
obj/user/primes:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 6b 12 00 00       	call   8012c3 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  800071:	e8 0f 02 00 00       	call   800285 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 bb 11 00 00       	call   801236 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 6c 15 80 	movl   $0x80156c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  80009c:	e8 13 01 00 00       	call   8001b4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 03 12 00 00       	call   8012c3 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 b8 11 00 00       	call   8012a1 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 3e 11 00 00       	call   801236 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 6c 15 80 	movl   $0x80156c,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 75 15 80 00 	movl   $0x801575,(%esp)
  800119:	e8 96 00 00 00       	call   8001b4 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 59 11 00 00       	call   8012a1 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800162:	e8 ff 0f 00 00       	call   801166 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	c1 e0 07             	shl    $0x7,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 f4 0f 00 00       	call   8011a6 <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001bf:	a1 08 20 80 00       	mov    0x802008,%eax
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	74 10                	je     8001d8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8001c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cc:	c7 04 24 8d 15 80 00 	movl   $0x80158d,(%esp)
  8001d3:	e8 ad 00 00 00       	call   800285 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001de:	e8 83 0f 00 00       	call   801166 <sys_getenvid>
  8001e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  800200:	e8 80 00 00 00       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800205:	89 74 24 04          	mov    %esi,0x4(%esp)
  800209:	8b 45 10             	mov    0x10(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	e8 10 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  800214:	c7 04 24 92 15 80 00 	movl   $0x801592,(%esp)
  80021b:	e8 65 00 00 00       	call   800285 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800220:	cc                   	int3   
  800221:	eb fd                	jmp    800220 <_panic+0x6c>
	...

00800224 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800234:	00 00 00 
	b.cnt = 0;
  800237:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
  800244:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	c7 04 24 9f 02 80 00 	movl   $0x80029f,(%esp)
  800260:	e8 d8 01 00 00       	call   80043d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800265:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	e8 1f 0b 00 00       	call   800d9c <sys_cputs>

	return b.cnt;
}
  80027d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80028b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80028e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	e8 87 ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 14             	sub    $0x14,%esp
  8002a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a9:	8b 03                	mov    (%ebx),%eax
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b2:	83 c0 01             	add    $0x1,%eax
  8002b5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bc:	75 19                	jne    8002d7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002be:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c5:	00 
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	e8 cb 0a 00 00       	call   800d9c <sys_cputs>
		b->idx = 0;
  8002d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002db:	83 c4 14             	add    $0x14,%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
	...

008002f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 4c             	sub    $0x4c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d6                	mov    %edx,%esi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800304:	8b 55 0c             	mov    0xc(%ebp),%edx
  800307:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80030a:	8b 45 10             	mov    0x10(%ebp),%eax
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800310:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800313:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031b:	39 d1                	cmp    %edx,%ecx
  80031d:	72 15                	jb     800334 <printnum+0x44>
  80031f:	77 07                	ja     800328 <printnum+0x38>
  800321:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800324:	39 d0                	cmp    %edx,%eax
  800326:	76 0c                	jbe    800334 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800328:	83 eb 01             	sub    $0x1,%ebx
  80032b:	85 db                	test   %ebx,%ebx
  80032d:	8d 76 00             	lea    0x0(%esi),%esi
  800330:	7f 61                	jg     800393 <printnum+0xa3>
  800332:	eb 70                	jmp    8003a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800334:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800338:	83 eb 01             	sub    $0x1,%ebx
  80033b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800347:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80034b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80034e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800351:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800354:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800358:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035f:	00 
  800360:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800369:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036d:	e8 7e 0f 00 00       	call   8012f0 <__udivdi3>
  800372:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800375:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	89 54 24 04          	mov    %edx,0x4(%esp)
  800387:	89 f2                	mov    %esi,%edx
  800389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038c:	e8 5f ff ff ff       	call   8002f0 <printnum>
  800391:	eb 11                	jmp    8003a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800393:	89 74 24 04          	mov    %esi,0x4(%esp)
  800397:	89 3c 24             	mov    %edi,(%esp)
  80039a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039d:	83 eb 01             	sub    $0x1,%ebx
  8003a0:	85 db                	test   %ebx,%ebx
  8003a2:	7f ef                	jg     800393 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ba:	00 
  8003bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003be:	89 14 24             	mov    %edx,(%esp)
  8003c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003c8:	e8 53 10 00 00       	call   801420 <__umoddi3>
  8003cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d1:	0f be 80 b8 15 80 00 	movsbl 0x8015b8(%eax),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003de:	83 c4 4c             	add    $0x4c,%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e9:	83 fa 01             	cmp    $0x1,%edx
  8003ec:	7e 0e                	jle    8003fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ee:	8b 10                	mov    (%eax),%edx
  8003f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 02                	mov    (%edx),%eax
  8003f7:	8b 52 04             	mov    0x4(%edx),%edx
  8003fa:	eb 22                	jmp    80041e <getuint+0x38>
	else if (lflag)
  8003fc:	85 d2                	test   %edx,%edx
  8003fe:	74 10                	je     800410 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 04             	lea    0x4(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
  80040e:	eb 0e                	jmp    80041e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800410:	8b 10                	mov    (%eax),%edx
  800412:	8d 4a 04             	lea    0x4(%edx),%ecx
  800415:	89 08                	mov    %ecx,(%eax)
  800417:	8b 02                	mov    (%edx),%eax
  800419:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800426:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	3b 50 04             	cmp    0x4(%eax),%edx
  80042f:	73 0a                	jae    80043b <sprintputch+0x1b>
		*b->buf++ = ch;
  800431:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800434:	88 0a                	mov    %cl,(%edx)
  800436:	83 c2 01             	add    $0x1,%edx
  800439:	89 10                	mov    %edx,(%eax)
}
  80043b:	5d                   	pop    %ebp
  80043c:	c3                   	ret    

