
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 1b 02 00 00       	call   80024c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 11 11 00 00       	call   801167 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 80 15 80 	movl   $0x801580,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  800075:	e8 36 02 00 00       	call   8002b0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 5e 10 00 00       	call   8010fc <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a3 15 80 	movl   $0x8015a3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  8000bd:	e8 ee 01 00 00       	call   8002b0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 6b 0b 00 00       	call   800c45 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 a2 0f 00 00       	call   801090 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 b4 15 80 	movl   $0x8015b4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  80010d:	e8 9e 01 00 00       	call   8002b0 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	53                   	push   %ebx
  80011d:	83 ec 24             	sub    $0x24,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800120:	bb 08 00 00 00       	mov    $0x8,%ebx
  800125:	89 d8                	mov    %ebx,%eax
  800127:	cd 30                	int    $0x30
  800129:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	79 20                	jns    80014f <dumbfork+0x36>
		panic("sys_exofork: %e", envid);
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	c7 44 24 08 c7 15 80 	movl   $0x8015c7,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  80014a:	e8 61 01 00 00       	call   8002b0 <_panic>
	if (envid == 0) {
  80014f:	85 c0                	test   %eax,%eax
  800151:	75 19                	jne    80016c <dumbfork+0x53>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800153:	e8 fe 10 00 00       	call   801256 <sys_getenvid>
  800158:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015d:	c1 e0 07             	shl    $0x7,%eax
  800160:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800165:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016a:	eb 7e                	jmp    8001ea <dumbfork+0xd1>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800173:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  800178:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80017d:	76 23                	jbe    8001a2 <dumbfork+0x89>
  80017f:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	89 1c 24             	mov    %ebx,(%esp)
  80018b:	e8 a4 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800190:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800193:	05 00 10 00 00       	add    $0x1000,%eax
  800198:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019b:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  8001a0:	72 e2                	jb     800184 <dumbfork+0x6b>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	89 1c 24             	mov    %ebx,(%esp)
  8001b1:	e8 7e fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001bd:	00 
  8001be:	89 1c 24             	mov    %ebx,(%esp)
  8001c1:	e8 5e 0e 00 00       	call   801024 <sys_env_set_status>
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	79 20                	jns    8001ea <dumbfork+0xd1>
		panic("sys_env_set_status: %e", r);
  8001ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ce:	c7 44 24 08 d7 15 80 	movl   $0x8015d7,0x8(%esp)
  8001d5:	00 
  8001d6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  8001e5:	e8 c6 00 00 00       	call   8002b0 <_panic>

	return envid;
}
  8001ea:	89 d8                	mov    %ebx,%eax
  8001ec:	83 c4 24             	add    $0x24,%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fb:	e8 19 ff ff ff       	call   800119 <dumbfork>
  800200:	89 c6                	mov    %eax,%esi
  800202:	bb 00 00 00 00       	mov    $0x0,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800207:	bf f4 15 80 00       	mov    $0x8015f4,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80020c:	eb 27                	jmp    800235 <umain+0x43>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020e:	89 f8                	mov    %edi,%eax
  800210:	85 f6                	test   %esi,%esi
  800212:	75 05                	jne    800219 <umain+0x27>
  800214:	b8 ee 15 80 00       	mov    $0x8015ee,%eax
  800219:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800221:	c7 04 24 fb 15 80 00 	movl   $0x8015fb,(%esp)
  800228:	e8 54 01 00 00       	call   800381 <cprintf>
		sys_yield();
  80022d:	e8 a2 0f 00 00       	call   8011d4 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800232:	83 c3 01             	add    $0x1,%ebx
  800235:	83 fe 01             	cmp    $0x1,%esi
  800238:	19 c0                	sbb    %eax,%eax
  80023a:	83 e0 0a             	and    $0xa,%eax
  80023d:	83 c0 0a             	add    $0xa,%eax
  800240:	39 c3                	cmp    %eax,%ebx
  800242:	7c ca                	jl     80020e <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800244:	83 c4 1c             	add    $0x1c,%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
  800252:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800255:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800258:	8b 75 08             	mov    0x8(%ebp),%esi
  80025b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80025e:	e8 f3 0f 00 00       	call   801256 <sys_getenvid>
  800263:	25 ff 03 00 00       	and    $0x3ff,%eax
  800268:	c1 e0 07             	shl    $0x7,%eax
  80026b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800270:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800275:	85 f6                	test   %esi,%esi
  800277:	7e 07                	jle    800280 <libmain+0x34>
		binaryname = argv[0];
  800279:	8b 03                	mov    (%ebx),%eax
  80027b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800280:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800284:	89 34 24             	mov    %esi,(%esp)
  800287:	e8 66 ff ff ff       	call   8001f2 <umain>

	// exit gracefully
	exit();
  80028c:	e8 0b 00 00 00       	call   80029c <exit>
}
  800291:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800294:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800297:	89 ec                	mov    %ebp,%esp
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    
	...

0080029c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a9:	e8 e8 0f 00 00       	call   801296 <sys_env_destroy>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002b8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8002bb:	a1 08 20 80 00       	mov    0x802008,%eax
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	74 10                	je     8002d4 <_panic+0x24>
		cprintf("%s: ", argv0);
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	c7 04 24 17 16 80 00 	movl   $0x801617,(%esp)
  8002cf:	e8 ad 00 00 00       	call   800381 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002da:	e8 77 0f 00 00       	call   801256 <sys_getenvid>
  8002df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	c7 04 24 1c 16 80 00 	movl   $0x80161c,(%esp)
  8002fc:	e8 80 00 00 00       	call   800381 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800301:	89 74 24 04          	mov    %esi,0x4(%esp)
  800305:	8b 45 10             	mov    0x10(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 10 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  800310:	c7 04 24 0b 16 80 00 	movl   $0x80160b,(%esp)
  800317:	e8 65 00 00 00       	call   800381 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80031c:	cc                   	int3   
  80031d:	eb fd                	jmp    80031c <_panic+0x6c>
	...

00800320 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	c7 04 24 9b 03 80 00 	movl   $0x80039b,(%esp)
  80035c:	e8 cc 01 00 00       	call   80052d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800361:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	e8 13 0b 00 00       	call   800e8c <sys_cputs>

	return b.cnt;
}
  800379:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037f:	c9                   	leave  
  800380:	c3                   	ret    

00800381 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800387:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80038a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	89 04 24             	mov    %eax,(%esp)
  800394:	e8 87 ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	53                   	push   %ebx
  80039f:	83 ec 14             	sub    $0x14,%esp
  8003a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a5:	8b 03                	mov    (%ebx),%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ae:	83 c0 01             	add    $0x1,%eax
  8003b1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b8:	75 19                	jne    8003d3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003ba:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003c1:	00 
  8003c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	e8 bf 0a 00 00       	call   800e8c <sys_cputs>
		b->idx = 0;
  8003cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003d3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d7:	83 c4 14             	add    $0x14,%esp
  8003da:	5b                   	pop    %ebx
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    
  8003dd:	00 00                	add    %al,(%eax)
	...

