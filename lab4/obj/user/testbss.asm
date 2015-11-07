
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  800041:	e8 0b 02 00 00       	call   800251 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	b8 01 00 00 00       	mov    $0x1,%eax
  80004b:	ba 20 20 80 00       	mov    $0x802020,%edx
  800050:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  800057:	74 04                	je     80005d <umain+0x29>
  800059:	b0 00                	mov    $0x0,%al
  80005b:	eb 06                	jmp    800063 <umain+0x2f>
  80005d:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800061:	74 20                	je     800083 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 db 14 80 	movl   $0x8014db,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  80007e:	e8 fd 00 00 00       	call   800180 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 d0                	jne    80005d <umain+0x29>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	ba 20 20 80 00       	mov    $0x802020,%edx
  800097:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a2:	75 f3                	jne    800097 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a9:	ba 20 20 80 00       	mov    $0x802020,%edx
  8000ae:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000b5:	74 04                	je     8000bb <umain+0x87>
  8000b7:	b0 00                	mov    $0x0,%al
  8000b9:	eb 05                	jmp    8000c0 <umain+0x8c>
  8000bb:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000be:	74 20                	je     8000e0 <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 80 14 80 	movl   $0x801480,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  8000db:	e8 a0 00 00 00       	call   800180 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e0:	83 c0 01             	add    $0x1,%eax
  8000e3:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e8:	75 d1                	jne    8000bb <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ea:	c7 04 24 a8 14 80 00 	movl   $0x8014a8,(%esp)
  8000f1:	e8 5b 01 00 00       	call   800251 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 07 15 80 	movl   $0x801507,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  800117:	e8 64 00 00 00       	call   800180 <_panic>

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800128:	8b 75 08             	mov    0x8(%ebp),%esi
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80012e:	e8 f3 0f 00 00       	call   801126 <sys_getenvid>
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	c1 e0 07             	shl    $0x7,%eax
  80013b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800140:	a3 20 20 c0 00       	mov    %eax,0xc02020
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800145:	85 f6                	test   %esi,%esi
  800147:	7e 07                	jle    800150 <libmain+0x34>
		binaryname = argv[0];
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800154:	89 34 24             	mov    %esi,(%esp)
  800157:	e8 d8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800164:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
	...

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800179:	e8 e8 0f 00 00       	call   801166 <sys_env_destroy>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800188:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80018b:	a1 24 20 c0 00       	mov    0xc02024,%eax
  800190:	85 c0                	test   %eax,%eax
  800192:	74 10                	je     8001a4 <_panic+0x24>
		cprintf("%s: ", argv0);
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  80019f:	e8 ad 00 00 00       	call   800251 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001aa:	e8 77 0f 00 00       	call   801126 <sys_getenvid>
  8001af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	c7 04 24 30 15 80 00 	movl   $0x801530,(%esp)
  8001cc:	e8 80 00 00 00       	call   800251 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 10 00 00 00       	call   8001f0 <vcprintf>
	cprintf("\n");
  8001e0:	c7 04 24 f6 14 80 00 	movl   $0x8014f6,(%esp)
  8001e7:	e8 65 00 00 00       	call   800251 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ec:	cc                   	int3   
  8001ed:	eb fd                	jmp    8001ec <_panic+0x6c>
	...

