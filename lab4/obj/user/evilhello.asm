
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 a6 00 00 00       	call   8000f4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800062:	e8 57 04 00 00       	call   8004be <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 4c 04 00 00       	call   8004fe <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	89 d3                	mov    %edx,%ebx
  8000cf:	89 d7                	mov    %edx,%edi
  8000d1:	51                   	push   %ecx
  8000d2:	52                   	push   %edx
  8000d3:	53                   	push   %ebx
  8000d4:	54                   	push   %esp
  8000d5:	55                   	push   %ebp
  8000d6:	56                   	push   %esi
  8000d7:	57                   	push   %edi
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	8d 35 e2 00 80 00    	lea    0x8000e2,%esi
  8000e0:	0f 34                	sysenter 
  8000e2:	5f                   	pop    %edi
  8000e3:	5e                   	pop    %esi
  8000e4:	5d                   	pop    %ebp
  8000e5:	5c                   	pop    %esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5a                   	pop    %edx
  8000e8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	8b 1c 24             	mov    (%esp),%ebx
  8000ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000f0:	89 ec                	mov    %ebp,%esp
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	89 1c 24             	mov    %ebx,(%esp)
  8000fd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800101:	b8 00 00 00 00       	mov    $0x0,%eax
  800106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	89 c3                	mov    %eax,%ebx
  80010e:	89 c7                	mov    %eax,%edi
  800110:	51                   	push   %ecx
  800111:	52                   	push   %edx
  800112:	53                   	push   %ebx
  800113:	54                   	push   %esp
  800114:	55                   	push   %ebp
  800115:	56                   	push   %esi
  800116:	57                   	push   %edi
  800117:	89 e5                	mov    %esp,%ebp
  800119:	8d 35 21 01 80 00    	lea    0x800121,%esi
  80011f:	0f 34                	sysenter 
  800121:	5f                   	pop    %edi
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	5c                   	pop    %esp
  800125:	5b                   	pop    %ebx
  800126:	5a                   	pop    %edx
  800127:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800128:	8b 1c 24             	mov    (%esp),%ebx
  80012b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	89 1c 24             	mov    %ebx,(%esp)
  80013c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800140:	b9 00 00 00 00       	mov    $0x0,%ecx
  800145:	b8 0e 00 00 00       	mov    $0xe,%eax
  80014a:	8b 55 08             	mov    0x8(%ebp),%edx
  80014d:	89 cb                	mov    %ecx,%ebx
  80014f:	89 cf                	mov    %ecx,%edi
  800151:	51                   	push   %ecx
  800152:	52                   	push   %edx
  800153:	53                   	push   %ebx
  800154:	54                   	push   %esp
  800155:	55                   	push   %ebp
  800156:	56                   	push   %esi
  800157:	57                   	push   %edi
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	8d 35 62 01 80 00    	lea    0x800162,%esi
  800160:	0f 34                	sysenter 
  800162:	5f                   	pop    %edi
  800163:	5e                   	pop    %esi
  800164:	5d                   	pop    %ebp
  800165:	5c                   	pop    %esp
  800166:	5b                   	pop    %ebx
  800167:	5a                   	pop    %edx
  800168:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800169:	8b 1c 24             	mov    (%esp),%ebx
  80016c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 28             	sub    $0x28,%esp
  80017a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80017d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800180:	b9 00 00 00 00       	mov    $0x0,%ecx
  800185:	b8 0d 00 00 00       	mov    $0xd,%eax
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	89 cb                	mov    %ecx,%ebx
  80018f:	89 cf                	mov    %ecx,%edi
  800191:	51                   	push   %ecx
  800192:	52                   	push   %edx
  800193:	53                   	push   %ebx
  800194:	54                   	push   %esp
  800195:	55                   	push   %ebp
  800196:	56                   	push   %esi
  800197:	57                   	push   %edi
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	8d 35 a2 01 80 00    	lea    0x8001a2,%esi
  8001a0:	0f 34                	sysenter 
  8001a2:	5f                   	pop    %edi
  8001a3:	5e                   	pop    %esi
  8001a4:	5d                   	pop    %ebp
  8001a5:	5c                   	pop    %esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5a                   	pop    %edx
  8001a8:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7e 28                	jle    8001d5 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8001d0:	e8 97 03 00 00       	call   80056c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001d5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001db:	89 ec                	mov    %ebp,%esp
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	89 1c 24             	mov    %ebx,(%esp)
  8001e8:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ec:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001f1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	51                   	push   %ecx
  8001fe:	52                   	push   %edx
  8001ff:	53                   	push   %ebx
  800200:	54                   	push   %esp
  800201:	55                   	push   %ebp
  800202:	56                   	push   %esi
  800203:	57                   	push   %edi
  800204:	89 e5                	mov    %esp,%ebp
  800206:	8d 35 0e 02 80 00    	lea    0x80020e,%esi
  80020c:	0f 34                	sysenter 
  80020e:	5f                   	pop    %edi
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	5c                   	pop    %esp
  800212:	5b                   	pop    %ebx
  800213:	5a                   	pop    %edx
  800214:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800215:	8b 1c 24             	mov    (%esp),%ebx
  800218:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021c:	89 ec                	mov    %ebp,%esp
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 28             	sub    $0x28,%esp
  800226:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800229:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	b8 0a 00 00 00       	mov    $0xa,%eax
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	51                   	push   %ecx
  80023f:	52                   	push   %edx
  800240:	53                   	push   %ebx
  800241:	54                   	push   %esp
  800242:	55                   	push   %ebp
  800243:	56                   	push   %esi
  800244:	57                   	push   %edi
  800245:	89 e5                	mov    %esp,%ebp
  800247:	8d 35 4f 02 80 00    	lea    0x80024f,%esi
  80024d:	0f 34                	sysenter 
  80024f:	5f                   	pop    %edi
  800250:	5e                   	pop    %esi
  800251:	5d                   	pop    %ebp
  800252:	5c                   	pop    %esp
  800253:	5b                   	pop    %ebx
  800254:	5a                   	pop    %edx
  800255:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 28                	jle    800282 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800265:	00 
  800266:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80026d:	00 
  80026e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80027d:	e8 ea 02 00 00       	call   80056c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800282:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800285:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800288:	89 ec                	mov    %ebp,%esp
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 28             	sub    $0x28,%esp
  800292:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	51                   	push   %ecx
  8002ab:	52                   	push   %edx
  8002ac:	53                   	push   %ebx
  8002ad:	54                   	push   %esp
  8002ae:	55                   	push   %ebp
  8002af:	56                   	push   %esi
  8002b0:	57                   	push   %edi
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8d 35 bb 02 80 00    	lea    0x8002bb,%esi
  8002b9:	0f 34                	sysenter 
  8002bb:	5f                   	pop    %edi
  8002bc:	5e                   	pop    %esi
  8002bd:	5d                   	pop    %ebp
  8002be:	5c                   	pop    %esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5a                   	pop    %edx
  8002c1:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	7e 28                	jle    8002ee <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ca:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8002d9:	00 
  8002da:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8002e9:	e8 7e 02 00 00       	call   80056c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f4:	89 ec                	mov    %ebp,%esp
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 28             	sub    $0x28,%esp
  8002fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800301:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800304:	bb 00 00 00 00       	mov    $0x0,%ebx
  800309:	b8 07 00 00 00       	mov    $0x7,%eax
  80030e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800311:	8b 55 08             	mov    0x8(%ebp),%edx
  800314:	89 df                	mov    %ebx,%edi
  800316:	51                   	push   %ecx
  800317:	52                   	push   %edx
  800318:	53                   	push   %ebx
  800319:	54                   	push   %esp
  80031a:	55                   	push   %ebp
  80031b:	56                   	push   %esi
  80031c:	57                   	push   %edi
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8d 35 27 03 80 00    	lea    0x800327,%esi
  800325:	0f 34                	sysenter 
  800327:	5f                   	pop    %edi
  800328:	5e                   	pop    %esi
  800329:	5d                   	pop    %ebp
  80032a:	5c                   	pop    %esp
  80032b:	5b                   	pop    %ebx
  80032c:	5a                   	pop    %edx
  80032d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80032e:	85 c0                	test   %eax,%eax
  800330:	7e 28                	jle    80035a <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800332:	89 44 24 10          	mov    %eax,0x10(%esp)
  800336:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80033d:	00 
  80033e:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800345:	00 
  800346:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80034d:	00 
  80034e:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800355:	e8 12 02 00 00       	call   80056c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80035a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80035d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800360:	89 ec                	mov    %ebp,%esp
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 28             	sub    $0x28,%esp
  80036a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80036d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800370:	b8 06 00 00 00       	mov    $0x6,%eax
  800375:	8b 7d 14             	mov    0x14(%ebp),%edi
  800378:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80037b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	51                   	push   %ecx
  800382:	52                   	push   %edx
  800383:	53                   	push   %ebx
  800384:	54                   	push   %esp
  800385:	55                   	push   %ebp
  800386:	56                   	push   %esi
  800387:	57                   	push   %edi
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	8d 35 92 03 80 00    	lea    0x800392,%esi
  800390:	0f 34                	sysenter 
  800392:	5f                   	pop    %edi
  800393:	5e                   	pop    %esi
  800394:	5d                   	pop    %ebp
  800395:	5c                   	pop    %esp
  800396:	5b                   	pop    %ebx
  800397:	5a                   	pop    %edx
  800398:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7e 28                	jle    8003c5 <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8003b8:	00 
  8003b9:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8003c0:	e8 a7 01 00 00       	call   80056c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8003c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003cb:	89 ec                	mov    %ebp,%esp
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 28             	sub    $0x28,%esp
  8003d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003d8:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003db:	bf 00 00 00 00       	mov    $0x0,%edi
  8003e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8003e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ee:	51                   	push   %ecx
  8003ef:	52                   	push   %edx
  8003f0:	53                   	push   %ebx
  8003f1:	54                   	push   %esp
  8003f2:	55                   	push   %ebp
  8003f3:	56                   	push   %esi
  8003f4:	57                   	push   %edi
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	8d 35 ff 03 80 00    	lea    0x8003ff,%esi
  8003fd:	0f 34                	sysenter 
  8003ff:	5f                   	pop    %edi
  800400:	5e                   	pop    %esi
  800401:	5d                   	pop    %ebp
  800402:	5c                   	pop    %esp
  800403:	5b                   	pop    %ebx
  800404:	5a                   	pop    %edx
  800405:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800406:	85 c0                	test   %eax,%eax
  800408:	7e 28                	jle    800432 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800415:	00 
  800416:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80041d:	00 
  80041e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800425:	00 
  800426:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80042d:	e8 3a 01 00 00       	call   80056c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800432:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800435:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800438:	89 ec                	mov    %ebp,%esp
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	89 1c 24             	mov    %ebx,(%esp)
  800445:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800453:	89 d1                	mov    %edx,%ecx
  800455:	89 d3                	mov    %edx,%ebx
  800457:	89 d7                	mov    %edx,%edi
  800459:	51                   	push   %ecx
  80045a:	52                   	push   %edx
  80045b:	53                   	push   %ebx
  80045c:	54                   	push   %esp
  80045d:	55                   	push   %ebp
  80045e:	56                   	push   %esi
  80045f:	57                   	push   %edi
  800460:	89 e5                	mov    %esp,%ebp
  800462:	8d 35 6a 04 80 00    	lea    0x80046a,%esi
  800468:	0f 34                	sysenter 
  80046a:	5f                   	pop    %edi
  80046b:	5e                   	pop    %esi
  80046c:	5d                   	pop    %ebp
  80046d:	5c                   	pop    %esp
  80046e:	5b                   	pop    %ebx
  80046f:	5a                   	pop    %edx
  800470:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800471:	8b 1c 24             	mov    (%esp),%ebx
  800474:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800478:	89 ec                	mov    %ebp,%esp
  80047a:	5d                   	pop    %ebp
  80047b:	c3                   	ret    

