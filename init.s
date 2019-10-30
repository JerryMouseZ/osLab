	.file	"init.c"
	.stabs	"kern/init.c",100,0,2,.Ltext0
	.text
.Ltext0:
	.stabs	"gcc2_compiled.",60,0,0,0
	.stabs	"int:t(0,1)=r(0,1);-2147483648;2147483647;",128,0,0,0
	.stabs	"char:t(0,2)=r(0,2);0;127;",128,0,0,0
	.stabs	"long int:t(0,3)=r(0,3);-0;4294967295;",128,0,0,0
	.stabs	"unsigned int:t(0,4)=r(0,4);0;4294967295;",128,0,0,0
	.stabs	"long unsigned int:t(0,5)=r(0,5);0;-1;",128,0,0,0
	.stabs	"__int128:t(0,6)=r(0,6);0;-1;",128,0,0,0
	.stabs	"__int128 unsigned:t(0,7)=r(0,7);0;-1;",128,0,0,0
	.stabs	"long long int:t(0,8)=r(0,8);-0;4294967295;",128,0,0,0
	.stabs	"long long unsigned int:t(0,9)=r(0,9);0;-1;",128,0,0,0
	.stabs	"short int:t(0,10)=r(0,10);-32768;32767;",128,0,0,0
	.stabs	"short unsigned int:t(0,11)=r(0,11);0;65535;",128,0,0,0
	.stabs	"signed char:t(0,12)=r(0,12);-128;127;",128,0,0,0
	.stabs	"unsigned char:t(0,13)=r(0,13);0;255;",128,0,0,0
	.stabs	"float:t(0,14)=r(0,1);4;0;",128,0,0,0
	.stabs	"double:t(0,15)=r(0,1);8;0;",128,0,0,0
	.stabs	"long double:t(0,16)=r(0,1);16;0;",128,0,0,0
	.stabs	"_Float32:t(0,17)=r(0,1);4;0;",128,0,0,0
	.stabs	"_Float64:t(0,18)=r(0,1);8;0;",128,0,0,0
	.stabs	"_Float128:t(0,19)=r(0,1);16;0;",128,0,0,0
	.stabs	"_Float32x:t(0,20)=r(0,1);8;0;",128,0,0,0
	.stabs	"_Float64x:t(0,21)=r(0,1);16;0;",128,0,0,0
	.stabs	"_Decimal32:t(0,22)=r(0,1);4;0;",128,0,0,0
	.stabs	"_Decimal64:t(0,23)=r(0,1);8;0;",128,0,0,0
	.stabs	"_Decimal128:t(0,24)=r(0,1);16;0;",128,0,0,0
	.stabs	"void:t(0,25)=(0,25)",128,0,0,0
	.stabs	"./inc/stdio.h",130,0,0,0
	.stabs	"./inc/stdarg.h",130,0,0,0
	.stabs	"va_list:t(2,1)=(2,2)=(2,3)=ar(2,4)=r(2,4);0;-1;;0;0;(2,5)=xs__va_list_tag:",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.stabs	"./inc/string.h",130,0,0,0
	.stabs	"./inc/types.h",130,0,0,0
	.stabs	"bool:t(4,1)=(4,2)=eFalse:0,True:1,;",128,0,0,0
	.stabs	" :T(4,3)=efalse:0,true:1,;",128,0,0,0
	.stabs	"int8_t:t(4,4)=(0,12)",128,0,0,0
	.stabs	"uint8_t:t(4,5)=(0,13)",128,0,0,0
	.stabs	"int16_t:t(4,6)=(0,10)",128,0,0,0
	.stabs	"uint16_t:t(4,7)=(0,11)",128,0,0,0
	.stabs	"int32_t:t(4,8)=(0,1)",128,0,0,0
	.stabs	"uint32_t:t(4,9)=(0,4)",128,0,0,0
	.stabs	"int64_t:t(4,10)=(0,8)",128,0,0,0
	.stabs	"uint64_t:t(4,11)=(0,9)",128,0,0,0
	.stabs	"intptr_t:t(4,12)=(4,8)",128,0,0,0
	.stabs	"uintptr_t:t(4,13)=(4,9)",128,0,0,0
	.stabs	"physaddr_t:t(4,14)=(4,9)",128,0,0,0
	.stabs	"ppn_t:t(4,15)=(4,9)",128,0,0,0
	.stabs	"size_t:t(4,16)=(4,9)",128,0,0,0
	.stabs	"ssize_t:t(4,17)=(4,8)",128,0,0,0
	.stabs	"off_t:t(4,18)=(4,8)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"entering test_backtrace %d\n"
.LC1:
	.string	"leaving test_backtrace %d\n"
	.text
	.p2align 4,,15
	.stabs	"test_backtrace:F(0,25)",36,0,0,test_backtrace
	.stabs	"x:P(0,1)",64,0,0,3
	.globl	test_backtrace
	.type	test_backtrace, @function
test_backtrace:
	.stabn	68,0,13,.LM0-.LFBB1
.LM0:
.LFBB1:
.LFB0:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	.stabn	68,0,14,.LM1-.LFBB1
.LM1:
	movl	%edi, %esi
	.stabn	68,0,13,.LM2-.LFBB1
