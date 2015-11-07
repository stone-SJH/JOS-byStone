
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  80004e:	e8 32 01 00 00       	call   800185 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 de 10 00 00       	call   801136 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 b8 14 80 00 	movl   $0x8014b8,(%esp)
  800065:	e8 1b 01 00 00       	call   800185 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 68 14 80 00 	movl   $0x801468,(%esp)
  800073:	e8 0d 01 00 00       	call   800185 <cprintf>
	sys_yield();
  800078:	e8 67 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  80007d:	e8 62 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  800082:	e8 5d 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  800087:	e8 58 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 4f 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  800095:	e8 4a 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  80009a:	e8 45 0f 00 00       	call   800fe4 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 3f 0f 00 00       	call   800fe4 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 90 14 80 00 	movl   $0x801490,(%esp)
  8000ac:	e8 d4 00 00 00       	call   800185 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 ed 0f 00 00       	call   8010a6 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  8000d2:	e8 8f 0f 00 00       	call   801066 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 40 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
}
  800105:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800108:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011d:	e8 84 0f 00 00       	call   8010a6 <sys_env_destroy>
}
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	8b 45 0c             	mov    0xc(%ebp),%eax
  800144:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800148:	8b 45 08             	mov    0x8(%ebp),%eax
  80014b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	c7 04 24 9f 01 80 00 	movl   $0x80019f,(%esp)
  800160:	e8 d8 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800165:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 1f 0b 00 00       	call   800c9c <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 04 24             	mov    %eax,(%esp)
  800198:	e8 87 ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 14             	sub    $0x14,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 03                	mov    (%ebx),%eax
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b2:	83 c0 01             	add    $0x1,%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 19                	jne    8001d7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001be:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c5:	00 
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 cb 0a 00 00       	call   800c9c <sys_cputs>
		b->idx = 0;
  8001d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	83 c4 14             	add    $0x14,%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 15                	jb     800234 <printnum+0x44>
  80021f:	77 07                	ja     800228 <printnum+0x38>
  800221:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800224:	39 d0                	cmp    %edx,%eax
  800226:	76 0c                	jbe    800234 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	8d 76 00             	lea    0x0(%esi),%esi
  800230:	7f 61                	jg     800293 <printnum+0xa3>
  800232:	eb 70                	jmp    8002a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800247:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80024b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80024e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800251:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025f:	00 
  800260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800269:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026d:	e8 5e 0f 00 00       	call   8011d0 <__udivdi3>
  800272:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800275:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	89 54 24 04          	mov    %edx,0x4(%esp)
  800287:	89 f2                	mov    %esi,%edx
  800289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028c:	e8 5f ff ff ff       	call   8001f0 <printnum>
  800291:	eb 11                	jmp    8002a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	89 74 24 04          	mov    %esi,0x4(%esp)
  800297:	89 3c 24             	mov    %edi,(%esp)
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f ef                	jg     800293 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ba:	00 
  8002bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002be:	89 14 24             	mov    %edx,(%esp)
  8002c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002c8:	e8 33 10 00 00       	call   801300 <__umoddi3>
  8002cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d1:	0f be 80 e0 14 80 00 	movsbl 0x8014e0(%eax),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002de:	83 c4 4c             	add    $0x4c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	3b 50 04             	cmp    0x4(%eax),%edx
  80032f:	73 0a                	jae    80033b <sprintputch+0x1b>
		*b->buf++ = ch;
  800331:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800334:	88 0a                	mov    %cl,(%edx)
  800336:	83 c2 01             	add    $0x1,%edx
  800339:	89 10                	mov    %edx,(%eax)
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 5c             	sub    $0x5c,%esp
  800346:	8b 7d 08             	mov    0x8(%ebp),%edi
  800349:	8b 75 0c             	mov    0xc(%ebp),%esi
  80034c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80034f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800356:	eb 11                	jmp    800369 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 09 04 00 00    	je     800769 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800360:	89 74 24 04          	mov    %esi,0x4(%esp)
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	0f b6 03             	movzbl (%ebx),%eax
  80036c:	83 c3 01             	add    $0x1,%ebx
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e4                	jne    800358 <vprintfmt+0x1b>
  800374:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800378:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80037f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800386:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80038d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800392:	eb 06                	jmp    80039a <vprintfmt+0x5d>
  800394:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800398:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	0f b6 13             	movzbl (%ebx),%edx
  80039d:	0f b6 c2             	movzbl %dl,%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003a6:	83 ea 23             	sub    $0x23,%edx
  8003a9:	80 fa 55             	cmp    $0x55,%dl
  8003ac:	0f 87 9a 03 00 00    	ja     80074c <vprintfmt+0x40f>
  8003b2:	0f b6 d2             	movzbl %dl,%edx
  8003b5:	ff 24 95 a0 15 80 00 	jmp    *0x8015a0(,%edx,4)
  8003bc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c5:	83 ea 30             	sub    $0x30,%edx
  8003c8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003d1:	83 fb 09             	cmp    $0x9,%ebx
  8003d4:	77 4c                	ja     800422 <vprintfmt+0xe5>
  8003d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003df:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003e6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003e9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003ec:	83 fb 09             	cmp    $0x9,%ebx
  8003ef:	76 eb                	jbe    8003dc <vprintfmt+0x9f>
  8003f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f7:	eb 29                	jmp    800422 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800402:	8b 12                	mov    (%edx),%edx
  800404:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800407:	eb 19                	jmp    800422 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800409:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040c:	c1 fa 1f             	sar    $0x1f,%edx
  80040f:	f7 d2                	not    %edx
  800411:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800414:	eb 82                	jmp    800398 <vprintfmt+0x5b>
  800416:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80041d:	e9 76 ff ff ff       	jmp    800398 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800422:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800426:	0f 89 6c ff ff ff    	jns    800398 <vprintfmt+0x5b>
  80042c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800432:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800435:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800438:	e9 5b ff ff ff       	jmp    800398 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800440:	e9 53 ff ff ff       	jmp    800398 <vprintfmt+0x5b>
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 50 04             	lea    0x4(%eax),%edx
  80044e:	89 55 14             	mov    %edx,0x14(%ebp)
  800451:	89 74 24 04          	mov    %esi,0x4(%esp)
  800455:	8b 00                	mov    (%eax),%eax
  800457:	89 04 24             	mov    %eax,(%esp)
  80045a:	ff d7                	call   *%edi
  80045c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80045f:	e9 05 ff ff ff       	jmp    800369 <vprintfmt+0x2c>
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	89 c2                	mov    %eax,%edx
  800474:	c1 fa 1f             	sar    $0x1f,%edx
  800477:	31 d0                	xor    %edx,%eax
  800479:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047b:	83 f8 08             	cmp    $0x8,%eax
  80047e:	7f 0b                	jg     80048b <vprintfmt+0x14e>
  800480:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  800487:	85 d2                	test   %edx,%edx
  800489:	75 20                	jne    8004ab <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80048b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048f:	c7 44 24 08 f1 14 80 	movl   $0x8014f1,0x8(%esp)
  800496:	00 
  800497:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049b:	89 3c 24             	mov    %edi,(%esp)
  80049e:	e8 4e 03 00 00       	call   8007f1 <printfmt>
  8004a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a6:	e9 be fe ff ff       	jmp    800369 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004af:	c7 44 24 08 fa 14 80 	movl   $0x8014fa,0x8(%esp)
  8004b6:	00 
  8004b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004bb:	89 3c 24             	mov    %edi,(%esp)
  8004be:	e8 2e 03 00 00       	call   8007f1 <printfmt>
  8004c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c6:	e9 9e fe ff ff       	jmp    800369 <vprintfmt+0x2c>
  8004cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ce:	89 c3                	mov    %eax,%ebx
  8004d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 00                	mov    (%eax),%eax
  8004e4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	75 07                	jne    8004f2 <vprintfmt+0x1b5>
  8004eb:	c7 45 c4 fd 14 80 00 	movl   $0x8014fd,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004f2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004f6:	7e 06                	jle    8004fe <vprintfmt+0x1c1>
  8004f8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004fc:	75 13                	jne    800511 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800501:	0f be 02             	movsbl (%edx),%eax
  800504:	85 c0                	test   %eax,%eax
  800506:	0f 85 99 00 00 00    	jne    8005a5 <vprintfmt+0x268>
  80050c:	e9 86 00 00 00       	jmp    800597 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800515:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800518:	89 0c 24             	mov    %ecx,(%esp)
  80051b:	e8 1b 03 00 00       	call   80083b <strnlen>
  800520:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800523:	29 c2                	sub    %eax,%edx
  800525:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800528:	85 d2                	test   %edx,%edx
  80052a:	7e d2                	jle    8004fe <vprintfmt+0x1c1>
					putch(padc, putdat);
  80052c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800533:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800536:	89 d3                	mov    %edx,%ebx
  800538:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	83 eb 01             	sub    $0x1,%ebx
  800547:	85 db                	test   %ebx,%ebx
  800549:	7f ed                	jg     800538 <vprintfmt+0x1fb>
  80054b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80054e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800555:	eb a7                	jmp    8004fe <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800557:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80055b:	74 18                	je     800575 <vprintfmt+0x238>
  80055d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800560:	83 fa 5e             	cmp    $0x5e,%edx
  800563:	76 10                	jbe    800575 <vprintfmt+0x238>
					putch('?', putdat);
  800565:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800569:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800570:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800573:	eb 0a                	jmp    80057f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800579:	89 04 24             	mov    %eax,(%esp)
  80057c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800583:	0f be 03             	movsbl (%ebx),%eax
  800586:	85 c0                	test   %eax,%eax
  800588:	74 05                	je     80058f <vprintfmt+0x252>
  80058a:	83 c3 01             	add    $0x1,%ebx
  80058d:	eb 29                	jmp    8005b8 <vprintfmt+0x27b>
  80058f:	89 fe                	mov    %edi,%esi
  800591:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800594:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059b:	7f 2e                	jg     8005cb <vprintfmt+0x28e>
  80059d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a0:	e9 c4 fd ff ff       	jmp    800369 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005a8:	83 c2 01             	add    $0x1,%edx
  8005ab:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005ae:	89 f7                	mov    %esi,%edi
  8005b0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005b3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005b6:	89 d3                	mov    %edx,%ebx
  8005b8:	85 f6                	test   %esi,%esi
  8005ba:	78 9b                	js     800557 <vprintfmt+0x21a>
  8005bc:	83 ee 01             	sub    $0x1,%esi
  8005bf:	79 96                	jns    800557 <vprintfmt+0x21a>
  8005c1:	89 fe                	mov    %edi,%esi
  8005c3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005c6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005c9:	eb cc                	jmp    800597 <vprintfmt+0x25a>
  8005cb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 eb 01             	sub    $0x1,%ebx
  8005e1:	85 db                	test   %ebx,%ebx
  8005e3:	7f ec                	jg     8005d1 <vprintfmt+0x294>
  8005e5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e8:	e9 7c fd ff ff       	jmp    800369 <vprintfmt+0x2c>
  8005ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f0:	83 f9 01             	cmp    $0x1,%ecx
  8005f3:	7e 16                	jle    80060b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 08             	lea    0x8(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8b 48 04             	mov    0x4(%eax),%ecx
  800603:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800606:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800609:	eb 32                	jmp    80063d <vprintfmt+0x300>
	else if (lflag)
  80060b:	85 c9                	test   %ecx,%ecx
  80060d:	74 18                	je     800627 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061d:	89 c1                	mov    %eax,%ecx
  80061f:	c1 f9 1f             	sar    $0x1f,%ecx
  800622:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800625:	eb 16                	jmp    80063d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 50 04             	lea    0x4(%eax),%edx
  80062d:	89 55 14             	mov    %edx,0x14(%ebp)
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800635:	89 c2                	mov    %eax,%edx
  800637:	c1 fa 1f             	sar    $0x1f,%edx
  80063a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800640:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800643:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800648:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80064c:	0f 89 b8 00 00 00    	jns    80070a <vprintfmt+0x3cd>
				putch('-', putdat);
  800652:	89 74 24 04          	mov    %esi,0x4(%esp)
  800656:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065d:	ff d7                	call   *%edi
				num = -(long long) num;
  80065f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800662:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800665:	f7 d9                	neg    %ecx
  800667:	83 d3 00             	adc    $0x0,%ebx
  80066a:	f7 db                	neg    %ebx
  80066c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800671:	e9 94 00 00 00       	jmp    80070a <vprintfmt+0x3cd>
  800676:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 63 fc ff ff       	call   8002e6 <getuint>
  800683:	89 c1                	mov    %eax,%ecx
  800685:	89 d3                	mov    %edx,%ebx
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80068c:	eb 7c                	jmp    80070a <vprintfmt+0x3cd>
  80068e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800691:	89 74 24 04          	mov    %esi,0x4(%esp)
  800695:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069c:	ff d7                	call   *%edi
			putch('X', putdat);
  80069e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a9:	ff d7                	call   *%edi
			putch('X', putdat);
  8006ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006af:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b6:	ff d7                	call   *%edi
  8006b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006bb:	e9 a9 fc ff ff       	jmp    800369 <vprintfmt+0x2c>
  8006c0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ce:	ff d7                	call   *%edi
			putch('x', putdat);
  8006d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006db:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 08                	mov    (%eax),%ecx
  8006e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ed:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f2:	eb 16                	jmp    80070a <vprintfmt+0x3cd>
  8006f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f7:	89 ca                	mov    %ecx,%edx
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	e8 e5 fb ff ff       	call   8002e6 <getuint>
  800701:	89 c1                	mov    %eax,%ecx
  800703:	89 d3                	mov    %edx,%ebx
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80070e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800712:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800715:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071d:	89 0c 24             	mov    %ecx,(%esp)
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	89 f2                	mov    %esi,%edx
  800726:	89 f8                	mov    %edi,%eax
  800728:	e8 c3 fa ff ff       	call   8001f0 <printnum>
  80072d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800730:	e9 34 fc ff ff       	jmp    800369 <vprintfmt+0x2c>
  800735:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800738:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073f:	89 14 24             	mov    %edx,(%esp)
  800742:	ff d7                	call   *%edi
  800744:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800747:	e9 1d fc ff ff       	jmp    800369 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800750:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800757:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800759:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80075c:	80 38 25             	cmpb   $0x25,(%eax)
  80075f:	0f 84 04 fc ff ff    	je     800369 <vprintfmt+0x2c>
  800765:	89 c3                	mov    %eax,%ebx
  800767:	eb f0                	jmp    800759 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800769:	83 c4 5c             	add    $0x5c,%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 28             	sub    $0x28,%esp
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80077d:	85 c0                	test   %eax,%eax
  80077f:	74 04                	je     800785 <vsnprintf+0x14>
  800781:	85 d2                	test   %edx,%edx
  800783:	7f 07                	jg     80078c <vsnprintf+0x1b>
  800785:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078a:	eb 3b                	jmp    8007c7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800793:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800796:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b2:	c7 04 24 20 03 80 00 	movl   $0x800320,(%esp)
  8007b9:	e8 7f fb ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 82 ff ff ff       	call   800771 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800801:	89 44 24 08          	mov    %eax,0x8(%esp)
  800805:	8b 45 0c             	mov    0xc(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	89 04 24             	mov    %eax,(%esp)
  800812:	e8 26 fb ff ff       	call   80033d <vprintfmt>
	va_end(ap);
}
  800817:	c9                   	leave  
  800818:	c3                   	ret    
  800819:	00 00                	add    %al,(%eax)
  80081b:	00 00                	add    %al,(%eax)
  80081d:	00 00                	add    %al,(%eax)
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3a 00             	cmpb   $0x0,(%edx)
  80082e:	74 09                	je     800839 <strlen+0x19>
		n++;
  800830:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800837:	75 f7                	jne    800830 <strlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 19                	je     800862 <strnlen+0x27>
  800849:	80 3b 00             	cmpb   $0x0,(%ebx)
  80084c:	74 14                	je     800862 <strnlen+0x27>
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800853:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800856:	39 c8                	cmp    %ecx,%eax
  800858:	74 0d                	je     800867 <strnlen+0x2c>
  80085a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80085e:	75 f3                	jne    800853 <strnlen+0x18>
  800860:	eb 05                	jmp    800867 <strnlen+0x2c>
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800879:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	84 c9                	test   %cl,%cl
  800885:	75 f2                	jne    800879 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800894:	89 1c 24             	mov    %ebx,(%esp)
  800897:	e8 84 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 bc ff ff ff       	call   80086a <strcpy>
	return dst;
}
  8008ae:	89 d8                	mov    %ebx,%eax
  8008b0:	83 c4 08             	add    $0x8,%esp
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c4:	85 f6                	test   %esi,%esi
  8008c6:	74 18                	je     8008e0 <strncpy+0x2a>
  8008c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008cd:	0f b6 1a             	movzbl (%edx),%ebx
  8008d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	39 ce                	cmp    %ecx,%esi
  8008de:	77 ed                	ja     8008cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 27                	je     80091f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008f8:	83 e9 01             	sub    $0x1,%ecx
  8008fb:	74 1d                	je     80091a <strlcpy+0x36>
  8008fd:	0f b6 1a             	movzbl (%edx),%ebx
  800900:	84 db                	test   %bl,%bl
  800902:	74 16                	je     80091a <strlcpy+0x36>
			*dst++ = *src++;
  800904:	88 18                	mov    %bl,(%eax)
  800906:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800909:	83 e9 01             	sub    $0x1,%ecx
  80090c:	74 0e                	je     80091c <strlcpy+0x38>
			*dst++ = *src++;
  80090e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800911:	0f b6 1a             	movzbl (%edx),%ebx
  800914:	84 db                	test   %bl,%bl
  800916:	75 ec                	jne    800904 <strlcpy+0x20>
  800918:	eb 02                	jmp    80091c <strlcpy+0x38>
  80091a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80091c:	c6 00 00             	movb   $0x0,(%eax)
  80091f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092e:	0f b6 01             	movzbl (%ecx),%eax
  800931:	84 c0                	test   %al,%al
  800933:	74 15                	je     80094a <strcmp+0x25>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	75 11                	jne    80094a <strcmp+0x25>
		p++, q++;
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093f:	0f b6 01             	movzbl (%ecx),%eax
  800942:	84 c0                	test   %al,%al
  800944:	74 04                	je     80094a <strcmp+0x25>
  800946:	3a 02                	cmp    (%edx),%al
  800948:	74 ef                	je     800939 <strcmp+0x14>
  80094a:	0f b6 c0             	movzbl %al,%eax
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	53                   	push   %ebx
  800958:	8b 55 08             	mov    0x8(%ebp),%edx
  80095b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800961:	85 c0                	test   %eax,%eax
  800963:	74 23                	je     800988 <strncmp+0x34>
  800965:	0f b6 1a             	movzbl (%edx),%ebx
  800968:	84 db                	test   %bl,%bl
  80096a:	74 25                	je     800991 <strncmp+0x3d>
  80096c:	3a 19                	cmp    (%ecx),%bl
  80096e:	75 21                	jne    800991 <strncmp+0x3d>
  800970:	83 e8 01             	sub    $0x1,%eax
  800973:	74 13                	je     800988 <strncmp+0x34>
		n--, p++, q++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	84 db                	test   %bl,%bl
  800980:	74 0f                	je     800991 <strncmp+0x3d>
  800982:	3a 19                	cmp    (%ecx),%bl
  800984:	74 ea                	je     800970 <strncmp+0x1c>
  800986:	eb 09                	jmp    800991 <strncmp+0x3d>
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	90                   	nop
  800990:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 02             	movzbl (%edx),%eax
  800994:	0f b6 11             	movzbl (%ecx),%edx
  800997:	29 d0                	sub    %edx,%eax
  800999:	eb f2                	jmp    80098d <strncmp+0x39>

