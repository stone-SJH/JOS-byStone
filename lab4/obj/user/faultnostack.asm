
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 78 05 80 	movl   $0x800578,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 de 01 00 00       	call   80022c <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  80006e:	e8 57 04 00 00       	call   8004ca <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	c1 e0 07             	shl    $0x7,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 4c 04 00 00       	call   80050a <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	51                   	push   %ecx
  8000de:	52                   	push   %edx
  8000df:	53                   	push   %ebx
  8000e0:	54                   	push   %esp
  8000e1:	55                   	push   %ebp
  8000e2:	56                   	push   %esi
  8000e3:	57                   	push   %edi
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	8d 35 ee 00 80 00    	lea    0x8000ee,%esi
  8000ec:	0f 34                	sysenter 
  8000ee:	5f                   	pop    %edi
  8000ef:	5e                   	pop    %esi
  8000f0:	5d                   	pop    %ebp
  8000f1:	5c                   	pop    %esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5a                   	pop    %edx
  8000f4:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	8b 1c 24             	mov    (%esp),%ebx
  8000f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000fc:	89 ec                	mov    %ebp,%esp
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	89 1c 24             	mov    %ebx,(%esp)
  800109:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80010d:	b8 00 00 00 00       	mov    $0x0,%eax
  800112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 c3                	mov    %eax,%ebx
  80011a:	89 c7                	mov    %eax,%edi
  80011c:	51                   	push   %ecx
  80011d:	52                   	push   %edx
  80011e:	53                   	push   %ebx
  80011f:	54                   	push   %esp
  800120:	55                   	push   %ebp
  800121:	56                   	push   %esi
  800122:	57                   	push   %edi
  800123:	89 e5                	mov    %esp,%ebp
  800125:	8d 35 2d 01 80 00    	lea    0x80012d,%esi
  80012b:	0f 34                	sysenter 
  80012d:	5f                   	pop    %edi
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	5c                   	pop    %esp
  800131:	5b                   	pop    %ebx
  800132:	5a                   	pop    %edx
  800133:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800134:	8b 1c 24             	mov    (%esp),%ebx
  800137:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80013b:	89 ec                	mov    %ebp,%esp
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
  800145:	89 1c 24             	mov    %ebx,(%esp)
  800148:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80014c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800151:	b8 0e 00 00 00       	mov    $0xe,%eax
  800156:	8b 55 08             	mov    0x8(%ebp),%edx
  800159:	89 cb                	mov    %ecx,%ebx
  80015b:	89 cf                	mov    %ecx,%edi
  80015d:	51                   	push   %ecx
  80015e:	52                   	push   %edx
  80015f:	53                   	push   %ebx
  800160:	54                   	push   %esp
  800161:	55                   	push   %ebp
  800162:	56                   	push   %esi
  800163:	57                   	push   %edi
  800164:	89 e5                	mov    %esp,%ebp
  800166:	8d 35 6e 01 80 00    	lea    0x80016e,%esi
  80016c:	0f 34                	sysenter 
  80016e:	5f                   	pop    %edi
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	5c                   	pop    %esp
  800172:	5b                   	pop    %ebx
  800173:	5a                   	pop    %edx
  800174:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800175:	8b 1c 24             	mov    (%esp),%ebx
  800178:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80017c:	89 ec                	mov    %ebp,%esp
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 28             	sub    $0x28,%esp
  800186:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800189:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80018c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800191:	b8 0d 00 00 00       	mov    $0xd,%eax
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 cb                	mov    %ecx,%ebx
  80019b:	89 cf                	mov    %ecx,%edi
  80019d:	51                   	push   %ecx
  80019e:	52                   	push   %edx
  80019f:	53                   	push   %ebx
  8001a0:	54                   	push   %esp
  8001a1:	55                   	push   %ebp
  8001a2:	56                   	push   %esi
  8001a3:	57                   	push   %edi
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	8d 35 ae 01 80 00    	lea    0x8001ae,%esi
  8001ac:	0f 34                	sysenter 
  8001ae:	5f                   	pop    %edi
  8001af:	5e                   	pop    %esi
  8001b0:	5d                   	pop    %ebp
  8001b1:	5c                   	pop    %esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5a                   	pop    %edx
  8001b4:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001b5:	85 c0                	test   %eax,%eax
  8001b7:	7e 28                	jle    8001e1 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001bd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8001dc:	e8 a3 03 00 00       	call   800584 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001e1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001e7:	89 ec                	mov    %ebp,%esp
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	89 1c 24             	mov    %ebx,(%esp)
  8001f4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001fd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800200:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800206:	8b 55 08             	mov    0x8(%ebp),%edx
  800209:	51                   	push   %ecx
  80020a:	52                   	push   %edx
  80020b:	53                   	push   %ebx
  80020c:	54                   	push   %esp
  80020d:	55                   	push   %ebp
  80020e:	56                   	push   %esi
  80020f:	57                   	push   %edi
  800210:	89 e5                	mov    %esp,%ebp
  800212:	8d 35 1a 02 80 00    	lea    0x80021a,%esi
  800218:	0f 34                	sysenter 
  80021a:	5f                   	pop    %edi
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	5c                   	pop    %esp
  80021e:	5b                   	pop    %ebx
  80021f:	5a                   	pop    %edx
  800220:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800221:	8b 1c 24             	mov    (%esp),%ebx
  800224:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800228:	89 ec                	mov    %ebp,%esp
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 28             	sub    $0x28,%esp
  800232:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800235:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	51                   	push   %ecx
  80024b:	52                   	push   %edx
  80024c:	53                   	push   %ebx
  80024d:	54                   	push   %esp
  80024e:	55                   	push   %ebp
  80024f:	56                   	push   %esi
  800250:	57                   	push   %edi
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8d 35 5b 02 80 00    	lea    0x80025b,%esi
  800259:	0f 34                	sysenter 
  80025b:	5f                   	pop    %edi
  80025c:	5e                   	pop    %esi
  80025d:	5d                   	pop    %ebp
  80025e:	5c                   	pop    %esp
  80025f:	5b                   	pop    %ebx
  800260:	5a                   	pop    %edx
  800261:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800262:	85 c0                	test   %eax,%eax
  800264:	7e 28                	jle    80028e <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800266:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800271:	00 
  800272:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  800279:	00 
  80027a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  800289:	e8 f6 02 00 00       	call   800584 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800291:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800294:	89 ec                	mov    %ebp,%esp
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	83 ec 28             	sub    $0x28,%esp
  80029e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002a1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	89 df                	mov    %ebx,%edi
  8002b6:	51                   	push   %ecx
  8002b7:	52                   	push   %edx
  8002b8:	53                   	push   %ebx
  8002b9:	54                   	push   %esp
  8002ba:	55                   	push   %ebp
  8002bb:	56                   	push   %esi
  8002bc:	57                   	push   %edi
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8d 35 c7 02 80 00    	lea    0x8002c7,%esi
  8002c5:	0f 34                	sysenter 
  8002c7:	5f                   	pop    %edi
  8002c8:	5e                   	pop    %esi
  8002c9:	5d                   	pop    %ebp
  8002ca:	5c                   	pop    %esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5a                   	pop    %edx
  8002cd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 28                	jle    8002fa <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002dd:	00 
  8002de:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002ed:	00 
  8002ee:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8002f5:	e8 8a 02 00 00       	call   800584 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002fa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800300:	89 ec                	mov    %ebp,%esp
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 28             	sub    $0x28,%esp
  80030a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80030d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800310:	bb 00 00 00 00       	mov    $0x0,%ebx
  800315:	b8 07 00 00 00       	mov    $0x7,%eax
  80031a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 df                	mov    %ebx,%edi
  800322:	51                   	push   %ecx
  800323:	52                   	push   %edx
  800324:	53                   	push   %ebx
  800325:	54                   	push   %esp
  800326:	55                   	push   %ebp
  800327:	56                   	push   %esi
  800328:	57                   	push   %edi
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8d 35 33 03 80 00    	lea    0x800333,%esi
  800331:	0f 34                	sysenter 
  800333:	5f                   	pop    %edi
  800334:	5e                   	pop    %esi
  800335:	5d                   	pop    %ebp
  800336:	5c                   	pop    %esp
  800337:	5b                   	pop    %ebx
  800338:	5a                   	pop    %edx
  800339:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80033a:	85 c0                	test   %eax,%eax
  80033c:	7e 28                	jle    800366 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800342:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800349:	00 
  80034a:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  800351:	00 
  800352:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800359:	00 
  80035a:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  800361:	e8 1e 02 00 00       	call   800584 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800366:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800369:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80036c:	89 ec                	mov    %ebp,%esp
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 28             	sub    $0x28,%esp
  800376:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800379:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80037c:	b8 06 00 00 00       	mov    $0x6,%eax
  800381:	8b 7d 14             	mov    0x14(%ebp),%edi
  800384:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038a:	8b 55 08             	mov    0x8(%ebp),%edx
  80038d:	51                   	push   %ecx
  80038e:	52                   	push   %edx
  80038f:	53                   	push   %ebx
  800390:	54                   	push   %esp
  800391:	55                   	push   %ebp
  800392:	56                   	push   %esi
  800393:	57                   	push   %edi
  800394:	89 e5                	mov    %esp,%ebp
  800396:	8d 35 9e 03 80 00    	lea    0x80039e,%esi
  80039c:	0f 34                	sysenter 
  80039e:	5f                   	pop    %edi
  80039f:	5e                   	pop    %esi
  8003a0:	5d                   	pop    %ebp
  8003a1:	5c                   	pop    %esp
  8003a2:	5b                   	pop    %ebx
  8003a3:	5a                   	pop    %edx
  8003a4:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	7e 28                	jle    8003d1 <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ad:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8003b4:	00 
  8003b5:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8003c4:	00 
  8003c5:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8003cc:	e8 b3 01 00 00       	call   800584 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8003d1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d7:	89 ec                	mov    %ebp,%esp
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 28             	sub    $0x28,%esp
  8003e1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003e4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8003ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8003f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fa:	51                   	push   %ecx
  8003fb:	52                   	push   %edx
  8003fc:	53                   	push   %ebx
  8003fd:	54                   	push   %esp
  8003fe:	55                   	push   %ebp
  8003ff:	56                   	push   %esi
  800400:	57                   	push   %edi
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8d 35 0b 04 80 00    	lea    0x80040b,%esi
  800409:	0f 34                	sysenter 
  80040b:	5f                   	pop    %edi
  80040c:	5e                   	pop    %esi
  80040d:	5d                   	pop    %ebp
  80040e:	5c                   	pop    %esp
  80040f:	5b                   	pop    %ebx
  800410:	5a                   	pop    %edx
  800411:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800412:	85 c0                	test   %eax,%eax
  800414:	7e 28                	jle    80043e <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800416:	89 44 24 10          	mov    %eax,0x10(%esp)
  80041a:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800421:	00 
  800422:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  800429:	00 
  80042a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800431:	00 
  800432:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  800439:	e8 46 01 00 00       	call   800584 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80043e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800441:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800444:	89 ec                	mov    %ebp,%esp
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	89 1c 24             	mov    %ebx,(%esp)
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800455:	ba 00 00 00 00       	mov    $0x0,%edx
  80045a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80045f:	89 d1                	mov    %edx,%ecx
  800461:	89 d3                	mov    %edx,%ebx
  800463:	89 d7                	mov    %edx,%edi
  800465:	51                   	push   %ecx
  800466:	52                   	push   %edx
  800467:	53                   	push   %ebx
  800468:	54                   	push   %esp
  800469:	55                   	push   %ebp
  80046a:	56                   	push   %esi
  80046b:	57                   	push   %edi
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	8d 35 76 04 80 00    	lea    0x800476,%esi
  800474:	0f 34                	sysenter 
  800476:	5f                   	pop    %edi
  800477:	5e                   	pop    %esi
  800478:	5d                   	pop    %ebp
  800479:	5c                   	pop    %esp
  80047a:	5b                   	pop    %ebx
  80047b:	5a                   	pop    %edx
  80047c:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80047d:	8b 1c 24             	mov    (%esp),%ebx
  800480:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800484:	89 ec                	mov    %ebp,%esp
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	89 1c 24             	mov    %ebx,(%esp)
  800491:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800495:	bb 00 00 00 00       	mov    $0x0,%ebx
  80049a:	b8 04 00 00 00       	mov    $0x4,%eax
  80049f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a5:	89 df                	mov    %ebx,%edi
  8004a7:	51                   	push   %ecx
  8004a8:	52                   	push   %edx
  8004a9:	53                   	push   %ebx
  8004aa:	54                   	push   %esp
  8004ab:	55                   	push   %ebp
  8004ac:	56                   	push   %esi
  8004ad:	57                   	push   %edi
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	8d 35 b8 04 80 00    	lea    0x8004b8,%esi
  8004b6:	0f 34                	sysenter 
  8004b8:	5f                   	pop    %edi
  8004b9:	5e                   	pop    %esi
  8004ba:	5d                   	pop    %ebp
  8004bb:	5c                   	pop    %esp
  8004bc:	5b                   	pop    %ebx
  8004bd:	5a                   	pop    %edx
  8004be:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8004bf:	8b 1c 24             	mov    (%esp),%ebx
  8004c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004c6:	89 ec                	mov    %ebp,%esp
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	89 1c 24             	mov    %ebx,(%esp)
  8004d3:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8004e1:	89 d1                	mov    %edx,%ecx
  8004e3:	89 d3                	mov    %edx,%ebx
  8004e5:	89 d7                	mov    %edx,%edi
  8004e7:	51                   	push   %ecx
  8004e8:	52                   	push   %edx
  8004e9:	53                   	push   %ebx
  8004ea:	54                   	push   %esp
  8004eb:	55                   	push   %ebp
  8004ec:	56                   	push   %esi
  8004ed:	57                   	push   %edi
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	8d 35 f8 04 80 00    	lea    0x8004f8,%esi
  8004f6:	0f 34                	sysenter 
  8004f8:	5f                   	pop    %edi
  8004f9:	5e                   	pop    %esi
  8004fa:	5d                   	pop    %ebp
  8004fb:	5c                   	pop    %esp
  8004fc:	5b                   	pop    %ebx
  8004fd:	5a                   	pop    %edx
  8004fe:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004ff:	8b 1c 24             	mov    (%esp),%ebx
  800502:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800506:	89 ec                	mov    %ebp,%esp
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	83 ec 28             	sub    $0x28,%esp
  800510:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800513:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800516:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051b:	b8 03 00 00 00       	mov    $0x3,%eax
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 cb                	mov    %ecx,%ebx
  800525:	89 cf                	mov    %ecx,%edi
  800527:	51                   	push   %ecx
  800528:	52                   	push   %edx
  800529:	53                   	push   %ebx
  80052a:	54                   	push   %esp
  80052b:	55                   	push   %ebp
  80052c:	56                   	push   %esi
  80052d:	57                   	push   %edi
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	8d 35 38 05 80 00    	lea    0x800538,%esi
  800536:	0f 34                	sysenter 
  800538:	5f                   	pop    %edi
  800539:	5e                   	pop    %esi
  80053a:	5d                   	pop    %ebp
  80053b:	5c                   	pop    %esp
  80053c:	5b                   	pop    %ebx
  80053d:	5a                   	pop    %edx
  80053e:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80053f:	85 c0                	test   %eax,%eax
  800541:	7e 28                	jle    80056b <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800543:	89 44 24 10          	mov    %eax,0x10(%esp)
  800547:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80054e:	00 
  80054f:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  800556:	00 
  800557:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80055e:	00 
  80055f:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  800566:	e8 19 00 00 00       	call   800584 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80056b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80056e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800571:	89 ec                	mov    %ebp,%esp
  800573:	5d                   	pop    %ebp
  800574:	c3                   	ret    
  800575:	00 00                	add    %al,(%eax)
	...

