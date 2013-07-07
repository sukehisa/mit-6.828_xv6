
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 67 00 00 00       	call   800098 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 80 0f 80 00       	push   $0x800f80
  800049:	e8 36 01 00 00       	call   800184 <cprintf>
	for (i = 0; i < 5; i++) {
  80004e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800053:	83 c4 10             	add    $0x10,%esp
		sys_yield();
  800056:	e8 00 0a 00 00       	call   800a5b <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	53                   	push   %ebx
  80005f:	a1 04 20 80 00       	mov    0x802004,%eax
  800064:	8b 40 48             	mov    0x48(%eax),%eax
  800067:	50                   	push   %eax
  800068:	68 a0 0f 80 00       	push   $0x800fa0
  80006d:	e8 12 01 00 00       	call   800184 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	43                   	inc    %ebx
  800076:	83 fb 04             	cmp    $0x4,%ebx
  800079:	7e db                	jle    800056 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	a1 04 20 80 00       	mov    0x802004,%eax
  800083:	8b 40 48             	mov    0x48(%eax),%eax
  800086:	50                   	push   %eax
  800087:	68 cc 0f 80 00       	push   $0x800fcc
  80008c:	e8 f3 00 00 00       	call   800184 <cprintf>
}
  800091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000a3:	e8 94 09 00 00       	call   800a3c <sys_getenvid>
  8000a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ad:	89 c2                	mov    %eax,%edx
  8000af:	c1 e2 05             	shl    $0x5,%edx
  8000b2:	29 c2                	sub    %eax,%edx
  8000b4:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000bb:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c1:	85 f6                	test   %esi,%esi
  8000c3:	7e 07                	jle    8000cc <libmain+0x34>
		binaryname = argv[0];
  8000c5:	8b 03                	mov    (%ebx),%eax
  8000c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	56                   	push   %esi
  8000d1:	e8 5e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d6:	e8 09 00 00 00       	call   8000e4 <exit>
}
  8000db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000ea:	6a 00                	push   $0x0
  8000ec:	e8 0a 09 00 00       	call   8009fb <sys_env_destroy>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    
	...