0080047c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	89 1c 24             	mov    %ebx,(%esp)
  800485:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800489:	bb 00 00 00 00       	mov    $0x0,%ebx
  80048e:	b8 04 00 00 00       	mov    $0x4,%eax
  800493:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800496:	8b 55 08             	mov    0x8(%ebp),%edx
  800499:	89 df                	mov    %ebx,%edi
  80049b:	51                   	push   %ecx
  80049c:	52                   	push   %edx
  80049d:	53                   	push   %ebx
  80049e:	54                   	push   %esp
  80049f:	55                   	push   %ebp
  8004a0:	56                   	push   %esi
  8004a1:	57                   	push   %edi
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	8d 35 ac 04 80 00    	lea    0x8004ac,%esi
  8004aa:	0f 34                	sysenter 
  8004ac:	5f                   	pop    %edi
  8004ad:	5e                   	pop    %esi
  8004ae:	5d                   	pop    %ebp
  8004af:	5c                   	pop    %esp
  8004b0:	5b                   	pop    %ebx
  8004b1:	5a                   	pop    %edx
  8004b2:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8004b3:	8b 1c 24             	mov    (%esp),%ebx
  8004b6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004ba:	89 ec                	mov    %ebp,%esp
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	89 1c 24             	mov    %ebx,(%esp)
  8004c7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8004d5:	89 d1                	mov    %edx,%ecx
  8004d7:	89 d3                	mov    %edx,%ebx
  8004d9:	89 d7                	mov    %edx,%edi
  8004db:	51                   	push   %ecx
  8004dc:	52                   	push   %edx
  8004dd:	53                   	push   %ebx
  8004de:	54                   	push   %esp
  8004df:	55                   	push   %ebp
  8004e0:	56                   	push   %esi
  8004e1:	57                   	push   %edi
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8d 35 ec 04 80 00    	lea    0x8004ec,%esi
  8004ea:	0f 34                	sysenter 
  8004ec:	5f                   	pop    %edi
  8004ed:	5e                   	pop    %esi
  8004ee:	5d                   	pop    %ebp
  8004ef:	5c                   	pop    %esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5a                   	pop    %edx
  8004f2:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004f3:	8b 1c 24             	mov    (%esp),%ebx
  8004f6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004fa:	89 ec                	mov    %ebp,%esp
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	83 ec 28             	sub    $0x28,%esp
  800504:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800507:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80050a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050f:	b8 03 00 00 00       	mov    $0x3,%eax
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 cb                	mov    %ecx,%ebx
  800519:	89 cf                	mov    %ecx,%edi
  80051b:	51                   	push   %ecx
  80051c:	52                   	push   %edx
  80051d:	53                   	push   %ebx
  80051e:	54                   	push   %esp
  80051f:	55                   	push   %ebp
  800520:	56                   	push   %esi
  800521:	57                   	push   %edi
  800522:	89 e5                	mov    %esp,%ebp
  800524:	8d 35 2c 05 80 00    	lea    0x80052c,%esi
  80052a:	0f 34                	sysenter 
  80052c:	5f                   	pop    %edi
  80052d:	5e                   	pop    %esi
  80052e:	5d                   	pop    %ebp
  80052f:	5c                   	pop    %esp
  800530:	5b                   	pop    %ebx
  800531:	5a                   	pop    %edx
  800532:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800533:	85 c0                	test   %eax,%eax
  800535:	7e 28                	jle    80055f <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800537:	89 44 24 10          	mov    %eax,0x10(%esp)
  80053b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800542:	00 
  800543:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80054a:	00 
  80054b:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800552:	00 
  800553:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80055a:	e8 0d 00 00 00       	call   80056c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80055f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800562:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800565:	89 ec                	mov    %ebp,%esp
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    
  800569:	00 00                	add    %al,(%eax)
	...

