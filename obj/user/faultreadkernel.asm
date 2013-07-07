
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800040:	68 40 0f 80 00       	push   $0x800f40
  800045:	e8 ee 00 00 00       	call   800138 <cprintf>
}
  80004a:	c9                   	leave  
  80004b:	c3                   	ret    

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800057:	e8 94 09 00 00       	call   8009f0 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	89 c2                	mov    %eax,%edx
  800063:	c1 e2 05             	shl    $0x5,%edx
  800066:	29 c2                	sub    %eax,%edx
  800068:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80006f:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	53                   	push   %ebx
  800084:	56                   	push   %esi
  800085:	e8 aa ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008a:	e8 09 00 00 00       	call   800098 <exit>
}
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 0a 09 00 00       	call   8009af <sys_env_destroy>
}
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    
	...

008000a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 04             	sub    $0x4,%esp
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b2:	8b 03                	mov    (%ebx),%eax
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8000bb:	40                   	inc    %eax
  8000bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 96 08 00 00       	call   80096c <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	ff 43 04             	incl   0x4(%ebx)
}
  8000e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f0:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8000f7:	00 00 00 
	b.cnt = 0;
  8000fa:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800101:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800104:	ff 75 0c             	pushl  0xc(%ebp)
  800107:	ff 75 08             	pushl  0x8(%ebp)
  80010a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800110:	50                   	push   %eax
  800111:	68 a8 00 80 00       	push   $0x8000a8
  800116:	e8 49 01 00 00       	call   800264 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011b:	83 c4 08             	add    $0x8,%esp
  80011e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800124:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012a:	50                   	push   %eax
  80012b:	e8 3c 08 00 00       	call   80096c <sys_cputs>

	return b.cnt;
  800130:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800141:	50                   	push   %eax
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	e8 9d ff ff ff       	call   8000e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	8b 75 10             	mov    0x10(%ebp),%esi
  800158:	8b 7d 14             	mov    0x14(%ebp),%edi
  80015b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80015e:	8b 45 18             	mov    0x18(%ebp),%eax
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	39 fa                	cmp    %edi,%edx
  800168:	77 39                	ja     8001a3 <printnum+0x57>
  80016a:	72 04                	jb     800170 <printnum+0x24>
  80016c:	39 f0                	cmp    %esi,%eax
  80016e:	77 33                	ja     8001a3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	ff 75 20             	pushl  0x20(%ebp)
  800176:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 18             	pushl  0x18(%ebp)
  80017d:	8b 45 18             	mov    0x18(%ebp),%eax
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	52                   	push   %edx
  800186:	50                   	push   %eax
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	e8 de 0a 00 00       	call   800c6c <__udivdi3>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	52                   	push   %edx
  800192:	50                   	push   %eax
  800193:	ff 75 0c             	pushl  0xc(%ebp)
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 ae ff ff ff       	call   80014c <printnum>
  80019e:	83 c4 20             	add    $0x20,%esp
  8001a1:	eb 19                	jmp    8001bc <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001a3:	4b                   	dec    %ebx
  8001a4:	85 db                	test   %ebx,%ebx
  8001a6:	7e 14                	jle    8001bc <printnum+0x70>
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	ff 75 0c             	pushl  0xc(%ebp)
  8001ae:	ff 75 20             	pushl  0x20(%ebp)
  8001b1:	ff 55 08             	call   *0x8(%ebp)
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	4b                   	dec    %ebx
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7f ec                	jg     8001a8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	ff 75 0c             	pushl  0xc(%ebp)
  8001c2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ca:	83 ec 04             	sub    $0x4,%esp
  8001cd:	52                   	push   %edx
  8001ce:	50                   	push   %eax
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	e8 a2 0b 00 00       	call   800d78 <__umoddi3>
  8001d6:	83 c4 14             	add    $0x14,%esp
  8001d9:	0f be 80 83 10 80 00 	movsbl 0x801083(%eax),%eax
  8001e0:	50                   	push   %eax
  8001e1:	ff 55 08             	call   *0x8(%ebp)
}
  8001e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8001f5:	83 f8 01             	cmp    $0x1,%eax
  8001f8:	7e 0e                	jle    800208 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8001fa:	8b 11                	mov    (%ecx),%edx
  8001fc:	8d 42 08             	lea    0x8(%edx),%eax
  8001ff:	89 01                	mov    %eax,(%ecx)
  800201:	8b 02                	mov    (%edx),%eax
  800203:	8b 52 04             	mov    0x4(%edx),%edx
  800206:	eb 22                	jmp    80022a <getuint+0x3e>
	else if (lflag)
  800208:	85 c0                	test   %eax,%eax
  80020a:	74 10                	je     80021c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  80020c:	8b 11                	mov    (%ecx),%edx
  80020e:	8d 42 04             	lea    0x4(%edx),%eax
  800211:	89 01                	mov    %eax,(%ecx)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	ba 00 00 00 00       	mov    $0x0,%edx
  80021a:	eb 0e                	jmp    80022a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80021c:	8b 11                	mov    (%ecx),%edx
  80021e:	8d 42 04             	lea    0x4(%edx),%eax
  800221:	89 01                	mov    %eax,(%ecx)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800235:	83 f8 01             	cmp    $0x1,%eax
  800238:	7e 0e                	jle    800248 <getint+0x1c>
		return va_arg(*ap, long long);
  80023a:	8b 11                	mov    (%ecx),%edx
  80023c:	8d 42 08             	lea    0x8(%edx),%eax
  80023f:	89 01                	mov    %eax,(%ecx)
  800241:	8b 02                	mov    (%edx),%eax
  800243:	8b 52 04             	mov    0x4(%edx),%edx
  800246:	eb 1a                	jmp    800262 <getint+0x36>
	else if (lflag)
  800248:	85 c0                	test   %eax,%eax
  80024a:	74 0c                	je     800258 <getint+0x2c>
		return va_arg(*ap, long);
  80024c:	8b 01                	mov    (%ecx),%eax
  80024e:	8d 50 04             	lea    0x4(%eax),%edx
  800251:	89 11                	mov    %edx,(%ecx)
  800253:	8b 00                	mov    (%eax),%eax
  800255:	99                   	cltd   
  800256:	eb 0a                	jmp    800262 <getint+0x36>
	else
		return va_arg(*ap, int);
  800258:	8b 01                	mov    (%ecx),%eax
  80025a:	8d 50 04             	lea    0x4(%eax),%edx
  80025d:	89 11                	mov    %edx,(%ecx)
  80025f:	8b 00                	mov    (%eax),%eax
  800261:	99                   	cltd   
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 1c             	sub    $0x1c,%esp
  80026d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800270:	0f b6 0b             	movzbl (%ebx),%ecx
  800273:	43                   	inc    %ebx
  800274:	83 f9 25             	cmp    $0x25,%ecx
  800277:	74 1e                	je     800297 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800279:	85 c9                	test   %ecx,%ecx
  80027b:	0f 84 dc 02 00 00    	je     80055d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 0c             	pushl  0xc(%ebp)
  800287:	51                   	push   %ecx
  800288:	ff 55 08             	call   *0x8(%ebp)
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	0f b6 0b             	movzbl (%ebx),%ecx
  800291:	43                   	inc    %ebx
  800292:	83 f9 25             	cmp    $0x25,%ecx
  800295:	75 e2                	jne    800279 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  800297:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80029b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8002a2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002a7:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8002ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b3:	0f b6 0b             	movzbl (%ebx),%ecx
  8002b6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002b9:	43                   	inc    %ebx
  8002ba:	83 f8 55             	cmp    $0x55,%eax
  8002bd:	0f 87 75 02 00 00    	ja     800538 <vprintfmt+0x2d4>
  8002c3:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ca:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8002ce:	eb e3                	jmp    8002b3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002d0:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8002d4:	eb dd                	jmp    8002b3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002d6:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8002db:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8002de:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8002e2:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8002e5:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8002e8:	83 f8 09             	cmp    $0x9,%eax
  8002eb:	77 28                	ja     800315 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002ed:	43                   	inc    %ebx
  8002ee:	eb eb                	jmp    8002db <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f0:	8b 55 14             	mov    0x14(%ebp),%edx
  8002f3:	8d 42 04             	lea    0x4(%edx),%eax
  8002f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8002f9:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8002fb:	eb 18                	jmp    800315 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8002fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800301:	79 b0                	jns    8002b3 <vprintfmt+0x4f>
				width = 0;
  800303:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80030a:	eb a7                	jmp    8002b3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80030c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800313:	eb 9e                	jmp    8002b3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800315:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800319:	79 98                	jns    8002b3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80031b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80031e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800323:	eb 8e                	jmp    8002b3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800325:	47                   	inc    %edi
			goto reswitch;
  800326:	eb 8b                	jmp    8002b3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	ff 75 0c             	pushl  0xc(%ebp)
  80032e:	8b 55 14             	mov    0x14(%ebp),%edx
  800331:	8d 42 04             	lea    0x4(%edx),%eax
  800334:	89 45 14             	mov    %eax,0x14(%ebp)
  800337:	ff 32                	pushl  (%edx)
  800339:	ff 55 08             	call   *0x8(%ebp)
			break;
  80033c:	83 c4 10             	add    $0x10,%esp
  80033f:	e9 2c ff ff ff       	jmp    800270 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800344:	8b 55 14             	mov    0x14(%ebp),%edx
  800347:	8d 42 04             	lea    0x4(%edx),%eax
  80034a:	89 45 14             	mov    %eax,0x14(%ebp)
  80034d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	79 02                	jns    800355 <vprintfmt+0xf1>
				err = -err;
  800353:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800355:	83 f8 0f             	cmp    $0xf,%eax
  800358:	7f 0b                	jg     800365 <vprintfmt+0x101>
  80035a:	8b 3c 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edi
  800361:	85 ff                	test   %edi,%edi
  800363:	75 19                	jne    80037e <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800365:	50                   	push   %eax
  800366:	68 94 10 80 00       	push   $0x801094
  80036b:	ff 75 0c             	pushl  0xc(%ebp)
  80036e:	ff 75 08             	pushl  0x8(%ebp)
  800371:	e8 ef 01 00 00       	call   800565 <printfmt>
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	e9 f2 fe ff ff       	jmp    800270 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  80037e:	57                   	push   %edi
  80037f:	68 9d 10 80 00       	push   $0x80109d
  800384:	ff 75 0c             	pushl  0xc(%ebp)
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	e8 d6 01 00 00       	call   800565 <printfmt>
  80038f:	83 c4 10             	add    $0x10,%esp
			break;
  800392:	e9 d9 fe ff ff       	jmp    800270 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800397:	8b 55 14             	mov    0x14(%ebp),%edx
  80039a:	8d 42 04             	lea    0x4(%edx),%eax
  80039d:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a0:	8b 3a                	mov    (%edx),%edi
  8003a2:	85 ff                	test   %edi,%edi
  8003a4:	75 05                	jne    8003ab <vprintfmt+0x147>
				p = "(null)";
  8003a6:	bf a0 10 80 00       	mov    $0x8010a0,%edi
			if (width > 0 && padc != '-')
  8003ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003af:	7e 3b                	jle    8003ec <vprintfmt+0x188>
  8003b1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8003b5:	74 35                	je     8003ec <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	56                   	push   %esi
  8003bb:	57                   	push   %edi
  8003bc:	e8 58 02 00 00       	call   800619 <strnlen>
  8003c1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8003c4:	83 c4 10             	add    $0x10,%esp
  8003c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003cb:	7e 1f                	jle    8003ec <vprintfmt+0x188>
  8003cd:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8003d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8003d4:	83 ec 08             	sub    $0x8,%esp
  8003d7:	ff 75 0c             	pushl  0xc(%ebp)
  8003da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003dd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e0:	83 c4 10             	add    $0x10,%esp
  8003e3:	ff 4d f0             	decl   -0x10(%ebp)
  8003e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003ea:	7f e8                	jg     8003d4 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8003ec:	0f be 0f             	movsbl (%edi),%ecx
  8003ef:	47                   	inc    %edi
  8003f0:	85 c9                	test   %ecx,%ecx
  8003f2:	74 44                	je     800438 <vprintfmt+0x1d4>
  8003f4:	85 f6                	test   %esi,%esi
  8003f6:	78 03                	js     8003fb <vprintfmt+0x197>
  8003f8:	4e                   	dec    %esi
  8003f9:	78 3d                	js     800438 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8003fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8003ff:	74 18                	je     800419 <vprintfmt+0x1b5>
  800401:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800404:	83 f8 5e             	cmp    $0x5e,%eax
  800407:	76 10                	jbe    800419 <vprintfmt+0x1b5>
					putch('?', putdat);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	ff 75 0c             	pushl  0xc(%ebp)
  80040f:	6a 3f                	push   $0x3f
  800411:	ff 55 08             	call   *0x8(%ebp)
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	eb 0d                	jmp    800426 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 0c             	pushl  0xc(%ebp)
  80041f:	51                   	push   %ecx
  800420:	ff 55 08             	call   *0x8(%ebp)
  800423:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800426:	ff 4d f0             	decl   -0x10(%ebp)
  800429:	0f be 0f             	movsbl (%edi),%ecx
  80042c:	47                   	inc    %edi
  80042d:	85 c9                	test   %ecx,%ecx
  80042f:	74 07                	je     800438 <vprintfmt+0x1d4>
  800431:	85 f6                	test   %esi,%esi
  800433:	78 c6                	js     8003fb <vprintfmt+0x197>
  800435:	4e                   	dec    %esi
  800436:	79 c3                	jns    8003fb <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800438:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80043c:	0f 8e 2e fe ff ff    	jle    800270 <vprintfmt+0xc>
				putch(' ', putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	ff 75 0c             	pushl  0xc(%ebp)
  800448:	6a 20                	push   $0x20
  80044a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	ff 4d f0             	decl   -0x10(%ebp)
  800453:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800457:	7f e9                	jg     800442 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800459:	e9 12 fe ff ff       	jmp    800270 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80045e:	57                   	push   %edi
  80045f:	8d 45 14             	lea    0x14(%ebp),%eax
  800462:	50                   	push   %eax
  800463:	e8 c4 fd ff ff       	call   80022c <getint>
  800468:	89 c6                	mov    %eax,%esi
  80046a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80046c:	83 c4 08             	add    $0x8,%esp
  80046f:	85 d2                	test   %edx,%edx
  800471:	79 15                	jns    800488 <vprintfmt+0x224>
				putch('-', putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 0c             	pushl  0xc(%ebp)
  800479:	6a 2d                	push   $0x2d
  80047b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80047e:	f7 de                	neg    %esi
  800480:	83 d7 00             	adc    $0x0,%edi
  800483:	f7 df                	neg    %edi
  800485:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800488:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80048d:	eb 76                	jmp    800505 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80048f:	57                   	push   %edi
  800490:	8d 45 14             	lea    0x14(%ebp),%eax
  800493:	50                   	push   %eax
  800494:	e8 53 fd ff ff       	call   8001ec <getuint>
  800499:	89 c6                	mov    %eax,%esi
  80049b:	89 d7                	mov    %edx,%edi
			base = 10;
  80049d:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004a2:	83 c4 08             	add    $0x8,%esp
  8004a5:	eb 5e                	jmp    800505 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004a7:	57                   	push   %edi
  8004a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ab:	50                   	push   %eax
  8004ac:	e8 3b fd ff ff       	call   8001ec <getuint>
  8004b1:	89 c6                	mov    %eax,%esi
  8004b3:	89 d7                	mov    %edx,%edi
			base = 8;
  8004b5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004ba:	83 c4 08             	add    $0x8,%esp
  8004bd:	eb 46                	jmp    800505 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	6a 30                	push   $0x30
  8004c7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004ca:	83 c4 08             	add    $0x8,%esp
  8004cd:	ff 75 0c             	pushl  0xc(%ebp)
  8004d0:	6a 78                	push   $0x78
  8004d2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004d5:	8b 55 14             	mov    0x14(%ebp),%edx
  8004d8:	8d 42 04             	lea    0x4(%edx),%eax
  8004db:	89 45 14             	mov    %eax,0x14(%ebp)
  8004de:	8b 32                	mov    (%edx),%esi
  8004e0:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8004e5:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	eb 16                	jmp    800505 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8004ef:	57                   	push   %edi
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f3:	50                   	push   %eax
  8004f4:	e8 f3 fc ff ff       	call   8001ec <getuint>
  8004f9:	89 c6                	mov    %eax,%esi
  8004fb:	89 d7                	mov    %edx,%edi
			base = 16;
  8004fd:	ba 10 00 00 00       	mov    $0x10,%edx
  800502:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800505:	83 ec 04             	sub    $0x4,%esp
  800508:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80050c:	50                   	push   %eax
  80050d:	ff 75 f0             	pushl  -0x10(%ebp)
  800510:	52                   	push   %edx
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	ff 75 08             	pushl  0x8(%ebp)
  800519:	e8 2e fc ff ff       	call   80014c <printnum>
			break;
  80051e:	83 c4 20             	add    $0x20,%esp
  800521:	e9 4a fd ff ff       	jmp    800270 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 0c             	pushl  0xc(%ebp)
  80052c:	51                   	push   %ecx
  80052d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	e9 38 fd ff ff       	jmp    800270 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	6a 25                	push   $0x25
  800540:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800543:	4b                   	dec    %ebx
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80054b:	0f 84 1f fd ff ff    	je     800270 <vprintfmt+0xc>
  800551:	4b                   	dec    %ebx
  800552:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800556:	75 f9                	jne    800551 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800558:	e9 13 fd ff ff       	jmp    800270 <vprintfmt+0xc>
		}
	}
}
  80055d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800560:	5b                   	pop    %ebx
  800561:	5e                   	pop    %esi
  800562:	5f                   	pop    %edi
  800563:	c9                   	leave  
  800564:	c3                   	ret    

