
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003f:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = 0; i < n; i++)
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	39 d9                	cmp    %ebx,%ecx
  80004b:	7d 0e                	jge    80005b <sum+0x27>
		tot ^= i * s[i];
  80004d:	0f be 04 16          	movsbl (%esi,%edx,1),%eax
  800051:	0f af c2             	imul   %edx,%eax
  800054:	31 c1                	xor    %eax,%ecx

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800056:	42                   	inc    %edx
  800057:	39 da                	cmp    %ebx,%edx
  800059:	7c f2                	jl     80004d <sum+0x19>
		tot ^= i * s[i];
	return tot;
}
  80005b:	89 c8                	mov    %ecx,%eax
  80005d:	5b                   	pop    %ebx
  80005e:	5e                   	pop    %esi
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800070:	68 60 10 80 00       	push   $0x801060
  800075:	e8 ea 01 00 00       	call   800264 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 20 80 00       	push   $0x802000
  800084:	e8 ab ff ff ff       	call   800034 <sum>
  800089:	83 c4 18             	add    $0x18,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4a>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 c0 10 80 00       	push   $0x8010c0
  8000a1:	e8 be 01 00 00       	call   800264 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5a>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 6f 10 80 00       	push   $0x80106f
  8000b3:	e8 ac 01 00 00       	call   800264 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	68 70 17 00 00       	push   $0x1770
  8000c0:	68 80 37 80 00       	push   $0x803780
  8000c5:	e8 6a ff ff ff       	call   800034 <sum>
  8000ca:	83 c4 08             	add    $0x8,%esp
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 13                	je     8000e4 <umain+0x83>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	50                   	push   %eax
  8000d5:	68 fc 10 80 00       	push   $0x8010fc
  8000da:	e8 85 01 00 00       	call   800264 <cprintf>
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	eb 10                	jmp    8000f4 <umain+0x93>
	else
		cprintf("init: bss seems okay\n");
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	68 86 10 80 00       	push   $0x801086
  8000ec:	e8 73 01 00 00       	call   800264 <cprintf>
  8000f1:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f4:	83 ec 08             	sub    $0x8,%esp
  8000f7:	68 9c 10 80 00       	push   $0x80109c
  8000fc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800102:	50                   	push   %eax
  800103:	e8 7b 06 00 00       	call   800783 <strcat>
	for (i = 0; i < argc; i++) {
  800108:	bb 00 00 00 00       	mov    $0x0,%ebx
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	39 fb                	cmp    %edi,%ebx
  800112:	7d 39                	jge    80014d <umain+0xec>
  800114:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
		strcat(args, " '");
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	68 a8 10 80 00       	push   $0x8010a8
  800122:	56                   	push   %esi
  800123:	e8 5b 06 00 00       	call   800783 <strcat>
		strcat(args, argv[i]);
  800128:	83 c4 08             	add    $0x8,%esp
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	ff 34 98             	pushl  (%eax,%ebx,4)
  800131:	56                   	push   %esi
  800132:	e8 4c 06 00 00       	call   800783 <strcat>
		strcat(args, "'");
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	68 a9 10 80 00       	push   $0x8010a9
  80013f:	56                   	push   %esi
  800140:	e8 3e 06 00 00       	call   800783 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800145:	83 c4 10             	add    $0x10,%esp
  800148:	43                   	inc    %ebx
  800149:	39 fb                	cmp    %edi,%ebx
  80014b:	7c cd                	jl     80011a <umain+0xb9>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014d:	83 ec 08             	sub    $0x8,%esp
  800150:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800156:	50                   	push   %eax
  800157:	68 ab 10 80 00       	push   $0x8010ab
  80015c:	e8 03 01 00 00       	call   800264 <cprintf>

	cprintf("init: exiting\n");
  800161:	c7 04 24 af 10 80 00 	movl   $0x8010af,(%esp)
  800168:	e8 f7 00 00 00       	call   800264 <cprintf>
}
  80016d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	c9                   	leave  
  800174:	c3                   	ret    
  800175:	00 00                	add    %al,(%eax)
	...

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 75 08             	mov    0x8(%ebp),%esi
  800180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800183:	e8 94 09 00 00       	call   800b1c <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	89 c2                	mov    %eax,%edx
  80018f:	c1 e2 05             	shl    $0x5,%edx
  800192:	29 c2                	sub    %eax,%edx
  800194:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80019b:	89 15 f0 4e 80 00    	mov    %edx,0x804ef0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a1:	85 f6                	test   %esi,%esi
  8001a3:	7e 07                	jle    8001ac <libmain+0x34>
		binaryname = argv[0];
  8001a5:	8b 03                	mov    (%ebx),%eax
  8001a7:	a3 70 37 80 00       	mov    %eax,0x803770

	// call user main routine
	umain(argc, argv);
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	53                   	push   %ebx
  8001b0:	56                   	push   %esi
  8001b1:	e8 ab fe ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8001b6:	e8 09 00 00 00       	call   8001c4 <exit>
}
  8001bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
	...

008001c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8001ca:	6a 00                	push   $0x0
  8001cc:	e8 0a 09 00 00       	call   800adb <sys_env_destroy>
}
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    
	...

