
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 13 80 00 	movl   $0x8013e0,(%esp)
  80004e:	e8 12 01 00 00       	call   800165 <cprintf>
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800058:	e8 67 0f 00 00       	call   800fc4 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 14 80 00 	movl   $0x801400,(%esp)
  800074:	e8 ec 00 00 00       	call   800165 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 2c 14 80 00 	movl   $0x80142c,(%esp)
  800094:	e8 cc 00 00 00       	call   800165 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  8000b2:	e8 8f 0f 00 00       	call   801046 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	c1 e0 07             	shl    $0x7,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 84 0f 00 00       	call   801086 <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	8b 45 0c             	mov    0xc(%ebp),%eax
  800124:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800128:	8b 45 08             	mov    0x8(%ebp),%eax
  80012b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	c7 04 24 7f 01 80 00 	movl   $0x80017f,(%esp)
  800140:	e8 d8 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800145:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800155:	89 04 24             	mov    %eax,(%esp)
  800158:	e8 1f 0b 00 00       	call   800c7c <sys_cputs>

	return b.cnt;
}
  80015d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80016e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 87 ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	53                   	push   %ebx
  800183:	83 ec 14             	sub    $0x14,%esp
  800186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800189:	8b 03                	mov    (%ebx),%eax
  80018b:	8b 55 08             	mov    0x8(%ebp),%edx
  80018e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800192:	83 c0 01             	add    $0x1,%eax
  800195:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800197:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019c:	75 19                	jne    8001b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a5:	00 
  8001a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a9:	89 04 24             	mov    %eax,(%esp)
  8001ac:	e8 cb 0a 00 00       	call   800c7c <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	83 c4 14             	add    $0x14,%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fb:	39 d1                	cmp    %edx,%ecx
  8001fd:	72 15                	jb     800214 <printnum+0x44>
  8001ff:	77 07                	ja     800208 <printnum+0x38>
  800201:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800204:	39 d0                	cmp    %edx,%eax
  800206:	76 0c                	jbe    800214 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	85 db                	test   %ebx,%ebx
  80020d:	8d 76 00             	lea    0x0(%esi),%esi
  800210:	7f 61                	jg     800273 <printnum+0xa3>
  800212:	eb 70                	jmp    800284 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800227:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80022b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80022e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800231:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800249:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024d:	e8 1e 0f 00 00       	call   801170 <__udivdi3>
  800252:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800255:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	89 54 24 04          	mov    %edx,0x4(%esp)
  800267:	89 f2                	mov    %esi,%edx
  800269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026c:	e8 5f ff ff ff       	call   8001d0 <printnum>
  800271:	eb 11                	jmp    800284 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	89 74 24 04          	mov    %esi,0x4(%esp)
  800277:	89 3c 24             	mov    %edi,(%esp)
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ef                	jg     800273 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 74 24 04          	mov    0x4(%esp),%esi
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029a:	00 
  80029b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80029e:	89 14 24             	mov    %edx,(%esp)
  8002a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002a8:	e8 f3 0f 00 00       	call   8012a0 <__umoddi3>
  8002ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b1:	0f be 80 55 14 80 00 	movsbl 0x801455(%eax),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002be:	83 c4 4c             	add    $0x4c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800314:	88 0a                	mov    %cl,(%edx)
  800316:	83 c2 01             	add    $0x1,%edx
  800319:	89 10                	mov    %edx,(%eax)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 5c             	sub    $0x5c,%esp
  800326:	8b 7d 08             	mov    0x8(%ebp),%edi
  800329:	8b 75 0c             	mov    0xc(%ebp),%esi
  80032c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80032f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800336:	eb 11                	jmp    800349 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800338:	85 c0                	test   %eax,%eax
  80033a:	0f 84 09 04 00 00    	je     800749 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800340:	89 74 24 04          	mov    %esi,0x4(%esp)
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	0f b6 03             	movzbl (%ebx),%eax
  80034c:	83 c3 01             	add    $0x1,%ebx
  80034f:	83 f8 25             	cmp    $0x25,%eax
  800352:	75 e4                	jne    800338 <vprintfmt+0x1b>
  800354:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800358:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80035f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800366:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80036d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800372:	eb 06                	jmp    80037a <vprintfmt+0x5d>
  800374:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800378:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	0f b6 13             	movzbl (%ebx),%edx
  80037d:	0f b6 c2             	movzbl %dl,%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	8d 43 01             	lea    0x1(%ebx),%eax
  800386:	83 ea 23             	sub    $0x23,%edx
  800389:	80 fa 55             	cmp    $0x55,%dl
  80038c:	0f 87 9a 03 00 00    	ja     80072c <vprintfmt+0x40f>
  800392:	0f b6 d2             	movzbl %dl,%edx
  800395:	ff 24 95 20 15 80 00 	jmp    *0x801520(,%edx,4)
  80039c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003a0:	eb d6                	jmp    800378 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a5:	83 ea 30             	sub    $0x30,%edx
  8003a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003b1:	83 fb 09             	cmp    $0x9,%ebx
  8003b4:	77 4c                	ja     800402 <vprintfmt+0xe5>
  8003b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003cc:	83 fb 09             	cmp    $0x9,%ebx
  8003cf:	76 eb                	jbe    8003bc <vprintfmt+0x9f>
  8003d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003d7:	eb 29                	jmp    800402 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003e2:	8b 12                	mov    (%edx),%edx
  8003e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003e7:	eb 19                	jmp    800402 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ec:	c1 fa 1f             	sar    $0x1f,%edx
  8003ef:	f7 d2                	not    %edx
  8003f1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003f4:	eb 82                	jmp    800378 <vprintfmt+0x5b>
  8003f6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003fd:	e9 76 ff ff ff       	jmp    800378 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800402:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800406:	0f 89 6c ff ff ff    	jns    800378 <vprintfmt+0x5b>
  80040c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80040f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800412:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800415:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800418:	e9 5b ff ff ff       	jmp    800378 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800420:	e9 53 ff ff ff       	jmp    800378 <vprintfmt+0x5b>
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	89 74 24 04          	mov    %esi,0x4(%esp)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	ff d7                	call   *%edi
  80043c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80043f:	e9 05 ff ff ff       	jmp    800349 <vprintfmt+0x2c>
  800444:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	89 c2                	mov    %eax,%edx
  800454:	c1 fa 1f             	sar    $0x1f,%edx
  800457:	31 d0                	xor    %edx,%eax
  800459:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045b:	83 f8 08             	cmp    $0x8,%eax
  80045e:	7f 0b                	jg     80046b <vprintfmt+0x14e>
  800460:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	75 20                	jne    80048b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	c7 44 24 08 66 14 80 	movl   $0x801466,0x8(%esp)
  800476:	00 
  800477:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047b:	89 3c 24             	mov    %edi,(%esp)
  80047e:	e8 4e 03 00 00       	call   8007d1 <printfmt>
  800483:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800486:	e9 be fe ff ff       	jmp    800349 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80048b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048f:	c7 44 24 08 6f 14 80 	movl   $0x80146f,0x8(%esp)
  800496:	00 
  800497:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049b:	89 3c 24             	mov    %edi,(%esp)
  80049e:	e8 2e 03 00 00       	call   8007d1 <printfmt>
  8004a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a6:	e9 9e fe ff ff       	jmp    800349 <vprintfmt+0x2c>
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	89 c3                	mov    %eax,%ebx
  8004b0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 50 04             	lea    0x4(%eax),%edx
  8004bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	75 07                	jne    8004d2 <vprintfmt+0x1b5>
  8004cb:	c7 45 c4 72 14 80 00 	movl   $0x801472,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004d2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004d6:	7e 06                	jle    8004de <vprintfmt+0x1c1>
  8004d8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004dc:	75 13                	jne    8004f1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e1:	0f be 02             	movsbl (%edx),%eax
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	0f 85 99 00 00 00    	jne    800585 <vprintfmt+0x268>
  8004ec:	e9 86 00 00 00       	jmp    800577 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004f8:	89 0c 24             	mov    %ecx,(%esp)
  8004fb:	e8 1b 03 00 00       	call   80081b <strnlen>
  800500:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	85 d2                	test   %edx,%edx
  80050a:	7e d2                	jle    8004de <vprintfmt+0x1c1>
					putch(padc, putdat);
  80050c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800510:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800513:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800516:	89 d3                	mov    %edx,%ebx
  800518:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 eb 01             	sub    $0x1,%ebx
  800527:	85 db                	test   %ebx,%ebx
  800529:	7f ed                	jg     800518 <vprintfmt+0x1fb>
  80052b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80052e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800535:	eb a7                	jmp    8004de <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80053b:	74 18                	je     800555 <vprintfmt+0x238>
  80053d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800540:	83 fa 5e             	cmp    $0x5e,%edx
  800543:	76 10                	jbe    800555 <vprintfmt+0x238>
					putch('?', putdat);
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800550:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800553:	eb 0a                	jmp    80055f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	89 04 24             	mov    %eax,(%esp)
  80055c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800563:	0f be 03             	movsbl (%ebx),%eax
  800566:	85 c0                	test   %eax,%eax
  800568:	74 05                	je     80056f <vprintfmt+0x252>
  80056a:	83 c3 01             	add    $0x1,%ebx
  80056d:	eb 29                	jmp    800598 <vprintfmt+0x27b>
  80056f:	89 fe                	mov    %edi,%esi
  800571:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800574:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800577:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057b:	7f 2e                	jg     8005ab <vprintfmt+0x28e>
  80057d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800580:	e9 c4 fd ff ff       	jmp    800349 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800585:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800588:	83 c2 01             	add    $0x1,%edx
  80058b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80058e:	89 f7                	mov    %esi,%edi
  800590:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800593:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800596:	89 d3                	mov    %edx,%ebx
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 9b                	js     800537 <vprintfmt+0x21a>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 96                	jns    800537 <vprintfmt+0x21a>
  8005a1:	89 fe                	mov    %edi,%esi
  8005a3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005a6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005a9:	eb cc                	jmp    800577 <vprintfmt+0x25a>
  8005ab:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005bc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005be:	83 eb 01             	sub    $0x1,%ebx
  8005c1:	85 db                	test   %ebx,%ebx
  8005c3:	7f ec                	jg     8005b1 <vprintfmt+0x294>
  8005c5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c8:	e9 7c fd ff ff       	jmp    800349 <vprintfmt+0x2c>
  8005cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 f9 01             	cmp    $0x1,%ecx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005e6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x300>
	else if (lflag)
  8005eb:	85 c9                	test   %ecx,%ecx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800615:	89 c2                	mov    %eax,%edx
  800617:	c1 fa 1f             	sar    $0x1f,%edx
  80061a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800620:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800623:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800628:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062c:	0f 89 b8 00 00 00    	jns    8006ea <vprintfmt+0x3cd>
				putch('-', putdat);
  800632:	89 74 24 04          	mov    %esi,0x4(%esp)
  800636:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063d:	ff d7                	call   *%edi
				num = -(long long) num;
  80063f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800642:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800645:	f7 d9                	neg    %ecx
  800647:	83 d3 00             	adc    $0x0,%ebx
  80064a:	f7 db                	neg    %ebx
  80064c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800651:	e9 94 00 00 00       	jmp    8006ea <vprintfmt+0x3cd>
  800656:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800659:	89 ca                	mov    %ecx,%edx
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 63 fc ff ff       	call   8002c6 <getuint>
  800663:	89 c1                	mov    %eax,%ecx
  800665:	89 d3                	mov    %edx,%ebx
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80066c:	eb 7c                	jmp    8006ea <vprintfmt+0x3cd>
  80066e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800671:	89 74 24 04          	mov    %esi,0x4(%esp)
  800675:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80067c:	ff d7                	call   *%edi
			putch('X', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800689:	ff d7                	call   *%edi
			putch('X', putdat);
  80068b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800696:	ff d7                	call   *%edi
  800698:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80069b:	e9 a9 fc ff ff       	jmp    800349 <vprintfmt+0x2c>
  8006a0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ae:	ff d7                	call   *%edi
			putch('x', putdat);
  8006b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006bb:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	8b 08                	mov    (%eax),%ecx
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d2:	eb 16                	jmp    8006ea <vprintfmt+0x3cd>
  8006d4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d7:	89 ca                	mov    %ecx,%edx
  8006d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dc:	e8 e5 fb ff ff       	call   8002c6 <getuint>
  8006e1:	89 c1                	mov    %eax,%ecx
  8006e3:	89 d3                	mov    %edx,%ebx
  8006e5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ea:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fd:	89 0c 24             	mov    %ecx,(%esp)
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	89 f2                	mov    %esi,%edx
  800706:	89 f8                	mov    %edi,%eax
  800708:	e8 c3 fa ff ff       	call   8001d0 <printnum>
  80070d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800710:	e9 34 fc ff ff       	jmp    800349 <vprintfmt+0x2c>
  800715:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800718:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80071f:	89 14 24             	mov    %edx,(%esp)
  800722:	ff d7                	call   *%edi
  800724:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800727:	e9 1d fc ff ff       	jmp    800349 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800730:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800737:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80073c:	80 38 25             	cmpb   $0x25,(%eax)
  80073f:	0f 84 04 fc ff ff    	je     800349 <vprintfmt+0x2c>
  800745:	89 c3                	mov    %eax,%ebx
  800747:	eb f0                	jmp    800739 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800749:	83 c4 5c             	add    $0x5c,%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 28             	sub    $0x28,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80075d:	85 c0                	test   %eax,%eax
  80075f:	74 04                	je     800765 <vsnprintf+0x14>
  800761:	85 d2                	test   %edx,%edx
  800763:	7f 07                	jg     80076c <vsnprintf+0x1b>
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076a:	eb 3b                	jmp    8007a7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800773:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800776:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800784:	8b 45 10             	mov    0x10(%ebp),%eax
  800787:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800792:	c7 04 24 00 03 80 00 	movl   $0x800300,(%esp)
  800799:	e8 7f fb ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007af:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	89 04 24             	mov    %eax,(%esp)
  8007ca:	e8 82 ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007d7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	e8 26 fb ff ff       	call   80031d <vprintfmt>
	va_end(ap);
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    
  8007f9:	00 00                	add    %al,(%eax)
  8007fb:	00 00                	add    %al,(%eax)
  8007fd:	00 00                	add    %al,(%eax)
	...

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	80 3a 00             	cmpb   $0x0,(%edx)
  80080e:	74 09                	je     800819 <strlen+0x19>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800825:	85 c9                	test   %ecx,%ecx
  800827:	74 19                	je     800842 <strnlen+0x27>
  800829:	80 3b 00             	cmpb   $0x0,(%ebx)
  80082c:	74 14                	je     800842 <strnlen+0x27>
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	39 c8                	cmp    %ecx,%eax
  800838:	74 0d                	je     800847 <strnlen+0x2c>
  80083a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80083e:	75 f3                	jne    800833 <strnlen+0x18>
  800840:	eb 05                	jmp    800847 <strnlen+0x2c>
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800854:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800859:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80085d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	84 c9                	test   %cl,%cl
  800865:	75 f2                	jne    800859 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800874:	89 1c 24             	mov    %ebx,(%esp)
  800877:	e8 84 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800883:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 bc ff ff ff       	call   80084a <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	85 f6                	test   %esi,%esi
  8008a6:	74 18                	je     8008c0 <strncpy+0x2a>
  8008a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008ad:	0f b6 1a             	movzbl (%edx),%ebx
  8008b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	39 ce                	cmp    %ecx,%esi
  8008be:	77 ed                	ja     8008ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 27                	je     8008ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008d8:	83 e9 01             	sub    $0x1,%ecx
  8008db:	74 1d                	je     8008fa <strlcpy+0x36>
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	74 16                	je     8008fa <strlcpy+0x36>
			*dst++ = *src++;
  8008e4:	88 18                	mov    %bl,(%eax)
  8008e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e9:	83 e9 01             	sub    $0x1,%ecx
  8008ec:	74 0e                	je     8008fc <strlcpy+0x38>
			*dst++ = *src++;
  8008ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f1:	0f b6 1a             	movzbl (%edx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ec                	jne    8008e4 <strlcpy+0x20>
  8008f8:	eb 02                	jmp    8008fc <strlcpy+0x38>
  8008fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fc:	c6 00 00             	movb   $0x0,(%eax)
  8008ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 15                	je     80092a <strcmp+0x25>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	75 11                	jne    80092a <strcmp+0x25>
		p++, q++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091f:	0f b6 01             	movzbl (%ecx),%eax
  800922:	84 c0                	test   %al,%al
  800924:	74 04                	je     80092a <strcmp+0x25>
  800926:	3a 02                	cmp    (%edx),%al
  800928:	74 ef                	je     800919 <strcmp+0x14>
  80092a:	0f b6 c0             	movzbl %al,%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	8b 55 08             	mov    0x8(%ebp),%edx
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800941:	85 c0                	test   %eax,%eax
  800943:	74 23                	je     800968 <strncmp+0x34>
  800945:	0f b6 1a             	movzbl (%edx),%ebx
  800948:	84 db                	test   %bl,%bl
  80094a:	74 25                	je     800971 <strncmp+0x3d>
  80094c:	3a 19                	cmp    (%ecx),%bl
  80094e:	75 21                	jne    800971 <strncmp+0x3d>
  800950:	83 e8 01             	sub    $0x1,%eax
  800953:	74 13                	je     800968 <strncmp+0x34>
		n--, p++, q++;
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	84 db                	test   %bl,%bl
  800960:	74 0f                	je     800971 <strncmp+0x3d>
  800962:	3a 19                	cmp    (%ecx),%bl
  800964:	74 ea                	je     800950 <strncmp+0x1c>
  800966:	eb 09                	jmp    800971 <strncmp+0x3d>
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	90                   	nop
  800970:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800971:	0f b6 02             	movzbl (%edx),%eax
  800974:	0f b6 11             	movzbl (%ecx),%edx
  800977:	29 d0                	sub    %edx,%eax
  800979:	eb f2                	jmp    80096d <strncmp+0x39>

0080097b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	74 18                	je     8009a4 <strchr+0x29>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	75 0a                	jne    80099a <strchr+0x1f>
  800990:	eb 17                	jmp    8009a9 <strchr+0x2e>
  800992:	38 ca                	cmp    %cl,%dl
  800994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800998:	74 0f                	je     8009a9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 ee                	jne    800992 <strchr+0x17>
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 18                	je     8009d4 <strfind+0x29>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 0a                	jne    8009ca <strfind+0x1f>
  8009c0:	eb 12                	jmp    8009d4 <strfind+0x29>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c8:	74 0a                	je     8009d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 ee                	jne    8009c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	89 1c 24             	mov    %ebx,(%esp)
  8009df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f0:	85 c9                	test   %ecx,%ecx
  8009f2:	74 30                	je     800a24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fa:	75 25                	jne    800a21 <memset+0x4b>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 20                	jne    800a21 <memset+0x4b>
		c &= 0xFF;
  800a01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a04:	89 d3                	mov    %edx,%ebx
  800a06:	c1 e3 08             	shl    $0x8,%ebx
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	c1 e6 18             	shl    $0x18,%esi
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	c1 e0 10             	shl    $0x10,%eax
  800a13:	09 f0                	or     %esi,%eax
  800a15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a17:	09 d8                	or     %ebx,%eax
  800a19:	c1 e9 02             	shr    $0x2,%ecx
  800a1c:	fc                   	cld    
  800a1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1f:	eb 03                	jmp    800a24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	8b 1c 24             	mov    (%esp),%ebx
  800a29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a31:	89 ec                	mov    %ebp,%esp
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	89 34 24             	mov    %esi,(%esp)
  800a3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a4d:	39 c6                	cmp    %eax,%esi
  800a4f:	73 35                	jae    800a86 <memmove+0x51>
  800a51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	73 2e                	jae    800a86 <memmove+0x51>
		s += n;
		d += n;
  800a58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	f6 c2 03             	test   $0x3,%dl
  800a5d:	75 1b                	jne    800a7a <memmove+0x45>
  800a5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a65:	75 13                	jne    800a7a <memmove+0x45>
  800a67:	f6 c1 03             	test   $0x3,%cl
  800a6a:	75 0e                	jne    800a7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a6c:	83 ef 04             	sub    $0x4,%edi
  800a6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fd                   	std    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a78:	eb 09                	jmp    800a83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a84:	eb 20                	jmp    800aa6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8c:	75 15                	jne    800aa3 <memmove+0x6e>
  800a8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a94:	75 0d                	jne    800aa3 <memmove+0x6e>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 08                	jne    800aa3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa1:	eb 03                	jmp    800aa6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	fc                   	cld    
  800aa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa6:	8b 34 24             	mov    (%esp),%esi
  800aa9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800aad:	89 ec                	mov    %ebp,%esp
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	89 04 24             	mov    %eax,(%esp)
  800acb:	e8 65 ff ff ff       	call   800a35 <memmove>
}
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	8b 75 08             	mov    0x8(%ebp),%esi
  800adb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae1:	85 c9                	test   %ecx,%ecx
  800ae3:	74 36                	je     800b1b <memcmp+0x49>
		if (*s1 != *s2)
  800ae5:	0f b6 06             	movzbl (%esi),%eax
  800ae8:	0f b6 1f             	movzbl (%edi),%ebx
  800aeb:	38 d8                	cmp    %bl,%al
  800aed:	74 20                	je     800b0f <memcmp+0x3d>
  800aef:	eb 14                	jmp    800b05 <memcmp+0x33>
  800af1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800af6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	83 e9 01             	sub    $0x1,%ecx
  800b01:	38 d8                	cmp    %bl,%al
  800b03:	74 12                	je     800b17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b05:	0f b6 c0             	movzbl %al,%eax
  800b08:	0f b6 db             	movzbl %bl,%ebx
  800b0b:	29 d8                	sub    %ebx,%eax
  800b0d:	eb 11                	jmp    800b20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0f:	83 e9 01             	sub    $0x1,%ecx
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	85 c9                	test   %ecx,%ecx
  800b19:	75 d6                	jne    800af1 <memcmp+0x1f>
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	73 15                	jae    800b49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b38:	38 08                	cmp    %cl,(%eax)
  800b3a:	75 06                	jne    800b42 <memfind+0x1d>
  800b3c:	eb 0b                	jmp    800b49 <memfind+0x24>
  800b3e:	38 08                	cmp    %cl,(%eax)
  800b40:	74 07                	je     800b49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	39 c2                	cmp    %eax,%edx
  800b47:	77 f5                	ja     800b3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	83 ec 04             	sub    $0x4,%esp
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 02             	movzbl (%edx),%eax
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 04                	je     800b65 <strtol+0x1a>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	75 0e                	jne    800b73 <strtol+0x28>
		s++;
  800b65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b68:	0f b6 02             	movzbl (%edx),%eax
  800b6b:	3c 20                	cmp    $0x20,%al
  800b6d:	74 f6                	je     800b65 <strtol+0x1a>
  800b6f:	3c 09                	cmp    $0x9,%al
  800b71:	74 f2                	je     800b65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b73:	3c 2b                	cmp    $0x2b,%al
  800b75:	75 0c                	jne    800b83 <strtol+0x38>
		s++;
  800b77:	83 c2 01             	add    $0x1,%edx
  800b7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b81:	eb 15                	jmp    800b98 <strtol+0x4d>
	else if (*s == '-')
  800b83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b8a:	3c 2d                	cmp    $0x2d,%al
  800b8c:	75 0a                	jne    800b98 <strtol+0x4d>
		s++, neg = 1;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b98:	85 db                	test   %ebx,%ebx
  800b9a:	0f 94 c0             	sete   %al
  800b9d:	74 05                	je     800ba4 <strtol+0x59>
  800b9f:	83 fb 10             	cmp    $0x10,%ebx
  800ba2:	75 18                	jne    800bbc <strtol+0x71>
  800ba4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba7:	75 13                	jne    800bbc <strtol+0x71>
  800ba9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bad:	8d 76 00             	lea    0x0(%esi),%esi
  800bb0:	75 0a                	jne    800bbc <strtol+0x71>
		s += 2, base = 16;
  800bb2:	83 c2 02             	add    $0x2,%edx
  800bb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bba:	eb 15                	jmp    800bd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbc:	84 c0                	test   %al,%al
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	74 0f                	je     800bd1 <strtol+0x86>
  800bc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bc7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bca:	75 05                	jne    800bd1 <strtol+0x86>
		s++, base = 8;
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd8:	0f b6 0a             	movzbl (%edx),%ecx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800be0:	80 fb 09             	cmp    $0x9,%bl
  800be3:	77 08                	ja     800bed <strtol+0xa2>
			dig = *s - '0';
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 30             	sub    $0x30,%ecx
  800beb:	eb 1e                	jmp    800c0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bf0:	80 fb 19             	cmp    $0x19,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 57             	sub    $0x57,%ecx
  800bfb:	eb 0e                	jmp    800c0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 15                	ja     800c1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c0b:	39 f1                	cmp    %esi,%ecx
  800c0d:	7d 0b                	jge    800c1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c0f:	83 c2 01             	add    $0x1,%edx
  800c12:	0f af c6             	imul   %esi,%eax
  800c15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c18:	eb be                	jmp    800bd8 <strtol+0x8d>
  800c1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 05                	je     800c27 <strtol+0xdc>
		*endptr = (char *) s;
  800c22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c2b:	74 04                	je     800c31 <strtol+0xe6>
  800c2d:	89 c8                	mov    %ecx,%eax
  800c2f:	f7 d8                	neg    %eax
}
  800c31:	83 c4 04             	add    $0x4,%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    
  800c39:	00 00                	add    %al,(%eax)
	...

