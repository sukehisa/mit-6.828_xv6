
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	53                   	push   %ebx
  800041:	68 20 10 80 00       	push   $0x801020
  800046:	e8 b5 01 00 00       	call   800200 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	89 d8                	mov    %ebx,%eax
  800050:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800055:	6a 07                	push   $0x7
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 97 0a 00 00       	call   800af6 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 40 10 80 00       	push   $0x801040
  800070:	6a 0e                	push   $0xe
  800072:	68 2a 10 80 00       	push   $0x80102a
  800077:	e8 a8 00 00 00       	call   800124 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 6c 10 80 00       	push   $0x80106c
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 21 06 00 00       	call   8006ab <snprintf>
}
  80008a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <umain>:

void
umain(int argc, char **argv)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800095:	68 34 00 80 00       	push   $0x800034
  80009a:	e8 49 0c 00 00       	call   800ce8 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  80009f:	83 c4 08             	add    $0x8,%esp
  8000a2:	68 ef be ad de       	push   $0xdeadbeef
  8000a7:	68 3c 10 80 00       	push   $0x80103c
  8000ac:	e8 4f 01 00 00       	call   800200 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b1:	83 c4 08             	add    $0x8,%esp
  8000b4:	68 fe bf fe ca       	push   $0xcafebffe
  8000b9:	68 3c 10 80 00       	push   $0x80103c
  8000be:	e8 3d 01 00 00       	call   800200 <cprintf>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000d3:	e8 e0 09 00 00       	call   800ab8 <sys_getenvid>
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	89 c2                	mov    %eax,%edx
  8000df:	c1 e2 05             	shl    $0x5,%edx
  8000e2:	29 c2                	sub    %eax,%edx
  8000e4:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000eb:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f1:	85 f6                	test   %esi,%esi
  8000f3:	7e 07                	jle    8000fc <libmain+0x34>
		binaryname = argv[0];
  8000f5:	8b 03                	mov    (%ebx),%eax
  8000f7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	53                   	push   %ebx
  800100:	56                   	push   %esi
  800101:	e8 89 ff ff ff       	call   80008f <umain>

	// exit gracefully
	exit();
  800106:	e8 09 00 00 00       	call   800114 <exit>
}
  80010b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	c9                   	leave  
  800111:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80011a:	6a 00                	push   $0x0
  80011c:	e8 56 09 00 00       	call   800a77 <sys_env_destroy>
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    
	...

