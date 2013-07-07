
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8a 5d 0c             	mov    0xc(%ebp),%bl
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800042:	56                   	push   %esi
  800043:	e8 4c 06 00 00       	call   800694 <strlen>
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	83 f8 02             	cmp    $0x2,%eax
  80004e:	7f 38                	jg     800088 <forkchild+0x54>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	0f be c3             	movsbl %bl,%eax
  800056:	50                   	push   %eax
  800057:	56                   	push   %esi
  800058:	68 40 11 80 00       	push   $0x801140
  80005d:	6a 04                	push   $0x4
  80005f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800062:	50                   	push   %eax
  800063:	e8 0f 06 00 00       	call   800677 <snprintf>
	if (fork() == 0) {
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	e8 e2 0c 00 00       	call   800d52 <fork>
  800070:	85 c0                	test   %eax,%eax
  800072:	75 14                	jne    800088 <forkchild+0x54>
		forktree(nxt);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80007a:	50                   	push   %eax
  80007b:	e8 0f 00 00 00       	call   80008f <forktree>
		exit();
  800080:	e8 a7 00 00 00       	call   80012c <exit>
  800085:	83 c4 10             	add    $0x10,%esp
	}
}
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <forktree>:

void
forktree(const char *cur)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	53                   	push   %ebx
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800099:	53                   	push   %ebx
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	e8 e2 09 00 00       	call   800a84 <sys_getenvid>
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	50                   	push   %eax
  8000a6:	68 45 11 80 00       	push   $0x801145
  8000ab:	e8 1c 01 00 00       	call   8001cc <cprintf>

	forkchild(cur, '0');
  8000b0:	83 c4 08             	add    $0x8,%esp
  8000b3:	6a 30                	push   $0x30
  8000b5:	53                   	push   %ebx
  8000b6:	e8 79 ff ff ff       	call   800034 <forkchild>
	forkchild(cur, '1');
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	6a 31                	push   $0x31
  8000c0:	53                   	push   %ebx
  8000c1:	e8 6e ff ff ff       	call   800034 <forkchild>
}
  8000c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <umain>:

void
umain(int argc, char **argv)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d1:	68 55 11 80 00       	push   $0x801155
  8000d6:	e8 b4 ff ff ff       	call   80008f <forktree>
}
  8000db:	c9                   	leave  
  8000dc:	c3                   	ret    
  8000dd:	00 00                	add    %al,(%eax)
	...

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8000eb:	e8 94 09 00 00       	call   800a84 <sys_getenvid>
  8000f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f5:	89 c2                	mov    %eax,%edx
  8000f7:	c1 e2 05             	shl    $0x5,%edx
  8000fa:	29 c2                	sub    %eax,%edx
  8000fc:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800103:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 f6                	test   %esi,%esi
  80010b:	7e 07                	jle    800114 <libmain+0x34>
		binaryname = argv[0];
  80010d:	8b 03                	mov    (%ebx),%eax
  80010f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	53                   	push   %ebx
  800118:	56                   	push   %esi
  800119:	e8 ad ff ff ff       	call   8000cb <umain>

	// exit gracefully
	exit();
  80011e:	e8 09 00 00 00       	call   80012c <exit>
}
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	c9                   	leave  
  800129:	c3                   	ret    
	...

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800132:	6a 00                	push   $0x0
  800134:	e8 0a 09 00 00       	call   800a43 <sys_env_destroy>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    
	...

