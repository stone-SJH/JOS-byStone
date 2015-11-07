
obj/user/evilhello2:     file format elf32-i386


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
  80002c:	e8 0f 01 00 00       	call   800140 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <evil>:
#include <inc/x86.h>


// Call this function with ring0 privilege
void evil()
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800043:	b8 49 00 00 00       	mov    $0x49,%eax
  800048:	ee                   	out    %al,(%dx)
  800049:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004e:	ee                   	out    %al,(%dx)
  80004f:	b8 20 00 00 00       	mov    $0x20,%eax
  800054:	ee                   	out    %al,(%dx)
  800055:	b8 52 00 00 00       	mov    $0x52,%eax
  80005a:	ee                   	out    %al,(%dx)
  80005b:	b8 49 00 00 00       	mov    $0x49,%eax
  800060:	ee                   	out    %al,(%dx)
  800061:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800066:	ee                   	out    %al,(%dx)
  800067:	b8 47 00 00 00       	mov    $0x47,%eax
  80006c:	ee                   	out    %al,(%dx)
  80006d:	b8 30 00 00 00       	mov    $0x30,%eax
  800072:	ee                   	out    %al,(%dx)
  800073:	b8 21 00 00 00       	mov    $0x21,%eax
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	ee                   	out    %al,(%dx)
  80007b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800080:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <tevil>:
}
char va[PGSIZE];
struct Segdesc* entry;
struct Segdesc duplicate;// save the origin state of GDT entry
// Invoke a given function pointer with ring0 privilege, then return to ring3
void tevil(){
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
	evil();  
  800086:	e8 a9 ff ff ff       	call   800034 <evil>
	*entry = duplicate;  
  80008b:	8b 15 24 20 80 00    	mov    0x802024,%edx
  800091:	8b 0d 28 20 80 00    	mov    0x802028,%ecx
  800097:	a1 20 20 80 00       	mov    0x802020,%eax
  80009c:	89 10                	mov    %edx,(%eax)
  80009e:	89 48 04             	mov    %ecx,0x4(%eax)
	asm volatile("popl %ebp");
  8000a1:	5d                   	pop    %ebp
	asm volatile("lret");	
  8000a2:	cb                   	lret   
}
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <ring0_call>:
void ring0_call(void (*fun_ptr)(void)) {
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 28             	sub    $0x28,%esp
}

static void
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
  8000ab:	0f 01 45 f2          	sgdtl  -0xe(%ebp)
    // Lab3 : Your Code Here
	/*stone's solution for lab3-B*/
	struct Pseudodesc gdtd;
	struct Segdesc* gdt;
	sgdt(&gdtd);
	if(sys_map_kernel_page((void*)gdtd.pd_base, (void*)va) < 0)
  8000af:	c7 44 24 04 40 20 80 	movl   $0x802040,0x4(%esp)
  8000b6:	00 
  8000b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 aa 04 00 00       	call   80056c <sys_map_kernel_page>
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	78 5d                	js     800123 <ring0_call+0x7e>
		return;
	gdt = (struct Segdesc*)((uint32_t)(PGNUM(va) << PTXSHIFT) + (uint32_t)PGOFF(gdtd.pd_base));
	entry = gdt + (uint32_t)(GD_UD >> 3);
  8000c6:	ba 40 20 80 00       	mov    $0x802040,%edx
  8000cb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8000d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000d4:	25 ff 0f 00 00       	and    $0xfff,%eax
  8000d9:	8d 44 02 20          	lea    0x20(%edx,%eax,1),%eax
  8000dd:	a3 20 20 80 00       	mov    %eax,0x802020
	duplicate = *entry;
  8000e2:	8b 10                	mov    (%eax),%edx
  8000e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8000e7:	89 15 24 20 80 00    	mov    %edx,0x802024
  8000ed:	89 0d 28 20 80 00    	mov    %ecx,0x802028
	SETCALLGATE(*((struct Gatedesc*)entry), GD_KT, tevil, 3);
  8000f3:	b9 83 00 80 00       	mov    $0x800083,%ecx
  8000f8:	66 89 08             	mov    %cx,(%eax)
  8000fb:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  800101:	c6 40 04 00          	movb   $0x0,0x4(%eax)
  800105:	0f b6 50 05          	movzbl 0x5(%eax),%edx
  800109:	83 e2 e0             	and    $0xffffffe0,%edx
  80010c:	83 ca 0c             	or     $0xc,%edx
  80010f:	83 ca e0             	or     $0xffffffe0,%edx
  800112:	88 50 05             	mov    %dl,0x5(%eax)
  800115:	c1 e9 10             	shr    $0x10,%ecx
  800118:	66 89 48 06          	mov    %cx,0x6(%eax)
	asm volatile("lcall $0x20, $0");
  80011c:	9a 00 00 00 00 20 00 	lcall  $0x20,$0x0

}
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <umain>:

void
umain(int argc, char **argv)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp
        // call the evil function in ring0
	ring0_call(&evil);
  80012b:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800132:	e8 6e ff ff ff       	call   8000a5 <ring0_call>

	// call the evil function in ring3
	evil();
  800137:	e8 f8 fe ff ff       	call   800034 <evil>
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    
	...