008000f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 04             	sub    $0x4,%esp
  8000fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fe:	8b 03                	mov    (%ebx),%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  800107:	40                   	inc    %eax
  800108:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 96 08 00 00       	call   8009b8 <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	ff 43 04             	incl   0x4(%ebx)
}
  80012e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013c:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  800143:	00 00 00 
	b.cnt = 0;
  800146:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80014d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800150:	ff 75 0c             	pushl  0xc(%ebp)
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80015c:	50                   	push   %eax
  80015d:	68 f4 00 80 00       	push   $0x8000f4
  800162:	e8 49 01 00 00       	call   8002b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800167:	83 c4 08             	add    $0x8,%esp
  80016a:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800170:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800176:	50                   	push   %eax
  800177:	e8 3c 08 00 00       	call   8009b8 <sys_cputs>

	return b.cnt;
  80017c:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018d:	50                   	push   %eax
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	e8 9d ff ff ff       	call   800133 <vcprintf>
	va_end(ap);

	return cnt;
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	8b 75 10             	mov    0x10(%ebp),%esi
  8001a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a7:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001aa:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b2:	39 fa                	cmp    %edi,%edx
  8001b4:	77 39                	ja     8001ef <printnum+0x57>
  8001b6:	72 04                	jb     8001bc <printnum+0x24>
  8001b8:	39 f0                	cmp    %esi,%eax
  8001ba:	77 33                	ja     8001ef <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	ff 75 20             	pushl  0x20(%ebp)
  8001c2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001c5:	50                   	push   %eax
  8001c6:	ff 75 18             	pushl  0x18(%ebp)
  8001c9:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d1:	52                   	push   %edx
  8001d2:	50                   	push   %eax
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	e8 de 0a 00 00       	call   800cb8 <__udivdi3>
  8001da:	83 c4 10             	add    $0x10,%esp
  8001dd:	52                   	push   %edx
  8001de:	50                   	push   %eax
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 ae ff ff ff       	call   800198 <printnum>
  8001ea:	83 c4 20             	add    $0x20,%esp
  8001ed:	eb 19                	jmp    800208 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ef:	4b                   	dec    %ebx
  8001f0:	85 db                	test   %ebx,%ebx
  8001f2:	7e 14                	jle    800208 <printnum+0x70>
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 0c             	pushl  0xc(%ebp)
  8001fa:	ff 75 20             	pushl  0x20(%ebp)
  8001fd:	ff 55 08             	call   *0x8(%ebp)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f ec                	jg     8001f4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	8b 45 18             	mov    0x18(%ebp),%eax
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	83 ec 04             	sub    $0x4,%esp
  800219:	52                   	push   %edx
  80021a:	50                   	push   %eax
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	e8 a2 0b 00 00       	call   800dc4 <__umoddi3>
  800222:	83 c4 14             	add    $0x14,%esp
  800225:	0f be 80 07 11 80 00 	movsbl 0x801107(%eax),%eax
  80022c:	50                   	push   %eax
  80022d:	ff 55 08             	call   *0x8(%ebp)
}
  800230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800241:	83 f8 01             	cmp    $0x1,%eax
  800244:	7e 0e                	jle    800254 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800246:	8b 11                	mov    (%ecx),%edx
  800248:	8d 42 08             	lea    0x8(%edx),%eax
  80024b:	89 01                	mov    %eax,(%ecx)
  80024d:	8b 02                	mov    (%edx),%eax
  80024f:	8b 52 04             	mov    0x4(%edx),%edx
  800252:	eb 22                	jmp    800276 <getuint+0x3e>
	else if (lflag)
  800254:	85 c0                	test   %eax,%eax
  800256:	74 10                	je     800268 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800258:	8b 11                	mov    (%ecx),%edx
  80025a:	8d 42 04             	lea    0x4(%edx),%eax
  80025d:	89 01                	mov    %eax,(%ecx)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
  800266:	eb 0e                	jmp    800276 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800268:	8b 11                	mov    (%ecx),%edx
  80026a:	8d 42 04             	lea    0x4(%edx),%eax
  80026d:	89 01                	mov    %eax,(%ecx)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800281:	83 f8 01             	cmp    $0x1,%eax
  800284:	7e 0e                	jle    800294 <getint+0x1c>
		return va_arg(*ap, long long);
  800286:	8b 11                	mov    (%ecx),%edx
  800288:	8d 42 08             	lea    0x8(%edx),%eax
  80028b:	89 01                	mov    %eax,(%ecx)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 1a                	jmp    8002ae <getint+0x36>
	else if (lflag)
  800294:	85 c0                	test   %eax,%eax
  800296:	74 0c                	je     8002a4 <getint+0x2c>
		return va_arg(*ap, long);
  800298:	8b 01                	mov    (%ecx),%eax
  80029a:	8d 50 04             	lea    0x4(%eax),%edx
  80029d:	89 11                	mov    %edx,(%ecx)
  80029f:	8b 00                	mov    (%eax),%eax
  8002a1:	99                   	cltd   
  8002a2:	eb 0a                	jmp    8002ae <getint+0x36>
	else
		return va_arg(*ap, int);
  8002a4:	8b 01                	mov    (%ecx),%eax
  8002a6:	8d 50 04             	lea    0x4(%eax),%edx
  8002a9:	89 11                	mov    %edx,(%ecx)
  8002ab:	8b 00                	mov    (%eax),%eax
  8002ad:	99                   	cltd   
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 1c             	sub    $0x1c,%esp
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8002bc:	0f b6 0b             	movzbl (%ebx),%ecx
  8002bf:	43                   	inc    %ebx
  8002c0:	83 f9 25             	cmp    $0x25,%ecx
  8002c3:	74 1e                	je     8002e3 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c5:	85 c9                	test   %ecx,%ecx
  8002c7:	0f 84 dc 02 00 00    	je     8005a9 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	51                   	push   %ecx
  8002d4:	ff 55 08             	call   *0x8(%ebp)
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	0f b6 0b             	movzbl (%ebx),%ecx
  8002dd:	43                   	inc    %ebx
  8002de:	83 f9 25             	cmp    $0x25,%ecx
  8002e1:	75 e2                	jne    8002c5 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002e3:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8002e7:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8002ee:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002f3:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8002f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	0f b6 0b             	movzbl (%ebx),%ecx
  800302:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800305:	43                   	inc    %ebx
  800306:	83 f8 55             	cmp    $0x55,%eax
  800309:	0f 87 75 02 00 00    	ja     800584 <vprintfmt+0x2d4>
  80030f:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800316:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  80031a:	eb e3                	jmp    8002ff <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800320:	eb dd                	jmp    8002ff <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800322:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800327:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80032a:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  80032e:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800331:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800334:	83 f8 09             	cmp    $0x9,%eax
  800337:	77 28                	ja     800361 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800339:	43                   	inc    %ebx
  80033a:	eb eb                	jmp    800327 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80033c:	8b 55 14             	mov    0x14(%ebp),%edx
  80033f:	8d 42 04             	lea    0x4(%edx),%eax
  800342:	89 45 14             	mov    %eax,0x14(%ebp)
  800345:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800347:	eb 18                	jmp    800361 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800349:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80034d:	79 b0                	jns    8002ff <vprintfmt+0x4f>
				width = 0;
  80034f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800356:	eb a7                	jmp    8002ff <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800358:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80035f:	eb 9e                	jmp    8002ff <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800361:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800365:	79 98                	jns    8002ff <vprintfmt+0x4f>
				width = precision, precision = -1;
  800367:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80036a:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80036f:	eb 8e                	jmp    8002ff <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800371:	47                   	inc    %edi
			goto reswitch;
  800372:	eb 8b                	jmp    8002ff <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	8b 55 14             	mov    0x14(%ebp),%edx
  80037d:	8d 42 04             	lea    0x4(%edx),%eax
  800380:	89 45 14             	mov    %eax,0x14(%ebp)
  800383:	ff 32                	pushl  (%edx)
  800385:	ff 55 08             	call   *0x8(%ebp)
			break;
  800388:	83 c4 10             	add    $0x10,%esp
  80038b:	e9 2c ff ff ff       	jmp    8002bc <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800390:	8b 55 14             	mov    0x14(%ebp),%edx
  800393:	8d 42 04             	lea    0x4(%edx),%eax
  800396:	89 45 14             	mov    %eax,0x14(%ebp)
  800399:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	79 02                	jns    8003a1 <vprintfmt+0xf1>
				err = -err;
  80039f:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a1:	83 f8 0f             	cmp    $0xf,%eax
  8003a4:	7f 0b                	jg     8003b1 <vprintfmt+0x101>
  8003a6:	8b 3c 85 60 11 80 00 	mov    0x801160(,%eax,4),%edi
  8003ad:	85 ff                	test   %edi,%edi
  8003af:	75 19                	jne    8003ca <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  8003b1:	50                   	push   %eax
  8003b2:	68 18 11 80 00       	push   $0x801118
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	e8 ef 01 00 00       	call   8005b1 <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	e9 f2 fe ff ff       	jmp    8002bc <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8003ca:	57                   	push   %edi
  8003cb:	68 21 11 80 00       	push   $0x801121
  8003d0:	ff 75 0c             	pushl  0xc(%ebp)
  8003d3:	ff 75 08             	pushl  0x8(%ebp)
  8003d6:	e8 d6 01 00 00       	call   8005b1 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			break;
  8003de:	e9 d9 fe ff ff       	jmp    8002bc <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e3:	8b 55 14             	mov    0x14(%ebp),%edx
  8003e6:	8d 42 04             	lea    0x4(%edx),%eax
  8003e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ec:	8b 3a                	mov    (%edx),%edi
  8003ee:	85 ff                	test   %edi,%edi
  8003f0:	75 05                	jne    8003f7 <vprintfmt+0x147>
				p = "(null)";
  8003f2:	bf 24 11 80 00       	mov    $0x801124,%edi
			if (width > 0 && padc != '-')
  8003f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003fb:	7e 3b                	jle    800438 <vprintfmt+0x188>
  8003fd:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800401:	74 35                	je     800438 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	56                   	push   %esi
  800407:	57                   	push   %edi
  800408:	e8 58 02 00 00       	call   800665 <strnlen>
  80040d:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800417:	7e 1f                	jle    800438 <vprintfmt+0x188>
  800419:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80041d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	ff 75 0c             	pushl  0xc(%ebp)
  800426:	ff 75 e4             	pushl  -0x1c(%ebp)
  800429:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	ff 4d f0             	decl   -0x10(%ebp)
  800432:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800436:	7f e8                	jg     800420 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800438:	0f be 0f             	movsbl (%edi),%ecx
  80043b:	47                   	inc    %edi
  80043c:	85 c9                	test   %ecx,%ecx
  80043e:	74 44                	je     800484 <vprintfmt+0x1d4>
  800440:	85 f6                	test   %esi,%esi
  800442:	78 03                	js     800447 <vprintfmt+0x197>
  800444:	4e                   	dec    %esi
  800445:	78 3d                	js     800484 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800447:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80044b:	74 18                	je     800465 <vprintfmt+0x1b5>
  80044d:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800450:	83 f8 5e             	cmp    $0x5e,%eax
  800453:	76 10                	jbe    800465 <vprintfmt+0x1b5>
					putch('?', putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 0c             	pushl  0xc(%ebp)
  80045b:	6a 3f                	push   $0x3f
  80045d:	ff 55 08             	call   *0x8(%ebp)
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	eb 0d                	jmp    800472 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	ff 75 0c             	pushl  0xc(%ebp)
  80046b:	51                   	push   %ecx
  80046c:	ff 55 08             	call   *0x8(%ebp)
  80046f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800472:	ff 4d f0             	decl   -0x10(%ebp)
  800475:	0f be 0f             	movsbl (%edi),%ecx
  800478:	47                   	inc    %edi
  800479:	85 c9                	test   %ecx,%ecx
  80047b:	74 07                	je     800484 <vprintfmt+0x1d4>
  80047d:	85 f6                	test   %esi,%esi
  80047f:	78 c6                	js     800447 <vprintfmt+0x197>
  800481:	4e                   	dec    %esi
  800482:	79 c3                	jns    800447 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800484:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800488:	0f 8e 2e fe ff ff    	jle    8002bc <vprintfmt+0xc>
				putch(' ', putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	ff 75 0c             	pushl  0xc(%ebp)
  800494:	6a 20                	push   $0x20
  800496:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	ff 4d f0             	decl   -0x10(%ebp)
  80049f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004a3:	7f e9                	jg     80048e <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  8004a5:	e9 12 fe ff ff       	jmp    8002bc <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004aa:	57                   	push   %edi
  8004ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ae:	50                   	push   %eax
  8004af:	e8 c4 fd ff ff       	call   800278 <getint>
  8004b4:	89 c6                	mov    %eax,%esi
  8004b6:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004b8:	83 c4 08             	add    $0x8,%esp
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	79 15                	jns    8004d4 <vprintfmt+0x224>
				putch('-', putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	6a 2d                	push   $0x2d
  8004c7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004ca:	f7 de                	neg    %esi
  8004cc:	83 d7 00             	adc    $0x0,%edi
  8004cf:	f7 df                	neg    %edi
  8004d1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004d4:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004d9:	eb 76                	jmp    800551 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004db:	57                   	push   %edi
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8004df:	50                   	push   %eax
  8004e0:	e8 53 fd ff ff       	call   800238 <getuint>
  8004e5:	89 c6                	mov    %eax,%esi
  8004e7:	89 d7                	mov    %edx,%edi
			base = 10;
  8004e9:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004ee:	83 c4 08             	add    $0x8,%esp
  8004f1:	eb 5e                	jmp    800551 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004f3:	57                   	push   %edi
  8004f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f7:	50                   	push   %eax
  8004f8:	e8 3b fd ff ff       	call   800238 <getuint>
  8004fd:	89 c6                	mov    %eax,%esi
  8004ff:	89 d7                	mov    %edx,%edi
			base = 8;
  800501:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	eb 46                	jmp    800551 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	ff 75 0c             	pushl  0xc(%ebp)
  800511:	6a 30                	push   $0x30
  800513:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	6a 78                	push   $0x78
  80051e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800521:	8b 55 14             	mov    0x14(%ebp),%edx
  800524:	8d 42 04             	lea    0x4(%edx),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
  80052a:	8b 32                	mov    (%edx),%esi
  80052c:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800531:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 16                	jmp    800551 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80053b:	57                   	push   %edi
  80053c:	8d 45 14             	lea    0x14(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	e8 f3 fc ff ff       	call   800238 <getuint>
  800545:	89 c6                	mov    %eax,%esi
  800547:	89 d7                	mov    %edx,%edi
			base = 16;
  800549:	ba 10 00 00 00       	mov    $0x10,%edx
  80054e:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800551:	83 ec 04             	sub    $0x4,%esp
  800554:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 f0             	pushl  -0x10(%ebp)
  80055c:	52                   	push   %edx
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	ff 75 0c             	pushl  0xc(%ebp)
  800562:	ff 75 08             	pushl  0x8(%ebp)
  800565:	e8 2e fc ff ff       	call   800198 <printnum>
			break;
  80056a:	83 c4 20             	add    $0x20,%esp
  80056d:	e9 4a fd ff ff       	jmp    8002bc <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	51                   	push   %ecx
  800579:	ff 55 08             	call   *0x8(%ebp)
			break;
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	e9 38 fd ff ff       	jmp    8002bc <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	ff 75 0c             	pushl  0xc(%ebp)
  80058a:	6a 25                	push   $0x25
  80058c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80058f:	4b                   	dec    %ebx
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800597:	0f 84 1f fd ff ff    	je     8002bc <vprintfmt+0xc>
  80059d:	4b                   	dec    %ebx
  80059e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005a2:	75 f9                	jne    80059d <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005a4:	e9 13 fd ff ff       	jmp    8002bc <vprintfmt+0xc>
		}
	}
}
  8005a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ac:	5b                   	pop    %ebx
  8005ad:	5e                   	pop    %esi
  8005ae:	5f                   	pop    %edi
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005ba:	50                   	push   %eax
  8005bb:	ff 75 10             	pushl  0x10(%ebp)
  8005be:	ff 75 0c             	pushl  0xc(%ebp)
  8005c1:	ff 75 08             	pushl  0x8(%ebp)
  8005c4:	e8 e7 fc ff ff       	call   8002b0 <vprintfmt>
	va_end(ap);
}
  8005c9:	c9                   	leave  
  8005ca:	c3                   	ret    