.LM2:
	movl	%edi, %ebx
	.stabn	68,0,14,.LM3-.LFBB1
.LM3:
	leaq	.LC0(%rip), %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,15,.LM4-.LFBB1
.LM4:
	testl	%ebx, %ebx
	jg	.L6
	.stabn	68,0,18,.LM5-.LFBB1
.LM5:
	xorl	%edx, %edx
	xorl	%esi, %esi
	xorl	%edi, %edi
	call	mon_backtrace@PLT
.L3:
	.stabn	68,0,19,.LM6-.LFBB1
.LM6:
	movl	%ebx, %esi
	leaq	.LC1(%rip), %rdi
	xorl	%eax, %eax
	.stabn	68,0,20,.LM7-.LFBB1
.LM7:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	.stabn	68,0,19,.LM8-.LFBB1
.LM8:
	jmp	cprintf@PLT
	.p2align 4,,10
	.p2align 3
.L6:
	.cfi_restore_state
	.stabn	68,0,16,.LM9-.LFBB1
.LM9:
	leal	-1(%rbx), %edi
	call	test_backtrace
	jmp	.L3
	.cfi_endproc
.LFE0:
	.size	test_backtrace, .-test_backtrace
.Lscope1:
	.section	.rodata.str1.1
.LC2:
	.string	"6828 decimal is %o octal!\n"
.LC3:
	.string	"x %d, y %x, z %d\n"
.LC4:
	.string	"H%x Wo%s\n"
.LC5:
	.string	"x=%d y=%d\n"
	.text
	.p2align 4,,15
	.stabs	"i386_init:F(0,25)",36,0,0,i386_init
	.globl	i386_init
	.type	i386_init, @function
i386_init:
	.stabn	68,0,24,.LM10-.LFBB2
.LM10:
.LFBB2:
.LFB1:
	.cfi_startproc
	.stabn	68,0,30,.LM11-.LFBB2
.LM11:
	leaq	edata(%rip), %rdi
	leaq	end(%rip), %rdx
	.stabn	68,0,24,.LM12-.LFBB2
.LM12:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	.stabn	68,0,30,.LM13-.LFBB2
.LM13:
	xorl	%esi, %esi
	subq	%rdi, %rdx
	.stabn	68,0,24,.LM14-.LFBB2
.LM14:
	movq	%fs:40, %rax
	movq	%rax, 8(%rsp)
	xorl	%eax, %eax
	.stabn	68,0,30,.LM15-.LFBB2
.LM15:
	call	memset@PLT
	.stabn	68,0,34,.LM16-.LFBB2
.LM16:
	call	cons_init@PLT
	.stabn	68,0,36,.LM17-.LFBB2
.LM17:
	leaq	.LC2(%rip), %rdi
	movl	$6828, %esi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,38,.LM18-.LFBB2
.LM18:
	leaq	.LC3(%rip), %rdi
	movl	$4, %ecx
	movl	$3, %edx
	movl	$1, %esi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,41,.LM19-.LFBB2
.LM19:
	leaq	4(%rsp), %rdx
	leaq	.LC4(%rip), %rdi
	movl	$57616, %esi
	xorl	%eax, %eax
	.stabn	68,0,40,.LM20-.LFBB2
.LM20:
	movl	$6581362, 4(%rsp)
	.stabn	68,0,41,.LM21-.LFBB2
.LM21:
	call	cprintf@PLT
	.stabn	68,0,42,.LM22-.LFBB2
.LM22:
	leaq	.LC5(%rip), %rdi
	movl	$3, %esi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,44,.LM23-.LFBB2
.LM23:
	movl	$5, %edi
	call	test_backtrace
	.p2align 4,,10
	.p2align 3
.L8:
	.stabn	68,0,48,.LM24-.LFBB2
.LM24:
	xorl	%edi, %edi
	call	monitor@PLT
	jmp	.L8
	.cfi_endproc
.LFE1:
	.size	i386_init, .-i386_init
	.stabs	"i:(0,4)",128,0,0,4
	.stabn	192,0,0,.LFBB2-.LFBB2
	.stabn	224,0,0,.Lscope2-.LFBB2
.Lscope2:
	.section	.rodata.str1.1
.LC6:
	.string	"kernel panic at %s:%d: "
.LC7:
	.string	"\n"
	.text
	.p2align 4,,15
	.stabs	"_panic:F(0,25)",36,0,0,_panic
	.stabs	"file:P(0,26)=*(0,2)",64,0,0,5
	.stabs	"line:P(0,1)",64,0,0,4
	.stabs	"fmt:P(0,26)",64,0,0,3
	.globl	_panic
	.type	_panic, @function
_panic:
	.stabn	68,0,64,.LM25-.LFBB3