0080013c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	53                   	push   %ebx
  800140:	83 ec 04             	sub    $0x4,%esp
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800146:	8b 03                	mov    (%ebx),%eax
  800148:	8b 55 08             	mov    0x8(%ebp),%edx
  80014b:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  80014f:	40                   	inc    %eax
  800150:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800152:	3d ff 00 00 00       	cmp    $0xff,%eax
  800157:	75 1a                	jne    800173 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	68 ff 00 00 00       	push   $0xff
  800161:	8d 43 08             	lea    0x8(%ebx),%eax
  800164:	50                   	push   %eax
  800165:	e8 96 08 00 00       	call   800a00 <sys_cputs>
		b->idx = 0;
  80016a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800170:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800173:	ff 43 04             	incl   0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 3c 01 80 00       	push   $0x80013c
  8001aa:	e8 49 01 00 00       	call   8002f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 3c 08 00 00       	call   800a00 <sys_cputs>

	return b.cnt;
  8001c4:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8001ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ef:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001fa:	39 fa                	cmp    %edi,%edx
  8001fc:	77 39                	ja     800237 <printnum+0x57>
  8001fe:	72 04                	jb     800204 <printnum+0x24>
  800200:	39 f0                	cmp    %esi,%eax
  800202:	77 33                	ja     800237 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	83 ec 04             	sub    $0x4,%esp
  800207:	ff 75 20             	pushl  0x20(%ebp)
  80020a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80020d:	50                   	push   %eax
  80020e:	ff 75 18             	pushl  0x18(%ebp)
  800211:	8b 45 18             	mov    0x18(%ebp),%eax
  800214:	ba 00 00 00 00       	mov    $0x0,%edx
  800219:	52                   	push   %edx
  80021a:	50                   	push   %eax
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	e8 52 0c 00 00       	call   800e74 <__udivdi3>
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	52                   	push   %edx
  800226:	50                   	push   %eax
  800227:	ff 75 0c             	pushl  0xc(%ebp)
  80022a:	ff 75 08             	pushl  0x8(%ebp)
  80022d:	e8 ae ff ff ff       	call   8001e0 <printnum>
  800232:	83 c4 20             	add    $0x20,%esp
  800235:	eb 19                	jmp    800250 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800237:	4b                   	dec    %ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7e 14                	jle    800250 <printnum+0x70>
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	ff 75 0c             	pushl  0xc(%ebp)
  800242:	ff 75 20             	pushl  0x20(%ebp)
  800245:	ff 55 08             	call   *0x8(%ebp)
  800248:	83 c4 10             	add    $0x10,%esp
  80024b:	4b                   	dec    %ebx
  80024c:	85 db                	test   %ebx,%ebx
  80024e:	7f ec                	jg     80023c <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	ff 75 0c             	pushl  0xc(%ebp)
  800256:	8b 45 18             	mov    0x18(%ebp),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	83 ec 04             	sub    $0x4,%esp
  800261:	52                   	push   %edx
  800262:	50                   	push   %eax
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	e8 16 0d 00 00       	call   800f80 <__umoddi3>
  80026a:	83 c4 14             	add    $0x14,%esp
  80026d:	0f be 80 72 12 80 00 	movsbl 0x801272(%eax),%eax
  800274:	50                   	push   %eax
  800275:	ff 55 08             	call   *0x8(%ebp)
}
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800289:	83 f8 01             	cmp    $0x1,%eax
  80028c:	7e 0e                	jle    80029c <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 11                	mov    (%ecx),%edx
  800290:	8d 42 08             	lea    0x8(%edx),%eax
  800293:	89 01                	mov    %eax,(%ecx)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x3e>
	else if (lflag)
  80029c:	85 c0                	test   %eax,%eax
  80029e:	74 10                	je     8002b0 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 11                	mov    (%ecx),%edx
  8002a2:	8d 42 04             	lea    0x4(%edx),%eax
  8002a5:	89 01                	mov    %eax,(%ecx)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 11                	mov    (%ecx),%edx
  8002b2:	8d 42 04             	lea    0x4(%edx),%eax
  8002b5:	89 01                	mov    %eax,(%ecx)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002c9:	83 f8 01             	cmp    $0x1,%eax
  8002cc:	7e 0e                	jle    8002dc <getint+0x1c>
		return va_arg(*ap, long long);
  8002ce:	8b 11                	mov    (%ecx),%edx
  8002d0:	8d 42 08             	lea    0x8(%edx),%eax
  8002d3:	89 01                	mov    %eax,(%ecx)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 1a                	jmp    8002f6 <getint+0x36>
	else if (lflag)
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	74 0c                	je     8002ec <getint+0x2c>
		return va_arg(*ap, long);
  8002e0:	8b 01                	mov    (%ecx),%eax
  8002e2:	8d 50 04             	lea    0x4(%eax),%edx
  8002e5:	89 11                	mov    %edx,(%ecx)
  8002e7:	8b 00                	mov    (%eax),%eax
  8002e9:	99                   	cltd   
  8002ea:	eb 0a                	jmp    8002f6 <getint+0x36>
	else
		return va_arg(*ap, int);
  8002ec:	8b 01                	mov    (%ecx),%eax
  8002ee:	8d 50 04             	lea    0x4(%eax),%edx
  8002f1:	89 11                	mov    %edx,(%ecx)
  8002f3:	8b 00                	mov    (%eax),%eax
  8002f5:	99                   	cltd   
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 1c             	sub    $0x1c,%esp
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800304:	0f b6 0b             	movzbl (%ebx),%ecx
  800307:	43                   	inc    %ebx
  800308:	83 f9 25             	cmp    $0x25,%ecx
  80030b:	74 1e                	je     80032b <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030d:	85 c9                	test   %ecx,%ecx
  80030f:	0f 84 dc 02 00 00    	je     8005f1 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	51                   	push   %ecx
  80031c:	ff 55 08             	call   *0x8(%ebp)
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	0f b6 0b             	movzbl (%ebx),%ecx
  800325:	43                   	inc    %ebx
  800326:	83 f9 25             	cmp    $0x25,%ecx
  800329:	75 e2                	jne    80030d <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80032b:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80032f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800336:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80033b:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800340:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	0f b6 0b             	movzbl (%ebx),%ecx
  80034a:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80034d:	43                   	inc    %ebx
  80034e:	83 f8 55             	cmp    $0x55,%eax
  800351:	0f 87 75 02 00 00    	ja     8005cc <vprintfmt+0x2d4>
  800357:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80035e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800362:	eb e3                	jmp    800347 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800364:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800368:	eb dd                	jmp    800347 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036a:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80036f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800372:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800376:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800379:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80037c:	83 f8 09             	cmp    $0x9,%eax
  80037f:	77 28                	ja     8003a9 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	43                   	inc    %ebx
  800382:	eb eb                	jmp    80036f <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 55 14             	mov    0x14(%ebp),%edx
  800387:	8d 42 04             	lea    0x4(%edx),%eax
  80038a:	89 45 14             	mov    %eax,0x14(%ebp)
  80038d:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80038f:	eb 18                	jmp    8003a9 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800391:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800395:	79 b0                	jns    800347 <vprintfmt+0x4f>
				width = 0;
  800397:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80039e:	eb a7                	jmp    800347 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003a0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  8003a7:	eb 9e                	jmp    800347 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  8003a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003ad:	79 98                	jns    800347 <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003af:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8003b2:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003b7:	eb 8e                	jmp    800347 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b9:	47                   	inc    %edi
			goto reswitch;
  8003ba:	eb 8b                	jmp    800347 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	ff 75 0c             	pushl  0xc(%ebp)
  8003c2:	8b 55 14             	mov    0x14(%ebp),%edx
  8003c5:	8d 42 04             	lea    0x4(%edx),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8003cb:	ff 32                	pushl  (%edx)
  8003cd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003d0:	83 c4 10             	add    $0x10,%esp
  8003d3:	e9 2c ff ff ff       	jmp    800304 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003db:	8d 42 04             	lea    0x4(%edx),%eax
  8003de:	89 45 14             	mov    %eax,0x14(%ebp)
  8003e1:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 02                	jns    8003e9 <vprintfmt+0xf1>
				err = -err;
  8003e7:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 0f             	cmp    $0xf,%eax
  8003ec:	7f 0b                	jg     8003f9 <vprintfmt+0x101>
  8003ee:	8b 3c 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edi
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	75 19                	jne    800412 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	50                   	push   %eax
  8003fa:	68 83 12 80 00       	push   $0x801283
  8003ff:	ff 75 0c             	pushl  0xc(%ebp)
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	e8 ef 01 00 00       	call   8005f9 <printfmt>
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	e9 f2 fe ff ff       	jmp    800304 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800412:	57                   	push   %edi
  800413:	68 8c 12 80 00       	push   $0x80128c
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 d6 01 00 00       	call   8005f9 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			break;
  800426:	e9 d9 fe ff ff       	jmp    800304 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042b:	8b 55 14             	mov    0x14(%ebp),%edx
  80042e:	8d 42 04             	lea    0x4(%edx),%eax
  800431:	89 45 14             	mov    %eax,0x14(%ebp)
  800434:	8b 3a                	mov    (%edx),%edi
  800436:	85 ff                	test   %edi,%edi
  800438:	75 05                	jne    80043f <vprintfmt+0x147>
				p = "(null)";
  80043a:	bf 8f 12 80 00       	mov    $0x80128f,%edi
			if (width > 0 && padc != '-')
  80043f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800443:	7e 3b                	jle    800480 <vprintfmt+0x188>
  800445:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800449:	74 35                	je     800480 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	56                   	push   %esi
  80044f:	57                   	push   %edi
  800450:	e8 58 02 00 00       	call   8006ad <strnlen>
  800455:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80045f:	7e 1f                	jle    800480 <vprintfmt+0x188>
  800461:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800465:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 0c             	pushl  0xc(%ebp)
  80046e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800471:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	ff 4d f0             	decl   -0x10(%ebp)
  80047a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80047e:	7f e8                	jg     800468 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800480:	0f be 0f             	movsbl (%edi),%ecx
  800483:	47                   	inc    %edi
  800484:	85 c9                	test   %ecx,%ecx
  800486:	74 44                	je     8004cc <vprintfmt+0x1d4>
  800488:	85 f6                	test   %esi,%esi
  80048a:	78 03                	js     80048f <vprintfmt+0x197>
  80048c:	4e                   	dec    %esi
  80048d:	78 3d                	js     8004cc <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800493:	74 18                	je     8004ad <vprintfmt+0x1b5>
  800495:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800498:	83 f8 5e             	cmp    $0x5e,%eax
  80049b:	76 10                	jbe    8004ad <vprintfmt+0x1b5>
					putch('?', putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	6a 3f                	push   $0x3f
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	eb 0d                	jmp    8004ba <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	51                   	push   %ecx
  8004b4:	ff 55 08             	call   *0x8(%ebp)
  8004b7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ba:	ff 4d f0             	decl   -0x10(%ebp)
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
  8004c0:	47                   	inc    %edi
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	74 07                	je     8004cc <vprintfmt+0x1d4>
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	78 c6                	js     80048f <vprintfmt+0x197>
  8004c9:	4e                   	dec    %esi
  8004ca:	79 c3                	jns    80048f <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004d0:	0f 8e 2e fe ff ff    	jle    800304 <vprintfmt+0xc>
				putch(' ', putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	6a 20                	push   $0x20
  8004de:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	ff 4d f0             	decl   -0x10(%ebp)
  8004e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004eb:	7f e9                	jg     8004d6 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  8004ed:	e9 12 fe ff ff       	jmp    800304 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004f2:	57                   	push   %edi
  8004f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f6:	50                   	push   %eax
  8004f7:	e8 c4 fd ff ff       	call   8002c0 <getint>
  8004fc:	89 c6                	mov    %eax,%esi
  8004fe:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800500:	83 c4 08             	add    $0x8,%esp
  800503:	85 d2                	test   %edx,%edx
  800505:	79 15                	jns    80051c <vprintfmt+0x224>
				putch('-', putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	6a 2d                	push   $0x2d
  80050f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800512:	f7 de                	neg    %esi
  800514:	83 d7 00             	adc    $0x0,%edi
  800517:	f7 df                	neg    %edi
  800519:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80051c:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800521:	eb 76                	jmp    800599 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800523:	57                   	push   %edi
  800524:	8d 45 14             	lea    0x14(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	e8 53 fd ff ff       	call   800280 <getuint>
  80052d:	89 c6                	mov    %eax,%esi
  80052f:	89 d7                	mov    %edx,%edi
			base = 10;
  800531:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800536:	83 c4 08             	add    $0x8,%esp
  800539:	eb 5e                	jmp    800599 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80053b:	57                   	push   %edi
  80053c:	8d 45 14             	lea    0x14(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	e8 3b fd ff ff       	call   800280 <getuint>
  800545:	89 c6                	mov    %eax,%esi
  800547:	89 d7                	mov    %edx,%edi
			base = 8;
  800549:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	eb 46                	jmp    800599 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	ff 75 0c             	pushl  0xc(%ebp)
  800559:	6a 30                	push   $0x30
  80055b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80055e:	83 c4 08             	add    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	6a 78                	push   $0x78
  800566:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800569:	8b 55 14             	mov    0x14(%ebp),%edx
  80056c:	8d 42 04             	lea    0x4(%edx),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	8b 32                	mov    (%edx),%esi
  800574:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800579:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb 16                	jmp    800599 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800583:	57                   	push   %edi
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	50                   	push   %eax
  800588:	e8 f3 fc ff ff       	call   800280 <getuint>
  80058d:	89 c6                	mov    %eax,%esi
  80058f:	89 d7                	mov    %edx,%edi
			base = 16;
  800591:	ba 10 00 00 00       	mov    $0x10,%edx
  800596:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800599:	83 ec 04             	sub    $0x4,%esp
  80059c:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005a0:	50                   	push   %eax
  8005a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8005a4:	52                   	push   %edx
  8005a5:	57                   	push   %edi
  8005a6:	56                   	push   %esi
  8005a7:	ff 75 0c             	pushl  0xc(%ebp)
  8005aa:	ff 75 08             	pushl  0x8(%ebp)
  8005ad:	e8 2e fc ff ff       	call   8001e0 <printnum>
			break;
  8005b2:	83 c4 20             	add    $0x20,%esp
  8005b5:	e9 4a fd ff ff       	jmp    800304 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	ff 75 0c             	pushl  0xc(%ebp)
  8005c0:	51                   	push   %ecx
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	e9 38 fd ff ff       	jmp    800304 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	ff 75 0c             	pushl  0xc(%ebp)
  8005d2:	6a 25                	push   $0x25
  8005d4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005df:	0f 84 1f fd ff ff    	je     800304 <vprintfmt+0xc>
  8005e5:	4b                   	dec    %ebx
  8005e6:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005ea:	75 f9                	jne    8005e5 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  8005ec:	e9 13 fd ff ff       	jmp    800304 <vprintfmt+0xc>
		}
	}
}
  8005f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f4:	5b                   	pop    %ebx
  8005f5:	5e                   	pop    %esi
  8005f6:	5f                   	pop    %edi
  8005f7:	c9                   	leave  
  8005f8:	c3                   	ret    

008005f9 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800602:	50                   	push   %eax
  800603:	ff 75 10             	pushl  0x10(%ebp)
  800606:	ff 75 0c             	pushl  0xc(%ebp)
  800609:	ff 75 08             	pushl  0x8(%ebp)
  80060c:	e8 e7 fc ff ff       	call   8002f8 <vprintfmt>
	va_end(ap);
}
  800611:	c9                   	leave  
  800612:	c3                   	ret    

00800613 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800613:	55                   	push   %ebp
  800614:	89 e5                	mov    %esp,%ebp
  800616:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800619:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80061c:	8b 0a                	mov    (%edx),%ecx
  80061e:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800621:	73 07                	jae    80062a <sprintputch+0x17>
		*b->buf++ = ch;
  800623:	8b 45 08             	mov    0x8(%ebp),%eax
  800626:	88 01                	mov    %al,(%ecx)
  800628:	ff 02                	incl   (%edx)
}
  80062a:	c9                   	leave  
  80062b:	c3                   	ret    