008001f0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800200:	00 00 00 
	b.cnt = 0;
  800203:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	c7 04 24 6b 02 80 00 	movl   $0x80026b,(%esp)
  80022c:	e8 cc 01 00 00       	call   8003fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800231:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	e8 13 0b 00 00       	call   800d5c <sys_cputs>

	return b.cnt;
}
  800249:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800257:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 87 ff ff ff       	call   8001f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	53                   	push   %ebx
  80026f:	83 ec 14             	sub    $0x14,%esp
  800272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800275:	8b 03                	mov    (%ebx),%eax
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80027e:	83 c0 01             	add    $0x1,%eax
  800281:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800283:	3d ff 00 00 00       	cmp    $0xff,%eax
  800288:	75 19                	jne    8002a3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80028a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800291:	00 
  800292:	8d 43 08             	lea    0x8(%ebx),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	e8 bf 0a 00 00       	call   800d5c <sys_cputs>
		b->idx = 0;
  80029d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 15                	jb     8002f4 <printnum+0x44>
  8002df:	77 07                	ja     8002e8 <printnum+0x38>
  8002e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e4:	39 d0                	cmp    %edx,%eax
  8002e6:	76 0c                	jbe    8002f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	8d 76 00             	lea    0x0(%esi),%esi
  8002f0:	7f 61                	jg     800353 <printnum+0xa3>
  8002f2:	eb 70                	jmp    800364 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800307:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80030e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800311:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800314:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800329:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032d:	e8 ae 0e 00 00       	call   8011e0 <__udivdi3>
  800332:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	89 54 24 04          	mov    %edx,0x4(%esp)
  800347:	89 f2                	mov    %esi,%edx
  800349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034c:	e8 5f ff ff ff       	call   8002b0 <printnum>
  800351:	eb 11                	jmp    800364 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800353:	89 74 24 04          	mov    %esi,0x4(%esp)
  800357:	89 3c 24             	mov    %edi,(%esp)
  80035a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035d:	83 eb 01             	sub    $0x1,%ebx
  800360:	85 db                	test   %ebx,%ebx
  800362:	7f ef                	jg     800353 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037a:	00 
  80037b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037e:	89 14 24             	mov    %edx,(%esp)
  800381:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800384:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800388:	e8 83 0f 00 00       	call   801310 <__umoddi3>
  80038d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800391:	0f be 80 54 15 80 00 	movsbl 0x801554(%eax),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039e:	83 c4 4c             	add    $0x4c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a9:	83 fa 01             	cmp    $0x1,%edx
  8003ac:	7e 0e                	jle    8003bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 02                	mov    (%edx),%eax
  8003b7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ba:	eb 22                	jmp    8003de <getuint+0x38>
	else if (lflag)
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	74 10                	je     8003d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ce:	eb 0e                	jmp    8003de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f4:	88 0a                	mov    %cl,(%edx)
  8003f6:	83 c2 01             	add    $0x1,%edx
  8003f9:	89 10                	mov    %edx,(%eax)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	57                   	push   %edi
  800401:	56                   	push   %esi
  800402:	53                   	push   %ebx
  800403:	83 ec 5c             	sub    $0x5c,%esp
  800406:	8b 7d 08             	mov    0x8(%ebp),%edi
  800409:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800416:	eb 11                	jmp    800429 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 09 04 00 00    	je     800829 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800420:	89 74 24 04          	mov    %esi,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800429:	0f b6 03             	movzbl (%ebx),%eax
  80042c:	83 c3 01             	add    $0x1,%ebx
  80042f:	83 f8 25             	cmp    $0x25,%eax
  800432:	75 e4                	jne    800418 <vprintfmt+0x1b>
  800434:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800438:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80043f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800446:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80044d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800452:	eb 06                	jmp    80045a <vprintfmt+0x5d>
  800454:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800458:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	0f b6 13             	movzbl (%ebx),%edx
  80045d:	0f b6 c2             	movzbl %dl,%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	8d 43 01             	lea    0x1(%ebx),%eax
  800466:	83 ea 23             	sub    $0x23,%edx
  800469:	80 fa 55             	cmp    $0x55,%dl
  80046c:	0f 87 9a 03 00 00    	ja     80080c <vprintfmt+0x40f>
  800472:	0f b6 d2             	movzbl %dl,%edx
  800475:	ff 24 95 20 16 80 00 	jmp    *0x801620(,%edx,4)
  80047c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800480:	eb d6                	jmp    800458 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800482:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800485:	83 ea 30             	sub    $0x30,%edx
  800488:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80048b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80048e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800491:	83 fb 09             	cmp    $0x9,%ebx
  800494:	77 4c                	ja     8004e2 <vprintfmt+0xe5>
  800496:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800499:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80049f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004a6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004a9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004ac:	83 fb 09             	cmp    $0x9,%ebx
  8004af:	76 eb                	jbe    80049c <vprintfmt+0x9f>
  8004b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b7:	eb 29                	jmp    8004e2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004bf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004c2:	8b 12                	mov    (%edx),%edx
  8004c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004c7:	eb 19                	jmp    8004e2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8004c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004cc:	c1 fa 1f             	sar    $0x1f,%edx
  8004cf:	f7 d2                	not    %edx
  8004d1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8004d4:	eb 82                	jmp    800458 <vprintfmt+0x5b>
  8004d6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004dd:	e9 76 ff ff ff       	jmp    800458 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e6:	0f 89 6c ff ff ff    	jns    800458 <vprintfmt+0x5b>
  8004ec:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004f5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004f8:	e9 5b ff ff ff       	jmp    800458 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004fd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800500:	e9 53 ff ff ff       	jmp    800458 <vprintfmt+0x5b>
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	89 74 24 04          	mov    %esi,0x4(%esp)
  800515:	8b 00                	mov    (%eax),%eax
  800517:	89 04 24             	mov    %eax,(%esp)
  80051a:	ff d7                	call   *%edi
  80051c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80051f:	e9 05 ff ff ff       	jmp    800429 <vprintfmt+0x2c>
  800524:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 50 04             	lea    0x4(%eax),%edx
  80052d:	89 55 14             	mov    %edx,0x14(%ebp)
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 c2                	mov    %eax,%edx
  800534:	c1 fa 1f             	sar    $0x1f,%edx
  800537:	31 d0                	xor    %edx,%eax
  800539:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053b:	83 f8 08             	cmp    $0x8,%eax
  80053e:	7f 0b                	jg     80054b <vprintfmt+0x14e>
  800540:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	75 20                	jne    80056b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80054b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054f:	c7 44 24 08 65 15 80 	movl   $0x801565,0x8(%esp)
  800556:	00 
  800557:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055b:	89 3c 24             	mov    %edi,(%esp)
  80055e:	e8 4e 03 00 00       	call   8008b1 <printfmt>
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800566:	e9 be fe ff ff       	jmp    800429 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80056b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80056f:	c7 44 24 08 6e 15 80 	movl   $0x80156e,0x8(%esp)
  800576:	00 
  800577:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057b:	89 3c 24             	mov    %edi,(%esp)
  80057e:	e8 2e 03 00 00       	call   8008b1 <printfmt>
  800583:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800586:	e9 9e fe ff ff       	jmp    800429 <vprintfmt+0x2c>
  80058b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800596:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	75 07                	jne    8005b2 <vprintfmt+0x1b5>
  8005ab:	c7 45 c4 71 15 80 00 	movl   $0x801571,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005b2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005b6:	7e 06                	jle    8005be <vprintfmt+0x1c1>
  8005b8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005bc:	75 13                	jne    8005d1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005c1:	0f be 02             	movsbl (%edx),%eax
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	0f 85 99 00 00 00    	jne    800665 <vprintfmt+0x268>
  8005cc:	e9 86 00 00 00       	jmp    800657 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8005d8:	89 0c 24             	mov    %ecx,(%esp)
  8005db:	e8 1b 03 00 00       	call   8008fb <strnlen>
  8005e0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005e3:	29 c2                	sub    %eax,%edx
  8005e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	7e d2                	jle    8005be <vprintfmt+0x1c1>
					putch(padc, putdat);
  8005ec:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005f6:	89 d3                	mov    %edx,%ebx
  8005f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	83 eb 01             	sub    $0x1,%ebx
  800607:	85 db                	test   %ebx,%ebx
  800609:	7f ed                	jg     8005f8 <vprintfmt+0x1fb>
  80060b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80060e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800615:	eb a7                	jmp    8005be <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800617:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80061b:	74 18                	je     800635 <vprintfmt+0x238>
  80061d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800620:	83 fa 5e             	cmp    $0x5e,%edx
  800623:	76 10                	jbe    800635 <vprintfmt+0x238>
					putch('?', putdat);
  800625:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800629:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800630:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800633:	eb 0a                	jmp    80063f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800635:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800639:	89 04 24             	mov    %eax,(%esp)
  80063c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800643:	0f be 03             	movsbl (%ebx),%eax
  800646:	85 c0                	test   %eax,%eax
  800648:	74 05                	je     80064f <vprintfmt+0x252>
  80064a:	83 c3 01             	add    $0x1,%ebx
  80064d:	eb 29                	jmp    800678 <vprintfmt+0x27b>
  80064f:	89 fe                	mov    %edi,%esi
  800651:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800654:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800657:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065b:	7f 2e                	jg     80068b <vprintfmt+0x28e>
  80065d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800660:	e9 c4 fd ff ff       	jmp    800429 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800668:	83 c2 01             	add    $0x1,%edx
  80066b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80066e:	89 f7                	mov    %esi,%edi
  800670:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800673:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800676:	89 d3                	mov    %edx,%ebx
  800678:	85 f6                	test   %esi,%esi
  80067a:	78 9b                	js     800617 <vprintfmt+0x21a>
  80067c:	83 ee 01             	sub    $0x1,%esi
  80067f:	79 96                	jns    800617 <vprintfmt+0x21a>
  800681:	89 fe                	mov    %edi,%esi
  800683:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800686:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800689:	eb cc                	jmp    800657 <vprintfmt+0x25a>
  80068b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80068e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800691:	89 74 24 04          	mov    %esi,0x4(%esp)
  800695:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069e:	83 eb 01             	sub    $0x1,%ebx
  8006a1:	85 db                	test   %ebx,%ebx
  8006a3:	7f ec                	jg     800691 <vprintfmt+0x294>
  8006a5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006a8:	e9 7c fd ff ff       	jmp    800429 <vprintfmt+0x2c>
  8006ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 16                	jle    8006cb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 08             	lea    0x8(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c9:	eb 32                	jmp    8006fd <vprintfmt+0x300>
	else if (lflag)
  8006cb:	85 c9                	test   %ecx,%ecx
  8006cd:	74 18                	je     8006e7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 04             	lea    0x4(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006dd:	89 c1                	mov    %eax,%ecx
  8006df:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e5:	eb 16                	jmp    8006fd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 50 04             	lea    0x4(%eax),%edx
  8006ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f5:	89 c2                	mov    %eax,%edx
  8006f7:	c1 fa 1f             	sar    $0x1f,%edx
  8006fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800700:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800703:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800708:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80070c:	0f 89 b8 00 00 00    	jns    8007ca <vprintfmt+0x3cd>
				putch('-', putdat);
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071d:	ff d7                	call   *%edi
				num = -(long long) num;
  80071f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800722:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800725:	f7 d9                	neg    %ecx
  800727:	83 d3 00             	adc    $0x0,%ebx
  80072a:	f7 db                	neg    %ebx
  80072c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800731:	e9 94 00 00 00       	jmp    8007ca <vprintfmt+0x3cd>
  800736:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800739:	89 ca                	mov    %ecx,%edx
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 63 fc ff ff       	call   8003a6 <getuint>
  800743:	89 c1                	mov    %eax,%ecx
  800745:	89 d3                	mov    %edx,%ebx
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80074c:	eb 7c                	jmp    8007ca <vprintfmt+0x3cd>
  80074e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800751:	89 74 24 04          	mov    %esi,0x4(%esp)
  800755:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80075c:	ff d7                	call   *%edi
			putch('X', putdat);
  80075e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800762:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800769:	ff d7                	call   *%edi
			putch('X', putdat);
  80076b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800776:	ff d7                	call   *%edi
  800778:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80077b:	e9 a9 fc ff ff       	jmp    800429 <vprintfmt+0x2c>
  800780:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800783:	89 74 24 04          	mov    %esi,0x4(%esp)
  800787:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078e:	ff d7                	call   *%edi
			putch('x', putdat);
  800790:	89 74 24 04          	mov    %esi,0x4(%esp)
  800794:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079b:	ff d7                	call   *%edi
			num = (unsigned long long)
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 50 04             	lea    0x4(%eax),%edx
  8007a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a6:	8b 08                	mov    (%eax),%ecx
  8007a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ad:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007b2:	eb 16                	jmp    8007ca <vprintfmt+0x3cd>
  8007b4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b7:	89 ca                	mov    %ecx,%edx
  8007b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bc:	e8 e5 fb ff ff       	call   8003a6 <getuint>
  8007c1:	89 c1                	mov    %eax,%ecx
  8007c3:	89 d3                	mov    %edx,%ebx
  8007c5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ca:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007ce:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	89 0c 24             	mov    %ecx,(%esp)
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	89 f8                	mov    %edi,%eax
  8007e8:	e8 c3 fa ff ff       	call   8002b0 <printnum>
  8007ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007f0:	e9 34 fc ff ff       	jmp    800429 <vprintfmt+0x2c>
  8007f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007f8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ff:	89 14 24             	mov    %edx,(%esp)
  800802:	ff d7                	call   *%edi
  800804:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800807:	e9 1d fc ff ff       	jmp    800429 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800810:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800817:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800819:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80081c:	80 38 25             	cmpb   $0x25,(%eax)
  80081f:	0f 84 04 fc ff ff    	je     800429 <vprintfmt+0x2c>
  800825:	89 c3                	mov    %eax,%ebx
  800827:	eb f0                	jmp    800819 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800829:	83 c4 5c             	add    $0x5c,%esp
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5f                   	pop    %edi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 28             	sub    $0x28,%esp
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 04                	je     800845 <vsnprintf+0x14>
  800841:	85 d2                	test   %edx,%edx
  800843:	7f 07                	jg     80084c <vsnprintf+0x1b>
  800845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084a:	eb 3b                	jmp    800887 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800853:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800856:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085d:	8b 45 14             	mov    0x14(%ebp),%eax
  800860:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800864:	8b 45 10             	mov    0x10(%ebp),%eax
  800867:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800872:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  800879:	e8 7f fb ff ff       	call   8003fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800881:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800884:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
  800899:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 82 ff ff ff       	call   800831 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008b7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008be:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	89 04 24             	mov    %eax,(%esp)
  8008d2:	e8 26 fb ff ff       	call   8003fd <vprintfmt>
	va_end(ap);
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    
  8008d9:	00 00                	add    %al,(%eax)
  8008db:	00 00                	add    %al,(%eax)
  8008dd:	00 00                	add    %al,(%eax)
	...

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ee:	74 09                	je     8008f9 <strlen+0x19>
		n++;
  8008f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f7:	75 f7                	jne    8008f0 <strlen+0x10>
		n++;
	return n;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 19                	je     800922 <strnlen+0x27>
  800909:	80 3b 00             	cmpb   $0x0,(%ebx)
  80090c:	74 14                	je     800922 <strnlen+0x27>
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800913:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800916:	39 c8                	cmp    %ecx,%eax
  800918:	74 0d                	je     800927 <strnlen+0x2c>
  80091a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80091e:	75 f3                	jne    800913 <strnlen+0x18>
  800920:	eb 05                	jmp    800927 <strnlen+0x2c>
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800939:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	84 c9                	test   %cl,%cl
  800945:	75 f2                	jne    800939 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800954:	89 1c 24             	mov    %ebx,(%esp)
  800957:	e8 84 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800963:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 bc ff ff ff       	call   80092a <strcpy>
	return dst;
}
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	83 c4 08             	add    $0x8,%esp
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800984:	85 f6                	test   %esi,%esi
  800986:	74 18                	je     8009a0 <strncpy+0x2a>
  800988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80098d:	0f b6 1a             	movzbl (%edx),%ebx
  800990:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800993:	80 3a 01             	cmpb   $0x1,(%edx)
  800996:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	39 ce                	cmp    %ecx,%esi
  80099e:	77 ed                	ja     80098d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 27                	je     8009df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009b8:	83 e9 01             	sub    $0x1,%ecx
  8009bb:	74 1d                	je     8009da <strlcpy+0x36>
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	84 db                	test   %bl,%bl
  8009c2:	74 16                	je     8009da <strlcpy+0x36>
			*dst++ = *src++;
  8009c4:	88 18                	mov    %bl,(%eax)
  8009c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c9:	83 e9 01             	sub    $0x1,%ecx
  8009cc:	74 0e                	je     8009dc <strlcpy+0x38>
			*dst++ = *src++;
  8009ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d1:	0f b6 1a             	movzbl (%edx),%ebx
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	75 ec                	jne    8009c4 <strlcpy+0x20>
  8009d8:	eb 02                	jmp    8009dc <strlcpy+0x38>
  8009da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009dc:	c6 00 00             	movb   $0x0,(%eax)
  8009df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ee:	0f b6 01             	movzbl (%ecx),%eax
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 15                	je     800a0a <strcmp+0x25>
  8009f5:	3a 02                	cmp    (%edx),%al
  8009f7:	75 11                	jne    800a0a <strcmp+0x25>
		p++, q++;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	84 c0                	test   %al,%al
  800a04:	74 04                	je     800a0a <strcmp+0x25>
  800a06:	3a 02                	cmp    (%edx),%al
  800a08:	74 ef                	je     8009f9 <strcmp+0x14>
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a21:	85 c0                	test   %eax,%eax
  800a23:	74 23                	je     800a48 <strncmp+0x34>
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	84 db                	test   %bl,%bl
  800a2a:	74 25                	je     800a51 <strncmp+0x3d>
  800a2c:	3a 19                	cmp    (%ecx),%bl
  800a2e:	75 21                	jne    800a51 <strncmp+0x3d>
  800a30:	83 e8 01             	sub    $0x1,%eax
  800a33:	74 13                	je     800a48 <strncmp+0x34>
		n--, p++, q++;
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3b:	0f b6 1a             	movzbl (%edx),%ebx
  800a3e:	84 db                	test   %bl,%bl
  800a40:	74 0f                	je     800a51 <strncmp+0x3d>
  800a42:	3a 19                	cmp    (%ecx),%bl
  800a44:	74 ea                	je     800a30 <strncmp+0x1c>
  800a46:	eb 09                	jmp    800a51 <strncmp+0x3d>
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	90                   	nop
  800a50:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 02             	movzbl (%edx),%eax
  800a54:	0f b6 11             	movzbl (%ecx),%edx
  800a57:	29 d0                	sub    %edx,%eax
  800a59:	eb f2                	jmp    800a4d <strncmp+0x39>

00800a5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a65:	0f b6 10             	movzbl (%eax),%edx
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	74 18                	je     800a84 <strchr+0x29>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	75 0a                	jne    800a7a <strchr+0x1f>
  800a70:	eb 17                	jmp    800a89 <strchr+0x2e>
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a78:	74 0f                	je     800a89 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	84 d2                	test   %dl,%dl
  800a82:	75 ee                	jne    800a72 <strchr+0x17>
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 18                	je     800ab4 <strfind+0x29>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 0a                	jne    800aaa <strfind+0x1f>
  800aa0:	eb 12                	jmp    800ab4 <strfind+0x29>
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa8:	74 0a                	je     800ab4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 ee                	jne    800aa2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	89 1c 24             	mov    %ebx,(%esp)
  800abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ac3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad0:	85 c9                	test   %ecx,%ecx
  800ad2:	74 30                	je     800b04 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ada:	75 25                	jne    800b01 <memset+0x4b>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 20                	jne    800b01 <memset+0x4b>
		c &= 0xFF;
  800ae1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	c1 e3 08             	shl    $0x8,%ebx
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	c1 e6 18             	shl    $0x18,%esi
  800aee:	89 d0                	mov    %edx,%eax
  800af0:	c1 e0 10             	shl    $0x10,%eax
  800af3:	09 f0                	or     %esi,%eax
  800af5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800af7:	09 d8                	or     %ebx,%eax
  800af9:	c1 e9 02             	shr    $0x2,%ecx
  800afc:	fc                   	cld    
  800afd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aff:	eb 03                	jmp    800b04 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b01:	fc                   	cld    
  800b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	8b 1c 24             	mov    (%esp),%ebx
  800b09:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b11:	89 ec                	mov    %ebp,%esp
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	89 34 24             	mov    %esi,(%esp)
  800b1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b2b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b2d:	39 c6                	cmp    %eax,%esi
  800b2f:	73 35                	jae    800b66 <memmove+0x51>
  800b31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 2e                	jae    800b66 <memmove+0x51>
		s += n;
		d += n;
  800b38:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f6 c2 03             	test   $0x3,%dl
  800b3d:	75 1b                	jne    800b5a <memmove+0x45>
  800b3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b45:	75 13                	jne    800b5a <memmove+0x45>
  800b47:	f6 c1 03             	test   $0x3,%cl
  800b4a:	75 0e                	jne    800b5a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b4c:	83 ef 04             	sub    $0x4,%edi
  800b4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b52:	c1 e9 02             	shr    $0x2,%ecx
  800b55:	fd                   	std    
  800b56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b58:	eb 09                	jmp    800b63 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5a:	83 ef 01             	sub    $0x1,%edi
  800b5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b60:	fd                   	std    
  800b61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b63:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b64:	eb 20                	jmp    800b86 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6c:	75 15                	jne    800b83 <memmove+0x6e>
  800b6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b74:	75 0d                	jne    800b83 <memmove+0x6e>
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 08                	jne    800b83 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
  800b7e:	fc                   	cld    
  800b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b81:	eb 03                	jmp    800b86 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b83:	fc                   	cld    
  800b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b86:	8b 34 24             	mov    (%esp),%esi
  800b89:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b8d:	89 ec                	mov    %ebp,%esp
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b97:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	89 04 24             	mov    %eax,(%esp)
  800bab:	e8 65 ff ff ff       	call   800b15 <memmove>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc1:	85 c9                	test   %ecx,%ecx
  800bc3:	74 36                	je     800bfb <memcmp+0x49>
		if (*s1 != *s2)
  800bc5:	0f b6 06             	movzbl (%esi),%eax
  800bc8:	0f b6 1f             	movzbl (%edi),%ebx
  800bcb:	38 d8                	cmp    %bl,%al
  800bcd:	74 20                	je     800bef <memcmp+0x3d>
  800bcf:	eb 14                	jmp    800be5 <memcmp+0x33>
  800bd1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bd6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bdb:	83 c2 01             	add    $0x1,%edx
  800bde:	83 e9 01             	sub    $0x1,%ecx
  800be1:	38 d8                	cmp    %bl,%al
  800be3:	74 12                	je     800bf7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800be5:	0f b6 c0             	movzbl %al,%eax
  800be8:	0f b6 db             	movzbl %bl,%ebx
  800beb:	29 d8                	sub    %ebx,%eax
  800bed:	eb 11                	jmp    800c00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	83 e9 01             	sub    $0x1,%ecx
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	85 c9                	test   %ecx,%ecx
  800bf9:	75 d6                	jne    800bd1 <memcmp+0x1f>
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c10:	39 d0                	cmp    %edx,%eax
  800c12:	73 15                	jae    800c29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c18:	38 08                	cmp    %cl,(%eax)
  800c1a:	75 06                	jne    800c22 <memfind+0x1d>
  800c1c:	eb 0b                	jmp    800c29 <memfind+0x24>
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 07                	je     800c29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	39 c2                	cmp    %eax,%edx
  800c27:	77 f5                	ja     800c1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 04             	sub    $0x4,%esp
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3a:	0f b6 02             	movzbl (%edx),%eax
  800c3d:	3c 20                	cmp    $0x20,%al
  800c3f:	74 04                	je     800c45 <strtol+0x1a>
  800c41:	3c 09                	cmp    $0x9,%al
  800c43:	75 0e                	jne    800c53 <strtol+0x28>
		s++;
  800c45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c48:	0f b6 02             	movzbl (%edx),%eax
  800c4b:	3c 20                	cmp    $0x20,%al
  800c4d:	74 f6                	je     800c45 <strtol+0x1a>
  800c4f:	3c 09                	cmp    $0x9,%al
  800c51:	74 f2                	je     800c45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c53:	3c 2b                	cmp    $0x2b,%al
  800c55:	75 0c                	jne    800c63 <strtol+0x38>
		s++;
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c61:	eb 15                	jmp    800c78 <strtol+0x4d>
	else if (*s == '-')
  800c63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c6a:	3c 2d                	cmp    $0x2d,%al
  800c6c:	75 0a                	jne    800c78 <strtol+0x4d>
		s++, neg = 1;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c78:	85 db                	test   %ebx,%ebx
  800c7a:	0f 94 c0             	sete   %al
  800c7d:	74 05                	je     800c84 <strtol+0x59>
  800c7f:	83 fb 10             	cmp    $0x10,%ebx
  800c82:	75 18                	jne    800c9c <strtol+0x71>
  800c84:	80 3a 30             	cmpb   $0x30,(%edx)
  800c87:	75 13                	jne    800c9c <strtol+0x71>
  800c89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c8d:	8d 76 00             	lea    0x0(%esi),%esi
  800c90:	75 0a                	jne    800c9c <strtol+0x71>
		s += 2, base = 16;
  800c92:	83 c2 02             	add    $0x2,%edx
  800c95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9a:	eb 15                	jmp    800cb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	84 c0                	test   %al,%al
  800c9e:	66 90                	xchg   %ax,%ax
  800ca0:	74 0f                	je     800cb1 <strtol+0x86>
  800ca2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ca7:	80 3a 30             	cmpb   $0x30,(%edx)
  800caa:	75 05                	jne    800cb1 <strtol+0x86>
		s++, base = 8;
  800cac:	83 c2 01             	add    $0x1,%edx
  800caf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb8:	0f b6 0a             	movzbl (%edx),%ecx
  800cbb:	89 cf                	mov    %ecx,%edi
  800cbd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cc0:	80 fb 09             	cmp    $0x9,%bl
  800cc3:	77 08                	ja     800ccd <strtol+0xa2>
			dig = *s - '0';
  800cc5:	0f be c9             	movsbl %cl,%ecx
  800cc8:	83 e9 30             	sub    $0x30,%ecx
  800ccb:	eb 1e                	jmp    800ceb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ccd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cd5:	0f be c9             	movsbl %cl,%ecx
  800cd8:	83 e9 57             	sub    $0x57,%ecx
  800cdb:	eb 0e                	jmp    800ceb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cdd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 15                	ja     800cfa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ceb:	39 f1                	cmp    %esi,%ecx
  800ced:	7d 0b                	jge    800cfa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cef:	83 c2 01             	add    $0x1,%edx
  800cf2:	0f af c6             	imul   %esi,%eax
  800cf5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cf8:	eb be                	jmp    800cb8 <strtol+0x8d>
  800cfa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d00:	74 05                	je     800d07 <strtol+0xdc>
		*endptr = (char *) s;
  800d02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d0b:	74 04                	je     800d11 <strtol+0xe6>
  800d0d:	89 c8                	mov    %ecx,%eax
  800d0f:	f7 d8                	neg    %eax
}
  800d11:	83 c4 04             	add    $0x4,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
  800d19:	00 00                	add    %al,(%eax)
	...