0080099b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 18                	je     8009c4 <strchr+0x29>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	75 0a                	jne    8009ba <strchr+0x1f>
  8009b0:	eb 17                	jmp    8009c9 <strchr+0x2e>
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009b8:	74 0f                	je     8009c9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 ee                	jne    8009b2 <strchr+0x17>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strfind+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strfind+0x1f>
  8009e0:	eb 12                	jmp    8009f4 <strfind+0x29>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0a                	je     8009f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	89 1c 24             	mov    %ebx,(%esp)
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 30                	je     800a44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 25                	jne    800a41 <memset+0x4b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 20                	jne    800a41 <memset+0x4b>
		c &= 0xFF;
  800a21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a24:	89 d3                	mov    %edx,%ebx
  800a26:	c1 e3 08             	shl    $0x8,%ebx
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 18             	shl    $0x18,%esi
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	c1 e0 10             	shl    $0x10,%eax
  800a33:	09 f0                	or     %esi,%eax
  800a35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a37:	09 d8                	or     %ebx,%eax
  800a39:	c1 e9 02             	shr    $0x2,%ecx
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	eb 03                	jmp    800a44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a44:	89 f8                	mov    %edi,%eax
  800a46:	8b 1c 24             	mov    (%esp),%ebx
  800a49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a51:	89 ec                	mov    %ebp,%esp
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	89 34 24             	mov    %esi,(%esp)
  800a5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 35                	jae    800aa6 <memmove+0x51>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 2e                	jae    800aa6 <memmove+0x51>
		s += n;
		d += n;
  800a78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	f6 c2 03             	test   $0x3,%dl
  800a7d:	75 1b                	jne    800a9a <memmove+0x45>
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 13                	jne    800a9a <memmove+0x45>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 0e                	jne    800a9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a8c:	83 ef 04             	sub    $0x4,%edi
  800a8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a92:	c1 e9 02             	shr    $0x2,%ecx
  800a95:	fd                   	std    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	eb 09                	jmp    800aa3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	eb 20                	jmp    800ac6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aac:	75 15                	jne    800ac3 <memmove+0x6e>
  800aae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab4:	75 0d                	jne    800ac3 <memmove+0x6e>
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	75 08                	jne    800ac3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	eb 03                	jmp    800ac6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	fc                   	cld    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac6:	8b 34 24             	mov    (%esp),%esi
  800ac9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800acd:	89 ec                	mov    %ebp,%esp
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 65 ff ff ff       	call   800a55 <memmove>
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 75 08             	mov    0x8(%ebp),%esi
  800afb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	85 c9                	test   %ecx,%ecx
  800b03:	74 36                	je     800b3b <memcmp+0x49>
		if (*s1 != *s2)
  800b05:	0f b6 06             	movzbl (%esi),%eax
  800b08:	0f b6 1f             	movzbl (%edi),%ebx
  800b0b:	38 d8                	cmp    %bl,%al
  800b0d:	74 20                	je     800b2f <memcmp+0x3d>
  800b0f:	eb 14                	jmp    800b25 <memcmp+0x33>
  800b11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	83 e9 01             	sub    $0x1,%ecx
  800b21:	38 d8                	cmp    %bl,%al
  800b23:	74 12                	je     800b37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 db             	movzbl %bl,%ebx
  800b2b:	29 d8                	sub    %ebx,%eax
  800b2d:	eb 11                	jmp    800b40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	83 e9 01             	sub    $0x1,%ecx
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	85 c9                	test   %ecx,%ecx
  800b39:	75 d6                	jne    800b11 <memcmp+0x1f>
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 15                	jae    800b69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b58:	38 08                	cmp    %cl,(%eax)
  800b5a:	75 06                	jne    800b62 <memfind+0x1d>
  800b5c:	eb 0b                	jmp    800b69 <memfind+0x24>
  800b5e:	38 08                	cmp    %cl,(%eax)
  800b60:	74 07                	je     800b69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	39 c2                	cmp    %eax,%edx
  800b67:	77 f5                	ja     800b5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 04             	sub    $0x4,%esp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 02             	movzbl (%edx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 04                	je     800b85 <strtol+0x1a>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	75 0e                	jne    800b93 <strtol+0x28>
		s++;
  800b85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	0f b6 02             	movzbl (%edx),%eax
  800b8b:	3c 20                	cmp    $0x20,%al
  800b8d:	74 f6                	je     800b85 <strtol+0x1a>
  800b8f:	3c 09                	cmp    $0x9,%al
  800b91:	74 f2                	je     800b85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b93:	3c 2b                	cmp    $0x2b,%al
  800b95:	75 0c                	jne    800ba3 <strtol+0x38>
		s++;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba1:	eb 15                	jmp    800bb8 <strtol+0x4d>
	else if (*s == '-')
  800ba3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	75 0a                	jne    800bb8 <strtol+0x4d>
		s++, neg = 1;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	85 db                	test   %ebx,%ebx
  800bba:	0f 94 c0             	sete   %al
  800bbd:	74 05                	je     800bc4 <strtol+0x59>
  800bbf:	83 fb 10             	cmp    $0x10,%ebx
  800bc2:	75 18                	jne    800bdc <strtol+0x71>
  800bc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc7:	75 13                	jne    800bdc <strtol+0x71>
  800bc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	75 0a                	jne    800bdc <strtol+0x71>
		s += 2, base = 16;
  800bd2:	83 c2 02             	add    $0x2,%edx
  800bd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	eb 15                	jmp    800bf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdc:	84 c0                	test   %al,%al
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	74 0f                	je     800bf1 <strtol+0x86>
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bea:	75 05                	jne    800bf1 <strtol+0x86>
		s++, base = 8;
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 0a             	movzbl (%edx),%ecx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xa2>
			dig = *s - '0';
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 30             	sub    $0x30,%ecx
  800c0b:	eb 1e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 57             	sub    $0x57,%ecx
  800c1b:	eb 0e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 15                	ja     800c3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2b:	39 f1                	cmp    %esi,%ecx
  800c2d:	7d 0b                	jge    800c3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c2f:	83 c2 01             	add    $0x1,%edx
  800c32:	0f af c6             	imul   %esi,%eax
  800c35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c38:	eb be                	jmp    800bf8 <strtol+0x8d>
  800c3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c40:	74 05                	je     800c47 <strtol+0xdc>
		*endptr = (char *) s;
  800c42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c4b:	74 04                	je     800c51 <strtol+0xe6>
  800c4d:	89 c8                	mov    %ecx,%eax
  800c4f:	f7 d8                	neg    %eax
}
  800c51:	83 c4 04             	add    $0x4,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    
  800c59:	00 00                	add    %al,(%eax)
	...