008001d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001de:	8b 03                	mov    (%ebx),%eax
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8001e7:	40                   	inc    %eax
  8001e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ef:	75 1a                	jne    80020b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	68 ff 00 00 00       	push   $0xff
  8001f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 96 08 00 00       	call   800a98 <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800208:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020b:	ff 43 04             	incl   0x4(%ebx)
}
  80020e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	ff 75 0c             	pushl  0xc(%ebp)
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80023c:	50                   	push   %eax
  80023d:	68 d4 01 80 00       	push   $0x8001d4
  800242:	e8 49 01 00 00       	call   800390 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	83 c4 08             	add    $0x8,%esp
  80024a:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800250:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	e8 3c 08 00 00       	call   800a98 <sys_cputs>

	return b.cnt;
  80025c:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	50                   	push   %eax
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 9d ff ff ff       	call   800213 <vcprintf>
	va_end(ap);

	return cnt;
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	8b 75 10             	mov    0x10(%ebp),%esi
  800284:	8b 7d 14             	mov    0x14(%ebp),%edi
  800287:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028a:	8b 45 18             	mov    0x18(%ebp),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	39 fa                	cmp    %edi,%edx
  800294:	77 39                	ja     8002cf <printnum+0x57>
  800296:	72 04                	jb     80029c <printnum+0x24>
  800298:	39 f0                	cmp    %esi,%eax
  80029a:	77 33                	ja     8002cf <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	ff 75 20             	pushl  0x20(%ebp)
  8002a2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 18             	pushl  0x18(%ebp)
  8002a9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	52                   	push   %edx
  8002b2:	50                   	push   %eax
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	e8 de 0a 00 00       	call   800d98 <__udivdi3>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	52                   	push   %edx
  8002be:	50                   	push   %eax
  8002bf:	ff 75 0c             	pushl  0xc(%ebp)
  8002c2:	ff 75 08             	pushl  0x8(%ebp)
  8002c5:	e8 ae ff ff ff       	call   800278 <printnum>
  8002ca:	83 c4 20             	add    $0x20,%esp
  8002cd:	eb 19                	jmp    8002e8 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cf:	4b                   	dec    %ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7e 14                	jle    8002e8 <printnum+0x70>
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	ff 75 0c             	pushl  0xc(%ebp)
  8002da:	ff 75 20             	pushl  0x20(%ebp)
  8002dd:	ff 55 08             	call   *0x8(%ebp)
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	4b                   	dec    %ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f ec                	jg     8002d4 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ee:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f6:	83 ec 04             	sub    $0x4,%esp
  8002f9:	52                   	push   %edx
  8002fa:	50                   	push   %eax
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	e8 a2 0b 00 00       	call   800ea4 <__umoddi3>
  800302:	83 c4 14             	add    $0x14,%esp
  800305:	0f be 80 47 12 80 00 	movsbl 0x801247(%eax),%eax
  80030c:	50                   	push   %eax
  80030d:	ff 55 08             	call   *0x8(%ebp)
}
  800310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800321:	83 f8 01             	cmp    $0x1,%eax
  800324:	7e 0e                	jle    800334 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  800326:	8b 11                	mov    (%ecx),%edx
  800328:	8d 42 08             	lea    0x8(%edx),%eax
  80032b:	89 01                	mov    %eax,(%ecx)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	8b 52 04             	mov    0x4(%edx),%edx
  800332:	eb 22                	jmp    800356 <getuint+0x3e>
	else if (lflag)
  800334:	85 c0                	test   %eax,%eax
  800336:	74 10                	je     800348 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800338:	8b 11                	mov    (%ecx),%edx
  80033a:	8d 42 04             	lea    0x4(%edx),%eax
  80033d:	89 01                	mov    %eax,(%ecx)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
  800346:	eb 0e                	jmp    800356 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800348:	8b 11                	mov    (%ecx),%edx
  80034a:	8d 42 04             	lea    0x4(%edx),%eax
  80034d:	89 01                	mov    %eax,(%ecx)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800361:	83 f8 01             	cmp    $0x1,%eax
  800364:	7e 0e                	jle    800374 <getint+0x1c>
		return va_arg(*ap, long long);
  800366:	8b 11                	mov    (%ecx),%edx
  800368:	8d 42 08             	lea    0x8(%edx),%eax
  80036b:	89 01                	mov    %eax,(%ecx)
  80036d:	8b 02                	mov    (%edx),%eax
  80036f:	8b 52 04             	mov    0x4(%edx),%edx
  800372:	eb 1a                	jmp    80038e <getint+0x36>
	else if (lflag)
  800374:	85 c0                	test   %eax,%eax
  800376:	74 0c                	je     800384 <getint+0x2c>
		return va_arg(*ap, long);
  800378:	8b 01                	mov    (%ecx),%eax
  80037a:	8d 50 04             	lea    0x4(%eax),%edx
  80037d:	89 11                	mov    %edx,(%ecx)
  80037f:	8b 00                	mov    (%eax),%eax
  800381:	99                   	cltd   
  800382:	eb 0a                	jmp    80038e <getint+0x36>
	else
		return va_arg(*ap, int);
  800384:	8b 01                	mov    (%ecx),%eax
  800386:	8d 50 04             	lea    0x4(%eax),%edx
  800389:	89 11                	mov    %edx,(%ecx)
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	99                   	cltd   
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 1c             	sub    $0x1c,%esp
  800399:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  80039c:	0f b6 0b             	movzbl (%ebx),%ecx
  80039f:	43                   	inc    %ebx
  8003a0:	83 f9 25             	cmp    $0x25,%ecx
  8003a3:	74 1e                	je     8003c3 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a5:	85 c9                	test   %ecx,%ecx
  8003a7:	0f 84 dc 02 00 00    	je     800689 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	51                   	push   %ecx
  8003b4:	ff 55 08             	call   *0x8(%ebp)
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	0f b6 0b             	movzbl (%ebx),%ecx
  8003bd:	43                   	inc    %ebx
  8003be:	83 f9 25             	cmp    $0x25,%ecx
  8003c1:	75 e2                	jne    8003a5 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8003c3:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8003c7:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8003ce:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8003d3:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8003d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	0f b6 0b             	movzbl (%ebx),%ecx
  8003e2:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003e5:	43                   	inc    %ebx
  8003e6:	83 f8 55             	cmp    $0x55,%eax
  8003e9:	0f 87 75 02 00 00    	ja     800664 <vprintfmt+0x2d4>
  8003ef:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f6:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8003fa:	eb e3                	jmp    8003df <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800400:	eb dd                	jmp    8003df <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800402:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  800407:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  80040a:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  80040e:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800411:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800414:	83 f8 09             	cmp    $0x9,%eax
  800417:	77 28                	ja     800441 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800419:	43                   	inc    %ebx
  80041a:	eb eb                	jmp    800407 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041c:	8b 55 14             	mov    0x14(%ebp),%edx
  80041f:	8d 42 04             	lea    0x4(%edx),%eax
  800422:	89 45 14             	mov    %eax,0x14(%ebp)
  800425:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  800427:	eb 18                	jmp    800441 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800429:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80042d:	79 b0                	jns    8003df <vprintfmt+0x4f>
				width = 0;
  80042f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800436:	eb a7                	jmp    8003df <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800438:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80043f:	eb 9e                	jmp    8003df <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800441:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800445:	79 98                	jns    8003df <vprintfmt+0x4f>
				width = precision, precision = -1;
  800447:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80044a:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80044f:	eb 8e                	jmp    8003df <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800451:	47                   	inc    %edi
			goto reswitch;
  800452:	eb 8b                	jmp    8003df <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	ff 75 0c             	pushl  0xc(%ebp)
  80045a:	8b 55 14             	mov    0x14(%ebp),%edx
  80045d:	8d 42 04             	lea    0x4(%edx),%eax
  800460:	89 45 14             	mov    %eax,0x14(%ebp)
  800463:	ff 32                	pushl  (%edx)
  800465:	ff 55 08             	call   *0x8(%ebp)
			break;
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	e9 2c ff ff ff       	jmp    80039c <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	8b 55 14             	mov    0x14(%ebp),%edx
  800473:	8d 42 04             	lea    0x4(%edx),%eax
  800476:	89 45 14             	mov    %eax,0x14(%ebp)
  800479:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  80047b:	85 c0                	test   %eax,%eax
  80047d:	79 02                	jns    800481 <vprintfmt+0xf1>
				err = -err;
  80047f:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	83 f8 0f             	cmp    $0xf,%eax
  800484:	7f 0b                	jg     800491 <vprintfmt+0x101>
  800486:	8b 3c 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edi
  80048d:	85 ff                	test   %edi,%edi
  80048f:	75 19                	jne    8004aa <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800491:	50                   	push   %eax
  800492:	68 58 12 80 00       	push   $0x801258
  800497:	ff 75 0c             	pushl  0xc(%ebp)
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 ef 01 00 00       	call   800691 <printfmt>
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	e9 f2 fe ff ff       	jmp    80039c <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8004aa:	57                   	push   %edi
  8004ab:	68 61 12 80 00       	push   $0x801261
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	ff 75 08             	pushl  0x8(%ebp)
  8004b6:	e8 d6 01 00 00       	call   800691 <printfmt>
  8004bb:	83 c4 10             	add    $0x10,%esp
			break;
  8004be:	e9 d9 fe ff ff       	jmp    80039c <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c3:	8b 55 14             	mov    0x14(%ebp),%edx
  8004c6:	8d 42 04             	lea    0x4(%edx),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cc:	8b 3a                	mov    (%edx),%edi
  8004ce:	85 ff                	test   %edi,%edi
  8004d0:	75 05                	jne    8004d7 <vprintfmt+0x147>
				p = "(null)";
  8004d2:	bf 64 12 80 00       	mov    $0x801264,%edi
			if (width > 0 && padc != '-')
  8004d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004db:	7e 3b                	jle    800518 <vprintfmt+0x188>
  8004dd:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8004e1:	74 35                	je     800518 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	56                   	push   %esi
  8004e7:	57                   	push   %edi
  8004e8:	e8 58 02 00 00       	call   800745 <strnlen>
  8004ed:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004f7:	7e 1f                	jle    800518 <vprintfmt+0x188>
  8004f9:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8004fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 0c             	pushl  0xc(%ebp)
  800506:	ff 75 e4             	pushl  -0x1c(%ebp)
  800509:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	ff 4d f0             	decl   -0x10(%ebp)
  800512:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800516:	7f e8                	jg     800500 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800518:	0f be 0f             	movsbl (%edi),%ecx
  80051b:	47                   	inc    %edi
  80051c:	85 c9                	test   %ecx,%ecx
  80051e:	74 44                	je     800564 <vprintfmt+0x1d4>
  800520:	85 f6                	test   %esi,%esi
  800522:	78 03                	js     800527 <vprintfmt+0x197>
  800524:	4e                   	dec    %esi
  800525:	78 3d                	js     800564 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  800527:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80052b:	74 18                	je     800545 <vprintfmt+0x1b5>
  80052d:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800530:	83 f8 5e             	cmp    $0x5e,%eax
  800533:	76 10                	jbe    800545 <vprintfmt+0x1b5>
					putch('?', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	6a 3f                	push   $0x3f
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 0d                	jmp    800552 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	ff 75 0c             	pushl  0xc(%ebp)
  80054b:	51                   	push   %ecx
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	ff 4d f0             	decl   -0x10(%ebp)
  800555:	0f be 0f             	movsbl (%edi),%ecx
  800558:	47                   	inc    %edi
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 07                	je     800564 <vprintfmt+0x1d4>
  80055d:	85 f6                	test   %esi,%esi
  80055f:	78 c6                	js     800527 <vprintfmt+0x197>
  800561:	4e                   	dec    %esi
  800562:	79 c3                	jns    800527 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800564:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800568:	0f 8e 2e fe ff ff    	jle    80039c <vprintfmt+0xc>
				putch(' ', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 20                	push   $0x20
  800576:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	ff 4d f0             	decl   -0x10(%ebp)
  80057f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800583:	7f e9                	jg     80056e <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800585:	e9 12 fe ff ff       	jmp    80039c <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058a:	57                   	push   %edi
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	50                   	push   %eax
  80058f:	e8 c4 fd ff ff       	call   800358 <getint>
  800594:	89 c6                	mov    %eax,%esi
  800596:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	85 d2                	test   %edx,%edx
  80059d:	79 15                	jns    8005b4 <vprintfmt+0x224>
				putch('-', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	ff 75 0c             	pushl  0xc(%ebp)
  8005a5:	6a 2d                	push   $0x2d
  8005a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005aa:	f7 de                	neg    %esi
  8005ac:	83 d7 00             	adc    $0x0,%edi
  8005af:	f7 df                	neg    %edi
  8005b1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b4:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8005b9:	eb 76                	jmp    800631 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bb:	57                   	push   %edi
  8005bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bf:	50                   	push   %eax
  8005c0:	e8 53 fd ff ff       	call   800318 <getuint>
  8005c5:	89 c6                	mov    %eax,%esi
  8005c7:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c9:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8005ce:	83 c4 08             	add    $0x8,%esp
  8005d1:	eb 5e                	jmp    800631 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d3:	57                   	push   %edi
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	50                   	push   %eax
  8005d8:	e8 3b fd ff ff       	call   800318 <getuint>
  8005dd:	89 c6                	mov    %eax,%esi
  8005df:	89 d7                	mov    %edx,%edi
			base = 8;
  8005e1:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	eb 46                	jmp    800631 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 30                	push   $0x30
  8005f3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f6:	83 c4 08             	add    $0x8,%esp
  8005f9:	ff 75 0c             	pushl  0xc(%ebp)
  8005fc:	6a 78                	push   $0x78
  8005fe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800601:	8b 55 14             	mov    0x14(%ebp),%edx
  800604:	8d 42 04             	lea    0x4(%edx),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
  80060a:	8b 32                	mov    (%edx),%esi
  80060c:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800611:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb 16                	jmp    800631 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061b:	57                   	push   %edi
  80061c:	8d 45 14             	lea    0x14(%ebp),%eax
  80061f:	50                   	push   %eax
  800620:	e8 f3 fc ff ff       	call   800318 <getuint>
  800625:	89 c6                	mov    %eax,%esi
  800627:	89 d7                	mov    %edx,%edi
			base = 16;
  800629:	ba 10 00 00 00       	mov    $0x10,%edx
  80062e:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800631:	83 ec 04             	sub    $0x4,%esp
  800634:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	ff 75 f0             	pushl  -0x10(%ebp)
  80063c:	52                   	push   %edx
  80063d:	57                   	push   %edi
  80063e:	56                   	push   %esi
  80063f:	ff 75 0c             	pushl  0xc(%ebp)
  800642:	ff 75 08             	pushl  0x8(%ebp)
  800645:	e8 2e fc ff ff       	call   800278 <printnum>
			break;
  80064a:	83 c4 20             	add    $0x20,%esp
  80064d:	e9 4a fd ff ff       	jmp    80039c <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	ff 75 0c             	pushl  0xc(%ebp)
  800658:	51                   	push   %ecx
  800659:	ff 55 08             	call   *0x8(%ebp)
			break;
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	e9 38 fd ff ff       	jmp    80039c <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	ff 75 0c             	pushl  0xc(%ebp)
  80066a:	6a 25                	push   $0x25
  80066c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066f:	4b                   	dec    %ebx
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800677:	0f 84 1f fd ff ff    	je     80039c <vprintfmt+0xc>
  80067d:	4b                   	dec    %ebx
  80067e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800682:	75 f9                	jne    80067d <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800684:	e9 13 fd ff ff       	jmp    80039c <vprintfmt+0xc>
		}
	}
}
  800689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068c:	5b                   	pop    %ebx
  80068d:	5e                   	pop    %esi
  80068e:	5f                   	pop    %edi
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80069a:	50                   	push   %eax
  80069b:	ff 75 10             	pushl  0x10(%ebp)
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	e8 e7 fc ff ff       	call   800390 <vprintfmt>
	va_end(ap);
}
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8006b1:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8006b4:	8b 0a                	mov    (%edx),%ecx
  8006b6:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8006b9:	73 07                	jae    8006c2 <sprintputch+0x17>
		*b->buf++ = ch;
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	88 01                	mov    %al,(%ecx)
  8006c0:	ff 02                	incl   (%edx)
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 18             	sub    $0x18,%esp
  8006ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006d3:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8006e1:	85 d2                	test   %edx,%edx
  8006e3:	74 04                	je     8006e9 <vsnprintf+0x25>
  8006e5:	85 c9                	test   %ecx,%ecx
  8006e7:	7f 07                	jg     8006f0 <vsnprintf+0x2c>
		return -E_INVAL;
  8006e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ee:	eb 1d                	jmp    80070d <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	ff 75 14             	pushl  0x14(%ebp)
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	68 ab 06 80 00       	push   $0x8006ab
  8006ff:	e8 8c fc ff ff       	call   800390 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800718:	50                   	push   %eax
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	ff 75 0c             	pushl  0xc(%ebp)
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 9d ff ff ff       	call   8006c4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800727:	c9                   	leave  
  800728:	c3                   	ret    
  800729:	00 00                	add    %al,(%eax)
	...

