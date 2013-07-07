
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 a7 00 00 00       	call   8000d8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	68 c0 0f 80 00       	push   $0x800fc0
  80003f:	e8 cc 01 00 00       	call   800210 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800044:	b8 00 00 00 00       	mov    $0x0,%eax
  800049:	83 c4 10             	add    $0x10,%esp
		if (bigarray[i] != 0)
  80004c:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800053:	00 
  800054:	74 12                	je     800068 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800056:	50                   	push   %eax
  800057:	68 3b 10 80 00       	push   $0x80103b
  80005c:	6a 11                	push   $0x11
  80005e:	68 58 10 80 00       	push   $0x801058
  800063:	e8 cc 00 00 00       	call   800134 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800068:	40                   	inc    %eax
  800069:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  80006e:	7e dc                	jle    80004c <umain+0x18>
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800070:	b8 00 00 00 00       	mov    $0x0,%eax
  800075:	ba 20 20 80 00       	mov    $0x802020,%edx
		bigarray[i] = i;
  80007a:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	40                   	inc    %eax
  80007e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  800083:	7e f5                	jle    80007a <umain+0x46>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80008a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800091:	74 12                	je     8000a5 <umain+0x71>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800093:	50                   	push   %eax
  800094:	68 e0 0f 80 00       	push   $0x800fe0
  800099:	6a 16                	push   $0x16
  80009b:	68 58 10 80 00       	push   $0x801058
  8000a0:	e8 8f 00 00 00       	call   800134 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a5:	40                   	inc    %eax
  8000a6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8000ab:	7e dd                	jle    80008a <umain+0x56>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ad:	83 ec 0c             	sub    $0xc,%esp
  8000b0:	68 08 10 80 00       	push   $0x801008
  8000b5:	e8 56 01 00 00       	call   800210 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000ba:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c4:	83 c4 0c             	add    $0xc,%esp
  8000c7:	68 67 10 80 00       	push   $0x801067
  8000cc:	6a 1a                	push   $0x1a
  8000ce:	68 58 10 80 00       	push   $0x801058
  8000d3:	e8 5c 00 00 00       	call   800134 <_panic>