00800124 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80012b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012e:	ff 75 0c             	pushl  0xc(%ebp)
  800131:	ff 75 08             	pushl  0x8(%ebp)
  800134:	ff 35 00 20 80 00    	pushl  0x802000
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	e8 76 09 00 00       	call   800ab8 <sys_getenvid>
  800142:	83 c4 08             	add    $0x8,%esp
  800145:	50                   	push   %eax
  800146:	68 98 10 80 00       	push   $0x801098
  80014b:	e8 b0 00 00 00       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800150:	83 c4 18             	add    $0x18,%esp
  800153:	53                   	push   %ebx
  800154:	ff 75 10             	pushl  0x10(%ebp)
  800157:	e8 53 00 00 00       	call   8001af <vcprintf>
	cprintf("\n");
  80015c:	c7 04 24 3e 10 80 00 	movl   $0x80103e,(%esp)
  800163:	e8 98 00 00 00       	call   800200 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800168:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80016b:	cc                   	int3   
  80016c:	eb fd                	jmp    80016b <_panic+0x47>
	...

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  800183:	40                   	inc    %eax
  800184:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800186:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018b:	75 1a                	jne    8001a7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	68 ff 00 00 00       	push   $0xff
  800195:	8d 43 08             	lea    0x8(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 96 08 00 00       	call   800a34 <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a7:	ff 43 04             	incl   0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 70 01 80 00       	push   $0x800170
  8001de:	e8 49 01 00 00       	call   80032c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  8001ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 3c 08 00 00       	call   800a34 <sys_cputs>

	return b.cnt;
  8001f8:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	8b 75 10             	mov    0x10(%ebp),%esi
  800220:	8b 7d 14             	mov    0x14(%ebp),%edi
  800223:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800226:	8b 45 18             	mov    0x18(%ebp),%eax
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
  80022e:	39 fa                	cmp    %edi,%edx
  800230:	77 39                	ja     80026b <printnum+0x57>
  800232:	72 04                	jb     800238 <printnum+0x24>
  800234:	39 f0                	cmp    %esi,%eax
  800236:	77 33                	ja     80026b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	ff 75 20             	pushl  0x20(%ebp)
  80023e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800241:	50                   	push   %eax
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	8b 45 18             	mov    0x18(%ebp),%eax
  800248:	ba 00 00 00 00       	mov    $0x0,%edx
  80024d:	52                   	push   %edx
  80024e:	50                   	push   %eax
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	e8 0e 0b 00 00       	call   800d64 <__udivdi3>
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	ff 75 08             	pushl  0x8(%ebp)
  800261:	e8 ae ff ff ff       	call   800214 <printnum>
  800266:	83 c4 20             	add    $0x20,%esp
  800269:	eb 19                	jmp    800284 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	4b                   	dec    %ebx
  80026c:	85 db                	test   %ebx,%ebx
  80026e:	7e 14                	jle    800284 <printnum+0x70>
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	ff 75 20             	pushl  0x20(%ebp)
  800279:	ff 55 08             	call   *0x8(%ebp)
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	4b                   	dec    %ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ec                	jg     800270 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	8b 45 18             	mov    0x18(%ebp),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	52                   	push   %edx
  800296:	50                   	push   %eax
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	e8 d2 0b 00 00       	call   800e70 <__umoddi3>
  80029e:	83 c4 14             	add    $0x14,%esp
  8002a1:	0f be 80 cd 11 80 00 	movsbl 0x8011cd(%eax),%eax
  8002a8:	50                   	push   %eax
  8002a9:	ff 55 08             	call   *0x8(%ebp)
}
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002bd:	83 f8 01             	cmp    $0x1,%eax
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 11                	mov    (%ecx),%edx
  8002c4:	8d 42 08             	lea    0x8(%edx),%eax
  8002c7:	89 01                	mov    %eax,(%ecx)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x3e>
	else if (lflag)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	74 10                	je     8002e4 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 11                	mov    (%ecx),%edx
  8002d6:	8d 42 04             	lea    0x4(%edx),%eax
  8002d9:	89 01                	mov    %eax,(%ecx)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 11                	mov    (%ecx),%edx
  8002e6:	8d 42 04             	lea    0x4(%edx),%eax
  8002e9:	89 01                	mov    %eax,(%ecx)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002fd:	83 f8 01             	cmp    $0x1,%eax
  800300:	7e 0e                	jle    800310 <getint+0x1c>
		return va_arg(*ap, long long);
  800302:	8b 11                	mov    (%ecx),%edx
  800304:	8d 42 08             	lea    0x8(%edx),%eax
  800307:	89 01                	mov    %eax,(%ecx)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	8b 52 04             	mov    0x4(%edx),%edx
  80030e:	eb 1a                	jmp    80032a <getint+0x36>
	else if (lflag)
  800310:	85 c0                	test   %eax,%eax
  800312:	74 0c                	je     800320 <getint+0x2c>
		return va_arg(*ap, long);
  800314:	8b 01                	mov    (%ecx),%eax
  800316:	8d 50 04             	lea    0x4(%eax),%edx
  800319:	89 11                	mov    %edx,(%ecx)
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	99                   	cltd   
  80031e:	eb 0a                	jmp    80032a <getint+0x36>
	else
		return va_arg(*ap, int);
  800320:	8b 01                	mov    (%ecx),%eax
  800322:	8d 50 04             	lea    0x4(%eax),%edx
  800325:	89 11                	mov    %edx,(%ecx)
  800327:	8b 00                	mov    (%eax),%eax
  800329:	99                   	cltd   
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
  800332:	83 ec 1c             	sub    $0x1c,%esp
  800335:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800338:	0f b6 0b             	movzbl (%ebx),%ecx
  80033b:	43                   	inc    %ebx
  80033c:	83 f9 25             	cmp    $0x25,%ecx
  80033f:	74 1e                	je     80035f <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800341:	85 c9                	test   %ecx,%ecx
  800343:	0f 84 dc 02 00 00    	je     800625 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	51                   	push   %ecx
  800350:	ff 55 08             	call   *0x8(%ebp)
  800353:	83 c4 10             	add    $0x10,%esp
  800356:	0f b6 0b             	movzbl (%ebx),%ecx
  800359:	43                   	inc    %ebx
  80035a:	83 f9 25             	cmp    $0x25,%ecx
  80035d:	75 e2                	jne    800341 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80035f:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800363:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80036a:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80036f:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800374:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	0f b6 0b             	movzbl (%ebx),%ecx
  80037e:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800381:	43                   	inc    %ebx
  800382:	83 f8 55             	cmp    $0x55,%eax
  800385:	0f 87 75 02 00 00    	ja     800600 <vprintfmt+0x2d4>
  80038b:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800392:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800396:	eb e3                	jmp    80037b <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  80039c:	eb dd                	jmp    80037b <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039e:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003a6:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8003aa:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003ad:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003b0:	83 f8 09             	cmp    $0x9,%eax
  8003b3:	77 28                	ja     8003dd <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b5:	43                   	inc    %ebx
  8003b6:	eb eb                	jmp    8003a3 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bb:	8d 42 04             	lea    0x4(%edx),%eax
  8003be:	89 45 14             	mov    %eax,0x14(%ebp)
  8003c1:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8003c3:	eb 18                	jmp    8003dd <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8003c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003c9:	79 b0                	jns    80037b <vprintfmt+0x4f>
				width = 0;
  8003cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8003d2:	eb a7                	jmp    80037b <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003d4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  8003db:	eb 9e                	jmp    80037b <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  8003dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003e1:	79 98                	jns    80037b <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003e3:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8003e6:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003eb:	eb 8e                	jmp    80037b <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ed:	47                   	inc    %edi
			goto reswitch;
  8003ee:	eb 8b                	jmp    80037b <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	ff 75 0c             	pushl  0xc(%ebp)
  8003f6:	8b 55 14             	mov    0x14(%ebp),%edx
  8003f9:	8d 42 04             	lea    0x4(%edx),%eax
  8003fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ff:	ff 32                	pushl  (%edx)
  800401:	ff 55 08             	call   *0x8(%ebp)
			break;
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	e9 2c ff ff ff       	jmp    800338 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 55 14             	mov    0x14(%ebp),%edx
  80040f:	8d 42 04             	lea    0x4(%edx),%eax
  800412:	89 45 14             	mov    %eax,0x14(%ebp)
  800415:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800417:	85 c0                	test   %eax,%eax
  800419:	79 02                	jns    80041d <vprintfmt+0xf1>
				err = -err;
  80041b:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x101>
  800422:	8b 3c 85 20 12 80 00 	mov    0x801220(,%eax,4),%edi
  800429:	85 ff                	test   %edi,%edi
  80042b:	75 19                	jne    800446 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 de 11 80 00       	push   $0x8011de
  800433:	ff 75 0c             	pushl  0xc(%ebp)
  800436:	ff 75 08             	pushl  0x8(%ebp)
  800439:	e8 ef 01 00 00       	call   80062d <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	e9 f2 fe ff ff       	jmp    800338 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800446:	57                   	push   %edi
  800447:	68 e7 11 80 00       	push   $0x8011e7
  80044c:	ff 75 0c             	pushl  0xc(%ebp)
  80044f:	ff 75 08             	pushl  0x8(%ebp)
  800452:	e8 d6 01 00 00       	call   80062d <printfmt>
  800457:	83 c4 10             	add    $0x10,%esp
			break;
  80045a:	e9 d9 fe ff ff       	jmp    800338 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045f:	8b 55 14             	mov    0x14(%ebp),%edx
  800462:	8d 42 04             	lea    0x4(%edx),%eax
  800465:	89 45 14             	mov    %eax,0x14(%ebp)
  800468:	8b 3a                	mov    (%edx),%edi
  80046a:	85 ff                	test   %edi,%edi
  80046c:	75 05                	jne    800473 <vprintfmt+0x147>
				p = "(null)";
  80046e:	bf ea 11 80 00       	mov    $0x8011ea,%edi
			if (width > 0 && padc != '-')
  800473:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800477:	7e 3b                	jle    8004b4 <vprintfmt+0x188>
  800479:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  80047d:	74 35                	je     8004b4 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	56                   	push   %esi
  800483:	57                   	push   %edi
  800484:	e8 58 02 00 00       	call   8006e1 <strnlen>
  800489:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800493:	7e 1f                	jle    8004b4 <vprintfmt+0x188>
  800495:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	ff 4d f0             	decl   -0x10(%ebp)
  8004ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004b2:	7f e8                	jg     80049c <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b4:	0f be 0f             	movsbl (%edi),%ecx
  8004b7:	47                   	inc    %edi
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	74 44                	je     800500 <vprintfmt+0x1d4>
  8004bc:	85 f6                	test   %esi,%esi
  8004be:	78 03                	js     8004c3 <vprintfmt+0x197>
  8004c0:	4e                   	dec    %esi
  8004c1:	78 3d                	js     800500 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8004c7:	74 18                	je     8004e1 <vprintfmt+0x1b5>
  8004c9:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 10                	jbe    8004e1 <vprintfmt+0x1b5>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	6a 3f                	push   $0x3f
  8004d9:	ff 55 08             	call   *0x8(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb 0d                	jmp    8004ee <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	51                   	push   %ecx
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	ff 4d f0             	decl   -0x10(%ebp)
  8004f1:	0f be 0f             	movsbl (%edi),%ecx
  8004f4:	47                   	inc    %edi
  8004f5:	85 c9                	test   %ecx,%ecx
  8004f7:	74 07                	je     800500 <vprintfmt+0x1d4>
  8004f9:	85 f6                	test   %esi,%esi
  8004fb:	78 c6                	js     8004c3 <vprintfmt+0x197>
  8004fd:	4e                   	dec    %esi
  8004fe:	79 c3                	jns    8004c3 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800500:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800504:	0f 8e 2e fe ff ff    	jle    800338 <vprintfmt+0xc>
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	6a 20                	push   $0x20
  800512:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	ff 4d f0             	decl   -0x10(%ebp)
  80051b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80051f:	7f e9                	jg     80050a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800521:	e9 12 fe ff ff       	jmp    800338 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800526:	57                   	push   %edi
  800527:	8d 45 14             	lea    0x14(%ebp),%eax
  80052a:	50                   	push   %eax
  80052b:	e8 c4 fd ff ff       	call   8002f4 <getint>
  800530:	89 c6                	mov    %eax,%esi
  800532:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800534:	83 c4 08             	add    $0x8,%esp
  800537:	85 d2                	test   %edx,%edx
  800539:	79 15                	jns    800550 <vprintfmt+0x224>
				putch('-', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	6a 2d                	push   $0x2d
  800543:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800546:	f7 de                	neg    %esi
  800548:	83 d7 00             	adc    $0x0,%edi
  80054b:	f7 df                	neg    %edi
  80054d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800550:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800555:	eb 76                	jmp    8005cd <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800557:	57                   	push   %edi
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	e8 53 fd ff ff       	call   8002b4 <getuint>
  800561:	89 c6                	mov    %eax,%esi
  800563:	89 d7                	mov    %edx,%edi
			base = 10;
  800565:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80056a:	83 c4 08             	add    $0x8,%esp
  80056d:	eb 5e                	jmp    8005cd <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80056f:	57                   	push   %edi
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
  800573:	50                   	push   %eax
  800574:	e8 3b fd ff ff       	call   8002b4 <getuint>
  800579:	89 c6                	mov    %eax,%esi
  80057b:	89 d7                	mov    %edx,%edi
			base = 8;
  80057d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800582:	83 c4 08             	add    $0x8,%esp
  800585:	eb 46                	jmp    8005cd <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	ff 75 0c             	pushl  0xc(%ebp)
  80058d:	6a 30                	push   $0x30
  80058f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800592:	83 c4 08             	add    $0x8,%esp
  800595:	ff 75 0c             	pushl  0xc(%ebp)
  800598:	6a 78                	push   $0x78
  80059a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80059d:	8b 55 14             	mov    0x14(%ebp),%edx
  8005a0:	8d 42 04             	lea    0x4(%edx),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a6:	8b 32                	mov    (%edx),%esi
  8005a8:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ad:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 16                	jmp    8005cd <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005b7:	57                   	push   %edi
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	50                   	push   %eax
  8005bc:	e8 f3 fc ff ff       	call   8002b4 <getuint>
  8005c1:	89 c6                	mov    %eax,%esi
  8005c3:	89 d7                	mov    %edx,%edi
			base = 16;
  8005c5:	ba 10 00 00 00       	mov    $0x10,%edx
  8005ca:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005cd:	83 ec 04             	sub    $0x4,%esp
  8005d0:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8005d8:	52                   	push   %edx
  8005d9:	57                   	push   %edi
  8005da:	56                   	push   %esi
  8005db:	ff 75 0c             	pushl  0xc(%ebp)
  8005de:	ff 75 08             	pushl  0x8(%ebp)
  8005e1:	e8 2e fc ff ff       	call   800214 <printnum>
			break;
  8005e6:	83 c4 20             	add    $0x20,%esp
  8005e9:	e9 4a fd ff ff       	jmp    800338 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	51                   	push   %ecx
  8005f5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	e9 38 fd ff ff       	jmp    800338 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	ff 75 0c             	pushl  0xc(%ebp)
  800606:	6a 25                	push   $0x25
  800608:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80060b:	4b                   	dec    %ebx
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800613:	0f 84 1f fd ff ff    	je     800338 <vprintfmt+0xc>
  800619:	4b                   	dec    %ebx
  80061a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80061e:	75 f9                	jne    800619 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800620:	e9 13 fd ff ff       	jmp    800338 <vprintfmt+0xc>
		}
	}
}
  800625:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800628:	5b                   	pop    %ebx
  800629:	5e                   	pop    %esi
  80062a:	5f                   	pop    %edi
  80062b:	c9                   	leave  
  80062c:	c3                   	ret    

