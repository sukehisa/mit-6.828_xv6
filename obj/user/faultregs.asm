
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 e7 04 00 00       	call   800518 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 75 10             	mov    0x10(%ebp),%esi
	int mismatch = 0;
  800043:	bf 00 00 00 00       	mov    $0x0,%edi

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800048:	ff 75 14             	pushl  0x14(%ebp)
  80004b:	ff 75 0c             	pushl  0xc(%ebp)
  80004e:	68 b1 14 80 00       	push   $0x8014b1
  800053:	68 80 14 80 00       	push   $0x801480
  800058:	e8 f3 05 00 00       	call   800650 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005d:	ff 36                	pushl  (%esi)
  80005f:	ff 33                	pushl  (%ebx)
  800061:	68 90 14 80 00       	push   $0x801490
  800066:	68 94 14 80 00       	push   $0x801494
  80006b:	e8 e0 05 00 00       	call   800650 <cprintf>
  800070:	83 c4 20             	add    $0x20,%esp
  800073:	8b 03                	mov    (%ebx),%eax
  800075:	3b 06                	cmp    (%esi),%eax
  800077:	75 12                	jne    80008b <check_regs+0x57>
  800079:	83 ec 0c             	sub    $0xc,%esp
  80007c:	68 a4 14 80 00       	push   $0x8014a4
  800081:	e8 ca 05 00 00       	call   800650 <cprintf>
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	eb 15                	jmp    8000a0 <check_regs+0x6c>
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	68 a8 14 80 00       	push   $0x8014a8
  800093:	e8 b8 05 00 00       	call   800650 <cprintf>
  800098:	bf 01 00 00 00       	mov    $0x1,%edi
  80009d:	83 c4 10             	add    $0x10,%esp
	CHECK(esi, regs.reg_esi);
  8000a0:	ff 76 04             	pushl  0x4(%esi)
  8000a3:	ff 73 04             	pushl  0x4(%ebx)
  8000a6:	68 b2 14 80 00       	push   $0x8014b2
  8000ab:	68 94 14 80 00       	push   $0x801494
  8000b0:	e8 9b 05 00 00       	call   800650 <cprintf>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000bb:	3b 46 04             	cmp    0x4(%esi),%eax
  8000be:	75 12                	jne    8000d2 <check_regs+0x9e>
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	68 a4 14 80 00       	push   $0x8014a4
  8000c8:	e8 83 05 00 00       	call   800650 <cprintf>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	eb 15                	jmp    8000e7 <check_regs+0xb3>
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	68 a8 14 80 00       	push   $0x8014a8
  8000da:	e8 71 05 00 00       	call   800650 <cprintf>
  8000df:	bf 01 00 00 00       	mov    $0x1,%edi
  8000e4:	83 c4 10             	add    $0x10,%esp
	CHECK(ebp, regs.reg_ebp);
  8000e7:	ff 76 08             	pushl  0x8(%esi)
  8000ea:	ff 73 08             	pushl  0x8(%ebx)
  8000ed:	68 b6 14 80 00       	push   $0x8014b6
  8000f2:	68 94 14 80 00       	push   $0x801494
  8000f7:	e8 54 05 00 00       	call   800650 <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8b 43 08             	mov    0x8(%ebx),%eax
  800102:	3b 46 08             	cmp    0x8(%esi),%eax
  800105:	75 12                	jne    800119 <check_regs+0xe5>
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	68 a4 14 80 00       	push   $0x8014a4
  80010f:	e8 3c 05 00 00       	call   800650 <cprintf>
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	eb 15                	jmp    80012e <check_regs+0xfa>
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	68 a8 14 80 00       	push   $0x8014a8
  800121:	e8 2a 05 00 00       	call   800650 <cprintf>
  800126:	bf 01 00 00 00       	mov    $0x1,%edi
  80012b:	83 c4 10             	add    $0x10,%esp
	CHECK(ebx, regs.reg_ebx);
  80012e:	ff 76 10             	pushl  0x10(%esi)
  800131:	ff 73 10             	pushl  0x10(%ebx)
  800134:	68 ba 14 80 00       	push   $0x8014ba
  800139:	68 94 14 80 00       	push   $0x801494
  80013e:	e8 0d 05 00 00       	call   800650 <cprintf>
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	8b 43 10             	mov    0x10(%ebx),%eax
  800149:	3b 46 10             	cmp    0x10(%esi),%eax
  80014c:	75 12                	jne    800160 <check_regs+0x12c>
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	68 a4 14 80 00       	push   $0x8014a4
  800156:	e8 f5 04 00 00       	call   800650 <cprintf>
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	eb 15                	jmp    800175 <check_regs+0x141>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	68 a8 14 80 00       	push   $0x8014a8
  800168:	e8 e3 04 00 00       	call   800650 <cprintf>
  80016d:	bf 01 00 00 00       	mov    $0x1,%edi
  800172:	83 c4 10             	add    $0x10,%esp
	CHECK(edx, regs.reg_edx);
  800175:	ff 76 14             	pushl  0x14(%esi)
  800178:	ff 73 14             	pushl  0x14(%ebx)
  80017b:	68 be 14 80 00       	push   $0x8014be
  800180:	68 94 14 80 00       	push   $0x801494
  800185:	e8 c6 04 00 00       	call   800650 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	8b 43 14             	mov    0x14(%ebx),%eax
  800190:	3b 46 14             	cmp    0x14(%esi),%eax
  800193:	75 12                	jne    8001a7 <check_regs+0x173>
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	68 a4 14 80 00       	push   $0x8014a4
  80019d:	e8 ae 04 00 00       	call   800650 <cprintf>
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	eb 15                	jmp    8001bc <check_regs+0x188>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	68 a8 14 80 00       	push   $0x8014a8
  8001af:	e8 9c 04 00 00       	call   800650 <cprintf>
  8001b4:	bf 01 00 00 00       	mov    $0x1,%edi
  8001b9:	83 c4 10             	add    $0x10,%esp
	CHECK(ecx, regs.reg_ecx);
  8001bc:	ff 76 18             	pushl  0x18(%esi)
  8001bf:	ff 73 18             	pushl  0x18(%ebx)
  8001c2:	68 c2 14 80 00       	push   $0x8014c2
  8001c7:	68 94 14 80 00       	push   $0x801494
  8001cc:	e8 7f 04 00 00       	call   800650 <cprintf>
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d7:	3b 46 18             	cmp    0x18(%esi),%eax
  8001da:	75 12                	jne    8001ee <check_regs+0x1ba>
  8001dc:	83 ec 0c             	sub    $0xc,%esp
  8001df:	68 a4 14 80 00       	push   $0x8014a4
  8001e4:	e8 67 04 00 00       	call   800650 <cprintf>
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	eb 15                	jmp    800203 <check_regs+0x1cf>
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	68 a8 14 80 00       	push   $0x8014a8
  8001f6:	e8 55 04 00 00       	call   800650 <cprintf>
  8001fb:	bf 01 00 00 00       	mov    $0x1,%edi
  800200:	83 c4 10             	add    $0x10,%esp
	CHECK(eax, regs.reg_eax);
  800203:	ff 76 1c             	pushl  0x1c(%esi)
  800206:	ff 73 1c             	pushl  0x1c(%ebx)
  800209:	68 c6 14 80 00       	push   $0x8014c6
  80020e:	68 94 14 80 00       	push   $0x801494
  800213:	e8 38 04 00 00       	call   800650 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80021e:	3b 46 1c             	cmp    0x1c(%esi),%eax
  800221:	75 12                	jne    800235 <check_regs+0x201>
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	68 a4 14 80 00       	push   $0x8014a4
  80022b:	e8 20 04 00 00       	call   800650 <cprintf>
  800230:	83 c4 10             	add    $0x10,%esp
  800233:	eb 15                	jmp    80024a <check_regs+0x216>
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	68 a8 14 80 00       	push   $0x8014a8
  80023d:	e8 0e 04 00 00       	call   800650 <cprintf>
  800242:	bf 01 00 00 00       	mov    $0x1,%edi
  800247:	83 c4 10             	add    $0x10,%esp
	CHECK(eip, eip);
  80024a:	ff 76 20             	pushl  0x20(%esi)
  80024d:	ff 73 20             	pushl  0x20(%ebx)
  800250:	68 ca 14 80 00       	push   $0x8014ca
  800255:	68 94 14 80 00       	push   $0x801494
  80025a:	e8 f1 03 00 00       	call   800650 <cprintf>
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8b 43 20             	mov    0x20(%ebx),%eax
  800265:	3b 46 20             	cmp    0x20(%esi),%eax
  800268:	75 12                	jne    80027c <check_regs+0x248>
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	68 a4 14 80 00       	push   $0x8014a4
  800272:	e8 d9 03 00 00       	call   800650 <cprintf>
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	eb 15                	jmp    800291 <check_regs+0x25d>
  80027c:	83 ec 0c             	sub    $0xc,%esp
  80027f:	68 a8 14 80 00       	push   $0x8014a8
  800284:	e8 c7 03 00 00       	call   800650 <cprintf>
  800289:	bf 01 00 00 00       	mov    $0x1,%edi
  80028e:	83 c4 10             	add    $0x10,%esp
	CHECK(eflags, eflags);
  800291:	ff 76 24             	pushl  0x24(%esi)
  800294:	ff 73 24             	pushl  0x24(%ebx)
  800297:	68 ce 14 80 00       	push   $0x8014ce
  80029c:	68 94 14 80 00       	push   $0x801494
  8002a1:	e8 aa 03 00 00       	call   800650 <cprintf>
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ac:	3b 46 24             	cmp    0x24(%esi),%eax
  8002af:	75 12                	jne    8002c3 <check_regs+0x28f>
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	68 a4 14 80 00       	push   $0x8014a4
  8002b9:	e8 92 03 00 00       	call   800650 <cprintf>
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	eb 15                	jmp    8002d8 <check_regs+0x2a4>
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	68 a8 14 80 00       	push   $0x8014a8
  8002cb:	e8 80 03 00 00       	call   800650 <cprintf>
  8002d0:	bf 01 00 00 00       	mov    $0x1,%edi
  8002d5:	83 c4 10             	add    $0x10,%esp
	CHECK(esp, esp);
  8002d8:	ff 76 28             	pushl  0x28(%esi)
  8002db:	ff 73 28             	pushl  0x28(%ebx)
  8002de:	68 d5 14 80 00       	push   $0x8014d5
  8002e3:	68 94 14 80 00       	push   $0x801494
  8002e8:	e8 63 03 00 00       	call   800650 <cprintf>
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f3:	3b 46 28             	cmp    0x28(%esi),%eax
  8002f6:	75 12                	jne    80030a <check_regs+0x2d6>
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	68 a4 14 80 00       	push   $0x8014a4
  800300:	e8 4b 03 00 00       	call   800650 <cprintf>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	eb 15                	jmp    80031f <check_regs+0x2eb>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 a8 14 80 00       	push   $0x8014a8
  800312:	e8 39 03 00 00       	call   800650 <cprintf>
  800317:	bf 01 00 00 00       	mov    $0x1,%edi
  80031c:	83 c4 10             	add    $0x10,%esp

