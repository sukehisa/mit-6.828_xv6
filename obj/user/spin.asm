
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 83 00 00 00       	call   8000b4 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 00 11 80 00       	push   $0x801100
  800040:	e8 5b 01 00 00       	call   8001a0 <cprintf>
	// this is temporarily fork() -> dumbfork
	if ((env = fork()) == 0) {
  800045:	e8 dc 0c 00 00       	call   800d26 <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 78 11 80 00       	push   $0x801178
  80005b:	e8 40 01 00 00       	call   8001a0 <cprintf>
		while (1)
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 28 11 80 00       	push   $0x801128
  80006d:	e8 2e 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800072:	e8 00 0a 00 00       	call   800a77 <sys_yield>
	sys_yield();
  800077:	e8 fb 09 00 00       	call   800a77 <sys_yield>
	sys_yield();
  80007c:	e8 f6 09 00 00       	call   800a77 <sys_yield>
	sys_yield();
  800081:	e8 f1 09 00 00       	call   800a77 <sys_yield>
	sys_yield();
  800086:	e8 ec 09 00 00       	call   800a77 <sys_yield>
	sys_yield();
  80008b:	e8 e7 09 00 00       	call   800a77 <sys_yield>
	sys_yield();
  800090:	e8 e2 09 00 00       	call   800a77 <sys_yield>
	sys_yield();
  800095:	e8 dd 09 00 00       	call   800a77 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 50 11 80 00 	movl   $0x801150,(%esp)
  8000a1:	e8 fa 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 69 09 00 00       	call   800a17 <sys_env_destroy>
}
  8000ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    
	...

008000b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000bf:	e8 94 09 00 00       	call   800a58 <sys_getenvid>
  8000c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c9:	89 c2                	mov    %eax,%edx
  8000cb:	c1 e2 05             	shl    $0x5,%edx
  8000ce:	29 c2                	sub    %eax,%edx
  8000d0:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000d7:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000dd:	85 f6                	test   %esi,%esi
  8000df:	7e 07                	jle    8000e8 <libmain+0x34>
		binaryname = argv[0];
  8000e1:	8b 03                	mov    (%ebx),%eax
  8000e3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	53                   	push   %ebx
  8000ec:	56                   	push   %esi
  8000ed:	e8 42 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f2:	e8 09 00 00 00       	call   800100 <exit>
}
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    
	...

