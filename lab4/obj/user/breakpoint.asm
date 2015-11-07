
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 28             	sub    $0x28,%esp
	int a;
	a=10;
  80003a:	c7 45 f4 0a 00 00 00 	movl   $0xa,-0xc(%ebp)
	cprintf("At first , a equals %d\n",a);
  800041:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800048:	00 
  800049:	c7 04 24 c0 13 80 00 	movl   $0x8013c0,(%esp)
  800050:	e8 f8 00 00 00       	call   80014d <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  800055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 d8 13 80 00 	movl   $0x8013d8,(%esp)
  800063:	e8 e5 00 00 00       	call   80014d <cprintf>
	asm volatile("int $3");
  800068:	cc                   	int3   
	// Try single-step here
	a=20;
  800069:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800070:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 e8 13 80 00 	movl   $0x8013e8,(%esp)
  80007f:	e8 c9 00 00 00       	call   80014d <cprintf>
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
  80008e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800091:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800094:	8b 75 08             	mov    0x8(%ebp),%esi
  800097:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80009a:	e8 87 0f 00 00       	call   801026 <sys_getenvid>
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	c1 e0 07             	shl    $0x7,%eax
  8000a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ac:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b1:	85 f6                	test   %esi,%esi
  8000b3:	7e 07                	jle    8000bc <libmain+0x34>
		binaryname = argv[0];
  8000b5:	8b 03                	mov    (%ebx),%eax
  8000b7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c0:	89 34 24             	mov    %esi,(%esp)
  8000c3:	e8 6c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c8:	e8 0b 00 00 00       	call   8000d8 <exit>
}
  8000cd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000d0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000d3:	89 ec                	mov    %ebp,%esp
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    
	...