#undef CHECK

	cprintf("Registers %s ", testname);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	ff 75 18             	pushl  0x18(%ebp)
  800325:	68 d9 14 80 00       	push   $0x8014d9
  80032a:	e8 21 03 00 00       	call   800650 <cprintf>
	if (!mismatch)
  80032f:	83 c4 10             	add    $0x10,%esp
  800332:	85 ff                	test   %edi,%edi
  800334:	75 12                	jne    800348 <check_regs+0x314>
		cprintf("OK\n");
  800336:	83 ec 0c             	sub    $0xc,%esp
  800339:	68 a4 14 80 00       	push   $0x8014a4
  80033e:	e8 0d 03 00 00       	call   800650 <cprintf>
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	eb 10                	jmp    800358 <check_regs+0x324>
	else
		cprintf("MISMATCH\n");
  800348:	83 ec 0c             	sub    $0xc,%esp
  80034b:	68 a8 14 80 00       	push   $0x8014a8
  800350:	e8 fb 02 00 00       	call   800650 <cprintf>
  800355:	83 c4 10             	add    $0x10,%esp
}
  800358:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035b:	5b                   	pop    %ebx
  80035c:	5e                   	pop    %esi
  80035d:	5f                   	pop    %edi
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	8b 55 08             	mov    0x8(%ebp),%edx
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  800368:	81 3a 00 00 40 00    	cmpl   $0x400000,(%edx)
  80036e:	74 19                	je     800389 <pgfault+0x29>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	ff 72 28             	pushl  0x28(%edx)
  800376:	ff 32                	pushl  (%edx)
  800378:	68 40 15 80 00       	push   $0x801540
  80037d:	6a 51                	push   $0x51
  80037f:	68 e7 14 80 00       	push   $0x8014e7
  800384:	e8 eb 01 00 00       	call   800574 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  800389:	bf 60 20 80 00       	mov    $0x802060,%edi
  80038e:	8d 72 08             	lea    0x8(%edx),%esi
  800391:	fc                   	cld    
  800392:	b9 08 00 00 00       	mov    $0x8,%ecx
  800397:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  800399:	8b 42 28             	mov    0x28(%edx),%eax
  80039c:	a3 80 20 80 00       	mov    %eax,0x802080
	during.eflags = utf->utf_eflags;
  8003a1:	8b 42 2c             	mov    0x2c(%edx),%eax
  8003a4:	a3 84 20 80 00       	mov    %eax,0x802084
	during.esp = utf->utf_esp;
  8003a9:	8b 42 30             	mov    0x30(%edx),%eax
  8003ac:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003b1:	83 ec 0c             	sub    $0xc,%esp
  8003b4:	68 f8 14 80 00       	push   $0x8014f8
  8003b9:	68 06 15 80 00       	push   $0x801506
  8003be:	68 60 20 80 00       	push   $0x802060
  8003c3:	68 0d 15 80 00       	push   $0x80150d
  8003c8:	68 20 20 80 00       	push   $0x802020
  8003cd:	e8 62 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8003d2:	83 c4 1c             	add    $0x1c,%esp
  8003d5:	6a 07                	push   $0x7
  8003d7:	68 00 00 40 00       	push   $0x400000
  8003dc:	6a 00                	push   $0x0
  8003de:	e8 63 0b 00 00       	call   800f46 <sys_page_alloc>
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	79 12                	jns    8003fc <pgfault+0x9c>
		panic("sys_page_alloc: %e", r);
  8003ea:	50                   	push   %eax
  8003eb:	68 14 15 80 00       	push   $0x801514
  8003f0:	6a 5c                	push   $0x5c
  8003f2:	68 e7 14 80 00       	push   $0x8014e7
  8003f7:	e8 78 01 00 00       	call   800574 <_panic>
}
  8003fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003ff:	5e                   	pop    %esi
  800400:	5f                   	pop    %edi
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <umain>:

void
umain(int argc, char **argv)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800409:	68 60 03 80 00       	push   $0x800360
  80040e:	e8 25 0d 00 00       	call   801138 <set_pgfault_handler>

	__asm __volatile(
  800413:	50                   	push   %eax
  800414:	9c                   	pushf  
  800415:	58                   	pop    %eax
  800416:	0d d5 08 00 00       	or     $0x8d5,%eax
  80041b:	50                   	push   %eax
  80041c:	9d                   	popf   
  80041d:	a3 44 20 80 00       	mov    %eax,0x802044
  800422:	8d 05 5d 04 80 00    	lea    0x80045d,%eax
  800428:	a3 40 20 80 00       	mov    %eax,0x802040
  80042d:	58                   	pop    %eax
  80042e:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800434:	89 35 24 20 80 00    	mov    %esi,0x802024
  80043a:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800440:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800446:	89 15 34 20 80 00    	mov    %edx,0x802034
  80044c:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800452:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800457:	89 25 48 20 80 00    	mov    %esp,0x802048
  80045d:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800464:	00 00 00 
  800467:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  80046d:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800473:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800479:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80047f:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800485:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80048b:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  800490:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800496:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  80049c:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8004a2:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8004a8:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  8004ae:	8b 15 34 20 80 00    	mov    0x802034,%edx
  8004b4:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  8004ba:	a1 3c 20 80 00       	mov    0x80203c,%eax
  8004bf:	8b 25 48 20 80 00    	mov    0x802048,%esp
  8004c5:	50                   	push   %eax
  8004c6:	9c                   	pushf  
  8004c7:	58                   	pop    %eax
  8004c8:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004cd:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8004d8:	74 10                	je     8004ea <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  8004da:	83 ec 0c             	sub    $0xc,%esp
  8004dd:	68 74 15 80 00       	push   $0x801574
  8004e2:	e8 69 01 00 00       	call   800650 <cprintf>
  8004e7:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8004ea:	a1 40 20 80 00       	mov    0x802040,%eax
  8004ef:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  8004f4:	83 ec 0c             	sub    $0xc,%esp
  8004f7:	68 27 15 80 00       	push   $0x801527
  8004fc:	68 38 15 80 00       	push   $0x801538
  800501:	68 a0 20 80 00       	push   $0x8020a0
  800506:	68 0d 15 80 00       	push   $0x80150d
  80050b:	68 20 20 80 00       	push   $0x802020
  800510:	e8 1f fb ff ff       	call   800034 <check_regs>
}
  800515:	c9                   	leave  
  800516:	c3                   	ret    
	...