00800c3c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	51                   	push   %ecx
  800c5a:	52                   	push   %edx
  800c5b:	53                   	push   %ebx
  800c5c:	54                   	push   %esp
  800c5d:	55                   	push   %ebp
  800c5e:	56                   	push   %esi
  800c5f:	57                   	push   %edi
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	8d 35 6a 0c 80 00    	lea    0x800c6a,%esi
  800c68:	0f 34                	sysenter 
  800c6a:	5f                   	pop    %edi
  800c6b:	5e                   	pop    %esi
  800c6c:	5d                   	pop    %ebp
  800c6d:	5c                   	pop    %esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5a                   	pop    %edx
  800c70:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c71:	8b 1c 24             	mov    (%esp),%ebx
  800c74:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c78:	89 ec                	mov    %ebp,%esp
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
  800c82:	89 1c 24             	mov    %ebx,(%esp)
  800c85:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 c3                	mov    %eax,%ebx
  800c96:	89 c7                	mov    %eax,%edi
  800c98:	51                   	push   %ecx
  800c99:	52                   	push   %edx
  800c9a:	53                   	push   %ebx
  800c9b:	54                   	push   %esp
  800c9c:	55                   	push   %ebp
  800c9d:	56                   	push   %esi
  800c9e:	57                   	push   %edi
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	8d 35 a9 0c 80 00    	lea    0x800ca9,%esi
  800ca7:	0f 34                	sysenter 
  800ca9:	5f                   	pop    %edi
  800caa:	5e                   	pop    %esi
  800cab:	5d                   	pop    %ebp
  800cac:	5c                   	pop    %esp
  800cad:	5b                   	pop    %ebx
  800cae:	5a                   	pop    %edx
  800caf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb0:	8b 1c 24             	mov    (%esp),%ebx
  800cb3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cb7:	89 ec                	mov    %ebp,%esp
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
  800cc1:	89 1c 24             	mov    %ebx,(%esp)
  800cc4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccd:	b8 0e 00 00 00       	mov    $0xe,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800cf1:	8b 1c 24             	mov    (%esp),%ebx
  800cf4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cf8:	89 ec                	mov    %ebp,%esp
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 28             	sub    $0x28,%esp
  800d02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d05:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 cb                	mov    %ecx,%ebx
  800d17:	89 cf                	mov    %ecx,%edi
  800d19:	51                   	push   %ecx
  800d1a:	52                   	push   %edx
  800d1b:	53                   	push   %ebx
  800d1c:	54                   	push   %esp
  800d1d:	55                   	push   %ebp
  800d1e:	56                   	push   %esi
  800d1f:	57                   	push   %edi
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	8d 35 2a 0d 80 00    	lea    0x800d2a,%esi
  800d28:	0f 34                	sysenter 
  800d2a:	5f                   	pop    %edi
  800d2b:	5e                   	pop    %esi
  800d2c:	5d                   	pop    %ebp
  800d2d:	5c                   	pop    %esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5a                   	pop    %edx
  800d30:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 28                	jle    800d5d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d39:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d40:	00 
  800d41:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800d48:	00 
  800d49:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d50:	00 
  800d51:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800d58:	e8 97 03 00 00       	call   8010f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d63:	89 ec                	mov    %ebp,%esp
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 08             	sub    $0x8,%esp
  800d6d:	89 1c 24             	mov    %ebx,(%esp)
  800d70:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d74:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	51                   	push   %ecx
  800d86:	52                   	push   %edx
  800d87:	53                   	push   %ebx
  800d88:	54                   	push   %esp
  800d89:	55                   	push   %ebp
  800d8a:	56                   	push   %esi
  800d8b:	57                   	push   %edi
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	8d 35 96 0d 80 00    	lea    0x800d96,%esi
  800d94:	0f 34                	sysenter 
  800d96:	5f                   	pop    %edi
  800d97:	5e                   	pop    %esi
  800d98:	5d                   	pop    %ebp
  800d99:	5c                   	pop    %esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5a                   	pop    %edx
  800d9c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9d:	8b 1c 24             	mov    (%esp),%ebx
  800da0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800da4:	89 ec                	mov    %ebp,%esp
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	83 ec 28             	sub    $0x28,%esp
  800dae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800db1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	51                   	push   %ecx
  800dc7:	52                   	push   %edx
  800dc8:	53                   	push   %ebx
  800dc9:	54                   	push   %esp
  800dca:	55                   	push   %ebp
  800dcb:	56                   	push   %esi
  800dcc:	57                   	push   %edi
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8d 35 d7 0d 80 00    	lea    0x800dd7,%esi
  800dd5:	0f 34                	sysenter 
  800dd7:	5f                   	pop    %edi
  800dd8:	5e                   	pop    %esi
  800dd9:	5d                   	pop    %ebp
  800dda:	5c                   	pop    %esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5a                   	pop    %edx
  800ddd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800e05:	e8 ea 02 00 00       	call   8010f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e10:	89 ec                	mov    %ebp,%esp
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 28             	sub    $0x28,%esp
  800e1a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e1d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e25:	b8 09 00 00 00       	mov    $0x9,%eax
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 df                	mov    %ebx,%edi
  800e32:	51                   	push   %ecx
  800e33:	52                   	push   %edx
  800e34:	53                   	push   %ebx
  800e35:	54                   	push   %esp
  800e36:	55                   	push   %ebp
  800e37:	56                   	push   %esi
  800e38:	57                   	push   %edi
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8d 35 43 0e 80 00    	lea    0x800e43,%esi
  800e41:	0f 34                	sysenter 
  800e43:	5f                   	pop    %edi
  800e44:	5e                   	pop    %esi
  800e45:	5d                   	pop    %ebp
  800e46:	5c                   	pop    %esp
  800e47:	5b                   	pop    %ebx
  800e48:	5a                   	pop    %edx
  800e49:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 28                	jle    800e76 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e52:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e59:	00 
  800e5a:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800e61:	00 
  800e62:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e69:	00 
  800e6a:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800e71:	e8 7e 02 00 00       	call   8010f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e76:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e79:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7c:	89 ec                	mov    %ebp,%esp
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 28             	sub    $0x28,%esp
  800e86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e89:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e91:	b8 07 00 00 00       	mov    $0x7,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 df                	mov    %ebx,%edi
  800e9e:	51                   	push   %ecx
  800e9f:	52                   	push   %edx
  800ea0:	53                   	push   %ebx
  800ea1:	54                   	push   %esp
  800ea2:	55                   	push   %ebp
  800ea3:	56                   	push   %esi
  800ea4:	57                   	push   %edi
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	8d 35 af 0e 80 00    	lea    0x800eaf,%esi
  800ead:	0f 34                	sysenter 
  800eaf:	5f                   	pop    %edi
  800eb0:	5e                   	pop    %esi
  800eb1:	5d                   	pop    %ebp
  800eb2:	5c                   	pop    %esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5a                   	pop    %edx
  800eb5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	7e 28                	jle    800ee2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebe:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ec5:	00 
  800ec6:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800ecd:	00 
  800ece:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ed5:	00 
  800ed6:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800edd:	e8 12 02 00 00       	call   8010f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ee5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 28             	sub    $0x28,%esp
  800ef2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ef5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ef8:	b8 06 00 00 00       	mov    $0x6,%eax
  800efd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	51                   	push   %ecx
  800f0a:	52                   	push   %edx
  800f0b:	53                   	push   %ebx
  800f0c:	54                   	push   %esp
  800f0d:	55                   	push   %ebp
  800f0e:	56                   	push   %esi
  800f0f:	57                   	push   %edi
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	8d 35 1a 0f 80 00    	lea    0x800f1a,%esi
  800f18:	0f 34                	sysenter 
  800f1a:	5f                   	pop    %edi
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	5c                   	pop    %esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5a                   	pop    %edx
  800f20:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	7e 28                	jle    800f4d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f29:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f30:	00 
  800f31:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800f38:	00 
  800f39:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800f48:	e8 a7 01 00 00       	call   8010f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f4d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f53:	89 ec                	mov    %ebp,%esp
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 28             	sub    $0x28,%esp
  800f5d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f60:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f63:	bf 00 00 00 00       	mov    $0x0,%edi
  800f68:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	51                   	push   %ecx
  800f77:	52                   	push   %edx
  800f78:	53                   	push   %ebx
  800f79:	54                   	push   %esp
  800f7a:	55                   	push   %ebp
  800f7b:	56                   	push   %esi
  800f7c:	57                   	push   %edi
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	8d 35 87 0f 80 00    	lea    0x800f87,%esi
  800f85:	0f 34                	sysenter 
  800f87:	5f                   	pop    %edi
  800f88:	5e                   	pop    %esi
  800f89:	5d                   	pop    %ebp
  800f8a:	5c                   	pop    %esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5a                   	pop    %edx
  800f8d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	7e 28                	jle    800fba <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f96:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fad:	00 
  800fae:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  800fb5:	e8 3a 01 00 00       	call   8010f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc0:	89 ec                	mov    %ebp,%esp
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  800fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fdb:	89 d1                	mov    %edx,%ecx
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	51                   	push   %ecx
  800fe2:	52                   	push   %edx
  800fe3:	53                   	push   %ebx
  800fe4:	54                   	push   %esp
  800fe5:	55                   	push   %ebp
  800fe6:	56                   	push   %esi
  800fe7:	57                   	push   %edi
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	8d 35 f2 0f 80 00    	lea    0x800ff2,%esi
  800ff0:	0f 34                	sysenter 
  800ff2:	5f                   	pop    %edi
  800ff3:	5e                   	pop    %esi
  800ff4:	5d                   	pop    %ebp
  800ff5:	5c                   	pop    %esp
  800ff6:	5b                   	pop    %ebx
  800ff7:	5a                   	pop    %edx
  800ff8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ff9:	8b 1c 24             	mov    (%esp),%ebx
  800ffc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801000:	89 ec                	mov    %ebp,%esp
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	89 1c 24             	mov    %ebx,(%esp)
  80100d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801011:	bb 00 00 00 00       	mov    $0x0,%ebx
  801016:	b8 04 00 00 00       	mov    $0x4,%eax
  80101b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
  801021:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80103b:	8b 1c 24             	mov    (%esp),%ebx
  80103e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801042:	89 ec                	mov    %ebp,%esp
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	83 ec 08             	sub    $0x8,%esp
  80104c:	89 1c 24             	mov    %ebx,(%esp)
  80104f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801053:	ba 00 00 00 00       	mov    $0x0,%edx
  801058:	b8 02 00 00 00       	mov    $0x2,%eax
  80105d:	89 d1                	mov    %edx,%ecx
  80105f:	89 d3                	mov    %edx,%ebx
  801061:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80107b:	8b 1c 24             	mov    (%esp),%ebx
  80107e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801082:	89 ec                	mov    %ebp,%esp
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 28             	sub    $0x28,%esp
  80108c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80108f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801092:	b9 00 00 00 00       	mov    $0x0,%ecx
  801097:	b8 03 00 00 00       	mov    $0x3,%eax
  80109c:	8b 55 08             	mov    0x8(%ebp),%edx
  80109f:	89 cb                	mov    %ecx,%ebx
  8010a1:	89 cf                	mov    %ecx,%edi
  8010a3:	51                   	push   %ecx
  8010a4:	52                   	push   %edx
  8010a5:	53                   	push   %ebx
  8010a6:	54                   	push   %esp
  8010a7:	55                   	push   %ebp
  8010a8:	56                   	push   %esi
  8010a9:	57                   	push   %edi
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	8d 35 b4 10 80 00    	lea    0x8010b4,%esi
  8010b2:	0f 34                	sysenter 
  8010b4:	5f                   	pop    %edi
  8010b5:	5e                   	pop    %esi
  8010b6:	5d                   	pop    %ebp
  8010b7:	5c                   	pop    %esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5a                   	pop    %edx
  8010ba:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	7e 28                	jle    8010e7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 08 a4 16 80 	movl   $0x8016a4,0x8(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010da:	00 
  8010db:	c7 04 24 c1 16 80 00 	movl   $0x8016c1,(%esp)
  8010e2:	e8 0d 00 00 00       	call   8010f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010e7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ed:	89 ec                	mov    %ebp,%esp
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    
  8010f1:	00 00                	add    %al,(%eax)
	...

008010f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8010fc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8010ff:	a1 08 20 80 00       	mov    0x802008,%eax
  801104:	85 c0                	test   %eax,%eax
  801106:	74 10                	je     801118 <_panic+0x24>
		cprintf("%s: ", argv0);
  801108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110c:	c7 04 24 cf 16 80 00 	movl   $0x8016cf,(%esp)
  801113:	e8 4d f0 ff ff       	call   800165 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801118:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80111e:	e8 23 ff ff ff       	call   801046 <sys_getenvid>
  801123:	8b 55 0c             	mov    0xc(%ebp),%edx
  801126:	89 54 24 10          	mov    %edx,0x10(%esp)
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
  80112d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801131:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801135:	89 44 24 04          	mov    %eax,0x4(%esp)
  801139:	c7 04 24 d8 16 80 00 	movl   $0x8016d8,(%esp)
  801140:	e8 20 f0 ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801145:	89 74 24 04          	mov    %esi,0x4(%esp)
  801149:	8b 45 10             	mov    0x10(%ebp),%eax
  80114c:	89 04 24             	mov    %eax,(%esp)
  80114f:	e8 b0 ef ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  801154:	c7 04 24 d4 16 80 00 	movl   $0x8016d4,(%esp)
  80115b:	e8 05 f0 ff ff       	call   800165 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801160:	cc                   	int3   
  801161:	eb fd                	jmp    801160 <_panic+0x6c>
	...

00801170 <__udivdi3>:
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	83 ec 10             	sub    $0x10,%esp
  801178:	8b 45 14             	mov    0x14(%ebp),%eax
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	8b 75 10             	mov    0x10(%ebp),%esi
  801181:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801184:	85 c0                	test   %eax,%eax
  801186:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801189:	75 35                	jne    8011c0 <__udivdi3+0x50>
  80118b:	39 fe                	cmp    %edi,%esi
  80118d:	77 61                	ja     8011f0 <__udivdi3+0x80>
  80118f:	85 f6                	test   %esi,%esi
  801191:	75 0b                	jne    80119e <__udivdi3+0x2e>
  801193:	b8 01 00 00 00       	mov    $0x1,%eax
  801198:	31 d2                	xor    %edx,%edx
  80119a:	f7 f6                	div    %esi
  80119c:	89 c6                	mov    %eax,%esi
  80119e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8011a1:	31 d2                	xor    %edx,%edx
  8011a3:	89 f8                	mov    %edi,%eax
  8011a5:	f7 f6                	div    %esi
  8011a7:	89 c7                	mov    %eax,%edi
  8011a9:	89 c8                	mov    %ecx,%eax
  8011ab:	f7 f6                	div    %esi
  8011ad:	89 c1                	mov    %eax,%ecx
  8011af:	89 fa                	mov    %edi,%edx
  8011b1:	89 c8                	mov    %ecx,%eax
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    
  8011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011c0:	39 f8                	cmp    %edi,%eax
  8011c2:	77 1c                	ja     8011e0 <__udivdi3+0x70>
  8011c4:	0f bd d0             	bsr    %eax,%edx
  8011c7:	83 f2 1f             	xor    $0x1f,%edx
  8011ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011cd:	75 39                	jne    801208 <__udivdi3+0x98>
  8011cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8011d2:	0f 86 a0 00 00 00    	jbe    801278 <__udivdi3+0x108>
  8011d8:	39 f8                	cmp    %edi,%eax
  8011da:	0f 82 98 00 00 00    	jb     801278 <__udivdi3+0x108>
  8011e0:	31 ff                	xor    %edi,%edi
  8011e2:	31 c9                	xor    %ecx,%ecx
  8011e4:	89 c8                	mov    %ecx,%eax
  8011e6:	89 fa                	mov    %edi,%edx
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	5e                   	pop    %esi
  8011ec:	5f                   	pop    %edi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    
  8011ef:	90                   	nop
  8011f0:	89 d1                	mov    %edx,%ecx
  8011f2:	89 fa                	mov    %edi,%edx
  8011f4:	89 c8                	mov    %ecx,%eax
  8011f6:	31 ff                	xor    %edi,%edi
  8011f8:	f7 f6                	div    %esi
  8011fa:	89 c1                	mov    %eax,%ecx
  8011fc:	89 fa                	mov    %edi,%edx
  8011fe:	89 c8                	mov    %ecx,%eax
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    
  801207:	90                   	nop
  801208:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80120c:	89 f2                	mov    %esi,%edx
  80120e:	d3 e0                	shl    %cl,%eax
  801210:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801213:	b8 20 00 00 00       	mov    $0x20,%eax
  801218:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80121b:	89 c1                	mov    %eax,%ecx
  80121d:	d3 ea                	shr    %cl,%edx
  80121f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801223:	0b 55 ec             	or     -0x14(%ebp),%edx
  801226:	d3 e6                	shl    %cl,%esi
  801228:	89 c1                	mov    %eax,%ecx
  80122a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80122d:	89 fe                	mov    %edi,%esi
  80122f:	d3 ee                	shr    %cl,%esi
  801231:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801235:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801238:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80123b:	d3 e7                	shl    %cl,%edi
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	d3 ea                	shr    %cl,%edx
  801241:	09 d7                	or     %edx,%edi
  801243:	89 f2                	mov    %esi,%edx
  801245:	89 f8                	mov    %edi,%eax
  801247:	f7 75 ec             	divl   -0x14(%ebp)
  80124a:	89 d6                	mov    %edx,%esi
  80124c:	89 c7                	mov    %eax,%edi
  80124e:	f7 65 e8             	mull   -0x18(%ebp)
  801251:	39 d6                	cmp    %edx,%esi
  801253:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801256:	72 30                	jb     801288 <__udivdi3+0x118>
  801258:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80125f:	d3 e2                	shl    %cl,%edx
  801261:	39 c2                	cmp    %eax,%edx
  801263:	73 05                	jae    80126a <__udivdi3+0xfa>
  801265:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801268:	74 1e                	je     801288 <__udivdi3+0x118>
  80126a:	89 f9                	mov    %edi,%ecx
  80126c:	31 ff                	xor    %edi,%edi
  80126e:	e9 71 ff ff ff       	jmp    8011e4 <__udivdi3+0x74>
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	31 ff                	xor    %edi,%edi
  80127a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80127f:	e9 60 ff ff ff       	jmp    8011e4 <__udivdi3+0x74>
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80128b:	31 ff                	xor    %edi,%edi
  80128d:	89 c8                	mov    %ecx,%eax
  80128f:	89 fa                	mov    %edi,%edx
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    
	...

008012a0 <__umoddi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	83 ec 20             	sub    $0x20,%esp
  8012a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b4:	85 d2                	test   %edx,%edx
  8012b6:	89 c8                	mov    %ecx,%eax
  8012b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8012bb:	75 13                	jne    8012d0 <__umoddi3+0x30>
  8012bd:	39 f7                	cmp    %esi,%edi
  8012bf:	76 3f                	jbe    801300 <__umoddi3+0x60>
  8012c1:	89 f2                	mov    %esi,%edx
  8012c3:	f7 f7                	div    %edi
  8012c5:	89 d0                	mov    %edx,%eax
  8012c7:	31 d2                	xor    %edx,%edx
  8012c9:	83 c4 20             	add    $0x20,%esp
  8012cc:	5e                   	pop    %esi
  8012cd:	5f                   	pop    %edi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    
  8012d0:	39 f2                	cmp    %esi,%edx
  8012d2:	77 4c                	ja     801320 <__umoddi3+0x80>
  8012d4:	0f bd ca             	bsr    %edx,%ecx
  8012d7:	83 f1 1f             	xor    $0x1f,%ecx
  8012da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8012dd:	75 51                	jne    801330 <__umoddi3+0x90>
  8012df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8012e2:	0f 87 e0 00 00 00    	ja     8013c8 <__umoddi3+0x128>
  8012e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012eb:	29 f8                	sub    %edi,%eax
  8012ed:	19 d6                	sbb    %edx,%esi
  8012ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f5:	89 f2                	mov    %esi,%edx
  8012f7:	83 c4 20             	add    $0x20,%esp
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    
  8012fe:	66 90                	xchg   %ax,%ax
  801300:	85 ff                	test   %edi,%edi
  801302:	75 0b                	jne    80130f <__umoddi3+0x6f>
  801304:	b8 01 00 00 00       	mov    $0x1,%eax
  801309:	31 d2                	xor    %edx,%edx
  80130b:	f7 f7                	div    %edi
  80130d:	89 c7                	mov    %eax,%edi
  80130f:	89 f0                	mov    %esi,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 f7                	div    %edi
  801315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801318:	f7 f7                	div    %edi
  80131a:	eb a9                	jmp    8012c5 <__umoddi3+0x25>
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 f2                	mov    %esi,%edx
  801324:	83 c4 20             	add    $0x20,%esp
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
  80132b:	90                   	nop
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801334:	d3 e2                	shl    %cl,%edx
  801336:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801339:	ba 20 00 00 00       	mov    $0x20,%edx
  80133e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801341:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801344:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801348:	89 fa                	mov    %edi,%edx
  80134a:	d3 ea                	shr    %cl,%edx
  80134c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801350:	0b 55 f4             	or     -0xc(%ebp),%edx
  801353:	d3 e7                	shl    %cl,%edi
  801355:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801359:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80135c:	89 f2                	mov    %esi,%edx
  80135e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801361:	89 c7                	mov    %eax,%edi
  801363:	d3 ea                	shr    %cl,%edx
  801365:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801369:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	d3 e6                	shl    %cl,%esi
  801370:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801374:	d3 ea                	shr    %cl,%edx
  801376:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80137a:	09 d6                	or     %edx,%esi
  80137c:	89 f0                	mov    %esi,%eax
  80137e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801381:	d3 e7                	shl    %cl,%edi
  801383:	89 f2                	mov    %esi,%edx
  801385:	f7 75 f4             	divl   -0xc(%ebp)
  801388:	89 d6                	mov    %edx,%esi
  80138a:	f7 65 e8             	mull   -0x18(%ebp)
  80138d:	39 d6                	cmp    %edx,%esi
  80138f:	72 2b                	jb     8013bc <__umoddi3+0x11c>
  801391:	39 c7                	cmp    %eax,%edi
  801393:	72 23                	jb     8013b8 <__umoddi3+0x118>
  801395:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801399:	29 c7                	sub    %eax,%edi
  80139b:	19 d6                	sbb    %edx,%esi
  80139d:	89 f0                	mov    %esi,%eax
  80139f:	89 f2                	mov    %esi,%edx
  8013a1:	d3 ef                	shr    %cl,%edi
  8013a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013a7:	d3 e0                	shl    %cl,%eax
  8013a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013ad:	09 f8                	or     %edi,%eax
  8013af:	d3 ea                	shr    %cl,%edx
  8013b1:	83 c4 20             	add    $0x20,%esp
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    
  8013b8:	39 d6                	cmp    %edx,%esi
  8013ba:	75 d9                	jne    801395 <__umoddi3+0xf5>
  8013bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8013bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8013c2:	eb d1                	jmp    801395 <__umoddi3+0xf5>
  8013c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	39 f2                	cmp    %esi,%edx
  8013ca:	0f 82 18 ff ff ff    	jb     8012e8 <__umoddi3+0x48>
  8013d0:	e9 1d ff ff ff       	jmp    8012f2 <__umoddi3+0x52>
