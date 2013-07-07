
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4b 00 00 00       	call   80007c <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	52                   	push   %edx
  800044:	ff 30                	pushl  (%eax)
  800046:	68 e0 0f 80 00       	push   $0x800fe0
  80004b:	e8 18 01 00 00       	call   800168 <cprintf>
	sys_env_destroy(sys_getenvid());
  800050:	e8 cb 09 00 00       	call   800a20 <sys_getenvid>
  800055:	89 04 24             	mov    %eax,(%esp)
  800058:	e8 82 09 00 00       	call   8009df <sys_env_destroy>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <umain>:

void
umain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800065:	68 34 00 80 00       	push   $0x800034
  80006a:	e8 e1 0b 00 00       	call   800c50 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80006f:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800076:	00 00 00 
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
	...

0080007c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	8b 75 08             	mov    0x8(%ebp),%esi
  800084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800087:	e8 94 09 00 00       	call   800a20 <sys_getenvid>
  80008c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800091:	89 c2                	mov    %eax,%edx
  800093:	c1 e2 05             	shl    $0x5,%edx
  800096:	29 c2                	sub    %eax,%edx
  800098:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80009f:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 f6                	test   %esi,%esi
  8000a7:	7e 07                	jle    8000b0 <libmain+0x34>
		binaryname = argv[0];
  8000a9:	8b 03                	mov    (%ebx),%eax
  8000ab:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b0:	83 ec 08             	sub    $0x8,%esp
  8000b3:	53                   	push   %ebx
  8000b4:	56                   	push   %esi
  8000b5:	e8 a5 ff ff ff       	call   80005f <umain>

	// exit gracefully
	exit();
  8000ba:	e8 09 00 00 00       	call   8000c8 <exit>
}
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	e8 0a 09 00 00       	call   8009df <sys_env_destroy>
}
  8000d5:	c9                   	leave  
  8000d6:	c3                   	ret    
	...

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8000eb:	40                   	inc    %eax
  8000ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f3:	75 1a                	jne    80010f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	68 ff 00 00 00       	push   $0xff
  8000fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800100:	50                   	push   %eax
  800101:	e8 96 08 00 00       	call   80099c <sys_cputs>
		b->idx = 0;
  800106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010f:	ff 43 04             	incl   0x4(%ebx)
}
  800112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	68 d8 00 80 00       	push   $0x8000d8
  800146:	e8 49 01 00 00       	call   800294 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800154:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015a:	50                   	push   %eax
  80015b:	e8 3c 08 00 00       	call   80099c <sys_cputs>

	return b.cnt;
  800160:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	50                   	push   %eax
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	e8 9d ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	8b 75 10             	mov    0x10(%ebp),%esi
  800188:	8b 7d 14             	mov    0x14(%ebp),%edi
  80018b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018e:	8b 45 18             	mov    0x18(%ebp),%eax
  800191:	ba 00 00 00 00       	mov    $0x0,%edx
  800196:	39 fa                	cmp    %edi,%edx
  800198:	77 39                	ja     8001d3 <printnum+0x57>
  80019a:	72 04                	jb     8001a0 <printnum+0x24>
  80019c:	39 f0                	cmp    %esi,%eax
  80019e:	77 33                	ja     8001d3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	ff 75 20             	pushl  0x20(%ebp)
  8001a6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 18             	pushl  0x18(%ebp)
  8001ad:	8b 45 18             	mov    0x18(%ebp),%eax
  8001b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b5:	52                   	push   %edx
  8001b6:	50                   	push   %eax
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	e8 5a 0b 00 00       	call   800d18 <__udivdi3>
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	52                   	push   %edx
  8001c2:	50                   	push   %eax
  8001c3:	ff 75 0c             	pushl  0xc(%ebp)
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	e8 ae ff ff ff       	call   80017c <printnum>
  8001ce:	83 c4 20             	add    $0x20,%esp
  8001d1:	eb 19                	jmp    8001ec <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d3:	4b                   	dec    %ebx
  8001d4:	85 db                	test   %ebx,%ebx
  8001d6:	7e 14                	jle    8001ec <printnum+0x70>
  8001d8:	83 ec 08             	sub    $0x8,%esp
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	ff 75 20             	pushl  0x20(%ebp)
  8001e1:	ff 55 08             	call   *0x8(%ebp)
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	4b                   	dec    %ebx
  8001e8:	85 db                	test   %ebx,%ebx
  8001ea:	7f ec                	jg     8001d8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001fa:	83 ec 04             	sub    $0x4,%esp
  8001fd:	52                   	push   %edx
  8001fe:	50                   	push   %eax
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	e8 1e 0c 00 00       	call   800e24 <__umoddi3>
  800206:	83 c4 14             	add    $0x14,%esp
  800209:	0f be 80 18 11 80 00 	movsbl 0x801118(%eax),%eax
  800210:	50                   	push   %eax
  800211:	ff 55 08             	call   *0x8(%ebp)
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800222:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800225:	83 f8 01             	cmp    $0x1,%eax
  800228:	7e 0e                	jle    800238 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80022a:	8b 11                	mov    (%ecx),%edx
  80022c:	8d 42 08             	lea    0x8(%edx),%eax
  80022f:	89 01                	mov    %eax,(%ecx)
  800231:	8b 02                	mov    (%edx),%eax
  800233:	8b 52 04             	mov    0x4(%edx),%edx
  800236:	eb 22                	jmp    80025a <getuint+0x3e>
	else if (lflag)
  800238:	85 c0                	test   %eax,%eax
  80023a:	74 10                	je     80024c <getuint+0x30>
		return va_arg(*ap, unsigned long);
  80023c:	8b 11                	mov    (%ecx),%edx
  80023e:	8d 42 04             	lea    0x4(%edx),%eax
  800241:	89 01                	mov    %eax,(%ecx)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	ba 00 00 00 00       	mov    $0x0,%edx
  80024a:	eb 0e                	jmp    80025a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  80024c:	8b 11                	mov    (%ecx),%edx
  80024e:	8d 42 04             	lea    0x4(%edx),%eax
  800251:	89 01                	mov    %eax,(%ecx)
  800253:	8b 02                	mov    (%edx),%eax
  800255:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800265:	83 f8 01             	cmp    $0x1,%eax
  800268:	7e 0e                	jle    800278 <getint+0x1c>
		return va_arg(*ap, long long);
  80026a:	8b 11                	mov    (%ecx),%edx
  80026c:	8d 42 08             	lea    0x8(%edx),%eax
  80026f:	89 01                	mov    %eax,(%ecx)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	8b 52 04             	mov    0x4(%edx),%edx
  800276:	eb 1a                	jmp    800292 <getint+0x36>
	else if (lflag)
  800278:	85 c0                	test   %eax,%eax
  80027a:	74 0c                	je     800288 <getint+0x2c>
		return va_arg(*ap, long);
  80027c:	8b 01                	mov    (%ecx),%eax
  80027e:	8d 50 04             	lea    0x4(%eax),%edx
  800281:	89 11                	mov    %edx,(%ecx)
  800283:	8b 00                	mov    (%eax),%eax
  800285:	99                   	cltd   
  800286:	eb 0a                	jmp    800292 <getint+0x36>
	else
		return va_arg(*ap, int);
  800288:	8b 01                	mov    (%ecx),%eax
  80028a:	8d 50 04             	lea    0x4(%eax),%edx
  80028d:	89 11                	mov    %edx,(%ecx)
  80028f:	8b 00                	mov    (%eax),%eax
  800291:	99                   	cltd   
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 1c             	sub    $0x1c,%esp
  80029d:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8002a0:	0f b6 0b             	movzbl (%ebx),%ecx
  8002a3:	43                   	inc    %ebx
  8002a4:	83 f9 25             	cmp    $0x25,%ecx
  8002a7:	74 1e                	je     8002c7 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a9:	85 c9                	test   %ecx,%ecx
  8002ab:	0f 84 dc 02 00 00    	je     80058d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	51                   	push   %ecx
  8002b8:	ff 55 08             	call   *0x8(%ebp)
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	0f b6 0b             	movzbl (%ebx),%ecx
  8002c1:	43                   	inc    %ebx
  8002c2:	83 f9 25             	cmp    $0x25,%ecx
  8002c5:	75 e2                	jne    8002a9 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002c7:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8002cb:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8002d2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002d7:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8002dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	0f b6 0b             	movzbl (%ebx),%ecx
  8002e6:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8002e9:	43                   	inc    %ebx
  8002ea:	83 f8 55             	cmp    $0x55,%eax
  8002ed:	0f 87 75 02 00 00    	ja     800568 <vprintfmt+0x2d4>
  8002f3:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8002fe:	eb e3                	jmp    8002e3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800300:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800304:	eb dd                	jmp    8002e3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800306:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80030b:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80030e:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800312:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800315:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800318:	83 f8 09             	cmp    $0x9,%eax
  80031b:	77 28                	ja     800345 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031d:	43                   	inc    %ebx
  80031e:	eb eb                	jmp    80030b <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800320:	8b 55 14             	mov    0x14(%ebp),%edx
  800323:	8d 42 04             	lea    0x4(%edx),%eax
  800326:	89 45 14             	mov    %eax,0x14(%ebp)
  800329:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80032b:	eb 18                	jmp    800345 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  80032d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800331:	79 b0                	jns    8002e3 <vprintfmt+0x4f>
				width = 0;
  800333:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80033a:	eb a7                	jmp    8002e3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  80033c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800343:	eb 9e                	jmp    8002e3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800345:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800349:	79 98                	jns    8002e3 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80034b:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800353:	eb 8e                	jmp    8002e3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800355:	47                   	inc    %edi
			goto reswitch;
  800356:	eb 8b                	jmp    8002e3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800358:	83 ec 08             	sub    $0x8,%esp
  80035b:	ff 75 0c             	pushl  0xc(%ebp)
  80035e:	8b 55 14             	mov    0x14(%ebp),%edx
  800361:	8d 42 04             	lea    0x4(%edx),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
  800367:	ff 32                	pushl  (%edx)
  800369:	ff 55 08             	call   *0x8(%ebp)
			break;
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	e9 2c ff ff ff       	jmp    8002a0 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800374:	8b 55 14             	mov    0x14(%ebp),%edx
  800377:	8d 42 04             	lea    0x4(%edx),%eax
  80037a:	89 45 14             	mov    %eax,0x14(%ebp)
  80037d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80037f:	85 c0                	test   %eax,%eax
  800381:	79 02                	jns    800385 <vprintfmt+0xf1>
				err = -err;
  800383:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800385:	83 f8 0f             	cmp    $0xf,%eax
  800388:	7f 0b                	jg     800395 <vprintfmt+0x101>
  80038a:	8b 3c 85 60 11 80 00 	mov    0x801160(,%eax,4),%edi
  800391:	85 ff                	test   %edi,%edi
  800393:	75 19                	jne    8003ae <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800395:	50                   	push   %eax
  800396:	68 29 11 80 00       	push   $0x801129
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 ef 01 00 00       	call   800595 <printfmt>
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	e9 f2 fe ff ff       	jmp    8002a0 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8003ae:	57                   	push   %edi
  8003af:	68 32 11 80 00       	push   $0x801132
  8003b4:	ff 75 0c             	pushl  0xc(%ebp)
  8003b7:	ff 75 08             	pushl  0x8(%ebp)
  8003ba:	e8 d6 01 00 00       	call   800595 <printfmt>
  8003bf:	83 c4 10             	add    $0x10,%esp
			break;
  8003c2:	e9 d9 fe ff ff       	jmp    8002a0 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c7:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ca:	8d 42 04             	lea    0x4(%edx),%eax
  8003cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8003d0:	8b 3a                	mov    (%edx),%edi
  8003d2:	85 ff                	test   %edi,%edi
  8003d4:	75 05                	jne    8003db <vprintfmt+0x147>
				p = "(null)";
  8003d6:	bf 35 11 80 00       	mov    $0x801135,%edi
			if (width > 0 && padc != '-')
  8003db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003df:	7e 3b                	jle    80041c <vprintfmt+0x188>
  8003e1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8003e5:	74 35                	je     80041c <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	56                   	push   %esi
  8003eb:	57                   	push   %edi
  8003ec:	e8 58 02 00 00       	call   800649 <strnlen>
  8003f1:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003fb:	7e 1f                	jle    80041c <vprintfmt+0x188>
  8003fd:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800401:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	ff 75 0c             	pushl  0xc(%ebp)
  80040a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	ff 4d f0             	decl   -0x10(%ebp)
  800416:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80041a:	7f e8                	jg     800404 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80041c:	0f be 0f             	movsbl (%edi),%ecx
  80041f:	47                   	inc    %edi
  800420:	85 c9                	test   %ecx,%ecx
  800422:	74 44                	je     800468 <vprintfmt+0x1d4>
  800424:	85 f6                	test   %esi,%esi
  800426:	78 03                	js     80042b <vprintfmt+0x197>
  800428:	4e                   	dec    %esi
  800429:	78 3d                	js     800468 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  80042b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80042f:	74 18                	je     800449 <vprintfmt+0x1b5>
  800431:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800434:	83 f8 5e             	cmp    $0x5e,%eax
  800437:	76 10                	jbe    800449 <vprintfmt+0x1b5>
					putch('?', putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	ff 75 0c             	pushl  0xc(%ebp)
  80043f:	6a 3f                	push   $0x3f
  800441:	ff 55 08             	call   *0x8(%ebp)
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	eb 0d                	jmp    800456 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 0c             	pushl  0xc(%ebp)
  80044f:	51                   	push   %ecx
  800450:	ff 55 08             	call   *0x8(%ebp)
  800453:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800456:	ff 4d f0             	decl   -0x10(%ebp)
  800459:	0f be 0f             	movsbl (%edi),%ecx
  80045c:	47                   	inc    %edi
  80045d:	85 c9                	test   %ecx,%ecx
  80045f:	74 07                	je     800468 <vprintfmt+0x1d4>
  800461:	85 f6                	test   %esi,%esi
  800463:	78 c6                	js     80042b <vprintfmt+0x197>
  800465:	4e                   	dec    %esi
  800466:	79 c3                	jns    80042b <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800468:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80046c:	0f 8e 2e fe ff ff    	jle    8002a0 <vprintfmt+0xc>
				putch(' ', putdat);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 0c             	pushl  0xc(%ebp)
  800478:	6a 20                	push   $0x20
  80047a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	ff 4d f0             	decl   -0x10(%ebp)
  800483:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800487:	7f e9                	jg     800472 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800489:	e9 12 fe ff ff       	jmp    8002a0 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80048e:	57                   	push   %edi
  80048f:	8d 45 14             	lea    0x14(%ebp),%eax
  800492:	50                   	push   %eax
  800493:	e8 c4 fd ff ff       	call   80025c <getint>
  800498:	89 c6                	mov    %eax,%esi
  80049a:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  80049c:	83 c4 08             	add    $0x8,%esp
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	79 15                	jns    8004b8 <vprintfmt+0x224>
				putch('-', putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	ff 75 0c             	pushl  0xc(%ebp)
  8004a9:	6a 2d                	push   $0x2d
  8004ab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004ae:	f7 de                	neg    %esi
  8004b0:	83 d7 00             	adc    $0x0,%edi
  8004b3:	f7 df                	neg    %edi
  8004b5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004b8:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004bd:	eb 76                	jmp    800535 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004bf:	57                   	push   %edi
  8004c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	e8 53 fd ff ff       	call   80021c <getuint>
  8004c9:	89 c6                	mov    %eax,%esi
  8004cb:	89 d7                	mov    %edx,%edi
			base = 10;
  8004cd:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004d2:	83 c4 08             	add    $0x8,%esp
  8004d5:	eb 5e                	jmp    800535 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004d7:	57                   	push   %edi
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004db:	50                   	push   %eax
  8004dc:	e8 3b fd ff ff       	call   80021c <getuint>
  8004e1:	89 c6                	mov    %eax,%esi
  8004e3:	89 d7                	mov    %edx,%edi
			base = 8;
  8004e5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8004ea:	83 c4 08             	add    $0x8,%esp
  8004ed:	eb 46                	jmp    800535 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	ff 75 0c             	pushl  0xc(%ebp)
  8004f5:	6a 30                	push   $0x30
  8004f7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8004fa:	83 c4 08             	add    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	6a 78                	push   $0x78
  800502:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800505:	8b 55 14             	mov    0x14(%ebp),%edx
  800508:	8d 42 04             	lea    0x4(%edx),%eax
  80050b:	89 45 14             	mov    %eax,0x14(%ebp)
  80050e:	8b 32                	mov    (%edx),%esi
  800510:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800515:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 16                	jmp    800535 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80051f:	57                   	push   %edi
  800520:	8d 45 14             	lea    0x14(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	e8 f3 fc ff ff       	call   80021c <getuint>
  800529:	89 c6                	mov    %eax,%esi
  80052b:	89 d7                	mov    %edx,%edi
			base = 16;
  80052d:	ba 10 00 00 00       	mov    $0x10,%edx
  800532:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800535:	83 ec 04             	sub    $0x4,%esp
  800538:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 f0             	pushl  -0x10(%ebp)
  800540:	52                   	push   %edx
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 2e fc ff ff       	call   80017c <printnum>
			break;
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	e9 4a fd ff ff       	jmp    8002a0 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 0c             	pushl  0xc(%ebp)
  80055c:	51                   	push   %ecx
  80055d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	e9 38 fd ff ff       	jmp    8002a0 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	6a 25                	push   $0x25
  800570:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800573:	4b                   	dec    %ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80057b:	0f 84 1f fd ff ff    	je     8002a0 <vprintfmt+0xc>
  800581:	4b                   	dec    %ebx
  800582:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800586:	75 f9                	jne    800581 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800588:	e9 13 fd ff ff       	jmp    8002a0 <vprintfmt+0xc>
		}
	}
}
  80058d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800590:	5b                   	pop    %ebx
  800591:	5e                   	pop    %esi
  800592:	5f                   	pop    %edi
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80059b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80059e:	50                   	push   %eax
  80059f:	ff 75 10             	pushl  0x10(%ebp)
  8005a2:	ff 75 0c             	pushl  0xc(%ebp)
  8005a5:	ff 75 08             	pushl  0x8(%ebp)
  8005a8:	e8 e7 fc ff ff       	call   800294 <vprintfmt>
	va_end(ap);
}
  8005ad:	c9                   	leave  
  8005ae:	c3                   	ret    