00800518 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	56                   	push   %esi
  80051c:	53                   	push   %ebx
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800523:	e8 e0 09 00 00       	call   800f08 <sys_getenvid>
  800528:	25 ff 03 00 00       	and    $0x3ff,%eax
  80052d:	89 c2                	mov    %eax,%edx
  80052f:	c1 e2 05             	shl    $0x5,%edx
  800532:	29 c2                	sub    %eax,%edx
  800534:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80053b:	89 15 cc 20 80 00    	mov    %edx,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800541:	85 f6                	test   %esi,%esi
  800543:	7e 07                	jle    80054c <libmain+0x34>
		binaryname = argv[0];
  800545:	8b 03                	mov    (%ebx),%eax
  800547:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	56                   	push   %esi
  800551:	e8 ad fe ff ff       	call   800403 <umain>

	// exit gracefully
	exit();
  800556:	e8 09 00 00 00       	call   800564 <exit>
}
  80055b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80055e:	5b                   	pop    %ebx
  80055f:	5e                   	pop    %esi
  800560:	c9                   	leave  
  800561:	c3                   	ret    
	...

00800564 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80056a:	6a 00                	push   $0x0
  80056c:	e8 56 09 00 00       	call   800ec7 <sys_env_destroy>
}
  800571:	c9                   	leave  
  800572:	c3                   	ret    
	...

00800574 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	53                   	push   %ebx
  800578:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80057b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	ff 75 08             	pushl  0x8(%ebp)
  800584:	ff 35 00 20 80 00    	pushl  0x802000
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	e8 76 09 00 00       	call   800f08 <sys_getenvid>
  800592:	83 c4 08             	add    $0x8,%esp
  800595:	50                   	push   %eax
  800596:	68 a0 15 80 00       	push   $0x8015a0
  80059b:	e8 b0 00 00 00       	call   800650 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005a0:	83 c4 18             	add    $0x18,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	ff 75 10             	pushl  0x10(%ebp)
  8005a7:	e8 53 00 00 00       	call   8005ff <vcprintf>
	cprintf("\n");
  8005ac:	c7 04 24 b0 14 80 00 	movl   $0x8014b0,(%esp)
  8005b3:	e8 98 00 00 00       	call   800650 <cprintf>

	// Cause a breakpoint exception
	while (1)
  8005b8:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8005bb:	cc                   	int3   
  8005bc:	eb fd                	jmp    8005bb <_panic+0x47>
	...

008005c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	53                   	push   %ebx
  8005c4:	83 ec 04             	sub    $0x4,%esp
  8005c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005ca:	8b 03                	mov    (%ebx),%eax
  8005cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cf:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8005d3:	40                   	inc    %eax
  8005d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005db:	75 1a                	jne    8005f7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	68 ff 00 00 00       	push   $0xff
  8005e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8005e8:	50                   	push   %eax
  8005e9:	e8 96 08 00 00       	call   800e84 <sys_cputs>
		b->idx = 0;
  8005ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8005f7:	ff 43 04             	incl   0x4(%ebx)
}
  8005fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005fd:	c9                   	leave  
  8005fe:	c3                   	ret    

008005ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800608:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80060f:	00 00 00 
	b.cnt = 0;
  800612:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800619:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80061c:	ff 75 0c             	pushl  0xc(%ebp)
  80061f:	ff 75 08             	pushl  0x8(%ebp)
  800622:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	68 c0 05 80 00       	push   $0x8005c0
  80062e:	e8 49 01 00 00       	call   80077c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80063c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800642:	50                   	push   %eax
  800643:	e8 3c 08 00 00       	call   800e84 <sys_cputs>

	return b.cnt;
  800648:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80064e:	c9                   	leave  
  80064f:	c3                   	ret    

00800650 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800656:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800659:	50                   	push   %eax
  80065a:	ff 75 08             	pushl  0x8(%ebp)
  80065d:	e8 9d ff ff ff       	call   8005ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800662:	c9                   	leave  
  800663:	c3                   	ret    

