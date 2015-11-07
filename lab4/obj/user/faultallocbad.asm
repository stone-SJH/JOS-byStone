
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 5c 00 80 00 	movl   $0x80005c,(%esp)
  800041:	e8 5e 11 00 00       	call   8011a4 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800046:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004d:	00 
  80004e:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800055:	e8 d2 0c 00 00       	call   800d2c <sys_cputs>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	53                   	push   %ebx
  800060:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800063:	8b 45 08             	mov    0x8(%ebp),%eax
  800066:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800068:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006c:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  800073:	e8 a1 01 00 00       	call   800219 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 70 0f 00 00       	call   801007 <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 80 14 80 	movl   $0x801480,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 6a 14 80 00 	movl   $0x80146a,(%esp)
  8000ba:	e8 89 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 ac 14 80 	movl   $0x8014ac,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000d2:	00 
  8000d3:	89 1c 24             	mov    %ebx,(%esp)
  8000d6:	e8 7e 07 00 00       	call   800859 <snprintf>
}
  8000db:	83 c4 24             	add    $0x24,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  8000f6:	e8 fb 0f 00 00       	call   8010f6 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 10 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 f0 0f 00 00       	call   801136 <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800150:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800153:	a1 08 20 80 00       	mov    0x802008,%eax
  800158:	85 c0                	test   %eax,%eax
  80015a:	74 10                	je     80016c <_panic+0x24>
		cprintf("%s: ", argv0);
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	c7 04 24 d7 14 80 00 	movl   $0x8014d7,(%esp)
  800167:	e8 ad 00 00 00       	call   800219 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800172:	e8 7f 0f 00 00       	call   8010f6 <sys_getenvid>
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800185:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	c7 04 24 dc 14 80 00 	movl   $0x8014dc,(%esp)
  800194:	e8 80 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800199:	89 74 24 04          	mov    %esi,0x4(%esp)
  80019d:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 10 00 00 00       	call   8001b8 <vcprintf>
	cprintf("\n");
  8001a8:	c7 04 24 68 14 80 00 	movl   $0x801468,(%esp)
  8001af:	e8 65 00 00 00       	call   800219 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b4:	cc                   	int3   
  8001b5:	eb fd                	jmp    8001b4 <_panic+0x6c>
	...