0080043d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043d:	55                   	push   %ebp
  80043e:	89 e5                	mov    %esp,%ebp
  800440:	57                   	push   %edi
  800441:	56                   	push   %esi
  800442:	53                   	push   %ebx
  800443:	83 ec 5c             	sub    $0x5c,%esp
  800446:	8b 7d 08             	mov    0x8(%ebp),%edi
  800449:	8b 75 0c             	mov    0xc(%ebp),%esi
  80044c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800456:	eb 11                	jmp    800469 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800458:	85 c0                	test   %eax,%eax
  80045a:	0f 84 09 04 00 00    	je     800869 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800460:	89 74 24 04          	mov    %esi,0x4(%esp)
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800469:	0f b6 03             	movzbl (%ebx),%eax
  80046c:	83 c3 01             	add    $0x1,%ebx
  80046f:	83 f8 25             	cmp    $0x25,%eax
  800472:	75 e4                	jne    800458 <vprintfmt+0x1b>
  800474:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800478:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80047f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800486:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	eb 06                	jmp    80049a <vprintfmt+0x5d>
  800494:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800498:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	0f b6 13             	movzbl (%ebx),%edx
  80049d:	0f b6 c2             	movzbl %dl,%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8004a6:	83 ea 23             	sub    $0x23,%edx
  8004a9:	80 fa 55             	cmp    $0x55,%dl
  8004ac:	0f 87 9a 03 00 00    	ja     80084c <vprintfmt+0x40f>
  8004b2:	0f b6 d2             	movzbl %dl,%edx
  8004b5:	ff 24 95 80 16 80 00 	jmp    *0x801680(,%edx,4)
  8004bc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004c0:	eb d6                	jmp    800498 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c5:	83 ea 30             	sub    $0x30,%edx
  8004c8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8004cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004d1:	83 fb 09             	cmp    $0x9,%ebx
  8004d4:	77 4c                	ja     800522 <vprintfmt+0xe5>
  8004d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004df:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004e6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004e9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004ec:	83 fb 09             	cmp    $0x9,%ebx
  8004ef:	76 eb                	jbe    8004dc <vprintfmt+0x9f>
  8004f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f7:	eb 29                	jmp    800522 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004fc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800502:	8b 12                	mov    (%edx),%edx
  800504:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800507:	eb 19                	jmp    800522 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800509:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050c:	c1 fa 1f             	sar    $0x1f,%edx
  80050f:	f7 d2                	not    %edx
  800511:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800514:	eb 82                	jmp    800498 <vprintfmt+0x5b>
  800516:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80051d:	e9 76 ff ff ff       	jmp    800498 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800522:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800526:	0f 89 6c ff ff ff    	jns    800498 <vprintfmt+0x5b>
  80052c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80052f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800532:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800535:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800538:	e9 5b ff ff ff       	jmp    800498 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800540:	e9 53 ff ff ff       	jmp    800498 <vprintfmt+0x5b>
  800545:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	ff d7                	call   *%edi
  80055c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80055f:	e9 05 ff ff ff       	jmp    800469 <vprintfmt+0x2c>
  800564:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 c2                	mov    %eax,%edx
  800574:	c1 fa 1f             	sar    $0x1f,%edx
  800577:	31 d0                	xor    %edx,%eax
  800579:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057b:	83 f8 08             	cmp    $0x8,%eax
  80057e:	7f 0b                	jg     80058b <vprintfmt+0x14e>
  800580:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	75 20                	jne    8005ab <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80058b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058f:	c7 44 24 08 c9 15 80 	movl   $0x8015c9,0x8(%esp)
  800596:	00 
  800597:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059b:	89 3c 24             	mov    %edi,(%esp)
  80059e:	e8 4e 03 00 00       	call   8008f1 <printfmt>
  8005a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a6:	e9 be fe ff ff       	jmp    800469 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005af:	c7 44 24 08 d2 15 80 	movl   $0x8015d2,0x8(%esp)
  8005b6:	00 
  8005b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005bb:	89 3c 24             	mov    %edi,(%esp)
  8005be:	e8 2e 03 00 00       	call   8008f1 <printfmt>
  8005c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c6:	e9 9e fe ff ff       	jmp    800469 <vprintfmt+0x2c>
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ce:	89 c3                	mov    %eax,%ebx
  8005d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	75 07                	jne    8005f2 <vprintfmt+0x1b5>
  8005eb:	c7 45 c4 d5 15 80 00 	movl   $0x8015d5,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005f2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005f6:	7e 06                	jle    8005fe <vprintfmt+0x1c1>
  8005f8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005fc:	75 13                	jne    800611 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800601:	0f be 02             	movsbl (%edx),%eax
  800604:	85 c0                	test   %eax,%eax
  800606:	0f 85 99 00 00 00    	jne    8006a5 <vprintfmt+0x268>
  80060c:	e9 86 00 00 00       	jmp    800697 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800611:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800615:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800618:	89 0c 24             	mov    %ecx,(%esp)
  80061b:	e8 1b 03 00 00       	call   80093b <strnlen>
  800620:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800623:	29 c2                	sub    %eax,%edx
  800625:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800628:	85 d2                	test   %edx,%edx
  80062a:	7e d2                	jle    8005fe <vprintfmt+0x1c1>
					putch(padc, putdat);
  80062c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800630:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800633:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800636:	89 d3                	mov    %edx,%ebx
  800638:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	83 eb 01             	sub    $0x1,%ebx
  800647:	85 db                	test   %ebx,%ebx
  800649:	7f ed                	jg     800638 <vprintfmt+0x1fb>
  80064b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80064e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800655:	eb a7                	jmp    8005fe <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800657:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80065b:	74 18                	je     800675 <vprintfmt+0x238>
  80065d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800660:	83 fa 5e             	cmp    $0x5e,%edx
  800663:	76 10                	jbe    800675 <vprintfmt+0x238>
					putch('?', putdat);
  800665:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800669:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800670:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800673:	eb 0a                	jmp    80067f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800675:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800683:	0f be 03             	movsbl (%ebx),%eax
  800686:	85 c0                	test   %eax,%eax
  800688:	74 05                	je     80068f <vprintfmt+0x252>
  80068a:	83 c3 01             	add    $0x1,%ebx
  80068d:	eb 29                	jmp    8006b8 <vprintfmt+0x27b>
  80068f:	89 fe                	mov    %edi,%esi
  800691:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800694:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800697:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069b:	7f 2e                	jg     8006cb <vprintfmt+0x28e>
  80069d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a0:	e9 c4 fd ff ff       	jmp    800469 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006a8:	83 c2 01             	add    $0x1,%edx
  8006ab:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8006ae:	89 f7                	mov    %esi,%edi
  8006b0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006b3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006b6:	89 d3                	mov    %edx,%ebx
  8006b8:	85 f6                	test   %esi,%esi
  8006ba:	78 9b                	js     800657 <vprintfmt+0x21a>
  8006bc:	83 ee 01             	sub    $0x1,%esi
  8006bf:	79 96                	jns    800657 <vprintfmt+0x21a>
  8006c1:	89 fe                	mov    %edi,%esi
  8006c3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006c6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006c9:	eb cc                	jmp    800697 <vprintfmt+0x25a>
  8006cb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006de:	83 eb 01             	sub    $0x1,%ebx
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	7f ec                	jg     8006d1 <vprintfmt+0x294>
  8006e5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e8:	e9 7c fd ff ff       	jmp    800469 <vprintfmt+0x2c>
  8006ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f0:	83 f9 01             	cmp    $0x1,%ecx
  8006f3:	7e 16                	jle    80070b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 08             	lea    0x8(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	8b 48 04             	mov    0x4(%eax),%ecx
  800703:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800706:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800709:	eb 32                	jmp    80073d <vprintfmt+0x300>
	else if (lflag)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	74 18                	je     800727 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800725:	eb 16                	jmp    80073d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8d 50 04             	lea    0x4(%eax),%edx
  80072d:	89 55 14             	mov    %edx,0x14(%ebp)
  800730:	8b 00                	mov    (%eax),%eax
  800732:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800735:	89 c2                	mov    %eax,%edx
  800737:	c1 fa 1f             	sar    $0x1f,%edx
  80073a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800740:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800743:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800748:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80074c:	0f 89 b8 00 00 00    	jns    80080a <vprintfmt+0x3cd>
				putch('-', putdat);
  800752:	89 74 24 04          	mov    %esi,0x4(%esp)
  800756:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80075d:	ff d7                	call   *%edi
				num = -(long long) num;
  80075f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800762:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800765:	f7 d9                	neg    %ecx
  800767:	83 d3 00             	adc    $0x0,%ebx
  80076a:	f7 db                	neg    %ebx
  80076c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800771:	e9 94 00 00 00       	jmp    80080a <vprintfmt+0x3cd>
  800776:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800779:	89 ca                	mov    %ecx,%edx
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 63 fc ff ff       	call   8003e6 <getuint>
  800783:	89 c1                	mov    %eax,%ecx
  800785:	89 d3                	mov    %edx,%ebx
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80078c:	eb 7c                	jmp    80080a <vprintfmt+0x3cd>
  80078e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800791:	89 74 24 04          	mov    %esi,0x4(%esp)
  800795:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80079c:	ff d7                	call   *%edi
			putch('X', putdat);
  80079e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007a9:	ff d7                	call   *%edi
			putch('X', putdat);
  8007ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007af:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007b6:	ff d7                	call   *%edi
  8007b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007bb:	e9 a9 fc ff ff       	jmp    800469 <vprintfmt+0x2c>
  8007c0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ce:	ff d7                	call   *%edi
			putch('x', putdat);
  8007d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007db:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 08                	mov    (%eax),%ecx
  8007e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ed:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f2:	eb 16                	jmp    80080a <vprintfmt+0x3cd>
  8007f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f7:	89 ca                	mov    %ecx,%edx
  8007f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fc:	e8 e5 fb ff ff       	call   8003e6 <getuint>
  800801:	89 c1                	mov    %eax,%ecx
  800803:	89 d3                	mov    %edx,%ebx
  800805:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80080e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800812:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800815:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800819:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081d:	89 0c 24             	mov    %ecx,(%esp)
  800820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800824:	89 f2                	mov    %esi,%edx
  800826:	89 f8                	mov    %edi,%eax
  800828:	e8 c3 fa ff ff       	call   8002f0 <printnum>
  80082d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800830:	e9 34 fc ff ff       	jmp    800469 <vprintfmt+0x2c>
  800835:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800838:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083f:	89 14 24             	mov    %edx,(%esp)
  800842:	ff d7                	call   *%edi
  800844:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800847:	e9 1d fc ff ff       	jmp    800469 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800850:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800857:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800859:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80085c:	80 38 25             	cmpb   $0x25,(%eax)
  80085f:	0f 84 04 fc ff ff    	je     800469 <vprintfmt+0x2c>
  800865:	89 c3                	mov    %eax,%ebx
  800867:	eb f0                	jmp    800859 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800869:	83 c4 5c             	add    $0x5c,%esp
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5f                   	pop    %edi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 28             	sub    $0x28,%esp
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 04                	je     800885 <vsnprintf+0x14>
  800881:	85 d2                	test   %edx,%edx
  800883:	7f 07                	jg     80088c <vsnprintf+0x1b>
  800885:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088a:	eb 3b                	jmp    8008c7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800893:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b2:	c7 04 24 20 04 80 00 	movl   $0x800420,(%esp)
  8008b9:	e8 7f fb ff ff       	call   80043d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008cf:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	e8 82 ff ff ff       	call   800871 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800901:	89 44 24 08          	mov    %eax,0x8(%esp)
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	e8 26 fb ff ff       	call   80043d <vprintfmt>
	va_end(ap);
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    
  800919:	00 00                	add    %al,(%eax)
  80091b:	00 00                	add    %al,(%eax)
  80091d:	00 00                	add    %al,(%eax)
	...

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	80 3a 00             	cmpb   $0x0,(%edx)
  80092e:	74 09                	je     800939 <strlen+0x19>
		n++;
  800930:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800937:	75 f7                	jne    800930 <strlen+0x10>
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 19                	je     800962 <strnlen+0x27>
  800949:	80 3b 00             	cmpb   $0x0,(%ebx)
  80094c:	74 14                	je     800962 <strnlen+0x27>
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800953:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800956:	39 c8                	cmp    %ecx,%eax
  800958:	74 0d                	je     800967 <strnlen+0x2c>
  80095a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80095e:	75 f3                	jne    800953 <strnlen+0x18>
  800960:	eb 05                	jmp    800967 <strnlen+0x2c>
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800974:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800979:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80097d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	84 c9                	test   %cl,%cl
  800985:	75 f2                	jne    800979 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800994:	89 1c 24             	mov    %ebx,(%esp)
  800997:	e8 84 ff ff ff       	call   800920 <strlen>
	strcpy(dst + len, src);
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009a6:	89 04 24             	mov    %eax,(%esp)
  8009a9:	e8 bc ff ff ff       	call   80096a <strcpy>
	return dst;
}
  8009ae:	89 d8                	mov    %ebx,%eax
  8009b0:	83 c4 08             	add    $0x8,%esp
  8009b3:	5b                   	pop    %ebx
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c4:	85 f6                	test   %esi,%esi
  8009c6:	74 18                	je     8009e0 <strncpy+0x2a>
  8009c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	39 ce                	cmp    %ecx,%esi
  8009de:	77 ed                	ja     8009cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f2:	89 f0                	mov    %esi,%eax
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 27                	je     800a1f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009f8:	83 e9 01             	sub    $0x1,%ecx
  8009fb:	74 1d                	je     800a1a <strlcpy+0x36>
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	84 db                	test   %bl,%bl
  800a02:	74 16                	je     800a1a <strlcpy+0x36>
			*dst++ = *src++;
  800a04:	88 18                	mov    %bl,(%eax)
  800a06:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a09:	83 e9 01             	sub    $0x1,%ecx
  800a0c:	74 0e                	je     800a1c <strlcpy+0x38>
			*dst++ = *src++;
  800a0e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a11:	0f b6 1a             	movzbl (%edx),%ebx
  800a14:	84 db                	test   %bl,%bl
  800a16:	75 ec                	jne    800a04 <strlcpy+0x20>
  800a18:	eb 02                	jmp    800a1c <strlcpy+0x38>
  800a1a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a1c:	c6 00 00             	movb   $0x0,(%eax)
  800a1f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a2e:	0f b6 01             	movzbl (%ecx),%eax
  800a31:	84 c0                	test   %al,%al
  800a33:	74 15                	je     800a4a <strcmp+0x25>
  800a35:	3a 02                	cmp    (%edx),%al
  800a37:	75 11                	jne    800a4a <strcmp+0x25>
		p++, q++;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3f:	0f b6 01             	movzbl (%ecx),%eax
  800a42:	84 c0                	test   %al,%al
  800a44:	74 04                	je     800a4a <strcmp+0x25>
  800a46:	3a 02                	cmp    (%edx),%al
  800a48:	74 ef                	je     800a39 <strcmp+0x14>
  800a4a:	0f b6 c0             	movzbl %al,%eax
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	53                   	push   %ebx
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a61:	85 c0                	test   %eax,%eax
  800a63:	74 23                	je     800a88 <strncmp+0x34>
  800a65:	0f b6 1a             	movzbl (%edx),%ebx
  800a68:	84 db                	test   %bl,%bl
  800a6a:	74 25                	je     800a91 <strncmp+0x3d>
  800a6c:	3a 19                	cmp    (%ecx),%bl
  800a6e:	75 21                	jne    800a91 <strncmp+0x3d>
  800a70:	83 e8 01             	sub    $0x1,%eax
  800a73:	74 13                	je     800a88 <strncmp+0x34>
		n--, p++, q++;
  800a75:	83 c2 01             	add    $0x1,%edx
  800a78:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a7b:	0f b6 1a             	movzbl (%edx),%ebx
  800a7e:	84 db                	test   %bl,%bl
  800a80:	74 0f                	je     800a91 <strncmp+0x3d>
  800a82:	3a 19                	cmp    (%ecx),%bl
  800a84:	74 ea                	je     800a70 <strncmp+0x1c>
  800a86:	eb 09                	jmp    800a91 <strncmp+0x3d>
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5d                   	pop    %ebp
  800a8f:	90                   	nop
  800a90:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a91:	0f b6 02             	movzbl (%edx),%eax
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	29 d0                	sub    %edx,%eax
  800a99:	eb f2                	jmp    800a8d <strncmp+0x39>