008005cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005d1:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005d4:	8b 0a                	mov    (%edx),%ecx
  8005d6:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005d9:	73 07                	jae    8005e2 <sprintputch+0x17>
		*b->buf++ = ch;
  8005db:	8b 45 08             	mov    0x8(%ebp),%eax
  8005de:	88 01                	mov    %al,(%ecx)
  8005e0:	ff 02                	incl   (%edx)
}
  8005e2:	c9                   	leave  
  8005e3:	c3                   	ret    

008005e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	83 ec 18             	sub    $0x18,%esp
  8005ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005f3:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8005f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800601:	85 d2                	test   %edx,%edx
  800603:	74 04                	je     800609 <vsnprintf+0x25>
  800605:	85 c9                	test   %ecx,%ecx
  800607:	7f 07                	jg     800610 <vsnprintf+0x2c>
		return -E_INVAL;
  800609:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80060e:	eb 1d                	jmp    80062d <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800610:	ff 75 14             	pushl  0x14(%ebp)
  800613:	ff 75 10             	pushl  0x10(%ebp)
  800616:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800619:	50                   	push   %eax
  80061a:	68 cb 05 80 00       	push   $0x8005cb
  80061f:	e8 8c fc ff ff       	call   8002b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800624:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800627:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80062a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800638:	50                   	push   %eax
  800639:	ff 75 10             	pushl  0x10(%ebp)
  80063c:	ff 75 0c             	pushl  0xc(%ebp)
  80063f:	ff 75 08             	pushl  0x8(%ebp)
  800642:	e8 9d ff ff ff       	call   8005e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800647:	c9                   	leave  
  800648:	c3                   	ret    
  800649:	00 00                	add    %al,(%eax)
	...

