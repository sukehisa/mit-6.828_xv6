
obj/user/hello.debug:     file format elf32-i386


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
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003a:	68 40 0f 80 00       	push   $0x800f40
  80003f:	e8 04 01 00 00       	call   800148 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	83 c4 08             	add    $0x8,%esp
  800047:	a1 04 20 80 00       	mov    0x802004,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	50                   	push   %eax
  800050:	68 4e 0f 80 00       	push   $0x800f4e
  800055:	e8 ee 00 00 00       	call   800148 <cprintf>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 75 08             	mov    0x8(%ebp),%esi
  800064:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800067:	e8 94 09 00 00       	call   800a00 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	89 c2                	mov    %eax,%edx
  800073:	c1 e2 05             	shl    $0x5,%edx
  800076:	29 c2                	sub    %eax,%edx
  800078:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80007f:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	53                   	push   %ebx
  800094:	56                   	push   %esi
  800095:	e8 9a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009a:	e8 09 00 00 00       	call   8000a8 <exit>
}
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 0a 09 00 00       	call   8009bf <sys_env_destroy>
}
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    
	...

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8000cb:	40                   	inc    %eax
  8000cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 96 08 00 00       	call   80097c <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	ff 43 04             	incl   0x4(%ebx)
}
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800100:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  800107:	00 00 00 
	b.cnt = 0;
  80010a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800111:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800114:	ff 75 0c             	pushl  0xc(%ebp)
  800117:	ff 75 08             	pushl  0x8(%ebp)
  80011a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800120:	50                   	push   %eax
  800121:	68 b8 00 80 00       	push   $0x8000b8
  800126:	e8 49 01 00 00       	call   800274 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012b:	83 c4 08             	add    $0x8,%esp
  80012e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800134:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013a:	50                   	push   %eax
  80013b:	e8 3c 08 00 00       	call   80097c <sys_cputs>

	return b.cnt;
  800140:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800151:	50                   	push   %eax
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	e8 9d ff ff ff       	call   8000f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 0c             	sub    $0xc,%esp
  800165:	8b 75 10             	mov    0x10(%ebp),%esi
  800168:	8b 7d 14             	mov    0x14(%ebp),%edi
  80016b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 45 18             	mov    0x18(%ebp),%eax
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	39 fa                	cmp    %edi,%edx
  800178:	77 39                	ja     8001b3 <printnum+0x57>
  80017a:	72 04                	jb     800180 <printnum+0x24>
  80017c:	39 f0                	cmp    %esi,%eax
  80017e:	77 33                	ja     8001b3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800180:	83 ec 04             	sub    $0x4,%esp
  800183:	ff 75 20             	pushl  0x20(%ebp)
  800186:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800189:	50                   	push   %eax
  80018a:	ff 75 18             	pushl  0x18(%ebp)
  80018d:	8b 45 18             	mov    0x18(%ebp),%eax
  800190:	ba 00 00 00 00       	mov    $0x0,%edx
  800195:	52                   	push   %edx
  800196:	50                   	push   %eax
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	e8 de 0a 00 00       	call   800c7c <__udivdi3>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	52                   	push   %edx
  8001a2:	50                   	push   %eax
  8001a3:	ff 75 0c             	pushl  0xc(%ebp)
  8001a6:	ff 75 08             	pushl  0x8(%ebp)
  8001a9:	e8 ae ff ff ff       	call   80015c <printnum>
  8001ae:	83 c4 20             	add    $0x20,%esp
  8001b1:	eb 19                	jmp    8001cc <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b3:	4b                   	dec    %ebx
  8001b4:	85 db                	test   %ebx,%ebx
  8001b6:	7e 14                	jle    8001cc <printnum+0x70>
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	ff 75 0c             	pushl  0xc(%ebp)
  8001be:	ff 75 20             	pushl  0x20(%ebp)
  8001c1:	ff 55 08             	call   *0x8(%ebp)
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	4b                   	dec    %ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f ec                	jg     8001b8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001da:	83 ec 04             	sub    $0x4,%esp
  8001dd:	52                   	push   %edx
  8001de:	50                   	push   %eax
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	e8 a2 0b 00 00       	call   800d88 <__umoddi3>
  8001e6:	83 c4 14             	add    $0x14,%esp
  8001e9:	0f be 80 81 10 80 00 	movsbl 0x801081(%eax),%eax
  8001f0:	50                   	push   %eax
  8001f1:	ff 55 08             	call   *0x8(%ebp)
}
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800202:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800205:	83 f8 01             	cmp    $0x1,%eax
  800208:	7e 0e                	jle    800218 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80020a:	8b 11                	mov    (%ecx),%edx
  80020c:	8d 42 08             	lea    0x8(%edx),%eax
  80020f:	89 01                	mov    %eax,(%ecx)
  800211:	8b 02                	mov    (%edx),%eax
  800213:	8b 52 04             	mov    0x4(%edx),%edx
  800216:	eb 22                	jmp    80023a <getuint+0x3e>
	else if (lflag)
  800218:	85 c0                	test   %eax,%eax
  80021a:	74 10                	je     80022c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  80021c:	8b 11                	mov    (%ecx),%edx
  80021e:	8d 42 04             	lea    0x4(%edx),%eax
  800221:	89 01                	mov    %eax,(%ecx)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
  80022a:	eb 0e                	jmp    80023a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80022c:	8b 11                	mov    (%ecx),%edx
  80022e:	8d 42 04             	lea    0x4(%edx),%eax
  800231:	89 01                	mov    %eax,(%ecx)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800242:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800245:	83 f8 01             	cmp    $0x1,%eax
  800248:	7e 0e                	jle    800258 <getint+0x1c>
		return va_arg(*ap, long long);
  80024a:	8b 11                	mov    (%ecx),%edx
  80024c:	8d 42 08             	lea    0x8(%edx),%eax
  80024f:	89 01                	mov    %eax,(%ecx)
  800251:	8b 02                	mov    (%edx),%eax
  800253:	8b 52 04             	mov    0x4(%edx),%edx
  800256:	eb 1a                	jmp    800272 <getint+0x36>
	else if (lflag)
  800258:	85 c0                	test   %eax,%eax
  80025a:	74 0c                	je     800268 <getint+0x2c>
		return va_arg(*ap, long);
  80025c:	8b 01                	mov    (%ecx),%eax
  80025e:	8d 50 04             	lea    0x4(%eax),%edx
  800261:	89 11                	mov    %edx,(%ecx)
  800263:	8b 00                	mov    (%eax),%eax
  800265:	99                   	cltd   
  800266:	eb 0a                	jmp    800272 <getint+0x36>
	else
		return va_arg(*ap, int);
  800268:	8b 01                	mov    (%ecx),%eax
  80026a:	8d 50 04             	lea    0x4(%eax),%edx
  80026d:	89 11                	mov    %edx,(%ecx)
  80026f:	8b 00                	mov    (%eax),%eax
  800271:	99                   	cltd   
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 1c             	sub    $0x1c,%esp
  80027d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800280:	0f b6 0b             	movzbl (%ebx),%ecx
  800283:	43                   	inc    %ebx
  800284:	83 f9 25             	cmp    $0x25,%ecx
  800287:	74 1e                	je     8002a7 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800289:	85 c9                	test   %ecx,%ecx
  80028b:	0f 84 dc 02 00 00    	je     80056d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	51                   	push   %ecx
  800298:	ff 55 08             	call   *0x8(%ebp)
  80029b:	83 c4 10             	add    $0x10,%esp
  80029e:	0f b6 0b             	movzbl (%ebx),%ecx
  8002a1:	43                   	inc    %ebx
  8002a2:	83 f9 25             	cmp    $0x25,%ecx
  8002a5:	75 e2                	jne    800289 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002a7:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8002ab:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8002b2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002b7:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8002bc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c3:	0f b6 0b             	movzbl (%ebx),%ecx
  8002c6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002c9:	43                   	inc    %ebx
  8002ca:	83 f8 55             	cmp    $0x55,%eax
  8002cd:	0f 87 75 02 00 00    	ja     800548 <vprintfmt+0x2d4>
  8002d3:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002da:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8002de:	eb e3                	jmp    8002c3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002e0:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8002e4:	eb dd                	jmp    8002c3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002e6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8002eb:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8002ee:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8002f2:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8002f5:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8002f8:	83 f8 09             	cmp    $0x9,%eax
  8002fb:	77 28                	ja     800325 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002fd:	43                   	inc    %ebx
  8002fe:	eb eb                	jmp    8002eb <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800300:	8b 55 14             	mov    0x14(%ebp),%edx
  800303:	8d 42 04             	lea    0x4(%edx),%eax
  800306:	89 45 14             	mov    %eax,0x14(%ebp)
  800309:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80030b:	eb 18                	jmp    800325 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  80030d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800311:	79 b0                	jns    8002c3 <vprintfmt+0x4f>
				width = 0;
  800313:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80031a:	eb a7                	jmp    8002c3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80031c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800323:	eb 9e                	jmp    8002c3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800325:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800329:	79 98                	jns    8002c3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80032b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80032e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800333:	eb 8e                	jmp    8002c3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800335:	47                   	inc    %edi
			goto reswitch;
  800336:	eb 8b                	jmp    8002c3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800338:	83 ec 08             	sub    $0x8,%esp
  80033b:	ff 75 0c             	pushl  0xc(%ebp)
  80033e:	8b 55 14             	mov    0x14(%ebp),%edx
  800341:	8d 42 04             	lea    0x4(%edx),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
  800347:	ff 32                	pushl  (%edx)
  800349:	ff 55 08             	call   *0x8(%ebp)
			break;
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	e9 2c ff ff ff       	jmp    800280 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800354:	8b 55 14             	mov    0x14(%ebp),%edx
  800357:	8d 42 04             	lea    0x4(%edx),%eax
  80035a:	89 45 14             	mov    %eax,0x14(%ebp)
  80035d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80035f:	85 c0                	test   %eax,%eax
  800361:	79 02                	jns    800365 <vprintfmt+0xf1>
				err = -err;
  800363:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800365:	83 f8 0f             	cmp    $0xf,%eax
  800368:	7f 0b                	jg     800375 <vprintfmt+0x101>
  80036a:	8b 3c 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edi
  800371:	85 ff                	test   %edi,%edi
  800373:	75 19                	jne    80038e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800375:	50                   	push   %eax
  800376:	68 92 10 80 00       	push   $0x801092
  80037b:	ff 75 0c             	pushl  0xc(%ebp)
  80037e:	ff 75 08             	pushl  0x8(%ebp)
  800381:	e8 ef 01 00 00       	call   800575 <printfmt>
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	e9 f2 fe ff ff       	jmp    800280 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80038e:	57                   	push   %edi
  80038f:	68 9b 10 80 00       	push   $0x80109b
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 d6 01 00 00       	call   800575 <printfmt>
  80039f:	83 c4 10             	add    $0x10,%esp
			break;
  8003a2:	e9 d9 fe ff ff       	jmp    800280 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003a7:	8b 55 14             	mov    0x14(%ebp),%edx
  8003aa:	8d 42 04             	lea    0x4(%edx),%eax
  8003ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8003b0:	8b 3a                	mov    (%edx),%edi
  8003b2:	85 ff                	test   %edi,%edi
  8003b4:	75 05                	jne    8003bb <vprintfmt+0x147>
				p = "(null)";
  8003b6:	bf 9e 10 80 00       	mov    $0x80109e,%edi
			if (width > 0 && padc != '-')
  8003bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003bf:	7e 3b                	jle    8003fc <vprintfmt+0x188>
  8003c1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8003c5:	74 35                	je     8003fc <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003c7:	83 ec 08             	sub    $0x8,%esp
  8003ca:	56                   	push   %esi
  8003cb:	57                   	push   %edi
  8003cc:	e8 58 02 00 00       	call   800629 <strnlen>
  8003d1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8003d4:	83 c4 10             	add    $0x10,%esp
  8003d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003db:	7e 1f                	jle    8003fc <vprintfmt+0x188>
  8003dd:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ed:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	ff 4d f0             	decl   -0x10(%ebp)
  8003f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003fa:	7f e8                	jg     8003e4 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8003fc:	0f be 0f             	movsbl (%edi),%ecx
  8003ff:	47                   	inc    %edi
  800400:	85 c9                	test   %ecx,%ecx
  800402:	74 44                	je     800448 <vprintfmt+0x1d4>
  800404:	85 f6                	test   %esi,%esi
  800406:	78 03                	js     80040b <vprintfmt+0x197>
  800408:	4e                   	dec    %esi
  800409:	78 3d                	js     800448 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  80040b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80040f:	74 18                	je     800429 <vprintfmt+0x1b5>
  800411:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800414:	83 f8 5e             	cmp    $0x5e,%eax
  800417:	76 10                	jbe    800429 <vprintfmt+0x1b5>
					putch('?', putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 0c             	pushl  0xc(%ebp)
  80041f:	6a 3f                	push   $0x3f
  800421:	ff 55 08             	call   *0x8(%ebp)
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	eb 0d                	jmp    800436 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	51                   	push   %ecx
  800430:	ff 55 08             	call   *0x8(%ebp)
  800433:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800436:	ff 4d f0             	decl   -0x10(%ebp)
  800439:	0f be 0f             	movsbl (%edi),%ecx
  80043c:	47                   	inc    %edi
  80043d:	85 c9                	test   %ecx,%ecx
  80043f:	74 07                	je     800448 <vprintfmt+0x1d4>
  800441:	85 f6                	test   %esi,%esi
  800443:	78 c6                	js     80040b <vprintfmt+0x197>
  800445:	4e                   	dec    %esi
  800446:	79 c3                	jns    80040b <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800448:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80044c:	0f 8e 2e fe ff ff    	jle    800280 <vprintfmt+0xc>
				putch(' ', putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	ff 75 0c             	pushl  0xc(%ebp)
  800458:	6a 20                	push   $0x20
  80045a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	ff 4d f0             	decl   -0x10(%ebp)
  800463:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800467:	7f e9                	jg     800452 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800469:	e9 12 fe ff ff       	jmp    800280 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80046e:	57                   	push   %edi
  80046f:	8d 45 14             	lea    0x14(%ebp),%eax
  800472:	50                   	push   %eax
  800473:	e8 c4 fd ff ff       	call   80023c <getint>
  800478:	89 c6                	mov    %eax,%esi
  80047a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80047c:	83 c4 08             	add    $0x8,%esp
  80047f:	85 d2                	test   %edx,%edx
  800481:	79 15                	jns    800498 <vprintfmt+0x224>
				putch('-', putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	6a 2d                	push   $0x2d
  80048b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80048e:	f7 de                	neg    %esi
  800490:	83 d7 00             	adc    $0x0,%edi
  800493:	f7 df                	neg    %edi
  800495:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800498:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80049d:	eb 76                	jmp    800515 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80049f:	57                   	push   %edi
  8004a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a3:	50                   	push   %eax
  8004a4:	e8 53 fd ff ff       	call   8001fc <getuint>
  8004a9:	89 c6                	mov    %eax,%esi
  8004ab:	89 d7                	mov    %edx,%edi
			base = 10;
  8004ad:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	eb 5e                	jmp    800515 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004b7:	57                   	push   %edi
  8004b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004bb:	50                   	push   %eax
  8004bc:	e8 3b fd ff ff       	call   8001fc <getuint>
  8004c1:	89 c6                	mov    %eax,%esi
  8004c3:	89 d7                	mov    %edx,%edi
			base = 8;
  8004c5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004ca:	83 c4 08             	add    $0x8,%esp
  8004cd:	eb 46                	jmp    800515 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	6a 30                	push   $0x30
  8004d7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004da:	83 c4 08             	add    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	6a 78                	push   $0x78
  8004e2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004e5:	8b 55 14             	mov    0x14(%ebp),%edx
  8004e8:	8d 42 04             	lea    0x4(%edx),%eax
  8004eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ee:	8b 32                	mov    (%edx),%esi
  8004f0:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8004f5:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb 16                	jmp    800515 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8004ff:	57                   	push   %edi
  800500:	8d 45 14             	lea    0x14(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	e8 f3 fc ff ff       	call   8001fc <getuint>
  800509:	89 c6                	mov    %eax,%esi
  80050b:	89 d7                	mov    %edx,%edi
			base = 16;
  80050d:	ba 10 00 00 00       	mov    $0x10,%edx
  800512:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800515:	83 ec 04             	sub    $0x4,%esp
  800518:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80051c:	50                   	push   %eax
  80051d:	ff 75 f0             	pushl  -0x10(%ebp)
  800520:	52                   	push   %edx
  800521:	57                   	push   %edi
  800522:	56                   	push   %esi
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	ff 75 08             	pushl  0x8(%ebp)
  800529:	e8 2e fc ff ff       	call   80015c <printnum>
			break;
  80052e:	83 c4 20             	add    $0x20,%esp
  800531:	e9 4a fd ff ff       	jmp    800280 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	51                   	push   %ecx
  80053d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	e9 38 fd ff ff       	jmp    800280 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	ff 75 0c             	pushl  0xc(%ebp)
  80054e:	6a 25                	push   $0x25
  800550:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800553:	4b                   	dec    %ebx
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80055b:	0f 84 1f fd ff ff    	je     800280 <vprintfmt+0xc>
  800561:	4b                   	dec    %ebx
  800562:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800566:	75 f9                	jne    800561 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800568:	e9 13 fd ff ff       	jmp    800280 <vprintfmt+0xc>
		}
	}
}
  80056d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800570:	5b                   	pop    %ebx
  800571:	5e                   	pop    %esi
  800572:	5f                   	pop    %edi
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80057b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80057e:	50                   	push   %eax
  80057f:	ff 75 10             	pushl  0x10(%ebp)
  800582:	ff 75 0c             	pushl  0xc(%ebp)
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 e7 fc ff ff       	call   800274 <vprintfmt>
	va_end(ap);
}
  80058d:	c9                   	leave  
  80058e:	c3                   	ret    

