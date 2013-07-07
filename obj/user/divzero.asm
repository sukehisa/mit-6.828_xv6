
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	99                   	cltd   
  80004a:	f7 3d 04 20 80 00    	idivl  0x802004
  800050:	50                   	push   %eax
  800051:	68 40 0f 80 00       	push   $0x800f40
  800056:	e8 f1 00 00 00       	call   80014c <cprintf>
}
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    
  80005d:	00 00                	add    %al,(%eax)
	...

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 75 08             	mov    0x8(%ebp),%esi
  800068:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80006b:	e8 94 09 00 00       	call   800a04 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	89 c2                	mov    %eax,%edx
  800077:	c1 e2 05             	shl    $0x5,%edx
  80007a:	29 c2                	sub    %eax,%edx
  80007c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800083:	89 15 08 20 80 00    	mov    %edx,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	83 ec 08             	sub    $0x8,%esp
  800097:	53                   	push   %ebx
  800098:	56                   	push   %esi
  800099:	e8 96 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009e:	e8 09 00 00 00       	call   8000ac <exit>
}
  8000a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 0a 09 00 00       	call   8009c3 <sys_env_destroy>
}
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    
	...

008000bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8000cf:	40                   	inc    %eax
  8000d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d7:	75 1a                	jne    8000f3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000d9:	83 ec 08             	sub    $0x8,%esp
  8000dc:	68 ff 00 00 00       	push   $0xff
  8000e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e4:	50                   	push   %eax
  8000e5:	e8 96 08 00 00       	call   800980 <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f3:	ff 43 04             	incl   0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 bc 00 80 00       	push   $0x8000bc
  80012a:	e8 49 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800138:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 3c 08 00 00       	call   800980 <sys_cputs>

	return b.cnt;
  800144:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	8b 75 10             	mov    0x10(%ebp),%esi
  80016c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80016f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800172:	8b 45 18             	mov    0x18(%ebp),%eax
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	39 fa                	cmp    %edi,%edx
  80017c:	77 39                	ja     8001b7 <printnum+0x57>
  80017e:	72 04                	jb     800184 <printnum+0x24>
  800180:	39 f0                	cmp    %esi,%eax
  800182:	77 33                	ja     8001b7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	ff 75 20             	pushl  0x20(%ebp)
  80018a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80018d:	50                   	push   %eax
  80018e:	ff 75 18             	pushl  0x18(%ebp)
  800191:	8b 45 18             	mov    0x18(%ebp),%eax
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	52                   	push   %edx
  80019a:	50                   	push   %eax
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	e8 de 0a 00 00       	call   800c80 <__udivdi3>
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	52                   	push   %edx
  8001a6:	50                   	push   %eax
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 ae ff ff ff       	call   800160 <printnum>
  8001b2:	83 c4 20             	add    $0x20,%esp
  8001b5:	eb 19                	jmp    8001d0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b7:	4b                   	dec    %ebx
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7e 14                	jle    8001d0 <printnum+0x70>
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	ff 75 0c             	pushl  0xc(%ebp)
  8001c2:	ff 75 20             	pushl  0x20(%ebp)
  8001c5:	ff 55 08             	call   *0x8(%ebp)
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	4b                   	dec    %ebx
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7f ec                	jg     8001bc <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	8b 45 18             	mov    0x18(%ebp),%eax
  8001d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	52                   	push   %edx
  8001e2:	50                   	push   %eax
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	e8 a2 0b 00 00       	call   800d8c <__umoddi3>
  8001ea:	83 c4 14             	add    $0x14,%esp
  8001ed:	0f be 80 6a 10 80 00 	movsbl 0x80106a(%eax),%eax
  8001f4:	50                   	push   %eax
  8001f5:	ff 55 08             	call   *0x8(%ebp)
}
  8001f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5f                   	pop    %edi
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800209:	83 f8 01             	cmp    $0x1,%eax
  80020c:	7e 0e                	jle    80021c <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80020e:	8b 11                	mov    (%ecx),%edx
  800210:	8d 42 08             	lea    0x8(%edx),%eax
  800213:	89 01                	mov    %eax,(%ecx)
  800215:	8b 02                	mov    (%edx),%eax
  800217:	8b 52 04             	mov    0x4(%edx),%edx
  80021a:	eb 22                	jmp    80023e <getuint+0x3e>
	else if (lflag)
  80021c:	85 c0                	test   %eax,%eax
  80021e:	74 10                	je     800230 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800220:	8b 11                	mov    (%ecx),%edx
  800222:	8d 42 04             	lea    0x4(%edx),%eax
  800225:	89 01                	mov    %eax,(%ecx)
  800227:	8b 02                	mov    (%edx),%eax
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
  80022e:	eb 0e                	jmp    80023e <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800230:	8b 11                	mov    (%ecx),%edx
  800232:	8d 42 04             	lea    0x4(%edx),%eax
  800235:	89 01                	mov    %eax,(%ecx)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800246:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800249:	83 f8 01             	cmp    $0x1,%eax
  80024c:	7e 0e                	jle    80025c <getint+0x1c>
		return va_arg(*ap, long long);
  80024e:	8b 11                	mov    (%ecx),%edx
  800250:	8d 42 08             	lea    0x8(%edx),%eax
  800253:	89 01                	mov    %eax,(%ecx)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	8b 52 04             	mov    0x4(%edx),%edx
  80025a:	eb 1a                	jmp    800276 <getint+0x36>
	else if (lflag)
  80025c:	85 c0                	test   %eax,%eax
  80025e:	74 0c                	je     80026c <getint+0x2c>
		return va_arg(*ap, long);
  800260:	8b 01                	mov    (%ecx),%eax
  800262:	8d 50 04             	lea    0x4(%eax),%edx
  800265:	89 11                	mov    %edx,(%ecx)
  800267:	8b 00                	mov    (%eax),%eax
  800269:	99                   	cltd   
  80026a:	eb 0a                	jmp    800276 <getint+0x36>
	else
		return va_arg(*ap, int);
  80026c:	8b 01                	mov    (%ecx),%eax
  80026e:	8d 50 04             	lea    0x4(%eax),%edx
  800271:	89 11                	mov    %edx,(%ecx)
  800273:	8b 00                	mov    (%eax),%eax
  800275:	99                   	cltd   
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 1c             	sub    $0x1c,%esp
  800281:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800284:	0f b6 0b             	movzbl (%ebx),%ecx
  800287:	43                   	inc    %ebx
  800288:	83 f9 25             	cmp    $0x25,%ecx
  80028b:	74 1e                	je     8002ab <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028d:	85 c9                	test   %ecx,%ecx
  80028f:	0f 84 dc 02 00 00    	je     800571 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	51                   	push   %ecx
  80029c:	ff 55 08             	call   *0x8(%ebp)
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	0f b6 0b             	movzbl (%ebx),%ecx
  8002a5:	43                   	inc    %ebx
  8002a6:	83 f9 25             	cmp    $0x25,%ecx
  8002a9:	75 e2                	jne    80028d <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002ab:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8002af:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8002b6:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002bb:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8002c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c7:	0f b6 0b             	movzbl (%ebx),%ecx
  8002ca:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002cd:	43                   	inc    %ebx
  8002ce:	83 f8 55             	cmp    $0x55,%eax
  8002d1:	0f 87 75 02 00 00    	ja     80054c <vprintfmt+0x2d4>
  8002d7:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002de:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8002e2:	eb e3                	jmp    8002c7 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002e4:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8002e8:	eb dd                	jmp    8002c7 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002ea:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8002ef:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8002f2:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8002f6:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8002f9:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8002fc:	83 f8 09             	cmp    $0x9,%eax
  8002ff:	77 28                	ja     800329 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800301:	43                   	inc    %ebx
  800302:	eb eb                	jmp    8002ef <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800304:	8b 55 14             	mov    0x14(%ebp),%edx
  800307:	8d 42 04             	lea    0x4(%edx),%eax
  80030a:	89 45 14             	mov    %eax,0x14(%ebp)
  80030d:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80030f:	eb 18                	jmp    800329 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800311:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800315:	79 b0                	jns    8002c7 <vprintfmt+0x4f>
				width = 0;
  800317:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80031e:	eb a7                	jmp    8002c7 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800320:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800327:	eb 9e                	jmp    8002c7 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800329:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80032d:	79 98                	jns    8002c7 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80032f:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800332:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800337:	eb 8e                	jmp    8002c7 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800339:	47                   	inc    %edi
			goto reswitch;
  80033a:	eb 8b                	jmp    8002c7 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	ff 75 0c             	pushl  0xc(%ebp)
  800342:	8b 55 14             	mov    0x14(%ebp),%edx
  800345:	8d 42 04             	lea    0x4(%edx),%eax
  800348:	89 45 14             	mov    %eax,0x14(%ebp)
  80034b:	ff 32                	pushl  (%edx)
  80034d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	e9 2c ff ff ff       	jmp    800284 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800358:	8b 55 14             	mov    0x14(%ebp),%edx
  80035b:	8d 42 04             	lea    0x4(%edx),%eax
  80035e:	89 45 14             	mov    %eax,0x14(%ebp)
  800361:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800363:	85 c0                	test   %eax,%eax
  800365:	79 02                	jns    800369 <vprintfmt+0xf1>
				err = -err;
  800367:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800369:	83 f8 0f             	cmp    $0xf,%eax
  80036c:	7f 0b                	jg     800379 <vprintfmt+0x101>
  80036e:	8b 3c 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edi
  800375:	85 ff                	test   %edi,%edi
  800377:	75 19                	jne    800392 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800379:	50                   	push   %eax
  80037a:	68 7b 10 80 00       	push   $0x80107b
  80037f:	ff 75 0c             	pushl  0xc(%ebp)
  800382:	ff 75 08             	pushl  0x8(%ebp)
  800385:	e8 ef 01 00 00       	call   800579 <printfmt>
  80038a:	83 c4 10             	add    $0x10,%esp
  80038d:	e9 f2 fe ff ff       	jmp    800284 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800392:	57                   	push   %edi
  800393:	68 84 10 80 00       	push   $0x801084
  800398:	ff 75 0c             	pushl  0xc(%ebp)
  80039b:	ff 75 08             	pushl  0x8(%ebp)
  80039e:	e8 d6 01 00 00       	call   800579 <printfmt>
  8003a3:	83 c4 10             	add    $0x10,%esp
			break;
  8003a6:	e9 d9 fe ff ff       	jmp    800284 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ab:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ae:	8d 42 04             	lea    0x4(%edx),%eax
  8003b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8003b4:	8b 3a                	mov    (%edx),%edi
  8003b6:	85 ff                	test   %edi,%edi
  8003b8:	75 05                	jne    8003bf <vprintfmt+0x147>
				p = "(null)";
  8003ba:	bf 87 10 80 00       	mov    $0x801087,%edi
			if (width > 0 && padc != '-')
  8003bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003c3:	7e 3b                	jle    800400 <vprintfmt+0x188>
  8003c5:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8003c9:	74 35                	je     800400 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	56                   	push   %esi
  8003cf:	57                   	push   %edi
  8003d0:	e8 58 02 00 00       	call   80062d <strnlen>
  8003d5:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003df:	7e 1f                	jle    800400 <vprintfmt+0x188>
  8003e1:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	ff 75 0c             	pushl  0xc(%ebp)
  8003ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	ff 4d f0             	decl   -0x10(%ebp)
  8003fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003fe:	7f e8                	jg     8003e8 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800400:	0f be 0f             	movsbl (%edi),%ecx
  800403:	47                   	inc    %edi
  800404:	85 c9                	test   %ecx,%ecx
  800406:	74 44                	je     80044c <vprintfmt+0x1d4>
  800408:	85 f6                	test   %esi,%esi
  80040a:	78 03                	js     80040f <vprintfmt+0x197>
  80040c:	4e                   	dec    %esi
  80040d:	78 3d                	js     80044c <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  80040f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800413:	74 18                	je     80042d <vprintfmt+0x1b5>
  800415:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800418:	83 f8 5e             	cmp    $0x5e,%eax
  80041b:	76 10                	jbe    80042d <vprintfmt+0x1b5>
					putch('?', putdat);
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	ff 75 0c             	pushl  0xc(%ebp)
  800423:	6a 3f                	push   $0x3f
  800425:	ff 55 08             	call   *0x8(%ebp)
  800428:	83 c4 10             	add    $0x10,%esp
  80042b:	eb 0d                	jmp    80043a <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	ff 75 0c             	pushl  0xc(%ebp)
  800433:	51                   	push   %ecx
  800434:	ff 55 08             	call   *0x8(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043a:	ff 4d f0             	decl   -0x10(%ebp)
  80043d:	0f be 0f             	movsbl (%edi),%ecx
  800440:	47                   	inc    %edi
  800441:	85 c9                	test   %ecx,%ecx
  800443:	74 07                	je     80044c <vprintfmt+0x1d4>
  800445:	85 f6                	test   %esi,%esi
  800447:	78 c6                	js     80040f <vprintfmt+0x197>
  800449:	4e                   	dec    %esi
  80044a:	79 c3                	jns    80040f <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80044c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800450:	0f 8e 2e fe ff ff    	jle    800284 <vprintfmt+0xc>
				putch(' ', putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 0c             	pushl  0xc(%ebp)
  80045c:	6a 20                	push   $0x20
  80045e:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	ff 4d f0             	decl   -0x10(%ebp)
  800467:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80046b:	7f e9                	jg     800456 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  80046d:	e9 12 fe ff ff       	jmp    800284 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800472:	57                   	push   %edi
  800473:	8d 45 14             	lea    0x14(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	e8 c4 fd ff ff       	call   800240 <getint>
  80047c:	89 c6                	mov    %eax,%esi
  80047e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800480:	83 c4 08             	add    $0x8,%esp
  800483:	85 d2                	test   %edx,%edx
  800485:	79 15                	jns    80049c <vprintfmt+0x224>
				putch('-', putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 0c             	pushl  0xc(%ebp)
  80048d:	6a 2d                	push   $0x2d
  80048f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800492:	f7 de                	neg    %esi
  800494:	83 d7 00             	adc    $0x0,%edi
  800497:	f7 df                	neg    %edi
  800499:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80049c:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004a1:	eb 76                	jmp    800519 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004a3:	57                   	push   %edi
  8004a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a7:	50                   	push   %eax
  8004a8:	e8 53 fd ff ff       	call   800200 <getuint>
  8004ad:	89 c6                	mov    %eax,%esi
  8004af:	89 d7                	mov    %edx,%edi
			base = 10;
  8004b1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004b6:	83 c4 08             	add    $0x8,%esp
  8004b9:	eb 5e                	jmp    800519 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004bb:	57                   	push   %edi
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 3b fd ff ff       	call   800200 <getuint>
  8004c5:	89 c6                	mov    %eax,%esi
  8004c7:	89 d7                	mov    %edx,%edi
			base = 8;
  8004c9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004ce:	83 c4 08             	add    $0x8,%esp
  8004d1:	eb 46                	jmp    800519 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	6a 30                	push   $0x30
  8004db:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004de:	83 c4 08             	add    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	6a 78                	push   $0x78
  8004e6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8004e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ec:	8d 42 04             	lea    0x4(%edx),%eax
  8004ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f2:	8b 32                	mov    (%edx),%esi
  8004f4:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8004f9:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	eb 16                	jmp    800519 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800503:	57                   	push   %edi
  800504:	8d 45 14             	lea    0x14(%ebp),%eax
  800507:	50                   	push   %eax
  800508:	e8 f3 fc ff ff       	call   800200 <getuint>
  80050d:	89 c6                	mov    %eax,%esi
  80050f:	89 d7                	mov    %edx,%edi
			base = 16;
  800511:	ba 10 00 00 00       	mov    $0x10,%edx
  800516:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800519:	83 ec 04             	sub    $0x4,%esp
  80051c:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800520:	50                   	push   %eax
  800521:	ff 75 f0             	pushl  -0x10(%ebp)
  800524:	52                   	push   %edx
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 2e fc ff ff       	call   800160 <printnum>
			break;
  800532:	83 c4 20             	add    $0x20,%esp
  800535:	e9 4a fd ff ff       	jmp    800284 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	51                   	push   %ecx
  800541:	ff 55 08             	call   *0x8(%ebp)
			break;
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	e9 38 fd ff ff       	jmp    800284 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	6a 25                	push   $0x25
  800554:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800557:	4b                   	dec    %ebx
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80055f:	0f 84 1f fd ff ff    	je     800284 <vprintfmt+0xc>
  800565:	4b                   	dec    %ebx
  800566:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80056a:	75 f9                	jne    800565 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80056c:	e9 13 fd ff ff       	jmp    800284 <vprintfmt+0xc>
		}
	}
}
  800571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800574:	5b                   	pop    %ebx
  800575:	5e                   	pop    %esi
  800576:	5f                   	pop    %edi
  800577:	c9                   	leave  
  800578:	c3                   	ret    

00800579 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80057f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800582:	50                   	push   %eax
  800583:	ff 75 10             	pushl  0x10(%ebp)
  800586:	ff 75 0c             	pushl  0xc(%ebp)
  800589:	ff 75 08             	pushl  0x8(%ebp)
  80058c:	e8 e7 fc ff ff       	call   800278 <vprintfmt>
	va_end(ap);
}
  800591:	c9                   	leave  
  800592:	c3                   	ret    