00800c5c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
  800c62:	89 1c 24             	mov    %ebx,(%esp)
  800c65:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	89 d7                	mov    %edx,%edi
  800c79:	51                   	push   %ecx
  800c7a:	52                   	push   %edx
  800c7b:	53                   	push   %ebx
  800c7c:	54                   	push   %esp
  800c7d:	55                   	push   %ebp
  800c7e:	56                   	push   %esi
  800c7f:	57                   	push   %edi
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	8d 35 8a 0c 80 00    	lea    0x800c8a,%esi
  800c88:	0f 34                	sysenter 
  800c8a:	5f                   	pop    %edi
  800c8b:	5e                   	pop    %esi
  800c8c:	5d                   	pop    %ebp
  800c8d:	5c                   	pop    %esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5a                   	pop    %edx
  800c90:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c91:	8b 1c 24             	mov    (%esp),%ebx
  800c94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c98:	89 ec                	mov    %ebp,%esp
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 08             	sub    $0x8,%esp
  800ca2:	89 1c 24             	mov    %ebx,(%esp)
  800ca5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 c3                	mov    %eax,%ebx
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	51                   	push   %ecx
  800cb9:	52                   	push   %edx
  800cba:	53                   	push   %ebx
  800cbb:	54                   	push   %esp
  800cbc:	55                   	push   %ebp
  800cbd:	56                   	push   %esi
  800cbe:	57                   	push   %edi
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	8d 35 c9 0c 80 00    	lea    0x800cc9,%esi
  800cc7:	0f 34                	sysenter 
  800cc9:	5f                   	pop    %edi
  800cca:	5e                   	pop    %esi
  800ccb:	5d                   	pop    %ebp
  800ccc:	5c                   	pop    %esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5a                   	pop    %edx
  800ccf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd0:	8b 1c 24             	mov    (%esp),%ebx
  800cd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cd7:	89 ec                	mov    %ebp,%esp
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 08             	sub    $0x8,%esp
  800ce1:	89 1c 24             	mov    %ebx,(%esp)
  800ce4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ced:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 cb                	mov    %ecx,%ebx
  800cf7:	89 cf                	mov    %ecx,%edi
  800cf9:	51                   	push   %ecx
  800cfa:	52                   	push   %edx
  800cfb:	53                   	push   %ebx
  800cfc:	54                   	push   %esp
  800cfd:	55                   	push   %ebp
  800cfe:	56                   	push   %esi
  800cff:	57                   	push   %edi
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	8d 35 0a 0d 80 00    	lea    0x800d0a,%esi
  800d08:	0f 34                	sysenter 
  800d0a:	5f                   	pop    %edi
  800d0b:	5e                   	pop    %esi
  800d0c:	5d                   	pop    %ebp
  800d0d:	5c                   	pop    %esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5a                   	pop    %edx
  800d10:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800d11:	8b 1c 24             	mov    (%esp),%ebx
  800d14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 28             	sub    $0x28,%esp
  800d22:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d25:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 cb                	mov    %ecx,%ebx
  800d37:	89 cf                	mov    %ecx,%edi
  800d39:	51                   	push   %ecx
  800d3a:	52                   	push   %edx
  800d3b:	53                   	push   %ebx
  800d3c:	54                   	push   %esp
  800d3d:	55                   	push   %ebp
  800d3e:	56                   	push   %esi
  800d3f:	57                   	push   %edi
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	8d 35 4a 0d 80 00    	lea    0x800d4a,%esi
  800d48:	0f 34                	sysenter 
  800d4a:	5f                   	pop    %edi
  800d4b:	5e                   	pop    %esi
  800d4c:	5d                   	pop    %ebp
  800d4d:	5c                   	pop    %esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5a                   	pop    %edx
  800d50:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 28                	jle    800d7d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d59:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d60:	00 
  800d61:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800d68:	00 
  800d69:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d70:	00 
  800d71:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800d78:	e8 db 03 00 00       	call   801158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d83:	89 ec                	mov    %ebp,%esp
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	83 ec 08             	sub    $0x8,%esp
  800d8d:	89 1c 24             	mov    %ebx,(%esp)
  800d90:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	51                   	push   %ecx
  800da6:	52                   	push   %edx
  800da7:	53                   	push   %ebx
  800da8:	54                   	push   %esp
  800da9:	55                   	push   %ebp
  800daa:	56                   	push   %esi
  800dab:	57                   	push   %edi
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8d 35 b6 0d 80 00    	lea    0x800db6,%esi
  800db4:	0f 34                	sysenter 
  800db6:	5f                   	pop    %edi
  800db7:	5e                   	pop    %esi
  800db8:	5d                   	pop    %ebp
  800db9:	5c                   	pop    %esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5a                   	pop    %edx
  800dbc:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbd:	8b 1c 24             	mov    (%esp),%ebx
  800dc0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dc4:	89 ec                	mov    %ebp,%esp
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 28             	sub    $0x28,%esp
  800dce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800dd1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 df                	mov    %ebx,%edi
  800de6:	51                   	push   %ecx
  800de7:	52                   	push   %edx
  800de8:	53                   	push   %ebx
  800de9:	54                   	push   %esp
  800dea:	55                   	push   %ebp
  800deb:	56                   	push   %esi
  800dec:	57                   	push   %edi
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	8d 35 f7 0d 80 00    	lea    0x800df7,%esi
  800df5:	0f 34                	sysenter 
  800df7:	5f                   	pop    %edi
  800df8:	5e                   	pop    %esi
  800df9:	5d                   	pop    %ebp
  800dfa:	5c                   	pop    %esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5a                   	pop    %edx
  800dfd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7e 28                	jle    800e2a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e06:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800e15:	00 
  800e16:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e1d:	00 
  800e1e:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800e25:	e8 2e 03 00 00       	call   801158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e30:	89 ec                	mov    %ebp,%esp
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 28             	sub    $0x28,%esp
  800e3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e3d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e45:	b8 09 00 00 00       	mov    $0x9,%eax
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	89 df                	mov    %ebx,%edi
  800e52:	51                   	push   %ecx
  800e53:	52                   	push   %edx
  800e54:	53                   	push   %ebx
  800e55:	54                   	push   %esp
  800e56:	55                   	push   %ebp
  800e57:	56                   	push   %esi
  800e58:	57                   	push   %edi
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	8d 35 63 0e 80 00    	lea    0x800e63,%esi
  800e61:	0f 34                	sysenter 
  800e63:	5f                   	pop    %edi
  800e64:	5e                   	pop    %esi
  800e65:	5d                   	pop    %ebp
  800e66:	5c                   	pop    %esp
  800e67:	5b                   	pop    %ebx
  800e68:	5a                   	pop    %edx
  800e69:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 28                	jle    800e96 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e72:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e79:	00 
  800e7a:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800e81:	00 
  800e82:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e89:	00 
  800e8a:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800e91:	e8 c2 02 00 00       	call   801158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e96:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9c:	89 ec                	mov    %ebp,%esp
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 28             	sub    $0x28,%esp
  800ea6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ea9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb1:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 df                	mov    %ebx,%edi
  800ebe:	51                   	push   %ecx
  800ebf:	52                   	push   %edx
  800ec0:	53                   	push   %ebx
  800ec1:	54                   	push   %esp
  800ec2:	55                   	push   %ebp
  800ec3:	56                   	push   %esi
  800ec4:	57                   	push   %edi
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	8d 35 cf 0e 80 00    	lea    0x800ecf,%esi
  800ecd:	0f 34                	sysenter 
  800ecf:	5f                   	pop    %edi
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	5c                   	pop    %esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5a                   	pop    %edx
  800ed5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7e 28                	jle    800f02 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ede:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800eed:	00 
  800eee:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ef5:	00 
  800ef6:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800efd:	e8 56 02 00 00       	call   801158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f02:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 28             	sub    $0x28,%esp
  800f12:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f18:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	51                   	push   %ecx
  800f2a:	52                   	push   %edx
  800f2b:	53                   	push   %ebx
  800f2c:	54                   	push   %esp
  800f2d:	55                   	push   %ebp
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	8d 35 3a 0f 80 00    	lea    0x800f3a,%esi
  800f38:	0f 34                	sysenter 
  800f3a:	5f                   	pop    %edi
  800f3b:	5e                   	pop    %esi
  800f3c:	5d                   	pop    %ebp
  800f3d:	5c                   	pop    %esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5a                   	pop    %edx
  800f40:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 28                	jle    800f6d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f49:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f50:	00 
  800f51:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800f58:	00 
  800f59:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f60:	00 
  800f61:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800f68:	e8 eb 01 00 00       	call   801158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f6d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f73:	89 ec                	mov    %ebp,%esp
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 28             	sub    $0x28,%esp
  800f7d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f80:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f83:	bf 00 00 00 00       	mov    $0x0,%edi
  800f88:	b8 05 00 00 00       	mov    $0x5,%eax
  800f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
  800f96:	51                   	push   %ecx
  800f97:	52                   	push   %edx
  800f98:	53                   	push   %ebx
  800f99:	54                   	push   %esp
  800f9a:	55                   	push   %ebp
  800f9b:	56                   	push   %esi
  800f9c:	57                   	push   %edi
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	8d 35 a7 0f 80 00    	lea    0x800fa7,%esi
  800fa5:	0f 34                	sysenter 
  800fa7:	5f                   	pop    %edi
  800fa8:	5e                   	pop    %esi
  800fa9:	5d                   	pop    %ebp
  800faa:	5c                   	pop    %esp
  800fab:	5b                   	pop    %ebx
  800fac:	5a                   	pop    %edx
  800fad:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 28                	jle    800fda <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fcd:	00 
  800fce:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800fd5:	e8 7e 01 00 00       	call   801158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fda:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe0:	89 ec                	mov    %ebp,%esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 08             	sub    $0x8,%esp
  800fea:	89 1c 24             	mov    %ebx,(%esp)
  800fed:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ffb:	89 d1                	mov    %edx,%ecx
  800ffd:	89 d3                	mov    %edx,%ebx
  800fff:	89 d7                	mov    %edx,%edi
  801001:	51                   	push   %ecx
  801002:	52                   	push   %edx
  801003:	53                   	push   %ebx
  801004:	54                   	push   %esp
  801005:	55                   	push   %ebp
  801006:	56                   	push   %esi
  801007:	57                   	push   %edi
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	8d 35 12 10 80 00    	lea    0x801012,%esi
  801010:	0f 34                	sysenter 
  801012:	5f                   	pop    %edi
  801013:	5e                   	pop    %esi
  801014:	5d                   	pop    %ebp
  801015:	5c                   	pop    %esp
  801016:	5b                   	pop    %ebx
  801017:	5a                   	pop    %edx
  801018:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801019:	8b 1c 24             	mov    (%esp),%ebx
  80101c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	89 1c 24             	mov    %ebx,(%esp)
  80102d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801031:	bb 00 00 00 00       	mov    $0x0,%ebx
  801036:	b8 04 00 00 00       	mov    $0x4,%eax
  80103b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 df                	mov    %ebx,%edi
  801043:	51                   	push   %ecx
  801044:	52                   	push   %edx
  801045:	53                   	push   %ebx
  801046:	54                   	push   %esp
  801047:	55                   	push   %ebp
  801048:	56                   	push   %esi
  801049:	57                   	push   %edi
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	8d 35 54 10 80 00    	lea    0x801054,%esi
  801052:	0f 34                	sysenter 
  801054:	5f                   	pop    %edi
  801055:	5e                   	pop    %esi
  801056:	5d                   	pop    %ebp
  801057:	5c                   	pop    %esp
  801058:	5b                   	pop    %ebx
  801059:	5a                   	pop    %edx
  80105a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80105b:	8b 1c 24             	mov    (%esp),%ebx
  80105e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801062:	89 ec                	mov    %ebp,%esp
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	89 1c 24             	mov    %ebx,(%esp)
  80106f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801073:	ba 00 00 00 00       	mov    $0x0,%edx
  801078:	b8 02 00 00 00       	mov    $0x2,%eax
  80107d:	89 d1                	mov    %edx,%ecx
  80107f:	89 d3                	mov    %edx,%ebx
  801081:	89 d7                	mov    %edx,%edi
  801083:	51                   	push   %ecx
  801084:	52                   	push   %edx
  801085:	53                   	push   %ebx
  801086:	54                   	push   %esp
  801087:	55                   	push   %ebp
  801088:	56                   	push   %esi
  801089:	57                   	push   %edi
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	8d 35 94 10 80 00    	lea    0x801094,%esi
  801092:	0f 34                	sysenter 
  801094:	5f                   	pop    %edi
  801095:	5e                   	pop    %esi
  801096:	5d                   	pop    %ebp
  801097:	5c                   	pop    %esp
  801098:	5b                   	pop    %ebx
  801099:	5a                   	pop    %edx
  80109a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80109b:	8b 1c 24             	mov    (%esp),%ebx
  80109e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010a2:	89 ec                	mov    %ebp,%esp
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 28             	sub    $0x28,%esp
  8010ac:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010af:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b7:	b8 03 00 00 00       	mov    $0x3,%eax
  8010bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bf:	89 cb                	mov    %ecx,%ebx
  8010c1:	89 cf                	mov    %ecx,%edi
  8010c3:	51                   	push   %ecx
  8010c4:	52                   	push   %edx
  8010c5:	53                   	push   %ebx
  8010c6:	54                   	push   %esp
  8010c7:	55                   	push   %ebp
  8010c8:	56                   	push   %esi
  8010c9:	57                   	push   %edi
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	8d 35 d4 10 80 00    	lea    0x8010d4,%esi
  8010d2:	0f 34                	sysenter 
  8010d4:	5f                   	pop    %edi
  8010d5:	5e                   	pop    %esi
  8010d6:	5d                   	pop    %ebp
  8010d7:	5c                   	pop    %esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5a                   	pop    %edx
  8010da:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	7e 28                	jle    801107 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010ea:	00 
  8010eb:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  801102:	e8 51 00 00 00       	call   801158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801107:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80110a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110d:	89 ec                	mov    %ebp,%esp
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    
  801111:	00 00                	add    %al,(%eax)
	...

