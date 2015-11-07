
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 92 10 00 00       	call   8010e4 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 00 14 80 00 	movl   $0x801400,(%esp)
  80007e:	e8 d6 00 00 00       	call   800159 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 ae 0f 00 00       	call   801036 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 e6 0f 00 00       	call   801076 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  8000a6:	e8 8b 0f 00 00       	call   801036 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	c1 e0 07             	shl    $0x7,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 6c ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 80 0f 00 00       	call   801076 <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	8b 45 0c             	mov    0xc(%ebp),%eax
  800118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011c:	8b 45 08             	mov    0x8(%ebp),%eax
  80011f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	c7 04 24 73 01 80 00 	movl   $0x800173,(%esp)
  800134:	e8 d4 01 00 00       	call   80030d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800139:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800149:	89 04 24             	mov    %eax,(%esp)
  80014c:	e8 1b 0b 00 00       	call   800c6c <sys_cputs>

	return b.cnt;
}
  800151:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80015f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800162:	89 44 24 04          	mov    %eax,0x4(%esp)
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 87 ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 14             	sub    $0x14,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	8b 55 08             	mov    0x8(%ebp),%edx
  800182:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800186:	83 c0 01             	add    $0x1,%eax
  800189:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	75 19                	jne    8001ab <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800192:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800199:	00 
  80019a:	8d 43 08             	lea    0x8(%ebx),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 c7 0a 00 00       	call   800c6c <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	83 c4 14             	add    $0x14,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	39 d1                	cmp    %edx,%ecx
  8001ed:	72 15                	jb     800204 <printnum+0x44>
  8001ef:	77 07                	ja     8001f8 <printnum+0x38>
  8001f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f4:	39 d0                	cmp    %edx,%eax
  8001f6:	76 0c                	jbe    800204 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	8d 76 00             	lea    0x0(%esi),%esi
  800200:	7f 61                	jg     800263 <printnum+0xa3>
  800202:	eb 70                	jmp    800274 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800217:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80021b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80021e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800221:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800224:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800239:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023d:	e8 4e 0f 00 00       	call   801190 <__udivdi3>
  800242:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800245:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	89 54 24 04          	mov    %edx,0x4(%esp)
  800257:	89 f2                	mov    %esi,%edx
  800259:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025c:	e8 5f ff ff ff       	call   8001c0 <printnum>
  800261:	eb 11                	jmp    800274 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800263:	89 74 24 04          	mov    %esi,0x4(%esp)
  800267:	89 3c 24             	mov    %edi,(%esp)
  80026a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f ef                	jg     800263 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800274:	89 74 24 04          	mov    %esi,0x4(%esp)
  800278:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028a:	00 
  80028b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80028e:	89 14 24             	mov    %edx,(%esp)
  800291:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800294:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800298:	e8 23 10 00 00       	call   8012c0 <__umoddi3>
  80029d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a1:	0f be 80 26 14 80 00 	movsbl 0x801426(%eax),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ae:	83 c4 4c             	add    $0x4c,%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7e 0e                	jle    8002cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ca:	eb 22                	jmp    8002ee <getuint+0x38>
	else if (lflag)
  8002cc:	85 d2                	test   %edx,%edx
  8002ce:	74 10                	je     8002e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	eb 0e                	jmp    8002ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ff:	73 0a                	jae    80030b <sprintputch+0x1b>
		*b->buf++ = ch;
  800301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800304:	88 0a                	mov    %cl,(%edx)
  800306:	83 c2 01             	add    $0x1,%edx
  800309:	89 10                	mov    %edx,(%eax)
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 5c             	sub    $0x5c,%esp
  800316:	8b 7d 08             	mov    0x8(%ebp),%edi
  800319:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80031f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800326:	eb 11                	jmp    800339 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800328:	85 c0                	test   %eax,%eax
  80032a:	0f 84 09 04 00 00    	je     800739 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800330:	89 74 24 04          	mov    %esi,0x4(%esp)
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	0f b6 03             	movzbl (%ebx),%eax
  80033c:	83 c3 01             	add    $0x1,%ebx
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e4                	jne    800328 <vprintfmt+0x1b>
  800344:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800348:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80034f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800356:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 06                	jmp    80036a <vprintfmt+0x5d>
  800364:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800368:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 13             	movzbl (%ebx),%edx
  80036d:	0f b6 c2             	movzbl %dl,%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	8d 43 01             	lea    0x1(%ebx),%eax
  800376:	83 ea 23             	sub    $0x23,%edx
  800379:	80 fa 55             	cmp    $0x55,%dl
  80037c:	0f 87 9a 03 00 00    	ja     80071c <vprintfmt+0x40f>
  800382:	0f b6 d2             	movzbl %dl,%edx
  800385:	ff 24 95 e0 14 80 00 	jmp    *0x8014e0(,%edx,4)
  80038c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800390:	eb d6                	jmp    800368 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800392:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800395:	83 ea 30             	sub    $0x30,%edx
  800398:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80039b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80039e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003a1:	83 fb 09             	cmp    $0x9,%ebx
  8003a4:	77 4c                	ja     8003f2 <vprintfmt+0xe5>
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003af:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003b2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003b6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003bc:	83 fb 09             	cmp    $0x9,%ebx
  8003bf:	76 eb                	jbe    8003ac <vprintfmt+0x9f>
  8003c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003c7:	eb 29                	jmp    8003f2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003d2:	8b 12                	mov    (%edx),%edx
  8003d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003d7:	eb 19                	jmp    8003f2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003dc:	c1 fa 1f             	sar    $0x1f,%edx
  8003df:	f7 d2                	not    %edx
  8003e1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003e4:	eb 82                	jmp    800368 <vprintfmt+0x5b>
  8003e6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003ed:	e9 76 ff ff ff       	jmp    800368 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f6:	0f 89 6c ff ff ff    	jns    800368 <vprintfmt+0x5b>
  8003fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800402:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800405:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800408:	e9 5b ff ff ff       	jmp    800368 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800410:	e9 53 ff ff ff       	jmp    800368 <vprintfmt+0x5b>
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	89 74 24 04          	mov    %esi,0x4(%esp)
  800425:	8b 00                	mov    (%eax),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff d7                	call   *%edi
  80042c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80042f:	e9 05 ff ff ff       	jmp    800339 <vprintfmt+0x2c>
  800434:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	8b 00                	mov    (%eax),%eax
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 fa 1f             	sar    $0x1f,%edx
  800447:	31 d0                	xor    %edx,%eax
  800449:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	83 f8 08             	cmp    $0x8,%eax
  80044e:	7f 0b                	jg     80045b <vprintfmt+0x14e>
  800450:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800457:	85 d2                	test   %edx,%edx
  800459:	75 20                	jne    80047b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80045b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045f:	c7 44 24 08 37 14 80 	movl   $0x801437,0x8(%esp)
  800466:	00 
  800467:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046b:	89 3c 24             	mov    %edi,(%esp)
  80046e:	e8 4e 03 00 00       	call   8007c1 <printfmt>
  800473:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800476:	e9 be fe ff ff       	jmp    800339 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80047b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047f:	c7 44 24 08 40 14 80 	movl   $0x801440,0x8(%esp)
  800486:	00 
  800487:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048b:	89 3c 24             	mov    %edi,(%esp)
  80048e:	e8 2e 03 00 00       	call   8007c1 <printfmt>
  800493:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800496:	e9 9e fe ff ff       	jmp    800339 <vprintfmt+0x2c>
  80049b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049e:	89 c3                	mov    %eax,%ebx
  8004a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	75 07                	jne    8004c2 <vprintfmt+0x1b5>
  8004bb:	c7 45 c4 43 14 80 00 	movl   $0x801443,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004c2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004c6:	7e 06                	jle    8004ce <vprintfmt+0x1c1>
  8004c8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004cc:	75 13                	jne    8004e1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d1:	0f be 02             	movsbl (%edx),%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	0f 85 99 00 00 00    	jne    800575 <vprintfmt+0x268>
  8004dc:	e9 86 00 00 00       	jmp    800567 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004e8:	89 0c 24             	mov    %ecx,(%esp)
  8004eb:	e8 1b 03 00 00       	call   80080b <strnlen>
  8004f0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f8:	85 d2                	test   %edx,%edx
  8004fa:	7e d2                	jle    8004ce <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004fc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800500:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800503:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800506:	89 d3                	mov    %edx,%ebx
  800508:	89 74 24 04          	mov    %esi,0x4(%esp)
  80050c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 eb 01             	sub    $0x1,%ebx
  800517:	85 db                	test   %ebx,%ebx
  800519:	7f ed                	jg     800508 <vprintfmt+0x1fb>
  80051b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80051e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800525:	eb a7                	jmp    8004ce <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800527:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80052b:	74 18                	je     800545 <vprintfmt+0x238>
  80052d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800530:	83 fa 5e             	cmp    $0x5e,%edx
  800533:	76 10                	jbe    800545 <vprintfmt+0x238>
					putch('?', putdat);
  800535:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800539:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800540:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800543:	eb 0a                	jmp    80054f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	89 04 24             	mov    %eax,(%esp)
  80054c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800553:	0f be 03             	movsbl (%ebx),%eax
  800556:	85 c0                	test   %eax,%eax
  800558:	74 05                	je     80055f <vprintfmt+0x252>
  80055a:	83 c3 01             	add    $0x1,%ebx
  80055d:	eb 29                	jmp    800588 <vprintfmt+0x27b>
  80055f:	89 fe                	mov    %edi,%esi
  800561:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800564:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800567:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056b:	7f 2e                	jg     80059b <vprintfmt+0x28e>
  80056d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800570:	e9 c4 fd ff ff       	jmp    800339 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800578:	83 c2 01             	add    $0x1,%edx
  80057b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80057e:	89 f7                	mov    %esi,%edi
  800580:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800583:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800586:	89 d3                	mov    %edx,%ebx
  800588:	85 f6                	test   %esi,%esi
  80058a:	78 9b                	js     800527 <vprintfmt+0x21a>
  80058c:	83 ee 01             	sub    $0x1,%esi
  80058f:	79 96                	jns    800527 <vprintfmt+0x21a>
  800591:	89 fe                	mov    %edi,%esi
  800593:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800596:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800599:	eb cc                	jmp    800567 <vprintfmt+0x25a>
  80059b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80059e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ac:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ae:	83 eb 01             	sub    $0x1,%ebx
  8005b1:	85 db                	test   %ebx,%ebx
  8005b3:	7f ec                	jg     8005a1 <vprintfmt+0x294>
  8005b5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b8:	e9 7c fd ff ff       	jmp    800339 <vprintfmt+0x2c>
  8005bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 f9 01             	cmp    $0x1,%ecx
  8005c3:	7e 16                	jle    8005db <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 08             	lea    0x8(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 10                	mov    (%eax),%edx
  8005d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005d6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005d9:	eb 32                	jmp    80060d <vprintfmt+0x300>
	else if (lflag)
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005f5:	eb 16                	jmp    80060d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800605:	89 c2                	mov    %eax,%edx
  800607:	c1 fa 1f             	sar    $0x1f,%edx
  80060a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800610:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800618:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061c:	0f 89 b8 00 00 00    	jns    8006da <vprintfmt+0x3cd>
				putch('-', putdat);
  800622:	89 74 24 04          	mov    %esi,0x4(%esp)
  800626:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062d:	ff d7                	call   *%edi
				num = -(long long) num;
  80062f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800632:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800635:	f7 d9                	neg    %ecx
  800637:	83 d3 00             	adc    $0x0,%ebx
  80063a:	f7 db                	neg    %ebx
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800641:	e9 94 00 00 00       	jmp    8006da <vprintfmt+0x3cd>
  800646:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800649:	89 ca                	mov    %ecx,%edx
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 63 fc ff ff       	call   8002b6 <getuint>
  800653:	89 c1                	mov    %eax,%ecx
  800655:	89 d3                	mov    %edx,%ebx
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80065c:	eb 7c                	jmp    8006da <vprintfmt+0x3cd>
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80066c:	ff d7                	call   *%edi
			putch('X', putdat);
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800679:	ff d7                	call   *%edi
			putch('X', putdat);
  80067b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800686:	ff d7                	call   *%edi
  800688:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80068b:	e9 a9 fc ff ff       	jmp    800339 <vprintfmt+0x2c>
  800690:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800693:	89 74 24 04          	mov    %esi,0x4(%esp)
  800697:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069e:	ff d7                	call   *%edi
			putch('x', putdat);
  8006a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ab:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b6:	8b 08                	mov    (%eax),%ecx
  8006b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c2:	eb 16                	jmp    8006da <vprintfmt+0x3cd>
  8006c4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c7:	89 ca                	mov    %ecx,%edx
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 e5 fb ff ff       	call   8002b6 <getuint>
  8006d1:	89 c1                	mov    %eax,%ecx
  8006d3:	89 d3                	mov    %edx,%ebx
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006da:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006de:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ed:	89 0c 24             	mov    %ecx,(%esp)
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	89 f2                	mov    %esi,%edx
  8006f6:	89 f8                	mov    %edi,%eax
  8006f8:	e8 c3 fa ff ff       	call   8001c0 <printnum>
  8006fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800700:	e9 34 fc ff ff       	jmp    800339 <vprintfmt+0x2c>
  800705:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800708:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80070f:	89 14 24             	mov    %edx,(%esp)
  800712:	ff d7                	call   *%edi
  800714:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800717:	e9 1d fc ff ff       	jmp    800339 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800720:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800727:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800729:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80072c:	80 38 25             	cmpb   $0x25,(%eax)
  80072f:	0f 84 04 fc ff ff    	je     800339 <vprintfmt+0x2c>
  800735:	89 c3                	mov    %eax,%ebx
  800737:	eb f0                	jmp    800729 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800739:	83 c4 5c             	add    $0x5c,%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5e                   	pop    %esi
  80073e:	5f                   	pop    %edi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 28             	sub    $0x28,%esp
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80074d:	85 c0                	test   %eax,%eax
  80074f:	74 04                	je     800755 <vsnprintf+0x14>
  800751:	85 d2                	test   %edx,%edx
  800753:	7f 07                	jg     80075c <vsnprintf+0x1b>
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075a:	eb 3b                	jmp    800797 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800763:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800774:	8b 45 10             	mov    0x10(%ebp),%eax
  800777:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800782:	c7 04 24 f0 02 80 00 	movl   $0x8002f0,(%esp)
  800789:	e8 7f fb ff ff       	call   80030d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800791:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800794:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 82 ff ff ff       	call   800741 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 26 fb ff ff       	call   80030d <vprintfmt>
	va_end(ap);
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    
  8007e9:	00 00                	add    %al,(%eax)
  8007eb:	00 00                	add    %al,(%eax)
  8007ed:	00 00                	add    %al,(%eax)
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fe:	74 09                	je     800809 <strlen+0x19>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	85 c9                	test   %ecx,%ecx
  800817:	74 19                	je     800832 <strnlen+0x27>
  800819:	80 3b 00             	cmpb   $0x0,(%ebx)
  80081c:	74 14                	je     800832 <strnlen+0x27>
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800823:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	39 c8                	cmp    %ecx,%eax
  800828:	74 0d                	je     800837 <strnlen+0x2c>
  80082a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80082e:	75 f3                	jne    800823 <strnlen+0x18>
  800830:	eb 05                	jmp    800837 <strnlen+0x2c>
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800844:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800849:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80084d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	84 c9                	test   %cl,%cl
  800855:	75 f2                	jne    800849 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800864:	89 1c 24             	mov    %ebx,(%esp)
  800867:	e8 84 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800873:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 bc ff ff ff       	call   80083a <strcpy>
	return dst;
}
  80087e:	89 d8                	mov    %ebx,%eax
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	85 f6                	test   %esi,%esi
  800896:	74 18                	je     8008b0 <strncpy+0x2a>
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80089d:	0f b6 1a             	movzbl (%edx),%ebx
  8008a0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	39 ce                	cmp    %ecx,%esi
  8008ae:	77 ed                	ja     80089d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 27                	je     8008ef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008c8:	83 e9 01             	sub    $0x1,%ecx
  8008cb:	74 1d                	je     8008ea <strlcpy+0x36>
  8008cd:	0f b6 1a             	movzbl (%edx),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	74 16                	je     8008ea <strlcpy+0x36>
			*dst++ = *src++;
  8008d4:	88 18                	mov    %bl,(%eax)
  8008d6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d9:	83 e9 01             	sub    $0x1,%ecx
  8008dc:	74 0e                	je     8008ec <strlcpy+0x38>
			*dst++ = *src++;
  8008de:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e1:	0f b6 1a             	movzbl (%edx),%ebx
  8008e4:	84 db                	test   %bl,%bl
  8008e6:	75 ec                	jne    8008d4 <strlcpy+0x20>
  8008e8:	eb 02                	jmp    8008ec <strlcpy+0x38>
  8008ea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ec:	c6 00 00             	movb   $0x0,(%eax)
  8008ef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fe:	0f b6 01             	movzbl (%ecx),%eax
  800901:	84 c0                	test   %al,%al
  800903:	74 15                	je     80091a <strcmp+0x25>
  800905:	3a 02                	cmp    (%edx),%al
  800907:	75 11                	jne    80091a <strcmp+0x25>
		p++, q++;
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090f:	0f b6 01             	movzbl (%ecx),%eax
  800912:	84 c0                	test   %al,%al
  800914:	74 04                	je     80091a <strcmp+0x25>
  800916:	3a 02                	cmp    (%edx),%al
  800918:	74 ef                	je     800909 <strcmp+0x14>
  80091a:	0f b6 c0             	movzbl %al,%eax
  80091d:	0f b6 12             	movzbl (%edx),%edx
  800920:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	8b 55 08             	mov    0x8(%ebp),%edx
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800931:	85 c0                	test   %eax,%eax
  800933:	74 23                	je     800958 <strncmp+0x34>
  800935:	0f b6 1a             	movzbl (%edx),%ebx
  800938:	84 db                	test   %bl,%bl
  80093a:	74 25                	je     800961 <strncmp+0x3d>
  80093c:	3a 19                	cmp    (%ecx),%bl
  80093e:	75 21                	jne    800961 <strncmp+0x3d>
  800940:	83 e8 01             	sub    $0x1,%eax
  800943:	74 13                	je     800958 <strncmp+0x34>
		n--, p++, q++;
  800945:	83 c2 01             	add    $0x1,%edx
  800948:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094b:	0f b6 1a             	movzbl (%edx),%ebx
  80094e:	84 db                	test   %bl,%bl
  800950:	74 0f                	je     800961 <strncmp+0x3d>
  800952:	3a 19                	cmp    (%ecx),%bl
  800954:	74 ea                	je     800940 <strncmp+0x1c>
  800956:	eb 09                	jmp    800961 <strncmp+0x3d>
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	90                   	nop
  800960:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800961:	0f b6 02             	movzbl (%edx),%eax
  800964:	0f b6 11             	movzbl (%ecx),%edx
  800967:	29 d0                	sub    %edx,%eax
  800969:	eb f2                	jmp    80095d <strncmp+0x39>