008005af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005af:	55                   	push   %ebp
  8005b0:	89 e5                	mov    %esp,%ebp
  8005b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005b5:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005b8:	8b 0a                	mov    (%edx),%ecx
  8005ba:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005bd:	73 07                	jae    8005c6 <sprintputch+0x17>
		*b->buf++ = ch;
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	88 01                	mov    %al,(%ecx)
  8005c4:	ff 02                	incl   (%edx)
}
  8005c6:	c9                   	leave  
  8005c7:	c3                   	ret    

008005c8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005c8:	55                   	push   %ebp
  8005c9:	89 e5                	mov    %esp,%ebp
  8005cb:	83 ec 18             	sub    $0x18,%esp
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005d4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005d7:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8005db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	74 04                	je     8005ed <vsnprintf+0x25>
  8005e9:	85 c9                	test   %ecx,%ecx
  8005eb:	7f 07                	jg     8005f4 <vsnprintf+0x2c>
		return -E_INVAL;
  8005ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8005f2:	eb 1d                	jmp    800611 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005f4:	ff 75 14             	pushl  0x14(%ebp)
  8005f7:	ff 75 10             	pushl  0x10(%ebp)
  8005fa:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8005fd:	50                   	push   %eax
  8005fe:	68 af 05 80 00       	push   $0x8005af
  800603:	e8 8c fc ff ff       	call   800294 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800608:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80060b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80060e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800611:	c9                   	leave  
  800612:	c3                   	ret    