00800578 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800578:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800579:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80057e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800580:	83 c4 04             	add    $0x4,%esp
	...

00800584 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	56                   	push   %esi
  800588:	53                   	push   %ebx
  800589:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80058c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80058f:	a1 08 20 80 00       	mov    0x802008,%eax
  800594:	85 c0                	test   %eax,%eax
  800596:	74 10                	je     8005a8 <_panic+0x24>
		cprintf("%s: ", argv0);
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	c7 04 24 15 14 80 00 	movl   $0x801415,(%esp)
  8005a3:	e8 ad 00 00 00       	call   800655 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005a8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005ae:	e8 17 ff ff ff       	call   8004ca <sys_getenvid>
  8005b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8005bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c9:	c7 04 24 1c 14 80 00 	movl   $0x80141c,(%esp)
  8005d0:	e8 80 00 00 00       	call   800655 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 10 00 00 00       	call   8005f4 <vcprintf>
	cprintf("\n");
  8005e4:	c7 04 24 1a 14 80 00 	movl   $0x80141a,(%esp)
  8005eb:	e8 65 00 00 00       	call   800655 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f0:	cc                   	int3   
  8005f1:	eb fd                	jmp    8005f0 <_panic+0x6c>
	...

008005f4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800604:	00 00 00 
	b.cnt = 0;
  800607:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80060e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800611:	8b 45 0c             	mov    0xc(%ebp),%eax
  800614:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	c7 04 24 6f 06 80 00 	movl   $0x80066f,(%esp)
  800630:	e8 d8 01 00 00       	call   80080d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800635:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	e8 b3 fa ff ff       	call   800100 <sys_cputs>

	return b.cnt;
}
  80064d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800653:	c9                   	leave  
  800654:	c3                   	ret    

