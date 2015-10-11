
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
	# until we set up our real page table in i386_vm_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 03 01 00 00       	call   f0100141 <i386_init>

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
f0100058:	c7 04 24 c0 1f 10 f0 	movl   $0xf0101fc0,(%esp)
f010005f:	e8 4b 0c 00 00       	call   f0100caf <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 09 0c 00 00       	call   f0100c7c <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 e6 20 10 f0 	movl   $0xf01020e6,(%esp)
f010007a:	e8 30 0c 00 00       	call   f0100caf <cprintf>
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
f0100090:	83 3d 00 33 11 f0 00 	cmpl   $0x0,0xf0113300
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 00 33 11 f0    	mov    %esi,0xf0113300

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
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 da 1f 10 f0 	movl   $0xf0101fda,(%esp)
f01000b9:	e8 f1 0b 00 00       	call   f0100caf <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 b2 0b 00 00       	call   f0100c7c <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 e6 20 10 f0 	movl   $0xf01020e6,(%esp)
f01000d1:	e8 d9 0b 00 00       	call   f0100caf <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 e8 08 00 00       	call   f01009ca <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	53                   	push   %ebx
f01000e8:	83 ec 14             	sub    $0x14,%esp
f01000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f2:	c7 04 24 f2 1f 10 f0 	movl   $0xf0101ff2,(%esp)
f01000f9:	e8 b1 0b 00 00       	call   f0100caf <cprintf>
	if (x > 0)
f01000fe:	85 db                	test   %ebx,%ebx
f0100100:	7e 0d                	jle    f010010f <test_backtrace+0x2b>
		test_backtrace(x-1);
f0100102:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100105:	89 04 24             	mov    %eax,(%esp)
f0100108:	e8 d7 ff ff ff       	call   f01000e4 <test_backtrace>
f010010d:	eb 1c                	jmp    f010012b <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010010f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100116:	00 
f0100117:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010011e:	00 
f010011f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100126:	e8 9b 0a 00 00       	call   f0100bc6 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f010012b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012f:	c7 04 24 0e 20 10 f0 	movl   $0xf010200e,(%esp)
f0100136:	e8 74 0b 00 00       	call   f0100caf <cprintf>
}
f010013b:	83 c4 14             	add    $0x14,%esp
f010013e:	5b                   	pop    %ebx
f010013f:	5d                   	pop    %ebp
f0100140:	c3                   	ret    

f0100141 <i386_init>:

void
i386_init(void)
{
f0100141:	55                   	push   %ebp
f0100142:	89 e5                	mov    %esp,%ebp
f0100144:	57                   	push   %edi
f0100145:	53                   	push   %ebx
f0100146:	81 ec 20 01 00 00    	sub    $0x120,%esp
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f010014c:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
f0100150:	c6 45 f6 00          	movb   $0x0,-0xa(%ebp)
f0100154:	ba 00 01 00 00       	mov    $0x100,%edx
f0100159:	b8 00 00 00 00       	mov    $0x0,%eax
f010015e:	8d bd f6 fe ff ff    	lea    -0x10a(%ebp),%edi
f0100164:	66 ab                	stos   %ax,%es:(%edi)
f0100166:	83 ea 02             	sub    $0x2,%edx
f0100169:	89 d1                	mov    %edx,%ecx
f010016b:	c1 e9 02             	shr    $0x2,%ecx
f010016e:	f3 ab                	rep stos %eax,%es:(%edi)
f0100170:	f6 c2 02             	test   $0x2,%dl
f0100173:	74 02                	je     f0100177 <i386_init+0x36>
f0100175:	66 ab                	stos   %ax,%es:(%edi)
f0100177:	83 e2 01             	and    $0x1,%edx
f010017a:	85 d2                	test   %edx,%edx
f010017c:	74 01                	je     f010017f <i386_init+0x3e>
f010017e:	aa                   	stos   %al,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010017f:	b8 60 39 11 f0       	mov    $0xf0113960,%eax
f0100184:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100194:	00 
f0100195:	c7 04 24 00 33 11 f0 	movl   $0xf0113300,(%esp)
f010019c:	e8 45 19 00 00       	call   f0101ae6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a1:	e8 f4 03 00 00       	call   f010059a <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01001a6:	8d 45 f6             	lea    -0xa(%ebp),%eax
f01001a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001ad:	8d 7d f7             	lea    -0x9(%ebp),%edi
f01001b0:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01001b4:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 70 20 10 f0 	movl   $0xf0102070,(%esp)
f01001c3:	e8 e7 0a 00 00       	call   f0100caf <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01001c8:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
f01001cf:	00 
f01001d0:	c7 04 24 90 20 10 f0 	movl   $0xf0102090,(%esp)
f01001d7:	e8 d3 0a 00 00       	call   f0100caf <cprintf>
	//cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f01001dc:	0f be 45 f6          	movsbl -0xa(%ebp),%eax
f01001e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001e4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f01001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001ec:	c7 04 24 29 20 10 f0 	movl   $0xf0102029,(%esp)
f01001f3:	e8 b7 0a 00 00       	call   f0100caf <cprintf>
	cprintf("%n", NULL);
f01001f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001ff:	00 
f0100200:	c7 04 24 42 20 10 f0 	movl   $0xf0102042,(%esp)
f0100207:	e8 a3 0a 00 00       	call   f0100caf <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f010020c:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f0100213:	00 
f0100214:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f010021b:	00 
f010021c:	8d 9d f6 fe ff ff    	lea    -0x10a(%ebp),%ebx
f0100222:	89 1c 24             	mov    %ebx,(%esp)
f0100225:	e8 bc 18 00 00       	call   f0101ae6 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f010022a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010022e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100232:	c7 04 24 40 20 10 f0 	movl   $0xf0102040,(%esp)
f0100239:	e8 71 0a 00 00       	call   f0100caf <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010023e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100242:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100246:	c7 04 24 45 20 10 f0 	movl   $0xf0102045,(%esp)
f010024d:	e8 5d 0a 00 00       	call   f0100caf <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f0100252:	c7 44 24 08 00 fc ff 	movl   $0xfffffc00,0x8(%esp)
f0100259:	ff 
f010025a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0100261:	00 
f0100262:	c7 04 24 51 20 10 f0 	movl   $0xf0102051,(%esp)
f0100269:	e8 41 0a 00 00       	call   f0100caf <cprintf>


	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010026e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100275:	e8 6a fe ff ff       	call   f01000e4 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010027a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100281:	e8 44 07 00 00       	call   f01009ca <monitor>
f0100286:	eb f2                	jmp    f010027a <i386_init+0x139>
	...

f0100290 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100290:	55                   	push   %ebp
f0100291:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100293:	ba 84 00 00 00       	mov    $0x84,%edx
f0100298:	ec                   	in     (%dx),%al
f0100299:	ec                   	in     (%dx),%al
f010029a:	ec                   	in     (%dx),%al
f010029b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010029c:	5d                   	pop    %ebp
f010029d:	c3                   	ret    

f010029e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a6:	ec                   	in     (%dx),%al
f01002a7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ae:	f6 c2 01             	test   $0x1,%dl
f01002b1:	74 09                	je     f01002bc <serial_proc_data+0x1e>
f01002b3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002b8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002b9:	0f b6 c0             	movzbl %al,%eax
}
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002be:	55                   	push   %ebp
f01002bf:	89 e5                	mov    %esp,%ebp
f01002c1:	57                   	push   %edi
f01002c2:	56                   	push   %esi
f01002c3:	53                   	push   %ebx
f01002c4:	83 ec 0c             	sub    $0xc,%esp
f01002c7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002c9:	bb 44 35 11 f0       	mov    $0xf0113544,%ebx
f01002ce:	bf 40 33 11 f0       	mov    $0xf0113340,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d3:	eb 1e                	jmp    f01002f3 <cons_intr+0x35>
		if (c == 0)
f01002d5:	85 c0                	test   %eax,%eax
f01002d7:	74 1a                	je     f01002f3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002d9:	8b 13                	mov    (%ebx),%edx
f01002db:	88 04 17             	mov    %al,(%edi,%edx,1)
f01002de:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002e1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002e6:	0f 94 c2             	sete   %dl
f01002e9:	0f b6 d2             	movzbl %dl,%edx
f01002ec:	83 ea 01             	sub    $0x1,%edx
f01002ef:	21 d0                	and    %edx,%eax
f01002f1:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002f3:	ff d6                	call   *%esi
f01002f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f8:	75 db                	jne    f01002d5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002fa:	83 c4 0c             	add    $0xc,%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5e                   	pop    %esi
f01002ff:	5f                   	pop    %edi
f0100300:	5d                   	pop    %ebp
f0100301:	c3                   	ret    

f0100302 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100302:	55                   	push   %ebp
f0100303:	89 e5                	mov    %esp,%ebp
f0100305:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100308:	b8 8a 06 10 f0       	mov    $0xf010068a,%eax
f010030d:	e8 ac ff ff ff       	call   f01002be <cons_intr>
}
f0100312:	c9                   	leave  
f0100313:	c3                   	ret    

f0100314 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100314:	55                   	push   %ebp
f0100315:	89 e5                	mov    %esp,%ebp
f0100317:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010031a:	83 3d 24 33 11 f0 00 	cmpl   $0x0,0xf0113324
f0100321:	74 0a                	je     f010032d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100323:	b8 9e 02 10 f0       	mov    $0xf010029e,%eax
f0100328:	e8 91 ff ff ff       	call   f01002be <cons_intr>
}
f010032d:	c9                   	leave  
f010032e:	c3                   	ret    

f010032f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010032f:	55                   	push   %ebp
f0100330:	89 e5                	mov    %esp,%ebp
f0100332:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100335:	e8 da ff ff ff       	call   f0100314 <serial_intr>
	kbd_intr();
f010033a:	e8 c3 ff ff ff       	call   f0100302 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010033f:	8b 15 40 35 11 f0    	mov    0xf0113540,%edx
f0100345:	b8 00 00 00 00       	mov    $0x0,%eax
f010034a:	3b 15 44 35 11 f0    	cmp    0xf0113544,%edx
f0100350:	74 21                	je     f0100373 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100352:	0f b6 82 40 33 11 f0 	movzbl -0xfeeccc0(%edx),%eax
f0100359:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010035c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100362:	0f 94 c1             	sete   %cl
f0100365:	0f b6 c9             	movzbl %cl,%ecx
f0100368:	83 e9 01             	sub    $0x1,%ecx
f010036b:	21 ca                	and    %ecx,%edx
f010036d:	89 15 40 35 11 f0    	mov    %edx,0xf0113540
		return c;
	}
	return 0;
}
f0100373:	c9                   	leave  
f0100374:	c3                   	ret    

f0100375 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100375:	55                   	push   %ebp
f0100376:	89 e5                	mov    %esp,%ebp
f0100378:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010037b:	e8 af ff ff ff       	call   f010032f <cons_getc>
f0100380:	85 c0                	test   %eax,%eax
f0100382:	74 f7                	je     f010037b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100384:	c9                   	leave  
f0100385:	c3                   	ret    

f0100386 <iscons>:

int
iscons(int fdnum)
{
f0100386:	55                   	push   %ebp
f0100387:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100389:	b8 01 00 00 00       	mov    $0x1,%eax
f010038e:	5d                   	pop    %ebp
f010038f:	c3                   	ret    

f0100390 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100390:	55                   	push   %ebp
f0100391:	89 e5                	mov    %esp,%ebp
f0100393:	57                   	push   %edi
f0100394:	56                   	push   %esi
f0100395:	53                   	push   %ebx
f0100396:	83 ec 2c             	sub    $0x2c,%esp
f0100399:	89 c7                	mov    %eax,%edi
f010039b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003a1:	a8 20                	test   $0x20,%al
f01003a3:	75 21                	jne    f01003c6 <cons_putc+0x36>
f01003a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003aa:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01003af:	e8 dc fe ff ff       	call   f0100290 <delay>
f01003b4:	89 f2                	mov    %esi,%edx
f01003b6:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003b7:	a8 20                	test   $0x20,%al
f01003b9:	75 0b                	jne    f01003c6 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003bb:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003be:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003c4:	75 e9                	jne    f01003af <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01003c6:	89 fa                	mov    %edi,%edx
f01003c8:	89 f8                	mov    %edi,%eax
f01003ca:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d3:	b2 79                	mov    $0x79,%dl
f01003d5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d6:	84 c0                	test   %al,%al
f01003d8:	78 21                	js     f01003fb <cons_putc+0x6b>
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003df:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01003e4:	e8 a7 fe ff ff       	call   f0100290 <delay>
f01003e9:	89 f2                	mov    %esi,%edx
f01003eb:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ec:	84 c0                	test   %al,%al
f01003ee:	78 0b                	js     f01003fb <cons_putc+0x6b>
f01003f0:	83 c3 01             	add    $0x1,%ebx
f01003f3:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003f9:	75 e9                	jne    f01003e4 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003fb:	ba 78 03 00 00       	mov    $0x378,%edx
f0100400:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100404:	ee                   	out    %al,(%dx)
f0100405:	b2 7a                	mov    $0x7a,%dl
f0100407:	b8 0d 00 00 00       	mov    $0xd,%eax
f010040c:	ee                   	out    %al,(%dx)
f010040d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100412:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100413:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100419:	75 06                	jne    f0100421 <cons_putc+0x91>
		c |= 0x0700;
f010041b:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100421:	89 f8                	mov    %edi,%eax
f0100423:	25 ff 00 00 00       	and    $0xff,%eax
f0100428:	83 f8 09             	cmp    $0x9,%eax
f010042b:	0f 84 83 00 00 00    	je     f01004b4 <cons_putc+0x124>
f0100431:	83 f8 09             	cmp    $0x9,%eax
f0100434:	7f 0c                	jg     f0100442 <cons_putc+0xb2>
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	0f 85 a9 00 00 00    	jne    f01004e8 <cons_putc+0x158>
f010043f:	90                   	nop
f0100440:	eb 18                	jmp    f010045a <cons_putc+0xca>
f0100442:	83 f8 0a             	cmp    $0xa,%eax
f0100445:	8d 76 00             	lea    0x0(%esi),%esi
f0100448:	74 40                	je     f010048a <cons_putc+0xfa>
f010044a:	83 f8 0d             	cmp    $0xd,%eax
f010044d:	8d 76 00             	lea    0x0(%esi),%esi
f0100450:	0f 85 92 00 00 00    	jne    f01004e8 <cons_putc+0x158>
f0100456:	66 90                	xchg   %ax,%ax
f0100458:	eb 38                	jmp    f0100492 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010045a:	0f b7 05 30 33 11 f0 	movzwl 0xf0113330,%eax
f0100461:	66 85 c0             	test   %ax,%ax
f0100464:	0f 84 e8 00 00 00    	je     f0100552 <cons_putc+0x1c2>
			crt_pos--;
f010046a:	83 e8 01             	sub    $0x1,%eax
f010046d:	66 a3 30 33 11 f0    	mov    %ax,0xf0113330
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100473:	0f b7 c0             	movzwl %ax,%eax
f0100476:	66 81 e7 00 ff       	and    $0xff00,%di
f010047b:	83 cf 20             	or     $0x20,%edi
f010047e:	8b 15 2c 33 11 f0    	mov    0xf011332c,%edx
f0100484:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100488:	eb 7b                	jmp    f0100505 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010048a:	66 83 05 30 33 11 f0 	addw   $0x50,0xf0113330
f0100491:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100492:	0f b7 05 30 33 11 f0 	movzwl 0xf0113330,%eax
f0100499:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010049f:	c1 e8 10             	shr    $0x10,%eax
f01004a2:	66 c1 e8 06          	shr    $0x6,%ax
f01004a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004a9:	c1 e0 04             	shl    $0x4,%eax
f01004ac:	66 a3 30 33 11 f0    	mov    %ax,0xf0113330
f01004b2:	eb 51                	jmp    f0100505 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01004b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b9:	e8 d2 fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004be:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c3:	e8 c8 fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cd:	e8 be fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d7:	e8 b4 fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e1:	e8 aa fe ff ff       	call   f0100390 <cons_putc>
f01004e6:	eb 1d                	jmp    f0100505 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004e8:	0f b7 05 30 33 11 f0 	movzwl 0xf0113330,%eax
f01004ef:	0f b7 c8             	movzwl %ax,%ecx
f01004f2:	8b 15 2c 33 11 f0    	mov    0xf011332c,%edx
f01004f8:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01004fc:	83 c0 01             	add    $0x1,%eax
f01004ff:	66 a3 30 33 11 f0    	mov    %ax,0xf0113330
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100505:	66 81 3d 30 33 11 f0 	cmpw   $0x7cf,0xf0113330
f010050c:	cf 07 
f010050e:	76 42                	jbe    f0100552 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100510:	a1 2c 33 11 f0       	mov    0xf011332c,%eax
f0100515:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010051c:	00 
f010051d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100523:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100527:	89 04 24             	mov    %eax,(%esp)
f010052a:	e8 16 16 00 00       	call   f0101b45 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010052f:	8b 15 2c 33 11 f0    	mov    0xf011332c,%edx
f0100535:	b8 80 07 00 00       	mov    $0x780,%eax
f010053a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100540:	83 c0 01             	add    $0x1,%eax
f0100543:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100548:	75 f0                	jne    f010053a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010054a:	66 83 2d 30 33 11 f0 	subw   $0x50,0xf0113330
f0100551:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100552:	8b 0d 28 33 11 f0    	mov    0xf0113328,%ecx
f0100558:	89 cb                	mov    %ecx,%ebx
f010055a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010055f:	89 ca                	mov    %ecx,%edx
f0100561:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100562:	0f b7 35 30 33 11 f0 	movzwl 0xf0113330,%esi
f0100569:	83 c1 01             	add    $0x1,%ecx
f010056c:	89 f0                	mov    %esi,%eax
f010056e:	66 c1 e8 08          	shr    $0x8,%ax
f0100572:	89 ca                	mov    %ecx,%edx
f0100574:	ee                   	out    %al,(%dx)
f0100575:	b8 0f 00 00 00       	mov    $0xf,%eax
f010057a:	89 da                	mov    %ebx,%edx
f010057c:	ee                   	out    %al,(%dx)
f010057d:	89 f0                	mov    %esi,%eax
f010057f:	89 ca                	mov    %ecx,%edx
f0100581:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100582:	83 c4 2c             	add    $0x2c,%esp
f0100585:	5b                   	pop    %ebx
f0100586:	5e                   	pop    %esi
f0100587:	5f                   	pop    %edi
f0100588:	5d                   	pop    %ebp
f0100589:	c3                   	ret    

f010058a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010058a:	55                   	push   %ebp
f010058b:	89 e5                	mov    %esp,%ebp
f010058d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100590:	8b 45 08             	mov    0x8(%ebp),%eax
f0100593:	e8 f8 fd ff ff       	call   f0100390 <cons_putc>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	57                   	push   %edi
f010059e:	56                   	push   %esi
f010059f:	53                   	push   %ebx
f01005a0:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01005a3:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01005a8:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01005ab:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01005b0:	0f b7 00             	movzwl (%eax),%eax
f01005b3:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b7:	74 11                	je     f01005ca <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005b9:	c7 05 28 33 11 f0 b4 	movl   $0x3b4,0xf0113328
f01005c0:	03 00 00 
f01005c3:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005c8:	eb 16                	jmp    f01005e0 <cons_init+0x46>
	} else {
		*cp = was;
f01005ca:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005d1:	c7 05 28 33 11 f0 d4 	movl   $0x3d4,0xf0113328
f01005d8:	03 00 00 
f01005db:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01005e0:	8b 0d 28 33 11 f0    	mov    0xf0113328,%ecx
f01005e6:	89 cb                	mov    %ecx,%ebx
f01005e8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ed:	89 ca                	mov    %ecx,%edx
f01005ef:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f0:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f3:	89 ca                	mov    %ecx,%edx
f01005f5:	ec                   	in     (%dx),%al
f01005f6:	0f b6 f8             	movzbl %al,%edi
f01005f9:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005fc:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100601:	89 da                	mov    %ebx,%edx
f0100603:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100604:	89 ca                	mov    %ecx,%edx
f0100606:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100607:	89 35 2c 33 11 f0    	mov    %esi,0xf011332c
	crt_pos = pos;
f010060d:	0f b6 c8             	movzbl %al,%ecx
f0100610:	09 cf                	or     %ecx,%edi
f0100612:	66 89 3d 30 33 11 f0 	mov    %di,0xf0113330
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010061e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100623:	89 da                	mov    %ebx,%edx
f0100625:	ee                   	out    %al,(%dx)
f0100626:	b2 fb                	mov    $0xfb,%dl
f0100628:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010062d:	ee                   	out    %al,(%dx)
f010062e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100633:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100638:	89 ca                	mov    %ecx,%edx
f010063a:	ee                   	out    %al,(%dx)
f010063b:	b2 f9                	mov    $0xf9,%dl
f010063d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100642:	ee                   	out    %al,(%dx)
f0100643:	b2 fb                	mov    $0xfb,%dl
f0100645:	b8 03 00 00 00       	mov    $0x3,%eax
f010064a:	ee                   	out    %al,(%dx)
f010064b:	b2 fc                	mov    $0xfc,%dl
f010064d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100652:	ee                   	out    %al,(%dx)
f0100653:	b2 f9                	mov    $0xf9,%dl
f0100655:	b8 01 00 00 00       	mov    $0x1,%eax
f010065a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010065b:	b2 fd                	mov    $0xfd,%dl
f010065d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010065e:	3c ff                	cmp    $0xff,%al
f0100660:	0f 95 c0             	setne  %al
f0100663:	0f b6 f0             	movzbl %al,%esi
f0100666:	89 35 24 33 11 f0    	mov    %esi,0xf0113324
f010066c:	89 da                	mov    %ebx,%edx
f010066e:	ec                   	in     (%dx),%al
f010066f:	89 ca                	mov    %ecx,%edx
f0100671:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100672:	85 f6                	test   %esi,%esi
f0100674:	75 0c                	jne    f0100682 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f0100676:	c7 04 24 bf 20 10 f0 	movl   $0xf01020bf,(%esp)
f010067d:	e8 2d 06 00 00       	call   f0100caf <cprintf>
}
f0100682:	83 c4 1c             	add    $0x1c,%esp
f0100685:	5b                   	pop    %ebx
f0100686:	5e                   	pop    %esi
f0100687:	5f                   	pop    %edi
f0100688:	5d                   	pop    %ebp
f0100689:	c3                   	ret    

f010068a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010068a:	55                   	push   %ebp
f010068b:	89 e5                	mov    %esp,%ebp
f010068d:	53                   	push   %ebx
f010068e:	83 ec 14             	sub    $0x14,%esp
f0100691:	ba 64 00 00 00       	mov    $0x64,%edx
f0100696:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100697:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010069c:	a8 01                	test   $0x1,%al
f010069e:	0f 84 d9 00 00 00    	je     f010077d <kbd_proc_data+0xf3>
f01006a4:	b2 60                	mov    $0x60,%dl
f01006a6:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01006a7:	3c e0                	cmp    $0xe0,%al
f01006a9:	75 11                	jne    f01006bc <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01006ab:	83 0d 20 33 11 f0 40 	orl    $0x40,0xf0113320
f01006b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006b7:	e9 c1 00 00 00       	jmp    f010077d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01006bc:	84 c0                	test   %al,%al
f01006be:	79 32                	jns    f01006f2 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006c0:	8b 15 20 33 11 f0    	mov    0xf0113320,%edx
f01006c6:	f6 c2 40             	test   $0x40,%dl
f01006c9:	75 03                	jne    f01006ce <kbd_proc_data+0x44>
f01006cb:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01006ce:	0f b6 c0             	movzbl %al,%eax
f01006d1:	0f b6 80 00 21 10 f0 	movzbl -0xfefdf00(%eax),%eax
f01006d8:	83 c8 40             	or     $0x40,%eax
f01006db:	0f b6 c0             	movzbl %al,%eax
f01006de:	f7 d0                	not    %eax
f01006e0:	21 c2                	and    %eax,%edx
f01006e2:	89 15 20 33 11 f0    	mov    %edx,0xf0113320
f01006e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006ed:	e9 8b 00 00 00       	jmp    f010077d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01006f2:	8b 15 20 33 11 f0    	mov    0xf0113320,%edx
f01006f8:	f6 c2 40             	test   $0x40,%dl
f01006fb:	74 0c                	je     f0100709 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01006fd:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100700:	83 e2 bf             	and    $0xffffffbf,%edx
f0100703:	89 15 20 33 11 f0    	mov    %edx,0xf0113320
	}

	shift |= shiftcode[data];
f0100709:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010070c:	0f b6 90 00 21 10 f0 	movzbl -0xfefdf00(%eax),%edx
f0100713:	0b 15 20 33 11 f0    	or     0xf0113320,%edx
f0100719:	0f b6 88 00 22 10 f0 	movzbl -0xfefde00(%eax),%ecx
f0100720:	31 ca                	xor    %ecx,%edx
f0100722:	89 15 20 33 11 f0    	mov    %edx,0xf0113320

	c = charcode[shift & (CTL | SHIFT)][data];
f0100728:	89 d1                	mov    %edx,%ecx
f010072a:	83 e1 03             	and    $0x3,%ecx
f010072d:	8b 0c 8d 00 23 10 f0 	mov    -0xfefdd00(,%ecx,4),%ecx
f0100734:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100738:	f6 c2 08             	test   $0x8,%dl
f010073b:	74 1a                	je     f0100757 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010073d:	89 d9                	mov    %ebx,%ecx
f010073f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100742:	83 f8 19             	cmp    $0x19,%eax
f0100745:	77 05                	ja     f010074c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100747:	83 eb 20             	sub    $0x20,%ebx
f010074a:	eb 0b                	jmp    f0100757 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010074c:	83 e9 41             	sub    $0x41,%ecx
f010074f:	83 f9 19             	cmp    $0x19,%ecx
f0100752:	77 03                	ja     f0100757 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100754:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100757:	f7 d2                	not    %edx
f0100759:	f6 c2 06             	test   $0x6,%dl
f010075c:	75 1f                	jne    f010077d <kbd_proc_data+0xf3>
f010075e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100764:	75 17                	jne    f010077d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100766:	c7 04 24 dc 20 10 f0 	movl   $0xf01020dc,(%esp)
f010076d:	e8 3d 05 00 00       	call   f0100caf <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100772:	ba 92 00 00 00       	mov    $0x92,%edx
f0100777:	b8 03 00 00 00       	mov    $0x3,%eax
f010077c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010077d:	89 d8                	mov    %ebx,%eax
f010077f:	83 c4 14             	add    $0x14,%esp
f0100782:	5b                   	pop    %ebx
f0100783:	5d                   	pop    %ebp
f0100784:	c3                   	ret    
	...

f0100790 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100790:	55                   	push   %ebp
f0100791:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100793:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100796:	5d                   	pop    %ebp
f0100797:	c3                   	ret    

f0100798 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100798:	55                   	push   %ebp
f0100799:	89 e5                	mov    %esp,%ebp
f010079b:	57                   	push   %edi
f010079c:	56                   	push   %esi
f010079d:	53                   	push   %ebx
f010079e:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f01007a4:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01007aa:	b9 40 00 00 00       	mov    $0x40,%ecx
f01007af:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b4:	f3 ab                	rep stos %eax,%es:(%edi)
    int nstr = 0;
    char *pret_addr;

	// Your code here.
    	/* stone's solution for exercise16 */
	pret_addr = (char *)read_pretaddr();
f01007b6:	8d 75 04             	lea    0x4(%ebp),%esi
	uint32_t targ_addr = (uint32_t)do_overflow + 3;//reserve the stack.
f01007b9:	bf c1 08 10 f0       	mov    $0xf01008c1,%edi
	int i;
	for( i = 0; i < 256; i++)
		str[i] = '1';
f01007be:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
f01007c4:	c6 04 02 31          	movb   $0x31,(%edx,%eax,1)
	// Your code here.
    	/* stone's solution for exercise16 */
	pret_addr = (char *)read_pretaddr();
	uint32_t targ_addr = (uint32_t)do_overflow + 3;//reserve the stack.
	int i;
	for( i = 0; i < 256; i++)
f01007c8:	83 c0 01             	add    $0x1,%eax
f01007cb:	3d 00 01 00 00       	cmp    $0x100,%eax
f01007d0:	75 f2                	jne    f01007c4 <start_overflow+0x2c>
		str[i] = '1';
	uint32_t targ_frag1 = targ_addr & 0xFF;
f01007d2:	89 f8                	mov    %edi,%eax
f01007d4:	25 ff 00 00 00       	and    $0xff,%eax
f01007d9:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag1] = '\0';
f01007df:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f01007e6:	00 
	cprintf("%s%n", str, pret_addr);
f01007e7:	89 74 24 08          	mov    %esi,0x8(%esp)
f01007eb:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f01007f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01007f5:	c7 04 24 40 20 10 f0 	movl   $0xf0102040,(%esp)
f01007fc:	e8 ae 04 00 00       	call   f0100caf <cprintf>
	str[targ_frag1] = '1';
f0100801:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f0100807:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f010080e:	31 

	uint32_t targ_frag2 = (targ_addr>>8) & 0xFF;
f010080f:	89 f8                	mov    %edi,%eax
f0100811:	0f b6 c4             	movzbl %ah,%eax
f0100814:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag2] = '\0';
f010081a:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100821:	00 
	cprintf("%s%n", str, pret_addr+1);
f0100822:	8d 46 01             	lea    0x1(%esi),%eax
f0100825:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100829:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010082d:	c7 04 24 40 20 10 f0 	movl   $0xf0102040,(%esp)
f0100834:	e8 76 04 00 00       	call   f0100caf <cprintf>
	str[targ_frag2] = '1';
f0100839:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f010083f:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f0100846:	31 

	uint32_t targ_frag3 = (targ_addr>>16) & 0xFF;
f0100847:	89 f8                	mov    %edi,%eax
f0100849:	c1 e8 10             	shr    $0x10,%eax
f010084c:	25 ff 00 00 00       	and    $0xff,%eax
f0100851:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	str[targ_frag3] = '\0';
f0100857:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f010085e:	00 
	cprintf("%s%n", str, pret_addr+2);
f010085f:	8d 46 02             	lea    0x2(%esi),%eax
f0100862:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100866:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010086a:	c7 04 24 40 20 10 f0 	movl   $0xf0102040,(%esp)
f0100871:	e8 39 04 00 00       	call   f0100caf <cprintf>
	str[targ_frag3] = '1';
f0100876:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f010087c:	c6 84 05 e8 fe ff ff 	movb   $0x31,-0x118(%ebp,%eax,1)
f0100883:	31 

	uint32_t targ_frag4 = (targ_addr>>24) & 0xFF;
	str[targ_frag4] = '\0';
f0100884:	c1 ef 18             	shr    $0x18,%edi
f0100887:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f010088e:	00 
	cprintf("%s%n\n", str, pret_addr+3);
f010088f:	83 c6 03             	add    $0x3,%esi
f0100892:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100896:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010089a:	c7 04 24 10 23 10 f0 	movl   $0xf0102310,(%esp)
f01008a1:	e8 09 04 00 00       	call   f0100caf <cprintf>
	str[targ_frag4] = '1';
}
f01008a6:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f01008ac:	5b                   	pop    %ebx
f01008ad:	5e                   	pop    %esi
f01008ae:	5f                   	pop    %edi
f01008af:	5d                   	pop    %ebp
f01008b0:	c3                   	ret    

f01008b1 <overflow_me>:

void
overflow_me(void)
{
f01008b1:	55                   	push   %ebp
f01008b2:	89 e5                	mov    %esp,%ebp
f01008b4:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f01008b7:	e8 dc fe ff ff       	call   f0100798 <start_overflow>
}
f01008bc:	c9                   	leave  
f01008bd:	c3                   	ret    

f01008be <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f01008be:	55                   	push   %ebp
f01008bf:	89 e5                	mov    %esp,%ebp
f01008c1:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f01008c4:	c7 04 24 16 23 10 f0 	movl   $0xf0102316,(%esp)
f01008cb:	e8 df 03 00 00       	call   f0100caf <cprintf>
}
f01008d0:	c9                   	leave  
f01008d1:	c3                   	ret    

