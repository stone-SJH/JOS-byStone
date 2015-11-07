
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 f9 10 00 00       	call   801146 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 bd 11 00 00       	call   801216 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 1d                	jmp    800084 <umain+0x44>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 18                	je     800084 <umain+0x44>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	89 f0                	mov    %esi,%eax
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	05 54 00 c0 ee       	add    $0xeec00054,%eax
  80007c:	8b 00                	mov    (%eax),%eax
  80007e:	85 c0                	test   %eax,%eax
  800080:	75 13                	jne    800095 <umain+0x55>
  800082:	eb 24                	jmp    8000a8 <umain+0x68>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800084:	e8 3b 10 00 00       	call   8010c4 <sys_yield>
		return;
  800089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800090:	e9 95 00 00 00       	jmp    80012a <umain+0xea>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	89 f2                	mov    %esi,%edx
  800097:	c1 e2 07             	shl    $0x7,%edx
  80009a:	81 c2 54 00 c0 ee    	add    $0xeec00054,%edx
		asm volatile("pause");
  8000a0:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a2:	8b 02                	mov    (%edx),%eax
  8000a4:	85 c0                	test   %eax,%eax
  8000a6:	75 f8                	jne    8000a0 <umain+0x60>
  8000a8:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ad:	be 00 00 00 00       	mov    $0x0,%esi
  8000b2:	e8 0d 10 00 00       	call   8010c4 <sys_yield>
  8000b7:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000b9:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000bf:	83 c2 01             	add    $0x1,%edx
  8000c2:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c8:	83 c0 01             	add    $0x1,%eax
  8000cb:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000d0:	75 e7                	jne    8000b9 <umain+0x79>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000d2:	83 c3 01             	add    $0x1,%ebx
  8000d5:	83 fb 0a             	cmp    $0xa,%ebx
  8000d8:	75 d8                	jne    8000b2 <umain+0x72>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000da:	a1 04 20 80 00       	mov    0x802004,%eax
  8000df:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e4:	74 25                	je     80010b <umain+0xcb>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ef:	c7 44 24 08 c0 14 80 	movl   $0x8014c0,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 e8 14 80 00 	movl   $0x8014e8,(%esp)
  800106:	e8 8d 00 00 00       	call   800198 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  80010b:	a1 08 20 80 00       	mov    0x802008,%eax
  800110:	8b 50 5c             	mov    0x5c(%eax),%edx
  800113:	8b 40 48             	mov    0x48(%eax),%eax
  800116:	89 54 24 08          	mov    %edx,0x8(%esp)
  80011a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011e:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  800125:	e8 3f 01 00 00       	call   800269 <cprintf>

}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
  80013a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80013d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800140:	8b 75 08             	mov    0x8(%ebp),%esi
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800146:	e8 fb 0f 00 00       	call   801146 <sys_getenvid>
  80014b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800150:	c1 e0 07             	shl    $0x7,%eax
  800153:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800158:	a3 08 20 80 00       	mov    %eax,0x802008
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015d:	85 f6                	test   %esi,%esi
  80015f:	7e 07                	jle    800168 <libmain+0x34>
		binaryname = argv[0];
  800161:	8b 03                	mov    (%ebx),%eax
  800163:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800168:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80016c:	89 34 24             	mov    %esi,(%esp)
  80016f:	e8 cc fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800174:	e8 0b 00 00 00       	call   800184 <exit>
}
  800179:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80017c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80017f:	89 ec                	mov    %ebp,%esp
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    
	...

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80018a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800191:	e8 f0 0f 00 00       	call   801186 <sys_env_destroy>
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001a0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001a3:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	74 10                	je     8001bc <_panic+0x24>
		cprintf("%s: ", argv0);
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	c7 04 24 23 15 80 00 	movl   $0x801523,(%esp)
  8001b7:	e8 ad 00 00 00       	call   800269 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c2:	e8 7f 0f 00 00       	call   801146 <sys_getenvid>
  8001c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ca:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dd:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  8001e4:	e8 80 00 00 00       	call   800269 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 10 00 00 00       	call   800208 <vcprintf>
	cprintf("\n");
  8001f8:	c7 04 24 17 15 80 00 	movl   $0x801517,(%esp)
  8001ff:	e8 65 00 00 00       	call   800269 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800204:	cc                   	int3   
  800205:	eb fd                	jmp    800204 <_panic+0x6c>
	...