00800d1c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800d29:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d33:	89 d1                	mov    %edx,%ecx
  800d35:	89 d3                	mov    %edx,%ebx
  800d37:	89 d7                	mov    %edx,%edi
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

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d51:	8b 1c 24             	mov    (%esp),%ebx
  800d54:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 08             	sub    $0x8,%esp
  800d62:	89 1c 24             	mov    %ebx,(%esp)
  800d65:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	51                   	push   %ecx
  800d79:	52                   	push   %edx
  800d7a:	53                   	push   %ebx
  800d7b:	54                   	push   %esp
  800d7c:	55                   	push   %ebp
  800d7d:	56                   	push   %esi
  800d7e:	57                   	push   %edi
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8d 35 89 0d 80 00    	lea    0x800d89,%esi
  800d87:	0f 34                	sysenter 
  800d89:	5f                   	pop    %edi
  800d8a:	5e                   	pop    %esi
  800d8b:	5d                   	pop    %ebp
  800d8c:	5c                   	pop    %esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5a                   	pop    %edx
  800d8f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d90:	8b 1c 24             	mov    (%esp),%ebx
  800d93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d97:	89 ec                	mov    %ebp,%esp
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
  800da1:	89 1c 24             	mov    %ebx,(%esp)
  800da4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dad:	b8 0e 00 00 00       	mov    $0xe,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800dd1:	8b 1c 24             	mov    (%esp),%ebx
  800dd4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd8:	89 ec                	mov    %ebp,%esp
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 28             	sub    $0x28,%esp
  800de2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800de5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ded:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 cb                	mov    %ecx,%ebx
  800df7:	89 cf                	mov    %ecx,%edi
  800df9:	51                   	push   %ecx
  800dfa:	52                   	push   %edx
  800dfb:	53                   	push   %ebx
  800dfc:	54                   	push   %esp
  800dfd:	55                   	push   %ebp
  800dfe:	56                   	push   %esi
  800dff:	57                   	push   %edi
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	8d 35 0a 0e 80 00    	lea    0x800e0a,%esi
  800e08:	0f 34                	sysenter 
  800e0a:	5f                   	pop    %edi
  800e0b:	5e                   	pop    %esi
  800e0c:	5d                   	pop    %ebp
  800e0d:	5c                   	pop    %esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5a                   	pop    %edx
  800e10:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7e 28                	jle    800e3d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e19:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e20:	00 
  800e21:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800e28:	00 
  800e29:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e30:	00 
  800e31:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800e38:	e8 43 f3 ff ff       	call   800180 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e43:	89 ec                	mov    %ebp,%esp
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	89 1c 24             	mov    %ebx,(%esp)
  800e50:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	51                   	push   %ecx
  800e66:	52                   	push   %edx
  800e67:	53                   	push   %ebx
  800e68:	54                   	push   %esp
  800e69:	55                   	push   %ebp
  800e6a:	56                   	push   %esi
  800e6b:	57                   	push   %edi
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8d 35 76 0e 80 00    	lea    0x800e76,%esi
  800e74:	0f 34                	sysenter 
  800e76:	5f                   	pop    %edi
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	5c                   	pop    %esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5a                   	pop    %edx
  800e7c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7d:	8b 1c 24             	mov    (%esp),%ebx
  800e80:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e84:	89 ec                	mov    %ebp,%esp
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 28             	sub    $0x28,%esp
  800e8e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e91:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 df                	mov    %ebx,%edi
  800ea6:	51                   	push   %ecx
  800ea7:	52                   	push   %edx
  800ea8:	53                   	push   %ebx
  800ea9:	54                   	push   %esp
  800eaa:	55                   	push   %ebp
  800eab:	56                   	push   %esi
  800eac:	57                   	push   %edi
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	8d 35 b7 0e 80 00    	lea    0x800eb7,%esi
  800eb5:	0f 34                	sysenter 
  800eb7:	5f                   	pop    %edi
  800eb8:	5e                   	pop    %esi
  800eb9:	5d                   	pop    %ebp
  800eba:	5c                   	pop    %esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5a                   	pop    %edx
  800ebd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	7e 28                	jle    800eea <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ecd:	00 
  800ece:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800ee5:	e8 96 f2 ff ff       	call   800180 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eea:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800eed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef0:	89 ec                	mov    %ebp,%esp
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 28             	sub    $0x28,%esp
  800efa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800efd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	89 df                	mov    %ebx,%edi
  800f12:	51                   	push   %ecx
  800f13:	52                   	push   %edx
  800f14:	53                   	push   %ebx
  800f15:	54                   	push   %esp
  800f16:	55                   	push   %ebp
  800f17:	56                   	push   %esi
  800f18:	57                   	push   %edi
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	8d 35 23 0f 80 00    	lea    0x800f23,%esi
  800f21:	0f 34                	sysenter 
  800f23:	5f                   	pop    %edi
  800f24:	5e                   	pop    %esi
  800f25:	5d                   	pop    %ebp
  800f26:	5c                   	pop    %esp
  800f27:	5b                   	pop    %ebx
  800f28:	5a                   	pop    %edx
  800f29:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	7e 28                	jle    800f56 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f32:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f39:	00 
  800f3a:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800f41:	00 
  800f42:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f49:	00 
  800f4a:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800f51:	e8 2a f2 ff ff       	call   800180 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f56:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5c:	89 ec                	mov    %ebp,%esp
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 28             	sub    $0x28,%esp
  800f66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f69:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f71:	b8 07 00 00 00       	mov    $0x7,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	89 df                	mov    %ebx,%edi
  800f7e:	51                   	push   %ecx
  800f7f:	52                   	push   %edx
  800f80:	53                   	push   %ebx
  800f81:	54                   	push   %esp
  800f82:	55                   	push   %ebp
  800f83:	56                   	push   %esi
  800f84:	57                   	push   %edi
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	8d 35 8f 0f 80 00    	lea    0x800f8f,%esi
  800f8d:	0f 34                	sysenter 
  800f8f:	5f                   	pop    %edi
  800f90:	5e                   	pop    %esi
  800f91:	5d                   	pop    %ebp
  800f92:	5c                   	pop    %esp
  800f93:	5b                   	pop    %ebx
  800f94:	5a                   	pop    %edx
  800f95:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f96:	85 c0                	test   %eax,%eax
  800f98:	7e 28                	jle    800fc2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800fad:	00 
  800fae:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800fb5:	00 
  800fb6:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800fbd:	e8 be f1 ff ff       	call   800180 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fc2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fc5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc8:	89 ec                	mov    %ebp,%esp
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 28             	sub    $0x28,%esp
  800fd2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fd5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	51                   	push   %ecx
  800fea:	52                   	push   %edx
  800feb:	53                   	push   %ebx
  800fec:	54                   	push   %esp
  800fed:	55                   	push   %ebp
  800fee:	56                   	push   %esi
  800fef:	57                   	push   %edi
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	8d 35 fa 0f 80 00    	lea    0x800ffa,%esi
  800ff8:	0f 34                	sysenter 
  800ffa:	5f                   	pop    %edi
  800ffb:	5e                   	pop    %esi
  800ffc:	5d                   	pop    %ebp
  800ffd:	5c                   	pop    %esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5a                   	pop    %edx
  801000:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  801028:	e8 53 f1 ff ff       	call   800180 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80102d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801030:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801033:	89 ec                	mov    %ebp,%esp
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 28             	sub    $0x28,%esp
  80103d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801040:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801043:	bf 00 00 00 00       	mov    $0x0,%edi
  801048:	b8 05 00 00 00       	mov    $0x5,%eax
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	51                   	push   %ecx
  801057:	52                   	push   %edx
  801058:	53                   	push   %ebx
  801059:	54                   	push   %esp
  80105a:	55                   	push   %ebp
  80105b:	56                   	push   %esi
  80105c:	57                   	push   %edi
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	8d 35 67 10 80 00    	lea    0x801067,%esi
  801065:	0f 34                	sysenter 
  801067:	5f                   	pop    %edi
  801068:	5e                   	pop    %esi
  801069:	5d                   	pop    %ebp
  80106a:	5c                   	pop    %esp
  80106b:	5b                   	pop    %ebx
  80106c:	5a                   	pop    %edx
  80106d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	7e 28                	jle    80109a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801072:	89 44 24 10          	mov    %eax,0x10(%esp)
  801076:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80107d:	00 
  80107e:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  801085:	00 
  801086:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80108d:	00 
  80108e:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  801095:	e8 e6 f0 ff ff       	call   800180 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80109a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80109d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a0:	89 ec                	mov    %ebp,%esp
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	51                   	push   %ecx
  8010c2:	52                   	push   %edx
  8010c3:	53                   	push   %ebx
  8010c4:	54                   	push   %esp
  8010c5:	55                   	push   %ebp
  8010c6:	56                   	push   %esi
  8010c7:	57                   	push   %edi
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	8d 35 d2 10 80 00    	lea    0x8010d2,%esi
  8010d0:	0f 34                	sysenter 
  8010d2:	5f                   	pop    %edi
  8010d3:	5e                   	pop    %esi
  8010d4:	5d                   	pop    %ebp
  8010d5:	5c                   	pop    %esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5a                   	pop    %edx
  8010d8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010d9:	8b 1c 24             	mov    (%esp),%ebx
  8010dc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e0:	89 ec                	mov    %ebp,%esp
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	89 1c 24             	mov    %ebx,(%esp)
  8010ed:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8010fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801101:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80111b:	8b 1c 24             	mov    (%esp),%ebx
  80111e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801122:	89 ec                	mov    %ebp,%esp
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	89 1c 24             	mov    %ebx,(%esp)
  80112f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801133:	ba 00 00 00 00       	mov    $0x0,%edx
  801138:	b8 02 00 00 00       	mov    $0x2,%eax
  80113d:	89 d1                	mov    %edx,%ecx
  80113f:	89 d3                	mov    %edx,%ebx
  801141:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80115b:	8b 1c 24             	mov    (%esp),%ebx
  80115e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801162:	89 ec                	mov    %ebp,%esp
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 28             	sub    $0x28,%esp
  80116c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80116f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801172:	b9 00 00 00 00       	mov    $0x0,%ecx
  801177:	b8 03 00 00 00       	mov    $0x3,%eax
  80117c:	8b 55 08             	mov    0x8(%ebp),%edx
  80117f:	89 cb                	mov    %ecx,%ebx
  801181:	89 cf                	mov    %ecx,%edi
  801183:	51                   	push   %ecx
  801184:	52                   	push   %edx
  801185:	53                   	push   %ebx
  801186:	54                   	push   %esp
  801187:	55                   	push   %ebp
  801188:	56                   	push   %esi
  801189:	57                   	push   %edi
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	8d 35 94 11 80 00    	lea    0x801194,%esi
  801192:	0f 34                	sysenter 
  801194:	5f                   	pop    %edi
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	5c                   	pop    %esp
  801198:	5b                   	pop    %ebx
  801199:	5a                   	pop    %edx
  80119a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80119b:	85 c0                	test   %eax,%eax
  80119d:	7e 28                	jle    8011c7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  8011c2:	e8 b9 ef ff ff       	call   800180 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011c7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011cd:	89 ec                	mov    %ebp,%esp
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    
	...