0080056c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	56                   	push   %esi
  800570:	53                   	push   %ebx
  800571:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800574:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800577:	a1 08 20 80 00       	mov    0x802008,%eax
  80057c:	85 c0                	test   %eax,%eax
  80057e:	74 10                	je     800590 <_panic+0x24>
		cprintf("%s: ", argv0);
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	c7 04 24 b5 13 80 00 	movl   $0x8013b5,(%esp)
  80058b:	e8 ad 00 00 00       	call   80063d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800590:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800596:	e8 23 ff ff ff       	call   8004be <sys_getenvid>
  80059b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059e:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	c7 04 24 bc 13 80 00 	movl   $0x8013bc,(%esp)
  8005b8:	e8 80 00 00 00       	call   80063d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	e8 10 00 00 00       	call   8005dc <vcprintf>
	cprintf("\n");
  8005cc:	c7 04 24 ba 13 80 00 	movl   $0x8013ba,(%esp)
  8005d3:	e8 65 00 00 00       	call   80063d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005d8:	cc                   	int3   
  8005d9:	eb fd                	jmp    8005d8 <_panic+0x6c>
	...

008005dc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005ec:	00 00 00 
	b.cnt = 0;
  8005ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800600:	8b 45 08             	mov    0x8(%ebp),%eax
  800603:	89 44 24 08          	mov    %eax,0x8(%esp)
  800607:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	c7 04 24 57 06 80 00 	movl   $0x800657,(%esp)
  800618:	e8 d0 01 00 00       	call   8007ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80061d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800623:	89 44 24 04          	mov    %eax,0x4(%esp)
  800627:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	e8 bf fa ff ff       	call   8000f4 <sys_cputs>

	return b.cnt;
}
  800635:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80063b:	c9                   	leave  
  80063c:	c3                   	ret    

0080063d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800643:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	e8 87 ff ff ff       	call   8005dc <vcprintf>
	va_end(ap);

	return cnt;
}
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	53                   	push   %ebx
  80065b:	83 ec 14             	sub    $0x14,%esp
  80065e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800661:	8b 03                	mov    (%ebx),%eax
  800663:	8b 55 08             	mov    0x8(%ebp),%edx
  800666:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80066a:	83 c0 01             	add    $0x1,%eax
  80066d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80066f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800674:	75 19                	jne    80068f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800676:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80067d:	00 
  80067e:	8d 43 08             	lea    0x8(%ebx),%eax
  800681:	89 04 24             	mov    %eax,(%esp)
  800684:	e8 6b fa ff ff       	call   8000f4 <sys_cputs>
		b->idx = 0;
  800689:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80068f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800693:	83 c4 14             	add    $0x14,%esp
  800696:	5b                   	pop    %ebx
  800697:	5d                   	pop    %ebp
  800698:	c3                   	ret    
  800699:	00 00                	add    %al,(%eax)
  80069b:	00 00                	add    %al,(%eax)
  80069d:	00 00                	add    %al,(%eax)
	...

