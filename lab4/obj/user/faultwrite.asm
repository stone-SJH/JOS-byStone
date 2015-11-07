
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800056:	e8 57 04 00 00       	call   8004b2 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	c1 e0 07             	shl    $0x7,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 4c 04 00 00       	call   8004f2 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	51                   	push   %ecx
  8000c6:	52                   	push   %edx
  8000c7:	53                   	push   %ebx
  8000c8:	54                   	push   %esp
  8000c9:	55                   	push   %ebp
  8000ca:	56                   	push   %esi
  8000cb:	57                   	push   %edi
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	8d 35 d6 00 80 00    	lea    0x8000d6,%esi
  8000d4:	0f 34                	sysenter 
  8000d6:	5f                   	pop    %edi
  8000d7:	5e                   	pop    %esi
  8000d8:	5d                   	pop    %ebp
  8000d9:	5c                   	pop    %esp
  8000da:	5b                   	pop    %ebx
  8000db:	5a                   	pop    %edx
  8000dc:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	8b 1c 24             	mov    (%esp),%ebx
  8000e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000e4:	89 ec                	mov    %ebp,%esp
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	89 1c 24             	mov    %ebx,(%esp)
  8000f1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800100:	89 c3                	mov    %eax,%ebx
  800102:	89 c7                	mov    %eax,%edi
  800104:	51                   	push   %ecx
  800105:	52                   	push   %edx
  800106:	53                   	push   %ebx
  800107:	54                   	push   %esp
  800108:	55                   	push   %ebp
  800109:	56                   	push   %esi
  80010a:	57                   	push   %edi
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	8d 35 15 01 80 00    	lea    0x800115,%esi
  800113:	0f 34                	sysenter 
  800115:	5f                   	pop    %edi
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	5c                   	pop    %esp
  800119:	5b                   	pop    %ebx
  80011a:	5a                   	pop    %edx
  80011b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80011c:	8b 1c 24             	mov    (%esp),%ebx
  80011f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800123:	89 ec                	mov    %ebp,%esp
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	89 1c 24             	mov    %ebx,(%esp)
  800130:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800134:	b9 00 00 00 00       	mov    $0x0,%ecx
  800139:	b8 0e 00 00 00       	mov    $0xe,%eax
  80013e:	8b 55 08             	mov    0x8(%ebp),%edx
  800141:	89 cb                	mov    %ecx,%ebx
  800143:	89 cf                	mov    %ecx,%edi
  800145:	51                   	push   %ecx
  800146:	52                   	push   %edx
  800147:	53                   	push   %ebx
  800148:	54                   	push   %esp
  800149:	55                   	push   %ebp
  80014a:	56                   	push   %esi
  80014b:	57                   	push   %edi
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	8d 35 56 01 80 00    	lea    0x800156,%esi
  800154:	0f 34                	sysenter 
  800156:	5f                   	pop    %edi
  800157:	5e                   	pop    %esi
  800158:	5d                   	pop    %ebp
  800159:	5c                   	pop    %esp
  80015a:	5b                   	pop    %ebx
  80015b:	5a                   	pop    %edx
  80015c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80015d:	8b 1c 24             	mov    (%esp),%ebx
  800160:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800164:	89 ec                	mov    %ebp,%esp
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 28             	sub    $0x28,%esp
  80016e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800171:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800174:	b9 00 00 00 00       	mov    $0x0,%ecx
  800179:	b8 0d 00 00 00       	mov    $0xd,%eax
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	89 cb                	mov    %ecx,%ebx
  800183:	89 cf                	mov    %ecx,%edi
  800185:	51                   	push   %ecx
  800186:	52                   	push   %edx
  800187:	53                   	push   %ebx
  800188:	54                   	push   %esp
  800189:	55                   	push   %ebp
  80018a:	56                   	push   %esi
  80018b:	57                   	push   %edi
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	8d 35 96 01 80 00    	lea    0x800196,%esi
  800194:	0f 34                	sysenter 
  800196:	5f                   	pop    %edi
  800197:	5e                   	pop    %esi
  800198:	5d                   	pop    %ebp
  800199:	5c                   	pop    %esp
  80019a:	5b                   	pop    %ebx
  80019b:	5a                   	pop    %edx
  80019c:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 28                	jle    8001c9 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8001c4:	e8 97 03 00 00       	call   800560 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001cf:	89 ec                	mov    %ebp,%esp
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	89 1c 24             	mov    %ebx,(%esp)
  8001dc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001e0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8001e5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	51                   	push   %ecx
  8001f2:	52                   	push   %edx
  8001f3:	53                   	push   %ebx
  8001f4:	54                   	push   %esp
  8001f5:	55                   	push   %ebp
  8001f6:	56                   	push   %esi
  8001f7:	57                   	push   %edi
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	8d 35 02 02 80 00    	lea    0x800202,%esi
  800200:	0f 34                	sysenter 
  800202:	5f                   	pop    %edi
  800203:	5e                   	pop    %esi
  800204:	5d                   	pop    %ebp
  800205:	5c                   	pop    %esp
  800206:	5b                   	pop    %ebx
  800207:	5a                   	pop    %edx
  800208:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800209:	8b 1c 24             	mov    (%esp),%ebx
  80020c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800210:	89 ec                	mov    %ebp,%esp
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 28             	sub    $0x28,%esp
  80021a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80021d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	b8 0a 00 00 00       	mov    $0xa,%eax
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	89 df                	mov    %ebx,%edi
  800232:	51                   	push   %ecx
  800233:	52                   	push   %edx
  800234:	53                   	push   %ebx
  800235:	54                   	push   %esp
  800236:	55                   	push   %ebp
  800237:	56                   	push   %esi
  800238:	57                   	push   %edi
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8d 35 43 02 80 00    	lea    0x800243,%esi
  800241:	0f 34                	sysenter 
  800243:	5f                   	pop    %edi
  800244:	5e                   	pop    %esi
  800245:	5d                   	pop    %ebp
  800246:	5c                   	pop    %esp
  800247:	5b                   	pop    %ebx
  800248:	5a                   	pop    %edx
  800249:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80024a:	85 c0                	test   %eax,%eax
  80024c:	7e 28                	jle    800276 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800252:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800259:	00 
  80025a:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800261:	00 
  800262:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800269:	00 
  80026a:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800271:	e8 ea 02 00 00       	call   800560 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800276:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800279:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80027c:	89 ec                	mov    %ebp,%esp
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 28             	sub    $0x28,%esp
  800286:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800289:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 09 00 00 00       	mov    $0x9,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	51                   	push   %ecx
  80029f:	52                   	push   %edx
  8002a0:	53                   	push   %ebx
  8002a1:	54                   	push   %esp
  8002a2:	55                   	push   %ebp
  8002a3:	56                   	push   %esi
  8002a4:	57                   	push   %edi
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	8d 35 af 02 80 00    	lea    0x8002af,%esi
  8002ad:	0f 34                	sysenter 
  8002af:	5f                   	pop    %edi
  8002b0:	5e                   	pop    %esi
  8002b1:	5d                   	pop    %ebp
  8002b2:	5c                   	pop    %esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5a                   	pop    %edx
  8002b5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 28                	jle    8002e2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002be:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8002dd:	e8 7e 02 00 00       	call   800560 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e8:	89 ec                	mov    %ebp,%esp
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 28             	sub    $0x28,%esp
  8002f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002f5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	b8 07 00 00 00       	mov    $0x7,%eax
  800302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	89 df                	mov    %ebx,%edi
  80030a:	51                   	push   %ecx
  80030b:	52                   	push   %edx
  80030c:	53                   	push   %ebx
  80030d:	54                   	push   %esp
  80030e:	55                   	push   %ebp
  80030f:	56                   	push   %esi
  800310:	57                   	push   %edi
  800311:	89 e5                	mov    %esp,%ebp
  800313:	8d 35 1b 03 80 00    	lea    0x80031b,%esi
  800319:	0f 34                	sysenter 
  80031b:	5f                   	pop    %edi
  80031c:	5e                   	pop    %esi
  80031d:	5d                   	pop    %ebp
  80031e:	5c                   	pop    %esp
  80031f:	5b                   	pop    %ebx
  800320:	5a                   	pop    %edx
  800321:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800322:	85 c0                	test   %eax,%eax
  800324:	7e 28                	jle    80034e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800326:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800331:	00 
  800332:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800339:	00 
  80033a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800341:	00 
  800342:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800349:	e8 12 02 00 00       	call   800560 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80034e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800351:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800354:	89 ec                	mov    %ebp,%esp
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 28             	sub    $0x28,%esp
  80035e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800361:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800364:	b8 06 00 00 00       	mov    $0x6,%eax
  800369:	8b 7d 14             	mov    0x14(%ebp),%edi
  80036c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800372:	8b 55 08             	mov    0x8(%ebp),%edx
  800375:	51                   	push   %ecx
  800376:	52                   	push   %edx
  800377:	53                   	push   %ebx
  800378:	54                   	push   %esp
  800379:	55                   	push   %ebp
  80037a:	56                   	push   %esi
  80037b:	57                   	push   %edi
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8d 35 86 03 80 00    	lea    0x800386,%esi
  800384:	0f 34                	sysenter 
  800386:	5f                   	pop    %edi
  800387:	5e                   	pop    %esi
  800388:	5d                   	pop    %ebp
  800389:	5c                   	pop    %esp
  80038a:	5b                   	pop    %ebx
  80038b:	5a                   	pop    %edx
  80038c:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80038d:	85 c0                	test   %eax,%eax
  80038f:	7e 28                	jle    8003b9 <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800391:	89 44 24 10          	mov    %eax,0x10(%esp)
  800395:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80039c:	00 
  80039d:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8003a4:	00 
  8003a5:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8003ac:	00 
  8003ad:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8003b4:	e8 a7 01 00 00       	call   800560 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8003b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003bf:	89 ec                	mov    %ebp,%esp
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	83 ec 28             	sub    $0x28,%esp
  8003c9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003cc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8003d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8003d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003df:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e2:	51                   	push   %ecx
  8003e3:	52                   	push   %edx
  8003e4:	53                   	push   %ebx
  8003e5:	54                   	push   %esp
  8003e6:	55                   	push   %ebp
  8003e7:	56                   	push   %esi
  8003e8:	57                   	push   %edi
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8d 35 f3 03 80 00    	lea    0x8003f3,%esi
  8003f1:	0f 34                	sysenter 
  8003f3:	5f                   	pop    %edi
  8003f4:	5e                   	pop    %esi
  8003f5:	5d                   	pop    %ebp
  8003f6:	5c                   	pop    %esp
  8003f7:	5b                   	pop    %ebx
  8003f8:	5a                   	pop    %edx
  8003f9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	7e 28                	jle    800426 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800402:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800409:	00 
  80040a:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800411:	00 
  800412:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800419:	00 
  80041a:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800421:	e8 3a 01 00 00       	call   800560 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800426:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800429:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80042c:	89 ec                	mov    %ebp,%esp
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	89 1c 24             	mov    %ebx,(%esp)
  800439:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	b8 0b 00 00 00       	mov    $0xb,%eax
  800447:	89 d1                	mov    %edx,%ecx
  800449:	89 d3                	mov    %edx,%ebx
  80044b:	89 d7                	mov    %edx,%edi
  80044d:	51                   	push   %ecx
  80044e:	52                   	push   %edx
  80044f:	53                   	push   %ebx
  800450:	54                   	push   %esp
  800451:	55                   	push   %ebp
  800452:	56                   	push   %esi
  800453:	57                   	push   %edi
  800454:	89 e5                	mov    %esp,%ebp
  800456:	8d 35 5e 04 80 00    	lea    0x80045e,%esi
  80045c:	0f 34                	sysenter 
  80045e:	5f                   	pop    %edi
  80045f:	5e                   	pop    %esi
  800460:	5d                   	pop    %ebp
  800461:	5c                   	pop    %esp
  800462:	5b                   	pop    %ebx
  800463:	5a                   	pop    %edx
  800464:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800465:	8b 1c 24             	mov    (%esp),%ebx
  800468:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80046c:	89 ec                	mov    %ebp,%esp
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	89 1c 24             	mov    %ebx,(%esp)
  800479:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80047d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800482:	b8 04 00 00 00       	mov    $0x4,%eax
  800487:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048a:	8b 55 08             	mov    0x8(%ebp),%edx
  80048d:	89 df                	mov    %ebx,%edi
  80048f:	51                   	push   %ecx
  800490:	52                   	push   %edx
  800491:	53                   	push   %ebx
  800492:	54                   	push   %esp
  800493:	55                   	push   %ebp
  800494:	56                   	push   %esi
  800495:	57                   	push   %edi
  800496:	89 e5                	mov    %esp,%ebp
  800498:	8d 35 a0 04 80 00    	lea    0x8004a0,%esi
  80049e:	0f 34                	sysenter 
  8004a0:	5f                   	pop    %edi
  8004a1:	5e                   	pop    %esi
  8004a2:	5d                   	pop    %ebp
  8004a3:	5c                   	pop    %esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5a                   	pop    %edx
  8004a6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8004a7:	8b 1c 24             	mov    (%esp),%ebx
  8004aa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004ae:	89 ec                	mov    %ebp,%esp
  8004b0:	5d                   	pop    %ebp
  8004b1:	c3                   	ret    