0080062c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062c:	55                   	push   %ebp
  80062d:	89 e5                	mov    %esp,%ebp
  80062f:	83 ec 18             	sub    $0x18,%esp
  800632:	8b 55 08             	mov    0x8(%ebp),%edx
  800635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800638:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80063b:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80063f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800642:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800649:	85 d2                	test   %edx,%edx
  80064b:	74 04                	je     800651 <vsnprintf+0x25>
  80064d:	85 c9                	test   %ecx,%ecx
  80064f:	7f 07                	jg     800658 <vsnprintf+0x2c>
		return -E_INVAL;
  800651:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800656:	eb 1d                	jmp    800675 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800658:	ff 75 14             	pushl  0x14(%ebp)
  80065b:	ff 75 10             	pushl  0x10(%ebp)
  80065e:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800661:	50                   	push   %eax
  800662:	68 13 06 80 00       	push   $0x800613
  800667:	e8 8c fc ff ff       	call   8002f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80066f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800680:	50                   	push   %eax
  800681:	ff 75 10             	pushl  0x10(%ebp)
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	e8 9d ff ff ff       	call   80062c <vsnprintf>
	va_end(ap);

	return rc;
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    
  800691:	00 00                	add    %al,(%eax)
	...

00800694 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069a:	b8 00 00 00 00       	mov    $0x0,%eax
  80069f:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a2:	74 07                	je     8006ab <strlen+0x17>
		n++;
  8006a4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a5:	42                   	inc    %edx
  8006a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a9:	75 f9                	jne    8006a4 <strlen+0x10>
		n++;
	return n;
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    

