/* See COPYRIGHT for copyright information. */

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/monitor.h>
#include <kern/console.h>
#include <kern/pmap.h>
#include <kern/kclock.h>
#include <kern/env.h>
#include <kern/trap.h>
#include <kern/sched.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
	int i;
	volatile int interval = 0;
	//cprintf("spinlock_test:\n");
	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}
	//cprintf("done\n");
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
			test_ctr++;
		//cprintf("%d\n", i);
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
	unlock_kernel();
}
void
i386_init(void)
{
	extern char edata[], end[];
	
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();

//<<<<<<< HEAD
	cprintf("6828 decimal is %o octal!\n", 6828);
//=======
	/*cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
	//cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
	cprintf("%n", NULL);
	memset(ntest, 0xd, sizeof(ntest) - 1);
	cprintf("%s%n", ntest, &chnum1); 
	cprintf("chnum1: %d\n", chnum1);
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
	*/
//>>>>>>> lab2

	// Lab 2 memory management initialization functions
	mem_init();
	//cprintf("1\n");
	// Lab 3 user environment initialization functions
	env_init();
	//cprintf("2\n");
	trap_init();
//<<<<<<< HEAD

	// Lab 4 multiprocessor initialization functions
	mp_init();
	lapic_init();

	// Lab 4 multitasking initialization functions
	pic_init();

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	/*stone's solution for lab4-A*/
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

#ifdef USE_TICKET_SPIN_LOCK
	unlock_kernel();
	spinlock_test();
	lock_kernel();
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

//<<<<<<< HEAD
	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);

//=======
//======
	//cprintf("3\n");
//>>>>>>> lab3
	//cprintf("start test\n");
//>>>>>>> lab4
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
//<<<<<<< HEAD
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
	// ENV_CREATE(user_writemotd, ENV_TYPE_USER);
	// ENV_CREATE(user_testfile, ENV_TYPE_USER);
	// ENV_CREATE(user_icode, ENV_TYPE_USER);
//=======
	// Touch all you want
	/*stone's solution for lab4*/
	/*stone: if you want to test Round-Robin Schedule, PLZ remove the comment below*/
	//ENV_CREATE(user_idle, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//cprintf("create done!\n");
	/*stone: if you want to test sfork() for challenge, PLZ remove the comment below*/
	ENV_CREATE(user_sforkcheck, ENV_TYPE_USER);
	ENV_CREATE(user_sforktree, ENV_TYPE_USER);
//>>>>>>> lab4
#endif // TEST*

//<<<<<<< HEAD
	// Schedule and run the first user environment!
	//cprintf("start schedule!\n");	
	sched_yield();
}

// While boot_aps is booting a given CPU, it communicates the per-core
// stack pointer that should be loaded by mpentry.S to that CPU in
// this variable.
void *mpentry_kstack;

// Start the non-boot (AP) processors.
static void
boot_aps(void)
{
	extern unsigned char mpentry_start[], mpentry_end[];
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
			;
	}
//=======
	// We only have one user environment for now, so just run it.
	//cprintf("4\n");
	//env_run(&envs[0]);
//>>>>>>> lab3
}

// Setup code for APs
void
mp_main(void)
{
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
	cprintf("SMP: CPU %d starting\n", cpunum());

	lapic_init();
	env_init_percpu();
	trap_init_percpu();
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up

#ifdef USE_TICKET_SPIN_LOCK
	spinlock_test();
#endif

	// Now that we have finished some basic setup, call sched_yield()
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	/*stone's solution for lab4-A*/
	lock_kernel();
	sched_yield();
	// Remove this after you finish Exercise 4
	for (;;);
}

/*
 * Variable panicstr contains argument to first call to panic; used as flag
 * to indicate that the kernel has already called panic.
 */
const char *panicstr;

/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
	va_list ap;

	if (panicstr)
		goto dead;
	panicstr = fmt;

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
	vcprintf(fmt, ap);
	cprintf("\n");
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
	vcprintf(fmt, ap);
	cprintf("\n");
	va_end(ap);
}