00800655 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80065b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80065e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800662:	8b 45 08             	mov    0x8(%ebp),%eax
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	e8 87 ff ff ff       	call   8005f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80066d:	c9                   	leave  
  80066e:	c3                   	ret    

0080066f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	53                   	push   %ebx
  800673:	83 ec 14             	sub    $0x14,%esp
  800676:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800679:	8b 03                	mov    (%ebx),%eax
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
  80067e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800682:	83 c0 01             	add    $0x1,%eax
  800685:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800687:	3d ff 00 00 00       	cmp    $0xff,%eax
  80068c:	75 19                	jne    8006a7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80068e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800695:	00 
  800696:	8d 43 08             	lea    0x8(%ebx),%eax
  800699:	89 04 24             	mov    %eax,(%esp)
  80069c:	e8 5f fa ff ff       	call   800100 <sys_cputs>
		b->idx = 0;
  8006a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8006a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006ab:	83 c4 14             	add    $0x14,%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    
	...

008006c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 4c             	sub    $0x4c,%esp
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cc:	89 d6                	mov    %edx,%esi
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006eb:	39 d1                	cmp    %edx,%ecx
  8006ed:	72 15                	jb     800704 <printnum+0x44>
  8006ef:	77 07                	ja     8006f8 <printnum+0x38>
  8006f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f4:	39 d0                	cmp    %edx,%eax
  8006f6:	76 0c                	jbe    800704 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006f8:	83 eb 01             	sub    $0x1,%ebx
  8006fb:	85 db                	test   %ebx,%ebx
  8006fd:	8d 76 00             	lea    0x0(%esi),%esi
  800700:	7f 61                	jg     800763 <printnum+0xa3>
  800702:	eb 70                	jmp    800774 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800704:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800708:	83 eb 01             	sub    $0x1,%ebx
  80070b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80070f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800713:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800717:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80071b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80071e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800721:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800724:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800728:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80072f:	00 
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800739:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073d:	e8 2e 0a 00 00       	call   801170 <__udivdi3>
  800742:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800745:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800748:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	89 54 24 04          	mov    %edx,0x4(%esp)
  800757:	89 f2                	mov    %esi,%edx
  800759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075c:	e8 5f ff ff ff       	call   8006c0 <printnum>
  800761:	eb 11                	jmp    800774 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800763:	89 74 24 04          	mov    %esi,0x4(%esp)
  800767:	89 3c 24             	mov    %edi,(%esp)
  80076a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80076d:	83 eb 01             	sub    $0x1,%ebx
  800770:	85 db                	test   %ebx,%ebx
  800772:	7f ef                	jg     800763 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800774:	89 74 24 04          	mov    %esi,0x4(%esp)
  800778:	8b 74 24 04          	mov    0x4(%esp),%esi
  80077c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80078a:	00 
  80078b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80078e:	89 14 24             	mov    %edx,(%esp)
  800791:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800794:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800798:	e8 03 0b 00 00       	call   8012a0 <__umoddi3>
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ae:	83 c4 4c             	add    $0x4c,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b9:	83 fa 01             	cmp    $0x1,%edx
  8007bc:	7e 0e                	jle    8007cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 02                	mov    (%edx),%eax
  8007c7:	8b 52 04             	mov    0x4(%edx),%edx
  8007ca:	eb 22                	jmp    8007ee <getuint+0x38>
	else if (lflag)
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 10                	je     8007e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d5:	89 08                	mov    %ecx,(%eax)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 0e                	jmp    8007ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ff:	73 0a                	jae    80080b <sprintputch+0x1b>
		*b->buf++ = ch;
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	88 0a                	mov    %cl,(%edx)
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	89 10                	mov    %edx,(%eax)
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	57                   	push   %edi
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	83 ec 5c             	sub    $0x5c,%esp
  800816:	8b 7d 08             	mov    0x8(%ebp),%edi
  800819:	8b 75 0c             	mov    0xc(%ebp),%esi
  80081c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80081f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800826:	eb 11                	jmp    800839 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800828:	85 c0                	test   %eax,%eax
  80082a:	0f 84 09 04 00 00    	je     800c39 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800830:	89 74 24 04          	mov    %esi,0x4(%esp)
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800839:	0f b6 03             	movzbl (%ebx),%eax
  80083c:	83 c3 01             	add    $0x1,%ebx
  80083f:	83 f8 25             	cmp    $0x25,%eax
  800842:	75 e4                	jne    800828 <vprintfmt+0x1b>
  800844:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800848:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80084f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800856:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	eb 06                	jmp    80086a <vprintfmt+0x5d>
  800864:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800868:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	0f b6 13             	movzbl (%ebx),%edx
  80086d:	0f b6 c2             	movzbl %dl,%eax
  800870:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800873:	8d 43 01             	lea    0x1(%ebx),%eax
  800876:	83 ea 23             	sub    $0x23,%edx
  800879:	80 fa 55             	cmp    $0x55,%dl
  80087c:	0f 87 9a 03 00 00    	ja     800c1c <vprintfmt+0x40f>
  800882:	0f b6 d2             	movzbl %dl,%edx
  800885:	ff 24 95 00 15 80 00 	jmp    *0x801500(,%edx,4)
  80088c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800890:	eb d6                	jmp    800868 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800892:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800895:	83 ea 30             	sub    $0x30,%edx
  800898:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80089b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80089e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8008a1:	83 fb 09             	cmp    $0x9,%ebx
  8008a4:	77 4c                	ja     8008f2 <vprintfmt+0xe5>
  8008a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8008a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ac:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8008af:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8008b2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8008b6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8008bc:	83 fb 09             	cmp    $0x9,%ebx
  8008bf:	76 eb                	jbe    8008ac <vprintfmt+0x9f>
  8008c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008c7:	eb 29                	jmp    8008f2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8008cc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8008cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8008d2:	8b 12                	mov    (%edx),%edx
  8008d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8008d7:	eb 19                	jmp    8008f2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8008d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008dc:	c1 fa 1f             	sar    $0x1f,%edx
  8008df:	f7 d2                	not    %edx
  8008e1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8008e4:	eb 82                	jmp    800868 <vprintfmt+0x5b>
  8008e6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8008ed:	e9 76 ff ff ff       	jmp    800868 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8008f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f6:	0f 89 6c ff ff ff    	jns    800868 <vprintfmt+0x5b>
  8008fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800902:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800905:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800908:	e9 5b ff ff ff       	jmp    800868 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80090d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800910:	e9 53 ff ff ff       	jmp    800868 <vprintfmt+0x5b>
  800915:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800918:	8b 45 14             	mov    0x14(%ebp),%eax
  80091b:	8d 50 04             	lea    0x4(%eax),%edx
  80091e:	89 55 14             	mov    %edx,0x14(%ebp)
  800921:	89 74 24 04          	mov    %esi,0x4(%esp)
  800925:	8b 00                	mov    (%eax),%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	ff d7                	call   *%edi
  80092c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80092f:	e9 05 ff ff ff       	jmp    800839 <vprintfmt+0x2c>
  800934:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8d 50 04             	lea    0x4(%eax),%edx
  80093d:	89 55 14             	mov    %edx,0x14(%ebp)
  800940:	8b 00                	mov    (%eax),%eax
  800942:	89 c2                	mov    %eax,%edx
  800944:	c1 fa 1f             	sar    $0x1f,%edx
  800947:	31 d0                	xor    %edx,%eax
  800949:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094b:	83 f8 08             	cmp    $0x8,%eax
  80094e:	7f 0b                	jg     80095b <vprintfmt+0x14e>
  800950:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  800957:	85 d2                	test   %edx,%edx
  800959:	75 20                	jne    80097b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80095b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095f:	c7 44 24 08 50 14 80 	movl   $0x801450,0x8(%esp)
  800966:	00 
  800967:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096b:	89 3c 24             	mov    %edi,(%esp)
  80096e:	e8 4e 03 00 00       	call   800cc1 <printfmt>
  800973:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800976:	e9 be fe ff ff       	jmp    800839 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80097b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80097f:	c7 44 24 08 59 14 80 	movl   $0x801459,0x8(%esp)
  800986:	00 
  800987:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098b:	89 3c 24             	mov    %edi,(%esp)
  80098e:	e8 2e 03 00 00       	call   800cc1 <printfmt>
  800993:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800996:	e9 9e fe ff ff       	jmp    800839 <vprintfmt+0x2c>
  80099b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80099e:	89 c3                	mov    %eax,%ebx
  8009a0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009a6:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ac:	8d 50 04             	lea    0x4(%eax),%edx
  8009af:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b2:	8b 00                	mov    (%eax),%eax
  8009b4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8009b7:	85 c0                	test   %eax,%eax
  8009b9:	75 07                	jne    8009c2 <vprintfmt+0x1b5>
  8009bb:	c7 45 c4 5c 14 80 00 	movl   $0x80145c,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8009c2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8009c6:	7e 06                	jle    8009ce <vprintfmt+0x1c1>
  8009c8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8009cc:	75 13                	jne    8009e1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ce:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009d1:	0f be 02             	movsbl (%edx),%eax
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	0f 85 99 00 00 00    	jne    800a75 <vprintfmt+0x268>
  8009dc:	e9 86 00 00 00       	jmp    800a67 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8009e8:	89 0c 24             	mov    %ecx,(%esp)
  8009eb:	e8 1b 03 00 00       	call   800d0b <strnlen>
  8009f0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8009f3:	29 c2                	sub    %eax,%edx
  8009f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009f8:	85 d2                	test   %edx,%edx
  8009fa:	7e d2                	jle    8009ce <vprintfmt+0x1c1>
					putch(padc, putdat);
  8009fc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800a00:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a03:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a06:	89 d3                	mov    %edx,%ebx
  800a08:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a0f:	89 04 24             	mov    %eax,(%esp)
  800a12:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a14:	83 eb 01             	sub    $0x1,%ebx
  800a17:	85 db                	test   %ebx,%ebx
  800a19:	7f ed                	jg     800a08 <vprintfmt+0x1fb>
  800a1b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a25:	eb a7                	jmp    8009ce <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a27:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a2b:	74 18                	je     800a45 <vprintfmt+0x238>
  800a2d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a30:	83 fa 5e             	cmp    $0x5e,%edx
  800a33:	76 10                	jbe    800a45 <vprintfmt+0x238>
					putch('?', putdat);
  800a35:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a39:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a40:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a43:	eb 0a                	jmp    800a4f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a45:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a49:	89 04 24             	mov    %eax,(%esp)
  800a4c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a53:	0f be 03             	movsbl (%ebx),%eax
  800a56:	85 c0                	test   %eax,%eax
  800a58:	74 05                	je     800a5f <vprintfmt+0x252>
  800a5a:	83 c3 01             	add    $0x1,%ebx
  800a5d:	eb 29                	jmp    800a88 <vprintfmt+0x27b>
  800a5f:	89 fe                	mov    %edi,%esi
  800a61:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a64:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a67:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a6b:	7f 2e                	jg     800a9b <vprintfmt+0x28e>
  800a6d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a70:	e9 c4 fd ff ff       	jmp    800839 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a75:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800a7e:	89 f7                	mov    %esi,%edi
  800a80:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a83:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a86:	89 d3                	mov    %edx,%ebx
  800a88:	85 f6                	test   %esi,%esi
  800a8a:	78 9b                	js     800a27 <vprintfmt+0x21a>
  800a8c:	83 ee 01             	sub    $0x1,%esi
  800a8f:	79 96                	jns    800a27 <vprintfmt+0x21a>
  800a91:	89 fe                	mov    %edi,%esi
  800a93:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a96:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a99:	eb cc                	jmp    800a67 <vprintfmt+0x25a>
  800a9b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a9e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aa1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aa5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800aac:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aae:	83 eb 01             	sub    $0x1,%ebx
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	7f ec                	jg     800aa1 <vprintfmt+0x294>
  800ab5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ab8:	e9 7c fd ff ff       	jmp    800839 <vprintfmt+0x2c>
  800abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ac0:	83 f9 01             	cmp    $0x1,%ecx
  800ac3:	7e 16                	jle    800adb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8d 50 08             	lea    0x8(%eax),%edx
  800acb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ace:	8b 10                	mov    (%eax),%edx
  800ad0:	8b 48 04             	mov    0x4(%eax),%ecx
  800ad3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800ad6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ad9:	eb 32                	jmp    800b0d <vprintfmt+0x300>
	else if (lflag)
  800adb:	85 c9                	test   %ecx,%ecx
  800add:	74 18                	je     800af7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800adf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae2:	8d 50 04             	lea    0x4(%eax),%edx
  800ae5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae8:	8b 00                	mov    (%eax),%eax
  800aea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aed:	89 c1                	mov    %eax,%ecx
  800aef:	c1 f9 1f             	sar    $0x1f,%ecx
  800af2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800af5:	eb 16                	jmp    800b0d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800af7:	8b 45 14             	mov    0x14(%ebp),%eax
  800afa:	8d 50 04             	lea    0x4(%eax),%edx
  800afd:	89 55 14             	mov    %edx,0x14(%ebp)
  800b00:	8b 00                	mov    (%eax),%eax
  800b02:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b05:	89 c2                	mov    %eax,%edx
  800b07:	c1 fa 1f             	sar    $0x1f,%edx
  800b0a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b0d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b10:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b13:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800b18:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b1c:	0f 89 b8 00 00 00    	jns    800bda <vprintfmt+0x3cd>
				putch('-', putdat);
  800b22:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b26:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b2d:	ff d7                	call   *%edi
				num = -(long long) num;
  800b2f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b35:	f7 d9                	neg    %ecx
  800b37:	83 d3 00             	adc    $0x0,%ebx
  800b3a:	f7 db                	neg    %ebx
  800b3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b41:	e9 94 00 00 00       	jmp    800bda <vprintfmt+0x3cd>
  800b46:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b49:	89 ca                	mov    %ecx,%edx
  800b4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4e:	e8 63 fc ff ff       	call   8007b6 <getuint>
  800b53:	89 c1                	mov    %eax,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800b5c:	eb 7c                	jmp    800bda <vprintfmt+0x3cd>
  800b5e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b65:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b6c:	ff d7                	call   *%edi
			putch('X', putdat);
  800b6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b72:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b79:	ff d7                	call   *%edi
			putch('X', putdat);
  800b7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b7f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b86:	ff d7                	call   *%edi
  800b88:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800b8b:	e9 a9 fc ff ff       	jmp    800839 <vprintfmt+0x2c>
  800b90:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800b93:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b97:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b9e:	ff d7                	call   *%edi
			putch('x', putdat);
  800ba0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bab:	ff d7                	call   *%edi
			num = (unsigned long long)
  800bad:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb0:	8d 50 04             	lea    0x4(%eax),%edx
  800bb3:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb6:	8b 08                	mov    (%eax),%ecx
  800bb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbd:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bc2:	eb 16                	jmp    800bda <vprintfmt+0x3cd>
  800bc4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc7:	89 ca                	mov    %ecx,%edx
  800bc9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcc:	e8 e5 fb ff ff       	call   8007b6 <getuint>
  800bd1:	89 c1                	mov    %eax,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bda:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800bde:	89 54 24 10          	mov    %edx,0x10(%esp)
  800be2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800be5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800be9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bed:	89 0c 24             	mov    %ecx,(%esp)
  800bf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf4:	89 f2                	mov    %esi,%edx
  800bf6:	89 f8                	mov    %edi,%eax
  800bf8:	e8 c3 fa ff ff       	call   8006c0 <printnum>
  800bfd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c00:	e9 34 fc ff ff       	jmp    800839 <vprintfmt+0x2c>
  800c05:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c08:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c0f:	89 14 24             	mov    %edx,(%esp)
  800c12:	ff d7                	call   *%edi
  800c14:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c17:	e9 1d fc ff ff       	jmp    800839 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c20:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c27:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c29:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800c2c:	80 38 25             	cmpb   $0x25,(%eax)
  800c2f:	0f 84 04 fc ff ff    	je     800839 <vprintfmt+0x2c>
  800c35:	89 c3                	mov    %eax,%ebx
  800c37:	eb f0                	jmp    800c29 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800c39:	83 c4 5c             	add    $0x5c,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 28             	sub    $0x28,%esp
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	74 04                	je     800c55 <vsnprintf+0x14>
  800c51:	85 d2                	test   %edx,%edx
  800c53:	7f 07                	jg     800c5c <vsnprintf+0x1b>
  800c55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c5a:	eb 3b                	jmp    800c97 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c5f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c74:	8b 45 10             	mov    0x10(%ebp),%eax
  800c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c82:	c7 04 24 f0 07 80 00 	movl   $0x8007f0,(%esp)
  800c89:	e8 7f fb ff ff       	call   80080d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c91:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c9f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800ca2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ca6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	89 04 24             	mov    %eax,(%esp)
  800cba:	e8 82 ff ff ff       	call   800c41 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800cc7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800cca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cce:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	89 04 24             	mov    %eax,(%esp)
  800ce2:	e8 26 fb ff ff       	call   80080d <vprintfmt>
	va_end(ap);
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    
  800ce9:	00 00                	add    %al,(%eax)
  800ceb:	00 00                	add    %al,(%eax)
  800ced:	00 00                	add    %al,(%eax)
	...