008006a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	57                   	push   %edi
  8006a4:	56                   	push   %esi
  8006a5:	53                   	push   %ebx
  8006a6:	83 ec 4c             	sub    $0x4c,%esp
  8006a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ac:	89 d6                	mov    %edx,%esi
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8006bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	39 d1                	cmp    %edx,%ecx
  8006cd:	72 15                	jb     8006e4 <printnum+0x44>
  8006cf:	77 07                	ja     8006d8 <printnum+0x38>
  8006d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d4:	39 d0                	cmp    %edx,%eax
  8006d6:	76 0c                	jbe    8006e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006d8:	83 eb 01             	sub    $0x1,%ebx
  8006db:	85 db                	test   %ebx,%ebx
  8006dd:	8d 76 00             	lea    0x0(%esi),%esi
  8006e0:	7f 61                	jg     800743 <printnum+0xa3>
  8006e2:	eb 70                	jmp    800754 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006e8:	83 eb 01             	sub    $0x1,%ebx
  8006eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8006f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8006fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800701:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800704:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800708:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80070f:	00 
  800710:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800713:	89 04 24             	mov    %eax,(%esp)
  800716:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800719:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071d:	e8 ee 09 00 00       	call   801110 <__udivdi3>
  800722:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800725:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80072c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	89 54 24 04          	mov    %edx,0x4(%esp)
  800737:	89 f2                	mov    %esi,%edx
  800739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80073c:	e8 5f ff ff ff       	call   8006a0 <printnum>
  800741:	eb 11                	jmp    800754 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800743:	89 74 24 04          	mov    %esi,0x4(%esp)
  800747:	89 3c 24             	mov    %edi,(%esp)
  80074a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80074d:	83 eb 01             	sub    $0x1,%ebx
  800750:	85 db                	test   %ebx,%ebx
  800752:	7f ef                	jg     800743 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800754:	89 74 24 04          	mov    %esi,0x4(%esp)
  800758:	8b 74 24 04          	mov    0x4(%esp),%esi
  80075c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80075f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800763:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80076a:	00 
  80076b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076e:	89 14 24             	mov    %edx,(%esp)
  800771:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800774:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800778:	e8 c3 0a 00 00       	call   801240 <__umoddi3>
  80077d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800781:	0f be 80 e0 13 80 00 	movsbl 0x8013e0(%eax),%eax
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80078e:	83 c4 4c             	add    $0x4c,%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800799:	83 fa 01             	cmp    $0x1,%edx
  80079c:	7e 0e                	jle    8007ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079e:	8b 10                	mov    (%eax),%edx
  8007a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a3:	89 08                	mov    %ecx,(%eax)
  8007a5:	8b 02                	mov    (%edx),%eax
  8007a7:	8b 52 04             	mov    0x4(%edx),%edx
  8007aa:	eb 22                	jmp    8007ce <getuint+0x38>
	else if (lflag)
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 10                	je     8007c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b5:	89 08                	mov    %ecx,(%eax)
  8007b7:	8b 02                	mov    (%edx),%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007be:	eb 0e                	jmp    8007ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c5:	89 08                	mov    %ecx,(%eax)
  8007c7:	8b 02                	mov    (%edx),%eax
  8007c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007da:	8b 10                	mov    (%eax),%edx
  8007dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8007df:	73 0a                	jae    8007eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	88 0a                	mov    %cl,(%edx)
  8007e6:	83 c2 01             	add    $0x1,%edx
  8007e9:	89 10                	mov    %edx,(%eax)
}
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	57                   	push   %edi
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	83 ec 5c             	sub    $0x5c,%esp
  8007f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800806:	eb 11                	jmp    800819 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800808:	85 c0                	test   %eax,%eax
  80080a:	0f 84 09 04 00 00    	je     800c19 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800810:	89 74 24 04          	mov    %esi,0x4(%esp)
  800814:	89 04 24             	mov    %eax,(%esp)
  800817:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800819:	0f b6 03             	movzbl (%ebx),%eax
  80081c:	83 c3 01             	add    $0x1,%ebx
  80081f:	83 f8 25             	cmp    $0x25,%eax
  800822:	75 e4                	jne    800808 <vprintfmt+0x1b>
  800824:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800828:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80082f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800836:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80083d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800842:	eb 06                	jmp    80084a <vprintfmt+0x5d>
  800844:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800848:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084a:	0f b6 13             	movzbl (%ebx),%edx
  80084d:	0f b6 c2             	movzbl %dl,%eax
  800850:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800853:	8d 43 01             	lea    0x1(%ebx),%eax
  800856:	83 ea 23             	sub    $0x23,%edx
  800859:	80 fa 55             	cmp    $0x55,%dl
  80085c:	0f 87 9a 03 00 00    	ja     800bfc <vprintfmt+0x40f>
  800862:	0f b6 d2             	movzbl %dl,%edx
  800865:	ff 24 95 a0 14 80 00 	jmp    *0x8014a0(,%edx,4)
  80086c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800870:	eb d6                	jmp    800848 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800872:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800875:	83 ea 30             	sub    $0x30,%edx
  800878:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80087b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80087e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800881:	83 fb 09             	cmp    $0x9,%ebx
  800884:	77 4c                	ja     8008d2 <vprintfmt+0xe5>
  800886:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800889:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80088c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80088f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800892:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800896:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800899:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80089c:	83 fb 09             	cmp    $0x9,%ebx
  80089f:	76 eb                	jbe    80088c <vprintfmt+0x9f>
  8008a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008a7:	eb 29                	jmp    8008d2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8008ac:	8d 5a 04             	lea    0x4(%edx),%ebx
  8008af:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8008b2:	8b 12                	mov    (%edx),%edx
  8008b4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8008b7:	eb 19                	jmp    8008d2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8008b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008bc:	c1 fa 1f             	sar    $0x1f,%edx
  8008bf:	f7 d2                	not    %edx
  8008c1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8008c4:	eb 82                	jmp    800848 <vprintfmt+0x5b>
  8008c6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8008cd:	e9 76 ff ff ff       	jmp    800848 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8008d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d6:	0f 89 6c ff ff ff    	jns    800848 <vprintfmt+0x5b>
  8008dc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008e2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8008e5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8008e8:	e9 5b ff ff ff       	jmp    800848 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ed:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8008f0:	e9 53 ff ff ff       	jmp    800848 <vprintfmt+0x5b>
  8008f5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8d 50 04             	lea    0x4(%eax),%edx
  8008fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800901:	89 74 24 04          	mov    %esi,0x4(%esp)
  800905:	8b 00                	mov    (%eax),%eax
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	ff d7                	call   *%edi
  80090c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80090f:	e9 05 ff ff ff       	jmp    800819 <vprintfmt+0x2c>
  800914:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8d 50 04             	lea    0x4(%eax),%edx
  80091d:	89 55 14             	mov    %edx,0x14(%ebp)
  800920:	8b 00                	mov    (%eax),%eax
  800922:	89 c2                	mov    %eax,%edx
  800924:	c1 fa 1f             	sar    $0x1f,%edx
  800927:	31 d0                	xor    %edx,%eax
  800929:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092b:	83 f8 08             	cmp    $0x8,%eax
  80092e:	7f 0b                	jg     80093b <vprintfmt+0x14e>
  800930:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800937:	85 d2                	test   %edx,%edx
  800939:	75 20                	jne    80095b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80093b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093f:	c7 44 24 08 f1 13 80 	movl   $0x8013f1,0x8(%esp)
  800946:	00 
  800947:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094b:	89 3c 24             	mov    %edi,(%esp)
  80094e:	e8 4e 03 00 00       	call   800ca1 <printfmt>
  800953:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800956:	e9 be fe ff ff       	jmp    800819 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80095b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80095f:	c7 44 24 08 fa 13 80 	movl   $0x8013fa,0x8(%esp)
  800966:	00 
  800967:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096b:	89 3c 24             	mov    %edi,(%esp)
  80096e:	e8 2e 03 00 00       	call   800ca1 <printfmt>
  800973:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800976:	e9 9e fe ff ff       	jmp    800819 <vprintfmt+0x2c>
  80097b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80097e:	89 c3                	mov    %eax,%ebx
  800980:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800986:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	8d 50 04             	lea    0x4(%eax),%edx
  80098f:	89 55 14             	mov    %edx,0x14(%ebp)
  800992:	8b 00                	mov    (%eax),%eax
  800994:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800997:	85 c0                	test   %eax,%eax
  800999:	75 07                	jne    8009a2 <vprintfmt+0x1b5>
  80099b:	c7 45 c4 fd 13 80 00 	movl   $0x8013fd,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8009a2:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8009a6:	7e 06                	jle    8009ae <vprintfmt+0x1c1>
  8009a8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8009ac:	75 13                	jne    8009c1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009b1:	0f be 02             	movsbl (%edx),%eax
  8009b4:	85 c0                	test   %eax,%eax
  8009b6:	0f 85 99 00 00 00    	jne    800a55 <vprintfmt+0x268>
  8009bc:	e9 86 00 00 00       	jmp    800a47 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8009c8:	89 0c 24             	mov    %ecx,(%esp)
  8009cb:	e8 1b 03 00 00       	call   800ceb <strnlen>
  8009d0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8009d3:	29 c2                	sub    %eax,%edx
  8009d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d8:	85 d2                	test   %edx,%edx
  8009da:	7e d2                	jle    8009ae <vprintfmt+0x1c1>
					putch(padc, putdat);
  8009dc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8009e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009e3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8009e6:	89 d3                	mov    %edx,%ebx
  8009e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009ef:	89 04 24             	mov    %eax,(%esp)
  8009f2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f4:	83 eb 01             	sub    $0x1,%ebx
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	7f ed                	jg     8009e8 <vprintfmt+0x1fb>
  8009fb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8009fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a05:	eb a7                	jmp    8009ae <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a07:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a0b:	74 18                	je     800a25 <vprintfmt+0x238>
  800a0d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a10:	83 fa 5e             	cmp    $0x5e,%edx
  800a13:	76 10                	jbe    800a25 <vprintfmt+0x238>
					putch('?', putdat);
  800a15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a19:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a20:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a23:	eb 0a                	jmp    800a2f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a25:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a29:	89 04 24             	mov    %eax,(%esp)
  800a2c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a33:	0f be 03             	movsbl (%ebx),%eax
  800a36:	85 c0                	test   %eax,%eax
  800a38:	74 05                	je     800a3f <vprintfmt+0x252>
  800a3a:	83 c3 01             	add    $0x1,%ebx
  800a3d:	eb 29                	jmp    800a68 <vprintfmt+0x27b>
  800a3f:	89 fe                	mov    %edi,%esi
  800a41:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a44:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a4b:	7f 2e                	jg     800a7b <vprintfmt+0x28e>
  800a4d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a50:	e9 c4 fd ff ff       	jmp    800819 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a55:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a58:	83 c2 01             	add    $0x1,%edx
  800a5b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800a5e:	89 f7                	mov    %esi,%edi
  800a60:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a63:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a66:	89 d3                	mov    %edx,%ebx
  800a68:	85 f6                	test   %esi,%esi
  800a6a:	78 9b                	js     800a07 <vprintfmt+0x21a>
  800a6c:	83 ee 01             	sub    $0x1,%esi
  800a6f:	79 96                	jns    800a07 <vprintfmt+0x21a>
  800a71:	89 fe                	mov    %edi,%esi
  800a73:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a76:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a79:	eb cc                	jmp    800a47 <vprintfmt+0x25a>
  800a7b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a7e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a81:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a85:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a8c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a8e:	83 eb 01             	sub    $0x1,%ebx
  800a91:	85 db                	test   %ebx,%ebx
  800a93:	7f ec                	jg     800a81 <vprintfmt+0x294>
  800a95:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a98:	e9 7c fd ff ff       	jmp    800819 <vprintfmt+0x2c>
  800a9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aa0:	83 f9 01             	cmp    $0x1,%ecx
  800aa3:	7e 16                	jle    800abb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	8d 50 08             	lea    0x8(%eax),%edx
  800aab:	89 55 14             	mov    %edx,0x14(%ebp)
  800aae:	8b 10                	mov    (%eax),%edx
  800ab0:	8b 48 04             	mov    0x4(%eax),%ecx
  800ab3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800ab6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ab9:	eb 32                	jmp    800aed <vprintfmt+0x300>
	else if (lflag)
  800abb:	85 c9                	test   %ecx,%ecx
  800abd:	74 18                	je     800ad7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800abf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac2:	8d 50 04             	lea    0x4(%eax),%edx
  800ac5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac8:	8b 00                	mov    (%eax),%eax
  800aca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800acd:	89 c1                	mov    %eax,%ecx
  800acf:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ad5:	eb 16                	jmp    800aed <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800ad7:	8b 45 14             	mov    0x14(%ebp),%eax
  800ada:	8d 50 04             	lea    0x4(%eax),%edx
  800add:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae0:	8b 00                	mov    (%eax),%eax
  800ae2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	c1 fa 1f             	sar    $0x1f,%edx
  800aea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aed:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800af0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800af3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800af8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800afc:	0f 89 b8 00 00 00    	jns    800bba <vprintfmt+0x3cd>
				putch('-', putdat);
  800b02:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b06:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b0d:	ff d7                	call   *%edi
				num = -(long long) num;
  800b0f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b12:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b15:	f7 d9                	neg    %ecx
  800b17:	83 d3 00             	adc    $0x0,%ebx
  800b1a:	f7 db                	neg    %ebx
  800b1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b21:	e9 94 00 00 00       	jmp    800bba <vprintfmt+0x3cd>
  800b26:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b29:	89 ca                	mov    %ecx,%edx
  800b2b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2e:	e8 63 fc ff ff       	call   800796 <getuint>
  800b33:	89 c1                	mov    %eax,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800b3c:	eb 7c                	jmp    800bba <vprintfmt+0x3cd>
  800b3e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b45:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b4c:	ff d7                	call   *%edi
			putch('X', putdat);
  800b4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b52:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b59:	ff d7                	call   *%edi
			putch('X', putdat);
  800b5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b5f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b66:	ff d7                	call   *%edi
  800b68:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800b6b:	e9 a9 fc ff ff       	jmp    800819 <vprintfmt+0x2c>
  800b70:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800b73:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b77:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b7e:	ff d7                	call   *%edi
			putch('x', putdat);
  800b80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b84:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b8b:	ff d7                	call   *%edi
			num = (unsigned long long)
  800b8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b90:	8d 50 04             	lea    0x4(%eax),%edx
  800b93:	89 55 14             	mov    %edx,0x14(%ebp)
  800b96:	8b 08                	mov    (%eax),%ecx
  800b98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ba2:	eb 16                	jmp    800bba <vprintfmt+0x3cd>
  800ba4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ba7:	89 ca                	mov    %ecx,%edx
  800ba9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bac:	e8 e5 fb ff ff       	call   800796 <getuint>
  800bb1:	89 c1                	mov    %eax,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bba:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800bbe:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bc2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bc5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bc9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcd:	89 0c 24             	mov    %ecx,(%esp)
  800bd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd4:	89 f2                	mov    %esi,%edx
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	e8 c3 fa ff ff       	call   8006a0 <printnum>
  800bdd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800be0:	e9 34 fc ff ff       	jmp    800819 <vprintfmt+0x2c>
  800be5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800be8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800beb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bef:	89 14 24             	mov    %edx,(%esp)
  800bf2:	ff d7                	call   *%edi
  800bf4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800bf7:	e9 1d fc ff ff       	jmp    800819 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c00:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c07:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c09:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800c0c:	80 38 25             	cmpb   $0x25,(%eax)
  800c0f:	0f 84 04 fc ff ff    	je     800819 <vprintfmt+0x2c>
  800c15:	89 c3                	mov    %eax,%ebx
  800c17:	eb f0                	jmp    800c09 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800c19:	83 c4 5c             	add    $0x5c,%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 28             	sub    $0x28,%esp
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	74 04                	je     800c35 <vsnprintf+0x14>
  800c31:	85 d2                	test   %edx,%edx
  800c33:	7f 07                	jg     800c3c <vsnprintf+0x1b>
  800c35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c3a:	eb 3b                	jmp    800c77 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c3f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800c43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c54:	8b 45 10             	mov    0x10(%ebp),%eax
  800c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c62:	c7 04 24 d0 07 80 00 	movl   $0x8007d0,(%esp)
  800c69:	e8 7f fb ff ff       	call   8007ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c71:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c7f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800c82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c86:	8b 45 10             	mov    0x10(%ebp),%eax
  800c89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	89 04 24             	mov    %eax,(%esp)
  800c9a:	e8 82 ff ff ff       	call   800c21 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800ca7:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800caa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	89 04 24             	mov    %eax,(%esp)
  800cc2:	e8 26 fb ff ff       	call   8007ed <vprintfmt>
	va_end(ap);
}
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    
  800cc9:	00 00                	add    %al,(%eax)
  800ccb:	00 00                	add    %al,(%eax)
  800ccd:	00 00                	add    %al,(%eax)
	...