00800565 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80056b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056e:	50                   	push   %eax
  80056f:	ff 75 10             	pushl  0x10(%ebp)
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	ff 75 08             	pushl  0x8(%ebp)
  800578:	e8 e7 fc ff ff       	call   800264 <vprintfmt>
	va_end(ap);
}
  80057d:	c9                   	leave  
  80057e:	c3                   	ret    

0080057f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800585:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800588:	8b 0a                	mov    (%edx),%ecx
  80058a:	3b 4a 04             	cmp    0x4(%edx),%ecx
  80058d:	73 07                	jae    800596 <sprintputch+0x17>
		*b->buf++ = ch;
  80058f:	8b 45 08             	mov    0x8(%ebp),%eax
  800592:	88 01                	mov    %al,(%ecx)
  800594:	ff 02                	incl   (%edx)
}
  800596:	c9                   	leave  
  800597:	c3                   	ret    

00800598 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005a4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005a7:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8005ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005ae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8005b5:	85 d2                	test   %edx,%edx
  8005b7:	74 04                	je     8005bd <vsnprintf+0x25>
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	7f 07                	jg     8005c4 <vsnprintf+0x2c>
		return -E_INVAL;
  8005bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005c2:	eb 1d                	jmp    8005e1 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005c4:	ff 75 14             	pushl  0x14(%ebp)
  8005c7:	ff 75 10             	pushl  0x10(%ebp)
  8005ca:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8005cd:	50                   	push   %eax
  8005ce:	68 7f 05 80 00       	push   $0x80057f
  8005d3:	e8 8c fc ff ff       	call   800264 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8005e1:	c9                   	leave  
  8005e2:	c3                   	ret    