00800cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfb:	80 3a 00             	cmpb   $0x0,(%edx)
  800cfe:	74 09                	je     800d09 <strlen+0x19>
		n++;
  800d00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d07:	75 f7                	jne    800d00 <strlen+0x10>
		n++;
	return n;
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	53                   	push   %ebx
  800d0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d15:	85 c9                	test   %ecx,%ecx
  800d17:	74 19                	je     800d32 <strnlen+0x27>
  800d19:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d1c:	74 14                	je     800d32 <strnlen+0x27>
  800d1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d26:	39 c8                	cmp    %ecx,%eax
  800d28:	74 0d                	je     800d37 <strnlen+0x2c>
  800d2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800d2e:	75 f3                	jne    800d23 <strnlen+0x18>
  800d30:	eb 05                	jmp    800d37 <strnlen+0x2c>
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d37:	5b                   	pop    %ebx
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d50:	83 c2 01             	add    $0x1,%edx
  800d53:	84 c9                	test   %cl,%cl
  800d55:	75 f2                	jne    800d49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d57:	5b                   	pop    %ebx
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 08             	sub    $0x8,%esp
  800d61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d64:	89 1c 24             	mov    %ebx,(%esp)
  800d67:	e8 84 ff ff ff       	call   800cf0 <strlen>
	strcpy(dst + len, src);
  800d6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d73:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d76:	89 04 24             	mov    %eax,(%esp)
  800d79:	e8 bc ff ff ff       	call   800d3a <strcpy>
	return dst;
}
  800d7e:	89 d8                	mov    %ebx,%eax
  800d80:	83 c4 08             	add    $0x8,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d91:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d94:	85 f6                	test   %esi,%esi
  800d96:	74 18                	je     800db0 <strncpy+0x2a>
  800d98:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d9d:	0f b6 1a             	movzbl (%edx),%ebx
  800da0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800da3:	80 3a 01             	cmpb   $0x1,(%edx)
  800da6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da9:	83 c1 01             	add    $0x1,%ecx
  800dac:	39 ce                	cmp    %ecx,%esi
  800dae:	77 ed                	ja     800d9d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dc2:	89 f0                	mov    %esi,%eax
  800dc4:	85 c9                	test   %ecx,%ecx
  800dc6:	74 27                	je     800def <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800dc8:	83 e9 01             	sub    $0x1,%ecx
  800dcb:	74 1d                	je     800dea <strlcpy+0x36>
  800dcd:	0f b6 1a             	movzbl (%edx),%ebx
  800dd0:	84 db                	test   %bl,%bl
  800dd2:	74 16                	je     800dea <strlcpy+0x36>
			*dst++ = *src++;
  800dd4:	88 18                	mov    %bl,(%eax)
  800dd6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dd9:	83 e9 01             	sub    $0x1,%ecx
  800ddc:	74 0e                	je     800dec <strlcpy+0x38>
			*dst++ = *src++;
  800dde:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800de1:	0f b6 1a             	movzbl (%edx),%ebx
  800de4:	84 db                	test   %bl,%bl
  800de6:	75 ec                	jne    800dd4 <strlcpy+0x20>
  800de8:	eb 02                	jmp    800dec <strlcpy+0x38>
  800dea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dec:	c6 00 00             	movb   $0x0,(%eax)
  800def:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dfe:	0f b6 01             	movzbl (%ecx),%eax
  800e01:	84 c0                	test   %al,%al
  800e03:	74 15                	je     800e1a <strcmp+0x25>
  800e05:	3a 02                	cmp    (%edx),%al
  800e07:	75 11                	jne    800e1a <strcmp+0x25>
		p++, q++;
  800e09:	83 c1 01             	add    $0x1,%ecx
  800e0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e0f:	0f b6 01             	movzbl (%ecx),%eax
  800e12:	84 c0                	test   %al,%al
  800e14:	74 04                	je     800e1a <strcmp+0x25>
  800e16:	3a 02                	cmp    (%edx),%al
  800e18:	74 ef                	je     800e09 <strcmp+0x14>
  800e1a:	0f b6 c0             	movzbl %al,%eax
  800e1d:	0f b6 12             	movzbl (%edx),%edx
  800e20:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	74 23                	je     800e58 <strncmp+0x34>
  800e35:	0f b6 1a             	movzbl (%edx),%ebx
  800e38:	84 db                	test   %bl,%bl
  800e3a:	74 25                	je     800e61 <strncmp+0x3d>
  800e3c:	3a 19                	cmp    (%ecx),%bl
  800e3e:	75 21                	jne    800e61 <strncmp+0x3d>
  800e40:	83 e8 01             	sub    $0x1,%eax
  800e43:	74 13                	je     800e58 <strncmp+0x34>
		n--, p++, q++;
  800e45:	83 c2 01             	add    $0x1,%edx
  800e48:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e4b:	0f b6 1a             	movzbl (%edx),%ebx
  800e4e:	84 db                	test   %bl,%bl
  800e50:	74 0f                	je     800e61 <strncmp+0x3d>
  800e52:	3a 19                	cmp    (%ecx),%bl
  800e54:	74 ea                	je     800e40 <strncmp+0x1c>
  800e56:	eb 09                	jmp    800e61 <strncmp+0x3d>
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5d                   	pop    %ebp
  800e5f:	90                   	nop
  800e60:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e61:	0f b6 02             	movzbl (%edx),%eax
  800e64:	0f b6 11             	movzbl (%ecx),%edx
  800e67:	29 d0                	sub    %edx,%eax
  800e69:	eb f2                	jmp    800e5d <strncmp+0x39>

