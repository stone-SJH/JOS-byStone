
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 39 01 00 00       	call   f0100177 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 00 5a 10 f0 	movl   $0xf0105a00,(%esp)
f010005f:	e8 d3 31 00 00       	call   f0103237 <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 91 31 00 00       	call   f0103204 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 28 5b 10 f0 	movl   $0xf0105b28,(%esp)
f010007a:	e8 b8 31 00 00       	call   f0103237 <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d a0 3e 23 f0 00 	cmpl   $0x0,0xf0233ea0
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 a0 3e 23 f0    	mov    %esi,0xf0233ea0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000a4:	e8 35 52 00 00       	call   f01052de <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 58 5a 10 f0 	movl   $0xf0105a58,(%esp)
f01000c2:	e8 70 31 00 00       	call   f0103237 <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 31 31 00 00       	call   f0103204 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 28 5b 10 f0 	movl   $0xf0105b28,(%esp)
f01000da:	e8 58 31 00 00       	call   f0103237 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 4f 0a 00 00       	call   f0100b3a <monitor>
f01000eb:	eb f2                	jmp    f01000df <_panic+0x5a>

f01000ed <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000ed:	55                   	push   %ebp
f01000ee:	89 e5                	mov    %esp,%ebp
f01000f0:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000f3:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	89 c2                	mov    %eax,%edx
f01000fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000ff:	77 20                	ja     f0100121 <mp_main+0x34>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100101:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100105:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 1a 5a 10 f0 	movl   $0xf0105a1a,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 af 51 00 00       	call   f01052de <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 26 5a 10 f0 	movl   $0xf0105a26,(%esp)
f010013a:	e8 f8 30 00 00       	call   f0103237 <cprintf>

	lapic_init();
f010013f:	e8 b6 51 00 00       	call   f01052fa <lapic_init>
	env_init_percpu();
f0100144:	e8 77 26 00 00       	call   f01027c0 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 22 31 00 00       	call   f0103270 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 89 51 00 00       	call   f01052de <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 40 23 f0    	add    $0xf0234024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010015e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100163:	f0 87 02             	lock xchg %eax,(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100166:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f010016d:	e8 33 55 00 00       	call   f01056a5 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	/*stone's solution for lab4-A*/
	lock_kernel();
	sched_yield();
f0100172:	e8 09 3a 00 00       	call   f0103b80 <sched_yield>

f0100177 <i386_init>:
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
	unlock_kernel();
}
void
i386_init(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp
f010017a:	56                   	push   %esi
f010017b:	53                   	push   %ebx
f010017c:	83 ec 10             	sub    $0x10,%esp
	
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010017f:	b8 04 50 27 f0       	mov    $0xf0275004,%eax
f0100184:	2d 27 29 23 f0       	sub    $0xf0232927,%eax
f0100189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100194:	00 
f0100195:	c7 04 24 27 29 23 f0 	movl   $0xf0232927,(%esp)
f010019c:	e8 95 4a 00 00       	call   f0104c36 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a1:	e8 4f 06 00 00       	call   f01007f5 <cons_init>

//<<<<<<< HEAD
	cprintf("6828 decimal is %o octal!\n", 6828);
f01001a6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001ad:	00 
f01001ae:	c7 04 24 3c 5a 10 f0 	movl   $0xf0105a3c,(%esp)
f01001b5:	e8 7d 30 00 00       	call   f0103237 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
	*/
//>>>>>>> lab2

	// Lab 2 memory management initialization functions
	mem_init();
f01001ba:	e8 2d 1b 00 00       	call   f0101cec <mem_init>
	//cprintf("1\n");
	// Lab 3 user environment initialization functions
	env_init();
f01001bf:	e8 ab 2a 00 00       	call   f0102c6f <env_init>
	//cprintf("2\n");
	trap_init();
f01001c4:	e8 4d 31 00 00       	call   f0103316 <trap_init>
//<<<<<<< HEAD

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001c9:	e8 2c 4e 00 00       	call   f0104ffa <mp_init>
	lapic_init();
f01001ce:	66 90                	xchg   %ax,%ax
f01001d0:	e8 25 51 00 00       	call   f01052fa <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001d5:	e8 9b 2f 00 00       	call   f0103175 <pic_init>
f01001da:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01001e1:	e8 bf 54 00 00       	call   f01056a5 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001e6:	83 3d a8 3e 23 f0 07 	cmpl   $0x7,0xf0233ea8
f01001ed:	77 24                	ja     f0100213 <i386_init+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001ef:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001f6:	00 
f01001f7:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01001fe:	f0 
f01001ff:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
f0100206:	00 
f0100207:	c7 04 24 1a 5a 10 f0 	movl   $0xf0105a1a,(%esp)
f010020e:	e8 72 fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100213:	b8 16 4f 10 f0       	mov    $0xf0104f16,%eax
f0100218:	2d 9c 4e 10 f0       	sub    $0xf0104e9c,%eax
f010021d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100221:	c7 44 24 04 9c 4e 10 	movl   $0xf0104e9c,0x4(%esp)
f0100228:	f0 
f0100229:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100230:	e8 60 4a 00 00       	call   f0104c95 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100235:	6b 05 c4 43 23 f0 74 	imul   $0x74,0xf02343c4,%eax
f010023c:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0100241:	3d 20 40 23 f0       	cmp    $0xf0234020,%eax
f0100246:	76 65                	jbe    f01002ad <i386_init+0x136>
f0100248:	be 00 00 00 00       	mov    $0x0,%esi
f010024d:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100252:	e8 87 50 00 00       	call   f01052de <cpunum>
f0100257:	6b c0 74             	imul   $0x74,%eax,%eax
f010025a:	05 20 40 23 f0       	add    $0xf0234020,%eax
f010025f:	39 c3                	cmp    %eax,%ebx
f0100261:	74 34                	je     f0100297 <i386_init+0x120>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100263:	89 f0                	mov    %esi,%eax
f0100265:	c1 f8 02             	sar    $0x2,%eax
f0100268:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010026e:	c1 e0 0f             	shl    $0xf,%eax
f0100271:	8d 80 00 d0 23 f0    	lea    -0xfdc3000(%eax),%eax
f0100277:	a3 a4 3e 23 f0       	mov    %eax,0xf0233ea4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010027c:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100283:	00 
f0100284:	0f b6 03             	movzbl (%ebx),%eax
f0100287:	89 04 24             	mov    %eax,(%esp)
f010028a:	e8 d5 51 00 00       	call   f0105464 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010028f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100292:	83 f8 01             	cmp    $0x1,%eax
f0100295:	75 f8                	jne    f010028f <i386_init+0x118>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100297:	83 c3 74             	add    $0x74,%ebx
f010029a:	83 c6 74             	add    $0x74,%esi
f010029d:	6b 05 c4 43 23 f0 74 	imul   $0x74,0xf02343c4,%eax
f01002a4:	05 20 40 23 f0       	add    $0xf0234020,%eax
f01002a9:	39 c3                	cmp    %eax,%ebx
f01002ab:	72 a5                	jb     f0100252 <i386_init+0xdb>
f01002ad:	bb 00 00 00 00       	mov    $0x0,%ebx
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01002b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01002b9:	00 
f01002ba:	c7 44 24 04 6b 89 00 	movl   $0x896b,0x4(%esp)
f01002c1:	00 
f01002c2:	c7 04 24 1e 02 1a f0 	movl   $0xf01a021e,(%esp)
f01002c9:	e8 a5 2c 00 00       	call   f0102f73 <env_create>
	lock_kernel();
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01002ce:	83 c3 01             	add    $0x1,%ebx
f01002d1:	83 fb 08             	cmp    $0x8,%ebx
f01002d4:	75 dc                	jne    f01002b2 <i386_init+0x13b>
	//ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

//<<<<<<< HEAD
	// Schedule and run the first user environment!
	sched_yield();
f01002d6:	e8 a5 38 00 00       	call   f0103b80 <sched_yield>

f01002db <spinlock_test>:
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f01002db:	55                   	push   %ebp
f01002dc:	89 e5                	mov    %esp,%ebp
f01002de:	56                   	push   %esi
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 20             	sub    $0x20,%esp
	int i;
	volatile int interval = 0;
f01002e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	//cprintf("spinlock_test:\n");
	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
f01002ea:	e8 ef 4f 00 00       	call   f01052de <cpunum>
f01002ef:	85 c0                	test   %eax,%eax
f01002f1:	75 10                	jne    f0100303 <spinlock_test+0x28>
		while (interval++ < 10000)
f01002f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01002f6:	8d 50 01             	lea    0x1(%eax),%edx
f01002f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01002fc:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100301:	7e 0c                	jle    f010030f <spinlock_test+0x34>
f0100303:	bb 00 00 00 00       	mov    $0x0,%ebx
			asm volatile("pause");
	}
	//cprintf("done\n");
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f0100308:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f010030d:	eb 14                	jmp    f0100323 <spinlock_test+0x48>
	volatile int interval = 0;
	//cprintf("spinlock_test:\n");
	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
f010030f:	f3 90                	pause  
	int i;
	volatile int interval = 0;
	//cprintf("spinlock_test:\n");
	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
f0100311:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100314:	8d 50 01             	lea    0x1(%eax),%edx
f0100317:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010031a:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010031f:	7e ee                	jle    f010030f <spinlock_test+0x34>
f0100321:	eb e0                	jmp    f0100303 <spinlock_test+0x28>
f0100323:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f010032a:	e8 76 53 00 00       	call   f01056a5 <spin_lock>
			asm volatile("pause");
	}
	//cprintf("done\n");
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f010032f:	8b 0d 00 30 23 f0    	mov    0xf0233000,%ecx
f0100335:	89 c8                	mov    %ecx,%eax
f0100337:	f7 ee                	imul   %esi
f0100339:	c1 fa 0c             	sar    $0xc,%edx
f010033c:	89 c8                	mov    %ecx,%eax
f010033e:	c1 f8 1f             	sar    $0x1f,%eax
f0100341:	29 c2                	sub    %eax,%edx
f0100343:	69 d2 10 27 00 00    	imul   $0x2710,%edx,%edx
f0100349:	39 d1                	cmp    %edx,%ecx
f010034b:	74 1c                	je     f0100369 <spinlock_test+0x8e>
			panic("ticket spinlock test fail: I saw a middle value\n");
f010034d:	c7 44 24 08 c4 5a 10 	movl   $0xf0105ac4,0x8(%esp)
f0100354:	f0 
f0100355:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
f010035c:	00 
f010035d:	c7 04 24 1a 5a 10 f0 	movl   $0xf0105a1a,(%esp)
f0100364:	e8 1c fd ff ff       	call   f0100085 <_panic>
		interval = 0;
f0100369:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (interval++ < 10000)
f0100370:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100373:	8d 50 01             	lea    0x1(%eax),%edx
f0100376:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100379:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010037e:	7f 1d                	jg     f010039d <spinlock_test+0xc2>
			test_ctr++;
f0100380:	a1 00 30 23 f0       	mov    0xf0233000,%eax
f0100385:	83 c0 01             	add    $0x1,%eax
f0100388:	a3 00 30 23 f0       	mov    %eax,0xf0233000
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
f010038d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100390:	8d 50 01             	lea    0x1(%eax),%edx
f0100393:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100396:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010039b:	7e e3                	jle    f0100380 <spinlock_test+0xa5>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010039d:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01003a4:	e8 e3 51 00 00       	call   f010558c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01003a9:	f3 90                	pause  
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}
	//cprintf("done\n");
	for (i=0; i<100; i++) {
f01003ab:	83 c3 01             	add    $0x1,%ebx
f01003ae:	83 fb 64             	cmp    $0x64,%ebx
f01003b1:	0f 85 6c ff ff ff    	jne    f0100323 <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01003b7:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01003be:	e8 e2 52 00 00       	call   f01056a5 <spin_lock>
			test_ctr++;
		//cprintf("%d\n", i);
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f01003c3:	e8 16 4f 00 00       	call   f01052de <cpunum>
f01003c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01003cc:	c7 04 24 f8 5a 10 f0 	movl   $0xf0105af8,(%esp)
f01003d3:	e8 5f 2e 00 00       	call   f0103237 <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01003d8:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01003df:	e8 a8 51 00 00       	call   f010558c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01003e4:	f3 90                	pause  
	unlock_kernel();
}
f01003e6:	83 c4 20             	add    $0x20,%esp
f01003e9:	5b                   	pop    %ebx
f01003ea:	5e                   	pop    %esi
f01003eb:	5d                   	pop    %ebp
f01003ec:	c3                   	ret    
f01003ed:	00 00                	add    %al,(%eax)
	...

f01003f0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01003f0:	55                   	push   %ebp
f01003f1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f3:	ba 84 00 00 00       	mov    $0x84,%edx
f01003f8:	ec                   	in     (%dx),%al
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01003fc:	5d                   	pop    %ebp
f01003fd:	c3                   	ret    

f01003fe <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003fe:	55                   	push   %ebp
f01003ff:	89 e5                	mov    %esp,%ebp
f0100401:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100406:	ec                   	in     (%dx),%al
f0100407:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010040e:	f6 c2 01             	test   $0x1,%dl
f0100411:	74 09                	je     f010041c <serial_proc_data+0x1e>
f0100413:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100418:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100419:	0f b6 c0             	movzbl %al,%eax
}
f010041c:	5d                   	pop    %ebp
f010041d:	c3                   	ret    

f010041e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010041e:	55                   	push   %ebp
f010041f:	89 e5                	mov    %esp,%ebp
f0100421:	57                   	push   %edi
f0100422:	56                   	push   %esi
f0100423:	53                   	push   %ebx
f0100424:	83 ec 0c             	sub    $0xc,%esp
f0100427:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100429:	bb 44 32 23 f0       	mov    $0xf0233244,%ebx
f010042e:	bf 40 30 23 f0       	mov    $0xf0233040,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100433:	eb 1e                	jmp    f0100453 <cons_intr+0x35>
		if (c == 0)
f0100435:	85 c0                	test   %eax,%eax
f0100437:	74 1a                	je     f0100453 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100439:	8b 13                	mov    (%ebx),%edx
f010043b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010043e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100441:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100446:	0f 94 c2             	sete   %dl
f0100449:	0f b6 d2             	movzbl %dl,%edx
f010044c:	83 ea 01             	sub    $0x1,%edx
f010044f:	21 d0                	and    %edx,%eax
f0100451:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100453:	ff d6                	call   *%esi
f0100455:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100458:	75 db                	jne    f0100435 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010045a:	83 c4 0c             	add    $0xc,%esp
f010045d:	5b                   	pop    %ebx
f010045e:	5e                   	pop    %esi
f010045f:	5f                   	pop    %edi
f0100460:	5d                   	pop    %ebp
f0100461:	c3                   	ret    

f0100462 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100462:	55                   	push   %ebp
f0100463:	89 e5                	mov    %esp,%ebp
f0100465:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100468:	b8 fa 06 10 f0       	mov    $0xf01006fa,%eax
f010046d:	e8 ac ff ff ff       	call   f010041e <cons_intr>
}
f0100472:	c9                   	leave  
f0100473:	c3                   	ret    

f0100474 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100474:	55                   	push   %ebp
f0100475:	89 e5                	mov    %esp,%ebp
f0100477:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010047a:	83 3d 24 30 23 f0 00 	cmpl   $0x0,0xf0233024
f0100481:	74 0a                	je     f010048d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100483:	b8 fe 03 10 f0       	mov    $0xf01003fe,%eax
f0100488:	e8 91 ff ff ff       	call   f010041e <cons_intr>
}
f010048d:	c9                   	leave  
f010048e:	c3                   	ret    

f010048f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010048f:	55                   	push   %ebp
f0100490:	89 e5                	mov    %esp,%ebp
f0100492:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100495:	e8 da ff ff ff       	call   f0100474 <serial_intr>
	kbd_intr();
f010049a:	e8 c3 ff ff ff       	call   f0100462 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010049f:	8b 15 40 32 23 f0    	mov    0xf0233240,%edx
f01004a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01004aa:	3b 15 44 32 23 f0    	cmp    0xf0233244,%edx
f01004b0:	74 21                	je     f01004d3 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01004b2:	0f b6 82 40 30 23 f0 	movzbl -0xfdccfc0(%edx),%eax
f01004b9:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01004bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01004c2:	0f 94 c1             	sete   %cl
f01004c5:	0f b6 c9             	movzbl %cl,%ecx
f01004c8:	83 e9 01             	sub    $0x1,%ecx
f01004cb:	21 ca                	and    %ecx,%edx
f01004cd:	89 15 40 32 23 f0    	mov    %edx,0xf0233240
		return c;
	}
	return 0;
}
f01004d3:	c9                   	leave  
f01004d4:	c3                   	ret    

f01004d5 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01004d5:	55                   	push   %ebp
f01004d6:	89 e5                	mov    %esp,%ebp
f01004d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01004db:	e8 af ff ff ff       	call   f010048f <cons_getc>
f01004e0:	85 c0                	test   %eax,%eax
f01004e2:	74 f7                	je     f01004db <getchar+0x6>
		/* do nothing */;
	return c;
}
f01004e4:	c9                   	leave  
f01004e5:	c3                   	ret    

f01004e6 <iscons>:

int
iscons(int fdnum)
{
f01004e6:	55                   	push   %ebp
f01004e7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01004e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01004ee:	5d                   	pop    %ebp
f01004ef:	c3                   	ret    

f01004f0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004f0:	55                   	push   %ebp
f01004f1:	89 e5                	mov    %esp,%ebp
f01004f3:	57                   	push   %edi
f01004f4:	56                   	push   %esi
f01004f5:	53                   	push   %ebx
f01004f6:	83 ec 2c             	sub    $0x2c,%esp
f01004f9:	89 c7                	mov    %eax,%edi
f01004fb:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100500:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100501:	a8 20                	test   $0x20,%al
f0100503:	75 21                	jne    f0100526 <cons_putc+0x36>
f0100505:	bb 00 00 00 00       	mov    $0x0,%ebx
f010050a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010050f:	e8 dc fe ff ff       	call   f01003f0 <delay>
f0100514:	89 f2                	mov    %esi,%edx
f0100516:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100517:	a8 20                	test   $0x20,%al
f0100519:	75 0b                	jne    f0100526 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010051b:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010051e:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100524:	75 e9                	jne    f010050f <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100526:	89 fa                	mov    %edi,%edx
f0100528:	89 f8                	mov    %edi,%eax
f010052a:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010052d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100532:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100533:	b2 79                	mov    $0x79,%dl
f0100535:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100536:	84 c0                	test   %al,%al
f0100538:	78 21                	js     f010055b <cons_putc+0x6b>
f010053a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010053f:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100544:	e8 a7 fe ff ff       	call   f01003f0 <delay>
f0100549:	89 f2                	mov    %esi,%edx
f010054b:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010054c:	84 c0                	test   %al,%al
f010054e:	78 0b                	js     f010055b <cons_putc+0x6b>
f0100550:	83 c3 01             	add    $0x1,%ebx
f0100553:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100559:	75 e9                	jne    f0100544 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100560:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100564:	ee                   	out    %al,(%dx)
f0100565:	b2 7a                	mov    $0x7a,%dl
f0100567:	b8 0d 00 00 00       	mov    $0xd,%eax
f010056c:	ee                   	out    %al,(%dx)
f010056d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100572:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100573:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100579:	75 06                	jne    f0100581 <cons_putc+0x91>
		c |= 0x0700;
f010057b:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100581:	89 f8                	mov    %edi,%eax
f0100583:	25 ff 00 00 00       	and    $0xff,%eax
f0100588:	83 f8 09             	cmp    $0x9,%eax
f010058b:	0f 84 83 00 00 00    	je     f0100614 <cons_putc+0x124>
f0100591:	83 f8 09             	cmp    $0x9,%eax
f0100594:	7f 0c                	jg     f01005a2 <cons_putc+0xb2>
f0100596:	83 f8 08             	cmp    $0x8,%eax
f0100599:	0f 85 a9 00 00 00    	jne    f0100648 <cons_putc+0x158>
f010059f:	90                   	nop
f01005a0:	eb 18                	jmp    f01005ba <cons_putc+0xca>
f01005a2:	83 f8 0a             	cmp    $0xa,%eax
f01005a5:	8d 76 00             	lea    0x0(%esi),%esi
f01005a8:	74 40                	je     f01005ea <cons_putc+0xfa>
f01005aa:	83 f8 0d             	cmp    $0xd,%eax
f01005ad:	8d 76 00             	lea    0x0(%esi),%esi
f01005b0:	0f 85 92 00 00 00    	jne    f0100648 <cons_putc+0x158>
f01005b6:	66 90                	xchg   %ax,%ax
f01005b8:	eb 38                	jmp    f01005f2 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f01005ba:	0f b7 05 30 30 23 f0 	movzwl 0xf0233030,%eax
f01005c1:	66 85 c0             	test   %ax,%ax
f01005c4:	0f 84 e8 00 00 00    	je     f01006b2 <cons_putc+0x1c2>
			crt_pos--;
f01005ca:	83 e8 01             	sub    $0x1,%eax
f01005cd:	66 a3 30 30 23 f0    	mov    %ax,0xf0233030
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005d3:	0f b7 c0             	movzwl %ax,%eax
f01005d6:	66 81 e7 00 ff       	and    $0xff00,%di
f01005db:	83 cf 20             	or     $0x20,%edi
f01005de:	8b 15 2c 30 23 f0    	mov    0xf023302c,%edx
f01005e4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005e8:	eb 7b                	jmp    f0100665 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01005ea:	66 83 05 30 30 23 f0 	addw   $0x50,0xf0233030
f01005f1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01005f2:	0f b7 05 30 30 23 f0 	movzwl 0xf0233030,%eax
f01005f9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01005ff:	c1 e8 10             	shr    $0x10,%eax
f0100602:	66 c1 e8 06          	shr    $0x6,%ax
f0100606:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100609:	c1 e0 04             	shl    $0x4,%eax
f010060c:	66 a3 30 30 23 f0    	mov    %ax,0xf0233030
f0100612:	eb 51                	jmp    f0100665 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100614:	b8 20 00 00 00       	mov    $0x20,%eax
f0100619:	e8 d2 fe ff ff       	call   f01004f0 <cons_putc>
		cons_putc(' ');
f010061e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100623:	e8 c8 fe ff ff       	call   f01004f0 <cons_putc>
		cons_putc(' ');
f0100628:	b8 20 00 00 00       	mov    $0x20,%eax
f010062d:	e8 be fe ff ff       	call   f01004f0 <cons_putc>
		cons_putc(' ');
f0100632:	b8 20 00 00 00       	mov    $0x20,%eax
f0100637:	e8 b4 fe ff ff       	call   f01004f0 <cons_putc>
		cons_putc(' ');
f010063c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100641:	e8 aa fe ff ff       	call   f01004f0 <cons_putc>
f0100646:	eb 1d                	jmp    f0100665 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100648:	0f b7 05 30 30 23 f0 	movzwl 0xf0233030,%eax
f010064f:	0f b7 c8             	movzwl %ax,%ecx
f0100652:	8b 15 2c 30 23 f0    	mov    0xf023302c,%edx
f0100658:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010065c:	83 c0 01             	add    $0x1,%eax
f010065f:	66 a3 30 30 23 f0    	mov    %ax,0xf0233030
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100665:	66 81 3d 30 30 23 f0 	cmpw   $0x7cf,0xf0233030
f010066c:	cf 07 
f010066e:	76 42                	jbe    f01006b2 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100670:	a1 2c 30 23 f0       	mov    0xf023302c,%eax
f0100675:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010067c:	00 
f010067d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100683:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100687:	89 04 24             	mov    %eax,(%esp)
f010068a:	e8 06 46 00 00       	call   f0104c95 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010068f:	8b 15 2c 30 23 f0    	mov    0xf023302c,%edx
f0100695:	b8 80 07 00 00       	mov    $0x780,%eax
f010069a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006a0:	83 c0 01             	add    $0x1,%eax
f01006a3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006a8:	75 f0                	jne    f010069a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006aa:	66 83 2d 30 30 23 f0 	subw   $0x50,0xf0233030
f01006b1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006b2:	8b 0d 28 30 23 f0    	mov    0xf0233028,%ecx
f01006b8:	89 cb                	mov    %ecx,%ebx
f01006ba:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006bf:	89 ca                	mov    %ecx,%edx
f01006c1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006c2:	0f b7 35 30 30 23 f0 	movzwl 0xf0233030,%esi
f01006c9:	83 c1 01             	add    $0x1,%ecx
f01006cc:	89 f0                	mov    %esi,%eax
f01006ce:	66 c1 e8 08          	shr    $0x8,%ax
f01006d2:	89 ca                	mov    %ecx,%edx
f01006d4:	ee                   	out    %al,(%dx)
f01006d5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006da:	89 da                	mov    %ebx,%edx
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	89 f0                	mov    %esi,%eax
f01006df:	89 ca                	mov    %ecx,%edx
f01006e1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01006e2:	83 c4 2c             	add    $0x2c,%esp
f01006e5:	5b                   	pop    %ebx
f01006e6:	5e                   	pop    %esi
f01006e7:	5f                   	pop    %edi
f01006e8:	5d                   	pop    %ebp
f01006e9:	c3                   	ret    

f01006ea <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006ea:	55                   	push   %ebp
f01006eb:	89 e5                	mov    %esp,%ebp
f01006ed:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01006f3:	e8 f8 fd ff ff       	call   f01004f0 <cons_putc>
}
f01006f8:	c9                   	leave  
f01006f9:	c3                   	ret    

f01006fa <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01006fa:	55                   	push   %ebp
f01006fb:	89 e5                	mov    %esp,%ebp
f01006fd:	53                   	push   %ebx
f01006fe:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100701:	ba 64 00 00 00       	mov    $0x64,%edx
f0100706:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100707:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010070c:	a8 01                	test   $0x1,%al
f010070e:	0f 84 d9 00 00 00    	je     f01007ed <kbd_proc_data+0xf3>
f0100714:	b2 60                	mov    $0x60,%dl
f0100716:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100717:	3c e0                	cmp    $0xe0,%al
f0100719:	75 11                	jne    f010072c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010071b:	83 0d 20 30 23 f0 40 	orl    $0x40,0xf0233020
f0100722:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100727:	e9 c1 00 00 00       	jmp    f01007ed <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010072c:	84 c0                	test   %al,%al
f010072e:	79 32                	jns    f0100762 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100730:	8b 15 20 30 23 f0    	mov    0xf0233020,%edx
f0100736:	f6 c2 40             	test   $0x40,%dl
f0100739:	75 03                	jne    f010073e <kbd_proc_data+0x44>
f010073b:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010073e:	0f b6 c0             	movzbl %al,%eax
f0100741:	0f b6 80 60 5b 10 f0 	movzbl -0xfefa4a0(%eax),%eax
f0100748:	83 c8 40             	or     $0x40,%eax
f010074b:	0f b6 c0             	movzbl %al,%eax
f010074e:	f7 d0                	not    %eax
f0100750:	21 c2                	and    %eax,%edx
f0100752:	89 15 20 30 23 f0    	mov    %edx,0xf0233020
f0100758:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010075d:	e9 8b 00 00 00       	jmp    f01007ed <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100762:	8b 15 20 30 23 f0    	mov    0xf0233020,%edx
f0100768:	f6 c2 40             	test   $0x40,%dl
f010076b:	74 0c                	je     f0100779 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010076d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100770:	83 e2 bf             	and    $0xffffffbf,%edx
f0100773:	89 15 20 30 23 f0    	mov    %edx,0xf0233020
	}

	shift |= shiftcode[data];
f0100779:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010077c:	0f b6 90 60 5b 10 f0 	movzbl -0xfefa4a0(%eax),%edx
f0100783:	0b 15 20 30 23 f0    	or     0xf0233020,%edx
f0100789:	0f b6 88 60 5c 10 f0 	movzbl -0xfefa3a0(%eax),%ecx
f0100790:	31 ca                	xor    %ecx,%edx
f0100792:	89 15 20 30 23 f0    	mov    %edx,0xf0233020

	c = charcode[shift & (CTL | SHIFT)][data];
f0100798:	89 d1                	mov    %edx,%ecx
f010079a:	83 e1 03             	and    $0x3,%ecx
f010079d:	8b 0c 8d 60 5d 10 f0 	mov    -0xfefa2a0(,%ecx,4),%ecx
f01007a4:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01007a8:	f6 c2 08             	test   $0x8,%dl
f01007ab:	74 1a                	je     f01007c7 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f01007ad:	89 d9                	mov    %ebx,%ecx
f01007af:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01007b2:	83 f8 19             	cmp    $0x19,%eax
f01007b5:	77 05                	ja     f01007bc <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f01007b7:	83 eb 20             	sub    $0x20,%ebx
f01007ba:	eb 0b                	jmp    f01007c7 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01007bc:	83 e9 41             	sub    $0x41,%ecx
f01007bf:	83 f9 19             	cmp    $0x19,%ecx
f01007c2:	77 03                	ja     f01007c7 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f01007c4:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01007c7:	f7 d2                	not    %edx
f01007c9:	f6 c2 06             	test   $0x6,%dl
f01007cc:	75 1f                	jne    f01007ed <kbd_proc_data+0xf3>
f01007ce:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01007d4:	75 17                	jne    f01007ed <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f01007d6:	c7 04 24 1e 5b 10 f0 	movl   $0xf0105b1e,(%esp)
f01007dd:	e8 55 2a 00 00       	call   f0103237 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007e2:	ba 92 00 00 00       	mov    $0x92,%edx
f01007e7:	b8 03 00 00 00       	mov    $0x3,%eax
f01007ec:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01007ed:	89 d8                	mov    %ebx,%eax
f01007ef:	83 c4 14             	add    $0x14,%esp
f01007f2:	5b                   	pop    %ebx
f01007f3:	5d                   	pop    %ebp
f01007f4:	c3                   	ret    

f01007f5 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
f01007f8:	57                   	push   %edi
f01007f9:	56                   	push   %esi
f01007fa:	53                   	push   %ebx
f01007fb:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01007fe:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100803:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100806:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010080b:	0f b7 00             	movzwl (%eax),%eax
f010080e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100812:	74 11                	je     f0100825 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100814:	c7 05 28 30 23 f0 b4 	movl   $0x3b4,0xf0233028
f010081b:	03 00 00 
f010081e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100823:	eb 16                	jmp    f010083b <cons_init+0x46>
	} else {
		*cp = was;
f0100825:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010082c:	c7 05 28 30 23 f0 d4 	movl   $0x3d4,0xf0233028
f0100833:	03 00 00 
f0100836:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010083b:	8b 0d 28 30 23 f0    	mov    0xf0233028,%ecx
f0100841:	89 cb                	mov    %ecx,%ebx
f0100843:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100848:	89 ca                	mov    %ecx,%edx
f010084a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010084b:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010084e:	89 ca                	mov    %ecx,%edx
f0100850:	ec                   	in     (%dx),%al
f0100851:	0f b6 f8             	movzbl %al,%edi
f0100854:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100857:	b8 0f 00 00 00       	mov    $0xf,%eax
f010085c:	89 da                	mov    %ebx,%edx
f010085e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010085f:	89 ca                	mov    %ecx,%edx
f0100861:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100862:	89 35 2c 30 23 f0    	mov    %esi,0xf023302c
	crt_pos = pos;
f0100868:	0f b6 c8             	movzbl %al,%ecx
f010086b:	09 cf                	or     %ecx,%edi
f010086d:	66 89 3d 30 30 23 f0 	mov    %di,0xf0233030

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100874:	e8 e9 fb ff ff       	call   f0100462 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100879:	0f b7 05 70 f3 11 f0 	movzwl 0xf011f370,%eax
f0100880:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100885:	89 04 24             	mov    %eax,(%esp)
f0100888:	e8 77 28 00 00       	call   f0103104 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010088d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100892:	b8 00 00 00 00       	mov    $0x0,%eax
f0100897:	89 da                	mov    %ebx,%edx
f0100899:	ee                   	out    %al,(%dx)
f010089a:	b2 fb                	mov    $0xfb,%dl
f010089c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01008a1:	ee                   	out    %al,(%dx)
f01008a2:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01008a7:	b8 0c 00 00 00       	mov    $0xc,%eax
f01008ac:	89 ca                	mov    %ecx,%edx
f01008ae:	ee                   	out    %al,(%dx)
f01008af:	b2 f9                	mov    $0xf9,%dl
f01008b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b6:	ee                   	out    %al,(%dx)
f01008b7:	b2 fb                	mov    $0xfb,%dl
f01008b9:	b8 03 00 00 00       	mov    $0x3,%eax
f01008be:	ee                   	out    %al,(%dx)
f01008bf:	b2 fc                	mov    $0xfc,%dl
f01008c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c6:	ee                   	out    %al,(%dx)
f01008c7:	b2 f9                	mov    $0xf9,%dl
f01008c9:	b8 01 00 00 00       	mov    $0x1,%eax
f01008ce:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008cf:	b2 fd                	mov    $0xfd,%dl
f01008d1:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01008d2:	3c ff                	cmp    $0xff,%al
f01008d4:	0f 95 c0             	setne  %al
f01008d7:	0f b6 f0             	movzbl %al,%esi
f01008da:	89 35 24 30 23 f0    	mov    %esi,0xf0233024
f01008e0:	89 da                	mov    %ebx,%edx
f01008e2:	ec                   	in     (%dx),%al
f01008e3:	89 ca                	mov    %ecx,%edx
f01008e5:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008e6:	85 f6                	test   %esi,%esi
f01008e8:	75 0c                	jne    f01008f6 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f01008ea:	c7 04 24 2a 5b 10 f0 	movl   $0xf0105b2a,(%esp)
f01008f1:	e8 41 29 00 00       	call   f0103237 <cprintf>
}
f01008f6:	83 c4 1c             	add    $0x1c,%esp
f01008f9:	5b                   	pop    %ebx
f01008fa:	5e                   	pop    %esi
f01008fb:	5f                   	pop    %edi
f01008fc:	5d                   	pop    %ebp
f01008fd:	c3                   	ret    
	...

f0100900 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100900:	55                   	push   %ebp
f0100901:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100903:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100906:	5d                   	pop    %ebp
f0100907:	c3                   	ret    

f0100908 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100908:	55                   	push   %ebp
f0100909:	89 e5                	mov    %esp,%ebp
f010090b:	57                   	push   %edi
f010090c:	56                   	push   %esi
f010090d:	53                   	push   %ebx
f010090e:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f0100914:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f010091a:	b9 40 00 00 00       	mov    $0x40,%ecx
f010091f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100924:	f3 ab                	rep stos %eax,%es:(%edi)
    int nstr = 0;
    char *pret_addr;

	// Your code here.
    	/* stone's solution for exercise16 */
	pret_addr = (char *)read_pretaddr();
f0100926:	8d 75 04             	lea    0x4(%ebp),%esi
	uint32_t targ_addr = (uint32_t)do_overflow + 3;//reserve the stack.
f0100929:	bf 31 0a 10 f0       	mov    $0xf0100a31,%edi
	int i;
	for( i = 0; i < 256; i++)
		str[i] = '1';
f010092e:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
f0100934:	c6 04 02 31          	movb   $0x31,(%edx,%eax,1)
	// Your code here.
    	/* stone's solution for exercise16 */
	pret_addr = (char *)read_pretaddr();
	uint32_t targ_addr = (uint32_t)do_overflow + 3;//reserve the stack.
	int i;
	for( i = 0; i < 256; i++)
f0100938:	83 c0 01             	add    $0x1,%eax
f010093b:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100940:	75 f2                	jne    f0100934 <start_overflow+0x2c>
		str[i] = '1';
	uint32_t targ_frag1 = targ_addr & 0xFF;
f0100942:	89 f8                	mov    %edi,%eax
f0100944:	25 ff 00 00 00       	and    $0xff,%eax
f0100949:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag1] = '\0';
f010094f:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100956:	00 
	cprintf("%s%n", str, pret_addr);
f0100957:	89 74 24 08          	mov    %esi,0x8(%esp)
f010095b:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100965:	c7 04 24 70 5d 10 f0 	movl   $0xf0105d70,(%esp)
f010096c:	e8 c6 28 00 00       	call   f0103237 <cprintf>
	str[targ_frag1] = '1';
f0100971:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f0100977:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f010097e:	31 

	uint32_t targ_frag2 = (targ_addr>>8) & 0xFF;
f010097f:	89 f8                	mov    %edi,%eax
f0100981:	0f b6 c4             	movzbl %ah,%eax
f0100984:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag2] = '\0';
f010098a:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100991:	00 
	cprintf("%s%n", str, pret_addr+1);
f0100992:	8d 46 01             	lea    0x1(%esi),%eax
f0100995:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100999:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010099d:	c7 04 24 70 5d 10 f0 	movl   $0xf0105d70,(%esp)
f01009a4:	e8 8e 28 00 00       	call   f0103237 <cprintf>
	str[targ_frag2] = '1';
f01009a9:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f01009af:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f01009b6:	31 

	uint32_t targ_frag3 = (targ_addr>>16) & 0xFF;
f01009b7:	89 f8                	mov    %edi,%eax
f01009b9:	c1 e8 10             	shr    $0x10,%eax
f01009bc:	25 ff 00 00 00       	and    $0xff,%eax
f01009c1:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag3] = '\0';
f01009c7:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f01009ce:	00 
	cprintf("%s%n", str, pret_addr+2);
f01009cf:	8d 46 02             	lea    0x2(%esi),%eax
f01009d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009da:	c7 04 24 70 5d 10 f0 	movl   $0xf0105d70,(%esp)
f01009e1:	e8 51 28 00 00       	call   f0103237 <cprintf>
	str[targ_frag3] = '1';
f01009e6:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f01009ec:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f01009f3:	31 

	uint32_t targ_frag4 = (targ_addr>>24) & 0xFF;
	str[targ_frag4] = '\0';
f01009f4:	c1 ef 18             	shr    $0x18,%edi
f01009f7:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f01009fe:	00 
	cprintf("%s%n\n", str, pret_addr+3);
f01009ff:	83 c6 03             	add    $0x3,%esi
f0100a02:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100a0a:	c7 04 24 75 5d 10 f0 	movl   $0xf0105d75,(%esp)
f0100a11:	e8 21 28 00 00       	call   f0103237 <cprintf>
	str[targ_frag4] = '1';
}
f0100a16:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f0100a1c:	5b                   	pop    %ebx
f0100a1d:	5e                   	pop    %esi
f0100a1e:	5f                   	pop    %edi
f0100a1f:	5d                   	pop    %ebp
f0100a20:	c3                   	ret    

f0100a21 <overflow_me>:

void
overflow_me(void)
{
f0100a21:	55                   	push   %ebp
f0100a22:	89 e5                	mov    %esp,%ebp
f0100a24:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100a27:	e8 dc fe ff ff       	call   f0100908 <start_overflow>
}
f0100a2c:	c9                   	leave  
f0100a2d:	c3                   	ret    

f0100a2e <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100a2e:	55                   	push   %ebp
f0100a2f:	89 e5                	mov    %esp,%ebp
f0100a31:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100a34:	c7 04 24 7b 5d 10 f0 	movl   $0xf0105d7b,(%esp)
f0100a3b:	e8 f7 27 00 00       	call   f0103237 <cprintf>
}
f0100a40:	c9                   	leave  
f0100a41:	c3                   	ret    

f0100a42 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100a42:	55                   	push   %ebp
f0100a43:	89 e5                	mov    %esp,%ebp
f0100a45:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100a48:	c7 04 24 8d 5d 10 f0 	movl   $0xf0105d8d,(%esp)
f0100a4f:	e8 e3 27 00 00       	call   f0103237 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100a54:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100a5b:	00 
f0100a5c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100a63:	f0 
f0100a64:	c7 04 24 c0 5e 10 f0 	movl   $0xf0105ec0,(%esp)
f0100a6b:	e8 c7 27 00 00       	call   f0103237 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a70:	c7 44 24 08 e5 59 10 	movl   $0x1059e5,0x8(%esp)
f0100a77:	00 
f0100a78:	c7 44 24 04 e5 59 10 	movl   $0xf01059e5,0x4(%esp)
f0100a7f:	f0 
f0100a80:	c7 04 24 e4 5e 10 f0 	movl   $0xf0105ee4,(%esp)
f0100a87:	e8 ab 27 00 00       	call   f0103237 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a8c:	c7 44 24 08 27 29 23 	movl   $0x232927,0x8(%esp)
f0100a93:	00 
f0100a94:	c7 44 24 04 27 29 23 	movl   $0xf0232927,0x4(%esp)
f0100a9b:	f0 
f0100a9c:	c7 04 24 08 5f 10 f0 	movl   $0xf0105f08,(%esp)
f0100aa3:	e8 8f 27 00 00       	call   f0103237 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100aa8:	c7 44 24 08 04 50 27 	movl   $0x275004,0x8(%esp)
f0100aaf:	00 
f0100ab0:	c7 44 24 04 04 50 27 	movl   $0xf0275004,0x4(%esp)
f0100ab7:	f0 
f0100ab8:	c7 04 24 2c 5f 10 f0 	movl   $0xf0105f2c,(%esp)
f0100abf:	e8 73 27 00 00       	call   f0103237 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100ac4:	b8 03 54 27 f0       	mov    $0xf0275403,%eax
f0100ac9:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100ace:	89 c2                	mov    %eax,%edx
f0100ad0:	c1 fa 1f             	sar    $0x1f,%edx
f0100ad3:	c1 ea 16             	shr    $0x16,%edx
f0100ad6:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100ad9:	c1 f8 0a             	sar    $0xa,%eax
f0100adc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae0:	c7 04 24 50 5f 10 f0 	movl   $0xf0105f50,(%esp)
f0100ae7:	e8 4b 27 00 00       	call   f0103237 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100aec:	b8 00 00 00 00       	mov    $0x0,%eax
f0100af1:	c9                   	leave  
f0100af2:	c3                   	ret    

f0100af3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100af3:	55                   	push   %ebp
f0100af4:	89 e5                	mov    %esp,%ebp
f0100af6:	57                   	push   %edi
f0100af7:	56                   	push   %esi
f0100af8:	53                   	push   %ebx
f0100af9:	83 ec 1c             	sub    $0x1c,%esp
f0100afc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100b01:	be e4 60 10 f0       	mov    $0xf01060e4,%esi
f0100b06:	bf e0 60 10 f0       	mov    $0xf01060e0,%edi
f0100b0b:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100b0e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b12:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f0100b15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b19:	c7 04 24 a6 5d 10 f0 	movl   $0xf0105da6,(%esp)
f0100b20:	e8 12 27 00 00       	call   f0103237 <cprintf>
f0100b25:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100b28:	83 fb 54             	cmp    $0x54,%ebx
f0100b2b:	75 de                	jne    f0100b0b <mon_help+0x18>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100b2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b32:	83 c4 1c             	add    $0x1c,%esp
f0100b35:	5b                   	pop    %ebx
f0100b36:	5e                   	pop    %esi
f0100b37:	5f                   	pop    %edi
f0100b38:	5d                   	pop    %ebp
f0100b39:	c3                   	ret    

f0100b3a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b3a:	55                   	push   %ebp
f0100b3b:	89 e5                	mov    %esp,%ebp
f0100b3d:	57                   	push   %edi
f0100b3e:	56                   	push   %esi
f0100b3f:	53                   	push   %ebx
f0100b40:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b43:	c7 04 24 7c 5f 10 f0 	movl   $0xf0105f7c,(%esp)
f0100b4a:	e8 e8 26 00 00       	call   f0103237 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b4f:	c7 04 24 a0 5f 10 f0 	movl   $0xf0105fa0,(%esp)
f0100b56:	e8 dc 26 00 00       	call   f0103237 <cprintf>

	if (tf != NULL)
f0100b5b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b5f:	74 0b                	je     f0100b6c <monitor+0x32>
		print_trapframe(tf);
f0100b61:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b64:	89 04 24             	mov    %eax,(%esp)
f0100b67:	e8 87 2b 00 00       	call   f01036f3 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100b6c:	c7 04 24 af 5d 10 f0 	movl   $0xf0105daf,(%esp)
f0100b73:	e8 08 3e 00 00       	call   f0104980 <readline>
f0100b78:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b7a:	85 c0                	test   %eax,%eax
f0100b7c:	74 ee                	je     f0100b6c <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b7e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100b85:	be 00 00 00 00       	mov    $0x0,%esi
f0100b8a:	eb 06                	jmp    f0100b92 <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b8c:	c6 03 00             	movb   $0x0,(%ebx)
f0100b8f:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b92:	0f b6 03             	movzbl (%ebx),%eax
f0100b95:	84 c0                	test   %al,%al
f0100b97:	74 6c                	je     f0100c05 <monitor+0xcb>
f0100b99:	0f be c0             	movsbl %al,%eax
f0100b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ba0:	c7 04 24 b3 5d 10 f0 	movl   $0xf0105db3,(%esp)
f0100ba7:	e8 2f 40 00 00       	call   f0104bdb <strchr>
f0100bac:	85 c0                	test   %eax,%eax
f0100bae:	75 dc                	jne    f0100b8c <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100bb0:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100bb3:	74 50                	je     f0100c05 <monitor+0xcb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100bb5:	83 fe 0f             	cmp    $0xf,%esi
f0100bb8:	75 16                	jne    f0100bd0 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100bba:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100bc1:	00 
f0100bc2:	c7 04 24 b8 5d 10 f0 	movl   $0xf0105db8,(%esp)
f0100bc9:	e8 69 26 00 00       	call   f0103237 <cprintf>
f0100bce:	eb 9c                	jmp    f0100b6c <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100bd0:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100bd4:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bd7:	0f b6 03             	movzbl (%ebx),%eax
f0100bda:	84 c0                	test   %al,%al
f0100bdc:	75 0e                	jne    f0100bec <monitor+0xb2>
f0100bde:	66 90                	xchg   %ax,%ax
f0100be0:	eb b0                	jmp    f0100b92 <monitor+0x58>
			buf++;
f0100be2:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100be5:	0f b6 03             	movzbl (%ebx),%eax
f0100be8:	84 c0                	test   %al,%al
f0100bea:	74 a6                	je     f0100b92 <monitor+0x58>
f0100bec:	0f be c0             	movsbl %al,%eax
f0100bef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bf3:	c7 04 24 b3 5d 10 f0 	movl   $0xf0105db3,(%esp)
f0100bfa:	e8 dc 3f 00 00       	call   f0104bdb <strchr>
f0100bff:	85 c0                	test   %eax,%eax
f0100c01:	74 df                	je     f0100be2 <monitor+0xa8>
f0100c03:	eb 8d                	jmp    f0100b92 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100c05:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c0c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c0d:	85 f6                	test   %esi,%esi
f0100c0f:	90                   	nop
f0100c10:	0f 84 56 ff ff ff    	je     f0100b6c <monitor+0x32>
f0100c16:	bb e0 60 10 f0       	mov    $0xf01060e0,%ebx
f0100c1b:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c20:	8b 03                	mov    (%ebx),%eax
f0100c22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c26:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c29:	89 04 24             	mov    %eax,(%esp)
f0100c2c:	e8 34 3f 00 00       	call   f0104b65 <strcmp>
f0100c31:	85 c0                	test   %eax,%eax
f0100c33:	75 23                	jne    f0100c58 <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f0100c35:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c38:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c3f:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c46:	89 34 24             	mov    %esi,(%esp)
f0100c49:	ff 97 e8 60 10 f0    	call   *-0xfef9f18(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c4f:	85 c0                	test   %eax,%eax
f0100c51:	78 28                	js     f0100c7b <monitor+0x141>
f0100c53:	e9 14 ff ff ff       	jmp    f0100b6c <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c58:	83 c7 01             	add    $0x1,%edi
f0100c5b:	83 c3 0c             	add    $0xc,%ebx
f0100c5e:	83 ff 07             	cmp    $0x7,%edi
f0100c61:	75 bd                	jne    f0100c20 <monitor+0xe6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c63:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c6a:	c7 04 24 d5 5d 10 f0 	movl   $0xf0105dd5,(%esp)
f0100c71:	e8 c1 25 00 00       	call   f0103237 <cprintf>
f0100c76:	e9 f1 fe ff ff       	jmp    f0100b6c <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c7b:	83 c4 5c             	add    $0x5c,%esp
f0100c7e:	5b                   	pop    %ebx
f0100c7f:	5e                   	pop    %esi
f0100c80:	5f                   	pop    %edi
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    

f0100c83 <mon_time>:
//<<<<<<< HEAD/
//=======
/* stone's solution for exercise17 */
int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
f0100c86:	57                   	push   %edi
f0100c87:	56                   	push   %esi
f0100c88:	53                   	push   %ebx
f0100c89:	83 ec 2c             	sub    $0x2c,%esp
	if (argc == 1){
f0100c8c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100c90:	75 16                	jne    f0100ca8 <mon_time+0x25>
		cprintf("Usage: time [command]\n");
f0100c92:	c7 04 24 eb 5d 10 f0 	movl   $0xf0105deb,(%esp)
f0100c99:	e8 99 25 00 00       	call   f0103237 <cprintf>
f0100c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0100ca3:	e9 96 00 00 00       	jmp    f0100d3e <mon_time+0xbb>
f0100ca8:	bb e0 60 10 f0       	mov    $0xf01060e0,%ebx
f0100cad:	be 00 00 00 00       	mov    $0x0,%esi
	}
	int i;
	for (i = 0; i < NCOMMANDS; i++){
		if (strcmp(commands[i].name, argv[1]) == 0)
f0100cb2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100cb5:	83 c7 04             	add    $0x4,%edi
f0100cb8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100cbb:	8b 07                	mov    (%edi),%eax
f0100cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cc1:	8b 03                	mov    (%ebx),%eax
f0100cc3:	89 04 24             	mov    %eax,(%esp)
f0100cc6:	e8 9a 3e 00 00       	call   f0104b65 <strcmp>
f0100ccb:	85 c0                	test   %eax,%eax
f0100ccd:	74 23                	je     f0100cf2 <mon_time+0x6f>
			break;
		if (i == NCOMMANDS - 1){
f0100ccf:	83 fe 06             	cmp    $0x6,%esi
f0100cd2:	75 13                	jne    f0100ce7 <mon_time+0x64>
			cprintf("Unkown command.\n");
f0100cd4:	c7 04 24 02 5e 10 f0 	movl   $0xf0105e02,(%esp)
f0100cdb:	e8 57 25 00 00       	call   f0103237 <cprintf>
f0100ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			return -1;
f0100ce5:	eb 57                	jmp    f0100d3e <mon_time+0xbb>
	if (argc == 1){
		cprintf("Usage: time [command]\n");
		return -1;
	}
	int i;
	for (i = 0; i < NCOMMANDS; i++){
f0100ce7:	83 c6 01             	add    $0x1,%esi
f0100cea:	83 c3 0c             	add    $0xc,%ebx
f0100ced:	83 fe 07             	cmp    $0x7,%esi
f0100cf0:	75 c6                	jne    f0100cb8 <mon_time+0x35>

static __inline uint64_t
read_tsc(void)
{
        uint64_t tsc;
        __asm __volatile("rdtsc" : "=A" (tsc));
f0100cf2:	0f 31                	rdtsc  
f0100cf4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cf7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			return -1;
		}
	}

	uint32_t begin = read_tsc();
	commands[i].func(argc-1, argv+1, tf);
f0100cfa:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100cfd:	8b 55 10             	mov    0x10(%ebp),%edx
f0100d00:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d07:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d0b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d0e:	83 ea 01             	sub    $0x1,%edx
f0100d11:	89 14 24             	mov    %edx,(%esp)
f0100d14:	ff 14 85 e8 60 10 f0 	call   *-0xfef9f18(,%eax,4)
f0100d1b:	0f 31                	rdtsc  
	uint32_t end = read_tsc();
	cprintf("%s cycles: %llu\n", argv[1], end-begin);
f0100d1d:	2b 45 d8             	sub    -0x28(%ebp),%eax
f0100d20:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d27:	8b 02                	mov    (%edx),%eax
f0100d29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d2d:	c7 04 24 13 5e 10 f0 	movl   $0xf0105e13,(%esp)
f0100d34:	e8 fe 24 00 00       	call   f0103237 <cprintf>
f0100d39:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0; 
}
f0100d3e:	83 c4 2c             	add    $0x2c,%esp
f0100d41:	5b                   	pop    %ebx
f0100d42:	5e                   	pop    %esi
f0100d43:	5f                   	pop    %edi
f0100d44:	5d                   	pop    %ebp
f0100d45:	c3                   	ret    

f0100d46 <mon_backtrace>:
}

//>>>>>>> lab2
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100d46:	55                   	push   %ebp
f0100d47:	89 e5                	mov    %esp,%ebp
f0100d49:	57                   	push   %edi
f0100d4a:	56                   	push   %esi
f0100d4b:	53                   	push   %ebx
f0100d4c:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
//<<<<<<< HEAD
//=======
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
f0100d4f:	89 eb                	mov    %ebp,%ebx
	cprintf("Stack backtrace:\n");
f0100d51:	c7 04 24 24 5e 10 f0 	movl   $0xf0105e24,(%esp)
f0100d58:	e8 da 24 00 00       	call   f0103237 <cprintf>
	while (ebp != 0){
f0100d5d:	85 db                	test   %ebx,%ebx
f0100d5f:	74 7d                	je     f0100dde <mon_backtrace+0x98>
		cprintf(" eip %08x ebp %08x args %08x %08x %08x %08x %08x\n", (uint32_t*)ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100d61:	8d 7d d0             	lea    -0x30(%ebp),%edi
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0){
		cprintf(" eip %08x ebp %08x args %08x %08x %08x %08x %08x\n", (uint32_t*)ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100d64:	8d 73 04             	lea    0x4(%ebx),%esi
f0100d67:	8b 43 18             	mov    0x18(%ebx),%eax
f0100d6a:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100d6e:	8b 43 14             	mov    0x14(%ebx),%eax
f0100d71:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100d75:	8b 43 10             	mov    0x10(%ebx),%eax
f0100d78:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100d7c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100d7f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100d83:	8b 43 08             	mov    0x8(%ebx),%eax
f0100d86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d8a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100d8e:	8b 06                	mov    (%esi),%eax
f0100d90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d94:	c7 04 24 c8 5f 10 f0 	movl   $0xf0105fc8,(%esp)
f0100d9b:	e8 97 24 00 00       	call   f0103237 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100da0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100da4:	8b 06                	mov    (%esi),%eax
f0100da6:	89 04 24             	mov    %eax,(%esp)
f0100da9:	e8 d0 32 00 00       	call   f010407e <debuginfo_eip>
		uint32_t offset = (int)(uint32_t*)ebp[1] - info.eip_fn_addr;
		cprintf(" 	%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);//there must be a space between ':' and '%s+%x'
f0100dae:	8b 06                	mov    (%esi),%eax
f0100db0:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100db3:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100db7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100dba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dc1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dc5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dcc:	c7 04 24 36 5e 10 f0 	movl   $0xf0105e36,(%esp)
f0100dd3:	e8 5f 24 00 00       	call   f0103237 <cprintf>
		ebp = (uint32_t*)ebp[0];
f0100dd8:	8b 1b                	mov    (%ebx),%ebx
//=======
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0){
f0100dda:	85 db                	test   %ebx,%ebx
f0100ddc:	75 86                	jne    f0100d64 <mon_backtrace+0x1e>
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
		uint32_t offset = (int)(uint32_t*)ebp[1] - info.eip_fn_addr;
		cprintf(" 	%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);//there must be a space between ':' and '%s+%x'
		ebp = (uint32_t*)ebp[0];
	}
    	overflow_me();
f0100dde:	e8 3e fc ff ff       	call   f0100a21 <overflow_me>
    	cprintf("Backtrace success\n");
f0100de3:	c7 04 24 46 5e 10 f0 	movl   $0xf0105e46,(%esp)
f0100dea:	e8 48 24 00 00       	call   f0103237 <cprintf>
//>>>>>>> lab2
	return 0;
}
f0100def:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df4:	83 c4 4c             	add    $0x4c,%esp
f0100df7:	5b                   	pop    %ebx
f0100df8:	5e                   	pop    %esi
f0100df9:	5f                   	pop    %edi
f0100dfa:	5d                   	pop    %ebp
f0100dfb:	c3                   	ret    

f0100dfc <mon_si>:
	}
	else
		return -1;
}
int
mon_si(int argc, char** argv, struct Trapframe* tf){
f0100dfc:	55                   	push   %ebp
f0100dfd:	89 e5                	mov    %esp,%ebp
f0100dff:	53                   	push   %ebx
f0100e00:	83 ec 44             	sub    $0x44,%esp
f0100e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (tf != NULL){
f0100e06:	85 db                	test   %ebx,%ebx
f0100e08:	74 6d                	je     f0100e77 <mon_si+0x7b>
		tf->tf_eflags |= FL_TF;
f0100e0a:	81 4b 38 00 01 00 00 	orl    $0x100,0x38(%ebx)
		struct Eipdebuginfo info;
		int r = debuginfo_eip(tf->tf_eip, &info);
f0100e11:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100e14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e18:	8b 43 30             	mov    0x30(%ebx),%eax
f0100e1b:	89 04 24             	mov    %eax,(%esp)
f0100e1e:	e8 5b 32 00 00       	call   f010407e <debuginfo_eip>
		cprintf("%08x\n", tf->tf_eip);
f0100e23:	8b 43 30             	mov    0x30(%ebx),%eax
f0100e26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e2a:	c7 04 24 25 70 10 f0 	movl   $0xf0107025,(%esp)
f0100e31:	e8 01 24 00 00       	call   f0103237 <cprintf>
		uint32_t offset = tf->tf_eip - info.eip_fn_addr;
		cprintf("%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);
f0100e36:	8b 43 30             	mov    0x30(%ebx),%eax
f0100e39:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100e3c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100e40:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100e43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e55:	c7 04 24 38 5e 10 f0 	movl   $0xf0105e38,(%esp)
f0100e5c:	e8 d6 23 00 00       	call   f0103237 <cprintf>
		env_run(curenv);		
f0100e61:	e8 78 44 00 00       	call   f01052de <cpunum>
f0100e66:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e69:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0100e6f:	89 04 24             	mov    %eax,(%esp)
f0100e72:	e8 5c 1a 00 00       	call   f01028d3 <env_run>
		return 0;
	}
	else
		return -1;
}
f0100e77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e7c:	83 c4 44             	add    $0x44,%esp
f0100e7f:	5b                   	pop    %ebx
f0100e80:	5d                   	pop    %ebp
f0100e81:	c3                   	ret    

f0100e82 <mon_c>:
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();
/*stone's solution for lab3-B*/
int
mon_c(int argc, char** argv, struct Trapframe* tf){
f0100e82:	55                   	push   %ebp
f0100e83:	89 e5                	mov    %esp,%ebp
f0100e85:	83 ec 18             	sub    $0x18,%esp
f0100e88:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf != NULL){
f0100e8b:	85 c0                	test   %eax,%eax
f0100e8d:	74 1d                	je     f0100eac <mon_c+0x2a>
		tf->tf_eflags &= ~FL_TF;
f0100e8f:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
		env_run(curenv);
f0100e96:	e8 43 44 00 00       	call   f01052de <cpunum>
f0100e9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e9e:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0100ea4:	89 04 24             	mov    %eax,(%esp)
f0100ea7:	e8 27 1a 00 00       	call   f01028d3 <env_run>
		return 0;
	}
	else
		return -1;
}
f0100eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eb1:	c9                   	leave  
f0100eb2:	c3                   	ret    

f0100eb3 <mon_x>:
int
mon_x(int argc, char** argv, struct Trapframe* tf){
f0100eb3:	55                   	push   %ebp
f0100eb4:	89 e5                	mov    %esp,%ebp
f0100eb6:	83 ec 18             	sub    $0x18,%esp
	if (argc != 2){
f0100eb9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100ebd:	74 13                	je     f0100ed2 <mon_x+0x1f>
		cprintf("Usage: x [address]\n");
f0100ebf:	c7 04 24 59 5e 10 f0 	movl   $0xf0105e59,(%esp)
f0100ec6:	e8 6c 23 00 00       	call   f0103237 <cprintf>
f0100ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0100ed0:	eb 40                	jmp    f0100f12 <mon_x+0x5f>
	}
	if (tf != NULL){
f0100ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ed7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100edb:	74 35                	je     f0100f12 <mon_x+0x5f>
		uint32_t addr;
		uint32_t val;
		addr = strtol(argv[1], NULL, 16);
f0100edd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100ee4:	00 
f0100ee5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100eec:	00 
f0100eed:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ef0:	8b 40 04             	mov    0x4(%eax),%eax
f0100ef3:	89 04 24             	mov    %eax,(%esp)
f0100ef6:	e8 b0 3e 00 00       	call   f0104dab <strtol>
		__asm __volatile("movl (%0), %0" : "=r" (val) : "r" (addr));	
f0100efb:	8b 00                	mov    (%eax),%eax
		cprintf("%d\n", val);
f0100efd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f01:	c7 04 24 56 67 10 f0 	movl   $0xf0106756,(%esp)
f0100f08:	e8 2a 23 00 00       	call   f0103237 <cprintf>
f0100f0d:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	else
		return -1;
}
f0100f12:	c9                   	leave  
f0100f13:	c3                   	ret    
	...

f0100f20 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reachesc 0.)
//
void
page_free(struct Page *pp)
{
f0100f20:	55                   	push   %ebp
f0100f21:	89 e5                	mov    %esp,%ebp
f0100f23:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	/*stone's solution for lab2*/
	if (pp->pp_ref == 0){
f0100f26:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f2b:	75 0d                	jne    f0100f3a <page_free+0x1a>
		pp->pp_link = page_free_list;
f0100f2d:	8b 15 50 32 23 f0    	mov    0xf0233250,%edx
f0100f33:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0100f35:	a3 50 32 23 f0       	mov    %eax,0xf0233250
	}
}
f0100f3a:	5d                   	pop    %ebp
f0100f3b:	c3                   	ret    

f0100f3c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100f3c:	55                   	push   %ebp
f0100f3d:	89 e5                	mov    %esp,%ebp
f0100f3f:	83 ec 04             	sub    $0x4,%esp
f0100f42:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f45:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100f49:	83 ea 01             	sub    $0x1,%edx
f0100f4c:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f50:	66 85 d2             	test   %dx,%dx
f0100f53:	75 08                	jne    f0100f5d <page_decref+0x21>
		page_free(pp);
f0100f55:	89 04 24             	mov    %eax,(%esp)
f0100f58:	e8 c3 ff ff ff       	call   f0100f20 <page_free>
}
f0100f5d:	c9                   	leave  
f0100f5e:	c3                   	ret    

f0100f5f <check_continuous>:
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp, int num_page)
{
f0100f5f:	55                   	push   %ebp
f0100f60:	89 e5                	mov    %esp,%ebp
f0100f62:	57                   	push   %edi
f0100f63:	56                   	push   %esi
f0100f64:	53                   	push   %ebx
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100f65:	8d 72 ff             	lea    -0x1(%edx),%esi
f0100f68:	85 f6                	test   %esi,%esi
f0100f6a:	7e 5f                	jle    f0100fcb <check_continuous+0x6c>
	{
		if(tmp == NULL) 
f0100f6c:	85 c0                	test   %eax,%eax
f0100f6e:	74 54                	je     f0100fc4 <check_continuous+0x65>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100f70:	8b 08                	mov    (%eax),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f72:	8b 1d b0 3e 23 f0    	mov    0xf0233eb0,%ebx
f0100f78:	89 ca                	mov    %ecx,%edx
f0100f7a:	29 da                	sub    %ebx,%edx
f0100f7c:	c1 fa 03             	sar    $0x3,%edx
f0100f7f:	29 d8                	sub    %ebx,%eax
f0100f81:	c1 f8 03             	sar    $0x3,%eax
f0100f84:	29 c2                	sub    %eax,%edx
f0100f86:	c1 e2 0c             	shl    $0xc,%edx
f0100f89:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0100f94:	74 25                	je     f0100fbb <check_continuous+0x5c>
f0100f96:	eb 2c                	jmp    f0100fc4 <check_continuous+0x65>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL) 
f0100f98:	85 c9                	test   %ecx,%ecx
f0100f9a:	74 28                	je     f0100fc4 <check_continuous+0x65>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100f9c:	8b 11                	mov    (%ecx),%edx
f0100f9e:	89 d7                	mov    %edx,%edi
f0100fa0:	29 df                	sub    %ebx,%edi
f0100fa2:	c1 ff 03             	sar    $0x3,%edi
f0100fa5:	29 d9                	sub    %ebx,%ecx
f0100fa7:	c1 f9 03             	sar    $0x3,%ecx
f0100faa:	29 cf                	sub    %ecx,%edi
f0100fac:	89 f9                	mov    %edi,%ecx
f0100fae:	c1 e1 0c             	shl    $0xc,%ecx
f0100fb1:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0100fb7:	75 0b                	jne    f0100fc4 <check_continuous+0x65>
f0100fb9:	89 d1                	mov    %edx,%ecx
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100fbb:	83 c0 01             	add    $0x1,%eax
f0100fbe:	39 f0                	cmp    %esi,%eax
f0100fc0:	7c d6                	jl     f0100f98 <check_continuous+0x39>
f0100fc2:	eb 07                	jmp    f0100fcb <check_continuous+0x6c>
f0100fc4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fc9:	eb 05                	jmp    f0100fd0 <check_continuous+0x71>
f0100fcb:	b8 01 00 00 00       	mov    $0x1,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100fd0:	5b                   	pop    %ebx
f0100fd1:	5e                   	pop    %esi
f0100fd2:	5f                   	pop    %edi
f0100fd3:	5d                   	pop    %ebp
f0100fd4:	c3                   	ret    

f0100fd5 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0100fd5:	55                   	push   %ebp
f0100fd6:	89 e5                	mov    %esp,%ebp
f0100fd8:	56                   	push   %esi
f0100fd9:	53                   	push   %ebx
f0100fda:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100fdd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function
	/* stone's solution for lab2*/
	//if (pp == NULL) return -1;

	if (check_continuous(pp, n) == 0) return -1;
f0100fe0:	89 f2                	mov    %esi,%edx
f0100fe2:	89 d8                	mov    %ebx,%eax
f0100fe4:	e8 76 ff ff ff       	call   f0100f5f <check_continuous>
f0100fe9:	89 c2                	mov    %eax,%edx
f0100feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ff0:	85 d2                	test   %edx,%edx
f0100ff2:	74 27                	je     f010101b <page_free_npages+0x46>
	struct Page* tmp = pp;
	size_t i;
	for (i = 0; i < n-1; i++)
f0100ff4:	89 da                	mov    %ebx,%edx
f0100ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ffb:	83 ee 01             	sub    $0x1,%esi
f0100ffe:	74 09                	je     f0101009 <page_free_npages+0x34>
		tmp = tmp->pp_link;
f0101000:	8b 12                	mov    (%edx),%edx
	//if (pp == NULL) return -1;

	if (check_continuous(pp, n) == 0) return -1;
	struct Page* tmp = pp;
	size_t i;
	for (i = 0; i < n-1; i++)
f0101002:	83 c0 01             	add    $0x1,%eax
f0101005:	39 f0                	cmp    %esi,%eax
f0101007:	72 f7                	jb     f0101000 <page_free_npages+0x2b>
		tmp = tmp->pp_link;
	tmp->pp_link = chunk_list;
f0101009:	a1 54 32 23 f0       	mov    0xf0233254,%eax
f010100e:	89 02                	mov    %eax,(%edx)
	chunk_list = pp;
f0101010:	89 1d 54 32 23 f0    	mov    %ebx,0xf0233254
f0101016:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010101b:	5b                   	pop    %ebx
f010101c:	5e                   	pop    %esi
f010101d:	5d                   	pop    %ebp
f010101e:	c3                   	ret    

f010101f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010101f:	55                   	push   %ebp
f0101020:	89 e5                	mov    %esp,%ebp
f0101022:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101025:	e8 b4 42 00 00       	call   f01052de <cpunum>
f010102a:	6b c0 74             	imul   $0x74,%eax,%eax
f010102d:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0101034:	74 16                	je     f010104c <tlb_invalidate+0x2d>
f0101036:	e8 a3 42 00 00       	call   f01052de <cpunum>
f010103b:	6b c0 74             	imul   $0x74,%eax,%eax
f010103e:	8b 90 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%edx
f0101044:	8b 45 08             	mov    0x8(%ebp),%eax
f0101047:	39 42 64             	cmp    %eax,0x64(%edx)
f010104a:	75 06                	jne    f0101052 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010104c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010104f:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101052:	c9                   	leave  
f0101053:	c3                   	ret    

f0101054 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101054:	55                   	push   %ebp
f0101055:	89 e5                	mov    %esp,%ebp
f0101057:	83 ec 18             	sub    $0x18,%esp
f010105a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010105d:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101060:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101062:	89 04 24             	mov    %eax,(%esp)
f0101065:	e8 72 20 00 00       	call   f01030dc <mc146818_read>
f010106a:	89 c6                	mov    %eax,%esi
f010106c:	83 c3 01             	add    $0x1,%ebx
f010106f:	89 1c 24             	mov    %ebx,(%esp)
f0101072:	e8 65 20 00 00       	call   f01030dc <mc146818_read>
f0101077:	c1 e0 08             	shl    $0x8,%eax
f010107a:	09 f0                	or     %esi,%eax
}
f010107c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010107f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101082:	89 ec                	mov    %ebp,%esp
f0101084:	5d                   	pop    %ebp
f0101085:	c3                   	ret    

f0101086 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101086:	55                   	push   %ebp
f0101087:	89 e5                	mov    %esp,%ebp
f0101089:	83 ec 18             	sub    $0x18,%esp
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010108c:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f0101092:	c1 f8 03             	sar    $0x3,%eax
f0101095:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101098:	89 c2                	mov    %eax,%edx
f010109a:	c1 ea 0c             	shr    $0xc,%edx
f010109d:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f01010a3:	72 20                	jb     f01010c5 <page2kva+0x3f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010a9:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01010b0:	f0 
f01010b1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01010b8:	00 
f01010b9:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f01010c0:	e8 c0 ef ff ff       	call   f0100085 <_panic>
f01010c5:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
}
f01010ca:	c9                   	leave  
f01010cb:	c3                   	ret    

f01010cc <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f01010cc:	55                   	push   %ebp
f01010cd:	89 e5                	mov    %esp,%ebp
f01010cf:	57                   	push   %edi
f01010d0:	56                   	push   %esi
f01010d1:	53                   	push   %ebx
f01010d2:	83 ec 2c             	sub    $0x2c,%esp
	// Fill this function
	/*stone's solution for lab2*/
	if (n <= 0)
f01010d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01010d9:	0f 8e fe 00 00 00    	jle    f01011dd <page_alloc_npages+0x111>
		return NULL;
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
f01010df:	8b 35 a8 3e 23 f0    	mov    0xf0233ea8,%esi
f01010e5:	85 f6                	test   %esi,%esi
f01010e7:	0f 84 f0 00 00 00    	je     f01011dd <page_alloc_npages+0x111>
		if (pages[i].pp_ref == 0){
f01010ed:	a1 b0 3e 23 f0       	mov    0xf0233eb0,%eax
f01010f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010f5:	b9 00 00 00 00       	mov    $0x0,%ecx
			for (j = 0; j < n && i + j < npages; j++){
f01010fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
		return NULL;
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
		if (pages[i].pp_ref == 0){
f01010fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101100:	66 83 7c cb 04 00    	cmpw   $0x0,0x4(%ebx,%ecx,8)
f0101106:	75 41                	jne    f0101149 <page_alloc_npages+0x7d>
			for (j = 0; j < n && i + j < npages; j++){
f0101108:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010110c:	0f 84 da 00 00 00    	je     f01011ec <page_alloc_npages+0x120>
f0101112:	b8 00 00 00 00       	mov    $0x0,%eax
f0101117:	39 ce                	cmp    %ecx,%esi
f0101119:	76 2c                	jbe    f0101147 <page_alloc_npages+0x7b>
f010111b:	8d 54 cb 0c          	lea    0xc(%ebx,%ecx,8),%edx
f010111f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101124:	eb 0b                	jmp    f0101131 <page_alloc_npages+0x65>
				if (pages[i+j].pp_ref != 0)
f0101126:	0f b7 1a             	movzwl (%edx),%ebx
f0101129:	83 c2 08             	add    $0x8,%edx
f010112c:	66 85 db             	test   %bx,%bx
f010112f:	75 0e                	jne    f010113f <page_alloc_npages+0x73>
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
		if (pages[i].pp_ref == 0){
			for (j = 0; j < n && i + j < npages; j++){
f0101131:	83 c0 01             	add    $0x1,%eax
f0101134:	39 f8                	cmp    %edi,%eax
f0101136:	73 07                	jae    f010113f <page_alloc_npages+0x73>
f0101138:	8d 1c 08             	lea    (%eax,%ecx,1),%ebx
f010113b:	39 de                	cmp    %ebx,%esi
f010113d:	77 e7                	ja     f0101126 <page_alloc_npages+0x5a>
				if (pages[i+j].pp_ref != 0)
					break;
			}
			if (j == n) flag = 1;
f010113f:	39 c7                	cmp    %eax,%edi
f0101141:	0f 84 aa 00 00 00    	je     f01011f1 <page_alloc_npages+0x125>
			else i += j;
f0101147:	01 c1                	add    %eax,%ecx
		}
		if (flag == 1) break;
		i++;
f0101149:	83 c1 01             	add    $0x1,%ecx
	if (n <= 0)
		return NULL;
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
f010114c:	39 f1                	cmp    %esi,%ecx
f010114e:	72 ad                	jb     f01010fd <page_alloc_npages+0x31>
f0101150:	e9 88 00 00 00       	jmp    f01011dd <page_alloc_npages+0x111>
		i++;
	}
	if (flag == 0) return NULL;

	struct Page* tmp = page_free_list;
	while (&pages[i+j] > tmp && tmp >= &pages[i])
f0101155:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101158:	8d 1c ce             	lea    (%esi,%ecx,8),%ebx
f010115b:	39 da                	cmp    %ebx,%edx
f010115d:	72 0a                	jb     f0101169 <page_alloc_npages+0x9d>
		tmp = tmp->pp_link;
f010115f:	8b 12                	mov    (%edx),%edx
		i++;
	}
	if (flag == 0) return NULL;

	struct Page* tmp = page_free_list;
	while (&pages[i+j] > tmp && tmp >= &pages[i])
f0101161:	39 c2                	cmp    %eax,%edx
f0101163:	73 04                	jae    f0101169 <page_alloc_npages+0x9d>
f0101165:	39 da                	cmp    %ebx,%edx
f0101167:	73 f6                	jae    f010115f <page_alloc_npages+0x93>
		tmp = tmp->pp_link;
	page_free_list = tmp;
f0101169:	89 15 50 32 23 f0    	mov    %edx,0xf0233250
			result->pp_link = tmp->pp_link;
		}
		result = tmp;
	}*/
	size_t k;
	for (k = 0; k < n - 1; k++){
f010116f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101172:	83 ef 01             	sub    $0x1,%edi
f0101175:	74 32                	je     f01011a9 <page_alloc_npages+0xdd>
f0101177:	8d 1c cd 00 00 00 00 	lea    0x0(,%ecx,8),%ebx
f010117e:	8d 14 cd 08 00 00 00 	lea    0x8(,%ecx,8),%edx
f0101185:	b8 00 00 00 00       	mov    $0x0,%eax
f010118a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		pages[k + i].pp_link = &pages[k + 1 + i];
f010118d:	8b 0d b0 3e 23 f0    	mov    0xf0233eb0,%ecx
f0101193:	8d 34 11             	lea    (%ecx,%edx,1),%esi
f0101196:	89 34 19             	mov    %esi,(%ecx,%ebx,1)
			result->pp_link = tmp->pp_link;
		}
		result = tmp;
	}*/
	size_t k;
	for (k = 0; k < n - 1; k++){
f0101199:	83 c0 01             	add    $0x1,%eax
f010119c:	83 c3 08             	add    $0x8,%ebx
f010119f:	83 c2 08             	add    $0x8,%edx
f01011a2:	39 c7                	cmp    %eax,%edi
f01011a4:	77 e7                	ja     f010118d <page_alloc_npages+0xc1>
f01011a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
		pages[k + i].pp_link = &pages[k + 1 + i];
	}
	result = &pages[i];
f01011a9:	c1 e1 03             	shl    $0x3,%ecx
f01011ac:	89 cb                	mov    %ecx,%ebx
f01011ae:	03 1d b0 3e 23 f0    	add    0xf0233eb0,%ebx
	
	if (alloc_flags & ALLOC_ZERO)
f01011b4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01011b8:	74 28                	je     f01011e2 <page_alloc_npages+0x116>
		memset(page2kva(result), '\0', n*PGSIZE);
f01011ba:	89 d8                	mov    %ebx,%eax
f01011bc:	e8 c5 fe ff ff       	call   f0101086 <page2kva>
f01011c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011c4:	c1 e2 0c             	shl    $0xc,%edx
f01011c7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01011cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011d2:	00 
f01011d3:	89 04 24             	mov    %eax,(%esp)
f01011d6:	e8 5b 3a 00 00       	call   f0104c36 <memset>
f01011db:	eb 05                	jmp    f01011e2 <page_alloc_npages+0x116>
f01011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	return result;
}
f01011e2:	89 d8                	mov    %ebx,%eax
f01011e4:	83 c4 2c             	add    $0x2c,%esp
f01011e7:	5b                   	pop    %ebx
f01011e8:	5e                   	pop    %esi
f01011e9:	5f                   	pop    %edi
f01011ea:	5d                   	pop    %ebp
f01011eb:	c3                   	ret    
		pages[k + i].pp_link = &pages[k + 1 + i];
	}
	result = &pages[i];
	
	if (alloc_flags & ALLOC_ZERO)
		memset(page2kva(result), '\0', n*PGSIZE);
f01011ec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (flag == 1) break;
		i++;
	}
	if (flag == 0) return NULL;

	struct Page* tmp = page_free_list;
f01011f1:	8b 15 50 32 23 f0    	mov    0xf0233250,%edx
	while (&pages[i+j] > tmp && tmp >= &pages[i])
f01011f7:	01 c8                	add    %ecx,%eax
f01011f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01011fc:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01011ff:	39 c2                	cmp    %eax,%edx
f0101201:	0f 82 4e ff ff ff    	jb     f0101155 <page_alloc_npages+0x89>
f0101207:	e9 5d ff ff ff       	jmp    f0101169 <page_alloc_npages+0x9d>

f010120c <page_realloc_npages>:
// (Try to reuse the allocated pages as many as possible.)
//

struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f010120c:	55                   	push   %ebp
f010120d:	89 e5                	mov    %esp,%ebp
f010120f:	83 ec 38             	sub    $0x38,%esp
f0101212:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101215:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101218:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010121e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101221:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function
	//stone's solution for lab2
	if (new_n <= 0) return NULL;
f0101224:	85 f6                	test   %esi,%esi
f0101226:	0f 8e c5 00 00 00    	jle    f01012f1 <page_realloc_npages+0xe5>
	if (old_n <= 0) return NULL;
f010122c:	85 ff                	test   %edi,%edi
f010122e:	0f 8e bd 00 00 00    	jle    f01012f1 <page_realloc_npages+0xe5>
	if (check_continuous(pp, old_n) == 0) return NULL;
f0101234:	89 fa                	mov    %edi,%edx
f0101236:	89 d8                	mov    %ebx,%eax
f0101238:	e8 22 fd ff ff       	call   f0100f5f <check_continuous>
f010123d:	85 c0                	test   %eax,%eax
f010123f:	0f 84 ac 00 00 00    	je     f01012f1 <page_realloc_npages+0xe5>
	if (new_n == old_n) return pp;
f0101245:	39 fe                	cmp    %edi,%esi
f0101247:	0f 84 a9 00 00 00    	je     f01012f6 <page_realloc_npages+0xea>
	if (new_n < old_n){
f010124d:	39 fe                	cmp    %edi,%esi
f010124f:	90                   	nop
f0101250:	7d 16                	jge    f0101268 <page_realloc_npages+0x5c>
		page_free_npages(pp+new_n, old_n-new_n);
f0101252:	29 f7                	sub    %esi,%edi
f0101254:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101258:	8d 04 f3             	lea    (%ebx,%esi,8),%eax
f010125b:	89 04 24             	mov    %eax,(%esp)
f010125e:	e8 72 fd ff ff       	call   f0100fd5 <page_free_npages>
		return pp;
f0101263:	e9 8e 00 00 00       	jmp    f01012f6 <page_realloc_npages+0xea>
	}
	//stone: when new_n > old_n ,if the tail pages is continuous, then link them directly, o.w alloc new pages. 
	struct Page* tmp = pp + old_n;
f0101268:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	size_t i;
	int flag = 0;
	for (i = 0; i < new_n - old_n; i++){
f010126b:	89 f2                	mov    %esi,%edx
f010126d:	29 fa                	sub    %edi,%edx
f010126f:	0f 84 81 00 00 00    	je     f01012f6 <page_realloc_npages+0xea>
	if (new_n < old_n){
		page_free_npages(pp+new_n, old_n-new_n);
		return pp;
	}
	//stone: when new_n > old_n ,if the tail pages is continuous, then link them directly, o.w alloc new pages. 
	struct Page* tmp = pp + old_n;
f0101275:	8d 0c fb             	lea    (%ebx,%edi,8),%ecx
	size_t i;
	int flag = 0;
	for (i = 0; i < new_n - old_n; i++){
		if (tmp->pp_ref != 0){
f0101278:	b8 00 00 00 00       	mov    $0x0,%eax
f010127d:	66 83 79 04 00       	cmpw   $0x0,0x4(%ecx)
f0101282:	74 0a                	je     f010128e <page_realloc_npages+0x82>
f0101284:	eb 11                	jmp    f0101297 <page_realloc_npages+0x8b>
f0101286:	66 83 7c c1 04 00    	cmpw   $0x0,0x4(%ecx,%eax,8)
f010128c:	75 09                	jne    f0101297 <page_realloc_npages+0x8b>
	}
	//stone: when new_n > old_n ,if the tail pages is continuous, then link them directly, o.w alloc new pages. 
	struct Page* tmp = pp + old_n;
	size_t i;
	int flag = 0;
	for (i = 0; i < new_n - old_n; i++){
f010128e:	83 c0 01             	add    $0x1,%eax
f0101291:	39 d0                	cmp    %edx,%eax
f0101293:	72 f1                	jb     f0101286 <page_realloc_npages+0x7a>
f0101295:	eb 6e                	jmp    f0101305 <page_realloc_npages+0xf9>
			result++;
		}
		return pp;
	}
	else{
		result = page_alloc_npages(ALLOC_ZERO, new_n);
f0101297:	89 74 24 04          	mov    %esi,0x4(%esp)
f010129b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01012a2:	e8 25 fe ff ff       	call   f01010cc <page_alloc_npages>
f01012a7:	89 c6                	mov    %eax,%esi
		memmove(page2kva(result), page2kva(pp), old_n*PGSIZE);
f01012a9:	89 d8                	mov    %ebx,%eax
f01012ab:	e8 d6 fd ff ff       	call   f0101086 <page2kva>
f01012b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012b3:	89 f0                	mov    %esi,%eax
f01012b5:	e8 cc fd ff ff       	call   f0101086 <page2kva>
f01012ba:	89 fa                	mov    %edi,%edx
f01012bc:	c1 e2 0c             	shl    $0xc,%edx
f01012bf:	89 54 24 08          	mov    %edx,0x8(%esp)
f01012c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01012c6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012ca:	89 04 24             	mov    %eax,(%esp)
f01012cd:	e8 c3 39 00 00       	call   f0104c95 <memmove>
		page_free_npages(pp, old_n);
f01012d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012d6:	89 1c 24             	mov    %ebx,(%esp)
f01012d9:	e8 f7 fc ff ff       	call   f0100fd5 <page_free_npages>
f01012de:	89 f3                	mov    %esi,%ebx
		pp = result;
		return pp;
f01012e0:	eb 14                	jmp    f01012f6 <page_realloc_npages+0xea>
	}
	struct Page* result;
	if (flag == 0){
		result = pp + old_n - 1;
		for (i = 0; i < new_n - old_n; i++){
			result->pp_link = result + 1;
f01012e2:	83 c0 08             	add    $0x8,%eax
f01012e5:	89 40 f8             	mov    %eax,-0x8(%eax)
		else tmp++;
	}
	struct Page* result;
	if (flag == 0){
		result = pp + old_n - 1;
		for (i = 0; i < new_n - old_n; i++){
f01012e8:	83 c1 01             	add    $0x1,%ecx
f01012eb:	39 d1                	cmp    %edx,%ecx
f01012ed:	72 f3                	jb     f01012e2 <page_realloc_npages+0xd6>
f01012ef:	eb 05                	jmp    f01012f6 <page_realloc_npages+0xea>
f01012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		page_free_npages(pp, old_n);
		pp = result;
		return pp;
	}		
	//return NULL;
}
f01012f6:	89 d8                	mov    %ebx,%eax
f01012f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01012fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01012fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101301:	89 ec                	mov    %ebp,%esp
f0101303:	5d                   	pop    %ebp
f0101304:	c3                   	ret    
		}
		else tmp++;
	}
	struct Page* result;
	if (flag == 0){
		result = pp + old_n - 1;
f0101305:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101308:	8d 44 cb f8          	lea    -0x8(%ebx,%ecx,8),%eax
f010130c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101311:	eb cf                	jmp    f01012e2 <page_realloc_npages+0xd6>

f0101313 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101313:	55                   	push   %ebp
f0101314:	89 e5                	mov    %esp,%ebp
f0101316:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101319:	89 d1                	mov    %edx,%ecx
f010131b:	c1 e9 16             	shr    $0x16,%ecx
f010131e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101321:	a8 01                	test   $0x1,%al
f0101323:	74 4d                	je     f0101372 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101325:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010132a:	89 c1                	mov    %eax,%ecx
f010132c:	c1 e9 0c             	shr    $0xc,%ecx
f010132f:	3b 0d a8 3e 23 f0    	cmp    0xf0233ea8,%ecx
f0101335:	72 20                	jb     f0101357 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101337:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010133b:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0101342:	f0 
f0101343:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f010134a:	00 
f010134b:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101352:	e8 2e ed ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101357:	c1 ea 0c             	shr    $0xc,%edx
f010135a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101360:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101367:	a8 01                	test   $0x1,%al
f0101369:	74 07                	je     f0101372 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010136b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101370:	eb 05                	jmp    f0101377 <check_va2pa+0x64>
f0101372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101377:	c9                   	leave  
f0101378:	c3                   	ret    

f0101379 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101379:	55                   	push   %ebp
f010137a:	89 e5                	mov    %esp,%ebp
f010137c:	53                   	push   %ebx
f010137d:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101380:	83 3d 48 32 23 f0 00 	cmpl   $0x0,0xf0233248
f0101387:	75 11                	jne    f010139a <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101389:	ba 03 60 27 f0       	mov    $0xf0276003,%edx
f010138e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101394:	89 15 48 32 23 f0    	mov    %edx,0xf0233248
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	/*stone's solution for lab2*/
	result = nextfree;
f010139a:	8b 15 48 32 23 f0    	mov    0xf0233248,%edx
	if (n > 0){
f01013a0:	85 c0                	test   %eax,%eax
f01013a2:	74 76                	je     f010141a <boot_alloc+0xa1>
		nextfree += n;
f01013a4:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01013a7:	a3 48 32 23 f0       	mov    %eax,0xf0233248
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013ac:	89 c1                	mov    %eax,%ecx
f01013ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013b3:	77 20                	ja     f01013d5 <boot_alloc+0x5c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013b9:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f01013c0:	f0 
f01013c1:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f01013c8:	00 
f01013c9:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01013d0:	e8 b0 ec ff ff       	call   f0100085 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01013d5:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013db:	89 c3                	mov    %eax,%ebx
f01013dd:	c1 eb 0c             	shr    $0xc,%ebx
f01013e0:	3b 1d a8 3e 23 f0    	cmp    0xf0233ea8,%ebx
f01013e6:	72 20                	jb     f0101408 <boot_alloc+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013ec:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01013f3:	f0 
f01013f4:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f01013fb:	00 
f01013fc:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101403:	e8 7d ec ff ff       	call   f0100085 <_panic>
		KADDR(PADDR(nextfree));
		nextfree = ROUNDUP(nextfree, PGSIZE);
f0101408:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f010140e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101414:	89 0d 48 32 23 f0    	mov    %ecx,0xf0233248
	}
	return result;
}
f010141a:	89 d0                	mov    %edx,%eax
f010141c:	83 c4 14             	add    $0x14,%esp
f010141f:	5b                   	pop    %ebx
f0101420:	5d                   	pop    %ebp
f0101421:	c3                   	ret    

f0101422 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101422:	55                   	push   %ebp
f0101423:	89 e5                	mov    %esp,%ebp
f0101425:	56                   	push   %esi
f0101426:	53                   	push   %ebx
f0101427:	83 ec 10             	sub    $0x10,%esp
	// free pages!
	/*stone's solution for lab2*/
	size_t i;
	size_t mp = MPENTRY_PADDR / PGSIZE;
	/*stone's solution for lab4-A(modify)*/
	for (i = 1; i < npages_basemem && i != mp; i++){
f010142a:	8b 35 4c 32 23 f0    	mov    0xf023324c,%esi
f0101430:	83 fe 01             	cmp    $0x1,%esi
f0101433:	76 42                	jbe    f0101477 <page_init+0x55>
f0101435:	8b 0d 50 32 23 f0    	mov    0xf0233250,%ecx
f010143b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101440:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101447:	8b 1d b0 3e 23 f0    	mov    0xf0233eb0,%ebx
f010144d:	66 c7 44 13 04 00 00 	movw   $0x0,0x4(%ebx,%edx,1)
		pages[i].pp_link = page_free_list;
f0101454:	8b 1d b0 3e 23 f0    	mov    0xf0233eb0,%ebx
f010145a:	89 0c 13             	mov    %ecx,(%ebx,%edx,1)
		page_free_list = &pages[i];
f010145d:	89 d1                	mov    %edx,%ecx
f010145f:	03 0d b0 3e 23 f0    	add    0xf0233eb0,%ecx
	// free pages!
	/*stone's solution for lab2*/
	size_t i;
	size_t mp = MPENTRY_PADDR / PGSIZE;
	/*stone's solution for lab4-A(modify)*/
	for (i = 1; i < npages_basemem && i != mp; i++){
f0101465:	83 c0 01             	add    $0x1,%eax
f0101468:	39 f0                	cmp    %esi,%eax
f010146a:	73 05                	jae    f0101471 <page_init+0x4f>
f010146c:	83 f8 07             	cmp    $0x7,%eax
f010146f:	75 cf                	jne    f0101440 <page_init+0x1e>
f0101471:	89 0d 50 32 23 f0    	mov    %ecx,0xf0233250
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//use boot_alloc(0) to get next free page
	for (i = (PADDR(boot_alloc(0)) / PGSIZE); i < npages; i++){
f0101477:	b8 00 00 00 00       	mov    $0x0,%eax
f010147c:	e8 f8 fe ff ff       	call   f0101379 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101481:	89 c2                	mov    %eax,%edx
f0101483:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101488:	77 20                	ja     f01014aa <page_init+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010148a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010148e:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0101495:	f0 
f0101496:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f010149d:	00 
f010149e:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01014a5:	e8 db eb ff ff       	call   f0100085 <_panic>
f01014aa:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01014b0:	c1 ea 0c             	shr    $0xc,%edx
f01014b3:	39 15 a8 3e 23 f0    	cmp    %edx,0xf0233ea8
f01014b9:	76 3f                	jbe    f01014fa <page_init+0xd8>
f01014bb:	8b 0d 50 32 23 f0    	mov    0xf0233250,%ecx
f01014c1:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		 pages[i].pp_ref = 0;
f01014c8:	8b 1d b0 3e 23 f0    	mov    0xf0233eb0,%ebx
f01014ce:	66 c7 44 03 04 00 00 	movw   $0x0,0x4(%ebx,%eax,1)
		pages[i].pp_link = page_free_list;
f01014d5:	8b 1d b0 3e 23 f0    	mov    0xf0233eb0,%ebx
f01014db:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
		page_free_list = &pages[i];
f01014de:	89 c1                	mov    %eax,%ecx
f01014e0:	03 0d b0 3e 23 f0    	add    0xf0233eb0,%ecx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//use boot_alloc(0) to get next free page
	for (i = (PADDR(boot_alloc(0)) / PGSIZE); i < npages; i++){
f01014e6:	83 c2 01             	add    $0x1,%edx
f01014e9:	83 c0 08             	add    $0x8,%eax
f01014ec:	39 15 a8 3e 23 f0    	cmp    %edx,0xf0233ea8
f01014f2:	77 d4                	ja     f01014c8 <page_init+0xa6>
f01014f4:	89 0d 50 32 23 f0    	mov    %ecx,0xf0233250
		 pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f01014fa:	c7 05 54 32 23 f0 00 	movl   $0x0,0xf0233254
f0101501:	00 00 00 
}
f0101504:	83 c4 10             	add    $0x10,%esp
f0101507:	5b                   	pop    %ebx
f0101508:	5e                   	pop    %esi
f0101509:	5d                   	pop    %ebp
f010150a:	c3                   	ret    

f010150b <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010150b:	55                   	push   %ebp
f010150c:	89 e5                	mov    %esp,%ebp
f010150e:	57                   	push   %edi
f010150f:	56                   	push   %esi
f0101510:	53                   	push   %ebx
f0101511:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101514:	83 f8 01             	cmp    $0x1,%eax
f0101517:	19 f6                	sbb    %esi,%esi
f0101519:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010151f:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101522:	8b 1d 50 32 23 f0    	mov    0xf0233250,%ebx
f0101528:	85 db                	test   %ebx,%ebx
f010152a:	75 1c                	jne    f0101548 <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f010152c:	c7 44 24 08 34 61 10 	movl   $0xf0106134,0x8(%esp)
f0101533:	f0 
f0101534:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f010153b:	00 
f010153c:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101543:	e8 3d eb ff ff       	call   f0100085 <_panic>
	//cprintf("2");
	if (only_low_memory) {
f0101548:	85 c0                	test   %eax,%eax
f010154a:	74 52                	je     f010159e <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f010154c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010154f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101552:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101555:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101558:	8b 0d b0 3e 23 f0    	mov    0xf0233eb0,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010155e:	89 d8                	mov    %ebx,%eax
f0101560:	29 c8                	sub    %ecx,%eax
f0101562:	c1 e0 09             	shl    $0x9,%eax
f0101565:	c1 e8 16             	shr    $0x16,%eax
f0101568:	39 c6                	cmp    %eax,%esi
f010156a:	0f 96 c0             	setbe  %al
f010156d:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101570:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101574:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101576:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010157a:	8b 1b                	mov    (%ebx),%ebx
f010157c:	85 db                	test   %ebx,%ebx
f010157e:	75 de                	jne    f010155e <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101580:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101583:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101589:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010158c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010158f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101594:	89 1d 50 32 23 f0    	mov    %ebx,0xf0233250
	}
	//cprintf("2");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f010159a:	85 db                	test   %ebx,%ebx
f010159c:	74 67                	je     f0101605 <check_page_free_list+0xfa>
f010159e:	89 d8                	mov    %ebx,%eax
f01015a0:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f01015a6:	c1 f8 03             	sar    $0x3,%eax
f01015a9:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01015ac:	89 c2                	mov    %eax,%edx
f01015ae:	c1 ea 16             	shr    $0x16,%edx
f01015b1:	39 d6                	cmp    %edx,%esi
f01015b3:	76 4a                	jbe    f01015ff <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015b5:	89 c2                	mov    %eax,%edx
f01015b7:	c1 ea 0c             	shr    $0xc,%edx
f01015ba:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f01015c0:	72 20                	jb     f01015e2 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015c6:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01015cd:	f0 
f01015ce:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01015d5:	00 
f01015d6:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f01015dd:	e8 a3 ea ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01015e2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01015e9:	00 
f01015ea:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01015f1:	00 
f01015f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015f7:	89 04 24             	mov    %eax,(%esp)
f01015fa:	e8 37 36 00 00       	call   f0104c36 <memset>
		page_free_list = pp1;
	}
	//cprintf("2");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01015ff:	8b 1b                	mov    (%ebx),%ebx
f0101601:	85 db                	test   %ebx,%ebx
f0101603:	75 99                	jne    f010159e <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
f0101605:	b8 00 00 00 00       	mov    $0x0,%eax
f010160a:	e8 6a fd ff ff       	call   f0101379 <boot_alloc>
f010160f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101612:	8b 15 50 32 23 f0    	mov    0xf0233250,%edx
f0101618:	85 d2                	test   %edx,%edx
f010161a:	0f 84 3b 02 00 00    	je     f010185b <check_page_free_list+0x350>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101620:	8b 1d b0 3e 23 f0    	mov    0xf0233eb0,%ebx
f0101626:	39 da                	cmp    %ebx,%edx
f0101628:	72 50                	jb     f010167a <check_page_free_list+0x16f>
		assert(pp < pages + npages);
f010162a:	a1 a8 3e 23 f0       	mov    0xf0233ea8,%eax
f010162f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101632:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101635:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101638:	39 c2                	cmp    %eax,%edx
f010163a:	73 67                	jae    f01016a3 <check_page_free_list+0x198>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010163c:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010163f:	89 d0                	mov    %edx,%eax
f0101641:	29 d8                	sub    %ebx,%eax
f0101643:	a8 07                	test   $0x7,%al
f0101645:	0f 85 85 00 00 00    	jne    f01016d0 <check_page_free_list+0x1c5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010164b:	c1 f8 03             	sar    $0x3,%eax
f010164e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101651:	85 c0                	test   %eax,%eax
f0101653:	0f 84 a5 00 00 00    	je     f01016fe <check_page_free_list+0x1f3>
		assert(page2pa(pp) != IOPHYSMEM);
f0101659:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010165e:	0f 84 c5 00 00 00    	je     f0101729 <check_page_free_list+0x21e>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101664:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101669:	0f 85 09 01 00 00    	jne    f0101778 <check_page_free_list+0x26d>
f010166f:	90                   	nop
f0101670:	e9 df 00 00 00       	jmp    f0101754 <check_page_free_list+0x249>
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101675:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101678:	73 24                	jae    f010169e <check_page_free_list+0x193>
f010167a:	c7 44 24 0c 87 64 10 	movl   $0xf0106487,0xc(%esp)
f0101681:	f0 
f0101682:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0101689:	f0 
f010168a:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101691:	00 
f0101692:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101699:	e8 e7 e9 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f010169e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01016a1:	72 24                	jb     f01016c7 <check_page_free_list+0x1bc>
f01016a3:	c7 44 24 0c a8 64 10 	movl   $0xf01064a8,0xc(%esp)
f01016aa:	f0 
f01016ab:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01016b2:	f0 
f01016b3:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01016ba:	00 
f01016bb:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01016c2:	e8 be e9 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01016c7:	89 d0                	mov    %edx,%eax
f01016c9:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01016cc:	a8 07                	test   $0x7,%al
f01016ce:	74 24                	je     f01016f4 <check_page_free_list+0x1e9>
f01016d0:	c7 44 24 0c 58 61 10 	movl   $0xf0106158,0xc(%esp)
f01016d7:	f0 
f01016d8:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01016df:	f0 
f01016e0:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f01016e7:	00 
f01016e8:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01016ef:	e8 91 e9 ff ff       	call   f0100085 <_panic>
f01016f4:	c1 f8 03             	sar    $0x3,%eax
f01016f7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01016fa:	85 c0                	test   %eax,%eax
f01016fc:	75 24                	jne    f0101722 <check_page_free_list+0x217>
f01016fe:	c7 44 24 0c bc 64 10 	movl   $0xf01064bc,0xc(%esp)
f0101705:	f0 
f0101706:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f010170d:	f0 
f010170e:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101715:	00 
f0101716:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010171d:	e8 63 e9 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101722:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101727:	75 24                	jne    f010174d <check_page_free_list+0x242>
f0101729:	c7 44 24 0c cd 64 10 	movl   $0xf01064cd,0xc(%esp)
f0101730:	f0 
f0101731:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0101738:	f0 
f0101739:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101740:	00 
f0101741:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101748:	e8 38 e9 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010174d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101752:	75 31                	jne    f0101785 <check_page_free_list+0x27a>
f0101754:	c7 44 24 0c 8c 61 10 	movl   $0xf010618c,0xc(%esp)
f010175b:	f0 
f010175c:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0101763:	f0 
f0101764:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f010176b:	00 
f010176c:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101773:	e8 0d e9 ff ff       	call   f0100085 <_panic>
f0101778:	be 00 00 00 00       	mov    $0x0,%esi
f010177d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101782:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0101785:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010178a:	75 24                	jne    f01017b0 <check_page_free_list+0x2a5>
f010178c:	c7 44 24 0c e6 64 10 	movl   $0xf01064e6,0xc(%esp)
f0101793:	f0 
f0101794:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f010179b:	f0 
f010179c:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f01017a3:	00 
f01017a4:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01017ab:	e8 d5 e8 ff ff       	call   f0100085 <_panic>
f01017b0:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01017b2:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01017b7:	76 59                	jbe    f0101812 <check_page_free_list+0x307>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017b9:	89 c3                	mov    %eax,%ebx
f01017bb:	c1 eb 0c             	shr    $0xc,%ebx
f01017be:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f01017c1:	77 20                	ja     f01017e3 <check_page_free_list+0x2d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017c7:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01017ce:	f0 
f01017cf:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01017d6:	00 
f01017d7:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f01017de:	e8 a2 e8 ff ff       	call   f0100085 <_panic>
f01017e3:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01017e9:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01017ec:	76 24                	jbe    f0101812 <check_page_free_list+0x307>
f01017ee:	c7 44 24 0c b0 61 10 	movl   $0xf01061b0,0xc(%esp)
f01017f5:	f0 
f01017f6:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01017fd:	f0 
f01017fe:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101805:	00 
f0101806:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010180d:	e8 73 e8 ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101812:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101817:	75 24                	jne    f010183d <check_page_free_list+0x332>
f0101819:	c7 44 24 0c 00 65 10 	movl   $0xf0106500,0xc(%esp)
f0101820:	f0 
f0101821:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0101828:	f0 
f0101829:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101830:	00 
f0101831:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101838:	e8 48 e8 ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010183d:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101843:	77 05                	ja     f010184a <check_page_free_list+0x33f>
			++nfree_basemem;
f0101845:	83 c7 01             	add    $0x1,%edi
f0101848:	eb 03                	jmp    f010184d <check_page_free_list+0x342>
		else
			++nfree_extmem;
f010184a:	83 c6 01             	add    $0x1,%esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010184d:	8b 12                	mov    (%edx),%edx
f010184f:	85 d2                	test   %edx,%edx
f0101851:	0f 85 1e fe ff ff    	jne    f0101675 <check_page_free_list+0x16a>
			++nfree_basemem;
		else
			++nfree_extmem;
	}
	//cprintf("2");
	assert(nfree_basemem > 0);
f0101857:	85 ff                	test   %edi,%edi
f0101859:	7f 24                	jg     f010187f <check_page_free_list+0x374>
f010185b:	c7 44 24 0c 1d 65 10 	movl   $0xf010651d,0xc(%esp)
f0101862:	f0 
f0101863:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f010186a:	f0 
f010186b:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101872:	00 
f0101873:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010187a:	e8 06 e8 ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f010187f:	85 f6                	test   %esi,%esi
f0101881:	7f 24                	jg     f01018a7 <check_page_free_list+0x39c>
f0101883:	c7 44 24 0c 2f 65 10 	movl   $0xf010652f,0xc(%esp)
f010188a:	f0 
f010188b:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0101892:	f0 
f0101893:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f010189a:	00 
f010189b:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01018a2:	e8 de e7 ff ff       	call   f0100085 <_panic>
	//cprintf("2");
}
f01018a7:	83 c4 5c             	add    $0x5c,%esp
f01018aa:	5b                   	pop    %ebx
f01018ab:	5e                   	pop    %esi
f01018ac:	5f                   	pop    %edi
f01018ad:	5d                   	pop    %ebp
f01018ae:	c3                   	ret    

f01018af <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01018af:	55                   	push   %ebp
f01018b0:	89 e5                	mov    %esp,%ebp
f01018b2:	53                   	push   %ebx
f01018b3:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	/*stone's solution for lab2*/
	struct Page* alloc_page;
	if (page_free_list != NULL){
f01018b6:	8b 1d 50 32 23 f0    	mov    0xf0233250,%ebx
f01018bc:	85 db                	test   %ebx,%ebx
f01018be:	74 6b                	je     f010192b <page_alloc+0x7c>
		alloc_page = page_free_list;
		page_free_list = page_free_list->pp_link;
f01018c0:	8b 03                	mov    (%ebx),%eax
f01018c2:	a3 50 32 23 f0       	mov    %eax,0xf0233250
		alloc_page->pp_link = NULL;
f01018c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f01018cd:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01018d1:	74 58                	je     f010192b <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01018d3:	89 d8                	mov    %ebx,%eax
f01018d5:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f01018db:	c1 f8 03             	sar    $0x3,%eax
f01018de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018e1:	89 c2                	mov    %eax,%edx
f01018e3:	c1 ea 0c             	shr    $0xc,%edx
f01018e6:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f01018ec:	72 20                	jb     f010190e <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018f2:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01018f9:	f0 
f01018fa:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101901:	00 
f0101902:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0101909:	e8 77 e7 ff ff       	call   f0100085 <_panic>
			memset(page2kva(alloc_page), '\0', PGSIZE);
f010190e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101915:	00 
f0101916:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010191d:	00 
f010191e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101923:	89 04 24             	mov    %eax,(%esp)
f0101926:	e8 0b 33 00 00       	call   f0104c36 <memset>
		return alloc_page;
	}
	return NULL;
}
f010192b:	89 d8                	mov    %ebx,%eax
f010192d:	83 c4 14             	add    $0x14,%esp
f0101930:	5b                   	pop    %ebx
f0101931:	5d                   	pop    %ebp
f0101932:	c3                   	ret    

f0101933 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101933:	55                   	push   %ebp
f0101934:	89 e5                	mov    %esp,%ebp
f0101936:	83 ec 18             	sub    $0x18,%esp
f0101939:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010193c:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	/*stone's solution for lab2*/
	pde_t* pde = pgdir + PDX(va);//stone: get pde
f010193f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101942:	89 de                	mov    %ebx,%esi
f0101944:	c1 ee 16             	shr    $0x16,%esi
f0101947:	c1 e6 02             	shl    $0x2,%esi
f010194a:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P){//stone:if present
f010194d:	8b 06                	mov    (%esi),%eax
f010194f:	a8 01                	test   $0x1,%al
f0101951:	74 44                	je     f0101997 <pgdir_walk+0x64>
		pte_t *pte = PTX(va) + (pte_t *)KADDR(PTE_ADDR(*pde));
f0101953:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101958:	89 c2                	mov    %eax,%edx
f010195a:	c1 ea 0c             	shr    $0xc,%edx
f010195d:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f0101963:	72 20                	jb     f0101985 <pgdir_walk+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101965:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101969:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0101970:	f0 
f0101971:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
f0101978:	00 
f0101979:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101980:	e8 00 e7 ff ff       	call   f0100085 <_panic>
f0101985:	c1 eb 0a             	shr    $0xa,%ebx
f0101988:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010198e:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
		return pte;
f0101995:	eb 78                	jmp    f0101a0f <pgdir_walk+0xdc>
	}
	else if (create == 0)
f0101997:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010199b:	74 6d                	je     f0101a0a <pgdir_walk+0xd7>
		return NULL;
	else{
		struct Page* pp = page_alloc(ALLOC_ZERO);
f010199d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019a4:	e8 06 ff ff ff       	call   f01018af <page_alloc>
		if (pp == NULL)
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	74 5d                	je     f0101a0a <pgdir_walk+0xd7>
			return NULL;
		else{
			pp->pp_ref = 1;
f01019ad:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			physaddr_t physaddr = page2pa(pp);
			*pde = physaddr | PTE_U | PTE_W | PTE_P;
f01019b3:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f01019b9:	c1 f8 03             	sar    $0x3,%eax
f01019bc:	c1 e0 0c             	shl    $0xc,%eax
f01019bf:	83 c8 07             	or     $0x7,%eax
f01019c2:	89 06                	mov    %eax,(%esi)
			pte_t *pte = PTX(va) + (pte_t *)KADDR(PTE_ADDR(*pde));
f01019c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019c9:	89 c2                	mov    %eax,%edx
f01019cb:	c1 ea 0c             	shr    $0xc,%edx
f01019ce:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f01019d4:	72 20                	jb     f01019f6 <pgdir_walk+0xc3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019da:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01019e1:	f0 
f01019e2:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f01019e9:	00 
f01019ea:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01019f1:	e8 8f e6 ff ff       	call   f0100085 <_panic>
f01019f6:	c1 eb 0a             	shr    $0xa,%ebx
f01019f9:	89 da                	mov    %ebx,%edx
f01019fb:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101a01:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
			return pte;
f0101a08:	eb 05                	jmp    f0101a0f <pgdir_walk+0xdc>
f0101a0a:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}	  
	//return NULL;
}
f0101a0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101a12:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101a15:	89 ec                	mov    %ebp,%esp
f0101a17:	5d                   	pop    %ebp
f0101a18:	c3                   	ret    

f0101a19 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101a19:	55                   	push   %ebp
f0101a1a:	89 e5                	mov    %esp,%ebp
f0101a1c:	57                   	push   %edi
f0101a1d:	56                   	push   %esi
f0101a1e:	53                   	push   %ebx
f0101a1f:	83 ec 2c             	sub    $0x2c,%esp
f0101a22:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	uintptr_t start = (uintptr_t)va;
f0101a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uintptr_t end = (uintptr_t)va + len;
f0101a28:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a2b:	01 d8                	add    %ebx,%eax
f0101a2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	perm |= PTE_P;
f0101a30:	8b 7d 14             	mov    0x14(%ebp),%edi
f0101a33:	83 cf 01             	or     $0x1,%edi
	int r = 0;
	while (start < end){
f0101a36:	39 c3                	cmp    %eax,%ebx
f0101a38:	73 66                	jae    f0101aa0 <user_mem_check+0x87>
		if (start > ULIM){
f0101a3a:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0101a40:	76 1d                	jbe    f0101a5f <user_mem_check+0x46>
f0101a42:	eb 0e                	jmp    f0101a52 <user_mem_check+0x39>
f0101a44:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a50:	76 0d                	jbe    f0101a5f <user_mem_check+0x46>
			user_mem_check_addr = start;
f0101a52:	89 1d 58 32 23 f0    	mov    %ebx,0xf0233258
f0101a58:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			r = -E_FAULT;
			break;
f0101a5d:	eb 46                	jmp    f0101aa5 <user_mem_check+0x8c>
		}
		pte_t* pte = pgdir_walk(env->env_pgdir, (void*)start, 0);
f0101a5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a66:	00 
f0101a67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a6b:	8b 46 64             	mov    0x64(%esi),%eax
f0101a6e:	89 04 24             	mov    %eax,(%esp)
f0101a71:	e8 bd fe ff ff       	call   f0101933 <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm){
f0101a76:	85 c0                	test   %eax,%eax
f0101a78:	74 08                	je     f0101a82 <user_mem_check+0x69>
f0101a7a:	8b 00                	mov    (%eax),%eax
f0101a7c:	21 f8                	and    %edi,%eax
f0101a7e:	39 c7                	cmp    %eax,%edi
f0101a80:	74 0d                	je     f0101a8f <user_mem_check+0x76>
			user_mem_check_addr = start;
f0101a82:	89 1d 58 32 23 f0    	mov    %ebx,0xf0233258
f0101a88:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			r = -E_FAULT;
			break;
f0101a8d:	eb 16                	jmp    f0101aa5 <user_mem_check+0x8c>
		}
		start = ROUNDDOWN(start+PGSIZE, PGSIZE);
f0101a8f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101a95:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	/*stone's solution for lab3-B*/
	uintptr_t start = (uintptr_t)va;
	uintptr_t end = (uintptr_t)va + len;
	perm |= PTE_P;
	int r = 0;
	while (start < end){
f0101a9b:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101a9e:	77 a4                	ja     f0101a44 <user_mem_check+0x2b>
f0101aa0:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
		}
		start = ROUNDDOWN(start+PGSIZE, PGSIZE);
	}
	return r;
}
f0101aa5:	83 c4 2c             	add    $0x2c,%esp
f0101aa8:	5b                   	pop    %ebx
f0101aa9:	5e                   	pop    %esi
f0101aaa:	5f                   	pop    %edi
f0101aab:	5d                   	pop    %ebp
f0101aac:	c3                   	ret    

f0101aad <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101aad:	55                   	push   %ebp
f0101aae:	89 e5                	mov    %esp,%ebp
f0101ab0:	53                   	push   %ebx
f0101ab1:	83 ec 14             	sub    $0x14,%esp
f0101ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101ab7:	8b 45 14             	mov    0x14(%ebp),%eax
f0101aba:	83 c8 04             	or     $0x4,%eax
f0101abd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ac1:	8b 45 10             	mov    0x10(%ebp),%eax
f0101ac4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101acf:	89 1c 24             	mov    %ebx,(%esp)
f0101ad2:	e8 42 ff ff ff       	call   f0101a19 <user_mem_check>
f0101ad7:	85 c0                	test   %eax,%eax
f0101ad9:	79 24                	jns    f0101aff <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101adb:	a1 58 32 23 f0       	mov    0xf0233258,%eax
f0101ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ae4:	8b 43 48             	mov    0x48(%ebx),%eax
f0101ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101aeb:	c7 04 24 f8 61 10 f0 	movl   $0xf01061f8,(%esp)
f0101af2:	e8 40 17 00 00       	call   f0103237 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101af7:	89 1c 24             	mov    %ebx,(%esp)
f0101afa:	e8 12 11 00 00       	call   f0102c11 <env_destroy>
	}
}
f0101aff:	83 c4 14             	add    $0x14,%esp
f0101b02:	5b                   	pop    %ebx
f0101b03:	5d                   	pop    %ebp
f0101b04:	c3                   	ret    

f0101b05 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101b05:	55                   	push   %ebp
f0101b06:	89 e5                	mov    %esp,%ebp
f0101b08:	53                   	push   %ebx
f0101b09:	83 ec 14             	sub    $0x14,%esp
f0101b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t* pte = pgdir_walk(pgdir, (void *)va, 0);
f0101b0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b16:	00 
f0101b17:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b21:	89 04 24             	mov    %eax,(%esp)
f0101b24:	e8 0a fe ff ff       	call   f0101933 <pgdir_walk>
	if (pte_store != 0)
f0101b29:	85 db                	test   %ebx,%ebx
f0101b2b:	74 02                	je     f0101b2f <page_lookup+0x2a>
		*pte_store = pte;
f0101b2d:	89 03                	mov    %eax,(%ebx)
	//stone: here i miss "pte != NULL" and debug for a long time, it's important cuz "*pte & PTE_P" only means the page is not presented, 
	//but not mean *pte present or not.
	if ((pte != NULL) && (*pte & PTE_P)){
f0101b2f:	85 c0                	test   %eax,%eax
f0101b31:	74 38                	je     f0101b6b <page_lookup+0x66>
f0101b33:	8b 00                	mov    (%eax),%eax
f0101b35:	a8 01                	test   $0x1,%al
f0101b37:	74 32                	je     f0101b6b <page_lookup+0x66>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b39:	c1 e8 0c             	shr    $0xc,%eax
f0101b3c:	3b 05 a8 3e 23 f0    	cmp    0xf0233ea8,%eax
f0101b42:	72 1c                	jb     f0101b60 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101b44:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0101b4b:	f0 
f0101b4c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101b53:	00 
f0101b54:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0101b5b:	e8 25 e5 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101b60:	c1 e0 03             	shl    $0x3,%eax
f0101b63:	03 05 b0 3e 23 f0    	add    0xf0233eb0,%eax
		struct Page* result = pa2page(PTE_ADDR(*pte));
		return result;
f0101b69:	eb 05                	jmp    f0101b70 <page_lookup+0x6b>
f0101b6b:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	else 
		return NULL;
}
f0101b70:	83 c4 14             	add    $0x14,%esp
f0101b73:	5b                   	pop    %ebx
f0101b74:	5d                   	pop    %ebp
f0101b75:	c3                   	ret    

f0101b76 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101b76:	55                   	push   %ebp
f0101b77:	89 e5                	mov    %esp,%ebp
f0101b79:	83 ec 28             	sub    $0x28,%esp
f0101b7c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101b7f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101b82:	8b 75 08             	mov    0x8(%ebp),%esi
f0101b85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t* pte;
	struct Page* pp = page_lookup(pgdir, va, &pte);
f0101b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b93:	89 34 24             	mov    %esi,(%esp)
f0101b96:	e8 6a ff ff ff       	call   f0101b05 <page_lookup>
	if (pp != NULL){
f0101b9b:	85 c0                	test   %eax,%eax
f0101b9d:	74 1d                	je     f0101bbc <page_remove+0x46>
		*pte = 0;
f0101b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101ba2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(pp);
f0101ba8:	89 04 24             	mov    %eax,(%esp)
f0101bab:	e8 8c f3 ff ff       	call   f0100f3c <page_decref>
		tlb_invalidate(pgdir, va);		
f0101bb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101bb4:	89 34 24             	mov    %esi,(%esp)
f0101bb7:	e8 63 f4 ff ff       	call   f010101f <tlb_invalidate>
	}
	return;
}
f0101bbc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101bbf:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101bc2:	89 ec                	mov    %ebp,%esp
f0101bc4:	5d                   	pop    %ebp
f0101bc5:	c3                   	ret    

f0101bc6 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101bc6:	55                   	push   %ebp
f0101bc7:	89 e5                	mov    %esp,%ebp
f0101bc9:	83 ec 48             	sub    $0x48,%esp
f0101bcc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101bcf:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101bd2:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101bd5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101bd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101bdb:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101bde:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101be5:	00 
f0101be6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bea:	89 3c 24             	mov    %edi,(%esp)
f0101bed:	e8 41 fd ff ff       	call   f0101933 <pgdir_walk>
f0101bf2:	89 c2                	mov    %eax,%edx
	if (pte == NULL) return -E_NO_MEM;
f0101bf4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101bf9:	85 d2                	test   %edx,%edx
f0101bfb:	74 7b                	je     f0101c78 <page_insert+0xb2>
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101bfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if (pte == NULL) return -E_NO_MEM;

	if (pp == page_lookup(pgdir, va, &pte)){
f0101c00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c03:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c0b:	89 3c 24             	mov    %edi,(%esp)
f0101c0e:	e8 f2 fe ff ff       	call   f0101b05 <page_lookup>
f0101c13:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c16:	39 d8                	cmp    %ebx,%eax
f0101c18:	75 2f                	jne    f0101c49 <page_insert+0x83>
		tlb_invalidate(pgdir, va);
f0101c1a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c1e:	89 3c 24             	mov    %edi,(%esp)
f0101c21:	e8 f9 f3 ff ff       	call   f010101f <tlb_invalidate>
		*pte = page2pa(pp) | perm | PTE_P;
f0101c26:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c29:	83 c8 01             	or     $0x1,%eax
f0101c2c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c2f:	2b 15 b0 3e 23 f0    	sub    0xf0233eb0,%edx
f0101c35:	c1 fa 03             	sar    $0x3,%edx
f0101c38:	c1 e2 0c             	shl    $0xc,%edx
f0101c3b:	09 c2                	or     %eax,%edx
f0101c3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101c40:	89 10                	mov    %edx,(%eax)
f0101c42:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c47:	eb 2f                	jmp    f0101c78 <page_insert+0xb2>
	}
	else{
		page_remove(pgdir, va);
f0101c49:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c4d:	89 3c 24             	mov    %edi,(%esp)
f0101c50:	e8 21 ff ff ff       	call   f0101b76 <page_remove>
		pp->pp_ref++;
f0101c55:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		*pte = page2pa(pp) | perm | PTE_P;
f0101c5a:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c5d:	83 c8 01             	or     $0x1,%eax
f0101c60:	2b 1d b0 3e 23 f0    	sub    0xf0233eb0,%ebx
f0101c66:	c1 fb 03             	sar    $0x3,%ebx
f0101c69:	c1 e3 0c             	shl    $0xc,%ebx
f0101c6c:	09 c3                	or     %eax,%ebx
f0101c6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101c71:	89 18                	mov    %ebx,(%eax)
f0101c73:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return 0;
}
f0101c78:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101c7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101c7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101c81:	89 ec                	mov    %ebp,%esp
f0101c83:	5d                   	pop    %ebp
f0101c84:	c3                   	ret    

f0101c85 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101c85:	55                   	push   %ebp
f0101c86:	89 e5                	mov    %esp,%ebp
f0101c88:	57                   	push   %edi
f0101c89:	56                   	push   %esi
f0101c8a:	53                   	push   %ebx
f0101c8b:	83 ec 2c             	sub    $0x2c,%esp
f0101c8e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
f0101c91:	c1 e9 0c             	shr    $0xc,%ecx
f0101c94:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
f0101c97:	85 c9                	test   %ecx,%ecx
f0101c99:	74 49                	je     f0101ce4 <boot_map_region+0x5f>
f0101c9b:	89 d6                	mov    %edx,%esi
f0101c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
f0101ca2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101ca5:	83 cf 01             	or     $0x1,%edi
f0101ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
f0101cb3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101cba:	00 
f0101cbb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101cbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101cc2:	89 04 24             	mov    %eax,(%esp)
f0101cc5:	e8 69 fc ff ff       	call   f0101933 <pgdir_walk>
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
f0101cca:	89 da                	mov    %ebx,%edx
f0101ccc:	c1 e2 0c             	shl    $0xc,%edx
f0101ccf:	03 55 e4             	add    -0x1c(%ebp),%edx
f0101cd2:	09 fa                	or     %edi,%edx
f0101cd4:	89 10                	mov    %edx,(%eax)
		vaddr = vaddr + PGSIZE;
f0101cd6:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// Fill this function in
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
f0101cdc:	83 c3 01             	add    $0x1,%ebx
f0101cdf:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0101ce2:	77 cf                	ja     f0101cb3 <boot_map_region+0x2e>
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
		vaddr = vaddr + PGSIZE;
	}
}
f0101ce4:	83 c4 2c             	add    $0x2c,%esp
f0101ce7:	5b                   	pop    %ebx
f0101ce8:	5e                   	pop    %esi
f0101ce9:	5f                   	pop    %edi
f0101cea:	5d                   	pop    %ebp
f0101ceb:	c3                   	ret    

f0101cec <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101cec:	55                   	push   %ebp
f0101ced:	89 e5                	mov    %esp,%ebp
f0101cef:	57                   	push   %edi
f0101cf0:	56                   	push   %esi
f0101cf1:	53                   	push   %ebx
f0101cf2:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101cf5:	b8 15 00 00 00       	mov    $0x15,%eax
f0101cfa:	e8 55 f3 ff ff       	call   f0101054 <nvram_read>
f0101cff:	c1 e0 0a             	shl    $0xa,%eax
f0101d02:	89 c2                	mov    %eax,%edx
f0101d04:	c1 fa 1f             	sar    $0x1f,%edx
f0101d07:	c1 ea 14             	shr    $0x14,%edx
f0101d0a:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101d0d:	c1 f8 0c             	sar    $0xc,%eax
f0101d10:	a3 4c 32 23 f0       	mov    %eax,0xf023324c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101d15:	b8 17 00 00 00       	mov    $0x17,%eax
f0101d1a:	e8 35 f3 ff ff       	call   f0101054 <nvram_read>
f0101d1f:	c1 e0 0a             	shl    $0xa,%eax
f0101d22:	89 c2                	mov    %eax,%edx
f0101d24:	c1 fa 1f             	sar    $0x1f,%edx
f0101d27:	c1 ea 14             	shr    $0x14,%edx
f0101d2a:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101d2d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101d30:	85 c0                	test   %eax,%eax
f0101d32:	74 0e                	je     f0101d42 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101d34:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101d3a:	89 15 a8 3e 23 f0    	mov    %edx,0xf0233ea8
f0101d40:	eb 0c                	jmp    f0101d4e <mem_init+0x62>
	else
		npages = npages_basemem;
f0101d42:	8b 15 4c 32 23 f0    	mov    0xf023324c,%edx
f0101d48:	89 15 a8 3e 23 f0    	mov    %edx,0xf0233ea8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101d4e:	c1 e0 0c             	shl    $0xc,%eax
f0101d51:	c1 e8 0a             	shr    $0xa,%eax
f0101d54:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d58:	a1 4c 32 23 f0       	mov    0xf023324c,%eax
f0101d5d:	c1 e0 0c             	shl    $0xc,%eax
f0101d60:	c1 e8 0a             	shr    $0xa,%eax
f0101d63:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101d67:	a1 a8 3e 23 f0       	mov    0xf0233ea8,%eax
f0101d6c:	c1 e0 0c             	shl    $0xc,%eax
f0101d6f:	c1 e8 0a             	shr    $0xa,%eax
f0101d72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d76:	c7 04 24 50 62 10 f0 	movl   $0xf0106250,(%esp)
f0101d7d:	e8 b5 14 00 00       	call   f0103237 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101d82:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101d87:	e8 ed f5 ff ff       	call   f0101379 <boot_alloc>
f0101d8c:	a3 ac 3e 23 f0       	mov    %eax,0xf0233eac
	memset(kern_pgdir, 0, PGSIZE);
f0101d91:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d98:	00 
f0101d99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101da0:	00 
f0101da1:	89 04 24             	mov    %eax,(%esp)
f0101da4:	e8 8d 2e 00 00       	call   f0104c36 <memset>
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	//user writeable
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101da9:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101dae:	89 c2                	mov    %eax,%edx
f0101db0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101db5:	77 20                	ja     f0101dd7 <mem_init+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101db7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101dbb:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0101dc2:	f0 
f0101dc3:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0101dca:	00 
f0101dcb:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101dd2:	e8 ae e2 ff ff       	call   f0100085 <_panic>
f0101dd7:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101ddd:	83 ca 05             	or     $0x5,%edx
f0101de0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
//<<<<<<< HEAD
	/*stone's solution for lab2*/
	pages = (struct Page*) boot_alloc(npages * sizeof(struct Page));
f0101de6:	a1 a8 3e 23 f0       	mov    0xf0233ea8,%eax
f0101deb:	c1 e0 03             	shl    $0x3,%eax
f0101dee:	e8 86 f5 ff ff       	call   f0101379 <boot_alloc>
f0101df3:	a3 b0 3e 23 f0       	mov    %eax,0xf0233eb0

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101df8:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101dfd:	e8 77 f5 ff ff       	call   f0101379 <boot_alloc>
f0101e02:	a3 5c 32 23 f0       	mov    %eax,0xf023325c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101e07:	e8 16 f6 ff ff       	call   f0101422 <page_init>

	check_page_free_list(1);
f0101e0c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e11:	e8 f5 f6 ff ff       	call   f010150b <check_page_free_list>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	/*stone's solution for lab2*/
	//RO pages for PTSIZE
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0101e16:	a1 b0 3e 23 f0       	mov    0xf0233eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101e1b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e20:	77 20                	ja     f0101e42 <mem_init+0x156>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101e22:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e26:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0101e2d:	f0 
f0101e2e:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0101e35:	00 
f0101e36:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101e3d:	e8 43 e2 ff ff       	call   f0100085 <_panic>
f0101e42:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0101e49:	00 
f0101e4a:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0101e50:	89 04 24             	mov    %eax,(%esp)
f0101e53:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101e58:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101e5d:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0101e62:	e8 1e fe ff ff       	call   f0101c85 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0101e67:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101e6c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e71:	77 20                	ja     f0101e93 <mem_init+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101e73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e77:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0101e86:	00 
f0101e87:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101e8e:	e8 f2 e1 ff ff       	call   f0100085 <_panic>
f0101e93:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0101e9a:	00 
f0101e9b:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0101ea1:	89 04 24             	mov    %eax,(%esp)
f0101ea4:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0101ea9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101eae:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0101eb3:	e8 cd fd ff ff       	call   f0101c85 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101eb8:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0101ebd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101ec2:	77 20                	ja     f0101ee4 <mem_init+0x1f8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101ec4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ec8:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0101ecf:	f0 
f0101ed0:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
f0101ed7:	00 
f0101ed8:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101edf:	e8 a1 e1 ff ff       	call   f0100085 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	/*stone's solution for lab2*/
	//kernel stack for 8*PGSIZE
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
f0101ee4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0101eeb:	00 
f0101eec:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ef1:	89 04 24             	mov    %eax,(%esp)
f0101ef4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101ef9:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0101efe:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0101f03:	e8 7d fd ff ff       	call   f0101c85 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(0xFFFFFFFF - KERNBASE, PGSIZE), 0, PTE_P | PTE_W);
f0101f08:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0101f0f:	00 
f0101f10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f17:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101f1c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101f21:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0101f26:	e8 5a fd ff ff       	call   f0101c85 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0101f2b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101f32:	00 
f0101f33:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f0101f3a:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0101f3f:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0101f44:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0101f49:	e8 37 fd ff ff       	call   f0101c85 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101f4e:	c7 45 dc 00 50 23 f0 	movl   $0xf0235000,-0x24(%ebp)
f0101f55:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f0101f5c:	0f 87 0d 08 00 00    	ja     f010276f <mem_init+0xa83>
f0101f62:	b8 00 50 23 f0       	mov    $0xf0235000,%eax
f0101f67:	eb 10                	jmp    f0101f79 <mem_init+0x28d>
	size_t pos = KSTACKTOP - KSTKSIZE;
	size_t gap = KSTKSIZE + KSTKGAP;
	size_t i = 0;
	for(; i < NCPU; i++){
		boot_map_region(kern_pgdir, pos, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_P | PTE_W);
		pos = pos - gap;
f0101f69:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0101f6f:	89 d8                	mov    %ebx,%eax
f0101f71:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101f77:	77 20                	ja     f0101f99 <mem_init+0x2ad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f7d:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0101f8c:	00 
f0101f8d:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0101f94:	e8 ec e0 ff ff       	call   f0100085 <_panic>
	/*stone's solution for lab4-A*/
	size_t pos = KSTACKTOP - KSTKSIZE;
	size_t gap = KSTKSIZE + KSTKGAP;
	size_t i = 0;
	for(; i < NCPU; i++){
		boot_map_region(kern_pgdir, pos, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_P | PTE_W);
f0101f99:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0101fa0:	00 
f0101fa1:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0101fa7:	89 04 24             	mov    %eax,(%esp)
f0101faa:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101faf:	89 f2                	mov    %esi,%edx
f0101fb1:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0101fb6:	e8 ca fc ff ff       	call   f0101c85 <boot_map_region>
f0101fbb:	81 c3 00 80 00 00    	add    $0x8000,%ebx
	// LAB 4: Your code here:
	/*stone's solution for lab4-A*/
	size_t pos = KSTACKTOP - KSTKSIZE;
	size_t gap = KSTKSIZE + KSTKGAP;
	size_t i = 0;
	for(; i < NCPU; i++){
f0101fc1:	81 fe 00 80 b8 ef    	cmp    $0xefb88000,%esi
f0101fc7:	75 a0                	jne    f0101f69 <mem_init+0x27d>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0101fc9:	8b 35 ac 3e 23 f0    	mov    0xf0233eac,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0101fcf:	a1 a8 3e 23 f0       	mov    0xf0233ea8,%eax
f0101fd4:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0101fdb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101fe1:	74 79                	je     f010205c <mem_init+0x370>
f0101fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101fe8:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101fee:	89 f0                	mov    %esi,%eax
f0101ff0:	e8 1e f3 ff ff       	call   f0101313 <check_va2pa>
f0101ff5:	8b 15 b0 3e 23 f0    	mov    0xf0233eb0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101ffb:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102001:	77 20                	ja     f0102023 <mem_init+0x337>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102003:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102007:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f010200e:	f0 
f010200f:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102016:	00 
f0102017:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010201e:	e8 62 e0 ff ff       	call   f0100085 <_panic>
f0102023:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f010202a:	39 d0                	cmp    %edx,%eax
f010202c:	74 24                	je     f0102052 <mem_init+0x366>
f010202e:	c7 44 24 0c 8c 62 10 	movl   $0xf010628c,0xc(%esp)
f0102035:	f0 
f0102036:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f010203d:	f0 
f010203e:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102045:	00 
f0102046:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010204d:	e8 33 e0 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102052:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102058:	39 df                	cmp    %ebx,%edi
f010205a:	77 8c                	ja     f0101fe8 <mem_init+0x2fc>
f010205c:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102061:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0102067:	89 f0                	mov    %esi,%eax
f0102069:	e8 a5 f2 ff ff       	call   f0101313 <check_va2pa>
f010206e:	8b 15 5c 32 23 f0    	mov    0xf023325c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102074:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010207a:	77 20                	ja     f010209c <mem_init+0x3b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010207c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102080:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0102087:	f0 
f0102088:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f010208f:	00 
f0102090:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102097:	e8 e9 df ff ff       	call   f0100085 <_panic>
f010209c:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f01020a3:	39 d0                	cmp    %edx,%eax
f01020a5:	74 24                	je     f01020cb <mem_init+0x3df>
f01020a7:	c7 44 24 0c c0 62 10 	movl   $0xf01062c0,0xc(%esp)
f01020ae:	f0 
f01020af:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01020b6:	f0 
f01020b7:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f01020be:	00 
f01020bf:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01020c6:	e8 ba df ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01020cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01020d1:	81 fb 00 00 02 00    	cmp    $0x20000,%ebx
f01020d7:	75 88                	jne    f0102061 <mem_init+0x375>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01020d9:	a1 a8 3e 23 f0       	mov    0xf0233ea8,%eax
f01020de:	c1 e0 0c             	shl    $0xc,%eax
f01020e1:	85 c0                	test   %eax,%eax
f01020e3:	74 4c                	je     f0102131 <mem_init+0x445>
f01020e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01020ea:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01020f0:	89 f0                	mov    %esi,%eax
f01020f2:	e8 1c f2 ff ff       	call   f0101313 <check_va2pa>
f01020f7:	39 c3                	cmp    %eax,%ebx
f01020f9:	74 24                	je     f010211f <mem_init+0x433>
f01020fb:	c7 44 24 0c f4 62 10 	movl   $0xf01062f4,0xc(%esp)
f0102102:	f0 
f0102103:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f010210a:	f0 
f010210b:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102112:	00 
f0102113:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010211a:	e8 66 df ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010211f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102125:	a1 a8 3e 23 f0       	mov    0xf0233ea8,%eax
f010212a:	c1 e0 0c             	shl    $0xc,%eax
f010212d:	39 c3                	cmp    %eax,%ebx
f010212f:	72 b9                	jb     f01020ea <mem_init+0x3fe>
f0102131:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0102136:	89 da                	mov    %ebx,%edx
f0102138:	89 f0                	mov    %esi,%eax
f010213a:	e8 d4 f1 ff ff       	call   f0101313 <check_va2pa>
f010213f:	39 c3                	cmp    %eax,%ebx
f0102141:	74 24                	je     f0102167 <mem_init+0x47b>
f0102143:	c7 44 24 0c 40 65 10 	movl   $0xf0106540,0xc(%esp)
f010214a:	f0 
f010214b:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102152:	f0 
f0102153:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f010215a:	00 
f010215b:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102162:	e8 1e df ff ff       	call   f0100085 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0102167:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010216d:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0102173:	75 c1                	jne    f0102136 <mem_init+0x44a>
f0102175:	c7 45 e0 00 00 bf ef 	movl   $0xefbf0000,-0x20(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010217c:	89 f7                	mov    %esi,%edi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f010217e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102181:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102184:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102187:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010218d:	89 c6                	mov    %eax,%esi
f010218f:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102195:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102198:	05 00 00 01 00       	add    $0x10000,%eax
f010219d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01021a0:	89 da                	mov    %ebx,%edx
f01021a2:	89 f8                	mov    %edi,%eax
f01021a4:	e8 6a f1 ff ff       	call   f0101313 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021a9:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f01021b0:	77 23                	ja     f01021d5 <mem_init+0x4e9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01021b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021b9:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f01021c0:	f0 
f01021c1:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f01021c8:	00 
f01021c9:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01021d0:	e8 b0 de ff ff       	call   f0100085 <_panic>
f01021d5:	39 f0                	cmp    %esi,%eax
f01021d7:	74 24                	je     f01021fd <mem_init+0x511>
f01021d9:	c7 44 24 0c 1c 63 10 	movl   $0xf010631c,0xc(%esp)
f01021e0:	f0 
f01021e1:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01021e8:	f0 
f01021e9:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f01021f0:	00 
f01021f1:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01021f8:	e8 88 de ff ff       	call   f0100085 <_panic>
f01021fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102203:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102209:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010220c:	0f 85 93 05 00 00    	jne    f01027a5 <mem_init+0xab9>
f0102212:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102217:	8b 75 e0             	mov    -0x20(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010221a:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f010221d:	89 f8                	mov    %edi,%eax
f010221f:	e8 ef f0 ff ff       	call   f0101313 <check_va2pa>
f0102224:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102227:	74 24                	je     f010224d <mem_init+0x561>
f0102229:	c7 44 24 0c 64 63 10 	movl   $0xf0106364,0xc(%esp)
f0102230:	f0 
f0102231:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102238:	f0 
f0102239:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102240:	00 
f0102241:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102248:	e8 38 de ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010224d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102253:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102259:	75 bf                	jne    f010221a <mem_init+0x52e>
f010225b:	81 6d e0 00 00 01 00 	subl   $0x10000,-0x20(%ebp)
f0102262:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102269:	81 7d e0 00 00 b7 ef 	cmpl   $0xefb70000,-0x20(%ebp)
f0102270:	0f 85 08 ff ff ff    	jne    f010217e <mem_init+0x492>
f0102276:	89 fe                	mov    %edi,%esi
f0102278:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010227d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102283:	83 fa 03             	cmp    $0x3,%edx
f0102286:	77 2e                	ja     f01022b6 <mem_init+0x5ca>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102288:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010228c:	0f 85 aa 00 00 00    	jne    f010233c <mem_init+0x650>
f0102292:	c7 44 24 0c 5b 65 10 	movl   $0xf010655b,0xc(%esp)
f0102299:	f0 
f010229a:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01022a1:	f0 
f01022a2:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01022a9:	00 
f01022aa:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01022b1:	e8 cf dd ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01022b6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022bb:	76 55                	jbe    f0102312 <mem_init+0x626>
				assert(pgdir[i] & PTE_P);
f01022bd:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01022c0:	f6 c2 01             	test   $0x1,%dl
f01022c3:	75 24                	jne    f01022e9 <mem_init+0x5fd>
f01022c5:	c7 44 24 0c 5b 65 10 	movl   $0xf010655b,0xc(%esp)
f01022cc:	f0 
f01022cd:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01022d4:	f0 
f01022d5:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f01022dc:	00 
f01022dd:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01022e4:	e8 9c dd ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f01022e9:	f6 c2 02             	test   $0x2,%dl
f01022ec:	75 4e                	jne    f010233c <mem_init+0x650>
f01022ee:	c7 44 24 0c 6c 65 10 	movl   $0xf010656c,0xc(%esp)
f01022f5:	f0 
f01022f6:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01022fd:	f0 
f01022fe:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102305:	00 
f0102306:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010230d:	e8 73 dd ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102312:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102316:	74 24                	je     f010233c <mem_init+0x650>
f0102318:	c7 44 24 0c 7d 65 10 	movl   $0xf010657d,0xc(%esp)
f010231f:	f0 
f0102320:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102327:	f0 
f0102328:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010232f:	00 
f0102330:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102337:	e8 49 dd ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010233c:	83 c0 01             	add    $0x1,%eax
f010233f:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102344:	0f 85 33 ff ff ff    	jne    f010227d <mem_init+0x591>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010234a:	c7 04 24 88 63 10 f0 	movl   $0xf0106388,(%esp)
f0102351:	e8 e1 0e 00 00       	call   f0103237 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102356:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010235b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102360:	77 20                	ja     f0102382 <mem_init+0x696>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102362:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102366:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f010236d:	f0 
f010236e:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
f0102375:	00 
f0102376:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010237d:	e8 03 dd ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102382:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102388:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("1");
	check_page_free_list(0);
f010238b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102390:	e8 76 f1 ff ff       	call   f010150b <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102395:	0f 20 c0             	mov    %cr0,%eax
	//cprintf("1");
	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102398:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010239d:	83 e0 f3             	and    $0xfffffff3,%eax
f01023a0:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;
	//cprintf("1");
	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023aa:	e8 00 f5 ff ff       	call   f01018af <page_alloc>
f01023af:	89 c3                	mov    %eax,%ebx
f01023b1:	85 c0                	test   %eax,%eax
f01023b3:	75 24                	jne    f01023d9 <mem_init+0x6ed>
f01023b5:	c7 44 24 0c 8b 65 10 	movl   $0xf010658b,0xc(%esp)
f01023bc:	f0 
f01023bd:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01023c4:	f0 
f01023c5:	c7 44 24 04 3e 05 00 	movl   $0x53e,0x4(%esp)
f01023cc:	00 
f01023cd:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01023d4:	e8 ac dc ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01023d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023e0:	e8 ca f4 ff ff       	call   f01018af <page_alloc>
f01023e5:	89 c7                	mov    %eax,%edi
f01023e7:	85 c0                	test   %eax,%eax
f01023e9:	75 24                	jne    f010240f <mem_init+0x723>
f01023eb:	c7 44 24 0c a1 65 10 	movl   $0xf01065a1,0xc(%esp)
f01023f2:	f0 
f01023f3:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01023fa:	f0 
f01023fb:	c7 44 24 04 3f 05 00 	movl   $0x53f,0x4(%esp)
f0102402:	00 
f0102403:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010240a:	e8 76 dc ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010240f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102416:	e8 94 f4 ff ff       	call   f01018af <page_alloc>
f010241b:	89 c6                	mov    %eax,%esi
f010241d:	85 c0                	test   %eax,%eax
f010241f:	75 24                	jne    f0102445 <mem_init+0x759>
f0102421:	c7 44 24 0c b7 65 10 	movl   $0xf01065b7,0xc(%esp)
f0102428:	f0 
f0102429:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102430:	f0 
f0102431:	c7 44 24 04 40 05 00 	movl   $0x540,0x4(%esp)
f0102438:	00 
f0102439:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102440:	e8 40 dc ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	page_free(pp0);
f0102445:	89 1c 24             	mov    %ebx,(%esp)
f0102448:	e8 d3 ea ff ff       	call   f0100f20 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010244d:	89 f8                	mov    %edi,%eax
f010244f:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f0102455:	c1 f8 03             	sar    $0x3,%eax
f0102458:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010245b:	89 c2                	mov    %eax,%edx
f010245d:	c1 ea 0c             	shr    $0xc,%edx
f0102460:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f0102466:	72 20                	jb     f0102488 <mem_init+0x79c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102468:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010246c:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0102473:	f0 
f0102474:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010247b:	00 
f010247c:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0102483:	e8 fd db ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102488:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010248f:	00 
f0102490:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102497:	00 
f0102498:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010249d:	89 04 24             	mov    %eax,(%esp)
f01024a0:	e8 91 27 00 00       	call   f0104c36 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01024a5:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01024a8:	89 f0                	mov    %esi,%eax
f01024aa:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f01024b0:	c1 f8 03             	sar    $0x3,%eax
f01024b3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024b6:	89 c2                	mov    %eax,%edx
f01024b8:	c1 ea 0c             	shr    $0xc,%edx
f01024bb:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f01024c1:	72 20                	jb     f01024e3 <mem_init+0x7f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024c7:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01024ce:	f0 
f01024cf:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01024d6:	00 
f01024d7:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f01024de:	e8 a2 db ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01024e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ea:	00 
f01024eb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01024f2:	00 
f01024f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f8:	89 04 24             	mov    %eax,(%esp)
f01024fb:	e8 36 27 00 00       	call   f0104c36 <memset>
	//cprintf("1");
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102500:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102507:	00 
f0102508:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010250f:	00 
f0102510:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102514:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0102519:	89 04 24             	mov    %eax,(%esp)
f010251c:	e8 a5 f6 ff ff       	call   f0101bc6 <page_insert>
	//cprintf("1");
	assert(pp1->pp_ref == 1);
f0102521:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102526:	74 24                	je     f010254c <mem_init+0x860>
f0102528:	c7 44 24 0c cd 65 10 	movl   $0xf01065cd,0xc(%esp)
f010252f:	f0 
f0102530:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102537:	f0 
f0102538:	c7 44 24 04 48 05 00 	movl   $0x548,0x4(%esp)
f010253f:	00 
f0102540:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102547:	e8 39 db ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010254c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102553:	01 01 01 
f0102556:	74 24                	je     f010257c <mem_init+0x890>
f0102558:	c7 44 24 0c a8 63 10 	movl   $0xf01063a8,0xc(%esp)
f010255f:	f0 
f0102560:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102567:	f0 
f0102568:	c7 44 24 04 4a 05 00 	movl   $0x54a,0x4(%esp)
f010256f:	00 
f0102570:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102577:	e8 09 db ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010257c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102583:	00 
f0102584:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010258b:	00 
f010258c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102590:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0102595:	89 04 24             	mov    %eax,(%esp)
f0102598:	e8 29 f6 ff ff       	call   f0101bc6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010259d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025a4:	02 02 02 
f01025a7:	74 24                	je     f01025cd <mem_init+0x8e1>
f01025a9:	c7 44 24 0c cc 63 10 	movl   $0xf01063cc,0xc(%esp)
f01025b0:	f0 
f01025b1:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01025b8:	f0 
f01025b9:	c7 44 24 04 4c 05 00 	movl   $0x54c,0x4(%esp)
f01025c0:	00 
f01025c1:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01025c8:	e8 b8 da ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01025cd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025d2:	74 24                	je     f01025f8 <mem_init+0x90c>
f01025d4:	c7 44 24 0c de 65 10 	movl   $0xf01065de,0xc(%esp)
f01025db:	f0 
f01025dc:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01025e3:	f0 
f01025e4:	c7 44 24 04 4d 05 00 	movl   $0x54d,0x4(%esp)
f01025eb:	00 
f01025ec:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01025f3:	e8 8d da ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01025f8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01025fd:	74 24                	je     f0102623 <mem_init+0x937>
f01025ff:	c7 44 24 0c ef 65 10 	movl   $0xf01065ef,0xc(%esp)
f0102606:	f0 
f0102607:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f010260e:	f0 
f010260f:	c7 44 24 04 4e 05 00 	movl   $0x54e,0x4(%esp)
f0102616:	00 
f0102617:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f010261e:	e8 62 da ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102623:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010262a:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010262d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102630:	2b 05 b0 3e 23 f0    	sub    0xf0233eb0,%eax
f0102636:	c1 f8 03             	sar    $0x3,%eax
f0102639:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010263c:	89 c2                	mov    %eax,%edx
f010263e:	c1 ea 0c             	shr    $0xc,%edx
f0102641:	3b 15 a8 3e 23 f0    	cmp    0xf0233ea8,%edx
f0102647:	72 20                	jb     f0102669 <mem_init+0x97d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102649:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010264d:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0102654:	f0 
f0102655:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010265c:	00 
f010265d:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0102664:	e8 1c da ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102669:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102670:	03 03 03 
f0102673:	74 24                	je     f0102699 <mem_init+0x9ad>
f0102675:	c7 44 24 0c f0 63 10 	movl   $0xf01063f0,0xc(%esp)
f010267c:	f0 
f010267d:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 50 05 00 	movl   $0x550,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102694:	e8 ec d9 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102699:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026a0:	00 
f01026a1:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f01026a6:	89 04 24             	mov    %eax,(%esp)
f01026a9:	e8 c8 f4 ff ff       	call   f0101b76 <page_remove>
	assert(pp2->pp_ref == 0);
f01026ae:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026b3:	74 24                	je     f01026d9 <mem_init+0x9ed>
f01026b5:	c7 44 24 0c 00 66 10 	movl   $0xf0106600,0xc(%esp)
f01026bc:	f0 
f01026bd:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f01026c4:	f0 
f01026c5:	c7 44 24 04 52 05 00 	movl   $0x552,0x4(%esp)
f01026cc:	00 
f01026cd:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f01026d4:	e8 ac d9 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026d9:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f01026de:	8b 08                	mov    (%eax),%ecx
f01026e0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026e6:	89 da                	mov    %ebx,%edx
f01026e8:	2b 15 b0 3e 23 f0    	sub    0xf0233eb0,%edx
f01026ee:	c1 fa 03             	sar    $0x3,%edx
f01026f1:	c1 e2 0c             	shl    $0xc,%edx
f01026f4:	39 d1                	cmp    %edx,%ecx
f01026f6:	74 24                	je     f010271c <mem_init+0xa30>
f01026f8:	c7 44 24 0c 1c 64 10 	movl   $0xf010641c,0xc(%esp)
f01026ff:	f0 
f0102700:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102707:	f0 
f0102708:	c7 44 24 04 55 05 00 	movl   $0x555,0x4(%esp)
f010270f:	00 
f0102710:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102717:	e8 69 d9 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f010271c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102722:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102727:	74 24                	je     f010274d <mem_init+0xa61>
f0102729:	c7 44 24 0c 11 66 10 	movl   $0xf0106611,0xc(%esp)
f0102730:	f0 
f0102731:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0102738:	f0 
f0102739:	c7 44 24 04 57 05 00 	movl   $0x557,0x4(%esp)
f0102740:	00 
f0102741:	c7 04 24 7b 64 10 f0 	movl   $0xf010647b,(%esp)
f0102748:	e8 38 d9 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f010274d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	//cprintf("1");
	// free the pages we took
	page_free(pp0);
f0102753:	89 1c 24             	mov    %ebx,(%esp)
f0102756:	e8 c5 e7 ff ff       	call   f0100f20 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010275b:	c7 04 24 44 64 10 f0 	movl   $0xf0106444,(%esp)
f0102762:	e8 d0 0a 00 00       	call   f0103237 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);
	//cprintf("check");
	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102767:	83 c4 2c             	add    $0x2c,%esp
f010276a:	5b                   	pop    %ebx
f010276b:	5e                   	pop    %esi
f010276c:	5f                   	pop    %edi
f010276d:	5d                   	pop    %ebp
f010276e:	c3                   	ret    
	/*stone's solution for lab4-A*/
	size_t pos = KSTACKTOP - KSTKSIZE;
	size_t gap = KSTKSIZE + KSTKGAP;
	size_t i = 0;
	for(; i < NCPU; i++){
		boot_map_region(kern_pgdir, pos, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_P | PTE_W);
f010276f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102776:	00 
f0102777:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010277a:	05 00 00 00 10       	add    $0x10000000,%eax
f010277f:	89 04 24             	mov    %eax,(%esp)
f0102782:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102787:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010278c:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0102791:	e8 ef f4 ff ff       	call   f0101c85 <boot_map_region>
f0102796:	bb 00 d0 23 f0       	mov    $0xf023d000,%ebx
f010279b:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f01027a0:	e9 ca f7 ff ff       	jmp    f0101f6f <mem_init+0x283>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01027a5:	89 da                	mov    %ebx,%edx
f01027a7:	89 f8                	mov    %edi,%eax
f01027a9:	e8 65 eb ff ff       	call   f0101313 <check_va2pa>
f01027ae:	e9 22 fa ff ff       	jmp    f01021d5 <mem_init+0x4e9>
	...

f01027c0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01027c0:	55                   	push   %ebp
f01027c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01027c3:	b8 68 f3 11 f0       	mov    $0xf011f368,%eax
f01027c8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01027cb:	b8 23 00 00 00       	mov    $0x23,%eax
f01027d0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01027d2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01027d4:	b0 10                	mov    $0x10,%al
f01027d6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01027d8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01027da:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01027dc:	ea e3 27 10 f0 08 00 	ljmp   $0x8,$0xf01027e3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01027e3:	b0 00                	mov    $0x0,%al
f01027e5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01027e8:	5d                   	pop    %ebp
f01027e9:	c3                   	ret    

f01027ea <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01027ea:	55                   	push   %ebp
f01027eb:	89 e5                	mov    %esp,%ebp
f01027ed:	83 ec 18             	sub    $0x18,%esp
f01027f0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01027f3:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01027f6:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01027f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01027fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01027ff:	85 c0                	test   %eax,%eax
f0102801:	75 17                	jne    f010281a <envid2env+0x30>
		*env_store = curenv;
f0102803:	e8 d6 2a 00 00       	call   f01052de <cpunum>
f0102808:	6b c0 74             	imul   $0x74,%eax,%eax
f010280b:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102811:	89 06                	mov    %eax,(%esi)
f0102813:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0102818:	eb 69                	jmp    f0102883 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010281a:	89 c3                	mov    %eax,%ebx
f010281c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102822:	c1 e3 07             	shl    $0x7,%ebx
f0102825:	03 1d 5c 32 23 f0    	add    0xf023325c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010282b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010282f:	74 05                	je     f0102836 <envid2env+0x4c>
f0102831:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102834:	74 0d                	je     f0102843 <envid2env+0x59>
		*env_store = 0;
f0102836:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010283c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0102841:	eb 40                	jmp    f0102883 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102843:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102847:	74 33                	je     f010287c <envid2env+0x92>
f0102849:	e8 90 2a 00 00       	call   f01052de <cpunum>
f010284e:	6b c0 74             	imul   $0x74,%eax,%eax
f0102851:	39 98 28 40 23 f0    	cmp    %ebx,-0xfdcbfd8(%eax)
f0102857:	74 23                	je     f010287c <envid2env+0x92>
f0102859:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f010285c:	e8 7d 2a 00 00       	call   f01052de <cpunum>
f0102861:	6b c0 74             	imul   $0x74,%eax,%eax
f0102864:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f010286a:	3b 78 48             	cmp    0x48(%eax),%edi
f010286d:	74 0d                	je     f010287c <envid2env+0x92>
		*env_store = 0;
f010286f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0102875:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f010287a:	eb 07                	jmp    f0102883 <envid2env+0x99>
	}

	*env_store = e;
f010287c:	89 1e                	mov    %ebx,(%esi)
f010287e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102883:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0102886:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102889:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010288c:	89 ec                	mov    %ebp,%esp
f010288e:	5d                   	pop    %ebp
f010288f:	c3                   	ret    

f0102890 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102890:	55                   	push   %ebp
f0102891:	89 e5                	mov    %esp,%ebp
f0102893:	53                   	push   %ebx
f0102894:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102897:	e8 42 2a 00 00       	call   f01052de <cpunum>
f010289c:	6b c0 74             	imul   $0x74,%eax,%eax
f010289f:	8b 98 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%ebx
f01028a5:	e8 34 2a 00 00       	call   f01052de <cpunum>
f01028aa:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01028ad:	8b 65 08             	mov    0x8(%ebp),%esp
f01028b0:	61                   	popa   
f01028b1:	07                   	pop    %es
f01028b2:	1f                   	pop    %ds
f01028b3:	83 c4 08             	add    $0x8,%esp
f01028b6:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01028b7:	c7 44 24 08 22 66 10 	movl   $0xf0106622,0x8(%esp)
f01028be:	f0 
f01028bf:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
f01028c6:	00 
f01028c7:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f01028ce:	e8 b2 d7 ff ff       	call   f0100085 <_panic>

f01028d3 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01028d3:	55                   	push   %ebp
f01028d4:	89 e5                	mov    %esp,%ebp
f01028d6:	56                   	push   %esi
f01028d7:	53                   	push   %ebx
f01028d8:	83 ec 10             	sub    $0x10,%esp
f01028db:	8b 75 08             	mov    0x8(%ebp),%esi
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	//1
	if (curenv == NULL || curenv != e){
f01028de:	e8 fb 29 00 00       	call   f01052de <cpunum>
f01028e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01028e6:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f01028ed:	74 14                	je     f0102903 <env_run+0x30>
f01028ef:	e8 ea 29 00 00       	call   f01052de <cpunum>
f01028f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01028f7:	39 b0 28 40 23 f0    	cmp    %esi,-0xfdcbfd8(%eax)
f01028fd:	0f 84 e1 00 00 00    	je     f01029e4 <env_run+0x111>
		cprintf("env_run:%08x\n", e->env_id);
f0102903:	8b 46 48             	mov    0x48(%esi),%eax
f0102906:	89 44 24 04          	mov    %eax,0x4(%esp)
f010290a:	c7 04 24 39 66 10 f0 	movl   $0xf0106639,(%esp)
f0102911:	e8 21 09 00 00       	call   f0103237 <cprintf>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0102916:	e8 c3 29 00 00       	call   f01052de <cpunum>
f010291b:	6b c0 74             	imul   $0x74,%eax,%eax
f010291e:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0102925:	74 29                	je     f0102950 <env_run+0x7d>
f0102927:	e8 b2 29 00 00       	call   f01052de <cpunum>
f010292c:	6b c0 74             	imul   $0x74,%eax,%eax
f010292f:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102935:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0102939:	75 15                	jne    f0102950 <env_run+0x7d>
			curenv->env_status = ENV_RUNNABLE;
f010293b:	e8 9e 29 00 00       	call   f01052de <cpunum>
f0102940:	6b c0 74             	imul   $0x74,%eax,%eax
f0102943:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102949:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		//may be others
		//if()
		curenv = e;
f0102950:	e8 89 29 00 00       	call   f01052de <cpunum>
f0102955:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f010295a:	6b c0 74             	imul   $0x74,%eax,%eax
f010295d:	89 74 18 08          	mov    %esi,0x8(%eax,%ebx,1)
		cprintf("env_run:%08x\n", curenv->env_id);
f0102961:	e8 78 29 00 00       	call   f01052de <cpunum>
f0102966:	6b c0 74             	imul   $0x74,%eax,%eax
f0102969:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010296d:	8b 40 48             	mov    0x48(%eax),%eax
f0102970:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102974:	c7 04 24 39 66 10 f0 	movl   $0xf0106639,(%esp)
f010297b:	e8 b7 08 00 00       	call   f0103237 <cprintf>
		curenv->env_status = ENV_RUNNING;
f0102980:	e8 59 29 00 00       	call   f01052de <cpunum>
f0102985:	6b c0 74             	imul   $0x74,%eax,%eax
f0102988:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010298c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0102993:	e8 46 29 00 00       	call   f01052de <cpunum>
f0102998:	6b c0 74             	imul   $0x74,%eax,%eax
f010299b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010299f:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f01029a3:	e8 36 29 00 00       	call   f01052de <cpunum>
f01029a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01029ab:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01029af:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029b2:	89 c2                	mov    %eax,%edx
f01029b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029b9:	77 20                	ja     f01029db <env_run+0x108>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029bf:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f01029c6:	f0 
f01029c7:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f01029ce:	00 
f01029cf:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f01029d6:	e8 aa d6 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029db:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01029e1:	0f 22 da             	mov    %edx,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01029e4:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01029eb:	e8 9c 2b 00 00       	call   f010558c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01029f0:	f3 90                	pause  
	}
	/*stone's solution for lab4-A*/
	unlock_kernel();
	//2
	env_pop_tf(&(curenv->env_tf));
f01029f2:	e8 e7 28 00 00       	call   f01052de <cpunum>
f01029f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01029fa:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102a00:	89 04 24             	mov    %eax,(%esp)
f0102a03:	e8 88 fe ff ff       	call   f0102890 <env_pop_tf>

f0102a08 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102a08:	55                   	push   %ebp
f0102a09:	89 e5                	mov    %esp,%ebp
f0102a0b:	57                   	push   %edi
f0102a0c:	56                   	push   %esi
f0102a0d:	53                   	push   %ebx
f0102a0e:	83 ec 2c             	sub    $0x2c,%esp
f0102a11:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102a14:	e8 c5 28 00 00       	call   f01052de <cpunum>
f0102a19:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a1c:	39 b8 28 40 23 f0    	cmp    %edi,-0xfdcbfd8(%eax)
f0102a22:	75 35                	jne    f0102a59 <env_free+0x51>
		lcr3(PADDR(kern_pgdir));
f0102a24:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a2e:	77 20                	ja     f0102a50 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a34:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0102a3b:	f0 
f0102a3c:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0102a43:	00 
f0102a44:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102a4b:	e8 35 d6 ff ff       	call   f0100085 <_panic>
f0102a50:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102a56:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102a59:	8b 5f 48             	mov    0x48(%edi),%ebx
f0102a5c:	e8 7d 28 00 00       	call   f01052de <cpunum>
f0102a61:	6b d0 74             	imul   $0x74,%eax,%edx
f0102a64:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a69:	83 ba 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%edx)
f0102a70:	74 11                	je     f0102a83 <env_free+0x7b>
f0102a72:	e8 67 28 00 00       	call   f01052de <cpunum>
f0102a77:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a7a:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102a80:	8b 40 48             	mov    0x48(%eax),%eax
f0102a83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102a87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a8b:	c7 04 24 47 66 10 f0 	movl   $0xf0106647,(%esp)
f0102a92:	e8 a0 07 00 00       	call   f0103237 <cprintf>
f0102a97:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102aa1:	c1 e0 02             	shl    $0x2,%eax
f0102aa4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102aa7:	8b 47 64             	mov    0x64(%edi),%eax
f0102aaa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102aad:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0102ab0:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102ab6:	0f 84 b8 00 00 00    	je     f0102b74 <env_free+0x16c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102abc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ac2:	89 f0                	mov    %esi,%eax
f0102ac4:	c1 e8 0c             	shr    $0xc,%eax
f0102ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102aca:	3b 05 a8 3e 23 f0    	cmp    0xf0233ea8,%eax
f0102ad0:	72 20                	jb     f0102af2 <env_free+0xea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ad2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102ad6:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f0102ae5:	00 
f0102ae6:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102aed:	e8 93 d5 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102af2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102af5:	c1 e2 16             	shl    $0x16,%edx
f0102af8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102afb:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0102b00:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102b07:	01 
f0102b08:	74 17                	je     f0102b21 <env_free+0x119>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102b0a:	89 d8                	mov    %ebx,%eax
f0102b0c:	c1 e0 0c             	shl    $0xc,%eax
f0102b0f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102b12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b16:	8b 47 64             	mov    0x64(%edi),%eax
f0102b19:	89 04 24             	mov    %eax,(%esp)
f0102b1c:	e8 55 f0 ff ff       	call   f0101b76 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102b21:	83 c3 01             	add    $0x1,%ebx
f0102b24:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102b2a:	75 d4                	jne    f0102b00 <env_free+0xf8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102b2c:	8b 47 64             	mov    0x64(%edi),%eax
f0102b2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102b32:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b39:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102b3c:	3b 05 a8 3e 23 f0    	cmp    0xf0233ea8,%eax
f0102b42:	72 1c                	jb     f0102b60 <env_free+0x158>
		panic("pa2page called with invalid pa");
f0102b44:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0102b4b:	f0 
f0102b4c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0102b53:	00 
f0102b54:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0102b5b:	e8 25 d5 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0102b60:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102b63:	c1 e0 03             	shl    $0x3,%eax
f0102b66:	03 05 b0 3e 23 f0    	add    0xf0233eb0,%eax
f0102b6c:	89 04 24             	mov    %eax,(%esp)
f0102b6f:	e8 c8 e3 ff ff       	call   f0100f3c <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102b74:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102b78:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102b7f:	0f 85 19 ff ff ff    	jne    f0102a9e <env_free+0x96>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102b85:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b88:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b8d:	77 20                	ja     f0102baf <env_free+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b93:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0102b9a:	f0 
f0102b9b:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f0102ba2:	00 
f0102ba3:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102baa:	e8 d6 d4 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0102baf:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb6:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102bbc:	c1 e8 0c             	shr    $0xc,%eax
f0102bbf:	3b 05 a8 3e 23 f0    	cmp    0xf0233ea8,%eax
f0102bc5:	72 1c                	jb     f0102be3 <env_free+0x1db>
		panic("pa2page called with invalid pa");
f0102bc7:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0102bce:	f0 
f0102bcf:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0102bd6:	00 
f0102bd7:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0102bde:	e8 a2 d4 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0102be3:	c1 e0 03             	shl    $0x3,%eax
f0102be6:	03 05 b0 3e 23 f0    	add    0xf0233eb0,%eax
f0102bec:	89 04 24             	mov    %eax,(%esp)
f0102bef:	e8 48 e3 ff ff       	call   f0100f3c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102bf4:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102bfb:	a1 60 32 23 f0       	mov    0xf0233260,%eax
f0102c00:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102c03:	89 3d 60 32 23 f0    	mov    %edi,0xf0233260
}
f0102c09:	83 c4 2c             	add    $0x2c,%esp
f0102c0c:	5b                   	pop    %ebx
f0102c0d:	5e                   	pop    %esi
f0102c0e:	5f                   	pop    %edi
f0102c0f:	5d                   	pop    %ebp
f0102c10:	c3                   	ret    

f0102c11 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0102c11:	55                   	push   %ebp
f0102c12:	89 e5                	mov    %esp,%ebp
f0102c14:	53                   	push   %ebx
f0102c15:	83 ec 14             	sub    $0x14,%esp
f0102c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0102c1b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0102c1f:	75 19                	jne    f0102c3a <env_destroy+0x29>
f0102c21:	e8 b8 26 00 00       	call   f01052de <cpunum>
f0102c26:	6b c0 74             	imul   $0x74,%eax,%eax
f0102c29:	39 98 28 40 23 f0    	cmp    %ebx,-0xfdcbfd8(%eax)
f0102c2f:	74 09                	je     f0102c3a <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0102c31:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0102c38:	eb 2f                	jmp    f0102c69 <env_destroy+0x58>
	}

	env_free(e);
f0102c3a:	89 1c 24             	mov    %ebx,(%esp)
f0102c3d:	e8 c6 fd ff ff       	call   f0102a08 <env_free>

	if (curenv == e) {
f0102c42:	e8 97 26 00 00       	call   f01052de <cpunum>
f0102c47:	6b c0 74             	imul   $0x74,%eax,%eax
f0102c4a:	39 98 28 40 23 f0    	cmp    %ebx,-0xfdcbfd8(%eax)
f0102c50:	75 17                	jne    f0102c69 <env_destroy+0x58>
		curenv = NULL;
f0102c52:	e8 87 26 00 00       	call   f01052de <cpunum>
f0102c57:	6b c0 74             	imul   $0x74,%eax,%eax
f0102c5a:	c7 80 28 40 23 f0 00 	movl   $0x0,-0xfdcbfd8(%eax)
f0102c61:	00 00 00 
		sched_yield();
f0102c64:	e8 17 0f 00 00       	call   f0103b80 <sched_yield>
	}
}
f0102c69:	83 c4 14             	add    $0x14,%esp
f0102c6c:	5b                   	pop    %ebx
f0102c6d:	5d                   	pop    %ebp
f0102c6e:	c3                   	ret    

f0102c6f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102c6f:	55                   	push   %ebp
f0102c70:	89 e5                	mov    %esp,%ebp
f0102c72:	53                   	push   %ebx
f0102c73:	83 ec 14             	sub    $0x14,%esp
	// Set up envs array
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	//cprintf("a\n");
	env_free_list = NULL;
f0102c76:	c7 05 60 32 23 f0 00 	movl   $0x0,0xf0233260
f0102c7d:	00 00 00 
f0102c80:	bb 80 ff 01 00       	mov    $0x1ff80,%ebx
	int i = NENV - 1;
	//cprintf("b\n");
	for (; i >= 0; i--){//for same order
		memset(&(envs[i].env_tf), 0, sizeof(struct Trapframe));
f0102c85:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102c8c:	00 
f0102c8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c94:	00 
f0102c95:	89 d8                	mov    %ebx,%eax
f0102c97:	03 05 5c 32 23 f0    	add    0xf023325c,%eax
f0102c9d:	89 04 24             	mov    %eax,(%esp)
f0102ca0:	e8 91 1f 00 00       	call   f0104c36 <memset>
		//cprintf("c\n");
		envs[i].env_link = env_free_list;
f0102ca5:	8b 15 60 32 23 f0    	mov    0xf0233260,%edx
f0102cab:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102cb0:	89 54 18 44          	mov    %edx,0x44(%eax,%ebx,1)
		envs[i].env_id = 0;
f0102cb4:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102cb9:	c7 44 18 48 00 00 00 	movl   $0x0,0x48(%eax,%ebx,1)
f0102cc0:	00 
		envs[i].env_parent_id = 0;
f0102cc1:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102cc6:	c7 44 18 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ebx,1)
f0102ccd:	00 
		envs[i].env_type = ENV_TYPE_USER;
f0102cce:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102cd3:	c7 44 18 50 00 00 00 	movl   $0x0,0x50(%eax,%ebx,1)
f0102cda:	00 
		envs[i].env_status = ENV_FREE;
f0102cdb:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102ce0:	c7 44 18 54 00 00 00 	movl   $0x0,0x54(%eax,%ebx,1)
f0102ce7:	00 
		envs[i].env_runs = 0;	
f0102ce8:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102ced:	c7 44 18 58 00 00 00 	movl   $0x0,0x58(%eax,%ebx,1)
f0102cf4:	00 
		env_free_list = &envs[i];
f0102cf5:	89 d8                	mov    %ebx,%eax
f0102cf7:	03 05 5c 32 23 f0    	add    0xf023325c,%eax
f0102cfd:	a3 60 32 23 f0       	mov    %eax,0xf0233260
f0102d02:	83 c3 80             	add    $0xffffff80,%ebx
	/*stone's solution for lab3-A*/
	//cprintf("a\n");
	env_free_list = NULL;
	int i = NENV - 1;
	//cprintf("b\n");
	for (; i >= 0; i--){//for same order
f0102d05:	83 fb 80             	cmp    $0xffffff80,%ebx
f0102d08:	0f 85 77 ff ff ff    	jne    f0102c85 <env_init+0x16>
		envs[i].env_runs = 0;	
		env_free_list = &envs[i];
	}
	//cprintf("d\n");
	// Per-CPU part of the initialization
	env_init_percpu();
f0102d0e:	e8 ad fa ff ff       	call   f01027c0 <env_init_percpu>
}
f0102d13:	83 c4 14             	add    $0x14,%esp
f0102d16:	5b                   	pop    %ebx
f0102d17:	5d                   	pop    %ebp
f0102d18:	c3                   	ret    

f0102d19 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102d19:	55                   	push   %ebp
f0102d1a:	89 e5                	mov    %esp,%ebp
f0102d1c:	53                   	push   %ebx
f0102d1d:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102d20:	8b 1d 60 32 23 f0    	mov    0xf0233260,%ebx
f0102d26:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0102d2b:	85 db                	test   %ebx,%ebx
f0102d2d:	0f 84 8d 01 00 00    	je     f0102ec0 <env_alloc+0x1a7>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102d33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102d3a:	e8 70 eb ff ff       	call   f01018af <page_alloc>
f0102d3f:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0102d44:	85 c0                	test   %eax,%eax
f0102d46:	0f 84 74 01 00 00    	je     f0102ec0 <env_alloc+0x1a7>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d4c:	89 c2                	mov    %eax,%edx
f0102d4e:	2b 15 b0 3e 23 f0    	sub    0xf0233eb0,%edx
f0102d54:	c1 fa 03             	sar    $0x3,%edx
f0102d57:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d5a:	89 d1                	mov    %edx,%ecx
f0102d5c:	c1 e9 0c             	shr    $0xc,%ecx
f0102d5f:	3b 0d a8 3e 23 f0    	cmp    0xf0233ea8,%ecx
f0102d65:	72 20                	jb     f0102d87 <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d67:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d6b:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0102d72:	f0 
f0102d73:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102d7a:	00 
f0102d7b:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0102d82:	e8 fe d2 ff ff       	call   f0100085 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/

	e->env_pgdir = page2kva(p);
f0102d87:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d8d:	89 53 64             	mov    %edx,0x64(%ebx)
	p->pp_ref++;
f0102d90:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	memmove(e->env_pgdir, kern_pgdir, PGSIZE); 
f0102d95:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d9c:	00 
f0102d9d:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
f0102da2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102da6:	8b 43 64             	mov    0x64(%ebx),%eax
f0102da9:	89 04 24             	mov    %eax,(%esp)
f0102dac:	e8 e4 1e 00 00       	call   f0104c95 <memmove>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102db1:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db4:	89 c2                	mov    %eax,%edx
f0102db6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dbb:	77 20                	ja     f0102ddd <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dc1:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0102dc8:	f0 
f0102dc9:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0102dd0:	00 
f0102dd1:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102dd8:	e8 a8 d2 ff ff       	call   f0100085 <_panic>
f0102ddd:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102de3:	83 ca 05             	or     $0x5,%edx
f0102de6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102dec:	8b 43 48             	mov    0x48(%ebx),%eax
f0102def:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102df4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102df9:	7f 05                	jg     f0102e00 <env_alloc+0xe7>
f0102dfb:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0102e00:	89 da                	mov    %ebx,%edx
f0102e02:	2b 15 5c 32 23 f0    	sub    0xf023325c,%edx
f0102e08:	c1 fa 07             	sar    $0x7,%edx
f0102e0b:	09 d0                	or     %edx,%eax
f0102e0d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102e10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e13:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102e16:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102e1d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102e24:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102e2b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102e32:	00 
f0102e33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102e3a:	00 
f0102e3b:	89 1c 24             	mov    %ebx,(%esp)
f0102e3e:	e8 f3 1d 00 00       	call   f0104c36 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102e43:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102e49:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102e4f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102e55:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102e5c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102e62:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102e69:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102e70:	8b 43 44             	mov    0x44(%ebx),%eax
f0102e73:	a3 60 32 23 f0       	mov    %eax,0xf0233260
	*newenv_store = e;
f0102e78:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e7b:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e7d:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102e80:	e8 59 24 00 00       	call   f01052de <cpunum>
f0102e85:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e88:	ba 00 00 00 00       	mov    $0x0,%edx
f0102e8d:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0102e94:	74 11                	je     f0102ea7 <env_alloc+0x18e>
f0102e96:	e8 43 24 00 00       	call   f01052de <cpunum>
f0102e9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e9e:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102ea4:	8b 50 48             	mov    0x48(%eax),%edx
f0102ea7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102eab:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102eaf:	c7 04 24 5d 66 10 f0 	movl   $0xf010665d,(%esp)
f0102eb6:	e8 7c 03 00 00       	call   f0103237 <cprintf>
f0102ebb:	ba 00 00 00 00       	mov    $0x0,%edx
	return 0;
}
f0102ec0:	89 d0                	mov    %edx,%eax
f0102ec2:	83 c4 14             	add    $0x14,%esp
f0102ec5:	5b                   	pop    %ebx
f0102ec6:	5d                   	pop    %ebp
f0102ec7:	c3                   	ret    

f0102ec8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ec8:	55                   	push   %ebp
f0102ec9:	89 e5                	mov    %esp,%ebp
f0102ecb:	57                   	push   %edi
f0102ecc:	56                   	push   %esi
f0102ecd:	53                   	push   %ebx
f0102ece:	83 ec 2c             	sub    $0x2c,%esp
f0102ed1:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	/*stone's solution for lab3-A*/
	/*stone's solution for lab3-B(modify)*/
	char* va_start = ROUNDDOWN((char*)va, PGSIZE);
f0102ed3:	89 d0                	mov    %edx,%eax
f0102ed5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* va_end = ROUNDUP((char*)(va + len), PGSIZE);
f0102edd:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102ee4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page* p;
	char* pos = va_start;
	for (; pos < va_end; pos += PGSIZE){
f0102eea:	39 f8                	cmp    %edi,%eax
f0102eec:	73 77                	jae    f0102f65 <region_alloc+0x9d>
f0102eee:	89 c3                	mov    %eax,%ebx
		int r;
		if (!(p = page_alloc(0)))
f0102ef0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ef7:	e8 b3 e9 ff ff       	call   f01018af <page_alloc>
f0102efc:	85 c0                	test   %eax,%eax
f0102efe:	75 1c                	jne    f0102f1c <region_alloc+0x54>
			panic("env_alloc: page alloc failed\n");
f0102f00:	c7 44 24 08 72 66 10 	movl   $0xf0106672,0x8(%esp)
f0102f07:	f0 
f0102f08:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f0102f0f:	00 
f0102f10:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102f17:	e8 69 d1 ff ff       	call   f0100085 <_panic>
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
f0102f1c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0102f23:	00 
f0102f24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102f28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f2c:	8b 46 64             	mov    0x64(%esi),%eax
f0102f2f:	89 04 24             	mov    %eax,(%esp)
f0102f32:	e8 8f ec ff ff       	call   f0101bc6 <page_insert>
f0102f37:	85 c0                	test   %eax,%eax
f0102f39:	79 20                	jns    f0102f5b <region_alloc+0x93>
			panic("env_alloc: %e\n", r);
f0102f3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f3f:	c7 44 24 08 90 66 10 	movl   $0xf0106690,0x8(%esp)
f0102f46:	f0 
f0102f47:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f0102f4e:	00 
f0102f4f:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102f56:	e8 2a d1 ff ff       	call   f0100085 <_panic>
	/*stone's solution for lab3-B(modify)*/
	char* va_start = ROUNDDOWN((char*)va, PGSIZE);
	char* va_end = ROUNDUP((char*)(va + len), PGSIZE);
	struct Page* p;
	char* pos = va_start;
	for (; pos < va_end; pos += PGSIZE){
f0102f5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f61:	39 df                	cmp    %ebx,%edi
f0102f63:	77 8b                	ja     f0102ef0 <region_alloc+0x28>
		if (!(p = page_alloc(0)))
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
	}
	e->env_sbrk_pos = va_start;
f0102f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f68:	89 46 60             	mov    %eax,0x60(%esi)
}
f0102f6b:	83 c4 2c             	add    $0x2c,%esp
f0102f6e:	5b                   	pop    %ebx
f0102f6f:	5e                   	pop    %esi
f0102f70:	5f                   	pop    %edi
f0102f71:	5d                   	pop    %ebp
f0102f72:	c3                   	ret    

f0102f73 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102f73:	55                   	push   %ebp
f0102f74:	89 e5                	mov    %esp,%ebp
f0102f76:	57                   	push   %edi
f0102f77:	56                   	push   %esi
f0102f78:	53                   	push   %ebx
f0102f79:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Env *e;
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
f0102f7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f83:	00 
f0102f84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102f87:	89 04 24             	mov    %eax,(%esp)
f0102f8a:	e8 8a fd ff ff       	call   f0102d19 <env_alloc>
f0102f8f:	85 c0                	test   %eax,%eax
f0102f91:	79 20                	jns    f0102fb3 <env_create+0x40>
		panic("env_alloc: %e\n", r);
f0102f93:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f97:	c7 44 24 08 90 66 10 	movl   $0xf0106690,0x8(%esp)
f0102f9e:	f0 
f0102f9f:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f0102fa6:	00 
f0102fa7:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102fae:	e8 d2 d0 ff ff       	call   f0100085 <_panic>
	else{
		load_icode(e, binary, size);
f0102fb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fb6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Proghdr *ph, *eph;
	struct Elf* elfhdr = (struct Elf*)binary; 
	lcr3(PADDR(e->env_pgdir));
f0102fb9:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fbc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fc1:	77 20                	ja     f0102fe3 <env_create+0x70>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102fc7:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0102fce:	f0 
f0102fcf:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0102fd6:	00 
f0102fd7:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f0102fde:	e8 a2 d0 ff ff       	call   f0100085 <_panic>
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Proghdr *ph, *eph;
	struct Elf* elfhdr = (struct Elf*)binary; 
f0102fe3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102fe6:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102fec:	0f 22 d8             	mov    %eax,%cr3
	lcr3(PADDR(e->env_pgdir));
	// is this a valid ELF?
	if (elfhdr->e_magic != ELF_MAGIC)
f0102fef:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102ff5:	74 1c                	je     f0103013 <env_create+0xa0>
		panic("not a valid ELF\n");
f0102ff7:	c7 44 24 08 9f 66 10 	movl   $0xf010669f,0x8(%esp)
f0102ffe:	f0 
f0102fff:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0103006:	00 
f0103007:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f010300e:	e8 72 d0 ff ff       	call   f0100085 <_panic>
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
f0103013:	89 fb                	mov    %edi,%ebx
f0103015:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f0103018:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010301c:	c1 e6 05             	shl    $0x5,%esi
f010301f:	8d 34 33             	lea    (%ebx,%esi,1),%esi
	for (; ph < eph; ph++){
f0103022:	39 f3                	cmp    %esi,%ebx
f0103024:	73 55                	jae    f010307b <env_create+0x108>
		if (ph->p_type == ELF_PROG_LOAD){
f0103026:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103029:	75 49                	jne    f0103074 <env_create+0x101>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f010302b:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010302e:	8b 53 08             	mov    0x8(%ebx),%edx
f0103031:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103034:	e8 8f fe ff ff       	call   f0102ec8 <region_alloc>
			memmove((void*)ph->p_va, (void*)(binary+ph->p_offset), ph->p_filesz);
f0103039:	8b 43 10             	mov    0x10(%ebx),%eax
f010303c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103040:	8b 45 08             	mov    0x8(%ebp),%eax
f0103043:	03 43 04             	add    0x4(%ebx),%eax
f0103046:	89 44 24 04          	mov    %eax,0x4(%esp)
f010304a:	8b 43 08             	mov    0x8(%ebx),%eax
f010304d:	89 04 24             	mov    %eax,(%esp)
f0103050:	e8 40 1c 00 00       	call   f0104c95 <memmove>
			memset((void*)(ph->p_va+ph->p_filesz), 0, (ph->p_memsz-ph->p_filesz));
f0103055:	8b 43 10             	mov    0x10(%ebx),%eax
f0103058:	8b 53 14             	mov    0x14(%ebx),%edx
f010305b:	29 c2                	sub    %eax,%edx
f010305d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103068:	00 
f0103069:	03 43 08             	add    0x8(%ebx),%eax
f010306c:	89 04 24             	mov    %eax,(%esp)
f010306f:	e8 c2 1b 00 00       	call   f0104c36 <memset>
	if (elfhdr->e_magic != ELF_MAGIC)
		panic("not a valid ELF\n");
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	for (; ph < eph; ph++){
f0103074:	83 c3 20             	add    $0x20,%ebx
f0103077:	39 de                	cmp    %ebx,%esi
f0103079:	77 ab                	ja     f0103026 <env_create+0xb3>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
			memmove((void*)ph->p_va, (void*)(binary+ph->p_offset), ph->p_filesz);
			memset((void*)(ph->p_va+ph->p_filesz), 0, (ph->p_memsz-ph->p_filesz));
		}
	}
	e->env_tf.tf_eip = (uintptr_t)elfhdr->e_entry;
f010307b:	8b 47 18             	mov    0x18(%edi),%eax
f010307e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103081:	89 42 30             	mov    %eax,0x30(%edx)
	lcr3(PADDR(kern_pgdir));
f0103084:	a1 ac 3e 23 f0       	mov    0xf0233eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103089:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010308e:	77 20                	ja     f01030b0 <env_create+0x13d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103090:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103094:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f010309b:	f0 
f010309c:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f01030a3:	00 
f01030a4:	c7 04 24 2e 66 10 f0 	movl   $0xf010662e,(%esp)
f01030ab:	e8 d5 cf ff ff       	call   f0100085 <_panic>
f01030b0:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01030b6:	0f 22 d8             	mov    %eax,%cr3
	
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f01030b9:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01030be:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01030c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01030c6:	e8 fd fd ff ff       	call   f0102ec8 <region_alloc>
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
		panic("env_alloc: %e\n", r);
	else{
		load_icode(e, binary, size);
		e->env_type = type;
f01030cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030ce:	8b 55 10             	mov    0x10(%ebp),%edx
f01030d1:	89 50 50             	mov    %edx,0x50(%eax)
	}
}
f01030d4:	83 c4 3c             	add    $0x3c,%esp
f01030d7:	5b                   	pop    %ebx
f01030d8:	5e                   	pop    %esi
f01030d9:	5f                   	pop    %edi
f01030da:	5d                   	pop    %ebp
f01030db:	c3                   	ret    

f01030dc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01030dc:	55                   	push   %ebp
f01030dd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030df:	ba 70 00 00 00       	mov    $0x70,%edx
f01030e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030e8:	b2 71                	mov    $0x71,%dl
f01030ea:	ec                   	in     (%dx),%al
f01030eb:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01030ee:	5d                   	pop    %ebp
f01030ef:	c3                   	ret    

f01030f0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01030f0:	55                   	push   %ebp
f01030f1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030f3:	ba 70 00 00 00       	mov    $0x70,%edx
f01030f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030fb:	ee                   	out    %al,(%dx)
f01030fc:	b2 71                	mov    $0x71,%dl
f01030fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103101:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103102:	5d                   	pop    %ebp
f0103103:	c3                   	ret    

f0103104 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103104:	55                   	push   %ebp
f0103105:	89 e5                	mov    %esp,%ebp
f0103107:	56                   	push   %esi
f0103108:	53                   	push   %ebx
f0103109:	83 ec 10             	sub    $0x10,%esp
f010310c:	8b 45 08             	mov    0x8(%ebp),%eax
f010310f:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103111:	66 a3 70 f3 11 f0    	mov    %ax,0xf011f370
	if (!didinit)
f0103117:	83 3d 64 32 23 f0 00 	cmpl   $0x0,0xf0233264
f010311e:	74 4e                	je     f010316e <irq_setmask_8259A+0x6a>
f0103120:	ba 21 00 00 00       	mov    $0x21,%edx
f0103125:	ee                   	out    %al,(%dx)
f0103126:	89 f0                	mov    %esi,%eax
f0103128:	66 c1 e8 08          	shr    $0x8,%ax
f010312c:	b2 a1                	mov    $0xa1,%dl
f010312e:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010312f:	c7 04 24 b0 66 10 f0 	movl   $0xf01066b0,(%esp)
f0103136:	e8 fc 00 00 00       	call   f0103237 <cprintf>
f010313b:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0103140:	0f b7 f6             	movzwl %si,%esi
f0103143:	f7 d6                	not    %esi
f0103145:	0f a3 de             	bt     %ebx,%esi
f0103148:	73 10                	jae    f010315a <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010314a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010314e:	c7 04 24 a0 6b 10 f0 	movl   $0xf0106ba0,(%esp)
f0103155:	e8 dd 00 00 00       	call   f0103237 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010315a:	83 c3 01             	add    $0x1,%ebx
f010315d:	83 fb 10             	cmp    $0x10,%ebx
f0103160:	75 e3                	jne    f0103145 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103162:	c7 04 24 28 5b 10 f0 	movl   $0xf0105b28,(%esp)
f0103169:	e8 c9 00 00 00       	call   f0103237 <cprintf>
}
f010316e:	83 c4 10             	add    $0x10,%esp
f0103171:	5b                   	pop    %ebx
f0103172:	5e                   	pop    %esi
f0103173:	5d                   	pop    %ebp
f0103174:	c3                   	ret    

f0103175 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103175:	55                   	push   %ebp
f0103176:	89 e5                	mov    %esp,%ebp
f0103178:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010317b:	c7 05 64 32 23 f0 01 	movl   $0x1,0xf0233264
f0103182:	00 00 00 
f0103185:	ba 21 00 00 00       	mov    $0x21,%edx
f010318a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010318f:	ee                   	out    %al,(%dx)
f0103190:	b2 a1                	mov    $0xa1,%dl
f0103192:	ee                   	out    %al,(%dx)
f0103193:	b2 20                	mov    $0x20,%dl
f0103195:	b8 11 00 00 00       	mov    $0x11,%eax
f010319a:	ee                   	out    %al,(%dx)
f010319b:	b2 21                	mov    $0x21,%dl
f010319d:	b8 20 00 00 00       	mov    $0x20,%eax
f01031a2:	ee                   	out    %al,(%dx)
f01031a3:	b8 04 00 00 00       	mov    $0x4,%eax
f01031a8:	ee                   	out    %al,(%dx)
f01031a9:	b8 03 00 00 00       	mov    $0x3,%eax
f01031ae:	ee                   	out    %al,(%dx)
f01031af:	b2 a0                	mov    $0xa0,%dl
f01031b1:	b8 11 00 00 00       	mov    $0x11,%eax
f01031b6:	ee                   	out    %al,(%dx)
f01031b7:	b2 a1                	mov    $0xa1,%dl
f01031b9:	b8 28 00 00 00       	mov    $0x28,%eax
f01031be:	ee                   	out    %al,(%dx)
f01031bf:	b8 02 00 00 00       	mov    $0x2,%eax
f01031c4:	ee                   	out    %al,(%dx)
f01031c5:	b8 01 00 00 00       	mov    $0x1,%eax
f01031ca:	ee                   	out    %al,(%dx)
f01031cb:	b2 20                	mov    $0x20,%dl
f01031cd:	b8 68 00 00 00       	mov    $0x68,%eax
f01031d2:	ee                   	out    %al,(%dx)
f01031d3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01031d8:	ee                   	out    %al,(%dx)
f01031d9:	b2 a0                	mov    $0xa0,%dl
f01031db:	b8 68 00 00 00       	mov    $0x68,%eax
f01031e0:	ee                   	out    %al,(%dx)
f01031e1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01031e6:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01031e7:	0f b7 05 70 f3 11 f0 	movzwl 0xf011f370,%eax
f01031ee:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01031f2:	74 0b                	je     f01031ff <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01031f4:	0f b7 c0             	movzwl %ax,%eax
f01031f7:	89 04 24             	mov    %eax,(%esp)
f01031fa:	e8 05 ff ff ff       	call   f0103104 <irq_setmask_8259A>
}
f01031ff:	c9                   	leave  
f0103200:	c3                   	ret    
f0103201:	00 00                	add    %al,(%eax)
	...

f0103204 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0103204:	55                   	push   %ebp
f0103205:	89 e5                	mov    %esp,%ebp
f0103207:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010320a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103211:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103214:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103218:	8b 45 08             	mov    0x8(%ebp),%eax
f010321b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010321f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103222:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103226:	c7 04 24 51 32 10 f0 	movl   $0xf0103251,(%esp)
f010322d:	e8 6b 12 00 00       	call   f010449d <vprintfmt>
	return cnt;
}
f0103232:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103235:	c9                   	leave  
f0103236:	c3                   	ret    

f0103237 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103237:	55                   	push   %ebp
f0103238:	89 e5                	mov    %esp,%ebp
f010323a:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f010323d:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103240:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103244:	8b 45 08             	mov    0x8(%ebp),%eax
f0103247:	89 04 24             	mov    %eax,(%esp)
f010324a:	e8 b5 ff ff ff       	call   f0103204 <vcprintf>
	va_end(ap);

	return cnt;
}
f010324f:	c9                   	leave  
f0103250:	c3                   	ret    

f0103251 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103251:	55                   	push   %ebp
f0103252:	89 e5                	mov    %esp,%ebp
f0103254:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103257:	8b 45 08             	mov    0x8(%ebp),%eax
f010325a:	89 04 24             	mov    %eax,(%esp)
f010325d:	e8 88 d4 ff ff       	call   f01006ea <cputchar>
	*cnt++;
}
f0103262:	c9                   	leave  
f0103263:	c3                   	ret    
	...

f0103270 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103270:	55                   	push   %ebp
f0103271:	89 e5                	mov    %esp,%ebp
f0103273:	83 ec 18             	sub    $0x18,%esp
f0103276:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103279:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010327c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	/*stone's solution for lab4-A*/
	size_t id = cpunum();
f010327f:	e8 5a 20 00 00       	call   f01052de <cpunum>
f0103284:	89 c3                	mov    %eax,%ebx
	size_t gap = KSTKSIZE + KSTKGAP;
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//ts.ts_esp0 = KSTACKTOP;
	//ts.ts_ss0 = GD_KD;
	cpus[id].cpu_ts.ts_esp0 = KSTACKTOP - id * gap;
f0103286:	6b f0 74             	imul   $0x74,%eax,%esi
f0103289:	c1 e0 10             	shl    $0x10,%eax
f010328c:	bf 00 00 c0 ef       	mov    $0xefc00000,%edi
f0103291:	29 c7                	sub    %eax,%edi
f0103293:	89 be 30 40 23 f0    	mov    %edi,-0xfdcbfd0(%esi)
	cpus[id].cpu_ts.ts_ss0 = GD_KD;
f0103299:	66 c7 86 34 40 23 f0 	movw   $0x10,-0xfdcbfcc(%esi)
f01032a0:	10 00 
	wrmsr(0x174, GD_KT, 0);
f01032a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01032a7:	b8 08 00 00 00       	mov    $0x8,%eax
f01032ac:	b9 74 01 00 00       	mov    $0x174,%ecx
f01032b1:	0f 30                	wrmsr  
   	wrmsr(0x175, cpus[id].cpu_ts.ts_esp0, 0);
f01032b3:	b1 75                	mov    $0x75,%cl
f01032b5:	89 f8                	mov    %edi,%eax
f01032b7:	0f 30                	wrmsr  
    	wrmsr(0x176, sysenter_handler, 0);
f01032b9:	b8 3a 3b 10 f0       	mov    $0xf0103b3a,%eax
f01032be:	b1 76                	mov    $0x76,%cl
f01032c0:	0f 30                	wrmsr  

	// Initialize the TSS slot of the gdt.
	//gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
	//				sizeof(struct Taskstate), 0);
	//gdt[GD_TSS0 >> 3].sd_s = 0;
	gdt[(GD_TSS0 >> 3) + id] = SEG16(STS_T32A, (uint32_t)(&(cpus[id].cpu_ts)), sizeof(struct Taskstate), 0);
f01032c2:	8d 53 05             	lea    0x5(%ebx),%edx
f01032c5:	81 c6 2c 40 23 f0    	add    $0xf023402c,%esi
f01032cb:	b8 00 f3 11 f0       	mov    $0xf011f300,%eax
f01032d0:	66 c7 04 d0 68 00    	movw   $0x68,(%eax,%edx,8)
f01032d6:	66 89 74 d0 02       	mov    %si,0x2(%eax,%edx,8)
f01032db:	89 f1                	mov    %esi,%ecx
f01032dd:	c1 e9 10             	shr    $0x10,%ecx
f01032e0:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
f01032e4:	c6 44 d0 06 40       	movb   $0x40,0x6(%eax,%edx,8)
f01032e9:	c1 ee 18             	shr    $0x18,%esi
f01032ec:	89 f1                	mov    %esi,%ecx
f01032ee:	88 4c d0 07          	mov    %cl,0x7(%eax,%edx,8)
	gdt[(GD_TSS0 >> 3) + id].sd_s = 0;
f01032f2:	c6 44 d0 05 89       	movb   $0x89,0x5(%eax,%edx,8)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01032f7:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
f01032fe:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103301:	b8 74 f3 11 f0       	mov    $0xf011f374,%eax
f0103306:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	//ltr(GD_TSS0);
	ltr(((GD_TSS0 >> 3) + id) << 3);
	// Load the IDT
	lidt(&idt_pd);
}
f0103309:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010330c:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010330f:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103312:	89 ec                	mov    %ebp,%esp
f0103314:	5d                   	pop    %ebp
f0103315:	c3                   	ret    

f0103316 <trap_init>:
/*stone's solution for lab3-B*/
void sysenter_handler();

void
trap_init(void)
{
f0103316:	55                   	push   %ebp
f0103317:	89 e5                	mov    %esp,%ebp
f0103319:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t0, 0);
f010331c:	b8 dc 3a 10 f0       	mov    $0xf0103adc,%eax
f0103321:	66 a3 80 32 23 f0    	mov    %ax,0xf0233280
f0103327:	66 c7 05 82 32 23 f0 	movw   $0x8,0xf0233282
f010332e:	08 00 
f0103330:	c6 05 84 32 23 f0 00 	movb   $0x0,0xf0233284
f0103337:	c6 05 85 32 23 f0 8e 	movb   $0x8e,0xf0233285
f010333e:	c1 e8 10             	shr    $0x10,%eax
f0103341:	66 a3 86 32 23 f0    	mov    %ax,0xf0233286
	SETGATE(idt[T_DEBUG], 0, GD_KT, t1, 0);
f0103347:	b8 e2 3a 10 f0       	mov    $0xf0103ae2,%eax
f010334c:	66 a3 88 32 23 f0    	mov    %ax,0xf0233288
f0103352:	66 c7 05 8a 32 23 f0 	movw   $0x8,0xf023328a
f0103359:	08 00 
f010335b:	c6 05 8c 32 23 f0 00 	movb   $0x0,0xf023328c
f0103362:	c6 05 8d 32 23 f0 8e 	movb   $0x8e,0xf023328d
f0103369:	c1 e8 10             	shr    $0x10,%eax
f010336c:	66 a3 8e 32 23 f0    	mov    %ax,0xf023328e
	SETGATE(idt[T_NMI], 0, GD_KT, t2, 0);
f0103372:	b8 e8 3a 10 f0       	mov    $0xf0103ae8,%eax
f0103377:	66 a3 90 32 23 f0    	mov    %ax,0xf0233290
f010337d:	66 c7 05 92 32 23 f0 	movw   $0x8,0xf0233292
f0103384:	08 00 
f0103386:	c6 05 94 32 23 f0 00 	movb   $0x0,0xf0233294
f010338d:	c6 05 95 32 23 f0 8e 	movb   $0x8e,0xf0233295
f0103394:	c1 e8 10             	shr    $0x10,%eax
f0103397:	66 a3 96 32 23 f0    	mov    %ax,0xf0233296
	/*stone's solution for lab3-B(modify)*/
	SETGATE(idt[T_BRKPT], 0, GD_KT, t3, 3);
f010339d:	b8 ee 3a 10 f0       	mov    $0xf0103aee,%eax
f01033a2:	66 a3 98 32 23 f0    	mov    %ax,0xf0233298
f01033a8:	66 c7 05 9a 32 23 f0 	movw   $0x8,0xf023329a
f01033af:	08 00 
f01033b1:	c6 05 9c 32 23 f0 00 	movb   $0x0,0xf023329c
f01033b8:	c6 05 9d 32 23 f0 ee 	movb   $0xee,0xf023329d
f01033bf:	c1 e8 10             	shr    $0x10,%eax
f01033c2:	66 a3 9e 32 23 f0    	mov    %ax,0xf023329e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t4, 3);
f01033c8:	b8 f4 3a 10 f0       	mov    $0xf0103af4,%eax
f01033cd:	66 a3 a0 32 23 f0    	mov    %ax,0xf02332a0
f01033d3:	66 c7 05 a2 32 23 f0 	movw   $0x8,0xf02332a2
f01033da:	08 00 
f01033dc:	c6 05 a4 32 23 f0 00 	movb   $0x0,0xf02332a4
f01033e3:	c6 05 a5 32 23 f0 ee 	movb   $0xee,0xf02332a5
f01033ea:	c1 e8 10             	shr    $0x10,%eax
f01033ed:	66 a3 a6 32 23 f0    	mov    %ax,0xf02332a6
	SETGATE(idt[T_BOUND], 0, GD_KT, t5, 0);
f01033f3:	b8 fa 3a 10 f0       	mov    $0xf0103afa,%eax
f01033f8:	66 a3 a8 32 23 f0    	mov    %ax,0xf02332a8
f01033fe:	66 c7 05 aa 32 23 f0 	movw   $0x8,0xf02332aa
f0103405:	08 00 
f0103407:	c6 05 ac 32 23 f0 00 	movb   $0x0,0xf02332ac
f010340e:	c6 05 ad 32 23 f0 8e 	movb   $0x8e,0xf02332ad
f0103415:	c1 e8 10             	shr    $0x10,%eax
f0103418:	66 a3 ae 32 23 f0    	mov    %ax,0xf02332ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, t6, 0);
f010341e:	b8 00 3b 10 f0       	mov    $0xf0103b00,%eax
f0103423:	66 a3 b0 32 23 f0    	mov    %ax,0xf02332b0
f0103429:	66 c7 05 b2 32 23 f0 	movw   $0x8,0xf02332b2
f0103430:	08 00 
f0103432:	c6 05 b4 32 23 f0 00 	movb   $0x0,0xf02332b4
f0103439:	c6 05 b5 32 23 f0 8e 	movb   $0x8e,0xf02332b5
f0103440:	c1 e8 10             	shr    $0x10,%eax
f0103443:	66 a3 b6 32 23 f0    	mov    %ax,0xf02332b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, t7, 0);
f0103449:	b8 06 3b 10 f0       	mov    $0xf0103b06,%eax
f010344e:	66 a3 b8 32 23 f0    	mov    %ax,0xf02332b8
f0103454:	66 c7 05 ba 32 23 f0 	movw   $0x8,0xf02332ba
f010345b:	08 00 
f010345d:	c6 05 bc 32 23 f0 00 	movb   $0x0,0xf02332bc
f0103464:	c6 05 bd 32 23 f0 8e 	movb   $0x8e,0xf02332bd
f010346b:	c1 e8 10             	shr    $0x10,%eax
f010346e:	66 a3 be 32 23 f0    	mov    %ax,0xf02332be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t8, 0);
f0103474:	b8 0c 3b 10 f0       	mov    $0xf0103b0c,%eax
f0103479:	66 a3 c0 32 23 f0    	mov    %ax,0xf02332c0
f010347f:	66 c7 05 c2 32 23 f0 	movw   $0x8,0xf02332c2
f0103486:	08 00 
f0103488:	c6 05 c4 32 23 f0 00 	movb   $0x0,0xf02332c4
f010348f:	c6 05 c5 32 23 f0 8e 	movb   $0x8e,0xf02332c5
f0103496:	c1 e8 10             	shr    $0x10,%eax
f0103499:	66 a3 c6 32 23 f0    	mov    %ax,0xf02332c6
	SETGATE(idt[T_TSS], 0, GD_KT, t10, 0);
f010349f:	b8 10 3b 10 f0       	mov    $0xf0103b10,%eax
f01034a4:	66 a3 d0 32 23 f0    	mov    %ax,0xf02332d0
f01034aa:	66 c7 05 d2 32 23 f0 	movw   $0x8,0xf02332d2
f01034b1:	08 00 
f01034b3:	c6 05 d4 32 23 f0 00 	movb   $0x0,0xf02332d4
f01034ba:	c6 05 d5 32 23 f0 8e 	movb   $0x8e,0xf02332d5
f01034c1:	c1 e8 10             	shr    $0x10,%eax
f01034c4:	66 a3 d6 32 23 f0    	mov    %ax,0xf02332d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t11, 0);
f01034ca:	b8 14 3b 10 f0       	mov    $0xf0103b14,%eax
f01034cf:	66 a3 d8 32 23 f0    	mov    %ax,0xf02332d8
f01034d5:	66 c7 05 da 32 23 f0 	movw   $0x8,0xf02332da
f01034dc:	08 00 
f01034de:	c6 05 dc 32 23 f0 00 	movb   $0x0,0xf02332dc
f01034e5:	c6 05 dd 32 23 f0 8e 	movb   $0x8e,0xf02332dd
f01034ec:	c1 e8 10             	shr    $0x10,%eax
f01034ef:	66 a3 de 32 23 f0    	mov    %ax,0xf02332de
	SETGATE(idt[T_STACK], 0, GD_KT, t12, 0);
f01034f5:	b8 18 3b 10 f0       	mov    $0xf0103b18,%eax
f01034fa:	66 a3 e0 32 23 f0    	mov    %ax,0xf02332e0
f0103500:	66 c7 05 e2 32 23 f0 	movw   $0x8,0xf02332e2
f0103507:	08 00 
f0103509:	c6 05 e4 32 23 f0 00 	movb   $0x0,0xf02332e4
f0103510:	c6 05 e5 32 23 f0 8e 	movb   $0x8e,0xf02332e5
f0103517:	c1 e8 10             	shr    $0x10,%eax
f010351a:	66 a3 e6 32 23 f0    	mov    %ax,0xf02332e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t13, 0);
f0103520:	b8 1c 3b 10 f0       	mov    $0xf0103b1c,%eax
f0103525:	66 a3 e8 32 23 f0    	mov    %ax,0xf02332e8
f010352b:	66 c7 05 ea 32 23 f0 	movw   $0x8,0xf02332ea
f0103532:	08 00 
f0103534:	c6 05 ec 32 23 f0 00 	movb   $0x0,0xf02332ec
f010353b:	c6 05 ed 32 23 f0 8e 	movb   $0x8e,0xf02332ed
f0103542:	c1 e8 10             	shr    $0x10,%eax
f0103545:	66 a3 ee 32 23 f0    	mov    %ax,0xf02332ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, t14, 0);
f010354b:	b8 20 3b 10 f0       	mov    $0xf0103b20,%eax
f0103550:	66 a3 f0 32 23 f0    	mov    %ax,0xf02332f0
f0103556:	66 c7 05 f2 32 23 f0 	movw   $0x8,0xf02332f2
f010355d:	08 00 
f010355f:	c6 05 f4 32 23 f0 00 	movb   $0x0,0xf02332f4
f0103566:	c6 05 f5 32 23 f0 8e 	movb   $0x8e,0xf02332f5
f010356d:	c1 e8 10             	shr    $0x10,%eax
f0103570:	66 a3 f6 32 23 f0    	mov    %ax,0xf02332f6
	SETGATE(idt[T_FPERR], 0, GD_KT, t16, 0);
f0103576:	b8 24 3b 10 f0       	mov    $0xf0103b24,%eax
f010357b:	66 a3 00 33 23 f0    	mov    %ax,0xf0233300
f0103581:	66 c7 05 02 33 23 f0 	movw   $0x8,0xf0233302
f0103588:	08 00 
f010358a:	c6 05 04 33 23 f0 00 	movb   $0x0,0xf0233304
f0103591:	c6 05 05 33 23 f0 8e 	movb   $0x8e,0xf0233305
f0103598:	c1 e8 10             	shr    $0x10,%eax
f010359b:	66 a3 06 33 23 f0    	mov    %ax,0xf0233306
	SETGATE(idt[T_ALIGN], 0, GD_KT, t17, 0);
f01035a1:	b8 2a 3b 10 f0       	mov    $0xf0103b2a,%eax
f01035a6:	66 a3 08 33 23 f0    	mov    %ax,0xf0233308
f01035ac:	66 c7 05 0a 33 23 f0 	movw   $0x8,0xf023330a
f01035b3:	08 00 
f01035b5:	c6 05 0c 33 23 f0 00 	movb   $0x0,0xf023330c
f01035bc:	c6 05 0d 33 23 f0 8e 	movb   $0x8e,0xf023330d
f01035c3:	c1 e8 10             	shr    $0x10,%eax
f01035c6:	66 a3 0e 33 23 f0    	mov    %ax,0xf023330e
	SETGATE(idt[T_MCHK], 0, GD_KT, t18, 0);
f01035cc:	b8 2e 3b 10 f0       	mov    $0xf0103b2e,%eax
f01035d1:	66 a3 10 33 23 f0    	mov    %ax,0xf0233310
f01035d7:	66 c7 05 12 33 23 f0 	movw   $0x8,0xf0233312
f01035de:	08 00 
f01035e0:	c6 05 14 33 23 f0 00 	movb   $0x0,0xf0233314
f01035e7:	c6 05 15 33 23 f0 8e 	movb   $0x8e,0xf0233315
f01035ee:	c1 e8 10             	shr    $0x10,%eax
f01035f1:	66 a3 16 33 23 f0    	mov    %ax,0xf0233316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t19, 0);
f01035f7:	b8 34 3b 10 f0       	mov    $0xf0103b34,%eax
f01035fc:	66 a3 18 33 23 f0    	mov    %ax,0xf0233318
f0103602:	66 c7 05 1a 33 23 f0 	movw   $0x8,0xf023331a
f0103609:	08 00 
f010360b:	c6 05 1c 33 23 f0 00 	movb   $0x0,0xf023331c
f0103612:	c6 05 1d 33 23 f0 8e 	movb   $0x8e,0xf023331d
f0103619:	c1 e8 10             	shr    $0x10,%eax
f010361c:	66 a3 1e 33 23 f0    	mov    %ax,0xf023331e
	/*stone's solution for lab3-B*/
	wrmsr(0x174, GD_KT, 0);
f0103622:	ba 00 00 00 00       	mov    $0x0,%edx
f0103627:	b8 08 00 00 00       	mov    $0x8,%eax
f010362c:	b9 74 01 00 00       	mov    $0x174,%ecx
f0103631:	0f 30                	wrmsr  
   	wrmsr(0x175, KSTACKTOP, 0);
f0103633:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0103638:	b1 75                	mov    $0x75,%cl
f010363a:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f010363c:	b8 3a 3b 10 f0       	mov    $0xf0103b3a,%eax
f0103641:	b1 76                	mov    $0x76,%cl
f0103643:	0f 30                	wrmsr  
	// Per-CPU setup 
	trap_init_percpu();
f0103645:	e8 26 fc ff ff       	call   f0103270 <trap_init_percpu>
}
f010364a:	c9                   	leave  
f010364b:	c3                   	ret    

f010364c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010364c:	55                   	push   %ebp
f010364d:	89 e5                	mov    %esp,%ebp
f010364f:	53                   	push   %ebx
f0103650:	83 ec 14             	sub    $0x14,%esp
f0103653:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103656:	8b 03                	mov    (%ebx),%eax
f0103658:	89 44 24 04          	mov    %eax,0x4(%esp)
f010365c:	c7 04 24 c4 66 10 f0 	movl   $0xf01066c4,(%esp)
f0103663:	e8 cf fb ff ff       	call   f0103237 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103668:	8b 43 04             	mov    0x4(%ebx),%eax
f010366b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010366f:	c7 04 24 d3 66 10 f0 	movl   $0xf01066d3,(%esp)
f0103676:	e8 bc fb ff ff       	call   f0103237 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010367b:	8b 43 08             	mov    0x8(%ebx),%eax
f010367e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103682:	c7 04 24 e2 66 10 f0 	movl   $0xf01066e2,(%esp)
f0103689:	e8 a9 fb ff ff       	call   f0103237 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010368e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103691:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103695:	c7 04 24 f1 66 10 f0 	movl   $0xf01066f1,(%esp)
f010369c:	e8 96 fb ff ff       	call   f0103237 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01036a1:	8b 43 10             	mov    0x10(%ebx),%eax
f01036a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036a8:	c7 04 24 00 67 10 f0 	movl   $0xf0106700,(%esp)
f01036af:	e8 83 fb ff ff       	call   f0103237 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01036b4:	8b 43 14             	mov    0x14(%ebx),%eax
f01036b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036bb:	c7 04 24 0f 67 10 f0 	movl   $0xf010670f,(%esp)
f01036c2:	e8 70 fb ff ff       	call   f0103237 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01036c7:	8b 43 18             	mov    0x18(%ebx),%eax
f01036ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ce:	c7 04 24 1e 67 10 f0 	movl   $0xf010671e,(%esp)
f01036d5:	e8 5d fb ff ff       	call   f0103237 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01036da:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01036dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e1:	c7 04 24 2d 67 10 f0 	movl   $0xf010672d,(%esp)
f01036e8:	e8 4a fb ff ff       	call   f0103237 <cprintf>
}
f01036ed:	83 c4 14             	add    $0x14,%esp
f01036f0:	5b                   	pop    %ebx
f01036f1:	5d                   	pop    %ebp
f01036f2:	c3                   	ret    

f01036f3 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01036f3:	55                   	push   %ebp
f01036f4:	89 e5                	mov    %esp,%ebp
f01036f6:	56                   	push   %esi
f01036f7:	53                   	push   %ebx
f01036f8:	83 ec 10             	sub    $0x10,%esp
f01036fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01036fe:	e8 db 1b 00 00       	call   f01052de <cpunum>
f0103703:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010370b:	c7 04 24 3c 67 10 f0 	movl   $0xf010673c,(%esp)
f0103712:	e8 20 fb ff ff       	call   f0103237 <cprintf>
	print_regs(&tf->tf_regs);
f0103717:	89 1c 24             	mov    %ebx,(%esp)
f010371a:	e8 2d ff ff ff       	call   f010364c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010371f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103723:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103727:	c7 04 24 5a 67 10 f0 	movl   $0xf010675a,(%esp)
f010372e:	e8 04 fb ff ff       	call   f0103237 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103733:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103737:	89 44 24 04          	mov    %eax,0x4(%esp)
f010373b:	c7 04 24 6d 67 10 f0 	movl   $0xf010676d,(%esp)
f0103742:	e8 f0 fa ff ff       	call   f0103237 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103747:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010374a:	83 f8 13             	cmp    $0x13,%eax
f010374d:	77 09                	ja     f0103758 <print_trapframe+0x65>
		return excnames[trapno];
f010374f:	8b 14 85 60 6a 10 f0 	mov    -0xfef95a0(,%eax,4),%edx
f0103756:	eb 1c                	jmp    f0103774 <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f0103758:	ba 80 67 10 f0       	mov    $0xf0106780,%edx
f010375d:	83 f8 30             	cmp    $0x30,%eax
f0103760:	74 12                	je     f0103774 <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103762:	8d 48 e0             	lea    -0x20(%eax),%ecx
f0103765:	ba 9b 67 10 f0       	mov    $0xf010679b,%edx
f010376a:	83 f9 0f             	cmp    $0xf,%ecx
f010376d:	76 05                	jbe    f0103774 <print_trapframe+0x81>
f010376f:	ba 8c 67 10 f0       	mov    $0xf010678c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103774:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010377c:	c7 04 24 ae 67 10 f0 	movl   $0xf01067ae,(%esp)
f0103783:	e8 af fa ff ff       	call   f0103237 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103788:	3b 1d 80 3a 23 f0    	cmp    0xf0233a80,%ebx
f010378e:	75 19                	jne    f01037a9 <print_trapframe+0xb6>
f0103790:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103794:	75 13                	jne    f01037a9 <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103796:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103799:	89 44 24 04          	mov    %eax,0x4(%esp)
f010379d:	c7 04 24 c0 67 10 f0 	movl   $0xf01067c0,(%esp)
f01037a4:	e8 8e fa ff ff       	call   f0103237 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01037a9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01037ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037b0:	c7 04 24 cf 67 10 f0 	movl   $0xf01067cf,(%esp)
f01037b7:	e8 7b fa ff ff       	call   f0103237 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01037bc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01037c0:	75 47                	jne    f0103809 <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01037c2:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01037c5:	be e9 67 10 f0       	mov    $0xf01067e9,%esi
f01037ca:	a8 01                	test   $0x1,%al
f01037cc:	75 05                	jne    f01037d3 <print_trapframe+0xe0>
f01037ce:	be dd 67 10 f0       	mov    $0xf01067dd,%esi
f01037d3:	b9 f9 67 10 f0       	mov    $0xf01067f9,%ecx
f01037d8:	a8 02                	test   $0x2,%al
f01037da:	75 05                	jne    f01037e1 <print_trapframe+0xee>
f01037dc:	b9 f4 67 10 f0       	mov    $0xf01067f4,%ecx
f01037e1:	ba ff 67 10 f0       	mov    $0xf01067ff,%edx
f01037e6:	a8 04                	test   $0x4,%al
f01037e8:	75 05                	jne    f01037ef <print_trapframe+0xfc>
f01037ea:	ba d6 68 10 f0       	mov    $0xf01068d6,%edx
f01037ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01037f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01037f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037fb:	c7 04 24 04 68 10 f0 	movl   $0xf0106804,(%esp)
f0103802:	e8 30 fa ff ff       	call   f0103237 <cprintf>
f0103807:	eb 0c                	jmp    f0103815 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103809:	c7 04 24 28 5b 10 f0 	movl   $0xf0105b28,(%esp)
f0103810:	e8 22 fa ff ff       	call   f0103237 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103815:	8b 43 30             	mov    0x30(%ebx),%eax
f0103818:	89 44 24 04          	mov    %eax,0x4(%esp)
f010381c:	c7 04 24 13 68 10 f0 	movl   $0xf0106813,(%esp)
f0103823:	e8 0f fa ff ff       	call   f0103237 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103828:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010382c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103830:	c7 04 24 22 68 10 f0 	movl   $0xf0106822,(%esp)
f0103837:	e8 fb f9 ff ff       	call   f0103237 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010383c:	8b 43 38             	mov    0x38(%ebx),%eax
f010383f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103843:	c7 04 24 35 68 10 f0 	movl   $0xf0106835,(%esp)
f010384a:	e8 e8 f9 ff ff       	call   f0103237 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010384f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103853:	74 27                	je     f010387c <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103855:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103858:	89 44 24 04          	mov    %eax,0x4(%esp)
f010385c:	c7 04 24 44 68 10 f0 	movl   $0xf0106844,(%esp)
f0103863:	e8 cf f9 ff ff       	call   f0103237 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103868:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010386c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103870:	c7 04 24 53 68 10 f0 	movl   $0xf0106853,(%esp)
f0103877:	e8 bb f9 ff ff       	call   f0103237 <cprintf>
	}
}
f010387c:	83 c4 10             	add    $0x10,%esp
f010387f:	5b                   	pop    %ebx
f0103880:	5e                   	pop    %esi
f0103881:	5d                   	pop    %ebp
f0103882:	c3                   	ret    

f0103883 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103883:	55                   	push   %ebp
f0103884:	89 e5                	mov    %esp,%ebp
f0103886:	83 ec 28             	sub    $0x28,%esp
f0103889:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010388c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010388f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103892:	8b 75 08             	mov    0x8(%ebp),%esi
f0103895:	0f 20 d3             	mov    %cr2,%ebx

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	if (tf->tf_cs == GD_KT)
f0103898:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010389d:	75 1c                	jne    f01038bb <page_fault_handler+0x38>
		panic("Page Fault in kernel");
f010389f:	c7 44 24 08 66 68 10 	movl   $0xf0106866,0x8(%esp)
f01038a6:	f0 
f01038a7:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f01038ae:	00 
f01038af:	c7 04 24 7b 68 10 f0 	movl   $0xf010687b,(%esp)
f01038b6:	e8 ca c7 ff ff       	call   f0100085 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038bb:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01038be:	e8 1b 1a 00 00       	call   f01052de <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038c3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01038c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038cb:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f01038d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d3:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01038d7:	8b 40 48             	mov    0x48(%eax),%eax
f01038da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038de:	c7 04 24 20 6a 10 f0 	movl   $0xf0106a20,(%esp)
f01038e5:	e8 4d f9 ff ff       	call   f0103237 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01038ea:	89 34 24             	mov    %esi,(%esp)
f01038ed:	e8 01 fe ff ff       	call   f01036f3 <print_trapframe>
	env_destroy(curenv);
f01038f2:	e8 e7 19 00 00       	call   f01052de <cpunum>
f01038f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01038fa:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01038fe:	89 04 24             	mov    %eax,(%esp)
f0103901:	e8 0b f3 ff ff       	call   f0102c11 <env_destroy>
}
f0103906:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103909:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010390c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010390f:	89 ec                	mov    %ebp,%esp
f0103911:	5d                   	pop    %ebp
f0103912:	c3                   	ret    

f0103913 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103913:	55                   	push   %ebp
f0103914:	89 e5                	mov    %esp,%ebp
f0103916:	83 ec 28             	sub    $0x28,%esp
f0103919:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010391c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010391f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103922:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103925:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103926:	83 3d a0 3e 23 f0 00 	cmpl   $0x0,0xf0233ea0
f010392d:	74 01                	je     f0103930 <trap+0x1d>
		asm volatile("hlt");
f010392f:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103930:	9c                   	pushf  
f0103931:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103932:	f6 c4 02             	test   $0x2,%ah
f0103935:	74 24                	je     f010395b <trap+0x48>
f0103937:	c7 44 24 0c 87 68 10 	movl   $0xf0106887,0xc(%esp)
f010393e:	f0 
f010393f:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0103946:	f0 
f0103947:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
f010394e:	00 
f010394f:	c7 04 24 7b 68 10 f0 	movl   $0xf010687b,(%esp)
f0103956:	e8 2a c7 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010395b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010395f:	83 e0 03             	and    $0x3,%eax
f0103962:	83 f8 03             	cmp    $0x3,%eax
f0103965:	0f 85 a9 00 00 00    	jne    f0103a14 <trap+0x101>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010396b:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f0103972:	e8 2e 1d 00 00       	call   f01056a5 <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		/*stone's solution for lab4-A*/
		lock_kernel();
		assert(curenv);
f0103977:	e8 62 19 00 00       	call   f01052de <cpunum>
f010397c:	6b c0 74             	imul   $0x74,%eax,%eax
f010397f:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0103986:	75 24                	jne    f01039ac <trap+0x99>
f0103988:	c7 44 24 0c a0 68 10 	movl   $0xf01068a0,0xc(%esp)
f010398f:	f0 
f0103990:	c7 44 24 08 93 64 10 	movl   $0xf0106493,0x8(%esp)
f0103997:	f0 
f0103998:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
f010399f:	00 
f01039a0:	c7 04 24 7b 68 10 f0 	movl   $0xf010687b,(%esp)
f01039a7:	e8 d9 c6 ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01039ac:	e8 2d 19 00 00       	call   f01052de <cpunum>
f01039b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039b4:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f01039ba:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01039be:	75 2e                	jne    f01039ee <trap+0xdb>
			env_free(curenv);
f01039c0:	e8 19 19 00 00       	call   f01052de <cpunum>
f01039c5:	be 20 40 23 f0       	mov    $0xf0234020,%esi
f01039ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01039cd:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01039d1:	89 04 24             	mov    %eax,(%esp)
f01039d4:	e8 2f f0 ff ff       	call   f0102a08 <env_free>
			curenv = NULL;
f01039d9:	e8 00 19 00 00       	call   f01052de <cpunum>
f01039de:	6b c0 74             	imul   $0x74,%eax,%eax
f01039e1:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f01039e8:	00 
			sched_yield();
f01039e9:	e8 92 01 00 00       	call   f0103b80 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01039ee:	e8 eb 18 00 00       	call   f01052de <cpunum>
f01039f3:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f01039f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01039fb:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01039ff:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103a04:	89 c7                	mov    %eax,%edi
f0103a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103a08:	e8 d1 18 00 00       	call   f01052de <cpunum>
f0103a0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a10:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103a14:	89 35 80 3a 23 f0    	mov    %esi,0xf0233a80
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103a1a:	8b 46 28             	mov    0x28(%esi),%eax
f0103a1d:	83 f8 27             	cmp    $0x27,%eax
f0103a20:	75 16                	jne    f0103a38 <trap+0x125>
		cprintf("Spurious interrupt on irq 7\n");
f0103a22:	c7 04 24 a7 68 10 f0 	movl   $0xf01068a7,(%esp)
f0103a29:	e8 09 f8 ff ff       	call   f0103237 <cprintf>
		print_trapframe(tf);
f0103a2e:	89 34 24             	mov    %esi,(%esp)
f0103a31:	e8 bd fc ff ff       	call   f01036f3 <print_trapframe>
f0103a36:	eb 63                	jmp    f0103a9b <trap+0x188>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

//=======
	/*stone's solution for lab3-B*/
	if (tf->tf_trapno == T_PGFLT)
f0103a38:	83 f8 0e             	cmp    $0xe,%eax
f0103a3b:	75 08                	jne    f0103a45 <trap+0x132>
		page_fault_handler(tf);
f0103a3d:	89 34 24             	mov    %esi,(%esp)
f0103a40:	e8 3e fe ff ff       	call   f0103883 <page_fault_handler>
	if (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT)
f0103a45:	8b 46 28             	mov    0x28(%esi),%eax
f0103a48:	83 f8 01             	cmp    $0x1,%eax
f0103a4b:	74 05                	je     f0103a52 <trap+0x13f>
f0103a4d:	83 f8 03             	cmp    $0x3,%eax
f0103a50:	75 08                	jne    f0103a5a <trap+0x147>
		monitor(tf);
f0103a52:	89 34 24             	mov    %esi,(%esp)
f0103a55:	e8 e0 d0 ff ff       	call   f0100b3a <monitor>
	
//>>>>>>> lab3
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103a5a:	89 34 24             	mov    %esi,(%esp)
f0103a5d:	e8 91 fc ff ff       	call   f01036f3 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103a62:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103a67:	75 1c                	jne    f0103a85 <trap+0x172>
		panic("unhandled trap in kernel");
f0103a69:	c7 44 24 08 c4 68 10 	movl   $0xf01068c4,0x8(%esp)
f0103a70:	f0 
f0103a71:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103a78:	00 
f0103a79:	c7 04 24 7b 68 10 f0 	movl   $0xf010687b,(%esp)
f0103a80:	e8 00 c6 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f0103a85:	e8 54 18 00 00       	call   f01052de <cpunum>
f0103a8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a8d:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103a93:	89 04 24             	mov    %eax,(%esp)
f0103a96:	e8 76 f1 ff ff       	call   f0102c11 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103a9b:	e8 3e 18 00 00       	call   f01052de <cpunum>
f0103aa0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aa3:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0103aaa:	74 2a                	je     f0103ad6 <trap+0x1c3>
f0103aac:	e8 2d 18 00 00       	call   f01052de <cpunum>
f0103ab1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ab4:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103aba:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103abe:	75 16                	jne    f0103ad6 <trap+0x1c3>
		env_run(curenv);
f0103ac0:	e8 19 18 00 00       	call   f01052de <cpunum>
f0103ac5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac8:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103ace:	89 04 24             	mov    %eax,(%esp)
f0103ad1:	e8 fd ed ff ff       	call   f01028d3 <env_run>
	else
		sched_yield();
f0103ad6:	e8 a5 00 00 00       	call   f0103b80 <sched_yield>
	...

f0103adc <t0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*stone's solution for lab3-A*/
	TRAPHANDLER_NOEC(t0,  T_DIVIDE);
f0103adc:	6a 00                	push   $0x0
f0103ade:	6a 00                	push   $0x0
f0103ae0:	eb 7e                	jmp    f0103b60 <_alltraps>

f0103ae2 <t1>:
	TRAPHANDLER_NOEC(t1,  T_DEBUG);
f0103ae2:	6a 00                	push   $0x0
f0103ae4:	6a 01                	push   $0x1
f0103ae6:	eb 78                	jmp    f0103b60 <_alltraps>

f0103ae8 <t2>:
	TRAPHANDLER_NOEC(t2,  T_NMI);
f0103ae8:	6a 00                	push   $0x0
f0103aea:	6a 02                	push   $0x2
f0103aec:	eb 72                	jmp    f0103b60 <_alltraps>

f0103aee <t3>:
	TRAPHANDLER_NOEC(t3,  T_BRKPT);
f0103aee:	6a 00                	push   $0x0
f0103af0:	6a 03                	push   $0x3
f0103af2:	eb 6c                	jmp    f0103b60 <_alltraps>

f0103af4 <t4>:
	TRAPHANDLER_NOEC(t4,  T_OFLOW);
f0103af4:	6a 00                	push   $0x0
f0103af6:	6a 04                	push   $0x4
f0103af8:	eb 66                	jmp    f0103b60 <_alltraps>

f0103afa <t5>:
	TRAPHANDLER_NOEC(t5,  T_BOUND);
f0103afa:	6a 00                	push   $0x0
f0103afc:	6a 05                	push   $0x5
f0103afe:	eb 60                	jmp    f0103b60 <_alltraps>

f0103b00 <t6>:
	TRAPHANDLER_NOEC(t6,  T_ILLOP);
f0103b00:	6a 00                	push   $0x0
f0103b02:	6a 06                	push   $0x6
f0103b04:	eb 5a                	jmp    f0103b60 <_alltraps>

f0103b06 <t7>:
	TRAPHANDLER_NOEC(t7,  T_DEVICE);
f0103b06:	6a 00                	push   $0x0
f0103b08:	6a 07                	push   $0x7
f0103b0a:	eb 54                	jmp    f0103b60 <_alltraps>

f0103b0c <t8>:
	TRAPHANDLER	(t8,  T_DBLFLT);
f0103b0c:	6a 08                	push   $0x8
f0103b0e:	eb 50                	jmp    f0103b60 <_alltraps>

f0103b10 <t10>:
	TRAPHANDLER	(t10, T_TSS);
f0103b10:	6a 0a                	push   $0xa
f0103b12:	eb 4c                	jmp    f0103b60 <_alltraps>

f0103b14 <t11>:
	TRAPHANDLER	(t11, T_SEGNP);
f0103b14:	6a 0b                	push   $0xb
f0103b16:	eb 48                	jmp    f0103b60 <_alltraps>

f0103b18 <t12>:
	TRAPHANDLER	(t12, T_STACK);
f0103b18:	6a 0c                	push   $0xc
f0103b1a:	eb 44                	jmp    f0103b60 <_alltraps>

f0103b1c <t13>:
	TRAPHANDLER	(t13, T_GPFLT);
f0103b1c:	6a 0d                	push   $0xd
f0103b1e:	eb 40                	jmp    f0103b60 <_alltraps>

f0103b20 <t14>:
	TRAPHANDLER	(t14, T_PGFLT);
f0103b20:	6a 0e                	push   $0xe
f0103b22:	eb 3c                	jmp    f0103b60 <_alltraps>

f0103b24 <t16>:
	TRAPHANDLER_NOEC(t16, T_FPERR);
f0103b24:	6a 00                	push   $0x0
f0103b26:	6a 10                	push   $0x10
f0103b28:	eb 36                	jmp    f0103b60 <_alltraps>

f0103b2a <t17>:
	TRAPHANDLER	(t17, T_ALIGN);
f0103b2a:	6a 11                	push   $0x11
f0103b2c:	eb 32                	jmp    f0103b60 <_alltraps>

f0103b2e <t18>:
	TRAPHANDLER_NOEC(t18, T_MCHK);
f0103b2e:	6a 00                	push   $0x0
f0103b30:	6a 12                	push   $0x12
f0103b32:	eb 2c                	jmp    f0103b60 <_alltraps>

f0103b34 <t19>:
	TRAPHANDLER_NOEC(t19, T_SIMDERR );
f0103b34:	6a 00                	push   $0x0
f0103b36:	6a 13                	push   $0x13
f0103b38:	eb 26                	jmp    f0103b60 <_alltraps>

f0103b3a <sysenter_handler>:
/*
 * Lab 3: Your code here for system call handling
 */
/*stone's solution for lab3-B*/
	//User Data
	pushl $GD_UD
f0103b3a:	6a 20                	push   $0x20
	pushl %ebp
f0103b3c:	55                   	push   %ebp
	//flag registers
	pushfl
f0103b3d:	9c                   	pushf  
	//User Text
	pushl $GD_UT
f0103b3e:	6a 18                	push   $0x18
	pushl %esi
f0103b40:	56                   	push   %esi
	pushl $0
f0103b41:	6a 00                	push   $0x0
	pushl $0
f0103b43:	6a 00                	push   $0x0
	pushl %ds
f0103b45:	1e                   	push   %ds
	pushl %es
f0103b46:	06                   	push   %es

	//tf parse to router
	pushal
f0103b47:	60                   	pusha  
	//switch to Kernel Data
	movw $GD_KD, %ax
f0103b48:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0103b4c:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103b4e:	8e c0                	mov    %eax,%es
	pushl %esp
f0103b50:	54                   	push   %esp
	//router is a method to parse modified register to syscall
	call router
f0103b51:	e8 68 03 00 00       	call   f0103ebe <router>
	popl %esp
f0103b56:	5c                   	pop    %esp
	popal
f0103b57:	61                   	popa   
	popl %es
f0103b58:	07                   	pop    %es
	popl %ds
f0103b59:	1f                   	pop    %ds
	movl %ebp, %ecx
f0103b5a:	89 e9                	mov    %ebp,%ecx
	movl %esi, %edx
f0103b5c:	89 f2                	mov    %esi,%edx
	sysexit
f0103b5e:	0f 35                	sysexit 

f0103b60 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
/*stone's solution for lab3-A*/
_alltraps:
	pushl %ds
f0103b60:	1e                   	push   %ds
	pushl %es
f0103b61:	06                   	push   %es
	pushal
f0103b62:	60                   	pusha  
	
	movw $GD_KD, %ax
f0103b63:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0103b67:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103b69:	8e c0                	mov    %eax,%es
	
	pushl %esp
f0103b6b:	54                   	push   %esp
	call trap
f0103b6c:	e8 a2 fd ff ff       	call   f0103913 <trap>
	...

f0103b80 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103b80:	55                   	push   %ebp
f0103b81:	89 e5                	mov    %esp,%ebp
f0103b83:	53                   	push   %ebx
f0103b84:	83 ec 14             	sub    $0x14,%esp

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0103b87:	8b 1d 5c 32 23 f0    	mov    0xf023325c,%ebx
f0103b8d:	89 d8                	mov    %ebx,%eax
f0103b8f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b94:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0103b98:	74 0b                	je     f0103ba5 <sched_yield+0x25>
f0103b9a:	8b 48 54             	mov    0x54(%eax),%ecx
f0103b9d:	83 e9 02             	sub    $0x2,%ecx
f0103ba0:	83 f9 01             	cmp    $0x1,%ecx
f0103ba3:	76 10                	jbe    f0103bb5 <sched_yield+0x35>
	// LAB 4: Your code here.

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ba5:	83 c2 01             	add    $0x1,%edx
f0103ba8:	83 e8 80             	sub    $0xffffff80,%eax
f0103bab:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103bb1:	75 e1                	jne    f0103b94 <sched_yield+0x14>
f0103bb3:	eb 08                	jmp    f0103bbd <sched_yield+0x3d>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0103bb5:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103bbb:	75 1a                	jne    f0103bd7 <sched_yield+0x57>
		cprintf("No more runnable environments!\n");
f0103bbd:	c7 04 24 b0 6a 10 f0 	movl   $0xf0106ab0,(%esp)
f0103bc4:	e8 6e f6 ff ff       	call   f0103237 <cprintf>
		while (1)
			monitor(NULL);
f0103bc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103bd0:	e8 65 cf ff ff       	call   f0100b3a <monitor>
f0103bd5:	eb f2                	jmp    f0103bc9 <sched_yield+0x49>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0103bd7:	e8 02 17 00 00       	call   f01052de <cpunum>
f0103bdc:	c1 e0 07             	shl    $0x7,%eax
f0103bdf:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0103be1:	8b 43 54             	mov    0x54(%ebx),%eax
f0103be4:	83 e8 02             	sub    $0x2,%eax
f0103be7:	83 f8 01             	cmp    $0x1,%eax
f0103bea:	76 25                	jbe    f0103c11 <sched_yield+0x91>
		panic("CPU %d: No idle environment!", cpunum());
f0103bec:	e8 ed 16 00 00       	call   f01052de <cpunum>
f0103bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bf5:	c7 44 24 08 d0 6a 10 	movl   $0xf0106ad0,0x8(%esp)
f0103bfc:	f0 
f0103bfd:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f0103c04:	00 
f0103c05:	c7 04 24 ed 6a 10 f0 	movl   $0xf0106aed,(%esp)
f0103c0c:	e8 74 c4 ff ff       	call   f0100085 <_panic>
	env_run(idle);
f0103c11:	89 1c 24             	mov    %ebx,(%esp)
f0103c14:	e8 ba ec ff ff       	call   f01028d3 <env_run>
f0103c19:	00 00                	add    %al,(%eax)
f0103c1b:	00 00                	add    %al,(%eax)
f0103c1d:	00 00                	add    %al,(%eax)
	...

f0103c20 <sbrk>:

//=======
/*stone's solution for lab3-B*/
void
sbrk(struct Env* e, size_t len)
{
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
f0103c23:	57                   	push   %edi
f0103c24:	56                   	push   %esi
f0103c25:	53                   	push   %ebx
f0103c26:	83 ec 2c             	sub    $0x2c,%esp
f0103c29:	8b 75 08             	mov    0x8(%ebp),%esi
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
f0103c2c:	8b 7e 60             	mov    0x60(%esi),%edi
f0103c2f:	89 f8                	mov    %edi,%eax
f0103c31:	2b 45 0c             	sub    0xc(%ebp),%eax
f0103c34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103c39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
f0103c3c:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0103c42:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
f0103c48:	39 f8                	cmp    %edi,%eax
f0103c4a:	73 77                	jae    f0103cc3 <sbrk+0xa3>
f0103c4c:	89 c3                	mov    %eax,%ebx
		int r;
		if (!(p = page_alloc(0)))
f0103c4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103c55:	e8 55 dc ff ff       	call   f01018af <page_alloc>
f0103c5a:	85 c0                	test   %eax,%eax
f0103c5c:	75 1c                	jne    f0103c7a <sbrk+0x5a>
			panic("env_alloc: page alloc failed\n");
f0103c5e:	c7 44 24 08 72 66 10 	movl   $0xf0106672,0x8(%esp)
f0103c65:	f0 
f0103c66:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f0103c6d:	00 
f0103c6e:	c7 04 24 fa 6a 10 f0 	movl   $0xf0106afa,(%esp)
f0103c75:	e8 0b c4 ff ff       	call   f0100085 <_panic>
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
f0103c7a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103c81:	00 
f0103c82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103c86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c8a:	8b 46 64             	mov    0x64(%esi),%eax
f0103c8d:	89 04 24             	mov    %eax,(%esp)
f0103c90:	e8 31 df ff ff       	call   f0101bc6 <page_insert>
f0103c95:	85 c0                	test   %eax,%eax
f0103c97:	79 20                	jns    f0103cb9 <sbrk+0x99>
			panic("env_alloc: %e\n", r);
f0103c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c9d:	c7 44 24 08 90 66 10 	movl   $0xf0106690,0x8(%esp)
f0103ca4:	f0 
f0103ca5:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f0103cac:	00 
f0103cad:	c7 04 24 fa 6a 10 f0 	movl   $0xf0106afa,(%esp)
f0103cb4:	e8 cc c3 ff ff       	call   f0100085 <_panic>
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
f0103cb9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103cbf:	39 df                	cmp    %ebx,%edi
f0103cc1:	77 8b                	ja     f0103c4e <sbrk+0x2e>
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
		//cprintf("2\n");
	}
	e->env_sbrk_pos = start;	
f0103cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103cc6:	89 46 60             	mov    %eax,0x60(%esi)
}
f0103cc9:	83 c4 2c             	add    $0x2c,%esp
f0103ccc:	5b                   	pop    %ebx
f0103ccd:	5e                   	pop    %esi
f0103cce:	5f                   	pop    %edi
f0103ccf:	5d                   	pop    %ebp
f0103cd0:	c3                   	ret    

f0103cd1 <syscall>:
	env_run(curenv);
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103cd1:	55                   	push   %ebp
f0103cd2:	89 e5                	mov    %esp,%ebp
f0103cd4:	83 ec 28             	sub    $0x28,%esp
f0103cd7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0103cda:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ce0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ce3:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	int32_t ret = -E_INVAL;
	switch (syscallno){
f0103ce6:	83 f8 0e             	cmp    $0xe,%eax
f0103ce9:	77 07                	ja     f0103cf2 <syscall+0x21>
f0103ceb:	ff 24 85 44 6b 10 f0 	jmp    *-0xfef94bc(,%eax,4)
f0103cf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103cf7:	e9 b8 01 00 00       	jmp    f0103eb4 <syscall+0x1e3>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	user_mem_assert(curenv, (void*)s, len, PTE_P | PTE_U);
f0103cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103d00:	e8 d9 15 00 00       	call   f01052de <cpunum>
f0103d05:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103d0c:	00 
f0103d0d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103d11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d15:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d18:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103d1e:	89 04 24             	mov    %eax,(%esp)
f0103d21:	e8 87 dd ff ff       	call   f0101aad <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103d26:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d2a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d2e:	c7 04 24 09 6b 10 f0 	movl   $0xf0106b09,(%esp)
f0103d35:	e8 fd f4 ff ff       	call   f0103237 <cprintf>
f0103d3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d3f:	e9 70 01 00 00       	jmp    f0103eb4 <syscall+0x1e3>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103d44:	e8 46 c7 ff ff       	call   f010048f <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0103d49:	e9 66 01 00 00       	jmp    f0103eb4 <syscall+0x1e3>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	//cprintf("get:%08x\n", curenv->env_id);
	return curenv->env_id;
f0103d4e:	66 90                	xchg   %ax,%ax
f0103d50:	e8 89 15 00 00       	call   f01052de <cpunum>
f0103d55:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d58:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103d5e:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f0103d61:	e9 4e 01 00 00       	jmp    f0103eb4 <syscall+0x1e3>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103d66:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103d6d:	00 
f0103d6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d75:	89 1c 24             	mov    %ebx,(%esp)
f0103d78:	e8 6d ea ff ff       	call   f01027ea <envid2env>
f0103d7d:	85 c0                	test   %eax,%eax
f0103d7f:	0f 88 2f 01 00 00    	js     f0103eb4 <syscall+0x1e3>
		return r;
	if (e == curenv)
f0103d85:	e8 54 15 00 00       	call   f01052de <cpunum>
f0103d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103d8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d90:	39 90 28 40 23 f0    	cmp    %edx,-0xfdcbfd8(%eax)
f0103d96:	75 23                	jne    f0103dbb <syscall+0xea>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103d98:	e8 41 15 00 00       	call   f01052de <cpunum>
f0103d9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da0:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103da6:	8b 40 48             	mov    0x48(%eax),%eax
f0103da9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dad:	c7 04 24 0e 6b 10 f0 	movl   $0xf0106b0e,(%esp)
f0103db4:	e8 7e f4 ff ff       	call   f0103237 <cprintf>
f0103db9:	eb 28                	jmp    f0103de3 <syscall+0x112>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103dbb:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103dbe:	e8 1b 15 00 00       	call   f01052de <cpunum>
f0103dc3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103dc7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dca:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103dd0:	8b 40 48             	mov    0x48(%eax),%eax
f0103dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dd7:	c7 04 24 29 6b 10 f0 	movl   $0xf0106b29,(%esp)
f0103dde:	e8 54 f4 ff ff       	call   f0103237 <cprintf>
	env_destroy(e);
f0103de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103de6:	89 04 24             	mov    %eax,(%esp)
f0103de9:	e8 23 ee ff ff       	call   f0102c11 <env_destroy>
f0103dee:	b8 00 00 00 00       	mov    $0x0,%eax
f0103df3:	e9 bc 00 00 00       	jmp    f0103eb4 <syscall+0x1e3>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103df8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103dfe:	77 20                	ja     f0103e20 <syscall+0x14f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e00:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103e04:	c7 44 24 08 7c 5a 10 	movl   $0xf0105a7c,0x8(%esp)
f0103e0b:	f0 
f0103e0c:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
f0103e13:	00 
f0103e14:	c7 04 24 fa 6a 10 f0 	movl   $0xf0106afa,(%esp)
f0103e1b:	e8 65 c2 ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e20:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0103e26:	c1 eb 0c             	shr    $0xc,%ebx
f0103e29:	3b 1d a8 3e 23 f0    	cmp    0xf0233ea8,%ebx
f0103e2f:	72 1c                	jb     f0103e4d <syscall+0x17c>
		panic("pa2page called with invalid pa");
f0103e31:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0103e38:	f0 
f0103e39:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0103e40:	00 
f0103e41:	c7 04 24 6d 64 10 f0 	movl   $0xf010646d,(%esp)
f0103e48:	e8 38 c2 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0103e4d:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0103e50:	b8 03 00 00 00       	mov    $0x3,%eax
f0103e55:	03 1d b0 3e 23 f0    	add    0xf0233eb0,%ebx
f0103e5b:	74 57                	je     f0103eb4 <syscall+0x1e3>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0103e5d:	e8 7c 14 00 00       	call   f01052de <cpunum>
f0103e62:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103e69:	00 
f0103e6a:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103e6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e72:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e75:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103e7b:	8b 40 64             	mov    0x64(%eax),%eax
f0103e7e:	89 04 24             	mov    %eax,(%esp)
f0103e81:	e8 40 dd ff ff       	call   f0101bc6 <page_insert>
f0103e86:	eb 2c                	jmp    f0103eb4 <syscall+0x1e3>
static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	/*stone's solution for lab3-B*/
	sbrk(curenv, inc);
f0103e88:	e8 51 14 00 00       	call   f01052de <cpunum>
f0103e8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e91:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f0103e96:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e99:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103e9d:	89 04 24             	mov    %eax,(%esp)
f0103ea0:	e8 7b fd ff ff       	call   f0103c20 <sbrk>
	return (int)curenv->env_sbrk_pos;
f0103ea5:	e8 34 14 00 00       	call   f01052de <cpunum>
f0103eaa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ead:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103eb1:	8b 40 60             	mov    0x60(%eax),%eax
		default:
			break;
	}
	return ret;
	//panic("syscall not implemented");
}
f0103eb4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0103eb7:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0103eba:	89 ec                	mov    %ebp,%esp
f0103ebc:	5d                   	pop    %ebp
f0103ebd:	c3                   	ret    

f0103ebe <router>:
	sbrk(curenv, inc);
	return (int)curenv->env_sbrk_pos;
}
/*stone's solution for lab3-B*/
void
router(struct Trapframe *tf){
f0103ebe:	55                   	push   %ebp
f0103ebf:	89 e5                	mov    %esp,%ebp
f0103ec1:	83 ec 38             	sub    $0x38,%esp
f0103ec4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103ec7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103eca:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103ecd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ed0:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f0103ed7:	e8 c9 17 00 00       	call   f01056a5 <spin_lock>
	lock_kernel();
	curenv->env_tf = *tf;
f0103edc:	e8 fd 13 00 00       	call   f01052de <cpunum>
f0103ee1:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f0103ee6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee9:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103eed:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103ef2:	89 c7                	mov    %eax,%edi
f0103ef4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf = &curenv->env_tf;
f0103ef6:	e8 e3 13 00 00       	call   f01052de <cpunum>
f0103efb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103efe:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
f0103f02:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f0103f09:	00 
f0103f0a:	8b 06                	mov    (%esi),%eax
f0103f0c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103f10:	8b 46 10             	mov    0x10(%esi),%eax
f0103f13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f17:	8b 46 18             	mov    0x18(%esi),%eax
f0103f1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f1e:	8b 46 14             	mov    0x14(%esi),%eax
f0103f21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f25:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103f28:	89 04 24             	mov    %eax,(%esp)
f0103f2b:	e8 a1 fd ff ff       	call   f0103cd1 <syscall>
f0103f30:	89 46 1c             	mov    %eax,0x1c(%esi)
	env_run(curenv);
f0103f33:	e8 a6 13 00 00       	call   f01052de <cpunum>
f0103f38:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f3b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103f3f:	89 04 24             	mov    %eax,(%esp)
f0103f42:	e8 8c e9 ff ff       	call   f01028d3 <env_run>
	...

f0103f50 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103f50:	55                   	push   %ebp
f0103f51:	89 e5                	mov    %esp,%ebp
f0103f53:	57                   	push   %edi
f0103f54:	56                   	push   %esi
f0103f55:	53                   	push   %ebx
f0103f56:	83 ec 14             	sub    $0x14,%esp
f0103f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f5c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103f5f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103f62:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103f65:	8b 1a                	mov    (%edx),%ebx
f0103f67:	8b 01                	mov    (%ecx),%eax
f0103f69:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0103f6c:	39 c3                	cmp    %eax,%ebx
f0103f6e:	0f 8f 9c 00 00 00    	jg     f0104010 <stab_binsearch+0xc0>
f0103f74:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0103f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f7e:	01 d8                	add    %ebx,%eax
f0103f80:	89 c7                	mov    %eax,%edi
f0103f82:	c1 ef 1f             	shr    $0x1f,%edi
f0103f85:	01 c7                	add    %eax,%edi
f0103f87:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103f89:	39 df                	cmp    %ebx,%edi
f0103f8b:	7c 33                	jl     f0103fc0 <stab_binsearch+0x70>
f0103f8d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103f90:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103f93:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103f98:	39 f0                	cmp    %esi,%eax
f0103f9a:	0f 84 bc 00 00 00    	je     f010405c <stab_binsearch+0x10c>
f0103fa0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0103fa4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0103fa8:	89 f8                	mov    %edi,%eax
			m--;
f0103faa:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103fad:	39 d8                	cmp    %ebx,%eax
f0103faf:	7c 0f                	jl     f0103fc0 <stab_binsearch+0x70>
f0103fb1:	0f b6 0a             	movzbl (%edx),%ecx
f0103fb4:	83 ea 0c             	sub    $0xc,%edx
f0103fb7:	39 f1                	cmp    %esi,%ecx
f0103fb9:	75 ef                	jne    f0103faa <stab_binsearch+0x5a>
f0103fbb:	e9 9e 00 00 00       	jmp    f010405e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103fc0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103fc3:	eb 3c                	jmp    f0104001 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103fc5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103fc8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103fca:	8d 5f 01             	lea    0x1(%edi),%ebx
f0103fcd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103fd4:	eb 2b                	jmp    f0104001 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0103fd6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103fd9:	76 14                	jbe    f0103fef <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103fdb:	83 e8 01             	sub    $0x1,%eax
f0103fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103fe1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103fe4:	89 02                	mov    %eax,(%edx)
f0103fe6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103fed:	eb 12                	jmp    f0104001 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103fef:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103ff2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103ff4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103ff8:	89 c3                	mov    %eax,%ebx
f0103ffa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0104001:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104004:	0f 8d 71 ff ff ff    	jge    f0103f7b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010400a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010400e:	75 0f                	jne    f010401f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0104010:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104013:	8b 03                	mov    (%ebx),%eax
f0104015:	83 e8 01             	sub    $0x1,%eax
f0104018:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010401b:	89 02                	mov    %eax,(%edx)
f010401d:	eb 57                	jmp    f0104076 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010401f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104022:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104024:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104027:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104029:	39 c1                	cmp    %eax,%ecx
f010402b:	7d 28                	jge    f0104055 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010402d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104030:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104033:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104038:	39 f2                	cmp    %esi,%edx
f010403a:	74 19                	je     f0104055 <stab_binsearch+0x105>
f010403c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0104040:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0104044:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104047:	39 c1                	cmp    %eax,%ecx
f0104049:	7d 0a                	jge    f0104055 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010404b:	0f b6 1a             	movzbl (%edx),%ebx
f010404e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104051:	39 f3                	cmp    %esi,%ebx
f0104053:	75 ef                	jne    f0104044 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0104055:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104058:	89 02                	mov    %eax,(%edx)
f010405a:	eb 1a                	jmp    f0104076 <stab_binsearch+0x126>
	}
}
f010405c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010405e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104061:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104064:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104068:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010406b:	0f 82 54 ff ff ff    	jb     f0103fc5 <stab_binsearch+0x75>
f0104071:	e9 60 ff ff ff       	jmp    f0103fd6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104076:	83 c4 14             	add    $0x14,%esp
f0104079:	5b                   	pop    %ebx
f010407a:	5e                   	pop    %esi
f010407b:	5f                   	pop    %edi
f010407c:	5d                   	pop    %ebp
f010407d:	c3                   	ret    

f010407e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010407e:	55                   	push   %ebp
f010407f:	89 e5                	mov    %esp,%ebp
f0104081:	83 ec 58             	sub    $0x58,%esp
f0104084:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104087:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010408a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010408d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104090:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104093:	c7 03 80 6b 10 f0    	movl   $0xf0106b80,(%ebx)
	info->eip_line = 0;
f0104099:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01040a0:	c7 43 08 80 6b 10 f0 	movl   $0xf0106b80,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01040a7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01040ae:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01040b1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01040b8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01040be:	76 1f                	jbe    f01040df <debuginfo_eip+0x61>
f01040c0:	bf 69 4e 11 f0       	mov    $0xf0114e69,%edi
f01040c5:	c7 45 c4 0d 12 11 f0 	movl   $0xf011120d,-0x3c(%ebp)
f01040cc:	c7 45 bc 0c 12 11 f0 	movl   $0xf011120c,-0x44(%ebp)
f01040d3:	c7 45 c0 54 70 10 f0 	movl   $0xf0107054,-0x40(%ebp)
f01040da:	e9 c7 00 00 00       	jmp    f01041a6 <debuginfo_eip+0x128>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		/*stone's solution for lab3-B*/
		if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f01040df:	e8 fa 11 00 00       	call   f01052de <cpunum>
f01040e4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01040eb:	00 
f01040ec:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01040f3:	00 
f01040f4:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01040fb:	00 
f01040fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ff:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0104105:	89 04 24             	mov    %eax,(%esp)
f0104108:	e8 0c d9 ff ff       	call   f0101a19 <user_mem_check>
f010410d:	85 c0                	test   %eax,%eax
f010410f:	0f 88 01 02 00 00    	js     f0104316 <debuginfo_eip+0x298>
		stabs = usd->stabs;
f0104115:	b8 00 00 20 00       	mov    $0x200000,%eax
f010411a:	8b 10                	mov    (%eax),%edx
f010411c:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f010411f:	8b 48 04             	mov    0x4(%eax),%ecx
f0104122:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f0104125:	8b 50 08             	mov    0x8(%eax),%edx
f0104128:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f010412b:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		/*stone's solution for lab3-B*/
		if (user_mem_check(curenv, (void*)stabs, stab_end - stabs, PTE_U) < 0) return -1;
f010412e:	e8 ab 11 00 00       	call   f01052de <cpunum>
f0104133:	89 c2                	mov    %eax,%edx
f0104135:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010413c:	00 
f010413d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104140:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0104143:	c1 f8 02             	sar    $0x2,%eax
f0104146:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010414c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104150:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104153:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104157:	6b c2 74             	imul   $0x74,%edx,%eax
f010415a:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0104160:	89 04 24             	mov    %eax,(%esp)
f0104163:	e8 b1 d8 ff ff       	call   f0101a19 <user_mem_check>
f0104168:	85 c0                	test   %eax,%eax
f010416a:	0f 88 a6 01 00 00    	js     f0104316 <debuginfo_eip+0x298>
		if (user_mem_check(curenv, (void*)stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f0104170:	e8 69 11 00 00       	call   f01052de <cpunum>
f0104175:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010417c:	00 
f010417d:	89 fa                	mov    %edi,%edx
f010417f:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0104182:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104186:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104189:	89 54 24 04          	mov    %edx,0x4(%esp)
f010418d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104190:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0104196:	89 04 24             	mov    %eax,(%esp)
f0104199:	e8 7b d8 ff ff       	call   f0101a19 <user_mem_check>
f010419e:	85 c0                	test   %eax,%eax
f01041a0:	0f 88 70 01 00 00    	js     f0104316 <debuginfo_eip+0x298>
		
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01041a6:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f01041a9:	0f 83 67 01 00 00    	jae    f0104316 <debuginfo_eip+0x298>
f01041af:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01041b3:	0f 85 5d 01 00 00    	jne    f0104316 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01041b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01041c0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01041c3:	2b 45 c0             	sub    -0x40(%ebp),%eax
f01041c6:	c1 f8 02             	sar    $0x2,%eax
f01041c9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01041cf:	83 e8 01             	sub    $0x1,%eax
f01041d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01041d5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01041d8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01041db:	89 74 24 04          	mov    %esi,0x4(%esp)
f01041df:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01041e6:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01041e9:	e8 62 fd ff ff       	call   f0103f50 <stab_binsearch>
	if (lfile == 0)
f01041ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041f1:	85 c0                	test   %eax,%eax
f01041f3:	0f 84 1d 01 00 00    	je     f0104316 <debuginfo_eip+0x298>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01041f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01041fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104202:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104205:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104208:	89 74 24 04          	mov    %esi,0x4(%esp)
f010420c:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104213:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104216:	e8 35 fd ff ff       	call   f0103f50 <stab_binsearch>

	if (lfun <= rfun) {
f010421b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010421e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104221:	7f 35                	jg     f0104258 <debuginfo_eip+0x1da>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104223:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104226:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104229:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f010422c:	89 fa                	mov    %edi,%edx
f010422e:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0104231:	39 d0                	cmp    %edx,%eax
f0104233:	73 06                	jae    f010423b <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104235:	03 45 c4             	add    -0x3c(%ebp),%eax
f0104238:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010423b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010423e:	6b c2 0c             	imul   $0xc,%edx,%eax
f0104241:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104244:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f0104248:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010424b:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010424d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104250:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104253:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104256:	eb 0f                	jmp    f0104267 <debuginfo_eip+0x1e9>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104258:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010425b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010425e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104261:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104264:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104267:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010426e:	00 
f010426f:	8b 43 08             	mov    0x8(%ebx),%eax
f0104272:	89 04 24             	mov    %eax,(%esp)
f0104275:	e8 91 09 00 00       	call   f0104c0b <strfind>
f010427a:	2b 43 08             	sub    0x8(%ebx),%eax
f010427d:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	/* stone's solution for exercise15 */
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104280:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104283:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104286:	89 74 24 04          	mov    %esi,0x4(%esp)
f010428a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0104291:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104294:	e8 b7 fc ff ff       	call   f0103f50 <stab_binsearch>
	if (lline <= rline)
f0104299:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010429c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010429f:	7f 75                	jg     f0104316 <debuginfo_eip+0x298>
		info->eip_line = stabs[lline].n_desc;
f01042a1:	6b c0 0c             	imul   $0xc,%eax,%eax
f01042a4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01042a7:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f01042ac:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01042af:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042b2:	eb 06                	jmp    f01042ba <debuginfo_eip+0x23c>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01042b4:	83 e8 01             	sub    $0x1,%eax
f01042b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01042ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042bd:	39 f0                	cmp    %esi,%eax
f01042bf:	7c 26                	jl     f01042e7 <debuginfo_eip+0x269>
	       && stabs[lline].n_type != N_SOL
f01042c1:	6b d0 0c             	imul   $0xc,%eax,%edx
f01042c4:	03 55 c0             	add    -0x40(%ebp),%edx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01042c7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042cb:	80 f9 84             	cmp    $0x84,%cl
f01042ce:	74 5f                	je     f010432f <debuginfo_eip+0x2b1>
f01042d0:	80 f9 64             	cmp    $0x64,%cl
f01042d3:	75 df                	jne    f01042b4 <debuginfo_eip+0x236>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01042d5:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01042d9:	74 d9                	je     f01042b4 <debuginfo_eip+0x236>
f01042db:	90                   	nop
f01042dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01042e0:	eb 4d                	jmp    f010432f <debuginfo_eip+0x2b1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01042e2:	03 45 c4             	add    -0x3c(%ebp),%eax
f01042e5:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01042e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042ea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01042ed:	7d 2e                	jge    f010431d <debuginfo_eip+0x29f>
		for (lline = lfun + 1;
f01042ef:	83 c0 01             	add    $0x1,%eax
f01042f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01042f5:	eb 08                	jmp    f01042ff <debuginfo_eip+0x281>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01042f7:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01042fb:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01042ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104302:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104305:	7d 16                	jge    f010431d <debuginfo_eip+0x29f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104307:	6b c0 0c             	imul   $0xc,%eax,%eax
f010430a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010430d:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f0104312:	74 e3                	je     f01042f7 <debuginfo_eip+0x279>
f0104314:	eb 07                	jmp    f010431d <debuginfo_eip+0x29f>
f0104316:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010431b:	eb 05                	jmp    f0104322 <debuginfo_eip+0x2a4>
f010431d:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0104322:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104325:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104328:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010432b:	89 ec                	mov    %ebp,%esp
f010432d:	5d                   	pop    %ebp
f010432e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010432f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104332:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104335:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0104338:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f010433b:	39 f8                	cmp    %edi,%eax
f010433d:	72 a3                	jb     f01042e2 <debuginfo_eip+0x264>
f010433f:	eb a6                	jmp    f01042e7 <debuginfo_eip+0x269>
	...

f0104350 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104350:	55                   	push   %ebp
f0104351:	89 e5                	mov    %esp,%ebp
f0104353:	57                   	push   %edi
f0104354:	56                   	push   %esi
f0104355:	53                   	push   %ebx
f0104356:	83 ec 4c             	sub    $0x4c,%esp
f0104359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010435c:	89 d6                	mov    %edx,%esi
f010435e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104361:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104364:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104367:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010436a:	8b 45 10             	mov    0x10(%ebp),%eax
f010436d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104370:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104373:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104376:	b9 00 00 00 00       	mov    $0x0,%ecx
f010437b:	39 d1                	cmp    %edx,%ecx
f010437d:	72 15                	jb     f0104394 <printnum+0x44>
f010437f:	77 07                	ja     f0104388 <printnum+0x38>
f0104381:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104384:	39 d0                	cmp    %edx,%eax
f0104386:	76 0c                	jbe    f0104394 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104388:	83 eb 01             	sub    $0x1,%ebx
f010438b:	85 db                	test   %ebx,%ebx
f010438d:	8d 76 00             	lea    0x0(%esi),%esi
f0104390:	7f 61                	jg     f01043f3 <printnum+0xa3>
f0104392:	eb 70                	jmp    f0104404 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104394:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0104398:	83 eb 01             	sub    $0x1,%ebx
f010439b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010439f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043a3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01043a7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01043ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01043ae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01043b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01043b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01043b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01043bf:	00 
f01043c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01043c3:	89 04 24             	mov    %eax,(%esp)
f01043c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01043c9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043cd:	e8 ae 13 00 00       	call   f0105780 <__udivdi3>
f01043d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01043d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01043d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01043dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01043e0:	89 04 24             	mov    %eax,(%esp)
f01043e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043e7:	89 f2                	mov    %esi,%edx
f01043e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043ec:	e8 5f ff ff ff       	call   f0104350 <printnum>
f01043f1:	eb 11                	jmp    f0104404 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01043f3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01043f7:	89 3c 24             	mov    %edi,(%esp)
f01043fa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01043fd:	83 eb 01             	sub    $0x1,%ebx
f0104400:	85 db                	test   %ebx,%ebx
f0104402:	7f ef                	jg     f01043f3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104404:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104408:	8b 74 24 04          	mov    0x4(%esp),%esi
f010440c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010440f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104413:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010441a:	00 
f010441b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010441e:	89 14 24             	mov    %edx,(%esp)
f0104421:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104424:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104428:	e8 83 14 00 00       	call   f01058b0 <__umoddi3>
f010442d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104431:	0f be 80 8a 6b 10 f0 	movsbl -0xfef9476(%eax),%eax
f0104438:	89 04 24             	mov    %eax,(%esp)
f010443b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010443e:	83 c4 4c             	add    $0x4c,%esp
f0104441:	5b                   	pop    %ebx
f0104442:	5e                   	pop    %esi
f0104443:	5f                   	pop    %edi
f0104444:	5d                   	pop    %ebp
f0104445:	c3                   	ret    

f0104446 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104446:	55                   	push   %ebp
f0104447:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104449:	83 fa 01             	cmp    $0x1,%edx
f010444c:	7e 0e                	jle    f010445c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010444e:	8b 10                	mov    (%eax),%edx
f0104450:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104453:	89 08                	mov    %ecx,(%eax)
f0104455:	8b 02                	mov    (%edx),%eax
f0104457:	8b 52 04             	mov    0x4(%edx),%edx
f010445a:	eb 22                	jmp    f010447e <getuint+0x38>
	else if (lflag)
f010445c:	85 d2                	test   %edx,%edx
f010445e:	74 10                	je     f0104470 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104460:	8b 10                	mov    (%eax),%edx
f0104462:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104465:	89 08                	mov    %ecx,(%eax)
f0104467:	8b 02                	mov    (%edx),%eax
f0104469:	ba 00 00 00 00       	mov    $0x0,%edx
f010446e:	eb 0e                	jmp    f010447e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104470:	8b 10                	mov    (%eax),%edx
f0104472:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104475:	89 08                	mov    %ecx,(%eax)
f0104477:	8b 02                	mov    (%edx),%eax
f0104479:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010447e:	5d                   	pop    %ebp
f010447f:	c3                   	ret    

f0104480 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104480:	55                   	push   %ebp
f0104481:	89 e5                	mov    %esp,%ebp
f0104483:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104486:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010448a:	8b 10                	mov    (%eax),%edx
f010448c:	3b 50 04             	cmp    0x4(%eax),%edx
f010448f:	73 0a                	jae    f010449b <sprintputch+0x1b>
		*b->buf++ = ch;
f0104491:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104494:	88 0a                	mov    %cl,(%edx)
f0104496:	83 c2 01             	add    $0x1,%edx
f0104499:	89 10                	mov    %edx,(%eax)
}
f010449b:	5d                   	pop    %ebp
f010449c:	c3                   	ret    

f010449d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010449d:	55                   	push   %ebp
f010449e:	89 e5                	mov    %esp,%ebp
f01044a0:	57                   	push   %edi
f01044a1:	56                   	push   %esi
f01044a2:	53                   	push   %ebx
f01044a3:	83 ec 5c             	sub    $0x5c,%esp
f01044a6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01044a9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01044af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01044b6:	eb 11                	jmp    f01044c9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01044b8:	85 c0                	test   %eax,%eax
f01044ba:	0f 84 09 04 00 00    	je     f01048c9 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
f01044c0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01044c4:	89 04 24             	mov    %eax,(%esp)
f01044c7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01044c9:	0f b6 03             	movzbl (%ebx),%eax
f01044cc:	83 c3 01             	add    $0x1,%ebx
f01044cf:	83 f8 25             	cmp    $0x25,%eax
f01044d2:	75 e4                	jne    f01044b8 <vprintfmt+0x1b>
f01044d4:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01044d8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f01044df:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01044e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01044ed:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044f2:	eb 06                	jmp    f01044fa <vprintfmt+0x5d>
f01044f4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01044f8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044fa:	0f b6 13             	movzbl (%ebx),%edx
f01044fd:	0f b6 c2             	movzbl %dl,%eax
f0104500:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104503:	8d 43 01             	lea    0x1(%ebx),%eax
f0104506:	83 ea 23             	sub    $0x23,%edx
f0104509:	80 fa 55             	cmp    $0x55,%dl
f010450c:	0f 87 9a 03 00 00    	ja     f01048ac <vprintfmt+0x40f>
f0104512:	0f b6 d2             	movzbl %dl,%edx
f0104515:	ff 24 95 40 6c 10 f0 	jmp    *-0xfef93c0(,%edx,4)
f010451c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104520:	eb d6                	jmp    f01044f8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104522:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104525:	83 ea 30             	sub    $0x30,%edx
f0104528:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f010452b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010452e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104531:	83 fb 09             	cmp    $0x9,%ebx
f0104534:	77 4c                	ja     f0104582 <vprintfmt+0xe5>
f0104536:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104539:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010453c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f010453f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104542:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0104546:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104549:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010454c:	83 fb 09             	cmp    $0x9,%ebx
f010454f:	76 eb                	jbe    f010453c <vprintfmt+0x9f>
f0104551:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104554:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104557:	eb 29                	jmp    f0104582 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104559:	8b 55 14             	mov    0x14(%ebp),%edx
f010455c:	8d 5a 04             	lea    0x4(%edx),%ebx
f010455f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104562:	8b 12                	mov    (%edx),%edx
f0104564:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0104567:	eb 19                	jmp    f0104582 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
f0104569:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010456c:	c1 fa 1f             	sar    $0x1f,%edx
f010456f:	f7 d2                	not    %edx
f0104571:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0104574:	eb 82                	jmp    f01044f8 <vprintfmt+0x5b>
f0104576:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f010457d:	e9 76 ff ff ff       	jmp    f01044f8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0104582:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104586:	0f 89 6c ff ff ff    	jns    f01044f8 <vprintfmt+0x5b>
f010458c:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010458f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104592:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104595:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104598:	e9 5b ff ff ff       	jmp    f01044f8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010459d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f01045a0:	e9 53 ff ff ff       	jmp    f01044f8 <vprintfmt+0x5b>
f01045a5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01045a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01045ab:	8d 50 04             	lea    0x4(%eax),%edx
f01045ae:	89 55 14             	mov    %edx,0x14(%ebp)
f01045b1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01045b5:	8b 00                	mov    (%eax),%eax
f01045b7:	89 04 24             	mov    %eax,(%esp)
f01045ba:	ff d7                	call   *%edi
f01045bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01045bf:	e9 05 ff ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
f01045c4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01045c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01045ca:	8d 50 04             	lea    0x4(%eax),%edx
f01045cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01045d0:	8b 00                	mov    (%eax),%eax
f01045d2:	89 c2                	mov    %eax,%edx
f01045d4:	c1 fa 1f             	sar    $0x1f,%edx
f01045d7:	31 d0                	xor    %edx,%eax
f01045d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01045db:	83 f8 08             	cmp    $0x8,%eax
f01045de:	7f 0b                	jg     f01045eb <vprintfmt+0x14e>
f01045e0:	8b 14 85 a0 6d 10 f0 	mov    -0xfef9260(,%eax,4),%edx
f01045e7:	85 d2                	test   %edx,%edx
f01045e9:	75 20                	jne    f010460b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
f01045eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045ef:	c7 44 24 08 9b 6b 10 	movl   $0xf0106b9b,0x8(%esp)
f01045f6:	f0 
f01045f7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01045fb:	89 3c 24             	mov    %edi,(%esp)
f01045fe:	e8 4e 03 00 00       	call   f0104951 <printfmt>
f0104603:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104606:	e9 be fe ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f010460b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010460f:	c7 44 24 08 a5 64 10 	movl   $0xf01064a5,0x8(%esp)
f0104616:	f0 
f0104617:	89 74 24 04          	mov    %esi,0x4(%esp)
f010461b:	89 3c 24             	mov    %edi,(%esp)
f010461e:	e8 2e 03 00 00       	call   f0104951 <printfmt>
f0104623:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104626:	e9 9e fe ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
f010462b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010462e:	89 c3                	mov    %eax,%ebx
f0104630:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104636:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104639:	8b 45 14             	mov    0x14(%ebp),%eax
f010463c:	8d 50 04             	lea    0x4(%eax),%edx
f010463f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104642:	8b 00                	mov    (%eax),%eax
f0104644:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104647:	85 c0                	test   %eax,%eax
f0104649:	75 07                	jne    f0104652 <vprintfmt+0x1b5>
f010464b:	c7 45 c4 a4 6b 10 f0 	movl   $0xf0106ba4,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0104652:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0104656:	7e 06                	jle    f010465e <vprintfmt+0x1c1>
f0104658:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010465c:	75 13                	jne    f0104671 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010465e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104661:	0f be 02             	movsbl (%edx),%eax
f0104664:	85 c0                	test   %eax,%eax
f0104666:	0f 85 99 00 00 00    	jne    f0104705 <vprintfmt+0x268>
f010466c:	e9 86 00 00 00       	jmp    f01046f7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104671:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104675:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104678:	89 0c 24             	mov    %ecx,(%esp)
f010467b:	e8 fb 03 00 00       	call   f0104a7b <strnlen>
f0104680:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104683:	29 c2                	sub    %eax,%edx
f0104685:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104688:	85 d2                	test   %edx,%edx
f010468a:	7e d2                	jle    f010465e <vprintfmt+0x1c1>
					putch(padc, putdat);
f010468c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f0104690:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104693:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0104696:	89 d3                	mov    %edx,%ebx
f0104698:	89 74 24 04          	mov    %esi,0x4(%esp)
f010469c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010469f:	89 04 24             	mov    %eax,(%esp)
f01046a2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01046a4:	83 eb 01             	sub    $0x1,%ebx
f01046a7:	85 db                	test   %ebx,%ebx
f01046a9:	7f ed                	jg     f0104698 <vprintfmt+0x1fb>
f01046ab:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01046ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01046b5:	eb a7                	jmp    f010465e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01046b7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01046bb:	74 18                	je     f01046d5 <vprintfmt+0x238>
f01046bd:	8d 50 e0             	lea    -0x20(%eax),%edx
f01046c0:	83 fa 5e             	cmp    $0x5e,%edx
f01046c3:	76 10                	jbe    f01046d5 <vprintfmt+0x238>
					putch('?', putdat);
f01046c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01046d0:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01046d3:	eb 0a                	jmp    f01046df <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
f01046d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046d9:	89 04 24             	mov    %eax,(%esp)
f01046dc:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01046df:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01046e3:	0f be 03             	movsbl (%ebx),%eax
f01046e6:	85 c0                	test   %eax,%eax
f01046e8:	74 05                	je     f01046ef <vprintfmt+0x252>
f01046ea:	83 c3 01             	add    $0x1,%ebx
f01046ed:	eb 29                	jmp    f0104718 <vprintfmt+0x27b>
f01046ef:	89 fe                	mov    %edi,%esi
f01046f1:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01046f4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01046f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01046fb:	7f 2e                	jg     f010472b <vprintfmt+0x28e>
f01046fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104700:	e9 c4 fd ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104705:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104708:	83 c2 01             	add    $0x1,%edx
f010470b:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010470e:	89 f7                	mov    %esi,%edi
f0104710:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104713:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104716:	89 d3                	mov    %edx,%ebx
f0104718:	85 f6                	test   %esi,%esi
f010471a:	78 9b                	js     f01046b7 <vprintfmt+0x21a>
f010471c:	83 ee 01             	sub    $0x1,%esi
f010471f:	79 96                	jns    f01046b7 <vprintfmt+0x21a>
f0104721:	89 fe                	mov    %edi,%esi
f0104723:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0104726:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104729:	eb cc                	jmp    f01046f7 <vprintfmt+0x25a>
f010472b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010472e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104731:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104735:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010473c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010473e:	83 eb 01             	sub    $0x1,%ebx
f0104741:	85 db                	test   %ebx,%ebx
f0104743:	7f ec                	jg     f0104731 <vprintfmt+0x294>
f0104745:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104748:	e9 7c fd ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
f010474d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104750:	83 f9 01             	cmp    $0x1,%ecx
f0104753:	7e 16                	jle    f010476b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
f0104755:	8b 45 14             	mov    0x14(%ebp),%eax
f0104758:	8d 50 08             	lea    0x8(%eax),%edx
f010475b:	89 55 14             	mov    %edx,0x14(%ebp)
f010475e:	8b 10                	mov    (%eax),%edx
f0104760:	8b 48 04             	mov    0x4(%eax),%ecx
f0104763:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104766:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104769:	eb 32                	jmp    f010479d <vprintfmt+0x300>
	else if (lflag)
f010476b:	85 c9                	test   %ecx,%ecx
f010476d:	74 18                	je     f0104787 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
f010476f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104772:	8d 50 04             	lea    0x4(%eax),%edx
f0104775:	89 55 14             	mov    %edx,0x14(%ebp)
f0104778:	8b 00                	mov    (%eax),%eax
f010477a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010477d:	89 c1                	mov    %eax,%ecx
f010477f:	c1 f9 1f             	sar    $0x1f,%ecx
f0104782:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104785:	eb 16                	jmp    f010479d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
f0104787:	8b 45 14             	mov    0x14(%ebp),%eax
f010478a:	8d 50 04             	lea    0x4(%eax),%edx
f010478d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104790:	8b 00                	mov    (%eax),%eax
f0104792:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104795:	89 c2                	mov    %eax,%edx
f0104797:	c1 fa 1f             	sar    $0x1f,%edx
f010479a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010479d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01047a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01047a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01047a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01047ac:	0f 89 b8 00 00 00    	jns    f010486a <vprintfmt+0x3cd>
				putch('-', putdat);
f01047b2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047b6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01047bd:	ff d7                	call   *%edi
				num = -(long long) num;
f01047bf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01047c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01047c5:	f7 d9                	neg    %ecx
f01047c7:	83 d3 00             	adc    $0x0,%ebx
f01047ca:	f7 db                	neg    %ebx
f01047cc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01047d1:	e9 94 00 00 00       	jmp    f010486a <vprintfmt+0x3cd>
f01047d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01047d9:	89 ca                	mov    %ecx,%edx
f01047db:	8d 45 14             	lea    0x14(%ebp),%eax
f01047de:	e8 63 fc ff ff       	call   f0104446 <getuint>
f01047e3:	89 c1                	mov    %eax,%ecx
f01047e5:	89 d3                	mov    %edx,%ebx
f01047e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f01047ec:	eb 7c                	jmp    f010486a <vprintfmt+0x3cd>
f01047ee:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01047f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047f5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01047fc:	ff d7                	call   *%edi
			putch('X', putdat);
f01047fe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104802:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104809:	ff d7                	call   *%edi
			putch('X', putdat);
f010480b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010480f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104816:	ff d7                	call   *%edi
f0104818:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f010481b:	e9 a9 fc ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
f0104820:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0104823:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104827:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010482e:	ff d7                	call   *%edi
			putch('x', putdat);
f0104830:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104834:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010483b:	ff d7                	call   *%edi
			num = (unsigned long long)
f010483d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104840:	8d 50 04             	lea    0x4(%eax),%edx
f0104843:	89 55 14             	mov    %edx,0x14(%ebp)
f0104846:	8b 08                	mov    (%eax),%ecx
f0104848:	bb 00 00 00 00       	mov    $0x0,%ebx
f010484d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104852:	eb 16                	jmp    f010486a <vprintfmt+0x3cd>
f0104854:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104857:	89 ca                	mov    %ecx,%edx
f0104859:	8d 45 14             	lea    0x14(%ebp),%eax
f010485c:	e8 e5 fb ff ff       	call   f0104446 <getuint>
f0104861:	89 c1                	mov    %eax,%ecx
f0104863:	89 d3                	mov    %edx,%ebx
f0104865:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f010486a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f010486e:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104872:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104875:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104879:	89 44 24 08          	mov    %eax,0x8(%esp)
f010487d:	89 0c 24             	mov    %ecx,(%esp)
f0104880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104884:	89 f2                	mov    %esi,%edx
f0104886:	89 f8                	mov    %edi,%eax
f0104888:	e8 c3 fa ff ff       	call   f0104350 <printnum>
f010488d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0104890:	e9 34 fc ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
f0104895:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104898:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010489b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010489f:	89 14 24             	mov    %edx,(%esp)
f01048a2:	ff d7                	call   *%edi
f01048a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01048a7:	e9 1d fc ff ff       	jmp    f01044c9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01048ac:	89 74 24 04          	mov    %esi,0x4(%esp)
f01048b0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01048b7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01048b9:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01048bc:	80 38 25             	cmpb   $0x25,(%eax)
f01048bf:	0f 84 04 fc ff ff    	je     f01044c9 <vprintfmt+0x2c>
f01048c5:	89 c3                	mov    %eax,%ebx
f01048c7:	eb f0                	jmp    f01048b9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
f01048c9:	83 c4 5c             	add    $0x5c,%esp
f01048cc:	5b                   	pop    %ebx
f01048cd:	5e                   	pop    %esi
f01048ce:	5f                   	pop    %edi
f01048cf:	5d                   	pop    %ebp
f01048d0:	c3                   	ret    

f01048d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01048d1:	55                   	push   %ebp
f01048d2:	89 e5                	mov    %esp,%ebp
f01048d4:	83 ec 28             	sub    $0x28,%esp
f01048d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01048da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01048dd:	85 c0                	test   %eax,%eax
f01048df:	74 04                	je     f01048e5 <vsnprintf+0x14>
f01048e1:	85 d2                	test   %edx,%edx
f01048e3:	7f 07                	jg     f01048ec <vsnprintf+0x1b>
f01048e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048ea:	eb 3b                	jmp    f0104927 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01048ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01048ef:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01048f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01048f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01048fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104900:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104904:	8b 45 10             	mov    0x10(%ebp),%eax
f0104907:	89 44 24 08          	mov    %eax,0x8(%esp)
f010490b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010490e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104912:	c7 04 24 80 44 10 f0 	movl   $0xf0104480,(%esp)
f0104919:	e8 7f fb ff ff       	call   f010449d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010491e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104921:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104927:	c9                   	leave  
f0104928:	c3                   	ret    

f0104929 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104929:	55                   	push   %ebp
f010492a:	89 e5                	mov    %esp,%ebp
f010492c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f010492f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0104932:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104936:	8b 45 10             	mov    0x10(%ebp),%eax
f0104939:	89 44 24 08          	mov    %eax,0x8(%esp)
f010493d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104940:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104944:	8b 45 08             	mov    0x8(%ebp),%eax
f0104947:	89 04 24             	mov    %eax,(%esp)
f010494a:	e8 82 ff ff ff       	call   f01048d1 <vsnprintf>
	va_end(ap);

	return rc;
}
f010494f:	c9                   	leave  
f0104950:	c3                   	ret    

f0104951 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104951:	55                   	push   %ebp
f0104952:	89 e5                	mov    %esp,%ebp
f0104954:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0104957:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f010495a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010495e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104961:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104965:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104968:	89 44 24 04          	mov    %eax,0x4(%esp)
f010496c:	8b 45 08             	mov    0x8(%ebp),%eax
f010496f:	89 04 24             	mov    %eax,(%esp)
f0104972:	e8 26 fb ff ff       	call   f010449d <vprintfmt>
	va_end(ap);
}
f0104977:	c9                   	leave  
f0104978:	c3                   	ret    
f0104979:	00 00                	add    %al,(%eax)
f010497b:	00 00                	add    %al,(%eax)
f010497d:	00 00                	add    %al,(%eax)
	...

f0104980 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104980:	55                   	push   %ebp
f0104981:	89 e5                	mov    %esp,%ebp
f0104983:	57                   	push   %edi
f0104984:	56                   	push   %esi
f0104985:	53                   	push   %ebx
f0104986:	83 ec 1c             	sub    $0x1c,%esp
f0104989:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010498c:	85 c0                	test   %eax,%eax
f010498e:	74 10                	je     f01049a0 <readline+0x20>
		cprintf("%s", prompt);
f0104990:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104994:	c7 04 24 a5 64 10 f0 	movl   $0xf01064a5,(%esp)
f010499b:	e8 97 e8 ff ff       	call   f0103237 <cprintf>

	i = 0;
	echoing = iscons(0);
f01049a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01049a7:	e8 3a bb ff ff       	call   f01004e6 <iscons>
f01049ac:	89 c7                	mov    %eax,%edi
f01049ae:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01049b3:	e8 1d bb ff ff       	call   f01004d5 <getchar>
f01049b8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01049ba:	85 c0                	test   %eax,%eax
f01049bc:	79 17                	jns    f01049d5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01049be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049c2:	c7 04 24 c4 6d 10 f0 	movl   $0xf0106dc4,(%esp)
f01049c9:	e8 69 e8 ff ff       	call   f0103237 <cprintf>
f01049ce:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01049d3:	eb 76                	jmp    f0104a4b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01049d5:	83 f8 08             	cmp    $0x8,%eax
f01049d8:	74 08                	je     f01049e2 <readline+0x62>
f01049da:	83 f8 7f             	cmp    $0x7f,%eax
f01049dd:	8d 76 00             	lea    0x0(%esi),%esi
f01049e0:	75 19                	jne    f01049fb <readline+0x7b>
f01049e2:	85 f6                	test   %esi,%esi
f01049e4:	7e 15                	jle    f01049fb <readline+0x7b>
			if (echoing)
f01049e6:	85 ff                	test   %edi,%edi
f01049e8:	74 0c                	je     f01049f6 <readline+0x76>
				cputchar('\b');
f01049ea:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01049f1:	e8 f4 bc ff ff       	call   f01006ea <cputchar>
			i--;
f01049f6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01049f9:	eb b8                	jmp    f01049b3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f01049fb:	83 fb 1f             	cmp    $0x1f,%ebx
f01049fe:	66 90                	xchg   %ax,%ax
f0104a00:	7e 23                	jle    f0104a25 <readline+0xa5>
f0104a02:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104a08:	7f 1b                	jg     f0104a25 <readline+0xa5>
			if (echoing)
f0104a0a:	85 ff                	test   %edi,%edi
f0104a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a10:	74 08                	je     f0104a1a <readline+0x9a>
				cputchar(c);
f0104a12:	89 1c 24             	mov    %ebx,(%esp)
f0104a15:	e8 d0 bc ff ff       	call   f01006ea <cputchar>
			buf[i++] = c;
f0104a1a:	88 9e a0 3a 23 f0    	mov    %bl,-0xfdcc560(%esi)
f0104a20:	83 c6 01             	add    $0x1,%esi
f0104a23:	eb 8e                	jmp    f01049b3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104a25:	83 fb 0a             	cmp    $0xa,%ebx
f0104a28:	74 05                	je     f0104a2f <readline+0xaf>
f0104a2a:	83 fb 0d             	cmp    $0xd,%ebx
f0104a2d:	75 84                	jne    f01049b3 <readline+0x33>
			if (echoing)
f0104a2f:	85 ff                	test   %edi,%edi
f0104a31:	74 0c                	je     f0104a3f <readline+0xbf>
				cputchar('\n');
f0104a33:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104a3a:	e8 ab bc ff ff       	call   f01006ea <cputchar>
			buf[i] = 0;
f0104a3f:	c6 86 a0 3a 23 f0 00 	movb   $0x0,-0xfdcc560(%esi)
f0104a46:	b8 a0 3a 23 f0       	mov    $0xf0233aa0,%eax
			return buf;
		}
	}
}
f0104a4b:	83 c4 1c             	add    $0x1c,%esp
f0104a4e:	5b                   	pop    %ebx
f0104a4f:	5e                   	pop    %esi
f0104a50:	5f                   	pop    %edi
f0104a51:	5d                   	pop    %ebp
f0104a52:	c3                   	ret    
	...

f0104a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104a60:	55                   	push   %ebp
f0104a61:	89 e5                	mov    %esp,%ebp
f0104a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104a66:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a6b:	80 3a 00             	cmpb   $0x0,(%edx)
f0104a6e:	74 09                	je     f0104a79 <strlen+0x19>
		n++;
f0104a70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104a73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104a77:	75 f7                	jne    f0104a70 <strlen+0x10>
		n++;
	return n;
}
f0104a79:	5d                   	pop    %ebp
f0104a7a:	c3                   	ret    

f0104a7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104a7b:	55                   	push   %ebp
f0104a7c:	89 e5                	mov    %esp,%ebp
f0104a7e:	53                   	push   %ebx
f0104a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104a85:	85 c9                	test   %ecx,%ecx
f0104a87:	74 19                	je     f0104aa2 <strnlen+0x27>
f0104a89:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104a8c:	74 14                	je     f0104aa2 <strnlen+0x27>
f0104a8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104a93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104a96:	39 c8                	cmp    %ecx,%eax
f0104a98:	74 0d                	je     f0104aa7 <strnlen+0x2c>
f0104a9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0104a9e:	75 f3                	jne    f0104a93 <strnlen+0x18>
f0104aa0:	eb 05                	jmp    f0104aa7 <strnlen+0x2c>
f0104aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104aa7:	5b                   	pop    %ebx
f0104aa8:	5d                   	pop    %ebp
f0104aa9:	c3                   	ret    

f0104aaa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104aaa:	55                   	push   %ebp
f0104aab:	89 e5                	mov    %esp,%ebp
f0104aad:	53                   	push   %ebx
f0104aae:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ab4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104ab9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104abd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104ac0:	83 c2 01             	add    $0x1,%edx
f0104ac3:	84 c9                	test   %cl,%cl
f0104ac5:	75 f2                	jne    f0104ab9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104ac7:	5b                   	pop    %ebx
f0104ac8:	5d                   	pop    %ebp
f0104ac9:	c3                   	ret    

f0104aca <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104aca:	55                   	push   %ebp
f0104acb:	89 e5                	mov    %esp,%ebp
f0104acd:	53                   	push   %ebx
f0104ace:	83 ec 08             	sub    $0x8,%esp
f0104ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104ad4:	89 1c 24             	mov    %ebx,(%esp)
f0104ad7:	e8 84 ff ff ff       	call   f0104a60 <strlen>
	strcpy(dst + len, src);
f0104adc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104adf:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ae3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0104ae6:	89 04 24             	mov    %eax,(%esp)
f0104ae9:	e8 bc ff ff ff       	call   f0104aaa <strcpy>
	return dst;
}
f0104aee:	89 d8                	mov    %ebx,%eax
f0104af0:	83 c4 08             	add    $0x8,%esp
f0104af3:	5b                   	pop    %ebx
f0104af4:	5d                   	pop    %ebp
f0104af5:	c3                   	ret    

f0104af6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104af6:	55                   	push   %ebp
f0104af7:	89 e5                	mov    %esp,%ebp
f0104af9:	56                   	push   %esi
f0104afa:	53                   	push   %ebx
f0104afb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104afe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b04:	85 f6                	test   %esi,%esi
f0104b06:	74 18                	je     f0104b20 <strncpy+0x2a>
f0104b08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104b0d:	0f b6 1a             	movzbl (%edx),%ebx
f0104b10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104b13:	80 3a 01             	cmpb   $0x1,(%edx)
f0104b16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b19:	83 c1 01             	add    $0x1,%ecx
f0104b1c:	39 ce                	cmp    %ecx,%esi
f0104b1e:	77 ed                	ja     f0104b0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104b20:	5b                   	pop    %ebx
f0104b21:	5e                   	pop    %esi
f0104b22:	5d                   	pop    %ebp
f0104b23:	c3                   	ret    

f0104b24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104b24:	55                   	push   %ebp
f0104b25:	89 e5                	mov    %esp,%ebp
f0104b27:	56                   	push   %esi
f0104b28:	53                   	push   %ebx
f0104b29:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104b32:	89 f0                	mov    %esi,%eax
f0104b34:	85 c9                	test   %ecx,%ecx
f0104b36:	74 27                	je     f0104b5f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0104b38:	83 e9 01             	sub    $0x1,%ecx
f0104b3b:	74 1d                	je     f0104b5a <strlcpy+0x36>
f0104b3d:	0f b6 1a             	movzbl (%edx),%ebx
f0104b40:	84 db                	test   %bl,%bl
f0104b42:	74 16                	je     f0104b5a <strlcpy+0x36>
			*dst++ = *src++;
f0104b44:	88 18                	mov    %bl,(%eax)
f0104b46:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104b49:	83 e9 01             	sub    $0x1,%ecx
f0104b4c:	74 0e                	je     f0104b5c <strlcpy+0x38>
			*dst++ = *src++;
f0104b4e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104b51:	0f b6 1a             	movzbl (%edx),%ebx
f0104b54:	84 db                	test   %bl,%bl
f0104b56:	75 ec                	jne    f0104b44 <strlcpy+0x20>
f0104b58:	eb 02                	jmp    f0104b5c <strlcpy+0x38>
f0104b5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104b5c:	c6 00 00             	movb   $0x0,(%eax)
f0104b5f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0104b61:	5b                   	pop    %ebx
f0104b62:	5e                   	pop    %esi
f0104b63:	5d                   	pop    %ebp
f0104b64:	c3                   	ret    

f0104b65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104b65:	55                   	push   %ebp
f0104b66:	89 e5                	mov    %esp,%ebp
f0104b68:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104b6e:	0f b6 01             	movzbl (%ecx),%eax
f0104b71:	84 c0                	test   %al,%al
f0104b73:	74 15                	je     f0104b8a <strcmp+0x25>
f0104b75:	3a 02                	cmp    (%edx),%al
f0104b77:	75 11                	jne    f0104b8a <strcmp+0x25>
		p++, q++;
f0104b79:	83 c1 01             	add    $0x1,%ecx
f0104b7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104b7f:	0f b6 01             	movzbl (%ecx),%eax
f0104b82:	84 c0                	test   %al,%al
f0104b84:	74 04                	je     f0104b8a <strcmp+0x25>
f0104b86:	3a 02                	cmp    (%edx),%al
f0104b88:	74 ef                	je     f0104b79 <strcmp+0x14>
f0104b8a:	0f b6 c0             	movzbl %al,%eax
f0104b8d:	0f b6 12             	movzbl (%edx),%edx
f0104b90:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104b92:	5d                   	pop    %ebp
f0104b93:	c3                   	ret    

f0104b94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104b94:	55                   	push   %ebp
f0104b95:	89 e5                	mov    %esp,%ebp
f0104b97:	53                   	push   %ebx
f0104b98:	8b 55 08             	mov    0x8(%ebp),%edx
f0104b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0104ba1:	85 c0                	test   %eax,%eax
f0104ba3:	74 23                	je     f0104bc8 <strncmp+0x34>
f0104ba5:	0f b6 1a             	movzbl (%edx),%ebx
f0104ba8:	84 db                	test   %bl,%bl
f0104baa:	74 25                	je     f0104bd1 <strncmp+0x3d>
f0104bac:	3a 19                	cmp    (%ecx),%bl
f0104bae:	75 21                	jne    f0104bd1 <strncmp+0x3d>
f0104bb0:	83 e8 01             	sub    $0x1,%eax
f0104bb3:	74 13                	je     f0104bc8 <strncmp+0x34>
		n--, p++, q++;
f0104bb5:	83 c2 01             	add    $0x1,%edx
f0104bb8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104bbb:	0f b6 1a             	movzbl (%edx),%ebx
f0104bbe:	84 db                	test   %bl,%bl
f0104bc0:	74 0f                	je     f0104bd1 <strncmp+0x3d>
f0104bc2:	3a 19                	cmp    (%ecx),%bl
f0104bc4:	74 ea                	je     f0104bb0 <strncmp+0x1c>
f0104bc6:	eb 09                	jmp    f0104bd1 <strncmp+0x3d>
f0104bc8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104bcd:	5b                   	pop    %ebx
f0104bce:	5d                   	pop    %ebp
f0104bcf:	90                   	nop
f0104bd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104bd1:	0f b6 02             	movzbl (%edx),%eax
f0104bd4:	0f b6 11             	movzbl (%ecx),%edx
f0104bd7:	29 d0                	sub    %edx,%eax
f0104bd9:	eb f2                	jmp    f0104bcd <strncmp+0x39>

f0104bdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104bdb:	55                   	push   %ebp
f0104bdc:	89 e5                	mov    %esp,%ebp
f0104bde:	8b 45 08             	mov    0x8(%ebp),%eax
f0104be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104be5:	0f b6 10             	movzbl (%eax),%edx
f0104be8:	84 d2                	test   %dl,%dl
f0104bea:	74 18                	je     f0104c04 <strchr+0x29>
		if (*s == c)
f0104bec:	38 ca                	cmp    %cl,%dl
f0104bee:	75 0a                	jne    f0104bfa <strchr+0x1f>
f0104bf0:	eb 17                	jmp    f0104c09 <strchr+0x2e>
f0104bf2:	38 ca                	cmp    %cl,%dl
f0104bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104bf8:	74 0f                	je     f0104c09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104bfa:	83 c0 01             	add    $0x1,%eax
f0104bfd:	0f b6 10             	movzbl (%eax),%edx
f0104c00:	84 d2                	test   %dl,%dl
f0104c02:	75 ee                	jne    f0104bf2 <strchr+0x17>
f0104c04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0104c09:	5d                   	pop    %ebp
f0104c0a:	c3                   	ret    

f0104c0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104c0b:	55                   	push   %ebp
f0104c0c:	89 e5                	mov    %esp,%ebp
f0104c0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104c15:	0f b6 10             	movzbl (%eax),%edx
f0104c18:	84 d2                	test   %dl,%dl
f0104c1a:	74 18                	je     f0104c34 <strfind+0x29>
		if (*s == c)
f0104c1c:	38 ca                	cmp    %cl,%dl
f0104c1e:	75 0a                	jne    f0104c2a <strfind+0x1f>
f0104c20:	eb 12                	jmp    f0104c34 <strfind+0x29>
f0104c22:	38 ca                	cmp    %cl,%dl
f0104c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c28:	74 0a                	je     f0104c34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104c2a:	83 c0 01             	add    $0x1,%eax
f0104c2d:	0f b6 10             	movzbl (%eax),%edx
f0104c30:	84 d2                	test   %dl,%dl
f0104c32:	75 ee                	jne    f0104c22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104c34:	5d                   	pop    %ebp
f0104c35:	c3                   	ret    

f0104c36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104c36:	55                   	push   %ebp
f0104c37:	89 e5                	mov    %esp,%ebp
f0104c39:	83 ec 0c             	sub    $0xc,%esp
f0104c3c:	89 1c 24             	mov    %ebx,(%esp)
f0104c3f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104c43:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104c47:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104c50:	85 c9                	test   %ecx,%ecx
f0104c52:	74 30                	je     f0104c84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c54:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c5a:	75 25                	jne    f0104c81 <memset+0x4b>
f0104c5c:	f6 c1 03             	test   $0x3,%cl
f0104c5f:	75 20                	jne    f0104c81 <memset+0x4b>
		c &= 0xFF;
f0104c61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104c64:	89 d3                	mov    %edx,%ebx
f0104c66:	c1 e3 08             	shl    $0x8,%ebx
f0104c69:	89 d6                	mov    %edx,%esi
f0104c6b:	c1 e6 18             	shl    $0x18,%esi
f0104c6e:	89 d0                	mov    %edx,%eax
f0104c70:	c1 e0 10             	shl    $0x10,%eax
f0104c73:	09 f0                	or     %esi,%eax
f0104c75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0104c77:	09 d8                	or     %ebx,%eax
f0104c79:	c1 e9 02             	shr    $0x2,%ecx
f0104c7c:	fc                   	cld    
f0104c7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c7f:	eb 03                	jmp    f0104c84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104c81:	fc                   	cld    
f0104c82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104c84:	89 f8                	mov    %edi,%eax
f0104c86:	8b 1c 24             	mov    (%esp),%ebx
f0104c89:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104c8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104c91:	89 ec                	mov    %ebp,%esp
f0104c93:	5d                   	pop    %ebp
f0104c94:	c3                   	ret    

f0104c95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104c95:	55                   	push   %ebp
f0104c96:	89 e5                	mov    %esp,%ebp
f0104c98:	83 ec 08             	sub    $0x8,%esp
f0104c9b:	89 34 24             	mov    %esi,(%esp)
f0104c9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ca2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ca5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0104ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0104cab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0104cad:	39 c6                	cmp    %eax,%esi
f0104caf:	73 35                	jae    f0104ce6 <memmove+0x51>
f0104cb1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104cb4:	39 d0                	cmp    %edx,%eax
f0104cb6:	73 2e                	jae    f0104ce6 <memmove+0x51>
		s += n;
		d += n;
f0104cb8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cba:	f6 c2 03             	test   $0x3,%dl
f0104cbd:	75 1b                	jne    f0104cda <memmove+0x45>
f0104cbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104cc5:	75 13                	jne    f0104cda <memmove+0x45>
f0104cc7:	f6 c1 03             	test   $0x3,%cl
f0104cca:	75 0e                	jne    f0104cda <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0104ccc:	83 ef 04             	sub    $0x4,%edi
f0104ccf:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104cd2:	c1 e9 02             	shr    $0x2,%ecx
f0104cd5:	fd                   	std    
f0104cd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cd8:	eb 09                	jmp    f0104ce3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104cda:	83 ef 01             	sub    $0x1,%edi
f0104cdd:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104ce0:	fd                   	std    
f0104ce1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104ce3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104ce4:	eb 20                	jmp    f0104d06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ce6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104cec:	75 15                	jne    f0104d03 <memmove+0x6e>
f0104cee:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104cf4:	75 0d                	jne    f0104d03 <memmove+0x6e>
f0104cf6:	f6 c1 03             	test   $0x3,%cl
f0104cf9:	75 08                	jne    f0104d03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0104cfb:	c1 e9 02             	shr    $0x2,%ecx
f0104cfe:	fc                   	cld    
f0104cff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d01:	eb 03                	jmp    f0104d06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104d03:	fc                   	cld    
f0104d04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104d06:	8b 34 24             	mov    (%esp),%esi
f0104d09:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104d0d:	89 ec                	mov    %ebp,%esp
f0104d0f:	5d                   	pop    %ebp
f0104d10:	c3                   	ret    

f0104d11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104d11:	55                   	push   %ebp
f0104d12:	89 e5                	mov    %esp,%ebp
f0104d14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104d17:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d25:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d28:	89 04 24             	mov    %eax,(%esp)
f0104d2b:	e8 65 ff ff ff       	call   f0104c95 <memmove>
}
f0104d30:	c9                   	leave  
f0104d31:	c3                   	ret    

f0104d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104d32:	55                   	push   %ebp
f0104d33:	89 e5                	mov    %esp,%ebp
f0104d35:	57                   	push   %edi
f0104d36:	56                   	push   %esi
f0104d37:	53                   	push   %ebx
f0104d38:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d41:	85 c9                	test   %ecx,%ecx
f0104d43:	74 36                	je     f0104d7b <memcmp+0x49>
		if (*s1 != *s2)
f0104d45:	0f b6 06             	movzbl (%esi),%eax
f0104d48:	0f b6 1f             	movzbl (%edi),%ebx
f0104d4b:	38 d8                	cmp    %bl,%al
f0104d4d:	74 20                	je     f0104d6f <memcmp+0x3d>
f0104d4f:	eb 14                	jmp    f0104d65 <memcmp+0x33>
f0104d51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0104d56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0104d5b:	83 c2 01             	add    $0x1,%edx
f0104d5e:	83 e9 01             	sub    $0x1,%ecx
f0104d61:	38 d8                	cmp    %bl,%al
f0104d63:	74 12                	je     f0104d77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0104d65:	0f b6 c0             	movzbl %al,%eax
f0104d68:	0f b6 db             	movzbl %bl,%ebx
f0104d6b:	29 d8                	sub    %ebx,%eax
f0104d6d:	eb 11                	jmp    f0104d80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d6f:	83 e9 01             	sub    $0x1,%ecx
f0104d72:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d77:	85 c9                	test   %ecx,%ecx
f0104d79:	75 d6                	jne    f0104d51 <memcmp+0x1f>
f0104d7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0104d80:	5b                   	pop    %ebx
f0104d81:	5e                   	pop    %esi
f0104d82:	5f                   	pop    %edi
f0104d83:	5d                   	pop    %ebp
f0104d84:	c3                   	ret    

f0104d85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d85:	55                   	push   %ebp
f0104d86:	89 e5                	mov    %esp,%ebp
f0104d88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104d8b:	89 c2                	mov    %eax,%edx
f0104d8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104d90:	39 d0                	cmp    %edx,%eax
f0104d92:	73 15                	jae    f0104da9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104d98:	38 08                	cmp    %cl,(%eax)
f0104d9a:	75 06                	jne    f0104da2 <memfind+0x1d>
f0104d9c:	eb 0b                	jmp    f0104da9 <memfind+0x24>
f0104d9e:	38 08                	cmp    %cl,(%eax)
f0104da0:	74 07                	je     f0104da9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104da2:	83 c0 01             	add    $0x1,%eax
f0104da5:	39 c2                	cmp    %eax,%edx
f0104da7:	77 f5                	ja     f0104d9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104da9:	5d                   	pop    %ebp
f0104daa:	c3                   	ret    

f0104dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104dab:	55                   	push   %ebp
f0104dac:	89 e5                	mov    %esp,%ebp
f0104dae:	57                   	push   %edi
f0104daf:	56                   	push   %esi
f0104db0:	53                   	push   %ebx
f0104db1:	83 ec 04             	sub    $0x4,%esp
f0104db4:	8b 55 08             	mov    0x8(%ebp),%edx
f0104db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104dba:	0f b6 02             	movzbl (%edx),%eax
f0104dbd:	3c 20                	cmp    $0x20,%al
f0104dbf:	74 04                	je     f0104dc5 <strtol+0x1a>
f0104dc1:	3c 09                	cmp    $0x9,%al
f0104dc3:	75 0e                	jne    f0104dd3 <strtol+0x28>
		s++;
f0104dc5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104dc8:	0f b6 02             	movzbl (%edx),%eax
f0104dcb:	3c 20                	cmp    $0x20,%al
f0104dcd:	74 f6                	je     f0104dc5 <strtol+0x1a>
f0104dcf:	3c 09                	cmp    $0x9,%al
f0104dd1:	74 f2                	je     f0104dc5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104dd3:	3c 2b                	cmp    $0x2b,%al
f0104dd5:	75 0c                	jne    f0104de3 <strtol+0x38>
		s++;
f0104dd7:	83 c2 01             	add    $0x1,%edx
f0104dda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104de1:	eb 15                	jmp    f0104df8 <strtol+0x4d>
	else if (*s == '-')
f0104de3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104dea:	3c 2d                	cmp    $0x2d,%al
f0104dec:	75 0a                	jne    f0104df8 <strtol+0x4d>
		s++, neg = 1;
f0104dee:	83 c2 01             	add    $0x1,%edx
f0104df1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104df8:	85 db                	test   %ebx,%ebx
f0104dfa:	0f 94 c0             	sete   %al
f0104dfd:	74 05                	je     f0104e04 <strtol+0x59>
f0104dff:	83 fb 10             	cmp    $0x10,%ebx
f0104e02:	75 18                	jne    f0104e1c <strtol+0x71>
f0104e04:	80 3a 30             	cmpb   $0x30,(%edx)
f0104e07:	75 13                	jne    f0104e1c <strtol+0x71>
f0104e09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104e0d:	8d 76 00             	lea    0x0(%esi),%esi
f0104e10:	75 0a                	jne    f0104e1c <strtol+0x71>
		s += 2, base = 16;
f0104e12:	83 c2 02             	add    $0x2,%edx
f0104e15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104e1a:	eb 15                	jmp    f0104e31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104e1c:	84 c0                	test   %al,%al
f0104e1e:	66 90                	xchg   %ax,%ax
f0104e20:	74 0f                	je     f0104e31 <strtol+0x86>
f0104e22:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104e27:	80 3a 30             	cmpb   $0x30,(%edx)
f0104e2a:	75 05                	jne    f0104e31 <strtol+0x86>
		s++, base = 8;
f0104e2c:	83 c2 01             	add    $0x1,%edx
f0104e2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104e31:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104e38:	0f b6 0a             	movzbl (%edx),%ecx
f0104e3b:	89 cf                	mov    %ecx,%edi
f0104e3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104e40:	80 fb 09             	cmp    $0x9,%bl
f0104e43:	77 08                	ja     f0104e4d <strtol+0xa2>
			dig = *s - '0';
f0104e45:	0f be c9             	movsbl %cl,%ecx
f0104e48:	83 e9 30             	sub    $0x30,%ecx
f0104e4b:	eb 1e                	jmp    f0104e6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0104e4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0104e50:	80 fb 19             	cmp    $0x19,%bl
f0104e53:	77 08                	ja     f0104e5d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0104e55:	0f be c9             	movsbl %cl,%ecx
f0104e58:	83 e9 57             	sub    $0x57,%ecx
f0104e5b:	eb 0e                	jmp    f0104e6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0104e5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0104e60:	80 fb 19             	cmp    $0x19,%bl
f0104e63:	77 15                	ja     f0104e7a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0104e65:	0f be c9             	movsbl %cl,%ecx
f0104e68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104e6b:	39 f1                	cmp    %esi,%ecx
f0104e6d:	7d 0b                	jge    f0104e7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0104e6f:	83 c2 01             	add    $0x1,%edx
f0104e72:	0f af c6             	imul   %esi,%eax
f0104e75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104e78:	eb be                	jmp    f0104e38 <strtol+0x8d>
f0104e7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0104e7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e80:	74 05                	je     f0104e87 <strtol+0xdc>
		*endptr = (char *) s;
f0104e82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104e87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104e8b:	74 04                	je     f0104e91 <strtol+0xe6>
f0104e8d:	89 c8                	mov    %ecx,%eax
f0104e8f:	f7 d8                	neg    %eax
}
f0104e91:	83 c4 04             	add    $0x4,%esp
f0104e94:	5b                   	pop    %ebx
f0104e95:	5e                   	pop    %esi
f0104e96:	5f                   	pop    %edi
f0104e97:	5d                   	pop    %ebp
f0104e98:	c3                   	ret    
f0104e99:	00 00                	add    %al,(%eax)
	...

f0104e9c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104e9c:	fa                   	cli    

	xorw    %ax, %ax
f0104e9d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104e9f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104ea1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104ea3:	8e d0                	mov    %eax,%ss
#stone
	lgdt    MPBOOTPHYS(gdtdesc)
f0104ea5:	0f 01 16             	lgdtl  (%esi)
f0104ea8:	74 70                	je     f0104f1a <mpentry_end+0x4>
	movl    %cr0, %eax
f0104eaa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104ead:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104eb1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104eb4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104eba:	08 00                	or     %al,(%eax)

f0104ebc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104ebc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104ec0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104ec2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104ec4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104ec6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104eca:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104ecc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104ece:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f0104ed3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104ed6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104ed9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104ede:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0104ee1:	8b 25 a4 3e 23 f0    	mov    0xf0233ea4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104ee7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104eec:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f0104ef1:	ff d0                	call   *%eax

f0104ef3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104ef3:	eb fe                	jmp    f0104ef3 <spin>
f0104ef5:	8d 76 00             	lea    0x0(%esi),%esi

f0104ef8 <gdt>:
	...
f0104f00:	ff                   	(bad)  
f0104f01:	ff 00                	incl   (%eax)
f0104f03:	00 00                	add    %al,(%eax)
f0104f05:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104f0c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0104f10 <gdtdesc>:
f0104f10:	17                   	pop    %ss
f0104f11:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104f16 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104f16:	90                   	nop
	...

f0104f20 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0104f20:	55                   	push   %ebp
f0104f21:	89 e5                	mov    %esp,%ebp
f0104f23:	56                   	push   %esi
f0104f24:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104f25:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f2a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f2f:	85 d2                	test   %edx,%edx
f0104f31:	7e 0d                	jle    f0104f40 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0104f33:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0104f37:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104f39:	83 c1 01             	add    $0x1,%ecx
f0104f3c:	39 d1                	cmp    %edx,%ecx
f0104f3e:	75 f3                	jne    f0104f33 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0104f40:	89 d8                	mov    %ebx,%eax
f0104f42:	5b                   	pop    %ebx
f0104f43:	5e                   	pop    %esi
f0104f44:	5d                   	pop    %ebp
f0104f45:	c3                   	ret    

f0104f46 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104f46:	55                   	push   %ebp
f0104f47:	89 e5                	mov    %esp,%ebp
f0104f49:	56                   	push   %esi
f0104f4a:	53                   	push   %ebx
f0104f4b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104f4e:	8b 0d a8 3e 23 f0    	mov    0xf0233ea8,%ecx
f0104f54:	89 c3                	mov    %eax,%ebx
f0104f56:	c1 eb 0c             	shr    $0xc,%ebx
f0104f59:	39 cb                	cmp    %ecx,%ebx
f0104f5b:	72 20                	jb     f0104f7d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f61:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0104f68:	f0 
f0104f69:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104f70:	00 
f0104f71:	c7 04 24 61 6f 10 f0 	movl   $0xf0106f61,(%esp)
f0104f78:	e8 08 b1 ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104f7d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104f80:	89 f2                	mov    %esi,%edx
f0104f82:	c1 ea 0c             	shr    $0xc,%edx
f0104f85:	39 d1                	cmp    %edx,%ecx
f0104f87:	77 20                	ja     f0104fa9 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f89:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104f8d:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0104f94:	f0 
f0104f95:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104f9c:	00 
f0104f9d:	c7 04 24 61 6f 10 f0 	movl   $0xf0106f61,(%esp)
f0104fa4:	e8 dc b0 ff ff       	call   f0100085 <_panic>
f0104fa9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0104faf:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0104fb5:	39 f3                	cmp    %esi,%ebx
f0104fb7:	73 33                	jae    f0104fec <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104fb9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0104fc0:	00 
f0104fc1:	c7 44 24 04 71 6f 10 	movl   $0xf0106f71,0x4(%esp)
f0104fc8:	f0 
f0104fc9:	89 1c 24             	mov    %ebx,(%esp)
f0104fcc:	e8 61 fd ff ff       	call   f0104d32 <memcmp>
f0104fd1:	85 c0                	test   %eax,%eax
f0104fd3:	75 10                	jne    f0104fe5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0104fd5:	ba 10 00 00 00       	mov    $0x10,%edx
f0104fda:	89 d8                	mov    %ebx,%eax
f0104fdc:	e8 3f ff ff ff       	call   f0104f20 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104fe1:	84 c0                	test   %al,%al
f0104fe3:	74 0c                	je     f0104ff1 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0104fe5:	83 c3 10             	add    $0x10,%ebx
f0104fe8:	39 de                	cmp    %ebx,%esi
f0104fea:	77 cd                	ja     f0104fb9 <mpsearch1+0x73>
f0104fec:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0104ff1:	89 d8                	mov    %ebx,%eax
f0104ff3:	83 c4 10             	add    $0x10,%esp
f0104ff6:	5b                   	pop    %ebx
f0104ff7:	5e                   	pop    %esi
f0104ff8:	5d                   	pop    %ebp
f0104ff9:	c3                   	ret    

f0104ffa <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104ffa:	55                   	push   %ebp
f0104ffb:	89 e5                	mov    %esp,%ebp
f0104ffd:	57                   	push   %edi
f0104ffe:	56                   	push   %esi
f0104fff:	53                   	push   %ebx
f0105000:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105003:	c7 05 c0 43 23 f0 20 	movl   $0xf0234020,0xf02343c0
f010500a:	40 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010500d:	83 3d a8 3e 23 f0 00 	cmpl   $0x0,0xf0233ea8
f0105014:	75 24                	jne    f010503a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105016:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010501d:	00 
f010501e:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f0105025:	f0 
f0105026:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010502d:	00 
f010502e:	c7 04 24 61 6f 10 f0 	movl   $0xf0106f61,(%esp)
f0105035:	e8 4b b0 ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010503a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105041:	85 c0                	test   %eax,%eax
f0105043:	74 16                	je     f010505b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105045:	c1 e0 04             	shl    $0x4,%eax
f0105048:	ba 00 04 00 00       	mov    $0x400,%edx
f010504d:	e8 f4 fe ff ff       	call   f0104f46 <mpsearch1>
f0105052:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105055:	85 c0                	test   %eax,%eax
f0105057:	75 3c                	jne    f0105095 <mp_init+0x9b>
f0105059:	eb 20                	jmp    f010507b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010505b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105062:	c1 e0 0a             	shl    $0xa,%eax
f0105065:	2d 00 04 00 00       	sub    $0x400,%eax
f010506a:	ba 00 04 00 00       	mov    $0x400,%edx
f010506f:	e8 d2 fe ff ff       	call   f0104f46 <mpsearch1>
f0105074:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105077:	85 c0                	test   %eax,%eax
f0105079:	75 1a                	jne    f0105095 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010507b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105080:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105085:	e8 bc fe ff ff       	call   f0104f46 <mpsearch1>
f010508a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010508d:	85 c0                	test   %eax,%eax
f010508f:	0f 84 27 02 00 00    	je     f01052bc <mp_init+0x2c2>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105095:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105098:	8b 78 04             	mov    0x4(%eax),%edi
f010509b:	85 ff                	test   %edi,%edi
f010509d:	74 06                	je     f01050a5 <mp_init+0xab>
f010509f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01050a3:	74 11                	je     f01050b6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01050a5:	c7 04 24 d4 6d 10 f0 	movl   $0xf0106dd4,(%esp)
f01050ac:	e8 86 e1 ff ff       	call   f0103237 <cprintf>
f01050b1:	e9 06 02 00 00       	jmp    f01052bc <mp_init+0x2c2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01050b6:	89 f8                	mov    %edi,%eax
f01050b8:	c1 e8 0c             	shr    $0xc,%eax
f01050bb:	3b 05 a8 3e 23 f0    	cmp    0xf0233ea8,%eax
f01050c1:	72 20                	jb     f01050e3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01050c3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01050c7:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f01050ce:	f0 
f01050cf:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01050d6:	00 
f01050d7:	c7 04 24 61 6f 10 f0 	movl   $0xf0106f61,(%esp)
f01050de:	e8 a2 af ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f01050e3:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01050e9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01050f0:	00 
f01050f1:	c7 44 24 04 76 6f 10 	movl   $0xf0106f76,0x4(%esp)
f01050f8:	f0 
f01050f9:	89 3c 24             	mov    %edi,(%esp)
f01050fc:	e8 31 fc ff ff       	call   f0104d32 <memcmp>
f0105101:	85 c0                	test   %eax,%eax
f0105103:	74 11                	je     f0105116 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105105:	c7 04 24 04 6e 10 f0 	movl   $0xf0106e04,(%esp)
f010510c:	e8 26 e1 ff ff       	call   f0103237 <cprintf>
f0105111:	e9 a6 01 00 00       	jmp    f01052bc <mp_init+0x2c2>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105116:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f010511a:	89 f8                	mov    %edi,%eax
f010511c:	e8 ff fd ff ff       	call   f0104f20 <sum>
f0105121:	84 c0                	test   %al,%al
f0105123:	74 11                	je     f0105136 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105125:	c7 04 24 38 6e 10 f0 	movl   $0xf0106e38,(%esp)
f010512c:	e8 06 e1 ff ff       	call   f0103237 <cprintf>
f0105131:	e9 86 01 00 00       	jmp    f01052bc <mp_init+0x2c2>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105136:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f010513a:	3c 01                	cmp    $0x1,%al
f010513c:	74 1c                	je     f010515a <mp_init+0x160>
f010513e:	3c 04                	cmp    $0x4,%al
f0105140:	74 18                	je     f010515a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105142:	0f b6 c0             	movzbl %al,%eax
f0105145:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105149:	c7 04 24 5c 6e 10 f0 	movl   $0xf0106e5c,(%esp)
f0105150:	e8 e2 e0 ff ff       	call   f0103237 <cprintf>
f0105155:	e9 62 01 00 00       	jmp    f01052bc <mp_init+0x2c2>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f010515a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010515e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0105162:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0105165:	e8 b6 fd ff ff       	call   f0104f20 <sum>
f010516a:	3a 47 2a             	cmp    0x2a(%edi),%al
f010516d:	74 11                	je     f0105180 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010516f:	c7 04 24 7c 6e 10 f0 	movl   $0xf0106e7c,(%esp)
f0105176:	e8 bc e0 ff ff       	call   f0103237 <cprintf>
f010517b:	e9 3c 01 00 00       	jmp    f01052bc <mp_init+0x2c2>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105180:	85 ff                	test   %edi,%edi
f0105182:	0f 84 34 01 00 00    	je     f01052bc <mp_init+0x2c2>
		return;
	ismp = 1;
f0105188:	c7 05 00 40 23 f0 01 	movl   $0x1,0xf0234000
f010518f:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0105192:	8b 47 24             	mov    0x24(%edi),%eax
f0105195:	a3 00 50 27 f0       	mov    %eax,0xf0275000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010519a:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f010519f:	0f 84 98 00 00 00    	je     f010523d <mp_init+0x243>
f01051a5:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f01051a8:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f01051ad:	0f b6 03             	movzbl (%ebx),%eax
f01051b0:	84 c0                	test   %al,%al
f01051b2:	74 06                	je     f01051ba <mp_init+0x1c0>
f01051b4:	3c 04                	cmp    $0x4,%al
f01051b6:	77 55                	ja     f010520d <mp_init+0x213>
f01051b8:	eb 4e                	jmp    f0105208 <mp_init+0x20e>
		case MPPROC:
			proc = (struct mpproc *)p;
f01051ba:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f01051bc:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01051c0:	74 11                	je     f01051d3 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f01051c2:	6b 05 c4 43 23 f0 74 	imul   $0x74,0xf02343c4,%eax
f01051c9:	05 20 40 23 f0       	add    $0xf0234020,%eax
f01051ce:	a3 c0 43 23 f0       	mov    %eax,0xf02343c0
			if (ncpu < NCPU) {
f01051d3:	a1 c4 43 23 f0       	mov    0xf02343c4,%eax
f01051d8:	83 f8 07             	cmp    $0x7,%eax
f01051db:	7f 12                	jg     f01051ef <mp_init+0x1f5>
				cpus[ncpu].cpu_id = ncpu;
f01051dd:	6b d0 74             	imul   $0x74,%eax,%edx
f01051e0:	88 82 20 40 23 f0    	mov    %al,-0xfdcbfe0(%edx)
				ncpu++;
f01051e6:	83 05 c4 43 23 f0 01 	addl   $0x1,0xf02343c4
f01051ed:	eb 14                	jmp    f0105203 <mp_init+0x209>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01051ef:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f01051f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051f7:	c7 04 24 ac 6e 10 f0 	movl   $0xf0106eac,(%esp)
f01051fe:	e8 34 e0 ff ff       	call   f0103237 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105203:	83 c3 14             	add    $0x14,%ebx
			continue;
f0105206:	eb 26                	jmp    f010522e <mp_init+0x234>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105208:	83 c3 08             	add    $0x8,%ebx
			continue;
f010520b:	eb 21                	jmp    f010522e <mp_init+0x234>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010520d:	0f b6 c0             	movzbl %al,%eax
f0105210:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105214:	c7 04 24 d4 6e 10 f0 	movl   $0xf0106ed4,(%esp)
f010521b:	e8 17 e0 ff ff       	call   f0103237 <cprintf>
			ismp = 0;
f0105220:	c7 05 00 40 23 f0 00 	movl   $0x0,0xf0234000
f0105227:	00 00 00 
			i = conf->entry;
f010522a:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010522e:	83 c6 01             	add    $0x1,%esi
f0105231:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105235:	39 f0                	cmp    %esi,%eax
f0105237:	0f 87 70 ff ff ff    	ja     f01051ad <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010523d:	a1 c0 43 23 f0       	mov    0xf02343c0,%eax
f0105242:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105249:	83 3d 00 40 23 f0 00 	cmpl   $0x0,0xf0234000
f0105250:	75 22                	jne    f0105274 <mp_init+0x27a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105252:	c7 05 c4 43 23 f0 01 	movl   $0x1,0xf02343c4
f0105259:	00 00 00 
		lapic = NULL;
f010525c:	c7 05 00 50 27 f0 00 	movl   $0x0,0xf0275000
f0105263:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105266:	c7 04 24 f4 6e 10 f0 	movl   $0xf0106ef4,(%esp)
f010526d:	e8 c5 df ff ff       	call   f0103237 <cprintf>
		return;
f0105272:	eb 48                	jmp    f01052bc <mp_init+0x2c2>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105274:	a1 c4 43 23 f0       	mov    0xf02343c4,%eax
f0105279:	89 44 24 08          	mov    %eax,0x8(%esp)
f010527d:	a1 c0 43 23 f0       	mov    0xf02343c0,%eax
f0105282:	0f b6 00             	movzbl (%eax),%eax
f0105285:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105289:	c7 04 24 7b 6f 10 f0 	movl   $0xf0106f7b,(%esp)
f0105290:	e8 a2 df ff ff       	call   f0103237 <cprintf>

	if (mp->imcrp) {
f0105295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105298:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010529c:	74 1e                	je     f01052bc <mp_init+0x2c2>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010529e:	c7 04 24 20 6f 10 f0 	movl   $0xf0106f20,(%esp)
f01052a5:	e8 8d df ff ff       	call   f0103237 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01052aa:	ba 22 00 00 00       	mov    $0x22,%edx
f01052af:	b8 70 00 00 00       	mov    $0x70,%eax
f01052b4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01052b5:	b2 23                	mov    $0x23,%dl
f01052b7:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01052b8:	83 c8 01             	or     $0x1,%eax
f01052bb:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01052bc:	83 c4 2c             	add    $0x2c,%esp
f01052bf:	5b                   	pop    %ebx
f01052c0:	5e                   	pop    %esi
f01052c1:	5f                   	pop    %edi
f01052c2:	5d                   	pop    %ebp
f01052c3:	c3                   	ret    

f01052c4 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f01052c4:	55                   	push   %ebp
f01052c5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01052c7:	c1 e0 02             	shl    $0x2,%eax
f01052ca:	03 05 00 50 27 f0    	add    0xf0275000,%eax
f01052d0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01052d2:	a1 00 50 27 f0       	mov    0xf0275000,%eax
f01052d7:	83 c0 20             	add    $0x20,%eax
f01052da:	8b 00                	mov    (%eax),%eax
}
f01052dc:	5d                   	pop    %ebp
f01052dd:	c3                   	ret    

f01052de <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01052de:	55                   	push   %ebp
f01052df:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01052e1:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f01052e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01052ec:	85 d2                	test   %edx,%edx
f01052ee:	74 08                	je     f01052f8 <cpunum+0x1a>
		return lapic[ID] >> 24;
f01052f0:	83 c2 20             	add    $0x20,%edx
f01052f3:	8b 02                	mov    (%edx),%eax
f01052f5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01052f8:	5d                   	pop    %ebp
f01052f9:	c3                   	ret    

f01052fa <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01052fa:	55                   	push   %ebp
f01052fb:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f01052fd:	83 3d 00 50 27 f0 00 	cmpl   $0x0,0xf0275000
f0105304:	0f 84 0b 01 00 00    	je     f0105415 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010530a:	ba 27 01 00 00       	mov    $0x127,%edx
f010530f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105314:	e8 ab ff ff ff       	call   f01052c4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105319:	ba 0b 00 00 00       	mov    $0xb,%edx
f010531e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105323:	e8 9c ff ff ff       	call   f01052c4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105328:	ba 20 00 02 00       	mov    $0x20020,%edx
f010532d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105332:	e8 8d ff ff ff       	call   f01052c4 <lapicw>
	lapicw(TICR, 10000000); 
f0105337:	ba 80 96 98 00       	mov    $0x989680,%edx
f010533c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105341:	e8 7e ff ff ff       	call   f01052c4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105346:	e8 93 ff ff ff       	call   f01052de <cpunum>
f010534b:	6b c0 74             	imul   $0x74,%eax,%eax
f010534e:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0105353:	39 05 c0 43 23 f0    	cmp    %eax,0xf02343c0
f0105359:	74 0f                	je     f010536a <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010535b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105360:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105365:	e8 5a ff ff ff       	call   f01052c4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010536a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010536f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105374:	e8 4b ff ff ff       	call   f01052c4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105379:	a1 00 50 27 f0       	mov    0xf0275000,%eax
f010537e:	83 c0 30             	add    $0x30,%eax
f0105381:	8b 00                	mov    (%eax),%eax
f0105383:	c1 e8 10             	shr    $0x10,%eax
f0105386:	3c 03                	cmp    $0x3,%al
f0105388:	76 0f                	jbe    f0105399 <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f010538a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010538f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105394:	e8 2b ff ff ff       	call   f01052c4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105399:	ba 33 00 00 00       	mov    $0x33,%edx
f010539e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01053a3:	e8 1c ff ff ff       	call   f01052c4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01053a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01053ad:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01053b2:	e8 0d ff ff ff       	call   f01052c4 <lapicw>
	lapicw(ESR, 0);
f01053b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01053bc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01053c1:	e8 fe fe ff ff       	call   f01052c4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01053c6:	ba 00 00 00 00       	mov    $0x0,%edx
f01053cb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01053d0:	e8 ef fe ff ff       	call   f01052c4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01053d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01053da:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01053df:	e8 e0 fe ff ff       	call   f01052c4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01053e4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01053e9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01053ee:	e8 d1 fe ff ff       	call   f01052c4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01053f3:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f01053f9:	81 c2 00 03 00 00    	add    $0x300,%edx
f01053ff:	8b 02                	mov    (%edx),%eax
f0105401:	f6 c4 10             	test   $0x10,%ah
f0105404:	75 f9                	jne    f01053ff <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105406:	ba 00 00 00 00       	mov    $0x0,%edx
f010540b:	b8 20 00 00 00       	mov    $0x20,%eax
f0105410:	e8 af fe ff ff       	call   f01052c4 <lapicw>
}
f0105415:	5d                   	pop    %ebp
f0105416:	c3                   	ret    

f0105417 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105417:	55                   	push   %ebp
f0105418:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010541a:	83 3d 00 50 27 f0 00 	cmpl   $0x0,0xf0275000
f0105421:	74 0f                	je     f0105432 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105423:	ba 00 00 00 00       	mov    $0x0,%edx
f0105428:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010542d:	e8 92 fe ff ff       	call   f01052c4 <lapicw>
}
f0105432:	5d                   	pop    %ebp
f0105433:	c3                   	ret    

f0105434 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0105434:	55                   	push   %ebp
f0105435:	89 e5                	mov    %esp,%ebp
}
f0105437:	5d                   	pop    %ebp
f0105438:	c3                   	ret    

f0105439 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0105439:	55                   	push   %ebp
f010543a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010543c:	8b 55 08             	mov    0x8(%ebp),%edx
f010543f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105445:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010544a:	e8 75 fe ff ff       	call   f01052c4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010544f:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f0105455:	81 c2 00 03 00 00    	add    $0x300,%edx
f010545b:	8b 02                	mov    (%edx),%eax
f010545d:	f6 c4 10             	test   $0x10,%ah
f0105460:	75 f9                	jne    f010545b <lapic_ipi+0x22>
		;
}
f0105462:	5d                   	pop    %ebp
f0105463:	c3                   	ret    

f0105464 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105464:	55                   	push   %ebp
f0105465:	89 e5                	mov    %esp,%ebp
f0105467:	56                   	push   %esi
f0105468:	53                   	push   %ebx
f0105469:	83 ec 10             	sub    $0x10,%esp
f010546c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010546f:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0105473:	ba 70 00 00 00       	mov    $0x70,%edx
f0105478:	b8 0f 00 00 00       	mov    $0xf,%eax
f010547d:	ee                   	out    %al,(%dx)
f010547e:	b2 71                	mov    $0x71,%dl
f0105480:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105485:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105486:	83 3d a8 3e 23 f0 00 	cmpl   $0x0,0xf0233ea8
f010548d:	75 24                	jne    f01054b3 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010548f:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0105496:	00 
f0105497:	c7 44 24 08 a0 5a 10 	movl   $0xf0105aa0,0x8(%esp)
f010549e:	f0 
f010549f:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01054a6:	00 
f01054a7:	c7 04 24 98 6f 10 f0 	movl   $0xf0106f98,(%esp)
f01054ae:	e8 d2 ab ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01054b3:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01054ba:	00 00 
	wrv[1] = addr >> 4;
f01054bc:	89 f0                	mov    %esi,%eax
f01054be:	c1 e8 04             	shr    $0x4,%eax
f01054c1:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01054c7:	c1 e3 18             	shl    $0x18,%ebx
f01054ca:	89 da                	mov    %ebx,%edx
f01054cc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01054d1:	e8 ee fd ff ff       	call   f01052c4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01054d6:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01054db:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01054e0:	e8 df fd ff ff       	call   f01052c4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01054e5:	ba 00 85 00 00       	mov    $0x8500,%edx
f01054ea:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01054ef:	e8 d0 fd ff ff       	call   f01052c4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01054f4:	c1 ee 0c             	shr    $0xc,%esi
f01054f7:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01054fd:	89 da                	mov    %ebx,%edx
f01054ff:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105504:	e8 bb fd ff ff       	call   f01052c4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105509:	89 f2                	mov    %esi,%edx
f010550b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105510:	e8 af fd ff ff       	call   f01052c4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105515:	89 da                	mov    %ebx,%edx
f0105517:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010551c:	e8 a3 fd ff ff       	call   f01052c4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105521:	89 f2                	mov    %esi,%edx
f0105523:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105528:	e8 97 fd ff ff       	call   f01052c4 <lapicw>
		microdelay(200);
	}
}
f010552d:	83 c4 10             	add    $0x10,%esp
f0105530:	5b                   	pop    %ebx
f0105531:	5e                   	pop    %esi
f0105532:	5d                   	pop    %ebp
f0105533:	c3                   	ret    
	...

f0105540 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105540:	55                   	push   %ebp
f0105541:	89 e5                	mov    %esp,%ebp
f0105543:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
f0105546:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lk->own = 0;
	lk->next = 0;
#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010554c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010554f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105552:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105559:	5d                   	pop    %ebp
f010555a:	c3                   	ret    

f010555b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010555b:	55                   	push   %ebp
f010555c:	89 e5                	mov    %esp,%ebp
f010555e:	53                   	push   %ebx
f010555f:	83 ec 04             	sub    $0x4,%esp
f0105562:	89 c2                	mov    %eax,%edx
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
f0105564:	b8 00 00 00 00       	mov    $0x0,%eax
f0105569:	83 3a 00             	cmpl   $0x0,(%edx)
f010556c:	74 18                	je     f0105586 <holding+0x2b>
f010556e:	8b 5a 08             	mov    0x8(%edx),%ebx
f0105571:	e8 68 fd ff ff       	call   f01052de <cpunum>
f0105576:	6b c0 74             	imul   $0x74,%eax,%eax
f0105579:	05 20 40 23 f0       	add    $0xf0234020,%eax
f010557e:	39 c3                	cmp    %eax,%ebx
f0105580:	0f 94 c0             	sete   %al
f0105583:	0f b6 c0             	movzbl %al,%eax
	//LAB 4: Your code here
	/*stone's solution for lab4-A*/
	//panic("ticket spinlock: not implemented yet");
	return lock->own != lock->next && lock->cpu == thiscpu;
#endif
}
f0105586:	83 c4 04             	add    $0x4,%esp
f0105589:	5b                   	pop    %ebx
f010558a:	5d                   	pop    %ebp
f010558b:	c3                   	ret    

f010558c <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010558c:	55                   	push   %ebp
f010558d:	89 e5                	mov    %esp,%ebp
f010558f:	83 ec 78             	sub    $0x78,%esp
f0105592:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105595:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105598:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010559b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010559e:	89 d8                	mov    %ebx,%eax
f01055a0:	e8 b6 ff ff ff       	call   f010555b <holding>
f01055a5:	85 c0                	test   %eax,%eax
f01055a7:	0f 85 d5 00 00 00    	jne    f0105682 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01055ad:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01055b4:	00 
f01055b5:	8d 43 0c             	lea    0xc(%ebx),%eax
f01055b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055bc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01055bf:	89 04 24             	mov    %eax,(%esp)
f01055c2:	e8 ce f6 ff ff       	call   f0104c95 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01055c7:	8b 43 08             	mov    0x8(%ebx),%eax
f01055ca:	0f b6 30             	movzbl (%eax),%esi
f01055cd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01055d0:	e8 09 fd ff ff       	call   f01052de <cpunum>
f01055d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01055d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01055dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055e1:	c7 04 24 a8 6f 10 f0 	movl   $0xf0106fa8,(%esp)
f01055e8:	e8 4a dc ff ff       	call   f0103237 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01055ed:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01055f0:	85 c0                	test   %eax,%eax
f01055f2:	74 72                	je     f0105666 <spin_unlock+0xda>
f01055f4:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01055f7:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01055fa:	8d 75 d0             	lea    -0x30(%ebp),%esi
f01055fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105601:	89 04 24             	mov    %eax,(%esp)
f0105604:	e8 75 ea ff ff       	call   f010407e <debuginfo_eip>
f0105609:	85 c0                	test   %eax,%eax
f010560b:	78 39                	js     f0105646 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010560d:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010560f:	89 c2                	mov    %eax,%edx
f0105611:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0105614:	89 54 24 18          	mov    %edx,0x18(%esp)
f0105618:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010561b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010561f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105622:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105626:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105629:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010562d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105630:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105634:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105638:	c7 04 24 0c 70 10 f0 	movl   $0xf010700c,(%esp)
f010563f:	e8 f3 db ff ff       	call   f0103237 <cprintf>
f0105644:	eb 12                	jmp    f0105658 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105646:	8b 03                	mov    (%ebx),%eax
f0105648:	89 44 24 04          	mov    %eax,0x4(%esp)
f010564c:	c7 04 24 23 70 10 f0 	movl   $0xf0107023,(%esp)
f0105653:	e8 df db ff ff       	call   f0103237 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105658:	39 fb                	cmp    %edi,%ebx
f010565a:	74 0a                	je     f0105666 <spin_unlock+0xda>
f010565c:	8b 43 04             	mov    0x4(%ebx),%eax
f010565f:	83 c3 04             	add    $0x4,%ebx
f0105662:	85 c0                	test   %eax,%eax
f0105664:	75 97                	jne    f01055fd <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105666:	c7 44 24 08 2b 70 10 	movl   $0xf010702b,0x8(%esp)
f010566d:	f0 
f010566e:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
f0105675:	00 
f0105676:	c7 04 24 37 70 10 f0 	movl   $0xf0107037,(%esp)
f010567d:	e8 03 aa ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f0105682:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0105689:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105690:	b8 00 00 00 00       	mov    $0x0,%eax
f0105695:	f0 87 03             	lock xchg %eax,(%ebx)
#else
	//LAB 4: Your code here
	/*stone's solution for lab4-A*/
	atomic_return_and_add(&(lk->own), 1);
#endif
}
f0105698:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010569b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010569e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01056a1:	89 ec                	mov    %ebp,%esp
f01056a3:	5d                   	pop    %ebp
f01056a4:	c3                   	ret    

f01056a5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01056a5:	55                   	push   %ebp
f01056a6:	89 e5                	mov    %esp,%ebp
f01056a8:	56                   	push   %esi
f01056a9:	53                   	push   %ebx
f01056aa:	83 ec 20             	sub    $0x20,%esp
f01056ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01056b0:	89 d8                	mov    %ebx,%eax
f01056b2:	e8 a4 fe ff ff       	call   f010555b <holding>
f01056b7:	85 c0                	test   %eax,%eax
f01056b9:	75 12                	jne    f01056cd <spin_lock+0x28>

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01056bb:	89 da                	mov    %ebx,%edx
f01056bd:	b0 01                	mov    $0x1,%al
f01056bf:	f0 87 03             	lock xchg %eax,(%ebx)
f01056c2:	b9 01 00 00 00       	mov    $0x1,%ecx
f01056c7:	85 c0                	test   %eax,%eax
f01056c9:	75 2e                	jne    f01056f9 <spin_lock+0x54>
f01056cb:	eb 37                	jmp    f0105704 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01056cd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01056d0:	e8 09 fc ff ff       	call   f01052de <cpunum>
f01056d5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01056d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01056dd:	c7 44 24 08 e0 6f 10 	movl   $0xf0106fe0,0x8(%esp)
f01056e4:	f0 
f01056e5:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f01056ec:	00 
f01056ed:	c7 04 24 37 70 10 f0 	movl   $0xf0107037,(%esp)
f01056f4:	e8 8c a9 ff ff       	call   f0100085 <_panic>
#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01056f9:	f3 90                	pause  
f01056fb:	89 c8                	mov    %ecx,%eax
f01056fd:	f0 87 02             	lock xchg %eax,(%edx)

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105700:	85 c0                	test   %eax,%eax
f0105702:	75 f5                	jne    f01056f9 <spin_lock+0x54>
	while (lk->own != target);
#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105704:	e8 d5 fb ff ff       	call   f01052de <cpunum>
f0105709:	6b c0 74             	imul   $0x74,%eax,%eax
f010570c:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0105711:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105714:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0105717:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0105719:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f010571f:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0105725:	76 40                	jbe    f0105767 <spin_lock+0xc2>
f0105727:	eb 33                	jmp    f010575c <spin_lock+0xb7>
f0105729:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f010572f:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0105735:	77 2a                	ja     f0105761 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105737:	8b 4a 04             	mov    0x4(%edx),%ecx
f010573a:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010573d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010573f:	83 c0 01             	add    $0x1,%eax
f0105742:	83 f8 0a             	cmp    $0xa,%eax
f0105745:	75 e2                	jne    f0105729 <spin_lock+0x84>
f0105747:	eb 2d                	jmp    f0105776 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105749:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010574f:	83 c0 01             	add    $0x1,%eax
f0105752:	83 c2 04             	add    $0x4,%edx
f0105755:	83 f8 09             	cmp    $0x9,%eax
f0105758:	7e ef                	jle    f0105749 <spin_lock+0xa4>
f010575a:	eb 1a                	jmp    f0105776 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010575c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0105761:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0105765:	eb e2                	jmp    f0105749 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105767:	8b 50 04             	mov    0x4(%eax),%edx
f010576a:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010576d:	8b 10                	mov    (%eax),%edx
f010576f:	b8 01 00 00 00       	mov    $0x1,%eax
f0105774:	eb b3                	jmp    f0105729 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105776:	83 c4 20             	add    $0x20,%esp
f0105779:	5b                   	pop    %ebx
f010577a:	5e                   	pop    %esi
f010577b:	5d                   	pop    %ebp
f010577c:	c3                   	ret    
f010577d:	00 00                	add    %al,(%eax)
	...

f0105780 <__udivdi3>:
f0105780:	55                   	push   %ebp
f0105781:	89 e5                	mov    %esp,%ebp
f0105783:	57                   	push   %edi
f0105784:	56                   	push   %esi
f0105785:	83 ec 10             	sub    $0x10,%esp
f0105788:	8b 45 14             	mov    0x14(%ebp),%eax
f010578b:	8b 55 08             	mov    0x8(%ebp),%edx
f010578e:	8b 75 10             	mov    0x10(%ebp),%esi
f0105791:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105794:	85 c0                	test   %eax,%eax
f0105796:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0105799:	75 35                	jne    f01057d0 <__udivdi3+0x50>
f010579b:	39 fe                	cmp    %edi,%esi
f010579d:	77 61                	ja     f0105800 <__udivdi3+0x80>
f010579f:	85 f6                	test   %esi,%esi
f01057a1:	75 0b                	jne    f01057ae <__udivdi3+0x2e>
f01057a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01057a8:	31 d2                	xor    %edx,%edx
f01057aa:	f7 f6                	div    %esi
f01057ac:	89 c6                	mov    %eax,%esi
f01057ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01057b1:	31 d2                	xor    %edx,%edx
f01057b3:	89 f8                	mov    %edi,%eax
f01057b5:	f7 f6                	div    %esi
f01057b7:	89 c7                	mov    %eax,%edi
f01057b9:	89 c8                	mov    %ecx,%eax
f01057bb:	f7 f6                	div    %esi
f01057bd:	89 c1                	mov    %eax,%ecx
f01057bf:	89 fa                	mov    %edi,%edx
f01057c1:	89 c8                	mov    %ecx,%eax
f01057c3:	83 c4 10             	add    $0x10,%esp
f01057c6:	5e                   	pop    %esi
f01057c7:	5f                   	pop    %edi
f01057c8:	5d                   	pop    %ebp
f01057c9:	c3                   	ret    
f01057ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01057d0:	39 f8                	cmp    %edi,%eax
f01057d2:	77 1c                	ja     f01057f0 <__udivdi3+0x70>
f01057d4:	0f bd d0             	bsr    %eax,%edx
f01057d7:	83 f2 1f             	xor    $0x1f,%edx
f01057da:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01057dd:	75 39                	jne    f0105818 <__udivdi3+0x98>
f01057df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01057e2:	0f 86 a0 00 00 00    	jbe    f0105888 <__udivdi3+0x108>
f01057e8:	39 f8                	cmp    %edi,%eax
f01057ea:	0f 82 98 00 00 00    	jb     f0105888 <__udivdi3+0x108>
f01057f0:	31 ff                	xor    %edi,%edi
f01057f2:	31 c9                	xor    %ecx,%ecx
f01057f4:	89 c8                	mov    %ecx,%eax
f01057f6:	89 fa                	mov    %edi,%edx
f01057f8:	83 c4 10             	add    $0x10,%esp
f01057fb:	5e                   	pop    %esi
f01057fc:	5f                   	pop    %edi
f01057fd:	5d                   	pop    %ebp
f01057fe:	c3                   	ret    
f01057ff:	90                   	nop
f0105800:	89 d1                	mov    %edx,%ecx
f0105802:	89 fa                	mov    %edi,%edx
f0105804:	89 c8                	mov    %ecx,%eax
f0105806:	31 ff                	xor    %edi,%edi
f0105808:	f7 f6                	div    %esi
f010580a:	89 c1                	mov    %eax,%ecx
f010580c:	89 fa                	mov    %edi,%edx
f010580e:	89 c8                	mov    %ecx,%eax
f0105810:	83 c4 10             	add    $0x10,%esp
f0105813:	5e                   	pop    %esi
f0105814:	5f                   	pop    %edi
f0105815:	5d                   	pop    %ebp
f0105816:	c3                   	ret    
f0105817:	90                   	nop
f0105818:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010581c:	89 f2                	mov    %esi,%edx
f010581e:	d3 e0                	shl    %cl,%eax
f0105820:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105823:	b8 20 00 00 00       	mov    $0x20,%eax
f0105828:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010582b:	89 c1                	mov    %eax,%ecx
f010582d:	d3 ea                	shr    %cl,%edx
f010582f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105833:	0b 55 ec             	or     -0x14(%ebp),%edx
f0105836:	d3 e6                	shl    %cl,%esi
f0105838:	89 c1                	mov    %eax,%ecx
f010583a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010583d:	89 fe                	mov    %edi,%esi
f010583f:	d3 ee                	shr    %cl,%esi
f0105841:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105845:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105848:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010584b:	d3 e7                	shl    %cl,%edi
f010584d:	89 c1                	mov    %eax,%ecx
f010584f:	d3 ea                	shr    %cl,%edx
f0105851:	09 d7                	or     %edx,%edi
f0105853:	89 f2                	mov    %esi,%edx
f0105855:	89 f8                	mov    %edi,%eax
f0105857:	f7 75 ec             	divl   -0x14(%ebp)
f010585a:	89 d6                	mov    %edx,%esi
f010585c:	89 c7                	mov    %eax,%edi
f010585e:	f7 65 e8             	mull   -0x18(%ebp)
f0105861:	39 d6                	cmp    %edx,%esi
f0105863:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105866:	72 30                	jb     f0105898 <__udivdi3+0x118>
f0105868:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010586b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010586f:	d3 e2                	shl    %cl,%edx
f0105871:	39 c2                	cmp    %eax,%edx
f0105873:	73 05                	jae    f010587a <__udivdi3+0xfa>
f0105875:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0105878:	74 1e                	je     f0105898 <__udivdi3+0x118>
f010587a:	89 f9                	mov    %edi,%ecx
f010587c:	31 ff                	xor    %edi,%edi
f010587e:	e9 71 ff ff ff       	jmp    f01057f4 <__udivdi3+0x74>
f0105883:	90                   	nop
f0105884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105888:	31 ff                	xor    %edi,%edi
f010588a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010588f:	e9 60 ff ff ff       	jmp    f01057f4 <__udivdi3+0x74>
f0105894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105898:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010589b:	31 ff                	xor    %edi,%edi
f010589d:	89 c8                	mov    %ecx,%eax
f010589f:	89 fa                	mov    %edi,%edx
f01058a1:	83 c4 10             	add    $0x10,%esp
f01058a4:	5e                   	pop    %esi
f01058a5:	5f                   	pop    %edi
f01058a6:	5d                   	pop    %ebp
f01058a7:	c3                   	ret    
	...

f01058b0 <__umoddi3>:
f01058b0:	55                   	push   %ebp
f01058b1:	89 e5                	mov    %esp,%ebp
f01058b3:	57                   	push   %edi
f01058b4:	56                   	push   %esi
f01058b5:	83 ec 20             	sub    $0x20,%esp
f01058b8:	8b 55 14             	mov    0x14(%ebp),%edx
f01058bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01058be:	8b 7d 10             	mov    0x10(%ebp),%edi
f01058c1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058c4:	85 d2                	test   %edx,%edx
f01058c6:	89 c8                	mov    %ecx,%eax
f01058c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01058cb:	75 13                	jne    f01058e0 <__umoddi3+0x30>
f01058cd:	39 f7                	cmp    %esi,%edi
f01058cf:	76 3f                	jbe    f0105910 <__umoddi3+0x60>
f01058d1:	89 f2                	mov    %esi,%edx
f01058d3:	f7 f7                	div    %edi
f01058d5:	89 d0                	mov    %edx,%eax
f01058d7:	31 d2                	xor    %edx,%edx
f01058d9:	83 c4 20             	add    $0x20,%esp
f01058dc:	5e                   	pop    %esi
f01058dd:	5f                   	pop    %edi
f01058de:	5d                   	pop    %ebp
f01058df:	c3                   	ret    
f01058e0:	39 f2                	cmp    %esi,%edx
f01058e2:	77 4c                	ja     f0105930 <__umoddi3+0x80>
f01058e4:	0f bd ca             	bsr    %edx,%ecx
f01058e7:	83 f1 1f             	xor    $0x1f,%ecx
f01058ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01058ed:	75 51                	jne    f0105940 <__umoddi3+0x90>
f01058ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01058f2:	0f 87 e0 00 00 00    	ja     f01059d8 <__umoddi3+0x128>
f01058f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01058fb:	29 f8                	sub    %edi,%eax
f01058fd:	19 d6                	sbb    %edx,%esi
f01058ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0105902:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105905:	89 f2                	mov    %esi,%edx
f0105907:	83 c4 20             	add    $0x20,%esp
f010590a:	5e                   	pop    %esi
f010590b:	5f                   	pop    %edi
f010590c:	5d                   	pop    %ebp
f010590d:	c3                   	ret    
f010590e:	66 90                	xchg   %ax,%ax
f0105910:	85 ff                	test   %edi,%edi
f0105912:	75 0b                	jne    f010591f <__umoddi3+0x6f>
f0105914:	b8 01 00 00 00       	mov    $0x1,%eax
f0105919:	31 d2                	xor    %edx,%edx
f010591b:	f7 f7                	div    %edi
f010591d:	89 c7                	mov    %eax,%edi
f010591f:	89 f0                	mov    %esi,%eax
f0105921:	31 d2                	xor    %edx,%edx
f0105923:	f7 f7                	div    %edi
f0105925:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105928:	f7 f7                	div    %edi
f010592a:	eb a9                	jmp    f01058d5 <__umoddi3+0x25>
f010592c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105930:	89 c8                	mov    %ecx,%eax
f0105932:	89 f2                	mov    %esi,%edx
f0105934:	83 c4 20             	add    $0x20,%esp
f0105937:	5e                   	pop    %esi
f0105938:	5f                   	pop    %edi
f0105939:	5d                   	pop    %ebp
f010593a:	c3                   	ret    
f010593b:	90                   	nop
f010593c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105940:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105944:	d3 e2                	shl    %cl,%edx
f0105946:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0105949:	ba 20 00 00 00       	mov    $0x20,%edx
f010594e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0105951:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105954:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105958:	89 fa                	mov    %edi,%edx
f010595a:	d3 ea                	shr    %cl,%edx
f010595c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105960:	0b 55 f4             	or     -0xc(%ebp),%edx
f0105963:	d3 e7                	shl    %cl,%edi
f0105965:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105969:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010596c:	89 f2                	mov    %esi,%edx
f010596e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0105971:	89 c7                	mov    %eax,%edi
f0105973:	d3 ea                	shr    %cl,%edx
f0105975:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105979:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010597c:	89 c2                	mov    %eax,%edx
f010597e:	d3 e6                	shl    %cl,%esi
f0105980:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105984:	d3 ea                	shr    %cl,%edx
f0105986:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010598a:	09 d6                	or     %edx,%esi
f010598c:	89 f0                	mov    %esi,%eax
f010598e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105991:	d3 e7                	shl    %cl,%edi
f0105993:	89 f2                	mov    %esi,%edx
f0105995:	f7 75 f4             	divl   -0xc(%ebp)
f0105998:	89 d6                	mov    %edx,%esi
f010599a:	f7 65 e8             	mull   -0x18(%ebp)
f010599d:	39 d6                	cmp    %edx,%esi
f010599f:	72 2b                	jb     f01059cc <__umoddi3+0x11c>
f01059a1:	39 c7                	cmp    %eax,%edi
f01059a3:	72 23                	jb     f01059c8 <__umoddi3+0x118>
f01059a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01059a9:	29 c7                	sub    %eax,%edi
f01059ab:	19 d6                	sbb    %edx,%esi
f01059ad:	89 f0                	mov    %esi,%eax
f01059af:	89 f2                	mov    %esi,%edx
f01059b1:	d3 ef                	shr    %cl,%edi
f01059b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01059b7:	d3 e0                	shl    %cl,%eax
f01059b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01059bd:	09 f8                	or     %edi,%eax
f01059bf:	d3 ea                	shr    %cl,%edx
f01059c1:	83 c4 20             	add    $0x20,%esp
f01059c4:	5e                   	pop    %esi
f01059c5:	5f                   	pop    %edi
f01059c6:	5d                   	pop    %ebp
f01059c7:	c3                   	ret    
f01059c8:	39 d6                	cmp    %edx,%esi
f01059ca:	75 d9                	jne    f01059a5 <__umoddi3+0xf5>
f01059cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01059cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01059d2:	eb d1                	jmp    f01059a5 <__umoddi3+0xf5>
f01059d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01059d8:	39 f2                	cmp    %esi,%edx
f01059da:	0f 82 18 ff ff ff    	jb     f01058f8 <__umoddi3+0x48>
f01059e0:	e9 1d ff ff ff       	jmp    f0105902 <__umoddi3+0x52>