008003e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 4c             	sub    $0x4c,%esp
  8003e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ec:	89 d6                	mov    %edx,%esi
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800400:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800403:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	39 d1                	cmp    %edx,%ecx
  80040d:	72 15                	jb     800424 <printnum+0x44>
  80040f:	77 07                	ja     800418 <printnum+0x38>
  800411:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800414:	39 d0                	cmp    %edx,%eax
  800416:	76 0c                	jbe    800424 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800418:	83 eb 01             	sub    $0x1,%ebx
  80041b:	85 db                	test   %ebx,%ebx
  80041d:	8d 76 00             	lea    0x0(%esi),%esi
  800420:	7f 61                	jg     800483 <printnum+0xa3>
  800422:	eb 70                	jmp    800494 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800424:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800428:	83 eb 01             	sub    $0x1,%ebx
  80042b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80042f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800433:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800437:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80043b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800441:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800448:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044f:	00 
  800450:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800459:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045d:	e8 ae 0e 00 00       	call   801310 <__udivdi3>
  800462:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800465:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80046c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	89 54 24 04          	mov    %edx,0x4(%esp)
  800477:	89 f2                	mov    %esi,%edx
  800479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047c:	e8 5f ff ff ff       	call   8003e0 <printnum>
  800481:	eb 11                	jmp    800494 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800483:	89 74 24 04          	mov    %esi,0x4(%esp)
  800487:	89 3c 24             	mov    %edi,(%esp)
  80048a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80048d:	83 eb 01             	sub    $0x1,%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f ef                	jg     800483 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800494:	89 74 24 04          	mov    %esi,0x4(%esp)
  800498:	8b 74 24 04          	mov    0x4(%esp),%esi
  80049c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004aa:	00 
  8004ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ae:	89 14 24             	mov    %edx,(%esp)
  8004b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b8:	e8 83 0f 00 00       	call   801440 <__umoddi3>
  8004bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c1:	0f be 80 40 16 80 00 	movsbl 0x801640(%eax),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004ce:	83 c4 4c             	add    $0x4c,%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d9:	83 fa 01             	cmp    $0x1,%edx
  8004dc:	7e 0e                	jle    8004ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e3:	89 08                	mov    %ecx,(%eax)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ea:	eb 22                	jmp    80050e <getuint+0x38>
	else if (lflag)
  8004ec:	85 d2                	test   %edx,%edx
  8004ee:	74 10                	je     800500 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 02                	mov    (%edx),%eax
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fe:	eb 0e                	jmp    80050e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800500:	8b 10                	mov    (%eax),%edx
  800502:	8d 4a 04             	lea    0x4(%edx),%ecx
  800505:	89 08                	mov    %ecx,(%eax)
  800507:	8b 02                	mov    (%edx),%eax
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800516:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	3b 50 04             	cmp    0x4(%eax),%edx
  80051f:	73 0a                	jae    80052b <sprintputch+0x1b>
		*b->buf++ = ch;
  800521:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800524:	88 0a                	mov    %cl,(%edx)
  800526:	83 c2 01             	add    $0x1,%edx
  800529:	89 10                	mov    %edx,(%eax)
}
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	57                   	push   %edi
  800531:	56                   	push   %esi
  800532:	53                   	push   %ebx
  800533:	83 ec 5c             	sub    $0x5c,%esp
  800536:	8b 7d 08             	mov    0x8(%ebp),%edi
  800539:	8b 75 0c             	mov    0xc(%ebp),%esi
  80053c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80053f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800546:	eb 11                	jmp    800559 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 09 04 00 00    	je     800959 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800550:	89 74 24 04          	mov    %esi,0x4(%esp)
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800559:	0f b6 03             	movzbl (%ebx),%eax
  80055c:	83 c3 01             	add    $0x1,%ebx
  80055f:	83 f8 25             	cmp    $0x25,%eax
  800562:	75 e4                	jne    800548 <vprintfmt+0x1b>
  800564:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800568:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80056f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800576:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80057d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800582:	eb 06                	jmp    80058a <vprintfmt+0x5d>
  800584:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800588:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	0f b6 13             	movzbl (%ebx),%edx
  80058d:	0f b6 c2             	movzbl %dl,%eax
  800590:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800593:	8d 43 01             	lea    0x1(%ebx),%eax
  800596:	83 ea 23             	sub    $0x23,%edx
  800599:	80 fa 55             	cmp    $0x55,%dl
  80059c:	0f 87 9a 03 00 00    	ja     80093c <vprintfmt+0x40f>
  8005a2:	0f b6 d2             	movzbl %dl,%edx
  8005a5:	ff 24 95 00 17 80 00 	jmp    *0x801700(,%edx,4)
  8005ac:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005b0:	eb d6                	jmp    800588 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b5:	83 ea 30             	sub    $0x30,%edx
  8005b8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8005bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005be:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005c1:	83 fb 09             	cmp    $0x9,%ebx
  8005c4:	77 4c                	ja     800612 <vprintfmt+0xe5>
  8005c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005cf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005d2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8005d6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005dc:	83 fb 09             	cmp    $0x9,%ebx
  8005df:	76 eb                	jbe    8005cc <vprintfmt+0x9f>
  8005e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e7:	eb 29                	jmp    800612 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ec:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005ef:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8005f2:	8b 12                	mov    (%edx),%edx
  8005f4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8005f7:	eb 19                	jmp    800612 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8005f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fc:	c1 fa 1f             	sar    $0x1f,%edx
  8005ff:	f7 d2                	not    %edx
  800601:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800604:	eb 82                	jmp    800588 <vprintfmt+0x5b>
  800606:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80060d:	e9 76 ff ff ff       	jmp    800588 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800612:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800616:	0f 89 6c ff ff ff    	jns    800588 <vprintfmt+0x5b>
  80061c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80061f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800622:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800625:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800628:	e9 5b ff ff ff       	jmp    800588 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800630:	e9 53 ff ff ff       	jmp    800588 <vprintfmt+0x5b>
  800635:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	89 74 24 04          	mov    %esi,0x4(%esp)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	ff d7                	call   *%edi
  80064c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80064f:	e9 05 ff ff ff       	jmp    800559 <vprintfmt+0x2c>
  800654:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 c2                	mov    %eax,%edx
  800664:	c1 fa 1f             	sar    $0x1f,%edx
  800667:	31 d0                	xor    %edx,%eax
  800669:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066b:	83 f8 08             	cmp    $0x8,%eax
  80066e:	7f 0b                	jg     80067b <vprintfmt+0x14e>
  800670:	8b 14 85 60 18 80 00 	mov    0x801860(,%eax,4),%edx
  800677:	85 d2                	test   %edx,%edx
  800679:	75 20                	jne    80069b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80067b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067f:	c7 44 24 08 51 16 80 	movl   $0x801651,0x8(%esp)
  800686:	00 
  800687:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068b:	89 3c 24             	mov    %edi,(%esp)
  80068e:	e8 4e 03 00 00       	call   8009e1 <printfmt>
  800693:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800696:	e9 be fe ff ff       	jmp    800559 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80069b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069f:	c7 44 24 08 5a 16 80 	movl   $0x80165a,0x8(%esp)
  8006a6:	00 
  8006a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ab:	89 3c 24             	mov    %edi,(%esp)
  8006ae:	e8 2e 03 00 00       	call   8009e1 <printfmt>
  8006b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b6:	e9 9e fe ff ff       	jmp    800559 <vprintfmt+0x2c>
  8006bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006be:	89 c3                	mov    %eax,%ebx
  8006c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	75 07                	jne    8006e2 <vprintfmt+0x1b5>
  8006db:	c7 45 c4 5d 16 80 00 	movl   $0x80165d,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006e2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8006e6:	7e 06                	jle    8006ee <vprintfmt+0x1c1>
  8006e8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006ec:	75 13                	jne    800701 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f1:	0f be 02             	movsbl (%edx),%eax
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	0f 85 99 00 00 00    	jne    800795 <vprintfmt+0x268>
  8006fc:	e9 86 00 00 00       	jmp    800787 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800701:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800705:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800708:	89 0c 24             	mov    %ecx,(%esp)
  80070b:	e8 1b 03 00 00       	call   800a2b <strnlen>
  800710:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800713:	29 c2                	sub    %eax,%edx
  800715:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e d2                	jle    8006ee <vprintfmt+0x1c1>
					putch(padc, putdat);
  80071c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800720:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800723:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800726:	89 d3                	mov    %edx,%ebx
  800728:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	83 eb 01             	sub    $0x1,%ebx
  800737:	85 db                	test   %ebx,%ebx
  800739:	7f ed                	jg     800728 <vprintfmt+0x1fb>
  80073b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80073e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800745:	eb a7                	jmp    8006ee <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800747:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80074b:	74 18                	je     800765 <vprintfmt+0x238>
  80074d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800750:	83 fa 5e             	cmp    $0x5e,%edx
  800753:	76 10                	jbe    800765 <vprintfmt+0x238>
					putch('?', putdat);
  800755:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800759:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800760:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800763:	eb 0a                	jmp    80076f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	89 04 24             	mov    %eax,(%esp)
  80076c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800773:	0f be 03             	movsbl (%ebx),%eax
  800776:	85 c0                	test   %eax,%eax
  800778:	74 05                	je     80077f <vprintfmt+0x252>
  80077a:	83 c3 01             	add    $0x1,%ebx
  80077d:	eb 29                	jmp    8007a8 <vprintfmt+0x27b>
  80077f:	89 fe                	mov    %edi,%esi
  800781:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800784:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800787:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80078b:	7f 2e                	jg     8007bb <vprintfmt+0x28e>
  80078d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800790:	e9 c4 fd ff ff       	jmp    800559 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800795:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800798:	83 c2 01             	add    $0x1,%edx
  80079b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80079e:	89 f7                	mov    %esi,%edi
  8007a0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007a3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007a6:	89 d3                	mov    %edx,%ebx
  8007a8:	85 f6                	test   %esi,%esi
  8007aa:	78 9b                	js     800747 <vprintfmt+0x21a>
  8007ac:	83 ee 01             	sub    $0x1,%esi
  8007af:	79 96                	jns    800747 <vprintfmt+0x21a>
  8007b1:	89 fe                	mov    %edi,%esi
  8007b3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007b6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8007b9:	eb cc                	jmp    800787 <vprintfmt+0x25a>
  8007bb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007cc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ce:	83 eb 01             	sub    $0x1,%ebx
  8007d1:	85 db                	test   %ebx,%ebx
  8007d3:	7f ec                	jg     8007c1 <vprintfmt+0x294>
  8007d5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007d8:	e9 7c fd ff ff       	jmp    800559 <vprintfmt+0x2c>
  8007dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e0:	83 f9 01             	cmp    $0x1,%ecx
  8007e3:	7e 16                	jle    8007fb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 08             	lea    0x8(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ee:	8b 10                	mov    (%eax),%edx
  8007f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8007f6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8007f9:	eb 32                	jmp    80082d <vprintfmt+0x300>
	else if (lflag)
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	74 18                	je     800817 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 04             	lea    0x4(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80080d:	89 c1                	mov    %eax,%ecx
  80080f:	c1 f9 1f             	sar    $0x1f,%ecx
  800812:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800815:	eb 16                	jmp    80082d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 00                	mov    (%eax),%eax
  800822:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800825:	89 c2                	mov    %eax,%edx
  800827:	c1 fa 1f             	sar    $0x1f,%edx
  80082a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80082d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800830:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800833:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800838:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80083c:	0f 89 b8 00 00 00    	jns    8008fa <vprintfmt+0x3cd>
				putch('-', putdat);
  800842:	89 74 24 04          	mov    %esi,0x4(%esp)
  800846:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80084d:	ff d7                	call   *%edi
				num = -(long long) num;
  80084f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800852:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800855:	f7 d9                	neg    %ecx
  800857:	83 d3 00             	adc    $0x0,%ebx
  80085a:	f7 db                	neg    %ebx
  80085c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800861:	e9 94 00 00 00       	jmp    8008fa <vprintfmt+0x3cd>
  800866:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800869:	89 ca                	mov    %ecx,%edx
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 63 fc ff ff       	call   8004d6 <getuint>
  800873:	89 c1                	mov    %eax,%ecx
  800875:	89 d3                	mov    %edx,%ebx
  800877:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80087c:	eb 7c                	jmp    8008fa <vprintfmt+0x3cd>
  80087e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800881:	89 74 24 04          	mov    %esi,0x4(%esp)
  800885:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80088c:	ff d7                	call   *%edi
			putch('X', putdat);
  80088e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800892:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800899:	ff d7                	call   *%edi
			putch('X', putdat);
  80089b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80089f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008a6:	ff d7                	call   *%edi
  8008a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8008ab:	e9 a9 fc ff ff       	jmp    800559 <vprintfmt+0x2c>
  8008b0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008be:	ff d7                	call   *%edi
			putch('x', putdat);
  8008c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008cb:	ff d7                	call   *%edi
			num = (unsigned long long)
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 50 04             	lea    0x4(%eax),%edx
  8008d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d6:	8b 08                	mov    (%eax),%ecx
  8008d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008dd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008e2:	eb 16                	jmp    8008fa <vprintfmt+0x3cd>
  8008e4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008e7:	89 ca                	mov    %ecx,%edx
  8008e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ec:	e8 e5 fb ff ff       	call   8004d6 <getuint>
  8008f1:	89 c1                	mov    %eax,%ecx
  8008f3:	89 d3                	mov    %edx,%ebx
  8008f5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008fa:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8008fe:	89 54 24 10          	mov    %edx,0x10(%esp)
  800902:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800905:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800909:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090d:	89 0c 24             	mov    %ecx,(%esp)
  800910:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800914:	89 f2                	mov    %esi,%edx
  800916:	89 f8                	mov    %edi,%eax
  800918:	e8 c3 fa ff ff       	call   8003e0 <printnum>
  80091d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800920:	e9 34 fc ff ff       	jmp    800559 <vprintfmt+0x2c>
  800925:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800928:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80092b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092f:	89 14 24             	mov    %edx,(%esp)
  800932:	ff d7                	call   *%edi
  800934:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800937:	e9 1d fc ff ff       	jmp    800559 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80093c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800940:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800947:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800949:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80094c:	80 38 25             	cmpb   $0x25,(%eax)
  80094f:	0f 84 04 fc ff ff    	je     800559 <vprintfmt+0x2c>
  800955:	89 c3                	mov    %eax,%ebx
  800957:	eb f0                	jmp    800949 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800959:	83 c4 5c             	add    $0x5c,%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 28             	sub    $0x28,%esp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80096d:	85 c0                	test   %eax,%eax
  80096f:	74 04                	je     800975 <vsnprintf+0x14>
  800971:	85 d2                	test   %edx,%edx
  800973:	7f 07                	jg     80097c <vsnprintf+0x1b>
  800975:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80097a:	eb 3b                	jmp    8009b7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800983:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800986:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
  800997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	c7 04 24 10 05 80 00 	movl   $0x800510,(%esp)
  8009a9:	e8 7f fb ff ff       	call   80052d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 82 ff ff ff       	call   800961 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009e7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	89 04 24             	mov    %eax,(%esp)
  800a02:	e8 26 fb ff ff       	call   80052d <vprintfmt>
	va_end(ap);
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    
  800a09:	00 00                	add    %al,(%eax)
  800a0b:	00 00                	add    %al,(%eax)
  800a0d:	00 00                	add    %al,(%eax)
	...

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1e:	74 09                	je     800a29 <strlen+0x19>
		n++;
  800a20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a27:	75 f7                	jne    800a20 <strlen+0x10>
		n++;
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 19                	je     800a52 <strnlen+0x27>
  800a39:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a3c:	74 14                	je     800a52 <strnlen+0x27>
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a43:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a46:	39 c8                	cmp    %ecx,%eax
  800a48:	74 0d                	je     800a57 <strnlen+0x2c>
  800a4a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a4e:	75 f3                	jne    800a43 <strnlen+0x18>
  800a50:	eb 05                	jmp    800a57 <strnlen+0x2c>
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	84 c9                	test   %cl,%cl
  800a75:	75 f2                	jne    800a69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	89 1c 24             	mov    %ebx,(%esp)
  800a87:	e8 84 ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a93:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	e8 bc ff ff ff       	call   800a5a <strcpy>
	return dst;
}
  800a9e:	89 d8                	mov    %ebx,%eax
  800aa0:	83 c4 08             	add    $0x8,%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab4:	85 f6                	test   %esi,%esi
  800ab6:	74 18                	je     800ad0 <strncpy+0x2a>
  800ab8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800abd:	0f b6 1a             	movzbl (%edx),%ebx
  800ac0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	39 ce                	cmp    %ecx,%esi
  800ace:	77 ed                	ja     800abd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae2:	89 f0                	mov    %esi,%eax
  800ae4:	85 c9                	test   %ecx,%ecx
  800ae6:	74 27                	je     800b0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ae8:	83 e9 01             	sub    $0x1,%ecx
  800aeb:	74 1d                	je     800b0a <strlcpy+0x36>
  800aed:	0f b6 1a             	movzbl (%edx),%ebx
  800af0:	84 db                	test   %bl,%bl
  800af2:	74 16                	je     800b0a <strlcpy+0x36>
			*dst++ = *src++;
  800af4:	88 18                	mov    %bl,(%eax)
  800af6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af9:	83 e9 01             	sub    $0x1,%ecx
  800afc:	74 0e                	je     800b0c <strlcpy+0x38>
			*dst++ = *src++;
  800afe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b01:	0f b6 1a             	movzbl (%edx),%ebx
  800b04:	84 db                	test   %bl,%bl
  800b06:	75 ec                	jne    800af4 <strlcpy+0x20>
  800b08:	eb 02                	jmp    800b0c <strlcpy+0x38>
  800b0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b0c:	c6 00 00             	movb   $0x0,(%eax)
  800b0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1e:	0f b6 01             	movzbl (%ecx),%eax
  800b21:	84 c0                	test   %al,%al
  800b23:	74 15                	je     800b3a <strcmp+0x25>
  800b25:	3a 02                	cmp    (%edx),%al
  800b27:	75 11                	jne    800b3a <strcmp+0x25>
		p++, q++;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	84 c0                	test   %al,%al
  800b34:	74 04                	je     800b3a <strcmp+0x25>
  800b36:	3a 02                	cmp    (%edx),%al
  800b38:	74 ef                	je     800b29 <strcmp+0x14>
  800b3a:	0f b6 c0             	movzbl %al,%eax
  800b3d:	0f b6 12             	movzbl (%edx),%edx
  800b40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	74 23                	je     800b78 <strncmp+0x34>
  800b55:	0f b6 1a             	movzbl (%edx),%ebx
  800b58:	84 db                	test   %bl,%bl
  800b5a:	74 25                	je     800b81 <strncmp+0x3d>
  800b5c:	3a 19                	cmp    (%ecx),%bl
  800b5e:	75 21                	jne    800b81 <strncmp+0x3d>
  800b60:	83 e8 01             	sub    $0x1,%eax
  800b63:	74 13                	je     800b78 <strncmp+0x34>
		n--, p++, q++;
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6b:	0f b6 1a             	movzbl (%edx),%ebx
  800b6e:	84 db                	test   %bl,%bl
  800b70:	74 0f                	je     800b81 <strncmp+0x3d>
  800b72:	3a 19                	cmp    (%ecx),%bl
  800b74:	74 ea                	je     800b60 <strncmp+0x1c>
  800b76:	eb 09                	jmp    800b81 <strncmp+0x3d>
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5d                   	pop    %ebp
  800b7f:	90                   	nop
  800b80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b81:	0f b6 02             	movzbl (%edx),%eax
  800b84:	0f b6 11             	movzbl (%ecx),%edx
  800b87:	29 d0                	sub    %edx,%eax
  800b89:	eb f2                	jmp    800b7d <strncmp+0x39>

00800b8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	74 18                	je     800bb4 <strchr+0x29>
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	75 0a                	jne    800baa <strchr+0x1f>
  800ba0:	eb 17                	jmp    800bb9 <strchr+0x2e>
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ba8:	74 0f                	je     800bb9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	0f b6 10             	movzbl (%eax),%edx
  800bb0:	84 d2                	test   %dl,%dl
  800bb2:	75 ee                	jne    800ba2 <strchr+0x17>
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	0f b6 10             	movzbl (%eax),%edx
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 18                	je     800be4 <strfind+0x29>
		if (*s == c)
  800bcc:	38 ca                	cmp    %cl,%dl
  800bce:	75 0a                	jne    800bda <strfind+0x1f>
  800bd0:	eb 12                	jmp    800be4 <strfind+0x29>
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bd8:	74 0a                	je     800be4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
  800be0:	84 d2                	test   %dl,%dl
  800be2:	75 ee                	jne    800bd2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	89 1c 24             	mov    %ebx,(%esp)
  800bef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	74 30                	je     800c34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0a:	75 25                	jne    800c31 <memset+0x4b>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 20                	jne    800c31 <memset+0x4b>
		c &= 0xFF;
  800c11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	c1 e3 08             	shl    $0x8,%ebx
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	c1 e6 18             	shl    $0x18,%esi
  800c1e:	89 d0                	mov    %edx,%eax
  800c20:	c1 e0 10             	shl    $0x10,%eax
  800c23:	09 f0                	or     %esi,%eax
  800c25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c27:	09 d8                	or     %ebx,%eax
  800c29:	c1 e9 02             	shr    $0x2,%ecx
  800c2c:	fc                   	cld    
  800c2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2f:	eb 03                	jmp    800c34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c31:	fc                   	cld    
  800c32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	8b 1c 24             	mov    (%esp),%ebx
  800c39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	89 34 24             	mov    %esi,(%esp)
  800c4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c5d:	39 c6                	cmp    %eax,%esi
  800c5f:	73 35                	jae    800c96 <memmove+0x51>
  800c61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	73 2e                	jae    800c96 <memmove+0x51>
		s += n;
		d += n;
  800c68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6a:	f6 c2 03             	test   $0x3,%dl
  800c6d:	75 1b                	jne    800c8a <memmove+0x45>
  800c6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c75:	75 13                	jne    800c8a <memmove+0x45>
  800c77:	f6 c1 03             	test   $0x3,%cl
  800c7a:	75 0e                	jne    800c8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c7c:	83 ef 04             	sub    $0x4,%edi
  800c7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c82:	c1 e9 02             	shr    $0x2,%ecx
  800c85:	fd                   	std    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c88:	eb 09                	jmp    800c93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c90:	fd                   	std    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c94:	eb 20                	jmp    800cb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c9c:	75 15                	jne    800cb3 <memmove+0x6e>
  800c9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca4:	75 0d                	jne    800cb3 <memmove+0x6e>
  800ca6:	f6 c1 03             	test   $0x3,%cl
  800ca9:	75 08                	jne    800cb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cab:	c1 e9 02             	shr    $0x2,%ecx
  800cae:	fc                   	cld    
  800caf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb1:	eb 03                	jmp    800cb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cb3:	fc                   	cld    
  800cb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb6:	8b 34 24             	mov    (%esp),%esi
  800cb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cbd:	89 ec                	mov    %ebp,%esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 65 ff ff ff       	call   800c45 <memmove>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ceb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf1:	85 c9                	test   %ecx,%ecx
  800cf3:	74 36                	je     800d2b <memcmp+0x49>
		if (*s1 != *s2)
  800cf5:	0f b6 06             	movzbl (%esi),%eax
  800cf8:	0f b6 1f             	movzbl (%edi),%ebx
  800cfb:	38 d8                	cmp    %bl,%al
  800cfd:	74 20                	je     800d1f <memcmp+0x3d>
  800cff:	eb 14                	jmp    800d15 <memcmp+0x33>
  800d01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d0b:	83 c2 01             	add    $0x1,%edx
  800d0e:	83 e9 01             	sub    $0x1,%ecx
  800d11:	38 d8                	cmp    %bl,%al
  800d13:	74 12                	je     800d27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 db             	movzbl %bl,%ebx
  800d1b:	29 d8                	sub    %ebx,%eax
  800d1d:	eb 11                	jmp    800d30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1f:	83 e9 01             	sub    $0x1,%ecx
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	85 c9                	test   %ecx,%ecx
  800d29:	75 d6                	jne    800d01 <memcmp+0x1f>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d40:	39 d0                	cmp    %edx,%eax
  800d42:	73 15                	jae    800d59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d48:	38 08                	cmp    %cl,(%eax)
  800d4a:	75 06                	jne    800d52 <memfind+0x1d>
  800d4c:	eb 0b                	jmp    800d59 <memfind+0x24>
  800d4e:	38 08                	cmp    %cl,(%eax)
  800d50:	74 07                	je     800d59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d52:	83 c0 01             	add    $0x1,%eax
  800d55:	39 c2                	cmp    %eax,%edx
  800d57:	77 f5                	ja     800d4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6a:	0f b6 02             	movzbl (%edx),%eax
  800d6d:	3c 20                	cmp    $0x20,%al
  800d6f:	74 04                	je     800d75 <strtol+0x1a>
  800d71:	3c 09                	cmp    $0x9,%al
  800d73:	75 0e                	jne    800d83 <strtol+0x28>
		s++;
  800d75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d78:	0f b6 02             	movzbl (%edx),%eax
  800d7b:	3c 20                	cmp    $0x20,%al
  800d7d:	74 f6                	je     800d75 <strtol+0x1a>
  800d7f:	3c 09                	cmp    $0x9,%al
  800d81:	74 f2                	je     800d75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d83:	3c 2b                	cmp    $0x2b,%al
  800d85:	75 0c                	jne    800d93 <strtol+0x38>
		s++;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d91:	eb 15                	jmp    800da8 <strtol+0x4d>
	else if (*s == '-')
  800d93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d9a:	3c 2d                	cmp    $0x2d,%al
  800d9c:	75 0a                	jne    800da8 <strtol+0x4d>
		s++, neg = 1;
  800d9e:	83 c2 01             	add    $0x1,%edx
  800da1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	85 db                	test   %ebx,%ebx
  800daa:	0f 94 c0             	sete   %al
  800dad:	74 05                	je     800db4 <strtol+0x59>
  800daf:	83 fb 10             	cmp    $0x10,%ebx
  800db2:	75 18                	jne    800dcc <strtol+0x71>
  800db4:	80 3a 30             	cmpb   $0x30,(%edx)
  800db7:	75 13                	jne    800dcc <strtol+0x71>
  800db9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	75 0a                	jne    800dcc <strtol+0x71>
		s += 2, base = 16;
  800dc2:	83 c2 02             	add    $0x2,%edx
  800dc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dca:	eb 15                	jmp    800de1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcc:	84 c0                	test   %al,%al
  800dce:	66 90                	xchg   %ax,%ax
  800dd0:	74 0f                	je     800de1 <strtol+0x86>
  800dd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dda:	75 05                	jne    800de1 <strtol+0x86>
		s++, base = 8;
  800ddc:	83 c2 01             	add    $0x1,%edx
  800ddf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
  800de6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de8:	0f b6 0a             	movzbl (%edx),%ecx
  800deb:	89 cf                	mov    %ecx,%edi
  800ded:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800df0:	80 fb 09             	cmp    $0x9,%bl
  800df3:	77 08                	ja     800dfd <strtol+0xa2>
			dig = *s - '0';
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 30             	sub    $0x30,%ecx
  800dfb:	eb 1e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e00:	80 fb 19             	cmp    $0x19,%bl
  800e03:	77 08                	ja     800e0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e05:	0f be c9             	movsbl %cl,%ecx
  800e08:	83 e9 57             	sub    $0x57,%ecx
  800e0b:	eb 0e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e10:	80 fb 19             	cmp    $0x19,%bl
  800e13:	77 15                	ja     800e2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e15:	0f be c9             	movsbl %cl,%ecx
  800e18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e1b:	39 f1                	cmp    %esi,%ecx
  800e1d:	7d 0b                	jge    800e2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e1f:	83 c2 01             	add    $0x1,%edx
  800e22:	0f af c6             	imul   %esi,%eax
  800e25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e28:	eb be                	jmp    800de8 <strtol+0x8d>
  800e2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e30:	74 05                	je     800e37 <strtol+0xdc>
		*endptr = (char *) s;
  800e32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e3b:	74 04                	je     800e41 <strtol+0xe6>
  800e3d:	89 c8                	mov    %ecx,%eax
  800e3f:	f7 d8                	neg    %eax
}
  800e41:	83 c4 04             	add    $0x4,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	89 1c 24             	mov    %ebx,(%esp)
  800e55:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	89 d1                	mov    %edx,%ecx
  800e65:	89 d3                	mov    %edx,%ebx
  800e67:	89 d7                	mov    %edx,%edi
  800e69:	51                   	push   %ecx
  800e6a:	52                   	push   %edx
  800e6b:	53                   	push   %ebx
  800e6c:	54                   	push   %esp
  800e6d:	55                   	push   %ebp
  800e6e:	56                   	push   %esi
  800e6f:	57                   	push   %edi
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	8d 35 7a 0e 80 00    	lea    0x800e7a,%esi
  800e78:	0f 34                	sysenter 
  800e7a:	5f                   	pop    %edi
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	5c                   	pop    %esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5a                   	pop    %edx
  800e80:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e81:	8b 1c 24             	mov    (%esp),%ebx
  800e84:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	89 1c 24             	mov    %ebx,(%esp)
  800e95:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	89 c7                	mov    %eax,%edi
  800ea8:	51                   	push   %ecx
  800ea9:	52                   	push   %edx
  800eaa:	53                   	push   %ebx
  800eab:	54                   	push   %esp
  800eac:	55                   	push   %ebp
  800ead:	56                   	push   %esi
  800eae:	57                   	push   %edi
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	8d 35 b9 0e 80 00    	lea    0x800eb9,%esi
  800eb7:	0f 34                	sysenter 
  800eb9:	5f                   	pop    %edi
  800eba:	5e                   	pop    %esi
  800ebb:	5d                   	pop    %ebp
  800ebc:	5c                   	pop    %esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5a                   	pop    %edx
  800ebf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ec0:	8b 1c 24             	mov    (%esp),%ebx
  800ec3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec7:	89 ec                	mov    %ebp,%esp
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	89 1c 24             	mov    %ebx,(%esp)
  800ed4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f01:	8b 1c 24             	mov    (%esp),%ebx
  800f04:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
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
  800f18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 cb                	mov    %ecx,%ebx
  800f27:	89 cf                	mov    %ecx,%edi
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
  800f43:	7e 28                	jle    800f6d <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f49:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f50:	00 
  800f51:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800f58:	00 
  800f59:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800f60:	00 
  800f61:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800f68:	e8 43 f3 ff ff       	call   8002b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f73:	89 ec                	mov    %ebp,%esp
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	89 1c 24             	mov    %ebx,(%esp)
  800f80:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f84:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	51                   	push   %ecx
  800f96:	52                   	push   %edx
  800f97:	53                   	push   %ebx
  800f98:	54                   	push   %esp
  800f99:	55                   	push   %ebp
  800f9a:	56                   	push   %esi
  800f9b:	57                   	push   %edi
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	8d 35 a6 0f 80 00    	lea    0x800fa6,%esi
  800fa4:	0f 34                	sysenter 
  800fa6:	5f                   	pop    %edi
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	5c                   	pop    %esp
  800faa:	5b                   	pop    %ebx
  800fab:	5a                   	pop    %edx
  800fac:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fad:	8b 1c 24             	mov    (%esp),%ebx
  800fb0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb4:	89 ec                	mov    %ebp,%esp
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 28             	sub    $0x28,%esp
  800fbe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd4:	89 df                	mov    %ebx,%edi
  800fd6:	51                   	push   %ecx
  800fd7:	52                   	push   %edx
  800fd8:	53                   	push   %ebx
  800fd9:	54                   	push   %esp
  800fda:	55                   	push   %ebp
  800fdb:	56                   	push   %esi
  800fdc:	57                   	push   %edi
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	8d 35 e7 0f 80 00    	lea    0x800fe7,%esi
  800fe5:	0f 34                	sysenter 
  800fe7:	5f                   	pop    %edi
  800fe8:	5e                   	pop    %esi
  800fe9:	5d                   	pop    %ebp
  800fea:	5c                   	pop    %esp
  800feb:	5b                   	pop    %ebx
  800fec:	5a                   	pop    %edx
  800fed:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 28                	jle    80101a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff6:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  801005:	00 
  801006:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80100d:	00 
  80100e:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  801015:	e8 96 f2 ff ff       	call   8002b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80101a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80101d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 28             	sub    $0x28,%esp
  80102a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80102d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801030:	bb 00 00 00 00       	mov    $0x0,%ebx
  801035:	b8 09 00 00 00       	mov    $0x9,%eax
  80103a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	89 df                	mov    %ebx,%edi
  801042:	51                   	push   %ecx
  801043:	52                   	push   %edx
  801044:	53                   	push   %ebx
  801045:	54                   	push   %esp
  801046:	55                   	push   %ebp
  801047:	56                   	push   %esi
  801048:	57                   	push   %edi
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	8d 35 53 10 80 00    	lea    0x801053,%esi
  801051:	0f 34                	sysenter 
  801053:	5f                   	pop    %edi
  801054:	5e                   	pop    %esi
  801055:	5d                   	pop    %ebp
  801056:	5c                   	pop    %esp
  801057:	5b                   	pop    %ebx
  801058:	5a                   	pop    %edx
  801059:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80105a:	85 c0                	test   %eax,%eax
  80105c:	7e 28                	jle    801086 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801062:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801069:	00 
  80106a:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  801071:	00 
  801072:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801079:	00 
  80107a:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  801081:	e8 2a f2 ff ff       	call   8002b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801086:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801089:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108c:	89 ec                	mov    %ebp,%esp
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 28             	sub    $0x28,%esp
  801096:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801099:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80109c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a1:	b8 07 00 00 00       	mov    $0x7,%eax
  8010a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	89 df                	mov    %ebx,%edi
  8010ae:	51                   	push   %ecx
  8010af:	52                   	push   %edx
  8010b0:	53                   	push   %ebx
  8010b1:	54                   	push   %esp
  8010b2:	55                   	push   %ebp
  8010b3:	56                   	push   %esi
  8010b4:	57                   	push   %edi
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	8d 35 bf 10 80 00    	lea    0x8010bf,%esi
  8010bd:	0f 34                	sysenter 
  8010bf:	5f                   	pop    %edi
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	5c                   	pop    %esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5a                   	pop    %edx
  8010c5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	7e 28                	jle    8010f2 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ce:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  8010dd:	00 
  8010de:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8010e5:	00 
  8010e6:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  8010ed:	e8 be f1 ff ff       	call   8002b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010f2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f8:	89 ec                	mov    %ebp,%esp
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 28             	sub    $0x28,%esp
  801102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801105:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801108:	b8 06 00 00 00       	mov    $0x6,%eax
  80110d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801110:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801113:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801116:	8b 55 08             	mov    0x8(%ebp),%edx
  801119:	51                   	push   %ecx
  80111a:	52                   	push   %edx
  80111b:	53                   	push   %ebx
  80111c:	54                   	push   %esp
  80111d:	55                   	push   %ebp
  80111e:	56                   	push   %esi
  80111f:	57                   	push   %edi
  801120:	89 e5                	mov    %esp,%ebp
  801122:	8d 35 2a 11 80 00    	lea    0x80112a,%esi
  801128:	0f 34                	sysenter 
  80112a:	5f                   	pop    %edi
  80112b:	5e                   	pop    %esi
  80112c:	5d                   	pop    %ebp
  80112d:	5c                   	pop    %esp
  80112e:	5b                   	pop    %ebx
  80112f:	5a                   	pop    %edx
  801130:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801131:	85 c0                	test   %eax,%eax
  801133:	7e 28                	jle    80115d <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801135:	89 44 24 10          	mov    %eax,0x10(%esp)
  801139:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801140:	00 
  801141:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  801148:	00 
  801149:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  801158:	e8 53 f1 ff ff       	call   8002b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80115d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801160:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801163:	89 ec                	mov    %ebp,%esp
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 28             	sub    $0x28,%esp
  80116d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801170:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801173:	bf 00 00 00 00       	mov    $0x0,%edi
  801178:	b8 05 00 00 00       	mov    $0x5,%eax
  80117d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801183:	8b 55 08             	mov    0x8(%ebp),%edx
  801186:	51                   	push   %ecx
  801187:	52                   	push   %edx
  801188:	53                   	push   %ebx
  801189:	54                   	push   %esp
  80118a:	55                   	push   %ebp
  80118b:	56                   	push   %esi
  80118c:	57                   	push   %edi
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	8d 35 97 11 80 00    	lea    0x801197,%esi
  801195:	0f 34                	sysenter 
  801197:	5f                   	pop    %edi
  801198:	5e                   	pop    %esi
  801199:	5d                   	pop    %ebp
  80119a:	5c                   	pop    %esp
  80119b:	5b                   	pop    %ebx
  80119c:	5a                   	pop    %edx
  80119d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	7e 28                	jle    8011ca <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011ad:	00 
  8011ae:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8011bd:	00 
  8011be:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  8011c5:	e8 e6 f0 ff ff       	call   8002b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d0:	89 ec                	mov    %ebp,%esp
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	89 1c 24             	mov    %ebx,(%esp)
  8011dd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011eb:	89 d1                	mov    %edx,%ecx
  8011ed:	89 d3                	mov    %edx,%ebx
  8011ef:	89 d7                	mov    %edx,%edi
  8011f1:	51                   	push   %ecx
  8011f2:	52                   	push   %edx
  8011f3:	53                   	push   %ebx
  8011f4:	54                   	push   %esp
  8011f5:	55                   	push   %ebp
  8011f6:	56                   	push   %esi
  8011f7:	57                   	push   %edi
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	8d 35 02 12 80 00    	lea    0x801202,%esi
  801200:	0f 34                	sysenter 
  801202:	5f                   	pop    %edi
  801203:	5e                   	pop    %esi
  801204:	5d                   	pop    %ebp
  801205:	5c                   	pop    %esp
  801206:	5b                   	pop    %ebx
  801207:	5a                   	pop    %edx
  801208:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801209:	8b 1c 24             	mov    (%esp),%ebx
  80120c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801210:	89 ec                	mov    %ebp,%esp
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	89 1c 24             	mov    %ebx,(%esp)
  80121d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801221:	bb 00 00 00 00       	mov    $0x0,%ebx
  801226:	b8 04 00 00 00       	mov    $0x4,%eax
  80122b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122e:	8b 55 08             	mov    0x8(%ebp),%edx
  801231:	89 df                	mov    %ebx,%edi
  801233:	51                   	push   %ecx
  801234:	52                   	push   %edx
  801235:	53                   	push   %ebx
  801236:	54                   	push   %esp
  801237:	55                   	push   %ebp
  801238:	56                   	push   %esi
  801239:	57                   	push   %edi
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	8d 35 44 12 80 00    	lea    0x801244,%esi
  801242:	0f 34                	sysenter 
  801244:	5f                   	pop    %edi
  801245:	5e                   	pop    %esi
  801246:	5d                   	pop    %ebp
  801247:	5c                   	pop    %esp
  801248:	5b                   	pop    %ebx
  801249:	5a                   	pop    %edx
  80124a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80124b:	8b 1c 24             	mov    (%esp),%ebx
  80124e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801252:	89 ec                	mov    %ebp,%esp
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 08             	sub    $0x8,%esp
  80125c:	89 1c 24             	mov    %ebx,(%esp)
  80125f:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801263:	ba 00 00 00 00       	mov    $0x0,%edx
  801268:	b8 02 00 00 00       	mov    $0x2,%eax
  80126d:	89 d1                	mov    %edx,%ecx
  80126f:	89 d3                	mov    %edx,%ebx
  801271:	89 d7                	mov    %edx,%edi
  801273:	51                   	push   %ecx
  801274:	52                   	push   %edx
  801275:	53                   	push   %ebx
  801276:	54                   	push   %esp
  801277:	55                   	push   %ebp
  801278:	56                   	push   %esi
  801279:	57                   	push   %edi
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	8d 35 84 12 80 00    	lea    0x801284,%esi
  801282:	0f 34                	sysenter 
  801284:	5f                   	pop    %edi
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	5c                   	pop    %esp
  801288:	5b                   	pop    %ebx
  801289:	5a                   	pop    %edx
  80128a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80128b:	8b 1c 24             	mov    (%esp),%ebx
  80128e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801292:	89 ec                	mov    %ebp,%esp
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 28             	sub    $0x28,%esp
  80129c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80129f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8012af:	89 cb                	mov    %ecx,%ebx
  8012b1:	89 cf                	mov    %ecx,%edi
  8012b3:	51                   	push   %ecx
  8012b4:	52                   	push   %edx
  8012b5:	53                   	push   %ebx
  8012b6:	54                   	push   %esp
  8012b7:	55                   	push   %ebp
  8012b8:	56                   	push   %esi
  8012b9:	57                   	push   %edi
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	8d 35 c4 12 80 00    	lea    0x8012c4,%esi
  8012c2:	0f 34                	sysenter 
  8012c4:	5f                   	pop    %edi
  8012c5:	5e                   	pop    %esi
  8012c6:	5d                   	pop    %ebp
  8012c7:	5c                   	pop    %esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5a                   	pop    %edx
  8012ca:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	7e 28                	jle    8012f7 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8012da:	00 
  8012db:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8012ea:	00 
  8012eb:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  8012f2:	e8 b9 ef ff ff       	call   8002b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012f7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012fd:	89 ec                	mov    %ebp,%esp
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    
	...

