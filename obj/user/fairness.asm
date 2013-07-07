
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 73 00 00 00       	call   8000a4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 07 0a 00 00       	call   800a48 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
		while (1) {
			ipc_recv(&who, 0, 0);
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 19 0c 00 00       	call   800c78 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 a0 10 80 00       	push   $0x8010a0
  80006b:	e8 20 01 00 00       	call   800190 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  80007e:	50                   	push   %eax
  80007f:	68 b1 10 80 00       	push   $0x8010b1
  800084:	e8 07 01 00 00       	call   800190 <cprintf>
		while (1)
  800089:	83 c4 10             	add    $0x10,%esp
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  800098:	e8 4b 0c 00 00       	call   800ce8 <ipc_send>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	eb ea                	jmp    80008c <umain+0x58>
	...

008000a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000af:	e8 94 09 00 00       	call   800a48 <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	89 c2                	mov    %eax,%edx
  8000bb:	c1 e2 05             	shl    $0x5,%edx
  8000be:	29 c2                	sub    %eax,%edx
  8000c0:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000c7:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 f6                	test   %esi,%esi
  8000cf:	7e 07                	jle    8000d8 <libmain+0x34>
		binaryname = argv[0];
  8000d1:	8b 03                	mov    (%ebx),%eax
  8000d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	53                   	push   %ebx
  8000dc:	56                   	push   %esi
  8000dd:	e8 52 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e2:	e8 09 00 00 00       	call   8000f0 <exit>
}
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000f6:	6a 00                	push   $0x0
  8000f8:	e8 0a 09 00 00       	call   800a07 <sys_env_destroy>
}
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    
	...