008005e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
  8005e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8005ec:	50                   	push   %eax
  8005ed:	ff 75 10             	pushl  0x10(%ebp)
  8005f0:	ff 75 0c             	pushl  0xc(%ebp)
  8005f3:	ff 75 08             	pushl  0x8(%ebp)
  8005f6:	e8 9d ff ff ff       	call   800598 <vsnprintf>
	va_end(ap);

	return rc;
}
  8005fb:	c9                   	leave  
  8005fc:	c3                   	ret    
  8005fd:	00 00                	add    %al,(%eax)
	...

00800600 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800606:	b8 00 00 00 00       	mov    $0x0,%eax
  80060b:	80 3a 00             	cmpb   $0x0,(%edx)
  80060e:	74 07                	je     800617 <strlen+0x17>
		n++;
  800610:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800611:	42                   	inc    %edx
  800612:	80 3a 00             	cmpb   $0x0,(%edx)
  800615:	75 f9                	jne    800610 <strlen+0x10>
		n++;
	return n;
}
  800617:	c9                   	leave  
  800618:	c3                   	ret    

00800619 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800622:	b8 00 00 00 00       	mov    $0x0,%eax
  800627:	85 d2                	test   %edx,%edx
  800629:	74 0f                	je     80063a <strnlen+0x21>
  80062b:	80 39 00             	cmpb   $0x0,(%ecx)
  80062e:	74 0a                	je     80063a <strnlen+0x21>
		n++;
  800630:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800631:	41                   	inc    %ecx
  800632:	4a                   	dec    %edx
  800633:	74 05                	je     80063a <strnlen+0x21>
  800635:	80 39 00             	cmpb   $0x0,(%ecx)
  800638:	75 f6                	jne    800630 <strnlen+0x17>
		n++;
	return n;
}
  80063a:	c9                   	leave  
  80063b:	c3                   	ret    

