
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
  800046:	e8 9d 01 00 00       	call   8001e8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	89 d8                	mov    %ebx,%eax
  800050:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800055:	6a 07                	push   $0x7
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 7f 0a 00 00       	call   800ade <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 40 10 80 00       	push   $0x801040
  800070:	6a 0f                	push   $0xf
  800072:	68 2a 10 80 00       	push   $0x80102a
  800077:	e8 90 00 00 00       	call   80010c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 6c 10 80 00       	push   $0x80106c
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 09 06 00 00       	call   800693 <snprintf>
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
  80009a:	e8 31 0c 00 00       	call   800cd0 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  80009f:	83 c4 08             	add    $0x8,%esp
  8000a2:	6a 04                	push   $0x4
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	e8 6e 09 00 00       	call   800a1c <sys_cputs>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000bb:	e8 e0 09 00 00       	call   800aa0 <sys_getenvid>
  8000c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c5:	89 c2                	mov    %eax,%edx
  8000c7:	c1 e2 05             	shl    $0x5,%edx
  8000ca:	29 c2                	sub    %eax,%edx
  8000cc:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000d3:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d9:	85 f6                	test   %esi,%esi
  8000db:	7e 07                	jle    8000e4 <libmain+0x34>
		binaryname = argv[0];
  8000dd:	8b 03                	mov    (%ebx),%eax
  8000df:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	53                   	push   %ebx
  8000e8:	56                   	push   %esi
  8000e9:	e8 a1 ff ff ff       	call   80008f <umain>

	// exit gracefully
	exit();
  8000ee:	e8 09 00 00 00       	call   8000fc <exit>
}
  8000f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    
	...

008000fc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800102:	6a 00                	push   $0x0
  800104:	e8 56 09 00 00       	call   800a5f <sys_env_destroy>
}
  800109:	c9                   	leave  
  80010a:	c3                   	ret    
	...

0080010c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800113:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800116:	ff 75 0c             	pushl  0xc(%ebp)
  800119:	ff 75 08             	pushl  0x8(%ebp)
  80011c:	ff 35 00 20 80 00    	pushl  0x802000
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	e8 76 09 00 00       	call   800aa0 <sys_getenvid>
  80012a:	83 c4 08             	add    $0x8,%esp
  80012d:	50                   	push   %eax
  80012e:	68 98 10 80 00       	push   $0x801098
  800133:	e8 b0 00 00 00       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800138:	83 c4 18             	add    $0x18,%esp
  80013b:	53                   	push   %ebx
  80013c:	ff 75 10             	pushl  0x10(%ebp)
  80013f:	e8 53 00 00 00       	call   800197 <vcprintf>
	cprintf("\n");
  800144:	c7 04 24 28 10 80 00 	movl   $0x801028,(%esp)
  80014b:	e8 98 00 00 00       	call   8001e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800150:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800153:	cc                   	int3   
  800154:	eb fd                	jmp    800153 <_panic+0x47>
	...