00800140 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
  800146:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800149:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80014c:	8b 75 08             	mov    0x8(%ebp),%esi
  80014f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  800152:	e8 57 04 00 00       	call   8005ae <sys_getenvid>
  800157:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015c:	c1 e0 07             	shl    $0x7,%eax
  80015f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800164:	a3 40 30 80 00       	mov    %eax,0x803040
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800169:	85 f6                	test   %esi,%esi
  80016b:	7e 07                	jle    800174 <libmain+0x34>
		binaryname = argv[0];
  80016d:	8b 03                	mov    (%ebx),%eax
  80016f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 a5 ff ff ff       	call   800125 <umain>

	// exit gracefully
	exit();
  800180:	e8 0b 00 00 00       	call   800190 <exit>
}
  800185:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800188:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80018b:	89 ec                	mov    %ebp,%esp
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    
	...

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019d:	e8 4c 04 00 00       	call   8005ee <sys_env_destroy>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	89 1c 24             	mov    %ebx,(%esp)
  8001ad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8001bb:	89 d1                	mov    %edx,%ecx
  8001bd:	89 d3                	mov    %edx,%ebx
  8001bf:	89 d7                	mov    %edx,%edi
  8001c1:	51                   	push   %ecx
  8001c2:	52                   	push   %edx
  8001c3:	53                   	push   %ebx
  8001c4:	54                   	push   %esp
  8001c5:	55                   	push   %ebp
  8001c6:	56                   	push   %esi
  8001c7:	57                   	push   %edi
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	8d 35 d2 01 80 00    	lea    0x8001d2,%esi
  8001d0:	0f 34                	sysenter 
  8001d2:	5f                   	pop    %edi
  8001d3:	5e                   	pop    %esi
  8001d4:	5d                   	pop    %ebp
  8001d5:	5c                   	pop    %esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5a                   	pop    %edx
  8001d8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8001d9:	8b 1c 24             	mov    (%esp),%ebx
  8001dc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001e0:	89 ec                	mov    %ebp,%esp
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	89 1c 24             	mov    %ebx,(%esp)
  8001ed:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 c3                	mov    %eax,%ebx
  8001fe:	89 c7                	mov    %eax,%edi
  800200:	51                   	push   %ecx
  800201:	52                   	push   %edx
  800202:	53                   	push   %ebx
  800203:	54                   	push   %esp
  800204:	55                   	push   %ebp
  800205:	56                   	push   %esi
  800206:	57                   	push   %edi
  800207:	89 e5                	mov    %esp,%ebp
  800209:	8d 35 11 02 80 00    	lea    0x800211,%esi
  80020f:	0f 34                	sysenter 
  800211:	5f                   	pop    %edi
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	5c                   	pop    %esp
  800215:	5b                   	pop    %ebx
  800216:	5a                   	pop    %edx
  800217:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800218:	8b 1c 24             	mov    (%esp),%ebx
  80021b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021f:	89 ec                	mov    %ebp,%esp
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 08             	sub    $0x8,%esp
  800229:	89 1c 24             	mov    %ebx,(%esp)
  80022c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800230:	b9 00 00 00 00       	mov    $0x0,%ecx
  800235:	b8 0e 00 00 00       	mov    $0xe,%eax
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	89 cb                	mov    %ecx,%ebx
  80023f:	89 cf                	mov    %ecx,%edi
  800241:	51                   	push   %ecx
  800242:	52                   	push   %edx
  800243:	53                   	push   %ebx
  800244:	54                   	push   %esp
  800245:	55                   	push   %ebp
  800246:	56                   	push   %esi
  800247:	57                   	push   %edi
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	8d 35 52 02 80 00    	lea    0x800252,%esi
  800250:	0f 34                	sysenter 
  800252:	5f                   	pop    %edi
  800253:	5e                   	pop    %esi
  800254:	5d                   	pop    %ebp
  800255:	5c                   	pop    %esp
  800256:	5b                   	pop    %ebx
  800257:	5a                   	pop    %edx
  800258:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800259:	8b 1c 24             	mov    (%esp),%ebx
  80025c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800260:	89 ec                	mov    %ebp,%esp
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 28             	sub    $0x28,%esp
  80026a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80026d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800270:	b9 00 00 00 00       	mov    $0x0,%ecx
  800275:	b8 0d 00 00 00       	mov    $0xd,%eax
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 cb                	mov    %ecx,%ebx
  80027f:	89 cf                	mov    %ecx,%edi
  800281:	51                   	push   %ecx
  800282:	52                   	push   %edx
  800283:	53                   	push   %ebx
  800284:	54                   	push   %esp
  800285:	55                   	push   %ebp
  800286:	56                   	push   %esi
  800287:	57                   	push   %edi
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	8d 35 92 02 80 00    	lea    0x800292,%esi
  800290:	0f 34                	sysenter 
  800292:	5f                   	pop    %edi
  800293:	5e                   	pop    %esi
  800294:	5d                   	pop    %ebp
  800295:	5c                   	pop    %esp
  800296:	5b                   	pop    %ebx
  800297:	5a                   	pop    %edx
  800298:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800299:	85 c0                	test   %eax,%eax
  80029b:	7e 28                	jle    8002c5 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  8002b0:	00 
  8002b1:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002b8:	00 
  8002b9:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  8002c0:	e8 97 03 00 00       	call   80065c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002cb:	89 ec                	mov    %ebp,%esp
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	83 ec 08             	sub    $0x8,%esp
  8002d5:	89 1c 24             	mov    %ebx,(%esp)
  8002d8:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002dc:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	51                   	push   %ecx
  8002ee:	52                   	push   %edx
  8002ef:	53                   	push   %ebx
  8002f0:	54                   	push   %esp
  8002f1:	55                   	push   %ebp
  8002f2:	56                   	push   %esi
  8002f3:	57                   	push   %edi
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8d 35 fe 02 80 00    	lea    0x8002fe,%esi
  8002fc:	0f 34                	sysenter 
  8002fe:	5f                   	pop    %edi
  8002ff:	5e                   	pop    %esi
  800300:	5d                   	pop    %ebp
  800301:	5c                   	pop    %esp
  800302:	5b                   	pop    %ebx
  800303:	5a                   	pop    %edx
  800304:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	8b 1c 24             	mov    (%esp),%ebx
  800308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030c:	89 ec                	mov    %ebp,%esp
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 28             	sub    $0x28,%esp
  800316:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800319:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80031c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800321:	b8 0a 00 00 00       	mov    $0xa,%eax
  800326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 df                	mov    %ebx,%edi
  80032e:	51                   	push   %ecx
  80032f:	52                   	push   %edx
  800330:	53                   	push   %ebx
  800331:	54                   	push   %esp
  800332:	55                   	push   %ebp
  800333:	56                   	push   %esi
  800334:	57                   	push   %edi
  800335:	89 e5                	mov    %esp,%ebp
  800337:	8d 35 3f 03 80 00    	lea    0x80033f,%esi
  80033d:	0f 34                	sysenter 
  80033f:	5f                   	pop    %edi
  800340:	5e                   	pop    %esi
  800341:	5d                   	pop    %ebp
  800342:	5c                   	pop    %esp
  800343:	5b                   	pop    %ebx
  800344:	5a                   	pop    %edx
  800345:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 28                	jle    800372 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800355:	00 
  800356:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  80035d:	00 
  80035e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800365:	00 
  800366:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  80036d:	e8 ea 02 00 00       	call   80065c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800372:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800375:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800378:	89 ec                	mov    %ebp,%esp
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 28             	sub    $0x28,%esp
  800382:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800385:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800388:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038d:	b8 09 00 00 00       	mov    $0x9,%eax
  800392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	89 df                	mov    %ebx,%edi
  80039a:	51                   	push   %ecx
  80039b:	52                   	push   %edx
  80039c:	53                   	push   %ebx
  80039d:	54                   	push   %esp
  80039e:	55                   	push   %ebp
  80039f:	56                   	push   %esi
  8003a0:	57                   	push   %edi
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	8d 35 ab 03 80 00    	lea    0x8003ab,%esi
  8003a9:	0f 34                	sysenter 
  8003ab:	5f                   	pop    %edi
  8003ac:	5e                   	pop    %esi
  8003ad:	5d                   	pop    %ebp
  8003ae:	5c                   	pop    %esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5a                   	pop    %edx
  8003b1:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	7e 28                	jle    8003de <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ba:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003c1:	00 
  8003c2:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  8003c9:	00 
  8003ca:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8003d1:	00 
  8003d2:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  8003d9:	e8 7e 02 00 00       	call   80065c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8003de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003e4:	89 ec                	mov    %ebp,%esp
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 28             	sub    $0x28,%esp
  8003ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003f1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8003fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800401:	8b 55 08             	mov    0x8(%ebp),%edx
  800404:	89 df                	mov    %ebx,%edi
  800406:	51                   	push   %ecx
  800407:	52                   	push   %edx
  800408:	53                   	push   %ebx
  800409:	54                   	push   %esp
  80040a:	55                   	push   %ebp
  80040b:	56                   	push   %esi
  80040c:	57                   	push   %edi
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8d 35 17 04 80 00    	lea    0x800417,%esi
  800415:	0f 34                	sysenter 
  800417:	5f                   	pop    %edi
  800418:	5e                   	pop    %esi
  800419:	5d                   	pop    %ebp
  80041a:	5c                   	pop    %esp
  80041b:	5b                   	pop    %ebx
  80041c:	5a                   	pop    %edx
  80041d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80041e:	85 c0                	test   %eax,%eax
  800420:	7e 28                	jle    80044a <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800422:	89 44 24 10          	mov    %eax,0x10(%esp)
  800426:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80042d:	00 
  80042e:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  800435:	00 
  800436:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80043d:	00 
  80043e:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  800445:	e8 12 02 00 00       	call   80065c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80044a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80044d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800450:	89 ec                	mov    %ebp,%esp
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	83 ec 28             	sub    $0x28,%esp
  80045a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80045d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800460:	b8 06 00 00 00       	mov    $0x6,%eax
  800465:	8b 7d 14             	mov    0x14(%ebp),%edi
  800468:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80046b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046e:	8b 55 08             	mov    0x8(%ebp),%edx
  800471:	51                   	push   %ecx
  800472:	52                   	push   %edx
  800473:	53                   	push   %ebx
  800474:	54                   	push   %esp
  800475:	55                   	push   %ebp
  800476:	56                   	push   %esi
  800477:	57                   	push   %edi
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	8d 35 82 04 80 00    	lea    0x800482,%esi
  800480:	0f 34                	sysenter 
  800482:	5f                   	pop    %edi
  800483:	5e                   	pop    %esi
  800484:	5d                   	pop    %ebp
  800485:	5c                   	pop    %esp
  800486:	5b                   	pop    %ebx
  800487:	5a                   	pop    %edx
  800488:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800489:	85 c0                	test   %eax,%eax
  80048b:	7e 28                	jle    8004b5 <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80048d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800491:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800498:	00 
  800499:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  8004a0:	00 
  8004a1:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8004a8:	00 
  8004a9:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  8004b0:	e8 a7 01 00 00       	call   80065c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8004b5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004bb:	89 ec                	mov    %ebp,%esp
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 28             	sub    $0x28,%esp
  8004c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004c8:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8004d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8004d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004db:	8b 55 08             	mov    0x8(%ebp),%edx
  8004de:	51                   	push   %ecx
  8004df:	52                   	push   %edx
  8004e0:	53                   	push   %ebx
  8004e1:	54                   	push   %esp
  8004e2:	55                   	push   %ebp
  8004e3:	56                   	push   %esi
  8004e4:	57                   	push   %edi
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	8d 35 ef 04 80 00    	lea    0x8004ef,%esi
  8004ed:	0f 34                	sysenter 
  8004ef:	5f                   	pop    %edi
  8004f0:	5e                   	pop    %esi
  8004f1:	5d                   	pop    %ebp
  8004f2:	5c                   	pop    %esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5a                   	pop    %edx
  8004f5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	7e 28                	jle    800522 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004fe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800505:	00 
  800506:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  80050d:	00 
  80050e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800515:	00 
  800516:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  80051d:	e8 3a 01 00 00       	call   80065c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800522:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800525:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800528:	89 ec                	mov    %ebp,%esp
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	89 1c 24             	mov    %ebx,(%esp)
  800535:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
  80053e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800543:	89 d1                	mov    %edx,%ecx
  800545:	89 d3                	mov    %edx,%ebx
  800547:	89 d7                	mov    %edx,%edi
  800549:	51                   	push   %ecx
  80054a:	52                   	push   %edx
  80054b:	53                   	push   %ebx
  80054c:	54                   	push   %esp
  80054d:	55                   	push   %ebp
  80054e:	56                   	push   %esi
  80054f:	57                   	push   %edi
  800550:	89 e5                	mov    %esp,%ebp
  800552:	8d 35 5a 05 80 00    	lea    0x80055a,%esi
  800558:	0f 34                	sysenter 
  80055a:	5f                   	pop    %edi
  80055b:	5e                   	pop    %esi
  80055c:	5d                   	pop    %ebp
  80055d:	5c                   	pop    %esp
  80055e:	5b                   	pop    %ebx
  80055f:	5a                   	pop    %edx
  800560:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800561:	8b 1c 24             	mov    (%esp),%ebx
  800564:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800568:	89 ec                	mov    %ebp,%esp
  80056a:	5d                   	pop    %ebp
  80056b:	c3                   	ret    