00800664 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	57                   	push   %edi
  800668:	56                   	push   %esi
  800669:	53                   	push   %ebx
  80066a:	83 ec 0c             	sub    $0xc,%esp
  80066d:	8b 75 10             	mov    0x10(%ebp),%esi
  800670:	8b 7d 14             	mov    0x14(%ebp),%edi
  800673:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800676:	8b 45 18             	mov    0x18(%ebp),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	39 fa                	cmp    %edi,%edx
  800680:	77 39                	ja     8006bb <printnum+0x57>
  800682:	72 04                	jb     800688 <printnum+0x24>
  800684:	39 f0                	cmp    %esi,%eax
  800686:	77 33                	ja     8006bb <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800688:	83 ec 04             	sub    $0x4,%esp
  80068b:	ff 75 20             	pushl  0x20(%ebp)
  80068e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800691:	50                   	push   %eax
  800692:	ff 75 18             	pushl  0x18(%ebp)
  800695:	8b 45 18             	mov    0x18(%ebp),%eax
  800698:	ba 00 00 00 00       	mov    $0x0,%edx
  80069d:	52                   	push   %edx
  80069e:	50                   	push   %eax
  80069f:	57                   	push   %edi
  8006a0:	56                   	push   %esi
  8006a1:	e8 0e 0b 00 00       	call   8011b4 <__udivdi3>
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	52                   	push   %edx
  8006aa:	50                   	push   %eax
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	ff 75 08             	pushl  0x8(%ebp)
  8006b1:	e8 ae ff ff ff       	call   800664 <printnum>
  8006b6:	83 c4 20             	add    $0x20,%esp
  8006b9:	eb 19                	jmp    8006d4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006bb:	4b                   	dec    %ebx
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	7e 14                	jle    8006d4 <printnum+0x70>
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	ff 75 0c             	pushl  0xc(%ebp)
  8006c6:	ff 75 20             	pushl  0x20(%ebp)
  8006c9:	ff 55 08             	call   *0x8(%ebp)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	4b                   	dec    %ebx
  8006d0:	85 db                	test   %ebx,%ebx
  8006d2:	7f ec                	jg     8006c0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	8b 45 18             	mov    0x18(%ebp),%eax
  8006dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e2:	83 ec 04             	sub    $0x4,%esp
  8006e5:	52                   	push   %edx
  8006e6:	50                   	push   %eax
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	e8 d2 0b 00 00       	call   8012c0 <__umoddi3>
  8006ee:	83 c4 14             	add    $0x14,%esp
  8006f1:	0f be 80 d5 16 80 00 	movsbl 0x8016d5(%eax),%eax
  8006f8:	50                   	push   %eax
  8006f9:	ff 55 08             	call   *0x8(%ebp)
}
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80070d:	83 f8 01             	cmp    $0x1,%eax
  800710:	7e 0e                	jle    800720 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800712:	8b 11                	mov    (%ecx),%edx
  800714:	8d 42 08             	lea    0x8(%edx),%eax
  800717:	89 01                	mov    %eax,(%ecx)
  800719:	8b 02                	mov    (%edx),%eax
  80071b:	8b 52 04             	mov    0x4(%edx),%edx
  80071e:	eb 22                	jmp    800742 <getuint+0x3e>
	else if (lflag)
  800720:	85 c0                	test   %eax,%eax
  800722:	74 10                	je     800734 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800724:	8b 11                	mov    (%ecx),%edx
  800726:	8d 42 04             	lea    0x4(%edx),%eax
  800729:	89 01                	mov    %eax,(%ecx)
  80072b:	8b 02                	mov    (%edx),%eax
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	eb 0e                	jmp    800742 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800734:	8b 11                	mov    (%ecx),%edx
  800736:	8d 42 04             	lea    0x4(%edx),%eax
  800739:	89 01                	mov    %eax,(%ecx)
  80073b:	8b 02                	mov    (%edx),%eax
  80073d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80074d:	83 f8 01             	cmp    $0x1,%eax
  800750:	7e 0e                	jle    800760 <getint+0x1c>
		return va_arg(*ap, long long);
  800752:	8b 11                	mov    (%ecx),%edx
  800754:	8d 42 08             	lea    0x8(%edx),%eax
  800757:	89 01                	mov    %eax,(%ecx)
  800759:	8b 02                	mov    (%edx),%eax
  80075b:	8b 52 04             	mov    0x4(%edx),%edx
  80075e:	eb 1a                	jmp    80077a <getint+0x36>
	else if (lflag)
  800760:	85 c0                	test   %eax,%eax
  800762:	74 0c                	je     800770 <getint+0x2c>
		return va_arg(*ap, long);
  800764:	8b 01                	mov    (%ecx),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 11                	mov    %edx,(%ecx)
  80076b:	8b 00                	mov    (%eax),%eax
  80076d:	99                   	cltd   
  80076e:	eb 0a                	jmp    80077a <getint+0x36>
	else
		return va_arg(*ap, int);
  800770:	8b 01                	mov    (%ecx),%eax
  800772:	8d 50 04             	lea    0x4(%eax),%edx
  800775:	89 11                	mov    %edx,(%ecx)
  800777:	8b 00                	mov    (%eax),%eax
  800779:	99                   	cltd   
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	57                   	push   %edi
  800780:	56                   	push   %esi
  800781:	53                   	push   %ebx
  800782:	83 ec 1c             	sub    $0x1c,%esp
  800785:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800788:	0f b6 0b             	movzbl (%ebx),%ecx
  80078b:	43                   	inc    %ebx
  80078c:	83 f9 25             	cmp    $0x25,%ecx
  80078f:	74 1e                	je     8007af <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800791:	85 c9                	test   %ecx,%ecx
  800793:	0f 84 dc 02 00 00    	je     800a75 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	ff 75 0c             	pushl  0xc(%ebp)
  80079f:	51                   	push   %ecx
  8007a0:	ff 55 08             	call   *0x8(%ebp)
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	0f b6 0b             	movzbl (%ebx),%ecx
  8007a9:	43                   	inc    %ebx
  8007aa:	83 f9 25             	cmp    $0x25,%ecx
  8007ad:	75 e2                	jne    800791 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8007af:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8007b3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8007ba:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8007bf:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8007c4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cb:	0f b6 0b             	movzbl (%ebx),%ecx
  8007ce:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8007d1:	43                   	inc    %ebx
  8007d2:	83 f8 55             	cmp    $0x55,%eax
  8007d5:	0f 87 75 02 00 00    	ja     800a50 <vprintfmt+0x2d4>
  8007db:	ff 24 85 60 17 80 00 	jmp    *0x801760(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8007e2:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8007e6:	eb e3                	jmp    8007cb <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007e8:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8007ec:	eb dd                	jmp    8007cb <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007ee:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8007f3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8007f6:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8007fa:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8007fd:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800800:	83 f8 09             	cmp    $0x9,%eax
  800803:	77 28                	ja     80082d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800805:	43                   	inc    %ebx
  800806:	eb eb                	jmp    8007f3 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800808:	8b 55 14             	mov    0x14(%ebp),%edx
  80080b:	8d 42 04             	lea    0x4(%edx),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
  800811:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800813:	eb 18                	jmp    80082d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800815:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800819:	79 b0                	jns    8007cb <vprintfmt+0x4f>
				width = 0;
  80081b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800822:	eb a7                	jmp    8007cb <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800824:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80082b:	eb 9e                	jmp    8007cb <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80082d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800831:	79 98                	jns    8007cb <vprintfmt+0x4f>
				width = precision, precision = -1;
  800833:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800836:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80083b:	eb 8e                	jmp    8007cb <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80083d:	47                   	inc    %edi
			goto reswitch;
  80083e:	eb 8b                	jmp    8007cb <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	8b 55 14             	mov    0x14(%ebp),%edx
  800849:	8d 42 04             	lea    0x4(%edx),%eax
  80084c:	89 45 14             	mov    %eax,0x14(%ebp)
  80084f:	ff 32                	pushl  (%edx)
  800851:	ff 55 08             	call   *0x8(%ebp)
			break;
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	e9 2c ff ff ff       	jmp    800788 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085c:	8b 55 14             	mov    0x14(%ebp),%edx
  80085f:	8d 42 04             	lea    0x4(%edx),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)
  800865:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800867:	85 c0                	test   %eax,%eax
  800869:	79 02                	jns    80086d <vprintfmt+0xf1>
				err = -err;
  80086b:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086d:	83 f8 0f             	cmp    $0xf,%eax
  800870:	7f 0b                	jg     80087d <vprintfmt+0x101>
  800872:	8b 3c 85 20 17 80 00 	mov    0x801720(,%eax,4),%edi
  800879:	85 ff                	test   %edi,%edi
  80087b:	75 19                	jne    800896 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  80087d:	50                   	push   %eax
  80087e:	68 e6 16 80 00       	push   $0x8016e6
  800883:	ff 75 0c             	pushl  0xc(%ebp)
  800886:	ff 75 08             	pushl  0x8(%ebp)
  800889:	e8 ef 01 00 00       	call   800a7d <printfmt>
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	e9 f2 fe ff ff       	jmp    800788 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800896:	57                   	push   %edi
  800897:	68 ef 16 80 00       	push   $0x8016ef
  80089c:	ff 75 0c             	pushl  0xc(%ebp)
  80089f:	ff 75 08             	pushl  0x8(%ebp)
  8008a2:	e8 d6 01 00 00       	call   800a7d <printfmt>
  8008a7:	83 c4 10             	add    $0x10,%esp
			break;
  8008aa:	e9 d9 fe ff ff       	jmp    800788 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008af:	8b 55 14             	mov    0x14(%ebp),%edx
  8008b2:	8d 42 04             	lea    0x4(%edx),%eax
  8008b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b8:	8b 3a                	mov    (%edx),%edi
  8008ba:	85 ff                	test   %edi,%edi
  8008bc:	75 05                	jne    8008c3 <vprintfmt+0x147>
				p = "(null)";
  8008be:	bf f2 16 80 00       	mov    $0x8016f2,%edi
			if (width > 0 && padc != '-')
  8008c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008c7:	7e 3b                	jle    800904 <vprintfmt+0x188>
  8008c9:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8008cd:	74 35                	je     800904 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	56                   	push   %esi
  8008d3:	57                   	push   %edi
  8008d4:	e8 58 02 00 00       	call   800b31 <strnlen>
  8008d9:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008e3:	7e 1f                	jle    800904 <vprintfmt+0x188>
  8008e5:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8008e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	ff 75 0c             	pushl  0xc(%ebp)
  8008f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	ff 4d f0             	decl   -0x10(%ebp)
  8008fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800902:	7f e8                	jg     8008ec <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800904:	0f be 0f             	movsbl (%edi),%ecx
  800907:	47                   	inc    %edi
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 44                	je     800950 <vprintfmt+0x1d4>
  80090c:	85 f6                	test   %esi,%esi
  80090e:	78 03                	js     800913 <vprintfmt+0x197>
  800910:	4e                   	dec    %esi
  800911:	78 3d                	js     800950 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800913:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800917:	74 18                	je     800931 <vprintfmt+0x1b5>
  800919:	8d 41 e0             	lea    -0x20(%ecx),%eax
  80091c:	83 f8 5e             	cmp    $0x5e,%eax
  80091f:	76 10                	jbe    800931 <vprintfmt+0x1b5>
					putch('?', putdat);
  800921:	83 ec 08             	sub    $0x8,%esp
  800924:	ff 75 0c             	pushl  0xc(%ebp)
  800927:	6a 3f                	push   $0x3f
  800929:	ff 55 08             	call   *0x8(%ebp)
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	eb 0d                	jmp    80093e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	ff 75 0c             	pushl  0xc(%ebp)
  800937:	51                   	push   %ecx
  800938:	ff 55 08             	call   *0x8(%ebp)
  80093b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093e:	ff 4d f0             	decl   -0x10(%ebp)
  800941:	0f be 0f             	movsbl (%edi),%ecx
  800944:	47                   	inc    %edi
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 07                	je     800950 <vprintfmt+0x1d4>
  800949:	85 f6                	test   %esi,%esi
  80094b:	78 c6                	js     800913 <vprintfmt+0x197>
  80094d:	4e                   	dec    %esi
  80094e:	79 c3                	jns    800913 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800954:	0f 8e 2e fe ff ff    	jle    800788 <vprintfmt+0xc>
				putch(' ', putdat);
  80095a:	83 ec 08             	sub    $0x8,%esp
  80095d:	ff 75 0c             	pushl  0xc(%ebp)
  800960:	6a 20                	push   $0x20
  800962:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800965:	83 c4 10             	add    $0x10,%esp
  800968:	ff 4d f0             	decl   -0x10(%ebp)
  80096b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80096f:	7f e9                	jg     80095a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800971:	e9 12 fe ff ff       	jmp    800788 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800976:	57                   	push   %edi
  800977:	8d 45 14             	lea    0x14(%ebp),%eax
  80097a:	50                   	push   %eax
  80097b:	e8 c4 fd ff ff       	call   800744 <getint>
  800980:	89 c6                	mov    %eax,%esi
  800982:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800984:	83 c4 08             	add    $0x8,%esp
  800987:	85 d2                	test   %edx,%edx
  800989:	79 15                	jns    8009a0 <vprintfmt+0x224>
				putch('-', putdat);
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	ff 75 0c             	pushl  0xc(%ebp)
  800991:	6a 2d                	push   $0x2d
  800993:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800996:	f7 de                	neg    %esi
  800998:	83 d7 00             	adc    $0x0,%edi
  80099b:	f7 df                	neg    %edi
  80099d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009a0:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8009a5:	eb 76                	jmp    800a1d <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a7:	57                   	push   %edi
  8009a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ab:	50                   	push   %eax
  8009ac:	e8 53 fd ff ff       	call   800704 <getuint>
  8009b1:	89 c6                	mov    %eax,%esi
  8009b3:	89 d7                	mov    %edx,%edi
			base = 10;
  8009b5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8009ba:	83 c4 08             	add    $0x8,%esp
  8009bd:	eb 5e                	jmp    800a1d <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009bf:	57                   	push   %edi
  8009c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c3:	50                   	push   %eax
  8009c4:	e8 3b fd ff ff       	call   800704 <getuint>
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	89 d7                	mov    %edx,%edi
			base = 8;
  8009cd:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8009d2:	83 c4 08             	add    $0x8,%esp
  8009d5:	eb 46                	jmp    800a1d <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8009d7:	83 ec 08             	sub    $0x8,%esp
  8009da:	ff 75 0c             	pushl  0xc(%ebp)
  8009dd:	6a 30                	push   $0x30
  8009df:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009e2:	83 c4 08             	add    $0x8,%esp
  8009e5:	ff 75 0c             	pushl  0xc(%ebp)
  8009e8:	6a 78                	push   $0x78
  8009ea:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8009ed:	8b 55 14             	mov    0x14(%ebp),%edx
  8009f0:	8d 42 04             	lea    0x4(%edx),%eax
  8009f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8009f6:	8b 32                	mov    (%edx),%esi
  8009f8:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009fd:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800a02:	83 c4 10             	add    $0x10,%esp
  800a05:	eb 16                	jmp    800a1d <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a07:	57                   	push   %edi
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	50                   	push   %eax
  800a0c:	e8 f3 fc ff ff       	call   800704 <getuint>
  800a11:	89 c6                	mov    %eax,%esi
  800a13:	89 d7                	mov    %edx,%edi
			base = 16;
  800a15:	ba 10 00 00 00       	mov    $0x10,%edx
  800a1a:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a1d:	83 ec 04             	sub    $0x4,%esp
  800a20:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800a24:	50                   	push   %eax
  800a25:	ff 75 f0             	pushl  -0x10(%ebp)
  800a28:	52                   	push   %edx
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	e8 2e fc ff ff       	call   800664 <printnum>
			break;
  800a36:	83 c4 20             	add    $0x20,%esp
  800a39:	e9 4a fd ff ff       	jmp    800788 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a3e:	83 ec 08             	sub    $0x8,%esp
  800a41:	ff 75 0c             	pushl  0xc(%ebp)
  800a44:	51                   	push   %ecx
  800a45:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	e9 38 fd ff ff       	jmp    800788 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a50:	83 ec 08             	sub    $0x8,%esp
  800a53:	ff 75 0c             	pushl  0xc(%ebp)
  800a56:	6a 25                	push   $0x25
  800a58:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a5b:	4b                   	dec    %ebx
  800a5c:	83 c4 10             	add    $0x10,%esp
  800a5f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a63:	0f 84 1f fd ff ff    	je     800788 <vprintfmt+0xc>
  800a69:	4b                   	dec    %ebx
  800a6a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a6e:	75 f9                	jne    800a69 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800a70:	e9 13 fd ff ff       	jmp    800788 <vprintfmt+0xc>
		}
	}
}
  800a75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800a83:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a86:	50                   	push   %eax
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 e7 fc ff ff       	call   80077c <vprintfmt>
	va_end(ap);
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800a9d:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800aa0:	8b 0a                	mov    (%edx),%ecx
  800aa2:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800aa5:	73 07                	jae    800aae <sprintputch+0x17>
		*b->buf++ = ch;
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	88 01                	mov    %al,(%ecx)
  800aac:	ff 02                	incl   (%edx)
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	83 ec 18             	sub    $0x18,%esp
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800abc:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800abf:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ac6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800acd:	85 d2                	test   %edx,%edx
  800acf:	74 04                	je     800ad5 <vsnprintf+0x25>
  800ad1:	85 c9                	test   %ecx,%ecx
  800ad3:	7f 07                	jg     800adc <vsnprintf+0x2c>
		return -E_INVAL;
  800ad5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ada:	eb 1d                	jmp    800af9 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800adc:	ff 75 14             	pushl  0x14(%ebp)
  800adf:	ff 75 10             	pushl  0x10(%ebp)
  800ae2:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800ae5:	50                   	push   %eax
  800ae6:	68 97 0a 80 00       	push   $0x800a97
  800aeb:	e8 8c fc ff ff       	call   80077c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800af3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b04:	50                   	push   %eax
  800b05:	ff 75 10             	pushl  0x10(%ebp)
  800b08:	ff 75 0c             	pushl  0xc(%ebp)
  800b0b:	ff 75 08             	pushl  0x8(%ebp)
  800b0e:	e8 9d ff ff ff       	call   800ab0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b13:	c9                   	leave  
  800b14:	c3                   	ret    
  800b15:	00 00                	add    %al,(%eax)
	...