0080063c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	53                   	push   %ebx
  800640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800643:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800646:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800648:	8a 02                	mov    (%edx),%al
  80064a:	42                   	inc    %edx
  80064b:	88 01                	mov    %al,(%ecx)
  80064d:	41                   	inc    %ecx
  80064e:	84 c0                	test   %al,%al
  800650:	75 f6                	jne    800648 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800652:	89 d8                	mov    %ebx,%eax
  800654:	5b                   	pop    %ebx
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	53                   	push   %ebx
  80065b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80065e:	53                   	push   %ebx
  80065f:	e8 9c ff ff ff       	call   800600 <strlen>
	strcpy(dst + len, src);
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80066a:	50                   	push   %eax
  80066b:	e8 cc ff ff ff       	call   80063c <strcpy>
	return dst;
}
  800670:	89 d8                	mov    %ebx,%eax
  800672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	57                   	push   %edi
  80067b:	56                   	push   %esi
  80067c:	53                   	push   %ebx
  80067d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800680:	8b 55 0c             	mov    0xc(%ebp),%edx
  800683:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  800686:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800688:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068d:	39 f3                	cmp    %esi,%ebx
  80068f:	73 10                	jae    8006a1 <strncpy+0x2a>
		*dst++ = *src;
  800691:	8a 02                	mov    (%edx),%al
  800693:	88 01                	mov    %al,(%ecx)
  800695:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800696:	80 3a 01             	cmpb   $0x1,(%edx)
  800699:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80069c:	43                   	inc    %ebx
  80069d:	39 f3                	cmp    %esi,%ebx
  80069f:	72 f0                	jb     800691 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006a1:	89 f8                	mov    %edi,%eax
  8006a3:	5b                   	pop    %ebx
  8006a4:	5e                   	pop    %esi
  8006a5:	5f                   	pop    %edi
  8006a6:	c9                   	leave  
  8006a7:	c3                   	ret    