00800a9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 18                	je     800ac4 <strchr+0x29>
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	75 0a                	jne    800aba <strchr+0x1f>
  800ab0:	eb 17                	jmp    800ac9 <strchr+0x2e>
  800ab2:	38 ca                	cmp    %cl,%dl
  800ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ab8:	74 0f                	je     800ac9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 ee                	jne    800ab2 <strchr+0x17>
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	0f b6 10             	movzbl (%eax),%edx
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	74 18                	je     800af4 <strfind+0x29>
		if (*s == c)
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	75 0a                	jne    800aea <strfind+0x1f>
  800ae0:	eb 12                	jmp    800af4 <strfind+0x29>
  800ae2:	38 ca                	cmp    %cl,%dl
  800ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ae8:	74 0a                	je     800af4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 ee                	jne    800ae2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	89 1c 24             	mov    %ebx,(%esp)
  800aff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b10:	85 c9                	test   %ecx,%ecx
  800b12:	74 30                	je     800b44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1a:	75 25                	jne    800b41 <memset+0x4b>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 20                	jne    800b41 <memset+0x4b>
		c &= 0xFF;
  800b21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	c1 e3 08             	shl    $0x8,%ebx
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	c1 e6 18             	shl    $0x18,%esi
  800b2e:	89 d0                	mov    %edx,%eax
  800b30:	c1 e0 10             	shl    $0x10,%eax
  800b33:	09 f0                	or     %esi,%eax
  800b35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b37:	09 d8                	or     %ebx,%eax
  800b39:	c1 e9 02             	shr    $0x2,%ecx
  800b3c:	fc                   	cld    
  800b3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3f:	eb 03                	jmp    800b44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b41:	fc                   	cld    
  800b42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	8b 1c 24             	mov    (%esp),%ebx
  800b49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b51:	89 ec                	mov    %ebp,%esp
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	89 34 24             	mov    %esi,(%esp)
  800b5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b6d:	39 c6                	cmp    %eax,%esi
  800b6f:	73 35                	jae    800ba6 <memmove+0x51>
  800b71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b74:	39 d0                	cmp    %edx,%eax
  800b76:	73 2e                	jae    800ba6 <memmove+0x51>
		s += n;
		d += n;
  800b78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	f6 c2 03             	test   $0x3,%dl
  800b7d:	75 1b                	jne    800b9a <memmove+0x45>
  800b7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b85:	75 13                	jne    800b9a <memmove+0x45>
  800b87:	f6 c1 03             	test   $0x3,%cl
  800b8a:	75 0e                	jne    800b9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b8c:	83 ef 04             	sub    $0x4,%edi
  800b8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b92:	c1 e9 02             	shr    $0x2,%ecx
  800b95:	fd                   	std    
  800b96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b98:	eb 09                	jmp    800ba3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9a:	83 ef 01             	sub    $0x1,%edi
  800b9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba0:	fd                   	std    
  800ba1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba4:	eb 20                	jmp    800bc6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bac:	75 15                	jne    800bc3 <memmove+0x6e>
  800bae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb4:	75 0d                	jne    800bc3 <memmove+0x6e>
  800bb6:	f6 c1 03             	test   $0x3,%cl
  800bb9:	75 08                	jne    800bc3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bbb:	c1 e9 02             	shr    $0x2,%ecx
  800bbe:	fc                   	cld    
  800bbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	eb 03                	jmp    800bc6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc3:	fc                   	cld    
  800bc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc6:	8b 34 24             	mov    (%esp),%esi
  800bc9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bcd:	89 ec                	mov    %ebp,%esp
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	89 04 24             	mov    %eax,(%esp)
  800beb:	e8 65 ff ff ff       	call   800b55 <memmove>
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c01:	85 c9                	test   %ecx,%ecx
  800c03:	74 36                	je     800c3b <memcmp+0x49>
		if (*s1 != *s2)
  800c05:	0f b6 06             	movzbl (%esi),%eax
  800c08:	0f b6 1f             	movzbl (%edi),%ebx
  800c0b:	38 d8                	cmp    %bl,%al
  800c0d:	74 20                	je     800c2f <memcmp+0x3d>
  800c0f:	eb 14                	jmp    800c25 <memcmp+0x33>
  800c11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c1b:	83 c2 01             	add    $0x1,%edx
  800c1e:	83 e9 01             	sub    $0x1,%ecx
  800c21:	38 d8                	cmp    %bl,%al
  800c23:	74 12                	je     800c37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c25:	0f b6 c0             	movzbl %al,%eax
  800c28:	0f b6 db             	movzbl %bl,%ebx
  800c2b:	29 d8                	sub    %ebx,%eax
  800c2d:	eb 11                	jmp    800c40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2f:	83 e9 01             	sub    $0x1,%ecx
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	85 c9                	test   %ecx,%ecx
  800c39:	75 d6                	jne    800c11 <memcmp+0x1f>
  800c3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c4b:	89 c2                	mov    %eax,%edx
  800c4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c50:	39 d0                	cmp    %edx,%eax
  800c52:	73 15                	jae    800c69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c58:	38 08                	cmp    %cl,(%eax)
  800c5a:	75 06                	jne    800c62 <memfind+0x1d>
  800c5c:	eb 0b                	jmp    800c69 <memfind+0x24>
  800c5e:	38 08                	cmp    %cl,(%eax)
  800c60:	74 07                	je     800c69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c62:	83 c0 01             	add    $0x1,%eax
  800c65:	39 c2                	cmp    %eax,%edx
  800c67:	77 f5                	ja     800c5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 04             	sub    $0x4,%esp
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7a:	0f b6 02             	movzbl (%edx),%eax
  800c7d:	3c 20                	cmp    $0x20,%al
  800c7f:	74 04                	je     800c85 <strtol+0x1a>
  800c81:	3c 09                	cmp    $0x9,%al
  800c83:	75 0e                	jne    800c93 <strtol+0x28>
		s++;
  800c85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c88:	0f b6 02             	movzbl (%edx),%eax
  800c8b:	3c 20                	cmp    $0x20,%al
  800c8d:	74 f6                	je     800c85 <strtol+0x1a>
  800c8f:	3c 09                	cmp    $0x9,%al
  800c91:	74 f2                	je     800c85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c93:	3c 2b                	cmp    $0x2b,%al
  800c95:	75 0c                	jne    800ca3 <strtol+0x38>
		s++;
  800c97:	83 c2 01             	add    $0x1,%edx
  800c9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ca1:	eb 15                	jmp    800cb8 <strtol+0x4d>
	else if (*s == '-')
  800ca3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800caa:	3c 2d                	cmp    $0x2d,%al
  800cac:	75 0a                	jne    800cb8 <strtol+0x4d>
		s++, neg = 1;
  800cae:	83 c2 01             	add    $0x1,%edx
  800cb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	85 db                	test   %ebx,%ebx
  800cba:	0f 94 c0             	sete   %al
  800cbd:	74 05                	je     800cc4 <strtol+0x59>
  800cbf:	83 fb 10             	cmp    $0x10,%ebx
  800cc2:	75 18                	jne    800cdc <strtol+0x71>
  800cc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc7:	75 13                	jne    800cdc <strtol+0x71>
  800cc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ccd:	8d 76 00             	lea    0x0(%esi),%esi
  800cd0:	75 0a                	jne    800cdc <strtol+0x71>
		s += 2, base = 16;
  800cd2:	83 c2 02             	add    $0x2,%edx
  800cd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cda:	eb 15                	jmp    800cf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cdc:	84 c0                	test   %al,%al
  800cde:	66 90                	xchg   %ax,%ax
  800ce0:	74 0f                	je     800cf1 <strtol+0x86>
  800ce2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ce7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cea:	75 05                	jne    800cf1 <strtol+0x86>
		s++, base = 8;
  800cec:	83 c2 01             	add    $0x1,%edx
  800cef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf8:	0f b6 0a             	movzbl (%edx),%ecx
  800cfb:	89 cf                	mov    %ecx,%edi
  800cfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d00:	80 fb 09             	cmp    $0x9,%bl
  800d03:	77 08                	ja     800d0d <strtol+0xa2>
			dig = *s - '0';
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 30             	sub    $0x30,%ecx
  800d0b:	eb 1e                	jmp    800d2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d10:	80 fb 19             	cmp    $0x19,%bl
  800d13:	77 08                	ja     800d1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d15:	0f be c9             	movsbl %cl,%ecx
  800d18:	83 e9 57             	sub    $0x57,%ecx
  800d1b:	eb 0e                	jmp    800d2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d20:	80 fb 19             	cmp    $0x19,%bl
  800d23:	77 15                	ja     800d3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d25:	0f be c9             	movsbl %cl,%ecx
  800d28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d2b:	39 f1                	cmp    %esi,%ecx
  800d2d:	7d 0b                	jge    800d3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d2f:	83 c2 01             	add    $0x1,%edx
  800d32:	0f af c6             	imul   %esi,%eax
  800d35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d38:	eb be                	jmp    800cf8 <strtol+0x8d>
  800d3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d40:	74 05                	je     800d47 <strtol+0xdc>
		*endptr = (char *) s;
  800d42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d4b:	74 04                	je     800d51 <strtol+0xe6>
  800d4d:	89 c8                	mov    %ecx,%eax
  800d4f:	f7 d8                	neg    %eax
}
  800d51:	83 c4 04             	add    $0x4,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    
  800d59:	00 00                	add    %al,(%eax)
	...