00800100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	53                   	push   %ebx
  800104:	83 ec 04             	sub    $0x4,%esp
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010a:	8b 03                	mov    (%ebx),%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  800113:	40                   	inc    %eax
  800114:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	75 1a                	jne    800137 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 ff 00 00 00       	push   $0xff
  800125:	8d 43 08             	lea    0x8(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	e8 96 08 00 00       	call   8009c4 <sys_cputs>
		b->idx = 0;
  80012e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800134:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800137:	ff 43 04             	incl   0x4(%ebx)
}
  80013a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800148:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80014f:	00 00 00 
	b.cnt = 0;
  800152:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800168:	50                   	push   %eax
  800169:	68 00 01 80 00       	push   $0x800100
  80016e:	e8 49 01 00 00       	call   8002bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 3c 08 00 00       	call   8009c4 <sys_cputs>

	return b.cnt;
  800188:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	50                   	push   %eax
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	e8 9d ff ff ff       	call   80013f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 0c             	sub    $0xc,%esp
  8001ad:	8b 75 10             	mov    0x10(%ebp),%esi
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b6:	8b 45 18             	mov    0x18(%ebp),%eax
  8001b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001be:	39 fa                	cmp    %edi,%edx
  8001c0:	77 39                	ja     8001fb <printnum+0x57>
  8001c2:	72 04                	jb     8001c8 <printnum+0x24>
  8001c4:	39 f0                	cmp    %esi,%eax
  8001c6:	77 33                	ja     8001fb <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c8:	83 ec 04             	sub    $0x4,%esp
  8001cb:	ff 75 20             	pushl  0x20(%ebp)
  8001ce:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001dd:	52                   	push   %edx
  8001de:	50                   	push   %eax
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	e8 f2 0b 00 00       	call   800dd8 <__udivdi3>
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	52                   	push   %edx
  8001ea:	50                   	push   %eax
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	e8 ae ff ff ff       	call   8001a4 <printnum>
  8001f6:	83 c4 20             	add    $0x20,%esp
  8001f9:	eb 19                	jmp    800214 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fb:	4b                   	dec    %ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7e 14                	jle    800214 <printnum+0x70>
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	ff 75 20             	pushl  0x20(%ebp)
  800209:	ff 55 08             	call   *0x8(%ebp)
  80020c:	83 c4 10             	add    $0x10,%esp
  80020f:	4b                   	dec    %ebx
  800210:	85 db                	test   %ebx,%ebx
  800212:	7f ec                	jg     800200 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	ff 75 0c             	pushl  0xc(%ebp)
  80021a:	8b 45 18             	mov    0x18(%ebp),%eax
  80021d:	ba 00 00 00 00       	mov    $0x0,%edx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	52                   	push   %edx
  800226:	50                   	push   %eax
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	e8 b6 0c 00 00       	call   800ee4 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 e4 11 80 00 	movsbl 0x8011e4(%eax),%eax
  800238:	50                   	push   %eax
  800239:	ff 55 08             	call   *0x8(%ebp)
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80024d:	83 f8 01             	cmp    $0x1,%eax
  800250:	7e 0e                	jle    800260 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800252:	8b 11                	mov    (%ecx),%edx
  800254:	8d 42 08             	lea    0x8(%edx),%eax
  800257:	89 01                	mov    %eax,(%ecx)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x3e>
	else if (lflag)
  800260:	85 c0                	test   %eax,%eax
  800262:	74 10                	je     800274 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800264:	8b 11                	mov    (%ecx),%edx
  800266:	8d 42 04             	lea    0x4(%edx),%eax
  800269:	89 01                	mov    %eax,(%ecx)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 11                	mov    (%ecx),%edx
  800276:	8d 42 04             	lea    0x4(%edx),%eax
  800279:	89 01                	mov    %eax,(%ecx)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80028d:	83 f8 01             	cmp    $0x1,%eax
  800290:	7e 0e                	jle    8002a0 <getint+0x1c>
		return va_arg(*ap, long long);
  800292:	8b 11                	mov    (%ecx),%edx
  800294:	8d 42 08             	lea    0x8(%edx),%eax
  800297:	89 01                	mov    %eax,(%ecx)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	8b 52 04             	mov    0x4(%edx),%edx
  80029e:	eb 1a                	jmp    8002ba <getint+0x36>
	else if (lflag)
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	74 0c                	je     8002b0 <getint+0x2c>
		return va_arg(*ap, long);
  8002a4:	8b 01                	mov    (%ecx),%eax
  8002a6:	8d 50 04             	lea    0x4(%eax),%edx
  8002a9:	89 11                	mov    %edx,(%ecx)
  8002ab:	8b 00                	mov    (%eax),%eax
  8002ad:	99                   	cltd   
  8002ae:	eb 0a                	jmp    8002ba <getint+0x36>
	else
		return va_arg(*ap, int);
  8002b0:	8b 01                	mov    (%ecx),%eax
  8002b2:	8d 50 04             	lea    0x4(%eax),%edx
  8002b5:	89 11                	mov    %edx,(%ecx)
  8002b7:	8b 00                	mov    (%eax),%eax
  8002b9:	99                   	cltd   
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 1c             	sub    $0x1c,%esp
  8002c5:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8002c8:	0f b6 0b             	movzbl (%ebx),%ecx
  8002cb:	43                   	inc    %ebx
  8002cc:	83 f9 25             	cmp    $0x25,%ecx
  8002cf:	74 1e                	je     8002ef <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d1:	85 c9                	test   %ecx,%ecx
  8002d3:	0f 84 dc 02 00 00    	je     8005b5 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	ff 75 0c             	pushl  0xc(%ebp)
  8002df:	51                   	push   %ecx
  8002e0:	ff 55 08             	call   *0x8(%ebp)
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	0f b6 0b             	movzbl (%ebx),%ecx
  8002e9:	43                   	inc    %ebx
  8002ea:	83 f9 25             	cmp    $0x25,%ecx
  8002ed:	75 e2                	jne    8002d1 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8002ef:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8002f3:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8002fa:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8002ff:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800304:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	0f b6 0b             	movzbl (%ebx),%ecx
  80030e:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800311:	43                   	inc    %ebx
  800312:	83 f8 55             	cmp    $0x55,%eax
  800315:	0f 87 75 02 00 00    	ja     800590 <vprintfmt+0x2d4>
  80031b:	ff 24 85 80 12 80 00 	jmp    *0x801280(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  800322:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800326:	eb e3                	jmp    80030b <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  80032c:	eb dd                	jmp    80030b <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032e:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800333:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800336:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  80033a:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  80033d:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800340:	83 f8 09             	cmp    $0x9,%eax
  800343:	77 28                	ja     80036d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	43                   	inc    %ebx
  800346:	eb eb                	jmp    800333 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800348:	8b 55 14             	mov    0x14(%ebp),%edx
  80034b:	8d 42 04             	lea    0x4(%edx),%eax
  80034e:	89 45 14             	mov    %eax,0x14(%ebp)
  800351:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800353:	eb 18                	jmp    80036d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800355:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800359:	79 b0                	jns    80030b <vprintfmt+0x4f>
				width = 0;
  80035b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800362:	eb a7                	jmp    80030b <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800364:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80036b:	eb 9e                	jmp    80030b <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80036d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800371:	79 98                	jns    80030b <vprintfmt+0x4f>
				width = precision, precision = -1;
  800373:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800376:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80037b:	eb 8e                	jmp    80030b <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037d:	47                   	inc    %edi
			goto reswitch;
  80037e:	eb 8b                	jmp    80030b <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	ff 75 0c             	pushl  0xc(%ebp)
  800386:	8b 55 14             	mov    0x14(%ebp),%edx
  800389:	8d 42 04             	lea    0x4(%edx),%eax
  80038c:	89 45 14             	mov    %eax,0x14(%ebp)
  80038f:	ff 32                	pushl  (%edx)
  800391:	ff 55 08             	call   *0x8(%ebp)
			break;
  800394:	83 c4 10             	add    $0x10,%esp
  800397:	e9 2c ff ff ff       	jmp    8002c8 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039c:	8b 55 14             	mov    0x14(%ebp),%edx
  80039f:	8d 42 04             	lea    0x4(%edx),%eax
  8003a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a5:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  8003a7:	85 c0                	test   %eax,%eax
  8003a9:	79 02                	jns    8003ad <vprintfmt+0xf1>
				err = -err;
  8003ab:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ad:	83 f8 0f             	cmp    $0xf,%eax
  8003b0:	7f 0b                	jg     8003bd <vprintfmt+0x101>
  8003b2:	8b 3c 85 40 12 80 00 	mov    0x801240(,%eax,4),%edi
  8003b9:	85 ff                	test   %edi,%edi
  8003bb:	75 19                	jne    8003d6 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  8003bd:	50                   	push   %eax
  8003be:	68 f5 11 80 00       	push   $0x8011f5
  8003c3:	ff 75 0c             	pushl  0xc(%ebp)
  8003c6:	ff 75 08             	pushl  0x8(%ebp)
  8003c9:	e8 ef 01 00 00       	call   8005bd <printfmt>
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	e9 f2 fe ff ff       	jmp    8002c8 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8003d6:	57                   	push   %edi
  8003d7:	68 fe 11 80 00       	push   $0x8011fe
  8003dc:	ff 75 0c             	pushl  0xc(%ebp)
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 d6 01 00 00       	call   8005bd <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
			break;
  8003ea:	e9 d9 fe ff ff       	jmp    8002c8 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ef:	8b 55 14             	mov    0x14(%ebp),%edx
  8003f2:	8d 42 04             	lea    0x4(%edx),%eax
  8003f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8003f8:	8b 3a                	mov    (%edx),%edi
  8003fa:	85 ff                	test   %edi,%edi
  8003fc:	75 05                	jne    800403 <vprintfmt+0x147>
				p = "(null)";
  8003fe:	bf 01 12 80 00       	mov    $0x801201,%edi
			if (width > 0 && padc != '-')
  800403:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800407:	7e 3b                	jle    800444 <vprintfmt+0x188>
  800409:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  80040d:	74 35                	je     800444 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	56                   	push   %esi
  800413:	57                   	push   %edi
  800414:	e8 58 02 00 00       	call   800671 <strnlen>
  800419:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800423:	7e 1f                	jle    800444 <vprintfmt+0x188>
  800425:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800429:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	ff 75 0c             	pushl  0xc(%ebp)
  800432:	ff 75 e4             	pushl  -0x1c(%ebp)
  800435:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	ff 4d f0             	decl   -0x10(%ebp)
  80043e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800442:	7f e8                	jg     80042c <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800444:	0f be 0f             	movsbl (%edi),%ecx
  800447:	47                   	inc    %edi
  800448:	85 c9                	test   %ecx,%ecx
  80044a:	74 44                	je     800490 <vprintfmt+0x1d4>
  80044c:	85 f6                	test   %esi,%esi
  80044e:	78 03                	js     800453 <vprintfmt+0x197>
  800450:	4e                   	dec    %esi
  800451:	78 3d                	js     800490 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800453:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800457:	74 18                	je     800471 <vprintfmt+0x1b5>
  800459:	8d 41 e0             	lea    -0x20(%ecx),%eax
  80045c:	83 f8 5e             	cmp    $0x5e,%eax
  80045f:	76 10                	jbe    800471 <vprintfmt+0x1b5>
					putch('?', putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	ff 75 0c             	pushl  0xc(%ebp)
  800467:	6a 3f                	push   $0x3f
  800469:	ff 55 08             	call   *0x8(%ebp)
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	eb 0d                	jmp    80047e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 0c             	pushl  0xc(%ebp)
  800477:	51                   	push   %ecx
  800478:	ff 55 08             	call   *0x8(%ebp)
  80047b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047e:	ff 4d f0             	decl   -0x10(%ebp)
  800481:	0f be 0f             	movsbl (%edi),%ecx
  800484:	47                   	inc    %edi
  800485:	85 c9                	test   %ecx,%ecx
  800487:	74 07                	je     800490 <vprintfmt+0x1d4>
  800489:	85 f6                	test   %esi,%esi
  80048b:	78 c6                	js     800453 <vprintfmt+0x197>
  80048d:	4e                   	dec    %esi
  80048e:	79 c3                	jns    800453 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800490:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800494:	0f 8e 2e fe ff ff    	jle    8002c8 <vprintfmt+0xc>
				putch(' ', putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	6a 20                	push   $0x20
  8004a2:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	ff 4d f0             	decl   -0x10(%ebp)
  8004ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004af:	7f e9                	jg     80049a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  8004b1:	e9 12 fe ff ff       	jmp    8002c8 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004b6:	57                   	push   %edi
  8004b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ba:	50                   	push   %eax
  8004bb:	e8 c4 fd ff ff       	call   800284 <getint>
  8004c0:	89 c6                	mov    %eax,%esi
  8004c2:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8004c4:	83 c4 08             	add    $0x8,%esp
  8004c7:	85 d2                	test   %edx,%edx
  8004c9:	79 15                	jns    8004e0 <vprintfmt+0x224>
				putch('-', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	ff 75 0c             	pushl  0xc(%ebp)
  8004d1:	6a 2d                	push   $0x2d
  8004d3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8004d6:	f7 de                	neg    %esi
  8004d8:	83 d7 00             	adc    $0x0,%edi
  8004db:	f7 df                	neg    %edi
  8004dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8004e0:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004e5:	eb 76                	jmp    80055d <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004e7:	57                   	push   %edi
  8004e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8004eb:	50                   	push   %eax
  8004ec:	e8 53 fd ff ff       	call   800244 <getuint>
  8004f1:	89 c6                	mov    %eax,%esi
  8004f3:	89 d7                	mov    %edx,%edi
			base = 10;
  8004f5:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8004fa:	83 c4 08             	add    $0x8,%esp
  8004fd:	eb 5e                	jmp    80055d <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004ff:	57                   	push   %edi
  800500:	8d 45 14             	lea    0x14(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	e8 3b fd ff ff       	call   800244 <getuint>
  800509:	89 c6                	mov    %eax,%esi
  80050b:	89 d7                	mov    %edx,%edi
			base = 8;
  80050d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800512:	83 c4 08             	add    $0x8,%esp
  800515:	eb 46                	jmp    80055d <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	6a 30                	push   $0x30
  80051f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800522:	83 c4 08             	add    $0x8,%esp
  800525:	ff 75 0c             	pushl  0xc(%ebp)
  800528:	6a 78                	push   $0x78
  80052a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80052d:	8b 55 14             	mov    0x14(%ebp),%edx
  800530:	8d 42 04             	lea    0x4(%edx),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
  800536:	8b 32                	mov    (%edx),%esi
  800538:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80053d:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb 16                	jmp    80055d <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800547:	57                   	push   %edi
  800548:	8d 45 14             	lea    0x14(%ebp),%eax
  80054b:	50                   	push   %eax
  80054c:	e8 f3 fc ff ff       	call   800244 <getuint>
  800551:	89 c6                	mov    %eax,%esi
  800553:	89 d7                	mov    %edx,%edi
			base = 16;
  800555:	ba 10 00 00 00       	mov    $0x10,%edx
  80055a:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  80055d:	83 ec 04             	sub    $0x4,%esp
  800560:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800564:	50                   	push   %eax
  800565:	ff 75 f0             	pushl  -0x10(%ebp)
  800568:	52                   	push   %edx
  800569:	57                   	push   %edi
  80056a:	56                   	push   %esi
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	ff 75 08             	pushl  0x8(%ebp)
  800571:	e8 2e fc ff ff       	call   8001a4 <printnum>
			break;
  800576:	83 c4 20             	add    $0x20,%esp
  800579:	e9 4a fd ff ff       	jmp    8002c8 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	51                   	push   %ecx
  800585:	ff 55 08             	call   *0x8(%ebp)
			break;
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	e9 38 fd ff ff       	jmp    8002c8 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 0c             	pushl  0xc(%ebp)
  800596:	6a 25                	push   $0x25
  800598:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80059b:	4b                   	dec    %ebx
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005a3:	0f 84 1f fd ff ff    	je     8002c8 <vprintfmt+0xc>
  8005a9:	4b                   	dec    %ebx
  8005aa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005ae:	75 f9                	jne    8005a9 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005b0:	e9 13 fd ff ff       	jmp    8002c8 <vprintfmt+0xc>
		}
	}
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 10             	pushl  0x10(%ebp)
  8005ca:	ff 75 0c             	pushl  0xc(%ebp)
  8005cd:	ff 75 08             	pushl  0x8(%ebp)
  8005d0:	e8 e7 fc ff ff       	call   8002bc <vprintfmt>
	va_end(ap);
}
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    

008005d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8005dd:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8005e0:	8b 0a                	mov    (%edx),%ecx
  8005e2:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8005e5:	73 07                	jae    8005ee <sprintputch+0x17>
		*b->buf++ = ch;
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	88 01                	mov    %al,(%ecx)
  8005ec:	ff 02                	incl   (%edx)
}
  8005ee:	c9                   	leave  
  8005ef:	c3                   	ret    

008005f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
  8005f3:	83 ec 18             	sub    $0x18,%esp
  8005f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005fc:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005ff:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800603:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800606:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 04                	je     800615 <vsnprintf+0x25>
  800611:	85 c9                	test   %ecx,%ecx
  800613:	7f 07                	jg     80061c <vsnprintf+0x2c>
		return -E_INVAL;
  800615:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80061a:	eb 1d                	jmp    800639 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80061c:	ff 75 14             	pushl  0x14(%ebp)
  80061f:	ff 75 10             	pushl  0x10(%ebp)
  800622:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800625:	50                   	push   %eax
  800626:	68 d7 05 80 00       	push   $0x8005d7
  80062b:	e8 8c fc ff ff       	call   8002bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800630:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800633:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800636:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800639:	c9                   	leave  
  80063a:	c3                   	ret    

0080063b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800641:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800644:	50                   	push   %eax
  800645:	ff 75 10             	pushl  0x10(%ebp)
  800648:	ff 75 0c             	pushl  0xc(%ebp)
  80064b:	ff 75 08             	pushl  0x8(%ebp)
  80064e:	e8 9d ff ff ff       	call   8005f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800653:	c9                   	leave  
  800654:	c3                   	ret    
  800655:	00 00                	add    %al,(%eax)
	...

00800658 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80065e:	b8 00 00 00 00       	mov    $0x0,%eax
  800663:	80 3a 00             	cmpb   $0x0,(%edx)
  800666:	74 07                	je     80066f <strlen+0x17>
		n++;
  800668:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800669:	42                   	inc    %edx
  80066a:	80 3a 00             	cmpb   $0x0,(%edx)
  80066d:	75 f9                	jne    800668 <strlen+0x10>
		n++;
	return n;
}
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800677:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80067a:	b8 00 00 00 00       	mov    $0x0,%eax
  80067f:	85 d2                	test   %edx,%edx
  800681:	74 0f                	je     800692 <strnlen+0x21>
  800683:	80 39 00             	cmpb   $0x0,(%ecx)
  800686:	74 0a                	je     800692 <strnlen+0x21>
		n++;
  800688:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800689:	41                   	inc    %ecx
  80068a:	4a                   	dec    %edx
  80068b:	74 05                	je     800692 <strnlen+0x21>
  80068d:	80 39 00             	cmpb   $0x0,(%ecx)
  800690:	75 f6                	jne    800688 <strnlen+0x17>
		n++;
	return n;
}
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	53                   	push   %ebx
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80069e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006a0:	8a 02                	mov    (%edx),%al
  8006a2:	42                   	inc    %edx
  8006a3:	88 01                	mov    %al,(%ecx)
  8006a5:	41                   	inc    %ecx
  8006a6:	84 c0                	test   %al,%al
  8006a8:	75 f6                	jne    8006a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006aa:	89 d8                	mov    %ebx,%eax
  8006ac:	5b                   	pop    %ebx
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    

