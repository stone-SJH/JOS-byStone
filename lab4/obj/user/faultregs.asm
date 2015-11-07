
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 73 05 00 00       	call   8005a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800054:	89 54 24 08          	mov    %edx,0x8(%esp)
  800058:	c7 44 24 04 51 19 80 	movl   $0x801951,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800067:	e8 6d 06 00 00       	call   8006d9 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 30 19 80 	movl   $0x801930,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  800087:	e8 4d 06 00 00       	call   8006d9 <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800099:	e8 3b 06 00 00       	call   8006d9 <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8000ac:	e8 28 06 00 00       	call   8006d9 <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 52 19 80 	movl   $0x801952,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  8000d3:	e8 01 06 00 00       	call   8006d9 <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  8000e7:	e8 ed 05 00 00       	call   8006d9 <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8000f5:	e8 df 05 00 00       	call   8006d9 <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 56 19 80 	movl   $0x801956,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  80011c:	e8 b8 05 00 00       	call   8006d9 <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800130:	e8 a4 05 00 00       	call   8006d9 <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  80013e:	e8 96 05 00 00       	call   8006d9 <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 5a 19 80 	movl   $0x80195a,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  800165:	e8 6f 05 00 00       	call   8006d9 <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800179:	e8 5b 05 00 00       	call   8006d9 <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  800187:	e8 4d 05 00 00       	call   8006d9 <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 5e 19 80 	movl   $0x80195e,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  8001ae:	e8 26 05 00 00       	call   8006d9 <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  8001c2:	e8 12 05 00 00       	call   8006d9 <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8001d0:	e8 04 05 00 00       	call   8006d9 <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 62 19 80 	movl   $0x801962,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  8001f7:	e8 dd 04 00 00       	call   8006d9 <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  80020b:	e8 c9 04 00 00       	call   8006d9 <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  800219:	e8 bb 04 00 00       	call   8006d9 <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 66 19 80 	movl   $0x801966,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  800240:	e8 94 04 00 00       	call   8006d9 <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800254:	e8 80 04 00 00       	call   8006d9 <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  800262:	e8 72 04 00 00       	call   8006d9 <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 6a 19 80 	movl   $0x80196a,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  800289:	e8 4b 04 00 00       	call   8006d9 <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  80029d:	e8 37 04 00 00       	call   8006d9 <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8002ab:	e8 29 04 00 00       	call   8006d9 <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 6e 19 80 	movl   $0x80196e,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  8002d2:	e8 02 04 00 00       	call   8006d9 <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  8002e6:	e8 ee 03 00 00       	call   8006d9 <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8002f4:	e8 e0 03 00 00       	call   8006d9 <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 75 19 80 	movl   $0x801975,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 34 19 80 00 	movl   $0x801934,(%esp)
  80031b:	e8 b9 03 00 00       	call   8006d9 <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  80032f:	e8 a5 03 00 00       	call   8006d9 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 79 19 80 00 	movl   $0x801979,(%esp)
  800342:	e8 92 03 00 00       	call   8006d9 <cprintf>
	if (!mismatch)
  800347:	85 ff                	test   %edi,%edi
  800349:	74 23                	je     80036e <check_regs+0x32e>
  80034b:	eb 2f                	jmp    80037c <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80034d:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  800354:	e8 80 03 00 00       	call   8006d9 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 79 19 80 00 	movl   $0x801979,(%esp)
  800367:	e8 6d 03 00 00       	call   8006d9 <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800375:	e8 5f 03 00 00       	call   8006d9 <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  800383:	e8 51 03 00 00       	call   8006d9 <cprintf>
}
  800388:	83 c4 1c             	add    $0x1c,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <umain>:
		panic("sys_page_alloc: %e", r);
}

void
umain(int argc, char **argv)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800396:	c7 04 24 a1 04 80 00 	movl   $0x8004a1,(%esp)
  80039d:	e8 c2 12 00 00       	call   801664 <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 44 20 80 00       	mov    %eax,0x802044
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 40 20 80 00       	mov    %eax,0x802040
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8003c3:	89 35 24 20 80 00    	mov    %esi,0x802024
  8003c9:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8003cf:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8003d5:	89 15 34 20 80 00    	mov    %edx,0x802034
  8003db:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8003e1:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8003e6:	89 25 48 20 80 00    	mov    %esp,0x802048
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8003fc:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800402:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800408:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80040e:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800414:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80041a:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80041f:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800425:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  80042b:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800431:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  800437:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  80043d:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800443:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  800449:	a1 3c 20 80 00       	mov    0x80203c,%eax
  80044e:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 e0 19 80 00 	movl   $0x8019e0,(%esp)
  80046d:	e8 67 02 00 00       	call   8006d9 <cprintf>
	after.eip = before.eip;
  800472:	a1 40 20 80 00       	mov    0x802040,%eax
  800477:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 8e 19 80 	movl   $0x80198e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 9f 19 80 00 	movl   $0x80199f,(%esp)
  80048b:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800490:	ba 87 19 80 00       	mov    $0x801987,%edx
  800495:	b8 20 20 80 00       	mov    $0x802020,%eax
  80049a:	e8 a1 fb ff ff       	call   800040 <check_regs>
}
  80049f:	c9                   	leave  
  8004a0:	c3                   	ret    

008004a1 <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	83 ec 28             	sub    $0x28,%esp
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8004b2:	74 27                	je     8004db <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004b4:	8b 40 28             	mov    0x28(%eax),%eax
  8004b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 00 1a 80 	movl   $0x801a00,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  8004d6:	e8 2d 01 00 00       	call   800608 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 60 20 80 00    	mov    %edx,0x802060
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 70 20 80 00    	mov    %edx,0x802070
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 78 20 80 00    	mov    %edx,0x802078
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 b6 19 80 	movl   $0x8019b6,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 c4 19 80 00 	movl   $0x8019c4,(%esp)
  80054c:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800551:	ba 87 19 80 00       	mov    $0x801987,%edx
  800556:	b8 20 20 80 00       	mov    $0x802020,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 4b 0f 00 00       	call   8014c7 <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 cb 19 80 	movl   $0x8019cb,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 a5 19 80 00 	movl   $0x8019a5,(%esp)
  80059b:	e8 68 00 00 00       	call   800608 <_panic>
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    
	...

008005a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	83 ec 18             	sub    $0x18,%esp
  8005aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	//thisenv = 0;
	thisenv = envs + ENVX(sys_getenvid());
  8005b6:	e8 fb 0f 00 00       	call   8015b6 <sys_getenvid>
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	c1 e0 07             	shl    $0x7,%eax
  8005c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005c8:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	//cprintf("libmain:%08x\n", thisenv->env_id);	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005cd:	85 f6                	test   %esi,%esi
  8005cf:	7e 07                	jle    8005d8 <libmain+0x34>
		binaryname = argv[0];
  8005d1:	8b 03                	mov    (%ebx),%eax
  8005d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 34 24             	mov    %esi,(%esp)
  8005df:	e8 ac fd ff ff       	call   800390 <umain>

	// exit gracefully
	exit();
  8005e4:	e8 0b 00 00 00       	call   8005f4 <exit>
}
  8005e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005ec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005ef:	89 ec                	mov    %ebp,%esp
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
	...

008005f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800601:	e8 f0 0f 00 00       	call   8015f6 <sys_env_destroy>
}
  800606:	c9                   	leave  
  800607:	c3                   	ret    

00800608 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800610:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800613:	a1 d0 20 80 00       	mov    0x8020d0,%eax
  800618:	85 c0                	test   %eax,%eax
  80061a:	74 10                	je     80062c <_panic+0x24>
		cprintf("%s: ", argv0);
  80061c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800620:	c7 04 24 3b 1a 80 00 	movl   $0x801a3b,(%esp)
  800627:	e8 ad 00 00 00       	call   8006d9 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80062c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800632:	e8 7f 0f 00 00       	call   8015b6 <sys_getenvid>
  800637:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80063e:	8b 55 08             	mov    0x8(%ebp),%edx
  800641:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800645:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064d:	c7 04 24 40 1a 80 00 	movl   $0x801a40,(%esp)
  800654:	e8 80 00 00 00       	call   8006d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065d:	8b 45 10             	mov    0x10(%ebp),%eax
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	e8 10 00 00 00       	call   800678 <vcprintf>
	cprintf("\n");
  800668:	c7 04 24 50 19 80 00 	movl   $0x801950,(%esp)
  80066f:	e8 65 00 00 00       	call   8006d9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800674:	cc                   	int3   
  800675:	eb fd                	jmp    800674 <_panic+0x6c>
	...

