
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 a1 03 00 00       	call   8003f7 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 de 01 00 00       	call   800248 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80008a:	e8 57 04 00 00       	call   8004e6 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	c1 e0 07             	shl    $0x7,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 4c 04 00 00       	call   800526 <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	89 1c 24             	mov    %ebx,(%esp)
  8000e5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	51                   	push   %ecx
  8000fa:	52                   	push   %edx
  8000fb:	53                   	push   %ebx
  8000fc:	54                   	push   %esp
  8000fd:	55                   	push   %ebp
  8000fe:	56                   	push   %esi
  8000ff:	57                   	push   %edi
  800100:	89 e5                	mov    %esp,%ebp
  800102:	8d 35 0a 01 80 00    	lea    0x80010a,%esi
  800108:	0f 34                	sysenter 
  80010a:	5f                   	pop    %edi
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	5c                   	pop    %esp
  80010e:	5b                   	pop    %ebx
  80010f:	5a                   	pop    %edx
  800110:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	8b 1c 24             	mov    (%esp),%ebx
  800114:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800118:	89 ec                	mov    %ebp,%esp
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 08             	sub    $0x8,%esp
  800122:	89 1c 24             	mov    %ebx,(%esp)
  800125:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800129:	b8 00 00 00 00       	mov    $0x0,%eax
  80012e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800131:	8b 55 08             	mov    0x8(%ebp),%edx
  800134:	89 c3                	mov    %eax,%ebx
  800136:	89 c7                	mov    %eax,%edi
  800138:	51                   	push   %ecx
  800139:	52                   	push   %edx
  80013a:	53                   	push   %ebx
  80013b:	54                   	push   %esp
  80013c:	55                   	push   %ebp
  80013d:	56                   	push   %esi
  80013e:	57                   	push   %edi
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8d 35 49 01 80 00    	lea    0x800149,%esi
  800147:	0f 34                	sysenter 
  800149:	5f                   	pop    %edi
  80014a:	5e                   	pop    %esi
  80014b:	5d                   	pop    %ebp
  80014c:	5c                   	pop    %esp
  80014d:	5b                   	pop    %ebx
  80014e:	5a                   	pop    %edx
  80014f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800150:	8b 1c 24             	mov    (%esp),%ebx
  800153:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800157:	89 ec                	mov    %ebp,%esp
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
  800161:	89 1c 24             	mov    %ebx,(%esp)
  800164:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800168:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800172:	8b 55 08             	mov    0x8(%ebp),%edx
  800175:	89 cb                	mov    %ecx,%ebx
  800177:	89 cf                	mov    %ecx,%edi
  800179:	51                   	push   %ecx
  80017a:	52                   	push   %edx
  80017b:	53                   	push   %ebx
  80017c:	54                   	push   %esp
  80017d:	55                   	push   %ebp
  80017e:	56                   	push   %esi
  80017f:	57                   	push   %edi
  800180:	89 e5                	mov    %esp,%ebp
  800182:	8d 35 8a 01 80 00    	lea    0x80018a,%esi
  800188:	0f 34                	sysenter 
  80018a:	5f                   	pop    %edi
  80018b:	5e                   	pop    %esi
  80018c:	5d                   	pop    %ebp
  80018d:	5c                   	pop    %esp
  80018e:	5b                   	pop    %ebx
  80018f:	5a                   	pop    %edx
  800190:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800191:	8b 1c 24             	mov    (%esp),%ebx
  800194:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800198:	89 ec                	mov    %ebp,%esp
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 28             	sub    $0x28,%esp
  8001a2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001a5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	89 cb                	mov    %ecx,%ebx
  8001b7:	89 cf                	mov    %ecx,%edi
  8001b9:	51                   	push   %ecx
  8001ba:	52                   	push   %edx
  8001bb:	53                   	push   %ebx
  8001bc:	54                   	push   %esp
  8001bd:	55                   	push   %ebp
  8001be:	56                   	push   %esi
  8001bf:	57                   	push   %edi
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	8d 35 ca 01 80 00    	lea    0x8001ca,%esi
  8001c8:	0f 34                	sysenter 
  8001ca:	5f                   	pop    %edi
  8001cb:	5e                   	pop    %esi
  8001cc:	5d                   	pop    %ebp
  8001cd:	5c                   	pop    %esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5a                   	pop    %edx
  8001d0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	7e 28                	jle    8001fd <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  8001f8:	e8 97 03 00 00       	call   800594 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001fd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800200:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800203:	89 ec                	mov    %ebp,%esp
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	89 1c 24             	mov    %ebx,(%esp)
  800210:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800214:	b8 0c 00 00 00       	mov    $0xc,%eax
  800219:	8b 7d 14             	mov    0x14(%ebp),%edi
  80021c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	51                   	push   %ecx
  800226:	52                   	push   %edx
  800227:	53                   	push   %ebx
  800228:	54                   	push   %esp
  800229:	55                   	push   %ebp
  80022a:	56                   	push   %esi
  80022b:	57                   	push   %edi
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	8d 35 36 02 80 00    	lea    0x800236,%esi
  800234:	0f 34                	sysenter 
  800236:	5f                   	pop    %edi
  800237:	5e                   	pop    %esi
  800238:	5d                   	pop    %ebp
  800239:	5c                   	pop    %esp
  80023a:	5b                   	pop    %ebx
  80023b:	5a                   	pop    %edx
  80023c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80023d:	8b 1c 24             	mov    (%esp),%ebx
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	89 ec                	mov    %ebp,%esp
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 28             	sub    $0x28,%esp
  80024e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800251:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	b8 0a 00 00 00       	mov    $0xa,%eax
  80025e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	89 df                	mov    %ebx,%edi
  800266:	51                   	push   %ecx
  800267:	52                   	push   %edx
  800268:	53                   	push   %ebx
  800269:	54                   	push   %esp
  80026a:	55                   	push   %ebp
  80026b:	56                   	push   %esi
  80026c:	57                   	push   %edi
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	8d 35 77 02 80 00    	lea    0x800277,%esi
  800275:	0f 34                	sysenter 
  800277:	5f                   	pop    %edi
  800278:	5e                   	pop    %esi
  800279:	5d                   	pop    %ebp
  80027a:	5c                   	pop    %esp
  80027b:	5b                   	pop    %ebx
  80027c:	5a                   	pop    %edx
  80027d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 28                	jle    8002aa <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	89 44 24 10          	mov    %eax,0x10(%esp)
  800286:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80028d:	00 
  80028e:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  800295:	00 
  800296:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80029d:	00 
  80029e:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  8002a5:	e8 ea 02 00 00       	call   800594 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b0:	89 ec                	mov    %ebp,%esp
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 28             	sub    $0x28,%esp
  8002ba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002bd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 df                	mov    %ebx,%edi
  8002d2:	51                   	push   %ecx
  8002d3:	52                   	push   %edx
  8002d4:	53                   	push   %ebx
  8002d5:	54                   	push   %esp
  8002d6:	55                   	push   %ebp
  8002d7:	56                   	push   %esi
  8002d8:	57                   	push   %edi
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8d 35 e3 02 80 00    	lea    0x8002e3,%esi
  8002e1:	0f 34                	sysenter 
  8002e3:	5f                   	pop    %edi
  8002e4:	5e                   	pop    %esi
  8002e5:	5d                   	pop    %ebp
  8002e6:	5c                   	pop    %esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5a                   	pop    %edx
  8002e9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 28                	jle    800316 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  800301:	00 
  800302:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  800311:	e8 7e 02 00 00       	call   800594 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800316:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800319:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80031c:	89 ec                	mov    %ebp,%esp
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 28             	sub    $0x28,%esp
  800326:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800329:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80032c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800331:	b8 07 00 00 00       	mov    $0x7,%eax
  800336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800339:	8b 55 08             	mov    0x8(%ebp),%edx
  80033c:	89 df                	mov    %ebx,%edi
  80033e:	51                   	push   %ecx
  80033f:	52                   	push   %edx
  800340:	53                   	push   %ebx
  800341:	54                   	push   %esp
  800342:	55                   	push   %ebp
  800343:	56                   	push   %esi
  800344:	57                   	push   %edi
  800345:	89 e5                	mov    %esp,%ebp
  800347:	8d 35 4f 03 80 00    	lea    0x80034f,%esi
  80034d:	0f 34                	sysenter 
  80034f:	5f                   	pop    %edi
  800350:	5e                   	pop    %esi
  800351:	5d                   	pop    %ebp
  800352:	5c                   	pop    %esp
  800353:	5b                   	pop    %ebx
  800354:	5a                   	pop    %edx
  800355:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	7e 28                	jle    800382 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800365:	00 
  800366:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  80037d:	e8 12 02 00 00       	call   800594 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800382:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800385:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800388:	89 ec                	mov    %ebp,%esp
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 28             	sub    $0x28,%esp
  800392:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800395:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800398:	b8 06 00 00 00       	mov    $0x6,%eax
  80039d:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	51                   	push   %ecx
  8003aa:	52                   	push   %edx
  8003ab:	53                   	push   %ebx
  8003ac:	54                   	push   %esp
  8003ad:	55                   	push   %ebp
  8003ae:	56                   	push   %esi
  8003af:	57                   	push   %edi
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	8d 35 ba 03 80 00    	lea    0x8003ba,%esi
  8003b8:	0f 34                	sysenter 
  8003ba:	5f                   	pop    %edi
  8003bb:	5e                   	pop    %esi
  8003bc:	5d                   	pop    %ebp
  8003bd:	5c                   	pop    %esp
  8003be:	5b                   	pop    %ebx
  8003bf:	5a                   	pop    %edx
  8003c0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	7e 28                	jle    8003ed <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  8003e8:	e8 a7 01 00 00       	call   800594 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8003ed:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003f3:	89 ec                	mov    %ebp,%esp
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	83 ec 28             	sub    $0x28,%esp
  8003fd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800400:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	b8 05 00 00 00       	mov    $0x5,%eax
  80040d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800413:	8b 55 08             	mov    0x8(%ebp),%edx
  800416:	51                   	push   %ecx
  800417:	52                   	push   %edx
  800418:	53                   	push   %ebx
  800419:	54                   	push   %esp
  80041a:	55                   	push   %ebp
  80041b:	56                   	push   %esi
  80041c:	57                   	push   %edi
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	8d 35 27 04 80 00    	lea    0x800427,%esi
  800425:	0f 34                	sysenter 
  800427:	5f                   	pop    %edi
  800428:	5e                   	pop    %esi
  800429:	5d                   	pop    %ebp
  80042a:	5c                   	pop    %esp
  80042b:	5b                   	pop    %ebx
  80042c:	5a                   	pop    %edx
  80042d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80042e:	85 c0                	test   %eax,%eax
  800430:	7e 28                	jle    80045a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800432:	89 44 24 10          	mov    %eax,0x10(%esp)
  800436:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80043d:	00 
  80043e:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  800445:	00 
  800446:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80044d:	00 
  80044e:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  800455:	e8 3a 01 00 00       	call   800594 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80045a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80045d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800460:	89 ec                	mov    %ebp,%esp
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	89 1c 24             	mov    %ebx,(%esp)
  80046d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800471:	ba 00 00 00 00       	mov    $0x0,%edx
  800476:	b8 0b 00 00 00       	mov    $0xb,%eax
  80047b:	89 d1                	mov    %edx,%ecx
  80047d:	89 d3                	mov    %edx,%ebx
  80047f:	89 d7                	mov    %edx,%edi
  800481:	51                   	push   %ecx
  800482:	52                   	push   %edx
  800483:	53                   	push   %ebx
  800484:	54                   	push   %esp
  800485:	55                   	push   %ebp
  800486:	56                   	push   %esi
  800487:	57                   	push   %edi
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	8d 35 92 04 80 00    	lea    0x800492,%esi
  800490:	0f 34                	sysenter 
  800492:	5f                   	pop    %edi
  800493:	5e                   	pop    %esi
  800494:	5d                   	pop    %ebp
  800495:	5c                   	pop    %esp
  800496:	5b                   	pop    %ebx
  800497:	5a                   	pop    %edx
  800498:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800499:	8b 1c 24             	mov    (%esp),%ebx
  80049c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004a0:	89 ec                	mov    %ebp,%esp
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    

