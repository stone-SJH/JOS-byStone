/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*stone's solution for lab3-A*/
	TRAPHANDLER_NOEC(t0,  T_DIVIDE);
	TRAPHANDLER_NOEC(t1,  T_DEBUG);
	TRAPHANDLER_NOEC(t2,  T_NMI);
	TRAPHANDLER_NOEC(t3,  T_BRKPT);
	TRAPHANDLER_NOEC(t4,  T_OFLOW);
	TRAPHANDLER_NOEC(t5,  T_BOUND);
	TRAPHANDLER_NOEC(t6,  T_ILLOP);
	TRAPHANDLER_NOEC(t7,  T_DEVICE);
	TRAPHANDLER	(t8,  T_DBLFLT);
	TRAPHANDLER	(t10, T_TSS);
	TRAPHANDLER	(t11, T_SEGNP);
	TRAPHANDLER	(t12, T_STACK);
	TRAPHANDLER	(t13, T_GPFLT);
	TRAPHANDLER	(t14, T_PGFLT);
	TRAPHANDLER_NOEC(t16, T_FPERR);
	TRAPHANDLER	(t17, T_ALIGN);
	TRAPHANDLER_NOEC(t18, T_MCHK);
	TRAPHANDLER_NOEC(t19, T_SIMDERR );
	/*stone's solution for lab4-A*/
	TRAPHANDLER_NOEC(user_syscall, T_SYSCALL);
	
.globl sysenter_handler;
.type sysenter_handler, @function;
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
/*stone's solution for lab3-B*/
	//User Data
	pushl $GD_UD|3
	pushl %ebp
	//flag registers
	pushfl
	//User Text
	pushl $GD_UT|3
	pushl %esi
	pushl $0
	pushl $0
	pushl %ds
	pushl %es

	//tf parse to router
	pushal
	//switch to Kernel Data
	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	//router is a method to parse modified register to syscall
	call router
	popl %esp
	popal
	popl %es
	popl %ds
	movl %ebp, %ecx
	movl %esi, %edx
	sysexit
/*
 * Lab 3: Your code here for _alltraps
 */
/*stone's solution for lab3-A*/
_alltraps:
	pushl %ds
	pushl %es
	pushal
	
	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	
	pushl %esp
	call trap