0080056c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	89 1c 24             	mov    %ebx,(%esp)
  800575:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800579:	bb 00 00 00 00       	mov    $0x0,%ebx
  80057e:	b8 04 00 00 00       	mov    $0x4,%eax
  800583:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800586:	8b 55 08             	mov    0x8(%ebp),%edx
  800589:	89 df                	mov    %ebx,%edi
  80058b:	51                   	push   %ecx
  80058c:	52                   	push   %edx
  80058d:	53                   	push   %ebx
  80058e:	54                   	push   %esp
  80058f:	55                   	push   %ebp
  800590:	56                   	push   %esi
  800591:	57                   	push   %edi
  800592:	89 e5                	mov    %esp,%ebp
  800594:	8d 35 9c 05 80 00    	lea    0x80059c,%esi
  80059a:	0f 34                	sysenter 
  80059c:	5f                   	pop    %edi
  80059d:	5e                   	pop    %esi
  80059e:	5d                   	pop    %ebp
  80059f:	5c                   	pop    %esp
  8005a0:	5b                   	pop    %ebx
  8005a1:	5a                   	pop    %edx
  8005a2:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8005a3:	8b 1c 24             	mov    (%esp),%ebx
  8005a6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005aa:	89 ec                	mov    %ebp,%esp
  8005ac:	5d                   	pop    %ebp
  8005ad:	c3                   	ret    

008005ae <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	89 1c 24             	mov    %ebx,(%esp)
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8005c5:	89 d1                	mov    %edx,%ecx
  8005c7:	89 d3                	mov    %edx,%ebx
  8005c9:	89 d7                	mov    %edx,%edi
  8005cb:	51                   	push   %ecx
  8005cc:	52                   	push   %edx
  8005cd:	53                   	push   %ebx
  8005ce:	54                   	push   %esp
  8005cf:	55                   	push   %ebp
  8005d0:	56                   	push   %esi
  8005d1:	57                   	push   %edi
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	8d 35 dc 05 80 00    	lea    0x8005dc,%esi
  8005da:	0f 34                	sysenter 
  8005dc:	5f                   	pop    %edi
  8005dd:	5e                   	pop    %esi
  8005de:	5d                   	pop    %ebp
  8005df:	5c                   	pop    %esp
  8005e0:	5b                   	pop    %ebx
  8005e1:	5a                   	pop    %edx
  8005e2:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8005e3:	8b 1c 24             	mov    (%esp),%ebx
  8005e6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005ea:	89 ec                	mov    %ebp,%esp
  8005ec:	5d                   	pop    %ebp
  8005ed:	c3                   	ret    

008005ee <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8005ee:	55                   	push   %ebp
  8005ef:	89 e5                	mov    %esp,%ebp
  8005f1:	83 ec 28             	sub    $0x28,%esp
  8005f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005f7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800604:	8b 55 08             	mov    0x8(%ebp),%edx
  800607:	89 cb                	mov    %ecx,%ebx
  800609:	89 cf                	mov    %ecx,%edi
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	53                   	push   %ebx
  80060e:	54                   	push   %esp
  80060f:	55                   	push   %ebp
  800610:	56                   	push   %esi
  800611:	57                   	push   %edi
  800612:	89 e5                	mov    %esp,%ebp
  800614:	8d 35 1c 06 80 00    	lea    0x80061c,%esi
  80061a:	0f 34                	sysenter 
  80061c:	5f                   	pop    %edi
  80061d:	5e                   	pop    %esi
  80061e:	5d                   	pop    %ebp
  80061f:	5c                   	pop    %esp
  800620:	5b                   	pop    %ebx
  800621:	5a                   	pop    %edx
  800622:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800623:	85 c0                	test   %eax,%eax
  800625:	7e 28                	jle    80064f <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800627:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800632:	00 
  800633:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  80063a:	00 
  80063b:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800642:	00 
  800643:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  80064a:	e8 0d 00 00 00       	call   80065c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80064f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800652:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800655:	89 ec                	mov    %ebp,%esp
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    
  800659:	00 00                	add    %al,(%eax)
	...

0080065c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	56                   	push   %esi
  800660:	53                   	push   %ebx
  800661:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800664:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800667:	a1 44 30 80 00       	mov    0x803044,%eax
  80066c:	85 c0                	test   %eax,%eax
  80066e:	74 10                	je     800680 <_panic+0x24>
		cprintf("%s: ", argv0);
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 b5 14 80 00 	movl   $0x8014b5,(%esp)
  80067b:	e8 ad 00 00 00       	call   80072d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800680:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800686:	e8 23 ff ff ff       	call   8005ae <sys_getenvid>
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800692:	8b 55 08             	mov    0x8(%ebp),%edx
  800695:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	c7 04 24 bc 14 80 00 	movl   $0x8014bc,(%esp)
  8006a8:	e8 80 00 00 00       	call   80072d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b4:	89 04 24             	mov    %eax,(%esp)
  8006b7:	e8 10 00 00 00       	call   8006cc <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 ba 14 80 00 	movl   $0x8014ba,(%esp)
  8006c3:	e8 65 00 00 00       	call   80072d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006c8:	cc                   	int3   
  8006c9:	eb fd                	jmp    8006c8 <_panic+0x6c>
	...

008006cc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006dc:	00 00 00 
	b.cnt = 0;
  8006df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800701:	c7 04 24 47 07 80 00 	movl   $0x800747,(%esp)
  800708:	e8 d0 01 00 00       	call   8008dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80070d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80071d:	89 04 24             	mov    %eax,(%esp)
  800720:	e8 bf fa ff ff       	call   8001e4 <sys_cputs>

	return b.cnt;
}
  800725:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800733:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	89 04 24             	mov    %eax,(%esp)
  800740:	e8 87 ff ff ff       	call   8006cc <vcprintf>
	va_end(ap);

	return cnt;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	83 ec 14             	sub    $0x14,%esp
  80074e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800751:	8b 03                	mov    (%ebx),%eax
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
  800756:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80075a:	83 c0 01             	add    $0x1,%eax
  80075d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80075f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800764:	75 19                	jne    80077f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800766:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80076d:	00 
  80076e:	8d 43 08             	lea    0x8(%ebx),%eax
  800771:	89 04 24             	mov    %eax,(%esp)
  800774:	e8 6b fa ff ff       	call   8001e4 <sys_cputs>
		b->idx = 0;
  800779:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80077f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800783:	83 c4 14             	add    $0x14,%esp
  800786:	5b                   	pop    %ebx
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    
  800789:	00 00                	add    %al,(%eax)
  80078b:	00 00                	add    %al,(%eax)
  80078d:	00 00                	add    %al,(%eax)
	...