00800100 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800106:	6a 00                	push   $0x0
  800108:	e8 0a 09 00 00       	call   800a17 <sys_env_destroy>
}
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    
	...

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 04             	sub    $0x4,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  800123:	40                   	inc    %eax
  800124:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 1a                	jne    800147 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	68 ff 00 00 00       	push   $0xff
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	50                   	push   %eax
  800139:	e8 96 08 00 00       	call   8009d4 <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800144:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800147:	ff 43 04             	incl   0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 10 01 80 00       	push   $0x800110
  80017e:	e8 49 01 00 00       	call   8002cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80018c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 3c 08 00 00       	call   8009d4 <sys_cputs>

	return b.cnt;
  800198:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c6:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ce:	39 fa                	cmp    %edi,%edx
  8001d0:	77 39                	ja     80020b <printnum+0x57>
  8001d2:	72 04                	jb     8001d8 <printnum+0x24>
  8001d4:	39 f0                	cmp    %esi,%eax
  8001d6:	77 33                	ja     80020b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 20             	pushl  0x20(%ebp)
  8001de:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 18             	pushl  0x18(%ebp)
  8001e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ed:	52                   	push   %edx
  8001ee:	50                   	push   %eax
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	e8 52 0c 00 00       	call   800e48 <__udivdi3>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	52                   	push   %edx
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 ae ff ff ff       	call   8001b4 <printnum>
  800206:	83 c4 20             	add    $0x20,%esp
  800209:	eb 19                	jmp    800224 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020b:	4b                   	dec    %ebx
  80020c:	85 db                	test   %ebx,%ebx
  80020e:	7e 14                	jle    800224 <printnum+0x70>
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	ff 75 0c             	pushl  0xc(%ebp)
  800216:	ff 75 20             	pushl  0x20(%ebp)
  800219:	ff 55 08             	call   *0x8(%ebp)
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	4b                   	dec    %ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ec                	jg     800210 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	ff 75 0c             	pushl  0xc(%ebp)
  80022a:	8b 45 18             	mov    0x18(%ebp),%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
  800232:	83 ec 04             	sub    $0x4,%esp
  800235:	52                   	push   %edx
  800236:	50                   	push   %eax
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	e8 16 0d 00 00       	call   800f54 <__umoddi3>
  80023e:	83 c4 14             	add    $0x14,%esp
  800241:	0f be 80 b2 12 80 00 	movsbl 0x8012b2(%eax),%eax
  800248:	50                   	push   %eax
  800249:	ff 55 08             	call   *0x8(%ebp)
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80025d:	83 f8 01             	cmp    $0x1,%eax
  800260:	7e 0e                	jle    800270 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800262:	8b 11                	mov    (%ecx),%edx
  800264:	8d 42 08             	lea    0x8(%edx),%eax
  800267:	89 01                	mov    %eax,(%ecx)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x3e>
	else if (lflag)
  800270:	85 c0                	test   %eax,%eax
  800272:	74 10                	je     800284 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800274:	8b 11                	mov    (%ecx),%edx
  800276:	8d 42 04             	lea    0x4(%edx),%eax
  800279:	89 01                	mov    %eax,(%ecx)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 11                	mov    (%ecx),%edx
  800286:	8d 42 04             	lea    0x4(%edx),%eax
  800289:	89 01                	mov    %eax,(%ecx)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80029d:	83 f8 01             	cmp    $0x1,%eax
  8002a0:	7e 0e                	jle    8002b0 <getint+0x1c>
		return va_arg(*ap, long long);
  8002a2:	8b 11                	mov    (%ecx),%edx
  8002a4:	8d 42 08             	lea    0x8(%edx),%eax
  8002a7:	89 01                	mov    %eax,(%ecx)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	8b 52 04             	mov    0x4(%edx),%edx
  8002ae:	eb 1a                	jmp    8002ca <getint+0x36>
	else if (lflag)
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 0c                	je     8002c0 <getint+0x2c>
		return va_arg(*ap, long);
  8002b4:	8b 01                	mov    (%ecx),%eax
  8002b6:	8d 50 04             	lea    0x4(%eax),%edx
  8002b9:	89 11                	mov    %edx,(%ecx)
  8002bb:	8b 00                	mov    (%eax),%eax
  8002bd:	99                   	cltd   
  8002be:	eb 0a                	jmp    8002ca <getint+0x36>
	else
		return va_arg(*ap, int);
  8002c0:	8b 01                	mov    (%ecx),%eax
  8002c2:	8d 50 04             	lea    0x4(%eax),%edx
  8002c5:	89 11                	mov    %edx,(%ecx)
  8002c7:	8b 00                	mov    (%eax),%eax
  8002c9:	99                   	cltd   
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 1c             	sub    $0x1c,%esp
  8002d5:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8002d8:	0f b6 0b             	movzbl (%ebx),%ecx
  8002db:	43                   	inc    %ebx
  8002dc:	83 f9 25             	cmp    $0x25,%ecx
  8002df:	74 1e                	je     8002ff <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e1:	85 c9                	test   %ecx,%ecx
  8002e3:	0f 84 dc 02 00 00    	je     8005c5 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 75 0c             	pushl  0xc(%ebp)
  8002ef:	51                   	push   %ecx
  8002f0:	ff 55 08             	call   *0x8(%ebp)
  8002f3:	83 c4 10             	add    $0x10,%esp
  8002f6:	0f b6 0b             	movzbl (%ebx),%ecx
  8002f9:	43                   	inc    %ebx
  8002fa:	83 f9 25             	cmp    $0x25,%ecx
  8002fd:	75 e2                	jne    8002e1 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002ff:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800303:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80030a:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80030f:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800314:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	0f b6 0b             	movzbl (%ebx),%ecx
  80031e:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800321:	43                   	inc    %ebx
  800322:	83 f8 55             	cmp    $0x55,%eax
  800325:	0f 87 75 02 00 00    	ja     8005a0 <vprintfmt+0x2d4>
  80032b:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800332:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800336:	eb e3                	jmp    80031b <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800338:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  80033c:	eb dd                	jmp    80031b <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033e:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800343:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800346:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  80034a:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80034d:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800350:	83 f8 09             	cmp    $0x9,%eax
  800353:	77 28                	ja     80037d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800355:	43                   	inc    %ebx
  800356:	eb eb                	jmp    800343 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800358:	8b 55 14             	mov    0x14(%ebp),%edx
  80035b:	8d 42 04             	lea    0x4(%edx),%eax
  80035e:	89 45 14             	mov    %eax,0x14(%ebp)
  800361:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800363:	eb 18                	jmp    80037d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800365:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800369:	79 b0                	jns    80031b <vprintfmt+0x4f>
				width = 0;
  80036b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800372:	eb a7                	jmp    80031b <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800374:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80037b:	eb 9e                	jmp    80031b <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80037d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800381:	79 98                	jns    80031b <vprintfmt+0x4f>
				width = precision, precision = -1;
  800383:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800386:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80038b:	eb 8e                	jmp    80031b <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038d:	47                   	inc    %edi
			goto reswitch;
  80038e:	eb 8b                	jmp    80031b <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	8b 55 14             	mov    0x14(%ebp),%edx
  800399:	8d 42 04             	lea    0x4(%edx),%eax
  80039c:	89 45 14             	mov    %eax,0x14(%ebp)
  80039f:	ff 32                	pushl  (%edx)
  8003a1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
  8003a7:	e9 2c ff ff ff       	jmp    8002d8 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ac:	8b 55 14             	mov    0x14(%ebp),%edx
  8003af:	8d 42 04             	lea    0x4(%edx),%eax
  8003b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8003b5:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	79 02                	jns    8003bd <vprintfmt+0xf1>
				err = -err;
  8003bb:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bd:	83 f8 0f             	cmp    $0xf,%eax
  8003c0:	7f 0b                	jg     8003cd <vprintfmt+0x101>
  8003c2:	8b 3c 85 00 13 80 00 	mov    0x801300(,%eax,4),%edi
  8003c9:	85 ff                	test   %edi,%edi
  8003cb:	75 19                	jne    8003e6 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  8003cd:	50                   	push   %eax
  8003ce:	68 c3 12 80 00       	push   $0x8012c3
  8003d3:	ff 75 0c             	pushl  0xc(%ebp)
  8003d6:	ff 75 08             	pushl  0x8(%ebp)
  8003d9:	e8 ef 01 00 00       	call   8005cd <printfmt>
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	e9 f2 fe ff ff       	jmp    8002d8 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8003e6:	57                   	push   %edi
  8003e7:	68 cc 12 80 00       	push   $0x8012cc
  8003ec:	ff 75 0c             	pushl  0xc(%ebp)
  8003ef:	ff 75 08             	pushl  0x8(%ebp)
  8003f2:	e8 d6 01 00 00       	call   8005cd <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			break;
  8003fa:	e9 d9 fe ff ff       	jmp    8002d8 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ff:	8b 55 14             	mov    0x14(%ebp),%edx
  800402:	8d 42 04             	lea    0x4(%edx),%eax
  800405:	89 45 14             	mov    %eax,0x14(%ebp)
  800408:	8b 3a                	mov    (%edx),%edi
  80040a:	85 ff                	test   %edi,%edi
  80040c:	75 05                	jne    800413 <vprintfmt+0x147>
				p = "(null)";
  80040e:	bf cf 12 80 00       	mov    $0x8012cf,%edi
			if (width > 0 && padc != '-')
  800413:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800417:	7e 3b                	jle    800454 <vprintfmt+0x188>
  800419:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  80041d:	74 35                	je     800454 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	56                   	push   %esi
  800423:	57                   	push   %edi
  800424:	e8 58 02 00 00       	call   800681 <strnlen>
  800429:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800433:	7e 1f                	jle    800454 <vprintfmt+0x188>
  800435:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 0c             	pushl  0xc(%ebp)
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	ff 4d f0             	decl   -0x10(%ebp)
  80044e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800452:	7f e8                	jg     80043c <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800454:	0f be 0f             	movsbl (%edi),%ecx
  800457:	47                   	inc    %edi
  800458:	85 c9                	test   %ecx,%ecx
  80045a:	74 44                	je     8004a0 <vprintfmt+0x1d4>
  80045c:	85 f6                	test   %esi,%esi
  80045e:	78 03                	js     800463 <vprintfmt+0x197>
  800460:	4e                   	dec    %esi
  800461:	78 3d                	js     8004a0 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800463:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800467:	74 18                	je     800481 <vprintfmt+0x1b5>
  800469:	8d 41 e0             	lea    -0x20(%ecx),%eax
  80046c:	83 f8 5e             	cmp    $0x5e,%eax
  80046f:	76 10                	jbe    800481 <vprintfmt+0x1b5>
					putch('?', putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 0c             	pushl  0xc(%ebp)
  800477:	6a 3f                	push   $0x3f
  800479:	ff 55 08             	call   *0x8(%ebp)
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	eb 0d                	jmp    80048e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	ff 75 0c             	pushl  0xc(%ebp)
  800487:	51                   	push   %ecx
  800488:	ff 55 08             	call   *0x8(%ebp)
  80048b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048e:	ff 4d f0             	decl   -0x10(%ebp)
  800491:	0f be 0f             	movsbl (%edi),%ecx
  800494:	47                   	inc    %edi
  800495:	85 c9                	test   %ecx,%ecx
  800497:	74 07                	je     8004a0 <vprintfmt+0x1d4>
  800499:	85 f6                	test   %esi,%esi
  80049b:	78 c6                	js     800463 <vprintfmt+0x197>
  80049d:	4e                   	dec    %esi
  80049e:	79 c3                	jns    800463 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004a4:	0f 8e 2e fe ff ff    	jle    8002d8 <vprintfmt+0xc>
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 0c             	pushl  0xc(%ebp)
  8004b0:	6a 20                	push   $0x20
  8004b2:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	ff 4d f0             	decl   -0x10(%ebp)
  8004bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004bf:	7f e9                	jg     8004aa <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  8004c1:	e9 12 fe ff ff       	jmp    8002d8 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004c6:	57                   	push   %edi
  8004c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 c4 fd ff ff       	call   800294 <getint>
  8004d0:	89 c6                	mov    %eax,%esi
  8004d2:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004d4:	83 c4 08             	add    $0x8,%esp
  8004d7:	85 d2                	test   %edx,%edx
  8004d9:	79 15                	jns    8004f0 <vprintfmt+0x224>
				putch('-', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	6a 2d                	push   $0x2d
  8004e3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004e6:	f7 de                	neg    %esi
  8004e8:	83 d7 00             	adc    $0x0,%edi
  8004eb:	f7 df                	neg    %edi
  8004ed:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004f0:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004f5:	eb 76                	jmp    80056d <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004f7:	57                   	push   %edi
  8004f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	e8 53 fd ff ff       	call   800254 <getuint>
  800501:	89 c6                	mov    %eax,%esi
  800503:	89 d7                	mov    %edx,%edi
			base = 10;
  800505:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80050a:	83 c4 08             	add    $0x8,%esp
  80050d:	eb 5e                	jmp    80056d <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80050f:	57                   	push   %edi
  800510:	8d 45 14             	lea    0x14(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	e8 3b fd ff ff       	call   800254 <getuint>
  800519:	89 c6                	mov    %eax,%esi
  80051b:	89 d7                	mov    %edx,%edi
			base = 8;
  80051d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800522:	83 c4 08             	add    $0x8,%esp
  800525:	eb 46                	jmp    80056d <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	6a 30                	push   $0x30
  80052f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800532:	83 c4 08             	add    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 78                	push   $0x78
  80053a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80053d:	8b 55 14             	mov    0x14(%ebp),%edx
  800540:	8d 42 04             	lea    0x4(%edx),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
  800546:	8b 32                	mov    (%edx),%esi
  800548:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80054d:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	eb 16                	jmp    80056d <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800557:	57                   	push   %edi
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	e8 f3 fc ff ff       	call   800254 <getuint>
  800561:	89 c6                	mov    %eax,%esi
  800563:	89 d7                	mov    %edx,%edi
			base = 16;
  800565:	ba 10 00 00 00       	mov    $0x10,%edx
  80056a:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  80056d:	83 ec 04             	sub    $0x4,%esp
  800570:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800574:	50                   	push   %eax
  800575:	ff 75 f0             	pushl  -0x10(%ebp)
  800578:	52                   	push   %edx
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	ff 75 08             	pushl  0x8(%ebp)
  800581:	e8 2e fc ff ff       	call   8001b4 <printnum>
			break;
  800586:	83 c4 20             	add    $0x20,%esp
  800589:	e9 4a fd ff ff       	jmp    8002d8 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	ff 75 0c             	pushl  0xc(%ebp)
  800594:	51                   	push   %ecx
  800595:	ff 55 08             	call   *0x8(%ebp)
			break;
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	e9 38 fd ff ff       	jmp    8002d8 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	ff 75 0c             	pushl  0xc(%ebp)
  8005a6:	6a 25                	push   $0x25
  8005a8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005ab:	4b                   	dec    %ebx
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005b3:	0f 84 1f fd ff ff    	je     8002d8 <vprintfmt+0xc>
  8005b9:	4b                   	dec    %ebx
  8005ba:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005be:	75 f9                	jne    8005b9 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005c0:	e9 13 fd ff ff       	jmp    8002d8 <vprintfmt+0xc>
		}
	}
}
  8005c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c8:	5b                   	pop    %ebx
  8005c9:	5e                   	pop    %esi
  8005ca:	5f                   	pop    %edi
  8005cb:	c9                   	leave  
  8005cc:	c3                   	ret    