0080062d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800636:	50                   	push   %eax
  800637:	ff 75 10             	pushl  0x10(%ebp)
  80063a:	ff 75 0c             	pushl  0xc(%ebp)
  80063d:	ff 75 08             	pushl  0x8(%ebp)
  800640:	e8 e7 fc ff ff       	call   80032c <vprintfmt>
	va_end(ap);
}
  800645:	c9                   	leave  
  800646:	c3                   	ret    

00800647 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80064d:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800650:	8b 0a                	mov    (%edx),%ecx
  800652:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800655:	73 07                	jae    80065e <sprintputch+0x17>
		*b->buf++ = ch;
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	88 01                	mov    %al,(%ecx)
  80065c:	ff 02                	incl   (%edx)
}
  80065e:	c9                   	leave  
  80065f:	c3                   	ret    

00800660 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	83 ec 18             	sub    $0x18,%esp
  800666:	8b 55 08             	mov    0x8(%ebp),%edx
  800669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80066f:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800673:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800676:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  80067d:	85 d2                	test   %edx,%edx
  80067f:	74 04                	je     800685 <vsnprintf+0x25>
  800681:	85 c9                	test   %ecx,%ecx
  800683:	7f 07                	jg     80068c <vsnprintf+0x2c>
		return -E_INVAL;
  800685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068a:	eb 1d                	jmp    8006a9 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068c:	ff 75 14             	pushl  0x14(%ebp)
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	68 47 06 80 00       	push   $0x800647
  80069b:	e8 8c fc ff ff       	call   80032c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b4:	50                   	push   %eax
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	ff 75 08             	pushl  0x8(%ebp)
  8006be:	e8 9d ff ff ff       	call   800660 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    
  8006c5:	00 00                	add    %al,(%eax)
	...