00800613 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800613:	55                   	push   %ebp
  800614:	89 e5                	mov    %esp,%ebp
  800616:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800619:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80061c:	50                   	push   %eax
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	ff 75 0c             	pushl  0xc(%ebp)
  800623:	ff 75 08             	pushl  0x8(%ebp)
  800626:	e8 9d ff ff ff       	call   8005c8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80062b:	c9                   	leave  
  80062c:	c3                   	ret    
  80062d:	00 00                	add    %al,(%eax)
	...

00800630 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	80 3a 00             	cmpb   $0x0,(%edx)
  80063e:	74 07                	je     800647 <strlen+0x17>
		n++;
  800640:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800641:	42                   	inc    %edx
  800642:	80 3a 00             	cmpb   $0x0,(%edx)
  800645:	75 f9                	jne    800640 <strlen+0x10>
		n++;
	return n;
}
  800647:	c9                   	leave  
  800648:	c3                   	ret    

00800649 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800652:	b8 00 00 00 00       	mov    $0x0,%eax
  800657:	85 d2                	test   %edx,%edx
  800659:	74 0f                	je     80066a <strnlen+0x21>
  80065b:	80 39 00             	cmpb   $0x0,(%ecx)
  80065e:	74 0a                	je     80066a <strnlen+0x21>
		n++;
  800660:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800661:	41                   	inc    %ecx
  800662:	4a                   	dec    %edx
  800663:	74 05                	je     80066a <strnlen+0x21>
  800665:	80 39 00             	cmpb   $0x0,(%ecx)
  800668:	75 f6                	jne    800660 <strnlen+0x17>
		n++;
	return n;
}
  80066a:	c9                   	leave  
  80066b:	c3                   	ret    

