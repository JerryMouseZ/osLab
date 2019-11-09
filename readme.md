[TOC]

# JOS内核监视器

## 预备工作

```c
static struct Command commands[] = {

    {"help", "Display this list of commands or one of the command", "help\nhelp <command>", mon_help},

    {"kerninfo", "Display information about the kernel", "kerninfo", mon_kerninfo},

    {"backtrace", "Display backtrace info", "backtrace", mon_backtrace},

    {"showmappings", "Display the permission of the vaddr between begin and end", "showmappings <begin> <end>", mon_showmapping},

    {"setperm", "set the permission of the virtual address bewteen begin and end",

     "setperm <begin> <end> <perm>", mon_setPrivilege},

    {"dump", "Display the contents between begin and end", "dump -p/-v <begin> <end>", mon_dump},

};
```

```c
int mon_help(int argc, char **argv, struct Trapframe *tf)
{
	// cprintf("%x\n", UPAGES);
	if (argc == 1)
	{
		int i;
		for (i = 0; i < NCOMMANDS; i++)
			cprintf("%s - %s - usage:\n%s\n", commands[i].name, commands[i].desc, commands[i].usage);
	}
	else if (argc == 2)
	{
		int i;
		for (i = 0; i < NCOMMANDS; i++)
			if (!strcmp(commands[i].name, argv[1]))
				cprintf("%s - %s - usage:\n%s\n", commands[i].name, commands[i].desc, commands[i].usage);
	}
	else
	{
		cprintf("help usage:\n%s\n", commands[0].usage);
	}
	return 0;
}
```

调整commands 结构，增加一个usage信息

同时调整help函数，增加help + command 的用法，显示命令的信息和用法。



## (1) showmappings addr1 addr2 显示虚拟地址在addr1 - addr2 之间的页的权限位

```c
int mon_showmapping(int argc, char **argv, struct Trapframe *tf)
{
	if (argc == 3)
	{
		uint32_t begin, end;
		// 将begin,end 4k 对齐
		char *endptr;
		begin = ROUNDDOWN((uint32_t)strtol(argv[1], &endptr, 0), PGSIZE);
		end = ROUNDUP((uint32_t)strtol(argv[2], &endptr, 0), PGSIZE);
		for (; begin < end; begin += PGSIZE)
		{
			struct PageInfo *pg;
			// 拿到PTE的低12位
			pte_t *pte;
			pte = pgdir_walk(kern_pgdir, (void *)begin, 0);
			pg = page_lookup(kern_pgdir, (void *)begin, 0);
			if (!pte || !(*pte & PTE_P))
			{
				cprintf("0x%x - 0x%x not mapping \n", begin, begin + PGSIZE);
			}
			else
			{
				cprintf("0x%x - 0x%x\t Phy Addr: %x\treference: %d\n", begin, begin + PGSIZE, page2pa(pg), pg->pp_ref);
				cprintf("0x%x - 0x%x user state: %d\twritable: %d\tpresent: %d\n", begin, begin + PGSIZE, (bool)(*pte & PTE_U), (bool)(*pte & PTE_W), (bool)(*pte & PTE_P));
			}
		}
	}
	else
	{
		cprintf("showmapping usage:\n%s\n", commands[3].usage);
	}
	return 0;
}
```

实现思路大概为向下找到begin所在的页的开始地址和end所在的页的结束地址，然后用pgdir_walk拿到二级页表项以查看U W P 位并输出。page_look 拿到 所在的页面信息以查看该页的引用情况并输出。

## (2) setperm begin end perm 修改虚拟地址在begin和end之间的虚拟页权限位

```c
int mon_setPrivilege(int argc, char **argv, struct Trapframe *tf)
{
	if (argc == 4)
	{
		uint32_t begin, end;
		int perm;
		// 将begin,end 4k 对齐
		char *endptr;
		begin = ROUNDDOWN((uint32_t)strtol(argv[1], &endptr, 0), PGSIZE);
		end = ROUNDUP((uint32_t)strtol(argv[2], &endptr, 0), PGSIZE);
		perm = (int)strtol(argv[3], &endptr, 0);
		if (perm < 0 || perm > 0xfff)
		{
			cprintf("plese input a number between 0 and 0xfff\n");
			return 0;
		}
		for (; begin < end; begin += PGSIZE)
		{
			struct PageInfo *pg;
			// 拿到PTE的低12位
			pte_t *pte;
			pte = pgdir_walk(kern_pgdir, (void *)begin, 0);
			if (!pte || !(*pte & PTE_P))
			{
				return 0;
			}
			else
			{
				if (!perm & PTE_P)
				{
					page_remove(kern_pgdir, (void *)begin);
				}
				else
				{
					*pte = (*pte & 0xfffff000) | perm;
					cprintf("0x%x - 0x%x perm: %d\n", begin, begin + PGSIZE, *pte & 0xfff);
				}
			}
		}
	}
	else
	{
		cprintf("setperm usage:\n setperm <begin> <end> <perm>");
	}
	return 0;
}
```