00800b18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	80 3a 00             	cmpb   $0x0,(%edx)
  800b26:	74 07                	je     800b2f <strlen+0x17>
		n++;
  800b28:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b29:	42                   	inc    %edx
  800b2a:	80 3a 00             	cmpb   $0x0,(%edx)
  800b2d:	75 f9                	jne    800b28 <strlen+0x10>
		n++;
	return n;
}
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	85 d2                	test   %edx,%edx
  800b41:	74 0f                	je     800b52 <strnlen+0x21>
  800b43:	80 39 00             	cmpb   $0x0,(%ecx)
  800b46:	74 0a                	je     800b52 <strnlen+0x21>
		n++;
  800b48:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b49:	41                   	inc    %ecx
  800b4a:	4a                   	dec    %edx
  800b4b:	74 05                	je     800b52 <strnlen+0x21>
  800b4d:	80 39 00             	cmpb   $0x0,(%ecx)
  800b50:	75 f6                	jne    800b48 <strnlen+0x17>
		n++;
	return n;
}
  800b52:	c9                   	leave  
  800b53:	c3                   	ret    

00800b54 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	53                   	push   %ebx
  800b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800b5e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800b60:	8a 02                	mov    (%edx),%al
  800b62:	42                   	inc    %edx
  800b63:	88 01                	mov    %al,(%ecx)
  800b65:	41                   	inc    %ecx
  800b66:	84 c0                	test   %al,%al
  800b68:	75 f6                	jne    800b60 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b6a:	89 d8                	mov    %ebx,%eax
  800b6c:	5b                   	pop    %ebx
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	53                   	push   %ebx
  800b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b76:	53                   	push   %ebx
  800b77:	e8 9c ff ff ff       	call   800b18 <strlen>
	strcpy(dst + len, src);
  800b7c:	ff 75 0c             	pushl  0xc(%ebp)
  800b7f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b82:	50                   	push   %eax
  800b83:	e8 cc ff ff ff       	call   800b54 <strcpy>
	return dst;
}
  800b88:	89 d8                	mov    %ebx,%eax
  800b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800b9e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800ba0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba5:	39 f3                	cmp    %esi,%ebx
  800ba7:	73 10                	jae    800bb9 <strncpy+0x2a>
		*dst++ = *src;
  800ba9:	8a 02                	mov    (%edx),%al
  800bab:	88 01                	mov    %al,(%ecx)
  800bad:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bae:	80 3a 01             	cmpb   $0x1,(%edx)
  800bb1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb4:	43                   	inc    %ebx
  800bb5:	39 f3                	cmp    %esi,%ebx
  800bb7:	72 f0                	jb     800ba9 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bb9:	89 f8                	mov    %edi,%eax
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800bce:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800bd0:	85 d2                	test   %edx,%edx
  800bd2:	74 19                	je     800bed <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bd4:	4a                   	dec    %edx
  800bd5:	74 13                	je     800bea <strlcpy+0x2a>
  800bd7:	80 39 00             	cmpb   $0x0,(%ecx)
  800bda:	74 0e                	je     800bea <strlcpy+0x2a>
  800bdc:	8a 01                	mov    (%ecx),%al
  800bde:	41                   	inc    %ecx
  800bdf:	88 03                	mov    %al,(%ebx)
  800be1:	43                   	inc    %ebx
  800be2:	4a                   	dec    %edx
  800be3:	74 05                	je     800bea <strlcpy+0x2a>
  800be5:	80 39 00             	cmpb   $0x0,(%ecx)
  800be8:	75 f2                	jne    800bdc <strlcpy+0x1c>
		*dst = '\0';
  800bea:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800bed:	89 d8                	mov    %ebx,%eax
  800bef:	29 f0                	sub    %esi,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800bfe:	80 3a 00             	cmpb   $0x0,(%edx)
  800c01:	74 13                	je     800c16 <strcmp+0x21>
  800c03:	8a 02                	mov    (%edx),%al
  800c05:	3a 01                	cmp    (%ecx),%al
  800c07:	75 0d                	jne    800c16 <strcmp+0x21>
  800c09:	42                   	inc    %edx
  800c0a:	41                   	inc    %ecx
  800c0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c0e:	74 06                	je     800c16 <strcmp+0x21>
  800c10:	8a 02                	mov    (%edx),%al
  800c12:	3a 01                	cmp    (%ecx),%al
  800c14:	74 f3                	je     800c09 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c16:	0f b6 02             	movzbl (%edx),%eax
  800c19:	0f b6 11             	movzbl (%ecx),%edx
  800c1c:	29 d0                	sub    %edx,%eax
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	53                   	push   %ebx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800c2d:	85 c9                	test   %ecx,%ecx
  800c2f:	74 1f                	je     800c50 <strncmp+0x30>
  800c31:	80 3a 00             	cmpb   $0x0,(%edx)
  800c34:	74 16                	je     800c4c <strncmp+0x2c>
  800c36:	8a 02                	mov    (%edx),%al
  800c38:	3a 03                	cmp    (%ebx),%al
  800c3a:	75 10                	jne    800c4c <strncmp+0x2c>
  800c3c:	42                   	inc    %edx
  800c3d:	43                   	inc    %ebx
  800c3e:	49                   	dec    %ecx
  800c3f:	74 0f                	je     800c50 <strncmp+0x30>
  800c41:	80 3a 00             	cmpb   $0x0,(%edx)
  800c44:	74 06                	je     800c4c <strncmp+0x2c>
  800c46:	8a 02                	mov    (%edx),%al
  800c48:	3a 03                	cmp    (%ebx),%al
  800c4a:	74 f0                	je     800c3c <strncmp+0x1c>
	if (n == 0)
  800c4c:	85 c9                	test   %ecx,%ecx
  800c4e:	75 07                	jne    800c57 <strncmp+0x37>
		return 0;
  800c50:	b8 00 00 00 00       	mov    $0x0,%eax
  800c55:	eb 0a                	jmp    800c61 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c57:	0f b6 12             	movzbl (%edx),%edx
  800c5a:	0f b6 03             	movzbl (%ebx),%eax
  800c5d:	29 c2                	sub    %eax,%edx
  800c5f:	89 d0                	mov    %edx,%eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800c6d:	80 38 00             	cmpb   $0x0,(%eax)
  800c70:	74 0a                	je     800c7c <strchr+0x18>
		if (*s == c)
  800c72:	38 10                	cmp    %dl,(%eax)
  800c74:	74 0b                	je     800c81 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c76:	40                   	inc    %eax
  800c77:	80 38 00             	cmpb   $0x0,(%eax)
  800c7a:	75 f6                	jne    800c72 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800c8c:	80 38 00             	cmpb   $0x0,(%eax)
  800c8f:	74 0a                	je     800c9b <strfind+0x18>
		if (*s == c)
  800c91:	38 10                	cmp    %dl,(%eax)
  800c93:	74 06                	je     800c9b <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c95:	40                   	inc    %eax
  800c96:	80 38 00             	cmpb   $0x0,(%eax)
  800c99:	75 f6                	jne    800c91 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800ca7:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800ca9:	85 c9                	test   %ecx,%ecx
  800cab:	74 40                	je     800ced <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb3:	75 30                	jne    800ce5 <memset+0x48>
  800cb5:	f6 c1 03             	test   $0x3,%cl
  800cb8:	75 2b                	jne    800ce5 <memset+0x48>
		c &= 0xFF;
  800cba:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc4:	c1 e0 18             	shl    $0x18,%eax
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cca:	c1 e2 10             	shl    $0x10,%edx
  800ccd:	09 d0                	or     %edx,%eax
  800ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd2:	c1 e2 08             	shl    $0x8,%edx
  800cd5:	09 d0                	or     %edx,%eax
  800cd7:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800cda:	c1 e9 02             	shr    $0x2,%ecx
  800cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce0:	fc                   	cld    
  800ce1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce3:	eb 06                	jmp    800ceb <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	fc                   	cld    
  800ce9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ceb:	89 f8                	mov    %edi,%eax
}
  800ced:	5f                   	pop    %edi
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cfb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cfe:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d00:	39 c6                	cmp    %eax,%esi
  800d02:	73 34                	jae    800d38 <memmove+0x48>
  800d04:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d07:	39 c2                	cmp    %eax,%edx
  800d09:	76 2d                	jbe    800d38 <memmove+0x48>
		s += n;
  800d0b:	89 d6                	mov    %edx,%esi
		d += n;
  800d0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d10:	f6 c2 03             	test   $0x3,%dl
  800d13:	75 1b                	jne    800d30 <memmove+0x40>
  800d15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1b:	75 13                	jne    800d30 <memmove+0x40>
  800d1d:	f6 c1 03             	test   $0x3,%cl
  800d20:	75 0e                	jne    800d30 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800d22:	83 ef 04             	sub    $0x4,%edi
  800d25:	83 ee 04             	sub    $0x4,%esi
  800d28:	c1 e9 02             	shr    $0x2,%ecx
  800d2b:	fd                   	std    
  800d2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2e:	eb 05                	jmp    800d35 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d30:	4f                   	dec    %edi
  800d31:	4e                   	dec    %esi
  800d32:	fd                   	std    
  800d33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d35:	fc                   	cld    
  800d36:	eb 20                	jmp    800d58 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d3e:	75 15                	jne    800d55 <memmove+0x65>
  800d40:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d46:	75 0d                	jne    800d55 <memmove+0x65>
  800d48:	f6 c1 03             	test   $0x3,%cl
  800d4b:	75 08                	jne    800d55 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800d4d:	c1 e9 02             	shr    $0x2,%ecx
  800d50:	fc                   	cld    
  800d51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d53:	eb 03                	jmp    800d58 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d55:	fc                   	cld    
  800d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    