008004a4 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	89 1c 24             	mov    %ebx,(%esp)
  8004ad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8004bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004be:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c1:	89 df                	mov    %ebx,%edi
  8004c3:	51                   	push   %ecx
  8004c4:	52                   	push   %edx
  8004c5:	53                   	push   %ebx
  8004c6:	54                   	push   %esp
  8004c7:	55                   	push   %ebp
  8004c8:	56                   	push   %esi
  8004c9:	57                   	push   %edi
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	8d 35 d4 04 80 00    	lea    0x8004d4,%esi
  8004d2:	0f 34                	sysenter 
  8004d4:	5f                   	pop    %edi
  8004d5:	5e                   	pop    %esi
  8004d6:	5d                   	pop    %ebp
  8004d7:	5c                   	pop    %esp
  8004d8:	5b                   	pop    %ebx
  8004d9:	5a                   	pop    %edx
  8004da:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8004db:	8b 1c 24             	mov    (%esp),%ebx
  8004de:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004e2:	89 ec                	mov    %ebp,%esp
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	89 1c 24             	mov    %ebx,(%esp)
  8004ef:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8004fd:	89 d1                	mov    %edx,%ecx
  8004ff:	89 d3                	mov    %edx,%ebx
  800501:	89 d7                	mov    %edx,%edi
  800503:	51                   	push   %ecx
  800504:	52                   	push   %edx
  800505:	53                   	push   %ebx
  800506:	54                   	push   %esp
  800507:	55                   	push   %ebp
  800508:	56                   	push   %esi
  800509:	57                   	push   %edi
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	8d 35 14 05 80 00    	lea    0x800514,%esi
  800512:	0f 34                	sysenter 
  800514:	5f                   	pop    %edi
  800515:	5e                   	pop    %esi
  800516:	5d                   	pop    %ebp
  800517:	5c                   	pop    %esp
  800518:	5b                   	pop    %ebx
  800519:	5a                   	pop    %edx
  80051a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80051b:	8b 1c 24             	mov    (%esp),%ebx
  80051e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800522:	89 ec                	mov    %ebp,%esp
  800524:	5d                   	pop    %ebp
  800525:	c3                   	ret    

00800526 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	83 ec 28             	sub    $0x28,%esp
  80052c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80052f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800532:	b9 00 00 00 00       	mov    $0x0,%ecx
  800537:	b8 03 00 00 00       	mov    $0x3,%eax
  80053c:	8b 55 08             	mov    0x8(%ebp),%edx
  80053f:	89 cb                	mov    %ecx,%ebx
  800541:	89 cf                	mov    %ecx,%edi
  800543:	51                   	push   %ecx
  800544:	52                   	push   %edx
  800545:	53                   	push   %ebx
  800546:	54                   	push   %esp
  800547:	55                   	push   %ebp
  800548:	56                   	push   %esi
  800549:	57                   	push   %edi
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	8d 35 54 05 80 00    	lea    0x800554,%esi
  800552:	0f 34                	sysenter 
  800554:	5f                   	pop    %edi
  800555:	5e                   	pop    %esi
  800556:	5d                   	pop    %ebp
  800557:	5c                   	pop    %esp
  800558:	5b                   	pop    %ebx
  800559:	5a                   	pop    %edx
  80055a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80055b:	85 c0                	test   %eax,%eax
  80055d:	7e 28                	jle    800587 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80055f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800563:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80056a:	00 
  80056b:	c7 44 24 08 ca 13 80 	movl   $0x8013ca,0x8(%esp)
  800572:	00 
  800573:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80057a:	00 
  80057b:	c7 04 24 e7 13 80 00 	movl   $0x8013e7,(%esp)
  800582:	e8 0d 00 00 00       	call   800594 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800587:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80058a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80058d:	89 ec                	mov    %ebp,%esp
  80058f:	5d                   	pop    %ebp
  800590:	c3                   	ret    
  800591:	00 00                	add    %al,(%eax)
	...