f01008d2 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008d2:	55                   	push   %ebp
f01008d3:	89 e5                	mov    %esp,%ebp
f01008d5:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008d8:	c7 04 24 28 23 10 f0 	movl   $0xf0102328,(%esp)
f01008df:	e8 cb 03 00 00       	call   f0100caf <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008e4:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008eb:	00 
f01008ec:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01008f3:	f0 
f01008f4:	c7 04 24 30 24 10 f0 	movl   $0xf0102430,(%esp)
f01008fb:	e8 af 03 00 00       	call   f0100caf <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100900:	c7 44 24 08 b5 1f 10 	movl   $0x101fb5,0x8(%esp)
f0100907:	00 
f0100908:	c7 44 24 04 b5 1f 10 	movl   $0xf0101fb5,0x4(%esp)
f010090f:	f0 
f0100910:	c7 04 24 54 24 10 f0 	movl   $0xf0102454,(%esp)
f0100917:	e8 93 03 00 00       	call   f0100caf <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010091c:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f0100923:	00 
f0100924:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f010092b:	f0 
f010092c:	c7 04 24 78 24 10 f0 	movl   $0xf0102478,(%esp)
f0100933:	e8 77 03 00 00       	call   f0100caf <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100938:	c7 44 24 08 60 39 11 	movl   $0x113960,0x8(%esp)
f010093f:	00 
f0100940:	c7 44 24 04 60 39 11 	movl   $0xf0113960,0x4(%esp)
f0100947:	f0 
f0100948:	c7 04 24 9c 24 10 f0 	movl   $0xf010249c,(%esp)
f010094f:	e8 5b 03 00 00       	call   f0100caf <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100954:	b8 5f 3d 11 f0       	mov    $0xf0113d5f,%eax
f0100959:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010095e:	89 c2                	mov    %eax,%edx
f0100960:	c1 fa 1f             	sar    $0x1f,%edx
f0100963:	c1 ea 16             	shr    $0x16,%edx
f0100966:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100969:	c1 f8 0a             	sar    $0xa,%eax
f010096c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100970:	c7 04 24 c0 24 10 f0 	movl   $0xf01024c0,(%esp)
f0100977:	e8 33 03 00 00       	call   f0100caf <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010097c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100981:	c9                   	leave  
f0100982:	c3                   	ret    

f0100983 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100983:	55                   	push   %ebp
f0100984:	89 e5                	mov    %esp,%ebp
f0100986:	57                   	push   %edi
f0100987:	56                   	push   %esi
f0100988:	53                   	push   %ebx
f0100989:	83 ec 1c             	sub    $0x1c,%esp
f010098c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100991:	be e4 25 10 f0       	mov    $0xf01025e4,%esi
f0100996:	bf e0 25 10 f0       	mov    $0xf01025e0,%edi
f010099b:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f010099e:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a2:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f01009a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a9:	c7 04 24 41 23 10 f0 	movl   $0xf0102341,(%esp)
f01009b0:	e8 fa 02 00 00       	call   f0100caf <cprintf>
f01009b5:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01009b8:	83 fb 30             	cmp    $0x30,%ebx
f01009bb:	75 de                	jne    f010099b <mon_help+0x18>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01009bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c2:	83 c4 1c             	add    $0x1c,%esp
f01009c5:	5b                   	pop    %ebx
f01009c6:	5e                   	pop    %esi
f01009c7:	5f                   	pop    %edi
f01009c8:	5d                   	pop    %ebp
f01009c9:	c3                   	ret    

f01009ca <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009ca:	55                   	push   %ebp
f01009cb:	89 e5                	mov    %esp,%ebp
f01009cd:	57                   	push   %edi
f01009ce:	56                   	push   %esi
f01009cf:	53                   	push   %ebx
f01009d0:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009d3:	c7 04 24 ec 24 10 f0 	movl   $0xf01024ec,(%esp)
f01009da:	e8 d0 02 00 00       	call   f0100caf <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009df:	c7 04 24 10 25 10 f0 	movl   $0xf0102510,(%esp)
f01009e6:	e8 c4 02 00 00       	call   f0100caf <cprintf>


	while (1) {
		buf = readline("K> ");
f01009eb:	c7 04 24 4a 23 10 f0 	movl   $0xf010234a,(%esp)
f01009f2:	e8 69 0e 00 00       	call   f0101860 <readline>
f01009f7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009f9:	85 c0                	test   %eax,%eax
f01009fb:	74 ee                	je     f01009eb <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009fd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100a04:	be 00 00 00 00       	mov    $0x0,%esi
f0100a09:	eb 06                	jmp    f0100a11 <monitor+0x47>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a0b:	c6 03 00             	movb   $0x0,(%ebx)
f0100a0e:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a11:	0f b6 03             	movzbl (%ebx),%eax
f0100a14:	84 c0                	test   %al,%al
f0100a16:	74 6a                	je     f0100a82 <monitor+0xb8>
f0100a18:	0f be c0             	movsbl %al,%eax
f0100a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1f:	c7 04 24 4e 23 10 f0 	movl   $0xf010234e,(%esp)
f0100a26:	e8 63 10 00 00       	call   f0101a8e <strchr>
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	75 dc                	jne    f0100a0b <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100a2f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a32:	74 4e                	je     f0100a82 <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a34:	83 fe 0f             	cmp    $0xf,%esi
f0100a37:	75 16                	jne    f0100a4f <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a39:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a40:	00 
f0100a41:	c7 04 24 53 23 10 f0 	movl   $0xf0102353,(%esp)
f0100a48:	e8 62 02 00 00       	call   f0100caf <cprintf>
f0100a4d:	eb 9c                	jmp    f01009eb <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100a4f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a53:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a56:	0f b6 03             	movzbl (%ebx),%eax
f0100a59:	84 c0                	test   %al,%al
f0100a5b:	75 0c                	jne    f0100a69 <monitor+0x9f>
f0100a5d:	eb b2                	jmp    f0100a11 <monitor+0x47>
			buf++;
f0100a5f:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a62:	0f b6 03             	movzbl (%ebx),%eax
f0100a65:	84 c0                	test   %al,%al
f0100a67:	74 a8                	je     f0100a11 <monitor+0x47>
f0100a69:	0f be c0             	movsbl %al,%eax
f0100a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a70:	c7 04 24 4e 23 10 f0 	movl   $0xf010234e,(%esp)
f0100a77:	e8 12 10 00 00       	call   f0101a8e <strchr>
f0100a7c:	85 c0                	test   %eax,%eax
f0100a7e:	74 df                	je     f0100a5f <monitor+0x95>
f0100a80:	eb 8f                	jmp    f0100a11 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f0100a82:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a89:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a8a:	85 f6                	test   %esi,%esi
f0100a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100a90:	0f 84 55 ff ff ff    	je     f01009eb <monitor+0x21>
f0100a96:	bb e0 25 10 f0       	mov    $0xf01025e0,%ebx
f0100a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa0:	8b 03                	mov    (%ebx),%eax
f0100aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100aa9:	89 04 24             	mov    %eax,(%esp)
f0100aac:	e8 68 0f 00 00       	call   f0101a19 <strcmp>
f0100ab1:	85 c0                	test   %eax,%eax
f0100ab3:	75 23                	jne    f0100ad8 <monitor+0x10e>
			return commands[i].func(argc, argv, tf);
f0100ab5:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100ab8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100abb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100abf:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ac6:	89 34 24             	mov    %esi,(%esp)
f0100ac9:	ff 97 e8 25 10 f0    	call   *-0xfefda18(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100acf:	85 c0                	test   %eax,%eax
f0100ad1:	78 28                	js     f0100afb <monitor+0x131>
f0100ad3:	e9 13 ff ff ff       	jmp    f01009eb <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ad8:	83 c7 01             	add    $0x1,%edi
f0100adb:	83 c3 0c             	add    $0xc,%ebx
f0100ade:	83 ff 04             	cmp    $0x4,%edi
f0100ae1:	75 bd                	jne    f0100aa0 <monitor+0xd6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ae3:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aea:	c7 04 24 70 23 10 f0 	movl   $0xf0102370,(%esp)
f0100af1:	e8 b9 01 00 00       	call   f0100caf <cprintf>
f0100af6:	e9 f0 fe ff ff       	jmp    f01009eb <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100afb:	83 c4 5c             	add    $0x5c,%esp
f0100afe:	5b                   	pop    %ebx
f0100aff:	5e                   	pop    %esi
f0100b00:	5f                   	pop    %edi
f0100b01:	5d                   	pop    %ebp
f0100b02:	c3                   	ret    

f0100b03 <mon_time>:
}

/* stone's solution for exercise17 */
int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100b03:	55                   	push   %ebp
f0100b04:	89 e5                	mov    %esp,%ebp
f0100b06:	57                   	push   %edi
f0100b07:	56                   	push   %esi
f0100b08:	53                   	push   %ebx
f0100b09:	83 ec 2c             	sub    $0x2c,%esp
	if (argc == 1){
f0100b0c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100b10:	75 16                	jne    f0100b28 <mon_time+0x25>
		cprintf("Usage: time [command]\n");
f0100b12:	c7 04 24 86 23 10 f0 	movl   $0xf0102386,(%esp)
f0100b19:	e8 91 01 00 00       	call   f0100caf <cprintf>
f0100b1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0100b23:	e9 96 00 00 00       	jmp    f0100bbe <mon_time+0xbb>
f0100b28:	bb e0 25 10 f0       	mov    $0xf01025e0,%ebx
f0100b2d:	be 00 00 00 00       	mov    $0x0,%esi
	}
	int i;
	for (i = 0; i < NCOMMANDS; i++){
		if (strcmp(commands[i].name, argv[1]) == 0)
f0100b32:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100b35:	83 c7 04             	add    $0x4,%edi
f0100b38:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100b3b:	8b 07                	mov    (%edi),%eax
f0100b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b41:	8b 03                	mov    (%ebx),%eax
f0100b43:	89 04 24             	mov    %eax,(%esp)
f0100b46:	e8 ce 0e 00 00       	call   f0101a19 <strcmp>
f0100b4b:	85 c0                	test   %eax,%eax
f0100b4d:	74 23                	je     f0100b72 <mon_time+0x6f>
			break;
		if (i == NCOMMANDS - 1){
f0100b4f:	83 fe 03             	cmp    $0x3,%esi
f0100b52:	75 13                	jne    f0100b67 <mon_time+0x64>
			cprintf("Unkown command.\n");
f0100b54:	c7 04 24 9d 23 10 f0 	movl   $0xf010239d,(%esp)
f0100b5b:	e8 4f 01 00 00       	call   f0100caf <cprintf>
f0100b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			return -1;
f0100b65:	eb 57                	jmp    f0100bbe <mon_time+0xbb>
	if (argc == 1){
		cprintf("Usage: time [command]\n");
		return -1;
	}
	int i;
	for (i = 0; i < NCOMMANDS; i++){
f0100b67:	83 c6 01             	add    $0x1,%esi
f0100b6a:	83 c3 0c             	add    $0xc,%ebx
f0100b6d:	83 fe 04             	cmp    $0x4,%esi
f0100b70:	75 c6                	jne    f0100b38 <mon_time+0x35>

static __inline uint64_t
read_tsc(void)
{
        uint64_t tsc;
        __asm __volatile("rdtsc" : "=A" (tsc));
f0100b72:	0f 31                	rdtsc  
f0100b74:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b77:	89 55 dc             	mov    %edx,-0x24(%ebp)
			return -1;
		}
	}

	uint32_t begin = read_tsc();
	commands[i].func(argc-1, argv+1, tf);
f0100b7a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100b7d:	8b 55 10             	mov    0x10(%ebp),%edx
f0100b80:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100b84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b87:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100b8b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100b8e:	83 ea 01             	sub    $0x1,%edx
f0100b91:	89 14 24             	mov    %edx,(%esp)
f0100b94:	ff 14 85 e8 25 10 f0 	call   *-0xfefda18(,%eax,4)
f0100b9b:	0f 31                	rdtsc  
	uint32_t end = read_tsc();
	cprintf("%s cycles: %llu\n", argv[1], end-begin);
f0100b9d:	2b 45 d8             	sub    -0x28(%ebp),%eax
f0100ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ba4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ba7:	8b 02                	mov    (%edx),%eax
f0100ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bad:	c7 04 24 ae 23 10 f0 	movl   $0xf01023ae,(%esp)
f0100bb4:	e8 f6 00 00 00       	call   f0100caf <cprintf>
f0100bb9:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0; 
}
f0100bbe:	83 c4 2c             	add    $0x2c,%esp
f0100bc1:	5b                   	pop    %ebx
f0100bc2:	5e                   	pop    %esi
f0100bc3:	5f                   	pop    %edi
f0100bc4:	5d                   	pop    %ebp
f0100bc5:	c3                   	ret    

f0100bc6 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100bc6:	55                   	push   %ebp
f0100bc7:	89 e5                	mov    %esp,%ebp
f0100bc9:	57                   	push   %edi
f0100bca:	56                   	push   %esi
f0100bcb:	53                   	push   %ebx
f0100bcc:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
f0100bcf:	89 eb                	mov    %ebp,%ebx
	cprintf("Stack backtrace:\n");
f0100bd1:	c7 04 24 bf 23 10 f0 	movl   $0xf01023bf,(%esp)
f0100bd8:	e8 d2 00 00 00       	call   f0100caf <cprintf>
	while (ebp != 0){
f0100bdd:	85 db                	test   %ebx,%ebx
f0100bdf:	74 7d                	je     f0100c5e <mon_backtrace+0x98>
		cprintf(" eip %08x ebp %08x args %08x %08x %08x %08x %08x\n", (uint32_t*)ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100be1:	8d 7d d0             	lea    -0x30(%ebp),%edi
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0){
		cprintf(" eip %08x ebp %08x args %08x %08x %08x %08x %08x\n", (uint32_t*)ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100be4:	8d 73 04             	lea    0x4(%ebx),%esi
f0100be7:	8b 43 18             	mov    0x18(%ebx),%eax
f0100bea:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100bee:	8b 43 14             	mov    0x14(%ebx),%eax
f0100bf1:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100bf5:	8b 43 10             	mov    0x10(%ebx),%eax
f0100bf8:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100bfc:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100bff:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c03:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c0a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100c0e:	8b 06                	mov    (%esi),%eax
f0100c10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c14:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100c1b:	e8 8f 00 00 00       	call   f0100caf <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
f0100c20:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c24:	8b 06                	mov    (%esi),%eax
f0100c26:	89 04 24             	mov    %eax,(%esp)
f0100c29:	e8 f0 01 00 00       	call   f0100e1e <debuginfo_eip>
		uint32_t offset = (int)(uint32_t*)ebp[1] - info.eip_fn_addr;
		cprintf(" 	%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);//there must be a space between ':' and '%s+%x'
f0100c2e:	8b 06                	mov    (%esi),%eax
f0100c30:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100c33:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c37:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c41:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c45:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c4c:	c7 04 24 d1 23 10 f0 	movl   $0xf01023d1,(%esp)
f0100c53:	e8 57 00 00 00       	call   f0100caf <cprintf>
		ebp = (uint32_t*)ebp[0];
f0100c58:	8b 1b                	mov    (%ebx),%ebx
	// Your code here.
	/* stone's solution for exercise14 */
	/* stone's solution for exercise15 */
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0){
f0100c5a:	85 db                	test   %ebx,%ebx
f0100c5c:	75 86                	jne    f0100be4 <mon_backtrace+0x1e>
		debuginfo_eip( (int)(uint32_t*)ebp[1], &info);
		uint32_t offset = (int)(uint32_t*)ebp[1] - info.eip_fn_addr;
		cprintf(" 	%s:%d: %s+%x\n", info.eip_file, info.eip_line, info.eip_fn_name, offset);//there must be a space between ':' and '%s+%x'
		ebp = (uint32_t*)ebp[0];
	}
    	overflow_me();
f0100c5e:	e8 4e fc ff ff       	call   f01008b1 <overflow_me>
    	cprintf("Backtrace success\n");
f0100c63:	c7 04 24 e1 23 10 f0 	movl   $0xf01023e1,(%esp)
f0100c6a:	e8 40 00 00 00       	call   f0100caf <cprintf>
	return 0;
}
f0100c6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c74:	83 c4 4c             	add    $0x4c,%esp
f0100c77:	5b                   	pop    %ebx
f0100c78:	5e                   	pop    %esi
f0100c79:	5f                   	pop    %edi
f0100c7a:	5d                   	pop    %ebp
f0100c7b:	c3                   	ret    

f0100c7c <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100c7c:	55                   	push   %ebp
f0100c7d:	89 e5                	mov    %esp,%ebp
f0100c7f:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100c82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100c89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c90:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c93:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c97:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c9e:	c7 04 24 c9 0c 10 f0 	movl   $0xf0100cc9,(%esp)
f0100ca5:	e8 35 05 00 00       	call   f01011df <vprintfmt>
	return cnt;
}
f0100caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100cad:	c9                   	leave  
f0100cae:	c3                   	ret    

f0100caf <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100caf:	55                   	push   %ebp
f0100cb0:	89 e5                	mov    %esp,%ebp
f0100cb2:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0100cb5:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cbc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cbf:	89 04 24             	mov    %eax,(%esp)
f0100cc2:	e8 b5 ff ff ff       	call   f0100c7c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100cc7:	c9                   	leave  
f0100cc8:	c3                   	ret    

f0100cc9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100cc9:	55                   	push   %ebp
f0100cca:	89 e5                	mov    %esp,%ebp
f0100ccc:	53                   	push   %ebx
f0100ccd:	83 ec 14             	sub    $0x14,%esp
f0100cd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100cd3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cd6:	89 04 24             	mov    %eax,(%esp)
f0100cd9:	e8 ac f8 ff ff       	call   f010058a <cputchar>
    (*cnt)++;
f0100cde:	83 03 01             	addl   $0x1,(%ebx)
}
f0100ce1:	83 c4 14             	add    $0x14,%esp
f0100ce4:	5b                   	pop    %ebx
f0100ce5:	5d                   	pop    %ebp
f0100ce6:	c3                   	ret    
	...

f0100cf0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100cf0:	55                   	push   %ebp
f0100cf1:	89 e5                	mov    %esp,%ebp
f0100cf3:	57                   	push   %edi
f0100cf4:	56                   	push   %esi
f0100cf5:	53                   	push   %ebx
f0100cf6:	83 ec 14             	sub    $0x14,%esp
f0100cf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100cfc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100cff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d02:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100d05:	8b 1a                	mov    (%edx),%ebx
f0100d07:	8b 01                	mov    (%ecx),%eax
f0100d09:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0100d0c:	39 c3                	cmp    %eax,%ebx
f0100d0e:	0f 8f 9c 00 00 00    	jg     f0100db0 <stab_binsearch+0xc0>
f0100d14:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100d1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100d1e:	01 d8                	add    %ebx,%eax
f0100d20:	89 c7                	mov    %eax,%edi
f0100d22:	c1 ef 1f             	shr    $0x1f,%edi
f0100d25:	01 c7                	add    %eax,%edi
f0100d27:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d29:	39 df                	cmp    %ebx,%edi
f0100d2b:	7c 33                	jl     f0100d60 <stab_binsearch+0x70>
f0100d2d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d30:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100d33:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100d38:	39 f0                	cmp    %esi,%eax
f0100d3a:	0f 84 bc 00 00 00    	je     f0100dfc <stab_binsearch+0x10c>
f0100d40:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0100d44:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0100d48:	89 f8                	mov    %edi,%eax
			m--;
f0100d4a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d4d:	39 d8                	cmp    %ebx,%eax
f0100d4f:	7c 0f                	jl     f0100d60 <stab_binsearch+0x70>
f0100d51:	0f b6 0a             	movzbl (%edx),%ecx
f0100d54:	83 ea 0c             	sub    $0xc,%edx
f0100d57:	39 f1                	cmp    %esi,%ecx
f0100d59:	75 ef                	jne    f0100d4a <stab_binsearch+0x5a>
f0100d5b:	e9 9e 00 00 00       	jmp    f0100dfe <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100d60:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100d63:	eb 3c                	jmp    f0100da1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100d65:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100d68:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100d6a:	8d 5f 01             	lea    0x1(%edi),%ebx
f0100d6d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100d74:	eb 2b                	jmp    f0100da1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0100d76:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100d79:	76 14                	jbe    f0100d8f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0100d7b:	83 e8 01             	sub    $0x1,%eax
f0100d7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100d81:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d84:	89 02                	mov    %eax,(%edx)
f0100d86:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100d8d:	eb 12                	jmp    f0100da1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100d8f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100d92:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100d94:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100d98:	89 c3                	mov    %eax,%ebx
f0100d9a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100da1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100da4:	0f 8d 71 ff ff ff    	jge    f0100d1b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100daa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100dae:	75 0f                	jne    f0100dbf <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0100db0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100db3:	8b 03                	mov    (%ebx),%eax
f0100db5:	83 e8 01             	sub    $0x1,%eax
f0100db8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100dbb:	89 02                	mov    %eax,(%edx)
f0100dbd:	eb 57                	jmp    f0100e16 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100dbf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100dc2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100dc4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100dc7:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100dc9:	39 c1                	cmp    %eax,%ecx
f0100dcb:	7d 28                	jge    f0100df5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100dcd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100dd0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100dd3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100dd8:	39 f2                	cmp    %esi,%edx
f0100dda:	74 19                	je     f0100df5 <stab_binsearch+0x105>
f0100ddc:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0100de0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0100de4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100de7:	39 c1                	cmp    %eax,%ecx
f0100de9:	7d 0a                	jge    f0100df5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100deb:	0f b6 1a             	movzbl (%edx),%ebx
f0100dee:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100df1:	39 f3                	cmp    %esi,%ebx
f0100df3:	75 ef                	jne    f0100de4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0100df5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100df8:	89 02                	mov    %eax,(%edx)
f0100dfa:	eb 1a                	jmp    f0100e16 <stab_binsearch+0x126>
	}
}
f0100dfc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100dfe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e01:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100e04:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100e08:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100e0b:	0f 82 54 ff ff ff    	jb     f0100d65 <stab_binsearch+0x75>
f0100e11:	e9 60 ff ff ff       	jmp    f0100d76 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100e16:	83 c4 14             	add    $0x14,%esp
f0100e19:	5b                   	pop    %ebx
f0100e1a:	5e                   	pop    %esi
f0100e1b:	5f                   	pop    %edi
f0100e1c:	5d                   	pop    %ebp
f0100e1d:	c3                   	ret    