00800d5c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 08             	sub    $0x8,%esp
  800d62:	89 1c 24             	mov    %ebx,(%esp)
  800d65:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d69:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d73:	89 d1                	mov    %edx,%ecx
  800d75:	89 d3                	mov    %edx,%ebx
  800d77:	89 d7                	mov    %edx,%edi
  800d79:	51                   	push   %ecx
  800d7a:	52                   	push   %edx
  800d7b:	53                   	push   %ebx
  800d7c:	54                   	push   %esp
  800d7d:	55                   	push   %ebp
  800d7e:	56                   	push   %esi
  800d7f:	57                   	push   %edi
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	8d 35 8a 0d 80 00    	lea    0x800d8a,%esi
  800d88:	0f 34                	sysenter 
  800d8a:	5f                   	pop    %edi
  800d8b:	5e                   	pop    %esi
  800d8c:	5d                   	pop    %ebp
  800d8d:	5c                   	pop    %esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5a                   	pop    %edx
  800d90:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d91:	8b 1c 24             	mov    (%esp),%ebx
  800d94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 08             	sub    $0x8,%esp
  800da2:	89 1c 24             	mov    %ebx,(%esp)
  800da5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 c3                	mov    %eax,%ebx
  800db6:	89 c7                	mov    %eax,%edi
  800db8:	51                   	push   %ecx
  800db9:	52                   	push   %edx
  800dba:	53                   	push   %ebx
  800dbb:	54                   	push   %esp
  800dbc:	55                   	push   %ebp
  800dbd:	56                   	push   %esi
  800dbe:	57                   	push   %edi
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	8d 35 c9 0d 80 00    	lea    0x800dc9,%esi
  800dc7:	0f 34                	sysenter 
  800dc9:	5f                   	pop    %edi
  800dca:	5e                   	pop    %esi
  800dcb:	5d                   	pop    %ebp
  800dcc:	5c                   	pop    %esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5a                   	pop    %edx
  800dcf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dd0:	8b 1c 24             	mov    (%esp),%ebx
  800dd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	89 1c 24             	mov    %ebx,(%esp)
  800de4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ded:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 cb                	mov    %ecx,%ebx
  800df7:	89 cf                	mov    %ecx,%edi
  800df9:	51                   	push   %ecx
  800dfa:	52                   	push   %edx
  800dfb:	53                   	push   %ebx
  800dfc:	54                   	push   %esp
  800dfd:	55                   	push   %ebp
  800dfe:	56                   	push   %esi
  800dff:	57                   	push   %edi
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	8d 35 0a 0e 80 00    	lea    0x800e0a,%esi
  800e08:	0f 34                	sysenter 
  800e0a:	5f                   	pop    %edi
  800e0b:	5e                   	pop    %esi
  800e0c:	5d                   	pop    %ebp
  800e0d:	5c                   	pop    %esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5a                   	pop    %edx
  800e10:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800e11:	8b 1c 24             	mov    (%esp),%ebx
  800e14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 28             	sub    $0x28,%esp
  800e22:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e25:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	89 cb                	mov    %ecx,%ebx
  800e37:	89 cf                	mov    %ecx,%edi
  800e39:	51                   	push   %ecx
  800e3a:	52                   	push   %edx
  800e3b:	53                   	push   %ebx
  800e3c:	54                   	push   %esp
  800e3d:	55                   	push   %ebp
  800e3e:	56                   	push   %esi
  800e3f:	57                   	push   %edi
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	8d 35 4a 0e 80 00    	lea    0x800e4a,%esi
  800e48:	0f 34                	sysenter 
  800e4a:	5f                   	pop    %edi
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	5c                   	pop    %esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5a                   	pop    %edx
  800e50:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800e78:	e8 37 f3 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e83:	89 ec                	mov    %ebp,%esp
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	89 1c 24             	mov    %ebx,(%esp)
  800e90:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	51                   	push   %ecx
  800ea6:	52                   	push   %edx
  800ea7:	53                   	push   %ebx
  800ea8:	54                   	push   %esp
  800ea9:	55                   	push   %ebp
  800eaa:	56                   	push   %esi
  800eab:	57                   	push   %edi
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	8d 35 b6 0e 80 00    	lea    0x800eb6,%esi
  800eb4:	0f 34                	sysenter 
  800eb6:	5f                   	pop    %edi
  800eb7:	5e                   	pop    %esi
  800eb8:	5d                   	pop    %ebp
  800eb9:	5c                   	pop    %esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5a                   	pop    %edx
  800ebc:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ebd:	8b 1c 24             	mov    (%esp),%ebx
  800ec0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec4:	89 ec                	mov    %ebp,%esp
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 28             	sub    $0x28,%esp
  800ece:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ed1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	51                   	push   %ecx
  800ee7:	52                   	push   %edx
  800ee8:	53                   	push   %ebx
  800ee9:	54                   	push   %esp
  800eea:	55                   	push   %ebp
  800eeb:	56                   	push   %esi
  800eec:	57                   	push   %edi
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	8d 35 f7 0e 80 00    	lea    0x800ef7,%esi
  800ef5:	0f 34                	sysenter 
  800ef7:	5f                   	pop    %edi
  800ef8:	5e                   	pop    %esi
  800ef9:	5d                   	pop    %ebp
  800efa:	5c                   	pop    %esp
  800efb:	5b                   	pop    %ebx
  800efc:	5a                   	pop    %edx
  800efd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800efe:	85 c0                	test   %eax,%eax
  800f00:	7e 28                	jle    800f2a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f06:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f0d:	00 
  800f0e:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800f25:	e8 8a f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f30:	89 ec                	mov    %ebp,%esp
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 28             	sub    $0x28,%esp
  800f3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f3d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f45:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	89 df                	mov    %ebx,%edi
  800f52:	51                   	push   %ecx
  800f53:	52                   	push   %edx
  800f54:	53                   	push   %ebx
  800f55:	54                   	push   %esp
  800f56:	55                   	push   %ebp
  800f57:	56                   	push   %esi
  800f58:	57                   	push   %edi
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	8d 35 63 0f 80 00    	lea    0x800f63,%esi
  800f61:	0f 34                	sysenter 
  800f63:	5f                   	pop    %edi
  800f64:	5e                   	pop    %esi
  800f65:	5d                   	pop    %ebp
  800f66:	5c                   	pop    %esp
  800f67:	5b                   	pop    %ebx
  800f68:	5a                   	pop    %edx
  800f69:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 28                	jle    800f96 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f72:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f79:	00 
  800f7a:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800f91:	e8 1e f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f96:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9c:	89 ec                	mov    %ebp,%esp
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 28             	sub    $0x28,%esp
  800fa6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fa9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	89 df                	mov    %ebx,%edi
  800fbe:	51                   	push   %ecx
  800fbf:	52                   	push   %edx
  800fc0:	53                   	push   %ebx
  800fc1:	54                   	push   %esp
  800fc2:	55                   	push   %ebp
  800fc3:	56                   	push   %esi
  800fc4:	57                   	push   %edi
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	8d 35 cf 0f 80 00    	lea    0x800fcf,%esi
  800fcd:	0f 34                	sysenter 
  800fcf:	5f                   	pop    %edi
  800fd0:	5e                   	pop    %esi
  800fd1:	5d                   	pop    %ebp
  800fd2:	5c                   	pop    %esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5a                   	pop    %edx
  800fd5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	7e 28                	jle    801002 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fde:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800fe5:	00 
  800fe6:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800fed:	00 
  800fee:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ff5:	00 
  800ff6:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800ffd:	e8 b2 f1 ff ff       	call   8001b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801002:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801005:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801008:	89 ec                	mov    %ebp,%esp
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 28             	sub    $0x28,%esp
  801012:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801015:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801018:	b8 06 00 00 00       	mov    $0x6,%eax
  80101d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801020:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	51                   	push   %ecx
  80102a:	52                   	push   %edx
  80102b:	53                   	push   %ebx
  80102c:	54                   	push   %esp
  80102d:	55                   	push   %ebp
  80102e:	56                   	push   %esi
  80102f:	57                   	push   %edi
  801030:	89 e5                	mov    %esp,%ebp
  801032:	8d 35 3a 10 80 00    	lea    0x80103a,%esi
  801038:	0f 34                	sysenter 
  80103a:	5f                   	pop    %edi
  80103b:	5e                   	pop    %esi
  80103c:	5d                   	pop    %ebp
  80103d:	5c                   	pop    %esp
  80103e:	5b                   	pop    %ebx
  80103f:	5a                   	pop    %edx
  801040:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	7e 28                	jle    80106d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801045:	89 44 24 10          	mov    %eax,0x10(%esp)
  801049:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801050:	00 
  801051:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  801068:	e8 47 f1 ff ff       	call   8001b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80106d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801070:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801073:	89 ec                	mov    %ebp,%esp
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 28             	sub    $0x28,%esp
  80107d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801080:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801083:	bf 00 00 00 00       	mov    $0x0,%edi
  801088:	b8 05 00 00 00       	mov    $0x5,%eax
  80108d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801093:	8b 55 08             	mov    0x8(%ebp),%edx
  801096:	51                   	push   %ecx
  801097:	52                   	push   %edx
  801098:	53                   	push   %ebx
  801099:	54                   	push   %esp
  80109a:	55                   	push   %ebp
  80109b:	56                   	push   %esi
  80109c:	57                   	push   %edi
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	8d 35 a7 10 80 00    	lea    0x8010a7,%esi
  8010a5:	0f 34                	sysenter 
  8010a7:	5f                   	pop    %edi
  8010a8:	5e                   	pop    %esi
  8010a9:	5d                   	pop    %ebp
  8010aa:	5c                   	pop    %esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5a                   	pop    %edx
  8010ad:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	7e 28                	jle    8010da <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010bd:	00 
  8010be:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  8010d5:	e8 da f0 ff ff       	call   8001b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010da:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010dd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e0:	89 ec                	mov    %ebp,%esp
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	89 1c 24             	mov    %ebx,(%esp)
  8010ed:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010fb:	89 d1                	mov    %edx,%ecx
  8010fd:	89 d3                	mov    %edx,%ebx
  8010ff:	89 d7                	mov    %edx,%edi
  801101:	51                   	push   %ecx
  801102:	52                   	push   %edx
  801103:	53                   	push   %ebx
  801104:	54                   	push   %esp
  801105:	55                   	push   %ebp
  801106:	56                   	push   %esi
  801107:	57                   	push   %edi
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	8d 35 12 11 80 00    	lea    0x801112,%esi
  801110:	0f 34                	sysenter 
  801112:	5f                   	pop    %edi
  801113:	5e                   	pop    %esi
  801114:	5d                   	pop    %ebp
  801115:	5c                   	pop    %esp
  801116:	5b                   	pop    %ebx
  801117:	5a                   	pop    %edx
  801118:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801119:	8b 1c 24             	mov    (%esp),%ebx
  80111c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801120:	89 ec                	mov    %ebp,%esp
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 08             	sub    $0x8,%esp
  80112a:	89 1c 24             	mov    %ebx,(%esp)
  80112d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801131:	bb 00 00 00 00       	mov    $0x0,%ebx
  801136:	b8 04 00 00 00       	mov    $0x4,%eax
  80113b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113e:	8b 55 08             	mov    0x8(%ebp),%edx
  801141:	89 df                	mov    %ebx,%edi
  801143:	51                   	push   %ecx
  801144:	52                   	push   %edx
  801145:	53                   	push   %ebx
  801146:	54                   	push   %esp
  801147:	55                   	push   %ebp
  801148:	56                   	push   %esi
  801149:	57                   	push   %edi
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	8d 35 54 11 80 00    	lea    0x801154,%esi
  801152:	0f 34                	sysenter 
  801154:	5f                   	pop    %edi
  801155:	5e                   	pop    %esi
  801156:	5d                   	pop    %ebp
  801157:	5c                   	pop    %esp
  801158:	5b                   	pop    %ebx
  801159:	5a                   	pop    %edx
  80115a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80115b:	8b 1c 24             	mov    (%esp),%ebx
  80115e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801162:	89 ec                	mov    %ebp,%esp
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	89 1c 24             	mov    %ebx,(%esp)
  80116f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801173:	ba 00 00 00 00       	mov    $0x0,%edx
  801178:	b8 02 00 00 00       	mov    $0x2,%eax
  80117d:	89 d1                	mov    %edx,%ecx
  80117f:	89 d3                	mov    %edx,%ebx
  801181:	89 d7                	mov    %edx,%edi
  801183:	51                   	push   %ecx
  801184:	52                   	push   %edx
  801185:	53                   	push   %ebx
  801186:	54                   	push   %esp
  801187:	55                   	push   %ebp
  801188:	56                   	push   %esi
  801189:	57                   	push   %edi
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	8d 35 94 11 80 00    	lea    0x801194,%esi
  801192:	0f 34                	sysenter 
  801194:	5f                   	pop    %edi
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	5c                   	pop    %esp
  801198:	5b                   	pop    %ebx
  801199:	5a                   	pop    %edx
  80119a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80119b:	8b 1c 24             	mov    (%esp),%ebx
  80119e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011a2:	89 ec                	mov    %ebp,%esp
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	83 ec 28             	sub    $0x28,%esp
  8011ac:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011af:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011b7:	b8 03 00 00 00       	mov    $0x3,%eax
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	89 cb                	mov    %ecx,%ebx
  8011c1:	89 cf                	mov    %ecx,%edi
  8011c3:	51                   	push   %ecx
  8011c4:	52                   	push   %edx
  8011c5:	53                   	push   %ebx
  8011c6:	54                   	push   %esp
  8011c7:	55                   	push   %ebp
  8011c8:	56                   	push   %esi
  8011c9:	57                   	push   %edi
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	8d 35 d4 11 80 00    	lea    0x8011d4,%esi
  8011d2:	0f 34                	sysenter 
  8011d4:	5f                   	pop    %edi
  8011d5:	5e                   	pop    %esi
  8011d6:	5d                   	pop    %ebp
  8011d7:	5c                   	pop    %esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5a                   	pop    %edx
  8011da:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	7e 28                	jle    801207 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  801202:	e8 ad ef ff ff       	call   8001b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801207:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80120a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80120d:	89 ec                	mov    %ebp,%esp
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    
  801211:	00 00                	add    %al,(%eax)
	...

