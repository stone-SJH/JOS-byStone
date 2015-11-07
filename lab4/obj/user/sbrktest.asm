
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 9f 00 00 00       	call   8000d0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800044:	e8 a2 0c 00 00       	call   800ceb <sys_sbrk>
  800049:	89 c6                	mov    %eax,%esi
	end = sys_sbrk(ALLOCATE_SIZE);
  80004b:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  800052:	e8 94 0c 00 00       	call   800ceb <sys_sbrk>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("start:%08x, end:%08x\n", start, end);
  800059:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800061:	c7 04 24 20 14 80 00 	movl   $0x801420,(%esp)
  800068:	e8 28 01 00 00       	call   800195 <cprintf>
	if (end - start < ALLOCATE_SIZE) {
  80006d:	29 f3                	sub    %esi,%ebx
  80006f:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
  800075:	77 0c                	ja     800083 <umain+0x4f>
		cprintf("sbrk not correctly implemented\n");
  800077:	c7 04 24 48 14 80 00 	movl   $0x801448,(%esp)
  80007e:	e8 12 01 00 00       	call   800195 <cprintf>
	}
	s = (char *) start;
  800083:	89 f7                	mov    %esi,%edi
  800085:	b9 00 00 00 00       	mov    $0x0,%ecx
	for ( i = 0; i < STRING_SIZE; i++) {
		s[i] = 'A' + (i % 26);
  80008a:	bb 4f ec c4 4e       	mov    $0x4ec4ec4f,%ebx
  80008f:	89 c8                	mov    %ecx,%eax
  800091:	f7 eb                	imul   %ebx
  800093:	c1 fa 03             	sar    $0x3,%edx
  800096:	89 c8                	mov    %ecx,%eax
  800098:	c1 f8 1f             	sar    $0x1f,%eax
  80009b:	29 c2                	sub    %eax,%edx
  80009d:	6b c2 1a             	imul   $0x1a,%edx,%eax
  8000a0:	89 ca                	mov    %ecx,%edx
  8000a2:	29 c2                	sub    %eax,%edx
  8000a4:	89 d0                	mov    %edx,%eax
  8000a6:	83 c0 41             	add    $0x41,%eax
  8000a9:	88 04 31             	mov    %al,(%ecx,%esi,1)
	cprintf("start:%08x, end:%08x\n", start, end);
	if (end - start < ALLOCATE_SIZE) {
		cprintf("sbrk not correctly implemented\n");
	}
	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  8000ac:	83 c1 01             	add    $0x1,%ecx
  8000af:	83 f9 40             	cmp    $0x40,%ecx
  8000b2:	75 db                	jne    80008f <umain+0x5b>
		s[i] = 'A' + (i % 26);
	}
	s[STRING_SIZE] = '\0';
  8000b4:	c6 47 40 00          	movb   $0x0,0x40(%edi)
	
	cprintf("SBRK_TEST(%s)\n", s);
  8000b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000bc:	c7 04 24 36 14 80 00 	movl   $0x801436,(%esp)
  8000c3:	e8 cd 00 00 00       	call   800195 <cprintf>
}
  8000c8:	83 c4 1c             	add    $0x1c,%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5f                   	pop    %edi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 18             	sub    $0x18,%esp
  8000d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000d9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  8000e2:	e8 8f 0f 00 00       	call   801076 <sys_getenvid>
  8000e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ec:	c1 e0 07             	shl    $0x7,%eax
  8000ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f4:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f9:	85 f6                	test   %esi,%esi
  8000fb:	7e 07                	jle    800104 <libmain+0x34>
		binaryname = argv[0];
  8000fd:	8b 03                	mov    (%ebx),%eax
  8000ff:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800104:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800108:	89 34 24             	mov    %esi,(%esp)
  80010b:	e8 24 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800110:	e8 0b 00 00 00       	call   800120 <exit>
}
  800115:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800118:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    
	...