008004b2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	89 1c 24             	mov    %ebx,(%esp)
  8004bb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8004c9:	89 d1                	mov    %edx,%ecx
  8004cb:	89 d3                	mov    %edx,%ebx
  8004cd:	89 d7                	mov    %edx,%edi
  8004cf:	51                   	push   %ecx
  8004d0:	52                   	push   %edx
  8004d1:	53                   	push   %ebx
  8004d2:	54                   	push   %esp
  8004d3:	55                   	push   %ebp
  8004d4:	56                   	push   %esi
  8004d5:	57                   	push   %edi
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	8d 35 e0 04 80 00    	lea    0x8004e0,%esi
  8004de:	0f 34                	sysenter 
  8004e0:	5f                   	pop    %edi
  8004e1:	5e                   	pop    %esi
  8004e2:	5d                   	pop    %ebp
  8004e3:	5c                   	pop    %esp
  8004e4:	5b                   	pop    %ebx
  8004e5:	5a                   	pop    %edx
  8004e6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8004e7:	8b 1c 24             	mov    (%esp),%ebx
  8004ea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004ee:	89 ec                	mov    %ebp,%esp
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 28             	sub    $0x28,%esp
  8004f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004fb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800503:	b8 03 00 00 00       	mov    $0x3,%eax
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 cb                	mov    %ecx,%ebx
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	51                   	push   %ecx
  800510:	52                   	push   %edx
  800511:	53                   	push   %ebx
  800512:	54                   	push   %esp
  800513:	55                   	push   %ebp
  800514:	56                   	push   %esi
  800515:	57                   	push   %edi
  800516:	89 e5                	mov    %esp,%ebp
  800518:	8d 35 20 05 80 00    	lea    0x800520,%esi
  80051e:	0f 34                	sysenter 
  800520:	5f                   	pop    %edi
  800521:	5e                   	pop    %esi
  800522:	5d                   	pop    %ebp
  800523:	5c                   	pop    %esp
  800524:	5b                   	pop    %ebx
  800525:	5a                   	pop    %edx
  800526:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800527:	85 c0                	test   %eax,%eax
  800529:	7e 28                	jle    800553 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80052b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80052f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800536:	00 
  800537:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80053e:	00 
  80053f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800546:	00 
  800547:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80054e:	e8 0d 00 00 00       	call   800560 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800553:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800556:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800559:	89 ec                	mov    %ebp,%esp
  80055b:	5d                   	pop    %ebp
  80055c:	c3                   	ret    
  80055d:	00 00                	add    %al,(%eax)
	...