0080096b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 18                	je     800994 <strchr+0x29>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	75 0a                	jne    80098a <strchr+0x1f>
  800980:	eb 17                	jmp    800999 <strchr+0x2e>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800988:	74 0f                	je     800999 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 ee                	jne    800982 <strchr+0x17>
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 18                	je     8009c4 <strfind+0x29>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	75 0a                	jne    8009ba <strfind+0x1f>
  8009b0:	eb 12                	jmp    8009c4 <strfind+0x29>
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009b8:	74 0a                	je     8009c4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 ee                	jne    8009b2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	89 1c 24             	mov    %ebx,(%esp)
  8009cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	74 30                	je     800a14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ea:	75 25                	jne    800a11 <memset+0x4b>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 20                	jne    800a11 <memset+0x4b>
		c &= 0xFF;
  8009f1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f4:	89 d3                	mov    %edx,%ebx
  8009f6:	c1 e3 08             	shl    $0x8,%ebx
  8009f9:	89 d6                	mov    %edx,%esi
  8009fb:	c1 e6 18             	shl    $0x18,%esi
  8009fe:	89 d0                	mov    %edx,%eax
  800a00:	c1 e0 10             	shl    $0x10,%eax
  800a03:	09 f0                	or     %esi,%eax
  800a05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a07:	09 d8                	or     %ebx,%eax
  800a09:	c1 e9 02             	shr    $0x2,%ecx
  800a0c:	fc                   	cld    
  800a0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0f:	eb 03                	jmp    800a14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a11:	fc                   	cld    
  800a12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	8b 1c 24             	mov    (%esp),%ebx
  800a19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a21:	89 ec                	mov    %ebp,%esp
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
  800a2b:	89 34 24             	mov    %esi,(%esp)
  800a2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a3d:	39 c6                	cmp    %eax,%esi
  800a3f:	73 35                	jae    800a76 <memmove+0x51>
  800a41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a44:	39 d0                	cmp    %edx,%eax
  800a46:	73 2e                	jae    800a76 <memmove+0x51>
		s += n;
		d += n;
  800a48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4a:	f6 c2 03             	test   $0x3,%dl
  800a4d:	75 1b                	jne    800a6a <memmove+0x45>
  800a4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a55:	75 13                	jne    800a6a <memmove+0x45>
  800a57:	f6 c1 03             	test   $0x3,%cl
  800a5a:	75 0e                	jne    800a6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a5c:	83 ef 04             	sub    $0x4,%edi
  800a5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a62:	c1 e9 02             	shr    $0x2,%ecx
  800a65:	fd                   	std    
  800a66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	eb 09                	jmp    800a73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6a:	83 ef 01             	sub    $0x1,%edi
  800a6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a70:	fd                   	std    
  800a71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a74:	eb 20                	jmp    800a96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7c:	75 15                	jne    800a93 <memmove+0x6e>
  800a7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a84:	75 0d                	jne    800a93 <memmove+0x6e>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 08                	jne    800a93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a8b:	c1 e9 02             	shr    $0x2,%ecx
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	eb 03                	jmp    800a96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	8b 34 24             	mov    (%esp),%esi
  800a99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a9d:	89 ec                	mov    %ebp,%esp
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	89 04 24             	mov    %eax,(%esp)
  800abb:	e8 65 ff ff ff       	call   800a25 <memmove>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 75 08             	mov    0x8(%ebp),%esi
  800acb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	85 c9                	test   %ecx,%ecx
  800ad3:	74 36                	je     800b0b <memcmp+0x49>
		if (*s1 != *s2)
  800ad5:	0f b6 06             	movzbl (%esi),%eax
  800ad8:	0f b6 1f             	movzbl (%edi),%ebx
  800adb:	38 d8                	cmp    %bl,%al
  800add:	74 20                	je     800aff <memcmp+0x3d>
  800adf:	eb 14                	jmp    800af5 <memcmp+0x33>
  800ae1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ae6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800aeb:	83 c2 01             	add    $0x1,%edx
  800aee:	83 e9 01             	sub    $0x1,%ecx
  800af1:	38 d8                	cmp    %bl,%al
  800af3:	74 12                	je     800b07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 db             	movzbl %bl,%ebx
  800afb:	29 d8                	sub    %ebx,%eax
  800afd:	eb 11                	jmp    800b10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aff:	83 e9 01             	sub    $0x1,%ecx
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	85 c9                	test   %ecx,%ecx
  800b09:	75 d6                	jne    800ae1 <memcmp+0x1f>
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b20:	39 d0                	cmp    %edx,%eax
  800b22:	73 15                	jae    800b39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b28:	38 08                	cmp    %cl,(%eax)
  800b2a:	75 06                	jne    800b32 <memfind+0x1d>
  800b2c:	eb 0b                	jmp    800b39 <memfind+0x24>
  800b2e:	38 08                	cmp    %cl,(%eax)
  800b30:	74 07                	je     800b39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
  800b35:	39 c2                	cmp    %eax,%edx
  800b37:	77 f5                	ja     800b2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 04             	sub    $0x4,%esp
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4a:	0f b6 02             	movzbl (%edx),%eax
  800b4d:	3c 20                	cmp    $0x20,%al
  800b4f:	74 04                	je     800b55 <strtol+0x1a>
  800b51:	3c 09                	cmp    $0x9,%al
  800b53:	75 0e                	jne    800b63 <strtol+0x28>
		s++;
  800b55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b58:	0f b6 02             	movzbl (%edx),%eax
  800b5b:	3c 20                	cmp    $0x20,%al
  800b5d:	74 f6                	je     800b55 <strtol+0x1a>
  800b5f:	3c 09                	cmp    $0x9,%al
  800b61:	74 f2                	je     800b55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b63:	3c 2b                	cmp    $0x2b,%al
  800b65:	75 0c                	jne    800b73 <strtol+0x38>
		s++;
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b71:	eb 15                	jmp    800b88 <strtol+0x4d>
	else if (*s == '-')
  800b73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b7a:	3c 2d                	cmp    $0x2d,%al
  800b7c:	75 0a                	jne    800b88 <strtol+0x4d>
		s++, neg = 1;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b88:	85 db                	test   %ebx,%ebx
  800b8a:	0f 94 c0             	sete   %al
  800b8d:	74 05                	je     800b94 <strtol+0x59>
  800b8f:	83 fb 10             	cmp    $0x10,%ebx
  800b92:	75 18                	jne    800bac <strtol+0x71>
  800b94:	80 3a 30             	cmpb   $0x30,(%edx)
  800b97:	75 13                	jne    800bac <strtol+0x71>
  800b99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ba0:	75 0a                	jne    800bac <strtol+0x71>
		s += 2, base = 16;
  800ba2:	83 c2 02             	add    $0x2,%edx
  800ba5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baa:	eb 15                	jmp    800bc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bac:	84 c0                	test   %al,%al
  800bae:	66 90                	xchg   %ax,%ax
  800bb0:	74 0f                	je     800bc1 <strtol+0x86>
  800bb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bba:	75 05                	jne    800bc1 <strtol+0x86>
		s++, base = 8;
  800bbc:	83 c2 01             	add    $0x1,%edx
  800bbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc8:	0f b6 0a             	movzbl (%edx),%ecx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bd0:	80 fb 09             	cmp    $0x9,%bl
  800bd3:	77 08                	ja     800bdd <strtol+0xa2>
			dig = *s - '0';
  800bd5:	0f be c9             	movsbl %cl,%ecx
  800bd8:	83 e9 30             	sub    $0x30,%ecx
  800bdb:	eb 1e                	jmp    800bfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bdd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 08                	ja     800bed <strtol+0xb2>
			dig = *s - 'a' + 10;
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 57             	sub    $0x57,%ecx
  800beb:	eb 0e                	jmp    800bfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bed:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bf0:	80 fb 19             	cmp    $0x19,%bl
  800bf3:	77 15                	ja     800c0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bfb:	39 f1                	cmp    %esi,%ecx
  800bfd:	7d 0b                	jge    800c0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bff:	83 c2 01             	add    $0x1,%edx
  800c02:	0f af c6             	imul   %esi,%eax
  800c05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c08:	eb be                	jmp    800bc8 <strtol+0x8d>
  800c0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c10:	74 05                	je     800c17 <strtol+0xdc>
		*endptr = (char *) s;
  800c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c1b:	74 04                	je     800c21 <strtol+0xe6>
  800c1d:	89 c8                	mov    %ecx,%eax
  800c1f:	f7 d8                	neg    %eax
}
  800c21:	83 c4 04             	add    $0x4,%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
  800c29:	00 00                	add    %al,(%eax)
	...