00800594 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	56                   	push   %esi
  800598:	53                   	push   %ebx
  800599:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80059c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80059f:	a1 08 20 80 00       	mov    0x802008,%eax
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	74 10                	je     8005b8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8005a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ac:	c7 04 24 f5 13 80 00 	movl   $0x8013f5,(%esp)
  8005b3:	e8 ad 00 00 00       	call   800665 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005b8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005be:	e8 23 ff ff ff       	call   8004e6 <sys_getenvid>
  8005c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d9:	c7 04 24 fc 13 80 00 	movl   $0x8013fc,(%esp)
  8005e0:	e8 80 00 00 00       	call   800665 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 10 00 00 00       	call   800604 <vcprintf>
	cprintf("\n");
  8005f4:	c7 04 24 fa 13 80 00 	movl   $0x8013fa,(%esp)
  8005fb:	e8 65 00 00 00       	call   800665 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800600:	cc                   	int3   
  800601:	eb fd                	jmp    800600 <_panic+0x6c>
	...

00800604 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80060d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800614:	00 00 00 
	b.cnt = 0;
  800617:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80061e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800621:	8b 45 0c             	mov    0xc(%ebp),%eax
  800624:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800635:	89 44 24 04          	mov    %eax,0x4(%esp)
  800639:	c7 04 24 7f 06 80 00 	movl   $0x80067f,(%esp)
  800640:	e8 d8 01 00 00       	call   80081d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800645:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800655:	89 04 24             	mov    %eax,(%esp)
  800658:	e8 bf fa ff ff       	call   80011c <sys_cputs>

	return b.cnt;
}
  80065d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800663:	c9                   	leave  
  800664:	c3                   	ret    

00800665 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80066b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	e8 87 ff ff ff       	call   800604 <vcprintf>
	va_end(ap);

	return cnt;
}
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	53                   	push   %ebx
  800683:	83 ec 14             	sub    $0x14,%esp
  800686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800689:	8b 03                	mov    (%ebx),%eax
  80068b:	8b 55 08             	mov    0x8(%ebp),%edx
  80068e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800692:	83 c0 01             	add    $0x1,%eax
  800695:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800697:	3d ff 00 00 00       	cmp    $0xff,%eax
  80069c:	75 19                	jne    8006b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80069e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8006a5:	00 
  8006a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8006a9:	89 04 24             	mov    %eax,(%esp)
  8006ac:	e8 6b fa ff ff       	call   80011c <sys_cputs>
		b->idx = 0;
  8006b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8006b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006bb:	83 c4 14             	add    $0x14,%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    
	...