00800120 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800126:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012d:	e8 84 0f 00 00       	call   8010b6 <sys_env_destroy>
}
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	8b 45 0c             	mov    0xc(%ebp),%eax
  800154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800158:	8b 45 08             	mov    0x8(%ebp),%eax
  80015b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	c7 04 24 af 01 80 00 	movl   $0x8001af,(%esp)
  800170:	e8 d8 01 00 00       	call   80034d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800175:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 1f 0b 00 00       	call   800cac <sys_cputs>

	return b.cnt;
}
  80018d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 04 24             	mov    %eax,(%esp)
  8001a8:	e8 87 ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 14             	sub    $0x14,%esp
  8001b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b9:	8b 03                	mov    (%ebx),%eax
  8001bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001be:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c2:	83 c0 01             	add    $0x1,%eax
  8001c5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cc:	75 19                	jne    8001e7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ce:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d5:	00 
  8001d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 cb 0a 00 00       	call   800cac <sys_cputs>
		b->idx = 0;
  8001e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001eb:	83 c4 14             	add    $0x14,%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
	...

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 4c             	sub    $0x4c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d6                	mov    %edx,%esi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80021a:	8b 45 10             	mov    0x10(%ebp),%eax
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800220:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80022b:	39 d1                	cmp    %edx,%ecx
  80022d:	72 15                	jb     800244 <printnum+0x44>
  80022f:	77 07                	ja     800238 <printnum+0x38>
  800231:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800234:	39 d0                	cmp    %edx,%eax
  800236:	76 0c                	jbe    800244 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	7f 61                	jg     8002a3 <printnum+0xa3>
  800242:	eb 70                	jmp    8002b4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800248:	83 eb 01             	sub    $0x1,%ebx
  80024b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800257:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80025b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80025e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800261:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800264:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800279:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027d:	e8 1e 0f 00 00       	call   8011a0 <__udivdi3>
  800282:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800285:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	89 54 24 04          	mov    %edx,0x4(%esp)
  800297:	89 f2                	mov    %esi,%edx
  800299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029c:	e8 5f ff ff ff       	call   800200 <printnum>
  8002a1:	eb 11                	jmp    8002b4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a7:	89 3c 24             	mov    %edi,(%esp)
  8002aa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ad:	83 eb 01             	sub    $0x1,%ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ef                	jg     8002a3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ca:	00 
  8002cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ce:	89 14 24             	mov    %edx,(%esp)
  8002d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002d8:	e8 f3 0f 00 00       	call   8012d0 <__umoddi3>
  8002dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e1:	0f be 80 72 14 80 00 	movsbl 0x801472(%eax),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ee:	83 c4 4c             	add    $0x4c,%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f9:	83 fa 01             	cmp    $0x1,%edx
  8002fc:	7e 0e                	jle    80030c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	eb 22                	jmp    80032e <getuint+0x38>
	else if (lflag)
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 10                	je     800320 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 0e                	jmp    80032e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	3b 50 04             	cmp    0x4(%eax),%edx
  80033f:	73 0a                	jae    80034b <sprintputch+0x1b>
		*b->buf++ = ch;
  800341:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800344:	88 0a                	mov    %cl,(%edx)
  800346:	83 c2 01             	add    $0x1,%edx
  800349:	89 10                	mov    %edx,(%eax)
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 5c             	sub    $0x5c,%esp
  800356:	8b 7d 08             	mov    0x8(%ebp),%edi
  800359:	8b 75 0c             	mov    0xc(%ebp),%esi
  80035c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80035f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800366:	eb 11                	jmp    800379 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800368:	85 c0                	test   %eax,%eax
  80036a:	0f 84 09 04 00 00    	je     800779 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800370:	89 74 24 04          	mov    %esi,0x4(%esp)
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	0f b6 03             	movzbl (%ebx),%eax
  80037c:	83 c3 01             	add    $0x1,%ebx
  80037f:	83 f8 25             	cmp    $0x25,%eax
  800382:	75 e4                	jne    800368 <vprintfmt+0x1b>
  800384:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800388:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80038f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800396:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	eb 06                	jmp    8003aa <vprintfmt+0x5d>
  8003a4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003a8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	0f b6 13             	movzbl (%ebx),%edx
  8003ad:	0f b6 c2             	movzbl %dl,%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003b6:	83 ea 23             	sub    $0x23,%edx
  8003b9:	80 fa 55             	cmp    $0x55,%dl
  8003bc:	0f 87 9a 03 00 00    	ja     80075c <vprintfmt+0x40f>
  8003c2:	0f b6 d2             	movzbl %dl,%edx
  8003c5:	ff 24 95 40 15 80 00 	jmp    *0x801540(,%edx,4)
  8003cc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d0:	eb d6                	jmp    8003a8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d5:	83 ea 30             	sub    $0x30,%edx
  8003d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003de:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003e1:	83 fb 09             	cmp    $0x9,%ebx
  8003e4:	77 4c                	ja     800432 <vprintfmt+0xe5>
  8003e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003ef:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003f2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003f6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003f9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003fc:	83 fb 09             	cmp    $0x9,%ebx
  8003ff:	76 eb                	jbe    8003ec <vprintfmt+0x9f>
  800401:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800404:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800407:	eb 29                	jmp    800432 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800409:	8b 55 14             	mov    0x14(%ebp),%edx
  80040c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80040f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800412:	8b 12                	mov    (%edx),%edx
  800414:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800417:	eb 19                	jmp    800432 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800419:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041c:	c1 fa 1f             	sar    $0x1f,%edx
  80041f:	f7 d2                	not    %edx
  800421:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800424:	eb 82                	jmp    8003a8 <vprintfmt+0x5b>
  800426:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80042d:	e9 76 ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800432:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800436:	0f 89 6c ff ff ff    	jns    8003a8 <vprintfmt+0x5b>
  80043c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80043f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800442:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800445:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800448:	e9 5b ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800450:	e9 53 ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	89 74 24 04          	mov    %esi,0x4(%esp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	ff d7                	call   *%edi
  80046c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80046f:	e9 05 ff ff ff       	jmp    800379 <vprintfmt+0x2c>
  800474:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	8b 00                	mov    (%eax),%eax
  800482:	89 c2                	mov    %eax,%edx
  800484:	c1 fa 1f             	sar    $0x1f,%edx
  800487:	31 d0                	xor    %edx,%eax
  800489:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 08             	cmp    $0x8,%eax
  80048e:	7f 0b                	jg     80049b <vprintfmt+0x14e>
  800490:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	75 20                	jne    8004bb <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80049b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049f:	c7 44 24 08 83 14 80 	movl   $0x801483,0x8(%esp)
  8004a6:	00 
  8004a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ab:	89 3c 24             	mov    %edi,(%esp)
  8004ae:	e8 4e 03 00 00       	call   800801 <printfmt>
  8004b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b6:	e9 be fe ff ff       	jmp    800379 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 8c 14 80 	movl   $0x80148c,0x8(%esp)
  8004c6:	00 
  8004c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cb:	89 3c 24             	mov    %edi,(%esp)
  8004ce:	e8 2e 03 00 00       	call   800801 <printfmt>
  8004d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d6:	e9 9e fe ff ff       	jmp    800379 <vprintfmt+0x2c>
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 c3                	mov    %eax,%ebx
  8004e0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 00                	mov    (%eax),%eax
  8004f4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 07                	jne    800502 <vprintfmt+0x1b5>
  8004fb:	c7 45 c4 8f 14 80 00 	movl   $0x80148f,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800502:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800506:	7e 06                	jle    80050e <vprintfmt+0x1c1>
  800508:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80050c:	75 13                	jne    800521 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800511:	0f be 02             	movsbl (%edx),%eax
  800514:	85 c0                	test   %eax,%eax
  800516:	0f 85 99 00 00 00    	jne    8005b5 <vprintfmt+0x268>
  80051c:	e9 86 00 00 00       	jmp    8005a7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800525:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800528:	89 0c 24             	mov    %ecx,(%esp)
  80052b:	e8 1b 03 00 00       	call   80084b <strnlen>
  800530:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800533:	29 c2                	sub    %eax,%edx
  800535:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800538:	85 d2                	test   %edx,%edx
  80053a:	7e d2                	jle    80050e <vprintfmt+0x1c1>
					putch(padc, putdat);
  80053c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800543:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800546:	89 d3                	mov    %edx,%ebx
  800548:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	85 db                	test   %ebx,%ebx
  800559:	7f ed                	jg     800548 <vprintfmt+0x1fb>
  80055b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80055e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800565:	eb a7                	jmp    80050e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800567:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80056b:	74 18                	je     800585 <vprintfmt+0x238>
  80056d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800570:	83 fa 5e             	cmp    $0x5e,%edx
  800573:	76 10                	jbe    800585 <vprintfmt+0x238>
					putch('?', putdat);
  800575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800579:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800580:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800583:	eb 0a                	jmp    80058f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800585:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800589:	89 04 24             	mov    %eax,(%esp)
  80058c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800593:	0f be 03             	movsbl (%ebx),%eax
  800596:	85 c0                	test   %eax,%eax
  800598:	74 05                	je     80059f <vprintfmt+0x252>
  80059a:	83 c3 01             	add    $0x1,%ebx
  80059d:	eb 29                	jmp    8005c8 <vprintfmt+0x27b>
  80059f:	89 fe                	mov    %edi,%esi
  8005a1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005a4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ab:	7f 2e                	jg     8005db <vprintfmt+0x28e>
  8005ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b0:	e9 c4 fd ff ff       	jmp    800379 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005b8:	83 c2 01             	add    $0x1,%edx
  8005bb:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005be:	89 f7                	mov    %esi,%edi
  8005c0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005c6:	89 d3                	mov    %edx,%ebx
  8005c8:	85 f6                	test   %esi,%esi
  8005ca:	78 9b                	js     800567 <vprintfmt+0x21a>
  8005cc:	83 ee 01             	sub    $0x1,%esi
  8005cf:	79 96                	jns    800567 <vprintfmt+0x21a>
  8005d1:	89 fe                	mov    %edi,%esi
  8005d3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005d9:	eb cc                	jmp    8005a7 <vprintfmt+0x25a>
  8005db:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005de:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ec:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ee:	83 eb 01             	sub    $0x1,%ebx
  8005f1:	85 db                	test   %ebx,%ebx
  8005f3:	7f ec                	jg     8005e1 <vprintfmt+0x294>
  8005f5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f8:	e9 7c fd ff ff       	jmp    800379 <vprintfmt+0x2c>
  8005fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7e 16                	jle    80061b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 08             	lea    0x8(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8b 48 04             	mov    0x4(%eax),%ecx
  800613:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800616:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800619:	eb 32                	jmp    80064d <vprintfmt+0x300>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 18                	je     800637 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80062d:	89 c1                	mov    %eax,%ecx
  80062f:	c1 f9 1f             	sar    $0x1f,%ecx
  800632:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800635:	eb 16                	jmp    80064d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800645:	89 c2                	mov    %eax,%edx
  800647:	c1 fa 1f             	sar    $0x1f,%edx
  80064a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800650:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800653:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800658:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80065c:	0f 89 b8 00 00 00    	jns    80071a <vprintfmt+0x3cd>
				putch('-', putdat);
  800662:	89 74 24 04          	mov    %esi,0x4(%esp)
  800666:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066d:	ff d7                	call   *%edi
				num = -(long long) num;
  80066f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800672:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800675:	f7 d9                	neg    %ecx
  800677:	83 d3 00             	adc    $0x0,%ebx
  80067a:	f7 db                	neg    %ebx
  80067c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800681:	e9 94 00 00 00       	jmp    80071a <vprintfmt+0x3cd>
  800686:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 63 fc ff ff       	call   8002f6 <getuint>
  800693:	89 c1                	mov    %eax,%ecx
  800695:	89 d3                	mov    %edx,%ebx
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80069c:	eb 7c                	jmp    80071a <vprintfmt+0x3cd>
  80069e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ac:	ff d7                	call   *%edi
			putch('X', putdat);
  8006ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b9:	ff d7                	call   *%edi
			putch('X', putdat);
  8006bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bf:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006c6:	ff d7                	call   *%edi
  8006c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006cb:	e9 a9 fc ff ff       	jmp    800379 <vprintfmt+0x2c>
  8006d0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006de:	ff d7                	call   *%edi
			putch('x', putdat);
  8006e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006eb:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f6:	8b 08                	mov    (%eax),%ecx
  8006f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800702:	eb 16                	jmp    80071a <vprintfmt+0x3cd>
  800704:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800707:	89 ca                	mov    %ecx,%edx
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
  80070c:	e8 e5 fb ff ff       	call   8002f6 <getuint>
  800711:	89 c1                	mov    %eax,%ecx
  800713:	89 d3                	mov    %edx,%ebx
  800715:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80071e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800722:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800725:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800729:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072d:	89 0c 24             	mov    %ecx,(%esp)
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	89 f2                	mov    %esi,%edx
  800736:	89 f8                	mov    %edi,%eax
  800738:	e8 c3 fa ff ff       	call   800200 <printnum>
  80073d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800740:	e9 34 fc ff ff       	jmp    800379 <vprintfmt+0x2c>
  800745:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800748:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074f:	89 14 24             	mov    %edx,(%esp)
  800752:	ff d7                	call   *%edi
  800754:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800757:	e9 1d fc ff ff       	jmp    800379 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800760:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800767:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800769:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80076c:	80 38 25             	cmpb   $0x25,(%eax)
  80076f:	0f 84 04 fc ff ff    	je     800379 <vprintfmt+0x2c>
  800775:	89 c3                	mov    %eax,%ebx
  800777:	eb f0                	jmp    800769 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800779:	83 c4 5c             	add    $0x5c,%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5f                   	pop    %edi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 28             	sub    $0x28,%esp
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 04                	je     800795 <vsnprintf+0x14>
  800791:	85 d2                	test   %edx,%edx
  800793:	7f 07                	jg     80079c <vsnprintf+0x1b>
  800795:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079a:	eb 3b                	jmp    8007d7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c2:	c7 04 24 30 03 80 00 	movl   $0x800330,(%esp)
  8007c9:	e8 7f fb ff ff       	call   80034d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	89 04 24             	mov    %eax,(%esp)
  8007fa:	e8 82 ff ff ff       	call   800781 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8b 45 0c             	mov    0xc(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	e8 26 fb ff ff       	call   80034d <vprintfmt>
	va_end(ap);
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    
  800829:	00 00                	add    %al,(%eax)
  80082b:	00 00                	add    %al,(%eax)
  80082d:	00 00                	add    %al,(%eax)
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	80 3a 00             	cmpb   $0x0,(%edx)
  80083e:	74 09                	je     800849 <strlen+0x19>
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
		n++;
	return n;
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	74 19                	je     800872 <strnlen+0x27>
  800859:	80 3b 00             	cmpb   $0x0,(%ebx)
  80085c:	74 14                	je     800872 <strnlen+0x27>
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800866:	39 c8                	cmp    %ecx,%eax
  800868:	74 0d                	je     800877 <strnlen+0x2c>
  80086a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80086e:	75 f3                	jne    800863 <strnlen+0x18>
  800870:	eb 05                	jmp    800877 <strnlen+0x2c>
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800884:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800889:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80088d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	84 c9                	test   %cl,%cl
  800895:	75 f2                	jne    800889 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a4:	89 1c 24             	mov    %ebx,(%esp)
  8008a7:	e8 84 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 bc ff ff ff       	call   80087a <strcpy>
	return dst;
}
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	83 c4 08             	add    $0x8,%esp
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d4:	85 f6                	test   %esi,%esi
  8008d6:	74 18                	je     8008f0 <strncpy+0x2a>
  8008d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	39 ce                	cmp    %ecx,%esi
  8008ee:	77 ed                	ja     8008dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800902:	89 f0                	mov    %esi,%eax
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 27                	je     80092f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800908:	83 e9 01             	sub    $0x1,%ecx
  80090b:	74 1d                	je     80092a <strlcpy+0x36>
  80090d:	0f b6 1a             	movzbl (%edx),%ebx
  800910:	84 db                	test   %bl,%bl
  800912:	74 16                	je     80092a <strlcpy+0x36>
			*dst++ = *src++;
  800914:	88 18                	mov    %bl,(%eax)
  800916:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800919:	83 e9 01             	sub    $0x1,%ecx
  80091c:	74 0e                	je     80092c <strlcpy+0x38>
			*dst++ = *src++;
  80091e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800921:	0f b6 1a             	movzbl (%edx),%ebx
  800924:	84 db                	test   %bl,%bl
  800926:	75 ec                	jne    800914 <strlcpy+0x20>
  800928:	eb 02                	jmp    80092c <strlcpy+0x38>
  80092a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092c:	c6 00 00             	movb   $0x0,(%eax)
  80092f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093e:	0f b6 01             	movzbl (%ecx),%eax
  800941:	84 c0                	test   %al,%al
  800943:	74 15                	je     80095a <strcmp+0x25>
  800945:	3a 02                	cmp    (%edx),%al
  800947:	75 11                	jne    80095a <strcmp+0x25>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x25>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0x14>
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 55 08             	mov    0x8(%ebp),%edx
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800971:	85 c0                	test   %eax,%eax
  800973:	74 23                	je     800998 <strncmp+0x34>
  800975:	0f b6 1a             	movzbl (%edx),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	74 25                	je     8009a1 <strncmp+0x3d>
  80097c:	3a 19                	cmp    (%ecx),%bl
  80097e:	75 21                	jne    8009a1 <strncmp+0x3d>
  800980:	83 e8 01             	sub    $0x1,%eax
  800983:	74 13                	je     800998 <strncmp+0x34>
		n--, p++, q++;
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098b:	0f b6 1a             	movzbl (%edx),%ebx
  80098e:	84 db                	test   %bl,%bl
  800990:	74 0f                	je     8009a1 <strncmp+0x3d>
  800992:	3a 19                	cmp    (%ecx),%bl
  800994:	74 ea                	je     800980 <strncmp+0x1c>
  800996:	eb 09                	jmp    8009a1 <strncmp+0x3d>
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	90                   	nop
  8009a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 02             	movzbl (%edx),%eax
  8009a4:	0f b6 11             	movzbl (%ecx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
  8009a9:	eb f2                	jmp    80099d <strncmp+0x39>

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 18                	je     8009d4 <strchr+0x29>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 0a                	jne    8009ca <strchr+0x1f>
  8009c0:	eb 17                	jmp    8009d9 <strchr+0x2e>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c8:	74 0f                	je     8009d9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 ee                	jne    8009c2 <strchr+0x17>
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 18                	je     800a04 <strfind+0x29>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	75 0a                	jne    8009fa <strfind+0x1f>
  8009f0:	eb 12                	jmp    800a04 <strfind+0x29>
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009f8:	74 0a                	je     800a04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 ee                	jne    8009f2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 0c             	sub    $0xc,%esp
  800a0c:	89 1c 24             	mov    %ebx,(%esp)
  800a0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a20:	85 c9                	test   %ecx,%ecx
  800a22:	74 30                	je     800a54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2a:	75 25                	jne    800a51 <memset+0x4b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 20                	jne    800a51 <memset+0x4b>
		c &= 0xFF;
  800a31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a34:	89 d3                	mov    %edx,%ebx
  800a36:	c1 e3 08             	shl    $0x8,%ebx
  800a39:	89 d6                	mov    %edx,%esi
  800a3b:	c1 e6 18             	shl    $0x18,%esi
  800a3e:	89 d0                	mov    %edx,%eax
  800a40:	c1 e0 10             	shl    $0x10,%eax
  800a43:	09 f0                	or     %esi,%eax
  800a45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a47:	09 d8                	or     %ebx,%eax
  800a49:	c1 e9 02             	shr    $0x2,%ecx
  800a4c:	fc                   	cld    
  800a4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	eb 03                	jmp    800a54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	8b 1c 24             	mov    (%esp),%ebx
  800a59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a61:	89 ec                	mov    %ebp,%esp
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	89 34 24             	mov    %esi,(%esp)
  800a6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a7d:	39 c6                	cmp    %eax,%esi
  800a7f:	73 35                	jae    800ab6 <memmove+0x51>
  800a81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 2e                	jae    800ab6 <memmove+0x51>
		s += n;
		d += n;
  800a88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	f6 c2 03             	test   $0x3,%dl
  800a8d:	75 1b                	jne    800aaa <memmove+0x45>
  800a8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a95:	75 13                	jne    800aaa <memmove+0x45>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0e                	jne    800aaa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a9c:	83 ef 04             	sub    $0x4,%edi
  800a9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
  800aa5:	fd                   	std    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa8:	eb 09                	jmp    800ab3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aaa:	83 ef 01             	sub    $0x1,%edi
  800aad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab0:	fd                   	std    
  800ab1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab4:	eb 20                	jmp    800ad6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abc:	75 15                	jne    800ad3 <memmove+0x6e>
  800abe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac4:	75 0d                	jne    800ad3 <memmove+0x6e>
  800ac6:	f6 c1 03             	test   $0x3,%cl
  800ac9:	75 08                	jne    800ad3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800acb:	c1 e9 02             	shr    $0x2,%ecx
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	eb 03                	jmp    800ad6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad3:	fc                   	cld    
  800ad4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad6:	8b 34 24             	mov    (%esp),%esi
  800ad9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800add:	89 ec                	mov    %ebp,%esp
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	89 04 24             	mov    %eax,(%esp)
  800afb:	e8 65 ff ff ff       	call   800a65 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 36                	je     800b4b <memcmp+0x49>
		if (*s1 != *s2)
  800b15:	0f b6 06             	movzbl (%esi),%eax
  800b18:	0f b6 1f             	movzbl (%edi),%ebx
  800b1b:	38 d8                	cmp    %bl,%al
  800b1d:	74 20                	je     800b3f <memcmp+0x3d>
  800b1f:	eb 14                	jmp    800b35 <memcmp+0x33>
  800b21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b2b:	83 c2 01             	add    $0x1,%edx
  800b2e:	83 e9 01             	sub    $0x1,%ecx
  800b31:	38 d8                	cmp    %bl,%al
  800b33:	74 12                	je     800b47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b35:	0f b6 c0             	movzbl %al,%eax
  800b38:	0f b6 db             	movzbl %bl,%ebx
  800b3b:	29 d8                	sub    %ebx,%eax
  800b3d:	eb 11                	jmp    800b50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	83 e9 01             	sub    $0x1,%ecx
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	85 c9                	test   %ecx,%ecx
  800b49:	75 d6                	jne    800b21 <memcmp+0x1f>
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b60:	39 d0                	cmp    %edx,%eax
  800b62:	73 15                	jae    800b79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b68:	38 08                	cmp    %cl,(%eax)
  800b6a:	75 06                	jne    800b72 <memfind+0x1d>
  800b6c:	eb 0b                	jmp    800b79 <memfind+0x24>
  800b6e:	38 08                	cmp    %cl,(%eax)
  800b70:	74 07                	je     800b79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 c2                	cmp    %eax,%edx
  800b77:	77 f5                	ja     800b6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8a:	0f b6 02             	movzbl (%edx),%eax
  800b8d:	3c 20                	cmp    $0x20,%al
  800b8f:	74 04                	je     800b95 <strtol+0x1a>
  800b91:	3c 09                	cmp    $0x9,%al
  800b93:	75 0e                	jne    800ba3 <strtol+0x28>
		s++;
  800b95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b98:	0f b6 02             	movzbl (%edx),%eax
  800b9b:	3c 20                	cmp    $0x20,%al
  800b9d:	74 f6                	je     800b95 <strtol+0x1a>
  800b9f:	3c 09                	cmp    $0x9,%al
  800ba1:	74 f2                	je     800b95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba3:	3c 2b                	cmp    $0x2b,%al
  800ba5:	75 0c                	jne    800bb3 <strtol+0x38>
		s++;
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb1:	eb 15                	jmp    800bc8 <strtol+0x4d>
	else if (*s == '-')
  800bb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bba:	3c 2d                	cmp    $0x2d,%al
  800bbc:	75 0a                	jne    800bc8 <strtol+0x4d>
		s++, neg = 1;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc8:	85 db                	test   %ebx,%ebx
  800bca:	0f 94 c0             	sete   %al
  800bcd:	74 05                	je     800bd4 <strtol+0x59>
  800bcf:	83 fb 10             	cmp    $0x10,%ebx
  800bd2:	75 18                	jne    800bec <strtol+0x71>
  800bd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd7:	75 13                	jne    800bec <strtol+0x71>
  800bd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	75 0a                	jne    800bec <strtol+0x71>
		s += 2, base = 16;
  800be2:	83 c2 02             	add    $0x2,%edx
  800be5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	eb 15                	jmp    800c01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bec:	84 c0                	test   %al,%al
  800bee:	66 90                	xchg   %ax,%ax
  800bf0:	74 0f                	je     800c01 <strtol+0x86>
  800bf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfa:	75 05                	jne    800c01 <strtol+0x86>
		s++, base = 8;
  800bfc:	83 c2 01             	add    $0x1,%edx
  800bff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c08:	0f b6 0a             	movzbl (%edx),%ecx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c10:	80 fb 09             	cmp    $0x9,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xa2>
			dig = *s - '0';
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 30             	sub    $0x30,%ecx
  800c1b:	eb 1e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 08                	ja     800c2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 57             	sub    $0x57,%ecx
  800c2b:	eb 0e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c30:	80 fb 19             	cmp    $0x19,%bl
  800c33:	77 15                	ja     800c4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3b:	39 f1                	cmp    %esi,%ecx
  800c3d:	7d 0b                	jge    800c4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c3f:	83 c2 01             	add    $0x1,%edx
  800c42:	0f af c6             	imul   %esi,%eax
  800c45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c48:	eb be                	jmp    800c08 <strtol+0x8d>
  800c4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c50:	74 05                	je     800c57 <strtol+0xdc>
		*endptr = (char *) s;
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c5b:	74 04                	je     800c61 <strtol+0xe6>
  800c5d:	89 c8                	mov    %ecx,%eax
  800c5f:	f7 d8                	neg    %eax
}
  800c61:	83 c4 04             	add    $0x4,%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    
  800c69:	00 00                	add    %al,(%eax)
	...

00800c6c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 08             	sub    $0x8,%esp
  800c72:	89 1c 24             	mov    %ebx,(%esp)
  800c75:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	89 d3                	mov    %edx,%ebx
  800c87:	89 d7                	mov    %edx,%edi
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
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca1:	8b 1c 24             	mov    (%esp),%ebx
  800ca4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ca8:	89 ec                	mov    %ebp,%esp
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 08             	sub    $0x8,%esp
  800cb2:	89 1c 24             	mov    %ebx,(%esp)
  800cb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 c3                	mov    %eax,%ebx
  800cc6:	89 c7                	mov    %eax,%edi
  800cc8:	51                   	push   %ecx
  800cc9:	52                   	push   %edx
  800cca:	53                   	push   %ebx
  800ccb:	54                   	push   %esp
  800ccc:	55                   	push   %ebp
  800ccd:	56                   	push   %esi
  800cce:	57                   	push   %edi
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	8d 35 d9 0c 80 00    	lea    0x800cd9,%esi
  800cd7:	0f 34                	sysenter 
  800cd9:	5f                   	pop    %edi
  800cda:	5e                   	pop    %esi
  800cdb:	5d                   	pop    %ebp
  800cdc:	5c                   	pop    %esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5a                   	pop    %edx
  800cdf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce0:	8b 1c 24             	mov    (%esp),%ebx
  800ce3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ce7:	89 ec                	mov    %ebp,%esp
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
  800cf1:	89 1c 24             	mov    %ebx,(%esp)
  800cf4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 cb                	mov    %ecx,%ebx
  800d07:	89 cf                	mov    %ecx,%edi
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
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800d21:	8b 1c 24             	mov    (%esp),%ebx
  800d24:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d28:	89 ec                	mov    %ebp,%esp
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 28             	sub    $0x28,%esp
  800d32:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d35:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 cb                	mov    %ecx,%ebx
  800d47:	89 cf                	mov    %ecx,%edi
  800d49:	51                   	push   %ecx
  800d4a:	52                   	push   %edx
  800d4b:	53                   	push   %ebx
  800d4c:	54                   	push   %esp
  800d4d:	55                   	push   %ebp
  800d4e:	56                   	push   %esi
  800d4f:	57                   	push   %edi
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	8d 35 5a 0d 80 00    	lea    0x800d5a,%esi
  800d58:	0f 34                	sysenter 
  800d5a:	5f                   	pop    %edi
  800d5b:	5e                   	pop    %esi
  800d5c:	5d                   	pop    %ebp
  800d5d:	5c                   	pop    %esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5a                   	pop    %edx
  800d60:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800d88:	e8 97 03 00 00       	call   801124 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d93:	89 ec                	mov    %ebp,%esp
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 08             	sub    $0x8,%esp
  800d9d:	89 1c 24             	mov    %ebx,(%esp)
  800da0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	51                   	push   %ecx
  800db6:	52                   	push   %edx
  800db7:	53                   	push   %ebx
  800db8:	54                   	push   %esp
  800db9:	55                   	push   %ebp
  800dba:	56                   	push   %esi
  800dbb:	57                   	push   %edi
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	8d 35 c6 0d 80 00    	lea    0x800dc6,%esi
  800dc4:	0f 34                	sysenter 
  800dc6:	5f                   	pop    %edi
  800dc7:	5e                   	pop    %esi
  800dc8:	5d                   	pop    %ebp
  800dc9:	5c                   	pop    %esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5a                   	pop    %edx
  800dcc:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcd:	8b 1c 24             	mov    (%esp),%ebx
  800dd0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd4:	89 ec                	mov    %ebp,%esp
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	83 ec 28             	sub    $0x28,%esp
  800dde:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800de1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	51                   	push   %ecx
  800df7:	52                   	push   %edx
  800df8:	53                   	push   %ebx
  800df9:	54                   	push   %esp
  800dfa:	55                   	push   %ebp
  800dfb:	56                   	push   %esi
  800dfc:	57                   	push   %edi
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	8d 35 07 0e 80 00    	lea    0x800e07,%esi
  800e05:	0f 34                	sysenter 
  800e07:	5f                   	pop    %edi
  800e08:	5e                   	pop    %esi
  800e09:	5d                   	pop    %ebp
  800e0a:	5c                   	pop    %esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5a                   	pop    %edx
  800e0d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	7e 28                	jle    800e3a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e16:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800e25:	00 
  800e26:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e2d:	00 
  800e2e:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800e35:	e8 ea 02 00 00       	call   801124 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e40:	89 ec                	mov    %ebp,%esp
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 28             	sub    $0x28,%esp
  800e4a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e4d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	51                   	push   %ecx
  800e63:	52                   	push   %edx
  800e64:	53                   	push   %ebx
  800e65:	54                   	push   %esp
  800e66:	55                   	push   %ebp
  800e67:	56                   	push   %esi
  800e68:	57                   	push   %edi
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	8d 35 73 0e 80 00    	lea    0x800e73,%esi
  800e71:	0f 34                	sysenter 
  800e73:	5f                   	pop    %edi
  800e74:	5e                   	pop    %esi
  800e75:	5d                   	pop    %ebp
  800e76:	5c                   	pop    %esp
  800e77:	5b                   	pop    %ebx
  800e78:	5a                   	pop    %edx
  800e79:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7e 28                	jle    800ea6 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e82:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e89:	00 
  800e8a:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800e91:	00 
  800e92:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e99:	00 
  800e9a:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800ea1:	e8 7e 02 00 00       	call   801124 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ea9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eac:	89 ec                	mov    %ebp,%esp
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 28             	sub    $0x28,%esp
  800eb6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800eb9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 df                	mov    %ebx,%edi
  800ece:	51                   	push   %ecx
  800ecf:	52                   	push   %edx
  800ed0:	53                   	push   %ebx
  800ed1:	54                   	push   %esp
  800ed2:	55                   	push   %ebp
  800ed3:	56                   	push   %esi
  800ed4:	57                   	push   %edi
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	8d 35 df 0e 80 00    	lea    0x800edf,%esi
  800edd:	0f 34                	sysenter 
  800edf:	5f                   	pop    %edi
  800ee0:	5e                   	pop    %esi
  800ee1:	5d                   	pop    %ebp
  800ee2:	5c                   	pop    %esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5a                   	pop    %edx
  800ee5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	7e 28                	jle    800f12 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800efd:	00 
  800efe:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f05:	00 
  800f06:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800f0d:	e8 12 02 00 00       	call   801124 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f12:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 28             	sub    $0x28,%esp
  800f22:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f25:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f28:	b8 06 00 00 00       	mov    $0x6,%eax
  800f2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	51                   	push   %ecx
  800f3a:	52                   	push   %edx
  800f3b:	53                   	push   %ebx
  800f3c:	54                   	push   %esp
  800f3d:	55                   	push   %ebp
  800f3e:	56                   	push   %esi
  800f3f:	57                   	push   %edi
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	8d 35 4a 0f 80 00    	lea    0x800f4a,%esi
  800f48:	0f 34                	sysenter 
  800f4a:	5f                   	pop    %edi
  800f4b:	5e                   	pop    %esi
  800f4c:	5d                   	pop    %ebp
  800f4d:	5c                   	pop    %esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5a                   	pop    %edx
  800f50:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	7e 28                	jle    800f7d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f59:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f60:	00 
  800f61:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800f68:	00 
  800f69:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f70:	00 
  800f71:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800f78:	e8 a7 01 00 00       	call   801124 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f7d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f83:	89 ec                	mov    %ebp,%esp
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 28             	sub    $0x28,%esp
  800f8d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f90:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f93:	bf 00 00 00 00       	mov    $0x0,%edi
  800f98:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	51                   	push   %ecx
  800fa7:	52                   	push   %edx
  800fa8:	53                   	push   %ebx
  800fa9:	54                   	push   %esp
  800faa:	55                   	push   %ebp
  800fab:	56                   	push   %esi
  800fac:	57                   	push   %edi
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	8d 35 b7 0f 80 00    	lea    0x800fb7,%esi
  800fb5:	0f 34                	sysenter 
  800fb7:	5f                   	pop    %edi
  800fb8:	5e                   	pop    %esi
  800fb9:	5d                   	pop    %ebp
  800fba:	5c                   	pop    %esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5a                   	pop    %edx
  800fbd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 28                	jle    800fea <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800fe5:	e8 3a 01 00 00       	call   801124 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fea:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff0:	89 ec                	mov    %ebp,%esp
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	89 1c 24             	mov    %ebx,(%esp)
  800ffd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801001:	ba 00 00 00 00       	mov    $0x0,%edx
  801006:	b8 0b 00 00 00       	mov    $0xb,%eax
  80100b:	89 d1                	mov    %edx,%ecx
  80100d:	89 d3                	mov    %edx,%ebx
  80100f:	89 d7                	mov    %edx,%edi
  801011:	51                   	push   %ecx
  801012:	52                   	push   %edx
  801013:	53                   	push   %ebx
  801014:	54                   	push   %esp
  801015:	55                   	push   %ebp
  801016:	56                   	push   %esi
  801017:	57                   	push   %edi
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	8d 35 22 10 80 00    	lea    0x801022,%esi
  801020:	0f 34                	sysenter 
  801022:	5f                   	pop    %edi
  801023:	5e                   	pop    %esi
  801024:	5d                   	pop    %ebp
  801025:	5c                   	pop    %esp
  801026:	5b                   	pop    %ebx
  801027:	5a                   	pop    %edx
  801028:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801029:	8b 1c 24             	mov    (%esp),%ebx
  80102c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801030:	89 ec                	mov    %ebp,%esp
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	89 1c 24             	mov    %ebx,(%esp)
  80103d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
  801046:	b8 04 00 00 00       	mov    $0x4,%eax
  80104b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
  801051:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80106b:	8b 1c 24             	mov    (%esp),%ebx
  80106e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801072:	89 ec                	mov    %ebp,%esp
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	89 1c 24             	mov    %ebx,(%esp)
  80107f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801083:	ba 00 00 00 00       	mov    $0x0,%edx
  801088:	b8 02 00 00 00       	mov    $0x2,%eax
  80108d:	89 d1                	mov    %edx,%ecx
  80108f:	89 d3                	mov    %edx,%ebx
  801091:	89 d7                	mov    %edx,%edi
  801093:	51                   	push   %ecx
  801094:	52                   	push   %edx
  801095:	53                   	push   %ebx
  801096:	54                   	push   %esp
  801097:	55                   	push   %ebp
  801098:	56                   	push   %esi
  801099:	57                   	push   %edi
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	8d 35 a4 10 80 00    	lea    0x8010a4,%esi
  8010a2:	0f 34                	sysenter 
  8010a4:	5f                   	pop    %edi
  8010a5:	5e                   	pop    %esi
  8010a6:	5d                   	pop    %ebp
  8010a7:	5c                   	pop    %esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5a                   	pop    %edx
  8010aa:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ab:	8b 1c 24             	mov    (%esp),%ebx
  8010ae:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b2:	89 ec                	mov    %ebp,%esp
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	83 ec 28             	sub    $0x28,%esp
  8010bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010bf:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8010cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cf:	89 cb                	mov    %ecx,%ebx
  8010d1:	89 cf                	mov    %ecx,%edi
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	7e 28                	jle    801117 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  801102:	00 
  801103:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80110a:	00 
  80110b:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  801112:	e8 0d 00 00 00       	call   801124 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801117:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80111a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80111d:	89 ec                	mov    %ebp,%esp
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    
  801121:	00 00                	add    %al,(%eax)
	...

00801124 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80112c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80112f:	a1 08 20 80 00       	mov    0x802008,%eax
  801134:	85 c0                	test   %eax,%eax
  801136:	74 10                	je     801148 <_panic+0x24>
		cprintf("%s: ", argv0);
  801138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113c:	c7 04 24 ef 16 80 00 	movl   $0x8016ef,(%esp)
  801143:	e8 4d f0 ff ff       	call   800195 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801148:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80114e:	e8 23 ff ff ff       	call   801076 <sys_getenvid>
  801153:	8b 55 0c             	mov    0xc(%ebp),%edx
  801156:	89 54 24 10          	mov    %edx,0x10(%esp)
  80115a:	8b 55 08             	mov    0x8(%ebp),%edx
  80115d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801161:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801165:	89 44 24 04          	mov    %eax,0x4(%esp)
  801169:	c7 04 24 f4 16 80 00 	movl   $0x8016f4,(%esp)
  801170:	e8 20 f0 ff ff       	call   800195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801175:	89 74 24 04          	mov    %esi,0x4(%esp)
  801179:	8b 45 10             	mov    0x10(%ebp),%eax
  80117c:	89 04 24             	mov    %eax,(%esp)
  80117f:	e8 b0 ef ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  801184:	c7 04 24 43 14 80 00 	movl   $0x801443,(%esp)
  80118b:	e8 05 f0 ff ff       	call   800195 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801190:	cc                   	int3   
  801191:	eb fd                	jmp    801190 <_panic+0x6c>
	...

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	83 ec 10             	sub    $0x10,%esp
  8011a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8011b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011b9:	75 35                	jne    8011f0 <__udivdi3+0x50>
  8011bb:	39 fe                	cmp    %edi,%esi
  8011bd:	77 61                	ja     801220 <__udivdi3+0x80>
  8011bf:	85 f6                	test   %esi,%esi
  8011c1:	75 0b                	jne    8011ce <__udivdi3+0x2e>
  8011c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c8:	31 d2                	xor    %edx,%edx
  8011ca:	f7 f6                	div    %esi
  8011cc:	89 c6                	mov    %eax,%esi
  8011ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8011d1:	31 d2                	xor    %edx,%edx
  8011d3:	89 f8                	mov    %edi,%eax
  8011d5:	f7 f6                	div    %esi
  8011d7:	89 c7                	mov    %eax,%edi
  8011d9:	89 c8                	mov    %ecx,%eax
  8011db:	f7 f6                	div    %esi
  8011dd:	89 c1                	mov    %eax,%ecx
  8011df:	89 fa                	mov    %edi,%edx
  8011e1:	89 c8                	mov    %ecx,%eax
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    
  8011ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f0:	39 f8                	cmp    %edi,%eax
  8011f2:	77 1c                	ja     801210 <__udivdi3+0x70>
  8011f4:	0f bd d0             	bsr    %eax,%edx
  8011f7:	83 f2 1f             	xor    $0x1f,%edx
  8011fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011fd:	75 39                	jne    801238 <__udivdi3+0x98>
  8011ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801202:	0f 86 a0 00 00 00    	jbe    8012a8 <__udivdi3+0x108>
  801208:	39 f8                	cmp    %edi,%eax
  80120a:	0f 82 98 00 00 00    	jb     8012a8 <__udivdi3+0x108>
  801210:	31 ff                	xor    %edi,%edi
  801212:	31 c9                	xor    %ecx,%ecx
  801214:	89 c8                	mov    %ecx,%eax
  801216:	89 fa                	mov    %edi,%edx
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    
  80121f:	90                   	nop
  801220:	89 d1                	mov    %edx,%ecx
  801222:	89 fa                	mov    %edi,%edx
  801224:	89 c8                	mov    %ecx,%eax
  801226:	31 ff                	xor    %edi,%edi
  801228:	f7 f6                	div    %esi
  80122a:	89 c1                	mov    %eax,%ecx
  80122c:	89 fa                	mov    %edi,%edx
  80122e:	89 c8                	mov    %ecx,%eax
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    
  801237:	90                   	nop
  801238:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80123c:	89 f2                	mov    %esi,%edx
  80123e:	d3 e0                	shl    %cl,%eax
  801240:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801243:	b8 20 00 00 00       	mov    $0x20,%eax
  801248:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80124b:	89 c1                	mov    %eax,%ecx
  80124d:	d3 ea                	shr    %cl,%edx
  80124f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801253:	0b 55 ec             	or     -0x14(%ebp),%edx
  801256:	d3 e6                	shl    %cl,%esi
  801258:	89 c1                	mov    %eax,%ecx
  80125a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80125d:	89 fe                	mov    %edi,%esi
  80125f:	d3 ee                	shr    %cl,%esi
  801261:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801265:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801268:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80126b:	d3 e7                	shl    %cl,%edi
  80126d:	89 c1                	mov    %eax,%ecx
  80126f:	d3 ea                	shr    %cl,%edx
  801271:	09 d7                	or     %edx,%edi
  801273:	89 f2                	mov    %esi,%edx
  801275:	89 f8                	mov    %edi,%eax
  801277:	f7 75 ec             	divl   -0x14(%ebp)
  80127a:	89 d6                	mov    %edx,%esi
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	f7 65 e8             	mull   -0x18(%ebp)
  801281:	39 d6                	cmp    %edx,%esi
  801283:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801286:	72 30                	jb     8012b8 <__udivdi3+0x118>
  801288:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80128b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80128f:	d3 e2                	shl    %cl,%edx
  801291:	39 c2                	cmp    %eax,%edx
  801293:	73 05                	jae    80129a <__udivdi3+0xfa>
  801295:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801298:	74 1e                	je     8012b8 <__udivdi3+0x118>
  80129a:	89 f9                	mov    %edi,%ecx
  80129c:	31 ff                	xor    %edi,%edi
  80129e:	e9 71 ff ff ff       	jmp    801214 <__udivdi3+0x74>
  8012a3:	90                   	nop
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	31 ff                	xor    %edi,%edi
  8012aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8012af:	e9 60 ff ff ff       	jmp    801214 <__udivdi3+0x74>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8012bb:	31 ff                	xor    %edi,%edi
  8012bd:	89 c8                	mov    %ecx,%eax
  8012bf:	89 fa                	mov    %edi,%edx
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
	...

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	57                   	push   %edi
  8012d4:	56                   	push   %esi
  8012d5:	83 ec 20             	sub    $0x20,%esp
  8012d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e4:	85 d2                	test   %edx,%edx
  8012e6:	89 c8                	mov    %ecx,%eax
  8012e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8012eb:	75 13                	jne    801300 <__umoddi3+0x30>
  8012ed:	39 f7                	cmp    %esi,%edi
  8012ef:	76 3f                	jbe    801330 <__umoddi3+0x60>
  8012f1:	89 f2                	mov    %esi,%edx
  8012f3:	f7 f7                	div    %edi
  8012f5:	89 d0                	mov    %edx,%eax
  8012f7:	31 d2                	xor    %edx,%edx
  8012f9:	83 c4 20             	add    $0x20,%esp
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    
  801300:	39 f2                	cmp    %esi,%edx
  801302:	77 4c                	ja     801350 <__umoddi3+0x80>
  801304:	0f bd ca             	bsr    %edx,%ecx
  801307:	83 f1 1f             	xor    $0x1f,%ecx
  80130a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80130d:	75 51                	jne    801360 <__umoddi3+0x90>
  80130f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801312:	0f 87 e0 00 00 00    	ja     8013f8 <__umoddi3+0x128>
  801318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131b:	29 f8                	sub    %edi,%eax
  80131d:	19 d6                	sbb    %edx,%esi
  80131f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801325:	89 f2                	mov    %esi,%edx
  801327:	83 c4 20             	add    $0x20,%esp
  80132a:	5e                   	pop    %esi
  80132b:	5f                   	pop    %edi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    
  80132e:	66 90                	xchg   %ax,%ax
  801330:	85 ff                	test   %edi,%edi
  801332:	75 0b                	jne    80133f <__umoddi3+0x6f>
  801334:	b8 01 00 00 00       	mov    $0x1,%eax
  801339:	31 d2                	xor    %edx,%edx
  80133b:	f7 f7                	div    %edi
  80133d:	89 c7                	mov    %eax,%edi
  80133f:	89 f0                	mov    %esi,%eax
  801341:	31 d2                	xor    %edx,%edx
  801343:	f7 f7                	div    %edi
  801345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801348:	f7 f7                	div    %edi
  80134a:	eb a9                	jmp    8012f5 <__umoddi3+0x25>
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 f2                	mov    %esi,%edx
  801354:	83 c4 20             	add    $0x20,%esp
  801357:	5e                   	pop    %esi
  801358:	5f                   	pop    %edi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    
  80135b:	90                   	nop
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801364:	d3 e2                	shl    %cl,%edx
  801366:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801369:	ba 20 00 00 00       	mov    $0x20,%edx
  80136e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801371:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801374:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801378:	89 fa                	mov    %edi,%edx
  80137a:	d3 ea                	shr    %cl,%edx
  80137c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801380:	0b 55 f4             	or     -0xc(%ebp),%edx
  801383:	d3 e7                	shl    %cl,%edi
  801385:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801389:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80138c:	89 f2                	mov    %esi,%edx
  80138e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801391:	89 c7                	mov    %eax,%edi
  801393:	d3 ea                	shr    %cl,%edx
  801395:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801399:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80139c:	89 c2                	mov    %eax,%edx
  80139e:	d3 e6                	shl    %cl,%esi
  8013a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013a4:	d3 ea                	shr    %cl,%edx
  8013a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013aa:	09 d6                	or     %edx,%esi
  8013ac:	89 f0                	mov    %esi,%eax
  8013ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013b1:	d3 e7                	shl    %cl,%edi
  8013b3:	89 f2                	mov    %esi,%edx
  8013b5:	f7 75 f4             	divl   -0xc(%ebp)
  8013b8:	89 d6                	mov    %edx,%esi
  8013ba:	f7 65 e8             	mull   -0x18(%ebp)
  8013bd:	39 d6                	cmp    %edx,%esi
  8013bf:	72 2b                	jb     8013ec <__umoddi3+0x11c>
  8013c1:	39 c7                	cmp    %eax,%edi
  8013c3:	72 23                	jb     8013e8 <__umoddi3+0x118>
  8013c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013c9:	29 c7                	sub    %eax,%edi
  8013cb:	19 d6                	sbb    %edx,%esi
  8013cd:	89 f0                	mov    %esi,%eax
  8013cf:	89 f2                	mov    %esi,%edx
  8013d1:	d3 ef                	shr    %cl,%edi
  8013d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013d7:	d3 e0                	shl    %cl,%eax
  8013d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013dd:	09 f8                	or     %edi,%eax
  8013df:	d3 ea                	shr    %cl,%edx
  8013e1:	83 c4 20             	add    $0x20,%esp
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    
  8013e8:	39 d6                	cmp    %edx,%esi
  8013ea:	75 d9                	jne    8013c5 <__umoddi3+0xf5>
  8013ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8013ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8013f2:	eb d1                	jmp    8013c5 <__umoddi3+0xf5>
  8013f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	39 f2                	cmp    %esi,%edx
  8013fa:	0f 82 18 ff ff ff    	jb     801318 <__umoddi3+0x48>
  801400:	e9 1d ff ff ff       	jmp    801322 <__umoddi3+0x52>
