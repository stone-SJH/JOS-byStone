
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 a0 13 80 00 	movl   $0x8013a0,(%esp)
  800041:	e8 df 00 00 00       	call   800125 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ae 13 80 00 	movl   $0x8013ae,(%esp)
  800059:	e8 c7 00 00 00       	call   800125 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800072:	e8 8f 0f 00 00       	call   801006 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	c1 e0 07             	shl    $0x7,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 84 0f 00 00       	call   801046 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000d4:	00 00 00 
	b.cnt = 0;
  8000d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f9:	c7 04 24 3f 01 80 00 	movl   $0x80013f,(%esp)
  800100:	e8 d8 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800105:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800115:	89 04 24             	mov    %eax,(%esp)
  800118:	e8 1f 0b 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  80011d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80012b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 04 24             	mov    %eax,(%esp)
  800138:	e8 87 ff ff ff       	call   8000c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	53                   	push   %ebx
  800143:	83 ec 14             	sub    $0x14,%esp
  800146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	8b 55 08             	mov    0x8(%ebp),%edx
  80014e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800152:	83 c0 01             	add    $0x1,%eax
  800155:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800157:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015c:	75 19                	jne    800177 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80015e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800165:	00 
  800166:	8d 43 08             	lea    0x8(%ebx),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 cb 0a 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800177:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017b:	83 c4 14             	add    $0x14,%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 1e 0f 00 00       	call   801130 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 f3 0f 00 00       	call   801260 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 cf 13 80 00 	movsbl 0x8013cf(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0e                	jle    80029c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 08             	lea    0x8(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x38>
	else if (lflag)
  80029c:	85 d2                	test   %edx,%edx
  80029e:	74 10                	je     8002b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	88 0a                	mov    %cl,(%edx)
  8002d6:	83 c2 01             	add    $0x1,%edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 5c             	sub    $0x5c,%esp
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f6:	eb 11                	jmp    800309 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 09 04 00 00    	je     800709 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800300:	89 74 24 04          	mov    %esi,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 03             	movzbl (%ebx),%eax
  80030c:	83 c3 01             	add    $0x1,%ebx
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 e4                	jne    8002f8 <vprintfmt+0x1b>
  800314:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800318:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80031f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800326:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	eb 06                	jmp    80033a <vprintfmt+0x5d>
  800334:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800338:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 13             	movzbl (%ebx),%edx
  80033d:	0f b6 c2             	movzbl %dl,%eax
  800340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800343:	8d 43 01             	lea    0x1(%ebx),%eax
  800346:	83 ea 23             	sub    $0x23,%edx
  800349:	80 fa 55             	cmp    $0x55,%dl
  80034c:	0f 87 9a 03 00 00    	ja     8006ec <vprintfmt+0x40f>
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	ff 24 95 a0 14 80 00 	jmp    *0x8014a0(,%edx,4)
  80035c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800365:	83 ea 30             	sub    $0x30,%edx
  800368:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80036b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800371:	83 fb 09             	cmp    $0x9,%ebx
  800374:	77 4c                	ja     8003c2 <vprintfmt+0xe5>
  800376:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800379:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80037f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800382:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800386:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80038c:	83 fb 09             	cmp    $0x9,%ebx
  80038f:	76 eb                	jbe    80037c <vprintfmt+0x9f>
  800391:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800394:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800397:	eb 29                	jmp    8003c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800399:	8b 55 14             	mov    0x14(%ebp),%edx
  80039c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a2:	8b 12                	mov    (%edx),%edx
  8003a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003a7:	eb 19                	jmp    8003c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ac:	c1 fa 1f             	sar    $0x1f,%edx
  8003af:	f7 d2                	not    %edx
  8003b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003b4:	eb 82                	jmp    800338 <vprintfmt+0x5b>
  8003b6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003bd:	e9 76 ff ff ff       	jmp    800338 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c6:	0f 89 6c ff ff ff    	jns    800338 <vprintfmt+0x5b>
  8003cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003d8:	e9 5b ff ff ff       	jmp    800338 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	89 04 24             	mov    %eax,(%esp)
  8003fa:	ff d7                	call   *%edi
  8003fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8003ff:	e9 05 ff ff ff       	jmp    800309 <vprintfmt+0x2c>
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 50 04             	lea    0x4(%eax),%edx
  80040d:	89 55 14             	mov    %edx,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 c2                	mov    %eax,%edx
  800414:	c1 fa 1f             	sar    $0x1f,%edx
  800417:	31 d0                	xor    %edx,%eax
  800419:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 08             	cmp    $0x8,%eax
  80041e:	7f 0b                	jg     80042b <vprintfmt+0x14e>
  800420:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	75 20                	jne    80044b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	c7 44 24 08 e0 13 80 	movl   $0x8013e0,0x8(%esp)
  800436:	00 
  800437:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043b:	89 3c 24             	mov    %edi,(%esp)
  80043e:	e8 4e 03 00 00       	call   800791 <printfmt>
  800443:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800446:	e9 be fe ff ff       	jmp    800309 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044f:	c7 44 24 08 e9 13 80 	movl   $0x8013e9,0x8(%esp)
  800456:	00 
  800457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045b:	89 3c 24             	mov    %edi,(%esp)
  80045e:	e8 2e 03 00 00       	call   800791 <printfmt>
  800463:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800466:	e9 9e fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046e:	89 c3                	mov    %eax,%ebx
  800470:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800476:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800487:	85 c0                	test   %eax,%eax
  800489:	75 07                	jne    800492 <vprintfmt+0x1b5>
  80048b:	c7 45 c4 ec 13 80 00 	movl   $0x8013ec,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800492:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800496:	7e 06                	jle    80049e <vprintfmt+0x1c1>
  800498:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80049c:	75 13                	jne    8004b1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004a1:	0f be 02             	movsbl (%edx),%eax
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	0f 85 99 00 00 00    	jne    800545 <vprintfmt+0x268>
  8004ac:	e9 86 00 00 00       	jmp    800537 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004b8:	89 0c 24             	mov    %ecx,(%esp)
  8004bb:	e8 1b 03 00 00       	call   8007db <strnlen>
  8004c0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004c3:	29 c2                	sub    %eax,%edx
  8004c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	7e d2                	jle    80049e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004cc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8004d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004d3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004d6:	89 d3                	mov    %edx,%ebx
  8004d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	85 db                	test   %ebx,%ebx
  8004e9:	7f ed                	jg     8004d8 <vprintfmt+0x1fb>
  8004eb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f5:	eb a7                	jmp    80049e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004fb:	74 18                	je     800515 <vprintfmt+0x238>
  8004fd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800500:	83 fa 5e             	cmp    $0x5e,%edx
  800503:	76 10                	jbe    800515 <vprintfmt+0x238>
					putch('?', putdat);
  800505:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800509:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800510:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800513:	eb 0a                	jmp    80051f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800523:	0f be 03             	movsbl (%ebx),%eax
  800526:	85 c0                	test   %eax,%eax
  800528:	74 05                	je     80052f <vprintfmt+0x252>
  80052a:	83 c3 01             	add    $0x1,%ebx
  80052d:	eb 29                	jmp    800558 <vprintfmt+0x27b>
  80052f:	89 fe                	mov    %edi,%esi
  800531:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800534:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	7f 2e                	jg     80056b <vprintfmt+0x28e>
  80053d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800540:	e9 c4 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800548:	83 c2 01             	add    $0x1,%edx
  80054b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80054e:	89 f7                	mov    %esi,%edi
  800550:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800553:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800556:	89 d3                	mov    %edx,%ebx
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 9b                	js     8004f7 <vprintfmt+0x21a>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 96                	jns    8004f7 <vprintfmt+0x21a>
  800561:	89 fe                	mov    %edi,%esi
  800563:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800566:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800569:	eb cc                	jmp    800537 <vprintfmt+0x25a>
  80056b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80056e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800571:	89 74 24 04          	mov    %esi,0x4(%esp)
  800575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	85 db                	test   %ebx,%ebx
  800583:	7f ec                	jg     800571 <vprintfmt+0x294>
  800585:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800588:	e9 7c fd ff ff       	jmp    800309 <vprintfmt+0x2c>
  80058d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800590:	83 f9 01             	cmp    $0x1,%ecx
  800593:	7e 16                	jle    8005ab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 08             	lea    0x8(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005a9:	eb 32                	jmp    8005dd <vprintfmt+0x300>
	else if (lflag)
  8005ab:	85 c9                	test   %ecx,%ecx
  8005ad:	74 18                	je     8005c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005c5:	eb 16                	jmp    8005dd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d5:	89 c2                	mov    %eax,%edx
  8005d7:	c1 fa 1f             	sar    $0x1f,%edx
  8005da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005e8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ec:	0f 89 b8 00 00 00    	jns    8006aa <vprintfmt+0x3cd>
				putch('-', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fd:	ff d7                	call   *%edi
				num = -(long long) num;
  8005ff:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800602:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800605:	f7 d9                	neg    %ecx
  800607:	83 d3 00             	adc    $0x0,%ebx
  80060a:	f7 db                	neg    %ebx
  80060c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800611:	e9 94 00 00 00       	jmp    8006aa <vprintfmt+0x3cd>
  800616:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800619:	89 ca                	mov    %ecx,%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 63 fc ff ff       	call   800286 <getuint>
  800623:	89 c1                	mov    %eax,%ecx
  800625:	89 d3                	mov    %edx,%ebx
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80062c:	eb 7c                	jmp    8006aa <vprintfmt+0x3cd>
  80062e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800631:	89 74 24 04          	mov    %esi,0x4(%esp)
  800635:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80063c:	ff d7                	call   *%edi
			putch('X', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800649:	ff d7                	call   *%edi
			putch('X', putdat);
  80064b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800656:	ff d7                	call   *%edi
  800658:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80065b:	e9 a9 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  800660:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800663:	89 74 24 04          	mov    %esi,0x4(%esp)
  800667:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066e:	ff d7                	call   *%edi
			putch('x', putdat);
  800670:	89 74 24 04          	mov    %esi,0x4(%esp)
  800674:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)
  800686:	8b 08                	mov    (%eax),%ecx
  800688:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800692:	eb 16                	jmp    8006aa <vprintfmt+0x3cd>
  800694:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800697:	89 ca                	mov    %ecx,%edx
  800699:	8d 45 14             	lea    0x14(%ebp),%eax
  80069c:	e8 e5 fb ff ff       	call   800286 <getuint>
  8006a1:	89 c1                	mov    %eax,%ecx
  8006a3:	89 d3                	mov    %edx,%ebx
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006aa:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ae:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bd:	89 0c 24             	mov    %ecx,(%esp)
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	89 f2                	mov    %esi,%edx
  8006c6:	89 f8                	mov    %edi,%eax
  8006c8:	e8 c3 fa ff ff       	call   800190 <printnum>
  8006cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006d0:	e9 34 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  8006d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006df:	89 14 24             	mov    %edx,(%esp)
  8006e2:	ff d7                	call   *%edi
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006e7:	e9 1d fc ff ff       	jmp    800309 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006fc:	80 38 25             	cmpb   $0x25,(%eax)
  8006ff:	0f 84 04 fc ff ff    	je     800309 <vprintfmt+0x2c>
  800705:	89 c3                	mov    %eax,%ebx
  800707:	eb f0                	jmp    8006f9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800709:	83 c4 5c             	add    $0x5c,%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 28             	sub    $0x28,%esp
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 04                	je     800725 <vsnprintf+0x14>
  800721:	85 d2                	test   %edx,%edx
  800723:	7f 07                	jg     80072c <vsnprintf+0x1b>
  800725:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072a:	eb 3b                	jmp    800767 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800733:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800744:	8b 45 10             	mov    0x10(%ebp),%eax
  800747:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800752:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  800759:	e8 7f fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800761:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800764:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800772:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	e8 82 ff ff ff       	call   800711 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 26 fb ff ff       	call   8002dd <vprintfmt>
	va_end(ap);
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    
  8007b9:	00 00                	add    %al,(%eax)
  8007bb:	00 00                	add    %al,(%eax)
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 09                	je     8007d9 <strlen+0x19>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	85 c9                	test   %ecx,%ecx
  8007e7:	74 19                	je     800802 <strnlen+0x27>
  8007e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007ec:	74 14                	je     800802 <strnlen+0x27>
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f6:	39 c8                	cmp    %ecx,%eax
  8007f8:	74 0d                	je     800807 <strnlen+0x2c>
  8007fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007fe:	75 f3                	jne    8007f3 <strnlen+0x18>
  800800:	eb 05                	jmp    800807 <strnlen+0x2c>
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800814:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80081d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	84 c9                	test   %cl,%cl
  800825:	75 f2                	jne    800819 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800834:	89 1c 24             	mov    %ebx,(%esp)
  800837:	e8 84 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800843:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 bc ff ff ff       	call   80080a <strcpy>
	return dst;
}
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	85 f6                	test   %esi,%esi
  800866:	74 18                	je     800880 <strncpy+0x2a>
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80086d:	0f b6 1a             	movzbl (%edx),%ebx
  800870:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800873:	80 3a 01             	cmpb   $0x1,(%edx)
  800876:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	83 c1 01             	add    $0x1,%ecx
  80087c:	39 ce                	cmp    %ecx,%esi
  80087e:	77 ed                	ja     80086d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	89 f0                	mov    %esi,%eax
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 27                	je     8008bf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800898:	83 e9 01             	sub    $0x1,%ecx
  80089b:	74 1d                	je     8008ba <strlcpy+0x36>
  80089d:	0f b6 1a             	movzbl (%edx),%ebx
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	74 16                	je     8008ba <strlcpy+0x36>
			*dst++ = *src++;
  8008a4:	88 18                	mov    %bl,(%eax)
  8008a6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a9:	83 e9 01             	sub    $0x1,%ecx
  8008ac:	74 0e                	je     8008bc <strlcpy+0x38>
			*dst++ = *src++;
  8008ae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b1:	0f b6 1a             	movzbl (%edx),%ebx
  8008b4:	84 db                	test   %bl,%bl
  8008b6:	75 ec                	jne    8008a4 <strlcpy+0x20>
  8008b8:	eb 02                	jmp    8008bc <strlcpy+0x38>
  8008ba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008bc:	c6 00 00             	movb   $0x0,(%eax)
  8008bf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 15                	je     8008ea <strcmp+0x25>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	75 11                	jne    8008ea <strcmp+0x25>
		p++, q++;
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008df:	0f b6 01             	movzbl (%ecx),%eax
  8008e2:	84 c0                	test   %al,%al
  8008e4:	74 04                	je     8008ea <strcmp+0x25>
  8008e6:	3a 02                	cmp    (%edx),%al
  8008e8:	74 ef                	je     8008d9 <strcmp+0x14>
  8008ea:	0f b6 c0             	movzbl %al,%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	53                   	push   %ebx
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800901:	85 c0                	test   %eax,%eax
  800903:	74 23                	je     800928 <strncmp+0x34>
  800905:	0f b6 1a             	movzbl (%edx),%ebx
  800908:	84 db                	test   %bl,%bl
  80090a:	74 25                	je     800931 <strncmp+0x3d>
  80090c:	3a 19                	cmp    (%ecx),%bl
  80090e:	75 21                	jne    800931 <strncmp+0x3d>
  800910:	83 e8 01             	sub    $0x1,%eax
  800913:	74 13                	je     800928 <strncmp+0x34>
		n--, p++, q++;
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091b:	0f b6 1a             	movzbl (%edx),%ebx
  80091e:	84 db                	test   %bl,%bl
  800920:	74 0f                	je     800931 <strncmp+0x3d>
  800922:	3a 19                	cmp    (%ecx),%bl
  800924:	74 ea                	je     800910 <strncmp+0x1c>
  800926:	eb 09                	jmp    800931 <strncmp+0x3d>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092d:	5b                   	pop    %ebx
  80092e:	5d                   	pop    %ebp
  80092f:	90                   	nop
  800930:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800931:	0f b6 02             	movzbl (%edx),%eax
  800934:	0f b6 11             	movzbl (%ecx),%edx
  800937:	29 d0                	sub    %edx,%eax
  800939:	eb f2                	jmp    80092d <strncmp+0x39>

0080093b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 18                	je     800964 <strchr+0x29>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	75 0a                	jne    80095a <strchr+0x1f>
  800950:	eb 17                	jmp    800969 <strchr+0x2e>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800958:	74 0f                	je     800969 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 ee                	jne    800952 <strchr+0x17>
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 18                	je     800994 <strfind+0x29>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	75 0a                	jne    80098a <strfind+0x1f>
  800980:	eb 12                	jmp    800994 <strfind+0x29>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800988:	74 0a                	je     800994 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 ee                	jne    800982 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
  80099c:	89 1c 24             	mov    %ebx,(%esp)
  80099f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b0:	85 c9                	test   %ecx,%ecx
  8009b2:	74 30                	je     8009e4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ba:	75 25                	jne    8009e1 <memset+0x4b>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 20                	jne    8009e1 <memset+0x4b>
		c &= 0xFF;
  8009c1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c4:	89 d3                	mov    %edx,%ebx
  8009c6:	c1 e3 08             	shl    $0x8,%ebx
  8009c9:	89 d6                	mov    %edx,%esi
  8009cb:	c1 e6 18             	shl    $0x18,%esi
  8009ce:	89 d0                	mov    %edx,%eax
  8009d0:	c1 e0 10             	shl    $0x10,%eax
  8009d3:	09 f0                	or     %esi,%eax
  8009d5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009d7:	09 d8                	or     %ebx,%eax
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	fc                   	cld    
  8009dd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	eb 03                	jmp    8009e4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	8b 1c 24             	mov    (%esp),%ebx
  8009e9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009f1:	89 ec                	mov    %ebp,%esp
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	89 34 24             	mov    %esi,(%esp)
  8009fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a0d:	39 c6                	cmp    %eax,%esi
  800a0f:	73 35                	jae    800a46 <memmove+0x51>
  800a11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a14:	39 d0                	cmp    %edx,%eax
  800a16:	73 2e                	jae    800a46 <memmove+0x51>
		s += n;
		d += n;
  800a18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	f6 c2 03             	test   $0x3,%dl
  800a1d:	75 1b                	jne    800a3a <memmove+0x45>
  800a1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a25:	75 13                	jne    800a3a <memmove+0x45>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	75 0e                	jne    800a3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a2c:	83 ef 04             	sub    $0x4,%edi
  800a2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a32:	c1 e9 02             	shr    $0x2,%ecx
  800a35:	fd                   	std    
  800a36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	eb 09                	jmp    800a43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3a:	83 ef 01             	sub    $0x1,%edi
  800a3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a40:	fd                   	std    
  800a41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a44:	eb 20                	jmp    800a66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 15                	jne    800a63 <memmove+0x6e>
  800a4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a54:	75 0d                	jne    800a63 <memmove+0x6e>
  800a56:	f6 c1 03             	test   $0x3,%cl
  800a59:	75 08                	jne    800a63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a61:	eb 03                	jmp    800a66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a63:	fc                   	cld    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a66:	8b 34 24             	mov    (%esp),%esi
  800a69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a6d:	89 ec                	mov    %ebp,%esp
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a77:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	89 04 24             	mov    %eax,(%esp)
  800a8b:	e8 65 ff ff ff       	call   8009f5 <memmove>
}
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 36                	je     800adb <memcmp+0x49>
		if (*s1 != *s2)
  800aa5:	0f b6 06             	movzbl (%esi),%eax
  800aa8:	0f b6 1f             	movzbl (%edi),%ebx
  800aab:	38 d8                	cmp    %bl,%al
  800aad:	74 20                	je     800acf <memcmp+0x3d>
  800aaf:	eb 14                	jmp    800ac5 <memcmp+0x33>
  800ab1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ab6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800abb:	83 c2 01             	add    $0x1,%edx
  800abe:	83 e9 01             	sub    $0x1,%ecx
  800ac1:	38 d8                	cmp    %bl,%al
  800ac3:	74 12                	je     800ad7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ac5:	0f b6 c0             	movzbl %al,%eax
  800ac8:	0f b6 db             	movzbl %bl,%ebx
  800acb:	29 d8                	sub    %ebx,%eax
  800acd:	eb 11                	jmp    800ae0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	83 e9 01             	sub    $0x1,%ecx
  800ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad7:	85 c9                	test   %ecx,%ecx
  800ad9:	75 d6                	jne    800ab1 <memcmp+0x1f>
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	73 15                	jae    800b09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800af8:	38 08                	cmp    %cl,(%eax)
  800afa:	75 06                	jne    800b02 <memfind+0x1d>
  800afc:	eb 0b                	jmp    800b09 <memfind+0x24>
  800afe:	38 08                	cmp    %cl,(%eax)
  800b00:	74 07                	je     800b09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 c2                	cmp    %eax,%edx
  800b07:	77 f5                	ja     800afe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	83 ec 04             	sub    $0x4,%esp
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1a:	0f b6 02             	movzbl (%edx),%eax
  800b1d:	3c 20                	cmp    $0x20,%al
  800b1f:	74 04                	je     800b25 <strtol+0x1a>
  800b21:	3c 09                	cmp    $0x9,%al
  800b23:	75 0e                	jne    800b33 <strtol+0x28>
		s++;
  800b25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b28:	0f b6 02             	movzbl (%edx),%eax
  800b2b:	3c 20                	cmp    $0x20,%al
  800b2d:	74 f6                	je     800b25 <strtol+0x1a>
  800b2f:	3c 09                	cmp    $0x9,%al
  800b31:	74 f2                	je     800b25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b33:	3c 2b                	cmp    $0x2b,%al
  800b35:	75 0c                	jne    800b43 <strtol+0x38>
		s++;
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b41:	eb 15                	jmp    800b58 <strtol+0x4d>
	else if (*s == '-')
  800b43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b4a:	3c 2d                	cmp    $0x2d,%al
  800b4c:	75 0a                	jne    800b58 <strtol+0x4d>
		s++, neg = 1;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	85 db                	test   %ebx,%ebx
  800b5a:	0f 94 c0             	sete   %al
  800b5d:	74 05                	je     800b64 <strtol+0x59>
  800b5f:	83 fb 10             	cmp    $0x10,%ebx
  800b62:	75 18                	jne    800b7c <strtol+0x71>
  800b64:	80 3a 30             	cmpb   $0x30,(%edx)
  800b67:	75 13                	jne    800b7c <strtol+0x71>
  800b69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6d:	8d 76 00             	lea    0x0(%esi),%esi
  800b70:	75 0a                	jne    800b7c <strtol+0x71>
		s += 2, base = 16;
  800b72:	83 c2 02             	add    $0x2,%edx
  800b75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	eb 15                	jmp    800b91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7c:	84 c0                	test   %al,%al
  800b7e:	66 90                	xchg   %ax,%ax
  800b80:	74 0f                	je     800b91 <strtol+0x86>
  800b82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b87:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8a:	75 05                	jne    800b91 <strtol+0x86>
		s++, base = 8;
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 0a             	movzbl (%edx),%ecx
  800b9b:	89 cf                	mov    %ecx,%edi
  800b9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	77 08                	ja     800bad <strtol+0xa2>
			dig = *s - '0';
  800ba5:	0f be c9             	movsbl %cl,%ecx
  800ba8:	83 e9 30             	sub    $0x30,%ecx
  800bab:	eb 1e                	jmp    800bcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 57             	sub    $0x57,%ecx
  800bbb:	eb 0e                	jmp    800bcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 15                	ja     800bda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bc5:	0f be c9             	movsbl %cl,%ecx
  800bc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcb:	39 f1                	cmp    %esi,%ecx
  800bcd:	7d 0b                	jge    800bda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	0f af c6             	imul   %esi,%eax
  800bd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bd8:	eb be                	jmp    800b98 <strtol+0x8d>
  800bda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be0:	74 05                	je     800be7 <strtol+0xdc>
		*endptr = (char *) s;
  800be2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800beb:	74 04                	je     800bf1 <strtol+0xe6>
  800bed:	89 c8                	mov    %ecx,%eax
  800bef:	f7 d8                	neg    %eax
}
  800bf1:	83 c4 04             	add    $0x4,%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	00 00                	add    %al,(%eax)
	...

00800bfc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	89 1c 24             	mov    %ebx,(%esp)
  800c05:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c09:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	89 d7                	mov    %edx,%edi
  800c19:	51                   	push   %ecx
  800c1a:	52                   	push   %edx
  800c1b:	53                   	push   %ebx
  800c1c:	54                   	push   %esp
  800c1d:	55                   	push   %ebp
  800c1e:	56                   	push   %esi
  800c1f:	57                   	push   %edi
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	8d 35 2a 0c 80 00    	lea    0x800c2a,%esi
  800c28:	0f 34                	sysenter 
  800c2a:	5f                   	pop    %edi
  800c2b:	5e                   	pop    %esi
  800c2c:	5d                   	pop    %ebp
  800c2d:	5c                   	pop    %esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5a                   	pop    %edx
  800c30:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c31:	8b 1c 24             	mov    (%esp),%ebx
  800c34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c38:	89 ec                	mov    %ebp,%esp
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	89 1c 24             	mov    %ebx,(%esp)
  800c45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 c3                	mov    %eax,%ebx
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	51                   	push   %ecx
  800c59:	52                   	push   %edx
  800c5a:	53                   	push   %ebx
  800c5b:	54                   	push   %esp
  800c5c:	55                   	push   %ebp
  800c5d:	56                   	push   %esi
  800c5e:	57                   	push   %edi
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	8d 35 69 0c 80 00    	lea    0x800c69,%esi
  800c67:	0f 34                	sysenter 
  800c69:	5f                   	pop    %edi
  800c6a:	5e                   	pop    %esi
  800c6b:	5d                   	pop    %ebp
  800c6c:	5c                   	pop    %esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5a                   	pop    %edx
  800c6f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c70:	8b 1c 24             	mov    (%esp),%ebx
  800c73:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c77:	89 ec                	mov    %ebp,%esp
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	89 1c 24             	mov    %ebx,(%esp)
  800c84:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	89 cb                	mov    %ecx,%ebx
  800c97:	89 cf                	mov    %ecx,%edi
  800c99:	51                   	push   %ecx
  800c9a:	52                   	push   %edx
  800c9b:	53                   	push   %ebx
  800c9c:	54                   	push   %esp
  800c9d:	55                   	push   %ebp
  800c9e:	56                   	push   %esi
  800c9f:	57                   	push   %edi
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	8d 35 aa 0c 80 00    	lea    0x800caa,%esi
  800ca8:	0f 34                	sysenter 
  800caa:	5f                   	pop    %edi
  800cab:	5e                   	pop    %esi
  800cac:	5d                   	pop    %ebp
  800cad:	5c                   	pop    %esp
  800cae:	5b                   	pop    %ebx
  800caf:	5a                   	pop    %edx
  800cb0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800cb1:	8b 1c 24             	mov    (%esp),%ebx
  800cb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cb8:	89 ec                	mov    %ebp,%esp
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 28             	sub    $0x28,%esp
  800cc2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cc5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 cb                	mov    %ecx,%ebx
  800cd7:	89 cf                	mov    %ecx,%edi
  800cd9:	51                   	push   %ecx
  800cda:	52                   	push   %edx
  800cdb:	53                   	push   %ebx
  800cdc:	54                   	push   %esp
  800cdd:	55                   	push   %ebp
  800cde:	56                   	push   %esi
  800cdf:	57                   	push   %edi
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	8d 35 ea 0c 80 00    	lea    0x800cea,%esi
  800ce8:	0f 34                	sysenter 
  800cea:	5f                   	pop    %edi
  800ceb:	5e                   	pop    %esi
  800cec:	5d                   	pop    %ebp
  800ced:	5c                   	pop    %esp
  800cee:	5b                   	pop    %ebx
  800cef:	5a                   	pop    %edx
  800cf0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 28                	jle    800d1d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d00:	00 
  800d01:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800d08:	00 
  800d09:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d10:	00 
  800d11:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800d18:	e8 97 03 00 00       	call   8010b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d23:	89 ec                	mov    %ebp,%esp
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
  800d2d:	89 1c 24             	mov    %ebx,(%esp)
  800d30:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	51                   	push   %ecx
  800d46:	52                   	push   %edx
  800d47:	53                   	push   %ebx
  800d48:	54                   	push   %esp
  800d49:	55                   	push   %ebp
  800d4a:	56                   	push   %esi
  800d4b:	57                   	push   %edi
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	8d 35 56 0d 80 00    	lea    0x800d56,%esi
  800d54:	0f 34                	sysenter 
  800d56:	5f                   	pop    %edi
  800d57:	5e                   	pop    %esi
  800d58:	5d                   	pop    %ebp
  800d59:	5c                   	pop    %esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5a                   	pop    %edx
  800d5c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5d:	8b 1c 24             	mov    (%esp),%ebx
  800d60:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d64:	89 ec                	mov    %ebp,%esp
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 28             	sub    $0x28,%esp
  800d6e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d71:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	51                   	push   %ecx
  800d87:	52                   	push   %edx
  800d88:	53                   	push   %ebx
  800d89:	54                   	push   %esp
  800d8a:	55                   	push   %ebp
  800d8b:	56                   	push   %esi
  800d8c:	57                   	push   %edi
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	8d 35 97 0d 80 00    	lea    0x800d97,%esi
  800d95:	0f 34                	sysenter 
  800d97:	5f                   	pop    %edi
  800d98:	5e                   	pop    %esi
  800d99:	5d                   	pop    %ebp
  800d9a:	5c                   	pop    %esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5a                   	pop    %edx
  800d9d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 28                	jle    800dca <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dad:	00 
  800dae:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800db5:	00 
  800db6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800dbd:	00 
  800dbe:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800dc5:	e8 ea 02 00 00       	call   8010b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800dcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd0:	89 ec                	mov    %ebp,%esp
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 28             	sub    $0x28,%esp
  800dda:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ddd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	89 df                	mov    %ebx,%edi
  800df2:	51                   	push   %ecx
  800df3:	52                   	push   %edx
  800df4:	53                   	push   %ebx
  800df5:	54                   	push   %esp
  800df6:	55                   	push   %ebp
  800df7:	56                   	push   %esi
  800df8:	57                   	push   %edi
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	8d 35 03 0e 80 00    	lea    0x800e03,%esi
  800e01:	0f 34                	sysenter 
  800e03:	5f                   	pop    %edi
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	5c                   	pop    %esp
  800e07:	5b                   	pop    %ebx
  800e08:	5a                   	pop    %edx
  800e09:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 28                	jle    800e36 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e12:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e19:	00 
  800e1a:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e21:	00 
  800e22:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e29:	00 
  800e2a:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e31:	e8 7e 02 00 00       	call   8010b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e36:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3c:	89 ec                	mov    %ebp,%esp
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 28             	sub    $0x28,%esp
  800e46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e49:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 07 00 00 00       	mov    $0x7,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	51                   	push   %ecx
  800e5f:	52                   	push   %edx
  800e60:	53                   	push   %ebx
  800e61:	54                   	push   %esp
  800e62:	55                   	push   %ebp
  800e63:	56                   	push   %esi
  800e64:	57                   	push   %edi
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	8d 35 6f 0e 80 00    	lea    0x800e6f,%esi
  800e6d:	0f 34                	sysenter 
  800e6f:	5f                   	pop    %edi
  800e70:	5e                   	pop    %esi
  800e71:	5d                   	pop    %ebp
  800e72:	5c                   	pop    %esp
  800e73:	5b                   	pop    %ebx
  800e74:	5a                   	pop    %edx
  800e75:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	7e 28                	jle    800ea2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e85:	00 
  800e86:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e95:	00 
  800e96:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e9d:	e8 12 02 00 00       	call   8010b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 28             	sub    $0x28,%esp
  800eb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800eb5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ebd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	51                   	push   %ecx
  800eca:	52                   	push   %edx
  800ecb:	53                   	push   %ebx
  800ecc:	54                   	push   %esp
  800ecd:	55                   	push   %ebp
  800ece:	56                   	push   %esi
  800ecf:	57                   	push   %edi
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	8d 35 da 0e 80 00    	lea    0x800eda,%esi
  800ed8:	0f 34                	sysenter 
  800eda:	5f                   	pop    %edi
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	5c                   	pop    %esp
  800ede:	5b                   	pop    %ebx
  800edf:	5a                   	pop    %edx
  800ee0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	7e 28                	jle    800f0d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f08:	e8 a7 01 00 00       	call   8010b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f0d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f13:	89 ec                	mov    %ebp,%esp
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 28             	sub    $0x28,%esp
  800f1d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f20:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f23:	bf 00 00 00 00       	mov    $0x0,%edi
  800f28:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	51                   	push   %ecx
  800f37:	52                   	push   %edx
  800f38:	53                   	push   %ebx
  800f39:	54                   	push   %esp
  800f3a:	55                   	push   %ebp
  800f3b:	56                   	push   %esi
  800f3c:	57                   	push   %edi
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	8d 35 47 0f 80 00    	lea    0x800f47,%esi
  800f45:	0f 34                	sysenter 
  800f47:	5f                   	pop    %edi
  800f48:	5e                   	pop    %esi
  800f49:	5d                   	pop    %ebp
  800f4a:	5c                   	pop    %esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5a                   	pop    %edx
  800f4d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	7e 28                	jle    800f7a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f56:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f65:	00 
  800f66:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f6d:	00 
  800f6e:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f75:	e8 3a 01 00 00       	call   8010b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f7a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f80:	89 ec                	mov    %ebp,%esp
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	89 1c 24             	mov    %ebx,(%esp)
  800f8d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f91:	ba 00 00 00 00       	mov    $0x0,%edx
  800f96:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f9b:	89 d1                	mov    %edx,%ecx
  800f9d:	89 d3                	mov    %edx,%ebx
  800f9f:	89 d7                	mov    %edx,%edi
  800fa1:	51                   	push   %ecx
  800fa2:	52                   	push   %edx
  800fa3:	53                   	push   %ebx
  800fa4:	54                   	push   %esp
  800fa5:	55                   	push   %ebp
  800fa6:	56                   	push   %esi
  800fa7:	57                   	push   %edi
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	8d 35 b2 0f 80 00    	lea    0x800fb2,%esi
  800fb0:	0f 34                	sysenter 
  800fb2:	5f                   	pop    %edi
  800fb3:	5e                   	pop    %esi
  800fb4:	5d                   	pop    %ebp
  800fb5:	5c                   	pop    %esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5a                   	pop    %edx
  800fb8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fb9:	8b 1c 24             	mov    (%esp),%ebx
  800fbc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc0:	89 ec                	mov    %ebp,%esp
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	89 1c 24             	mov    %ebx,(%esp)
  800fcd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fde:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe1:	89 df                	mov    %ebx,%edi
  800fe3:	51                   	push   %ecx
  800fe4:	52                   	push   %edx
  800fe5:	53                   	push   %ebx
  800fe6:	54                   	push   %esp
  800fe7:	55                   	push   %ebp
  800fe8:	56                   	push   %esi
  800fe9:	57                   	push   %edi
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	8d 35 f4 0f 80 00    	lea    0x800ff4,%esi
  800ff2:	0f 34                	sysenter 
  800ff4:	5f                   	pop    %edi
  800ff5:	5e                   	pop    %esi
  800ff6:	5d                   	pop    %ebp
  800ff7:	5c                   	pop    %esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5a                   	pop    %edx
  800ffa:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ffb:	8b 1c 24             	mov    (%esp),%ebx
  800ffe:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801002:	89 ec                	mov    %ebp,%esp
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 08             	sub    $0x8,%esp
  80100c:	89 1c 24             	mov    %ebx,(%esp)
  80100f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801013:	ba 00 00 00 00       	mov    $0x0,%edx
  801018:	b8 02 00 00 00       	mov    $0x2,%eax
  80101d:	89 d1                	mov    %edx,%ecx
  80101f:	89 d3                	mov    %edx,%ebx
  801021:	89 d7                	mov    %edx,%edi
  801023:	51                   	push   %ecx
  801024:	52                   	push   %edx
  801025:	53                   	push   %ebx
  801026:	54                   	push   %esp
  801027:	55                   	push   %ebp
  801028:	56                   	push   %esi
  801029:	57                   	push   %edi
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	8d 35 34 10 80 00    	lea    0x801034,%esi
  801032:	0f 34                	sysenter 
  801034:	5f                   	pop    %edi
  801035:	5e                   	pop    %esi
  801036:	5d                   	pop    %ebp
  801037:	5c                   	pop    %esp
  801038:	5b                   	pop    %ebx
  801039:	5a                   	pop    %edx
  80103a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80103b:	8b 1c 24             	mov    (%esp),%ebx
  80103e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801042:	89 ec                	mov    %ebp,%esp
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	83 ec 28             	sub    $0x28,%esp
  80104c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80104f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801052:	b9 00 00 00 00       	mov    $0x0,%ecx
  801057:	b8 03 00 00 00       	mov    $0x3,%eax
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	89 cb                	mov    %ecx,%ebx
  801061:	89 cf                	mov    %ecx,%edi
  801063:	51                   	push   %ecx
  801064:	52                   	push   %edx
  801065:	53                   	push   %ebx
  801066:	54                   	push   %esp
  801067:	55                   	push   %ebp
  801068:	56                   	push   %esi
  801069:	57                   	push   %edi
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	8d 35 74 10 80 00    	lea    0x801074,%esi
  801072:	0f 34                	sysenter 
  801074:	5f                   	pop    %edi
  801075:	5e                   	pop    %esi
  801076:	5d                   	pop    %ebp
  801077:	5c                   	pop    %esp
  801078:	5b                   	pop    %ebx
  801079:	5a                   	pop    %edx
  80107a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80107b:	85 c0                	test   %eax,%eax
  80107d:	7e 28                	jle    8010a7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801083:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80108a:	00 
  80108b:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  8010a2:	e8 0d 00 00 00       	call   8010b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ad:	89 ec                	mov    %ebp,%esp
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    
  8010b1:	00 00                	add    %al,(%eax)
	...

008010b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8010bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8010bf:	a1 08 20 80 00       	mov    0x802008,%eax
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	74 10                	je     8010d8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8010c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cc:	c7 04 24 4f 16 80 00 	movl   $0x80164f,(%esp)
  8010d3:	e8 4d f0 ff ff       	call   800125 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010d8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8010de:	e8 23 ff ff ff       	call   801006 <sys_getenvid>
  8010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  801100:	e8 20 f0 ff ff       	call   800125 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801105:	89 74 24 04          	mov    %esi,0x4(%esp)
  801109:	8b 45 10             	mov    0x10(%ebp),%eax
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 b0 ef ff ff       	call   8000c4 <vcprintf>
	cprintf("\n");
  801114:	c7 04 24 ac 13 80 00 	movl   $0x8013ac,(%esp)
  80111b:	e8 05 f0 ff ff       	call   800125 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801120:	cc                   	int3   
  801121:	eb fd                	jmp    801120 <_panic+0x6c>
	...

00801130 <__udivdi3>:
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	83 ec 10             	sub    $0x10,%esp
  801138:	8b 45 14             	mov    0x14(%ebp),%eax
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	8b 75 10             	mov    0x10(%ebp),%esi
  801141:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801144:	85 c0                	test   %eax,%eax
  801146:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801149:	75 35                	jne    801180 <__udivdi3+0x50>
  80114b:	39 fe                	cmp    %edi,%esi
  80114d:	77 61                	ja     8011b0 <__udivdi3+0x80>
  80114f:	85 f6                	test   %esi,%esi
  801151:	75 0b                	jne    80115e <__udivdi3+0x2e>
  801153:	b8 01 00 00 00       	mov    $0x1,%eax
  801158:	31 d2                	xor    %edx,%edx
  80115a:	f7 f6                	div    %esi
  80115c:	89 c6                	mov    %eax,%esi
  80115e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801161:	31 d2                	xor    %edx,%edx
  801163:	89 f8                	mov    %edi,%eax
  801165:	f7 f6                	div    %esi
  801167:	89 c7                	mov    %eax,%edi
  801169:	89 c8                	mov    %ecx,%eax
  80116b:	f7 f6                	div    %esi
  80116d:	89 c1                	mov    %eax,%ecx
  80116f:	89 fa                	mov    %edi,%edx
  801171:	89 c8                	mov    %ecx,%eax
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    
  80117a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801180:	39 f8                	cmp    %edi,%eax
  801182:	77 1c                	ja     8011a0 <__udivdi3+0x70>
  801184:	0f bd d0             	bsr    %eax,%edx
  801187:	83 f2 1f             	xor    $0x1f,%edx
  80118a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80118d:	75 39                	jne    8011c8 <__udivdi3+0x98>
  80118f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801192:	0f 86 a0 00 00 00    	jbe    801238 <__udivdi3+0x108>
  801198:	39 f8                	cmp    %edi,%eax
  80119a:	0f 82 98 00 00 00    	jb     801238 <__udivdi3+0x108>
  8011a0:	31 ff                	xor    %edi,%edi
  8011a2:	31 c9                	xor    %ecx,%ecx
  8011a4:	89 c8                	mov    %ecx,%eax
  8011a6:	89 fa                	mov    %edi,%edx
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    
  8011af:	90                   	nop
  8011b0:	89 d1                	mov    %edx,%ecx
  8011b2:	89 fa                	mov    %edi,%edx
  8011b4:	89 c8                	mov    %ecx,%eax
  8011b6:	31 ff                	xor    %edi,%edi
  8011b8:	f7 f6                	div    %esi
  8011ba:	89 c1                	mov    %eax,%ecx
  8011bc:	89 fa                	mov    %edi,%edx
  8011be:	89 c8                	mov    %ecx,%eax
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    
  8011c7:	90                   	nop
  8011c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	d3 e0                	shl    %cl,%eax
  8011d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011db:	89 c1                	mov    %eax,%ecx
  8011dd:	d3 ea                	shr    %cl,%edx
  8011df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011e6:	d3 e6                	shl    %cl,%esi
  8011e8:	89 c1                	mov    %eax,%ecx
  8011ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011ed:	89 fe                	mov    %edi,%esi
  8011ef:	d3 ee                	shr    %cl,%esi
  8011f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011fb:	d3 e7                	shl    %cl,%edi
  8011fd:	89 c1                	mov    %eax,%ecx
  8011ff:	d3 ea                	shr    %cl,%edx
  801201:	09 d7                	or     %edx,%edi
  801203:	89 f2                	mov    %esi,%edx
  801205:	89 f8                	mov    %edi,%eax
  801207:	f7 75 ec             	divl   -0x14(%ebp)
  80120a:	89 d6                	mov    %edx,%esi
  80120c:	89 c7                	mov    %eax,%edi
  80120e:	f7 65 e8             	mull   -0x18(%ebp)
  801211:	39 d6                	cmp    %edx,%esi
  801213:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801216:	72 30                	jb     801248 <__udivdi3+0x118>
  801218:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80121b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80121f:	d3 e2                	shl    %cl,%edx
  801221:	39 c2                	cmp    %eax,%edx
  801223:	73 05                	jae    80122a <__udivdi3+0xfa>
  801225:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801228:	74 1e                	je     801248 <__udivdi3+0x118>
  80122a:	89 f9                	mov    %edi,%ecx
  80122c:	31 ff                	xor    %edi,%edi
  80122e:	e9 71 ff ff ff       	jmp    8011a4 <__udivdi3+0x74>
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	31 ff                	xor    %edi,%edi
  80123a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80123f:	e9 60 ff ff ff       	jmp    8011a4 <__udivdi3+0x74>
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80124b:	31 ff                	xor    %edi,%edi
  80124d:	89 c8                	mov    %ecx,%eax
  80124f:	89 fa                	mov    %edi,%edx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
	...

00801260 <__umoddi3>:
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	83 ec 20             	sub    $0x20,%esp
  801268:	8b 55 14             	mov    0x14(%ebp),%edx
  80126b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801271:	8b 75 0c             	mov    0xc(%ebp),%esi
  801274:	85 d2                	test   %edx,%edx
  801276:	89 c8                	mov    %ecx,%eax
  801278:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80127b:	75 13                	jne    801290 <__umoddi3+0x30>
  80127d:	39 f7                	cmp    %esi,%edi
  80127f:	76 3f                	jbe    8012c0 <__umoddi3+0x60>
  801281:	89 f2                	mov    %esi,%edx
  801283:	f7 f7                	div    %edi
  801285:	89 d0                	mov    %edx,%eax
  801287:	31 d2                	xor    %edx,%edx
  801289:	83 c4 20             	add    $0x20,%esp
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    
  801290:	39 f2                	cmp    %esi,%edx
  801292:	77 4c                	ja     8012e0 <__umoddi3+0x80>
  801294:	0f bd ca             	bsr    %edx,%ecx
  801297:	83 f1 1f             	xor    $0x1f,%ecx
  80129a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80129d:	75 51                	jne    8012f0 <__umoddi3+0x90>
  80129f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8012a2:	0f 87 e0 00 00 00    	ja     801388 <__umoddi3+0x128>
  8012a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ab:	29 f8                	sub    %edi,%eax
  8012ad:	19 d6                	sbb    %edx,%esi
  8012af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b5:	89 f2                	mov    %esi,%edx
  8012b7:	83 c4 20             	add    $0x20,%esp
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    
  8012be:	66 90                	xchg   %ax,%ax
  8012c0:	85 ff                	test   %edi,%edi
  8012c2:	75 0b                	jne    8012cf <__umoddi3+0x6f>
  8012c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c9:	31 d2                	xor    %edx,%edx
  8012cb:	f7 f7                	div    %edi
  8012cd:	89 c7                	mov    %eax,%edi
  8012cf:	89 f0                	mov    %esi,%eax
  8012d1:	31 d2                	xor    %edx,%edx
  8012d3:	f7 f7                	div    %edi
  8012d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d8:	f7 f7                	div    %edi
  8012da:	eb a9                	jmp    801285 <__umoddi3+0x25>
  8012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 c8                	mov    %ecx,%eax
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	83 c4 20             	add    $0x20,%esp
  8012e7:	5e                   	pop    %esi
  8012e8:	5f                   	pop    %edi
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    
  8012eb:	90                   	nop
  8012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f4:	d3 e2                	shl    %cl,%edx
  8012f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8012fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801301:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801304:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801308:	89 fa                	mov    %edi,%edx
  80130a:	d3 ea                	shr    %cl,%edx
  80130c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801310:	0b 55 f4             	or     -0xc(%ebp),%edx
  801313:	d3 e7                	shl    %cl,%edi
  801315:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801319:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80131c:	89 f2                	mov    %esi,%edx
  80131e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801321:	89 c7                	mov    %eax,%edi
  801323:	d3 ea                	shr    %cl,%edx
  801325:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801329:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	d3 e6                	shl    %cl,%esi
  801330:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801334:	d3 ea                	shr    %cl,%edx
  801336:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80133a:	09 d6                	or     %edx,%esi
  80133c:	89 f0                	mov    %esi,%eax
  80133e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801341:	d3 e7                	shl    %cl,%edi
  801343:	89 f2                	mov    %esi,%edx
  801345:	f7 75 f4             	divl   -0xc(%ebp)
  801348:	89 d6                	mov    %edx,%esi
  80134a:	f7 65 e8             	mull   -0x18(%ebp)
  80134d:	39 d6                	cmp    %edx,%esi
  80134f:	72 2b                	jb     80137c <__umoddi3+0x11c>
  801351:	39 c7                	cmp    %eax,%edi
  801353:	72 23                	jb     801378 <__umoddi3+0x118>
  801355:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801359:	29 c7                	sub    %eax,%edi
  80135b:	19 d6                	sbb    %edx,%esi
  80135d:	89 f0                	mov    %esi,%eax
  80135f:	89 f2                	mov    %esi,%edx
  801361:	d3 ef                	shr    %cl,%edi
  801363:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801367:	d3 e0                	shl    %cl,%eax
  801369:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80136d:	09 f8                	or     %edi,%eax
  80136f:	d3 ea                	shr    %cl,%edx
  801371:	83 c4 20             	add    $0x20,%esp
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    
  801378:	39 d6                	cmp    %edx,%esi
  80137a:	75 d9                	jne    801355 <__umoddi3+0xf5>
  80137c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80137f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801382:	eb d1                	jmp    801355 <__umoddi3+0xf5>
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	39 f2                	cmp    %esi,%edx
  80138a:	0f 82 18 ff ff ff    	jb     8012a8 <__umoddi3+0x48>
  801390:	e9 1d ff ff ff       	jmp    8012b2 <__umoddi3+0x52>