00800d5c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d5f:	ff 75 10             	pushl  0x10(%ebp)
  800d62:	ff 75 0c             	pushl  0xc(%ebp)
  800d65:	ff 75 08             	pushl  0x8(%ebp)
  800d68:	e8 83 ff ff ff       	call   800cf0 <memmove>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800d76:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d79:	8b 55 10             	mov    0x10(%ebp),%edx
  800d7c:	4a                   	dec    %edx
  800d7d:	83 fa ff             	cmp    $0xffffffff,%edx
  800d80:	74 1a                	je     800d9c <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800d82:	8a 01                	mov    (%ecx),%al
  800d84:	3a 03                	cmp    (%ebx),%al
  800d86:	74 0c                	je     800d94 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800d88:	0f b6 d0             	movzbl %al,%edx
  800d8b:	0f b6 03             	movzbl (%ebx),%eax
  800d8e:	29 c2                	sub    %eax,%edx
  800d90:	89 d0                	mov    %edx,%eax
  800d92:	eb 0d                	jmp    800da1 <memcmp+0x32>
		s1++, s2++;
  800d94:	41                   	inc    %ecx
  800d95:	43                   	inc    %ebx
  800d96:	4a                   	dec    %edx
  800d97:	83 fa ff             	cmp    $0xffffffff,%edx
  800d9a:	75 e6                	jne    800d82 <memcmp+0x13>
	}

	return 0;
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da1:	5b                   	pop    %ebx
  800da2:	c9                   	leave  
  800da3:	c3                   	ret    