008006ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	74 0f                	je     8006ce <strnlen+0x21>
  8006bf:	80 39 00             	cmpb   $0x0,(%ecx)
  8006c2:	74 0a                	je     8006ce <strnlen+0x21>
		n++;
  8006c4:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c5:	41                   	inc    %ecx
  8006c6:	4a                   	dec    %edx
  8006c7:	74 05                	je     8006ce <strnlen+0x21>
  8006c9:	80 39 00             	cmpb   $0x0,(%ecx)
  8006cc:	75 f6                	jne    8006c4 <strnlen+0x17>
		n++;
	return n;
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006da:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006dc:	8a 02                	mov    (%edx),%al
  8006de:	42                   	inc    %edx
  8006df:	88 01                	mov    %al,(%ecx)
  8006e1:	41                   	inc    %ecx
  8006e2:	84 c0                	test   %al,%al
  8006e4:	75 f6                	jne    8006dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	5b                   	pop    %ebx
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	53                   	push   %ebx
  8006ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f2:	53                   	push   %ebx
  8006f3:	e8 9c ff ff ff       	call   800694 <strlen>
	strcpy(dst + len, src);
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006fe:	50                   	push   %eax
  8006ff:	e8 cc ff ff ff       	call   8006d0 <strcpy>
	return dst;
}
  800704:	89 d8                	mov    %ebx,%eax
  800706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	57                   	push   %edi
  80070f:	56                   	push   %esi
  800710:	53                   	push   %ebx
  800711:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
  800717:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80071a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80071c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800721:	39 f3                	cmp    %esi,%ebx
  800723:	73 10                	jae    800735 <strncpy+0x2a>
		*dst++ = *src;
  800725:	8a 02                	mov    (%edx),%al
  800727:	88 01                	mov    %al,(%ecx)
  800729:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80072a:	80 3a 01             	cmpb   $0x1,(%edx)
  80072d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800730:	43                   	inc    %ebx
  800731:	39 f3                	cmp    %esi,%ebx
  800733:	72 f0                	jb     800725 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800735:	89 f8                	mov    %edi,%eax
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	56                   	push   %esi
  800740:	53                   	push   %ebx
  800741:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800747:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80074a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80074c:	85 d2                	test   %edx,%edx
  80074e:	74 19                	je     800769 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800750:	4a                   	dec    %edx
  800751:	74 13                	je     800766 <strlcpy+0x2a>
  800753:	80 39 00             	cmpb   $0x0,(%ecx)
  800756:	74 0e                	je     800766 <strlcpy+0x2a>
  800758:	8a 01                	mov    (%ecx),%al
  80075a:	41                   	inc    %ecx
  80075b:	88 03                	mov    %al,(%ebx)
  80075d:	43                   	inc    %ebx
  80075e:	4a                   	dec    %edx
  80075f:	74 05                	je     800766 <strlcpy+0x2a>
  800761:	80 39 00             	cmpb   $0x0,(%ecx)
  800764:	75 f2                	jne    800758 <strlcpy+0x1c>
		*dst = '\0';
  800766:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800769:	89 d8                	mov    %ebx,%eax
  80076b:	29 f0                	sub    %esi,%eax
}
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	8b 55 08             	mov    0x8(%ebp),%edx
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80077a:	80 3a 00             	cmpb   $0x0,(%edx)
  80077d:	74 13                	je     800792 <strcmp+0x21>
  80077f:	8a 02                	mov    (%edx),%al
  800781:	3a 01                	cmp    (%ecx),%al
  800783:	75 0d                	jne    800792 <strcmp+0x21>
  800785:	42                   	inc    %edx
  800786:	41                   	inc    %ecx
  800787:	80 3a 00             	cmpb   $0x0,(%edx)
  80078a:	74 06                	je     800792 <strcmp+0x21>
  80078c:	8a 02                	mov    (%edx),%al
  80078e:	3a 01                	cmp    (%ecx),%al
  800790:	74 f3                	je     800785 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800792:	0f b6 02             	movzbl (%edx),%eax
  800795:	0f b6 11             	movzbl (%ecx),%edx
  800798:	29 d0                	sub    %edx,%eax
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007a9:	85 c9                	test   %ecx,%ecx
  8007ab:	74 1f                	je     8007cc <strncmp+0x30>
  8007ad:	80 3a 00             	cmpb   $0x0,(%edx)
  8007b0:	74 16                	je     8007c8 <strncmp+0x2c>
  8007b2:	8a 02                	mov    (%edx),%al
  8007b4:	3a 03                	cmp    (%ebx),%al
  8007b6:	75 10                	jne    8007c8 <strncmp+0x2c>
  8007b8:	42                   	inc    %edx
  8007b9:	43                   	inc    %ebx
  8007ba:	49                   	dec    %ecx
  8007bb:	74 0f                	je     8007cc <strncmp+0x30>
  8007bd:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c0:	74 06                	je     8007c8 <strncmp+0x2c>
  8007c2:	8a 02                	mov    (%edx),%al
  8007c4:	3a 03                	cmp    (%ebx),%al
  8007c6:	74 f0                	je     8007b8 <strncmp+0x1c>
	if (n == 0)
  8007c8:	85 c9                	test   %ecx,%ecx
  8007ca:	75 07                	jne    8007d3 <strncmp+0x37>
		return 0;
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 0a                	jmp    8007dd <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d3:	0f b6 12             	movzbl (%edx),%edx
  8007d6:	0f b6 03             	movzbl (%ebx),%eax
  8007d9:	29 c2                	sub    %eax,%edx
  8007db:	89 d0                	mov    %edx,%eax
}
  8007dd:	5b                   	pop    %ebx
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8007e9:	80 38 00             	cmpb   $0x0,(%eax)
  8007ec:	74 0a                	je     8007f8 <strchr+0x18>
		if (*s == c)
  8007ee:	38 10                	cmp    %dl,(%eax)
  8007f0:	74 0b                	je     8007fd <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007f2:	40                   	inc    %eax
  8007f3:	80 38 00             	cmpb   $0x0,(%eax)
  8007f6:	75 f6                	jne    8007ee <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800808:	80 38 00             	cmpb   $0x0,(%eax)
  80080b:	74 0a                	je     800817 <strfind+0x18>
		if (*s == c)
  80080d:	38 10                	cmp    %dl,(%eax)
  80080f:	74 06                	je     800817 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800811:	40                   	inc    %eax
  800812:	80 38 00             	cmpb   $0x0,(%eax)
  800815:	75 f6                	jne    80080d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800823:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800825:	85 c9                	test   %ecx,%ecx
  800827:	74 40                	je     800869 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800829:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082f:	75 30                	jne    800861 <memset+0x48>
  800831:	f6 c1 03             	test   $0x3,%cl
  800834:	75 2b                	jne    800861 <memset+0x48>
		c &= 0xFF;
  800836:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800840:	c1 e0 18             	shl    $0x18,%eax
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
  800846:	c1 e2 10             	shl    $0x10,%edx
  800849:	09 d0                	or     %edx,%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	c1 e2 08             	shl    $0x8,%edx
  800851:	09 d0                	or     %edx,%eax
  800853:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800856:	c1 e9 02             	shr    $0x2,%ecx
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	fc                   	cld    
  80085d:	f3 ab                	rep stos %eax,%es:(%edi)
  80085f:	eb 06                	jmp    800867 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
  800864:	fc                   	cld    
  800865:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800867:	89 f8                	mov    %edi,%eax
}
  800869:	5f                   	pop    %edi
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	57                   	push   %edi
  800870:	56                   	push   %esi
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800877:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80087a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80087c:	39 c6                	cmp    %eax,%esi
  80087e:	73 34                	jae    8008b4 <memmove+0x48>
  800880:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800883:	39 c2                	cmp    %eax,%edx
  800885:	76 2d                	jbe    8008b4 <memmove+0x48>
		s += n;
  800887:	89 d6                	mov    %edx,%esi
		d += n;
  800889:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088c:	f6 c2 03             	test   $0x3,%dl
  80088f:	75 1b                	jne    8008ac <memmove+0x40>
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 13                	jne    8008ac <memmove+0x40>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	75 0e                	jne    8008ac <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80089e:	83 ef 04             	sub    $0x4,%edi
  8008a1:	83 ee 04             	sub    $0x4,%esi
  8008a4:	c1 e9 02             	shr    $0x2,%ecx
  8008a7:	fd                   	std    
  8008a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008aa:	eb 05                	jmp    8008b1 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ac:	4f                   	dec    %edi
  8008ad:	4e                   	dec    %esi
  8008ae:	fd                   	std    
  8008af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b1:	fc                   	cld    
  8008b2:	eb 20                	jmp    8008d4 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ba:	75 15                	jne    8008d1 <memmove+0x65>
  8008bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c2:	75 0d                	jne    8008d1 <memmove+0x65>
  8008c4:	f6 c1 03             	test   $0x3,%cl
  8008c7:	75 08                	jne    8008d1 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  8008c9:	c1 e9 02             	shr    $0x2,%ecx
  8008cc:	fc                   	cld    
  8008cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cf:	eb 03                	jmp    8008d4 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d1:	fc                   	cld    
  8008d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d4:	5e                   	pop    %esi
  8008d5:	5f                   	pop    %edi
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	ff 75 0c             	pushl  0xc(%ebp)
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 83 ff ff ff       	call   80086c <memmove>
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  8008ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8008f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f8:	4a                   	dec    %edx
  8008f9:	83 fa ff             	cmp    $0xffffffff,%edx
  8008fc:	74 1a                	je     800918 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  8008fe:	8a 01                	mov    (%ecx),%al
  800900:	3a 03                	cmp    (%ebx),%al
  800902:	74 0c                	je     800910 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800904:	0f b6 d0             	movzbl %al,%edx
  800907:	0f b6 03             	movzbl (%ebx),%eax
  80090a:	29 c2                	sub    %eax,%edx
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	eb 0d                	jmp    80091d <memcmp+0x32>
		s1++, s2++;
  800910:	41                   	inc    %ecx
  800911:	43                   	inc    %ebx
  800912:	4a                   	dec    %edx
  800913:	83 fa ff             	cmp    $0xffffffff,%edx
  800916:	75 e6                	jne    8008fe <memcmp+0x13>
	}

	return 0;
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091d:	5b                   	pop    %ebx
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800929:	89 c2                	mov    %eax,%edx
  80092b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80092e:	39 d0                	cmp    %edx,%eax
  800930:	73 09                	jae    80093b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800932:	38 08                	cmp    %cl,(%eax)
  800934:	74 05                	je     80093b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800936:	40                   	inc    %eax
  800937:	39 d0                	cmp    %edx,%eax
  800939:	72 f7                	jb     800932 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 55 08             	mov    0x8(%ebp),%edx
  800946:	8b 75 0c             	mov    0xc(%ebp),%esi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  80094c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800951:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800956:	80 3a 20             	cmpb   $0x20,(%edx)
  800959:	74 05                	je     800960 <strtol+0x23>
  80095b:	80 3a 09             	cmpb   $0x9,(%edx)
  80095e:	75 0b                	jne    80096b <strtol+0x2e>
  800960:	42                   	inc    %edx
  800961:	80 3a 20             	cmpb   $0x20,(%edx)
  800964:	74 fa                	je     800960 <strtol+0x23>
  800966:	80 3a 09             	cmpb   $0x9,(%edx)
  800969:	74 f5                	je     800960 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80096b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80096e:	75 03                	jne    800973 <strtol+0x36>
		s++;
  800970:	42                   	inc    %edx
  800971:	eb 0b                	jmp    80097e <strtol+0x41>
	else if (*s == '-')
  800973:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800976:	75 06                	jne    80097e <strtol+0x41>
		s++, neg = 1;
  800978:	42                   	inc    %edx
  800979:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097e:	85 c9                	test   %ecx,%ecx
  800980:	74 05                	je     800987 <strtol+0x4a>
  800982:	83 f9 10             	cmp    $0x10,%ecx
  800985:	75 15                	jne    80099c <strtol+0x5f>
  800987:	80 3a 30             	cmpb   $0x30,(%edx)
  80098a:	75 10                	jne    80099c <strtol+0x5f>
  80098c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800990:	75 0a                	jne    80099c <strtol+0x5f>
		s += 2, base = 16;
  800992:	83 c2 02             	add    $0x2,%edx
  800995:	b9 10 00 00 00       	mov    $0x10,%ecx
  80099a:	eb 14                	jmp    8009b0 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  80099c:	85 c9                	test   %ecx,%ecx
  80099e:	75 10                	jne    8009b0 <strtol+0x73>
  8009a0:	80 3a 30             	cmpb   $0x30,(%edx)
  8009a3:	75 05                	jne    8009aa <strtol+0x6d>
		s++, base = 8;
  8009a5:	42                   	inc    %edx
  8009a6:	b1 08                	mov    $0x8,%cl
  8009a8:	eb 06                	jmp    8009b0 <strtol+0x73>
	else if (base == 0)
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	75 02                	jne    8009b0 <strtol+0x73>
		base = 10;
  8009ae:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b0:	8a 02                	mov    (%edx),%al
  8009b2:	83 e8 30             	sub    $0x30,%eax
  8009b5:	3c 09                	cmp    $0x9,%al
  8009b7:	77 08                	ja     8009c1 <strtol+0x84>
			dig = *s - '0';
  8009b9:	0f be 02             	movsbl (%edx),%eax
  8009bc:	83 e8 30             	sub    $0x30,%eax
  8009bf:	eb 20                	jmp    8009e1 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  8009c1:	8a 02                	mov    (%edx),%al
  8009c3:	83 e8 61             	sub    $0x61,%eax
  8009c6:	3c 19                	cmp    $0x19,%al
  8009c8:	77 08                	ja     8009d2 <strtol+0x95>
			dig = *s - 'a' + 10;
  8009ca:	0f be 02             	movsbl (%edx),%eax
  8009cd:	83 e8 57             	sub    $0x57,%eax
  8009d0:	eb 0f                	jmp    8009e1 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  8009d2:	8a 02                	mov    (%edx),%al
  8009d4:	83 e8 41             	sub    $0x41,%eax
  8009d7:	3c 19                	cmp    $0x19,%al
  8009d9:	77 12                	ja     8009ed <strtol+0xb0>
			dig = *s - 'A' + 10;
  8009db:	0f be 02             	movsbl (%edx),%eax
  8009de:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  8009e1:	39 c8                	cmp    %ecx,%eax
  8009e3:	7d 08                	jge    8009ed <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009e5:	42                   	inc    %edx
  8009e6:	0f af d9             	imul   %ecx,%ebx
  8009e9:	01 c3                	add    %eax,%ebx
  8009eb:	eb c3                	jmp    8009b0 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  8009ed:	85 f6                	test   %esi,%esi
  8009ef:	74 02                	je     8009f3 <strtol+0xb6>
		*endptr = (char *) s;
  8009f1:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8009f3:	89 d8                	mov    %ebx,%eax
  8009f5:	85 ff                	test   %edi,%edi
  8009f7:	74 02                	je     8009fb <strtol+0xbe>
  8009f9:	f7 d8                	neg    %eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	83 ec 04             	sub    $0x4,%esp
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	89 fb                	mov    %edi,%ebx
  800a18:	89 fe                	mov    %edi,%esi
  800a1a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a1c:	83 c4 04             	add    $0x4,%esp
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a34:	89 fa                	mov    %edi,%edx
  800a36:	89 f9                	mov    %edi,%ecx
  800a38:	89 fb                	mov    %edi,%ebx
  800a3a:	89 fe                	mov    %edi,%esi
  800a3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	83 ec 0c             	sub    $0xc,%esp
  800a4c:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a59:	89 f9                	mov    %edi,%ecx
  800a5b:	89 fb                	mov    %edi,%ebx
  800a5d:	89 fe                	mov    %edi,%esi
  800a5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a61:	85 c0                	test   %eax,%eax
  800a63:	7e 17                	jle    800a7c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a65:	83 ec 0c             	sub    $0xc,%esp
  800a68:	50                   	push   %eax
  800a69:	6a 03                	push   $0x3
  800a6b:	68 58 14 80 00       	push   $0x801458
  800a70:	6a 23                	push   $0x23
  800a72:	68 75 14 80 00       	push   $0x801475
  800a77:	e8 ac 03 00 00       	call   800e28 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a94:	89 fa                	mov    %edi,%edx
  800a96:	89 f9                	mov    %edi,%ecx
  800a98:	89 fb                	mov    %edi,%ebx
  800a9a:	89 fe                	mov    %edi,%esi
  800a9c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <sys_yield>:

void
sys_yield(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aae:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab3:	89 fa                	mov    %edi,%edx
  800ab5:	89 f9                	mov    %edi,%ecx
  800ab7:	89 fb                	mov    %edi,%ebx
  800ab9:	89 fe                	mov    %edi,%esi
  800abb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	89 fe                	mov    %edi,%esi
  800ae0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	7e 17                	jle    800afd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	50                   	push   %eax
  800aea:	6a 04                	push   $0x4
  800aec:	68 58 14 80 00       	push   $0x801458
  800af1:	6a 23                	push   $0x23
  800af3:	68 75 14 80 00       	push   $0x801475
  800af8:	e8 2b 03 00 00       	call   800e28 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b1a:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b1d:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b24:	85 c0                	test   %eax,%eax
  800b26:	7e 17                	jle    800b3f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	50                   	push   %eax
  800b2c:	6a 05                	push   $0x5
  800b2e:	68 58 14 80 00       	push   $0x801458
  800b33:	6a 23                	push   $0x23
  800b35:	68 75 14 80 00       	push   $0x801475
  800b3a:	e8 e9 02 00 00       	call   800e28 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800b56:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800b68:	7e 17                	jle    800b81 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	50                   	push   %eax
  800b6e:	6a 06                	push   $0x6
  800b70:	68 58 14 80 00       	push   $0x801458
  800b75:	6a 23                	push   $0x23
  800b77:	68 75 14 80 00       	push   $0x801475
  800b7c:	e8 a7 02 00 00       	call   800e28 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800b98:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800baa:	7e 17                	jle    800bc3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 08                	push   $0x8
  800bb2:	68 58 14 80 00       	push   $0x801458
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 75 14 80 00       	push   $0x801475
  800bbe:	e8 65 02 00 00       	call   800e28 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bda:	b8 09 00 00 00       	mov    $0x9,%eax
  800bdf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	89 fb                	mov    %edi,%ebx
  800be6:	89 fe                	mov    %edi,%esi
  800be8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 17                	jle    800c05 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 09                	push   $0x9
  800bf4:	68 58 14 80 00       	push   $0x801458
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 75 14 80 00       	push   $0x801475
  800c00:	e8 23 02 00 00       	call   800e28 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	89 fb                	mov    %edi,%ebx
  800c28:	89 fe                	mov    %edi,%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 0a                	push   $0xa
  800c36:	68 58 14 80 00       	push   $0x801458
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 75 14 80 00       	push   $0x801475
  800c42:	e8 e1 01 00 00       	call   800e28 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5e:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c7e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c83:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	89 f9                	mov    %edi,%ecx
  800c8a:	89 fb                	mov    %edi,%ebx
  800c8c:	89 fe                	mov    %edi,%esi
  800c8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7e 17                	jle    800cab <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 0d                	push   $0xd
  800c9a:	68 58 14 80 00       	push   $0x801458
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 75 14 80 00       	push   $0x801475
  800ca6:	e8 7d 01 00 00       	call   800e28 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    
	...

00800cb4 <duppage>:


/// dstenv: child's envid
void
duppage(envid_t dstenv, void *addr)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	8b 75 08             	mov    0x8(%ebp),%esi
  800cbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800cbf:	83 ec 04             	sub    $0x4,%esp
  800cc2:	6a 07                	push   $0x7
  800cc4:	53                   	push   %ebx
  800cc5:	56                   	push   %esi
  800cc6:	e8 f7 fd ff ff       	call   800ac2 <sys_page_alloc>
  800ccb:	83 c4 10             	add    $0x10,%esp
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	79 12                	jns    800ce4 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800cd2:	50                   	push   %eax
  800cd3:	68 83 14 80 00       	push   $0x801483
  800cd8:	6a 18                	push   $0x18
  800cda:	68 96 14 80 00       	push   $0x801496
  800cdf:	e8 44 01 00 00       	call   800e28 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	6a 07                	push   $0x7
  800ce9:	68 00 00 40 00       	push   $0x400000
  800cee:	6a 00                	push   $0x0
  800cf0:	53                   	push   %ebx
  800cf1:	56                   	push   %esi
  800cf2:	e8 0e fe ff ff       	call   800b05 <sys_page_map>
  800cf7:	83 c4 20             	add    $0x20,%esp
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	79 12                	jns    800d10 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  800cfe:	50                   	push   %eax
  800cff:	68 a1 14 80 00       	push   $0x8014a1
  800d04:	6a 1a                	push   $0x1a
  800d06:	68 96 14 80 00       	push   $0x801496
  800d0b:	e8 18 01 00 00       	call   800e28 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	68 00 10 00 00       	push   $0x1000
  800d18:	53                   	push   %ebx
  800d19:	68 00 00 40 00       	push   $0x400000
  800d1e:	e8 49 fb ff ff       	call   80086c <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800d23:	83 c4 08             	add    $0x8,%esp
  800d26:	68 00 00 40 00       	push   $0x400000
  800d2b:	6a 00                	push   $0x0
  800d2d:	e8 15 fe ff ff       	call   800b47 <sys_page_unmap>
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	85 c0                	test   %eax,%eax
  800d37:	79 12                	jns    800d4b <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  800d39:	50                   	push   %eax
  800d3a:	68 b2 14 80 00       	push   $0x8014b2
  800d3f:	6a 1d                	push   $0x1d
  800d41:	68 96 14 80 00       	push   $0x801496
  800d46:	e8 dd 00 00 00       	call   800e28 <_panic>
}
  800d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <fork>:

envid_t
fork(void)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	53                   	push   %ebx
  800d56:	83 ec 04             	sub    $0x4,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800d59:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  800d5e:	89 d0                	mov    %edx,%eax
  800d60:	cd 30                	int    $0x30
  800d62:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	79 12                	jns    800d7a <fork+0x28>
		panic("sys_exofork: %e", envid);
  800d68:	50                   	push   %eax
  800d69:	68 c5 14 80 00       	push   $0x8014c5
  800d6e:	6a 2f                	push   $0x2f
  800d70:	68 96 14 80 00       	push   $0x801496
  800d75:	e8 ae 00 00 00       	call   800e28 <_panic>
	if (envid == 0) {
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	75 25                	jne    800da3 <fork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800d7e:	e8 01 fd ff ff       	call   800a84 <sys_getenvid>
  800d83:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	c1 e2 05             	shl    $0x5,%edx
  800d8d:	29 c2                	sub    %eax,%edx
  800d8f:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800d96:	89 15 04 20 80 00    	mov    %edx,0x802004
		return 0;
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800da1:	eb 67                	jmp    800e0a <fork+0xb8>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800da3:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800daa:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800db1:	73 1f                	jae    800dd2 <fork+0x80>
		duppage(envid, addr);
  800db3:	83 ec 08             	sub    $0x8,%esp
  800db6:	ff 75 f8             	pushl  -0x8(%ebp)
  800db9:	53                   	push   %ebx
  800dba:	e8 f5 fe ff ff       	call   800cb4 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  800dc9:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800dd0:	72 e1                	jb     800db3 <fork+0x61>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800dd2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800dd5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dda:	83 ec 08             	sub    $0x8,%esp
  800ddd:	50                   	push   %eax
  800dde:	53                   	push   %ebx
  800ddf:	e8 d0 fe ff ff       	call   800cb4 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800de4:	83 c4 08             	add    $0x8,%esp
  800de7:	6a 02                	push   $0x2
  800de9:	53                   	push   %ebx
  800dea:	e8 9a fd ff ff       	call   800b89 <sys_env_set_status>
  800def:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  800df2:	89 da                	mov    %ebx,%edx

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800df4:	85 c0                	test   %eax,%eax
  800df6:	79 12                	jns    800e0a <fork+0xb8>
		panic("sys_env_set_status: %e", r);
  800df8:	50                   	push   %eax
  800df9:	68 d5 14 80 00       	push   $0x8014d5
  800dfe:	6a 44                	push   $0x44
  800e00:	68 96 14 80 00       	push   $0x801496
  800e05:	e8 1e 00 00 00       	call   800e28 <_panic>

	return envid;
}
  800e0a:	89 d0                	mov    %edx,%eax
  800e0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    