00800560 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800568:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80056b:	a1 08 20 80 00       	mov    0x802008,%eax
  800570:	85 c0                	test   %eax,%eax
  800572:	74 10                	je     800584 <_panic+0x24>
		cprintf("%s: ", argv0);
  800574:	89 44 24 04          	mov    %eax,0x4(%esp)
  800578:	c7 04 24 b5 13 80 00 	movl   $0x8013b5,(%esp)
  80057f:	e8 ad 00 00 00       	call   800631 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800584:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80058a:	e8 23 ff ff ff       	call   8004b2 <sys_getenvid>
  80058f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800592:	89 54 24 10          	mov    %edx,0x10(%esp)
  800596:	8b 55 08             	mov    0x8(%ebp),%edx
  800599:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a5:	c7 04 24 bc 13 80 00 	movl   $0x8013bc,(%esp)
  8005ac:	e8 80 00 00 00       	call   800631 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	e8 10 00 00 00       	call   8005d0 <vcprintf>
	cprintf("\n");
  8005c0:	c7 04 24 ba 13 80 00 	movl   $0x8013ba,(%esp)
  8005c7:	e8 65 00 00 00       	call   800631 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005cc:	cc                   	int3   
  8005cd:	eb fd                	jmp    8005cc <_panic+0x6c>
	...

008005d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005e0:	00 00 00 
	b.cnt = 0;
  8005e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800601:	89 44 24 04          	mov    %eax,0x4(%esp)
  800605:	c7 04 24 4b 06 80 00 	movl   $0x80064b,(%esp)
  80060c:	e8 cc 01 00 00       	call   8007dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800611:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 bf fa ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  800629:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80062f:	c9                   	leave  
  800630:	c3                   	ret    

00800631 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800637:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80063a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063e:	8b 45 08             	mov    0x8(%ebp),%eax
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	e8 87 ff ff ff       	call   8005d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800649:	c9                   	leave  
  80064a:	c3                   	ret    

0080064b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	53                   	push   %ebx
  80064f:	83 ec 14             	sub    $0x14,%esp
  800652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800655:	8b 03                	mov    (%ebx),%eax
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80065e:	83 c0 01             	add    $0x1,%eax
  800661:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800663:	3d ff 00 00 00       	cmp    $0xff,%eax
  800668:	75 19                	jne    800683 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80066a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800671:	00 
  800672:	8d 43 08             	lea    0x8(%ebx),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	e8 6b fa ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  80067d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800683:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800687:	83 c4 14             	add    $0x14,%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    
  80068d:	00 00                	add    %al,(%eax)
	...