008006af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	53                   	push   %ebx
  8006b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006b6:	53                   	push   %ebx
  8006b7:	e8 9c ff ff ff       	call   800658 <strlen>
	strcpy(dst + len, src);
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 cc ff ff ff       	call   800694 <strcpy>
	return dst;
}
  8006c8:	89 d8                	mov    %ebx,%eax
  8006ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	57                   	push   %edi
  8006d3:	56                   	push   %esi
  8006d4:	53                   	push   %ebx
  8006d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006db:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8006de:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8006e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e5:	39 f3                	cmp    %esi,%ebx
  8006e7:	73 10                	jae    8006f9 <strncpy+0x2a>
		*dst++ = *src;
  8006e9:	8a 02                	mov    (%edx),%al
  8006eb:	88 01                	mov    %al,(%ecx)
  8006ed:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006ee:	80 3a 01             	cmpb   $0x1,(%edx)
  8006f1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006f4:	43                   	inc    %ebx
  8006f5:	39 f3                	cmp    %esi,%ebx
  8006f7:	72 f0                	jb     8006e9 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006f9:	89 f8                	mov    %edi,%eax
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800708:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80070e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800710:	85 d2                	test   %edx,%edx
  800712:	74 19                	je     80072d <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800714:	4a                   	dec    %edx
  800715:	74 13                	je     80072a <strlcpy+0x2a>
  800717:	80 39 00             	cmpb   $0x0,(%ecx)
  80071a:	74 0e                	je     80072a <strlcpy+0x2a>
  80071c:	8a 01                	mov    (%ecx),%al
  80071e:	41                   	inc    %ecx
  80071f:	88 03                	mov    %al,(%ebx)
  800721:	43                   	inc    %ebx
  800722:	4a                   	dec    %edx
  800723:	74 05                	je     80072a <strlcpy+0x2a>
  800725:	80 39 00             	cmpb   $0x0,(%ecx)
  800728:	75 f2                	jne    80071c <strlcpy+0x1c>
		*dst = '\0';
  80072a:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	29 f0                	sub    %esi,%eax
}
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80073e:	80 3a 00             	cmpb   $0x0,(%edx)
  800741:	74 13                	je     800756 <strcmp+0x21>
  800743:	8a 02                	mov    (%edx),%al
  800745:	3a 01                	cmp    (%ecx),%al
  800747:	75 0d                	jne    800756 <strcmp+0x21>
  800749:	42                   	inc    %edx
  80074a:	41                   	inc    %ecx
  80074b:	80 3a 00             	cmpb   $0x0,(%edx)
  80074e:	74 06                	je     800756 <strcmp+0x21>
  800750:	8a 02                	mov    (%edx),%al
  800752:	3a 01                	cmp    (%ecx),%al
  800754:	74 f3                	je     800749 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800756:	0f b6 02             	movzbl (%edx),%eax
  800759:	0f b6 11             	movzbl (%ecx),%edx
  80075c:	29 d0                	sub    %edx,%eax
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 55 08             	mov    0x8(%ebp),%edx
  800767:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80076d:	85 c9                	test   %ecx,%ecx
  80076f:	74 1f                	je     800790 <strncmp+0x30>
  800771:	80 3a 00             	cmpb   $0x0,(%edx)
  800774:	74 16                	je     80078c <strncmp+0x2c>
  800776:	8a 02                	mov    (%edx),%al
  800778:	3a 03                	cmp    (%ebx),%al
  80077a:	75 10                	jne    80078c <strncmp+0x2c>
  80077c:	42                   	inc    %edx
  80077d:	43                   	inc    %ebx
  80077e:	49                   	dec    %ecx
  80077f:	74 0f                	je     800790 <strncmp+0x30>
  800781:	80 3a 00             	cmpb   $0x0,(%edx)
  800784:	74 06                	je     80078c <strncmp+0x2c>
  800786:	8a 02                	mov    (%edx),%al
  800788:	3a 03                	cmp    (%ebx),%al
  80078a:	74 f0                	je     80077c <strncmp+0x1c>
	if (n == 0)
  80078c:	85 c9                	test   %ecx,%ecx
  80078e:	75 07                	jne    800797 <strncmp+0x37>
		return 0;
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 0a                	jmp    8007a1 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800797:	0f b6 12             	movzbl (%edx),%edx
  80079a:	0f b6 03             	movzbl (%ebx),%eax
  80079d:	29 c2                	sub    %eax,%edx
  80079f:	89 d0                	mov    %edx,%eax
}
  8007a1:	5b                   	pop    %ebx
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007ad:	80 38 00             	cmpb   $0x0,(%eax)
  8007b0:	74 0a                	je     8007bc <strchr+0x18>
		if (*s == c)
  8007b2:	38 10                	cmp    %dl,(%eax)
  8007b4:	74 0b                	je     8007c1 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007b6:	40                   	inc    %eax
  8007b7:	80 38 00             	cmpb   $0x0,(%eax)
  8007ba:	75 f6                	jne    8007b2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007cc:	80 38 00             	cmpb   $0x0,(%eax)
  8007cf:	74 0a                	je     8007db <strfind+0x18>
		if (*s == c)
  8007d1:	38 10                	cmp    %dl,(%eax)
  8007d3:	74 06                	je     8007db <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007d5:	40                   	inc    %eax
  8007d6:	80 38 00             	cmpb   $0x0,(%eax)
  8007d9:	75 f6                	jne    8007d1 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	57                   	push   %edi
  8007e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8007e7:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8007e9:	85 c9                	test   %ecx,%ecx
  8007eb:	74 40                	je     80082d <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007f3:	75 30                	jne    800825 <memset+0x48>
  8007f5:	f6 c1 03             	test   $0x3,%cl
  8007f8:	75 2b                	jne    800825 <memset+0x48>
		c &= 0xFF;
  8007fa:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800801:	8b 45 0c             	mov    0xc(%ebp),%eax
  800804:	c1 e0 18             	shl    $0x18,%eax
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	c1 e2 10             	shl    $0x10,%edx
  80080d:	09 d0                	or     %edx,%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	c1 e2 08             	shl    $0x8,%edx
  800815:	09 d0                	or     %edx,%eax
  800817:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80081a:	c1 e9 02             	shr    $0x2,%ecx
  80081d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800820:	fc                   	cld    
  800821:	f3 ab                	rep stos %eax,%es:(%edi)
  800823:	eb 06                	jmp    80082b <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800825:	8b 45 0c             	mov    0xc(%ebp),%eax
  800828:	fc                   	cld    
  800829:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  80082b:	89 f8                	mov    %edi,%eax
}
  80082d:	5f                   	pop    %edi
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	57                   	push   %edi
  800834:	56                   	push   %esi
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80083b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80083e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800840:	39 c6                	cmp    %eax,%esi
  800842:	73 34                	jae    800878 <memmove+0x48>
  800844:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800847:	39 c2                	cmp    %eax,%edx
  800849:	76 2d                	jbe    800878 <memmove+0x48>
		s += n;
  80084b:	89 d6                	mov    %edx,%esi
		d += n;
  80084d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800850:	f6 c2 03             	test   $0x3,%dl
  800853:	75 1b                	jne    800870 <memmove+0x40>
  800855:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085b:	75 13                	jne    800870 <memmove+0x40>
  80085d:	f6 c1 03             	test   $0x3,%cl
  800860:	75 0e                	jne    800870 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800862:	83 ef 04             	sub    $0x4,%edi
  800865:	83 ee 04             	sub    $0x4,%esi
  800868:	c1 e9 02             	shr    $0x2,%ecx
  80086b:	fd                   	std    
  80086c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80086e:	eb 05                	jmp    800875 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800870:	4f                   	dec    %edi
  800871:	4e                   	dec    %esi
  800872:	fd                   	std    
  800873:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800875:	fc                   	cld    
  800876:	eb 20                	jmp    800898 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800878:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087e:	75 15                	jne    800895 <memmove+0x65>
  800880:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800886:	75 0d                	jne    800895 <memmove+0x65>
  800888:	f6 c1 03             	test   $0x3,%cl
  80088b:	75 08                	jne    800895 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  80088d:	c1 e9 02             	shr    $0x2,%ecx
  800890:	fc                   	cld    
  800891:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800893:	eb 03                	jmp    800898 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800895:	fc                   	cld    
  800896:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80089f:	ff 75 10             	pushl  0x10(%ebp)
  8008a2:	ff 75 0c             	pushl  0xc(%ebp)
  8008a5:	ff 75 08             	pushl  0x8(%ebp)
  8008a8:	e8 83 ff ff ff       	call   800830 <memmove>
}
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008bc:	4a                   	dec    %edx
  8008bd:	83 fa ff             	cmp    $0xffffffff,%edx
  8008c0:	74 1a                	je     8008dc <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8008c2:	8a 01                	mov    (%ecx),%al
  8008c4:	3a 03                	cmp    (%ebx),%al
  8008c6:	74 0c                	je     8008d4 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  8008c8:	0f b6 d0             	movzbl %al,%edx
  8008cb:	0f b6 03             	movzbl (%ebx),%eax
  8008ce:	29 c2                	sub    %eax,%edx
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	eb 0d                	jmp    8008e1 <memcmp+0x32>
		s1++, s2++;
  8008d4:	41                   	inc    %ecx
  8008d5:	43                   	inc    %ebx
  8008d6:	4a                   	dec    %edx
  8008d7:	83 fa ff             	cmp    $0xffffffff,%edx
  8008da:	75 e6                	jne    8008c2 <memcmp+0x13>
	}

	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008ed:	89 c2                	mov    %eax,%edx
  8008ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8008f2:	39 d0                	cmp    %edx,%eax
  8008f4:	73 09                	jae    8008ff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8008f6:	38 08                	cmp    %cl,(%eax)
  8008f8:	74 05                	je     8008ff <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008fa:	40                   	inc    %eax
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	72 f7                	jb     8008f6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 55 08             	mov    0x8(%ebp),%edx
  80090a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800910:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800915:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80091a:	80 3a 20             	cmpb   $0x20,(%edx)
  80091d:	74 05                	je     800924 <strtol+0x23>
  80091f:	80 3a 09             	cmpb   $0x9,(%edx)
  800922:	75 0b                	jne    80092f <strtol+0x2e>
  800924:	42                   	inc    %edx
  800925:	80 3a 20             	cmpb   $0x20,(%edx)
  800928:	74 fa                	je     800924 <strtol+0x23>
  80092a:	80 3a 09             	cmpb   $0x9,(%edx)
  80092d:	74 f5                	je     800924 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80092f:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800932:	75 03                	jne    800937 <strtol+0x36>
		s++;
  800934:	42                   	inc    %edx
  800935:	eb 0b                	jmp    800942 <strtol+0x41>
	else if (*s == '-')
  800937:	80 3a 2d             	cmpb   $0x2d,(%edx)
  80093a:	75 06                	jne    800942 <strtol+0x41>
		s++, neg = 1;
  80093c:	42                   	inc    %edx
  80093d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 05                	je     80094b <strtol+0x4a>
  800946:	83 f9 10             	cmp    $0x10,%ecx
  800949:	75 15                	jne    800960 <strtol+0x5f>
  80094b:	80 3a 30             	cmpb   $0x30,(%edx)
  80094e:	75 10                	jne    800960 <strtol+0x5f>
  800950:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800954:	75 0a                	jne    800960 <strtol+0x5f>
		s += 2, base = 16;
  800956:	83 c2 02             	add    $0x2,%edx
  800959:	b9 10 00 00 00       	mov    $0x10,%ecx
  80095e:	eb 14                	jmp    800974 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800960:	85 c9                	test   %ecx,%ecx
  800962:	75 10                	jne    800974 <strtol+0x73>
  800964:	80 3a 30             	cmpb   $0x30,(%edx)
  800967:	75 05                	jne    80096e <strtol+0x6d>
		s++, base = 8;
  800969:	42                   	inc    %edx
  80096a:	b1 08                	mov    $0x8,%cl
  80096c:	eb 06                	jmp    800974 <strtol+0x73>
	else if (base == 0)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	75 02                	jne    800974 <strtol+0x73>
		base = 10;
  800972:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800974:	8a 02                	mov    (%edx),%al
  800976:	83 e8 30             	sub    $0x30,%eax
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	77 08                	ja     800985 <strtol+0x84>
			dig = *s - '0';
  80097d:	0f be 02             	movsbl (%edx),%eax
  800980:	83 e8 30             	sub    $0x30,%eax
  800983:	eb 20                	jmp    8009a5 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800985:	8a 02                	mov    (%edx),%al
  800987:	83 e8 61             	sub    $0x61,%eax
  80098a:	3c 19                	cmp    $0x19,%al
  80098c:	77 08                	ja     800996 <strtol+0x95>
			dig = *s - 'a' + 10;
  80098e:	0f be 02             	movsbl (%edx),%eax
  800991:	83 e8 57             	sub    $0x57,%eax
  800994:	eb 0f                	jmp    8009a5 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800996:	8a 02                	mov    (%edx),%al
  800998:	83 e8 41             	sub    $0x41,%eax
  80099b:	3c 19                	cmp    $0x19,%al
  80099d:	77 12                	ja     8009b1 <strtol+0xb0>
			dig = *s - 'A' + 10;
  80099f:	0f be 02             	movsbl (%edx),%eax
  8009a2:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009a5:	39 c8                	cmp    %ecx,%eax
  8009a7:	7d 08                	jge    8009b1 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009a9:	42                   	inc    %edx
  8009aa:	0f af d9             	imul   %ecx,%ebx
  8009ad:	01 c3                	add    %eax,%ebx
  8009af:	eb c3                	jmp    800974 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009b1:	85 f6                	test   %esi,%esi
  8009b3:	74 02                	je     8009b7 <strtol+0xb6>
		*endptr = (char *) s;
  8009b5:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009b7:	89 d8                	mov    %ebx,%eax
  8009b9:	85 ff                	test   %edi,%edi
  8009bb:	74 02                	je     8009bf <strtol+0xbe>
  8009bd:	f7 d8                	neg    %eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	83 ec 04             	sub    $0x4,%esp
  8009cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009d8:	89 f8                	mov    %edi,%eax
  8009da:	89 fb                	mov    %edi,%ebx
  8009dc:	89 fe                	mov    %edi,%esi
  8009de:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009e0:	83 c4 04             	add    $0x4,%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5f                   	pop    %edi
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8009ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8009f3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009f8:	89 fa                	mov    %edi,%edx
  8009fa:	89 f9                	mov    %edi,%ecx
  8009fc:	89 fb                	mov    %edi,%ebx
  8009fe:	89 fe                	mov    %edi,%esi
  800a00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 0c             	sub    $0xc,%esp
  800a10:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a13:	b8 03 00 00 00       	mov    $0x3,%eax
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1d:	89 f9                	mov    %edi,%ecx
  800a1f:	89 fb                	mov    %edi,%ebx
  800a21:	89 fe                	mov    %edi,%esi
  800a23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a25:	85 c0                	test   %eax,%eax
  800a27:	7e 17                	jle    800a40 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	50                   	push   %eax
  800a2d:	6a 03                	push   $0x3
  800a2f:	68 d8 13 80 00       	push   $0x8013d8
  800a34:	6a 23                	push   $0x23
  800a36:	68 f5 13 80 00       	push   $0x8013f5
  800a3b:	e8 4c 03 00 00       	call   800d8c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	89 fa                	mov    %edi,%edx
  800a5a:	89 f9                	mov    %edi,%ecx
  800a5c:	89 fb                	mov    %edi,%ebx
  800a5e:	89 fe                	mov    %edi,%esi
  800a60:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <sys_yield>:

void
sys_yield(void)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a77:	89 fa                	mov    %edi,%edx
  800a79:	89 f9                	mov    %edi,%ecx
  800a7b:	89 fb                	mov    %edi,%ebx
  800a7d:	89 fe                	mov    %edi,%esi
  800a7f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	83 ec 0c             	sub    $0xc,%esp
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a98:	b8 04 00 00 00       	mov    $0x4,%eax
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	89 fe                	mov    %edi,%esi
  800aa4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	7e 17                	jle    800ac1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aaa:	83 ec 0c             	sub    $0xc,%esp
  800aad:	50                   	push   %eax
  800aae:	6a 04                	push   $0x4
  800ab0:	68 d8 13 80 00       	push   $0x8013d8
  800ab5:	6a 23                	push   $0x23
  800ab7:	68 f5 13 80 00       	push   $0x8013f5
  800abc:	e8 cb 02 00 00       	call   800d8c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800adb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ade:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ae1:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae8:	85 c0                	test   %eax,%eax
  800aea:	7e 17                	jle    800b03 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aec:	83 ec 0c             	sub    $0xc,%esp
  800aef:	50                   	push   %eax
  800af0:	6a 05                	push   $0x5
  800af2:	68 d8 13 80 00       	push   $0x8013d8
  800af7:	6a 23                	push   $0x23
  800af9:	68 f5 13 80 00       	push   $0x8013f5
  800afe:	e8 89 02 00 00       	call   800d8c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	83 ec 0c             	sub    $0xc,%esp
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	89 fb                	mov    %edi,%ebx
  800b26:	89 fe                	mov    %edi,%esi
  800b28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7e 17                	jle    800b45 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 06                	push   $0x6
  800b34:	68 d8 13 80 00       	push   $0x8013d8
  800b39:	6a 23                	push   $0x23
  800b3b:	68 f5 13 80 00       	push   $0x8013f5
  800b40:	e8 47 02 00 00       	call   800d8c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b61:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	89 fb                	mov    %edi,%ebx
  800b68:	89 fe                	mov    %edi,%esi
  800b6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7e 17                	jle    800b87 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 08                	push   $0x8
  800b76:	68 d8 13 80 00       	push   $0x8013d8
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 f5 13 80 00       	push   $0x8013f5
  800b82:	e8 05 02 00 00       	call   800d8c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b9e:	b8 09 00 00 00       	mov    $0x9,%eax
  800ba3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	89 fb                	mov    %edi,%ebx
  800baa:	89 fe                	mov    %edi,%esi
  800bac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	7e 17                	jle    800bc9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	50                   	push   %eax
  800bb6:	6a 09                	push   $0x9
  800bb8:	68 d8 13 80 00       	push   $0x8013d8
  800bbd:	6a 23                	push   $0x23
  800bbf:	68 f5 13 80 00       	push   $0x8013f5
  800bc4:	e8 c3 01 00 00       	call   800d8c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800be0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be5:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	89 fb                	mov    %edi,%ebx
  800bec:	89 fe                	mov    %edi,%esi
  800bee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 17                	jle    800c0b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 0a                	push   $0xa
  800bfa:	68 d8 13 80 00       	push   $0x8013d8
  800bff:	6a 23                	push   $0x23
  800c01:	68 f5 13 80 00       	push   $0x8013f5
  800c06:	e8 81 01 00 00       	call   800d8c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c22:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c2a:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c42:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c47:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	89 f9                	mov    %edi,%ecx
  800c4e:	89 fb                	mov    %edi,%ebx
  800c50:	89 fe                	mov    %edi,%esi
  800c52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 17                	jle    800c6f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 0d                	push   $0xd
  800c5e:	68 d8 13 80 00       	push   $0x8013d8
  800c63:	6a 23                	push   $0x23
  800c65:	68 f5 13 80 00       	push   $0x8013f5
  800c6a:	e8 1d 01 00 00       	call   800d8c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    
	...