0080058f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800595:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800598:	8b 0a                	mov    (%edx),%ecx
  80059a:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80059d:	73 07                	jae    8005a6 <sprintputch+0x17>
		*b->buf++ = ch;
  80059f:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a2:	88 01                	mov    %al,(%ecx)
  8005a4:	ff 02                	incl   (%edx)
}
  8005a6:	c9                   	leave  
  8005a7:	c3                   	ret    

008005a8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	83 ec 18             	sub    $0x18,%esp
  8005ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005b4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005b7:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8005bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8005c5:	85 d2                	test   %edx,%edx
  8005c7:	74 04                	je     8005cd <vsnprintf+0x25>
  8005c9:	85 c9                	test   %ecx,%ecx
  8005cb:	7f 07                	jg     8005d4 <vsnprintf+0x2c>
		return -E_INVAL;
  8005cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005d2:	eb 1d                	jmp    8005f1 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005d4:	ff 75 14             	pushl  0x14(%ebp)
  8005d7:	ff 75 10             	pushl  0x10(%ebp)
  8005da:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8005dd:	50                   	push   %eax
  8005de:	68 8f 05 80 00       	push   $0x80058f
  8005e3:	e8 8c fc ff ff       	call   800274 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8005f1:	c9                   	leave  
  8005f2:	c3                   	ret    