00801214 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80121a:	c7 44 24 08 2f 18 80 	movl   $0x80182f,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  801231:	e8 7e ef ff ff       	call   8001b4 <_panic>

00801236 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80123c:	c7 44 24 08 30 18 80 	movl   $0x801830,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80124b:	00 
  80124c:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  801253:	e8 5c ef ff ff       	call   8001b4 <_panic>

00801258 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80125e:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801264:	b8 01 00 00 00       	mov    $0x1,%eax
  801269:	39 ca                	cmp    %ecx,%edx
  80126b:	75 04                	jne    801271 <ipc_find_env+0x19>
  80126d:	b0 00                	mov    $0x0,%al
  80126f:	eb 11                	jmp    801282 <ipc_find_env+0x2a>
  801271:	89 c2                	mov    %eax,%edx
  801273:	c1 e2 07             	shl    $0x7,%edx
  801276:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  80127c:	8b 12                	mov    (%edx),%edx
  80127e:	39 ca                	cmp    %ecx,%edx
  801280:	75 0f                	jne    801291 <ipc_find_env+0x39>
			return envs[i].env_id;
  801282:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801286:	c1 e0 06             	shl    $0x6,%eax
  801289:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  80128f:	eb 0e                	jmp    80129f <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801291:	83 c0 01             	add    $0x1,%eax
  801294:	3d 00 04 00 00       	cmp    $0x400,%eax
  801299:	75 d6                	jne    801271 <ipc_find_env+0x19>
  80129b:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8012a7:	c7 44 24 08 50 18 80 	movl   $0x801850,0x8(%esp)
  8012ae:	00 
  8012af:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8012b6:	00 
  8012b7:	c7 04 24 69 18 80 00 	movl   $0x801869,(%esp)
  8012be:	e8 f1 ee ff ff       	call   8001b4 <_panic>