008006c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d3:	80 3a 00             	cmpb   $0x0,(%edx)
  8006d6:	74 07                	je     8006df <strlen+0x17>
		n++;
  8006d8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d9:	42                   	inc    %edx
  8006da:	80 3a 00             	cmpb   $0x0,(%edx)
  8006dd:	75 f9                	jne    8006d8 <strlen+0x10>
		n++;
	return n;
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    

008006e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	74 0f                	je     800702 <strnlen+0x21>
  8006f3:	80 39 00             	cmpb   $0x0,(%ecx)
  8006f6:	74 0a                	je     800702 <strnlen+0x21>
		n++;
  8006f8:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f9:	41                   	inc    %ecx
  8006fa:	4a                   	dec    %edx
  8006fb:	74 05                	je     800702 <strnlen+0x21>
  8006fd:	80 39 00             	cmpb   $0x0,(%ecx)
  800700:	75 f6                	jne    8006f8 <strnlen+0x17>
		n++;
	return n;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80070e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800710:	8a 02                	mov    (%edx),%al
  800712:	42                   	inc    %edx
  800713:	88 01                	mov    %al,(%ecx)
  800715:	41                   	inc    %ecx
  800716:	84 c0                	test   %al,%al
  800718:	75 f6                	jne    800710 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	5b                   	pop    %ebx
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800726:	53                   	push   %ebx
  800727:	e8 9c ff ff ff       	call   8006c8 <strlen>
	strcpy(dst + len, src);
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800732:	50                   	push   %eax
  800733:	e8 cc ff ff ff       	call   800704 <strcpy>
	return dst;
}
  800738:	89 d8                	mov    %ebx,%eax
  80073a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	57                   	push   %edi
  800743:	56                   	push   %esi
  800744:	53                   	push   %ebx
  800745:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80074e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800750:	bb 00 00 00 00       	mov    $0x0,%ebx
  800755:	39 f3                	cmp    %esi,%ebx
  800757:	73 10                	jae    800769 <strncpy+0x2a>
		*dst++ = *src;
  800759:	8a 02                	mov    (%edx),%al
  80075b:	88 01                	mov    %al,(%ecx)
  80075d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075e:	80 3a 01             	cmpb   $0x1,(%edx)
  800761:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	43                   	inc    %ebx
  800765:	39 f3                	cmp    %esi,%ebx
  800767:	72 f0                	jb     800759 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800769:	89 f8                	mov    %edi,%eax
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80077e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800780:	85 d2                	test   %edx,%edx
  800782:	74 19                	je     80079d <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800784:	4a                   	dec    %edx
  800785:	74 13                	je     80079a <strlcpy+0x2a>
  800787:	80 39 00             	cmpb   $0x0,(%ecx)
  80078a:	74 0e                	je     80079a <strlcpy+0x2a>
  80078c:	8a 01                	mov    (%ecx),%al
  80078e:	41                   	inc    %ecx
  80078f:	88 03                	mov    %al,(%ebx)
  800791:	43                   	inc    %ebx
  800792:	4a                   	dec    %edx
  800793:	74 05                	je     80079a <strlcpy+0x2a>
  800795:	80 39 00             	cmpb   $0x0,(%ecx)
  800798:	75 f2                	jne    80078c <strlcpy+0x1c>
		*dst = '\0';
  80079a:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80079d:	89 d8                	mov    %ebx,%eax
  80079f:	29 f0                	sub    %esi,%eax
}
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8007ae:	80 3a 00             	cmpb   $0x0,(%edx)
  8007b1:	74 13                	je     8007c6 <strcmp+0x21>
  8007b3:	8a 02                	mov    (%edx),%al
  8007b5:	3a 01                	cmp    (%ecx),%al
  8007b7:	75 0d                	jne    8007c6 <strcmp+0x21>
  8007b9:	42                   	inc    %edx
  8007ba:	41                   	inc    %ecx
  8007bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007be:	74 06                	je     8007c6 <strcmp+0x21>
  8007c0:	8a 02                	mov    (%edx),%al
  8007c2:	3a 01                	cmp    (%ecx),%al
  8007c4:	74 f3                	je     8007b9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c6:	0f b6 02             	movzbl (%edx),%eax
  8007c9:	0f b6 11             	movzbl (%ecx),%edx
  8007cc:	29 d0                	sub    %edx,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007dd:	85 c9                	test   %ecx,%ecx
  8007df:	74 1f                	je     800800 <strncmp+0x30>
  8007e1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e4:	74 16                	je     8007fc <strncmp+0x2c>
  8007e6:	8a 02                	mov    (%edx),%al
  8007e8:	3a 03                	cmp    (%ebx),%al
  8007ea:	75 10                	jne    8007fc <strncmp+0x2c>
  8007ec:	42                   	inc    %edx
  8007ed:	43                   	inc    %ebx
  8007ee:	49                   	dec    %ecx
  8007ef:	74 0f                	je     800800 <strncmp+0x30>
  8007f1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f4:	74 06                	je     8007fc <strncmp+0x2c>
  8007f6:	8a 02                	mov    (%edx),%al
  8007f8:	3a 03                	cmp    (%ebx),%al
  8007fa:	74 f0                	je     8007ec <strncmp+0x1c>
	if (n == 0)
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	75 07                	jne    800807 <strncmp+0x37>
		return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
  800805:	eb 0a                	jmp    800811 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800807:	0f b6 12             	movzbl (%edx),%edx
  80080a:	0f b6 03             	movzbl (%ebx),%eax
  80080d:	29 c2                	sub    %eax,%edx
  80080f:	89 d0                	mov    %edx,%eax
}
  800811:	5b                   	pop    %ebx
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80081d:	80 38 00             	cmpb   $0x0,(%eax)
  800820:	74 0a                	je     80082c <strchr+0x18>
		if (*s == c)
  800822:	38 10                	cmp    %dl,(%eax)
  800824:	74 0b                	je     800831 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800826:	40                   	inc    %eax
  800827:	80 38 00             	cmpb   $0x0,(%eax)
  80082a:	75 f6                	jne    800822 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80083c:	80 38 00             	cmpb   $0x0,(%eax)
  80083f:	74 0a                	je     80084b <strfind+0x18>
		if (*s == c)
  800841:	38 10                	cmp    %dl,(%eax)
  800843:	74 06                	je     80084b <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800845:	40                   	inc    %eax
  800846:	80 38 00             	cmpb   $0x0,(%eax)
  800849:	75 f6                	jne    800841 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	57                   	push   %edi
  800851:	8b 7d 08             	mov    0x8(%ebp),%edi
  800854:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800857:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	74 40                	je     80089d <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 30                	jne    800895 <memset+0x48>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 2b                	jne    800895 <memset+0x48>
		c &= 0xFF;
  80086a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
  800874:	c1 e0 18             	shl    $0x18,%eax
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	c1 e2 10             	shl    $0x10,%edx
  80087d:	09 d0                	or     %edx,%eax
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800882:	c1 e2 08             	shl    $0x8,%edx
  800885:	09 d0                	or     %edx,%eax
  800887:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80088a:	c1 e9 02             	shr    $0x2,%ecx
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	fc                   	cld    
  800891:	f3 ab                	rep stos %eax,%es:(%edi)
  800893:	eb 06                	jmp    80089b <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800895:	8b 45 0c             	mov    0xc(%ebp),%eax
  800898:	fc                   	cld    
  800899:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80089b:	89 f8                	mov    %edi,%eax
}
  80089d:	5f                   	pop    %edi
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	57                   	push   %edi
  8008a4:	56                   	push   %esi
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008ae:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008b0:	39 c6                	cmp    %eax,%esi
  8008b2:	73 34                	jae    8008e8 <memmove+0x48>
  8008b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b7:	39 c2                	cmp    %eax,%edx
  8008b9:	76 2d                	jbe    8008e8 <memmove+0x48>
		s += n;
  8008bb:	89 d6                	mov    %edx,%esi
		d += n;
  8008bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	f6 c2 03             	test   $0x3,%dl
  8008c3:	75 1b                	jne    8008e0 <memmove+0x40>
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 13                	jne    8008e0 <memmove+0x40>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 0e                	jne    8008e0 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008d2:	83 ef 04             	sub    $0x4,%edi
  8008d5:	83 ee 04             	sub    $0x4,%esi
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
  8008db:	fd                   	std    
  8008dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008de:	eb 05                	jmp    8008e5 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e0:	4f                   	dec    %edi
  8008e1:	4e                   	dec    %esi
  8008e2:	fd                   	std    
  8008e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e5:	fc                   	cld    
  8008e6:	eb 20                	jmp    800908 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 15                	jne    800905 <memmove+0x65>
  8008f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f6:	75 0d                	jne    800905 <memmove+0x65>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 08                	jne    800905 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	fc                   	cld    
  800901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800903:	eb 03                	jmp    800908 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800905:	fc                   	cld    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 83 ff ff ff       	call   8008a0 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800926:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800929:	8b 55 10             	mov    0x10(%ebp),%edx
  80092c:	4a                   	dec    %edx
  80092d:	83 fa ff             	cmp    $0xffffffff,%edx
  800930:	74 1a                	je     80094c <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800932:	8a 01                	mov    (%ecx),%al
  800934:	3a 03                	cmp    (%ebx),%al
  800936:	74 0c                	je     800944 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800938:	0f b6 d0             	movzbl %al,%edx
  80093b:	0f b6 03             	movzbl (%ebx),%eax
  80093e:	29 c2                	sub    %eax,%edx
  800940:	89 d0                	mov    %edx,%eax
  800942:	eb 0d                	jmp    800951 <memcmp+0x32>
		s1++, s2++;
  800944:	41                   	inc    %ecx
  800945:	43                   	inc    %ebx
  800946:	4a                   	dec    %edx
  800947:	83 fa ff             	cmp    $0xffffffff,%edx
  80094a:	75 e6                	jne    800932 <memcmp+0x13>
	}

	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800951:	5b                   	pop    %ebx
  800952:	c9                   	leave  
  800953:	c3                   	ret    