0080066c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	53                   	push   %ebx
  800670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800673:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800676:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800678:	8a 02                	mov    (%edx),%al
  80067a:	42                   	inc    %edx
  80067b:	88 01                	mov    %al,(%ecx)
  80067d:	41                   	inc    %ecx
  80067e:	84 c0                	test   %al,%al
  800680:	75 f6                	jne    800678 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800682:	89 d8                	mov    %ebx,%eax
  800684:	5b                   	pop    %ebx
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	53                   	push   %ebx
  80068b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80068e:	53                   	push   %ebx
  80068f:	e8 9c ff ff ff       	call   800630 <strlen>
	strcpy(dst + len, src);
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80069a:	50                   	push   %eax
  80069b:	e8 cc ff ff ff       	call   80066c <strcpy>
	return dst;
}
  8006a0:	89 d8                	mov    %ebx,%eax
  8006a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	57                   	push   %edi
  8006ab:	56                   	push   %esi
  8006ac:	53                   	push   %ebx
  8006ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b3:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006b6:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bd:	39 f3                	cmp    %esi,%ebx
  8006bf:	73 10                	jae    8006d1 <strncpy+0x2a>
		*dst++ = *src;
  8006c1:	8a 02                	mov    (%edx),%al
  8006c3:	88 01                	mov    %al,(%ecx)
  8006c5:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006c6:	80 3a 01             	cmpb   $0x1,(%edx)
  8006c9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006cc:	43                   	inc    %ebx
  8006cd:	39 f3                	cmp    %esi,%ebx
  8006cf:	72 f0                	jb     8006c1 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006d1:	89 f8                	mov    %edi,%eax
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	56                   	push   %esi
  8006dc:	53                   	push   %ebx
  8006dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8006e6:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	74 19                	je     800705 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006ec:	4a                   	dec    %edx
  8006ed:	74 13                	je     800702 <strlcpy+0x2a>
  8006ef:	80 39 00             	cmpb   $0x0,(%ecx)
  8006f2:	74 0e                	je     800702 <strlcpy+0x2a>
  8006f4:	8a 01                	mov    (%ecx),%al
  8006f6:	41                   	inc    %ecx
  8006f7:	88 03                	mov    %al,(%ebx)
  8006f9:	43                   	inc    %ebx
  8006fa:	4a                   	dec    %edx
  8006fb:	74 05                	je     800702 <strlcpy+0x2a>
  8006fd:	80 39 00             	cmpb   $0x0,(%ecx)
  800700:	75 f2                	jne    8006f4 <strlcpy+0x1c>
		*dst = '\0';
  800702:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800705:	89 d8                	mov    %ebx,%eax
  800707:	29 f0                	sub    %esi,%eax
}
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	8b 55 08             	mov    0x8(%ebp),%edx
  800713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800716:	80 3a 00             	cmpb   $0x0,(%edx)
  800719:	74 13                	je     80072e <strcmp+0x21>
  80071b:	8a 02                	mov    (%edx),%al
  80071d:	3a 01                	cmp    (%ecx),%al
  80071f:	75 0d                	jne    80072e <strcmp+0x21>
  800721:	42                   	inc    %edx
  800722:	41                   	inc    %ecx
  800723:	80 3a 00             	cmpb   $0x0,(%edx)
  800726:	74 06                	je     80072e <strcmp+0x21>
  800728:	8a 02                	mov    (%edx),%al
  80072a:	3a 01                	cmp    (%ecx),%al
  80072c:	74 f3                	je     800721 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80072e:	0f b6 02             	movzbl (%edx),%eax
  800731:	0f b6 11             	movzbl (%ecx),%edx
  800734:	29 d0                	sub    %edx,%eax
}
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
  80073f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800742:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800745:	85 c9                	test   %ecx,%ecx
  800747:	74 1f                	je     800768 <strncmp+0x30>
  800749:	80 3a 00             	cmpb   $0x0,(%edx)
  80074c:	74 16                	je     800764 <strncmp+0x2c>
  80074e:	8a 02                	mov    (%edx),%al
  800750:	3a 03                	cmp    (%ebx),%al
  800752:	75 10                	jne    800764 <strncmp+0x2c>
  800754:	42                   	inc    %edx
  800755:	43                   	inc    %ebx
  800756:	49                   	dec    %ecx
  800757:	74 0f                	je     800768 <strncmp+0x30>
  800759:	80 3a 00             	cmpb   $0x0,(%edx)
  80075c:	74 06                	je     800764 <strncmp+0x2c>
  80075e:	8a 02                	mov    (%edx),%al
  800760:	3a 03                	cmp    (%ebx),%al
  800762:	74 f0                	je     800754 <strncmp+0x1c>
	if (n == 0)
  800764:	85 c9                	test   %ecx,%ecx
  800766:	75 07                	jne    80076f <strncmp+0x37>
		return 0;
  800768:	b8 00 00 00 00       	mov    $0x0,%eax
  80076d:	eb 0a                	jmp    800779 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80076f:	0f b6 12             	movzbl (%edx),%edx
  800772:	0f b6 03             	movzbl (%ebx),%eax
  800775:	29 c2                	sub    %eax,%edx
  800777:	89 d0                	mov    %edx,%eax
}
  800779:	5b                   	pop    %ebx
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800785:	80 38 00             	cmpb   $0x0,(%eax)
  800788:	74 0a                	je     800794 <strchr+0x18>
		if (*s == c)
  80078a:	38 10                	cmp    %dl,(%eax)
  80078c:	74 0b                	je     800799 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80078e:	40                   	inc    %eax
  80078f:	80 38 00             	cmpb   $0x0,(%eax)
  800792:	75 f6                	jne    80078a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007a4:	80 38 00             	cmpb   $0x0,(%eax)
  8007a7:	74 0a                	je     8007b3 <strfind+0x18>
		if (*s == c)
  8007a9:	38 10                	cmp    %dl,(%eax)
  8007ab:	74 06                	je     8007b3 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007ad:	40                   	inc    %eax
  8007ae:	80 38 00             	cmpb   $0x0,(%eax)
  8007b1:	75 f6                	jne    8007a9 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	57                   	push   %edi
  8007b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8007bf:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8007c1:	85 c9                	test   %ecx,%ecx
  8007c3:	74 40                	je     800805 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007cb:	75 30                	jne    8007fd <memset+0x48>
  8007cd:	f6 c1 03             	test   $0x3,%cl
  8007d0:	75 2b                	jne    8007fd <memset+0x48>
		c &= 0xFF;
  8007d2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	c1 e0 18             	shl    $0x18,%eax
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e2:	c1 e2 10             	shl    $0x10,%edx
  8007e5:	09 d0                	or     %edx,%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	c1 e2 08             	shl    $0x8,%edx
  8007ed:	09 d0                	or     %edx,%eax
  8007ef:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8007f2:	c1 e9 02             	shr    $0x2,%ecx
  8007f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f8:	fc                   	cld    
  8007f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8007fb:	eb 06                	jmp    800803 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800800:	fc                   	cld    
  800801:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800803:	89 f8                	mov    %edi,%eax
}
  800805:	5f                   	pop    %edi
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	57                   	push   %edi
  80080c:	56                   	push   %esi
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800813:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800816:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800818:	39 c6                	cmp    %eax,%esi
  80081a:	73 34                	jae    800850 <memmove+0x48>
  80081c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80081f:	39 c2                	cmp    %eax,%edx
  800821:	76 2d                	jbe    800850 <memmove+0x48>
		s += n;
  800823:	89 d6                	mov    %edx,%esi
		d += n;
  800825:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800828:	f6 c2 03             	test   $0x3,%dl
  80082b:	75 1b                	jne    800848 <memmove+0x40>
  80082d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800833:	75 13                	jne    800848 <memmove+0x40>
  800835:	f6 c1 03             	test   $0x3,%cl
  800838:	75 0e                	jne    800848 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80083a:	83 ef 04             	sub    $0x4,%edi
  80083d:	83 ee 04             	sub    $0x4,%esi
  800840:	c1 e9 02             	shr    $0x2,%ecx
  800843:	fd                   	std    
  800844:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800846:	eb 05                	jmp    80084d <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800848:	4f                   	dec    %edi
  800849:	4e                   	dec    %esi
  80084a:	fd                   	std    
  80084b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80084d:	fc                   	cld    
  80084e:	eb 20                	jmp    800870 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800850:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800856:	75 15                	jne    80086d <memmove+0x65>
  800858:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085e:	75 0d                	jne    80086d <memmove+0x65>
  800860:	f6 c1 03             	test   $0x3,%cl
  800863:	75 08                	jne    80086d <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800865:	c1 e9 02             	shr    $0x2,%ecx
  800868:	fc                   	cld    
  800869:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80086b:	eb 03                	jmp    800870 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80086d:	fc                   	cld    
  80086e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800870:	5e                   	pop    %esi
  800871:	5f                   	pop    %edi
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 83 ff ff ff       	call   800808 <memmove>
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800891:	8b 55 10             	mov    0x10(%ebp),%edx
  800894:	4a                   	dec    %edx
  800895:	83 fa ff             	cmp    $0xffffffff,%edx
  800898:	74 1a                	je     8008b4 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80089a:	8a 01                	mov    (%ecx),%al
  80089c:	3a 03                	cmp    (%ebx),%al
  80089e:	74 0c                	je     8008ac <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  8008a0:	0f b6 d0             	movzbl %al,%edx
  8008a3:	0f b6 03             	movzbl (%ebx),%eax
  8008a6:	29 c2                	sub    %eax,%edx
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	eb 0d                	jmp    8008b9 <memcmp+0x32>
		s1++, s2++;
  8008ac:	41                   	inc    %ecx
  8008ad:	43                   	inc    %ebx
  8008ae:	4a                   	dec    %edx
  8008af:	83 fa ff             	cmp    $0xffffffff,%edx
  8008b2:	75 e6                	jne    80089a <memcmp+0x13>
	}

	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008ca:	39 d0                	cmp    %edx,%eax
  8008cc:	73 09                	jae    8008d7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008ce:	38 08                	cmp    %cl,(%eax)
  8008d0:	74 05                	je     8008d7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008d2:	40                   	inc    %eax
  8008d3:	39 d0                	cmp    %edx,%eax
  8008d5:	72 f7                	jb     8008ce <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    