f0100e1e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100e1e:	55                   	push   %ebp
f0100e1f:	89 e5                	mov    %esp,%ebp
f0100e21:	83 ec 48             	sub    $0x48,%esp
f0100e24:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100e27:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100e2a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100e2d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100e33:	c7 03 10 26 10 f0    	movl   $0xf0102610,(%ebx)
	info->eip_line = 0;
f0100e39:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100e40:	c7 43 08 10 26 10 f0 	movl   $0xf0102610,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100e47:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100e4e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100e51:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100e58:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100e5e:	76 12                	jbe    f0100e72 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e60:	b8 22 86 10 f0       	mov    $0xf0108622,%eax
f0100e65:	3d 71 6a 10 f0       	cmp    $0xf0106a71,%eax
f0100e6a:	0f 86 a2 01 00 00    	jbe    f0101012 <debuginfo_eip+0x1f4>
f0100e70:	eb 1c                	jmp    f0100e8e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100e72:	c7 44 24 08 1a 26 10 	movl   $0xf010261a,0x8(%esp)
f0100e79:	f0 
f0100e7a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100e81:	00 
f0100e82:	c7 04 24 27 26 10 f0 	movl   $0xf0102627,(%esp)
f0100e89:	e8 f7 f1 ff ff       	call   f0100085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e8e:	80 3d 21 86 10 f0 00 	cmpb   $0x0,0xf0108621
f0100e95:	0f 85 77 01 00 00    	jne    f0101012 <debuginfo_eip+0x1f4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100e9b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ea2:	b8 70 6a 10 f0       	mov    $0xf0106a70,%eax
f0100ea7:	2d c4 28 10 f0       	sub    $0xf01028c4,%eax
f0100eac:	c1 f8 02             	sar    $0x2,%eax
f0100eaf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100eb5:	83 e8 01             	sub    $0x1,%eax
f0100eb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100ebb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100ebe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100ec1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ec5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100ecc:	b8 c4 28 10 f0       	mov    $0xf01028c4,%eax
f0100ed1:	e8 1a fe ff ff       	call   f0100cf0 <stab_binsearch>
	if (lfile == 0)
f0100ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ed9:	85 c0                	test   %eax,%eax
f0100edb:	0f 84 31 01 00 00    	je     f0101012 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ee1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ee4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ee7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100eea:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100eed:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ef0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ef4:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100efb:	b8 c4 28 10 f0       	mov    $0xf01028c4,%eax
f0100f00:	e8 eb fd ff ff       	call   f0100cf0 <stab_binsearch>

	if (lfun <= rfun) {
f0100f05:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f08:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100f0b:	7f 3c                	jg     f0100f49 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100f0d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100f10:	8b 80 c4 28 10 f0    	mov    -0xfefd73c(%eax),%eax
f0100f16:	ba 22 86 10 f0       	mov    $0xf0108622,%edx
f0100f1b:	81 ea 71 6a 10 f0    	sub    $0xf0106a71,%edx
f0100f21:	39 d0                	cmp    %edx,%eax
f0100f23:	73 08                	jae    f0100f2d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100f25:	05 71 6a 10 f0       	add    $0xf0106a71,%eax
f0100f2a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100f2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f30:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100f33:	8b 92 cc 28 10 f0    	mov    -0xfefd734(%edx),%edx
f0100f39:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100f3c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100f3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100f41:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f44:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f47:	eb 0f                	jmp    f0100f58 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100f49:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100f52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f55:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100f58:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100f5f:	00 
f0100f60:	8b 43 08             	mov    0x8(%ebx),%eax
f0100f63:	89 04 24             	mov    %eax,(%esp)
f0100f66:	e8 50 0b 00 00       	call   f0101abb <strfind>
f0100f6b:	2b 43 08             	sub    0x8(%ebx),%eax
f0100f6e:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	/* stone's solution for exercise15 */
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100f71:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100f74:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100f77:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f7b:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100f82:	b8 c4 28 10 f0       	mov    $0xf01028c4,%eax
f0100f87:	e8 64 fd ff ff       	call   f0100cf0 <stab_binsearch>
	if (lline <= rline)
f0100f8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f8f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100f92:	0f 8f 7a 00 00 00    	jg     f0101012 <debuginfo_eip+0x1f4>
		info->eip_line = stabs[lline].n_desc;
f0100f98:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100f9b:	0f b7 80 ca 28 10 f0 	movzwl -0xfefd736(%eax),%eax
f0100fa2:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0100fa5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fa8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100fab:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100fae:	81 c2 cc 28 10 f0    	add    $0xf01028cc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100fb4:	eb 06                	jmp    f0100fbc <debuginfo_eip+0x19e>
f0100fb6:	83 e8 01             	sub    $0x1,%eax
f0100fb9:	83 ea 0c             	sub    $0xc,%edx
f0100fbc:	89 c6                	mov    %eax,%esi
f0100fbe:	39 f8                	cmp    %edi,%eax
f0100fc0:	7c 1f                	jl     f0100fe1 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100fc2:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100fc6:	80 f9 84             	cmp    $0x84,%cl
f0100fc9:	74 60                	je     f010102b <debuginfo_eip+0x20d>
f0100fcb:	80 f9 64             	cmp    $0x64,%cl
f0100fce:	75 e6                	jne    f0100fb6 <debuginfo_eip+0x198>
f0100fd0:	83 3a 00             	cmpl   $0x0,(%edx)
f0100fd3:	74 e1                	je     f0100fb6 <debuginfo_eip+0x198>
f0100fd5:	8d 76 00             	lea    0x0(%esi),%esi
f0100fd8:	eb 51                	jmp    f010102b <debuginfo_eip+0x20d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100fda:	05 71 6a 10 f0       	add    $0xf0106a71,%eax
f0100fdf:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100fe1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fe4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100fe7:	7d 30                	jge    f0101019 <debuginfo_eip+0x1fb>
		for (lline = lfun + 1;
f0100fe9:	83 c0 01             	add    $0x1,%eax
f0100fec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100fef:	ba c4 28 10 f0       	mov    $0xf01028c4,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100ff4:	eb 08                	jmp    f0100ffe <debuginfo_eip+0x1e0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100ff6:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100ffa:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ffe:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101001:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0101004:	7d 13                	jge    f0101019 <debuginfo_eip+0x1fb>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101006:	6b c0 0c             	imul   $0xc,%eax,%eax
f0101009:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f010100e:	74 e6                	je     f0100ff6 <debuginfo_eip+0x1d8>
f0101010:	eb 07                	jmp    f0101019 <debuginfo_eip+0x1fb>
f0101012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101017:	eb 05                	jmp    f010101e <debuginfo_eip+0x200>
f0101019:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f010101e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101021:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101024:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101027:	89 ec                	mov    %ebp,%esp
f0101029:	5d                   	pop    %ebp
f010102a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010102b:	6b c6 0c             	imul   $0xc,%esi,%eax
f010102e:	8b 80 c4 28 10 f0    	mov    -0xfefd73c(%eax),%eax
f0101034:	ba 22 86 10 f0       	mov    $0xf0108622,%edx
f0101039:	81 ea 71 6a 10 f0    	sub    $0xf0106a71,%edx
f010103f:	39 d0                	cmp    %edx,%eax
f0101041:	72 97                	jb     f0100fda <debuginfo_eip+0x1bc>
f0101043:	eb 9c                	jmp    f0100fe1 <debuginfo_eip+0x1c3>
	...

f0101050 <_printnum>:
 */
/* stone's solution for exercise11 */
static int
_printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101050:	55                   	push   %ebp
f0101051:	89 e5                	mov    %esp,%ebp
f0101053:	57                   	push   %edi
f0101054:	56                   	push   %esi
f0101055:	53                   	push   %ebx
f0101056:	83 ec 4c             	sub    $0x4c,%esp
f0101059:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010105c:	89 d6                	mov    %edx,%esi
f010105e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101061:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101067:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010106a:	8b 45 10             	mov    0x10(%ebp),%eax
f010106d:	8b 7d 18             	mov    0x18(%ebp),%edi
	int w = width;
	if (num >= base) {
f0101070:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101073:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101078:	39 d1                	cmp    %edx,%ecx
f010107a:	72 07                	jb     f0101083 <_printnum+0x33>
f010107c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010107f:	39 d8                	cmp    %ebx,%eax
f0101081:	77 64                	ja     f01010e7 <_printnum+0x97>
		w = _printnum(putch, putdat, num / base, base, width - 1, padc);
f0101083:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0101087:	8b 7d 14             	mov    0x14(%ebp),%edi
f010108a:	83 ef 01             	sub    $0x1,%edi
f010108d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101091:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101095:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101099:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010109d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01010a6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01010aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01010b1:	00 
f01010b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01010b5:	89 0c 24             	mov    %ecx,(%esp)
f01010b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01010bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010bf:	e8 8c 0c 00 00       	call   f0101d50 <__udivdi3>
f01010c4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01010c7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01010ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01010ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01010d2:	89 04 24             	mov    %eax,(%esp)
f01010d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010d9:	89 f2                	mov    %esi,%edx
f01010db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010de:	e8 6d ff ff ff       	call   f0101050 <_printnum>
f01010e3:	89 c7                	mov    %eax,%edi
f01010e5:	eb 23                	jmp    f010110a <_printnum+0xba>
	} else if (padc != '-'){
f01010e7:	83 ff 2d             	cmp    $0x2d,%edi
f01010ea:	74 1b                	je     f0101107 <_printnum+0xb7>
		// print any needed pad characters before first digit
		while (--width > 0)
f01010ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01010ef:	83 eb 01             	sub    $0x1,%ebx
f01010f2:	85 db                	test   %ebx,%ebx
f01010f4:	7e 11                	jle    f0101107 <_printnum+0xb7>
			putch(padc, putdat);
f01010f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010fa:	89 3c 24             	mov    %edi,(%esp)
f01010fd:	ff 55 e4             	call   *-0x1c(%ebp)
	int w = width;
	if (num >= base) {
		w = _printnum(putch, putdat, num / base, base, width - 1, padc);
	} else if (padc != '-'){
		// print any needed pad characters before first digit
		while (--width > 0)
f0101100:	83 eb 01             	sub    $0x1,%ebx
f0101103:	85 db                	test   %ebx,%ebx
f0101105:	7f ef                	jg     f01010f6 <_printnum+0xa6>
f0101107:	8b 7d 14             	mov    0x14(%ebp),%edi
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010110a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010110e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101112:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101115:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101119:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101120:	00 
f0101121:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101124:	89 14 24             	mov    %edx,(%esp)
f0101127:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010112a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010112e:	e8 4d 0d 00 00       	call   f0101e80 <__umoddi3>
f0101133:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101137:	0f be 80 35 26 10 f0 	movsbl -0xfefd9cb(%eax),%eax
f010113e:	89 04 24             	mov    %eax,(%esp)
f0101141:	ff 55 e4             	call   *-0x1c(%ebp)
	return w;
}
f0101144:	89 f8                	mov    %edi,%eax
f0101146:	83 c4 4c             	add    $0x4c,%esp
f0101149:	5b                   	pop    %ebx
f010114a:	5e                   	pop    %esi
f010114b:	5f                   	pop    %edi
f010114c:	5d                   	pop    %ebp
f010114d:	c3                   	ret    

f010114e <getuint>:
}
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010114e:	55                   	push   %ebp
f010114f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101151:	83 fa 01             	cmp    $0x1,%edx
f0101154:	7e 0e                	jle    f0101164 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101156:	8b 10                	mov    (%eax),%edx
f0101158:	8d 4a 08             	lea    0x8(%edx),%ecx
f010115b:	89 08                	mov    %ecx,(%eax)
f010115d:	8b 02                	mov    (%edx),%eax
f010115f:	8b 52 04             	mov    0x4(%edx),%edx
f0101162:	eb 22                	jmp    f0101186 <getuint+0x38>
	else if (lflag)
f0101164:	85 d2                	test   %edx,%edx
f0101166:	74 10                	je     f0101178 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101168:	8b 10                	mov    (%eax),%edx
f010116a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010116d:	89 08                	mov    %ecx,(%eax)
f010116f:	8b 02                	mov    (%edx),%eax
f0101171:	ba 00 00 00 00       	mov    $0x0,%edx
f0101176:	eb 0e                	jmp    f0101186 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101178:	8b 10                	mov    (%eax),%edx
f010117a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010117d:	89 08                	mov    %ecx,(%eax)
f010117f:	8b 02                	mov    (%edx),%eax
f0101181:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101186:	5d                   	pop    %ebp
f0101187:	c3                   	ret    

f0101188 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0101188:	55                   	push   %ebp
f0101189:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010118b:	83 fa 01             	cmp    $0x1,%edx
f010118e:	7e 0e                	jle    f010119e <getint+0x16>
		return va_arg(*ap, long long);
f0101190:	8b 10                	mov    (%eax),%edx
f0101192:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101195:	89 08                	mov    %ecx,(%eax)
f0101197:	8b 02                	mov    (%edx),%eax
f0101199:	8b 52 04             	mov    0x4(%edx),%edx
f010119c:	eb 22                	jmp    f01011c0 <getint+0x38>
	else if (lflag)
f010119e:	85 d2                	test   %edx,%edx
f01011a0:	74 10                	je     f01011b2 <getint+0x2a>
		return va_arg(*ap, long);
f01011a2:	8b 10                	mov    (%eax),%edx
f01011a4:	8d 4a 04             	lea    0x4(%edx),%ecx
f01011a7:	89 08                	mov    %ecx,(%eax)
f01011a9:	8b 02                	mov    (%edx),%eax
f01011ab:	89 c2                	mov    %eax,%edx
f01011ad:	c1 fa 1f             	sar    $0x1f,%edx
f01011b0:	eb 0e                	jmp    f01011c0 <getint+0x38>
	else
		return va_arg(*ap, int);
f01011b2:	8b 10                	mov    (%eax),%edx
f01011b4:	8d 4a 04             	lea    0x4(%edx),%ecx
f01011b7:	89 08                	mov    %ecx,(%eax)
f01011b9:	8b 02                	mov    (%edx),%eax
f01011bb:	89 c2                	mov    %eax,%edx
f01011bd:	c1 fa 1f             	sar    $0x1f,%edx
}
f01011c0:	5d                   	pop    %ebp
f01011c1:	c3                   	ret    

f01011c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01011c2:	55                   	push   %ebp
f01011c3:	89 e5                	mov    %esp,%ebp
f01011c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01011c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01011cc:	8b 10                	mov    (%eax),%edx
f01011ce:	3b 50 04             	cmp    0x4(%eax),%edx
f01011d1:	73 0a                	jae    f01011dd <sprintputch+0x1b>
		*b->buf++ = ch;
f01011d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011d6:	88 0a                	mov    %cl,(%edx)
f01011d8:	83 c2 01             	add    $0x1,%edx
f01011db:	89 10                	mov    %edx,(%eax)
}
f01011dd:	5d                   	pop    %ebp
f01011de:	c3                   	ret    