00800954 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800962:	39 d0                	cmp    %edx,%eax
  800964:	73 09                	jae    80096f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800966:	38 08                	cmp    %cl,(%eax)
  800968:	74 05                	je     80096f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096a:	40                   	inc    %eax
  80096b:	39 d0                	cmp    %edx,%eax
  80096d:	72 f7                	jb     800966 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	57                   	push   %edi
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 55 08             	mov    0x8(%ebp),%edx
  80097a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800980:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800985:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80098a:	80 3a 20             	cmpb   $0x20,(%edx)
  80098d:	74 05                	je     800994 <strtol+0x23>
  80098f:	80 3a 09             	cmpb   $0x9,(%edx)
  800992:	75 0b                	jne    80099f <strtol+0x2e>
  800994:	42                   	inc    %edx
  800995:	80 3a 20             	cmpb   $0x20,(%edx)
  800998:	74 fa                	je     800994 <strtol+0x23>
  80099a:	80 3a 09             	cmpb   $0x9,(%edx)
  80099d:	74 f5                	je     800994 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80099f:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8009a2:	75 03                	jne    8009a7 <strtol+0x36>
		s++;
  8009a4:	42                   	inc    %edx
  8009a5:	eb 0b                	jmp    8009b2 <strtol+0x41>
	else if (*s == '-')
  8009a7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8009aa:	75 06                	jne    8009b2 <strtol+0x41>
		s++, neg = 1;
  8009ac:	42                   	inc    %edx
  8009ad:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	74 05                	je     8009bb <strtol+0x4a>
  8009b6:	83 f9 10             	cmp    $0x10,%ecx
  8009b9:	75 15                	jne    8009d0 <strtol+0x5f>
  8009bb:	80 3a 30             	cmpb   $0x30,(%edx)
  8009be:	75 10                	jne    8009d0 <strtol+0x5f>
  8009c0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009c4:	75 0a                	jne    8009d0 <strtol+0x5f>
		s += 2, base = 16;
  8009c6:	83 c2 02             	add    $0x2,%edx
  8009c9:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009ce:	eb 14                	jmp    8009e4 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8009d0:	85 c9                	test   %ecx,%ecx
  8009d2:	75 10                	jne    8009e4 <strtol+0x73>
  8009d4:	80 3a 30             	cmpb   $0x30,(%edx)
  8009d7:	75 05                	jne    8009de <strtol+0x6d>
		s++, base = 8;
  8009d9:	42                   	inc    %edx
  8009da:	b1 08                	mov    $0x8,%cl
  8009dc:	eb 06                	jmp    8009e4 <strtol+0x73>
	else if (base == 0)
  8009de:	85 c9                	test   %ecx,%ecx
  8009e0:	75 02                	jne    8009e4 <strtol+0x73>
		base = 10;
  8009e2:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e4:	8a 02                	mov    (%edx),%al
  8009e6:	83 e8 30             	sub    $0x30,%eax
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	77 08                	ja     8009f5 <strtol+0x84>
			dig = *s - '0';
  8009ed:	0f be 02             	movsbl (%edx),%eax
  8009f0:	83 e8 30             	sub    $0x30,%eax
  8009f3:	eb 20                	jmp    800a15 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  8009f5:	8a 02                	mov    (%edx),%al
  8009f7:	83 e8 61             	sub    $0x61,%eax
  8009fa:	3c 19                	cmp    $0x19,%al
  8009fc:	77 08                	ja     800a06 <strtol+0x95>
			dig = *s - 'a' + 10;
  8009fe:	0f be 02             	movsbl (%edx),%eax
  800a01:	83 e8 57             	sub    $0x57,%eax
  800a04:	eb 0f                	jmp    800a15 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800a06:	8a 02                	mov    (%edx),%al
  800a08:	83 e8 41             	sub    $0x41,%eax
  800a0b:	3c 19                	cmp    $0x19,%al
  800a0d:	77 12                	ja     800a21 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800a0f:	0f be 02             	movsbl (%edx),%eax
  800a12:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a15:	39 c8                	cmp    %ecx,%eax
  800a17:	7d 08                	jge    800a21 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a19:	42                   	inc    %edx
  800a1a:	0f af d9             	imul   %ecx,%ebx
  800a1d:	01 c3                	add    %eax,%ebx
  800a1f:	eb c3                	jmp    8009e4 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a21:	85 f6                	test   %esi,%esi
  800a23:	74 02                	je     800a27 <strtol+0xb6>
		*endptr = (char *) s;
  800a25:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a27:	89 d8                	mov    %ebx,%eax
  800a29:	85 ff                	test   %edi,%edi
  800a2b:	74 02                	je     800a2f <strtol+0xbe>
  800a2d:	f7 d8                	neg    %eax
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	83 ec 04             	sub    $0x4,%esp
  800a3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a48:	89 f8                	mov    %edi,%eax
  800a4a:	89 fb                	mov    %edi,%ebx
  800a4c:	89 fe                	mov    %edi,%esi
  800a4e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a50:	83 c4 04             	add    $0x4,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a68:	89 fa                	mov    %edi,%edx
  800a6a:	89 f9                	mov    %edi,%ecx
  800a6c:	89 fb                	mov    %edi,%ebx
  800a6e:	89 fe                	mov    %edi,%esi
  800a70:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 0c             	sub    $0xc,%esp
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a83:	b8 03 00 00 00       	mov    $0x3,%eax
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8d:	89 f9                	mov    %edi,%ecx
  800a8f:	89 fb                	mov    %edi,%ebx
  800a91:	89 fe                	mov    %edi,%esi
  800a93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a95:	85 c0                	test   %eax,%eax
  800a97:	7e 17                	jle    800ab0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a99:	83 ec 0c             	sub    $0xc,%esp
  800a9c:	50                   	push   %eax
  800a9d:	6a 03                	push   $0x3
  800a9f:	68 b8 13 80 00       	push   $0x8013b8
  800aa4:	6a 23                	push   $0x23
  800aa6:	68 d5 13 80 00       	push   $0x8013d5
  800aab:	e8 74 f6 ff ff       	call   800124 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	57                   	push   %edi
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800abe:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	89 fa                	mov    %edi,%edx
  800aca:	89 f9                	mov    %edi,%ecx
  800acc:	89 fb                	mov    %edi,%ebx
  800ace:	89 fe                	mov    %edi,%esi
  800ad0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <sys_yield>:

void
sys_yield(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800add:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ae2:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	89 fa                	mov    %edi,%edx
  800ae9:	89 f9                	mov    %edi,%ecx
  800aeb:	89 fb                	mov    %edi,%ebx
  800aed:	89 fe                	mov    %edi,%esi
  800aef:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    

00800af6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	8b 55 08             	mov    0x8(%ebp),%edx
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b08:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	89 fe                	mov    %edi,%esi
  800b14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b16:	85 c0                	test   %eax,%eax
  800b18:	7e 17                	jle    800b31 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	50                   	push   %eax
  800b1e:	6a 04                	push   $0x4
  800b20:	68 b8 13 80 00       	push   $0x8013b8
  800b25:	6a 23                	push   $0x23
  800b27:	68 d5 13 80 00       	push   $0x8013d5
  800b2c:	e8 f3 f5 ff ff       	call   800124 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b4e:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b51:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 05                	push   $0x5
  800b62:	68 b8 13 80 00       	push   $0x8013b8
  800b67:	6a 23                	push   $0x23
  800b69:	68 d5 13 80 00       	push   $0x8013d5
  800b6e:	e8 b1 f5 ff ff       	call   800124 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	89 fb                	mov    %edi,%ebx
  800b96:	89 fe                	mov    %edi,%esi
  800b98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 06                	push   $0x6
  800ba4:	68 b8 13 80 00       	push   $0x8013b8
  800ba9:	6a 23                	push   $0x23
  800bab:	68 d5 13 80 00       	push   $0x8013d5
  800bb0:	e8 6f f5 ff ff       	call   800124 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	89 fb                	mov    %edi,%ebx
  800bd8:	89 fe                	mov    %edi,%esi
  800bda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 08                	push   $0x8
  800be6:	68 b8 13 80 00       	push   $0x8013b8
  800beb:	6a 23                	push   $0x23
  800bed:	68 d5 13 80 00       	push   $0x8013d5
  800bf2:	e8 2d f5 ff ff       	call   800124 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c13:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	89 fb                	mov    %edi,%ebx
  800c1a:	89 fe                	mov    %edi,%esi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 09                	push   $0x9
  800c28:	68 b8 13 80 00       	push   $0x8013b8
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 d5 13 80 00       	push   $0x8013d5
  800c34:	e8 eb f4 ff ff       	call   800124 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    

00800c41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c55:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	89 fb                	mov    %edi,%ebx
  800c5c:	89 fe                	mov    %edi,%esi
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 0a                	push   $0xa
  800c6a:	68 b8 13 80 00       	push   $0x8013b8
  800c6f:	6a 23                	push   $0x23
  800c71:	68 d5 13 80 00       	push   $0x8013d5
  800c76:	e8 a9 f4 ff ff       	call   800124 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c92:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9a:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	c9                   	leave  
  800ca5:	c3                   	ret    

00800ca6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cb2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	89 f9                	mov    %edi,%ecx
  800cbe:	89 fb                	mov    %edi,%ebx
  800cc0:	89 fe                	mov    %edi,%esi
  800cc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 0d                	push   $0xd
  800cce:	68 b8 13 80 00       	push   $0x8013b8
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 d5 13 80 00       	push   $0x8013d5
  800cda:	e8 45 f4 ff ff       	call   800124 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    
	...

00800ce8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cee:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cf5:	75 35                	jne    800d2c <set_pgfault_handler+0x44>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);
  800cf7:	83 ec 04             	sub    $0x4,%esp
  800cfa:	6a 07                	push   $0x7
  800cfc:	68 00 f0 bf ee       	push   $0xeebff000
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	e8 af fd ff ff       	call   800ab8 <sys_getenvid>
  800d09:	89 04 24             	mov    %eax,(%esp)
  800d0c:	e8 e5 fd ff ff       	call   800af6 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800d11:	83 c4 08             	add    $0x8,%esp
  800d14:	68 38 0d 80 00       	push   $0x800d38
  800d19:	83 ec 04             	sub    $0x4,%esp
  800d1c:	e8 97 fd ff ff       	call   800ab8 <sys_getenvid>
  800d21:	89 04 24             	mov    %eax,(%esp)
  800d24:	e8 18 ff ff ff       	call   800c41 <sys_env_set_pgfault_upcall>
  800d29:	83 c4 10             	add    $0x10,%esp