00800c78 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c83:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	75 05                	jne    800c8f <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  800c8a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	e8 9e ff ff ff       	call   800c36 <sys_ipc_recv>
  800c98:	83 c4 10             	add    $0x10,%esp
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	79 16                	jns    800cb5 <ipc_recv+0x3d>
		if (from_env_store)
  800c9f:	85 db                	test   %ebx,%ebx
  800ca1:	74 06                	je     800ca9 <ipc_recv+0x31>
			*from_env_store = 0;
  800ca3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  800ca9:	85 f6                	test   %esi,%esi
  800cab:	74 34                	je     800ce1 <ipc_recv+0x69>
			*perm_store = 0;
  800cad:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  800cb3:	eb 2c                	jmp    800ce1 <ipc_recv+0x69>
	}

	if (from_env_store)
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 0a                	je     800cc3 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  800cb9:	a1 04 20 80 00       	mov    0x802004,%eax
  800cbe:	8b 40 74             	mov    0x74(%eax),%eax
  800cc1:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  800cc3:	85 f6                	test   %esi,%esi
  800cc5:	74 12                	je     800cd9 <ipc_recv+0x61>
  800cc7:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800ccd:	8b 42 78             	mov    0x78(%edx),%eax
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	74 05                	je     800cd9 <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  800cd4:	8b 42 78             	mov    0x78(%edx),%eax
  800cd7:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  800cd9:	a1 04 20 80 00       	mov    0x802004,%eax
  800cde:	8b 40 70             	mov    0x70(%eax),%eax
}
  800ce1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    