00800593 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800599:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80059c:	8b 0a                	mov    (%edx),%ecx
  80059e:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005a1:	73 07                	jae    8005aa <sprintputch+0x17>
		*b->buf++ = ch;
  8005a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a6:	88 01                	mov    %al,(%ecx)
  8005a8:	ff 02                	incl   (%edx)
}
  8005aa:	c9                   	leave  
  8005ab:	c3                   	ret    

008005ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	83 ec 18             	sub    $0x18,%esp
  8005b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005b8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005bb:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8005bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	74 04                	je     8005d1 <vsnprintf+0x25>
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	7f 07                	jg     8005d8 <vsnprintf+0x2c>
		return -E_INVAL;
  8005d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005d6:	eb 1d                	jmp    8005f5 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005d8:	ff 75 14             	pushl  0x14(%ebp)
  8005db:	ff 75 10             	pushl  0x10(%ebp)
  8005de:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8005e1:	50                   	push   %eax
  8005e2:	68 93 05 80 00       	push   $0x800593
  8005e7:	e8 8c fc ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800600:	50                   	push   %eax
  800601:	ff 75 10             	pushl  0x10(%ebp)
  800604:	ff 75 0c             	pushl  0xc(%ebp)
  800607:	ff 75 08             	pushl  0x8(%ebp)
  80060a:	e8 9d ff ff ff       	call   8005ac <vsnprintf>
	va_end(ap);

	return rc;
}
  80060f:	c9                   	leave  
  800610:	c3                   	ret    
  800611:	00 00                	add    %al,(%eax)
	...