00800208 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800211:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800218:	00 00 00 
	b.cnt = 0;
  80021b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800222:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800225:	8b 45 0c             	mov    0xc(%ebp),%eax
  800228:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800233:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	c7 04 24 83 02 80 00 	movl   $0x800283,(%esp)
  800244:	e8 d4 01 00 00       	call   80041d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800249:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	e8 1b 0b 00 00       	call   800d7c <sys_cputs>

	return b.cnt;
}
  800261:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80026f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800272:	89 44 24 04          	mov    %eax,0x4(%esp)
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 04 24             	mov    %eax,(%esp)
  80027c:	e8 87 ff ff ff       	call   800208 <vcprintf>
	va_end(ap);

	return cnt;
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	53                   	push   %ebx
  800287:	83 ec 14             	sub    $0x14,%esp
  80028a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028d:	8b 03                	mov    (%ebx),%eax
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800296:	83 c0 01             	add    $0x1,%eax
  800299:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a0:	75 19                	jne    8002bb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002a2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a9:	00 
  8002aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	e8 c7 0a 00 00       	call   800d7c <sys_cputs>
		b->idx = 0;
  8002b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fb:	39 d1                	cmp    %edx,%ecx
  8002fd:	72 15                	jb     800314 <printnum+0x44>
  8002ff:	77 07                	ja     800308 <printnum+0x38>
  800301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800304:	39 d0                	cmp    %edx,%eax
  800306:	76 0c                	jbe    800314 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	83 eb 01             	sub    $0x1,%ebx
  80030b:	85 db                	test   %ebx,%ebx
  80030d:	8d 76 00             	lea    0x0(%esi),%esi
  800310:	7f 61                	jg     800373 <printnum+0xa3>
  800312:	eb 70                	jmp    800384 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800327:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80032b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80032e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800331:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800334:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033f:	00 
  800340:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	e8 ee 0e 00 00       	call   801240 <__udivdi3>
  800352:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800355:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	89 54 24 04          	mov    %edx,0x4(%esp)
  800367:	89 f2                	mov    %esi,%edx
  800369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036c:	e8 5f ff ff ff       	call   8002d0 <printnum>
  800371:	eb 11                	jmp    800384 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800373:	89 74 24 04          	mov    %esi,0x4(%esp)
  800377:	89 3c 24             	mov    %edi,(%esp)
  80037a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f ef                	jg     800373 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	89 74 24 04          	mov    %esi,0x4(%esp)
  800388:	8b 74 24 04          	mov    0x4(%esp),%esi
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039a:	00 
  80039b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80039e:	89 14 24             	mov    %edx,(%esp)
  8003a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003a8:	e8 c3 0f 00 00       	call   801370 <__umoddi3>
  8003ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b1:	0f be 80 4c 15 80 00 	movsbl 0x80154c(%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003be:	83 c4 4c             	add    $0x4c,%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c9:	83 fa 01             	cmp    $0x1,%edx
  8003cc:	7e 0e                	jle    8003dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	eb 22                	jmp    8003fe <getuint+0x38>
	else if (lflag)
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	74 10                	je     8003f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 0e                	jmp    8003fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800406:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	3b 50 04             	cmp    0x4(%eax),%edx
  80040f:	73 0a                	jae    80041b <sprintputch+0x1b>
		*b->buf++ = ch;
  800411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800414:	88 0a                	mov    %cl,(%edx)
  800416:	83 c2 01             	add    $0x1,%edx
  800419:	89 10                	mov    %edx,(%eax)
}
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	83 ec 5c             	sub    $0x5c,%esp
  800426:	8b 7d 08             	mov    0x8(%ebp),%edi
  800429:	8b 75 0c             	mov    0xc(%ebp),%esi
  80042c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800436:	eb 11                	jmp    800449 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800438:	85 c0                	test   %eax,%eax
  80043a:	0f 84 09 04 00 00    	je     800849 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800440:	89 74 24 04          	mov    %esi,0x4(%esp)
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 03             	movzbl (%ebx),%eax
  80044c:	83 c3 01             	add    $0x1,%ebx
  80044f:	83 f8 25             	cmp    $0x25,%eax
  800452:	75 e4                	jne    800438 <vprintfmt+0x1b>
  800454:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800458:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80045f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800466:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80046d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800472:	eb 06                	jmp    80047a <vprintfmt+0x5d>
  800474:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800478:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	0f b6 13             	movzbl (%ebx),%edx
  80047d:	0f b6 c2             	movzbl %dl,%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800483:	8d 43 01             	lea    0x1(%ebx),%eax
  800486:	83 ea 23             	sub    $0x23,%edx
  800489:	80 fa 55             	cmp    $0x55,%dl
  80048c:	0f 87 9a 03 00 00    	ja     80082c <vprintfmt+0x40f>
  800492:	0f b6 d2             	movzbl %dl,%edx
  800495:	ff 24 95 20 16 80 00 	jmp    *0x801620(,%edx,4)
  80049c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004a0:	eb d6                	jmp    800478 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a5:	83 ea 30             	sub    $0x30,%edx
  8004a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8004ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004b1:	83 fb 09             	cmp    $0x9,%ebx
  8004b4:	77 4c                	ja     800502 <vprintfmt+0xe5>
  8004b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004cc:	83 fb 09             	cmp    $0x9,%ebx
  8004cf:	76 eb                	jbe    8004bc <vprintfmt+0x9f>
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d7:	eb 29                	jmp    800502 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004e2:	8b 12                	mov    (%edx),%edx
  8004e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004e7:	eb 19                	jmp    800502 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8004e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ec:	c1 fa 1f             	sar    $0x1f,%edx
  8004ef:	f7 d2                	not    %edx
  8004f1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8004f4:	eb 82                	jmp    800478 <vprintfmt+0x5b>
  8004f6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004fd:	e9 76 ff ff ff       	jmp    800478 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800502:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800506:	0f 89 6c ff ff ff    	jns    800478 <vprintfmt+0x5b>
  80050c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80050f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800512:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800515:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800518:	e9 5b ff ff ff       	jmp    800478 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800520:	e9 53 ff ff ff       	jmp    800478 <vprintfmt+0x5b>
  800525:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	89 74 24 04          	mov    %esi,0x4(%esp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	ff d7                	call   *%edi
  80053c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80053f:	e9 05 ff ff ff       	jmp    800449 <vprintfmt+0x2c>
  800544:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 c2                	mov    %eax,%edx
  800554:	c1 fa 1f             	sar    $0x1f,%edx
  800557:	31 d0                	xor    %edx,%eax
  800559:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055b:	83 f8 08             	cmp    $0x8,%eax
  80055e:	7f 0b                	jg     80056b <vprintfmt+0x14e>
  800560:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  800567:	85 d2                	test   %edx,%edx
  800569:	75 20                	jne    80058b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80056b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056f:	c7 44 24 08 5d 15 80 	movl   $0x80155d,0x8(%esp)
  800576:	00 
  800577:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057b:	89 3c 24             	mov    %edi,(%esp)
  80057e:	e8 4e 03 00 00       	call   8008d1 <printfmt>
  800583:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	e9 be fe ff ff       	jmp    800449 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80058b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058f:	c7 44 24 08 66 15 80 	movl   $0x801566,0x8(%esp)
  800596:	00 
  800597:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059b:	89 3c 24             	mov    %edi,(%esp)
  80059e:	e8 2e 03 00 00       	call   8008d1 <printfmt>
  8005a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a6:	e9 9e fe ff ff       	jmp    800449 <vprintfmt+0x2c>
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	75 07                	jne    8005d2 <vprintfmt+0x1b5>
  8005cb:	c7 45 c4 69 15 80 00 	movl   $0x801569,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005d2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005d6:	7e 06                	jle    8005de <vprintfmt+0x1c1>
  8005d8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005dc:	75 13                	jne    8005f1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e1:	0f be 02             	movsbl (%edx),%eax
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	0f 85 99 00 00 00    	jne    800685 <vprintfmt+0x268>
  8005ec:	e9 86 00 00 00       	jmp    800677 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8005f8:	89 0c 24             	mov    %ecx,(%esp)
  8005fb:	e8 1b 03 00 00       	call   80091b <strnlen>
  800600:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800603:	29 c2                	sub    %eax,%edx
  800605:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800608:	85 d2                	test   %edx,%edx
  80060a:	7e d2                	jle    8005de <vprintfmt+0x1c1>
					putch(padc, putdat);
  80060c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800610:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800613:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800616:	89 d3                	mov    %edx,%ebx
  800618:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 eb 01             	sub    $0x1,%ebx
  800627:	85 db                	test   %ebx,%ebx
  800629:	7f ed                	jg     800618 <vprintfmt+0x1fb>
  80062b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80062e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800635:	eb a7                	jmp    8005de <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800637:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80063b:	74 18                	je     800655 <vprintfmt+0x238>
  80063d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800640:	83 fa 5e             	cmp    $0x5e,%edx
  800643:	76 10                	jbe    800655 <vprintfmt+0x238>
					putch('?', putdat);
  800645:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800649:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800650:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800653:	eb 0a                	jmp    80065f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800655:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800663:	0f be 03             	movsbl (%ebx),%eax
  800666:	85 c0                	test   %eax,%eax
  800668:	74 05                	je     80066f <vprintfmt+0x252>
  80066a:	83 c3 01             	add    $0x1,%ebx
  80066d:	eb 29                	jmp    800698 <vprintfmt+0x27b>
  80066f:	89 fe                	mov    %edi,%esi
  800671:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800674:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800677:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067b:	7f 2e                	jg     8006ab <vprintfmt+0x28e>
  80067d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800680:	e9 c4 fd ff ff       	jmp    800449 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800685:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800688:	83 c2 01             	add    $0x1,%edx
  80068b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80068e:	89 f7                	mov    %esi,%edi
  800690:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800693:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800696:	89 d3                	mov    %edx,%ebx
  800698:	85 f6                	test   %esi,%esi
  80069a:	78 9b                	js     800637 <vprintfmt+0x21a>
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	79 96                	jns    800637 <vprintfmt+0x21a>
  8006a1:	89 fe                	mov    %edi,%esi
  8006a3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006a6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006a9:	eb cc                	jmp    800677 <vprintfmt+0x25a>
  8006ab:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006be:	83 eb 01             	sub    $0x1,%ebx
  8006c1:	85 db                	test   %ebx,%ebx
  8006c3:	7f ec                	jg     8006b1 <vprintfmt+0x294>
  8006c5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c8:	e9 7c fd ff ff       	jmp    800449 <vprintfmt+0x2c>
  8006cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7e 16                	jle    8006eb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 08             	lea    0x8(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 10                	mov    (%eax),%edx
  8006e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006e6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e9:	eb 32                	jmp    80071d <vprintfmt+0x300>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	74 18                	je     800707 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006fd:	89 c1                	mov    %eax,%ecx
  8006ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800702:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800705:	eb 16                	jmp    80071d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800715:	89 c2                	mov    %eax,%edx
  800717:	c1 fa 1f             	sar    $0x1f,%edx
  80071a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800720:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800723:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800728:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072c:	0f 89 b8 00 00 00    	jns    8007ea <vprintfmt+0x3cd>
				putch('-', putdat);
  800732:	89 74 24 04          	mov    %esi,0x4(%esp)
  800736:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80073d:	ff d7                	call   *%edi
				num = -(long long) num;
  80073f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800742:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800745:	f7 d9                	neg    %ecx
  800747:	83 d3 00             	adc    $0x0,%ebx
  80074a:	f7 db                	neg    %ebx
  80074c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800751:	e9 94 00 00 00       	jmp    8007ea <vprintfmt+0x3cd>
  800756:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800759:	89 ca                	mov    %ecx,%edx
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 63 fc ff ff       	call   8003c6 <getuint>
  800763:	89 c1                	mov    %eax,%ecx
  800765:	89 d3                	mov    %edx,%ebx
  800767:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80076c:	eb 7c                	jmp    8007ea <vprintfmt+0x3cd>
  80076e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800771:	89 74 24 04          	mov    %esi,0x4(%esp)
  800775:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80077c:	ff d7                	call   *%edi
			putch('X', putdat);
  80077e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800782:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800789:	ff d7                	call   *%edi
			putch('X', putdat);
  80078b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800796:	ff d7                	call   *%edi
  800798:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80079b:	e9 a9 fc ff ff       	jmp    800449 <vprintfmt+0x2c>
  8007a0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ae:	ff d7                	call   *%edi
			putch('x', putdat);
  8007b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007bb:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 08                	mov    (%eax),%ecx
  8007c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007cd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007d2:	eb 16                	jmp    8007ea <vprintfmt+0x3cd>
  8007d4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d7:	89 ca                	mov    %ecx,%edx
  8007d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007dc:	e8 e5 fb ff ff       	call   8003c6 <getuint>
  8007e1:	89 c1                	mov    %eax,%ecx
  8007e3:	89 d3                	mov    %edx,%ebx
  8007e5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ea:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fd:	89 0c 24             	mov    %ecx,(%esp)
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	89 f2                	mov    %esi,%edx
  800806:	89 f8                	mov    %edi,%eax
  800808:	e8 c3 fa ff ff       	call   8002d0 <printnum>
  80080d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800810:	e9 34 fc ff ff       	jmp    800449 <vprintfmt+0x2c>
  800815:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800818:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081f:	89 14 24             	mov    %edx,(%esp)
  800822:	ff d7                	call   *%edi
  800824:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800827:	e9 1d fc ff ff       	jmp    800449 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800830:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800837:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800839:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80083c:	80 38 25             	cmpb   $0x25,(%eax)
  80083f:	0f 84 04 fc ff ff    	je     800449 <vprintfmt+0x2c>
  800845:	89 c3                	mov    %eax,%ebx
  800847:	eb f0                	jmp    800839 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800849:	83 c4 5c             	add    $0x5c,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 28             	sub    $0x28,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 04                	je     800865 <vsnprintf+0x14>
  800861:	85 d2                	test   %edx,%edx
  800863:	7f 07                	jg     80086c <vsnprintf+0x1b>
  800865:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086a:	eb 3b                	jmp    8008a7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800873:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800876:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800884:	8b 45 10             	mov    0x10(%ebp),%eax
  800887:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800892:	c7 04 24 00 04 80 00 	movl   $0x800400,(%esp)
  800899:	e8 7f fb ff ff       	call   80041d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 82 ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008de:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	e8 26 fb ff ff       	call   80041d <vprintfmt>
	va_end(ap);
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    
  8008f9:	00 00                	add    %al,(%eax)
  8008fb:	00 00                	add    %al,(%eax)
  8008fd:	00 00                	add    %al,(%eax)
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 09                	je     800919 <strlen+0x19>
		n++;
  800910:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800913:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800917:	75 f7                	jne    800910 <strlen+0x10>
		n++;
	return n;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 19                	je     800942 <strnlen+0x27>
  800929:	80 3b 00             	cmpb   $0x0,(%ebx)
  80092c:	74 14                	je     800942 <strnlen+0x27>
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800933:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800936:	39 c8                	cmp    %ecx,%eax
  800938:	74 0d                	je     800947 <strnlen+0x2c>
  80093a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80093e:	75 f3                	jne    800933 <strnlen+0x18>
  800940:	eb 05                	jmp    800947 <strnlen+0x2c>
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800959:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800960:	83 c2 01             	add    $0x1,%edx
  800963:	84 c9                	test   %cl,%cl
  800965:	75 f2                	jne    800959 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800974:	89 1c 24             	mov    %ebx,(%esp)
  800977:	e8 84 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800983:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800986:	89 04 24             	mov    %eax,(%esp)
  800989:	e8 bc ff ff ff       	call   80094a <strcpy>
	return dst;
}
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	83 c4 08             	add    $0x8,%esp
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	85 f6                	test   %esi,%esi
  8009a6:	74 18                	je     8009c0 <strncpy+0x2a>
  8009a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ad:	0f b6 1a             	movzbl (%edx),%ebx
  8009b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	39 ce                	cmp    %ecx,%esi
  8009be:	77 ed                	ja     8009ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d2:	89 f0                	mov    %esi,%eax
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	74 27                	je     8009ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009d8:	83 e9 01             	sub    $0x1,%ecx
  8009db:	74 1d                	je     8009fa <strlcpy+0x36>
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	84 db                	test   %bl,%bl
  8009e2:	74 16                	je     8009fa <strlcpy+0x36>
			*dst++ = *src++;
  8009e4:	88 18                	mov    %bl,(%eax)
  8009e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e9:	83 e9 01             	sub    $0x1,%ecx
  8009ec:	74 0e                	je     8009fc <strlcpy+0x38>
			*dst++ = *src++;
  8009ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f1:	0f b6 1a             	movzbl (%edx),%ebx
  8009f4:	84 db                	test   %bl,%bl
  8009f6:	75 ec                	jne    8009e4 <strlcpy+0x20>
  8009f8:	eb 02                	jmp    8009fc <strlcpy+0x38>
  8009fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fc:	c6 00 00             	movb   $0x0,(%eax)
  8009ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	84 c0                	test   %al,%al
  800a13:	74 15                	je     800a2a <strcmp+0x25>
  800a15:	3a 02                	cmp    (%edx),%al
  800a17:	75 11                	jne    800a2a <strcmp+0x25>
		p++, q++;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1f:	0f b6 01             	movzbl (%ecx),%eax
  800a22:	84 c0                	test   %al,%al
  800a24:	74 04                	je     800a2a <strcmp+0x25>
  800a26:	3a 02                	cmp    (%edx),%al
  800a28:	74 ef                	je     800a19 <strcmp+0x14>
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	0f b6 12             	movzbl (%edx),%edx
  800a30:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a41:	85 c0                	test   %eax,%eax
  800a43:	74 23                	je     800a68 <strncmp+0x34>
  800a45:	0f b6 1a             	movzbl (%edx),%ebx
  800a48:	84 db                	test   %bl,%bl
  800a4a:	74 25                	je     800a71 <strncmp+0x3d>
  800a4c:	3a 19                	cmp    (%ecx),%bl
  800a4e:	75 21                	jne    800a71 <strncmp+0x3d>
  800a50:	83 e8 01             	sub    $0x1,%eax
  800a53:	74 13                	je     800a68 <strncmp+0x34>
		n--, p++, q++;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5b:	0f b6 1a             	movzbl (%edx),%ebx
  800a5e:	84 db                	test   %bl,%bl
  800a60:	74 0f                	je     800a71 <strncmp+0x3d>
  800a62:	3a 19                	cmp    (%ecx),%bl
  800a64:	74 ea                	je     800a50 <strncmp+0x1c>
  800a66:	eb 09                	jmp    800a71 <strncmp+0x3d>
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	90                   	nop
  800a70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a71:	0f b6 02             	movzbl (%edx),%eax
  800a74:	0f b6 11             	movzbl (%ecx),%edx
  800a77:	29 d0                	sub    %edx,%eax
  800a79:	eb f2                	jmp    800a6d <strncmp+0x39>

00800a7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	0f b6 10             	movzbl (%eax),%edx
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	74 18                	je     800aa4 <strchr+0x29>
		if (*s == c)
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	75 0a                	jne    800a9a <strchr+0x1f>
  800a90:	eb 17                	jmp    800aa9 <strchr+0x2e>
  800a92:	38 ca                	cmp    %cl,%dl
  800a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a98:	74 0f                	je     800aa9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 ee                	jne    800a92 <strchr+0x17>
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	0f b6 10             	movzbl (%eax),%edx
  800ab8:	84 d2                	test   %dl,%dl
  800aba:	74 18                	je     800ad4 <strfind+0x29>
		if (*s == c)
  800abc:	38 ca                	cmp    %cl,%dl
  800abe:	75 0a                	jne    800aca <strfind+0x1f>
  800ac0:	eb 12                	jmp    800ad4 <strfind+0x29>
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ac8:	74 0a                	je     800ad4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	75 ee                	jne    800ac2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	89 1c 24             	mov    %ebx,(%esp)
  800adf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af0:	85 c9                	test   %ecx,%ecx
  800af2:	74 30                	je     800b24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afa:	75 25                	jne    800b21 <memset+0x4b>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 20                	jne    800b21 <memset+0x4b>
		c &= 0xFF;
  800b01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	c1 e3 08             	shl    $0x8,%ebx
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	c1 e6 18             	shl    $0x18,%esi
  800b0e:	89 d0                	mov    %edx,%eax
  800b10:	c1 e0 10             	shl    $0x10,%eax
  800b13:	09 f0                	or     %esi,%eax
  800b15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b17:	09 d8                	or     %ebx,%eax
  800b19:	c1 e9 02             	shr    $0x2,%ecx
  800b1c:	fc                   	cld    
  800b1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1f:	eb 03                	jmp    800b24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b21:	fc                   	cld    
  800b22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	8b 1c 24             	mov    (%esp),%ebx
  800b29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b31:	89 ec                	mov    %ebp,%esp
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	89 34 24             	mov    %esi,(%esp)
  800b3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b4d:	39 c6                	cmp    %eax,%esi
  800b4f:	73 35                	jae    800b86 <memmove+0x51>
  800b51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b54:	39 d0                	cmp    %edx,%eax
  800b56:	73 2e                	jae    800b86 <memmove+0x51>
		s += n;
		d += n;
  800b58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5a:	f6 c2 03             	test   $0x3,%dl
  800b5d:	75 1b                	jne    800b7a <memmove+0x45>
  800b5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b65:	75 13                	jne    800b7a <memmove+0x45>
  800b67:	f6 c1 03             	test   $0x3,%cl
  800b6a:	75 0e                	jne    800b7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b6c:	83 ef 04             	sub    $0x4,%edi
  800b6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b72:	c1 e9 02             	shr    $0x2,%ecx
  800b75:	fd                   	std    
  800b76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	eb 09                	jmp    800b83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7a:	83 ef 01             	sub    $0x1,%edi
  800b7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b80:	fd                   	std    
  800b81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b84:	eb 20                	jmp    800ba6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8c:	75 15                	jne    800ba3 <memmove+0x6e>
  800b8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b94:	75 0d                	jne    800ba3 <memmove+0x6e>
  800b96:	f6 c1 03             	test   $0x3,%cl
  800b99:	75 08                	jne    800ba3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b9b:	c1 e9 02             	shr    $0x2,%ecx
  800b9e:	fc                   	cld    
  800b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba1:	eb 03                	jmp    800ba6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba3:	fc                   	cld    
  800ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba6:	8b 34 24             	mov    (%esp),%esi
  800ba9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bad:	89 ec                	mov    %ebp,%esp
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	89 04 24             	mov    %eax,(%esp)
  800bcb:	e8 65 ff ff ff       	call   800b35 <memmove>
}
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be1:	85 c9                	test   %ecx,%ecx
  800be3:	74 36                	je     800c1b <memcmp+0x49>
		if (*s1 != *s2)
  800be5:	0f b6 06             	movzbl (%esi),%eax
  800be8:	0f b6 1f             	movzbl (%edi),%ebx
  800beb:	38 d8                	cmp    %bl,%al
  800bed:	74 20                	je     800c0f <memcmp+0x3d>
  800bef:	eb 14                	jmp    800c05 <memcmp+0x33>
  800bf1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bf6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bfb:	83 c2 01             	add    $0x1,%edx
  800bfe:	83 e9 01             	sub    $0x1,%ecx
  800c01:	38 d8                	cmp    %bl,%al
  800c03:	74 12                	je     800c17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c05:	0f b6 c0             	movzbl %al,%eax
  800c08:	0f b6 db             	movzbl %bl,%ebx
  800c0b:	29 d8                	sub    %ebx,%eax
  800c0d:	eb 11                	jmp    800c20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0f:	83 e9 01             	sub    $0x1,%ecx
  800c12:	ba 00 00 00 00       	mov    $0x0,%edx
  800c17:	85 c9                	test   %ecx,%ecx
  800c19:	75 d6                	jne    800bf1 <memcmp+0x1f>
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c30:	39 d0                	cmp    %edx,%eax
  800c32:	73 15                	jae    800c49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c38:	38 08                	cmp    %cl,(%eax)
  800c3a:	75 06                	jne    800c42 <memfind+0x1d>
  800c3c:	eb 0b                	jmp    800c49 <memfind+0x24>
  800c3e:	38 08                	cmp    %cl,(%eax)
  800c40:	74 07                	je     800c49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c42:	83 c0 01             	add    $0x1,%eax
  800c45:	39 c2                	cmp    %eax,%edx
  800c47:	77 f5                	ja     800c3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 04             	sub    $0x4,%esp
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5a:	0f b6 02             	movzbl (%edx),%eax
  800c5d:	3c 20                	cmp    $0x20,%al
  800c5f:	74 04                	je     800c65 <strtol+0x1a>
  800c61:	3c 09                	cmp    $0x9,%al
  800c63:	75 0e                	jne    800c73 <strtol+0x28>
		s++;
  800c65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c68:	0f b6 02             	movzbl (%edx),%eax
  800c6b:	3c 20                	cmp    $0x20,%al
  800c6d:	74 f6                	je     800c65 <strtol+0x1a>
  800c6f:	3c 09                	cmp    $0x9,%al
  800c71:	74 f2                	je     800c65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c73:	3c 2b                	cmp    $0x2b,%al
  800c75:	75 0c                	jne    800c83 <strtol+0x38>
		s++;
  800c77:	83 c2 01             	add    $0x1,%edx
  800c7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c81:	eb 15                	jmp    800c98 <strtol+0x4d>
	else if (*s == '-')
  800c83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c8a:	3c 2d                	cmp    $0x2d,%al
  800c8c:	75 0a                	jne    800c98 <strtol+0x4d>
		s++, neg = 1;
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c98:	85 db                	test   %ebx,%ebx
  800c9a:	0f 94 c0             	sete   %al
  800c9d:	74 05                	je     800ca4 <strtol+0x59>
  800c9f:	83 fb 10             	cmp    $0x10,%ebx
  800ca2:	75 18                	jne    800cbc <strtol+0x71>
  800ca4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ca7:	75 13                	jne    800cbc <strtol+0x71>
  800ca9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cad:	8d 76 00             	lea    0x0(%esi),%esi
  800cb0:	75 0a                	jne    800cbc <strtol+0x71>
		s += 2, base = 16;
  800cb2:	83 c2 02             	add    $0x2,%edx
  800cb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cba:	eb 15                	jmp    800cd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cbc:	84 c0                	test   %al,%al
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	74 0f                	je     800cd1 <strtol+0x86>
  800cc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cc7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cca:	75 05                	jne    800cd1 <strtol+0x86>
		s++, base = 8;
  800ccc:	83 c2 01             	add    $0x1,%edx
  800ccf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd8:	0f b6 0a             	movzbl (%edx),%ecx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ce0:	80 fb 09             	cmp    $0x9,%bl
  800ce3:	77 08                	ja     800ced <strtol+0xa2>
			dig = *s - '0';
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 30             	sub    $0x30,%ecx
  800ceb:	eb 1e                	jmp    800d0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ced:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cf0:	80 fb 19             	cmp    $0x19,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 57             	sub    $0x57,%ecx
  800cfb:	eb 0e                	jmp    800d0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 15                	ja     800d1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d0b:	39 f1                	cmp    %esi,%ecx
  800d0d:	7d 0b                	jge    800d1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d0f:	83 c2 01             	add    $0x1,%edx
  800d12:	0f af c6             	imul   %esi,%eax
  800d15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d18:	eb be                	jmp    800cd8 <strtol+0x8d>
  800d1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d20:	74 05                	je     800d27 <strtol+0xdc>
		*endptr = (char *) s;
  800d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d2b:	74 04                	je     800d31 <strtol+0xe6>
  800d2d:	89 c8                	mov    %ecx,%eax
  800d2f:	f7 d8                	neg    %eax
}
  800d31:	83 c4 04             	add    $0x4,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
  800d39:	00 00                	add    %al,(%eax)
	...

