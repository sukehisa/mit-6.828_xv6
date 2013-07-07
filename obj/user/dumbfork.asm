
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 bf 01 00 00       	call   8001f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800039:	e8 e4 00 00 00       	call   800122 <dumbfork>
  80003e:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
  800045:	eb 26                	jmp    80006d <umain+0x39>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800047:	83 ec 04             	sub    $0x4,%esp
  80004a:	b8 e0 10 80 00       	mov    $0x8010e0,%eax
  80004f:	85 f6                	test   %esi,%esi
  800051:	75 05                	jne    800058 <umain+0x24>
  800053:	b8 e7 10 80 00       	mov    $0x8010e7,%eax
  800058:	50                   	push   %eax
  800059:	53                   	push   %ebx
  80005a:	68 ed 10 80 00       	push   $0x8010ed
  80005f:	e8 c4 02 00 00       	call   800328 <cprintf>
		sys_yield();
  800064:	e8 96 0b 00 00       	call   800bff <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	43                   	inc    %ebx
  80006d:	85 f6                	test   %esi,%esi
  80006f:	74 07                	je     800078 <umain+0x44>
  800071:	83 fb 09             	cmp    $0x9,%ebx
  800074:	7e d1                	jle    800047 <umain+0x13>
  800076:	eb 05                	jmp    80007d <umain+0x49>
  800078:	83 fb 13             	cmp    $0x13,%ebx
  80007b:	7e ca                	jle    800047 <umain+0x13>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <duppage>:

/// dstenv: child's envid
void
duppage(envid_t dstenv, void *addr)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	8b 75 08             	mov    0x8(%ebp),%esi
  80008c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	6a 07                	push   $0x7
  800094:	53                   	push   %ebx
  800095:	56                   	push   %esi
  800096:	e8 83 0b 00 00       	call   800c1e <sys_page_alloc>
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 12                	jns    8000b4 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  8000a2:	50                   	push   %eax
  8000a3:	68 ff 10 80 00       	push   $0x8010ff
  8000a8:	6a 21                	push   $0x21
  8000aa:	68 12 11 80 00       	push   $0x801112
  8000af:	e8 98 01 00 00       	call   80024c <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8000b4:	83 ec 0c             	sub    $0xc,%esp
  8000b7:	6a 07                	push   $0x7
  8000b9:	68 00 00 40 00       	push   $0x400000
  8000be:	6a 00                	push   $0x0
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 9a 0b 00 00       	call   800c61 <sys_page_map>
  8000c7:	83 c4 20             	add    $0x20,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	79 12                	jns    8000e0 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  8000ce:	50                   	push   %eax
  8000cf:	68 22 11 80 00       	push   $0x801122
  8000d4:	6a 23                	push   $0x23
  8000d6:	68 12 11 80 00       	push   $0x801112
  8000db:	e8 6c 01 00 00       	call   80024c <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000e0:	83 ec 04             	sub    $0x4,%esp
  8000e3:	68 00 10 00 00       	push   $0x1000
  8000e8:	53                   	push   %ebx
  8000e9:	68 00 00 40 00       	push   $0x400000
  8000ee:	e8 d5 08 00 00       	call   8009c8 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	68 00 00 40 00       	push   $0x400000
  8000fb:	6a 00                	push   $0x0
  8000fd:	e8 a1 0b 00 00       	call   800ca3 <sys_page_unmap>
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	85 c0                	test   %eax,%eax
  800107:	79 12                	jns    80011b <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  800109:	50                   	push   %eax
  80010a:	68 33 11 80 00       	push   $0x801133
  80010f:	6a 26                	push   $0x26
  800111:	68 12 11 80 00       	push   $0x801112
  800116:	e8 31 01 00 00       	call   80024c <_panic>
}
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <dumbfork>:

envid_t
dumbfork(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	53                   	push   %ebx
  800126:	83 ec 04             	sub    $0x4,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800129:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  80012e:	89 d0                	mov    %edx,%eax
  800130:	cd 30                	int    $0x30
  800132:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800134:	85 c0                	test   %eax,%eax
  800136:	79 12                	jns    80014a <dumbfork+0x28>
		panic("sys_exofork: %e", envid);
  800138:	50                   	push   %eax
  800139:	68 46 11 80 00       	push   $0x801146
  80013e:	6a 38                	push   $0x38
  800140:	68 12 11 80 00       	push   $0x801112
  800145:	e8 02 01 00 00       	call   80024c <_panic>
	if (envid == 0) {
  80014a:	85 c0                	test   %eax,%eax
  80014c:	75 32                	jne    800180 <dumbfork+0x5e>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		cprintf("I'm child\n");
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	68 56 11 80 00       	push   $0x801156
  800156:	e8 cd 01 00 00       	call   800328 <cprintf>
		thisenv = &envs[ENVX(sys_getenvid())];
  80015b:	e8 80 0a 00 00       	call   800be0 <sys_getenvid>
  800160:	25 ff 03 00 00       	and    $0x3ff,%eax
  800165:	89 c2                	mov    %eax,%edx
  800167:	c1 e2 05             	shl    $0x5,%edx
  80016a:	29 c2                	sub    %eax,%edx
  80016c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800173:	89 15 04 20 80 00    	mov    %edx,0x802004
		return 0;
  800179:	ba 00 00 00 00       	mov    $0x0,%edx
  80017e:	eb 67                	jmp    8001e7 <dumbfork+0xc5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800180:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800187:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  80018e:	73 1f                	jae    8001af <dumbfork+0x8d>
		duppage(envid, addr);
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	ff 75 f8             	pushl  -0x8(%ebp)
  800196:	53                   	push   %ebx
  800197:	e8 e8 fe ff ff       	call   800084 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  8001a6:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  8001ad:	72 e1                	jb     800190 <dumbfork+0x6e>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001af:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8001b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	50                   	push   %eax
  8001bb:	53                   	push   %ebx
  8001bc:	e8 c3 fe ff ff       	call   800084 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001c1:	83 c4 08             	add    $0x8,%esp
  8001c4:	6a 02                	push   $0x2
  8001c6:	53                   	push   %ebx
  8001c7:	e8 19 0b 00 00       	call   800ce5 <sys_env_set_status>
  8001cc:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  8001cf:	89 da                	mov    %ebx,%edx

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	79 12                	jns    8001e7 <dumbfork+0xc5>
		panic("sys_env_set_status: %e", r);
  8001d5:	50                   	push   %eax
  8001d6:	68 61 11 80 00       	push   $0x801161
  8001db:	6a 4e                	push   $0x4e
  8001dd:	68 12 11 80 00       	push   $0x801112
  8001e2:	e8 65 00 00 00       	call   80024c <_panic>

	return envid;
}
  8001e7:	89 d0                	mov    %edx,%eax
  8001e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    
	...

008001f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8001fb:	e8 e0 09 00 00       	call   800be0 <sys_getenvid>
  800200:	25 ff 03 00 00       	and    $0x3ff,%eax
  800205:	89 c2                	mov    %eax,%edx
  800207:	c1 e2 05             	shl    $0x5,%edx
  80020a:	29 c2                	sub    %eax,%edx
  80020c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800213:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800219:	85 f6                	test   %esi,%esi
  80021b:	7e 07                	jle    800224 <libmain+0x34>
		binaryname = argv[0];
  80021d:	8b 03                	mov    (%ebx),%eax
  80021f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	53                   	push   %ebx
  800228:	56                   	push   %esi
  800229:	e8 06 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80022e:	e8 09 00 00 00       	call   80023c <exit>
}
  800233:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	c9                   	leave  
  800239:	c3                   	ret    
	...