0080064c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800652:	b8 00 00 00 00       	mov    $0x0,%eax
  800657:	80 3a 00             	cmpb   $0x0,(%edx)
  80065a:	74 07                	je     800663 <strlen+0x17>
		n++;
  80065c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80065d:	42                   	inc    %edx
  80065e:	80 3a 00             	cmpb   $0x0,(%edx)
  800661:	75 f9                	jne    80065c <strlen+0x10>
		n++;
	return n;
}
  800663:	c9                   	leave  
  800664:	c3                   	ret    

00800665 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80066b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80066e:	b8 00 00 00 00       	mov    $0x0,%eax
  800673:	85 d2                	test   %edx,%edx
  800675:	74 0f                	je     800686 <strnlen+0x21>
  800677:	80 39 00             	cmpb   $0x0,(%ecx)
  80067a:	74 0a                	je     800686 <strnlen+0x21>
		n++;
  80067c:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80067d:	41                   	inc    %ecx
  80067e:	4a                   	dec    %edx
  80067f:	74 05                	je     800686 <strnlen+0x21>
  800681:	80 39 00             	cmpb   $0x0,(%ecx)
  800684:	75 f6                	jne    80067c <strnlen+0x17>
		n++;
	return n;
}
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	53                   	push   %ebx
  80068c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800692:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800694:	8a 02                	mov    (%edx),%al
  800696:	42                   	inc    %edx
  800697:	88 01                	mov    %al,(%ecx)
  800699:	41                   	inc    %ecx
  80069a:	84 c0                	test   %al,%al
  80069c:	75 f6                	jne    800694 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80069e:	89 d8                	mov    %ebx,%eax
  8006a0:	5b                   	pop    %ebx
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	53                   	push   %ebx
  8006a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006aa:	53                   	push   %ebx
  8006ab:	e8 9c ff ff ff       	call   80064c <strlen>
	strcpy(dst + len, src);
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006b6:	50                   	push   %eax
  8006b7:	e8 cc ff ff ff       	call   800688 <strcpy>
	return dst;
}
  8006bc:	89 d8                	mov    %ebx,%eax
  8006be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	57                   	push   %edi
  8006c7:	56                   	push   %esi
  8006c8:	53                   	push   %ebx
  8006c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cf:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006d2:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	73 10                	jae    8006ed <strncpy+0x2a>
		*dst++ = *src;
  8006dd:	8a 02                	mov    (%edx),%al
  8006df:	88 01                	mov    %al,(%ecx)
  8006e1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006e2:	80 3a 01             	cmpb   $0x1,(%edx)
  8006e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006e8:	43                   	inc    %ebx
  8006e9:	39 f3                	cmp    %esi,%ebx
  8006eb:	72 f0                	jb     8006dd <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006ed:	89 f8                	mov    %edi,%eax
  8006ef:	5b                   	pop    %ebx
  8006f0:	5e                   	pop    %esi
  8006f1:	5f                   	pop    %edi
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	56                   	push   %esi
  8006f8:	53                   	push   %ebx
  8006f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  800702:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800704:	85 d2                	test   %edx,%edx
  800706:	74 19                	je     800721 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800708:	4a                   	dec    %edx
  800709:	74 13                	je     80071e <strlcpy+0x2a>
  80070b:	80 39 00             	cmpb   $0x0,(%ecx)
  80070e:	74 0e                	je     80071e <strlcpy+0x2a>
  800710:	8a 01                	mov    (%ecx),%al
  800712:	41                   	inc    %ecx
  800713:	88 03                	mov    %al,(%ebx)
  800715:	43                   	inc    %ebx
  800716:	4a                   	dec    %edx
  800717:	74 05                	je     80071e <strlcpy+0x2a>
  800719:	80 39 00             	cmpb   $0x0,(%ecx)
  80071c:	75 f2                	jne    800710 <strlcpy+0x1c>
		*dst = '\0';
  80071e:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800721:	89 d8                	mov    %ebx,%eax
  800723:	29 f0                	sub    %esi,%eax
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	8b 55 08             	mov    0x8(%ebp),%edx
  80072f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800732:	80 3a 00             	cmpb   $0x0,(%edx)
  800735:	74 13                	je     80074a <strcmp+0x21>
  800737:	8a 02                	mov    (%edx),%al
  800739:	3a 01                	cmp    (%ecx),%al
  80073b:	75 0d                	jne    80074a <strcmp+0x21>
  80073d:	42                   	inc    %edx
  80073e:	41                   	inc    %ecx
  80073f:	80 3a 00             	cmpb   $0x0,(%edx)
  800742:	74 06                	je     80074a <strcmp+0x21>
  800744:	8a 02                	mov    (%edx),%al
  800746:	3a 01                	cmp    (%ecx),%al
  800748:	74 f3                	je     80073d <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80074a:	0f b6 02             	movzbl (%edx),%eax
  80074d:	0f b6 11             	movzbl (%ecx),%edx
  800750:	29 d0                	sub    %edx,%eax
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
  80075b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800761:	85 c9                	test   %ecx,%ecx
  800763:	74 1f                	je     800784 <strncmp+0x30>
  800765:	80 3a 00             	cmpb   $0x0,(%edx)
  800768:	74 16                	je     800780 <strncmp+0x2c>
  80076a:	8a 02                	mov    (%edx),%al
  80076c:	3a 03                	cmp    (%ebx),%al
  80076e:	75 10                	jne    800780 <strncmp+0x2c>
  800770:	42                   	inc    %edx
  800771:	43                   	inc    %ebx
  800772:	49                   	dec    %ecx
  800773:	74 0f                	je     800784 <strncmp+0x30>
  800775:	80 3a 00             	cmpb   $0x0,(%edx)
  800778:	74 06                	je     800780 <strncmp+0x2c>
  80077a:	8a 02                	mov    (%edx),%al
  80077c:	3a 03                	cmp    (%ebx),%al
  80077e:	74 f0                	je     800770 <strncmp+0x1c>
	if (n == 0)
  800780:	85 c9                	test   %ecx,%ecx
  800782:	75 07                	jne    80078b <strncmp+0x37>
		return 0;
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 0a                	jmp    800795 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80078b:	0f b6 12             	movzbl (%edx),%edx
  80078e:	0f b6 03             	movzbl (%ebx),%eax
  800791:	29 c2                	sub    %eax,%edx
  800793:	89 d0                	mov    %edx,%eax
}
  800795:	5b                   	pop    %ebx
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007a1:	80 38 00             	cmpb   $0x0,(%eax)
  8007a4:	74 0a                	je     8007b0 <strchr+0x18>
		if (*s == c)
  8007a6:	38 10                	cmp    %dl,(%eax)
  8007a8:	74 0b                	je     8007b5 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007aa:	40                   	inc    %eax
  8007ab:	80 38 00             	cmpb   $0x0,(%eax)
  8007ae:	75 f6                	jne    8007a6 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007c0:	80 38 00             	cmpb   $0x0,(%eax)
  8007c3:	74 0a                	je     8007cf <strfind+0x18>
		if (*s == c)
  8007c5:	38 10                	cmp    %dl,(%eax)
  8007c7:	74 06                	je     8007cf <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007c9:	40                   	inc    %eax
  8007ca:	80 38 00             	cmpb   $0x0,(%eax)
  8007cd:	75 f6                	jne    8007c5 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	57                   	push   %edi
  8007d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8007db:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8007dd:	85 c9                	test   %ecx,%ecx
  8007df:	74 40                	je     800821 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007e7:	75 30                	jne    800819 <memset+0x48>
  8007e9:	f6 c1 03             	test   $0x3,%cl
  8007ec:	75 2b                	jne    800819 <memset+0x48>
		c &= 0xFF;
  8007ee:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f8:	c1 e0 18             	shl    $0x18,%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	c1 e2 10             	shl    $0x10,%edx
  800801:	09 d0                	or     %edx,%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	c1 e2 08             	shl    $0x8,%edx
  800809:	09 d0                	or     %edx,%eax
  80080b:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80080e:	c1 e9 02             	shr    $0x2,%ecx
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	fc                   	cld    
  800815:	f3 ab                	rep stos %eax,%es:(%edi)
  800817:	eb 06                	jmp    80081f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	fc                   	cld    
  80081d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80081f:	89 f8                	mov    %edi,%eax
}
  800821:	5f                   	pop    %edi
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	57                   	push   %edi
  800828:	56                   	push   %esi
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80082f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800832:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800834:	39 c6                	cmp    %eax,%esi
  800836:	73 34                	jae    80086c <memmove+0x48>
  800838:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80083b:	39 c2                	cmp    %eax,%edx
  80083d:	76 2d                	jbe    80086c <memmove+0x48>
		s += n;
  80083f:	89 d6                	mov    %edx,%esi
		d += n;
  800841:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800844:	f6 c2 03             	test   $0x3,%dl
  800847:	75 1b                	jne    800864 <memmove+0x40>
  800849:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084f:	75 13                	jne    800864 <memmove+0x40>
  800851:	f6 c1 03             	test   $0x3,%cl
  800854:	75 0e                	jne    800864 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800856:	83 ef 04             	sub    $0x4,%edi
  800859:	83 ee 04             	sub    $0x4,%esi
  80085c:	c1 e9 02             	shr    $0x2,%ecx
  80085f:	fd                   	std    
  800860:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800862:	eb 05                	jmp    800869 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800864:	4f                   	dec    %edi
  800865:	4e                   	dec    %esi
  800866:	fd                   	std    
  800867:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800869:	fc                   	cld    
  80086a:	eb 20                	jmp    80088c <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80086c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800872:	75 15                	jne    800889 <memmove+0x65>
  800874:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087a:	75 0d                	jne    800889 <memmove+0x65>
  80087c:	f6 c1 03             	test   $0x3,%cl
  80087f:	75 08                	jne    800889 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800881:	c1 e9 02             	shr    $0x2,%ecx
  800884:	fc                   	cld    
  800885:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800887:	eb 03                	jmp    80088c <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800889:	fc                   	cld    
  80088a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80088c:	5e                   	pop    %esi
  80088d:	5f                   	pop    %edi
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800893:	ff 75 10             	pushl  0x10(%ebp)
  800896:	ff 75 0c             	pushl  0xc(%ebp)
  800899:	ff 75 08             	pushl  0x8(%ebp)
  80089c:	e8 83 ff ff ff       	call   800824 <memmove>
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008ad:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b0:	4a                   	dec    %edx
  8008b1:	83 fa ff             	cmp    $0xffffffff,%edx
  8008b4:	74 1a                	je     8008d0 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8008b6:	8a 01                	mov    (%ecx),%al
  8008b8:	3a 03                	cmp    (%ebx),%al
  8008ba:	74 0c                	je     8008c8 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  8008bc:	0f b6 d0             	movzbl %al,%edx
  8008bf:	0f b6 03             	movzbl (%ebx),%eax
  8008c2:	29 c2                	sub    %eax,%edx
  8008c4:	89 d0                	mov    %edx,%eax
  8008c6:	eb 0d                	jmp    8008d5 <memcmp+0x32>
		s1++, s2++;
  8008c8:	41                   	inc    %ecx
  8008c9:	43                   	inc    %ebx
  8008ca:	4a                   	dec    %edx
  8008cb:	83 fa ff             	cmp    $0xffffffff,%edx
  8008ce:	75 e6                	jne    8008b6 <memcmp+0x13>
	}

	return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008e6:	39 d0                	cmp    %edx,%eax
  8008e8:	73 09                	jae    8008f3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008ea:	38 08                	cmp    %cl,(%eax)
  8008ec:	74 05                	je     8008f3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	39 d0                	cmp    %edx,%eax
  8008f1:	72 f7                	jb     8008ea <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	57                   	push   %edi
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800901:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800904:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800909:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80090e:	80 3a 20             	cmpb   $0x20,(%edx)
  800911:	74 05                	je     800918 <strtol+0x23>
  800913:	80 3a 09             	cmpb   $0x9,(%edx)
  800916:	75 0b                	jne    800923 <strtol+0x2e>
  800918:	42                   	inc    %edx
  800919:	80 3a 20             	cmpb   $0x20,(%edx)
  80091c:	74 fa                	je     800918 <strtol+0x23>
  80091e:	80 3a 09             	cmpb   $0x9,(%edx)
  800921:	74 f5                	je     800918 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800923:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800926:	75 03                	jne    80092b <strtol+0x36>
		s++;
  800928:	42                   	inc    %edx
  800929:	eb 0b                	jmp    800936 <strtol+0x41>
	else if (*s == '-')
  80092b:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80092e:	75 06                	jne    800936 <strtol+0x41>
		s++, neg = 1;
  800930:	42                   	inc    %edx
  800931:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800936:	85 c9                	test   %ecx,%ecx
  800938:	74 05                	je     80093f <strtol+0x4a>
  80093a:	83 f9 10             	cmp    $0x10,%ecx
  80093d:	75 15                	jne    800954 <strtol+0x5f>
  80093f:	80 3a 30             	cmpb   $0x30,(%edx)
  800942:	75 10                	jne    800954 <strtol+0x5f>
  800944:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800948:	75 0a                	jne    800954 <strtol+0x5f>
		s += 2, base = 16;
  80094a:	83 c2 02             	add    $0x2,%edx
  80094d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800952:	eb 14                	jmp    800968 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800954:	85 c9                	test   %ecx,%ecx
  800956:	75 10                	jne    800968 <strtol+0x73>
  800958:	80 3a 30             	cmpb   $0x30,(%edx)
  80095b:	75 05                	jne    800962 <strtol+0x6d>
		s++, base = 8;
  80095d:	42                   	inc    %edx
  80095e:	b1 08                	mov    $0x8,%cl
  800960:	eb 06                	jmp    800968 <strtol+0x73>
	else if (base == 0)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	75 02                	jne    800968 <strtol+0x73>
		base = 10;
  800966:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800968:	8a 02                	mov    (%edx),%al
  80096a:	83 e8 30             	sub    $0x30,%eax
  80096d:	3c 09                	cmp    $0x9,%al
  80096f:	77 08                	ja     800979 <strtol+0x84>
			dig = *s - '0';
  800971:	0f be 02             	movsbl (%edx),%eax
  800974:	83 e8 30             	sub    $0x30,%eax
  800977:	eb 20                	jmp    800999 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800979:	8a 02                	mov    (%edx),%al
  80097b:	83 e8 61             	sub    $0x61,%eax
  80097e:	3c 19                	cmp    $0x19,%al
  800980:	77 08                	ja     80098a <strtol+0x95>
			dig = *s - 'a' + 10;
  800982:	0f be 02             	movsbl (%edx),%eax
  800985:	83 e8 57             	sub    $0x57,%eax
  800988:	eb 0f                	jmp    800999 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  80098a:	8a 02                	mov    (%edx),%al
  80098c:	83 e8 41             	sub    $0x41,%eax
  80098f:	3c 19                	cmp    $0x19,%al
  800991:	77 12                	ja     8009a5 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800993:	0f be 02             	movsbl (%edx),%eax
  800996:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800999:	39 c8                	cmp    %ecx,%eax
  80099b:	7d 08                	jge    8009a5 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80099d:	42                   	inc    %edx
  80099e:	0f af d9             	imul   %ecx,%ebx
  8009a1:	01 c3                	add    %eax,%ebx
  8009a3:	eb c3                	jmp    800968 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009a5:	85 f6                	test   %esi,%esi
  8009a7:	74 02                	je     8009ab <strtol+0xb6>
		*endptr = (char *) s;
  8009a9:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	85 ff                	test   %edi,%edi
  8009af:	74 02                	je     8009b3 <strtol+0xbe>
  8009b1:	f7 d8                	neg    %eax
}
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	57                   	push   %edi
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	83 ec 04             	sub    $0x4,%esp
  8009c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009c7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	89 fb                	mov    %edi,%ebx
  8009d0:	89 fe                	mov    %edi,%esi
  8009d2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009d4:	83 c4 04             	add    $0x4,%esp
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009ec:	89 fa                	mov    %edi,%edx
  8009ee:	89 f9                	mov    %edi,%ecx
  8009f0:	89 fb                	mov    %edi,%ebx
  8009f2:	89 fe                	mov    %edi,%esi
  8009f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	83 ec 0c             	sub    $0xc,%esp
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a07:	b8 03 00 00 00       	mov    $0x3,%eax
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a11:	89 f9                	mov    %edi,%ecx
  800a13:	89 fb                	mov    %edi,%ebx
  800a15:	89 fe                	mov    %edi,%esi
  800a17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	7e 17                	jle    800a34 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a1d:	83 ec 0c             	sub    $0xc,%esp
  800a20:	50                   	push   %eax
  800a21:	6a 03                	push   $0x3
  800a23:	68 f8 12 80 00       	push   $0x8012f8
  800a28:	6a 23                	push   $0x23
  800a2a:	68 15 13 80 00       	push   $0x801315
  800a2f:	e8 38 02 00 00       	call   800c6c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a42:	b8 02 00 00 00       	mov    $0x2,%eax
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4c:	89 fa                	mov    %edi,%edx
  800a4e:	89 f9                	mov    %edi,%ecx
  800a50:	89 fb                	mov    %edi,%ebx
  800a52:	89 fe                	mov    %edi,%esi
  800a54:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <sys_yield>:

void
sys_yield(void)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a61:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6b:	89 fa                	mov    %edi,%edx
  800a6d:	89 f9                	mov    %edi,%ecx
  800a6f:	89 fb                	mov    %edi,%ebx
  800a71:	89 fe                	mov    %edi,%esi
  800a73:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	83 ec 0c             	sub    $0xc,%esp
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
  800a86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	89 fe                	mov    %edi,%esi
  800a98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 04                	push   $0x4
  800aa4:	68 f8 12 80 00       	push   $0x8012f8
  800aa9:	6a 23                	push   $0x23
  800aab:	68 15 13 80 00       	push   $0x801315
  800ab0:	e8 b7 01 00 00       	call   800c6c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 0c             	sub    $0xc,%esp
  800ac6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800acf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ad2:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad5:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800adc:	85 c0                	test   %eax,%eax
  800ade:	7e 17                	jle    800af7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae0:	83 ec 0c             	sub    $0xc,%esp
  800ae3:	50                   	push   %eax
  800ae4:	6a 05                	push   $0x5
  800ae6:	68 f8 12 80 00       	push   $0x8012f8
  800aeb:	6a 23                	push   $0x23
  800aed:	68 15 13 80 00       	push   $0x801315
  800af2:	e8 75 01 00 00       	call   800c6c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800af7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b13:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	89 fb                	mov    %edi,%ebx
  800b1a:	89 fe                	mov    %edi,%esi
  800b1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	7e 17                	jle    800b39 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	50                   	push   %eax
  800b26:	6a 06                	push   $0x6
  800b28:	68 f8 12 80 00       	push   $0x8012f8
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 15 13 80 00       	push   $0x801315
  800b34:	e8 33 01 00 00       	call   800c6c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b50:	b8 08 00 00 00       	mov    $0x8,%eax
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	89 fb                	mov    %edi,%ebx
  800b5c:	89 fe                	mov    %edi,%esi
  800b5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 08                	push   $0x8
  800b6a:	68 f8 12 80 00       	push   $0x8012f8
  800b6f:	6a 23                	push   $0x23
  800b71:	68 15 13 80 00       	push   $0x801315
  800b76:	e8 f1 00 00 00       	call   800c6c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b92:	b8 09 00 00 00       	mov    $0x9,%eax
  800b97:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	89 fb                	mov    %edi,%ebx
  800b9e:	89 fe                	mov    %edi,%esi
  800ba0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 09                	push   $0x9
  800bac:	68 f8 12 80 00       	push   $0x8012f8
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 15 13 80 00       	push   $0x801315
  800bb8:	e8 af 00 00 00       	call   800c6c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bd4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	89 fb                	mov    %edi,%ebx
  800be0:	89 fe                	mov    %edi,%esi
  800be2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 0a                	push   $0xa
  800bee:	68 f8 12 80 00       	push   $0x8012f8
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 15 13 80 00       	push   $0x801315
  800bfa:	e8 6d 00 00 00       	call   800c6c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c1e:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c36:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c3b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	89 f9                	mov    %edi,%ecx
  800c42:	89 fb                	mov    %edi,%ebx
  800c44:	89 fe                	mov    %edi,%esi
  800c46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 0d                	push   $0xd
  800c52:	68 f8 12 80 00       	push   $0x8012f8
  800c57:	6a 23                	push   $0x23
  800c59:	68 15 13 80 00       	push   $0x801315
  800c5e:	e8 09 00 00 00       	call   800c6c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    
	...