f01011df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01011df:	55                   	push   %ebp
f01011e0:	89 e5                	mov    %esp,%ebp
f01011e2:	57                   	push   %edi
f01011e3:	56                   	push   %esi
f01011e4:	53                   	push   %ebx
f01011e5:	83 ec 5c             	sub    $0x5c,%esp
f01011e8:	8b 7d 10             	mov    0x10(%ebp),%edi
f01011eb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011f0:	be 00 00 00 00       	mov    $0x0,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01011f5:	c7 45 c0 ff ff ff ff 	movl   $0xffffffff,-0x40(%ebp)
f01011fc:	eb 1a                	jmp    f0101218 <vprintfmt+0x39>
	int base, lflag, width, precision, altflag, pflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01011fe:	85 c0                	test   %eax,%eax
f0101200:	0f 84 a0 05 00 00    	je     f01017a6 <vprintfmt+0x5c7>
				return;
			putch(ch, putdat);
f0101206:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101209:	89 54 24 04          	mov    %edx,0x4(%esp)
f010120d:	89 04 24             	mov    %eax,(%esp)
f0101210:	ff 55 08             	call   *0x8(%ebp)
f0101213:	eb 03                	jmp    f0101218 <vprintfmt+0x39>
f0101215:	8b 7d e0             	mov    -0x20(%ebp),%edi
	unsigned long long num = 0;
	int base, lflag, width, precision, altflag, pflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101218:	0f b6 07             	movzbl (%edi),%eax
f010121b:	83 c7 01             	add    $0x1,%edi
f010121e:	83 f8 25             	cmp    $0x25,%eax
f0101221:	75 db                	jne    f01011fe <vprintfmt+0x1f>
f0101223:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0101227:	b9 00 00 00 00       	mov    $0x0,%ecx
f010122c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101233:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
f010123a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0101241:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0101248:	eb 06                	jmp    f0101250 <vprintfmt+0x71>
f010124a:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f010124e:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
		pflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101250:	0f b6 17             	movzbl (%edi),%edx
f0101253:	0f b6 c2             	movzbl %dl,%eax
f0101256:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101259:	8d 47 01             	lea    0x1(%edi),%eax
f010125c:	83 ea 23             	sub    $0x23,%edx
f010125f:	80 fa 55             	cmp    $0x55,%dl
f0101262:	0f 87 1d 05 00 00    	ja     f0101785 <vprintfmt+0x5a6>
f0101268:	0f b6 d2             	movzbl %dl,%edx
f010126b:	ff 24 95 40 27 10 f0 	jmp    *-0xfefd8c0(,%edx,4)
f0101272:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0101276:	eb d6                	jmp    f010124e <vprintfmt+0x6f>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101278:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010127b:	83 ea 30             	sub    $0x30,%edx
f010127e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0101281:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0101284:	8d 7a d0             	lea    -0x30(%edx),%edi
f0101287:	83 ff 09             	cmp    $0x9,%edi
f010128a:	76 09                	jbe    f0101295 <vprintfmt+0xb6>
f010128c:	eb 60                	jmp    f01012ee <vprintfmt+0x10f>
f010128e:	b9 01 00 00 00       	mov    $0x1,%ecx
			padc = '0';
			goto reswitch;
		/* stone's solution for exercise9 */
		case '+':
			pflag = 1;
			goto reswitch;
f0101293:	eb b9                	jmp    f010124e <vprintfmt+0x6f>
f0101295:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0101298:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f010129b:	89 cb                	mov    %ecx,%ebx
f010129d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01012a0:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f01012a3:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01012a6:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f01012aa:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01012ad:	8d 72 d0             	lea    -0x30(%edx),%esi
f01012b0:	83 fe 09             	cmp    $0x9,%esi
f01012b3:	76 eb                	jbe    f01012a0 <vprintfmt+0xc1>
f01012b5:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01012b8:	89 d9                	mov    %ebx,%ecx
f01012ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01012bd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01012c0:	eb 2c                	jmp    f01012ee <vprintfmt+0x10f>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01012c2:	8b 55 14             	mov    0x14(%ebp),%edx
f01012c5:	8d 7a 04             	lea    0x4(%edx),%edi
f01012c8:	89 7d 14             	mov    %edi,0x14(%ebp)
f01012cb:	8b 12                	mov    (%edx),%edx
f01012cd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
			goto process_precision;
f01012d0:	eb 1c                	jmp    f01012ee <vprintfmt+0x10f>

		case '.':
			if (width < 0)
f01012d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01012d5:	c1 fa 1f             	sar    $0x1f,%edx
f01012d8:	f7 d2                	not    %edx
f01012da:	21 55 d4             	and    %edx,-0x2c(%ebp)
f01012dd:	e9 6c ff ff ff       	jmp    f010124e <vprintfmt+0x6f>
f01012e2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01012e9:	e9 60 ff ff ff       	jmp    f010124e <vprintfmt+0x6f>

		process_precision:
			if (width < 0)
f01012ee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01012f2:	0f 89 56 ff ff ff    	jns    f010124e <vprintfmt+0x6f>
f01012f8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01012fb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01012fe:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0101301:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0101304:	e9 45 ff ff ff       	jmp    f010124e <vprintfmt+0x6f>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101309:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
			goto reswitch;
f010130d:	e9 3c ff ff ff       	jmp    f010124e <vprintfmt+0x6f>
f0101312:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101315:	8b 45 14             	mov    0x14(%ebp),%eax
f0101318:	8d 50 04             	lea    0x4(%eax),%edx
f010131b:	89 55 14             	mov    %edx,0x14(%ebp)
f010131e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101321:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101325:	8b 00                	mov    (%eax),%eax
f0101327:	89 04 24             	mov    %eax,(%esp)
f010132a:	ff 55 08             	call   *0x8(%ebp)
f010132d:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;
f0101330:	e9 e3 fe ff ff       	jmp    f0101218 <vprintfmt+0x39>
f0101335:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101338:	8b 45 14             	mov    0x14(%ebp),%eax
f010133b:	8d 50 04             	lea    0x4(%eax),%edx
f010133e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101341:	8b 00                	mov    (%eax),%eax
f0101343:	89 c2                	mov    %eax,%edx
f0101345:	c1 fa 1f             	sar    $0x1f,%edx
f0101348:	31 d0                	xor    %edx,%eax
f010134a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010134c:	83 f8 06             	cmp    $0x6,%eax
f010134f:	7f 0b                	jg     f010135c <vprintfmt+0x17d>
f0101351:	8b 14 85 98 28 10 f0 	mov    -0xfefd768(,%eax,4),%edx
f0101358:	85 d2                	test   %edx,%edx
f010135a:	75 26                	jne    f0101382 <vprintfmt+0x1a3>
				printfmt(putch, putdat, "error %d", err);