008006d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	57                   	push   %edi
  8006d4:	56                   	push   %esi
  8006d5:	53                   	push   %ebx
  8006d6:	83 ec 4c             	sub    $0x4c,%esp
  8006d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006dc:	89 d6                	mov    %edx,%esi
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	39 d1                	cmp    %edx,%ecx
  8006fd:	72 15                	jb     800714 <printnum+0x44>
  8006ff:	77 07                	ja     800708 <printnum+0x38>
  800701:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800704:	39 d0                	cmp    %edx,%eax
  800706:	76 0c                	jbe    800714 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800708:	83 eb 01             	sub    $0x1,%ebx
  80070b:	85 db                	test   %ebx,%ebx
  80070d:	8d 76 00             	lea    0x0(%esi),%esi
  800710:	7f 61                	jg     800773 <printnum+0xa3>
  800712:	eb 70                	jmp    800784 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800718:	83 eb 01             	sub    $0x1,%ebx
  80071b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80071f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800723:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800727:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80072b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80072e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800731:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800734:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800738:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80073f:	00 
  800740:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800749:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074d:	e8 ee 09 00 00       	call   801140 <__udivdi3>
  800752:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800755:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800758:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80075c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	89 54 24 04          	mov    %edx,0x4(%esp)
  800767:	89 f2                	mov    %esi,%edx
  800769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80076c:	e8 5f ff ff ff       	call   8006d0 <printnum>
  800771:	eb 11                	jmp    800784 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800773:	89 74 24 04          	mov    %esi,0x4(%esp)
  800777:	89 3c 24             	mov    %edi,(%esp)
  80077a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80077d:	83 eb 01             	sub    $0x1,%ebx
  800780:	85 db                	test   %ebx,%ebx
  800782:	7f ef                	jg     800773 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800784:	89 74 24 04          	mov    %esi,0x4(%esp)
  800788:	8b 74 24 04          	mov    0x4(%esp),%esi
  80078c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80078f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800793:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80079a:	00 
  80079b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079e:	89 14 24             	mov    %edx,(%esp)
  8007a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a8:	e8 c3 0a 00 00       	call   801270 <__umoddi3>
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	0f be 80 20 14 80 00 	movsbl 0x801420(%eax),%eax
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007be:	83 c4 4c             	add    $0x4c,%esp
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5f                   	pop    %edi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007c9:	83 fa 01             	cmp    $0x1,%edx
  8007cc:	7e 0e                	jle    8007dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007d3:	89 08                	mov    %ecx,(%eax)
  8007d5:	8b 02                	mov    (%edx),%eax
  8007d7:	8b 52 04             	mov    0x4(%edx),%edx
  8007da:	eb 22                	jmp    8007fe <getuint+0x38>
	else if (lflag)
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 10                	je     8007f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ee:	eb 0e                	jmp    8007fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007f0:	8b 10                	mov    (%eax),%edx
  8007f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007f5:	89 08                	mov    %ecx,(%eax)
  8007f7:	8b 02                	mov    (%edx),%eax
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800806:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	3b 50 04             	cmp    0x4(%eax),%edx
  80080f:	73 0a                	jae    80081b <sprintputch+0x1b>
		*b->buf++ = ch;
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800814:	88 0a                	mov    %cl,(%edx)
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	89 10                	mov    %edx,(%eax)
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	57                   	push   %edi
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	83 ec 5c             	sub    $0x5c,%esp
  800826:	8b 7d 08             	mov    0x8(%ebp),%edi
  800829:	8b 75 0c             	mov    0xc(%ebp),%esi
  80082c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80082f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800836:	eb 11                	jmp    800849 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800838:	85 c0                	test   %eax,%eax
  80083a:	0f 84 09 04 00 00    	je     800c49 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800840:	89 74 24 04          	mov    %esi,0x4(%esp)
  800844:	89 04 24             	mov    %eax,(%esp)
  800847:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800849:	0f b6 03             	movzbl (%ebx),%eax
  80084c:	83 c3 01             	add    $0x1,%ebx
  80084f:	83 f8 25             	cmp    $0x25,%eax
  800852:	75 e4                	jne    800838 <vprintfmt+0x1b>
  800854:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800858:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80085f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800866:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	eb 06                	jmp    80087a <vprintfmt+0x5d>
  800874:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800878:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087a:	0f b6 13             	movzbl (%ebx),%edx
  80087d:	0f b6 c2             	movzbl %dl,%eax
  800880:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800883:	8d 43 01             	lea    0x1(%ebx),%eax
  800886:	83 ea 23             	sub    $0x23,%edx
  800889:	80 fa 55             	cmp    $0x55,%dl
  80088c:	0f 87 9a 03 00 00    	ja     800c2c <vprintfmt+0x40f>
  800892:	0f b6 d2             	movzbl %dl,%edx
  800895:	ff 24 95 e0 14 80 00 	jmp    *0x8014e0(,%edx,4)
  80089c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8008a0:	eb d6                	jmp    800878 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008a5:	83 ea 30             	sub    $0x30,%edx
  8008a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8008ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8008b1:	83 fb 09             	cmp    $0x9,%ebx
  8008b4:	77 4c                	ja     800902 <vprintfmt+0xe5>
  8008b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8008b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8008bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8008c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8008c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8008cc:	83 fb 09             	cmp    $0x9,%ebx
  8008cf:	76 eb                	jbe    8008bc <vprintfmt+0x9f>
  8008d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008d7:	eb 29                	jmp    800902 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8008dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8008df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8008e2:	8b 12                	mov    (%edx),%edx
  8008e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8008e7:	eb 19                	jmp    800902 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8008e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ec:	c1 fa 1f             	sar    $0x1f,%edx
  8008ef:	f7 d2                	not    %edx
  8008f1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8008f4:	eb 82                	jmp    800878 <vprintfmt+0x5b>
  8008f6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8008fd:	e9 76 ff ff ff       	jmp    800878 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800902:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800906:	0f 89 6c ff ff ff    	jns    800878 <vprintfmt+0x5b>
  80090c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80090f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800912:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800915:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800918:	e9 5b ff ff ff       	jmp    800878 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80091d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800920:	e9 53 ff ff ff       	jmp    800878 <vprintfmt+0x5b>
  800925:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 50 04             	lea    0x4(%eax),%edx
  80092e:	89 55 14             	mov    %edx,0x14(%ebp)
  800931:	89 74 24 04          	mov    %esi,0x4(%esp)
  800935:	8b 00                	mov    (%eax),%eax
  800937:	89 04 24             	mov    %eax,(%esp)
  80093a:	ff d7                	call   *%edi
  80093c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80093f:	e9 05 ff ff ff       	jmp    800849 <vprintfmt+0x2c>
  800944:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8d 50 04             	lea    0x4(%eax),%edx
  80094d:	89 55 14             	mov    %edx,0x14(%ebp)
  800950:	8b 00                	mov    (%eax),%eax
  800952:	89 c2                	mov    %eax,%edx
  800954:	c1 fa 1f             	sar    $0x1f,%edx
  800957:	31 d0                	xor    %edx,%eax
  800959:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095b:	83 f8 08             	cmp    $0x8,%eax
  80095e:	7f 0b                	jg     80096b <vprintfmt+0x14e>
  800960:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800967:	85 d2                	test   %edx,%edx
  800969:	75 20                	jne    80098b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80096b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096f:	c7 44 24 08 31 14 80 	movl   $0x801431,0x8(%esp)
  800976:	00 
  800977:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097b:	89 3c 24             	mov    %edi,(%esp)
  80097e:	e8 4e 03 00 00       	call   800cd1 <printfmt>
  800983:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800986:	e9 be fe ff ff       	jmp    800849 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80098b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80098f:	c7 44 24 08 3a 14 80 	movl   $0x80143a,0x8(%esp)
  800996:	00 
  800997:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099b:	89 3c 24             	mov    %edi,(%esp)
  80099e:	e8 2e 03 00 00       	call   800cd1 <printfmt>
  8009a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009a6:	e9 9e fe ff ff       	jmp    800849 <vprintfmt+0x2c>
  8009ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ae:	89 c3                	mov    %eax,%ebx
  8009b0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009b6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bc:	8d 50 04             	lea    0x4(%eax),%edx
  8009bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c2:	8b 00                	mov    (%eax),%eax
  8009c4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8009c7:	85 c0                	test   %eax,%eax
  8009c9:	75 07                	jne    8009d2 <vprintfmt+0x1b5>
  8009cb:	c7 45 c4 3d 14 80 00 	movl   $0x80143d,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8009d2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8009d6:	7e 06                	jle    8009de <vprintfmt+0x1c1>
  8009d8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8009dc:	75 13                	jne    8009f1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009e1:	0f be 02             	movsbl (%edx),%eax
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	0f 85 99 00 00 00    	jne    800a85 <vprintfmt+0x268>
  8009ec:	e9 86 00 00 00       	jmp    800a77 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009f5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8009f8:	89 0c 24             	mov    %ecx,(%esp)
  8009fb:	e8 1b 03 00 00       	call   800d1b <strnlen>
  800a00:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a03:	29 c2                	sub    %eax,%edx
  800a05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a08:	85 d2                	test   %edx,%edx
  800a0a:	7e d2                	jle    8009de <vprintfmt+0x1c1>
					putch(padc, putdat);
  800a0c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800a10:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a13:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a16:	89 d3                	mov    %edx,%ebx
  800a18:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a1f:	89 04 24             	mov    %eax,(%esp)
  800a22:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a24:	83 eb 01             	sub    $0x1,%ebx
  800a27:	85 db                	test   %ebx,%ebx
  800a29:	7f ed                	jg     800a18 <vprintfmt+0x1fb>
  800a2b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a2e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a35:	eb a7                	jmp    8009de <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a37:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a3b:	74 18                	je     800a55 <vprintfmt+0x238>
  800a3d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a40:	83 fa 5e             	cmp    $0x5e,%edx
  800a43:	76 10                	jbe    800a55 <vprintfmt+0x238>
					putch('?', putdat);
  800a45:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a49:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a50:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a53:	eb 0a                	jmp    800a5f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a55:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a59:	89 04 24             	mov    %eax,(%esp)
  800a5c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a63:	0f be 03             	movsbl (%ebx),%eax
  800a66:	85 c0                	test   %eax,%eax
  800a68:	74 05                	je     800a6f <vprintfmt+0x252>
  800a6a:	83 c3 01             	add    $0x1,%ebx
  800a6d:	eb 29                	jmp    800a98 <vprintfmt+0x27b>
  800a6f:	89 fe                	mov    %edi,%esi
  800a71:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a74:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a7b:	7f 2e                	jg     800aab <vprintfmt+0x28e>
  800a7d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a80:	e9 c4 fd ff ff       	jmp    800849 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a85:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a88:	83 c2 01             	add    $0x1,%edx
  800a8b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800a8e:	89 f7                	mov    %esi,%edi
  800a90:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a93:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a96:	89 d3                	mov    %edx,%ebx
  800a98:	85 f6                	test   %esi,%esi
  800a9a:	78 9b                	js     800a37 <vprintfmt+0x21a>
  800a9c:	83 ee 01             	sub    $0x1,%esi
  800a9f:	79 96                	jns    800a37 <vprintfmt+0x21a>
  800aa1:	89 fe                	mov    %edi,%esi
  800aa3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800aa6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800aa9:	eb cc                	jmp    800a77 <vprintfmt+0x25a>
  800aab:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800aae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ab1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800abc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800abe:	83 eb 01             	sub    $0x1,%ebx
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	7f ec                	jg     800ab1 <vprintfmt+0x294>
  800ac5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ac8:	e9 7c fd ff ff       	jmp    800849 <vprintfmt+0x2c>
  800acd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ad0:	83 f9 01             	cmp    $0x1,%ecx
  800ad3:	7e 16                	jle    800aeb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800ad5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad8:	8d 50 08             	lea    0x8(%eax),%edx
  800adb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ade:	8b 10                	mov    (%eax),%edx
  800ae0:	8b 48 04             	mov    0x4(%eax),%ecx
  800ae3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800ae6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ae9:	eb 32                	jmp    800b1d <vprintfmt+0x300>
	else if (lflag)
  800aeb:	85 c9                	test   %ecx,%ecx
  800aed:	74 18                	je     800b07 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8d 50 04             	lea    0x4(%eax),%edx
  800af5:	89 55 14             	mov    %edx,0x14(%ebp)
  800af8:	8b 00                	mov    (%eax),%eax
  800afa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800afd:	89 c1                	mov    %eax,%ecx
  800aff:	c1 f9 1f             	sar    $0x1f,%ecx
  800b02:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b05:	eb 16                	jmp    800b1d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800b07:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0a:	8d 50 04             	lea    0x4(%eax),%edx
  800b0d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b10:	8b 00                	mov    (%eax),%eax
  800b12:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	c1 fa 1f             	sar    $0x1f,%edx
  800b1a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b1d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b23:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800b28:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b2c:	0f 89 b8 00 00 00    	jns    800bea <vprintfmt+0x3cd>
				putch('-', putdat);
  800b32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b36:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b3d:	ff d7                	call   *%edi
				num = -(long long) num;
  800b3f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b45:	f7 d9                	neg    %ecx
  800b47:	83 d3 00             	adc    $0x0,%ebx
  800b4a:	f7 db                	neg    %ebx
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b51:	e9 94 00 00 00       	jmp    800bea <vprintfmt+0x3cd>
  800b56:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b59:	89 ca                	mov    %ecx,%edx
  800b5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5e:	e8 63 fc ff ff       	call   8007c6 <getuint>
  800b63:	89 c1                	mov    %eax,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800b6c:	eb 7c                	jmp    800bea <vprintfmt+0x3cd>
  800b6e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b75:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b7c:	ff d7                	call   *%edi
			putch('X', putdat);
  800b7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b82:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b89:	ff d7                	call   *%edi
			putch('X', putdat);
  800b8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b8f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b96:	ff d7                	call   *%edi
  800b98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800b9b:	e9 a9 fc ff ff       	jmp    800849 <vprintfmt+0x2c>
  800ba0:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800ba3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bae:	ff d7                	call   *%edi
			putch('x', putdat);
  800bb0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bbb:	ff d7                	call   *%edi
			num = (unsigned long long)
  800bbd:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc0:	8d 50 04             	lea    0x4(%eax),%edx
  800bc3:	89 55 14             	mov    %edx,0x14(%ebp)
  800bc6:	8b 08                	mov    (%eax),%ecx
  800bc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd2:	eb 16                	jmp    800bea <vprintfmt+0x3cd>
  800bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bd7:	89 ca                	mov    %ecx,%edx
  800bd9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bdc:	e8 e5 fb ff ff       	call   8007c6 <getuint>
  800be1:	89 c1                	mov    %eax,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bea:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800bee:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bf2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bf5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfd:	89 0c 24             	mov    %ecx,(%esp)
  800c00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c04:	89 f2                	mov    %esi,%edx
  800c06:	89 f8                	mov    %edi,%eax
  800c08:	e8 c3 fa ff ff       	call   8006d0 <printnum>
  800c0d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c10:	e9 34 fc ff ff       	jmp    800849 <vprintfmt+0x2c>
  800c15:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c18:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c1f:	89 14 24             	mov    %edx,(%esp)
  800c22:	ff d7                	call   *%edi
  800c24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c27:	e9 1d fc ff ff       	jmp    800849 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c30:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c37:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c39:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800c3c:	80 38 25             	cmpb   $0x25,(%eax)
  800c3f:	0f 84 04 fc ff ff    	je     800849 <vprintfmt+0x2c>
  800c45:	89 c3                	mov    %eax,%ebx
  800c47:	eb f0                	jmp    800c39 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800c49:	83 c4 5c             	add    $0x5c,%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 28             	sub    $0x28,%esp
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	74 04                	je     800c65 <vsnprintf+0x14>
  800c61:	85 d2                	test   %edx,%edx
  800c63:	7f 07                	jg     800c6c <vsnprintf+0x1b>
  800c65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c6a:	eb 3b                	jmp    800ca7 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c6f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c84:	8b 45 10             	mov    0x10(%ebp),%eax
  800c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c92:	c7 04 24 00 08 80 00 	movl   $0x800800,(%esp)
  800c99:	e8 7f fb ff ff       	call   80081d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800caf:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800cb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	89 04 24             	mov    %eax,(%esp)
  800cca:	e8 82 ff ff ff       	call   800c51 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800cd7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800cda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cde:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	89 04 24             	mov    %eax,(%esp)
  800cf2:	e8 26 fb ff ff       	call   80081d <vprintfmt>
	va_end(ap);
}
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    
  800cf9:	00 00                	add    %al,(%eax)
  800cfb:	00 00                	add    %al,(%eax)
  800cfd:	00 00                	add    %al,(%eax)
	...