00800690 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	57                   	push   %edi
  800694:	56                   	push   %esi
  800695:	53                   	push   %ebx
  800696:	83 ec 4c             	sub    $0x4c,%esp
  800699:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80069c:	89 d6                	mov    %edx,%esi
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	39 d1                	cmp    %edx,%ecx
  8006bd:	72 15                	jb     8006d4 <printnum+0x44>
  8006bf:	77 07                	ja     8006c8 <printnum+0x38>
  8006c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c4:	39 d0                	cmp    %edx,%eax
  8006c6:	76 0c                	jbe    8006d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	85 db                	test   %ebx,%ebx
  8006cd:	8d 76 00             	lea    0x0(%esi),%esi
  8006d0:	7f 61                	jg     800733 <printnum+0xa3>
  8006d2:	eb 70                	jmp    800744 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006d8:	83 eb 01             	sub    $0x1,%ebx
  8006db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8006e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8006eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8006f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006ff:	00 
  800700:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800703:	89 04 24             	mov    %eax,(%esp)
  800706:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800709:	89 54 24 04          	mov    %edx,0x4(%esp)
  80070d:	e8 ee 09 00 00       	call   801100 <__udivdi3>
  800712:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800715:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800718:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80071c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	89 54 24 04          	mov    %edx,0x4(%esp)
  800727:	89 f2                	mov    %esi,%edx
  800729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80072c:	e8 5f ff ff ff       	call   800690 <printnum>
  800731:	eb 11                	jmp    800744 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800733:	89 74 24 04          	mov    %esi,0x4(%esp)
  800737:	89 3c 24             	mov    %edi,(%esp)
  80073a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80073d:	83 eb 01             	sub    $0x1,%ebx
  800740:	85 db                	test   %ebx,%ebx
  800742:	7f ef                	jg     800733 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800744:	89 74 24 04          	mov    %esi,0x4(%esp)
  800748:	8b 74 24 04          	mov    0x4(%esp),%esi
  80074c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80074f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800753:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80075a:	00 
  80075b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075e:	89 14 24             	mov    %edx,(%esp)
  800761:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800764:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800768:	e8 c3 0a 00 00       	call   801230 <__umoddi3>
  80076d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800771:	0f be 80 e0 13 80 00 	movsbl 0x8013e0(%eax),%eax
  800778:	89 04 24             	mov    %eax,(%esp)
  80077b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80077e:	83 c4 4c             	add    $0x4c,%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800789:	83 fa 01             	cmp    $0x1,%edx
  80078c:	7e 0e                	jle    80079c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078e:	8b 10                	mov    (%eax),%edx
  800790:	8d 4a 08             	lea    0x8(%edx),%ecx
  800793:	89 08                	mov    %ecx,(%eax)
  800795:	8b 02                	mov    (%edx),%eax
  800797:	8b 52 04             	mov    0x4(%edx),%edx
  80079a:	eb 22                	jmp    8007be <getuint+0x38>
	else if (lflag)
  80079c:	85 d2                	test   %edx,%edx
  80079e:	74 10                	je     8007b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a5:	89 08                	mov    %ecx,(%eax)
  8007a7:	8b 02                	mov    (%edx),%eax
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ae:	eb 0e                	jmp    8007be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b5:	89 08                	mov    %ecx,(%eax)
  8007b7:	8b 02                	mov    (%edx),%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007ca:	8b 10                	mov    (%eax),%edx
  8007cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8007cf:	73 0a                	jae    8007db <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	88 0a                	mov    %cl,(%edx)
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	89 10                	mov    %edx,(%eax)
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	57                   	push   %edi
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	83 ec 5c             	sub    $0x5c,%esp
  8007e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8007f6:	eb 11                	jmp    800809 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007f8:	85 c0                	test   %eax,%eax
  8007fa:	0f 84 09 04 00 00    	je     800c09 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800800:	89 74 24 04          	mov    %esi,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800809:	0f b6 03             	movzbl (%ebx),%eax
  80080c:	83 c3 01             	add    $0x1,%ebx
  80080f:	83 f8 25             	cmp    $0x25,%eax
  800812:	75 e4                	jne    8007f8 <vprintfmt+0x1b>
  800814:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800818:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80081f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800826:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800832:	eb 06                	jmp    80083a <vprintfmt+0x5d>
  800834:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800838:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083a:	0f b6 13             	movzbl (%ebx),%edx
  80083d:	0f b6 c2             	movzbl %dl,%eax
  800840:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800843:	8d 43 01             	lea    0x1(%ebx),%eax
  800846:	83 ea 23             	sub    $0x23,%edx
  800849:	80 fa 55             	cmp    $0x55,%dl
  80084c:	0f 87 9a 03 00 00    	ja     800bec <vprintfmt+0x40f>
  800852:	0f b6 d2             	movzbl %dl,%edx
  800855:	ff 24 95 a0 14 80 00 	jmp    *0x8014a0(,%edx,4)
  80085c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800860:	eb d6                	jmp    800838 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800862:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800865:	83 ea 30             	sub    $0x30,%edx
  800868:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80086b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80086e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800871:	83 fb 09             	cmp    $0x9,%ebx
  800874:	77 4c                	ja     8008c2 <vprintfmt+0xe5>
  800876:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800879:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80087c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80087f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800882:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800886:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800889:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80088c:	83 fb 09             	cmp    $0x9,%ebx
  80088f:	76 eb                	jbe    80087c <vprintfmt+0x9f>
  800891:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800894:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800897:	eb 29                	jmp    8008c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800899:	8b 55 14             	mov    0x14(%ebp),%edx
  80089c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80089f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8008a2:	8b 12                	mov    (%edx),%edx
  8008a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8008a7:	eb 19                	jmp    8008c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8008a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ac:	c1 fa 1f             	sar    $0x1f,%edx
  8008af:	f7 d2                	not    %edx
  8008b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8008b4:	eb 82                	jmp    800838 <vprintfmt+0x5b>
  8008b6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8008bd:	e9 76 ff ff ff       	jmp    800838 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8008c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c6:	0f 89 6c ff ff ff    	jns    800838 <vprintfmt+0x5b>
  8008cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8008d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8008d8:	e9 5b ff ff ff       	jmp    800838 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8008e0:	e9 53 ff ff ff       	jmp    800838 <vprintfmt+0x5b>
  8008e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f5:	8b 00                	mov    (%eax),%eax
  8008f7:	89 04 24             	mov    %eax,(%esp)
  8008fa:	ff d7                	call   *%edi
  8008fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8008ff:	e9 05 ff ff ff       	jmp    800809 <vprintfmt+0x2c>
  800904:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 50 04             	lea    0x4(%eax),%edx
  80090d:	89 55 14             	mov    %edx,0x14(%ebp)
  800910:	8b 00                	mov    (%eax),%eax
  800912:	89 c2                	mov    %eax,%edx
  800914:	c1 fa 1f             	sar    $0x1f,%edx
  800917:	31 d0                	xor    %edx,%eax
  800919:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80091b:	83 f8 08             	cmp    $0x8,%eax
  80091e:	7f 0b                	jg     80092b <vprintfmt+0x14e>
  800920:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800927:	85 d2                	test   %edx,%edx
  800929:	75 20                	jne    80094b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80092b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092f:	c7 44 24 08 f1 13 80 	movl   $0x8013f1,0x8(%esp)
  800936:	00 
  800937:	89 74 24 04          	mov    %esi,0x4(%esp)
  80093b:	89 3c 24             	mov    %edi,(%esp)
  80093e:	e8 4e 03 00 00       	call   800c91 <printfmt>
  800943:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800946:	e9 be fe ff ff       	jmp    800809 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80094b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80094f:	c7 44 24 08 fa 13 80 	movl   $0x8013fa,0x8(%esp)
  800956:	00 
  800957:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095b:	89 3c 24             	mov    %edi,(%esp)
  80095e:	e8 2e 03 00 00       	call   800c91 <printfmt>
  800963:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800966:	e9 9e fe ff ff       	jmp    800809 <vprintfmt+0x2c>
  80096b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800973:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800976:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800979:	8b 45 14             	mov    0x14(%ebp),%eax
  80097c:	8d 50 04             	lea    0x4(%eax),%edx
  80097f:	89 55 14             	mov    %edx,0x14(%ebp)
  800982:	8b 00                	mov    (%eax),%eax
  800984:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800987:	85 c0                	test   %eax,%eax
  800989:	75 07                	jne    800992 <vprintfmt+0x1b5>
  80098b:	c7 45 c4 fd 13 80 00 	movl   $0x8013fd,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800992:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800996:	7e 06                	jle    80099e <vprintfmt+0x1c1>
  800998:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80099c:	75 13                	jne    8009b1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80099e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009a1:	0f be 02             	movsbl (%edx),%eax
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	0f 85 99 00 00 00    	jne    800a45 <vprintfmt+0x268>
  8009ac:	e9 86 00 00 00       	jmp    800a37 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009b5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8009b8:	89 0c 24             	mov    %ecx,(%esp)
  8009bb:	e8 1b 03 00 00       	call   800cdb <strnlen>
  8009c0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8009c3:	29 c2                	sub    %eax,%edx
  8009c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009c8:	85 d2                	test   %edx,%edx
  8009ca:	7e d2                	jle    80099e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8009cc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8009d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009d3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8009d6:	89 d3                	mov    %edx,%ebx
  8009d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e4:	83 eb 01             	sub    $0x1,%ebx
  8009e7:	85 db                	test   %ebx,%ebx
  8009e9:	7f ed                	jg     8009d8 <vprintfmt+0x1fb>
  8009eb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8009ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8009f5:	eb a7                	jmp    80099e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8009fb:	74 18                	je     800a15 <vprintfmt+0x238>
  8009fd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a00:	83 fa 5e             	cmp    $0x5e,%edx
  800a03:	76 10                	jbe    800a15 <vprintfmt+0x238>
					putch('?', putdat);
  800a05:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a09:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a10:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a13:	eb 0a                	jmp    800a1f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a19:	89 04 24             	mov    %eax,(%esp)
  800a1c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a23:	0f be 03             	movsbl (%ebx),%eax
  800a26:	85 c0                	test   %eax,%eax
  800a28:	74 05                	je     800a2f <vprintfmt+0x252>
  800a2a:	83 c3 01             	add    $0x1,%ebx
  800a2d:	eb 29                	jmp    800a58 <vprintfmt+0x27b>
  800a2f:	89 fe                	mov    %edi,%esi
  800a31:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a34:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a3b:	7f 2e                	jg     800a6b <vprintfmt+0x28e>
  800a3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a40:	e9 c4 fd ff ff       	jmp    800809 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a45:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800a4e:	89 f7                	mov    %esi,%edi
  800a50:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a53:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a56:	89 d3                	mov    %edx,%ebx
  800a58:	85 f6                	test   %esi,%esi
  800a5a:	78 9b                	js     8009f7 <vprintfmt+0x21a>
  800a5c:	83 ee 01             	sub    $0x1,%esi
  800a5f:	79 96                	jns    8009f7 <vprintfmt+0x21a>
  800a61:	89 fe                	mov    %edi,%esi
  800a63:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a66:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a69:	eb cc                	jmp    800a37 <vprintfmt+0x25a>
  800a6b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a6e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a75:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a7c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a7e:	83 eb 01             	sub    $0x1,%ebx
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	7f ec                	jg     800a71 <vprintfmt+0x294>
  800a85:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a88:	e9 7c fd ff ff       	jmp    800809 <vprintfmt+0x2c>
  800a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a90:	83 f9 01             	cmp    $0x1,%ecx
  800a93:	7e 16                	jle    800aab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8d 50 08             	lea    0x8(%eax),%edx
  800a9b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9e:	8b 10                	mov    (%eax),%edx
  800aa0:	8b 48 04             	mov    0x4(%eax),%ecx
  800aa3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800aa6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800aa9:	eb 32                	jmp    800add <vprintfmt+0x300>
	else if (lflag)
  800aab:	85 c9                	test   %ecx,%ecx
  800aad:	74 18                	je     800ac7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab2:	8d 50 04             	lea    0x4(%eax),%edx
  800ab5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab8:	8b 00                	mov    (%eax),%eax
  800aba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800abd:	89 c1                	mov    %eax,%ecx
  800abf:	c1 f9 1f             	sar    $0x1f,%ecx
  800ac2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ac5:	eb 16                	jmp    800add <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aca:	8d 50 04             	lea    0x4(%eax),%edx
  800acd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad0:	8b 00                	mov    (%eax),%eax
  800ad2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	c1 fa 1f             	sar    $0x1f,%edx
  800ada:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800add:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ae0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ae3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800ae8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800aec:	0f 89 b8 00 00 00    	jns    800baa <vprintfmt+0x3cd>
				putch('-', putdat);
  800af2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800afd:	ff d7                	call   *%edi
				num = -(long long) num;
  800aff:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b05:	f7 d9                	neg    %ecx
  800b07:	83 d3 00             	adc    $0x0,%ebx
  800b0a:	f7 db                	neg    %ebx
  800b0c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b11:	e9 94 00 00 00       	jmp    800baa <vprintfmt+0x3cd>
  800b16:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b19:	89 ca                	mov    %ecx,%edx
  800b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1e:	e8 63 fc ff ff       	call   800786 <getuint>
  800b23:	89 c1                	mov    %eax,%ecx
  800b25:	89 d3                	mov    %edx,%ebx
  800b27:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800b2c:	eb 7c                	jmp    800baa <vprintfmt+0x3cd>
  800b2e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b31:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b35:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b3c:	ff d7                	call   *%edi
			putch('X', putdat);
  800b3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b42:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b49:	ff d7                	call   *%edi
			putch('X', putdat);
  800b4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b4f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b56:	ff d7                	call   *%edi
  800b58:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800b5b:	e9 a9 fc ff ff       	jmp    800809 <vprintfmt+0x2c>
  800b60:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800b63:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b67:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b6e:	ff d7                	call   *%edi
			putch('x', putdat);
  800b70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b7b:	ff d7                	call   *%edi
			num = (unsigned long long)
  800b7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b80:	8d 50 04             	lea    0x4(%eax),%edx
  800b83:	89 55 14             	mov    %edx,0x14(%ebp)
  800b86:	8b 08                	mov    (%eax),%ecx
  800b88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b92:	eb 16                	jmp    800baa <vprintfmt+0x3cd>
  800b94:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b97:	89 ca                	mov    %ecx,%edx
  800b99:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9c:	e8 e5 fb ff ff       	call   800786 <getuint>
  800ba1:	89 c1                	mov    %eax,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800baa:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800bae:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bb5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbd:	89 0c 24             	mov    %ecx,(%esp)
  800bc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc4:	89 f2                	mov    %esi,%edx
  800bc6:	89 f8                	mov    %edi,%eax
  800bc8:	e8 c3 fa ff ff       	call   800690 <printnum>
  800bcd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800bd0:	e9 34 fc ff ff       	jmp    800809 <vprintfmt+0x2c>
  800bd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800bd8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bdb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bdf:	89 14 24             	mov    %edx,(%esp)
  800be2:	ff d7                	call   *%edi
  800be4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800be7:	e9 1d fc ff ff       	jmp    800809 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bec:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bf7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bf9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800bfc:	80 38 25             	cmpb   $0x25,(%eax)
  800bff:	0f 84 04 fc ff ff    	je     800809 <vprintfmt+0x2c>
  800c05:	89 c3                	mov    %eax,%ebx
  800c07:	eb f0                	jmp    800bf9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800c09:	83 c4 5c             	add    $0x5c,%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 28             	sub    $0x28,%esp
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	74 04                	je     800c25 <vsnprintf+0x14>
  800c21:	85 d2                	test   %edx,%edx
  800c23:	7f 07                	jg     800c2c <vsnprintf+0x1b>
  800c25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c2a:	eb 3b                	jmp    800c67 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c2f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c44:	8b 45 10             	mov    0x10(%ebp),%eax
  800c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	c7 04 24 c0 07 80 00 	movl   $0x8007c0,(%esp)
  800c59:	e8 7f fb ff ff       	call   8007dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c61:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c6f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800c72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c76:	8b 45 10             	mov    0x10(%ebp),%eax
  800c79:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	89 04 24             	mov    %eax,(%esp)
  800c8a:	e8 82 ff ff ff       	call   800c11 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800c97:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800c9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	89 04 24             	mov    %eax,(%esp)
  800cb2:	e8 26 fb ff ff       	call   8007dd <vprintfmt>
	va_end(ap);
}
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    
  800cb9:	00 00                	add    %al,(%eax)
  800cbb:	00 00                	add    %al,(%eax)
  800cbd:	00 00                	add    %al,(%eax)
	...