00800614 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80061a:	b8 00 00 00 00       	mov    $0x0,%eax
  80061f:	80 3a 00             	cmpb   $0x0,(%edx)
  800622:	74 07                	je     80062b <strlen+0x17>
		n++;
  800624:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800625:	42                   	inc    %edx
  800626:	80 3a 00             	cmpb   $0x0,(%edx)
  800629:	75 f9                	jne    800624 <strlen+0x10>
		n++;
	return n;
}
  80062b:	c9                   	leave  
  80062c:	c3                   	ret    

0080062d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800633:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 0f                	je     80064e <strnlen+0x21>
  80063f:	80 39 00             	cmpb   $0x0,(%ecx)
  800642:	74 0a                	je     80064e <strnlen+0x21>
		n++;
  800644:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800645:	41                   	inc    %ecx
  800646:	4a                   	dec    %edx
  800647:	74 05                	je     80064e <strnlen+0x21>
  800649:	80 39 00             	cmpb   $0x0,(%ecx)
  80064c:	75 f6                	jne    800644 <strnlen+0x17>
		n++;
	return n;
}
  80064e:	c9                   	leave  
  80064f:	c3                   	ret    

00800650 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	53                   	push   %ebx
  800654:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800657:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80065a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80065c:	8a 02                	mov    (%edx),%al
  80065e:	42                   	inc    %edx
  80065f:	88 01                	mov    %al,(%ecx)
  800661:	41                   	inc    %ecx
  800662:	84 c0                	test   %al,%al
  800664:	75 f6                	jne    80065c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800666:	89 d8                	mov    %ebx,%eax
  800668:	5b                   	pop    %ebx
  800669:	c9                   	leave  
  80066a:	c3                   	ret    