00800e11 <sfork>:

// Challenge!
int
sfork(void)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e17:	68 ec 14 80 00       	push   $0x8014ec
  800e1c:	6a 4d                	push   $0x4d
  800e1e:	68 96 14 80 00       	push   $0x801496
  800e23:	e8 00 00 00 00       	call   800e28 <_panic>

00800e28 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800e2f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e32:	ff 75 0c             	pushl  0xc(%ebp)
  800e35:	ff 75 08             	pushl  0x8(%ebp)
  800e38:	ff 35 00 20 80 00    	pushl  0x802000
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	e8 3e fc ff ff       	call   800a84 <sys_getenvid>
  800e46:	83 c4 08             	add    $0x8,%esp
  800e49:	50                   	push   %eax
  800e4a:	68 04 15 80 00       	push   $0x801504
  800e4f:	e8 78 f3 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e54:	83 c4 18             	add    $0x18,%esp
  800e57:	53                   	push   %ebx
  800e58:	ff 75 10             	pushl  0x10(%ebp)
  800e5b:	e8 1b f3 ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  800e60:	c7 04 24 54 11 80 00 	movl   $0x801154,(%esp)
  800e67:	e8 60 f3 ff ff       	call   8001cc <cprintf>

	// Cause a breakpoint exception
	while (1)
  800e6c:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800e6f:	cc                   	int3   
  800e70:	eb fd                	jmp    800e6f <_panic+0x47>
	...