00800678 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800681:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800688:	00 00 00 
	b.cnt = 0;
  80068b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800692:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800695:	8b 45 0c             	mov    0xc(%ebp),%eax
  800698:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	c7 04 24 f3 06 80 00 	movl   $0x8006f3,(%esp)
  8006b4:	e8 d4 01 00 00       	call   80088d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	e8 1b 0b 00 00       	call   8011ec <sys_cputs>

	return b.cnt;
}
  8006d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006df:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	89 04 24             	mov    %eax,(%esp)
  8006ec:	e8 87 ff ff ff       	call   800678 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	53                   	push   %ebx
  8006f7:	83 ec 14             	sub    $0x14,%esp
  8006fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006fd:	8b 03                	mov    (%ebx),%eax
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800702:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800706:	83 c0 01             	add    $0x1,%eax
  800709:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80070b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800710:	75 19                	jne    80072b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800712:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800719:	00 
  80071a:	8d 43 08             	lea    0x8(%ebx),%eax
  80071d:	89 04 24             	mov    %eax,(%esp)
  800720:	e8 c7 0a 00 00       	call   8011ec <sys_cputs>
		b->idx = 0;
  800725:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80072b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80072f:	83 c4 14             	add    $0x14,%esp
  800732:	5b                   	pop    %ebx
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    
	...

