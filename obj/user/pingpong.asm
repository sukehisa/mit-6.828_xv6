
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800038:	83 ec 04             	sub    $0x4,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003b:	e8 f6 0c 00 00       	call   800d36 <fork>
  800040:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800043:	85 c0                	test   %eax,%eax
  800045:	74 2b                	je     800072 <umain+0x3e>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800047:	83 ec 04             	sub    $0x4,%esp
  80004a:	50                   	push   %eax
  80004b:	83 ec 08             	sub    $0x8,%esp
  80004e:	e8 15 0a 00 00       	call   800a68 <sys_getenvid>
  800053:	83 c4 08             	add    $0x8,%esp
  800056:	50                   	push   %eax
  800057:	68 40 12 80 00       	push   $0x801240
  80005c:	e8 4f 01 00 00       	call   8001b0 <cprintf>
		ipc_send(who, 0, 0, 0);
  800061:	6a 00                	push   $0x0
  800063:	6a 00                	push   $0x0
  800065:	6a 00                	push   $0x0
  800067:	ff 75 f8             	pushl  -0x8(%ebp)
  80006a:	e8 0d 0e 00 00       	call   800e7c <ipc_send>
  80006f:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80007c:	50                   	push   %eax
  80007d:	e8 8a 0d 00 00       	call   800e0c <ipc_recv>
  800082:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800084:	ff 75 f8             	pushl  -0x8(%ebp)
  800087:	50                   	push   %eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	e8 d8 09 00 00       	call   800a68 <sys_getenvid>
  800090:	83 c4 08             	add    $0x8,%esp
  800093:	50                   	push   %eax
  800094:	68 56 12 80 00       	push   $0x801256
  800099:	e8 12 01 00 00       	call   8001b0 <cprintf>
		if (i == 10)
  80009e:	83 c4 20             	add    $0x20,%esp
  8000a1:	83 fb 0a             	cmp    $0xa,%ebx
  8000a4:	74 16                	je     8000bc <umain+0x88>
			return;
		i++;
  8000a6:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	6a 00                	push   $0x0
  8000ab:	53                   	push   %ebx
  8000ac:	ff 75 f8             	pushl  -0x8(%ebp)
  8000af:	e8 c8 0d 00 00       	call   800e7c <ipc_send>
		if (i == 10)
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	83 fb 0a             	cmp    $0xa,%ebx
  8000ba:	75 b6                	jne    800072 <umain+0x3e>
			return;
	}

}
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000cf:	e8 94 09 00 00       	call   800a68 <sys_getenvid>
  8000d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d9:	89 c2                	mov    %eax,%edx
  8000db:	c1 e2 05             	shl    $0x5,%edx
  8000de:	29 c2                	sub    %eax,%edx
  8000e0:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000e7:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	53                   	push   %ebx
  8000fc:	56                   	push   %esi
  8000fd:	e8 32 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800102:	e8 09 00 00 00       	call   800110 <exit>
}
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 0a 09 00 00       	call   800a27 <sys_env_destroy>
}
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    
	...

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 96 08 00 00       	call   8009e4 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	ff 43 04             	incl   0x4(%ebx)
}
  80015a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	ff 75 0c             	pushl  0xc(%ebp)
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	68 20 01 80 00       	push   $0x800120
  80018e:	e8 49 01 00 00       	call   8002dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800193:	83 c4 08             	add    $0x8,%esp
  800196:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80019c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 3c 08 00 00       	call   8009e4 <sys_cputs>

	return b.cnt;
  8001a8:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	50                   	push   %eax
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	e8 9d ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	8b 75 10             	mov    0x10(%ebp),%esi
  8001d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d3:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	8b 45 18             	mov    0x18(%ebp),%eax
  8001d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001de:	39 fa                	cmp    %edi,%edx
  8001e0:	77 39                	ja     80021b <printnum+0x57>
  8001e2:	72 04                	jb     8001e8 <printnum+0x24>
  8001e4:	39 f0                	cmp    %esi,%eax
  8001e6:	77 33                	ja     80021b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 20             	pushl  0x20(%ebp)
  8001ee:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001fd:	52                   	push   %edx
  8001fe:	50                   	push   %eax
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	e8 66 0d 00 00       	call   800f6c <__udivdi3>
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	52                   	push   %edx
  80020a:	50                   	push   %eax
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	ff 75 08             	pushl  0x8(%ebp)
  800211:	e8 ae ff ff ff       	call   8001c4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 19                	jmp    800234 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	4b                   	dec    %ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7e 14                	jle    800234 <printnum+0x70>
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 0c             	pushl  0xc(%ebp)
  800226:	ff 75 20             	pushl  0x20(%ebp)
  800229:	ff 55 08             	call   *0x8(%ebp)
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	4b                   	dec    %ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ec                	jg     800220 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	ff 75 0c             	pushl  0xc(%ebp)
  80023a:	8b 45 18             	mov    0x18(%ebp),%eax
  80023d:	ba 00 00 00 00       	mov    $0x0,%edx
  800242:	83 ec 04             	sub    $0x4,%esp
  800245:	52                   	push   %edx
  800246:	50                   	push   %eax
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	e8 2a 0e 00 00       	call   801078 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 85 13 80 00 	movsbl 0x801385(%eax),%eax
  800258:	50                   	push   %eax
  800259:	ff 55 08             	call   *0x8(%ebp)
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80026d:	83 f8 01             	cmp    $0x1,%eax
  800270:	7e 0e                	jle    800280 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800272:	8b 11                	mov    (%ecx),%edx
  800274:	8d 42 08             	lea    0x8(%edx),%eax
  800277:	89 01                	mov    %eax,(%ecx)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	8b 52 04             	mov    0x4(%edx),%edx
  80027e:	eb 22                	jmp    8002a2 <getuint+0x3e>
	else if (lflag)
  800280:	85 c0                	test   %eax,%eax
  800282:	74 10                	je     800294 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800284:	8b 11                	mov    (%ecx),%edx
  800286:	8d 42 04             	lea    0x4(%edx),%eax
  800289:	89 01                	mov    %eax,(%ecx)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	eb 0e                	jmp    8002a2 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800294:	8b 11                	mov    (%ecx),%edx
  800296:	8d 42 04             	lea    0x4(%edx),%eax
  800299:	89 01                	mov    %eax,(%ecx)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002ad:	83 f8 01             	cmp    $0x1,%eax
  8002b0:	7e 0e                	jle    8002c0 <getint+0x1c>
		return va_arg(*ap, long long);
  8002b2:	8b 11                	mov    (%ecx),%edx
  8002b4:	8d 42 08             	lea    0x8(%edx),%eax
  8002b7:	89 01                	mov    %eax,(%ecx)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	8b 52 04             	mov    0x4(%edx),%edx
  8002be:	eb 1a                	jmp    8002da <getint+0x36>
	else if (lflag)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	74 0c                	je     8002d0 <getint+0x2c>
		return va_arg(*ap, long);
  8002c4:	8b 01                	mov    (%ecx),%eax
  8002c6:	8d 50 04             	lea    0x4(%eax),%edx
  8002c9:	89 11                	mov    %edx,(%ecx)
  8002cb:	8b 00                	mov    (%eax),%eax
  8002cd:	99                   	cltd   
  8002ce:	eb 0a                	jmp    8002da <getint+0x36>
	else
		return va_arg(*ap, int);
  8002d0:	8b 01                	mov    (%ecx),%eax
  8002d2:	8d 50 04             	lea    0x4(%eax),%edx
  8002d5:	89 11                	mov    %edx,(%ecx)
  8002d7:	8b 00                	mov    (%eax),%eax
  8002d9:	99                   	cltd   
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 1c             	sub    $0x1c,%esp
  8002e5:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8002e8:	0f b6 0b             	movzbl (%ebx),%ecx
  8002eb:	43                   	inc    %ebx
  8002ec:	83 f9 25             	cmp    $0x25,%ecx
  8002ef:	74 1e                	je     80030f <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f1:	85 c9                	test   %ecx,%ecx
  8002f3:	0f 84 dc 02 00 00    	je     8005d5 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	51                   	push   %ecx
  800300:	ff 55 08             	call   *0x8(%ebp)
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	0f b6 0b             	movzbl (%ebx),%ecx
  800309:	43                   	inc    %ebx
  80030a:	83 f9 25             	cmp    $0x25,%ecx
  80030d:	75 e2                	jne    8002f1 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80030f:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800313:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80031a:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80031f:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800324:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	0f b6 0b             	movzbl (%ebx),%ecx
  80032e:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800331:	43                   	inc    %ebx
  800332:	83 f8 55             	cmp    $0x55,%eax
  800335:	0f 87 75 02 00 00    	ja     8005b0 <vprintfmt+0x2d4>
  80033b:	ff 24 85 20 14 80 00 	jmp    *0x801420(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800342:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800346:	eb e3                	jmp    80032b <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  80034c:	eb dd                	jmp    80032b <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800353:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800356:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  80035a:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80035d:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800360:	83 f8 09             	cmp    $0x9,%eax
  800363:	77 28                	ja     80038d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800365:	43                   	inc    %ebx
  800366:	eb eb                	jmp    800353 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800368:	8b 55 14             	mov    0x14(%ebp),%edx
  80036b:	8d 42 04             	lea    0x4(%edx),%eax
  80036e:	89 45 14             	mov    %eax,0x14(%ebp)
  800371:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800373:	eb 18                	jmp    80038d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800375:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800379:	79 b0                	jns    80032b <vprintfmt+0x4f>
				width = 0;
  80037b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800382:	eb a7                	jmp    80032b <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800384:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80038b:	eb 9e                	jmp    80032b <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80038d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800391:	79 98                	jns    80032b <vprintfmt+0x4f>
				width = precision, precision = -1;
  800393:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800396:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80039b:	eb 8e                	jmp    80032b <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039d:	47                   	inc    %edi
			goto reswitch;
  80039e:	eb 8b                	jmp    80032b <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	ff 75 0c             	pushl  0xc(%ebp)
  8003a6:	8b 55 14             	mov    0x14(%ebp),%edx
  8003a9:	8d 42 04             	lea    0x4(%edx),%eax
  8003ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8003af:	ff 32                	pushl  (%edx)
  8003b1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003b4:	83 c4 10             	add    $0x10,%esp
  8003b7:	e9 2c ff ff ff       	jmp    8002e8 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bf:	8d 42 04             	lea    0x4(%edx),%eax
  8003c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8003c5:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  8003c7:	85 c0                	test   %eax,%eax
  8003c9:	79 02                	jns    8003cd <vprintfmt+0xf1>
				err = -err;
  8003cb:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 0f             	cmp    $0xf,%eax
  8003d0:	7f 0b                	jg     8003dd <vprintfmt+0x101>
  8003d2:	8b 3c 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edi
  8003d9:	85 ff                	test   %edi,%edi
  8003db:	75 19                	jne    8003f6 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  8003dd:	50                   	push   %eax
  8003de:	68 96 13 80 00       	push   $0x801396
  8003e3:	ff 75 0c             	pushl  0xc(%ebp)
  8003e6:	ff 75 08             	pushl  0x8(%ebp)
  8003e9:	e8 ef 01 00 00       	call   8005dd <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
  8003f1:	e9 f2 fe ff ff       	jmp    8002e8 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8003f6:	57                   	push   %edi
  8003f7:	68 9f 13 80 00       	push   $0x80139f
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 d6 01 00 00       	call   8005dd <printfmt>
  800407:	83 c4 10             	add    $0x10,%esp
			break;
  80040a:	e9 d9 fe ff ff       	jmp    8002e8 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040f:	8b 55 14             	mov    0x14(%ebp),%edx
  800412:	8d 42 04             	lea    0x4(%edx),%eax
  800415:	89 45 14             	mov    %eax,0x14(%ebp)
  800418:	8b 3a                	mov    (%edx),%edi
  80041a:	85 ff                	test   %edi,%edi
  80041c:	75 05                	jne    800423 <vprintfmt+0x147>
				p = "(null)";
  80041e:	bf a2 13 80 00       	mov    $0x8013a2,%edi
			if (width > 0 && padc != '-')
  800423:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800427:	7e 3b                	jle    800464 <vprintfmt+0x188>
  800429:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  80042d:	74 35                	je     800464 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	56                   	push   %esi
  800433:	57                   	push   %edi
  800434:	e8 58 02 00 00       	call   800691 <strnlen>
  800439:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800443:	7e 1f                	jle    800464 <vprintfmt+0x188>
  800445:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 0c             	pushl  0xc(%ebp)
  800452:	ff 75 e4             	pushl  -0x1c(%ebp)
  800455:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	ff 4d f0             	decl   -0x10(%ebp)
  80045e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800462:	7f e8                	jg     80044c <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800464:	0f be 0f             	movsbl (%edi),%ecx
  800467:	47                   	inc    %edi
  800468:	85 c9                	test   %ecx,%ecx
  80046a:	74 44                	je     8004b0 <vprintfmt+0x1d4>
  80046c:	85 f6                	test   %esi,%esi
  80046e:	78 03                	js     800473 <vprintfmt+0x197>
  800470:	4e                   	dec    %esi
  800471:	78 3d                	js     8004b0 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800473:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800477:	74 18                	je     800491 <vprintfmt+0x1b5>
  800479:	8d 41 e0             	lea    -0x20(%ecx),%eax
  80047c:	83 f8 5e             	cmp    $0x5e,%eax
  80047f:	76 10                	jbe    800491 <vprintfmt+0x1b5>
					putch('?', putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	ff 75 0c             	pushl  0xc(%ebp)
  800487:	6a 3f                	push   $0x3f
  800489:	ff 55 08             	call   *0x8(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	eb 0d                	jmp    80049e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	ff 75 0c             	pushl  0xc(%ebp)
  800497:	51                   	push   %ecx
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	ff 4d f0             	decl   -0x10(%ebp)
  8004a1:	0f be 0f             	movsbl (%edi),%ecx
  8004a4:	47                   	inc    %edi
  8004a5:	85 c9                	test   %ecx,%ecx
  8004a7:	74 07                	je     8004b0 <vprintfmt+0x1d4>
  8004a9:	85 f6                	test   %esi,%esi
  8004ab:	78 c6                	js     800473 <vprintfmt+0x197>
  8004ad:	4e                   	dec    %esi
  8004ae:	79 c3                	jns    800473 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004b4:	0f 8e 2e fe ff ff    	jle    8002e8 <vprintfmt+0xc>
				putch(' ', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	ff 75 0c             	pushl  0xc(%ebp)
  8004c0:	6a 20                	push   $0x20
  8004c2:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	ff 4d f0             	decl   -0x10(%ebp)
  8004cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004cf:	7f e9                	jg     8004ba <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  8004d1:	e9 12 fe ff ff       	jmp    8002e8 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004d6:	57                   	push   %edi
  8004d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8004da:	50                   	push   %eax
  8004db:	e8 c4 fd ff ff       	call   8002a4 <getint>
  8004e0:	89 c6                	mov    %eax,%esi
  8004e2:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004e4:	83 c4 08             	add    $0x8,%esp
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	79 15                	jns    800500 <vprintfmt+0x224>
				putch('-', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 2d                	push   $0x2d
  8004f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004f6:	f7 de                	neg    %esi
  8004f8:	83 d7 00             	adc    $0x0,%edi
  8004fb:	f7 df                	neg    %edi
  8004fd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800500:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800505:	eb 76                	jmp    80057d <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800507:	57                   	push   %edi
  800508:	8d 45 14             	lea    0x14(%ebp),%eax
  80050b:	50                   	push   %eax
  80050c:	e8 53 fd ff ff       	call   800264 <getuint>
  800511:	89 c6                	mov    %eax,%esi
  800513:	89 d7                	mov    %edx,%edi
			base = 10;
  800515:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80051a:	83 c4 08             	add    $0x8,%esp
  80051d:	eb 5e                	jmp    80057d <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80051f:	57                   	push   %edi
  800520:	8d 45 14             	lea    0x14(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	e8 3b fd ff ff       	call   800264 <getuint>
  800529:	89 c6                	mov    %eax,%esi
  80052b:	89 d7                	mov    %edx,%edi
			base = 8;
  80052d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800532:	83 c4 08             	add    $0x8,%esp
  800535:	eb 46                	jmp    80057d <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	6a 30                	push   $0x30
  80053f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800542:	83 c4 08             	add    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	6a 78                	push   $0x78
  80054a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80054d:	8b 55 14             	mov    0x14(%ebp),%edx
  800550:	8d 42 04             	lea    0x4(%edx),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	8b 32                	mov    (%edx),%esi
  800558:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80055d:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 16                	jmp    80057d <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800567:	57                   	push   %edi
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
  80056b:	50                   	push   %eax
  80056c:	e8 f3 fc ff ff       	call   800264 <getuint>
  800571:	89 c6                	mov    %eax,%esi
  800573:	89 d7                	mov    %edx,%edi
			base = 16;
  800575:	ba 10 00 00 00       	mov    $0x10,%edx
  80057a:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  80057d:	83 ec 04             	sub    $0x4,%esp
  800580:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 f0             	pushl  -0x10(%ebp)
  800588:	52                   	push   %edx
  800589:	57                   	push   %edi
  80058a:	56                   	push   %esi
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	ff 75 08             	pushl  0x8(%ebp)
  800591:	e8 2e fc ff ff       	call   8001c4 <printnum>
			break;
  800596:	83 c4 20             	add    $0x20,%esp
  800599:	e9 4a fd ff ff       	jmp    8002e8 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	ff 75 0c             	pushl  0xc(%ebp)
  8005a4:	51                   	push   %ecx
  8005a5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	e9 38 fd ff ff       	jmp    8002e8 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	ff 75 0c             	pushl  0xc(%ebp)
  8005b6:	6a 25                	push   $0x25
  8005b8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005bb:	4b                   	dec    %ebx
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005c3:	0f 84 1f fd ff ff    	je     8002e8 <vprintfmt+0xc>
  8005c9:	4b                   	dec    %ebx
  8005ca:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005ce:	75 f9                	jne    8005c9 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005d0:	e9 13 fd ff ff       	jmp    8002e8 <vprintfmt+0xc>
		}
	}
}
  8005d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d8:	5b                   	pop    %ebx
  8005d9:	5e                   	pop    %esi
  8005da:	5f                   	pop    %edi
  8005db:	c9                   	leave  
  8005dc:	c3                   	ret    

008005dd <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005e6:	50                   	push   %eax
  8005e7:	ff 75 10             	pushl  0x10(%ebp)
  8005ea:	ff 75 0c             	pushl  0xc(%ebp)
  8005ed:	ff 75 08             	pushl  0x8(%ebp)
  8005f0:	e8 e7 fc ff ff       	call   8002dc <vprintfmt>
	va_end(ap);
}
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005fd:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800600:	8b 0a                	mov    (%edx),%ecx
  800602:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800605:	73 07                	jae    80060e <sprintputch+0x17>
		*b->buf++ = ch;
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	88 01                	mov    %al,(%ecx)
  80060c:	ff 02                	incl   (%edx)
}
  80060e:	c9                   	leave  
  80060f:	c3                   	ret    

00800610 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	83 ec 18             	sub    $0x18,%esp
  800616:	8b 55 08             	mov    0x8(%ebp),%edx
  800619:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80061c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80061f:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800623:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800626:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  80062d:	85 d2                	test   %edx,%edx
  80062f:	74 04                	je     800635 <vsnprintf+0x25>
  800631:	85 c9                	test   %ecx,%ecx
  800633:	7f 07                	jg     80063c <vsnprintf+0x2c>
		return -E_INVAL;
  800635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80063a:	eb 1d                	jmp    800659 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80063c:	ff 75 14             	pushl  0x14(%ebp)
  80063f:	ff 75 10             	pushl  0x10(%ebp)
  800642:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	68 f7 05 80 00       	push   $0x8005f7
  80064b:	e8 8c fc ff ff       	call   8002dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800650:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800653:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800656:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800659:	c9                   	leave  
  80065a:	c3                   	ret    

0080065b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800664:	50                   	push   %eax
  800665:	ff 75 10             	pushl  0x10(%ebp)
  800668:	ff 75 0c             	pushl  0xc(%ebp)
  80066b:	ff 75 08             	pushl  0x8(%ebp)
  80066e:	e8 9d ff ff ff       	call   800610 <vsnprintf>
	va_end(ap);

	return rc;
}
  800673:	c9                   	leave  
  800674:	c3                   	ret    
  800675:	00 00                	add    %al,(%eax)
	...