//		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	a3 08 20 80 00       	mov    %eax,0x802008
//	cprintf("_pgfault_upcall: %08x\n", thisenv->env_pgfault_upcall);
//	cprintf("_pgfault_handler is %08x\n", _pgfault_handler);
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    
	...

00800d38 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTrapframe
  800d38:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d39:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d3e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d40:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  800d43:	89 e3                	mov    %esp,%ebx

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp
	movl 48(%esp), %ecx
  800d45:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// trap-time eip
	movl 40(%esp), %edx 
  800d49:	8b 54 24 28          	mov    0x28(%esp),%edx
	// switch to trap-time esp 
	movl %ecx, %esp 
  800d4d:	89 cc                	mov    %ecx,%esp
	// push trap-time eip to trap-time stack 
	pushl %edx 
  800d4f:	52                   	push   %edx
	// return to user exception stack 
	movl %ebx, %esp 
  800d50:	89 dc                	mov    %ebx,%esp
	// update the trap-time esp stored in exception stack(because of pushed eip
	subl $4, %ecx
  800d52:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx, 48(%esp)
  800d55:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// restore general registars, ignoring fault_va & err
	addl $8, %esp
  800d59:	83 c4 08             	add    $0x8,%esp
	popal
  800d5c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// skipping trap-time eip 
	addl $4, %esp
  800d5d:	83 c4 04             	add    $0x4,%esp
	// restore eflags
	popfl
  800d60:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d61:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800d62:	c3                   	ret    
	...