008005cd <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005cd:	55                   	push   %ebp
  8005ce:	89 e5                	mov    %esp,%ebp
  8005d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d6:	50                   	push   %eax
  8005d7:	ff 75 10             	pushl  0x10(%ebp)
  8005da:	ff 75 0c             	pushl  0xc(%ebp)
  8005dd:	ff 75 08             	pushl  0x8(%ebp)
  8005e0:	e8 e7 fc ff ff       	call   8002cc <vprintfmt>
	va_end(ap);
}
  8005e5:	c9                   	leave  
  8005e6:	c3                   	ret    

008005e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005ed:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005f0:	8b 0a                	mov    (%edx),%ecx
  8005f2:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005f5:	73 07                	jae    8005fe <sprintputch+0x17>
		*b->buf++ = ch;
  8005f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fa:	88 01                	mov    %al,(%ecx)
  8005fc:	ff 02                	incl   (%edx)
}
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 18             	sub    $0x18,%esp
  800606:	8b 55 08             	mov    0x8(%ebp),%edx
  800609:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80060c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80060f:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800613:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800616:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  80061d:	85 d2                	test   %edx,%edx
  80061f:	74 04                	je     800625 <vsnprintf+0x25>
  800621:	85 c9                	test   %ecx,%ecx
  800623:	7f 07                	jg     80062c <vsnprintf+0x2c>
		return -E_INVAL;
  800625:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80062a:	eb 1d                	jmp    800649 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80062c:	ff 75 14             	pushl  0x14(%ebp)
  80062f:	ff 75 10             	pushl  0x10(%ebp)
  800632:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800635:	50                   	push   %eax
  800636:	68 e7 05 80 00       	push   $0x8005e7
  80063b:	e8 8c fc ff ff       	call   8002cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800640:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800643:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800649:	c9                   	leave  
  80064a:	c3                   	ret    

0080064b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800654:	50                   	push   %eax
  800655:	ff 75 10             	pushl  0x10(%ebp)
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	ff 75 08             	pushl  0x8(%ebp)
  80065e:	e8 9d ff ff ff       	call   800600 <vsnprintf>
	va_end(ap);

	return rc;
}
  800663:	c9                   	leave  
  800664:	c3                   	ret    
  800665:	00 00                	add    %al,(%eax)
	...