实现思路为用pgdir_walk()拿到二级页表项，然后清空低12位或上perm即可。另外一点小细节就是当P位被置为0时页面会失效，因此需要使用page_remove()取消该页的映射。

## (3) dump -v/-p begin end 以4字节为单位输出虚拟地址或者物理地址在 begin和end之间的内容

```c
int mon_dump(int argc, char **argv, struct Trapframe *tf)
{
	if (argc == 4)
	{
		uint32_t begin, end;
		char *endptr;
		if (*argv[1] == '-')
		{
			if (argv[1][1] == 'p') //dump -p addr (physical)
			{
				begin = (uint32_t)KADDR(strtol(argv[2], &endptr, 0));
				end = (uint32_t)KADDR(strtol(argv[3], &endptr, 0));
				cprintf("physical address\tcontent\n");
			}
			else if (argv[1][1] == 'v') //dump -v addr (virtual)
			{

				begin = (uint32_t)strtol(argv[2], &endptr, 0);
				end = (uint32_t)strtol(argv[3], &endptr, 0);
				cprintf("virtual address\tcontent\n");
			}
			else
			{
				cprintf("dump usage:\n dump -p/-v <begin> <end>\n");
				return 1;
			}

			for (; begin < end; begin += 4)
			{
				cprintf("0x%08x\t", begin);
				struct PageInfo *pg;
				pg = page_lookup(kern_pgdir, (void *)ROUNDDOWN(begin, PGSIZE), 0);
				if (pg == NULL)
				{
					cprintf("No Mapping\n");
					begin += PGSIZE - begin % PGSIZE;
					continue;
				}
				cprintf("%d\n", *(uint32_t *)begin);
			}
		}
	}
	else
	{
		cprintf("dump usage:\n dump -p/-v <begin> <end>\n");
		return 1;
	}
	return 0;
}
```

根据-p 还是 -v 区分物理地址和虚拟地址。如果是物理地址则需转换成虚拟地址。然后用page_lookup判断该地址所在的页面是否存在，如果存在的话每四个字节输出成一个无符号整数即可。



## 演示

![image-20191109220243270](image-20191109220243270.png)

先是查看所有指令的用法

![image-20191109220306784](image-20191109220306784.png)

然后查看0xef000000 - 0xef008000 之间的页面信息和权限 U W P位

![image-20191109220321416](image-20191109220321416.png)

给刚刚的地址范围设置页面权限为0，再查看发现这些页面都失效了。

![image-20191109220335026](image-20191109220335026.png)

用dump查看虚拟地址的信息。

![image-20191109220346809](image-20191109220346809.png)

查看物理地址信息。





# 蒋璋报告和总结：

## 练习1：

- boot_alloc()
- mem_init()（仅完成调用     `check_page_free_list(1)` 之前的部分）
- page_init()
- page_alloc()
- page_free()

 

boot_alloc()

用于查看空闲内存的起始地址，当参数为0时。

以及在内存建立过程中，即页表初始化之前内存的分配。

![image-20191109220404522](image-20191109220404522.png)

这里可以看出bss段是在整个程序的最后的，因为最后的comment注释是不会写入内存的。那么end指向bss段的末尾，即整个内存的最后一个地址。bss段存放的是未被初始化的全局变量，属于静态内存分配。然后找到向PGSIZE对其的下一个地址即可

```c
static char *nextfree; // virtual address of next byte of free memory

char *result;

  // 第一次调用时 end指向 bss段，即静态变量所在位置的最后，也是内核全局变量的第一个虚拟地址

  if (!nextfree)

  {

​    extern char end[];

​    nextfree = ROUNDUP((char *)end, PGSIZE);

  }

  // Allocate a chunk large enough to hold 'n' bytes, then update

  // nextfree. Make sure nextfree is kept aligned

  // to a multiple of PGSIZE.

  //

  // LAB 2: Your code here.

  cprintf("boot_alloc memory at %x\n", nextfree);

  cprintf("Next memory at %x\n", ROUNDUP((char *)(nextfree + n), PGSIZE));

  result = nextfree;

  nextfree = ROUNDUP((char *)(result + n), PGSIZE);

  // 如果没有足够的内存了，应该panic

  return result;
```