00800d00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d0e:	74 09                	je     800d19 <strlen+0x19>
		n++;
  800d10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d17:	75 f7                	jne    800d10 <strlen+0x10>
		n++;
	return n;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	53                   	push   %ebx
  800d1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d25:	85 c9                	test   %ecx,%ecx
  800d27:	74 19                	je     800d42 <strnlen+0x27>
  800d29:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d2c:	74 14                	je     800d42 <strnlen+0x27>
  800d2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d33:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d36:	39 c8                	cmp    %ecx,%eax
  800d38:	74 0d                	je     800d47 <strnlen+0x2c>
  800d3a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800d3e:	75 f3                	jne    800d33 <strnlen+0x18>
  800d40:	eb 05                	jmp    800d47 <strnlen+0x2c>
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d47:	5b                   	pop    %ebx
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	53                   	push   %ebx
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d54:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	84 c9                	test   %cl,%cl
  800d65:	75 f2                	jne    800d59 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d67:	5b                   	pop    %ebx
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d74:	89 1c 24             	mov    %ebx,(%esp)
  800d77:	e8 84 ff ff ff       	call   800d00 <strlen>
	strcpy(dst + len, src);
  800d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d83:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d86:	89 04 24             	mov    %eax,(%esp)
  800d89:	e8 bc ff ff ff       	call   800d4a <strcpy>
	return dst;
}
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	83 c4 08             	add    $0x8,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da4:	85 f6                	test   %esi,%esi
  800da6:	74 18                	je     800dc0 <strncpy+0x2a>
  800da8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800dad:	0f b6 1a             	movzbl (%edx),%ebx
  800db0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db3:	80 3a 01             	cmpb   $0x1,(%edx)
  800db6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db9:	83 c1 01             	add    $0x1,%ecx
  800dbc:	39 ce                	cmp    %ecx,%esi
  800dbe:	77 ed                	ja     800dad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd2:	89 f0                	mov    %esi,%eax
  800dd4:	85 c9                	test   %ecx,%ecx
  800dd6:	74 27                	je     800dff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800dd8:	83 e9 01             	sub    $0x1,%ecx
  800ddb:	74 1d                	je     800dfa <strlcpy+0x36>
  800ddd:	0f b6 1a             	movzbl (%edx),%ebx
  800de0:	84 db                	test   %bl,%bl
  800de2:	74 16                	je     800dfa <strlcpy+0x36>
			*dst++ = *src++;
  800de4:	88 18                	mov    %bl,(%eax)
  800de6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800de9:	83 e9 01             	sub    $0x1,%ecx
  800dec:	74 0e                	je     800dfc <strlcpy+0x38>
			*dst++ = *src++;
  800dee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df1:	0f b6 1a             	movzbl (%edx),%ebx
  800df4:	84 db                	test   %bl,%bl
  800df6:	75 ec                	jne    800de4 <strlcpy+0x20>
  800df8:	eb 02                	jmp    800dfc <strlcpy+0x38>
  800dfa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dfc:	c6 00 00             	movb   $0x0,(%eax)
  800dff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e0e:	0f b6 01             	movzbl (%ecx),%eax
  800e11:	84 c0                	test   %al,%al
  800e13:	74 15                	je     800e2a <strcmp+0x25>
  800e15:	3a 02                	cmp    (%edx),%al
  800e17:	75 11                	jne    800e2a <strcmp+0x25>
		p++, q++;
  800e19:	83 c1 01             	add    $0x1,%ecx
  800e1c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e1f:	0f b6 01             	movzbl (%ecx),%eax
  800e22:	84 c0                	test   %al,%al
  800e24:	74 04                	je     800e2a <strcmp+0x25>
  800e26:	3a 02                	cmp    (%edx),%al
  800e28:	74 ef                	je     800e19 <strcmp+0x14>
  800e2a:	0f b6 c0             	movzbl %al,%eax
  800e2d:	0f b6 12             	movzbl (%edx),%edx
  800e30:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	53                   	push   %ebx
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	74 23                	je     800e68 <strncmp+0x34>
  800e45:	0f b6 1a             	movzbl (%edx),%ebx
  800e48:	84 db                	test   %bl,%bl
  800e4a:	74 25                	je     800e71 <strncmp+0x3d>
  800e4c:	3a 19                	cmp    (%ecx),%bl
  800e4e:	75 21                	jne    800e71 <strncmp+0x3d>
  800e50:	83 e8 01             	sub    $0x1,%eax
  800e53:	74 13                	je     800e68 <strncmp+0x34>
		n--, p++, q++;
  800e55:	83 c2 01             	add    $0x1,%edx
  800e58:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e5b:	0f b6 1a             	movzbl (%edx),%ebx
  800e5e:	84 db                	test   %bl,%bl
  800e60:	74 0f                	je     800e71 <strncmp+0x3d>
  800e62:	3a 19                	cmp    (%ecx),%bl
  800e64:	74 ea                	je     800e50 <strncmp+0x1c>
  800e66:	eb 09                	jmp    800e71 <strncmp+0x3d>
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e6d:	5b                   	pop    %ebx
  800e6e:	5d                   	pop    %ebp
  800e6f:	90                   	nop
  800e70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e71:	0f b6 02             	movzbl (%edx),%eax
  800e74:	0f b6 11             	movzbl (%ecx),%edx
  800e77:	29 d0                	sub    %edx,%eax
  800e79:	eb f2                	jmp    800e6d <strncmp+0x39>

