
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 24 11 00 00       	call   801166 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 46 10 00 00       	call   801096 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  80005f:	e8 59 01 00 00       	call   8001bd <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 4a 11 00 00       	call   8011d1 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 51 11 00 00       	call   8011f3 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 ea 0f 00 00       	call   801096 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 16 15 80 00 	movl   $0x801516,(%esp)
  8000bf:	e8 f9 00 00 00       	call   8001bd <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 e6 10 00 00       	call   8011d1 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80010a:	e8 87 0f 00 00       	call   801096 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 7c 0f 00 00       	call   8010d6 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800180:	8b 45 08             	mov    0x8(%ebp),%eax
  800183:	89 44 24 08          	mov    %eax,0x8(%esp)
  800187:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	c7 04 24 d7 01 80 00 	movl   $0x8001d7,(%esp)
  800198:	e8 d0 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 17 0b 00 00       	call   800ccc <sys_cputs>

	return b.cnt;
}
  8001b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001c3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 87 ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	53                   	push   %ebx
  8001db:	83 ec 14             	sub    $0x14,%esp
  8001de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e1:	8b 03                	mov    (%ebx),%eax
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ea:	83 c0 01             	add    $0x1,%eax
  8001ed:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f4:	75 19                	jne    80020f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fd:	00 
  8001fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 c3 0a 00 00       	call   800ccc <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80020f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	5b                   	pop    %ebx
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    
  800219:	00 00                	add    %al,(%eax)
  80021b:	00 00                	add    %al,(%eax)
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800243:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800246:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024b:	39 d1                	cmp    %edx,%ecx
  80024d:	72 15                	jb     800264 <printnum+0x44>
  80024f:	77 07                	ja     800258 <printnum+0x38>
  800251:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800254:	39 d0                	cmp    %edx,%eax
  800256:	76 0c                	jbe    800264 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	8d 76 00             	lea    0x0(%esi),%esi
  800260:	7f 61                	jg     8002c3 <printnum+0xa3>
  800262:	eb 70                	jmp    8002d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800277:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80027b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80027e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800281:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800284:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800288:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028f:	00 
  800290:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800299:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029d:	e8 ee 0f 00 00       	call   801290 <__udivdi3>
  8002a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b7:	89 f2                	mov    %esi,%edx
  8002b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002bc:	e8 5f ff ff ff       	call   800220 <printnum>
  8002c1:	eb 11                	jmp    8002d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c7:	89 3c 24             	mov    %edi,(%esp)
  8002ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cd:	83 eb 01             	sub    $0x1,%ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f ef                	jg     8002c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ea:	00 
  8002eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ee:	89 14 24             	mov    %edx,(%esp)
  8002f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002f8:	e8 c3 10 00 00       	call   8013c0 <__umoddi3>
  8002fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800301:	0f be 80 33 15 80 00 	movsbl 0x801533(%eax),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80030e:	83 c4 4c             	add    $0x4c,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800319:	83 fa 01             	cmp    $0x1,%edx
  80031c:	7e 0e                	jle    80032c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 08             	lea    0x8(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	8b 52 04             	mov    0x4(%edx),%edx
  80032a:	eb 22                	jmp    80034e <getuint+0x38>
	else if (lflag)
  80032c:	85 d2                	test   %edx,%edx
  80032e:	74 10                	je     800340 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 04             	lea    0x4(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	eb 0e                	jmp    80034e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800356:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	3b 50 04             	cmp    0x4(%eax),%edx
  80035f:	73 0a                	jae    80036b <sprintputch+0x1b>
		*b->buf++ = ch;
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 0a                	mov    %cl,(%edx)
  800366:	83 c2 01             	add    $0x1,%edx
  800369:	89 10                	mov    %edx,(%eax)
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 5c             	sub    $0x5c,%esp
  800376:	8b 7d 08             	mov    0x8(%ebp),%edi
  800379:	8b 75 0c             	mov    0xc(%ebp),%esi
  80037c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80037f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800386:	eb 11                	jmp    800399 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800388:	85 c0                	test   %eax,%eax
  80038a:	0f 84 09 04 00 00    	je     800799 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800390:	89 74 24 04          	mov    %esi,0x4(%esp)
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	0f b6 03             	movzbl (%ebx),%eax
  80039c:	83 c3 01             	add    $0x1,%ebx
  80039f:	83 f8 25             	cmp    $0x25,%eax
  8003a2:	75 e4                	jne    800388 <vprintfmt+0x1b>
  8003a4:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003a8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003af:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003b6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c2:	eb 06                	jmp    8003ca <vprintfmt+0x5d>
  8003c4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	0f b6 13             	movzbl (%ebx),%edx
  8003cd:	0f b6 c2             	movzbl %dl,%eax
  8003d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003d6:	83 ea 23             	sub    $0x23,%edx
  8003d9:	80 fa 55             	cmp    $0x55,%dl
  8003dc:	0f 87 9a 03 00 00    	ja     80077c <vprintfmt+0x40f>
  8003e2:	0f b6 d2             	movzbl %dl,%edx
  8003e5:	ff 24 95 00 16 80 00 	jmp    *0x801600(,%edx,4)
  8003ec:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003f0:	eb d6                	jmp    8003c8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f5:	83 ea 30             	sub    $0x30,%edx
  8003f8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003fe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800401:	83 fb 09             	cmp    $0x9,%ebx
  800404:	77 4c                	ja     800452 <vprintfmt+0xe5>
  800406:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800409:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80040f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800412:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800416:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800419:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80041c:	83 fb 09             	cmp    $0x9,%ebx
  80041f:	76 eb                	jbe    80040c <vprintfmt+0x9f>
  800421:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800424:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800427:	eb 29                	jmp    800452 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800429:	8b 55 14             	mov    0x14(%ebp),%edx
  80042c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80042f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800432:	8b 12                	mov    (%edx),%edx
  800434:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800437:	eb 19                	jmp    800452 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043c:	c1 fa 1f             	sar    $0x1f,%edx
  80043f:	f7 d2                	not    %edx
  800441:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800444:	eb 82                	jmp    8003c8 <vprintfmt+0x5b>
  800446:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80044d:	e9 76 ff ff ff       	jmp    8003c8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800452:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800456:	0f 89 6c ff ff ff    	jns    8003c8 <vprintfmt+0x5b>
  80045c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80045f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800462:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800465:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800468:	e9 5b ff ff ff       	jmp    8003c8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800470:	e9 53 ff ff ff       	jmp    8003c8 <vprintfmt+0x5b>
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	89 74 24 04          	mov    %esi,0x4(%esp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	ff d7                	call   *%edi
  80048c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80048f:	e9 05 ff ff ff       	jmp    800399 <vprintfmt+0x2c>
  800494:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	89 c2                	mov    %eax,%edx
  8004a4:	c1 fa 1f             	sar    $0x1f,%edx
  8004a7:	31 d0                	xor    %edx,%eax
  8004a9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ab:	83 f8 08             	cmp    $0x8,%eax
  8004ae:	7f 0b                	jg     8004bb <vprintfmt+0x14e>
  8004b0:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	75 20                	jne    8004db <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bf:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  8004c6:	00 
  8004c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cb:	89 3c 24             	mov    %edi,(%esp)
  8004ce:	e8 4e 03 00 00       	call   800821 <printfmt>
  8004d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	e9 be fe ff ff       	jmp    800399 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004df:	c7 44 24 08 4d 15 80 	movl   $0x80154d,0x8(%esp)
  8004e6:	00 
  8004e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004eb:	89 3c 24             	mov    %edi,(%esp)
  8004ee:	e8 2e 03 00 00       	call   800821 <printfmt>
  8004f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f6:	e9 9e fe ff ff       	jmp    800399 <vprintfmt+0x2c>
  8004fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800506:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800517:	85 c0                	test   %eax,%eax
  800519:	75 07                	jne    800522 <vprintfmt+0x1b5>
  80051b:	c7 45 c4 50 15 80 00 	movl   $0x801550,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800522:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800526:	7e 06                	jle    80052e <vprintfmt+0x1c1>
  800528:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80052c:	75 13                	jne    800541 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800531:	0f be 02             	movsbl (%edx),%eax
  800534:	85 c0                	test   %eax,%eax
  800536:	0f 85 99 00 00 00    	jne    8005d5 <vprintfmt+0x268>
  80053c:	e9 86 00 00 00       	jmp    8005c7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800545:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800548:	89 0c 24             	mov    %ecx,(%esp)
  80054b:	e8 1b 03 00 00       	call   80086b <strnlen>
  800550:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800553:	29 c2                	sub    %eax,%edx
  800555:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800558:	85 d2                	test   %edx,%edx
  80055a:	7e d2                	jle    80052e <vprintfmt+0x1c1>
					putch(padc, putdat);
  80055c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800566:	89 d3                	mov    %edx,%ebx
  800568:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800574:	83 eb 01             	sub    $0x1,%ebx
  800577:	85 db                	test   %ebx,%ebx
  800579:	7f ed                	jg     800568 <vprintfmt+0x1fb>
  80057b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80057e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800585:	eb a7                	jmp    80052e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80058b:	74 18                	je     8005a5 <vprintfmt+0x238>
  80058d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800590:	83 fa 5e             	cmp    $0x5e,%edx
  800593:	76 10                	jbe    8005a5 <vprintfmt+0x238>
					putch('?', putdat);
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800599:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a0:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a3:	eb 0a                	jmp    8005af <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005af:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005b3:	0f be 03             	movsbl (%ebx),%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	74 05                	je     8005bf <vprintfmt+0x252>
  8005ba:	83 c3 01             	add    $0x1,%ebx
  8005bd:	eb 29                	jmp    8005e8 <vprintfmt+0x27b>
  8005bf:	89 fe                	mov    %edi,%esi
  8005c1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005c4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cb:	7f 2e                	jg     8005fb <vprintfmt+0x28e>
  8005cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d0:	e9 c4 fd ff ff       	jmp    800399 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005d8:	83 c2 01             	add    $0x1,%edx
  8005db:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005de:	89 f7                	mov    %esi,%edi
  8005e0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005e6:	89 d3                	mov    %edx,%ebx
  8005e8:	85 f6                	test   %esi,%esi
  8005ea:	78 9b                	js     800587 <vprintfmt+0x21a>
  8005ec:	83 ee 01             	sub    $0x1,%esi
  8005ef:	79 96                	jns    800587 <vprintfmt+0x21a>
  8005f1:	89 fe                	mov    %edi,%esi
  8005f3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005f6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005f9:	eb cc                	jmp    8005c7 <vprintfmt+0x25a>
  8005fb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005fe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800601:	89 74 24 04          	mov    %esi,0x4(%esp)
  800605:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 eb 01             	sub    $0x1,%ebx
  800611:	85 db                	test   %ebx,%ebx
  800613:	7f ec                	jg     800601 <vprintfmt+0x294>
  800615:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800618:	e9 7c fd ff ff       	jmp    800399 <vprintfmt+0x2c>
  80061d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 16                	jle    80063b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 08             	lea    0x8(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	8b 48 04             	mov    0x4(%eax),%ecx
  800633:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800636:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800639:	eb 32                	jmp    80066d <vprintfmt+0x300>
	else if (lflag)
  80063b:	85 c9                	test   %ecx,%ecx
  80063d:	74 18                	je     800657 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064d:	89 c1                	mov    %eax,%ecx
  80064f:	c1 f9 1f             	sar    $0x1f,%ecx
  800652:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800655:	eb 16                	jmp    80066d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800665:	89 c2                	mov    %eax,%edx
  800667:	c1 fa 1f             	sar    $0x1f,%edx
  80066a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800670:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800673:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800678:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80067c:	0f 89 b8 00 00 00    	jns    80073a <vprintfmt+0x3cd>
				putch('-', putdat);
  800682:	89 74 24 04          	mov    %esi,0x4(%esp)
  800686:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80068d:	ff d7                	call   *%edi
				num = -(long long) num;
  80068f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800692:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800695:	f7 d9                	neg    %ecx
  800697:	83 d3 00             	adc    $0x0,%ebx
  80069a:	f7 db                	neg    %ebx
  80069c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a1:	e9 94 00 00 00       	jmp    80073a <vprintfmt+0x3cd>
  8006a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a9:	89 ca                	mov    %ecx,%edx
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 63 fc ff ff       	call   800316 <getuint>
  8006b3:	89 c1                	mov    %eax,%ecx
  8006b5:	89 d3                	mov    %edx,%ebx
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006bc:	eb 7c                	jmp    80073a <vprintfmt+0x3cd>
  8006be:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006cc:	ff d7                	call   *%edi
			putch('X', putdat);
  8006ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006d9:	ff d7                	call   *%edi
			putch('X', putdat);
  8006db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006df:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006e6:	ff d7                	call   *%edi
  8006e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006eb:	e9 a9 fc ff ff       	jmp    800399 <vprintfmt+0x2c>
  8006f0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006fe:	ff d7                	call   *%edi
			putch('x', putdat);
  800700:	89 74 24 04          	mov    %esi,0x4(%esp)
  800704:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)
  800716:	8b 08                	mov    (%eax),%ecx
  800718:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800722:	eb 16                	jmp    80073a <vprintfmt+0x3cd>
  800724:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800727:	89 ca                	mov    %ecx,%edx
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 e5 fb ff ff       	call   800316 <getuint>
  800731:	89 c1                	mov    %eax,%ecx
  800733:	89 d3                	mov    %edx,%ebx
  800735:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80073e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800742:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800745:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800749:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074d:	89 0c 24             	mov    %ecx,(%esp)
  800750:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800754:	89 f2                	mov    %esi,%edx
  800756:	89 f8                	mov    %edi,%eax
  800758:	e8 c3 fa ff ff       	call   800220 <printnum>
  80075d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800760:	e9 34 fc ff ff       	jmp    800399 <vprintfmt+0x2c>
  800765:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800768:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076f:	89 14 24             	mov    %edx,(%esp)
  800772:	ff d7                	call   *%edi
  800774:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800777:	e9 1d fc ff ff       	jmp    800399 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800780:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800787:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800789:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80078c:	80 38 25             	cmpb   $0x25,(%eax)
  80078f:	0f 84 04 fc ff ff    	je     800399 <vprintfmt+0x2c>
  800795:	89 c3                	mov    %eax,%ebx
  800797:	eb f0                	jmp    800789 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800799:	83 c4 5c             	add    $0x5c,%esp
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5f                   	pop    %edi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 28             	sub    $0x28,%esp
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	74 04                	je     8007b5 <vsnprintf+0x14>
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	7f 07                	jg     8007bc <vsnprintf+0x1b>
  8007b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ba:	eb 3b                	jmp    8007f7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bf:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e2:	c7 04 24 50 03 80 00 	movl   $0x800350,(%esp)
  8007e9:	e8 7f fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800802:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800806:	8b 45 10             	mov    0x10(%ebp),%eax
  800809:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	e8 82 ff ff ff       	call   8007a1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081f:	c9                   	leave  
  800820:	c3                   	ret    

00800821 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	8b 45 10             	mov    0x10(%ebp),%eax
  800831:	89 44 24 08          	mov    %eax,0x8(%esp)
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 26 fb ff ff       	call   80036d <vprintfmt>
	va_end(ap);
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    
  800849:	00 00                	add    %al,(%eax)
  80084b:	00 00                	add    %al,(%eax)
  80084d:	00 00                	add    %al,(%eax)
	...

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 19                	je     800892 <strnlen+0x27>
  800879:	80 3b 00             	cmpb   $0x0,(%ebx)
  80087c:	74 14                	je     800892 <strnlen+0x27>
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c8                	cmp    %ecx,%eax
  800888:	74 0d                	je     800897 <strnlen+0x2c>
  80088a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x18>
  800890:	eb 05                	jmp    800897 <strnlen+0x2c>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	75 f2                	jne    8008a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c4:	89 1c 24             	mov    %ebx,(%esp)
  8008c7:	e8 84 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 bc ff ff ff       	call   80089a <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	83 c4 08             	add    $0x8,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	85 f6                	test   %esi,%esi
  8008f6:	74 18                	je     800910 <strncpy+0x2a>
  8008f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008fd:	0f b6 1a             	movzbl (%edx),%ebx
  800900:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 3a 01             	cmpb   $0x1,(%edx)
  800906:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	39 ce                	cmp    %ecx,%esi
  80090e:	77 ed                	ja     8008fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 75 08             	mov    0x8(%ebp),%esi
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800922:	89 f0                	mov    %esi,%eax
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 27                	je     80094f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800928:	83 e9 01             	sub    $0x1,%ecx
  80092b:	74 1d                	je     80094a <strlcpy+0x36>
  80092d:	0f b6 1a             	movzbl (%edx),%ebx
  800930:	84 db                	test   %bl,%bl
  800932:	74 16                	je     80094a <strlcpy+0x36>
			*dst++ = *src++;
  800934:	88 18                	mov    %bl,(%eax)
  800936:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800939:	83 e9 01             	sub    $0x1,%ecx
  80093c:	74 0e                	je     80094c <strlcpy+0x38>
			*dst++ = *src++;
  80093e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	84 db                	test   %bl,%bl
  800946:	75 ec                	jne    800934 <strlcpy+0x20>
  800948:	eb 02                	jmp    80094c <strlcpy+0x38>
  80094a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80094c:	c6 00 00             	movb   $0x0,(%eax)
  80094f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	84 c0                	test   %al,%al
  800963:	74 15                	je     80097a <strcmp+0x25>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	75 11                	jne    80097a <strcmp+0x25>
		p++, q++;
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096f:	0f b6 01             	movzbl (%ecx),%eax
  800972:	84 c0                	test   %al,%al
  800974:	74 04                	je     80097a <strcmp+0x25>
  800976:	3a 02                	cmp    (%edx),%al
  800978:	74 ef                	je     800969 <strcmp+0x14>
  80097a:	0f b6 c0             	movzbl %al,%eax
  80097d:	0f b6 12             	movzbl (%edx),%edx
  800980:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800991:	85 c0                	test   %eax,%eax
  800993:	74 23                	je     8009b8 <strncmp+0x34>
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	84 db                	test   %bl,%bl
  80099a:	74 25                	je     8009c1 <strncmp+0x3d>
  80099c:	3a 19                	cmp    (%ecx),%bl
  80099e:	75 21                	jne    8009c1 <strncmp+0x3d>
  8009a0:	83 e8 01             	sub    $0x1,%eax
  8009a3:	74 13                	je     8009b8 <strncmp+0x34>
		n--, p++, q++;
  8009a5:	83 c2 01             	add    $0x1,%edx
  8009a8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ab:	0f b6 1a             	movzbl (%edx),%ebx
  8009ae:	84 db                	test   %bl,%bl
  8009b0:	74 0f                	je     8009c1 <strncmp+0x3d>
  8009b2:	3a 19                	cmp    (%ecx),%bl
  8009b4:	74 ea                	je     8009a0 <strncmp+0x1c>
  8009b6:	eb 09                	jmp    8009c1 <strncmp+0x3d>
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	90                   	nop
  8009c0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c1:	0f b6 02             	movzbl (%edx),%eax
  8009c4:	0f b6 11             	movzbl (%ecx),%edx
  8009c7:	29 d0                	sub    %edx,%eax
  8009c9:	eb f2                	jmp    8009bd <strncmp+0x39>

008009cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strchr+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strchr+0x1f>
  8009e0:	eb 17                	jmp    8009f9 <strchr+0x2e>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0f                	je     8009f9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strchr+0x17>
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	74 18                	je     800a24 <strfind+0x29>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	75 0a                	jne    800a1a <strfind+0x1f>
  800a10:	eb 12                	jmp    800a24 <strfind+0x29>
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a18:	74 0a                	je     800a24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 ee                	jne    800a12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	89 1c 24             	mov    %ebx,(%esp)
  800a2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a40:	85 c9                	test   %ecx,%ecx
  800a42:	74 30                	je     800a74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4a:	75 25                	jne    800a71 <memset+0x4b>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 20                	jne    800a71 <memset+0x4b>
		c &= 0xFF;
  800a51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a54:	89 d3                	mov    %edx,%ebx
  800a56:	c1 e3 08             	shl    $0x8,%ebx
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	c1 e6 18             	shl    $0x18,%esi
  800a5e:	89 d0                	mov    %edx,%eax
  800a60:	c1 e0 10             	shl    $0x10,%eax
  800a63:	09 f0                	or     %esi,%eax
  800a65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a67:	09 d8                	or     %ebx,%eax
  800a69:	c1 e9 02             	shr    $0x2,%ecx
  800a6c:	fc                   	cld    
  800a6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6f:	eb 03                	jmp    800a74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a71:	fc                   	cld    
  800a72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a74:	89 f8                	mov    %edi,%eax
  800a76:	8b 1c 24             	mov    (%esp),%ebx
  800a79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a81:	89 ec                	mov    %ebp,%esp
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	89 34 24             	mov    %esi,(%esp)
  800a8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a9d:	39 c6                	cmp    %eax,%esi
  800a9f:	73 35                	jae    800ad6 <memmove+0x51>
  800aa1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 2e                	jae    800ad6 <memmove+0x51>
		s += n;
		d += n;
  800aa8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	f6 c2 03             	test   $0x3,%dl
  800aad:	75 1b                	jne    800aca <memmove+0x45>
  800aaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab5:	75 13                	jne    800aca <memmove+0x45>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 0e                	jne    800aca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800abc:	83 ef 04             	sub    $0x4,%edi
  800abf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	fd                   	std    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac8:	eb 09                	jmp    800ad3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad0:	fd                   	std    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad4:	eb 20                	jmp    800af6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adc:	75 15                	jne    800af3 <memmove+0x6e>
  800ade:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae4:	75 0d                	jne    800af3 <memmove+0x6e>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 08                	jne    800af3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
  800aee:	fc                   	cld    
  800aef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	eb 03                	jmp    800af6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af3:	fc                   	cld    
  800af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af6:	8b 34 24             	mov    (%esp),%esi
  800af9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800afd:	89 ec                	mov    %ebp,%esp
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b07:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	89 04 24             	mov    %eax,(%esp)
  800b1b:	e8 65 ff ff ff       	call   800a85 <memmove>
}
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	74 36                	je     800b6b <memcmp+0x49>
		if (*s1 != *s2)
  800b35:	0f b6 06             	movzbl (%esi),%eax
  800b38:	0f b6 1f             	movzbl (%edi),%ebx
  800b3b:	38 d8                	cmp    %bl,%al
  800b3d:	74 20                	je     800b5f <memcmp+0x3d>
  800b3f:	eb 14                	jmp    800b55 <memcmp+0x33>
  800b41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	83 e9 01             	sub    $0x1,%ecx
  800b51:	38 d8                	cmp    %bl,%al
  800b53:	74 12                	je     800b67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 11                	jmp    800b70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	83 e9 01             	sub    $0x1,%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	85 c9                	test   %ecx,%ecx
  800b69:	75 d6                	jne    800b41 <memcmp+0x1f>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b80:	39 d0                	cmp    %edx,%eax
  800b82:	73 15                	jae    800b99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b88:	38 08                	cmp    %cl,(%eax)
  800b8a:	75 06                	jne    800b92 <memfind+0x1d>
  800b8c:	eb 0b                	jmp    800b99 <memfind+0x24>
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	74 07                	je     800b99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	39 c2                	cmp    %eax,%edx
  800b97:	77 f5                	ja     800b8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 04             	sub    $0x4,%esp
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 02             	movzbl (%edx),%eax
  800bad:	3c 20                	cmp    $0x20,%al
  800baf:	74 04                	je     800bb5 <strtol+0x1a>
  800bb1:	3c 09                	cmp    $0x9,%al
  800bb3:	75 0e                	jne    800bc3 <strtol+0x28>
		s++;
  800bb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	0f b6 02             	movzbl (%edx),%eax
  800bbb:	3c 20                	cmp    $0x20,%al
  800bbd:	74 f6                	je     800bb5 <strtol+0x1a>
  800bbf:	3c 09                	cmp    $0x9,%al
  800bc1:	74 f2                	je     800bb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc3:	3c 2b                	cmp    $0x2b,%al
  800bc5:	75 0c                	jne    800bd3 <strtol+0x38>
		s++;
  800bc7:	83 c2 01             	add    $0x1,%edx
  800bca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bd1:	eb 15                	jmp    800be8 <strtol+0x4d>
	else if (*s == '-')
  800bd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bda:	3c 2d                	cmp    $0x2d,%al
  800bdc:	75 0a                	jne    800be8 <strtol+0x4d>
		s++, neg = 1;
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	0f 94 c0             	sete   %al
  800bed:	74 05                	je     800bf4 <strtol+0x59>
  800bef:	83 fb 10             	cmp    $0x10,%ebx
  800bf2:	75 18                	jne    800c0c <strtol+0x71>
  800bf4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf7:	75 13                	jne    800c0c <strtol+0x71>
  800bf9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfd:	8d 76 00             	lea    0x0(%esi),%esi
  800c00:	75 0a                	jne    800c0c <strtol+0x71>
		s += 2, base = 16;
  800c02:	83 c2 02             	add    $0x2,%edx
  800c05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0a:	eb 15                	jmp    800c21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0c:	84 c0                	test   %al,%al
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	74 0f                	je     800c21 <strtol+0x86>
  800c12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c17:	80 3a 30             	cmpb   $0x30,(%edx)
  800c1a:	75 05                	jne    800c21 <strtol+0x86>
		s++, base = 8;
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 0a             	movzbl (%edx),%ecx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 08                	ja     800c3d <strtol+0xa2>
			dig = *s - '0';
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 30             	sub    $0x30,%ecx
  800c3b:	eb 1e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c40:	80 fb 19             	cmp    $0x19,%bl
  800c43:	77 08                	ja     800c4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c45:	0f be c9             	movsbl %cl,%ecx
  800c48:	83 e9 57             	sub    $0x57,%ecx
  800c4b:	eb 0e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c50:	80 fb 19             	cmp    $0x19,%bl
  800c53:	77 15                	ja     800c6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5b:	39 f1                	cmp    %esi,%ecx
  800c5d:	7d 0b                	jge    800c6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c5f:	83 c2 01             	add    $0x1,%edx
  800c62:	0f af c6             	imul   %esi,%eax
  800c65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c68:	eb be                	jmp    800c28 <strtol+0x8d>
  800c6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c70:	74 05                	je     800c77 <strtol+0xdc>
		*endptr = (char *) s;
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c7b:	74 04                	je     800c81 <strtol+0xe6>
  800c7d:	89 c8                	mov    %ecx,%eax
  800c7f:	f7 d8                	neg    %eax
}
  800c81:	83 c4 04             	add    $0x4,%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
  800c89:	00 00                	add    %al,(%eax)
	...

00800c8c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	89 1c 24             	mov    %ebx,(%esp)
  800c95:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c99:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	89 d3                	mov    %edx,%ebx
  800ca7:	89 d7                	mov    %edx,%edi
  800ca9:	51                   	push   %ecx
  800caa:	52                   	push   %edx
  800cab:	53                   	push   %ebx
  800cac:	54                   	push   %esp
  800cad:	55                   	push   %ebp
  800cae:	56                   	push   %esi
  800caf:	57                   	push   %edi
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	8d 35 ba 0c 80 00    	lea    0x800cba,%esi
  800cb8:	0f 34                	sysenter 
  800cba:	5f                   	pop    %edi
  800cbb:	5e                   	pop    %esi
  800cbc:	5d                   	pop    %ebp
  800cbd:	5c                   	pop    %esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5a                   	pop    %edx
  800cc0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc1:	8b 1c 24             	mov    (%esp),%ebx
  800cc4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 08             	sub    $0x8,%esp
  800cd2:	89 1c 24             	mov    %ebx,(%esp)
  800cd5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 c3                	mov    %eax,%ebx
  800ce6:	89 c7                	mov    %eax,%edi
  800ce8:	51                   	push   %ecx
  800ce9:	52                   	push   %edx
  800cea:	53                   	push   %ebx
  800ceb:	54                   	push   %esp
  800cec:	55                   	push   %ebp
  800ced:	56                   	push   %esi
  800cee:	57                   	push   %edi
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	8d 35 f9 0c 80 00    	lea    0x800cf9,%esi
  800cf7:	0f 34                	sysenter 
  800cf9:	5f                   	pop    %edi
  800cfa:	5e                   	pop    %esi
  800cfb:	5d                   	pop    %ebp
  800cfc:	5c                   	pop    %esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5a                   	pop    %edx
  800cff:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d00:	8b 1c 24             	mov    (%esp),%ebx
  800d03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d07:	89 ec                	mov    %ebp,%esp
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
  800d11:	89 1c 24             	mov    %ebx,(%esp)
  800d14:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 cb                	mov    %ecx,%ebx
  800d27:	89 cf                	mov    %ecx,%edi
  800d29:	51                   	push   %ecx
  800d2a:	52                   	push   %edx
  800d2b:	53                   	push   %ebx
  800d2c:	54                   	push   %esp
  800d2d:	55                   	push   %ebp
  800d2e:	56                   	push   %esi
  800d2f:	57                   	push   %edi
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	8d 35 3a 0d 80 00    	lea    0x800d3a,%esi
  800d38:	0f 34                	sysenter 
  800d3a:	5f                   	pop    %edi
  800d3b:	5e                   	pop    %esi
  800d3c:	5d                   	pop    %ebp
  800d3d:	5c                   	pop    %esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5a                   	pop    %edx
  800d40:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800d41:	8b 1c 24             	mov    (%esp),%ebx
  800d44:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 28             	sub    $0x28,%esp
  800d52:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d55:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 cb                	mov    %ecx,%ebx
  800d67:	89 cf                	mov    %ecx,%edi
  800d69:	51                   	push   %ecx
  800d6a:	52                   	push   %edx
  800d6b:	53                   	push   %ebx
  800d6c:	54                   	push   %esp
  800d6d:	55                   	push   %ebp
  800d6e:	56                   	push   %esi
  800d6f:	57                   	push   %edi
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	8d 35 7a 0d 80 00    	lea    0x800d7a,%esi
  800d78:	0f 34                	sysenter 
  800d7a:	5f                   	pop    %edi
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	5c                   	pop    %esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5a                   	pop    %edx
  800d80:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  800da8:	e8 6b 04 00 00       	call   801218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800db0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db3:	89 ec                	mov    %ebp,%esp
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
  800dbd:	89 1c 24             	mov    %ebx,(%esp)
  800dc0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	51                   	push   %ecx
  800dd6:	52                   	push   %edx
  800dd7:	53                   	push   %ebx
  800dd8:	54                   	push   %esp
  800dd9:	55                   	push   %ebp
  800dda:	56                   	push   %esi
  800ddb:	57                   	push   %edi
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	8d 35 e6 0d 80 00    	lea    0x800de6,%esi
  800de4:	0f 34                	sysenter 
  800de6:	5f                   	pop    %edi
  800de7:	5e                   	pop    %esi
  800de8:	5d                   	pop    %ebp
  800de9:	5c                   	pop    %esp
  800dea:	5b                   	pop    %ebx
  800deb:	5a                   	pop    %edx
  800dec:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ded:	8b 1c 24             	mov    (%esp),%ebx
  800df0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800df4:	89 ec                	mov    %ebp,%esp
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	83 ec 28             	sub    $0x28,%esp
  800dfe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e01:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	89 df                	mov    %ebx,%edi
  800e16:	51                   	push   %ecx
  800e17:	52                   	push   %edx
  800e18:	53                   	push   %ebx
  800e19:	54                   	push   %esp
  800e1a:	55                   	push   %ebp
  800e1b:	56                   	push   %esi
  800e1c:	57                   	push   %edi
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	8d 35 27 0e 80 00    	lea    0x800e27,%esi
  800e25:	0f 34                	sysenter 
  800e27:	5f                   	pop    %edi
  800e28:	5e                   	pop    %esi
  800e29:	5d                   	pop    %ebp
  800e2a:	5c                   	pop    %esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5a                   	pop    %edx
  800e2d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 28                	jle    800e5a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e36:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800e45:	00 
  800e46:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e4d:	00 
  800e4e:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  800e55:	e8 be 03 00 00       	call   801218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e60:	89 ec                	mov    %ebp,%esp
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 28             	sub    $0x28,%esp
  800e6a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e6d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e75:	b8 09 00 00 00       	mov    $0x9,%eax
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 df                	mov    %ebx,%edi
  800e82:	51                   	push   %ecx
  800e83:	52                   	push   %edx
  800e84:	53                   	push   %ebx
  800e85:	54                   	push   %esp
  800e86:	55                   	push   %ebp
  800e87:	56                   	push   %esi
  800e88:	57                   	push   %edi
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	8d 35 93 0e 80 00    	lea    0x800e93,%esi
  800e91:	0f 34                	sysenter 
  800e93:	5f                   	pop    %edi
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	5c                   	pop    %esp
  800e97:	5b                   	pop    %ebx
  800e98:	5a                   	pop    %edx
  800e99:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	7e 28                	jle    800ec6 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800eb9:	00 
  800eba:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  800ec1:	e8 52 03 00 00       	call   801218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ec9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ecc:	89 ec                	mov    %ebp,%esp
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 28             	sub    $0x28,%esp
  800ed6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ed9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	89 df                	mov    %ebx,%edi
  800eee:	51                   	push   %ecx
  800eef:	52                   	push   %edx
  800ef0:	53                   	push   %ebx
  800ef1:	54                   	push   %esp
  800ef2:	55                   	push   %ebp
  800ef3:	56                   	push   %esi
  800ef4:	57                   	push   %edi
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	8d 35 ff 0e 80 00    	lea    0x800eff,%esi
  800efd:	0f 34                	sysenter 
  800eff:	5f                   	pop    %edi
  800f00:	5e                   	pop    %esi
  800f01:	5d                   	pop    %ebp
  800f02:	5c                   	pop    %esp
  800f03:	5b                   	pop    %ebx
  800f04:	5a                   	pop    %edx
  800f05:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f06:	85 c0                	test   %eax,%eax
  800f08:	7e 28                	jle    800f32 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f15:	00 
  800f16:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f25:	00 
  800f26:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  800f2d:	e8 e6 02 00 00       	call   801218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f32:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 28             	sub    $0x28,%esp
  800f42:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f45:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f48:	b8 06 00 00 00       	mov    $0x6,%eax
  800f4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	51                   	push   %ecx
  800f5a:	52                   	push   %edx
  800f5b:	53                   	push   %ebx
  800f5c:	54                   	push   %esp
  800f5d:	55                   	push   %ebp
  800f5e:	56                   	push   %esi
  800f5f:	57                   	push   %edi
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	8d 35 6a 0f 80 00    	lea    0x800f6a,%esi
  800f68:	0f 34                	sysenter 
  800f6a:	5f                   	pop    %edi
  800f6b:	5e                   	pop    %esi
  800f6c:	5d                   	pop    %ebp
  800f6d:	5c                   	pop    %esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5a                   	pop    %edx
  800f70:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f71:	85 c0                	test   %eax,%eax
  800f73:	7e 28                	jle    800f9d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f79:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f80:	00 
  800f81:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800f88:	00 
  800f89:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f90:	00 
  800f91:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  800f98:	e8 7b 02 00 00       	call   801218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f9d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fa0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa3:	89 ec                	mov    %ebp,%esp
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 28             	sub    $0x28,%esp
  800fad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fb0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	51                   	push   %ecx
  800fc7:	52                   	push   %edx
  800fc8:	53                   	push   %ebx
  800fc9:	54                   	push   %esp
  800fca:	55                   	push   %ebp
  800fcb:	56                   	push   %esi
  800fcc:	57                   	push   %edi
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	8d 35 d7 0f 80 00    	lea    0x800fd7,%esi
  800fd5:	0f 34                	sysenter 
  800fd7:	5f                   	pop    %edi
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	5c                   	pop    %esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5a                   	pop    %edx
  800fdd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	7e 28                	jle    80100a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fed:	00 
  800fee:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  800ff5:	00 
  800ff6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800ffd:	00 
  800ffe:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  801005:	e8 0e 02 00 00       	call   801218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80100a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80100d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801010:	89 ec                	mov    %ebp,%esp
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 08             	sub    $0x8,%esp
  80101a:	89 1c 24             	mov    %ebx,(%esp)
  80101d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	b8 0b 00 00 00       	mov    $0xb,%eax
  80102b:	89 d1                	mov    %edx,%ecx
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 d7                	mov    %edx,%edi
  801031:	51                   	push   %ecx
  801032:	52                   	push   %edx
  801033:	53                   	push   %ebx
  801034:	54                   	push   %esp
  801035:	55                   	push   %ebp
  801036:	56                   	push   %esi
  801037:	57                   	push   %edi
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	8d 35 42 10 80 00    	lea    0x801042,%esi
  801040:	0f 34                	sysenter 
  801042:	5f                   	pop    %edi
  801043:	5e                   	pop    %esi
  801044:	5d                   	pop    %ebp
  801045:	5c                   	pop    %esp
  801046:	5b                   	pop    %ebx
  801047:	5a                   	pop    %edx
  801048:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801049:	8b 1c 24             	mov    (%esp),%ebx
  80104c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801050:	89 ec                	mov    %ebp,%esp
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 08             	sub    $0x8,%esp
  80105a:	89 1c 24             	mov    %ebx,(%esp)
  80105d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
  801066:	b8 04 00 00 00       	mov    $0x4,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 df                	mov    %ebx,%edi
  801073:	51                   	push   %ecx
  801074:	52                   	push   %edx
  801075:	53                   	push   %ebx
  801076:	54                   	push   %esp
  801077:	55                   	push   %ebp
  801078:	56                   	push   %esi
  801079:	57                   	push   %edi
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	8d 35 84 10 80 00    	lea    0x801084,%esi
  801082:	0f 34                	sysenter 
  801084:	5f                   	pop    %edi
  801085:	5e                   	pop    %esi
  801086:	5d                   	pop    %ebp
  801087:	5c                   	pop    %esp
  801088:	5b                   	pop    %ebx
  801089:	5a                   	pop    %edx
  80108a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80108b:	8b 1c 24             	mov    (%esp),%ebx
  80108e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801092:	89 ec                	mov    %ebp,%esp
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	89 1c 24             	mov    %ebx,(%esp)
  80109f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8010ad:	89 d1                	mov    %edx,%ecx
  8010af:	89 d3                	mov    %edx,%ebx
  8010b1:	89 d7                	mov    %edx,%edi
  8010b3:	51                   	push   %ecx
  8010b4:	52                   	push   %edx
  8010b5:	53                   	push   %ebx
  8010b6:	54                   	push   %esp
  8010b7:	55                   	push   %ebp
  8010b8:	56                   	push   %esi
  8010b9:	57                   	push   %edi
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	8d 35 c4 10 80 00    	lea    0x8010c4,%esi
  8010c2:	0f 34                	sysenter 
  8010c4:	5f                   	pop    %edi
  8010c5:	5e                   	pop    %esi
  8010c6:	5d                   	pop    %ebp
  8010c7:	5c                   	pop    %esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5a                   	pop    %edx
  8010ca:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010cb:	8b 1c 24             	mov    (%esp),%ebx
  8010ce:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d2:	89 ec                	mov    %ebp,%esp
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 28             	sub    $0x28,%esp
  8010dc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010df:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8010ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ef:	89 cb                	mov    %ecx,%ebx
  8010f1:	89 cf                	mov    %ecx,%edi
  8010f3:	51                   	push   %ecx
  8010f4:	52                   	push   %edx
  8010f5:	53                   	push   %ebx
  8010f6:	54                   	push   %esp
  8010f7:	55                   	push   %ebp
  8010f8:	56                   	push   %esi
  8010f9:	57                   	push   %edi
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8d 35 04 11 80 00    	lea    0x801104,%esi
  801102:	0f 34                	sysenter 
  801104:	5f                   	pop    %edi
  801105:	5e                   	pop    %esi
  801106:	5d                   	pop    %ebp
  801107:	5c                   	pop    %esp
  801108:	5b                   	pop    %ebx
  801109:	5a                   	pop    %edx
  80110a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7e 28                	jle    801137 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80111a:	00 
  80111b:	c7 44 24 08 84 17 80 	movl   $0x801784,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 a1 17 80 00 	movl   $0x8017a1,(%esp)
  801132:	e8 e1 00 00 00       	call   801218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801137:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80113a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113d:	89 ec                	mov    %ebp,%esp
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    
  801141:	00 00                	add    %al,(%eax)
	...

00801144 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80114a:	c7 44 24 08 af 17 80 	movl   $0x8017af,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801159:	00 
  80115a:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  801161:	e8 b2 00 00 00       	call   801218 <_panic>

00801166 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80116c:	c7 44 24 08 b0 17 80 	movl   $0x8017b0,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  801183:	e8 90 00 00 00       	call   801218 <_panic>

00801188 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80118e:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801194:	b8 01 00 00 00       	mov    $0x1,%eax
  801199:	39 ca                	cmp    %ecx,%edx
  80119b:	75 04                	jne    8011a1 <ipc_find_env+0x19>
  80119d:	b0 00                	mov    $0x0,%al
  80119f:	eb 11                	jmp    8011b2 <ipc_find_env+0x2a>
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	c1 e2 07             	shl    $0x7,%edx
  8011a6:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8011ac:	8b 12                	mov    (%edx),%edx
  8011ae:	39 ca                	cmp    %ecx,%edx
  8011b0:	75 0f                	jne    8011c1 <ipc_find_env+0x39>
			return envs[i].env_id;
  8011b2:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  8011b6:	c1 e0 06             	shl    $0x6,%eax
  8011b9:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  8011bf:	eb 0e                	jmp    8011cf <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c1:	83 c0 01             	add    $0x1,%eax
  8011c4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c9:	75 d6                	jne    8011a1 <ipc_find_env+0x19>
  8011cb:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8011d7:	c7 44 24 08 d0 17 80 	movl   $0x8017d0,0x8(%esp)
  8011de:	00 
  8011df:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8011e6:	00 
  8011e7:	c7 04 24 e9 17 80 00 	movl   $0x8017e9,(%esp)
  8011ee:	e8 25 00 00 00       	call   801218 <_panic>

008011f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8011f9:	c7 44 24 08 f3 17 80 	movl   $0x8017f3,0x8(%esp)
  801200:	00 
  801201:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801208:	00 
  801209:	c7 04 24 e9 17 80 00 	movl   $0x8017e9,(%esp)
  801210:	e8 03 00 00 00       	call   801218 <_panic>
  801215:	00 00                	add    %al,(%eax)
	...

00801218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801220:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801223:	a1 08 20 80 00       	mov    0x802008,%eax
  801228:	85 c0                	test   %eax,%eax
  80122a:	74 10                	je     80123c <_panic+0x24>
		cprintf("%s: ", argv0);
  80122c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801230:	c7 04 24 0c 18 80 00 	movl   $0x80180c,(%esp)
  801237:	e8 81 ef ff ff       	call   8001bd <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80123c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801242:	e8 4f fe ff ff       	call   801096 <sys_getenvid>
  801247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80124e:	8b 55 08             	mov    0x8(%ebp),%edx
  801251:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801255:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125d:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  801264:	e8 54 ef ff ff       	call   8001bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801269:	89 74 24 04          	mov    %esi,0x4(%esp)
  80126d:	8b 45 10             	mov    0x10(%ebp),%eax
  801270:	89 04 24             	mov    %eax,(%esp)
  801273:	e8 e4 ee ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  801278:	c7 04 24 27 15 80 00 	movl   $0x801527,(%esp)
  80127f:	e8 39 ef ff ff       	call   8001bd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801284:	cc                   	int3   
  801285:	eb fd                	jmp    801284 <_panic+0x6c>
	...

00801290 <__udivdi3>:
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	83 ec 10             	sub    $0x10,%esp
  801298:	8b 45 14             	mov    0x14(%ebp),%eax
  80129b:	8b 55 08             	mov    0x8(%ebp),%edx
  80129e:	8b 75 10             	mov    0x10(%ebp),%esi
  8012a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8012a9:	75 35                	jne    8012e0 <__udivdi3+0x50>
  8012ab:	39 fe                	cmp    %edi,%esi
  8012ad:	77 61                	ja     801310 <__udivdi3+0x80>
  8012af:	85 f6                	test   %esi,%esi
  8012b1:	75 0b                	jne    8012be <__udivdi3+0x2e>
  8012b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	f7 f6                	div    %esi
  8012bc:	89 c6                	mov    %eax,%esi
  8012be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8012c1:	31 d2                	xor    %edx,%edx
  8012c3:	89 f8                	mov    %edi,%eax
  8012c5:	f7 f6                	div    %esi
  8012c7:	89 c7                	mov    %eax,%edi
  8012c9:	89 c8                	mov    %ecx,%eax
  8012cb:	f7 f6                	div    %esi
  8012cd:	89 c1                	mov    %eax,%ecx
  8012cf:	89 fa                	mov    %edi,%edx
  8012d1:	89 c8                	mov    %ecx,%eax
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
  8012da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e0:	39 f8                	cmp    %edi,%eax
  8012e2:	77 1c                	ja     801300 <__udivdi3+0x70>
  8012e4:	0f bd d0             	bsr    %eax,%edx
  8012e7:	83 f2 1f             	xor    $0x1f,%edx
  8012ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012ed:	75 39                	jne    801328 <__udivdi3+0x98>
  8012ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8012f2:	0f 86 a0 00 00 00    	jbe    801398 <__udivdi3+0x108>
  8012f8:	39 f8                	cmp    %edi,%eax
  8012fa:	0f 82 98 00 00 00    	jb     801398 <__udivdi3+0x108>
  801300:	31 ff                	xor    %edi,%edi
  801302:	31 c9                	xor    %ecx,%ecx
  801304:	89 c8                	mov    %ecx,%eax
  801306:	89 fa                	mov    %edi,%edx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    
  80130f:	90                   	nop
  801310:	89 d1                	mov    %edx,%ecx
  801312:	89 fa                	mov    %edi,%edx
  801314:	89 c8                	mov    %ecx,%eax
  801316:	31 ff                	xor    %edi,%edi
  801318:	f7 f6                	div    %esi
  80131a:	89 c1                	mov    %eax,%ecx
  80131c:	89 fa                	mov    %edi,%edx
  80131e:	89 c8                	mov    %ecx,%eax
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	5e                   	pop    %esi
  801324:	5f                   	pop    %edi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    
  801327:	90                   	nop
  801328:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80132c:	89 f2                	mov    %esi,%edx
  80132e:	d3 e0                	shl    %cl,%eax
  801330:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801333:	b8 20 00 00 00       	mov    $0x20,%eax
  801338:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80133b:	89 c1                	mov    %eax,%ecx
  80133d:	d3 ea                	shr    %cl,%edx
  80133f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801343:	0b 55 ec             	or     -0x14(%ebp),%edx
  801346:	d3 e6                	shl    %cl,%esi
  801348:	89 c1                	mov    %eax,%ecx
  80134a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80134d:	89 fe                	mov    %edi,%esi
  80134f:	d3 ee                	shr    %cl,%esi
  801351:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801355:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801358:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80135b:	d3 e7                	shl    %cl,%edi
  80135d:	89 c1                	mov    %eax,%ecx
  80135f:	d3 ea                	shr    %cl,%edx
  801361:	09 d7                	or     %edx,%edi
  801363:	89 f2                	mov    %esi,%edx
  801365:	89 f8                	mov    %edi,%eax
  801367:	f7 75 ec             	divl   -0x14(%ebp)
  80136a:	89 d6                	mov    %edx,%esi
  80136c:	89 c7                	mov    %eax,%edi
  80136e:	f7 65 e8             	mull   -0x18(%ebp)
  801371:	39 d6                	cmp    %edx,%esi
  801373:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801376:	72 30                	jb     8013a8 <__udivdi3+0x118>
  801378:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80137b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80137f:	d3 e2                	shl    %cl,%edx
  801381:	39 c2                	cmp    %eax,%edx
  801383:	73 05                	jae    80138a <__udivdi3+0xfa>
  801385:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801388:	74 1e                	je     8013a8 <__udivdi3+0x118>
  80138a:	89 f9                	mov    %edi,%ecx
  80138c:	31 ff                	xor    %edi,%edi
  80138e:	e9 71 ff ff ff       	jmp    801304 <__udivdi3+0x74>
  801393:	90                   	nop
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	31 ff                	xor    %edi,%edi
  80139a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80139f:	e9 60 ff ff ff       	jmp    801304 <__udivdi3+0x74>
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8013ab:	31 ff                	xor    %edi,%edi
  8013ad:	89 c8                	mov    %ecx,%eax
  8013af:	89 fa                	mov    %edi,%edx
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    
	...

008013c0 <__umoddi3>:
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	57                   	push   %edi
  8013c4:	56                   	push   %esi
  8013c5:	83 ec 20             	sub    $0x20,%esp
  8013c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8013cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8013d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d4:	85 d2                	test   %edx,%edx
  8013d6:	89 c8                	mov    %ecx,%eax
  8013d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8013db:	75 13                	jne    8013f0 <__umoddi3+0x30>
  8013dd:	39 f7                	cmp    %esi,%edi
  8013df:	76 3f                	jbe    801420 <__umoddi3+0x60>
  8013e1:	89 f2                	mov    %esi,%edx
  8013e3:	f7 f7                	div    %edi
  8013e5:	89 d0                	mov    %edx,%eax
  8013e7:	31 d2                	xor    %edx,%edx
  8013e9:	83 c4 20             	add    $0x20,%esp
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    
  8013f0:	39 f2                	cmp    %esi,%edx
  8013f2:	77 4c                	ja     801440 <__umoddi3+0x80>
  8013f4:	0f bd ca             	bsr    %edx,%ecx
  8013f7:	83 f1 1f             	xor    $0x1f,%ecx
  8013fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013fd:	75 51                	jne    801450 <__umoddi3+0x90>
  8013ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801402:	0f 87 e0 00 00 00    	ja     8014e8 <__umoddi3+0x128>
  801408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140b:	29 f8                	sub    %edi,%eax
  80140d:	19 d6                	sbb    %edx,%esi
  80140f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801412:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801415:	89 f2                	mov    %esi,%edx
  801417:	83 c4 20             	add    $0x20,%esp
  80141a:	5e                   	pop    %esi
  80141b:	5f                   	pop    %edi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    
  80141e:	66 90                	xchg   %ax,%ax
  801420:	85 ff                	test   %edi,%edi
  801422:	75 0b                	jne    80142f <__umoddi3+0x6f>
  801424:	b8 01 00 00 00       	mov    $0x1,%eax
  801429:	31 d2                	xor    %edx,%edx
  80142b:	f7 f7                	div    %edi
  80142d:	89 c7                	mov    %eax,%edi
  80142f:	89 f0                	mov    %esi,%eax
  801431:	31 d2                	xor    %edx,%edx
  801433:	f7 f7                	div    %edi
  801435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801438:	f7 f7                	div    %edi
  80143a:	eb a9                	jmp    8013e5 <__umoddi3+0x25>
  80143c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 f2                	mov    %esi,%edx
  801444:	83 c4 20             	add    $0x20,%esp
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    
  80144b:	90                   	nop
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801454:	d3 e2                	shl    %cl,%edx
  801456:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801459:	ba 20 00 00 00       	mov    $0x20,%edx
  80145e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801461:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801464:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801468:	89 fa                	mov    %edi,%edx
  80146a:	d3 ea                	shr    %cl,%edx
  80146c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801470:	0b 55 f4             	or     -0xc(%ebp),%edx
  801473:	d3 e7                	shl    %cl,%edi
  801475:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801479:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80147c:	89 f2                	mov    %esi,%edx
  80147e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801481:	89 c7                	mov    %eax,%edi
  801483:	d3 ea                	shr    %cl,%edx
  801485:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801489:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	d3 e6                	shl    %cl,%esi
  801490:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801494:	d3 ea                	shr    %cl,%edx
  801496:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80149a:	09 d6                	or     %edx,%esi
  80149c:	89 f0                	mov    %esi,%eax
  80149e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8014a1:	d3 e7                	shl    %cl,%edi
  8014a3:	89 f2                	mov    %esi,%edx
  8014a5:	f7 75 f4             	divl   -0xc(%ebp)
  8014a8:	89 d6                	mov    %edx,%esi
  8014aa:	f7 65 e8             	mull   -0x18(%ebp)
  8014ad:	39 d6                	cmp    %edx,%esi
  8014af:	72 2b                	jb     8014dc <__umoddi3+0x11c>
  8014b1:	39 c7                	cmp    %eax,%edi
  8014b3:	72 23                	jb     8014d8 <__umoddi3+0x118>
  8014b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014b9:	29 c7                	sub    %eax,%edi
  8014bb:	19 d6                	sbb    %edx,%esi
  8014bd:	89 f0                	mov    %esi,%eax
  8014bf:	89 f2                	mov    %esi,%edx
  8014c1:	d3 ef                	shr    %cl,%edi
  8014c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014c7:	d3 e0                	shl    %cl,%eax
  8014c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014cd:	09 f8                	or     %edi,%eax
  8014cf:	d3 ea                	shr    %cl,%edx
  8014d1:	83 c4 20             	add    $0x20,%esp
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    
  8014d8:	39 d6                	cmp    %edx,%esi
  8014da:	75 d9                	jne    8014b5 <__umoddi3+0xf5>
  8014dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8014df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8014e2:	eb d1                	jmp    8014b5 <__umoddi3+0xf5>
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	39 f2                	cmp    %esi,%edx
  8014ea:	0f 82 18 ff ff ff    	jb     801408 <__umoddi3+0x48>
  8014f0:	e9 1d ff ff ff       	jmp    801412 <__umoddi3+0x52>