008011e0 <__udivdi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	83 ec 10             	sub    $0x10,%esp
  8011e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8011f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011f9:	75 35                	jne    801230 <__udivdi3+0x50>
  8011fb:	39 fe                	cmp    %edi,%esi
  8011fd:	77 61                	ja     801260 <__udivdi3+0x80>
  8011ff:	85 f6                	test   %esi,%esi
  801201:	75 0b                	jne    80120e <__udivdi3+0x2e>
  801203:	b8 01 00 00 00       	mov    $0x1,%eax
  801208:	31 d2                	xor    %edx,%edx
  80120a:	f7 f6                	div    %esi
  80120c:	89 c6                	mov    %eax,%esi
  80120e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801211:	31 d2                	xor    %edx,%edx
  801213:	89 f8                	mov    %edi,%eax
  801215:	f7 f6                	div    %esi
  801217:	89 c7                	mov    %eax,%edi
  801219:	89 c8                	mov    %ecx,%eax
  80121b:	f7 f6                	div    %esi
  80121d:	89 c1                	mov    %eax,%ecx
  80121f:	89 fa                	mov    %edi,%edx
  801221:	89 c8                	mov    %ecx,%eax
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    
  80122a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801230:	39 f8                	cmp    %edi,%eax
  801232:	77 1c                	ja     801250 <__udivdi3+0x70>
  801234:	0f bd d0             	bsr    %eax,%edx
  801237:	83 f2 1f             	xor    $0x1f,%edx
  80123a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80123d:	75 39                	jne    801278 <__udivdi3+0x98>
  80123f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801242:	0f 86 a0 00 00 00    	jbe    8012e8 <__udivdi3+0x108>
  801248:	39 f8                	cmp    %edi,%eax
  80124a:	0f 82 98 00 00 00    	jb     8012e8 <__udivdi3+0x108>
  801250:	31 ff                	xor    %edi,%edi
  801252:	31 c9                	xor    %ecx,%ecx
  801254:	89 c8                	mov    %ecx,%eax
  801256:	89 fa                	mov    %edi,%edx
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    
  80125f:	90                   	nop
  801260:	89 d1                	mov    %edx,%ecx
  801262:	89 fa                	mov    %edi,%edx
  801264:	89 c8                	mov    %ecx,%eax
  801266:	31 ff                	xor    %edi,%edi
  801268:	f7 f6                	div    %esi
  80126a:	89 c1                	mov    %eax,%ecx
  80126c:	89 fa                	mov    %edi,%edx
  80126e:	89 c8                	mov    %ecx,%eax
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    
  801277:	90                   	nop
  801278:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80127c:	89 f2                	mov    %esi,%edx
  80127e:	d3 e0                	shl    %cl,%eax
  801280:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801283:	b8 20 00 00 00       	mov    $0x20,%eax
  801288:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80128b:	89 c1                	mov    %eax,%ecx
  80128d:	d3 ea                	shr    %cl,%edx
  80128f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801293:	0b 55 ec             	or     -0x14(%ebp),%edx
  801296:	d3 e6                	shl    %cl,%esi
  801298:	89 c1                	mov    %eax,%ecx
  80129a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80129d:	89 fe                	mov    %edi,%esi
  80129f:	d3 ee                	shr    %cl,%esi
  8012a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ab:	d3 e7                	shl    %cl,%edi
  8012ad:	89 c1                	mov    %eax,%ecx
  8012af:	d3 ea                	shr    %cl,%edx
  8012b1:	09 d7                	or     %edx,%edi
  8012b3:	89 f2                	mov    %esi,%edx
  8012b5:	89 f8                	mov    %edi,%eax
  8012b7:	f7 75 ec             	divl   -0x14(%ebp)
  8012ba:	89 d6                	mov    %edx,%esi
  8012bc:	89 c7                	mov    %eax,%edi
  8012be:	f7 65 e8             	mull   -0x18(%ebp)
  8012c1:	39 d6                	cmp    %edx,%esi
  8012c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012c6:	72 30                	jb     8012f8 <__udivdi3+0x118>
  8012c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012cf:	d3 e2                	shl    %cl,%edx
  8012d1:	39 c2                	cmp    %eax,%edx
  8012d3:	73 05                	jae    8012da <__udivdi3+0xfa>
  8012d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8012d8:	74 1e                	je     8012f8 <__udivdi3+0x118>
  8012da:	89 f9                	mov    %edi,%ecx
  8012dc:	31 ff                	xor    %edi,%edi
  8012de:	e9 71 ff ff ff       	jmp    801254 <__udivdi3+0x74>
  8012e3:	90                   	nop
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	31 ff                	xor    %edi,%edi
  8012ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8012ef:	e9 60 ff ff ff       	jmp    801254 <__udivdi3+0x74>
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8012fb:	31 ff                	xor    %edi,%edi
  8012fd:	89 c8                	mov    %ecx,%eax
  8012ff:	89 fa                	mov    %edi,%edx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    
	...