00800cd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	80 3a 00             	cmpb   $0x0,(%edx)
  800cde:	74 09                	je     800ce9 <strlen+0x19>
		n++;
  800ce0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce7:	75 f7                	jne    800ce0 <strlen+0x10>
		n++;
	return n;
}
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf5:	85 c9                	test   %ecx,%ecx
  800cf7:	74 19                	je     800d12 <strnlen+0x27>
  800cf9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800cfc:	74 14                	je     800d12 <strnlen+0x27>
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d03:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d06:	39 c8                	cmp    %ecx,%eax
  800d08:	74 0d                	je     800d17 <strnlen+0x2c>
  800d0a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800d0e:	75 f3                	jne    800d03 <strnlen+0x18>
  800d10:	eb 05                	jmp    800d17 <strnlen+0x2c>
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d17:	5b                   	pop    %ebx
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	53                   	push   %ebx
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d2d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d30:	83 c2 01             	add    $0x1,%edx
  800d33:	84 c9                	test   %cl,%cl
  800d35:	75 f2                	jne    800d29 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d37:	5b                   	pop    %ebx
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 08             	sub    $0x8,%esp
  800d41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d44:	89 1c 24             	mov    %ebx,(%esp)
  800d47:	e8 84 ff ff ff       	call   800cd0 <strlen>
	strcpy(dst + len, src);
  800d4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d53:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d56:	89 04 24             	mov    %eax,(%esp)
  800d59:	e8 bc ff ff ff       	call   800d1a <strcpy>
	return dst;
}
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	83 c4 08             	add    $0x8,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d74:	85 f6                	test   %esi,%esi
  800d76:	74 18                	je     800d90 <strncpy+0x2a>
  800d78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d7d:	0f b6 1a             	movzbl (%edx),%ebx
  800d80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d83:	80 3a 01             	cmpb   $0x1,(%edx)
  800d86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d89:	83 c1 01             	add    $0x1,%ecx
  800d8c:	39 ce                	cmp    %ecx,%esi
  800d8e:	77 ed                	ja     800d7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	85 c9                	test   %ecx,%ecx
  800da6:	74 27                	je     800dcf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800da8:	83 e9 01             	sub    $0x1,%ecx
  800dab:	74 1d                	je     800dca <strlcpy+0x36>
  800dad:	0f b6 1a             	movzbl (%edx),%ebx
  800db0:	84 db                	test   %bl,%bl
  800db2:	74 16                	je     800dca <strlcpy+0x36>
			*dst++ = *src++;
  800db4:	88 18                	mov    %bl,(%eax)
  800db6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800db9:	83 e9 01             	sub    $0x1,%ecx
  800dbc:	74 0e                	je     800dcc <strlcpy+0x38>
			*dst++ = *src++;
  800dbe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc1:	0f b6 1a             	movzbl (%edx),%ebx
  800dc4:	84 db                	test   %bl,%bl
  800dc6:	75 ec                	jne    800db4 <strlcpy+0x20>
  800dc8:	eb 02                	jmp    800dcc <strlcpy+0x38>
  800dca:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dcc:	c6 00 00             	movb   $0x0,(%eax)
  800dcf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dde:	0f b6 01             	movzbl (%ecx),%eax
  800de1:	84 c0                	test   %al,%al
  800de3:	74 15                	je     800dfa <strcmp+0x25>
  800de5:	3a 02                	cmp    (%edx),%al
  800de7:	75 11                	jne    800dfa <strcmp+0x25>
		p++, q++;
  800de9:	83 c1 01             	add    $0x1,%ecx
  800dec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800def:	0f b6 01             	movzbl (%ecx),%eax
  800df2:	84 c0                	test   %al,%al
  800df4:	74 04                	je     800dfa <strcmp+0x25>
  800df6:	3a 02                	cmp    (%edx),%al
  800df8:	74 ef                	je     800de9 <strcmp+0x14>
  800dfa:	0f b6 c0             	movzbl %al,%eax
  800dfd:	0f b6 12             	movzbl (%edx),%edx
  800e00:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	53                   	push   %ebx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	74 23                	je     800e38 <strncmp+0x34>
  800e15:	0f b6 1a             	movzbl (%edx),%ebx
  800e18:	84 db                	test   %bl,%bl
  800e1a:	74 25                	je     800e41 <strncmp+0x3d>
  800e1c:	3a 19                	cmp    (%ecx),%bl
  800e1e:	75 21                	jne    800e41 <strncmp+0x3d>
  800e20:	83 e8 01             	sub    $0x1,%eax
  800e23:	74 13                	je     800e38 <strncmp+0x34>
		n--, p++, q++;
  800e25:	83 c2 01             	add    $0x1,%edx
  800e28:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e2b:	0f b6 1a             	movzbl (%edx),%ebx
  800e2e:	84 db                	test   %bl,%bl
  800e30:	74 0f                	je     800e41 <strncmp+0x3d>
  800e32:	3a 19                	cmp    (%ecx),%bl
  800e34:	74 ea                	je     800e20 <strncmp+0x1c>
  800e36:	eb 09                	jmp    800e41 <strncmp+0x3d>
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e3d:	5b                   	pop    %ebx
  800e3e:	5d                   	pop    %ebp
  800e3f:	90                   	nop
  800e40:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e41:	0f b6 02             	movzbl (%edx),%eax
  800e44:	0f b6 11             	movzbl (%ecx),%edx
  800e47:	29 d0                	sub    %edx,%eax
  800e49:	eb f2                	jmp    800e3d <strncmp+0x39>