0080066b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
  80066e:	53                   	push   %ebx
  80066f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800672:	53                   	push   %ebx
  800673:	e8 9c ff ff ff       	call   800614 <strlen>
	strcpy(dst + len, src);
  800678:	ff 75 0c             	pushl  0xc(%ebp)
  80067b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80067e:	50                   	push   %eax
  80067f:	e8 cc ff ff ff       	call   800650 <strcpy>
	return dst;
}
  800684:	89 d8                	mov    %ebx,%eax
  800686:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800689:	c9                   	leave  
  80068a:	c3                   	ret    

0080068b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	57                   	push   %edi
  80068f:	56                   	push   %esi
  800690:	53                   	push   %ebx
  800691:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
  800697:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80069a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80069c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a1:	39 f3                	cmp    %esi,%ebx
  8006a3:	73 10                	jae    8006b5 <strncpy+0x2a>
		*dst++ = *src;
  8006a5:	8a 02                	mov    (%edx),%al
  8006a7:	88 01                	mov    %al,(%ecx)
  8006a9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006aa:	80 3a 01             	cmpb   $0x1,(%edx)
  8006ad:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006b0:	43                   	inc    %ebx
  8006b1:	39 f3                	cmp    %esi,%ebx
  8006b3:	72 f0                	jb     8006a5 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006b5:	89 f8                	mov    %edi,%eax
  8006b7:	5b                   	pop    %ebx
  8006b8:	5e                   	pop    %esi
  8006b9:	5f                   	pop    %edi
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	56                   	push   %esi
  8006c0:	53                   	push   %ebx
  8006c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006ca:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	74 19                	je     8006e9 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006d0:	4a                   	dec    %edx
  8006d1:	74 13                	je     8006e6 <strlcpy+0x2a>
  8006d3:	80 39 00             	cmpb   $0x0,(%ecx)
  8006d6:	74 0e                	je     8006e6 <strlcpy+0x2a>
  8006d8:	8a 01                	mov    (%ecx),%al
  8006da:	41                   	inc    %ecx
  8006db:	88 03                	mov    %al,(%ebx)
  8006dd:	43                   	inc    %ebx
  8006de:	4a                   	dec    %edx
  8006df:	74 05                	je     8006e6 <strlcpy+0x2a>
  8006e1:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e4:	75 f2                	jne    8006d8 <strlcpy+0x1c>
		*dst = '\0';
  8006e6:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8006e9:	89 d8                	mov    %ebx,%eax
  8006eb:	29 f0                	sub    %esi,%eax
}
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8006fa:	80 3a 00             	cmpb   $0x0,(%edx)
  8006fd:	74 13                	je     800712 <strcmp+0x21>
  8006ff:	8a 02                	mov    (%edx),%al
  800701:	3a 01                	cmp    (%ecx),%al
  800703:	75 0d                	jne    800712 <strcmp+0x21>
  800705:	42                   	inc    %edx
  800706:	41                   	inc    %ecx
  800707:	80 3a 00             	cmpb   $0x0,(%edx)
  80070a:	74 06                	je     800712 <strcmp+0x21>
  80070c:	8a 02                	mov    (%edx),%al
  80070e:	3a 01                	cmp    (%ecx),%al
  800710:	74 f3                	je     800705 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800712:	0f b6 02             	movzbl (%edx),%eax
  800715:	0f b6 11             	movzbl (%ecx),%edx
  800718:	29 d0                	sub    %edx,%eax
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
  800723:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800726:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800729:	85 c9                	test   %ecx,%ecx
  80072b:	74 1f                	je     80074c <strncmp+0x30>
  80072d:	80 3a 00             	cmpb   $0x0,(%edx)
  800730:	74 16                	je     800748 <strncmp+0x2c>
  800732:	8a 02                	mov    (%edx),%al
  800734:	3a 03                	cmp    (%ebx),%al
  800736:	75 10                	jne    800748 <strncmp+0x2c>
  800738:	42                   	inc    %edx
  800739:	43                   	inc    %ebx
  80073a:	49                   	dec    %ecx
  80073b:	74 0f                	je     80074c <strncmp+0x30>
  80073d:	80 3a 00             	cmpb   $0x0,(%edx)
  800740:	74 06                	je     800748 <strncmp+0x2c>
  800742:	8a 02                	mov    (%edx),%al
  800744:	3a 03                	cmp    (%ebx),%al
  800746:	74 f0                	je     800738 <strncmp+0x1c>
	if (n == 0)
  800748:	85 c9                	test   %ecx,%ecx
  80074a:	75 07                	jne    800753 <strncmp+0x37>
		return 0;
  80074c:	b8 00 00 00 00       	mov    $0x0,%eax
  800751:	eb 0a                	jmp    80075d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800753:	0f b6 12             	movzbl (%edx),%edx
  800756:	0f b6 03             	movzbl (%ebx),%eax
  800759:	29 c2                	sub    %eax,%edx
  80075b:	89 d0                	mov    %edx,%eax
}
  80075d:	5b                   	pop    %ebx
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800769:	80 38 00             	cmpb   $0x0,(%eax)
  80076c:	74 0a                	je     800778 <strchr+0x18>
		if (*s == c)
  80076e:	38 10                	cmp    %dl,(%eax)
  800770:	74 0b                	je     80077d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800772:	40                   	inc    %eax
  800773:	80 38 00             	cmpb   $0x0,(%eax)
  800776:	75 f6                	jne    80076e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800788:	80 38 00             	cmpb   $0x0,(%eax)
  80078b:	74 0a                	je     800797 <strfind+0x18>
		if (*s == c)
  80078d:	38 10                	cmp    %dl,(%eax)
  80078f:	74 06                	je     800797 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800791:	40                   	inc    %eax
  800792:	80 38 00             	cmpb   $0x0,(%eax)
  800795:	75 f6                	jne    80078d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	57                   	push   %edi
  80079d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8007a3:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	74 40                	je     8007e9 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007af:	75 30                	jne    8007e1 <memset+0x48>
  8007b1:	f6 c1 03             	test   $0x3,%cl
  8007b4:	75 2b                	jne    8007e1 <memset+0x48>
		c &= 0xFF;
  8007b6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	c1 e0 18             	shl    $0x18,%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	c1 e2 10             	shl    $0x10,%edx
  8007c9:	09 d0                	or     %edx,%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	c1 e2 08             	shl    $0x8,%edx
  8007d1:	09 d0                	or     %edx,%eax
  8007d3:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8007d6:	c1 e9 02             	shr    $0x2,%ecx
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	fc                   	cld    
  8007dd:	f3 ab                	rep stos %eax,%es:(%edi)
  8007df:	eb 06                	jmp    8007e7 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e4:	fc                   	cld    
  8007e5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8007e7:	89 f8                	mov    %edi,%eax
}
  8007e9:	5f                   	pop    %edi
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	57                   	push   %edi
  8007f0:	56                   	push   %esi
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8007f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007fa:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007fc:	39 c6                	cmp    %eax,%esi
  8007fe:	73 34                	jae    800834 <memmove+0x48>
  800800:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800803:	39 c2                	cmp    %eax,%edx
  800805:	76 2d                	jbe    800834 <memmove+0x48>
		s += n;
  800807:	89 d6                	mov    %edx,%esi
		d += n;
  800809:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80080c:	f6 c2 03             	test   $0x3,%dl
  80080f:	75 1b                	jne    80082c <memmove+0x40>
  800811:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800817:	75 13                	jne    80082c <memmove+0x40>
  800819:	f6 c1 03             	test   $0x3,%cl
  80081c:	75 0e                	jne    80082c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80081e:	83 ef 04             	sub    $0x4,%edi
  800821:	83 ee 04             	sub    $0x4,%esi
  800824:	c1 e9 02             	shr    $0x2,%ecx
  800827:	fd                   	std    
  800828:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80082a:	eb 05                	jmp    800831 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80082c:	4f                   	dec    %edi
  80082d:	4e                   	dec    %esi
  80082e:	fd                   	std    
  80082f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800831:	fc                   	cld    
  800832:	eb 20                	jmp    800854 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800834:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80083a:	75 15                	jne    800851 <memmove+0x65>
  80083c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800842:	75 0d                	jne    800851 <memmove+0x65>
  800844:	f6 c1 03             	test   $0x3,%cl
  800847:	75 08                	jne    800851 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800849:	c1 e9 02             	shr    $0x2,%ecx
  80084c:	fc                   	cld    
  80084d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80084f:	eb 03                	jmp    800854 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800851:	fc                   	cld    
  800852:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800854:	5e                   	pop    %esi
  800855:	5f                   	pop    %edi
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80085b:	ff 75 10             	pushl  0x10(%ebp)
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	ff 75 08             	pushl  0x8(%ebp)
  800864:	e8 83 ff ff ff       	call   8007ec <memmove>
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80086f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800872:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800875:	8b 55 10             	mov    0x10(%ebp),%edx
  800878:	4a                   	dec    %edx
  800879:	83 fa ff             	cmp    $0xffffffff,%edx
  80087c:	74 1a                	je     800898 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80087e:	8a 01                	mov    (%ecx),%al
  800880:	3a 03                	cmp    (%ebx),%al
  800882:	74 0c                	je     800890 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800884:	0f b6 d0             	movzbl %al,%edx
  800887:	0f b6 03             	movzbl (%ebx),%eax
  80088a:	29 c2                	sub    %eax,%edx
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	eb 0d                	jmp    80089d <memcmp+0x32>
		s1++, s2++;
  800890:	41                   	inc    %ecx
  800891:	43                   	inc    %ebx
  800892:	4a                   	dec    %edx
  800893:	83 fa ff             	cmp    $0xffffffff,%edx
  800896:	75 e6                	jne    80087e <memcmp+0x13>
	}

	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	5b                   	pop    %ebx
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008ae:	39 d0                	cmp    %edx,%eax
  8008b0:	73 09                	jae    8008bb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008b2:	38 08                	cmp    %cl,(%eax)
  8008b4:	74 05                	je     8008bb <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008b6:	40                   	inc    %eax
  8008b7:	39 d0                	cmp    %edx,%eax
  8008b9:	72 f7                	jb     8008b2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8008cc:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8008d1:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008d6:	80 3a 20             	cmpb   $0x20,(%edx)
  8008d9:	74 05                	je     8008e0 <strtol+0x23>
  8008db:	80 3a 09             	cmpb   $0x9,(%edx)
  8008de:	75 0b                	jne    8008eb <strtol+0x2e>
  8008e0:	42                   	inc    %edx
  8008e1:	80 3a 20             	cmpb   $0x20,(%edx)
  8008e4:	74 fa                	je     8008e0 <strtol+0x23>
  8008e6:	80 3a 09             	cmpb   $0x9,(%edx)
  8008e9:	74 f5                	je     8008e0 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8008eb:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8008ee:	75 03                	jne    8008f3 <strtol+0x36>
		s++;
  8008f0:	42                   	inc    %edx
  8008f1:	eb 0b                	jmp    8008fe <strtol+0x41>
	else if (*s == '-')
  8008f3:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8008f6:	75 06                	jne    8008fe <strtol+0x41>
		s++, neg = 1;
  8008f8:	42                   	inc    %edx
  8008f9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008fe:	85 c9                	test   %ecx,%ecx
  800900:	74 05                	je     800907 <strtol+0x4a>
  800902:	83 f9 10             	cmp    $0x10,%ecx
  800905:	75 15                	jne    80091c <strtol+0x5f>
  800907:	80 3a 30             	cmpb   $0x30,(%edx)
  80090a:	75 10                	jne    80091c <strtol+0x5f>
  80090c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800910:	75 0a                	jne    80091c <strtol+0x5f>
		s += 2, base = 16;
  800912:	83 c2 02             	add    $0x2,%edx
  800915:	b9 10 00 00 00       	mov    $0x10,%ecx
  80091a:	eb 14                	jmp    800930 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	75 10                	jne    800930 <strtol+0x73>
  800920:	80 3a 30             	cmpb   $0x30,(%edx)
  800923:	75 05                	jne    80092a <strtol+0x6d>
		s++, base = 8;
  800925:	42                   	inc    %edx
  800926:	b1 08                	mov    $0x8,%cl
  800928:	eb 06                	jmp    800930 <strtol+0x73>
	else if (base == 0)
  80092a:	85 c9                	test   %ecx,%ecx
  80092c:	75 02                	jne    800930 <strtol+0x73>
		base = 10;
  80092e:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800930:	8a 02                	mov    (%edx),%al
  800932:	83 e8 30             	sub    $0x30,%eax
  800935:	3c 09                	cmp    $0x9,%al
  800937:	77 08                	ja     800941 <strtol+0x84>
			dig = *s - '0';
  800939:	0f be 02             	movsbl (%edx),%eax
  80093c:	83 e8 30             	sub    $0x30,%eax
  80093f:	eb 20                	jmp    800961 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800941:	8a 02                	mov    (%edx),%al
  800943:	83 e8 61             	sub    $0x61,%eax
  800946:	3c 19                	cmp    $0x19,%al
  800948:	77 08                	ja     800952 <strtol+0x95>
			dig = *s - 'a' + 10;
  80094a:	0f be 02             	movsbl (%edx),%eax
  80094d:	83 e8 57             	sub    $0x57,%eax
  800950:	eb 0f                	jmp    800961 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800952:	8a 02                	mov    (%edx),%al
  800954:	83 e8 41             	sub    $0x41,%eax
  800957:	3c 19                	cmp    $0x19,%al
  800959:	77 12                	ja     80096d <strtol+0xb0>
			dig = *s - 'A' + 10;
  80095b:	0f be 02             	movsbl (%edx),%eax
  80095e:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800961:	39 c8                	cmp    %ecx,%eax
  800963:	7d 08                	jge    80096d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800965:	42                   	inc    %edx
  800966:	0f af d9             	imul   %ecx,%ebx
  800969:	01 c3                	add    %eax,%ebx
  80096b:	eb c3                	jmp    800930 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  80096d:	85 f6                	test   %esi,%esi
  80096f:	74 02                	je     800973 <strtol+0xb6>
		*endptr = (char *) s;
  800971:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800973:	89 d8                	mov    %ebx,%eax
  800975:	85 ff                	test   %edi,%edi
  800977:	74 02                	je     80097b <strtol+0xbe>
  800979:	f7 d8                	neg    %eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	83 ec 04             	sub    $0x4,%esp
  800989:	8b 55 08             	mov    0x8(%ebp),%edx
  80098c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80098f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800994:	89 f8                	mov    %edi,%eax
  800996:	89 fb                	mov    %edi,%ebx
  800998:	89 fe                	mov    %edi,%esi
  80099a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80099c:	83 c4 04             	add    $0x4,%esp
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	57                   	push   %edi
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8009af:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009b4:	89 fa                	mov    %edi,%edx
  8009b6:	89 f9                	mov    %edi,%ecx
  8009b8:	89 fb                	mov    %edi,%ebx
  8009ba:	89 fe                	mov    %edi,%esi
  8009bc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8009d4:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009d9:	89 f9                	mov    %edi,%ecx
  8009db:	89 fb                	mov    %edi,%ebx
  8009dd:	89 fe                	mov    %edi,%esi
  8009df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8009e1:	85 c0                	test   %eax,%eax
  8009e3:	7e 17                	jle    8009fc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009e5:	83 ec 0c             	sub    $0xc,%esp
  8009e8:	50                   	push   %eax
  8009e9:	6a 03                	push   $0x3
  8009eb:	68 58 12 80 00       	push   $0x801258
  8009f0:	6a 23                	push   $0x23
  8009f2:	68 75 12 80 00       	push   $0x801275
  8009f7:	e8 38 02 00 00       	call   800c34 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8009fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a14:	89 fa                	mov    %edi,%edx
  800a16:	89 f9                	mov    %edi,%ecx
  800a18:	89 fb                	mov    %edi,%ebx
  800a1a:	89 fe                	mov    %edi,%esi
  800a1c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <sys_yield>:

void
sys_yield(void)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a2e:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a33:	89 fa                	mov    %edi,%edx
  800a35:	89 f9                	mov    %edi,%ecx
  800a37:	89 fb                	mov    %edi,%ebx
  800a39:	89 fe                	mov    %edi,%esi
  800a3b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	83 ec 0c             	sub    $0xc,%esp
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a54:	b8 04 00 00 00       	mov    $0x4,%eax
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5e:	89 fe                	mov    %edi,%esi
  800a60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a62:	85 c0                	test   %eax,%eax
  800a64:	7e 17                	jle    800a7d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a66:	83 ec 0c             	sub    $0xc,%esp
  800a69:	50                   	push   %eax
  800a6a:	6a 04                	push   $0x4
  800a6c:	68 58 12 80 00       	push   $0x801258
  800a71:	6a 23                	push   $0x23
  800a73:	68 75 12 80 00       	push   $0x801275
  800a78:	e8 b7 01 00 00       	call   800c34 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800a9a:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a9d:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	7e 17                	jle    800abf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa8:	83 ec 0c             	sub    $0xc,%esp
  800aab:	50                   	push   %eax
  800aac:	6a 05                	push   $0x5
  800aae:	68 58 12 80 00       	push   $0x801258
  800ab3:	6a 23                	push   $0x23
  800ab5:	68 75 12 80 00       	push   $0x801275
  800aba:	e8 75 01 00 00       	call   800c34 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800abf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	83 ec 0c             	sub    $0xc,%esp
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad6:	b8 06 00 00 00       	mov    $0x6,%eax
  800adb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	89 fb                	mov    %edi,%ebx
  800ae2:	89 fe                	mov    %edi,%esi
  800ae4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	7e 17                	jle    800b01 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	50                   	push   %eax
  800aee:	6a 06                	push   $0x6
  800af0:	68 58 12 80 00       	push   $0x801258
  800af5:	6a 23                	push   $0x23
  800af7:	68 75 12 80 00       	push   $0x801275
  800afc:	e8 33 01 00 00       	call   800c34 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b18:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	89 fb                	mov    %edi,%ebx
  800b24:	89 fe                	mov    %edi,%esi
  800b26:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	7e 17                	jle    800b43 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2c:	83 ec 0c             	sub    $0xc,%esp
  800b2f:	50                   	push   %eax
  800b30:	6a 08                	push   $0x8
  800b32:	68 58 12 80 00       	push   $0x801258
  800b37:	6a 23                	push   $0x23
  800b39:	68 75 12 80 00       	push   $0x801275
  800b3e:	e8 f1 00 00 00       	call   800c34 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	89 fb                	mov    %edi,%ebx
  800b66:	89 fe                	mov    %edi,%esi
  800b68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	7e 17                	jle    800b85 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	50                   	push   %eax
  800b72:	6a 09                	push   $0x9
  800b74:	68 58 12 80 00       	push   $0x801258
  800b79:	6a 23                	push   $0x23
  800b7b:	68 75 12 80 00       	push   $0x801275
  800b80:	e8 af 00 00 00       	call   800c34 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	89 fb                	mov    %edi,%ebx
  800ba8:	89 fe                	mov    %edi,%esi
  800baa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bac:	85 c0                	test   %eax,%eax
  800bae:	7e 17                	jle    800bc7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	50                   	push   %eax
  800bb4:	6a 0a                	push   $0xa
  800bb6:	68 58 12 80 00       	push   $0x801258
  800bbb:	6a 23                	push   $0x23
  800bbd:	68 75 12 80 00       	push   $0x801275
  800bc2:	e8 6d 00 00 00       	call   800c34 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800be1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800be6:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bfe:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	89 f9                	mov    %edi,%ecx
  800c0a:	89 fb                	mov    %edi,%ebx
  800c0c:	89 fe                	mov    %edi,%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 0d                	push   $0xd
  800c1a:	68 58 12 80 00       	push   $0x801258
  800c1f:	6a 23                	push   $0x23
  800c21:	68 75 12 80 00       	push   $0x801275
  800c26:	e8 09 00 00 00       	call   800c34 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    
	...