00800d3c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 08             	sub    $0x8,%esp
  800d42:	89 1c 24             	mov    %ebx,(%esp)
  800d45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d49:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d53:	89 d1                	mov    %edx,%ecx
  800d55:	89 d3                	mov    %edx,%ebx
  800d57:	89 d7                	mov    %edx,%edi
  800d59:	51                   	push   %ecx
  800d5a:	52                   	push   %edx
  800d5b:	53                   	push   %ebx
  800d5c:	54                   	push   %esp
  800d5d:	55                   	push   %ebp
  800d5e:	56                   	push   %esi
  800d5f:	57                   	push   %edi
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	8d 35 6a 0d 80 00    	lea    0x800d6a,%esi
  800d68:	0f 34                	sysenter 
  800d6a:	5f                   	pop    %edi
  800d6b:	5e                   	pop    %esi
  800d6c:	5d                   	pop    %ebp
  800d6d:	5c                   	pop    %esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5a                   	pop    %edx
  800d70:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d71:	8b 1c 24             	mov    (%esp),%ebx
  800d74:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
  800d82:	89 1c 24             	mov    %ebx,(%esp)
  800d85:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	89 c7                	mov    %eax,%edi
  800d98:	51                   	push   %ecx
  800d99:	52                   	push   %edx
  800d9a:	53                   	push   %ebx
  800d9b:	54                   	push   %esp
  800d9c:	55                   	push   %ebp
  800d9d:	56                   	push   %esi
  800d9e:	57                   	push   %edi
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	8d 35 a9 0d 80 00    	lea    0x800da9,%esi
  800da7:	0f 34                	sysenter 
  800da9:	5f                   	pop    %edi
  800daa:	5e                   	pop    %esi
  800dab:	5d                   	pop    %ebp
  800dac:	5c                   	pop    %esp
  800dad:	5b                   	pop    %ebx
  800dae:	5a                   	pop    %edx
  800daf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800db0:	8b 1c 24             	mov    (%esp),%ebx
  800db3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800db7:	89 ec                	mov    %ebp,%esp
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	83 ec 08             	sub    $0x8,%esp
  800dc1:	89 1c 24             	mov    %ebx,(%esp)
  800dc4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 cb                	mov    %ecx,%ebx
  800dd7:	89 cf                	mov    %ecx,%edi
  800dd9:	51                   	push   %ecx
  800dda:	52                   	push   %edx
  800ddb:	53                   	push   %ebx
  800ddc:	54                   	push   %esp
  800ddd:	55                   	push   %ebp
  800dde:	56                   	push   %esi
  800ddf:	57                   	push   %edi
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	8d 35 ea 0d 80 00    	lea    0x800dea,%esi
  800de8:	0f 34                	sysenter 
  800dea:	5f                   	pop    %edi
  800deb:	5e                   	pop    %esi
  800dec:	5d                   	pop    %ebp
  800ded:	5c                   	pop    %esp
  800dee:	5b                   	pop    %ebx
  800def:	5a                   	pop    %edx
  800df0:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800df1:	8b 1c 24             	mov    (%esp),%ebx
  800df4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 28             	sub    $0x28,%esp
  800e02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e05:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 cb                	mov    %ecx,%ebx
  800e17:	89 cf                	mov    %ecx,%edi
  800e19:	51                   	push   %ecx
  800e1a:	52                   	push   %edx
  800e1b:	53                   	push   %ebx
  800e1c:	54                   	push   %esp
  800e1d:	55                   	push   %ebp
  800e1e:	56                   	push   %esi
  800e1f:	57                   	push   %edi
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	8d 35 2a 0e 80 00    	lea    0x800e2a,%esi
  800e28:	0f 34                	sysenter 
  800e2a:	5f                   	pop    %edi
  800e2b:	5e                   	pop    %esi
  800e2c:	5d                   	pop    %ebp
  800e2d:	5c                   	pop    %esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5a                   	pop    %edx
  800e30:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800e58:	e8 3b f3 ff ff       	call   800198 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e63:	89 ec                	mov    %ebp,%esp
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	89 1c 24             	mov    %ebx,(%esp)
  800e70:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e74:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	51                   	push   %ecx
  800e86:	52                   	push   %edx
  800e87:	53                   	push   %ebx
  800e88:	54                   	push   %esp
  800e89:	55                   	push   %ebp
  800e8a:	56                   	push   %esi
  800e8b:	57                   	push   %edi
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	8d 35 96 0e 80 00    	lea    0x800e96,%esi
  800e94:	0f 34                	sysenter 
  800e96:	5f                   	pop    %edi
  800e97:	5e                   	pop    %esi
  800e98:	5d                   	pop    %ebp
  800e99:	5c                   	pop    %esp
  800e9a:	5b                   	pop    %ebx
  800e9b:	5a                   	pop    %edx
  800e9c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9d:	8b 1c 24             	mov    (%esp),%ebx
  800ea0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ea4:	89 ec                	mov    %ebp,%esp
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	83 ec 28             	sub    $0x28,%esp
  800eae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800eb1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 df                	mov    %ebx,%edi
  800ec6:	51                   	push   %ecx
  800ec7:	52                   	push   %edx
  800ec8:	53                   	push   %ebx
  800ec9:	54                   	push   %esp
  800eca:	55                   	push   %ebp
  800ecb:	56                   	push   %esi
  800ecc:	57                   	push   %edi
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	8d 35 d7 0e 80 00    	lea    0x800ed7,%esi
  800ed5:	0f 34                	sysenter 
  800ed7:	5f                   	pop    %edi
  800ed8:	5e                   	pop    %esi
  800ed9:	5d                   	pop    %ebp
  800eda:	5c                   	pop    %esp
  800edb:	5b                   	pop    %ebx
  800edc:	5a                   	pop    %edx
  800edd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	7e 28                	jle    800f0a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eed:	00 
  800eee:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800f05:	e8 8e f2 ff ff       	call   800198 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f10:	89 ec                	mov    %ebp,%esp
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 28             	sub    $0x28,%esp
  800f1a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f1d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f25:	b8 09 00 00 00       	mov    $0x9,%eax
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	89 df                	mov    %ebx,%edi
  800f32:	51                   	push   %ecx
  800f33:	52                   	push   %edx
  800f34:	53                   	push   %ebx
  800f35:	54                   	push   %esp
  800f36:	55                   	push   %ebp
  800f37:	56                   	push   %esi
  800f38:	57                   	push   %edi
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	8d 35 43 0f 80 00    	lea    0x800f43,%esi
  800f41:	0f 34                	sysenter 
  800f43:	5f                   	pop    %edi
  800f44:	5e                   	pop    %esi
  800f45:	5d                   	pop    %ebp
  800f46:	5c                   	pop    %esp
  800f47:	5b                   	pop    %ebx
  800f48:	5a                   	pop    %edx
  800f49:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	7e 28                	jle    800f76 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f52:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800f71:	e8 22 f2 ff ff       	call   800198 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f76:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f79:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7c:	89 ec                	mov    %ebp,%esp
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 28             	sub    $0x28,%esp
  800f86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f89:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f91:	b8 07 00 00 00       	mov    $0x7,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	89 df                	mov    %ebx,%edi
  800f9e:	51                   	push   %ecx
  800f9f:	52                   	push   %edx
  800fa0:	53                   	push   %ebx
  800fa1:	54                   	push   %esp
  800fa2:	55                   	push   %ebp
  800fa3:	56                   	push   %esi
  800fa4:	57                   	push   %edi
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	8d 35 af 0f 80 00    	lea    0x800faf,%esi
  800fad:	0f 34                	sysenter 
  800faf:	5f                   	pop    %edi
  800fb0:	5e                   	pop    %esi
  800fb1:	5d                   	pop    %ebp
  800fb2:	5c                   	pop    %esp
  800fb3:	5b                   	pop    %ebx
  800fb4:	5a                   	pop    %edx
  800fb5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	7e 28                	jle    800fe2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbe:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800fcd:	00 
  800fce:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fd5:	00 
  800fd6:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800fdd:	e8 b6 f1 ff ff       	call   800198 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fe2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fe5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 28             	sub    $0x28,%esp
  800ff2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ff5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ffd:	8b 7d 14             	mov    0x14(%ebp),%edi
  801000:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	51                   	push   %ecx
  80100a:	52                   	push   %edx
  80100b:	53                   	push   %ebx
  80100c:	54                   	push   %esp
  80100d:	55                   	push   %ebp
  80100e:	56                   	push   %esi
  80100f:	57                   	push   %edi
  801010:	89 e5                	mov    %esp,%ebp
  801012:	8d 35 1a 10 80 00    	lea    0x80101a,%esi
  801018:	0f 34                	sysenter 
  80101a:	5f                   	pop    %edi
  80101b:	5e                   	pop    %esi
  80101c:	5d                   	pop    %ebp
  80101d:	5c                   	pop    %esp
  80101e:	5b                   	pop    %ebx
  80101f:	5a                   	pop    %edx
  801020:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801021:	85 c0                	test   %eax,%eax
  801023:	7e 28                	jle    80104d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801025:	89 44 24 10          	mov    %eax,0x10(%esp)
  801029:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801030:	00 
  801031:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  801048:	e8 4b f1 ff ff       	call   800198 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80104d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801050:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801053:	89 ec                	mov    %ebp,%esp
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 28             	sub    $0x28,%esp
  80105d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801060:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801063:	bf 00 00 00 00       	mov    $0x0,%edi
  801068:	b8 05 00 00 00       	mov    $0x5,%eax
  80106d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801070:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801073:	8b 55 08             	mov    0x8(%ebp),%edx
  801076:	51                   	push   %ecx
  801077:	52                   	push   %edx
  801078:	53                   	push   %ebx
  801079:	54                   	push   %esp
  80107a:	55                   	push   %ebp
  80107b:	56                   	push   %esi
  80107c:	57                   	push   %edi
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	8d 35 87 10 80 00    	lea    0x801087,%esi
  801085:	0f 34                	sysenter 
  801087:	5f                   	pop    %edi
  801088:	5e                   	pop    %esi
  801089:	5d                   	pop    %ebp
  80108a:	5c                   	pop    %esp
  80108b:	5b                   	pop    %ebx
  80108c:	5a                   	pop    %edx
  80108d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80108e:	85 c0                	test   %eax,%eax
  801090:	7e 28                	jle    8010ba <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801092:	89 44 24 10          	mov    %eax,0x10(%esp)
  801096:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80109d:	00 
  80109e:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  8010b5:	e8 de f0 ff ff       	call   800198 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010ba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c0:	89 ec                	mov    %ebp,%esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	89 1c 24             	mov    %ebx,(%esp)
  8010cd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010db:	89 d1                	mov    %edx,%ecx
  8010dd:	89 d3                	mov    %edx,%ebx
  8010df:	89 d7                	mov    %edx,%edi
  8010e1:	51                   	push   %ecx
  8010e2:	52                   	push   %edx
  8010e3:	53                   	push   %ebx
  8010e4:	54                   	push   %esp
  8010e5:	55                   	push   %ebp
  8010e6:	56                   	push   %esi
  8010e7:	57                   	push   %edi
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	8d 35 f2 10 80 00    	lea    0x8010f2,%esi
  8010f0:	0f 34                	sysenter 
  8010f2:	5f                   	pop    %edi
  8010f3:	5e                   	pop    %esi
  8010f4:	5d                   	pop    %ebp
  8010f5:	5c                   	pop    %esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5a                   	pop    %edx
  8010f8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010f9:	8b 1c 24             	mov    (%esp),%ebx
  8010fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801100:	89 ec                	mov    %ebp,%esp
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	89 1c 24             	mov    %ebx,(%esp)
  80110d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801111:	bb 00 00 00 00       	mov    $0x0,%ebx
  801116:	b8 04 00 00 00       	mov    $0x4,%eax
  80111b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111e:	8b 55 08             	mov    0x8(%ebp),%edx
  801121:	89 df                	mov    %ebx,%edi
  801123:	51                   	push   %ecx
  801124:	52                   	push   %edx
  801125:	53                   	push   %ebx
  801126:	54                   	push   %esp
  801127:	55                   	push   %ebp
  801128:	56                   	push   %esi
  801129:	57                   	push   %edi
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	8d 35 34 11 80 00    	lea    0x801134,%esi
  801132:	0f 34                	sysenter 
  801134:	5f                   	pop    %edi
  801135:	5e                   	pop    %esi
  801136:	5d                   	pop    %ebp
  801137:	5c                   	pop    %esp
  801138:	5b                   	pop    %ebx
  801139:	5a                   	pop    %edx
  80113a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80113b:	8b 1c 24             	mov    (%esp),%ebx
  80113e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801142:	89 ec                	mov    %ebp,%esp
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	89 1c 24             	mov    %ebx,(%esp)
  80114f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801153:	ba 00 00 00 00       	mov    $0x0,%edx
  801158:	b8 02 00 00 00       	mov    $0x2,%eax
  80115d:	89 d1                	mov    %edx,%ecx
  80115f:	89 d3                	mov    %edx,%ebx
  801161:	89 d7                	mov    %edx,%edi
  801163:	51                   	push   %ecx
  801164:	52                   	push   %edx
  801165:	53                   	push   %ebx
  801166:	54                   	push   %esp
  801167:	55                   	push   %ebp
  801168:	56                   	push   %esi
  801169:	57                   	push   %edi
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	8d 35 74 11 80 00    	lea    0x801174,%esi
  801172:	0f 34                	sysenter 
  801174:	5f                   	pop    %edi
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	5c                   	pop    %esp
  801178:	5b                   	pop    %ebx
  801179:	5a                   	pop    %edx
  80117a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80117b:	8b 1c 24             	mov    (%esp),%ebx
  80117e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801182:	89 ec                	mov    %ebp,%esp
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 28             	sub    $0x28,%esp
  80118c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80118f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801192:	b9 00 00 00 00       	mov    $0x0,%ecx
  801197:	b8 03 00 00 00       	mov    $0x3,%eax
  80119c:	8b 55 08             	mov    0x8(%ebp),%edx
  80119f:	89 cb                	mov    %ecx,%ebx
  8011a1:	89 cf                	mov    %ecx,%edi
  8011a3:	51                   	push   %ecx
  8011a4:	52                   	push   %edx
  8011a5:	53                   	push   %ebx
  8011a6:	54                   	push   %esp
  8011a7:	55                   	push   %ebp
  8011a8:	56                   	push   %esi
  8011a9:	57                   	push   %edi
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	8d 35 b4 11 80 00    	lea    0x8011b4,%esi
  8011b2:	0f 34                	sysenter 
  8011b4:	5f                   	pop    %edi
  8011b5:	5e                   	pop    %esi
  8011b6:	5d                   	pop    %ebp
  8011b7:	5c                   	pop    %esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5a                   	pop    %edx
  8011ba:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	7e 28                	jle    8011e7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8011da:	00 
  8011db:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  8011e2:	e8 b1 ef ff ff       	call   800198 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011e7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ed:	89 ec                	mov    %ebp,%esp
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    
  8011f1:	00 00                	add    %al,(%eax)
	...

