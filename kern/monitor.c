// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE 80 // enough for one VGA text line

struct Command
{
	const char *name;
	const char *desc;
	const char *usage;
	// return -1 to force monitor to exit
	int (*func)(int argc, char **argv, struct Trapframe *tf);
};

static struct Command commands[] = {
	{"help", "Display this list of commands or one of the command", "help\nhelp <command>", mon_help},
	{"kerninfo", "Display information about the kernel", "kerninfo", mon_kerninfo},
	{"backtrace", "Display backtrace info", "backtrace", mon_backtrace},
	{"showmappings", "Display the permission of the vaddr between begin and end", "showmappings <begin> <end>", mon_showmapping},
	{"setperm", "set the permission of the virtual address bewteen begin and end",
	 "setperm <begin> <end> <perm>", mon_setPrivilege},
	{"dump", "Display the contents between begin and end", "dump -p/-v <begin> <end>", mon_dump},
};
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

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

int mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
			ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.

	uint32_t ebp, eip, arg[5];
	uint32_t *ptr_ebp;
	struct Eipdebuginfo info;

	ebp = read_ebp();
	eip = *((uint32_t *)ebp + 1);
	arg[0] = *((uint32_t *)ebp + 2);
	arg[1] = *((uint32_t *)ebp + 3);
	arg[2] = *((uint32_t *)ebp + 4);
	arg[3] = *((uint32_t *)ebp + 5);
	arg[4] = *((uint32_t *)ebp + 6);
	cprintf("Stack backtrace:\n");
	while (ebp != 0x00)
	{
		ptr_ebp = (uint32_t *)ebp;
		cprintf("ebp %08x eip %08x args %08x %08x %08x  %08x %08x\n",
				ebp, eip, arg[0], arg[1], arg[2], arg[3], arg[4]);
		ebp = *(uint32_t *)ebp;
		eip = *((uint32_t *)ebp + 1);
		arg[0] = *((uint32_t *)ebp + 2);
		arg[1] = *((uint32_t *)ebp + 3);
		arg[2] = *((uint32_t *)ebp + 4);
		arg[3] = *((uint32_t *)ebp + 5);
		arg[4] = *((uint32_t *)ebp + 6);
		if (debuginfo_eip(ptr_ebp[1], &info) == 0)
		{
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr;
			cprintf("\t\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
	}
	return 0;
}

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
/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1)
	{
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS - 1)
		{
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++)
	{
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