00800da4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800db2:	39 d0                	cmp    %edx,%eax
  800db4:	73 09                	jae    800dbf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db6:	38 08                	cmp    %cl,(%eax)
  800db8:	74 05                	je     800dbf <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dba:	40                   	inc    %eax
  800dbb:	39 d0                	cmp    %edx,%eax
  800dbd:	72 f7                	jb     800db6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800dd0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800dda:	80 3a 20             	cmpb   $0x20,(%edx)
  800ddd:	74 05                	je     800de4 <strtol+0x23>
  800ddf:	80 3a 09             	cmpb   $0x9,(%edx)
  800de2:	75 0b                	jne    800def <strtol+0x2e>
  800de4:	42                   	inc    %edx
  800de5:	80 3a 20             	cmpb   $0x20,(%edx)
  800de8:	74 fa                	je     800de4 <strtol+0x23>
  800dea:	80 3a 09             	cmpb   $0x9,(%edx)
  800ded:	74 f5                	je     800de4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800def:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800df2:	75 03                	jne    800df7 <strtol+0x36>
		s++;
  800df4:	42                   	inc    %edx
  800df5:	eb 0b                	jmp    800e02 <strtol+0x41>
	else if (*s == '-')
  800df7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800dfa:	75 06                	jne    800e02 <strtol+0x41>
		s++, neg = 1;
  800dfc:	42                   	inc    %edx
  800dfd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e02:	85 c9                	test   %ecx,%ecx
  800e04:	74 05                	je     800e0b <strtol+0x4a>
  800e06:	83 f9 10             	cmp    $0x10,%ecx
  800e09:	75 15                	jne    800e20 <strtol+0x5f>
  800e0b:	80 3a 30             	cmpb   $0x30,(%edx)
  800e0e:	75 10                	jne    800e20 <strtol+0x5f>
  800e10:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e14:	75 0a                	jne    800e20 <strtol+0x5f>
		s += 2, base = 16;
  800e16:	83 c2 02             	add    $0x2,%edx
  800e19:	b9 10 00 00 00       	mov    $0x10,%ecx
  800e1e:	eb 14                	jmp    800e34 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800e20:	85 c9                	test   %ecx,%ecx
  800e22:	75 10                	jne    800e34 <strtol+0x73>
  800e24:	80 3a 30             	cmpb   $0x30,(%edx)
  800e27:	75 05                	jne    800e2e <strtol+0x6d>
		s++, base = 8;
  800e29:	42                   	inc    %edx
  800e2a:	b1 08                	mov    $0x8,%cl
  800e2c:	eb 06                	jmp    800e34 <strtol+0x73>
	else if (base == 0)
  800e2e:	85 c9                	test   %ecx,%ecx
  800e30:	75 02                	jne    800e34 <strtol+0x73>
		base = 10;
  800e32:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e34:	8a 02                	mov    (%edx),%al
  800e36:	83 e8 30             	sub    $0x30,%eax
  800e39:	3c 09                	cmp    $0x9,%al
  800e3b:	77 08                	ja     800e45 <strtol+0x84>
			dig = *s - '0';
  800e3d:	0f be 02             	movsbl (%edx),%eax
  800e40:	83 e8 30             	sub    $0x30,%eax
  800e43:	eb 20                	jmp    800e65 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800e45:	8a 02                	mov    (%edx),%al
  800e47:	83 e8 61             	sub    $0x61,%eax
  800e4a:	3c 19                	cmp    $0x19,%al
  800e4c:	77 08                	ja     800e56 <strtol+0x95>
			dig = *s - 'a' + 10;
  800e4e:	0f be 02             	movsbl (%edx),%eax
  800e51:	83 e8 57             	sub    $0x57,%eax
  800e54:	eb 0f                	jmp    800e65 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800e56:	8a 02                	mov    (%edx),%al
  800e58:	83 e8 41             	sub    $0x41,%eax
  800e5b:	3c 19                	cmp    $0x19,%al
  800e5d:	77 12                	ja     800e71 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800e5f:	0f be 02             	movsbl (%edx),%eax
  800e62:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800e65:	39 c8                	cmp    %ecx,%eax
  800e67:	7d 08                	jge    800e71 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e69:	42                   	inc    %edx
  800e6a:	0f af d9             	imul   %ecx,%ebx
  800e6d:	01 c3                	add    %eax,%ebx
  800e6f:	eb c3                	jmp    800e34 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e71:	85 f6                	test   %esi,%esi
  800e73:	74 02                	je     800e77 <strtol+0xb6>
		*endptr = (char *) s;
  800e75:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e77:	89 d8                	mov    %ebx,%eax
  800e79:	85 ff                	test   %edi,%edi
  800e7b:	74 02                	je     800e7f <strtol+0xbe>
  800e7d:	f7 d8                	neg    %eax
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e93:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	89 f8                	mov    %edi,%eax
  800e9a:	89 fb                	mov    %edi,%ebx
  800e9c:	89 fe                	mov    %edi,%esi
  800e9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea0:	83 c4 04             	add    $0x4,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eae:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb8:	89 fa                	mov    %edi,%edx
  800eba:	89 f9                	mov    %edi,%ecx
  800ebc:	89 fb                	mov    %edi,%ebx
  800ebe:	89 fe                	mov    %edi,%esi
  800ec0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ed3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed8:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	89 f9                	mov    %edi,%ecx
  800edf:	89 fb                	mov    %edi,%ebx
  800ee1:	89 fe                	mov    %edi,%esi
  800ee3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 03                	push   $0x3
  800eef:	68 b8 18 80 00       	push   $0x8018b8
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 d5 18 80 00       	push   $0x8018d5
  800efb:	e8 74 f6 ff ff       	call   800574 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f13:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	89 fa                	mov    %edi,%edx
  800f1a:	89 f9                	mov    %edi,%ecx
  800f1c:	89 fb                	mov    %edi,%ebx
  800f1e:	89 fe                	mov    %edi,%esi
  800f20:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <sys_yield>:

void
sys_yield(void)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f32:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f37:	89 fa                	mov    %edi,%edx
  800f39:	89 f9                	mov    %edi,%ecx
  800f3b:	89 fb                	mov    %edi,%ebx
  800f3d:	89 fe                	mov    %edi,%esi
  800f3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f58:	b8 04 00 00 00       	mov    $0x4,%eax
  800f5d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	89 fe                	mov    %edi,%esi
  800f64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 17                	jle    800f81 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	50                   	push   %eax
  800f6e:	6a 04                	push   $0x4
  800f70:	68 b8 18 80 00       	push   $0x8018b8
  800f75:	6a 23                	push   $0x23
  800f77:	68 d5 18 80 00       	push   $0x8018d5
  800f7c:	e8 f3 f5 ff ff       	call   800574 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9e:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800fa1:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 17                	jle    800fc3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	50                   	push   %eax
  800fb0:	6a 05                	push   $0x5
  800fb2:	68 b8 18 80 00       	push   $0x8018b8
  800fb7:	6a 23                	push   $0x23
  800fb9:	68 d5 18 80 00       	push   $0x8018d5
  800fbe:	e8 b1 f5 ff ff       	call   800574 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800fda:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	89 fb                	mov    %edi,%ebx
  800fe6:	89 fe                	mov    %edi,%esi
  800fe8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 17                	jle    801005 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	6a 06                	push   $0x6
  800ff4:	68 b8 18 80 00       	push   $0x8018b8
  800ff9:	6a 23                	push   $0x23
  800ffb:	68 d5 18 80 00       	push   $0x8018d5
  801000:	e8 6f f5 ff ff       	call   800574 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80101c:	b8 08 00 00 00       	mov    $0x8,%eax
  801021:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801026:	89 fb                	mov    %edi,%ebx
  801028:	89 fe                	mov    %edi,%esi
  80102a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	7e 17                	jle    801047 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	50                   	push   %eax
  801034:	6a 08                	push   $0x8
  801036:	68 b8 18 80 00       	push   $0x8018b8
  80103b:	6a 23                	push   $0x23
  80103d:	68 d5 18 80 00       	push   $0x8018d5
  801042:	e8 2d f5 ff ff       	call   800574 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80105e:	b8 09 00 00 00       	mov    $0x9,%eax
  801063:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801068:	89 fb                	mov    %edi,%ebx
  80106a:	89 fe                	mov    %edi,%esi
  80106c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	7e 17                	jle    801089 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	50                   	push   %eax
  801076:	6a 09                	push   $0x9
  801078:	68 b8 18 80 00       	push   $0x8018b8
  80107d:	6a 23                	push   $0x23
  80107f:	68 d5 18 80 00       	push   $0x8018d5
  801084:	e8 eb f4 ff ff       	call   800574 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	8b 55 08             	mov    0x8(%ebp),%edx
  80109d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8010a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a5:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010aa:	89 fb                	mov    %edi,%ebx
  8010ac:	89 fe                	mov    %edi,%esi
  8010ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	7e 17                	jle    8010cb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	50                   	push   %eax
  8010b8:	6a 0a                	push   $0xa
  8010ba:	68 b8 18 80 00       	push   $0x8018b8
  8010bf:	6a 23                	push   $0x23
  8010c1:	68 d5 18 80 00       	push   $0x8018d5
  8010c6:	e8 a9 f4 ff ff       	call   800574 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e2:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8010e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ea:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  801102:	b8 0d 00 00 00       	mov    $0xd,%eax
  801107:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110c:	89 f9                	mov    %edi,%ecx
  80110e:	89 fb                	mov    %edi,%ebx
  801110:	89 fe                	mov    %edi,%esi
  801112:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	7e 17                	jle    80112f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	50                   	push   %eax
  80111c:	6a 0d                	push   $0xd
  80111e:	68 b8 18 80 00       	push   $0x8018b8
  801123:	6a 23                	push   $0x23
  801125:	68 d5 18 80 00       	push   $0x8018d5
  80112a:	e8 45 f4 ff ff       	call   800574 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	c9                   	leave  
  801136:	c3                   	ret    
	...

00801138 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80113e:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801145:	75 35                	jne    80117c <set_pgfault_handler+0x44>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	6a 07                	push   $0x7
  80114c:	68 00 f0 bf ee       	push   $0xeebff000
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	e8 af fd ff ff       	call   800f08 <sys_getenvid>
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 e5 fd ff ff       	call   800f46 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	68 88 11 80 00       	push   $0x801188
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	e8 97 fd ff ff       	call   800f08 <sys_getenvid>
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 18 ff ff ff       	call   801091 <sys_env_set_pgfault_upcall>
  801179:	83 c4 10             	add    $0x10,%esp
//		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80117c:	8b 45 08             	mov    0x8(%ebp),%eax
  80117f:	a3 d0 20 80 00       	mov    %eax,0x8020d0
//	cprintf("_pgfault_upcall: %08x\n", thisenv->env_pgfault_upcall);
//	cprintf("_pgfault_handler is %08x\n", _pgfault_handler);
}
  801184:	c9                   	leave  
  801185:	c3                   	ret    
	...