008008d9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8008e8:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8008ed:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008f2:	80 3a 20             	cmpb   $0x20,(%edx)
  8008f5:	74 05                	je     8008fc <strtol+0x23>
  8008f7:	80 3a 09             	cmpb   $0x9,(%edx)
  8008fa:	75 0b                	jne    800907 <strtol+0x2e>
  8008fc:	42                   	inc    %edx
  8008fd:	80 3a 20             	cmpb   $0x20,(%edx)
  800900:	74 fa                	je     8008fc <strtol+0x23>
  800902:	80 3a 09             	cmpb   $0x9,(%edx)
  800905:	74 f5                	je     8008fc <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800907:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80090a:	75 03                	jne    80090f <strtol+0x36>
		s++;
  80090c:	42                   	inc    %edx
  80090d:	eb 0b                	jmp    80091a <strtol+0x41>
	else if (*s == '-')
  80090f:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800912:	75 06                	jne    80091a <strtol+0x41>
		s++, neg = 1;
  800914:	42                   	inc    %edx
  800915:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80091a:	85 c9                	test   %ecx,%ecx
  80091c:	74 05                	je     800923 <strtol+0x4a>
  80091e:	83 f9 10             	cmp    $0x10,%ecx
  800921:	75 15                	jne    800938 <strtol+0x5f>
  800923:	80 3a 30             	cmpb   $0x30,(%edx)
  800926:	75 10                	jne    800938 <strtol+0x5f>
  800928:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80092c:	75 0a                	jne    800938 <strtol+0x5f>
		s += 2, base = 16;
  80092e:	83 c2 02             	add    $0x2,%edx
  800931:	b9 10 00 00 00       	mov    $0x10,%ecx
  800936:	eb 14                	jmp    80094c <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	75 10                	jne    80094c <strtol+0x73>
  80093c:	80 3a 30             	cmpb   $0x30,(%edx)
  80093f:	75 05                	jne    800946 <strtol+0x6d>
		s++, base = 8;
  800941:	42                   	inc    %edx
  800942:	b1 08                	mov    $0x8,%cl
  800944:	eb 06                	jmp    80094c <strtol+0x73>
	else if (base == 0)
  800946:	85 c9                	test   %ecx,%ecx
  800948:	75 02                	jne    80094c <strtol+0x73>
		base = 10;
  80094a:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80094c:	8a 02                	mov    (%edx),%al
  80094e:	83 e8 30             	sub    $0x30,%eax
  800951:	3c 09                	cmp    $0x9,%al
  800953:	77 08                	ja     80095d <strtol+0x84>
			dig = *s - '0';
  800955:	0f be 02             	movsbl (%edx),%eax
  800958:	83 e8 30             	sub    $0x30,%eax
  80095b:	eb 20                	jmp    80097d <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  80095d:	8a 02                	mov    (%edx),%al
  80095f:	83 e8 61             	sub    $0x61,%eax
  800962:	3c 19                	cmp    $0x19,%al
  800964:	77 08                	ja     80096e <strtol+0x95>
			dig = *s - 'a' + 10;
  800966:	0f be 02             	movsbl (%edx),%eax
  800969:	83 e8 57             	sub    $0x57,%eax
  80096c:	eb 0f                	jmp    80097d <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  80096e:	8a 02                	mov    (%edx),%al
  800970:	83 e8 41             	sub    $0x41,%eax
  800973:	3c 19                	cmp    $0x19,%al
  800975:	77 12                	ja     800989 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800977:	0f be 02             	movsbl (%edx),%eax
  80097a:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  80097d:	39 c8                	cmp    %ecx,%eax
  80097f:	7d 08                	jge    800989 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800981:	42                   	inc    %edx
  800982:	0f af d9             	imul   %ecx,%ebx
  800985:	01 c3                	add    %eax,%ebx
  800987:	eb c3                	jmp    80094c <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800989:	85 f6                	test   %esi,%esi
  80098b:	74 02                	je     80098f <strtol+0xb6>
		*endptr = (char *) s;
  80098d:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80098f:	89 d8                	mov    %ebx,%eax
  800991:	85 ff                	test   %edi,%edi
  800993:	74 02                	je     800997 <strtol+0xbe>
  800995:	f7 d8                	neg    %eax
}
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 04             	sub    $0x4,%esp
  8009a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009b0:	89 f8                	mov    %edi,%eax
  8009b2:	89 fb                	mov    %edi,%ebx
  8009b4:	89 fe                	mov    %edi,%esi
  8009b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009b8:	83 c4 04             	add    $0x4,%esp
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5f                   	pop    %edi
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009d0:	89 fa                	mov    %edi,%edx
  8009d2:	89 f9                	mov    %edi,%ecx
  8009d4:	89 fb                	mov    %edi,%ebx
  8009d6:	89 fe                	mov    %edi,%esi
  8009d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	83 ec 0c             	sub    $0xc,%esp
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8009f0:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009f5:	89 f9                	mov    %edi,%ecx
  8009f7:	89 fb                	mov    %edi,%ebx
  8009f9:	89 fe                	mov    %edi,%esi
  8009fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	7e 17                	jle    800a18 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a01:	83 ec 0c             	sub    $0xc,%esp
  800a04:	50                   	push   %eax
  800a05:	6a 03                	push   $0x3
  800a07:	68 f8 12 80 00       	push   $0x8012f8
  800a0c:	6a 23                	push   $0x23
  800a0e:	68 15 13 80 00       	push   $0x801315
  800a13:	e8 b4 02 00 00       	call   800ccc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5f                   	pop    %edi
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a26:	b8 02 00 00 00       	mov    $0x2,%eax
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a30:	89 fa                	mov    %edi,%edx
  800a32:	89 f9                	mov    %edi,%ecx
  800a34:	89 fb                	mov    %edi,%ebx
  800a36:	89 fe                	mov    %edi,%esi
  800a38:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <sys_yield>:

void
sys_yield(void)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4f:	89 fa                	mov    %edi,%edx
  800a51:	89 f9                	mov    %edi,%ecx
  800a53:	89 fb                	mov    %edi,%ebx
  800a55:	89 fe                	mov    %edi,%esi
  800a57:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a70:	b8 04 00 00 00       	mov    $0x4,%eax
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	89 fe                	mov    %edi,%esi
  800a7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a7e:	85 c0                	test   %eax,%eax
  800a80:	7e 17                	jle    800a99 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a82:	83 ec 0c             	sub    $0xc,%esp
  800a85:	50                   	push   %eax
  800a86:	6a 04                	push   $0x4
  800a88:	68 f8 12 80 00       	push   $0x8012f8
  800a8d:	6a 23                	push   $0x23
  800a8f:	68 15 13 80 00       	push   $0x801315
  800a94:	e8 33 02 00 00       	call   800ccc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 0c             	sub    $0xc,%esp
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ab3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ab6:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab9:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	7e 17                	jle    800adb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac4:	83 ec 0c             	sub    $0xc,%esp
  800ac7:	50                   	push   %eax
  800ac8:	6a 05                	push   $0x5
  800aca:	68 f8 12 80 00       	push   $0x8012f8
  800acf:	6a 23                	push   $0x23
  800ad1:	68 15 13 80 00       	push   $0x801315
  800ad6:	e8 f1 01 00 00       	call   800ccc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800af2:	b8 06 00 00 00       	mov    $0x6,%eax
  800af7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	89 fb                	mov    %edi,%ebx
  800afe:	89 fe                	mov    %edi,%esi
  800b00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b02:	85 c0                	test   %eax,%eax
  800b04:	7e 17                	jle    800b1d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	50                   	push   %eax
  800b0a:	6a 06                	push   $0x6
  800b0c:	68 f8 12 80 00       	push   $0x8012f8
  800b11:	6a 23                	push   $0x23
  800b13:	68 15 13 80 00       	push   $0x801315
  800b18:	e8 af 01 00 00       	call   800ccc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b34:	b8 08 00 00 00       	mov    $0x8,%eax
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	89 fb                	mov    %edi,%ebx
  800b40:	89 fe                	mov    %edi,%esi
  800b42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b44:	85 c0                	test   %eax,%eax
  800b46:	7e 17                	jle    800b5f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 08                	push   $0x8
  800b4e:	68 f8 12 80 00       	push   $0x8012f8
  800b53:	6a 23                	push   $0x23
  800b55:	68 15 13 80 00       	push   $0x801315
  800b5a:	e8 6d 01 00 00       	call   800ccc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b76:	b8 09 00 00 00       	mov    $0x9,%eax
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	89 fb                	mov    %edi,%ebx
  800b82:	89 fe                	mov    %edi,%esi
  800b84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 17                	jle    800ba1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 09                	push   $0x9
  800b90:	68 f8 12 80 00       	push   $0x8012f8
  800b95:	6a 23                	push   $0x23
  800b97:	68 15 13 80 00       	push   $0x801315
  800b9c:	e8 2b 01 00 00       	call   800ccc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbd:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	89 fb                	mov    %edi,%ebx
  800bc4:	89 fe                	mov    %edi,%esi
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 17                	jle    800be3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 0a                	push   $0xa
  800bd2:	68 f8 12 80 00       	push   $0x8012f8
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 15 13 80 00       	push   $0x801315
  800bde:	e8 e9 00 00 00       	call   800ccc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfa:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bfd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c02:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c1f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	89 f9                	mov    %edi,%ecx
  800c26:	89 fb                	mov    %edi,%ebx
  800c28:	89 fe                	mov    %edi,%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 0d                	push   $0xd
  800c36:	68 f8 12 80 00       	push   $0x8012f8
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 15 13 80 00       	push   $0x801315
  800c42:	e8 85 00 00 00       	call   800ccc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    
	...