f010135c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101360:	c7 44 24 08 46 26 10 	movl   $0xf0102646,0x8(%esp)
f0101367:	f0 
f0101368:	8b 45 0c             	mov    0xc(%ebp),%eax
f010136b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010136f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101372:	89 14 24             	mov    %edx,(%esp)
f0101375:	e8 b4 04 00 00       	call   f010182e <printfmt>
f010137a:	8b 7d e0             	mov    -0x20(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010137d:	e9 96 fe ff ff       	jmp    f0101218 <vprintfmt+0x39>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0101382:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101386:	c7 44 24 08 4f 26 10 	movl   $0xf010264f,0x8(%esp)
f010138d:	f0 
f010138e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101391:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101395:	8b 55 08             	mov    0x8(%ebp),%edx
f0101398:	89 14 24             	mov    %edx,(%esp)
f010139b:	e8 8e 04 00 00       	call   f010182e <printfmt>
f01013a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01013a3:	e9 70 fe ff ff       	jmp    f0101218 <vprintfmt+0x39>
f01013a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01013ab:	89 c7                	mov    %eax,%edi
f01013ad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01013b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013b3:	89 45 b8             	mov    %eax,-0x48(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01013b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b9:	8d 50 04             	lea    0x4(%eax),%edx
f01013bc:	89 55 14             	mov    %edx,0x14(%ebp)
f01013bf:	8b 00                	mov    (%eax),%eax
f01013c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01013c4:	85 c0                	test   %eax,%eax
f01013c6:	75 07                	jne    f01013cf <vprintfmt+0x1f0>
f01013c8:	c7 45 c8 52 26 10 f0 	movl   $0xf0102652,-0x38(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f01013cf:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
f01013d3:	7e 06                	jle    f01013db <vprintfmt+0x1fc>
f01013d5:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f01013d9:	75 13                	jne    f01013ee <vprintfmt+0x20f>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01013db:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01013de:	0f be 02             	movsbl (%edx),%eax
f01013e1:	85 c0                	test   %eax,%eax
f01013e3:	0f 85 ab 00 00 00    	jne    f0101494 <vprintfmt+0x2b5>
f01013e9:	e9 9b 00 00 00       	jmp    f0101489 <vprintfmt+0x2aa>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01013ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01013f2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01013f5:	89 04 24             	mov    %eax,(%esp)
f01013f8:	e8 5e 05 00 00       	call   f010195b <strnlen>
f01013fd:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0101400:	29 c2                	sub    %eax,%edx
f0101402:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101405:	85 d2                	test   %edx,%edx
f0101407:	7e d2                	jle    f01013db <vprintfmt+0x1fc>
					putch(padc, putdat);
f0101409:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f010140d:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0101410:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0101413:	89 d3                	mov    %edx,%ebx
f0101415:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101418:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010141b:	89 c6                	mov    %eax,%esi
f010141d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101421:	89 34 24             	mov    %esi,(%esp)
f0101424:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101427:	83 eb 01             	sub    $0x1,%ebx
f010142a:	85 db                	test   %ebx,%ebx
f010142c:	7f ef                	jg     f010141d <vprintfmt+0x23e>
f010142e:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0101431:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0101434:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101437:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010143e:	eb 9b                	jmp    f01013db <vprintfmt+0x1fc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101440:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101444:	74 1b                	je     f0101461 <vprintfmt+0x282>
f0101446:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101449:	83 fa 5e             	cmp    $0x5e,%edx
f010144c:	76 13                	jbe    f0101461 <vprintfmt+0x282>
					putch('?', putdat);
f010144e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101451:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101455:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010145c:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010145f:	eb 0d                	jmp    f010146e <vprintfmt+0x28f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0101461:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101464:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101468:	89 04 24             	mov    %eax,(%esp)
f010146b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010146e:	83 ef 01             	sub    $0x1,%edi
f0101471:	0f be 03             	movsbl (%ebx),%eax
f0101474:	85 c0                	test   %eax,%eax
f0101476:	74 05                	je     f010147d <vprintfmt+0x29e>
f0101478:	83 c3 01             	add    $0x1,%ebx
f010147b:	eb 2e                	jmp    f01014ab <vprintfmt+0x2cc>
f010147d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101480:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0101483:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101486:	8b 7d d0             	mov    -0x30(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101489:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010148d:	7f 33                	jg     f01014c2 <vprintfmt+0x2e3>
f010148f:	e9 81 fd ff ff       	jmp    f0101215 <vprintfmt+0x36>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101494:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101497:	83 c2 01             	add    $0x1,%edx
f010149a:	89 5d c8             	mov    %ebx,-0x38(%ebp)
f010149d:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01014a0:	89 d3                	mov    %edx,%ebx
f01014a2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01014a5:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01014a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014ab:	85 f6                	test   %esi,%esi
f01014ad:	78 91                	js     f0101440 <vprintfmt+0x261>
f01014af:	83 ee 01             	sub    $0x1,%esi
f01014b2:	79 8c                	jns    f0101440 <vprintfmt+0x261>
f01014b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01014b7:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01014ba:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01014bd:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01014c0:	eb c7                	jmp    f0101489 <vprintfmt+0x2aa>
f01014c2:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01014c5:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01014c8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01014d1:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01014d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01014d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01014df:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01014e1:	83 eb 01             	sub    $0x1,%ebx
f01014e4:	85 db                	test   %ebx,%ebx
f01014e6:	7f ec                	jg     f01014d4 <vprintfmt+0x2f5>
f01014e8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01014eb:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01014ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014f1:	e9 22 fd ff ff       	jmp    f0101218 <vprintfmt+0x39>
f01014f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			break;

		// (signed) decimal
		/* stone's solution for exercise9 */
		case 'd':
			if (pflag == 0){
f01014f9:	85 c9                	test   %ecx,%ecx
f01014fb:	75 45                	jne    f0101542 <vprintfmt+0x363>
				num = getint(&ap, lflag);
f01014fd:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101500:	8d 45 14             	lea    0x14(%ebp),%eax
f0101503:	e8 80 fc ff ff       	call   f0101188 <getint>
f0101508:	89 c3                	mov    %eax,%ebx
f010150a:	89 d6                	mov    %edx,%esi
				if ((long long) num < 0) {
f010150c:	85 d2                	test   %edx,%edx
f010150e:	78 0d                	js     f010151d <vprintfmt+0x33e>

		// (signed) decimal
		/* stone's solution for exercise9 */
		case 'd':
			if (pflag == 0){
				num = getint(&ap, lflag);
f0101510:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101513:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101518:	e9 59 01 00 00       	jmp    f0101676 <vprintfmt+0x497>
				if ((long long) num < 0) {
					putch('-', putdat);
f010151d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101520:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101524:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010152b:	ff 55 08             	call   *0x8(%ebp)
					num = -(long long) num;
f010152e:	f7 db                	neg    %ebx
f0101530:	83 d6 00             	adc    $0x0,%esi
f0101533:	f7 de                	neg    %esi
f0101535:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101538:	b8 0a 00 00 00       	mov    $0xa,%eax
f010153d:	e9 34 01 00 00       	jmp    f0101676 <vprintfmt+0x497>
				}
			}
			else if (pflag == 1){
f0101542:	83 f9 01             	cmp    $0x1,%ecx
f0101545:	0f 85 23 01 00 00    	jne    f010166e <vprintfmt+0x48f>
				num = getint(&ap, lflag);
f010154b:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010154e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101551:	e8 32 fc ff ff       	call   f0101188 <getint>
f0101556:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101559:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010155c:	89 c3                	mov    %eax,%ebx
f010155e:	89 d6                	mov    %edx,%esi
				if ((long long) num < 0) {
f0101560:	85 d2                	test   %edx,%edx
f0101562:	79 2b                	jns    f010158f <vprintfmt+0x3b0>
					putch('-', putdat);
f0101564:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101567:	89 54 24 04          	mov    %edx,0x4(%esp)
f010156b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101572:	ff 55 08             	call   *0x8(%ebp)
					num = -(long long) num;
f0101575:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0101578:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010157b:	f7 db                	neg    %ebx
f010157d:	83 d6 00             	adc    $0x0,%esi
f0101580:	f7 de                	neg    %esi
f0101582:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101585:	b8 0a 00 00 00       	mov    $0xa,%eax
f010158a:	e9 e7 00 00 00       	jmp    f0101676 <vprintfmt+0x497>
				}
				else if ((long long) num > 0){
f010158f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101593:	0f 88 d5 00 00 00    	js     f010166e <vprintfmt+0x48f>
f0101599:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010159d:	7f 0a                	jg     f01015a9 <vprintfmt+0x3ca>
f010159f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01015a3:	0f 86 c5 00 00 00    	jbe    f010166e <vprintfmt+0x48f>
					putch('+', putdat);
f01015a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015b0:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f01015b7:	ff 55 08             	call   *0x8(%ebp)
f01015ba:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01015bd:	b8 0a 00 00 00       	mov    $0xa,%eax
f01015c2:	e9 af 00 00 00       	jmp    f0101676 <vprintfmt+0x497>
f01015c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01015ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01015cd:	8d 45 14             	lea    0x14(%ebp),%eax
f01015d0:	e8 79 fb ff ff       	call   f010114e <getuint>
f01015d5:	89 c3                	mov    %eax,%ebx
f01015d7:	89 d6                	mov    %edx,%esi
f01015d9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01015dc:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f01015e1:	e9 90 00 00 00       	jmp    f0101676 <vprintfmt+0x497>
f01015e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			/* stone's solution for exercise8 */
			putch('0', putdat);
f01015e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01015f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01015f7:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
f01015fa:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01015fd:	8d 45 14             	lea    0x14(%ebp),%eax
f0101600:	e8 49 fb ff ff       	call   f010114e <getuint>
f0101605:	89 c3                	mov    %eax,%ebx
f0101607:	89 d6                	mov    %edx,%esi
f0101609:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010160c:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
f0101611:	eb 63                	jmp    f0101676 <vprintfmt+0x497>
f0101613:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0101616:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101619:	89 44 24 04          	mov    %eax,0x4(%esp)
f010161d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101624:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101627:	8b 55 0c             	mov    0xc(%ebp),%edx
f010162a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010162e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101635:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101638:	8b 45 14             	mov    0x14(%ebp),%eax
f010163b:	8d 50 04             	lea    0x4(%eax),%edx
f010163e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101641:	8b 18                	mov    (%eax),%ebx
f0101643:	be 00 00 00 00       	mov    $0x0,%esi
f0101648:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010164b:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101650:	eb 24                	jmp    f0101676 <vprintfmt+0x497>
f0101652:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101655:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101658:	8d 45 14             	lea    0x14(%ebp),%eax
f010165b:	e8 ee fa ff ff       	call   f010114e <getuint>
f0101660:	89 c3                	mov    %eax,%ebx
f0101662:	89 d6                	mov    %edx,%esi
f0101664:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101667:	b8 10 00 00 00       	mov    $0x10,%eax
f010166c:	eb 08                	jmp    f0101676 <vprintfmt+0x497>
f010166e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101671:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 16;
			goto number;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101676:	0f be 55 d0          	movsbl -0x30(%ebp),%edx
f010167a:	89 55 d8             	mov    %edx,-0x28(%ebp)
}
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	width = _printnum(putch, putdat, num, base, width, padc);
f010167d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101681:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101684:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101688:	89 44 24 08          	mov    %eax,0x8(%esp)
f010168c:	89 1c 24             	mov    %ebx,(%esp)
f010168f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101693:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101696:	8b 45 08             	mov    0x8(%ebp),%eax
f0101699:	e8 b2 f9 ff ff       	call   f0101050 <_printnum>
	if (padc == '-'){
f010169e:	83 7d d8 2d          	cmpl   $0x2d,-0x28(%ebp)
f01016a2:	0f 85 6d fb ff ff    	jne    f0101215 <vprintfmt+0x36>
		while (--width > 0)
f01016a8:	83 e8 01             	sub    $0x1,%eax
f01016ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016ae:	85 c0                	test   %eax,%eax
f01016b0:	0f 8e 5f fb ff ff    	jle    f0101215 <vprintfmt+0x36>
f01016b6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01016b9:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01016bc:	89 c3                	mov    %eax,%ebx
f01016be:	8b 75 08             	mov    0x8(%ebp),%esi
f01016c1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01016c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
			putch(' ', putdat);
f01016c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016cb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01016d2:	ff d6                	call   *%esi
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	width = _printnum(putch, putdat, num, base, width, padc);
	if (padc == '-'){
		while (--width > 0)
f01016d4:	83 eb 01             	sub    $0x1,%ebx
f01016d7:	85 db                	test   %ebx,%ebx
f01016d9:	7f ec                	jg     f01016c7 <vprintfmt+0x4e8>
f01016db:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01016de:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01016e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01016e4:	e9 2f fb ff ff       	jmp    f0101218 <vprintfmt+0x39>
f01016e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    	/* stone's solution for exercise10 */
		char* pos = putdat;
		char*  spec = va_arg(ap, char*);
f01016ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01016ef:	8d 50 04             	lea    0x4(%eax),%edx
f01016f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01016f5:	8b 38                	mov    (%eax),%edi
		if (spec == NULL){
f01016f7:	85 ff                	test   %edi,%edi
f01016f9:	75 2a                	jne    f0101725 <vprintfmt+0x546>
			printfmt(putch, putdat, "%s", null_error);
f01016fb:	c7 44 24 0c c4 26 10 	movl   $0xf01026c4,0xc(%esp)
f0101702:	f0 
f0101703:	c7 44 24 08 4f 26 10 	movl   $0xf010264f,0x8(%esp)
f010170a:	f0 
f010170b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010170e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101712:	8b 55 08             	mov    0x8(%ebp),%edx
f0101715:	89 14 24             	mov    %edx,(%esp)
f0101718:	e8 11 01 00 00       	call   f010182e <printfmt>
f010171d:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;
f0101720:	e9 f3 fa ff ff       	jmp    f0101218 <vprintfmt+0x39>
		}
		else if ((*(int *)putdat) >= 0xff){
f0101725:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101728:	81 38 fe 00 00 00    	cmpl   $0xfe,(%eax)
f010172e:	7e 2a                	jle    f010175a <vprintfmt+0x57b>
			printfmt(putch, putdat, "%s", overflow_error);
f0101730:	c7 44 24 0c fc 26 10 	movl   $0xf01026fc,0xc(%esp)
f0101737:	f0 
f0101738:	c7 44 24 08 4f 26 10 	movl   $0xf010264f,0x8(%esp)
f010173f:	f0 
f0101740:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101744:	8b 55 08             	mov    0x8(%ebp),%edx
f0101747:	89 14 24             	mov    %edx,(%esp)
f010174a:	e8 df 00 00 00       	call   f010182e <printfmt>
			*spec = 0xff; //-1
f010174f:	c6 07 ff             	movb   $0xff,(%edi)
f0101752:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;
f0101755:	e9 be fa ff ff       	jmp    f0101218 <vprintfmt+0x39>
		} 
		else *spec = *pos;
f010175a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010175d:	0f b6 02             	movzbl (%edx),%eax
f0101760:	88 07                	mov    %al,(%edi)
f0101762:	8b 7d e0             	mov    -0x20(%ebp),%edi
            break;
f0101765:	e9 ae fa ff ff       	jmp    f0101218 <vprintfmt+0x39>
f010176a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010176d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101770:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101773:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101777:	89 14 24             	mov    %edx,(%esp)
f010177a:	ff 55 08             	call   *0x8(%ebp)
f010177d:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;
f0101780:	e9 93 fa ff ff       	jmp    f0101218 <vprintfmt+0x39>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101785:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101788:	89 54 24 04          	mov    %edx,0x4(%esp)
f010178c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101793:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101796:	8d 47 ff             	lea    -0x1(%edi),%eax
f0101799:	80 38 25             	cmpb   $0x25,(%eax)
f010179c:	0f 84 76 fa ff ff    	je     f0101218 <vprintfmt+0x39>
f01017a2:	89 c7                	mov    %eax,%edi
f01017a4:	eb f0                	jmp    f0101796 <vprintfmt+0x5b7>
				/* do nothing */;
			break;
		}
	}
}
f01017a6:	83 c4 5c             	add    $0x5c,%esp
f01017a9:	5b                   	pop    %ebx
f01017aa:	5e                   	pop    %esi
f01017ab:	5f                   	pop    %edi
f01017ac:	5d                   	pop    %ebp
f01017ad:	c3                   	ret    

f01017ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01017ae:	55                   	push   %ebp
f01017af:	89 e5                	mov    %esp,%ebp
f01017b1:	83 ec 28             	sub    $0x28,%esp
f01017b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01017ba:	85 c0                	test   %eax,%eax
f01017bc:	74 04                	je     f01017c2 <vsnprintf+0x14>
f01017be:	85 d2                	test   %edx,%edx
f01017c0:	7f 07                	jg     f01017c9 <vsnprintf+0x1b>
f01017c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01017c7:	eb 3b                	jmp    f0101804 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01017c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01017cc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01017d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01017d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01017da:	8b 45 14             	mov    0x14(%ebp),%eax
f01017dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01017e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01017eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017ef:	c7 04 24 c2 11 10 f0 	movl   $0xf01011c2,(%esp)
f01017f6:	e8 e4 f9 ff ff       	call   f01011df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01017fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101801:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0101804:	c9                   	leave  
f0101805:	c3                   	ret    

f0101806 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101806:	55                   	push   %ebp
f0101807:	89 e5                	mov    %esp,%ebp
f0101809:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f010180c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f010180f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101813:	8b 45 10             	mov    0x10(%ebp),%eax
f0101816:	89 44 24 08          	mov    %eax,0x8(%esp)
f010181a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010181d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101821:	8b 45 08             	mov    0x8(%ebp),%eax
f0101824:	89 04 24             	mov    %eax,(%esp)
f0101827:	e8 82 ff ff ff       	call   f01017ae <vsnprintf>
	va_end(ap);

	return rc;
}
f010182c:	c9                   	leave  
f010182d:	c3                   	ret    

f010182e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010182e:	55                   	push   %ebp
f010182f:	89 e5                	mov    %esp,%ebp
f0101831:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0101834:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0101837:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010183b:	8b 45 10             	mov    0x10(%ebp),%eax
f010183e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101842:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101845:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101849:	8b 45 08             	mov    0x8(%ebp),%eax
f010184c:	89 04 24             	mov    %eax,(%esp)
f010184f:	e8 8b f9 ff ff       	call   f01011df <vprintfmt>
	va_end(ap);
}
f0101854:	c9                   	leave  
f0101855:	c3                   	ret    
	...

f0101860 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101860:	55                   	push   %ebp
f0101861:	89 e5                	mov    %esp,%ebp
f0101863:	57                   	push   %edi
f0101864:	56                   	push   %esi
f0101865:	53                   	push   %ebx
f0101866:	83 ec 1c             	sub    $0x1c,%esp
f0101869:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010186c:	85 c0                	test   %eax,%eax
f010186e:	74 10                	je     f0101880 <readline+0x20>
		cprintf("%s", prompt);
f0101870:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101874:	c7 04 24 4f 26 10 f0 	movl   $0xf010264f,(%esp)
f010187b:	e8 2f f4 ff ff       	call   f0100caf <cprintf>

	i = 0;
	echoing = iscons(0);
f0101880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101887:	e8 fa ea ff ff       	call   f0100386 <iscons>
f010188c:	89 c7                	mov    %eax,%edi
f010188e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101893:	e8 dd ea ff ff       	call   f0100375 <getchar>
f0101898:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010189a:	85 c0                	test   %eax,%eax
f010189c:	79 17                	jns    f01018b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010189e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018a2:	c7 04 24 b4 28 10 f0 	movl   $0xf01028b4,(%esp)
f01018a9:	e8 01 f4 ff ff       	call   f0100caf <cprintf>
f01018ae:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01018b3:	eb 76                	jmp    f010192b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01018b5:	83 f8 08             	cmp    $0x8,%eax
f01018b8:	74 08                	je     f01018c2 <readline+0x62>
f01018ba:	83 f8 7f             	cmp    $0x7f,%eax
f01018bd:	8d 76 00             	lea    0x0(%esi),%esi
f01018c0:	75 19                	jne    f01018db <readline+0x7b>
f01018c2:	85 f6                	test   %esi,%esi
f01018c4:	7e 15                	jle    f01018db <readline+0x7b>
			if (echoing)
f01018c6:	85 ff                	test   %edi,%edi
f01018c8:	74 0c                	je     f01018d6 <readline+0x76>
				cputchar('\b');
f01018ca:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01018d1:	e8 b4 ec ff ff       	call   f010058a <cputchar>
			i--;
f01018d6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01018d9:	eb b8                	jmp    f0101893 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f01018db:	83 fb 1f             	cmp    $0x1f,%ebx
f01018de:	66 90                	xchg   %ax,%ax
f01018e0:	7e 23                	jle    f0101905 <readline+0xa5>
f01018e2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01018e8:	7f 1b                	jg     f0101905 <readline+0xa5>
			if (echoing)
f01018ea:	85 ff                	test   %edi,%edi
f01018ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018f0:	74 08                	je     f01018fa <readline+0x9a>
				cputchar(c);
f01018f2:	89 1c 24             	mov    %ebx,(%esp)
f01018f5:	e8 90 ec ff ff       	call   f010058a <cputchar>
			buf[i++] = c;
f01018fa:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f0101900:	83 c6 01             	add    $0x1,%esi
f0101903:	eb 8e                	jmp    f0101893 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101905:	83 fb 0a             	cmp    $0xa,%ebx
f0101908:	74 05                	je     f010190f <readline+0xaf>
f010190a:	83 fb 0d             	cmp    $0xd,%ebx
f010190d:	75 84                	jne    f0101893 <readline+0x33>
			if (echoing)
f010190f:	85 ff                	test   %edi,%edi
f0101911:	74 0c                	je     f010191f <readline+0xbf>
				cputchar('\n');
f0101913:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010191a:	e8 6b ec ff ff       	call   f010058a <cputchar>
			buf[i] = 0;
f010191f:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
f0101926:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
			return buf;
		}
	}
}
f010192b:	83 c4 1c             	add    $0x1c,%esp
f010192e:	5b                   	pop    %ebx
f010192f:	5e                   	pop    %esi
f0101930:	5f                   	pop    %edi
f0101931:	5d                   	pop    %ebp
f0101932:	c3                   	ret    
	...

f0101940 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101940:	55                   	push   %ebp
f0101941:	89 e5                	mov    %esp,%ebp
f0101943:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101946:	b8 00 00 00 00       	mov    $0x0,%eax
f010194b:	80 3a 00             	cmpb   $0x0,(%edx)
f010194e:	74 09                	je     f0101959 <strlen+0x19>
		n++;
f0101950:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101953:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101957:	75 f7                	jne    f0101950 <strlen+0x10>
		n++;
	return n;
}
f0101959:	5d                   	pop    %ebp
f010195a:	c3                   	ret    

f010195b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010195b:	55                   	push   %ebp
f010195c:	89 e5                	mov    %esp,%ebp
f010195e:	53                   	push   %ebx
f010195f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101965:	85 c9                	test   %ecx,%ecx
f0101967:	74 19                	je     f0101982 <strnlen+0x27>
f0101969:	80 3b 00             	cmpb   $0x0,(%ebx)
f010196c:	74 14                	je     f0101982 <strnlen+0x27>
f010196e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101973:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101976:	39 c8                	cmp    %ecx,%eax
f0101978:	74 0d                	je     f0101987 <strnlen+0x2c>
f010197a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010197e:	75 f3                	jne    f0101973 <strnlen+0x18>
f0101980:	eb 05                	jmp    f0101987 <strnlen+0x2c>
f0101982:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101987:	5b                   	pop    %ebx
f0101988:	5d                   	pop    %ebp
f0101989:	c3                   	ret    