00800158 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	53                   	push   %ebx
  80015c:	83 ec 04             	sub    $0x4,%esp
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800162:	8b 03                	mov    (%ebx),%eax
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  80016b:	40                   	inc    %eax
  80016c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 96 08 00 00       	call   800a1c <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	ff 43 04             	incl   0x4(%ebx)
}
  800192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a0:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8001a7:	00 00 00 
	b.cnt = 0;
  8001aa:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8001b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b4:	ff 75 0c             	pushl  0xc(%ebp)
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	68 58 01 80 00       	push   $0x800158
  8001c6:	e8 49 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cb:	83 c4 08             	add    $0x8,%esp
  8001ce:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  8001d4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 3c 08 00 00       	call   800a1c <sys_cputs>

	return b.cnt;
  8001e0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	50                   	push   %eax
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	e8 9d ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	8b 75 10             	mov    0x10(%ebp),%esi
  800208:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020e:	8b 45 18             	mov    0x18(%ebp),%eax
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	39 fa                	cmp    %edi,%edx
  800218:	77 39                	ja     800253 <printnum+0x57>
  80021a:	72 04                	jb     800220 <printnum+0x24>
  80021c:	39 f0                	cmp    %esi,%eax
  80021e:	77 33                	ja     800253 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	ff 75 20             	pushl  0x20(%ebp)
  800226:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800229:	50                   	push   %eax
  80022a:	ff 75 18             	pushl  0x18(%ebp)
  80022d:	8b 45 18             	mov    0x18(%ebp),%eax
  800230:	ba 00 00 00 00       	mov    $0x0,%edx
  800235:	52                   	push   %edx
  800236:	50                   	push   %eax
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	e8 0e 0b 00 00       	call   800d4c <__udivdi3>
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	52                   	push   %edx
  800242:	50                   	push   %eax
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	e8 ae ff ff ff       	call   8001fc <printnum>
  80024e:	83 c4 20             	add    $0x20,%esp
  800251:	eb 19                	jmp    80026c <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	4b                   	dec    %ebx
  800254:	85 db                	test   %ebx,%ebx
  800256:	7e 14                	jle    80026c <printnum+0x70>
  800258:	83 ec 08             	sub    $0x8,%esp
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	ff 75 20             	pushl  0x20(%ebp)
  800261:	ff 55 08             	call   *0x8(%ebp)
  800264:	83 c4 10             	add    $0x10,%esp
  800267:	4b                   	dec    %ebx
  800268:	85 db                	test   %ebx,%ebx
  80026a:	7f ec                	jg     800258 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	ff 75 0c             	pushl  0xc(%ebp)
  800272:	8b 45 18             	mov    0x18(%ebp),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	83 ec 04             	sub    $0x4,%esp
  80027d:	52                   	push   %edx
  80027e:	50                   	push   %eax
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	e8 d2 0b 00 00       	call   800e58 <__umoddi3>
  800286:	83 c4 14             	add    $0x14,%esp
  800289:	0f be 80 cd 11 80 00 	movsbl 0x8011cd(%eax),%eax
  800290:	50                   	push   %eax
  800291:	ff 55 08             	call   *0x8(%ebp)
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002a5:	83 f8 01             	cmp    $0x1,%eax
  8002a8:	7e 0e                	jle    8002b8 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8002aa:	8b 11                	mov    (%ecx),%edx
  8002ac:	8d 42 08             	lea    0x8(%edx),%eax
  8002af:	89 01                	mov    %eax,(%ecx)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	8b 52 04             	mov    0x4(%edx),%edx
  8002b6:	eb 22                	jmp    8002da <getuint+0x3e>
	else if (lflag)
  8002b8:	85 c0                	test   %eax,%eax
  8002ba:	74 10                	je     8002cc <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8002bc:	8b 11                	mov    (%ecx),%edx
  8002be:	8d 42 04             	lea    0x4(%edx),%eax
  8002c1:	89 01                	mov    %eax,(%ecx)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ca:	eb 0e                	jmp    8002da <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  8002cc:	8b 11                	mov    (%ecx),%edx
  8002ce:	8d 42 04             	lea    0x4(%edx),%eax
  8002d1:	89 01                	mov    %eax,(%ecx)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002e5:	83 f8 01             	cmp    $0x1,%eax
  8002e8:	7e 0e                	jle    8002f8 <getint+0x1c>
		return va_arg(*ap, long long);
  8002ea:	8b 11                	mov    (%ecx),%edx
  8002ec:	8d 42 08             	lea    0x8(%edx),%eax
  8002ef:	89 01                	mov    %eax,(%ecx)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 1a                	jmp    800312 <getint+0x36>
	else if (lflag)
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	74 0c                	je     800308 <getint+0x2c>
		return va_arg(*ap, long);
  8002fc:	8b 01                	mov    (%ecx),%eax
  8002fe:	8d 50 04             	lea    0x4(%eax),%edx
  800301:	89 11                	mov    %edx,(%ecx)
  800303:	8b 00                	mov    (%eax),%eax
  800305:	99                   	cltd   
  800306:	eb 0a                	jmp    800312 <getint+0x36>
	else
		return va_arg(*ap, int);
  800308:	8b 01                	mov    (%ecx),%eax
  80030a:	8d 50 04             	lea    0x4(%eax),%edx
  80030d:	89 11                	mov    %edx,(%ecx)
  80030f:	8b 00                	mov    (%eax),%eax
  800311:	99                   	cltd   
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 1c             	sub    $0x1c,%esp
  80031d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800320:	0f b6 0b             	movzbl (%ebx),%ecx
  800323:	43                   	inc    %ebx
  800324:	83 f9 25             	cmp    $0x25,%ecx
  800327:	74 1e                	je     800347 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800329:	85 c9                	test   %ecx,%ecx
  80032b:	0f 84 dc 02 00 00    	je     80060d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	ff 75 0c             	pushl  0xc(%ebp)
  800337:	51                   	push   %ecx
  800338:	ff 55 08             	call   *0x8(%ebp)
  80033b:	83 c4 10             	add    $0x10,%esp
  80033e:	0f b6 0b             	movzbl (%ebx),%ecx
  800341:	43                   	inc    %ebx
  800342:	83 f9 25             	cmp    $0x25,%ecx
  800345:	75 e2                	jne    800329 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800347:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80034b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800352:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  800357:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  80035c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	0f b6 0b             	movzbl (%ebx),%ecx
  800366:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800369:	43                   	inc    %ebx
  80036a:	83 f8 55             	cmp    $0x55,%eax
  80036d:	0f 87 75 02 00 00    	ja     8005e8 <vprintfmt+0x2d4>
  800373:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  80037e:	eb e3                	jmp    800363 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800380:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800384:	eb dd                	jmp    800363 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800386:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80038b:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80038e:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800392:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800395:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800398:	83 f8 09             	cmp    $0x9,%eax
  80039b:	77 28                	ja     8003c5 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	43                   	inc    %ebx
  80039e:	eb eb                	jmp    80038b <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8003a3:	8d 42 04             	lea    0x4(%edx),%eax
  8003a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a9:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8003ab:	eb 18                	jmp    8003c5 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8003ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003b1:	79 b0                	jns    800363 <vprintfmt+0x4f>
				width = 0;
  8003b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8003ba:	eb a7                	jmp    800363 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003bc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  8003c3:	eb 9e                	jmp    800363 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  8003c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003c9:	79 98                	jns    800363 <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003cb:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8003ce:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003d3:	eb 8e                	jmp    800363 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d5:	47                   	inc    %edi
			goto reswitch;
  8003d6:	eb 8b                	jmp    800363 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d8:	83 ec 08             	sub    $0x8,%esp
  8003db:	ff 75 0c             	pushl  0xc(%ebp)
  8003de:	8b 55 14             	mov    0x14(%ebp),%edx
  8003e1:	8d 42 04             	lea    0x4(%edx),%eax
  8003e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8003e7:	ff 32                	pushl  (%edx)
  8003e9:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003ec:	83 c4 10             	add    $0x10,%esp
  8003ef:	e9 2c ff ff ff       	jmp    800320 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f4:	8b 55 14             	mov    0x14(%ebp),%edx
  8003f7:	8d 42 04             	lea    0x4(%edx),%eax
  8003fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8003fd:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  8003ff:	85 c0                	test   %eax,%eax
  800401:	79 02                	jns    800405 <vprintfmt+0xf1>
				err = -err;
  800403:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800405:	83 f8 0f             	cmp    $0xf,%eax
  800408:	7f 0b                	jg     800415 <vprintfmt+0x101>
  80040a:	8b 3c 85 20 12 80 00 	mov    0x801220(,%eax,4),%edi
  800411:	85 ff                	test   %edi,%edi
  800413:	75 19                	jne    80042e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800415:	50                   	push   %eax
  800416:	68 de 11 80 00       	push   $0x8011de
  80041b:	ff 75 0c             	pushl  0xc(%ebp)
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	e8 ef 01 00 00       	call   800615 <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	e9 f2 fe ff ff       	jmp    800320 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80042e:	57                   	push   %edi
  80042f:	68 e7 11 80 00       	push   $0x8011e7
  800434:	ff 75 0c             	pushl  0xc(%ebp)
  800437:	ff 75 08             	pushl  0x8(%ebp)
  80043a:	e8 d6 01 00 00       	call   800615 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
			break;
  800442:	e9 d9 fe ff ff       	jmp    800320 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 55 14             	mov    0x14(%ebp),%edx
  80044a:	8d 42 04             	lea    0x4(%edx),%eax
  80044d:	89 45 14             	mov    %eax,0x14(%ebp)
  800450:	8b 3a                	mov    (%edx),%edi
  800452:	85 ff                	test   %edi,%edi
  800454:	75 05                	jne    80045b <vprintfmt+0x147>
				p = "(null)";
  800456:	bf ea 11 80 00       	mov    $0x8011ea,%edi
			if (width > 0 && padc != '-')
  80045b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80045f:	7e 3b                	jle    80049c <vprintfmt+0x188>
  800461:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800465:	74 35                	je     80049c <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	57                   	push   %edi
  80046c:	e8 58 02 00 00       	call   8006c9 <strnlen>
  800471:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80047b:	7e 1f                	jle    80049c <vprintfmt+0x188>
  80047d:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800481:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	ff 75 0c             	pushl  0xc(%ebp)
  80048a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	ff 4d f0             	decl   -0x10(%ebp)
  800496:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80049a:	7f e8                	jg     800484 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049c:	0f be 0f             	movsbl (%edi),%ecx
  80049f:	47                   	inc    %edi
  8004a0:	85 c9                	test   %ecx,%ecx
  8004a2:	74 44                	je     8004e8 <vprintfmt+0x1d4>
  8004a4:	85 f6                	test   %esi,%esi
  8004a6:	78 03                	js     8004ab <vprintfmt+0x197>
  8004a8:	4e                   	dec    %esi
  8004a9:	78 3d                	js     8004e8 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8004af:	74 18                	je     8004c9 <vprintfmt+0x1b5>
  8004b1:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8004b4:	83 f8 5e             	cmp    $0x5e,%eax
  8004b7:	76 10                	jbe    8004c9 <vprintfmt+0x1b5>
					putch('?', putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 0c             	pushl  0xc(%ebp)
  8004bf:	6a 3f                	push   $0x3f
  8004c1:	ff 55 08             	call   *0x8(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	eb 0d                	jmp    8004d6 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	51                   	push   %ecx
  8004d0:	ff 55 08             	call   *0x8(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d6:	ff 4d f0             	decl   -0x10(%ebp)
  8004d9:	0f be 0f             	movsbl (%edi),%ecx
  8004dc:	47                   	inc    %edi
  8004dd:	85 c9                	test   %ecx,%ecx
  8004df:	74 07                	je     8004e8 <vprintfmt+0x1d4>
  8004e1:	85 f6                	test   %esi,%esi
  8004e3:	78 c6                	js     8004ab <vprintfmt+0x197>
  8004e5:	4e                   	dec    %esi
  8004e6:	79 c3                	jns    8004ab <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004ec:	0f 8e 2e fe ff ff    	jle    800320 <vprintfmt+0xc>
				putch(' ', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	6a 20                	push   $0x20
  8004fa:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	ff 4d f0             	decl   -0x10(%ebp)
  800503:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800507:	7f e9                	jg     8004f2 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800509:	e9 12 fe ff ff       	jmp    800320 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80050e:	57                   	push   %edi
  80050f:	8d 45 14             	lea    0x14(%ebp),%eax
  800512:	50                   	push   %eax
  800513:	e8 c4 fd ff ff       	call   8002dc <getint>
  800518:	89 c6                	mov    %eax,%esi
  80051a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80051c:	83 c4 08             	add    $0x8,%esp
  80051f:	85 d2                	test   %edx,%edx
  800521:	79 15                	jns    800538 <vprintfmt+0x224>
				putch('-', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	ff 75 0c             	pushl  0xc(%ebp)
  800529:	6a 2d                	push   $0x2d
  80052b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80052e:	f7 de                	neg    %esi
  800530:	83 d7 00             	adc    $0x0,%edi
  800533:	f7 df                	neg    %edi
  800535:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800538:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80053d:	eb 76                	jmp    8005b5 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80053f:	57                   	push   %edi
  800540:	8d 45 14             	lea    0x14(%ebp),%eax
  800543:	50                   	push   %eax
  800544:	e8 53 fd ff ff       	call   80029c <getuint>
  800549:	89 c6                	mov    %eax,%esi
  80054b:	89 d7                	mov    %edx,%edi
			base = 10;
  80054d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800552:	83 c4 08             	add    $0x8,%esp
  800555:	eb 5e                	jmp    8005b5 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800557:	57                   	push   %edi
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	e8 3b fd ff ff       	call   80029c <getuint>
  800561:	89 c6                	mov    %eax,%esi
  800563:	89 d7                	mov    %edx,%edi
			base = 8;
  800565:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  80056a:	83 c4 08             	add    $0x8,%esp
  80056d:	eb 46                	jmp    8005b5 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	6a 30                	push   $0x30
  800577:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	ff 75 0c             	pushl  0xc(%ebp)
  800580:	6a 78                	push   $0x78
  800582:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800585:	8b 55 14             	mov    0x14(%ebp),%edx
  800588:	8d 42 04             	lea    0x4(%edx),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
  80058e:	8b 32                	mov    (%edx),%esi
  800590:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800595:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 16                	jmp    8005b5 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80059f:	57                   	push   %edi
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	e8 f3 fc ff ff       	call   80029c <getuint>
  8005a9:	89 c6                	mov    %eax,%esi
  8005ab:	89 d7                	mov    %edx,%edi
			base = 16;
  8005ad:	ba 10 00 00 00       	mov    $0x10,%edx
  8005b2:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005b5:	83 ec 04             	sub    $0x4,%esp
  8005b8:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005bc:	50                   	push   %eax
  8005bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8005c0:	52                   	push   %edx
  8005c1:	57                   	push   %edi
  8005c2:	56                   	push   %esi
  8005c3:	ff 75 0c             	pushl  0xc(%ebp)
  8005c6:	ff 75 08             	pushl  0x8(%ebp)
  8005c9:	e8 2e fc ff ff       	call   8001fc <printnum>
			break;
  8005ce:	83 c4 20             	add    $0x20,%esp
  8005d1:	e9 4a fd ff ff       	jmp    800320 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	51                   	push   %ecx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	e9 38 fd ff ff       	jmp    800320 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ee:	6a 25                	push   $0x25
  8005f0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005fb:	0f 84 1f fd ff ff    	je     800320 <vprintfmt+0xc>
  800601:	4b                   	dec    %ebx
  800602:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800606:	75 f9                	jne    800601 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800608:	e9 13 fd ff ff       	jmp    800320 <vprintfmt+0xc>
		}
	}
}
  80060d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800610:	5b                   	pop    %ebx
  800611:	5e                   	pop    %esi
  800612:	5f                   	pop    %edi
  800613:	c9                   	leave  
  800614:	c3                   	ret    

00800615 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80061e:	50                   	push   %eax
  80061f:	ff 75 10             	pushl  0x10(%ebp)
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	ff 75 08             	pushl  0x8(%ebp)
  800628:	e8 e7 fc ff ff       	call   800314 <vprintfmt>
	va_end(ap);
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800635:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800638:	8b 0a                	mov    (%edx),%ecx
  80063a:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80063d:	73 07                	jae    800646 <sprintputch+0x17>
		*b->buf++ = ch;
  80063f:	8b 45 08             	mov    0x8(%ebp),%eax
  800642:	88 01                	mov    %al,(%ecx)
  800644:	ff 02                	incl   (%edx)
}
  800646:	c9                   	leave  
  800647:	c3                   	ret    

00800648 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	83 ec 18             	sub    $0x18,%esp
  80064e:	8b 55 08             	mov    0x8(%ebp),%edx
  800651:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800654:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800657:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80065b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800665:	85 d2                	test   %edx,%edx
  800667:	74 04                	je     80066d <vsnprintf+0x25>
  800669:	85 c9                	test   %ecx,%ecx
  80066b:	7f 07                	jg     800674 <vsnprintf+0x2c>
		return -E_INVAL;
  80066d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800672:	eb 1d                	jmp    800691 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800674:	ff 75 14             	pushl  0x14(%ebp)
  800677:	ff 75 10             	pushl  0x10(%ebp)
  80067a:	8d 45 e8             	lea    -0x18(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	68 2f 06 80 00       	push   $0x80062f
  800683:	e8 8c fc ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800688:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80068b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800691:	c9                   	leave  
  800692:	c3                   	ret    

00800693 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800699:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069c:	50                   	push   %eax
  80069d:	ff 75 10             	pushl  0x10(%ebp)
  8006a0:	ff 75 0c             	pushl  0xc(%ebp)
  8006a3:	ff 75 08             	pushl  0x8(%ebp)
  8006a6:	e8 9d ff ff ff       	call   800648 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    
  8006ad:	00 00                	add    %al,(%eax)
	...

008006b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8006be:	74 07                	je     8006c7 <strlen+0x17>
		n++;
  8006c0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c1:	42                   	inc    %edx
  8006c2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c5:	75 f9                	jne    8006c0 <strlen+0x10>
		n++;
	return n;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	74 0f                	je     8006ea <strnlen+0x21>
  8006db:	80 39 00             	cmpb   $0x0,(%ecx)
  8006de:	74 0a                	je     8006ea <strnlen+0x21>
		n++;
  8006e0:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e1:	41                   	inc    %ecx
  8006e2:	4a                   	dec    %edx
  8006e3:	74 05                	je     8006ea <strnlen+0x21>
  8006e5:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e8:	75 f6                	jne    8006e0 <strnlen+0x17>
		n++;
	return n;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	53                   	push   %ebx
  8006f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006f6:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006f8:	8a 02                	mov    (%edx),%al
  8006fa:	42                   	inc    %edx
  8006fb:	88 01                	mov    %al,(%ecx)
  8006fd:	41                   	inc    %ecx
  8006fe:	84 c0                	test   %al,%al
  800700:	75 f6                	jne    8006f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800702:	89 d8                	mov    %ebx,%eax
  800704:	5b                   	pop    %ebx
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80070e:	53                   	push   %ebx
  80070f:	e8 9c ff ff ff       	call   8006b0 <strlen>
	strcpy(dst + len, src);
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80071a:	50                   	push   %eax
  80071b:	e8 cc ff ff ff       	call   8006ec <strcpy>
	return dst;
}
  800720:	89 d8                	mov    %ebx,%eax
  800722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	57                   	push   %edi
  80072b:	56                   	push   %esi
  80072c:	53                   	push   %ebx
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
  800733:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800736:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800738:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073d:	39 f3                	cmp    %esi,%ebx
  80073f:	73 10                	jae    800751 <strncpy+0x2a>
		*dst++ = *src;
  800741:	8a 02                	mov    (%edx),%al
  800743:	88 01                	mov    %al,(%ecx)
  800745:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800746:	80 3a 01             	cmpb   $0x1,(%edx)
  800749:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074c:	43                   	inc    %ebx
  80074d:	39 f3                	cmp    %esi,%ebx
  80074f:	72 f0                	jb     800741 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800751:	89 f8                	mov    %edi,%eax
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800766:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800768:	85 d2                	test   %edx,%edx
  80076a:	74 19                	je     800785 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80076c:	4a                   	dec    %edx
  80076d:	74 13                	je     800782 <strlcpy+0x2a>
  80076f:	80 39 00             	cmpb   $0x0,(%ecx)
  800772:	74 0e                	je     800782 <strlcpy+0x2a>
  800774:	8a 01                	mov    (%ecx),%al
  800776:	41                   	inc    %ecx
  800777:	88 03                	mov    %al,(%ebx)
  800779:	43                   	inc    %ebx
  80077a:	4a                   	dec    %edx
  80077b:	74 05                	je     800782 <strlcpy+0x2a>
  80077d:	80 39 00             	cmpb   $0x0,(%ecx)
  800780:	75 f2                	jne    800774 <strlcpy+0x1c>
		*dst = '\0';
  800782:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800785:	89 d8                	mov    %ebx,%eax
  800787:	29 f0                	sub    %esi,%eax
}
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 55 08             	mov    0x8(%ebp),%edx
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800796:	80 3a 00             	cmpb   $0x0,(%edx)
  800799:	74 13                	je     8007ae <strcmp+0x21>
  80079b:	8a 02                	mov    (%edx),%al
  80079d:	3a 01                	cmp    (%ecx),%al
  80079f:	75 0d                	jne    8007ae <strcmp+0x21>
  8007a1:	42                   	inc    %edx
  8007a2:	41                   	inc    %ecx
  8007a3:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a6:	74 06                	je     8007ae <strcmp+0x21>
  8007a8:	8a 02                	mov    (%edx),%al
  8007aa:	3a 01                	cmp    (%ecx),%al
  8007ac:	74 f3                	je     8007a1 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ae:	0f b6 02             	movzbl (%edx),%eax
  8007b1:	0f b6 11             	movzbl (%ecx),%edx
  8007b4:	29 d0                	sub    %edx,%eax
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007c5:	85 c9                	test   %ecx,%ecx
  8007c7:	74 1f                	je     8007e8 <strncmp+0x30>
  8007c9:	80 3a 00             	cmpb   $0x0,(%edx)
  8007cc:	74 16                	je     8007e4 <strncmp+0x2c>
  8007ce:	8a 02                	mov    (%edx),%al
  8007d0:	3a 03                	cmp    (%ebx),%al
  8007d2:	75 10                	jne    8007e4 <strncmp+0x2c>
  8007d4:	42                   	inc    %edx
  8007d5:	43                   	inc    %ebx
  8007d6:	49                   	dec    %ecx
  8007d7:	74 0f                	je     8007e8 <strncmp+0x30>
  8007d9:	80 3a 00             	cmpb   $0x0,(%edx)
  8007dc:	74 06                	je     8007e4 <strncmp+0x2c>
  8007de:	8a 02                	mov    (%edx),%al
  8007e0:	3a 03                	cmp    (%ebx),%al
  8007e2:	74 f0                	je     8007d4 <strncmp+0x1c>
	if (n == 0)
  8007e4:	85 c9                	test   %ecx,%ecx
  8007e6:	75 07                	jne    8007ef <strncmp+0x37>
		return 0;
  8007e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ed:	eb 0a                	jmp    8007f9 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ef:	0f b6 12             	movzbl (%edx),%edx
  8007f2:	0f b6 03             	movzbl (%ebx),%eax
  8007f5:	29 c2                	sub    %eax,%edx
  8007f7:	89 d0                	mov    %edx,%eax
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800805:	80 38 00             	cmpb   $0x0,(%eax)
  800808:	74 0a                	je     800814 <strchr+0x18>
		if (*s == c)
  80080a:	38 10                	cmp    %dl,(%eax)
  80080c:	74 0b                	je     800819 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080e:	40                   	inc    %eax
  80080f:	80 38 00             	cmpb   $0x0,(%eax)
  800812:	75 f6                	jne    80080a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800824:	80 38 00             	cmpb   $0x0,(%eax)
  800827:	74 0a                	je     800833 <strfind+0x18>
		if (*s == c)
  800829:	38 10                	cmp    %dl,(%eax)
  80082b:	74 06                	je     800833 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80082d:	40                   	inc    %eax
  80082e:	80 38 00             	cmpb   $0x0,(%eax)
  800831:	75 f6                	jne    800829 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  80083f:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800841:	85 c9                	test   %ecx,%ecx
  800843:	74 40                	je     800885 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800845:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084b:	75 30                	jne    80087d <memset+0x48>
  80084d:	f6 c1 03             	test   $0x3,%cl
  800850:	75 2b                	jne    80087d <memset+0x48>
		c &= 0xFF;
  800852:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	c1 e0 18             	shl    $0x18,%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	c1 e2 10             	shl    $0x10,%edx
  800865:	09 d0                	or     %edx,%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	c1 e2 08             	shl    $0x8,%edx
  80086d:	09 d0                	or     %edx,%eax
  80086f:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800872:	c1 e9 02             	shr    $0x2,%ecx
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800883:	89 f8                	mov    %edi,%eax
}
  800885:	5f                   	pop    %edi
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800893:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800896:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 34                	jae    8008d0 <memmove+0x48>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 c2                	cmp    %eax,%edx
  8008a1:	76 2d                	jbe    8008d0 <memmove+0x48>
		s += n;
  8008a3:	89 d6                	mov    %edx,%esi
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a8:	f6 c2 03             	test   $0x3,%dl
  8008ab:	75 1b                	jne    8008c8 <memmove+0x40>
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 13                	jne    8008c8 <memmove+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 0e                	jne    8008c8 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008ba:	83 ef 04             	sub    $0x4,%edi
  8008bd:	83 ee 04             	sub    $0x4,%esi
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
  8008c3:	fd                   	std    
  8008c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 05                	jmp    8008cd <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c8:	4f                   	dec    %edi
  8008c9:	4e                   	dec    %esi
  8008ca:	fd                   	std    
  8008cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cd:	fc                   	cld    
  8008ce:	eb 20                	jmp    8008f0 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d6:	75 15                	jne    8008ed <memmove+0x65>
  8008d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008de:	75 0d                	jne    8008ed <memmove+0x65>
  8008e0:	f6 c1 03             	test   $0x3,%cl
  8008e3:	75 08                	jne    8008ed <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  8008e5:	c1 e9 02             	shr    $0x2,%ecx
  8008e8:	fc                   	cld    
  8008e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008eb:	eb 03                	jmp    8008f0 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ed:	fc                   	cld    
  8008ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f0:	5e                   	pop    %esi
  8008f1:	5f                   	pop    %edi
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 83 ff ff ff       	call   800888 <memmove>
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80090e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800911:	8b 55 10             	mov    0x10(%ebp),%edx
  800914:	4a                   	dec    %edx
  800915:	83 fa ff             	cmp    $0xffffffff,%edx
  800918:	74 1a                	je     800934 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80091a:	8a 01                	mov    (%ecx),%al
  80091c:	3a 03                	cmp    (%ebx),%al
  80091e:	74 0c                	je     80092c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800920:	0f b6 d0             	movzbl %al,%edx
  800923:	0f b6 03             	movzbl (%ebx),%eax
  800926:	29 c2                	sub    %eax,%edx
  800928:	89 d0                	mov    %edx,%eax
  80092a:	eb 0d                	jmp    800939 <memcmp+0x32>
		s1++, s2++;
  80092c:	41                   	inc    %ecx
  80092d:	43                   	inc    %ebx
  80092e:	4a                   	dec    %edx
  80092f:	83 fa ff             	cmp    $0xffffffff,%edx
  800932:	75 e6                	jne    80091a <memcmp+0x13>
	}

	return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	5b                   	pop    %ebx
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800945:	89 c2                	mov    %eax,%edx
  800947:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094a:	39 d0                	cmp    %edx,%eax
  80094c:	73 09                	jae    800957 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094e:	38 08                	cmp    %cl,(%eax)
  800950:	74 05                	je     800957 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800952:	40                   	inc    %eax
  800953:	39 d0                	cmp    %edx,%eax
  800955:	72 f7                	jb     80094e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 55 08             	mov    0x8(%ebp),%edx
  800962:	8b 75 0c             	mov    0xc(%ebp),%esi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800968:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  80096d:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800972:	80 3a 20             	cmpb   $0x20,(%edx)
  800975:	74 05                	je     80097c <strtol+0x23>
  800977:	80 3a 09             	cmpb   $0x9,(%edx)
  80097a:	75 0b                	jne    800987 <strtol+0x2e>
  80097c:	42                   	inc    %edx
  80097d:	80 3a 20             	cmpb   $0x20,(%edx)
  800980:	74 fa                	je     80097c <strtol+0x23>
  800982:	80 3a 09             	cmpb   $0x9,(%edx)
  800985:	74 f5                	je     80097c <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800987:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80098a:	75 03                	jne    80098f <strtol+0x36>
		s++;
  80098c:	42                   	inc    %edx
  80098d:	eb 0b                	jmp    80099a <strtol+0x41>
	else if (*s == '-')
  80098f:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800992:	75 06                	jne    80099a <strtol+0x41>
		s++, neg = 1;
  800994:	42                   	inc    %edx
  800995:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099a:	85 c9                	test   %ecx,%ecx
  80099c:	74 05                	je     8009a3 <strtol+0x4a>
  80099e:	83 f9 10             	cmp    $0x10,%ecx
  8009a1:	75 15                	jne    8009b8 <strtol+0x5f>
  8009a3:	80 3a 30             	cmpb   $0x30,(%edx)
  8009a6:	75 10                	jne    8009b8 <strtol+0x5f>
  8009a8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ac:	75 0a                	jne    8009b8 <strtol+0x5f>
		s += 2, base = 16;
  8009ae:	83 c2 02             	add    $0x2,%edx
  8009b1:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009b6:	eb 14                	jmp    8009cc <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	75 10                	jne    8009cc <strtol+0x73>
  8009bc:	80 3a 30             	cmpb   $0x30,(%edx)
  8009bf:	75 05                	jne    8009c6 <strtol+0x6d>
		s++, base = 8;
  8009c1:	42                   	inc    %edx
  8009c2:	b1 08                	mov    $0x8,%cl
  8009c4:	eb 06                	jmp    8009cc <strtol+0x73>
	else if (base == 0)
  8009c6:	85 c9                	test   %ecx,%ecx
  8009c8:	75 02                	jne    8009cc <strtol+0x73>
		base = 10;
  8009ca:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cc:	8a 02                	mov    (%edx),%al
  8009ce:	83 e8 30             	sub    $0x30,%eax
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	77 08                	ja     8009dd <strtol+0x84>
			dig = *s - '0';
  8009d5:	0f be 02             	movsbl (%edx),%eax
  8009d8:	83 e8 30             	sub    $0x30,%eax
  8009db:	eb 20                	jmp    8009fd <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  8009dd:	8a 02                	mov    (%edx),%al
  8009df:	83 e8 61             	sub    $0x61,%eax
  8009e2:	3c 19                	cmp    $0x19,%al
  8009e4:	77 08                	ja     8009ee <strtol+0x95>
			dig = *s - 'a' + 10;
  8009e6:	0f be 02             	movsbl (%edx),%eax
  8009e9:	83 e8 57             	sub    $0x57,%eax
  8009ec:	eb 0f                	jmp    8009fd <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  8009ee:	8a 02                	mov    (%edx),%al
  8009f0:	83 e8 41             	sub    $0x41,%eax
  8009f3:	3c 19                	cmp    $0x19,%al
  8009f5:	77 12                	ja     800a09 <strtol+0xb0>
			dig = *s - 'A' + 10;
  8009f7:	0f be 02             	movsbl (%edx),%eax
  8009fa:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009fd:	39 c8                	cmp    %ecx,%eax
  8009ff:	7d 08                	jge    800a09 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a01:	42                   	inc    %edx
  800a02:	0f af d9             	imul   %ecx,%ebx
  800a05:	01 c3                	add    %eax,%ebx
  800a07:	eb c3                	jmp    8009cc <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a09:	85 f6                	test   %esi,%esi
  800a0b:	74 02                	je     800a0f <strtol+0xb6>
		*endptr = (char *) s;
  800a0d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a0f:	89 d8                	mov    %ebx,%eax
  800a11:	85 ff                	test   %edi,%edi
  800a13:	74 02                	je     800a17 <strtol+0xbe>
  800a15:	f7 d8                	neg    %eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	83 ec 04             	sub    $0x4,%esp
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a30:	89 f8                	mov    %edi,%eax
  800a32:	89 fb                	mov    %edi,%ebx
  800a34:	89 fe                	mov    %edi,%esi
  800a36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a38:	83 c4 04             	add    $0x4,%esp
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5f                   	pop    %edi
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a46:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a50:	89 fa                	mov    %edi,%edx
  800a52:	89 f9                	mov    %edi,%ecx
  800a54:	89 fb                	mov    %edi,%ebx
  800a56:	89 fe                	mov    %edi,%esi
  800a58:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	83 ec 0c             	sub    $0xc,%esp
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a75:	89 f9                	mov    %edi,%ecx
  800a77:	89 fb                	mov    %edi,%ebx
  800a79:	89 fe                	mov    %edi,%esi
  800a7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	7e 17                	jle    800a98 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a81:	83 ec 0c             	sub    $0xc,%esp
  800a84:	50                   	push   %eax
  800a85:	6a 03                	push   $0x3
  800a87:	68 b8 13 80 00       	push   $0x8013b8
  800a8c:	6a 23                	push   $0x23
  800a8e:	68 d5 13 80 00       	push   $0x8013d5
  800a93:	e8 74 f6 ff ff       	call   80010c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aab:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	89 fa                	mov    %edi,%edx
  800ab2:	89 f9                	mov    %edi,%ecx
  800ab4:	89 fb                	mov    %edi,%ebx
  800ab6:	89 fe                	mov    %edi,%esi
  800ab8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <sys_yield>:

void
sys_yield(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acf:	89 fa                	mov    %edi,%edx
  800ad1:	89 f9                	mov    %edi,%ecx
  800ad3:	89 fb                	mov    %edi,%ebx
  800ad5:	89 fe                	mov    %edi,%esi
  800ad7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 0c             	sub    $0xc,%esp
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800af0:	b8 04 00 00 00       	mov    $0x4,%eax
  800af5:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afa:	89 fe                	mov    %edi,%esi
  800afc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afe:	85 c0                	test   %eax,%eax
  800b00:	7e 17                	jle    800b19 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	50                   	push   %eax
  800b06:	6a 04                	push   $0x4
  800b08:	68 b8 13 80 00       	push   $0x8013b8
  800b0d:	6a 23                	push   $0x23
  800b0f:	68 d5 13 80 00       	push   $0x8013d5
  800b14:	e8 f3 f5 ff ff       	call   80010c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b36:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b39:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b40:	85 c0                	test   %eax,%eax
  800b42:	7e 17                	jle    800b5b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b44:	83 ec 0c             	sub    $0xc,%esp
  800b47:	50                   	push   %eax
  800b48:	6a 05                	push   $0x5
  800b4a:	68 b8 13 80 00       	push   $0x8013b8
  800b4f:	6a 23                	push   $0x23
  800b51:	68 d5 13 80 00       	push   $0x8013d5
  800b56:	e8 b1 f5 ff ff       	call   80010c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b72:	b8 06 00 00 00       	mov    $0x6,%eax
  800b77:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	89 fb                	mov    %edi,%ebx
  800b7e:	89 fe                	mov    %edi,%esi
  800b80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 06                	push   $0x6
  800b8c:	68 b8 13 80 00       	push   $0x8013b8
  800b91:	6a 23                	push   $0x23
  800b93:	68 d5 13 80 00       	push   $0x8013d5
  800b98:	e8 6f f5 ff ff       	call   80010c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	89 fb                	mov    %edi,%ebx
  800bc0:	89 fe                	mov    %edi,%esi
  800bc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 08                	push   $0x8
  800bce:	68 b8 13 80 00       	push   $0x8013b8
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 d5 13 80 00       	push   $0x8013d5
  800bda:	e8 2d f5 ff ff       	call   80010c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bf6:	b8 09 00 00 00       	mov    $0x9,%eax
  800bfb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	89 fb                	mov    %edi,%ebx
  800c02:	89 fe                	mov    %edi,%esi
  800c04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 09                	push   $0x9
  800c10:	68 b8 13 80 00       	push   $0x8013b8
  800c15:	6a 23                	push   $0x23
  800c17:	68 d5 13 80 00       	push   $0x8013d5
  800c1c:	e8 eb f4 ff ff       	call   80010c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	89 fb                	mov    %edi,%ebx
  800c44:	89 fe                	mov    %edi,%esi
  800c46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 0a                	push   $0xa
  800c52:	68 b8 13 80 00       	push   $0x8013b8
  800c57:	6a 23                	push   $0x23
  800c59:	68 d5 13 80 00       	push   $0x8013d5
  800c5e:	e8 a9 f4 ff ff       	call   80010c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7a:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c7d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c9a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c9f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	89 f9                	mov    %edi,%ecx
  800ca6:	89 fb                	mov    %edi,%ebx
  800ca8:	89 fe                	mov    %edi,%esi
  800caa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 17                	jle    800cc7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 0d                	push   $0xd
  800cb6:	68 b8 13 80 00       	push   $0x8013b8
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 d5 13 80 00       	push   $0x8013d5
  800cc2:	e8 45 f4 ff ff       	call   80010c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    
	...

00800cd0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cd6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cdd:	75 35                	jne    800d14 <set_pgfault_handler+0x44>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);
  800cdf:	83 ec 04             	sub    $0x4,%esp
  800ce2:	6a 07                	push   $0x7
  800ce4:	68 00 f0 bf ee       	push   $0xeebff000
  800ce9:	83 ec 04             	sub    $0x4,%esp
  800cec:	e8 af fd ff ff       	call   800aa0 <sys_getenvid>
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 e5 fd ff ff       	call   800ade <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800cf9:	83 c4 08             	add    $0x8,%esp
  800cfc:	68 20 0d 80 00       	push   $0x800d20
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	e8 97 fd ff ff       	call   800aa0 <sys_getenvid>
  800d09:	89 04 24             	mov    %eax,(%esp)
  800d0c:	e8 18 ff ff ff       	call   800c29 <sys_env_set_pgfault_upcall>
  800d11:	83 c4 10             	add    $0x10,%esp