00800e4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e55:	0f b6 10             	movzbl (%eax),%edx
  800e58:	84 d2                	test   %dl,%dl
  800e5a:	74 18                	je     800e74 <strchr+0x29>
		if (*s == c)
  800e5c:	38 ca                	cmp    %cl,%dl
  800e5e:	75 0a                	jne    800e6a <strchr+0x1f>
  800e60:	eb 17                	jmp    800e79 <strchr+0x2e>
  800e62:	38 ca                	cmp    %cl,%dl
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	74 0f                	je     800e79 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e6a:	83 c0 01             	add    $0x1,%eax
  800e6d:	0f b6 10             	movzbl (%eax),%edx
  800e70:	84 d2                	test   %dl,%dl
  800e72:	75 ee                	jne    800e62 <strchr+0x17>
  800e74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e85:	0f b6 10             	movzbl (%eax),%edx
  800e88:	84 d2                	test   %dl,%dl
  800e8a:	74 18                	je     800ea4 <strfind+0x29>
		if (*s == c)
  800e8c:	38 ca                	cmp    %cl,%dl
  800e8e:	75 0a                	jne    800e9a <strfind+0x1f>
  800e90:	eb 12                	jmp    800ea4 <strfind+0x29>
  800e92:	38 ca                	cmp    %cl,%dl
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	74 0a                	je     800ea4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e9a:	83 c0 01             	add    $0x1,%eax
  800e9d:	0f b6 10             	movzbl (%eax),%edx
  800ea0:	84 d2                	test   %dl,%dl
  800ea2:	75 ee                	jne    800e92 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	89 1c 24             	mov    %ebx,(%esp)
  800eaf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800eb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ec0:	85 c9                	test   %ecx,%ecx
  800ec2:	74 30                	je     800ef4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eca:	75 25                	jne    800ef1 <memset+0x4b>
  800ecc:	f6 c1 03             	test   $0x3,%cl
  800ecf:	75 20                	jne    800ef1 <memset+0x4b>
		c &= 0xFF;
  800ed1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed4:	89 d3                	mov    %edx,%ebx
  800ed6:	c1 e3 08             	shl    $0x8,%ebx
  800ed9:	89 d6                	mov    %edx,%esi
  800edb:	c1 e6 18             	shl    $0x18,%esi
  800ede:	89 d0                	mov    %edx,%eax
  800ee0:	c1 e0 10             	shl    $0x10,%eax
  800ee3:	09 f0                	or     %esi,%eax
  800ee5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ee7:	09 d8                	or     %ebx,%eax
  800ee9:	c1 e9 02             	shr    $0x2,%ecx
  800eec:	fc                   	cld    
  800eed:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eef:	eb 03                	jmp    800ef4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ef1:	fc                   	cld    
  800ef2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ef4:	89 f8                	mov    %edi,%eax
  800ef6:	8b 1c 24             	mov    (%esp),%ebx
  800ef9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800efd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f01:	89 ec                	mov    %ebp,%esp
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	89 34 24             	mov    %esi,(%esp)
  800f0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f18:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f1b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800f1d:	39 c6                	cmp    %eax,%esi
  800f1f:	73 35                	jae    800f56 <memmove+0x51>
  800f21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f24:	39 d0                	cmp    %edx,%eax
  800f26:	73 2e                	jae    800f56 <memmove+0x51>
		s += n;
		d += n;
  800f28:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2a:	f6 c2 03             	test   $0x3,%dl
  800f2d:	75 1b                	jne    800f4a <memmove+0x45>
  800f2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f35:	75 13                	jne    800f4a <memmove+0x45>
  800f37:	f6 c1 03             	test   $0x3,%cl
  800f3a:	75 0e                	jne    800f4a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800f3c:	83 ef 04             	sub    $0x4,%edi
  800f3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f42:	c1 e9 02             	shr    $0x2,%ecx
  800f45:	fd                   	std    
  800f46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f48:	eb 09                	jmp    800f53 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f4a:	83 ef 01             	sub    $0x1,%edi
  800f4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f50:	fd                   	std    
  800f51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f53:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f54:	eb 20                	jmp    800f76 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f5c:	75 15                	jne    800f73 <memmove+0x6e>
  800f5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f64:	75 0d                	jne    800f73 <memmove+0x6e>
  800f66:	f6 c1 03             	test   $0x3,%cl
  800f69:	75 08                	jne    800f73 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800f6b:	c1 e9 02             	shr    $0x2,%ecx
  800f6e:	fc                   	cld    
  800f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f71:	eb 03                	jmp    800f76 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f73:	fc                   	cld    
  800f74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f76:	8b 34 24             	mov    (%esp),%esi
  800f79:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f7d:	89 ec                	mov    %ebp,%esp
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f87:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	e8 65 ff ff ff       	call   800f05 <memmove>
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb1:	85 c9                	test   %ecx,%ecx
  800fb3:	74 36                	je     800feb <memcmp+0x49>
		if (*s1 != *s2)
  800fb5:	0f b6 06             	movzbl (%esi),%eax
  800fb8:	0f b6 1f             	movzbl (%edi),%ebx
  800fbb:	38 d8                	cmp    %bl,%al
  800fbd:	74 20                	je     800fdf <memcmp+0x3d>
  800fbf:	eb 14                	jmp    800fd5 <memcmp+0x33>
  800fc1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800fc6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800fcb:	83 c2 01             	add    $0x1,%edx
  800fce:	83 e9 01             	sub    $0x1,%ecx
  800fd1:	38 d8                	cmp    %bl,%al
  800fd3:	74 12                	je     800fe7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800fd5:	0f b6 c0             	movzbl %al,%eax
  800fd8:	0f b6 db             	movzbl %bl,%ebx
  800fdb:	29 d8                	sub    %ebx,%eax
  800fdd:	eb 11                	jmp    800ff0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fdf:	83 e9 01             	sub    $0x1,%ecx
  800fe2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe7:	85 c9                	test   %ecx,%ecx
  800fe9:	75 d6                	jne    800fc1 <memcmp+0x1f>
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ffb:	89 c2                	mov    %eax,%edx
  800ffd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801000:	39 d0                	cmp    %edx,%eax
  801002:	73 15                	jae    801019 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801004:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801008:	38 08                	cmp    %cl,(%eax)
  80100a:	75 06                	jne    801012 <memfind+0x1d>
  80100c:	eb 0b                	jmp    801019 <memfind+0x24>
  80100e:	38 08                	cmp    %cl,(%eax)
  801010:	74 07                	je     801019 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801012:	83 c0 01             	add    $0x1,%eax
  801015:	39 c2                	cmp    %eax,%edx
  801017:	77 f5                	ja     80100e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 04             	sub    $0x4,%esp
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80102a:	0f b6 02             	movzbl (%edx),%eax
  80102d:	3c 20                	cmp    $0x20,%al
  80102f:	74 04                	je     801035 <strtol+0x1a>
  801031:	3c 09                	cmp    $0x9,%al
  801033:	75 0e                	jne    801043 <strtol+0x28>
		s++;
  801035:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801038:	0f b6 02             	movzbl (%edx),%eax
  80103b:	3c 20                	cmp    $0x20,%al
  80103d:	74 f6                	je     801035 <strtol+0x1a>
  80103f:	3c 09                	cmp    $0x9,%al
  801041:	74 f2                	je     801035 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801043:	3c 2b                	cmp    $0x2b,%al
  801045:	75 0c                	jne    801053 <strtol+0x38>
		s++;
  801047:	83 c2 01             	add    $0x1,%edx
  80104a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801051:	eb 15                	jmp    801068 <strtol+0x4d>
	else if (*s == '-')
  801053:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80105a:	3c 2d                	cmp    $0x2d,%al
  80105c:	75 0a                	jne    801068 <strtol+0x4d>
		s++, neg = 1;
  80105e:	83 c2 01             	add    $0x1,%edx
  801061:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801068:	85 db                	test   %ebx,%ebx
  80106a:	0f 94 c0             	sete   %al
  80106d:	74 05                	je     801074 <strtol+0x59>
  80106f:	83 fb 10             	cmp    $0x10,%ebx
  801072:	75 18                	jne    80108c <strtol+0x71>
  801074:	80 3a 30             	cmpb   $0x30,(%edx)
  801077:	75 13                	jne    80108c <strtol+0x71>
  801079:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
  801080:	75 0a                	jne    80108c <strtol+0x71>
		s += 2, base = 16;
  801082:	83 c2 02             	add    $0x2,%edx
  801085:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80108a:	eb 15                	jmp    8010a1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80108c:	84 c0                	test   %al,%al
  80108e:	66 90                	xchg   %ax,%ax
  801090:	74 0f                	je     8010a1 <strtol+0x86>
  801092:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801097:	80 3a 30             	cmpb   $0x30,(%edx)
  80109a:	75 05                	jne    8010a1 <strtol+0x86>
		s++, base = 8;
  80109c:	83 c2 01             	add    $0x1,%edx
  80109f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010a8:	0f b6 0a             	movzbl (%edx),%ecx
  8010ab:	89 cf                	mov    %ecx,%edi
  8010ad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8010b0:	80 fb 09             	cmp    $0x9,%bl
  8010b3:	77 08                	ja     8010bd <strtol+0xa2>
			dig = *s - '0';
  8010b5:	0f be c9             	movsbl %cl,%ecx
  8010b8:	83 e9 30             	sub    $0x30,%ecx
  8010bb:	eb 1e                	jmp    8010db <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8010bd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8010c0:	80 fb 19             	cmp    $0x19,%bl
  8010c3:	77 08                	ja     8010cd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8010c5:	0f be c9             	movsbl %cl,%ecx
  8010c8:	83 e9 57             	sub    $0x57,%ecx
  8010cb:	eb 0e                	jmp    8010db <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8010cd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8010d0:	80 fb 19             	cmp    $0x19,%bl
  8010d3:	77 15                	ja     8010ea <strtol+0xcf>
			dig = *s - 'A' + 10;
  8010d5:	0f be c9             	movsbl %cl,%ecx
  8010d8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010db:	39 f1                	cmp    %esi,%ecx
  8010dd:	7d 0b                	jge    8010ea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8010df:	83 c2 01             	add    $0x1,%edx
  8010e2:	0f af c6             	imul   %esi,%eax
  8010e5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8010e8:	eb be                	jmp    8010a8 <strtol+0x8d>
  8010ea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8010ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010f0:	74 05                	je     8010f7 <strtol+0xdc>
		*endptr = (char *) s;
  8010f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010f5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8010fb:	74 04                	je     801101 <strtol+0xe6>
  8010fd:	89 c8                	mov    %ecx,%eax
  8010ff:	f7 d8                	neg    %eax
}
  801101:	83 c4 04             	add    $0x4,%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    
  801109:	00 00                	add    %al,(%eax)
  80110b:	00 00                	add    %al,(%eax)
  80110d:	00 00                	add    %al,(%eax)
	...