mem_init()

内存初始化

page_init()

根据注释中的提示，把page0 标记成使用中。用于存放BIOS 以及中断向量表IDT。然后下一块内存是空闲的。IO hole 必须标记成使用中。当然我们前面调用了boot_alloc()分配了一部分内存，所以最后一部分可以被分配的内存已经被分配了一部分，但是可以通过调用boot_alloc(0) 知道下一个未被分配的页的起始地址，在那之前的页标记为已分配，之后标记成未分配。

```c
size_t i;

  //1

  pages[0].pp_ref = 1;

  pages[0].pp_link = NULL;

  for (i = 1; i < npages; i++)

  {

​    // 2

​    /*page_init()中，通过page_free_list这个全局中间变量，把后一个页面的pp_link指向前一个页面,于是这里就把所有的pages都链接起来了*/

​    if (i < npages_basemem)

​    {

​      pages[i].pp_ref = 0;

​      pages[i].pp_link = page_free_list;

​      page_free_list = &pages[i];

​      // 相当于 temp->next = head ; head = temp; 把temp 加在了链表的头节点

​    }

​    // 3 注意/是向下取整的，不要扩大范围

​    else if (i >= ROUNDUP(IOPHYSMEM, PGSIZE) / PGSIZE && i < EXTPHYSMEM / PGSIZE)

​    {

​      pages[i].pp_ref = 1;

​      pages[i].pp_link = NULL;

​    }

​    // 4 通过alloc(0)拿到下一条空闲地址

​    else if (i >= EXTPHYSMEM / PGSIZE && i < ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE)

​    {

​      pages[i].pp_ref = 1;

​      pages[i].pp_link = NULL;

​    }

​    else

​    {

​      pages[i].pp_ref = 0;

​      pages[i].pp_link = page_free_list;

​      page_free_list = &pages[i];

​    }

  }
```

page_alloc()

页表建立后真正的内存分配，从free_list中取下一项并标记成已使用，把free_list的指针往后移动。

```c
if (!page_free_list)

  {

​    return NULL;

  }

  struct PageInfo *pp = NULL;

  pp = page_free_list;

  page_free_list = pp->pp_link;

  pp->pp_link = NULL;

  if (alloc_flags & ALLOC_ZERO)

  {

​    memset(page2kva(pp), 0, PGSIZE);

  }

  return pp;
```



page_free() 将一个页表项加入到free_list中

```c
void page_free(struct PageInfo *pp)

{

  // Fill this function in

  // Hint: You may want to panic if pp->pp_ref is nonzero or

  // pp->pp_link is not NULL.

  if (pp->pp_ref == 0 && pp->pp_link == NULL)

  {

​    pp->pp_link = page_free_list;

​    page_free_list = pp;

  }

  else

  {

​    panic("page_free error!\n");

  }

}
```

### 小问题：

线性地址，虚拟地址和物理地址的关系

 

C中所有的指针都是虚拟地址。

在实验中，指出了很重要的一点，一般来说，c语言的指针，它指向的地址是段的偏移量，即OFFSET，其实不是虚拟地址，还需要加上段基址才可以得到那个指针变量的虚拟地址，然后经过页翻译，得到实际的物理地址。但是jos由于不支持段，因此可以把段基址看成0。

### 问题1：

**假设以下 JOS 内核代码是正确的，变量 x 应该是什么类型？uintptr_t 还是 physaddr_t？**

```c
mystery_t x;char * value = return_a_pointer（）;* value = 10;

x =（mystery_t）value;
```

那么这个应该很明显了，所有的指针都是虚拟地址

 

虚拟地址和物理地址的转换关系：

为了将一个物理地址转换到内核可以直接读写的虚拟地址，内核为了在虚拟地址映射区域内相应的原来物理地址对应的位置，必须将物理地址增加 `0xf0000000`，做你可以用下面这个宏：`KADDR(pa)` 来完成这个加法操作。

JOS 内核有时还需要能够根据虚拟地址找到相应的物理地址。内核的全局变量以及使用 boot_alloc() 分配的内存，都在内核加载的区域中，即从 0xf0000000 开始的区域，也就是我们映射了所有物理内存的区域。因此，要将该区域中的虚拟地址转换为物理地址，内核可以简单地减去 0xf0000000。你可以用 PADDR(va) 来完成这个减法。

## 练习 4. 

![image-20191109220434556](image-20191109220434556.png)

在文件 `kern/pmap.c` 中，实现以下函数的代码。

- `pgdir_walk()`
- `boot_map_region()`
- `page_lookup()`
- `page_remove()`
- `page_insert()`

 