00800e74 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	83 ec 14             	sub    $0x14,%esp
  800e7c:	8b 55 14             	mov    0x14(%ebp),%edx
  800e7f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e82:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e85:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e88:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e8a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800e90:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800e93:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e95:	75 11                	jne    800ea8 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800e97:	39 f8                	cmp    %edi,%eax
  800e99:	76 4d                	jbe    800ee8 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e9b:	89 fa                	mov    %edi,%edx
  800e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea0:	f7 75 e4             	divl   -0x1c(%ebp)
  800ea3:	89 c7                	mov    %eax,%edi
  800ea5:	eb 09                	jmp    800eb0 <__udivdi3+0x3c>
  800ea7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea8:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800eab:	76 17                	jbe    800ec4 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800ead:	31 ff                	xor    %edi,%edi
  800eaf:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800eb0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eb7:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eba:	83 c4 14             	add    $0x14,%esp
  800ebd:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ebe:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec0:	5f                   	pop    %edi
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ec4:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800ec8:	89 c7                	mov    %eax,%edi
  800eca:	83 f7 1f             	xor    $0x1f,%edi
  800ecd:	75 4d                	jne    800f1c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ecf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed2:	77 0a                	ja     800ede <__udivdi3+0x6a>
  800ed4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800ed7:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed9:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800edc:	72 d2                	jb     800eb0 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800ede:	bf 01 00 00 00       	mov    $0x1,%edi
  800ee3:	eb cb                	jmp    800eb0 <__udivdi3+0x3c>
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 0e                	jne    800efd <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eef:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef4:	31 c9                	xor    %ecx,%ecx
  800ef6:	31 d2                	xor    %edx,%edx
  800ef8:	f7 f1                	div    %ecx
  800efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800efd:	89 f0                	mov    %esi,%eax
  800eff:	31 d2                	xor    %edx,%edx
  800f01:	f7 75 e4             	divl   -0x1c(%ebp)
  800f04:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0a:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f10:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f13:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f15:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f16:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f18:	5f                   	pop    %edi
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    
  800f1b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f21:	29 f8                	sub    %edi,%eax
  800f23:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800f26:	89 f9                	mov    %edi,%ecx
  800f28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f2b:	d3 e2                	shl    %cl,%edx
  800f2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f30:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800f33:	d3 e8                	shr    %cl,%eax
  800f35:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800f37:	89 f9                	mov    %edi,%ecx
  800f39:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f3c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f3f:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800f46:	89 f9                	mov    %edi,%ecx
  800f48:	d3 e6                	shl    %cl,%esi
  800f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4d:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800f50:	d3 e8                	shr    %cl,%eax
  800f52:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800f54:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f56:	89 f0                	mov    %esi,%eax
  800f58:	f7 75 f4             	divl   -0xc(%ebp)
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f5f:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f65:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f67:	39 f2                	cmp    %esi,%edx
  800f69:	77 0f                	ja     800f7a <__udivdi3+0x106>
  800f6b:	0f 85 3f ff ff ff    	jne    800eb0 <__udivdi3+0x3c>
  800f71:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f74:	0f 86 36 ff ff ff    	jbe    800eb0 <__udivdi3+0x3c>
		{
		  q0--;
  800f7a:	4f                   	dec    %edi
  800f7b:	e9 30 ff ff ff       	jmp    800eb0 <__udivdi3+0x3c>

00800f80 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	83 ec 30             	sub    $0x30,%esp
  800f88:	8b 55 14             	mov    0x14(%ebp),%edx
  800f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800f8e:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800f90:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800f93:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800f95:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f9b:	85 ff                	test   %edi,%edi
  800f9d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800fa4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800fab:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800fae:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800fb1:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fb4:	75 3e                	jne    800ff4 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800fb6:	39 d6                	cmp    %edx,%esi
  800fb8:	0f 86 a2 00 00 00    	jbe    801060 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fbe:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800fc0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fc3:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fc5:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800fc8:	74 1b                	je     800fe5 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800fca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fcd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800fd0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fda:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fdd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800fe0:	89 10                	mov    %edx,(%eax)
  800fe2:	89 48 04             	mov    %ecx,0x4(%eax)
  800fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800feb:	83 c4 30             	add    $0x30,%esp
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    
  800ff2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ff4:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800ff7:	76 1f                	jbe    801018 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800ffc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800fff:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  801002:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801005:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801008:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80100b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80100e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801011:	83 c4 30             	add    $0x30,%esp
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	c9                   	leave  
  801017:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801018:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80101b:	83 f0 1f             	xor    $0x1f,%eax
  80101e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801021:	75 61                	jne    801084 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801023:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  801026:	77 05                	ja     80102d <__umoddi3+0xad>
  801028:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  80102b:	72 10                	jb     80103d <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80102d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801030:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801033:	29 f0                	sub    %esi,%eax
  801035:	19 fa                	sbb    %edi,%edx
  801037:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80103a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  80103d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801040:	85 d2                	test   %edx,%edx
  801042:	74 a1                	je     800fe5 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801044:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  801047:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80104a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  80104d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801050:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801053:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801056:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801059:	89 01                	mov    %eax,(%ecx)
  80105b:	89 51 04             	mov    %edx,0x4(%ecx)
  80105e:	eb 85                	jmp    800fe5 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801060:	85 f6                	test   %esi,%esi
  801062:	75 0b                	jne    80106f <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801064:	b8 01 00 00 00       	mov    $0x1,%eax
  801069:	31 d2                	xor    %edx,%edx
  80106b:	f7 f6                	div    %esi
  80106d:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80106f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801072:	89 fa                	mov    %edi,%edx
  801074:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801076:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801079:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80107c:	f7 f6                	div    %esi
  80107e:	e9 3d ff ff ff       	jmp    800fc0 <__umoddi3+0x40>
  801083:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801084:	b8 20 00 00 00       	mov    $0x20,%eax
  801089:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  80108c:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  80108f:	89 fa                	mov    %edi,%edx
  801091:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801094:	d3 e2                	shl    %cl,%edx
  801096:	89 f0                	mov    %esi,%eax
  801098:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80109b:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  80109d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8010a0:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010a2:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8010a4:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8010a7:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010aa:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8010ac:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8010ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8010b1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8010b4:	d3 e0                	shl    %cl,%eax
  8010b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8010b9:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8010bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010bf:	d3 e8                	shr    %cl,%eax
  8010c1:	0b 45 cc             	or     -0x34(%ebp),%eax
  8010c4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  8010c7:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8010ca:	f7 f7                	div    %edi
  8010cc:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8010cf:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8010d2:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010d4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8010d7:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010da:	77 0a                	ja     8010e6 <__umoddi3+0x166>
  8010dc:	75 12                	jne    8010f0 <__umoddi3+0x170>
  8010de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010e1:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  8010e4:	76 0a                	jbe    8010f0 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8010e6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8010e9:	29 f1                	sub    %esi,%ecx
  8010eb:	19 fa                	sbb    %edi,%edx
  8010ed:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  8010f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	0f 84 ea fe ff ff    	je     800fe5 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8010fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801101:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801104:	19 d1                	sbb    %edx,%ecx
  801106:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801109:	89 ca                	mov    %ecx,%edx
  80110b:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80110e:	d3 e2                	shl    %cl,%edx
  801110:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801113:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801116:	d3 e8                	shr    %cl,%eax
  801118:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80111a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80111d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80111f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801122:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801125:	e9 ad fe ff ff       	jmp    800fd7 <__umoddi3+0x57>