008011f4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011fa:	c7 44 24 08 cf 17 80 	movl   $0x8017cf,0x8(%esp)
  801201:	00 
  801202:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801209:	00 
  80120a:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  801211:	e8 82 ef ff ff       	call   800198 <_panic>

00801216 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80121c:	c7 44 24 08 d0 17 80 	movl   $0x8017d0,0x8(%esp)
  801223:	00 
  801224:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80122b:	00 
  80122c:	c7 04 24 e5 17 80 00 	movl   $0x8017e5,(%esp)
  801233:	e8 60 ef ff ff       	call   800198 <_panic>
	...

00801240 <__udivdi3>:
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	83 ec 10             	sub    $0x10,%esp
  801248:	8b 45 14             	mov    0x14(%ebp),%eax
  80124b:	8b 55 08             	mov    0x8(%ebp),%edx
  80124e:	8b 75 10             	mov    0x10(%ebp),%esi
  801251:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801254:	85 c0                	test   %eax,%eax
  801256:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801259:	75 35                	jne    801290 <__udivdi3+0x50>
  80125b:	39 fe                	cmp    %edi,%esi
  80125d:	77 61                	ja     8012c0 <__udivdi3+0x80>
  80125f:	85 f6                	test   %esi,%esi
  801261:	75 0b                	jne    80126e <__udivdi3+0x2e>
  801263:	b8 01 00 00 00       	mov    $0x1,%eax
  801268:	31 d2                	xor    %edx,%edx
  80126a:	f7 f6                	div    %esi
  80126c:	89 c6                	mov    %eax,%esi
  80126e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801271:	31 d2                	xor    %edx,%edx
  801273:	89 f8                	mov    %edi,%eax
  801275:	f7 f6                	div    %esi
  801277:	89 c7                	mov    %eax,%edi
  801279:	89 c8                	mov    %ecx,%eax
  80127b:	f7 f6                	div    %esi
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	89 fa                	mov    %edi,%edx
  801281:	89 c8                	mov    %ecx,%eax
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    
  80128a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801290:	39 f8                	cmp    %edi,%eax
  801292:	77 1c                	ja     8012b0 <__udivdi3+0x70>
  801294:	0f bd d0             	bsr    %eax,%edx
  801297:	83 f2 1f             	xor    $0x1f,%edx
  80129a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80129d:	75 39                	jne    8012d8 <__udivdi3+0x98>
  80129f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8012a2:	0f 86 a0 00 00 00    	jbe    801348 <__udivdi3+0x108>
  8012a8:	39 f8                	cmp    %edi,%eax
  8012aa:	0f 82 98 00 00 00    	jb     801348 <__udivdi3+0x108>
  8012b0:	31 ff                	xor    %edi,%edi
  8012b2:	31 c9                	xor    %ecx,%ecx
  8012b4:	89 c8                	mov    %ecx,%eax
  8012b6:	89 fa                	mov    %edi,%edx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	5e                   	pop    %esi
  8012bc:	5f                   	pop    %edi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    
  8012bf:	90                   	nop
  8012c0:	89 d1                	mov    %edx,%ecx
  8012c2:	89 fa                	mov    %edi,%edx
  8012c4:	89 c8                	mov    %ecx,%eax
  8012c6:	31 ff                	xor    %edi,%edi
  8012c8:	f7 f6                	div    %esi
  8012ca:	89 c1                	mov    %eax,%ecx
  8012cc:	89 fa                	mov    %edi,%edx
  8012ce:	89 c8                	mov    %ecx,%eax
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	5e                   	pop    %esi
  8012d4:	5f                   	pop    %edi
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    
  8012d7:	90                   	nop
  8012d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012dc:	89 f2                	mov    %esi,%edx
  8012de:	d3 e0                	shl    %cl,%eax
  8012e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8012e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8012eb:	89 c1                	mov    %eax,%ecx
  8012ed:	d3 ea                	shr    %cl,%edx
  8012ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8012f6:	d3 e6                	shl    %cl,%esi
  8012f8:	89 c1                	mov    %eax,%ecx
  8012fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8012fd:	89 fe                	mov    %edi,%esi
  8012ff:	d3 ee                	shr    %cl,%esi
  801301:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801305:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801308:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80130b:	d3 e7                	shl    %cl,%edi
  80130d:	89 c1                	mov    %eax,%ecx
  80130f:	d3 ea                	shr    %cl,%edx
  801311:	09 d7                	or     %edx,%edi
  801313:	89 f2                	mov    %esi,%edx
  801315:	89 f8                	mov    %edi,%eax
  801317:	f7 75 ec             	divl   -0x14(%ebp)
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	f7 65 e8             	mull   -0x18(%ebp)
  801321:	39 d6                	cmp    %edx,%esi
  801323:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801326:	72 30                	jb     801358 <__udivdi3+0x118>
  801328:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80132b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80132f:	d3 e2                	shl    %cl,%edx
  801331:	39 c2                	cmp    %eax,%edx
  801333:	73 05                	jae    80133a <__udivdi3+0xfa>
  801335:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801338:	74 1e                	je     801358 <__udivdi3+0x118>
  80133a:	89 f9                	mov    %edi,%ecx
  80133c:	31 ff                	xor    %edi,%edi
  80133e:	e9 71 ff ff ff       	jmp    8012b4 <__udivdi3+0x74>
  801343:	90                   	nop
  801344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801348:	31 ff                	xor    %edi,%edi
  80134a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80134f:	e9 60 ff ff ff       	jmp    8012b4 <__udivdi3+0x74>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80135b:	31 ff                	xor    %edi,%edi
  80135d:	89 c8                	mov    %ecx,%eax
  80135f:	89 fa                	mov    %edi,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	5e                   	pop    %esi
  801365:	5f                   	pop    %edi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    
	...