pgdir_walk()：返回va对应的二级页表的地址(PTE) ，PDE（页目录表）即页表的树根，由CR3寄存器指向

```c
int dindex = PDX(va), tindex = PTX(va);

  //dir index, table index

  if (!(pgdir[dindex] & PTE_P))

  { //if pde not exist

​    if (create)

`` 

​    {

​      struct PageInfo *pg = page_alloc(ALLOC_ZERO); //alloc a zero page

​      if (!pg)

​        return NULL; //allocation fails

​      pg->pp_ref++;

​      pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;

​      //we should use PTE_U and PTE_W to pass checkings

​    }

​    else

​      return NULL;

  }

  pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));

`` 

  return p + tindex;
```

先是判断是否存在所在的页表，如果不存在需要创建该PTE所在的页表。首先dindex = va的高10位作为pgdir的偏移，找到所在的二级页表。不存在需要分配一个页，然后pgdir[index] = 分配了该页的物理地址，这就是说，页目录表中存的地址，全都是物理地址！ 然后返回该二级页表的基址，加上所在的1024项中的偏移。千万注意，返回的一定是虚拟地址呀！

 

2. boot_map_region： [va, va+size)映射到[pa, pa+size)

这个函数比较简单，功能就是把 [va, va+size)映射到[pa, pa+size)

就是调用pgdir_walk()把二级页表的页表项（PTE）赋值为 pa 低12位为0（为什么是12不是0，因为要找的是字节而不是字，所以要多两位），与上权限 perm|PTE_P

```c
int i;

  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE)

  {

​    pte_t *pte = pgdir_walk(pgdir, (void *)va, 1); //create

​    if (!pte)

​      panic("boot_map_region panic, out of memory");

​    *pte = pa | perm | PTE_P;

  }
```

3.page_lookup：返回虚拟地址va对应的物理地址的页面page

```c
pte_t *pte = pgdir_walk(pgdir, va, 0); //not create

  if (!pte || !(*pte & PTE_P))

​    return NULL; //page not found

  if (pte_store)

​    *pte_store = pte; //found and set

  return pa2page(PTE_ADDR(*pte));
```

用pgdir_walk 找到对应的二级页表项，就是虚拟地址对应的物理页面的虚拟地址了。转化一下就有结果了。

4.page_remove：对va和其对应的页面取消映射

5.page_insert:把va映射到指定的物理页表page

```c
int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)

{

  // Fill this function in

  pte_t *pte = pgdir_walk(pgdir, va, 1); //create on demand

  if (!pte)               //page table not allocated

​    return -E_NO_MEM;

  //increase ref count beforehand to avoid the corner case that pp is freed before it is inserted.

  pp->pp_ref++;

  if (*pte & PTE_P) //page colides, tle is invalidated in page_remove

​    page_remove(pgdir, va);

  *pte = page2pa(pp) | perm | PTE_P;

  return 0;

}
```

首先拿到该地址对应的虚拟地址，存储到pte指针中，如果pte为空，说明内存溢出了。然后看pte是否有效，如果有效则需remove他。最后让*pte的值为pp的物理地址即可。

这个函数要考虑三种情况：

1:va没有对应的映射page

2:va有对应的映射page，但是不是指定的page

3:va有对应的映射page，并且和指定的page相同。

虚拟内存结构

![image-20191109220502055](image-20191109220502055.png)