00800e7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e85:	0f b6 10             	movzbl (%eax),%edx
  800e88:	84 d2                	test   %dl,%dl
  800e8a:	74 18                	je     800ea4 <strchr+0x29>
		if (*s == c)
  800e8c:	38 ca                	cmp    %cl,%dl
  800e8e:	75 0a                	jne    800e9a <strchr+0x1f>
  800e90:	eb 17                	jmp    800ea9 <strchr+0x2e>
  800e92:	38 ca                	cmp    %cl,%dl
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	74 0f                	je     800ea9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e9a:	83 c0 01             	add    $0x1,%eax
  800e9d:	0f b6 10             	movzbl (%eax),%edx
  800ea0:	84 d2                	test   %dl,%dl
  800ea2:	75 ee                	jne    800e92 <strchr+0x17>
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eb5:	0f b6 10             	movzbl (%eax),%edx
  800eb8:	84 d2                	test   %dl,%dl
  800eba:	74 18                	je     800ed4 <strfind+0x29>
		if (*s == c)
  800ebc:	38 ca                	cmp    %cl,%dl
  800ebe:	75 0a                	jne    800eca <strfind+0x1f>
  800ec0:	eb 12                	jmp    800ed4 <strfind+0x29>
  800ec2:	38 ca                	cmp    %cl,%dl
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	74 0a                	je     800ed4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eca:	83 c0 01             	add    $0x1,%eax
  800ecd:	0f b6 10             	movzbl (%eax),%edx
  800ed0:	84 d2                	test   %dl,%dl
  800ed2:	75 ee                	jne    800ec2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	89 1c 24             	mov    %ebx,(%esp)
  800edf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ef0:	85 c9                	test   %ecx,%ecx
  800ef2:	74 30                	je     800f24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ef4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800efa:	75 25                	jne    800f21 <memset+0x4b>
  800efc:	f6 c1 03             	test   $0x3,%cl
  800eff:	75 20                	jne    800f21 <memset+0x4b>
		c &= 0xFF;
  800f01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f04:	89 d3                	mov    %edx,%ebx
  800f06:	c1 e3 08             	shl    $0x8,%ebx
  800f09:	89 d6                	mov    %edx,%esi
  800f0b:	c1 e6 18             	shl    $0x18,%esi
  800f0e:	89 d0                	mov    %edx,%eax
  800f10:	c1 e0 10             	shl    $0x10,%eax
  800f13:	09 f0                	or     %esi,%eax
  800f15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800f17:	09 d8                	or     %ebx,%eax
  800f19:	c1 e9 02             	shr    $0x2,%ecx
  800f1c:	fc                   	cld    
  800f1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f1f:	eb 03                	jmp    800f24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f21:	fc                   	cld    
  800f22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f24:	89 f8                	mov    %edi,%eax
  800f26:	8b 1c 24             	mov    (%esp),%ebx
  800f29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f31:	89 ec                	mov    %ebp,%esp
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	89 34 24             	mov    %esi,(%esp)
  800f3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800f4d:	39 c6                	cmp    %eax,%esi
  800f4f:	73 35                	jae    800f86 <memmove+0x51>
  800f51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f54:	39 d0                	cmp    %edx,%eax
  800f56:	73 2e                	jae    800f86 <memmove+0x51>
		s += n;
		d += n;
  800f58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f5a:	f6 c2 03             	test   $0x3,%dl
  800f5d:	75 1b                	jne    800f7a <memmove+0x45>
  800f5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f65:	75 13                	jne    800f7a <memmove+0x45>
  800f67:	f6 c1 03             	test   $0x3,%cl
  800f6a:	75 0e                	jne    800f7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800f6c:	83 ef 04             	sub    $0x4,%edi
  800f6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f72:	c1 e9 02             	shr    $0x2,%ecx
  800f75:	fd                   	std    
  800f76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f78:	eb 09                	jmp    800f83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f7a:	83 ef 01             	sub    $0x1,%edi
  800f7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f80:	fd                   	std    
  800f81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f84:	eb 20                	jmp    800fa6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f8c:	75 15                	jne    800fa3 <memmove+0x6e>
  800f8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f94:	75 0d                	jne    800fa3 <memmove+0x6e>
  800f96:	f6 c1 03             	test   $0x3,%cl
  800f99:	75 08                	jne    800fa3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800f9b:	c1 e9 02             	shr    $0x2,%ecx
  800f9e:	fc                   	cld    
  800f9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa1:	eb 03                	jmp    800fa6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fa3:	fc                   	cld    
  800fa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fa6:	8b 34 24             	mov    (%esp),%esi
  800fa9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fad:	89 ec                	mov    %ebp,%esp
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	89 04 24             	mov    %eax,(%esp)
  800fcb:	e8 65 ff ff ff       	call   800f35 <memmove>
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe1:	85 c9                	test   %ecx,%ecx
  800fe3:	74 36                	je     80101b <memcmp+0x49>
		if (*s1 != *s2)
  800fe5:	0f b6 06             	movzbl (%esi),%eax
  800fe8:	0f b6 1f             	movzbl (%edi),%ebx
  800feb:	38 d8                	cmp    %bl,%al
  800fed:	74 20                	je     80100f <memcmp+0x3d>
  800fef:	eb 14                	jmp    801005 <memcmp+0x33>
  800ff1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ff6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ffb:	83 c2 01             	add    $0x1,%edx
  800ffe:	83 e9 01             	sub    $0x1,%ecx
  801001:	38 d8                	cmp    %bl,%al
  801003:	74 12                	je     801017 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801005:	0f b6 c0             	movzbl %al,%eax
  801008:	0f b6 db             	movzbl %bl,%ebx
  80100b:	29 d8                	sub    %ebx,%eax
  80100d:	eb 11                	jmp    801020 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80100f:	83 e9 01             	sub    $0x1,%ecx
  801012:	ba 00 00 00 00       	mov    $0x0,%edx
  801017:	85 c9                	test   %ecx,%ecx
  801019:	75 d6                	jne    800ff1 <memcmp+0x1f>
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80102b:	89 c2                	mov    %eax,%edx
  80102d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801030:	39 d0                	cmp    %edx,%eax
  801032:	73 15                	jae    801049 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801034:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801038:	38 08                	cmp    %cl,(%eax)
  80103a:	75 06                	jne    801042 <memfind+0x1d>
  80103c:	eb 0b                	jmp    801049 <memfind+0x24>
  80103e:	38 08                	cmp    %cl,(%eax)
  801040:	74 07                	je     801049 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801042:	83 c0 01             	add    $0x1,%eax
  801045:	39 c2                	cmp    %eax,%edx
  801047:	77 f5                	ja     80103e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	8b 55 08             	mov    0x8(%ebp),%edx
  801057:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105a:	0f b6 02             	movzbl (%edx),%eax
  80105d:	3c 20                	cmp    $0x20,%al
  80105f:	74 04                	je     801065 <strtol+0x1a>
  801061:	3c 09                	cmp    $0x9,%al
  801063:	75 0e                	jne    801073 <strtol+0x28>
		s++;
  801065:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801068:	0f b6 02             	movzbl (%edx),%eax
  80106b:	3c 20                	cmp    $0x20,%al
  80106d:	74 f6                	je     801065 <strtol+0x1a>
  80106f:	3c 09                	cmp    $0x9,%al
  801071:	74 f2                	je     801065 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801073:	3c 2b                	cmp    $0x2b,%al
  801075:	75 0c                	jne    801083 <strtol+0x38>
		s++;
  801077:	83 c2 01             	add    $0x1,%edx
  80107a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801081:	eb 15                	jmp    801098 <strtol+0x4d>
	else if (*s == '-')
  801083:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80108a:	3c 2d                	cmp    $0x2d,%al
  80108c:	75 0a                	jne    801098 <strtol+0x4d>
		s++, neg = 1;
  80108e:	83 c2 01             	add    $0x1,%edx
  801091:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801098:	85 db                	test   %ebx,%ebx
  80109a:	0f 94 c0             	sete   %al
  80109d:	74 05                	je     8010a4 <strtol+0x59>
  80109f:	83 fb 10             	cmp    $0x10,%ebx
  8010a2:	75 18                	jne    8010bc <strtol+0x71>
  8010a4:	80 3a 30             	cmpb   $0x30,(%edx)
  8010a7:	75 13                	jne    8010bc <strtol+0x71>
  8010a9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8010ad:	8d 76 00             	lea    0x0(%esi),%esi
  8010b0:	75 0a                	jne    8010bc <strtol+0x71>
		s += 2, base = 16;
  8010b2:	83 c2 02             	add    $0x2,%edx
  8010b5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ba:	eb 15                	jmp    8010d1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010bc:	84 c0                	test   %al,%al
  8010be:	66 90                	xchg   %ax,%ax
  8010c0:	74 0f                	je     8010d1 <strtol+0x86>
  8010c2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8010c7:	80 3a 30             	cmpb   $0x30,(%edx)
  8010ca:	75 05                	jne    8010d1 <strtol+0x86>
		s++, base = 8;
  8010cc:	83 c2 01             	add    $0x1,%edx
  8010cf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d8:	0f b6 0a             	movzbl (%edx),%ecx
  8010db:	89 cf                	mov    %ecx,%edi
  8010dd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8010e0:	80 fb 09             	cmp    $0x9,%bl
  8010e3:	77 08                	ja     8010ed <strtol+0xa2>
			dig = *s - '0';
  8010e5:	0f be c9             	movsbl %cl,%ecx
  8010e8:	83 e9 30             	sub    $0x30,%ecx
  8010eb:	eb 1e                	jmp    80110b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8010ed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8010f0:	80 fb 19             	cmp    $0x19,%bl
  8010f3:	77 08                	ja     8010fd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8010f5:	0f be c9             	movsbl %cl,%ecx
  8010f8:	83 e9 57             	sub    $0x57,%ecx
  8010fb:	eb 0e                	jmp    80110b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8010fd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801100:	80 fb 19             	cmp    $0x19,%bl
  801103:	77 15                	ja     80111a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801105:	0f be c9             	movsbl %cl,%ecx
  801108:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80110b:	39 f1                	cmp    %esi,%ecx
  80110d:	7d 0b                	jge    80111a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80110f:	83 c2 01             	add    $0x1,%edx
  801112:	0f af c6             	imul   %esi,%eax
  801115:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801118:	eb be                	jmp    8010d8 <strtol+0x8d>
  80111a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80111c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801120:	74 05                	je     801127 <strtol+0xdc>
		*endptr = (char *) s;
  801122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801125:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801127:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80112b:	74 04                	je     801131 <strtol+0xe6>
  80112d:	89 c8                	mov    %ecx,%eax
  80112f:	f7 d8                	neg    %eax
}
  801131:	83 c4 04             	add    $0x4,%esp
  801134:	5b                   	pop    %ebx
  801135:	5e                   	pop    %esi
  801136:	5f                   	pop    %edi
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    
  801139:	00 00                	add    %al,(%eax)
  80113b:	00 00                	add    %al,(%eax)
  80113d:	00 00                	add    %al,(%eax)
	...