0080023c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800242:	6a 00                	push   $0x0
  800244:	e8 56 09 00 00       	call   800b9f <sys_env_destroy>
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    
	...

0080024c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	53                   	push   %ebx
  800250:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800253:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800256:	ff 75 0c             	pushl  0xc(%ebp)
  800259:	ff 75 08             	pushl  0x8(%ebp)
  80025c:	ff 35 00 20 80 00    	pushl  0x802000
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	e8 76 09 00 00       	call   800be0 <sys_getenvid>
  80026a:	83 c4 08             	add    $0x8,%esp
  80026d:	50                   	push   %eax
  80026e:	68 84 11 80 00       	push   $0x801184
  800273:	e8 b0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	53                   	push   %ebx
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	e8 53 00 00 00       	call   8002d7 <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 fd 10 80 00 	movl   $0x8010fd,(%esp)
  80028b:	e8 98 00 00 00       	call   800328 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800290:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800293:	cc                   	int3   
  800294:	eb fd                	jmp    800293 <_panic+0x47>
	...

00800298 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	53                   	push   %ebx
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a2:	8b 03                	mov    (%ebx),%eax
  8002a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8002ab:	40                   	inc    %eax
  8002ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b3:	75 1a                	jne    8002cf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	68 ff 00 00 00       	push   $0xff
  8002bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c0:	50                   	push   %eax
  8002c1:	e8 96 08 00 00       	call   800b5c <sys_cputs>
		b->idx = 0;
  8002c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002cf:	ff 43 04             	incl   0x4(%ebx)
}
  8002d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e0:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8002e7:	00 00 00 
	b.cnt = 0;
  8002ea:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8002f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f4:	ff 75 0c             	pushl  0xc(%ebp)
  8002f7:	ff 75 08             	pushl  0x8(%ebp)
  8002fa:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800300:	50                   	push   %eax
  800301:	68 98 02 80 00       	push   $0x800298
  800306:	e8 49 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030b:	83 c4 08             	add    $0x8,%esp
  80030e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800314:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80031a:	50                   	push   %eax
  80031b:	e8 3c 08 00 00       	call   800b5c <sys_cputs>

	return b.cnt;
  800320:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	50                   	push   %eax
  800332:	ff 75 08             	pushl  0x8(%ebp)
  800335:	e8 9d ff ff ff       	call   8002d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	8b 75 10             	mov    0x10(%ebp),%esi
  800348:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034e:	8b 45 18             	mov    0x18(%ebp),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	39 fa                	cmp    %edi,%edx
  800358:	77 39                	ja     800393 <printnum+0x57>
  80035a:	72 04                	jb     800360 <printnum+0x24>
  80035c:	39 f0                	cmp    %esi,%eax
  80035e:	77 33                	ja     800393 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	ff 75 20             	pushl  0x20(%ebp)
  800366:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800369:	50                   	push   %eax
  80036a:	ff 75 18             	pushl  0x18(%ebp)
  80036d:	8b 45 18             	mov    0x18(%ebp),%eax
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	52                   	push   %edx
  800376:	50                   	push   %eax
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	e8 92 0a 00 00       	call   800e10 <__udivdi3>
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	52                   	push   %edx
  800382:	50                   	push   %eax
  800383:	ff 75 0c             	pushl  0xc(%ebp)
  800386:	ff 75 08             	pushl  0x8(%ebp)
  800389:	e8 ae ff ff ff       	call   80033c <printnum>
  80038e:	83 c4 20             	add    $0x20,%esp
  800391:	eb 19                	jmp    8003ac <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800393:	4b                   	dec    %ebx
  800394:	85 db                	test   %ebx,%ebx
  800396:	7e 14                	jle    8003ac <printnum+0x70>
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 20             	pushl  0x20(%ebp)
  8003a1:	ff 55 08             	call   *0x8(%ebp)
  8003a4:	83 c4 10             	add    $0x10,%esp
  8003a7:	4b                   	dec    %ebx
  8003a8:	85 db                	test   %ebx,%ebx
  8003aa:	7f ec                	jg     800398 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	ff 75 0c             	pushl  0xc(%ebp)
  8003b2:	8b 45 18             	mov    0x18(%ebp),%eax
  8003b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ba:	83 ec 04             	sub    $0x4,%esp
  8003bd:	52                   	push   %edx
  8003be:	50                   	push   %eax
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	e8 56 0b 00 00       	call   800f1c <__umoddi3>
  8003c6:	83 c4 14             	add    $0x14,%esp
  8003c9:	0f be 80 b9 12 80 00 	movsbl 0x8012b9(%eax),%eax
  8003d0:	50                   	push   %eax
  8003d1:	ff 55 08             	call   *0x8(%ebp)
}
  8003d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d7:	5b                   	pop    %ebx
  8003d8:	5e                   	pop    %esi
  8003d9:	5f                   	pop    %edi
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8003e5:	83 f8 01             	cmp    $0x1,%eax
  8003e8:	7e 0e                	jle    8003f8 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8003ea:	8b 11                	mov    (%ecx),%edx
  8003ec:	8d 42 08             	lea    0x8(%edx),%eax
  8003ef:	89 01                	mov    %eax,(%ecx)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	8b 52 04             	mov    0x4(%edx),%edx
  8003f6:	eb 22                	jmp    80041a <getuint+0x3e>
	else if (lflag)
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	74 10                	je     80040c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8003fc:	8b 11                	mov    (%ecx),%edx
  8003fe:	8d 42 04             	lea    0x4(%edx),%eax
  800401:	89 01                	mov    %eax,(%ecx)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	eb 0e                	jmp    80041a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80040c:	8b 11                	mov    (%ecx),%edx
  80040e:	8d 42 04             	lea    0x4(%edx),%eax
  800411:	89 01                	mov    %eax,(%ecx)
  800413:	8b 02                	mov    (%edx),%eax
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800422:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800425:	83 f8 01             	cmp    $0x1,%eax
  800428:	7e 0e                	jle    800438 <getint+0x1c>
		return va_arg(*ap, long long);
  80042a:	8b 11                	mov    (%ecx),%edx
  80042c:	8d 42 08             	lea    0x8(%edx),%eax
  80042f:	89 01                	mov    %eax,(%ecx)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	8b 52 04             	mov    0x4(%edx),%edx
  800436:	eb 1a                	jmp    800452 <getint+0x36>
	else if (lflag)
  800438:	85 c0                	test   %eax,%eax
  80043a:	74 0c                	je     800448 <getint+0x2c>
		return va_arg(*ap, long);
  80043c:	8b 01                	mov    (%ecx),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 11                	mov    %edx,(%ecx)
  800443:	8b 00                	mov    (%eax),%eax
  800445:	99                   	cltd   
  800446:	eb 0a                	jmp    800452 <getint+0x36>
	else
		return va_arg(*ap, int);
  800448:	8b 01                	mov    (%ecx),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 11                	mov    %edx,(%ecx)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	99                   	cltd   
}
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 1c             	sub    $0x1c,%esp
  80045d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800460:	0f b6 0b             	movzbl (%ebx),%ecx
  800463:	43                   	inc    %ebx
  800464:	83 f9 25             	cmp    $0x25,%ecx
  800467:	74 1e                	je     800487 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800469:	85 c9                	test   %ecx,%ecx
  80046b:	0f 84 dc 02 00 00    	je     80074d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 0c             	pushl  0xc(%ebp)
  800477:	51                   	push   %ecx
  800478:	ff 55 08             	call   *0x8(%ebp)
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	0f b6 0b             	movzbl (%ebx),%ecx
  800481:	43                   	inc    %ebx
  800482:	83 f9 25             	cmp    $0x25,%ecx
  800485:	75 e2                	jne    800469 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800487:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80048b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800492:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800497:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  80049c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	0f b6 0b             	movzbl (%ebx),%ecx
  8004a6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8004a9:	43                   	inc    %ebx
  8004aa:	83 f8 55             	cmp    $0x55,%eax
  8004ad:	0f 87 75 02 00 00    	ja     800728 <vprintfmt+0x2d4>
  8004b3:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8004ba:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8004be:	eb e3                	jmp    8004a3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c0:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8004c4:	eb dd                	jmp    8004a3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8004cb:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8004ce:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8004d2:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8004d5:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8004d8:	83 f8 09             	cmp    $0x9,%eax
  8004db:	77 28                	ja     800505 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dd:	43                   	inc    %ebx
  8004de:	eb eb                	jmp    8004cb <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e0:	8b 55 14             	mov    0x14(%ebp),%edx
  8004e3:	8d 42 04             	lea    0x4(%edx),%eax
  8004e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e9:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8004eb:	eb 18                	jmp    800505 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8004ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004f1:	79 b0                	jns    8004a3 <vprintfmt+0x4f>
				width = 0;
  8004f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8004fa:	eb a7                	jmp    8004a3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8004fc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800503:	eb 9e                	jmp    8004a3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800505:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800509:	79 98                	jns    8004a3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80050b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80050e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800513:	eb 8e                	jmp    8004a3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800515:	47                   	inc    %edi
			goto reswitch;
  800516:	eb 8b                	jmp    8004a3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	8b 55 14             	mov    0x14(%ebp),%edx
  800521:	8d 42 04             	lea    0x4(%edx),%eax
  800524:	89 45 14             	mov    %eax,0x14(%ebp)
  800527:	ff 32                	pushl  (%edx)
  800529:	ff 55 08             	call   *0x8(%ebp)
			break;
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	e9 2c ff ff ff       	jmp    800460 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 55 14             	mov    0x14(%ebp),%edx
  800537:	8d 42 04             	lea    0x4(%edx),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80053f:	85 c0                	test   %eax,%eax
  800541:	79 02                	jns    800545 <vprintfmt+0xf1>
				err = -err;
  800543:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800545:	83 f8 0f             	cmp    $0xf,%eax
  800548:	7f 0b                	jg     800555 <vprintfmt+0x101>
  80054a:	8b 3c 85 00 13 80 00 	mov    0x801300(,%eax,4),%edi
  800551:	85 ff                	test   %edi,%edi
  800553:	75 19                	jne    80056e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800555:	50                   	push   %eax
  800556:	68 ca 12 80 00       	push   $0x8012ca
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	ff 75 08             	pushl  0x8(%ebp)
  800561:	e8 ef 01 00 00       	call   800755 <printfmt>
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	e9 f2 fe ff ff       	jmp    800460 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80056e:	57                   	push   %edi
  80056f:	68 d3 12 80 00       	push   $0x8012d3
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	ff 75 08             	pushl  0x8(%ebp)
  80057a:	e8 d6 01 00 00       	call   800755 <printfmt>
  80057f:	83 c4 10             	add    $0x10,%esp
			break;
  800582:	e9 d9 fe ff ff       	jmp    800460 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800587:	8b 55 14             	mov    0x14(%ebp),%edx
  80058a:	8d 42 04             	lea    0x4(%edx),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
  800590:	8b 3a                	mov    (%edx),%edi
  800592:	85 ff                	test   %edi,%edi
  800594:	75 05                	jne    80059b <vprintfmt+0x147>
				p = "(null)";
  800596:	bf d6 12 80 00       	mov    $0x8012d6,%edi
			if (width > 0 && padc != '-')
  80059b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80059f:	7e 3b                	jle    8005dc <vprintfmt+0x188>
  8005a1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8005a5:	74 35                	je     8005dc <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	56                   	push   %esi
  8005ab:	57                   	push   %edi
  8005ac:	e8 58 02 00 00       	call   800809 <strnlen>
  8005b1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005bb:	7e 1f                	jle    8005dc <vprintfmt+0x188>
  8005bd:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	ff 4d f0             	decl   -0x10(%ebp)
  8005d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005da:	7f e8                	jg     8005c4 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dc:	0f be 0f             	movsbl (%edi),%ecx
  8005df:	47                   	inc    %edi
  8005e0:	85 c9                	test   %ecx,%ecx
  8005e2:	74 44                	je     800628 <vprintfmt+0x1d4>
  8005e4:	85 f6                	test   %esi,%esi
  8005e6:	78 03                	js     8005eb <vprintfmt+0x197>
  8005e8:	4e                   	dec    %esi
  8005e9:	78 3d                	js     800628 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8005eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8005ef:	74 18                	je     800609 <vprintfmt+0x1b5>
  8005f1:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8005f4:	83 f8 5e             	cmp    $0x5e,%eax
  8005f7:	76 10                	jbe    800609 <vprintfmt+0x1b5>
					putch('?', putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	ff 75 0c             	pushl  0xc(%ebp)
  8005ff:	6a 3f                	push   $0x3f
  800601:	ff 55 08             	call   *0x8(%ebp)
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	eb 0d                	jmp    800616 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 0c             	pushl  0xc(%ebp)
  80060f:	51                   	push   %ecx
  800610:	ff 55 08             	call   *0x8(%ebp)
  800613:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	ff 4d f0             	decl   -0x10(%ebp)
  800619:	0f be 0f             	movsbl (%edi),%ecx
  80061c:	47                   	inc    %edi
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 07                	je     800628 <vprintfmt+0x1d4>
  800621:	85 f6                	test   %esi,%esi
  800623:	78 c6                	js     8005eb <vprintfmt+0x197>
  800625:	4e                   	dec    %esi
  800626:	79 c3                	jns    8005eb <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800628:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80062c:	0f 8e 2e fe ff ff    	jle    800460 <vprintfmt+0xc>
				putch(' ', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	ff 75 0c             	pushl  0xc(%ebp)
  800638:	6a 20                	push   $0x20
  80063a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	ff 4d f0             	decl   -0x10(%ebp)
  800643:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800647:	7f e9                	jg     800632 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800649:	e9 12 fe ff ff       	jmp    800460 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064e:	57                   	push   %edi
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	50                   	push   %eax
  800653:	e8 c4 fd ff ff       	call   80041c <getint>
  800658:	89 c6                	mov    %eax,%esi
  80065a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80065c:	83 c4 08             	add    $0x8,%esp
  80065f:	85 d2                	test   %edx,%edx
  800661:	79 15                	jns    800678 <vprintfmt+0x224>
				putch('-', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	ff 75 0c             	pushl  0xc(%ebp)
  800669:	6a 2d                	push   $0x2d
  80066b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066e:	f7 de                	neg    %esi
  800670:	83 d7 00             	adc    $0x0,%edi
  800673:	f7 df                	neg    %edi
  800675:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800678:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80067d:	eb 76                	jmp    8006f5 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067f:	57                   	push   %edi
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	50                   	push   %eax
  800684:	e8 53 fd ff ff       	call   8003dc <getuint>
  800689:	89 c6                	mov    %eax,%esi
  80068b:	89 d7                	mov    %edx,%edi
			base = 10;
  80068d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800692:	83 c4 08             	add    $0x8,%esp
  800695:	eb 5e                	jmp    8006f5 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800697:	57                   	push   %edi
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
  80069b:	50                   	push   %eax
  80069c:	e8 3b fd ff ff       	call   8003dc <getuint>
  8006a1:	89 c6                	mov    %eax,%esi
  8006a3:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8006aa:	83 c4 08             	add    $0x8,%esp
  8006ad:	eb 46                	jmp    8006f5 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	6a 30                	push   $0x30
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ba:	83 c4 08             	add    $0x8,%esp
  8006bd:	ff 75 0c             	pushl  0xc(%ebp)
  8006c0:	6a 78                	push   $0x78
  8006c2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006c5:	8b 55 14             	mov    0x14(%ebp),%edx
  8006c8:	8d 42 04             	lea    0x4(%edx),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ce:	8b 32                	mov    (%edx),%esi
  8006d0:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d5:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 16                	jmp    8006f5 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006df:	57                   	push   %edi
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e3:	50                   	push   %eax
  8006e4:	e8 f3 fc ff ff       	call   8003dc <getuint>
  8006e9:	89 c6                	mov    %eax,%esi
  8006eb:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ed:	ba 10 00 00 00       	mov    $0x10,%edx
  8006f2:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006fc:	50                   	push   %eax
  8006fd:	ff 75 f0             	pushl  -0x10(%ebp)
  800700:	52                   	push   %edx
  800701:	57                   	push   %edi
  800702:	56                   	push   %esi
  800703:	ff 75 0c             	pushl  0xc(%ebp)
  800706:	ff 75 08             	pushl  0x8(%ebp)
  800709:	e8 2e fc ff ff       	call   80033c <printnum>
			break;
  80070e:	83 c4 20             	add    $0x20,%esp
  800711:	e9 4a fd ff ff       	jmp    800460 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	51                   	push   %ecx
  80071d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	e9 38 fd ff ff       	jmp    800460 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	6a 25                	push   $0x25
  800730:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800733:	4b                   	dec    %ebx
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80073b:	0f 84 1f fd ff ff    	je     800460 <vprintfmt+0xc>
  800741:	4b                   	dec    %ebx
  800742:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800746:	75 f9                	jne    800741 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800748:	e9 13 fd ff ff       	jmp    800460 <vprintfmt+0xc>
		}
	}
}
  80074d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80075e:	50                   	push   %eax
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	ff 75 08             	pushl  0x8(%ebp)
  800768:	e8 e7 fc ff ff       	call   800454 <vprintfmt>
	va_end(ap);
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800775:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800778:	8b 0a                	mov    (%edx),%ecx
  80077a:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80077d:	73 07                	jae    800786 <sprintputch+0x17>
		*b->buf++ = ch;
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	88 01                	mov    %al,(%ecx)
  800784:	ff 02                	incl   (%edx)
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 18             	sub    $0x18,%esp
  80078e:	8b 55 08             	mov    0x8(%ebp),%edx
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800794:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800797:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80079b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 04                	je     8007ad <vsnprintf+0x25>
  8007a9:	85 c9                	test   %ecx,%ecx
  8007ab:	7f 07                	jg     8007b4 <vsnprintf+0x2c>
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b2:	eb 1d                	jmp    8007d1 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b4:	ff 75 14             	pushl  0x14(%ebp)
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	68 6f 07 80 00       	push   $0x80076f
  8007c3:	e8 8c fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 10             	pushl  0x10(%ebp)
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	ff 75 08             	pushl  0x8(%ebp)
  8007e6:	e8 9d ff ff ff       	call   800788 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
  8007ed:	00 00                	add    %al,(%eax)
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fe:	74 07                	je     800807 <strlen+0x17>
		n++;
  800800:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	42                   	inc    %edx
  800802:	80 3a 00             	cmpb   $0x0,(%edx)
  800805:	75 f9                	jne    800800 <strlen+0x10>
		n++;
	return n;
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	85 d2                	test   %edx,%edx
  800819:	74 0f                	je     80082a <strnlen+0x21>
  80081b:	80 39 00             	cmpb   $0x0,(%ecx)
  80081e:	74 0a                	je     80082a <strnlen+0x21>
		n++;
  800820:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	41                   	inc    %ecx
  800822:	4a                   	dec    %edx
  800823:	74 05                	je     80082a <strnlen+0x21>
  800825:	80 39 00             	cmpb   $0x0,(%ecx)
  800828:	75 f6                	jne    800820 <strnlen+0x17>
		n++;
	return n;
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800836:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800838:	8a 02                	mov    (%edx),%al
  80083a:	42                   	inc    %edx
  80083b:	88 01                	mov    %al,(%ecx)
  80083d:	41                   	inc    %ecx
  80083e:	84 c0                	test   %al,%al
  800840:	75 f6                	jne    800838 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	5b                   	pop    %ebx
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084e:	53                   	push   %ebx
  80084f:	e8 9c ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80085a:	50                   	push   %eax
  80085b:	e8 cc ff ff ff       	call   80082c <strcpy>
	return dst;
}
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800876:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800878:	bb 00 00 00 00       	mov    $0x0,%ebx
  80087d:	39 f3                	cmp    %esi,%ebx
  80087f:	73 10                	jae    800891 <strncpy+0x2a>
		*dst++ = *src;
  800881:	8a 02                	mov    (%edx),%al
  800883:	88 01                	mov    %al,(%ecx)
  800885:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800886:	80 3a 01             	cmpb   $0x1,(%edx)
  800889:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088c:	43                   	inc    %ebx
  80088d:	39 f3                	cmp    %esi,%ebx
  80088f:	72 f0                	jb     800881 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800891:	89 f8                	mov    %edi,%eax
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5f                   	pop    %edi
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8008a6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	74 19                	je     8008c5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ac:	4a                   	dec    %edx
  8008ad:	74 13                	je     8008c2 <strlcpy+0x2a>
  8008af:	80 39 00             	cmpb   $0x0,(%ecx)
  8008b2:	74 0e                	je     8008c2 <strlcpy+0x2a>
  8008b4:	8a 01                	mov    (%ecx),%al
  8008b6:	41                   	inc    %ecx
  8008b7:	88 03                	mov    %al,(%ebx)
  8008b9:	43                   	inc    %ebx
  8008ba:	4a                   	dec    %edx
  8008bb:	74 05                	je     8008c2 <strlcpy+0x2a>
  8008bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8008c0:	75 f2                	jne    8008b4 <strlcpy+0x1c>
		*dst = '\0';
  8008c2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	29 f0                	sub    %esi,%eax
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8008d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008d9:	74 13                	je     8008ee <strcmp+0x21>
  8008db:	8a 02                	mov    (%edx),%al
  8008dd:	3a 01                	cmp    (%ecx),%al
  8008df:	75 0d                	jne    8008ee <strcmp+0x21>
  8008e1:	42                   	inc    %edx
  8008e2:	41                   	inc    %ecx
  8008e3:	80 3a 00             	cmpb   $0x0,(%edx)
  8008e6:	74 06                	je     8008ee <strcmp+0x21>
  8008e8:	8a 02                	mov    (%edx),%al
  8008ea:	3a 01                	cmp    (%ecx),%al
  8008ec:	74 f3                	je     8008e1 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 02             	movzbl (%edx),%eax
  8008f1:	0f b6 11             	movzbl (%ecx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	53                   	push   %ebx
  8008fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 1f                	je     800928 <strncmp+0x30>
  800909:	80 3a 00             	cmpb   $0x0,(%edx)
  80090c:	74 16                	je     800924 <strncmp+0x2c>
  80090e:	8a 02                	mov    (%edx),%al
  800910:	3a 03                	cmp    (%ebx),%al
  800912:	75 10                	jne    800924 <strncmp+0x2c>
  800914:	42                   	inc    %edx
  800915:	43                   	inc    %ebx
  800916:	49                   	dec    %ecx
  800917:	74 0f                	je     800928 <strncmp+0x30>
  800919:	80 3a 00             	cmpb   $0x0,(%edx)
  80091c:	74 06                	je     800924 <strncmp+0x2c>
  80091e:	8a 02                	mov    (%edx),%al
  800920:	3a 03                	cmp    (%ebx),%al
  800922:	74 f0                	je     800914 <strncmp+0x1c>
	if (n == 0)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	75 07                	jne    80092f <strncmp+0x37>
		return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb 0a                	jmp    800939 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	0f b6 03             	movzbl (%ebx),%eax
  800935:	29 c2                	sub    %eax,%edx
  800937:	89 d0                	mov    %edx,%eax
}
  800939:	5b                   	pop    %ebx
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800945:	80 38 00             	cmpb   $0x0,(%eax)
  800948:	74 0a                	je     800954 <strchr+0x18>
		if (*s == c)
  80094a:	38 10                	cmp    %dl,(%eax)
  80094c:	74 0b                	je     800959 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	40                   	inc    %eax
  80094f:	80 38 00             	cmpb   $0x0,(%eax)
  800952:	75 f6                	jne    80094a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800964:	80 38 00             	cmpb   $0x0,(%eax)
  800967:	74 0a                	je     800973 <strfind+0x18>
		if (*s == c)
  800969:	38 10                	cmp    %dl,(%eax)
  80096b:	74 06                	je     800973 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096d:	40                   	inc    %eax
  80096e:	80 38 00             	cmpb   $0x0,(%eax)
  800971:	75 f6                	jne    800969 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  80097f:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800981:	85 c9                	test   %ecx,%ecx
  800983:	74 40                	je     8009c5 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800985:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098b:	75 30                	jne    8009bd <memset+0x48>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 2b                	jne    8009bd <memset+0x48>
		c &= 0xFF;
  800992:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	c1 e0 18             	shl    $0x18,%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a2:	c1 e2 10             	shl    $0x10,%edx
  8009a5:	09 d0                	or     %edx,%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	c1 e2 08             	shl    $0x8,%edx
  8009ad:	09 d0                	or     %edx,%eax
  8009af:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
  8009b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b8:	fc                   	cld    
  8009b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bb:	eb 06                	jmp    8009c3 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	fc                   	cld    
  8009c1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8009c3:	89 f8                	mov    %edi,%eax
}
  8009c5:	5f                   	pop    %edi
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009d6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009d8:	39 c6                	cmp    %eax,%esi
  8009da:	73 34                	jae    800a10 <memmove+0x48>
  8009dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009df:	39 c2                	cmp    %eax,%edx
  8009e1:	76 2d                	jbe    800a10 <memmove+0x48>
		s += n;
  8009e3:	89 d6                	mov    %edx,%esi
		d += n;
  8009e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	75 1b                	jne    800a08 <memmove+0x40>
  8009ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f3:	75 13                	jne    800a08 <memmove+0x40>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0e                	jne    800a08 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8009fa:	83 ef 04             	sub    $0x4,%edi
  8009fd:	83 ee 04             	sub    $0x4,%esi
  800a00:	c1 e9 02             	shr    $0x2,%ecx
  800a03:	fd                   	std    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 05                	jmp    800a0d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a08:	4f                   	dec    %edi
  800a09:	4e                   	dec    %esi
  800a0a:	fd                   	std    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0d:	fc                   	cld    
  800a0e:	eb 20                	jmp    800a30 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a16:	75 15                	jne    800a2d <memmove+0x65>
  800a18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1e:	75 0d                	jne    800a2d <memmove+0x65>
  800a20:	f6 c1 03             	test   $0x3,%cl
  800a23:	75 08                	jne    800a2d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800a25:	c1 e9 02             	shr    $0x2,%ecx
  800a28:	fc                   	cld    
  800a29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2b:	eb 03                	jmp    800a30 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2d:	fc                   	cld    
  800a2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a37:	ff 75 10             	pushl  0x10(%ebp)
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	ff 75 08             	pushl  0x8(%ebp)
  800a40:	e8 83 ff ff ff       	call   8009c8 <memmove>
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a51:	8b 55 10             	mov    0x10(%ebp),%edx
  800a54:	4a                   	dec    %edx
  800a55:	83 fa ff             	cmp    $0xffffffff,%edx
  800a58:	74 1a                	je     800a74 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800a5a:	8a 01                	mov    (%ecx),%al
  800a5c:	3a 03                	cmp    (%ebx),%al
  800a5e:	74 0c                	je     800a6c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800a60:	0f b6 d0             	movzbl %al,%edx
  800a63:	0f b6 03             	movzbl (%ebx),%eax
  800a66:	29 c2                	sub    %eax,%edx
  800a68:	89 d0                	mov    %edx,%eax
  800a6a:	eb 0d                	jmp    800a79 <memcmp+0x32>
		s1++, s2++;
  800a6c:	41                   	inc    %ecx
  800a6d:	43                   	inc    %ebx
  800a6e:	4a                   	dec    %edx
  800a6f:	83 fa ff             	cmp    $0xffffffff,%edx
  800a72:	75 e6                	jne    800a5a <memcmp+0x13>
	}

	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8a:	39 d0                	cmp    %edx,%eax
  800a8c:	73 09                	jae    800a97 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	38 08                	cmp    %cl,(%eax)
  800a90:	74 05                	je     800a97 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a92:	40                   	inc    %eax
  800a93:	39 d0                	cmp    %edx,%eax
  800a95:	72 f7                	jb     800a8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800aad:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800ab2:	80 3a 20             	cmpb   $0x20,(%edx)
  800ab5:	74 05                	je     800abc <strtol+0x23>
  800ab7:	80 3a 09             	cmpb   $0x9,(%edx)
  800aba:	75 0b                	jne    800ac7 <strtol+0x2e>
  800abc:	42                   	inc    %edx
  800abd:	80 3a 20             	cmpb   $0x20,(%edx)
  800ac0:	74 fa                	je     800abc <strtol+0x23>
  800ac2:	80 3a 09             	cmpb   $0x9,(%edx)
  800ac5:	74 f5                	je     800abc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800ac7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800aca:	75 03                	jne    800acf <strtol+0x36>
		s++;
  800acc:	42                   	inc    %edx
  800acd:	eb 0b                	jmp    800ada <strtol+0x41>
	else if (*s == '-')
  800acf:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800ad2:	75 06                	jne    800ada <strtol+0x41>
		s++, neg = 1;
  800ad4:	42                   	inc    %edx
  800ad5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	85 c9                	test   %ecx,%ecx
  800adc:	74 05                	je     800ae3 <strtol+0x4a>
  800ade:	83 f9 10             	cmp    $0x10,%ecx
  800ae1:	75 15                	jne    800af8 <strtol+0x5f>
  800ae3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae6:	75 10                	jne    800af8 <strtol+0x5f>
  800ae8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aec:	75 0a                	jne    800af8 <strtol+0x5f>
		s += 2, base = 16;
  800aee:	83 c2 02             	add    $0x2,%edx
  800af1:	b9 10 00 00 00       	mov    $0x10,%ecx
  800af6:	eb 14                	jmp    800b0c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800af8:	85 c9                	test   %ecx,%ecx
  800afa:	75 10                	jne    800b0c <strtol+0x73>
  800afc:	80 3a 30             	cmpb   $0x30,(%edx)
  800aff:	75 05                	jne    800b06 <strtol+0x6d>
		s++, base = 8;
  800b01:	42                   	inc    %edx
  800b02:	b1 08                	mov    $0x8,%cl
  800b04:	eb 06                	jmp    800b0c <strtol+0x73>
	else if (base == 0)
  800b06:	85 c9                	test   %ecx,%ecx
  800b08:	75 02                	jne    800b0c <strtol+0x73>
		base = 10;
  800b0a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0c:	8a 02                	mov    (%edx),%al
  800b0e:	83 e8 30             	sub    $0x30,%eax
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	77 08                	ja     800b1d <strtol+0x84>
			dig = *s - '0';
  800b15:	0f be 02             	movsbl (%edx),%eax
  800b18:	83 e8 30             	sub    $0x30,%eax
  800b1b:	eb 20                	jmp    800b3d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800b1d:	8a 02                	mov    (%edx),%al
  800b1f:	83 e8 61             	sub    $0x61,%eax
  800b22:	3c 19                	cmp    $0x19,%al
  800b24:	77 08                	ja     800b2e <strtol+0x95>
			dig = *s - 'a' + 10;
  800b26:	0f be 02             	movsbl (%edx),%eax
  800b29:	83 e8 57             	sub    $0x57,%eax
  800b2c:	eb 0f                	jmp    800b3d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800b2e:	8a 02                	mov    (%edx),%al
  800b30:	83 e8 41             	sub    $0x41,%eax
  800b33:	3c 19                	cmp    $0x19,%al
  800b35:	77 12                	ja     800b49 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800b37:	0f be 02             	movsbl (%edx),%eax
  800b3a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800b3d:	39 c8                	cmp    %ecx,%eax
  800b3f:	7d 08                	jge    800b49 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b41:	42                   	inc    %edx
  800b42:	0f af d9             	imul   %ecx,%ebx
  800b45:	01 c3                	add    %eax,%ebx
  800b47:	eb c3                	jmp    800b0c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b49:	85 f6                	test   %esi,%esi
  800b4b:	74 02                	je     800b4f <strtol+0xb6>
		*endptr = (char *) s;
  800b4d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b4f:	89 d8                	mov    %ebx,%eax
  800b51:	85 ff                	test   %edi,%edi
  800b53:	74 02                	je     800b57 <strtol+0xbe>
  800b55:	f7 d8                	neg    %eax
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 04             	sub    $0x4,%esp
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	89 f8                	mov    %edi,%eax
  800b72:	89 fb                	mov    %edi,%ebx
  800b74:	89 fe                	mov    %edi,%esi
  800b76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b78:	83 c4 04             	add    $0x4,%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b86:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	89 fa                	mov    %edi,%edx
  800b92:	89 f9                	mov    %edi,%ecx
  800b94:	89 fb                	mov    %edi,%ebx
  800b96:	89 fe                	mov    %edi,%esi
  800b98:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bab:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	89 f9                	mov    %edi,%ecx
  800bb7:	89 fb                	mov    %edi,%ebx
  800bb9:	89 fe                	mov    %edi,%esi
  800bbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 03                	push   $0x3
  800bc7:	68 98 14 80 00       	push   $0x801498
  800bcc:	6a 23                	push   $0x23
  800bce:	68 b5 14 80 00       	push   $0x8014b5
  800bd3:	e8 74 f6 ff ff       	call   80024c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800be6:	b8 02 00 00 00       	mov    $0x2,%eax
  800beb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	89 fa                	mov    %edi,%edx
  800bf2:	89 f9                	mov    %edi,%ecx
  800bf4:	89 fb                	mov    %edi,%ebx
  800bf6:	89 fe                	mov    %edi,%esi
  800bf8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <sys_yield>:

void
sys_yield(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0a:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	89 fa                	mov    %edi,%edx
  800c11:	89 f9                	mov    %edi,%ecx
  800c13:	89 fb                	mov    %edi,%ebx
  800c15:	89 fe                	mov    %edi,%esi
  800c17:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c30:	b8 04 00 00 00       	mov    $0x4,%eax
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	89 fe                	mov    %edi,%esi
  800c3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 04                	push   $0x4
  800c48:	68 98 14 80 00       	push   $0x801498
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 b5 14 80 00       	push   $0x8014b5
  800c54:	e8 f3 f5 ff ff       	call   80024c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c76:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c79:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 05                	push   $0x5
  800c8a:	68 98 14 80 00       	push   $0x801498
  800c8f:	6a 23                	push   $0x23
  800c91:	68 b5 14 80 00       	push   $0x8014b5
  800c96:	e8 b1 f5 ff ff       	call   80024c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	89 fb                	mov    %edi,%ebx
  800cbe:	89 fe                	mov    %edi,%esi
  800cc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 06                	push   $0x6
  800ccc:	68 98 14 80 00       	push   $0x801498
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 b5 14 80 00       	push   $0x8014b5
  800cd8:	e8 6f f5 ff ff       	call   80024c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	89 fb                	mov    %edi,%ebx
  800d00:	89 fe                	mov    %edi,%esi
  800d02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 08                	push   $0x8
  800d0e:	68 98 14 80 00       	push   $0x801498
  800d13:	6a 23                	push   $0x23
  800d15:	68 b5 14 80 00       	push   $0x8014b5
  800d1a:	e8 2d f5 ff ff       	call   80024c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d36:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	89 fb                	mov    %edi,%ebx
  800d42:	89 fe                	mov    %edi,%esi
  800d44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 09                	push   $0x9
  800d50:	68 98 14 80 00       	push   $0x801498
  800d55:	6a 23                	push   $0x23
  800d57:	68 b5 14 80 00       	push   $0x8014b5
  800d5c:	e8 eb f4 ff ff       	call   80024c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	89 fb                	mov    %edi,%ebx
  800d84:	89 fe                	mov    %edi,%esi
  800d86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 17                	jle    800da3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 0a                	push   $0xa
  800d92:	68 98 14 80 00       	push   $0x801498
  800d97:	6a 23                	push   $0x23
  800d99:	68 b5 14 80 00       	push   $0x8014b5
  800d9e:	e8 a9 f4 ff ff       	call   80024c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dbd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc2:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	89 f9                	mov    %edi,%ecx
  800de6:	89 fb                	mov    %edi,%ebx
  800de8:	89 fe                	mov    %edi,%esi
  800dea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 17                	jle    800e07 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 0d                	push   $0xd
  800df6:	68 98 14 80 00       	push   $0x801498
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 b5 14 80 00       	push   $0x8014b5
  800e02:	e8 45 f4 ff ff       	call   80024c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	c9                   	leave  
  800e0e:	c3                   	ret    
	...

00800e10 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	83 ec 14             	sub    $0x14,%esp
  800e18:	8b 55 14             	mov    0x14(%ebp),%edx
  800e1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e21:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e24:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e26:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800e2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e2f:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e31:	75 11                	jne    800e44 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800e33:	39 f8                	cmp    %edi,%eax
  800e35:	76 4d                	jbe    800e84 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e37:	89 fa                	mov    %edi,%edx
  800e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3c:	f7 75 e4             	divl   -0x1c(%ebp)
  800e3f:	89 c7                	mov    %eax,%edi
  800e41:	eb 09                	jmp    800e4c <__udivdi3+0x3c>
  800e43:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e44:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800e47:	76 17                	jbe    800e60 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800e49:	31 ff                	xor    %edi,%edi
  800e4b:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800e4c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e53:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e56:	83 c4 14             	add    $0x14,%esp
  800e59:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e5a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e5c:	5f                   	pop    %edi
  800e5d:	c9                   	leave  
  800e5e:	c3                   	ret    
  800e5f:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e60:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800e64:	89 c7                	mov    %eax,%edi
  800e66:	83 f7 1f             	xor    $0x1f,%edi
  800e69:	75 4d                	jne    800eb8 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e6b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e6e:	77 0a                	ja     800e7a <__udivdi3+0x6a>
  800e70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800e73:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e75:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e78:	72 d2                	jb     800e4c <__udivdi3+0x3c>
		{
		  q0 = 1;
  800e7a:	bf 01 00 00 00       	mov    $0x1,%edi
  800e7f:	eb cb                	jmp    800e4c <__udivdi3+0x3c>
  800e81:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e87:	85 c0                	test   %eax,%eax
  800e89:	75 0e                	jne    800e99 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e90:	31 c9                	xor    %ecx,%ecx
  800e92:	31 d2                	xor    %edx,%edx
  800e94:	f7 f1                	div    %ecx
  800e96:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 75 e4             	divl   -0x1c(%ebp)
  800ea0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea6:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea9:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eac:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eaf:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb1:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eb2:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb4:	5f                   	pop    %edi
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800eb8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ebd:	29 f8                	sub    %edi,%eax
  800ebf:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800ec2:	89 f9                	mov    %edi,%ecx
  800ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ec7:	d3 e2                	shl    %cl,%edx
  800ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ecc:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800ecf:	d3 e8                	shr    %cl,%eax
  800ed1:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800ed3:	89 f9                	mov    %edi,%ecx
  800ed5:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ed8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800edb:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800ede:	89 f2                	mov    %esi,%edx
  800ee0:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800ee2:	89 f9                	mov    %edi,%ecx
  800ee4:	d3 e6                	shl    %cl,%esi
  800ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee9:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800eec:	d3 e8                	shr    %cl,%eax
  800eee:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800ef0:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ef2:	89 f0                	mov    %esi,%eax
  800ef4:	f7 75 f4             	divl   -0xc(%ebp)
  800ef7:	89 d6                	mov    %edx,%esi
  800ef9:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800efb:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800efe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f01:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f03:	39 f2                	cmp    %esi,%edx
  800f05:	77 0f                	ja     800f16 <__udivdi3+0x106>
  800f07:	0f 85 3f ff ff ff    	jne    800e4c <__udivdi3+0x3c>
  800f0d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f10:	0f 86 36 ff ff ff    	jbe    800e4c <__udivdi3+0x3c>
		{
		  q0--;
  800f16:	4f                   	dec    %edi
  800f17:	e9 30 ff ff ff       	jmp    800e4c <__udivdi3+0x3c>

00800f1c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	83 ec 30             	sub    $0x30,%esp
  800f24:	8b 55 14             	mov    0x14(%ebp),%edx
  800f27:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800f2a:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800f2c:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800f2f:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800f31:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f37:	85 ff                	test   %edi,%edi
  800f39:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800f40:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800f47:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800f4d:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f50:	75 3e                	jne    800f90 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800f52:	39 d6                	cmp    %edx,%esi
  800f54:	0f 86 a2 00 00 00    	jbe    800ffc <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f5a:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800f5c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f5f:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f61:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800f64:	74 1b                	je     800f81 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800f66:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f69:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800f6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f76:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f79:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800f7c:	89 10                	mov    %edx,(%eax)
  800f7e:	89 48 04             	mov    %ecx,0x4(%eax)
  800f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f87:	83 c4 30             	add    $0x30,%esp
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
  800f8e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f90:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800f93:	76 1f                	jbe    800fb4 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f95:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800f98:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f9b:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800f9e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800faa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fad:	83 c4 30             	add    $0x30,%esp
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fb4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800fb7:	83 f0 1f             	xor    $0x1f,%eax
  800fba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800fbd:	75 61                	jne    801020 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fbf:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800fc2:	77 05                	ja     800fc9 <__umoddi3+0xad>
  800fc4:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800fc7:	72 10                	jb     800fd9 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fc9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800fcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fcf:	29 f0                	sub    %esi,%eax
  800fd1:	19 fa                	sbb    %edi,%edx
  800fd3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fd6:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800fd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fdc:	85 d2                	test   %edx,%edx
  800fde:	74 a1                	je     800f81 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800fe0:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800fe3:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800fe6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800fe9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800fec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff5:	89 01                	mov    %eax,(%ecx)
  800ff7:	89 51 04             	mov    %edx,0x4(%ecx)
  800ffa:	eb 85                	jmp    800f81 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ffc:	85 f6                	test   %esi,%esi
  800ffe:	75 0b                	jne    80100b <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801000:	b8 01 00 00 00       	mov    $0x1,%eax
  801005:	31 d2                	xor    %edx,%edx
  801007:	f7 f6                	div    %esi
  801009:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80100b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80100e:	89 fa                	mov    %edi,%edx
  801010:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801012:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801015:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801018:	f7 f6                	div    %esi
  80101a:	e9 3d ff ff ff       	jmp    800f5c <__umoddi3+0x40>
  80101f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801020:	b8 20 00 00 00       	mov    $0x20,%eax
  801025:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  801028:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  80102b:	89 fa                	mov    %edi,%edx
  80102d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801030:	d3 e2                	shl    %cl,%edx
  801032:	89 f0                	mov    %esi,%eax
  801034:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801037:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  801039:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  80103c:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80103e:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801040:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801043:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801046:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801048:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  80104a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80104d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801050:	d3 e0                	shl    %cl,%eax
  801052:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801055:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801058:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	0b 45 cc             	or     -0x34(%ebp),%eax
  801060:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  801063:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801066:	f7 f7                	div    %edi
  801068:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80106b:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  80106e:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801070:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801073:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801076:	77 0a                	ja     801082 <__umoddi3+0x166>
  801078:	75 12                	jne    80108c <__umoddi3+0x170>
  80107a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80107d:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801080:	76 0a                	jbe    80108c <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801082:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801085:	29 f1                	sub    %esi,%ecx
  801087:	19 fa                	sbb    %edi,%edx
  801089:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  80108c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80108f:	85 c0                	test   %eax,%eax
  801091:	0f 84 ea fe ff ff    	je     800f81 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801097:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80109a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80109d:	2b 45 c8             	sub    -0x38(%ebp),%eax
  8010a0:	19 d1                	sbb    %edx,%ecx
  8010a2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010a5:	89 ca                	mov    %ecx,%edx
  8010a7:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8010aa:	d3 e2                	shl    %cl,%edx
  8010ac:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010af:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010b2:	d3 e8                	shr    %cl,%eax
  8010b4:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  8010b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8010b9:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  8010be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c1:	e9 ad fe ff ff       	jmp    800f73 <__umoddi3+0x57>