008006a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	56                   	push   %esi
  8006ac:	53                   	push   %ebx
  8006ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006b6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	74 19                	je     8006d5 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006bc:	4a                   	dec    %edx
  8006bd:	74 13                	je     8006d2 <strlcpy+0x2a>
  8006bf:	80 39 00             	cmpb   $0x0,(%ecx)
  8006c2:	74 0e                	je     8006d2 <strlcpy+0x2a>
  8006c4:	8a 01                	mov    (%ecx),%al
  8006c6:	41                   	inc    %ecx
  8006c7:	88 03                	mov    %al,(%ebx)
  8006c9:	43                   	inc    %ebx
  8006ca:	4a                   	dec    %edx
  8006cb:	74 05                	je     8006d2 <strlcpy+0x2a>
  8006cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d0:	75 f2                	jne    8006c4 <strlcpy+0x1c>
		*dst = '\0';
  8006d2:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006d5:	89 d8                	mov    %ebx,%eax
  8006d7:	29 f0                	sub    %esi,%eax
}
  8006d9:	5b                   	pop    %ebx
  8006da:	5e                   	pop    %esi
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8006e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006e9:	74 13                	je     8006fe <strcmp+0x21>
  8006eb:	8a 02                	mov    (%edx),%al
  8006ed:	3a 01                	cmp    (%ecx),%al
  8006ef:	75 0d                	jne    8006fe <strcmp+0x21>
  8006f1:	42                   	inc    %edx
  8006f2:	41                   	inc    %ecx
  8006f3:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f6:	74 06                	je     8006fe <strcmp+0x21>
  8006f8:	8a 02                	mov    (%edx),%al
  8006fa:	3a 01                	cmp    (%ecx),%al
  8006fc:	74 f3                	je     8006f1 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8006fe:	0f b6 02             	movzbl (%edx),%eax
  800701:	0f b6 11             	movzbl (%ecx),%edx
  800704:	29 d0                	sub    %edx,%eax
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	53                   	push   %ebx
  80070c:	8b 55 08             	mov    0x8(%ebp),%edx
  80070f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800712:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800715:	85 c9                	test   %ecx,%ecx
  800717:	74 1f                	je     800738 <strncmp+0x30>
  800719:	80 3a 00             	cmpb   $0x0,(%edx)
  80071c:	74 16                	je     800734 <strncmp+0x2c>
  80071e:	8a 02                	mov    (%edx),%al
  800720:	3a 03                	cmp    (%ebx),%al
  800722:	75 10                	jne    800734 <strncmp+0x2c>
  800724:	42                   	inc    %edx
  800725:	43                   	inc    %ebx
  800726:	49                   	dec    %ecx
  800727:	74 0f                	je     800738 <strncmp+0x30>
  800729:	80 3a 00             	cmpb   $0x0,(%edx)
  80072c:	74 06                	je     800734 <strncmp+0x2c>
  80072e:	8a 02                	mov    (%edx),%al
  800730:	3a 03                	cmp    (%ebx),%al
  800732:	74 f0                	je     800724 <strncmp+0x1c>
	if (n == 0)
  800734:	85 c9                	test   %ecx,%ecx
  800736:	75 07                	jne    80073f <strncmp+0x37>
		return 0;
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	eb 0a                	jmp    800749 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80073f:	0f b6 12             	movzbl (%edx),%edx
  800742:	0f b6 03             	movzbl (%ebx),%eax
  800745:	29 c2                	sub    %eax,%edx
  800747:	89 d0                	mov    %edx,%eax
}
  800749:	5b                   	pop    %ebx
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800755:	80 38 00             	cmpb   $0x0,(%eax)
  800758:	74 0a                	je     800764 <strchr+0x18>
		if (*s == c)
  80075a:	38 10                	cmp    %dl,(%eax)
  80075c:	74 0b                	je     800769 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80075e:	40                   	inc    %eax
  80075f:	80 38 00             	cmpb   $0x0,(%eax)
  800762:	75 f6                	jne    80075a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800774:	80 38 00             	cmpb   $0x0,(%eax)
  800777:	74 0a                	je     800783 <strfind+0x18>
		if (*s == c)
  800779:	38 10                	cmp    %dl,(%eax)
  80077b:	74 06                	je     800783 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80077d:	40                   	inc    %eax
  80077e:	80 38 00             	cmpb   $0x0,(%eax)
  800781:	75 f6                	jne    800779 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	57                   	push   %edi
  800789:	8b 7d 08             	mov    0x8(%ebp),%edi
  80078c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  80078f:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800791:	85 c9                	test   %ecx,%ecx
  800793:	74 40                	je     8007d5 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800795:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80079b:	75 30                	jne    8007cd <memset+0x48>
  80079d:	f6 c1 03             	test   $0x3,%cl
  8007a0:	75 2b                	jne    8007cd <memset+0x48>
		c &= 0xFF;
  8007a2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	c1 e0 18             	shl    $0x18,%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b2:	c1 e2 10             	shl    $0x10,%edx
  8007b5:	09 d0                	or     %edx,%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	c1 e2 08             	shl    $0x8,%edx
  8007bd:	09 d0                	or     %edx,%eax
  8007bf:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8007c2:	c1 e9 02             	shr    $0x2,%ecx
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	fc                   	cld    
  8007c9:	f3 ab                	rep stos %eax,%es:(%edi)
  8007cb:	eb 06                	jmp    8007d3 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	fc                   	cld    
  8007d1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8007d3:	89 f8                	mov    %edi,%eax
}
  8007d5:	5f                   	pop    %edi
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	57                   	push   %edi
  8007dc:	56                   	push   %esi
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8007e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007e6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007e8:	39 c6                	cmp    %eax,%esi
  8007ea:	73 34                	jae    800820 <memmove+0x48>
  8007ec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8007ef:	39 c2                	cmp    %eax,%edx
  8007f1:	76 2d                	jbe    800820 <memmove+0x48>
		s += n;
  8007f3:	89 d6                	mov    %edx,%esi
		d += n;
  8007f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8007f8:	f6 c2 03             	test   $0x3,%dl
  8007fb:	75 1b                	jne    800818 <memmove+0x40>
  8007fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800803:	75 13                	jne    800818 <memmove+0x40>
  800805:	f6 c1 03             	test   $0x3,%cl
  800808:	75 0e                	jne    800818 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80080a:	83 ef 04             	sub    $0x4,%edi
  80080d:	83 ee 04             	sub    $0x4,%esi
  800810:	c1 e9 02             	shr    $0x2,%ecx
  800813:	fd                   	std    
  800814:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800816:	eb 05                	jmp    80081d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800818:	4f                   	dec    %edi
  800819:	4e                   	dec    %esi
  80081a:	fd                   	std    
  80081b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80081d:	fc                   	cld    
  80081e:	eb 20                	jmp    800840 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800820:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800826:	75 15                	jne    80083d <memmove+0x65>
  800828:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082e:	75 0d                	jne    80083d <memmove+0x65>
  800830:	f6 c1 03             	test   $0x3,%cl
  800833:	75 08                	jne    80083d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800835:	c1 e9 02             	shr    $0x2,%ecx
  800838:	fc                   	cld    
  800839:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80083b:	eb 03                	jmp    800840 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80083d:	fc                   	cld    
  80083e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800840:	5e                   	pop    %esi
  800841:	5f                   	pop    %edi
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 83 ff ff ff       	call   8007d8 <memmove>
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80085e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800861:	8b 55 10             	mov    0x10(%ebp),%edx
  800864:	4a                   	dec    %edx
  800865:	83 fa ff             	cmp    $0xffffffff,%edx
  800868:	74 1a                	je     800884 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80086a:	8a 01                	mov    (%ecx),%al
  80086c:	3a 03                	cmp    (%ebx),%al
  80086e:	74 0c                	je     80087c <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800870:	0f b6 d0             	movzbl %al,%edx
  800873:	0f b6 03             	movzbl (%ebx),%eax
  800876:	29 c2                	sub    %eax,%edx
  800878:	89 d0                	mov    %edx,%eax
  80087a:	eb 0d                	jmp    800889 <memcmp+0x32>
		s1++, s2++;
  80087c:	41                   	inc    %ecx
  80087d:	43                   	inc    %ebx
  80087e:	4a                   	dec    %edx
  80087f:	83 fa ff             	cmp    $0xffffffff,%edx
  800882:	75 e6                	jne    80086a <memcmp+0x13>
	}

	return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800889:	5b                   	pop    %ebx
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800895:	89 c2                	mov    %eax,%edx
  800897:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80089a:	39 d0                	cmp    %edx,%eax
  80089c:	73 09                	jae    8008a7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80089e:	38 08                	cmp    %cl,(%eax)
  8008a0:	74 05                	je     8008a7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008a2:	40                   	inc    %eax
  8008a3:	39 d0                	cmp    %edx,%eax
  8008a5:	72 f7                	jb     80089e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8008b8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8008bd:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008c2:	80 3a 20             	cmpb   $0x20,(%edx)
  8008c5:	74 05                	je     8008cc <strtol+0x23>
  8008c7:	80 3a 09             	cmpb   $0x9,(%edx)
  8008ca:	75 0b                	jne    8008d7 <strtol+0x2e>
  8008cc:	42                   	inc    %edx
  8008cd:	80 3a 20             	cmpb   $0x20,(%edx)
  8008d0:	74 fa                	je     8008cc <strtol+0x23>
  8008d2:	80 3a 09             	cmpb   $0x9,(%edx)
  8008d5:	74 f5                	je     8008cc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8008d7:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8008da:	75 03                	jne    8008df <strtol+0x36>
		s++;
  8008dc:	42                   	inc    %edx
  8008dd:	eb 0b                	jmp    8008ea <strtol+0x41>
	else if (*s == '-')
  8008df:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8008e2:	75 06                	jne    8008ea <strtol+0x41>
		s++, neg = 1;
  8008e4:	42                   	inc    %edx
  8008e5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 05                	je     8008f3 <strtol+0x4a>
  8008ee:	83 f9 10             	cmp    $0x10,%ecx
  8008f1:	75 15                	jne    800908 <strtol+0x5f>
  8008f3:	80 3a 30             	cmpb   $0x30,(%edx)
  8008f6:	75 10                	jne    800908 <strtol+0x5f>
  8008f8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8008fc:	75 0a                	jne    800908 <strtol+0x5f>
		s += 2, base = 16;
  8008fe:	83 c2 02             	add    $0x2,%edx
  800901:	b9 10 00 00 00       	mov    $0x10,%ecx
  800906:	eb 14                	jmp    80091c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	75 10                	jne    80091c <strtol+0x73>
  80090c:	80 3a 30             	cmpb   $0x30,(%edx)
  80090f:	75 05                	jne    800916 <strtol+0x6d>
		s++, base = 8;
  800911:	42                   	inc    %edx
  800912:	b1 08                	mov    $0x8,%cl
  800914:	eb 06                	jmp    80091c <strtol+0x73>
	else if (base == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	75 02                	jne    80091c <strtol+0x73>
		base = 10;
  80091a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80091c:	8a 02                	mov    (%edx),%al
  80091e:	83 e8 30             	sub    $0x30,%eax
  800921:	3c 09                	cmp    $0x9,%al
  800923:	77 08                	ja     80092d <strtol+0x84>
			dig = *s - '0';
  800925:	0f be 02             	movsbl (%edx),%eax
  800928:	83 e8 30             	sub    $0x30,%eax
  80092b:	eb 20                	jmp    80094d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  80092d:	8a 02                	mov    (%edx),%al
  80092f:	83 e8 61             	sub    $0x61,%eax
  800932:	3c 19                	cmp    $0x19,%al
  800934:	77 08                	ja     80093e <strtol+0x95>
			dig = *s - 'a' + 10;
  800936:	0f be 02             	movsbl (%edx),%eax
  800939:	83 e8 57             	sub    $0x57,%eax
  80093c:	eb 0f                	jmp    80094d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  80093e:	8a 02                	mov    (%edx),%al
  800940:	83 e8 41             	sub    $0x41,%eax
  800943:	3c 19                	cmp    $0x19,%al
  800945:	77 12                	ja     800959 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800947:	0f be 02             	movsbl (%edx),%eax
  80094a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80094d:	39 c8                	cmp    %ecx,%eax
  80094f:	7d 08                	jge    800959 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800951:	42                   	inc    %edx
  800952:	0f af d9             	imul   %ecx,%ebx
  800955:	01 c3                	add    %eax,%ebx
  800957:	eb c3                	jmp    80091c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800959:	85 f6                	test   %esi,%esi
  80095b:	74 02                	je     80095f <strtol+0xb6>
		*endptr = (char *) s;
  80095d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80095f:	89 d8                	mov    %ebx,%eax
  800961:	85 ff                	test   %edi,%edi
  800963:	74 02                	je     800967 <strtol+0xbe>
  800965:	f7 d8                	neg    %eax
}
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	83 ec 04             	sub    $0x4,%esp
  800975:	8b 55 08             	mov    0x8(%ebp),%edx
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80097b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800980:	89 f8                	mov    %edi,%eax
  800982:	89 fb                	mov    %edi,%ebx
  800984:	89 fe                	mov    %edi,%esi
  800986:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800988:	83 c4 04             	add    $0x4,%esp
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <sys_cgetc>:

int
sys_cgetc(void)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800996:	b8 01 00 00 00       	mov    $0x1,%eax
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009a0:	89 fa                	mov    %edi,%edx
  8009a2:	89 f9                	mov    %edi,%ecx
  8009a4:	89 fb                	mov    %edi,%ebx
  8009a6:	89 fe                	mov    %edi,%esi
  8009a8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	83 ec 0c             	sub    $0xc,%esp
  8009b8:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8009c0:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009c5:	89 f9                	mov    %edi,%ecx
  8009c7:	89 fb                	mov    %edi,%ebx
  8009c9:	89 fe                	mov    %edi,%esi
  8009cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8009cd:	85 c0                	test   %eax,%eax
  8009cf:	7e 17                	jle    8009e8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009d1:	83 ec 0c             	sub    $0xc,%esp
  8009d4:	50                   	push   %eax
  8009d5:	6a 03                	push   $0x3
  8009d7:	68 78 12 80 00       	push   $0x801278
  8009dc:	6a 23                	push   $0x23
  8009de:	68 95 12 80 00       	push   $0x801295
  8009e3:	e8 38 02 00 00       	call   800c20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8009e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a00:	89 fa                	mov    %edi,%edx
  800a02:	89 f9                	mov    %edi,%ecx
  800a04:	89 fb                	mov    %edi,%ebx
  800a06:	89 fe                	mov    %edi,%esi
  800a08:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <sys_yield>:

void
sys_yield(void)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1f:	89 fa                	mov    %edi,%edx
  800a21:	89 f9                	mov    %edi,%ecx
  800a23:	89 fb                	mov    %edi,%ebx
  800a25:	89 fe                	mov    %edi,%esi
  800a27:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a40:	b8 04 00 00 00       	mov    $0x4,%eax
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4a:	89 fe                	mov    %edi,%esi
  800a4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	7e 17                	jle    800a69 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a52:	83 ec 0c             	sub    $0xc,%esp
  800a55:	50                   	push   %eax
  800a56:	6a 04                	push   $0x4
  800a58:	68 78 12 80 00       	push   $0x801278
  800a5d:	6a 23                	push   $0x23
  800a5f:	68 95 12 80 00       	push   $0x801295
  800a64:	e8 b7 01 00 00       	call   800c20 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800a69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	83 ec 0c             	sub    $0xc,%esp
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800a86:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a89:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a90:	85 c0                	test   %eax,%eax
  800a92:	7e 17                	jle    800aab <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a94:	83 ec 0c             	sub    $0xc,%esp
  800a97:	50                   	push   %eax
  800a98:	6a 05                	push   $0x5
  800a9a:	68 78 12 80 00       	push   $0x801278
  800a9f:	6a 23                	push   $0x23
  800aa1:	68 95 12 80 00       	push   $0x801295
  800aa6:	e8 75 01 00 00       	call   800c20 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800aab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    

00800ab3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	89 fb                	mov    %edi,%ebx
  800ace:	89 fe                	mov    %edi,%esi
  800ad0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	7e 17                	jle    800aed <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	50                   	push   %eax
  800ada:	6a 06                	push   $0x6
  800adc:	68 78 12 80 00       	push   $0x801278
  800ae1:	6a 23                	push   $0x23
  800ae3:	68 95 12 80 00       	push   $0x801295
  800ae8:	e8 33 01 00 00       	call   800c20 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b04:	b8 08 00 00 00       	mov    $0x8,%eax
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	89 fb                	mov    %edi,%ebx
  800b10:	89 fe                	mov    %edi,%esi
  800b12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b14:	85 c0                	test   %eax,%eax
  800b16:	7e 17                	jle    800b2f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	50                   	push   %eax
  800b1c:	6a 08                	push   $0x8
  800b1e:	68 78 12 80 00       	push   $0x801278
  800b23:	6a 23                	push   $0x23
  800b25:	68 95 12 80 00       	push   $0x801295
  800b2a:	e8 f1 00 00 00       	call   800c20 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b46:	b8 09 00 00 00       	mov    $0x9,%eax
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	89 fb                	mov    %edi,%ebx
  800b52:	89 fe                	mov    %edi,%esi
  800b54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	7e 17                	jle    800b71 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	50                   	push   %eax
  800b5e:	6a 09                	push   $0x9
  800b60:	68 78 12 80 00       	push   $0x801278
  800b65:	6a 23                	push   $0x23
  800b67:	68 95 12 80 00       	push   $0x801295
  800b6c:	e8 af 00 00 00       	call   800c20 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	89 fb                	mov    %edi,%ebx
  800b94:	89 fe                	mov    %edi,%esi
  800b96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7e 17                	jle    800bb3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 0a                	push   $0xa
  800ba2:	68 78 12 80 00       	push   $0x801278
  800ba7:	6a 23                	push   $0x23
  800ba9:	68 95 12 80 00       	push   $0x801295
  800bae:	e8 6d 00 00 00       	call   800c20 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bcd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bd2:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800bef:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	89 f9                	mov    %edi,%ecx
  800bf6:	89 fb                	mov    %edi,%ebx
  800bf8:	89 fe                	mov    %edi,%esi
  800bfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 0d                	push   $0xd
  800c06:	68 78 12 80 00       	push   $0x801278
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 95 12 80 00       	push   $0x801295
  800c12:	e8 09 00 00 00       	call   800c20 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    
	...

00800c20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	53                   	push   %ebx
  800c24:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800c27:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	ff 75 08             	pushl  0x8(%ebp)
  800c30:	ff 35 00 20 80 00    	pushl  0x802000
  800c36:	83 ec 08             	sub    $0x8,%esp
  800c39:	e8 b2 fd ff ff       	call   8009f0 <sys_getenvid>
  800c3e:	83 c4 08             	add    $0x8,%esp
  800c41:	50                   	push   %eax
  800c42:	68 a4 12 80 00       	push   $0x8012a4
  800c47:	e8 ec f4 ff ff       	call   800138 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c4c:	83 c4 18             	add    $0x18,%esp
  800c4f:	53                   	push   %ebx
  800c50:	ff 75 10             	pushl  0x10(%ebp)
  800c53:	e8 8f f4 ff ff       	call   8000e7 <vcprintf>
	cprintf("\n");
  800c58:	c7 04 24 c8 12 80 00 	movl   $0x8012c8,(%esp)
  800c5f:	e8 d4 f4 ff ff       	call   800138 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800c64:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800c67:	cc                   	int3   
  800c68:	eb fd                	jmp    800c67 <_panic+0x47>
	...