00800c34 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	53                   	push   %ebx
  800c38:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800c3b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c3e:	ff 75 0c             	pushl  0xc(%ebp)
  800c41:	ff 75 08             	pushl  0x8(%ebp)
  800c44:	ff 35 00 20 80 00    	pushl  0x802000
  800c4a:	83 ec 08             	sub    $0x8,%esp
  800c4d:	e8 b2 fd ff ff       	call   800a04 <sys_getenvid>
  800c52:	83 c4 08             	add    $0x8,%esp
  800c55:	50                   	push   %eax
  800c56:	68 84 12 80 00       	push   $0x801284
  800c5b:	e8 ec f4 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c60:	83 c4 18             	add    $0x18,%esp
  800c63:	53                   	push   %ebx
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	e8 8f f4 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800c6c:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  800c73:	e8 d4 f4 ff ff       	call   80014c <cprintf>

	// Cause a breakpoint exception
	while (1)
  800c78:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800c7b:	cc                   	int3   
  800c7c:	eb fd                	jmp    800c7b <_panic+0x47>
	...

00800c80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	83 ec 14             	sub    $0x14,%esp
  800c88:	8b 55 14             	mov    0x14(%ebp),%edx
  800c8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c91:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c94:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c96:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800c9c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800c9f:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ca1:	75 11                	jne    800cb4 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800ca3:	39 f8                	cmp    %edi,%eax
  800ca5:	76 4d                	jbe    800cf4 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ca7:	89 fa                	mov    %edi,%edx
  800ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cac:	f7 75 e4             	divl   -0x1c(%ebp)
  800caf:	89 c7                	mov    %eax,%edi
  800cb1:	eb 09                	jmp    800cbc <__udivdi3+0x3c>
  800cb3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cb4:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800cb7:	76 17                	jbe    800cd0 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800cb9:	31 ff                	xor    %edi,%edi
  800cbb:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800cbc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cc3:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cc6:	83 c4 14             	add    $0x14,%esp
  800cc9:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cca:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ccc:	5f                   	pop    %edi
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    
  800ccf:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cd0:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800cd4:	89 c7                	mov    %eax,%edi
  800cd6:	83 f7 1f             	xor    $0x1f,%edi
  800cd9:	75 4d                	jne    800d28 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cdb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800cde:	77 0a                	ja     800cea <__udivdi3+0x6a>
  800ce0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800ce3:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce5:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800ce8:	72 d2                	jb     800cbc <__udivdi3+0x3c>
		{
		  q0 = 1;
  800cea:	bf 01 00 00 00       	mov    $0x1,%edi
  800cef:	eb cb                	jmp    800cbc <__udivdi3+0x3c>
  800cf1:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	75 0e                	jne    800d09 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800d00:	31 c9                	xor    %ecx,%ecx
  800d02:	31 d2                	xor    %edx,%edx
  800d04:	f7 f1                	div    %ecx
  800d06:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d09:	89 f0                	mov    %esi,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	f7 75 e4             	divl   -0x1c(%ebp)
  800d10:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d16:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d19:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d1c:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d1f:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d21:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d22:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d24:	5f                   	pop    %edi
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    
  800d27:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d28:	b8 20 00 00 00       	mov    $0x20,%eax
  800d2d:	29 f8                	sub    %edi,%eax
  800d2f:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d32:	89 f9                	mov    %edi,%ecx
  800d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d37:	d3 e2                	shl    %cl,%edx
  800d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d3c:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d3f:	d3 e8                	shr    %cl,%eax
  800d41:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d43:	89 f9                	mov    %edi,%ecx
  800d45:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d48:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d4b:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d4e:	89 f2                	mov    %esi,%edx
  800d50:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d52:	89 f9                	mov    %edi,%ecx
  800d54:	d3 e6                	shl    %cl,%esi
  800d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d59:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d5c:	d3 e8                	shr    %cl,%eax
  800d5e:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d60:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d62:	89 f0                	mov    %esi,%eax
  800d64:	f7 75 f4             	divl   -0xc(%ebp)
  800d67:	89 d6                	mov    %edx,%esi
  800d69:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d6b:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d71:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d73:	39 f2                	cmp    %esi,%edx
  800d75:	77 0f                	ja     800d86 <__udivdi3+0x106>
  800d77:	0f 85 3f ff ff ff    	jne    800cbc <__udivdi3+0x3c>
  800d7d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800d80:	0f 86 36 ff ff ff    	jbe    800cbc <__udivdi3+0x3c>
		{
		  q0--;
  800d86:	4f                   	dec    %edi
  800d87:	e9 30 ff ff ff       	jmp    800cbc <__udivdi3+0x3c>

00800d8c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	83 ec 30             	sub    $0x30,%esp
  800d94:	8b 55 14             	mov    0x14(%ebp),%edx
  800d97:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800d9a:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800d9c:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d9f:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da7:	85 ff                	test   %edi,%edi
  800da9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800db0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800db7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dba:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800dbd:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dc0:	75 3e                	jne    800e00 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800dc2:	39 d6                	cmp    %edx,%esi
  800dc4:	0f 86 a2 00 00 00    	jbe    800e6c <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dca:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dcc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dcf:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd1:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800dd4:	74 1b                	je     800df1 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800dd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800ddc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800de3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800de6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800de9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dec:	89 10                	mov    %edx,(%eax)
  800dee:	89 48 04             	mov    %ecx,0x4(%eax)
  800df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800df7:	83 c4 30             	add    $0x30,%esp
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    
  800dfe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e00:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800e03:	76 1f                	jbe    800e24 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800e08:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e0b:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800e0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800e11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e1a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e1d:	83 c4 30             	add    $0x30,%esp
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e24:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e27:	83 f0 1f             	xor    $0x1f,%eax
  800e2a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e2d:	75 61                	jne    800e90 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e2f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e32:	77 05                	ja     800e39 <__umoddi3+0xad>
  800e34:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e37:	72 10                	jb     800e49 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e39:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e3f:	29 f0                	sub    %esi,%eax
  800e41:	19 fa                	sbb    %edi,%edx
  800e43:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e46:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e49:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e4c:	85 d2                	test   %edx,%edx
  800e4e:	74 a1                	je     800df1 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e50:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e53:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e56:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e5c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e65:	89 01                	mov    %eax,(%ecx)
  800e67:	89 51 04             	mov    %edx,0x4(%ecx)
  800e6a:	eb 85                	jmp    800df1 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e6c:	85 f6                	test   %esi,%esi
  800e6e:	75 0b                	jne    800e7b <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e70:	b8 01 00 00 00       	mov    $0x1,%eax
  800e75:	31 d2                	xor    %edx,%edx
  800e77:	f7 f6                	div    %esi
  800e79:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e7b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e82:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e85:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e88:	f7 f6                	div    %esi
  800e8a:	e9 3d ff ff ff       	jmp    800dcc <__umoddi3+0x40>
  800e8f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e90:	b8 20 00 00 00       	mov    $0x20,%eax
  800e95:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800e98:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e9b:	89 fa                	mov    %edi,%edx
  800e9d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ea0:	d3 e2                	shl    %cl,%edx
  800ea2:	89 f0                	mov    %esi,%eax
  800ea4:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ea7:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800ea9:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800eac:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eae:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800eb0:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eb3:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eb6:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800eb8:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800eba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ebd:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ec0:	d3 e0                	shl    %cl,%eax
  800ec2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800ec5:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800ec8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	0b 45 cc             	or     -0x34(%ebp),%eax
  800ed0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800ed3:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ed6:	f7 f7                	div    %edi
  800ed8:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800edb:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ede:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ee3:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee6:	77 0a                	ja     800ef2 <__umoddi3+0x166>
  800ee8:	75 12                	jne    800efc <__umoddi3+0x170>
  800eea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eed:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800ef0:	76 0a                	jbe    800efc <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800ef5:	29 f1                	sub    %esi,%ecx
  800ef7:	19 fa                	sbb    %edi,%edx
  800ef9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eff:	85 c0                	test   %eax,%eax
  800f01:	0f 84 ea fe ff ff    	je     800df1 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f07:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f0d:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800f10:	19 d1                	sbb    %edx,%ecx
  800f12:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f15:	89 ca                	mov    %ecx,%edx
  800f17:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f1a:	d3 e2                	shl    %cl,%edx
  800f1c:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f22:	d3 e8                	shr    %cl,%eax
  800f24:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f26:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f29:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f2b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f31:	e9 ad fe ff ff       	jmp    800de3 <__umoddi3+0x57>