008012c3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8012c9:	c7 44 24 08 73 18 80 	movl   $0x801873,0x8(%esp)
  8012d0:	00 
  8012d1:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8012d8:	00 
  8012d9:	c7 04 24 69 18 80 00 	movl   $0x801869,(%esp)
  8012e0:	e8 cf ee ff ff       	call   8001b4 <_panic>
	...

008012f0 <__udivdi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	83 ec 10             	sub    $0x10,%esp
  8012f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fe:	8b 75 10             	mov    0x10(%ebp),%esi
  801301:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801304:	85 c0                	test   %eax,%eax
  801306:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801309:	75 35                	jne    801340 <__udivdi3+0x50>
  80130b:	39 fe                	cmp    %edi,%esi
  80130d:	77 61                	ja     801370 <__udivdi3+0x80>
  80130f:	85 f6                	test   %esi,%esi
  801311:	75 0b                	jne    80131e <__udivdi3+0x2e>
  801313:	b8 01 00 00 00       	mov    $0x1,%eax
  801318:	31 d2                	xor    %edx,%edx
  80131a:	f7 f6                	div    %esi
  80131c:	89 c6                	mov    %eax,%esi
  80131e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801321:	31 d2                	xor    %edx,%edx
  801323:	89 f8                	mov    %edi,%eax
  801325:	f7 f6                	div    %esi
  801327:	89 c7                	mov    %eax,%edi
  801329:	89 c8                	mov    %ecx,%eax
  80132b:	f7 f6                	div    %esi
  80132d:	89 c1                	mov    %eax,%ecx
  80132f:	89 fa                	mov    %edi,%edx
  801331:	89 c8                	mov    %ecx,%eax
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
  80133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801340:	39 f8                	cmp    %edi,%eax
  801342:	77 1c                	ja     801360 <__udivdi3+0x70>
  801344:	0f bd d0             	bsr    %eax,%edx
  801347:	83 f2 1f             	xor    $0x1f,%edx
  80134a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80134d:	75 39                	jne    801388 <__udivdi3+0x98>
  80134f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801352:	0f 86 a0 00 00 00    	jbe    8013f8 <__udivdi3+0x108>
  801358:	39 f8                	cmp    %edi,%eax
  80135a:	0f 82 98 00 00 00    	jb     8013f8 <__udivdi3+0x108>
  801360:	31 ff                	xor    %edi,%edi
  801362:	31 c9                	xor    %ecx,%ecx
  801364:	89 c8                	mov    %ecx,%eax
  801366:	89 fa                	mov    %edi,%edx
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    
  80136f:	90                   	nop
  801370:	89 d1                	mov    %edx,%ecx
  801372:	89 fa                	mov    %edi,%edx
  801374:	89 c8                	mov    %ecx,%eax
  801376:	31 ff                	xor    %edi,%edi
  801378:	f7 f6                	div    %esi
  80137a:	89 c1                	mov    %eax,%ecx
  80137c:	89 fa                	mov    %edi,%edx
  80137e:	89 c8                	mov    %ecx,%eax
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	5e                   	pop    %esi
  801384:	5f                   	pop    %edi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    
  801387:	90                   	nop
  801388:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80138c:	89 f2                	mov    %esi,%edx
  80138e:	d3 e0                	shl    %cl,%eax
  801390:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801393:	b8 20 00 00 00       	mov    $0x20,%eax
  801398:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80139b:	89 c1                	mov    %eax,%ecx
  80139d:	d3 ea                	shr    %cl,%edx
  80139f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8013a6:	d3 e6                	shl    %cl,%esi
  8013a8:	89 c1                	mov    %eax,%ecx
  8013aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8013ad:	89 fe                	mov    %edi,%esi
  8013af:	d3 ee                	shr    %cl,%esi
  8013b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013bb:	d3 e7                	shl    %cl,%edi
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	d3 ea                	shr    %cl,%edx
  8013c1:	09 d7                	or     %edx,%edi
  8013c3:	89 f2                	mov    %esi,%edx
  8013c5:	89 f8                	mov    %edi,%eax
  8013c7:	f7 75 ec             	divl   -0x14(%ebp)
  8013ca:	89 d6                	mov    %edx,%esi
  8013cc:	89 c7                	mov    %eax,%edi
  8013ce:	f7 65 e8             	mull   -0x18(%ebp)
  8013d1:	39 d6                	cmp    %edx,%esi
  8013d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013d6:	72 30                	jb     801408 <__udivdi3+0x118>
  8013d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013df:	d3 e2                	shl    %cl,%edx
  8013e1:	39 c2                	cmp    %eax,%edx
  8013e3:	73 05                	jae    8013ea <__udivdi3+0xfa>
  8013e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8013e8:	74 1e                	je     801408 <__udivdi3+0x118>
  8013ea:	89 f9                	mov    %edi,%ecx
  8013ec:	31 ff                	xor    %edi,%edi
  8013ee:	e9 71 ff ff ff       	jmp    801364 <__udivdi3+0x74>
  8013f3:	90                   	nop
  8013f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	31 ff                	xor    %edi,%edi
  8013fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8013ff:	e9 60 ff ff ff       	jmp    801364 <__udivdi3+0x74>
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80140b:	31 ff                	xor    %edi,%edi
  80140d:	89 c8                	mov    %ecx,%eax
  80140f:	89 fa                	mov    %edi,%edx
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    
	...