00800ce8 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  800cfa:	85 db                	test   %ebx,%ebx
  800cfc:	74 10                	je     800d0e <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  800cfe:	ff 75 14             	pushl  0x14(%ebp)
  800d01:	53                   	push   %ebx
  800d02:	56                   	push   %esi
  800d03:	57                   	push   %edi
  800d04:	e8 0a ff ff ff       	call   800c13 <sys_ipc_try_send>
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	eb 11                	jmp    800d1f <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  800d0e:	6a 00                	push   $0x0
  800d10:	68 00 00 c0 ee       	push   $0xeec00000
  800d15:	56                   	push   %esi
  800d16:	57                   	push   %edi
  800d17:	e8 f7 fe ff ff       	call   800c13 <sys_ipc_try_send>
  800d1c:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	74 1e                	je     800d41 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  800d23:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800d26:	74 12                	je     800d3a <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  800d28:	50                   	push   %eax
  800d29:	68 04 14 80 00       	push   $0x801404
  800d2e:	6a 4a                	push   $0x4a
  800d30:	68 28 14 80 00       	push   $0x801428
  800d35:	e8 52 00 00 00       	call   800d8c <_panic>
		}
		sys_yield();
  800d3a:	e8 28 fd ff ff       	call   800a67 <sys_yield>
  800d3f:	eb b9                	jmp    800cfa <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	53                   	push   %ebx
  800d4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  800d55:	89 d0                	mov    %edx,%eax
  800d57:	c1 e0 05             	shl    $0x5,%eax
  800d5a:	29 d0                	sub    %edx,%eax
  800d5c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800d63:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  800d69:	8b 40 50             	mov    0x50(%eax),%eax
  800d6c:	39 d8                	cmp    %ebx,%eax
  800d6e:	75 0b                	jne    800d7b <ipc_find_env+0x32>
			return envs[i].env_id;
  800d70:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  800d76:	8b 40 40             	mov    0x40(%eax),%eax
  800d79:	eb 0e                	jmp    800d89 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d7b:	42                   	inc    %edx
  800d7c:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800d82:	7e d1                	jle    800d55 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d89:	5b                   	pop    %ebx
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800d93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d96:	ff 75 0c             	pushl  0xc(%ebp)
  800d99:	ff 75 08             	pushl  0x8(%ebp)
  800d9c:	ff 35 00 20 80 00    	pushl  0x802000
  800da2:	83 ec 08             	sub    $0x8,%esp
  800da5:	e8 9e fc ff ff       	call   800a48 <sys_getenvid>
  800daa:	83 c4 08             	add    $0x8,%esp
  800dad:	50                   	push   %eax
  800dae:	68 34 14 80 00       	push   $0x801434
  800db3:	e8 d8 f3 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800db8:	83 c4 18             	add    $0x18,%esp
  800dbb:	53                   	push   %ebx
  800dbc:	ff 75 10             	pushl  0x10(%ebp)
  800dbf:	e8 7b f3 ff ff       	call   80013f <vcprintf>
	cprintf("\n");
  800dc4:	c7 04 24 af 10 80 00 	movl   $0x8010af,(%esp)
  800dcb:	e8 c0 f3 ff ff       	call   800190 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800dd0:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800dd3:	cc                   	int3   
  800dd4:	eb fd                	jmp    800dd3 <_panic+0x47>
	...