0080072c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	80 3a 00             	cmpb   $0x0,(%edx)
  80073a:	74 07                	je     800743 <strlen+0x17>
		n++;
  80073c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073d:	42                   	inc    %edx
  80073e:	80 3a 00             	cmpb   $0x0,(%edx)
  800741:	75 f9                	jne    80073c <strlen+0x10>
		n++;
	return n;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	85 d2                	test   %edx,%edx
  800755:	74 0f                	je     800766 <strnlen+0x21>
  800757:	80 39 00             	cmpb   $0x0,(%ecx)
  80075a:	74 0a                	je     800766 <strnlen+0x21>
		n++;
  80075c:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	41                   	inc    %ecx
  80075e:	4a                   	dec    %edx
  80075f:	74 05                	je     800766 <strnlen+0x21>
  800761:	80 39 00             	cmpb   $0x0,(%ecx)
  800764:	75 f6                	jne    80075c <strnlen+0x17>
		n++;
	return n;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  800772:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800774:	8a 02                	mov    (%edx),%al
  800776:	42                   	inc    %edx
  800777:	88 01                	mov    %al,(%ecx)
  800779:	41                   	inc    %ecx
  80077a:	84 c0                	test   %al,%al
  80077c:	75 f6                	jne    800774 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077e:	89 d8                	mov    %ebx,%eax
  800780:	5b                   	pop    %ebx
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	53                   	push   %ebx
  80078b:	e8 9c ff ff ff       	call   80072c <strlen>
	strcpy(dst + len, src);
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800796:	50                   	push   %eax
  800797:	e8 cc ff ff ff       	call   800768 <strcpy>
	return dst;
}
  80079c:	89 d8                	mov    %ebx,%eax
  80079e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	57                   	push   %edi
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007af:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8007b2:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8007b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b9:	39 f3                	cmp    %esi,%ebx
  8007bb:	73 10                	jae    8007cd <strncpy+0x2a>
		*dst++ = *src;
  8007bd:	8a 02                	mov    (%edx),%al
  8007bf:	88 01                	mov    %al,(%ecx)
  8007c1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	43                   	inc    %ebx
  8007c9:	39 f3                	cmp    %esi,%ebx
  8007cb:	72 f0                	jb     8007bd <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007cd:	89 f8                	mov    %edi,%eax
  8007cf:	5b                   	pop    %ebx
  8007d0:	5e                   	pop    %esi
  8007d1:	5f                   	pop    %edi
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007e2:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007e4:	85 d2                	test   %edx,%edx
  8007e6:	74 19                	je     800801 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e8:	4a                   	dec    %edx
  8007e9:	74 13                	je     8007fe <strlcpy+0x2a>
  8007eb:	80 39 00             	cmpb   $0x0,(%ecx)
  8007ee:	74 0e                	je     8007fe <strlcpy+0x2a>
  8007f0:	8a 01                	mov    (%ecx),%al
  8007f2:	41                   	inc    %ecx
  8007f3:	88 03                	mov    %al,(%ebx)
  8007f5:	43                   	inc    %ebx
  8007f6:	4a                   	dec    %edx
  8007f7:	74 05                	je     8007fe <strlcpy+0x2a>
  8007f9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007fc:	75 f2                	jne    8007f0 <strlcpy+0x1c>
		*dst = '\0';
  8007fe:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800801:	89 d8                	mov    %ebx,%eax
  800803:	29 f0                	sub    %esi,%eax
}
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 55 08             	mov    0x8(%ebp),%edx
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  800812:	80 3a 00             	cmpb   $0x0,(%edx)
  800815:	74 13                	je     80082a <strcmp+0x21>
  800817:	8a 02                	mov    (%edx),%al
  800819:	3a 01                	cmp    (%ecx),%al
  80081b:	75 0d                	jne    80082a <strcmp+0x21>
  80081d:	42                   	inc    %edx
  80081e:	41                   	inc    %ecx
  80081f:	80 3a 00             	cmpb   $0x0,(%edx)
  800822:	74 06                	je     80082a <strcmp+0x21>
  800824:	8a 02                	mov    (%edx),%al
  800826:	3a 01                	cmp    (%ecx),%al
  800828:	74 f3                	je     80081d <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082a:	0f b6 02             	movzbl (%edx),%eax
  80082d:	0f b6 11             	movzbl (%ecx),%edx
  800830:	29 d0                	sub    %edx,%eax
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	8b 55 08             	mov    0x8(%ebp),%edx
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800841:	85 c9                	test   %ecx,%ecx
  800843:	74 1f                	je     800864 <strncmp+0x30>
  800845:	80 3a 00             	cmpb   $0x0,(%edx)
  800848:	74 16                	je     800860 <strncmp+0x2c>
  80084a:	8a 02                	mov    (%edx),%al
  80084c:	3a 03                	cmp    (%ebx),%al
  80084e:	75 10                	jne    800860 <strncmp+0x2c>
  800850:	42                   	inc    %edx
  800851:	43                   	inc    %ebx
  800852:	49                   	dec    %ecx
  800853:	74 0f                	je     800864 <strncmp+0x30>
  800855:	80 3a 00             	cmpb   $0x0,(%edx)
  800858:	74 06                	je     800860 <strncmp+0x2c>
  80085a:	8a 02                	mov    (%edx),%al
  80085c:	3a 03                	cmp    (%ebx),%al
  80085e:	74 f0                	je     800850 <strncmp+0x1c>
	if (n == 0)
  800860:	85 c9                	test   %ecx,%ecx
  800862:	75 07                	jne    80086b <strncmp+0x37>
		return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	eb 0a                	jmp    800875 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	0f b6 03             	movzbl (%ebx),%eax
  800871:	29 c2                	sub    %eax,%edx
  800873:	89 d0                	mov    %edx,%eax
}
  800875:	5b                   	pop    %ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800881:	80 38 00             	cmpb   $0x0,(%eax)
  800884:	74 0a                	je     800890 <strchr+0x18>
		if (*s == c)
  800886:	38 10                	cmp    %dl,(%eax)
  800888:	74 0b                	je     800895 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088a:	40                   	inc    %eax
  80088b:	80 38 00             	cmpb   $0x0,(%eax)
  80088e:	75 f6                	jne    800886 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8008a0:	80 38 00             	cmpb   $0x0,(%eax)
  8008a3:	74 0a                	je     8008af <strfind+0x18>
		if (*s == c)
  8008a5:	38 10                	cmp    %dl,(%eax)
  8008a7:	74 06                	je     8008af <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	40                   	inc    %eax
  8008aa:	80 38 00             	cmpb   $0x0,(%eax)
  8008ad:	75 f6                	jne    8008a5 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8008bb:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8008bd:	85 c9                	test   %ecx,%ecx
  8008bf:	74 40                	je     800901 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c7:	75 30                	jne    8008f9 <memset+0x48>
  8008c9:	f6 c1 03             	test   $0x3,%cl
  8008cc:	75 2b                	jne    8008f9 <memset+0x48>
		c &= 0xFF;
  8008ce:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	c1 e0 18             	shl    $0x18,%eax
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	c1 e2 10             	shl    $0x10,%edx
  8008e1:	09 d0                	or     %edx,%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	c1 e2 08             	shl    $0x8,%edx
  8008e9:	09 d0                	or     %edx,%eax
  8008eb:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8008ee:	c1 e9 02             	shr    $0x2,%ecx
  8008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f4:	fc                   	cld    
  8008f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f7:	eb 06                	jmp    8008ff <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	fc                   	cld    
  8008fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8008ff:	89 f8                	mov    %edi,%eax
}
  800901:	5f                   	pop    %edi
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800912:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800914:	39 c6                	cmp    %eax,%esi
  800916:	73 34                	jae    80094c <memmove+0x48>
  800918:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091b:	39 c2                	cmp    %eax,%edx
  80091d:	76 2d                	jbe    80094c <memmove+0x48>
		s += n;
  80091f:	89 d6                	mov    %edx,%esi
		d += n;
  800921:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	f6 c2 03             	test   $0x3,%dl
  800927:	75 1b                	jne    800944 <memmove+0x40>
  800929:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092f:	75 13                	jne    800944 <memmove+0x40>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 0e                	jne    800944 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800936:	83 ef 04             	sub    $0x4,%edi
  800939:	83 ee 04             	sub    $0x4,%esi
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	fd                   	std    
  800940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800942:	eb 05                	jmp    800949 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	4f                   	dec    %edi
  800945:	4e                   	dec    %esi
  800946:	fd                   	std    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800949:	fc                   	cld    
  80094a:	eb 20                	jmp    80096c <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800952:	75 15                	jne    800969 <memmove+0x65>
  800954:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095a:	75 0d                	jne    800969 <memmove+0x65>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 08                	jne    800969 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800961:	c1 e9 02             	shr    $0x2,%ecx
  800964:	fc                   	cld    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb 03                	jmp    80096c <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800969:	fc                   	cld    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 83 ff ff ff       	call   800904 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  80098a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80098d:	8b 55 10             	mov    0x10(%ebp),%edx
  800990:	4a                   	dec    %edx
  800991:	83 fa ff             	cmp    $0xffffffff,%edx
  800994:	74 1a                	je     8009b0 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800996:	8a 01                	mov    (%ecx),%al
  800998:	3a 03                	cmp    (%ebx),%al
  80099a:	74 0c                	je     8009a8 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 d0             	movzbl %al,%edx
  80099f:	0f b6 03             	movzbl (%ebx),%eax
  8009a2:	29 c2                	sub    %eax,%edx
  8009a4:	89 d0                	mov    %edx,%eax
  8009a6:	eb 0d                	jmp    8009b5 <memcmp+0x32>
		s1++, s2++;
  8009a8:	41                   	inc    %ecx
  8009a9:	43                   	inc    %ebx
  8009aa:	4a                   	dec    %edx
  8009ab:	83 fa ff             	cmp    $0xffffffff,%edx
  8009ae:	75 e6                	jne    800996 <memcmp+0x13>
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c6:	39 d0                	cmp    %edx,%eax
  8009c8:	73 09                	jae    8009d3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ca:	38 08                	cmp    %cl,(%eax)
  8009cc:	74 05                	je     8009d3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ce:	40                   	inc    %eax
  8009cf:	39 d0                	cmp    %edx,%eax
  8009d1:	72 f7                	jb     8009ca <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 55 08             	mov    0x8(%ebp),%edx
  8009de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8009e9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009ee:	80 3a 20             	cmpb   $0x20,(%edx)
  8009f1:	74 05                	je     8009f8 <strtol+0x23>
  8009f3:	80 3a 09             	cmpb   $0x9,(%edx)
  8009f6:	75 0b                	jne    800a03 <strtol+0x2e>
  8009f8:	42                   	inc    %edx
  8009f9:	80 3a 20             	cmpb   $0x20,(%edx)
  8009fc:	74 fa                	je     8009f8 <strtol+0x23>
  8009fe:	80 3a 09             	cmpb   $0x9,(%edx)
  800a01:	74 f5                	je     8009f8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800a03:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800a06:	75 03                	jne    800a0b <strtol+0x36>
		s++;
  800a08:	42                   	inc    %edx
  800a09:	eb 0b                	jmp    800a16 <strtol+0x41>
	else if (*s == '-')
  800a0b:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800a0e:	75 06                	jne    800a16 <strtol+0x41>
		s++, neg = 1;
  800a10:	42                   	inc    %edx
  800a11:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a16:	85 c9                	test   %ecx,%ecx
  800a18:	74 05                	je     800a1f <strtol+0x4a>
  800a1a:	83 f9 10             	cmp    $0x10,%ecx
  800a1d:	75 15                	jne    800a34 <strtol+0x5f>
  800a1f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a22:	75 10                	jne    800a34 <strtol+0x5f>
  800a24:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a28:	75 0a                	jne    800a34 <strtol+0x5f>
		s += 2, base = 16;
  800a2a:	83 c2 02             	add    $0x2,%edx
  800a2d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a32:	eb 14                	jmp    800a48 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800a34:	85 c9                	test   %ecx,%ecx
  800a36:	75 10                	jne    800a48 <strtol+0x73>
  800a38:	80 3a 30             	cmpb   $0x30,(%edx)
  800a3b:	75 05                	jne    800a42 <strtol+0x6d>
		s++, base = 8;
  800a3d:	42                   	inc    %edx
  800a3e:	b1 08                	mov    $0x8,%cl
  800a40:	eb 06                	jmp    800a48 <strtol+0x73>
	else if (base == 0)
  800a42:	85 c9                	test   %ecx,%ecx
  800a44:	75 02                	jne    800a48 <strtol+0x73>
		base = 10;
  800a46:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a48:	8a 02                	mov    (%edx),%al
  800a4a:	83 e8 30             	sub    $0x30,%eax
  800a4d:	3c 09                	cmp    $0x9,%al
  800a4f:	77 08                	ja     800a59 <strtol+0x84>
			dig = *s - '0';
  800a51:	0f be 02             	movsbl (%edx),%eax
  800a54:	83 e8 30             	sub    $0x30,%eax
  800a57:	eb 20                	jmp    800a79 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800a59:	8a 02                	mov    (%edx),%al
  800a5b:	83 e8 61             	sub    $0x61,%eax
  800a5e:	3c 19                	cmp    $0x19,%al
  800a60:	77 08                	ja     800a6a <strtol+0x95>
			dig = *s - 'a' + 10;
  800a62:	0f be 02             	movsbl (%edx),%eax
  800a65:	83 e8 57             	sub    $0x57,%eax
  800a68:	eb 0f                	jmp    800a79 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800a6a:	8a 02                	mov    (%edx),%al
  800a6c:	83 e8 41             	sub    $0x41,%eax
  800a6f:	3c 19                	cmp    $0x19,%al
  800a71:	77 12                	ja     800a85 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800a73:	0f be 02             	movsbl (%edx),%eax
  800a76:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a79:	39 c8                	cmp    %ecx,%eax
  800a7b:	7d 08                	jge    800a85 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a7d:	42                   	inc    %edx
  800a7e:	0f af d9             	imul   %ecx,%ebx
  800a81:	01 c3                	add    %eax,%ebx
  800a83:	eb c3                	jmp    800a48 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a85:	85 f6                	test   %esi,%esi
  800a87:	74 02                	je     800a8b <strtol+0xb6>
		*endptr = (char *) s;
  800a89:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a8b:	89 d8                	mov    %ebx,%eax
  800a8d:	85 ff                	test   %edi,%edi
  800a8f:	74 02                	je     800a93 <strtol+0xbe>
  800a91:	f7 d8                	neg    %eax
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	83 ec 04             	sub    $0x4,%esp
  800aa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	89 fb                	mov    %edi,%ebx
  800ab0:	89 fe                	mov    %edi,%esi
  800ab2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab4:	83 c4 04             	add    $0x4,%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <sys_cgetc>:

int
sys_cgetc(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	89 fa                	mov    %edi,%edx
  800ace:	89 f9                	mov    %edi,%ecx
  800ad0:	89 fb                	mov    %edi,%ebx
  800ad2:	89 fe                	mov    %edi,%esi
  800ad4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ae7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	89 f9                	mov    %edi,%ecx
  800af3:	89 fb                	mov    %edi,%ebx
  800af5:	89 fe                	mov    %edi,%esi
  800af7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 03                	push   $0x3
  800b03:	68 38 14 80 00       	push   $0x801438
  800b08:	6a 23                	push   $0x23
  800b0a:	68 55 14 80 00       	push   $0x801455
  800b0f:	e8 38 02 00 00       	call   800d4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b22:	b8 02 00 00 00       	mov    $0x2,%eax
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	89 fa                	mov    %edi,%edx
  800b2e:	89 f9                	mov    %edi,%ecx
  800b30:	89 fb                	mov    %edi,%ebx
  800b32:	89 fe                	mov    %edi,%esi
  800b34:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_yield>:

void
sys_yield(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	89 fa                	mov    %edi,%edx
  800b4d:	89 f9                	mov    %edi,%ecx
  800b4f:	89 fb                	mov    %edi,%ebx
  800b51:	89 fe                	mov    %edi,%esi
  800b53:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b71:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	89 fe                	mov    %edi,%esi
  800b78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 04                	push   $0x4
  800b84:	68 38 14 80 00       	push   $0x801438
  800b89:	6a 23                	push   $0x23
  800b8b:	68 55 14 80 00       	push   $0x801455
  800b90:	e8 b7 01 00 00       	call   800d4c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb2:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bb5:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 05                	push   $0x5
  800bc6:	68 38 14 80 00       	push   $0x801438
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 55 14 80 00       	push   $0x801455
  800bd2:	e8 75 01 00 00       	call   800d4c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bee:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	89 fb                	mov    %edi,%ebx
  800bfa:	89 fe                	mov    %edi,%esi
  800bfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 06                	push   $0x6
  800c08:	68 38 14 80 00       	push   $0x801438
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 55 14 80 00       	push   $0x801455
  800c14:	e8 33 01 00 00       	call   800d4c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c30:	b8 08 00 00 00       	mov    $0x8,%eax
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	89 fb                	mov    %edi,%ebx
  800c3c:	89 fe                	mov    %edi,%esi
  800c3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 08                	push   $0x8
  800c4a:	68 38 14 80 00       	push   $0x801438
  800c4f:	6a 23                	push   $0x23
  800c51:	68 55 14 80 00       	push   $0x801455
  800c56:	e8 f1 00 00 00       	call   800d4c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c72:	b8 09 00 00 00       	mov    $0x9,%eax
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	89 fb                	mov    %edi,%ebx
  800c7e:	89 fe                	mov    %edi,%esi
  800c80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 09                	push   $0x9
  800c8c:	68 38 14 80 00       	push   $0x801438
  800c91:	6a 23                	push   $0x23
  800c93:	68 55 14 80 00       	push   $0x801455
  800c98:	e8 af 00 00 00       	call   800d4c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cb4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	89 fb                	mov    %edi,%ebx
  800cc0:	89 fe                	mov    %edi,%esi
  800cc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 0a                	push   $0xa
  800cce:	68 38 14 80 00       	push   $0x801438
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 55 14 80 00       	push   $0x801455
  800cda:	e8 6d 00 00 00       	call   800d4c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cf9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfe:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d16:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	89 f9                	mov    %edi,%ecx
  800d22:	89 fb                	mov    %edi,%ebx
  800d24:	89 fe                	mov    %edi,%esi
  800d26:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 0d                	push   $0xd
  800d32:	68 38 14 80 00       	push   $0x801438
  800d37:	6a 23                	push   $0x23
  800d39:	68 55 14 80 00       	push   $0x801455
  800d3e:	e8 09 00 00 00       	call   800d4c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    
	...

00800d4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800d53:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d56:	ff 75 0c             	pushl  0xc(%ebp)
  800d59:	ff 75 08             	pushl  0x8(%ebp)
  800d5c:	ff 35 70 37 80 00    	pushl  0x803770
  800d62:	83 ec 08             	sub    $0x8,%esp
  800d65:	e8 b2 fd ff ff       	call   800b1c <sys_getenvid>
  800d6a:	83 c4 08             	add    $0x8,%esp
  800d6d:	50                   	push   %eax
  800d6e:	68 64 14 80 00       	push   $0x801464
  800d73:	e8 ec f4 ff ff       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d78:	83 c4 18             	add    $0x18,%esp
  800d7b:	53                   	push   %ebx
  800d7c:	ff 75 10             	pushl  0x10(%ebp)
  800d7f:	e8 8f f4 ff ff       	call   800213 <vcprintf>
	cprintf("\n");
  800d84:	c7 04 24 6d 10 80 00 	movl   $0x80106d,(%esp)
  800d8b:	e8 d4 f4 ff ff       	call   800264 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800d90:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800d93:	cc                   	int3   
  800d94:	eb fd                	jmp    800d93 <_panic+0x47>
	...

00800d98 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	83 ec 14             	sub    $0x14,%esp
  800da0:	8b 55 14             	mov    0x14(%ebp),%edx
  800da3:	8b 75 08             	mov    0x8(%ebp),%esi
  800da6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800da9:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dac:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dae:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800db4:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800db7:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800db9:	75 11                	jne    800dcc <__udivdi3+0x34>
    {
      if (d0 > n1)
  800dbb:	39 f8                	cmp    %edi,%eax
  800dbd:	76 4d                	jbe    800e0c <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc4:	f7 75 e4             	divl   -0x1c(%ebp)
  800dc7:	89 c7                	mov    %eax,%edi
  800dc9:	eb 09                	jmp    800dd4 <__udivdi3+0x3c>
  800dcb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dcc:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800dcf:	76 17                	jbe    800de8 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800dd1:	31 ff                	xor    %edi,%edi
  800dd3:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800dd4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ddb:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dde:	83 c4 14             	add    $0x14,%esp
  800de1:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de2:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de4:	5f                   	pop    %edi
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    
  800de7:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800de8:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800dec:	89 c7                	mov    %eax,%edi
  800dee:	83 f7 1f             	xor    $0x1f,%edi
  800df1:	75 4d                	jne    800e40 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800df3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800df6:	77 0a                	ja     800e02 <__udivdi3+0x6a>
  800df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  800dfb:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dfd:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e00:	72 d2                	jb     800dd4 <__udivdi3+0x3c>
		{
		  q0 = 1;
  800e02:	bf 01 00 00 00       	mov    $0x1,%edi
  800e07:	eb cb                	jmp    800dd4 <__udivdi3+0x3c>
  800e09:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	75 0e                	jne    800e21 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e13:	b8 01 00 00 00       	mov    $0x1,%eax
  800e18:	31 c9                	xor    %ecx,%ecx
  800e1a:	31 d2                	xor    %edx,%edx
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e21:	89 f0                	mov    %esi,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	f7 75 e4             	divl   -0x1c(%ebp)
  800e28:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2e:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e31:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e34:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e37:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e39:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e3a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e3c:	5f                   	pop    %edi
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    
  800e3f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e40:	b8 20 00 00 00       	mov    $0x20,%eax
  800e45:	29 f8                	sub    %edi,%eax
  800e47:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800e4a:	89 f9                	mov    %edi,%ecx
  800e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4f:	d3 e2                	shl    %cl,%edx
  800e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e54:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e57:	d3 e8                	shr    %cl,%eax
  800e59:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  800e5b:	89 f9                	mov    %edi,%ecx
  800e5d:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e60:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e63:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e66:	89 f2                	mov    %esi,%edx
  800e68:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800e6a:	89 f9                	mov    %edi,%ecx
  800e6c:	d3 e6                	shl    %cl,%esi
  800e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e71:	8a 4d e8             	mov    -0x18(%ebp),%cl
  800e74:	d3 e8                	shr    %cl,%eax
  800e76:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  800e78:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e7a:	89 f0                	mov    %esi,%eax
  800e7c:	f7 75 f4             	divl   -0xc(%ebp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e83:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e89:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8b:	39 f2                	cmp    %esi,%edx
  800e8d:	77 0f                	ja     800e9e <__udivdi3+0x106>
  800e8f:	0f 85 3f ff ff ff    	jne    800dd4 <__udivdi3+0x3c>
  800e95:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e98:	0f 86 36 ff ff ff    	jbe    800dd4 <__udivdi3+0x3c>
		{
		  q0--;
  800e9e:	4f                   	dec    %edi
  800e9f:	e9 30 ff ff ff       	jmp    800dd4 <__udivdi3+0x3c>

00800ea4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	83 ec 30             	sub    $0x30,%esp
  800eac:	8b 55 14             	mov    0x14(%ebp),%edx
  800eaf:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  800eb2:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800eb4:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800eb7:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  800eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ebf:	85 ff                	test   %edi,%edi
  800ec1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800ec8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  800ecf:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ed2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  800ed5:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ed8:	75 3e                	jne    800f18 <__umoddi3+0x74>
    {
      if (d0 > n1)
  800eda:	39 d6                	cmp    %edx,%esi
  800edc:	0f 86 a2 00 00 00    	jbe    800f84 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee2:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800ee4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800ee7:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee9:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  800eec:	74 1b                	je     800f09 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  800eee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  800ef4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800efb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f01:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800f04:	89 10                	mov    %edx,(%eax)
  800f06:	89 48 04             	mov    %ecx,0x4(%eax)
  800f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f0f:	83 c4 30             	add    $0x30,%esp
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    
  800f16:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f18:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  800f1b:	76 1f                	jbe    800f3c <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  800f20:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f23:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  800f26:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  800f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f32:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f35:	83 c4 30             	add    $0x30,%esp
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f3c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f3f:	83 f0 1f             	xor    $0x1f,%eax
  800f42:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f45:	75 61                	jne    800fa8 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f47:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  800f4a:	77 05                	ja     800f51 <__umoddi3+0xad>
  800f4c:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  800f4f:	72 10                	jb     800f61 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f51:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f54:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f57:	29 f0                	sub    %esi,%eax
  800f59:	19 fa                	sbb    %edi,%edx
  800f5b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f5e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  800f61:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f64:	85 d2                	test   %edx,%edx
  800f66:	74 a1                	je     800f09 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  800f68:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  800f6b:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  800f71:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  800f74:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f7d:	89 01                	mov    %eax,(%ecx)
  800f7f:	89 51 04             	mov    %edx,0x4(%ecx)
  800f82:	eb 85                	jmp    800f09 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f84:	85 f6                	test   %esi,%esi
  800f86:	75 0b                	jne    800f93 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	f7 f6                	div    %esi
  800f91:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f93:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f96:	89 fa                	mov    %edi,%edx
  800f98:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f9d:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fa0:	f7 f6                	div    %esi
  800fa2:	e9 3d ff ff ff       	jmp    800ee4 <__umoddi3+0x40>
  800fa7:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fa8:	b8 20 00 00 00       	mov    $0x20,%eax
  800fad:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800fb0:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  800fb3:	89 fa                	mov    %edi,%edx
  800fb5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800fb8:	d3 e2                	shl    %cl,%edx
  800fba:	89 f0                	mov    %esi,%eax
  800fbc:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fbf:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  800fc1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800fc4:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fc6:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fc8:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fcb:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fce:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fd0:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  800fd2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fd5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  800fd8:	d3 e0                	shl    %cl,%eax
  800fda:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800fdd:	8a 4d d8             	mov    -0x28(%ebp),%cl
  800fe0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	0b 45 cc             	or     -0x34(%ebp),%eax
  800fe8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  800feb:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fee:	f7 f7                	div    %edi
  800ff0:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ff3:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ff6:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  800ffb:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ffe:	77 0a                	ja     80100a <__umoddi3+0x166>
  801000:	75 12                	jne    801014 <__umoddi3+0x170>
  801002:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801005:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801008:	76 0a                	jbe    801014 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80100a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80100d:	29 f1                	sub    %esi,%ecx
  80100f:	19 fa                	sbb    %edi,%edx
  801011:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801014:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801017:	85 c0                	test   %eax,%eax
  801019:	0f 84 ea fe ff ff    	je     800f09 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80101f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801022:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801025:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801028:	19 d1                	sbb    %edx,%ecx
  80102a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80102d:	89 ca                	mov    %ecx,%edx
  80102f:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801032:	d3 e2                	shl    %cl,%edx
  801034:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801037:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80103a:	d3 e8                	shr    %cl,%eax
  80103c:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80103e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801041:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801043:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801049:	e9 ad fe ff ff       	jmp    800efb <__umoddi3+0x57>