00800678 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80067e:	b8 00 00 00 00       	mov    $0x0,%eax
  800683:	80 3a 00             	cmpb   $0x0,(%edx)
  800686:	74 07                	je     80068f <strlen+0x17>
		n++;
  800688:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800689:	42                   	inc    %edx
  80068a:	80 3a 00             	cmpb   $0x0,(%edx)
  80068d:	75 f9                	jne    800688 <strlen+0x10>
		n++;
	return n;
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800697:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80069a:	b8 00 00 00 00       	mov    $0x0,%eax
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	74 0f                	je     8006b2 <strnlen+0x21>
  8006a3:	80 39 00             	cmpb   $0x0,(%ecx)
  8006a6:	74 0a                	je     8006b2 <strnlen+0x21>
		n++;
  8006a8:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a9:	41                   	inc    %ecx
  8006aa:	4a                   	dec    %edx
  8006ab:	74 05                	je     8006b2 <strnlen+0x21>
  8006ad:	80 39 00             	cmpb   $0x0,(%ecx)
  8006b0:	75 f6                	jne    8006a8 <strnlen+0x17>
		n++;
	return n;
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	53                   	push   %ebx
  8006b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006be:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006c0:	8a 02                	mov    (%edx),%al
  8006c2:	42                   	inc    %edx
  8006c3:	88 01                	mov    %al,(%ecx)
  8006c5:	41                   	inc    %ecx
  8006c6:	84 c0                	test   %al,%al
  8006c8:	75 f6                	jne    8006c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ca:	89 d8                	mov    %ebx,%eax
  8006cc:	5b                   	pop    %ebx
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	53                   	push   %ebx
  8006d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006d6:	53                   	push   %ebx
  8006d7:	e8 9c ff ff ff       	call   800678 <strlen>
	strcpy(dst + len, src);
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006e2:	50                   	push   %eax
  8006e3:	e8 cc ff ff ff       	call   8006b4 <strcpy>
	return dst;
}
  8006e8:	89 d8                	mov    %ebx,%eax
  8006ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	57                   	push   %edi
  8006f3:	56                   	push   %esi
  8006f4:	53                   	push   %ebx
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fb:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006fe:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	39 f3                	cmp    %esi,%ebx
  800707:	73 10                	jae    800719 <strncpy+0x2a>
		*dst++ = *src;
  800709:	8a 02                	mov    (%edx),%al
  80070b:	88 01                	mov    %al,(%ecx)
  80070d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80070e:	80 3a 01             	cmpb   $0x1,(%edx)
  800711:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800714:	43                   	inc    %ebx
  800715:	39 f3                	cmp    %esi,%ebx
  800717:	72 f0                	jb     800709 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800719:	89 f8                	mov    %edi,%eax
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	56                   	push   %esi
  800724:	53                   	push   %ebx
  800725:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80072e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800730:	85 d2                	test   %edx,%edx
  800732:	74 19                	je     80074d <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800734:	4a                   	dec    %edx
  800735:	74 13                	je     80074a <strlcpy+0x2a>
  800737:	80 39 00             	cmpb   $0x0,(%ecx)
  80073a:	74 0e                	je     80074a <strlcpy+0x2a>
  80073c:	8a 01                	mov    (%ecx),%al
  80073e:	41                   	inc    %ecx
  80073f:	88 03                	mov    %al,(%ebx)
  800741:	43                   	inc    %ebx
  800742:	4a                   	dec    %edx
  800743:	74 05                	je     80074a <strlcpy+0x2a>
  800745:	80 39 00             	cmpb   $0x0,(%ecx)
  800748:	75 f2                	jne    80073c <strlcpy+0x1c>
		*dst = '\0';
  80074a:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	29 f0                	sub    %esi,%eax
}
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80075e:	80 3a 00             	cmpb   $0x0,(%edx)
  800761:	74 13                	je     800776 <strcmp+0x21>
  800763:	8a 02                	mov    (%edx),%al
  800765:	3a 01                	cmp    (%ecx),%al
  800767:	75 0d                	jne    800776 <strcmp+0x21>
  800769:	42                   	inc    %edx
  80076a:	41                   	inc    %ecx
  80076b:	80 3a 00             	cmpb   $0x0,(%edx)
  80076e:	74 06                	je     800776 <strcmp+0x21>
  800770:	8a 02                	mov    (%edx),%al
  800772:	3a 01                	cmp    (%ecx),%al
  800774:	74 f3                	je     800769 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800776:	0f b6 02             	movzbl (%edx),%eax
  800779:	0f b6 11             	movzbl (%ecx),%edx
  80077c:	29 d0                	sub    %edx,%eax
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
  800787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	74 1f                	je     8007b0 <strncmp+0x30>
  800791:	80 3a 00             	cmpb   $0x0,(%edx)
  800794:	74 16                	je     8007ac <strncmp+0x2c>
  800796:	8a 02                	mov    (%edx),%al
  800798:	3a 03                	cmp    (%ebx),%al
  80079a:	75 10                	jne    8007ac <strncmp+0x2c>
  80079c:	42                   	inc    %edx
  80079d:	43                   	inc    %ebx
  80079e:	49                   	dec    %ecx
  80079f:	74 0f                	je     8007b0 <strncmp+0x30>
  8007a1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a4:	74 06                	je     8007ac <strncmp+0x2c>
  8007a6:	8a 02                	mov    (%edx),%al
  8007a8:	3a 03                	cmp    (%ebx),%al
  8007aa:	74 f0                	je     80079c <strncmp+0x1c>
	if (n == 0)
  8007ac:	85 c9                	test   %ecx,%ecx
  8007ae:	75 07                	jne    8007b7 <strncmp+0x37>
		return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 0a                	jmp    8007c1 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b7:	0f b6 12             	movzbl (%edx),%edx
  8007ba:	0f b6 03             	movzbl (%ebx),%eax
  8007bd:	29 c2                	sub    %eax,%edx
  8007bf:	89 d0                	mov    %edx,%eax
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007cd:	80 38 00             	cmpb   $0x0,(%eax)
  8007d0:	74 0a                	je     8007dc <strchr+0x18>
		if (*s == c)
  8007d2:	38 10                	cmp    %dl,(%eax)
  8007d4:	74 0b                	je     8007e1 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007d6:	40                   	inc    %eax
  8007d7:	80 38 00             	cmpb   $0x0,(%eax)
  8007da:	75 f6                	jne    8007d2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007ec:	80 38 00             	cmpb   $0x0,(%eax)
  8007ef:	74 0a                	je     8007fb <strfind+0x18>
		if (*s == c)
  8007f1:	38 10                	cmp    %dl,(%eax)
  8007f3:	74 06                	je     8007fb <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007f5:	40                   	inc    %eax
  8007f6:	80 38 00             	cmpb   $0x0,(%eax)
  8007f9:	75 f6                	jne    8007f1 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	57                   	push   %edi
  800801:	8b 7d 08             	mov    0x8(%ebp),%edi
  800804:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800807:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800809:	85 c9                	test   %ecx,%ecx
  80080b:	74 40                	je     80084d <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80080d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800813:	75 30                	jne    800845 <memset+0x48>
  800815:	f6 c1 03             	test   $0x3,%cl
  800818:	75 2b                	jne    800845 <memset+0x48>
		c &= 0xFF;
  80081a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800821:	8b 45 0c             	mov    0xc(%ebp),%eax
  800824:	c1 e0 18             	shl    $0x18,%eax
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082a:	c1 e2 10             	shl    $0x10,%edx
  80082d:	09 d0                	or     %edx,%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	c1 e2 08             	shl    $0x8,%edx
  800835:	09 d0                	or     %edx,%eax
  800837:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80083a:	c1 e9 02             	shr    $0x2,%ecx
  80083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800840:	fc                   	cld    
  800841:	f3 ab                	rep stos %eax,%es:(%edi)
  800843:	eb 06                	jmp    80084b <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	fc                   	cld    
  800849:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80084b:	89 f8                	mov    %edi,%eax
}
  80084d:	5f                   	pop    %edi
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	57                   	push   %edi
  800854:	56                   	push   %esi
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80085b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80085e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800860:	39 c6                	cmp    %eax,%esi
  800862:	73 34                	jae    800898 <memmove+0x48>
  800864:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800867:	39 c2                	cmp    %eax,%edx
  800869:	76 2d                	jbe    800898 <memmove+0x48>
		s += n;
  80086b:	89 d6                	mov    %edx,%esi
		d += n;
  80086d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800870:	f6 c2 03             	test   $0x3,%dl
  800873:	75 1b                	jne    800890 <memmove+0x40>
  800875:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087b:	75 13                	jne    800890 <memmove+0x40>
  80087d:	f6 c1 03             	test   $0x3,%cl
  800880:	75 0e                	jne    800890 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800882:	83 ef 04             	sub    $0x4,%edi
  800885:	83 ee 04             	sub    $0x4,%esi
  800888:	c1 e9 02             	shr    $0x2,%ecx
  80088b:	fd                   	std    
  80088c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80088e:	eb 05                	jmp    800895 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800890:	4f                   	dec    %edi
  800891:	4e                   	dec    %esi
  800892:	fd                   	std    
  800893:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800895:	fc                   	cld    
  800896:	eb 20                	jmp    8008b8 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800898:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089e:	75 15                	jne    8008b5 <memmove+0x65>
  8008a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a6:	75 0d                	jne    8008b5 <memmove+0x65>
  8008a8:	f6 c1 03             	test   $0x3,%cl
  8008ab:	75 08                	jne    8008b5 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  8008ad:	c1 e9 02             	shr    $0x2,%ecx
  8008b0:	fc                   	cld    
  8008b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b3:	eb 03                	jmp    8008b8 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b5:	fc                   	cld    
  8008b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008bf:	ff 75 10             	pushl  0x10(%ebp)
  8008c2:	ff 75 0c             	pushl  0xc(%ebp)
  8008c5:	ff 75 08             	pushl  0x8(%ebp)
  8008c8:	e8 83 ff ff ff       	call   800850 <memmove>
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008d9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008dc:	4a                   	dec    %edx
  8008dd:	83 fa ff             	cmp    $0xffffffff,%edx
  8008e0:	74 1a                	je     8008fc <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8008e2:	8a 01                	mov    (%ecx),%al
  8008e4:	3a 03                	cmp    (%ebx),%al
  8008e6:	74 0c                	je     8008f4 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  8008e8:	0f b6 d0             	movzbl %al,%edx
  8008eb:	0f b6 03             	movzbl (%ebx),%eax
  8008ee:	29 c2                	sub    %eax,%edx
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	eb 0d                	jmp    800901 <memcmp+0x32>
		s1++, s2++;
  8008f4:	41                   	inc    %ecx
  8008f5:	43                   	inc    %ebx
  8008f6:	4a                   	dec    %edx
  8008f7:	83 fa ff             	cmp    $0xffffffff,%edx
  8008fa:	75 e6                	jne    8008e2 <memcmp+0x13>
	}

	return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800901:	5b                   	pop    %ebx
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800912:	39 d0                	cmp    %edx,%eax
  800914:	73 09                	jae    80091f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800916:	38 08                	cmp    %cl,(%eax)
  800918:	74 05                	je     80091f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091a:	40                   	inc    %eax
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	72 f7                	jb     800916 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 55 08             	mov    0x8(%ebp),%edx
  80092a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800930:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800935:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80093a:	80 3a 20             	cmpb   $0x20,(%edx)
  80093d:	74 05                	je     800944 <strtol+0x23>
  80093f:	80 3a 09             	cmpb   $0x9,(%edx)
  800942:	75 0b                	jne    80094f <strtol+0x2e>
  800944:	42                   	inc    %edx
  800945:	80 3a 20             	cmpb   $0x20,(%edx)
  800948:	74 fa                	je     800944 <strtol+0x23>
  80094a:	80 3a 09             	cmpb   $0x9,(%edx)
  80094d:	74 f5                	je     800944 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80094f:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800952:	75 03                	jne    800957 <strtol+0x36>
		s++;
  800954:	42                   	inc    %edx
  800955:	eb 0b                	jmp    800962 <strtol+0x41>
	else if (*s == '-')
  800957:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80095a:	75 06                	jne    800962 <strtol+0x41>
		s++, neg = 1;
  80095c:	42                   	inc    %edx
  80095d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 05                	je     80096b <strtol+0x4a>
  800966:	83 f9 10             	cmp    $0x10,%ecx
  800969:	75 15                	jne    800980 <strtol+0x5f>
  80096b:	80 3a 30             	cmpb   $0x30,(%edx)
  80096e:	75 10                	jne    800980 <strtol+0x5f>
  800970:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800974:	75 0a                	jne    800980 <strtol+0x5f>
		s += 2, base = 16;
  800976:	83 c2 02             	add    $0x2,%edx
  800979:	b9 10 00 00 00       	mov    $0x10,%ecx
  80097e:	eb 14                	jmp    800994 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800980:	85 c9                	test   %ecx,%ecx
  800982:	75 10                	jne    800994 <strtol+0x73>
  800984:	80 3a 30             	cmpb   $0x30,(%edx)
  800987:	75 05                	jne    80098e <strtol+0x6d>
		s++, base = 8;
  800989:	42                   	inc    %edx
  80098a:	b1 08                	mov    $0x8,%cl
  80098c:	eb 06                	jmp    800994 <strtol+0x73>
	else if (base == 0)
  80098e:	85 c9                	test   %ecx,%ecx
  800990:	75 02                	jne    800994 <strtol+0x73>
		base = 10;
  800992:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800994:	8a 02                	mov    (%edx),%al
  800996:	83 e8 30             	sub    $0x30,%eax
  800999:	3c 09                	cmp    $0x9,%al
  80099b:	77 08                	ja     8009a5 <strtol+0x84>
			dig = *s - '0';
  80099d:	0f be 02             	movsbl (%edx),%eax
  8009a0:	83 e8 30             	sub    $0x30,%eax
  8009a3:	eb 20                	jmp    8009c5 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  8009a5:	8a 02                	mov    (%edx),%al
  8009a7:	83 e8 61             	sub    $0x61,%eax
  8009aa:	3c 19                	cmp    $0x19,%al
  8009ac:	77 08                	ja     8009b6 <strtol+0x95>
			dig = *s - 'a' + 10;
  8009ae:	0f be 02             	movsbl (%edx),%eax
  8009b1:	83 e8 57             	sub    $0x57,%eax
  8009b4:	eb 0f                	jmp    8009c5 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  8009b6:	8a 02                	mov    (%edx),%al
  8009b8:	83 e8 41             	sub    $0x41,%eax
  8009bb:	3c 19                	cmp    $0x19,%al
  8009bd:	77 12                	ja     8009d1 <strtol+0xb0>
			dig = *s - 'A' + 10;
  8009bf:	0f be 02             	movsbl (%edx),%eax
  8009c2:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009c5:	39 c8                	cmp    %ecx,%eax
  8009c7:	7d 08                	jge    8009d1 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009c9:	42                   	inc    %edx
  8009ca:	0f af d9             	imul   %ecx,%ebx
  8009cd:	01 c3                	add    %eax,%ebx
  8009cf:	eb c3                	jmp    800994 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009d1:	85 f6                	test   %esi,%esi
  8009d3:	74 02                	je     8009d7 <strtol+0xb6>
		*endptr = (char *) s;
  8009d5:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009d7:	89 d8                	mov    %ebx,%eax
  8009d9:	85 ff                	test   %edi,%edi
  8009db:	74 02                	je     8009df <strtol+0xbe>
  8009dd:	f7 d8                	neg    %eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 04             	sub    $0x4,%esp
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009f3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009f8:	89 f8                	mov    %edi,%eax
  8009fa:	89 fb                	mov    %edi,%ebx
  8009fc:	89 fe                	mov    %edi,%esi
  8009fe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a00:	83 c4 04             	add    $0x4,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a18:	89 fa                	mov    %edi,%edx
  800a1a:	89 f9                	mov    %edi,%ecx
  800a1c:	89 fb                	mov    %edi,%ebx
  800a1e:	89 fe                	mov    %edi,%esi
  800a20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	83 ec 0c             	sub    $0xc,%esp
  800a30:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a33:	b8 03 00 00 00       	mov    $0x3,%eax
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3d:	89 f9                	mov    %edi,%ecx
  800a3f:	89 fb                	mov    %edi,%ebx
  800a41:	89 fe                	mov    %edi,%esi
  800a43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	7e 17                	jle    800a60 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a49:	83 ec 0c             	sub    $0xc,%esp
  800a4c:	50                   	push   %eax
  800a4d:	6a 03                	push   $0x3
  800a4f:	68 78 15 80 00       	push   $0x801578
  800a54:	6a 23                	push   $0x23
  800a56:	68 95 15 80 00       	push   $0x801595
  800a5b:	e8 c0 04 00 00       	call   800f20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a78:	89 fa                	mov    %edi,%edx
  800a7a:	89 f9                	mov    %edi,%ecx
  800a7c:	89 fb                	mov    %edi,%ebx
  800a7e:	89 fe                	mov    %edi,%esi
  800a80:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <sys_yield>:

void
sys_yield(void)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a97:	89 fa                	mov    %edi,%edx
  800a99:	89 f9                	mov    %edi,%ecx
  800a9b:	89 fb                	mov    %edi,%ebx
  800a9d:	89 fe                	mov    %edi,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	83 ec 0c             	sub    $0xc,%esp
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab8:	b8 04 00 00 00       	mov    $0x4,%eax
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	89 fe                	mov    %edi,%esi
  800ac4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	7e 17                	jle    800ae1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aca:	83 ec 0c             	sub    $0xc,%esp
  800acd:	50                   	push   %eax
  800ace:	6a 04                	push   $0x4
  800ad0:	68 78 15 80 00       	push   $0x801578
  800ad5:	6a 23                	push   $0x23
  800ad7:	68 95 15 80 00       	push   $0x801595
  800adc:	e8 3f 04 00 00       	call   800f20 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800afb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800afe:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b01:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	7e 17                	jle    800b23 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	50                   	push   %eax
  800b10:	6a 05                	push   $0x5
  800b12:	68 78 15 80 00       	push   $0x801578
  800b17:	6a 23                	push   $0x23
  800b19:	68 95 15 80 00       	push   $0x801595
  800b1e:	e8 fd 03 00 00       	call   800f20 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b3f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	89 fb                	mov    %edi,%ebx
  800b46:	89 fe                	mov    %edi,%esi
  800b48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 06                	push   $0x6
  800b54:	68 78 15 80 00       	push   $0x801578
  800b59:	6a 23                	push   $0x23
  800b5b:	68 95 15 80 00       	push   $0x801595
  800b60:	e8 bb 03 00 00       	call   800f20 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b81:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	89 fb                	mov    %edi,%ebx
  800b88:	89 fe                	mov    %edi,%esi
  800b8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 17                	jle    800ba7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 08                	push   $0x8
  800b96:	68 78 15 80 00       	push   $0x801578
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 95 15 80 00       	push   $0x801595
  800ba2:	e8 79 03 00 00       	call   800f20 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bbe:	b8 09 00 00 00       	mov    $0x9,%eax
  800bc3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	89 fb                	mov    %edi,%ebx
  800bca:	89 fe                	mov    %edi,%esi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 09                	push   $0x9
  800bd8:	68 78 15 80 00       	push   $0x801578
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 95 15 80 00       	push   $0x801595
  800be4:	e8 37 03 00 00       	call   800f20 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c05:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	89 fb                	mov    %edi,%ebx
  800c0c:	89 fe                	mov    %edi,%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 0a                	push   $0xa
  800c1a:	68 78 15 80 00       	push   $0x801578
  800c1f:	6a 23                	push   $0x23
  800c21:	68 95 15 80 00       	push   $0x801595
  800c26:	e8 f5 02 00 00       	call   800f20 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c42:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c4a:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c62:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	89 f9                	mov    %edi,%ecx
  800c6e:	89 fb                	mov    %edi,%ebx
  800c70:	89 fe                	mov    %edi,%esi
  800c72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 0d                	push   $0xd
  800c7e:	68 78 15 80 00       	push   $0x801578
  800c83:	6a 23                	push   $0x23
  800c85:	68 95 15 80 00       	push   $0x801595
  800c8a:	e8 91 02 00 00       	call   800f20 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    
	...