008000d8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000e3:	e8 e0 09 00 00       	call   800ac8 <sys_getenvid>
  8000e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ed:	89 c2                	mov    %eax,%edx
  8000ef:	c1 e2 05             	shl    $0x5,%edx
  8000f2:	29 c2                	sub    %eax,%edx
  8000f4:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8000fb:	89 15 20 20 c0 00    	mov    %edx,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800101:	85 f6                	test   %esi,%esi
  800103:	7e 07                	jle    80010c <libmain+0x34>
		binaryname = argv[0];
  800105:	8b 03                	mov    (%ebx),%eax
  800107:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	53                   	push   %ebx
  800110:	56                   	push   %esi
  800111:	e8 1e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800116:	e8 09 00 00 00       	call   800124 <exit>
}
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	c9                   	leave  
  800121:	c3                   	ret    
	...

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80012a:	6a 00                	push   $0x0
  80012c:	e8 56 09 00 00       	call   800a87 <sys_env_destroy>
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    
	...

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80013b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013e:	ff 75 0c             	pushl  0xc(%ebp)
  800141:	ff 75 08             	pushl  0x8(%ebp)
  800144:	ff 35 00 20 80 00    	pushl  0x802000
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	e8 76 09 00 00       	call   800ac8 <sys_getenvid>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	50                   	push   %eax
  800156:	68 88 10 80 00       	push   $0x801088
  80015b:	e8 b0 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 53 00 00 00       	call   8001bf <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 56 10 80 00 	movl   $0x801056,(%esp)
  800173:	e8 98 00 00 00       	call   800210 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800178:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80017b:	cc                   	int3   
  80017c:	eb fd                	jmp    80017b <_panic+0x47>
	...

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 03                	mov    (%ebx),%eax
  80018c:	8b 55 08             	mov    0x8(%ebp),%edx
  80018f:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  800193:	40                   	inc    %eax
  800194:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	75 1a                	jne    8001b7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 96 08 00 00       	call   800a44 <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b7:	ff 43 04             	incl   0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 80 01 80 00       	push   $0x800180
  8001ee:	e8 49 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  8001fc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 3c 08 00 00       	call   800a44 <sys_cputs>

	return b.cnt;
  800208:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 9d ff ff ff       	call   8001bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	8b 75 10             	mov    0x10(%ebp),%esi
  800230:	8b 7d 14             	mov    0x14(%ebp),%edi
  800233:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800236:	8b 45 18             	mov    0x18(%ebp),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	39 fa                	cmp    %edi,%edx
  800240:	77 39                	ja     80027b <printnum+0x57>
  800242:	72 04                	jb     800248 <printnum+0x24>
  800244:	39 f0                	cmp    %esi,%eax
  800246:	77 33                	ja     80027b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 20             	pushl  0x20(%ebp)
  80024e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800251:	50                   	push   %eax
  800252:	ff 75 18             	pushl  0x18(%ebp)
  800255:	8b 45 18             	mov    0x18(%ebp),%eax
  800258:	ba 00 00 00 00       	mov    $0x0,%edx
  80025d:	52                   	push   %edx
  80025e:	50                   	push   %eax
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	e8 92 0a 00 00       	call   800cf8 <__udivdi3>
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	52                   	push   %edx
  80026a:	50                   	push   %eax
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 ae ff ff ff       	call   800224 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 19                	jmp    800294 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	4b                   	dec    %ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7e 14                	jle    800294 <printnum+0x70>
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	ff 75 20             	pushl  0x20(%ebp)
  800289:	ff 55 08             	call   *0x8(%ebp)
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	4b                   	dec    %ebx
  800290:	85 db                	test   %ebx,%ebx
  800292:	7f ec                	jg     800280 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	8b 45 18             	mov    0x18(%ebp),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a2:	83 ec 04             	sub    $0x4,%esp
  8002a5:	52                   	push   %edx
  8002a6:	50                   	push   %eax
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	e8 56 0b 00 00       	call   800e04 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 bd 11 80 00 	movsbl 0x8011bd(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff 55 08             	call   *0x8(%ebp)
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002cd:	83 f8 01             	cmp    $0x1,%eax
  8002d0:	7e 0e                	jle    8002e0 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8002d2:	8b 11                	mov    (%ecx),%edx
  8002d4:	8d 42 08             	lea    0x8(%edx),%eax
  8002d7:	89 01                	mov    %eax,(%ecx)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	8b 52 04             	mov    0x4(%edx),%edx
  8002de:	eb 22                	jmp    800302 <getuint+0x3e>
	else if (lflag)
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	74 10                	je     8002f4 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8002e4:	8b 11                	mov    (%ecx),%edx
  8002e6:	8d 42 04             	lea    0x4(%edx),%eax
  8002e9:	89 01                	mov    %eax,(%ecx)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 0e                	jmp    800302 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  8002f4:	8b 11                	mov    (%ecx),%edx
  8002f6:	8d 42 04             	lea    0x4(%edx),%eax
  8002f9:	89 01                	mov    %eax,(%ecx)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80030d:	83 f8 01             	cmp    $0x1,%eax
  800310:	7e 0e                	jle    800320 <getint+0x1c>
		return va_arg(*ap, long long);
  800312:	8b 11                	mov    (%ecx),%edx
  800314:	8d 42 08             	lea    0x8(%edx),%eax
  800317:	89 01                	mov    %eax,(%ecx)
  800319:	8b 02                	mov    (%edx),%eax
  80031b:	8b 52 04             	mov    0x4(%edx),%edx
  80031e:	eb 1a                	jmp    80033a <getint+0x36>
	else if (lflag)
  800320:	85 c0                	test   %eax,%eax
  800322:	74 0c                	je     800330 <getint+0x2c>
		return va_arg(*ap, long);
  800324:	8b 01                	mov    (%ecx),%eax
  800326:	8d 50 04             	lea    0x4(%eax),%edx
  800329:	89 11                	mov    %edx,(%ecx)
  80032b:	8b 00                	mov    (%eax),%eax
  80032d:	99                   	cltd   
  80032e:	eb 0a                	jmp    80033a <getint+0x36>
	else
		return va_arg(*ap, int);
  800330:	8b 01                	mov    (%ecx),%eax
  800332:	8d 50 04             	lea    0x4(%eax),%edx
  800335:	89 11                	mov    %edx,(%ecx)
  800337:	8b 00                	mov    (%eax),%eax
  800339:	99                   	cltd   
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 1c             	sub    $0x1c,%esp
  800345:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800348:	0f b6 0b             	movzbl (%ebx),%ecx
  80034b:	43                   	inc    %ebx
  80034c:	83 f9 25             	cmp    $0x25,%ecx
  80034f:	74 1e                	je     80036f <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800351:	85 c9                	test   %ecx,%ecx
  800353:	0f 84 dc 02 00 00    	je     800635 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 0c             	pushl  0xc(%ebp)
  80035f:	51                   	push   %ecx
  800360:	ff 55 08             	call   *0x8(%ebp)
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	0f b6 0b             	movzbl (%ebx),%ecx
  800369:	43                   	inc    %ebx
  80036a:	83 f9 25             	cmp    $0x25,%ecx
  80036d:	75 e2                	jne    800351 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80036f:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800373:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80037a:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80037f:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800384:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	0f b6 0b             	movzbl (%ebx),%ecx
  80038e:	8d 41 dd             	lea    -0x23(%ecx),%eax
  800391:	43                   	inc    %ebx
  800392:	83 f8 55             	cmp    $0x55,%eax
  800395:	0f 87 75 02 00 00    	ja     800610 <vprintfmt+0x2d4>
  80039b:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a2:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8003a6:	eb e3                	jmp    80038b <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a8:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8003ac:	eb dd                	jmp    80038b <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ae:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003b6:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8003ba:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003c0:	83 f8 09             	cmp    $0x9,%eax
  8003c3:	77 28                	ja     8003ed <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	43                   	inc    %ebx
  8003c6:	eb eb                	jmp    8003b3 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cb:	8d 42 04             	lea    0x4(%edx),%eax
  8003ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8003d1:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8003d3:	eb 18                	jmp    8003ed <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8003d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003d9:	79 b0                	jns    80038b <vprintfmt+0x4f>
				width = 0;
  8003db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8003e2:	eb a7                	jmp    80038b <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003e4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  8003eb:	eb 9e                	jmp    80038b <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  8003ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003f1:	79 98                	jns    80038b <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003f3:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8003f6:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003fb:	eb 8e                	jmp    80038b <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	47                   	inc    %edi
			goto reswitch;
  8003fe:	eb 8b                	jmp    80038b <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	ff 75 0c             	pushl  0xc(%ebp)
  800406:	8b 55 14             	mov    0x14(%ebp),%edx
  800409:	8d 42 04             	lea    0x4(%edx),%eax
  80040c:	89 45 14             	mov    %eax,0x14(%ebp)
  80040f:	ff 32                	pushl  (%edx)
  800411:	ff 55 08             	call   *0x8(%ebp)
			break;
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	e9 2c ff ff ff       	jmp    800348 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041c:	8b 55 14             	mov    0x14(%ebp),%edx
  80041f:	8d 42 04             	lea    0x4(%edx),%eax
  800422:	89 45 14             	mov    %eax,0x14(%ebp)
  800425:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800427:	85 c0                	test   %eax,%eax
  800429:	79 02                	jns    80042d <vprintfmt+0xf1>
				err = -err;
  80042b:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042d:	83 f8 0f             	cmp    $0xf,%eax
  800430:	7f 0b                	jg     80043d <vprintfmt+0x101>
  800432:	8b 3c 85 20 12 80 00 	mov    0x801220(,%eax,4),%edi
  800439:	85 ff                	test   %edi,%edi
  80043b:	75 19                	jne    800456 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  80043d:	50                   	push   %eax
  80043e:	68 ce 11 80 00       	push   $0x8011ce
  800443:	ff 75 0c             	pushl  0xc(%ebp)
  800446:	ff 75 08             	pushl  0x8(%ebp)
  800449:	e8 ef 01 00 00       	call   80063d <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	e9 f2 fe ff ff       	jmp    800348 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800456:	57                   	push   %edi
  800457:	68 d7 11 80 00       	push   $0x8011d7
  80045c:	ff 75 0c             	pushl  0xc(%ebp)
  80045f:	ff 75 08             	pushl  0x8(%ebp)
  800462:	e8 d6 01 00 00       	call   80063d <printfmt>
  800467:	83 c4 10             	add    $0x10,%esp
			break;
  80046a:	e9 d9 fe ff ff       	jmp    800348 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046f:	8b 55 14             	mov    0x14(%ebp),%edx
  800472:	8d 42 04             	lea    0x4(%edx),%eax
  800475:	89 45 14             	mov    %eax,0x14(%ebp)
  800478:	8b 3a                	mov    (%edx),%edi
  80047a:	85 ff                	test   %edi,%edi
  80047c:	75 05                	jne    800483 <vprintfmt+0x147>
				p = "(null)";
  80047e:	bf da 11 80 00       	mov    $0x8011da,%edi
			if (width > 0 && padc != '-')
  800483:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800487:	7e 3b                	jle    8004c4 <vprintfmt+0x188>
  800489:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  80048d:	74 35                	je     8004c4 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	57                   	push   %edi
  800494:	e8 58 02 00 00       	call   8006f1 <strnlen>
  800499:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004a3:	7e 1f                	jle    8004c4 <vprintfmt+0x188>
  8004a5:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	ff 75 0c             	pushl  0xc(%ebp)
  8004b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	ff 4d f0             	decl   -0x10(%ebp)
  8004be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004c2:	7f e8                	jg     8004ac <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c4:	0f be 0f             	movsbl (%edi),%ecx
  8004c7:	47                   	inc    %edi
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	74 44                	je     800510 <vprintfmt+0x1d4>
  8004cc:	85 f6                	test   %esi,%esi
  8004ce:	78 03                	js     8004d3 <vprintfmt+0x197>
  8004d0:	4e                   	dec    %esi
  8004d1:	78 3d                	js     800510 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8004d7:	74 18                	je     8004f1 <vprintfmt+0x1b5>
  8004d9:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8004dc:	83 f8 5e             	cmp    $0x5e,%eax
  8004df:	76 10                	jbe    8004f1 <vprintfmt+0x1b5>
					putch('?', putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	6a 3f                	push   $0x3f
  8004e9:	ff 55 08             	call   *0x8(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	eb 0d                	jmp    8004fe <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	51                   	push   %ecx
  8004f8:	ff 55 08             	call   *0x8(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	ff 4d f0             	decl   -0x10(%ebp)
  800501:	0f be 0f             	movsbl (%edi),%ecx
  800504:	47                   	inc    %edi
  800505:	85 c9                	test   %ecx,%ecx
  800507:	74 07                	je     800510 <vprintfmt+0x1d4>
  800509:	85 f6                	test   %esi,%esi
  80050b:	78 c6                	js     8004d3 <vprintfmt+0x197>
  80050d:	4e                   	dec    %esi
  80050e:	79 c3                	jns    8004d3 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800510:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800514:	0f 8e 2e fe ff ff    	jle    800348 <vprintfmt+0xc>
				putch(' ', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 0c             	pushl  0xc(%ebp)
  800520:	6a 20                	push   $0x20
  800522:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	ff 4d f0             	decl   -0x10(%ebp)
  80052b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80052f:	7f e9                	jg     80051a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800531:	e9 12 fe ff ff       	jmp    800348 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800536:	57                   	push   %edi
  800537:	8d 45 14             	lea    0x14(%ebp),%eax
  80053a:	50                   	push   %eax
  80053b:	e8 c4 fd ff ff       	call   800304 <getint>
  800540:	89 c6                	mov    %eax,%esi
  800542:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800544:	83 c4 08             	add    $0x8,%esp
  800547:	85 d2                	test   %edx,%edx
  800549:	79 15                	jns    800560 <vprintfmt+0x224>
				putch('-', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 2d                	push   $0x2d
  800553:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800556:	f7 de                	neg    %esi
  800558:	83 d7 00             	adc    $0x0,%edi
  80055b:	f7 df                	neg    %edi
  80055d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800560:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800565:	eb 76                	jmp    8005dd <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800567:	57                   	push   %edi
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
  80056b:	50                   	push   %eax
  80056c:	e8 53 fd ff ff       	call   8002c4 <getuint>
  800571:	89 c6                	mov    %eax,%esi
  800573:	89 d7                	mov    %edx,%edi
			base = 10;
  800575:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	eb 5e                	jmp    8005dd <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80057f:	57                   	push   %edi
  800580:	8d 45 14             	lea    0x14(%ebp),%eax
  800583:	50                   	push   %eax
  800584:	e8 3b fd ff ff       	call   8002c4 <getuint>
  800589:	89 c6                	mov    %eax,%esi
  80058b:	89 d7                	mov    %edx,%edi
			base = 8;
  80058d:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  800592:	83 c4 08             	add    $0x8,%esp
  800595:	eb 46                	jmp    8005dd <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	ff 75 0c             	pushl  0xc(%ebp)
  80059d:	6a 30                	push   $0x30
  80059f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	ff 75 0c             	pushl  0xc(%ebp)
  8005a8:	6a 78                	push   $0x78
  8005aa:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8005ad:	8b 55 14             	mov    0x14(%ebp),%edx
  8005b0:	8d 42 04             	lea    0x4(%edx),%eax
  8005b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b6:	8b 32                	mov    (%edx),%esi
  8005b8:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005bd:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	eb 16                	jmp    8005dd <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c7:	57                   	push   %edi
  8005c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cb:	50                   	push   %eax
  8005cc:	e8 f3 fc ff ff       	call   8002c4 <getuint>
  8005d1:	89 c6                	mov    %eax,%esi
  8005d3:	89 d7                	mov    %edx,%edi
			base = 16;
  8005d5:	ba 10 00 00 00       	mov    $0x10,%edx
  8005da:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005dd:	83 ec 04             	sub    $0x4,%esp
  8005e0:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8005e8:	52                   	push   %edx
  8005e9:	57                   	push   %edi
  8005ea:	56                   	push   %esi
  8005eb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ee:	ff 75 08             	pushl  0x8(%ebp)
  8005f1:	e8 2e fc ff ff       	call   800224 <printnum>
			break;
  8005f6:	83 c4 20             	add    $0x20,%esp
  8005f9:	e9 4a fd ff ff       	jmp    800348 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	51                   	push   %ecx
  800605:	ff 55 08             	call   *0x8(%ebp)
			break;
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	e9 38 fd ff ff       	jmp    800348 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	ff 75 0c             	pushl  0xc(%ebp)
  800616:	6a 25                	push   $0x25
  800618:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061b:	4b                   	dec    %ebx
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800623:	0f 84 1f fd ff ff    	je     800348 <vprintfmt+0xc>
  800629:	4b                   	dec    %ebx
  80062a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80062e:	75 f9                	jne    800629 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800630:	e9 13 fd ff ff       	jmp    800348 <vprintfmt+0xc>
		}
	}
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	c9                   	leave  
  80063c:	c3                   	ret    

0080063d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800646:	50                   	push   %eax
  800647:	ff 75 10             	pushl  0x10(%ebp)
  80064a:	ff 75 0c             	pushl  0xc(%ebp)
  80064d:	ff 75 08             	pushl  0x8(%ebp)
  800650:	e8 e7 fc ff ff       	call   80033c <vprintfmt>
	va_end(ap);
}
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80065d:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800660:	8b 0a                	mov    (%edx),%ecx
  800662:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800665:	73 07                	jae    80066e <sprintputch+0x17>
		*b->buf++ = ch;
  800667:	8b 45 08             	mov    0x8(%ebp),%eax
  80066a:	88 01                	mov    %al,(%ecx)
  80066c:	ff 02                	incl   (%edx)
}
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    

00800670 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	83 ec 18             	sub    $0x18,%esp
  800676:	8b 55 08             	mov    0x8(%ebp),%edx
  800679:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80067f:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  800683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800686:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  80068d:	85 d2                	test   %edx,%edx
  80068f:	74 04                	je     800695 <vsnprintf+0x25>
  800691:	85 c9                	test   %ecx,%ecx
  800693:	7f 07                	jg     80069c <vsnprintf+0x2c>
		return -E_INVAL;
  800695:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069a:	eb 1d                	jmp    8006b9 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069c:	ff 75 14             	pushl  0x14(%ebp)
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	68 57 06 80 00       	push   $0x800657
  8006ab:	e8 8c fc ff ff       	call   80033c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c4:	50                   	push   %eax
  8006c5:	ff 75 10             	pushl  0x10(%ebp)
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	ff 75 08             	pushl  0x8(%ebp)
  8006ce:	e8 9d ff ff ff       	call   800670 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    
  8006d5:	00 00                	add    %al,(%eax)
	...

008006d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	80 3a 00             	cmpb   $0x0,(%edx)
  8006e6:	74 07                	je     8006ef <strlen+0x17>
		n++;
  8006e8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	42                   	inc    %edx
  8006ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8006ed:	75 f9                	jne    8006e8 <strlen+0x10>
		n++;
	return n;
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	85 d2                	test   %edx,%edx
  800701:	74 0f                	je     800712 <strnlen+0x21>
  800703:	80 39 00             	cmpb   $0x0,(%ecx)
  800706:	74 0a                	je     800712 <strnlen+0x21>
		n++;
  800708:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800709:	41                   	inc    %ecx
  80070a:	4a                   	dec    %edx
  80070b:	74 05                	je     800712 <strnlen+0x21>
  80070d:	80 39 00             	cmpb   $0x0,(%ecx)
  800710:	75 f6                	jne    800708 <strnlen+0x17>
		n++;
	return n;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80071e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800720:	8a 02                	mov    (%edx),%al
  800722:	42                   	inc    %edx
  800723:	88 01                	mov    %al,(%ecx)
  800725:	41                   	inc    %ecx
  800726:	84 c0                	test   %al,%al
  800728:	75 f6                	jne    800720 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072a:	89 d8                	mov    %ebx,%eax
  80072c:	5b                   	pop    %ebx
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800736:	53                   	push   %ebx
  800737:	e8 9c ff ff ff       	call   8006d8 <strlen>
	strcpy(dst + len, src);
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800742:	50                   	push   %eax
  800743:	e8 cc ff ff ff       	call   800714 <strcpy>
	return dst;
}
  800748:	89 d8                	mov    %ebx,%eax
  80074a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80075e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800760:	bb 00 00 00 00       	mov    $0x0,%ebx
  800765:	39 f3                	cmp    %esi,%ebx
  800767:	73 10                	jae    800779 <strncpy+0x2a>
		*dst++ = *src;
  800769:	8a 02                	mov    (%edx),%al
  80076b:	88 01                	mov    %al,(%ecx)
  80076d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076e:	80 3a 01             	cmpb   $0x1,(%edx)
  800771:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800774:	43                   	inc    %ebx
  800775:	39 f3                	cmp    %esi,%ebx
  800777:	72 f0                	jb     800769 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800779:	89 f8                	mov    %edi,%eax
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80078e:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  800790:	85 d2                	test   %edx,%edx
  800792:	74 19                	je     8007ad <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800794:	4a                   	dec    %edx
  800795:	74 13                	je     8007aa <strlcpy+0x2a>
  800797:	80 39 00             	cmpb   $0x0,(%ecx)
  80079a:	74 0e                	je     8007aa <strlcpy+0x2a>
  80079c:	8a 01                	mov    (%ecx),%al
  80079e:	41                   	inc    %ecx
  80079f:	88 03                	mov    %al,(%ebx)
  8007a1:	43                   	inc    %ebx
  8007a2:	4a                   	dec    %edx
  8007a3:	74 05                	je     8007aa <strlcpy+0x2a>
  8007a5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a8:	75 f2                	jne    80079c <strlcpy+0x1c>
		*dst = '\0';
  8007aa:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007ad:	89 d8                	mov    %ebx,%eax
  8007af:	29 f0                	sub    %esi,%eax
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8007be:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c1:	74 13                	je     8007d6 <strcmp+0x21>
  8007c3:	8a 02                	mov    (%edx),%al
  8007c5:	3a 01                	cmp    (%ecx),%al
  8007c7:	75 0d                	jne    8007d6 <strcmp+0x21>
  8007c9:	42                   	inc    %edx
  8007ca:	41                   	inc    %ecx
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 06                	je     8007d6 <strcmp+0x21>
  8007d0:	8a 02                	mov    (%edx),%al
  8007d2:	3a 01                	cmp    (%ecx),%al
  8007d4:	74 f3                	je     8007c9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d6:	0f b6 02             	movzbl (%edx),%eax
  8007d9:	0f b6 11             	movzbl (%ecx),%edx
  8007dc:	29 d0                	sub    %edx,%eax
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007ed:	85 c9                	test   %ecx,%ecx
  8007ef:	74 1f                	je     800810 <strncmp+0x30>
  8007f1:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f4:	74 16                	je     80080c <strncmp+0x2c>
  8007f6:	8a 02                	mov    (%edx),%al
  8007f8:	3a 03                	cmp    (%ebx),%al
  8007fa:	75 10                	jne    80080c <strncmp+0x2c>
  8007fc:	42                   	inc    %edx
  8007fd:	43                   	inc    %ebx
  8007fe:	49                   	dec    %ecx
  8007ff:	74 0f                	je     800810 <strncmp+0x30>
  800801:	80 3a 00             	cmpb   $0x0,(%edx)
  800804:	74 06                	je     80080c <strncmp+0x2c>
  800806:	8a 02                	mov    (%edx),%al
  800808:	3a 03                	cmp    (%ebx),%al
  80080a:	74 f0                	je     8007fc <strncmp+0x1c>
	if (n == 0)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	75 07                	jne    800817 <strncmp+0x37>
		return 0;
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 0a                	jmp    800821 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 12             	movzbl (%edx),%edx
  80081a:	0f b6 03             	movzbl (%ebx),%eax
  80081d:	29 c2                	sub    %eax,%edx
  80081f:	89 d0                	mov    %edx,%eax
}
  800821:	5b                   	pop    %ebx
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80082d:	80 38 00             	cmpb   $0x0,(%eax)
  800830:	74 0a                	je     80083c <strchr+0x18>
		if (*s == c)
  800832:	38 10                	cmp    %dl,(%eax)
  800834:	74 0b                	je     800841 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800836:	40                   	inc    %eax
  800837:	80 38 00             	cmpb   $0x0,(%eax)
  80083a:	75 f6                	jne    800832 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80084c:	80 38 00             	cmpb   $0x0,(%eax)
  80084f:	74 0a                	je     80085b <strfind+0x18>
		if (*s == c)
  800851:	38 10                	cmp    %dl,(%eax)
  800853:	74 06                	je     80085b <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800855:	40                   	inc    %eax
  800856:	80 38 00             	cmpb   $0x0,(%eax)
  800859:	75 f6                	jne    800851 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	8b 7d 08             	mov    0x8(%ebp),%edi
  800864:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800867:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 40                	je     8008ad <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800873:	75 30                	jne    8008a5 <memset+0x48>
  800875:	f6 c1 03             	test   $0x3,%cl
  800878:	75 2b                	jne    8008a5 <memset+0x48>
		c &= 0xFF;
  80087a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800881:	8b 45 0c             	mov    0xc(%ebp),%eax
  800884:	c1 e0 18             	shl    $0x18,%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	c1 e2 10             	shl    $0x10,%edx
  80088d:	09 d0                	or     %edx,%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	c1 e2 08             	shl    $0x8,%edx
  800895:	09 d0                	or     %edx,%eax
  800897:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  80089a:	c1 e9 02             	shr    $0x2,%ecx
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	fc                   	cld    
  8008a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a3:	eb 06                	jmp    8008ab <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	fc                   	cld    
  8008a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8008ab:	89 f8                	mov    %edi,%eax
}
  8008ad:	5f                   	pop    %edi
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	57                   	push   %edi
  8008b4:	56                   	push   %esi
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8008bb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008be:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008c0:	39 c6                	cmp    %eax,%esi
  8008c2:	73 34                	jae    8008f8 <memmove+0x48>
  8008c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c7:	39 c2                	cmp    %eax,%edx
  8008c9:	76 2d                	jbe    8008f8 <memmove+0x48>
		s += n;
  8008cb:	89 d6                	mov    %edx,%esi
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	f6 c2 03             	test   $0x3,%dl
  8008d3:	75 1b                	jne    8008f0 <memmove+0x40>
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 13                	jne    8008f0 <memmove+0x40>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 0e                	jne    8008f0 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008e2:	83 ef 04             	sub    $0x4,%edi
  8008e5:	83 ee 04             	sub    $0x4,%esi
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
  8008eb:	fd                   	std    
  8008ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ee:	eb 05                	jmp    8008f5 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f0:	4f                   	dec    %edi
  8008f1:	4e                   	dec    %esi
  8008f2:	fd                   	std    
  8008f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f5:	fc                   	cld    
  8008f6:	eb 20                	jmp    800918 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fe:	75 15                	jne    800915 <memmove+0x65>
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 0d                	jne    800915 <memmove+0x65>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 08                	jne    800915 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  80090d:	c1 e9 02             	shr    $0x2,%ecx
  800910:	fc                   	cld    
  800911:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800913:	eb 03                	jmp    800918 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800915:	fc                   	cld    
  800916:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091f:	ff 75 10             	pushl  0x10(%ebp)
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	ff 75 08             	pushl  0x8(%ebp)
  800928:	e8 83 ff ff ff       	call   8008b0 <memmove>
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800933:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800936:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800939:	8b 55 10             	mov    0x10(%ebp),%edx
  80093c:	4a                   	dec    %edx
  80093d:	83 fa ff             	cmp    $0xffffffff,%edx
  800940:	74 1a                	je     80095c <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800942:	8a 01                	mov    (%ecx),%al
  800944:	3a 03                	cmp    (%ebx),%al
  800946:	74 0c                	je     800954 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800948:	0f b6 d0             	movzbl %al,%edx
  80094b:	0f b6 03             	movzbl (%ebx),%eax
  80094e:	29 c2                	sub    %eax,%edx
  800950:	89 d0                	mov    %edx,%eax
  800952:	eb 0d                	jmp    800961 <memcmp+0x32>
		s1++, s2++;
  800954:	41                   	inc    %ecx
  800955:	43                   	inc    %ebx
  800956:	4a                   	dec    %edx
  800957:	83 fa ff             	cmp    $0xffffffff,%edx
  80095a:	75 e6                	jne    800942 <memcmp+0x13>
	}

	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800972:	39 d0                	cmp    %edx,%eax
  800974:	73 09                	jae    80097f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800976:	38 08                	cmp    %cl,(%eax)
  800978:	74 05                	je     80097f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097a:	40                   	inc    %eax
  80097b:	39 d0                	cmp    %edx,%eax
  80097d:	72 f7                	jb     800976 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 55 08             	mov    0x8(%ebp),%edx
  80098a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800990:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800995:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80099a:	80 3a 20             	cmpb   $0x20,(%edx)
  80099d:	74 05                	je     8009a4 <strtol+0x23>
  80099f:	80 3a 09             	cmpb   $0x9,(%edx)
  8009a2:	75 0b                	jne    8009af <strtol+0x2e>
  8009a4:	42                   	inc    %edx
  8009a5:	80 3a 20             	cmpb   $0x20,(%edx)
  8009a8:	74 fa                	je     8009a4 <strtol+0x23>
  8009aa:	80 3a 09             	cmpb   $0x9,(%edx)
  8009ad:	74 f5                	je     8009a4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8009af:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8009b2:	75 03                	jne    8009b7 <strtol+0x36>
		s++;
  8009b4:	42                   	inc    %edx
  8009b5:	eb 0b                	jmp    8009c2 <strtol+0x41>
	else if (*s == '-')
  8009b7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8009ba:	75 06                	jne    8009c2 <strtol+0x41>
		s++, neg = 1;
  8009bc:	42                   	inc    %edx
  8009bd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c2:	85 c9                	test   %ecx,%ecx
  8009c4:	74 05                	je     8009cb <strtol+0x4a>
  8009c6:	83 f9 10             	cmp    $0x10,%ecx
  8009c9:	75 15                	jne    8009e0 <strtol+0x5f>
  8009cb:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ce:	75 10                	jne    8009e0 <strtol+0x5f>
  8009d0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009d4:	75 0a                	jne    8009e0 <strtol+0x5f>
		s += 2, base = 16;
  8009d6:	83 c2 02             	add    $0x2,%edx
  8009d9:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009de:	eb 14                	jmp    8009f4 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	75 10                	jne    8009f4 <strtol+0x73>
  8009e4:	80 3a 30             	cmpb   $0x30,(%edx)
  8009e7:	75 05                	jne    8009ee <strtol+0x6d>
		s++, base = 8;
  8009e9:	42                   	inc    %edx
  8009ea:	b1 08                	mov    $0x8,%cl
  8009ec:	eb 06                	jmp    8009f4 <strtol+0x73>
	else if (base == 0)
  8009ee:	85 c9                	test   %ecx,%ecx
  8009f0:	75 02                	jne    8009f4 <strtol+0x73>
		base = 10;
  8009f2:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f4:	8a 02                	mov    (%edx),%al
  8009f6:	83 e8 30             	sub    $0x30,%eax
  8009f9:	3c 09                	cmp    $0x9,%al
  8009fb:	77 08                	ja     800a05 <strtol+0x84>
			dig = *s - '0';
  8009fd:	0f be 02             	movsbl (%edx),%eax
  800a00:	83 e8 30             	sub    $0x30,%eax
  800a03:	eb 20                	jmp    800a25 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800a05:	8a 02                	mov    (%edx),%al
  800a07:	83 e8 61             	sub    $0x61,%eax
  800a0a:	3c 19                	cmp    $0x19,%al
  800a0c:	77 08                	ja     800a16 <strtol+0x95>
			dig = *s - 'a' + 10;
  800a0e:	0f be 02             	movsbl (%edx),%eax
  800a11:	83 e8 57             	sub    $0x57,%eax
  800a14:	eb 0f                	jmp    800a25 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800a16:	8a 02                	mov    (%edx),%al
  800a18:	83 e8 41             	sub    $0x41,%eax
  800a1b:	3c 19                	cmp    $0x19,%al
  800a1d:	77 12                	ja     800a31 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800a1f:	0f be 02             	movsbl (%edx),%eax
  800a22:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a25:	39 c8                	cmp    %ecx,%eax
  800a27:	7d 08                	jge    800a31 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a29:	42                   	inc    %edx
  800a2a:	0f af d9             	imul   %ecx,%ebx
  800a2d:	01 c3                	add    %eax,%ebx
  800a2f:	eb c3                	jmp    8009f4 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a31:	85 f6                	test   %esi,%esi
  800a33:	74 02                	je     800a37 <strtol+0xb6>
		*endptr = (char *) s;
  800a35:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a37:	89 d8                	mov    %ebx,%eax
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	74 02                	je     800a3f <strtol+0xbe>
  800a3d:	f7 d8                	neg    %eax
}
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	83 ec 04             	sub    $0x4,%esp
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	89 f8                	mov    %edi,%eax
  800a5a:	89 fb                	mov    %edi,%ebx
  800a5c:	89 fe                	mov    %edi,%esi
  800a5e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a60:	83 c4 04             	add    $0x4,%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <sys_cgetc>:

int
sys_cgetc(void)
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
  800a6e:	b8 01 00 00 00       	mov    $0x1,%eax
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

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	83 ec 0c             	sub    $0xc,%esp
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a93:	b8 03 00 00 00       	mov    $0x3,%eax
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9d:	89 f9                	mov    %edi,%ecx
  800a9f:	89 fb                	mov    %edi,%ebx
  800aa1:	89 fe                	mov    %edi,%esi
  800aa3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa5:	85 c0                	test   %eax,%eax
  800aa7:	7e 17                	jle    800ac0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	50                   	push   %eax
  800aad:	6a 03                	push   $0x3
  800aaf:	68 b8 13 80 00       	push   $0x8013b8
  800ab4:	6a 23                	push   $0x23
  800ab6:	68 d5 13 80 00       	push   $0x8013d5
  800abb:	e8 74 f6 ff ff       	call   800134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ace:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	89 fa                	mov    %edi,%edx
  800ada:	89 f9                	mov    %edi,%ecx
  800adc:	89 fb                	mov    %edi,%ebx
  800ade:	89 fe                	mov    %edi,%esi
  800ae0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <sys_yield>:

void
sys_yield(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af7:	89 fa                	mov    %edi,%edx
  800af9:	89 f9                	mov    %edi,%ecx
  800afb:	89 fb                	mov    %edi,%ebx
  800afd:	89 fe                	mov    %edi,%esi
  800aff:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b18:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	89 fe                	mov    %edi,%esi
  800b24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b26:	85 c0                	test   %eax,%eax
  800b28:	7e 17                	jle    800b41 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	50                   	push   %eax
  800b2e:	6a 04                	push   $0x4
  800b30:	68 b8 13 80 00       	push   $0x8013b8
  800b35:	6a 23                	push   $0x23
  800b37:	68 d5 13 80 00       	push   $0x8013d5
  800b3c:	e8 f3 f5 ff ff       	call   800134 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5e:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b61:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 05                	push   $0x5
  800b72:	68 b8 13 80 00       	push   $0x8013b8
  800b77:	6a 23                	push   $0x23
  800b79:	68 d5 13 80 00       	push   $0x8013d5
  800b7e:	e8 b1 f5 ff ff       	call   800134 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	89 fb                	mov    %edi,%ebx
  800ba6:	89 fe                	mov    %edi,%esi
  800ba8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 06                	push   $0x6
  800bb4:	68 b8 13 80 00       	push   $0x8013b8
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 d5 13 80 00       	push   $0x8013d5
  800bc0:	e8 6f f5 ff ff       	call   800134 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800be1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	89 fb                	mov    %edi,%ebx
  800be8:	89 fe                	mov    %edi,%esi
  800bea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 08                	push   $0x8
  800bf6:	68 b8 13 80 00       	push   $0x8013b8
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 d5 13 80 00       	push   $0x8013d5
  800c02:	e8 2d f5 ff ff       	call   800134 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c23:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	89 fb                	mov    %edi,%ebx
  800c2a:	89 fe                	mov    %edi,%esi
  800c2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 09                	push   $0x9
  800c38:	68 b8 13 80 00       	push   $0x8013b8
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 d5 13 80 00       	push   $0x8013d5
  800c44:	e8 eb f4 ff ff       	call   800134 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    

00800c51 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c65:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	89 fb                	mov    %edi,%ebx
  800c6c:	89 fe                	mov    %edi,%esi
  800c6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 0a                	push   $0xa
  800c7a:	68 b8 13 80 00       	push   $0x8013b8
  800c7f:	6a 23                	push   $0x23
  800c81:	68 d5 13 80 00       	push   $0x8013d5
  800c86:	e8 a9 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca2:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ca5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800caa:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cc2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	89 f9                	mov    %edi,%ecx
  800cce:	89 fb                	mov    %edi,%ebx
  800cd0:	89 fe                	mov    %edi,%esi
  800cd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 17                	jle    800cef <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 0d                	push   $0xd
  800cde:	68 b8 13 80 00       	push   $0x8013b8
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 d5 13 80 00       	push   $0x8013d5
  800cea:	e8 45 f4 ff ff       	call   800134 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    
	...

00800cf8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	83 ec 14             	sub    $0x14,%esp
  800d00:	8b 55 14             	mov    0x14(%ebp),%edx
  800d03:	8b 75 08             	mov    0x8(%ebp),%esi
  800d06:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d09:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d0c:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d0e:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800d14:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800d17:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d19:	75 11                	jne    800d2c <__udivdi3+0x34>
    {
      if (d0 > n1)
  800d1b:	39 f8                	cmp    %edi,%eax
  800d1d:	76 4d                	jbe    800d6c <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d1f:	89 fa                	mov    %edi,%edx
  800d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d24:	f7 75 e4             	divl   -0x1c(%ebp)
  800d27:	89 c7                	mov    %eax,%edi
  800d29:	eb 09                	jmp    800d34 <__udivdi3+0x3c>
  800d2b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d2c:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800d2f:	76 17                	jbe    800d48 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800d31:	31 ff                	xor    %edi,%edi
  800d33:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800d34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d3e:	83 c4 14             	add    $0x14,%esp
  800d41:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d42:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d44:	5f                   	pop    %edi
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    
  800d47:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d48:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	83 f7 1f             	xor    $0x1f,%edi
  800d51:	75 4d                	jne    800da0 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d53:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800d56:	77 0a                	ja     800d62 <__udivdi3+0x6a>
  800d58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800d5b:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d5d:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800d60:	72 d2                	jb     800d34 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800d62:	bf 01 00 00 00       	mov    $0x1,%edi
  800d67:	eb cb                	jmp    800d34 <__udivdi3+0x3c>
  800d69:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	75 0e                	jne    800d81 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d73:	b8 01 00 00 00       	mov    $0x1,%eax
  800d78:	31 c9                	xor    %ecx,%ecx
  800d7a:	31 d2                	xor    %edx,%edx
  800d7c:	f7 f1                	div    %ecx
  800d7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d81:	89 f0                	mov    %esi,%eax
  800d83:	31 d2                	xor    %edx,%edx
  800d85:	f7 75 e4             	divl   -0x1c(%ebp)
  800d88:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d8e:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d91:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d94:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d97:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d99:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d9a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d9c:	5f                   	pop    %edi
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    
  800d9f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800da0:	b8 20 00 00 00       	mov    $0x20,%eax
  800da5:	29 f8                	sub    %edi,%eax
  800da7:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800daa:	89 f9                	mov    %edi,%ecx
  800dac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800daf:	d3 e2                	shl    %cl,%edx
  800db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800db4:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800dbb:	89 f9                	mov    %edi,%ecx
  800dbd:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dc0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800dc3:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800dc6:	89 f2                	mov    %esi,%edx
  800dc8:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800dca:	89 f9                	mov    %edi,%ecx
  800dcc:	d3 e6                	shl    %cl,%esi
  800dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd1:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800dd4:	d3 e8                	shr    %cl,%eax
  800dd6:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800dd8:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dda:	89 f0                	mov    %esi,%eax
  800ddc:	f7 75 f4             	divl   -0xc(%ebp)
  800ddf:	89 d6                	mov    %edx,%esi
  800de1:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800de3:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de9:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800deb:	39 f2                	cmp    %esi,%edx
  800ded:	77 0f                	ja     800dfe <__udivdi3+0x106>
  800def:	0f 85 3f ff ff ff    	jne    800d34 <__udivdi3+0x3c>
  800df5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800df8:	0f 86 36 ff ff ff    	jbe    800d34 <__udivdi3+0x3c>
		{
		  q0--;
  800dfe:	4f                   	dec    %edi
  800dff:	e9 30 ff ff ff       	jmp    800d34 <__udivdi3+0x3c>

00800e04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	83 ec 30             	sub    $0x30,%esp
  800e0c:	8b 55 14             	mov    0x14(%ebp),%edx
  800e0f:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800e12:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e14:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e17:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e19:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e1f:	85 ff                	test   %edi,%edi
  800e21:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800e28:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800e2f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e32:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800e35:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e38:	75 3e                	jne    800e78 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800e3a:	39 d6                	cmp    %edx,%esi
  800e3c:	0f 86 a2 00 00 00    	jbe    800ee4 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e42:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e44:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e47:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e49:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800e4c:	74 1b                	je     800e69 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800e4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e51:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800e54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e61:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e64:	89 10                	mov    %edx,(%eax)
  800e66:	89 48 04             	mov    %ecx,0x4(%eax)
  800e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e6f:	83 c4 30             	add    $0x30,%esp
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	c9                   	leave  
  800e75:	c3                   	ret    
  800e76:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e78:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800e7b:	76 1f                	jbe    800e9c <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800e80:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e83:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800e86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e92:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e95:	83 c4 30             	add    $0x30,%esp
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e9c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e9f:	83 f0 1f             	xor    $0x1f,%eax
  800ea2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ea5:	75 61                	jne    800f08 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ea7:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800eaa:	77 05                	ja     800eb1 <__umoddi3+0xad>
  800eac:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800eaf:	72 10                	jb     800ec1 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800eb1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800eb4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800eb7:	29 f0                	sub    %esi,%eax
  800eb9:	19 fa                	sbb    %edi,%edx
  800ebb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ebe:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800ec1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ec4:	85 d2                	test   %edx,%edx
  800ec6:	74 a1                	je     800e69 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800ec8:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800ecb:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ece:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800ed1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800ed4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800ed7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800edd:	89 01                	mov    %eax,(%ecx)
  800edf:	89 51 04             	mov    %edx,0x4(%ecx)
  800ee2:	eb 85                	jmp    800e69 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ee4:	85 f6                	test   %esi,%esi
  800ee6:	75 0b                	jne    800ef3 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ee8:	b8 01 00 00 00       	mov    $0x1,%eax
  800eed:	31 d2                	xor    %edx,%edx
  800eef:	f7 f6                	div    %esi
  800ef1:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ef3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ef6:	89 fa                	mov    %edi,%edx
  800ef8:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800efa:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800efd:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f00:	f7 f6                	div    %esi
  800f02:	e9 3d ff ff ff       	jmp    800e44 <__umoddi3+0x40>
  800f07:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f08:	b8 20 00 00 00       	mov    $0x20,%eax
  800f0d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800f10:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800f13:	89 fa                	mov    %edi,%edx
  800f15:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f18:	d3 e2                	shl    %cl,%edx
  800f1a:	89 f0                	mov    %esi,%eax
  800f1c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f1f:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800f21:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f24:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f26:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f28:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f2b:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f2e:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f30:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f32:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f35:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800f38:	d3 e0                	shl    %cl,%eax
  800f3a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800f3d:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f40:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f43:	d3 e8                	shr    %cl,%eax
  800f45:	0b 45 cc             	or     -0x34(%ebp),%eax
  800f48:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800f4b:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f4e:	f7 f7                	div    %edi
  800f50:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f53:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f56:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f58:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f5b:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f5e:	77 0a                	ja     800f6a <__umoddi3+0x166>
  800f60:	75 12                	jne    800f74 <__umoddi3+0x170>
  800f62:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f65:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  800f68:	76 0a                	jbe    800f74 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f6a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800f6d:	29 f1                	sub    %esi,%ecx
  800f6f:	19 fa                	sbb    %edi,%edx
  800f71:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  800f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f77:	85 c0                	test   %eax,%eax
  800f79:	0f 84 ea fe ff ff    	je     800e69 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f7f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f82:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f85:	2b 45 c8             	sub    -0x38(%ebp),%eax
  800f88:	19 d1                	sbb    %edx,%ecx
  800f8a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f8d:	89 ca                	mov    %ecx,%edx
  800f8f:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800f92:	d3 e2                	shl    %cl,%edx
  800f94:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f97:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f9a:	d3 e8                	shr    %cl,%eax
  800f9c:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  800f9e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fa1:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fa3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  800fa6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fa9:	e9 ad fe ff ff       	jmp    800e5b <__umoddi3+0x57>