00800cc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccb:	80 3a 00             	cmpb   $0x0,(%edx)
  800cce:	74 09                	je     800cd9 <strlen+0x19>
		n++;
  800cd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cd7:	75 f7                	jne    800cd0 <strlen+0x10>
		n++;
	return n;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	53                   	push   %ebx
  800cdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce5:	85 c9                	test   %ecx,%ecx
  800ce7:	74 19                	je     800d02 <strnlen+0x27>
  800ce9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800cec:	74 14                	je     800d02 <strnlen+0x27>
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cf3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf6:	39 c8                	cmp    %ecx,%eax
  800cf8:	74 0d                	je     800d07 <strnlen+0x2c>
  800cfa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800cfe:	75 f3                	jne    800cf3 <strnlen+0x18>
  800d00:	eb 05                	jmp    800d07 <strnlen+0x2c>
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d07:	5b                   	pop    %ebx
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	53                   	push   %ebx
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d20:	83 c2 01             	add    $0x1,%edx
  800d23:	84 c9                	test   %cl,%cl
  800d25:	75 f2                	jne    800d19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d27:	5b                   	pop    %ebx
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 08             	sub    $0x8,%esp
  800d31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d34:	89 1c 24             	mov    %ebx,(%esp)
  800d37:	e8 84 ff ff ff       	call   800cc0 <strlen>
	strcpy(dst + len, src);
  800d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d46:	89 04 24             	mov    %eax,(%esp)
  800d49:	e8 bc ff ff ff       	call   800d0a <strcpy>
	return dst;
}
  800d4e:	89 d8                	mov    %ebx,%eax
  800d50:	83 c4 08             	add    $0x8,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d64:	85 f6                	test   %esi,%esi
  800d66:	74 18                	je     800d80 <strncpy+0x2a>
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d6d:	0f b6 1a             	movzbl (%edx),%ebx
  800d70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d73:	80 3a 01             	cmpb   $0x1,(%edx)
  800d76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d79:	83 c1 01             	add    $0x1,%ecx
  800d7c:	39 ce                	cmp    %ecx,%esi
  800d7e:	77 ed                	ja     800d6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	8b 75 08             	mov    0x8(%ebp),%esi
  800d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d92:	89 f0                	mov    %esi,%eax
  800d94:	85 c9                	test   %ecx,%ecx
  800d96:	74 27                	je     800dbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800d98:	83 e9 01             	sub    $0x1,%ecx
  800d9b:	74 1d                	je     800dba <strlcpy+0x36>
  800d9d:	0f b6 1a             	movzbl (%edx),%ebx
  800da0:	84 db                	test   %bl,%bl
  800da2:	74 16                	je     800dba <strlcpy+0x36>
			*dst++ = *src++;
  800da4:	88 18                	mov    %bl,(%eax)
  800da6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800da9:	83 e9 01             	sub    $0x1,%ecx
  800dac:	74 0e                	je     800dbc <strlcpy+0x38>
			*dst++ = *src++;
  800dae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800db1:	0f b6 1a             	movzbl (%edx),%ebx
  800db4:	84 db                	test   %bl,%bl
  800db6:	75 ec                	jne    800da4 <strlcpy+0x20>
  800db8:	eb 02                	jmp    800dbc <strlcpy+0x38>
  800dba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dbc:	c6 00 00             	movb   $0x0,(%eax)
  800dbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dce:	0f b6 01             	movzbl (%ecx),%eax
  800dd1:	84 c0                	test   %al,%al
  800dd3:	74 15                	je     800dea <strcmp+0x25>
  800dd5:	3a 02                	cmp    (%edx),%al
  800dd7:	75 11                	jne    800dea <strcmp+0x25>
		p++, q++;
  800dd9:	83 c1 01             	add    $0x1,%ecx
  800ddc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ddf:	0f b6 01             	movzbl (%ecx),%eax
  800de2:	84 c0                	test   %al,%al
  800de4:	74 04                	je     800dea <strcmp+0x25>
  800de6:	3a 02                	cmp    (%edx),%al
  800de8:	74 ef                	je     800dd9 <strcmp+0x14>
  800dea:	0f b6 c0             	movzbl %al,%eax
  800ded:	0f b6 12             	movzbl (%edx),%edx
  800df0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	53                   	push   %ebx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	74 23                	je     800e28 <strncmp+0x34>
  800e05:	0f b6 1a             	movzbl (%edx),%ebx
  800e08:	84 db                	test   %bl,%bl
  800e0a:	74 25                	je     800e31 <strncmp+0x3d>
  800e0c:	3a 19                	cmp    (%ecx),%bl
  800e0e:	75 21                	jne    800e31 <strncmp+0x3d>
  800e10:	83 e8 01             	sub    $0x1,%eax
  800e13:	74 13                	je     800e28 <strncmp+0x34>
		n--, p++, q++;
  800e15:	83 c2 01             	add    $0x1,%edx
  800e18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e1b:	0f b6 1a             	movzbl (%edx),%ebx
  800e1e:	84 db                	test   %bl,%bl
  800e20:	74 0f                	je     800e31 <strncmp+0x3d>
  800e22:	3a 19                	cmp    (%ecx),%bl
  800e24:	74 ea                	je     800e10 <strncmp+0x1c>
  800e26:	eb 09                	jmp    800e31 <strncmp+0x3d>
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5d                   	pop    %ebp
  800e2f:	90                   	nop
  800e30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e31:	0f b6 02             	movzbl (%edx),%eax
  800e34:	0f b6 11             	movzbl (%ecx),%edx
  800e37:	29 d0                	sub    %edx,%eax
  800e39:	eb f2                	jmp    800e2d <strncmp+0x39>