00800740 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	57                   	push   %edi
  800744:	56                   	push   %esi
  800745:	53                   	push   %ebx
  800746:	83 ec 4c             	sub    $0x4c,%esp
  800749:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074c:	89 d6                	mov    %edx,%esi
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
  800757:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80075a:	8b 45 10             	mov    0x10(%ebp),%eax
  80075d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800760:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800763:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076b:	39 d1                	cmp    %edx,%ecx
  80076d:	72 15                	jb     800784 <printnum+0x44>
  80076f:	77 07                	ja     800778 <printnum+0x38>
  800771:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800774:	39 d0                	cmp    %edx,%eax
  800776:	76 0c                	jbe    800784 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800778:	83 eb 01             	sub    $0x1,%ebx
  80077b:	85 db                	test   %ebx,%ebx
  80077d:	8d 76 00             	lea    0x0(%esi),%esi
  800780:	7f 61                	jg     8007e3 <printnum+0xa3>
  800782:	eb 70                	jmp    8007f4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800784:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800788:	83 eb 01             	sub    $0x1,%ebx
  80078b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80078f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800793:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800797:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80079b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80079e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8007a1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007af:	00 
  8007b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b3:	89 04 24             	mov    %eax,(%esp)
  8007b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bd:	e8 de 0e 00 00       	call   8016a0 <__udivdi3>
  8007c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d7:	89 f2                	mov    %esi,%edx
  8007d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007dc:	e8 5f ff ff ff       	call   800740 <printnum>
  8007e1:	eb 11                	jmp    8007f4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e7:	89 3c 24             	mov    %edi,(%esp)
  8007ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f ef                	jg     8007e3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800803:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80080a:	00 
  80080b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080e:	89 14 24             	mov    %edx,(%esp)
  800811:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800814:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800818:	e8 b3 0f 00 00       	call   8017d0 <__umoddi3>
  80081d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800821:	0f be 80 63 1a 80 00 	movsbl 0x801a63(%eax),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80082e:	83 c4 4c             	add    $0x4c,%esp
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5f                   	pop    %edi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800839:	83 fa 01             	cmp    $0x1,%edx
  80083c:	7e 0e                	jle    80084c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 08             	lea    0x8(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	8b 52 04             	mov    0x4(%edx),%edx
  80084a:	eb 22                	jmp    80086e <getuint+0x38>
	else if (lflag)
  80084c:	85 d2                	test   %edx,%edx
  80084e:	74 10                	je     800860 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800850:	8b 10                	mov    (%eax),%edx
  800852:	8d 4a 04             	lea    0x4(%edx),%ecx
  800855:	89 08                	mov    %ecx,(%eax)
  800857:	8b 02                	mov    (%edx),%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
  80085e:	eb 0e                	jmp    80086e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800860:	8b 10                	mov    (%eax),%edx
  800862:	8d 4a 04             	lea    0x4(%edx),%ecx
  800865:	89 08                	mov    %ecx,(%eax)
  800867:	8b 02                	mov    (%edx),%eax
  800869:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800876:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80087a:	8b 10                	mov    (%eax),%edx
  80087c:	3b 50 04             	cmp    0x4(%eax),%edx
  80087f:	73 0a                	jae    80088b <sprintputch+0x1b>
		*b->buf++ = ch;
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	88 0a                	mov    %cl,(%edx)
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	89 10                	mov    %edx,(%eax)
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	57                   	push   %edi
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	83 ec 5c             	sub    $0x5c,%esp
  800896:	8b 7d 08             	mov    0x8(%ebp),%edi
  800899:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80089f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008a6:	eb 11                	jmp    8008b9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	0f 84 09 04 00 00    	je     800cb9 <vprintfmt+0x42c>
				return;
			putch(ch, putdat);
  8008b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b9:	0f b6 03             	movzbl (%ebx),%eax
  8008bc:	83 c3 01             	add    $0x1,%ebx
  8008bf:	83 f8 25             	cmp    $0x25,%eax
  8008c2:	75 e4                	jne    8008a8 <vprintfmt+0x1b>
  8008c4:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8008c8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008cf:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e2:	eb 06                	jmp    8008ea <vprintfmt+0x5d>
  8008e4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8008e8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	0f b6 13             	movzbl (%ebx),%edx
  8008ed:	0f b6 c2             	movzbl %dl,%eax
  8008f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f3:	8d 43 01             	lea    0x1(%ebx),%eax
  8008f6:	83 ea 23             	sub    $0x23,%edx
  8008f9:	80 fa 55             	cmp    $0x55,%dl
  8008fc:	0f 87 9a 03 00 00    	ja     800c9c <vprintfmt+0x40f>
  800902:	0f b6 d2             	movzbl %dl,%edx
  800905:	ff 24 95 20 1b 80 00 	jmp    *0x801b20(,%edx,4)
  80090c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800910:	eb d6                	jmp    8008e8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800912:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800915:	83 ea 30             	sub    $0x30,%edx
  800918:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80091b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80091e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800921:	83 fb 09             	cmp    $0x9,%ebx
  800924:	77 4c                	ja     800972 <vprintfmt+0xe5>
  800926:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800929:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80092c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80092f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800932:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800936:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800939:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80093c:	83 fb 09             	cmp    $0x9,%ebx
  80093f:	76 eb                	jbe    80092c <vprintfmt+0x9f>
  800941:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800944:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800947:	eb 29                	jmp    800972 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800949:	8b 55 14             	mov    0x14(%ebp),%edx
  80094c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80094f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800952:	8b 12                	mov    (%edx),%edx
  800954:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800957:	eb 19                	jmp    800972 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800959:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80095c:	c1 fa 1f             	sar    $0x1f,%edx
  80095f:	f7 d2                	not    %edx
  800961:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800964:	eb 82                	jmp    8008e8 <vprintfmt+0x5b>
  800966:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80096d:	e9 76 ff ff ff       	jmp    8008e8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800972:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800976:	0f 89 6c ff ff ff    	jns    8008e8 <vprintfmt+0x5b>
  80097c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80097f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800982:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800985:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800988:	e9 5b ff ff ff       	jmp    8008e8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80098d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800990:	e9 53 ff ff ff       	jmp    8008e8 <vprintfmt+0x5b>
  800995:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800998:	8b 45 14             	mov    0x14(%ebp),%eax
  80099b:	8d 50 04             	lea    0x4(%eax),%edx
  80099e:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a5:	8b 00                	mov    (%eax),%eax
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	ff d7                	call   *%edi
  8009ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8009af:	e9 05 ff ff ff       	jmp    8008b9 <vprintfmt+0x2c>
  8009b4:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ba:	8d 50 04             	lea    0x4(%eax),%edx
  8009bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c0:	8b 00                	mov    (%eax),%eax
  8009c2:	89 c2                	mov    %eax,%edx
  8009c4:	c1 fa 1f             	sar    $0x1f,%edx
  8009c7:	31 d0                	xor    %edx,%eax
  8009c9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009cb:	83 f8 08             	cmp    $0x8,%eax
  8009ce:	7f 0b                	jg     8009db <vprintfmt+0x14e>
  8009d0:	8b 14 85 80 1c 80 00 	mov    0x801c80(,%eax,4),%edx
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	75 20                	jne    8009fb <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  8009db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009df:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  8009e6:	00 
  8009e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009eb:	89 3c 24             	mov    %edi,(%esp)
  8009ee:	e8 4e 03 00 00       	call   800d41 <printfmt>
  8009f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009f6:	e9 be fe ff ff       	jmp    8008b9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ff:	c7 44 24 08 7d 1a 80 	movl   $0x801a7d,0x8(%esp)
  800a06:	00 
  800a07:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a0b:	89 3c 24             	mov    %edi,(%esp)
  800a0e:	e8 2e 03 00 00       	call   800d41 <printfmt>
  800a13:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a16:	e9 9e fe ff ff       	jmp    8008b9 <vprintfmt+0x2c>
  800a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a26:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a29:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2c:	8d 50 04             	lea    0x4(%eax),%edx
  800a2f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a32:	8b 00                	mov    (%eax),%eax
  800a34:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800a37:	85 c0                	test   %eax,%eax
  800a39:	75 07                	jne    800a42 <vprintfmt+0x1b5>
  800a3b:	c7 45 c4 80 1a 80 00 	movl   $0x801a80,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a42:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a46:	7e 06                	jle    800a4e <vprintfmt+0x1c1>
  800a48:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800a4c:	75 13                	jne    800a61 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a51:	0f be 02             	movsbl (%edx),%eax
  800a54:	85 c0                	test   %eax,%eax
  800a56:	0f 85 99 00 00 00    	jne    800af5 <vprintfmt+0x268>
  800a5c:	e9 86 00 00 00       	jmp    800ae7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a65:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800a68:	89 0c 24             	mov    %ecx,(%esp)
  800a6b:	e8 1b 03 00 00       	call   800d8b <strnlen>
  800a70:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a73:	29 c2                	sub    %eax,%edx
  800a75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a78:	85 d2                	test   %edx,%edx
  800a7a:	7e d2                	jle    800a4e <vprintfmt+0x1c1>
					putch(padc, putdat);
  800a7c:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800a80:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a83:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a86:	89 d3                	mov    %edx,%ebx
  800a88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a8f:	89 04 24             	mov    %eax,(%esp)
  800a92:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a94:	83 eb 01             	sub    $0x1,%ebx
  800a97:	85 db                	test   %ebx,%ebx
  800a99:	7f ed                	jg     800a88 <vprintfmt+0x1fb>
  800a9b:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800aa5:	eb a7                	jmp    800a4e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aa7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800aab:	74 18                	je     800ac5 <vprintfmt+0x238>
  800aad:	8d 50 e0             	lea    -0x20(%eax),%edx
  800ab0:	83 fa 5e             	cmp    $0x5e,%edx
  800ab3:	76 10                	jbe    800ac5 <vprintfmt+0x238>
					putch('?', putdat);
  800ab5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ac0:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ac3:	eb 0a                	jmp    800acf <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800ac5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac9:	89 04 24             	mov    %eax,(%esp)
  800acc:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800acf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800ad3:	0f be 03             	movsbl (%ebx),%eax
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	74 05                	je     800adf <vprintfmt+0x252>
  800ada:	83 c3 01             	add    $0x1,%ebx
  800add:	eb 29                	jmp    800b08 <vprintfmt+0x27b>
  800adf:	89 fe                	mov    %edi,%esi
  800ae1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ae4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ae7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800aeb:	7f 2e                	jg     800b1b <vprintfmt+0x28e>
  800aed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800af0:	e9 c4 fd ff ff       	jmp    8008b9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800af5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800afe:	89 f7                	mov    %esi,%edi
  800b00:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800b03:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	85 f6                	test   %esi,%esi
  800b0a:	78 9b                	js     800aa7 <vprintfmt+0x21a>
  800b0c:	83 ee 01             	sub    $0x1,%esi
  800b0f:	79 96                	jns    800aa7 <vprintfmt+0x21a>
  800b11:	89 fe                	mov    %edi,%esi
  800b13:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800b16:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800b19:	eb cc                	jmp    800ae7 <vprintfmt+0x25a>
  800b1b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800b1e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b25:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b2c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b2e:	83 eb 01             	sub    $0x1,%ebx
  800b31:	85 db                	test   %ebx,%ebx
  800b33:	7f ec                	jg     800b21 <vprintfmt+0x294>
  800b35:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b38:	e9 7c fd ff ff       	jmp    8008b9 <vprintfmt+0x2c>
  800b3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b40:	83 f9 01             	cmp    $0x1,%ecx
  800b43:	7e 16                	jle    800b5b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8d 50 08             	lea    0x8(%eax),%edx
  800b4b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4e:	8b 10                	mov    (%eax),%edx
  800b50:	8b 48 04             	mov    0x4(%eax),%ecx
  800b53:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800b56:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b59:	eb 32                	jmp    800b8d <vprintfmt+0x300>
	else if (lflag)
  800b5b:	85 c9                	test   %ecx,%ecx
  800b5d:	74 18                	je     800b77 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	8d 50 04             	lea    0x4(%eax),%edx
  800b65:	89 55 14             	mov    %edx,0x14(%ebp)
  800b68:	8b 00                	mov    (%eax),%eax
  800b6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b6d:	89 c1                	mov    %eax,%ecx
  800b6f:	c1 f9 1f             	sar    $0x1f,%ecx
  800b72:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b75:	eb 16                	jmp    800b8d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800b77:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7a:	8d 50 04             	lea    0x4(%eax),%edx
  800b7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b80:	8b 00                	mov    (%eax),%eax
  800b82:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b85:	89 c2                	mov    %eax,%edx
  800b87:	c1 fa 1f             	sar    $0x1f,%edx
  800b8a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b8d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b93:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800b98:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b9c:	0f 89 b8 00 00 00    	jns    800c5a <vprintfmt+0x3cd>
				putch('-', putdat);
  800ba2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bad:	ff d7                	call   *%edi
				num = -(long long) num;
  800baf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800bb2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800bb5:	f7 d9                	neg    %ecx
  800bb7:	83 d3 00             	adc    $0x0,%ebx
  800bba:	f7 db                	neg    %ebx
  800bbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc1:	e9 94 00 00 00       	jmp    800c5a <vprintfmt+0x3cd>
  800bc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bc9:	89 ca                	mov    %ecx,%edx
  800bcb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bce:	e8 63 fc ff ff       	call   800836 <getuint>
  800bd3:	89 c1                	mov    %eax,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800bdc:	eb 7c                	jmp    800c5a <vprintfmt+0x3cd>
  800bde:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800be1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bec:	ff d7                	call   *%edi
			putch('X', putdat);
  800bee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bf9:	ff d7                	call   *%edi
			putch('X', putdat);
  800bfb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bff:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800c06:	ff d7                	call   *%edi
  800c08:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c0b:	e9 a9 fc ff ff       	jmp    8008b9 <vprintfmt+0x2c>
  800c10:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800c13:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c17:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c1e:	ff d7                	call   *%edi
			putch('x', putdat);
  800c20:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c24:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c2b:	ff d7                	call   *%edi
			num = (unsigned long long)
  800c2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c30:	8d 50 04             	lea    0x4(%eax),%edx
  800c33:	89 55 14             	mov    %edx,0x14(%ebp)
  800c36:	8b 08                	mov    (%eax),%ecx
  800c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3d:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c42:	eb 16                	jmp    800c5a <vprintfmt+0x3cd>
  800c44:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c47:	89 ca                	mov    %ecx,%edx
  800c49:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4c:	e8 e5 fb ff ff       	call   800836 <getuint>
  800c51:	89 c1                	mov    %eax,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c5a:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800c5e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c65:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c69:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6d:	89 0c 24             	mov    %ecx,(%esp)
  800c70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c74:	89 f2                	mov    %esi,%edx
  800c76:	89 f8                	mov    %edi,%eax
  800c78:	e8 c3 fa ff ff       	call   800740 <printnum>
  800c7d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c80:	e9 34 fc ff ff       	jmp    8008b9 <vprintfmt+0x2c>
  800c85:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c88:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8f:	89 14 24             	mov    %edx,(%esp)
  800c92:	ff d7                	call   *%edi
  800c94:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c97:	e9 1d fc ff ff       	jmp    8008b9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ca7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cac:	80 38 25             	cmpb   $0x25,(%eax)
  800caf:	0f 84 04 fc ff ff    	je     8008b9 <vprintfmt+0x2c>
  800cb5:	89 c3                	mov    %eax,%ebx
  800cb7:	eb f0                	jmp    800ca9 <vprintfmt+0x41c>
				/* do nothing */;
			break;
		}
	}
}
  800cb9:	83 c4 5c             	add    $0x5c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 28             	sub    $0x28,%esp
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	74 04                	je     800cd5 <vsnprintf+0x14>
  800cd1:	85 d2                	test   %edx,%edx
  800cd3:	7f 07                	jg     800cdc <vsnprintf+0x1b>
  800cd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cda:	eb 3b                	jmp    800d17 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cdf:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ce6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ced:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d02:	c7 04 24 70 08 80 00 	movl   $0x800870,(%esp)
  800d09:	e8 7f fb ff ff       	call   80088d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d11:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d1f:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d26:	8b 45 10             	mov    0x10(%ebp),%eax
  800d29:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	89 04 24             	mov    %eax,(%esp)
  800d3a:	e8 82 ff ff ff       	call   800cc1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d47:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 26 fb ff ff       	call   80088d <vprintfmt>
	va_end(ap);
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    
  800d69:	00 00                	add    %al,(%eax)
  800d6b:	00 00                	add    %al,(%eax)
  800d6d:	00 00                	add    %al,(%eax)
	...