00800c98 <duppage>:


/// dstenv: child's envid
void
duppage(envid_t dstenv, void *addr)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800ca0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ca3:	83 ec 04             	sub    $0x4,%esp
  800ca6:	6a 07                	push   $0x7
  800ca8:	53                   	push   %ebx
  800ca9:	56                   	push   %esi
  800caa:	e8 f7 fd ff ff       	call   800aa6 <sys_page_alloc>
  800caf:	83 c4 10             	add    $0x10,%esp
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	79 12                	jns    800cc8 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800cb6:	50                   	push   %eax
  800cb7:	68 a3 15 80 00       	push   $0x8015a3
  800cbc:	6a 18                	push   $0x18
  800cbe:	68 b6 15 80 00       	push   $0x8015b6
  800cc3:	e8 58 02 00 00       	call   800f20 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	6a 07                	push   $0x7
  800ccd:	68 00 00 40 00       	push   $0x400000
  800cd2:	6a 00                	push   $0x0
  800cd4:	53                   	push   %ebx
  800cd5:	56                   	push   %esi
  800cd6:	e8 0e fe ff ff       	call   800ae9 <sys_page_map>
  800cdb:	83 c4 20             	add    $0x20,%esp
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	79 12                	jns    800cf4 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  800ce2:	50                   	push   %eax
  800ce3:	68 c1 15 80 00       	push   $0x8015c1
  800ce8:	6a 1a                	push   $0x1a
  800cea:	68 b6 15 80 00       	push   $0x8015b6
  800cef:	e8 2c 02 00 00       	call   800f20 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	68 00 10 00 00       	push   $0x1000
  800cfc:	53                   	push   %ebx
  800cfd:	68 00 00 40 00       	push   $0x400000
  800d02:	e8 49 fb ff ff       	call   800850 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800d07:	83 c4 08             	add    $0x8,%esp
  800d0a:	68 00 00 40 00       	push   $0x400000
  800d0f:	6a 00                	push   $0x0
  800d11:	e8 15 fe ff ff       	call   800b2b <sys_page_unmap>
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	79 12                	jns    800d2f <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  800d1d:	50                   	push   %eax
  800d1e:	68 d2 15 80 00       	push   $0x8015d2
  800d23:	6a 1d                	push   $0x1d
  800d25:	68 b6 15 80 00       	push   $0x8015b6
  800d2a:	e8 f1 01 00 00       	call   800f20 <_panic>
}
  800d2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <fork>:

envid_t
fork(void)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 04             	sub    $0x4,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800d3d:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  800d42:	89 d0                	mov    %edx,%eax
  800d44:	cd 30                	int    $0x30
  800d46:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	79 12                	jns    800d5e <fork+0x28>
		panic("sys_exofork: %e", envid);
  800d4c:	50                   	push   %eax
  800d4d:	68 e5 15 80 00       	push   $0x8015e5
  800d52:	6a 2f                	push   $0x2f
  800d54:	68 b6 15 80 00       	push   $0x8015b6
  800d59:	e8 c2 01 00 00       	call   800f20 <_panic>
	if (envid == 0) {
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	75 25                	jne    800d87 <fork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800d62:	e8 01 fd ff ff       	call   800a68 <sys_getenvid>
  800d67:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d6c:	89 c2                	mov    %eax,%edx
  800d6e:	c1 e2 05             	shl    $0x5,%edx
  800d71:	29 c2                	sub    %eax,%edx
  800d73:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800d7a:	89 15 04 20 80 00    	mov    %edx,0x802004
		return 0;
  800d80:	ba 00 00 00 00       	mov    $0x0,%edx
  800d85:	eb 67                	jmp    800dee <fork+0xb8>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800d87:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800d8e:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800d95:	73 1f                	jae    800db6 <fork+0x80>
		duppage(envid, addr);
  800d97:	83 ec 08             	sub    $0x8,%esp
  800d9a:	ff 75 f8             	pushl  -0x8(%ebp)
  800d9d:	53                   	push   %ebx
  800d9e:	e8 f5 fe ff ff       	call   800c98 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  800dad:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800db4:	72 e1                	jb     800d97 <fork+0x61>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800db6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800db9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dbe:	83 ec 08             	sub    $0x8,%esp
  800dc1:	50                   	push   %eax
  800dc2:	53                   	push   %ebx
  800dc3:	e8 d0 fe ff ff       	call   800c98 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800dc8:	83 c4 08             	add    $0x8,%esp
  800dcb:	6a 02                	push   $0x2
  800dcd:	53                   	push   %ebx
  800dce:	e8 9a fd ff ff       	call   800b6d <sys_env_set_status>
  800dd3:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  800dd6:	89 da                	mov    %ebx,%edx

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	79 12                	jns    800dee <fork+0xb8>
		panic("sys_env_set_status: %e", r);
  800ddc:	50                   	push   %eax
  800ddd:	68 f5 15 80 00       	push   $0x8015f5
  800de2:	6a 44                	push   $0x44
  800de4:	68 b6 15 80 00       	push   $0x8015b6
  800de9:	e8 32 01 00 00       	call   800f20 <_panic>

	return envid;
}
  800dee:	89 d0                	mov    %edx,%eax
  800df0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <sfork>:

// Challenge!
int
sfork(void)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dfb:	68 0c 16 80 00       	push   $0x80160c
  800e00:	6a 4d                	push   $0x4d
  800e02:	68 b6 15 80 00       	push   $0x8015b6
  800e07:	e8 14 01 00 00       	call   800f20 <_panic>

00800e0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e17:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	75 05                	jne    800e23 <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  800e1e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	e8 2a fe ff ff       	call   800c56 <sys_ipc_recv>
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	79 16                	jns    800e49 <ipc_recv+0x3d>
		if (from_env_store)
  800e33:	85 db                	test   %ebx,%ebx
  800e35:	74 06                	je     800e3d <ipc_recv+0x31>
			*from_env_store = 0;
  800e37:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  800e3d:	85 f6                	test   %esi,%esi
  800e3f:	74 34                	je     800e75 <ipc_recv+0x69>
			*perm_store = 0;
  800e41:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  800e47:	eb 2c                	jmp    800e75 <ipc_recv+0x69>
	}

	if (from_env_store)
  800e49:	85 db                	test   %ebx,%ebx
  800e4b:	74 0a                	je     800e57 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  800e4d:	a1 04 20 80 00       	mov    0x802004,%eax
  800e52:	8b 40 74             	mov    0x74(%eax),%eax
  800e55:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  800e57:	85 f6                	test   %esi,%esi
  800e59:	74 12                	je     800e6d <ipc_recv+0x61>
  800e5b:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800e61:	8b 42 78             	mov    0x78(%edx),%eax
  800e64:	85 c0                	test   %eax,%eax
  800e66:	74 05                	je     800e6d <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  800e68:	8b 42 78             	mov    0x78(%edx),%eax
  800e6b:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  800e6d:	a1 04 20 80 00       	mov    0x802004,%eax
  800e72:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    