.LM25:
.LFBB3:
.LFB2:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movq	%rdx, %rbx
	subq	$208, %rsp
	.cfi_def_cfa_offset 224
	testb	%al, %al
	movq	%rcx, 56(%rsp)
	movq	%r8, 64(%rsp)
	movq	%r9, 72(%rsp)
	je	.L12
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm1, 96(%rsp)
	movaps	%xmm2, 112(%rsp)
	movaps	%xmm3, 128(%rsp)
	movaps	%xmm4, 144(%rsp)
	movaps	%xmm5, 160(%rsp)
	movaps	%xmm6, 176(%rsp)
	movaps	%xmm7, 192(%rsp)
.L12:
	.stabn	68,0,64,.LM26-.LFBB3
.LM26:
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	.stabn	68,0,67,.LM27-.LFBB3
.LM27:
	cmpq	$0, panicstr(%rip)
	je	.L17
	.p2align 4,,10
	.p2align 3
.L14:
	.stabn	68,0,83,.LM28-.LFBB3
.LM28:
	xorl	%edi, %edi
	call	monitor@PLT
	jmp	.L14
.L17:
	.stabn	68,0,69,.LM29-.LFBB3
.LM29:
	movq	%rbx, panicstr(%rip)
	.stabn	68,0,72,.LM30-.LFBB3
.LM30:
#APP
# 72 "kern/init.c" 1
	cli; cld
# 0 "" 2
	.stabn	68,0,74,.LM31-.LFBB3
.LM31:
#NO_APP
	leaq	224(%rsp), %rax
	.stabn	68,0,75,.LM32-.LFBB3
.LM32:
	movl	%esi, %edx
	movq	%rdi, %rsi
	leaq	.LC6(%rip), %rdi
	.stabn	68,0,74,.LM33-.LFBB3
.LM33:
	movl	$24, (%rsp)
	movl	$48, 4(%rsp)
	movq	%rax, 8(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 16(%rsp)
	.stabn	68,0,75,.LM34-.LFBB3
.LM34:
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,76,.LM35-.LFBB3
.LM35:
	movq	%rbx, %rdi
	movq	%rsp, %rsi
	call	vcprintf@PLT
	.stabn	68,0,77,.LM36-.LFBB3
.LM36:
	leaq	.LC7(%rip), %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
	jmp	.L14
	.cfi_endproc
.LFE2:
	.size	_panic, .-_panic
	.stabs	"ap:(2,1)",128,0,0,0
	.stabn	192,0,0,.LFBB3-.LFBB3
	.stabn	224,0,0,.Lscope3-.LFBB3
.Lscope3:
	.section	.rodata.str1.1
.LC8:
	.string	"kernel warning at %s:%d: "
	.text
	.p2align 4,,15
	.stabs	"_warn:F(0,25)",36,0,0,_warn
	.stabs	"file:P(0,26)",64,0,0,5
	.stabs	"line:P(0,1)",64,0,0,4
	.stabs	"fmt:P(0,26)",64,0,0,3
	.globl	_warn
	.type	_warn, @function
_warn:
	.stabn	68,0,89,.LM37-.LFBB4
.LM37:
.LFBB4:
.LFB3:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movq	%rdx, %rbx
	subq	$208, %rsp
	.cfi_def_cfa_offset 224
	testb	%al, %al
	movq	%rcx, 56(%rsp)
	movq	%r8, 64(%rsp)
	movq	%r9, 72(%rsp)
	je	.L19
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm1, 96(%rsp)
	movaps	%xmm2, 112(%rsp)
	movaps	%xmm3, 128(%rsp)
	movaps	%xmm4, 144(%rsp)
	movaps	%xmm5, 160(%rsp)
	movaps	%xmm6, 176(%rsp)
	movaps	%xmm7, 192(%rsp)
.L19:
	.stabn	68,0,89,.LM38-.LFBB4
.LM38:
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	.stabn	68,0,92,.LM39-.LFBB4
.LM39:
	leaq	224(%rsp), %rax
	.stabn	68,0,93,.LM40-.LFBB4
.LM40:
	movl	%esi, %edx
	movq	%rdi, %rsi
	leaq	.LC8(%rip), %rdi
	.stabn	68,0,92,.LM41-.LFBB4
.LM41:
	movq	%rax, 8(%rsp)
	leaq	32(%rsp), %rax
	movl	$24, (%rsp)
	movl	$48, 4(%rsp)
	movq	%rax, 16(%rsp)
	.stabn	68,0,93,.LM42-.LFBB4
.LM42:
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,94,.LM43-.LFBB4
.LM43:
	movq	%rsp, %rsi
	movq	%rbx, %rdi
	call	vcprintf@PLT
	.stabn	68,0,95,.LM44-.LFBB4
.LM44:
	leaq	.LC7(%rip), %rdi
	xorl	%eax, %eax
	call	cprintf@PLT
	.stabn	68,0,97,.LM45-.LFBB4
.LM45:
	movq	24(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L22
	addq	$208, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
.L22:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE3:
	.size	_warn, .-_warn
	.stabs	"ap:(2,1)",128,0,0,0
	.stabn	192,0,0,.LFBB4-.LFBB4
	.stabn	224,0,0,.Lscope4-.LFBB4
.Lscope4:
	.comm	panicstr,8,8
	.stabs	"panicstr:G(0,26)",32,0,0,0
	.stabs	"",100,0,0,.Letext0
.Letext0:
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
