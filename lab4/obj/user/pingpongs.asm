
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 52 11 00 00       	call   801194 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 92 10 00 00       	call   8010e6 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  800063:	e8 a9 01 00 00       	call   800211 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 76 10 00 00       	call   8010e6 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 7a 15 80 00 	movl   $0x80157a,(%esp)
  80007f:	e8 8d 01 00 00       	call   800211 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 7a 11 00 00       	call   801221 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 81 11 00 00       	call   801243 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 0a 10 00 00       	call   8010e6 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 90 15 80 00 	movl   $0x801590,(%esp)
  8000fa:	e8 12 01 00 00       	call   800211 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 ed 10 00 00       	call   801221 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80015e:	e8 83 0f 00 00       	call   8010e6 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	c1 e0 07             	shl    $0x7,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 20 80 00       	mov    %eax,0x802008
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 78 0f 00 00       	call   801126 <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c0:	00 00 00 
	b.cnt = 0;
  8001c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 2b 02 80 00 	movl   $0x80022b,(%esp)
  8001ec:	e8 cc 01 00 00       	call   8003bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 13 0b 00 00       	call   800d1c <sys_cputs>

	return b.cnt;
}
  800209:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800217:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	e8 87 ff ff ff       	call   8001b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 14             	sub    $0x14,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 03                	mov    (%ebx),%eax
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023e:	83 c0 01             	add    $0x1,%eax
  800241:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 19                	jne    800263 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800251:	00 
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	e8 bf 0a 00 00       	call   800d1c <sys_cputs>
		b->idx = 0;
  80025d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800263:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800290:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800293:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029b:	39 d1                	cmp    %edx,%ecx
  80029d:	72 15                	jb     8002b4 <printnum+0x44>
  80029f:	77 07                	ja     8002a8 <printnum+0x38>
  8002a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a4:	39 d0                	cmp    %edx,%eax
  8002a6:	76 0c                	jbe    8002b4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a8:	83 eb 01             	sub    $0x1,%ebx
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	8d 76 00             	lea    0x0(%esi),%esi
  8002b0:	7f 61                	jg     800313 <printnum+0xa3>
  8002b2:	eb 70                	jmp    800324 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002c7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002cb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ce:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002df:	00 
  8002e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	e8 ee 0f 00 00       	call   8012e0 <__udivdi3>
  8002f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	89 54 24 04          	mov    %edx,0x4(%esp)
  800307:	89 f2                	mov    %esi,%edx
  800309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030c:	e8 5f ff ff ff       	call   800270 <printnum>
  800311:	eb 11                	jmp    800324 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	89 74 24 04          	mov    %esi,0x4(%esp)
  800317:	89 3c 24             	mov    %edi,(%esp)
  80031a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f ef                	jg     800313 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800324:	89 74 24 04          	mov    %esi,0x4(%esp)
  800328:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033a:	00 
  80033b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80033e:	89 14 24             	mov    %edx,(%esp)
  800341:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800344:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800348:	e8 c3 10 00 00       	call   801410 <__umoddi3>
  80034d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800351:	0f be 80 c0 15 80 00 	movsbl 0x8015c0(%eax),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80035e:	83 c4 4c             	add    $0x4c,%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800369:	83 fa 01             	cmp    $0x1,%edx
  80036c:	7e 0e                	jle    80037c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	8d 4a 08             	lea    0x8(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 02                	mov    (%edx),%eax
  800377:	8b 52 04             	mov    0x4(%edx),%edx
  80037a:	eb 22                	jmp    80039e <getuint+0x38>
	else if (lflag)
  80037c:	85 d2                	test   %edx,%edx
  80037e:	74 10                	je     800390 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
  80038e:	eb 0e                	jmp    80039e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 04             	lea    0x4(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8003af:	73 0a                	jae    8003bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	88 0a                	mov    %cl,(%edx)
  8003b6:	83 c2 01             	add    $0x1,%edx
  8003b9:	89 10                	mov    %edx,(%eax)
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	57                   	push   %edi
  8003c1:	56                   	push   %esi
  8003c2:	53                   	push   %ebx
  8003c3:	83 ec 5c             	sub    $0x5c,%esp
  8003c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003cf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003d6:	eb 11                	jmp    8003e9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	0f 84 09 04 00 00    	je     8007e9 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  8003e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 03             	movzbl (%ebx),%eax
  8003ec:	83 c3 01             	add    $0x1,%ebx
  8003ef:	83 f8 25             	cmp    $0x25,%eax
  8003f2:	75 e4                	jne    8003d8 <vprintfmt+0x1b>
  8003f4:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003f8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003ff:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	eb 06                	jmp    80041a <vprintfmt+0x5d>
  800414:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800418:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	0f b6 13             	movzbl (%ebx),%edx
  80041d:	0f b6 c2             	movzbl %dl,%eax
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	8d 43 01             	lea    0x1(%ebx),%eax
  800426:	83 ea 23             	sub    $0x23,%edx
  800429:	80 fa 55             	cmp    $0x55,%dl
  80042c:	0f 87 9a 03 00 00    	ja     8007cc <vprintfmt+0x40f>
  800432:	0f b6 d2             	movzbl %dl,%edx
  800435:	ff 24 95 80 16 80 00 	jmp    *0x801680(,%edx,4)
  80043c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800440:	eb d6                	jmp    800418 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800442:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800445:	83 ea 30             	sub    $0x30,%edx
  800448:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80044b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80044e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800451:	83 fb 09             	cmp    $0x9,%ebx
  800454:	77 4c                	ja     8004a2 <vprintfmt+0xe5>
  800456:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800459:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80045f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800462:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800466:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800469:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80046c:	83 fb 09             	cmp    $0x9,%ebx
  80046f:	76 eb                	jbe    80045c <vprintfmt+0x9f>
  800471:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800474:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800477:	eb 29                	jmp    8004a2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800479:	8b 55 14             	mov    0x14(%ebp),%edx
  80047c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80047f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800482:	8b 12                	mov    (%edx),%edx
  800484:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800487:	eb 19                	jmp    8004a2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800489:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048c:	c1 fa 1f             	sar    $0x1f,%edx
  80048f:	f7 d2                	not    %edx
  800491:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800494:	eb 82                	jmp    800418 <vprintfmt+0x5b>
  800496:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80049d:	e9 76 ff ff ff       	jmp    800418 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a6:	0f 89 6c ff ff ff    	jns    800418 <vprintfmt+0x5b>
  8004ac:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004b8:	e9 5b ff ff ff       	jmp    800418 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004c0:	e9 53 ff ff ff       	jmp    800418 <vprintfmt+0x5b>
  8004c5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	89 04 24             	mov    %eax,(%esp)
  8004da:	ff d7                	call   *%edi
  8004dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8004df:	e9 05 ff ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  8004e4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	89 c2                	mov    %eax,%edx
  8004f4:	c1 fa 1f             	sar    $0x1f,%edx
  8004f7:	31 d0                	xor    %edx,%eax
  8004f9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fb:	83 f8 08             	cmp    $0x8,%eax
  8004fe:	7f 0b                	jg     80050b <vprintfmt+0x14e>
  800500:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  800507:	85 d2                	test   %edx,%edx
  800509:	75 20                	jne    80052b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	c7 44 24 08 d1 15 80 	movl   $0x8015d1,0x8(%esp)
  800516:	00 
  800517:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051b:	89 3c 24             	mov    %edi,(%esp)
  80051e:	e8 4e 03 00 00       	call   800871 <printfmt>
  800523:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800526:	e9 be fe ff ff       	jmp    8003e9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80052b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052f:	c7 44 24 08 da 15 80 	movl   $0x8015da,0x8(%esp)
  800536:	00 
  800537:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053b:	89 3c 24             	mov    %edi,(%esp)
  80053e:	e8 2e 03 00 00       	call   800871 <printfmt>
  800543:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800546:	e9 9e fe ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800556:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800567:	85 c0                	test   %eax,%eax
  800569:	75 07                	jne    800572 <vprintfmt+0x1b5>
  80056b:	c7 45 c4 dd 15 80 00 	movl   $0x8015dd,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800572:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800576:	7e 06                	jle    80057e <vprintfmt+0x1c1>
  800578:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80057c:	75 13                	jne    800591 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800581:	0f be 02             	movsbl (%edx),%eax
  800584:	85 c0                	test   %eax,%eax
  800586:	0f 85 99 00 00 00    	jne    800625 <vprintfmt+0x268>
  80058c:	e9 86 00 00 00       	jmp    800617 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800595:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800598:	89 0c 24             	mov    %ecx,(%esp)
  80059b:	e8 1b 03 00 00       	call   8008bb <strnlen>
  8005a0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	7e d2                	jle    80057e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8005ac:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005b6:	89 d3                	mov    %edx,%ebx
  8005b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	85 db                	test   %ebx,%ebx
  8005c9:	7f ed                	jg     8005b8 <vprintfmt+0x1fb>
  8005cb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005d5:	eb a7                	jmp    80057e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005db:	74 18                	je     8005f5 <vprintfmt+0x238>
  8005dd:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005e0:	83 fa 5e             	cmp    $0x5e,%edx
  8005e3:	76 10                	jbe    8005f5 <vprintfmt+0x238>
					putch('?', putdat);
  8005e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f0:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f3:	eb 0a                	jmp    8005ff <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	89 04 24             	mov    %eax,(%esp)
  8005fc:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ff:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800603:	0f be 03             	movsbl (%ebx),%eax
  800606:	85 c0                	test   %eax,%eax
  800608:	74 05                	je     80060f <vprintfmt+0x252>
  80060a:	83 c3 01             	add    $0x1,%ebx
  80060d:	eb 29                	jmp    800638 <vprintfmt+0x27b>
  80060f:	89 fe                	mov    %edi,%esi
  800611:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800614:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800617:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061b:	7f 2e                	jg     80064b <vprintfmt+0x28e>
  80061d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800620:	e9 c4 fd ff ff       	jmp    8003e9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800625:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800628:	83 c2 01             	add    $0x1,%edx
  80062b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80062e:	89 f7                	mov    %esi,%edi
  800630:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800633:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800636:	89 d3                	mov    %edx,%ebx
  800638:	85 f6                	test   %esi,%esi
  80063a:	78 9b                	js     8005d7 <vprintfmt+0x21a>
  80063c:	83 ee 01             	sub    $0x1,%esi
  80063f:	79 96                	jns    8005d7 <vprintfmt+0x21a>
  800641:	89 fe                	mov    %edi,%esi
  800643:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800646:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800649:	eb cc                	jmp    800617 <vprintfmt+0x25a>
  80064b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80064e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800651:	89 74 24 04          	mov    %esi,0x4(%esp)
  800655:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065e:	83 eb 01             	sub    $0x1,%ebx
  800661:	85 db                	test   %ebx,%ebx
  800663:	7f ec                	jg     800651 <vprintfmt+0x294>
  800665:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800668:	e9 7c fd ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  80066d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800670:	83 f9 01             	cmp    $0x1,%ecx
  800673:	7e 16                	jle    80068b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 08             	lea    0x8(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	8b 48 04             	mov    0x4(%eax),%ecx
  800683:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800686:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800689:	eb 32                	jmp    8006bd <vprintfmt+0x300>
	else if (lflag)
  80068b:	85 c9                	test   %ecx,%ecx
  80068d:	74 18                	je     8006a7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069d:	89 c1                	mov    %eax,%ecx
  80069f:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006a5:	eb 16                	jmp    8006bd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b5:	89 c2                	mov    %eax,%edx
  8006b7:	c1 fa 1f             	sar    $0x1f,%edx
  8006ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006c3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006c8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006cc:	0f 89 b8 00 00 00    	jns    80078a <vprintfmt+0x3cd>
				putch('-', putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006dd:	ff d7                	call   *%edi
				num = -(long long) num;
  8006df:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e5:	f7 d9                	neg    %ecx
  8006e7:	83 d3 00             	adc    $0x0,%ebx
  8006ea:	f7 db                	neg    %ebx
  8006ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f1:	e9 94 00 00 00       	jmp    80078a <vprintfmt+0x3cd>
  8006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f9:	89 ca                	mov    %ecx,%edx
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 63 fc ff ff       	call   800366 <getuint>
  800703:	89 c1                	mov    %eax,%ecx
  800705:	89 d3                	mov    %edx,%ebx
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80070c:	eb 7c                	jmp    80078a <vprintfmt+0x3cd>
  80070e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800711:	89 74 24 04          	mov    %esi,0x4(%esp)
  800715:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80071c:	ff d7                	call   *%edi
			putch('X', putdat);
  80071e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800722:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800729:	ff d7                	call   *%edi
			putch('X', putdat);
  80072b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800736:	ff d7                	call   *%edi
  800738:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80073b:	e9 a9 fc ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  800740:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800743:	89 74 24 04          	mov    %esi,0x4(%esp)
  800747:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80074e:	ff d7                	call   *%edi
			putch('x', putdat);
  800750:	89 74 24 04          	mov    %esi,0x4(%esp)
  800754:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8d 50 04             	lea    0x4(%eax),%edx
  800763:	89 55 14             	mov    %edx,0x14(%ebp)
  800766:	8b 08                	mov    (%eax),%ecx
  800768:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800772:	eb 16                	jmp    80078a <vprintfmt+0x3cd>
  800774:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800777:	89 ca                	mov    %ecx,%edx
  800779:	8d 45 14             	lea    0x14(%ebp),%eax
  80077c:	e8 e5 fb ff ff       	call   800366 <getuint>
  800781:	89 c1                	mov    %eax,%ecx
  800783:	89 d3                	mov    %edx,%ebx
  800785:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80078e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800792:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800795:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	89 0c 24             	mov    %ecx,(%esp)
  8007a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a4:	89 f2                	mov    %esi,%edx
  8007a6:	89 f8                	mov    %edi,%eax
  8007a8:	e8 c3 fa ff ff       	call   800270 <printnum>
  8007ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007b0:	e9 34 fc ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  8007b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007b8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007bf:	89 14 24             	mov    %edx,(%esp)
  8007c2:	ff d7                	call   *%edi
  8007c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007c7:	e9 1d fc ff ff       	jmp    8003e9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007dc:	80 38 25             	cmpb   $0x25,(%eax)
  8007df:	0f 84 04 fc ff ff    	je     8003e9 <vprintfmt+0x2c>
  8007e5:	89 c3                	mov    %eax,%ebx
  8007e7:	eb f0                	jmp    8007d9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  8007e9:	83 c4 5c             	add    $0x5c,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 28             	sub    $0x28,%esp
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 04                	je     800805 <vsnprintf+0x14>
  800801:	85 d2                	test   %edx,%edx
  800803:	7f 07                	jg     80080c <vsnprintf+0x1b>
  800805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080a:	eb 3b                	jmp    800847 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800813:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800824:	8b 45 10             	mov    0x10(%ebp),%eax
  800827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800832:	c7 04 24 a0 03 80 00 	movl   $0x8003a0,(%esp)
  800839:	e8 7f fb ff ff       	call   8003bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800841:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800844:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 82 ff ff ff       	call   8007f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80087a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087e:	8b 45 10             	mov    0x10(%ebp),%eax
  800881:	89 44 24 08          	mov    %eax,0x8(%esp)
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 26 fb ff ff       	call   8003bd <vprintfmt>
	va_end(ap);
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    
  800899:	00 00                	add    %al,(%eax)
  80089b:	00 00                	add    %al,(%eax)
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ae:	74 09                	je     8008b9 <strlen+0x19>
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 19                	je     8008e2 <strnlen+0x27>
  8008c9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008cc:	74 14                	je     8008e2 <strnlen+0x27>
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	39 c8                	cmp    %ecx,%eax
  8008d8:	74 0d                	je     8008e7 <strnlen+0x2c>
  8008da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008de:	75 f3                	jne    8008d3 <strnlen+0x18>
  8008e0:	eb 05                	jmp    8008e7 <strnlen+0x2c>
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	84 c9                	test   %cl,%cl
  800905:	75 f2                	jne    8008f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800914:	89 1c 24             	mov    %ebx,(%esp)
  800917:	e8 84 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800923:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	e8 bc ff ff ff       	call   8008ea <strcpy>
	return dst;
}
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	83 c4 08             	add    $0x8,%esp
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	85 f6                	test   %esi,%esi
  800946:	74 18                	je     800960 <strncpy+0x2a>
  800948:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80094d:	0f b6 1a             	movzbl (%edx),%ebx
  800950:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800953:	80 3a 01             	cmpb   $0x1,(%edx)
  800956:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	83 c1 01             	add    $0x1,%ecx
  80095c:	39 ce                	cmp    %ecx,%esi
  80095e:	77 ed                	ja     80094d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800972:	89 f0                	mov    %esi,%eax
  800974:	85 c9                	test   %ecx,%ecx
  800976:	74 27                	je     80099f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800978:	83 e9 01             	sub    $0x1,%ecx
  80097b:	74 1d                	je     80099a <strlcpy+0x36>
  80097d:	0f b6 1a             	movzbl (%edx),%ebx
  800980:	84 db                	test   %bl,%bl
  800982:	74 16                	je     80099a <strlcpy+0x36>
			*dst++ = *src++;
  800984:	88 18                	mov    %bl,(%eax)
  800986:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800989:	83 e9 01             	sub    $0x1,%ecx
  80098c:	74 0e                	je     80099c <strlcpy+0x38>
			*dst++ = *src++;
  80098e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800991:	0f b6 1a             	movzbl (%edx),%ebx
  800994:	84 db                	test   %bl,%bl
  800996:	75 ec                	jne    800984 <strlcpy+0x20>
  800998:	eb 02                	jmp    80099c <strlcpy+0x38>
  80099a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80099c:	c6 00 00             	movb   $0x0,(%eax)
  80099f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ae:	0f b6 01             	movzbl (%ecx),%eax
  8009b1:	84 c0                	test   %al,%al
  8009b3:	74 15                	je     8009ca <strcmp+0x25>
  8009b5:	3a 02                	cmp    (%edx),%al
  8009b7:	75 11                	jne    8009ca <strcmp+0x25>
		p++, q++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	84 c0                	test   %al,%al
  8009c4:	74 04                	je     8009ca <strcmp+0x25>
  8009c6:	3a 02                	cmp    (%edx),%al
  8009c8:	74 ef                	je     8009b9 <strcmp+0x14>
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009e1:	85 c0                	test   %eax,%eax
  8009e3:	74 23                	je     800a08 <strncmp+0x34>
  8009e5:	0f b6 1a             	movzbl (%edx),%ebx
  8009e8:	84 db                	test   %bl,%bl
  8009ea:	74 25                	je     800a11 <strncmp+0x3d>
  8009ec:	3a 19                	cmp    (%ecx),%bl
  8009ee:	75 21                	jne    800a11 <strncmp+0x3d>
  8009f0:	83 e8 01             	sub    $0x1,%eax
  8009f3:	74 13                	je     800a08 <strncmp+0x34>
		n--, p++, q++;
  8009f5:	83 c2 01             	add    $0x1,%edx
  8009f8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fb:	0f b6 1a             	movzbl (%edx),%ebx
  8009fe:	84 db                	test   %bl,%bl
  800a00:	74 0f                	je     800a11 <strncmp+0x3d>
  800a02:	3a 19                	cmp    (%ecx),%bl
  800a04:	74 ea                	je     8009f0 <strncmp+0x1c>
  800a06:	eb 09                	jmp    800a11 <strncmp+0x3d>
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5d                   	pop    %ebp
  800a0f:	90                   	nop
  800a10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a11:	0f b6 02             	movzbl (%edx),%eax
  800a14:	0f b6 11             	movzbl (%ecx),%edx
  800a17:	29 d0                	sub    %edx,%eax
  800a19:	eb f2                	jmp    800a0d <strncmp+0x39>

00800a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	74 18                	je     800a44 <strchr+0x29>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	75 0a                	jne    800a3a <strchr+0x1f>
  800a30:	eb 17                	jmp    800a49 <strchr+0x2e>
  800a32:	38 ca                	cmp    %cl,%dl
  800a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a38:	74 0f                	je     800a49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 ee                	jne    800a32 <strchr+0x17>
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	0f b6 10             	movzbl (%eax),%edx
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	74 18                	je     800a74 <strfind+0x29>
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	75 0a                	jne    800a6a <strfind+0x1f>
  800a60:	eb 12                	jmp    800a74 <strfind+0x29>
  800a62:	38 ca                	cmp    %cl,%dl
  800a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a68:	74 0a                	je     800a74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 ee                	jne    800a62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
  800a7c:	89 1c 24             	mov    %ebx,(%esp)
  800a7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a90:	85 c9                	test   %ecx,%ecx
  800a92:	74 30                	je     800ac4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 25                	jne    800ac1 <memset+0x4b>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 20                	jne    800ac1 <memset+0x4b>
		c &= 0xFF;
  800aa1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	c1 e3 08             	shl    $0x8,%ebx
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	c1 e6 18             	shl    $0x18,%esi
  800aae:	89 d0                	mov    %edx,%eax
  800ab0:	c1 e0 10             	shl    $0x10,%eax
  800ab3:	09 f0                	or     %esi,%eax
  800ab5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ab7:	09 d8                	or     %ebx,%eax
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
  800abc:	fc                   	cld    
  800abd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abf:	eb 03                	jmp    800ac4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac1:	fc                   	cld    
  800ac2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac4:	89 f8                	mov    %edi,%eax
  800ac6:	8b 1c 24             	mov    (%esp),%ebx
  800ac9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800acd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ad1:	89 ec                	mov    %ebp,%esp
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	83 ec 08             	sub    $0x8,%esp
  800adb:	89 34 24             	mov    %esi,(%esp)
  800ade:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800aeb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800aed:	39 c6                	cmp    %eax,%esi
  800aef:	73 35                	jae    800b26 <memmove+0x51>
  800af1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af4:	39 d0                	cmp    %edx,%eax
  800af6:	73 2e                	jae    800b26 <memmove+0x51>
		s += n;
		d += n;
  800af8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	f6 c2 03             	test   $0x3,%dl
  800afd:	75 1b                	jne    800b1a <memmove+0x45>
  800aff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b05:	75 13                	jne    800b1a <memmove+0x45>
  800b07:	f6 c1 03             	test   $0x3,%cl
  800b0a:	75 0e                	jne    800b1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b0c:	83 ef 04             	sub    $0x4,%edi
  800b0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b12:	c1 e9 02             	shr    $0x2,%ecx
  800b15:	fd                   	std    
  800b16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b18:	eb 09                	jmp    800b23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1a:	83 ef 01             	sub    $0x1,%edi
  800b1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b20:	fd                   	std    
  800b21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b24:	eb 20                	jmp    800b46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2c:	75 15                	jne    800b43 <memmove+0x6e>
  800b2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b34:	75 0d                	jne    800b43 <memmove+0x6e>
  800b36:	f6 c1 03             	test   $0x3,%cl
  800b39:	75 08                	jne    800b43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b3b:	c1 e9 02             	shr    $0x2,%ecx
  800b3e:	fc                   	cld    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	eb 03                	jmp    800b46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b43:	fc                   	cld    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b46:	8b 34 24             	mov    (%esp),%esi
  800b49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b4d:	89 ec                	mov    %ebp,%esp
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 04 24             	mov    %eax,(%esp)
  800b6b:	e8 65 ff ff ff       	call   800ad5 <memmove>
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b81:	85 c9                	test   %ecx,%ecx
  800b83:	74 36                	je     800bbb <memcmp+0x49>
		if (*s1 != *s2)
  800b85:	0f b6 06             	movzbl (%esi),%eax
  800b88:	0f b6 1f             	movzbl (%edi),%ebx
  800b8b:	38 d8                	cmp    %bl,%al
  800b8d:	74 20                	je     800baf <memcmp+0x3d>
  800b8f:	eb 14                	jmp    800ba5 <memcmp+0x33>
  800b91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b9b:	83 c2 01             	add    $0x1,%edx
  800b9e:	83 e9 01             	sub    $0x1,%ecx
  800ba1:	38 d8                	cmp    %bl,%al
  800ba3:	74 12                	je     800bb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ba5:	0f b6 c0             	movzbl %al,%eax
  800ba8:	0f b6 db             	movzbl %bl,%ebx
  800bab:	29 d8                	sub    %ebx,%eax
  800bad:	eb 11                	jmp    800bc0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800baf:	83 e9 01             	sub    $0x1,%ecx
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	85 c9                	test   %ecx,%ecx
  800bb9:	75 d6                	jne    800b91 <memcmp+0x1f>
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd0:	39 d0                	cmp    %edx,%eax
  800bd2:	73 15                	jae    800be9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bd8:	38 08                	cmp    %cl,(%eax)
  800bda:	75 06                	jne    800be2 <memfind+0x1d>
  800bdc:	eb 0b                	jmp    800be9 <memfind+0x24>
  800bde:	38 08                	cmp    %cl,(%eax)
  800be0:	74 07                	je     800be9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	39 c2                	cmp    %eax,%edx
  800be7:	77 f5                	ja     800bde <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 04             	sub    $0x4,%esp
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	0f b6 02             	movzbl (%edx),%eax
  800bfd:	3c 20                	cmp    $0x20,%al
  800bff:	74 04                	je     800c05 <strtol+0x1a>
  800c01:	3c 09                	cmp    $0x9,%al
  800c03:	75 0e                	jne    800c13 <strtol+0x28>
		s++;
  800c05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c08:	0f b6 02             	movzbl (%edx),%eax
  800c0b:	3c 20                	cmp    $0x20,%al
  800c0d:	74 f6                	je     800c05 <strtol+0x1a>
  800c0f:	3c 09                	cmp    $0x9,%al
  800c11:	74 f2                	je     800c05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c13:	3c 2b                	cmp    $0x2b,%al
  800c15:	75 0c                	jne    800c23 <strtol+0x38>
		s++;
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c21:	eb 15                	jmp    800c38 <strtol+0x4d>
	else if (*s == '-')
  800c23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c2a:	3c 2d                	cmp    $0x2d,%al
  800c2c:	75 0a                	jne    800c38 <strtol+0x4d>
		s++, neg = 1;
  800c2e:	83 c2 01             	add    $0x1,%edx
  800c31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c38:	85 db                	test   %ebx,%ebx
  800c3a:	0f 94 c0             	sete   %al
  800c3d:	74 05                	je     800c44 <strtol+0x59>
  800c3f:	83 fb 10             	cmp    $0x10,%ebx
  800c42:	75 18                	jne    800c5c <strtol+0x71>
  800c44:	80 3a 30             	cmpb   $0x30,(%edx)
  800c47:	75 13                	jne    800c5c <strtol+0x71>
  800c49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c4d:	8d 76 00             	lea    0x0(%esi),%esi
  800c50:	75 0a                	jne    800c5c <strtol+0x71>
		s += 2, base = 16;
  800c52:	83 c2 02             	add    $0x2,%edx
  800c55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5a:	eb 15                	jmp    800c71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5c:	84 c0                	test   %al,%al
  800c5e:	66 90                	xchg   %ax,%ax
  800c60:	74 0f                	je     800c71 <strtol+0x86>
  800c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c67:	80 3a 30             	cmpb   $0x30,(%edx)
  800c6a:	75 05                	jne    800c71 <strtol+0x86>
		s++, base = 8;
  800c6c:	83 c2 01             	add    $0x1,%edx
  800c6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c78:	0f b6 0a             	movzbl (%edx),%ecx
  800c7b:	89 cf                	mov    %ecx,%edi
  800c7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c80:	80 fb 09             	cmp    $0x9,%bl
  800c83:	77 08                	ja     800c8d <strtol+0xa2>
			dig = *s - '0';
  800c85:	0f be c9             	movsbl %cl,%ecx
  800c88:	83 e9 30             	sub    $0x30,%ecx
  800c8b:	eb 1e                	jmp    800cab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c90:	80 fb 19             	cmp    $0x19,%bl
  800c93:	77 08                	ja     800c9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c95:	0f be c9             	movsbl %cl,%ecx
  800c98:	83 e9 57             	sub    $0x57,%ecx
  800c9b:	eb 0e                	jmp    800cab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ca0:	80 fb 19             	cmp    $0x19,%bl
  800ca3:	77 15                	ja     800cba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ca5:	0f be c9             	movsbl %cl,%ecx
  800ca8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cab:	39 f1                	cmp    %esi,%ecx
  800cad:	7d 0b                	jge    800cba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800caf:	83 c2 01             	add    $0x1,%edx
  800cb2:	0f af c6             	imul   %esi,%eax
  800cb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cb8:	eb be                	jmp    800c78 <strtol+0x8d>
  800cba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc0:	74 05                	je     800cc7 <strtol+0xdc>
		*endptr = (char *) s;
  800cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ccb:	74 04                	je     800cd1 <strtol+0xe6>
  800ccd:	89 c8                	mov    %ecx,%eax
  800ccf:	f7 d8                	neg    %eax
}
  800cd1:	83 c4 04             	add    $0x4,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
  800cd9:	00 00                	add    %al,(%eax)
	...

00800cdc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
  800ce2:	89 1c 24             	mov    %ebx,(%esp)
  800ce5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ce9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cee:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	89 d3                	mov    %edx,%ebx
  800cf7:	89 d7                	mov    %edx,%edi
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
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d11:	8b 1c 24             	mov    (%esp),%ebx
  800d14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 08             	sub    $0x8,%esp
  800d22:	89 1c 24             	mov    %ebx,(%esp)
  800d25:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	89 c7                	mov    %eax,%edi
  800d38:	51                   	push   %ecx
  800d39:	52                   	push   %edx
  800d3a:	53                   	push   %ebx
  800d3b:	54                   	push   %esp
  800d3c:	55                   	push   %ebp
  800d3d:	56                   	push   %esi
  800d3e:	57                   	push   %edi
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	8d 35 49 0d 80 00    	lea    0x800d49,%esi
  800d47:	0f 34                	sysenter 
  800d49:	5f                   	pop    %edi
  800d4a:	5e                   	pop    %esi
  800d4b:	5d                   	pop    %ebp
  800d4c:	5c                   	pop    %esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5a                   	pop    %edx
  800d4f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d50:	8b 1c 24             	mov    (%esp),%ebx
  800d53:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d57:	89 ec                	mov    %ebp,%esp
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 08             	sub    $0x8,%esp
  800d61:	89 1c 24             	mov    %ebx,(%esp)
  800d64:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
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
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800d91:	8b 1c 24             	mov    (%esp),%ebx
  800d94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 28             	sub    $0x28,%esp
  800da2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800da5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dad:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 cb                	mov    %ecx,%ebx
  800db7:	89 cf                	mov    %ecx,%edi
  800db9:	51                   	push   %ecx
  800dba:	52                   	push   %edx
  800dbb:	53                   	push   %ebx
  800dbc:	54                   	push   %esp
  800dbd:	55                   	push   %ebp
  800dbe:	56                   	push   %esi
  800dbf:	57                   	push   %edi
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	8d 35 ca 0d 80 00    	lea    0x800dca,%esi
  800dc8:	0f 34                	sysenter 
  800dca:	5f                   	pop    %edi
  800dcb:	5e                   	pop    %esi
  800dcc:	5d                   	pop    %ebp
  800dcd:	5c                   	pop    %esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5a                   	pop    %edx
  800dd0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 28                	jle    800dfd <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de0:	00 
  800de1:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800de8:	00 
  800de9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800df0:	00 
  800df1:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800df8:	e8 6b 04 00 00       	call   801268 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e03:	89 ec                	mov    %ebp,%esp
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	83 ec 08             	sub    $0x8,%esp
  800e0d:	89 1c 24             	mov    %ebx,(%esp)
  800e10:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	51                   	push   %ecx
  800e26:	52                   	push   %edx
  800e27:	53                   	push   %ebx
  800e28:	54                   	push   %esp
  800e29:	55                   	push   %ebp
  800e2a:	56                   	push   %esi
  800e2b:	57                   	push   %edi
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8d 35 36 0e 80 00    	lea    0x800e36,%esi
  800e34:	0f 34                	sysenter 
  800e36:	5f                   	pop    %edi
  800e37:	5e                   	pop    %esi
  800e38:	5d                   	pop    %ebp
  800e39:	5c                   	pop    %esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5a                   	pop    %edx
  800e3c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3d:	8b 1c 24             	mov    (%esp),%ebx
  800e40:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e44:	89 ec                	mov    %ebp,%esp
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 28             	sub    $0x28,%esp
  800e4e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e51:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 df                	mov    %ebx,%edi
  800e66:	51                   	push   %ecx
  800e67:	52                   	push   %edx
  800e68:	53                   	push   %ebx
  800e69:	54                   	push   %esp
  800e6a:	55                   	push   %ebp
  800e6b:	56                   	push   %esi
  800e6c:	57                   	push   %edi
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	8d 35 77 0e 80 00    	lea    0x800e77,%esi
  800e75:	0f 34                	sysenter 
  800e77:	5f                   	pop    %edi
  800e78:	5e                   	pop    %esi
  800e79:	5d                   	pop    %ebp
  800e7a:	5c                   	pop    %esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5a                   	pop    %edx
  800e7d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	7e 28                	jle    800eaa <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e86:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800e95:	00 
  800e96:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e9d:	00 
  800e9e:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800ea5:	e8 be 03 00 00       	call   801268 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eaa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ead:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb0:	89 ec                	mov    %ebp,%esp
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 28             	sub    $0x28,%esp
  800eba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ebd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	89 df                	mov    %ebx,%edi
  800ed2:	51                   	push   %ecx
  800ed3:	52                   	push   %edx
  800ed4:	53                   	push   %ebx
  800ed5:	54                   	push   %esp
  800ed6:	55                   	push   %ebp
  800ed7:	56                   	push   %esi
  800ed8:	57                   	push   %edi
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	8d 35 e3 0e 80 00    	lea    0x800ee3,%esi
  800ee1:	0f 34                	sysenter 
  800ee3:	5f                   	pop    %edi
  800ee4:	5e                   	pop    %esi
  800ee5:	5d                   	pop    %ebp
  800ee6:	5c                   	pop    %esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5a                   	pop    %edx
  800ee9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 28                	jle    800f16 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ef9:	00 
  800efa:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800f01:	00 
  800f02:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f09:	00 
  800f0a:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800f11:	e8 52 03 00 00       	call   801268 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f16:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1c:	89 ec                	mov    %ebp,%esp
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 28             	sub    $0x28,%esp
  800f26:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f29:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f31:	b8 07 00 00 00       	mov    $0x7,%eax
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 df                	mov    %ebx,%edi
  800f3e:	51                   	push   %ecx
  800f3f:	52                   	push   %edx
  800f40:	53                   	push   %ebx
  800f41:	54                   	push   %esp
  800f42:	55                   	push   %ebp
  800f43:	56                   	push   %esi
  800f44:	57                   	push   %edi
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	8d 35 4f 0f 80 00    	lea    0x800f4f,%esi
  800f4d:	0f 34                	sysenter 
  800f4f:	5f                   	pop    %edi
  800f50:	5e                   	pop    %esi
  800f51:	5d                   	pop    %ebp
  800f52:	5c                   	pop    %esp
  800f53:	5b                   	pop    %ebx
  800f54:	5a                   	pop    %edx
  800f55:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7e 28                	jle    800f82 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f65:	00 
  800f66:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800f7d:	e8 e6 02 00 00       	call   801268 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f82:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f88:	89 ec                	mov    %ebp,%esp
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 28             	sub    $0x28,%esp
  800f92:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f95:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f98:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa9:	51                   	push   %ecx
  800faa:	52                   	push   %edx
  800fab:	53                   	push   %ebx
  800fac:	54                   	push   %esp
  800fad:	55                   	push   %ebp
  800fae:	56                   	push   %esi
  800faf:	57                   	push   %edi
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	8d 35 ba 0f 80 00    	lea    0x800fba,%esi
  800fb8:	0f 34                	sysenter 
  800fba:	5f                   	pop    %edi
  800fbb:	5e                   	pop    %esi
  800fbc:	5d                   	pop    %ebp
  800fbd:	5c                   	pop    %esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5a                   	pop    %edx
  800fc0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	7e 28                	jle    800fed <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fe0:	00 
  800fe1:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800fe8:	e8 7b 02 00 00       	call   801268 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fed:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ff0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff3:	89 ec                	mov    %ebp,%esp
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 28             	sub    $0x28,%esp
  800ffd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801000:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801003:	bf 00 00 00 00       	mov    $0x0,%edi
  801008:	b8 05 00 00 00       	mov    $0x5,%eax
  80100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	51                   	push   %ecx
  801017:	52                   	push   %edx
  801018:	53                   	push   %ebx
  801019:	54                   	push   %esp
  80101a:	55                   	push   %ebp
  80101b:	56                   	push   %esi
  80101c:	57                   	push   %edi
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	8d 35 27 10 80 00    	lea    0x801027,%esi
  801025:	0f 34                	sysenter 
  801027:	5f                   	pop    %edi
  801028:	5e                   	pop    %esi
  801029:	5d                   	pop    %ebp
  80102a:	5c                   	pop    %esp
  80102b:	5b                   	pop    %ebx
  80102c:	5a                   	pop    %edx
  80102d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 28                	jle    80105a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801032:	89 44 24 10          	mov    %eax,0x10(%esp)
  801036:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80103d:	00 
  80103e:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  801055:	e8 0e 02 00 00       	call   801268 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80105a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80105d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801060:	89 ec                	mov    %ebp,%esp
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	89 1c 24             	mov    %ebx,(%esp)
  80106d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801071:	ba 00 00 00 00       	mov    $0x0,%edx
  801076:	b8 0b 00 00 00       	mov    $0xb,%eax
  80107b:	89 d1                	mov    %edx,%ecx
  80107d:	89 d3                	mov    %edx,%ebx
  80107f:	89 d7                	mov    %edx,%edi
  801081:	51                   	push   %ecx
  801082:	52                   	push   %edx
  801083:	53                   	push   %ebx
  801084:	54                   	push   %esp
  801085:	55                   	push   %ebp
  801086:	56                   	push   %esi
  801087:	57                   	push   %edi
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	8d 35 92 10 80 00    	lea    0x801092,%esi
  801090:	0f 34                	sysenter 
  801092:	5f                   	pop    %edi
  801093:	5e                   	pop    %esi
  801094:	5d                   	pop    %ebp
  801095:	5c                   	pop    %esp
  801096:	5b                   	pop    %ebx
  801097:	5a                   	pop    %edx
  801098:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801099:	8b 1c 24             	mov    (%esp),%ebx
  80109c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010a0:	89 ec                	mov    %ebp,%esp
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	89 1c 24             	mov    %ebx,(%esp)
  8010ad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8010db:	8b 1c 24             	mov    (%esp),%ebx
  8010de:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e2:	89 ec                	mov    %ebp,%esp
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	89 1c 24             	mov    %ebx,(%esp)
  8010ef:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8010fd:	89 d1                	mov    %edx,%ecx
  8010ff:	89 d3                	mov    %edx,%ebx
  801101:	89 d7                	mov    %edx,%edi
  801103:	51                   	push   %ecx
  801104:	52                   	push   %edx
  801105:	53                   	push   %ebx
  801106:	54                   	push   %esp
  801107:	55                   	push   %ebp
  801108:	56                   	push   %esi
  801109:	57                   	push   %edi
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	8d 35 14 11 80 00    	lea    0x801114,%esi
  801112:	0f 34                	sysenter 
  801114:	5f                   	pop    %edi
  801115:	5e                   	pop    %esi
  801116:	5d                   	pop    %ebp
  801117:	5c                   	pop    %esp
  801118:	5b                   	pop    %ebx
  801119:	5a                   	pop    %edx
  80111a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80111b:	8b 1c 24             	mov    (%esp),%ebx
  80111e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801122:	89 ec                	mov    %ebp,%esp
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	83 ec 28             	sub    $0x28,%esp
  80112c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80112f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801132:	b9 00 00 00 00       	mov    $0x0,%ecx
  801137:	b8 03 00 00 00       	mov    $0x3,%eax
  80113c:	8b 55 08             	mov    0x8(%ebp),%edx
  80113f:	89 cb                	mov    %ecx,%ebx
  801141:	89 cf                	mov    %ecx,%edi
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80115b:	85 c0                	test   %eax,%eax
  80115d:	7e 28                	jle    801187 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801163:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80116a:	00 
  80116b:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  801172:	00 
  801173:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  801182:	e8 e1 00 00 00       	call   801268 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801187:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80118a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80118d:	89 ec                	mov    %ebp,%esp
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    
  801191:	00 00                	add    %al,(%eax)
	...

00801194 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80119a:	c7 44 24 08 2f 18 80 	movl   $0x80182f,0x8(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8011a9:	00 
  8011aa:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  8011b1:	e8 b2 00 00 00       	call   801268 <_panic>

008011b6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  8011bc:	c7 44 24 08 30 18 80 	movl   $0x801830,0x8(%esp)
  8011c3:	00 
  8011c4:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011cb:	00 
  8011cc:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  8011d3:	e8 90 00 00 00       	call   801268 <_panic>

008011d8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011de:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8011e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e9:	39 ca                	cmp    %ecx,%edx
  8011eb:	75 04                	jne    8011f1 <ipc_find_env+0x19>
  8011ed:	b0 00                	mov    $0x0,%al
  8011ef:	eb 11                	jmp    801202 <ipc_find_env+0x2a>
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 e2 07             	shl    $0x7,%edx
  8011f6:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8011fc:	8b 12                	mov    (%edx),%edx
  8011fe:	39 ca                	cmp    %ecx,%edx
  801200:	75 0f                	jne    801211 <ipc_find_env+0x39>
			return envs[i].env_id;
  801202:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801206:	c1 e0 06             	shl    $0x6,%eax
  801209:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  80120f:	eb 0e                	jmp    80121f <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801211:	83 c0 01             	add    $0x1,%eax
  801214:	3d 00 04 00 00       	cmp    $0x400,%eax
  801219:	75 d6                	jne    8011f1 <ipc_find_env+0x19>
  80121b:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801227:	c7 44 24 08 50 18 80 	movl   $0x801850,0x8(%esp)
  80122e:	00 
  80122f:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801236:	00 
  801237:	c7 04 24 69 18 80 00 	movl   $0x801869,(%esp)
  80123e:	e8 25 00 00 00       	call   801268 <_panic>

00801243 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801249:	c7 44 24 08 73 18 80 	movl   $0x801873,0x8(%esp)
  801250:	00 
  801251:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801258:	00 
  801259:	c7 04 24 69 18 80 00 	movl   $0x801869,(%esp)
  801260:	e8 03 00 00 00       	call   801268 <_panic>
  801265:	00 00                	add    %al,(%eax)
	...

00801268 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801270:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801273:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801278:	85 c0                	test   %eax,%eax
  80127a:	74 10                	je     80128c <_panic+0x24>
		cprintf("%s: ", argv0);
  80127c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801280:	c7 04 24 8c 18 80 00 	movl   $0x80188c,(%esp)
  801287:	e8 85 ef ff ff       	call   800211 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80128c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801292:	e8 4f fe ff ff       	call   8010e6 <sys_getenvid>
  801297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80129e:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ad:	c7 04 24 94 18 80 00 	movl   $0x801894,(%esp)
  8012b4:	e8 58 ef ff ff       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	e8 e8 ee ff ff       	call   8001b0 <vcprintf>
	cprintf("\n");
  8012c8:	c7 04 24 78 15 80 00 	movl   $0x801578,(%esp)
  8012cf:	e8 3d ef ff ff       	call   800211 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012d4:	cc                   	int3   
  8012d5:	eb fd                	jmp    8012d4 <_panic+0x6c>
	...

008012e0 <__udivdi3>:
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	57                   	push   %edi
  8012e4:	56                   	push   %esi
  8012e5:	83 ec 10             	sub    $0x10,%esp
  8012e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8012f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8012f9:	75 35                	jne    801330 <__udivdi3+0x50>
  8012fb:	39 fe                	cmp    %edi,%esi
  8012fd:	77 61                	ja     801360 <__udivdi3+0x80>
  8012ff:	85 f6                	test   %esi,%esi
  801301:	75 0b                	jne    80130e <__udivdi3+0x2e>
  801303:	b8 01 00 00 00       	mov    $0x1,%eax
  801308:	31 d2                	xor    %edx,%edx
  80130a:	f7 f6                	div    %esi
  80130c:	89 c6                	mov    %eax,%esi
  80130e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801311:	31 d2                	xor    %edx,%edx
  801313:	89 f8                	mov    %edi,%eax
  801315:	f7 f6                	div    %esi
  801317:	89 c7                	mov    %eax,%edi
  801319:	89 c8                	mov    %ecx,%eax
  80131b:	f7 f6                	div    %esi
  80131d:	89 c1                	mov    %eax,%ecx
  80131f:	89 fa                	mov    %edi,%edx
  801321:	89 c8                	mov    %ecx,%eax
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    
  80132a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801330:	39 f8                	cmp    %edi,%eax
  801332:	77 1c                	ja     801350 <__udivdi3+0x70>
  801334:	0f bd d0             	bsr    %eax,%edx
  801337:	83 f2 1f             	xor    $0x1f,%edx
  80133a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80133d:	75 39                	jne    801378 <__udivdi3+0x98>
  80133f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801342:	0f 86 a0 00 00 00    	jbe    8013e8 <__udivdi3+0x108>
  801348:	39 f8                	cmp    %edi,%eax
  80134a:	0f 82 98 00 00 00    	jb     8013e8 <__udivdi3+0x108>
  801350:	31 ff                	xor    %edi,%edi
  801352:	31 c9                	xor    %ecx,%ecx
  801354:	89 c8                	mov    %ecx,%eax
  801356:	89 fa                	mov    %edi,%edx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	5e                   	pop    %esi
  80135c:	5f                   	pop    %edi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    
  80135f:	90                   	nop
  801360:	89 d1                	mov    %edx,%ecx
  801362:	89 fa                	mov    %edi,%edx
  801364:	89 c8                	mov    %ecx,%eax
  801366:	31 ff                	xor    %edi,%edi
  801368:	f7 f6                	div    %esi
  80136a:	89 c1                	mov    %eax,%ecx
  80136c:	89 fa                	mov    %edi,%edx
  80136e:	89 c8                	mov    %ecx,%eax
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    
  801377:	90                   	nop
  801378:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80137c:	89 f2                	mov    %esi,%edx
  80137e:	d3 e0                	shl    %cl,%eax
  801380:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801383:	b8 20 00 00 00       	mov    $0x20,%eax
  801388:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80138b:	89 c1                	mov    %eax,%ecx
  80138d:	d3 ea                	shr    %cl,%edx
  80138f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801393:	0b 55 ec             	or     -0x14(%ebp),%edx
  801396:	d3 e6                	shl    %cl,%esi
  801398:	89 c1                	mov    %eax,%ecx
  80139a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80139d:	89 fe                	mov    %edi,%esi
  80139f:	d3 ee                	shr    %cl,%esi
  8013a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ab:	d3 e7                	shl    %cl,%edi
  8013ad:	89 c1                	mov    %eax,%ecx
  8013af:	d3 ea                	shr    %cl,%edx
  8013b1:	09 d7                	or     %edx,%edi
  8013b3:	89 f2                	mov    %esi,%edx
  8013b5:	89 f8                	mov    %edi,%eax
  8013b7:	f7 75 ec             	divl   -0x14(%ebp)
  8013ba:	89 d6                	mov    %edx,%esi
  8013bc:	89 c7                	mov    %eax,%edi
  8013be:	f7 65 e8             	mull   -0x18(%ebp)
  8013c1:	39 d6                	cmp    %edx,%esi
  8013c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013c6:	72 30                	jb     8013f8 <__udivdi3+0x118>
  8013c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013cf:	d3 e2                	shl    %cl,%edx
  8013d1:	39 c2                	cmp    %eax,%edx
  8013d3:	73 05                	jae    8013da <__udivdi3+0xfa>
  8013d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8013d8:	74 1e                	je     8013f8 <__udivdi3+0x118>
  8013da:	89 f9                	mov    %edi,%ecx
  8013dc:	31 ff                	xor    %edi,%edi
  8013de:	e9 71 ff ff ff       	jmp    801354 <__udivdi3+0x74>
  8013e3:	90                   	nop
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	31 ff                	xor    %edi,%edi
  8013ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8013ef:	e9 60 ff ff ff       	jmp    801354 <__udivdi3+0x74>
  8013f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8013fb:	31 ff                	xor    %edi,%edi
  8013fd:	89 c8                	mov    %ecx,%eax
  8013ff:	89 fa                	mov    %edi,%edx
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	5e                   	pop    %esi
  801405:	5f                   	pop    %edi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    
	...

00801410 <__umoddi3>:
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	57                   	push   %edi
  801414:	56                   	push   %esi
  801415:	83 ec 20             	sub    $0x20,%esp
  801418:	8b 55 14             	mov    0x14(%ebp),%edx
  80141b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801421:	8b 75 0c             	mov    0xc(%ebp),%esi
  801424:	85 d2                	test   %edx,%edx
  801426:	89 c8                	mov    %ecx,%eax
  801428:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80142b:	75 13                	jne    801440 <__umoddi3+0x30>
  80142d:	39 f7                	cmp    %esi,%edi
  80142f:	76 3f                	jbe    801470 <__umoddi3+0x60>
  801431:	89 f2                	mov    %esi,%edx
  801433:	f7 f7                	div    %edi
  801435:	89 d0                	mov    %edx,%eax
  801437:	31 d2                	xor    %edx,%edx
  801439:	83 c4 20             	add    $0x20,%esp
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    
  801440:	39 f2                	cmp    %esi,%edx
  801442:	77 4c                	ja     801490 <__umoddi3+0x80>
  801444:	0f bd ca             	bsr    %edx,%ecx
  801447:	83 f1 1f             	xor    $0x1f,%ecx
  80144a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80144d:	75 51                	jne    8014a0 <__umoddi3+0x90>
  80144f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801452:	0f 87 e0 00 00 00    	ja     801538 <__umoddi3+0x128>
  801458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145b:	29 f8                	sub    %edi,%eax
  80145d:	19 d6                	sbb    %edx,%esi
  80145f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801465:	89 f2                	mov    %esi,%edx
  801467:	83 c4 20             	add    $0x20,%esp
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    
  80146e:	66 90                	xchg   %ax,%ax
  801470:	85 ff                	test   %edi,%edi
  801472:	75 0b                	jne    80147f <__umoddi3+0x6f>
  801474:	b8 01 00 00 00       	mov    $0x1,%eax
  801479:	31 d2                	xor    %edx,%edx
  80147b:	f7 f7                	div    %edi
  80147d:	89 c7                	mov    %eax,%edi
  80147f:	89 f0                	mov    %esi,%eax
  801481:	31 d2                	xor    %edx,%edx
  801483:	f7 f7                	div    %edi
  801485:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801488:	f7 f7                	div    %edi
  80148a:	eb a9                	jmp    801435 <__umoddi3+0x25>
  80148c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801490:	89 c8                	mov    %ecx,%eax
  801492:	89 f2                	mov    %esi,%edx
  801494:	83 c4 20             	add    $0x20,%esp
  801497:	5e                   	pop    %esi
  801498:	5f                   	pop    %edi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
  80149b:	90                   	nop
  80149c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014a4:	d3 e2                	shl    %cl,%edx
  8014a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8014ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8014b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014b8:	89 fa                	mov    %edi,%edx
  8014ba:	d3 ea                	shr    %cl,%edx
  8014bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8014c3:	d3 e7                	shl    %cl,%edi
  8014c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014cc:	89 f2                	mov    %esi,%edx
  8014ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8014d1:	89 c7                	mov    %eax,%edi
  8014d3:	d3 ea                	shr    %cl,%edx
  8014d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	d3 e6                	shl    %cl,%esi
  8014e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014e4:	d3 ea                	shr    %cl,%edx
  8014e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014ea:	09 d6                	or     %edx,%esi
  8014ec:	89 f0                	mov    %esi,%eax
  8014ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8014f1:	d3 e7                	shl    %cl,%edi
  8014f3:	89 f2                	mov    %esi,%edx
  8014f5:	f7 75 f4             	divl   -0xc(%ebp)
  8014f8:	89 d6                	mov    %edx,%esi
  8014fa:	f7 65 e8             	mull   -0x18(%ebp)
  8014fd:	39 d6                	cmp    %edx,%esi
  8014ff:	72 2b                	jb     80152c <__umoddi3+0x11c>
  801501:	39 c7                	cmp    %eax,%edi
  801503:	72 23                	jb     801528 <__umoddi3+0x118>
  801505:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801509:	29 c7                	sub    %eax,%edi
  80150b:	19 d6                	sbb    %edx,%esi
  80150d:	89 f0                	mov    %esi,%eax
  80150f:	89 f2                	mov    %esi,%edx
  801511:	d3 ef                	shr    %cl,%edi
  801513:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801517:	d3 e0                	shl    %cl,%eax
  801519:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80151d:	09 f8                	or     %edi,%eax
  80151f:	d3 ea                	shr    %cl,%edx
  801521:	83 c4 20             	add    $0x20,%esp
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    
  801528:	39 d6                	cmp    %edx,%esi
  80152a:	75 d9                	jne    801505 <__umoddi3+0xf5>
  80152c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80152f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801532:	eb d1                	jmp    801505 <__umoddi3+0xf5>
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	39 f2                	cmp    %esi,%edx
  80153a:	0f 82 18 ff ff ff    	jb     801458 <__umoddi3+0x48>
  801540:	e9 1d ff ff ff       	jmp    801462 <__umoddi3+0x52>