00800d70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d7e:	74 09                	je     800d89 <strlen+0x19>
		n++;
  800d80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d87:	75 f7                	jne    800d80 <strlen+0x10>
		n++;
	return n;
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	53                   	push   %ebx
  800d8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d95:	85 c9                	test   %ecx,%ecx
  800d97:	74 19                	je     800db2 <strnlen+0x27>
  800d99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d9c:	74 14                	je     800db2 <strnlen+0x27>
  800d9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800da3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800da6:	39 c8                	cmp    %ecx,%eax
  800da8:	74 0d                	je     800db7 <strnlen+0x2c>
  800daa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dae:	75 f3                	jne    800da3 <strnlen+0x18>
  800db0:	eb 05                	jmp    800db7 <strnlen+0x2c>
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800db7:	5b                   	pop    %ebx
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	53                   	push   %ebx
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800dc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800dcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800dd0:	83 c2 01             	add    $0x1,%edx
  800dd3:	84 c9                	test   %cl,%cl
  800dd5:	75 f2                	jne    800dc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800de4:	89 1c 24             	mov    %ebx,(%esp)
  800de7:	e8 84 ff ff ff       	call   800d70 <strlen>
	strcpy(dst + len, src);
  800dec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800def:	89 54 24 04          	mov    %edx,0x4(%esp)
  800df3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800df6:	89 04 24             	mov    %eax,(%esp)
  800df9:	e8 bc ff ff ff       	call   800dba <strcpy>
	return dst;
}
  800dfe:	89 d8                	mov    %ebx,%eax
  800e00:	83 c4 08             	add    $0x8,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e14:	85 f6                	test   %esi,%esi
  800e16:	74 18                	je     800e30 <strncpy+0x2a>
  800e18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e1d:	0f b6 1a             	movzbl (%edx),%ebx
  800e20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e23:	80 3a 01             	cmpb   $0x1,(%edx)
  800e26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e29:	83 c1 01             	add    $0x1,%ecx
  800e2c:	39 ce                	cmp    %ecx,%esi
  800e2e:	77 ed                	ja     800e1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	85 c9                	test   %ecx,%ecx
  800e46:	74 27                	je     800e6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e48:	83 e9 01             	sub    $0x1,%ecx
  800e4b:	74 1d                	je     800e6a <strlcpy+0x36>
  800e4d:	0f b6 1a             	movzbl (%edx),%ebx
  800e50:	84 db                	test   %bl,%bl
  800e52:	74 16                	je     800e6a <strlcpy+0x36>
			*dst++ = *src++;
  800e54:	88 18                	mov    %bl,(%eax)
  800e56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e59:	83 e9 01             	sub    $0x1,%ecx
  800e5c:	74 0e                	je     800e6c <strlcpy+0x38>
			*dst++ = *src++;
  800e5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e61:	0f b6 1a             	movzbl (%edx),%ebx
  800e64:	84 db                	test   %bl,%bl
  800e66:	75 ec                	jne    800e54 <strlcpy+0x20>
  800e68:	eb 02                	jmp    800e6c <strlcpy+0x38>
  800e6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e6c:	c6 00 00             	movb   $0x0,(%eax)
  800e6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e7e:	0f b6 01             	movzbl (%ecx),%eax
  800e81:	84 c0                	test   %al,%al
  800e83:	74 15                	je     800e9a <strcmp+0x25>
  800e85:	3a 02                	cmp    (%edx),%al
  800e87:	75 11                	jne    800e9a <strcmp+0x25>
		p++, q++;
  800e89:	83 c1 01             	add    $0x1,%ecx
  800e8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e8f:	0f b6 01             	movzbl (%ecx),%eax
  800e92:	84 c0                	test   %al,%al
  800e94:	74 04                	je     800e9a <strcmp+0x25>
  800e96:	3a 02                	cmp    (%edx),%al
  800e98:	74 ef                	je     800e89 <strcmp+0x14>
  800e9a:	0f b6 c0             	movzbl %al,%eax
  800e9d:	0f b6 12             	movzbl (%edx),%edx
  800ea0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	74 23                	je     800ed8 <strncmp+0x34>
  800eb5:	0f b6 1a             	movzbl (%edx),%ebx
  800eb8:	84 db                	test   %bl,%bl
  800eba:	74 25                	je     800ee1 <strncmp+0x3d>
  800ebc:	3a 19                	cmp    (%ecx),%bl
  800ebe:	75 21                	jne    800ee1 <strncmp+0x3d>
  800ec0:	83 e8 01             	sub    $0x1,%eax
  800ec3:	74 13                	je     800ed8 <strncmp+0x34>
		n--, p++, q++;
  800ec5:	83 c2 01             	add    $0x1,%edx
  800ec8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ecb:	0f b6 1a             	movzbl (%edx),%ebx
  800ece:	84 db                	test   %bl,%bl
  800ed0:	74 0f                	je     800ee1 <strncmp+0x3d>
  800ed2:	3a 19                	cmp    (%ecx),%bl
  800ed4:	74 ea                	je     800ec0 <strncmp+0x1c>
  800ed6:	eb 09                	jmp    800ee1 <strncmp+0x3d>
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800edd:	5b                   	pop    %ebx
  800ede:	5d                   	pop    %ebp
  800edf:	90                   	nop
  800ee0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ee1:	0f b6 02             	movzbl (%edx),%eax
  800ee4:	0f b6 11             	movzbl (%ecx),%edx
  800ee7:	29 d0                	sub    %edx,%eax
  800ee9:	eb f2                	jmp    800edd <strncmp+0x39>

