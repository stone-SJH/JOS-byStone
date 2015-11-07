
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
f0100039:	e8 2a 01 00 00       	call   f0100168 <i386_init>

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
f0100058:	c7 04 24 40 58 10 f0 	movl   $0xf0105840,(%esp)
f010005f:	e8 97 30 00 00       	call   f01030fb <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 55 30 00 00       	call   f01030c8 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 68 59 10 f0 	movl   $0xf0105968,(%esp)
f010007a:	e8 7c 30 00 00       	call   f01030fb <cprintf>
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
f0100090:	83 3d 00 3f 23 f0 00 	cmpl   $0x0,0xf0233f00
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 00 3f 23 f0    	mov    %esi,0xf0233f00

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
f01000a4:	e8 75 50 00 00       	call   f010511e <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 98 58 10 f0 	movl   $0xf0105898,(%esp)
f01000c2:	e8 34 30 00 00       	call   f01030fb <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 f5 2f 00 00       	call   f01030c8 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 68 59 10 f0 	movl   $0xf0105968,(%esp)
f01000da:	e8 1c 30 00 00       	call   f01030fb <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 0f 0a 00 00       	call   f0100afa <monitor>
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
f01000f3:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000fd:	77 20                	ja     f010011f <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100103:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f010010a:	f0 
f010010b:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
f0100112:	00 
f0100113:	c7 04 24 5a 58 10 f0 	movl   $0xf010585a,(%esp)
f010011a:	e8 66 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010011f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0100125:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100128:	e8 f1 4f 00 00       	call   f010511e <cpunum>
f010012d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100131:	c7 04 24 66 58 10 f0 	movl   $0xf0105866,(%esp)
f0100138:	e8 be 2f 00 00       	call   f01030fb <cprintf>

	lapic_init();
f010013d:	e8 f8 4f 00 00       	call   f010513a <lapic_init>
	env_init_percpu();
f0100142:	e8 49 25 00 00       	call   f0102690 <env_init_percpu>
	trap_init_percpu();
f0100147:	e8 e4 2f 00 00       	call   f0103130 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100150:	e8 c9 4f 00 00       	call   f010511e <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 40 23 f0    	add    $0xf0234024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010015e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100163:	f0 87 02             	lock xchg %eax,(%edx)
f0100166:	eb fe                	jmp    f0100166 <mp_main+0x79>

f0100168 <i386_init>:
	unlock_kernel();
}

void
i386_init(void)
{
f0100168:	55                   	push   %ebp
f0100169:	89 e5                	mov    %esp,%ebp
f010016b:	56                   	push   %esi
f010016c:	53                   	push   %ebx
f010016d:	83 ec 10             	sub    $0x10,%esp
	
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100170:	b8 04 50 27 f0       	mov    $0xf0275004,%eax
f0100175:	2d 27 29 23 f0       	sub    $0xf0232927,%eax
f010017a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010017e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100185:	00 
f0100186:	c7 04 24 27 29 23 f0 	movl   $0xf0232927,(%esp)
f010018d:	e8 e4 48 00 00       	call   f0104a76 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100192:	e8 1e 06 00 00       	call   f01007b5 <cons_init>

//<<<<<<< HEAD
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100197:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010019e:	00 
f010019f:	c7 04 24 7c 58 10 f0 	movl   $0xf010587c,(%esp)
f01001a6:	e8 50 2f 00 00       	call   f01030fb <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
	*/
//>>>>>>> lab2

	// Lab 2 memory management initialization functions
	mem_init();
f01001ab:	e8 54 17 00 00       	call   f0101904 <mem_init>
	//cprintf("1\n");
	// Lab 3 user environment initialization functions
	env_init();
f01001b0:	e8 7c 29 00 00       	call   f0102b31 <env_init>
	//cprintf("2\n");
	trap_init();
f01001b5:	e8 d3 2f 00 00       	call   f010318d <trap_init>
//<<<<<<< HEAD

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ba:	e8 7b 4c 00 00       	call   f0104e3a <mp_init>
	lapic_init();
f01001bf:	90                   	nop
f01001c0:	e8 75 4f 00 00       	call   f010513a <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001c5:	e8 6f 2e 00 00       	call   f0103039 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001ca:	83 3d 08 3f 23 f0 07 	cmpl   $0x7,0xf0233f08
f01001d1:	77 24                	ja     f01001f7 <i386_init+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d3:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001da:	00 
f01001db:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f01001e2:	f0 
f01001e3:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
f01001ea:	00 
f01001eb:	c7 04 24 5a 58 10 f0 	movl   $0xf010585a,(%esp)
f01001f2:	e8 8e fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001f7:	b8 56 4d 10 f0       	mov    $0xf0104d56,%eax
f01001fc:	2d dc 4c 10 f0       	sub    $0xf0104cdc,%eax
f0100201:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100205:	c7 44 24 04 dc 4c 10 	movl   $0xf0104cdc,0x4(%esp)
f010020c:	f0 
f010020d:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100214:	e8 bc 48 00 00       	call   f0104ad5 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100219:	6b 05 c4 43 23 f0 74 	imul   $0x74,0xf02343c4,%eax
f0100220:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0100225:	3d 20 40 23 f0       	cmp    $0xf0234020,%eax
f010022a:	76 65                	jbe    f0100291 <i386_init+0x129>
f010022c:	be 00 00 00 00       	mov    $0x0,%esi
f0100231:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100236:	e8 e3 4e 00 00       	call   f010511e <cpunum>
f010023b:	6b c0 74             	imul   $0x74,%eax,%eax
f010023e:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0100243:	39 c3                	cmp    %eax,%ebx
f0100245:	74 34                	je     f010027b <i386_init+0x113>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100247:	89 f0                	mov    %esi,%eax
f0100249:	c1 f8 02             	sar    $0x2,%eax
f010024c:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100252:	c1 e0 0f             	shl    $0xf,%eax
f0100255:	8d 80 00 d0 23 f0    	lea    -0xfdc3000(%eax),%eax
f010025b:	a3 04 3f 23 f0       	mov    %eax,0xf0233f04
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100260:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100267:	00 
f0100268:	0f b6 03             	movzbl (%ebx),%eax
f010026b:	89 04 24             	mov    %eax,(%esp)
f010026e:	e8 31 50 00 00       	call   f01052a4 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100273:	8b 43 04             	mov    0x4(%ebx),%eax
f0100276:	83 f8 01             	cmp    $0x1,%eax
f0100279:	75 f8                	jne    f0100273 <i386_init+0x10b>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010027b:	83 c3 74             	add    $0x74,%ebx
f010027e:	83 c6 74             	add    $0x74,%esi
f0100281:	6b 05 c4 43 23 f0 74 	imul   $0x74,0xf02343c4,%eax
f0100288:	05 20 40 23 f0       	add    $0xf0234020,%eax
f010028d:	39 c3                	cmp    %eax,%ebx
f010028f:	72 a5                	jb     f0100236 <i386_init+0xce>
			;
	}
//=======
	// We only have one user environment for now, so just run it.
	//cprintf("4\n");
	env_run(&envs[0]);
f0100291:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0100296:	89 04 24             	mov    %eax,(%esp)
f0100299:	e8 05 25 00 00       	call   f01027a3 <env_run>

f010029e <spinlock_test>:
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	56                   	push   %esi
f01002a2:	53                   	push   %ebx
f01002a3:	83 ec 20             	sub    $0x20,%esp
	int i;
	volatile int interval = 0;
f01002a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
f01002ad:	e8 6c 4e 00 00       	call   f010511e <cpunum>
f01002b2:	85 c0                	test   %eax,%eax
f01002b4:	75 10                	jne    f01002c6 <spinlock_test+0x28>
		while (interval++ < 10000)
f01002b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01002b9:	8d 50 01             	lea    0x1(%eax),%edx
f01002bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01002bf:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01002c4:	7e 0c                	jle    f01002d2 <spinlock_test+0x34>
f01002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01002cb:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f01002d0:	eb 14                	jmp    f01002e6 <spinlock_test+0x48>
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
f01002d2:	f3 90                	pause  
	int i;
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
f01002d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01002d7:	8d 50 01             	lea    0x1(%eax),%edx
f01002da:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01002dd:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01002e2:	7e ee                	jle    f01002d2 <spinlock_test+0x34>
f01002e4:	eb e0                	jmp    f01002c6 <spinlock_test+0x28>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01002e6:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01002ed:	e8 f3 51 00 00       	call   f01054e5 <spin_lock>
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01002f2:	8b 0d 00 30 23 f0    	mov    0xf0233000,%ecx
f01002f8:	89 c8                	mov    %ecx,%eax
f01002fa:	f7 ee                	imul   %esi
f01002fc:	c1 fa 0c             	sar    $0xc,%edx
f01002ff:	89 c8                	mov    %ecx,%eax
f0100301:	c1 f8 1f             	sar    $0x1f,%eax
f0100304:	29 c2                	sub    %eax,%edx
f0100306:	69 d2 10 27 00 00    	imul   $0x2710,%edx,%edx
f010030c:	39 d1                	cmp    %edx,%ecx
f010030e:	74 1c                	je     f010032c <spinlock_test+0x8e>
			panic("ticket spinlock test fail: I saw a middle value\n");
f0100310:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f0100317:	f0 
f0100318:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
f010031f:	00 
f0100320:	c7 04 24 5a 58 10 f0 	movl   $0xf010585a,(%esp)
f0100327:	e8 59 fd ff ff       	call   f0100085 <_panic>
		interval = 0;
f010032c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (interval++ < 10000)
f0100333:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100336:	8d 50 01             	lea    0x1(%eax),%edx
f0100339:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010033c:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100341:	7f 1d                	jg     f0100360 <spinlock_test+0xc2>
			test_ctr++;
f0100343:	a1 00 30 23 f0       	mov    0xf0233000,%eax
f0100348:	83 c0 01             	add    $0x1,%eax
f010034b:	a3 00 30 23 f0       	mov    %eax,0xf0233000
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
f0100350:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100353:	8d 50 01             	lea    0x1(%eax),%edx
f0100356:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100359:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010035e:	7e e3                	jle    f0100343 <spinlock_test+0xa5>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100360:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f0100367:	e8 60 50 00 00       	call   f01053cc <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010036c:	f3 90                	pause  
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
f010036e:	83 c3 01             	add    $0x1,%ebx
f0100371:	83 fb 64             	cmp    $0x64,%ebx
f0100374:	0f 85 6c ff ff ff    	jne    f01002e6 <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010037a:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f0100381:	e8 5f 51 00 00       	call   f01054e5 <spin_lock>
		while (interval++ < 10000)
			test_ctr++;
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f0100386:	e8 93 4d 00 00       	call   f010511e <cpunum>
f010038b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010038f:	c7 04 24 38 59 10 f0 	movl   $0xf0105938,(%esp)
f0100396:	e8 60 2d 00 00       	call   f01030fb <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010039b:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f01003a2:	e8 25 50 00 00       	call   f01053cc <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01003a7:	f3 90                	pause  
	unlock_kernel();
}
f01003a9:	83 c4 20             	add    $0x20,%esp
f01003ac:	5b                   	pop    %ebx
f01003ad:	5e                   	pop    %esi
f01003ae:	5d                   	pop    %ebp
f01003af:	c3                   	ret    

f01003b0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01003b0:	55                   	push   %ebp
f01003b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b3:	ba 84 00 00 00       	mov    $0x84,%edx
f01003b8:	ec                   	in     (%dx),%al
f01003b9:	ec                   	in     (%dx),%al
f01003ba:	ec                   	in     (%dx),%al
f01003bb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01003bc:	5d                   	pop    %ebp
f01003bd:	c3                   	ret    

f01003be <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003be:	55                   	push   %ebp
f01003bf:	89 e5                	mov    %esp,%ebp
f01003c1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01003c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003ce:	f6 c2 01             	test   $0x1,%dl
f01003d1:	74 09                	je     f01003dc <serial_proc_data+0x1e>
f01003d3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01003d9:	0f b6 c0             	movzbl %al,%eax
}
f01003dc:	5d                   	pop    %ebp
f01003dd:	c3                   	ret    

f01003de <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	57                   	push   %edi
f01003e2:	56                   	push   %esi
f01003e3:	53                   	push   %ebx
f01003e4:	83 ec 0c             	sub    $0xc,%esp
f01003e7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01003e9:	bb 44 32 23 f0       	mov    $0xf0233244,%ebx
f01003ee:	bf 40 30 23 f0       	mov    $0xf0233040,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003f3:	eb 1e                	jmp    f0100413 <cons_intr+0x35>
		if (c == 0)
f01003f5:	85 c0                	test   %eax,%eax
f01003f7:	74 1a                	je     f0100413 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01003f9:	8b 13                	mov    (%ebx),%edx
f01003fb:	88 04 17             	mov    %al,(%edi,%edx,1)
f01003fe:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100401:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100406:	0f 94 c2             	sete   %dl
f0100409:	0f b6 d2             	movzbl %dl,%edx
f010040c:	83 ea 01             	sub    $0x1,%edx
f010040f:	21 d0                	and    %edx,%eax
f0100411:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100413:	ff d6                	call   *%esi
f0100415:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100418:	75 db                	jne    f01003f5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010041a:	83 c4 0c             	add    $0xc,%esp
f010041d:	5b                   	pop    %ebx
f010041e:	5e                   	pop    %esi
f010041f:	5f                   	pop    %edi
f0100420:	5d                   	pop    %ebp
f0100421:	c3                   	ret    

f0100422 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100422:	55                   	push   %ebp
f0100423:	89 e5                	mov    %esp,%ebp
f0100425:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100428:	b8 ba 06 10 f0       	mov    $0xf01006ba,%eax
f010042d:	e8 ac ff ff ff       	call   f01003de <cons_intr>
}
f0100432:	c9                   	leave  
f0100433:	c3                   	ret    

f0100434 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100434:	55                   	push   %ebp
f0100435:	89 e5                	mov    %esp,%ebp
f0100437:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010043a:	83 3d 24 30 23 f0 00 	cmpl   $0x0,0xf0233024
f0100441:	74 0a                	je     f010044d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100443:	b8 be 03 10 f0       	mov    $0xf01003be,%eax
f0100448:	e8 91 ff ff ff       	call   f01003de <cons_intr>
}
f010044d:	c9                   	leave  
f010044e:	c3                   	ret    

f010044f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010044f:	55                   	push   %ebp
f0100450:	89 e5                	mov    %esp,%ebp
f0100452:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100455:	e8 da ff ff ff       	call   f0100434 <serial_intr>
	kbd_intr();
f010045a:	e8 c3 ff ff ff       	call   f0100422 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010045f:	8b 15 40 32 23 f0    	mov    0xf0233240,%edx
f0100465:	b8 00 00 00 00       	mov    $0x0,%eax
f010046a:	3b 15 44 32 23 f0    	cmp    0xf0233244,%edx
f0100470:	74 21                	je     f0100493 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100472:	0f b6 82 40 30 23 f0 	movzbl -0xfdccfc0(%edx),%eax
f0100479:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010047c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100482:	0f 94 c1             	sete   %cl
f0100485:	0f b6 c9             	movzbl %cl,%ecx
f0100488:	83 e9 01             	sub    $0x1,%ecx
f010048b:	21 ca                	and    %ecx,%edx
f010048d:	89 15 40 32 23 f0    	mov    %edx,0xf0233240
		return c;
	}
	return 0;
}
f0100493:	c9                   	leave  
f0100494:	c3                   	ret    

f0100495 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100495:	55                   	push   %ebp
f0100496:	89 e5                	mov    %esp,%ebp
f0100498:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010049b:	e8 af ff ff ff       	call   f010044f <cons_getc>
f01004a0:	85 c0                	test   %eax,%eax
f01004a2:	74 f7                	je     f010049b <getchar+0x6>
		/* do nothing */;
	return c;
}
f01004a4:	c9                   	leave  
f01004a5:	c3                   	ret    

f01004a6 <iscons>:

int
iscons(int fdnum)
{
f01004a6:	55                   	push   %ebp
f01004a7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01004a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01004ae:	5d                   	pop    %ebp
f01004af:	c3                   	ret    

f01004b0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004b0:	55                   	push   %ebp
f01004b1:	89 e5                	mov    %esp,%ebp
f01004b3:	57                   	push   %edi
f01004b4:	56                   	push   %esi
f01004b5:	53                   	push   %ebx
f01004b6:	83 ec 2c             	sub    $0x2c,%esp
f01004b9:	89 c7                	mov    %eax,%edi
f01004bb:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01004c0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01004c1:	a8 20                	test   $0x20,%al
f01004c3:	75 21                	jne    f01004e6 <cons_putc+0x36>
f01004c5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004ca:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01004cf:	e8 dc fe ff ff       	call   f01003b0 <delay>
f01004d4:	89 f2                	mov    %esi,%edx
f01004d6:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01004d7:	a8 20                	test   $0x20,%al
f01004d9:	75 0b                	jne    f01004e6 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01004db:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01004de:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01004e4:	75 e9                	jne    f01004cf <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01004e6:	89 fa                	mov    %edi,%edx
f01004e8:	89 f8                	mov    %edi,%eax
f01004ea:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004ed:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004f2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004f3:	b2 79                	mov    $0x79,%dl
f01004f5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004f6:	84 c0                	test   %al,%al
f01004f8:	78 21                	js     f010051b <cons_putc+0x6b>
f01004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004ff:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100504:	e8 a7 fe ff ff       	call   f01003b0 <delay>
f0100509:	89 f2                	mov    %esi,%edx
f010050b:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010050c:	84 c0                	test   %al,%al
f010050e:	78 0b                	js     f010051b <cons_putc+0x6b>
f0100510:	83 c3 01             	add    $0x1,%ebx
f0100513:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100519:	75 e9                	jne    f0100504 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010051b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100520:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100524:	ee                   	out    %al,(%dx)
f0100525:	b2 7a                	mov    $0x7a,%dl
f0100527:	b8 0d 00 00 00       	mov    $0xd,%eax
f010052c:	ee                   	out    %al,(%dx)
f010052d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100532:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100533:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100539:	75 06                	jne    f0100541 <cons_putc+0x91>
		c |= 0x0700;
f010053b:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100541:	89 f8                	mov    %edi,%eax
f0100543:	25 ff 00 00 00       	and    $0xff,%eax
f0100548:	83 f8 09             	cmp    $0x9,%eax
f010054b:	0f 84 83 00 00 00    	je     f01005d4 <cons_putc+0x124>
f0100551:	83 f8 09             	cmp    $0x9,%eax
f0100554:	7f 0c                	jg     f0100562 <cons_putc+0xb2>
f0100556:	83 f8 08             	cmp    $0x8,%eax
f0100559:	0f 85 a9 00 00 00    	jne    f0100608 <cons_putc+0x158>
f010055f:	90                   	nop
f0100560:	eb 18                	jmp    f010057a <cons_putc+0xca>
f0100562:	83 f8 0a             	cmp    $0xa,%eax
f0100565:	8d 76 00             	lea    0x0(%esi),%esi
f0100568:	74 40                	je     f01005aa <cons_putc+0xfa>
f010056a:	83 f8 0d             	cmp    $0xd,%eax
f010056d:	8d 76 00             	lea    0x0(%esi),%esi
f0100570:	0f 85 92 00 00 00    	jne    f0100608 <cons_putc+0x158>
f0100576:	66 90                	xchg   %ax,%ax
f0100578:	eb 38                	jmp    f01005b2 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010057a:	0f b7 05 30 30 23 f0 	movzwl 0xf0233030,%eax
f0100581:	66 85 c0             	test   %ax,%ax
f0100584:	0f 84 e8 00 00 00    	je     f0100672 <cons_putc+0x1c2>
			crt_pos--;
f010058a:	83 e8 01             	sub    $0x1,%eax
f010058d:	66 a3 30 30 23 f0    	mov    %ax,0xf0233030
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100593:	0f b7 c0             	movzwl %ax,%eax
f0100596:	66 81 e7 00 ff       	and    $0xff00,%di
f010059b:	83 cf 20             	or     $0x20,%edi
f010059e:	8b 15 2c 30 23 f0    	mov    0xf023302c,%edx
f01005a4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005a8:	eb 7b                	jmp    f0100625 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01005aa:	66 83 05 30 30 23 f0 	addw   $0x50,0xf0233030
f01005b1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01005b2:	0f b7 05 30 30 23 f0 	movzwl 0xf0233030,%eax
f01005b9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01005bf:	c1 e8 10             	shr    $0x10,%eax
f01005c2:	66 c1 e8 06          	shr    $0x6,%ax
f01005c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005c9:	c1 e0 04             	shl    $0x4,%eax
f01005cc:	66 a3 30 30 23 f0    	mov    %ax,0xf0233030
f01005d2:	eb 51                	jmp    f0100625 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01005d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01005d9:	e8 d2 fe ff ff       	call   f01004b0 <cons_putc>
		cons_putc(' ');
f01005de:	b8 20 00 00 00       	mov    $0x20,%eax
f01005e3:	e8 c8 fe ff ff       	call   f01004b0 <cons_putc>
		cons_putc(' ');
f01005e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ed:	e8 be fe ff ff       	call   f01004b0 <cons_putc>
		cons_putc(' ');
f01005f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01005f7:	e8 b4 fe ff ff       	call   f01004b0 <cons_putc>
		cons_putc(' ');
f01005fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0100601:	e8 aa fe ff ff       	call   f01004b0 <cons_putc>
f0100606:	eb 1d                	jmp    f0100625 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100608:	0f b7 05 30 30 23 f0 	movzwl 0xf0233030,%eax
f010060f:	0f b7 c8             	movzwl %ax,%ecx
f0100612:	8b 15 2c 30 23 f0    	mov    0xf023302c,%edx
f0100618:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010061c:	83 c0 01             	add    $0x1,%eax
f010061f:	66 a3 30 30 23 f0    	mov    %ax,0xf0233030
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100625:	66 81 3d 30 30 23 f0 	cmpw   $0x7cf,0xf0233030
f010062c:	cf 07 
f010062e:	76 42                	jbe    f0100672 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100630:	a1 2c 30 23 f0       	mov    0xf023302c,%eax
f0100635:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010063c:	00 
f010063d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100643:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100647:	89 04 24             	mov    %eax,(%esp)
f010064a:	e8 86 44 00 00       	call   f0104ad5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010064f:	8b 15 2c 30 23 f0    	mov    0xf023302c,%edx
f0100655:	b8 80 07 00 00       	mov    $0x780,%eax
f010065a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100660:	83 c0 01             	add    $0x1,%eax
f0100663:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100668:	75 f0                	jne    f010065a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010066a:	66 83 2d 30 30 23 f0 	subw   $0x50,0xf0233030
f0100671:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100672:	8b 0d 28 30 23 f0    	mov    0xf0233028,%ecx
f0100678:	89 cb                	mov    %ecx,%ebx
f010067a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067f:	89 ca                	mov    %ecx,%edx
f0100681:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100682:	0f b7 35 30 30 23 f0 	movzwl 0xf0233030,%esi
f0100689:	83 c1 01             	add    $0x1,%ecx
f010068c:	89 f0                	mov    %esi,%eax
f010068e:	66 c1 e8 08          	shr    $0x8,%ax
f0100692:	89 ca                	mov    %ecx,%edx
f0100694:	ee                   	out    %al,(%dx)
f0100695:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069a:	89 da                	mov    %ebx,%edx
f010069c:	ee                   	out    %al,(%dx)
f010069d:	89 f0                	mov    %esi,%eax
f010069f:	89 ca                	mov    %ecx,%edx
f01006a1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01006a2:	83 c4 2c             	add    $0x2c,%esp
f01006a5:	5b                   	pop    %ebx
f01006a6:	5e                   	pop    %esi
f01006a7:	5f                   	pop    %edi
f01006a8:	5d                   	pop    %ebp
f01006a9:	c3                   	ret    

f01006aa <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006aa:	55                   	push   %ebp
f01006ab:	89 e5                	mov    %esp,%ebp
f01006ad:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01006b3:	e8 f8 fd ff ff       	call   f01004b0 <cons_putc>
}
f01006b8:	c9                   	leave  
f01006b9:	c3                   	ret    

f01006ba <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01006ba:	55                   	push   %ebp
f01006bb:	89 e5                	mov    %esp,%ebp
f01006bd:	53                   	push   %ebx
f01006be:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c1:	ba 64 00 00 00       	mov    $0x64,%edx
f01006c6:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01006c7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01006cc:	a8 01                	test   $0x1,%al
f01006ce:	0f 84 d9 00 00 00    	je     f01007ad <kbd_proc_data+0xf3>
f01006d4:	b2 60                	mov    $0x60,%dl
f01006d6:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01006d7:	3c e0                	cmp    $0xe0,%al
f01006d9:	75 11                	jne    f01006ec <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01006db:	83 0d 20 30 23 f0 40 	orl    $0x40,0xf0233020
f01006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006e7:	e9 c1 00 00 00       	jmp    f01007ad <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01006ec:	84 c0                	test   %al,%al
f01006ee:	79 32                	jns    f0100722 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006f0:	8b 15 20 30 23 f0    	mov    0xf0233020,%edx
f01006f6:	f6 c2 40             	test   $0x40,%dl
f01006f9:	75 03                	jne    f01006fe <kbd_proc_data+0x44>
f01006fb:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01006fe:	0f b6 c0             	movzbl %al,%eax
f0100701:	0f b6 80 a0 59 10 f0 	movzbl -0xfefa660(%eax),%eax
f0100708:	83 c8 40             	or     $0x40,%eax
f010070b:	0f b6 c0             	movzbl %al,%eax
f010070e:	f7 d0                	not    %eax
f0100710:	21 c2                	and    %eax,%edx
f0100712:	89 15 20 30 23 f0    	mov    %edx,0xf0233020
f0100718:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010071d:	e9 8b 00 00 00       	jmp    f01007ad <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100722:	8b 15 20 30 23 f0    	mov    0xf0233020,%edx
f0100728:	f6 c2 40             	test   $0x40,%dl
f010072b:	74 0c                	je     f0100739 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010072d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100730:	83 e2 bf             	and    $0xffffffbf,%edx
f0100733:	89 15 20 30 23 f0    	mov    %edx,0xf0233020
	}

	shift |= shiftcode[data];
f0100739:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010073c:	0f b6 90 a0 59 10 f0 	movzbl -0xfefa660(%eax),%edx
f0100743:	0b 15 20 30 23 f0    	or     0xf0233020,%edx
f0100749:	0f b6 88 a0 5a 10 f0 	movzbl -0xfefa560(%eax),%ecx
f0100750:	31 ca                	xor    %ecx,%edx
f0100752:	89 15 20 30 23 f0    	mov    %edx,0xf0233020

	c = charcode[shift & (CTL | SHIFT)][data];
f0100758:	89 d1                	mov    %edx,%ecx
f010075a:	83 e1 03             	and    $0x3,%ecx
f010075d:	8b 0c 8d a0 5b 10 f0 	mov    -0xfefa460(,%ecx,4),%ecx
f0100764:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100768:	f6 c2 08             	test   $0x8,%dl
f010076b:	74 1a                	je     f0100787 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010076d:	89 d9                	mov    %ebx,%ecx
f010076f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100772:	83 f8 19             	cmp    $0x19,%eax
f0100775:	77 05                	ja     f010077c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100777:	83 eb 20             	sub    $0x20,%ebx
f010077a:	eb 0b                	jmp    f0100787 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010077c:	83 e9 41             	sub    $0x41,%ecx
f010077f:	83 f9 19             	cmp    $0x19,%ecx
f0100782:	77 03                	ja     f0100787 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100784:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100787:	f7 d2                	not    %edx
f0100789:	f6 c2 06             	test   $0x6,%dl
f010078c:	75 1f                	jne    f01007ad <kbd_proc_data+0xf3>
f010078e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100794:	75 17                	jne    f01007ad <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100796:	c7 04 24 5e 59 10 f0 	movl   $0xf010595e,(%esp)
f010079d:	e8 59 29 00 00       	call   f01030fb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01007a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01007ac:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01007ad:	89 d8                	mov    %ebx,%eax
f01007af:	83 c4 14             	add    $0x14,%esp
f01007b2:	5b                   	pop    %ebx
f01007b3:	5d                   	pop    %ebp
f01007b4:	c3                   	ret    

f01007b5 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01007b5:	55                   	push   %ebp
f01007b6:	89 e5                	mov    %esp,%ebp
f01007b8:	57                   	push   %edi
f01007b9:	56                   	push   %esi
f01007ba:	53                   	push   %ebx
f01007bb:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01007be:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01007c3:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01007c6:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01007cb:	0f b7 00             	movzwl (%eax),%eax
f01007ce:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01007d2:	74 11                	je     f01007e5 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01007d4:	c7 05 28 30 23 f0 b4 	movl   $0x3b4,0xf0233028
f01007db:	03 00 00 
f01007de:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007e3:	eb 16                	jmp    f01007fb <cons_init+0x46>
	} else {
		*cp = was;
f01007e5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007ec:	c7 05 28 30 23 f0 d4 	movl   $0x3d4,0xf0233028
f01007f3:	03 00 00 
f01007f6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01007fb:	8b 0d 28 30 23 f0    	mov    0xf0233028,%ecx
f0100801:	89 cb                	mov    %ecx,%ebx
f0100803:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100808:	89 ca                	mov    %ecx,%edx
f010080a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010080b:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010080e:	89 ca                	mov    %ecx,%edx
f0100810:	ec                   	in     (%dx),%al
f0100811:	0f b6 f8             	movzbl %al,%edi
f0100814:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100817:	b8 0f 00 00 00       	mov    $0xf,%eax
f010081c:	89 da                	mov    %ebx,%edx
f010081e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010081f:	89 ca                	mov    %ecx,%edx
f0100821:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100822:	89 35 2c 30 23 f0    	mov    %esi,0xf023302c
	crt_pos = pos;
f0100828:	0f b6 c8             	movzbl %al,%ecx
f010082b:	09 cf                	or     %ecx,%edi
f010082d:	66 89 3d 30 30 23 f0 	mov    %di,0xf0233030

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100834:	e8 e9 fb ff ff       	call   f0100422 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100839:	0f b7 05 70 f3 11 f0 	movzwl 0xf011f370,%eax
f0100840:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100845:	89 04 24             	mov    %eax,(%esp)
f0100848:	e8 7b 27 00 00       	call   f0102fc8 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010084d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100852:	b8 00 00 00 00       	mov    $0x0,%eax
f0100857:	89 da                	mov    %ebx,%edx
f0100859:	ee                   	out    %al,(%dx)
f010085a:	b2 fb                	mov    $0xfb,%dl
f010085c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100861:	ee                   	out    %al,(%dx)
f0100862:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100867:	b8 0c 00 00 00       	mov    $0xc,%eax
f010086c:	89 ca                	mov    %ecx,%edx
f010086e:	ee                   	out    %al,(%dx)
f010086f:	b2 f9                	mov    $0xf9,%dl
f0100871:	b8 00 00 00 00       	mov    $0x0,%eax
f0100876:	ee                   	out    %al,(%dx)
f0100877:	b2 fb                	mov    $0xfb,%dl
f0100879:	b8 03 00 00 00       	mov    $0x3,%eax
f010087e:	ee                   	out    %al,(%dx)
f010087f:	b2 fc                	mov    $0xfc,%dl
f0100881:	b8 00 00 00 00       	mov    $0x0,%eax
f0100886:	ee                   	out    %al,(%dx)
f0100887:	b2 f9                	mov    $0xf9,%dl
f0100889:	b8 01 00 00 00       	mov    $0x1,%eax
f010088e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010088f:	b2 fd                	mov    $0xfd,%dl
f0100891:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100892:	3c ff                	cmp    $0xff,%al
f0100894:	0f 95 c0             	setne  %al
f0100897:	0f b6 f0             	movzbl %al,%esi
f010089a:	89 35 24 30 23 f0    	mov    %esi,0xf0233024
f01008a0:	89 da                	mov    %ebx,%edx
f01008a2:	ec                   	in     (%dx),%al
f01008a3:	89 ca                	mov    %ecx,%edx
f01008a5:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008a6:	85 f6                	test   %esi,%esi
f01008a8:	75 0c                	jne    f01008b6 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f01008aa:	c7 04 24 6a 59 10 f0 	movl   $0xf010596a,(%esp)
f01008b1:	e8 45 28 00 00       	call   f01030fb <cprintf>
}
f01008b6:	83 c4 1c             	add    $0x1c,%esp
f01008b9:	5b                   	pop    %ebx
f01008ba:	5e                   	pop    %esi
f01008bb:	5f                   	pop    %edi
f01008bc:	5d                   	pop    %ebp
f01008bd:	c3                   	ret    
	...

f01008c0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01008c0:	55                   	push   %ebp
f01008c1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01008c3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01008c6:	5d                   	pop    %ebp
f01008c7:	c3                   	ret    

f01008c8 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f01008c8:	55                   	push   %ebp
f01008c9:	89 e5                	mov    %esp,%ebp
f01008cb:	57                   	push   %edi
f01008cc:	56                   	push   %esi
f01008cd:	53                   	push   %ebx
f01008ce:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f01008d4:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01008da:	b9 40 00 00 00       	mov    $0x40,%ecx
f01008df:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e4:	f3 ab                	rep stos %eax,%es:(%edi)
    int nstr = 0;
    char *pret_addr;

	// Your code here.
    	/* stone's solution for exercise16 */
	pret_addr = (char *)read_pretaddr();
f01008e6:	8d 75 04             	lea    0x4(%ebp),%esi
	uint32_t targ_addr = (uint32_t)do_overflow + 3;//reserve the stack.
f01008e9:	bf f1 09 10 f0       	mov    $0xf01009f1,%edi
	int i;
	for( i = 0; i < 256; i++)
		str[i] = '1';
f01008ee:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
f01008f4:	c6 04 02 31          	movb   $0x31,(%edx,%eax,1)
	// Your code here.
    	/* stone's solution for exercise16 */
	pret_addr = (char *)read_pretaddr();
	uint32_t targ_addr = (uint32_t)do_overflow + 3;//reserve the stack.
	int i;
	for( i = 0; i < 256; i++)
f01008f8:	83 c0 01             	add    $0x1,%eax
f01008fb:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100900:	75 f2                	jne    f01008f4 <start_overflow+0x2c>
		str[i] = '1';
	uint32_t targ_frag1 = targ_addr & 0xFF;
f0100902:	89 f8                	mov    %edi,%eax
f0100904:	25 ff 00 00 00       	and    $0xff,%eax
f0100909:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag1] = '\0';
f010090f:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100916:	00 
	cprintf("%s%n", str, pret_addr);
f0100917:	89 74 24 08          	mov    %esi,0x8(%esp)
f010091b:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100925:	c7 04 24 b0 5b 10 f0 	movl   $0xf0105bb0,(%esp)
f010092c:	e8 ca 27 00 00       	call   f01030fb <cprintf>
	str[targ_frag1] = '1';
f0100931:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f0100937:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f010093e:	31 

	uint32_t targ_frag2 = (targ_addr>>8) & 0xFF;
f010093f:	89 f8                	mov    %edi,%eax
f0100941:	0f b6 c4             	movzbl %ah,%eax
f0100944:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag2] = '\0';
f010094a:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100951:	00 
	cprintf("%s%n", str, pret_addr+1);
f0100952:	8d 46 01             	lea    0x1(%esi),%eax
f0100955:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100959:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010095d:	c7 04 24 b0 5b 10 f0 	movl   $0xf0105bb0,(%esp)
f0100964:	e8 92 27 00 00       	call   f01030fb <cprintf>
	str[targ_frag2] = '1';
f0100969:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f010096f:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f0100976:	31 

	uint32_t targ_frag3 = (targ_addr>>16) & 0xFF;
f0100977:	89 f8                	mov    %edi,%eax
f0100979:	c1 e8 10             	shr    $0x10,%eax
f010097c:	25 ff 00 00 00       	and    $0xff,%eax
f0100981:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag3] = '\0';
f0100987:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f010098e:	00 
	cprintf("%s%n", str, pret_addr+2);
f010098f:	8d 46 02             	lea    0x2(%esi),%eax
f0100992:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100996:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010099a:	c7 04 24 b0 5b 10 f0 	movl   $0xf0105bb0,(%esp)
f01009a1:	e8 55 27 00 00       	call   f01030fb <cprintf>
	str[targ_frag3] = '1';
f01009a6:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f01009ac:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f01009b3:	31 

	uint32_t targ_frag4 = (targ_addr>>24) & 0xFF;
	str[targ_frag4] = '\0';
f01009b4:	c1 ef 18             	shr    $0x18,%edi
f01009b7:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f01009be:	00 
	cprintf("%s%n\n", str, pret_addr+3);
f01009bf:	83 c6 03             	add    $0x3,%esi
f01009c2:	89 74 24 08          	mov    %esi,0x8(%esp)
f01009c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009ca:	c7 04 24 b5 5b 10 f0 	movl   $0xf0105bb5,(%esp)
f01009d1:	e8 25 27 00 00       	call   f01030fb <cprintf>
	str[targ_frag4] = '1';
}
f01009d6:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f01009dc:	5b                   	pop    %ebx
f01009dd:	5e                   	pop    %esi
f01009de:	5f                   	pop    %edi
f01009df:	5d                   	pop    %ebp
f01009e0:	c3                   	ret    

f01009e1 <overflow_me>:

void
overflow_me(void)
{
f01009e1:	55                   	push   %ebp
f01009e2:	89 e5                	mov    %esp,%ebp
f01009e4:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f01009e7:	e8 dc fe ff ff       	call   f01008c8 <start_overflow>
}
f01009ec:	c9                   	leave  
f01009ed:	c3                   	ret    

f01009ee <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f01009ee:	55                   	push   %ebp
f01009ef:	89 e5                	mov    %esp,%ebp
f01009f1:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f01009f4:	c7 04 24 bb 5b 10 f0 	movl   $0xf0105bbb,(%esp)
f01009fb:	e8 fb 26 00 00       	call   f01030fb <cprintf>
}
f0100a00:	c9                   	leave  
f0100a01:	c3                   	ret    

f0100a02 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100a02:	55                   	push   %ebp
f0100a03:	89 e5                	mov    %esp,%ebp
f0100a05:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100a08:	c7 04 24 cd 5b 10 f0 	movl   $0xf0105bcd,(%esp)
f0100a0f:	e8 e7 26 00 00       	call   f01030fb <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100a14:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100a1b:	00 
f0100a1c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100a23:	f0 
f0100a24:	c7 04 24 00 5d 10 f0 	movl   $0xf0105d00,(%esp)
f0100a2b:	e8 cb 26 00 00       	call   f01030fb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a30:	c7 44 24 08 25 58 10 	movl   $0x105825,0x8(%esp)
f0100a37:	00 
f0100a38:	c7 44 24 04 25 58 10 	movl   $0xf0105825,0x4(%esp)
f0100a3f:	f0 
f0100a40:	c7 04 24 24 5d 10 f0 	movl   $0xf0105d24,(%esp)
f0100a47:	e8 af 26 00 00       	call   f01030fb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a4c:	c7 44 24 08 27 29 23 	movl   $0x232927,0x8(%esp)
f0100a53:	00 
f0100a54:	c7 44 24 04 27 29 23 	movl   $0xf0232927,0x4(%esp)
f0100a5b:	f0 
f0100a5c:	c7 04 24 48 5d 10 f0 	movl   $0xf0105d48,(%esp)
f0100a63:	e8 93 26 00 00       	call   f01030fb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a68:	c7 44 24 08 04 50 27 	movl   $0x275004,0x8(%esp)
f0100a6f:	00 
f0100a70:	c7 44 24 04 04 50 27 	movl   $0xf0275004,0x4(%esp)
f0100a77:	f0 
f0100a78:	c7 04 24 6c 5d 10 f0 	movl   $0xf0105d6c,(%esp)
f0100a7f:	e8 77 26 00 00       	call   f01030fb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a84:	b8 03 54 27 f0       	mov    $0xf0275403,%eax
f0100a89:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100a8e:	89 c2                	mov    %eax,%edx
f0100a90:	c1 fa 1f             	sar    $0x1f,%edx
f0100a93:	c1 ea 16             	shr    $0x16,%edx
f0100a96:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100a99:	c1 f8 0a             	sar    $0xa,%eax
f0100a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa0:	c7 04 24 90 5d 10 f0 	movl   $0xf0105d90,(%esp)
f0100aa7:	e8 4f 26 00 00       	call   f01030fb <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100aac:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab1:	c9                   	leave  
f0100ab2:	c3                   	ret    

f0100ab3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100ab3:	55                   	push   %ebp
f0100ab4:	89 e5                	mov    %esp,%ebp
f0100ab6:	57                   	push   %edi
f0100ab7:	56                   	push   %esi
f0100ab8:	53                   	push   %ebx
f0100ab9:	83 ec 1c             	sub    $0x1c,%esp
f0100abc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100ac1:	be 24 5f 10 f0       	mov    $0xf0105f24,%esi
f0100ac6:	bf 20 5f 10 f0       	mov    $0xf0105f20,%edi
f0100acb:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100ace:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ad2:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f0100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad9:	c7 04 24 e6 5b 10 f0 	movl   $0xf0105be6,(%esp)
f0100ae0:	e8 16 26 00 00       	call   f01030fb <cprintf>
f0100ae5:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100ae8:	83 fb 54             	cmp    $0x54,%ebx
f0100aeb:	75 de                	jne    f0100acb <mon_help+0x18>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100aed:	b8 00 00 00 00       	mov    $0x0,%eax
f0100af2:	83 c4 1c             	add    $0x1c,%esp
f0100af5:	5b                   	pop    %ebx
f0100af6:	5e                   	pop    %esi
f0100af7:	5f                   	pop    %edi
f0100af8:	5d                   	pop    %ebp
f0100af9:	c3                   	ret    

f0100afa <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100afa:	55                   	push   %ebp
f0100afb:	89 e5                	mov    %esp,%ebp
f0100afd:	57                   	push   %edi
f0100afe:	56                   	push   %esi
f0100aff:	53                   	push   %ebx
f0100b00:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b03:	c7 04 24 bc 5d 10 f0 	movl   $0xf0105dbc,(%esp)
f0100b0a:	e8 ec 25 00 00       	call   f01030fb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b0f:	c7 04 24 e0 5d 10 f0 	movl   $0xf0105de0,(%esp)
f0100b16:	e8 e0 25 00 00       	call   f01030fb <cprintf>

	if (tf != NULL)
f0100b1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b1f:	74 0b                	je     f0100b2c <monitor+0x32>
		print_trapframe(tf);
f0100b21:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b24:	89 04 24             	mov    %eax,(%esp)
f0100b27:	e8 3b 2a 00 00       	call   f0103567 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100b2c:	c7 04 24 ef 5b 10 f0 	movl   $0xf0105bef,(%esp)
f0100b33:	e8 88 3c 00 00       	call   f01047c0 <readline>
f0100b38:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b3a:	85 c0                	test   %eax,%eax
f0100b3c:	74 ee                	je     f0100b2c <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b3e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100b45:	be 00 00 00 00       	mov    $0x0,%esi
f0100b4a:	eb 06                	jmp    f0100b52 <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b4c:	c6 03 00             	movb   $0x0,(%ebx)
f0100b4f:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b52:	0f b6 03             	movzbl (%ebx),%eax
f0100b55:	84 c0                	test   %al,%al
f0100b57:	74 6c                	je     f0100bc5 <monitor+0xcb>
f0100b59:	0f be c0             	movsbl %al,%eax
f0100b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b60:	c7 04 24 f3 5b 10 f0 	movl   $0xf0105bf3,(%esp)
f0100b67:	e8 af 3e 00 00       	call   f0104a1b <strchr>
f0100b6c:	85 c0                	test   %eax,%eax
f0100b6e:	75 dc                	jne    f0100b4c <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100b70:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b73:	74 50                	je     f0100bc5 <monitor+0xcb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b75:	83 fe 0f             	cmp    $0xf,%esi
f0100b78:	75 16                	jne    f0100b90 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b7a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b81:	00 
f0100b82:	c7 04 24 f8 5b 10 f0 	movl   $0xf0105bf8,(%esp)
f0100b89:	e8 6d 25 00 00       	call   f01030fb <cprintf>
f0100b8e:	eb 9c                	jmp    f0100b2c <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100b90:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b94:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b97:	0f b6 03             	movzbl (%ebx),%eax
f0100b9a:	84 c0                	test   %al,%al
f0100b9c:	75 0e                	jne    f0100bac <monitor+0xb2>
f0100b9e:	66 90                	xchg   %ax,%ax
f0100ba0:	eb b0                	jmp    f0100b52 <monitor+0x58>
			buf++;
f0100ba2:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ba5:	0f b6 03             	movzbl (%ebx),%eax
f0100ba8:	84 c0                	test   %al,%al
f0100baa:	74 a6                	je     f0100b52 <monitor+0x58>
f0100bac:	0f be c0             	movsbl %al,%eax
f0100baf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bb3:	c7 04 24 f3 5b 10 f0 	movl   $0xf0105bf3,(%esp)
f0100bba:	e8 5c 3e 00 00       	call   f0104a1b <strchr>
f0100bbf:	85 c0                	test   %eax,%eax
f0100bc1:	74 df                	je     f0100ba2 <monitor+0xa8>
f0100bc3:	eb 8d                	jmp    f0100b52 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100bc5:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100bcc:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100bcd:	85 f6                	test   %esi,%esi
f0100bcf:	90                   	nop
f0100bd0:	0f 84 56 ff ff ff    	je     f0100b2c <monitor+0x32>
f0100bd6:	bb 20 5f 10 f0       	mov    $0xf0105f20,%ebx
f0100bdb:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100be0:	8b 03                	mov    (%ebx),%eax
f0100be2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100be9:	89 04 24             	mov    %eax,(%esp)
f0100bec:	e8 b4 3d 00 00       	call   f01049a5 <strcmp>
f0100bf1:	85 c0                	test   %eax,%eax
f0100bf3:	75 23                	jne    f0100c18 <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f0100bf5:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100bf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bff:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c06:	89 34 24             	mov    %esi,(%esp)
f0100c09:	ff 97 28 5f 10 f0    	call   *-0xfefa0d8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c0f:	85 c0                	test   %eax,%eax
f0100c11:	78 28                	js     f0100c3b <monitor+0x141>
f0100c13:	e9 14 ff ff ff       	jmp    f0100b2c <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c18:	83 c7 01             	add    $0x1,%edi
f0100c1b:	83 c3 0c             	add    $0xc,%ebx
f0100c1e:	83 ff 07             	cmp    $0x7,%edi
f0100c21:	75 bd                	jne    f0100be0 <monitor+0xe6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c23:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2a:	c7 04 24 15 5c 10 f0 	movl   $0xf0105c15,(%esp)
f0100c31:	e8 c5 24 00 00       	call   f01030fb <cprintf>
f0100c36:	e9 f1 fe ff ff       	jmp    f0100b2c <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c3b:	83 c4 5c             	add    $0x5c,%esp
f0100c3e:	5b                   	pop    %ebx
f0100c3f:	5e                   	pop    %esi
f0100c40:	5f                   	pop    %edi
f0100c41:	5d                   	pop    %ebp
f0100c42:	c3                   	ret    

f0100c43 <mon_time>:
//<<<<<<< HEAD/
//=======
/* stone's solution for exercise17 */
int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100c43:	55                   	push   %ebp
f0100c44:	89 e5                	mov    %esp,%ebp
f0100c46:	57                   	push   %edi
f0100c47:	56                   	push   %esi
f0100c48:	53                   	push   %ebx
f0100c49:	83 ec 2c             	sub    $0x2c,%esp
	if (argc == 1){
f0100c4c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100c50:	75 16                	jne    f0100c68 <mon_time+0x25>
		cprintf("Usage: time [command]\n");
f0100c52:	c7 04 24 2b 5c 10 f0 	movl   $0xf0105c2b,(%esp)
f0100c59:	e8 9d 24 00 00       	call   f01030fb <cprintf>
f0100c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0100c63:	e9 96 00 00 00       	jmp    f0100cfe <mon_time+0xbb>
f0100c68:	bb 20 5f 10 f0       	mov    $0xf0105f20,%ebx
f0100c6d:	be 00 00 00 00       	mov    $0x0,%esi
	}
	int i;
	for (i = 0; i < NCOMMANDS; i++){
		if (strcmp(commands[i].name, argv[1]) == 0)
f0100c72:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100c75:	83 c7 04             	add    $0x4,%edi
f0100c78:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100c7b:	8b 07                	mov    (%edi),%eax
f0100c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c81:	8b 03                	mov    (%ebx),%eax
f0100c83:	89 04 24             	mov    %eax,(%esp)
f0100c86:	e8 1a 3d 00 00       	call   f01049a5 <strcmp>
f0100c8b:	85 c0                	test   %eax,%eax
f0100c8d:	74 23                	je     f0100cb2 <mon_time+0x6f>
			break;
		if (i == NCOMMANDS - 1){
f0100c8f:	83 fe 06             	cmp    $0x6,%esi
f0100c92:	75 13                	jne    f0100ca7 <mon_time+0x64>
			cprintf("Unkown command.\n");
f0100c94:	c7 04 24 42 5c 10 f0 	movl   $0xf0105c42,(%esp)
f0100c9b:	e8 5b 24 00 00       	call   f01030fb <cprintf>
f0100ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			return -1;
f0100ca5:	eb 57                	jmp    f0100cfe <mon_time+0xbb>
	if (argc == 1){
		cprintf("Usage: time [command]\n");
		return -1;
	}
	int i;
	for (i = 0; i < NCOMMANDS; i++){
f0100ca7:	83 c6 01             	add    $0x1,%esi
f0100caa:	83 c3 0c             	add    $0xc,%ebx
f0100cad:	83 fe 07             	cmp    $0x7,%esi
f0100cb0:	75 c6                	jne    f0100c78 <mon_time+0x35>

static __inline uint64_t
read_tsc(void)
{
        uint64_t tsc;
        __asm __volatile("rdtsc" : "=A" (tsc));
f0100cb2:	0f 31                	rdtsc  
f0100cb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cb7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			return -1;
		}
	}

	uint32_t begin = read_tsc();
	commands[i].func(argc-1, argv+1, tf);
f0100cba:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100cbd:	8b 55 10             	mov    0x10(%ebp),%edx
f0100cc0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100cc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100cc7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ccb:	8b 55 08             	mov    0x8(%ebp),%edx
f0100cce:	83 ea 01             	sub    $0x1,%edx
f0100cd1:	89 14 24             	mov    %edx,(%esp)
f0100cd4:	ff 14 85 28 5f 10 f0 	call   *-0xfefa0d8(,%eax,4)
f0100cdb:	0f 31                	rdtsc  
	uint32_t end = read_tsc();
	cprintf("%s cycles: %llu\n", argv[1], end-begin);
f0100cdd:	2b 45 d8             	sub    -0x28(%ebp),%eax
f0100ce0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ce4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ce7:	8b 02                	mov    (%edx),%eax
f0100ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ced:	c7 04 24 53 5c 10 f0 	movl   $0xf0105c53,(%esp)
f0100cf4:	e8 02 24 00 00       	call   f01030fb <cprintf>
f0100cf9:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0; 
}
f0100cfe:	83 c4 2c             	add    $0x2c,%esp
f0100d01:	5b                   	pop    %ebx
f0100d02:	5e                   	pop    %esi
f0100d03:	5f                   	pop    %edi
f0100d04:	5d                   	pop    %ebp
f0100d05:	c3                   	ret    

f0100d06 <mon_backtrace>:
}

//>>>>>>> lab2
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100d06:	55                   	push   %ebp
f0100d07:	89 e5                	mov    %esp,%ebp
f0100d09:	57                   	push   %edi
f0100d0a:	56                   	push   %esi
f0100d0b:	53                   	push   %ebx
f0100d0c:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
//<<<<<<< HEAD
//=======
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
f0100d0f:	89 eb                	mov    %ebp,%ebx
	cprintf("Stack backtrace:\n");
f0100d11:	c7 04 24 64 5c 10 f0 	movl   $0xf0105c64,(%esp)
f0100d18:	e8 de 23 00 00       	call   f01030fb <cprintf>
	while (ebp != 0){
f0100d1d:	85 db                	test   %ebx,%ebx
f0100d1f:	74 7d                	je     f0100d9e <mon_backtrace+0x98>
		cprintf(" eip %08x ebp %08x args %08x %08x %08x %08x %08x\n", (uint32_t*)ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100d21:	8d 7d d0             	lea    -0x30(%ebp),%edi
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0){
		cprintf(" eip %08x ebp %08x args %08x %08x %08x %08x %08x\n", (uint32_t*)ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100d24:	8d 73 04             	lea    0x4(%ebx),%esi
f0100d27:	8b 43 18             	mov    0x18(%ebx),%eax
f0100d2a:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100d2e:	8b 43 14             	mov    0x14(%ebx),%eax
f0100d31:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100d35:	8b 43 10             	mov    0x10(%ebx),%eax
f0100d38:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100d3c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100d3f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100d43:	8b 43 08             	mov    0x8(%ebx),%eax
f0100d46:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d4a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100d4e:	8b 06                	mov    (%esi),%eax
f0100d50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d54:	c7 04 24 08 5e 10 f0 	movl   $0xf0105e08,(%esp)
f0100d5b:	e8 9b 23 00 00       	call   f01030fb <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100d60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d64:	8b 06                	mov    (%esi),%eax
f0100d66:	89 04 24             	mov    %eax,(%esp)
f0100d69:	e8 50 31 00 00       	call   f0103ebe <debuginfo_eip>
		uint32_t offset = (int)(uint32_t*)ebp[1] - info.eip_fn_addr;
		cprintf(" 	%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);//there must be a space between ':' and '%s+%x'
f0100d6e:	8b 06                	mov    (%esi),%eax
f0100d70:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100d73:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100d77:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d8c:	c7 04 24 76 5c 10 f0 	movl   $0xf0105c76,(%esp)
f0100d93:	e8 63 23 00 00       	call   f01030fb <cprintf>
		ebp = (uint32_t*)ebp[0];
f0100d98:	8b 1b                	mov    (%ebx),%ebx
//=======
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0){
f0100d9a:	85 db                	test   %ebx,%ebx
f0100d9c:	75 86                	jne    f0100d24 <mon_backtrace+0x1e>
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
		uint32_t offset = (int)(uint32_t*)ebp[1] - info.eip_fn_addr;
		cprintf(" 	%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);//there must be a space between ':' and '%s+%x'
		ebp = (uint32_t*)ebp[0];
	}
    	overflow_me();
f0100d9e:	e8 3e fc ff ff       	call   f01009e1 <overflow_me>
    	cprintf("Backtrace success\n");
f0100da3:	c7 04 24 86 5c 10 f0 	movl   $0xf0105c86,(%esp)
f0100daa:	e8 4c 23 00 00       	call   f01030fb <cprintf>
//>>>>>>> lab2
	return 0;
}
f0100daf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db4:	83 c4 4c             	add    $0x4c,%esp
f0100db7:	5b                   	pop    %ebx
f0100db8:	5e                   	pop    %esi
f0100db9:	5f                   	pop    %edi
f0100dba:	5d                   	pop    %ebp
f0100dbb:	c3                   	ret    

f0100dbc <mon_si>:
	}
	else
		return -1;
}
int
mon_si(int argc, char** argv, struct Trapframe* tf){
f0100dbc:	55                   	push   %ebp
f0100dbd:	89 e5                	mov    %esp,%ebp
f0100dbf:	53                   	push   %ebx
f0100dc0:	83 ec 44             	sub    $0x44,%esp
f0100dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (tf != NULL){
f0100dc6:	85 db                	test   %ebx,%ebx
f0100dc8:	74 6d                	je     f0100e37 <mon_si+0x7b>
		tf->tf_eflags |= FL_TF;
f0100dca:	81 4b 38 00 01 00 00 	orl    $0x100,0x38(%ebx)
		struct Eipdebuginfo info;
		int r = debuginfo_eip(tf->tf_eip, &info);
f0100dd1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd8:	8b 43 30             	mov    0x30(%ebx),%eax
f0100ddb:	89 04 24             	mov    %eax,(%esp)
f0100dde:	e8 db 30 00 00       	call   f0103ebe <debuginfo_eip>
		cprintf("%08x\n", tf->tf_eip);
f0100de3:	8b 43 30             	mov    0x30(%ebx),%eax
f0100de6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dea:	c7 04 24 65 6e 10 f0 	movl   $0xf0106e65,(%esp)
f0100df1:	e8 05 23 00 00       	call   f01030fb <cprintf>
		uint32_t offset = tf->tf_eip - info.eip_fn_addr;
		cprintf("%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);
f0100df6:	8b 43 30             	mov    0x30(%ebx),%eax
f0100df9:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100dfc:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100e00:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100e03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e15:	c7 04 24 78 5c 10 f0 	movl   $0xf0105c78,(%esp)
f0100e1c:	e8 da 22 00 00       	call   f01030fb <cprintf>
		env_run(curenv);		
f0100e21:	e8 f8 42 00 00       	call   f010511e <cpunum>
f0100e26:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e29:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0100e2f:	89 04 24             	mov    %eax,(%esp)
f0100e32:	e8 6c 19 00 00       	call   f01027a3 <env_run>
		return 0;
	}
	else
		return -1;
}
f0100e37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e3c:	83 c4 44             	add    $0x44,%esp
f0100e3f:	5b                   	pop    %ebx
f0100e40:	5d                   	pop    %ebp
f0100e41:	c3                   	ret    

f0100e42 <mon_c>:
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();
/*stone's solution for lab3-B*/
int
mon_c(int argc, char** argv, struct Trapframe* tf){
f0100e42:	55                   	push   %ebp
f0100e43:	89 e5                	mov    %esp,%ebp
f0100e45:	83 ec 18             	sub    $0x18,%esp
f0100e48:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf != NULL){
f0100e4b:	85 c0                	test   %eax,%eax
f0100e4d:	74 1d                	je     f0100e6c <mon_c+0x2a>
		tf->tf_eflags &= ~FL_TF;
f0100e4f:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
		env_run(curenv);
f0100e56:	e8 c3 42 00 00       	call   f010511e <cpunum>
f0100e5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e5e:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0100e64:	89 04 24             	mov    %eax,(%esp)
f0100e67:	e8 37 19 00 00       	call   f01027a3 <env_run>
		return 0;
	}
	else
		return -1;
}
f0100e6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e71:	c9                   	leave  
f0100e72:	c3                   	ret    

f0100e73 <mon_x>:
int
mon_x(int argc, char** argv, struct Trapframe* tf){
f0100e73:	55                   	push   %ebp
f0100e74:	89 e5                	mov    %esp,%ebp
f0100e76:	83 ec 18             	sub    $0x18,%esp
	if (argc != 2){
f0100e79:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100e7d:	74 13                	je     f0100e92 <mon_x+0x1f>
		cprintf("Usage: x [address]\n");
f0100e7f:	c7 04 24 99 5c 10 f0 	movl   $0xf0105c99,(%esp)
f0100e86:	e8 70 22 00 00       	call   f01030fb <cprintf>
f0100e8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0100e90:	eb 40                	jmp    f0100ed2 <mon_x+0x5f>
	}
	if (tf != NULL){
f0100e92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e9b:	74 35                	je     f0100ed2 <mon_x+0x5f>
		uint32_t addr;
		uint32_t val;
		addr = strtol(argv[1], NULL, 16);
f0100e9d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100ea4:	00 
f0100ea5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100eac:	00 
f0100ead:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eb0:	8b 40 04             	mov    0x4(%eax),%eax
f0100eb3:	89 04 24             	mov    %eax,(%esp)
f0100eb6:	e8 30 3d 00 00       	call   f0104beb <strtol>
		__asm __volatile("movl (%0), %0" : "=r" (val) : "r" (addr));	
f0100ebb:	8b 00                	mov    (%eax),%eax
		cprintf("%d\n", val);
f0100ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ec1:	c7 04 24 96 65 10 f0 	movl   $0xf0106596,(%esp)
f0100ec8:	e8 2e 22 00 00       	call   f01030fb <cprintf>
f0100ecd:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	else
		return -1;
}
f0100ed2:	c9                   	leave  
f0100ed3:	c3                   	ret    
	...

f0100ee0 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reachesc 0.)
//
void
page_free(struct Page *pp)
{
f0100ee0:	55                   	push   %ebp
f0100ee1:	89 e5                	mov    %esp,%ebp
f0100ee3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	/*stone's solution for lab2*/
	if (pp->pp_ref == 0){
f0100ee6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100eeb:	75 0d                	jne    f0100efa <page_free+0x1a>
		pp->pp_link = page_free_list;
f0100eed:	8b 15 50 32 23 f0    	mov    0xf0233250,%edx
f0100ef3:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0100ef5:	a3 50 32 23 f0       	mov    %eax,0xf0233250
	}
}
f0100efa:	5d                   	pop    %ebp
f0100efb:	c3                   	ret    

f0100efc <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100efc:	55                   	push   %ebp
f0100efd:	89 e5                	mov    %esp,%ebp
f0100eff:	83 ec 04             	sub    $0x4,%esp
f0100f02:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f05:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100f09:	83 ea 01             	sub    $0x1,%edx
f0100f0c:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f10:	66 85 d2             	test   %dx,%dx
f0100f13:	75 08                	jne    f0100f1d <page_decref+0x21>
		page_free(pp);
f0100f15:	89 04 24             	mov    %eax,(%esp)
f0100f18:	e8 c3 ff ff ff       	call   f0100ee0 <page_free>
}
f0100f1d:	c9                   	leave  
f0100f1e:	c3                   	ret    

f0100f1f <check_continuous>:
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp, int num_page)
{
f0100f1f:	55                   	push   %ebp
f0100f20:	89 e5                	mov    %esp,%ebp
f0100f22:	57                   	push   %edi
f0100f23:	56                   	push   %esi
f0100f24:	53                   	push   %ebx
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100f25:	8d 72 ff             	lea    -0x1(%edx),%esi
f0100f28:	85 f6                	test   %esi,%esi
f0100f2a:	7e 5f                	jle    f0100f8b <check_continuous+0x6c>
	{
		if(tmp == NULL) 
f0100f2c:	85 c0                	test   %eax,%eax
f0100f2e:	74 54                	je     f0100f84 <check_continuous+0x65>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100f30:	8b 08                	mov    (%eax),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f32:	8b 1d 10 3f 23 f0    	mov    0xf0233f10,%ebx
f0100f38:	89 ca                	mov    %ecx,%edx
f0100f3a:	29 da                	sub    %ebx,%edx
f0100f3c:	c1 fa 03             	sar    $0x3,%edx
f0100f3f:	29 d8                	sub    %ebx,%eax
f0100f41:	c1 f8 03             	sar    $0x3,%eax
f0100f44:	29 c2                	sub    %eax,%edx
f0100f46:	c1 e2 0c             	shl    $0xc,%edx
f0100f49:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f4e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0100f54:	74 25                	je     f0100f7b <check_continuous+0x5c>
f0100f56:	eb 2c                	jmp    f0100f84 <check_continuous+0x65>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL) 
f0100f58:	85 c9                	test   %ecx,%ecx
f0100f5a:	74 28                	je     f0100f84 <check_continuous+0x65>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100f5c:	8b 11                	mov    (%ecx),%edx
f0100f5e:	89 d7                	mov    %edx,%edi
f0100f60:	29 df                	sub    %ebx,%edi
f0100f62:	c1 ff 03             	sar    $0x3,%edi
f0100f65:	29 d9                	sub    %ebx,%ecx
f0100f67:	c1 f9 03             	sar    $0x3,%ecx
f0100f6a:	29 cf                	sub    %ecx,%edi
f0100f6c:	89 f9                	mov    %edi,%ecx
f0100f6e:	c1 e1 0c             	shl    $0xc,%ecx
f0100f71:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0100f77:	75 0b                	jne    f0100f84 <check_continuous+0x65>
f0100f79:	89 d1                	mov    %edx,%ecx
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100f7b:	83 c0 01             	add    $0x1,%eax
f0100f7e:	39 f0                	cmp    %esi,%eax
f0100f80:	7c d6                	jl     f0100f58 <check_continuous+0x39>
f0100f82:	eb 07                	jmp    f0100f8b <check_continuous+0x6c>
f0100f84:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f89:	eb 05                	jmp    f0100f90 <check_continuous+0x71>
f0100f8b:	b8 01 00 00 00       	mov    $0x1,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100f90:	5b                   	pop    %ebx
f0100f91:	5e                   	pop    %esi
f0100f92:	5f                   	pop    %edi
f0100f93:	5d                   	pop    %ebp
f0100f94:	c3                   	ret    

f0100f95 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0100f95:	55                   	push   %ebp
f0100f96:	89 e5                	mov    %esp,%ebp
f0100f98:	56                   	push   %esi
f0100f99:	53                   	push   %ebx
f0100f9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100f9d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function
	/* stone's solution for lab2*/
	//if (pp == NULL) return -1;

	if (check_continuous(pp, n) == 0) return -1;
f0100fa0:	89 f2                	mov    %esi,%edx
f0100fa2:	89 d8                	mov    %ebx,%eax
f0100fa4:	e8 76 ff ff ff       	call   f0100f1f <check_continuous>
f0100fa9:	89 c2                	mov    %eax,%edx
f0100fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fb0:	85 d2                	test   %edx,%edx
f0100fb2:	74 27                	je     f0100fdb <page_free_npages+0x46>
	struct Page* tmp = pp;
	size_t i;
	for (i = 0; i < n-1; i++)
f0100fb4:	89 da                	mov    %ebx,%edx
f0100fb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fbb:	83 ee 01             	sub    $0x1,%esi
f0100fbe:	74 09                	je     f0100fc9 <page_free_npages+0x34>
		tmp = tmp->pp_link;
f0100fc0:	8b 12                	mov    (%edx),%edx
	//if (pp == NULL) return -1;

	if (check_continuous(pp, n) == 0) return -1;
	struct Page* tmp = pp;
	size_t i;
	for (i = 0; i < n-1; i++)
f0100fc2:	83 c0 01             	add    $0x1,%eax
f0100fc5:	39 f0                	cmp    %esi,%eax
f0100fc7:	72 f7                	jb     f0100fc0 <page_free_npages+0x2b>
		tmp = tmp->pp_link;
	tmp->pp_link = chunk_list;
f0100fc9:	a1 54 32 23 f0       	mov    0xf0233254,%eax
f0100fce:	89 02                	mov    %eax,(%edx)
	chunk_list = pp;
f0100fd0:	89 1d 54 32 23 f0    	mov    %ebx,0xf0233254
f0100fd6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0100fdb:	5b                   	pop    %ebx
f0100fdc:	5e                   	pop    %esi
f0100fdd:	5d                   	pop    %ebp
f0100fde:	c3                   	ret    

f0100fdf <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100fdf:	55                   	push   %ebp
f0100fe0:	89 e5                	mov    %esp,%ebp
f0100fe2:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100fe5:	e8 34 41 00 00       	call   f010511e <cpunum>
f0100fea:	6b c0 74             	imul   $0x74,%eax,%eax
f0100fed:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0100ff4:	74 16                	je     f010100c <tlb_invalidate+0x2d>
f0100ff6:	e8 23 41 00 00       	call   f010511e <cpunum>
f0100ffb:	6b c0 74             	imul   $0x74,%eax,%eax
f0100ffe:	8b 90 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%edx
f0101004:	8b 45 08             	mov    0x8(%ebp),%eax
f0101007:	39 42 64             	cmp    %eax,0x64(%edx)
f010100a:	75 06                	jne    f0101012 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010100c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100f:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101012:	c9                   	leave  
f0101013:	c3                   	ret    

f0101014 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101014:	55                   	push   %ebp
f0101015:	89 e5                	mov    %esp,%ebp
f0101017:	83 ec 18             	sub    $0x18,%esp
f010101a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010101d:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101020:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101022:	89 04 24             	mov    %eax,(%esp)
f0101025:	e8 76 1f 00 00       	call   f0102fa0 <mc146818_read>
f010102a:	89 c6                	mov    %eax,%esi
f010102c:	83 c3 01             	add    $0x1,%ebx
f010102f:	89 1c 24             	mov    %ebx,(%esp)
f0101032:	e8 69 1f 00 00       	call   f0102fa0 <mc146818_read>
f0101037:	c1 e0 08             	shl    $0x8,%eax
f010103a:	09 f0                	or     %esi,%eax
}
f010103c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010103f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101042:	89 ec                	mov    %ebp,%esp
f0101044:	5d                   	pop    %ebp
f0101045:	c3                   	ret    

f0101046 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101046:	55                   	push   %ebp
f0101047:	89 e5                	mov    %esp,%ebp
f0101049:	83 ec 18             	sub    $0x18,%esp
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010104c:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f0101052:	c1 f8 03             	sar    $0x3,%eax
f0101055:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101058:	89 c2                	mov    %eax,%edx
f010105a:	c1 ea 0c             	shr    $0xc,%edx
f010105d:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f0101063:	72 20                	jb     f0101085 <page2kva+0x3f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101065:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101069:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0101070:	f0 
f0101071:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101078:	00 
f0101079:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0101080:	e8 00 f0 ff ff       	call   f0100085 <_panic>
f0101085:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
}
f010108a:	c9                   	leave  
f010108b:	c3                   	ret    

f010108c <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f010108c:	55                   	push   %ebp
f010108d:	89 e5                	mov    %esp,%ebp
f010108f:	57                   	push   %edi
f0101090:	56                   	push   %esi
f0101091:	53                   	push   %ebx
f0101092:	83 ec 2c             	sub    $0x2c,%esp
	// Fill this function
	/*stone's solution for lab2*/
	if (n <= 0)
f0101095:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101099:	0f 8e fe 00 00 00    	jle    f010119d <page_alloc_npages+0x111>
		return NULL;
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
f010109f:	8b 35 08 3f 23 f0    	mov    0xf0233f08,%esi
f01010a5:	85 f6                	test   %esi,%esi
f01010a7:	0f 84 f0 00 00 00    	je     f010119d <page_alloc_npages+0x111>
		if (pages[i].pp_ref == 0){
f01010ad:	a1 10 3f 23 f0       	mov    0xf0233f10,%eax
f01010b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010b5:	b9 00 00 00 00       	mov    $0x0,%ecx
			for (j = 0; j < n && i + j < npages; j++){
f01010ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
		return NULL;
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
		if (pages[i].pp_ref == 0){
f01010bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010c0:	66 83 7c cb 04 00    	cmpw   $0x0,0x4(%ebx,%ecx,8)
f01010c6:	75 41                	jne    f0101109 <page_alloc_npages+0x7d>
			for (j = 0; j < n && i + j < npages; j++){
f01010c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01010cc:	0f 84 da 00 00 00    	je     f01011ac <page_alloc_npages+0x120>
f01010d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01010d7:	39 ce                	cmp    %ecx,%esi
f01010d9:	76 2c                	jbe    f0101107 <page_alloc_npages+0x7b>
f01010db:	8d 54 cb 0c          	lea    0xc(%ebx,%ecx,8),%edx
f01010df:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e4:	eb 0b                	jmp    f01010f1 <page_alloc_npages+0x65>
				if (pages[i+j].pp_ref != 0)
f01010e6:	0f b7 1a             	movzwl (%edx),%ebx
f01010e9:	83 c2 08             	add    $0x8,%edx
f01010ec:	66 85 db             	test   %bx,%bx
f01010ef:	75 0e                	jne    f01010ff <page_alloc_npages+0x73>
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
		if (pages[i].pp_ref == 0){
			for (j = 0; j < n && i + j < npages; j++){
f01010f1:	83 c0 01             	add    $0x1,%eax
f01010f4:	39 f8                	cmp    %edi,%eax
f01010f6:	73 07                	jae    f01010ff <page_alloc_npages+0x73>
f01010f8:	8d 1c 08             	lea    (%eax,%ecx,1),%ebx
f01010fb:	39 de                	cmp    %ebx,%esi
f01010fd:	77 e7                	ja     f01010e6 <page_alloc_npages+0x5a>
				if (pages[i+j].pp_ref != 0)
					break;
			}
			if (j == n) flag = 1;
f01010ff:	39 c7                	cmp    %eax,%edi
f0101101:	0f 84 aa 00 00 00    	je     f01011b1 <page_alloc_npages+0x125>
			else i += j;
f0101107:	01 c1                	add    %eax,%ecx
		}
		if (flag == 1) break;
		i++;
f0101109:	83 c1 01             	add    $0x1,%ecx
	if (n <= 0)
		return NULL;
	size_t i = 0;
	size_t j;
	int flag = 0;
	while (i < npages){
f010110c:	39 f1                	cmp    %esi,%ecx
f010110e:	72 ad                	jb     f01010bd <page_alloc_npages+0x31>
f0101110:	e9 88 00 00 00       	jmp    f010119d <page_alloc_npages+0x111>
		i++;
	}
	if (flag == 0) return NULL;

	struct Page* tmp = page_free_list;
	while (&pages[i+j] > tmp && tmp >= &pages[i])
f0101115:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101118:	8d 1c ce             	lea    (%esi,%ecx,8),%ebx
f010111b:	39 da                	cmp    %ebx,%edx
f010111d:	72 0a                	jb     f0101129 <page_alloc_npages+0x9d>
		tmp = tmp->pp_link;
f010111f:	8b 12                	mov    (%edx),%edx
		i++;
	}
	if (flag == 0) return NULL;

	struct Page* tmp = page_free_list;
	while (&pages[i+j] > tmp && tmp >= &pages[i])
f0101121:	39 c2                	cmp    %eax,%edx
f0101123:	73 04                	jae    f0101129 <page_alloc_npages+0x9d>
f0101125:	39 da                	cmp    %ebx,%edx
f0101127:	73 f6                	jae    f010111f <page_alloc_npages+0x93>
		tmp = tmp->pp_link;
	page_free_list = tmp;
f0101129:	89 15 50 32 23 f0    	mov    %edx,0xf0233250
			result->pp_link = tmp->pp_link;
		}
		result = tmp;
	}*/
	size_t k;
	for (k = 0; k < n - 1; k++){
f010112f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101132:	83 ef 01             	sub    $0x1,%edi
f0101135:	74 32                	je     f0101169 <page_alloc_npages+0xdd>
f0101137:	8d 1c cd 00 00 00 00 	lea    0x0(,%ecx,8),%ebx
f010113e:	8d 14 cd 08 00 00 00 	lea    0x8(,%ecx,8),%edx
f0101145:	b8 00 00 00 00       	mov    $0x0,%eax
f010114a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		pages[k + i].pp_link = &pages[k + 1 + i];
f010114d:	8b 0d 10 3f 23 f0    	mov    0xf0233f10,%ecx
f0101153:	8d 34 11             	lea    (%ecx,%edx,1),%esi
f0101156:	89 34 19             	mov    %esi,(%ecx,%ebx,1)
			result->pp_link = tmp->pp_link;
		}
		result = tmp;
	}*/
	size_t k;
	for (k = 0; k < n - 1; k++){
f0101159:	83 c0 01             	add    $0x1,%eax
f010115c:	83 c3 08             	add    $0x8,%ebx
f010115f:	83 c2 08             	add    $0x8,%edx
f0101162:	39 c7                	cmp    %eax,%edi
f0101164:	77 e7                	ja     f010114d <page_alloc_npages+0xc1>
f0101166:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
		pages[k + i].pp_link = &pages[k + 1 + i];
	}
	result = &pages[i];
f0101169:	c1 e1 03             	shl    $0x3,%ecx
f010116c:	89 cb                	mov    %ecx,%ebx
f010116e:	03 1d 10 3f 23 f0    	add    0xf0233f10,%ebx
	
	if (alloc_flags & ALLOC_ZERO)
f0101174:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101178:	74 28                	je     f01011a2 <page_alloc_npages+0x116>
		memset(page2kva(result), '\0', n*PGSIZE);
f010117a:	89 d8                	mov    %ebx,%eax
f010117c:	e8 c5 fe ff ff       	call   f0101046 <page2kva>
f0101181:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101184:	c1 e2 0c             	shl    $0xc,%edx
f0101187:	89 54 24 08          	mov    %edx,0x8(%esp)
f010118b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101192:	00 
f0101193:	89 04 24             	mov    %eax,(%esp)
f0101196:	e8 db 38 00 00       	call   f0104a76 <memset>
f010119b:	eb 05                	jmp    f01011a2 <page_alloc_npages+0x116>
f010119d:	bb 00 00 00 00       	mov    $0x0,%ebx
	return result;
}
f01011a2:	89 d8                	mov    %ebx,%eax
f01011a4:	83 c4 2c             	add    $0x2c,%esp
f01011a7:	5b                   	pop    %ebx
f01011a8:	5e                   	pop    %esi
f01011a9:	5f                   	pop    %edi
f01011aa:	5d                   	pop    %ebp
f01011ab:	c3                   	ret    
		pages[k + i].pp_link = &pages[k + 1 + i];
	}
	result = &pages[i];
	
	if (alloc_flags & ALLOC_ZERO)
		memset(page2kva(result), '\0', n*PGSIZE);
f01011ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (flag == 1) break;
		i++;
	}
	if (flag == 0) return NULL;

	struct Page* tmp = page_free_list;
f01011b1:	8b 15 50 32 23 f0    	mov    0xf0233250,%edx
	while (&pages[i+j] > tmp && tmp >= &pages[i])
f01011b7:	01 c8                	add    %ecx,%eax
f01011b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01011bc:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01011bf:	39 c2                	cmp    %eax,%edx
f01011c1:	0f 82 4e ff ff ff    	jb     f0101115 <page_alloc_npages+0x89>
f01011c7:	e9 5d ff ff ff       	jmp    f0101129 <page_alloc_npages+0x9d>

f01011cc <page_realloc_npages>:
// (Try to reuse the allocated pages as many as possible.)
//

struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f01011cc:	55                   	push   %ebp
f01011cd:	89 e5                	mov    %esp,%ebp
f01011cf:	83 ec 38             	sub    $0x38,%esp
f01011d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01011d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01011d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01011db:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011de:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01011e1:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function
	//stone's solution for lab2
	if (new_n <= 0) return NULL;
f01011e4:	85 f6                	test   %esi,%esi
f01011e6:	0f 8e c5 00 00 00    	jle    f01012b1 <page_realloc_npages+0xe5>
	if (old_n <= 0) return NULL;
f01011ec:	85 ff                	test   %edi,%edi
f01011ee:	0f 8e bd 00 00 00    	jle    f01012b1 <page_realloc_npages+0xe5>
	if (check_continuous(pp, old_n) == 0) return NULL;
f01011f4:	89 fa                	mov    %edi,%edx
f01011f6:	89 d8                	mov    %ebx,%eax
f01011f8:	e8 22 fd ff ff       	call   f0100f1f <check_continuous>
f01011fd:	85 c0                	test   %eax,%eax
f01011ff:	0f 84 ac 00 00 00    	je     f01012b1 <page_realloc_npages+0xe5>
	if (new_n == old_n) return pp;
f0101205:	39 fe                	cmp    %edi,%esi
f0101207:	0f 84 a9 00 00 00    	je     f01012b6 <page_realloc_npages+0xea>
	if (new_n < old_n){
f010120d:	39 fe                	cmp    %edi,%esi
f010120f:	90                   	nop
f0101210:	7d 16                	jge    f0101228 <page_realloc_npages+0x5c>
		page_free_npages(pp+new_n, old_n-new_n);
f0101212:	29 f7                	sub    %esi,%edi
f0101214:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101218:	8d 04 f3             	lea    (%ebx,%esi,8),%eax
f010121b:	89 04 24             	mov    %eax,(%esp)
f010121e:	e8 72 fd ff ff       	call   f0100f95 <page_free_npages>
		return pp;
f0101223:	e9 8e 00 00 00       	jmp    f01012b6 <page_realloc_npages+0xea>
	}
	//stone: when new_n > old_n ,if the tail pages is continuous, then link them directly, o.w alloc new pages. 
	struct Page* tmp = pp + old_n;
f0101228:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	size_t i;
	int flag = 0;
	for (i = 0; i < new_n - old_n; i++){
f010122b:	89 f2                	mov    %esi,%edx
f010122d:	29 fa                	sub    %edi,%edx
f010122f:	0f 84 81 00 00 00    	je     f01012b6 <page_realloc_npages+0xea>
	if (new_n < old_n){
		page_free_npages(pp+new_n, old_n-new_n);
		return pp;
	}
	//stone: when new_n > old_n ,if the tail pages is continuous, then link them directly, o.w alloc new pages. 
	struct Page* tmp = pp + old_n;
f0101235:	8d 0c fb             	lea    (%ebx,%edi,8),%ecx
	size_t i;
	int flag = 0;
	for (i = 0; i < new_n - old_n; i++){
		if (tmp->pp_ref != 0){
f0101238:	b8 00 00 00 00       	mov    $0x0,%eax
f010123d:	66 83 79 04 00       	cmpw   $0x0,0x4(%ecx)
f0101242:	74 0a                	je     f010124e <page_realloc_npages+0x82>
f0101244:	eb 11                	jmp    f0101257 <page_realloc_npages+0x8b>
f0101246:	66 83 7c c1 04 00    	cmpw   $0x0,0x4(%ecx,%eax,8)
f010124c:	75 09                	jne    f0101257 <page_realloc_npages+0x8b>
	}
	//stone: when new_n > old_n ,if the tail pages is continuous, then link them directly, o.w alloc new pages. 
	struct Page* tmp = pp + old_n;
	size_t i;
	int flag = 0;
	for (i = 0; i < new_n - old_n; i++){
f010124e:	83 c0 01             	add    $0x1,%eax
f0101251:	39 d0                	cmp    %edx,%eax
f0101253:	72 f1                	jb     f0101246 <page_realloc_npages+0x7a>
f0101255:	eb 6e                	jmp    f01012c5 <page_realloc_npages+0xf9>
			result++;
		}
		return pp;
	}
	else{
		result = page_alloc_npages(ALLOC_ZERO, new_n);
f0101257:	89 74 24 04          	mov    %esi,0x4(%esp)
f010125b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101262:	e8 25 fe ff ff       	call   f010108c <page_alloc_npages>
f0101267:	89 c6                	mov    %eax,%esi
		memmove(page2kva(result), page2kva(pp), old_n*PGSIZE);
f0101269:	89 d8                	mov    %ebx,%eax
f010126b:	e8 d6 fd ff ff       	call   f0101046 <page2kva>
f0101270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101273:	89 f0                	mov    %esi,%eax
f0101275:	e8 cc fd ff ff       	call   f0101046 <page2kva>
f010127a:	89 fa                	mov    %edi,%edx
f010127c:	c1 e2 0c             	shl    $0xc,%edx
f010127f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101283:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101286:	89 54 24 04          	mov    %edx,0x4(%esp)
f010128a:	89 04 24             	mov    %eax,(%esp)
f010128d:	e8 43 38 00 00       	call   f0104ad5 <memmove>
		page_free_npages(pp, old_n);
f0101292:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101296:	89 1c 24             	mov    %ebx,(%esp)
f0101299:	e8 f7 fc ff ff       	call   f0100f95 <page_free_npages>
f010129e:	89 f3                	mov    %esi,%ebx
		pp = result;
		return pp;
f01012a0:	eb 14                	jmp    f01012b6 <page_realloc_npages+0xea>
	}
	struct Page* result;
	if (flag == 0){
		result = pp + old_n - 1;
		for (i = 0; i < new_n - old_n; i++){
			result->pp_link = result + 1;
f01012a2:	83 c0 08             	add    $0x8,%eax
f01012a5:	89 40 f8             	mov    %eax,-0x8(%eax)
		else tmp++;
	}
	struct Page* result;
	if (flag == 0){
		result = pp + old_n - 1;
		for (i = 0; i < new_n - old_n; i++){
f01012a8:	83 c1 01             	add    $0x1,%ecx
f01012ab:	39 d1                	cmp    %edx,%ecx
f01012ad:	72 f3                	jb     f01012a2 <page_realloc_npages+0xd6>
f01012af:	eb 05                	jmp    f01012b6 <page_realloc_npages+0xea>
f01012b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		page_free_npages(pp, old_n);
		pp = result;
		return pp;
	}		
	//return NULL;
}
f01012b6:	89 d8                	mov    %ebx,%eax
f01012b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01012bb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01012be:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01012c1:	89 ec                	mov    %ebp,%esp
f01012c3:	5d                   	pop    %ebp
f01012c4:	c3                   	ret    
		}
		else tmp++;
	}
	struct Page* result;
	if (flag == 0){
		result = pp + old_n - 1;
f01012c5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01012c8:	8d 44 cb f8          	lea    -0x8(%ebx,%ecx,8),%eax
f01012cc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012d1:	eb cf                	jmp    f01012a2 <page_realloc_npages+0xd6>

f01012d3 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01012d3:	55                   	push   %ebp
f01012d4:	89 e5                	mov    %esp,%ebp
f01012d6:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01012d9:	89 d1                	mov    %edx,%ecx
f01012db:	c1 e9 16             	shr    $0x16,%ecx
f01012de:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01012e1:	a8 01                	test   $0x1,%al
f01012e3:	74 4d                	je     f0101332 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01012e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012ea:	89 c1                	mov    %eax,%ecx
f01012ec:	c1 e9 0c             	shr    $0xc,%ecx
f01012ef:	3b 0d 08 3f 23 f0    	cmp    0xf0233f08,%ecx
f01012f5:	72 20                	jb     f0101317 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012fb:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0101302:	f0 
f0101303:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f010130a:	00 
f010130b:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101312:	e8 6e ed ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101317:	c1 ea 0c             	shr    $0xc,%edx
f010131a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101320:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101327:	a8 01                	test   $0x1,%al
f0101329:	74 07                	je     f0101332 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010132b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101330:	eb 05                	jmp    f0101337 <check_va2pa+0x64>
f0101332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101337:	c9                   	leave  
f0101338:	c3                   	ret    

f0101339 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101339:	55                   	push   %ebp
f010133a:	89 e5                	mov    %esp,%ebp
f010133c:	53                   	push   %ebx
f010133d:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101340:	83 3d 48 32 23 f0 00 	cmpl   $0x0,0xf0233248
f0101347:	75 11                	jne    f010135a <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101349:	ba 03 60 27 f0       	mov    $0xf0276003,%edx
f010134e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101354:	89 15 48 32 23 f0    	mov    %edx,0xf0233248
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	/*stone's solution for lab2*/
	result = nextfree;
f010135a:	8b 15 48 32 23 f0    	mov    0xf0233248,%edx
	if (n > 0){
f0101360:	85 c0                	test   %eax,%eax
f0101362:	74 76                	je     f01013da <boot_alloc+0xa1>
		nextfree += n;
f0101364:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101367:	a3 48 32 23 f0       	mov    %eax,0xf0233248
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010136c:	89 c1                	mov    %eax,%ecx
f010136e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101373:	77 20                	ja     f0101395 <boot_alloc+0x5c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101375:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101379:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101380:	f0 
f0101381:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0101388:	00 
f0101389:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101390:	e8 f0 ec ff ff       	call   f0100085 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101395:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010139b:	89 c3                	mov    %eax,%ebx
f010139d:	c1 eb 0c             	shr    $0xc,%ebx
f01013a0:	3b 1d 08 3f 23 f0    	cmp    0xf0233f08,%ebx
f01013a6:	72 20                	jb     f01013c8 <boot_alloc+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013ac:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f01013b3:	f0 
f01013b4:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f01013bb:	00 
f01013bc:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01013c3:	e8 bd ec ff ff       	call   f0100085 <_panic>
		KADDR(PADDR(nextfree));
		nextfree = ROUNDUP(nextfree, PGSIZE);
f01013c8:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01013ce:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01013d4:	89 0d 48 32 23 f0    	mov    %ecx,0xf0233248
	}
	return result;
}
f01013da:	89 d0                	mov    %edx,%eax
f01013dc:	83 c4 14             	add    $0x14,%esp
f01013df:	5b                   	pop    %ebx
f01013e0:	5d                   	pop    %ebp
f01013e1:	c3                   	ret    

f01013e2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01013e2:	55                   	push   %ebp
f01013e3:	89 e5                	mov    %esp,%ebp
f01013e5:	56                   	push   %esi
f01013e6:	53                   	push   %ebx
f01013e7:	83 ec 10             	sub    $0x10,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	/*stone's solution for lab2*/
	size_t i;
	for (i = 1; i < npages_basemem; i++){
f01013ea:	8b 35 4c 32 23 f0    	mov    0xf023324c,%esi
f01013f0:	83 fe 01             	cmp    $0x1,%esi
f01013f3:	76 3d                	jbe    f0101432 <page_init+0x50>
f01013f5:	8b 0d 50 32 23 f0    	mov    0xf0233250,%ecx
f01013fb:	b8 01 00 00 00       	mov    $0x1,%eax
f0101400:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101407:	8b 1d 10 3f 23 f0    	mov    0xf0233f10,%ebx
f010140d:	66 c7 44 13 04 00 00 	movw   $0x0,0x4(%ebx,%edx,1)
		pages[i].pp_link = page_free_list;
f0101414:	8b 1d 10 3f 23 f0    	mov    0xf0233f10,%ebx
f010141a:	89 0c 13             	mov    %ecx,(%ebx,%edx,1)
		page_free_list = &pages[i];
f010141d:	89 d1                	mov    %edx,%ecx
f010141f:	03 0d 10 3f 23 f0    	add    0xf0233f10,%ecx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	/*stone's solution for lab2*/
	size_t i;
	for (i = 1; i < npages_basemem; i++){
f0101425:	83 c0 01             	add    $0x1,%eax
f0101428:	39 f0                	cmp    %esi,%eax
f010142a:	75 d4                	jne    f0101400 <page_init+0x1e>
f010142c:	89 0d 50 32 23 f0    	mov    %ecx,0xf0233250
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//use boot_alloc(0) to get next free page
	for (i = (PADDR(boot_alloc(0)) / PGSIZE); i < npages; i++){
f0101432:	b8 00 00 00 00       	mov    $0x0,%eax
f0101437:	e8 fd fe ff ff       	call   f0101339 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010143c:	89 c2                	mov    %eax,%edx
f010143e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101443:	77 20                	ja     f0101465 <page_init+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101445:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101449:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101450:	f0 
f0101451:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f0101458:	00 
f0101459:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101460:	e8 20 ec ff ff       	call   f0100085 <_panic>
f0101465:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010146b:	c1 ea 0c             	shr    $0xc,%edx
f010146e:	39 15 08 3f 23 f0    	cmp    %edx,0xf0233f08
f0101474:	76 3f                	jbe    f01014b5 <page_init+0xd3>
f0101476:	8b 0d 50 32 23 f0    	mov    0xf0233250,%ecx
f010147c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		 pages[i].pp_ref = 0;
f0101483:	8b 1d 10 3f 23 f0    	mov    0xf0233f10,%ebx
f0101489:	66 c7 44 03 04 00 00 	movw   $0x0,0x4(%ebx,%eax,1)
		pages[i].pp_link = page_free_list;
f0101490:	8b 1d 10 3f 23 f0    	mov    0xf0233f10,%ebx
f0101496:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
		page_free_list = &pages[i];
f0101499:	89 c1                	mov    %eax,%ecx
f010149b:	03 0d 10 3f 23 f0    	add    0xf0233f10,%ecx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//use boot_alloc(0) to get next free page
	for (i = (PADDR(boot_alloc(0)) / PGSIZE); i < npages; i++){
f01014a1:	83 c2 01             	add    $0x1,%edx
f01014a4:	83 c0 08             	add    $0x8,%eax
f01014a7:	39 15 08 3f 23 f0    	cmp    %edx,0xf0233f08
f01014ad:	77 d4                	ja     f0101483 <page_init+0xa1>
f01014af:	89 0d 50 32 23 f0    	mov    %ecx,0xf0233250
		 pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f01014b5:	c7 05 54 32 23 f0 00 	movl   $0x0,0xf0233254
f01014bc:	00 00 00 
}
f01014bf:	83 c4 10             	add    $0x10,%esp
f01014c2:	5b                   	pop    %ebx
f01014c3:	5e                   	pop    %esi
f01014c4:	5d                   	pop    %ebp
f01014c5:	c3                   	ret    

f01014c6 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01014c6:	55                   	push   %ebp
f01014c7:	89 e5                	mov    %esp,%ebp
f01014c9:	53                   	push   %ebx
f01014ca:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	/*stone's solution for lab2*/
	struct Page* alloc_page;
	if (page_free_list != NULL){
f01014cd:	8b 1d 50 32 23 f0    	mov    0xf0233250,%ebx
f01014d3:	85 db                	test   %ebx,%ebx
f01014d5:	74 6b                	je     f0101542 <page_alloc+0x7c>
		alloc_page = page_free_list;
		page_free_list = page_free_list->pp_link;
f01014d7:	8b 03                	mov    (%ebx),%eax
f01014d9:	a3 50 32 23 f0       	mov    %eax,0xf0233250
		alloc_page->pp_link = NULL;
f01014de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f01014e4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01014e8:	74 58                	je     f0101542 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01014ea:	89 d8                	mov    %ebx,%eax
f01014ec:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f01014f2:	c1 f8 03             	sar    $0x3,%eax
f01014f5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f8:	89 c2                	mov    %eax,%edx
f01014fa:	c1 ea 0c             	shr    $0xc,%edx
f01014fd:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f0101503:	72 20                	jb     f0101525 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101505:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101509:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0101510:	f0 
f0101511:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101518:	00 
f0101519:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0101520:	e8 60 eb ff ff       	call   f0100085 <_panic>
			memset(page2kva(alloc_page), '\0', PGSIZE);
f0101525:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010152c:	00 
f010152d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101534:	00 
f0101535:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010153a:	89 04 24             	mov    %eax,(%esp)
f010153d:	e8 34 35 00 00       	call   f0104a76 <memset>
		return alloc_page;
	}
	return NULL;
}
f0101542:	89 d8                	mov    %ebx,%eax
f0101544:	83 c4 14             	add    $0x14,%esp
f0101547:	5b                   	pop    %ebx
f0101548:	5d                   	pop    %ebp
f0101549:	c3                   	ret    

f010154a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010154a:	55                   	push   %ebp
f010154b:	89 e5                	mov    %esp,%ebp
f010154d:	83 ec 18             	sub    $0x18,%esp
f0101550:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101553:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	/*stone's solution for lab2*/
	pde_t* pde = pgdir + PDX(va);//stone: get pde
f0101556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101559:	89 de                	mov    %ebx,%esi
f010155b:	c1 ee 16             	shr    $0x16,%esi
f010155e:	c1 e6 02             	shl    $0x2,%esi
f0101561:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P){//stone:if present
f0101564:	8b 06                	mov    (%esi),%eax
f0101566:	a8 01                	test   $0x1,%al
f0101568:	74 44                	je     f01015ae <pgdir_walk+0x64>
		pte_t *pte = PTX(va) + (pte_t *)KADDR(PTE_ADDR(*pde));
f010156a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010156f:	89 c2                	mov    %eax,%edx
f0101571:	c1 ea 0c             	shr    $0xc,%edx
f0101574:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f010157a:	72 20                	jb     f010159c <pgdir_walk+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010157c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101580:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0101587:	f0 
f0101588:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
f010158f:	00 
f0101590:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101597:	e8 e9 ea ff ff       	call   f0100085 <_panic>
f010159c:	c1 eb 0a             	shr    $0xa,%ebx
f010159f:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01015a5:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
		return pte;
f01015ac:	eb 78                	jmp    f0101626 <pgdir_walk+0xdc>
	}
	else if (create == 0)
f01015ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015b2:	74 6d                	je     f0101621 <pgdir_walk+0xd7>
		return NULL;
	else{
		struct Page* pp = page_alloc(ALLOC_ZERO);
f01015b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015bb:	e8 06 ff ff ff       	call   f01014c6 <page_alloc>
		if (pp == NULL)
f01015c0:	85 c0                	test   %eax,%eax
f01015c2:	74 5d                	je     f0101621 <pgdir_walk+0xd7>
			return NULL;
		else{
			pp->pp_ref = 1;
f01015c4:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			physaddr_t physaddr = page2pa(pp);
			*pde = physaddr | PTE_U | PTE_W | PTE_P;
f01015ca:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f01015d0:	c1 f8 03             	sar    $0x3,%eax
f01015d3:	c1 e0 0c             	shl    $0xc,%eax
f01015d6:	83 c8 07             	or     $0x7,%eax
f01015d9:	89 06                	mov    %eax,(%esi)
			pte_t *pte = PTX(va) + (pte_t *)KADDR(PTE_ADDR(*pde));
f01015db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015e0:	89 c2                	mov    %eax,%edx
f01015e2:	c1 ea 0c             	shr    $0xc,%edx
f01015e5:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f01015eb:	72 20                	jb     f010160d <pgdir_walk+0xc3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015f1:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f01015f8:	f0 
f01015f9:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f0101600:	00 
f0101601:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101608:	e8 78 ea ff ff       	call   f0100085 <_panic>
f010160d:	c1 eb 0a             	shr    $0xa,%ebx
f0101610:	89 da                	mov    %ebx,%edx
f0101612:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101618:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
			return pte;
f010161f:	eb 05                	jmp    f0101626 <pgdir_walk+0xdc>
f0101621:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}	  
	//return NULL;
}
f0101626:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101629:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010162c:	89 ec                	mov    %ebp,%esp
f010162e:	5d                   	pop    %ebp
f010162f:	c3                   	ret    

f0101630 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101630:	55                   	push   %ebp
f0101631:	89 e5                	mov    %esp,%ebp
f0101633:	57                   	push   %edi
f0101634:	56                   	push   %esi
f0101635:	53                   	push   %ebx
f0101636:	83 ec 2c             	sub    $0x2c,%esp
f0101639:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	uintptr_t start = (uintptr_t)va;
f010163c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uintptr_t end = (uintptr_t)va + len;
f010163f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101642:	01 d8                	add    %ebx,%eax
f0101644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	perm |= PTE_P;
f0101647:	8b 7d 14             	mov    0x14(%ebp),%edi
f010164a:	83 cf 01             	or     $0x1,%edi
	int r = 0;
	while (start < end){
f010164d:	39 c3                	cmp    %eax,%ebx
f010164f:	73 67                	jae    f01016b8 <user_mem_check+0x88>
		if (start > ULIM){
f0101651:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0101657:	76 1e                	jbe    f0101677 <user_mem_check+0x47>
f0101659:	eb 0f                	jmp    f010166a <user_mem_check+0x3a>
f010165b:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0101661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101668:	76 0d                	jbe    f0101677 <user_mem_check+0x47>
			user_mem_check_addr = start;
f010166a:	89 1d 58 32 23 f0    	mov    %ebx,0xf0233258
f0101670:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			r = -E_FAULT;
			break;
f0101675:	eb 46                	jmp    f01016bd <user_mem_check+0x8d>
		}
		pte_t* pte = pgdir_walk(env->env_pgdir, (void*)start, 0);
f0101677:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010167e:	00 
f010167f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101683:	8b 46 64             	mov    0x64(%esi),%eax
f0101686:	89 04 24             	mov    %eax,(%esp)
f0101689:	e8 bc fe ff ff       	call   f010154a <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm){
f010168e:	85 c0                	test   %eax,%eax
f0101690:	74 08                	je     f010169a <user_mem_check+0x6a>
f0101692:	8b 00                	mov    (%eax),%eax
f0101694:	21 f8                	and    %edi,%eax
f0101696:	39 c7                	cmp    %eax,%edi
f0101698:	74 0d                	je     f01016a7 <user_mem_check+0x77>
			user_mem_check_addr = start;
f010169a:	89 1d 58 32 23 f0    	mov    %ebx,0xf0233258
f01016a0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			r = -E_FAULT;
			break;
f01016a5:	eb 16                	jmp    f01016bd <user_mem_check+0x8d>
		}
		start = ROUNDDOWN(start+PGSIZE, PGSIZE);
f01016a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01016ad:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	/*stone's solution for lab3-B*/
	uintptr_t start = (uintptr_t)va;
	uintptr_t end = (uintptr_t)va + len;
	perm |= PTE_P;
	int r = 0;
	while (start < end){
f01016b3:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01016b6:	77 a3                	ja     f010165b <user_mem_check+0x2b>
f01016b8:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
		}
		start = ROUNDDOWN(start+PGSIZE, PGSIZE);
	}
	return r;
}
f01016bd:	83 c4 2c             	add    $0x2c,%esp
f01016c0:	5b                   	pop    %ebx
f01016c1:	5e                   	pop    %esi
f01016c2:	5f                   	pop    %edi
f01016c3:	5d                   	pop    %ebp
f01016c4:	c3                   	ret    

f01016c5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01016c5:	55                   	push   %ebp
f01016c6:	89 e5                	mov    %esp,%ebp
f01016c8:	53                   	push   %ebx
f01016c9:	83 ec 14             	sub    $0x14,%esp
f01016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01016cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01016d2:	83 c8 04             	or     $0x4,%eax
f01016d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01016dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016e7:	89 1c 24             	mov    %ebx,(%esp)
f01016ea:	e8 41 ff ff ff       	call   f0101630 <user_mem_check>
f01016ef:	85 c0                	test   %eax,%eax
f01016f1:	79 24                	jns    f0101717 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01016f3:	a1 58 32 23 f0       	mov    0xf0233258,%eax
f01016f8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016fc:	8b 43 48             	mov    0x48(%ebx),%eax
f01016ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101703:	c7 04 24 74 5f 10 f0 	movl   $0xf0105f74,(%esp)
f010170a:	e8 ec 19 00 00       	call   f01030fb <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010170f:	89 1c 24             	mov    %ebx,(%esp)
f0101712:	e8 bc 13 00 00       	call   f0102ad3 <env_destroy>
	}
}
f0101717:	83 c4 14             	add    $0x14,%esp
f010171a:	5b                   	pop    %ebx
f010171b:	5d                   	pop    %ebp
f010171c:	c3                   	ret    

f010171d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010171d:	55                   	push   %ebp
f010171e:	89 e5                	mov    %esp,%ebp
f0101720:	53                   	push   %ebx
f0101721:	83 ec 14             	sub    $0x14,%esp
f0101724:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t* pte = pgdir_walk(pgdir, (void *)va, 0);
f0101727:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010172e:	00 
f010172f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101732:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101736:	8b 45 08             	mov    0x8(%ebp),%eax
f0101739:	89 04 24             	mov    %eax,(%esp)
f010173c:	e8 09 fe ff ff       	call   f010154a <pgdir_walk>
	if (pte_store != 0)
f0101741:	85 db                	test   %ebx,%ebx
f0101743:	74 02                	je     f0101747 <page_lookup+0x2a>
		*pte_store = pte;
f0101745:	89 03                	mov    %eax,(%ebx)
	//stone: here i miss "pte != NULL" and debug for a long time, it's important cuz "*pte & PTE_P" only means the page is not presented, 
	//but not mean *pte present or not.
	if ((pte != NULL) && (*pte & PTE_P)){
f0101747:	85 c0                	test   %eax,%eax
f0101749:	74 38                	je     f0101783 <page_lookup+0x66>
f010174b:	8b 00                	mov    (%eax),%eax
f010174d:	a8 01                	test   $0x1,%al
f010174f:	74 32                	je     f0101783 <page_lookup+0x66>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101751:	c1 e8 0c             	shr    $0xc,%eax
f0101754:	3b 05 08 3f 23 f0    	cmp    0xf0233f08,%eax
f010175a:	72 1c                	jb     f0101778 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010175c:	c7 44 24 08 ac 5f 10 	movl   $0xf0105fac,0x8(%esp)
f0101763:	f0 
f0101764:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f010176b:	00 
f010176c:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0101773:	e8 0d e9 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101778:	c1 e0 03             	shl    $0x3,%eax
f010177b:	03 05 10 3f 23 f0    	add    0xf0233f10,%eax
		struct Page* result = pa2page(PTE_ADDR(*pte));
		return result;
f0101781:	eb 05                	jmp    f0101788 <page_lookup+0x6b>
f0101783:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	else 
		return NULL;
}
f0101788:	83 c4 14             	add    $0x14,%esp
f010178b:	5b                   	pop    %ebx
f010178c:	5d                   	pop    %ebp
f010178d:	c3                   	ret    

f010178e <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010178e:	55                   	push   %ebp
f010178f:	89 e5                	mov    %esp,%ebp
f0101791:	83 ec 28             	sub    $0x28,%esp
f0101794:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101797:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010179a:	8b 75 08             	mov    0x8(%ebp),%esi
f010179d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t* pte;
	struct Page* pp = page_lookup(pgdir, va, &pte);
f01017a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01017a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017ab:	89 34 24             	mov    %esi,(%esp)
f01017ae:	e8 6a ff ff ff       	call   f010171d <page_lookup>
	if (pp != NULL){
f01017b3:	85 c0                	test   %eax,%eax
f01017b5:	74 1d                	je     f01017d4 <page_remove+0x46>
		*pte = 0;
f01017b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017ba:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(pp);
f01017c0:	89 04 24             	mov    %eax,(%esp)
f01017c3:	e8 34 f7 ff ff       	call   f0100efc <page_decref>
		tlb_invalidate(pgdir, va);		
f01017c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017cc:	89 34 24             	mov    %esi,(%esp)
f01017cf:	e8 0b f8 ff ff       	call   f0100fdf <tlb_invalidate>
	}
	return;
}
f01017d4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01017d7:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01017da:	89 ec                	mov    %ebp,%esp
f01017dc:	5d                   	pop    %ebp
f01017dd:	c3                   	ret    

f01017de <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01017de:	55                   	push   %ebp
f01017df:	89 e5                	mov    %esp,%ebp
f01017e1:	83 ec 48             	sub    $0x48,%esp
f01017e4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01017e7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01017ea:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01017ed:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01017f3:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01017f6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01017fd:	00 
f01017fe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101802:	89 3c 24             	mov    %edi,(%esp)
f0101805:	e8 40 fd ff ff       	call   f010154a <pgdir_walk>
f010180a:	89 c2                	mov    %eax,%edx
	if (pte == NULL) return -E_NO_MEM;
f010180c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101811:	85 d2                	test   %edx,%edx
f0101813:	74 7b                	je     f0101890 <page_insert+0xb2>
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101815:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if (pte == NULL) return -E_NO_MEM;

	if (pp == page_lookup(pgdir, va, &pte)){
f0101818:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010181b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010181f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101823:	89 3c 24             	mov    %edi,(%esp)
f0101826:	e8 f2 fe ff ff       	call   f010171d <page_lookup>
f010182b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010182e:	39 d8                	cmp    %ebx,%eax
f0101830:	75 2f                	jne    f0101861 <page_insert+0x83>
		tlb_invalidate(pgdir, va);
f0101832:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101836:	89 3c 24             	mov    %edi,(%esp)
f0101839:	e8 a1 f7 ff ff       	call   f0100fdf <tlb_invalidate>
		*pte = page2pa(pp) | perm | PTE_P;
f010183e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101841:	83 c8 01             	or     $0x1,%eax
f0101844:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101847:	2b 15 10 3f 23 f0    	sub    0xf0233f10,%edx
f010184d:	c1 fa 03             	sar    $0x3,%edx
f0101850:	c1 e2 0c             	shl    $0xc,%edx
f0101853:	09 c2                	or     %eax,%edx
f0101855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101858:	89 10                	mov    %edx,(%eax)
f010185a:	b8 00 00 00 00       	mov    $0x0,%eax
f010185f:	eb 2f                	jmp    f0101890 <page_insert+0xb2>
	}
	else{
		page_remove(pgdir, va);
f0101861:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101865:	89 3c 24             	mov    %edi,(%esp)
f0101868:	e8 21 ff ff ff       	call   f010178e <page_remove>
		pp->pp_ref++;
f010186d:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		*pte = page2pa(pp) | perm | PTE_P;
f0101872:	8b 45 14             	mov    0x14(%ebp),%eax
f0101875:	83 c8 01             	or     $0x1,%eax
f0101878:	2b 1d 10 3f 23 f0    	sub    0xf0233f10,%ebx
f010187e:	c1 fb 03             	sar    $0x3,%ebx
f0101881:	c1 e3 0c             	shl    $0xc,%ebx
f0101884:	09 c3                	or     %eax,%ebx
f0101886:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101889:	89 18                	mov    %ebx,(%eax)
f010188b:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return 0;
}
f0101890:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101893:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101896:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101899:	89 ec                	mov    %ebp,%esp
f010189b:	5d                   	pop    %ebp
f010189c:	c3                   	ret    

f010189d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010189d:	55                   	push   %ebp
f010189e:	89 e5                	mov    %esp,%ebp
f01018a0:	57                   	push   %edi
f01018a1:	56                   	push   %esi
f01018a2:	53                   	push   %ebx
f01018a3:	83 ec 2c             	sub    $0x2c,%esp
f01018a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
f01018a9:	c1 e9 0c             	shr    $0xc,%ecx
f01018ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
f01018af:	85 c9                	test   %ecx,%ecx
f01018b1:	74 49                	je     f01018fc <boot_map_region+0x5f>
f01018b3:	89 d6                	mov    %edx,%esi
f01018b5:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
f01018ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01018bd:	83 cf 01             	or     $0x1,%edi
f01018c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01018c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01018c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
f01018cb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01018d2:	00 
f01018d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01018da:	89 04 24             	mov    %eax,(%esp)
f01018dd:	e8 68 fc ff ff       	call   f010154a <pgdir_walk>
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
f01018e2:	89 da                	mov    %ebx,%edx
f01018e4:	c1 e2 0c             	shl    $0xc,%edx
f01018e7:	03 55 e4             	add    -0x1c(%ebp),%edx
f01018ea:	09 fa                	or     %edi,%edx
f01018ec:	89 10                	mov    %edx,(%eax)
		vaddr = vaddr + PGSIZE;
f01018ee:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// Fill this function in
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
f01018f4:	83 c3 01             	add    $0x1,%ebx
f01018f7:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f01018fa:	77 cf                	ja     f01018cb <boot_map_region+0x2e>
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
		vaddr = vaddr + PGSIZE;
	}
}
f01018fc:	83 c4 2c             	add    $0x2c,%esp
f01018ff:	5b                   	pop    %ebx
f0101900:	5e                   	pop    %esi
f0101901:	5f                   	pop    %edi
f0101902:	5d                   	pop    %ebp
f0101903:	c3                   	ret    

f0101904 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101904:	55                   	push   %ebp
f0101905:	89 e5                	mov    %esp,%ebp
f0101907:	57                   	push   %edi
f0101908:	56                   	push   %esi
f0101909:	53                   	push   %ebx
f010190a:	83 ec 5c             	sub    $0x5c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010190d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101912:	e8 fd f6 ff ff       	call   f0101014 <nvram_read>
f0101917:	c1 e0 0a             	shl    $0xa,%eax
f010191a:	89 c2                	mov    %eax,%edx
f010191c:	c1 fa 1f             	sar    $0x1f,%edx
f010191f:	c1 ea 14             	shr    $0x14,%edx
f0101922:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101925:	c1 f8 0c             	sar    $0xc,%eax
f0101928:	a3 4c 32 23 f0       	mov    %eax,0xf023324c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010192d:	b8 17 00 00 00       	mov    $0x17,%eax
f0101932:	e8 dd f6 ff ff       	call   f0101014 <nvram_read>
f0101937:	c1 e0 0a             	shl    $0xa,%eax
f010193a:	89 c2                	mov    %eax,%edx
f010193c:	c1 fa 1f             	sar    $0x1f,%edx
f010193f:	c1 ea 14             	shr    $0x14,%edx
f0101942:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101945:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101948:	85 c0                	test   %eax,%eax
f010194a:	74 0e                	je     f010195a <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010194c:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101952:	89 15 08 3f 23 f0    	mov    %edx,0xf0233f08
f0101958:	eb 0c                	jmp    f0101966 <mem_init+0x62>
	else
		npages = npages_basemem;
f010195a:	8b 15 4c 32 23 f0    	mov    0xf023324c,%edx
f0101960:	89 15 08 3f 23 f0    	mov    %edx,0xf0233f08

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101966:	c1 e0 0c             	shl    $0xc,%eax
f0101969:	c1 e8 0a             	shr    $0xa,%eax
f010196c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101970:	a1 4c 32 23 f0       	mov    0xf023324c,%eax
f0101975:	c1 e0 0c             	shl    $0xc,%eax
f0101978:	c1 e8 0a             	shr    $0xa,%eax
f010197b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010197f:	a1 08 3f 23 f0       	mov    0xf0233f08,%eax
f0101984:	c1 e0 0c             	shl    $0xc,%eax
f0101987:	c1 e8 0a             	shr    $0xa,%eax
f010198a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010198e:	c7 04 24 cc 5f 10 f0 	movl   $0xf0105fcc,(%esp)
f0101995:	e8 61 17 00 00       	call   f01030fb <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010199a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010199f:	e8 95 f9 ff ff       	call   f0101339 <boot_alloc>
f01019a4:	a3 0c 3f 23 f0       	mov    %eax,0xf0233f0c
	memset(kern_pgdir, 0, PGSIZE);
f01019a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019b0:	00 
f01019b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019b8:	00 
f01019b9:	89 04 24             	mov    %eax,(%esp)
f01019bc:	e8 b5 30 00 00       	call   f0104a76 <memset>
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	//user writeable
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01019c1:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01019c6:	89 c2                	mov    %eax,%edx
f01019c8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01019cd:	77 20                	ja     f01019ef <mem_init+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01019cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019d3:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f01019da:	f0 
f01019db:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01019e2:	00 
f01019e3:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01019ea:	e8 96 e6 ff ff       	call   f0100085 <_panic>
f01019ef:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01019f5:	83 ca 05             	or     $0x5,%edx
f01019f8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
//<<<<<<< HEAD
	/*stone's solution for lab2*/
	pages = (struct Page*) boot_alloc(npages * sizeof(struct Page));
f01019fe:	a1 08 3f 23 f0       	mov    0xf0233f08,%eax
f0101a03:	c1 e0 03             	shl    $0x3,%eax
f0101a06:	e8 2e f9 ff ff       	call   f0101339 <boot_alloc>
f0101a0b:	a3 10 3f 23 f0       	mov    %eax,0xf0233f10

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101a10:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101a15:	e8 1f f9 ff ff       	call   f0101339 <boot_alloc>
f0101a1a:	a3 5c 32 23 f0       	mov    %eax,0xf023325c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a1f:	e8 be f9 ff ff       	call   f01013e2 <page_init>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101a24:	a1 50 32 23 f0       	mov    0xf0233250,%eax
f0101a29:	85 c0                	test   %eax,%eax
f0101a2b:	75 1c                	jne    f0101a49 <mem_init+0x145>
		panic("'page_free_list' is a null pointer!");
f0101a2d:	c7 44 24 08 08 60 10 	movl   $0xf0106008,0x8(%esp)
f0101a34:	f0 
f0101a35:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101a3c:	00 
f0101a3d:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101a44:	e8 3c e6 ff ff       	call   f0100085 <_panic>
	//cprintf("2");
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0101a49:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101a4c:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0101a4f:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0101a52:	89 55 dc             	mov    %edx,-0x24(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101a55:	89 c2                	mov    %eax,%edx
f0101a57:	2b 15 10 3f 23 f0    	sub    0xf0233f10,%edx
f0101a5d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101a63:	0f 95 c2             	setne  %dl
f0101a66:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101a69:	8b 4c 95 d8          	mov    -0x28(%ebp,%edx,4),%ecx
f0101a6d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101a6f:	89 44 95 d8          	mov    %eax,-0x28(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101a73:	8b 00                	mov    (%eax),%eax
f0101a75:	85 c0                	test   %eax,%eax
f0101a77:	75 dc                	jne    f0101a55 <mem_init+0x151>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101a7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101a82:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101a85:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101a88:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101a8a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101a8d:	89 1d 50 32 23 f0    	mov    %ebx,0xf0233250
	}
	//cprintf("2");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101a93:	85 db                	test   %ebx,%ebx
f0101a95:	74 68                	je     f0101aff <mem_init+0x1fb>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a97:	89 d8                	mov    %ebx,%eax
f0101a99:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f0101a9f:	c1 f8 03             	sar    $0x3,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101aa2:	89 c2                	mov    %eax,%edx
f0101aa4:	c1 e2 0c             	shl    $0xc,%edx
f0101aa7:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0101aac:	75 4b                	jne    f0101af9 <mem_init+0x1f5>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101aae:	89 d0                	mov    %edx,%eax
f0101ab0:	c1 e8 0c             	shr    $0xc,%eax
f0101ab3:	3b 05 08 3f 23 f0    	cmp    0xf0233f08,%eax
f0101ab9:	72 20                	jb     f0101adb <mem_init+0x1d7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101abb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101abf:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0101ac6:	f0 
f0101ac7:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101ace:	00 
f0101acf:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0101ad6:	e8 aa e5 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101adb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101ae2:	00 
f0101ae3:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101aea:	00 
f0101aeb:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101af1:	89 14 24             	mov    %edx,(%esp)
f0101af4:	e8 7d 2f 00 00       	call   f0104a76 <memset>
		page_free_list = pp1;
	}
	//cprintf("2");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101af9:	8b 1b                	mov    (%ebx),%ebx
f0101afb:	85 db                	test   %ebx,%ebx
f0101afd:	75 98                	jne    f0101a97 <mem_init+0x193>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
f0101aff:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b04:	e8 30 f8 ff ff       	call   f0101339 <boot_alloc>
f0101b09:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101b0c:	8b 15 50 32 23 f0    	mov    0xf0233250,%edx
f0101b12:	85 d2                	test   %edx,%edx
f0101b14:	0f 84 44 02 00 00    	je     f0101d5e <mem_init+0x45a>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101b1a:	8b 1d 10 3f 23 f0    	mov    0xf0233f10,%ebx
f0101b20:	39 d3                	cmp    %edx,%ebx
f0101b22:	77 56                	ja     f0101b7a <mem_init+0x276>
		assert(pp < pages + npages);
f0101b24:	a1 08 3f 23 f0       	mov    0xf0233f08,%eax
f0101b29:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101b2c:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101b2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b32:	39 c2                	cmp    %eax,%edx
f0101b34:	73 6d                	jae    f0101ba3 <mem_init+0x29f>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101b36:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101b39:	89 d0                	mov    %edx,%eax
f0101b3b:	29 d8                	sub    %ebx,%eax
f0101b3d:	a8 07                	test   $0x7,%al
f0101b3f:	0f 85 8b 00 00 00    	jne    f0101bd0 <mem_init+0x2cc>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b45:	c1 f8 03             	sar    $0x3,%eax
f0101b48:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101b4b:	85 c0                	test   %eax,%eax
f0101b4d:	0f 84 ab 00 00 00    	je     f0101bfe <mem_init+0x2fa>
		assert(page2pa(pp) != IOPHYSMEM);
f0101b53:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101b58:	0f 84 cb 00 00 00    	je     f0101c29 <mem_init+0x325>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101b5e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101b63:	0f 85 0f 01 00 00    	jne    f0101c78 <mem_init+0x374>
f0101b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b70:	e9 df 00 00 00       	jmp    f0101c54 <mem_init+0x350>
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101b75:	39 55 b4             	cmp    %edx,-0x4c(%ebp)
f0101b78:	76 24                	jbe    f0101b9e <mem_init+0x29a>
f0101b7a:	c7 44 24 0c c7 62 10 	movl   $0xf01062c7,0xc(%esp)
f0101b81:	f0 
f0101b82:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101b89:	f0 
f0101b8a:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101b91:	00 
f0101b92:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101b99:	e8 e7 e4 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101b9e:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101ba1:	77 24                	ja     f0101bc7 <mem_init+0x2c3>
f0101ba3:	c7 44 24 0c e8 62 10 	movl   $0xf01062e8,0xc(%esp)
f0101baa:	f0 
f0101bab:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101bb2:	f0 
f0101bb3:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101bba:	00 
f0101bbb:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101bc2:	e8 be e4 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101bc7:	89 d0                	mov    %edx,%eax
f0101bc9:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101bcc:	a8 07                	test   $0x7,%al
f0101bce:	74 24                	je     f0101bf4 <mem_init+0x2f0>
f0101bd0:	c7 44 24 0c 2c 60 10 	movl   $0xf010602c,0xc(%esp)
f0101bd7:	f0 
f0101bd8:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101bdf:	f0 
f0101be0:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101be7:	00 
f0101be8:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101bef:	e8 91 e4 ff ff       	call   f0100085 <_panic>
f0101bf4:	c1 f8 03             	sar    $0x3,%eax
f0101bf7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101bfa:	85 c0                	test   %eax,%eax
f0101bfc:	75 24                	jne    f0101c22 <mem_init+0x31e>
f0101bfe:	c7 44 24 0c fc 62 10 	movl   $0xf01062fc,0xc(%esp)
f0101c05:	f0 
f0101c06:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101c0d:	f0 
f0101c0e:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101c15:	00 
f0101c16:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101c1d:	e8 63 e4 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101c22:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101c27:	75 24                	jne    f0101c4d <mem_init+0x349>
f0101c29:	c7 44 24 0c 0d 63 10 	movl   $0xf010630d,0xc(%esp)
f0101c30:	f0 
f0101c31:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101c38:	f0 
f0101c39:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101c40:	00 
f0101c41:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101c48:	e8 38 e4 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101c4d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101c52:	75 31                	jne    f0101c85 <mem_init+0x381>
f0101c54:	c7 44 24 0c 60 60 10 	movl   $0xf0106060,0xc(%esp)
f0101c5b:	f0 
f0101c5c:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101c63:	f0 
f0101c64:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101c6b:	00 
f0101c6c:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101c73:	e8 0d e4 ff ff       	call   f0100085 <_panic>
f0101c78:	be 00 00 00 00       	mov    $0x0,%esi
f0101c7d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101c82:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0101c85:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101c8a:	75 24                	jne    f0101cb0 <mem_init+0x3ac>
f0101c8c:	c7 44 24 0c 26 63 10 	movl   $0xf0106326,0xc(%esp)
f0101c93:	f0 
f0101c94:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101c9b:	f0 
f0101c9c:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101ca3:	00 
f0101ca4:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101cab:	e8 d5 e3 ff ff       	call   f0100085 <_panic>
f0101cb0:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101cb2:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101cb7:	76 59                	jbe    f0101d12 <mem_init+0x40e>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cb9:	89 c3                	mov    %eax,%ebx
f0101cbb:	c1 eb 0c             	shr    $0xc,%ebx
f0101cbe:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101cc1:	77 20                	ja     f0101ce3 <mem_init+0x3df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cc7:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0101cce:	f0 
f0101ccf:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101cd6:	00 
f0101cd7:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0101cde:	e8 a2 e3 ff ff       	call   f0100085 <_panic>
f0101ce3:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101ce9:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101cec:	76 24                	jbe    f0101d12 <mem_init+0x40e>
f0101cee:	c7 44 24 0c 84 60 10 	movl   $0xf0106084,0xc(%esp)
f0101cf5:	f0 
f0101cf6:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101cfd:	f0 
f0101cfe:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101d05:	00 
f0101d06:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101d0d:	e8 73 e3 ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101d12:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101d17:	75 24                	jne    f0101d3d <mem_init+0x439>
f0101d19:	c7 44 24 0c 40 63 10 	movl   $0xf0106340,0xc(%esp)
f0101d20:	f0 
f0101d21:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101d28:	f0 
f0101d29:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101d30:	00 
f0101d31:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101d38:	e8 48 e3 ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0101d3d:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101d43:	77 05                	ja     f0101d4a <mem_init+0x446>
			++nfree_basemem;
f0101d45:	83 c7 01             	add    $0x1,%edi
f0101d48:	eb 03                	jmp    f0101d4d <mem_init+0x449>
		else
			++nfree_extmem;
f0101d4a:	83 c6 01             	add    $0x1,%esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101d4d:	8b 12                	mov    (%edx),%edx
f0101d4f:	85 d2                	test   %edx,%edx
f0101d51:	0f 85 1e fe ff ff    	jne    f0101b75 <mem_init+0x271>
f0101d57:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}
	//cprintf("2");
	assert(nfree_basemem > 0);
f0101d5a:	85 ff                	test   %edi,%edi
f0101d5c:	7f 24                	jg     f0101d82 <mem_init+0x47e>
f0101d5e:	c7 44 24 0c 5d 63 10 	movl   $0xf010635d,0xc(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101d75:	00 
f0101d76:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101d7d:	e8 03 e3 ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0101d82:	85 f6                	test   %esi,%esi
f0101d84:	7f 24                	jg     f0101daa <mem_init+0x4a6>
f0101d86:	c7 44 24 0c 6f 63 10 	movl   $0xf010636f,0xc(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101d95:	f0 
f0101d96:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101d9d:	00 
f0101d9e:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101da5:	e8 db e2 ff ff       	call   f0100085 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101daa:	89 d8                	mov    %ebx,%eax
f0101dac:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101db2:	77 20                	ja     f0101dd4 <mem_init+0x4d0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101db4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101db8:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101dbf:	f0 
f0101dc0:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f0101dc7:	00 
f0101dc8:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101dcf:	e8 b1 e2 ff ff       	call   f0100085 <_panic>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	/*stone's solution for lab2*/
	//RO pages for PTSIZE
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0101dd4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0101ddb:	00 
f0101ddc:	05 00 00 00 10       	add    $0x10000000,%eax
f0101de1:	89 04 24             	mov    %eax,(%esp)
f0101de4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0101de9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101dee:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f0101df3:	e8 a5 fa ff ff       	call   f010189d <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0101df8:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101dfd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e02:	77 20                	ja     f0101e24 <mem_init+0x520>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101e04:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e08:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101e0f:	f0 
f0101e10:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f0101e17:	00 
f0101e18:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101e1f:	e8 61 e2 ff ff       	call   f0100085 <_panic>
f0101e24:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0101e2b:	00 
f0101e2c:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0101e32:	89 04 24             	mov    %eax,(%esp)
f0101e35:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0101e3a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101e3f:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f0101e44:	e8 54 fa ff ff       	call   f010189d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101e49:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0101e4e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e53:	77 20                	ja     f0101e75 <mem_init+0x571>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101e55:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e59:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101e60:	f0 
f0101e61:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
f0101e68:	00 
f0101e69:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101e70:	e8 10 e2 ff ff       	call   f0100085 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	/*stone's solution for lab2*/
	//kernel stack for 8*PGSIZE
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
f0101e75:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0101e7c:	00 
f0101e7d:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e82:	89 04 24             	mov    %eax,(%esp)
f0101e85:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101e8a:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0101e8f:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f0101e94:	e8 04 fa ff ff       	call   f010189d <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0101e99:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101ea0:	00 
f0101ea1:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f0101ea8:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0101ead:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0101eb2:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f0101eb7:	e8 e1 f9 ff ff       	call   f010189d <boot_map_region>
	mem_init_mp();

//=======
	/*stone's solution for lab2*/
	//remapped physical memory
	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(0xFFFFFFFF - KERNBASE, PGSIZE), 0, PTE_P | PTE_W);
f0101ebc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0101ec3:	00 
f0101ec4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ecb:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101ed0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101ed5:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f0101eda:	e8 be f9 ff ff       	call   f010189d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0101edf:	8b 35 0c 3f 23 f0    	mov    0xf0233f0c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0101ee5:	a1 08 3f 23 f0       	mov    0xf0233f08,%eax
f0101eea:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0101ef1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101ef7:	74 79                	je     f0101f72 <mem_init+0x66e>
f0101ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101efe:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0101f04:	89 f0                	mov    %esi,%eax
f0101f06:	e8 c8 f3 ff ff       	call   f01012d3 <check_va2pa>
f0101f0b:	8b 15 10 3f 23 f0    	mov    0xf0233f10,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101f11:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101f17:	77 20                	ja     f0101f39 <mem_init+0x635>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101f19:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101f1d:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101f24:	f0 
f0101f25:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101f2c:	00 
f0101f2d:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101f34:	e8 4c e1 ff ff       	call   f0100085 <_panic>
f0101f39:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0101f40:	39 d0                	cmp    %edx,%eax
f0101f42:	74 24                	je     f0101f68 <mem_init+0x664>
f0101f44:	c7 44 24 0c cc 60 10 	movl   $0xf01060cc,0xc(%esp)
f0101f4b:	f0 
f0101f4c:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101f53:	f0 
f0101f54:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101f5b:	00 
f0101f5c:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101f63:	e8 1d e1 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101f68:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101f6e:	39 df                	cmp    %ebx,%edi
f0101f70:	77 8c                	ja     f0101efe <mem_init+0x5fa>
f0101f72:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101f77:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0101f7d:	89 f0                	mov    %esi,%eax
f0101f7f:	e8 4f f3 ff ff       	call   f01012d3 <check_va2pa>
f0101f84:	8b 15 5c 32 23 f0    	mov    0xf023325c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101f8a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101f90:	77 20                	ja     f0101fb2 <mem_init+0x6ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101f92:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101f96:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101fa5:	00 
f0101fa6:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101fad:	e8 d3 e0 ff ff       	call   f0100085 <_panic>
f0101fb2:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0101fb9:	39 d0                	cmp    %edx,%eax
f0101fbb:	74 24                	je     f0101fe1 <mem_init+0x6dd>
f0101fbd:	c7 44 24 0c 00 61 10 	movl   $0xf0106100,0xc(%esp)
f0101fc4:	f0 
f0101fc5:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0101fcc:	f0 
f0101fcd:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101fd4:	00 
f0101fd5:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0101fdc:	e8 a4 e0 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101fe1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101fe7:	81 fb 00 00 02 00    	cmp    $0x20000,%ebx
f0101fed:	75 88                	jne    f0101f77 <mem_init+0x673>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101fef:	a1 08 3f 23 f0       	mov    0xf0233f08,%eax
f0101ff4:	c1 e0 0c             	shl    $0xc,%eax
f0101ff7:	85 c0                	test   %eax,%eax
f0101ff9:	74 4c                	je     f0102047 <mem_init+0x743>
f0101ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102000:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102006:	89 f0                	mov    %esi,%eax
f0102008:	e8 c6 f2 ff ff       	call   f01012d3 <check_va2pa>
f010200d:	39 c3                	cmp    %eax,%ebx
f010200f:	74 24                	je     f0102035 <mem_init+0x731>
f0102011:	c7 44 24 0c 34 61 10 	movl   $0xf0106134,0xc(%esp)
f0102018:	f0 
f0102019:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102020:	f0 
f0102021:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102028:	00 
f0102029:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102030:	e8 50 e0 ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102035:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010203b:	a1 08 3f 23 f0       	mov    0xf0233f08,%eax
f0102040:	c1 e0 0c             	shl    $0xc,%eax
f0102043:	39 c3                	cmp    %eax,%ebx
f0102045:	72 b9                	jb     f0102000 <mem_init+0x6fc>
f0102047:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f010204c:	89 da                	mov    %ebx,%edx
f010204e:	89 f0                	mov    %esi,%eax
f0102050:	e8 7e f2 ff ff       	call   f01012d3 <check_va2pa>
f0102055:	39 c3                	cmp    %eax,%ebx
f0102057:	74 24                	je     f010207d <mem_init+0x779>
f0102059:	c7 44 24 0c 80 63 10 	movl   $0xf0106380,0xc(%esp)
f0102060:	f0 
f0102061:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102068:	f0 
f0102069:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0102070:	00 
f0102071:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102078:	e8 08 e0 ff ff       	call   f0100085 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f010207d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102083:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0102089:	75 c1                	jne    f010204c <mem_init+0x748>
f010208b:	c7 45 d0 00 50 23 f0 	movl   $0xf0235000,-0x30(%ebp)
f0102092:	c7 45 cc 00 00 bf ef 	movl   $0xefbf0000,-0x34(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102099:	89 f7                	mov    %esi,%edi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f010209b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010209e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01020a1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f01020a4:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01020aa:	89 c6                	mov    %eax,%esi
f01020ac:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f01020b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020b5:	05 00 00 01 00       	add    $0x10000,%eax
f01020ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01020bd:	89 da                	mov    %ebx,%edx
f01020bf:	89 f8                	mov    %edi,%eax
f01020c1:	e8 0d f2 ff ff       	call   f01012d3 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020c6:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01020cd:	77 23                	ja     f01020f2 <mem_init+0x7ee>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020cf:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01020d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01020d6:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f01020dd:	f0 
f01020de:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f01020e5:	00 
f01020e6:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01020ed:	e8 93 df ff ff       	call   f0100085 <_panic>
f01020f2:	39 f0                	cmp    %esi,%eax
f01020f4:	74 24                	je     f010211a <mem_init+0x816>
f01020f6:	c7 44 24 0c 5c 61 10 	movl   $0xf010615c,0xc(%esp)
f01020fd:	f0 
f01020fe:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102105:	f0 
f0102106:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f010210d:	00 
f010210e:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102115:	e8 6b df ff ff       	call   f0100085 <_panic>
f010211a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102120:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102126:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102129:	0f 85 53 05 00 00    	jne    f0102682 <mem_init+0xd7e>
f010212f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102134:	8b 75 cc             	mov    -0x34(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102137:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010213a:	89 f8                	mov    %edi,%eax
f010213c:	e8 92 f1 ff ff       	call   f01012d3 <check_va2pa>
f0102141:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102144:	74 24                	je     f010216a <mem_init+0x866>
f0102146:	c7 44 24 0c a4 61 10 	movl   $0xf01061a4,0xc(%esp)
f010214d:	f0 
f010214e:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102155:	f0 
f0102156:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f010215d:	00 
f010215e:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102165:	e8 1b df ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010216a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102170:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102176:	75 bf                	jne    f0102137 <mem_init+0x833>
f0102178:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f010217f:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102186:	81 7d cc 00 00 b7 ef 	cmpl   $0xefb70000,-0x34(%ebp)
f010218d:	0f 85 08 ff ff ff    	jne    f010209b <mem_init+0x797>
f0102193:	89 fe                	mov    %edi,%esi
f0102195:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010219a:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01021a0:	83 fa 03             	cmp    $0x3,%edx
f01021a3:	77 2e                	ja     f01021d3 <mem_init+0x8cf>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01021a5:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01021a9:	0f 85 aa 00 00 00    	jne    f0102259 <mem_init+0x955>
f01021af:	c7 44 24 0c 9b 63 10 	movl   $0xf010639b,0xc(%esp)
f01021b6:	f0 
f01021b7:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01021be:	f0 
f01021bf:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01021c6:	00 
f01021c7:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01021ce:	e8 b2 de ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01021d3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01021d8:	76 55                	jbe    f010222f <mem_init+0x92b>
				assert(pgdir[i] & PTE_P);
f01021da:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01021dd:	f6 c2 01             	test   $0x1,%dl
f01021e0:	75 24                	jne    f0102206 <mem_init+0x902>
f01021e2:	c7 44 24 0c 9b 63 10 	movl   $0xf010639b,0xc(%esp)
f01021e9:	f0 
f01021ea:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01021f1:	f0 
f01021f2:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f01021f9:	00 
f01021fa:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102201:	e8 7f de ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f0102206:	f6 c2 02             	test   $0x2,%dl
f0102209:	75 4e                	jne    f0102259 <mem_init+0x955>
f010220b:	c7 44 24 0c ac 63 10 	movl   $0xf01063ac,0xc(%esp)
f0102212:	f0 
f0102213:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f010221a:	f0 
f010221b:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102222:	00 
f0102223:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010222a:	e8 56 de ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f010222f:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102233:	74 24                	je     f0102259 <mem_init+0x955>
f0102235:	c7 44 24 0c bd 63 10 	movl   $0xf01063bd,0xc(%esp)
f010223c:	f0 
f010223d:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102244:	f0 
f0102245:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010224c:	00 
f010224d:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102254:	e8 2c de ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102259:	83 c0 01             	add    $0x1,%eax
f010225c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102261:	0f 85 33 ff ff ff    	jne    f010219a <mem_init+0x896>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102267:	c7 04 24 c8 61 10 f0 	movl   $0xf01061c8,(%esp)
f010226e:	e8 88 0e 00 00       	call   f01030fb <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102273:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102278:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010227d:	77 20                	ja     f010229f <mem_init+0x99b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010227f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102283:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f010228a:	f0 
f010228b:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
f0102292:	00 
f0102293:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010229a:	e8 e6 dd ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010229f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01022a5:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01022a8:	0f 20 c0             	mov    %cr0,%eax
	//check_page_free_list(0);
	//cprintf("1");
	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01022ab:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01022b0:	83 e0 f3             	and    $0xfffffff3,%eax
f01022b3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;
	//cprintf("1");
	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01022b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022bd:	e8 04 f2 ff ff       	call   f01014c6 <page_alloc>
f01022c2:	89 c3                	mov    %eax,%ebx
f01022c4:	85 c0                	test   %eax,%eax
f01022c6:	75 24                	jne    f01022ec <mem_init+0x9e8>
f01022c8:	c7 44 24 0c cb 63 10 	movl   $0xf01063cb,0xc(%esp)
f01022cf:	f0 
f01022d0:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01022d7:	f0 
f01022d8:	c7 44 24 04 3e 05 00 	movl   $0x53e,0x4(%esp)
f01022df:	00 
f01022e0:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01022e7:	e8 99 dd ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01022ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022f3:	e8 ce f1 ff ff       	call   f01014c6 <page_alloc>
f01022f8:	89 c7                	mov    %eax,%edi
f01022fa:	85 c0                	test   %eax,%eax
f01022fc:	75 24                	jne    f0102322 <mem_init+0xa1e>
f01022fe:	c7 44 24 0c e1 63 10 	movl   $0xf01063e1,0xc(%esp)
f0102305:	f0 
f0102306:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f010230d:	f0 
f010230e:	c7 44 24 04 3f 05 00 	movl   $0x53f,0x4(%esp)
f0102315:	00 
f0102316:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010231d:	e8 63 dd ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102322:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102329:	e8 98 f1 ff ff       	call   f01014c6 <page_alloc>
f010232e:	89 c6                	mov    %eax,%esi
f0102330:	85 c0                	test   %eax,%eax
f0102332:	75 24                	jne    f0102358 <mem_init+0xa54>
f0102334:	c7 44 24 0c f7 63 10 	movl   $0xf01063f7,0xc(%esp)
f010233b:	f0 
f010233c:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102343:	f0 
f0102344:	c7 44 24 04 40 05 00 	movl   $0x540,0x4(%esp)
f010234b:	00 
f010234c:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102353:	e8 2d dd ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	page_free(pp0);
f0102358:	89 1c 24             	mov    %ebx,(%esp)
f010235b:	e8 80 eb ff ff       	call   f0100ee0 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102360:	89 f8                	mov    %edi,%eax
f0102362:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f0102368:	c1 f8 03             	sar    $0x3,%eax
f010236b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010236e:	89 c2                	mov    %eax,%edx
f0102370:	c1 ea 0c             	shr    $0xc,%edx
f0102373:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f0102379:	72 20                	jb     f010239b <mem_init+0xa97>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010237b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010237f:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0102386:	f0 
f0102387:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010238e:	00 
f010238f:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0102396:	e8 ea dc ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010239b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023a2:	00 
f01023a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01023aa:	00 
f01023ab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023b0:	89 04 24             	mov    %eax,(%esp)
f01023b3:	e8 be 26 00 00       	call   f0104a76 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01023b8:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01023bb:	89 f0                	mov    %esi,%eax
f01023bd:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f01023c3:	c1 f8 03             	sar    $0x3,%eax
f01023c6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023c9:	89 c2                	mov    %eax,%edx
f01023cb:	c1 ea 0c             	shr    $0xc,%edx
f01023ce:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f01023d4:	72 20                	jb     f01023f6 <mem_init+0xaf2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023da:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f01023e1:	f0 
f01023e2:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01023e9:	00 
f01023ea:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f01023f1:	e8 8f dc ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01023f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023fd:	00 
f01023fe:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102405:	00 
f0102406:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010240b:	89 04 24             	mov    %eax,(%esp)
f010240e:	e8 63 26 00 00       	call   f0104a76 <memset>
	//cprintf("1");
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102413:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010241a:	00 
f010241b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102422:	00 
f0102423:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102427:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f010242c:	89 04 24             	mov    %eax,(%esp)
f010242f:	e8 aa f3 ff ff       	call   f01017de <page_insert>
	//cprintf("1");
	assert(pp1->pp_ref == 1);
f0102434:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102439:	74 24                	je     f010245f <mem_init+0xb5b>
f010243b:	c7 44 24 0c 0d 64 10 	movl   $0xf010640d,0xc(%esp)
f0102442:	f0 
f0102443:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f010244a:	f0 
f010244b:	c7 44 24 04 48 05 00 	movl   $0x548,0x4(%esp)
f0102452:	00 
f0102453:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010245a:	e8 26 dc ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010245f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102466:	01 01 01 
f0102469:	74 24                	je     f010248f <mem_init+0xb8b>
f010246b:	c7 44 24 0c e8 61 10 	movl   $0xf01061e8,0xc(%esp)
f0102472:	f0 
f0102473:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f010247a:	f0 
f010247b:	c7 44 24 04 4a 05 00 	movl   $0x54a,0x4(%esp)
f0102482:	00 
f0102483:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010248a:	e8 f6 db ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010248f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102496:	00 
f0102497:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010249e:	00 
f010249f:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024a3:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f01024a8:	89 04 24             	mov    %eax,(%esp)
f01024ab:	e8 2e f3 ff ff       	call   f01017de <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024b0:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024b7:	02 02 02 
f01024ba:	74 24                	je     f01024e0 <mem_init+0xbdc>
f01024bc:	c7 44 24 0c 0c 62 10 	movl   $0xf010620c,0xc(%esp)
f01024c3:	f0 
f01024c4:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01024cb:	f0 
f01024cc:	c7 44 24 04 4c 05 00 	movl   $0x54c,0x4(%esp)
f01024d3:	00 
f01024d4:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01024db:	e8 a5 db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01024e0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024e5:	74 24                	je     f010250b <mem_init+0xc07>
f01024e7:	c7 44 24 0c 1e 64 10 	movl   $0xf010641e,0xc(%esp)
f01024ee:	f0 
f01024ef:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01024f6:	f0 
f01024f7:	c7 44 24 04 4d 05 00 	movl   $0x54d,0x4(%esp)
f01024fe:	00 
f01024ff:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102506:	e8 7a db ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f010250b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102510:	74 24                	je     f0102536 <mem_init+0xc32>
f0102512:	c7 44 24 0c 2f 64 10 	movl   $0xf010642f,0xc(%esp)
f0102519:	f0 
f010251a:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102521:	f0 
f0102522:	c7 44 24 04 4e 05 00 	movl   $0x54e,0x4(%esp)
f0102529:	00 
f010252a:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f0102531:	e8 4f db ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102536:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010253d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102540:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102543:	2b 05 10 3f 23 f0    	sub    0xf0233f10,%eax
f0102549:	c1 f8 03             	sar    $0x3,%eax
f010254c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010254f:	89 c2                	mov    %eax,%edx
f0102551:	c1 ea 0c             	shr    $0xc,%edx
f0102554:	3b 15 08 3f 23 f0    	cmp    0xf0233f08,%edx
f010255a:	72 20                	jb     f010257c <mem_init+0xc78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010255c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102560:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0102567:	f0 
f0102568:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010256f:	00 
f0102570:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0102577:	e8 09 db ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010257c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102583:	03 03 03 
f0102586:	74 24                	je     f01025ac <mem_init+0xca8>
f0102588:	c7 44 24 0c 30 62 10 	movl   $0xf0106230,0xc(%esp)
f010258f:	f0 
f0102590:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f0102597:	f0 
f0102598:	c7 44 24 04 50 05 00 	movl   $0x550,0x4(%esp)
f010259f:	00 
f01025a0:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01025a7:	e8 d9 da ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025ac:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025b3:	00 
f01025b4:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f01025b9:	89 04 24             	mov    %eax,(%esp)
f01025bc:	e8 cd f1 ff ff       	call   f010178e <page_remove>
	assert(pp2->pp_ref == 0);
f01025c1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025c6:	74 24                	je     f01025ec <mem_init+0xce8>
f01025c8:	c7 44 24 0c 40 64 10 	movl   $0xf0106440,0xc(%esp)
f01025cf:	f0 
f01025d0:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01025d7:	f0 
f01025d8:	c7 44 24 04 52 05 00 	movl   $0x552,0x4(%esp)
f01025df:	00 
f01025e0:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f01025e7:	e8 99 da ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025ec:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f01025f1:	8b 08                	mov    (%eax),%ecx
f01025f3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025f9:	89 da                	mov    %ebx,%edx
f01025fb:	2b 15 10 3f 23 f0    	sub    0xf0233f10,%edx
f0102601:	c1 fa 03             	sar    $0x3,%edx
f0102604:	c1 e2 0c             	shl    $0xc,%edx
f0102607:	39 d1                	cmp    %edx,%ecx
f0102609:	74 24                	je     f010262f <mem_init+0xd2b>
f010260b:	c7 44 24 0c 5c 62 10 	movl   $0xf010625c,0xc(%esp)
f0102612:	f0 
f0102613:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f010261a:	f0 
f010261b:	c7 44 24 04 55 05 00 	movl   $0x555,0x4(%esp)
f0102622:	00 
f0102623:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010262a:	e8 56 da ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f010262f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102635:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010263a:	74 24                	je     f0102660 <mem_init+0xd5c>
f010263c:	c7 44 24 0c 51 64 10 	movl   $0xf0106451,0xc(%esp)
f0102643:	f0 
f0102644:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f010264b:	f0 
f010264c:	c7 44 24 04 57 05 00 	movl   $0x557,0x4(%esp)
f0102653:	00 
f0102654:	c7 04 24 bb 62 10 f0 	movl   $0xf01062bb,(%esp)
f010265b:	e8 25 da ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102660:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	//cprintf("1");
	// free the pages we took
	page_free(pp0);
f0102666:	89 1c 24             	mov    %ebx,(%esp)
f0102669:	e8 72 e8 ff ff       	call   f0100ee0 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010266e:	c7 04 24 84 62 10 f0 	movl   $0xf0106284,(%esp)
f0102675:	e8 81 0a 00 00       	call   f01030fb <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);
	//cprintf("check");
	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010267a:	83 c4 5c             	add    $0x5c,%esp
f010267d:	5b                   	pop    %ebx
f010267e:	5e                   	pop    %esi
f010267f:	5f                   	pop    %edi
f0102680:	5d                   	pop    %ebp
f0102681:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102682:	89 da                	mov    %ebx,%edx
f0102684:	89 f8                	mov    %edi,%eax
f0102686:	e8 48 ec ff ff       	call   f01012d3 <check_va2pa>
f010268b:	e9 62 fa ff ff       	jmp    f01020f2 <mem_init+0x7ee>

f0102690 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102690:	55                   	push   %ebp
f0102691:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102693:	b8 68 f3 11 f0       	mov    $0xf011f368,%eax
f0102698:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010269b:	b8 23 00 00 00       	mov    $0x23,%eax
f01026a0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01026a2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01026a4:	b0 10                	mov    $0x10,%al
f01026a6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01026a8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01026aa:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01026ac:	ea b3 26 10 f0 08 00 	ljmp   $0x8,$0xf01026b3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01026b3:	b0 00                	mov    $0x0,%al
f01026b5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01026b8:	5d                   	pop    %ebp
f01026b9:	c3                   	ret    

f01026ba <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01026ba:	55                   	push   %ebp
f01026bb:	89 e5                	mov    %esp,%ebp
f01026bd:	83 ec 18             	sub    $0x18,%esp
f01026c0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01026c3:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01026c6:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01026c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01026cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01026cf:	85 c0                	test   %eax,%eax
f01026d1:	75 17                	jne    f01026ea <envid2env+0x30>
		*env_store = curenv;
f01026d3:	e8 46 2a 00 00       	call   f010511e <cpunum>
f01026d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01026db:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f01026e1:	89 06                	mov    %eax,(%esi)
f01026e3:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f01026e8:	eb 69                	jmp    f0102753 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01026ea:	89 c3                	mov    %eax,%ebx
f01026ec:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01026f2:	c1 e3 07             	shl    $0x7,%ebx
f01026f5:	03 1d 5c 32 23 f0    	add    0xf023325c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01026fb:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01026ff:	74 05                	je     f0102706 <envid2env+0x4c>
f0102701:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102704:	74 0d                	je     f0102713 <envid2env+0x59>
		*env_store = 0;
f0102706:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010270c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0102711:	eb 40                	jmp    f0102753 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102713:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102717:	74 33                	je     f010274c <envid2env+0x92>
f0102719:	e8 00 2a 00 00       	call   f010511e <cpunum>
f010271e:	6b c0 74             	imul   $0x74,%eax,%eax
f0102721:	39 98 28 40 23 f0    	cmp    %ebx,-0xfdcbfd8(%eax)
f0102727:	74 23                	je     f010274c <envid2env+0x92>
f0102729:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f010272c:	e8 ed 29 00 00       	call   f010511e <cpunum>
f0102731:	6b c0 74             	imul   $0x74,%eax,%eax
f0102734:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f010273a:	3b 78 48             	cmp    0x48(%eax),%edi
f010273d:	74 0d                	je     f010274c <envid2env+0x92>
		*env_store = 0;
f010273f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0102745:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f010274a:	eb 07                	jmp    f0102753 <envid2env+0x99>
	}

	*env_store = e;
f010274c:	89 1e                	mov    %ebx,(%esi)
f010274e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102753:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0102756:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102759:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010275c:	89 ec                	mov    %ebp,%esp
f010275e:	5d                   	pop    %ebp
f010275f:	c3                   	ret    

f0102760 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102760:	55                   	push   %ebp
f0102761:	89 e5                	mov    %esp,%ebp
f0102763:	53                   	push   %ebx
f0102764:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102767:	e8 b2 29 00 00       	call   f010511e <cpunum>
f010276c:	6b c0 74             	imul   $0x74,%eax,%eax
f010276f:	8b 98 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%ebx
f0102775:	e8 a4 29 00 00       	call   f010511e <cpunum>
f010277a:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f010277d:	8b 65 08             	mov    0x8(%ebp),%esp
f0102780:	61                   	popa   
f0102781:	07                   	pop    %es
f0102782:	1f                   	pop    %ds
f0102783:	83 c4 08             	add    $0x8,%esp
f0102786:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102787:	c7 44 24 08 62 64 10 	movl   $0xf0106462,0x8(%esp)
f010278e:	f0 
f010278f:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
f0102796:	00 
f0102797:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f010279e:	e8 e2 d8 ff ff       	call   f0100085 <_panic>

f01027a3 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01027a3:	55                   	push   %ebp
f01027a4:	89 e5                	mov    %esp,%ebp
f01027a6:	56                   	push   %esi
f01027a7:	53                   	push   %ebx
f01027a8:	83 ec 10             	sub    $0x10,%esp
f01027ab:	8b 75 08             	mov    0x8(%ebp),%esi
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	//1
	if (curenv == NULL || curenv != e){
f01027ae:	e8 6b 29 00 00       	call   f010511e <cpunum>
f01027b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01027b6:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f01027bd:	74 14                	je     f01027d3 <env_run+0x30>
f01027bf:	e8 5a 29 00 00       	call   f010511e <cpunum>
f01027c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01027c7:	39 b0 28 40 23 f0    	cmp    %esi,-0xfdcbfd8(%eax)
f01027cd:	0f 84 e1 00 00 00    	je     f01028b4 <env_run+0x111>
		cprintf("env_run:%08x\n", e->env_id);
f01027d3:	8b 46 48             	mov    0x48(%esi),%eax
f01027d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027da:	c7 04 24 79 64 10 f0 	movl   $0xf0106479,(%esp)
f01027e1:	e8 15 09 00 00       	call   f01030fb <cprintf>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01027e6:	e8 33 29 00 00       	call   f010511e <cpunum>
f01027eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01027ee:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f01027f5:	74 29                	je     f0102820 <env_run+0x7d>
f01027f7:	e8 22 29 00 00       	call   f010511e <cpunum>
f01027fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01027ff:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102805:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0102809:	75 15                	jne    f0102820 <env_run+0x7d>
			curenv->env_status = ENV_RUNNABLE;
f010280b:	e8 0e 29 00 00       	call   f010511e <cpunum>
f0102810:	6b c0 74             	imul   $0x74,%eax,%eax
f0102813:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102819:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		//may be others
		//if()
		curenv = e;
f0102820:	e8 f9 28 00 00       	call   f010511e <cpunum>
f0102825:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f010282a:	6b c0 74             	imul   $0x74,%eax,%eax
f010282d:	89 74 18 08          	mov    %esi,0x8(%eax,%ebx,1)
		cprintf("env_run:%08x\n", curenv->env_id);
f0102831:	e8 e8 28 00 00       	call   f010511e <cpunum>
f0102836:	6b c0 74             	imul   $0x74,%eax,%eax
f0102839:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010283d:	8b 40 48             	mov    0x48(%eax),%eax
f0102840:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102844:	c7 04 24 79 64 10 f0 	movl   $0xf0106479,(%esp)
f010284b:	e8 ab 08 00 00       	call   f01030fb <cprintf>
		curenv->env_status = ENV_RUNNING;
f0102850:	e8 c9 28 00 00       	call   f010511e <cpunum>
f0102855:	6b c0 74             	imul   $0x74,%eax,%eax
f0102858:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010285c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0102863:	e8 b6 28 00 00       	call   f010511e <cpunum>
f0102868:	6b c0 74             	imul   $0x74,%eax,%eax
f010286b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010286f:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0102873:	e8 a6 28 00 00       	call   f010511e <cpunum>
f0102878:	6b c0 74             	imul   $0x74,%eax,%eax
f010287b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010287f:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102882:	89 c2                	mov    %eax,%edx
f0102884:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102889:	77 20                	ja     f01028ab <env_run+0x108>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010288b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010288f:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0102896:	f0 
f0102897:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f010289e:	00 
f010289f:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f01028a6:	e8 da d7 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01028ab:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01028b1:	0f 22 da             	mov    %edx,%cr3
	}
	//2
	env_pop_tf(&(curenv->env_tf));
f01028b4:	e8 65 28 00 00       	call   f010511e <cpunum>
f01028b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01028bc:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f01028c2:	89 04 24             	mov    %eax,(%esp)
f01028c5:	e8 96 fe ff ff       	call   f0102760 <env_pop_tf>

f01028ca <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01028ca:	55                   	push   %ebp
f01028cb:	89 e5                	mov    %esp,%ebp
f01028cd:	57                   	push   %edi
f01028ce:	56                   	push   %esi
f01028cf:	53                   	push   %ebx
f01028d0:	83 ec 2c             	sub    $0x2c,%esp
f01028d3:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01028d6:	e8 43 28 00 00       	call   f010511e <cpunum>
f01028db:	6b c0 74             	imul   $0x74,%eax,%eax
f01028de:	39 b8 28 40 23 f0    	cmp    %edi,-0xfdcbfd8(%eax)
f01028e4:	75 35                	jne    f010291b <env_free+0x51>
		lcr3(PADDR(kern_pgdir));
f01028e6:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028f0:	77 20                	ja     f0102912 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028f6:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f01028fd:	f0 
f01028fe:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0102905:	00 
f0102906:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f010290d:	e8 73 d7 ff ff       	call   f0100085 <_panic>
f0102912:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102918:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010291b:	8b 5f 48             	mov    0x48(%edi),%ebx
f010291e:	e8 fb 27 00 00       	call   f010511e <cpunum>
f0102923:	6b d0 74             	imul   $0x74,%eax,%edx
f0102926:	b8 00 00 00 00       	mov    $0x0,%eax
f010292b:	83 ba 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%edx)
f0102932:	74 11                	je     f0102945 <env_free+0x7b>
f0102934:	e8 e5 27 00 00       	call   f010511e <cpunum>
f0102939:	6b c0 74             	imul   $0x74,%eax,%eax
f010293c:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102942:	8b 40 48             	mov    0x48(%eax),%eax
f0102945:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102949:	89 44 24 04          	mov    %eax,0x4(%esp)
f010294d:	c7 04 24 87 64 10 f0 	movl   $0xf0106487,(%esp)
f0102954:	e8 a2 07 00 00       	call   f01030fb <cprintf>
f0102959:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102960:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102963:	c1 e0 02             	shl    $0x2,%eax
f0102966:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102969:	8b 47 64             	mov    0x64(%edi),%eax
f010296c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010296f:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0102972:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102978:	0f 84 b8 00 00 00    	je     f0102a36 <env_free+0x16c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010297e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102984:	89 f0                	mov    %esi,%eax
f0102986:	c1 e8 0c             	shr    $0xc,%eax
f0102989:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010298c:	3b 05 08 3f 23 f0    	cmp    0xf0233f08,%eax
f0102992:	72 20                	jb     f01029b4 <env_free+0xea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102994:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102998:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f010299f:	f0 
f01029a0:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f01029a7:	00 
f01029a8:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f01029af:	e8 d1 d6 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01029b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01029b7:	c1 e2 16             	shl    $0x16,%edx
f01029ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01029bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01029c2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01029c9:	01 
f01029ca:	74 17                	je     f01029e3 <env_free+0x119>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01029cc:	89 d8                	mov    %ebx,%eax
f01029ce:	c1 e0 0c             	shl    $0xc,%eax
f01029d1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01029d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029d8:	8b 47 64             	mov    0x64(%edi),%eax
f01029db:	89 04 24             	mov    %eax,(%esp)
f01029de:	e8 ab ed ff ff       	call   f010178e <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01029e3:	83 c3 01             	add    $0x1,%ebx
f01029e6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01029ec:	75 d4                	jne    f01029c2 <env_free+0xf8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01029ee:	8b 47 64             	mov    0x64(%edi),%eax
f01029f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01029f4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01029fe:	3b 05 08 3f 23 f0    	cmp    0xf0233f08,%eax
f0102a04:	72 1c                	jb     f0102a22 <env_free+0x158>
		panic("pa2page called with invalid pa");
f0102a06:	c7 44 24 08 ac 5f 10 	movl   $0xf0105fac,0x8(%esp)
f0102a0d:	f0 
f0102a0e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0102a15:	00 
f0102a16:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0102a1d:	e8 63 d6 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0102a22:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102a25:	c1 e0 03             	shl    $0x3,%eax
f0102a28:	03 05 10 3f 23 f0    	add    0xf0233f10,%eax
f0102a2e:	89 04 24             	mov    %eax,(%esp)
f0102a31:	e8 c6 e4 ff ff       	call   f0100efc <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102a36:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102a3a:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102a41:	0f 85 19 ff ff ff    	jne    f0102960 <env_free+0x96>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102a47:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a4a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a4f:	77 20                	ja     f0102a71 <env_free+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a55:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0102a5c:	f0 
f0102a5d:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f0102a64:	00 
f0102a65:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102a6c:	e8 14 d6 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0102a71:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a78:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102a7e:	c1 e8 0c             	shr    $0xc,%eax
f0102a81:	3b 05 08 3f 23 f0    	cmp    0xf0233f08,%eax
f0102a87:	72 1c                	jb     f0102aa5 <env_free+0x1db>
		panic("pa2page called with invalid pa");
f0102a89:	c7 44 24 08 ac 5f 10 	movl   $0xf0105fac,0x8(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0102a98:	00 
f0102a99:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0102aa0:	e8 e0 d5 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0102aa5:	c1 e0 03             	shl    $0x3,%eax
f0102aa8:	03 05 10 3f 23 f0    	add    0xf0233f10,%eax
f0102aae:	89 04 24             	mov    %eax,(%esp)
f0102ab1:	e8 46 e4 ff ff       	call   f0100efc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102ab6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102abd:	a1 60 32 23 f0       	mov    0xf0233260,%eax
f0102ac2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102ac5:	89 3d 60 32 23 f0    	mov    %edi,0xf0233260
}
f0102acb:	83 c4 2c             	add    $0x2c,%esp
f0102ace:	5b                   	pop    %ebx
f0102acf:	5e                   	pop    %esi
f0102ad0:	5f                   	pop    %edi
f0102ad1:	5d                   	pop    %ebp
f0102ad2:	c3                   	ret    

f0102ad3 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0102ad3:	55                   	push   %ebp
f0102ad4:	89 e5                	mov    %esp,%ebp
f0102ad6:	53                   	push   %ebx
f0102ad7:	83 ec 14             	sub    $0x14,%esp
f0102ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0102add:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0102ae1:	75 19                	jne    f0102afc <env_destroy+0x29>
f0102ae3:	e8 36 26 00 00       	call   f010511e <cpunum>
f0102ae8:	6b c0 74             	imul   $0x74,%eax,%eax
f0102aeb:	39 98 28 40 23 f0    	cmp    %ebx,-0xfdcbfd8(%eax)
f0102af1:	74 09                	je     f0102afc <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0102af3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0102afa:	eb 2f                	jmp    f0102b2b <env_destroy+0x58>
	}

	env_free(e);
f0102afc:	89 1c 24             	mov    %ebx,(%esp)
f0102aff:	e8 c6 fd ff ff       	call   f01028ca <env_free>

	if (curenv == e) {
f0102b04:	e8 15 26 00 00       	call   f010511e <cpunum>
f0102b09:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b0c:	39 98 28 40 23 f0    	cmp    %ebx,-0xfdcbfd8(%eax)
f0102b12:	75 17                	jne    f0102b2b <env_destroy+0x58>
		curenv = NULL;
f0102b14:	e8 05 26 00 00       	call   f010511e <cpunum>
f0102b19:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b1c:	c7 80 28 40 23 f0 00 	movl   $0x0,-0xfdcbfd8(%eax)
f0102b23:	00 00 00 
		sched_yield();
f0102b26:	e8 b5 0e 00 00       	call   f01039e0 <sched_yield>
	}
}
f0102b2b:	83 c4 14             	add    $0x14,%esp
f0102b2e:	5b                   	pop    %ebx
f0102b2f:	5d                   	pop    %ebp
f0102b30:	c3                   	ret    

f0102b31 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102b31:	55                   	push   %ebp
f0102b32:	89 e5                	mov    %esp,%ebp
f0102b34:	53                   	push   %ebx
f0102b35:	83 ec 14             	sub    $0x14,%esp
	// Set up envs array
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	//cprintf("a\n");
	env_free_list = NULL;
f0102b38:	c7 05 60 32 23 f0 00 	movl   $0x0,0xf0233260
f0102b3f:	00 00 00 
f0102b42:	bb 80 ff 01 00       	mov    $0x1ff80,%ebx
	int i = NENV - 1;
	//cprintf("b\n");
	for (; i >= 0; i--){//for same order
		memset(&(envs[i].env_tf), 0, sizeof(struct Trapframe));
f0102b47:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102b4e:	00 
f0102b4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b56:	00 
f0102b57:	89 d8                	mov    %ebx,%eax
f0102b59:	03 05 5c 32 23 f0    	add    0xf023325c,%eax
f0102b5f:	89 04 24             	mov    %eax,(%esp)
f0102b62:	e8 0f 1f 00 00       	call   f0104a76 <memset>
		//cprintf("c\n");
		envs[i].env_link = env_free_list;
f0102b67:	8b 15 60 32 23 f0    	mov    0xf0233260,%edx
f0102b6d:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102b72:	89 54 18 44          	mov    %edx,0x44(%eax,%ebx,1)
		envs[i].env_id = 0;
f0102b76:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102b7b:	c7 44 18 48 00 00 00 	movl   $0x0,0x48(%eax,%ebx,1)
f0102b82:	00 
		envs[i].env_parent_id = 0;
f0102b83:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102b88:	c7 44 18 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ebx,1)
f0102b8f:	00 
		envs[i].env_type = ENV_TYPE_USER;
f0102b90:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102b95:	c7 44 18 50 00 00 00 	movl   $0x0,0x50(%eax,%ebx,1)
f0102b9c:	00 
		envs[i].env_status = ENV_FREE;
f0102b9d:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102ba2:	c7 44 18 54 00 00 00 	movl   $0x0,0x54(%eax,%ebx,1)
f0102ba9:	00 
		envs[i].env_runs = 0;	
f0102baa:	a1 5c 32 23 f0       	mov    0xf023325c,%eax
f0102baf:	c7 44 18 58 00 00 00 	movl   $0x0,0x58(%eax,%ebx,1)
f0102bb6:	00 
		env_free_list = &envs[i];
f0102bb7:	89 d8                	mov    %ebx,%eax
f0102bb9:	03 05 5c 32 23 f0    	add    0xf023325c,%eax
f0102bbf:	a3 60 32 23 f0       	mov    %eax,0xf0233260
f0102bc4:	83 c3 80             	add    $0xffffff80,%ebx
	/*stone's solution for lab3-A*/
	//cprintf("a\n");
	env_free_list = NULL;
	int i = NENV - 1;
	//cprintf("b\n");
	for (; i >= 0; i--){//for same order
f0102bc7:	83 fb 80             	cmp    $0xffffff80,%ebx
f0102bca:	0f 85 77 ff ff ff    	jne    f0102b47 <env_init+0x16>
		envs[i].env_runs = 0;	
		env_free_list = &envs[i];
	}
	//cprintf("d\n");
	// Per-CPU part of the initialization
	env_init_percpu();
f0102bd0:	e8 bb fa ff ff       	call   f0102690 <env_init_percpu>
}
f0102bd5:	83 c4 14             	add    $0x14,%esp
f0102bd8:	5b                   	pop    %ebx
f0102bd9:	5d                   	pop    %ebp
f0102bda:	c3                   	ret    

f0102bdb <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102bdb:	55                   	push   %ebp
f0102bdc:	89 e5                	mov    %esp,%ebp
f0102bde:	53                   	push   %ebx
f0102bdf:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102be2:	8b 1d 60 32 23 f0    	mov    0xf0233260,%ebx
f0102be8:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0102bed:	85 db                	test   %ebx,%ebx
f0102bef:	0f 84 8d 01 00 00    	je     f0102d82 <env_alloc+0x1a7>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102bf5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102bfc:	e8 c5 e8 ff ff       	call   f01014c6 <page_alloc>
f0102c01:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0102c06:	85 c0                	test   %eax,%eax
f0102c08:	0f 84 74 01 00 00    	je     f0102d82 <env_alloc+0x1a7>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c0e:	89 c2                	mov    %eax,%edx
f0102c10:	2b 15 10 3f 23 f0    	sub    0xf0233f10,%edx
f0102c16:	c1 fa 03             	sar    $0x3,%edx
f0102c19:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c1c:	89 d1                	mov    %edx,%ecx
f0102c1e:	c1 e9 0c             	shr    $0xc,%ecx
f0102c21:	3b 0d 08 3f 23 f0    	cmp    0xf0233f08,%ecx
f0102c27:	72 20                	jb     f0102c49 <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c29:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c2d:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0102c34:	f0 
f0102c35:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102c3c:	00 
f0102c3d:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0102c44:	e8 3c d4 ff ff       	call   f0100085 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/

	e->env_pgdir = page2kva(p);
f0102c49:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c4f:	89 53 64             	mov    %edx,0x64(%ebx)
	p->pp_ref++;
f0102c52:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	memmove(e->env_pgdir, kern_pgdir, PGSIZE); 
f0102c57:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c5e:	00 
f0102c5f:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
f0102c64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c68:	8b 43 64             	mov    0x64(%ebx),%eax
f0102c6b:	89 04 24             	mov    %eax,(%esp)
f0102c6e:	e8 62 1e 00 00       	call   f0104ad5 <memmove>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102c73:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c76:	89 c2                	mov    %eax,%edx
f0102c78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c7d:	77 20                	ja     f0102c9f <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c83:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0102c8a:	f0 
f0102c8b:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0102c92:	00 
f0102c93:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102c9a:	e8 e6 d3 ff ff       	call   f0100085 <_panic>
f0102c9f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102ca5:	83 ca 05             	or     $0x5,%edx
f0102ca8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102cae:	8b 43 48             	mov    0x48(%ebx),%eax
f0102cb1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102cb6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102cbb:	7f 05                	jg     f0102cc2 <env_alloc+0xe7>
f0102cbd:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0102cc2:	89 da                	mov    %ebx,%edx
f0102cc4:	2b 15 5c 32 23 f0    	sub    0xf023325c,%edx
f0102cca:	c1 fa 07             	sar    $0x7,%edx
f0102ccd:	09 d0                	or     %edx,%eax
f0102ccf:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cd5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102cd8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102cdf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102ce6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102ced:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102cf4:	00 
f0102cf5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102cfc:	00 
f0102cfd:	89 1c 24             	mov    %ebx,(%esp)
f0102d00:	e8 71 1d 00 00       	call   f0104a76 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102d05:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102d0b:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102d11:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102d17:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102d1e:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102d24:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102d2b:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102d32:	8b 43 44             	mov    0x44(%ebx),%eax
f0102d35:	a3 60 32 23 f0       	mov    %eax,0xf0233260
	*newenv_store = e;
f0102d3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d3d:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d3f:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102d42:	e8 d7 23 00 00       	call   f010511e <cpunum>
f0102d47:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0102d4f:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0102d56:	74 11                	je     f0102d69 <env_alloc+0x18e>
f0102d58:	e8 c1 23 00 00       	call   f010511e <cpunum>
f0102d5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d60:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0102d66:	8b 50 48             	mov    0x48(%eax),%edx
f0102d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102d6d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102d71:	c7 04 24 9d 64 10 f0 	movl   $0xf010649d,(%esp)
f0102d78:	e8 7e 03 00 00       	call   f01030fb <cprintf>
f0102d7d:	ba 00 00 00 00       	mov    $0x0,%edx
	return 0;
}
f0102d82:	89 d0                	mov    %edx,%eax
f0102d84:	83 c4 14             	add    $0x14,%esp
f0102d87:	5b                   	pop    %ebx
f0102d88:	5d                   	pop    %ebp
f0102d89:	c3                   	ret    

f0102d8a <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102d8a:	55                   	push   %ebp
f0102d8b:	89 e5                	mov    %esp,%ebp
f0102d8d:	57                   	push   %edi
f0102d8e:	56                   	push   %esi
f0102d8f:	53                   	push   %ebx
f0102d90:	83 ec 2c             	sub    $0x2c,%esp
f0102d93:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	/*stone's solution for lab3-A*/
	/*stone's solution for lab3-B(modify)*/
	char* va_start = ROUNDDOWN((char*)va, PGSIZE);
f0102d95:	89 d0                	mov    %edx,%eax
f0102d97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* va_end = ROUNDUP((char*)(va + len), PGSIZE);
f0102d9f:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102da6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page* p;
	char* pos = va_start;
	for (; pos < va_end; pos += PGSIZE){
f0102dac:	39 f8                	cmp    %edi,%eax
f0102dae:	73 77                	jae    f0102e27 <region_alloc+0x9d>
f0102db0:	89 c3                	mov    %eax,%ebx
		int r;
		if (!(p = page_alloc(0)))
f0102db2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102db9:	e8 08 e7 ff ff       	call   f01014c6 <page_alloc>
f0102dbe:	85 c0                	test   %eax,%eax
f0102dc0:	75 1c                	jne    f0102dde <region_alloc+0x54>
			panic("env_alloc: page alloc failed\n");
f0102dc2:	c7 44 24 08 b2 64 10 	movl   $0xf01064b2,0x8(%esp)
f0102dc9:	f0 
f0102dca:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f0102dd1:	00 
f0102dd2:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102dd9:	e8 a7 d2 ff ff       	call   f0100085 <_panic>
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
f0102dde:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0102de5:	00 
f0102de6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102dea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dee:	8b 46 64             	mov    0x64(%esi),%eax
f0102df1:	89 04 24             	mov    %eax,(%esp)
f0102df4:	e8 e5 e9 ff ff       	call   f01017de <page_insert>
f0102df9:	85 c0                	test   %eax,%eax
f0102dfb:	79 20                	jns    f0102e1d <region_alloc+0x93>
			panic("env_alloc: %e\n", r);
f0102dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e01:	c7 44 24 08 d0 64 10 	movl   $0xf01064d0,0x8(%esp)
f0102e08:	f0 
f0102e09:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f0102e10:	00 
f0102e11:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102e18:	e8 68 d2 ff ff       	call   f0100085 <_panic>
	/*stone's solution for lab3-B(modify)*/
	char* va_start = ROUNDDOWN((char*)va, PGSIZE);
	char* va_end = ROUNDUP((char*)(va + len), PGSIZE);
	struct Page* p;
	char* pos = va_start;
	for (; pos < va_end; pos += PGSIZE){
f0102e1d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e23:	39 df                	cmp    %ebx,%edi
f0102e25:	77 8b                	ja     f0102db2 <region_alloc+0x28>
		if (!(p = page_alloc(0)))
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
	}
	e->env_sbrk_pos = va_start;
f0102e27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e2a:	89 46 60             	mov    %eax,0x60(%esi)
}
f0102e2d:	83 c4 2c             	add    $0x2c,%esp
f0102e30:	5b                   	pop    %ebx
f0102e31:	5e                   	pop    %esi
f0102e32:	5f                   	pop    %edi
f0102e33:	5d                   	pop    %ebp
f0102e34:	c3                   	ret    

f0102e35 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102e35:	55                   	push   %ebp
f0102e36:	89 e5                	mov    %esp,%ebp
f0102e38:	57                   	push   %edi
f0102e39:	56                   	push   %esi
f0102e3a:	53                   	push   %ebx
f0102e3b:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Env *e;
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
f0102e3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102e45:	00 
f0102e46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102e49:	89 04 24             	mov    %eax,(%esp)
f0102e4c:	e8 8a fd ff ff       	call   f0102bdb <env_alloc>
f0102e51:	85 c0                	test   %eax,%eax
f0102e53:	79 20                	jns    f0102e75 <env_create+0x40>
		panic("env_alloc: %e\n", r);
f0102e55:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e59:	c7 44 24 08 d0 64 10 	movl   $0xf01064d0,0x8(%esp)
f0102e60:	f0 
f0102e61:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f0102e68:	00 
f0102e69:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102e70:	e8 10 d2 ff ff       	call   f0100085 <_panic>
	else{
		load_icode(e, binary, size);
f0102e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e78:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Proghdr *ph, *eph;
	struct Elf* elfhdr = (struct Elf*)binary; 
	lcr3(PADDR(e->env_pgdir));
f0102e7b:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e7e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e83:	77 20                	ja     f0102ea5 <env_create+0x70>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e89:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0102e90:	f0 
f0102e91:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0102e98:	00 
f0102e99:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102ea0:	e8 e0 d1 ff ff       	call   f0100085 <_panic>
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Proghdr *ph, *eph;
	struct Elf* elfhdr = (struct Elf*)binary; 
f0102ea5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102ea8:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102eae:	0f 22 d8             	mov    %eax,%cr3
	lcr3(PADDR(e->env_pgdir));
	// is this a valid ELF?
	if (elfhdr->e_magic != ELF_MAGIC)
f0102eb1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102eb7:	74 1c                	je     f0102ed5 <env_create+0xa0>
		panic("not a valid ELF\n");
f0102eb9:	c7 44 24 08 df 64 10 	movl   $0xf01064df,0x8(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0102ec8:	00 
f0102ec9:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102ed0:	e8 b0 d1 ff ff       	call   f0100085 <_panic>
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
f0102ed5:	89 fb                	mov    %edi,%ebx
f0102ed7:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f0102eda:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102ede:	c1 e6 05             	shl    $0x5,%esi
f0102ee1:	8d 34 33             	lea    (%ebx,%esi,1),%esi
	for (; ph < eph; ph++){
f0102ee4:	39 f3                	cmp    %esi,%ebx
f0102ee6:	73 55                	jae    f0102f3d <env_create+0x108>
		if (ph->p_type == ELF_PROG_LOAD){
f0102ee8:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102eeb:	75 49                	jne    f0102f36 <env_create+0x101>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0102eed:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102ef0:	8b 53 08             	mov    0x8(%ebx),%edx
f0102ef3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ef6:	e8 8f fe ff ff       	call   f0102d8a <region_alloc>
			memmove((void*)ph->p_va, (void*)(binary+ph->p_offset), ph->p_filesz);
f0102efb:	8b 43 10             	mov    0x10(%ebx),%eax
f0102efe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f02:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f05:	03 43 04             	add    0x4(%ebx),%eax
f0102f08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f0c:	8b 43 08             	mov    0x8(%ebx),%eax
f0102f0f:	89 04 24             	mov    %eax,(%esp)
f0102f12:	e8 be 1b 00 00       	call   f0104ad5 <memmove>
			memset((void*)(ph->p_va+ph->p_filesz), 0, (ph->p_memsz-ph->p_filesz));
f0102f17:	8b 43 10             	mov    0x10(%ebx),%eax
f0102f1a:	8b 53 14             	mov    0x14(%ebx),%edx
f0102f1d:	29 c2                	sub    %eax,%edx
f0102f1f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102f23:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f2a:	00 
f0102f2b:	03 43 08             	add    0x8(%ebx),%eax
f0102f2e:	89 04 24             	mov    %eax,(%esp)
f0102f31:	e8 40 1b 00 00       	call   f0104a76 <memset>
	if (elfhdr->e_magic != ELF_MAGIC)
		panic("not a valid ELF\n");
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	for (; ph < eph; ph++){
f0102f36:	83 c3 20             	add    $0x20,%ebx
f0102f39:	39 de                	cmp    %ebx,%esi
f0102f3b:	77 ab                	ja     f0102ee8 <env_create+0xb3>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
			memmove((void*)ph->p_va, (void*)(binary+ph->p_offset), ph->p_filesz);
			memset((void*)(ph->p_va+ph->p_filesz), 0, (ph->p_memsz-ph->p_filesz));
		}
	}
	e->env_tf.tf_eip = (uintptr_t)elfhdr->e_entry;
f0102f3d:	8b 47 18             	mov    0x18(%edi),%eax
f0102f40:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102f43:	89 42 30             	mov    %eax,0x30(%edx)
	lcr3(PADDR(kern_pgdir));
f0102f46:	a1 0c 3f 23 f0       	mov    0xf0233f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f4b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f50:	77 20                	ja     f0102f72 <env_create+0x13d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f52:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f56:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0102f5d:	f0 
f0102f5e:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0102f65:	00 
f0102f66:	c7 04 24 6e 64 10 f0 	movl   $0xf010646e,(%esp)
f0102f6d:	e8 13 d1 ff ff       	call   f0100085 <_panic>
f0102f72:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102f78:	0f 22 d8             	mov    %eax,%cr3
	
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f0102f7b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102f80:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102f85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f88:	e8 fd fd ff ff       	call   f0102d8a <region_alloc>
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
		panic("env_alloc: %e\n", r);
	else{
		load_icode(e, binary, size);
		e->env_type = type;
f0102f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f90:	8b 55 10             	mov    0x10(%ebp),%edx
f0102f93:	89 50 50             	mov    %edx,0x50(%eax)
	}
}
f0102f96:	83 c4 3c             	add    $0x3c,%esp
f0102f99:	5b                   	pop    %ebx
f0102f9a:	5e                   	pop    %esi
f0102f9b:	5f                   	pop    %edi
f0102f9c:	5d                   	pop    %ebp
f0102f9d:	c3                   	ret    
	...

f0102fa0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102fa0:	55                   	push   %ebp
f0102fa1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fa3:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fa8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fab:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102fac:	b2 71                	mov    $0x71,%dl
f0102fae:	ec                   	in     (%dx),%al
f0102faf:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0102fb2:	5d                   	pop    %ebp
f0102fb3:	c3                   	ret    

f0102fb4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102fb4:	55                   	push   %ebp
f0102fb5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fb7:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fbc:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fbf:	ee                   	out    %al,(%dx)
f0102fc0:	b2 71                	mov    $0x71,%dl
f0102fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fc5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102fc6:	5d                   	pop    %ebp
f0102fc7:	c3                   	ret    

f0102fc8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0102fc8:	55                   	push   %ebp
f0102fc9:	89 e5                	mov    %esp,%ebp
f0102fcb:	56                   	push   %esi
f0102fcc:	53                   	push   %ebx
f0102fcd:	83 ec 10             	sub    $0x10,%esp
f0102fd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fd3:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0102fd5:	66 a3 70 f3 11 f0    	mov    %ax,0xf011f370
	if (!didinit)
f0102fdb:	83 3d 64 32 23 f0 00 	cmpl   $0x0,0xf0233264
f0102fe2:	74 4e                	je     f0103032 <irq_setmask_8259A+0x6a>
f0102fe4:	ba 21 00 00 00       	mov    $0x21,%edx
f0102fe9:	ee                   	out    %al,(%dx)
f0102fea:	89 f0                	mov    %esi,%eax
f0102fec:	66 c1 e8 08          	shr    $0x8,%ax
f0102ff0:	b2 a1                	mov    $0xa1,%dl
f0102ff2:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0102ff3:	c7 04 24 f0 64 10 f0 	movl   $0xf01064f0,(%esp)
f0102ffa:	e8 fc 00 00 00       	call   f01030fb <cprintf>
f0102fff:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0103004:	0f b7 f6             	movzwl %si,%esi
f0103007:	f7 d6                	not    %esi
f0103009:	0f a3 de             	bt     %ebx,%esi
f010300c:	73 10                	jae    f010301e <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010300e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103012:	c7 04 24 e0 69 10 f0 	movl   $0xf01069e0,(%esp)
f0103019:	e8 dd 00 00 00       	call   f01030fb <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010301e:	83 c3 01             	add    $0x1,%ebx
f0103021:	83 fb 10             	cmp    $0x10,%ebx
f0103024:	75 e3                	jne    f0103009 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103026:	c7 04 24 68 59 10 f0 	movl   $0xf0105968,(%esp)
f010302d:	e8 c9 00 00 00       	call   f01030fb <cprintf>
}
f0103032:	83 c4 10             	add    $0x10,%esp
f0103035:	5b                   	pop    %ebx
f0103036:	5e                   	pop    %esi
f0103037:	5d                   	pop    %ebp
f0103038:	c3                   	ret    

f0103039 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103039:	55                   	push   %ebp
f010303a:	89 e5                	mov    %esp,%ebp
f010303c:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010303f:	c7 05 64 32 23 f0 01 	movl   $0x1,0xf0233264
f0103046:	00 00 00 
f0103049:	ba 21 00 00 00       	mov    $0x21,%edx
f010304e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103053:	ee                   	out    %al,(%dx)
f0103054:	b2 a1                	mov    $0xa1,%dl
f0103056:	ee                   	out    %al,(%dx)
f0103057:	b2 20                	mov    $0x20,%dl
f0103059:	b8 11 00 00 00       	mov    $0x11,%eax
f010305e:	ee                   	out    %al,(%dx)
f010305f:	b2 21                	mov    $0x21,%dl
f0103061:	b8 20 00 00 00       	mov    $0x20,%eax
f0103066:	ee                   	out    %al,(%dx)
f0103067:	b8 04 00 00 00       	mov    $0x4,%eax
f010306c:	ee                   	out    %al,(%dx)
f010306d:	b8 03 00 00 00       	mov    $0x3,%eax
f0103072:	ee                   	out    %al,(%dx)
f0103073:	b2 a0                	mov    $0xa0,%dl
f0103075:	b8 11 00 00 00       	mov    $0x11,%eax
f010307a:	ee                   	out    %al,(%dx)
f010307b:	b2 a1                	mov    $0xa1,%dl
f010307d:	b8 28 00 00 00       	mov    $0x28,%eax
f0103082:	ee                   	out    %al,(%dx)
f0103083:	b8 02 00 00 00       	mov    $0x2,%eax
f0103088:	ee                   	out    %al,(%dx)
f0103089:	b8 01 00 00 00       	mov    $0x1,%eax
f010308e:	ee                   	out    %al,(%dx)
f010308f:	b2 20                	mov    $0x20,%dl
f0103091:	b8 68 00 00 00       	mov    $0x68,%eax
f0103096:	ee                   	out    %al,(%dx)
f0103097:	b8 0a 00 00 00       	mov    $0xa,%eax
f010309c:	ee                   	out    %al,(%dx)
f010309d:	b2 a0                	mov    $0xa0,%dl
f010309f:	b8 68 00 00 00       	mov    $0x68,%eax
f01030a4:	ee                   	out    %al,(%dx)
f01030a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01030aa:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01030ab:	0f b7 05 70 f3 11 f0 	movzwl 0xf011f370,%eax
f01030b2:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01030b6:	74 0b                	je     f01030c3 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01030b8:	0f b7 c0             	movzwl %ax,%eax
f01030bb:	89 04 24             	mov    %eax,(%esp)
f01030be:	e8 05 ff ff ff       	call   f0102fc8 <irq_setmask_8259A>
}
f01030c3:	c9                   	leave  
f01030c4:	c3                   	ret    
f01030c5:	00 00                	add    %al,(%eax)
	...

f01030c8 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01030c8:	55                   	push   %ebp
f01030c9:	89 e5                	mov    %esp,%ebp
f01030cb:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01030df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030ea:	c7 04 24 15 31 10 f0 	movl   $0xf0103115,(%esp)
f01030f1:	e8 e7 11 00 00       	call   f01042dd <vprintfmt>
	return cnt;
}
f01030f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030f9:	c9                   	leave  
f01030fa:	c3                   	ret    

f01030fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01030fb:	55                   	push   %ebp
f01030fc:	89 e5                	mov    %esp,%ebp
f01030fe:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0103101:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103104:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103108:	8b 45 08             	mov    0x8(%ebp),%eax
f010310b:	89 04 24             	mov    %eax,(%esp)
f010310e:	e8 b5 ff ff ff       	call   f01030c8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103113:	c9                   	leave  
f0103114:	c3                   	ret    

f0103115 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103115:	55                   	push   %ebp
f0103116:	89 e5                	mov    %esp,%ebp
f0103118:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010311b:	8b 45 08             	mov    0x8(%ebp),%eax
f010311e:	89 04 24             	mov    %eax,(%esp)
f0103121:	e8 84 d5 ff ff       	call   f01006aa <cputchar>
	*cnt++;
}
f0103126:	c9                   	leave  
f0103127:	c3                   	ret    
	...

f0103130 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103130:	55                   	push   %ebp
f0103131:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103133:	c7 05 84 3a 23 f0 00 	movl   $0xefc00000,0xf0233a84
f010313a:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010313d:	66 c7 05 88 3a 23 f0 	movw   $0x10,0xf0233a88
f0103144:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103146:	66 c7 05 28 f3 11 f0 	movw   $0x68,0xf011f328
f010314d:	68 00 
f010314f:	b8 80 3a 23 f0       	mov    $0xf0233a80,%eax
f0103154:	66 a3 2a f3 11 f0    	mov    %ax,0xf011f32a
f010315a:	89 c2                	mov    %eax,%edx
f010315c:	c1 ea 10             	shr    $0x10,%edx
f010315f:	88 15 2c f3 11 f0    	mov    %dl,0xf011f32c
f0103165:	c6 05 2e f3 11 f0 40 	movb   $0x40,0xf011f32e
f010316c:	c1 e8 18             	shr    $0x18,%eax
f010316f:	a2 2f f3 11 f0       	mov    %al,0xf011f32f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103174:	c6 05 2d f3 11 f0 89 	movb   $0x89,0xf011f32d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010317b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103180:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103183:	b8 74 f3 11 f0       	mov    $0xf011f374,%eax
f0103188:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010318b:	5d                   	pop    %ebp
f010318c:	c3                   	ret    

f010318d <trap_init>:
/*stone's solution for lab3-B*/
void sysenter_handler();

void
trap_init(void)
{
f010318d:	55                   	push   %ebp
f010318e:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t0, 0);
f0103190:	b8 44 39 10 f0       	mov    $0xf0103944,%eax
f0103195:	66 a3 80 32 23 f0    	mov    %ax,0xf0233280
f010319b:	66 c7 05 82 32 23 f0 	movw   $0x8,0xf0233282
f01031a2:	08 00 
f01031a4:	c6 05 84 32 23 f0 00 	movb   $0x0,0xf0233284
f01031ab:	c6 05 85 32 23 f0 8e 	movb   $0x8e,0xf0233285
f01031b2:	c1 e8 10             	shr    $0x10,%eax
f01031b5:	66 a3 86 32 23 f0    	mov    %ax,0xf0233286
	SETGATE(idt[T_DEBUG], 0, GD_KT, t1, 0);
f01031bb:	b8 4a 39 10 f0       	mov    $0xf010394a,%eax
f01031c0:	66 a3 88 32 23 f0    	mov    %ax,0xf0233288
f01031c6:	66 c7 05 8a 32 23 f0 	movw   $0x8,0xf023328a
f01031cd:	08 00 
f01031cf:	c6 05 8c 32 23 f0 00 	movb   $0x0,0xf023328c
f01031d6:	c6 05 8d 32 23 f0 8e 	movb   $0x8e,0xf023328d
f01031dd:	c1 e8 10             	shr    $0x10,%eax
f01031e0:	66 a3 8e 32 23 f0    	mov    %ax,0xf023328e
	SETGATE(idt[T_NMI], 0, GD_KT, t2, 0);
f01031e6:	b8 50 39 10 f0       	mov    $0xf0103950,%eax
f01031eb:	66 a3 90 32 23 f0    	mov    %ax,0xf0233290
f01031f1:	66 c7 05 92 32 23 f0 	movw   $0x8,0xf0233292
f01031f8:	08 00 
f01031fa:	c6 05 94 32 23 f0 00 	movb   $0x0,0xf0233294
f0103201:	c6 05 95 32 23 f0 8e 	movb   $0x8e,0xf0233295
f0103208:	c1 e8 10             	shr    $0x10,%eax
f010320b:	66 a3 96 32 23 f0    	mov    %ax,0xf0233296
	/*stone's solution for lab3-B(modify)*/
	SETGATE(idt[T_BRKPT], 0, GD_KT, t3, 3);
f0103211:	b8 56 39 10 f0       	mov    $0xf0103956,%eax
f0103216:	66 a3 98 32 23 f0    	mov    %ax,0xf0233298
f010321c:	66 c7 05 9a 32 23 f0 	movw   $0x8,0xf023329a
f0103223:	08 00 
f0103225:	c6 05 9c 32 23 f0 00 	movb   $0x0,0xf023329c
f010322c:	c6 05 9d 32 23 f0 ee 	movb   $0xee,0xf023329d
f0103233:	c1 e8 10             	shr    $0x10,%eax
f0103236:	66 a3 9e 32 23 f0    	mov    %ax,0xf023329e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t4, 3);
f010323c:	b8 5c 39 10 f0       	mov    $0xf010395c,%eax
f0103241:	66 a3 a0 32 23 f0    	mov    %ax,0xf02332a0
f0103247:	66 c7 05 a2 32 23 f0 	movw   $0x8,0xf02332a2
f010324e:	08 00 
f0103250:	c6 05 a4 32 23 f0 00 	movb   $0x0,0xf02332a4
f0103257:	c6 05 a5 32 23 f0 ee 	movb   $0xee,0xf02332a5
f010325e:	c1 e8 10             	shr    $0x10,%eax
f0103261:	66 a3 a6 32 23 f0    	mov    %ax,0xf02332a6
	SETGATE(idt[T_BOUND], 0, GD_KT, t5, 0);
f0103267:	b8 62 39 10 f0       	mov    $0xf0103962,%eax
f010326c:	66 a3 a8 32 23 f0    	mov    %ax,0xf02332a8
f0103272:	66 c7 05 aa 32 23 f0 	movw   $0x8,0xf02332aa
f0103279:	08 00 
f010327b:	c6 05 ac 32 23 f0 00 	movb   $0x0,0xf02332ac
f0103282:	c6 05 ad 32 23 f0 8e 	movb   $0x8e,0xf02332ad
f0103289:	c1 e8 10             	shr    $0x10,%eax
f010328c:	66 a3 ae 32 23 f0    	mov    %ax,0xf02332ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, t6, 0);
f0103292:	b8 68 39 10 f0       	mov    $0xf0103968,%eax
f0103297:	66 a3 b0 32 23 f0    	mov    %ax,0xf02332b0
f010329d:	66 c7 05 b2 32 23 f0 	movw   $0x8,0xf02332b2
f01032a4:	08 00 
f01032a6:	c6 05 b4 32 23 f0 00 	movb   $0x0,0xf02332b4
f01032ad:	c6 05 b5 32 23 f0 8e 	movb   $0x8e,0xf02332b5
f01032b4:	c1 e8 10             	shr    $0x10,%eax
f01032b7:	66 a3 b6 32 23 f0    	mov    %ax,0xf02332b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, t7, 0);
f01032bd:	b8 6e 39 10 f0       	mov    $0xf010396e,%eax
f01032c2:	66 a3 b8 32 23 f0    	mov    %ax,0xf02332b8
f01032c8:	66 c7 05 ba 32 23 f0 	movw   $0x8,0xf02332ba
f01032cf:	08 00 
f01032d1:	c6 05 bc 32 23 f0 00 	movb   $0x0,0xf02332bc
f01032d8:	c6 05 bd 32 23 f0 8e 	movb   $0x8e,0xf02332bd
f01032df:	c1 e8 10             	shr    $0x10,%eax
f01032e2:	66 a3 be 32 23 f0    	mov    %ax,0xf02332be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t8, 0);
f01032e8:	b8 74 39 10 f0       	mov    $0xf0103974,%eax
f01032ed:	66 a3 c0 32 23 f0    	mov    %ax,0xf02332c0
f01032f3:	66 c7 05 c2 32 23 f0 	movw   $0x8,0xf02332c2
f01032fa:	08 00 
f01032fc:	c6 05 c4 32 23 f0 00 	movb   $0x0,0xf02332c4
f0103303:	c6 05 c5 32 23 f0 8e 	movb   $0x8e,0xf02332c5
f010330a:	c1 e8 10             	shr    $0x10,%eax
f010330d:	66 a3 c6 32 23 f0    	mov    %ax,0xf02332c6
	SETGATE(idt[T_TSS], 0, GD_KT, t10, 0);
f0103313:	b8 78 39 10 f0       	mov    $0xf0103978,%eax
f0103318:	66 a3 d0 32 23 f0    	mov    %ax,0xf02332d0
f010331e:	66 c7 05 d2 32 23 f0 	movw   $0x8,0xf02332d2
f0103325:	08 00 
f0103327:	c6 05 d4 32 23 f0 00 	movb   $0x0,0xf02332d4
f010332e:	c6 05 d5 32 23 f0 8e 	movb   $0x8e,0xf02332d5
f0103335:	c1 e8 10             	shr    $0x10,%eax
f0103338:	66 a3 d6 32 23 f0    	mov    %ax,0xf02332d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t11, 0);
f010333e:	b8 7c 39 10 f0       	mov    $0xf010397c,%eax
f0103343:	66 a3 d8 32 23 f0    	mov    %ax,0xf02332d8
f0103349:	66 c7 05 da 32 23 f0 	movw   $0x8,0xf02332da
f0103350:	08 00 
f0103352:	c6 05 dc 32 23 f0 00 	movb   $0x0,0xf02332dc
f0103359:	c6 05 dd 32 23 f0 8e 	movb   $0x8e,0xf02332dd
f0103360:	c1 e8 10             	shr    $0x10,%eax
f0103363:	66 a3 de 32 23 f0    	mov    %ax,0xf02332de
	SETGATE(idt[T_STACK], 0, GD_KT, t12, 0);
f0103369:	b8 80 39 10 f0       	mov    $0xf0103980,%eax
f010336e:	66 a3 e0 32 23 f0    	mov    %ax,0xf02332e0
f0103374:	66 c7 05 e2 32 23 f0 	movw   $0x8,0xf02332e2
f010337b:	08 00 
f010337d:	c6 05 e4 32 23 f0 00 	movb   $0x0,0xf02332e4
f0103384:	c6 05 e5 32 23 f0 8e 	movb   $0x8e,0xf02332e5
f010338b:	c1 e8 10             	shr    $0x10,%eax
f010338e:	66 a3 e6 32 23 f0    	mov    %ax,0xf02332e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t13, 0);
f0103394:	b8 84 39 10 f0       	mov    $0xf0103984,%eax
f0103399:	66 a3 e8 32 23 f0    	mov    %ax,0xf02332e8
f010339f:	66 c7 05 ea 32 23 f0 	movw   $0x8,0xf02332ea
f01033a6:	08 00 
f01033a8:	c6 05 ec 32 23 f0 00 	movb   $0x0,0xf02332ec
f01033af:	c6 05 ed 32 23 f0 8e 	movb   $0x8e,0xf02332ed
f01033b6:	c1 e8 10             	shr    $0x10,%eax
f01033b9:	66 a3 ee 32 23 f0    	mov    %ax,0xf02332ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, t14, 0);
f01033bf:	b8 88 39 10 f0       	mov    $0xf0103988,%eax
f01033c4:	66 a3 f0 32 23 f0    	mov    %ax,0xf02332f0
f01033ca:	66 c7 05 f2 32 23 f0 	movw   $0x8,0xf02332f2
f01033d1:	08 00 
f01033d3:	c6 05 f4 32 23 f0 00 	movb   $0x0,0xf02332f4
f01033da:	c6 05 f5 32 23 f0 8e 	movb   $0x8e,0xf02332f5
f01033e1:	c1 e8 10             	shr    $0x10,%eax
f01033e4:	66 a3 f6 32 23 f0    	mov    %ax,0xf02332f6
	SETGATE(idt[T_FPERR], 0, GD_KT, t16, 0);
f01033ea:	b8 8c 39 10 f0       	mov    $0xf010398c,%eax
f01033ef:	66 a3 00 33 23 f0    	mov    %ax,0xf0233300
f01033f5:	66 c7 05 02 33 23 f0 	movw   $0x8,0xf0233302
f01033fc:	08 00 
f01033fe:	c6 05 04 33 23 f0 00 	movb   $0x0,0xf0233304
f0103405:	c6 05 05 33 23 f0 8e 	movb   $0x8e,0xf0233305
f010340c:	c1 e8 10             	shr    $0x10,%eax
f010340f:	66 a3 06 33 23 f0    	mov    %ax,0xf0233306
	SETGATE(idt[T_ALIGN], 0, GD_KT, t17, 0);
f0103415:	b8 92 39 10 f0       	mov    $0xf0103992,%eax
f010341a:	66 a3 08 33 23 f0    	mov    %ax,0xf0233308
f0103420:	66 c7 05 0a 33 23 f0 	movw   $0x8,0xf023330a
f0103427:	08 00 
f0103429:	c6 05 0c 33 23 f0 00 	movb   $0x0,0xf023330c
f0103430:	c6 05 0d 33 23 f0 8e 	movb   $0x8e,0xf023330d
f0103437:	c1 e8 10             	shr    $0x10,%eax
f010343a:	66 a3 0e 33 23 f0    	mov    %ax,0xf023330e
	SETGATE(idt[T_MCHK], 0, GD_KT, t18, 0);
f0103440:	b8 96 39 10 f0       	mov    $0xf0103996,%eax
f0103445:	66 a3 10 33 23 f0    	mov    %ax,0xf0233310
f010344b:	66 c7 05 12 33 23 f0 	movw   $0x8,0xf0233312
f0103452:	08 00 
f0103454:	c6 05 14 33 23 f0 00 	movb   $0x0,0xf0233314
f010345b:	c6 05 15 33 23 f0 8e 	movb   $0x8e,0xf0233315
f0103462:	c1 e8 10             	shr    $0x10,%eax
f0103465:	66 a3 16 33 23 f0    	mov    %ax,0xf0233316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t19, 0);
f010346b:	b8 9c 39 10 f0       	mov    $0xf010399c,%eax
f0103470:	66 a3 18 33 23 f0    	mov    %ax,0xf0233318
f0103476:	66 c7 05 1a 33 23 f0 	movw   $0x8,0xf023331a
f010347d:	08 00 
f010347f:	c6 05 1c 33 23 f0 00 	movb   $0x0,0xf023331c
f0103486:	c6 05 1d 33 23 f0 8e 	movb   $0x8e,0xf023331d
f010348d:	c1 e8 10             	shr    $0x10,%eax
f0103490:	66 a3 1e 33 23 f0    	mov    %ax,0xf023331e
	/*stone's solution for lab3-B*/
	wrmsr(0x174, GD_KT, 0);
f0103496:	ba 00 00 00 00       	mov    $0x0,%edx
f010349b:	b8 08 00 00 00       	mov    $0x8,%eax
f01034a0:	b9 74 01 00 00       	mov    $0x174,%ecx
f01034a5:	0f 30                	wrmsr  
   	wrmsr(0x175, KSTACKTOP, 0);
f01034a7:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f01034ac:	b1 75                	mov    $0x75,%cl
f01034ae:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f01034b0:	b8 a2 39 10 f0       	mov    $0xf01039a2,%eax
f01034b5:	b1 76                	mov    $0x76,%cl
f01034b7:	0f 30                	wrmsr  
	// Per-CPU setup 
	trap_init_percpu();
f01034b9:	e8 72 fc ff ff       	call   f0103130 <trap_init_percpu>
}
f01034be:	5d                   	pop    %ebp
f01034bf:	c3                   	ret    

f01034c0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01034c0:	55                   	push   %ebp
f01034c1:	89 e5                	mov    %esp,%ebp
f01034c3:	53                   	push   %ebx
f01034c4:	83 ec 14             	sub    $0x14,%esp
f01034c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01034ca:	8b 03                	mov    (%ebx),%eax
f01034cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034d0:	c7 04 24 04 65 10 f0 	movl   $0xf0106504,(%esp)
f01034d7:	e8 1f fc ff ff       	call   f01030fb <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01034dc:	8b 43 04             	mov    0x4(%ebx),%eax
f01034df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e3:	c7 04 24 13 65 10 f0 	movl   $0xf0106513,(%esp)
f01034ea:	e8 0c fc ff ff       	call   f01030fb <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01034ef:	8b 43 08             	mov    0x8(%ebx),%eax
f01034f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034f6:	c7 04 24 22 65 10 f0 	movl   $0xf0106522,(%esp)
f01034fd:	e8 f9 fb ff ff       	call   f01030fb <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103502:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103505:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103509:	c7 04 24 31 65 10 f0 	movl   $0xf0106531,(%esp)
f0103510:	e8 e6 fb ff ff       	call   f01030fb <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103515:	8b 43 10             	mov    0x10(%ebx),%eax
f0103518:	89 44 24 04          	mov    %eax,0x4(%esp)
f010351c:	c7 04 24 40 65 10 f0 	movl   $0xf0106540,(%esp)
f0103523:	e8 d3 fb ff ff       	call   f01030fb <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103528:	8b 43 14             	mov    0x14(%ebx),%eax
f010352b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010352f:	c7 04 24 4f 65 10 f0 	movl   $0xf010654f,(%esp)
f0103536:	e8 c0 fb ff ff       	call   f01030fb <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010353b:	8b 43 18             	mov    0x18(%ebx),%eax
f010353e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103542:	c7 04 24 5e 65 10 f0 	movl   $0xf010655e,(%esp)
f0103549:	e8 ad fb ff ff       	call   f01030fb <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010354e:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103551:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103555:	c7 04 24 6d 65 10 f0 	movl   $0xf010656d,(%esp)
f010355c:	e8 9a fb ff ff       	call   f01030fb <cprintf>
}
f0103561:	83 c4 14             	add    $0x14,%esp
f0103564:	5b                   	pop    %ebx
f0103565:	5d                   	pop    %ebp
f0103566:	c3                   	ret    

f0103567 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103567:	55                   	push   %ebp
f0103568:	89 e5                	mov    %esp,%ebp
f010356a:	56                   	push   %esi
f010356b:	53                   	push   %ebx
f010356c:	83 ec 10             	sub    $0x10,%esp
f010356f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103572:	e8 a7 1b 00 00       	call   f010511e <cpunum>
f0103577:	89 44 24 08          	mov    %eax,0x8(%esp)
f010357b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010357f:	c7 04 24 7c 65 10 f0 	movl   $0xf010657c,(%esp)
f0103586:	e8 70 fb ff ff       	call   f01030fb <cprintf>
	print_regs(&tf->tf_regs);
f010358b:	89 1c 24             	mov    %ebx,(%esp)
f010358e:	e8 2d ff ff ff       	call   f01034c0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103593:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103597:	89 44 24 04          	mov    %eax,0x4(%esp)
f010359b:	c7 04 24 9a 65 10 f0 	movl   $0xf010659a,(%esp)
f01035a2:	e8 54 fb ff ff       	call   f01030fb <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01035a7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01035ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035af:	c7 04 24 ad 65 10 f0 	movl   $0xf01065ad,(%esp)
f01035b6:	e8 40 fb ff ff       	call   f01030fb <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01035bb:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01035be:	83 f8 13             	cmp    $0x13,%eax
f01035c1:	77 09                	ja     f01035cc <print_trapframe+0x65>
		return excnames[trapno];
f01035c3:	8b 14 85 a0 68 10 f0 	mov    -0xfef9760(,%eax,4),%edx
f01035ca:	eb 1c                	jmp    f01035e8 <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f01035cc:	ba c0 65 10 f0       	mov    $0xf01065c0,%edx
f01035d1:	83 f8 30             	cmp    $0x30,%eax
f01035d4:	74 12                	je     f01035e8 <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01035d6:	8d 48 e0             	lea    -0x20(%eax),%ecx
f01035d9:	ba db 65 10 f0       	mov    $0xf01065db,%edx
f01035de:	83 f9 0f             	cmp    $0xf,%ecx
f01035e1:	76 05                	jbe    f01035e8 <print_trapframe+0x81>
f01035e3:	ba cc 65 10 f0       	mov    $0xf01065cc,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01035e8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01035ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035f0:	c7 04 24 ee 65 10 f0 	movl   $0xf01065ee,(%esp)
f01035f7:	e8 ff fa ff ff       	call   f01030fb <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01035fc:	3b 1d e8 3a 23 f0    	cmp    0xf0233ae8,%ebx
f0103602:	75 19                	jne    f010361d <print_trapframe+0xb6>
f0103604:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103608:	75 13                	jne    f010361d <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010360a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010360d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103611:	c7 04 24 00 66 10 f0 	movl   $0xf0106600,(%esp)
f0103618:	e8 de fa ff ff       	call   f01030fb <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010361d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103620:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103624:	c7 04 24 0f 66 10 f0 	movl   $0xf010660f,(%esp)
f010362b:	e8 cb fa ff ff       	call   f01030fb <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103630:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103634:	75 47                	jne    f010367d <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103636:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103639:	be 29 66 10 f0       	mov    $0xf0106629,%esi
f010363e:	a8 01                	test   $0x1,%al
f0103640:	75 05                	jne    f0103647 <print_trapframe+0xe0>
f0103642:	be 1d 66 10 f0       	mov    $0xf010661d,%esi
f0103647:	b9 39 66 10 f0       	mov    $0xf0106639,%ecx
f010364c:	a8 02                	test   $0x2,%al
f010364e:	75 05                	jne    f0103655 <print_trapframe+0xee>
f0103650:	b9 34 66 10 f0       	mov    $0xf0106634,%ecx
f0103655:	ba 3f 66 10 f0       	mov    $0xf010663f,%edx
f010365a:	a8 04                	test   $0x4,%al
f010365c:	75 05                	jne    f0103663 <print_trapframe+0xfc>
f010365e:	ba 16 67 10 f0       	mov    $0xf0106716,%edx
f0103663:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103667:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010366b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010366f:	c7 04 24 44 66 10 f0 	movl   $0xf0106644,(%esp)
f0103676:	e8 80 fa ff ff       	call   f01030fb <cprintf>
f010367b:	eb 0c                	jmp    f0103689 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010367d:	c7 04 24 68 59 10 f0 	movl   $0xf0105968,(%esp)
f0103684:	e8 72 fa ff ff       	call   f01030fb <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103689:	8b 43 30             	mov    0x30(%ebx),%eax
f010368c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103690:	c7 04 24 53 66 10 f0 	movl   $0xf0106653,(%esp)
f0103697:	e8 5f fa ff ff       	call   f01030fb <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010369c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01036a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036a4:	c7 04 24 62 66 10 f0 	movl   $0xf0106662,(%esp)
f01036ab:	e8 4b fa ff ff       	call   f01030fb <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01036b0:	8b 43 38             	mov    0x38(%ebx),%eax
f01036b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036b7:	c7 04 24 75 66 10 f0 	movl   $0xf0106675,(%esp)
f01036be:	e8 38 fa ff ff       	call   f01030fb <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01036c3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01036c7:	74 27                	je     f01036f0 <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01036c9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01036cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036d0:	c7 04 24 84 66 10 f0 	movl   $0xf0106684,(%esp)
f01036d7:	e8 1f fa ff ff       	call   f01030fb <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01036dc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01036e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e4:	c7 04 24 93 66 10 f0 	movl   $0xf0106693,(%esp)
f01036eb:	e8 0b fa ff ff       	call   f01030fb <cprintf>
	}
}
f01036f0:	83 c4 10             	add    $0x10,%esp
f01036f3:	5b                   	pop    %ebx
f01036f4:	5e                   	pop    %esi
f01036f5:	5d                   	pop    %ebp
f01036f6:	c3                   	ret    

f01036f7 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01036f7:	55                   	push   %ebp
f01036f8:	89 e5                	mov    %esp,%ebp
f01036fa:	83 ec 28             	sub    $0x28,%esp
f01036fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103700:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103703:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103706:	8b 75 08             	mov    0x8(%ebp),%esi
f0103709:	0f 20 d3             	mov    %cr2,%ebx

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	if (tf->tf_cs == GD_KT)
f010370c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103711:	75 1c                	jne    f010372f <page_fault_handler+0x38>
		panic("Page Fault in kernel");
f0103713:	c7 44 24 08 a6 66 10 	movl   $0xf01066a6,0x8(%esp)
f010371a:	f0 
f010371b:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0103722:	00 
f0103723:	c7 04 24 bb 66 10 f0 	movl   $0xf01066bb,(%esp)
f010372a:	e8 56 c9 ff ff       	call   f0100085 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010372f:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103732:	e8 e7 19 00 00       	call   f010511e <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103737:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010373b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010373f:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f0103744:	6b c0 74             	imul   $0x74,%eax,%eax
f0103747:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010374b:	8b 40 48             	mov    0x48(%eax),%eax
f010374e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103752:	c7 04 24 60 68 10 f0 	movl   $0xf0106860,(%esp)
f0103759:	e8 9d f9 ff ff       	call   f01030fb <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010375e:	89 34 24             	mov    %esi,(%esp)
f0103761:	e8 01 fe ff ff       	call   f0103567 <print_trapframe>
	env_destroy(curenv);
f0103766:	e8 b3 19 00 00       	call   f010511e <cpunum>
f010376b:	6b c0 74             	imul   $0x74,%eax,%eax
f010376e:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103772:	89 04 24             	mov    %eax,(%esp)
f0103775:	e8 59 f3 ff ff       	call   f0102ad3 <env_destroy>
}
f010377a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010377d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103780:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103783:	89 ec                	mov    %ebp,%esp
f0103785:	5d                   	pop    %ebp
f0103786:	c3                   	ret    

f0103787 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103787:	55                   	push   %ebp
f0103788:	89 e5                	mov    %esp,%ebp
f010378a:	83 ec 28             	sub    $0x28,%esp
f010378d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103790:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103793:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103796:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103799:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010379a:	83 3d 00 3f 23 f0 00 	cmpl   $0x0,0xf0233f00
f01037a1:	74 01                	je     f01037a4 <trap+0x1d>
		asm volatile("hlt");
f01037a3:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01037a4:	9c                   	pushf  
f01037a5:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01037a6:	f6 c4 02             	test   $0x2,%ah
f01037a9:	74 24                	je     f01037cf <trap+0x48>
f01037ab:	c7 44 24 0c c7 66 10 	movl   $0xf01066c7,0xc(%esp)
f01037b2:	f0 
f01037b3:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01037ba:	f0 
f01037bb:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
f01037c2:	00 
f01037c3:	c7 04 24 bb 66 10 f0 	movl   $0xf01066bb,(%esp)
f01037ca:	e8 b6 c8 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01037cf:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01037d3:	83 e0 03             	and    $0x3,%eax
f01037d6:	83 f8 03             	cmp    $0x3,%eax
f01037d9:	0f 85 9d 00 00 00    	jne    f010387c <trap+0xf5>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01037df:	e8 3a 19 00 00       	call   f010511e <cpunum>
f01037e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e7:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f01037ee:	75 24                	jne    f0103814 <trap+0x8d>
f01037f0:	c7 44 24 0c e0 66 10 	movl   $0xf01066e0,0xc(%esp)
f01037f7:	f0 
f01037f8:	c7 44 24 08 d3 62 10 	movl   $0xf01062d3,0x8(%esp)
f01037ff:	f0 
f0103800:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f0103807:	00 
f0103808:	c7 04 24 bb 66 10 f0 	movl   $0xf01066bb,(%esp)
f010380f:	e8 71 c8 ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103814:	e8 05 19 00 00       	call   f010511e <cpunum>
f0103819:	6b c0 74             	imul   $0x74,%eax,%eax
f010381c:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103822:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103826:	75 2e                	jne    f0103856 <trap+0xcf>
			env_free(curenv);
f0103828:	e8 f1 18 00 00       	call   f010511e <cpunum>
f010382d:	be 20 40 23 f0       	mov    $0xf0234020,%esi
f0103832:	6b c0 74             	imul   $0x74,%eax,%eax
f0103835:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0103839:	89 04 24             	mov    %eax,(%esp)
f010383c:	e8 89 f0 ff ff       	call   f01028ca <env_free>
			curenv = NULL;
f0103841:	e8 d8 18 00 00       	call   f010511e <cpunum>
f0103846:	6b c0 74             	imul   $0x74,%eax,%eax
f0103849:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f0103850:	00 
			sched_yield();
f0103851:	e8 8a 01 00 00       	call   f01039e0 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103856:	e8 c3 18 00 00       	call   f010511e <cpunum>
f010385b:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f0103860:	6b c0 74             	imul   $0x74,%eax,%eax
f0103863:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103867:	b9 11 00 00 00       	mov    $0x11,%ecx
f010386c:	89 c7                	mov    %eax,%edi
f010386e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103870:	e8 a9 18 00 00       	call   f010511e <cpunum>
f0103875:	6b c0 74             	imul   $0x74,%eax,%eax
f0103878:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010387c:	89 35 e8 3a 23 f0    	mov    %esi,0xf0233ae8
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103882:	8b 46 28             	mov    0x28(%esi),%eax
f0103885:	83 f8 27             	cmp    $0x27,%eax
f0103888:	75 16                	jne    f01038a0 <trap+0x119>
		cprintf("Spurious interrupt on irq 7\n");
f010388a:	c7 04 24 e7 66 10 f0 	movl   $0xf01066e7,(%esp)
f0103891:	e8 65 f8 ff ff       	call   f01030fb <cprintf>
		print_trapframe(tf);
f0103896:	89 34 24             	mov    %esi,(%esp)
f0103899:	e8 c9 fc ff ff       	call   f0103567 <print_trapframe>
f010389e:	eb 63                	jmp    f0103903 <trap+0x17c>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

//=======
	/*stone's solution for lab3-B*/
	if (tf->tf_trapno == T_PGFLT)
f01038a0:	83 f8 0e             	cmp    $0xe,%eax
f01038a3:	75 08                	jne    f01038ad <trap+0x126>
		page_fault_handler(tf);
f01038a5:	89 34 24             	mov    %esi,(%esp)
f01038a8:	e8 4a fe ff ff       	call   f01036f7 <page_fault_handler>
	if (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT)
f01038ad:	8b 46 28             	mov    0x28(%esi),%eax
f01038b0:	83 f8 01             	cmp    $0x1,%eax
f01038b3:	74 05                	je     f01038ba <trap+0x133>
f01038b5:	83 f8 03             	cmp    $0x3,%eax
f01038b8:	75 08                	jne    f01038c2 <trap+0x13b>
		monitor(tf);
f01038ba:	89 34 24             	mov    %esi,(%esp)
f01038bd:	e8 38 d2 ff ff       	call   f0100afa <monitor>
	
//>>>>>>> lab3
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01038c2:	89 34 24             	mov    %esi,(%esp)
f01038c5:	e8 9d fc ff ff       	call   f0103567 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01038ca:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01038cf:	75 1c                	jne    f01038ed <trap+0x166>
		panic("unhandled trap in kernel");
f01038d1:	c7 44 24 08 04 67 10 	movl   $0xf0106704,0x8(%esp)
f01038d8:	f0 
f01038d9:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f01038e0:	00 
f01038e1:	c7 04 24 bb 66 10 f0 	movl   $0xf01066bb,(%esp)
f01038e8:	e8 98 c7 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f01038ed:	e8 2c 18 00 00       	call   f010511e <cpunum>
f01038f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f5:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f01038fb:	89 04 24             	mov    %eax,(%esp)
f01038fe:	e8 d0 f1 ff ff       	call   f0102ad3 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103903:	e8 16 18 00 00       	call   f010511e <cpunum>
f0103908:	6b c0 74             	imul   $0x74,%eax,%eax
f010390b:	83 b8 28 40 23 f0 00 	cmpl   $0x0,-0xfdcbfd8(%eax)
f0103912:	74 2a                	je     f010393e <trap+0x1b7>
f0103914:	e8 05 18 00 00       	call   f010511e <cpunum>
f0103919:	6b c0 74             	imul   $0x74,%eax,%eax
f010391c:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103922:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103926:	75 16                	jne    f010393e <trap+0x1b7>
		env_run(curenv);
f0103928:	e8 f1 17 00 00       	call   f010511e <cpunum>
f010392d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103930:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103936:	89 04 24             	mov    %eax,(%esp)
f0103939:	e8 65 ee ff ff       	call   f01027a3 <env_run>
	else
		sched_yield();
f010393e:	e8 9d 00 00 00       	call   f01039e0 <sched_yield>
	...

f0103944 <t0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*stone's solution for lab3-A*/
	TRAPHANDLER_NOEC(t0,  T_DIVIDE);
f0103944:	6a 00                	push   $0x0
f0103946:	6a 00                	push   $0x0
f0103948:	eb 7e                	jmp    f01039c8 <_alltraps>

f010394a <t1>:
	TRAPHANDLER_NOEC(t1,  T_DEBUG);
f010394a:	6a 00                	push   $0x0
f010394c:	6a 01                	push   $0x1
f010394e:	eb 78                	jmp    f01039c8 <_alltraps>

f0103950 <t2>:
	TRAPHANDLER_NOEC(t2,  T_NMI);
f0103950:	6a 00                	push   $0x0
f0103952:	6a 02                	push   $0x2
f0103954:	eb 72                	jmp    f01039c8 <_alltraps>

f0103956 <t3>:
	TRAPHANDLER_NOEC(t3,  T_BRKPT);
f0103956:	6a 00                	push   $0x0
f0103958:	6a 03                	push   $0x3
f010395a:	eb 6c                	jmp    f01039c8 <_alltraps>

f010395c <t4>:
	TRAPHANDLER_NOEC(t4,  T_OFLOW);
f010395c:	6a 00                	push   $0x0
f010395e:	6a 04                	push   $0x4
f0103960:	eb 66                	jmp    f01039c8 <_alltraps>

f0103962 <t5>:
	TRAPHANDLER_NOEC(t5,  T_BOUND);
f0103962:	6a 00                	push   $0x0
f0103964:	6a 05                	push   $0x5
f0103966:	eb 60                	jmp    f01039c8 <_alltraps>

f0103968 <t6>:
	TRAPHANDLER_NOEC(t6,  T_ILLOP);
f0103968:	6a 00                	push   $0x0
f010396a:	6a 06                	push   $0x6
f010396c:	eb 5a                	jmp    f01039c8 <_alltraps>

f010396e <t7>:
	TRAPHANDLER_NOEC(t7,  T_DEVICE);
f010396e:	6a 00                	push   $0x0
f0103970:	6a 07                	push   $0x7
f0103972:	eb 54                	jmp    f01039c8 <_alltraps>

f0103974 <t8>:
	TRAPHANDLER	(t8,  T_DBLFLT);
f0103974:	6a 08                	push   $0x8
f0103976:	eb 50                	jmp    f01039c8 <_alltraps>

f0103978 <t10>:
	TRAPHANDLER	(t10, T_TSS);
f0103978:	6a 0a                	push   $0xa
f010397a:	eb 4c                	jmp    f01039c8 <_alltraps>

f010397c <t11>:
	TRAPHANDLER	(t11, T_SEGNP);
f010397c:	6a 0b                	push   $0xb
f010397e:	eb 48                	jmp    f01039c8 <_alltraps>

f0103980 <t12>:
	TRAPHANDLER	(t12, T_STACK);
f0103980:	6a 0c                	push   $0xc
f0103982:	eb 44                	jmp    f01039c8 <_alltraps>

f0103984 <t13>:
	TRAPHANDLER	(t13, T_GPFLT);
f0103984:	6a 0d                	push   $0xd
f0103986:	eb 40                	jmp    f01039c8 <_alltraps>

f0103988 <t14>:
	TRAPHANDLER	(t14, T_PGFLT);
f0103988:	6a 0e                	push   $0xe
f010398a:	eb 3c                	jmp    f01039c8 <_alltraps>

f010398c <t16>:
	TRAPHANDLER_NOEC(t16, T_FPERR);
f010398c:	6a 00                	push   $0x0
f010398e:	6a 10                	push   $0x10
f0103990:	eb 36                	jmp    f01039c8 <_alltraps>

f0103992 <t17>:
	TRAPHANDLER	(t17, T_ALIGN);
f0103992:	6a 11                	push   $0x11
f0103994:	eb 32                	jmp    f01039c8 <_alltraps>

f0103996 <t18>:
	TRAPHANDLER_NOEC(t18, T_MCHK);
f0103996:	6a 00                	push   $0x0
f0103998:	6a 12                	push   $0x12
f010399a:	eb 2c                	jmp    f01039c8 <_alltraps>

f010399c <t19>:
	TRAPHANDLER_NOEC(t19, T_SIMDERR );
f010399c:	6a 00                	push   $0x0
f010399e:	6a 13                	push   $0x13
f01039a0:	eb 26                	jmp    f01039c8 <_alltraps>

f01039a2 <sysenter_handler>:
/*
 * Lab 3: Your code here for system call handling
 */
/*stone's solution for lab3-B*/
	//User Data
	pushl $GD_UD
f01039a2:	6a 20                	push   $0x20
	pushl %ebp
f01039a4:	55                   	push   %ebp
	//flag registers
	pushfl
f01039a5:	9c                   	pushf  
	//User Text
	pushl $GD_UT
f01039a6:	6a 18                	push   $0x18
	pushl %esi
f01039a8:	56                   	push   %esi
	pushl $0
f01039a9:	6a 00                	push   $0x0
	pushl $0
f01039ab:	6a 00                	push   $0x0
	pushl %ds
f01039ad:	1e                   	push   %ds
	pushl %es
f01039ae:	06                   	push   %es

	//tf parse to router
	pushal
f01039af:	60                   	pusha  
	//switch to Kernel Data
	movw $GD_KD, %ax
f01039b0:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01039b4:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01039b6:	8e c0                	mov    %eax,%es
	pushl %esp
f01039b8:	54                   	push   %esp
	//router is a method to parse modified register to syscall
	call router
f01039b9:	e8 60 03 00 00       	call   f0103d1e <router>
	popl %esp
f01039be:	5c                   	pop    %esp
	popal
f01039bf:	61                   	popa   
	popl %es
f01039c0:	07                   	pop    %es
	popl %ds
f01039c1:	1f                   	pop    %ds
	movl %ebp, %ecx
f01039c2:	89 e9                	mov    %ebp,%ecx
	movl %esi, %edx
f01039c4:	89 f2                	mov    %esi,%edx
	sysexit
f01039c6:	0f 35                	sysexit 

f01039c8 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
/*stone's solution for lab3-A*/
_alltraps:
	pushl %ds
f01039c8:	1e                   	push   %ds
	pushl %es
f01039c9:	06                   	push   %es
	pushal
f01039ca:	60                   	pusha  
	
	movw $GD_KD, %ax
f01039cb:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01039cf:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01039d1:	8e c0                	mov    %eax,%es
	
	pushl %esp
f01039d3:	54                   	push   %esp
	call trap
f01039d4:	e8 ae fd ff ff       	call   f0103787 <trap>
f01039d9:	00 00                	add    %al,(%eax)
f01039db:	00 00                	add    %al,(%eax)
f01039dd:	00 00                	add    %al,(%eax)
	...

f01039e0 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01039e0:	55                   	push   %ebp
f01039e1:	89 e5                	mov    %esp,%ebp
f01039e3:	53                   	push   %ebx
f01039e4:	83 ec 14             	sub    $0x14,%esp

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f01039e7:	8b 1d 5c 32 23 f0    	mov    0xf023325c,%ebx
f01039ed:	89 d8                	mov    %ebx,%eax
f01039ef:	ba 00 00 00 00       	mov    $0x0,%edx
f01039f4:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f01039f8:	74 0b                	je     f0103a05 <sched_yield+0x25>
f01039fa:	8b 48 54             	mov    0x54(%eax),%ecx
f01039fd:	83 e9 02             	sub    $0x2,%ecx
f0103a00:	83 f9 01             	cmp    $0x1,%ecx
f0103a03:	76 10                	jbe    f0103a15 <sched_yield+0x35>
	// LAB 4: Your code here.

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103a05:	83 c2 01             	add    $0x1,%edx
f0103a08:	83 e8 80             	sub    $0xffffff80,%eax
f0103a0b:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103a11:	75 e1                	jne    f01039f4 <sched_yield+0x14>
f0103a13:	eb 08                	jmp    f0103a1d <sched_yield+0x3d>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0103a15:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103a1b:	75 1a                	jne    f0103a37 <sched_yield+0x57>
		cprintf("No more runnable environments!\n");
f0103a1d:	c7 04 24 f0 68 10 f0 	movl   $0xf01068f0,(%esp)
f0103a24:	e8 d2 f6 ff ff       	call   f01030fb <cprintf>
		while (1)
			monitor(NULL);
f0103a29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a30:	e8 c5 d0 ff ff       	call   f0100afa <monitor>
f0103a35:	eb f2                	jmp    f0103a29 <sched_yield+0x49>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0103a37:	e8 e2 16 00 00       	call   f010511e <cpunum>
f0103a3c:	c1 e0 07             	shl    $0x7,%eax
f0103a3f:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0103a41:	8b 43 54             	mov    0x54(%ebx),%eax
f0103a44:	83 e8 02             	sub    $0x2,%eax
f0103a47:	83 f8 01             	cmp    $0x1,%eax
f0103a4a:	76 25                	jbe    f0103a71 <sched_yield+0x91>
		panic("CPU %d: No idle environment!", cpunum());
f0103a4c:	e8 cd 16 00 00       	call   f010511e <cpunum>
f0103a51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a55:	c7 44 24 08 10 69 10 	movl   $0xf0106910,0x8(%esp)
f0103a5c:	f0 
f0103a5d:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f0103a64:	00 
f0103a65:	c7 04 24 2d 69 10 f0 	movl   $0xf010692d,(%esp)
f0103a6c:	e8 14 c6 ff ff       	call   f0100085 <_panic>
	env_run(idle);
f0103a71:	89 1c 24             	mov    %ebx,(%esp)
f0103a74:	e8 2a ed ff ff       	call   f01027a3 <env_run>
f0103a79:	00 00                	add    %al,(%eax)
f0103a7b:	00 00                	add    %al,(%eax)
f0103a7d:	00 00                	add    %al,(%eax)
	...

f0103a80 <sbrk>:

//=======
/*stone's solution for lab3-B*/
void
sbrk(struct Env* e, size_t len)
{
f0103a80:	55                   	push   %ebp
f0103a81:	89 e5                	mov    %esp,%ebp
f0103a83:	57                   	push   %edi
f0103a84:	56                   	push   %esi
f0103a85:	53                   	push   %ebx
f0103a86:	83 ec 2c             	sub    $0x2c,%esp
f0103a89:	8b 75 08             	mov    0x8(%ebp),%esi
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
f0103a8c:	8b 7e 60             	mov    0x60(%esi),%edi
f0103a8f:	89 f8                	mov    %edi,%eax
f0103a91:	2b 45 0c             	sub    0xc(%ebp),%eax
f0103a94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103a99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
f0103a9c:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0103aa2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
f0103aa8:	39 f8                	cmp    %edi,%eax
f0103aaa:	73 77                	jae    f0103b23 <sbrk+0xa3>
f0103aac:	89 c3                	mov    %eax,%ebx
		int r;
		if (!(p = page_alloc(0)))
f0103aae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ab5:	e8 0c da ff ff       	call   f01014c6 <page_alloc>
f0103aba:	85 c0                	test   %eax,%eax
f0103abc:	75 1c                	jne    f0103ada <sbrk+0x5a>
			panic("env_alloc: page alloc failed\n");
f0103abe:	c7 44 24 08 b2 64 10 	movl   $0xf01064b2,0x8(%esp)
f0103ac5:	f0 
f0103ac6:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0103acd:	00 
f0103ace:	c7 04 24 3a 69 10 f0 	movl   $0xf010693a,(%esp)
f0103ad5:	e8 ab c5 ff ff       	call   f0100085 <_panic>
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
f0103ada:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103ae1:	00 
f0103ae2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aea:	8b 46 64             	mov    0x64(%esi),%eax
f0103aed:	89 04 24             	mov    %eax,(%esp)
f0103af0:	e8 e9 dc ff ff       	call   f01017de <page_insert>
f0103af5:	85 c0                	test   %eax,%eax
f0103af7:	79 20                	jns    f0103b19 <sbrk+0x99>
			panic("env_alloc: %e\n", r);
f0103af9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103afd:	c7 44 24 08 d0 64 10 	movl   $0xf01064d0,0x8(%esp)
f0103b04:	f0 
f0103b05:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f0103b0c:	00 
f0103b0d:	c7 04 24 3a 69 10 f0 	movl   $0xf010693a,(%esp)
f0103b14:	e8 6c c5 ff ff       	call   f0100085 <_panic>
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
f0103b19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103b1f:	39 df                	cmp    %ebx,%edi
f0103b21:	77 8b                	ja     f0103aae <sbrk+0x2e>
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
		//cprintf("2\n");
	}
	e->env_sbrk_pos = start;	
f0103b23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b26:	89 46 60             	mov    %eax,0x60(%esi)
}
f0103b29:	83 c4 2c             	add    $0x2c,%esp
f0103b2c:	5b                   	pop    %ebx
f0103b2d:	5e                   	pop    %esi
f0103b2e:	5f                   	pop    %edi
f0103b2f:	5d                   	pop    %ebp
f0103b30:	c3                   	ret    

f0103b31 <syscall>:
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103b31:	55                   	push   %ebp
f0103b32:	89 e5                	mov    %esp,%ebp
f0103b34:	83 ec 28             	sub    $0x28,%esp
f0103b37:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0103b3a:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0103b3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b43:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	int32_t ret = -E_INVAL;
	switch (syscallno){
f0103b46:	83 f8 0e             	cmp    $0xe,%eax
f0103b49:	77 07                	ja     f0103b52 <syscall+0x21>
f0103b4b:	ff 24 85 84 69 10 f0 	jmp    *-0xfef967c(,%eax,4)
f0103b52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103b57:	e9 b8 01 00 00       	jmp    f0103d14 <syscall+0x1e3>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	user_mem_assert(curenv, (void*)s, len, PTE_P | PTE_U);
f0103b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103b60:	e8 b9 15 00 00       	call   f010511e <cpunum>
f0103b65:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103b6c:	00 
f0103b6d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103b71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b78:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103b7e:	89 04 24             	mov    %eax,(%esp)
f0103b81:	e8 3f db ff ff       	call   f01016c5 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103b86:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b8a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b8e:	c7 04 24 49 69 10 f0 	movl   $0xf0106949,(%esp)
f0103b95:	e8 61 f5 ff ff       	call   f01030fb <cprintf>
f0103b9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b9f:	e9 70 01 00 00       	jmp    f0103d14 <syscall+0x1e3>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103ba4:	e8 a6 c8 ff ff       	call   f010044f <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0103ba9:	e9 66 01 00 00       	jmp    f0103d14 <syscall+0x1e3>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	//cprintf("get:%08x\n", curenv->env_id);
	return curenv->env_id;
f0103bae:	66 90                	xchg   %ax,%ax
f0103bb0:	e8 69 15 00 00       	call   f010511e <cpunum>
f0103bb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bb8:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103bbe:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f0103bc1:	e9 4e 01 00 00       	jmp    f0103d14 <syscall+0x1e3>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103bc6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103bcd:	00 
f0103bce:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd5:	89 1c 24             	mov    %ebx,(%esp)
f0103bd8:	e8 dd ea ff ff       	call   f01026ba <envid2env>
f0103bdd:	85 c0                	test   %eax,%eax
f0103bdf:	0f 88 2f 01 00 00    	js     f0103d14 <syscall+0x1e3>
		return r;
	if (e == curenv)
f0103be5:	e8 34 15 00 00       	call   f010511e <cpunum>
f0103bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103bed:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf0:	39 90 28 40 23 f0    	cmp    %edx,-0xfdcbfd8(%eax)
f0103bf6:	75 23                	jne    f0103c1b <syscall+0xea>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103bf8:	e8 21 15 00 00       	call   f010511e <cpunum>
f0103bfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c00:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103c06:	8b 40 48             	mov    0x48(%eax),%eax
f0103c09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c0d:	c7 04 24 4e 69 10 f0 	movl   $0xf010694e,(%esp)
f0103c14:	e8 e2 f4 ff ff       	call   f01030fb <cprintf>
f0103c19:	eb 28                	jmp    f0103c43 <syscall+0x112>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103c1b:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103c1e:	e8 fb 14 00 00       	call   f010511e <cpunum>
f0103c23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103c27:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2a:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103c30:	8b 40 48             	mov    0x48(%eax),%eax
f0103c33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c37:	c7 04 24 69 69 10 f0 	movl   $0xf0106969,(%esp)
f0103c3e:	e8 b8 f4 ff ff       	call   f01030fb <cprintf>
	env_destroy(e);
f0103c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c46:	89 04 24             	mov    %eax,(%esp)
f0103c49:	e8 85 ee ff ff       	call   f0102ad3 <env_destroy>
f0103c4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c53:	e9 bc 00 00 00       	jmp    f0103d14 <syscall+0x1e3>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c58:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103c5e:	77 20                	ja     f0103c80 <syscall+0x14f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c60:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103c64:	c7 44 24 08 bc 58 10 	movl   $0xf01058bc,0x8(%esp)
f0103c6b:	f0 
f0103c6c:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0103c73:	00 
f0103c74:	c7 04 24 3a 69 10 f0 	movl   $0xf010693a,(%esp)
f0103c7b:	e8 05 c4 ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c80:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0103c86:	c1 eb 0c             	shr    $0xc,%ebx
f0103c89:	3b 1d 08 3f 23 f0    	cmp    0xf0233f08,%ebx
f0103c8f:	72 1c                	jb     f0103cad <syscall+0x17c>
		panic("pa2page called with invalid pa");
f0103c91:	c7 44 24 08 ac 5f 10 	movl   $0xf0105fac,0x8(%esp)
f0103c98:	f0 
f0103c99:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0103ca0:	00 
f0103ca1:	c7 04 24 ad 62 10 f0 	movl   $0xf01062ad,(%esp)
f0103ca8:	e8 d8 c3 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0103cad:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0103cb0:	b8 03 00 00 00       	mov    $0x3,%eax
f0103cb5:	03 1d 10 3f 23 f0    	add    0xf0233f10,%ebx
f0103cbb:	74 57                	je     f0103d14 <syscall+0x1e3>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0103cbd:	e8 5c 14 00 00       	call   f010511e <cpunum>
f0103cc2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103cc9:	00 
f0103cca:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103cce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd5:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103cdb:	8b 40 64             	mov    0x64(%eax),%eax
f0103cde:	89 04 24             	mov    %eax,(%esp)
f0103ce1:	e8 f8 da ff ff       	call   f01017de <page_insert>
f0103ce6:	eb 2c                	jmp    f0103d14 <syscall+0x1e3>
static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	/*stone's solution for lab3-B*/
	sbrk(curenv, inc);
f0103ce8:	e8 31 14 00 00       	call   f010511e <cpunum>
f0103ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cf1:	bb 20 40 23 f0       	mov    $0xf0234020,%ebx
f0103cf6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cf9:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103cfd:	89 04 24             	mov    %eax,(%esp)
f0103d00:	e8 7b fd ff ff       	call   f0103a80 <sbrk>
	return (int)curenv->env_sbrk_pos;
f0103d05:	e8 14 14 00 00       	call   f010511e <cpunum>
f0103d0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0d:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103d11:	8b 40 60             	mov    0x60(%eax),%eax
		default:
			break;
	}
	return ret;
	//panic("syscall not implemented");
}
f0103d14:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0103d17:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0103d1a:	89 ec                	mov    %ebp,%esp
f0103d1c:	5d                   	pop    %ebp
f0103d1d:	c3                   	ret    

f0103d1e <router>:
	sbrk(curenv, inc);
	return (int)curenv->env_sbrk_pos;
}
/*stone's solution for lab3-B*/
void
router(struct Trapframe *tf){
f0103d1e:	55                   	push   %ebp
f0103d1f:	89 e5                	mov    %esp,%ebp
f0103d21:	83 ec 38             	sub    $0x38,%esp
f0103d24:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103d27:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103d2a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103d2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	curenv->env_tf = *tf;
f0103d30:	e8 e9 13 00 00       	call   f010511e <cpunum>
f0103d35:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d38:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103d3e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103d43:	89 c7                	mov    %eax,%edi
f0103d45:	89 de                	mov    %ebx,%esi
f0103d47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
f0103d49:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f0103d50:	00 
f0103d51:	8b 03                	mov    (%ebx),%eax
f0103d53:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103d57:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d5e:	8b 43 18             	mov    0x18(%ebx),%eax
f0103d61:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d65:	8b 43 14             	mov    0x14(%ebx),%eax
f0103d68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d6c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103d6f:	89 04 24             	mov    %eax,(%esp)
f0103d72:	e8 ba fd ff ff       	call   f0103b31 <syscall>
f0103d77:	89 43 1c             	mov    %eax,0x1c(%ebx)
}
f0103d7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103d7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103d80:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103d83:	89 ec                	mov    %ebp,%esp
f0103d85:	5d                   	pop    %ebp
f0103d86:	c3                   	ret    
	...

f0103d90 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103d90:	55                   	push   %ebp
f0103d91:	89 e5                	mov    %esp,%ebp
f0103d93:	57                   	push   %edi
f0103d94:	56                   	push   %esi
f0103d95:	53                   	push   %ebx
f0103d96:	83 ec 14             	sub    $0x14,%esp
f0103d99:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103d9c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103d9f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103da2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103da5:	8b 1a                	mov    (%edx),%ebx
f0103da7:	8b 01                	mov    (%ecx),%eax
f0103da9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0103dac:	39 c3                	cmp    %eax,%ebx
f0103dae:	0f 8f 9c 00 00 00    	jg     f0103e50 <stab_binsearch+0xc0>
f0103db4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0103dbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103dbe:	01 d8                	add    %ebx,%eax
f0103dc0:	89 c7                	mov    %eax,%edi
f0103dc2:	c1 ef 1f             	shr    $0x1f,%edi
f0103dc5:	01 c7                	add    %eax,%edi
f0103dc7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103dc9:	39 df                	cmp    %ebx,%edi
f0103dcb:	7c 33                	jl     f0103e00 <stab_binsearch+0x70>
f0103dcd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103dd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103dd3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103dd8:	39 f0                	cmp    %esi,%eax
f0103dda:	0f 84 bc 00 00 00    	je     f0103e9c <stab_binsearch+0x10c>
f0103de0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0103de4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0103de8:	89 f8                	mov    %edi,%eax
			m--;
f0103dea:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ded:	39 d8                	cmp    %ebx,%eax
f0103def:	7c 0f                	jl     f0103e00 <stab_binsearch+0x70>
f0103df1:	0f b6 0a             	movzbl (%edx),%ecx
f0103df4:	83 ea 0c             	sub    $0xc,%edx
f0103df7:	39 f1                	cmp    %esi,%ecx
f0103df9:	75 ef                	jne    f0103dea <stab_binsearch+0x5a>
f0103dfb:	e9 9e 00 00 00       	jmp    f0103e9e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103e00:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103e03:	eb 3c                	jmp    f0103e41 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103e05:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103e08:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103e0a:	8d 5f 01             	lea    0x1(%edi),%ebx
f0103e0d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103e14:	eb 2b                	jmp    f0103e41 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0103e16:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103e19:	76 14                	jbe    f0103e2f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103e1b:	83 e8 01             	sub    $0x1,%eax
f0103e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103e21:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103e24:	89 02                	mov    %eax,(%edx)
f0103e26:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103e2d:	eb 12                	jmp    f0103e41 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103e2f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103e32:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103e34:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103e38:	89 c3                	mov    %eax,%ebx
f0103e3a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103e41:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103e44:	0f 8d 71 ff ff ff    	jge    f0103dbb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103e4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103e4e:	75 0f                	jne    f0103e5f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103e50:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103e53:	8b 03                	mov    (%ebx),%eax
f0103e55:	83 e8 01             	sub    $0x1,%eax
f0103e58:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103e5b:	89 02                	mov    %eax,(%edx)
f0103e5d:	eb 57                	jmp    f0103eb6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103e5f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e62:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103e64:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103e67:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103e69:	39 c1                	cmp    %eax,%ecx
f0103e6b:	7d 28                	jge    f0103e95 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103e6d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103e70:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103e73:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103e78:	39 f2                	cmp    %esi,%edx
f0103e7a:	74 19                	je     f0103e95 <stab_binsearch+0x105>
f0103e7c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0103e80:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0103e84:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103e87:	39 c1                	cmp    %eax,%ecx
f0103e89:	7d 0a                	jge    f0103e95 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103e8b:	0f b6 1a             	movzbl (%edx),%ebx
f0103e8e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103e91:	39 f3                	cmp    %esi,%ebx
f0103e93:	75 ef                	jne    f0103e84 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0103e95:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103e98:	89 02                	mov    %eax,(%edx)
f0103e9a:	eb 1a                	jmp    f0103eb6 <stab_binsearch+0x126>
	}
}
f0103e9c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103e9e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103ea1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103ea4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103ea8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103eab:	0f 82 54 ff ff ff    	jb     f0103e05 <stab_binsearch+0x75>
f0103eb1:	e9 60 ff ff ff       	jmp    f0103e16 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103eb6:	83 c4 14             	add    $0x14,%esp
f0103eb9:	5b                   	pop    %ebx
f0103eba:	5e                   	pop    %esi
f0103ebb:	5f                   	pop    %edi
f0103ebc:	5d                   	pop    %ebp
f0103ebd:	c3                   	ret    

f0103ebe <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ebe:	55                   	push   %ebp
f0103ebf:	89 e5                	mov    %esp,%ebp
f0103ec1:	83 ec 58             	sub    $0x58,%esp
f0103ec4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103ec7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103eca:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103ecd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ed0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103ed3:	c7 03 c0 69 10 f0    	movl   $0xf01069c0,(%ebx)
	info->eip_line = 0;
f0103ed9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103ee0:	c7 43 08 c0 69 10 f0 	movl   $0xf01069c0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103ee7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103eee:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103ef1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103ef8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103efe:	76 1f                	jbe    f0103f1f <debuginfo_eip+0x61>
f0103f00:	bf c2 49 11 f0       	mov    $0xf01149c2,%edi
f0103f05:	c7 45 c4 ad 0d 11 f0 	movl   $0xf0110dad,-0x3c(%ebp)
f0103f0c:	c7 45 bc ac 0d 11 f0 	movl   $0xf0110dac,-0x44(%ebp)
f0103f13:	c7 45 c0 94 6e 10 f0 	movl   $0xf0106e94,-0x40(%ebp)
f0103f1a:	e9 c7 00 00 00       	jmp    f0103fe6 <debuginfo_eip+0x128>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		/*stone's solution for lab3-B*/
		if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f0103f1f:	e8 fa 11 00 00       	call   f010511e <cpunum>
f0103f24:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103f2b:	00 
f0103f2c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0103f33:	00 
f0103f34:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0103f3b:	00 
f0103f3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f3f:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103f45:	89 04 24             	mov    %eax,(%esp)
f0103f48:	e8 e3 d6 ff ff       	call   f0101630 <user_mem_check>
f0103f4d:	85 c0                	test   %eax,%eax
f0103f4f:	0f 88 01 02 00 00    	js     f0104156 <debuginfo_eip+0x298>
		stabs = usd->stabs;
f0103f55:	b8 00 00 20 00       	mov    $0x200000,%eax
f0103f5a:	8b 10                	mov    (%eax),%edx
f0103f5c:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103f5f:	8b 48 04             	mov    0x4(%eax),%ecx
f0103f62:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f0103f65:	8b 50 08             	mov    0x8(%eax),%edx
f0103f68:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103f6b:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		/*stone's solution for lab3-B*/
		if (user_mem_check(curenv, (void*)stabs, stab_end - stabs, PTE_U) < 0) return -1;
f0103f6e:	e8 ab 11 00 00       	call   f010511e <cpunum>
f0103f73:	89 c2                	mov    %eax,%edx
f0103f75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103f7c:	00 
f0103f7d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103f80:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0103f83:	c1 f8 02             	sar    $0x2,%eax
f0103f86:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f90:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103f93:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103f97:	6b c2 74             	imul   $0x74,%edx,%eax
f0103f9a:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103fa0:	89 04 24             	mov    %eax,(%esp)
f0103fa3:	e8 88 d6 ff ff       	call   f0101630 <user_mem_check>
f0103fa8:	85 c0                	test   %eax,%eax
f0103faa:	0f 88 a6 01 00 00    	js     f0104156 <debuginfo_eip+0x298>
		if (user_mem_check(curenv, (void*)stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f0103fb0:	e8 69 11 00 00       	call   f010511e <cpunum>
f0103fb5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103fbc:	00 
f0103fbd:	89 fa                	mov    %edi,%edx
f0103fbf:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0103fc2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103fc6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103fc9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103fcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd0:	8b 80 28 40 23 f0    	mov    -0xfdcbfd8(%eax),%eax
f0103fd6:	89 04 24             	mov    %eax,(%esp)
f0103fd9:	e8 52 d6 ff ff       	call   f0101630 <user_mem_check>
f0103fde:	85 c0                	test   %eax,%eax
f0103fe0:	0f 88 70 01 00 00    	js     f0104156 <debuginfo_eip+0x298>
		
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103fe6:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0103fe9:	0f 83 67 01 00 00    	jae    f0104156 <debuginfo_eip+0x298>
f0103fef:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103ff3:	0f 85 5d 01 00 00    	jne    f0104156 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103ff9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104000:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104003:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0104006:	c1 f8 02             	sar    $0x2,%eax
f0104009:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010400f:	83 e8 01             	sub    $0x1,%eax
f0104012:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104015:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104018:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010401b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010401f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104026:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104029:	e8 62 fd ff ff       	call   f0103d90 <stab_binsearch>
	if (lfile == 0)
f010402e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104031:	85 c0                	test   %eax,%eax
f0104033:	0f 84 1d 01 00 00    	je     f0104156 <debuginfo_eip+0x298>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104039:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010403c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010403f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104042:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104045:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104048:	89 74 24 04          	mov    %esi,0x4(%esp)
f010404c:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104053:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104056:	e8 35 fd ff ff       	call   f0103d90 <stab_binsearch>

	if (lfun <= rfun) {
f010405b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010405e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104061:	7f 35                	jg     f0104098 <debuginfo_eip+0x1da>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104063:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104066:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104069:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f010406c:	89 fa                	mov    %edi,%edx
f010406e:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0104071:	39 d0                	cmp    %edx,%eax
f0104073:	73 06                	jae    f010407b <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104075:	03 45 c4             	add    -0x3c(%ebp),%eax
f0104078:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010407b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010407e:	6b c2 0c             	imul   $0xc,%edx,%eax
f0104081:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104084:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f0104088:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010408b:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010408d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104090:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104093:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104096:	eb 0f                	jmp    f01040a7 <debuginfo_eip+0x1e9>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104098:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010409b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010409e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01040a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01040a7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01040ae:	00 
f01040af:	8b 43 08             	mov    0x8(%ebx),%eax
f01040b2:	89 04 24             	mov    %eax,(%esp)
f01040b5:	e8 91 09 00 00       	call   f0104a4b <strfind>
f01040ba:	2b 43 08             	sub    0x8(%ebx),%eax
f01040bd:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	/* stone's solution for exercise15 */
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01040c0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01040c3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01040c6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040ca:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01040d1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01040d4:	e8 b7 fc ff ff       	call   f0103d90 <stab_binsearch>
	if (lline <= rline)
f01040d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040dc:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01040df:	7f 75                	jg     f0104156 <debuginfo_eip+0x298>
		info->eip_line = stabs[lline].n_desc;
f01040e1:	6b c0 0c             	imul   $0xc,%eax,%eax
f01040e4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01040e7:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f01040ec:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01040ef:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01040f2:	eb 06                	jmp    f01040fa <debuginfo_eip+0x23c>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01040f4:	83 e8 01             	sub    $0x1,%eax
f01040f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01040fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01040fd:	39 f0                	cmp    %esi,%eax
f01040ff:	7c 26                	jl     f0104127 <debuginfo_eip+0x269>
	       && stabs[lline].n_type != N_SOL
f0104101:	6b d0 0c             	imul   $0xc,%eax,%edx
f0104104:	03 55 c0             	add    -0x40(%ebp),%edx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104107:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010410b:	80 f9 84             	cmp    $0x84,%cl
f010410e:	74 5f                	je     f010416f <debuginfo_eip+0x2b1>
f0104110:	80 f9 64             	cmp    $0x64,%cl
f0104113:	75 df                	jne    f01040f4 <debuginfo_eip+0x236>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104115:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104119:	74 d9                	je     f01040f4 <debuginfo_eip+0x236>
f010411b:	90                   	nop
f010411c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104120:	eb 4d                	jmp    f010416f <debuginfo_eip+0x2b1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104122:	03 45 c4             	add    -0x3c(%ebp),%eax
f0104125:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104127:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010412a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010412d:	7d 2e                	jge    f010415d <debuginfo_eip+0x29f>
		for (lline = lfun + 1;
f010412f:	83 c0 01             	add    $0x1,%eax
f0104132:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104135:	eb 08                	jmp    f010413f <debuginfo_eip+0x281>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104137:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010413b:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010413f:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104142:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104145:	7d 16                	jge    f010415d <debuginfo_eip+0x29f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104147:	6b c0 0c             	imul   $0xc,%eax,%eax
f010414a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010414d:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f0104152:	74 e3                	je     f0104137 <debuginfo_eip+0x279>
f0104154:	eb 07                	jmp    f010415d <debuginfo_eip+0x29f>
f0104156:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010415b:	eb 05                	jmp    f0104162 <debuginfo_eip+0x2a4>
f010415d:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0104162:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104165:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104168:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010416b:	89 ec                	mov    %ebp,%esp
f010416d:	5d                   	pop    %ebp
f010416e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010416f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104172:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104175:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0104178:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f010417b:	39 f8                	cmp    %edi,%eax
f010417d:	72 a3                	jb     f0104122 <debuginfo_eip+0x264>
f010417f:	eb a6                	jmp    f0104127 <debuginfo_eip+0x269>
	...

f0104190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104190:	55                   	push   %ebp
f0104191:	89 e5                	mov    %esp,%ebp
f0104193:	57                   	push   %edi
f0104194:	56                   	push   %esi
f0104195:	53                   	push   %ebx
f0104196:	83 ec 4c             	sub    $0x4c,%esp
f0104199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010419c:	89 d6                	mov    %edx,%esi
f010419e:	8b 45 08             	mov    0x8(%ebp),%eax
f01041a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01041a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01041aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01041ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01041b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01041b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01041b6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041bb:	39 d1                	cmp    %edx,%ecx
f01041bd:	72 15                	jb     f01041d4 <printnum+0x44>
f01041bf:	77 07                	ja     f01041c8 <printnum+0x38>
f01041c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01041c4:	39 d0                	cmp    %edx,%eax
f01041c6:	76 0c                	jbe    f01041d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01041c8:	83 eb 01             	sub    $0x1,%ebx
f01041cb:	85 db                	test   %ebx,%ebx
f01041cd:	8d 76 00             	lea    0x0(%esi),%esi
f01041d0:	7f 61                	jg     f0104233 <printnum+0xa3>
f01041d2:	eb 70                	jmp    f0104244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01041d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01041d8:	83 eb 01             	sub    $0x1,%ebx
f01041db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01041df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01041e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01041e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01041eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01041ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01041f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01041f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01041f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01041ff:	00 
f0104200:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104203:	89 04 24             	mov    %eax,(%esp)
f0104206:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104209:	89 54 24 04          	mov    %edx,0x4(%esp)
f010420d:	e8 ae 13 00 00       	call   f01055c0 <__udivdi3>
f0104212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010421c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104220:	89 04 24             	mov    %eax,(%esp)
f0104223:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104227:	89 f2                	mov    %esi,%edx
f0104229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010422c:	e8 5f ff ff ff       	call   f0104190 <printnum>
f0104231:	eb 11                	jmp    f0104244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104233:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104237:	89 3c 24             	mov    %edi,(%esp)
f010423a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010423d:	83 eb 01             	sub    $0x1,%ebx
f0104240:	85 db                	test   %ebx,%ebx
f0104242:	7f ef                	jg     f0104233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104244:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104248:	8b 74 24 04          	mov    0x4(%esp),%esi
f010424c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010424f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010425a:	00 
f010425b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010425e:	89 14 24             	mov    %edx,(%esp)
f0104261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104268:	e8 83 14 00 00       	call   f01056f0 <__umoddi3>
f010426d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104271:	0f be 80 ca 69 10 f0 	movsbl -0xfef9636(%eax),%eax
f0104278:	89 04 24             	mov    %eax,(%esp)
f010427b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010427e:	83 c4 4c             	add    $0x4c,%esp
f0104281:	5b                   	pop    %ebx
f0104282:	5e                   	pop    %esi
f0104283:	5f                   	pop    %edi
f0104284:	5d                   	pop    %ebp
f0104285:	c3                   	ret    

f0104286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104286:	55                   	push   %ebp
f0104287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104289:	83 fa 01             	cmp    $0x1,%edx
f010428c:	7e 0e                	jle    f010429c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010428e:	8b 10                	mov    (%eax),%edx
f0104290:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104293:	89 08                	mov    %ecx,(%eax)
f0104295:	8b 02                	mov    (%edx),%eax
f0104297:	8b 52 04             	mov    0x4(%edx),%edx
f010429a:	eb 22                	jmp    f01042be <getuint+0x38>
	else if (lflag)
f010429c:	85 d2                	test   %edx,%edx
f010429e:	74 10                	je     f01042b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01042a0:	8b 10                	mov    (%eax),%edx
f01042a2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01042a5:	89 08                	mov    %ecx,(%eax)
f01042a7:	8b 02                	mov    (%edx),%eax
f01042a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01042ae:	eb 0e                	jmp    f01042be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01042b0:	8b 10                	mov    (%eax),%edx
f01042b2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01042b5:	89 08                	mov    %ecx,(%eax)
f01042b7:	8b 02                	mov    (%edx),%eax
f01042b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01042be:	5d                   	pop    %ebp
f01042bf:	c3                   	ret    

f01042c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01042c0:	55                   	push   %ebp
f01042c1:	89 e5                	mov    %esp,%ebp
f01042c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01042c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01042ca:	8b 10                	mov    (%eax),%edx
f01042cc:	3b 50 04             	cmp    0x4(%eax),%edx
f01042cf:	73 0a                	jae    f01042db <sprintputch+0x1b>
		*b->buf++ = ch;
f01042d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042d4:	88 0a                	mov    %cl,(%edx)
f01042d6:	83 c2 01             	add    $0x1,%edx
f01042d9:	89 10                	mov    %edx,(%eax)
}
f01042db:	5d                   	pop    %ebp
f01042dc:	c3                   	ret    

f01042dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01042dd:	55                   	push   %ebp
f01042de:	89 e5                	mov    %esp,%ebp
f01042e0:	57                   	push   %edi
f01042e1:	56                   	push   %esi
f01042e2:	53                   	push   %ebx
f01042e3:	83 ec 5c             	sub    $0x5c,%esp
f01042e6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01042e9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01042ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01042ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01042f6:	eb 11                	jmp    f0104309 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01042f8:	85 c0                	test   %eax,%eax
f01042fa:	0f 84 09 04 00 00    	je     f0104709 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
f0104300:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104304:	89 04 24             	mov    %eax,(%esp)
f0104307:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104309:	0f b6 03             	movzbl (%ebx),%eax
f010430c:	83 c3 01             	add    $0x1,%ebx
f010430f:	83 f8 25             	cmp    $0x25,%eax
f0104312:	75 e4                	jne    f01042f8 <vprintfmt+0x1b>
f0104314:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0104318:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010431f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104326:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010432d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104332:	eb 06                	jmp    f010433a <vprintfmt+0x5d>
f0104334:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0104338:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010433a:	0f b6 13             	movzbl (%ebx),%edx
f010433d:	0f b6 c2             	movzbl %dl,%eax
f0104340:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104343:	8d 43 01             	lea    0x1(%ebx),%eax
f0104346:	83 ea 23             	sub    $0x23,%edx
f0104349:	80 fa 55             	cmp    $0x55,%dl
f010434c:	0f 87 9a 03 00 00    	ja     f01046ec <vprintfmt+0x40f>
f0104352:	0f b6 d2             	movzbl %dl,%edx
f0104355:	ff 24 95 80 6a 10 f0 	jmp    *-0xfef9580(,%edx,4)
f010435c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104360:	eb d6                	jmp    f0104338 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104362:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104365:	83 ea 30             	sub    $0x30,%edx
f0104368:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f010436b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010436e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104371:	83 fb 09             	cmp    $0x9,%ebx
f0104374:	77 4c                	ja     f01043c2 <vprintfmt+0xe5>
f0104376:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104379:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010437c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f010437f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104382:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0104386:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104389:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010438c:	83 fb 09             	cmp    $0x9,%ebx
f010438f:	76 eb                	jbe    f010437c <vprintfmt+0x9f>
f0104391:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104394:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104397:	eb 29                	jmp    f01043c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104399:	8b 55 14             	mov    0x14(%ebp),%edx
f010439c:	8d 5a 04             	lea    0x4(%edx),%ebx
f010439f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01043a2:	8b 12                	mov    (%edx),%edx
f01043a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f01043a7:	eb 19                	jmp    f01043c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
f01043a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01043ac:	c1 fa 1f             	sar    $0x1f,%edx
f01043af:	f7 d2                	not    %edx
f01043b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
f01043b4:	eb 82                	jmp    f0104338 <vprintfmt+0x5b>
f01043b6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01043bd:	e9 76 ff ff ff       	jmp    f0104338 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f01043c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01043c6:	0f 89 6c ff ff ff    	jns    f0104338 <vprintfmt+0x5b>
f01043cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01043cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01043d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01043d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01043d8:	e9 5b ff ff ff       	jmp    f0104338 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01043dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f01043e0:	e9 53 ff ff ff       	jmp    f0104338 <vprintfmt+0x5b>
f01043e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01043e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01043eb:	8d 50 04             	lea    0x4(%eax),%edx
f01043ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01043f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01043f5:	8b 00                	mov    (%eax),%eax
f01043f7:	89 04 24             	mov    %eax,(%esp)
f01043fa:	ff d7                	call   *%edi
f01043fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01043ff:	e9 05 ff ff ff       	jmp    f0104309 <vprintfmt+0x2c>
f0104404:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104407:	8b 45 14             	mov    0x14(%ebp),%eax
f010440a:	8d 50 04             	lea    0x4(%eax),%edx
f010440d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104410:	8b 00                	mov    (%eax),%eax
f0104412:	89 c2                	mov    %eax,%edx
f0104414:	c1 fa 1f             	sar    $0x1f,%edx
f0104417:	31 d0                	xor    %edx,%eax
f0104419:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010441b:	83 f8 08             	cmp    $0x8,%eax
f010441e:	7f 0b                	jg     f010442b <vprintfmt+0x14e>
f0104420:	8b 14 85 e0 6b 10 f0 	mov    -0xfef9420(,%eax,4),%edx
f0104427:	85 d2                	test   %edx,%edx
f0104429:	75 20                	jne    f010444b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
f010442b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010442f:	c7 44 24 08 db 69 10 	movl   $0xf01069db,0x8(%esp)
f0104436:	f0 
f0104437:	89 74 24 04          	mov    %esi,0x4(%esp)
f010443b:	89 3c 24             	mov    %edi,(%esp)
f010443e:	e8 4e 03 00 00       	call   f0104791 <printfmt>
f0104443:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104446:	e9 be fe ff ff       	jmp    f0104309 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f010444b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010444f:	c7 44 24 08 e5 62 10 	movl   $0xf01062e5,0x8(%esp)
f0104456:	f0 
f0104457:	89 74 24 04          	mov    %esi,0x4(%esp)
f010445b:	89 3c 24             	mov    %edi,(%esp)
f010445e:	e8 2e 03 00 00       	call   f0104791 <printfmt>
f0104463:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104466:	e9 9e fe ff ff       	jmp    f0104309 <vprintfmt+0x2c>
f010446b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010446e:	89 c3                	mov    %eax,%ebx
f0104470:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104476:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104479:	8b 45 14             	mov    0x14(%ebp),%eax
f010447c:	8d 50 04             	lea    0x4(%eax),%edx
f010447f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104482:	8b 00                	mov    (%eax),%eax
f0104484:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104487:	85 c0                	test   %eax,%eax
f0104489:	75 07                	jne    f0104492 <vprintfmt+0x1b5>
f010448b:	c7 45 c4 e4 69 10 f0 	movl   $0xf01069e4,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0104492:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0104496:	7e 06                	jle    f010449e <vprintfmt+0x1c1>
f0104498:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010449c:	75 13                	jne    f01044b1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010449e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01044a1:	0f be 02             	movsbl (%edx),%eax
f01044a4:	85 c0                	test   %eax,%eax
f01044a6:	0f 85 99 00 00 00    	jne    f0104545 <vprintfmt+0x268>
f01044ac:	e9 86 00 00 00       	jmp    f0104537 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01044b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01044b5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01044b8:	89 0c 24             	mov    %ecx,(%esp)
f01044bb:	e8 fb 03 00 00       	call   f01048bb <strnlen>
f01044c0:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01044c3:	29 c2                	sub    %eax,%edx
f01044c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01044c8:	85 d2                	test   %edx,%edx
f01044ca:	7e d2                	jle    f010449e <vprintfmt+0x1c1>
					putch(padc, putdat);
f01044cc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f01044d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01044d3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f01044d6:	89 d3                	mov    %edx,%ebx
f01044d8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01044dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01044df:	89 04 24             	mov    %eax,(%esp)
f01044e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01044e4:	83 eb 01             	sub    $0x1,%ebx
f01044e7:	85 db                	test   %ebx,%ebx
f01044e9:	7f ed                	jg     f01044d8 <vprintfmt+0x1fb>
f01044eb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01044ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01044f5:	eb a7                	jmp    f010449e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01044f7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01044fb:	74 18                	je     f0104515 <vprintfmt+0x238>
f01044fd:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104500:	83 fa 5e             	cmp    $0x5e,%edx
f0104503:	76 10                	jbe    f0104515 <vprintfmt+0x238>
					putch('?', putdat);
f0104505:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104509:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104510:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104513:	eb 0a                	jmp    f010451f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0104515:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104519:	89 04 24             	mov    %eax,(%esp)
f010451c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010451f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0104523:	0f be 03             	movsbl (%ebx),%eax
f0104526:	85 c0                	test   %eax,%eax
f0104528:	74 05                	je     f010452f <vprintfmt+0x252>
f010452a:	83 c3 01             	add    $0x1,%ebx
f010452d:	eb 29                	jmp    f0104558 <vprintfmt+0x27b>
f010452f:	89 fe                	mov    %edi,%esi
f0104531:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0104534:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010453b:	7f 2e                	jg     f010456b <vprintfmt+0x28e>
f010453d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104540:	e9 c4 fd ff ff       	jmp    f0104309 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104545:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104548:	83 c2 01             	add    $0x1,%edx
f010454b:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010454e:	89 f7                	mov    %esi,%edi
f0104550:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104553:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104556:	89 d3                	mov    %edx,%ebx
f0104558:	85 f6                	test   %esi,%esi
f010455a:	78 9b                	js     f01044f7 <vprintfmt+0x21a>
f010455c:	83 ee 01             	sub    $0x1,%esi
f010455f:	79 96                	jns    f01044f7 <vprintfmt+0x21a>
f0104561:	89 fe                	mov    %edi,%esi
f0104563:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0104566:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104569:	eb cc                	jmp    f0104537 <vprintfmt+0x25a>
f010456b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010456e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104571:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010457c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010457e:	83 eb 01             	sub    $0x1,%ebx
f0104581:	85 db                	test   %ebx,%ebx
f0104583:	7f ec                	jg     f0104571 <vprintfmt+0x294>
f0104585:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104588:	e9 7c fd ff ff       	jmp    f0104309 <vprintfmt+0x2c>
f010458d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104590:	83 f9 01             	cmp    $0x1,%ecx
f0104593:	7e 16                	jle    f01045ab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
f0104595:	8b 45 14             	mov    0x14(%ebp),%eax
f0104598:	8d 50 08             	lea    0x8(%eax),%edx
f010459b:	89 55 14             	mov    %edx,0x14(%ebp)
f010459e:	8b 10                	mov    (%eax),%edx
f01045a0:	8b 48 04             	mov    0x4(%eax),%ecx
f01045a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01045a6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01045a9:	eb 32                	jmp    f01045dd <vprintfmt+0x300>
	else if (lflag)
f01045ab:	85 c9                	test   %ecx,%ecx
f01045ad:	74 18                	je     f01045c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
f01045af:	8b 45 14             	mov    0x14(%ebp),%eax
f01045b2:	8d 50 04             	lea    0x4(%eax),%edx
f01045b5:	89 55 14             	mov    %edx,0x14(%ebp)
f01045b8:	8b 00                	mov    (%eax),%eax
f01045ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01045bd:	89 c1                	mov    %eax,%ecx
f01045bf:	c1 f9 1f             	sar    $0x1f,%ecx
f01045c2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01045c5:	eb 16                	jmp    f01045dd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
f01045c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01045ca:	8d 50 04             	lea    0x4(%eax),%edx
f01045cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01045d0:	8b 00                	mov    (%eax),%eax
f01045d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01045d5:	89 c2                	mov    %eax,%edx
f01045d7:	c1 fa 1f             	sar    $0x1f,%edx
f01045da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01045dd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01045e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01045e3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01045e8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01045ec:	0f 89 b8 00 00 00    	jns    f01046aa <vprintfmt+0x3cd>
				putch('-', putdat);
f01045f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01045f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01045fd:	ff d7                	call   *%edi
				num = -(long long) num;
f01045ff:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104602:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104605:	f7 d9                	neg    %ecx
f0104607:	83 d3 00             	adc    $0x0,%ebx
f010460a:	f7 db                	neg    %ebx
f010460c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104611:	e9 94 00 00 00       	jmp    f01046aa <vprintfmt+0x3cd>
f0104616:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104619:	89 ca                	mov    %ecx,%edx
f010461b:	8d 45 14             	lea    0x14(%ebp),%eax
f010461e:	e8 63 fc ff ff       	call   f0104286 <getuint>
f0104623:	89 c1                	mov    %eax,%ecx
f0104625:	89 d3                	mov    %edx,%ebx
f0104627:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f010462c:	eb 7c                	jmp    f01046aa <vprintfmt+0x3cd>
f010462e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0104631:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104635:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010463c:	ff d7                	call   *%edi
			putch('X', putdat);
f010463e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104642:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104649:	ff d7                	call   *%edi
			putch('X', putdat);
f010464b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010464f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104656:	ff d7                	call   *%edi
f0104658:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f010465b:	e9 a9 fc ff ff       	jmp    f0104309 <vprintfmt+0x2c>
f0104660:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0104663:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104667:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010466e:	ff d7                	call   *%edi
			putch('x', putdat);
f0104670:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104674:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010467b:	ff d7                	call   *%edi
			num = (unsigned long long)
f010467d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104680:	8d 50 04             	lea    0x4(%eax),%edx
f0104683:	89 55 14             	mov    %edx,0x14(%ebp)
f0104686:	8b 08                	mov    (%eax),%ecx
f0104688:	bb 00 00 00 00       	mov    $0x0,%ebx
f010468d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104692:	eb 16                	jmp    f01046aa <vprintfmt+0x3cd>
f0104694:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104697:	89 ca                	mov    %ecx,%edx
f0104699:	8d 45 14             	lea    0x14(%ebp),%eax
f010469c:	e8 e5 fb ff ff       	call   f0104286 <getuint>
f01046a1:	89 c1                	mov    %eax,%ecx
f01046a3:	89 d3                	mov    %edx,%ebx
f01046a5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01046aa:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01046ae:	89 54 24 10          	mov    %edx,0x10(%esp)
f01046b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01046b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046bd:	89 0c 24             	mov    %ecx,(%esp)
f01046c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01046c4:	89 f2                	mov    %esi,%edx
f01046c6:	89 f8                	mov    %edi,%eax
f01046c8:	e8 c3 fa ff ff       	call   f0104190 <printnum>
f01046cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01046d0:	e9 34 fc ff ff       	jmp    f0104309 <vprintfmt+0x2c>
f01046d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01046d8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01046db:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046df:	89 14 24             	mov    %edx,(%esp)
f01046e2:	ff d7                	call   *%edi
f01046e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01046e7:	e9 1d fc ff ff       	jmp    f0104309 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01046ec:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046f0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01046f7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01046f9:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01046fc:	80 38 25             	cmpb   $0x25,(%eax)
f01046ff:	0f 84 04 fc ff ff    	je     f0104309 <vprintfmt+0x2c>
f0104705:	89 c3                	mov    %eax,%ebx
f0104707:	eb f0                	jmp    f01046f9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
f0104709:	83 c4 5c             	add    $0x5c,%esp
f010470c:	5b                   	pop    %ebx
f010470d:	5e                   	pop    %esi
f010470e:	5f                   	pop    %edi
f010470f:	5d                   	pop    %ebp
f0104710:	c3                   	ret    

f0104711 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104711:	55                   	push   %ebp
f0104712:	89 e5                	mov    %esp,%ebp
f0104714:	83 ec 28             	sub    $0x28,%esp
f0104717:	8b 45 08             	mov    0x8(%ebp),%eax
f010471a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f010471d:	85 c0                	test   %eax,%eax
f010471f:	74 04                	je     f0104725 <vsnprintf+0x14>
f0104721:	85 d2                	test   %edx,%edx
f0104723:	7f 07                	jg     f010472c <vsnprintf+0x1b>
f0104725:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010472a:	eb 3b                	jmp    f0104767 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f010472c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010472f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0104733:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010473d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104740:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104744:	8b 45 10             	mov    0x10(%ebp),%eax
f0104747:	89 44 24 08          	mov    %eax,0x8(%esp)
f010474b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010474e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104752:	c7 04 24 c0 42 10 f0 	movl   $0xf01042c0,(%esp)
f0104759:	e8 7f fb ff ff       	call   f01042dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010475e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104761:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104767:	c9                   	leave  
f0104768:	c3                   	ret    

f0104769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104769:	55                   	push   %ebp
f010476a:	89 e5                	mov    %esp,%ebp
f010476c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f010476f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0104772:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104776:	8b 45 10             	mov    0x10(%ebp),%eax
f0104779:	89 44 24 08          	mov    %eax,0x8(%esp)
f010477d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104780:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104784:	8b 45 08             	mov    0x8(%ebp),%eax
f0104787:	89 04 24             	mov    %eax,(%esp)
f010478a:	e8 82 ff ff ff       	call   f0104711 <vsnprintf>
	va_end(ap);

	return rc;
}
f010478f:	c9                   	leave  
f0104790:	c3                   	ret    

f0104791 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104791:	55                   	push   %ebp
f0104792:	89 e5                	mov    %esp,%ebp
f0104794:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0104797:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f010479a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010479e:	8b 45 10             	mov    0x10(%ebp),%eax
f01047a1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01047af:	89 04 24             	mov    %eax,(%esp)
f01047b2:	e8 26 fb ff ff       	call   f01042dd <vprintfmt>
	va_end(ap);
}
f01047b7:	c9                   	leave  
f01047b8:	c3                   	ret    
f01047b9:	00 00                	add    %al,(%eax)
f01047bb:	00 00                	add    %al,(%eax)
f01047bd:	00 00                	add    %al,(%eax)
	...

f01047c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01047c0:	55                   	push   %ebp
f01047c1:	89 e5                	mov    %esp,%ebp
f01047c3:	57                   	push   %edi
f01047c4:	56                   	push   %esi
f01047c5:	53                   	push   %ebx
f01047c6:	83 ec 1c             	sub    $0x1c,%esp
f01047c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01047cc:	85 c0                	test   %eax,%eax
f01047ce:	74 10                	je     f01047e0 <readline+0x20>
		cprintf("%s", prompt);
f01047d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047d4:	c7 04 24 e5 62 10 f0 	movl   $0xf01062e5,(%esp)
f01047db:	e8 1b e9 ff ff       	call   f01030fb <cprintf>

	i = 0;
	echoing = iscons(0);
f01047e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01047e7:	e8 ba bc ff ff       	call   f01004a6 <iscons>
f01047ec:	89 c7                	mov    %eax,%edi
f01047ee:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01047f3:	e8 9d bc ff ff       	call   f0100495 <getchar>
f01047f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01047fa:	85 c0                	test   %eax,%eax
f01047fc:	79 17                	jns    f0104815 <readline+0x55>
			cprintf("read error: %e\n", c);
f01047fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104802:	c7 04 24 04 6c 10 f0 	movl   $0xf0106c04,(%esp)
f0104809:	e8 ed e8 ff ff       	call   f01030fb <cprintf>
f010480e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0104813:	eb 76                	jmp    f010488b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104815:	83 f8 08             	cmp    $0x8,%eax
f0104818:	74 08                	je     f0104822 <readline+0x62>
f010481a:	83 f8 7f             	cmp    $0x7f,%eax
f010481d:	8d 76 00             	lea    0x0(%esi),%esi
f0104820:	75 19                	jne    f010483b <readline+0x7b>
f0104822:	85 f6                	test   %esi,%esi
f0104824:	7e 15                	jle    f010483b <readline+0x7b>
			if (echoing)
f0104826:	85 ff                	test   %edi,%edi
f0104828:	74 0c                	je     f0104836 <readline+0x76>
				cputchar('\b');
f010482a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104831:	e8 74 be ff ff       	call   f01006aa <cputchar>
			i--;
f0104836:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104839:	eb b8                	jmp    f01047f3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010483b:	83 fb 1f             	cmp    $0x1f,%ebx
f010483e:	66 90                	xchg   %ax,%ax
f0104840:	7e 23                	jle    f0104865 <readline+0xa5>
f0104842:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104848:	7f 1b                	jg     f0104865 <readline+0xa5>
			if (echoing)
f010484a:	85 ff                	test   %edi,%edi
f010484c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104850:	74 08                	je     f010485a <readline+0x9a>
				cputchar(c);
f0104852:	89 1c 24             	mov    %ebx,(%esp)
f0104855:	e8 50 be ff ff       	call   f01006aa <cputchar>
			buf[i++] = c;
f010485a:	88 9e 00 3b 23 f0    	mov    %bl,-0xfdcc500(%esi)
f0104860:	83 c6 01             	add    $0x1,%esi
f0104863:	eb 8e                	jmp    f01047f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104865:	83 fb 0a             	cmp    $0xa,%ebx
f0104868:	74 05                	je     f010486f <readline+0xaf>
f010486a:	83 fb 0d             	cmp    $0xd,%ebx
f010486d:	75 84                	jne    f01047f3 <readline+0x33>
			if (echoing)
f010486f:	85 ff                	test   %edi,%edi
f0104871:	74 0c                	je     f010487f <readline+0xbf>
				cputchar('\n');
f0104873:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010487a:	e8 2b be ff ff       	call   f01006aa <cputchar>
			buf[i] = 0;
f010487f:	c6 86 00 3b 23 f0 00 	movb   $0x0,-0xfdcc500(%esi)
f0104886:	b8 00 3b 23 f0       	mov    $0xf0233b00,%eax
			return buf;
		}
	}
}
f010488b:	83 c4 1c             	add    $0x1c,%esp
f010488e:	5b                   	pop    %ebx
f010488f:	5e                   	pop    %esi
f0104890:	5f                   	pop    %edi
f0104891:	5d                   	pop    %ebp
f0104892:	c3                   	ret    
	...

f01048a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01048a0:	55                   	push   %ebp
f01048a1:	89 e5                	mov    %esp,%ebp
f01048a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01048a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ab:	80 3a 00             	cmpb   $0x0,(%edx)
f01048ae:	74 09                	je     f01048b9 <strlen+0x19>
		n++;
f01048b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01048b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01048b7:	75 f7                	jne    f01048b0 <strlen+0x10>
		n++;
	return n;
}
f01048b9:	5d                   	pop    %ebp
f01048ba:	c3                   	ret    

f01048bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01048bb:	55                   	push   %ebp
f01048bc:	89 e5                	mov    %esp,%ebp
f01048be:	53                   	push   %ebx
f01048bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01048c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01048c5:	85 c9                	test   %ecx,%ecx
f01048c7:	74 19                	je     f01048e2 <strnlen+0x27>
f01048c9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01048cc:	74 14                	je     f01048e2 <strnlen+0x27>
f01048ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01048d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01048d6:	39 c8                	cmp    %ecx,%eax
f01048d8:	74 0d                	je     f01048e7 <strnlen+0x2c>
f01048da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01048de:	75 f3                	jne    f01048d3 <strnlen+0x18>
f01048e0:	eb 05                	jmp    f01048e7 <strnlen+0x2c>
f01048e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01048e7:	5b                   	pop    %ebx
f01048e8:	5d                   	pop    %ebp
f01048e9:	c3                   	ret    

f01048ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01048ea:	55                   	push   %ebp
f01048eb:	89 e5                	mov    %esp,%ebp
f01048ed:	53                   	push   %ebx
f01048ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01048f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01048f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01048f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01048fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104900:	83 c2 01             	add    $0x1,%edx
f0104903:	84 c9                	test   %cl,%cl
f0104905:	75 f2                	jne    f01048f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104907:	5b                   	pop    %ebx
f0104908:	5d                   	pop    %ebp
f0104909:	c3                   	ret    

f010490a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010490a:	55                   	push   %ebp
f010490b:	89 e5                	mov    %esp,%ebp
f010490d:	53                   	push   %ebx
f010490e:	83 ec 08             	sub    $0x8,%esp
f0104911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104914:	89 1c 24             	mov    %ebx,(%esp)
f0104917:	e8 84 ff ff ff       	call   f01048a0 <strlen>
	strcpy(dst + len, src);
f010491c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010491f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104923:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0104926:	89 04 24             	mov    %eax,(%esp)
f0104929:	e8 bc ff ff ff       	call   f01048ea <strcpy>
	return dst;
}
f010492e:	89 d8                	mov    %ebx,%eax
f0104930:	83 c4 08             	add    $0x8,%esp
f0104933:	5b                   	pop    %ebx
f0104934:	5d                   	pop    %ebp
f0104935:	c3                   	ret    

f0104936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104936:	55                   	push   %ebp
f0104937:	89 e5                	mov    %esp,%ebp
f0104939:	56                   	push   %esi
f010493a:	53                   	push   %ebx
f010493b:	8b 45 08             	mov    0x8(%ebp),%eax
f010493e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104941:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104944:	85 f6                	test   %esi,%esi
f0104946:	74 18                	je     f0104960 <strncpy+0x2a>
f0104948:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010494d:	0f b6 1a             	movzbl (%edx),%ebx
f0104950:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104953:	80 3a 01             	cmpb   $0x1,(%edx)
f0104956:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104959:	83 c1 01             	add    $0x1,%ecx
f010495c:	39 ce                	cmp    %ecx,%esi
f010495e:	77 ed                	ja     f010494d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104960:	5b                   	pop    %ebx
f0104961:	5e                   	pop    %esi
f0104962:	5d                   	pop    %ebp
f0104963:	c3                   	ret    

f0104964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104964:	55                   	push   %ebp
f0104965:	89 e5                	mov    %esp,%ebp
f0104967:	56                   	push   %esi
f0104968:	53                   	push   %ebx
f0104969:	8b 75 08             	mov    0x8(%ebp),%esi
f010496c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010496f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104972:	89 f0                	mov    %esi,%eax
f0104974:	85 c9                	test   %ecx,%ecx
f0104976:	74 27                	je     f010499f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0104978:	83 e9 01             	sub    $0x1,%ecx
f010497b:	74 1d                	je     f010499a <strlcpy+0x36>
f010497d:	0f b6 1a             	movzbl (%edx),%ebx
f0104980:	84 db                	test   %bl,%bl
f0104982:	74 16                	je     f010499a <strlcpy+0x36>
			*dst++ = *src++;
f0104984:	88 18                	mov    %bl,(%eax)
f0104986:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104989:	83 e9 01             	sub    $0x1,%ecx
f010498c:	74 0e                	je     f010499c <strlcpy+0x38>
			*dst++ = *src++;
f010498e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104991:	0f b6 1a             	movzbl (%edx),%ebx
f0104994:	84 db                	test   %bl,%bl
f0104996:	75 ec                	jne    f0104984 <strlcpy+0x20>
f0104998:	eb 02                	jmp    f010499c <strlcpy+0x38>
f010499a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010499c:	c6 00 00             	movb   $0x0,(%eax)
f010499f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01049a1:	5b                   	pop    %ebx
f01049a2:	5e                   	pop    %esi
f01049a3:	5d                   	pop    %ebp
f01049a4:	c3                   	ret    

f01049a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01049a5:	55                   	push   %ebp
f01049a6:	89 e5                	mov    %esp,%ebp
f01049a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01049ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01049ae:	0f b6 01             	movzbl (%ecx),%eax
f01049b1:	84 c0                	test   %al,%al
f01049b3:	74 15                	je     f01049ca <strcmp+0x25>
f01049b5:	3a 02                	cmp    (%edx),%al
f01049b7:	75 11                	jne    f01049ca <strcmp+0x25>
		p++, q++;
f01049b9:	83 c1 01             	add    $0x1,%ecx
f01049bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01049bf:	0f b6 01             	movzbl (%ecx),%eax
f01049c2:	84 c0                	test   %al,%al
f01049c4:	74 04                	je     f01049ca <strcmp+0x25>
f01049c6:	3a 02                	cmp    (%edx),%al
f01049c8:	74 ef                	je     f01049b9 <strcmp+0x14>
f01049ca:	0f b6 c0             	movzbl %al,%eax
f01049cd:	0f b6 12             	movzbl (%edx),%edx
f01049d0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01049d2:	5d                   	pop    %ebp
f01049d3:	c3                   	ret    

f01049d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01049d4:	55                   	push   %ebp
f01049d5:	89 e5                	mov    %esp,%ebp
f01049d7:	53                   	push   %ebx
f01049d8:	8b 55 08             	mov    0x8(%ebp),%edx
f01049db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01049de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01049e1:	85 c0                	test   %eax,%eax
f01049e3:	74 23                	je     f0104a08 <strncmp+0x34>
f01049e5:	0f b6 1a             	movzbl (%edx),%ebx
f01049e8:	84 db                	test   %bl,%bl
f01049ea:	74 25                	je     f0104a11 <strncmp+0x3d>
f01049ec:	3a 19                	cmp    (%ecx),%bl
f01049ee:	75 21                	jne    f0104a11 <strncmp+0x3d>
f01049f0:	83 e8 01             	sub    $0x1,%eax
f01049f3:	74 13                	je     f0104a08 <strncmp+0x34>
		n--, p++, q++;
f01049f5:	83 c2 01             	add    $0x1,%edx
f01049f8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01049fb:	0f b6 1a             	movzbl (%edx),%ebx
f01049fe:	84 db                	test   %bl,%bl
f0104a00:	74 0f                	je     f0104a11 <strncmp+0x3d>
f0104a02:	3a 19                	cmp    (%ecx),%bl
f0104a04:	74 ea                	je     f01049f0 <strncmp+0x1c>
f0104a06:	eb 09                	jmp    f0104a11 <strncmp+0x3d>
f0104a08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104a0d:	5b                   	pop    %ebx
f0104a0e:	5d                   	pop    %ebp
f0104a0f:	90                   	nop
f0104a10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a11:	0f b6 02             	movzbl (%edx),%eax
f0104a14:	0f b6 11             	movzbl (%ecx),%edx
f0104a17:	29 d0                	sub    %edx,%eax
f0104a19:	eb f2                	jmp    f0104a0d <strncmp+0x39>

f0104a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104a1b:	55                   	push   %ebp
f0104a1c:	89 e5                	mov    %esp,%ebp
f0104a1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a25:	0f b6 10             	movzbl (%eax),%edx
f0104a28:	84 d2                	test   %dl,%dl
f0104a2a:	74 18                	je     f0104a44 <strchr+0x29>
		if (*s == c)
f0104a2c:	38 ca                	cmp    %cl,%dl
f0104a2e:	75 0a                	jne    f0104a3a <strchr+0x1f>
f0104a30:	eb 17                	jmp    f0104a49 <strchr+0x2e>
f0104a32:	38 ca                	cmp    %cl,%dl
f0104a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a38:	74 0f                	je     f0104a49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104a3a:	83 c0 01             	add    $0x1,%eax
f0104a3d:	0f b6 10             	movzbl (%eax),%edx
f0104a40:	84 d2                	test   %dl,%dl
f0104a42:	75 ee                	jne    f0104a32 <strchr+0x17>
f0104a44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0104a49:	5d                   	pop    %ebp
f0104a4a:	c3                   	ret    

f0104a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104a4b:	55                   	push   %ebp
f0104a4c:	89 e5                	mov    %esp,%ebp
f0104a4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a55:	0f b6 10             	movzbl (%eax),%edx
f0104a58:	84 d2                	test   %dl,%dl
f0104a5a:	74 18                	je     f0104a74 <strfind+0x29>
		if (*s == c)
f0104a5c:	38 ca                	cmp    %cl,%dl
f0104a5e:	75 0a                	jne    f0104a6a <strfind+0x1f>
f0104a60:	eb 12                	jmp    f0104a74 <strfind+0x29>
f0104a62:	38 ca                	cmp    %cl,%dl
f0104a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a68:	74 0a                	je     f0104a74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104a6a:	83 c0 01             	add    $0x1,%eax
f0104a6d:	0f b6 10             	movzbl (%eax),%edx
f0104a70:	84 d2                	test   %dl,%dl
f0104a72:	75 ee                	jne    f0104a62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104a74:	5d                   	pop    %ebp
f0104a75:	c3                   	ret    

f0104a76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104a76:	55                   	push   %ebp
f0104a77:	89 e5                	mov    %esp,%ebp
f0104a79:	83 ec 0c             	sub    $0xc,%esp
f0104a7c:	89 1c 24             	mov    %ebx,(%esp)
f0104a7f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104a83:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104a87:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104a90:	85 c9                	test   %ecx,%ecx
f0104a92:	74 30                	je     f0104ac4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104a9a:	75 25                	jne    f0104ac1 <memset+0x4b>
f0104a9c:	f6 c1 03             	test   $0x3,%cl
f0104a9f:	75 20                	jne    f0104ac1 <memset+0x4b>
		c &= 0xFF;
f0104aa1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104aa4:	89 d3                	mov    %edx,%ebx
f0104aa6:	c1 e3 08             	shl    $0x8,%ebx
f0104aa9:	89 d6                	mov    %edx,%esi
f0104aab:	c1 e6 18             	shl    $0x18,%esi
f0104aae:	89 d0                	mov    %edx,%eax
f0104ab0:	c1 e0 10             	shl    $0x10,%eax
f0104ab3:	09 f0                	or     %esi,%eax
f0104ab5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0104ab7:	09 d8                	or     %ebx,%eax
f0104ab9:	c1 e9 02             	shr    $0x2,%ecx
f0104abc:	fc                   	cld    
f0104abd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104abf:	eb 03                	jmp    f0104ac4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104ac1:	fc                   	cld    
f0104ac2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104ac4:	89 f8                	mov    %edi,%eax
f0104ac6:	8b 1c 24             	mov    (%esp),%ebx
f0104ac9:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104acd:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104ad1:	89 ec                	mov    %ebp,%esp
f0104ad3:	5d                   	pop    %ebp
f0104ad4:	c3                   	ret    

f0104ad5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104ad5:	55                   	push   %ebp
f0104ad6:	89 e5                	mov    %esp,%ebp
f0104ad8:	83 ec 08             	sub    $0x8,%esp
f0104adb:	89 34 24             	mov    %esi,(%esp)
f0104ade:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ae2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0104ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0104aeb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0104aed:	39 c6                	cmp    %eax,%esi
f0104aef:	73 35                	jae    f0104b26 <memmove+0x51>
f0104af1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104af4:	39 d0                	cmp    %edx,%eax
f0104af6:	73 2e                	jae    f0104b26 <memmove+0x51>
		s += n;
		d += n;
f0104af8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104afa:	f6 c2 03             	test   $0x3,%dl
f0104afd:	75 1b                	jne    f0104b1a <memmove+0x45>
f0104aff:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104b05:	75 13                	jne    f0104b1a <memmove+0x45>
f0104b07:	f6 c1 03             	test   $0x3,%cl
f0104b0a:	75 0e                	jne    f0104b1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0104b0c:	83 ef 04             	sub    $0x4,%edi
f0104b0f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104b12:	c1 e9 02             	shr    $0x2,%ecx
f0104b15:	fd                   	std    
f0104b16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b18:	eb 09                	jmp    f0104b23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104b1a:	83 ef 01             	sub    $0x1,%edi
f0104b1d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104b20:	fd                   	std    
f0104b21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104b23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104b24:	eb 20                	jmp    f0104b46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b26:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104b2c:	75 15                	jne    f0104b43 <memmove+0x6e>
f0104b2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104b34:	75 0d                	jne    f0104b43 <memmove+0x6e>
f0104b36:	f6 c1 03             	test   $0x3,%cl
f0104b39:	75 08                	jne    f0104b43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0104b3b:	c1 e9 02             	shr    $0x2,%ecx
f0104b3e:	fc                   	cld    
f0104b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b41:	eb 03                	jmp    f0104b46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104b43:	fc                   	cld    
f0104b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104b46:	8b 34 24             	mov    (%esp),%esi
f0104b49:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104b4d:	89 ec                	mov    %ebp,%esp
f0104b4f:	5d                   	pop    %ebp
f0104b50:	c3                   	ret    

f0104b51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104b51:	55                   	push   %ebp
f0104b52:	89 e5                	mov    %esp,%ebp
f0104b54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104b57:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b5a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b65:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b68:	89 04 24             	mov    %eax,(%esp)
f0104b6b:	e8 65 ff ff ff       	call   f0104ad5 <memmove>
}
f0104b70:	c9                   	leave  
f0104b71:	c3                   	ret    

f0104b72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104b72:	55                   	push   %ebp
f0104b73:	89 e5                	mov    %esp,%ebp
f0104b75:	57                   	push   %edi
f0104b76:	56                   	push   %esi
f0104b77:	53                   	push   %ebx
f0104b78:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104b81:	85 c9                	test   %ecx,%ecx
f0104b83:	74 36                	je     f0104bbb <memcmp+0x49>
		if (*s1 != *s2)
f0104b85:	0f b6 06             	movzbl (%esi),%eax
f0104b88:	0f b6 1f             	movzbl (%edi),%ebx
f0104b8b:	38 d8                	cmp    %bl,%al
f0104b8d:	74 20                	je     f0104baf <memcmp+0x3d>
f0104b8f:	eb 14                	jmp    f0104ba5 <memcmp+0x33>
f0104b91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0104b96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0104b9b:	83 c2 01             	add    $0x1,%edx
f0104b9e:	83 e9 01             	sub    $0x1,%ecx
f0104ba1:	38 d8                	cmp    %bl,%al
f0104ba3:	74 12                	je     f0104bb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0104ba5:	0f b6 c0             	movzbl %al,%eax
f0104ba8:	0f b6 db             	movzbl %bl,%ebx
f0104bab:	29 d8                	sub    %ebx,%eax
f0104bad:	eb 11                	jmp    f0104bc0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104baf:	83 e9 01             	sub    $0x1,%ecx
f0104bb2:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bb7:	85 c9                	test   %ecx,%ecx
f0104bb9:	75 d6                	jne    f0104b91 <memcmp+0x1f>
f0104bbb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0104bc0:	5b                   	pop    %ebx
f0104bc1:	5e                   	pop    %esi
f0104bc2:	5f                   	pop    %edi
f0104bc3:	5d                   	pop    %ebp
f0104bc4:	c3                   	ret    

f0104bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104bc5:	55                   	push   %ebp
f0104bc6:	89 e5                	mov    %esp,%ebp
f0104bc8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104bcb:	89 c2                	mov    %eax,%edx
f0104bcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104bd0:	39 d0                	cmp    %edx,%eax
f0104bd2:	73 15                	jae    f0104be9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104bd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104bd8:	38 08                	cmp    %cl,(%eax)
f0104bda:	75 06                	jne    f0104be2 <memfind+0x1d>
f0104bdc:	eb 0b                	jmp    f0104be9 <memfind+0x24>
f0104bde:	38 08                	cmp    %cl,(%eax)
f0104be0:	74 07                	je     f0104be9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104be2:	83 c0 01             	add    $0x1,%eax
f0104be5:	39 c2                	cmp    %eax,%edx
f0104be7:	77 f5                	ja     f0104bde <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104be9:	5d                   	pop    %ebp
f0104bea:	c3                   	ret    

f0104beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104beb:	55                   	push   %ebp
f0104bec:	89 e5                	mov    %esp,%ebp
f0104bee:	57                   	push   %edi
f0104bef:	56                   	push   %esi
f0104bf0:	53                   	push   %ebx
f0104bf1:	83 ec 04             	sub    $0x4,%esp
f0104bf4:	8b 55 08             	mov    0x8(%ebp),%edx
f0104bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104bfa:	0f b6 02             	movzbl (%edx),%eax
f0104bfd:	3c 20                	cmp    $0x20,%al
f0104bff:	74 04                	je     f0104c05 <strtol+0x1a>
f0104c01:	3c 09                	cmp    $0x9,%al
f0104c03:	75 0e                	jne    f0104c13 <strtol+0x28>
		s++;
f0104c05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104c08:	0f b6 02             	movzbl (%edx),%eax
f0104c0b:	3c 20                	cmp    $0x20,%al
f0104c0d:	74 f6                	je     f0104c05 <strtol+0x1a>
f0104c0f:	3c 09                	cmp    $0x9,%al
f0104c11:	74 f2                	je     f0104c05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104c13:	3c 2b                	cmp    $0x2b,%al
f0104c15:	75 0c                	jne    f0104c23 <strtol+0x38>
		s++;
f0104c17:	83 c2 01             	add    $0x1,%edx
f0104c1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104c21:	eb 15                	jmp    f0104c38 <strtol+0x4d>
	else if (*s == '-')
f0104c23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104c2a:	3c 2d                	cmp    $0x2d,%al
f0104c2c:	75 0a                	jne    f0104c38 <strtol+0x4d>
		s++, neg = 1;
f0104c2e:	83 c2 01             	add    $0x1,%edx
f0104c31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c38:	85 db                	test   %ebx,%ebx
f0104c3a:	0f 94 c0             	sete   %al
f0104c3d:	74 05                	je     f0104c44 <strtol+0x59>
f0104c3f:	83 fb 10             	cmp    $0x10,%ebx
f0104c42:	75 18                	jne    f0104c5c <strtol+0x71>
f0104c44:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c47:	75 13                	jne    f0104c5c <strtol+0x71>
f0104c49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104c4d:	8d 76 00             	lea    0x0(%esi),%esi
f0104c50:	75 0a                	jne    f0104c5c <strtol+0x71>
		s += 2, base = 16;
f0104c52:	83 c2 02             	add    $0x2,%edx
f0104c55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c5a:	eb 15                	jmp    f0104c71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104c5c:	84 c0                	test   %al,%al
f0104c5e:	66 90                	xchg   %ax,%ax
f0104c60:	74 0f                	je     f0104c71 <strtol+0x86>
f0104c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104c67:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c6a:	75 05                	jne    f0104c71 <strtol+0x86>
		s++, base = 8;
f0104c6c:	83 c2 01             	add    $0x1,%edx
f0104c6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104c71:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104c78:	0f b6 0a             	movzbl (%edx),%ecx
f0104c7b:	89 cf                	mov    %ecx,%edi
f0104c7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104c80:	80 fb 09             	cmp    $0x9,%bl
f0104c83:	77 08                	ja     f0104c8d <strtol+0xa2>
			dig = *s - '0';
f0104c85:	0f be c9             	movsbl %cl,%ecx
f0104c88:	83 e9 30             	sub    $0x30,%ecx
f0104c8b:	eb 1e                	jmp    f0104cab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0104c8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0104c90:	80 fb 19             	cmp    $0x19,%bl
f0104c93:	77 08                	ja     f0104c9d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0104c95:	0f be c9             	movsbl %cl,%ecx
f0104c98:	83 e9 57             	sub    $0x57,%ecx
f0104c9b:	eb 0e                	jmp    f0104cab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0104c9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0104ca0:	80 fb 19             	cmp    $0x19,%bl
f0104ca3:	77 15                	ja     f0104cba <strtol+0xcf>
			dig = *s - 'A' + 10;
f0104ca5:	0f be c9             	movsbl %cl,%ecx
f0104ca8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104cab:	39 f1                	cmp    %esi,%ecx
f0104cad:	7d 0b                	jge    f0104cba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0104caf:	83 c2 01             	add    $0x1,%edx
f0104cb2:	0f af c6             	imul   %esi,%eax
f0104cb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104cb8:	eb be                	jmp    f0104c78 <strtol+0x8d>
f0104cba:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0104cbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104cc0:	74 05                	je     f0104cc7 <strtol+0xdc>
		*endptr = (char *) s;
f0104cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104cc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104ccb:	74 04                	je     f0104cd1 <strtol+0xe6>
f0104ccd:	89 c8                	mov    %ecx,%eax
f0104ccf:	f7 d8                	neg    %eax
}
f0104cd1:	83 c4 04             	add    $0x4,%esp
f0104cd4:	5b                   	pop    %ebx
f0104cd5:	5e                   	pop    %esi
f0104cd6:	5f                   	pop    %edi
f0104cd7:	5d                   	pop    %ebp
f0104cd8:	c3                   	ret    
f0104cd9:	00 00                	add    %al,(%eax)
	...

f0104cdc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104cdc:	fa                   	cli    

	xorw    %ax, %ax
f0104cdd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104cdf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104ce1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104ce3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104ce5:	0f 01 16             	lgdtl  (%esi)
f0104ce8:	74 70                	je     f0104d5a <mpentry_end+0x4>
	movl    %cr0, %eax
f0104cea:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104ced:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104cf1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104cf4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104cfa:	08 00                	or     %al,(%eax)

f0104cfc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104cfc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104d00:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104d02:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104d04:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104d06:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104d0a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104d0c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104d0e:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f0104d13:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104d16:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104d19:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104d1e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0104d21:	8b 25 04 3f 23 f0    	mov    0xf0233f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104d27:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104d2c:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f0104d31:	ff d0                	call   *%eax

f0104d33 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104d33:	eb fe                	jmp    f0104d33 <spin>
f0104d35:	8d 76 00             	lea    0x0(%esi),%esi

f0104d38 <gdt>:
	...
f0104d40:	ff                   	(bad)  
f0104d41:	ff 00                	incl   (%eax)
f0104d43:	00 00                	add    %al,(%eax)
f0104d45:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104d4c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0104d50 <gdtdesc>:
f0104d50:	17                   	pop    %ss
f0104d51:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104d56 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104d56:	90                   	nop
	...

f0104d60 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0104d60:	55                   	push   %ebp
f0104d61:	89 e5                	mov    %esp,%ebp
f0104d63:	56                   	push   %esi
f0104d64:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104d65:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d6a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d6f:	85 d2                	test   %edx,%edx
f0104d71:	7e 0d                	jle    f0104d80 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0104d73:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0104d77:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104d79:	83 c1 01             	add    $0x1,%ecx
f0104d7c:	39 d1                	cmp    %edx,%ecx
f0104d7e:	75 f3                	jne    f0104d73 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0104d80:	89 d8                	mov    %ebx,%eax
f0104d82:	5b                   	pop    %ebx
f0104d83:	5e                   	pop    %esi
f0104d84:	5d                   	pop    %ebp
f0104d85:	c3                   	ret    

f0104d86 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104d86:	55                   	push   %ebp
f0104d87:	89 e5                	mov    %esp,%ebp
f0104d89:	56                   	push   %esi
f0104d8a:	53                   	push   %ebx
f0104d8b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104d8e:	8b 0d 08 3f 23 f0    	mov    0xf0233f08,%ecx
f0104d94:	89 c3                	mov    %eax,%ebx
f0104d96:	c1 eb 0c             	shr    $0xc,%ebx
f0104d99:	39 cb                	cmp    %ecx,%ebx
f0104d9b:	72 20                	jb     f0104dbd <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104d9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104da1:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0104da8:	f0 
f0104da9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104db0:	00 
f0104db1:	c7 04 24 a1 6d 10 f0 	movl   $0xf0106da1,(%esp)
f0104db8:	e8 c8 b2 ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104dbd:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104dc0:	89 f2                	mov    %esi,%edx
f0104dc2:	c1 ea 0c             	shr    $0xc,%edx
f0104dc5:	39 d1                	cmp    %edx,%ecx
f0104dc7:	77 20                	ja     f0104de9 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104dc9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104dcd:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0104dd4:	f0 
f0104dd5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104ddc:	00 
f0104ddd:	c7 04 24 a1 6d 10 f0 	movl   $0xf0106da1,(%esp)
f0104de4:	e8 9c b2 ff ff       	call   f0100085 <_panic>
f0104de9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0104def:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0104df5:	39 f3                	cmp    %esi,%ebx
f0104df7:	73 33                	jae    f0104e2c <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104df9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0104e00:	00 
f0104e01:	c7 44 24 04 b1 6d 10 	movl   $0xf0106db1,0x4(%esp)
f0104e08:	f0 
f0104e09:	89 1c 24             	mov    %ebx,(%esp)
f0104e0c:	e8 61 fd ff ff       	call   f0104b72 <memcmp>
f0104e11:	85 c0                	test   %eax,%eax
f0104e13:	75 10                	jne    f0104e25 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0104e15:	ba 10 00 00 00       	mov    $0x10,%edx
f0104e1a:	89 d8                	mov    %ebx,%eax
f0104e1c:	e8 3f ff ff ff       	call   f0104d60 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104e21:	84 c0                	test   %al,%al
f0104e23:	74 0c                	je     f0104e31 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0104e25:	83 c3 10             	add    $0x10,%ebx
f0104e28:	39 de                	cmp    %ebx,%esi
f0104e2a:	77 cd                	ja     f0104df9 <mpsearch1+0x73>
f0104e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0104e31:	89 d8                	mov    %ebx,%eax
f0104e33:	83 c4 10             	add    $0x10,%esp
f0104e36:	5b                   	pop    %ebx
f0104e37:	5e                   	pop    %esi
f0104e38:	5d                   	pop    %ebp
f0104e39:	c3                   	ret    

f0104e3a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104e3a:	55                   	push   %ebp
f0104e3b:	89 e5                	mov    %esp,%ebp
f0104e3d:	57                   	push   %edi
f0104e3e:	56                   	push   %esi
f0104e3f:	53                   	push   %ebx
f0104e40:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104e43:	c7 05 c0 43 23 f0 20 	movl   $0xf0234020,0xf02343c0
f0104e4a:	40 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104e4d:	83 3d 08 3f 23 f0 00 	cmpl   $0x0,0xf0233f08
f0104e54:	75 24                	jne    f0104e7a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104e56:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0104e5d:	00 
f0104e5e:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0104e65:	f0 
f0104e66:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0104e6d:	00 
f0104e6e:	c7 04 24 a1 6d 10 f0 	movl   $0xf0106da1,(%esp)
f0104e75:	e8 0b b2 ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104e7a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104e81:	85 c0                	test   %eax,%eax
f0104e83:	74 16                	je     f0104e9b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0104e85:	c1 e0 04             	shl    $0x4,%eax
f0104e88:	ba 00 04 00 00       	mov    $0x400,%edx
f0104e8d:	e8 f4 fe ff ff       	call   f0104d86 <mpsearch1>
f0104e92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e95:	85 c0                	test   %eax,%eax
f0104e97:	75 3c                	jne    f0104ed5 <mp_init+0x9b>
f0104e99:	eb 20                	jmp    f0104ebb <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104e9b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104ea2:	c1 e0 0a             	shl    $0xa,%eax
f0104ea5:	2d 00 04 00 00       	sub    $0x400,%eax
f0104eaa:	ba 00 04 00 00       	mov    $0x400,%edx
f0104eaf:	e8 d2 fe ff ff       	call   f0104d86 <mpsearch1>
f0104eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104eb7:	85 c0                	test   %eax,%eax
f0104eb9:	75 1a                	jne    f0104ed5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0104ebb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104ec0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104ec5:	e8 bc fe ff ff       	call   f0104d86 <mpsearch1>
f0104eca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0104ecd:	85 c0                	test   %eax,%eax
f0104ecf:	0f 84 27 02 00 00    	je     f01050fc <mp_init+0x2c2>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0104ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ed8:	8b 78 04             	mov    0x4(%eax),%edi
f0104edb:	85 ff                	test   %edi,%edi
f0104edd:	74 06                	je     f0104ee5 <mp_init+0xab>
f0104edf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0104ee3:	74 11                	je     f0104ef6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0104ee5:	c7 04 24 14 6c 10 f0 	movl   $0xf0106c14,(%esp)
f0104eec:	e8 0a e2 ff ff       	call   f01030fb <cprintf>
f0104ef1:	e9 06 02 00 00       	jmp    f01050fc <mp_init+0x2c2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104ef6:	89 f8                	mov    %edi,%eax
f0104ef8:	c1 e8 0c             	shr    $0xc,%eax
f0104efb:	3b 05 08 3f 23 f0    	cmp    0xf0233f08,%eax
f0104f01:	72 20                	jb     f0104f23 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f03:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104f07:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f0104f0e:	f0 
f0104f0f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0104f16:	00 
f0104f17:	c7 04 24 a1 6d 10 f0 	movl   $0xf0106da1,(%esp)
f0104f1e:	e8 62 b1 ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0104f23:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0104f29:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0104f30:	00 
f0104f31:	c7 44 24 04 b6 6d 10 	movl   $0xf0106db6,0x4(%esp)
f0104f38:	f0 
f0104f39:	89 3c 24             	mov    %edi,(%esp)
f0104f3c:	e8 31 fc ff ff       	call   f0104b72 <memcmp>
f0104f41:	85 c0                	test   %eax,%eax
f0104f43:	74 11                	je     f0104f56 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0104f45:	c7 04 24 44 6c 10 f0 	movl   $0xf0106c44,(%esp)
f0104f4c:	e8 aa e1 ff ff       	call   f01030fb <cprintf>
f0104f51:	e9 a6 01 00 00       	jmp    f01050fc <mp_init+0x2c2>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0104f56:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f0104f5a:	89 f8                	mov    %edi,%eax
f0104f5c:	e8 ff fd ff ff       	call   f0104d60 <sum>
f0104f61:	84 c0                	test   %al,%al
f0104f63:	74 11                	je     f0104f76 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104f65:	c7 04 24 78 6c 10 f0 	movl   $0xf0106c78,(%esp)
f0104f6c:	e8 8a e1 ff ff       	call   f01030fb <cprintf>
f0104f71:	e9 86 01 00 00       	jmp    f01050fc <mp_init+0x2c2>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0104f76:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0104f7a:	3c 01                	cmp    $0x1,%al
f0104f7c:	74 1c                	je     f0104f9a <mp_init+0x160>
f0104f7e:	3c 04                	cmp    $0x4,%al
f0104f80:	74 18                	je     f0104f9a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104f82:	0f b6 c0             	movzbl %al,%eax
f0104f85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f89:	c7 04 24 9c 6c 10 f0 	movl   $0xf0106c9c,(%esp)
f0104f90:	e8 66 e1 ff ff       	call   f01030fb <cprintf>
f0104f95:	e9 62 01 00 00       	jmp    f01050fc <mp_init+0x2c2>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0104f9a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0104f9e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0104fa2:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0104fa5:	e8 b6 fd ff ff       	call   f0104d60 <sum>
f0104faa:	3a 47 2a             	cmp    0x2a(%edi),%al
f0104fad:	74 11                	je     f0104fc0 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104faf:	c7 04 24 bc 6c 10 f0 	movl   $0xf0106cbc,(%esp)
f0104fb6:	e8 40 e1 ff ff       	call   f01030fb <cprintf>
f0104fbb:	e9 3c 01 00 00       	jmp    f01050fc <mp_init+0x2c2>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0104fc0:	85 ff                	test   %edi,%edi
f0104fc2:	0f 84 34 01 00 00    	je     f01050fc <mp_init+0x2c2>
		return;
	ismp = 1;
f0104fc8:	c7 05 00 40 23 f0 01 	movl   $0x1,0xf0234000
f0104fcf:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0104fd2:	8b 47 24             	mov    0x24(%edi),%eax
f0104fd5:	a3 00 50 27 f0       	mov    %eax,0xf0275000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0104fda:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0104fdf:	0f 84 98 00 00 00    	je     f010507d <mp_init+0x243>
f0104fe5:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0104fe8:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0104fed:	0f b6 03             	movzbl (%ebx),%eax
f0104ff0:	84 c0                	test   %al,%al
f0104ff2:	74 06                	je     f0104ffa <mp_init+0x1c0>
f0104ff4:	3c 04                	cmp    $0x4,%al
f0104ff6:	77 55                	ja     f010504d <mp_init+0x213>
f0104ff8:	eb 4e                	jmp    f0105048 <mp_init+0x20e>
		case MPPROC:
			proc = (struct mpproc *)p;
f0104ffa:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0104ffc:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0105000:	74 11                	je     f0105013 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0105002:	6b 05 c4 43 23 f0 74 	imul   $0x74,0xf02343c4,%eax
f0105009:	05 20 40 23 f0       	add    $0xf0234020,%eax
f010500e:	a3 c0 43 23 f0       	mov    %eax,0xf02343c0
			if (ncpu < NCPU) {
f0105013:	a1 c4 43 23 f0       	mov    0xf02343c4,%eax
f0105018:	83 f8 07             	cmp    $0x7,%eax
f010501b:	7f 12                	jg     f010502f <mp_init+0x1f5>
				cpus[ncpu].cpu_id = ncpu;
f010501d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105020:	88 82 20 40 23 f0    	mov    %al,-0xfdcbfe0(%edx)
				ncpu++;
f0105026:	83 05 c4 43 23 f0 01 	addl   $0x1,0xf02343c4
f010502d:	eb 14                	jmp    f0105043 <mp_init+0x209>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010502f:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105033:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105037:	c7 04 24 ec 6c 10 f0 	movl   $0xf0106cec,(%esp)
f010503e:	e8 b8 e0 ff ff       	call   f01030fb <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105043:	83 c3 14             	add    $0x14,%ebx
			continue;
f0105046:	eb 26                	jmp    f010506e <mp_init+0x234>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105048:	83 c3 08             	add    $0x8,%ebx
			continue;
f010504b:	eb 21                	jmp    f010506e <mp_init+0x234>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010504d:	0f b6 c0             	movzbl %al,%eax
f0105050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105054:	c7 04 24 14 6d 10 f0 	movl   $0xf0106d14,(%esp)
f010505b:	e8 9b e0 ff ff       	call   f01030fb <cprintf>
			ismp = 0;
f0105060:	c7 05 00 40 23 f0 00 	movl   $0x0,0xf0234000
f0105067:	00 00 00 
			i = conf->entry;
f010506a:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010506e:	83 c6 01             	add    $0x1,%esi
f0105071:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105075:	39 f0                	cmp    %esi,%eax
f0105077:	0f 87 70 ff ff ff    	ja     f0104fed <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010507d:	a1 c0 43 23 f0       	mov    0xf02343c0,%eax
f0105082:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105089:	83 3d 00 40 23 f0 00 	cmpl   $0x0,0xf0234000
f0105090:	75 22                	jne    f01050b4 <mp_init+0x27a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105092:	c7 05 c4 43 23 f0 01 	movl   $0x1,0xf02343c4
f0105099:	00 00 00 
		lapic = NULL;
f010509c:	c7 05 00 50 27 f0 00 	movl   $0x0,0xf0275000
f01050a3:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01050a6:	c7 04 24 34 6d 10 f0 	movl   $0xf0106d34,(%esp)
f01050ad:	e8 49 e0 ff ff       	call   f01030fb <cprintf>
		return;
f01050b2:	eb 48                	jmp    f01050fc <mp_init+0x2c2>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01050b4:	a1 c4 43 23 f0       	mov    0xf02343c4,%eax
f01050b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050bd:	a1 c0 43 23 f0       	mov    0xf02343c0,%eax
f01050c2:	0f b6 00             	movzbl (%eax),%eax
f01050c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050c9:	c7 04 24 bb 6d 10 f0 	movl   $0xf0106dbb,(%esp)
f01050d0:	e8 26 e0 ff ff       	call   f01030fb <cprintf>

	if (mp->imcrp) {
f01050d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050d8:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01050dc:	74 1e                	je     f01050fc <mp_init+0x2c2>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01050de:	c7 04 24 60 6d 10 f0 	movl   $0xf0106d60,(%esp)
f01050e5:	e8 11 e0 ff ff       	call   f01030fb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01050ea:	ba 22 00 00 00       	mov    $0x22,%edx
f01050ef:	b8 70 00 00 00       	mov    $0x70,%eax
f01050f4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01050f5:	b2 23                	mov    $0x23,%dl
f01050f7:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01050f8:	83 c8 01             	or     $0x1,%eax
f01050fb:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01050fc:	83 c4 2c             	add    $0x2c,%esp
f01050ff:	5b                   	pop    %ebx
f0105100:	5e                   	pop    %esi
f0105101:	5f                   	pop    %edi
f0105102:	5d                   	pop    %ebp
f0105103:	c3                   	ret    

f0105104 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f0105104:	55                   	push   %ebp
f0105105:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105107:	c1 e0 02             	shl    $0x2,%eax
f010510a:	03 05 00 50 27 f0    	add    0xf0275000,%eax
f0105110:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105112:	a1 00 50 27 f0       	mov    0xf0275000,%eax
f0105117:	83 c0 20             	add    $0x20,%eax
f010511a:	8b 00                	mov    (%eax),%eax
}
f010511c:	5d                   	pop    %ebp
f010511d:	c3                   	ret    

f010511e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010511e:	55                   	push   %ebp
f010511f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105121:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f0105127:	b8 00 00 00 00       	mov    $0x0,%eax
f010512c:	85 d2                	test   %edx,%edx
f010512e:	74 08                	je     f0105138 <cpunum+0x1a>
		return lapic[ID] >> 24;
f0105130:	83 c2 20             	add    $0x20,%edx
f0105133:	8b 02                	mov    (%edx),%eax
f0105135:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0105138:	5d                   	pop    %ebp
f0105139:	c3                   	ret    

f010513a <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010513a:	55                   	push   %ebp
f010513b:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f010513d:	83 3d 00 50 27 f0 00 	cmpl   $0x0,0xf0275000
f0105144:	0f 84 0b 01 00 00    	je     f0105255 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010514a:	ba 27 01 00 00       	mov    $0x127,%edx
f010514f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105154:	e8 ab ff ff ff       	call   f0105104 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105159:	ba 0b 00 00 00       	mov    $0xb,%edx
f010515e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105163:	e8 9c ff ff ff       	call   f0105104 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105168:	ba 20 00 02 00       	mov    $0x20020,%edx
f010516d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105172:	e8 8d ff ff ff       	call   f0105104 <lapicw>
	lapicw(TICR, 10000000); 
f0105177:	ba 80 96 98 00       	mov    $0x989680,%edx
f010517c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105181:	e8 7e ff ff ff       	call   f0105104 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105186:	e8 93 ff ff ff       	call   f010511e <cpunum>
f010518b:	6b c0 74             	imul   $0x74,%eax,%eax
f010518e:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0105193:	39 05 c0 43 23 f0    	cmp    %eax,0xf02343c0
f0105199:	74 0f                	je     f01051aa <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010519b:	ba 00 00 01 00       	mov    $0x10000,%edx
f01051a0:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01051a5:	e8 5a ff ff ff       	call   f0105104 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01051aa:	ba 00 00 01 00       	mov    $0x10000,%edx
f01051af:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01051b4:	e8 4b ff ff ff       	call   f0105104 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01051b9:	a1 00 50 27 f0       	mov    0xf0275000,%eax
f01051be:	83 c0 30             	add    $0x30,%eax
f01051c1:	8b 00                	mov    (%eax),%eax
f01051c3:	c1 e8 10             	shr    $0x10,%eax
f01051c6:	3c 03                	cmp    $0x3,%al
f01051c8:	76 0f                	jbe    f01051d9 <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f01051ca:	ba 00 00 01 00       	mov    $0x10000,%edx
f01051cf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01051d4:	e8 2b ff ff ff       	call   f0105104 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01051d9:	ba 33 00 00 00       	mov    $0x33,%edx
f01051de:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01051e3:	e8 1c ff ff ff       	call   f0105104 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01051e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01051ed:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01051f2:	e8 0d ff ff ff       	call   f0105104 <lapicw>
	lapicw(ESR, 0);
f01051f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01051fc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105201:	e8 fe fe ff ff       	call   f0105104 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105206:	ba 00 00 00 00       	mov    $0x0,%edx
f010520b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105210:	e8 ef fe ff ff       	call   f0105104 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105215:	ba 00 00 00 00       	mov    $0x0,%edx
f010521a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010521f:	e8 e0 fe ff ff       	call   f0105104 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105224:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105229:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010522e:	e8 d1 fe ff ff       	call   f0105104 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105233:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f0105239:	81 c2 00 03 00 00    	add    $0x300,%edx
f010523f:	8b 02                	mov    (%edx),%eax
f0105241:	f6 c4 10             	test   $0x10,%ah
f0105244:	75 f9                	jne    f010523f <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105246:	ba 00 00 00 00       	mov    $0x0,%edx
f010524b:	b8 20 00 00 00       	mov    $0x20,%eax
f0105250:	e8 af fe ff ff       	call   f0105104 <lapicw>
}
f0105255:	5d                   	pop    %ebp
f0105256:	c3                   	ret    

f0105257 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105257:	55                   	push   %ebp
f0105258:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010525a:	83 3d 00 50 27 f0 00 	cmpl   $0x0,0xf0275000
f0105261:	74 0f                	je     f0105272 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105263:	ba 00 00 00 00       	mov    $0x0,%edx
f0105268:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010526d:	e8 92 fe ff ff       	call   f0105104 <lapicw>
}
f0105272:	5d                   	pop    %ebp
f0105273:	c3                   	ret    

f0105274 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0105274:	55                   	push   %ebp
f0105275:	89 e5                	mov    %esp,%ebp
}
f0105277:	5d                   	pop    %ebp
f0105278:	c3                   	ret    

f0105279 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0105279:	55                   	push   %ebp
f010527a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010527c:	8b 55 08             	mov    0x8(%ebp),%edx
f010527f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105285:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010528a:	e8 75 fe ff ff       	call   f0105104 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010528f:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f0105295:	81 c2 00 03 00 00    	add    $0x300,%edx
f010529b:	8b 02                	mov    (%edx),%eax
f010529d:	f6 c4 10             	test   $0x10,%ah
f01052a0:	75 f9                	jne    f010529b <lapic_ipi+0x22>
		;
}
f01052a2:	5d                   	pop    %ebp
f01052a3:	c3                   	ret    

f01052a4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01052a4:	55                   	push   %ebp
f01052a5:	89 e5                	mov    %esp,%ebp
f01052a7:	56                   	push   %esi
f01052a8:	53                   	push   %ebx
f01052a9:	83 ec 10             	sub    $0x10,%esp
f01052ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052af:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f01052b3:	ba 70 00 00 00       	mov    $0x70,%edx
f01052b8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01052bd:	ee                   	out    %al,(%dx)
f01052be:	b2 71                	mov    $0x71,%dl
f01052c0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052c5:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01052c6:	83 3d 08 3f 23 f0 00 	cmpl   $0x0,0xf0233f08
f01052cd:	75 24                	jne    f01052f3 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01052cf:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01052d6:	00 
f01052d7:	c7 44 24 08 e0 58 10 	movl   $0xf01058e0,0x8(%esp)
f01052de:	f0 
f01052df:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01052e6:	00 
f01052e7:	c7 04 24 d8 6d 10 f0 	movl   $0xf0106dd8,(%esp)
f01052ee:	e8 92 ad ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01052f3:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01052fa:	00 00 
	wrv[1] = addr >> 4;
f01052fc:	89 f0                	mov    %esi,%eax
f01052fe:	c1 e8 04             	shr    $0x4,%eax
f0105301:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105307:	c1 e3 18             	shl    $0x18,%ebx
f010530a:	89 da                	mov    %ebx,%edx
f010530c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105311:	e8 ee fd ff ff       	call   f0105104 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105316:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010531b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105320:	e8 df fd ff ff       	call   f0105104 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105325:	ba 00 85 00 00       	mov    $0x8500,%edx
f010532a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010532f:	e8 d0 fd ff ff       	call   f0105104 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105334:	c1 ee 0c             	shr    $0xc,%esi
f0105337:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010533d:	89 da                	mov    %ebx,%edx
f010533f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105344:	e8 bb fd ff ff       	call   f0105104 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105349:	89 f2                	mov    %esi,%edx
f010534b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105350:	e8 af fd ff ff       	call   f0105104 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105355:	89 da                	mov    %ebx,%edx
f0105357:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010535c:	e8 a3 fd ff ff       	call   f0105104 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105361:	89 f2                	mov    %esi,%edx
f0105363:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105368:	e8 97 fd ff ff       	call   f0105104 <lapicw>
		microdelay(200);
	}
}
f010536d:	83 c4 10             	add    $0x10,%esp
f0105370:	5b                   	pop    %ebx
f0105371:	5e                   	pop    %esi
f0105372:	5d                   	pop    %ebp
f0105373:	c3                   	ret    
	...

f0105380 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105380:	55                   	push   %ebp
f0105381:	89 e5                	mov    %esp,%ebp
f0105383:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
f0105386:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//LAB 4: Your code here

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010538c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010538f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105392:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105399:	5d                   	pop    %ebp
f010539a:	c3                   	ret    

f010539b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010539b:	55                   	push   %ebp
f010539c:	89 e5                	mov    %esp,%ebp
f010539e:	53                   	push   %ebx
f010539f:	83 ec 04             	sub    $0x4,%esp
f01053a2:	89 c2                	mov    %eax,%edx
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
f01053a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01053a9:	83 3a 00             	cmpl   $0x0,(%edx)
f01053ac:	74 18                	je     f01053c6 <holding+0x2b>
f01053ae:	8b 5a 08             	mov    0x8(%edx),%ebx
f01053b1:	e8 68 fd ff ff       	call   f010511e <cpunum>
f01053b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01053b9:	05 20 40 23 f0       	add    $0xf0234020,%eax
f01053be:	39 c3                	cmp    %eax,%ebx
f01053c0:	0f 94 c0             	sete   %al
f01053c3:	0f b6 c0             	movzbl %al,%eax
#else
	//LAB 4: Your code here
	panic("ticket spinlock: not implemented yet");

#endif
}
f01053c6:	83 c4 04             	add    $0x4,%esp
f01053c9:	5b                   	pop    %ebx
f01053ca:	5d                   	pop    %ebp
f01053cb:	c3                   	ret    

f01053cc <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01053cc:	55                   	push   %ebp
f01053cd:	89 e5                	mov    %esp,%ebp
f01053cf:	83 ec 78             	sub    $0x78,%esp
f01053d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01053d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01053d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01053db:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01053de:	89 d8                	mov    %ebx,%eax
f01053e0:	e8 b6 ff ff ff       	call   f010539b <holding>
f01053e5:	85 c0                	test   %eax,%eax
f01053e7:	0f 85 d5 00 00 00    	jne    f01054c2 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01053ed:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01053f4:	00 
f01053f5:	8d 43 0c             	lea    0xc(%ebx),%eax
f01053f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053fc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01053ff:	89 04 24             	mov    %eax,(%esp)
f0105402:	e8 ce f6 ff ff       	call   f0104ad5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105407:	8b 43 08             	mov    0x8(%ebx),%eax
f010540a:	0f b6 30             	movzbl (%eax),%esi
f010540d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105410:	e8 09 fd ff ff       	call   f010511e <cpunum>
f0105415:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105419:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010541d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105421:	c7 04 24 e8 6d 10 f0 	movl   $0xf0106de8,(%esp)
f0105428:	e8 ce dc ff ff       	call   f01030fb <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010542d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0105430:	85 c0                	test   %eax,%eax
f0105432:	74 72                	je     f01054a6 <spin_unlock+0xda>
f0105434:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0105437:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010543a:	8d 75 d0             	lea    -0x30(%ebp),%esi
f010543d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105441:	89 04 24             	mov    %eax,(%esp)
f0105444:	e8 75 ea ff ff       	call   f0103ebe <debuginfo_eip>
f0105449:	85 c0                	test   %eax,%eax
f010544b:	78 39                	js     f0105486 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010544d:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010544f:	89 c2                	mov    %eax,%edx
f0105451:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0105454:	89 54 24 18          	mov    %edx,0x18(%esp)
f0105458:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010545b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010545f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105462:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105466:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105469:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010546d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105470:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105474:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105478:	c7 04 24 4c 6e 10 f0 	movl   $0xf0106e4c,(%esp)
f010547f:	e8 77 dc ff ff       	call   f01030fb <cprintf>
f0105484:	eb 12                	jmp    f0105498 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105486:	8b 03                	mov    (%ebx),%eax
f0105488:	89 44 24 04          	mov    %eax,0x4(%esp)
f010548c:	c7 04 24 63 6e 10 f0 	movl   $0xf0106e63,(%esp)
f0105493:	e8 63 dc ff ff       	call   f01030fb <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105498:	39 fb                	cmp    %edi,%ebx
f010549a:	74 0a                	je     f01054a6 <spin_unlock+0xda>
f010549c:	8b 43 04             	mov    0x4(%ebx),%eax
f010549f:	83 c3 04             	add    $0x4,%ebx
f01054a2:	85 c0                	test   %eax,%eax
f01054a4:	75 97                	jne    f010543d <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01054a6:	c7 44 24 08 6b 6e 10 	movl   $0xf0106e6b,0x8(%esp)
f01054ad:	f0 
f01054ae:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
f01054b5:	00 
f01054b6:	c7 04 24 77 6e 10 f0 	movl   $0xf0106e77,(%esp)
f01054bd:	e8 c3 ab ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f01054c2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01054c9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01054d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01054d5:	f0 87 03             	lock xchg %eax,(%ebx)
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
#endif
}
f01054d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01054db:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01054de:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01054e1:	89 ec                	mov    %ebp,%esp
f01054e3:	5d                   	pop    %ebp
f01054e4:	c3                   	ret    

f01054e5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01054e5:	55                   	push   %ebp
f01054e6:	89 e5                	mov    %esp,%ebp
f01054e8:	56                   	push   %esi
f01054e9:	53                   	push   %ebx
f01054ea:	83 ec 20             	sub    $0x20,%esp
f01054ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01054f0:	89 d8                	mov    %ebx,%eax
f01054f2:	e8 a4 fe ff ff       	call   f010539b <holding>
f01054f7:	85 c0                	test   %eax,%eax
f01054f9:	75 12                	jne    f010550d <spin_lock+0x28>

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01054fb:	89 da                	mov    %ebx,%edx
f01054fd:	b0 01                	mov    $0x1,%al
f01054ff:	f0 87 03             	lock xchg %eax,(%ebx)
f0105502:	b9 01 00 00 00       	mov    $0x1,%ecx
f0105507:	85 c0                	test   %eax,%eax
f0105509:	75 2e                	jne    f0105539 <spin_lock+0x54>
f010550b:	eb 37                	jmp    f0105544 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010550d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105510:	e8 09 fc ff ff       	call   f010511e <cpunum>
f0105515:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0105519:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010551d:	c7 44 24 08 20 6e 10 	movl   $0xf0106e20,0x8(%esp)
f0105524:	f0 
f0105525:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010552c:	00 
f010552d:	c7 04 24 77 6e 10 f0 	movl   $0xf0106e77,(%esp)
f0105534:	e8 4c ab ff ff       	call   f0100085 <_panic>
#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105539:	f3 90                	pause  
f010553b:	89 c8                	mov    %ecx,%eax
f010553d:	f0 87 02             	lock xchg %eax,(%edx)

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105540:	85 c0                	test   %eax,%eax
f0105542:	75 f5                	jne    f0105539 <spin_lock+0x54>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105544:	e8 d5 fb ff ff       	call   f010511e <cpunum>
f0105549:	6b c0 74             	imul   $0x74,%eax,%eax
f010554c:	05 20 40 23 f0       	add    $0xf0234020,%eax
f0105551:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105554:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0105557:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0105559:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f010555f:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0105565:	76 40                	jbe    f01055a7 <spin_lock+0xc2>
f0105567:	eb 33                	jmp    f010559c <spin_lock+0xb7>
f0105569:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f010556f:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0105575:	77 2a                	ja     f01055a1 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105577:	8b 4a 04             	mov    0x4(%edx),%ecx
f010557a:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010557d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010557f:	83 c0 01             	add    $0x1,%eax
f0105582:	83 f8 0a             	cmp    $0xa,%eax
f0105585:	75 e2                	jne    f0105569 <spin_lock+0x84>
f0105587:	eb 2d                	jmp    f01055b6 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105589:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010558f:	83 c0 01             	add    $0x1,%eax
f0105592:	83 c2 04             	add    $0x4,%edx
f0105595:	83 f8 09             	cmp    $0x9,%eax
f0105598:	7e ef                	jle    f0105589 <spin_lock+0xa4>
f010559a:	eb 1a                	jmp    f01055b6 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010559c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f01055a1:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f01055a5:	eb e2                	jmp    f0105589 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01055a7:	8b 50 04             	mov    0x4(%eax),%edx
f01055aa:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01055ad:	8b 10                	mov    (%eax),%edx
f01055af:	b8 01 00 00 00       	mov    $0x1,%eax
f01055b4:	eb b3                	jmp    f0105569 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01055b6:	83 c4 20             	add    $0x20,%esp
f01055b9:	5b                   	pop    %ebx
f01055ba:	5e                   	pop    %esi
f01055bb:	5d                   	pop    %ebp
f01055bc:	c3                   	ret    
f01055bd:	00 00                	add    %al,(%eax)
	...

f01055c0 <__udivdi3>:
f01055c0:	55                   	push   %ebp
f01055c1:	89 e5                	mov    %esp,%ebp
f01055c3:	57                   	push   %edi
f01055c4:	56                   	push   %esi
f01055c5:	83 ec 10             	sub    $0x10,%esp
f01055c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01055cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01055ce:	8b 75 10             	mov    0x10(%ebp),%esi
f01055d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01055d4:	85 c0                	test   %eax,%eax
f01055d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01055d9:	75 35                	jne    f0105610 <__udivdi3+0x50>
f01055db:	39 fe                	cmp    %edi,%esi
f01055dd:	77 61                	ja     f0105640 <__udivdi3+0x80>
f01055df:	85 f6                	test   %esi,%esi
f01055e1:	75 0b                	jne    f01055ee <__udivdi3+0x2e>
f01055e3:	b8 01 00 00 00       	mov    $0x1,%eax
f01055e8:	31 d2                	xor    %edx,%edx
f01055ea:	f7 f6                	div    %esi
f01055ec:	89 c6                	mov    %eax,%esi
f01055ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01055f1:	31 d2                	xor    %edx,%edx
f01055f3:	89 f8                	mov    %edi,%eax
f01055f5:	f7 f6                	div    %esi
f01055f7:	89 c7                	mov    %eax,%edi
f01055f9:	89 c8                	mov    %ecx,%eax
f01055fb:	f7 f6                	div    %esi
f01055fd:	89 c1                	mov    %eax,%ecx
f01055ff:	89 fa                	mov    %edi,%edx
f0105601:	89 c8                	mov    %ecx,%eax
f0105603:	83 c4 10             	add    $0x10,%esp
f0105606:	5e                   	pop    %esi
f0105607:	5f                   	pop    %edi
f0105608:	5d                   	pop    %ebp
f0105609:	c3                   	ret    
f010560a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105610:	39 f8                	cmp    %edi,%eax
f0105612:	77 1c                	ja     f0105630 <__udivdi3+0x70>
f0105614:	0f bd d0             	bsr    %eax,%edx
f0105617:	83 f2 1f             	xor    $0x1f,%edx
f010561a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010561d:	75 39                	jne    f0105658 <__udivdi3+0x98>
f010561f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0105622:	0f 86 a0 00 00 00    	jbe    f01056c8 <__udivdi3+0x108>
f0105628:	39 f8                	cmp    %edi,%eax
f010562a:	0f 82 98 00 00 00    	jb     f01056c8 <__udivdi3+0x108>
f0105630:	31 ff                	xor    %edi,%edi
f0105632:	31 c9                	xor    %ecx,%ecx
f0105634:	89 c8                	mov    %ecx,%eax
f0105636:	89 fa                	mov    %edi,%edx
f0105638:	83 c4 10             	add    $0x10,%esp
f010563b:	5e                   	pop    %esi
f010563c:	5f                   	pop    %edi
f010563d:	5d                   	pop    %ebp
f010563e:	c3                   	ret    
f010563f:	90                   	nop
f0105640:	89 d1                	mov    %edx,%ecx
f0105642:	89 fa                	mov    %edi,%edx
f0105644:	89 c8                	mov    %ecx,%eax
f0105646:	31 ff                	xor    %edi,%edi
f0105648:	f7 f6                	div    %esi
f010564a:	89 c1                	mov    %eax,%ecx
f010564c:	89 fa                	mov    %edi,%edx
f010564e:	89 c8                	mov    %ecx,%eax
f0105650:	83 c4 10             	add    $0x10,%esp
f0105653:	5e                   	pop    %esi
f0105654:	5f                   	pop    %edi
f0105655:	5d                   	pop    %ebp
f0105656:	c3                   	ret    
f0105657:	90                   	nop
f0105658:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010565c:	89 f2                	mov    %esi,%edx
f010565e:	d3 e0                	shl    %cl,%eax
f0105660:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105663:	b8 20 00 00 00       	mov    $0x20,%eax
f0105668:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010566b:	89 c1                	mov    %eax,%ecx
f010566d:	d3 ea                	shr    %cl,%edx
f010566f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105673:	0b 55 ec             	or     -0x14(%ebp),%edx
f0105676:	d3 e6                	shl    %cl,%esi
f0105678:	89 c1                	mov    %eax,%ecx
f010567a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010567d:	89 fe                	mov    %edi,%esi
f010567f:	d3 ee                	shr    %cl,%esi
f0105681:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105685:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105688:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010568b:	d3 e7                	shl    %cl,%edi
f010568d:	89 c1                	mov    %eax,%ecx
f010568f:	d3 ea                	shr    %cl,%edx
f0105691:	09 d7                	or     %edx,%edi
f0105693:	89 f2                	mov    %esi,%edx
f0105695:	89 f8                	mov    %edi,%eax
f0105697:	f7 75 ec             	divl   -0x14(%ebp)
f010569a:	89 d6                	mov    %edx,%esi
f010569c:	89 c7                	mov    %eax,%edi
f010569e:	f7 65 e8             	mull   -0x18(%ebp)
f01056a1:	39 d6                	cmp    %edx,%esi
f01056a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01056a6:	72 30                	jb     f01056d8 <__udivdi3+0x118>
f01056a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01056ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01056af:	d3 e2                	shl    %cl,%edx
f01056b1:	39 c2                	cmp    %eax,%edx
f01056b3:	73 05                	jae    f01056ba <__udivdi3+0xfa>
f01056b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01056b8:	74 1e                	je     f01056d8 <__udivdi3+0x118>
f01056ba:	89 f9                	mov    %edi,%ecx
f01056bc:	31 ff                	xor    %edi,%edi
f01056be:	e9 71 ff ff ff       	jmp    f0105634 <__udivdi3+0x74>
f01056c3:	90                   	nop
f01056c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01056c8:	31 ff                	xor    %edi,%edi
f01056ca:	b9 01 00 00 00       	mov    $0x1,%ecx
f01056cf:	e9 60 ff ff ff       	jmp    f0105634 <__udivdi3+0x74>
f01056d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01056d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01056db:	31 ff                	xor    %edi,%edi
f01056dd:	89 c8                	mov    %ecx,%eax
f01056df:	89 fa                	mov    %edi,%edx
f01056e1:	83 c4 10             	add    $0x10,%esp
f01056e4:	5e                   	pop    %esi
f01056e5:	5f                   	pop    %edi
f01056e6:	5d                   	pop    %ebp
f01056e7:	c3                   	ret    
	...

f01056f0 <__umoddi3>:
f01056f0:	55                   	push   %ebp
f01056f1:	89 e5                	mov    %esp,%ebp
f01056f3:	57                   	push   %edi
f01056f4:	56                   	push   %esi
f01056f5:	83 ec 20             	sub    $0x20,%esp
f01056f8:	8b 55 14             	mov    0x14(%ebp),%edx
f01056fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056fe:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105701:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105704:	85 d2                	test   %edx,%edx
f0105706:	89 c8                	mov    %ecx,%eax
f0105708:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010570b:	75 13                	jne    f0105720 <__umoddi3+0x30>
f010570d:	39 f7                	cmp    %esi,%edi
f010570f:	76 3f                	jbe    f0105750 <__umoddi3+0x60>
f0105711:	89 f2                	mov    %esi,%edx
f0105713:	f7 f7                	div    %edi
f0105715:	89 d0                	mov    %edx,%eax
f0105717:	31 d2                	xor    %edx,%edx
f0105719:	83 c4 20             	add    $0x20,%esp
f010571c:	5e                   	pop    %esi
f010571d:	5f                   	pop    %edi
f010571e:	5d                   	pop    %ebp
f010571f:	c3                   	ret    
f0105720:	39 f2                	cmp    %esi,%edx
f0105722:	77 4c                	ja     f0105770 <__umoddi3+0x80>
f0105724:	0f bd ca             	bsr    %edx,%ecx
f0105727:	83 f1 1f             	xor    $0x1f,%ecx
f010572a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010572d:	75 51                	jne    f0105780 <__umoddi3+0x90>
f010572f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0105732:	0f 87 e0 00 00 00    	ja     f0105818 <__umoddi3+0x128>
f0105738:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010573b:	29 f8                	sub    %edi,%eax
f010573d:	19 d6                	sbb    %edx,%esi
f010573f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0105742:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105745:	89 f2                	mov    %esi,%edx
f0105747:	83 c4 20             	add    $0x20,%esp
f010574a:	5e                   	pop    %esi
f010574b:	5f                   	pop    %edi
f010574c:	5d                   	pop    %ebp
f010574d:	c3                   	ret    
f010574e:	66 90                	xchg   %ax,%ax
f0105750:	85 ff                	test   %edi,%edi
f0105752:	75 0b                	jne    f010575f <__umoddi3+0x6f>
f0105754:	b8 01 00 00 00       	mov    $0x1,%eax
f0105759:	31 d2                	xor    %edx,%edx
f010575b:	f7 f7                	div    %edi
f010575d:	89 c7                	mov    %eax,%edi
f010575f:	89 f0                	mov    %esi,%eax
f0105761:	31 d2                	xor    %edx,%edx
f0105763:	f7 f7                	div    %edi
f0105765:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105768:	f7 f7                	div    %edi
f010576a:	eb a9                	jmp    f0105715 <__umoddi3+0x25>
f010576c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105770:	89 c8                	mov    %ecx,%eax
f0105772:	89 f2                	mov    %esi,%edx
f0105774:	83 c4 20             	add    $0x20,%esp
f0105777:	5e                   	pop    %esi
f0105778:	5f                   	pop    %edi
f0105779:	5d                   	pop    %ebp
f010577a:	c3                   	ret    
f010577b:	90                   	nop
f010577c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105780:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105784:	d3 e2                	shl    %cl,%edx
f0105786:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0105789:	ba 20 00 00 00       	mov    $0x20,%edx
f010578e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0105791:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105794:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105798:	89 fa                	mov    %edi,%edx
f010579a:	d3 ea                	shr    %cl,%edx
f010579c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01057a0:	0b 55 f4             	or     -0xc(%ebp),%edx
f01057a3:	d3 e7                	shl    %cl,%edi
f01057a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01057a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01057ac:	89 f2                	mov    %esi,%edx
f01057ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01057b1:	89 c7                	mov    %eax,%edi
f01057b3:	d3 ea                	shr    %cl,%edx
f01057b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01057b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01057bc:	89 c2                	mov    %eax,%edx
f01057be:	d3 e6                	shl    %cl,%esi
f01057c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01057c4:	d3 ea                	shr    %cl,%edx
f01057c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01057ca:	09 d6                	or     %edx,%esi
f01057cc:	89 f0                	mov    %esi,%eax
f01057ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01057d1:	d3 e7                	shl    %cl,%edi
f01057d3:	89 f2                	mov    %esi,%edx
f01057d5:	f7 75 f4             	divl   -0xc(%ebp)
f01057d8:	89 d6                	mov    %edx,%esi
f01057da:	f7 65 e8             	mull   -0x18(%ebp)
f01057dd:	39 d6                	cmp    %edx,%esi
f01057df:	72 2b                	jb     f010580c <__umoddi3+0x11c>
f01057e1:	39 c7                	cmp    %eax,%edi
f01057e3:	72 23                	jb     f0105808 <__umoddi3+0x118>
f01057e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01057e9:	29 c7                	sub    %eax,%edi
f01057eb:	19 d6                	sbb    %edx,%esi
f01057ed:	89 f0                	mov    %esi,%eax
f01057ef:	89 f2                	mov    %esi,%edx
f01057f1:	d3 ef                	shr    %cl,%edi
f01057f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01057f7:	d3 e0                	shl    %cl,%eax
f01057f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01057fd:	09 f8                	or     %edi,%eax
f01057ff:	d3 ea                	shr    %cl,%edx
f0105801:	83 c4 20             	add    $0x20,%esp
f0105804:	5e                   	pop    %esi
f0105805:	5f                   	pop    %edi
f0105806:	5d                   	pop    %ebp
f0105807:	c3                   	ret    
f0105808:	39 d6                	cmp    %edx,%esi
f010580a:	75 d9                	jne    f01057e5 <__umoddi3+0xf5>
f010580c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010580f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0105812:	eb d1                	jmp    f01057e5 <__umoddi3+0xf5>
f0105814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105818:	39 f2                	cmp    %esi,%edx
f010581a:	0f 82 18 ff ff ff    	jb     f0105738 <__umoddi3+0x48>
f0105820:	e9 1d ff ff ff       	jmp    f0105742 <__umoddi3+0x52>