00801370 <__umoddi3>:
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	57                   	push   %edi
  801374:	56                   	push   %esi
  801375:	83 ec 20             	sub    $0x20,%esp
  801378:	8b 55 14             	mov    0x14(%ebp),%edx
  80137b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801381:	8b 75 0c             	mov    0xc(%ebp),%esi
  801384:	85 d2                	test   %edx,%edx
  801386:	89 c8                	mov    %ecx,%eax
  801388:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80138b:	75 13                	jne    8013a0 <__umoddi3+0x30>
  80138d:	39 f7                	cmp    %esi,%edi
  80138f:	76 3f                	jbe    8013d0 <__umoddi3+0x60>
  801391:	89 f2                	mov    %esi,%edx
  801393:	f7 f7                	div    %edi
  801395:	89 d0                	mov    %edx,%eax
  801397:	31 d2                	xor    %edx,%edx
  801399:	83 c4 20             	add    $0x20,%esp
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    
  8013a0:	39 f2                	cmp    %esi,%edx
  8013a2:	77 4c                	ja     8013f0 <__umoddi3+0x80>
  8013a4:	0f bd ca             	bsr    %edx,%ecx
  8013a7:	83 f1 1f             	xor    $0x1f,%ecx
  8013aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013ad:	75 51                	jne    801400 <__umoddi3+0x90>
  8013af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8013b2:	0f 87 e0 00 00 00    	ja     801498 <__umoddi3+0x128>
  8013b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bb:	29 f8                	sub    %edi,%eax
  8013bd:	19 d6                	sbb    %edx,%esi
  8013bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c5:	89 f2                	mov    %esi,%edx
  8013c7:	83 c4 20             	add    $0x20,%esp
  8013ca:	5e                   	pop    %esi
  8013cb:	5f                   	pop    %edi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    
  8013ce:	66 90                	xchg   %ax,%ax
  8013d0:	85 ff                	test   %edi,%edi
  8013d2:	75 0b                	jne    8013df <__umoddi3+0x6f>
  8013d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d9:	31 d2                	xor    %edx,%edx
  8013db:	f7 f7                	div    %edi
  8013dd:	89 c7                	mov    %eax,%edi
  8013df:	89 f0                	mov    %esi,%eax
  8013e1:	31 d2                	xor    %edx,%edx
  8013e3:	f7 f7                	div    %edi
  8013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e8:	f7 f7                	div    %edi
  8013ea:	eb a9                	jmp    801395 <__umoddi3+0x25>
  8013ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	89 c8                	mov    %ecx,%eax
  8013f2:	89 f2                	mov    %esi,%edx
  8013f4:	83 c4 20             	add    $0x20,%esp
  8013f7:	5e                   	pop    %esi
  8013f8:	5f                   	pop    %edi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    
  8013fb:	90                   	nop
  8013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801400:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801404:	d3 e2                	shl    %cl,%edx
  801406:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801409:	ba 20 00 00 00       	mov    $0x20,%edx
  80140e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801411:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801414:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801418:	89 fa                	mov    %edi,%edx
  80141a:	d3 ea                	shr    %cl,%edx
  80141c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801420:	0b 55 f4             	or     -0xc(%ebp),%edx
  801423:	d3 e7                	shl    %cl,%edi
  801425:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801429:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80142c:	89 f2                	mov    %esi,%edx
  80142e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801431:	89 c7                	mov    %eax,%edi
  801433:	d3 ea                	shr    %cl,%edx
  801435:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801439:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	d3 e6                	shl    %cl,%esi
  801440:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801444:	d3 ea                	shr    %cl,%edx
  801446:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80144a:	09 d6                	or     %edx,%esi
  80144c:	89 f0                	mov    %esi,%eax
  80144e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801451:	d3 e7                	shl    %cl,%edi
  801453:	89 f2                	mov    %esi,%edx
  801455:	f7 75 f4             	divl   -0xc(%ebp)
  801458:	89 d6                	mov    %edx,%esi
  80145a:	f7 65 e8             	mull   -0x18(%ebp)
  80145d:	39 d6                	cmp    %edx,%esi
  80145f:	72 2b                	jb     80148c <__umoddi3+0x11c>
  801461:	39 c7                	cmp    %eax,%edi
  801463:	72 23                	jb     801488 <__umoddi3+0x118>
  801465:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801469:	29 c7                	sub    %eax,%edi
  80146b:	19 d6                	sbb    %edx,%esi
  80146d:	89 f0                	mov    %esi,%eax
  80146f:	89 f2                	mov    %esi,%edx
  801471:	d3 ef                	shr    %cl,%edi
  801473:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801477:	d3 e0                	shl    %cl,%eax
  801479:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80147d:	09 f8                	or     %edi,%eax
  80147f:	d3 ea                	shr    %cl,%edx
  801481:	83 c4 20             	add    $0x20,%esp
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    
  801488:	39 d6                	cmp    %edx,%esi
  80148a:	75 d9                	jne    801465 <__umoddi3+0xf5>
  80148c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80148f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801492:	eb d1                	jmp    801465 <__umoddi3+0xf5>
  801494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801498:	39 f2                	cmp    %esi,%edx
  80149a:	0f 82 18 ff ff ff    	jb     8013b8 <__umoddi3+0x48>
  8014a0:	e9 1d ff ff ff       	jmp    8013c2 <__umoddi3+0x52>