00801110 <__udivdi3>:
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	83 ec 10             	sub    $0x10,%esp
  801118:	8b 45 14             	mov    0x14(%ebp),%eax
  80111b:	8b 55 08             	mov    0x8(%ebp),%edx
  80111e:	8b 75 10             	mov    0x10(%ebp),%esi
  801121:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801124:	85 c0                	test   %eax,%eax
  801126:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801129:	75 35                	jne    801160 <__udivdi3+0x50>
  80112b:	39 fe                	cmp    %edi,%esi
  80112d:	77 61                	ja     801190 <__udivdi3+0x80>
  80112f:	85 f6                	test   %esi,%esi
  801131:	75 0b                	jne    80113e <__udivdi3+0x2e>
  801133:	b8 01 00 00 00       	mov    $0x1,%eax
  801138:	31 d2                	xor    %edx,%edx
  80113a:	f7 f6                	div    %esi
  80113c:	89 c6                	mov    %eax,%esi
  80113e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801141:	31 d2                	xor    %edx,%edx
  801143:	89 f8                	mov    %edi,%eax
  801145:	f7 f6                	div    %esi
  801147:	89 c7                	mov    %eax,%edi
  801149:	89 c8                	mov    %ecx,%eax
  80114b:	f7 f6                	div    %esi
  80114d:	89 c1                	mov    %eax,%ecx
  80114f:	89 fa                	mov    %edi,%edx
  801151:	89 c8                	mov    %ecx,%eax
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    
  80115a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801160:	39 f8                	cmp    %edi,%eax
  801162:	77 1c                	ja     801180 <__udivdi3+0x70>
  801164:	0f bd d0             	bsr    %eax,%edx
  801167:	83 f2 1f             	xor    $0x1f,%edx
  80116a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80116d:	75 39                	jne    8011a8 <__udivdi3+0x98>
  80116f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801172:	0f 86 a0 00 00 00    	jbe    801218 <__udivdi3+0x108>
  801178:	39 f8                	cmp    %edi,%eax
  80117a:	0f 82 98 00 00 00    	jb     801218 <__udivdi3+0x108>
  801180:	31 ff                	xor    %edi,%edi
  801182:	31 c9                	xor    %ecx,%ecx
  801184:	89 c8                	mov    %ecx,%eax
  801186:	89 fa                	mov    %edi,%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    
  80118f:	90                   	nop
  801190:	89 d1                	mov    %edx,%ecx
  801192:	89 fa                	mov    %edi,%edx
  801194:	89 c8                	mov    %ecx,%eax
  801196:	31 ff                	xor    %edi,%edi
  801198:	f7 f6                	div    %esi
  80119a:	89 c1                	mov    %eax,%ecx
  80119c:	89 fa                	mov    %edi,%edx
  80119e:	89 c8                	mov    %ecx,%eax
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	5e                   	pop    %esi
  8011a4:	5f                   	pop    %edi
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    
  8011a7:	90                   	nop
  8011a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	d3 e0                	shl    %cl,%eax
  8011b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011bb:	89 c1                	mov    %eax,%ecx
  8011bd:	d3 ea                	shr    %cl,%edx
  8011bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011c6:	d3 e6                	shl    %cl,%esi
  8011c8:	89 c1                	mov    %eax,%ecx
  8011ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011cd:	89 fe                	mov    %edi,%esi
  8011cf:	d3 ee                	shr    %cl,%esi
  8011d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011db:	d3 e7                	shl    %cl,%edi
  8011dd:	89 c1                	mov    %eax,%ecx
  8011df:	d3 ea                	shr    %cl,%edx
  8011e1:	09 d7                	or     %edx,%edi
  8011e3:	89 f2                	mov    %esi,%edx
  8011e5:	89 f8                	mov    %edi,%eax
  8011e7:	f7 75 ec             	divl   -0x14(%ebp)
  8011ea:	89 d6                	mov    %edx,%esi
  8011ec:	89 c7                	mov    %eax,%edi
  8011ee:	f7 65 e8             	mull   -0x18(%ebp)
  8011f1:	39 d6                	cmp    %edx,%esi
  8011f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011f6:	72 30                	jb     801228 <__udivdi3+0x118>
  8011f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ff:	d3 e2                	shl    %cl,%edx
  801201:	39 c2                	cmp    %eax,%edx
  801203:	73 05                	jae    80120a <__udivdi3+0xfa>
  801205:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801208:	74 1e                	je     801228 <__udivdi3+0x118>
  80120a:	89 f9                	mov    %edi,%ecx
  80120c:	31 ff                	xor    %edi,%edi
  80120e:	e9 71 ff ff ff       	jmp    801184 <__udivdi3+0x74>
  801213:	90                   	nop
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 ff                	xor    %edi,%edi
  80121a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80121f:	e9 60 ff ff ff       	jmp    801184 <__udivdi3+0x74>
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80122b:	31 ff                	xor    %edi,%edi
  80122d:	89 c8                	mov    %ecx,%eax
  80122f:	89 fa                	mov    %edi,%edx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
	...