00800e7c <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  800e8e:	85 db                	test   %ebx,%ebx
  800e90:	74 10                	je     800ea2 <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  800e92:	ff 75 14             	pushl  0x14(%ebp)
  800e95:	53                   	push   %ebx
  800e96:	56                   	push   %esi
  800e97:	57                   	push   %edi
  800e98:	e8 96 fd ff ff       	call   800c33 <sys_ipc_try_send>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	eb 11                	jmp    800eb3 <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  800ea2:	6a 00                	push   $0x0
  800ea4:	68 00 00 c0 ee       	push   $0xeec00000
  800ea9:	56                   	push   %esi
  800eaa:	57                   	push   %edi
  800eab:	e8 83 fd ff ff       	call   800c33 <sys_ipc_try_send>
  800eb0:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	74 1e                	je     800ed5 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  800eb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800eba:	74 12                	je     800ece <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  800ebc:	50                   	push   %eax
  800ebd:	68 24 16 80 00       	push   $0x801624
  800ec2:	6a 4a                	push   $0x4a
  800ec4:	68 48 16 80 00       	push   $0x801648
  800ec9:	e8 52 00 00 00       	call   800f20 <_panic>
		}
		sys_yield();
  800ece:	e8 b4 fb ff ff       	call   800a87 <sys_yield>
  800ed3:	eb b9                	jmp    800e8e <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  800ed5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed8:	5b                   	pop    %ebx
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	53                   	push   %ebx
  800ee1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800ee4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	c1 e0 05             	shl    $0x5,%eax
  800eee:	29 d0                	sub    %edx,%eax
  800ef0:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800ef7:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  800efd:	8b 40 50             	mov    0x50(%eax),%eax
  800f00:	39 d8                	cmp    %ebx,%eax
  800f02:	75 0b                	jne    800f0f <ipc_find_env+0x32>
			return envs[i].env_id;
  800f04:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  800f0a:	8b 40 40             	mov    0x40(%eax),%eax
  800f0d:	eb 0e                	jmp    800f1d <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f0f:	42                   	inc    %edx
  800f10:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800f16:	7e d1                	jle    800ee9 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f1d:	5b                   	pop    %ebx
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	53                   	push   %ebx
  800f24:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800f27:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f2a:	ff 75 0c             	pushl  0xc(%ebp)
  800f2d:	ff 75 08             	pushl  0x8(%ebp)
  800f30:	ff 35 00 20 80 00    	pushl  0x802000
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	e8 2a fb ff ff       	call   800a68 <sys_getenvid>
  800f3e:	83 c4 08             	add    $0x8,%esp
  800f41:	50                   	push   %eax
  800f42:	68 54 16 80 00       	push   $0x801654
  800f47:	e8 64 f2 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f4c:	83 c4 18             	add    $0x18,%esp
  800f4f:	53                   	push   %ebx
  800f50:	ff 75 10             	pushl  0x10(%ebp)
  800f53:	e8 07 f2 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  800f58:	c7 04 24 67 12 80 00 	movl   $0x801267,(%esp)
  800f5f:	e8 4c f2 ff ff       	call   8001b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800f64:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800f67:	cc                   	int3   
  800f68:	eb fd                	jmp    800f67 <_panic+0x47>
	...