00801114 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80111a:	c7 44 24 08 4f 17 80 	movl   $0x80174f,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801129:	00 
  80112a:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  801131:	e8 22 00 00 00       	call   801158 <_panic>

00801136 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80113c:	c7 44 24 08 50 17 80 	movl   $0x801750,0x8(%esp)
  801143:	00 
  801144:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80114b:	00 
  80114c:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  801153:	e8 00 00 00 00       	call   801158 <_panic>

00801158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801160:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801163:	a1 08 20 80 00       	mov    0x802008,%eax
  801168:	85 c0                	test   %eax,%eax
  80116a:	74 10                	je     80117c <_panic+0x24>
		cprintf("%s: ", argv0);
  80116c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801170:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  801177:	e8 09 f0 ff ff       	call   800185 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80117c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801182:	e8 df fe ff ff       	call   801066 <sys_getenvid>
  801187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80118e:	8b 55 08             	mov    0x8(%ebp),%edx
  801191:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801195:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119d:	c7 04 24 78 17 80 00 	movl   $0x801778,(%esp)
  8011a4:	e8 dc ef ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b0:	89 04 24             	mov    %eax,(%esp)
  8011b3:	e8 6c ef ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  8011b8:	c7 04 24 d4 14 80 00 	movl   $0x8014d4,(%esp)
  8011bf:	e8 c1 ef ff ff       	call   800185 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011c4:	cc                   	int3   
  8011c5:	eb fd                	jmp    8011c4 <_panic+0x6c>
	...