00801310 <__umoddi3>:
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	57                   	push   %edi
  801314:	56                   	push   %esi
  801315:	83 ec 20             	sub    $0x20,%esp
  801318:	8b 55 14             	mov    0x14(%ebp),%edx
  80131b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801321:	8b 75 0c             	mov    0xc(%ebp),%esi
  801324:	85 d2                	test   %edx,%edx
  801326:	89 c8                	mov    %ecx,%eax
  801328:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80132b:	75 13                	jne    801340 <__umoddi3+0x30>
  80132d:	39 f7                	cmp    %esi,%edi
  80132f:	76 3f                	jbe    801370 <__umoddi3+0x60>
  801331:	89 f2                	mov    %esi,%edx
  801333:	f7 f7                	div    %edi
  801335:	89 d0                	mov    %edx,%eax
  801337:	31 d2                	xor    %edx,%edx
  801339:	83 c4 20             	add    $0x20,%esp
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
  801340:	39 f2                	cmp    %esi,%edx
  801342:	77 4c                	ja     801390 <__umoddi3+0x80>
  801344:	0f bd ca             	bsr    %edx,%ecx
  801347:	83 f1 1f             	xor    $0x1f,%ecx
  80134a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80134d:	75 51                	jne    8013a0 <__umoddi3+0x90>
  80134f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801352:	0f 87 e0 00 00 00    	ja     801438 <__umoddi3+0x128>
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	29 f8                	sub    %edi,%eax
  80135d:	19 d6                	sbb    %edx,%esi
  80135f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	89 f2                	mov    %esi,%edx
  801367:	83 c4 20             	add    $0x20,%esp
  80136a:	5e                   	pop    %esi
  80136b:	5f                   	pop    %edi
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    
  80136e:	66 90                	xchg   %ax,%ax
  801370:	85 ff                	test   %edi,%edi
  801372:	75 0b                	jne    80137f <__umoddi3+0x6f>
  801374:	b8 01 00 00 00       	mov    $0x1,%eax
  801379:	31 d2                	xor    %edx,%edx
  80137b:	f7 f7                	div    %edi
  80137d:	89 c7                	mov    %eax,%edi
  80137f:	89 f0                	mov    %esi,%eax
  801381:	31 d2                	xor    %edx,%edx
  801383:	f7 f7                	div    %edi
  801385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801388:	f7 f7                	div    %edi
  80138a:	eb a9                	jmp    801335 <__umoddi3+0x25>
  80138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 f2                	mov    %esi,%edx
  801394:	83 c4 20             	add    $0x20,%esp
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
  80139b:	90                   	nop
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013a4:	d3 e2                	shl    %cl,%edx
  8013a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8013ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8013b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013b8:	89 fa                	mov    %edi,%edx
  8013ba:	d3 ea                	shr    %cl,%edx
  8013bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013cc:	89 f2                	mov    %esi,%edx
  8013ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8013d1:	89 c7                	mov    %eax,%edi
  8013d3:	d3 ea                	shr    %cl,%edx
  8013d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	d3 e6                	shl    %cl,%esi
  8013e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013e4:	d3 ea                	shr    %cl,%edx
  8013e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013ea:	09 d6                	or     %edx,%esi
  8013ec:	89 f0                	mov    %esi,%eax
  8013ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013f1:	d3 e7                	shl    %cl,%edi
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	f7 75 f4             	divl   -0xc(%ebp)
  8013f8:	89 d6                	mov    %edx,%esi
  8013fa:	f7 65 e8             	mull   -0x18(%ebp)
  8013fd:	39 d6                	cmp    %edx,%esi
  8013ff:	72 2b                	jb     80142c <__umoddi3+0x11c>
  801401:	39 c7                	cmp    %eax,%edi
  801403:	72 23                	jb     801428 <__umoddi3+0x118>
  801405:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801409:	29 c7                	sub    %eax,%edi
  80140b:	19 d6                	sbb    %edx,%esi
  80140d:	89 f0                	mov    %esi,%eax
  80140f:	89 f2                	mov    %esi,%edx
  801411:	d3 ef                	shr    %cl,%edi
  801413:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801417:	d3 e0                	shl    %cl,%eax
  801419:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80141d:	09 f8                	or     %edi,%eax
  80141f:	d3 ea                	shr    %cl,%edx
  801421:	83 c4 20             	add    $0x20,%esp
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
  801428:	39 d6                	cmp    %edx,%esi
  80142a:	75 d9                	jne    801405 <__umoddi3+0xf5>
  80142c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80142f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801432:	eb d1                	jmp    801405 <__umoddi3+0xf5>
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	39 f2                	cmp    %esi,%edx
  80143a:	0f 82 18 ff ff ff    	jb     801358 <__umoddi3+0x48>
  801440:	e9 1d ff ff ff       	jmp    801362 <__umoddi3+0x52>