00800790 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	57                   	push   %edi
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	83 ec 4c             	sub    $0x4c,%esp
  800799:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079c:	89 d6                	mov    %edx,%esi
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bb:	39 d1                	cmp    %edx,%ecx
  8007bd:	72 15                	jb     8007d4 <printnum+0x44>
  8007bf:	77 07                	ja     8007c8 <printnum+0x38>
  8007c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c4:	39 d0                	cmp    %edx,%eax
  8007c6:	76 0c                	jbe    8007d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c8:	83 eb 01             	sub    $0x1,%ebx
  8007cb:	85 db                	test   %ebx,%ebx
  8007cd:	8d 76 00             	lea    0x0(%esi),%esi
  8007d0:	7f 61                	jg     800833 <printnum+0xa3>
  8007d2:	eb 70                	jmp    800844 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007d8:	83 eb 01             	sub    $0x1,%ebx
  8007db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8007e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8007eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8007ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8007f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007ff:	00 
  800800:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800809:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080d:	e8 ee 09 00 00       	call   801200 <__udivdi3>
  800812:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800815:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800818:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80081c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	89 54 24 04          	mov    %edx,0x4(%esp)
  800827:	89 f2                	mov    %esi,%edx
  800829:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80082c:	e8 5f ff ff ff       	call   800790 <printnum>
  800831:	eb 11                	jmp    800844 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800833:	89 74 24 04          	mov    %esi,0x4(%esp)
  800837:	89 3c 24             	mov    %edi,(%esp)
  80083a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80083d:	83 eb 01             	sub    $0x1,%ebx
  800840:	85 db                	test   %ebx,%ebx
  800842:	7f ef                	jg     800833 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800844:	89 74 24 04          	mov    %esi,0x4(%esp)
  800848:	8b 74 24 04          	mov    0x4(%esp),%esi
  80084c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80084f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800853:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80085a:	00 
  80085b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80085e:	89 14 24             	mov    %edx,(%esp)
  800861:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800864:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800868:	e8 c3 0a 00 00       	call   801330 <__umoddi3>
  80086d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800871:	0f be 80 e0 14 80 00 	movsbl 0x8014e0(%eax),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80087e:	83 c4 4c             	add    $0x4c,%esp
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800889:	83 fa 01             	cmp    $0x1,%edx
  80088c:	7e 0e                	jle    80089c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80088e:	8b 10                	mov    (%eax),%edx
  800890:	8d 4a 08             	lea    0x8(%edx),%ecx
  800893:	89 08                	mov    %ecx,(%eax)
  800895:	8b 02                	mov    (%edx),%eax
  800897:	8b 52 04             	mov    0x4(%edx),%edx
  80089a:	eb 22                	jmp    8008be <getuint+0x38>
	else if (lflag)
  80089c:	85 d2                	test   %edx,%edx
  80089e:	74 10                	je     8008b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008a5:	89 08                	mov    %ecx,(%eax)
  8008a7:	8b 02                	mov    (%edx),%eax
  8008a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ae:	eb 0e                	jmp    8008be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8008b0:	8b 10                	mov    (%eax),%edx
  8008b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008b5:	89 08                	mov    %ecx,(%eax)
  8008b7:	8b 02                	mov    (%edx),%eax
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8008c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8008ca:	8b 10                	mov    (%eax),%edx
  8008cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8008cf:	73 0a                	jae    8008db <sprintputch+0x1b>
		*b->buf++ = ch;
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	88 0a                	mov    %cl,(%edx)
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	89 10                	mov    %edx,(%eax)
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	83 ec 5c             	sub    $0x5c,%esp
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008f6:	eb 11                	jmp    800909 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	0f 84 09 04 00 00    	je     800d09 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  800900:	89 74 24 04          	mov    %esi,0x4(%esp)
  800904:	89 04 24             	mov    %eax,(%esp)
  800907:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800909:	0f b6 03             	movzbl (%ebx),%eax
  80090c:	83 c3 01             	add    $0x1,%ebx
  80090f:	83 f8 25             	cmp    $0x25,%eax
  800912:	75 e4                	jne    8008f8 <vprintfmt+0x1b>
  800914:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800918:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80091f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800926:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	eb 06                	jmp    80093a <vprintfmt+0x5d>
  800934:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800938:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093a:	0f b6 13             	movzbl (%ebx),%edx
  80093d:	0f b6 c2             	movzbl %dl,%eax
  800940:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800943:	8d 43 01             	lea    0x1(%ebx),%eax
  800946:	83 ea 23             	sub    $0x23,%edx
  800949:	80 fa 55             	cmp    $0x55,%dl
  80094c:	0f 87 9a 03 00 00    	ja     800cec <vprintfmt+0x40f>
  800952:	0f b6 d2             	movzbl %dl,%edx
  800955:	ff 24 95 a0 15 80 00 	jmp    *0x8015a0(,%edx,4)
  80095c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800960:	eb d6                	jmp    800938 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800962:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800965:	83 ea 30             	sub    $0x30,%edx
  800968:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80096b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80096e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800971:	83 fb 09             	cmp    $0x9,%ebx
  800974:	77 4c                	ja     8009c2 <vprintfmt+0xe5>
  800976:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800979:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80097c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80097f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800982:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800986:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800989:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80098c:	83 fb 09             	cmp    $0x9,%ebx
  80098f:	76 eb                	jbe    80097c <vprintfmt+0x9f>
  800991:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800994:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800997:	eb 29                	jmp    8009c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800999:	8b 55 14             	mov    0x14(%ebp),%edx
  80099c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80099f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8009a2:	8b 12                	mov    (%edx),%edx
  8009a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8009a7:	eb 19                	jmp    8009c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8009a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ac:	c1 fa 1f             	sar    $0x1f,%edx
  8009af:	f7 d2                	not    %edx
  8009b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8009b4:	eb 82                	jmp    800938 <vprintfmt+0x5b>
  8009b6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8009bd:	e9 76 ff ff ff       	jmp    800938 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8009c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009c6:	0f 89 6c ff ff ff    	jns    800938 <vprintfmt+0x5b>
  8009cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8009d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009d8:	e9 5b ff ff ff       	jmp    800938 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8009e0:	e9 53 ff ff ff       	jmp    800938 <vprintfmt+0x5b>
  8009e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8d 50 04             	lea    0x4(%eax),%edx
  8009ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f5:	8b 00                	mov    (%eax),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	ff d7                	call   *%edi
  8009fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8009ff:	e9 05 ff ff ff       	jmp    800909 <vprintfmt+0x2c>
  800a04:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a07:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0a:	8d 50 04             	lea    0x4(%eax),%edx
  800a0d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a10:	8b 00                	mov    (%eax),%eax
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	c1 fa 1f             	sar    $0x1f,%edx
  800a17:	31 d0                	xor    %edx,%eax
  800a19:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a1b:	83 f8 08             	cmp    $0x8,%eax
  800a1e:	7f 0b                	jg     800a2b <vprintfmt+0x14e>
  800a20:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  800a27:	85 d2                	test   %edx,%edx
  800a29:	75 20                	jne    800a4b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  800a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2f:	c7 44 24 08 f1 14 80 	movl   $0x8014f1,0x8(%esp)
  800a36:	00 
  800a37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3b:	89 3c 24             	mov    %edi,(%esp)
  800a3e:	e8 4e 03 00 00       	call   800d91 <printfmt>
  800a43:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a46:	e9 be fe ff ff       	jmp    800909 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800a4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a4f:	c7 44 24 08 fa 14 80 	movl   $0x8014fa,0x8(%esp)
  800a56:	00 
  800a57:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5b:	89 3c 24             	mov    %edi,(%esp)
  800a5e:	e8 2e 03 00 00       	call   800d91 <printfmt>
  800a63:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a66:	e9 9e fe ff ff       	jmp    800909 <vprintfmt+0x2c>
  800a6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a76:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a79:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7c:	8d 50 04             	lea    0x4(%eax),%edx
  800a7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a82:	8b 00                	mov    (%eax),%eax
  800a84:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	75 07                	jne    800a92 <vprintfmt+0x1b5>
  800a8b:	c7 45 c4 fd 14 80 00 	movl   $0x8014fd,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a92:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a96:	7e 06                	jle    800a9e <vprintfmt+0x1c1>
  800a98:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800a9c:	75 13                	jne    800ab1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a9e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800aa1:	0f be 02             	movsbl (%edx),%eax
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	0f 85 99 00 00 00    	jne    800b45 <vprintfmt+0x268>
  800aac:	e9 86 00 00 00       	jmp    800b37 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ab5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800ab8:	89 0c 24             	mov    %ecx,(%esp)
  800abb:	e8 1b 03 00 00       	call   800ddb <strnlen>
  800ac0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800ac3:	29 c2                	sub    %eax,%edx
  800ac5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ac8:	85 d2                	test   %edx,%edx
  800aca:	7e d2                	jle    800a9e <vprintfmt+0x1c1>
					putch(padc, putdat);
  800acc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800ad0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ad3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800adc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800adf:	89 04 24             	mov    %eax,(%esp)
  800ae2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ae4:	83 eb 01             	sub    $0x1,%ebx
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	7f ed                	jg     800ad8 <vprintfmt+0x1fb>
  800aeb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800aee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800af5:	eb a7                	jmp    800a9e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800af7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800afb:	74 18                	je     800b15 <vprintfmt+0x238>
  800afd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800b00:	83 fa 5e             	cmp    $0x5e,%edx
  800b03:	76 10                	jbe    800b15 <vprintfmt+0x238>
					putch('?', putdat);
  800b05:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b09:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b10:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b13:	eb 0a                	jmp    800b1f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800b15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b19:	89 04 24             	mov    %eax,(%esp)
  800b1c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b23:	0f be 03             	movsbl (%ebx),%eax
  800b26:	85 c0                	test   %eax,%eax
  800b28:	74 05                	je     800b2f <vprintfmt+0x252>
  800b2a:	83 c3 01             	add    $0x1,%ebx
  800b2d:	eb 29                	jmp    800b58 <vprintfmt+0x27b>
  800b2f:	89 fe                	mov    %edi,%esi
  800b31:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800b34:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b3b:	7f 2e                	jg     800b6b <vprintfmt+0x28e>
  800b3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b40:	e9 c4 fd ff ff       	jmp    800909 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b45:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800b4e:	89 f7                	mov    %esi,%edi
  800b50:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800b53:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	85 f6                	test   %esi,%esi
  800b5a:	78 9b                	js     800af7 <vprintfmt+0x21a>
  800b5c:	83 ee 01             	sub    $0x1,%esi
  800b5f:	79 96                	jns    800af7 <vprintfmt+0x21a>
  800b61:	89 fe                	mov    %edi,%esi
  800b63:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800b66:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800b69:	eb cc                	jmp    800b37 <vprintfmt+0x25a>
  800b6b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800b6e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b75:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b7c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b7e:	83 eb 01             	sub    $0x1,%ebx
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	7f ec                	jg     800b71 <vprintfmt+0x294>
  800b85:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b88:	e9 7c fd ff ff       	jmp    800909 <vprintfmt+0x2c>
  800b8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b90:	83 f9 01             	cmp    $0x1,%ecx
  800b93:	7e 16                	jle    800bab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800b95:	8b 45 14             	mov    0x14(%ebp),%eax
  800b98:	8d 50 08             	lea    0x8(%eax),%edx
  800b9b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b9e:	8b 10                	mov    (%eax),%edx
  800ba0:	8b 48 04             	mov    0x4(%eax),%ecx
  800ba3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800ba6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ba9:	eb 32                	jmp    800bdd <vprintfmt+0x300>
	else if (lflag)
  800bab:	85 c9                	test   %ecx,%ecx
  800bad:	74 18                	je     800bc7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800baf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb2:	8d 50 04             	lea    0x4(%eax),%edx
  800bb5:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb8:	8b 00                	mov    (%eax),%eax
  800bba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800bbd:	89 c1                	mov    %eax,%ecx
  800bbf:	c1 f9 1f             	sar    $0x1f,%ecx
  800bc2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800bc5:	eb 16                	jmp    800bdd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 50 04             	lea    0x4(%eax),%edx
  800bcd:	89 55 14             	mov    %edx,0x14(%ebp)
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800bd5:	89 c2                	mov    %eax,%edx
  800bd7:	c1 fa 1f             	sar    $0x1f,%edx
  800bda:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bdd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800be0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800be3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800be8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bec:	0f 89 b8 00 00 00    	jns    800caa <vprintfmt+0x3cd>
				putch('-', putdat);
  800bf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bfd:	ff d7                	call   *%edi
				num = -(long long) num;
  800bff:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800c02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800c05:	f7 d9                	neg    %ecx
  800c07:	83 d3 00             	adc    $0x0,%ebx
  800c0a:	f7 db                	neg    %ebx
  800c0c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c11:	e9 94 00 00 00       	jmp    800caa <vprintfmt+0x3cd>
  800c16:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c19:	89 ca                	mov    %ecx,%edx
  800c1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1e:	e8 63 fc ff ff       	call   800886 <getuint>
  800c23:	89 c1                	mov    %eax,%ecx
  800c25:	89 d3                	mov    %edx,%ebx
  800c27:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800c2c:	eb 7c                	jmp    800caa <vprintfmt+0x3cd>
  800c2e:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800c31:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c35:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800c3c:	ff d7                	call   *%edi
			putch('X', putdat);
  800c3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c42:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800c49:	ff d7                	call   *%edi
			putch('X', putdat);
  800c4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c4f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800c56:	ff d7                	call   *%edi
  800c58:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c5b:	e9 a9 fc ff ff       	jmp    800909 <vprintfmt+0x2c>
  800c60:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800c63:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c67:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c6e:	ff d7                	call   *%edi
			putch('x', putdat);
  800c70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c7b:	ff d7                	call   *%edi
			num = (unsigned long long)
  800c7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c80:	8d 50 04             	lea    0x4(%eax),%edx
  800c83:	89 55 14             	mov    %edx,0x14(%ebp)
  800c86:	8b 08                	mov    (%eax),%ecx
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c92:	eb 16                	jmp    800caa <vprintfmt+0x3cd>
  800c94:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c97:	89 ca                	mov    %ecx,%edx
  800c99:	8d 45 14             	lea    0x14(%ebp),%eax
  800c9c:	e8 e5 fb ff ff       	call   800886 <getuint>
  800ca1:	89 c1                	mov    %eax,%ecx
  800ca3:	89 d3                	mov    %edx,%ebx
  800ca5:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800caa:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800cae:	89 54 24 10          	mov    %edx,0x10(%esp)
  800cb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cb5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbd:	89 0c 24             	mov    %ecx,(%esp)
  800cc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc4:	89 f2                	mov    %esi,%edx
  800cc6:	89 f8                	mov    %edi,%eax
  800cc8:	e8 c3 fa ff ff       	call   800790 <printnum>
  800ccd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800cd0:	e9 34 fc ff ff       	jmp    800909 <vprintfmt+0x2c>
  800cd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800cd8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cdb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cdf:	89 14 24             	mov    %edx,(%esp)
  800ce2:	ff d7                	call   *%edi
  800ce4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800ce7:	e9 1d fc ff ff       	jmp    800909 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800cec:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800cf7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800cf9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfc:	80 38 25             	cmpb   $0x25,(%eax)
  800cff:	0f 84 04 fc ff ff    	je     800909 <vprintfmt+0x2c>
  800d05:	89 c3                	mov    %eax,%ebx
  800d07:	eb f0                	jmp    800cf9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800d09:	83 c4 5c             	add    $0x5c,%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 28             	sub    $0x28,%esp
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	74 04                	je     800d25 <vsnprintf+0x14>
  800d21:	85 d2                	test   %edx,%edx
  800d23:	7f 07                	jg     800d2c <vsnprintf+0x1b>
  800d25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d2a:	eb 3b                	jmp    800d67 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d2f:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800d33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d44:	8b 45 10             	mov    0x10(%ebp),%eax
  800d47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d52:	c7 04 24 c0 08 80 00 	movl   $0x8008c0,(%esp)
  800d59:	e8 7f fb ff ff       	call   8008dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d61:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d6f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d76:	8b 45 10             	mov    0x10(%ebp),%eax
  800d79:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	89 04 24             	mov    %eax,(%esp)
  800d8a:	e8 82 ff ff ff       	call   800d11 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d97:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800da1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	89 04 24             	mov    %eax,(%esp)
  800db2:	e8 26 fb ff ff       	call   8008dd <vprintfmt>
	va_end(ap);
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    
  800db9:	00 00                	add    %al,(%eax)
  800dbb:	00 00                	add    %al,(%eax)
  800dbd:	00 00                	add    %al,(%eax)
	...