00800eeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ef5:	0f b6 10             	movzbl (%eax),%edx
  800ef8:	84 d2                	test   %dl,%dl
  800efa:	74 18                	je     800f14 <strchr+0x29>
		if (*s == c)
  800efc:	38 ca                	cmp    %cl,%dl
  800efe:	75 0a                	jne    800f0a <strchr+0x1f>
  800f00:	eb 17                	jmp    800f19 <strchr+0x2e>
  800f02:	38 ca                	cmp    %cl,%dl
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	74 0f                	je     800f19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f0a:	83 c0 01             	add    $0x1,%eax
  800f0d:	0f b6 10             	movzbl (%eax),%edx
  800f10:	84 d2                	test   %dl,%dl
  800f12:	75 ee                	jne    800f02 <strchr+0x17>
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f25:	0f b6 10             	movzbl (%eax),%edx
  800f28:	84 d2                	test   %dl,%dl
  800f2a:	74 18                	je     800f44 <strfind+0x29>
		if (*s == c)
  800f2c:	38 ca                	cmp    %cl,%dl
  800f2e:	75 0a                	jne    800f3a <strfind+0x1f>
  800f30:	eb 12                	jmp    800f44 <strfind+0x29>
  800f32:	38 ca                	cmp    %cl,%dl
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	74 0a                	je     800f44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f3a:	83 c0 01             	add    $0x1,%eax
  800f3d:	0f b6 10             	movzbl (%eax),%edx
  800f40:	84 d2                	test   %dl,%dl
  800f42:	75 ee                	jne    800f32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	89 1c 24             	mov    %ebx,(%esp)
  800f4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f60:	85 c9                	test   %ecx,%ecx
  800f62:	74 30                	je     800f94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f6a:	75 25                	jne    800f91 <memset+0x4b>
  800f6c:	f6 c1 03             	test   $0x3,%cl
  800f6f:	75 20                	jne    800f91 <memset+0x4b>
		c &= 0xFF;
  800f71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f74:	89 d3                	mov    %edx,%ebx
  800f76:	c1 e3 08             	shl    $0x8,%ebx
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	c1 e6 18             	shl    $0x18,%esi
  800f7e:	89 d0                	mov    %edx,%eax
  800f80:	c1 e0 10             	shl    $0x10,%eax
  800f83:	09 f0                	or     %esi,%eax
  800f85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800f87:	09 d8                	or     %ebx,%eax
  800f89:	c1 e9 02             	shr    $0x2,%ecx
  800f8c:	fc                   	cld    
  800f8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f8f:	eb 03                	jmp    800f94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f91:	fc                   	cld    
  800f92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	8b 1c 24             	mov    (%esp),%ebx
  800f99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fa1:	89 ec                	mov    %ebp,%esp
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	89 34 24             	mov    %esi,(%esp)
  800fae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800fbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800fbd:	39 c6                	cmp    %eax,%esi
  800fbf:	73 35                	jae    800ff6 <memmove+0x51>
  800fc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fc4:	39 d0                	cmp    %edx,%eax
  800fc6:	73 2e                	jae    800ff6 <memmove+0x51>
		s += n;
		d += n;
  800fc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fca:	f6 c2 03             	test   $0x3,%dl
  800fcd:	75 1b                	jne    800fea <memmove+0x45>
  800fcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fd5:	75 13                	jne    800fea <memmove+0x45>
  800fd7:	f6 c1 03             	test   $0x3,%cl
  800fda:	75 0e                	jne    800fea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800fdc:	83 ef 04             	sub    $0x4,%edi
  800fdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fe2:	c1 e9 02             	shr    $0x2,%ecx
  800fe5:	fd                   	std    
  800fe6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fe8:	eb 09                	jmp    800ff3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fea:	83 ef 01             	sub    $0x1,%edi
  800fed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ff0:	fd                   	std    
  800ff1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ff3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ff4:	eb 20                	jmp    801016 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ff6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ffc:	75 15                	jne    801013 <memmove+0x6e>
  800ffe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801004:	75 0d                	jne    801013 <memmove+0x6e>
  801006:	f6 c1 03             	test   $0x3,%cl
  801009:	75 08                	jne    801013 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80100b:	c1 e9 02             	shr    $0x2,%ecx
  80100e:	fc                   	cld    
  80100f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801011:	eb 03                	jmp    801016 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801013:	fc                   	cld    
  801014:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801016:	8b 34 24             	mov    (%esp),%esi
  801019:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80101d:	89 ec                	mov    %ebp,%esp
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801027:	8b 45 10             	mov    0x10(%ebp),%eax
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801031:	89 44 24 04          	mov    %eax,0x4(%esp)
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	89 04 24             	mov    %eax,(%esp)
  80103b:	e8 65 ff ff ff       	call   800fa5 <memmove>
}
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	8b 75 08             	mov    0x8(%ebp),%esi
  80104b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80104e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801051:	85 c9                	test   %ecx,%ecx
  801053:	74 36                	je     80108b <memcmp+0x49>
		if (*s1 != *s2)
  801055:	0f b6 06             	movzbl (%esi),%eax
  801058:	0f b6 1f             	movzbl (%edi),%ebx
  80105b:	38 d8                	cmp    %bl,%al
  80105d:	74 20                	je     80107f <memcmp+0x3d>
  80105f:	eb 14                	jmp    801075 <memcmp+0x33>
  801061:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801066:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80106b:	83 c2 01             	add    $0x1,%edx
  80106e:	83 e9 01             	sub    $0x1,%ecx
  801071:	38 d8                	cmp    %bl,%al
  801073:	74 12                	je     801087 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801075:	0f b6 c0             	movzbl %al,%eax
  801078:	0f b6 db             	movzbl %bl,%ebx
  80107b:	29 d8                	sub    %ebx,%eax
  80107d:	eb 11                	jmp    801090 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80107f:	83 e9 01             	sub    $0x1,%ecx
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	85 c9                	test   %ecx,%ecx
  801089:	75 d6                	jne    801061 <memcmp+0x1f>
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010a0:	39 d0                	cmp    %edx,%eax
  8010a2:	73 15                	jae    8010b9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010a8:	38 08                	cmp    %cl,(%eax)
  8010aa:	75 06                	jne    8010b2 <memfind+0x1d>
  8010ac:	eb 0b                	jmp    8010b9 <memfind+0x24>
  8010ae:	38 08                	cmp    %cl,(%eax)
  8010b0:	74 07                	je     8010b9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010b2:	83 c0 01             	add    $0x1,%eax
  8010b5:	39 c2                	cmp    %eax,%edx
  8010b7:	77 f5                	ja     8010ae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ca:	0f b6 02             	movzbl (%edx),%eax
  8010cd:	3c 20                	cmp    $0x20,%al
  8010cf:	74 04                	je     8010d5 <strtol+0x1a>
  8010d1:	3c 09                	cmp    $0x9,%al
  8010d3:	75 0e                	jne    8010e3 <strtol+0x28>
		s++;
  8010d5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d8:	0f b6 02             	movzbl (%edx),%eax
  8010db:	3c 20                	cmp    $0x20,%al
  8010dd:	74 f6                	je     8010d5 <strtol+0x1a>
  8010df:	3c 09                	cmp    $0x9,%al
  8010e1:	74 f2                	je     8010d5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e3:	3c 2b                	cmp    $0x2b,%al
  8010e5:	75 0c                	jne    8010f3 <strtol+0x38>
		s++;
  8010e7:	83 c2 01             	add    $0x1,%edx
  8010ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010f1:	eb 15                	jmp    801108 <strtol+0x4d>
	else if (*s == '-')
  8010f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010fa:	3c 2d                	cmp    $0x2d,%al
  8010fc:	75 0a                	jne    801108 <strtol+0x4d>
		s++, neg = 1;
  8010fe:	83 c2 01             	add    $0x1,%edx
  801101:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801108:	85 db                	test   %ebx,%ebx
  80110a:	0f 94 c0             	sete   %al
  80110d:	74 05                	je     801114 <strtol+0x59>
  80110f:	83 fb 10             	cmp    $0x10,%ebx
  801112:	75 18                	jne    80112c <strtol+0x71>
  801114:	80 3a 30             	cmpb   $0x30,(%edx)
  801117:	75 13                	jne    80112c <strtol+0x71>
  801119:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	75 0a                	jne    80112c <strtol+0x71>
		s += 2, base = 16;
  801122:	83 c2 02             	add    $0x2,%edx
  801125:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80112a:	eb 15                	jmp    801141 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80112c:	84 c0                	test   %al,%al
  80112e:	66 90                	xchg   %ax,%ax
  801130:	74 0f                	je     801141 <strtol+0x86>
  801132:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801137:	80 3a 30             	cmpb   $0x30,(%edx)
  80113a:	75 05                	jne    801141 <strtol+0x86>
		s++, base = 8;
  80113c:	83 c2 01             	add    $0x1,%edx
  80113f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801148:	0f b6 0a             	movzbl (%edx),%ecx
  80114b:	89 cf                	mov    %ecx,%edi
  80114d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801150:	80 fb 09             	cmp    $0x9,%bl
  801153:	77 08                	ja     80115d <strtol+0xa2>
			dig = *s - '0';
  801155:	0f be c9             	movsbl %cl,%ecx
  801158:	83 e9 30             	sub    $0x30,%ecx
  80115b:	eb 1e                	jmp    80117b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80115d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801160:	80 fb 19             	cmp    $0x19,%bl
  801163:	77 08                	ja     80116d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801165:	0f be c9             	movsbl %cl,%ecx
  801168:	83 e9 57             	sub    $0x57,%ecx
  80116b:	eb 0e                	jmp    80117b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80116d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801170:	80 fb 19             	cmp    $0x19,%bl
  801173:	77 15                	ja     80118a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801175:	0f be c9             	movsbl %cl,%ecx
  801178:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80117b:	39 f1                	cmp    %esi,%ecx
  80117d:	7d 0b                	jge    80118a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	0f af c6             	imul   %esi,%eax
  801185:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801188:	eb be                	jmp    801148 <strtol+0x8d>
  80118a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80118c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801190:	74 05                	je     801197 <strtol+0xdc>
		*endptr = (char *) s;
  801192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801195:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80119b:	74 04                	je     8011a1 <strtol+0xe6>
  80119d:	89 c8                	mov    %ecx,%eax
  80119f:	f7 d8                	neg    %eax
}
  8011a1:	83 c4 04             	add    $0x4,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    
  8011a9:	00 00                	add    %al,(%eax)
	...