00800d64 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	83 ec 14             	sub    $0x14,%esp
  800d6c:	8b 55 14             	mov    0x14(%ebp),%edx
  800d6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800d72:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d75:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d78:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d7a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800d80:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d83:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d85:	75 11                	jne    800d98 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800d87:	39 f8                	cmp    %edi,%eax
  800d89:	76 4d                	jbe    800dd8 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d8b:	89 fa                	mov    %edi,%edx
  800d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d90:	f7 75 e4             	divl   -0x1c(%ebp)
  800d93:	89 c7                	mov    %eax,%edi
  800d95:	eb 09                	jmp    800da0 <__udivdi3+0x3c>
  800d97:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d98:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800d9b:	76 17                	jbe    800db4 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800d9d:	31 ff                	xor    %edi,%edi
  800d9f:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800da0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da7:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800daa:	83 c4 14             	add    $0x14,%esp
  800dad:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dae:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db0:	5f                   	pop    %edi
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    
  800db3:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800db4:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800db8:	89 c7                	mov    %eax,%edi
  800dba:	83 f7 1f             	xor    $0x1f,%edi
  800dbd:	75 4d                	jne    800e0c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dbf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800dc2:	77 0a                	ja     800dce <__udivdi3+0x6a>
  800dc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800dc7:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc9:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800dcc:	72 d2                	jb     800da0 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800dce:	bf 01 00 00 00       	mov    $0x1,%edi
  800dd3:	eb cb                	jmp    800da0 <__udivdi3+0x3c>
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	75 0e                	jne    800ded <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ddf:	b8 01 00 00 00       	mov    $0x1,%eax
  800de4:	31 c9                	xor    %ecx,%ecx
  800de6:	31 d2                	xor    %edx,%edx
  800de8:	f7 f1                	div    %ecx
  800dea:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ded:	89 f0                	mov    %esi,%eax
  800def:	31 d2                	xor    %edx,%edx
  800df1:	f7 75 e4             	divl   -0x1c(%ebp)
  800df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfa:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfd:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e00:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e03:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e05:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e06:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e08:	5f                   	pop    %edi
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    
  800e0b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e11:	29 f8                	sub    %edi,%eax
  800e13:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e16:	89 f9                	mov    %edi,%ecx
  800e18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e1b:	d3 e2                	shl    %cl,%edx
  800e1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e20:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e23:	d3 e8                	shr    %cl,%eax
  800e25:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800e27:	89 f9                	mov    %edi,%ecx
  800e29:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e2f:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800e36:	89 f9                	mov    %edi,%ecx
  800e38:	d3 e6                	shl    %cl,%esi
  800e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3d:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e40:	d3 e8                	shr    %cl,%eax
  800e42:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800e44:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	f7 75 f4             	divl   -0xc(%ebp)
  800e4b:	89 d6                	mov    %edx,%esi
  800e4d:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e4f:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e55:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e57:	39 f2                	cmp    %esi,%edx
  800e59:	77 0f                	ja     800e6a <__udivdi3+0x106>
  800e5b:	0f 85 3f ff ff ff    	jne    800da0 <__udivdi3+0x3c>
  800e61:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e64:	0f 86 36 ff ff ff    	jbe    800da0 <__udivdi3+0x3c>
		{
		  q0--;
  800e6a:	4f                   	dec    %edi
  800e6b:	e9 30 ff ff ff       	jmp    800da0 <__udivdi3+0x3c>

00800e70 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	83 ec 30             	sub    $0x30,%esp
  800e78:	8b 55 14             	mov    0x14(%ebp),%edx
  800e7b:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800e7e:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e80:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e83:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e8b:	85 ff                	test   %edi,%edi
  800e8d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e94:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e9b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800ea1:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ea4:	75 3e                	jne    800ee4 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800ea6:	39 d6                	cmp    %edx,%esi
  800ea8:	0f 86 a2 00 00 00    	jbe    800f50 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eae:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800eb0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800eb3:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb5:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800eb8:	74 1b                	je     800ed5 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800eba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ebd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800ec0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ecd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ed0:	89 10                	mov    %edx,(%eax)
  800ed2:	89 48 04             	mov    %ecx,0x4(%eax)
  800ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800edb:	83 c4 30             	add    $0x30,%esp
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    
  800ee2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ee4:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800ee7:	76 1f                	jbe    800f08 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800eec:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800eef:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800ef2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800efb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800efe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f01:	83 c4 30             	add    $0x30,%esp
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f08:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f0b:	83 f0 1f             	xor    $0x1f,%eax
  800f0e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f11:	75 61                	jne    800f74 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f13:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800f16:	77 05                	ja     800f1d <__umoddi3+0xad>
  800f18:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800f1b:	72 10                	jb     800f2d <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f1d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f20:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f23:	29 f0                	sub    %esi,%eax
  800f25:	19 fa                	sbb    %edi,%edx
  800f27:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f2a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800f2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f30:	85 d2                	test   %edx,%edx
  800f32:	74 a1                	je     800ed5 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800f34:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800f37:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800f3d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800f40:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f43:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f49:	89 01                	mov    %eax,(%ecx)
  800f4b:	89 51 04             	mov    %edx,0x4(%ecx)
  800f4e:	eb 85                	jmp    800ed5 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f50:	85 f6                	test   %esi,%esi
  800f52:	75 0b                	jne    800f5f <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f54:	b8 01 00 00 00       	mov    $0x1,%eax
  800f59:	31 d2                	xor    %edx,%edx
  800f5b:	f7 f6                	div    %esi
  800f5d:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f62:	89 fa                	mov    %edi,%edx
  800f64:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f66:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f69:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6c:	f7 f6                	div    %esi
  800f6e:	e9 3d ff ff ff       	jmp    800eb0 <__umoddi3+0x40>
  800f73:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f74:	b8 20 00 00 00       	mov    $0x20,%eax
  800f79:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800f7c:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800f7f:	89 fa                	mov    %edi,%edx
  800f81:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f84:	d3 e2                	shl    %cl,%edx
  800f86:	89 f0                	mov    %esi,%eax
  800f88:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f8b:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800f8d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f90:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f92:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f94:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f97:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f9a:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f9c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f9e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fa1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800fa4:	d3 e0                	shl    %cl,%eax
  800fa6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800fa9:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800faf:	d3 e8                	shr    %cl,%eax
  800fb1:	0b 45 cc             	or     -0x34(%ebp),%eax
  800fb4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800fb7:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fba:	f7 f7                	div    %edi
  800fbc:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fbf:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800fc2:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800fc7:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fca:	77 0a                	ja     800fd6 <__umoddi3+0x166>
  800fcc:	75 12                	jne    800fe0 <__umoddi3+0x170>
  800fce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fd1:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800fd4:	76 0a                	jbe    800fe0 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fd6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800fd9:	29 f1                	sub    %esi,%ecx
  800fdb:	19 fa                	sbb    %edi,%edx
  800fdd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800fe0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	0f 84 ea fe ff ff    	je     800ed5 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800feb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800fee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ff1:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800ff4:	19 d1                	sbb    %edx,%ecx
  800ff6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ff9:	89 ca                	mov    %ecx,%edx
  800ffb:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ffe:	d3 e2                	shl    %cl,%edx
  801000:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801003:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801006:	d3 e8                	shr    %cl,%eax
  801008:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80100a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80100d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80100f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801012:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801015:	e9 ad fe ff ff       	jmp    800ec7 <__umoddi3+0x57>