//		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	a3 08 20 80 00       	mov    %eax,0x802008
//	cprintf("_pgfault_upcall: %08x\n", thisenv->env_pgfault_upcall);
//	cprintf("_pgfault_handler is %08x\n", _pgfault_handler);
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    
	...

00800d20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTrapframe
  800d20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d21:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d28:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  800d2b:	89 e3                	mov    %esp,%ebx

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp
	movl 48(%esp), %ecx
  800d2d:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// trap-time eip
	movl 40(%esp), %edx 
  800d31:	8b 54 24 28          	mov    0x28(%esp),%edx
	// switch to trap-time esp 
	movl %ecx, %esp 
  800d35:	89 cc                	mov    %ecx,%esp
	// push trap-time eip to trap-time stack 
	pushl %edx 
  800d37:	52                   	push   %edx
	// return to user exception stack 
	movl %ebx, %esp 
  800d38:	89 dc                	mov    %ebx,%esp
	// update the trap-time esp stored in exception stack(because of pushed eip
	subl $4, %ecx
  800d3a:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx, 48(%esp)
  800d3d:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// restore general registars, ignoring fault_va & err
	addl $8, %esp
  800d41:	83 c4 08             	add    $0x8,%esp
	popal
  800d44:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// skipping trap-time eip 
	addl $4, %esp
  800d45:	83 c4 04             	add    $0x4,%esp
	// restore eflags
	popfl
  800d48:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d49:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800d4a:	c3                   	ret    
	...