00800668 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80066e:	b8 00 00 00 00       	mov    $0x0,%eax
  800673:	80 3a 00             	cmpb   $0x0,(%edx)
  800676:	74 07                	je     80067f <strlen+0x17>
		n++;
  800678:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800679:	42                   	inc    %edx
  80067a:	80 3a 00             	cmpb   $0x0,(%edx)
  80067d:	75 f9                	jne    800678 <strlen+0x10>
		n++;
	return n;
}
  80067f:	c9                   	leave  
  800680:	c3                   	ret    

00800681 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800687:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80068a:	b8 00 00 00 00       	mov    $0x0,%eax
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 0f                	je     8006a2 <strnlen+0x21>
  800693:	80 39 00             	cmpb   $0x0,(%ecx)
  800696:	74 0a                	je     8006a2 <strnlen+0x21>
		n++;
  800698:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800699:	41                   	inc    %ecx
  80069a:	4a                   	dec    %edx
  80069b:	74 05                	je     8006a2 <strnlen+0x21>
  80069d:	80 39 00             	cmpb   $0x0,(%ecx)
  8006a0:	75 f6                	jne    800698 <strnlen+0x17>
		n++;
	return n;
}
  8006a2:	c9                   	leave  
  8006a3:	c3                   	ret    

008006a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	53                   	push   %ebx
  8006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006ae:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006b0:	8a 02                	mov    (%edx),%al
  8006b2:	42                   	inc    %edx
  8006b3:	88 01                	mov    %al,(%ecx)
  8006b5:	41                   	inc    %ecx
  8006b6:	84 c0                	test   %al,%al
  8006b8:	75 f6                	jne    8006b0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ba:	89 d8                	mov    %ebx,%eax
  8006bc:	5b                   	pop    %ebx
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	53                   	push   %ebx
  8006c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006c6:	53                   	push   %ebx
  8006c7:	e8 9c ff ff ff       	call   800668 <strlen>
	strcpy(dst + len, src);
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006d2:	50                   	push   %eax
  8006d3:	e8 cc ff ff ff       	call   8006a4 <strcpy>
	return dst;
}
  8006d8:	89 d8                	mov    %ebx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006ee:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f5:	39 f3                	cmp    %esi,%ebx
  8006f7:	73 10                	jae    800709 <strncpy+0x2a>
		*dst++ = *src;
  8006f9:	8a 02                	mov    (%edx),%al
  8006fb:	88 01                	mov    %al,(%ecx)
  8006fd:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006fe:	80 3a 01             	cmpb   $0x1,(%edx)
  800701:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800704:	43                   	inc    %ebx
  800705:	39 f3                	cmp    %esi,%ebx
  800707:	72 f0                	jb     8006f9 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800709:	89 f8                	mov    %edi,%eax
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	56                   	push   %esi
  800714:	53                   	push   %ebx
  800715:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80071e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800720:	85 d2                	test   %edx,%edx
  800722:	74 19                	je     80073d <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800724:	4a                   	dec    %edx
  800725:	74 13                	je     80073a <strlcpy+0x2a>
  800727:	80 39 00             	cmpb   $0x0,(%ecx)
  80072a:	74 0e                	je     80073a <strlcpy+0x2a>
  80072c:	8a 01                	mov    (%ecx),%al
  80072e:	41                   	inc    %ecx
  80072f:	88 03                	mov    %al,(%ebx)
  800731:	43                   	inc    %ebx
  800732:	4a                   	dec    %edx
  800733:	74 05                	je     80073a <strlcpy+0x2a>
  800735:	80 39 00             	cmpb   $0x0,(%ecx)
  800738:	75 f2                	jne    80072c <strlcpy+0x1c>
		*dst = '\0';
  80073a:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80073d:	89 d8                	mov    %ebx,%eax
  80073f:	29 f0                	sub    %esi,%eax
}
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
  80074b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80074e:	80 3a 00             	cmpb   $0x0,(%edx)
  800751:	74 13                	je     800766 <strcmp+0x21>
  800753:	8a 02                	mov    (%edx),%al
  800755:	3a 01                	cmp    (%ecx),%al
  800757:	75 0d                	jne    800766 <strcmp+0x21>
  800759:	42                   	inc    %edx
  80075a:	41                   	inc    %ecx
  80075b:	80 3a 00             	cmpb   $0x0,(%edx)
  80075e:	74 06                	je     800766 <strcmp+0x21>
  800760:	8a 02                	mov    (%edx),%al
  800762:	3a 01                	cmp    (%ecx),%al
  800764:	74 f3                	je     800759 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800766:	0f b6 02             	movzbl (%edx),%eax
  800769:	0f b6 11             	movzbl (%ecx),%edx
  80076c:	29 d0                	sub    %edx,%eax
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 55 08             	mov    0x8(%ebp),%edx
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	74 1f                	je     8007a0 <strncmp+0x30>
  800781:	80 3a 00             	cmpb   $0x0,(%edx)
  800784:	74 16                	je     80079c <strncmp+0x2c>
  800786:	8a 02                	mov    (%edx),%al
  800788:	3a 03                	cmp    (%ebx),%al
  80078a:	75 10                	jne    80079c <strncmp+0x2c>
  80078c:	42                   	inc    %edx
  80078d:	43                   	inc    %ebx
  80078e:	49                   	dec    %ecx
  80078f:	74 0f                	je     8007a0 <strncmp+0x30>
  800791:	80 3a 00             	cmpb   $0x0,(%edx)
  800794:	74 06                	je     80079c <strncmp+0x2c>
  800796:	8a 02                	mov    (%edx),%al
  800798:	3a 03                	cmp    (%ebx),%al
  80079a:	74 f0                	je     80078c <strncmp+0x1c>
	if (n == 0)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	75 07                	jne    8007a7 <strncmp+0x37>
		return 0;
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 0a                	jmp    8007b1 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a7:	0f b6 12             	movzbl (%edx),%edx
  8007aa:	0f b6 03             	movzbl (%ebx),%eax
  8007ad:	29 c2                	sub    %eax,%edx
  8007af:	89 d0                	mov    %edx,%eax
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007bd:	80 38 00             	cmpb   $0x0,(%eax)
  8007c0:	74 0a                	je     8007cc <strchr+0x18>
		if (*s == c)
  8007c2:	38 10                	cmp    %dl,(%eax)
  8007c4:	74 0b                	je     8007d1 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007c6:	40                   	inc    %eax
  8007c7:	80 38 00             	cmpb   $0x0,(%eax)
  8007ca:	75 f6                	jne    8007c2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007dc:	80 38 00             	cmpb   $0x0,(%eax)
  8007df:	74 0a                	je     8007eb <strfind+0x18>
		if (*s == c)
  8007e1:	38 10                	cmp    %dl,(%eax)
  8007e3:	74 06                	je     8007eb <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007e5:	40                   	inc    %eax
  8007e6:	80 38 00             	cmpb   $0x0,(%eax)
  8007e9:	75 f6                	jne    8007e1 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	57                   	push   %edi
  8007f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8007f7:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8007f9:	85 c9                	test   %ecx,%ecx
  8007fb:	74 40                	je     80083d <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800803:	75 30                	jne    800835 <memset+0x48>
  800805:	f6 c1 03             	test   $0x3,%cl
  800808:	75 2b                	jne    800835 <memset+0x48>
		c &= 0xFF;
  80080a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	c1 e0 18             	shl    $0x18,%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	c1 e2 10             	shl    $0x10,%edx
  80081d:	09 d0                	or     %edx,%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	c1 e2 08             	shl    $0x8,%edx
  800825:	09 d0                	or     %edx,%eax
  800827:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80082a:	c1 e9 02             	shr    $0x2,%ecx
  80082d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800830:	fc                   	cld    
  800831:	f3 ab                	rep stos %eax,%es:(%edi)
  800833:	eb 06                	jmp    80083b <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	fc                   	cld    
  800839:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80083b:	89 f8                	mov    %edi,%eax
}
  80083d:	5f                   	pop    %edi
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80084b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80084e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800850:	39 c6                	cmp    %eax,%esi
  800852:	73 34                	jae    800888 <memmove+0x48>
  800854:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800857:	39 c2                	cmp    %eax,%edx
  800859:	76 2d                	jbe    800888 <memmove+0x48>
		s += n;
  80085b:	89 d6                	mov    %edx,%esi
		d += n;
  80085d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800860:	f6 c2 03             	test   $0x3,%dl
  800863:	75 1b                	jne    800880 <memmove+0x40>
  800865:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086b:	75 13                	jne    800880 <memmove+0x40>
  80086d:	f6 c1 03             	test   $0x3,%cl
  800870:	75 0e                	jne    800880 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800872:	83 ef 04             	sub    $0x4,%edi
  800875:	83 ee 04             	sub    $0x4,%esi
  800878:	c1 e9 02             	shr    $0x2,%ecx
  80087b:	fd                   	std    
  80087c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087e:	eb 05                	jmp    800885 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800880:	4f                   	dec    %edi
  800881:	4e                   	dec    %esi
  800882:	fd                   	std    
  800883:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800885:	fc                   	cld    
  800886:	eb 20                	jmp    8008a8 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800888:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088e:	75 15                	jne    8008a5 <memmove+0x65>
  800890:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800896:	75 0d                	jne    8008a5 <memmove+0x65>
  800898:	f6 c1 03             	test   $0x3,%cl
  80089b:	75 08                	jne    8008a5 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  80089d:	c1 e9 02             	shr    $0x2,%ecx
  8008a0:	fc                   	cld    
  8008a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a3:	eb 03                	jmp    8008a8 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008a5:	fc                   	cld    
  8008a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008a8:	5e                   	pop    %esi
  8008a9:	5f                   	pop    %edi
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	ff 75 0c             	pushl  0xc(%ebp)
  8008b5:	ff 75 08             	pushl  0x8(%ebp)
  8008b8:	e8 83 ff ff ff       	call   800840 <memmove>
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008c9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cc:	4a                   	dec    %edx
  8008cd:	83 fa ff             	cmp    $0xffffffff,%edx
  8008d0:	74 1a                	je     8008ec <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8008d2:	8a 01                	mov    (%ecx),%al
  8008d4:	3a 03                	cmp    (%ebx),%al
  8008d6:	74 0c                	je     8008e4 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  8008d8:	0f b6 d0             	movzbl %al,%edx
  8008db:	0f b6 03             	movzbl (%ebx),%eax
  8008de:	29 c2                	sub    %eax,%edx
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	eb 0d                	jmp    8008f1 <memcmp+0x32>
		s1++, s2++;
  8008e4:	41                   	inc    %ecx
  8008e5:	43                   	inc    %ebx
  8008e6:	4a                   	dec    %edx
  8008e7:	83 fa ff             	cmp    $0xffffffff,%edx
  8008ea:	75 e6                	jne    8008d2 <memcmp+0x13>
	}

	return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800902:	39 d0                	cmp    %edx,%eax
  800904:	73 09                	jae    80090f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800906:	38 08                	cmp    %cl,(%eax)
  800908:	74 05                	je     80090f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80090a:	40                   	inc    %eax
  80090b:	39 d0                	cmp    %edx,%eax
  80090d:	72 f7                	jb     800906 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 55 08             	mov    0x8(%ebp),%edx
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800920:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800925:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80092a:	80 3a 20             	cmpb   $0x20,(%edx)
  80092d:	74 05                	je     800934 <strtol+0x23>
  80092f:	80 3a 09             	cmpb   $0x9,(%edx)
  800932:	75 0b                	jne    80093f <strtol+0x2e>
  800934:	42                   	inc    %edx
  800935:	80 3a 20             	cmpb   $0x20,(%edx)
  800938:	74 fa                	je     800934 <strtol+0x23>
  80093a:	80 3a 09             	cmpb   $0x9,(%edx)
  80093d:	74 f5                	je     800934 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80093f:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800942:	75 03                	jne    800947 <strtol+0x36>
		s++;
  800944:	42                   	inc    %edx
  800945:	eb 0b                	jmp    800952 <strtol+0x41>
	else if (*s == '-')
  800947:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80094a:	75 06                	jne    800952 <strtol+0x41>
		s++, neg = 1;
  80094c:	42                   	inc    %edx
  80094d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800952:	85 c9                	test   %ecx,%ecx
  800954:	74 05                	je     80095b <strtol+0x4a>
  800956:	83 f9 10             	cmp    $0x10,%ecx
  800959:	75 15                	jne    800970 <strtol+0x5f>
  80095b:	80 3a 30             	cmpb   $0x30,(%edx)
  80095e:	75 10                	jne    800970 <strtol+0x5f>
  800960:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800964:	75 0a                	jne    800970 <strtol+0x5f>
		s += 2, base = 16;
  800966:	83 c2 02             	add    $0x2,%edx
  800969:	b9 10 00 00 00       	mov    $0x10,%ecx
  80096e:	eb 14                	jmp    800984 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800970:	85 c9                	test   %ecx,%ecx
  800972:	75 10                	jne    800984 <strtol+0x73>
  800974:	80 3a 30             	cmpb   $0x30,(%edx)
  800977:	75 05                	jne    80097e <strtol+0x6d>
		s++, base = 8;
  800979:	42                   	inc    %edx
  80097a:	b1 08                	mov    $0x8,%cl
  80097c:	eb 06                	jmp    800984 <strtol+0x73>
	else if (base == 0)
  80097e:	85 c9                	test   %ecx,%ecx
  800980:	75 02                	jne    800984 <strtol+0x73>
		base = 10;
  800982:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800984:	8a 02                	mov    (%edx),%al
  800986:	83 e8 30             	sub    $0x30,%eax
  800989:	3c 09                	cmp    $0x9,%al
  80098b:	77 08                	ja     800995 <strtol+0x84>
			dig = *s - '0';
  80098d:	0f be 02             	movsbl (%edx),%eax
  800990:	83 e8 30             	sub    $0x30,%eax
  800993:	eb 20                	jmp    8009b5 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800995:	8a 02                	mov    (%edx),%al
  800997:	83 e8 61             	sub    $0x61,%eax
  80099a:	3c 19                	cmp    $0x19,%al
  80099c:	77 08                	ja     8009a6 <strtol+0x95>
			dig = *s - 'a' + 10;
  80099e:	0f be 02             	movsbl (%edx),%eax
  8009a1:	83 e8 57             	sub    $0x57,%eax
  8009a4:	eb 0f                	jmp    8009b5 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  8009a6:	8a 02                	mov    (%edx),%al
  8009a8:	83 e8 41             	sub    $0x41,%eax
  8009ab:	3c 19                	cmp    $0x19,%al
  8009ad:	77 12                	ja     8009c1 <strtol+0xb0>
			dig = *s - 'A' + 10;
  8009af:	0f be 02             	movsbl (%edx),%eax
  8009b2:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009b5:	39 c8                	cmp    %ecx,%eax
  8009b7:	7d 08                	jge    8009c1 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009b9:	42                   	inc    %edx
  8009ba:	0f af d9             	imul   %ecx,%ebx
  8009bd:	01 c3                	add    %eax,%ebx
  8009bf:	eb c3                	jmp    800984 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009c1:	85 f6                	test   %esi,%esi
  8009c3:	74 02                	je     8009c7 <strtol+0xb6>
		*endptr = (char *) s;
  8009c5:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009c7:	89 d8                	mov    %ebx,%eax
  8009c9:	85 ff                	test   %edi,%edi
  8009cb:	74 02                	je     8009cf <strtol+0xbe>
  8009cd:	f7 d8                	neg    %eax
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 04             	sub    $0x4,%esp
  8009dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009e8:	89 f8                	mov    %edi,%eax
  8009ea:	89 fb                	mov    %edi,%ebx
  8009ec:	89 fe                	mov    %edi,%esi
  8009ee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009f0:	83 c4 04             	add    $0x4,%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5f                   	pop    %edi
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009fe:	b8 01 00 00 00       	mov    $0x1,%eax
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a08:	89 fa                	mov    %edi,%edx
  800a0a:	89 f9                	mov    %edi,%ecx
  800a0c:	89 fb                	mov    %edi,%ebx
  800a0e:	89 fe                	mov    %edi,%esi
  800a10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 0c             	sub    $0xc,%esp
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a23:	b8 03 00 00 00       	mov    $0x3,%eax
  800a28:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2d:	89 f9                	mov    %edi,%ecx
  800a2f:	89 fb                	mov    %edi,%ebx
  800a31:	89 fe                	mov    %edi,%esi
  800a33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a35:	85 c0                	test   %eax,%eax
  800a37:	7e 17                	jle    800a50 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	50                   	push   %eax
  800a3d:	6a 03                	push   $0x3
  800a3f:	68 98 14 80 00       	push   $0x801498
  800a44:	6a 23                	push   $0x23
  800a46:	68 b5 14 80 00       	push   $0x8014b5
  800a4b:	e8 ac 03 00 00       	call   800dfc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800a5e:	b8 02 00 00 00       	mov    $0x2,%eax
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <sys_yield>:

void
sys_yield(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a87:	89 fa                	mov    %edi,%edx
  800a89:	89 f9                	mov    %edi,%ecx
  800a8b:	89 fb                	mov    %edi,%ebx
  800a8d:	89 fe                	mov    %edi,%esi
  800a8f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa8:	b8 04 00 00 00       	mov    $0x4,%eax
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	89 fe                	mov    %edi,%esi
  800ab4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	7e 17                	jle    800ad1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aba:	83 ec 0c             	sub    $0xc,%esp
  800abd:	50                   	push   %eax
  800abe:	6a 04                	push   $0x4
  800ac0:	68 98 14 80 00       	push   $0x801498
  800ac5:	6a 23                	push   $0x23
  800ac7:	68 b5 14 80 00       	push   $0x8014b5
  800acc:	e8 2b 03 00 00       	call   800dfc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	c9                   	leave  
  800ad8:	c3                   	ret    

00800ad9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aeb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800aee:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800af1:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af8:	85 c0                	test   %eax,%eax
  800afa:	7e 17                	jle    800b13 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	50                   	push   %eax
  800b00:	6a 05                	push   $0x5
  800b02:	68 98 14 80 00       	push   $0x801498
  800b07:	6a 23                	push   $0x23
  800b09:	68 b5 14 80 00       	push   $0x8014b5
  800b0e:	e8 e9 02 00 00       	call   800dfc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	89 fb                	mov    %edi,%ebx
  800b36:	89 fe                	mov    %edi,%esi
  800b38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	7e 17                	jle    800b55 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	50                   	push   %eax
  800b42:	6a 06                	push   $0x6
  800b44:	68 98 14 80 00       	push   $0x801498
  800b49:	6a 23                	push   $0x23
  800b4b:	68 b5 14 80 00       	push   $0x8014b5
  800b50:	e8 a7 02 00 00       	call   800dfc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b71:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	89 fb                	mov    %edi,%ebx
  800b78:	89 fe                	mov    %edi,%esi
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 08                	push   $0x8
  800b86:	68 98 14 80 00       	push   $0x801498
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 b5 14 80 00       	push   $0x8014b5
  800b92:	e8 65 02 00 00       	call   800dfc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bae:	b8 09 00 00 00       	mov    $0x9,%eax
  800bb3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	89 fb                	mov    %edi,%ebx
  800bba:	89 fe                	mov    %edi,%esi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 09                	push   $0x9
  800bc8:	68 98 14 80 00       	push   $0x801498
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 b5 14 80 00       	push   $0x8014b5
  800bd4:	e8 23 02 00 00       	call   800dfc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bf0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf5:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	89 fb                	mov    %edi,%ebx
  800bfc:	89 fe                	mov    %edi,%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 0a                	push   $0xa
  800c0a:	68 98 14 80 00       	push   $0x801498
  800c0f:	6a 23                	push   $0x23
  800c11:	68 b5 14 80 00       	push   $0x8014b5
  800c16:	e8 e1 01 00 00       	call   800dfc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c32:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c3a:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c52:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	89 f9                	mov    %edi,%ecx
  800c5e:	89 fb                	mov    %edi,%ebx
  800c60:	89 fe                	mov    %edi,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 0d                	push   $0xd
  800c6e:	68 98 14 80 00       	push   $0x801498
  800c73:	6a 23                	push   $0x23
  800c75:	68 b5 14 80 00       	push   $0x8014b5
  800c7a:	e8 7d 01 00 00       	call   800dfc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    
	...

00800c88 <duppage>:


/// dstenv: child's envid
void
duppage(envid_t dstenv, void *addr)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800c93:	83 ec 04             	sub    $0x4,%esp
  800c96:	6a 07                	push   $0x7
  800c98:	53                   	push   %ebx
  800c99:	56                   	push   %esi
  800c9a:	e8 f7 fd ff ff       	call   800a96 <sys_page_alloc>
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	79 12                	jns    800cb8 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800ca6:	50                   	push   %eax
  800ca7:	68 c3 14 80 00       	push   $0x8014c3
  800cac:	6a 18                	push   $0x18
  800cae:	68 d6 14 80 00       	push   $0x8014d6
  800cb3:	e8 44 01 00 00       	call   800dfc <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	6a 07                	push   $0x7
  800cbd:	68 00 00 40 00       	push   $0x400000
  800cc2:	6a 00                	push   $0x0
  800cc4:	53                   	push   %ebx
  800cc5:	56                   	push   %esi
  800cc6:	e8 0e fe ff ff       	call   800ad9 <sys_page_map>
  800ccb:	83 c4 20             	add    $0x20,%esp
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	79 12                	jns    800ce4 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  800cd2:	50                   	push   %eax
  800cd3:	68 e1 14 80 00       	push   $0x8014e1
  800cd8:	6a 1a                	push   $0x1a
  800cda:	68 d6 14 80 00       	push   $0x8014d6
  800cdf:	e8 18 01 00 00       	call   800dfc <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800ce4:	83 ec 04             	sub    $0x4,%esp
  800ce7:	68 00 10 00 00       	push   $0x1000
  800cec:	53                   	push   %ebx
  800ced:	68 00 00 40 00       	push   $0x400000
  800cf2:	e8 49 fb ff ff       	call   800840 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800cf7:	83 c4 08             	add    $0x8,%esp
  800cfa:	68 00 00 40 00       	push   $0x400000
  800cff:	6a 00                	push   $0x0
  800d01:	e8 15 fe ff ff       	call   800b1b <sys_page_unmap>
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	79 12                	jns    800d1f <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  800d0d:	50                   	push   %eax
  800d0e:	68 f2 14 80 00       	push   $0x8014f2
  800d13:	6a 1d                	push   $0x1d
  800d15:	68 d6 14 80 00       	push   $0x8014d6
  800d1a:	e8 dd 00 00 00       	call   800dfc <_panic>
}
  800d1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    