```c
/*

 \* Virtual memory map:                Permissions

 \*                          kernel/user

 *

 \*  4 Gig --------> +------------------------------+

 \*           |               | RW/--

 \*           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 \*           :       .        :

 \*           :       .        :

 \*           :       .        :

 \*           |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~| RW/--

 \*           |               | RW/--

 \*           |  Remapped Physical Memory  | RW/--

 \*           |               | RW/--

 \*  KERNBASE, ----> +------------------------------+ 0xf0000000   --+

 \*  KSTACKTOP    |   CPU0's Kernel Stack   | RW/-- KSTKSIZE  |

 \*           | - - - - - - - - - - - - - - -|          |

 \*           |   Invalid Memory (*)   | --/-- KSTKGAP  |

 \*           +------------------------------+          |

 \*           |   CPU1's Kernel Stack   | RW/-- KSTKSIZE  |

 \*           | - - - - - - - - - - - - - - -|         PTSIZE

 \*           |   Invalid Memory (*)   | --/-- KSTKGAP  |

 \*           +------------------------------+          |

 \*           :       .        :          |

 \*           :       .        :          |

 \*  MMIOLIM ------> +------------------------------+ 0xefc00000   --+

 \*           |    Memory-mapped I/O   | RW/-- PTSIZE

 \* ULIM, MMIOBASE --> +------------------------------+ 0xef800000

 \*           | Cur. Page Table (User R-)  | R-/R- PTSIZE

 \*  UVPT   ----> +------------------------------+ 0xef400000

 \*           |     RO PAGES      | R-/R- PTSIZE

 \*  UPAGES  ----> +------------------------------+ 0xef000000

 \*           |      RO ENVS      | R-/R- PTSIZE

 \* UTOP,UENVS ------> +------------------------------+ 0xeec00000

 \* UXSTACKTOP -/    |   User Exception Stack   | RW/RW PGSIZE

 \*           +------------------------------+ 0xeebff000

 \*           |    Empty Memory (*)    | --/-- PGSIZE

 \*  USTACKTOP ---> +------------------------------+ 0xeebfe000

 \*           |   Normal User Stack    | RW/RW PGSIZE

 \*           +------------------------------+ 0xeebfd000

 \*           |               |

 \*           |               |

 \*           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 \*           .               .

 \*           .               .

 \*           .               .

 \*           |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|

 \*           |   Program Data & Heap   |

 \*  UTEXT --------> +------------------------------+ 0x00800000

 \*  PFTEMP -------> |    Empty Memory (*)    |    PTSIZE

 \*           |               |

 \*  UTEMP --------> +------------------------------+ 0x00400000   --+

 \*           |    Empty Memory (*)    |          |

 \*           | - - - - - - - - - - - - - - -|          |

 \*           | User STAB Data (optional)  |         PTSIZE

 \*  USTABDATA ----> +------------------------------+ 0x00200000    |

 \*           |    Empty Memory (*)    |          |

 \*  0 ------------> +------------------------------+         --+

 *

 \* (*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.

 \*   "Empty Memory" is normally unmapped, but user programs may map pages

 \*   there if desired. JOS user programs map pages temporarily at UTEMP.

 */
```

物理地址结构：

![image-20191109220527080](image-20191109220527080.png)

### 问题2. 

假设下图描述的是系统的页目录表，哪些条目（行）已经被填充了？它们是怎么样进行地址映射的？它们所指向的位置在哪里？请尽可能完善这张表的内容。

| **Entry** | **Base Virtual Address** | **Points to (logically)**              |
| --------- | ------------------------ | -------------------------------------- |
| 1023      | 0xffc00000               | Page table for top 4MB of phys  memory |
| 1022      | 0xff800000               | ...                                    |
| .         | ?                        | ？                                     |
| 960       | 0xf0000000               | 最低4k                                 |
|           |                          |                                        |
| 959       | efc00000                 | 接下来的8页放内核栈，映射到内核代码中  |
| .         | ?                        | ?                                      |
|           | 0xef400000               | kern_dir 页目录表                      |
| 957       | 0xef000000               | pages数组（物理页管理）                |
| .         | ?                        | ？                                     |
| .         | ?                        | ？                                     |
| 2         | 0x00800000               | ?                                      |
| 1         | 0x00400000               | ?                                      |
| 0         | 0x00000000               | [see next question]                    |

3BD号页目录项，指向的是kern_pgdir

3BC号页目录项，指向的是pages数组

3BF号页目录项，指向的是bootstack

3C0~3FF号页目录项，指向的是kernel

### 问题3：

我们已经将内核和用户环境放在同一地址空间内。为什么用户的程序不能读取内核的内存？有什么具体的机制保护内核空间吗？

主要是靠PTE_U来保护。

上图就是pte和pde中的地址分布情况，由于低12位是偏移位，是由va决定的，所以低12位就被用作页面的标志位。这里主要看低3位，即U，W，P三个标志位。

p：代表页面是否有效，若为1，表示页面有效。否则，表示页面无效，不能映射页面，否则会发生错误。

W:表示页面是否可写。若为1，则页面可以进行写操作，否则，页面是只读页面，不能进行修改。

U：表示用户程序是否可以使用该页面。若位1，表示此页面是用户页面，用户程序可以使用并且访问该页面。若为0，则表示用户程序不能访问该页面，只有内核才能访问页面。

上面的页面标志位，可以有效的保护系统的安全。由于操作系统运行在内核空间(微内核除外，其部分系统功能在用户态下进行)中运行，而一般的用户程序都是在用户空间上运行的。所以用户程序的奔溃，不会影响到操作系统，因为用户程序无权对内核地址中的内容进行修改。这就有效的对操作系统和用户程序进行了隔离，加强了系统的稳定性。