00800e3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e45:	0f b6 10             	movzbl (%eax),%edx
  800e48:	84 d2                	test   %dl,%dl
  800e4a:	74 18                	je     800e64 <strchr+0x29>
		if (*s == c)
  800e4c:	38 ca                	cmp    %cl,%dl
  800e4e:	75 0a                	jne    800e5a <strchr+0x1f>
  800e50:	eb 17                	jmp    800e69 <strchr+0x2e>
  800e52:	38 ca                	cmp    %cl,%dl
  800e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e58:	74 0f                	je     800e69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e5a:	83 c0 01             	add    $0x1,%eax
  800e5d:	0f b6 10             	movzbl (%eax),%edx
  800e60:	84 d2                	test   %dl,%dl
  800e62:	75 ee                	jne    800e52 <strchr+0x17>
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e75:	0f b6 10             	movzbl (%eax),%edx
  800e78:	84 d2                	test   %dl,%dl
  800e7a:	74 18                	je     800e94 <strfind+0x29>
		if (*s == c)
  800e7c:	38 ca                	cmp    %cl,%dl
  800e7e:	75 0a                	jne    800e8a <strfind+0x1f>
  800e80:	eb 12                	jmp    800e94 <strfind+0x29>
  800e82:	38 ca                	cmp    %cl,%dl
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	74 0a                	je     800e94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e8a:	83 c0 01             	add    $0x1,%eax
  800e8d:	0f b6 10             	movzbl (%eax),%edx
  800e90:	84 d2                	test   %dl,%dl
  800e92:	75 ee                	jne    800e82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	89 1c 24             	mov    %ebx,(%esp)
  800e9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ea7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb0:	85 c9                	test   %ecx,%ecx
  800eb2:	74 30                	je     800ee4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eba:	75 25                	jne    800ee1 <memset+0x4b>
  800ebc:	f6 c1 03             	test   $0x3,%cl
  800ebf:	75 20                	jne    800ee1 <memset+0x4b>
		c &= 0xFF;
  800ec1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ec4:	89 d3                	mov    %edx,%ebx
  800ec6:	c1 e3 08             	shl    $0x8,%ebx
  800ec9:	89 d6                	mov    %edx,%esi
  800ecb:	c1 e6 18             	shl    $0x18,%esi
  800ece:	89 d0                	mov    %edx,%eax
  800ed0:	c1 e0 10             	shl    $0x10,%eax
  800ed3:	09 f0                	or     %esi,%eax
  800ed5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ed7:	09 d8                	or     %ebx,%eax
  800ed9:	c1 e9 02             	shr    $0x2,%ecx
  800edc:	fc                   	cld    
  800edd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800edf:	eb 03                	jmp    800ee4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ee1:	fc                   	cld    
  800ee2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ee4:	89 f8                	mov    %edi,%eax
  800ee6:	8b 1c 24             	mov    (%esp),%ebx
  800ee9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 08             	sub    $0x8,%esp
  800efb:	89 34 24             	mov    %esi,(%esp)
  800efe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800f08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800f0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800f0d:	39 c6                	cmp    %eax,%esi
  800f0f:	73 35                	jae    800f46 <memmove+0x51>
  800f11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f14:	39 d0                	cmp    %edx,%eax
  800f16:	73 2e                	jae    800f46 <memmove+0x51>
		s += n;
		d += n;
  800f18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1a:	f6 c2 03             	test   $0x3,%dl
  800f1d:	75 1b                	jne    800f3a <memmove+0x45>
  800f1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f25:	75 13                	jne    800f3a <memmove+0x45>
  800f27:	f6 c1 03             	test   $0x3,%cl
  800f2a:	75 0e                	jne    800f3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800f2c:	83 ef 04             	sub    $0x4,%edi
  800f2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f32:	c1 e9 02             	shr    $0x2,%ecx
  800f35:	fd                   	std    
  800f36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f38:	eb 09                	jmp    800f43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f3a:	83 ef 01             	sub    $0x1,%edi
  800f3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f40:	fd                   	std    
  800f41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f44:	eb 20                	jmp    800f66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f4c:	75 15                	jne    800f63 <memmove+0x6e>
  800f4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f54:	75 0d                	jne    800f63 <memmove+0x6e>
  800f56:	f6 c1 03             	test   $0x3,%cl
  800f59:	75 08                	jne    800f63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800f5b:	c1 e9 02             	shr    $0x2,%ecx
  800f5e:	fc                   	cld    
  800f5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f61:	eb 03                	jmp    800f66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f63:	fc                   	cld    
  800f64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f66:	8b 34 24             	mov    (%esp),%esi
  800f69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f6d:	89 ec                	mov    %ebp,%esp
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f77:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
  800f88:	89 04 24             	mov    %eax,(%esp)
  800f8b:	e8 65 ff ff ff       	call   800ef5 <memmove>
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fa1:	85 c9                	test   %ecx,%ecx
  800fa3:	74 36                	je     800fdb <memcmp+0x49>
		if (*s1 != *s2)
  800fa5:	0f b6 06             	movzbl (%esi),%eax
  800fa8:	0f b6 1f             	movzbl (%edi),%ebx
  800fab:	38 d8                	cmp    %bl,%al
  800fad:	74 20                	je     800fcf <memcmp+0x3d>
  800faf:	eb 14                	jmp    800fc5 <memcmp+0x33>
  800fb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800fb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800fbb:	83 c2 01             	add    $0x1,%edx
  800fbe:	83 e9 01             	sub    $0x1,%ecx
  800fc1:	38 d8                	cmp    %bl,%al
  800fc3:	74 12                	je     800fd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800fc5:	0f b6 c0             	movzbl %al,%eax
  800fc8:	0f b6 db             	movzbl %bl,%ebx
  800fcb:	29 d8                	sub    %ebx,%eax
  800fcd:	eb 11                	jmp    800fe0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fcf:	83 e9 01             	sub    $0x1,%ecx
  800fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd7:	85 c9                	test   %ecx,%ecx
  800fd9:	75 d6                	jne    800fb1 <memcmp+0x1f>
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800feb:	89 c2                	mov    %eax,%edx
  800fed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ff0:	39 d0                	cmp    %edx,%eax
  800ff2:	73 15                	jae    801009 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ff4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ff8:	38 08                	cmp    %cl,(%eax)
  800ffa:	75 06                	jne    801002 <memfind+0x1d>
  800ffc:	eb 0b                	jmp    801009 <memfind+0x24>
  800ffe:	38 08                	cmp    %cl,(%eax)
  801000:	74 07                	je     801009 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801002:	83 c0 01             	add    $0x1,%eax
  801005:	39 c2                	cmp    %eax,%edx
  801007:	77 f5                	ja     800ffe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	8b 55 08             	mov    0x8(%ebp),%edx
  801017:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80101a:	0f b6 02             	movzbl (%edx),%eax
  80101d:	3c 20                	cmp    $0x20,%al
  80101f:	74 04                	je     801025 <strtol+0x1a>
  801021:	3c 09                	cmp    $0x9,%al
  801023:	75 0e                	jne    801033 <strtol+0x28>
		s++;
  801025:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801028:	0f b6 02             	movzbl (%edx),%eax
  80102b:	3c 20                	cmp    $0x20,%al
  80102d:	74 f6                	je     801025 <strtol+0x1a>
  80102f:	3c 09                	cmp    $0x9,%al
  801031:	74 f2                	je     801025 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801033:	3c 2b                	cmp    $0x2b,%al
  801035:	75 0c                	jne    801043 <strtol+0x38>
		s++;
  801037:	83 c2 01             	add    $0x1,%edx
  80103a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801041:	eb 15                	jmp    801058 <strtol+0x4d>
	else if (*s == '-')
  801043:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80104a:	3c 2d                	cmp    $0x2d,%al
  80104c:	75 0a                	jne    801058 <strtol+0x4d>
		s++, neg = 1;
  80104e:	83 c2 01             	add    $0x1,%edx
  801051:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801058:	85 db                	test   %ebx,%ebx
  80105a:	0f 94 c0             	sete   %al
  80105d:	74 05                	je     801064 <strtol+0x59>
  80105f:	83 fb 10             	cmp    $0x10,%ebx
  801062:	75 18                	jne    80107c <strtol+0x71>
  801064:	80 3a 30             	cmpb   $0x30,(%edx)
  801067:	75 13                	jne    80107c <strtol+0x71>
  801069:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	75 0a                	jne    80107c <strtol+0x71>
		s += 2, base = 16;
  801072:	83 c2 02             	add    $0x2,%edx
  801075:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80107a:	eb 15                	jmp    801091 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80107c:	84 c0                	test   %al,%al
  80107e:	66 90                	xchg   %ax,%ax
  801080:	74 0f                	je     801091 <strtol+0x86>
  801082:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801087:	80 3a 30             	cmpb   $0x30,(%edx)
  80108a:	75 05                	jne    801091 <strtol+0x86>
		s++, base = 8;
  80108c:	83 c2 01             	add    $0x1,%edx
  80108f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801091:	b8 00 00 00 00       	mov    $0x0,%eax
  801096:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801098:	0f b6 0a             	movzbl (%edx),%ecx
  80109b:	89 cf                	mov    %ecx,%edi
  80109d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8010a0:	80 fb 09             	cmp    $0x9,%bl
  8010a3:	77 08                	ja     8010ad <strtol+0xa2>
			dig = *s - '0';
  8010a5:	0f be c9             	movsbl %cl,%ecx
  8010a8:	83 e9 30             	sub    $0x30,%ecx
  8010ab:	eb 1e                	jmp    8010cb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8010ad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8010b0:	80 fb 19             	cmp    $0x19,%bl
  8010b3:	77 08                	ja     8010bd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8010b5:	0f be c9             	movsbl %cl,%ecx
  8010b8:	83 e9 57             	sub    $0x57,%ecx
  8010bb:	eb 0e                	jmp    8010cb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8010bd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8010c0:	80 fb 19             	cmp    $0x19,%bl
  8010c3:	77 15                	ja     8010da <strtol+0xcf>
			dig = *s - 'A' + 10;
  8010c5:	0f be c9             	movsbl %cl,%ecx
  8010c8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010cb:	39 f1                	cmp    %esi,%ecx
  8010cd:	7d 0b                	jge    8010da <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8010cf:	83 c2 01             	add    $0x1,%edx
  8010d2:	0f af c6             	imul   %esi,%eax
  8010d5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8010d8:	eb be                	jmp    801098 <strtol+0x8d>
  8010da:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8010dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010e0:	74 05                	je     8010e7 <strtol+0xdc>
		*endptr = (char *) s;
  8010e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010e5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8010eb:	74 04                	je     8010f1 <strtol+0xe6>
  8010ed:	89 c8                	mov    %ecx,%eax
  8010ef:	f7 d8                	neg    %eax
}
  8010f1:	83 c4 04             	add    $0x4,%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    
  8010f9:	00 00                	add    %al,(%eax)
  8010fb:	00 00                	add    %al,(%eax)
  8010fd:	00 00                	add    %al,(%eax)
	...