00800dc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800dce:	74 09                	je     800dd9 <strlen+0x19>
		n++;
  800dd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dd7:	75 f7                	jne    800dd0 <strlen+0x10>
		n++;
	return n;
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de5:	85 c9                	test   %ecx,%ecx
  800de7:	74 19                	je     800e02 <strnlen+0x27>
  800de9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800dec:	74 14                	je     800e02 <strnlen+0x27>
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800df3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800df6:	39 c8                	cmp    %ecx,%eax
  800df8:	74 0d                	je     800e07 <strnlen+0x2c>
  800dfa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dfe:	75 f3                	jne    800df3 <strnlen+0x18>
  800e00:	eb 05                	jmp    800e07 <strnlen+0x2c>
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	84 c9                	test   %cl,%cl
  800e25:	75 f2                	jne    800e19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e34:	89 1c 24             	mov    %ebx,(%esp)
  800e37:	e8 84 ff ff ff       	call   800dc0 <strlen>
	strcpy(dst + len, src);
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800e46:	89 04 24             	mov    %eax,(%esp)
  800e49:	e8 bc ff ff ff       	call   800e0a <strcpy>
	return dst;
}
  800e4e:	89 d8                	mov    %ebx,%eax
  800e50:	83 c4 08             	add    $0x8,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e64:	85 f6                	test   %esi,%esi
  800e66:	74 18                	je     800e80 <strncpy+0x2a>
  800e68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e6d:	0f b6 1a             	movzbl (%edx),%ebx
  800e70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e73:	80 3a 01             	cmpb   $0x1,(%edx)
  800e76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e79:	83 c1 01             	add    $0x1,%ecx
  800e7c:	39 ce                	cmp    %ecx,%esi
  800e7e:	77 ed                	ja     800e6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e92:	89 f0                	mov    %esi,%eax
  800e94:	85 c9                	test   %ecx,%ecx
  800e96:	74 27                	je     800ebf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e98:	83 e9 01             	sub    $0x1,%ecx
  800e9b:	74 1d                	je     800eba <strlcpy+0x36>
  800e9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ea0:	84 db                	test   %bl,%bl
  800ea2:	74 16                	je     800eba <strlcpy+0x36>
			*dst++ = *src++;
  800ea4:	88 18                	mov    %bl,(%eax)
  800ea6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ea9:	83 e9 01             	sub    $0x1,%ecx
  800eac:	74 0e                	je     800ebc <strlcpy+0x38>
			*dst++ = *src++;
  800eae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800eb1:	0f b6 1a             	movzbl (%edx),%ebx
  800eb4:	84 db                	test   %bl,%bl
  800eb6:	75 ec                	jne    800ea4 <strlcpy+0x20>
  800eb8:	eb 02                	jmp    800ebc <strlcpy+0x38>
  800eba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ebc:	c6 00 00             	movb   $0x0,(%eax)
  800ebf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ece:	0f b6 01             	movzbl (%ecx),%eax
  800ed1:	84 c0                	test   %al,%al
  800ed3:	74 15                	je     800eea <strcmp+0x25>
  800ed5:	3a 02                	cmp    (%edx),%al
  800ed7:	75 11                	jne    800eea <strcmp+0x25>
		p++, q++;
  800ed9:	83 c1 01             	add    $0x1,%ecx
  800edc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800edf:	0f b6 01             	movzbl (%ecx),%eax
  800ee2:	84 c0                	test   %al,%al
  800ee4:	74 04                	je     800eea <strcmp+0x25>
  800ee6:	3a 02                	cmp    (%edx),%al
  800ee8:	74 ef                	je     800ed9 <strcmp+0x14>
  800eea:	0f b6 c0             	movzbl %al,%eax
  800eed:	0f b6 12             	movzbl (%edx),%edx
  800ef0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	53                   	push   %ebx
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	74 23                	je     800f28 <strncmp+0x34>
  800f05:	0f b6 1a             	movzbl (%edx),%ebx
  800f08:	84 db                	test   %bl,%bl
  800f0a:	74 25                	je     800f31 <strncmp+0x3d>
  800f0c:	3a 19                	cmp    (%ecx),%bl
  800f0e:	75 21                	jne    800f31 <strncmp+0x3d>
  800f10:	83 e8 01             	sub    $0x1,%eax
  800f13:	74 13                	je     800f28 <strncmp+0x34>
		n--, p++, q++;
  800f15:	83 c2 01             	add    $0x1,%edx
  800f18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f1b:	0f b6 1a             	movzbl (%edx),%ebx
  800f1e:	84 db                	test   %bl,%bl
  800f20:	74 0f                	je     800f31 <strncmp+0x3d>
  800f22:	3a 19                	cmp    (%ecx),%bl
  800f24:	74 ea                	je     800f10 <strncmp+0x1c>
  800f26:	eb 09                	jmp    800f31 <strncmp+0x3d>
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f2d:	5b                   	pop    %ebx
  800f2e:	5d                   	pop    %ebp
  800f2f:	90                   	nop
  800f30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f31:	0f b6 02             	movzbl (%edx),%eax
  800f34:	0f b6 11             	movzbl (%ecx),%edx
  800f37:	29 d0                	sub    %edx,%eax
  800f39:	eb f2                	jmp    800f2d <strncmp+0x39>