00800d4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	83 ec 14             	sub    $0x14,%esp
  800d54:	8b 55 14             	mov    0x14(%ebp),%edx
  800d57:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d60:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d62:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800d68:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d6b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d6d:	75 11                	jne    800d80 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800d6f:	39 f8                	cmp    %edi,%eax
  800d71:	76 4d                	jbe    800dc0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d73:	89 fa                	mov    %edi,%edx
  800d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d78:	f7 75 e4             	divl   -0x1c(%ebp)
  800d7b:	89 c7                	mov    %eax,%edi
  800d7d:	eb 09                	jmp    800d88 <__udivdi3+0x3c>
  800d7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d80:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800d83:	76 17                	jbe    800d9c <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800d85:	31 ff                	xor    %edi,%edi
  800d87:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800d88:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d8f:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d92:	83 c4 14             	add    $0x14,%esp
  800d95:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d96:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d98:	5f                   	pop    %edi
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    
  800d9b:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d9c:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800da0:	89 c7                	mov    %eax,%edi
  800da2:	83 f7 1f             	xor    $0x1f,%edi
  800da5:	75 4d                	jne    800df4 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800da7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800daa:	77 0a                	ja     800db6 <__udivdi3+0x6a>
  800dac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800daf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800db4:	72 d2                	jb     800d88 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800db6:	bf 01 00 00 00       	mov    $0x1,%edi
  800dbb:	eb cb                	jmp    800d88 <__udivdi3+0x3c>
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	75 0e                	jne    800dd5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dc7:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcc:	31 c9                	xor    %ecx,%ecx
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f1                	div    %ecx
  800dd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dd5:	89 f0                	mov    %esi,%eax
  800dd7:	31 d2                	xor    %edx,%edx
  800dd9:	f7 75 e4             	divl   -0x1c(%ebp)
  800ddc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de2:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de5:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de8:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800deb:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ded:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dee:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800df0:	5f                   	pop    %edi
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
  800df3:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800df4:	b8 20 00 00 00       	mov    $0x20,%eax
  800df9:	29 f8                	sub    %edi,%eax
  800dfb:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800dfe:	89 f9                	mov    %edi,%ecx
  800e00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e03:	d3 e2                	shl    %cl,%edx
  800e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e08:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e0b:	d3 e8                	shr    %cl,%eax
  800e0d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800e0f:	89 f9                	mov    %edi,%ecx
  800e11:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e14:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e17:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e1a:	89 f2                	mov    %esi,%edx
  800e1c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800e1e:	89 f9                	mov    %edi,%ecx
  800e20:	d3 e6                	shl    %cl,%esi
  800e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e25:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e28:	d3 e8                	shr    %cl,%eax
  800e2a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800e2c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e2e:	89 f0                	mov    %esi,%eax
  800e30:	f7 75 f4             	divl   -0xc(%ebp)
  800e33:	89 d6                	mov    %edx,%esi
  800e35:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e37:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e3d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e3f:	39 f2                	cmp    %esi,%edx
  800e41:	77 0f                	ja     800e52 <__udivdi3+0x106>
  800e43:	0f 85 3f ff ff ff    	jne    800d88 <__udivdi3+0x3c>
  800e49:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e4c:	0f 86 36 ff ff ff    	jbe    800d88 <__udivdi3+0x3c>
		{
		  q0--;
  800e52:	4f                   	dec    %edi
  800e53:	e9 30 ff ff ff       	jmp    800d88 <__udivdi3+0x3c>

00800e58 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	83 ec 30             	sub    $0x30,%esp
  800e60:	8b 55 14             	mov    0x14(%ebp),%edx
  800e63:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800e66:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e68:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e6b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e73:	85 ff                	test   %edi,%edi
  800e75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e83:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e86:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800e89:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e8c:	75 3e                	jne    800ecc <__umoddi3+0x74>
    {
      if (d0 > n1)
  800e8e:	39 d6                	cmp    %edx,%esi
  800e90:	0f 86 a2 00 00 00    	jbe    800f38 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e96:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e98:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e9b:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e9d:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800ea0:	74 1b                	je     800ebd <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800ea2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ea5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800ea8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800eb5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800eb8:	89 10                	mov    %edx,(%eax)
  800eba:	89 48 04             	mov    %ecx,0x4(%eax)
  800ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec3:	83 c4 30             	add    $0x30,%esp
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    
  800eca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ecc:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800ecf:	76 1f                	jbe    800ef0 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800ed4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ed7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800eda:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800edd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ee0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ee3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ee6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee9:	83 c4 30             	add    $0x30,%esp
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ef0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ef3:	83 f0 1f             	xor    $0x1f,%eax
  800ef6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ef9:	75 61                	jne    800f5c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800efb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800efe:	77 05                	ja     800f05 <__umoddi3+0xad>
  800f00:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800f03:	72 10                	jb     800f15 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f05:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f08:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f0b:	29 f0                	sub    %esi,%eax
  800f0d:	19 fa                	sbb    %edi,%edx
  800f0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f12:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800f15:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f18:	85 d2                	test   %edx,%edx
  800f1a:	74 a1                	je     800ebd <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800f1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800f1f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f22:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800f25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800f28:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f31:	89 01                	mov    %eax,(%ecx)
  800f33:	89 51 04             	mov    %edx,0x4(%ecx)
  800f36:	eb 85                	jmp    800ebd <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f38:	85 f6                	test   %esi,%esi
  800f3a:	75 0b                	jne    800f47 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f41:	31 d2                	xor    %edx,%edx
  800f43:	f7 f6                	div    %esi
  800f45:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f47:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f4a:	89 fa                	mov    %edi,%edx
  800f4c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f51:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f54:	f7 f6                	div    %esi
  800f56:	e9 3d ff ff ff       	jmp    800e98 <__umoddi3+0x40>
  800f5b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f61:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800f64:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800f67:	89 fa                	mov    %edi,%edx
  800f69:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f6c:	d3 e2                	shl    %cl,%edx
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f73:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800f75:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f78:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f7a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f7c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f7f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f82:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f84:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f86:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f89:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f8c:	d3 e0                	shl    %cl,%eax
  800f8e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800f91:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	0b 45 cc             	or     -0x34(%ebp),%eax
  800f9c:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800f9f:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fa2:	f7 f7                	div    %edi
  800fa4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fa7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800faa:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fac:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800faf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fb2:	77 0a                	ja     800fbe <__umoddi3+0x166>
  800fb4:	75 12                	jne    800fc8 <__umoddi3+0x170>
  800fb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fb9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800fbc:	76 0a                	jbe    800fc8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fbe:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800fc1:	29 f1                	sub    %esi,%ecx
  800fc3:	19 fa                	sbb    %edi,%edx
  800fc5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	0f 84 ea fe ff ff    	je     800ebd <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fd3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800fd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fd9:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800fdc:	19 d1                	sbb    %edx,%ecx
  800fde:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fe1:	89 ca                	mov    %ecx,%edx
  800fe3:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fe6:	d3 e2                	shl    %cl,%edx
  800fe8:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800feb:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fee:	d3 e8                	shr    %cl,%eax
  800ff0:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800ff2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ff5:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ff7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800ffa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ffd:	e9 ad fe ff ff       	jmp    800eaf <__umoddi3+0x57>