00801100 <__udivdi3>:
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	83 ec 10             	sub    $0x10,%esp
  801108:	8b 45 14             	mov    0x14(%ebp),%eax
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	8b 75 10             	mov    0x10(%ebp),%esi
  801111:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801114:	85 c0                	test   %eax,%eax
  801116:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801119:	75 35                	jne    801150 <__udivdi3+0x50>
  80111b:	39 fe                	cmp    %edi,%esi
  80111d:	77 61                	ja     801180 <__udivdi3+0x80>
  80111f:	85 f6                	test   %esi,%esi
  801121:	75 0b                	jne    80112e <__udivdi3+0x2e>
  801123:	b8 01 00 00 00       	mov    $0x1,%eax
  801128:	31 d2                	xor    %edx,%edx
  80112a:	f7 f6                	div    %esi
  80112c:	89 c6                	mov    %eax,%esi
  80112e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801131:	31 d2                	xor    %edx,%edx
  801133:	89 f8                	mov    %edi,%eax
  801135:	f7 f6                	div    %esi
  801137:	89 c7                	mov    %eax,%edi
  801139:	89 c8                	mov    %ecx,%eax
  80113b:	f7 f6                	div    %esi
  80113d:	89 c1                	mov    %eax,%ecx
  80113f:	89 fa                	mov    %edi,%edx
  801141:	89 c8                	mov    %ecx,%eax
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    
  80114a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801150:	39 f8                	cmp    %edi,%eax
  801152:	77 1c                	ja     801170 <__udivdi3+0x70>
  801154:	0f bd d0             	bsr    %eax,%edx
  801157:	83 f2 1f             	xor    $0x1f,%edx
  80115a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80115d:	75 39                	jne    801198 <__udivdi3+0x98>
  80115f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801162:	0f 86 a0 00 00 00    	jbe    801208 <__udivdi3+0x108>
  801168:	39 f8                	cmp    %edi,%eax
  80116a:	0f 82 98 00 00 00    	jb     801208 <__udivdi3+0x108>
  801170:	31 ff                	xor    %edi,%edi
  801172:	31 c9                	xor    %ecx,%ecx
  801174:	89 c8                	mov    %ecx,%eax
  801176:	89 fa                	mov    %edi,%edx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
  80117f:	90                   	nop
  801180:	89 d1                	mov    %edx,%ecx
  801182:	89 fa                	mov    %edi,%edx
  801184:	89 c8                	mov    %ecx,%eax
  801186:	31 ff                	xor    %edi,%edi
  801188:	f7 f6                	div    %esi
  80118a:	89 c1                	mov    %eax,%ecx
  80118c:	89 fa                	mov    %edi,%edx
  80118e:	89 c8                	mov    %ecx,%eax
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
  801197:	90                   	nop
  801198:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	d3 e0                	shl    %cl,%eax
  8011a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011ab:	89 c1                	mov    %eax,%ecx
  8011ad:	d3 ea                	shr    %cl,%edx
  8011af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011b6:	d3 e6                	shl    %cl,%esi
  8011b8:	89 c1                	mov    %eax,%ecx
  8011ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011bd:	89 fe                	mov    %edi,%esi
  8011bf:	d3 ee                	shr    %cl,%esi
  8011c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011cb:	d3 e7                	shl    %cl,%edi
  8011cd:	89 c1                	mov    %eax,%ecx
  8011cf:	d3 ea                	shr    %cl,%edx
  8011d1:	09 d7                	or     %edx,%edi
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	f7 75 ec             	divl   -0x14(%ebp)
  8011da:	89 d6                	mov    %edx,%esi
  8011dc:	89 c7                	mov    %eax,%edi
  8011de:	f7 65 e8             	mull   -0x18(%ebp)
  8011e1:	39 d6                	cmp    %edx,%esi
  8011e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011e6:	72 30                	jb     801218 <__udivdi3+0x118>
  8011e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ef:	d3 e2                	shl    %cl,%edx
  8011f1:	39 c2                	cmp    %eax,%edx
  8011f3:	73 05                	jae    8011fa <__udivdi3+0xfa>
  8011f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8011f8:	74 1e                	je     801218 <__udivdi3+0x118>
  8011fa:	89 f9                	mov    %edi,%ecx
  8011fc:	31 ff                	xor    %edi,%edi
  8011fe:	e9 71 ff ff ff       	jmp    801174 <__udivdi3+0x74>
  801203:	90                   	nop
  801204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801208:	31 ff                	xor    %edi,%edi
  80120a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80120f:	e9 60 ff ff ff       	jmp    801174 <__udivdi3+0x74>
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80121b:	31 ff                	xor    %edi,%edi
  80121d:	89 c8                	mov    %ecx,%eax
  80121f:	89 fa                	mov    %edi,%edx
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
	...