00800f3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f45:	0f b6 10             	movzbl (%eax),%edx
  800f48:	84 d2                	test   %dl,%dl
  800f4a:	74 18                	je     800f64 <strchr+0x29>
		if (*s == c)
  800f4c:	38 ca                	cmp    %cl,%dl
  800f4e:	75 0a                	jne    800f5a <strchr+0x1f>
  800f50:	eb 17                	jmp    800f69 <strchr+0x2e>
  800f52:	38 ca                	cmp    %cl,%dl
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	74 0f                	je     800f69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f5a:	83 c0 01             	add    $0x1,%eax
  800f5d:	0f b6 10             	movzbl (%eax),%edx
  800f60:	84 d2                	test   %dl,%dl
  800f62:	75 ee                	jne    800f52 <strchr+0x17>
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f75:	0f b6 10             	movzbl (%eax),%edx
  800f78:	84 d2                	test   %dl,%dl
  800f7a:	74 18                	je     800f94 <strfind+0x29>
		if (*s == c)
  800f7c:	38 ca                	cmp    %cl,%dl
  800f7e:	75 0a                	jne    800f8a <strfind+0x1f>
  800f80:	eb 12                	jmp    800f94 <strfind+0x29>
  800f82:	38 ca                	cmp    %cl,%dl
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	74 0a                	je     800f94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f8a:	83 c0 01             	add    $0x1,%eax
  800f8d:	0f b6 10             	movzbl (%eax),%edx
  800f90:	84 d2                	test   %dl,%dl
  800f92:	75 ee                	jne    800f82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	89 1c 24             	mov    %ebx,(%esp)
  800f9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	74 30                	je     800fe4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fba:	75 25                	jne    800fe1 <memset+0x4b>
  800fbc:	f6 c1 03             	test   $0x3,%cl
  800fbf:	75 20                	jne    800fe1 <memset+0x4b>
		c &= 0xFF;
  800fc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fc4:	89 d3                	mov    %edx,%ebx
  800fc6:	c1 e3 08             	shl    $0x8,%ebx
  800fc9:	89 d6                	mov    %edx,%esi
  800fcb:	c1 e6 18             	shl    $0x18,%esi
  800fce:	89 d0                	mov    %edx,%eax
  800fd0:	c1 e0 10             	shl    $0x10,%eax
  800fd3:	09 f0                	or     %esi,%eax
  800fd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800fd7:	09 d8                	or     %ebx,%eax
  800fd9:	c1 e9 02             	shr    $0x2,%ecx
  800fdc:	fc                   	cld    
  800fdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fdf:	eb 03                	jmp    800fe4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fe1:	fc                   	cld    
  800fe2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fe4:	89 f8                	mov    %edi,%eax
  800fe6:	8b 1c 24             	mov    (%esp),%ebx
  800fe9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ff1:	89 ec                	mov    %ebp,%esp
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	89 34 24             	mov    %esi,(%esp)
  800ffe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801008:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80100b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80100d:	39 c6                	cmp    %eax,%esi
  80100f:	73 35                	jae    801046 <memmove+0x51>
  801011:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801014:	39 d0                	cmp    %edx,%eax
  801016:	73 2e                	jae    801046 <memmove+0x51>
		s += n;
		d += n;
  801018:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80101a:	f6 c2 03             	test   $0x3,%dl
  80101d:	75 1b                	jne    80103a <memmove+0x45>
  80101f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801025:	75 13                	jne    80103a <memmove+0x45>
  801027:	f6 c1 03             	test   $0x3,%cl
  80102a:	75 0e                	jne    80103a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80102c:	83 ef 04             	sub    $0x4,%edi
  80102f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801032:	c1 e9 02             	shr    $0x2,%ecx
  801035:	fd                   	std    
  801036:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801038:	eb 09                	jmp    801043 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80103a:	83 ef 01             	sub    $0x1,%edi
  80103d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801040:	fd                   	std    
  801041:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801043:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801044:	eb 20                	jmp    801066 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801046:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80104c:	75 15                	jne    801063 <memmove+0x6e>
  80104e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801054:	75 0d                	jne    801063 <memmove+0x6e>
  801056:	f6 c1 03             	test   $0x3,%cl
  801059:	75 08                	jne    801063 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80105b:	c1 e9 02             	shr    $0x2,%ecx
  80105e:	fc                   	cld    
  80105f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801061:	eb 03                	jmp    801066 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801063:	fc                   	cld    
  801064:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801066:	8b 34 24             	mov    (%esp),%esi
  801069:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80106d:	89 ec                	mov    %ebp,%esp
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801077:	8b 45 10             	mov    0x10(%ebp),%eax
  80107a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80107e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801081:	89 44 24 04          	mov    %eax,0x4(%esp)
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
  801088:	89 04 24             	mov    %eax,(%esp)
  80108b:	e8 65 ff ff ff       	call   800ff5 <memmove>
}
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	8b 75 08             	mov    0x8(%ebp),%esi
  80109b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80109e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010a1:	85 c9                	test   %ecx,%ecx
  8010a3:	74 36                	je     8010db <memcmp+0x49>
		if (*s1 != *s2)
  8010a5:	0f b6 06             	movzbl (%esi),%eax
  8010a8:	0f b6 1f             	movzbl (%edi),%ebx
  8010ab:	38 d8                	cmp    %bl,%al
  8010ad:	74 20                	je     8010cf <memcmp+0x3d>
  8010af:	eb 14                	jmp    8010c5 <memcmp+0x33>
  8010b1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8010b6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8010bb:	83 c2 01             	add    $0x1,%edx
  8010be:	83 e9 01             	sub    $0x1,%ecx
  8010c1:	38 d8                	cmp    %bl,%al
  8010c3:	74 12                	je     8010d7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8010c5:	0f b6 c0             	movzbl %al,%eax
  8010c8:	0f b6 db             	movzbl %bl,%ebx
  8010cb:	29 d8                	sub    %ebx,%eax
  8010cd:	eb 11                	jmp    8010e0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010cf:	83 e9 01             	sub    $0x1,%ecx
  8010d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d7:	85 c9                	test   %ecx,%ecx
  8010d9:	75 d6                	jne    8010b1 <memcmp+0x1f>
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010f0:	39 d0                	cmp    %edx,%eax
  8010f2:	73 15                	jae    801109 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010f8:	38 08                	cmp    %cl,(%eax)
  8010fa:	75 06                	jne    801102 <memfind+0x1d>
  8010fc:	eb 0b                	jmp    801109 <memfind+0x24>
  8010fe:	38 08                	cmp    %cl,(%eax)
  801100:	74 07                	je     801109 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801102:	83 c0 01             	add    $0x1,%eax
  801105:	39 c2                	cmp    %eax,%edx
  801107:	77 f5                	ja     8010fe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80111a:	0f b6 02             	movzbl (%edx),%eax
  80111d:	3c 20                	cmp    $0x20,%al
  80111f:	74 04                	je     801125 <strtol+0x1a>
  801121:	3c 09                	cmp    $0x9,%al
  801123:	75 0e                	jne    801133 <strtol+0x28>
		s++;
  801125:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801128:	0f b6 02             	movzbl (%edx),%eax
  80112b:	3c 20                	cmp    $0x20,%al
  80112d:	74 f6                	je     801125 <strtol+0x1a>
  80112f:	3c 09                	cmp    $0x9,%al
  801131:	74 f2                	je     801125 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801133:	3c 2b                	cmp    $0x2b,%al
  801135:	75 0c                	jne    801143 <strtol+0x38>
		s++;
  801137:	83 c2 01             	add    $0x1,%edx
  80113a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801141:	eb 15                	jmp    801158 <strtol+0x4d>
	else if (*s == '-')
  801143:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80114a:	3c 2d                	cmp    $0x2d,%al
  80114c:	75 0a                	jne    801158 <strtol+0x4d>
		s++, neg = 1;
  80114e:	83 c2 01             	add    $0x1,%edx
  801151:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801158:	85 db                	test   %ebx,%ebx
  80115a:	0f 94 c0             	sete   %al
  80115d:	74 05                	je     801164 <strtol+0x59>
  80115f:	83 fb 10             	cmp    $0x10,%ebx
  801162:	75 18                	jne    80117c <strtol+0x71>
  801164:	80 3a 30             	cmpb   $0x30,(%edx)
  801167:	75 13                	jne    80117c <strtol+0x71>
  801169:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80116d:	8d 76 00             	lea    0x0(%esi),%esi
  801170:	75 0a                	jne    80117c <strtol+0x71>
		s += 2, base = 16;
  801172:	83 c2 02             	add    $0x2,%edx
  801175:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80117a:	eb 15                	jmp    801191 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80117c:	84 c0                	test   %al,%al
  80117e:	66 90                	xchg   %ax,%ax
  801180:	74 0f                	je     801191 <strtol+0x86>
  801182:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801187:	80 3a 30             	cmpb   $0x30,(%edx)
  80118a:	75 05                	jne    801191 <strtol+0x86>
		s++, base = 8;
  80118c:	83 c2 01             	add    $0x1,%edx
  80118f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801198:	0f b6 0a             	movzbl (%edx),%ecx
  80119b:	89 cf                	mov    %ecx,%edi
  80119d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8011a0:	80 fb 09             	cmp    $0x9,%bl
  8011a3:	77 08                	ja     8011ad <strtol+0xa2>
			dig = *s - '0';
  8011a5:	0f be c9             	movsbl %cl,%ecx
  8011a8:	83 e9 30             	sub    $0x30,%ecx
  8011ab:	eb 1e                	jmp    8011cb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8011ad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8011b0:	80 fb 19             	cmp    $0x19,%bl
  8011b3:	77 08                	ja     8011bd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8011b5:	0f be c9             	movsbl %cl,%ecx
  8011b8:	83 e9 57             	sub    $0x57,%ecx
  8011bb:	eb 0e                	jmp    8011cb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8011bd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8011c0:	80 fb 19             	cmp    $0x19,%bl
  8011c3:	77 15                	ja     8011da <strtol+0xcf>
			dig = *s - 'A' + 10;
  8011c5:	0f be c9             	movsbl %cl,%ecx
  8011c8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8011cb:	39 f1                	cmp    %esi,%ecx
  8011cd:	7d 0b                	jge    8011da <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8011cf:	83 c2 01             	add    $0x1,%edx
  8011d2:	0f af c6             	imul   %esi,%eax
  8011d5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8011d8:	eb be                	jmp    801198 <strtol+0x8d>
  8011da:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8011dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011e0:	74 05                	je     8011e7 <strtol+0xdc>
		*endptr = (char *) s;
  8011e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8011e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011eb:	74 04                	je     8011f1 <strtol+0xe6>
  8011ed:	89 c8                	mov    %ecx,%eax
  8011ef:	f7 d8                	neg    %eax
}
  8011f1:	83 c4 04             	add    $0x4,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    
  8011f9:	00 00                	add    %al,(%eax)
  8011fb:	00 00                	add    %al,(%eax)
  8011fd:	00 00                	add    %al,(%eax)
	...