f010198a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010198a:	55                   	push   %ebp
f010198b:	89 e5                	mov    %esp,%ebp
f010198d:	53                   	push   %ebx
f010198e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101991:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101994:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101999:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010199d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01019a0:	83 c2 01             	add    $0x1,%edx
f01019a3:	84 c9                	test   %cl,%cl
f01019a5:	75 f2                	jne    f0101999 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01019a7:	5b                   	pop    %ebx
f01019a8:	5d                   	pop    %ebp
f01019a9:	c3                   	ret    

f01019aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01019aa:	55                   	push   %ebp
f01019ab:	89 e5                	mov    %esp,%ebp
f01019ad:	56                   	push   %esi
f01019ae:	53                   	push   %ebx
f01019af:	8b 45 08             	mov    0x8(%ebp),%eax
f01019b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01019b5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01019b8:	85 f6                	test   %esi,%esi
f01019ba:	74 18                	je     f01019d4 <strncpy+0x2a>
f01019bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01019c1:	0f b6 1a             	movzbl (%edx),%ebx
f01019c4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01019c7:	80 3a 01             	cmpb   $0x1,(%edx)
f01019ca:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01019cd:	83 c1 01             	add    $0x1,%ecx
f01019d0:	39 ce                	cmp    %ecx,%esi
f01019d2:	77 ed                	ja     f01019c1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01019d4:	5b                   	pop    %ebx
f01019d5:	5e                   	pop    %esi
f01019d6:	5d                   	pop    %ebp
f01019d7:	c3                   	ret    

f01019d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01019d8:	55                   	push   %ebp
f01019d9:	89 e5                	mov    %esp,%ebp
f01019db:	56                   	push   %esi
f01019dc:	53                   	push   %ebx
f01019dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01019e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01019e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01019e6:	89 f0                	mov    %esi,%eax
f01019e8:	85 c9                	test   %ecx,%ecx
f01019ea:	74 27                	je     f0101a13 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f01019ec:	83 e9 01             	sub    $0x1,%ecx
f01019ef:	74 1d                	je     f0101a0e <strlcpy+0x36>
f01019f1:	0f b6 1a             	movzbl (%edx),%ebx
f01019f4:	84 db                	test   %bl,%bl
f01019f6:	74 16                	je     f0101a0e <strlcpy+0x36>
			*dst++ = *src++;
f01019f8:	88 18                	mov    %bl,(%eax)
f01019fa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01019fd:	83 e9 01             	sub    $0x1,%ecx
f0101a00:	74 0e                	je     f0101a10 <strlcpy+0x38>
			*dst++ = *src++;
f0101a02:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101a05:	0f b6 1a             	movzbl (%edx),%ebx
f0101a08:	84 db                	test   %bl,%bl
f0101a0a:	75 ec                	jne    f01019f8 <strlcpy+0x20>
f0101a0c:	eb 02                	jmp    f0101a10 <strlcpy+0x38>
f0101a0e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101a10:	c6 00 00             	movb   $0x0,(%eax)
f0101a13:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101a15:	5b                   	pop    %ebx
f0101a16:	5e                   	pop    %esi
f0101a17:	5d                   	pop    %ebp
f0101a18:	c3                   	ret    

f0101a19 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101a19:	55                   	push   %ebp
f0101a1a:	89 e5                	mov    %esp,%ebp
f0101a1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101a22:	0f b6 01             	movzbl (%ecx),%eax
f0101a25:	84 c0                	test   %al,%al
f0101a27:	74 15                	je     f0101a3e <strcmp+0x25>
f0101a29:	3a 02                	cmp    (%edx),%al
f0101a2b:	75 11                	jne    f0101a3e <strcmp+0x25>
		p++, q++;
f0101a2d:	83 c1 01             	add    $0x1,%ecx
f0101a30:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101a33:	0f b6 01             	movzbl (%ecx),%eax
f0101a36:	84 c0                	test   %al,%al
f0101a38:	74 04                	je     f0101a3e <strcmp+0x25>
f0101a3a:	3a 02                	cmp    (%edx),%al
f0101a3c:	74 ef                	je     f0101a2d <strcmp+0x14>
f0101a3e:	0f b6 c0             	movzbl %al,%eax
f0101a41:	0f b6 12             	movzbl (%edx),%edx
f0101a44:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101a46:	5d                   	pop    %ebp
f0101a47:	c3                   	ret    

f0101a48 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101a48:	55                   	push   %ebp
f0101a49:	89 e5                	mov    %esp,%ebp
f0101a4b:	53                   	push   %ebx
f0101a4c:	8b 55 08             	mov    0x8(%ebp),%edx
f0101a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a52:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	74 23                	je     f0101a7c <strncmp+0x34>
f0101a59:	0f b6 1a             	movzbl (%edx),%ebx
f0101a5c:	84 db                	test   %bl,%bl
f0101a5e:	74 24                	je     f0101a84 <strncmp+0x3c>
f0101a60:	3a 19                	cmp    (%ecx),%bl
f0101a62:	75 20                	jne    f0101a84 <strncmp+0x3c>
f0101a64:	83 e8 01             	sub    $0x1,%eax
f0101a67:	74 13                	je     f0101a7c <strncmp+0x34>
		n--, p++, q++;
f0101a69:	83 c2 01             	add    $0x1,%edx
f0101a6c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101a6f:	0f b6 1a             	movzbl (%edx),%ebx
f0101a72:	84 db                	test   %bl,%bl
f0101a74:	74 0e                	je     f0101a84 <strncmp+0x3c>
f0101a76:	3a 19                	cmp    (%ecx),%bl
f0101a78:	74 ea                	je     f0101a64 <strncmp+0x1c>
f0101a7a:	eb 08                	jmp    f0101a84 <strncmp+0x3c>
f0101a7c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101a81:	5b                   	pop    %ebx
f0101a82:	5d                   	pop    %ebp
f0101a83:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101a84:	0f b6 02             	movzbl (%edx),%eax
f0101a87:	0f b6 11             	movzbl (%ecx),%edx
f0101a8a:	29 d0                	sub    %edx,%eax
f0101a8c:	eb f3                	jmp    f0101a81 <strncmp+0x39>

f0101a8e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101a8e:	55                   	push   %ebp
f0101a8f:	89 e5                	mov    %esp,%ebp
f0101a91:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a98:	0f b6 10             	movzbl (%eax),%edx
f0101a9b:	84 d2                	test   %dl,%dl
f0101a9d:	74 15                	je     f0101ab4 <strchr+0x26>
		if (*s == c)
f0101a9f:	38 ca                	cmp    %cl,%dl
f0101aa1:	75 07                	jne    f0101aaa <strchr+0x1c>
f0101aa3:	eb 14                	jmp    f0101ab9 <strchr+0x2b>
f0101aa5:	38 ca                	cmp    %cl,%dl
f0101aa7:	90                   	nop
f0101aa8:	74 0f                	je     f0101ab9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101aaa:	83 c0 01             	add    $0x1,%eax
f0101aad:	0f b6 10             	movzbl (%eax),%edx
f0101ab0:	84 d2                	test   %dl,%dl
f0101ab2:	75 f1                	jne    f0101aa5 <strchr+0x17>
f0101ab4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101ab9:	5d                   	pop    %ebp
f0101aba:	c3                   	ret    

f0101abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101abb:	55                   	push   %ebp
f0101abc:	89 e5                	mov    %esp,%ebp
f0101abe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101ac5:	0f b6 10             	movzbl (%eax),%edx
f0101ac8:	84 d2                	test   %dl,%dl
f0101aca:	74 18                	je     f0101ae4 <strfind+0x29>
		if (*s == c)
f0101acc:	38 ca                	cmp    %cl,%dl
f0101ace:	75 0a                	jne    f0101ada <strfind+0x1f>
f0101ad0:	eb 12                	jmp    f0101ae4 <strfind+0x29>
f0101ad2:	38 ca                	cmp    %cl,%dl
f0101ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ad8:	74 0a                	je     f0101ae4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101ada:	83 c0 01             	add    $0x1,%eax
f0101add:	0f b6 10             	movzbl (%eax),%edx
f0101ae0:	84 d2                	test   %dl,%dl
f0101ae2:	75 ee                	jne    f0101ad2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101ae4:	5d                   	pop    %ebp
f0101ae5:	c3                   	ret    

f0101ae6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101ae6:	55                   	push   %ebp
f0101ae7:	89 e5                	mov    %esp,%ebp
f0101ae9:	83 ec 0c             	sub    $0xc,%esp
f0101aec:	89 1c 24             	mov    %ebx,(%esp)
f0101aef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101af3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101af7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101afa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101b00:	85 c9                	test   %ecx,%ecx
f0101b02:	74 30                	je     f0101b34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101b04:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101b0a:	75 25                	jne    f0101b31 <memset+0x4b>
f0101b0c:	f6 c1 03             	test   $0x3,%cl
f0101b0f:	75 20                	jne    f0101b31 <memset+0x4b>
		c &= 0xFF;
f0101b11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101b14:	89 d3                	mov    %edx,%ebx
f0101b16:	c1 e3 08             	shl    $0x8,%ebx
f0101b19:	89 d6                	mov    %edx,%esi
f0101b1b:	c1 e6 18             	shl    $0x18,%esi
f0101b1e:	89 d0                	mov    %edx,%eax
f0101b20:	c1 e0 10             	shl    $0x10,%eax
f0101b23:	09 f0                	or     %esi,%eax
f0101b25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0101b27:	09 d8                	or     %ebx,%eax
f0101b29:	c1 e9 02             	shr    $0x2,%ecx
f0101b2c:	fc                   	cld    
f0101b2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101b2f:	eb 03                	jmp    f0101b34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101b31:	fc                   	cld    
f0101b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101b34:	89 f8                	mov    %edi,%eax
f0101b36:	8b 1c 24             	mov    (%esp),%ebx
f0101b39:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101b3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101b41:	89 ec                	mov    %ebp,%esp
f0101b43:	5d                   	pop    %ebp
f0101b44:	c3                   	ret    

f0101b45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101b45:	55                   	push   %ebp
f0101b46:	89 e5                	mov    %esp,%ebp
f0101b48:	83 ec 08             	sub    $0x8,%esp
f0101b4b:	89 34 24             	mov    %esi,(%esp)
f0101b4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b52:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0101b58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0101b5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0101b5d:	39 c6                	cmp    %eax,%esi
f0101b5f:	73 35                	jae    f0101b96 <memmove+0x51>
f0101b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101b64:	39 d0                	cmp    %edx,%eax
f0101b66:	73 2e                	jae    f0101b96 <memmove+0x51>
		s += n;
		d += n;
f0101b68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b6a:	f6 c2 03             	test   $0x3,%dl
f0101b6d:	75 1b                	jne    f0101b8a <memmove+0x45>
f0101b6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101b75:	75 13                	jne    f0101b8a <memmove+0x45>
f0101b77:	f6 c1 03             	test   $0x3,%cl
f0101b7a:	75 0e                	jne    f0101b8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0101b7c:	83 ef 04             	sub    $0x4,%edi
f0101b7f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101b82:	c1 e9 02             	shr    $0x2,%ecx
f0101b85:	fd                   	std    
f0101b86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b88:	eb 09                	jmp    f0101b93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101b8a:	83 ef 01             	sub    $0x1,%edi
f0101b8d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101b90:	fd                   	std    
f0101b91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101b93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101b94:	eb 20                	jmp    f0101bb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b96:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101b9c:	75 15                	jne    f0101bb3 <memmove+0x6e>
f0101b9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101ba4:	75 0d                	jne    f0101bb3 <memmove+0x6e>
f0101ba6:	f6 c1 03             	test   $0x3,%cl
f0101ba9:	75 08                	jne    f0101bb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0101bab:	c1 e9 02             	shr    $0x2,%ecx
f0101bae:	fc                   	cld    
f0101baf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101bb1:	eb 03                	jmp    f0101bb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101bb3:	fc                   	cld    
f0101bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101bb6:	8b 34 24             	mov    (%esp),%esi
f0101bb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101bbd:	89 ec                	mov    %ebp,%esp
f0101bbf:	5d                   	pop    %ebp
f0101bc0:	c3                   	ret    

f0101bc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101bc1:	55                   	push   %ebp
f0101bc2:	89 e5                	mov    %esp,%ebp
f0101bc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101bc7:	8b 45 10             	mov    0x10(%ebp),%eax
f0101bca:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bce:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bd8:	89 04 24             	mov    %eax,(%esp)
f0101bdb:	e8 65 ff ff ff       	call   f0101b45 <memmove>
}
f0101be0:	c9                   	leave  
f0101be1:	c3                   	ret    

f0101be2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101be2:	55                   	push   %ebp
f0101be3:	89 e5                	mov    %esp,%ebp
f0101be5:	57                   	push   %edi
f0101be6:	56                   	push   %esi
f0101be7:	53                   	push   %ebx
f0101be8:	8b 75 08             	mov    0x8(%ebp),%esi
f0101beb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101bf1:	85 c9                	test   %ecx,%ecx
f0101bf3:	74 36                	je     f0101c2b <memcmp+0x49>
		if (*s1 != *s2)
f0101bf5:	0f b6 06             	movzbl (%esi),%eax
f0101bf8:	0f b6 1f             	movzbl (%edi),%ebx
f0101bfb:	38 d8                	cmp    %bl,%al
f0101bfd:	74 20                	je     f0101c1f <memcmp+0x3d>
f0101bff:	eb 14                	jmp    f0101c15 <memcmp+0x33>
f0101c01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101c06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0101c0b:	83 c2 01             	add    $0x1,%edx
f0101c0e:	83 e9 01             	sub    $0x1,%ecx
f0101c11:	38 d8                	cmp    %bl,%al
f0101c13:	74 12                	je     f0101c27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101c15:	0f b6 c0             	movzbl %al,%eax
f0101c18:	0f b6 db             	movzbl %bl,%ebx
f0101c1b:	29 d8                	sub    %ebx,%eax
f0101c1d:	eb 11                	jmp    f0101c30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101c1f:	83 e9 01             	sub    $0x1,%ecx
f0101c22:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c27:	85 c9                	test   %ecx,%ecx
f0101c29:	75 d6                	jne    f0101c01 <memcmp+0x1f>
f0101c2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101c30:	5b                   	pop    %ebx
f0101c31:	5e                   	pop    %esi
f0101c32:	5f                   	pop    %edi
f0101c33:	5d                   	pop    %ebp
f0101c34:	c3                   	ret    

f0101c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101c35:	55                   	push   %ebp
f0101c36:	89 e5                	mov    %esp,%ebp
f0101c38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101c3b:	89 c2                	mov    %eax,%edx
f0101c3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101c40:	39 d0                	cmp    %edx,%eax
f0101c42:	73 15                	jae    f0101c59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101c44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101c48:	38 08                	cmp    %cl,(%eax)
f0101c4a:	75 06                	jne    f0101c52 <memfind+0x1d>
f0101c4c:	eb 0b                	jmp    f0101c59 <memfind+0x24>
f0101c4e:	38 08                	cmp    %cl,(%eax)
f0101c50:	74 07                	je     f0101c59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101c52:	83 c0 01             	add    $0x1,%eax
f0101c55:	39 c2                	cmp    %eax,%edx
f0101c57:	77 f5                	ja     f0101c4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101c59:	5d                   	pop    %ebp
f0101c5a:	c3                   	ret    

f0101c5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101c5b:	55                   	push   %ebp
f0101c5c:	89 e5                	mov    %esp,%ebp
f0101c5e:	57                   	push   %edi
f0101c5f:	56                   	push   %esi
f0101c60:	53                   	push   %ebx
f0101c61:	83 ec 04             	sub    $0x4,%esp
f0101c64:	8b 55 08             	mov    0x8(%ebp),%edx
f0101c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101c6a:	0f b6 02             	movzbl (%edx),%eax
f0101c6d:	3c 20                	cmp    $0x20,%al
f0101c6f:	74 04                	je     f0101c75 <strtol+0x1a>
f0101c71:	3c 09                	cmp    $0x9,%al
f0101c73:	75 0e                	jne    f0101c83 <strtol+0x28>
		s++;
f0101c75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101c78:	0f b6 02             	movzbl (%edx),%eax
f0101c7b:	3c 20                	cmp    $0x20,%al
f0101c7d:	74 f6                	je     f0101c75 <strtol+0x1a>
f0101c7f:	3c 09                	cmp    $0x9,%al
f0101c81:	74 f2                	je     f0101c75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101c83:	3c 2b                	cmp    $0x2b,%al
f0101c85:	75 0c                	jne    f0101c93 <strtol+0x38>
		s++;