008005f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8005fc:	50                   	push   %eax
  8005fd:	ff 75 10             	pushl  0x10(%ebp)
  800600:	ff 75 0c             	pushl  0xc(%ebp)
  800603:	ff 75 08             	pushl  0x8(%ebp)
  800606:	e8 9d ff ff ff       	call   8005a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80060b:	c9                   	leave  
  80060c:	c3                   	ret    
  80060d:	00 00                	add    %al,(%eax)
	...

00800610 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800616:	b8 00 00 00 00       	mov    $0x0,%eax
  80061b:	80 3a 00             	cmpb   $0x0,(%edx)
  80061e:	74 07                	je     800627 <strlen+0x17>
		n++;
  800620:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800621:	42                   	inc    %edx
  800622:	80 3a 00             	cmpb   $0x0,(%edx)
  800625:	75 f9                	jne    800620 <strlen+0x10>
		n++;
	return n;
}
  800627:	c9                   	leave  
  800628:	c3                   	ret    

00800629 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800629:	55                   	push   %ebp
  80062a:	89 e5                	mov    %esp,%ebp
  80062c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80062f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800632:	b8 00 00 00 00       	mov    $0x0,%eax
  800637:	85 d2                	test   %edx,%edx
  800639:	74 0f                	je     80064a <strnlen+0x21>
  80063b:	80 39 00             	cmpb   $0x0,(%ecx)
  80063e:	74 0a                	je     80064a <strnlen+0x21>
		n++;
  800640:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800641:	41                   	inc    %ecx
  800642:	4a                   	dec    %edx
  800643:	74 05                	je     80064a <strnlen+0x21>
  800645:	80 39 00             	cmpb   $0x0,(%ecx)
  800648:	75 f6                	jne    800640 <strnlen+0x17>
		n++;
	return n;
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	53                   	push   %ebx
  800650:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800653:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800656:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800658:	8a 02                	mov    (%edx),%al
  80065a:	42                   	inc    %edx
  80065b:	88 01                	mov    %al,(%ecx)
  80065d:	41                   	inc    %ecx
  80065e:	84 c0                	test   %al,%al
  800660:	75 f6                	jne    800658 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800662:	89 d8                	mov    %ebx,%eax
  800664:	5b                   	pop    %ebx
  800665:	c9                   	leave  
  800666:	c3                   	ret    