00801420 <__umoddi3>:
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	83 ec 20             	sub    $0x20,%esp
  801428:	8b 55 14             	mov    0x14(%ebp),%edx
  80142b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801431:	8b 75 0c             	mov    0xc(%ebp),%esi
  801434:	85 d2                	test   %edx,%edx
  801436:	89 c8                	mov    %ecx,%eax
  801438:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80143b:	75 13                	jne    801450 <__umoddi3+0x30>
  80143d:	39 f7                	cmp    %esi,%edi
  80143f:	76 3f                	jbe    801480 <__umoddi3+0x60>
  801441:	89 f2                	mov    %esi,%edx
  801443:	f7 f7                	div    %edi
  801445:	89 d0                	mov    %edx,%eax
  801447:	31 d2                	xor    %edx,%edx
  801449:	83 c4 20             	add    $0x20,%esp
  80144c:	5e                   	pop    %esi
  80144d:	5f                   	pop    %edi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    
  801450:	39 f2                	cmp    %esi,%edx
  801452:	77 4c                	ja     8014a0 <__umoddi3+0x80>
  801454:	0f bd ca             	bsr    %edx,%ecx
  801457:	83 f1 1f             	xor    $0x1f,%ecx
  80145a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80145d:	75 51                	jne    8014b0 <__umoddi3+0x90>
  80145f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801462:	0f 87 e0 00 00 00    	ja     801548 <__umoddi3+0x128>
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	29 f8                	sub    %edi,%eax
  80146d:	19 d6                	sbb    %edx,%esi
  80146f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801475:	89 f2                	mov    %esi,%edx
  801477:	83 c4 20             	add    $0x20,%esp
  80147a:	5e                   	pop    %esi
  80147b:	5f                   	pop    %edi
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    
  80147e:	66 90                	xchg   %ax,%ax
  801480:	85 ff                	test   %edi,%edi
  801482:	75 0b                	jne    80148f <__umoddi3+0x6f>
  801484:	b8 01 00 00 00       	mov    $0x1,%eax
  801489:	31 d2                	xor    %edx,%edx
  80148b:	f7 f7                	div    %edi
  80148d:	89 c7                	mov    %eax,%edi
  80148f:	89 f0                	mov    %esi,%eax
  801491:	31 d2                	xor    %edx,%edx
  801493:	f7 f7                	div    %edi
  801495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801498:	f7 f7                	div    %edi
  80149a:	eb a9                	jmp    801445 <__umoddi3+0x25>
  80149c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	89 c8                	mov    %ecx,%eax
  8014a2:	89 f2                	mov    %esi,%edx
  8014a4:	83 c4 20             	add    $0x20,%esp
  8014a7:	5e                   	pop    %esi
  8014a8:	5f                   	pop    %edi
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    
  8014ab:	90                   	nop
  8014ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014b4:	d3 e2                	shl    %cl,%edx
  8014b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8014be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8014c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014c8:	89 fa                	mov    %edi,%edx
  8014ca:	d3 ea                	shr    %cl,%edx
  8014cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8014d3:	d3 e7                	shl    %cl,%edi
  8014d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014dc:	89 f2                	mov    %esi,%edx
  8014de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8014e1:	89 c7                	mov    %eax,%edi
  8014e3:	d3 ea                	shr    %cl,%edx
  8014e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8014ec:	89 c2                	mov    %eax,%edx
  8014ee:	d3 e6                	shl    %cl,%esi
  8014f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014f4:	d3 ea                	shr    %cl,%edx
  8014f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014fa:	09 d6                	or     %edx,%esi
  8014fc:	89 f0                	mov    %esi,%eax
  8014fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801501:	d3 e7                	shl    %cl,%edi
  801503:	89 f2                	mov    %esi,%edx
  801505:	f7 75 f4             	divl   -0xc(%ebp)
  801508:	89 d6                	mov    %edx,%esi
  80150a:	f7 65 e8             	mull   -0x18(%ebp)
  80150d:	39 d6                	cmp    %edx,%esi
  80150f:	72 2b                	jb     80153c <__umoddi3+0x11c>
  801511:	39 c7                	cmp    %eax,%edi
  801513:	72 23                	jb     801538 <__umoddi3+0x118>
  801515:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801519:	29 c7                	sub    %eax,%edi
  80151b:	19 d6                	sbb    %edx,%esi
  80151d:	89 f0                	mov    %esi,%eax
  80151f:	89 f2                	mov    %esi,%edx
  801521:	d3 ef                	shr    %cl,%edi
  801523:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801527:	d3 e0                	shl    %cl,%eax
  801529:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80152d:	09 f8                	or     %edi,%eax
  80152f:	d3 ea                	shr    %cl,%edx
  801531:	83 c4 20             	add    $0x20,%esp
  801534:	5e                   	pop    %esi
  801535:	5f                   	pop    %edi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    
  801538:	39 d6                	cmp    %edx,%esi
  80153a:	75 d9                	jne    801515 <__umoddi3+0xf5>
  80153c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80153f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801542:	eb d1                	jmp    801515 <__umoddi3+0xf5>
  801544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801548:	39 f2                	cmp    %esi,%edx
  80154a:	0f 82 18 ff ff ff    	jb     801468 <__umoddi3+0x48>
  801550:	e9 1d ff ff ff       	jmp    801472 <__umoddi3+0x52>