在整个地址的中间的地址部分[UTOP,ULIM)，用户程序和内核都可以访问，但是这部分内存是只读的，不可以修改，在这部分内存中，主要存储内核的一些只读数据。可能GDT什么的一些表就存在这部分地址空间中。 

接下去的低位内存中，存的就是给用户程序使用的地址了。 

因为我们在初始化页目录项的时候，在目录项的低12位给内核设定了权限，但是并没有给用户相应的权限，采用了内存管理中的页保护机制

### 问题4：

**JOS 操作系统可以支持的最大物理内存是多少？为什么？**

由于在内存中，UPAGES总共有4M的内存来存储pages，也就是总共可以存4M/8Byte=0.5M个页面，总共的内存大小为0.5M*4K=2G，所以总共2G内存最大。

在实验中：

kern_dir 由 boot_alloc(0) 返回，该地址作为页目录表

npages = 16639一共这么多页面，在page_init()中可以知道

管理这些页面需要`sizeof(struct PageInfo))=8`Byte

8 * npages/1024 = 129k

npages*PGSIZE/1024 就是最大能管理的内存了。

UPAGES = ef000000 = 956M 也就是最大页面数。

66556k

base = 640k extended = 65532k

从  0x00000~0xA0000，这部分也叫basemem，是可用的。npages_basemem就是记录basemem的页数。

紧接0xA0000~0x100000，这部分叫做IO hole，是不可用的，主要被用来分配给外部设备。

然后0x100000~0x，这部分叫做extmem，是可用的。npages_extmem就是记录extmem的页数。

### 问题5：

**如果我们的硬件配置了可以支持的最大的物理内存，那么管理内存空间的开销是多少？这一开销是怎样划分的？**

2G内存的话，总共页面数就是0.5M个，pages结构体(PageInfo)的大小就是0.5M*8Byte=4M，page director是4K, 由于pages的数目为0.5M,所以page table是0.5M*4byge=2M，所以总共是6M+4k

将PTE_PS置位，使得页面大小由4K变为4M即可减少。

### 问题6：

**再次分析 kern/entry.S 和 kern/entrypgdir.c 的页表设置的过程，在打开分页之后，EIP 依然是一个数字（稍微超过 1MB）。在什么时刻我们才开始在 KERNBASE 上运行 EIP 的？当我们启动分页并在 KERNBASE 上开始运行 EIP 之时，我们能否以低地址的 EIP 继续执行？这个过渡为什么是必须要的？** 

在entrypgdir.c中预设了两个数组，`entry_pgtable[]`：预设了一个二级页表中的值，  

`entry_pgdir[]`：预设了页目录的值，如下：

即已经把entry_pgdir[]数组中0号元素设置成了与虚拟地址0:0x400000对应的物理地址0:0x400000(页表项 0 将虚拟地址 0:0x400000 映射到物理地址 0:0x400000),同样，页表项 960将虚拟地址的 KERNBASE:KERNBASE+0x400000 映射到物理地址 0:0x400000。这个页表项将在 entry.S 的代码结束后被使用；它将内核指令和内核数据应该出现的高虚拟地址处映射到了 boot loader 实际将它们载入的低物理地址处（0x100000）。这个映射就限制内核的指令+代码必须在 4mb 以内(实际是在3MB以内)。因为将系统区域放在虚拟地址的高地址是约定好了的