008001b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c8:	00 00 00 
	b.cnt = 0;
  8001cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	c7 04 24 33 02 80 00 	movl   $0x800233,(%esp)
  8001f4:	e8 d4 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	e8 1b 0b 00 00       	call   800d2c <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80021f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800222:	89 44 24 04          	mov    %eax,0x4(%esp)
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 87 ff ff ff       	call   8001b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	53                   	push   %ebx
  800237:	83 ec 14             	sub    $0x14,%esp
  80023a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023d:	8b 03                	mov    (%ebx),%eax
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800246:	83 c0 01             	add    $0x1,%eax
  800249:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800250:	75 19                	jne    80026b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800252:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800259:	00 
  80025a:	8d 43 08             	lea    0x8(%ebx),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 c7 0a 00 00       	call   800d2c <sys_cputs>
		b->idx = 0;
  800265:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80026b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 15                	jb     8002c4 <printnum+0x44>
  8002af:	77 07                	ja     8002b8 <printnum+0x38>
  8002b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b4:	39 d0                	cmp    %edx,%eax
  8002b6:	76 0c                	jbe    8002c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	8d 76 00             	lea    0x0(%esi),%esi
  8002c0:	7f 61                	jg     800323 <printnum+0xa3>
  8002c2:	eb 70                	jmp    800334 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ef:	00 
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 de 0e 00 00       	call   8011e0 <__udivdi3>
  800302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800305:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	89 54 24 04          	mov    %edx,0x4(%esp)
  800317:	89 f2                	mov    %esi,%edx
  800319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031c:	e8 5f ff ff ff       	call   800280 <printnum>
  800321:	eb 11                	jmp    800334 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	89 74 24 04          	mov    %esi,0x4(%esp)
  800327:	89 3c 24             	mov    %edi,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f ef                	jg     800323 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800334:	89 74 24 04          	mov    %esi,0x4(%esp)
  800338:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034a:	00 
  80034b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80034e:	89 14 24             	mov    %edx,(%esp)
  800351:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800354:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800358:	e8 b3 0f 00 00       	call   801310 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 ff 14 80 00 	movsbl 0x8014ff(%eax),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036e:	83 c4 4c             	add    $0x4c,%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800379:	83 fa 01             	cmp    $0x1,%edx
  80037c:	7e 0e                	jle    80038c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 08             	lea    0x8(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	8b 52 04             	mov    0x4(%edx),%edx
  80038a:	eb 22                	jmp    8003ae <getuint+0x38>
	else if (lflag)
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 10                	je     8003a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 04             	lea    0x4(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	eb 0e                	jmp    8003ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c4:	88 0a                	mov    %cl,(%edx)
  8003c6:	83 c2 01             	add    $0x1,%edx
  8003c9:	89 10                	mov    %edx,(%eax)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 5c             	sub    $0x5c,%esp
  8003d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e6:	eb 11                	jmp    8003f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	0f 84 09 04 00 00    	je     8007f9 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  8003f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	0f b6 03             	movzbl (%ebx),%eax
  8003fc:	83 c3 01             	add    $0x1,%ebx
  8003ff:	83 f8 25             	cmp    $0x25,%eax
  800402:	75 e4                	jne    8003e8 <vprintfmt+0x1b>
  800404:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800408:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80040f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800416:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80041d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800422:	eb 06                	jmp    80042a <vprintfmt+0x5d>
  800424:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800428:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 13             	movzbl (%ebx),%edx
  80042d:	0f b6 c2             	movzbl %dl,%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	8d 43 01             	lea    0x1(%ebx),%eax
  800436:	83 ea 23             	sub    $0x23,%edx
  800439:	80 fa 55             	cmp    $0x55,%dl
  80043c:	0f 87 9a 03 00 00    	ja     8007dc <vprintfmt+0x40f>
  800442:	0f b6 d2             	movzbl %dl,%edx
  800445:	ff 24 95 c0 15 80 00 	jmp    *0x8015c0(,%edx,4)
  80044c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800450:	eb d6                	jmp    800428 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800452:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800455:	83 ea 30             	sub    $0x30,%edx
  800458:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80045b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80045e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800461:	83 fb 09             	cmp    $0x9,%ebx
  800464:	77 4c                	ja     8004b2 <vprintfmt+0xe5>
  800466:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800469:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80046f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800472:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800476:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800479:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80047c:	83 fb 09             	cmp    $0x9,%ebx
  80047f:	76 eb                	jbe    80046c <vprintfmt+0x9f>
  800481:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	eb 29                	jmp    8004b2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800489:	8b 55 14             	mov    0x14(%ebp),%edx
  80048c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80048f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800492:	8b 12                	mov    (%edx),%edx
  800494:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800497:	eb 19                	jmp    8004b2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800499:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049c:	c1 fa 1f             	sar    $0x1f,%edx
  80049f:	f7 d2                	not    %edx
  8004a1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8004a4:	eb 82                	jmp    800428 <vprintfmt+0x5b>
  8004a6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004ad:	e9 76 ff ff ff       	jmp    800428 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b6:	0f 89 6c ff ff ff    	jns    800428 <vprintfmt+0x5b>
  8004bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004c8:	e9 5b ff ff ff       	jmp    800428 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004cd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004d0:	e9 53 ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e5:	8b 00                	mov    (%eax),%eax
  8004e7:	89 04 24             	mov    %eax,(%esp)
  8004ea:	ff d7                	call   *%edi
  8004ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8004ef:	e9 05 ff ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8004f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 50 04             	lea    0x4(%eax),%edx
  8004fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 c2                	mov    %eax,%edx
  800504:	c1 fa 1f             	sar    $0x1f,%edx
  800507:	31 d0                	xor    %edx,%eax
  800509:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050b:	83 f8 08             	cmp    $0x8,%eax
  80050e:	7f 0b                	jg     80051b <vprintfmt+0x14e>
  800510:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	75 20                	jne    80053b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80051b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051f:	c7 44 24 08 10 15 80 	movl   $0x801510,0x8(%esp)
  800526:	00 
  800527:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052b:	89 3c 24             	mov    %edi,(%esp)
  80052e:	e8 4e 03 00 00       	call   800881 <printfmt>
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800536:	e9 be fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80053b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053f:	c7 44 24 08 19 15 80 	movl   $0x801519,0x8(%esp)
  800546:	00 
  800547:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054b:	89 3c 24             	mov    %edi,(%esp)
  80054e:	e8 2e 03 00 00       	call   800881 <printfmt>
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	e9 9e fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  80055b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055e:	89 c3                	mov    %eax,%ebx
  800560:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800566:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800577:	85 c0                	test   %eax,%eax
  800579:	75 07                	jne    800582 <vprintfmt+0x1b5>
  80057b:	c7 45 c4 1c 15 80 00 	movl   $0x80151c,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800582:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800586:	7e 06                	jle    80058e <vprintfmt+0x1c1>
  800588:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80058c:	75 13                	jne    8005a1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800591:	0f be 02             	movsbl (%edx),%eax
  800594:	85 c0                	test   %eax,%eax
  800596:	0f 85 99 00 00 00    	jne    800635 <vprintfmt+0x268>
  80059c:	e9 86 00 00 00       	jmp    800627 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8005a8:	89 0c 24             	mov    %ecx,(%esp)
  8005ab:	e8 1b 03 00 00       	call   8008cb <strnlen>
  8005b0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	7e d2                	jle    80058e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8005bc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005c6:	89 d3                	mov    %edx,%ebx
  8005c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	83 eb 01             	sub    $0x1,%ebx
  8005d7:	85 db                	test   %ebx,%ebx
  8005d9:	7f ed                	jg     8005c8 <vprintfmt+0x1fb>
  8005db:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005e5:	eb a7                	jmp    80058e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005eb:	74 18                	je     800605 <vprintfmt+0x238>
  8005ed:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005f0:	83 fa 5e             	cmp    $0x5e,%edx
  8005f3:	76 10                	jbe    800605 <vprintfmt+0x238>
					putch('?', putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800600:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800603:	eb 0a                	jmp    80060f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800613:	0f be 03             	movsbl (%ebx),%eax
  800616:	85 c0                	test   %eax,%eax
  800618:	74 05                	je     80061f <vprintfmt+0x252>
  80061a:	83 c3 01             	add    $0x1,%ebx
  80061d:	eb 29                	jmp    800648 <vprintfmt+0x27b>
  80061f:	89 fe                	mov    %edi,%esi
  800621:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800624:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800627:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062b:	7f 2e                	jg     80065b <vprintfmt+0x28e>
  80062d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800630:	e9 c4 fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800635:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800638:	83 c2 01             	add    $0x1,%edx
  80063b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80063e:	89 f7                	mov    %esi,%edi
  800640:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800643:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800646:	89 d3                	mov    %edx,%ebx
  800648:	85 f6                	test   %esi,%esi
  80064a:	78 9b                	js     8005e7 <vprintfmt+0x21a>
  80064c:	83 ee 01             	sub    $0x1,%esi
  80064f:	79 96                	jns    8005e7 <vprintfmt+0x21a>
  800651:	89 fe                	mov    %edi,%esi
  800653:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800656:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800659:	eb cc                	jmp    800627 <vprintfmt+0x25a>
  80065b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80065e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80066c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066e:	83 eb 01             	sub    $0x1,%ebx
  800671:	85 db                	test   %ebx,%ebx
  800673:	7f ec                	jg     800661 <vprintfmt+0x294>
  800675:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800678:	e9 7c fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  80067d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800680:	83 f9 01             	cmp    $0x1,%ecx
  800683:	7e 16                	jle    80069b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 08             	lea    0x8(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	8b 48 04             	mov    0x4(%eax),%ecx
  800693:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800696:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800699:	eb 32                	jmp    8006cd <vprintfmt+0x300>
	else if (lflag)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	74 18                	je     8006b7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ad:	89 c1                	mov    %eax,%ecx
  8006af:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006b5:	eb 16                	jmp    8006cd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c5:	89 c2                	mov    %eax,%edx
  8006c7:	c1 fa 1f             	sar    $0x1f,%edx
  8006ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006d8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006dc:	0f 89 b8 00 00 00    	jns    80079a <vprintfmt+0x3cd>
				putch('-', putdat);
  8006e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ed:	ff d7                	call   *%edi
				num = -(long long) num;
  8006ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006f5:	f7 d9                	neg    %ecx
  8006f7:	83 d3 00             	adc    $0x0,%ebx
  8006fa:	f7 db                	neg    %ebx
  8006fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800701:	e9 94 00 00 00       	jmp    80079a <vprintfmt+0x3cd>
  800706:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800709:	89 ca                	mov    %ecx,%edx
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 63 fc ff ff       	call   800376 <getuint>
  800713:	89 c1                	mov    %eax,%ecx
  800715:	89 d3                	mov    %edx,%ebx
  800717:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80071c:	eb 7c                	jmp    80079a <vprintfmt+0x3cd>
  80071e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800721:	89 74 24 04          	mov    %esi,0x4(%esp)
  800725:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80072c:	ff d7                	call   *%edi
			putch('X', putdat);
  80072e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800732:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800739:	ff d7                	call   *%edi
			putch('X', putdat);
  80073b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800746:	ff d7                	call   *%edi
  800748:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80074b:	e9 a9 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800750:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800753:	89 74 24 04          	mov    %esi,0x4(%esp)
  800757:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80075e:	ff d7                	call   *%edi
			putch('x', putdat);
  800760:	89 74 24 04          	mov    %esi,0x4(%esp)
  800764:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80076b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8d 50 04             	lea    0x4(%eax),%edx
  800773:	89 55 14             	mov    %edx,0x14(%ebp)
  800776:	8b 08                	mov    (%eax),%ecx
  800778:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800782:	eb 16                	jmp    80079a <vprintfmt+0x3cd>
  800784:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800787:	89 ca                	mov    %ecx,%edx
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
  80078c:	e8 e5 fb ff ff       	call   800376 <getuint>
  800791:	89 c1                	mov    %eax,%ecx
  800793:	89 d3                	mov    %edx,%ebx
  800795:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80079e:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	89 0c 24             	mov    %ecx,(%esp)
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	89 f8                	mov    %edi,%eax
  8007b8:	e8 c3 fa ff ff       	call   800280 <printnum>
  8007bd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007c0:	e9 34 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8007c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007c8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007cf:	89 14 24             	mov    %edx,(%esp)
  8007d2:	ff d7                	call   *%edi
  8007d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007d7:	e9 1d fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007ec:	80 38 25             	cmpb   $0x25,(%eax)
  8007ef:	0f 84 04 fc ff ff    	je     8003f9 <vprintfmt+0x2c>
  8007f5:	89 c3                	mov    %eax,%ebx
  8007f7:	eb f0                	jmp    8007e9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	83 c4 5c             	add    $0x5c,%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 28             	sub    $0x28,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 04                	je     800815 <vsnprintf+0x14>
  800811:	85 d2                	test   %edx,%edx
  800813:	7f 07                	jg     80081c <vsnprintf+0x1b>
  800815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081a:	eb 3b                	jmp    800857 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800823:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800826:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800834:	8b 45 10             	mov    0x10(%ebp),%eax
  800837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	c7 04 24 b0 03 80 00 	movl   $0x8003b0,(%esp)
  800849:	e8 7f fb ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800851:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800854:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800862:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800866:	8b 45 10             	mov    0x10(%ebp),%eax
  800869:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800870:	89 44 24 04          	mov    %eax,0x4(%esp)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	e8 82 ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800887:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80088a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088e:	8b 45 10             	mov    0x10(%ebp),%eax
  800891:	89 44 24 08          	mov    %eax,0x8(%esp)
  800895:	8b 45 0c             	mov    0xc(%ebp),%eax
  800898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	e8 26 fb ff ff       	call   8003cd <vprintfmt>
	va_end(ap);
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    
  8008a9:	00 00                	add    %al,(%eax)
  8008ab:	00 00                	add    %al,(%eax)
  8008ad:	00 00                	add    %al,(%eax)
	...

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008be:	74 09                	je     8008c9 <strlen+0x19>
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c7:	75 f7                	jne    8008c0 <strlen+0x10>
		n++;
	return n;
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	74 19                	je     8008f2 <strnlen+0x27>
  8008d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008dc:	74 14                	je     8008f2 <strnlen+0x27>
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e6:	39 c8                	cmp    %ecx,%eax
  8008e8:	74 0d                	je     8008f7 <strnlen+0x2c>
  8008ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008ee:	75 f3                	jne    8008e3 <strnlen+0x18>
  8008f0:	eb 05                	jmp    8008f7 <strnlen+0x2c>
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800904:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800909:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80090d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800910:	83 c2 01             	add    $0x1,%edx
  800913:	84 c9                	test   %cl,%cl
  800915:	75 f2                	jne    800909 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800924:	89 1c 24             	mov    %ebx,(%esp)
  800927:	e8 84 ff ff ff       	call   8008b0 <strlen>
	strcpy(dst + len, src);
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800933:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 bc ff ff ff       	call   8008fa <strcpy>
	return dst;
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	83 c4 08             	add    $0x8,%esp
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800954:	85 f6                	test   %esi,%esi
  800956:	74 18                	je     800970 <strncpy+0x2a>
  800958:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80095d:	0f b6 1a             	movzbl (%edx),%ebx
  800960:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800963:	80 3a 01             	cmpb   $0x1,(%edx)
  800966:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	39 ce                	cmp    %ecx,%esi
  80096e:	77 ed                	ja     80095d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 75 08             	mov    0x8(%ebp),%esi
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800982:	89 f0                	mov    %esi,%eax
  800984:	85 c9                	test   %ecx,%ecx
  800986:	74 27                	je     8009af <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800988:	83 e9 01             	sub    $0x1,%ecx
  80098b:	74 1d                	je     8009aa <strlcpy+0x36>
  80098d:	0f b6 1a             	movzbl (%edx),%ebx
  800990:	84 db                	test   %bl,%bl
  800992:	74 16                	je     8009aa <strlcpy+0x36>
			*dst++ = *src++;
  800994:	88 18                	mov    %bl,(%eax)
  800996:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800999:	83 e9 01             	sub    $0x1,%ecx
  80099c:	74 0e                	je     8009ac <strlcpy+0x38>
			*dst++ = *src++;
  80099e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a1:	0f b6 1a             	movzbl (%edx),%ebx
  8009a4:	84 db                	test   %bl,%bl
  8009a6:	75 ec                	jne    800994 <strlcpy+0x20>
  8009a8:	eb 02                	jmp    8009ac <strlcpy+0x38>
  8009aa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ac:	c6 00 00             	movb   $0x0,(%eax)
  8009af:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009be:	0f b6 01             	movzbl (%ecx),%eax
  8009c1:	84 c0                	test   %al,%al
  8009c3:	74 15                	je     8009da <strcmp+0x25>
  8009c5:	3a 02                	cmp    (%edx),%al
  8009c7:	75 11                	jne    8009da <strcmp+0x25>
		p++, q++;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 04                	je     8009da <strcmp+0x25>
  8009d6:	3a 02                	cmp    (%edx),%al
  8009d8:	74 ef                	je     8009c9 <strcmp+0x14>
  8009da:	0f b6 c0             	movzbl %al,%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	74 23                	je     800a18 <strncmp+0x34>
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	84 db                	test   %bl,%bl
  8009fa:	74 25                	je     800a21 <strncmp+0x3d>
  8009fc:	3a 19                	cmp    (%ecx),%bl
  8009fe:	75 21                	jne    800a21 <strncmp+0x3d>
  800a00:	83 e8 01             	sub    $0x1,%eax
  800a03:	74 13                	je     800a18 <strncmp+0x34>
		n--, p++, q++;
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a0b:	0f b6 1a             	movzbl (%edx),%ebx
  800a0e:	84 db                	test   %bl,%bl
  800a10:	74 0f                	je     800a21 <strncmp+0x3d>
  800a12:	3a 19                	cmp    (%ecx),%bl
  800a14:	74 ea                	je     800a00 <strncmp+0x1c>
  800a16:	eb 09                	jmp    800a21 <strncmp+0x3d>
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	90                   	nop
  800a20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a21:	0f b6 02             	movzbl (%edx),%eax
  800a24:	0f b6 11             	movzbl (%ecx),%edx
  800a27:	29 d0                	sub    %edx,%eax
  800a29:	eb f2                	jmp    800a1d <strncmp+0x39>

00800a2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 18                	je     800a54 <strchr+0x29>
		if (*s == c)
  800a3c:	38 ca                	cmp    %cl,%dl
  800a3e:	75 0a                	jne    800a4a <strchr+0x1f>
  800a40:	eb 17                	jmp    800a59 <strchr+0x2e>
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a48:	74 0f                	je     800a59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 ee                	jne    800a42 <strchr+0x17>
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a65:	0f b6 10             	movzbl (%eax),%edx
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	74 18                	je     800a84 <strfind+0x29>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	75 0a                	jne    800a7a <strfind+0x1f>
  800a70:	eb 12                	jmp    800a84 <strfind+0x29>
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a78:	74 0a                	je     800a84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	84 d2                	test   %dl,%dl
  800a82:	75 ee                	jne    800a72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	83 ec 0c             	sub    $0xc,%esp
  800a8c:	89 1c 24             	mov    %ebx,(%esp)
  800a8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa0:	85 c9                	test   %ecx,%ecx
  800aa2:	74 30                	je     800ad4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaa:	75 25                	jne    800ad1 <memset+0x4b>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 20                	jne    800ad1 <memset+0x4b>
		c &= 0xFF;
  800ab1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab4:	89 d3                	mov    %edx,%ebx
  800ab6:	c1 e3 08             	shl    $0x8,%ebx
  800ab9:	89 d6                	mov    %edx,%esi
  800abb:	c1 e6 18             	shl    $0x18,%esi
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	c1 e0 10             	shl    $0x10,%eax
  800ac3:	09 f0                	or     %esi,%eax
  800ac5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ac7:	09 d8                	or     %ebx,%eax
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
  800acc:	fc                   	cld    
  800acd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800acf:	eb 03                	jmp    800ad4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad1:	fc                   	cld    
  800ad2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	8b 1c 24             	mov    (%esp),%ebx
  800ad9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800add:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ae1:	89 ec                	mov    %ebp,%esp
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	89 34 24             	mov    %esi,(%esp)
  800aee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800af8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800afb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800afd:	39 c6                	cmp    %eax,%esi
  800aff:	73 35                	jae    800b36 <memmove+0x51>
  800b01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	73 2e                	jae    800b36 <memmove+0x51>
		s += n;
		d += n;
  800b08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0a:	f6 c2 03             	test   $0x3,%dl
  800b0d:	75 1b                	jne    800b2a <memmove+0x45>
  800b0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b15:	75 13                	jne    800b2a <memmove+0x45>
  800b17:	f6 c1 03             	test   $0x3,%cl
  800b1a:	75 0e                	jne    800b2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b1c:	83 ef 04             	sub    $0x4,%edi
  800b1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b22:	c1 e9 02             	shr    $0x2,%ecx
  800b25:	fd                   	std    
  800b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b28:	eb 09                	jmp    800b33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2a:	83 ef 01             	sub    $0x1,%edi
  800b2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b30:	fd                   	std    
  800b31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b34:	eb 20                	jmp    800b56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3c:	75 15                	jne    800b53 <memmove+0x6e>
  800b3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b44:	75 0d                	jne    800b53 <memmove+0x6e>
  800b46:	f6 c1 03             	test   $0x3,%cl
  800b49:	75 08                	jne    800b53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
  800b4e:	fc                   	cld    
  800b4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b51:	eb 03                	jmp    800b56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b53:	fc                   	cld    
  800b54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b56:	8b 34 24             	mov    (%esp),%esi
  800b59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b5d:	89 ec                	mov    %ebp,%esp
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b67:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	89 04 24             	mov    %eax,(%esp)
  800b7b:	e8 65 ff ff ff       	call   800ae5 <memmove>
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b91:	85 c9                	test   %ecx,%ecx
  800b93:	74 36                	je     800bcb <memcmp+0x49>
		if (*s1 != *s2)
  800b95:	0f b6 06             	movzbl (%esi),%eax
  800b98:	0f b6 1f             	movzbl (%edi),%ebx
  800b9b:	38 d8                	cmp    %bl,%al
  800b9d:	74 20                	je     800bbf <memcmp+0x3d>
  800b9f:	eb 14                	jmp    800bb5 <memcmp+0x33>
  800ba1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ba6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bab:	83 c2 01             	add    $0x1,%edx
  800bae:	83 e9 01             	sub    $0x1,%ecx
  800bb1:	38 d8                	cmp    %bl,%al
  800bb3:	74 12                	je     800bc7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800bb5:	0f b6 c0             	movzbl %al,%eax
  800bb8:	0f b6 db             	movzbl %bl,%ebx
  800bbb:	29 d8                	sub    %ebx,%eax
  800bbd:	eb 11                	jmp    800bd0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbf:	83 e9 01             	sub    $0x1,%ecx
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	85 c9                	test   %ecx,%ecx
  800bc9:	75 d6                	jne    800ba1 <memcmp+0x1f>
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be0:	39 d0                	cmp    %edx,%eax
  800be2:	73 15                	jae    800bf9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800be8:	38 08                	cmp    %cl,(%eax)
  800bea:	75 06                	jne    800bf2 <memfind+0x1d>
  800bec:	eb 0b                	jmp    800bf9 <memfind+0x24>
  800bee:	38 08                	cmp    %cl,(%eax)
  800bf0:	74 07                	je     800bf9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	83 c0 01             	add    $0x1,%eax
  800bf5:	39 c2                	cmp    %eax,%edx
  800bf7:	77 f5                	ja     800bee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 04             	sub    $0x4,%esp
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0a:	0f b6 02             	movzbl (%edx),%eax
  800c0d:	3c 20                	cmp    $0x20,%al
  800c0f:	74 04                	je     800c15 <strtol+0x1a>
  800c11:	3c 09                	cmp    $0x9,%al
  800c13:	75 0e                	jne    800c23 <strtol+0x28>
		s++;
  800c15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c18:	0f b6 02             	movzbl (%edx),%eax
  800c1b:	3c 20                	cmp    $0x20,%al
  800c1d:	74 f6                	je     800c15 <strtol+0x1a>
  800c1f:	3c 09                	cmp    $0x9,%al
  800c21:	74 f2                	je     800c15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c23:	3c 2b                	cmp    $0x2b,%al
  800c25:	75 0c                	jne    800c33 <strtol+0x38>
		s++;
  800c27:	83 c2 01             	add    $0x1,%edx
  800c2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c31:	eb 15                	jmp    800c48 <strtol+0x4d>
	else if (*s == '-')
  800c33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c3a:	3c 2d                	cmp    $0x2d,%al
  800c3c:	75 0a                	jne    800c48 <strtol+0x4d>
		s++, neg = 1;
  800c3e:	83 c2 01             	add    $0x1,%edx
  800c41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c48:	85 db                	test   %ebx,%ebx
  800c4a:	0f 94 c0             	sete   %al
  800c4d:	74 05                	je     800c54 <strtol+0x59>
  800c4f:	83 fb 10             	cmp    $0x10,%ebx
  800c52:	75 18                	jne    800c6c <strtol+0x71>
  800c54:	80 3a 30             	cmpb   $0x30,(%edx)
  800c57:	75 13                	jne    800c6c <strtol+0x71>
  800c59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c5d:	8d 76 00             	lea    0x0(%esi),%esi
  800c60:	75 0a                	jne    800c6c <strtol+0x71>
		s += 2, base = 16;
  800c62:	83 c2 02             	add    $0x2,%edx
  800c65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6a:	eb 15                	jmp    800c81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6c:	84 c0                	test   %al,%al
  800c6e:	66 90                	xchg   %ax,%ax
  800c70:	74 0f                	je     800c81 <strtol+0x86>
  800c72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c77:	80 3a 30             	cmpb   $0x30,(%edx)
  800c7a:	75 05                	jne    800c81 <strtol+0x86>
		s++, base = 8;
  800c7c:	83 c2 01             	add    $0x1,%edx
  800c7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c81:	b8 00 00 00 00       	mov    $0x0,%eax
  800c86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c88:	0f b6 0a             	movzbl (%edx),%ecx
  800c8b:	89 cf                	mov    %ecx,%edi
  800c8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c90:	80 fb 09             	cmp    $0x9,%bl
  800c93:	77 08                	ja     800c9d <strtol+0xa2>
			dig = *s - '0';
  800c95:	0f be c9             	movsbl %cl,%ecx
  800c98:	83 e9 30             	sub    $0x30,%ecx
  800c9b:	eb 1e                	jmp    800cbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ca0:	80 fb 19             	cmp    $0x19,%bl
  800ca3:	77 08                	ja     800cad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ca5:	0f be c9             	movsbl %cl,%ecx
  800ca8:	83 e9 57             	sub    $0x57,%ecx
  800cab:	eb 0e                	jmp    800cbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800cb0:	80 fb 19             	cmp    $0x19,%bl
  800cb3:	77 15                	ja     800cca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800cb5:	0f be c9             	movsbl %cl,%ecx
  800cb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cbb:	39 f1                	cmp    %esi,%ecx
  800cbd:	7d 0b                	jge    800cca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cbf:	83 c2 01             	add    $0x1,%edx
  800cc2:	0f af c6             	imul   %esi,%eax
  800cc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cc8:	eb be                	jmp    800c88 <strtol+0x8d>
  800cca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ccc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd0:	74 05                	je     800cd7 <strtol+0xdc>
		*endptr = (char *) s;
  800cd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cdb:	74 04                	je     800ce1 <strtol+0xe6>
  800cdd:	89 c8                	mov    %ecx,%eax
  800cdf:	f7 d8                	neg    %eax
}
  800ce1:	83 c4 04             	add    $0x4,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	00 00                	add    %al,(%eax)
	...

00800cec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
  800cf2:	89 1c 24             	mov    %ebx,(%esp)
  800cf5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	89 d3                	mov    %edx,%ebx
  800d07:	89 d7                	mov    %edx,%edi
  800d09:	51                   	push   %ecx
  800d0a:	52                   	push   %edx
  800d0b:	53                   	push   %ebx
  800d0c:	54                   	push   %esp
  800d0d:	55                   	push   %ebp
  800d0e:	56                   	push   %esi
  800d0f:	57                   	push   %edi
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8d 35 1a 0d 80 00    	lea    0x800d1a,%esi
  800d18:	0f 34                	sysenter 
  800d1a:	5f                   	pop    %edi
  800d1b:	5e                   	pop    %esi
  800d1c:	5d                   	pop    %ebp
  800d1d:	5c                   	pop    %esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5a                   	pop    %edx
  800d20:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d21:	8b 1c 24             	mov    (%esp),%ebx
  800d24:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d28:	89 ec                	mov    %ebp,%esp
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
  800d32:	89 1c 24             	mov    %ebx,(%esp)
  800d35:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	89 c7                	mov    %eax,%edi
  800d48:	51                   	push   %ecx
  800d49:	52                   	push   %edx
  800d4a:	53                   	push   %ebx
  800d4b:	54                   	push   %esp
  800d4c:	55                   	push   %ebp
  800d4d:	56                   	push   %esi
  800d4e:	57                   	push   %edi
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	8d 35 59 0d 80 00    	lea    0x800d59,%esi
  800d57:	0f 34                	sysenter 
  800d59:	5f                   	pop    %edi
  800d5a:	5e                   	pop    %esi
  800d5b:	5d                   	pop    %ebp
  800d5c:	5c                   	pop    %esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5a                   	pop    %edx
  800d5f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d60:	8b 1c 24             	mov    (%esp),%ebx
  800d63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d67:	89 ec                	mov    %ebp,%esp
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	89 1c 24             	mov    %ebx,(%esp)
  800d74:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 cb                	mov    %ecx,%ebx
  800d87:	89 cf                	mov    %ecx,%edi
  800d89:	51                   	push   %ecx
  800d8a:	52                   	push   %edx
  800d8b:	53                   	push   %ebx
  800d8c:	54                   	push   %esp
  800d8d:	55                   	push   %ebp
  800d8e:	56                   	push   %esi
  800d8f:	57                   	push   %edi
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	8d 35 9a 0d 80 00    	lea    0x800d9a,%esi
  800d98:	0f 34                	sysenter 
  800d9a:	5f                   	pop    %edi
  800d9b:	5e                   	pop    %esi
  800d9c:	5d                   	pop    %ebp
  800d9d:	5c                   	pop    %esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5a                   	pop    %edx
  800da0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800da1:	8b 1c 24             	mov    (%esp),%ebx
  800da4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 28             	sub    $0x28,%esp
  800db2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800db5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800db8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 cb                	mov    %ecx,%ebx
  800dc7:	89 cf                	mov    %ecx,%edi
  800dc9:	51                   	push   %ecx
  800dca:	52                   	push   %edx
  800dcb:	53                   	push   %ebx
  800dcc:	54                   	push   %esp
  800dcd:	55                   	push   %ebp
  800dce:	56                   	push   %esi
  800dcf:	57                   	push   %edi
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	8d 35 da 0d 80 00    	lea    0x800dda,%esi
  800dd8:	0f 34                	sysenter 
  800dda:	5f                   	pop    %edi
  800ddb:	5e                   	pop    %esi
  800ddc:	5d                   	pop    %ebp
  800ddd:	5c                   	pop    %esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5a                   	pop    %edx
  800de0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800de1:	85 c0                	test   %eax,%eax
  800de3:	7e 28                	jle    800e0d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800df0:	00 
  800df1:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800df8:	00 
  800df9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e00:	00 
  800e01:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800e08:	e8 3b f3 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e13:	89 ec                	mov    %ebp,%esp
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	89 1c 24             	mov    %ebx,(%esp)
  800e20:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	51                   	push   %ecx
  800e36:	52                   	push   %edx
  800e37:	53                   	push   %ebx
  800e38:	54                   	push   %esp
  800e39:	55                   	push   %ebp
  800e3a:	56                   	push   %esi
  800e3b:	57                   	push   %edi
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	8d 35 46 0e 80 00    	lea    0x800e46,%esi
  800e44:	0f 34                	sysenter 
  800e46:	5f                   	pop    %edi
  800e47:	5e                   	pop    %esi
  800e48:	5d                   	pop    %ebp
  800e49:	5c                   	pop    %esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5a                   	pop    %edx
  800e4c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4d:	8b 1c 24             	mov    (%esp),%ebx
  800e50:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e54:	89 ec                	mov    %ebp,%esp
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 28             	sub    $0x28,%esp
  800e5e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e61:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	89 df                	mov    %ebx,%edi
  800e76:	51                   	push   %ecx
  800e77:	52                   	push   %edx
  800e78:	53                   	push   %ebx
  800e79:	54                   	push   %esp
  800e7a:	55                   	push   %ebp
  800e7b:	56                   	push   %esi
  800e7c:	57                   	push   %edi
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	8d 35 87 0e 80 00    	lea    0x800e87,%esi
  800e85:	0f 34                	sysenter 
  800e87:	5f                   	pop    %edi
  800e88:	5e                   	pop    %esi
  800e89:	5d                   	pop    %ebp
  800e8a:	5c                   	pop    %esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5a                   	pop    %edx
  800e8d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 28                	jle    800eba <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e96:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800eb5:	e8 8e f2 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ebd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec0:	89 ec                	mov    %ebp,%esp
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 28             	sub    $0x28,%esp
  800eca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ecd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 df                	mov    %ebx,%edi
  800ee2:	51                   	push   %ecx
  800ee3:	52                   	push   %edx
  800ee4:	53                   	push   %ebx
  800ee5:	54                   	push   %esp
  800ee6:	55                   	push   %ebp
  800ee7:	56                   	push   %esi
  800ee8:	57                   	push   %edi
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	8d 35 f3 0e 80 00    	lea    0x800ef3,%esi
  800ef1:	0f 34                	sysenter 
  800ef3:	5f                   	pop    %edi
  800ef4:	5e                   	pop    %esi
  800ef5:	5d                   	pop    %ebp
  800ef6:	5c                   	pop    %esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5a                   	pop    %edx
  800ef9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800efa:	85 c0                	test   %eax,%eax
  800efc:	7e 28                	jle    800f26 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f02:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f09:	00 
  800f0a:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f19:	00 
  800f1a:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800f21:	e8 22 f2 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f26:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f2c:	89 ec                	mov    %ebp,%esp
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 28             	sub    $0x28,%esp
  800f36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f39:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f41:	b8 07 00 00 00       	mov    $0x7,%eax
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	89 df                	mov    %ebx,%edi
  800f4e:	51                   	push   %ecx
  800f4f:	52                   	push   %edx
  800f50:	53                   	push   %ebx
  800f51:	54                   	push   %esp
  800f52:	55                   	push   %ebp
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	8d 35 5f 0f 80 00    	lea    0x800f5f,%esi
  800f5d:	0f 34                	sysenter 
  800f5f:	5f                   	pop    %edi
  800f60:	5e                   	pop    %esi
  800f61:	5d                   	pop    %ebp
  800f62:	5c                   	pop    %esp
  800f63:	5b                   	pop    %ebx
  800f64:	5a                   	pop    %edx
  800f65:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 28                	jle    800f92 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f75:	00 
  800f76:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f85:	00 
  800f86:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800f8d:	e8 b6 f1 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f92:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f98:	89 ec                	mov    %ebp,%esp
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 28             	sub    $0x28,%esp
  800fa2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fa5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb9:	51                   	push   %ecx
  800fba:	52                   	push   %edx
  800fbb:	53                   	push   %ebx
  800fbc:	54                   	push   %esp
  800fbd:	55                   	push   %ebp
  800fbe:	56                   	push   %esi
  800fbf:	57                   	push   %edi
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	8d 35 ca 0f 80 00    	lea    0x800fca,%esi
  800fc8:	0f 34                	sysenter 
  800fca:	5f                   	pop    %edi
  800fcb:	5e                   	pop    %esi
  800fcc:	5d                   	pop    %ebp
  800fcd:	5c                   	pop    %esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5a                   	pop    %edx
  800fd0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 28                	jle    800ffd <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800ff8:	e8 4b f1 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ffd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801000:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801003:	89 ec                	mov    %ebp,%esp
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 28             	sub    $0x28,%esp
  80100d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801010:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801013:	bf 00 00 00 00       	mov    $0x0,%edi
  801018:	b8 05 00 00 00       	mov    $0x5,%eax
  80101d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	51                   	push   %ecx
  801027:	52                   	push   %edx
  801028:	53                   	push   %ebx
  801029:	54                   	push   %esp
  80102a:	55                   	push   %ebp
  80102b:	56                   	push   %esi
  80102c:	57                   	push   %edi
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	8d 35 37 10 80 00    	lea    0x801037,%esi
  801035:	0f 34                	sysenter 
  801037:	5f                   	pop    %edi
  801038:	5e                   	pop    %esi
  801039:	5d                   	pop    %ebp
  80103a:	5c                   	pop    %esp
  80103b:	5b                   	pop    %ebx
  80103c:	5a                   	pop    %edx
  80103d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80103e:	85 c0                	test   %eax,%eax
  801040:	7e 28                	jle    80106a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801042:	89 44 24 10          	mov    %eax,0x10(%esp)
  801046:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80104d:	00 
  80104e:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  801055:	00 
  801056:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80105d:	00 
  80105e:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  801065:	e8 de f0 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80106a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80106d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801070:	89 ec                	mov    %ebp,%esp
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	89 1c 24             	mov    %ebx,(%esp)
  80107d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801081:	ba 00 00 00 00       	mov    $0x0,%edx
  801086:	b8 0b 00 00 00       	mov    $0xb,%eax
  80108b:	89 d1                	mov    %edx,%ecx
  80108d:	89 d3                	mov    %edx,%ebx
  80108f:	89 d7                	mov    %edx,%edi
  801091:	51                   	push   %ecx
  801092:	52                   	push   %edx
  801093:	53                   	push   %ebx
  801094:	54                   	push   %esp
  801095:	55                   	push   %ebp
  801096:	56                   	push   %esi
  801097:	57                   	push   %edi
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	8d 35 a2 10 80 00    	lea    0x8010a2,%esi
  8010a0:	0f 34                	sysenter 
  8010a2:	5f                   	pop    %edi
  8010a3:	5e                   	pop    %esi
  8010a4:	5d                   	pop    %ebp
  8010a5:	5c                   	pop    %esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5a                   	pop    %edx
  8010a8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010a9:	8b 1c 24             	mov    (%esp),%ebx
  8010ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b0:	89 ec                	mov    %ebp,%esp
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 08             	sub    $0x8,%esp
  8010ba:	89 1c 24             	mov    %ebx,(%esp)
  8010bd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8010cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d1:	89 df                	mov    %ebx,%edi
  8010d3:	51                   	push   %ecx
  8010d4:	52                   	push   %edx
  8010d5:	53                   	push   %ebx
  8010d6:	54                   	push   %esp
  8010d7:	55                   	push   %ebp
  8010d8:	56                   	push   %esi
  8010d9:	57                   	push   %edi
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	8d 35 e4 10 80 00    	lea    0x8010e4,%esi
  8010e2:	0f 34                	sysenter 
  8010e4:	5f                   	pop    %edi
  8010e5:	5e                   	pop    %esi
  8010e6:	5d                   	pop    %ebp
  8010e7:	5c                   	pop    %esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5a                   	pop    %edx
  8010ea:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8010eb:	8b 1c 24             	mov    (%esp),%ebx
  8010ee:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010f2:	89 ec                	mov    %ebp,%esp
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	83 ec 08             	sub    $0x8,%esp
  8010fc:	89 1c 24             	mov    %ebx,(%esp)
  8010ff:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801103:	ba 00 00 00 00       	mov    $0x0,%edx
  801108:	b8 02 00 00 00       	mov    $0x2,%eax
  80110d:	89 d1                	mov    %edx,%ecx
  80110f:	89 d3                	mov    %edx,%ebx
  801111:	89 d7                	mov    %edx,%edi
  801113:	51                   	push   %ecx
  801114:	52                   	push   %edx
  801115:	53                   	push   %ebx
  801116:	54                   	push   %esp
  801117:	55                   	push   %ebp
  801118:	56                   	push   %esi
  801119:	57                   	push   %edi
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	8d 35 24 11 80 00    	lea    0x801124,%esi
  801122:	0f 34                	sysenter 
  801124:	5f                   	pop    %edi
  801125:	5e                   	pop    %esi
  801126:	5d                   	pop    %ebp
  801127:	5c                   	pop    %esp
  801128:	5b                   	pop    %ebx
  801129:	5a                   	pop    %edx
  80112a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80112b:	8b 1c 24             	mov    (%esp),%ebx
  80112e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801132:	89 ec                	mov    %ebp,%esp
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 28             	sub    $0x28,%esp
  80113c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80113f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801142:	b9 00 00 00 00       	mov    $0x0,%ecx
  801147:	b8 03 00 00 00       	mov    $0x3,%eax
  80114c:	8b 55 08             	mov    0x8(%ebp),%edx
  80114f:	89 cb                	mov    %ecx,%ebx
  801151:	89 cf                	mov    %ecx,%edi
  801153:	51                   	push   %ecx
  801154:	52                   	push   %edx
  801155:	53                   	push   %ebx
  801156:	54                   	push   %esp
  801157:	55                   	push   %ebp
  801158:	56                   	push   %esi
  801159:	57                   	push   %edi
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	8d 35 64 11 80 00    	lea    0x801164,%esi
  801162:	0f 34                	sysenter 
  801164:	5f                   	pop    %edi
  801165:	5e                   	pop    %esi
  801166:	5d                   	pop    %ebp
  801167:	5c                   	pop    %esp
  801168:	5b                   	pop    %ebx
  801169:	5a                   	pop    %edx
  80116a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80116b:	85 c0                	test   %eax,%eax
  80116d:	7e 28                	jle    801197 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801173:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80117a:	00 
  80117b:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  801182:	00 
  801183:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80118a:	00 
  80118b:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  801192:	e8 b1 ef ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801197:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80119a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80119d:	89 ec                	mov    %ebp,%esp
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    
  8011a1:	00 00                	add    %al,(%eax)
	...

008011a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011aa:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8011b1:	75 1c                	jne    8011cf <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8011b3:	c7 44 24 08 70 17 80 	movl   $0x801770,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8011ca:	e8 79 ef ff ff       	call   800148 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    
  8011d9:	00 00                	add    %al,(%eax)
  8011db:	00 00                	add    %al,(%eax)
  8011dd:	00 00                	add    %al,(%eax)
	...

008011e0 <__udivdi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	83 ec 10             	sub    $0x10,%esp
  8011e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8011f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011f9:	75 35                	jne    801230 <__udivdi3+0x50>
  8011fb:	39 fe                	cmp    %edi,%esi
  8011fd:	77 61                	ja     801260 <__udivdi3+0x80>
  8011ff:	85 f6                	test   %esi,%esi
  801201:	75 0b                	jne    80120e <__udivdi3+0x2e>
  801203:	b8 01 00 00 00       	mov    $0x1,%eax
  801208:	31 d2                	xor    %edx,%edx
  80120a:	f7 f6                	div    %esi
  80120c:	89 c6                	mov    %eax,%esi
  80120e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801211:	31 d2                	xor    %edx,%edx
  801213:	89 f8                	mov    %edi,%eax
  801215:	f7 f6                	div    %esi
  801217:	89 c7                	mov    %eax,%edi
  801219:	89 c8                	mov    %ecx,%eax
  80121b:	f7 f6                	div    %esi
  80121d:	89 c1                	mov    %eax,%ecx
  80121f:	89 fa                	mov    %edi,%edx
  801221:	89 c8                	mov    %ecx,%eax
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    
  80122a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801230:	39 f8                	cmp    %edi,%eax
  801232:	77 1c                	ja     801250 <__udivdi3+0x70>
  801234:	0f bd d0             	bsr    %eax,%edx
  801237:	83 f2 1f             	xor    $0x1f,%edx
  80123a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80123d:	75 39                	jne    801278 <__udivdi3+0x98>
  80123f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801242:	0f 86 a0 00 00 00    	jbe    8012e8 <__udivdi3+0x108>
  801248:	39 f8                	cmp    %edi,%eax
  80124a:	0f 82 98 00 00 00    	jb     8012e8 <__udivdi3+0x108>
  801250:	31 ff                	xor    %edi,%edi
  801252:	31 c9                	xor    %ecx,%ecx
  801254:	89 c8                	mov    %ecx,%eax
  801256:	89 fa                	mov    %edi,%edx
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    
  80125f:	90                   	nop
  801260:	89 d1                	mov    %edx,%ecx
  801262:	89 fa                	mov    %edi,%edx
  801264:	89 c8                	mov    %ecx,%eax
  801266:	31 ff                	xor    %edi,%edi
  801268:	f7 f6                	div    %esi
  80126a:	89 c1                	mov    %eax,%ecx
  80126c:	89 fa                	mov    %edi,%edx
  80126e:	89 c8                	mov    %ecx,%eax
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    
  801277:	90                   	nop
  801278:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80127c:	89 f2                	mov    %esi,%edx
  80127e:	d3 e0                	shl    %cl,%eax
  801280:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801283:	b8 20 00 00 00       	mov    $0x20,%eax
  801288:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80128b:	89 c1                	mov    %eax,%ecx
  80128d:	d3 ea                	shr    %cl,%edx
  80128f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801293:	0b 55 ec             	or     -0x14(%ebp),%edx
  801296:	d3 e6                	shl    %cl,%esi
  801298:	89 c1                	mov    %eax,%ecx
  80129a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80129d:	89 fe                	mov    %edi,%esi
  80129f:	d3 ee                	shr    %cl,%esi
  8012a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ab:	d3 e7                	shl    %cl,%edi
  8012ad:	89 c1                	mov    %eax,%ecx
  8012af:	d3 ea                	shr    %cl,%edx
  8012b1:	09 d7                	or     %edx,%edi
  8012b3:	89 f2                	mov    %esi,%edx
  8012b5:	89 f8                	mov    %edi,%eax
  8012b7:	f7 75 ec             	divl   -0x14(%ebp)
  8012ba:	89 d6                	mov    %edx,%esi
  8012bc:	89 c7                	mov    %eax,%edi
  8012be:	f7 65 e8             	mull   -0x18(%ebp)
  8012c1:	39 d6                	cmp    %edx,%esi
  8012c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012c6:	72 30                	jb     8012f8 <__udivdi3+0x118>
  8012c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012cf:	d3 e2                	shl    %cl,%edx
  8012d1:	39 c2                	cmp    %eax,%edx
  8012d3:	73 05                	jae    8012da <__udivdi3+0xfa>
  8012d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8012d8:	74 1e                	je     8012f8 <__udivdi3+0x118>
  8012da:	89 f9                	mov    %edi,%ecx
  8012dc:	31 ff                	xor    %edi,%edi
  8012de:	e9 71 ff ff ff       	jmp    801254 <__udivdi3+0x74>
  8012e3:	90                   	nop
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	31 ff                	xor    %edi,%edi
  8012ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8012ef:	e9 60 ff ff ff       	jmp    801254 <__udivdi3+0x74>
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8012fb:	31 ff                	xor    %edi,%edi
  8012fd:	89 c8                	mov    %ecx,%eax
  8012ff:	89 fa                	mov    %edi,%edx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    
	...

00801310 <__umoddi3>:
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	57                   	push   %edi
  801314:	56                   	push   %esi
  801315:	83 ec 20             	sub    $0x20,%esp
  801318:	8b 55 14             	mov    0x14(%ebp),%edx
  80131b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801321:	8b 75 0c             	mov    0xc(%ebp),%esi
  801324:	85 d2                	test   %edx,%edx
  801326:	89 c8                	mov    %ecx,%eax
  801328:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80132b:	75 13                	jne    801340 <__umoddi3+0x30>
  80132d:	39 f7                	cmp    %esi,%edi
  80132f:	76 3f                	jbe    801370 <__umoddi3+0x60>
  801331:	89 f2                	mov    %esi,%edx
  801333:	f7 f7                	div    %edi
  801335:	89 d0                	mov    %edx,%eax
  801337:	31 d2                	xor    %edx,%edx
  801339:	83 c4 20             	add    $0x20,%esp
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
  801340:	39 f2                	cmp    %esi,%edx
  801342:	77 4c                	ja     801390 <__umoddi3+0x80>
  801344:	0f bd ca             	bsr    %edx,%ecx
  801347:	83 f1 1f             	xor    $0x1f,%ecx
  80134a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80134d:	75 51                	jne    8013a0 <__umoddi3+0x90>
  80134f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801352:	0f 87 e0 00 00 00    	ja     801438 <__umoddi3+0x128>
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	29 f8                	sub    %edi,%eax
  80135d:	19 d6                	sbb    %edx,%esi
  80135f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	89 f2                	mov    %esi,%edx
  801367:	83 c4 20             	add    $0x20,%esp
  80136a:	5e                   	pop    %esi
  80136b:	5f                   	pop    %edi
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    
  80136e:	66 90                	xchg   %ax,%ax
  801370:	85 ff                	test   %edi,%edi
  801372:	75 0b                	jne    80137f <__umoddi3+0x6f>
  801374:	b8 01 00 00 00       	mov    $0x1,%eax
  801379:	31 d2                	xor    %edx,%edx
  80137b:	f7 f7                	div    %edi
  80137d:	89 c7                	mov    %eax,%edi
  80137f:	89 f0                	mov    %esi,%eax
  801381:	31 d2                	xor    %edx,%edx
  801383:	f7 f7                	div    %edi
  801385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801388:	f7 f7                	div    %edi
  80138a:	eb a9                	jmp    801335 <__umoddi3+0x25>
  80138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 f2                	mov    %esi,%edx
  801394:	83 c4 20             	add    $0x20,%esp
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
  80139b:	90                   	nop
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013a4:	d3 e2                	shl    %cl,%edx
  8013a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8013ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8013b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013b8:	89 fa                	mov    %edi,%edx
  8013ba:	d3 ea                	shr    %cl,%edx
  8013bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013cc:	89 f2                	mov    %esi,%edx
  8013ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8013d1:	89 c7                	mov    %eax,%edi
  8013d3:	d3 ea                	shr    %cl,%edx
  8013d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	d3 e6                	shl    %cl,%esi
  8013e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013e4:	d3 ea                	shr    %cl,%edx
  8013e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013ea:	09 d6                	or     %edx,%esi
  8013ec:	89 f0                	mov    %esi,%eax
  8013ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013f1:	d3 e7                	shl    %cl,%edi
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	f7 75 f4             	divl   -0xc(%ebp)
  8013f8:	89 d6                	mov    %edx,%esi
  8013fa:	f7 65 e8             	mull   -0x18(%ebp)
  8013fd:	39 d6                	cmp    %edx,%esi
  8013ff:	72 2b                	jb     80142c <__umoddi3+0x11c>
  801401:	39 c7                	cmp    %eax,%edi
  801403:	72 23                	jb     801428 <__umoddi3+0x118>
  801405:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801409:	29 c7                	sub    %eax,%edi
  80140b:	19 d6                	sbb    %edx,%esi
  80140d:	89 f0                	mov    %esi,%eax
  80140f:	89 f2                	mov    %esi,%edx
  801411:	d3 ef                	shr    %cl,%edi
  801413:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801417:	d3 e0                	shl    %cl,%eax
  801419:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80141d:	09 f8                	or     %edi,%eax
  80141f:	d3 ea                	shr    %cl,%edx
  801421:	83 c4 20             	add    $0x20,%esp
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
  801428:	39 d6                	cmp    %edx,%esi
  80142a:	75 d9                	jne    801405 <__umoddi3+0xf5>
  80142c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80142f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801432:	eb d1                	jmp    801405 <__umoddi3+0xf5>
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	39 f2                	cmp    %esi,%edx
  80143a:	0f 82 18 ff ff ff    	jb     801358 <__umoddi3+0x48>
  801440:	e9 1d ff ff ff       	jmp    801362 <__umoddi3+0x52>