00801188 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTrapframe
  801188:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801189:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80118e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801190:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  801193:	89 e3                	mov    %esp,%ebx

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp
	movl 48(%esp), %ecx
  801195:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// trap-time eip
	movl 40(%esp), %edx 
  801199:	8b 54 24 28          	mov    0x28(%esp),%edx
	// switch to trap-time esp 
	movl %ecx, %esp 
  80119d:	89 cc                	mov    %ecx,%esp
	// push trap-time eip to trap-time stack 
	pushl %edx 
  80119f:	52                   	push   %edx
	// return to user exception stack 
	movl %ebx, %esp 
  8011a0:	89 dc                	mov    %ebx,%esp
	// update the trap-time esp stored in exception stack(because of pushed eip
	subl $4, %ecx
  8011a2:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx, 48(%esp)
  8011a5:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// restore general registars, ignoring fault_va & err
	addl $8, %esp
  8011a9:	83 c4 08             	add    $0x8,%esp
	popal
  8011ac:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// skipping trap-time eip 
	addl $4, %esp
  8011ad:	83 c4 04             	add    $0x4,%esp
	// restore eflags
	popfl
  8011b0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011b1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  8011b2:	c3                   	ret    
	...

008011b4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	57                   	push   %edi
  8011b8:	56                   	push   %esi
  8011b9:	83 ec 14             	sub    $0x14,%esp
  8011bc:	8b 55 14             	mov    0x14(%ebp),%edx
  8011bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011c5:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011c8:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8011ca:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8011cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  8011d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  8011d3:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011d5:	75 11                	jne    8011e8 <__udivdi3+0x34>
    {
      if (d0 > n1)
  8011d7:	39 f8                	cmp    %edi,%eax
  8011d9:	76 4d                	jbe    801228 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011db:	89 fa                	mov    %edi,%edx
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	f7 75 e4             	divl   -0x1c(%ebp)
  8011e3:	89 c7                	mov    %eax,%edi
  8011e5:	eb 09                	jmp    8011f0 <__udivdi3+0x3c>
  8011e7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011e8:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  8011eb:	76 17                	jbe    801204 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  8011ed:	31 ff                	xor    %edi,%edi
  8011ef:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  8011f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011fa:	83 c4 14             	add    $0x14,%esp
  8011fd:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011fe:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801200:	5f                   	pop    %edi
  801201:	c9                   	leave  
  801202:	c3                   	ret    
  801203:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801204:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  801208:	89 c7                	mov    %eax,%edi
  80120a:	83 f7 1f             	xor    $0x1f,%edi
  80120d:	75 4d                	jne    80125c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80120f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801212:	77 0a                	ja     80121e <__udivdi3+0x6a>
  801214:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  801217:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801219:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80121c:	72 d2                	jb     8011f0 <__udivdi3+0x3c>
		{
		  q0 = 1;
  80121e:	bf 01 00 00 00       	mov    $0x1,%edi
  801223:	eb cb                	jmp    8011f0 <__udivdi3+0x3c>
  801225:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80122b:	85 c0                	test   %eax,%eax
  80122d:	75 0e                	jne    80123d <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80122f:	b8 01 00 00 00       	mov    $0x1,%eax
  801234:	31 c9                	xor    %ecx,%ecx
  801236:	31 d2                	xor    %edx,%edx
  801238:	f7 f1                	div    %ecx
  80123a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80123d:	89 f0                	mov    %esi,%eax
  80123f:	31 d2                	xor    %edx,%edx
  801241:	f7 75 e4             	divl   -0x1c(%ebp)
  801244:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80124d:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801250:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801253:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801255:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801256:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801258:	5f                   	pop    %edi
  801259:	c9                   	leave  
  80125a:	c3                   	ret    
  80125b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80125c:	b8 20 00 00 00       	mov    $0x20,%eax
  801261:	29 f8                	sub    %edi,%eax
  801263:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801266:	89 f9                	mov    %edi,%ecx
  801268:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126b:	d3 e2                	shl    %cl,%edx
  80126d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801270:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801273:	d3 e8                	shr    %cl,%eax
  801275:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  801277:	89 f9                	mov    %edi,%ecx
  801279:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80127c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80127f:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801282:	89 f2                	mov    %esi,%edx
  801284:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801286:	89 f9                	mov    %edi,%ecx
  801288:	d3 e6                	shl    %cl,%esi
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801290:	d3 e8                	shr    %cl,%eax
  801292:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  801294:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801296:	89 f0                	mov    %esi,%eax
  801298:	f7 75 f4             	divl   -0xc(%ebp)
  80129b:	89 d6                	mov    %edx,%esi
  80129d:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80129f:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8012a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012a5:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012a7:	39 f2                	cmp    %esi,%edx
  8012a9:	77 0f                	ja     8012ba <__udivdi3+0x106>
  8012ab:	0f 85 3f ff ff ff    	jne    8011f0 <__udivdi3+0x3c>
  8012b1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8012b4:	0f 86 36 ff ff ff    	jbe    8011f0 <__udivdi3+0x3c>
		{
		  q0--;
  8012ba:	4f                   	dec    %edi
  8012bb:	e9 30 ff ff ff       	jmp    8011f0 <__udivdi3+0x3c>

008012c0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	83 ec 30             	sub    $0x30,%esp
  8012c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012cb:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  8012ce:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8012d0:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8012d3:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  8012d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8012db:	85 ff                	test   %edi,%edi
  8012dd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8012e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8012eb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8012ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  8012f1:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8012f4:	75 3e                	jne    801334 <__umoddi3+0x74>
    {
      if (d0 > n1)
  8012f6:	39 d6                	cmp    %edx,%esi
  8012f8:	0f 86 a2 00 00 00    	jbe    8013a0 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012fe:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801300:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801303:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801305:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801308:	74 1b                	je     801325 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  80130a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80130d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  801310:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801317:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80131a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80131d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801320:	89 10                	mov    %edx,(%eax)
  801322:	89 48 04             	mov    %ecx,0x4(%eax)
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80132b:	83 c4 30             	add    $0x30,%esp
  80132e:	5e                   	pop    %esi
  80132f:	5f                   	pop    %edi
  801330:	c9                   	leave  
  801331:	c3                   	ret    
  801332:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801334:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  801337:	76 1f                	jbe    801358 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801339:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  80133c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  80133f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  801342:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801348:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80134b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80134e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801351:	83 c4 30             	add    $0x30,%esp
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	c9                   	leave  
  801357:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801358:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80135b:	83 f0 1f             	xor    $0x1f,%eax
  80135e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801361:	75 61                	jne    8013c4 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801363:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  801366:	77 05                	ja     80136d <__umoddi3+0xad>
  801368:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  80136b:	72 10                	jb     80137d <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80136d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801370:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801373:	29 f0                	sub    %esi,%eax
  801375:	19 fa                	sbb    %edi,%edx
  801377:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80137a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  80137d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801380:	85 d2                	test   %edx,%edx
  801382:	74 a1                	je     801325 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801384:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  801387:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  80138d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801390:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801393:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801399:	89 01                	mov    %eax,(%ecx)
  80139b:	89 51 04             	mov    %edx,0x4(%ecx)
  80139e:	eb 85                	jmp    801325 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8013a0:	85 f6                	test   %esi,%esi
  8013a2:	75 0b                	jne    8013af <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8013a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a9:	31 d2                	xor    %edx,%edx
  8013ab:	f7 f6                	div    %esi
  8013ad:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8013af:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8013b2:	89 fa                	mov    %edi,%edx
  8013b4:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8013b9:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013bc:	f7 f6                	div    %esi
  8013be:	e9 3d ff ff ff       	jmp    801300 <__umoddi3+0x40>
  8013c3:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8013c4:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c9:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  8013cc:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8013d4:	d3 e2                	shl    %cl,%edx
  8013d6:	89 f0                	mov    %esi,%eax
  8013d8:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8013db:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  8013dd:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8013e0:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013e2:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8013e4:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8013e7:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013ea:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8013ec:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8013ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8013f1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8013f4:	d3 e0                	shl    %cl,%eax
  8013f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013f9:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8013fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013ff:	d3 e8                	shr    %cl,%eax
  801401:	0b 45 cc             	or     -0x34(%ebp),%eax
  801404:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  801407:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80140a:	f7 f7                	div    %edi
  80140c:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80140f:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801412:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801414:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801417:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80141a:	77 0a                	ja     801426 <__umoddi3+0x166>
  80141c:	75 12                	jne    801430 <__umoddi3+0x170>
  80141e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801421:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801424:	76 0a                	jbe    801430 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801426:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801429:	29 f1                	sub    %esi,%ecx
  80142b:	19 fa                	sbb    %edi,%edx
  80142d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801430:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801433:	85 c0                	test   %eax,%eax
  801435:	0f 84 ea fe ff ff    	je     801325 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80143b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80143e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801441:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801444:	19 d1                	sbb    %edx,%ecx
  801446:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801449:	89 ca                	mov    %ecx,%edx
  80144b:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80144e:	d3 e2                	shl    %cl,%edx
  801450:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801453:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801456:	d3 e8                	shr    %cl,%eax
  801458:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80145a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80145d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80145f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801465:	e9 ad fe ff ff       	jmp    801317 <__umoddi3+0x57>