00800c50 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c56:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c5d:	75 35                	jne    800c94 <set_pgfault_handler+0x44>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);
  800c5f:	83 ec 04             	sub    $0x4,%esp
  800c62:	6a 07                	push   $0x7
  800c64:	68 00 f0 bf ee       	push   $0xeebff000
  800c69:	83 ec 04             	sub    $0x4,%esp
  800c6c:	e8 af fd ff ff       	call   800a20 <sys_getenvid>
  800c71:	89 04 24             	mov    %eax,(%esp)
  800c74:	e8 e5 fd ff ff       	call   800a5e <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800c79:	83 c4 08             	add    $0x8,%esp
  800c7c:	68 a0 0c 80 00       	push   $0x800ca0
  800c81:	83 ec 04             	sub    $0x4,%esp
  800c84:	e8 97 fd ff ff       	call   800a20 <sys_getenvid>
  800c89:	89 04 24             	mov    %eax,(%esp)
  800c8c:	e8 18 ff ff ff       	call   800ba9 <sys_env_set_pgfault_upcall>
  800c91:	83 c4 10             	add    $0x10,%esp
//		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	a3 08 20 80 00       	mov    %eax,0x802008
//	cprintf("_pgfault_upcall: %08x\n", thisenv->env_pgfault_upcall);
//	cprintf("_pgfault_handler is %08x\n", _pgfault_handler);
}
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    
	...

00800ca0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTrapframe
  800ca0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ca1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ca6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ca8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  800cab:	89 e3                	mov    %esp,%ebx

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp
	movl 48(%esp), %ecx
  800cad:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// trap-time eip
	movl 40(%esp), %edx 
  800cb1:	8b 54 24 28          	mov    0x28(%esp),%edx
	// switch to trap-time esp 
	movl %ecx, %esp 
  800cb5:	89 cc                	mov    %ecx,%esp
	// push trap-time eip to trap-time stack 
	pushl %edx 
  800cb7:	52                   	push   %edx
	// return to user exception stack 
	movl %ebx, %esp 
  800cb8:	89 dc                	mov    %ebx,%esp
	// update the trap-time esp stored in exception stack(because of pushed eip
	subl $4, %ecx
  800cba:	83 e9 04             	sub    $0x4,%ecx
	movl %ecx, 48(%esp)
  800cbd:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// restore general registars, ignoring fault_va & err
	addl $8, %esp
  800cc1:	83 c4 08             	add    $0x8,%esp
	popal
  800cc4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// skipping trap-time eip 
	addl $4, %esp
  800cc5:	83 c4 04             	add    $0x4,%esp
	// restore eflags
	popfl
  800cc8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800cc9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  800cca:	c3                   	ret    
	...

00800ccc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800cd3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cd6:	ff 75 0c             	pushl  0xc(%ebp)
  800cd9:	ff 75 08             	pushl  0x8(%ebp)
  800cdc:	ff 35 00 20 80 00    	pushl  0x802000
  800ce2:	83 ec 08             	sub    $0x8,%esp
  800ce5:	e8 36 fd ff ff       	call   800a20 <sys_getenvid>
  800cea:	83 c4 08             	add    $0x8,%esp
  800ced:	50                   	push   %eax
  800cee:	68 24 13 80 00       	push   $0x801324
  800cf3:	e8 70 f4 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cf8:	83 c4 18             	add    $0x18,%esp
  800cfb:	53                   	push   %ebx
  800cfc:	ff 75 10             	pushl  0x10(%ebp)
  800cff:	e8 13 f4 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  800d04:	c7 04 24 fa 0f 80 00 	movl   $0x800ffa,(%esp)
  800d0b:	e8 58 f4 ff ff       	call   800168 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800d10:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800d13:	cc                   	int3   
  800d14:	eb fd                	jmp    800d13 <_panic+0x47>
	...