00800e6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e75:	0f b6 10             	movzbl (%eax),%edx
  800e78:	84 d2                	test   %dl,%dl
  800e7a:	74 18                	je     800e94 <strchr+0x29>
		if (*s == c)
  800e7c:	38 ca                	cmp    %cl,%dl
  800e7e:	75 0a                	jne    800e8a <strchr+0x1f>
  800e80:	eb 17                	jmp    800e99 <strchr+0x2e>
  800e82:	38 ca                	cmp    %cl,%dl
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	74 0f                	je     800e99 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e8a:	83 c0 01             	add    $0x1,%eax
  800e8d:	0f b6 10             	movzbl (%eax),%edx
  800e90:	84 d2                	test   %dl,%dl
  800e92:	75 ee                	jne    800e82 <strchr+0x17>
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ea5:	0f b6 10             	movzbl (%eax),%edx
  800ea8:	84 d2                	test   %dl,%dl
  800eaa:	74 18                	je     800ec4 <strfind+0x29>
		if (*s == c)
  800eac:	38 ca                	cmp    %cl,%dl
  800eae:	75 0a                	jne    800eba <strfind+0x1f>
  800eb0:	eb 12                	jmp    800ec4 <strfind+0x29>
  800eb2:	38 ca                	cmp    %cl,%dl
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	74 0a                	je     800ec4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eba:	83 c0 01             	add    $0x1,%eax
  800ebd:	0f b6 10             	movzbl (%eax),%edx
  800ec0:	84 d2                	test   %dl,%dl
  800ec2:	75 ee                	jne    800eb2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	89 1c 24             	mov    %ebx,(%esp)
  800ecf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ed3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ed7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ee0:	85 c9                	test   %ecx,%ecx
  800ee2:	74 30                	je     800f14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ee4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eea:	75 25                	jne    800f11 <memset+0x4b>
  800eec:	f6 c1 03             	test   $0x3,%cl
  800eef:	75 20                	jne    800f11 <memset+0x4b>
		c &= 0xFF;
  800ef1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ef4:	89 d3                	mov    %edx,%ebx
  800ef6:	c1 e3 08             	shl    $0x8,%ebx
  800ef9:	89 d6                	mov    %edx,%esi
  800efb:	c1 e6 18             	shl    $0x18,%esi
  800efe:	89 d0                	mov    %edx,%eax
  800f00:	c1 e0 10             	shl    $0x10,%eax
  800f03:	09 f0                	or     %esi,%eax
  800f05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800f07:	09 d8                	or     %ebx,%eax
  800f09:	c1 e9 02             	shr    $0x2,%ecx
  800f0c:	fc                   	cld    
  800f0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f0f:	eb 03                	jmp    800f14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f11:	fc                   	cld    
  800f12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f14:	89 f8                	mov    %edi,%eax
  800f16:	8b 1c 24             	mov    (%esp),%ebx
  800f19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f21:	89 ec                	mov    %ebp,%esp
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 08             	sub    $0x8,%esp
  800f2b:	89 34 24             	mov    %esi,(%esp)
  800f2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f32:	8b 45 08             	mov    0x8(%ebp),%eax
  800f35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800f3d:	39 c6                	cmp    %eax,%esi
  800f3f:	73 35                	jae    800f76 <memmove+0x51>
  800f41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f44:	39 d0                	cmp    %edx,%eax
  800f46:	73 2e                	jae    800f76 <memmove+0x51>
		s += n;
		d += n;
  800f48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4a:	f6 c2 03             	test   $0x3,%dl
  800f4d:	75 1b                	jne    800f6a <memmove+0x45>
  800f4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f55:	75 13                	jne    800f6a <memmove+0x45>
  800f57:	f6 c1 03             	test   $0x3,%cl
  800f5a:	75 0e                	jne    800f6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800f5c:	83 ef 04             	sub    $0x4,%edi
  800f5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f62:	c1 e9 02             	shr    $0x2,%ecx
  800f65:	fd                   	std    
  800f66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f68:	eb 09                	jmp    800f73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f6a:	83 ef 01             	sub    $0x1,%edi
  800f6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f70:	fd                   	std    
  800f71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f74:	eb 20                	jmp    800f96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f7c:	75 15                	jne    800f93 <memmove+0x6e>
  800f7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f84:	75 0d                	jne    800f93 <memmove+0x6e>
  800f86:	f6 c1 03             	test   $0x3,%cl
  800f89:	75 08                	jne    800f93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800f8b:	c1 e9 02             	shr    $0x2,%ecx
  800f8e:	fc                   	cld    
  800f8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f91:	eb 03                	jmp    800f96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f93:	fc                   	cld    
  800f94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f96:	8b 34 24             	mov    (%esp),%esi
  800f99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f9d:	89 ec                	mov    %ebp,%esp
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fa7:	8b 45 10             	mov    0x10(%ebp),%eax
  800faa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb8:	89 04 24             	mov    %eax,(%esp)
  800fbb:	e8 65 ff ff ff       	call   800f25 <memmove>
}
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd1:	85 c9                	test   %ecx,%ecx
  800fd3:	74 36                	je     80100b <memcmp+0x49>
		if (*s1 != *s2)
  800fd5:	0f b6 06             	movzbl (%esi),%eax
  800fd8:	0f b6 1f             	movzbl (%edi),%ebx
  800fdb:	38 d8                	cmp    %bl,%al
  800fdd:	74 20                	je     800fff <memcmp+0x3d>
  800fdf:	eb 14                	jmp    800ff5 <memcmp+0x33>
  800fe1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800fe6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800feb:	83 c2 01             	add    $0x1,%edx
  800fee:	83 e9 01             	sub    $0x1,%ecx
  800ff1:	38 d8                	cmp    %bl,%al
  800ff3:	74 12                	je     801007 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ff5:	0f b6 c0             	movzbl %al,%eax
  800ff8:	0f b6 db             	movzbl %bl,%ebx
  800ffb:	29 d8                	sub    %ebx,%eax
  800ffd:	eb 11                	jmp    801010 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fff:	83 e9 01             	sub    $0x1,%ecx
  801002:	ba 00 00 00 00       	mov    $0x0,%edx
  801007:	85 c9                	test   %ecx,%ecx
  801009:	75 d6                	jne    800fe1 <memcmp+0x1f>
  80100b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80101b:	89 c2                	mov    %eax,%edx
  80101d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801020:	39 d0                	cmp    %edx,%eax
  801022:	73 15                	jae    801039 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801024:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801028:	38 08                	cmp    %cl,(%eax)
  80102a:	75 06                	jne    801032 <memfind+0x1d>
  80102c:	eb 0b                	jmp    801039 <memfind+0x24>
  80102e:	38 08                	cmp    %cl,(%eax)
  801030:	74 07                	je     801039 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801032:	83 c0 01             	add    $0x1,%eax
  801035:	39 c2                	cmp    %eax,%edx
  801037:	77 f5                	ja     80102e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104a:	0f b6 02             	movzbl (%edx),%eax
  80104d:	3c 20                	cmp    $0x20,%al
  80104f:	74 04                	je     801055 <strtol+0x1a>
  801051:	3c 09                	cmp    $0x9,%al
  801053:	75 0e                	jne    801063 <strtol+0x28>
		s++;
  801055:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801058:	0f b6 02             	movzbl (%edx),%eax
  80105b:	3c 20                	cmp    $0x20,%al
  80105d:	74 f6                	je     801055 <strtol+0x1a>
  80105f:	3c 09                	cmp    $0x9,%al
  801061:	74 f2                	je     801055 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801063:	3c 2b                	cmp    $0x2b,%al
  801065:	75 0c                	jne    801073 <strtol+0x38>
		s++;
  801067:	83 c2 01             	add    $0x1,%edx
  80106a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801071:	eb 15                	jmp    801088 <strtol+0x4d>
	else if (*s == '-')
  801073:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80107a:	3c 2d                	cmp    $0x2d,%al
  80107c:	75 0a                	jne    801088 <strtol+0x4d>
		s++, neg = 1;
  80107e:	83 c2 01             	add    $0x1,%edx
  801081:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801088:	85 db                	test   %ebx,%ebx
  80108a:	0f 94 c0             	sete   %al
  80108d:	74 05                	je     801094 <strtol+0x59>
  80108f:	83 fb 10             	cmp    $0x10,%ebx
  801092:	75 18                	jne    8010ac <strtol+0x71>
  801094:	80 3a 30             	cmpb   $0x30,(%edx)
  801097:	75 13                	jne    8010ac <strtol+0x71>
  801099:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	75 0a                	jne    8010ac <strtol+0x71>
		s += 2, base = 16;
  8010a2:	83 c2 02             	add    $0x2,%edx
  8010a5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010aa:	eb 15                	jmp    8010c1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010ac:	84 c0                	test   %al,%al
  8010ae:	66 90                	xchg   %ax,%ax
  8010b0:	74 0f                	je     8010c1 <strtol+0x86>
  8010b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8010b7:	80 3a 30             	cmpb   $0x30,(%edx)
  8010ba:	75 05                	jne    8010c1 <strtol+0x86>
		s++, base = 8;
  8010bc:	83 c2 01             	add    $0x1,%edx
  8010bf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010c8:	0f b6 0a             	movzbl (%edx),%ecx
  8010cb:	89 cf                	mov    %ecx,%edi
  8010cd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8010d0:	80 fb 09             	cmp    $0x9,%bl
  8010d3:	77 08                	ja     8010dd <strtol+0xa2>
			dig = *s - '0';
  8010d5:	0f be c9             	movsbl %cl,%ecx
  8010d8:	83 e9 30             	sub    $0x30,%ecx
  8010db:	eb 1e                	jmp    8010fb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8010dd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8010e0:	80 fb 19             	cmp    $0x19,%bl
  8010e3:	77 08                	ja     8010ed <strtol+0xb2>
			dig = *s - 'a' + 10;
  8010e5:	0f be c9             	movsbl %cl,%ecx
  8010e8:	83 e9 57             	sub    $0x57,%ecx
  8010eb:	eb 0e                	jmp    8010fb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8010ed:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8010f0:	80 fb 19             	cmp    $0x19,%bl
  8010f3:	77 15                	ja     80110a <strtol+0xcf>
			dig = *s - 'A' + 10;
  8010f5:	0f be c9             	movsbl %cl,%ecx
  8010f8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010fb:	39 f1                	cmp    %esi,%ecx
  8010fd:	7d 0b                	jge    80110a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8010ff:	83 c2 01             	add    $0x1,%edx
  801102:	0f af c6             	imul   %esi,%eax
  801105:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801108:	eb be                	jmp    8010c8 <strtol+0x8d>
  80110a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80110c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801110:	74 05                	je     801117 <strtol+0xdc>
		*endptr = (char *) s;
  801112:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801115:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801117:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80111b:	74 04                	je     801121 <strtol+0xe6>
  80111d:	89 c8                	mov    %ecx,%eax
  80111f:	f7 d8                	neg    %eax
}
  801121:	83 c4 04             	add    $0x4,%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    
  801129:	00 00                	add    %al,(%eax)
	...

0080112c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801132:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801139:	75 1c                	jne    801157 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  80113b:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  801152:	e8 2d f4 ff ff       	call   800584 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
  80115a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    
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