00801310 <__udivdi3>:
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	57                   	push   %edi
  801314:	56                   	push   %esi
  801315:	83 ec 10             	sub    $0x10,%esp
  801318:	8b 45 14             	mov    0x14(%ebp),%eax
  80131b:	8b 55 08             	mov    0x8(%ebp),%edx
  80131e:	8b 75 10             	mov    0x10(%ebp),%esi
  801321:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801324:	85 c0                	test   %eax,%eax
  801326:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801329:	75 35                	jne    801360 <__udivdi3+0x50>
  80132b:	39 fe                	cmp    %edi,%esi
  80132d:	77 61                	ja     801390 <__udivdi3+0x80>
  80132f:	85 f6                	test   %esi,%esi
  801331:	75 0b                	jne    80133e <__udivdi3+0x2e>
  801333:	b8 01 00 00 00       	mov    $0x1,%eax
  801338:	31 d2                	xor    %edx,%edx
  80133a:	f7 f6                	div    %esi
  80133c:	89 c6                	mov    %eax,%esi
  80133e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801341:	31 d2                	xor    %edx,%edx
  801343:	89 f8                	mov    %edi,%eax
  801345:	f7 f6                	div    %esi
  801347:	89 c7                	mov    %eax,%edi
  801349:	89 c8                	mov    %ecx,%eax
  80134b:	f7 f6                	div    %esi
  80134d:	89 c1                	mov    %eax,%ecx
  80134f:	89 fa                	mov    %edi,%edx
  801351:	89 c8                	mov    %ecx,%eax
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    
  80135a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801360:	39 f8                	cmp    %edi,%eax
  801362:	77 1c                	ja     801380 <__udivdi3+0x70>
  801364:	0f bd d0             	bsr    %eax,%edx
  801367:	83 f2 1f             	xor    $0x1f,%edx
  80136a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80136d:	75 39                	jne    8013a8 <__udivdi3+0x98>
  80136f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801372:	0f 86 a0 00 00 00    	jbe    801418 <__udivdi3+0x108>
  801378:	39 f8                	cmp    %edi,%eax
  80137a:	0f 82 98 00 00 00    	jb     801418 <__udivdi3+0x108>
  801380:	31 ff                	xor    %edi,%edi
  801382:	31 c9                	xor    %ecx,%ecx
  801384:	89 c8                	mov    %ecx,%eax
  801386:	89 fa                	mov    %edi,%edx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	5e                   	pop    %esi
  80138c:	5f                   	pop    %edi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    
  80138f:	90                   	nop
  801390:	89 d1                	mov    %edx,%ecx
  801392:	89 fa                	mov    %edi,%edx
  801394:	89 c8                	mov    %ecx,%eax
  801396:	31 ff                	xor    %edi,%edi
  801398:	f7 f6                	div    %esi
  80139a:	89 c1                	mov    %eax,%ecx
  80139c:	89 fa                	mov    %edi,%edx
  80139e:	89 c8                	mov    %ecx,%eax
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	5e                   	pop    %esi
  8013a4:	5f                   	pop    %edi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    
  8013a7:	90                   	nop
  8013a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013ac:	89 f2                	mov    %esi,%edx
  8013ae:	d3 e0                	shl    %cl,%eax
  8013b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8013bb:	89 c1                	mov    %eax,%ecx
  8013bd:	d3 ea                	shr    %cl,%edx
  8013bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8013c6:	d3 e6                	shl    %cl,%esi
  8013c8:	89 c1                	mov    %eax,%ecx
  8013ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8013cd:	89 fe                	mov    %edi,%esi
  8013cf:	d3 ee                	shr    %cl,%esi
  8013d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013db:	d3 e7                	shl    %cl,%edi
  8013dd:	89 c1                	mov    %eax,%ecx
  8013df:	d3 ea                	shr    %cl,%edx
  8013e1:	09 d7                	or     %edx,%edi
  8013e3:	89 f2                	mov    %esi,%edx
  8013e5:	89 f8                	mov    %edi,%eax
  8013e7:	f7 75 ec             	divl   -0x14(%ebp)
  8013ea:	89 d6                	mov    %edx,%esi
  8013ec:	89 c7                	mov    %eax,%edi
  8013ee:	f7 65 e8             	mull   -0x18(%ebp)
  8013f1:	39 d6                	cmp    %edx,%esi
  8013f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013f6:	72 30                	jb     801428 <__udivdi3+0x118>
  8013f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013ff:	d3 e2                	shl    %cl,%edx
  801401:	39 c2                	cmp    %eax,%edx
  801403:	73 05                	jae    80140a <__udivdi3+0xfa>
  801405:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801408:	74 1e                	je     801428 <__udivdi3+0x118>
  80140a:	89 f9                	mov    %edi,%ecx
  80140c:	31 ff                	xor    %edi,%edi
  80140e:	e9 71 ff ff ff       	jmp    801384 <__udivdi3+0x74>
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	31 ff                	xor    %edi,%edi
  80141a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80141f:	e9 60 ff ff ff       	jmp    801384 <__udivdi3+0x74>
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80142b:	31 ff                	xor    %edi,%edi
  80142d:	89 c8                	mov    %ecx,%eax
  80142f:	89 fa                	mov    %edi,%edx
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    
	...