008011ac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	89 1c 24             	mov    %ebx,(%esp)
  8011b5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011be:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c3:	89 d1                	mov    %edx,%ecx
  8011c5:	89 d3                	mov    %edx,%ebx
  8011c7:	89 d7                	mov    %edx,%edi
  8011c9:	51                   	push   %ecx
  8011ca:	52                   	push   %edx
  8011cb:	53                   	push   %ebx
  8011cc:	54                   	push   %esp
  8011cd:	55                   	push   %ebp
  8011ce:	56                   	push   %esi
  8011cf:	57                   	push   %edi
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	8d 35 da 11 80 00    	lea    0x8011da,%esi
  8011d8:	0f 34                	sysenter 
  8011da:	5f                   	pop    %edi
  8011db:	5e                   	pop    %esi
  8011dc:	5d                   	pop    %ebp
  8011dd:	5c                   	pop    %esp
  8011de:	5b                   	pop    %ebx
  8011df:	5a                   	pop    %edx
  8011e0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011e1:	8b 1c 24             	mov    (%esp),%ebx
  8011e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011e8:	89 ec                	mov    %ebp,%esp
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 08             	sub    $0x8,%esp
  8011f2:	89 1c 24             	mov    %ebx,(%esp)
  8011f5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	8b 55 08             	mov    0x8(%ebp),%edx
  801204:	89 c3                	mov    %eax,%ebx
  801206:	89 c7                	mov    %eax,%edi
  801208:	51                   	push   %ecx
  801209:	52                   	push   %edx
  80120a:	53                   	push   %ebx
  80120b:	54                   	push   %esp
  80120c:	55                   	push   %ebp
  80120d:	56                   	push   %esi
  80120e:	57                   	push   %edi
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8d 35 19 12 80 00    	lea    0x801219,%esi
  801217:	0f 34                	sysenter 
  801219:	5f                   	pop    %edi
  80121a:	5e                   	pop    %esi
  80121b:	5d                   	pop    %ebp
  80121c:	5c                   	pop    %esp
  80121d:	5b                   	pop    %ebx
  80121e:	5a                   	pop    %edx
  80121f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801220:	8b 1c 24             	mov    (%esp),%ebx
  801223:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801227:	89 ec                	mov    %ebp,%esp
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	89 1c 24             	mov    %ebx,(%esp)
  801234:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801238:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123d:	b8 0e 00 00 00       	mov    $0xe,%eax
  801242:	8b 55 08             	mov    0x8(%ebp),%edx
  801245:	89 cb                	mov    %ecx,%ebx
  801247:	89 cf                	mov    %ecx,%edi
  801249:	51                   	push   %ecx
  80124a:	52                   	push   %edx
  80124b:	53                   	push   %ebx
  80124c:	54                   	push   %esp
  80124d:	55                   	push   %ebp
  80124e:	56                   	push   %esi
  80124f:	57                   	push   %edi
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8d 35 5a 12 80 00    	lea    0x80125a,%esi
  801258:	0f 34                	sysenter 
  80125a:	5f                   	pop    %edi
  80125b:	5e                   	pop    %esi
  80125c:	5d                   	pop    %ebp
  80125d:	5c                   	pop    %esp
  80125e:	5b                   	pop    %ebx
  80125f:	5a                   	pop    %edx
  801260:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801261:	8b 1c 24             	mov    (%esp),%ebx
  801264:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801268:	89 ec                	mov    %ebp,%esp
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 28             	sub    $0x28,%esp
  801272:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801275:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801278:	b9 00 00 00 00       	mov    $0x0,%ecx
  80127d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801282:	8b 55 08             	mov    0x8(%ebp),%edx
  801285:	89 cb                	mov    %ecx,%ebx
  801287:	89 cf                	mov    %ecx,%edi
  801289:	51                   	push   %ecx
  80128a:	52                   	push   %edx
  80128b:	53                   	push   %ebx
  80128c:	54                   	push   %esp
  80128d:	55                   	push   %ebp
  80128e:	56                   	push   %esi
  80128f:	57                   	push   %edi
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8d 35 9a 12 80 00    	lea    0x80129a,%esi
  801298:	0f 34                	sysenter 
  80129a:	5f                   	pop    %edi
  80129b:	5e                   	pop    %esi
  80129c:	5d                   	pop    %ebp
  80129d:	5c                   	pop    %esp
  80129e:	5b                   	pop    %ebx
  80129f:	5a                   	pop    %edx
  8012a0:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	7e 28                	jle    8012cd <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  8012c8:	e8 3b f3 ff ff       	call   800608 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012cd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012d3:	89 ec                	mov    %ebp,%esp
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	89 1c 24             	mov    %ebx,(%esp)
  8012e0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f5:	51                   	push   %ecx
  8012f6:	52                   	push   %edx
  8012f7:	53                   	push   %ebx
  8012f8:	54                   	push   %esp
  8012f9:	55                   	push   %ebp
  8012fa:	56                   	push   %esi
  8012fb:	57                   	push   %edi
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	8d 35 06 13 80 00    	lea    0x801306,%esi
  801304:	0f 34                	sysenter 
  801306:	5f                   	pop    %edi
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	5c                   	pop    %esp
  80130a:	5b                   	pop    %ebx
  80130b:	5a                   	pop    %edx
  80130c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80130d:	8b 1c 24             	mov    (%esp),%ebx
  801310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801314:	89 ec                	mov    %ebp,%esp
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 28             	sub    $0x28,%esp
  80131e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801321:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801324:	bb 00 00 00 00       	mov    $0x0,%ebx
  801329:	b8 0a 00 00 00       	mov    $0xa,%eax
  80132e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801331:	8b 55 08             	mov    0x8(%ebp),%edx
  801334:	89 df                	mov    %ebx,%edi
  801336:	51                   	push   %ecx
  801337:	52                   	push   %edx
  801338:	53                   	push   %ebx
  801339:	54                   	push   %esp
  80133a:	55                   	push   %ebp
  80133b:	56                   	push   %esi
  80133c:	57                   	push   %edi
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	8d 35 47 13 80 00    	lea    0x801347,%esi
  801345:	0f 34                	sysenter 
  801347:	5f                   	pop    %edi
  801348:	5e                   	pop    %esi
  801349:	5d                   	pop    %ebp
  80134a:	5c                   	pop    %esp
  80134b:	5b                   	pop    %ebx
  80134c:	5a                   	pop    %edx
  80134d:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80134e:	85 c0                	test   %eax,%eax
  801350:	7e 28                	jle    80137a <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801352:	89 44 24 10          	mov    %eax,0x10(%esp)
  801356:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80135d:	00 
  80135e:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  801365:	00 
  801366:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80136d:	00 
  80136e:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  801375:	e8 8e f2 ff ff       	call   800608 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80137a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80137d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801380:	89 ec                	mov    %ebp,%esp
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 28             	sub    $0x28,%esp
  80138a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80138d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
  801395:	b8 09 00 00 00       	mov    $0x9,%eax
  80139a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139d:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a0:	89 df                	mov    %ebx,%edi
  8013a2:	51                   	push   %ecx
  8013a3:	52                   	push   %edx
  8013a4:	53                   	push   %ebx
  8013a5:	54                   	push   %esp
  8013a6:	55                   	push   %ebp
  8013a7:	56                   	push   %esi
  8013a8:	57                   	push   %edi
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	8d 35 b3 13 80 00    	lea    0x8013b3,%esi
  8013b1:	0f 34                	sysenter 
  8013b3:	5f                   	pop    %edi
  8013b4:	5e                   	pop    %esi
  8013b5:	5d                   	pop    %ebp
  8013b6:	5c                   	pop    %esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5a                   	pop    %edx
  8013b9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	7e 28                	jle    8013e6 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013c9:	00 
  8013ca:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8013d9:	00 
  8013da:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  8013e1:	e8 22 f2 ff ff       	call   800608 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ec:	89 ec                	mov    %ebp,%esp
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 28             	sub    $0x28,%esp
  8013f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801401:	b8 07 00 00 00       	mov    $0x7,%eax
  801406:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801409:	8b 55 08             	mov    0x8(%ebp),%edx
  80140c:	89 df                	mov    %ebx,%edi
  80140e:	51                   	push   %ecx
  80140f:	52                   	push   %edx
  801410:	53                   	push   %ebx
  801411:	54                   	push   %esp
  801412:	55                   	push   %ebp
  801413:	56                   	push   %esi
  801414:	57                   	push   %edi
  801415:	89 e5                	mov    %esp,%ebp
  801417:	8d 35 1f 14 80 00    	lea    0x80141f,%esi
  80141d:	0f 34                	sysenter 
  80141f:	5f                   	pop    %edi
  801420:	5e                   	pop    %esi
  801421:	5d                   	pop    %ebp
  801422:	5c                   	pop    %esp
  801423:	5b                   	pop    %ebx
  801424:	5a                   	pop    %edx
  801425:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801426:	85 c0                	test   %eax,%eax
  801428:	7e 28                	jle    801452 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80142a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80142e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801435:	00 
  801436:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  80143d:	00 
  80143e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801445:	00 
  801446:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  80144d:	e8 b6 f1 ff ff       	call   800608 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801452:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801455:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801458:	89 ec                	mov    %ebp,%esp
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 28             	sub    $0x28,%esp
  801462:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801465:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801468:	b8 06 00 00 00       	mov    $0x6,%eax
  80146d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801470:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801473:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801476:	8b 55 08             	mov    0x8(%ebp),%edx
  801479:	51                   	push   %ecx
  80147a:	52                   	push   %edx
  80147b:	53                   	push   %ebx
  80147c:	54                   	push   %esp
  80147d:	55                   	push   %ebp
  80147e:	56                   	push   %esi
  80147f:	57                   	push   %edi
  801480:	89 e5                	mov    %esp,%ebp
  801482:	8d 35 8a 14 80 00    	lea    0x80148a,%esi
  801488:	0f 34                	sysenter 
  80148a:	5f                   	pop    %edi
  80148b:	5e                   	pop    %esi
  80148c:	5d                   	pop    %ebp
  80148d:	5c                   	pop    %esp
  80148e:	5b                   	pop    %ebx
  80148f:	5a                   	pop    %edx
  801490:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801491:	85 c0                	test   %eax,%eax
  801493:	7e 28                	jle    8014bd <sys_page_map+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801495:	89 44 24 10          	mov    %eax,0x10(%esp)
  801499:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8014a0:	00 
  8014a1:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  8014a8:	00 
  8014a9:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8014b0:	00 
  8014b1:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  8014b8:	e8 4b f1 ff ff       	call   800608 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8014bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c3:	89 ec                	mov    %ebp,%esp
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 28             	sub    $0x28,%esp
  8014cd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014d0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8014d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e6:	51                   	push   %ecx
  8014e7:	52                   	push   %edx
  8014e8:	53                   	push   %ebx
  8014e9:	54                   	push   %esp
  8014ea:	55                   	push   %ebp
  8014eb:	56                   	push   %esi
  8014ec:	57                   	push   %edi
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	8d 35 f7 14 80 00    	lea    0x8014f7,%esi
  8014f5:	0f 34                	sysenter 
  8014f7:	5f                   	pop    %edi
  8014f8:	5e                   	pop    %esi
  8014f9:	5d                   	pop    %ebp
  8014fa:	5c                   	pop    %esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5a                   	pop    %edx
  8014fd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8014fe:	85 c0                	test   %eax,%eax
  801500:	7e 28                	jle    80152a <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801502:	89 44 24 10          	mov    %eax,0x10(%esp)
  801506:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80150d:	00 
  80150e:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  801515:	00 
  801516:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80151d:	00 
  80151e:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  801525:	e8 de f0 ff ff       	call   800608 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80152a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80152d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801530:	89 ec                	mov    %ebp,%esp
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	89 1c 24             	mov    %ebx,(%esp)
  80153d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 0b 00 00 00       	mov    $0xb,%eax
  80154b:	89 d1                	mov    %edx,%ecx
  80154d:	89 d3                	mov    %edx,%ebx
  80154f:	89 d7                	mov    %edx,%edi
  801551:	51                   	push   %ecx
  801552:	52                   	push   %edx
  801553:	53                   	push   %ebx
  801554:	54                   	push   %esp
  801555:	55                   	push   %ebp
  801556:	56                   	push   %esi
  801557:	57                   	push   %edi
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	8d 35 62 15 80 00    	lea    0x801562,%esi
  801560:	0f 34                	sysenter 
  801562:	5f                   	pop    %edi
  801563:	5e                   	pop    %esi
  801564:	5d                   	pop    %ebp
  801565:	5c                   	pop    %esp
  801566:	5b                   	pop    %ebx
  801567:	5a                   	pop    %edx
  801568:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801569:	8b 1c 24             	mov    (%esp),%ebx
  80156c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801570:	89 ec                	mov    %ebp,%esp
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	89 1c 24             	mov    %ebx,(%esp)
  80157d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801581:	bb 00 00 00 00       	mov    $0x0,%ebx
  801586:	b8 04 00 00 00       	mov    $0x4,%eax
  80158b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158e:	8b 55 08             	mov    0x8(%ebp),%edx
  801591:	89 df                	mov    %ebx,%edi
  801593:	51                   	push   %ecx
  801594:	52                   	push   %edx
  801595:	53                   	push   %ebx
  801596:	54                   	push   %esp
  801597:	55                   	push   %ebp
  801598:	56                   	push   %esi
  801599:	57                   	push   %edi
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	8d 35 a4 15 80 00    	lea    0x8015a4,%esi
  8015a2:	0f 34                	sysenter 
  8015a4:	5f                   	pop    %edi
  8015a5:	5e                   	pop    %esi
  8015a6:	5d                   	pop    %ebp
  8015a7:	5c                   	pop    %esp
  8015a8:	5b                   	pop    %ebx
  8015a9:	5a                   	pop    %edx
  8015aa:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8015ab:	8b 1c 24             	mov    (%esp),%ebx
  8015ae:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015b2:	89 ec                	mov    %ebp,%esp
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	89 1c 24             	mov    %ebx,(%esp)
  8015bf:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8015cd:	89 d1                	mov    %edx,%ecx
  8015cf:	89 d3                	mov    %edx,%ebx
  8015d1:	89 d7                	mov    %edx,%edi
  8015d3:	51                   	push   %ecx
  8015d4:	52                   	push   %edx
  8015d5:	53                   	push   %ebx
  8015d6:	54                   	push   %esp
  8015d7:	55                   	push   %ebp
  8015d8:	56                   	push   %esi
  8015d9:	57                   	push   %edi
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	8d 35 e4 15 80 00    	lea    0x8015e4,%esi
  8015e2:	0f 34                	sysenter 
  8015e4:	5f                   	pop    %edi
  8015e5:	5e                   	pop    %esi
  8015e6:	5d                   	pop    %ebp
  8015e7:	5c                   	pop    %esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5a                   	pop    %edx
  8015ea:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015eb:	8b 1c 24             	mov    (%esp),%ebx
  8015ee:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015f2:	89 ec                	mov    %ebp,%esp
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	83 ec 28             	sub    $0x28,%esp
  8015fc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015ff:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801602:	b9 00 00 00 00       	mov    $0x0,%ecx
  801607:	b8 03 00 00 00       	mov    $0x3,%eax
  80160c:	8b 55 08             	mov    0x8(%ebp),%edx
  80160f:	89 cb                	mov    %ecx,%ebx
  801611:	89 cf                	mov    %ecx,%edi
  801613:	51                   	push   %ecx
  801614:	52                   	push   %edx
  801615:	53                   	push   %ebx
  801616:	54                   	push   %esp
  801617:	55                   	push   %ebp
  801618:	56                   	push   %esi
  801619:	57                   	push   %edi
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	8d 35 24 16 80 00    	lea    0x801624,%esi
  801622:	0f 34                	sysenter 
  801624:	5f                   	pop    %edi
  801625:	5e                   	pop    %esi
  801626:	5d                   	pop    %ebp
  801627:	5c                   	pop    %esp
  801628:	5b                   	pop    %ebx
  801629:	5a                   	pop    %edx
  80162a:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	7e 28                	jle    801657 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80162f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801633:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80163a:	00 
  80163b:	c7 44 24 08 a4 1c 80 	movl   $0x801ca4,0x8(%esp)
  801642:	00 
  801643:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80164a:	00 
  80164b:	c7 04 24 c1 1c 80 00 	movl   $0x801cc1,(%esp)
  801652:	e8 b1 ef ff ff       	call   800608 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801657:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80165a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80165d:	89 ec                	mov    %ebp,%esp
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    
  801661:	00 00                	add    %al,(%eax)
	...