00800d26 <fork>:

envid_t
fork(void)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 04             	sub    $0x4,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800d2d:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  800d32:	89 d0                	mov    %edx,%eax
  800d34:	cd 30                	int    $0x30
  800d36:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	79 12                	jns    800d4e <fork+0x28>
		panic("sys_exofork: %e", envid);
  800d3c:	50                   	push   %eax
  800d3d:	68 05 15 80 00       	push   $0x801505
  800d42:	6a 2f                	push   $0x2f
  800d44:	68 d6 14 80 00       	push   $0x8014d6
  800d49:	e8 ae 00 00 00       	call   800dfc <_panic>
	if (envid == 0) {
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	75 25                	jne    800d77 <fork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800d52:	e8 01 fd ff ff       	call   800a58 <sys_getenvid>
  800d57:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	c1 e2 05             	shl    $0x5,%edx
  800d61:	29 c2                	sub    %eax,%edx
  800d63:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800d6a:	89 15 04 20 80 00    	mov    %edx,0x802004
		return 0;
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	eb 67                	jmp    800dde <fork+0xb8>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800d77:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800d7e:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800d85:	73 1f                	jae    800da6 <fork+0x80>
		duppage(envid, addr);
  800d87:	83 ec 08             	sub    $0x8,%esp
  800d8a:	ff 75 f8             	pushl  -0x8(%ebp)
  800d8d:	53                   	push   %ebx
  800d8e:	e8 f5 fe ff ff       	call   800c88 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  800d9d:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800da4:	72 e1                	jb     800d87 <fork+0x61>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800da6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800da9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dae:	83 ec 08             	sub    $0x8,%esp
  800db1:	50                   	push   %eax
  800db2:	53                   	push   %ebx
  800db3:	e8 d0 fe ff ff       	call   800c88 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800db8:	83 c4 08             	add    $0x8,%esp
  800dbb:	6a 02                	push   $0x2
  800dbd:	53                   	push   %ebx
  800dbe:	e8 9a fd ff ff       	call   800b5d <sys_env_set_status>
  800dc3:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  800dc6:	89 da                	mov    %ebx,%edx

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	79 12                	jns    800dde <fork+0xb8>
		panic("sys_env_set_status: %e", r);
  800dcc:	50                   	push   %eax
  800dcd:	68 15 15 80 00       	push   $0x801515
  800dd2:	6a 44                	push   $0x44
  800dd4:	68 d6 14 80 00       	push   $0x8014d6
  800dd9:	e8 1e 00 00 00       	call   800dfc <_panic>

	return envid;
}
  800dde:	89 d0                	mov    %edx,%eax
  800de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <sfork>:

// Challenge!
int
sfork(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800deb:	68 2c 15 80 00       	push   $0x80152c
  800df0:	6a 4d                	push   $0x4d
  800df2:	68 d6 14 80 00       	push   $0x8014d6
  800df7:	e8 00 00 00 00       	call   800dfc <_panic>

00800dfc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	53                   	push   %ebx
  800e00:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800e03:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e06:	ff 75 0c             	pushl  0xc(%ebp)
  800e09:	ff 75 08             	pushl  0x8(%ebp)
  800e0c:	ff 35 00 20 80 00    	pushl  0x802000
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	e8 3e fc ff ff       	call   800a58 <sys_getenvid>
  800e1a:	83 c4 08             	add    $0x8,%esp
  800e1d:	50                   	push   %eax
  800e1e:	68 44 15 80 00       	push   $0x801544
  800e23:	e8 78 f3 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e28:	83 c4 18             	add    $0x18,%esp
  800e2b:	53                   	push   %ebx
  800e2c:	ff 75 10             	pushl  0x10(%ebp)
  800e2f:	e8 1b f3 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  800e34:	c7 04 24 94 11 80 00 	movl   $0x801194,(%esp)
  800e3b:	e8 60 f3 ff ff       	call   8001a0 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800e40:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800e43:	cc                   	int3   
  800e44:	eb fd                	jmp    800e43 <_panic+0x47>
	...

00800e48 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	83 ec 14             	sub    $0x14,%esp
  800e50:	8b 55 14             	mov    0x14(%ebp),%edx
  800e53:	8b 75 08             	mov    0x8(%ebp),%esi
  800e56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e59:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e5c:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e5e:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800e64:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e67:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e69:	75 11                	jne    800e7c <__udivdi3+0x34>
    {
      if (d0 > n1)
  800e6b:	39 f8                	cmp    %edi,%eax
  800e6d:	76 4d                	jbe    800ebc <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6f:	89 fa                	mov    %edi,%edx
  800e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e74:	f7 75 e4             	divl   -0x1c(%ebp)
  800e77:	89 c7                	mov    %eax,%edi
  800e79:	eb 09                	jmp    800e84 <__udivdi3+0x3c>
  800e7b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e7c:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800e7f:	76 17                	jbe    800e98 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800e81:	31 ff                	xor    %edi,%edi
  800e83:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800e84:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e8e:	83 c4 14             	add    $0x14,%esp
  800e91:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e92:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e94:	5f                   	pop    %edi
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    
  800e97:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e98:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	83 f7 1f             	xor    $0x1f,%edi
  800ea1:	75 4d                	jne    800ef0 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ea3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ea6:	77 0a                	ja     800eb2 <__udivdi3+0x6a>
  800ea8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800eab:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ead:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800eb0:	72 d2                	jb     800e84 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800eb2:	bf 01 00 00 00       	mov    $0x1,%edi
  800eb7:	eb cb                	jmp    800e84 <__udivdi3+0x3c>
  800eb9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	75 0e                	jne    800ed1 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec8:	31 c9                	xor    %ecx,%ecx
  800eca:	31 d2                	xor    %edx,%edx
  800ecc:	f7 f1                	div    %ecx
  800ece:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 75 e4             	divl   -0x1c(%ebp)
  800ed8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ede:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ee1:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ee4:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee7:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ee9:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eea:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eec:	5f                   	pop    %edi
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    
  800eef:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ef0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ef5:	29 f8                	sub    %edi,%eax
  800ef7:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800efa:	89 f9                	mov    %edi,%ecx
  800efc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f04:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800f0b:	89 f9                	mov    %edi,%ecx
  800f0d:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f13:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800f16:	89 f2                	mov    %esi,%edx
  800f18:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f1a:	89 f9                	mov    %edi,%ecx
  800f1c:	d3 e6                	shl    %cl,%esi
  800f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f21:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800f24:	d3 e8                	shr    %cl,%eax
  800f26:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800f28:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f2a:	89 f0                	mov    %esi,%eax
  800f2c:	f7 75 f4             	divl   -0xc(%ebp)
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f33:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f39:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f3b:	39 f2                	cmp    %esi,%edx
  800f3d:	77 0f                	ja     800f4e <__udivdi3+0x106>
  800f3f:	0f 85 3f ff ff ff    	jne    800e84 <__udivdi3+0x3c>
  800f45:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f48:	0f 86 36 ff ff ff    	jbe    800e84 <__udivdi3+0x3c>
		{
		  q0--;
  800f4e:	4f                   	dec    %edi
  800f4f:	e9 30 ff ff ff       	jmp    800e84 <__udivdi3+0x3c>

00800f54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	83 ec 30             	sub    $0x30,%esp
  800f5c:	8b 55 14             	mov    0x14(%ebp),%edx
  800f5f:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800f62:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800f64:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800f67:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800f69:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f6f:	85 ff                	test   %edi,%edi
  800f71:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800f78:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800f7f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f82:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800f85:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f88:	75 3e                	jne    800fc8 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800f8a:	39 d6                	cmp    %edx,%esi
  800f8c:	0f 86 a2 00 00 00    	jbe    801034 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f92:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800f94:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f97:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f99:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800f9c:	74 1b                	je     800fb9 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800f9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800fa4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800fab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fb1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800fb4:	89 10                	mov    %edx,(%eax)
  800fb6:	89 48 04             	mov    %ecx,0x4(%eax)
  800fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fbf:	83 c4 30             	add    $0x30,%esp
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    
  800fc6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fc8:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800fcb:	76 1f                	jbe    800fec <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800fcd:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800fd0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800fd3:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800fd6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fe2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fe5:	83 c4 30             	add    $0x30,%esp
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fec:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800fef:	83 f0 1f             	xor    $0x1f,%eax
  800ff2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ff5:	75 61                	jne    801058 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ff7:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800ffa:	77 05                	ja     801001 <__umoddi3+0xad>
  800ffc:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800fff:	72 10                	jb     801011 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801001:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801004:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801007:	29 f0                	sub    %esi,%eax
  801009:	19 fa                	sbb    %edi,%edx
  80100b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80100e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  801011:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801014:	85 d2                	test   %edx,%edx
  801016:	74 a1                	je     800fb9 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801018:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  80101b:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80101e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  801021:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801024:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801027:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80102d:	89 01                	mov    %eax,(%ecx)
  80102f:	89 51 04             	mov    %edx,0x4(%ecx)
  801032:	eb 85                	jmp    800fb9 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801034:	85 f6                	test   %esi,%esi
  801036:	75 0b                	jne    801043 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801038:	b8 01 00 00 00       	mov    $0x1,%eax
  80103d:	31 d2                	xor    %edx,%edx
  80103f:	f7 f6                	div    %esi
  801041:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801043:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801046:	89 fa                	mov    %edi,%edx
  801048:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80104a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80104d:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801050:	f7 f6                	div    %esi
  801052:	e9 3d ff ff ff       	jmp    800f94 <__umoddi3+0x40>
  801057:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801058:	b8 20 00 00 00       	mov    $0x20,%eax
  80105d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  801060:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801063:	89 fa                	mov    %edi,%edx
  801065:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801068:	d3 e2                	shl    %cl,%edx
  80106a:	89 f0                	mov    %esi,%eax
  80106c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80106f:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  801071:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801074:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801076:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801078:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80107b:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80107e:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801080:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801082:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801085:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801088:	d3 e0                	shl    %cl,%eax
  80108a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80108d:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801090:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801093:	d3 e8                	shr    %cl,%eax
  801095:	0b 45 cc             	or     -0x34(%ebp),%eax
  801098:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  80109b:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80109e:	f7 f7                	div    %edi
  8010a0:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8010a3:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8010a6:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010a8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8010ab:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010ae:	77 0a                	ja     8010ba <__umoddi3+0x166>
  8010b0:	75 12                	jne    8010c4 <__umoddi3+0x170>
  8010b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010b5:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8010b8:	76 0a                	jbe    8010c4 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8010ba:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8010bd:	29 f1                	sub    %esi,%ecx
  8010bf:	19 fa                	sbb    %edi,%edx
  8010c1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  8010c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	0f 84 ea fe ff ff    	je     800fb9 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8010d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010d5:	2b 45 c8             	sub    -0x38(%ebp),%eax
  8010d8:	19 d1                	sbb    %edx,%ecx
  8010da:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010dd:	89 ca                	mov    %ecx,%edx
  8010df:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8010e2:	d3 e2                	shl    %cl,%edx
  8010e4:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010ea:	d3 e8                	shr    %cl,%eax
  8010ec:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  8010ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8010f1:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  8010f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010f9:	e9 ad fe ff ff       	jmp    800fab <__umoddi3+0x57>