00801140 <__udivdi3>:
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	83 ec 10             	sub    $0x10,%esp
  801148:	8b 45 14             	mov    0x14(%ebp),%eax
  80114b:	8b 55 08             	mov    0x8(%ebp),%edx
  80114e:	8b 75 10             	mov    0x10(%ebp),%esi
  801151:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801154:	85 c0                	test   %eax,%eax
  801156:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801159:	75 35                	jne    801190 <__udivdi3+0x50>
  80115b:	39 fe                	cmp    %edi,%esi
  80115d:	77 61                	ja     8011c0 <__udivdi3+0x80>
  80115f:	85 f6                	test   %esi,%esi
  801161:	75 0b                	jne    80116e <__udivdi3+0x2e>
  801163:	b8 01 00 00 00       	mov    $0x1,%eax
  801168:	31 d2                	xor    %edx,%edx
  80116a:	f7 f6                	div    %esi
  80116c:	89 c6                	mov    %eax,%esi
  80116e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801171:	31 d2                	xor    %edx,%edx
  801173:	89 f8                	mov    %edi,%eax
  801175:	f7 f6                	div    %esi
  801177:	89 c7                	mov    %eax,%edi
  801179:	89 c8                	mov    %ecx,%eax
  80117b:	f7 f6                	div    %esi
  80117d:	89 c1                	mov    %eax,%ecx
  80117f:	89 fa                	mov    %edi,%edx
  801181:	89 c8                	mov    %ecx,%eax
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	39 f8                	cmp    %edi,%eax
  801192:	77 1c                	ja     8011b0 <__udivdi3+0x70>
  801194:	0f bd d0             	bsr    %eax,%edx
  801197:	83 f2 1f             	xor    $0x1f,%edx
  80119a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80119d:	75 39                	jne    8011d8 <__udivdi3+0x98>
  80119f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8011a2:	0f 86 a0 00 00 00    	jbe    801248 <__udivdi3+0x108>
  8011a8:	39 f8                	cmp    %edi,%eax
  8011aa:	0f 82 98 00 00 00    	jb     801248 <__udivdi3+0x108>
  8011b0:	31 ff                	xor    %edi,%edi
  8011b2:	31 c9                	xor    %ecx,%ecx
  8011b4:	89 c8                	mov    %ecx,%eax
  8011b6:	89 fa                	mov    %edi,%edx
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	5e                   	pop    %esi
  8011bc:	5f                   	pop    %edi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    
  8011bf:	90                   	nop
  8011c0:	89 d1                	mov    %edx,%ecx
  8011c2:	89 fa                	mov    %edi,%edx
  8011c4:	89 c8                	mov    %ecx,%eax
  8011c6:	31 ff                	xor    %edi,%edi
  8011c8:	f7 f6                	div    %esi
  8011ca:	89 c1                	mov    %eax,%ecx
  8011cc:	89 fa                	mov    %edi,%edx
  8011ce:	89 c8                	mov    %ecx,%eax
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    
  8011d7:	90                   	nop
  8011d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	d3 e0                	shl    %cl,%eax
  8011e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011eb:	89 c1                	mov    %eax,%ecx
  8011ed:	d3 ea                	shr    %cl,%edx
  8011ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011f6:	d3 e6                	shl    %cl,%esi
  8011f8:	89 c1                	mov    %eax,%ecx
  8011fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011fd:	89 fe                	mov    %edi,%esi
  8011ff:	d3 ee                	shr    %cl,%esi
  801201:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801205:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801208:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80120b:	d3 e7                	shl    %cl,%edi
  80120d:	89 c1                	mov    %eax,%ecx
  80120f:	d3 ea                	shr    %cl,%edx
  801211:	09 d7                	or     %edx,%edi
  801213:	89 f2                	mov    %esi,%edx
  801215:	89 f8                	mov    %edi,%eax
  801217:	f7 75 ec             	divl   -0x14(%ebp)
  80121a:	89 d6                	mov    %edx,%esi
  80121c:	89 c7                	mov    %eax,%edi
  80121e:	f7 65 e8             	mull   -0x18(%ebp)
  801221:	39 d6                	cmp    %edx,%esi
  801223:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801226:	72 30                	jb     801258 <__udivdi3+0x118>
  801228:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80122b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80122f:	d3 e2                	shl    %cl,%edx
  801231:	39 c2                	cmp    %eax,%edx
  801233:	73 05                	jae    80123a <__udivdi3+0xfa>
  801235:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801238:	74 1e                	je     801258 <__udivdi3+0x118>
  80123a:	89 f9                	mov    %edi,%ecx
  80123c:	31 ff                	xor    %edi,%edi
  80123e:	e9 71 ff ff ff       	jmp    8011b4 <__udivdi3+0x74>
  801243:	90                   	nop
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	31 ff                	xor    %edi,%edi
  80124a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80124f:	e9 60 ff ff ff       	jmp    8011b4 <__udivdi3+0x74>
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80125b:	31 ff                	xor    %edi,%edi
  80125d:	89 c8                	mov    %ecx,%eax
  80125f:	89 fa                	mov    %edi,%edx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    
	...