00800c2c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800c39:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c43:	89 d1                	mov    %edx,%ecx
  800c45:	89 d3                	mov    %edx,%ebx
  800c47:	89 d7                	mov    %edx,%edi
  800c49:	51                   	push   %ecx
  800c4a:	52                   	push   %edx
  800c4b:	53                   	push   %ebx
  800c4c:	54                   	push   %esp
  800c4d:	55                   	push   %ebp
  800c4e:	56                   	push   %esi
  800c4f:	57                   	push   %edi
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	8d 35 5a 0c 80 00    	lea    0x800c5a,%esi
  800c58:	0f 34                	sysenter 
  800c5a:	5f                   	pop    %edi
  800c5b:	5e                   	pop    %esi
  800c5c:	5d                   	pop    %ebp
  800c5d:	5c                   	pop    %esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5a                   	pop    %edx
  800c60:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c61:	8b 1c 24             	mov    (%esp),%ebx
  800c64:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c68:	89 ec                	mov    %ebp,%esp
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800c79:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 c3                	mov    %eax,%ebx
  800c86:	89 c7                	mov    %eax,%edi
  800c88:	51                   	push   %ecx
  800c89:	52                   	push   %edx
  800c8a:	53                   	push   %ebx
  800c8b:	54                   	push   %esp
  800c8c:	55                   	push   %ebp
  800c8d:	56                   	push   %esi
  800c8e:	57                   	push   %edi
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	8d 35 99 0c 80 00    	lea    0x800c99,%esi
  800c97:	0f 34                	sysenter 
  800c99:	5f                   	pop    %edi
  800c9a:	5e                   	pop    %esi
  800c9b:	5d                   	pop    %ebp
  800c9c:	5c                   	pop    %esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5a                   	pop    %edx
  800c9f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca0:	8b 1c 24             	mov    (%esp),%ebx
  800ca3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ca7:	89 ec                	mov    %ebp,%esp
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 08             	sub    $0x8,%esp
  800cb1:	89 1c 24             	mov    %ebx,(%esp)
  800cb4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbd:	b8 0e 00 00 00       	mov    $0xe,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ce1:	8b 1c 24             	mov    (%esp),%ebx
  800ce4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ce8:	89 ec                	mov    %ebp,%esp
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 28             	sub    $0x28,%esp
  800cf2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cf5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfd:	b8 0d 00 00 00       	mov    $0xd,%eax
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7e 28                	jle    800d4d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d29:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d30:	00 
  800d31:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800d38:	00 
  800d39:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800d40:	00 
  800d41:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800d48:	e8 cf 03 00 00       	call   80111c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d53:	89 ec                	mov    %ebp,%esp
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	83 ec 08             	sub    $0x8,%esp
  800d5d:	89 1c 24             	mov    %ebx,(%esp)
  800d60:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	51                   	push   %ecx
  800d76:	52                   	push   %edx
  800d77:	53                   	push   %ebx
  800d78:	54                   	push   %esp
  800d79:	55                   	push   %ebp
  800d7a:	56                   	push   %esi
  800d7b:	57                   	push   %edi
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	8d 35 86 0d 80 00    	lea    0x800d86,%esi
  800d84:	0f 34                	sysenter 
  800d86:	5f                   	pop    %edi
  800d87:	5e                   	pop    %esi
  800d88:	5d                   	pop    %ebp
  800d89:	5c                   	pop    %esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5a                   	pop    %edx
  800d8c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8d:	8b 1c 24             	mov    (%esp),%ebx
  800d90:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d94:	89 ec                	mov    %ebp,%esp
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 28             	sub    $0x28,%esp
  800d9e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800da1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	51                   	push   %ecx
  800db7:	52                   	push   %edx
  800db8:	53                   	push   %ebx
  800db9:	54                   	push   %esp
  800dba:	55                   	push   %ebp
  800dbb:	56                   	push   %esi
  800dbc:	57                   	push   %edi
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	8d 35 c7 0d 80 00    	lea    0x800dc7,%esi
  800dc5:	0f 34                	sysenter 
  800dc7:	5f                   	pop    %edi
  800dc8:	5e                   	pop    %esi
  800dc9:	5d                   	pop    %ebp
  800dca:	5c                   	pop    %esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5a                   	pop    %edx
  800dcd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 28                	jle    800dfa <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ddd:	00 
  800dde:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800de5:	00 
  800de6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ded:	00 
  800dee:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800df5:	e8 22 03 00 00       	call   80111c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800dfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e00:	89 ec                	mov    %ebp,%esp
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 28             	sub    $0x28,%esp
  800e0a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e0d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	51                   	push   %ecx
  800e23:	52                   	push   %edx
  800e24:	53                   	push   %ebx
  800e25:	54                   	push   %esp
  800e26:	55                   	push   %ebp
  800e27:	56                   	push   %esi
  800e28:	57                   	push   %edi
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	8d 35 33 0e 80 00    	lea    0x800e33,%esi
  800e31:	0f 34                	sysenter 
  800e33:	5f                   	pop    %edi
  800e34:	5e                   	pop    %esi
  800e35:	5d                   	pop    %ebp
  800e36:	5c                   	pop    %esp
  800e37:	5b                   	pop    %ebx
  800e38:	5a                   	pop    %edx
  800e39:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 28                	jle    800e66 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e42:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e49:	00 
  800e4a:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800e61:	e8 b6 02 00 00       	call   80111c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e66:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e69:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6c:	89 ec                	mov    %ebp,%esp
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 28             	sub    $0x28,%esp
  800e76:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e79:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	b8 07 00 00 00       	mov    $0x7,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	89 df                	mov    %ebx,%edi
  800e8e:	51                   	push   %ecx
  800e8f:	52                   	push   %edx
  800e90:	53                   	push   %ebx
  800e91:	54                   	push   %esp
  800e92:	55                   	push   %ebp
  800e93:	56                   	push   %esi
  800e94:	57                   	push   %edi
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8d 35 9f 0e 80 00    	lea    0x800e9f,%esi
  800e9d:	0f 34                	sysenter 
  800e9f:	5f                   	pop    %edi
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	5c                   	pop    %esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5a                   	pop    %edx
  800ea5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 28                	jle    800ed2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eae:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ec5:	00 
  800ec6:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800ecd:	e8 4a 02 00 00       	call   80111c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ed2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 28             	sub    $0x28,%esp
  800ee2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ee5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee8:	b8 06 00 00 00       	mov    $0x6,%eax
  800eed:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	51                   	push   %ecx
  800efa:	52                   	push   %edx
  800efb:	53                   	push   %ebx
  800efc:	54                   	push   %esp
  800efd:	55                   	push   %ebp
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	8d 35 0a 0f 80 00    	lea    0x800f0a,%esi
  800f08:	0f 34                	sysenter 
  800f0a:	5f                   	pop    %edi
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	5c                   	pop    %esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5a                   	pop    %edx
  800f10:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7e 28                	jle    800f3d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f19:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f20:	00 
  800f21:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f38:	e8 df 01 00 00       	call   80111c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f3d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f43:	89 ec                	mov    %ebp,%esp
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 28             	sub    $0x28,%esp
  800f4d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f50:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f53:	bf 00 00 00 00       	mov    $0x0,%edi
  800f58:	b8 05 00 00 00       	mov    $0x5,%eax
  800f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	51                   	push   %ecx
  800f67:	52                   	push   %edx
  800f68:	53                   	push   %ebx
  800f69:	54                   	push   %esp
  800f6a:	55                   	push   %ebp
  800f6b:	56                   	push   %esi
  800f6c:	57                   	push   %edi
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	8d 35 77 0f 80 00    	lea    0x800f77,%esi
  800f75:	0f 34                	sysenter 
  800f77:	5f                   	pop    %edi
  800f78:	5e                   	pop    %esi
  800f79:	5d                   	pop    %ebp
  800f7a:	5c                   	pop    %esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5a                   	pop    %edx
  800f7d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800fa5:	e8 72 01 00 00       	call   80111c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800faa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb0:	89 ec                	mov    %ebp,%esp
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  800fc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fcb:	89 d1                	mov    %edx,%ecx
  800fcd:	89 d3                	mov    %edx,%ebx
  800fcf:	89 d7                	mov    %edx,%edi
  800fd1:	51                   	push   %ecx
  800fd2:	52                   	push   %edx
  800fd3:	53                   	push   %ebx
  800fd4:	54                   	push   %esp
  800fd5:	55                   	push   %ebp
  800fd6:	56                   	push   %esi
  800fd7:	57                   	push   %edi
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	8d 35 e2 0f 80 00    	lea    0x800fe2,%esi
  800fe0:	0f 34                	sysenter 
  800fe2:	5f                   	pop    %edi
  800fe3:	5e                   	pop    %esi
  800fe4:	5d                   	pop    %ebp
  800fe5:	5c                   	pop    %esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5a                   	pop    %edx
  800fe8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fe9:	8b 1c 24             	mov    (%esp),%ebx
  800fec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff0:	89 ec                	mov    %ebp,%esp
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
  801006:	b8 04 00 00 00       	mov    $0x4,%eax
  80100b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100e:	8b 55 08             	mov    0x8(%ebp),%edx
  801011:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80102b:	8b 1c 24             	mov    (%esp),%ebx
  80102e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801032:	89 ec                	mov    %ebp,%esp
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 08             	sub    $0x8,%esp
  80103c:	89 1c 24             	mov    %ebx,(%esp)
  80103f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801043:	ba 00 00 00 00       	mov    $0x0,%edx
  801048:	b8 02 00 00 00       	mov    $0x2,%eax
  80104d:	89 d1                	mov    %edx,%ecx
  80104f:	89 d3                	mov    %edx,%ebx
  801051:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80106b:	8b 1c 24             	mov    (%esp),%ebx
  80106e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801072:	89 ec                	mov    %ebp,%esp
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 28             	sub    $0x28,%esp
  80107c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80107f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801082:	b9 00 00 00 00       	mov    $0x0,%ecx
  801087:	b8 03 00 00 00       	mov    $0x3,%eax
  80108c:	8b 55 08             	mov    0x8(%ebp),%edx
  80108f:	89 cb                	mov    %ecx,%ebx
  801091:	89 cf                	mov    %ecx,%edi
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	7e 28                	jle    8010d7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010ba:	00 
  8010bb:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010ca:	00 
  8010cb:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  8010d2:	e8 45 00 00 00       	call   80111c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010d7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010da:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010dd:	89 ec                	mov    %ebp,%esp
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    
  8010e1:	00 00                	add    %al,(%eax)
	...