00800c6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800c73:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c76:	ff 75 0c             	pushl  0xc(%ebp)
  800c79:	ff 75 08             	pushl  0x8(%ebp)
  800c7c:	ff 35 00 20 80 00    	pushl  0x802000
  800c82:	83 ec 08             	sub    $0x8,%esp
  800c85:	e8 b2 fd ff ff       	call   800a3c <sys_getenvid>
  800c8a:	83 c4 08             	add    $0x8,%esp
  800c8d:	50                   	push   %eax
  800c8e:	68 24 13 80 00       	push   $0x801324
  800c93:	e8 ec f4 ff ff       	call   800184 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c98:	83 c4 18             	add    $0x18,%esp
  800c9b:	53                   	push   %ebx
  800c9c:	ff 75 10             	pushl  0x10(%ebp)
  800c9f:	e8 8f f4 ff ff       	call   800133 <vcprintf>
	cprintf("\n");
  800ca4:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  800cab:	e8 d4 f4 ff ff       	call   800184 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800cb0:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800cb3:	cc                   	int3   
  800cb4:	eb fd                	jmp    800cb3 <_panic+0x47>
	...

00800cb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	83 ec 14             	sub    $0x14,%esp
  800cc0:	8b 55 14             	mov    0x14(%ebp),%edx
  800cc3:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cc9:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ccc:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cce:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800cd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800cd4:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800cd7:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cd9:	75 11                	jne    800cec <__udivdi3+0x34>
    {
      if (d0 > n1)
  800cdb:	39 f8                	cmp    %edi,%eax
  800cdd:	76 4d                	jbe    800d2c <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cdf:	89 fa                	mov    %edi,%edx
  800ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce4:	f7 75 e4             	divl   -0x1c(%ebp)
  800ce7:	89 c7                	mov    %eax,%edi
  800ce9:	eb 09                	jmp    800cf4 <__udivdi3+0x3c>
  800ceb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cec:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800cef:	76 17                	jbe    800d08 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800cf1:	31 ff                	xor    %edi,%edi
  800cf3:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800cf4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cfe:	83 c4 14             	add    $0x14,%esp
  800d01:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d02:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d04:	5f                   	pop    %edi
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    
  800d07:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d08:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	83 f7 1f             	xor    $0x1f,%edi
  800d11:	75 4d                	jne    800d60 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d13:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800d16:	77 0a                	ja     800d22 <__udivdi3+0x6a>
  800d18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800d1b:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d1d:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800d20:	72 d2                	jb     800cf4 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800d22:	bf 01 00 00 00       	mov    $0x1,%edi
  800d27:	eb cb                	jmp    800cf4 <__udivdi3+0x3c>
  800d29:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	75 0e                	jne    800d41 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d33:	b8 01 00 00 00       	mov    $0x1,%eax
  800d38:	31 c9                	xor    %ecx,%ecx
  800d3a:	31 d2                	xor    %edx,%edx
  800d3c:	f7 f1                	div    %ecx
  800d3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d41:	89 f0                	mov    %esi,%eax
  800d43:	31 d2                	xor    %edx,%edx
  800d45:	f7 75 e4             	divl   -0x1c(%ebp)
  800d48:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d4e:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d51:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d54:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d57:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d59:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5c:	5f                   	pop    %edi
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    
  800d5f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d60:	b8 20 00 00 00       	mov    $0x20,%eax
  800d65:	29 f8                	sub    %edi,%eax
  800d67:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800d6a:	89 f9                	mov    %edi,%ecx
  800d6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d6f:	d3 e2                	shl    %cl,%edx
  800d71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d74:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800d7b:	89 f9                	mov    %edi,%ecx
  800d7d:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d80:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d83:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d86:	89 f2                	mov    %esi,%edx
  800d88:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800d8a:	89 f9                	mov    %edi,%ecx
  800d8c:	d3 e6                	shl    %cl,%esi
  800d8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d91:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800d94:	d3 e8                	shr    %cl,%eax
  800d96:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800d98:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d9a:	89 f0                	mov    %esi,%eax
  800d9c:	f7 75 f4             	divl   -0xc(%ebp)
  800d9f:	89 d6                	mov    %edx,%esi
  800da1:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800da3:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da9:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dab:	39 f2                	cmp    %esi,%edx
  800dad:	77 0f                	ja     800dbe <__udivdi3+0x106>
  800daf:	0f 85 3f ff ff ff    	jne    800cf4 <__udivdi3+0x3c>
  800db5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800db8:	0f 86 36 ff ff ff    	jbe    800cf4 <__udivdi3+0x3c>
		{
		  q0--;
  800dbe:	4f                   	dec    %edi
  800dbf:	e9 30 ff ff ff       	jmp    800cf4 <__udivdi3+0x3c>

00800dc4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	83 ec 30             	sub    $0x30,%esp
  800dcc:	8b 55 14             	mov    0x14(%ebp),%edx
  800dcf:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800dd2:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800dd4:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dd7:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800dd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ddf:	85 ff                	test   %edi,%edi
  800de1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800de8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800def:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800df2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800df5:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df8:	75 3e                	jne    800e38 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800dfa:	39 d6                	cmp    %edx,%esi
  800dfc:	0f 86 a2 00 00 00    	jbe    800ea4 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e02:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e04:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e07:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e09:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e0c:	74 1b                	je     800e29 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800e14:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e21:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e24:	89 10                	mov    %edx,(%eax)
  800e26:	89 48 04             	mov    %ecx,0x4(%eax)
  800e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e2f:	83 c4 30             	add    $0x30,%esp
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    
  800e36:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e38:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800e3b:	76 1f                	jbe    800e5c <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800e40:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e43:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800e46:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800e49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e52:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e55:	83 c4 30             	add    $0x30,%esp
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e5c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e5f:	83 f0 1f             	xor    $0x1f,%eax
  800e62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e65:	75 61                	jne    800ec8 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e67:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800e6a:	77 05                	ja     800e71 <__umoddi3+0xad>
  800e6c:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800e6f:	72 10                	jb     800e81 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e71:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e77:	29 f0                	sub    %esi,%eax
  800e79:	19 fa                	sbb    %edi,%edx
  800e7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e7e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800e81:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e84:	85 d2                	test   %edx,%edx
  800e86:	74 a1                	je     800e29 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800e88:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800e8b:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800e8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800e91:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800e94:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e9d:	89 01                	mov    %eax,(%ecx)
  800e9f:	89 51 04             	mov    %edx,0x4(%ecx)
  800ea2:	eb 85                	jmp    800e29 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea4:	85 f6                	test   %esi,%esi
  800ea6:	75 0b                	jne    800eb3 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ea8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	f7 f6                	div    %esi
  800eb1:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eb3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800eb6:	89 fa                	mov    %edi,%edx
  800eb8:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eba:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ebd:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec0:	f7 f6                	div    %esi
  800ec2:	e9 3d ff ff ff       	jmp    800e04 <__umoddi3+0x40>
  800ec7:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ec8:	b8 20 00 00 00       	mov    $0x20,%eax
  800ecd:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800ed0:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800ed3:	89 fa                	mov    %edi,%edx
  800ed5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ed8:	d3 e2                	shl    %cl,%edx
  800eda:	89 f0                	mov    %esi,%eax
  800edc:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800edf:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800ee1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ee4:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ee6:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ee8:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800eeb:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eee:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ef0:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800ef2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ef5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ef8:	d3 e0                	shl    %cl,%eax
  800efa:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800efd:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f03:	d3 e8                	shr    %cl,%eax
  800f05:	0b 45 cc             	or     -0x34(%ebp),%eax
  800f08:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800f0b:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f0e:	f7 f7                	div    %edi
  800f10:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f13:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f16:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f18:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f1b:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f1e:	77 0a                	ja     800f2a <__umoddi3+0x166>
  800f20:	75 12                	jne    800f34 <__umoddi3+0x170>
  800f22:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f25:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800f28:	76 0a                	jbe    800f34 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f2a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800f2d:	29 f1                	sub    %esi,%ecx
  800f2f:	19 fa                	sbb    %edi,%edx
  800f31:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f37:	85 c0                	test   %eax,%eax
  800f39:	0f 84 ea fe ff ff    	je     800e29 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f3f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f42:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f45:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800f48:	19 d1                	sbb    %edx,%ecx
  800f4a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f4d:	89 ca                	mov    %ecx,%edx
  800f4f:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f52:	d3 e2                	shl    %cl,%edx
  800f54:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f57:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f5a:	d3 e8                	shr    %cl,%eax
  800f5c:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f5e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f61:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f63:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800f66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f69:	e9 ad fe ff ff       	jmp    800e1b <__umoddi3+0x57>