00801200 <__udivdi3>:
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	83 ec 10             	sub    $0x10,%esp
  801208:	8b 45 14             	mov    0x14(%ebp),%eax
  80120b:	8b 55 08             	mov    0x8(%ebp),%edx
  80120e:	8b 75 10             	mov    0x10(%ebp),%esi
  801211:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801214:	85 c0                	test   %eax,%eax
  801216:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801219:	75 35                	jne    801250 <__udivdi3+0x50>
  80121b:	39 fe                	cmp    %edi,%esi
  80121d:	77 61                	ja     801280 <__udivdi3+0x80>
  80121f:	85 f6                	test   %esi,%esi
  801221:	75 0b                	jne    80122e <__udivdi3+0x2e>
  801223:	b8 01 00 00 00       	mov    $0x1,%eax
  801228:	31 d2                	xor    %edx,%edx
  80122a:	f7 f6                	div    %esi
  80122c:	89 c6                	mov    %eax,%esi
  80122e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801231:	31 d2                	xor    %edx,%edx
  801233:	89 f8                	mov    %edi,%eax
  801235:	f7 f6                	div    %esi
  801237:	89 c7                	mov    %eax,%edi
  801239:	89 c8                	mov    %ecx,%eax
  80123b:	f7 f6                	div    %esi
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	89 fa                	mov    %edi,%edx
  801241:	89 c8                	mov    %ecx,%eax
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    
  80124a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801250:	39 f8                	cmp    %edi,%eax
  801252:	77 1c                	ja     801270 <__udivdi3+0x70>
  801254:	0f bd d0             	bsr    %eax,%edx
  801257:	83 f2 1f             	xor    $0x1f,%edx
  80125a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80125d:	75 39                	jne    801298 <__udivdi3+0x98>
  80125f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801262:	0f 86 a0 00 00 00    	jbe    801308 <__udivdi3+0x108>
  801268:	39 f8                	cmp    %edi,%eax
  80126a:	0f 82 98 00 00 00    	jb     801308 <__udivdi3+0x108>
  801270:	31 ff                	xor    %edi,%edi
  801272:	31 c9                	xor    %ecx,%ecx
  801274:	89 c8                	mov    %ecx,%eax
  801276:	89 fa                	mov    %edi,%edx
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	5e                   	pop    %esi
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    
  80127f:	90                   	nop
  801280:	89 d1                	mov    %edx,%ecx
  801282:	89 fa                	mov    %edi,%edx
  801284:	89 c8                	mov    %ecx,%eax
  801286:	31 ff                	xor    %edi,%edi
  801288:	f7 f6                	div    %esi
  80128a:	89 c1                	mov    %eax,%ecx
  80128c:	89 fa                	mov    %edi,%edx
  80128e:	89 c8                	mov    %ecx,%eax
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	5e                   	pop    %esi
  801294:	5f                   	pop    %edi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    
  801297:	90                   	nop
  801298:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	d3 e0                	shl    %cl,%eax
  8012a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8012a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8012a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8012ab:	89 c1                	mov    %eax,%ecx
  8012ad:	d3 ea                	shr    %cl,%edx
  8012af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8012b6:	d3 e6                	shl    %cl,%esi
  8012b8:	89 c1                	mov    %eax,%ecx
  8012ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8012bd:	89 fe                	mov    %edi,%esi
  8012bf:	d3 ee                	shr    %cl,%esi
  8012c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012cb:	d3 e7                	shl    %cl,%edi
  8012cd:	89 c1                	mov    %eax,%ecx
  8012cf:	d3 ea                	shr    %cl,%edx
  8012d1:	09 d7                	or     %edx,%edi
  8012d3:	89 f2                	mov    %esi,%edx
  8012d5:	89 f8                	mov    %edi,%eax
  8012d7:	f7 75 ec             	divl   -0x14(%ebp)
  8012da:	89 d6                	mov    %edx,%esi
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	f7 65 e8             	mull   -0x18(%ebp)
  8012e1:	39 d6                	cmp    %edx,%esi
  8012e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012e6:	72 30                	jb     801318 <__udivdi3+0x118>
  8012e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012ef:	d3 e2                	shl    %cl,%edx
  8012f1:	39 c2                	cmp    %eax,%edx
  8012f3:	73 05                	jae    8012fa <__udivdi3+0xfa>
  8012f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8012f8:	74 1e                	je     801318 <__udivdi3+0x118>
  8012fa:	89 f9                	mov    %edi,%ecx
  8012fc:	31 ff                	xor    %edi,%edi
  8012fe:	e9 71 ff ff ff       	jmp    801274 <__udivdi3+0x74>
  801303:	90                   	nop
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	31 ff                	xor    %edi,%edi
  80130a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80130f:	e9 60 ff ff ff       	jmp    801274 <__udivdi3+0x74>
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80131b:	31 ff                	xor    %edi,%edi
  80131d:	89 c8                	mov    %ecx,%eax
  80131f:	89 fa                	mov    %edi,%edx
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	5e                   	pop    %esi
  801325:	5f                   	pop    %edi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    
	...