00800dd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	83 ec 14             	sub    $0x14,%esp
  800de0:	8b 55 14             	mov    0x14(%ebp),%edx
  800de3:	8b 75 08             	mov    0x8(%ebp),%esi
  800de6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800de9:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dec:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dee:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800df1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800df4:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800df7:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df9:	75 11                	jne    800e0c <__udivdi3+0x34>
    {
      if (d0 > n1)
  800dfb:	39 f8                	cmp    %edi,%eax
  800dfd:	76 4d                	jbe    800e4c <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dff:	89 fa                	mov    %edi,%edx
  800e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e04:	f7 75 e4             	divl   -0x1c(%ebp)
  800e07:	89 c7                	mov    %eax,%edi
  800e09:	eb 09                	jmp    800e14 <__udivdi3+0x3c>
  800e0b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e0c:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800e0f:	76 17                	jbe    800e28 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800e11:	31 ff                	xor    %edi,%edi
  800e13:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800e14:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e1e:	83 c4 14             	add    $0x14,%esp
  800e21:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e22:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e24:	5f                   	pop    %edi
  800e25:	c9                   	leave  
  800e26:	c3                   	ret    
  800e27:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e28:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800e2c:	89 c7                	mov    %eax,%edi
  800e2e:	83 f7 1f             	xor    $0x1f,%edi
  800e31:	75 4d                	jne    800e80 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e33:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e36:	77 0a                	ja     800e42 <__udivdi3+0x6a>
  800e38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800e3b:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e3d:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e40:	72 d2                	jb     800e14 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800e42:	bf 01 00 00 00       	mov    $0x1,%edi
  800e47:	eb cb                	jmp    800e14 <__udivdi3+0x3c>
  800e49:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	75 0e                	jne    800e61 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e53:	b8 01 00 00 00       	mov    $0x1,%eax
  800e58:	31 c9                	xor    %ecx,%ecx
  800e5a:	31 d2                	xor    %edx,%edx
  800e5c:	f7 f1                	div    %ecx
  800e5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e61:	89 f0                	mov    %esi,%eax
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	f7 75 e4             	divl   -0x1c(%ebp)
  800e68:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6e:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e71:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e74:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e77:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e79:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e7a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e7c:	5f                   	pop    %edi
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    
  800e7f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e80:	b8 20 00 00 00       	mov    $0x20,%eax
  800e85:	29 f8                	sub    %edi,%eax
  800e87:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e8a:	89 f9                	mov    %edi,%ecx
  800e8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8f:	d3 e2                	shl    %cl,%edx
  800e91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e94:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e97:	d3 e8                	shr    %cl,%eax
  800e99:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ea0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ea3:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800ea6:	89 f2                	mov    %esi,%edx
  800ea8:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800eaa:	89 f9                	mov    %edi,%ecx
  800eac:	d3 e6                	shl    %cl,%esi
  800eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb1:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800eb4:	d3 e8                	shr    %cl,%eax
  800eb6:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800eb8:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	f7 75 f4             	divl   -0xc(%ebp)
  800ebf:	89 d6                	mov    %edx,%esi
  800ec1:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ec3:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec9:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ecb:	39 f2                	cmp    %esi,%edx
  800ecd:	77 0f                	ja     800ede <__udivdi3+0x106>
  800ecf:	0f 85 3f ff ff ff    	jne    800e14 <__udivdi3+0x3c>
  800ed5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800ed8:	0f 86 36 ff ff ff    	jbe    800e14 <__udivdi3+0x3c>
		{
		  q0--;
  800ede:	4f                   	dec    %edi
  800edf:	e9 30 ff ff ff       	jmp    800e14 <__udivdi3+0x3c>

00800ee4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	83 ec 30             	sub    $0x30,%esp
  800eec:	8b 55 14             	mov    0x14(%ebp),%edx
  800eef:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800ef2:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800ef4:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800ef7:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eff:	85 ff                	test   %edi,%edi
  800f01:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800f08:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800f0f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f12:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800f15:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f18:	75 3e                	jne    800f58 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800f1a:	39 d6                	cmp    %edx,%esi
  800f1c:	0f 86 a2 00 00 00    	jbe    800fc4 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f22:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800f24:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f27:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f29:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800f2c:	74 1b                	je     800f49 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800f2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f31:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800f34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f41:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800f44:	89 10                	mov    %edx,(%eax)
  800f46:	89 48 04             	mov    %ecx,0x4(%eax)
  800f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f4f:	83 c4 30             	add    $0x30,%esp
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    
  800f56:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f58:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800f5b:	76 1f                	jbe    800f7c <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800f60:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f63:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800f66:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f6c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f72:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f75:	83 c4 30             	add    $0x30,%esp
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f7c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f7f:	83 f0 1f             	xor    $0x1f,%eax
  800f82:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f85:	75 61                	jne    800fe8 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f87:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800f8a:	77 05                	ja     800f91 <__umoddi3+0xad>
  800f8c:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800f8f:	72 10                	jb     800fa1 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f91:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f97:	29 f0                	sub    %esi,%eax
  800f99:	19 fa                	sbb    %edi,%edx
  800f9b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f9e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800fa1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fa4:	85 d2                	test   %edx,%edx
  800fa6:	74 a1                	je     800f49 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800fa8:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800fab:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800fae:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800fb1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800fb4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fbd:	89 01                	mov    %eax,(%ecx)
  800fbf:	89 51 04             	mov    %edx,0x4(%ecx)
  800fc2:	eb 85                	jmp    800f49 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fc4:	85 f6                	test   %esi,%esi
  800fc6:	75 0b                	jne    800fd3 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fc8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcd:	31 d2                	xor    %edx,%edx
  800fcf:	f7 f6                	div    %esi
  800fd1:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fd3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fd6:	89 fa                	mov    %edi,%edx
  800fd8:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fda:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fdd:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fe0:	f7 f6                	div    %esi
  800fe2:	e9 3d ff ff ff       	jmp    800f24 <__umoddi3+0x40>
  800fe7:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fe8:	b8 20 00 00 00       	mov    $0x20,%eax
  800fed:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800ff0:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800ff3:	89 fa                	mov    %edi,%edx
  800ff5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800ff8:	d3 e2                	shl    %cl,%edx
  800ffa:	89 f0                	mov    %esi,%eax
  800ffc:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fff:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  801001:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801004:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801006:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801008:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80100b:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80100e:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801010:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801012:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801015:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801018:	d3 e0                	shl    %cl,%eax
  80101a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80101d:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801020:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801023:	d3 e8                	shr    %cl,%eax
  801025:	0b 45 cc             	or     -0x34(%ebp),%eax
  801028:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  80102b:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80102e:	f7 f7                	div    %edi
  801030:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801033:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801036:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801038:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  80103b:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80103e:	77 0a                	ja     80104a <__umoddi3+0x166>
  801040:	75 12                	jne    801054 <__umoddi3+0x170>
  801042:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801045:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801048:	76 0a                	jbe    801054 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80104a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80104d:	29 f1                	sub    %esi,%ecx
  80104f:	19 fa                	sbb    %edi,%edx
  801051:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801054:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801057:	85 c0                	test   %eax,%eax
  801059:	0f 84 ea fe ff ff    	je     800f49 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80105f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801062:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801065:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801068:	19 d1                	sbb    %edx,%ecx
  80106a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80106d:	89 ca                	mov    %ecx,%edx
  80106f:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801072:	d3 e2                	shl    %cl,%edx
  801074:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801077:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80107a:	d3 e8                	shr    %cl,%eax
  80107c:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80107e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801081:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801083:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801089:	e9 ad fe ff ff       	jmp    800f3b <__umoddi3+0x57>
