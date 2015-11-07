
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 a0 13 80 00 	movl   $0x8013a0,(%esp)
  80004a:	e8 ca 00 00 00       	call   800119 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800066:	e8 8b 0f 00 00       	call   800ff6 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	c1 e0 07             	shl    $0x7,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 80 0f 00 00       	call   801036 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000c8:	00 00 00 
	b.cnt = 0;
  8000cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 33 01 80 00 	movl   $0x800133,(%esp)
  8000f4:	e8 d4 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000f9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 1b 0b 00 00       	call   800c2c <sys_cputs>

	return b.cnt;
}
  800111:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80011f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800122:	89 44 24 04          	mov    %eax,0x4(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 87 ff ff ff       	call   8000b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	53                   	push   %ebx
  800137:	83 ec 14             	sub    $0x14,%esp
  80013a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013d:	8b 03                	mov    (%ebx),%eax
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800146:	83 c0 01             	add    $0x1,%eax
  800149:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800150:	75 19                	jne    80016b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800152:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800159:	00 
  80015a:	8d 43 08             	lea    0x8(%ebx),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 c7 0a 00 00       	call   800c2c <sys_cputs>
		b->idx = 0;
  800165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016f:	83 c4 14             	add    $0x14,%esp
  800172:	5b                   	pop    %ebx
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 15                	jb     8001c4 <printnum+0x44>
  8001af:	77 07                	ja     8001b8 <printnum+0x38>
  8001b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b4:	39 d0                	cmp    %edx,%eax
  8001b6:	76 0c                	jbe    8001c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b8:	83 eb 01             	sub    $0x1,%ebx
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	8d 76 00             	lea    0x0(%esi),%esi
  8001c0:	7f 61                	jg     800223 <printnum+0xa3>
  8001c2:	eb 70                	jmp    800234 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	e8 1e 0f 00 00       	call   801120 <__udivdi3>
  800202:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800205:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	89 54 24 04          	mov    %edx,0x4(%esp)
  800217:	89 f2                	mov    %esi,%edx
  800219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021c:	e8 5f ff ff ff       	call   800180 <printnum>
  800221:	eb 11                	jmp    800234 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	89 74 24 04          	mov    %esi,0x4(%esp)
  800227:	89 3c 24             	mov    %edi,(%esp)
  80022a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ef                	jg     800223 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 74 24 04          	mov    %esi,0x4(%esp)
  800238:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80024e:	89 14 24             	mov    %edx,(%esp)
  800251:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800254:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800258:	e8 f3 0f 00 00       	call   801250 <__umoddi3>
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	0f be 80 c8 13 80 00 	movsbl 0x8013c8(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 4c             	add    $0x4c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	88 0a                	mov    %cl,(%edx)
  8002c6:	83 c2 01             	add    $0x1,%edx
  8002c9:	89 10                	mov    %edx,(%eax)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 5c             	sub    $0x5c,%esp
  8002d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e6:	eb 11                	jmp    8002f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 09 04 00 00    	je     8006f9 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 03             	movzbl (%ebx),%eax
  8002fc:	83 c3 01             	add    $0x1,%ebx
  8002ff:	83 f8 25             	cmp    $0x25,%eax
  800302:	75 e4                	jne    8002e8 <vprintfmt+0x1b>
  800304:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800308:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80030f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800316:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	eb 06                	jmp    80032a <vprintfmt+0x5d>
  800324:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800328:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	0f b6 13             	movzbl (%ebx),%edx
  80032d:	0f b6 c2             	movzbl %dl,%eax
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	8d 43 01             	lea    0x1(%ebx),%eax
  800336:	83 ea 23             	sub    $0x23,%edx
  800339:	80 fa 55             	cmp    $0x55,%dl
  80033c:	0f 87 9a 03 00 00    	ja     8006dc <vprintfmt+0x40f>
  800342:	0f b6 d2             	movzbl %dl,%edx
  800345:	ff 24 95 80 14 80 00 	jmp    *0x801480(,%edx,4)
  80034c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800350:	eb d6                	jmp    800328 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800355:	83 ea 30             	sub    $0x30,%edx
  800358:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80035b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80035e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800361:	83 fb 09             	cmp    $0x9,%ebx
  800364:	77 4c                	ja     8003b2 <vprintfmt+0xe5>
  800366:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800369:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80036f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800372:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800376:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800379:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80037c:	83 fb 09             	cmp    $0x9,%ebx
  80037f:	76 eb                	jbe    80036c <vprintfmt+0x9f>
  800381:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800384:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800387:	eb 29                	jmp    8003b2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800389:	8b 55 14             	mov    0x14(%ebp),%edx
  80038c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80038f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800392:	8b 12                	mov    (%edx),%edx
  800394:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800397:	eb 19                	jmp    8003b2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800399:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039c:	c1 fa 1f             	sar    $0x1f,%edx
  80039f:	f7 d2                	not    %edx
  8003a1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003a4:	eb 82                	jmp    800328 <vprintfmt+0x5b>
  8003a6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003ad:	e9 76 ff ff ff       	jmp    800328 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b6:	0f 89 6c ff ff ff    	jns    800328 <vprintfmt+0x5b>
  8003bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003c2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003c8:	e9 5b ff ff ff       	jmp    800328 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003d0:	e9 53 ff ff ff       	jmp    800328 <vprintfmt+0x5b>
  8003d5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 50 04             	lea    0x4(%eax),%edx
  8003de:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff d7                	call   *%edi
  8003ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8003ef:	e9 05 ff ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  8003f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 50 04             	lea    0x4(%eax),%edx
  8003fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	89 c2                	mov    %eax,%edx
  800404:	c1 fa 1f             	sar    $0x1f,%edx
  800407:	31 d0                	xor    %edx,%eax
  800409:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 08             	cmp    $0x8,%eax
  80040e:	7f 0b                	jg     80041b <vprintfmt+0x14e>
  800410:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800417:	85 d2                	test   %edx,%edx
  800419:	75 20                	jne    80043b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80041b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041f:	c7 44 24 08 d9 13 80 	movl   $0x8013d9,0x8(%esp)
  800426:	00 
  800427:	89 74 24 04          	mov    %esi,0x4(%esp)
  80042b:	89 3c 24             	mov    %edi,(%esp)
  80042e:	e8 4e 03 00 00       	call   800781 <printfmt>
  800433:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800436:	e9 be fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80043b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043f:	c7 44 24 08 e2 13 80 	movl   $0x8013e2,0x8(%esp)
  800446:	00 
  800447:	89 74 24 04          	mov    %esi,0x4(%esp)
  80044b:	89 3c 24             	mov    %edi,(%esp)
  80044e:	e8 2e 03 00 00       	call   800781 <printfmt>
  800453:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800456:	e9 9e fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	89 c3                	mov    %eax,%ebx
  800460:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800466:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 50 04             	lea    0x4(%eax),%edx
  80046f:	89 55 14             	mov    %edx,0x14(%ebp)
  800472:	8b 00                	mov    (%eax),%eax
  800474:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800477:	85 c0                	test   %eax,%eax
  800479:	75 07                	jne    800482 <vprintfmt+0x1b5>
  80047b:	c7 45 c4 e5 13 80 00 	movl   $0x8013e5,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800482:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800486:	7e 06                	jle    80048e <vprintfmt+0x1c1>
  800488:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80048c:	75 13                	jne    8004a1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800491:	0f be 02             	movsbl (%edx),%eax
  800494:	85 c0                	test   %eax,%eax
  800496:	0f 85 99 00 00 00    	jne    800535 <vprintfmt+0x268>
  80049c:	e9 86 00 00 00       	jmp    800527 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004a8:	89 0c 24             	mov    %ecx,(%esp)
  8004ab:	e8 1b 03 00 00       	call   8007cb <strnlen>
  8004b0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	7e d2                	jle    80048e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004bc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8004c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004c3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004c6:	89 d3                	mov    %edx,%ebx
  8004c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cf:	89 04 24             	mov    %eax,(%esp)
  8004d2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 eb 01             	sub    $0x1,%ebx
  8004d7:	85 db                	test   %ebx,%ebx
  8004d9:	7f ed                	jg     8004c8 <vprintfmt+0x1fb>
  8004db:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004e5:	eb a7                	jmp    80048e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004eb:	74 18                	je     800505 <vprintfmt+0x238>
  8004ed:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f0:	83 fa 5e             	cmp    $0x5e,%edx
  8004f3:	76 10                	jbe    800505 <vprintfmt+0x238>
					putch('?', putdat);
  8004f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800500:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800503:	eb 0a                	jmp    80050f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800505:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800513:	0f be 03             	movsbl (%ebx),%eax
  800516:	85 c0                	test   %eax,%eax
  800518:	74 05                	je     80051f <vprintfmt+0x252>
  80051a:	83 c3 01             	add    $0x1,%ebx
  80051d:	eb 29                	jmp    800548 <vprintfmt+0x27b>
  80051f:	89 fe                	mov    %edi,%esi
  800521:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800524:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	7f 2e                	jg     80055b <vprintfmt+0x28e>
  80052d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800530:	e9 c4 fd ff ff       	jmp    8002f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800535:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800538:	83 c2 01             	add    $0x1,%edx
  80053b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80053e:	89 f7                	mov    %esi,%edi
  800540:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800543:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800546:	89 d3                	mov    %edx,%ebx
  800548:	85 f6                	test   %esi,%esi
  80054a:	78 9b                	js     8004e7 <vprintfmt+0x21a>
  80054c:	83 ee 01             	sub    $0x1,%esi
  80054f:	79 96                	jns    8004e7 <vprintfmt+0x21a>
  800551:	89 fe                	mov    %edi,%esi
  800553:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800556:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800559:	eb cc                	jmp    800527 <vprintfmt+0x25a>
  80055b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80055e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056e:	83 eb 01             	sub    $0x1,%ebx
  800571:	85 db                	test   %ebx,%ebx
  800573:	7f ec                	jg     800561 <vprintfmt+0x294>
  800575:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800578:	e9 7c fd ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 16                	jle    80059b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 08             	lea    0x8(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	8b 48 04             	mov    0x4(%eax),%ecx
  800593:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800596:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800599:	eb 32                	jmp    8005cd <vprintfmt+0x300>
	else if (lflag)
  80059b:	85 c9                	test   %ecx,%ecx
  80059d:	74 18                	je     8005b7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ad:	89 c1                	mov    %eax,%ecx
  8005af:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005b5:	eb 16                	jmp    8005cd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 04             	lea    0x4(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c5:	89 c2                	mov    %eax,%edx
  8005c7:	c1 fa 1f             	sar    $0x1f,%edx
  8005ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005dc:	0f 89 b8 00 00 00    	jns    80069a <vprintfmt+0x3cd>
				putch('-', putdat);
  8005e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ed:	ff d7                	call   *%edi
				num = -(long long) num;
  8005ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005f5:	f7 d9                	neg    %ecx
  8005f7:	83 d3 00             	adc    $0x0,%ebx
  8005fa:	f7 db                	neg    %ebx
  8005fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800601:	e9 94 00 00 00       	jmp    80069a <vprintfmt+0x3cd>
  800606:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 63 fc ff ff       	call   800276 <getuint>
  800613:	89 c1                	mov    %eax,%ecx
  800615:	89 d3                	mov    %edx,%ebx
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80061c:	eb 7c                	jmp    80069a <vprintfmt+0x3cd>
  80061e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800621:	89 74 24 04          	mov    %esi,0x4(%esp)
  800625:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80062c:	ff d7                	call   *%edi
			putch('X', putdat);
  80062e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800632:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800639:	ff d7                	call   *%edi
			putch('X', putdat);
  80063b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800646:	ff d7                	call   *%edi
  800648:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80064b:	e9 a9 fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  800650:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800653:	89 74 24 04          	mov    %esi,0x4(%esp)
  800657:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80065e:	ff d7                	call   *%edi
			putch('x', putdat);
  800660:	89 74 24 04          	mov    %esi,0x4(%esp)
  800664:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 08                	mov    (%eax),%ecx
  800678:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800682:	eb 16                	jmp    80069a <vprintfmt+0x3cd>
  800684:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800687:	89 ca                	mov    %ecx,%edx
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
  80068c:	e8 e5 fb ff ff       	call   800276 <getuint>
  800691:	89 c1                	mov    %eax,%ecx
  800693:	89 d3                	mov    %edx,%ebx
  800695:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80069e:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ad:	89 0c 24             	mov    %ecx,(%esp)
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	89 f2                	mov    %esi,%edx
  8006b6:	89 f8                	mov    %edi,%eax
  8006b8:	e8 c3 fa ff ff       	call   800180 <printnum>
  8006bd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006c0:	e9 34 fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  8006c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006cf:	89 14 24             	mov    %edx,(%esp)
  8006d2:	ff d7                	call   *%edi
  8006d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006d7:	e9 1d fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006ec:	80 38 25             	cmpb   $0x25,(%eax)
  8006ef:	0f 84 04 fc ff ff    	je     8002f9 <vprintfmt+0x2c>
  8006f5:	89 c3                	mov    %eax,%ebx
  8006f7:	eb f0                	jmp    8006e9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  8006f9:	83 c4 5c             	add    $0x5c,%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 28             	sub    $0x28,%esp
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 04                	je     800715 <vsnprintf+0x14>
  800711:	85 d2                	test   %edx,%edx
  800713:	7f 07                	jg     80071c <vsnprintf+0x1b>
  800715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071a:	eb 3b                	jmp    800757 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800723:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	8b 45 10             	mov    0x10(%ebp),%eax
  800737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800742:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  800749:	e8 7f fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 82 ff ff ff       	call   800701 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078e:	8b 45 10             	mov    0x10(%ebp),%eax
  800791:	89 44 24 08          	mov    %eax,0x8(%esp)
  800795:	8b 45 0c             	mov    0xc(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	e8 26 fb ff ff       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    
  8007a9:	00 00                	add    %al,(%eax)
  8007ab:	00 00                	add    %al,(%eax)
  8007ad:	00 00                	add    %al,(%eax)
	...

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007be:	74 09                	je     8007c9 <strlen+0x19>
		n++;
  8007c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c7:	75 f7                	jne    8007c0 <strlen+0x10>
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d5:	85 c9                	test   %ecx,%ecx
  8007d7:	74 19                	je     8007f2 <strnlen+0x27>
  8007d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007dc:	74 14                	je     8007f2 <strnlen+0x27>
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e6:	39 c8                	cmp    %ecx,%eax
  8007e8:	74 0d                	je     8007f7 <strnlen+0x2c>
  8007ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007ee:	75 f3                	jne    8007e3 <strnlen+0x18>
  8007f0:	eb 05                	jmp    8007f7 <strnlen+0x2c>
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800804:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800809:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	84 c9                	test   %cl,%cl
  800815:	75 f2                	jne    800809 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800824:	89 1c 24             	mov    %ebx,(%esp)
  800827:	e8 84 ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800833:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 bc ff ff ff       	call   8007fa <strcpy>
	return dst;
}
  80083e:	89 d8                	mov    %ebx,%eax
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	85 f6                	test   %esi,%esi
  800856:	74 18                	je     800870 <strncpy+0x2a>
  800858:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80085d:	0f b6 1a             	movzbl (%edx),%ebx
  800860:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800863:	80 3a 01             	cmpb   $0x1,(%edx)
  800866:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	39 ce                	cmp    %ecx,%esi
  80086e:	77 ed                	ja     80085d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800882:	89 f0                	mov    %esi,%eax
  800884:	85 c9                	test   %ecx,%ecx
  800886:	74 27                	je     8008af <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800888:	83 e9 01             	sub    $0x1,%ecx
  80088b:	74 1d                	je     8008aa <strlcpy+0x36>
  80088d:	0f b6 1a             	movzbl (%edx),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	74 16                	je     8008aa <strlcpy+0x36>
			*dst++ = *src++;
  800894:	88 18                	mov    %bl,(%eax)
  800896:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800899:	83 e9 01             	sub    $0x1,%ecx
  80089c:	74 0e                	je     8008ac <strlcpy+0x38>
			*dst++ = *src++;
  80089e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a1:	0f b6 1a             	movzbl (%edx),%ebx
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	75 ec                	jne    800894 <strlcpy+0x20>
  8008a8:	eb 02                	jmp    8008ac <strlcpy+0x38>
  8008aa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ac:	c6 00 00             	movb   $0x0,(%eax)
  8008af:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 15                	je     8008da <strcmp+0x25>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	75 11                	jne    8008da <strcmp+0x25>
		p++, q++;
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 04                	je     8008da <strcmp+0x25>
  8008d6:	3a 02                	cmp    (%edx),%al
  8008d8:	74 ef                	je     8008c9 <strcmp+0x14>
  8008da:	0f b6 c0             	movzbl %al,%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	74 23                	je     800918 <strncmp+0x34>
  8008f5:	0f b6 1a             	movzbl (%edx),%ebx
  8008f8:	84 db                	test   %bl,%bl
  8008fa:	74 25                	je     800921 <strncmp+0x3d>
  8008fc:	3a 19                	cmp    (%ecx),%bl
  8008fe:	75 21                	jne    800921 <strncmp+0x3d>
  800900:	83 e8 01             	sub    $0x1,%eax
  800903:	74 13                	je     800918 <strncmp+0x34>
		n--, p++, q++;
  800905:	83 c2 01             	add    $0x1,%edx
  800908:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090b:	0f b6 1a             	movzbl (%edx),%ebx
  80090e:	84 db                	test   %bl,%bl
  800910:	74 0f                	je     800921 <strncmp+0x3d>
  800912:	3a 19                	cmp    (%ecx),%bl
  800914:	74 ea                	je     800900 <strncmp+0x1c>
  800916:	eb 09                	jmp    800921 <strncmp+0x3d>
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091d:	5b                   	pop    %ebx
  80091e:	5d                   	pop    %ebp
  80091f:	90                   	nop
  800920:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800921:	0f b6 02             	movzbl (%edx),%eax
  800924:	0f b6 11             	movzbl (%ecx),%edx
  800927:	29 d0                	sub    %edx,%eax
  800929:	eb f2                	jmp    80091d <strncmp+0x39>

0080092b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800935:	0f b6 10             	movzbl (%eax),%edx
  800938:	84 d2                	test   %dl,%dl
  80093a:	74 18                	je     800954 <strchr+0x29>
		if (*s == c)
  80093c:	38 ca                	cmp    %cl,%dl
  80093e:	75 0a                	jne    80094a <strchr+0x1f>
  800940:	eb 17                	jmp    800959 <strchr+0x2e>
  800942:	38 ca                	cmp    %cl,%dl
  800944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800948:	74 0f                	je     800959 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 ee                	jne    800942 <strchr+0x17>
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 18                	je     800984 <strfind+0x29>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 0a                	jne    80097a <strfind+0x1f>
  800970:	eb 12                	jmp    800984 <strfind+0x29>
  800972:	38 ca                	cmp    %cl,%dl
  800974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800978:	74 0a                	je     800984 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 ee                	jne    800972 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 0c             	sub    $0xc,%esp
  80098c:	89 1c 24             	mov    %ebx,(%esp)
  80098f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800993:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800997:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 30                	je     8009d4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 25                	jne    8009d1 <memset+0x4b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 20                	jne    8009d1 <memset+0x4b>
		c &= 0xFF;
  8009b1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b4:	89 d3                	mov    %edx,%ebx
  8009b6:	c1 e3 08             	shl    $0x8,%ebx
  8009b9:	89 d6                	mov    %edx,%esi
  8009bb:	c1 e6 18             	shl    $0x18,%esi
  8009be:	89 d0                	mov    %edx,%eax
  8009c0:	c1 e0 10             	shl    $0x10,%eax
  8009c3:	09 f0                	or     %esi,%eax
  8009c5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009c7:	09 d8                	or     %ebx,%eax
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
  8009cc:	fc                   	cld    
  8009cd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cf:	eb 03                	jmp    8009d4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	8b 1c 24             	mov    (%esp),%ebx
  8009d9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009dd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009e1:	89 ec                	mov    %ebp,%esp
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	89 34 24             	mov    %esi,(%esp)
  8009ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009fb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009fd:	39 c6                	cmp    %eax,%esi
  8009ff:	73 35                	jae    800a36 <memmove+0x51>
  800a01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a04:	39 d0                	cmp    %edx,%eax
  800a06:	73 2e                	jae    800a36 <memmove+0x51>
		s += n;
		d += n;
  800a08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0a:	f6 c2 03             	test   $0x3,%dl
  800a0d:	75 1b                	jne    800a2a <memmove+0x45>
  800a0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a15:	75 13                	jne    800a2a <memmove+0x45>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0e                	jne    800a2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a1c:	83 ef 04             	sub    $0x4,%edi
  800a1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a22:	c1 e9 02             	shr    $0x2,%ecx
  800a25:	fd                   	std    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	eb 09                	jmp    800a33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a30:	fd                   	std    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	eb 20                	jmp    800a56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3c:	75 15                	jne    800a53 <memmove+0x6e>
  800a3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a44:	75 0d                	jne    800a53 <memmove+0x6e>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 08                	jne    800a53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
  800a4e:	fc                   	cld    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	eb 03                	jmp    800a56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a53:	fc                   	cld    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a56:	8b 34 24             	mov    (%esp),%esi
  800a59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a5d:	89 ec                	mov    %ebp,%esp
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	89 04 24             	mov    %eax,(%esp)
  800a7b:	e8 65 ff ff ff       	call   8009e5 <memmove>
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 36                	je     800acb <memcmp+0x49>
		if (*s1 != *s2)
  800a95:	0f b6 06             	movzbl (%esi),%eax
  800a98:	0f b6 1f             	movzbl (%edi),%ebx
  800a9b:	38 d8                	cmp    %bl,%al
  800a9d:	74 20                	je     800abf <memcmp+0x3d>
  800a9f:	eb 14                	jmp    800ab5 <memcmp+0x33>
  800aa1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800aa6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	83 e9 01             	sub    $0x1,%ecx
  800ab1:	38 d8                	cmp    %bl,%al
  800ab3:	74 12                	je     800ac7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 db             	movzbl %bl,%ebx
  800abb:	29 d8                	sub    %ebx,%eax
  800abd:	eb 11                	jmp    800ad0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	83 e9 01             	sub    $0x1,%ecx
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	85 c9                	test   %ecx,%ecx
  800ac9:	75 d6                	jne    800aa1 <memcmp+0x1f>
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800adb:	89 c2                	mov    %eax,%edx
  800add:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae0:	39 d0                	cmp    %edx,%eax
  800ae2:	73 15                	jae    800af9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ae8:	38 08                	cmp    %cl,(%eax)
  800aea:	75 06                	jne    800af2 <memfind+0x1d>
  800aec:	eb 0b                	jmp    800af9 <memfind+0x24>
  800aee:	38 08                	cmp    %cl,(%eax)
  800af0:	74 07                	je     800af9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	39 c2                	cmp    %eax,%edx
  800af7:	77 f5                	ja     800aee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 04             	sub    $0x4,%esp
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 02             	movzbl (%edx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 04                	je     800b15 <strtol+0x1a>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	75 0e                	jne    800b23 <strtol+0x28>
		s++;
  800b15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	0f b6 02             	movzbl (%edx),%eax
  800b1b:	3c 20                	cmp    $0x20,%al
  800b1d:	74 f6                	je     800b15 <strtol+0x1a>
  800b1f:	3c 09                	cmp    $0x9,%al
  800b21:	74 f2                	je     800b15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b23:	3c 2b                	cmp    $0x2b,%al
  800b25:	75 0c                	jne    800b33 <strtol+0x38>
		s++;
  800b27:	83 c2 01             	add    $0x1,%edx
  800b2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b31:	eb 15                	jmp    800b48 <strtol+0x4d>
	else if (*s == '-')
  800b33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 0a                	jne    800b48 <strtol+0x4d>
		s++, neg = 1;
  800b3e:	83 c2 01             	add    $0x1,%edx
  800b41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	0f 94 c0             	sete   %al
  800b4d:	74 05                	je     800b54 <strtol+0x59>
  800b4f:	83 fb 10             	cmp    $0x10,%ebx
  800b52:	75 18                	jne    800b6c <strtol+0x71>
  800b54:	80 3a 30             	cmpb   $0x30,(%edx)
  800b57:	75 13                	jne    800b6c <strtol+0x71>
  800b59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5d:	8d 76 00             	lea    0x0(%esi),%esi
  800b60:	75 0a                	jne    800b6c <strtol+0x71>
		s += 2, base = 16;
  800b62:	83 c2 02             	add    $0x2,%edx
  800b65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6a:	eb 15                	jmp    800b81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	84 c0                	test   %al,%al
  800b6e:	66 90                	xchg   %ax,%ax
  800b70:	74 0f                	je     800b81 <strtol+0x86>
  800b72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b77:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7a:	75 05                	jne    800b81 <strtol+0x86>
		s++, base = 8;
  800b7c:	83 c2 01             	add    $0x1,%edx
  800b7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b88:	0f b6 0a             	movzbl (%edx),%ecx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b90:	80 fb 09             	cmp    $0x9,%bl
  800b93:	77 08                	ja     800b9d <strtol+0xa2>
			dig = *s - '0';
  800b95:	0f be c9             	movsbl %cl,%ecx
  800b98:	83 e9 30             	sub    $0x30,%ecx
  800b9b:	eb 1e                	jmp    800bbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ba0:	80 fb 19             	cmp    $0x19,%bl
  800ba3:	77 08                	ja     800bad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ba5:	0f be c9             	movsbl %cl,%ecx
  800ba8:	83 e9 57             	sub    $0x57,%ecx
  800bab:	eb 0e                	jmp    800bbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 15                	ja     800bca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bbb:	39 f1                	cmp    %esi,%ecx
  800bbd:	7d 0b                	jge    800bca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bbf:	83 c2 01             	add    $0x1,%edx
  800bc2:	0f af c6             	imul   %esi,%eax
  800bc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bc8:	eb be                	jmp    800b88 <strtol+0x8d>
  800bca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd0:	74 05                	je     800bd7 <strtol+0xdc>
		*endptr = (char *) s;
  800bd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bdb:	74 04                	je     800be1 <strtol+0xe6>
  800bdd:	89 c8                	mov    %ecx,%eax
  800bdf:	f7 d8                	neg    %eax
}
  800be1:	83 c4 04             	add    $0x4,%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
  800be9:	00 00                	add    %al,(%eax)
	...

00800bec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	89 1c 24             	mov    %ebx,(%esp)
  800bf5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800c03:	89 d1                	mov    %edx,%ecx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	51                   	push   %ecx
  800c0a:	52                   	push   %edx
  800c0b:	53                   	push   %ebx
  800c0c:	54                   	push   %esp
  800c0d:	55                   	push   %ebp
  800c0e:	56                   	push   %esi
  800c0f:	57                   	push   %edi
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	8d 35 1a 0c 80 00    	lea    0x800c1a,%esi
  800c18:	0f 34                	sysenter 
  800c1a:	5f                   	pop    %edi
  800c1b:	5e                   	pop    %esi
  800c1c:	5d                   	pop    %ebp
  800c1d:	5c                   	pop    %esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5a                   	pop    %edx
  800c20:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	8b 1c 24             	mov    (%esp),%ebx
  800c24:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c28:	89 ec                	mov    %ebp,%esp
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
  800c32:	89 1c 24             	mov    %ebx,(%esp)
  800c35:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 c3                	mov    %eax,%ebx
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	51                   	push   %ecx
  800c49:	52                   	push   %edx
  800c4a:	53                   	push   %ebx
  800c4b:	54                   	push   %esp
  800c4c:	55                   	push   %ebp
  800c4d:	56                   	push   %esi
  800c4e:	57                   	push   %edi
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	8d 35 59 0c 80 00    	lea    0x800c59,%esi
  800c57:	0f 34                	sysenter 
  800c59:	5f                   	pop    %edi
  800c5a:	5e                   	pop    %esi
  800c5b:	5d                   	pop    %ebp
  800c5c:	5c                   	pop    %esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5a                   	pop    %edx
  800c5f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c60:	8b 1c 24             	mov    (%esp),%ebx
  800c63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c67:	89 ec                	mov    %ebp,%esp
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
  800c71:	89 1c 24             	mov    %ebx,(%esp)
  800c74:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 cb                	mov    %ecx,%ebx
  800c87:	89 cf                	mov    %ecx,%edi
  800c89:	51                   	push   %ecx
  800c8a:	52                   	push   %edx
  800c8b:	53                   	push   %ebx
  800c8c:	54                   	push   %esp
  800c8d:	55                   	push   %ebp
  800c8e:	56                   	push   %esi
  800c8f:	57                   	push   %edi
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	8d 35 9a 0c 80 00    	lea    0x800c9a,%esi
  800c98:	0f 34                	sysenter 
  800c9a:	5f                   	pop    %edi
  800c9b:	5e                   	pop    %esi
  800c9c:	5d                   	pop    %ebp
  800c9d:	5c                   	pop    %esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5a                   	pop    %edx
  800ca0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ca1:	8b 1c 24             	mov    (%esp),%ebx
  800ca4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ca8:	89 ec                	mov    %ebp,%esp
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 28             	sub    $0x28,%esp
  800cb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cb5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 cb                	mov    %ecx,%ebx
  800cc7:	89 cf                	mov    %ecx,%edi
  800cc9:	51                   	push   %ecx
  800cca:	52                   	push   %edx
  800ccb:	53                   	push   %ebx
  800ccc:	54                   	push   %esp
  800ccd:	55                   	push   %ebp
  800cce:	56                   	push   %esi
  800ccf:	57                   	push   %edi
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	8d 35 da 0c 80 00    	lea    0x800cda,%esi
  800cd8:	0f 34                	sysenter 
  800cda:	5f                   	pop    %edi
  800cdb:	5e                   	pop    %esi
  800cdc:	5d                   	pop    %ebp
  800cdd:	5c                   	pop    %esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5a                   	pop    %edx
  800ce0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800d08:	e8 97 03 00 00       	call   8010a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d13:	89 ec                	mov    %ebp,%esp
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 08             	sub    $0x8,%esp
  800d1d:	89 1c 24             	mov    %ebx,(%esp)
  800d20:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	51                   	push   %ecx
  800d36:	52                   	push   %edx
  800d37:	53                   	push   %ebx
  800d38:	54                   	push   %esp
  800d39:	55                   	push   %ebp
  800d3a:	56                   	push   %esi
  800d3b:	57                   	push   %edi
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8d 35 46 0d 80 00    	lea    0x800d46,%esi
  800d44:	0f 34                	sysenter 
  800d46:	5f                   	pop    %edi
  800d47:	5e                   	pop    %esi
  800d48:	5d                   	pop    %ebp
  800d49:	5c                   	pop    %esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5a                   	pop    %edx
  800d4c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4d:	8b 1c 24             	mov    (%esp),%ebx
  800d50:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d54:	89 ec                	mov    %ebp,%esp
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 28             	sub    $0x28,%esp
  800d5e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d61:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	51                   	push   %ecx
  800d77:	52                   	push   %edx
  800d78:	53                   	push   %ebx
  800d79:	54                   	push   %esp
  800d7a:	55                   	push   %ebp
  800d7b:	56                   	push   %esi
  800d7c:	57                   	push   %edi
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	8d 35 87 0d 80 00    	lea    0x800d87,%esi
  800d85:	0f 34                	sysenter 
  800d87:	5f                   	pop    %edi
  800d88:	5e                   	pop    %esi
  800d89:	5d                   	pop    %ebp
  800d8a:	5c                   	pop    %esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5a                   	pop    %edx
  800d8d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 28                	jle    800dba <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d96:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800da5:	00 
  800da6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800dad:	00 
  800dae:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800db5:	e8 ea 02 00 00       	call   8010a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800dbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc0:	89 ec                	mov    %ebp,%esp
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 28             	sub    $0x28,%esp
  800dca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800dcd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	89 df                	mov    %ebx,%edi
  800de2:	51                   	push   %ecx
  800de3:	52                   	push   %edx
  800de4:	53                   	push   %ebx
  800de5:	54                   	push   %esp
  800de6:	55                   	push   %ebp
  800de7:	56                   	push   %esi
  800de8:	57                   	push   %edi
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	8d 35 f3 0d 80 00    	lea    0x800df3,%esi
  800df1:	0f 34                	sysenter 
  800df3:	5f                   	pop    %edi
  800df4:	5e                   	pop    %esi
  800df5:	5d                   	pop    %ebp
  800df6:	5c                   	pop    %esp
  800df7:	5b                   	pop    %ebx
  800df8:	5a                   	pop    %edx
  800df9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e21:	e8 7e 02 00 00       	call   8010a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e26:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2c:	89 ec                	mov    %ebp,%esp
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 28             	sub    $0x28,%esp
  800e36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e39:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 07 00 00 00       	mov    $0x7,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	51                   	push   %ecx
  800e4f:	52                   	push   %edx
  800e50:	53                   	push   %ebx
  800e51:	54                   	push   %esp
  800e52:	55                   	push   %ebp
  800e53:	56                   	push   %esi
  800e54:	57                   	push   %edi
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	8d 35 5f 0e 80 00    	lea    0x800e5f,%esi
  800e5d:	0f 34                	sysenter 
  800e5f:	5f                   	pop    %edi
  800e60:	5e                   	pop    %esi
  800e61:	5d                   	pop    %ebp
  800e62:	5c                   	pop    %esp
  800e63:	5b                   	pop    %ebx
  800e64:	5a                   	pop    %edx
  800e65:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e8d:	e8 12 02 00 00       	call   8010a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e92:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 28             	sub    $0x28,%esp
  800ea2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ea5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ead:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	51                   	push   %ecx
  800eba:	52                   	push   %edx
  800ebb:	53                   	push   %ebx
  800ebc:	54                   	push   %esp
  800ebd:	55                   	push   %ebp
  800ebe:	56                   	push   %esi
  800ebf:	57                   	push   %edi
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	8d 35 ca 0e 80 00    	lea    0x800eca,%esi
  800ec8:	0f 34                	sysenter 
  800eca:	5f                   	pop    %edi
  800ecb:	5e                   	pop    %esi
  800ecc:	5d                   	pop    %ebp
  800ecd:	5c                   	pop    %esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5a                   	pop    %edx
  800ed0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	7e 28                	jle    800efd <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800ef8:	e8 a7 01 00 00       	call   8010a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f03:	89 ec                	mov    %ebp,%esp
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 28             	sub    $0x28,%esp
  800f0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f10:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f13:	bf 00 00 00 00       	mov    $0x0,%edi
  800f18:	b8 05 00 00 00       	mov    $0x5,%eax
  800f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	51                   	push   %ecx
  800f27:	52                   	push   %edx
  800f28:	53                   	push   %ebx
  800f29:	54                   	push   %esp
  800f2a:	55                   	push   %ebp
  800f2b:	56                   	push   %esi
  800f2c:	57                   	push   %edi
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	8d 35 37 0f 80 00    	lea    0x800f37,%esi
  800f35:	0f 34                	sysenter 
  800f37:	5f                   	pop    %edi
  800f38:	5e                   	pop    %esi
  800f39:	5d                   	pop    %ebp
  800f3a:	5c                   	pop    %esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5a                   	pop    %edx
  800f3d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	7e 28                	jle    800f6a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f46:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800f65:	e8 3a 01 00 00       	call   8010a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f6a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f70:	89 ec                	mov    %ebp,%esp
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 08             	sub    $0x8,%esp
  800f7a:	89 1c 24             	mov    %ebx,(%esp)
  800f7d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f81:	ba 00 00 00 00       	mov    $0x0,%edx
  800f86:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f8b:	89 d1                	mov    %edx,%ecx
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	89 d7                	mov    %edx,%edi
  800f91:	51                   	push   %ecx
  800f92:	52                   	push   %edx
  800f93:	53                   	push   %ebx
  800f94:	54                   	push   %esp
  800f95:	55                   	push   %ebp
  800f96:	56                   	push   %esi
  800f97:	57                   	push   %edi
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	8d 35 a2 0f 80 00    	lea    0x800fa2,%esi
  800fa0:	0f 34                	sysenter 
  800fa2:	5f                   	pop    %edi
  800fa3:	5e                   	pop    %esi
  800fa4:	5d                   	pop    %ebp
  800fa5:	5c                   	pop    %esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5a                   	pop    %edx
  800fa8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fa9:	8b 1c 24             	mov    (%esp),%ebx
  800fac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb0:	89 ec                	mov    %ebp,%esp
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 08             	sub    $0x8,%esp
  800fba:	89 1c 24             	mov    %ebx,(%esp)
  800fbd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800fcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fce:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd1:	89 df                	mov    %ebx,%edi
  800fd3:	51                   	push   %ecx
  800fd4:	52                   	push   %edx
  800fd5:	53                   	push   %ebx
  800fd6:	54                   	push   %esp
  800fd7:	55                   	push   %ebp
  800fd8:	56                   	push   %esi
  800fd9:	57                   	push   %edi
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	8d 35 e4 0f 80 00    	lea    0x800fe4,%esi
  800fe2:	0f 34                	sysenter 
  800fe4:	5f                   	pop    %edi
  800fe5:	5e                   	pop    %esi
  800fe6:	5d                   	pop    %ebp
  800fe7:	5c                   	pop    %esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5a                   	pop    %edx
  800fea:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800feb:	8b 1c 24             	mov    (%esp),%ebx
  800fee:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff2:	89 ec                	mov    %ebp,%esp
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	89 1c 24             	mov    %ebx,(%esp)
  800fff:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801003:	ba 00 00 00 00       	mov    $0x0,%edx
  801008:	b8 02 00 00 00       	mov    $0x2,%eax
  80100d:	89 d1                	mov    %edx,%ecx
  80100f:	89 d3                	mov    %edx,%ebx
  801011:	89 d7                	mov    %edx,%edi
  801013:	51                   	push   %ecx
  801014:	52                   	push   %edx
  801015:	53                   	push   %ebx
  801016:	54                   	push   %esp
  801017:	55                   	push   %ebp
  801018:	56                   	push   %esi
  801019:	57                   	push   %edi
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	8d 35 24 10 80 00    	lea    0x801024,%esi
  801022:	0f 34                	sysenter 
  801024:	5f                   	pop    %edi
  801025:	5e                   	pop    %esi
  801026:	5d                   	pop    %ebp
  801027:	5c                   	pop    %esp
  801028:	5b                   	pop    %ebx
  801029:	5a                   	pop    %edx
  80102a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102b:	8b 1c 24             	mov    (%esp),%ebx
  80102e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801032:	89 ec                	mov    %ebp,%esp
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 28             	sub    $0x28,%esp
  80103c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80103f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801042:	b9 00 00 00 00       	mov    $0x0,%ecx
  801047:	b8 03 00 00 00       	mov    $0x3,%eax
  80104c:	8b 55 08             	mov    0x8(%ebp),%edx
  80104f:	89 cb                	mov    %ecx,%ebx
  801051:	89 cf                	mov    %ecx,%edi
  801053:	51                   	push   %ecx
  801054:	52                   	push   %edx
  801055:	53                   	push   %ebx
  801056:	54                   	push   %esp
  801057:	55                   	push   %ebp
  801058:	56                   	push   %esi
  801059:	57                   	push   %edi
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	8d 35 64 10 80 00    	lea    0x801064,%esi
  801062:	0f 34                	sysenter 
  801064:	5f                   	pop    %edi
  801065:	5e                   	pop    %esi
  801066:	5d                   	pop    %ebp
  801067:	5c                   	pop    %esp
  801068:	5b                   	pop    %ebx
  801069:	5a                   	pop    %edx
  80106a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80106b:	85 c0                	test   %eax,%eax
  80106d:	7e 28                	jle    801097 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801073:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80107a:	00 
  80107b:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  801082:	00 
  801083:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80108a:	00 
  80108b:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  801092:	e8 0d 00 00 00       	call   8010a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801097:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80109a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80109d:	89 ec                	mov    %ebp,%esp
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    
  8010a1:	00 00                	add    %al,(%eax)
	...

008010a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8010ac:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8010af:	a1 08 20 80 00       	mov    0x802008,%eax
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 10                	je     8010c8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8010b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bc:	c7 04 24 2f 16 80 00 	movl   $0x80162f,(%esp)
  8010c3:	e8 51 f0 ff ff       	call   800119 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010c8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8010ce:	e8 23 ff ff ff       	call   800ff6 <sys_getenvid>
  8010d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010da:	8b 55 08             	mov    0x8(%ebp),%edx
  8010dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8010f0:	e8 24 f0 ff ff       	call   800119 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010fc:	89 04 24             	mov    %eax,(%esp)
  8010ff:	e8 b4 ef ff ff       	call   8000b8 <vcprintf>
	cprintf("\n");
  801104:	c7 04 24 bc 13 80 00 	movl   $0x8013bc,(%esp)
  80110b:	e8 09 f0 ff ff       	call   800119 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801110:	cc                   	int3   
  801111:	eb fd                	jmp    801110 <_panic+0x6c>
	...

00801120 <__udivdi3>:
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	83 ec 10             	sub    $0x10,%esp
  801128:	8b 45 14             	mov    0x14(%ebp),%eax
  80112b:	8b 55 08             	mov    0x8(%ebp),%edx
  80112e:	8b 75 10             	mov    0x10(%ebp),%esi
  801131:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801134:	85 c0                	test   %eax,%eax
  801136:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801139:	75 35                	jne    801170 <__udivdi3+0x50>
  80113b:	39 fe                	cmp    %edi,%esi
  80113d:	77 61                	ja     8011a0 <__udivdi3+0x80>
  80113f:	85 f6                	test   %esi,%esi
  801141:	75 0b                	jne    80114e <__udivdi3+0x2e>
  801143:	b8 01 00 00 00       	mov    $0x1,%eax
  801148:	31 d2                	xor    %edx,%edx
  80114a:	f7 f6                	div    %esi
  80114c:	89 c6                	mov    %eax,%esi
  80114e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801151:	31 d2                	xor    %edx,%edx
  801153:	89 f8                	mov    %edi,%eax
  801155:	f7 f6                	div    %esi
  801157:	89 c7                	mov    %eax,%edi
  801159:	89 c8                	mov    %ecx,%eax
  80115b:	f7 f6                	div    %esi
  80115d:	89 c1                	mov    %eax,%ecx
  80115f:	89 fa                	mov    %edi,%edx
  801161:	89 c8                	mov    %ecx,%eax
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    
  80116a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801170:	39 f8                	cmp    %edi,%eax
  801172:	77 1c                	ja     801190 <__udivdi3+0x70>
  801174:	0f bd d0             	bsr    %eax,%edx
  801177:	83 f2 1f             	xor    $0x1f,%edx
  80117a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80117d:	75 39                	jne    8011b8 <__udivdi3+0x98>
  80117f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801182:	0f 86 a0 00 00 00    	jbe    801228 <__udivdi3+0x108>
  801188:	39 f8                	cmp    %edi,%eax
  80118a:	0f 82 98 00 00 00    	jb     801228 <__udivdi3+0x108>
  801190:	31 ff                	xor    %edi,%edi
  801192:	31 c9                	xor    %ecx,%ecx
  801194:	89 c8                	mov    %ecx,%eax
  801196:	89 fa                	mov    %edi,%edx
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	5e                   	pop    %esi
  80119c:	5f                   	pop    %edi
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    
  80119f:	90                   	nop
  8011a0:	89 d1                	mov    %edx,%ecx
  8011a2:	89 fa                	mov    %edi,%edx
  8011a4:	89 c8                	mov    %ecx,%eax
  8011a6:	31 ff                	xor    %edi,%edi
  8011a8:	f7 f6                	div    %esi
  8011aa:	89 c1                	mov    %eax,%ecx
  8011ac:	89 fa                	mov    %edi,%edx
  8011ae:	89 c8                	mov    %ecx,%eax
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    
  8011b7:	90                   	nop
  8011b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011bc:	89 f2                	mov    %esi,%edx
  8011be:	d3 e0                	shl    %cl,%eax
  8011c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011cb:	89 c1                	mov    %eax,%ecx
  8011cd:	d3 ea                	shr    %cl,%edx
  8011cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011d6:	d3 e6                	shl    %cl,%esi
  8011d8:	89 c1                	mov    %eax,%ecx
  8011da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011dd:	89 fe                	mov    %edi,%esi
  8011df:	d3 ee                	shr    %cl,%esi
  8011e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011eb:	d3 e7                	shl    %cl,%edi
  8011ed:	89 c1                	mov    %eax,%ecx
  8011ef:	d3 ea                	shr    %cl,%edx
  8011f1:	09 d7                	or     %edx,%edi
  8011f3:	89 f2                	mov    %esi,%edx
  8011f5:	89 f8                	mov    %edi,%eax
  8011f7:	f7 75 ec             	divl   -0x14(%ebp)
  8011fa:	89 d6                	mov    %edx,%esi
  8011fc:	89 c7                	mov    %eax,%edi
  8011fe:	f7 65 e8             	mull   -0x18(%ebp)
  801201:	39 d6                	cmp    %edx,%esi
  801203:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801206:	72 30                	jb     801238 <__udivdi3+0x118>
  801208:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80120b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80120f:	d3 e2                	shl    %cl,%edx
  801211:	39 c2                	cmp    %eax,%edx
  801213:	73 05                	jae    80121a <__udivdi3+0xfa>
  801215:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801218:	74 1e                	je     801238 <__udivdi3+0x118>
  80121a:	89 f9                	mov    %edi,%ecx
  80121c:	31 ff                	xor    %edi,%edi
  80121e:	e9 71 ff ff ff       	jmp    801194 <__udivdi3+0x74>
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	31 ff                	xor    %edi,%edi
  80122a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80122f:	e9 60 ff ff ff       	jmp    801194 <__udivdi3+0x74>
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80123b:	31 ff                	xor    %edi,%edi
  80123d:	89 c8                	mov    %ecx,%eax
  80123f:	89 fa                	mov    %edi,%edx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    
	...

00801250 <__umoddi3>:
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	83 ec 20             	sub    $0x20,%esp
  801258:	8b 55 14             	mov    0x14(%ebp),%edx
  80125b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801261:	8b 75 0c             	mov    0xc(%ebp),%esi
  801264:	85 d2                	test   %edx,%edx
  801266:	89 c8                	mov    %ecx,%eax
  801268:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80126b:	75 13                	jne    801280 <__umoddi3+0x30>
  80126d:	39 f7                	cmp    %esi,%edi
  80126f:	76 3f                	jbe    8012b0 <__umoddi3+0x60>
  801271:	89 f2                	mov    %esi,%edx
  801273:	f7 f7                	div    %edi
  801275:	89 d0                	mov    %edx,%eax
  801277:	31 d2                	xor    %edx,%edx
  801279:	83 c4 20             	add    $0x20,%esp
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    
  801280:	39 f2                	cmp    %esi,%edx
  801282:	77 4c                	ja     8012d0 <__umoddi3+0x80>
  801284:	0f bd ca             	bsr    %edx,%ecx
  801287:	83 f1 1f             	xor    $0x1f,%ecx
  80128a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80128d:	75 51                	jne    8012e0 <__umoddi3+0x90>
  80128f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801292:	0f 87 e0 00 00 00    	ja     801378 <__umoddi3+0x128>
  801298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129b:	29 f8                	sub    %edi,%eax
  80129d:	19 d6                	sbb    %edx,%esi
  80129f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a5:	89 f2                	mov    %esi,%edx
  8012a7:	83 c4 20             	add    $0x20,%esp
  8012aa:	5e                   	pop    %esi
  8012ab:	5f                   	pop    %edi
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    
  8012ae:	66 90                	xchg   %ax,%ax
  8012b0:	85 ff                	test   %edi,%edi
  8012b2:	75 0b                	jne    8012bf <__umoddi3+0x6f>
  8012b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b9:	31 d2                	xor    %edx,%edx
  8012bb:	f7 f7                	div    %edi
  8012bd:	89 c7                	mov    %eax,%edi
  8012bf:	89 f0                	mov    %esi,%eax
  8012c1:	31 d2                	xor    %edx,%edx
  8012c3:	f7 f7                	div    %edi
  8012c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c8:	f7 f7                	div    %edi
  8012ca:	eb a9                	jmp    801275 <__umoddi3+0x25>
  8012cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	89 c8                	mov    %ecx,%eax
  8012d2:	89 f2                	mov    %esi,%edx
  8012d4:	83 c4 20             	add    $0x20,%esp
  8012d7:	5e                   	pop    %esi
  8012d8:	5f                   	pop    %edi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    
  8012db:	90                   	nop
  8012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012e4:	d3 e2                	shl    %cl,%edx
  8012e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8012ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8012f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012f8:	89 fa                	mov    %edi,%edx
  8012fa:	d3 ea                	shr    %cl,%edx
  8012fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801300:	0b 55 f4             	or     -0xc(%ebp),%edx
  801303:	d3 e7                	shl    %cl,%edi
  801305:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801309:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80130c:	89 f2                	mov    %esi,%edx
  80130e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801311:	89 c7                	mov    %eax,%edi
  801313:	d3 ea                	shr    %cl,%edx
  801315:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801319:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	d3 e6                	shl    %cl,%esi
  801320:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801324:	d3 ea                	shr    %cl,%edx
  801326:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80132a:	09 d6                	or     %edx,%esi
  80132c:	89 f0                	mov    %esi,%eax
  80132e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801331:	d3 e7                	shl    %cl,%edi
  801333:	89 f2                	mov    %esi,%edx
  801335:	f7 75 f4             	divl   -0xc(%ebp)
  801338:	89 d6                	mov    %edx,%esi
  80133a:	f7 65 e8             	mull   -0x18(%ebp)
  80133d:	39 d6                	cmp    %edx,%esi
  80133f:	72 2b                	jb     80136c <__umoddi3+0x11c>
  801341:	39 c7                	cmp    %eax,%edi
  801343:	72 23                	jb     801368 <__umoddi3+0x118>
  801345:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801349:	29 c7                	sub    %eax,%edi
  80134b:	19 d6                	sbb    %edx,%esi
  80134d:	89 f0                	mov    %esi,%eax
  80134f:	89 f2                	mov    %esi,%edx
  801351:	d3 ef                	shr    %cl,%edi
  801353:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801357:	d3 e0                	shl    %cl,%eax
  801359:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80135d:	09 f8                	or     %edi,%eax
  80135f:	d3 ea                	shr    %cl,%edx
  801361:	83 c4 20             	add    $0x20,%esp
  801364:	5e                   	pop    %esi
  801365:	5f                   	pop    %edi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    
  801368:	39 d6                	cmp    %edx,%esi
  80136a:	75 d9                	jne    801345 <__umoddi3+0xf5>
  80136c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80136f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801372:	eb d1                	jmp    801345 <__umoddi3+0xf5>
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	39 f2                	cmp    %esi,%edx
  80137a:	0f 82 18 ff ff ff    	jb     801298 <__umoddi3+0x48>
  801380:	e9 1d ff ff ff       	jmp    8012a2 <__umoddi3+0x52>