00800667 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	53                   	push   %ebx
  80066b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80066e:	53                   	push   %ebx
  80066f:	e8 9c ff ff ff       	call   800610 <strlen>
	strcpy(dst + len, src);
  800674:	ff 75 0c             	pushl  0xc(%ebp)
  800677:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80067a:	50                   	push   %eax
  80067b:	e8 cc ff ff ff       	call   80064c <strcpy>
	return dst;
}
  800680:	89 d8                	mov    %ebx,%eax
  800682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	57                   	push   %edi
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800690:	8b 55 0c             	mov    0xc(%ebp),%edx
  800693:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800696:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069d:	39 f3                	cmp    %esi,%ebx
  80069f:	73 10                	jae    8006b1 <strncpy+0x2a>
		*dst++ = *src;
  8006a1:	8a 02                	mov    (%edx),%al
  8006a3:	88 01                	mov    %al,(%ecx)
  8006a5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006a6:	80 3a 01             	cmpb   $0x1,(%edx)
  8006a9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006ac:	43                   	inc    %ebx
  8006ad:	39 f3                	cmp    %esi,%ebx
  8006af:	72 f0                	jb     8006a1 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006b1:	89 f8                	mov    %edi,%eax
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	56                   	push   %esi
  8006bc:	53                   	push   %ebx
  8006bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006c6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 19                	je     8006e5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006cc:	4a                   	dec    %edx
  8006cd:	74 13                	je     8006e2 <strlcpy+0x2a>
  8006cf:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d2:	74 0e                	je     8006e2 <strlcpy+0x2a>
  8006d4:	8a 01                	mov    (%ecx),%al
  8006d6:	41                   	inc    %ecx
  8006d7:	88 03                	mov    %al,(%ebx)
  8006d9:	43                   	inc    %ebx
  8006da:	4a                   	dec    %edx
  8006db:	74 05                	je     8006e2 <strlcpy+0x2a>
  8006dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e0:	75 f2                	jne    8006d4 <strlcpy+0x1c>
		*dst = '\0';
  8006e2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	29 f0                	sub    %esi,%eax
}
  8006e9:	5b                   	pop    %ebx
  8006ea:	5e                   	pop    %esi
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8006f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f9:	74 13                	je     80070e <strcmp+0x21>
  8006fb:	8a 02                	mov    (%edx),%al
  8006fd:	3a 01                	cmp    (%ecx),%al
  8006ff:	75 0d                	jne    80070e <strcmp+0x21>
  800701:	42                   	inc    %edx
  800702:	41                   	inc    %ecx
  800703:	80 3a 00             	cmpb   $0x0,(%edx)
  800706:	74 06                	je     80070e <strcmp+0x21>
  800708:	8a 02                	mov    (%edx),%al
  80070a:	3a 01                	cmp    (%ecx),%al
  80070c:	74 f3                	je     800701 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80070e:	0f b6 02             	movzbl (%edx),%eax
  800711:	0f b6 11             	movzbl (%ecx),%edx
  800714:	29 d0                	sub    %edx,%eax
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 55 08             	mov    0x8(%ebp),%edx
  80071f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800722:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800725:	85 c9                	test   %ecx,%ecx
  800727:	74 1f                	je     800748 <strncmp+0x30>
  800729:	80 3a 00             	cmpb   $0x0,(%edx)
  80072c:	74 16                	je     800744 <strncmp+0x2c>
  80072e:	8a 02                	mov    (%edx),%al
  800730:	3a 03                	cmp    (%ebx),%al
  800732:	75 10                	jne    800744 <strncmp+0x2c>
  800734:	42                   	inc    %edx
  800735:	43                   	inc    %ebx
  800736:	49                   	dec    %ecx
  800737:	74 0f                	je     800748 <strncmp+0x30>
  800739:	80 3a 00             	cmpb   $0x0,(%edx)
  80073c:	74 06                	je     800744 <strncmp+0x2c>
  80073e:	8a 02                	mov    (%edx),%al
  800740:	3a 03                	cmp    (%ebx),%al
  800742:	74 f0                	je     800734 <strncmp+0x1c>
	if (n == 0)
  800744:	85 c9                	test   %ecx,%ecx
  800746:	75 07                	jne    80074f <strncmp+0x37>
		return 0;
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	eb 0a                	jmp    800759 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80074f:	0f b6 12             	movzbl (%edx),%edx
  800752:	0f b6 03             	movzbl (%ebx),%eax
  800755:	29 c2                	sub    %eax,%edx
  800757:	89 d0                	mov    %edx,%eax
}
  800759:	5b                   	pop    %ebx
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800765:	80 38 00             	cmpb   $0x0,(%eax)
  800768:	74 0a                	je     800774 <strchr+0x18>
		if (*s == c)
  80076a:	38 10                	cmp    %dl,(%eax)
  80076c:	74 0b                	je     800779 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80076e:	40                   	inc    %eax
  80076f:	80 38 00             	cmpb   $0x0,(%eax)
  800772:	75 f6                	jne    80076a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800784:	80 38 00             	cmpb   $0x0,(%eax)
  800787:	74 0a                	je     800793 <strfind+0x18>
		if (*s == c)
  800789:	38 10                	cmp    %dl,(%eax)
  80078b:	74 06                	je     800793 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80078d:	40                   	inc    %eax
  80078e:	80 38 00             	cmpb   $0x0,(%eax)
  800791:	75 f6                	jne    800789 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	57                   	push   %edi
  800799:	8b 7d 08             	mov    0x8(%ebp),%edi
  80079c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  80079f:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8007a1:	85 c9                	test   %ecx,%ecx
  8007a3:	74 40                	je     8007e5 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007ab:	75 30                	jne    8007dd <memset+0x48>
  8007ad:	f6 c1 03             	test   $0x3,%cl
  8007b0:	75 2b                	jne    8007dd <memset+0x48>
		c &= 0xFF;
  8007b2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	c1 e0 18             	shl    $0x18,%eax
  8007bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c2:	c1 e2 10             	shl    $0x10,%edx
  8007c5:	09 d0                	or     %edx,%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	c1 e2 08             	shl    $0x8,%edx
  8007cd:	09 d0                	or     %edx,%eax
  8007cf:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8007d2:	c1 e9 02             	shr    $0x2,%ecx
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d8:	fc                   	cld    
  8007d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8007db:	eb 06                	jmp    8007e3 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e0:	fc                   	cld    
  8007e1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8007e3:	89 f8                	mov    %edi,%eax
}
  8007e5:	5f                   	pop    %edi
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	57                   	push   %edi
  8007ec:	56                   	push   %esi
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8007f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007f6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007f8:	39 c6                	cmp    %eax,%esi
  8007fa:	73 34                	jae    800830 <memmove+0x48>
  8007fc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8007ff:	39 c2                	cmp    %eax,%edx
  800801:	76 2d                	jbe    800830 <memmove+0x48>
		s += n;
  800803:	89 d6                	mov    %edx,%esi
		d += n;
  800805:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800808:	f6 c2 03             	test   $0x3,%dl
  80080b:	75 1b                	jne    800828 <memmove+0x40>
  80080d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800813:	75 13                	jne    800828 <memmove+0x40>
  800815:	f6 c1 03             	test   $0x3,%cl
  800818:	75 0e                	jne    800828 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80081a:	83 ef 04             	sub    $0x4,%edi
  80081d:	83 ee 04             	sub    $0x4,%esi
  800820:	c1 e9 02             	shr    $0x2,%ecx
  800823:	fd                   	std    
  800824:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800826:	eb 05                	jmp    80082d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800828:	4f                   	dec    %edi
  800829:	4e                   	dec    %esi
  80082a:	fd                   	std    
  80082b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80082d:	fc                   	cld    
  80082e:	eb 20                	jmp    800850 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800830:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800836:	75 15                	jne    80084d <memmove+0x65>
  800838:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80083e:	75 0d                	jne    80084d <memmove+0x65>
  800840:	f6 c1 03             	test   $0x3,%cl
  800843:	75 08                	jne    80084d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800845:	c1 e9 02             	shr    $0x2,%ecx
  800848:	fc                   	cld    
  800849:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80084b:	eb 03                	jmp    800850 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80084d:	fc                   	cld    
  80084e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800857:	ff 75 10             	pushl  0x10(%ebp)
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 83 ff ff ff       	call   8007e8 <memmove>
}
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800871:	8b 55 10             	mov    0x10(%ebp),%edx
  800874:	4a                   	dec    %edx
  800875:	83 fa ff             	cmp    $0xffffffff,%edx
  800878:	74 1a                	je     800894 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80087a:	8a 01                	mov    (%ecx),%al
  80087c:	3a 03                	cmp    (%ebx),%al
  80087e:	74 0c                	je     80088c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800880:	0f b6 d0             	movzbl %al,%edx
  800883:	0f b6 03             	movzbl (%ebx),%eax
  800886:	29 c2                	sub    %eax,%edx
  800888:	89 d0                	mov    %edx,%eax
  80088a:	eb 0d                	jmp    800899 <memcmp+0x32>
		s1++, s2++;
  80088c:	41                   	inc    %ecx
  80088d:	43                   	inc    %ebx
  80088e:	4a                   	dec    %edx
  80088f:	83 fa ff             	cmp    $0xffffffff,%edx
  800892:	75 e6                	jne    80087a <memcmp+0x13>
	}

	return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008a5:	89 c2                	mov    %eax,%edx
  8008a7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008aa:	39 d0                	cmp    %edx,%eax
  8008ac:	73 09                	jae    8008b7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008ae:	38 08                	cmp    %cl,(%eax)
  8008b0:	74 05                	je     8008b7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008b2:	40                   	inc    %eax
  8008b3:	39 d0                	cmp    %edx,%eax
  8008b5:	72 f7                	jb     8008ae <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8008c8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8008cd:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008d2:	80 3a 20             	cmpb   $0x20,(%edx)
  8008d5:	74 05                	je     8008dc <strtol+0x23>
  8008d7:	80 3a 09             	cmpb   $0x9,(%edx)
  8008da:	75 0b                	jne    8008e7 <strtol+0x2e>
  8008dc:	42                   	inc    %edx
  8008dd:	80 3a 20             	cmpb   $0x20,(%edx)
  8008e0:	74 fa                	je     8008dc <strtol+0x23>
  8008e2:	80 3a 09             	cmpb   $0x9,(%edx)
  8008e5:	74 f5                	je     8008dc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8008e7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8008ea:	75 03                	jne    8008ef <strtol+0x36>
		s++;
  8008ec:	42                   	inc    %edx
  8008ed:	eb 0b                	jmp    8008fa <strtol+0x41>
	else if (*s == '-')
  8008ef:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8008f2:	75 06                	jne    8008fa <strtol+0x41>
		s++, neg = 1;
  8008f4:	42                   	inc    %edx
  8008f5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 05                	je     800903 <strtol+0x4a>
  8008fe:	83 f9 10             	cmp    $0x10,%ecx
  800901:	75 15                	jne    800918 <strtol+0x5f>
  800903:	80 3a 30             	cmpb   $0x30,(%edx)
  800906:	75 10                	jne    800918 <strtol+0x5f>
  800908:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80090c:	75 0a                	jne    800918 <strtol+0x5f>
		s += 2, base = 16;
  80090e:	83 c2 02             	add    $0x2,%edx
  800911:	b9 10 00 00 00       	mov    $0x10,%ecx
  800916:	eb 14                	jmp    80092c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	75 10                	jne    80092c <strtol+0x73>
  80091c:	80 3a 30             	cmpb   $0x30,(%edx)
  80091f:	75 05                	jne    800926 <strtol+0x6d>
		s++, base = 8;
  800921:	42                   	inc    %edx
  800922:	b1 08                	mov    $0x8,%cl
  800924:	eb 06                	jmp    80092c <strtol+0x73>
	else if (base == 0)
  800926:	85 c9                	test   %ecx,%ecx
  800928:	75 02                	jne    80092c <strtol+0x73>
		base = 10;
  80092a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80092c:	8a 02                	mov    (%edx),%al
  80092e:	83 e8 30             	sub    $0x30,%eax
  800931:	3c 09                	cmp    $0x9,%al
  800933:	77 08                	ja     80093d <strtol+0x84>
			dig = *s - '0';
  800935:	0f be 02             	movsbl (%edx),%eax
  800938:	83 e8 30             	sub    $0x30,%eax
  80093b:	eb 20                	jmp    80095d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  80093d:	8a 02                	mov    (%edx),%al
  80093f:	83 e8 61             	sub    $0x61,%eax
  800942:	3c 19                	cmp    $0x19,%al
  800944:	77 08                	ja     80094e <strtol+0x95>
			dig = *s - 'a' + 10;
  800946:	0f be 02             	movsbl (%edx),%eax
  800949:	83 e8 57             	sub    $0x57,%eax
  80094c:	eb 0f                	jmp    80095d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  80094e:	8a 02                	mov    (%edx),%al
  800950:	83 e8 41             	sub    $0x41,%eax
  800953:	3c 19                	cmp    $0x19,%al
  800955:	77 12                	ja     800969 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800957:	0f be 02             	movsbl (%edx),%eax
  80095a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80095d:	39 c8                	cmp    %ecx,%eax
  80095f:	7d 08                	jge    800969 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800961:	42                   	inc    %edx
  800962:	0f af d9             	imul   %ecx,%ebx
  800965:	01 c3                	add    %eax,%ebx
  800967:	eb c3                	jmp    80092c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800969:	85 f6                	test   %esi,%esi
  80096b:	74 02                	je     80096f <strtol+0xb6>
		*endptr = (char *) s;
  80096d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	85 ff                	test   %edi,%edi
  800973:	74 02                	je     800977 <strtol+0xbe>
  800975:	f7 d8                	neg    %eax
}
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	83 ec 04             	sub    $0x4,%esp
  800985:	8b 55 08             	mov    0x8(%ebp),%edx
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800990:	89 f8                	mov    %edi,%eax
  800992:	89 fb                	mov    %edi,%ebx
  800994:	89 fe                	mov    %edi,%esi
  800996:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800998:	83 c4 04             	add    $0x4,%esp
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009b0:	89 fa                	mov    %edi,%edx
  8009b2:	89 f9                	mov    %edi,%ecx
  8009b4:	89 fb                	mov    %edi,%ebx
  8009b6:	89 fe                	mov    %edi,%esi
  8009b8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	83 ec 0c             	sub    $0xc,%esp
  8009c8:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009d5:	89 f9                	mov    %edi,%ecx
  8009d7:	89 fb                	mov    %edi,%ebx
  8009d9:	89 fe                	mov    %edi,%esi
  8009db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	7e 17                	jle    8009f8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	50                   	push   %eax
  8009e5:	6a 03                	push   $0x3
  8009e7:	68 78 12 80 00       	push   $0x801278
  8009ec:	6a 23                	push   $0x23
  8009ee:	68 95 12 80 00       	push   $0x801295
  8009f3:	e8 38 02 00 00       	call   800c30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8009f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a06:	b8 02 00 00 00       	mov    $0x2,%eax
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a10:	89 fa                	mov    %edi,%edx
  800a12:	89 f9                	mov    %edi,%ecx
  800a14:	89 fb                	mov    %edi,%ebx
  800a16:	89 fe                	mov    %edi,%esi
  800a18:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5f                   	pop    %edi
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <sys_yield>:

void
sys_yield(void)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2f:	89 fa                	mov    %edi,%edx
  800a31:	89 f9                	mov    %edi,%ecx
  800a33:	89 fb                	mov    %edi,%ebx
  800a35:	89 fe                	mov    %edi,%esi
  800a37:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a50:	b8 04 00 00 00       	mov    $0x4,%eax
  800a55:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	89 fe                	mov    %edi,%esi
  800a5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	7e 17                	jle    800a79 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	50                   	push   %eax
  800a66:	6a 04                	push   $0x4
  800a68:	68 78 12 80 00       	push   $0x801278
  800a6d:	6a 23                	push   $0x23
  800a6f:	68 95 12 80 00       	push   $0x801295
  800a74:	e8 b7 01 00 00       	call   800c30 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	83 ec 0c             	sub    $0xc,%esp
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800a96:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a99:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	7e 17                	jle    800abb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	50                   	push   %eax
  800aa8:	6a 05                	push   $0x5
  800aaa:	68 78 12 80 00       	push   $0x801278
  800aaf:	6a 23                	push   $0x23
  800ab1:	68 95 12 80 00       	push   $0x801295
  800ab6:	e8 75 01 00 00       	call   800c30 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ad7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	89 fb                	mov    %edi,%ebx
  800ade:	89 fe                	mov    %edi,%esi
  800ae0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	7e 17                	jle    800afd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	50                   	push   %eax
  800aea:	6a 06                	push   $0x6
  800aec:	68 78 12 80 00       	push   $0x801278
  800af1:	6a 23                	push   $0x23
  800af3:	68 95 12 80 00       	push   $0x801295
  800af8:	e8 33 01 00 00       	call   800c30 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b14:	b8 08 00 00 00       	mov    $0x8,%eax
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	89 fb                	mov    %edi,%ebx
  800b20:	89 fe                	mov    %edi,%esi
  800b22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b24:	85 c0                	test   %eax,%eax
  800b26:	7e 17                	jle    800b3f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	50                   	push   %eax
  800b2c:	6a 08                	push   $0x8
  800b2e:	68 78 12 80 00       	push   $0x801278
  800b33:	6a 23                	push   $0x23
  800b35:	68 95 12 80 00       	push   $0x801295
  800b3a:	e8 f1 00 00 00       	call   800c30 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b56:	b8 09 00 00 00       	mov    $0x9,%eax
  800b5b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	89 fb                	mov    %edi,%ebx
  800b62:	89 fe                	mov    %edi,%esi
  800b64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b66:	85 c0                	test   %eax,%eax
  800b68:	7e 17                	jle    800b81 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	50                   	push   %eax
  800b6e:	6a 09                	push   $0x9
  800b70:	68 78 12 80 00       	push   $0x801278
  800b75:	6a 23                	push   $0x23
  800b77:	68 95 12 80 00       	push   $0x801295
  800b7c:	e8 af 00 00 00       	call   800c30 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	89 fb                	mov    %edi,%ebx
  800ba4:	89 fe                	mov    %edi,%esi
  800ba6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 17                	jle    800bc3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 0a                	push   $0xa
  800bb2:	68 78 12 80 00       	push   $0x801278
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 95 12 80 00       	push   $0x801295
  800bbe:	e8 6d 00 00 00       	call   800c30 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bdd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800be2:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	89 f9                	mov    %edi,%ecx
  800c06:	89 fb                	mov    %edi,%ebx
  800c08:	89 fe                	mov    %edi,%esi
  800c0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 17                	jle    800c27 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 0d                	push   $0xd
  800c16:	68 78 12 80 00       	push   $0x801278
  800c1b:	6a 23                	push   $0x23
  800c1d:	68 95 12 80 00       	push   $0x801295
  800c22:	e8 09 00 00 00       	call   800c30 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    
	...