00801664 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80166a:	83 3d d4 20 80 00 00 	cmpl   $0x0,0x8020d4
  801671:	75 1c                	jne    80168f <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801673:	c7 44 24 08 d0 1c 80 	movl   $0x801cd0,0x8(%esp)
  80167a:	00 
  80167b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801682:	00 
  801683:	c7 04 24 f4 1c 80 00 	movl   $0x801cf4,(%esp)
  80168a:	e8 79 ef ff ff       	call   800608 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	a3 d4 20 80 00       	mov    %eax,0x8020d4
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    
  801699:	00 00                	add    %al,(%eax)
  80169b:	00 00                	add    %al,(%eax)
  80169d:	00 00                	add    %al,(%eax)
	...

008016a0 <__udivdi3>:
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	57                   	push   %edi
  8016a4:	56                   	push   %esi
  8016a5:	83 ec 10             	sub    $0x10,%esp
  8016a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8016b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8016b9:	75 35                	jne    8016f0 <__udivdi3+0x50>
  8016bb:	39 fe                	cmp    %edi,%esi
  8016bd:	77 61                	ja     801720 <__udivdi3+0x80>
  8016bf:	85 f6                	test   %esi,%esi
  8016c1:	75 0b                	jne    8016ce <__udivdi3+0x2e>
  8016c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c8:	31 d2                	xor    %edx,%edx
  8016ca:	f7 f6                	div    %esi
  8016cc:	89 c6                	mov    %eax,%esi
  8016ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8016d1:	31 d2                	xor    %edx,%edx
  8016d3:	89 f8                	mov    %edi,%eax
  8016d5:	f7 f6                	div    %esi
  8016d7:	89 c7                	mov    %eax,%edi
  8016d9:	89 c8                	mov    %ecx,%eax
  8016db:	f7 f6                	div    %esi
  8016dd:	89 c1                	mov    %eax,%ecx
  8016df:	89 fa                	mov    %edi,%edx
  8016e1:	89 c8                	mov    %ecx,%eax
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	5e                   	pop    %esi
  8016e7:	5f                   	pop    %edi
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    
  8016ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016f0:	39 f8                	cmp    %edi,%eax
  8016f2:	77 1c                	ja     801710 <__udivdi3+0x70>
  8016f4:	0f bd d0             	bsr    %eax,%edx
  8016f7:	83 f2 1f             	xor    $0x1f,%edx
  8016fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016fd:	75 39                	jne    801738 <__udivdi3+0x98>
  8016ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801702:	0f 86 a0 00 00 00    	jbe    8017a8 <__udivdi3+0x108>
  801708:	39 f8                	cmp    %edi,%eax
  80170a:	0f 82 98 00 00 00    	jb     8017a8 <__udivdi3+0x108>
  801710:	31 ff                	xor    %edi,%edi
  801712:	31 c9                	xor    %ecx,%ecx
  801714:	89 c8                	mov    %ecx,%eax
  801716:	89 fa                	mov    %edi,%edx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	5e                   	pop    %esi
  80171c:	5f                   	pop    %edi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    
  80171f:	90                   	nop
  801720:	89 d1                	mov    %edx,%ecx
  801722:	89 fa                	mov    %edi,%edx
  801724:	89 c8                	mov    %ecx,%eax
  801726:	31 ff                	xor    %edi,%edi
  801728:	f7 f6                	div    %esi
  80172a:	89 c1                	mov    %eax,%ecx
  80172c:	89 fa                	mov    %edi,%edx
  80172e:	89 c8                	mov    %ecx,%eax
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    
  801737:	90                   	nop
  801738:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80173c:	89 f2                	mov    %esi,%edx
  80173e:	d3 e0                	shl    %cl,%eax
  801740:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801743:	b8 20 00 00 00       	mov    $0x20,%eax
  801748:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80174b:	89 c1                	mov    %eax,%ecx
  80174d:	d3 ea                	shr    %cl,%edx
  80174f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801753:	0b 55 ec             	or     -0x14(%ebp),%edx
  801756:	d3 e6                	shl    %cl,%esi
  801758:	89 c1                	mov    %eax,%ecx
  80175a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80175d:	89 fe                	mov    %edi,%esi
  80175f:	d3 ee                	shr    %cl,%esi
  801761:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801765:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801768:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80176b:	d3 e7                	shl    %cl,%edi
  80176d:	89 c1                	mov    %eax,%ecx
  80176f:	d3 ea                	shr    %cl,%edx
  801771:	09 d7                	or     %edx,%edi
  801773:	89 f2                	mov    %esi,%edx
  801775:	89 f8                	mov    %edi,%eax
  801777:	f7 75 ec             	divl   -0x14(%ebp)
  80177a:	89 d6                	mov    %edx,%esi
  80177c:	89 c7                	mov    %eax,%edi
  80177e:	f7 65 e8             	mull   -0x18(%ebp)
  801781:	39 d6                	cmp    %edx,%esi
  801783:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801786:	72 30                	jb     8017b8 <__udivdi3+0x118>
  801788:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80178b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80178f:	d3 e2                	shl    %cl,%edx
  801791:	39 c2                	cmp    %eax,%edx
  801793:	73 05                	jae    80179a <__udivdi3+0xfa>
  801795:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801798:	74 1e                	je     8017b8 <__udivdi3+0x118>
  80179a:	89 f9                	mov    %edi,%ecx
  80179c:	31 ff                	xor    %edi,%edi
  80179e:	e9 71 ff ff ff       	jmp    801714 <__udivdi3+0x74>
  8017a3:	90                   	nop
  8017a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017a8:	31 ff                	xor    %edi,%edi
  8017aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8017af:	e9 60 ff ff ff       	jmp    801714 <__udivdi3+0x74>
  8017b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8017bb:	31 ff                	xor    %edi,%edi
  8017bd:	89 c8                	mov    %ecx,%eax
  8017bf:	89 fa                	mov    %edi,%edx
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    
	...