00801240 <__umoddi3>:
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	83 ec 20             	sub    $0x20,%esp
  801248:	8b 55 14             	mov    0x14(%ebp),%edx
  80124b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801251:	8b 75 0c             	mov    0xc(%ebp),%esi
  801254:	85 d2                	test   %edx,%edx
  801256:	89 c8                	mov    %ecx,%eax
  801258:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80125b:	75 13                	jne    801270 <__umoddi3+0x30>
  80125d:	39 f7                	cmp    %esi,%edi
  80125f:	76 3f                	jbe    8012a0 <__umoddi3+0x60>
  801261:	89 f2                	mov    %esi,%edx
  801263:	f7 f7                	div    %edi
  801265:	89 d0                	mov    %edx,%eax
  801267:	31 d2                	xor    %edx,%edx
  801269:	83 c4 20             	add    $0x20,%esp
  80126c:	5e                   	pop    %esi
  80126d:	5f                   	pop    %edi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    
  801270:	39 f2                	cmp    %esi,%edx
  801272:	77 4c                	ja     8012c0 <__umoddi3+0x80>
  801274:	0f bd ca             	bsr    %edx,%ecx
  801277:	83 f1 1f             	xor    $0x1f,%ecx
  80127a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80127d:	75 51                	jne    8012d0 <__umoddi3+0x90>
  80127f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801282:	0f 87 e0 00 00 00    	ja     801368 <__umoddi3+0x128>
  801288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128b:	29 f8                	sub    %edi,%eax
  80128d:	19 d6                	sbb    %edx,%esi
  80128f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801295:	89 f2                	mov    %esi,%edx
  801297:	83 c4 20             	add    $0x20,%esp
  80129a:	5e                   	pop    %esi
  80129b:	5f                   	pop    %edi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    
  80129e:	66 90                	xchg   %ax,%ax
  8012a0:	85 ff                	test   %edi,%edi
  8012a2:	75 0b                	jne    8012af <__umoddi3+0x6f>
  8012a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a9:	31 d2                	xor    %edx,%edx
  8012ab:	f7 f7                	div    %edi
  8012ad:	89 c7                	mov    %eax,%edi
  8012af:	89 f0                	mov    %esi,%eax
  8012b1:	31 d2                	xor    %edx,%edx
  8012b3:	f7 f7                	div    %edi
  8012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b8:	f7 f7                	div    %edi
  8012ba:	eb a9                	jmp    801265 <__umoddi3+0x25>
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 c8                	mov    %ecx,%eax
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	83 c4 20             	add    $0x20,%esp
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    
  8012cb:	90                   	nop
  8012cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012d4:	d3 e2                	shl    %cl,%edx
  8012d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8012de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8012e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012e8:	89 fa                	mov    %edi,%edx
  8012ea:	d3 ea                	shr    %cl,%edx
  8012ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8012f3:	d3 e7                	shl    %cl,%edi
  8012f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012fc:	89 f2                	mov    %esi,%edx
  8012fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801301:	89 c7                	mov    %eax,%edi
  801303:	d3 ea                	shr    %cl,%edx
  801305:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801309:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	d3 e6                	shl    %cl,%esi
  801310:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801314:	d3 ea                	shr    %cl,%edx
  801316:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80131a:	09 d6                	or     %edx,%esi
  80131c:	89 f0                	mov    %esi,%eax
  80131e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801321:	d3 e7                	shl    %cl,%edi
  801323:	89 f2                	mov    %esi,%edx
  801325:	f7 75 f4             	divl   -0xc(%ebp)
  801328:	89 d6                	mov    %edx,%esi
  80132a:	f7 65 e8             	mull   -0x18(%ebp)
  80132d:	39 d6                	cmp    %edx,%esi
  80132f:	72 2b                	jb     80135c <__umoddi3+0x11c>
  801331:	39 c7                	cmp    %eax,%edi
  801333:	72 23                	jb     801358 <__umoddi3+0x118>
  801335:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801339:	29 c7                	sub    %eax,%edi
  80133b:	19 d6                	sbb    %edx,%esi
  80133d:	89 f0                	mov    %esi,%eax
  80133f:	89 f2                	mov    %esi,%edx
  801341:	d3 ef                	shr    %cl,%edi
  801343:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801347:	d3 e0                	shl    %cl,%eax
  801349:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80134d:	09 f8                	or     %edi,%eax
  80134f:	d3 ea                	shr    %cl,%edx
  801351:	83 c4 20             	add    $0x20,%esp
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    
  801358:	39 d6                	cmp    %edx,%esi
  80135a:	75 d9                	jne    801335 <__umoddi3+0xf5>
  80135c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80135f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801362:	eb d1                	jmp    801335 <__umoddi3+0xf5>
  801364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801368:	39 f2                	cmp    %esi,%edx
  80136a:	0f 82 18 ff ff ff    	jb     801288 <__umoddi3+0x48>
  801370:	e9 1d ff ff ff       	jmp    801292 <__umoddi3+0x52>