008011d0 <__udivdi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	83 ec 10             	sub    $0x10,%esp
  8011d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011db:	8b 55 08             	mov    0x8(%ebp),%edx
  8011de:	8b 75 10             	mov    0x10(%ebp),%esi
  8011e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011e9:	75 35                	jne    801220 <__udivdi3+0x50>
  8011eb:	39 fe                	cmp    %edi,%esi
  8011ed:	77 61                	ja     801250 <__udivdi3+0x80>
  8011ef:	85 f6                	test   %esi,%esi
  8011f1:	75 0b                	jne    8011fe <__udivdi3+0x2e>
  8011f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f8:	31 d2                	xor    %edx,%edx
  8011fa:	f7 f6                	div    %esi
  8011fc:	89 c6                	mov    %eax,%esi
  8011fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801201:	31 d2                	xor    %edx,%edx
  801203:	89 f8                	mov    %edi,%eax
  801205:	f7 f6                	div    %esi
  801207:	89 c7                	mov    %eax,%edi
  801209:	89 c8                	mov    %ecx,%eax
  80120b:	f7 f6                	div    %esi
  80120d:	89 c1                	mov    %eax,%ecx
  80120f:	89 fa                	mov    %edi,%edx
  801211:	89 c8                	mov    %ecx,%eax
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    
  80121a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801220:	39 f8                	cmp    %edi,%eax
  801222:	77 1c                	ja     801240 <__udivdi3+0x70>
  801224:	0f bd d0             	bsr    %eax,%edx
  801227:	83 f2 1f             	xor    $0x1f,%edx
  80122a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80122d:	75 39                	jne    801268 <__udivdi3+0x98>
  80122f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801232:	0f 86 a0 00 00 00    	jbe    8012d8 <__udivdi3+0x108>
  801238:	39 f8                	cmp    %edi,%eax
  80123a:	0f 82 98 00 00 00    	jb     8012d8 <__udivdi3+0x108>
  801240:	31 ff                	xor    %edi,%edi
  801242:	31 c9                	xor    %ecx,%ecx
  801244:	89 c8                	mov    %ecx,%eax
  801246:	89 fa                	mov    %edi,%edx
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    
  80124f:	90                   	nop
  801250:	89 d1                	mov    %edx,%ecx
  801252:	89 fa                	mov    %edi,%edx
  801254:	89 c8                	mov    %ecx,%eax
  801256:	31 ff                	xor    %edi,%edi
  801258:	f7 f6                	div    %esi
  80125a:	89 c1                	mov    %eax,%ecx
  80125c:	89 fa                	mov    %edi,%edx
  80125e:	89 c8                	mov    %ecx,%eax
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	5e                   	pop    %esi
  801264:	5f                   	pop    %edi
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    
  801267:	90                   	nop
  801268:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80126c:	89 f2                	mov    %esi,%edx
  80126e:	d3 e0                	shl    %cl,%eax
  801270:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801273:	b8 20 00 00 00       	mov    $0x20,%eax
  801278:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80127b:	89 c1                	mov    %eax,%ecx
  80127d:	d3 ea                	shr    %cl,%edx
  80127f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801283:	0b 55 ec             	or     -0x14(%ebp),%edx
  801286:	d3 e6                	shl    %cl,%esi
  801288:	89 c1                	mov    %eax,%ecx
  80128a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80128d:	89 fe                	mov    %edi,%esi
  80128f:	d3 ee                	shr    %cl,%esi
  801291:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801295:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801298:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129b:	d3 e7                	shl    %cl,%edi
  80129d:	89 c1                	mov    %eax,%ecx
  80129f:	d3 ea                	shr    %cl,%edx
  8012a1:	09 d7                	or     %edx,%edi
  8012a3:	89 f2                	mov    %esi,%edx
  8012a5:	89 f8                	mov    %edi,%eax
  8012a7:	f7 75 ec             	divl   -0x14(%ebp)
  8012aa:	89 d6                	mov    %edx,%esi
  8012ac:	89 c7                	mov    %eax,%edi
  8012ae:	f7 65 e8             	mull   -0x18(%ebp)
  8012b1:	39 d6                	cmp    %edx,%esi
  8012b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012b6:	72 30                	jb     8012e8 <__udivdi3+0x118>
  8012b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012bf:	d3 e2                	shl    %cl,%edx
  8012c1:	39 c2                	cmp    %eax,%edx
  8012c3:	73 05                	jae    8012ca <__udivdi3+0xfa>
  8012c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8012c8:	74 1e                	je     8012e8 <__udivdi3+0x118>
  8012ca:	89 f9                	mov    %edi,%ecx
  8012cc:	31 ff                	xor    %edi,%edi
  8012ce:	e9 71 ff ff ff       	jmp    801244 <__udivdi3+0x74>
  8012d3:	90                   	nop
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	31 ff                	xor    %edi,%edi
  8012da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8012df:	e9 60 ff ff ff       	jmp    801244 <__udivdi3+0x74>
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8012eb:	31 ff                	xor    %edi,%edi
  8012ed:	89 c8                	mov    %ecx,%eax
  8012ef:	89 fa                	mov    %edi,%edx
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
	...