00801440 <__umoddi3>:
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	83 ec 20             	sub    $0x20,%esp
  801448:	8b 55 14             	mov    0x14(%ebp),%edx
  80144b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801451:	8b 75 0c             	mov    0xc(%ebp),%esi
  801454:	85 d2                	test   %edx,%edx
  801456:	89 c8                	mov    %ecx,%eax
  801458:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80145b:	75 13                	jne    801470 <__umoddi3+0x30>
  80145d:	39 f7                	cmp    %esi,%edi
  80145f:	76 3f                	jbe    8014a0 <__umoddi3+0x60>
  801461:	89 f2                	mov    %esi,%edx
  801463:	f7 f7                	div    %edi
  801465:	89 d0                	mov    %edx,%eax
  801467:	31 d2                	xor    %edx,%edx
  801469:	83 c4 20             	add    $0x20,%esp
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    
  801470:	39 f2                	cmp    %esi,%edx
  801472:	77 4c                	ja     8014c0 <__umoddi3+0x80>
  801474:	0f bd ca             	bsr    %edx,%ecx
  801477:	83 f1 1f             	xor    $0x1f,%ecx
  80147a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80147d:	75 51                	jne    8014d0 <__umoddi3+0x90>
  80147f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801482:	0f 87 e0 00 00 00    	ja     801568 <__umoddi3+0x128>
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	29 f8                	sub    %edi,%eax
  80148d:	19 d6                	sbb    %edx,%esi
  80148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	89 f2                	mov    %esi,%edx
  801497:	83 c4 20             	add    $0x20,%esp
  80149a:	5e                   	pop    %esi
  80149b:	5f                   	pop    %edi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    
  80149e:	66 90                	xchg   %ax,%ax
  8014a0:	85 ff                	test   %edi,%edi
  8014a2:	75 0b                	jne    8014af <__umoddi3+0x6f>
  8014a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a9:	31 d2                	xor    %edx,%edx
  8014ab:	f7 f7                	div    %edi
  8014ad:	89 c7                	mov    %eax,%edi
  8014af:	89 f0                	mov    %esi,%eax
  8014b1:	31 d2                	xor    %edx,%edx
  8014b3:	f7 f7                	div    %edi
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	f7 f7                	div    %edi
  8014ba:	eb a9                	jmp    801465 <__umoddi3+0x25>
  8014bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c0:	89 c8                	mov    %ecx,%eax
  8014c2:	89 f2                	mov    %esi,%edx
  8014c4:	83 c4 20             	add    $0x20,%esp
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    
  8014cb:	90                   	nop
  8014cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014d4:	d3 e2                	shl    %cl,%edx
  8014d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8014de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8014e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014e8:	89 fa                	mov    %edi,%edx
  8014ea:	d3 ea                	shr    %cl,%edx
  8014ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8014f3:	d3 e7                	shl    %cl,%edi
  8014f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014fc:	89 f2                	mov    %esi,%edx
  8014fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801501:	89 c7                	mov    %eax,%edi
  801503:	d3 ea                	shr    %cl,%edx
  801505:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801509:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	d3 e6                	shl    %cl,%esi
  801510:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801514:	d3 ea                	shr    %cl,%edx
  801516:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80151a:	09 d6                	or     %edx,%esi
  80151c:	89 f0                	mov    %esi,%eax
  80151e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801521:	d3 e7                	shl    %cl,%edi
  801523:	89 f2                	mov    %esi,%edx
  801525:	f7 75 f4             	divl   -0xc(%ebp)
  801528:	89 d6                	mov    %edx,%esi
  80152a:	f7 65 e8             	mull   -0x18(%ebp)
  80152d:	39 d6                	cmp    %edx,%esi
  80152f:	72 2b                	jb     80155c <__umoddi3+0x11c>
  801531:	39 c7                	cmp    %eax,%edi
  801533:	72 23                	jb     801558 <__umoddi3+0x118>
  801535:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801539:	29 c7                	sub    %eax,%edi
  80153b:	19 d6                	sbb    %edx,%esi
  80153d:	89 f0                	mov    %esi,%eax
  80153f:	89 f2                	mov    %esi,%edx
  801541:	d3 ef                	shr    %cl,%edi
  801543:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801547:	d3 e0                	shl    %cl,%eax
  801549:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80154d:	09 f8                	or     %edi,%eax
  80154f:	d3 ea                	shr    %cl,%edx
  801551:	83 c4 20             	add    $0x20,%esp
  801554:	5e                   	pop    %esi
  801555:	5f                   	pop    %edi
  801556:	5d                   	pop    %ebp
  801557:	c3                   	ret    
  801558:	39 d6                	cmp    %edx,%esi
  80155a:	75 d9                	jne    801535 <__umoddi3+0xf5>
  80155c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80155f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801562:	eb d1                	jmp    801535 <__umoddi3+0xf5>
  801564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801568:	39 f2                	cmp    %esi,%edx
  80156a:	0f 82 18 ff ff ff    	jb     801488 <__umoddi3+0x48>
  801570:	e9 1d ff ff ff       	jmp    801492 <__umoddi3+0x52>