00800c6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	83 ec 14             	sub    $0x14,%esp
  800c74:	8b 55 14             	mov    0x14(%ebp),%edx
  800c77:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c7d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c80:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c82:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c88:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c8b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c8d:	75 11                	jne    800ca0 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800c8f:	39 f8                	cmp    %edi,%eax
  800c91:	76 4d                	jbe    800ce0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c93:	89 fa                	mov    %edi,%edx
  800c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c98:	f7 75 e4             	divl   -0x1c(%ebp)
  800c9b:	89 c7                	mov    %eax,%edi
  800c9d:	eb 09                	jmp    800ca8 <__udivdi3+0x3c>
  800c9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ca0:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800ca3:	76 17                	jbe    800cbc <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800ca5:	31 ff                	xor    %edi,%edi
  800ca7:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800ca8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800caf:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb2:	83 c4 14             	add    $0x14,%esp
  800cb5:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb6:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb8:	5f                   	pop    %edi
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    
  800cbb:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cbc:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cc0:	89 c7                	mov    %eax,%edi
  800cc2:	83 f7 1f             	xor    $0x1f,%edi
  800cc5:	75 4d                	jne    800d14 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cca:	77 0a                	ja     800cd6 <__udivdi3+0x6a>
  800ccc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800ccf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cd1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800cd4:	72 d2                	jb     800ca8 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cd6:	bf 01 00 00 00       	mov    $0x1,%edi
  800cdb:	eb cb                	jmp    800ca8 <__udivdi3+0x3c>
  800cdd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	75 0e                	jne    800cf5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cec:	31 c9                	xor    %ecx,%ecx
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f1                	div    %ecx
  800cf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf5:	89 f0                	mov    %esi,%eax
  800cf7:	31 d2                	xor    %edx,%edx
  800cf9:	f7 75 e4             	divl   -0x1c(%ebp)
  800cfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d02:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d05:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d08:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0b:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d0d:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d0e:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d10:	5f                   	pop    %edi
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    
  800d13:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d14:	b8 20 00 00 00       	mov    $0x20,%eax
  800d19:	29 f8                	sub    %edi,%eax
  800d1b:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d1e:	89 f9                	mov    %edi,%ecx
  800d20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d23:	d3 e2                	shl    %cl,%edx
  800d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d28:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d2b:	d3 e8                	shr    %cl,%eax
  800d2d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d2f:	89 f9                	mov    %edi,%ecx
  800d31:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d34:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d37:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d3a:	89 f2                	mov    %esi,%edx
  800d3c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d3e:	89 f9                	mov    %edi,%ecx
  800d40:	d3 e6                	shl    %cl,%esi
  800d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d45:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d48:	d3 e8                	shr    %cl,%eax
  800d4a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d4c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d4e:	89 f0                	mov    %esi,%eax
  800d50:	f7 75 f4             	divl   -0xc(%ebp)
  800d53:	89 d6                	mov    %edx,%esi
  800d55:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d57:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d5d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d5f:	39 f2                	cmp    %esi,%edx
  800d61:	77 0f                	ja     800d72 <__udivdi3+0x106>
  800d63:	0f 85 3f ff ff ff    	jne    800ca8 <__udivdi3+0x3c>
  800d69:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d6c:	0f 86 36 ff ff ff    	jbe    800ca8 <__udivdi3+0x3c>
		{
		  q0--;
  800d72:	4f                   	dec    %edi
  800d73:	e9 30 ff ff ff       	jmp    800ca8 <__udivdi3+0x3c>

00800d78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	83 ec 30             	sub    $0x30,%esp
  800d80:	8b 55 14             	mov    0x14(%ebp),%edx
  800d83:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d86:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d88:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d8b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d93:	85 ff                	test   %edi,%edi
  800d95:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800da3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800da9:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dac:	75 3e                	jne    800dec <__umoddi3+0x74>
    {
      if (d0 > n1)
  800dae:	39 d6                	cmp    %edx,%esi
  800db0:	0f 86 a2 00 00 00    	jbe    800e58 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db6:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800db8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dbb:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dbd:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dc0:	74 1b                	je     800ddd <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800dc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dd2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800dd5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dd8:	89 10                	mov    %edx,(%eax)
  800dda:	89 48 04             	mov    %ecx,0x4(%eax)
  800ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800de3:	83 c4 30             	add    $0x30,%esp
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    
  800dea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dec:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800def:	76 1f                	jbe    800e10 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800df4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800dfa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800dfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e06:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e09:	83 c4 30             	add    $0x30,%esp
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e10:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e13:	83 f0 1f             	xor    $0x1f,%eax
  800e16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e19:	75 61                	jne    800e7c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e1b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e1e:	77 05                	ja     800e25 <__umoddi3+0xad>
  800e20:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e23:	72 10                	jb     800e35 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e25:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e28:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e2b:	29 f0                	sub    %esi,%eax
  800e2d:	19 fa                	sbb    %edi,%edx
  800e2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e32:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e35:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e38:	85 d2                	test   %edx,%edx
  800e3a:	74 a1                	je     800ddd <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e3f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e42:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e48:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e51:	89 01                	mov    %eax,(%ecx)
  800e53:	89 51 04             	mov    %edx,0x4(%ecx)
  800e56:	eb 85                	jmp    800ddd <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e58:	85 f6                	test   %esi,%esi
  800e5a:	75 0b                	jne    800e67 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e61:	31 d2                	xor    %edx,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e67:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e6a:	89 fa                	mov    %edi,%edx
  800e6c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e71:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e74:	f7 f6                	div    %esi
  800e76:	e9 3d ff ff ff       	jmp    800db8 <__umoddi3+0x40>
  800e7b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e81:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e84:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e87:	89 fa                	mov    %edi,%edx
  800e89:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e8c:	d3 e2                	shl    %cl,%edx
  800e8e:	89 f0                	mov    %esi,%eax
  800e90:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e93:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800e95:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800e98:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e9a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e9c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800e9f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ea2:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ea4:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800ea6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ea9:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800eac:	d3 e0                	shl    %cl,%eax
  800eae:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800eb1:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eb4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eb7:	d3 e8                	shr    %cl,%eax
  800eb9:	0b 45 cc             	or     -0x34(%ebp),%eax
  800ebc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800ebf:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ec2:	f7 f7                	div    %edi
  800ec4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ec7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800eca:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ecc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ecf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ed2:	77 0a                	ja     800ede <__umoddi3+0x166>
  800ed4:	75 12                	jne    800ee8 <__umoddi3+0x170>
  800ed6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ed9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800edc:	76 0a                	jbe    800ee8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ede:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ee1:	29 f1                	sub    %esi,%ecx
  800ee3:	19 fa                	sbb    %edi,%edx
  800ee5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800ee8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 84 ea fe ff ff    	je     800ddd <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ef3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ef6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef9:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800efc:	19 d1                	sbb    %edx,%ecx
  800efe:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f01:	89 ca                	mov    %ecx,%edx
  800f03:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f06:	d3 e2                	shl    %cl,%edx
  800f08:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f0b:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f0e:	d3 e8                	shr    %cl,%eax
  800f10:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f12:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f15:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f17:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f1d:	e9 ad fe ff ff       	jmp    800dcf <__umoddi3+0x57>