008000d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e5:	e8 7c 0f 00 00       	call   801066 <sys_env_destroy>
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fc:	00 00 00 
	b.cnt = 0;
  8000ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800106:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800109:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800110:	8b 45 08             	mov    0x8(%ebp),%eax
  800113:	89 44 24 08          	mov    %eax,0x8(%esp)
  800117:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800121:	c7 04 24 67 01 80 00 	movl   $0x800167,(%esp)
  800128:	e8 d0 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 17 0b 00 00       	call   800c5c <sys_cputs>

	return b.cnt;
}
  800145:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800153:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 87 ff ff ff       	call   8000ec <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	53                   	push   %ebx
  80016b:	83 ec 14             	sub    $0x14,%esp
  80016e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800171:	8b 03                	mov    (%ebx),%eax
  800173:	8b 55 08             	mov    0x8(%ebp),%edx
  800176:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017a:	83 c0 01             	add    $0x1,%eax
  80017d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800184:	75 19                	jne    80019f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800186:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018d:	00 
  80018e:	8d 43 08             	lea    0x8(%ebx),%eax
  800191:	89 04 24             	mov    %eax,(%esp)
  800194:	e8 c3 0a 00 00       	call   800c5c <sys_cputs>
		b->idx = 0;
  800199:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a3:	83 c4 14             	add    $0x14,%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    
  8001a9:	00 00                	add    %al,(%eax)
  8001ab:	00 00                	add    %al,(%eax)
  8001ad:	00 00                	add    %al,(%eax)
	...

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 4c             	sub    $0x4c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001db:	39 d1                	cmp    %edx,%ecx
  8001dd:	72 15                	jb     8001f4 <printnum+0x44>
  8001df:	77 07                	ja     8001e8 <printnum+0x38>
  8001e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e4:	39 d0                	cmp    %edx,%eax
  8001e6:	76 0c                	jbe    8001f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	85 db                	test   %ebx,%ebx
  8001ed:	8d 76 00             	lea    0x0(%esi),%esi
  8001f0:	7f 61                	jg     800253 <printnum+0xa3>
  8001f2:	eb 70                	jmp    800264 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800207:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80020b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80020e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800211:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800214:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800229:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022d:	e8 1e 0f 00 00       	call   801150 <__udivdi3>
  800232:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800235:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	89 54 24 04          	mov    %edx,0x4(%esp)
  800247:	89 f2                	mov    %esi,%edx
  800249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024c:	e8 5f ff ff ff       	call   8001b0 <printnum>
  800251:	eb 11                	jmp    800264 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	89 74 24 04          	mov    %esi,0x4(%esp)
  800257:	89 3c 24             	mov    %edi,(%esp)
  80025a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025d:	83 eb 01             	sub    $0x1,%ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f ef                	jg     800253 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 74 24 04          	mov    %esi,0x4(%esp)
  800268:	8b 74 24 04          	mov    0x4(%esp),%esi
  80026c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80027e:	89 14 24             	mov    %edx,(%esp)
  800281:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800284:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800288:	e8 f3 0f 00 00       	call   801280 <__umoddi3>
  80028d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800291:	0f be 80 09 14 80 00 	movsbl 0x801409(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 4c             	add    $0x4c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ef:	73 0a                	jae    8002fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f4:	88 0a                	mov    %cl,(%edx)
  8002f6:	83 c2 01             	add    $0x1,%edx
  8002f9:	89 10                	mov    %edx,(%eax)
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 5c             	sub    $0x5c,%esp
  800306:	8b 7d 08             	mov    0x8(%ebp),%edi
  800309:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80030f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800316:	eb 11                	jmp    800329 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800318:	85 c0                	test   %eax,%eax
  80031a:	0f 84 09 04 00 00    	je     800729 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800320:	89 74 24 04          	mov    %esi,0x4(%esp)
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	0f b6 03             	movzbl (%ebx),%eax
  80032c:	83 c3 01             	add    $0x1,%ebx
  80032f:	83 f8 25             	cmp    $0x25,%eax
  800332:	75 e4                	jne    800318 <vprintfmt+0x1b>
  800334:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800338:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80033f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800346:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	eb 06                	jmp    80035a <vprintfmt+0x5d>
  800354:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800358:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	0f b6 13             	movzbl (%ebx),%edx
  80035d:	0f b6 c2             	movzbl %dl,%eax
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	8d 43 01             	lea    0x1(%ebx),%eax
  800366:	83 ea 23             	sub    $0x23,%edx
  800369:	80 fa 55             	cmp    $0x55,%dl
  80036c:	0f 87 9a 03 00 00    	ja     80070c <vprintfmt+0x40f>
  800372:	0f b6 d2             	movzbl %dl,%edx
  800375:	ff 24 95 c0 14 80 00 	jmp    *0x8014c0(,%edx,4)
  80037c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800380:	eb d6                	jmp    800358 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800382:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800385:	83 ea 30             	sub    $0x30,%edx
  800388:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80038b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800391:	83 fb 09             	cmp    $0x9,%ebx
  800394:	77 4c                	ja     8003e2 <vprintfmt+0xe5>
  800396:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800399:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80039f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003a2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003a6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003a9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003ac:	83 fb 09             	cmp    $0x9,%ebx
  8003af:	76 eb                	jbe    80039c <vprintfmt+0x9f>
  8003b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003b7:	eb 29                	jmp    8003e2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003bf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003c2:	8b 12                	mov    (%edx),%edx
  8003c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003c7:	eb 19                	jmp    8003e2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003cc:	c1 fa 1f             	sar    $0x1f,%edx
  8003cf:	f7 d2                	not    %edx
  8003d1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003d4:	eb 82                	jmp    800358 <vprintfmt+0x5b>
  8003d6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003dd:	e9 76 ff ff ff       	jmp    800358 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e6:	0f 89 6c ff ff ff    	jns    800358 <vprintfmt+0x5b>
  8003ec:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003f2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003f5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003f8:	e9 5b ff ff ff       	jmp    800358 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800400:	e9 53 ff ff ff       	jmp    800358 <vprintfmt+0x5b>
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	89 74 24 04          	mov    %esi,0x4(%esp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	ff d7                	call   *%edi
  80041c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80041f:	e9 05 ff ff ff       	jmp    800329 <vprintfmt+0x2c>
  800424:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 50 04             	lea    0x4(%eax),%edx
  80042d:	89 55 14             	mov    %edx,0x14(%ebp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	89 c2                	mov    %eax,%edx
  800434:	c1 fa 1f             	sar    $0x1f,%edx
  800437:	31 d0                	xor    %edx,%eax
  800439:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043b:	83 f8 08             	cmp    $0x8,%eax
  80043e:	7f 0b                	jg     80044b <vprintfmt+0x14e>
  800440:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800447:	85 d2                	test   %edx,%edx
  800449:	75 20                	jne    80046b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80044b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044f:	c7 44 24 08 1a 14 80 	movl   $0x80141a,0x8(%esp)
  800456:	00 
  800457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045b:	89 3c 24             	mov    %edi,(%esp)
  80045e:	e8 4e 03 00 00       	call   8007b1 <printfmt>
  800463:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800466:	e9 be fe ff ff       	jmp    800329 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80046b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046f:	c7 44 24 08 23 14 80 	movl   $0x801423,0x8(%esp)
  800476:	00 
  800477:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047b:	89 3c 24             	mov    %edi,(%esp)
  80047e:	e8 2e 03 00 00       	call   8007b1 <printfmt>
  800483:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800486:	e9 9e fe ff ff       	jmp    800329 <vprintfmt+0x2c>
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048e:	89 c3                	mov    %eax,%ebx
  800490:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800496:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	75 07                	jne    8004b2 <vprintfmt+0x1b5>
  8004ab:	c7 45 c4 26 14 80 00 	movl   $0x801426,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004b2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004b6:	7e 06                	jle    8004be <vprintfmt+0x1c1>
  8004b8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004bc:	75 13                	jne    8004d1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c1:	0f be 02             	movsbl (%edx),%eax
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	0f 85 99 00 00 00    	jne    800565 <vprintfmt+0x268>
  8004cc:	e9 86 00 00 00       	jmp    800557 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004d8:	89 0c 24             	mov    %ecx,(%esp)
  8004db:	e8 1b 03 00 00       	call   8007fb <strnlen>
  8004e0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004e3:	29 c2                	sub    %eax,%edx
  8004e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	7e d2                	jle    8004be <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004ec:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8004f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004f3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004f6:	89 d3                	mov    %edx,%ebx
  8004f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	83 eb 01             	sub    $0x1,%ebx
  800507:	85 db                	test   %ebx,%ebx
  800509:	7f ed                	jg     8004f8 <vprintfmt+0x1fb>
  80050b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80050e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800515:	eb a7                	jmp    8004be <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80051b:	74 18                	je     800535 <vprintfmt+0x238>
  80051d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800520:	83 fa 5e             	cmp    $0x5e,%edx
  800523:	76 10                	jbe    800535 <vprintfmt+0x238>
					putch('?', putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800530:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800533:	eb 0a                	jmp    80053f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800535:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800543:	0f be 03             	movsbl (%ebx),%eax
  800546:	85 c0                	test   %eax,%eax
  800548:	74 05                	je     80054f <vprintfmt+0x252>
  80054a:	83 c3 01             	add    $0x1,%ebx
  80054d:	eb 29                	jmp    800578 <vprintfmt+0x27b>
  80054f:	89 fe                	mov    %edi,%esi
  800551:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800554:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055b:	7f 2e                	jg     80058b <vprintfmt+0x28e>
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	e9 c4 fd ff ff       	jmp    800329 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800565:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800568:	83 c2 01             	add    $0x1,%edx
  80056b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80056e:	89 f7                	mov    %esi,%edi
  800570:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800573:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800576:	89 d3                	mov    %edx,%ebx
  800578:	85 f6                	test   %esi,%esi
  80057a:	78 9b                	js     800517 <vprintfmt+0x21a>
  80057c:	83 ee 01             	sub    $0x1,%esi
  80057f:	79 96                	jns    800517 <vprintfmt+0x21a>
  800581:	89 fe                	mov    %edi,%esi
  800583:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800586:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800589:	eb cc                	jmp    800557 <vprintfmt+0x25a>
  80058b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80058e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800591:	89 74 24 04          	mov    %esi,0x4(%esp)
  800595:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059e:	83 eb 01             	sub    $0x1,%ebx
  8005a1:	85 db                	test   %ebx,%ebx
  8005a3:	7f ec                	jg     800591 <vprintfmt+0x294>
  8005a5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a8:	e9 7c fd ff ff       	jmp    800329 <vprintfmt+0x2c>
  8005ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 f9 01             	cmp    $0x1,%ecx
  8005b3:	7e 16                	jle    8005cb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 08             	lea    0x8(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005c9:	eb 32                	jmp    8005fd <vprintfmt+0x300>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	74 18                	je     8005e7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005dd:	89 c1                	mov    %eax,%ecx
  8005df:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e5:	eb 16                	jmp    8005fd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f5:	89 c2                	mov    %eax,%edx
  8005f7:	c1 fa 1f             	sar    $0x1f,%edx
  8005fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800600:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800608:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060c:	0f 89 b8 00 00 00    	jns    8006ca <vprintfmt+0x3cd>
				putch('-', putdat);
  800612:	89 74 24 04          	mov    %esi,0x4(%esp)
  800616:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061d:	ff d7                	call   *%edi
				num = -(long long) num;
  80061f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800622:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800625:	f7 d9                	neg    %ecx
  800627:	83 d3 00             	adc    $0x0,%ebx
  80062a:	f7 db                	neg    %ebx
  80062c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800631:	e9 94 00 00 00       	jmp    8006ca <vprintfmt+0x3cd>
  800636:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 63 fc ff ff       	call   8002a6 <getuint>
  800643:	89 c1                	mov    %eax,%ecx
  800645:	89 d3                	mov    %edx,%ebx
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80064c:	eb 7c                	jmp    8006ca <vprintfmt+0x3cd>
  80064e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800651:	89 74 24 04          	mov    %esi,0x4(%esp)
  800655:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80065c:	ff d7                	call   *%edi
			putch('X', putdat);
  80065e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800662:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800669:	ff d7                	call   *%edi
			putch('X', putdat);
  80066b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800676:	ff d7                	call   *%edi
  800678:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80067b:	e9 a9 fc ff ff       	jmp    800329 <vprintfmt+0x2c>
  800680:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800683:	89 74 24 04          	mov    %esi,0x4(%esp)
  800687:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068e:	ff d7                	call   *%edi
			putch('x', putdat);
  800690:	89 74 24 04          	mov    %esi,0x4(%esp)
  800694:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	8b 08                	mov    (%eax),%ecx
  8006a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ad:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b2:	eb 16                	jmp    8006ca <vprintfmt+0x3cd>
  8006b4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b7:	89 ca                	mov    %ecx,%edx
  8006b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bc:	e8 e5 fb ff ff       	call   8002a6 <getuint>
  8006c1:	89 c1                	mov    %eax,%ecx
  8006c3:	89 d3                	mov    %edx,%ebx
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ca:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ce:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dd:	89 0c 24             	mov    %ecx,(%esp)
  8006e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e4:	89 f2                	mov    %esi,%edx
  8006e6:	89 f8                	mov    %edi,%eax
  8006e8:	e8 c3 fa ff ff       	call   8001b0 <printnum>
  8006ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006f0:	e9 34 fc ff ff       	jmp    800329 <vprintfmt+0x2c>
  8006f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006f8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ff:	89 14 24             	mov    %edx,(%esp)
  800702:	ff d7                	call   *%edi
  800704:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800707:	e9 1d fc ff ff       	jmp    800329 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800710:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800717:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800719:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80071c:	80 38 25             	cmpb   $0x25,(%eax)
  80071f:	0f 84 04 fc ff ff    	je     800329 <vprintfmt+0x2c>
  800725:	89 c3                	mov    %eax,%ebx
  800727:	eb f0                	jmp    800719 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800729:	83 c4 5c             	add    $0x5c,%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 28             	sub    $0x28,%esp
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 04                	je     800745 <vsnprintf+0x14>
  800741:	85 d2                	test   %edx,%edx
  800743:	7f 07                	jg     80074c <vsnprintf+0x1b>
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074a:	eb 3b                	jmp    800787 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800753:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800764:	8b 45 10             	mov    0x10(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  800779:	e8 7f fb ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800781:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800784:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 82 ff ff ff       	call   800731 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 26 fb ff ff       	call   8002fd <vprintfmt>
	va_end(ap);
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
  8007db:	00 00                	add    %al,(%eax)
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 09                	je     8007f9 <strlen+0x19>
		n++;
  8007f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	75 f7                	jne    8007f0 <strlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 19                	je     800822 <strnlen+0x27>
  800809:	80 3b 00             	cmpb   $0x0,(%ebx)
  80080c:	74 14                	je     800822 <strnlen+0x27>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800813:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800816:	39 c8                	cmp    %ecx,%eax
  800818:	74 0d                	je     800827 <strnlen+0x2c>
  80081a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80081e:	75 f3                	jne    800813 <strnlen+0x18>
  800820:	eb 05                	jmp    800827 <strnlen+0x2c>
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800834:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80083d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	84 c9                	test   %cl,%cl
  800845:	75 f2                	jne    800839 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800854:	89 1c 24             	mov    %ebx,(%esp)
  800857:	e8 84 ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800863:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 bc ff ff ff       	call   80082a <strcpy>
	return dst;
}
  80086e:	89 d8                	mov    %ebx,%eax
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800884:	85 f6                	test   %esi,%esi
  800886:	74 18                	je     8008a0 <strncpy+0x2a>
  800888:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80088d:	0f b6 1a             	movzbl (%edx),%ebx
  800890:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800893:	80 3a 01             	cmpb   $0x1,(%edx)
  800896:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	39 ce                	cmp    %ecx,%esi
  80089e:	77 ed                	ja     80088d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b2:	89 f0                	mov    %esi,%eax
  8008b4:	85 c9                	test   %ecx,%ecx
  8008b6:	74 27                	je     8008df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008b8:	83 e9 01             	sub    $0x1,%ecx
  8008bb:	74 1d                	je     8008da <strlcpy+0x36>
  8008bd:	0f b6 1a             	movzbl (%edx),%ebx
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	74 16                	je     8008da <strlcpy+0x36>
			*dst++ = *src++;
  8008c4:	88 18                	mov    %bl,(%eax)
  8008c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c9:	83 e9 01             	sub    $0x1,%ecx
  8008cc:	74 0e                	je     8008dc <strlcpy+0x38>
			*dst++ = *src++;
  8008ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d1:	0f b6 1a             	movzbl (%edx),%ebx
  8008d4:	84 db                	test   %bl,%bl
  8008d6:	75 ec                	jne    8008c4 <strlcpy+0x20>
  8008d8:	eb 02                	jmp    8008dc <strlcpy+0x38>
  8008da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008dc:	c6 00 00             	movb   $0x0,(%eax)
  8008df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ee:	0f b6 01             	movzbl (%ecx),%eax
  8008f1:	84 c0                	test   %al,%al
  8008f3:	74 15                	je     80090a <strcmp+0x25>
  8008f5:	3a 02                	cmp    (%edx),%al
  8008f7:	75 11                	jne    80090a <strcmp+0x25>
		p++, q++;
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ff:	0f b6 01             	movzbl (%ecx),%eax
  800902:	84 c0                	test   %al,%al
  800904:	74 04                	je     80090a <strcmp+0x25>
  800906:	3a 02                	cmp    (%edx),%al
  800908:	74 ef                	je     8008f9 <strcmp+0x14>
  80090a:	0f b6 c0             	movzbl %al,%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 55 08             	mov    0x8(%ebp),%edx
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 23                	je     800948 <strncmp+0x34>
  800925:	0f b6 1a             	movzbl (%edx),%ebx
  800928:	84 db                	test   %bl,%bl
  80092a:	74 25                	je     800951 <strncmp+0x3d>
  80092c:	3a 19                	cmp    (%ecx),%bl
  80092e:	75 21                	jne    800951 <strncmp+0x3d>
  800930:	83 e8 01             	sub    $0x1,%eax
  800933:	74 13                	je     800948 <strncmp+0x34>
		n--, p++, q++;
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093b:	0f b6 1a             	movzbl (%edx),%ebx
  80093e:	84 db                	test   %bl,%bl
  800940:	74 0f                	je     800951 <strncmp+0x3d>
  800942:	3a 19                	cmp    (%ecx),%bl
  800944:	74 ea                	je     800930 <strncmp+0x1c>
  800946:	eb 09                	jmp    800951 <strncmp+0x3d>
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094d:	5b                   	pop    %ebx
  80094e:	5d                   	pop    %ebp
  80094f:	90                   	nop
  800950:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 02             	movzbl (%edx),%eax
  800954:	0f b6 11             	movzbl (%ecx),%edx
  800957:	29 d0                	sub    %edx,%eax
  800959:	eb f2                	jmp    80094d <strncmp+0x39>

0080095b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 18                	je     800984 <strchr+0x29>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 0a                	jne    80097a <strchr+0x1f>
  800970:	eb 17                	jmp    800989 <strchr+0x2e>
  800972:	38 ca                	cmp    %cl,%dl
  800974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800978:	74 0f                	je     800989 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 ee                	jne    800972 <strchr+0x17>
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	74 18                	je     8009b4 <strfind+0x29>
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	75 0a                	jne    8009aa <strfind+0x1f>
  8009a0:	eb 12                	jmp    8009b4 <strfind+0x29>
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009a8:	74 0a                	je     8009b4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 ee                	jne    8009a2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 0c             	sub    $0xc,%esp
  8009bc:	89 1c 24             	mov    %ebx,(%esp)
  8009bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d0:	85 c9                	test   %ecx,%ecx
  8009d2:	74 30                	je     800a04 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009da:	75 25                	jne    800a01 <memset+0x4b>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 20                	jne    800a01 <memset+0x4b>
		c &= 0xFF;
  8009e1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e4:	89 d3                	mov    %edx,%ebx
  8009e6:	c1 e3 08             	shl    $0x8,%ebx
  8009e9:	89 d6                	mov    %edx,%esi
  8009eb:	c1 e6 18             	shl    $0x18,%esi
  8009ee:	89 d0                	mov    %edx,%eax
  8009f0:	c1 e0 10             	shl    $0x10,%eax
  8009f3:	09 f0                	or     %esi,%eax
  8009f5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009f7:	09 d8                	or     %ebx,%eax
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
  8009fc:	fc                   	cld    
  8009fd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ff:	eb 03                	jmp    800a04 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a01:	fc                   	cld    
  800a02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a04:	89 f8                	mov    %edi,%eax
  800a06:	8b 1c 24             	mov    (%esp),%ebx
  800a09:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a11:	89 ec                	mov    %ebp,%esp
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 08             	sub    $0x8,%esp
  800a1b:	89 34 24             	mov    %esi,(%esp)
  800a1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a2b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a2d:	39 c6                	cmp    %eax,%esi
  800a2f:	73 35                	jae    800a66 <memmove+0x51>
  800a31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a34:	39 d0                	cmp    %edx,%eax
  800a36:	73 2e                	jae    800a66 <memmove+0x51>
		s += n;
		d += n;
  800a38:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	f6 c2 03             	test   $0x3,%dl
  800a3d:	75 1b                	jne    800a5a <memmove+0x45>
  800a3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a45:	75 13                	jne    800a5a <memmove+0x45>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 0e                	jne    800a5a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a4c:	83 ef 04             	sub    $0x4,%edi
  800a4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a52:	c1 e9 02             	shr    $0x2,%ecx
  800a55:	fd                   	std    
  800a56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a58:	eb 09                	jmp    800a63 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5a:	83 ef 01             	sub    $0x1,%edi
  800a5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a60:	fd                   	std    
  800a61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a63:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a64:	eb 20                	jmp    800a86 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6c:	75 15                	jne    800a83 <memmove+0x6e>
  800a6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a74:	75 0d                	jne    800a83 <memmove+0x6e>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 08                	jne    800a83 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	fc                   	cld    
  800a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	eb 03                	jmp    800a86 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	8b 34 24             	mov    (%esp),%esi
  800a89:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a8d:	89 ec                	mov    %ebp,%esp
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a97:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	89 04 24             	mov    %eax,(%esp)
  800aab:	e8 65 ff ff ff       	call   800a15 <memmove>
}
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 75 08             	mov    0x8(%ebp),%esi
  800abb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	74 36                	je     800afb <memcmp+0x49>
		if (*s1 != *s2)
  800ac5:	0f b6 06             	movzbl (%esi),%eax
  800ac8:	0f b6 1f             	movzbl (%edi),%ebx
  800acb:	38 d8                	cmp    %bl,%al
  800acd:	74 20                	je     800aef <memcmp+0x3d>
  800acf:	eb 14                	jmp    800ae5 <memcmp+0x33>
  800ad1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ad6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800adb:	83 c2 01             	add    $0x1,%edx
  800ade:	83 e9 01             	sub    $0x1,%ecx
  800ae1:	38 d8                	cmp    %bl,%al
  800ae3:	74 12                	je     800af7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	0f b6 db             	movzbl %bl,%ebx
  800aeb:	29 d8                	sub    %ebx,%eax
  800aed:	eb 11                	jmp    800b00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aef:	83 e9 01             	sub    $0x1,%ecx
  800af2:	ba 00 00 00 00       	mov    $0x0,%edx
  800af7:	85 c9                	test   %ecx,%ecx
  800af9:	75 d6                	jne    800ad1 <memcmp+0x1f>
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b10:	39 d0                	cmp    %edx,%eax
  800b12:	73 15                	jae    800b29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b18:	38 08                	cmp    %cl,(%eax)
  800b1a:	75 06                	jne    800b22 <memfind+0x1d>
  800b1c:	eb 0b                	jmp    800b29 <memfind+0x24>
  800b1e:	38 08                	cmp    %cl,(%eax)
  800b20:	74 07                	je     800b29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b22:	83 c0 01             	add    $0x1,%eax
  800b25:	39 c2                	cmp    %eax,%edx
  800b27:	77 f5                	ja     800b1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 04             	sub    $0x4,%esp
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 02             	movzbl (%edx),%eax
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 04                	je     800b45 <strtol+0x1a>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	75 0e                	jne    800b53 <strtol+0x28>
		s++;
  800b45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b48:	0f b6 02             	movzbl (%edx),%eax
  800b4b:	3c 20                	cmp    $0x20,%al
  800b4d:	74 f6                	je     800b45 <strtol+0x1a>
  800b4f:	3c 09                	cmp    $0x9,%al
  800b51:	74 f2                	je     800b45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b53:	3c 2b                	cmp    $0x2b,%al
  800b55:	75 0c                	jne    800b63 <strtol+0x38>
		s++;
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b61:	eb 15                	jmp    800b78 <strtol+0x4d>
	else if (*s == '-')
  800b63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b6a:	3c 2d                	cmp    $0x2d,%al
  800b6c:	75 0a                	jne    800b78 <strtol+0x4d>
		s++, neg = 1;
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	85 db                	test   %ebx,%ebx
  800b7a:	0f 94 c0             	sete   %al
  800b7d:	74 05                	je     800b84 <strtol+0x59>
  800b7f:	83 fb 10             	cmp    $0x10,%ebx
  800b82:	75 18                	jne    800b9c <strtol+0x71>
  800b84:	80 3a 30             	cmpb   $0x30,(%edx)
  800b87:	75 13                	jne    800b9c <strtol+0x71>
  800b89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b8d:	8d 76 00             	lea    0x0(%esi),%esi
  800b90:	75 0a                	jne    800b9c <strtol+0x71>
		s += 2, base = 16;
  800b92:	83 c2 02             	add    $0x2,%edx
  800b95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	eb 15                	jmp    800bb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b9c:	84 c0                	test   %al,%al
  800b9e:	66 90                	xchg   %ax,%ax
  800ba0:	74 0f                	je     800bb1 <strtol+0x86>
  800ba2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ba7:	80 3a 30             	cmpb   $0x30,(%edx)
  800baa:	75 05                	jne    800bb1 <strtol+0x86>
		s++, base = 8;
  800bac:	83 c2 01             	add    $0x1,%edx
  800baf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb8:	0f b6 0a             	movzbl (%edx),%ecx
  800bbb:	89 cf                	mov    %ecx,%edi
  800bbd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bc0:	80 fb 09             	cmp    $0x9,%bl
  800bc3:	77 08                	ja     800bcd <strtol+0xa2>
			dig = *s - '0';
  800bc5:	0f be c9             	movsbl %cl,%ecx
  800bc8:	83 e9 30             	sub    $0x30,%ecx
  800bcb:	eb 1e                	jmp    800beb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bcd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bd0:	80 fb 19             	cmp    $0x19,%bl
  800bd3:	77 08                	ja     800bdd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bd5:	0f be c9             	movsbl %cl,%ecx
  800bd8:	83 e9 57             	sub    $0x57,%ecx
  800bdb:	eb 0e                	jmp    800beb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bdd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 15                	ja     800bfa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800beb:	39 f1                	cmp    %esi,%ecx
  800bed:	7d 0b                	jge    800bfa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bef:	83 c2 01             	add    $0x1,%edx
  800bf2:	0f af c6             	imul   %esi,%eax
  800bf5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bf8:	eb be                	jmp    800bb8 <strtol+0x8d>
  800bfa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c00:	74 05                	je     800c07 <strtol+0xdc>
		*endptr = (char *) s;
  800c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c0b:	74 04                	je     800c11 <strtol+0xe6>
  800c0d:	89 c8                	mov    %ecx,%eax
  800c0f:	f7 d8                	neg    %eax
}
  800c11:	83 c4 04             	add    $0x4,%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
  800c19:	00 00                	add    %al,(%eax)
	...

00800c1c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
  800c22:	89 1c 24             	mov    %ebx,(%esp)
  800c25:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	51                   	push   %ecx
  800c3a:	52                   	push   %edx
  800c3b:	53                   	push   %ebx
  800c3c:	54                   	push   %esp
  800c3d:	55                   	push   %ebp
  800c3e:	56                   	push   %esi
  800c3f:	57                   	push   %edi
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	8d 35 4a 0c 80 00    	lea    0x800c4a,%esi
  800c48:	0f 34                	sysenter 
  800c4a:	5f                   	pop    %edi
  800c4b:	5e                   	pop    %esi
  800c4c:	5d                   	pop    %ebp
  800c4d:	5c                   	pop    %esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5a                   	pop    %edx
  800c50:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c51:	8b 1c 24             	mov    (%esp),%ebx
  800c54:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c58:	89 ec                	mov    %ebp,%esp
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	51                   	push   %ecx
  800c79:	52                   	push   %edx
  800c7a:	53                   	push   %ebx
  800c7b:	54                   	push   %esp
  800c7c:	55                   	push   %ebp
  800c7d:	56                   	push   %esi
  800c7e:	57                   	push   %edi
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	8d 35 89 0c 80 00    	lea    0x800c89,%esi
  800c87:	0f 34                	sysenter 
  800c89:	5f                   	pop    %edi
  800c8a:	5e                   	pop    %esi
  800c8b:	5d                   	pop    %ebp
  800c8c:	5c                   	pop    %esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5a                   	pop    %edx
  800c8f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c90:	8b 1c 24             	mov    (%esp),%ebx
  800c93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c97:	89 ec                	mov    %ebp,%esp
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 08             	sub    $0x8,%esp
  800ca1:	89 1c 24             	mov    %ebx,(%esp)
  800ca4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ca8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cad:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 cb                	mov    %ecx,%ebx
  800cb7:	89 cf                	mov    %ecx,%edi
  800cb9:	51                   	push   %ecx
  800cba:	52                   	push   %edx
  800cbb:	53                   	push   %ebx
  800cbc:	54                   	push   %esp
  800cbd:	55                   	push   %ebp
  800cbe:	56                   	push   %esi
  800cbf:	57                   	push   %edi
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	8d 35 ca 0c 80 00    	lea    0x800cca,%esi
  800cc8:	0f 34                	sysenter 
  800cca:	5f                   	pop    %edi
  800ccb:	5e                   	pop    %esi
  800ccc:	5d                   	pop    %ebp
  800ccd:	5c                   	pop    %esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5a                   	pop    %edx
  800cd0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800cd1:	8b 1c 24             	mov    (%esp),%ebx
  800cd4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cd8:	89 ec                	mov    %ebp,%esp
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 28             	sub    $0x28,%esp
  800ce2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ce5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ced:	b8 0d 00 00 00       	mov    $0xd,%eax
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800d38:	e8 97 03 00 00       	call   8010d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d43:	89 ec                	mov    %ebp,%esp
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	89 1c 24             	mov    %ebx,(%esp)
  800d50:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	51                   	push   %ecx
  800d66:	52                   	push   %edx
  800d67:	53                   	push   %ebx
  800d68:	54                   	push   %esp
  800d69:	55                   	push   %ebp
  800d6a:	56                   	push   %esi
  800d6b:	57                   	push   %edi
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	8d 35 76 0d 80 00    	lea    0x800d76,%esi
  800d74:	0f 34                	sysenter 
  800d76:	5f                   	pop    %edi
  800d77:	5e                   	pop    %esi
  800d78:	5d                   	pop    %ebp
  800d79:	5c                   	pop    %esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5a                   	pop    %edx
  800d7c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7d:	8b 1c 24             	mov    (%esp),%ebx
  800d80:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d84:	89 ec                	mov    %ebp,%esp
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 28             	sub    $0x28,%esp
  800d8e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d91:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 df                	mov    %ebx,%edi
  800da6:	51                   	push   %ecx
  800da7:	52                   	push   %edx
  800da8:	53                   	push   %ebx
  800da9:	54                   	push   %esp
  800daa:	55                   	push   %ebp
  800dab:	56                   	push   %esi
  800dac:	57                   	push   %edi
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	8d 35 b7 0d 80 00    	lea    0x800db7,%esi
  800db5:	0f 34                	sysenter 
  800db7:	5f                   	pop    %edi
  800db8:	5e                   	pop    %esi
  800db9:	5d                   	pop    %ebp
  800dba:	5c                   	pop    %esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5a                   	pop    %edx
  800dbd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 28                	jle    800dea <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcd:	00 
  800dce:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ddd:	00 
  800dde:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800de5:	e8 ea 02 00 00       	call   8010d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dea:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ded:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df0:	89 ec                	mov    %ebp,%esp
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 28             	sub    $0x28,%esp
  800dfa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800dfd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	51                   	push   %ecx
  800e13:	52                   	push   %edx
  800e14:	53                   	push   %ebx
  800e15:	54                   	push   %esp
  800e16:	55                   	push   %ebp
  800e17:	56                   	push   %esi
  800e18:	57                   	push   %edi
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	8d 35 23 0e 80 00    	lea    0x800e23,%esi
  800e21:	0f 34                	sysenter 
  800e23:	5f                   	pop    %edi
  800e24:	5e                   	pop    %esi
  800e25:	5d                   	pop    %ebp
  800e26:	5c                   	pop    %esp
  800e27:	5b                   	pop    %ebx
  800e28:	5a                   	pop    %edx
  800e29:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	7e 28                	jle    800e56 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e32:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e39:	00 
  800e3a:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800e41:	00 
  800e42:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e49:	00 
  800e4a:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800e51:	e8 7e 02 00 00       	call   8010d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e56:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5c:	89 ec                	mov    %ebp,%esp
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 28             	sub    $0x28,%esp
  800e66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e69:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e71:	b8 07 00 00 00       	mov    $0x7,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	89 df                	mov    %ebx,%edi
  800e7e:	51                   	push   %ecx
  800e7f:	52                   	push   %edx
  800e80:	53                   	push   %ebx
  800e81:	54                   	push   %esp
  800e82:	55                   	push   %ebp
  800e83:	56                   	push   %esi
  800e84:	57                   	push   %edi
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	8d 35 8f 0e 80 00    	lea    0x800e8f,%esi
  800e8d:	0f 34                	sysenter 
  800e8f:	5f                   	pop    %edi
  800e90:	5e                   	pop    %esi
  800e91:	5d                   	pop    %ebp
  800e92:	5c                   	pop    %esp
  800e93:	5b                   	pop    %ebx
  800e94:	5a                   	pop    %edx
  800e95:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 28                	jle    800ec2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800ead:	00 
  800eae:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800eb5:	00 
  800eb6:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800ebd:	e8 12 02 00 00       	call   8010d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ec5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 28             	sub    $0x28,%esp
  800ed2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ed5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed8:	b8 06 00 00 00       	mov    $0x6,%eax
  800edd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	51                   	push   %ecx
  800eea:	52                   	push   %edx
  800eeb:	53                   	push   %ebx
  800eec:	54                   	push   %esp
  800eed:	55                   	push   %ebp
  800eee:	56                   	push   %esi
  800eef:	57                   	push   %edi
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	8d 35 fa 0e 80 00    	lea    0x800efa,%esi
  800ef8:	0f 34                	sysenter 
  800efa:	5f                   	pop    %edi
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	5c                   	pop    %esp
  800efe:	5b                   	pop    %ebx
  800eff:	5a                   	pop    %edx
  800f00:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 28                	jle    800f2d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f09:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f10:	00 
  800f11:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800f28:	e8 a7 01 00 00       	call   8010d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f2d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f33:	89 ec                	mov    %ebp,%esp
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 28             	sub    $0x28,%esp
  800f3d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f40:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f43:	bf 00 00 00 00       	mov    $0x0,%edi
  800f48:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	51                   	push   %ecx
  800f57:	52                   	push   %edx
  800f58:	53                   	push   %ebx
  800f59:	54                   	push   %esp
  800f5a:	55                   	push   %ebp
  800f5b:	56                   	push   %esi
  800f5c:	57                   	push   %edi
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	8d 35 67 0f 80 00    	lea    0x800f67,%esi
  800f65:	0f 34                	sysenter 
  800f67:	5f                   	pop    %edi
  800f68:	5e                   	pop    %esi
  800f69:	5d                   	pop    %ebp
  800f6a:	5c                   	pop    %esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5a                   	pop    %edx
  800f6d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 28                	jle    800f9a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f76:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f85:	00 
  800f86:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f8d:	00 
  800f8e:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800f95:	e8 3a 01 00 00       	call   8010d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f9a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa0:	89 ec                	mov    %ebp,%esp
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 08             	sub    $0x8,%esp
  800faa:	89 1c 24             	mov    %ebx,(%esp)
  800fad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fbb:	89 d1                	mov    %edx,%ecx
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	89 d7                	mov    %edx,%edi
  800fc1:	51                   	push   %ecx
  800fc2:	52                   	push   %edx
  800fc3:	53                   	push   %ebx
  800fc4:	54                   	push   %esp
  800fc5:	55                   	push   %ebp
  800fc6:	56                   	push   %esi
  800fc7:	57                   	push   %edi
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	8d 35 d2 0f 80 00    	lea    0x800fd2,%esi
  800fd0:	0f 34                	sysenter 
  800fd2:	5f                   	pop    %edi
  800fd3:	5e                   	pop    %esi
  800fd4:	5d                   	pop    %ebp
  800fd5:	5c                   	pop    %esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5a                   	pop    %edx
  800fd8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fd9:	8b 1c 24             	mov    (%esp),%ebx
  800fdc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe0:	89 ec                	mov    %ebp,%esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  800ff1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 df                	mov    %ebx,%edi
  801003:	51                   	push   %ecx
  801004:	52                   	push   %edx
  801005:	53                   	push   %ebx
  801006:	54                   	push   %esp
  801007:	55                   	push   %ebp
  801008:	56                   	push   %esi
  801009:	57                   	push   %edi
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	8d 35 14 10 80 00    	lea    0x801014,%esi
  801012:	0f 34                	sysenter 
  801014:	5f                   	pop    %edi
  801015:	5e                   	pop    %esi
  801016:	5d                   	pop    %ebp
  801017:	5c                   	pop    %esp
  801018:	5b                   	pop    %ebx
  801019:	5a                   	pop    %edx
  80101a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80101b:	8b 1c 24             	mov    (%esp),%ebx
  80101e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801022:	89 ec                	mov    %ebp,%esp
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	89 1c 24             	mov    %ebx,(%esp)
  80102f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801033:	ba 00 00 00 00       	mov    $0x0,%edx
  801038:	b8 02 00 00 00       	mov    $0x2,%eax
  80103d:	89 d1                	mov    %edx,%ecx
  80103f:	89 d3                	mov    %edx,%ebx
  801041:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80105b:	8b 1c 24             	mov    (%esp),%ebx
  80105e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801062:	89 ec                	mov    %ebp,%esp
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 28             	sub    $0x28,%esp
  80106c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80106f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801072:	b9 00 00 00 00       	mov    $0x0,%ecx
  801077:	b8 03 00 00 00       	mov    $0x3,%eax
  80107c:	8b 55 08             	mov    0x8(%ebp),%edx
  80107f:	89 cb                	mov    %ecx,%ebx
  801081:	89 cf                	mov    %ecx,%edi
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 28                	jle    8010c7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  8010c2:	e8 0d 00 00 00       	call   8010d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010c7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cd:	89 ec                	mov    %ebp,%esp
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    
  8010d1:	00 00                	add    %al,(%eax)
	...

008010d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8010dc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8010df:	a1 08 20 80 00       	mov    0x802008,%eax
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	74 10                	je     8010f8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8010e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ec:	c7 04 24 6f 16 80 00 	movl   $0x80166f,(%esp)
  8010f3:	e8 55 f0 ff ff       	call   80014d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010f8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8010fe:	e8 23 ff ff ff       	call   801026 <sys_getenvid>
  801103:	8b 55 0c             	mov    0xc(%ebp),%edx
  801106:	89 54 24 10          	mov    %edx,0x10(%esp)
  80110a:	8b 55 08             	mov    0x8(%ebp),%edx
  80110d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801111:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801115:	89 44 24 04          	mov    %eax,0x4(%esp)
  801119:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  801120:	e8 28 f0 ff ff       	call   80014d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801125:	89 74 24 04          	mov    %esi,0x4(%esp)
  801129:	8b 45 10             	mov    0x10(%ebp),%eax
  80112c:	89 04 24             	mov    %eax,(%esp)
  80112f:	e8 b8 ef ff ff       	call   8000ec <vcprintf>
	cprintf("\n");
  801134:	c7 04 24 d6 13 80 00 	movl   $0x8013d6,(%esp)
  80113b:	e8 0d f0 ff ff       	call   80014d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801140:	cc                   	int3   
  801141:	eb fd                	jmp    801140 <_panic+0x6c>
	...

00801150 <__udivdi3>:
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	83 ec 10             	sub    $0x10,%esp
  801158:	8b 45 14             	mov    0x14(%ebp),%eax
  80115b:	8b 55 08             	mov    0x8(%ebp),%edx
  80115e:	8b 75 10             	mov    0x10(%ebp),%esi
  801161:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801164:	85 c0                	test   %eax,%eax
  801166:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801169:	75 35                	jne    8011a0 <__udivdi3+0x50>
  80116b:	39 fe                	cmp    %edi,%esi
  80116d:	77 61                	ja     8011d0 <__udivdi3+0x80>
  80116f:	85 f6                	test   %esi,%esi
  801171:	75 0b                	jne    80117e <__udivdi3+0x2e>
  801173:	b8 01 00 00 00       	mov    $0x1,%eax
  801178:	31 d2                	xor    %edx,%edx
  80117a:	f7 f6                	div    %esi
  80117c:	89 c6                	mov    %eax,%esi
  80117e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801181:	31 d2                	xor    %edx,%edx
  801183:	89 f8                	mov    %edi,%eax
  801185:	f7 f6                	div    %esi
  801187:	89 c7                	mov    %eax,%edi
  801189:	89 c8                	mov    %ecx,%eax
  80118b:	f7 f6                	div    %esi
  80118d:	89 c1                	mov    %eax,%ecx
  80118f:	89 fa                	mov    %edi,%edx
  801191:	89 c8                	mov    %ecx,%eax
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
  80119a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a0:	39 f8                	cmp    %edi,%eax
  8011a2:	77 1c                	ja     8011c0 <__udivdi3+0x70>
  8011a4:	0f bd d0             	bsr    %eax,%edx
  8011a7:	83 f2 1f             	xor    $0x1f,%edx
  8011aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011ad:	75 39                	jne    8011e8 <__udivdi3+0x98>
  8011af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8011b2:	0f 86 a0 00 00 00    	jbe    801258 <__udivdi3+0x108>
  8011b8:	39 f8                	cmp    %edi,%eax
  8011ba:	0f 82 98 00 00 00    	jb     801258 <__udivdi3+0x108>
  8011c0:	31 ff                	xor    %edi,%edi
  8011c2:	31 c9                	xor    %ecx,%ecx
  8011c4:	89 c8                	mov    %ecx,%eax
  8011c6:	89 fa                	mov    %edi,%edx
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    
  8011cf:	90                   	nop
  8011d0:	89 d1                	mov    %edx,%ecx
  8011d2:	89 fa                	mov    %edi,%edx
  8011d4:	89 c8                	mov    %ecx,%eax
  8011d6:	31 ff                	xor    %edi,%edi
  8011d8:	f7 f6                	div    %esi
  8011da:	89 c1                	mov    %eax,%ecx
  8011dc:	89 fa                	mov    %edi,%edx
  8011de:	89 c8                	mov    %ecx,%eax
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    
  8011e7:	90                   	nop
  8011e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ec:	89 f2                	mov    %esi,%edx
  8011ee:	d3 e0                	shl    %cl,%eax
  8011f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011fb:	89 c1                	mov    %eax,%ecx
  8011fd:	d3 ea                	shr    %cl,%edx
  8011ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801203:	0b 55 ec             	or     -0x14(%ebp),%edx
  801206:	d3 e6                	shl    %cl,%esi
  801208:	89 c1                	mov    %eax,%ecx
  80120a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80120d:	89 fe                	mov    %edi,%esi
  80120f:	d3 ee                	shr    %cl,%esi
  801211:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801215:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801218:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80121b:	d3 e7                	shl    %cl,%edi
  80121d:	89 c1                	mov    %eax,%ecx
  80121f:	d3 ea                	shr    %cl,%edx
  801221:	09 d7                	or     %edx,%edi
  801223:	89 f2                	mov    %esi,%edx
  801225:	89 f8                	mov    %edi,%eax
  801227:	f7 75 ec             	divl   -0x14(%ebp)
  80122a:	89 d6                	mov    %edx,%esi
  80122c:	89 c7                	mov    %eax,%edi
  80122e:	f7 65 e8             	mull   -0x18(%ebp)
  801231:	39 d6                	cmp    %edx,%esi
  801233:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801236:	72 30                	jb     801268 <__udivdi3+0x118>
  801238:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80123b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80123f:	d3 e2                	shl    %cl,%edx
  801241:	39 c2                	cmp    %eax,%edx
  801243:	73 05                	jae    80124a <__udivdi3+0xfa>
  801245:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801248:	74 1e                	je     801268 <__udivdi3+0x118>
  80124a:	89 f9                	mov    %edi,%ecx
  80124c:	31 ff                	xor    %edi,%edi
  80124e:	e9 71 ff ff ff       	jmp    8011c4 <__udivdi3+0x74>
  801253:	90                   	nop
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	31 ff                	xor    %edi,%edi
  80125a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80125f:	e9 60 ff ff ff       	jmp    8011c4 <__udivdi3+0x74>
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80126b:	31 ff                	xor    %edi,%edi
  80126d:	89 c8                	mov    %ecx,%eax
  80126f:	89 fa                	mov    %edi,%edx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
	...

00801280 <__umoddi3>:
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	83 ec 20             	sub    $0x20,%esp
  801288:	8b 55 14             	mov    0x14(%ebp),%edx
  80128b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801291:	8b 75 0c             	mov    0xc(%ebp),%esi
  801294:	85 d2                	test   %edx,%edx
  801296:	89 c8                	mov    %ecx,%eax
  801298:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80129b:	75 13                	jne    8012b0 <__umoddi3+0x30>
  80129d:	39 f7                	cmp    %esi,%edi
  80129f:	76 3f                	jbe    8012e0 <__umoddi3+0x60>
  8012a1:	89 f2                	mov    %esi,%edx
  8012a3:	f7 f7                	div    %edi
  8012a5:	89 d0                	mov    %edx,%eax
  8012a7:	31 d2                	xor    %edx,%edx
  8012a9:	83 c4 20             	add    $0x20,%esp
  8012ac:	5e                   	pop    %esi
  8012ad:	5f                   	pop    %edi
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    
  8012b0:	39 f2                	cmp    %esi,%edx
  8012b2:	77 4c                	ja     801300 <__umoddi3+0x80>
  8012b4:	0f bd ca             	bsr    %edx,%ecx
  8012b7:	83 f1 1f             	xor    $0x1f,%ecx
  8012ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8012bd:	75 51                	jne    801310 <__umoddi3+0x90>
  8012bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8012c2:	0f 87 e0 00 00 00    	ja     8013a8 <__umoddi3+0x128>
  8012c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cb:	29 f8                	sub    %edi,%eax
  8012cd:	19 d6                	sbb    %edx,%esi
  8012cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d5:	89 f2                	mov    %esi,%edx
  8012d7:	83 c4 20             	add    $0x20,%esp
  8012da:	5e                   	pop    %esi
  8012db:	5f                   	pop    %edi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    
  8012de:	66 90                	xchg   %ax,%ax
  8012e0:	85 ff                	test   %edi,%edi
  8012e2:	75 0b                	jne    8012ef <__umoddi3+0x6f>
  8012e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012e9:	31 d2                	xor    %edx,%edx
  8012eb:	f7 f7                	div    %edi
  8012ed:	89 c7                	mov    %eax,%edi
  8012ef:	89 f0                	mov    %esi,%eax
  8012f1:	31 d2                	xor    %edx,%edx
  8012f3:	f7 f7                	div    %edi
  8012f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f8:	f7 f7                	div    %edi
  8012fa:	eb a9                	jmp    8012a5 <__umoddi3+0x25>
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	89 c8                	mov    %ecx,%eax
  801302:	89 f2                	mov    %esi,%edx
  801304:	83 c4 20             	add    $0x20,%esp
  801307:	5e                   	pop    %esi
  801308:	5f                   	pop    %edi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    
  80130b:	90                   	nop
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801314:	d3 e2                	shl    %cl,%edx
  801316:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801319:	ba 20 00 00 00       	mov    $0x20,%edx
  80131e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801321:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801324:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801328:	89 fa                	mov    %edi,%edx
  80132a:	d3 ea                	shr    %cl,%edx
  80132c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801330:	0b 55 f4             	or     -0xc(%ebp),%edx
  801333:	d3 e7                	shl    %cl,%edi
  801335:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801339:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80133c:	89 f2                	mov    %esi,%edx
  80133e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801341:	89 c7                	mov    %eax,%edi
  801343:	d3 ea                	shr    %cl,%edx
  801345:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801349:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	d3 e6                	shl    %cl,%esi
  801350:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801354:	d3 ea                	shr    %cl,%edx
  801356:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80135a:	09 d6                	or     %edx,%esi
  80135c:	89 f0                	mov    %esi,%eax
  80135e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801361:	d3 e7                	shl    %cl,%edi
  801363:	89 f2                	mov    %esi,%edx
  801365:	f7 75 f4             	divl   -0xc(%ebp)
  801368:	89 d6                	mov    %edx,%esi
  80136a:	f7 65 e8             	mull   -0x18(%ebp)
  80136d:	39 d6                	cmp    %edx,%esi
  80136f:	72 2b                	jb     80139c <__umoddi3+0x11c>
  801371:	39 c7                	cmp    %eax,%edi
  801373:	72 23                	jb     801398 <__umoddi3+0x118>
  801375:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801379:	29 c7                	sub    %eax,%edi
  80137b:	19 d6                	sbb    %edx,%esi
  80137d:	89 f0                	mov    %esi,%eax
  80137f:	89 f2                	mov    %esi,%edx
  801381:	d3 ef                	shr    %cl,%edi
  801383:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801387:	d3 e0                	shl    %cl,%eax
  801389:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80138d:	09 f8                	or     %edi,%eax
  80138f:	d3 ea                	shr    %cl,%edx
  801391:	83 c4 20             	add    $0x20,%esp
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    
  801398:	39 d6                	cmp    %edx,%esi
  80139a:	75 d9                	jne    801375 <__umoddi3+0xf5>
  80139c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80139f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8013a2:	eb d1                	jmp    801375 <__umoddi3+0xf5>
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	39 f2                	cmp    %esi,%edx
  8013aa:	0f 82 18 ff ff ff    	jb     8012c8 <__umoddi3+0x48>
  8013b0:	e9 1d ff ff ff       	jmp    8012d2 <__umoddi3+0x52>