00800c30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	53                   	push   %ebx
  800c34:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800c37:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c3a:	ff 75 0c             	pushl  0xc(%ebp)
  800c3d:	ff 75 08             	pushl  0x8(%ebp)
  800c40:	ff 35 00 20 80 00    	pushl  0x802000
  800c46:	83 ec 08             	sub    $0x8,%esp
  800c49:	e8 b2 fd ff ff       	call   800a00 <sys_getenvid>
  800c4e:	83 c4 08             	add    $0x8,%esp
  800c51:	50                   	push   %eax
  800c52:	68 a4 12 80 00       	push   $0x8012a4
  800c57:	e8 ec f4 ff ff       	call   800148 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c5c:	83 c4 18             	add    $0x18,%esp
  800c5f:	53                   	push   %ebx
  800c60:	ff 75 10             	pushl  0x10(%ebp)
  800c63:	e8 8f f4 ff ff       	call   8000f7 <vcprintf>
	cprintf("\n");
  800c68:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  800c6f:	e8 d4 f4 ff ff       	call   800148 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800c74:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800c77:	cc                   	int3   
  800c78:	eb fd                	jmp    800c77 <_panic+0x47>
	...

00800c7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	83 ec 14             	sub    $0x14,%esp
  800c84:	8b 55 14             	mov    0x14(%ebp),%edx
  800c87:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c8d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c90:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c92:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c98:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c9b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c9d:	75 11                	jne    800cb0 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c9f:	39 f8                	cmp    %edi,%eax
  800ca1:	76 4d                	jbe    800cf0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ca3:	89 fa                	mov    %edi,%edx
  800ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca8:	f7 75 e4             	divl   -0x1c(%ebp)
  800cab:	89 c7                	mov    %eax,%edi
  800cad:	eb 09                	jmp    800cb8 <__udivdi3+0x3c>
  800caf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cb0:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800cb3:	76 17                	jbe    800ccc <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800cb5:	31 ff                	xor    %edi,%edi
  800cb7:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800cb8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cbf:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cc2:	83 c4 14             	add    $0x14,%esp
  800cc5:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cc6:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cc8:	5f                   	pop    %edi
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    
  800ccb:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ccc:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cd0:	89 c7                	mov    %eax,%edi
  800cd2:	83 f7 1f             	xor    $0x1f,%edi
  800cd5:	75 4d                	jne    800d24 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cd7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cda:	77 0a                	ja     800ce6 <__udivdi3+0x6a>
  800cdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800cdf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800ce4:	72 d2                	jb     800cb8 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800ce6:	bf 01 00 00 00       	mov    $0x1,%edi
  800ceb:	eb cb                	jmp    800cb8 <__udivdi3+0x3c>
  800ced:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	75 0e                	jne    800d05 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cf7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfc:	31 c9                	xor    %ecx,%ecx
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	f7 f1                	div    %ecx
  800d02:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d05:	89 f0                	mov    %esi,%eax
  800d07:	31 d2                	xor    %edx,%edx
  800d09:	f7 75 e4             	divl   -0x1c(%ebp)
  800d0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d12:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d15:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d18:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d1b:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d1d:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d1e:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d20:	5f                   	pop    %edi
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    
  800d23:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d24:	b8 20 00 00 00       	mov    $0x20,%eax
  800d29:	29 f8                	sub    %edi,%eax
  800d2b:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d2e:	89 f9                	mov    %edi,%ecx
  800d30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d33:	d3 e2                	shl    %cl,%edx
  800d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d38:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d3b:	d3 e8                	shr    %cl,%eax
  800d3d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d3f:	89 f9                	mov    %edi,%ecx
  800d41:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d44:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d47:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d4a:	89 f2                	mov    %esi,%edx
  800d4c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d4e:	89 f9                	mov    %edi,%ecx
  800d50:	d3 e6                	shl    %cl,%esi
  800d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d55:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d58:	d3 e8                	shr    %cl,%eax
  800d5a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d5c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d5e:	89 f0                	mov    %esi,%eax
  800d60:	f7 75 f4             	divl   -0xc(%ebp)
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d67:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d6f:	39 f2                	cmp    %esi,%edx
  800d71:	77 0f                	ja     800d82 <__udivdi3+0x106>
  800d73:	0f 85 3f ff ff ff    	jne    800cb8 <__udivdi3+0x3c>
  800d79:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d7c:	0f 86 36 ff ff ff    	jbe    800cb8 <__udivdi3+0x3c>
		{
		  q0--;
  800d82:	4f                   	dec    %edi
  800d83:	e9 30 ff ff ff       	jmp    800cb8 <__udivdi3+0x3c>

00800d88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	83 ec 30             	sub    $0x30,%esp
  800d90:	8b 55 14             	mov    0x14(%ebp),%edx
  800d93:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d96:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d98:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d9b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da3:	85 ff                	test   %edi,%edi
  800da5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800dac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800db3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800db6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800db9:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dbc:	75 3e                	jne    800dfc <__umoddi3+0x74>
    {
      if (d0 > n1)
  800dbe:	39 d6                	cmp    %edx,%esi
  800dc0:	0f 86 a2 00 00 00    	jbe    800e68 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dc6:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dc8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dcb:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dcd:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dd0:	74 1b                	je     800ded <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800dd8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ddf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800de2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800de5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800de8:	89 10                	mov    %edx,(%eax)
  800dea:	89 48 04             	mov    %ecx,0x4(%eax)
  800ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800df3:	83 c4 30             	add    $0x30,%esp
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    
  800dfa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dfc:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800dff:	76 1f                	jbe    800e20 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800e04:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e07:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800e0a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800e0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e16:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e19:	83 c4 30             	add    $0x30,%esp
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e20:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e23:	83 f0 1f             	xor    $0x1f,%eax
  800e26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e29:	75 61                	jne    800e8c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e2b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e2e:	77 05                	ja     800e35 <__umoddi3+0xad>
  800e30:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e33:	72 10                	jb     800e45 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e35:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e38:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e3b:	29 f0                	sub    %esi,%eax
  800e3d:	19 fa                	sbb    %edi,%edx
  800e3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e42:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e45:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e48:	85 d2                	test   %edx,%edx
  800e4a:	74 a1                	je     800ded <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e4f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e52:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e58:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e61:	89 01                	mov    %eax,(%ecx)
  800e63:	89 51 04             	mov    %edx,0x4(%ecx)
  800e66:	eb 85                	jmp    800ded <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e68:	85 f6                	test   %esi,%esi
  800e6a:	75 0b                	jne    800e77 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e71:	31 d2                	xor    %edx,%edx
  800e73:	f7 f6                	div    %esi
  800e75:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e77:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e7a:	89 fa                	mov    %edi,%edx
  800e7c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e81:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e84:	f7 f6                	div    %esi
  800e86:	e9 3d ff ff ff       	jmp    800dc8 <__umoddi3+0x40>
  800e8b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e91:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e94:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e97:	89 fa                	mov    %edi,%edx
  800e99:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e9c:	d3 e2                	shl    %cl,%edx
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ea3:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800ea5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ea8:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eaa:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800eac:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eaf:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eb2:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800eb4:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800eb6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800eb9:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ebc:	d3 e0                	shl    %cl,%eax
  800ebe:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ec1:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ec4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ec7:	d3 e8                	shr    %cl,%eax
  800ec9:	0b 45 cc             	or     -0x34(%ebp),%eax
  800ecc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800ecf:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ed2:	f7 f7                	div    %edi
  800ed4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ed7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800eda:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800edc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800edf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee2:	77 0a                	ja     800eee <__umoddi3+0x166>
  800ee4:	75 12                	jne    800ef8 <__umoddi3+0x170>
  800ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ee9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800eec:	76 0a                	jbe    800ef8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ef1:	29 f1                	sub    %esi,%ecx
  800ef3:	19 fa                	sbb    %edi,%edx
  800ef5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efb:	85 c0                	test   %eax,%eax
  800efd:	0f 84 ea fe ff ff    	je     800ded <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f03:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f06:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f09:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800f0c:	19 d1                	sbb    %edx,%ecx
  800f0e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f11:	89 ca                	mov    %ecx,%edx
  800f13:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f16:	d3 e2                	shl    %cl,%edx
  800f18:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f1e:	d3 e8                	shr    %cl,%eax
  800f20:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f22:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f25:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f27:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f2d:	e9 ad fe ff ff       	jmp    800ddf <__umoddi3+0x57>
