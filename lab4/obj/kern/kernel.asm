
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

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
f0100058:	c7 04 24 20 6d 10 f0 	movl   $0xf0106d20,(%esp)
f010005f:	e8 87 45 00 00       	call   f01045eb <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 45 45 00 00       	call   f01045b8 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 49 7d 10 f0 	movl   $0xf0107d49,(%esp)
f010007a:	e8 6c 45 00 00       	call   f01045eb <cprintf>
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
f0100090:	83 3d 00 5f 23 f0 00 	cmpl   $0x0,0xf0235f00
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 00 5f 23 f0    	mov    %esi,0xf0235f00

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
f01000a4:	e8 65 65 00 00       	call   f010660e <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 78 6d 10 f0 	movl   $0xf0106d78,(%esp)
f01000c2:	e8 24 45 00 00       	call   f01045eb <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 e5 44 00 00       	call   f01045b8 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 49 7d 10 f0 	movl   $0xf0107d49,(%esp)
f01000da:	e8 0c 45 00 00       	call   f01045eb <cprintf>
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
f01000f3:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000fd:	77 20                	ja     f010011f <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100103:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f010010a:	f0 
f010010b:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
f0100112:	00 
f0100113:	c7 04 24 3a 6d 10 f0 	movl   $0xf0106d3a,(%esp)
f010011a:	e8 66 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010011f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0100125:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100128:	e8 e1 64 00 00       	call   f010660e <cpunum>
f010012d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100131:	c7 04 24 46 6d 10 f0 	movl   $0xf0106d46,(%esp)
f0100138:	e8 ae 44 00 00       	call   f01045eb <cprintf>

	lapic_init();
f010013d:	e8 e8 64 00 00       	call   f010662a <lapic_init>
	env_init_percpu();
f0100142:	e8 39 3a 00 00       	call   f0103b80 <env_init_percpu>
	trap_init_percpu();
f0100147:	e8 d4 44 00 00       	call   f0104620 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100150:	e8 b9 64 00 00       	call   f010660e <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 60 23 f0    	add    $0xf0236024,%edx
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
f0100170:	b8 04 70 27 f0       	mov    $0xf0277004,%eax
f0100175:	2d 27 49 23 f0       	sub    $0xf0234927,%eax
f010017a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010017e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100185:	00 
f0100186:	c7 04 24 27 49 23 f0 	movl   $0xf0234927,(%esp)
f010018d:	e8 d4 5d 00 00       	call   f0105f66 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100192:	e8 1e 06 00 00       	call   f01007b5 <cons_init>

//<<<<<<< HEAD
	cprintf("6828 decimal is %o octal!\n", 6828);
f0100197:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010019e:	00 
f010019f:	c7 04 24 5c 6d 10 f0 	movl   $0xf0106d5c,(%esp)
f01001a6:	e8 40 44 00 00       	call   f01045eb <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
	*/
//>>>>>>> lab2

	// Lab 2 memory management initialization functions
	mem_init();
f01001ab:	e8 1e 28 00 00       	call   f01029ce <mem_init>
	//cprintf("1\n");
	// Lab 3 user environment initialization functions
	env_init();
f01001b0:	e8 6c 3e 00 00       	call   f0104021 <env_init>
	//cprintf("2\n");
	trap_init();
f01001b5:	e8 c3 44 00 00       	call   f010467d <trap_init>
//<<<<<<< HEAD

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ba:	e8 6b 61 00 00       	call   f010632a <mp_init>
	lapic_init();
f01001bf:	90                   	nop
f01001c0:	e8 65 64 00 00       	call   f010662a <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001c5:	e8 5f 43 00 00       	call   f0104529 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001ca:	83 3d 08 5f 23 f0 07 	cmpl   $0x7,0xf0235f08
f01001d1:	77 24                	ja     f01001f7 <i386_init+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001d3:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001da:	00 
f01001db:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01001e2:	f0 
f01001e3:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
f01001ea:	00 
f01001eb:	c7 04 24 3a 6d 10 f0 	movl   $0xf0106d3a,(%esp)
f01001f2:	e8 8e fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001f7:	b8 46 62 10 f0       	mov    $0xf0106246,%eax
f01001fc:	2d cc 61 10 f0       	sub    $0xf01061cc,%eax
f0100201:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100205:	c7 44 24 04 cc 61 10 	movl   $0xf01061cc,0x4(%esp)
f010020c:	f0 
f010020d:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100214:	e8 ac 5d 00 00       	call   f0105fc5 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100219:	6b 05 c4 63 23 f0 74 	imul   $0x74,0xf02363c4,%eax
f0100220:	05 20 60 23 f0       	add    $0xf0236020,%eax
f0100225:	3d 20 60 23 f0       	cmp    $0xf0236020,%eax
f010022a:	76 65                	jbe    f0100291 <i386_init+0x129>
f010022c:	be 00 00 00 00       	mov    $0x0,%esi
f0100231:	bb 20 60 23 f0       	mov    $0xf0236020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100236:	e8 d3 63 00 00       	call   f010660e <cpunum>
f010023b:	6b c0 74             	imul   $0x74,%eax,%eax
f010023e:	05 20 60 23 f0       	add    $0xf0236020,%eax
f0100243:	39 c3                	cmp    %eax,%ebx
f0100245:	74 34                	je     f010027b <i386_init+0x113>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100247:	89 f0                	mov    %esi,%eax
f0100249:	c1 f8 02             	sar    $0x2,%eax
f010024c:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100252:	c1 e0 0f             	shl    $0xf,%eax
f0100255:	8d 80 00 f0 23 f0    	lea    -0xfdc1000(%eax),%eax
f010025b:	a3 04 5f 23 f0       	mov    %eax,0xf0235f04
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100260:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100267:	00 
f0100268:	0f b6 03             	movzbl (%ebx),%eax
f010026b:	89 04 24             	mov    %eax,(%esp)
f010026e:	e8 21 65 00 00       	call   f0106794 <lapic_startap>
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
f0100281:	6b 05 c4 63 23 f0 74 	imul   $0x74,0xf02363c4,%eax
f0100288:	05 20 60 23 f0       	add    $0xf0236020,%eax
f010028d:	39 c3                	cmp    %eax,%ebx
f010028f:	72 a5                	jb     f0100236 <i386_init+0xce>
			;
	}
//=======
	// We only have one user environment for now, so just run it.
	//cprintf("4\n");
	env_run(&envs[0]);
f0100291:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f0100296:	89 04 24             	mov    %eax,(%esp)
f0100299:	e8 f5 39 00 00       	call   f0103c93 <env_run>

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
f01002ad:	e8 5c 63 00 00       	call   f010660e <cpunum>
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
f01002e6:	c7 04 24 80 13 12 f0 	movl   $0xf0121380,(%esp)
f01002ed:	e8 e3 66 00 00       	call   f01069d5 <spin_lock>
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01002f2:	8b 0d 00 50 23 f0    	mov    0xf0235000,%ecx
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
f0100310:	c7 44 24 08 e4 6d 10 	movl   $0xf0106de4,0x8(%esp)
f0100317:	f0 
f0100318:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
f010031f:	00 
f0100320:	c7 04 24 3a 6d 10 f0 	movl   $0xf0106d3a,(%esp)
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
f0100343:	a1 00 50 23 f0       	mov    0xf0235000,%eax
f0100348:	83 c0 01             	add    $0x1,%eax
f010034b:	a3 00 50 23 f0       	mov    %eax,0xf0235000
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
f0100360:	c7 04 24 80 13 12 f0 	movl   $0xf0121380,(%esp)
f0100367:	e8 50 65 00 00       	call   f01068bc <spin_unlock>

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
f010037a:	c7 04 24 80 13 12 f0 	movl   $0xf0121380,(%esp)
f0100381:	e8 4f 66 00 00       	call   f01069d5 <spin_lock>
		while (interval++ < 10000)
			test_ctr++;
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f0100386:	e8 83 62 00 00       	call   f010660e <cpunum>
f010038b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010038f:	c7 04 24 18 6e 10 f0 	movl   $0xf0106e18,(%esp)
f0100396:	e8 50 42 00 00       	call   f01045eb <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010039b:	c7 04 24 80 13 12 f0 	movl   $0xf0121380,(%esp)
f01003a2:	e8 15 65 00 00       	call   f01068bc <spin_unlock>

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
f01003e9:	bb 44 52 23 f0       	mov    $0xf0235244,%ebx
f01003ee:	bf 40 50 23 f0       	mov    $0xf0235040,%edi
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
f010043a:	83 3d 24 50 23 f0 00 	cmpl   $0x0,0xf0235024
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
f010045f:	8b 15 40 52 23 f0    	mov    0xf0235240,%edx
f0100465:	b8 00 00 00 00       	mov    $0x0,%eax
f010046a:	3b 15 44 52 23 f0    	cmp    0xf0235244,%edx
f0100470:	74 21                	je     f0100493 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100472:	0f b6 82 40 50 23 f0 	movzbl -0xfdcafc0(%edx),%eax
f0100479:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010047c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100482:	0f 94 c1             	sete   %cl
f0100485:	0f b6 c9             	movzbl %cl,%ecx
f0100488:	83 e9 01             	sub    $0x1,%ecx
f010048b:	21 ca                	and    %ecx,%edx
f010048d:	89 15 40 52 23 f0    	mov    %edx,0xf0235240
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
f010057a:	0f b7 05 30 50 23 f0 	movzwl 0xf0235030,%eax
f0100581:	66 85 c0             	test   %ax,%ax
f0100584:	0f 84 e8 00 00 00    	je     f0100672 <cons_putc+0x1c2>
			crt_pos--;
f010058a:	83 e8 01             	sub    $0x1,%eax
f010058d:	66 a3 30 50 23 f0    	mov    %ax,0xf0235030
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100593:	0f b7 c0             	movzwl %ax,%eax
f0100596:	66 81 e7 00 ff       	and    $0xff00,%di
f010059b:	83 cf 20             	or     $0x20,%edi
f010059e:	8b 15 2c 50 23 f0    	mov    0xf023502c,%edx
f01005a4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005a8:	eb 7b                	jmp    f0100625 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01005aa:	66 83 05 30 50 23 f0 	addw   $0x50,0xf0235030
f01005b1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01005b2:	0f b7 05 30 50 23 f0 	movzwl 0xf0235030,%eax
f01005b9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01005bf:	c1 e8 10             	shr    $0x10,%eax
f01005c2:	66 c1 e8 06          	shr    $0x6,%ax
f01005c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005c9:	c1 e0 04             	shl    $0x4,%eax
f01005cc:	66 a3 30 50 23 f0    	mov    %ax,0xf0235030
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
f0100608:	0f b7 05 30 50 23 f0 	movzwl 0xf0235030,%eax
f010060f:	0f b7 c8             	movzwl %ax,%ecx
f0100612:	8b 15 2c 50 23 f0    	mov    0xf023502c,%edx
f0100618:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010061c:	83 c0 01             	add    $0x1,%eax
f010061f:	66 a3 30 50 23 f0    	mov    %ax,0xf0235030
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100625:	66 81 3d 30 50 23 f0 	cmpw   $0x7cf,0xf0235030
f010062c:	cf 07 
f010062e:	76 42                	jbe    f0100672 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100630:	a1 2c 50 23 f0       	mov    0xf023502c,%eax
f0100635:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010063c:	00 
f010063d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100643:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100647:	89 04 24             	mov    %eax,(%esp)
f010064a:	e8 76 59 00 00       	call   f0105fc5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010064f:	8b 15 2c 50 23 f0    	mov    0xf023502c,%edx
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
f010066a:	66 83 2d 30 50 23 f0 	subw   $0x50,0xf0235030
f0100671:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100672:	8b 0d 28 50 23 f0    	mov    0xf0235028,%ecx
f0100678:	89 cb                	mov    %ecx,%ebx
f010067a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067f:	89 ca                	mov    %ecx,%edx
f0100681:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100682:	0f b7 35 30 50 23 f0 	movzwl 0xf0235030,%esi
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
f01006db:	83 0d 20 50 23 f0 40 	orl    $0x40,0xf0235020
f01006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006e7:	e9 c1 00 00 00       	jmp    f01007ad <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01006ec:	84 c0                	test   %al,%al
f01006ee:	79 32                	jns    f0100722 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006f0:	8b 15 20 50 23 f0    	mov    0xf0235020,%edx
f01006f6:	f6 c2 40             	test   $0x40,%dl
f01006f9:	75 03                	jne    f01006fe <kbd_proc_data+0x44>
f01006fb:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01006fe:	0f b6 c0             	movzbl %al,%eax
f0100701:	0f b6 80 80 6e 10 f0 	movzbl -0xfef9180(%eax),%eax
f0100708:	83 c8 40             	or     $0x40,%eax
f010070b:	0f b6 c0             	movzbl %al,%eax
f010070e:	f7 d0                	not    %eax
f0100710:	21 c2                	and    %eax,%edx
f0100712:	89 15 20 50 23 f0    	mov    %edx,0xf0235020
f0100718:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010071d:	e9 8b 00 00 00       	jmp    f01007ad <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100722:	8b 15 20 50 23 f0    	mov    0xf0235020,%edx
f0100728:	f6 c2 40             	test   $0x40,%dl
f010072b:	74 0c                	je     f0100739 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010072d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100730:	83 e2 bf             	and    $0xffffffbf,%edx
f0100733:	89 15 20 50 23 f0    	mov    %edx,0xf0235020
	}

	shift |= shiftcode[data];
f0100739:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010073c:	0f b6 90 80 6e 10 f0 	movzbl -0xfef9180(%eax),%edx
f0100743:	0b 15 20 50 23 f0    	or     0xf0235020,%edx
f0100749:	0f b6 88 80 6f 10 f0 	movzbl -0xfef9080(%eax),%ecx
f0100750:	31 ca                	xor    %ecx,%edx
f0100752:	89 15 20 50 23 f0    	mov    %edx,0xf0235020

	c = charcode[shift & (CTL | SHIFT)][data];
f0100758:	89 d1                	mov    %edx,%ecx
f010075a:	83 e1 03             	and    $0x3,%ecx
f010075d:	8b 0c 8d 80 70 10 f0 	mov    -0xfef8f80(,%ecx,4),%ecx
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
f0100796:	c7 04 24 3e 6e 10 f0 	movl   $0xf0106e3e,(%esp)
f010079d:	e8 49 3e 00 00       	call   f01045eb <cprintf>
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
f01007d4:	c7 05 28 50 23 f0 b4 	movl   $0x3b4,0xf0235028
f01007db:	03 00 00 
f01007de:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007e3:	eb 16                	jmp    f01007fb <cons_init+0x46>
	} else {
		*cp = was;
f01007e5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007ec:	c7 05 28 50 23 f0 d4 	movl   $0x3d4,0xf0235028
f01007f3:	03 00 00 
f01007f6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01007fb:	8b 0d 28 50 23 f0    	mov    0xf0235028,%ecx
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
f0100822:	89 35 2c 50 23 f0    	mov    %esi,0xf023502c
	crt_pos = pos;
f0100828:	0f b6 c8             	movzbl %al,%ecx
f010082b:	09 cf                	or     %ecx,%edi
f010082d:	66 89 3d 30 50 23 f0 	mov    %di,0xf0235030

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100834:	e8 e9 fb ff ff       	call   f0100422 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100839:	0f b7 05 70 13 12 f0 	movzwl 0xf0121370,%eax
f0100840:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100845:	89 04 24             	mov    %eax,(%esp)
f0100848:	e8 6b 3c 00 00       	call   f01044b8 <irq_setmask_8259A>
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
f010089a:	89 35 24 50 23 f0    	mov    %esi,0xf0235024
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
f01008aa:	c7 04 24 4a 6e 10 f0 	movl   $0xf0106e4a,(%esp)
f01008b1:	e8 35 3d 00 00       	call   f01045eb <cprintf>
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
f0100925:	c7 04 24 90 70 10 f0 	movl   $0xf0107090,(%esp)
f010092c:	e8 ba 3c 00 00       	call   f01045eb <cprintf>
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
f010095d:	c7 04 24 90 70 10 f0 	movl   $0xf0107090,(%esp)
f0100964:	e8 82 3c 00 00       	call   f01045eb <cprintf>
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
f010099a:	c7 04 24 90 70 10 f0 	movl   $0xf0107090,(%esp)
f01009a1:	e8 45 3c 00 00       	call   f01045eb <cprintf>
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
f01009ca:	c7 04 24 95 70 10 f0 	movl   $0xf0107095,(%esp)
f01009d1:	e8 15 3c 00 00       	call   f01045eb <cprintf>
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
f01009f4:	c7 04 24 9b 70 10 f0 	movl   $0xf010709b,(%esp)
f01009fb:	e8 eb 3b 00 00       	call   f01045eb <cprintf>
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
f0100a08:	c7 04 24 ad 70 10 f0 	movl   $0xf01070ad,(%esp)
f0100a0f:	e8 d7 3b 00 00       	call   f01045eb <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100a14:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100a1b:	00 
f0100a1c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100a23:	f0 
f0100a24:	c7 04 24 e0 71 10 f0 	movl   $0xf01071e0,(%esp)
f0100a2b:	e8 bb 3b 00 00       	call   f01045eb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a30:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
f0100a37:	00 
f0100a38:	c7 44 24 04 15 6d 10 	movl   $0xf0106d15,0x4(%esp)
f0100a3f:	f0 
f0100a40:	c7 04 24 04 72 10 f0 	movl   $0xf0107204,(%esp)
f0100a47:	e8 9f 3b 00 00       	call   f01045eb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a4c:	c7 44 24 08 27 49 23 	movl   $0x234927,0x8(%esp)
f0100a53:	00 
f0100a54:	c7 44 24 04 27 49 23 	movl   $0xf0234927,0x4(%esp)
f0100a5b:	f0 
f0100a5c:	c7 04 24 28 72 10 f0 	movl   $0xf0107228,(%esp)
f0100a63:	e8 83 3b 00 00       	call   f01045eb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a68:	c7 44 24 08 04 70 27 	movl   $0x277004,0x8(%esp)
f0100a6f:	00 
f0100a70:	c7 44 24 04 04 70 27 	movl   $0xf0277004,0x4(%esp)
f0100a77:	f0 
f0100a78:	c7 04 24 4c 72 10 f0 	movl   $0xf010724c,(%esp)
f0100a7f:	e8 67 3b 00 00       	call   f01045eb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a84:	b8 03 74 27 f0       	mov    $0xf0277403,%eax
f0100a89:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100a8e:	89 c2                	mov    %eax,%edx
f0100a90:	c1 fa 1f             	sar    $0x1f,%edx
f0100a93:	c1 ea 16             	shr    $0x16,%edx
f0100a96:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100a99:	c1 f8 0a             	sar    $0xa,%eax
f0100a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa0:	c7 04 24 70 72 10 f0 	movl   $0xf0107270,(%esp)
f0100aa7:	e8 3f 3b 00 00       	call   f01045eb <cprintf>
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
f0100ac1:	be 04 74 10 f0       	mov    $0xf0107404,%esi
f0100ac6:	bf 00 74 10 f0       	mov    $0xf0107400,%edi
f0100acb:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100ace:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ad2:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f0100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad9:	c7 04 24 c6 70 10 f0 	movl   $0xf01070c6,(%esp)
f0100ae0:	e8 06 3b 00 00       	call   f01045eb <cprintf>
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
f0100b03:	c7 04 24 9c 72 10 f0 	movl   $0xf010729c,(%esp)
f0100b0a:	e8 dc 3a 00 00       	call   f01045eb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b0f:	c7 04 24 c0 72 10 f0 	movl   $0xf01072c0,(%esp)
f0100b16:	e8 d0 3a 00 00       	call   f01045eb <cprintf>

	if (tf != NULL)
f0100b1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b1f:	74 0b                	je     f0100b2c <monitor+0x32>
		print_trapframe(tf);
f0100b21:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b24:	89 04 24             	mov    %eax,(%esp)
f0100b27:	e8 2b 3f 00 00       	call   f0104a57 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100b2c:	c7 04 24 cf 70 10 f0 	movl   $0xf01070cf,(%esp)
f0100b33:	e8 78 51 00 00       	call   f0105cb0 <readline>
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
f0100b60:	c7 04 24 d3 70 10 f0 	movl   $0xf01070d3,(%esp)
f0100b67:	e8 9f 53 00 00       	call   f0105f0b <strchr>
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
f0100b82:	c7 04 24 d8 70 10 f0 	movl   $0xf01070d8,(%esp)
f0100b89:	e8 5d 3a 00 00       	call   f01045eb <cprintf>
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
f0100bb3:	c7 04 24 d3 70 10 f0 	movl   $0xf01070d3,(%esp)
f0100bba:	e8 4c 53 00 00       	call   f0105f0b <strchr>
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
f0100bd6:	bb 00 74 10 f0       	mov    $0xf0107400,%ebx
f0100bdb:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100be0:	8b 03                	mov    (%ebx),%eax
f0100be2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100be9:	89 04 24             	mov    %eax,(%esp)
f0100bec:	e8 a4 52 00 00       	call   f0105e95 <strcmp>
f0100bf1:	85 c0                	test   %eax,%eax
f0100bf3:	75 23                	jne    f0100c18 <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f0100bf5:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100bf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bff:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c06:	89 34 24             	mov    %esi,(%esp)
f0100c09:	ff 97 08 74 10 f0    	call   *-0xfef8bf8(%edi)
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
f0100c2a:	c7 04 24 f5 70 10 f0 	movl   $0xf01070f5,(%esp)
f0100c31:	e8 b5 39 00 00       	call   f01045eb <cprintf>
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
f0100c52:	c7 04 24 0b 71 10 f0 	movl   $0xf010710b,(%esp)
f0100c59:	e8 8d 39 00 00       	call   f01045eb <cprintf>
f0100c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0100c63:	e9 96 00 00 00       	jmp    f0100cfe <mon_time+0xbb>
f0100c68:	bb 00 74 10 f0       	mov    $0xf0107400,%ebx
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
f0100c86:	e8 0a 52 00 00       	call   f0105e95 <strcmp>
f0100c8b:	85 c0                	test   %eax,%eax
f0100c8d:	74 23                	je     f0100cb2 <mon_time+0x6f>
			break;
		if (i == NCOMMANDS - 1){
f0100c8f:	83 fe 06             	cmp    $0x6,%esi
f0100c92:	75 13                	jne    f0100ca7 <mon_time+0x64>
			cprintf("Unkown command.\n");
f0100c94:	c7 04 24 22 71 10 f0 	movl   $0xf0107122,(%esp)
f0100c9b:	e8 4b 39 00 00       	call   f01045eb <cprintf>
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
f0100cd4:	ff 14 85 08 74 10 f0 	call   *-0xfef8bf8(,%eax,4)
f0100cdb:	0f 31                	rdtsc  
	uint32_t end = read_tsc();
	cprintf("%s cycles: %llu\n", argv[1], end-begin);
f0100cdd:	2b 45 d8             	sub    -0x28(%ebp),%eax
f0100ce0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ce4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ce7:	8b 02                	mov    (%edx),%eax
f0100ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ced:	c7 04 24 33 71 10 f0 	movl   $0xf0107133,(%esp)
f0100cf4:	e8 f2 38 00 00       	call   f01045eb <cprintf>
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
f0100d11:	c7 04 24 44 71 10 f0 	movl   $0xf0107144,(%esp)
f0100d18:	e8 ce 38 00 00       	call   f01045eb <cprintf>
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
f0100d54:	c7 04 24 e8 72 10 f0 	movl   $0xf01072e8,(%esp)
f0100d5b:	e8 8b 38 00 00       	call   f01045eb <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100d60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d64:	8b 06                	mov    (%esi),%eax
f0100d66:	89 04 24             	mov    %eax,(%esp)
f0100d69:	e8 40 46 00 00       	call   f01053ae <debuginfo_eip>
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
f0100d8c:	c7 04 24 56 71 10 f0 	movl   $0xf0107156,(%esp)
f0100d93:	e8 53 38 00 00       	call   f01045eb <cprintf>
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
f0100da3:	c7 04 24 66 71 10 f0 	movl   $0xf0107166,(%esp)
f0100daa:	e8 3c 38 00 00       	call   f01045eb <cprintf>
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
f0100dde:	e8 cb 45 00 00       	call   f01053ae <debuginfo_eip>
		cprintf("%08x\n", tf->tf_eip);
f0100de3:	8b 43 30             	mov    0x30(%ebx),%eax
f0100de6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dea:	c7 04 24 05 89 10 f0 	movl   $0xf0108905,(%esp)
f0100df1:	e8 f5 37 00 00       	call   f01045eb <cprintf>
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
f0100e15:	c7 04 24 58 71 10 f0 	movl   $0xf0107158,(%esp)
f0100e1c:	e8 ca 37 00 00       	call   f01045eb <cprintf>
		env_run(curenv);		
f0100e21:	e8 e8 57 00 00       	call   f010660e <cpunum>
f0100e26:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e29:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0100e2f:	89 04 24             	mov    %eax,(%esp)
f0100e32:	e8 5c 2e 00 00       	call   f0103c93 <env_run>
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
f0100e56:	e8 b3 57 00 00       	call   f010660e <cpunum>
f0100e5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e5e:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0100e64:	89 04 24             	mov    %eax,(%esp)
f0100e67:	e8 27 2e 00 00       	call   f0103c93 <env_run>
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
f0100e7f:	c7 04 24 79 71 10 f0 	movl   $0xf0107179,(%esp)
f0100e86:	e8 60 37 00 00       	call   f01045eb <cprintf>
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
f0100eb6:	e8 20 52 00 00       	call   f01060db <strtol>
		__asm __volatile("movl (%0), %0" : "=r" (val) : "r" (addr));	
f0100ebb:	8b 00                	mov    (%eax),%eax
		cprintf("%d\n", val);
f0100ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ec1:	c7 04 24 3f 80 10 f0 	movl   $0xf010803f,(%esp)
f0100ec8:	e8 1e 37 00 00       	call   f01045eb <cprintf>
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
f0100eed:	8b 15 50 52 23 f0    	mov    0xf0235250,%edx
f0100ef3:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0100ef5:	a3 50 52 23 f0       	mov    %eax,0xf0235250
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
f0100f32:	8b 1d 10 5f 23 f0    	mov    0xf0235f10,%ebx
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
f0100fc9:	a1 54 52 23 f0       	mov    0xf0235254,%eax
f0100fce:	89 02                	mov    %eax,(%edx)
	chunk_list = pp;
f0100fd0:	89 1d 54 52 23 f0    	mov    %ebx,0xf0235254
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
f0100fe5:	e8 24 56 00 00       	call   f010660e <cpunum>
f0100fea:	6b c0 74             	imul   $0x74,%eax,%eax
f0100fed:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0100ff4:	74 16                	je     f010100c <tlb_invalidate+0x2d>
f0100ff6:	e8 13 56 00 00       	call   f010660e <cpunum>
f0100ffb:	6b c0 74             	imul   $0x74,%eax,%eax
f0100ffe:	8b 90 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%edx
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
f0101025:	e8 66 34 00 00       	call   f0104490 <mc146818_read>
f010102a:	89 c6                	mov    %eax,%esi
f010102c:	83 c3 01             	add    $0x1,%ebx
f010102f:	89 1c 24             	mov    %ebx,(%esp)
f0101032:	e8 59 34 00 00       	call   f0104490 <mc146818_read>
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
f010104c:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f0101052:	c1 f8 03             	sar    $0x3,%eax
f0101055:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101058:	89 c2                	mov    %eax,%edx
f010105a:	c1 ea 0c             	shr    $0xc,%edx
f010105d:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0101063:	72 20                	jb     f0101085 <page2kva+0x3f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101065:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101069:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0101070:	f0 
f0101071:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101078:	00 
f0101079:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
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
f010109f:	8b 35 08 5f 23 f0    	mov    0xf0235f08,%esi
f01010a5:	85 f6                	test   %esi,%esi
f01010a7:	0f 84 f0 00 00 00    	je     f010119d <page_alloc_npages+0x111>
		if (pages[i].pp_ref == 0){
f01010ad:	a1 10 5f 23 f0       	mov    0xf0235f10,%eax
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
f0101129:	89 15 50 52 23 f0    	mov    %edx,0xf0235250
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
f010114d:	8b 0d 10 5f 23 f0    	mov    0xf0235f10,%ecx
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
f010116e:	03 1d 10 5f 23 f0    	add    0xf0235f10,%ebx
	
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
f0101196:	e8 cb 4d 00 00       	call   f0105f66 <memset>
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
f01011b1:	8b 15 50 52 23 f0    	mov    0xf0235250,%edx
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
f010128d:	e8 33 4d 00 00       	call   f0105fc5 <memmove>
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
f01012ef:	3b 0d 08 5f 23 f0    	cmp    0xf0235f08,%ecx
f01012f5:	72 20                	jb     f0101317 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012fb:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0101302:	f0 
f0101303:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010130a:	00 
f010130b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
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
f0101340:	83 3d 48 52 23 f0 00 	cmpl   $0x0,0xf0235248
f0101347:	75 11                	jne    f010135a <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101349:	ba 03 80 27 f0       	mov    $0xf0278003,%edx
f010134e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101354:	89 15 48 52 23 f0    	mov    %edx,0xf0235248
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	/*stone's solution for lab2*/
	result = nextfree;
f010135a:	8b 15 48 52 23 f0    	mov    0xf0235248,%edx
	if (n > 0){
f0101360:	85 c0                	test   %eax,%eax
f0101362:	74 76                	je     f01013da <boot_alloc+0xa1>
		nextfree += n;
f0101364:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101367:	a3 48 52 23 f0       	mov    %eax,0xf0235248
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
f0101379:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0101380:	f0 
f0101381:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0101388:	00 
f0101389:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
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
f01013a0:	3b 1d 08 5f 23 f0    	cmp    0xf0235f08,%ebx
f01013a6:	72 20                	jb     f01013c8 <boot_alloc+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013ac:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01013b3:	f0 
f01013b4:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f01013bb:	00 
f01013bc:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01013c3:	e8 bd ec ff ff       	call   f0100085 <_panic>
		KADDR(PADDR(nextfree));
		nextfree = ROUNDUP(nextfree, PGSIZE);
f01013c8:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01013ce:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01013d4:	89 0d 48 52 23 f0    	mov    %ecx,0xf0235248
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
	// free pages!
	/*stone's solution for lab2*/
	size_t i;
	size_t mp = MPENTRY_PADDR / PGSIZE;
	/*stone's solution for lab4-A(modify)*/
	for (i = 1; i < npages_basemem && i != mp; i++){
f01013ea:	8b 35 4c 52 23 f0    	mov    0xf023524c,%esi
f01013f0:	83 fe 01             	cmp    $0x1,%esi
f01013f3:	76 42                	jbe    f0101437 <page_init+0x55>
f01013f5:	8b 0d 50 52 23 f0    	mov    0xf0235250,%ecx
f01013fb:	b8 01 00 00 00       	mov    $0x1,%eax
f0101400:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101407:	8b 1d 10 5f 23 f0    	mov    0xf0235f10,%ebx
f010140d:	66 c7 44 13 04 00 00 	movw   $0x0,0x4(%ebx,%edx,1)
		pages[i].pp_link = page_free_list;
f0101414:	8b 1d 10 5f 23 f0    	mov    0xf0235f10,%ebx
f010141a:	89 0c 13             	mov    %ecx,(%ebx,%edx,1)
		page_free_list = &pages[i];
f010141d:	89 d1                	mov    %edx,%ecx
f010141f:	03 0d 10 5f 23 f0    	add    0xf0235f10,%ecx
	// free pages!
	/*stone's solution for lab2*/
	size_t i;
	size_t mp = MPENTRY_PADDR / PGSIZE;
	/*stone's solution for lab4-A(modify)*/
	for (i = 1; i < npages_basemem && i != mp; i++){
f0101425:	83 c0 01             	add    $0x1,%eax
f0101428:	39 f0                	cmp    %esi,%eax
f010142a:	73 05                	jae    f0101431 <page_init+0x4f>
f010142c:	83 f8 07             	cmp    $0x7,%eax
f010142f:	75 cf                	jne    f0101400 <page_init+0x1e>
f0101431:	89 0d 50 52 23 f0    	mov    %ecx,0xf0235250
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//use boot_alloc(0) to get next free page
	for (i = (PADDR(boot_alloc(0)) / PGSIZE); i < npages; i++){
f0101437:	b8 00 00 00 00       	mov    $0x0,%eax
f010143c:	e8 f8 fe ff ff       	call   f0101339 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101441:	89 c2                	mov    %eax,%edx
f0101443:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101448:	77 20                	ja     f010146a <page_init+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010144a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010144e:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0101455:	f0 
f0101456:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f010145d:	00 
f010145e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101465:	e8 1b ec ff ff       	call   f0100085 <_panic>
f010146a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101470:	c1 ea 0c             	shr    $0xc,%edx
f0101473:	39 15 08 5f 23 f0    	cmp    %edx,0xf0235f08
f0101479:	76 3f                	jbe    f01014ba <page_init+0xd8>
f010147b:	8b 0d 50 52 23 f0    	mov    0xf0235250,%ecx
f0101481:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		 pages[i].pp_ref = 0;
f0101488:	8b 1d 10 5f 23 f0    	mov    0xf0235f10,%ebx
f010148e:	66 c7 44 03 04 00 00 	movw   $0x0,0x4(%ebx,%eax,1)
		pages[i].pp_link = page_free_list;
f0101495:	8b 1d 10 5f 23 f0    	mov    0xf0235f10,%ebx
f010149b:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
		page_free_list = &pages[i];
f010149e:	89 c1                	mov    %eax,%ecx
f01014a0:	03 0d 10 5f 23 f0    	add    0xf0235f10,%ecx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//use boot_alloc(0) to get next free page
	for (i = (PADDR(boot_alloc(0)) / PGSIZE); i < npages; i++){
f01014a6:	83 c2 01             	add    $0x1,%edx
f01014a9:	83 c0 08             	add    $0x8,%eax
f01014ac:	39 15 08 5f 23 f0    	cmp    %edx,0xf0235f08
f01014b2:	77 d4                	ja     f0101488 <page_init+0xa6>
f01014b4:	89 0d 50 52 23 f0    	mov    %ecx,0xf0235250
		 pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f01014ba:	c7 05 54 52 23 f0 00 	movl   $0x0,0xf0235254
f01014c1:	00 00 00 
}
f01014c4:	83 c4 10             	add    $0x10,%esp
f01014c7:	5b                   	pop    %ebx
f01014c8:	5e                   	pop    %esi
f01014c9:	5d                   	pop    %ebp
f01014ca:	c3                   	ret    

f01014cb <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01014cb:	55                   	push   %ebp
f01014cc:	89 e5                	mov    %esp,%ebp
f01014ce:	57                   	push   %edi
f01014cf:	56                   	push   %esi
f01014d0:	53                   	push   %ebx
f01014d1:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01014d4:	83 f8 01             	cmp    $0x1,%eax
f01014d7:	19 f6                	sbb    %esi,%esi
f01014d9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01014df:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01014e2:	8b 1d 50 52 23 f0    	mov    0xf0235250,%ebx
f01014e8:	85 db                	test   %ebx,%ebx
f01014ea:	75 1c                	jne    f0101508 <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f01014ec:	c7 44 24 08 54 74 10 	movl   $0xf0107454,0x8(%esp)
f01014f3:	f0 
f01014f4:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f01014fb:	00 
f01014fc:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101503:	e8 7d eb ff ff       	call   f0100085 <_panic>
	//cprintf("2");
	if (only_low_memory) {
f0101508:	85 c0                	test   %eax,%eax
f010150a:	74 52                	je     f010155e <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f010150c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010150f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101512:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101515:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101518:	8b 0d 10 5f 23 f0    	mov    0xf0235f10,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010151e:	89 d8                	mov    %ebx,%eax
f0101520:	29 c8                	sub    %ecx,%eax
f0101522:	c1 e0 09             	shl    $0x9,%eax
f0101525:	c1 e8 16             	shr    $0x16,%eax
f0101528:	39 c6                	cmp    %eax,%esi
f010152a:	0f 96 c0             	setbe  %al
f010152d:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101530:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101534:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101536:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010153a:	8b 1b                	mov    (%ebx),%ebx
f010153c:	85 db                	test   %ebx,%ebx
f010153e:	75 de                	jne    f010151e <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101540:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101543:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101549:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010154c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010154f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101551:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101554:	89 1d 50 52 23 f0    	mov    %ebx,0xf0235250
	}
	//cprintf("2");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f010155a:	85 db                	test   %ebx,%ebx
f010155c:	74 67                	je     f01015c5 <check_page_free_list+0xfa>
f010155e:	89 d8                	mov    %ebx,%eax
f0101560:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f0101566:	c1 f8 03             	sar    $0x3,%eax
f0101569:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010156c:	89 c2                	mov    %eax,%edx
f010156e:	c1 ea 16             	shr    $0x16,%edx
f0101571:	39 d6                	cmp    %edx,%esi
f0101573:	76 4a                	jbe    f01015bf <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101575:	89 c2                	mov    %eax,%edx
f0101577:	c1 ea 0c             	shr    $0xc,%edx
f010157a:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0101580:	72 20                	jb     f01015a2 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101582:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101586:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f010158d:	f0 
f010158e:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101595:	00 
f0101596:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f010159d:	e8 e3 ea ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01015a2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01015a9:	00 
f01015aa:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01015b1:	00 
f01015b2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015b7:	89 04 24             	mov    %eax,(%esp)
f01015ba:	e8 a7 49 00 00       	call   f0105f66 <memset>
		page_free_list = pp1;
	}
	//cprintf("2");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01015bf:	8b 1b                	mov    (%ebx),%ebx
f01015c1:	85 db                	test   %ebx,%ebx
f01015c3:	75 99                	jne    f010155e <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
f01015c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ca:	e8 6a fd ff ff       	call   f0101339 <boot_alloc>
f01015cf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01015d2:	8b 15 50 52 23 f0    	mov    0xf0235250,%edx
f01015d8:	85 d2                	test   %edx,%edx
f01015da:	0f 84 3b 02 00 00    	je     f010181b <check_page_free_list+0x350>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01015e0:	8b 1d 10 5f 23 f0    	mov    0xf0235f10,%ebx
f01015e6:	39 da                	cmp    %ebx,%edx
f01015e8:	72 50                	jb     f010163a <check_page_free_list+0x16f>
		assert(pp < pages + npages);
f01015ea:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f01015ef:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01015f2:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01015f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015f8:	39 c2                	cmp    %eax,%edx
f01015fa:	73 67                	jae    f0101663 <check_page_free_list+0x198>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01015fc:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01015ff:	89 d0                	mov    %edx,%eax
f0101601:	29 d8                	sub    %ebx,%eax
f0101603:	a8 07                	test   $0x7,%al
f0101605:	0f 85 85 00 00 00    	jne    f0101690 <check_page_free_list+0x1c5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010160b:	c1 f8 03             	sar    $0x3,%eax
f010160e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101611:	85 c0                	test   %eax,%eax
f0101613:	0f 84 a5 00 00 00    	je     f01016be <check_page_free_list+0x1f3>
		assert(page2pa(pp) != IOPHYSMEM);
f0101619:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010161e:	0f 84 c5 00 00 00    	je     f01016e9 <check_page_free_list+0x21e>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101624:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101629:	0f 85 09 01 00 00    	jne    f0101738 <check_page_free_list+0x26d>
f010162f:	90                   	nop
f0101630:	e9 df 00 00 00       	jmp    f0101714 <check_page_free_list+0x249>
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101635:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101638:	73 24                	jae    f010165e <check_page_free_list+0x193>
f010163a:	c7 44 24 0c 6b 7b 10 	movl   $0xf0107b6b,0xc(%esp)
f0101641:	f0 
f0101642:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101649:	f0 
f010164a:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101651:	00 
f0101652:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101659:	e8 27 ea ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f010165e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101661:	72 24                	jb     f0101687 <check_page_free_list+0x1bc>
f0101663:	c7 44 24 0c 8c 7b 10 	movl   $0xf0107b8c,0xc(%esp)
f010166a:	f0 
f010166b:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101672:	f0 
f0101673:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f010167a:	00 
f010167b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101682:	e8 fe e9 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101687:	89 d0                	mov    %edx,%eax
f0101689:	2b 45 cc             	sub    -0x34(%ebp),%eax
f010168c:	a8 07                	test   $0x7,%al
f010168e:	74 24                	je     f01016b4 <check_page_free_list+0x1e9>
f0101690:	c7 44 24 0c 78 74 10 	movl   $0xf0107478,0xc(%esp)
f0101697:	f0 
f0101698:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010169f:	f0 
f01016a0:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f01016a7:	00 
f01016a8:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01016af:	e8 d1 e9 ff ff       	call   f0100085 <_panic>
f01016b4:	c1 f8 03             	sar    $0x3,%eax
f01016b7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01016ba:	85 c0                	test   %eax,%eax
f01016bc:	75 24                	jne    f01016e2 <check_page_free_list+0x217>
f01016be:	c7 44 24 0c a0 7b 10 	movl   $0xf0107ba0,0xc(%esp)
f01016c5:	f0 
f01016c6:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01016cd:	f0 
f01016ce:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f01016d5:	00 
f01016d6:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01016dd:	e8 a3 e9 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01016e2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01016e7:	75 24                	jne    f010170d <check_page_free_list+0x242>
f01016e9:	c7 44 24 0c b1 7b 10 	movl   $0xf0107bb1,0xc(%esp)
f01016f0:	f0 
f01016f1:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01016f8:	f0 
f01016f9:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101700:	00 
f0101701:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101708:	e8 78 e9 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010170d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101712:	75 31                	jne    f0101745 <check_page_free_list+0x27a>
f0101714:	c7 44 24 0c ac 74 10 	movl   $0xf01074ac,0xc(%esp)
f010171b:	f0 
f010171c:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101723:	f0 
f0101724:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f010172b:	00 
f010172c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101733:	e8 4d e9 ff ff       	call   f0100085 <_panic>
f0101738:	be 00 00 00 00       	mov    $0x0,%esi
f010173d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101742:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0101745:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010174a:	75 24                	jne    f0101770 <check_page_free_list+0x2a5>
f010174c:	c7 44 24 0c ca 7b 10 	movl   $0xf0107bca,0xc(%esp)
f0101753:	f0 
f0101754:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010175b:	f0 
f010175c:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101763:	00 
f0101764:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010176b:	e8 15 e9 ff ff       	call   f0100085 <_panic>
f0101770:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101772:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101777:	76 59                	jbe    f01017d2 <check_page_free_list+0x307>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101779:	89 c3                	mov    %eax,%ebx
f010177b:	c1 eb 0c             	shr    $0xc,%ebx
f010177e:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101781:	77 20                	ja     f01017a3 <check_page_free_list+0x2d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101783:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101787:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f010178e:	f0 
f010178f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101796:	00 
f0101797:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f010179e:	e8 e2 e8 ff ff       	call   f0100085 <_panic>
f01017a3:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01017a9:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01017ac:	76 24                	jbe    f01017d2 <check_page_free_list+0x307>
f01017ae:	c7 44 24 0c d0 74 10 	movl   $0xf01074d0,0xc(%esp)
f01017b5:	f0 
f01017b6:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01017bd:	f0 
f01017be:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01017c5:	00 
f01017c6:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01017cd:	e8 b3 e8 ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01017d2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01017d7:	75 24                	jne    f01017fd <check_page_free_list+0x332>
f01017d9:	c7 44 24 0c e4 7b 10 	movl   $0xf0107be4,0xc(%esp)
f01017e0:	f0 
f01017e1:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01017e8:	f0 
f01017e9:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f01017f0:	00 
f01017f1:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01017f8:	e8 88 e8 ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01017fd:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101803:	77 05                	ja     f010180a <check_page_free_list+0x33f>
			++nfree_basemem;
f0101805:	83 c7 01             	add    $0x1,%edi
f0101808:	eb 03                	jmp    f010180d <check_page_free_list+0x342>
		else
			++nfree_extmem;
f010180a:	83 c6 01             	add    $0x1,%esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	//cprintf("2");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010180d:	8b 12                	mov    (%edx),%edx
f010180f:	85 d2                	test   %edx,%edx
f0101811:	0f 85 1e fe ff ff    	jne    f0101635 <check_page_free_list+0x16a>
			++nfree_basemem;
		else
			++nfree_extmem;
	}
	//cprintf("2");
	assert(nfree_basemem > 0);
f0101817:	85 ff                	test   %edi,%edi
f0101819:	7f 24                	jg     f010183f <check_page_free_list+0x374>
f010181b:	c7 44 24 0c 01 7c 10 	movl   $0xf0107c01,0xc(%esp)
f0101822:	f0 
f0101823:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010182a:	f0 
f010182b:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101832:	00 
f0101833:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010183a:	e8 46 e8 ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f010183f:	85 f6                	test   %esi,%esi
f0101841:	7f 24                	jg     f0101867 <check_page_free_list+0x39c>
f0101843:	c7 44 24 0c 13 7c 10 	movl   $0xf0107c13,0xc(%esp)
f010184a:	f0 
f010184b:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101852:	f0 
f0101853:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010185a:	00 
f010185b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101862:	e8 1e e8 ff ff       	call   f0100085 <_panic>
	//cprintf("2");
}
f0101867:	83 c4 5c             	add    $0x5c,%esp
f010186a:	5b                   	pop    %ebx
f010186b:	5e                   	pop    %esi
f010186c:	5f                   	pop    %edi
f010186d:	5d                   	pop    %ebp
f010186e:	c3                   	ret    

f010186f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f010186f:	55                   	push   %ebp
f0101870:	89 e5                	mov    %esp,%ebp
f0101872:	53                   	push   %ebx
f0101873:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	/*stone's solution for lab2*/
	struct Page* alloc_page;
	if (page_free_list != NULL){
f0101876:	8b 1d 50 52 23 f0    	mov    0xf0235250,%ebx
f010187c:	85 db                	test   %ebx,%ebx
f010187e:	74 6b                	je     f01018eb <page_alloc+0x7c>
		alloc_page = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101880:	8b 03                	mov    (%ebx),%eax
f0101882:	a3 50 52 23 f0       	mov    %eax,0xf0235250
		alloc_page->pp_link = NULL;
f0101887:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f010188d:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101891:	74 58                	je     f01018eb <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101893:	89 d8                	mov    %ebx,%eax
f0101895:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f010189b:	c1 f8 03             	sar    $0x3,%eax
f010189e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a1:	89 c2                	mov    %eax,%edx
f01018a3:	c1 ea 0c             	shr    $0xc,%edx
f01018a6:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f01018ac:	72 20                	jb     f01018ce <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018b2:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01018b9:	f0 
f01018ba:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01018c1:	00 
f01018c2:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f01018c9:	e8 b7 e7 ff ff       	call   f0100085 <_panic>
			memset(page2kva(alloc_page), '\0', PGSIZE);
f01018ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018d5:	00 
f01018d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018dd:	00 
f01018de:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018e3:	89 04 24             	mov    %eax,(%esp)
f01018e6:	e8 7b 46 00 00       	call   f0105f66 <memset>
		return alloc_page;
	}
	return NULL;
}
f01018eb:	89 d8                	mov    %ebx,%eax
f01018ed:	83 c4 14             	add    $0x14,%esp
f01018f0:	5b                   	pop    %ebx
f01018f1:	5d                   	pop    %ebp
f01018f2:	c3                   	ret    

f01018f3 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01018f3:	55                   	push   %ebp
f01018f4:	89 e5                	mov    %esp,%ebp
f01018f6:	83 ec 18             	sub    $0x18,%esp
f01018f9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01018fc:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	/*stone's solution for lab2*/
	pde_t* pde = pgdir + PDX(va);//stone: get pde
f01018ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101902:	89 de                	mov    %ebx,%esi
f0101904:	c1 ee 16             	shr    $0x16,%esi
f0101907:	c1 e6 02             	shl    $0x2,%esi
f010190a:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P){//stone:if present
f010190d:	8b 06                	mov    (%esi),%eax
f010190f:	a8 01                	test   $0x1,%al
f0101911:	74 44                	je     f0101957 <pgdir_walk+0x64>
		pte_t *pte = PTX(va) + (pte_t *)KADDR(PTE_ADDR(*pde));
f0101913:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101918:	89 c2                	mov    %eax,%edx
f010191a:	c1 ea 0c             	shr    $0xc,%edx
f010191d:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0101923:	72 20                	jb     f0101945 <pgdir_walk+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101925:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101929:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0101930:	f0 
f0101931:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
f0101938:	00 
f0101939:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101940:	e8 40 e7 ff ff       	call   f0100085 <_panic>
f0101945:	c1 eb 0a             	shr    $0xa,%ebx
f0101948:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010194e:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
		return pte;
f0101955:	eb 78                	jmp    f01019cf <pgdir_walk+0xdc>
	}
	else if (create == 0)
f0101957:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010195b:	74 6d                	je     f01019ca <pgdir_walk+0xd7>
		return NULL;
	else{
		struct Page* pp = page_alloc(ALLOC_ZERO);
f010195d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101964:	e8 06 ff ff ff       	call   f010186f <page_alloc>
		if (pp == NULL)
f0101969:	85 c0                	test   %eax,%eax
f010196b:	74 5d                	je     f01019ca <pgdir_walk+0xd7>
			return NULL;
		else{
			pp->pp_ref = 1;
f010196d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			physaddr_t physaddr = page2pa(pp);
			*pde = physaddr | PTE_U | PTE_W | PTE_P;
f0101973:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f0101979:	c1 f8 03             	sar    $0x3,%eax
f010197c:	c1 e0 0c             	shl    $0xc,%eax
f010197f:	83 c8 07             	or     $0x7,%eax
f0101982:	89 06                	mov    %eax,(%esi)
			pte_t *pte = PTX(va) + (pte_t *)KADDR(PTE_ADDR(*pde));
f0101984:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101989:	89 c2                	mov    %eax,%edx
f010198b:	c1 ea 0c             	shr    $0xc,%edx
f010198e:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0101994:	72 20                	jb     f01019b6 <pgdir_walk+0xc3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101996:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010199a:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01019a1:	f0 
f01019a2:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
f01019a9:	00 
f01019aa:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01019b1:	e8 cf e6 ff ff       	call   f0100085 <_panic>
f01019b6:	c1 eb 0a             	shr    $0xa,%ebx
f01019b9:	89 da                	mov    %ebx,%edx
f01019bb:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f01019c1:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
			return pte;
f01019c8:	eb 05                	jmp    f01019cf <pgdir_walk+0xdc>
f01019ca:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}	  
	//return NULL;
}
f01019cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01019d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01019d5:	89 ec                	mov    %ebp,%esp
f01019d7:	5d                   	pop    %ebp
f01019d8:	c3                   	ret    

f01019d9 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01019d9:	55                   	push   %ebp
f01019da:	89 e5                	mov    %esp,%ebp
f01019dc:	57                   	push   %edi
f01019dd:	56                   	push   %esi
f01019de:	53                   	push   %ebx
f01019df:	83 ec 2c             	sub    $0x2c,%esp
f01019e2:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	uintptr_t start = (uintptr_t)va;
f01019e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uintptr_t end = (uintptr_t)va + len;
f01019e8:	8b 45 10             	mov    0x10(%ebp),%eax
f01019eb:	01 d8                	add    %ebx,%eax
f01019ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	perm |= PTE_P;
f01019f0:	8b 7d 14             	mov    0x14(%ebp),%edi
f01019f3:	83 cf 01             	or     $0x1,%edi
	int r = 0;
	while (start < end){
f01019f6:	39 c3                	cmp    %eax,%ebx
f01019f8:	73 66                	jae    f0101a60 <user_mem_check+0x87>
		if (start > ULIM){
f01019fa:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0101a00:	76 1d                	jbe    f0101a1f <user_mem_check+0x46>
f0101a02:	eb 0e                	jmp    f0101a12 <user_mem_check+0x39>
f0101a04:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0101a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a10:	76 0d                	jbe    f0101a1f <user_mem_check+0x46>
			user_mem_check_addr = start;
f0101a12:	89 1d 58 52 23 f0    	mov    %ebx,0xf0235258
f0101a18:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			r = -E_FAULT;
			break;
f0101a1d:	eb 46                	jmp    f0101a65 <user_mem_check+0x8c>
		}
		pte_t* pte = pgdir_walk(env->env_pgdir, (void*)start, 0);
f0101a1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a26:	00 
f0101a27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a2b:	8b 46 64             	mov    0x64(%esi),%eax
f0101a2e:	89 04 24             	mov    %eax,(%esp)
f0101a31:	e8 bd fe ff ff       	call   f01018f3 <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm){
f0101a36:	85 c0                	test   %eax,%eax
f0101a38:	74 08                	je     f0101a42 <user_mem_check+0x69>
f0101a3a:	8b 00                	mov    (%eax),%eax
f0101a3c:	21 f8                	and    %edi,%eax
f0101a3e:	39 c7                	cmp    %eax,%edi
f0101a40:	74 0d                	je     f0101a4f <user_mem_check+0x76>
			user_mem_check_addr = start;
f0101a42:	89 1d 58 52 23 f0    	mov    %ebx,0xf0235258
f0101a48:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			r = -E_FAULT;
			break;
f0101a4d:	eb 16                	jmp    f0101a65 <user_mem_check+0x8c>
		}
		start = ROUNDDOWN(start+PGSIZE, PGSIZE);
f0101a4f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101a55:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	/*stone's solution for lab3-B*/
	uintptr_t start = (uintptr_t)va;
	uintptr_t end = (uintptr_t)va + len;
	perm |= PTE_P;
	int r = 0;
	while (start < end){
f0101a5b:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101a5e:	77 a4                	ja     f0101a04 <user_mem_check+0x2b>
f0101a60:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
		}
		start = ROUNDDOWN(start+PGSIZE, PGSIZE);
	}
	return r;
}
f0101a65:	83 c4 2c             	add    $0x2c,%esp
f0101a68:	5b                   	pop    %ebx
f0101a69:	5e                   	pop    %esi
f0101a6a:	5f                   	pop    %edi
f0101a6b:	5d                   	pop    %ebp
f0101a6c:	c3                   	ret    

f0101a6d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101a6d:	55                   	push   %ebp
f0101a6e:	89 e5                	mov    %esp,%ebp
f0101a70:	53                   	push   %ebx
f0101a71:	83 ec 14             	sub    $0x14,%esp
f0101a74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101a77:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a7a:	83 c8 04             	or     $0x4,%eax
f0101a7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a81:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a8f:	89 1c 24             	mov    %ebx,(%esp)
f0101a92:	e8 42 ff ff ff       	call   f01019d9 <user_mem_check>
f0101a97:	85 c0                	test   %eax,%eax
f0101a99:	79 24                	jns    f0101abf <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101a9b:	a1 58 52 23 f0       	mov    0xf0235258,%eax
f0101aa0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101aa4:	8b 43 48             	mov    0x48(%ebx),%eax
f0101aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101aab:	c7 04 24 18 75 10 f0 	movl   $0xf0107518,(%esp)
f0101ab2:	e8 34 2b 00 00       	call   f01045eb <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101ab7:	89 1c 24             	mov    %ebx,(%esp)
f0101aba:	e8 04 25 00 00       	call   f0103fc3 <env_destroy>
	}
}
f0101abf:	83 c4 14             	add    $0x14,%esp
f0101ac2:	5b                   	pop    %ebx
f0101ac3:	5d                   	pop    %ebp
f0101ac4:	c3                   	ret    

f0101ac5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101ac5:	55                   	push   %ebp
f0101ac6:	89 e5                	mov    %esp,%ebp
f0101ac8:	53                   	push   %ebx
f0101ac9:	83 ec 14             	sub    $0x14,%esp
f0101acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t* pte = pgdir_walk(pgdir, (void *)va, 0);
f0101acf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ad6:	00 
f0101ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ada:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ade:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ae1:	89 04 24             	mov    %eax,(%esp)
f0101ae4:	e8 0a fe ff ff       	call   f01018f3 <pgdir_walk>
	if (pte_store != 0)
f0101ae9:	85 db                	test   %ebx,%ebx
f0101aeb:	74 02                	je     f0101aef <page_lookup+0x2a>
		*pte_store = pte;
f0101aed:	89 03                	mov    %eax,(%ebx)
	//stone: here i miss "pte != NULL" and debug for a long time, it's important cuz "*pte & PTE_P" only means the page is not presented, 
	//but not mean *pte present or not.
	if ((pte != NULL) && (*pte & PTE_P)){
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	74 38                	je     f0101b2b <page_lookup+0x66>
f0101af3:	8b 00                	mov    (%eax),%eax
f0101af5:	a8 01                	test   $0x1,%al
f0101af7:	74 32                	je     f0101b2b <page_lookup+0x66>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101af9:	c1 e8 0c             	shr    $0xc,%eax
f0101afc:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f0101b02:	72 1c                	jb     f0101b20 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101b04:	c7 44 24 08 50 75 10 	movl   $0xf0107550,0x8(%esp)
f0101b0b:	f0 
f0101b0c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101b13:	00 
f0101b14:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0101b1b:	e8 65 e5 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101b20:	c1 e0 03             	shl    $0x3,%eax
f0101b23:	03 05 10 5f 23 f0    	add    0xf0235f10,%eax
		struct Page* result = pa2page(PTE_ADDR(*pte));
		return result;
f0101b29:	eb 05                	jmp    f0101b30 <page_lookup+0x6b>
f0101b2b:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	else 
		return NULL;
}
f0101b30:	83 c4 14             	add    $0x14,%esp
f0101b33:	5b                   	pop    %ebx
f0101b34:	5d                   	pop    %ebp
f0101b35:	c3                   	ret    

f0101b36 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101b36:	55                   	push   %ebp
f0101b37:	89 e5                	mov    %esp,%ebp
f0101b39:	83 ec 28             	sub    $0x28,%esp
f0101b3c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101b3f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101b42:	8b 75 08             	mov    0x8(%ebp),%esi
f0101b45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t* pte;
	struct Page* pp = page_lookup(pgdir, va, &pte);
f0101b48:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101b4b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b53:	89 34 24             	mov    %esi,(%esp)
f0101b56:	e8 6a ff ff ff       	call   f0101ac5 <page_lookup>
	if (pp != NULL){
f0101b5b:	85 c0                	test   %eax,%eax
f0101b5d:	74 1d                	je     f0101b7c <page_remove+0x46>
		*pte = 0;
f0101b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101b62:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(pp);
f0101b68:	89 04 24             	mov    %eax,(%esp)
f0101b6b:	e8 8c f3 ff ff       	call   f0100efc <page_decref>
		tlb_invalidate(pgdir, va);		
f0101b70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b74:	89 34 24             	mov    %esi,(%esp)
f0101b77:	e8 63 f4 ff ff       	call   f0100fdf <tlb_invalidate>
	}
	return;
}
f0101b7c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101b7f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101b82:	89 ec                	mov    %ebp,%esp
f0101b84:	5d                   	pop    %ebp
f0101b85:	c3                   	ret    

f0101b86 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101b86:	55                   	push   %ebp
f0101b87:	89 e5                	mov    %esp,%ebp
f0101b89:	83 ec 48             	sub    $0x48,%esp
f0101b8c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101b8f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101b92:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101b95:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101b98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101b9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101b9e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101ba5:	00 
f0101ba6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101baa:	89 3c 24             	mov    %edi,(%esp)
f0101bad:	e8 41 fd ff ff       	call   f01018f3 <pgdir_walk>
f0101bb2:	89 c2                	mov    %eax,%edx
	if (pte == NULL) return -E_NO_MEM;
f0101bb4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101bb9:	85 d2                	test   %edx,%edx
f0101bbb:	74 7b                	je     f0101c38 <page_insert+0xb2>
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
	// Fill this function in
	/*stone's solution for lab2*/
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101bbd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if (pte == NULL) return -E_NO_MEM;

	if (pp == page_lookup(pgdir, va, &pte)){
f0101bc0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bc3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bc7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bcb:	89 3c 24             	mov    %edi,(%esp)
f0101bce:	e8 f2 fe ff ff       	call   f0101ac5 <page_lookup>
f0101bd3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bd6:	39 d8                	cmp    %ebx,%eax
f0101bd8:	75 2f                	jne    f0101c09 <page_insert+0x83>
		tlb_invalidate(pgdir, va);
f0101bda:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bde:	89 3c 24             	mov    %edi,(%esp)
f0101be1:	e8 f9 f3 ff ff       	call   f0100fdf <tlb_invalidate>
		*pte = page2pa(pp) | perm | PTE_P;
f0101be6:	8b 45 14             	mov    0x14(%ebp),%eax
f0101be9:	83 c8 01             	or     $0x1,%eax
f0101bec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101bef:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0101bf5:	c1 fa 03             	sar    $0x3,%edx
f0101bf8:	c1 e2 0c             	shl    $0xc,%edx
f0101bfb:	09 c2                	or     %eax,%edx
f0101bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101c00:	89 10                	mov    %edx,(%eax)
f0101c02:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c07:	eb 2f                	jmp    f0101c38 <page_insert+0xb2>
	}
	else{
		page_remove(pgdir, va);
f0101c09:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c0d:	89 3c 24             	mov    %edi,(%esp)
f0101c10:	e8 21 ff ff ff       	call   f0101b36 <page_remove>
		pp->pp_ref++;
f0101c15:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		*pte = page2pa(pp) | perm | PTE_P;
f0101c1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c1d:	83 c8 01             	or     $0x1,%eax
f0101c20:	2b 1d 10 5f 23 f0    	sub    0xf0235f10,%ebx
f0101c26:	c1 fb 03             	sar    $0x3,%ebx
f0101c29:	c1 e3 0c             	shl    $0xc,%ebx
f0101c2c:	09 c3                	or     %eax,%ebx
f0101c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101c31:	89 18                	mov    %ebx,(%eax)
f0101c33:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return 0;
}
f0101c38:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101c3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101c3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101c41:	89 ec                	mov    %ebp,%esp
f0101c43:	5d                   	pop    %ebp
f0101c44:	c3                   	ret    

f0101c45 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101c45:	55                   	push   %ebp
f0101c46:	89 e5                	mov    %esp,%ebp
f0101c48:	57                   	push   %edi
f0101c49:	56                   	push   %esi
f0101c4a:	53                   	push   %ebx
f0101c4b:	83 ec 2c             	sub    $0x2c,%esp
f0101c4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
f0101c51:	c1 e9 0c             	shr    $0xc,%ecx
f0101c54:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
f0101c57:	85 c9                	test   %ecx,%ecx
f0101c59:	74 49                	je     f0101ca4 <boot_map_region+0x5f>
f0101c5b:	89 d6                	mov    %edx,%esi
f0101c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
f0101c62:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101c65:	83 cf 01             	or     $0x1,%edi
f0101c68:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101c70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
f0101c73:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101c7a:	00 
f0101c7b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101c82:	89 04 24             	mov    %eax,(%esp)
f0101c85:	e8 69 fc ff ff       	call   f01018f3 <pgdir_walk>
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
f0101c8a:	89 da                	mov    %ebx,%edx
f0101c8c:	c1 e2 0c             	shl    $0xc,%edx
f0101c8f:	03 55 e4             	add    -0x1c(%ebp),%edx
f0101c92:	09 fa                	or     %edi,%edx
f0101c94:	89 10                	mov    %edx,(%eax)
		vaddr = vaddr + PGSIZE;
f0101c96:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// Fill this function in
	/*stone's solution for lab2*/
	size_t pages = size / PGSIZE;
	size_t i;
	uintptr_t vaddr = va;
	for (i = 0; i < pages; i++){
f0101c9c:	83 c3 01             	add    $0x1,%ebx
f0101c9f:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0101ca2:	77 cf                	ja     f0101c73 <boot_map_region+0x2e>
		pte_t* pte = pgdir_walk(pgdir, (void*)vaddr, 1);
  		*pte = (PTE_ADDR(pa) + i * PGSIZE) | perm | PTE_P;	
		vaddr = vaddr + PGSIZE;
	}
}
f0101ca4:	83 c4 2c             	add    $0x2c,%esp
f0101ca7:	5b                   	pop    %ebx
f0101ca8:	5e                   	pop    %esi
f0101ca9:	5f                   	pop    %edi
f0101caa:	5d                   	pop    %ebp
f0101cab:	c3                   	ret    

f0101cac <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f0101cac:	55                   	push   %ebp
f0101cad:	89 e5                	mov    %esp,%ebp
f0101caf:	57                   	push   %edi
f0101cb0:	56                   	push   %esi
f0101cb1:	53                   	push   %ebx
f0101cb2:	83 ec 3c             	sub    $0x3c,%esp
	int i;
	extern pde_t entry_pgdir[];
	//cprintf("1");
	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cbc:	e8 ae fb ff ff       	call   f010186f <page_alloc>
f0101cc1:	89 c6                	mov    %eax,%esi
f0101cc3:	85 c0                	test   %eax,%eax
f0101cc5:	75 24                	jne    f0101ceb <check_page+0x3f>
f0101cc7:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f0101cce:	f0 
f0101ccf:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101cd6:	f0 
f0101cd7:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0101cde:	00 
f0101cdf:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101ce6:	e8 9a e3 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ceb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cf2:	e8 78 fb ff ff       	call   f010186f <page_alloc>
f0101cf7:	89 c7                	mov    %eax,%edi
f0101cf9:	85 c0                	test   %eax,%eax
f0101cfb:	75 24                	jne    f0101d21 <check_page+0x75>
f0101cfd:	c7 44 24 0c 3a 7c 10 	movl   $0xf0107c3a,0xc(%esp)
f0101d04:	f0 
f0101d05:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101d0c:	f0 
f0101d0d:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f0101d14:	00 
f0101d15:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101d1c:	e8 64 e3 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d28:	e8 42 fb ff ff       	call   f010186f <page_alloc>
f0101d2d:	89 c3                	mov    %eax,%ebx
f0101d2f:	85 c0                	test   %eax,%eax
f0101d31:	75 24                	jne    f0101d57 <check_page+0xab>
f0101d33:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0101d3a:	f0 
f0101d3b:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101d42:	f0 
f0101d43:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f0101d4a:	00 
f0101d4b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101d52:	e8 2e e3 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d57:	39 fe                	cmp    %edi,%esi
f0101d59:	75 24                	jne    f0101d7f <check_page+0xd3>
f0101d5b:	c7 44 24 0c 66 7c 10 	movl   $0xf0107c66,0xc(%esp)
f0101d62:	f0 
f0101d63:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101d6a:	f0 
f0101d6b:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0101d72:	00 
f0101d73:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101d7a:	e8 06 e3 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d7f:	39 c7                	cmp    %eax,%edi
f0101d81:	74 04                	je     f0101d87 <check_page+0xdb>
f0101d83:	39 c6                	cmp    %eax,%esi
f0101d85:	75 24                	jne    f0101dab <check_page+0xff>
f0101d87:	c7 44 24 0c 70 75 10 	movl   $0xf0107570,0xc(%esp)
f0101d8e:	f0 
f0101d8f:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101d96:	f0 
f0101d97:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0101d9e:	00 
f0101d9f:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101da6:	e8 da e2 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101dab:	a1 50 52 23 f0       	mov    0xf0235250,%eax
f0101db0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101db3:	c7 05 50 52 23 f0 00 	movl   $0x0,0xf0235250
f0101dba:	00 00 00 
	//cprintf("1");
	// should be no free memory
	assert(!page_alloc(0));
f0101dbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dc4:	e8 a6 fa ff ff       	call   f010186f <page_alloc>
f0101dc9:	85 c0                	test   %eax,%eax
f0101dcb:	74 24                	je     f0101df1 <check_page+0x145>
f0101dcd:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0101dd4:	f0 
f0101dd5:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101ddc:	f0 
f0101ddd:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0101de4:	00 
f0101de5:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101dec:	e8 94 e2 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101df1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101df4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101df8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101dff:	00 
f0101e00:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0101e05:	89 04 24             	mov    %eax,(%esp)
f0101e08:	e8 b8 fc ff ff       	call   f0101ac5 <page_lookup>
f0101e0d:	85 c0                	test   %eax,%eax
f0101e0f:	74 24                	je     f0101e35 <check_page+0x189>
f0101e11:	c7 44 24 0c 90 75 10 	movl   $0xf0107590,0xc(%esp)
f0101e18:	f0 
f0101e19:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101e20:	f0 
f0101e21:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0101e28:	00 
f0101e29:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101e30:	e8 50 e2 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e35:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e3c:	00 
f0101e3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e44:	00 
f0101e45:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101e49:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0101e4e:	89 04 24             	mov    %eax,(%esp)
f0101e51:	e8 30 fd ff ff       	call   f0101b86 <page_insert>
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	78 24                	js     f0101e7e <check_page+0x1d2>
f0101e5a:	c7 44 24 0c c8 75 10 	movl   $0xf01075c8,0xc(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101e69:	f0 
f0101e6a:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0101e71:	00 
f0101e72:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101e79:	e8 07 e2 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101e7e:	89 34 24             	mov    %esi,(%esp)
f0101e81:	e8 5a f0 ff ff       	call   f0100ee0 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101e86:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e8d:	00 
f0101e8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e95:	00 
f0101e96:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101e9a:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0101e9f:	89 04 24             	mov    %eax,(%esp)
f0101ea2:	e8 df fc ff ff       	call   f0101b86 <page_insert>
f0101ea7:	85 c0                	test   %eax,%eax
f0101ea9:	74 24                	je     f0101ecf <check_page+0x223>
f0101eab:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f0101eb2:	f0 
f0101eb3:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101eba:	f0 
f0101ebb:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0101ec2:	00 
f0101ec3:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101eca:	e8 b6 e1 ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ecf:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ed4:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101ed7:	8b 08                	mov    (%eax),%ecx
f0101ed9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101edf:	89 f2                	mov    %esi,%edx
f0101ee1:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0101ee7:	c1 fa 03             	sar    $0x3,%edx
f0101eea:	c1 e2 0c             	shl    $0xc,%edx
f0101eed:	39 d1                	cmp    %edx,%ecx
f0101eef:	74 24                	je     f0101f15 <check_page+0x269>
f0101ef1:	c7 44 24 0c 28 76 10 	movl   $0xf0107628,0xc(%esp)
f0101ef8:	f0 
f0101ef9:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101f00:	f0 
f0101f01:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0101f08:	00 
f0101f09:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101f10:	e8 70 e1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101f15:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f1a:	e8 b4 f3 ff ff       	call   f01012d3 <check_va2pa>
f0101f1f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101f22:	89 fa                	mov    %edi,%edx
f0101f24:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0101f2a:	c1 fa 03             	sar    $0x3,%edx
f0101f2d:	c1 e2 0c             	shl    $0xc,%edx
f0101f30:	39 d0                	cmp    %edx,%eax
f0101f32:	74 24                	je     f0101f58 <check_page+0x2ac>
f0101f34:	c7 44 24 0c 50 76 10 	movl   $0xf0107650,0xc(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101f43:	f0 
f0101f44:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0101f4b:	00 
f0101f4c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101f53:	e8 2d e1 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101f58:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f5d:	74 24                	je     f0101f83 <check_page+0x2d7>
f0101f5f:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f0101f66:	f0 
f0101f67:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0101f76:	00 
f0101f77:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101f7e:	e8 02 e1 ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f0101f83:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f88:	74 24                	je     f0101fae <check_page+0x302>
f0101f8a:	c7 44 24 0c 98 7c 10 	movl   $0xf0107c98,0xc(%esp)
f0101f91:	f0 
f0101f92:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101f99:	f0 
f0101f9a:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0101fa1:	00 
f0101fa2:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101fa9:	e8 d7 e0 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	//// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fae:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fb5:	00 
f0101fb6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fbd:	00 
f0101fbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fc2:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0101fc7:	89 04 24             	mov    %eax,(%esp)
f0101fca:	e8 b7 fb ff ff       	call   f0101b86 <page_insert>
f0101fcf:	85 c0                	test   %eax,%eax
f0101fd1:	74 24                	je     f0101ff7 <check_page+0x34b>
f0101fd3:	c7 44 24 0c 80 76 10 	movl   $0xf0107680,0xc(%esp)
f0101fda:	f0 
f0101fdb:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0101fe2:	f0 
f0101fe3:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0101fea:	00 
f0101feb:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0101ff2:	e8 8e e0 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ff7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ffc:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102001:	e8 cd f2 ff ff       	call   f01012d3 <check_va2pa>
f0102006:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0102009:	89 da                	mov    %ebx,%edx
f010200b:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102011:	c1 fa 03             	sar    $0x3,%edx
f0102014:	c1 e2 0c             	shl    $0xc,%edx
f0102017:	39 d0                	cmp    %edx,%eax
f0102019:	74 24                	je     f010203f <check_page+0x393>
f010201b:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f0102022:	f0 
f0102023:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010202a:	f0 
f010202b:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102032:	00 
f0102033:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010203a:	e8 46 e0 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010203f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102044:	74 24                	je     f010206a <check_page+0x3be>
f0102046:	c7 44 24 0c a9 7c 10 	movl   $0xf0107ca9,0xc(%esp)
f010204d:	f0 
f010204e:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102055:	f0 
f0102056:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f010205d:	00 
f010205e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102065:	e8 1b e0 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// should be no free memory
	assert(!page_alloc(0));
f010206a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102071:	e8 f9 f7 ff ff       	call   f010186f <page_alloc>
f0102076:	85 c0                	test   %eax,%eax
f0102078:	74 24                	je     f010209e <check_page+0x3f2>
f010207a:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0102081:	f0 
f0102082:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102089:	f0 
f010208a:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102091:	00 
f0102092:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102099:	e8 e7 df ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010209e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020a5:	00 
f01020a6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020ad:	00 
f01020ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020b2:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01020b7:	89 04 24             	mov    %eax,(%esp)
f01020ba:	e8 c7 fa ff ff       	call   f0101b86 <page_insert>
f01020bf:	85 c0                	test   %eax,%eax
f01020c1:	74 24                	je     f01020e7 <check_page+0x43b>
f01020c3:	c7 44 24 0c 80 76 10 	movl   $0xf0107680,0xc(%esp)
f01020ca:	f0 
f01020cb:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01020d2:	f0 
f01020d3:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f01020da:	00 
f01020db:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01020e2:	e8 9e df ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020e7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ec:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01020f1:	e8 dd f1 ff ff       	call   f01012d3 <check_va2pa>
f01020f6:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01020f9:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f01020ff:	c1 fa 03             	sar    $0x3,%edx
f0102102:	c1 e2 0c             	shl    $0xc,%edx
f0102105:	39 d0                	cmp    %edx,%eax
f0102107:	74 24                	je     f010212d <check_page+0x481>
f0102109:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f0102110:	f0 
f0102111:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102118:	f0 
f0102119:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102120:	00 
f0102121:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102128:	e8 58 df ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010212d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102132:	74 24                	je     f0102158 <check_page+0x4ac>
f0102134:	c7 44 24 0c a9 7c 10 	movl   $0xf0107ca9,0xc(%esp)
f010213b:	f0 
f010213c:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102153:	e8 2d df ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	//error	
	//cprintf("1");
	assert(!page_alloc(0));
f0102158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010215f:	e8 0b f7 ff ff       	call   f010186f <page_alloc>
f0102164:	85 c0                	test   %eax,%eax
f0102166:	74 24                	je     f010218c <check_page+0x4e0>
f0102168:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f010216f:	f0 
f0102170:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102177:	f0 
f0102178:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f010217f:	00 
f0102180:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102187:	e8 f9 de ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010218c:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102191:	8b 00                	mov    (%eax),%eax
f0102193:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102198:	89 c2                	mov    %eax,%edx
f010219a:	c1 ea 0c             	shr    $0xc,%edx
f010219d:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f01021a3:	72 20                	jb     f01021c5 <check_page+0x519>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021a9:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01021b0:	f0 
f01021b1:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01021b8:	00 
f01021b9:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01021c0:	e8 c0 de ff ff       	call   f0100085 <_panic>
f01021c5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01021cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021d4:	00 
f01021d5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021dc:	00 
f01021dd:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01021e2:	89 04 24             	mov    %eax,(%esp)
f01021e5:	e8 09 f7 ff ff       	call   f01018f3 <pgdir_walk>
f01021ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01021ed:	83 c2 04             	add    $0x4,%edx
f01021f0:	39 d0                	cmp    %edx,%eax
f01021f2:	74 24                	je     f0102218 <check_page+0x56c>
f01021f4:	c7 44 24 0c ec 76 10 	movl   $0xf01076ec,0xc(%esp)
f01021fb:	f0 
f01021fc:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102203:	f0 
f0102204:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f010220b:	00 
f010220c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102213:	e8 6d de ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102218:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010221f:	00 
f0102220:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102227:	00 
f0102228:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010222c:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102231:	89 04 24             	mov    %eax,(%esp)
f0102234:	e8 4d f9 ff ff       	call   f0101b86 <page_insert>
f0102239:	85 c0                	test   %eax,%eax
f010223b:	74 24                	je     f0102261 <check_page+0x5b5>
f010223d:	c7 44 24 0c 2c 77 10 	movl   $0xf010772c,0xc(%esp)
f0102244:	f0 
f0102245:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010224c:	f0 
f010224d:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0102254:	00 
f0102255:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010225c:	e8 24 de ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102261:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102266:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010226b:	e8 63 f0 ff ff       	call   f01012d3 <check_va2pa>
f0102270:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102273:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102279:	c1 fa 03             	sar    $0x3,%edx
f010227c:	c1 e2 0c             	shl    $0xc,%edx
f010227f:	39 d0                	cmp    %edx,%eax
f0102281:	74 24                	je     f01022a7 <check_page+0x5fb>
f0102283:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f010228a:	f0 
f010228b:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102292:	f0 
f0102293:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f010229a:	00 
f010229b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01022a2:	e8 de dd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01022a7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022ac:	74 24                	je     f01022d2 <check_page+0x626>
f01022ae:	c7 44 24 0c a9 7c 10 	movl   $0xf0107ca9,0xc(%esp)
f01022b5:	f0 
f01022b6:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01022bd:	f0 
f01022be:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01022c5:	00 
f01022c6:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01022cd:	e8 b3 dd ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01022d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022d9:	00 
f01022da:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022e1:	00 
f01022e2:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01022e7:	89 04 24             	mov    %eax,(%esp)
f01022ea:	e8 04 f6 ff ff       	call   f01018f3 <pgdir_walk>
f01022ef:	f6 00 04             	testb  $0x4,(%eax)
f01022f2:	75 24                	jne    f0102318 <check_page+0x66c>
f01022f4:	c7 44 24 0c 6c 77 10 	movl   $0xf010776c,0xc(%esp)
f01022fb:	f0 
f01022fc:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102303:	f0 
f0102304:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f010230b:	00 
f010230c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102313:	e8 6d dd ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102318:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010231d:	f6 00 04             	testb  $0x4,(%eax)
f0102320:	75 24                	jne    f0102346 <check_page+0x69a>
f0102322:	c7 44 24 0c ba 7c 10 	movl   $0xf0107cba,0xc(%esp)
f0102329:	f0 
f010232a:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102331:	f0 
f0102332:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0102339:	00 
f010233a:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102341:	e8 3f dd ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	//error	
	//cprintf("1");
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102346:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010234d:	00 
f010234e:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102355:	00 
f0102356:	89 74 24 04          	mov    %esi,0x4(%esp)
f010235a:	89 04 24             	mov    %eax,(%esp)
f010235d:	e8 24 f8 ff ff       	call   f0101b86 <page_insert>
f0102362:	85 c0                	test   %eax,%eax
f0102364:	78 24                	js     f010238a <check_page+0x6de>
f0102366:	c7 44 24 0c a0 77 10 	movl   $0xf01077a0,0xc(%esp)
f010236d:	f0 
f010236e:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102375:	f0 
f0102376:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f010237d:	00 
f010237e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102385:	e8 fb dc ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010238a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102391:	00 
f0102392:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102399:	00 
f010239a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010239e:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01023a3:	89 04 24             	mov    %eax,(%esp)
f01023a6:	e8 db f7 ff ff       	call   f0101b86 <page_insert>
f01023ab:	85 c0                	test   %eax,%eax
f01023ad:	74 24                	je     f01023d3 <check_page+0x727>
f01023af:	c7 44 24 0c d8 77 10 	movl   $0xf01077d8,0xc(%esp)
f01023b6:	f0 
f01023b7:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01023be:	f0 
f01023bf:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f01023c6:	00 
f01023c7:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01023ce:	e8 b2 dc ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023da:	00 
f01023db:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023e2:	00 
f01023e3:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01023e8:	89 04 24             	mov    %eax,(%esp)
f01023eb:	e8 03 f5 ff ff       	call   f01018f3 <pgdir_walk>
f01023f0:	f6 00 04             	testb  $0x4,(%eax)
f01023f3:	74 24                	je     f0102419 <check_page+0x76d>
f01023f5:	c7 44 24 0c 14 78 10 	movl   $0xf0107814,0xc(%esp)
f01023fc:	f0 
f01023fd:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102404:	f0 
f0102405:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f010240c:	00 
f010240d:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102414:	e8 6c dc ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102419:	ba 00 00 00 00       	mov    $0x0,%edx
f010241e:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102423:	e8 ab ee ff ff       	call   f01012d3 <check_va2pa>
f0102428:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010242b:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102431:	c1 fa 03             	sar    $0x3,%edx
f0102434:	c1 e2 0c             	shl    $0xc,%edx
f0102437:	39 d0                	cmp    %edx,%eax
f0102439:	74 24                	je     f010245f <check_page+0x7b3>
f010243b:	c7 44 24 0c 4c 78 10 	movl   $0xf010784c,0xc(%esp)
f0102442:	f0 
f0102443:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010244a:	f0 
f010244b:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f0102452:	00 
f0102453:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010245a:	e8 26 dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010245f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102464:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102469:	e8 65 ee ff ff       	call   f01012d3 <check_va2pa>
f010246e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102471:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102477:	c1 fa 03             	sar    $0x3,%edx
f010247a:	c1 e2 0c             	shl    $0xc,%edx
f010247d:	39 d0                	cmp    %edx,%eax
f010247f:	74 24                	je     f01024a5 <check_page+0x7f9>
f0102481:	c7 44 24 0c 78 78 10 	movl   $0xf0107878,0xc(%esp)
f0102488:	f0 
f0102489:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102490:	f0 
f0102491:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102498:	00 
f0102499:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01024a0:	e8 e0 db ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01024a5:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01024aa:	74 24                	je     f01024d0 <check_page+0x824>
f01024ac:	c7 44 24 0c d0 7c 10 	movl   $0xf0107cd0,0xc(%esp)
f01024b3:	f0 
f01024b4:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01024bb:	f0 
f01024bc:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f01024c3:	00 
f01024c4:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01024cb:	e8 b5 db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f01024d0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024d5:	74 24                	je     f01024fb <check_page+0x84f>
f01024d7:	c7 44 24 0c e1 7c 10 	movl   $0xf0107ce1,0xc(%esp)
f01024de:	f0 
f01024df:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01024e6:	f0 
f01024e7:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f01024ee:	00 
f01024ef:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01024f6:	e8 8a db ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01024fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102502:	e8 68 f3 ff ff       	call   f010186f <page_alloc>
f0102507:	85 c0                	test   %eax,%eax
f0102509:	74 04                	je     f010250f <check_page+0x863>
f010250b:	39 c3                	cmp    %eax,%ebx
f010250d:	74 24                	je     f0102533 <check_page+0x887>
f010250f:	c7 44 24 0c a8 78 10 	movl   $0xf01078a8,0xc(%esp)
f0102516:	f0 
f0102517:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010251e:	f0 
f010251f:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0102526:	00 
f0102527:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010252e:	e8 52 db ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102533:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010253a:	00 
f010253b:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102540:	89 04 24             	mov    %eax,(%esp)
f0102543:	e8 ee f5 ff ff       	call   f0101b36 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102548:	ba 00 00 00 00       	mov    $0x0,%edx
f010254d:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102552:	e8 7c ed ff ff       	call   f01012d3 <check_va2pa>
f0102557:	83 f8 ff             	cmp    $0xffffffff,%eax
f010255a:	74 24                	je     f0102580 <check_page+0x8d4>
f010255c:	c7 44 24 0c cc 78 10 	movl   $0xf01078cc,0xc(%esp)
f0102563:	f0 
f0102564:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010256b:	f0 
f010256c:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0102573:	00 
f0102574:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010257b:	e8 05 db ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102580:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102585:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010258a:	e8 44 ed ff ff       	call   f01012d3 <check_va2pa>
f010258f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102592:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102598:	c1 fa 03             	sar    $0x3,%edx
f010259b:	c1 e2 0c             	shl    $0xc,%edx
f010259e:	39 d0                	cmp    %edx,%eax
f01025a0:	74 24                	je     f01025c6 <check_page+0x91a>
f01025a2:	c7 44 24 0c 78 78 10 	movl   $0xf0107878,0xc(%esp)
f01025a9:	f0 
f01025aa:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01025b1:	f0 
f01025b2:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f01025b9:	00 
f01025ba:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01025c1:	e8 bf da ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f01025c6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025cb:	74 24                	je     f01025f1 <check_page+0x945>
f01025cd:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f01025d4:	f0 
f01025d5:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01025dc:	f0 
f01025dd:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f01025e4:	00 
f01025e5:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01025ec:	e8 94 da ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f01025f1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025f6:	74 24                	je     f010261c <check_page+0x970>
f01025f8:	c7 44 24 0c e1 7c 10 	movl   $0xf0107ce1,0xc(%esp)
f01025ff:	f0 
f0102600:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102607:	f0 
f0102608:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f010260f:	00 
f0102610:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102617:	e8 69 da ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010261c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102623:	00 
f0102624:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102629:	89 04 24             	mov    %eax,(%esp)
f010262c:	e8 05 f5 ff ff       	call   f0101b36 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102631:	ba 00 00 00 00       	mov    $0x0,%edx
f0102636:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010263b:	e8 93 ec ff ff       	call   f01012d3 <check_va2pa>
f0102640:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102643:	74 24                	je     f0102669 <check_page+0x9bd>
f0102645:	c7 44 24 0c cc 78 10 	movl   $0xf01078cc,0xc(%esp)
f010264c:	f0 
f010264d:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102654:	f0 
f0102655:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f010265c:	00 
f010265d:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102664:	e8 1c da ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102669:	ba 00 10 00 00       	mov    $0x1000,%edx
f010266e:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102673:	e8 5b ec ff ff       	call   f01012d3 <check_va2pa>
f0102678:	83 f8 ff             	cmp    $0xffffffff,%eax
f010267b:	74 24                	je     f01026a1 <check_page+0x9f5>
f010267d:	c7 44 24 0c f0 78 10 	movl   $0xf01078f0,0xc(%esp)
f0102684:	f0 
f0102685:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010268c:	f0 
f010268d:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0102694:	00 
f0102695:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010269c:	e8 e4 d9 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01026a1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026a6:	74 24                	je     f01026cc <check_page+0xa20>
f01026a8:	c7 44 24 0c f2 7c 10 	movl   $0xf0107cf2,0xc(%esp)
f01026af:	f0 
f01026b0:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01026b7:	f0 
f01026b8:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f01026bf:	00 
f01026c0:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01026c7:	e8 b9 d9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f01026cc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026d1:	74 24                	je     f01026f7 <check_page+0xa4b>
f01026d3:	c7 44 24 0c e1 7c 10 	movl   $0xf0107ce1,0xc(%esp)
f01026da:	f0 
f01026db:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01026e2:	f0 
f01026e3:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f01026ea:	00 
f01026eb:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01026f2:	e8 8e d9 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026fe:	e8 6c f1 ff ff       	call   f010186f <page_alloc>
f0102703:	85 c0                	test   %eax,%eax
f0102705:	74 04                	je     f010270b <check_page+0xa5f>
f0102707:	39 c7                	cmp    %eax,%edi
f0102709:	74 24                	je     f010272f <check_page+0xa83>
f010270b:	c7 44 24 0c 18 79 10 	movl   $0xf0107918,0xc(%esp)
f0102712:	f0 
f0102713:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010271a:	f0 
f010271b:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102722:	00 
f0102723:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010272a:	e8 56 d9 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	//error	
	assert(!page_alloc(0));
f010272f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102736:	e8 34 f1 ff ff       	call   f010186f <page_alloc>
f010273b:	85 c0                	test   %eax,%eax
f010273d:	74 24                	je     f0102763 <check_page+0xab7>
f010273f:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0102746:	f0 
f0102747:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010274e:	f0 
f010274f:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0102756:	00 
f0102757:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010275e:	e8 22 d9 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102763:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0102768:	8b 08                	mov    (%eax),%ecx
f010276a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102770:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102773:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102779:	c1 fa 03             	sar    $0x3,%edx
f010277c:	c1 e2 0c             	shl    $0xc,%edx
f010277f:	39 d1                	cmp    %edx,%ecx
f0102781:	74 24                	je     f01027a7 <check_page+0xafb>
f0102783:	c7 44 24 0c 28 76 10 	movl   $0xf0107628,0xc(%esp)
f010278a:	f0 
f010278b:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102792:	f0 
f0102793:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f010279a:	00 
f010279b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01027a2:	e8 de d8 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f01027a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027ad:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027b2:	74 24                	je     f01027d8 <check_page+0xb2c>
f01027b4:	c7 44 24 0c 98 7c 10 	movl   $0xf0107c98,0xc(%esp)
f01027bb:	f0 
f01027bc:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01027c3:	f0 
f01027c4:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f01027cb:	00 
f01027cc:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01027d3:	e8 ad d8 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f01027d8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027de:	89 34 24             	mov    %esi,(%esp)
f01027e1:	e8 fa e6 ff ff       	call   f0100ee0 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027e6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027ed:	00 
f01027ee:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027f5:	00 
f01027f6:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01027fb:	89 04 24             	mov    %eax,(%esp)
f01027fe:	e8 f0 f0 ff ff       	call   f01018f3 <pgdir_walk>
f0102803:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102806:	8b 0d 0c 5f 23 f0    	mov    0xf0235f0c,%ecx
f010280c:	83 c1 04             	add    $0x4,%ecx
f010280f:	8b 11                	mov    (%ecx),%edx
f0102811:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102817:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010281a:	c1 ea 0c             	shr    $0xc,%edx
f010281d:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0102823:	72 23                	jb     f0102848 <check_page+0xb9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102825:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102828:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010282c:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0102833:	f0 
f0102834:	c7 44 24 04 89 04 00 	movl   $0x489,0x4(%esp)
f010283b:	00 
f010283c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102843:	e8 3d d8 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102848:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010284b:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102851:	39 d0                	cmp    %edx,%eax
f0102853:	74 24                	je     f0102879 <check_page+0xbcd>
f0102855:	c7 44 24 0c 03 7d 10 	movl   $0xf0107d03,0xc(%esp)
f010285c:	f0 
f010285d:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102864:	f0 
f0102865:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f010286c:	00 
f010286d:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102874:	e8 0c d8 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102879:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f010287f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102885:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102888:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f010288e:	c1 f8 03             	sar    $0x3,%eax
f0102891:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102894:	89 c2                	mov    %eax,%edx
f0102896:	c1 ea 0c             	shr    $0xc,%edx
f0102899:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f010289f:	72 20                	jb     f01028c1 <check_page+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028a5:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01028ac:	f0 
f01028ad:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01028b4:	00 
f01028b5:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f01028bc:	e8 c4 d7 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01028c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028c8:	00 
f01028c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01028d0:	00 
f01028d1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028d6:	89 04 24             	mov    %eax,(%esp)
f01028d9:	e8 88 36 00 00       	call   f0105f66 <memset>
	page_free(pp0);
f01028de:	89 34 24             	mov    %esi,(%esp)
f01028e1:	e8 fa e5 ff ff       	call   f0100ee0 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028e6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028ed:	00 
f01028ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028f5:	00 
f01028f6:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01028fb:	89 04 24             	mov    %eax,(%esp)
f01028fe:	e8 f0 ef ff ff       	call   f01018f3 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102903:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102906:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f010290c:	c1 fa 03             	sar    $0x3,%edx
f010290f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102912:	89 d0                	mov    %edx,%eax
f0102914:	c1 e8 0c             	shr    $0xc,%eax
f0102917:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f010291d:	72 20                	jb     f010293f <check_page+0xc93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010291f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102923:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f010292a:	f0 
f010292b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102932:	00 
f0102933:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f010293a:	e8 46 d7 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f010293f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102945:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102948:	f6 00 01             	testb  $0x1,(%eax)
f010294b:	75 11                	jne    f010295e <check_page+0xcb2>
f010294d:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
}


// check page_insert, page_remove, &c
static void
check_page(void)
f0102953:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102959:	f6 00 01             	testb  $0x1,(%eax)
f010295c:	74 24                	je     f0102982 <check_page+0xcd6>
f010295e:	c7 44 24 0c 1b 7d 10 	movl   $0xf0107d1b,0xc(%esp)
f0102965:	f0 
f0102966:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010296d:	f0 
f010296e:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f0102975:	00 
f0102976:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010297d:	e8 03 d7 ff ff       	call   f0100085 <_panic>
f0102982:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102985:	39 d0                	cmp    %edx,%eax
f0102987:	75 d0                	jne    f0102959 <check_page+0xcad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102989:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010298e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102994:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010299a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010299d:	a3 50 52 23 f0       	mov    %eax,0xf0235250

	// free the pages we took
	page_free(pp0);
f01029a2:	89 34 24             	mov    %esi,(%esp)
f01029a5:	e8 36 e5 ff ff       	call   f0100ee0 <page_free>
	page_free(pp1);
f01029aa:	89 3c 24             	mov    %edi,(%esp)
f01029ad:	e8 2e e5 ff ff       	call   f0100ee0 <page_free>
	page_free(pp2);
f01029b2:	89 1c 24             	mov    %ebx,(%esp)
f01029b5:	e8 26 e5 ff ff       	call   f0100ee0 <page_free>

	cprintf("check_page() succeeded!\n");
f01029ba:	c7 04 24 32 7d 10 f0 	movl   $0xf0107d32,(%esp)
f01029c1:	e8 25 1c 00 00       	call   f01045eb <cprintf>
}
f01029c6:	83 c4 3c             	add    $0x3c,%esp
f01029c9:	5b                   	pop    %ebx
f01029ca:	5e                   	pop    %esi
f01029cb:	5f                   	pop    %edi
f01029cc:	5d                   	pop    %ebp
f01029cd:	c3                   	ret    

f01029ce <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01029ce:	55                   	push   %ebp
f01029cf:	89 e5                	mov    %esp,%ebp
f01029d1:	57                   	push   %edi
f01029d2:	56                   	push   %esi
f01029d3:	53                   	push   %ebx
f01029d4:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01029d7:	b8 15 00 00 00       	mov    $0x15,%eax
f01029dc:	e8 33 e6 ff ff       	call   f0101014 <nvram_read>
f01029e1:	c1 e0 0a             	shl    $0xa,%eax
f01029e4:	89 c2                	mov    %eax,%edx
f01029e6:	c1 fa 1f             	sar    $0x1f,%edx
f01029e9:	c1 ea 14             	shr    $0x14,%edx
f01029ec:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01029ef:	c1 f8 0c             	sar    $0xc,%eax
f01029f2:	a3 4c 52 23 f0       	mov    %eax,0xf023524c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01029f7:	b8 17 00 00 00       	mov    $0x17,%eax
f01029fc:	e8 13 e6 ff ff       	call   f0101014 <nvram_read>
f0102a01:	c1 e0 0a             	shl    $0xa,%eax
f0102a04:	89 c2                	mov    %eax,%edx
f0102a06:	c1 fa 1f             	sar    $0x1f,%edx
f0102a09:	c1 ea 14             	shr    $0x14,%edx
f0102a0c:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0102a0f:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0102a12:	85 c0                	test   %eax,%eax
f0102a14:	74 0e                	je     f0102a24 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0102a16:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0102a1c:	89 15 08 5f 23 f0    	mov    %edx,0xf0235f08
f0102a22:	eb 0c                	jmp    f0102a30 <mem_init+0x62>
	else
		npages = npages_basemem;
f0102a24:	8b 15 4c 52 23 f0    	mov    0xf023524c,%edx
f0102a2a:	89 15 08 5f 23 f0    	mov    %edx,0xf0235f08

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0102a30:	c1 e0 0c             	shl    $0xc,%eax
f0102a33:	c1 e8 0a             	shr    $0xa,%eax
f0102a36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a3a:	a1 4c 52 23 f0       	mov    0xf023524c,%eax
f0102a3f:	c1 e0 0c             	shl    $0xc,%eax
f0102a42:	c1 e8 0a             	shr    $0xa,%eax
f0102a45:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102a49:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f0102a4e:	c1 e0 0c             	shl    $0xc,%eax
f0102a51:	c1 e8 0a             	shr    $0xa,%eax
f0102a54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a58:	c7 04 24 3c 79 10 f0 	movl   $0xf010793c,(%esp)
f0102a5f:	e8 87 1b 00 00       	call   f01045eb <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102a64:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102a69:	e8 cb e8 ff ff       	call   f0101339 <boot_alloc>
f0102a6e:	a3 0c 5f 23 f0       	mov    %eax,0xf0235f0c
	memset(kern_pgdir, 0, PGSIZE);
f0102a73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a7a:	00 
f0102a7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a82:	00 
f0102a83:	89 04 24             	mov    %eax,(%esp)
f0102a86:	e8 db 34 00 00       	call   f0105f66 <memset>
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	//user writeable
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102a8b:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a90:	89 c2                	mov    %eax,%edx
f0102a92:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a97:	77 20                	ja     f0102ab9 <mem_init+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a9d:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0102aa4:	f0 
f0102aa5:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0102aac:	00 
f0102aad:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102ab4:	e8 cc d5 ff ff       	call   f0100085 <_panic>
f0102ab9:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102abf:	83 ca 05             	or     $0x5,%edx
f0102ac2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
//<<<<<<< HEAD
	/*stone's solution for lab2*/
	pages = (struct Page*) boot_alloc(npages * sizeof(struct Page));
f0102ac8:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f0102acd:	c1 e0 03             	shl    $0x3,%eax
f0102ad0:	e8 64 e8 ff ff       	call   f0101339 <boot_alloc>
f0102ad5:	a3 10 5f 23 f0       	mov    %eax,0xf0235f10

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	envs = boot_alloc(NENV * sizeof(struct Env));
f0102ada:	b8 00 00 02 00       	mov    $0x20000,%eax
f0102adf:	e8 55 e8 ff ff       	call   f0101339 <boot_alloc>
f0102ae4:	a3 5c 52 23 f0       	mov    %eax,0xf023525c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102ae9:	e8 f4 e8 ff ff       	call   f01013e2 <page_init>

	check_page_free_list(1);
f0102aee:	b8 01 00 00 00       	mov    $0x1,%eax
f0102af3:	e8 d3 e9 ff ff       	call   f01014cb <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0102af8:	83 3d 10 5f 23 f0 00 	cmpl   $0x0,0xf0235f10
f0102aff:	75 1c                	jne    f0102b1d <mem_init+0x14f>
		panic("'pages' is a null pointer!");
f0102b01:	c7 44 24 08 4b 7d 10 	movl   $0xf0107d4b,0x8(%esp)
f0102b08:	f0 
f0102b09:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102b10:	00 
f0102b11:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102b18:	e8 68 d5 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102b1d:	a1 50 52 23 f0       	mov    0xf0235250,%eax
f0102b22:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b27:	85 c0                	test   %eax,%eax
f0102b29:	74 09                	je     f0102b34 <mem_init+0x166>
		++nfree;
f0102b2b:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102b2e:	8b 00                	mov    (%eax),%eax
f0102b30:	85 c0                	test   %eax,%eax
f0102b32:	75 f7                	jne    f0102b2b <mem_init+0x15d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b3b:	e8 2f ed ff ff       	call   f010186f <page_alloc>
f0102b40:	89 c6                	mov    %eax,%esi
f0102b42:	85 c0                	test   %eax,%eax
f0102b44:	75 24                	jne    f0102b6a <mem_init+0x19c>
f0102b46:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f0102b4d:	f0 
f0102b4e:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102b55:	f0 
f0102b56:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0102b5d:	00 
f0102b5e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102b65:	e8 1b d5 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b71:	e8 f9 ec ff ff       	call   f010186f <page_alloc>
f0102b76:	89 c7                	mov    %eax,%edi
f0102b78:	85 c0                	test   %eax,%eax
f0102b7a:	75 24                	jne    f0102ba0 <mem_init+0x1d2>
f0102b7c:	c7 44 24 0c 3a 7c 10 	movl   $0xf0107c3a,0xc(%esp)
f0102b83:	f0 
f0102b84:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102b8b:	f0 
f0102b8c:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0102b93:	00 
f0102b94:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102b9b:	e8 e5 d4 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ba0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ba7:	e8 c3 ec ff ff       	call   f010186f <page_alloc>
f0102bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102baf:	85 c0                	test   %eax,%eax
f0102bb1:	75 24                	jne    f0102bd7 <mem_init+0x209>
f0102bb3:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0102bba:	f0 
f0102bbb:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102bc2:	f0 
f0102bc3:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102bca:	00 
f0102bcb:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102bd2:	e8 ae d4 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102bd7:	39 fe                	cmp    %edi,%esi
f0102bd9:	75 24                	jne    f0102bff <mem_init+0x231>
f0102bdb:	c7 44 24 0c 66 7c 10 	movl   $0xf0107c66,0xc(%esp)
f0102be2:	f0 
f0102be3:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102bea:	f0 
f0102beb:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0102bf2:	00 
f0102bf3:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102bfa:	e8 86 d4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102bff:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102c02:	74 05                	je     f0102c09 <mem_init+0x23b>
f0102c04:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102c07:	75 24                	jne    f0102c2d <mem_init+0x25f>
f0102c09:	c7 44 24 0c 70 75 10 	movl   $0xf0107570,0xc(%esp)
f0102c10:	f0 
f0102c11:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102c18:	f0 
f0102c19:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102c20:	00 
f0102c21:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102c28:	e8 58 d4 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c2d:	8b 15 10 5f 23 f0    	mov    0xf0235f10,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102c33:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f0102c38:	c1 e0 0c             	shl    $0xc,%eax
f0102c3b:	89 f1                	mov    %esi,%ecx
f0102c3d:	29 d1                	sub    %edx,%ecx
f0102c3f:	c1 f9 03             	sar    $0x3,%ecx
f0102c42:	c1 e1 0c             	shl    $0xc,%ecx
f0102c45:	39 c1                	cmp    %eax,%ecx
f0102c47:	72 24                	jb     f0102c6d <mem_init+0x29f>
f0102c49:	c7 44 24 0c 66 7d 10 	movl   $0xf0107d66,0xc(%esp)
f0102c50:	f0 
f0102c51:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102c58:	f0 
f0102c59:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102c60:	00 
f0102c61:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102c68:	e8 18 d4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102c6d:	89 f9                	mov    %edi,%ecx
f0102c6f:	29 d1                	sub    %edx,%ecx
f0102c71:	c1 f9 03             	sar    $0x3,%ecx
f0102c74:	c1 e1 0c             	shl    $0xc,%ecx
f0102c77:	39 c8                	cmp    %ecx,%eax
f0102c79:	77 24                	ja     f0102c9f <mem_init+0x2d1>
f0102c7b:	c7 44 24 0c 83 7d 10 	movl   $0xf0107d83,0xc(%esp)
f0102c82:	f0 
f0102c83:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102c8a:	f0 
f0102c8b:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102c92:	00 
f0102c93:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102c9a:	e8 e6 d3 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102c9f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102ca2:	29 d1                	sub    %edx,%ecx
f0102ca4:	89 ca                	mov    %ecx,%edx
f0102ca6:	c1 fa 03             	sar    $0x3,%edx
f0102ca9:	c1 e2 0c             	shl    $0xc,%edx
f0102cac:	39 d0                	cmp    %edx,%eax
f0102cae:	77 24                	ja     f0102cd4 <mem_init+0x306>
f0102cb0:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102cb7:	f0 
f0102cb8:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102cbf:	f0 
f0102cc0:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0102cc7:	00 
f0102cc8:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102ccf:	e8 b1 d3 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102cd4:	a1 50 52 23 f0       	mov    0xf0235250,%eax
f0102cd9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f0102cdc:	c7 05 50 52 23 f0 00 	movl   $0x0,0xf0235250
f0102ce3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102ce6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ced:	e8 7d eb ff ff       	call   f010186f <page_alloc>
f0102cf2:	85 c0                	test   %eax,%eax
f0102cf4:	74 24                	je     f0102d1a <mem_init+0x34c>
f0102cf6:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0102cfd:	f0 
f0102cfe:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102d05:	f0 
f0102d06:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102d0d:	00 
f0102d0e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102d15:	e8 6b d3 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102d1a:	89 34 24             	mov    %esi,(%esp)
f0102d1d:	e8 be e1 ff ff       	call   f0100ee0 <page_free>
	page_free(pp1);
f0102d22:	89 3c 24             	mov    %edi,(%esp)
f0102d25:	e8 b6 e1 ff ff       	call   f0100ee0 <page_free>
	page_free(pp2);
f0102d2a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102d2d:	89 0c 24             	mov    %ecx,(%esp)
f0102d30:	e8 ab e1 ff ff       	call   f0100ee0 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d3c:	e8 2e eb ff ff       	call   f010186f <page_alloc>
f0102d41:	89 c6                	mov    %eax,%esi
f0102d43:	85 c0                	test   %eax,%eax
f0102d45:	75 24                	jne    f0102d6b <mem_init+0x39d>
f0102d47:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f0102d4e:	f0 
f0102d4f:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102d56:	f0 
f0102d57:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102d5e:	00 
f0102d5f:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102d66:	e8 1a d3 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d72:	e8 f8 ea ff ff       	call   f010186f <page_alloc>
f0102d77:	89 c7                	mov    %eax,%edi
f0102d79:	85 c0                	test   %eax,%eax
f0102d7b:	75 24                	jne    f0102da1 <mem_init+0x3d3>
f0102d7d:	c7 44 24 0c 3a 7c 10 	movl   $0xf0107c3a,0xc(%esp)
f0102d84:	f0 
f0102d85:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102d8c:	f0 
f0102d8d:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102d94:	00 
f0102d95:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102d9c:	e8 e4 d2 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102da1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102da8:	e8 c2 ea ff ff       	call   f010186f <page_alloc>
f0102dad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102db0:	85 c0                	test   %eax,%eax
f0102db2:	75 24                	jne    f0102dd8 <mem_init+0x40a>
f0102db4:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0102dbb:	f0 
f0102dbc:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102dc3:	f0 
f0102dc4:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0102dcb:	00 
f0102dcc:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102dd3:	e8 ad d2 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102dd8:	39 fe                	cmp    %edi,%esi
f0102dda:	75 24                	jne    f0102e00 <mem_init+0x432>
f0102ddc:	c7 44 24 0c 66 7c 10 	movl   $0xf0107c66,0xc(%esp)
f0102de3:	f0 
f0102de4:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102deb:	f0 
f0102dec:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0102df3:	00 
f0102df4:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102dfb:	e8 85 d2 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102e00:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102e03:	74 05                	je     f0102e0a <mem_init+0x43c>
f0102e05:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102e08:	75 24                	jne    f0102e2e <mem_init+0x460>
f0102e0a:	c7 44 24 0c 70 75 10 	movl   $0xf0107570,0xc(%esp)
f0102e11:	f0 
f0102e12:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102e19:	f0 
f0102e1a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102e21:	00 
f0102e22:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102e29:	e8 57 d2 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102e2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e35:	e8 35 ea ff ff       	call   f010186f <page_alloc>
f0102e3a:	85 c0                	test   %eax,%eax
f0102e3c:	74 24                	je     f0102e62 <mem_init+0x494>
f0102e3e:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0102e45:	f0 
f0102e46:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102e4d:	f0 
f0102e4e:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0102e55:	00 
f0102e56:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102e5d:	e8 23 d2 ff ff       	call   f0100085 <_panic>
f0102e62:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0102e65:	89 f0                	mov    %esi,%eax
f0102e67:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f0102e6d:	c1 f8 03             	sar    $0x3,%eax
f0102e70:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e73:	89 c2                	mov    %eax,%edx
f0102e75:	c1 ea 0c             	shr    $0xc,%edx
f0102e78:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0102e7e:	72 20                	jb     f0102ea0 <mem_init+0x4d2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e84:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0102e8b:	f0 
f0102e8c:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102e93:	00 
f0102e94:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0102e9b:	e8 e5 d1 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102ea0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ea7:	00 
f0102ea8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102eaf:	00 
f0102eb0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102eb5:	89 04 24             	mov    %eax,(%esp)
f0102eb8:	e8 a9 30 00 00       	call   f0105f66 <memset>
	page_free(pp0);
f0102ebd:	89 34 24             	mov    %esi,(%esp)
f0102ec0:	e8 1b e0 ff ff       	call   f0100ee0 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102ec5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102ecc:	e8 9e e9 ff ff       	call   f010186f <page_alloc>
f0102ed1:	85 c0                	test   %eax,%eax
f0102ed3:	75 24                	jne    f0102ef9 <mem_init+0x52b>
f0102ed5:	c7 44 24 0c bd 7d 10 	movl   $0xf0107dbd,0xc(%esp)
f0102edc:	f0 
f0102edd:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102ee4:	f0 
f0102ee5:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102eec:	00 
f0102eed:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102ef4:	e8 8c d1 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102ef9:	39 c6                	cmp    %eax,%esi
f0102efb:	74 24                	je     f0102f21 <mem_init+0x553>
f0102efd:	c7 44 24 0c db 7d 10 	movl   $0xf0107ddb,0xc(%esp)
f0102f04:	f0 
f0102f05:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102f0c:	f0 
f0102f0d:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102f14:	00 
f0102f15:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102f1c:	e8 64 d1 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f21:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102f24:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0102f2a:	c1 fa 03             	sar    $0x3,%edx
f0102f2d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f30:	89 d0                	mov    %edx,%eax
f0102f32:	c1 e8 0c             	shr    $0xc,%eax
f0102f35:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f0102f3b:	72 20                	jb     f0102f5d <mem_init+0x58f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f41:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0102f48:	f0 
f0102f49:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102f50:	00 
f0102f51:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0102f58:	e8 28 d1 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102f5d:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102f64:	75 11                	jne    f0102f77 <mem_init+0x5a9>
f0102f66:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f6c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102f72:	80 38 00             	cmpb   $0x0,(%eax)
f0102f75:	74 24                	je     f0102f9b <mem_init+0x5cd>
f0102f77:	c7 44 24 0c eb 7d 10 	movl   $0xf0107deb,0xc(%esp)
f0102f7e:	f0 
f0102f7f:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102f86:	f0 
f0102f87:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102f8e:	00 
f0102f8f:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102f96:	e8 ea d0 ff ff       	call   f0100085 <_panic>
f0102f9b:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102f9e:	39 d0                	cmp    %edx,%eax
f0102fa0:	75 d0                	jne    f0102f72 <mem_init+0x5a4>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102fa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102fa5:	a3 50 52 23 f0       	mov    %eax,0xf0235250

	// free the pages we took
	page_free(pp0);
f0102faa:	89 34 24             	mov    %esi,(%esp)
f0102fad:	e8 2e df ff ff       	call   f0100ee0 <page_free>
	page_free(pp1);
f0102fb2:	89 3c 24             	mov    %edi,(%esp)
f0102fb5:	e8 26 df ff ff       	call   f0100ee0 <page_free>
	page_free(pp2);
f0102fba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102fbd:	89 0c 24             	mov    %ecx,(%esp)
f0102fc0:	e8 1b df ff ff       	call   f0100ee0 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102fc5:	a1 50 52 23 f0       	mov    0xf0235250,%eax
f0102fca:	85 c0                	test   %eax,%eax
f0102fcc:	74 09                	je     f0102fd7 <mem_init+0x609>
		--nfree;
f0102fce:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102fd1:	8b 00                	mov    (%eax),%eax
f0102fd3:	85 c0                	test   %eax,%eax
f0102fd5:	75 f7                	jne    f0102fce <mem_init+0x600>
		--nfree;
	assert(nfree == 0);
f0102fd7:	85 db                	test   %ebx,%ebx
f0102fd9:	74 24                	je     f0102fff <mem_init+0x631>
f0102fdb:	c7 44 24 0c f5 7d 10 	movl   $0xf0107df5,0xc(%esp)
f0102fe2:	f0 
f0102fe3:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0102fea:	f0 
f0102feb:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0102ff2:	00 
f0102ff3:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0102ffa:	e8 86 d0 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102fff:	c7 04 24 78 79 10 f0 	movl   $0xf0107978,(%esp)
f0103006:	e8 e0 15 00 00       	call   f01045eb <cprintf>
	page_init();

	check_page_free_list(1);
//<<<<<<< HEAD
	check_page_alloc();
	check_page();
f010300b:	e8 9c ec ff ff       	call   f0101cac <check_page>
	struct Page* pp, *pp0;
	char* addr;
	int i;
	pp = pp0 = 0;
	// Allocate two single pages
	pp =  page_alloc(0);
f0103010:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103017:	e8 53 e8 ff ff       	call   f010186f <page_alloc>
f010301c:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f010301e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103025:	e8 45 e8 ff ff       	call   f010186f <page_alloc>
f010302a:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f010302c:	85 db                	test   %ebx,%ebx
f010302e:	75 24                	jne    f0103054 <mem_init+0x686>
f0103030:	c7 44 24 0c 00 7e 10 	movl   $0xf0107e00,0xc(%esp)
f0103037:	f0 
f0103038:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010303f:	f0 
f0103040:	c7 44 24 04 d6 04 00 	movl   $0x4d6,0x4(%esp)
f0103047:	00 
f0103048:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010304f:	e8 31 d0 ff ff       	call   f0100085 <_panic>
	assert(pp0 != 0);
f0103054:	85 c0                	test   %eax,%eax
f0103056:	75 24                	jne    f010307c <mem_init+0x6ae>
f0103058:	c7 44 24 0c 08 7e 10 	movl   $0xf0107e08,0xc(%esp)
f010305f:	f0 
f0103060:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103067:	f0 
f0103068:	c7 44 24 04 d7 04 00 	movl   $0x4d7,0x4(%esp)
f010306f:	00 
f0103070:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103077:	e8 09 d0 ff ff       	call   f0100085 <_panic>
	assert(pp != pp0);
f010307c:	39 c3                	cmp    %eax,%ebx
f010307e:	75 24                	jne    f01030a4 <mem_init+0x6d6>
f0103080:	c7 44 24 0c 11 7e 10 	movl   $0xf0107e11,0xc(%esp)
f0103087:	f0 
f0103088:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010308f:	f0 
f0103090:	c7 44 24 04 d8 04 00 	movl   $0x4d8,0x4(%esp)
f0103097:	00 
f0103098:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010309f:	e8 e1 cf ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	
	// Free pp and assign four continuous pages
	page_free(pp);
f01030a4:	89 1c 24             	mov    %ebx,(%esp)
f01030a7:	e8 34 de ff ff       	call   f0100ee0 <page_free>
	pp = page_alloc_npages(0, 4);
f01030ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01030b3:	00 
f01030b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030bb:	e8 cc df ff ff       	call   f010108c <page_alloc_npages>
f01030c0:	89 c3                	mov    %eax,%ebx
	//cprintf("1");
	assert(check_continuous(pp, 4));
f01030c2:	ba 04 00 00 00       	mov    $0x4,%edx
f01030c7:	e8 53 de ff ff       	call   f0100f1f <check_continuous>
f01030cc:	85 c0                	test   %eax,%eax
f01030ce:	75 24                	jne    f01030f4 <mem_init+0x726>
f01030d0:	c7 44 24 0c 1b 7e 10 	movl   $0xf0107e1b,0xc(%esp)
f01030d7:	f0 
f01030d8:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01030df:	f0 
f01030e0:	c7 44 24 04 df 04 00 	movl   $0x4df,0x4(%esp)
f01030e7:	00 
f01030e8:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01030ef:	e8 91 cf ff ff       	call   f0100085 <_panic>
	//pps = page_realloc_npages(pps, 4, 6);
	//assert(check_continuous(pps, 6));
	//cprintf("s");
	// Free four continuous pages
	//
	assert(!page_free_npages(pp, 4));
f01030f4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01030fb:	00 
f01030fc:	89 1c 24             	mov    %ebx,(%esp)
f01030ff:	e8 91 de ff ff       	call   f0100f95 <page_free_npages>
f0103104:	85 c0                	test   %eax,%eax
f0103106:	74 24                	je     f010312c <mem_init+0x75e>
f0103108:	c7 44 24 0c 33 7e 10 	movl   $0xf0107e33,0xc(%esp)
f010310f:	f0 
f0103110:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103117:	f0 
f0103118:	c7 44 24 04 e6 04 00 	movl   $0x4e6,0x4(%esp)
f010311f:	00 
f0103120:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103127:	e8 59 cf ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	//
	//assert(!page_free_npages(pps, 6));
	//cprintf("s");
	// Free pp and assign eight continuous pages
	pp = page_alloc_npages(0, 8);
f010312c:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f0103133:	00 
f0103134:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010313b:	e8 4c df ff ff       	call   f010108c <page_alloc_npages>
f0103140:	89 c3                	mov    %eax,%ebx
	//cprintf("1");
	assert(check_continuous(pp, 8));
f0103142:	ba 08 00 00 00       	mov    $0x8,%edx
f0103147:	e8 d3 dd ff ff       	call   f0100f1f <check_continuous>
f010314c:	85 c0                	test   %eax,%eax
f010314e:	75 24                	jne    f0103174 <mem_init+0x7a6>
f0103150:	c7 44 24 0c 4c 7e 10 	movl   $0xf0107e4c,0xc(%esp)
f0103157:	f0 
f0103158:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010315f:	f0 
f0103160:	c7 44 24 04 ee 04 00 	movl   $0x4ee,0x4(%esp)
f0103167:	00 
f0103168:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010316f:	e8 11 cf ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// Free four continuous pages
	assert(!page_free_npages(pp, 8));
f0103174:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f010317b:	00 
f010317c:	89 1c 24             	mov    %ebx,(%esp)
f010317f:	e8 11 de ff ff       	call   f0100f95 <page_free_npages>
f0103184:	85 c0                	test   %eax,%eax
f0103186:	74 24                	je     f01031ac <mem_init+0x7de>
f0103188:	c7 44 24 0c 64 7e 10 	movl   $0xf0107e64,0xc(%esp)
f010318f:	f0 
f0103190:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103197:	f0 
f0103198:	c7 44 24 04 f1 04 00 	movl   $0x4f1,0x4(%esp)
f010319f:	00 
f01031a0:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01031a7:	e8 d9 ce ff ff       	call   f0100085 <_panic>
	//cprintf("1");

	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f01031ac:	89 34 24             	mov    %esi,(%esp)
f01031af:	e8 2c dd ff ff       	call   f0100ee0 <page_free>
	//cprintf("1");
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
f01031b4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01031bb:	00 
f01031bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01031c3:	e8 c4 de ff ff       	call   f010108c <page_alloc_npages>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01031c8:	89 c1                	mov    %eax,%ecx
f01031ca:	2b 0d 10 5f 23 f0    	sub    0xf0235f10,%ecx
f01031d0:	c1 f9 03             	sar    $0x3,%ecx
f01031d3:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031d6:	89 ca                	mov    %ecx,%edx
f01031d8:	c1 ea 0c             	shr    $0xc,%edx
f01031db:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f01031e1:	72 20                	jb     f0103203 <mem_init+0x835>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01031e7:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01031ee:	f0 
f01031ef:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01031f6:	00 
f01031f7:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f01031fe:	e8 82 ce ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	addr = (char*)page2kva(pp0);
	//cprintf("1");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0103203:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f010320a:	75 11                	jne    f010321d <mem_init+0x84f>
f010320c:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103212:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
	//cprintf("1");
	addr = (char*)page2kva(pp0);
	//cprintf("1");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0103218:	80 3a 00             	cmpb   $0x0,(%edx)
f010321b:	74 24                	je     f0103241 <mem_init+0x873>
f010321d:	c7 44 24 0c 7d 7e 10 	movl   $0xf0107e7d,0xc(%esp)
f0103224:	f0 
f0103225:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010322c:	f0 
f010322d:	c7 44 24 04 fd 04 00 	movl   $0x4fd,0x4(%esp)
f0103234:	00 
f0103235:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010323c:	e8 44 ce ff ff       	call   f0100085 <_panic>
f0103241:	83 c2 01             	add    $0x1,%edx
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
	//cprintf("1");
	addr = (char*)page2kva(pp0);
	//cprintf("1");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f0103244:	39 ca                	cmp    %ecx,%edx
f0103246:	75 d0                	jne    f0103218 <mem_init+0x84a>
		assert(addr[i] == 0);
	}
	//cprintf("1");
	// Free pages
	assert(!page_free_npages(pp0, 4));
f0103248:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010324f:	00 
f0103250:	89 04 24             	mov    %eax,(%esp)
f0103253:	e8 3d dd ff ff       	call   f0100f95 <page_free_npages>
f0103258:	85 c0                	test   %eax,%eax
f010325a:	74 24                	je     f0103280 <mem_init+0x8b2>
f010325c:	c7 44 24 0c 8a 7e 10 	movl   $0xf0107e8a,0xc(%esp)
f0103263:	f0 
f0103264:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010326b:	f0 
f010326c:	c7 44 24 04 01 05 00 	movl   $0x501,0x4(%esp)
f0103273:	00 
f0103274:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010327b:	e8 05 ce ff ff       	call   f0100085 <_panic>
	cprintf("check_n_pages() succeeded!\n");
f0103280:	c7 04 24 a4 7e 10 f0 	movl   $0xf0107ea4,(%esp)
f0103287:	e8 5f 13 00 00       	call   f01045eb <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	/*stone's solution for lab2*/
	//RO pages for PTSIZE
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f010328c:	a1 10 5f 23 f0       	mov    0xf0235f10,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103291:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103296:	77 20                	ja     f01032b8 <mem_init+0x8ea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103298:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010329c:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f01032a3:	f0 
f01032a4:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f01032ab:	00 
f01032ac:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01032b3:	e8 cd cd ff ff       	call   f0100085 <_panic>
f01032b8:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01032bf:	00 
f01032c0:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01032c6:	89 04 24             	mov    %eax,(%esp)
f01032c9:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01032ce:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01032d3:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01032d8:	e8 68 e9 ff ff       	call   f0101c45 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01032dd:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e7:	77 20                	ja     f0103309 <mem_init+0x93b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032ed:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f01032f4:	f0 
f01032f5:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f01032fc:	00 
f01032fd:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103304:	e8 7c cd ff ff       	call   f0100085 <_panic>
f0103309:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103310:	00 
f0103311:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103317:	89 04 24             	mov    %eax,(%esp)
f010331a:	b9 00 00 02 00       	mov    $0x20000,%ecx
f010331f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103324:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0103329:	e8 17 e9 ff ff       	call   f0101c45 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010332e:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0103333:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103338:	77 20                	ja     f010335a <mem_init+0x98c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010333a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010333e:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103345:	f0 
f0103346:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
f010334d:	00 
f010334e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103355:	e8 2b cd ff ff       	call   f0100085 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	/*stone's solution for lab2*/
	//kernel stack for 8*PGSIZE
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
f010335a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103361:	00 
f0103362:	05 00 00 00 10       	add    $0x10000000,%eax
f0103367:	89 04 24             	mov    %eax,(%esp)
f010336a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010336f:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0103374:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0103379:	e8 c7 e8 ff ff       	call   f0101c45 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f010337e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103385:	00 
f0103386:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f010338d:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0103392:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0103397:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010339c:	e8 a4 e8 ff ff       	call   f0101c45 <boot_map_region>
	mem_init_mp();

//=======
	/*stone's solution for lab2*/
	//remapped physical memory
	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(0xFFFFFFFF - KERNBASE, PGSIZE), 0, PTE_P | PTE_W);
f01033a1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01033a8:	00 
f01033a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01033b0:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01033b5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01033ba:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f01033bf:	e8 81 e8 ff ff       	call   f0101c45 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01033c4:	8b 35 0c 5f 23 f0    	mov    0xf0235f0c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f01033ca:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f01033cf:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01033d6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01033dc:	74 79                	je     f0103457 <mem_init+0xa89>
f01033de:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01033e3:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01033e9:	89 f0                	mov    %esi,%eax
f01033eb:	e8 e3 de ff ff       	call   f01012d3 <check_va2pa>
f01033f0:	8b 15 10 5f 23 f0    	mov    0xf0235f10,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01033fc:	77 20                	ja     f010341e <mem_init+0xa50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103402:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103409:	f0 
f010340a:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0103411:	00 
f0103412:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103419:	e8 67 cc ff ff       	call   f0100085 <_panic>
f010341e:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0103425:	39 d0                	cmp    %edx,%eax
f0103427:	74 24                	je     f010344d <mem_init+0xa7f>
f0103429:	c7 44 24 0c 98 79 10 	movl   $0xf0107998,0xc(%esp)
f0103430:	f0 
f0103431:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103438:	f0 
f0103439:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0103440:	00 
f0103441:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103448:	e8 38 cc ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010344d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103453:	39 df                	cmp    %ebx,%edi
f0103455:	77 8c                	ja     f01033e3 <mem_init+0xa15>
f0103457:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010345c:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0103462:	89 f0                	mov    %esi,%eax
f0103464:	e8 6a de ff ff       	call   f01012d3 <check_va2pa>
f0103469:	8b 15 5c 52 23 f0    	mov    0xf023525c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010346f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103475:	77 20                	ja     f0103497 <mem_init+0xac9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103477:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010347b:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103482:	f0 
f0103483:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f010348a:	00 
f010348b:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103492:	e8 ee cb ff ff       	call   f0100085 <_panic>
f0103497:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f010349e:	39 d0                	cmp    %edx,%eax
f01034a0:	74 24                	je     f01034c6 <mem_init+0xaf8>
f01034a2:	c7 44 24 0c cc 79 10 	movl   $0xf01079cc,0xc(%esp)
f01034a9:	f0 
f01034aa:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01034b1:	f0 
f01034b2:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f01034b9:	00 
f01034ba:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01034c1:	e8 bf cb ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01034c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034cc:	81 fb 00 00 02 00    	cmp    $0x20000,%ebx
f01034d2:	75 88                	jne    f010345c <mem_init+0xa8e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01034d4:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f01034d9:	c1 e0 0c             	shl    $0xc,%eax
f01034dc:	85 c0                	test   %eax,%eax
f01034de:	74 4c                	je     f010352c <mem_init+0xb5e>
f01034e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01034e5:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01034eb:	89 f0                	mov    %esi,%eax
f01034ed:	e8 e1 dd ff ff       	call   f01012d3 <check_va2pa>
f01034f2:	39 c3                	cmp    %eax,%ebx
f01034f4:	74 24                	je     f010351a <mem_init+0xb4c>
f01034f6:	c7 44 24 0c 00 7a 10 	movl   $0xf0107a00,0xc(%esp)
f01034fd:	f0 
f01034fe:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103505:	f0 
f0103506:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f010350d:	00 
f010350e:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103515:	e8 6b cb ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010351a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103520:	a1 08 5f 23 f0       	mov    0xf0235f08,%eax
f0103525:	c1 e0 0c             	shl    $0xc,%eax
f0103528:	39 c3                	cmp    %eax,%ebx
f010352a:	72 b9                	jb     f01034e5 <mem_init+0xb17>
f010352c:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0103531:	89 da                	mov    %ebx,%edx
f0103533:	89 f0                	mov    %esi,%eax
f0103535:	e8 99 dd ff ff       	call   f01012d3 <check_va2pa>
f010353a:	39 c3                	cmp    %eax,%ebx
f010353c:	74 24                	je     f0103562 <mem_init+0xb94>
f010353e:	c7 44 24 0c c0 7e 10 	movl   $0xf0107ec0,0xc(%esp)
f0103545:	f0 
f0103546:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010354d:	f0 
f010354e:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0103555:	00 
f0103556:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010355d:	e8 23 cb ff ff       	call   f0100085 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103562:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103568:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f010356e:	75 c1                	jne    f0103531 <mem_init+0xb63>
f0103570:	c7 45 dc 00 70 23 f0 	movl   $0xf0237000,-0x24(%ebp)
f0103577:	c7 45 e0 00 00 bf ef 	movl   $0xefbf0000,-0x20(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010357e:	89 f7                	mov    %esi,%edi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103580:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103583:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103586:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103589:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010358f:	89 c6                	mov    %eax,%esi
f0103591:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103597:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010359a:	81 c1 00 00 01 00    	add    $0x10000,%ecx
f01035a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01035a3:	89 da                	mov    %ebx,%edx
f01035a5:	89 f8                	mov    %edi,%eax
f01035a7:	e8 27 dd ff ff       	call   f01012d3 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035ac:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f01035b3:	77 23                	ja     f01035d8 <mem_init+0xc0a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035bc:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f01035c3:	f0 
f01035c4:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f01035cb:	00 
f01035cc:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01035d3:	e8 ad ca ff ff       	call   f0100085 <_panic>
f01035d8:	39 f0                	cmp    %esi,%eax
f01035da:	74 24                	je     f0103600 <mem_init+0xc32>
f01035dc:	c7 44 24 0c 28 7a 10 	movl   $0xf0107a28,0xc(%esp)
f01035e3:	f0 
f01035e4:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01035eb:	f0 
f01035ec:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f01035f3:	00 
f01035f4:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01035fb:	e8 85 ca ff ff       	call   f0100085 <_panic>
f0103600:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103606:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010360c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010360f:	0f 85 5d 05 00 00    	jne    f0103b72 <mem_init+0x11a4>
f0103615:	bb 00 00 00 00       	mov    $0x0,%ebx
f010361a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010361d:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103620:	89 f8                	mov    %edi,%eax
f0103622:	e8 ac dc ff ff       	call   f01012d3 <check_va2pa>
f0103627:	83 f8 ff             	cmp    $0xffffffff,%eax
f010362a:	74 24                	je     f0103650 <mem_init+0xc82>
f010362c:	c7 44 24 0c 70 7a 10 	movl   $0xf0107a70,0xc(%esp)
f0103633:	f0 
f0103634:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010363b:	f0 
f010363c:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0103643:	00 
f0103644:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010364b:	e8 35 ca ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103650:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103656:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010365c:	75 bf                	jne    f010361d <mem_init+0xc4f>
f010365e:	81 6d e0 00 00 01 00 	subl   $0x10000,-0x20(%ebp)
f0103665:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010366c:	81 7d e0 00 00 b7 ef 	cmpl   $0xefb70000,-0x20(%ebp)
f0103673:	0f 85 07 ff ff ff    	jne    f0103580 <mem_init+0xbb2>
f0103679:	89 fe                	mov    %edi,%esi
f010367b:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103680:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103686:	83 fa 03             	cmp    $0x3,%edx
f0103689:	77 2e                	ja     f01036b9 <mem_init+0xceb>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010368b:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010368f:	0f 85 aa 00 00 00    	jne    f010373f <mem_init+0xd71>
f0103695:	c7 44 24 0c db 7e 10 	movl   $0xf0107edb,0xc(%esp)
f010369c:	f0 
f010369d:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01036a4:	f0 
f01036a5:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01036ac:	00 
f01036ad:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01036b4:	e8 cc c9 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01036b9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01036be:	76 55                	jbe    f0103715 <mem_init+0xd47>
				assert(pgdir[i] & PTE_P);
f01036c0:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01036c3:	f6 c2 01             	test   $0x1,%dl
f01036c6:	75 24                	jne    f01036ec <mem_init+0xd1e>
f01036c8:	c7 44 24 0c db 7e 10 	movl   $0xf0107edb,0xc(%esp)
f01036cf:	f0 
f01036d0:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01036d7:	f0 
f01036d8:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f01036df:	00 
f01036e0:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01036e7:	e8 99 c9 ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f01036ec:	f6 c2 02             	test   $0x2,%dl
f01036ef:	75 4e                	jne    f010373f <mem_init+0xd71>
f01036f1:	c7 44 24 0c ec 7e 10 	movl   $0xf0107eec,0xc(%esp)
f01036f8:	f0 
f01036f9:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103700:	f0 
f0103701:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0103708:	00 
f0103709:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103710:	e8 70 c9 ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103715:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0103719:	74 24                	je     f010373f <mem_init+0xd71>
f010371b:	c7 44 24 0c fd 7e 10 	movl   $0xf0107efd,0xc(%esp)
f0103722:	f0 
f0103723:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010372a:	f0 
f010372b:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0103732:	00 
f0103733:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010373a:	e8 46 c9 ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010373f:	83 c0 01             	add    $0x1,%eax
f0103742:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103747:	0f 85 33 ff ff ff    	jne    f0103680 <mem_init+0xcb2>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010374d:	c7 04 24 94 7a 10 f0 	movl   $0xf0107a94,(%esp)
f0103754:	e8 92 0e 00 00       	call   f01045eb <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103759:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010375e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103763:	77 20                	ja     f0103785 <mem_init+0xdb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103765:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103769:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103770:	f0 
f0103771:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
f0103778:	00 
f0103779:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103780:	e8 00 c9 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103785:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010378b:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("1");
	check_page_free_list(0);
f010378e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103793:	e8 33 dd ff ff       	call   f01014cb <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103798:	0f 20 c0             	mov    %cr0,%eax
	//cprintf("1");
	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010379b:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01037a0:	83 e0 f3             	and    $0xfffffff3,%eax
f01037a3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;
	//cprintf("1");
	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01037a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037ad:	e8 bd e0 ff ff       	call   f010186f <page_alloc>
f01037b2:	89 c3                	mov    %eax,%ebx
f01037b4:	85 c0                	test   %eax,%eax
f01037b6:	75 24                	jne    f01037dc <mem_init+0xe0e>
f01037b8:	c7 44 24 0c 24 7c 10 	movl   $0xf0107c24,0xc(%esp)
f01037bf:	f0 
f01037c0:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01037c7:	f0 
f01037c8:	c7 44 24 04 41 05 00 	movl   $0x541,0x4(%esp)
f01037cf:	00 
f01037d0:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01037d7:	e8 a9 c8 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01037dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037e3:	e8 87 e0 ff ff       	call   f010186f <page_alloc>
f01037e8:	89 c7                	mov    %eax,%edi
f01037ea:	85 c0                	test   %eax,%eax
f01037ec:	75 24                	jne    f0103812 <mem_init+0xe44>
f01037ee:	c7 44 24 0c 3a 7c 10 	movl   $0xf0107c3a,0xc(%esp)
f01037f5:	f0 
f01037f6:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01037fd:	f0 
f01037fe:	c7 44 24 04 42 05 00 	movl   $0x542,0x4(%esp)
f0103805:	00 
f0103806:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010380d:	e8 73 c8 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0103812:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103819:	e8 51 e0 ff ff       	call   f010186f <page_alloc>
f010381e:	89 c6                	mov    %eax,%esi
f0103820:	85 c0                	test   %eax,%eax
f0103822:	75 24                	jne    f0103848 <mem_init+0xe7a>
f0103824:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f010382b:	f0 
f010382c:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103833:	f0 
f0103834:	c7 44 24 04 43 05 00 	movl   $0x543,0x4(%esp)
f010383b:	00 
f010383c:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103843:	e8 3d c8 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	page_free(pp0);
f0103848:	89 1c 24             	mov    %ebx,(%esp)
f010384b:	e8 90 d6 ff ff       	call   f0100ee0 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103850:	89 f8                	mov    %edi,%eax
f0103852:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f0103858:	c1 f8 03             	sar    $0x3,%eax
f010385b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010385e:	89 c2                	mov    %eax,%edx
f0103860:	c1 ea 0c             	shr    $0xc,%edx
f0103863:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0103869:	72 20                	jb     f010388b <mem_init+0xebd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010386b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010386f:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0103876:	f0 
f0103877:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010387e:	00 
f010387f:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0103886:	e8 fa c7 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010388b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103892:	00 
f0103893:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010389a:	00 
f010389b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038a0:	89 04 24             	mov    %eax,(%esp)
f01038a3:	e8 be 26 00 00       	call   f0105f66 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01038a8:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01038ab:	89 f0                	mov    %esi,%eax
f01038ad:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f01038b3:	c1 f8 03             	sar    $0x3,%eax
f01038b6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038b9:	89 c2                	mov    %eax,%edx
f01038bb:	c1 ea 0c             	shr    $0xc,%edx
f01038be:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f01038c4:	72 20                	jb     f01038e6 <mem_init+0xf18>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038ca:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01038d1:	f0 
f01038d2:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01038d9:	00 
f01038da:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f01038e1:	e8 9f c7 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01038e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038ed:	00 
f01038ee:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01038f5:	00 
f01038f6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038fb:	89 04 24             	mov    %eax,(%esp)
f01038fe:	e8 63 26 00 00       	call   f0105f66 <memset>
	//cprintf("1");
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103903:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010390a:	00 
f010390b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103912:	00 
f0103913:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103917:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f010391c:	89 04 24             	mov    %eax,(%esp)
f010391f:	e8 62 e2 ff ff       	call   f0101b86 <page_insert>
	//cprintf("1");
	assert(pp1->pp_ref == 1);
f0103924:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103929:	74 24                	je     f010394f <mem_init+0xf81>
f010392b:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f0103932:	f0 
f0103933:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010393a:	f0 
f010393b:	c7 44 24 04 4b 05 00 	movl   $0x54b,0x4(%esp)
f0103942:	00 
f0103943:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010394a:	e8 36 c7 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010394f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103956:	01 01 01 
f0103959:	74 24                	je     f010397f <mem_init+0xfb1>
f010395b:	c7 44 24 0c b4 7a 10 	movl   $0xf0107ab4,0xc(%esp)
f0103962:	f0 
f0103963:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f010396a:	f0 
f010396b:	c7 44 24 04 4d 05 00 	movl   $0x54d,0x4(%esp)
f0103972:	00 
f0103973:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f010397a:	e8 06 c7 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010397f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103986:	00 
f0103987:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010398e:	00 
f010398f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103993:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0103998:	89 04 24             	mov    %eax,(%esp)
f010399b:	e8 e6 e1 ff ff       	call   f0101b86 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01039a0:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01039a7:	02 02 02 
f01039aa:	74 24                	je     f01039d0 <mem_init+0x1002>
f01039ac:	c7 44 24 0c d8 7a 10 	movl   $0xf0107ad8,0xc(%esp)
f01039b3:	f0 
f01039b4:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01039bb:	f0 
f01039bc:	c7 44 24 04 4f 05 00 	movl   $0x54f,0x4(%esp)
f01039c3:	00 
f01039c4:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01039cb:	e8 b5 c6 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01039d0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01039d5:	74 24                	je     f01039fb <mem_init+0x102d>
f01039d7:	c7 44 24 0c a9 7c 10 	movl   $0xf0107ca9,0xc(%esp)
f01039de:	f0 
f01039df:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f01039e6:	f0 
f01039e7:	c7 44 24 04 50 05 00 	movl   $0x550,0x4(%esp)
f01039ee:	00 
f01039ef:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f01039f6:	e8 8a c6 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01039fb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103a00:	74 24                	je     f0103a26 <mem_init+0x1058>
f0103a02:	c7 44 24 0c f2 7c 10 	movl   $0xf0107cf2,0xc(%esp)
f0103a09:	f0 
f0103a0a:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103a11:	f0 
f0103a12:	c7 44 24 04 51 05 00 	movl   $0x551,0x4(%esp)
f0103a19:	00 
f0103a1a:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103a21:	e8 5f c6 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103a26:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103a2d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a33:	2b 05 10 5f 23 f0    	sub    0xf0235f10,%eax
f0103a39:	c1 f8 03             	sar    $0x3,%eax
f0103a3c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a3f:	89 c2                	mov    %eax,%edx
f0103a41:	c1 ea 0c             	shr    $0xc,%edx
f0103a44:	3b 15 08 5f 23 f0    	cmp    0xf0235f08,%edx
f0103a4a:	72 20                	jb     f0103a6c <mem_init+0x109e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a50:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0103a57:	f0 
f0103a58:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0103a5f:	00 
f0103a60:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0103a67:	e8 19 c6 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a6c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a73:	03 03 03 
f0103a76:	74 24                	je     f0103a9c <mem_init+0x10ce>
f0103a78:	c7 44 24 0c fc 7a 10 	movl   $0xf0107afc,0xc(%esp)
f0103a7f:	f0 
f0103a80:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103a87:	f0 
f0103a88:	c7 44 24 04 53 05 00 	movl   $0x553,0x4(%esp)
f0103a8f:	00 
f0103a90:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103a97:	e8 e9 c5 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103a9c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103aa3:	00 
f0103aa4:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0103aa9:	89 04 24             	mov    %eax,(%esp)
f0103aac:	e8 85 e0 ff ff       	call   f0101b36 <page_remove>
	assert(pp2->pp_ref == 0);
f0103ab1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103ab6:	74 24                	je     f0103adc <mem_init+0x110e>
f0103ab8:	c7 44 24 0c e1 7c 10 	movl   $0xf0107ce1,0xc(%esp)
f0103abf:	f0 
f0103ac0:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103ac7:	f0 
f0103ac8:	c7 44 24 04 55 05 00 	movl   $0x555,0x4(%esp)
f0103acf:	00 
f0103ad0:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103ad7:	e8 a9 c5 ff ff       	call   f0100085 <_panic>
	//cprintf("1");
	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103adc:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0103ae1:	8b 08                	mov    (%eax),%ecx
f0103ae3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103ae9:	89 da                	mov    %ebx,%edx
f0103aeb:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0103af1:	c1 fa 03             	sar    $0x3,%edx
f0103af4:	c1 e2 0c             	shl    $0xc,%edx
f0103af7:	39 d1                	cmp    %edx,%ecx
f0103af9:	74 24                	je     f0103b1f <mem_init+0x1151>
f0103afb:	c7 44 24 0c 28 76 10 	movl   $0xf0107628,0xc(%esp)
f0103b02:	f0 
f0103b03:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103b0a:	f0 
f0103b0b:	c7 44 24 04 58 05 00 	movl   $0x558,0x4(%esp)
f0103b12:	00 
f0103b13:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103b1a:	e8 66 c5 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0103b1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103b25:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103b2a:	74 24                	je     f0103b50 <mem_init+0x1182>
f0103b2c:	c7 44 24 0c 98 7c 10 	movl   $0xf0107c98,0xc(%esp)
f0103b33:	f0 
f0103b34:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0103b3b:	f0 
f0103b3c:	c7 44 24 04 5a 05 00 	movl   $0x55a,0x4(%esp)
f0103b43:	00 
f0103b44:	c7 04 24 5f 7b 10 f0 	movl   $0xf0107b5f,(%esp)
f0103b4b:	e8 35 c5 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0103b50:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	//cprintf("1");
	// free the pages we took
	page_free(pp0);
f0103b56:	89 1c 24             	mov    %ebx,(%esp)
f0103b59:	e8 82 d3 ff ff       	call   f0100ee0 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b5e:	c7 04 24 28 7b 10 f0 	movl   $0xf0107b28,(%esp)
f0103b65:	e8 81 0a 00 00       	call   f01045eb <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);
	//cprintf("check");
	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103b6a:	83 c4 2c             	add    $0x2c,%esp
f0103b6d:	5b                   	pop    %ebx
f0103b6e:	5e                   	pop    %esi
f0103b6f:	5f                   	pop    %edi
f0103b70:	5d                   	pop    %ebp
f0103b71:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103b72:	89 da                	mov    %ebx,%edx
f0103b74:	89 f8                	mov    %edi,%eax
f0103b76:	e8 58 d7 ff ff       	call   f01012d3 <check_va2pa>
f0103b7b:	e9 58 fa ff ff       	jmp    f01035d8 <mem_init+0xc0a>

f0103b80 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103b80:	55                   	push   %ebp
f0103b81:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103b83:	b8 68 13 12 f0       	mov    $0xf0121368,%eax
f0103b88:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103b8b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103b90:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103b92:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103b94:	b0 10                	mov    $0x10,%al
f0103b96:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103b98:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103b9a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103b9c:	ea a3 3b 10 f0 08 00 	ljmp   $0x8,$0xf0103ba3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103ba3:	b0 00                	mov    $0x0,%al
f0103ba5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103ba8:	5d                   	pop    %ebp
f0103ba9:	c3                   	ret    

f0103baa <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103baa:	55                   	push   %ebp
f0103bab:	89 e5                	mov    %esp,%ebp
f0103bad:	83 ec 18             	sub    $0x18,%esp
f0103bb0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103bb3:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103bb6:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103bb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103bbf:	85 c0                	test   %eax,%eax
f0103bc1:	75 17                	jne    f0103bda <envid2env+0x30>
		*env_store = curenv;
f0103bc3:	e8 46 2a 00 00       	call   f010660e <cpunum>
f0103bc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bcb:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103bd1:	89 06                	mov    %eax,(%esi)
f0103bd3:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0103bd8:	eb 69                	jmp    f0103c43 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103bda:	89 c3                	mov    %eax,%ebx
f0103bdc:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103be2:	c1 e3 07             	shl    $0x7,%ebx
f0103be5:	03 1d 5c 52 23 f0    	add    0xf023525c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103beb:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103bef:	74 05                	je     f0103bf6 <envid2env+0x4c>
f0103bf1:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103bf4:	74 0d                	je     f0103c03 <envid2env+0x59>
		*env_store = 0;
f0103bf6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103bfc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103c01:	eb 40                	jmp    f0103c43 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103c03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103c07:	74 33                	je     f0103c3c <envid2env+0x92>
f0103c09:	e8 00 2a 00 00       	call   f010660e <cpunum>
f0103c0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c11:	39 98 28 60 23 f0    	cmp    %ebx,-0xfdc9fd8(%eax)
f0103c17:	74 23                	je     f0103c3c <envid2env+0x92>
f0103c19:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103c1c:	e8 ed 29 00 00       	call   f010660e <cpunum>
f0103c21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c24:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103c2a:	3b 78 48             	cmp    0x48(%eax),%edi
f0103c2d:	74 0d                	je     f0103c3c <envid2env+0x92>
		*env_store = 0;
f0103c2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103c35:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103c3a:	eb 07                	jmp    f0103c43 <envid2env+0x99>
	}

	*env_store = e;
f0103c3c:	89 1e                	mov    %ebx,(%esi)
f0103c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0103c43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103c46:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103c49:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103c4c:	89 ec                	mov    %ebp,%esp
f0103c4e:	5d                   	pop    %ebp
f0103c4f:	c3                   	ret    

f0103c50 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103c50:	55                   	push   %ebp
f0103c51:	89 e5                	mov    %esp,%ebp
f0103c53:	53                   	push   %ebx
f0103c54:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103c57:	e8 b2 29 00 00       	call   f010660e <cpunum>
f0103c5c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c5f:	8b 98 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%ebx
f0103c65:	e8 a4 29 00 00       	call   f010660e <cpunum>
f0103c6a:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103c6d:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c70:	61                   	popa   
f0103c71:	07                   	pop    %es
f0103c72:	1f                   	pop    %ds
f0103c73:	83 c4 08             	add    $0x8,%esp
f0103c76:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c77:	c7 44 24 08 0b 7f 10 	movl   $0xf0107f0b,0x8(%esp)
f0103c7e:	f0 
f0103c7f:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
f0103c86:	00 
f0103c87:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0103c8e:	e8 f2 c3 ff ff       	call   f0100085 <_panic>

f0103c93 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c93:	55                   	push   %ebp
f0103c94:	89 e5                	mov    %esp,%ebp
f0103c96:	56                   	push   %esi
f0103c97:	53                   	push   %ebx
f0103c98:	83 ec 10             	sub    $0x10,%esp
f0103c9b:	8b 75 08             	mov    0x8(%ebp),%esi
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	//1
	if (curenv == NULL || curenv != e){
f0103c9e:	e8 6b 29 00 00       	call   f010660e <cpunum>
f0103ca3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ca6:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0103cad:	74 14                	je     f0103cc3 <env_run+0x30>
f0103caf:	e8 5a 29 00 00       	call   f010660e <cpunum>
f0103cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb7:	39 b0 28 60 23 f0    	cmp    %esi,-0xfdc9fd8(%eax)
f0103cbd:	0f 84 e1 00 00 00    	je     f0103da4 <env_run+0x111>
		cprintf("env_run:%08x\n", e->env_id);
f0103cc3:	8b 46 48             	mov    0x48(%esi),%eax
f0103cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cca:	c7 04 24 22 7f 10 f0 	movl   $0xf0107f22,(%esp)
f0103cd1:	e8 15 09 00 00       	call   f01045eb <cprintf>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0103cd6:	e8 33 29 00 00       	call   f010660e <cpunum>
f0103cdb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cde:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0103ce5:	74 29                	je     f0103d10 <env_run+0x7d>
f0103ce7:	e8 22 29 00 00       	call   f010660e <cpunum>
f0103cec:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cef:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103cf5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103cf9:	75 15                	jne    f0103d10 <env_run+0x7d>
			curenv->env_status = ENV_RUNNABLE;
f0103cfb:	e8 0e 29 00 00       	call   f010660e <cpunum>
f0103d00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d03:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103d09:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		//may be others
		//if()
		curenv = e;
f0103d10:	e8 f9 28 00 00       	call   f010660e <cpunum>
f0103d15:	bb 20 60 23 f0       	mov    $0xf0236020,%ebx
f0103d1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1d:	89 74 18 08          	mov    %esi,0x8(%eax,%ebx,1)
		cprintf("env_run:%08x\n", curenv->env_id);
f0103d21:	e8 e8 28 00 00       	call   f010660e <cpunum>
f0103d26:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d29:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103d2d:	8b 40 48             	mov    0x48(%eax),%eax
f0103d30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d34:	c7 04 24 22 7f 10 f0 	movl   $0xf0107f22,(%esp)
f0103d3b:	e8 ab 08 00 00       	call   f01045eb <cprintf>
		curenv->env_status = ENV_RUNNING;
f0103d40:	e8 c9 28 00 00       	call   f010660e <cpunum>
f0103d45:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d48:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103d4c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103d53:	e8 b6 28 00 00       	call   f010660e <cpunum>
f0103d58:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d5b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103d5f:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103d63:	e8 a6 28 00 00       	call   f010660e <cpunum>
f0103d68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103d6f:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d72:	89 c2                	mov    %eax,%edx
f0103d74:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d79:	77 20                	ja     f0103d9b <env_run+0x108>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d7f:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103d86:	f0 
f0103d87:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0103d8e:	00 
f0103d8f:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0103d96:	e8 ea c2 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103d9b:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103da1:	0f 22 da             	mov    %edx,%cr3
	}
	//2
	env_pop_tf(&(curenv->env_tf));
f0103da4:	e8 65 28 00 00       	call   f010660e <cpunum>
f0103da9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dac:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103db2:	89 04 24             	mov    %eax,(%esp)
f0103db5:	e8 96 fe ff ff       	call   f0103c50 <env_pop_tf>

f0103dba <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103dba:	55                   	push   %ebp
f0103dbb:	89 e5                	mov    %esp,%ebp
f0103dbd:	57                   	push   %edi
f0103dbe:	56                   	push   %esi
f0103dbf:	53                   	push   %ebx
f0103dc0:	83 ec 2c             	sub    $0x2c,%esp
f0103dc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103dc6:	e8 43 28 00 00       	call   f010660e <cpunum>
f0103dcb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dce:	39 b8 28 60 23 f0    	cmp    %edi,-0xfdc9fd8(%eax)
f0103dd4:	75 35                	jne    f0103e0b <env_free+0x51>
		lcr3(PADDR(kern_pgdir));
f0103dd6:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ddb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103de0:	77 20                	ja     f0103e02 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103de2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103de6:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103ded:	f0 
f0103dee:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0103df5:	00 
f0103df6:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0103dfd:	e8 83 c2 ff ff       	call   f0100085 <_panic>
f0103e02:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103e08:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103e0b:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103e0e:	e8 fb 27 00 00       	call   f010660e <cpunum>
f0103e13:	6b d0 74             	imul   $0x74,%eax,%edx
f0103e16:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e1b:	83 ba 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%edx)
f0103e22:	74 11                	je     f0103e35 <env_free+0x7b>
f0103e24:	e8 e5 27 00 00       	call   f010660e <cpunum>
f0103e29:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e2c:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0103e32:	8b 40 48             	mov    0x48(%eax),%eax
f0103e35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103e39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e3d:	c7 04 24 30 7f 10 f0 	movl   $0xf0107f30,(%esp)
f0103e44:	e8 a2 07 00 00       	call   f01045eb <cprintf>
f0103e49:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103e50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e53:	c1 e0 02             	shl    $0x2,%eax
f0103e56:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103e59:	8b 47 64             	mov    0x64(%edi),%eax
f0103e5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e5f:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103e62:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103e68:	0f 84 b8 00 00 00    	je     f0103f26 <env_free+0x16c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103e6e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e74:	89 f0                	mov    %esi,%eax
f0103e76:	c1 e8 0c             	shr    $0xc,%eax
f0103e79:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e7c:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f0103e82:	72 20                	jb     f0103ea4 <env_free+0xea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e84:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103e88:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0103e8f:	f0 
f0103e90:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f0103e97:	00 
f0103e98:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0103e9f:	e8 e1 c1 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ea4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103ea7:	c1 e2 16             	shl    $0x16,%edx
f0103eaa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103ead:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0103eb2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103eb9:	01 
f0103eba:	74 17                	je     f0103ed3 <env_free+0x119>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ebc:	89 d8                	mov    %ebx,%eax
f0103ebe:	c1 e0 0c             	shl    $0xc,%eax
f0103ec1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ec8:	8b 47 64             	mov    0x64(%edi),%eax
f0103ecb:	89 04 24             	mov    %eax,(%esp)
f0103ece:	e8 63 dc ff ff       	call   f0101b36 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ed3:	83 c3 01             	add    $0x1,%ebx
f0103ed6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103edc:	75 d4                	jne    f0103eb2 <env_free+0xf8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103ede:	8b 47 64             	mov    0x64(%edi),%eax
f0103ee1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ee4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103eeb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103eee:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f0103ef4:	72 1c                	jb     f0103f12 <env_free+0x158>
		panic("pa2page called with invalid pa");
f0103ef6:	c7 44 24 08 50 75 10 	movl   $0xf0107550,0x8(%esp)
f0103efd:	f0 
f0103efe:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0103f05:	00 
f0103f06:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0103f0d:	e8 73 c1 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0103f12:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f15:	c1 e0 03             	shl    $0x3,%eax
f0103f18:	03 05 10 5f 23 f0    	add    0xf0235f10,%eax
f0103f1e:	89 04 24             	mov    %eax,(%esp)
f0103f21:	e8 d6 cf ff ff       	call   f0100efc <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103f26:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103f2a:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103f31:	0f 85 19 ff ff ff    	jne    f0103e50 <env_free+0x96>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103f37:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f3a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f3f:	77 20                	ja     f0103f61 <env_free+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f45:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0103f4c:	f0 
f0103f4d:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f0103f54:	00 
f0103f55:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0103f5c:	e8 24 c1 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0103f61:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f68:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103f6e:	c1 e8 0c             	shr    $0xc,%eax
f0103f71:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f0103f77:	72 1c                	jb     f0103f95 <env_free+0x1db>
		panic("pa2page called with invalid pa");
f0103f79:	c7 44 24 08 50 75 10 	movl   $0xf0107550,0x8(%esp)
f0103f80:	f0 
f0103f81:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0103f88:	00 
f0103f89:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0103f90:	e8 f0 c0 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0103f95:	c1 e0 03             	shl    $0x3,%eax
f0103f98:	03 05 10 5f 23 f0    	add    0xf0235f10,%eax
f0103f9e:	89 04 24             	mov    %eax,(%esp)
f0103fa1:	e8 56 cf ff ff       	call   f0100efc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103fa6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103fad:	a1 60 52 23 f0       	mov    0xf0235260,%eax
f0103fb2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103fb5:	89 3d 60 52 23 f0    	mov    %edi,0xf0235260
}
f0103fbb:	83 c4 2c             	add    $0x2c,%esp
f0103fbe:	5b                   	pop    %ebx
f0103fbf:	5e                   	pop    %esi
f0103fc0:	5f                   	pop    %edi
f0103fc1:	5d                   	pop    %ebp
f0103fc2:	c3                   	ret    

f0103fc3 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103fc3:	55                   	push   %ebp
f0103fc4:	89 e5                	mov    %esp,%ebp
f0103fc6:	53                   	push   %ebx
f0103fc7:	83 ec 14             	sub    $0x14,%esp
f0103fca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103fcd:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103fd1:	75 19                	jne    f0103fec <env_destroy+0x29>
f0103fd3:	e8 36 26 00 00       	call   f010660e <cpunum>
f0103fd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdb:	39 98 28 60 23 f0    	cmp    %ebx,-0xfdc9fd8(%eax)
f0103fe1:	74 09                	je     f0103fec <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103fe3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103fea:	eb 2f                	jmp    f010401b <env_destroy+0x58>
	}

	env_free(e);
f0103fec:	89 1c 24             	mov    %ebx,(%esp)
f0103fef:	e8 c6 fd ff ff       	call   f0103dba <env_free>

	if (curenv == e) {
f0103ff4:	e8 15 26 00 00       	call   f010660e <cpunum>
f0103ff9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ffc:	39 98 28 60 23 f0    	cmp    %ebx,-0xfdc9fd8(%eax)
f0104002:	75 17                	jne    f010401b <env_destroy+0x58>
		curenv = NULL;
f0104004:	e8 05 26 00 00       	call   f010660e <cpunum>
f0104009:	6b c0 74             	imul   $0x74,%eax,%eax
f010400c:	c7 80 28 60 23 f0 00 	movl   $0x0,-0xfdc9fd8(%eax)
f0104013:	00 00 00 
		sched_yield();
f0104016:	e8 b5 0e 00 00       	call   f0104ed0 <sched_yield>
	}
}
f010401b:	83 c4 14             	add    $0x14,%esp
f010401e:	5b                   	pop    %ebx
f010401f:	5d                   	pop    %ebp
f0104020:	c3                   	ret    

f0104021 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0104021:	55                   	push   %ebp
f0104022:	89 e5                	mov    %esp,%ebp
f0104024:	53                   	push   %ebx
f0104025:	83 ec 14             	sub    $0x14,%esp
	// Set up envs array
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	//cprintf("a\n");
	env_free_list = NULL;
f0104028:	c7 05 60 52 23 f0 00 	movl   $0x0,0xf0235260
f010402f:	00 00 00 
f0104032:	bb 80 ff 01 00       	mov    $0x1ff80,%ebx
	int i = NENV - 1;
	//cprintf("b\n");
	for (; i >= 0; i--){//for same order
		memset(&(envs[i].env_tf), 0, sizeof(struct Trapframe));
f0104037:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010403e:	00 
f010403f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104046:	00 
f0104047:	89 d8                	mov    %ebx,%eax
f0104049:	03 05 5c 52 23 f0    	add    0xf023525c,%eax
f010404f:	89 04 24             	mov    %eax,(%esp)
f0104052:	e8 0f 1f 00 00       	call   f0105f66 <memset>
		//cprintf("c\n");
		envs[i].env_link = env_free_list;
f0104057:	8b 15 60 52 23 f0    	mov    0xf0235260,%edx
f010405d:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f0104062:	89 54 18 44          	mov    %edx,0x44(%eax,%ebx,1)
		envs[i].env_id = 0;
f0104066:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f010406b:	c7 44 18 48 00 00 00 	movl   $0x0,0x48(%eax,%ebx,1)
f0104072:	00 
		envs[i].env_parent_id = 0;
f0104073:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f0104078:	c7 44 18 4c 00 00 00 	movl   $0x0,0x4c(%eax,%ebx,1)
f010407f:	00 
		envs[i].env_type = ENV_TYPE_USER;
f0104080:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f0104085:	c7 44 18 50 00 00 00 	movl   $0x0,0x50(%eax,%ebx,1)
f010408c:	00 
		envs[i].env_status = ENV_FREE;
f010408d:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f0104092:	c7 44 18 54 00 00 00 	movl   $0x0,0x54(%eax,%ebx,1)
f0104099:	00 
		envs[i].env_runs = 0;	
f010409a:	a1 5c 52 23 f0       	mov    0xf023525c,%eax
f010409f:	c7 44 18 58 00 00 00 	movl   $0x0,0x58(%eax,%ebx,1)
f01040a6:	00 
		env_free_list = &envs[i];
f01040a7:	89 d8                	mov    %ebx,%eax
f01040a9:	03 05 5c 52 23 f0    	add    0xf023525c,%eax
f01040af:	a3 60 52 23 f0       	mov    %eax,0xf0235260
f01040b4:	83 c3 80             	add    $0xffffff80,%ebx
	/*stone's solution for lab3-A*/
	//cprintf("a\n");
	env_free_list = NULL;
	int i = NENV - 1;
	//cprintf("b\n");
	for (; i >= 0; i--){//for same order
f01040b7:	83 fb 80             	cmp    $0xffffff80,%ebx
f01040ba:	0f 85 77 ff ff ff    	jne    f0104037 <env_init+0x16>
		envs[i].env_runs = 0;	
		env_free_list = &envs[i];
	}
	//cprintf("d\n");
	// Per-CPU part of the initialization
	env_init_percpu();
f01040c0:	e8 bb fa ff ff       	call   f0103b80 <env_init_percpu>
}
f01040c5:	83 c4 14             	add    $0x14,%esp
f01040c8:	5b                   	pop    %ebx
f01040c9:	5d                   	pop    %ebp
f01040ca:	c3                   	ret    

f01040cb <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01040cb:	55                   	push   %ebp
f01040cc:	89 e5                	mov    %esp,%ebp
f01040ce:	53                   	push   %ebx
f01040cf:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01040d2:	8b 1d 60 52 23 f0    	mov    0xf0235260,%ebx
f01040d8:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f01040dd:	85 db                	test   %ebx,%ebx
f01040df:	0f 84 8d 01 00 00    	je     f0104272 <env_alloc+0x1a7>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01040e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01040ec:	e8 7e d7 ff ff       	call   f010186f <page_alloc>
f01040f1:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f01040f6:	85 c0                	test   %eax,%eax
f01040f8:	0f 84 74 01 00 00    	je     f0104272 <env_alloc+0x1a7>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01040fe:	89 c2                	mov    %eax,%edx
f0104100:	2b 15 10 5f 23 f0    	sub    0xf0235f10,%edx
f0104106:	c1 fa 03             	sar    $0x3,%edx
f0104109:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010410c:	89 d1                	mov    %edx,%ecx
f010410e:	c1 e9 0c             	shr    $0xc,%ecx
f0104111:	3b 0d 08 5f 23 f0    	cmp    0xf0235f08,%ecx
f0104117:	72 20                	jb     f0104139 <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104119:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010411d:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0104124:	f0 
f0104125:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010412c:	00 
f010412d:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0104134:	e8 4c bf ff ff       	call   f0100085 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/

	e->env_pgdir = page2kva(p);
f0104139:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010413f:	89 53 64             	mov    %edx,0x64(%ebx)
	p->pp_ref++;
f0104142:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	memmove(e->env_pgdir, kern_pgdir, PGSIZE); 
f0104147:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010414e:	00 
f010414f:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
f0104154:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104158:	8b 43 64             	mov    0x64(%ebx),%eax
f010415b:	89 04 24             	mov    %eax,(%esp)
f010415e:	e8 62 1e 00 00       	call   f0105fc5 <memmove>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0104163:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104166:	89 c2                	mov    %eax,%edx
f0104168:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010416d:	77 20                	ja     f010418f <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010416f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104173:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f010417a:	f0 
f010417b:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0104182:	00 
f0104183:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f010418a:	e8 f6 be ff ff       	call   f0100085 <_panic>
f010418f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0104195:	83 ca 05             	or     $0x5,%edx
f0104198:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010419e:	8b 43 48             	mov    0x48(%ebx),%eax
f01041a1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01041a6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01041ab:	7f 05                	jg     f01041b2 <env_alloc+0xe7>
f01041ad:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01041b2:	89 da                	mov    %ebx,%edx
f01041b4:	2b 15 5c 52 23 f0    	sub    0xf023525c,%edx
f01041ba:	c1 fa 07             	sar    $0x7,%edx
f01041bd:	09 d0                	or     %edx,%eax
f01041bf:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01041c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041c5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01041c8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01041cf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01041d6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01041dd:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01041e4:	00 
f01041e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01041ec:	00 
f01041ed:	89 1c 24             	mov    %ebx,(%esp)
f01041f0:	e8 71 1d 00 00       	call   f0105f66 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01041f5:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01041fb:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0104201:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0104207:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010420e:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104214:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010421b:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0104222:	8b 43 44             	mov    0x44(%ebx),%eax
f0104225:	a3 60 52 23 f0       	mov    %eax,0xf0235260
	*newenv_store = e;
f010422a:	8b 45 08             	mov    0x8(%ebp),%eax
f010422d:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010422f:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0104232:	e8 d7 23 00 00       	call   f010660e <cpunum>
f0104237:	6b c0 74             	imul   $0x74,%eax,%eax
f010423a:	ba 00 00 00 00       	mov    $0x0,%edx
f010423f:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0104246:	74 11                	je     f0104259 <env_alloc+0x18e>
f0104248:	e8 c1 23 00 00       	call   f010660e <cpunum>
f010424d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104250:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104256:	8b 50 48             	mov    0x48(%eax),%edx
f0104259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010425d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104261:	c7 04 24 46 7f 10 f0 	movl   $0xf0107f46,(%esp)
f0104268:	e8 7e 03 00 00       	call   f01045eb <cprintf>
f010426d:	ba 00 00 00 00       	mov    $0x0,%edx
	return 0;
}
f0104272:	89 d0                	mov    %edx,%eax
f0104274:	83 c4 14             	add    $0x14,%esp
f0104277:	5b                   	pop    %ebx
f0104278:	5d                   	pop    %ebp
f0104279:	c3                   	ret    

f010427a <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010427a:	55                   	push   %ebp
f010427b:	89 e5                	mov    %esp,%ebp
f010427d:	57                   	push   %edi
f010427e:	56                   	push   %esi
f010427f:	53                   	push   %ebx
f0104280:	83 ec 2c             	sub    $0x2c,%esp
f0104283:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	/*stone's solution for lab3-A*/
	/*stone's solution for lab3-B(modify)*/
	char* va_start = ROUNDDOWN((char*)va, PGSIZE);
f0104285:	89 d0                	mov    %edx,%eax
f0104287:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010428c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* va_end = ROUNDUP((char*)(va + len), PGSIZE);
f010428f:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0104296:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page* p;
	char* pos = va_start;
	for (; pos < va_end; pos += PGSIZE){
f010429c:	39 f8                	cmp    %edi,%eax
f010429e:	73 77                	jae    f0104317 <region_alloc+0x9d>
f01042a0:	89 c3                	mov    %eax,%ebx
		int r;
		if (!(p = page_alloc(0)))
f01042a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01042a9:	e8 c1 d5 ff ff       	call   f010186f <page_alloc>
f01042ae:	85 c0                	test   %eax,%eax
f01042b0:	75 1c                	jne    f01042ce <region_alloc+0x54>
			panic("env_alloc: page alloc failed\n");
f01042b2:	c7 44 24 08 5b 7f 10 	movl   $0xf0107f5b,0x8(%esp)
f01042b9:	f0 
f01042ba:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f01042c1:	00 
f01042c2:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f01042c9:	e8 b7 bd ff ff       	call   f0100085 <_panic>
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
f01042ce:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01042d5:	00 
f01042d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01042da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042de:	8b 46 64             	mov    0x64(%esi),%eax
f01042e1:	89 04 24             	mov    %eax,(%esp)
f01042e4:	e8 9d d8 ff ff       	call   f0101b86 <page_insert>
f01042e9:	85 c0                	test   %eax,%eax
f01042eb:	79 20                	jns    f010430d <region_alloc+0x93>
			panic("env_alloc: %e\n", r);
f01042ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042f1:	c7 44 24 08 79 7f 10 	movl   $0xf0107f79,0x8(%esp)
f01042f8:	f0 
f01042f9:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f0104300:	00 
f0104301:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0104308:	e8 78 bd ff ff       	call   f0100085 <_panic>
	/*stone's solution for lab3-B(modify)*/
	char* va_start = ROUNDDOWN((char*)va, PGSIZE);
	char* va_end = ROUNDUP((char*)(va + len), PGSIZE);
	struct Page* p;
	char* pos = va_start;
	for (; pos < va_end; pos += PGSIZE){
f010430d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104313:	39 df                	cmp    %ebx,%edi
f0104315:	77 8b                	ja     f01042a2 <region_alloc+0x28>
		if (!(p = page_alloc(0)))
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
	}
	e->env_sbrk_pos = va_start;
f0104317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010431a:	89 46 60             	mov    %eax,0x60(%esi)
}
f010431d:	83 c4 2c             	add    $0x2c,%esp
f0104320:	5b                   	pop    %ebx
f0104321:	5e                   	pop    %esi
f0104322:	5f                   	pop    %edi
f0104323:	5d                   	pop    %ebp
f0104324:	c3                   	ret    

f0104325 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0104325:	55                   	push   %ebp
f0104326:	89 e5                	mov    %esp,%ebp
f0104328:	57                   	push   %edi
f0104329:	56                   	push   %esi
f010432a:	53                   	push   %ebx
f010432b:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Env *e;
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
f010432e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104335:	00 
f0104336:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104339:	89 04 24             	mov    %eax,(%esp)
f010433c:	e8 8a fd ff ff       	call   f01040cb <env_alloc>
f0104341:	85 c0                	test   %eax,%eax
f0104343:	79 20                	jns    f0104365 <env_create+0x40>
		panic("env_alloc: %e\n", r);
f0104345:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104349:	c7 44 24 08 79 7f 10 	movl   $0xf0107f79,0x8(%esp)
f0104350:	f0 
f0104351:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f0104358:	00 
f0104359:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0104360:	e8 20 bd ff ff       	call   f0100085 <_panic>
	else{
		load_icode(e, binary, size);
f0104365:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104368:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Proghdr *ph, *eph;
	struct Elf* elfhdr = (struct Elf*)binary; 
	lcr3(PADDR(e->env_pgdir));
f010436b:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010436e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104373:	77 20                	ja     f0104395 <env_create+0x70>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104375:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104379:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f0104380:	f0 
f0104381:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0104388:	00 
f0104389:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f0104390:	e8 f0 bc ff ff       	call   f0100085 <_panic>
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	struct Proghdr *ph, *eph;
	struct Elf* elfhdr = (struct Elf*)binary; 
f0104395:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104398:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010439e:	0f 22 d8             	mov    %eax,%cr3
	lcr3(PADDR(e->env_pgdir));
	// is this a valid ELF?
	if (elfhdr->e_magic != ELF_MAGIC)
f01043a1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01043a7:	74 1c                	je     f01043c5 <env_create+0xa0>
		panic("not a valid ELF\n");
f01043a9:	c7 44 24 08 88 7f 10 	movl   $0xf0107f88,0x8(%esp)
f01043b0:	f0 
f01043b1:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01043b8:	00 
f01043b9:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f01043c0:	e8 c0 bc ff ff       	call   f0100085 <_panic>
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
f01043c5:	89 fb                	mov    %edi,%ebx
f01043c7:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f01043ca:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01043ce:	c1 e6 05             	shl    $0x5,%esi
f01043d1:	8d 34 33             	lea    (%ebx,%esi,1),%esi
	for (; ph < eph; ph++){
f01043d4:	39 f3                	cmp    %esi,%ebx
f01043d6:	73 55                	jae    f010442d <env_create+0x108>
		if (ph->p_type == ELF_PROG_LOAD){
f01043d8:	83 3b 01             	cmpl   $0x1,(%ebx)
f01043db:	75 49                	jne    f0104426 <env_create+0x101>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f01043dd:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01043e0:	8b 53 08             	mov    0x8(%ebx),%edx
f01043e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01043e6:	e8 8f fe ff ff       	call   f010427a <region_alloc>
			memmove((void*)ph->p_va, (void*)(binary+ph->p_offset), ph->p_filesz);
f01043eb:	8b 43 10             	mov    0x10(%ebx),%eax
f01043ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01043f5:	03 43 04             	add    0x4(%ebx),%eax
f01043f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043fc:	8b 43 08             	mov    0x8(%ebx),%eax
f01043ff:	89 04 24             	mov    %eax,(%esp)
f0104402:	e8 be 1b 00 00       	call   f0105fc5 <memmove>
			memset((void*)(ph->p_va+ph->p_filesz), 0, (ph->p_memsz-ph->p_filesz));
f0104407:	8b 43 10             	mov    0x10(%ebx),%eax
f010440a:	8b 53 14             	mov    0x14(%ebx),%edx
f010440d:	29 c2                	sub    %eax,%edx
f010440f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010441a:	00 
f010441b:	03 43 08             	add    0x8(%ebx),%eax
f010441e:	89 04 24             	mov    %eax,(%esp)
f0104421:	e8 40 1b 00 00       	call   f0105f66 <memset>
	if (elfhdr->e_magic != ELF_MAGIC)
		panic("not a valid ELF\n");
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	for (; ph < eph; ph++){
f0104426:	83 c3 20             	add    $0x20,%ebx
f0104429:	39 de                	cmp    %ebx,%esi
f010442b:	77 ab                	ja     f01043d8 <env_create+0xb3>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
			memmove((void*)ph->p_va, (void*)(binary+ph->p_offset), ph->p_filesz);
			memset((void*)(ph->p_va+ph->p_filesz), 0, (ph->p_memsz-ph->p_filesz));
		}
	}
	e->env_tf.tf_eip = (uintptr_t)elfhdr->e_entry;
f010442d:	8b 47 18             	mov    0x18(%edi),%eax
f0104430:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104433:	89 42 30             	mov    %eax,0x30(%edx)
	lcr3(PADDR(kern_pgdir));
f0104436:	a1 0c 5f 23 f0       	mov    0xf0235f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010443b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104440:	77 20                	ja     f0104462 <env_create+0x13d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104442:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104446:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f010444d:	f0 
f010444e:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0104455:	00 
f0104456:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f010445d:	e8 23 bc ff ff       	call   f0100085 <_panic>
f0104462:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104468:	0f 22 d8             	mov    %eax,%cr3
	
	region_alloc(e, (void*)(USTACKTOP-PGSIZE), PGSIZE);
f010446b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0104470:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104475:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104478:	e8 fd fd ff ff       	call   f010427a <region_alloc>
	int r;
	if ((r = env_alloc(&e, 0)) < 0)
		panic("env_alloc: %e\n", r);
	else{
		load_icode(e, binary, size);
		e->env_type = type;
f010447d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104480:	8b 55 10             	mov    0x10(%ebp),%edx
f0104483:	89 50 50             	mov    %edx,0x50(%eax)
	}
}
f0104486:	83 c4 3c             	add    $0x3c,%esp
f0104489:	5b                   	pop    %ebx
f010448a:	5e                   	pop    %esi
f010448b:	5f                   	pop    %edi
f010448c:	5d                   	pop    %ebp
f010448d:	c3                   	ret    
	...

f0104490 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104490:	55                   	push   %ebp
f0104491:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104493:	ba 70 00 00 00       	mov    $0x70,%edx
f0104498:	8b 45 08             	mov    0x8(%ebp),%eax
f010449b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010449c:	b2 71                	mov    $0x71,%dl
f010449e:	ec                   	in     (%dx),%al
f010449f:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01044a2:	5d                   	pop    %ebp
f01044a3:	c3                   	ret    

f01044a4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01044a4:	55                   	push   %ebp
f01044a5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01044a7:	ba 70 00 00 00       	mov    $0x70,%edx
f01044ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01044af:	ee                   	out    %al,(%dx)
f01044b0:	b2 71                	mov    $0x71,%dl
f01044b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044b5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01044b6:	5d                   	pop    %ebp
f01044b7:	c3                   	ret    

f01044b8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01044b8:	55                   	push   %ebp
f01044b9:	89 e5                	mov    %esp,%ebp
f01044bb:	56                   	push   %esi
f01044bc:	53                   	push   %ebx
f01044bd:	83 ec 10             	sub    $0x10,%esp
f01044c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01044c3:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01044c5:	66 a3 70 13 12 f0    	mov    %ax,0xf0121370
	if (!didinit)
f01044cb:	83 3d 64 52 23 f0 00 	cmpl   $0x0,0xf0235264
f01044d2:	74 4e                	je     f0104522 <irq_setmask_8259A+0x6a>
f01044d4:	ba 21 00 00 00       	mov    $0x21,%edx
f01044d9:	ee                   	out    %al,(%dx)
f01044da:	89 f0                	mov    %esi,%eax
f01044dc:	66 c1 e8 08          	shr    $0x8,%ax
f01044e0:	b2 a1                	mov    $0xa1,%dl
f01044e2:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01044e3:	c7 04 24 99 7f 10 f0 	movl   $0xf0107f99,(%esp)
f01044ea:	e8 fc 00 00 00       	call   f01045eb <cprintf>
f01044ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f01044f4:	0f b7 f6             	movzwl %si,%esi
f01044f7:	f7 d6                	not    %esi
f01044f9:	0f a3 de             	bt     %ebx,%esi
f01044fc:	73 10                	jae    f010450e <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01044fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104502:	c7 04 24 80 84 10 f0 	movl   $0xf0108480,(%esp)
f0104509:	e8 dd 00 00 00       	call   f01045eb <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010450e:	83 c3 01             	add    $0x1,%ebx
f0104511:	83 fb 10             	cmp    $0x10,%ebx
f0104514:	75 e3                	jne    f01044f9 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104516:	c7 04 24 49 7d 10 f0 	movl   $0xf0107d49,(%esp)
f010451d:	e8 c9 00 00 00       	call   f01045eb <cprintf>
}
f0104522:	83 c4 10             	add    $0x10,%esp
f0104525:	5b                   	pop    %ebx
f0104526:	5e                   	pop    %esi
f0104527:	5d                   	pop    %ebp
f0104528:	c3                   	ret    

f0104529 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104529:	55                   	push   %ebp
f010452a:	89 e5                	mov    %esp,%ebp
f010452c:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010452f:	c7 05 64 52 23 f0 01 	movl   $0x1,0xf0235264
f0104536:	00 00 00 
f0104539:	ba 21 00 00 00       	mov    $0x21,%edx
f010453e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104543:	ee                   	out    %al,(%dx)
f0104544:	b2 a1                	mov    $0xa1,%dl
f0104546:	ee                   	out    %al,(%dx)
f0104547:	b2 20                	mov    $0x20,%dl
f0104549:	b8 11 00 00 00       	mov    $0x11,%eax
f010454e:	ee                   	out    %al,(%dx)
f010454f:	b2 21                	mov    $0x21,%dl
f0104551:	b8 20 00 00 00       	mov    $0x20,%eax
f0104556:	ee                   	out    %al,(%dx)
f0104557:	b8 04 00 00 00       	mov    $0x4,%eax
f010455c:	ee                   	out    %al,(%dx)
f010455d:	b8 03 00 00 00       	mov    $0x3,%eax
f0104562:	ee                   	out    %al,(%dx)
f0104563:	b2 a0                	mov    $0xa0,%dl
f0104565:	b8 11 00 00 00       	mov    $0x11,%eax
f010456a:	ee                   	out    %al,(%dx)
f010456b:	b2 a1                	mov    $0xa1,%dl
f010456d:	b8 28 00 00 00       	mov    $0x28,%eax
f0104572:	ee                   	out    %al,(%dx)
f0104573:	b8 02 00 00 00       	mov    $0x2,%eax
f0104578:	ee                   	out    %al,(%dx)
f0104579:	b8 01 00 00 00       	mov    $0x1,%eax
f010457e:	ee                   	out    %al,(%dx)
f010457f:	b2 20                	mov    $0x20,%dl
f0104581:	b8 68 00 00 00       	mov    $0x68,%eax
f0104586:	ee                   	out    %al,(%dx)
f0104587:	b8 0a 00 00 00       	mov    $0xa,%eax
f010458c:	ee                   	out    %al,(%dx)
f010458d:	b2 a0                	mov    $0xa0,%dl
f010458f:	b8 68 00 00 00       	mov    $0x68,%eax
f0104594:	ee                   	out    %al,(%dx)
f0104595:	b8 0a 00 00 00       	mov    $0xa,%eax
f010459a:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010459b:	0f b7 05 70 13 12 f0 	movzwl 0xf0121370,%eax
f01045a2:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01045a6:	74 0b                	je     f01045b3 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01045a8:	0f b7 c0             	movzwl %ax,%eax
f01045ab:	89 04 24             	mov    %eax,(%esp)
f01045ae:	e8 05 ff ff ff       	call   f01044b8 <irq_setmask_8259A>
}
f01045b3:	c9                   	leave  
f01045b4:	c3                   	ret    
f01045b5:	00 00                	add    %al,(%eax)
	...

f01045b8 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01045b8:	55                   	push   %ebp
f01045b9:	89 e5                	mov    %esp,%ebp
f01045bb:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01045be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01045c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01045cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045da:	c7 04 24 05 46 10 f0 	movl   $0xf0104605,(%esp)
f01045e1:	e8 e7 11 00 00       	call   f01057cd <vprintfmt>
	return cnt;
}
f01045e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045e9:	c9                   	leave  
f01045ea:	c3                   	ret    

f01045eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01045eb:	55                   	push   %ebp
f01045ec:	89 e5                	mov    %esp,%ebp
f01045ee:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f01045f1:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f01045f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01045fb:	89 04 24             	mov    %eax,(%esp)
f01045fe:	e8 b5 ff ff ff       	call   f01045b8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104603:	c9                   	leave  
f0104604:	c3                   	ret    

f0104605 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104605:	55                   	push   %ebp
f0104606:	89 e5                	mov    %esp,%ebp
f0104608:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010460b:	8b 45 08             	mov    0x8(%ebp),%eax
f010460e:	89 04 24             	mov    %eax,(%esp)
f0104611:	e8 94 c0 ff ff       	call   f01006aa <cputchar>
	*cnt++;
}
f0104616:	c9                   	leave  
f0104617:	c3                   	ret    
	...

f0104620 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104620:	55                   	push   %ebp
f0104621:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0104623:	c7 05 84 5a 23 f0 00 	movl   $0xefc00000,0xf0235a84
f010462a:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010462d:	66 c7 05 88 5a 23 f0 	movw   $0x10,0xf0235a88
f0104634:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0104636:	66 c7 05 28 13 12 f0 	movw   $0x68,0xf0121328
f010463d:	68 00 
f010463f:	b8 80 5a 23 f0       	mov    $0xf0235a80,%eax
f0104644:	66 a3 2a 13 12 f0    	mov    %ax,0xf012132a
f010464a:	89 c2                	mov    %eax,%edx
f010464c:	c1 ea 10             	shr    $0x10,%edx
f010464f:	88 15 2c 13 12 f0    	mov    %dl,0xf012132c
f0104655:	c6 05 2e 13 12 f0 40 	movb   $0x40,0xf012132e
f010465c:	c1 e8 18             	shr    $0x18,%eax
f010465f:	a2 2f 13 12 f0       	mov    %al,0xf012132f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0104664:	c6 05 2d 13 12 f0 89 	movb   $0x89,0xf012132d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010466b:	b8 28 00 00 00       	mov    $0x28,%eax
f0104670:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104673:	b8 74 13 12 f0       	mov    $0xf0121374,%eax
f0104678:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010467b:	5d                   	pop    %ebp
f010467c:	c3                   	ret    

f010467d <trap_init>:
/*stone's solution for lab3-B*/
void sysenter_handler();

void
trap_init(void)
{
f010467d:	55                   	push   %ebp
f010467e:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	/*stone's solution for lab3-A*/
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t0, 0);
f0104680:	b8 34 4e 10 f0       	mov    $0xf0104e34,%eax
f0104685:	66 a3 80 52 23 f0    	mov    %ax,0xf0235280
f010468b:	66 c7 05 82 52 23 f0 	movw   $0x8,0xf0235282
f0104692:	08 00 
f0104694:	c6 05 84 52 23 f0 00 	movb   $0x0,0xf0235284
f010469b:	c6 05 85 52 23 f0 8e 	movb   $0x8e,0xf0235285
f01046a2:	c1 e8 10             	shr    $0x10,%eax
f01046a5:	66 a3 86 52 23 f0    	mov    %ax,0xf0235286
	SETGATE(idt[T_DEBUG], 0, GD_KT, t1, 0);
f01046ab:	b8 3a 4e 10 f0       	mov    $0xf0104e3a,%eax
f01046b0:	66 a3 88 52 23 f0    	mov    %ax,0xf0235288
f01046b6:	66 c7 05 8a 52 23 f0 	movw   $0x8,0xf023528a
f01046bd:	08 00 
f01046bf:	c6 05 8c 52 23 f0 00 	movb   $0x0,0xf023528c
f01046c6:	c6 05 8d 52 23 f0 8e 	movb   $0x8e,0xf023528d
f01046cd:	c1 e8 10             	shr    $0x10,%eax
f01046d0:	66 a3 8e 52 23 f0    	mov    %ax,0xf023528e
	SETGATE(idt[T_NMI], 0, GD_KT, t2, 0);
f01046d6:	b8 40 4e 10 f0       	mov    $0xf0104e40,%eax
f01046db:	66 a3 90 52 23 f0    	mov    %ax,0xf0235290
f01046e1:	66 c7 05 92 52 23 f0 	movw   $0x8,0xf0235292
f01046e8:	08 00 
f01046ea:	c6 05 94 52 23 f0 00 	movb   $0x0,0xf0235294
f01046f1:	c6 05 95 52 23 f0 8e 	movb   $0x8e,0xf0235295
f01046f8:	c1 e8 10             	shr    $0x10,%eax
f01046fb:	66 a3 96 52 23 f0    	mov    %ax,0xf0235296
	/*stone's solution for lab3-B(modify)*/
	SETGATE(idt[T_BRKPT], 0, GD_KT, t3, 3);
f0104701:	b8 46 4e 10 f0       	mov    $0xf0104e46,%eax
f0104706:	66 a3 98 52 23 f0    	mov    %ax,0xf0235298
f010470c:	66 c7 05 9a 52 23 f0 	movw   $0x8,0xf023529a
f0104713:	08 00 
f0104715:	c6 05 9c 52 23 f0 00 	movb   $0x0,0xf023529c
f010471c:	c6 05 9d 52 23 f0 ee 	movb   $0xee,0xf023529d
f0104723:	c1 e8 10             	shr    $0x10,%eax
f0104726:	66 a3 9e 52 23 f0    	mov    %ax,0xf023529e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t4, 3);
f010472c:	b8 4c 4e 10 f0       	mov    $0xf0104e4c,%eax
f0104731:	66 a3 a0 52 23 f0    	mov    %ax,0xf02352a0
f0104737:	66 c7 05 a2 52 23 f0 	movw   $0x8,0xf02352a2
f010473e:	08 00 
f0104740:	c6 05 a4 52 23 f0 00 	movb   $0x0,0xf02352a4
f0104747:	c6 05 a5 52 23 f0 ee 	movb   $0xee,0xf02352a5
f010474e:	c1 e8 10             	shr    $0x10,%eax
f0104751:	66 a3 a6 52 23 f0    	mov    %ax,0xf02352a6
	SETGATE(idt[T_BOUND], 0, GD_KT, t5, 0);
f0104757:	b8 52 4e 10 f0       	mov    $0xf0104e52,%eax
f010475c:	66 a3 a8 52 23 f0    	mov    %ax,0xf02352a8
f0104762:	66 c7 05 aa 52 23 f0 	movw   $0x8,0xf02352aa
f0104769:	08 00 
f010476b:	c6 05 ac 52 23 f0 00 	movb   $0x0,0xf02352ac
f0104772:	c6 05 ad 52 23 f0 8e 	movb   $0x8e,0xf02352ad
f0104779:	c1 e8 10             	shr    $0x10,%eax
f010477c:	66 a3 ae 52 23 f0    	mov    %ax,0xf02352ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, t6, 0);
f0104782:	b8 58 4e 10 f0       	mov    $0xf0104e58,%eax
f0104787:	66 a3 b0 52 23 f0    	mov    %ax,0xf02352b0
f010478d:	66 c7 05 b2 52 23 f0 	movw   $0x8,0xf02352b2
f0104794:	08 00 
f0104796:	c6 05 b4 52 23 f0 00 	movb   $0x0,0xf02352b4
f010479d:	c6 05 b5 52 23 f0 8e 	movb   $0x8e,0xf02352b5
f01047a4:	c1 e8 10             	shr    $0x10,%eax
f01047a7:	66 a3 b6 52 23 f0    	mov    %ax,0xf02352b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, t7, 0);
f01047ad:	b8 5e 4e 10 f0       	mov    $0xf0104e5e,%eax
f01047b2:	66 a3 b8 52 23 f0    	mov    %ax,0xf02352b8
f01047b8:	66 c7 05 ba 52 23 f0 	movw   $0x8,0xf02352ba
f01047bf:	08 00 
f01047c1:	c6 05 bc 52 23 f0 00 	movb   $0x0,0xf02352bc
f01047c8:	c6 05 bd 52 23 f0 8e 	movb   $0x8e,0xf02352bd
f01047cf:	c1 e8 10             	shr    $0x10,%eax
f01047d2:	66 a3 be 52 23 f0    	mov    %ax,0xf02352be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t8, 0);
f01047d8:	b8 64 4e 10 f0       	mov    $0xf0104e64,%eax
f01047dd:	66 a3 c0 52 23 f0    	mov    %ax,0xf02352c0
f01047e3:	66 c7 05 c2 52 23 f0 	movw   $0x8,0xf02352c2
f01047ea:	08 00 
f01047ec:	c6 05 c4 52 23 f0 00 	movb   $0x0,0xf02352c4
f01047f3:	c6 05 c5 52 23 f0 8e 	movb   $0x8e,0xf02352c5
f01047fa:	c1 e8 10             	shr    $0x10,%eax
f01047fd:	66 a3 c6 52 23 f0    	mov    %ax,0xf02352c6
	SETGATE(idt[T_TSS], 0, GD_KT, t10, 0);
f0104803:	b8 68 4e 10 f0       	mov    $0xf0104e68,%eax
f0104808:	66 a3 d0 52 23 f0    	mov    %ax,0xf02352d0
f010480e:	66 c7 05 d2 52 23 f0 	movw   $0x8,0xf02352d2
f0104815:	08 00 
f0104817:	c6 05 d4 52 23 f0 00 	movb   $0x0,0xf02352d4
f010481e:	c6 05 d5 52 23 f0 8e 	movb   $0x8e,0xf02352d5
f0104825:	c1 e8 10             	shr    $0x10,%eax
f0104828:	66 a3 d6 52 23 f0    	mov    %ax,0xf02352d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t11, 0);
f010482e:	b8 6c 4e 10 f0       	mov    $0xf0104e6c,%eax
f0104833:	66 a3 d8 52 23 f0    	mov    %ax,0xf02352d8
f0104839:	66 c7 05 da 52 23 f0 	movw   $0x8,0xf02352da
f0104840:	08 00 
f0104842:	c6 05 dc 52 23 f0 00 	movb   $0x0,0xf02352dc
f0104849:	c6 05 dd 52 23 f0 8e 	movb   $0x8e,0xf02352dd
f0104850:	c1 e8 10             	shr    $0x10,%eax
f0104853:	66 a3 de 52 23 f0    	mov    %ax,0xf02352de
	SETGATE(idt[T_STACK], 0, GD_KT, t12, 0);
f0104859:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f010485e:	66 a3 e0 52 23 f0    	mov    %ax,0xf02352e0
f0104864:	66 c7 05 e2 52 23 f0 	movw   $0x8,0xf02352e2
f010486b:	08 00 
f010486d:	c6 05 e4 52 23 f0 00 	movb   $0x0,0xf02352e4
f0104874:	c6 05 e5 52 23 f0 8e 	movb   $0x8e,0xf02352e5
f010487b:	c1 e8 10             	shr    $0x10,%eax
f010487e:	66 a3 e6 52 23 f0    	mov    %ax,0xf02352e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t13, 0);
f0104884:	b8 74 4e 10 f0       	mov    $0xf0104e74,%eax
f0104889:	66 a3 e8 52 23 f0    	mov    %ax,0xf02352e8
f010488f:	66 c7 05 ea 52 23 f0 	movw   $0x8,0xf02352ea
f0104896:	08 00 
f0104898:	c6 05 ec 52 23 f0 00 	movb   $0x0,0xf02352ec
f010489f:	c6 05 ed 52 23 f0 8e 	movb   $0x8e,0xf02352ed
f01048a6:	c1 e8 10             	shr    $0x10,%eax
f01048a9:	66 a3 ee 52 23 f0    	mov    %ax,0xf02352ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, t14, 0);
f01048af:	b8 78 4e 10 f0       	mov    $0xf0104e78,%eax
f01048b4:	66 a3 f0 52 23 f0    	mov    %ax,0xf02352f0
f01048ba:	66 c7 05 f2 52 23 f0 	movw   $0x8,0xf02352f2
f01048c1:	08 00 
f01048c3:	c6 05 f4 52 23 f0 00 	movb   $0x0,0xf02352f4
f01048ca:	c6 05 f5 52 23 f0 8e 	movb   $0x8e,0xf02352f5
f01048d1:	c1 e8 10             	shr    $0x10,%eax
f01048d4:	66 a3 f6 52 23 f0    	mov    %ax,0xf02352f6
	SETGATE(idt[T_FPERR], 0, GD_KT, t16, 0);
f01048da:	b8 7c 4e 10 f0       	mov    $0xf0104e7c,%eax
f01048df:	66 a3 00 53 23 f0    	mov    %ax,0xf0235300
f01048e5:	66 c7 05 02 53 23 f0 	movw   $0x8,0xf0235302
f01048ec:	08 00 
f01048ee:	c6 05 04 53 23 f0 00 	movb   $0x0,0xf0235304
f01048f5:	c6 05 05 53 23 f0 8e 	movb   $0x8e,0xf0235305
f01048fc:	c1 e8 10             	shr    $0x10,%eax
f01048ff:	66 a3 06 53 23 f0    	mov    %ax,0xf0235306
	SETGATE(idt[T_ALIGN], 0, GD_KT, t17, 0);
f0104905:	b8 82 4e 10 f0       	mov    $0xf0104e82,%eax
f010490a:	66 a3 08 53 23 f0    	mov    %ax,0xf0235308
f0104910:	66 c7 05 0a 53 23 f0 	movw   $0x8,0xf023530a
f0104917:	08 00 
f0104919:	c6 05 0c 53 23 f0 00 	movb   $0x0,0xf023530c
f0104920:	c6 05 0d 53 23 f0 8e 	movb   $0x8e,0xf023530d
f0104927:	c1 e8 10             	shr    $0x10,%eax
f010492a:	66 a3 0e 53 23 f0    	mov    %ax,0xf023530e
	SETGATE(idt[T_MCHK], 0, GD_KT, t18, 0);
f0104930:	b8 86 4e 10 f0       	mov    $0xf0104e86,%eax
f0104935:	66 a3 10 53 23 f0    	mov    %ax,0xf0235310
f010493b:	66 c7 05 12 53 23 f0 	movw   $0x8,0xf0235312
f0104942:	08 00 
f0104944:	c6 05 14 53 23 f0 00 	movb   $0x0,0xf0235314
f010494b:	c6 05 15 53 23 f0 8e 	movb   $0x8e,0xf0235315
f0104952:	c1 e8 10             	shr    $0x10,%eax
f0104955:	66 a3 16 53 23 f0    	mov    %ax,0xf0235316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t19, 0);
f010495b:	b8 8c 4e 10 f0       	mov    $0xf0104e8c,%eax
f0104960:	66 a3 18 53 23 f0    	mov    %ax,0xf0235318
f0104966:	66 c7 05 1a 53 23 f0 	movw   $0x8,0xf023531a
f010496d:	08 00 
f010496f:	c6 05 1c 53 23 f0 00 	movb   $0x0,0xf023531c
f0104976:	c6 05 1d 53 23 f0 8e 	movb   $0x8e,0xf023531d
f010497d:	c1 e8 10             	shr    $0x10,%eax
f0104980:	66 a3 1e 53 23 f0    	mov    %ax,0xf023531e
	/*stone's solution for lab3-B*/
	wrmsr(0x174, GD_KT, 0);
f0104986:	ba 00 00 00 00       	mov    $0x0,%edx
f010498b:	b8 08 00 00 00       	mov    $0x8,%eax
f0104990:	b9 74 01 00 00       	mov    $0x174,%ecx
f0104995:	0f 30                	wrmsr  
   	wrmsr(0x175, KSTACKTOP, 0);
f0104997:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f010499c:	b1 75                	mov    $0x75,%cl
f010499e:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f01049a0:	b8 92 4e 10 f0       	mov    $0xf0104e92,%eax
f01049a5:	b1 76                	mov    $0x76,%cl
f01049a7:	0f 30                	wrmsr  
	// Per-CPU setup 
	trap_init_percpu();
f01049a9:	e8 72 fc ff ff       	call   f0104620 <trap_init_percpu>
}
f01049ae:	5d                   	pop    %ebp
f01049af:	c3                   	ret    

f01049b0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01049b0:	55                   	push   %ebp
f01049b1:	89 e5                	mov    %esp,%ebp
f01049b3:	53                   	push   %ebx
f01049b4:	83 ec 14             	sub    $0x14,%esp
f01049b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01049ba:	8b 03                	mov    (%ebx),%eax
f01049bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049c0:	c7 04 24 ad 7f 10 f0 	movl   $0xf0107fad,(%esp)
f01049c7:	e8 1f fc ff ff       	call   f01045eb <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01049cc:	8b 43 04             	mov    0x4(%ebx),%eax
f01049cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049d3:	c7 04 24 bc 7f 10 f0 	movl   $0xf0107fbc,(%esp)
f01049da:	e8 0c fc ff ff       	call   f01045eb <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01049df:	8b 43 08             	mov    0x8(%ebx),%eax
f01049e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049e6:	c7 04 24 cb 7f 10 f0 	movl   $0xf0107fcb,(%esp)
f01049ed:	e8 f9 fb ff ff       	call   f01045eb <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01049f2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01049f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049f9:	c7 04 24 da 7f 10 f0 	movl   $0xf0107fda,(%esp)
f0104a00:	e8 e6 fb ff ff       	call   f01045eb <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104a05:	8b 43 10             	mov    0x10(%ebx),%eax
f0104a08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a0c:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0104a13:	e8 d3 fb ff ff       	call   f01045eb <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104a18:	8b 43 14             	mov    0x14(%ebx),%eax
f0104a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a1f:	c7 04 24 f8 7f 10 f0 	movl   $0xf0107ff8,(%esp)
f0104a26:	e8 c0 fb ff ff       	call   f01045eb <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104a2b:	8b 43 18             	mov    0x18(%ebx),%eax
f0104a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a32:	c7 04 24 07 80 10 f0 	movl   $0xf0108007,(%esp)
f0104a39:	e8 ad fb ff ff       	call   f01045eb <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104a3e:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104a41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a45:	c7 04 24 16 80 10 f0 	movl   $0xf0108016,(%esp)
f0104a4c:	e8 9a fb ff ff       	call   f01045eb <cprintf>
}
f0104a51:	83 c4 14             	add    $0x14,%esp
f0104a54:	5b                   	pop    %ebx
f0104a55:	5d                   	pop    %ebp
f0104a56:	c3                   	ret    

f0104a57 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104a57:	55                   	push   %ebp
f0104a58:	89 e5                	mov    %esp,%ebp
f0104a5a:	56                   	push   %esi
f0104a5b:	53                   	push   %ebx
f0104a5c:	83 ec 10             	sub    $0x10,%esp
f0104a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104a62:	e8 a7 1b 00 00       	call   f010660e <cpunum>
f0104a67:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a6f:	c7 04 24 25 80 10 f0 	movl   $0xf0108025,(%esp)
f0104a76:	e8 70 fb ff ff       	call   f01045eb <cprintf>
	print_regs(&tf->tf_regs);
f0104a7b:	89 1c 24             	mov    %ebx,(%esp)
f0104a7e:	e8 2d ff ff ff       	call   f01049b0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104a83:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104a87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a8b:	c7 04 24 43 80 10 f0 	movl   $0xf0108043,(%esp)
f0104a92:	e8 54 fb ff ff       	call   f01045eb <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104a97:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a9f:	c7 04 24 56 80 10 f0 	movl   $0xf0108056,(%esp)
f0104aa6:	e8 40 fb ff ff       	call   f01045eb <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104aab:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104aae:	83 f8 13             	cmp    $0x13,%eax
f0104ab1:	77 09                	ja     f0104abc <print_trapframe+0x65>
		return excnames[trapno];
f0104ab3:	8b 14 85 40 83 10 f0 	mov    -0xfef7cc0(,%eax,4),%edx
f0104aba:	eb 1c                	jmp    f0104ad8 <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f0104abc:	ba 69 80 10 f0       	mov    $0xf0108069,%edx
f0104ac1:	83 f8 30             	cmp    $0x30,%eax
f0104ac4:	74 12                	je     f0104ad8 <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104ac6:	8d 48 e0             	lea    -0x20(%eax),%ecx
f0104ac9:	ba 84 80 10 f0       	mov    $0xf0108084,%edx
f0104ace:	83 f9 0f             	cmp    $0xf,%ecx
f0104ad1:	76 05                	jbe    f0104ad8 <print_trapframe+0x81>
f0104ad3:	ba 75 80 10 f0       	mov    $0xf0108075,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104ad8:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104adc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ae0:	c7 04 24 97 80 10 f0 	movl   $0xf0108097,(%esp)
f0104ae7:	e8 ff fa ff ff       	call   f01045eb <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104aec:	3b 1d e8 5a 23 f0    	cmp    0xf0235ae8,%ebx
f0104af2:	75 19                	jne    f0104b0d <print_trapframe+0xb6>
f0104af4:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104af8:	75 13                	jne    f0104b0d <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104afa:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104afd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b01:	c7 04 24 a9 80 10 f0 	movl   $0xf01080a9,(%esp)
f0104b08:	e8 de fa ff ff       	call   f01045eb <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104b0d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104b10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b14:	c7 04 24 b8 80 10 f0 	movl   $0xf01080b8,(%esp)
f0104b1b:	e8 cb fa ff ff       	call   f01045eb <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104b20:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104b24:	75 47                	jne    f0104b6d <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104b26:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104b29:	be d2 80 10 f0       	mov    $0xf01080d2,%esi
f0104b2e:	a8 01                	test   $0x1,%al
f0104b30:	75 05                	jne    f0104b37 <print_trapframe+0xe0>
f0104b32:	be c6 80 10 f0       	mov    $0xf01080c6,%esi
f0104b37:	b9 e2 80 10 f0       	mov    $0xf01080e2,%ecx
f0104b3c:	a8 02                	test   $0x2,%al
f0104b3e:	75 05                	jne    f0104b45 <print_trapframe+0xee>
f0104b40:	b9 dd 80 10 f0       	mov    $0xf01080dd,%ecx
f0104b45:	ba e8 80 10 f0       	mov    $0xf01080e8,%edx
f0104b4a:	a8 04                	test   $0x4,%al
f0104b4c:	75 05                	jne    f0104b53 <print_trapframe+0xfc>
f0104b4e:	ba bf 81 10 f0       	mov    $0xf01081bf,%edx
f0104b53:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104b57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104b5b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b5f:	c7 04 24 ed 80 10 f0 	movl   $0xf01080ed,(%esp)
f0104b66:	e8 80 fa ff ff       	call   f01045eb <cprintf>
f0104b6b:	eb 0c                	jmp    f0104b79 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104b6d:	c7 04 24 49 7d 10 f0 	movl   $0xf0107d49,(%esp)
f0104b74:	e8 72 fa ff ff       	call   f01045eb <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104b79:	8b 43 30             	mov    0x30(%ebx),%eax
f0104b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b80:	c7 04 24 fc 80 10 f0 	movl   $0xf01080fc,(%esp)
f0104b87:	e8 5f fa ff ff       	call   f01045eb <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104b8c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104b90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b94:	c7 04 24 0b 81 10 f0 	movl   $0xf010810b,(%esp)
f0104b9b:	e8 4b fa ff ff       	call   f01045eb <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104ba0:	8b 43 38             	mov    0x38(%ebx),%eax
f0104ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ba7:	c7 04 24 1e 81 10 f0 	movl   $0xf010811e,(%esp)
f0104bae:	e8 38 fa ff ff       	call   f01045eb <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104bb3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104bb7:	74 27                	je     f0104be0 <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104bb9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bc0:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0104bc7:	e8 1f fa ff ff       	call   f01045eb <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104bcc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bd4:	c7 04 24 3c 81 10 f0 	movl   $0xf010813c,(%esp)
f0104bdb:	e8 0b fa ff ff       	call   f01045eb <cprintf>
	}
}
f0104be0:	83 c4 10             	add    $0x10,%esp
f0104be3:	5b                   	pop    %ebx
f0104be4:	5e                   	pop    %esi
f0104be5:	5d                   	pop    %ebp
f0104be6:	c3                   	ret    

f0104be7 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104be7:	55                   	push   %ebp
f0104be8:	89 e5                	mov    %esp,%ebp
f0104bea:	83 ec 28             	sub    $0x28,%esp
f0104bed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104bf0:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104bf3:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104bf6:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bf9:	0f 20 d3             	mov    %cr2,%ebx

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	if (tf->tf_cs == GD_KT)
f0104bfc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104c01:	75 1c                	jne    f0104c1f <page_fault_handler+0x38>
		panic("Page Fault in kernel");
f0104c03:	c7 44 24 08 4f 81 10 	movl   $0xf010814f,0x8(%esp)
f0104c0a:	f0 
f0104c0b:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0104c12:	00 
f0104c13:	c7 04 24 64 81 10 f0 	movl   $0xf0108164,(%esp)
f0104c1a:	e8 66 b4 ff ff       	call   f0100085 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104c1f:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104c22:	e8 e7 19 00 00       	call   f010660e <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104c27:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104c2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104c2f:	bb 20 60 23 f0       	mov    $0xf0236020,%ebx
f0104c34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c37:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104c3b:	8b 40 48             	mov    0x48(%eax),%eax
f0104c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c42:	c7 04 24 0c 83 10 f0 	movl   $0xf010830c,(%esp)
f0104c49:	e8 9d f9 ff ff       	call   f01045eb <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104c4e:	89 34 24             	mov    %esi,(%esp)
f0104c51:	e8 01 fe ff ff       	call   f0104a57 <print_trapframe>
	env_destroy(curenv);
f0104c56:	e8 b3 19 00 00       	call   f010660e <cpunum>
f0104c5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c5e:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104c62:	89 04 24             	mov    %eax,(%esp)
f0104c65:	e8 59 f3 ff ff       	call   f0103fc3 <env_destroy>
}
f0104c6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104c6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104c70:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104c73:	89 ec                	mov    %ebp,%esp
f0104c75:	5d                   	pop    %ebp
f0104c76:	c3                   	ret    

f0104c77 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104c77:	55                   	push   %ebp
f0104c78:	89 e5                	mov    %esp,%ebp
f0104c7a:	83 ec 28             	sub    $0x28,%esp
f0104c7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104c80:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104c83:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104c86:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104c89:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104c8a:	83 3d 00 5f 23 f0 00 	cmpl   $0x0,0xf0235f00
f0104c91:	74 01                	je     f0104c94 <trap+0x1d>
		asm volatile("hlt");
f0104c93:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104c94:	9c                   	pushf  
f0104c95:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104c96:	f6 c4 02             	test   $0x2,%ah
f0104c99:	74 24                	je     f0104cbf <trap+0x48>
f0104c9b:	c7 44 24 0c 70 81 10 	movl   $0xf0108170,0xc(%esp)
f0104ca2:	f0 
f0104ca3:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0104caa:	f0 
f0104cab:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
f0104cb2:	00 
f0104cb3:	c7 04 24 64 81 10 f0 	movl   $0xf0108164,(%esp)
f0104cba:	e8 c6 b3 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104cbf:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104cc3:	83 e0 03             	and    $0x3,%eax
f0104cc6:	83 f8 03             	cmp    $0x3,%eax
f0104cc9:	0f 85 9d 00 00 00    	jne    f0104d6c <trap+0xf5>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104ccf:	e8 3a 19 00 00       	call   f010660e <cpunum>
f0104cd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd7:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0104cde:	75 24                	jne    f0104d04 <trap+0x8d>
f0104ce0:	c7 44 24 0c 89 81 10 	movl   $0xf0108189,0xc(%esp)
f0104ce7:	f0 
f0104ce8:	c7 44 24 08 77 7b 10 	movl   $0xf0107b77,0x8(%esp)
f0104cef:	f0 
f0104cf0:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f0104cf7:	00 
f0104cf8:	c7 04 24 64 81 10 f0 	movl   $0xf0108164,(%esp)
f0104cff:	e8 81 b3 ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104d04:	e8 05 19 00 00       	call   f010660e <cpunum>
f0104d09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d0c:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104d12:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104d16:	75 2e                	jne    f0104d46 <trap+0xcf>
			env_free(curenv);
f0104d18:	e8 f1 18 00 00       	call   f010660e <cpunum>
f0104d1d:	be 20 60 23 f0       	mov    $0xf0236020,%esi
f0104d22:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d25:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0104d29:	89 04 24             	mov    %eax,(%esp)
f0104d2c:	e8 89 f0 ff ff       	call   f0103dba <env_free>
			curenv = NULL;
f0104d31:	e8 d8 18 00 00       	call   f010660e <cpunum>
f0104d36:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d39:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f0104d40:	00 
			sched_yield();
f0104d41:	e8 8a 01 00 00       	call   f0104ed0 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104d46:	e8 c3 18 00 00       	call   f010660e <cpunum>
f0104d4b:	bb 20 60 23 f0       	mov    $0xf0236020,%ebx
f0104d50:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d53:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104d57:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d5c:	89 c7                	mov    %eax,%edi
f0104d5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104d60:	e8 a9 18 00 00       	call   f010660e <cpunum>
f0104d65:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d68:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d6c:	89 35 e8 5a 23 f0    	mov    %esi,0xf0235ae8
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104d72:	8b 46 28             	mov    0x28(%esi),%eax
f0104d75:	83 f8 27             	cmp    $0x27,%eax
f0104d78:	75 16                	jne    f0104d90 <trap+0x119>
		cprintf("Spurious interrupt on irq 7\n");
f0104d7a:	c7 04 24 90 81 10 f0 	movl   $0xf0108190,(%esp)
f0104d81:	e8 65 f8 ff ff       	call   f01045eb <cprintf>
		print_trapframe(tf);
f0104d86:	89 34 24             	mov    %esi,(%esp)
f0104d89:	e8 c9 fc ff ff       	call   f0104a57 <print_trapframe>
f0104d8e:	eb 63                	jmp    f0104df3 <trap+0x17c>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

//=======
	/*stone's solution for lab3-B*/
	if (tf->tf_trapno == T_PGFLT)
f0104d90:	83 f8 0e             	cmp    $0xe,%eax
f0104d93:	75 08                	jne    f0104d9d <trap+0x126>
		page_fault_handler(tf);
f0104d95:	89 34 24             	mov    %esi,(%esp)
f0104d98:	e8 4a fe ff ff       	call   f0104be7 <page_fault_handler>
	if (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT)
f0104d9d:	8b 46 28             	mov    0x28(%esi),%eax
f0104da0:	83 f8 01             	cmp    $0x1,%eax
f0104da3:	74 05                	je     f0104daa <trap+0x133>
f0104da5:	83 f8 03             	cmp    $0x3,%eax
f0104da8:	75 08                	jne    f0104db2 <trap+0x13b>
		monitor(tf);
f0104daa:	89 34 24             	mov    %esi,(%esp)
f0104dad:	e8 48 bd ff ff       	call   f0100afa <monitor>
	
//>>>>>>> lab3
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104db2:	89 34 24             	mov    %esi,(%esp)
f0104db5:	e8 9d fc ff ff       	call   f0104a57 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104dba:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104dbf:	75 1c                	jne    f0104ddd <trap+0x166>
		panic("unhandled trap in kernel");
f0104dc1:	c7 44 24 08 ad 81 10 	movl   $0xf01081ad,0x8(%esp)
f0104dc8:	f0 
f0104dc9:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f0104dd0:	00 
f0104dd1:	c7 04 24 64 81 10 f0 	movl   $0xf0108164,(%esp)
f0104dd8:	e8 a8 b2 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f0104ddd:	e8 2c 18 00 00       	call   f010660e <cpunum>
f0104de2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de5:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104deb:	89 04 24             	mov    %eax,(%esp)
f0104dee:	e8 d0 f1 ff ff       	call   f0103fc3 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104df3:	e8 16 18 00 00       	call   f010660e <cpunum>
f0104df8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dfb:	83 b8 28 60 23 f0 00 	cmpl   $0x0,-0xfdc9fd8(%eax)
f0104e02:	74 2a                	je     f0104e2e <trap+0x1b7>
f0104e04:	e8 05 18 00 00       	call   f010660e <cpunum>
f0104e09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e0c:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104e12:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e16:	75 16                	jne    f0104e2e <trap+0x1b7>
		env_run(curenv);
f0104e18:	e8 f1 17 00 00       	call   f010660e <cpunum>
f0104e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e20:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0104e26:	89 04 24             	mov    %eax,(%esp)
f0104e29:	e8 65 ee ff ff       	call   f0103c93 <env_run>
	else
		sched_yield();
f0104e2e:	e8 9d 00 00 00       	call   f0104ed0 <sched_yield>
	...

f0104e34 <t0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*stone's solution for lab3-A*/
	TRAPHANDLER_NOEC(t0,  T_DIVIDE);
f0104e34:	6a 00                	push   $0x0
f0104e36:	6a 00                	push   $0x0
f0104e38:	eb 7e                	jmp    f0104eb8 <_alltraps>

f0104e3a <t1>:
	TRAPHANDLER_NOEC(t1,  T_DEBUG);
f0104e3a:	6a 00                	push   $0x0
f0104e3c:	6a 01                	push   $0x1
f0104e3e:	eb 78                	jmp    f0104eb8 <_alltraps>

f0104e40 <t2>:
	TRAPHANDLER_NOEC(t2,  T_NMI);
f0104e40:	6a 00                	push   $0x0
f0104e42:	6a 02                	push   $0x2
f0104e44:	eb 72                	jmp    f0104eb8 <_alltraps>

f0104e46 <t3>:
	TRAPHANDLER_NOEC(t3,  T_BRKPT);
f0104e46:	6a 00                	push   $0x0
f0104e48:	6a 03                	push   $0x3
f0104e4a:	eb 6c                	jmp    f0104eb8 <_alltraps>

f0104e4c <t4>:
	TRAPHANDLER_NOEC(t4,  T_OFLOW);
f0104e4c:	6a 00                	push   $0x0
f0104e4e:	6a 04                	push   $0x4
f0104e50:	eb 66                	jmp    f0104eb8 <_alltraps>

f0104e52 <t5>:
	TRAPHANDLER_NOEC(t5,  T_BOUND);
f0104e52:	6a 00                	push   $0x0
f0104e54:	6a 05                	push   $0x5
f0104e56:	eb 60                	jmp    f0104eb8 <_alltraps>

f0104e58 <t6>:
	TRAPHANDLER_NOEC(t6,  T_ILLOP);
f0104e58:	6a 00                	push   $0x0
f0104e5a:	6a 06                	push   $0x6
f0104e5c:	eb 5a                	jmp    f0104eb8 <_alltraps>

f0104e5e <t7>:
	TRAPHANDLER_NOEC(t7,  T_DEVICE);
f0104e5e:	6a 00                	push   $0x0
f0104e60:	6a 07                	push   $0x7
f0104e62:	eb 54                	jmp    f0104eb8 <_alltraps>

f0104e64 <t8>:
	TRAPHANDLER	(t8,  T_DBLFLT);
f0104e64:	6a 08                	push   $0x8
f0104e66:	eb 50                	jmp    f0104eb8 <_alltraps>

f0104e68 <t10>:
	TRAPHANDLER	(t10, T_TSS);
f0104e68:	6a 0a                	push   $0xa
f0104e6a:	eb 4c                	jmp    f0104eb8 <_alltraps>

f0104e6c <t11>:
	TRAPHANDLER	(t11, T_SEGNP);
f0104e6c:	6a 0b                	push   $0xb
f0104e6e:	eb 48                	jmp    f0104eb8 <_alltraps>

f0104e70 <t12>:
	TRAPHANDLER	(t12, T_STACK);
f0104e70:	6a 0c                	push   $0xc
f0104e72:	eb 44                	jmp    f0104eb8 <_alltraps>

f0104e74 <t13>:
	TRAPHANDLER	(t13, T_GPFLT);
f0104e74:	6a 0d                	push   $0xd
f0104e76:	eb 40                	jmp    f0104eb8 <_alltraps>

f0104e78 <t14>:
	TRAPHANDLER	(t14, T_PGFLT);
f0104e78:	6a 0e                	push   $0xe
f0104e7a:	eb 3c                	jmp    f0104eb8 <_alltraps>

f0104e7c <t16>:
	TRAPHANDLER_NOEC(t16, T_FPERR);
f0104e7c:	6a 00                	push   $0x0
f0104e7e:	6a 10                	push   $0x10
f0104e80:	eb 36                	jmp    f0104eb8 <_alltraps>

f0104e82 <t17>:
	TRAPHANDLER	(t17, T_ALIGN);
f0104e82:	6a 11                	push   $0x11
f0104e84:	eb 32                	jmp    f0104eb8 <_alltraps>

f0104e86 <t18>:
	TRAPHANDLER_NOEC(t18, T_MCHK);
f0104e86:	6a 00                	push   $0x0
f0104e88:	6a 12                	push   $0x12
f0104e8a:	eb 2c                	jmp    f0104eb8 <_alltraps>

f0104e8c <t19>:
	TRAPHANDLER_NOEC(t19, T_SIMDERR );
f0104e8c:	6a 00                	push   $0x0
f0104e8e:	6a 13                	push   $0x13
f0104e90:	eb 26                	jmp    f0104eb8 <_alltraps>

f0104e92 <sysenter_handler>:
/*
 * Lab 3: Your code here for system call handling
 */
/*stone's solution for lab3-B*/
	//User Data
	pushl $GD_UD
f0104e92:	6a 20                	push   $0x20
	pushl %ebp
f0104e94:	55                   	push   %ebp
	//flag registers
	pushfl
f0104e95:	9c                   	pushf  
	//User Text
	pushl $GD_UT
f0104e96:	6a 18                	push   $0x18
	pushl %esi
f0104e98:	56                   	push   %esi
	pushl $0
f0104e99:	6a 00                	push   $0x0
	pushl $0
f0104e9b:	6a 00                	push   $0x0
	pushl %ds
f0104e9d:	1e                   	push   %ds
	pushl %es
f0104e9e:	06                   	push   %es

	//tf parse to router
	pushal
f0104e9f:	60                   	pusha  
	//switch to Kernel Data
	movw $GD_KD, %ax
f0104ea0:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104ea4:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104ea6:	8e c0                	mov    %eax,%es
	pushl %esp
f0104ea8:	54                   	push   %esp
	//router is a method to parse modified register to syscall
	call router
f0104ea9:	e8 60 03 00 00       	call   f010520e <router>
	popl %esp
f0104eae:	5c                   	pop    %esp
	popal
f0104eaf:	61                   	popa   
	popl %es
f0104eb0:	07                   	pop    %es
	popl %ds
f0104eb1:	1f                   	pop    %ds
	movl %ebp, %ecx
f0104eb2:	89 e9                	mov    %ebp,%ecx
	movl %esi, %edx
f0104eb4:	89 f2                	mov    %esi,%edx
	sysexit
f0104eb6:	0f 35                	sysexit 

f0104eb8 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
/*stone's solution for lab3-A*/
_alltraps:
	pushl %ds
f0104eb8:	1e                   	push   %ds
	pushl %es
f0104eb9:	06                   	push   %es
	pushal
f0104eba:	60                   	pusha  
	
	movw $GD_KD, %ax
f0104ebb:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104ebf:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104ec1:	8e c0                	mov    %eax,%es
	
	pushl %esp
f0104ec3:	54                   	push   %esp
	call trap
f0104ec4:	e8 ae fd ff ff       	call   f0104c77 <trap>
f0104ec9:	00 00                	add    %al,(%eax)
f0104ecb:	00 00                	add    %al,(%eax)
f0104ecd:	00 00                	add    %al,(%eax)
	...

f0104ed0 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104ed0:	55                   	push   %ebp
f0104ed1:	89 e5                	mov    %esp,%ebp
f0104ed3:	53                   	push   %ebx
f0104ed4:	83 ec 14             	sub    $0x14,%esp

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104ed7:	8b 1d 5c 52 23 f0    	mov    0xf023525c,%ebx
f0104edd:	89 d8                	mov    %ebx,%eax
f0104edf:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ee4:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0104ee8:	74 0b                	je     f0104ef5 <sched_yield+0x25>
f0104eea:	8b 48 54             	mov    0x54(%eax),%ecx
f0104eed:	83 e9 02             	sub    $0x2,%ecx
f0104ef0:	83 f9 01             	cmp    $0x1,%ecx
f0104ef3:	76 10                	jbe    f0104f05 <sched_yield+0x35>
	// LAB 4: Your code here.

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ef5:	83 c2 01             	add    $0x1,%edx
f0104ef8:	83 e8 80             	sub    $0xffffff80,%eax
f0104efb:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104f01:	75 e1                	jne    f0104ee4 <sched_yield+0x14>
f0104f03:	eb 08                	jmp    f0104f0d <sched_yield+0x3d>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104f05:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104f0b:	75 1a                	jne    f0104f27 <sched_yield+0x57>
		cprintf("No more runnable environments!\n");
f0104f0d:	c7 04 24 90 83 10 f0 	movl   $0xf0108390,(%esp)
f0104f14:	e8 d2 f6 ff ff       	call   f01045eb <cprintf>
		while (1)
			monitor(NULL);
f0104f19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104f20:	e8 d5 bb ff ff       	call   f0100afa <monitor>
f0104f25:	eb f2                	jmp    f0104f19 <sched_yield+0x49>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0104f27:	e8 e2 16 00 00       	call   f010660e <cpunum>
f0104f2c:	c1 e0 07             	shl    $0x7,%eax
f0104f2f:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0104f31:	8b 43 54             	mov    0x54(%ebx),%eax
f0104f34:	83 e8 02             	sub    $0x2,%eax
f0104f37:	83 f8 01             	cmp    $0x1,%eax
f0104f3a:	76 25                	jbe    f0104f61 <sched_yield+0x91>
		panic("CPU %d: No idle environment!", cpunum());
f0104f3c:	e8 cd 16 00 00       	call   f010660e <cpunum>
f0104f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f45:	c7 44 24 08 b0 83 10 	movl   $0xf01083b0,0x8(%esp)
f0104f4c:	f0 
f0104f4d:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f0104f54:	00 
f0104f55:	c7 04 24 cd 83 10 f0 	movl   $0xf01083cd,(%esp)
f0104f5c:	e8 24 b1 ff ff       	call   f0100085 <_panic>
	env_run(idle);
f0104f61:	89 1c 24             	mov    %ebx,(%esp)
f0104f64:	e8 2a ed ff ff       	call   f0103c93 <env_run>
f0104f69:	00 00                	add    %al,(%eax)
f0104f6b:	00 00                	add    %al,(%eax)
f0104f6d:	00 00                	add    %al,(%eax)
	...

f0104f70 <sbrk>:

//=======
/*stone's solution for lab3-B*/
void
sbrk(struct Env* e, size_t len)
{
f0104f70:	55                   	push   %ebp
f0104f71:	89 e5                	mov    %esp,%ebp
f0104f73:	57                   	push   %edi
f0104f74:	56                   	push   %esi
f0104f75:	53                   	push   %ebx
f0104f76:	83 ec 2c             	sub    $0x2c,%esp
f0104f79:	8b 75 08             	mov    0x8(%ebp),%esi
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
f0104f7c:	8b 7e 60             	mov    0x60(%esi),%edi
f0104f7f:	89 f8                	mov    %edi,%eax
f0104f81:	2b 45 0c             	sub    0xc(%ebp),%eax
f0104f84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104f89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
f0104f8c:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0104f92:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
f0104f98:	39 f8                	cmp    %edi,%eax
f0104f9a:	73 77                	jae    f0105013 <sbrk+0xa3>
f0104f9c:	89 c3                	mov    %eax,%ebx
		int r;
		if (!(p = page_alloc(0)))
f0104f9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104fa5:	e8 c5 c8 ff ff       	call   f010186f <page_alloc>
f0104faa:	85 c0                	test   %eax,%eax
f0104fac:	75 1c                	jne    f0104fca <sbrk+0x5a>
			panic("env_alloc: page alloc failed\n");
f0104fae:	c7 44 24 08 5b 7f 10 	movl   $0xf0107f5b,0x8(%esp)
f0104fb5:	f0 
f0104fb6:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0104fbd:	00 
f0104fbe:	c7 04 24 da 83 10 f0 	movl   $0xf01083da,(%esp)
f0104fc5:	e8 bb b0 ff ff       	call   f0100085 <_panic>
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
f0104fca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104fd1:	00 
f0104fd2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fda:	8b 46 64             	mov    0x64(%esi),%eax
f0104fdd:	89 04 24             	mov    %eax,(%esp)
f0104fe0:	e8 a1 cb ff ff       	call   f0101b86 <page_insert>
f0104fe5:	85 c0                	test   %eax,%eax
f0104fe7:	79 20                	jns    f0105009 <sbrk+0x99>
			panic("env_alloc: %e\n", r);
f0104fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fed:	c7 44 24 08 79 7f 10 	movl   $0xf0107f79,0x8(%esp)
f0104ff4:	f0 
f0104ff5:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f0104ffc:	00 
f0104ffd:	c7 04 24 da 83 10 f0 	movl   $0xf01083da,(%esp)
f0105004:	e8 7c b0 ff ff       	call   f0100085 <_panic>
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
f0105009:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010500f:	39 df                	cmp    %ebx,%edi
f0105011:	77 8b                	ja     f0104f9e <sbrk+0x2e>
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
		//cprintf("2\n");
	}
	e->env_sbrk_pos = start;	
f0105013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105016:	89 46 60             	mov    %eax,0x60(%esi)
}
f0105019:	83 c4 2c             	add    $0x2c,%esp
f010501c:	5b                   	pop    %ebx
f010501d:	5e                   	pop    %esi
f010501e:	5f                   	pop    %edi
f010501f:	5d                   	pop    %ebp
f0105020:	c3                   	ret    

f0105021 <syscall>:
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105021:	55                   	push   %ebp
f0105022:	89 e5                	mov    %esp,%ebp
f0105024:	83 ec 28             	sub    $0x28,%esp
f0105027:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010502a:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010502d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105030:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105033:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	int32_t ret = -E_INVAL;
	switch (syscallno){
f0105036:	83 f8 0e             	cmp    $0xe,%eax
f0105039:	77 07                	ja     f0105042 <syscall+0x21>
f010503b:	ff 24 85 24 84 10 f0 	jmp    *-0xfef7bdc(,%eax,4)
f0105042:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105047:	e9 b8 01 00 00       	jmp    f0105204 <syscall+0x1e3>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	user_mem_assert(curenv, (void*)s, len, PTE_P | PTE_U);
f010504c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105050:	e8 b9 15 00 00       	call   f010660e <cpunum>
f0105055:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f010505c:	00 
f010505d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105061:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105065:	6b c0 74             	imul   $0x74,%eax,%eax
f0105068:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f010506e:	89 04 24             	mov    %eax,(%esp)
f0105071:	e8 f7 c9 ff ff       	call   f0101a6d <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0105076:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010507a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010507e:	c7 04 24 e9 83 10 f0 	movl   $0xf01083e9,(%esp)
f0105085:	e8 61 f5 ff ff       	call   f01045eb <cprintf>
f010508a:	b8 00 00 00 00       	mov    $0x0,%eax
f010508f:	e9 70 01 00 00       	jmp    f0105204 <syscall+0x1e3>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105094:	e8 b6 b3 ff ff       	call   f010044f <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0105099:	e9 66 01 00 00       	jmp    f0105204 <syscall+0x1e3>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	//cprintf("get:%08x\n", curenv->env_id);
	return curenv->env_id;
f010509e:	66 90                	xchg   %ax,%ax
f01050a0:	e8 69 15 00 00       	call   f010660e <cpunum>
f01050a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a8:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01050ae:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f01050b1:	e9 4e 01 00 00       	jmp    f0105204 <syscall+0x1e3>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01050b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050bd:	00 
f01050be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01050c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050c5:	89 1c 24             	mov    %ebx,(%esp)
f01050c8:	e8 dd ea ff ff       	call   f0103baa <envid2env>
f01050cd:	85 c0                	test   %eax,%eax
f01050cf:	0f 88 2f 01 00 00    	js     f0105204 <syscall+0x1e3>
		return r;
	if (e == curenv)
f01050d5:	e8 34 15 00 00       	call   f010660e <cpunum>
f01050da:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01050dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e0:	39 90 28 60 23 f0    	cmp    %edx,-0xfdc9fd8(%eax)
f01050e6:	75 23                	jne    f010510b <syscall+0xea>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01050e8:	e8 21 15 00 00       	call   f010660e <cpunum>
f01050ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f0:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01050f6:	8b 40 48             	mov    0x48(%eax),%eax
f01050f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050fd:	c7 04 24 ee 83 10 f0 	movl   $0xf01083ee,(%esp)
f0105104:	e8 e2 f4 ff ff       	call   f01045eb <cprintf>
f0105109:	eb 28                	jmp    f0105133 <syscall+0x112>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010510b:	8b 5a 48             	mov    0x48(%edx),%ebx
f010510e:	e8 fb 14 00 00       	call   f010660e <cpunum>
f0105113:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105117:	6b c0 74             	imul   $0x74,%eax,%eax
f010511a:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0105120:	8b 40 48             	mov    0x48(%eax),%eax
f0105123:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105127:	c7 04 24 09 84 10 f0 	movl   $0xf0108409,(%esp)
f010512e:	e8 b8 f4 ff ff       	call   f01045eb <cprintf>
	env_destroy(e);
f0105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105136:	89 04 24             	mov    %eax,(%esp)
f0105139:	e8 85 ee ff ff       	call   f0103fc3 <env_destroy>
f010513e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105143:	e9 bc 00 00 00       	jmp    f0105204 <syscall+0x1e3>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0105148:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010514e:	77 20                	ja     f0105170 <syscall+0x14f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105150:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105154:	c7 44 24 08 9c 6d 10 	movl   $0xf0106d9c,0x8(%esp)
f010515b:	f0 
f010515c:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0105163:	00 
f0105164:	c7 04 24 da 83 10 f0 	movl   $0xf01083da,(%esp)
f010516b:	e8 15 af ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105170:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0105176:	c1 eb 0c             	shr    $0xc,%ebx
f0105179:	3b 1d 08 5f 23 f0    	cmp    0xf0235f08,%ebx
f010517f:	72 1c                	jb     f010519d <syscall+0x17c>
		panic("pa2page called with invalid pa");
f0105181:	c7 44 24 08 50 75 10 	movl   $0xf0107550,0x8(%esp)
f0105188:	f0 
f0105189:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0105190:	00 
f0105191:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0105198:	e8 e8 ae ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f010519d:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f01051a0:	b8 03 00 00 00       	mov    $0x3,%eax
f01051a5:	03 1d 10 5f 23 f0    	add    0xf0235f10,%ebx
f01051ab:	74 57                	je     f0105204 <syscall+0x1e3>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f01051ad:	e8 5c 14 00 00       	call   f010660e <cpunum>
f01051b2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01051b9:	00 
f01051ba:	89 74 24 08          	mov    %esi,0x8(%esp)
f01051be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01051c5:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01051cb:	8b 40 64             	mov    0x64(%eax),%eax
f01051ce:	89 04 24             	mov    %eax,(%esp)
f01051d1:	e8 b0 c9 ff ff       	call   f0101b86 <page_insert>
f01051d6:	eb 2c                	jmp    f0105204 <syscall+0x1e3>
static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	/*stone's solution for lab3-B*/
	sbrk(curenv, inc);
f01051d8:	e8 31 14 00 00       	call   f010660e <cpunum>
f01051dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051e1:	bb 20 60 23 f0       	mov    $0xf0236020,%ebx
f01051e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01051e9:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01051ed:	89 04 24             	mov    %eax,(%esp)
f01051f0:	e8 7b fd ff ff       	call   f0104f70 <sbrk>
	return (int)curenv->env_sbrk_pos;
f01051f5:	e8 14 14 00 00       	call   f010660e <cpunum>
f01051fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01051fd:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105201:	8b 40 60             	mov    0x60(%eax),%eax
		default:
			break;
	}
	return ret;
	//panic("syscall not implemented");
}
f0105204:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0105207:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010520a:	89 ec                	mov    %ebp,%esp
f010520c:	5d                   	pop    %ebp
f010520d:	c3                   	ret    

f010520e <router>:
	sbrk(curenv, inc);
	return (int)curenv->env_sbrk_pos;
}
/*stone's solution for lab3-B*/
void
router(struct Trapframe *tf){
f010520e:	55                   	push   %ebp
f010520f:	89 e5                	mov    %esp,%ebp
f0105211:	83 ec 38             	sub    $0x38,%esp
f0105214:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105217:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010521a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010521d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	curenv->env_tf = *tf;
f0105220:	e8 e9 13 00 00       	call   f010660e <cpunum>
f0105225:	6b c0 74             	imul   $0x74,%eax,%eax
f0105228:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f010522e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105233:	89 c7                	mov    %eax,%edi
f0105235:	89 de                	mov    %ebx,%esi
f0105237:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
f0105239:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f0105240:	00 
f0105241:	8b 03                	mov    (%ebx),%eax
f0105243:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105247:	8b 43 10             	mov    0x10(%ebx),%eax
f010524a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010524e:	8b 43 18             	mov    0x18(%ebx),%eax
f0105251:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105255:	8b 43 14             	mov    0x14(%ebx),%eax
f0105258:	89 44 24 04          	mov    %eax,0x4(%esp)
f010525c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010525f:	89 04 24             	mov    %eax,(%esp)
f0105262:	e8 ba fd ff ff       	call   f0105021 <syscall>
f0105267:	89 43 1c             	mov    %eax,0x1c(%ebx)
}
f010526a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010526d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105270:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105273:	89 ec                	mov    %ebp,%esp
f0105275:	5d                   	pop    %ebp
f0105276:	c3                   	ret    
	...

f0105280 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105280:	55                   	push   %ebp
f0105281:	89 e5                	mov    %esp,%ebp
f0105283:	57                   	push   %edi
f0105284:	56                   	push   %esi
f0105285:	53                   	push   %ebx
f0105286:	83 ec 14             	sub    $0x14,%esp
f0105289:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010528c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010528f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105292:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105295:	8b 1a                	mov    (%edx),%ebx
f0105297:	8b 01                	mov    (%ecx),%eax
f0105299:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010529c:	39 c3                	cmp    %eax,%ebx
f010529e:	0f 8f 9c 00 00 00    	jg     f0105340 <stab_binsearch+0xc0>
f01052a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01052ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01052ae:	01 d8                	add    %ebx,%eax
f01052b0:	89 c7                	mov    %eax,%edi
f01052b2:	c1 ef 1f             	shr    $0x1f,%edi
f01052b5:	01 c7                	add    %eax,%edi
f01052b7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052b9:	39 df                	cmp    %ebx,%edi
f01052bb:	7c 33                	jl     f01052f0 <stab_binsearch+0x70>
f01052bd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01052c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01052c3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01052c8:	39 f0                	cmp    %esi,%eax
f01052ca:	0f 84 bc 00 00 00    	je     f010538c <stab_binsearch+0x10c>
f01052d0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f01052d4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f01052d8:	89 f8                	mov    %edi,%eax
			m--;
f01052da:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052dd:	39 d8                	cmp    %ebx,%eax
f01052df:	7c 0f                	jl     f01052f0 <stab_binsearch+0x70>
f01052e1:	0f b6 0a             	movzbl (%edx),%ecx
f01052e4:	83 ea 0c             	sub    $0xc,%edx
f01052e7:	39 f1                	cmp    %esi,%ecx
f01052e9:	75 ef                	jne    f01052da <stab_binsearch+0x5a>
f01052eb:	e9 9e 00 00 00       	jmp    f010538e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01052f0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01052f3:	eb 3c                	jmp    f0105331 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01052f5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01052f8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01052fa:	8d 5f 01             	lea    0x1(%edi),%ebx
f01052fd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105304:	eb 2b                	jmp    f0105331 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0105306:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105309:	76 14                	jbe    f010531f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010530b:	83 e8 01             	sub    $0x1,%eax
f010530e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105311:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105314:	89 02                	mov    %eax,(%edx)
f0105316:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010531d:	eb 12                	jmp    f0105331 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010531f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105322:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0105324:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105328:	89 c3                	mov    %eax,%ebx
f010532a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0105331:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0105334:	0f 8d 71 ff ff ff    	jge    f01052ab <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010533a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010533e:	75 0f                	jne    f010534f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0105340:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105343:	8b 03                	mov    (%ebx),%eax
f0105345:	83 e8 01             	sub    $0x1,%eax
f0105348:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010534b:	89 02                	mov    %eax,(%edx)
f010534d:	eb 57                	jmp    f01053a6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010534f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105352:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105354:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105357:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105359:	39 c1                	cmp    %eax,%ecx
f010535b:	7d 28                	jge    f0105385 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010535d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105360:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105363:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105368:	39 f2                	cmp    %esi,%edx
f010536a:	74 19                	je     f0105385 <stab_binsearch+0x105>
f010536c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105370:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0105374:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105377:	39 c1                	cmp    %eax,%ecx
f0105379:	7d 0a                	jge    f0105385 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010537b:	0f b6 1a             	movzbl (%edx),%ebx
f010537e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105381:	39 f3                	cmp    %esi,%ebx
f0105383:	75 ef                	jne    f0105374 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0105385:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105388:	89 02                	mov    %eax,(%edx)
f010538a:	eb 1a                	jmp    f01053a6 <stab_binsearch+0x126>
	}
}
f010538c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010538e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105391:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105394:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105398:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010539b:	0f 82 54 ff ff ff    	jb     f01052f5 <stab_binsearch+0x75>
f01053a1:	e9 60 ff ff ff       	jmp    f0105306 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01053a6:	83 c4 14             	add    $0x14,%esp
f01053a9:	5b                   	pop    %ebx
f01053aa:	5e                   	pop    %esi
f01053ab:	5f                   	pop    %edi
f01053ac:	5d                   	pop    %ebp
f01053ad:	c3                   	ret    

f01053ae <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01053ae:	55                   	push   %ebp
f01053af:	89 e5                	mov    %esp,%ebp
f01053b1:	83 ec 58             	sub    $0x58,%esp
f01053b4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01053b7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01053ba:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01053bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01053c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01053c3:	c7 03 60 84 10 f0    	movl   $0xf0108460,(%ebx)
	info->eip_line = 0;
f01053c9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01053d0:	c7 43 08 60 84 10 f0 	movl   $0xf0108460,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01053d7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01053de:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01053e1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01053e8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01053ee:	76 1f                	jbe    f010540f <debuginfo_eip+0x61>
f01053f0:	bf 74 6f 11 f0       	mov    $0xf0116f74,%edi
f01053f5:	c7 45 c4 e5 32 11 f0 	movl   $0xf01132e5,-0x3c(%ebp)
f01053fc:	c7 45 bc e4 32 11 f0 	movl   $0xf01132e4,-0x44(%ebp)
f0105403:	c7 45 c0 34 89 10 f0 	movl   $0xf0108934,-0x40(%ebp)
f010540a:	e9 c7 00 00 00       	jmp    f01054d6 <debuginfo_eip+0x128>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		/*stone's solution for lab3-B*/
		if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f010540f:	e8 fa 11 00 00       	call   f010660e <cpunum>
f0105414:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010541b:	00 
f010541c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105423:	00 
f0105424:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010542b:	00 
f010542c:	6b c0 74             	imul   $0x74,%eax,%eax
f010542f:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0105435:	89 04 24             	mov    %eax,(%esp)
f0105438:	e8 9c c5 ff ff       	call   f01019d9 <user_mem_check>
f010543d:	85 c0                	test   %eax,%eax
f010543f:	0f 88 01 02 00 00    	js     f0105646 <debuginfo_eip+0x298>
		stabs = usd->stabs;
f0105445:	b8 00 00 20 00       	mov    $0x200000,%eax
f010544a:	8b 10                	mov    (%eax),%edx
f010544c:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f010544f:	8b 48 04             	mov    0x4(%eax),%ecx
f0105452:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f0105455:	8b 50 08             	mov    0x8(%eax),%edx
f0105458:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f010545b:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		/*stone's solution for lab3-B*/
		if (user_mem_check(curenv, (void*)stabs, stab_end - stabs, PTE_U) < 0) return -1;
f010545e:	e8 ab 11 00 00       	call   f010660e <cpunum>
f0105463:	89 c2                	mov    %eax,%edx
f0105465:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010546c:	00 
f010546d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105470:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105473:	c1 f8 02             	sar    $0x2,%eax
f0105476:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010547c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105480:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105483:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105487:	6b c2 74             	imul   $0x74,%edx,%eax
f010548a:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f0105490:	89 04 24             	mov    %eax,(%esp)
f0105493:	e8 41 c5 ff ff       	call   f01019d9 <user_mem_check>
f0105498:	85 c0                	test   %eax,%eax
f010549a:	0f 88 a6 01 00 00    	js     f0105646 <debuginfo_eip+0x298>
		if (user_mem_check(curenv, (void*)stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f01054a0:	e8 69 11 00 00       	call   f010660e <cpunum>
f01054a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01054ac:	00 
f01054ad:	89 fa                	mov    %edi,%edx
f01054af:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01054b2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01054b6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01054b9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01054c0:	8b 80 28 60 23 f0    	mov    -0xfdc9fd8(%eax),%eax
f01054c6:	89 04 24             	mov    %eax,(%esp)
f01054c9:	e8 0b c5 ff ff       	call   f01019d9 <user_mem_check>
f01054ce:	85 c0                	test   %eax,%eax
f01054d0:	0f 88 70 01 00 00    	js     f0105646 <debuginfo_eip+0x298>
		
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01054d6:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f01054d9:	0f 83 67 01 00 00    	jae    f0105646 <debuginfo_eip+0x298>
f01054df:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01054e3:	0f 85 5d 01 00 00    	jne    f0105646 <debuginfo_eip+0x298>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01054e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01054f0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01054f3:	2b 45 c0             	sub    -0x40(%ebp),%eax
f01054f6:	c1 f8 02             	sar    $0x2,%eax
f01054f9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01054ff:	83 e8 01             	sub    $0x1,%eax
f0105502:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105505:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105508:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010550b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010550f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105516:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105519:	e8 62 fd ff ff       	call   f0105280 <stab_binsearch>
	if (lfile == 0)
f010551e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105521:	85 c0                	test   %eax,%eax
f0105523:	0f 84 1d 01 00 00    	je     f0105646 <debuginfo_eip+0x298>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105529:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010552c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010552f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105532:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105535:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105538:	89 74 24 04          	mov    %esi,0x4(%esp)
f010553c:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105543:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105546:	e8 35 fd ff ff       	call   f0105280 <stab_binsearch>

	if (lfun <= rfun) {
f010554b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010554e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105551:	7f 35                	jg     f0105588 <debuginfo_eip+0x1da>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105553:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105556:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105559:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f010555c:	89 fa                	mov    %edi,%edx
f010555e:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105561:	39 d0                	cmp    %edx,%eax
f0105563:	73 06                	jae    f010556b <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105565:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105568:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010556b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010556e:	6b c2 0c             	imul   $0xc,%edx,%eax
f0105571:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105574:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f0105578:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010557b:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010557d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0105580:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105583:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105586:	eb 0f                	jmp    f0105597 <debuginfo_eip+0x1e9>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105588:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010558b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010558e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105591:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105594:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105597:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010559e:	00 
f010559f:	8b 43 08             	mov    0x8(%ebx),%eax
f01055a2:	89 04 24             	mov    %eax,(%esp)
f01055a5:	e8 91 09 00 00       	call   f0105f3b <strfind>
f01055aa:	2b 43 08             	sub    0x8(%ebx),%eax
f01055ad:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	/* stone's solution for exercise15 */
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01055b0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01055b3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01055b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01055ba:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01055c1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01055c4:	e8 b7 fc ff ff       	call   f0105280 <stab_binsearch>
	if (lline <= rline)
f01055c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01055cc:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01055cf:	7f 75                	jg     f0105646 <debuginfo_eip+0x298>
		info->eip_line = stabs[lline].n_desc;
f01055d1:	6b c0 0c             	imul   $0xc,%eax,%eax
f01055d4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01055d7:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f01055dc:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01055df:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055e2:	eb 06                	jmp    f01055ea <debuginfo_eip+0x23c>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01055e4:	83 e8 01             	sub    $0x1,%eax
f01055e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01055ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055ed:	39 f0                	cmp    %esi,%eax
f01055ef:	7c 26                	jl     f0105617 <debuginfo_eip+0x269>
	       && stabs[lline].n_type != N_SOL
f01055f1:	6b d0 0c             	imul   $0xc,%eax,%edx
f01055f4:	03 55 c0             	add    -0x40(%ebp),%edx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01055f7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055fb:	80 f9 84             	cmp    $0x84,%cl
f01055fe:	74 5f                	je     f010565f <debuginfo_eip+0x2b1>
f0105600:	80 f9 64             	cmp    $0x64,%cl
f0105603:	75 df                	jne    f01055e4 <debuginfo_eip+0x236>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105605:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105609:	74 d9                	je     f01055e4 <debuginfo_eip+0x236>
f010560b:	90                   	nop
f010560c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105610:	eb 4d                	jmp    f010565f <debuginfo_eip+0x2b1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105612:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105615:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105617:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010561a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010561d:	7d 2e                	jge    f010564d <debuginfo_eip+0x29f>
		for (lline = lfun + 1;
f010561f:	83 c0 01             	add    $0x1,%eax
f0105622:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105625:	eb 08                	jmp    f010562f <debuginfo_eip+0x281>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105627:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010562b:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010562f:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105632:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105635:	7d 16                	jge    f010564d <debuginfo_eip+0x29f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105637:	6b c0 0c             	imul   $0xc,%eax,%eax
f010563a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010563d:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f0105642:	74 e3                	je     f0105627 <debuginfo_eip+0x279>
f0105644:	eb 07                	jmp    f010564d <debuginfo_eip+0x29f>
f0105646:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010564b:	eb 05                	jmp    f0105652 <debuginfo_eip+0x2a4>
f010564d:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0105652:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105655:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105658:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010565b:	89 ec                	mov    %ebp,%esp
f010565d:	5d                   	pop    %ebp
f010565e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010565f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105662:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105665:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0105668:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f010566b:	39 f8                	cmp    %edi,%eax
f010566d:	72 a3                	jb     f0105612 <debuginfo_eip+0x264>
f010566f:	eb a6                	jmp    f0105617 <debuginfo_eip+0x269>
	...

f0105680 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105680:	55                   	push   %ebp
f0105681:	89 e5                	mov    %esp,%ebp
f0105683:	57                   	push   %edi
f0105684:	56                   	push   %esi
f0105685:	53                   	push   %ebx
f0105686:	83 ec 4c             	sub    $0x4c,%esp
f0105689:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010568c:	89 d6                	mov    %edx,%esi
f010568e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105691:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105694:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105697:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010569a:	8b 45 10             	mov    0x10(%ebp),%eax
f010569d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01056a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01056a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01056a6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056ab:	39 d1                	cmp    %edx,%ecx
f01056ad:	72 15                	jb     f01056c4 <printnum+0x44>
f01056af:	77 07                	ja     f01056b8 <printnum+0x38>
f01056b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056b4:	39 d0                	cmp    %edx,%eax
f01056b6:	76 0c                	jbe    f01056c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01056b8:	83 eb 01             	sub    $0x1,%ebx
f01056bb:	85 db                	test   %ebx,%ebx
f01056bd:	8d 76 00             	lea    0x0(%esi),%esi
f01056c0:	7f 61                	jg     f0105723 <printnum+0xa3>
f01056c2:	eb 70                	jmp    f0105734 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01056c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01056c8:	83 eb 01             	sub    $0x1,%ebx
f01056cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01056cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01056d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01056db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01056de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01056e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01056e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01056e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01056ef:	00 
f01056f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01056f3:	89 04 24             	mov    %eax,(%esp)
f01056f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01056f9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056fd:	e8 ae 13 00 00       	call   f0106ab0 <__udivdi3>
f0105702:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105705:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010570c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105710:	89 04 24             	mov    %eax,(%esp)
f0105713:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105717:	89 f2                	mov    %esi,%edx
f0105719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010571c:	e8 5f ff ff ff       	call   f0105680 <printnum>
f0105721:	eb 11                	jmp    f0105734 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105723:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105727:	89 3c 24             	mov    %edi,(%esp)
f010572a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010572d:	83 eb 01             	sub    $0x1,%ebx
f0105730:	85 db                	test   %ebx,%ebx
f0105732:	7f ef                	jg     f0105723 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105734:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105738:	8b 74 24 04          	mov    0x4(%esp),%esi
f010573c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010573f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105743:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010574a:	00 
f010574b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010574e:	89 14 24             	mov    %edx,(%esp)
f0105751:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105754:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105758:	e8 83 14 00 00       	call   f0106be0 <__umoddi3>
f010575d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105761:	0f be 80 6a 84 10 f0 	movsbl -0xfef7b96(%eax),%eax
f0105768:	89 04 24             	mov    %eax,(%esp)
f010576b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010576e:	83 c4 4c             	add    $0x4c,%esp
f0105771:	5b                   	pop    %ebx
f0105772:	5e                   	pop    %esi
f0105773:	5f                   	pop    %edi
f0105774:	5d                   	pop    %ebp
f0105775:	c3                   	ret    

f0105776 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105776:	55                   	push   %ebp
f0105777:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105779:	83 fa 01             	cmp    $0x1,%edx
f010577c:	7e 0e                	jle    f010578c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010577e:	8b 10                	mov    (%eax),%edx
f0105780:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105783:	89 08                	mov    %ecx,(%eax)
f0105785:	8b 02                	mov    (%edx),%eax
f0105787:	8b 52 04             	mov    0x4(%edx),%edx
f010578a:	eb 22                	jmp    f01057ae <getuint+0x38>
	else if (lflag)
f010578c:	85 d2                	test   %edx,%edx
f010578e:	74 10                	je     f01057a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105790:	8b 10                	mov    (%eax),%edx
f0105792:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105795:	89 08                	mov    %ecx,(%eax)
f0105797:	8b 02                	mov    (%edx),%eax
f0105799:	ba 00 00 00 00       	mov    $0x0,%edx
f010579e:	eb 0e                	jmp    f01057ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01057a0:	8b 10                	mov    (%eax),%edx
f01057a2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057a5:	89 08                	mov    %ecx,(%eax)
f01057a7:	8b 02                	mov    (%edx),%eax
f01057a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01057ae:	5d                   	pop    %ebp
f01057af:	c3                   	ret    

f01057b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01057b0:	55                   	push   %ebp
f01057b1:	89 e5                	mov    %esp,%ebp
f01057b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01057b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01057ba:	8b 10                	mov    (%eax),%edx
f01057bc:	3b 50 04             	cmp    0x4(%eax),%edx
f01057bf:	73 0a                	jae    f01057cb <sprintputch+0x1b>
		*b->buf++ = ch;
f01057c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057c4:	88 0a                	mov    %cl,(%edx)
f01057c6:	83 c2 01             	add    $0x1,%edx
f01057c9:	89 10                	mov    %edx,(%eax)
}
f01057cb:	5d                   	pop    %ebp
f01057cc:	c3                   	ret    

f01057cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01057cd:	55                   	push   %ebp
f01057ce:	89 e5                	mov    %esp,%ebp
f01057d0:	57                   	push   %edi
f01057d1:	56                   	push   %esi
f01057d2:	53                   	push   %ebx
f01057d3:	83 ec 5c             	sub    $0x5c,%esp
f01057d6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057d9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01057df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01057e6:	eb 11                	jmp    f01057f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01057e8:	85 c0                	test   %eax,%eax
f01057ea:	0f 84 09 04 00 00    	je     f0105bf9 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
f01057f0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057f4:	89 04 24             	mov    %eax,(%esp)
f01057f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01057f9:	0f b6 03             	movzbl (%ebx),%eax
f01057fc:	83 c3 01             	add    $0x1,%ebx
f01057ff:	83 f8 25             	cmp    $0x25,%eax
f0105802:	75 e4                	jne    f01057e8 <vprintfmt+0x1b>
f0105804:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0105808:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010580f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105816:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010581d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105822:	eb 06                	jmp    f010582a <vprintfmt+0x5d>
f0105824:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0105828:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010582a:	0f b6 13             	movzbl (%ebx),%edx
f010582d:	0f b6 c2             	movzbl %dl,%eax
f0105830:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105833:	8d 43 01             	lea    0x1(%ebx),%eax
f0105836:	83 ea 23             	sub    $0x23,%edx
f0105839:	80 fa 55             	cmp    $0x55,%dl
f010583c:	0f 87 9a 03 00 00    	ja     f0105bdc <vprintfmt+0x40f>
f0105842:	0f b6 d2             	movzbl %dl,%edx
f0105845:	ff 24 95 20 85 10 f0 	jmp    *-0xfef7ae0(,%edx,4)
f010584c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0105850:	eb d6                	jmp    f0105828 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105852:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105855:	83 ea 30             	sub    $0x30,%edx
f0105858:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f010585b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010585e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105861:	83 fb 09             	cmp    $0x9,%ebx
f0105864:	77 4c                	ja     f01058b2 <vprintfmt+0xe5>
f0105866:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105869:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010586c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f010586f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105872:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0105876:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0105879:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010587c:	83 fb 09             	cmp    $0x9,%ebx
f010587f:	76 eb                	jbe    f010586c <vprintfmt+0x9f>
f0105881:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105884:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105887:	eb 29                	jmp    f01058b2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105889:	8b 55 14             	mov    0x14(%ebp),%edx
f010588c:	8d 5a 04             	lea    0x4(%edx),%ebx
f010588f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0105892:	8b 12                	mov    (%edx),%edx
f0105894:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0105897:	eb 19                	jmp    f01058b2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
f0105899:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010589c:	c1 fa 1f             	sar    $0x1f,%edx
f010589f:	f7 d2                	not    %edx
f01058a1:	21 55 e4             	and    %edx,-0x1c(%ebp)
f01058a4:	eb 82                	jmp    f0105828 <vprintfmt+0x5b>
f01058a6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01058ad:	e9 76 ff ff ff       	jmp    f0105828 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f01058b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01058b6:	0f 89 6c ff ff ff    	jns    f0105828 <vprintfmt+0x5b>
f01058bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01058bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01058c2:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01058c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01058c8:	e9 5b ff ff ff       	jmp    f0105828 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01058cd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f01058d0:	e9 53 ff ff ff       	jmp    f0105828 <vprintfmt+0x5b>
f01058d5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01058d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01058db:	8d 50 04             	lea    0x4(%eax),%edx
f01058de:	89 55 14             	mov    %edx,0x14(%ebp)
f01058e1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01058e5:	8b 00                	mov    (%eax),%eax
f01058e7:	89 04 24             	mov    %eax,(%esp)
f01058ea:	ff d7                	call   *%edi
f01058ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01058ef:	e9 05 ff ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
f01058f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01058f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01058fa:	8d 50 04             	lea    0x4(%eax),%edx
f01058fd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105900:	8b 00                	mov    (%eax),%eax
f0105902:	89 c2                	mov    %eax,%edx
f0105904:	c1 fa 1f             	sar    $0x1f,%edx
f0105907:	31 d0                	xor    %edx,%eax
f0105909:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010590b:	83 f8 08             	cmp    $0x8,%eax
f010590e:	7f 0b                	jg     f010591b <vprintfmt+0x14e>
f0105910:	8b 14 85 80 86 10 f0 	mov    -0xfef7980(,%eax,4),%edx
f0105917:	85 d2                	test   %edx,%edx
f0105919:	75 20                	jne    f010593b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
f010591b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010591f:	c7 44 24 08 7b 84 10 	movl   $0xf010847b,0x8(%esp)
f0105926:	f0 
f0105927:	89 74 24 04          	mov    %esi,0x4(%esp)
f010592b:	89 3c 24             	mov    %edi,(%esp)
f010592e:	e8 4e 03 00 00       	call   f0105c81 <printfmt>
f0105933:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105936:	e9 be fe ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f010593b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010593f:	c7 44 24 08 89 7b 10 	movl   $0xf0107b89,0x8(%esp)
f0105946:	f0 
f0105947:	89 74 24 04          	mov    %esi,0x4(%esp)
f010594b:	89 3c 24             	mov    %edi,(%esp)
f010594e:	e8 2e 03 00 00       	call   f0105c81 <printfmt>
f0105953:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105956:	e9 9e fe ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
f010595b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010595e:	89 c3                	mov    %eax,%ebx
f0105960:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105966:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105969:	8b 45 14             	mov    0x14(%ebp),%eax
f010596c:	8d 50 04             	lea    0x4(%eax),%edx
f010596f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105972:	8b 00                	mov    (%eax),%eax
f0105974:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0105977:	85 c0                	test   %eax,%eax
f0105979:	75 07                	jne    f0105982 <vprintfmt+0x1b5>
f010597b:	c7 45 c4 84 84 10 f0 	movl   $0xf0108484,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0105982:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0105986:	7e 06                	jle    f010598e <vprintfmt+0x1c1>
f0105988:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010598c:	75 13                	jne    f01059a1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010598e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105991:	0f be 02             	movsbl (%edx),%eax
f0105994:	85 c0                	test   %eax,%eax
f0105996:	0f 85 99 00 00 00    	jne    f0105a35 <vprintfmt+0x268>
f010599c:	e9 86 00 00 00       	jmp    f0105a27 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01059a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01059a5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01059a8:	89 0c 24             	mov    %ecx,(%esp)
f01059ab:	e8 fb 03 00 00       	call   f0105dab <strnlen>
f01059b0:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01059b3:	29 c2                	sub    %eax,%edx
f01059b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01059b8:	85 d2                	test   %edx,%edx
f01059ba:	7e d2                	jle    f010598e <vprintfmt+0x1c1>
					putch(padc, putdat);
f01059bc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f01059c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01059c3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f01059c6:	89 d3                	mov    %edx,%ebx
f01059c8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059cf:	89 04 24             	mov    %eax,(%esp)
f01059d2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01059d4:	83 eb 01             	sub    $0x1,%ebx
f01059d7:	85 db                	test   %ebx,%ebx
f01059d9:	7f ed                	jg     f01059c8 <vprintfmt+0x1fb>
f01059db:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01059de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01059e5:	eb a7                	jmp    f010598e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01059e7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01059eb:	74 18                	je     f0105a05 <vprintfmt+0x238>
f01059ed:	8d 50 e0             	lea    -0x20(%eax),%edx
f01059f0:	83 fa 5e             	cmp    $0x5e,%edx
f01059f3:	76 10                	jbe    f0105a05 <vprintfmt+0x238>
					putch('?', putdat);
f01059f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059f9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105a00:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a03:	eb 0a                	jmp    f0105a0f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0105a05:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a09:	89 04 24             	mov    %eax,(%esp)
f0105a0c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a0f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0105a13:	0f be 03             	movsbl (%ebx),%eax
f0105a16:	85 c0                	test   %eax,%eax
f0105a18:	74 05                	je     f0105a1f <vprintfmt+0x252>
f0105a1a:	83 c3 01             	add    $0x1,%ebx
f0105a1d:	eb 29                	jmp    f0105a48 <vprintfmt+0x27b>
f0105a1f:	89 fe                	mov    %edi,%esi
f0105a21:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105a24:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a27:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a2b:	7f 2e                	jg     f0105a5b <vprintfmt+0x28e>
f0105a2d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105a30:	e9 c4 fd ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a35:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105a38:	83 c2 01             	add    $0x1,%edx
f0105a3b:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0105a3e:	89 f7                	mov    %esi,%edi
f0105a40:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0105a43:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0105a46:	89 d3                	mov    %edx,%ebx
f0105a48:	85 f6                	test   %esi,%esi
f0105a4a:	78 9b                	js     f01059e7 <vprintfmt+0x21a>
f0105a4c:	83 ee 01             	sub    $0x1,%esi
f0105a4f:	79 96                	jns    f01059e7 <vprintfmt+0x21a>
f0105a51:	89 fe                	mov    %edi,%esi
f0105a53:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105a56:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0105a59:	eb cc                	jmp    f0105a27 <vprintfmt+0x25a>
f0105a5b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0105a5e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105a61:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a65:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105a6c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a6e:	83 eb 01             	sub    $0x1,%ebx
f0105a71:	85 db                	test   %ebx,%ebx
f0105a73:	7f ec                	jg     f0105a61 <vprintfmt+0x294>
f0105a75:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105a78:	e9 7c fd ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
f0105a7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105a80:	83 f9 01             	cmp    $0x1,%ecx
f0105a83:	7e 16                	jle    f0105a9b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
f0105a85:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a88:	8d 50 08             	lea    0x8(%eax),%edx
f0105a8b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a8e:	8b 10                	mov    (%eax),%edx
f0105a90:	8b 48 04             	mov    0x4(%eax),%ecx
f0105a93:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105a96:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105a99:	eb 32                	jmp    f0105acd <vprintfmt+0x300>
	else if (lflag)
f0105a9b:	85 c9                	test   %ecx,%ecx
f0105a9d:	74 18                	je     f0105ab7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
f0105a9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aa2:	8d 50 04             	lea    0x4(%eax),%edx
f0105aa5:	89 55 14             	mov    %edx,0x14(%ebp)
f0105aa8:	8b 00                	mov    (%eax),%eax
f0105aaa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105aad:	89 c1                	mov    %eax,%ecx
f0105aaf:	c1 f9 1f             	sar    $0x1f,%ecx
f0105ab2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105ab5:	eb 16                	jmp    f0105acd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
f0105ab7:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aba:	8d 50 04             	lea    0x4(%eax),%edx
f0105abd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ac0:	8b 00                	mov    (%eax),%eax
f0105ac2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105ac5:	89 c2                	mov    %eax,%edx
f0105ac7:	c1 fa 1f             	sar    $0x1f,%edx
f0105aca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105acd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105ad0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105ad3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0105ad8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105adc:	0f 89 b8 00 00 00    	jns    f0105b9a <vprintfmt+0x3cd>
				putch('-', putdat);
f0105ae2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105ae6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105aed:	ff d7                	call   *%edi
				num = -(long long) num;
f0105aef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105af2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105af5:	f7 d9                	neg    %ecx
f0105af7:	83 d3 00             	adc    $0x0,%ebx
f0105afa:	f7 db                	neg    %ebx
f0105afc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105b01:	e9 94 00 00 00       	jmp    f0105b9a <vprintfmt+0x3cd>
f0105b06:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105b09:	89 ca                	mov    %ecx,%edx
f0105b0b:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b0e:	e8 63 fc ff ff       	call   f0105776 <getuint>
f0105b13:	89 c1                	mov    %eax,%ecx
f0105b15:	89 d3                	mov    %edx,%ebx
f0105b17:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0105b1c:	eb 7c                	jmp    f0105b9a <vprintfmt+0x3cd>
f0105b1e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105b21:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b25:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105b2c:	ff d7                	call   *%edi
			putch('X', putdat);
f0105b2e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b32:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105b39:	ff d7                	call   *%edi
			putch('X', putdat);
f0105b3b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b3f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105b46:	ff d7                	call   *%edi
f0105b48:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0105b4b:	e9 a9 fc ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
f0105b50:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0105b53:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b57:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105b5e:	ff d7                	call   *%edi
			putch('x', putdat);
f0105b60:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105b6b:	ff d7                	call   *%edi
			num = (unsigned long long)
f0105b6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b70:	8d 50 04             	lea    0x4(%eax),%edx
f0105b73:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b76:	8b 08                	mov    (%eax),%ecx
f0105b78:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105b7d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105b82:	eb 16                	jmp    f0105b9a <vprintfmt+0x3cd>
f0105b84:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105b87:	89 ca                	mov    %ecx,%edx
f0105b89:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b8c:	e8 e5 fb ff ff       	call   f0105776 <getuint>
f0105b91:	89 c1                	mov    %eax,%ecx
f0105b93:	89 d3                	mov    %edx,%ebx
f0105b95:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105b9a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0105b9e:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105ba2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105ba5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bad:	89 0c 24             	mov    %ecx,(%esp)
f0105bb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bb4:	89 f2                	mov    %esi,%edx
f0105bb6:	89 f8                	mov    %edi,%eax
f0105bb8:	e8 c3 fa ff ff       	call   f0105680 <printnum>
f0105bbd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0105bc0:	e9 34 fc ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
f0105bc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105bc8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105bcb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105bcf:	89 14 24             	mov    %edx,(%esp)
f0105bd2:	ff d7                	call   *%edi
f0105bd4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0105bd7:	e9 1d fc ff ff       	jmp    f01057f9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105bdc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105be0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105be7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105be9:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105bec:	80 38 25             	cmpb   $0x25,(%eax)
f0105bef:	0f 84 04 fc ff ff    	je     f01057f9 <vprintfmt+0x2c>
f0105bf5:	89 c3                	mov    %eax,%ebx
f0105bf7:	eb f0                	jmp    f0105be9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
f0105bf9:	83 c4 5c             	add    $0x5c,%esp
f0105bfc:	5b                   	pop    %ebx
f0105bfd:	5e                   	pop    %esi
f0105bfe:	5f                   	pop    %edi
f0105bff:	5d                   	pop    %ebp
f0105c00:	c3                   	ret    

f0105c01 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105c01:	55                   	push   %ebp
f0105c02:	89 e5                	mov    %esp,%ebp
f0105c04:	83 ec 28             	sub    $0x28,%esp
f0105c07:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0105c0d:	85 c0                	test   %eax,%eax
f0105c0f:	74 04                	je     f0105c15 <vsnprintf+0x14>
f0105c11:	85 d2                	test   %edx,%edx
f0105c13:	7f 07                	jg     f0105c1c <vsnprintf+0x1b>
f0105c15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105c1a:	eb 3b                	jmp    f0105c57 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105c1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105c1f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0105c23:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105c2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c34:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c37:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c42:	c7 04 24 b0 57 10 f0 	movl   $0xf01057b0,(%esp)
f0105c49:	e8 7f fb ff ff       	call   f01057cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105c51:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0105c57:	c9                   	leave  
f0105c58:	c3                   	ret    

f0105c59 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105c59:	55                   	push   %ebp
f0105c5a:	89 e5                	mov    %esp,%ebp
f0105c5c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0105c5f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0105c62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c66:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c69:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c74:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c77:	89 04 24             	mov    %eax,(%esp)
f0105c7a:	e8 82 ff ff ff       	call   f0105c01 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105c7f:	c9                   	leave  
f0105c80:	c3                   	ret    

f0105c81 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105c81:	55                   	push   %ebp
f0105c82:	89 e5                	mov    %esp,%ebp
f0105c84:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0105c87:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0105c8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c8e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c91:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c95:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c98:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c9f:	89 04 24             	mov    %eax,(%esp)
f0105ca2:	e8 26 fb ff ff       	call   f01057cd <vprintfmt>
	va_end(ap);
}
f0105ca7:	c9                   	leave  
f0105ca8:	c3                   	ret    
f0105ca9:	00 00                	add    %al,(%eax)
f0105cab:	00 00                	add    %al,(%eax)
f0105cad:	00 00                	add    %al,(%eax)
	...

f0105cb0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105cb0:	55                   	push   %ebp
f0105cb1:	89 e5                	mov    %esp,%ebp
f0105cb3:	57                   	push   %edi
f0105cb4:	56                   	push   %esi
f0105cb5:	53                   	push   %ebx
f0105cb6:	83 ec 1c             	sub    $0x1c,%esp
f0105cb9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105cbc:	85 c0                	test   %eax,%eax
f0105cbe:	74 10                	je     f0105cd0 <readline+0x20>
		cprintf("%s", prompt);
f0105cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cc4:	c7 04 24 89 7b 10 f0 	movl   $0xf0107b89,(%esp)
f0105ccb:	e8 1b e9 ff ff       	call   f01045eb <cprintf>

	i = 0;
	echoing = iscons(0);
f0105cd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105cd7:	e8 ca a7 ff ff       	call   f01004a6 <iscons>
f0105cdc:	89 c7                	mov    %eax,%edi
f0105cde:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105ce3:	e8 ad a7 ff ff       	call   f0100495 <getchar>
f0105ce8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105cea:	85 c0                	test   %eax,%eax
f0105cec:	79 17                	jns    f0105d05 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105cee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cf2:	c7 04 24 a4 86 10 f0 	movl   $0xf01086a4,(%esp)
f0105cf9:	e8 ed e8 ff ff       	call   f01045eb <cprintf>
f0105cfe:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0105d03:	eb 76                	jmp    f0105d7b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105d05:	83 f8 08             	cmp    $0x8,%eax
f0105d08:	74 08                	je     f0105d12 <readline+0x62>
f0105d0a:	83 f8 7f             	cmp    $0x7f,%eax
f0105d0d:	8d 76 00             	lea    0x0(%esi),%esi
f0105d10:	75 19                	jne    f0105d2b <readline+0x7b>
f0105d12:	85 f6                	test   %esi,%esi
f0105d14:	7e 15                	jle    f0105d2b <readline+0x7b>
			if (echoing)
f0105d16:	85 ff                	test   %edi,%edi
f0105d18:	74 0c                	je     f0105d26 <readline+0x76>
				cputchar('\b');
f0105d1a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105d21:	e8 84 a9 ff ff       	call   f01006aa <cputchar>
			i--;
f0105d26:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105d29:	eb b8                	jmp    f0105ce3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105d2b:	83 fb 1f             	cmp    $0x1f,%ebx
f0105d2e:	66 90                	xchg   %ax,%ax
f0105d30:	7e 23                	jle    f0105d55 <readline+0xa5>
f0105d32:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105d38:	7f 1b                	jg     f0105d55 <readline+0xa5>
			if (echoing)
f0105d3a:	85 ff                	test   %edi,%edi
f0105d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105d40:	74 08                	je     f0105d4a <readline+0x9a>
				cputchar(c);
f0105d42:	89 1c 24             	mov    %ebx,(%esp)
f0105d45:	e8 60 a9 ff ff       	call   f01006aa <cputchar>
			buf[i++] = c;
f0105d4a:	88 9e 00 5b 23 f0    	mov    %bl,-0xfdca500(%esi)
f0105d50:	83 c6 01             	add    $0x1,%esi
f0105d53:	eb 8e                	jmp    f0105ce3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105d55:	83 fb 0a             	cmp    $0xa,%ebx
f0105d58:	74 05                	je     f0105d5f <readline+0xaf>
f0105d5a:	83 fb 0d             	cmp    $0xd,%ebx
f0105d5d:	75 84                	jne    f0105ce3 <readline+0x33>
			if (echoing)
f0105d5f:	85 ff                	test   %edi,%edi
f0105d61:	74 0c                	je     f0105d6f <readline+0xbf>
				cputchar('\n');
f0105d63:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105d6a:	e8 3b a9 ff ff       	call   f01006aa <cputchar>
			buf[i] = 0;
f0105d6f:	c6 86 00 5b 23 f0 00 	movb   $0x0,-0xfdca500(%esi)
f0105d76:	b8 00 5b 23 f0       	mov    $0xf0235b00,%eax
			return buf;
		}
	}
}
f0105d7b:	83 c4 1c             	add    $0x1c,%esp
f0105d7e:	5b                   	pop    %ebx
f0105d7f:	5e                   	pop    %esi
f0105d80:	5f                   	pop    %edi
f0105d81:	5d                   	pop    %ebp
f0105d82:	c3                   	ret    
	...

f0105d90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105d90:	55                   	push   %ebp
f0105d91:	89 e5                	mov    %esp,%ebp
f0105d93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105d96:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d9b:	80 3a 00             	cmpb   $0x0,(%edx)
f0105d9e:	74 09                	je     f0105da9 <strlen+0x19>
		n++;
f0105da0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105da3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105da7:	75 f7                	jne    f0105da0 <strlen+0x10>
		n++;
	return n;
}
f0105da9:	5d                   	pop    %ebp
f0105daa:	c3                   	ret    

f0105dab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105dab:	55                   	push   %ebp
f0105dac:	89 e5                	mov    %esp,%ebp
f0105dae:	53                   	push   %ebx
f0105daf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105db5:	85 c9                	test   %ecx,%ecx
f0105db7:	74 19                	je     f0105dd2 <strnlen+0x27>
f0105db9:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105dbc:	74 14                	je     f0105dd2 <strnlen+0x27>
f0105dbe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105dc3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105dc6:	39 c8                	cmp    %ecx,%eax
f0105dc8:	74 0d                	je     f0105dd7 <strnlen+0x2c>
f0105dca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0105dce:	75 f3                	jne    f0105dc3 <strnlen+0x18>
f0105dd0:	eb 05                	jmp    f0105dd7 <strnlen+0x2c>
f0105dd2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105dd7:	5b                   	pop    %ebx
f0105dd8:	5d                   	pop    %ebp
f0105dd9:	c3                   	ret    

f0105dda <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105dda:	55                   	push   %ebp
f0105ddb:	89 e5                	mov    %esp,%ebp
f0105ddd:	53                   	push   %ebx
f0105dde:	8b 45 08             	mov    0x8(%ebp),%eax
f0105de1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105de4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105de9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105ded:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105df0:	83 c2 01             	add    $0x1,%edx
f0105df3:	84 c9                	test   %cl,%cl
f0105df5:	75 f2                	jne    f0105de9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105df7:	5b                   	pop    %ebx
f0105df8:	5d                   	pop    %ebp
f0105df9:	c3                   	ret    

f0105dfa <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105dfa:	55                   	push   %ebp
f0105dfb:	89 e5                	mov    %esp,%ebp
f0105dfd:	53                   	push   %ebx
f0105dfe:	83 ec 08             	sub    $0x8,%esp
f0105e01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105e04:	89 1c 24             	mov    %ebx,(%esp)
f0105e07:	e8 84 ff ff ff       	call   f0105d90 <strlen>
	strcpy(dst + len, src);
f0105e0c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e0f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e13:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105e16:	89 04 24             	mov    %eax,(%esp)
f0105e19:	e8 bc ff ff ff       	call   f0105dda <strcpy>
	return dst;
}
f0105e1e:	89 d8                	mov    %ebx,%eax
f0105e20:	83 c4 08             	add    $0x8,%esp
f0105e23:	5b                   	pop    %ebx
f0105e24:	5d                   	pop    %ebp
f0105e25:	c3                   	ret    

f0105e26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105e26:	55                   	push   %ebp
f0105e27:	89 e5                	mov    %esp,%ebp
f0105e29:	56                   	push   %esi
f0105e2a:	53                   	push   %ebx
f0105e2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e2e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e34:	85 f6                	test   %esi,%esi
f0105e36:	74 18                	je     f0105e50 <strncpy+0x2a>
f0105e38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105e3d:	0f b6 1a             	movzbl (%edx),%ebx
f0105e40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105e43:	80 3a 01             	cmpb   $0x1,(%edx)
f0105e46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e49:	83 c1 01             	add    $0x1,%ecx
f0105e4c:	39 ce                	cmp    %ecx,%esi
f0105e4e:	77 ed                	ja     f0105e3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105e50:	5b                   	pop    %ebx
f0105e51:	5e                   	pop    %esi
f0105e52:	5d                   	pop    %ebp
f0105e53:	c3                   	ret    

f0105e54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105e54:	55                   	push   %ebp
f0105e55:	89 e5                	mov    %esp,%ebp
f0105e57:	56                   	push   %esi
f0105e58:	53                   	push   %ebx
f0105e59:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105e62:	89 f0                	mov    %esi,%eax
f0105e64:	85 c9                	test   %ecx,%ecx
f0105e66:	74 27                	je     f0105e8f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0105e68:	83 e9 01             	sub    $0x1,%ecx
f0105e6b:	74 1d                	je     f0105e8a <strlcpy+0x36>
f0105e6d:	0f b6 1a             	movzbl (%edx),%ebx
f0105e70:	84 db                	test   %bl,%bl
f0105e72:	74 16                	je     f0105e8a <strlcpy+0x36>
			*dst++ = *src++;
f0105e74:	88 18                	mov    %bl,(%eax)
f0105e76:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105e79:	83 e9 01             	sub    $0x1,%ecx
f0105e7c:	74 0e                	je     f0105e8c <strlcpy+0x38>
			*dst++ = *src++;
f0105e7e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105e81:	0f b6 1a             	movzbl (%edx),%ebx
f0105e84:	84 db                	test   %bl,%bl
f0105e86:	75 ec                	jne    f0105e74 <strlcpy+0x20>
f0105e88:	eb 02                	jmp    f0105e8c <strlcpy+0x38>
f0105e8a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105e8c:	c6 00 00             	movb   $0x0,(%eax)
f0105e8f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0105e91:	5b                   	pop    %ebx
f0105e92:	5e                   	pop    %esi
f0105e93:	5d                   	pop    %ebp
f0105e94:	c3                   	ret    

f0105e95 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105e95:	55                   	push   %ebp
f0105e96:	89 e5                	mov    %esp,%ebp
f0105e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105e9e:	0f b6 01             	movzbl (%ecx),%eax
f0105ea1:	84 c0                	test   %al,%al
f0105ea3:	74 15                	je     f0105eba <strcmp+0x25>
f0105ea5:	3a 02                	cmp    (%edx),%al
f0105ea7:	75 11                	jne    f0105eba <strcmp+0x25>
		p++, q++;
f0105ea9:	83 c1 01             	add    $0x1,%ecx
f0105eac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105eaf:	0f b6 01             	movzbl (%ecx),%eax
f0105eb2:	84 c0                	test   %al,%al
f0105eb4:	74 04                	je     f0105eba <strcmp+0x25>
f0105eb6:	3a 02                	cmp    (%edx),%al
f0105eb8:	74 ef                	je     f0105ea9 <strcmp+0x14>
f0105eba:	0f b6 c0             	movzbl %al,%eax
f0105ebd:	0f b6 12             	movzbl (%edx),%edx
f0105ec0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105ec2:	5d                   	pop    %ebp
f0105ec3:	c3                   	ret    

f0105ec4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105ec4:	55                   	push   %ebp
f0105ec5:	89 e5                	mov    %esp,%ebp
f0105ec7:	53                   	push   %ebx
f0105ec8:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ece:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105ed1:	85 c0                	test   %eax,%eax
f0105ed3:	74 23                	je     f0105ef8 <strncmp+0x34>
f0105ed5:	0f b6 1a             	movzbl (%edx),%ebx
f0105ed8:	84 db                	test   %bl,%bl
f0105eda:	74 25                	je     f0105f01 <strncmp+0x3d>
f0105edc:	3a 19                	cmp    (%ecx),%bl
f0105ede:	75 21                	jne    f0105f01 <strncmp+0x3d>
f0105ee0:	83 e8 01             	sub    $0x1,%eax
f0105ee3:	74 13                	je     f0105ef8 <strncmp+0x34>
		n--, p++, q++;
f0105ee5:	83 c2 01             	add    $0x1,%edx
f0105ee8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105eeb:	0f b6 1a             	movzbl (%edx),%ebx
f0105eee:	84 db                	test   %bl,%bl
f0105ef0:	74 0f                	je     f0105f01 <strncmp+0x3d>
f0105ef2:	3a 19                	cmp    (%ecx),%bl
f0105ef4:	74 ea                	je     f0105ee0 <strncmp+0x1c>
f0105ef6:	eb 09                	jmp    f0105f01 <strncmp+0x3d>
f0105ef8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105efd:	5b                   	pop    %ebx
f0105efe:	5d                   	pop    %ebp
f0105eff:	90                   	nop
f0105f00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f01:	0f b6 02             	movzbl (%edx),%eax
f0105f04:	0f b6 11             	movzbl (%ecx),%edx
f0105f07:	29 d0                	sub    %edx,%eax
f0105f09:	eb f2                	jmp    f0105efd <strncmp+0x39>

f0105f0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105f0b:	55                   	push   %ebp
f0105f0c:	89 e5                	mov    %esp,%ebp
f0105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f15:	0f b6 10             	movzbl (%eax),%edx
f0105f18:	84 d2                	test   %dl,%dl
f0105f1a:	74 18                	je     f0105f34 <strchr+0x29>
		if (*s == c)
f0105f1c:	38 ca                	cmp    %cl,%dl
f0105f1e:	75 0a                	jne    f0105f2a <strchr+0x1f>
f0105f20:	eb 17                	jmp    f0105f39 <strchr+0x2e>
f0105f22:	38 ca                	cmp    %cl,%dl
f0105f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105f28:	74 0f                	je     f0105f39 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105f2a:	83 c0 01             	add    $0x1,%eax
f0105f2d:	0f b6 10             	movzbl (%eax),%edx
f0105f30:	84 d2                	test   %dl,%dl
f0105f32:	75 ee                	jne    f0105f22 <strchr+0x17>
f0105f34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0105f39:	5d                   	pop    %ebp
f0105f3a:	c3                   	ret    

f0105f3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105f3b:	55                   	push   %ebp
f0105f3c:	89 e5                	mov    %esp,%ebp
f0105f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f45:	0f b6 10             	movzbl (%eax),%edx
f0105f48:	84 d2                	test   %dl,%dl
f0105f4a:	74 18                	je     f0105f64 <strfind+0x29>
		if (*s == c)
f0105f4c:	38 ca                	cmp    %cl,%dl
f0105f4e:	75 0a                	jne    f0105f5a <strfind+0x1f>
f0105f50:	eb 12                	jmp    f0105f64 <strfind+0x29>
f0105f52:	38 ca                	cmp    %cl,%dl
f0105f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105f58:	74 0a                	je     f0105f64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105f5a:	83 c0 01             	add    $0x1,%eax
f0105f5d:	0f b6 10             	movzbl (%eax),%edx
f0105f60:	84 d2                	test   %dl,%dl
f0105f62:	75 ee                	jne    f0105f52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0105f64:	5d                   	pop    %ebp
f0105f65:	c3                   	ret    

f0105f66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105f66:	55                   	push   %ebp
f0105f67:	89 e5                	mov    %esp,%ebp
f0105f69:	83 ec 0c             	sub    $0xc,%esp
f0105f6c:	89 1c 24             	mov    %ebx,(%esp)
f0105f6f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105f77:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105f80:	85 c9                	test   %ecx,%ecx
f0105f82:	74 30                	je     f0105fb4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105f84:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f8a:	75 25                	jne    f0105fb1 <memset+0x4b>
f0105f8c:	f6 c1 03             	test   $0x3,%cl
f0105f8f:	75 20                	jne    f0105fb1 <memset+0x4b>
		c &= 0xFF;
f0105f91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105f94:	89 d3                	mov    %edx,%ebx
f0105f96:	c1 e3 08             	shl    $0x8,%ebx
f0105f99:	89 d6                	mov    %edx,%esi
f0105f9b:	c1 e6 18             	shl    $0x18,%esi
f0105f9e:	89 d0                	mov    %edx,%eax
f0105fa0:	c1 e0 10             	shl    $0x10,%eax
f0105fa3:	09 f0                	or     %esi,%eax
f0105fa5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0105fa7:	09 d8                	or     %ebx,%eax
f0105fa9:	c1 e9 02             	shr    $0x2,%ecx
f0105fac:	fc                   	cld    
f0105fad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105faf:	eb 03                	jmp    f0105fb4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105fb1:	fc                   	cld    
f0105fb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105fb4:	89 f8                	mov    %edi,%eax
f0105fb6:	8b 1c 24             	mov    (%esp),%ebx
f0105fb9:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105fbd:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105fc1:	89 ec                	mov    %ebp,%esp
f0105fc3:	5d                   	pop    %ebp
f0105fc4:	c3                   	ret    

f0105fc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105fc5:	55                   	push   %ebp
f0105fc6:	89 e5                	mov    %esp,%ebp
f0105fc8:	83 ec 08             	sub    $0x8,%esp
f0105fcb:	89 34 24             	mov    %esi,(%esp)
f0105fce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0105fd8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0105fdb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0105fdd:	39 c6                	cmp    %eax,%esi
f0105fdf:	73 35                	jae    f0106016 <memmove+0x51>
f0105fe1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105fe4:	39 d0                	cmp    %edx,%eax
f0105fe6:	73 2e                	jae    f0106016 <memmove+0x51>
		s += n;
		d += n;
f0105fe8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105fea:	f6 c2 03             	test   $0x3,%dl
f0105fed:	75 1b                	jne    f010600a <memmove+0x45>
f0105fef:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105ff5:	75 13                	jne    f010600a <memmove+0x45>
f0105ff7:	f6 c1 03             	test   $0x3,%cl
f0105ffa:	75 0e                	jne    f010600a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0105ffc:	83 ef 04             	sub    $0x4,%edi
f0105fff:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106002:	c1 e9 02             	shr    $0x2,%ecx
f0106005:	fd                   	std    
f0106006:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106008:	eb 09                	jmp    f0106013 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010600a:	83 ef 01             	sub    $0x1,%edi
f010600d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0106010:	fd                   	std    
f0106011:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106013:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106014:	eb 20                	jmp    f0106036 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106016:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010601c:	75 15                	jne    f0106033 <memmove+0x6e>
f010601e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106024:	75 0d                	jne    f0106033 <memmove+0x6e>
f0106026:	f6 c1 03             	test   $0x3,%cl
f0106029:	75 08                	jne    f0106033 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f010602b:	c1 e9 02             	shr    $0x2,%ecx
f010602e:	fc                   	cld    
f010602f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106031:	eb 03                	jmp    f0106036 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106033:	fc                   	cld    
f0106034:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106036:	8b 34 24             	mov    (%esp),%esi
f0106039:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010603d:	89 ec                	mov    %ebp,%esp
f010603f:	5d                   	pop    %ebp
f0106040:	c3                   	ret    

f0106041 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0106041:	55                   	push   %ebp
f0106042:	89 e5                	mov    %esp,%ebp
f0106044:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106047:	8b 45 10             	mov    0x10(%ebp),%eax
f010604a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010604e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106051:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106055:	8b 45 08             	mov    0x8(%ebp),%eax
f0106058:	89 04 24             	mov    %eax,(%esp)
f010605b:	e8 65 ff ff ff       	call   f0105fc5 <memmove>
}
f0106060:	c9                   	leave  
f0106061:	c3                   	ret    

f0106062 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106062:	55                   	push   %ebp
f0106063:	89 e5                	mov    %esp,%ebp
f0106065:	57                   	push   %edi
f0106066:	56                   	push   %esi
f0106067:	53                   	push   %ebx
f0106068:	8b 75 08             	mov    0x8(%ebp),%esi
f010606b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010606e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106071:	85 c9                	test   %ecx,%ecx
f0106073:	74 36                	je     f01060ab <memcmp+0x49>
		if (*s1 != *s2)
f0106075:	0f b6 06             	movzbl (%esi),%eax
f0106078:	0f b6 1f             	movzbl (%edi),%ebx
f010607b:	38 d8                	cmp    %bl,%al
f010607d:	74 20                	je     f010609f <memcmp+0x3d>
f010607f:	eb 14                	jmp    f0106095 <memcmp+0x33>
f0106081:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0106086:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010608b:	83 c2 01             	add    $0x1,%edx
f010608e:	83 e9 01             	sub    $0x1,%ecx
f0106091:	38 d8                	cmp    %bl,%al
f0106093:	74 12                	je     f01060a7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0106095:	0f b6 c0             	movzbl %al,%eax
f0106098:	0f b6 db             	movzbl %bl,%ebx
f010609b:	29 d8                	sub    %ebx,%eax
f010609d:	eb 11                	jmp    f01060b0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010609f:	83 e9 01             	sub    $0x1,%ecx
f01060a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01060a7:	85 c9                	test   %ecx,%ecx
f01060a9:	75 d6                	jne    f0106081 <memcmp+0x1f>
f01060ab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f01060b0:	5b                   	pop    %ebx
f01060b1:	5e                   	pop    %esi
f01060b2:	5f                   	pop    %edi
f01060b3:	5d                   	pop    %ebp
f01060b4:	c3                   	ret    

f01060b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01060b5:	55                   	push   %ebp
f01060b6:	89 e5                	mov    %esp,%ebp
f01060b8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01060bb:	89 c2                	mov    %eax,%edx
f01060bd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01060c0:	39 d0                	cmp    %edx,%eax
f01060c2:	73 15                	jae    f01060d9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01060c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01060c8:	38 08                	cmp    %cl,(%eax)
f01060ca:	75 06                	jne    f01060d2 <memfind+0x1d>
f01060cc:	eb 0b                	jmp    f01060d9 <memfind+0x24>
f01060ce:	38 08                	cmp    %cl,(%eax)
f01060d0:	74 07                	je     f01060d9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01060d2:	83 c0 01             	add    $0x1,%eax
f01060d5:	39 c2                	cmp    %eax,%edx
f01060d7:	77 f5                	ja     f01060ce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01060d9:	5d                   	pop    %ebp
f01060da:	c3                   	ret    

f01060db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01060db:	55                   	push   %ebp
f01060dc:	89 e5                	mov    %esp,%ebp
f01060de:	57                   	push   %edi
f01060df:	56                   	push   %esi
f01060e0:	53                   	push   %ebx
f01060e1:	83 ec 04             	sub    $0x4,%esp
f01060e4:	8b 55 08             	mov    0x8(%ebp),%edx
f01060e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060ea:	0f b6 02             	movzbl (%edx),%eax
f01060ed:	3c 20                	cmp    $0x20,%al
f01060ef:	74 04                	je     f01060f5 <strtol+0x1a>
f01060f1:	3c 09                	cmp    $0x9,%al
f01060f3:	75 0e                	jne    f0106103 <strtol+0x28>
		s++;
f01060f5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060f8:	0f b6 02             	movzbl (%edx),%eax
f01060fb:	3c 20                	cmp    $0x20,%al
f01060fd:	74 f6                	je     f01060f5 <strtol+0x1a>
f01060ff:	3c 09                	cmp    $0x9,%al
f0106101:	74 f2                	je     f01060f5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106103:	3c 2b                	cmp    $0x2b,%al
f0106105:	75 0c                	jne    f0106113 <strtol+0x38>
		s++;
f0106107:	83 c2 01             	add    $0x1,%edx
f010610a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0106111:	eb 15                	jmp    f0106128 <strtol+0x4d>
	else if (*s == '-')
f0106113:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010611a:	3c 2d                	cmp    $0x2d,%al
f010611c:	75 0a                	jne    f0106128 <strtol+0x4d>
		s++, neg = 1;
f010611e:	83 c2 01             	add    $0x1,%edx
f0106121:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106128:	85 db                	test   %ebx,%ebx
f010612a:	0f 94 c0             	sete   %al
f010612d:	74 05                	je     f0106134 <strtol+0x59>
f010612f:	83 fb 10             	cmp    $0x10,%ebx
f0106132:	75 18                	jne    f010614c <strtol+0x71>
f0106134:	80 3a 30             	cmpb   $0x30,(%edx)
f0106137:	75 13                	jne    f010614c <strtol+0x71>
f0106139:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010613d:	8d 76 00             	lea    0x0(%esi),%esi
f0106140:	75 0a                	jne    f010614c <strtol+0x71>
		s += 2, base = 16;
f0106142:	83 c2 02             	add    $0x2,%edx
f0106145:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010614a:	eb 15                	jmp    f0106161 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010614c:	84 c0                	test   %al,%al
f010614e:	66 90                	xchg   %ax,%ax
f0106150:	74 0f                	je     f0106161 <strtol+0x86>
f0106152:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106157:	80 3a 30             	cmpb   $0x30,(%edx)
f010615a:	75 05                	jne    f0106161 <strtol+0x86>
		s++, base = 8;
f010615c:	83 c2 01             	add    $0x1,%edx
f010615f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106161:	b8 00 00 00 00       	mov    $0x0,%eax
f0106166:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106168:	0f b6 0a             	movzbl (%edx),%ecx
f010616b:	89 cf                	mov    %ecx,%edi
f010616d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106170:	80 fb 09             	cmp    $0x9,%bl
f0106173:	77 08                	ja     f010617d <strtol+0xa2>
			dig = *s - '0';
f0106175:	0f be c9             	movsbl %cl,%ecx
f0106178:	83 e9 30             	sub    $0x30,%ecx
f010617b:	eb 1e                	jmp    f010619b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010617d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0106180:	80 fb 19             	cmp    $0x19,%bl
f0106183:	77 08                	ja     f010618d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0106185:	0f be c9             	movsbl %cl,%ecx
f0106188:	83 e9 57             	sub    $0x57,%ecx
f010618b:	eb 0e                	jmp    f010619b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010618d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0106190:	80 fb 19             	cmp    $0x19,%bl
f0106193:	77 15                	ja     f01061aa <strtol+0xcf>
			dig = *s - 'A' + 10;
f0106195:	0f be c9             	movsbl %cl,%ecx
f0106198:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010619b:	39 f1                	cmp    %esi,%ecx
f010619d:	7d 0b                	jge    f01061aa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010619f:	83 c2 01             	add    $0x1,%edx
f01061a2:	0f af c6             	imul   %esi,%eax
f01061a5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01061a8:	eb be                	jmp    f0106168 <strtol+0x8d>
f01061aa:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01061ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01061b0:	74 05                	je     f01061b7 <strtol+0xdc>
		*endptr = (char *) s;
f01061b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01061b5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01061b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01061bb:	74 04                	je     f01061c1 <strtol+0xe6>
f01061bd:	89 c8                	mov    %ecx,%eax
f01061bf:	f7 d8                	neg    %eax
}
f01061c1:	83 c4 04             	add    $0x4,%esp
f01061c4:	5b                   	pop    %ebx
f01061c5:	5e                   	pop    %esi
f01061c6:	5f                   	pop    %edi
f01061c7:	5d                   	pop    %ebp
f01061c8:	c3                   	ret    
f01061c9:	00 00                	add    %al,(%eax)
	...

f01061cc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01061cc:	fa                   	cli    

	xorw    %ax, %ax
f01061cd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01061cf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061d1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061d3:	8e d0                	mov    %eax,%ss
#stone
	lgdt    MPBOOTPHYS(gdtdesc)
f01061d5:	0f 01 16             	lgdtl  (%esi)
f01061d8:	74 70                	je     f010624a <mpentry_end+0x4>
	movl    %cr0, %eax
f01061da:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01061dd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01061e1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01061e4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01061ea:	08 00                	or     %al,(%eax)

f01061ec <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01061ec:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01061f0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061f2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061f4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01061f6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01061fa:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01061fc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01061fe:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0106203:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106206:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106209:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010620e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0106211:	8b 25 04 5f 23 f0    	mov    0xf0235f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106217:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010621c:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f0106221:	ff d0                	call   *%eax

f0106223 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106223:	eb fe                	jmp    f0106223 <spin>
f0106225:	8d 76 00             	lea    0x0(%esi),%esi

f0106228 <gdt>:
	...
f0106230:	ff                   	(bad)  
f0106231:	ff 00                	incl   (%eax)
f0106233:	00 00                	add    %al,(%eax)
f0106235:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010623c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106240 <gdtdesc>:
f0106240:	17                   	pop    %ss
f0106241:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106246 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106246:	90                   	nop
	...

f0106250 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106250:	55                   	push   %ebp
f0106251:	89 e5                	mov    %esp,%ebp
f0106253:	56                   	push   %esi
f0106254:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106255:	bb 00 00 00 00       	mov    $0x0,%ebx
f010625a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010625f:	85 d2                	test   %edx,%edx
f0106261:	7e 0d                	jle    f0106270 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0106263:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106267:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106269:	83 c1 01             	add    $0x1,%ecx
f010626c:	39 d1                	cmp    %edx,%ecx
f010626e:	75 f3                	jne    f0106263 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106270:	89 d8                	mov    %ebx,%eax
f0106272:	5b                   	pop    %ebx
f0106273:	5e                   	pop    %esi
f0106274:	5d                   	pop    %ebp
f0106275:	c3                   	ret    

f0106276 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106276:	55                   	push   %ebp
f0106277:	89 e5                	mov    %esp,%ebp
f0106279:	56                   	push   %esi
f010627a:	53                   	push   %ebx
f010627b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010627e:	8b 0d 08 5f 23 f0    	mov    0xf0235f08,%ecx
f0106284:	89 c3                	mov    %eax,%ebx
f0106286:	c1 eb 0c             	shr    $0xc,%ebx
f0106289:	39 cb                	cmp    %ecx,%ebx
f010628b:	72 20                	jb     f01062ad <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010628d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106291:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0106298:	f0 
f0106299:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01062a0:	00 
f01062a1:	c7 04 24 41 88 10 f0 	movl   $0xf0108841,(%esp)
f01062a8:	e8 d8 9d ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01062ad:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062b0:	89 f2                	mov    %esi,%edx
f01062b2:	c1 ea 0c             	shr    $0xc,%edx
f01062b5:	39 d1                	cmp    %edx,%ecx
f01062b7:	77 20                	ja     f01062d9 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062b9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01062bd:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01062c4:	f0 
f01062c5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01062cc:	00 
f01062cd:	c7 04 24 41 88 10 f0 	movl   $0xf0108841,(%esp)
f01062d4:	e8 ac 9d ff ff       	call   f0100085 <_panic>
f01062d9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01062df:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01062e5:	39 f3                	cmp    %esi,%ebx
f01062e7:	73 33                	jae    f010631c <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062e9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01062f0:	00 
f01062f1:	c7 44 24 04 51 88 10 	movl   $0xf0108851,0x4(%esp)
f01062f8:	f0 
f01062f9:	89 1c 24             	mov    %ebx,(%esp)
f01062fc:	e8 61 fd ff ff       	call   f0106062 <memcmp>
f0106301:	85 c0                	test   %eax,%eax
f0106303:	75 10                	jne    f0106315 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106305:	ba 10 00 00 00       	mov    $0x10,%edx
f010630a:	89 d8                	mov    %ebx,%eax
f010630c:	e8 3f ff ff ff       	call   f0106250 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106311:	84 c0                	test   %al,%al
f0106313:	74 0c                	je     f0106321 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106315:	83 c3 10             	add    $0x10,%ebx
f0106318:	39 de                	cmp    %ebx,%esi
f010631a:	77 cd                	ja     f01062e9 <mpsearch1+0x73>
f010631c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0106321:	89 d8                	mov    %ebx,%eax
f0106323:	83 c4 10             	add    $0x10,%esp
f0106326:	5b                   	pop    %ebx
f0106327:	5e                   	pop    %esi
f0106328:	5d                   	pop    %ebp
f0106329:	c3                   	ret    

f010632a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010632a:	55                   	push   %ebp
f010632b:	89 e5                	mov    %esp,%ebp
f010632d:	57                   	push   %edi
f010632e:	56                   	push   %esi
f010632f:	53                   	push   %ebx
f0106330:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106333:	c7 05 c0 63 23 f0 20 	movl   $0xf0236020,0xf02363c0
f010633a:	60 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010633d:	83 3d 08 5f 23 f0 00 	cmpl   $0x0,0xf0235f08
f0106344:	75 24                	jne    f010636a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106346:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010634d:	00 
f010634e:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f0106355:	f0 
f0106356:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010635d:	00 
f010635e:	c7 04 24 41 88 10 f0 	movl   $0xf0108841,(%esp)
f0106365:	e8 1b 9d ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010636a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106371:	85 c0                	test   %eax,%eax
f0106373:	74 16                	je     f010638b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106375:	c1 e0 04             	shl    $0x4,%eax
f0106378:	ba 00 04 00 00       	mov    $0x400,%edx
f010637d:	e8 f4 fe ff ff       	call   f0106276 <mpsearch1>
f0106382:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106385:	85 c0                	test   %eax,%eax
f0106387:	75 3c                	jne    f01063c5 <mp_init+0x9b>
f0106389:	eb 20                	jmp    f01063ab <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010638b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106392:	c1 e0 0a             	shl    $0xa,%eax
f0106395:	2d 00 04 00 00       	sub    $0x400,%eax
f010639a:	ba 00 04 00 00       	mov    $0x400,%edx
f010639f:	e8 d2 fe ff ff       	call   f0106276 <mpsearch1>
f01063a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01063a7:	85 c0                	test   %eax,%eax
f01063a9:	75 1a                	jne    f01063c5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01063ab:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063b0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01063b5:	e8 bc fe ff ff       	call   f0106276 <mpsearch1>
f01063ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01063bd:	85 c0                	test   %eax,%eax
f01063bf:	0f 84 27 02 00 00    	je     f01065ec <mp_init+0x2c2>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01063c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063c8:	8b 78 04             	mov    0x4(%eax),%edi
f01063cb:	85 ff                	test   %edi,%edi
f01063cd:	74 06                	je     f01063d5 <mp_init+0xab>
f01063cf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01063d3:	74 11                	je     f01063e6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01063d5:	c7 04 24 b4 86 10 f0 	movl   $0xf01086b4,(%esp)
f01063dc:	e8 0a e2 ff ff       	call   f01045eb <cprintf>
f01063e1:	e9 06 02 00 00       	jmp    f01065ec <mp_init+0x2c2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063e6:	89 f8                	mov    %edi,%eax
f01063e8:	c1 e8 0c             	shr    $0xc,%eax
f01063eb:	3b 05 08 5f 23 f0    	cmp    0xf0235f08,%eax
f01063f1:	72 20                	jb     f0106413 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063f3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01063f7:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01063fe:	f0 
f01063ff:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106406:	00 
f0106407:	c7 04 24 41 88 10 f0 	movl   $0xf0108841,(%esp)
f010640e:	e8 72 9c ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0106413:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106419:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106420:	00 
f0106421:	c7 44 24 04 56 88 10 	movl   $0xf0108856,0x4(%esp)
f0106428:	f0 
f0106429:	89 3c 24             	mov    %edi,(%esp)
f010642c:	e8 31 fc ff ff       	call   f0106062 <memcmp>
f0106431:	85 c0                	test   %eax,%eax
f0106433:	74 11                	je     f0106446 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106435:	c7 04 24 e4 86 10 f0 	movl   $0xf01086e4,(%esp)
f010643c:	e8 aa e1 ff ff       	call   f01045eb <cprintf>
f0106441:	e9 a6 01 00 00       	jmp    f01065ec <mp_init+0x2c2>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106446:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f010644a:	89 f8                	mov    %edi,%eax
f010644c:	e8 ff fd ff ff       	call   f0106250 <sum>
f0106451:	84 c0                	test   %al,%al
f0106453:	74 11                	je     f0106466 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106455:	c7 04 24 18 87 10 f0 	movl   $0xf0108718,(%esp)
f010645c:	e8 8a e1 ff ff       	call   f01045eb <cprintf>
f0106461:	e9 86 01 00 00       	jmp    f01065ec <mp_init+0x2c2>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106466:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f010646a:	3c 01                	cmp    $0x1,%al
f010646c:	74 1c                	je     f010648a <mp_init+0x160>
f010646e:	3c 04                	cmp    $0x4,%al
f0106470:	74 18                	je     f010648a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106472:	0f b6 c0             	movzbl %al,%eax
f0106475:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106479:	c7 04 24 3c 87 10 f0 	movl   $0xf010873c,(%esp)
f0106480:	e8 66 e1 ff ff       	call   f01045eb <cprintf>
f0106485:	e9 62 01 00 00       	jmp    f01065ec <mp_init+0x2c2>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f010648a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010648e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0106492:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0106495:	e8 b6 fd ff ff       	call   f0106250 <sum>
f010649a:	3a 47 2a             	cmp    0x2a(%edi),%al
f010649d:	74 11                	je     f01064b0 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010649f:	c7 04 24 5c 87 10 f0 	movl   $0xf010875c,(%esp)
f01064a6:	e8 40 e1 ff ff       	call   f01045eb <cprintf>
f01064ab:	e9 3c 01 00 00       	jmp    f01065ec <mp_init+0x2c2>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01064b0:	85 ff                	test   %edi,%edi
f01064b2:	0f 84 34 01 00 00    	je     f01065ec <mp_init+0x2c2>
		return;
	ismp = 1;
f01064b8:	c7 05 00 60 23 f0 01 	movl   $0x1,0xf0236000
f01064bf:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f01064c2:	8b 47 24             	mov    0x24(%edi),%eax
f01064c5:	a3 00 70 27 f0       	mov    %eax,0xf0277000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01064ca:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f01064cf:	0f 84 98 00 00 00    	je     f010656d <mp_init+0x243>
f01064d5:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f01064d8:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f01064dd:	0f b6 03             	movzbl (%ebx),%eax
f01064e0:	84 c0                	test   %al,%al
f01064e2:	74 06                	je     f01064ea <mp_init+0x1c0>
f01064e4:	3c 04                	cmp    $0x4,%al
f01064e6:	77 55                	ja     f010653d <mp_init+0x213>
f01064e8:	eb 4e                	jmp    f0106538 <mp_init+0x20e>
		case MPPROC:
			proc = (struct mpproc *)p;
f01064ea:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f01064ec:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01064f0:	74 11                	je     f0106503 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f01064f2:	6b 05 c4 63 23 f0 74 	imul   $0x74,0xf02363c4,%eax
f01064f9:	05 20 60 23 f0       	add    $0xf0236020,%eax
f01064fe:	a3 c0 63 23 f0       	mov    %eax,0xf02363c0
			if (ncpu < NCPU) {
f0106503:	a1 c4 63 23 f0       	mov    0xf02363c4,%eax
f0106508:	83 f8 07             	cmp    $0x7,%eax
f010650b:	7f 12                	jg     f010651f <mp_init+0x1f5>
				cpus[ncpu].cpu_id = ncpu;
f010650d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106510:	88 82 20 60 23 f0    	mov    %al,-0xfdc9fe0(%edx)
				ncpu++;
f0106516:	83 05 c4 63 23 f0 01 	addl   $0x1,0xf02363c4
f010651d:	eb 14                	jmp    f0106533 <mp_init+0x209>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010651f:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0106523:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106527:	c7 04 24 8c 87 10 f0 	movl   $0xf010878c,(%esp)
f010652e:	e8 b8 e0 ff ff       	call   f01045eb <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106533:	83 c3 14             	add    $0x14,%ebx
			continue;
f0106536:	eb 26                	jmp    f010655e <mp_init+0x234>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106538:	83 c3 08             	add    $0x8,%ebx
			continue;
f010653b:	eb 21                	jmp    f010655e <mp_init+0x234>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010653d:	0f b6 c0             	movzbl %al,%eax
f0106540:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106544:	c7 04 24 b4 87 10 f0 	movl   $0xf01087b4,(%esp)
f010654b:	e8 9b e0 ff ff       	call   f01045eb <cprintf>
			ismp = 0;
f0106550:	c7 05 00 60 23 f0 00 	movl   $0x0,0xf0236000
f0106557:	00 00 00 
			i = conf->entry;
f010655a:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010655e:	83 c6 01             	add    $0x1,%esi
f0106561:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106565:	39 f0                	cmp    %esi,%eax
f0106567:	0f 87 70 ff ff ff    	ja     f01064dd <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010656d:	a1 c0 63 23 f0       	mov    0xf02363c0,%eax
f0106572:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106579:	83 3d 00 60 23 f0 00 	cmpl   $0x0,0xf0236000
f0106580:	75 22                	jne    f01065a4 <mp_init+0x27a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106582:	c7 05 c4 63 23 f0 01 	movl   $0x1,0xf02363c4
f0106589:	00 00 00 
		lapic = NULL;
f010658c:	c7 05 00 70 27 f0 00 	movl   $0x0,0xf0277000
f0106593:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106596:	c7 04 24 d4 87 10 f0 	movl   $0xf01087d4,(%esp)
f010659d:	e8 49 e0 ff ff       	call   f01045eb <cprintf>
		return;
f01065a2:	eb 48                	jmp    f01065ec <mp_init+0x2c2>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01065a4:	a1 c4 63 23 f0       	mov    0xf02363c4,%eax
f01065a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01065ad:	a1 c0 63 23 f0       	mov    0xf02363c0,%eax
f01065b2:	0f b6 00             	movzbl (%eax),%eax
f01065b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065b9:	c7 04 24 5b 88 10 f0 	movl   $0xf010885b,(%esp)
f01065c0:	e8 26 e0 ff ff       	call   f01045eb <cprintf>

	if (mp->imcrp) {
f01065c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01065c8:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01065cc:	74 1e                	je     f01065ec <mp_init+0x2c2>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01065ce:	c7 04 24 00 88 10 f0 	movl   $0xf0108800,(%esp)
f01065d5:	e8 11 e0 ff ff       	call   f01045eb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065da:	ba 22 00 00 00       	mov    $0x22,%edx
f01065df:	b8 70 00 00 00       	mov    $0x70,%eax
f01065e4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01065e5:	b2 23                	mov    $0x23,%dl
f01065e7:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065e8:	83 c8 01             	or     $0x1,%eax
f01065eb:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01065ec:	83 c4 2c             	add    $0x2c,%esp
f01065ef:	5b                   	pop    %ebx
f01065f0:	5e                   	pop    %esi
f01065f1:	5f                   	pop    %edi
f01065f2:	5d                   	pop    %ebp
f01065f3:	c3                   	ret    

f01065f4 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f01065f4:	55                   	push   %ebp
f01065f5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01065f7:	c1 e0 02             	shl    $0x2,%eax
f01065fa:	03 05 00 70 27 f0    	add    0xf0277000,%eax
f0106600:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106602:	a1 00 70 27 f0       	mov    0xf0277000,%eax
f0106607:	83 c0 20             	add    $0x20,%eax
f010660a:	8b 00                	mov    (%eax),%eax
}
f010660c:	5d                   	pop    %ebp
f010660d:	c3                   	ret    

f010660e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010660e:	55                   	push   %ebp
f010660f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106611:	8b 15 00 70 27 f0    	mov    0xf0277000,%edx
f0106617:	b8 00 00 00 00       	mov    $0x0,%eax
f010661c:	85 d2                	test   %edx,%edx
f010661e:	74 08                	je     f0106628 <cpunum+0x1a>
		return lapic[ID] >> 24;
f0106620:	83 c2 20             	add    $0x20,%edx
f0106623:	8b 02                	mov    (%edx),%eax
f0106625:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106628:	5d                   	pop    %ebp
f0106629:	c3                   	ret    

f010662a <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010662a:	55                   	push   %ebp
f010662b:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f010662d:	83 3d 00 70 27 f0 00 	cmpl   $0x0,0xf0277000
f0106634:	0f 84 0b 01 00 00    	je     f0106745 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010663a:	ba 27 01 00 00       	mov    $0x127,%edx
f010663f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106644:	e8 ab ff ff ff       	call   f01065f4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106649:	ba 0b 00 00 00       	mov    $0xb,%edx
f010664e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106653:	e8 9c ff ff ff       	call   f01065f4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106658:	ba 20 00 02 00       	mov    $0x20020,%edx
f010665d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106662:	e8 8d ff ff ff       	call   f01065f4 <lapicw>
	lapicw(TICR, 10000000); 
f0106667:	ba 80 96 98 00       	mov    $0x989680,%edx
f010666c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106671:	e8 7e ff ff ff       	call   f01065f4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106676:	e8 93 ff ff ff       	call   f010660e <cpunum>
f010667b:	6b c0 74             	imul   $0x74,%eax,%eax
f010667e:	05 20 60 23 f0       	add    $0xf0236020,%eax
f0106683:	39 05 c0 63 23 f0    	cmp    %eax,0xf02363c0
f0106689:	74 0f                	je     f010669a <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010668b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106690:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106695:	e8 5a ff ff ff       	call   f01065f4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010669a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010669f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01066a4:	e8 4b ff ff ff       	call   f01065f4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01066a9:	a1 00 70 27 f0       	mov    0xf0277000,%eax
f01066ae:	83 c0 30             	add    $0x30,%eax
f01066b1:	8b 00                	mov    (%eax),%eax
f01066b3:	c1 e8 10             	shr    $0x10,%eax
f01066b6:	3c 03                	cmp    $0x3,%al
f01066b8:	76 0f                	jbe    f01066c9 <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f01066ba:	ba 00 00 01 00       	mov    $0x10000,%edx
f01066bf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01066c4:	e8 2b ff ff ff       	call   f01065f4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01066c9:	ba 33 00 00 00       	mov    $0x33,%edx
f01066ce:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01066d3:	e8 1c ff ff ff       	call   f01065f4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01066d8:	ba 00 00 00 00       	mov    $0x0,%edx
f01066dd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066e2:	e8 0d ff ff ff       	call   f01065f4 <lapicw>
	lapicw(ESR, 0);
f01066e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01066ec:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066f1:	e8 fe fe ff ff       	call   f01065f4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01066f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01066fb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106700:	e8 ef fe ff ff       	call   f01065f4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106705:	ba 00 00 00 00       	mov    $0x0,%edx
f010670a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010670f:	e8 e0 fe ff ff       	call   f01065f4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106714:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106719:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010671e:	e8 d1 fe ff ff       	call   f01065f4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106723:	8b 15 00 70 27 f0    	mov    0xf0277000,%edx
f0106729:	81 c2 00 03 00 00    	add    $0x300,%edx
f010672f:	8b 02                	mov    (%edx),%eax
f0106731:	f6 c4 10             	test   $0x10,%ah
f0106734:	75 f9                	jne    f010672f <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106736:	ba 00 00 00 00       	mov    $0x0,%edx
f010673b:	b8 20 00 00 00       	mov    $0x20,%eax
f0106740:	e8 af fe ff ff       	call   f01065f4 <lapicw>
}
f0106745:	5d                   	pop    %ebp
f0106746:	c3                   	ret    

f0106747 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106747:	55                   	push   %ebp
f0106748:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010674a:	83 3d 00 70 27 f0 00 	cmpl   $0x0,0xf0277000
f0106751:	74 0f                	je     f0106762 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0106753:	ba 00 00 00 00       	mov    $0x0,%edx
f0106758:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010675d:	e8 92 fe ff ff       	call   f01065f4 <lapicw>
}
f0106762:	5d                   	pop    %ebp
f0106763:	c3                   	ret    

f0106764 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0106764:	55                   	push   %ebp
f0106765:	89 e5                	mov    %esp,%ebp
}
f0106767:	5d                   	pop    %ebp
f0106768:	c3                   	ret    

f0106769 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0106769:	55                   	push   %ebp
f010676a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010676c:	8b 55 08             	mov    0x8(%ebp),%edx
f010676f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106775:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010677a:	e8 75 fe ff ff       	call   f01065f4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010677f:	8b 15 00 70 27 f0    	mov    0xf0277000,%edx
f0106785:	81 c2 00 03 00 00    	add    $0x300,%edx
f010678b:	8b 02                	mov    (%edx),%eax
f010678d:	f6 c4 10             	test   $0x10,%ah
f0106790:	75 f9                	jne    f010678b <lapic_ipi+0x22>
		;
}
f0106792:	5d                   	pop    %ebp
f0106793:	c3                   	ret    

f0106794 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106794:	55                   	push   %ebp
f0106795:	89 e5                	mov    %esp,%ebp
f0106797:	56                   	push   %esi
f0106798:	53                   	push   %ebx
f0106799:	83 ec 10             	sub    $0x10,%esp
f010679c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010679f:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f01067a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01067a8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01067ad:	ee                   	out    %al,(%dx)
f01067ae:	b2 71                	mov    $0x71,%dl
f01067b0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01067b5:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067b6:	83 3d 08 5f 23 f0 00 	cmpl   $0x0,0xf0235f08
f01067bd:	75 24                	jne    f01067e3 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067bf:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01067c6:	00 
f01067c7:	c7 44 24 08 c0 6d 10 	movl   $0xf0106dc0,0x8(%esp)
f01067ce:	f0 
f01067cf:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01067d6:	00 
f01067d7:	c7 04 24 78 88 10 f0 	movl   $0xf0108878,(%esp)
f01067de:	e8 a2 98 ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01067e3:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01067ea:	00 00 
	wrv[1] = addr >> 4;
f01067ec:	89 f0                	mov    %esi,%eax
f01067ee:	c1 e8 04             	shr    $0x4,%eax
f01067f1:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01067f7:	c1 e3 18             	shl    $0x18,%ebx
f01067fa:	89 da                	mov    %ebx,%edx
f01067fc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106801:	e8 ee fd ff ff       	call   f01065f4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106806:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010680b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106810:	e8 df fd ff ff       	call   f01065f4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106815:	ba 00 85 00 00       	mov    $0x8500,%edx
f010681a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010681f:	e8 d0 fd ff ff       	call   f01065f4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106824:	c1 ee 0c             	shr    $0xc,%esi
f0106827:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010682d:	89 da                	mov    %ebx,%edx
f010682f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106834:	e8 bb fd ff ff       	call   f01065f4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106839:	89 f2                	mov    %esi,%edx
f010683b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106840:	e8 af fd ff ff       	call   f01065f4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106845:	89 da                	mov    %ebx,%edx
f0106847:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010684c:	e8 a3 fd ff ff       	call   f01065f4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106851:	89 f2                	mov    %esi,%edx
f0106853:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106858:	e8 97 fd ff ff       	call   f01065f4 <lapicw>
		microdelay(200);
	}
}
f010685d:	83 c4 10             	add    $0x10,%esp
f0106860:	5b                   	pop    %ebx
f0106861:	5e                   	pop    %esi
f0106862:	5d                   	pop    %ebp
f0106863:	c3                   	ret    
	...

f0106870 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106870:	55                   	push   %ebp
f0106871:	89 e5                	mov    %esp,%ebp
f0106873:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
f0106876:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//LAB 4: Your code here

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010687c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010687f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106882:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106889:	5d                   	pop    %ebp
f010688a:	c3                   	ret    

f010688b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010688b:	55                   	push   %ebp
f010688c:	89 e5                	mov    %esp,%ebp
f010688e:	53                   	push   %ebx
f010688f:	83 ec 04             	sub    $0x4,%esp
f0106892:	89 c2                	mov    %eax,%edx
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
f0106894:	b8 00 00 00 00       	mov    $0x0,%eax
f0106899:	83 3a 00             	cmpl   $0x0,(%edx)
f010689c:	74 18                	je     f01068b6 <holding+0x2b>
f010689e:	8b 5a 08             	mov    0x8(%edx),%ebx
f01068a1:	e8 68 fd ff ff       	call   f010660e <cpunum>
f01068a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01068a9:	05 20 60 23 f0       	add    $0xf0236020,%eax
f01068ae:	39 c3                	cmp    %eax,%ebx
f01068b0:	0f 94 c0             	sete   %al
f01068b3:	0f b6 c0             	movzbl %al,%eax
#else
	//LAB 4: Your code here
	panic("ticket spinlock: not implemented yet");

#endif
}
f01068b6:	83 c4 04             	add    $0x4,%esp
f01068b9:	5b                   	pop    %ebx
f01068ba:	5d                   	pop    %ebp
f01068bb:	c3                   	ret    

f01068bc <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01068bc:	55                   	push   %ebp
f01068bd:	89 e5                	mov    %esp,%ebp
f01068bf:	83 ec 78             	sub    $0x78,%esp
f01068c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01068c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01068c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01068cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01068ce:	89 d8                	mov    %ebx,%eax
f01068d0:	e8 b6 ff ff ff       	call   f010688b <holding>
f01068d5:	85 c0                	test   %eax,%eax
f01068d7:	0f 85 d5 00 00 00    	jne    f01069b2 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01068dd:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01068e4:	00 
f01068e5:	8d 43 0c             	lea    0xc(%ebx),%eax
f01068e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068ec:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01068ef:	89 04 24             	mov    %eax,(%esp)
f01068f2:	e8 ce f6 ff ff       	call   f0105fc5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01068f7:	8b 43 08             	mov    0x8(%ebx),%eax
f01068fa:	0f b6 30             	movzbl (%eax),%esi
f01068fd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106900:	e8 09 fd ff ff       	call   f010660e <cpunum>
f0106905:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106909:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010690d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106911:	c7 04 24 88 88 10 f0 	movl   $0xf0108888,(%esp)
f0106918:	e8 ce dc ff ff       	call   f01045eb <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010691d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106920:	85 c0                	test   %eax,%eax
f0106922:	74 72                	je     f0106996 <spin_unlock+0xda>
f0106924:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106927:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010692a:	8d 75 d0             	lea    -0x30(%ebp),%esi
f010692d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106931:	89 04 24             	mov    %eax,(%esp)
f0106934:	e8 75 ea ff ff       	call   f01053ae <debuginfo_eip>
f0106939:	85 c0                	test   %eax,%eax
f010693b:	78 39                	js     f0106976 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010693d:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010693f:	89 c2                	mov    %eax,%edx
f0106941:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106944:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106948:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010694b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010694f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106952:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106956:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106959:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010695d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106960:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106964:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106968:	c7 04 24 ec 88 10 f0 	movl   $0xf01088ec,(%esp)
f010696f:	e8 77 dc ff ff       	call   f01045eb <cprintf>
f0106974:	eb 12                	jmp    f0106988 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106976:	8b 03                	mov    (%ebx),%eax
f0106978:	89 44 24 04          	mov    %eax,0x4(%esp)
f010697c:	c7 04 24 03 89 10 f0 	movl   $0xf0108903,(%esp)
f0106983:	e8 63 dc ff ff       	call   f01045eb <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106988:	39 fb                	cmp    %edi,%ebx
f010698a:	74 0a                	je     f0106996 <spin_unlock+0xda>
f010698c:	8b 43 04             	mov    0x4(%ebx),%eax
f010698f:	83 c3 04             	add    $0x4,%ebx
f0106992:	85 c0                	test   %eax,%eax
f0106994:	75 97                	jne    f010692d <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106996:	c7 44 24 08 0b 89 10 	movl   $0xf010890b,0x8(%esp)
f010699d:	f0 
f010699e:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
f01069a5:	00 
f01069a6:	c7 04 24 17 89 10 f0 	movl   $0xf0108917,(%esp)
f01069ad:	e8 d3 96 ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f01069b2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01069b9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01069c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01069c5:	f0 87 03             	lock xchg %eax,(%ebx)
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
#endif
}
f01069c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01069cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01069ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01069d1:	89 ec                	mov    %ebp,%esp
f01069d3:	5d                   	pop    %ebp
f01069d4:	c3                   	ret    

f01069d5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069d5:	55                   	push   %ebp
f01069d6:	89 e5                	mov    %esp,%ebp
f01069d8:	56                   	push   %esi
f01069d9:	53                   	push   %ebx
f01069da:	83 ec 20             	sub    $0x20,%esp
f01069dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069e0:	89 d8                	mov    %ebx,%eax
f01069e2:	e8 a4 fe ff ff       	call   f010688b <holding>
f01069e7:	85 c0                	test   %eax,%eax
f01069e9:	75 12                	jne    f01069fd <spin_lock+0x28>

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01069eb:	89 da                	mov    %ebx,%edx
f01069ed:	b0 01                	mov    $0x1,%al
f01069ef:	f0 87 03             	lock xchg %eax,(%ebx)
f01069f2:	b9 01 00 00 00       	mov    $0x1,%ecx
f01069f7:	85 c0                	test   %eax,%eax
f01069f9:	75 2e                	jne    f0106a29 <spin_lock+0x54>
f01069fb:	eb 37                	jmp    f0106a34 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01069fd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a00:	e8 09 fc ff ff       	call   f010660e <cpunum>
f0106a05:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a0d:	c7 44 24 08 c0 88 10 	movl   $0xf01088c0,0x8(%esp)
f0106a14:	f0 
f0106a15:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0106a1c:	00 
f0106a1d:	c7 04 24 17 89 10 f0 	movl   $0xf0108917,(%esp)
f0106a24:	e8 5c 96 ff ff       	call   f0100085 <_panic>
#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a29:	f3 90                	pause  
f0106a2b:	89 c8                	mov    %ecx,%eax
f0106a2d:	f0 87 02             	lock xchg %eax,(%edx)

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a30:	85 c0                	test   %eax,%eax
f0106a32:	75 f5                	jne    f0106a29 <spin_lock+0x54>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a34:	e8 d5 fb ff ff       	call   f010660e <cpunum>
f0106a39:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a3c:	05 20 60 23 f0       	add    $0xf0236020,%eax
f0106a41:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a44:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106a47:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106a49:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0106a4f:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0106a55:	76 40                	jbe    f0106a97 <spin_lock+0xc2>
f0106a57:	eb 33                	jmp    f0106a8c <spin_lock+0xb7>
f0106a59:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f0106a5f:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0106a65:	77 2a                	ja     f0106a91 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a67:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106a6a:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a6d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a6f:	83 c0 01             	add    $0x1,%eax
f0106a72:	83 f8 0a             	cmp    $0xa,%eax
f0106a75:	75 e2                	jne    f0106a59 <spin_lock+0x84>
f0106a77:	eb 2d                	jmp    f0106aa6 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106a79:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106a7f:	83 c0 01             	add    $0x1,%eax
f0106a82:	83 c2 04             	add    $0x4,%edx
f0106a85:	83 f8 09             	cmp    $0x9,%eax
f0106a88:	7e ef                	jle    f0106a79 <spin_lock+0xa4>
f0106a8a:	eb 1a                	jmp    f0106aa6 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106a8c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0106a91:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0106a95:	eb e2                	jmp    f0106a79 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a97:	8b 50 04             	mov    0x4(%eax),%edx
f0106a9a:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a9d:	8b 10                	mov    (%eax),%edx
f0106a9f:	b8 01 00 00 00       	mov    $0x1,%eax
f0106aa4:	eb b3                	jmp    f0106a59 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106aa6:	83 c4 20             	add    $0x20,%esp
f0106aa9:	5b                   	pop    %ebx
f0106aaa:	5e                   	pop    %esi
f0106aab:	5d                   	pop    %ebp
f0106aac:	c3                   	ret    
f0106aad:	00 00                	add    %al,(%eax)
	...

f0106ab0 <__udivdi3>:
f0106ab0:	55                   	push   %ebp
f0106ab1:	89 e5                	mov    %esp,%ebp
f0106ab3:	57                   	push   %edi
f0106ab4:	56                   	push   %esi
f0106ab5:	83 ec 10             	sub    $0x10,%esp
f0106ab8:	8b 45 14             	mov    0x14(%ebp),%eax
f0106abb:	8b 55 08             	mov    0x8(%ebp),%edx
f0106abe:	8b 75 10             	mov    0x10(%ebp),%esi
f0106ac1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106ac4:	85 c0                	test   %eax,%eax
f0106ac6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0106ac9:	75 35                	jne    f0106b00 <__udivdi3+0x50>
f0106acb:	39 fe                	cmp    %edi,%esi
f0106acd:	77 61                	ja     f0106b30 <__udivdi3+0x80>
f0106acf:	85 f6                	test   %esi,%esi
f0106ad1:	75 0b                	jne    f0106ade <__udivdi3+0x2e>
f0106ad3:	b8 01 00 00 00       	mov    $0x1,%eax
f0106ad8:	31 d2                	xor    %edx,%edx
f0106ada:	f7 f6                	div    %esi
f0106adc:	89 c6                	mov    %eax,%esi
f0106ade:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0106ae1:	31 d2                	xor    %edx,%edx
f0106ae3:	89 f8                	mov    %edi,%eax
f0106ae5:	f7 f6                	div    %esi
f0106ae7:	89 c7                	mov    %eax,%edi
f0106ae9:	89 c8                	mov    %ecx,%eax
f0106aeb:	f7 f6                	div    %esi
f0106aed:	89 c1                	mov    %eax,%ecx
f0106aef:	89 fa                	mov    %edi,%edx
f0106af1:	89 c8                	mov    %ecx,%eax
f0106af3:	83 c4 10             	add    $0x10,%esp
f0106af6:	5e                   	pop    %esi
f0106af7:	5f                   	pop    %edi
f0106af8:	5d                   	pop    %ebp
f0106af9:	c3                   	ret    
f0106afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b00:	39 f8                	cmp    %edi,%eax
f0106b02:	77 1c                	ja     f0106b20 <__udivdi3+0x70>
f0106b04:	0f bd d0             	bsr    %eax,%edx
f0106b07:	83 f2 1f             	xor    $0x1f,%edx
f0106b0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106b0d:	75 39                	jne    f0106b48 <__udivdi3+0x98>
f0106b0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0106b12:	0f 86 a0 00 00 00    	jbe    f0106bb8 <__udivdi3+0x108>
f0106b18:	39 f8                	cmp    %edi,%eax
f0106b1a:	0f 82 98 00 00 00    	jb     f0106bb8 <__udivdi3+0x108>
f0106b20:	31 ff                	xor    %edi,%edi
f0106b22:	31 c9                	xor    %ecx,%ecx
f0106b24:	89 c8                	mov    %ecx,%eax
f0106b26:	89 fa                	mov    %edi,%edx
f0106b28:	83 c4 10             	add    $0x10,%esp
f0106b2b:	5e                   	pop    %esi
f0106b2c:	5f                   	pop    %edi
f0106b2d:	5d                   	pop    %ebp
f0106b2e:	c3                   	ret    
f0106b2f:	90                   	nop
f0106b30:	89 d1                	mov    %edx,%ecx
f0106b32:	89 fa                	mov    %edi,%edx
f0106b34:	89 c8                	mov    %ecx,%eax
f0106b36:	31 ff                	xor    %edi,%edi
f0106b38:	f7 f6                	div    %esi
f0106b3a:	89 c1                	mov    %eax,%ecx
f0106b3c:	89 fa                	mov    %edi,%edx
f0106b3e:	89 c8                	mov    %ecx,%eax
f0106b40:	83 c4 10             	add    $0x10,%esp
f0106b43:	5e                   	pop    %esi
f0106b44:	5f                   	pop    %edi
f0106b45:	5d                   	pop    %ebp
f0106b46:	c3                   	ret    
f0106b47:	90                   	nop
f0106b48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106b4c:	89 f2                	mov    %esi,%edx
f0106b4e:	d3 e0                	shl    %cl,%eax
f0106b50:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106b53:	b8 20 00 00 00       	mov    $0x20,%eax
f0106b58:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0106b5b:	89 c1                	mov    %eax,%ecx
f0106b5d:	d3 ea                	shr    %cl,%edx
f0106b5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106b63:	0b 55 ec             	or     -0x14(%ebp),%edx
f0106b66:	d3 e6                	shl    %cl,%esi
f0106b68:	89 c1                	mov    %eax,%ecx
f0106b6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0106b6d:	89 fe                	mov    %edi,%esi
f0106b6f:	d3 ee                	shr    %cl,%esi
f0106b71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106b75:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106b7b:	d3 e7                	shl    %cl,%edi
f0106b7d:	89 c1                	mov    %eax,%ecx
f0106b7f:	d3 ea                	shr    %cl,%edx
f0106b81:	09 d7                	or     %edx,%edi
f0106b83:	89 f2                	mov    %esi,%edx
f0106b85:	89 f8                	mov    %edi,%eax
f0106b87:	f7 75 ec             	divl   -0x14(%ebp)
f0106b8a:	89 d6                	mov    %edx,%esi
f0106b8c:	89 c7                	mov    %eax,%edi
f0106b8e:	f7 65 e8             	mull   -0x18(%ebp)
f0106b91:	39 d6                	cmp    %edx,%esi
f0106b93:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106b96:	72 30                	jb     f0106bc8 <__udivdi3+0x118>
f0106b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106b9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106b9f:	d3 e2                	shl    %cl,%edx
f0106ba1:	39 c2                	cmp    %eax,%edx
f0106ba3:	73 05                	jae    f0106baa <__udivdi3+0xfa>
f0106ba5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0106ba8:	74 1e                	je     f0106bc8 <__udivdi3+0x118>
f0106baa:	89 f9                	mov    %edi,%ecx
f0106bac:	31 ff                	xor    %edi,%edi
f0106bae:	e9 71 ff ff ff       	jmp    f0106b24 <__udivdi3+0x74>
f0106bb3:	90                   	nop
f0106bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bb8:	31 ff                	xor    %edi,%edi
f0106bba:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106bbf:	e9 60 ff ff ff       	jmp    f0106b24 <__udivdi3+0x74>
f0106bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0106bcb:	31 ff                	xor    %edi,%edi
f0106bcd:	89 c8                	mov    %ecx,%eax
f0106bcf:	89 fa                	mov    %edi,%edx
f0106bd1:	83 c4 10             	add    $0x10,%esp
f0106bd4:	5e                   	pop    %esi
f0106bd5:	5f                   	pop    %edi
f0106bd6:	5d                   	pop    %ebp
f0106bd7:	c3                   	ret    
	...

f0106be0 <__umoddi3>:
f0106be0:	55                   	push   %ebp
f0106be1:	89 e5                	mov    %esp,%ebp
f0106be3:	57                   	push   %edi
f0106be4:	56                   	push   %esi
f0106be5:	83 ec 20             	sub    $0x20,%esp
f0106be8:	8b 55 14             	mov    0x14(%ebp),%edx
f0106beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106bee:	8b 7d 10             	mov    0x10(%ebp),%edi
f0106bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106bf4:	85 d2                	test   %edx,%edx
f0106bf6:	89 c8                	mov    %ecx,%eax
f0106bf8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106bfb:	75 13                	jne    f0106c10 <__umoddi3+0x30>
f0106bfd:	39 f7                	cmp    %esi,%edi
f0106bff:	76 3f                	jbe    f0106c40 <__umoddi3+0x60>
f0106c01:	89 f2                	mov    %esi,%edx
f0106c03:	f7 f7                	div    %edi
f0106c05:	89 d0                	mov    %edx,%eax
f0106c07:	31 d2                	xor    %edx,%edx
f0106c09:	83 c4 20             	add    $0x20,%esp
f0106c0c:	5e                   	pop    %esi
f0106c0d:	5f                   	pop    %edi
f0106c0e:	5d                   	pop    %ebp
f0106c0f:	c3                   	ret    
f0106c10:	39 f2                	cmp    %esi,%edx
f0106c12:	77 4c                	ja     f0106c60 <__umoddi3+0x80>
f0106c14:	0f bd ca             	bsr    %edx,%ecx
f0106c17:	83 f1 1f             	xor    $0x1f,%ecx
f0106c1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106c1d:	75 51                	jne    f0106c70 <__umoddi3+0x90>
f0106c1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0106c22:	0f 87 e0 00 00 00    	ja     f0106d08 <__umoddi3+0x128>
f0106c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106c2b:	29 f8                	sub    %edi,%eax
f0106c2d:	19 d6                	sbb    %edx,%esi
f0106c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106c35:	89 f2                	mov    %esi,%edx
f0106c37:	83 c4 20             	add    $0x20,%esp
f0106c3a:	5e                   	pop    %esi
f0106c3b:	5f                   	pop    %edi
f0106c3c:	5d                   	pop    %ebp
f0106c3d:	c3                   	ret    
f0106c3e:	66 90                	xchg   %ax,%ax
f0106c40:	85 ff                	test   %edi,%edi
f0106c42:	75 0b                	jne    f0106c4f <__umoddi3+0x6f>
f0106c44:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c49:	31 d2                	xor    %edx,%edx
f0106c4b:	f7 f7                	div    %edi
f0106c4d:	89 c7                	mov    %eax,%edi
f0106c4f:	89 f0                	mov    %esi,%eax
f0106c51:	31 d2                	xor    %edx,%edx
f0106c53:	f7 f7                	div    %edi
f0106c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106c58:	f7 f7                	div    %edi
f0106c5a:	eb a9                	jmp    f0106c05 <__umoddi3+0x25>
f0106c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c60:	89 c8                	mov    %ecx,%eax
f0106c62:	89 f2                	mov    %esi,%edx
f0106c64:	83 c4 20             	add    $0x20,%esp
f0106c67:	5e                   	pop    %esi
f0106c68:	5f                   	pop    %edi
f0106c69:	5d                   	pop    %ebp
f0106c6a:	c3                   	ret    
f0106c6b:	90                   	nop
f0106c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c74:	d3 e2                	shl    %cl,%edx
f0106c76:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106c79:	ba 20 00 00 00       	mov    $0x20,%edx
f0106c7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0106c81:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106c84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c88:	89 fa                	mov    %edi,%edx
f0106c8a:	d3 ea                	shr    %cl,%edx
f0106c8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c90:	0b 55 f4             	or     -0xc(%ebp),%edx
f0106c93:	d3 e7                	shl    %cl,%edi
f0106c95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c99:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106c9c:	89 f2                	mov    %esi,%edx
f0106c9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0106ca1:	89 c7                	mov    %eax,%edi
f0106ca3:	d3 ea                	shr    %cl,%edx
f0106ca5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106ca9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0106cac:	89 c2                	mov    %eax,%edx
f0106cae:	d3 e6                	shl    %cl,%esi
f0106cb0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106cb4:	d3 ea                	shr    %cl,%edx
f0106cb6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106cba:	09 d6                	or     %edx,%esi
f0106cbc:	89 f0                	mov    %esi,%eax
f0106cbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0106cc1:	d3 e7                	shl    %cl,%edi
f0106cc3:	89 f2                	mov    %esi,%edx
f0106cc5:	f7 75 f4             	divl   -0xc(%ebp)
f0106cc8:	89 d6                	mov    %edx,%esi
f0106cca:	f7 65 e8             	mull   -0x18(%ebp)
f0106ccd:	39 d6                	cmp    %edx,%esi
f0106ccf:	72 2b                	jb     f0106cfc <__umoddi3+0x11c>
f0106cd1:	39 c7                	cmp    %eax,%edi
f0106cd3:	72 23                	jb     f0106cf8 <__umoddi3+0x118>
f0106cd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106cd9:	29 c7                	sub    %eax,%edi
f0106cdb:	19 d6                	sbb    %edx,%esi
f0106cdd:	89 f0                	mov    %esi,%eax
f0106cdf:	89 f2                	mov    %esi,%edx
f0106ce1:	d3 ef                	shr    %cl,%edi
f0106ce3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106ce7:	d3 e0                	shl    %cl,%eax
f0106ce9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106ced:	09 f8                	or     %edi,%eax
f0106cef:	d3 ea                	shr    %cl,%edx
f0106cf1:	83 c4 20             	add    $0x20,%esp
f0106cf4:	5e                   	pop    %esi
f0106cf5:	5f                   	pop    %edi
f0106cf6:	5d                   	pop    %ebp
f0106cf7:	c3                   	ret    
f0106cf8:	39 d6                	cmp    %edx,%esi
f0106cfa:	75 d9                	jne    f0106cd5 <__umoddi3+0xf5>
f0106cfc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0106cff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0106d02:	eb d1                	jmp    f0106cd5 <__umoddi3+0xf5>
f0106d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106d08:	39 f2                	cmp    %esi,%edx
f0106d0a:	0f 82 18 ff ff ff    	jb     f0106c28 <__umoddi3+0x48>
f0106d10:	e9 1d ff ff ff       	jmp    f0106c32 <__umoddi3+0x52>