00800f6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	83 ec 14             	sub    $0x14,%esp
  800f74:	8b 55 14             	mov    0x14(%ebp),%edx
  800f77:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f80:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f82:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800f85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800f88:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800f8b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f8d:	75 11                	jne    800fa0 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800f8f:	39 f8                	cmp    %edi,%eax
  800f91:	76 4d                	jbe    800fe0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f93:	89 fa                	mov    %edi,%edx
  800f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f98:	f7 75 e4             	divl   -0x1c(%ebp)
  800f9b:	89 c7                	mov    %eax,%edi
  800f9d:	eb 09                	jmp    800fa8 <__udivdi3+0x3c>
  800f9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fa0:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800fa3:	76 17                	jbe    800fbc <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800fa5:	31 ff                	xor    %edi,%edi
  800fa7:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800fa8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800faf:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fb2:	83 c4 14             	add    $0x14,%esp
  800fb5:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fb6:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fb8:	5f                   	pop    %edi
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fbc:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800fc0:	89 c7                	mov    %eax,%edi
  800fc2:	83 f7 1f             	xor    $0x1f,%edi
  800fc5:	75 4d                	jne    801014 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fc7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fca:	77 0a                	ja     800fd6 <__udivdi3+0x6a>
  800fcc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800fcf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fd1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800fd4:	72 d2                	jb     800fa8 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800fd6:	bf 01 00 00 00       	mov    $0x1,%edi
  800fdb:	eb cb                	jmp    800fa8 <__udivdi3+0x3c>
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fe0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	75 0e                	jne    800ff5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fe7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fec:	31 c9                	xor    %ecx,%ecx
  800fee:	31 d2                	xor    %edx,%edx
  800ff0:	f7 f1                	div    %ecx
  800ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	31 d2                	xor    %edx,%edx
  800ff9:	f7 75 e4             	divl   -0x1c(%ebp)
  800ffc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801002:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801005:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801008:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80100b:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80100d:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80100e:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801010:	5f                   	pop    %edi
  801011:	c9                   	leave  
  801012:	c3                   	ret    
  801013:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801014:	b8 20 00 00 00       	mov    $0x20,%eax
  801019:	29 f8                	sub    %edi,%eax
  80101b:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  80101e:	89 f9                	mov    %edi,%ecx
  801020:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801023:	d3 e2                	shl    %cl,%edx
  801025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801028:	8a 4d e8             	mov    -0x18(%ebp),%cl
  80102b:	d3 e8                	shr    %cl,%eax
  80102d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  80102f:	89 f9                	mov    %edi,%ecx
  801031:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801034:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801037:	8a 4d e8             	mov    -0x18(%ebp),%cl
  80103a:	89 f2                	mov    %esi,%edx
  80103c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  80103e:	89 f9                	mov    %edi,%ecx
  801040:	d3 e6                	shl    %cl,%esi
  801042:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801045:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801048:	d3 e8                	shr    %cl,%eax
  80104a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  80104c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80104e:	89 f0                	mov    %esi,%eax
  801050:	f7 75 f4             	divl   -0xc(%ebp)
  801053:	89 d6                	mov    %edx,%esi
  801055:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801057:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  80105a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80105f:	39 f2                	cmp    %esi,%edx
  801061:	77 0f                	ja     801072 <__udivdi3+0x106>
  801063:	0f 85 3f ff ff ff    	jne    800fa8 <__udivdi3+0x3c>
  801069:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80106c:	0f 86 36 ff ff ff    	jbe    800fa8 <__udivdi3+0x3c>
		{
		  q0--;
  801072:	4f                   	dec    %edi
  801073:	e9 30 ff ff ff       	jmp    800fa8 <__udivdi3+0x3c>

00801078 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	83 ec 30             	sub    $0x30,%esp
  801080:	8b 55 14             	mov    0x14(%ebp),%edx
  801083:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  801086:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  801088:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80108b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  80108d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801093:	85 ff                	test   %edi,%edi
  801095:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80109c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8010a3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  8010a9:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010ac:	75 3e                	jne    8010ec <__umoddi3+0x74>
    {
      if (d0 > n1)
  8010ae:	39 d6                	cmp    %edx,%esi
  8010b0:	0f 86 a2 00 00 00    	jbe    801158 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010b6:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8010b8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8010bb:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010bd:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8010c0:	74 1b                	je     8010dd <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  8010c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  8010c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8010cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010d5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8010d8:	89 10                	mov    %edx,(%eax)
  8010da:	89 48 04             	mov    %ecx,0x4(%eax)
  8010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010e3:	83 c4 30             	add    $0x30,%esp
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    
  8010ea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010ec:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  8010ef:	76 1f                	jbe    801110 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8010f1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  8010f4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8010f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  8010fa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  8010fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801100:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801103:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801106:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801109:	83 c4 30             	add    $0x30,%esp
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801110:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801113:	83 f0 1f             	xor    $0x1f,%eax
  801116:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801119:	75 61                	jne    80117c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80111b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  80111e:	77 05                	ja     801125 <__umoddi3+0xad>
  801120:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  801123:	72 10                	jb     801135 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801125:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801128:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80112b:	29 f0                	sub    %esi,%eax
  80112d:	19 fa                	sbb    %edi,%edx
  80112f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801132:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  801135:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801138:	85 d2                	test   %edx,%edx
  80113a:	74 a1                	je     8010dd <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  80113c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  80113f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801142:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  801145:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801148:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80114b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80114e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801151:	89 01                	mov    %eax,(%ecx)
  801153:	89 51 04             	mov    %edx,0x4(%ecx)
  801156:	eb 85                	jmp    8010dd <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801158:	85 f6                	test   %esi,%esi
  80115a:	75 0b                	jne    801167 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80115c:	b8 01 00 00 00       	mov    $0x1,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f6                	div    %esi
  801165:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801167:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80116a:	89 fa                	mov    %edi,%edx
  80116c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80116e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801171:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801174:	f7 f6                	div    %esi
  801176:	e9 3d ff ff ff       	jmp    8010b8 <__umoddi3+0x40>
  80117b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80117c:	b8 20 00 00 00       	mov    $0x20,%eax
  801181:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  801184:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801187:	89 fa                	mov    %edi,%edx
  801189:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  80118c:	d3 e2                	shl    %cl,%edx
  80118e:	89 f0                	mov    %esi,%eax
  801190:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801193:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  801195:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801198:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80119a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80119c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80119f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011a2:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8011a4:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8011a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8011a9:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011ac:	d3 e0                	shl    %cl,%eax
  8011ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8011b1:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b7:	d3 e8                	shr    %cl,%eax
  8011b9:	0b 45 cc             	or     -0x34(%ebp),%eax
  8011bc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  8011bf:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011c2:	f7 f7                	div    %edi
  8011c4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011c7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8011ca:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011cc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8011cf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011d2:	77 0a                	ja     8011de <__umoddi3+0x166>
  8011d4:	75 12                	jne    8011e8 <__umoddi3+0x170>
  8011d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8011dc:	76 0a                	jbe    8011e8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8011de:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8011e1:	29 f1                	sub    %esi,%ecx
  8011e3:	19 fa                	sbb    %edi,%edx
  8011e5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  8011e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	0f 84 ea fe ff ff    	je     8010dd <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8011f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8011f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f9:	2b 45 c8             	sub    -0x38(%ebp),%eax
  8011fc:	19 d1                	sbb    %edx,%ecx
  8011fe:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801201:	89 ca                	mov    %ecx,%edx
  801203:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801206:	d3 e2                	shl    %cl,%edx
  801208:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80120b:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80120e:	d3 e8                	shr    %cl,%eax
  801210:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  801212:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801215:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801217:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  80121a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80121d:	e9 ad fe ff ff       	jmp    8010cf <__umoddi3+0x57>