00801270 <__umoddi3>:
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	57                   	push   %edi
  801274:	56                   	push   %esi
  801275:	83 ec 20             	sub    $0x20,%esp
  801278:	8b 55 14             	mov    0x14(%ebp),%edx
  80127b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801281:	8b 75 0c             	mov    0xc(%ebp),%esi
  801284:	85 d2                	test   %edx,%edx
  801286:	89 c8                	mov    %ecx,%eax
  801288:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80128b:	75 13                	jne    8012a0 <__umoddi3+0x30>
  80128d:	39 f7                	cmp    %esi,%edi
  80128f:	76 3f                	jbe    8012d0 <__umoddi3+0x60>
  801291:	89 f2                	mov    %esi,%edx
  801293:	f7 f7                	div    %edi
  801295:	89 d0                	mov    %edx,%eax
  801297:	31 d2                	xor    %edx,%edx
  801299:	83 c4 20             	add    $0x20,%esp
  80129c:	5e                   	pop    %esi
  80129d:	5f                   	pop    %edi
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    
  8012a0:	39 f2                	cmp    %esi,%edx
  8012a2:	77 4c                	ja     8012f0 <__umoddi3+0x80>
  8012a4:	0f bd ca             	bsr    %edx,%ecx
  8012a7:	83 f1 1f             	xor    $0x1f,%ecx
  8012aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8012ad:	75 51                	jne    801300 <__umoddi3+0x90>
  8012af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8012b2:	0f 87 e0 00 00 00    	ja     801398 <__umoddi3+0x128>
  8012b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bb:	29 f8                	sub    %edi,%eax
  8012bd:	19 d6                	sbb    %edx,%esi
  8012bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c5:	89 f2                	mov    %esi,%edx
  8012c7:	83 c4 20             	add    $0x20,%esp
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    
  8012ce:	66 90                	xchg   %ax,%ax
  8012d0:	85 ff                	test   %edi,%edi
  8012d2:	75 0b                	jne    8012df <__umoddi3+0x6f>
  8012d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d9:	31 d2                	xor    %edx,%edx
  8012db:	f7 f7                	div    %edi
  8012dd:	89 c7                	mov    %eax,%edi
  8012df:	89 f0                	mov    %esi,%eax
  8012e1:	31 d2                	xor    %edx,%edx
  8012e3:	f7 f7                	div    %edi
  8012e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e8:	f7 f7                	div    %edi
  8012ea:	eb a9                	jmp    801295 <__umoddi3+0x25>
  8012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	89 c8                	mov    %ecx,%eax
  8012f2:	89 f2                	mov    %esi,%edx
  8012f4:	83 c4 20             	add    $0x20,%esp
  8012f7:	5e                   	pop    %esi
  8012f8:	5f                   	pop    %edi
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    
  8012fb:	90                   	nop
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801304:	d3 e2                	shl    %cl,%edx
  801306:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801309:	ba 20 00 00 00       	mov    $0x20,%edx
  80130e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801311:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801314:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801318:	89 fa                	mov    %edi,%edx
  80131a:	d3 ea                	shr    %cl,%edx
  80131c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801320:	0b 55 f4             	or     -0xc(%ebp),%edx
  801323:	d3 e7                	shl    %cl,%edi
  801325:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801329:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80132c:	89 f2                	mov    %esi,%edx
  80132e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801331:	89 c7                	mov    %eax,%edi
  801333:	d3 ea                	shr    %cl,%edx
  801335:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801339:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	d3 e6                	shl    %cl,%esi
  801340:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801344:	d3 ea                	shr    %cl,%edx
  801346:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80134a:	09 d6                	or     %edx,%esi
  80134c:	89 f0                	mov    %esi,%eax
  80134e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801351:	d3 e7                	shl    %cl,%edi
  801353:	89 f2                	mov    %esi,%edx
  801355:	f7 75 f4             	divl   -0xc(%ebp)
  801358:	89 d6                	mov    %edx,%esi
  80135a:	f7 65 e8             	mull   -0x18(%ebp)
  80135d:	39 d6                	cmp    %edx,%esi
  80135f:	72 2b                	jb     80138c <__umoddi3+0x11c>
  801361:	39 c7                	cmp    %eax,%edi
  801363:	72 23                	jb     801388 <__umoddi3+0x118>
  801365:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801369:	29 c7                	sub    %eax,%edi
  80136b:	19 d6                	sbb    %edx,%esi
  80136d:	89 f0                	mov    %esi,%eax
  80136f:	89 f2                	mov    %esi,%edx
  801371:	d3 ef                	shr    %cl,%edi
  801373:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801377:	d3 e0                	shl    %cl,%eax
  801379:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80137d:	09 f8                	or     %edi,%eax
  80137f:	d3 ea                	shr    %cl,%edx
  801381:	83 c4 20             	add    $0x20,%esp
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
  801388:	39 d6                	cmp    %edx,%esi
  80138a:	75 d9                	jne    801365 <__umoddi3+0xf5>
  80138c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80138f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801392:	eb d1                	jmp    801365 <__umoddi3+0xf5>
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	39 f2                	cmp    %esi,%edx
  80139a:	0f 82 18 ff ff ff    	jb     8012b8 <__umoddi3+0x48>
  8013a0:	e9 1d ff ff ff       	jmp    8012c2 <__umoddi3+0x52>