00801300 <__umoddi3>:
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	57                   	push   %edi
  801304:	56                   	push   %esi
  801305:	83 ec 20             	sub    $0x20,%esp
  801308:	8b 55 14             	mov    0x14(%ebp),%edx
  80130b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801311:	8b 75 0c             	mov    0xc(%ebp),%esi
  801314:	85 d2                	test   %edx,%edx
  801316:	89 c8                	mov    %ecx,%eax
  801318:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80131b:	75 13                	jne    801330 <__umoddi3+0x30>
  80131d:	39 f7                	cmp    %esi,%edi
  80131f:	76 3f                	jbe    801360 <__umoddi3+0x60>
  801321:	89 f2                	mov    %esi,%edx
  801323:	f7 f7                	div    %edi
  801325:	89 d0                	mov    %edx,%eax
  801327:	31 d2                	xor    %edx,%edx
  801329:	83 c4 20             	add    $0x20,%esp
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    
  801330:	39 f2                	cmp    %esi,%edx
  801332:	77 4c                	ja     801380 <__umoddi3+0x80>
  801334:	0f bd ca             	bsr    %edx,%ecx
  801337:	83 f1 1f             	xor    $0x1f,%ecx
  80133a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80133d:	75 51                	jne    801390 <__umoddi3+0x90>
  80133f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801342:	0f 87 e0 00 00 00    	ja     801428 <__umoddi3+0x128>
  801348:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134b:	29 f8                	sub    %edi,%eax
  80134d:	19 d6                	sbb    %edx,%esi
  80134f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801355:	89 f2                	mov    %esi,%edx
  801357:	83 c4 20             	add    $0x20,%esp
  80135a:	5e                   	pop    %esi
  80135b:	5f                   	pop    %edi
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    
  80135e:	66 90                	xchg   %ax,%ax
  801360:	85 ff                	test   %edi,%edi
  801362:	75 0b                	jne    80136f <__umoddi3+0x6f>
  801364:	b8 01 00 00 00       	mov    $0x1,%eax
  801369:	31 d2                	xor    %edx,%edx
  80136b:	f7 f7                	div    %edi
  80136d:	89 c7                	mov    %eax,%edi
  80136f:	89 f0                	mov    %esi,%eax
  801371:	31 d2                	xor    %edx,%edx
  801373:	f7 f7                	div    %edi
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	f7 f7                	div    %edi
  80137a:	eb a9                	jmp    801325 <__umoddi3+0x25>
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	89 c8                	mov    %ecx,%eax
  801382:	89 f2                	mov    %esi,%edx
  801384:	83 c4 20             	add    $0x20,%esp
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    
  80138b:	90                   	nop
  80138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801390:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801394:	d3 e2                	shl    %cl,%edx
  801396:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801399:	ba 20 00 00 00       	mov    $0x20,%edx
  80139e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8013a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013a8:	89 fa                	mov    %edi,%edx
  8013aa:	d3 ea                	shr    %cl,%edx
  8013ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8013b3:	d3 e7                	shl    %cl,%edi
  8013b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013bc:	89 f2                	mov    %esi,%edx
  8013be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8013c1:	89 c7                	mov    %eax,%edi
  8013c3:	d3 ea                	shr    %cl,%edx
  8013c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013cc:	89 c2                	mov    %eax,%edx
  8013ce:	d3 e6                	shl    %cl,%esi
  8013d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013d4:	d3 ea                	shr    %cl,%edx
  8013d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013da:	09 d6                	or     %edx,%esi
  8013dc:	89 f0                	mov    %esi,%eax
  8013de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013e1:	d3 e7                	shl    %cl,%edi
  8013e3:	89 f2                	mov    %esi,%edx
  8013e5:	f7 75 f4             	divl   -0xc(%ebp)
  8013e8:	89 d6                	mov    %edx,%esi
  8013ea:	f7 65 e8             	mull   -0x18(%ebp)
  8013ed:	39 d6                	cmp    %edx,%esi
  8013ef:	72 2b                	jb     80141c <__umoddi3+0x11c>
  8013f1:	39 c7                	cmp    %eax,%edi
  8013f3:	72 23                	jb     801418 <__umoddi3+0x118>
  8013f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013f9:	29 c7                	sub    %eax,%edi
  8013fb:	19 d6                	sbb    %edx,%esi
  8013fd:	89 f0                	mov    %esi,%eax
  8013ff:	89 f2                	mov    %esi,%edx
  801401:	d3 ef                	shr    %cl,%edi
  801403:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801407:	d3 e0                	shl    %cl,%eax
  801409:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80140d:	09 f8                	or     %edi,%eax
  80140f:	d3 ea                	shr    %cl,%edx
  801411:	83 c4 20             	add    $0x20,%esp
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    
  801418:	39 d6                	cmp    %edx,%esi
  80141a:	75 d9                	jne    8013f5 <__umoddi3+0xf5>
  80141c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80141f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801422:	eb d1                	jmp    8013f5 <__umoddi3+0xf5>
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	39 f2                	cmp    %esi,%edx
  80142a:	0f 82 18 ff ff ff    	jb     801348 <__umoddi3+0x48>
  801430:	e9 1d ff ff ff       	jmp    801352 <__umoddi3+0x52>