00800d18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	83 ec 14             	sub    $0x14,%esp
  800d20:	8b 55 14             	mov    0x14(%ebp),%edx
  800d23:	8b 75 08             	mov    0x8(%ebp),%esi
  800d26:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d29:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d2c:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d2e:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800d34:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d37:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d39:	75 11                	jne    800d4c <__udivdi3+0x34>
    {
      if (d0 > n1)
  800d3b:	39 f8                	cmp    %edi,%eax
  800d3d:	76 4d                	jbe    800d8c <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3f:	89 fa                	mov    %edi,%edx
  800d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d44:	f7 75 e4             	divl   -0x1c(%ebp)
  800d47:	89 c7                	mov    %eax,%edi
  800d49:	eb 09                	jmp    800d54 <__udivdi3+0x3c>
  800d4b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d4c:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800d4f:	76 17                	jbe    800d68 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800d51:	31 ff                	xor    %edi,%edi
  800d53:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800d54:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5b:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5e:	83 c4 14             	add    $0x14,%esp
  800d61:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d62:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d64:	5f                   	pop    %edi
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    
  800d67:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d68:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800d6c:	89 c7                	mov    %eax,%edi
  800d6e:	83 f7 1f             	xor    $0x1f,%edi
  800d71:	75 4d                	jne    800dc0 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d73:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800d76:	77 0a                	ja     800d82 <__udivdi3+0x6a>
  800d78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800d7b:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d7d:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800d80:	72 d2                	jb     800d54 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800d82:	bf 01 00 00 00       	mov    $0x1,%edi
  800d87:	eb cb                	jmp    800d54 <__udivdi3+0x3c>
  800d89:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	75 0e                	jne    800da1 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d93:	b8 01 00 00 00       	mov    $0x1,%eax
  800d98:	31 c9                	xor    %ecx,%ecx
  800d9a:	31 d2                	xor    %edx,%edx
  800d9c:	f7 f1                	div    %ecx
  800d9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800da1:	89 f0                	mov    %esi,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 75 e4             	divl   -0x1c(%ebp)
  800da8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dae:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db1:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db4:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db7:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db9:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dba:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dbc:	5f                   	pop    %edi
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    
  800dbf:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800dc0:	b8 20 00 00 00       	mov    $0x20,%eax
  800dc5:	29 f8                	sub    %edi,%eax
  800dc7:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800dca:	89 f9                	mov    %edi,%ecx
  800dcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dcf:	d3 e2                	shl    %cl,%edx
  800dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd4:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800ddb:	89 f9                	mov    %edi,%ecx
  800ddd:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800de0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800de3:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800de6:	89 f2                	mov    %esi,%edx
  800de8:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800dea:	89 f9                	mov    %edi,%ecx
  800dec:	d3 e6                	shl    %cl,%esi
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800df4:	d3 e8                	shr    %cl,%eax
  800df6:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800df8:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dfa:	89 f0                	mov    %esi,%eax
  800dfc:	f7 75 f4             	divl   -0xc(%ebp)
  800dff:	89 d6                	mov    %edx,%esi
  800e01:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e03:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e09:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e0b:	39 f2                	cmp    %esi,%edx
  800e0d:	77 0f                	ja     800e1e <__udivdi3+0x106>
  800e0f:	0f 85 3f ff ff ff    	jne    800d54 <__udivdi3+0x3c>
  800e15:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e18:	0f 86 36 ff ff ff    	jbe    800d54 <__udivdi3+0x3c>
		{
		  q0--;
  800e1e:	4f                   	dec    %edi
  800e1f:	e9 30 ff ff ff       	jmp    800d54 <__udivdi3+0x3c>

00800e24 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	83 ec 30             	sub    $0x30,%esp
  800e2c:	8b 55 14             	mov    0x14(%ebp),%edx
  800e2f:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800e32:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e34:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e37:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e39:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e3f:	85 ff                	test   %edi,%edi
  800e41:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e4f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e52:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800e55:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e58:	75 3e                	jne    800e98 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800e5a:	39 d6                	cmp    %edx,%esi
  800e5c:	0f 86 a2 00 00 00    	jbe    800f04 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e62:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e64:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e67:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e69:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e6c:	74 1b                	je     800e89 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800e6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e71:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800e74:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e81:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e84:	89 10                	mov    %edx,(%eax)
  800e86:	89 48 04             	mov    %ecx,0x4(%eax)
  800e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e8f:	83 c4 30             	add    $0x30,%esp
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    
  800e96:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e98:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800e9b:	76 1f                	jbe    800ebc <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800ea0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ea3:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800ea6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800ea9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800eb2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb5:	83 c4 30             	add    $0x30,%esp
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ebc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ebf:	83 f0 1f             	xor    $0x1f,%eax
  800ec2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ec5:	75 61                	jne    800f28 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec7:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800eca:	77 05                	ja     800ed1 <__umoddi3+0xad>
  800ecc:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800ecf:	72 10                	jb     800ee1 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ed1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ed4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ed7:	29 f0                	sub    %esi,%eax
  800ed9:	19 fa                	sbb    %edi,%edx
  800edb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ede:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800ee1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ee4:	85 d2                	test   %edx,%edx
  800ee6:	74 a1                	je     800e89 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800ee8:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800eeb:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800eee:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800ef1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800ef4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800ef7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800efd:	89 01                	mov    %eax,(%ecx)
  800eff:	89 51 04             	mov    %edx,0x4(%ecx)
  800f02:	eb 85                	jmp    800e89 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f04:	85 f6                	test   %esi,%esi
  800f06:	75 0b                	jne    800f13 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f08:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0d:	31 d2                	xor    %edx,%edx
  800f0f:	f7 f6                	div    %esi
  800f11:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f13:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f16:	89 fa                	mov    %edi,%edx
  800f18:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f1d:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f20:	f7 f6                	div    %esi
  800f22:	e9 3d ff ff ff       	jmp    800e64 <__umoddi3+0x40>
  800f27:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f28:	b8 20 00 00 00       	mov    $0x20,%eax
  800f2d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800f30:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800f33:	89 fa                	mov    %edi,%edx
  800f35:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f38:	d3 e2                	shl    %cl,%edx
  800f3a:	89 f0                	mov    %esi,%eax
  800f3c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f3f:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800f41:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f44:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f46:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f48:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f4b:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f4e:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f50:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f52:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f55:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f58:	d3 e0                	shl    %cl,%eax
  800f5a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800f5d:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f60:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f63:	d3 e8                	shr    %cl,%eax
  800f65:	0b 45 cc             	or     -0x34(%ebp),%eax
  800f68:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800f6b:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f6e:	f7 f7                	div    %edi
  800f70:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f73:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f76:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f78:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f7b:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f7e:	77 0a                	ja     800f8a <__umoddi3+0x166>
  800f80:	75 12                	jne    800f94 <__umoddi3+0x170>
  800f82:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f85:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800f88:	76 0a                	jbe    800f94 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f8a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800f8d:	29 f1                	sub    %esi,%ecx
  800f8f:	19 fa                	sbb    %edi,%edx
  800f91:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800f94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f97:	85 c0                	test   %eax,%eax
  800f99:	0f 84 ea fe ff ff    	je     800e89 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f9f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800fa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fa5:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800fa8:	19 d1                	sbb    %edx,%ecx
  800faa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fad:	89 ca                	mov    %ecx,%edx
  800faf:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fb2:	d3 e2                	shl    %cl,%edx
  800fb4:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fb7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fba:	d3 e8                	shr    %cl,%eax
  800fbc:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800fbe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fc1:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fc3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800fc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fc9:	e9 ad fe ff ff       	jmp    800e7b <__umoddi3+0x57>