00801230 <__umoddi3>:
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	83 ec 20             	sub    $0x20,%esp
  801238:	8b 55 14             	mov    0x14(%ebp),%edx
  80123b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801241:	8b 75 0c             	mov    0xc(%ebp),%esi
  801244:	85 d2                	test   %edx,%edx
  801246:	89 c8                	mov    %ecx,%eax
  801248:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80124b:	75 13                	jne    801260 <__umoddi3+0x30>
  80124d:	39 f7                	cmp    %esi,%edi
  80124f:	76 3f                	jbe    801290 <__umoddi3+0x60>
  801251:	89 f2                	mov    %esi,%edx
  801253:	f7 f7                	div    %edi
  801255:	89 d0                	mov    %edx,%eax
  801257:	31 d2                	xor    %edx,%edx
  801259:	83 c4 20             	add    $0x20,%esp
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    
  801260:	39 f2                	cmp    %esi,%edx
  801262:	77 4c                	ja     8012b0 <__umoddi3+0x80>
  801264:	0f bd ca             	bsr    %edx,%ecx
  801267:	83 f1 1f             	xor    $0x1f,%ecx
  80126a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80126d:	75 51                	jne    8012c0 <__umoddi3+0x90>
  80126f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801272:	0f 87 e0 00 00 00    	ja     801358 <__umoddi3+0x128>
  801278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127b:	29 f8                	sub    %edi,%eax
  80127d:	19 d6                	sbb    %edx,%esi
  80127f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801285:	89 f2                	mov    %esi,%edx
  801287:	83 c4 20             	add    $0x20,%esp
  80128a:	5e                   	pop    %esi
  80128b:	5f                   	pop    %edi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    
  80128e:	66 90                	xchg   %ax,%ax
  801290:	85 ff                	test   %edi,%edi
  801292:	75 0b                	jne    80129f <__umoddi3+0x6f>
  801294:	b8 01 00 00 00       	mov    $0x1,%eax
  801299:	31 d2                	xor    %edx,%edx
  80129b:	f7 f7                	div    %edi
  80129d:	89 c7                	mov    %eax,%edi
  80129f:	89 f0                	mov    %esi,%eax
  8012a1:	31 d2                	xor    %edx,%edx
  8012a3:	f7 f7                	div    %edi
  8012a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a8:	f7 f7                	div    %edi
  8012aa:	eb a9                	jmp    801255 <__umoddi3+0x25>
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 c8                	mov    %ecx,%eax
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	83 c4 20             	add    $0x20,%esp
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    
  8012bb:	90                   	nop
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012c4:	d3 e2                	shl    %cl,%edx
  8012c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8012ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8012d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012d8:	89 fa                	mov    %edi,%edx
  8012da:	d3 ea                	shr    %cl,%edx
  8012dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8012e3:	d3 e7                	shl    %cl,%edi
  8012e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012ec:	89 f2                	mov    %esi,%edx
  8012ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8012f1:	89 c7                	mov    %eax,%edi
  8012f3:	d3 ea                	shr    %cl,%edx
  8012f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	d3 e6                	shl    %cl,%esi
  801300:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801304:	d3 ea                	shr    %cl,%edx
  801306:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80130a:	09 d6                	or     %edx,%esi
  80130c:	89 f0                	mov    %esi,%eax
  80130e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801311:	d3 e7                	shl    %cl,%edi
  801313:	89 f2                	mov    %esi,%edx
  801315:	f7 75 f4             	divl   -0xc(%ebp)
  801318:	89 d6                	mov    %edx,%esi
  80131a:	f7 65 e8             	mull   -0x18(%ebp)
  80131d:	39 d6                	cmp    %edx,%esi
  80131f:	72 2b                	jb     80134c <__umoddi3+0x11c>
  801321:	39 c7                	cmp    %eax,%edi
  801323:	72 23                	jb     801348 <__umoddi3+0x118>
  801325:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801329:	29 c7                	sub    %eax,%edi
  80132b:	19 d6                	sbb    %edx,%esi
  80132d:	89 f0                	mov    %esi,%eax
  80132f:	89 f2                	mov    %esi,%edx
  801331:	d3 ef                	shr    %cl,%edi
  801333:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801337:	d3 e0                	shl    %cl,%eax
  801339:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80133d:	09 f8                	or     %edi,%eax
  80133f:	d3 ea                	shr    %cl,%edx
  801341:	83 c4 20             	add    $0x20,%esp
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    
  801348:	39 d6                	cmp    %edx,%esi
  80134a:	75 d9                	jne    801325 <__umoddi3+0xf5>
  80134c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80134f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801352:	eb d1                	jmp    801325 <__umoddi3+0xf5>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	39 f2                	cmp    %esi,%edx
  80135a:	0f 82 18 ff ff ff    	jb     801278 <__umoddi3+0x48>
  801360:	e9 1d ff ff ff       	jmp    801282 <__umoddi3+0x52>