jmp *％eax完成之后。 能，是因为entry_pgdir还将va [0，4M）映射到pa [0，4M），这是必要的，因为稍后将加载kern_pgdir并将va [0，4M）放弃。





# 李明旗吐槽和报告：

 **1**；刚开始**git checkout -b lab2 origin/lab2**切换lab1到lab2,发现同学们都能切换出lab2的文件，但是我的真的没有，搞了好长时间，最后没办法把lab1_1删了，重新解压出lab1_1,再次**git checkout -b lab2 origin/lab2****，**发现终于有了，为什么咱也不知道。。。。

  **2**；最后make grade的时候老报错，问了一下学长

![image-20191109220610400](image-20191109220610400.png)

把GUNmakefile里的-Werror删掉，不把警告当报错处理

![image-20191109220620872](image-20191109220620872.png)

## 练习1：

 boot_alloc()函数，核心思想就是维护一个静态变量nextfree，里面存放着下一个可以使用的空闲内存空间的虚拟地址，所以每次当我们想要分配n个字节的内存时，我们都需要修改这个变量的值。

 mem_init()函数添加代码完成的功能是分配一块内存，用来存放一个struct PageInfo的数组，数组中的每一个PageInfo代表内存当中的一页。

 page_init()， 初始化pages数组 ，初始化pages_free_list链表

page_alloc()函数，这个函数的功能就是分配一个物理页。而函数的返回值就是这个物理页所对应的PageInfo结构体

page_free()，这个方法的功能就是把一个页的PageInfo结构体再返回给page_free_list空闲页链表，代表回收了这个页。



### 问题1

这里使用了 * 操作符解析地址，所以变量x应该是uintptr_t类型，虚拟地址。

### 问题2

3BD号页目录项，指向的是kern_pgdir

3BC号页目录项，指向的是pages数组

3BF号页目录项，指向的是bootstack

3C0~3FF号页目录项，指向的是kernel

### 问题3

因为我们在初始化页目录项的时候，在目录项的低12位给内核设定了权限，但是并没有给用户相应的权限，采用了内存管理中的页保护机制

### 问题4

由于在内存中，UPAGES总共有4M的内存来存储pages，也就是总共可以存4M/8Byte=0.5M个页面，总共的内存大小为0.5M*4K=2G，所以总共2G内存最大

### 问题5

2G内存的话，总共页面数就是0.5M个，pages结构体(PageInfo)的大小就是0.5M**8Byte=4M**，**page director**是**4K,** 由于**pages**的数目为**0.5M,**所以**page table**是**0.5M**4byge=2M，所以总共是6M+4k 将PTE_PS置位，使得页面大小由4K变为4M即可减少

### 问题6

jmp *％eax完成之后。 能，是因为entry_pgdir还将va [0，4M）映射到pa [0，4M），这是必要的，因为稍后将加载kern_pgdir并将va [0，4M）放弃。

## 练习4：

pgdir_walk()函数，通过页目录表求得这个虚拟地址所在的页表页对于与页目录中的页目录项地址，然后判断这个页目录项对应的页表页是否已经在内存中。如果在，计算这个页表页的基地址page_base，如果不在则，且create为true则分配新的页，并且把这个页的信息添加到页目录项dic_entry_ptr中。

  boot_map_region()设置虚拟地址UTOP之上的地址范围，这一部分的地址映射是静态的，

page_lookup()函数，返回虚拟地址va所映射的物理页的PageInfo结构体的指针，如果pte_store参数不为0，则把这个物理页的页表项地址存放在pte_store中

page_remove函数，把虚拟地址va和物理页的映射关系删除

page_insert(),把一个物理内存中页与虚拟地址建立映射关系。

## 练习5：

**完善mem_init()函数**

首先我们要映射的范围是把pages数组映射到线性地址UPAGES，大小为一个PTSIZE

然后映射内核的堆栈区域，把由bootstack变量所标记的物理地址范围映射给内核的堆栈。

最后映射整个操作系统内核，虚拟地址范围是[KERNBASE, 2^32]，物理地址范围是[0，2^32 - KERNBASE]。

最后make grade 70分

![image-20191109220640740](image-20191109220640740.png)



# 黄希lab2实验报告：

lab2的具体实验内容两位队友都描述得十分详细，实现过程大同小异，不必赘述。

### 实验中的的吐槽：

​		主要就是本次实验需要查看和编写的代码比较多，分布在不同的几个文件中，在不同文件中定义的变量和宏就难以找到，因为这些变量和宏可能在引用的头文件中定义，甚至在头文件的头文件中定义……果断尝试在虚拟机中装VSCode来解决，但是虚拟机是32位的，没有找到Ubuntu下32位的VSCode……退一步下载Sublime试试，然而终端中安装Sublime竟然下载出错，在Sublime官网下载十分缓慢，中途还会中断几次，实在是让人崩溃。用自带的编辑器编写和查看代码真是太难受了，感受到了一个好的编辑器的重要性。

### 实验中的一些细节：

​		ROUNDUP和ROUNDDOWN函数在inc/types中定义，返回距第一个参数最近的向上或向下的第二个参数的整数倍。

​		PDX、PTX、PGOFF、PGADDR在inc/mmu.h中定义，分别返回页目录下标，页表项下标，页内偏移量，和根据这三个量合成的虚拟地址。

```
flags：

// Page table/directory entry flags.

\#define PTE_P       0x001   // Present

\#define PTE_W      0x002   // Writeable

\#define PTE_U       0x004   // User

\#define PTE_PWT        0x008   // Write-Through

\#define PTE_PCD     0x010   // Cache-Disable

\#define PTE_A       0x020   // Accessed

\#define PTE_D       0x040   // Dirty

\#define PTE_PS      0x080   // Page Size

\#define PTE_G       0x100   // Global
```

​		在inc/mmu.h中定义。

​		在inc/entrypgdir.c中，这段代码将虚拟地址的[0,4MB]和内核代码[KERNBASE, KERNBASE+4MB)都映射到同一块物理地址[0, 4MB)中，实现过渡。

```
  __attribute__((__aligned__(PGSIZE)))

pde_t entry_pgdir[NPDENTRIES] = {
	// Map VA's [0, 4MB) to PA's [0, 4MB)
	[0]
		= ((uintptr_t)entry_pgtable - KERNBASE) + PTE_P,
	// Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
	[KERNBASE>>PDXSHIFT]
		= ((uintptr_t)entry_pgtable - KERNBASE) + PTE_P + PTE_W
}; 
```

## 实验问题回答：

### 问题 1. 

**假设以下 JOS 内核代码是正确的，变量 x 应该是什么类型？uintptr_t 还是 physaddr_t？**

```
mystery_t x;

char * value = return_a_pointer（）;

\* value = 10;

x =（mystery_t）value;
```

由于这里使用了 * 操作符解析地址，所以变量x应该是uintptr_t类型。

 

### 问题 2. 

假设下图描述的是系统的页目录表，哪些条目（行）已经被填充了？它们是怎么样进行地址映射的？它们所指向的位置在哪里？请尽可能完善这张表的内容。

| **Entry** | **Base Virtual Address** | **Points to (logically)**              |
| --------- | ------------------------ | -------------------------------------- |
| 1023      | 0xffc00000               | Page table for top 4MB of phys  memory |
| 1022      | 0xff800000               | ...                                    |
| .         | ?                        | ？                                     |
| 960       | 0xf0000000               | 最低4k                                 |
|           |                          |                                        |
| 959       | efc00000                 | 接下来的8页放内核栈，映射到内核代码中  |
| .         | ?                        | ?                                      |
|           | 0xef400000               | kern_dir 页目录表                      |
| 957       | 0xef000000               | pages数组（物理页管理）                |
| .         | ?                        | ？                                     |
| .         | ?                        | ？                                     |
| 2         | 0x00800000               | ?                                      |
| 1         | 0x00400000               | ?                                      |
| 0         | 0x00000000               | [see next question]                    |

### 问题 3.

**我们已经将内核和用户环境放在同一地址空间内。为什么用户的程序不能读取内核的内存？有什么具体的机制保护内核空间吗？**
   	用户程序不能去随意修改内核中的代码，数据，否则可能会破坏内核，造成程序崩溃。
   	正常的操作系统通常采用两个部件来完成对内核地址的保护，一个是通过段机制来实现的，但是JOS中的分段功能并没有实现。二就是通过分页机制来实现，通过把页表项中的 Supervisor/User位置0，那么用户态的代码就不能访问内存中的这个页。



### 问题 4.

**JOS 操作系统可以支持的最大物理内存是多少？为什么？**
	  由于这个操作系统利用一个大小为4MB的空间UPAGES来存放所有的页的PageInfo结构体信息，每个结构体的大小为8B，所以一共可以存放512K个PageInfo结构体，所以一共可以出现512K个物理页，每个物理页大小为4KB，所以总的物理内存占2GB。

 

### 问题 5.

**如果我们的硬件配置了可以支持的最大的物理内存，那么管理内存空间的开销是多少？这一开销是怎样划分的？**
  	首先需要存放所有的PageInfo，需要4MB，需要存放页目录表kern_pgdir，4KB，还需要存放当前的页表，大小为2MB。所以总的开销就是6MB + 4KB。

 

### 问题 6.

**再次分析 kern/entry.S 和 kern/entrypgdir.c 的页表设置的过程，在打开分页之后，EIP 依然是一个数字（稍微超过 1MB）。在什么时刻我们才开始在 KERNBASE 上运行 EIP 的？当我们启动分页并在 KERNBASE 上开始运行 EIP 之时，我们能否以低地址的 EIP 继续执行？这个过渡为什么是必须要的？**
	  entry.S的注释中如下写到:`Jump up above KERNBASE before entering。`
	 之后的指令指令 jmp *%eax要完成跳转，就会重新设置EIP的值，把它设置为寄存器eax中的值，而这个值是大于KERNBASE的，所以就完成了EIP从小的值到大于KERNBASE的值的转换，在这之后开始在KERNBASE上运行。
 在entrypgdir.c中，把虚拟地址空间[0, 4MB)映射到物理地址空间[0, 4MB)上，所以当访问位于[0, 4MB)之间的虚拟地址时，可以把它们转换为物理地址，可以执行。这是必要的，因为稍后将加载kern_pgdir并将va [0，4M）放弃。

makegrade结果：

![image-20191109220658361](image-20191109220658361.png)