008017d0 <__umoddi3>:
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	57                   	push   %edi
  8017d4:	56                   	push   %esi
  8017d5:	83 ec 20             	sub    $0x20,%esp
  8017d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8017db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017e4:	85 d2                	test   %edx,%edx
  8017e6:	89 c8                	mov    %ecx,%eax
  8017e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8017eb:	75 13                	jne    801800 <__umoddi3+0x30>
  8017ed:	39 f7                	cmp    %esi,%edi
  8017ef:	76 3f                	jbe    801830 <__umoddi3+0x60>
  8017f1:	89 f2                	mov    %esi,%edx
  8017f3:	f7 f7                	div    %edi
  8017f5:	89 d0                	mov    %edx,%eax
  8017f7:	31 d2                	xor    %edx,%edx
  8017f9:	83 c4 20             	add    $0x20,%esp
  8017fc:	5e                   	pop    %esi
  8017fd:	5f                   	pop    %edi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    
  801800:	39 f2                	cmp    %esi,%edx
  801802:	77 4c                	ja     801850 <__umoddi3+0x80>
  801804:	0f bd ca             	bsr    %edx,%ecx
  801807:	83 f1 1f             	xor    $0x1f,%ecx
  80180a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80180d:	75 51                	jne    801860 <__umoddi3+0x90>
  80180f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801812:	0f 87 e0 00 00 00    	ja     8018f8 <__umoddi3+0x128>
  801818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181b:	29 f8                	sub    %edi,%eax
  80181d:	19 d6                	sbb    %edx,%esi
  80181f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801825:	89 f2                	mov    %esi,%edx
  801827:	83 c4 20             	add    $0x20,%esp
  80182a:	5e                   	pop    %esi
  80182b:	5f                   	pop    %edi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    
  80182e:	66 90                	xchg   %ax,%ax
  801830:	85 ff                	test   %edi,%edi
  801832:	75 0b                	jne    80183f <__umoddi3+0x6f>
  801834:	b8 01 00 00 00       	mov    $0x1,%eax
  801839:	31 d2                	xor    %edx,%edx
  80183b:	f7 f7                	div    %edi
  80183d:	89 c7                	mov    %eax,%edi
  80183f:	89 f0                	mov    %esi,%eax
  801841:	31 d2                	xor    %edx,%edx
  801843:	f7 f7                	div    %edi
  801845:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801848:	f7 f7                	div    %edi
  80184a:	eb a9                	jmp    8017f5 <__umoddi3+0x25>
  80184c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801850:	89 c8                	mov    %ecx,%eax
  801852:	89 f2                	mov    %esi,%edx
  801854:	83 c4 20             	add    $0x20,%esp
  801857:	5e                   	pop    %esi
  801858:	5f                   	pop    %edi
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    
  80185b:	90                   	nop
  80185c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801860:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801864:	d3 e2                	shl    %cl,%edx
  801866:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801869:	ba 20 00 00 00       	mov    $0x20,%edx
  80186e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801871:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801874:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801878:	89 fa                	mov    %edi,%edx
  80187a:	d3 ea                	shr    %cl,%edx
  80187c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801880:	0b 55 f4             	or     -0xc(%ebp),%edx
  801883:	d3 e7                	shl    %cl,%edi
  801885:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801889:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80188c:	89 f2                	mov    %esi,%edx
  80188e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801891:	89 c7                	mov    %eax,%edi
  801893:	d3 ea                	shr    %cl,%edx
  801895:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801899:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	d3 e6                	shl    %cl,%esi
  8018a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8018a4:	d3 ea                	shr    %cl,%edx
  8018a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8018aa:	09 d6                	or     %edx,%esi
  8018ac:	89 f0                	mov    %esi,%eax
  8018ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8018b1:	d3 e7                	shl    %cl,%edi
  8018b3:	89 f2                	mov    %esi,%edx
  8018b5:	f7 75 f4             	divl   -0xc(%ebp)
  8018b8:	89 d6                	mov    %edx,%esi
  8018ba:	f7 65 e8             	mull   -0x18(%ebp)
  8018bd:	39 d6                	cmp    %edx,%esi
  8018bf:	72 2b                	jb     8018ec <__umoddi3+0x11c>
  8018c1:	39 c7                	cmp    %eax,%edi
  8018c3:	72 23                	jb     8018e8 <__umoddi3+0x118>
  8018c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8018c9:	29 c7                	sub    %eax,%edi
  8018cb:	19 d6                	sbb    %edx,%esi
  8018cd:	89 f0                	mov    %esi,%eax
  8018cf:	89 f2                	mov    %esi,%edx
  8018d1:	d3 ef                	shr    %cl,%edi
  8018d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8018d7:	d3 e0                	shl    %cl,%eax
  8018d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8018dd:	09 f8                	or     %edi,%eax
  8018df:	d3 ea                	shr    %cl,%edx
  8018e1:	83 c4 20             	add    $0x20,%esp
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    
  8018e8:	39 d6                	cmp    %edx,%esi
  8018ea:	75 d9                	jne    8018c5 <__umoddi3+0xf5>
  8018ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8018ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8018f2:	eb d1                	jmp    8018c5 <__umoddi3+0xf5>
  8018f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018f8:	39 f2                	cmp    %esi,%edx
  8018fa:	0f 82 18 ff ff ff    	jb     801818 <__umoddi3+0x48>
  801900:	e9 1d ff ff ff       	jmp    801822 <__umoddi3+0x52>