f0101c87:	83 c2 01             	add    $0x1,%edx
f0101c8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101c91:	eb 15                	jmp    f0101ca8 <strtol+0x4d>
	else if (*s == '-')
f0101c93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101c9a:	3c 2d                	cmp    $0x2d,%al
f0101c9c:	75 0a                	jne    f0101ca8 <strtol+0x4d>
		s++, neg = 1;
f0101c9e:	83 c2 01             	add    $0x1,%edx
f0101ca1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101ca8:	85 db                	test   %ebx,%ebx
f0101caa:	0f 94 c0             	sete   %al
f0101cad:	74 05                	je     f0101cb4 <strtol+0x59>
f0101caf:	83 fb 10             	cmp    $0x10,%ebx
f0101cb2:	75 18                	jne    f0101ccc <strtol+0x71>
f0101cb4:	80 3a 30             	cmpb   $0x30,(%edx)
f0101cb7:	75 13                	jne    f0101ccc <strtol+0x71>
f0101cb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101cbd:	8d 76 00             	lea    0x0(%esi),%esi
f0101cc0:	75 0a                	jne    f0101ccc <strtol+0x71>
		s += 2, base = 16;
f0101cc2:	83 c2 02             	add    $0x2,%edx
f0101cc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101cca:	eb 15                	jmp    f0101ce1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101ccc:	84 c0                	test   %al,%al
f0101cce:	66 90                	xchg   %ax,%ax
f0101cd0:	74 0f                	je     f0101ce1 <strtol+0x86>
f0101cd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101cd7:	80 3a 30             	cmpb   $0x30,(%edx)
f0101cda:	75 05                	jne    f0101ce1 <strtol+0x86>
		s++, base = 8;
f0101cdc:	83 c2 01             	add    $0x1,%edx
f0101cdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101ce1:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ce6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101ce8:	0f b6 0a             	movzbl (%edx),%ecx
f0101ceb:	89 cf                	mov    %ecx,%edi
f0101ced:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101cf0:	80 fb 09             	cmp    $0x9,%bl
f0101cf3:	77 08                	ja     f0101cfd <strtol+0xa2>
			dig = *s - '0';
f0101cf5:	0f be c9             	movsbl %cl,%ecx
f0101cf8:	83 e9 30             	sub    $0x30,%ecx
f0101cfb:	eb 1e                	jmp    f0101d1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0101cfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101d00:	80 fb 19             	cmp    $0x19,%bl
f0101d03:	77 08                	ja     f0101d0d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101d05:	0f be c9             	movsbl %cl,%ecx
f0101d08:	83 e9 57             	sub    $0x57,%ecx
f0101d0b:	eb 0e                	jmp    f0101d1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0101d0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101d10:	80 fb 19             	cmp    $0x19,%bl
f0101d13:	77 15                	ja     f0101d2a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101d15:	0f be c9             	movsbl %cl,%ecx
f0101d18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101d1b:	39 f1                	cmp    %esi,%ecx
f0101d1d:	7d 0b                	jge    f0101d2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0101d1f:	83 c2 01             	add    $0x1,%edx
f0101d22:	0f af c6             	imul   %esi,%eax
f0101d25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101d28:	eb be                	jmp    f0101ce8 <strtol+0x8d>
f0101d2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0101d2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101d30:	74 05                	je     f0101d37 <strtol+0xdc>
		*endptr = (char *) s;
f0101d32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101d35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101d37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101d3b:	74 04                	je     f0101d41 <strtol+0xe6>
f0101d3d:	89 c8                	mov    %ecx,%eax
f0101d3f:	f7 d8                	neg    %eax
}
f0101d41:	83 c4 04             	add    $0x4,%esp
f0101d44:	5b                   	pop    %ebx
f0101d45:	5e                   	pop    %esi
f0101d46:	5f                   	pop    %edi
f0101d47:	5d                   	pop    %ebp
f0101d48:	c3                   	ret    
f0101d49:	00 00                	add    %al,(%eax)
f0101d4b:	00 00                	add    %al,(%eax)
f0101d4d:	00 00                	add    %al,(%eax)
	...

f0101d50 <__udivdi3>:
f0101d50:	55                   	push   %ebp
f0101d51:	89 e5                	mov    %esp,%ebp
f0101d53:	57                   	push   %edi
f0101d54:	56                   	push   %esi
f0101d55:	83 ec 10             	sub    $0x10,%esp
f0101d58:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d5b:	8b 55 08             	mov    0x8(%ebp),%edx
f0101d5e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101d61:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101d69:	75 35                	jne    f0101da0 <__udivdi3+0x50>
f0101d6b:	39 fe                	cmp    %edi,%esi
f0101d6d:	77 61                	ja     f0101dd0 <__udivdi3+0x80>
f0101d6f:	85 f6                	test   %esi,%esi
f0101d71:	75 0b                	jne    f0101d7e <__udivdi3+0x2e>
f0101d73:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d78:	31 d2                	xor    %edx,%edx
f0101d7a:	f7 f6                	div    %esi
f0101d7c:	89 c6                	mov    %eax,%esi
f0101d7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101d81:	31 d2                	xor    %edx,%edx
f0101d83:	89 f8                	mov    %edi,%eax
f0101d85:	f7 f6                	div    %esi
f0101d87:	89 c7                	mov    %eax,%edi
f0101d89:	89 c8                	mov    %ecx,%eax
f0101d8b:	f7 f6                	div    %esi
f0101d8d:	89 c1                	mov    %eax,%ecx
f0101d8f:	89 fa                	mov    %edi,%edx
f0101d91:	89 c8                	mov    %ecx,%eax
f0101d93:	83 c4 10             	add    $0x10,%esp
f0101d96:	5e                   	pop    %esi
f0101d97:	5f                   	pop    %edi
f0101d98:	5d                   	pop    %ebp
f0101d99:	c3                   	ret    
f0101d9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101da0:	39 f8                	cmp    %edi,%eax
f0101da2:	77 1c                	ja     f0101dc0 <__udivdi3+0x70>
f0101da4:	0f bd d0             	bsr    %eax,%edx
f0101da7:	83 f2 1f             	xor    $0x1f,%edx
f0101daa:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101dad:	75 39                	jne    f0101de8 <__udivdi3+0x98>
f0101daf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101db2:	0f 86 a0 00 00 00    	jbe    f0101e58 <__udivdi3+0x108>
f0101db8:	39 f8                	cmp    %edi,%eax
f0101dba:	0f 82 98 00 00 00    	jb     f0101e58 <__udivdi3+0x108>
f0101dc0:	31 ff                	xor    %edi,%edi
f0101dc2:	31 c9                	xor    %ecx,%ecx
f0101dc4:	89 c8                	mov    %ecx,%eax
f0101dc6:	89 fa                	mov    %edi,%edx
f0101dc8:	83 c4 10             	add    $0x10,%esp
f0101dcb:	5e                   	pop    %esi
f0101dcc:	5f                   	pop    %edi
f0101dcd:	5d                   	pop    %ebp
f0101dce:	c3                   	ret    
f0101dcf:	90                   	nop
f0101dd0:	89 d1                	mov    %edx,%ecx
f0101dd2:	89 fa                	mov    %edi,%edx
f0101dd4:	89 c8                	mov    %ecx,%eax
f0101dd6:	31 ff                	xor    %edi,%edi
f0101dd8:	f7 f6                	div    %esi
f0101dda:	89 c1                	mov    %eax,%ecx
f0101ddc:	89 fa                	mov    %edi,%edx
f0101dde:	89 c8                	mov    %ecx,%eax
f0101de0:	83 c4 10             	add    $0x10,%esp
f0101de3:	5e                   	pop    %esi
f0101de4:	5f                   	pop    %edi
f0101de5:	5d                   	pop    %ebp
f0101de6:	c3                   	ret    
f0101de7:	90                   	nop
f0101de8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101dec:	89 f2                	mov    %esi,%edx
f0101dee:	d3 e0                	shl    %cl,%eax
f0101df0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101df3:	b8 20 00 00 00       	mov    $0x20,%eax
f0101df8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101dfb:	89 c1                	mov    %eax,%ecx
f0101dfd:	d3 ea                	shr    %cl,%edx
f0101dff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e03:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101e06:	d3 e6                	shl    %cl,%esi
f0101e08:	89 c1                	mov    %eax,%ecx
f0101e0a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101e0d:	89 fe                	mov    %edi,%esi
f0101e0f:	d3 ee                	shr    %cl,%esi
f0101e11:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e15:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101e18:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101e1b:	d3 e7                	shl    %cl,%edi
f0101e1d:	89 c1                	mov    %eax,%ecx
f0101e1f:	d3 ea                	shr    %cl,%edx
f0101e21:	09 d7                	or     %edx,%edi
f0101e23:	89 f2                	mov    %esi,%edx
f0101e25:	89 f8                	mov    %edi,%eax
f0101e27:	f7 75 ec             	divl   -0x14(%ebp)
f0101e2a:	89 d6                	mov    %edx,%esi
f0101e2c:	89 c7                	mov    %eax,%edi
f0101e2e:	f7 65 e8             	mull   -0x18(%ebp)
f0101e31:	39 d6                	cmp    %edx,%esi
f0101e33:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101e36:	72 30                	jb     f0101e68 <__udivdi3+0x118>
f0101e38:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101e3b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e3f:	d3 e2                	shl    %cl,%edx
f0101e41:	39 c2                	cmp    %eax,%edx
f0101e43:	73 05                	jae    f0101e4a <__udivdi3+0xfa>
f0101e45:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101e48:	74 1e                	je     f0101e68 <__udivdi3+0x118>
f0101e4a:	89 f9                	mov    %edi,%ecx
f0101e4c:	31 ff                	xor    %edi,%edi
f0101e4e:	e9 71 ff ff ff       	jmp    f0101dc4 <__udivdi3+0x74>
f0101e53:	90                   	nop
f0101e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e58:	31 ff                	xor    %edi,%edi
f0101e5a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101e5f:	e9 60 ff ff ff       	jmp    f0101dc4 <__udivdi3+0x74>
f0101e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e68:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0101e6b:	31 ff                	xor    %edi,%edi
f0101e6d:	89 c8                	mov    %ecx,%eax
f0101e6f:	89 fa                	mov    %edi,%edx
f0101e71:	83 c4 10             	add    $0x10,%esp
f0101e74:	5e                   	pop    %esi
f0101e75:	5f                   	pop    %edi
f0101e76:	5d                   	pop    %ebp
f0101e77:	c3                   	ret    
	...

f0101e80 <__umoddi3>:
f0101e80:	55                   	push   %ebp
f0101e81:	89 e5                	mov    %esp,%ebp
f0101e83:	57                   	push   %edi
f0101e84:	56                   	push   %esi
f0101e85:	83 ec 20             	sub    $0x20,%esp
f0101e88:	8b 55 14             	mov    0x14(%ebp),%edx
f0101e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101e8e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101e91:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101e94:	85 d2                	test   %edx,%edx
f0101e96:	89 c8                	mov    %ecx,%eax
f0101e98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101e9b:	75 13                	jne    f0101eb0 <__umoddi3+0x30>
f0101e9d:	39 f7                	cmp    %esi,%edi
f0101e9f:	76 3f                	jbe    f0101ee0 <__umoddi3+0x60>
f0101ea1:	89 f2                	mov    %esi,%edx
f0101ea3:	f7 f7                	div    %edi
f0101ea5:	89 d0                	mov    %edx,%eax
f0101ea7:	31 d2                	xor    %edx,%edx
f0101ea9:	83 c4 20             	add    $0x20,%esp
f0101eac:	5e                   	pop    %esi
f0101ead:	5f                   	pop    %edi
f0101eae:	5d                   	pop    %ebp
f0101eaf:	c3                   	ret    
f0101eb0:	39 f2                	cmp    %esi,%edx
f0101eb2:	77 4c                	ja     f0101f00 <__umoddi3+0x80>
f0101eb4:	0f bd ca             	bsr    %edx,%ecx
f0101eb7:	83 f1 1f             	xor    $0x1f,%ecx
f0101eba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101ebd:	75 51                	jne    f0101f10 <__umoddi3+0x90>
f0101ebf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101ec2:	0f 87 e0 00 00 00    	ja     f0101fa8 <__umoddi3+0x128>
f0101ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ecb:	29 f8                	sub    %edi,%eax
f0101ecd:	19 d6                	sbb    %edx,%esi
f0101ecf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ed5:	89 f2                	mov    %esi,%edx
f0101ed7:	83 c4 20             	add    $0x20,%esp
f0101eda:	5e                   	pop    %esi
f0101edb:	5f                   	pop    %edi
f0101edc:	5d                   	pop    %ebp
f0101edd:	c3                   	ret    
f0101ede:	66 90                	xchg   %ax,%ax
f0101ee0:	85 ff                	test   %edi,%edi
f0101ee2:	75 0b                	jne    f0101eef <__umoddi3+0x6f>
f0101ee4:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ee9:	31 d2                	xor    %edx,%edx
f0101eeb:	f7 f7                	div    %edi
f0101eed:	89 c7                	mov    %eax,%edi
f0101eef:	89 f0                	mov    %esi,%eax
f0101ef1:	31 d2                	xor    %edx,%edx
f0101ef3:	f7 f7                	div    %edi
f0101ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ef8:	f7 f7                	div    %edi
f0101efa:	eb a9                	jmp    f0101ea5 <__umoddi3+0x25>
f0101efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101f00:	89 c8                	mov    %ecx,%eax
f0101f02:	89 f2                	mov    %esi,%edx
f0101f04:	83 c4 20             	add    $0x20,%esp
f0101f07:	5e                   	pop    %esi
f0101f08:	5f                   	pop    %edi
f0101f09:	5d                   	pop    %ebp
f0101f0a:	c3                   	ret    
f0101f0b:	90                   	nop
f0101f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101f10:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f14:	d3 e2                	shl    %cl,%edx
f0101f16:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101f19:	ba 20 00 00 00       	mov    $0x20,%edx
f0101f1e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101f21:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101f24:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101f28:	89 fa                	mov    %edi,%edx
f0101f2a:	d3 ea                	shr    %cl,%edx
f0101f2c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f30:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101f33:	d3 e7                	shl    %cl,%edi
f0101f35:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101f39:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101f3c:	89 f2                	mov    %esi,%edx
f0101f3e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101f41:	89 c7                	mov    %eax,%edi
f0101f43:	d3 ea                	shr    %cl,%edx
f0101f45:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101f4c:	89 c2                	mov    %eax,%edx
f0101f4e:	d3 e6                	shl    %cl,%esi
f0101f50:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101f54:	d3 ea                	shr    %cl,%edx
f0101f56:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f5a:	09 d6                	or     %edx,%esi
f0101f5c:	89 f0                	mov    %esi,%eax
f0101f5e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101f61:	d3 e7                	shl    %cl,%edi
f0101f63:	89 f2                	mov    %esi,%edx
f0101f65:	f7 75 f4             	divl   -0xc(%ebp)
f0101f68:	89 d6                	mov    %edx,%esi
f0101f6a:	f7 65 e8             	mull   -0x18(%ebp)
f0101f6d:	39 d6                	cmp    %edx,%esi
f0101f6f:	72 2b                	jb     f0101f9c <__umoddi3+0x11c>
f0101f71:	39 c7                	cmp    %eax,%edi
f0101f73:	72 23                	jb     f0101f98 <__umoddi3+0x118>
f0101f75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f79:	29 c7                	sub    %eax,%edi
f0101f7b:	19 d6                	sbb    %edx,%esi
f0101f7d:	89 f0                	mov    %esi,%eax
f0101f7f:	89 f2                	mov    %esi,%edx
f0101f81:	d3 ef                	shr    %cl,%edi
f0101f83:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101f87:	d3 e0                	shl    %cl,%eax
f0101f89:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f8d:	09 f8                	or     %edi,%eax
f0101f8f:	d3 ea                	shr    %cl,%edx
f0101f91:	83 c4 20             	add    $0x20,%esp
f0101f94:	5e                   	pop    %esi
f0101f95:	5f                   	pop    %edi
f0101f96:	5d                   	pop    %ebp
f0101f97:	c3                   	ret    
f0101f98:	39 d6                	cmp    %edx,%esi
f0101f9a:	75 d9                	jne    f0101f75 <__umoddi3+0xf5>
f0101f9c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0101f9f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0101fa2:	eb d1                	jmp    f0101f75 <__umoddi3+0xf5>
f0101fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101fa8:	39 f2                	cmp    %esi,%edx
f0101faa:	0f 82 18 ff ff ff    	jb     f0101ec8 <__umoddi3+0x48>
f0101fb0:	e9 1d ff ff ff       	jmp    f0101ed2 <__umoddi3+0x52>