00801330 <__umoddi3>:
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	57                   	push   %edi
  801334:	56                   	push   %esi
  801335:	83 ec 20             	sub    $0x20,%esp
  801338:	8b 55 14             	mov    0x14(%ebp),%edx
  80133b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801341:	8b 75 0c             	mov    0xc(%ebp),%esi
  801344:	85 d2                	test   %edx,%edx
  801346:	89 c8                	mov    %ecx,%eax
  801348:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80134b:	75 13                	jne    801360 <__umoddi3+0x30>
  80134d:	39 f7                	cmp    %esi,%edi
  80134f:	76 3f                	jbe    801390 <__umoddi3+0x60>
  801351:	89 f2                	mov    %esi,%edx
  801353:	f7 f7                	div    %edi
  801355:	89 d0                	mov    %edx,%eax
  801357:	31 d2                	xor    %edx,%edx
  801359:	83 c4 20             	add    $0x20,%esp
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    
  801360:	39 f2                	cmp    %esi,%edx
  801362:	77 4c                	ja     8013b0 <__umoddi3+0x80>
  801364:	0f bd ca             	bsr    %edx,%ecx
  801367:	83 f1 1f             	xor    $0x1f,%ecx
  80136a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80136d:	75 51                	jne    8013c0 <__umoddi3+0x90>
  80136f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801372:	0f 87 e0 00 00 00    	ja     801458 <__umoddi3+0x128>
  801378:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137b:	29 f8                	sub    %edi,%eax
  80137d:	19 d6                	sbb    %edx,%esi
  80137f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801382:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801385:	89 f2                	mov    %esi,%edx
  801387:	83 c4 20             	add    $0x20,%esp
  80138a:	5e                   	pop    %esi
  80138b:	5f                   	pop    %edi
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    
  80138e:	66 90                	xchg   %ax,%ax
  801390:	85 ff                	test   %edi,%edi
  801392:	75 0b                	jne    80139f <__umoddi3+0x6f>
  801394:	b8 01 00 00 00       	mov    $0x1,%eax
  801399:	31 d2                	xor    %edx,%edx
  80139b:	f7 f7                	div    %edi
  80139d:	89 c7                	mov    %eax,%edi
  80139f:	89 f0                	mov    %esi,%eax
  8013a1:	31 d2                	xor    %edx,%edx
  8013a3:	f7 f7                	div    %edi
  8013a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a8:	f7 f7                	div    %edi
  8013aa:	eb a9                	jmp    801355 <__umoddi3+0x25>
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	89 c8                	mov    %ecx,%eax
  8013b2:	89 f2                	mov    %esi,%edx
  8013b4:	83 c4 20             	add    $0x20,%esp
  8013b7:	5e                   	pop    %esi
  8013b8:	5f                   	pop    %edi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    
  8013bb:	90                   	nop
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013c4:	d3 e2                	shl    %cl,%edx
  8013c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8013ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8013d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013d8:	89 fa                	mov    %edi,%edx
  8013da:	d3 ea                	shr    %cl,%edx
  8013dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8013e3:	d3 e7                	shl    %cl,%edi
  8013e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013ec:	89 f2                	mov    %esi,%edx
  8013ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8013f1:	89 c7                	mov    %eax,%edi
  8013f3:	d3 ea                	shr    %cl,%edx
  8013f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	d3 e6                	shl    %cl,%esi
  801400:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801404:	d3 ea                	shr    %cl,%edx
  801406:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80140a:	09 d6                	or     %edx,%esi
  80140c:	89 f0                	mov    %esi,%eax
  80140e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801411:	d3 e7                	shl    %cl,%edi
  801413:	89 f2                	mov    %esi,%edx
  801415:	f7 75 f4             	divl   -0xc(%ebp)
  801418:	89 d6                	mov    %edx,%esi
  80141a:	f7 65 e8             	mull   -0x18(%ebp)
  80141d:	39 d6                	cmp    %edx,%esi
  80141f:	72 2b                	jb     80144c <__umoddi3+0x11c>
  801421:	39 c7                	cmp    %eax,%edi
  801423:	72 23                	jb     801448 <__umoddi3+0x118>
  801425:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801429:	29 c7                	sub    %eax,%edi
  80142b:	19 d6                	sbb    %edx,%esi
  80142d:	89 f0                	mov    %esi,%eax
  80142f:	89 f2                	mov    %esi,%edx
  801431:	d3 ef                	shr    %cl,%edi
  801433:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801437:	d3 e0                	shl    %cl,%eax
  801439:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80143d:	09 f8                	or     %edi,%eax
  80143f:	d3 ea                	shr    %cl,%edx
  801441:	83 c4 20             	add    $0x20,%esp
  801444:	5e                   	pop    %esi
  801445:	5f                   	pop    %edi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    
  801448:	39 d6                	cmp    %edx,%esi
  80144a:	75 d9                	jne    801425 <__umoddi3+0xf5>
  80144c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80144f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801452:	eb d1                	jmp    801425 <__umoddi3+0xf5>
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	39 f2                	cmp    %esi,%edx
  80145a:	0f 82 18 ff ff ff    	jb     801378 <__umoddi3+0x48>
  801460:	e9 1d ff ff ff       	jmp    801382 <__umoddi3+0x52>