008010e4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010ea:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010f1:	75 1c                	jne    80110f <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8010f3:	c7 44 24 08 90 16 80 	movl   $0x801690,0x8(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801102:	00 
  801103:	c7 04 24 b4 16 80 00 	movl   $0x8016b4,(%esp)
  80110a:	e8 0d 00 00 00       	call   80111c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801117:	c9                   	leave  
  801118:	c3                   	ret    
  801119:	00 00                	add    %al,(%eax)
	...

0080111c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801124:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801127:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80112c:	85 c0                	test   %eax,%eax
  80112e:	74 10                	je     801140 <_panic+0x24>
		cprintf("%s: ", argv0);
  801130:	89 44 24 04          	mov    %eax,0x4(%esp)
  801134:	c7 04 24 c2 16 80 00 	movl   $0x8016c2,(%esp)
  80113b:	e8 19 f0 ff ff       	call   800159 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801140:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801146:	e8 eb fe ff ff       	call   801036 <sys_getenvid>
  80114b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801152:	8b 55 08             	mov    0x8(%ebp),%edx
  801155:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80115d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801161:	c7 04 24 c8 16 80 00 	movl   $0x8016c8,(%esp)
  801168:	e8 ec ef ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80116d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801171:	8b 45 10             	mov    0x10(%ebp),%eax
  801174:	89 04 24             	mov    %eax,(%esp)
  801177:	e8 7c ef ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  80117c:	c7 04 24 1a 14 80 00 	movl   $0x80141a,(%esp)
  801183:	e8 d1 ef ff ff       	call   800159 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801188:	cc                   	int3   
  801189:	eb fd                	jmp    801188 <_panic+0x6c>
  80118b:	00 00                	add    %al,(%eax)
  80118d:	00 00                	add    %al,(%eax)
	...

00801190 <__udivdi3>:
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	83 ec 10             	sub    $0x10,%esp
  801198:	8b 45 14             	mov    0x14(%ebp),%eax
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
  80119e:	8b 75 10             	mov    0x10(%ebp),%esi
  8011a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011a9:	75 35                	jne    8011e0 <__udivdi3+0x50>
  8011ab:	39 fe                	cmp    %edi,%esi
  8011ad:	77 61                	ja     801210 <__udivdi3+0x80>
  8011af:	85 f6                	test   %esi,%esi
  8011b1:	75 0b                	jne    8011be <__udivdi3+0x2e>
  8011b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b8:	31 d2                	xor    %edx,%edx
  8011ba:	f7 f6                	div    %esi
  8011bc:	89 c6                	mov    %eax,%esi
  8011be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8011c1:	31 d2                	xor    %edx,%edx
  8011c3:	89 f8                	mov    %edi,%eax
  8011c5:	f7 f6                	div    %esi
  8011c7:	89 c7                	mov    %eax,%edi
  8011c9:	89 c8                	mov    %ecx,%eax
  8011cb:	f7 f6                	div    %esi
  8011cd:	89 c1                	mov    %eax,%ecx
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	89 c8                	mov    %ecx,%eax
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    
  8011da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011e0:	39 f8                	cmp    %edi,%eax
  8011e2:	77 1c                	ja     801200 <__udivdi3+0x70>
  8011e4:	0f bd d0             	bsr    %eax,%edx
  8011e7:	83 f2 1f             	xor    $0x1f,%edx
  8011ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011ed:	75 39                	jne    801228 <__udivdi3+0x98>
  8011ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8011f2:	0f 86 a0 00 00 00    	jbe    801298 <__udivdi3+0x108>
  8011f8:	39 f8                	cmp    %edi,%eax
  8011fa:	0f 82 98 00 00 00    	jb     801298 <__udivdi3+0x108>
  801200:	31 ff                	xor    %edi,%edi
  801202:	31 c9                	xor    %ecx,%ecx
  801204:	89 c8                	mov    %ecx,%eax
  801206:	89 fa                	mov    %edi,%edx
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    
  80120f:	90                   	nop
  801210:	89 d1                	mov    %edx,%ecx
  801212:	89 fa                	mov    %edi,%edx
  801214:	89 c8                	mov    %ecx,%eax
  801216:	31 ff                	xor    %edi,%edi
  801218:	f7 f6                	div    %esi
  80121a:	89 c1                	mov    %eax,%ecx
  80121c:	89 fa                	mov    %edi,%edx
  80121e:	89 c8                	mov    %ecx,%eax
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    
  801227:	90                   	nop
  801228:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80122c:	89 f2                	mov    %esi,%edx
  80122e:	d3 e0                	shl    %cl,%eax
  801230:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801233:	b8 20 00 00 00       	mov    $0x20,%eax
  801238:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80123b:	89 c1                	mov    %eax,%ecx
  80123d:	d3 ea                	shr    %cl,%edx
  80123f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801243:	0b 55 ec             	or     -0x14(%ebp),%edx
  801246:	d3 e6                	shl    %cl,%esi
  801248:	89 c1                	mov    %eax,%ecx
  80124a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80124d:	89 fe                	mov    %edi,%esi
  80124f:	d3 ee                	shr    %cl,%esi
  801251:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801255:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801258:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125b:	d3 e7                	shl    %cl,%edi
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	d3 ea                	shr    %cl,%edx
  801261:	09 d7                	or     %edx,%edi
  801263:	89 f2                	mov    %esi,%edx
  801265:	89 f8                	mov    %edi,%eax
  801267:	f7 75 ec             	divl   -0x14(%ebp)
  80126a:	89 d6                	mov    %edx,%esi
  80126c:	89 c7                	mov    %eax,%edi
  80126e:	f7 65 e8             	mull   -0x18(%ebp)
  801271:	39 d6                	cmp    %edx,%esi
  801273:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801276:	72 30                	jb     8012a8 <__udivdi3+0x118>
  801278:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80127b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80127f:	d3 e2                	shl    %cl,%edx
  801281:	39 c2                	cmp    %eax,%edx
  801283:	73 05                	jae    80128a <__udivdi3+0xfa>
  801285:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801288:	74 1e                	je     8012a8 <__udivdi3+0x118>
  80128a:	89 f9                	mov    %edi,%ecx
  80128c:	31 ff                	xor    %edi,%edi
  80128e:	e9 71 ff ff ff       	jmp    801204 <__udivdi3+0x74>
  801293:	90                   	nop
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	31 ff                	xor    %edi,%edi
  80129a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80129f:	e9 60 ff ff ff       	jmp    801204 <__udivdi3+0x74>
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8012ab:	31 ff                	xor    %edi,%edi
  8012ad:	89 c8                	mov    %ecx,%eax
  8012af:	89 fa                	mov    %edi,%edx
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    
	...

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	83 ec 20             	sub    $0x20,%esp
  8012c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d4:	85 d2                	test   %edx,%edx
  8012d6:	89 c8                	mov    %ecx,%eax
  8012d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8012db:	75 13                	jne    8012f0 <__umoddi3+0x30>
  8012dd:	39 f7                	cmp    %esi,%edi
  8012df:	76 3f                	jbe    801320 <__umoddi3+0x60>
  8012e1:	89 f2                	mov    %esi,%edx
  8012e3:	f7 f7                	div    %edi
  8012e5:	89 d0                	mov    %edx,%eax
  8012e7:	31 d2                	xor    %edx,%edx
  8012e9:	83 c4 20             	add    $0x20,%esp
  8012ec:	5e                   	pop    %esi
  8012ed:	5f                   	pop    %edi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    
  8012f0:	39 f2                	cmp    %esi,%edx
  8012f2:	77 4c                	ja     801340 <__umoddi3+0x80>
  8012f4:	0f bd ca             	bsr    %edx,%ecx
  8012f7:	83 f1 1f             	xor    $0x1f,%ecx
  8012fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8012fd:	75 51                	jne    801350 <__umoddi3+0x90>
  8012ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801302:	0f 87 e0 00 00 00    	ja     8013e8 <__umoddi3+0x128>
  801308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130b:	29 f8                	sub    %edi,%eax
  80130d:	19 d6                	sbb    %edx,%esi
  80130f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801315:	89 f2                	mov    %esi,%edx
  801317:	83 c4 20             	add    $0x20,%esp
  80131a:	5e                   	pop    %esi
  80131b:	5f                   	pop    %edi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    
  80131e:	66 90                	xchg   %ax,%ax
  801320:	85 ff                	test   %edi,%edi
  801322:	75 0b                	jne    80132f <__umoddi3+0x6f>
  801324:	b8 01 00 00 00       	mov    $0x1,%eax
  801329:	31 d2                	xor    %edx,%edx
  80132b:	f7 f7                	div    %edi
  80132d:	89 c7                	mov    %eax,%edi
  80132f:	89 f0                	mov    %esi,%eax
  801331:	31 d2                	xor    %edx,%edx
  801333:	f7 f7                	div    %edi
  801335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801338:	f7 f7                	div    %edi
  80133a:	eb a9                	jmp    8012e5 <__umoddi3+0x25>
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	89 c8                	mov    %ecx,%eax
  801342:	89 f2                	mov    %esi,%edx
  801344:	83 c4 20             	add    $0x20,%esp
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    
  80134b:	90                   	nop
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801354:	d3 e2                	shl    %cl,%edx
  801356:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801359:	ba 20 00 00 00       	mov    $0x20,%edx
  80135e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801361:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801364:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801368:	89 fa                	mov    %edi,%edx
  80136a:	d3 ea                	shr    %cl,%edx
  80136c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801370:	0b 55 f4             	or     -0xc(%ebp),%edx
  801373:	d3 e7                	shl    %cl,%edi
  801375:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801379:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80137c:	89 f2                	mov    %esi,%edx
  80137e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801381:	89 c7                	mov    %eax,%edi
  801383:	d3 ea                	shr    %cl,%edx
  801385:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801389:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	d3 e6                	shl    %cl,%esi
  801390:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801394:	d3 ea                	shr    %cl,%edx
  801396:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80139a:	09 d6                	or     %edx,%esi
  80139c:	89 f0                	mov    %esi,%eax
  80139e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a1:	d3 e7                	shl    %cl,%edi
  8013a3:	89 f2                	mov    %esi,%edx
  8013a5:	f7 75 f4             	divl   -0xc(%ebp)
  8013a8:	89 d6                	mov    %edx,%esi
  8013aa:	f7 65 e8             	mull   -0x18(%ebp)
  8013ad:	39 d6                	cmp    %edx,%esi
  8013af:	72 2b                	jb     8013dc <__umoddi3+0x11c>
  8013b1:	39 c7                	cmp    %eax,%edi
  8013b3:	72 23                	jb     8013d8 <__umoddi3+0x118>
  8013b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013b9:	29 c7                	sub    %eax,%edi
  8013bb:	19 d6                	sbb    %edx,%esi
  8013bd:	89 f0                	mov    %esi,%eax
  8013bf:	89 f2                	mov    %esi,%edx
  8013c1:	d3 ef                	shr    %cl,%edi
  8013c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013c7:	d3 e0                	shl    %cl,%eax
  8013c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013cd:	09 f8                	or     %edi,%eax
  8013cf:	d3 ea                	shr    %cl,%edx
  8013d1:	83 c4 20             	add    $0x20,%esp
  8013d4:	5e                   	pop    %esi
  8013d5:	5f                   	pop    %edi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    
  8013d8:	39 d6                	cmp    %edx,%esi
  8013da:	75 d9                	jne    8013b5 <__umoddi3+0xf5>
  8013dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8013df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8013e2:	eb d1                	jmp    8013b5 <__umoddi3+0xf5>
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	39 f2                	cmp    %esi,%edx
  8013ea:	0f 82 18 ff ff ff    	jb     801308 <__umoddi3+0x48>
  8013f0:	e9 1d ff ff ff       	jmp    801312 <__umoddi3+0x52>
