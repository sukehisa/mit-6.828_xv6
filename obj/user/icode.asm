
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800039:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 20 	movl   $0x801e20,0x803000
  800046:	1e 80 00 

	cprintf("icode startup\n");
  800049:	68 26 1e 80 00       	push   $0x801e26
  80004e:	e8 19 02 00 00       	call   80026c <cprintf>

	cprintf("icode: open /motd\n");
  800053:	c7 04 24 35 1e 80 00 	movl   $0x801e35,(%esp)
  80005a:	e8 0d 02 00 00       	call   80026c <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005f:	83 c4 08             	add    $0x8,%esp
  800062:	6a 00                	push   $0x0
  800064:	68 48 1e 80 00       	push   $0x801e48
  800069:	e8 d1 12 00 00       	call   80133f <open>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	79 12                	jns    800089 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800077:	50                   	push   %eax
  800078:	68 4e 1e 80 00       	push   $0x801e4e
  80007d:	6a 0f                	push   $0xf
  80007f:	68 64 1e 80 00       	push   $0x801e64
  800084:	e8 07 01 00 00       	call   800190 <_panic>

	cprintf("icode: read /motd\n");
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	68 71 1e 80 00       	push   $0x801e71
  800091:	e8 d6 01 00 00       	call   80026c <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  80009f:	eb 0d                	jmp    8000ae <umain+0x7a>
		sys_cputs(buf, n);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	50                   	push   %eax
  8000a5:	56                   	push   %esi
  8000a6:	e8 f5 09 00 00       	call   800aa0 <sys_cputs>
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	68 00 02 00 00       	push   $0x200
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
  8000b8:	e8 79 0f 00 00       	call   801036 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	7f dd                	jg     8000a1 <umain+0x6d>

	cprintf("icode: close /motd\n");
  8000c4:	83 ec 0c             	sub    $0xc,%esp
  8000c7:	68 84 1e 80 00       	push   $0x801e84
  8000cc:	e8 9b 01 00 00       	call   80026c <cprintf>
	close(fd);
  8000d1:	89 1c 24             	mov    %ebx,(%esp)
  8000d4:	e8 28 0e 00 00       	call   800f01 <close>

	cprintf("icode: spawn /init\n");
  8000d9:	c7 04 24 98 1e 80 00 	movl   $0x801e98,(%esp)
  8000e0:	e8 87 01 00 00       	call   80026c <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	68 ac 1e 80 00       	push   $0x801eac
  8000f1:	68 b5 1e 80 00       	push   $0x801eb5
  8000f6:	68 bf 1e 80 00       	push   $0x801ebf
  8000fb:	68 be 1e 80 00       	push   $0x801ebe
  800100:	e8 30 16 00 00       	call   801735 <spawnl>
  800105:	83 c4 20             	add    $0x20,%esp
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 12                	jns    80011e <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010c:	50                   	push   %eax
  80010d:	68 c4 1e 80 00       	push   $0x801ec4
  800112:	6a 1a                	push   $0x1a
  800114:	68 64 1e 80 00       	push   $0x801e64
  800119:	e8 72 00 00 00       	call   800190 <_panic>

	cprintf("icode: exiting\n");
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 db 1e 80 00       	push   $0x801edb
  800126:	e8 41 01 00 00       	call   80026c <cprintf>
}
  80012b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	c9                   	leave  
  800131:	c3                   	ret    
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 75 08             	mov    0x8(%ebp),%esi
  80013c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80013f:	e8 e0 09 00 00       	call   800b24 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	89 c2                	mov    %eax,%edx
  80014b:	c1 e2 05             	shl    $0x5,%edx
  80014e:	29 c2                	sub    %eax,%edx
  800150:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800157:	89 15 04 40 80 00    	mov    %edx,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015d:	85 f6                	test   %esi,%esi
  80015f:	7e 07                	jle    800168 <libmain+0x34>
		binaryname = argv[0];
  800161:	8b 03                	mov    (%ebx),%eax
  800163:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	53                   	push   %ebx
  80016c:	56                   	push   %esi
  80016d:	e8 c2 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800172:	e8 09 00 00 00       	call   800180 <exit>
}
  800177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800186:	6a 00                	push   $0x0
  800188:	e8 56 09 00 00       	call   800ae3 <sys_env_destroy>
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    
	...

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800197:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019a:	ff 75 0c             	pushl  0xc(%ebp)
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	ff 35 00 30 80 00    	pushl  0x803000
  8001a6:	83 ec 08             	sub    $0x8,%esp
  8001a9:	e8 76 09 00 00       	call   800b24 <sys_getenvid>
  8001ae:	83 c4 08             	add    $0x8,%esp
  8001b1:	50                   	push   %eax
  8001b2:	68 f8 1e 80 00       	push   $0x801ef8
  8001b7:	e8 b0 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 53 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 82 1e 80 00 	movl   $0x801e82,(%esp)
  8001cf:	e8 98 00 00 00       	call   80026c <cprintf>

	// Cause a breakpoint exception
	while (1)
  8001d4:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x47>
	...

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8001ef:	40                   	inc    %eax
  8001f0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 96 08 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	ff 43 04             	incl   0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 dc 01 80 00       	push   $0x8001dc
  80024a:	e8 49 01 00 00       	call   800398 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  800258:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 3c 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
  800264:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	8b 75 10             	mov    0x10(%ebp),%esi
  80028c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80028f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	8b 45 18             	mov    0x18(%ebp),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	39 fa                	cmp    %edi,%edx
  80029c:	77 39                	ja     8002d7 <printnum+0x57>
  80029e:	72 04                	jb     8002a4 <printnum+0x24>
  8002a0:	39 f0                	cmp    %esi,%eax
  8002a2:	77 33                	ja     8002d7 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	ff 75 20             	pushl  0x20(%ebp)
  8002aa:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff 75 18             	pushl  0x18(%ebp)
  8002b1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b9:	52                   	push   %edx
  8002ba:	50                   	push   %eax
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	e8 8a 18 00 00       	call   801b4c <__udivdi3>
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	52                   	push   %edx
  8002c6:	50                   	push   %eax
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 ae ff ff ff       	call   800280 <printnum>
  8002d2:	83 c4 20             	add    $0x20,%esp
  8002d5:	eb 19                	jmp    8002f0 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d7:	4b                   	dec    %ebx
  8002d8:	85 db                	test   %ebx,%ebx
  8002da:	7e 14                	jle    8002f0 <printnum+0x70>
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 20             	pushl  0x20(%ebp)
  8002e5:	ff 55 08             	call   *0x8(%ebp)
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	4b                   	dec    %ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f ec                	jg     8002dc <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	83 ec 04             	sub    $0x4,%esp
  800301:	52                   	push   %edx
  800302:	50                   	push   %eax
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	e8 4e 19 00 00       	call   801c58 <__umoddi3>
  80030a:	83 c4 14             	add    $0x14,%esp
  80030d:	0f be 80 2d 20 80 00 	movsbl 0x80202d(%eax),%eax
  800314:	50                   	push   %eax
  800315:	ff 55 08             	call   *0x8(%ebp)
}
  800318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800329:	83 f8 01             	cmp    $0x1,%eax
  80032c:	7e 0e                	jle    80033c <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 11                	mov    (%ecx),%edx
  800330:	8d 42 08             	lea    0x8(%edx),%eax
  800333:	89 01                	mov    %eax,(%ecx)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x3e>
	else if (lflag)
  80033c:	85 c0                	test   %eax,%eax
  80033e:	74 10                	je     800350 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800340:	8b 11                	mov    (%ecx),%edx
  800342:	8d 42 04             	lea    0x4(%edx),%eax
  800345:	89 01                	mov    %eax,(%ecx)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 11                	mov    (%ecx),%edx
  800352:	8d 42 04             	lea    0x4(%edx),%eax
  800355:	89 01                	mov    %eax,(%ecx)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800369:	83 f8 01             	cmp    $0x1,%eax
  80036c:	7e 0e                	jle    80037c <getint+0x1c>
		return va_arg(*ap, long long);
  80036e:	8b 11                	mov    (%ecx),%edx
  800370:	8d 42 08             	lea    0x8(%edx),%eax
  800373:	89 01                	mov    %eax,(%ecx)
  800375:	8b 02                	mov    (%edx),%eax
  800377:	8b 52 04             	mov    0x4(%edx),%edx
  80037a:	eb 1a                	jmp    800396 <getint+0x36>
	else if (lflag)
  80037c:	85 c0                	test   %eax,%eax
  80037e:	74 0c                	je     80038c <getint+0x2c>
		return va_arg(*ap, long);
  800380:	8b 01                	mov    (%ecx),%eax
  800382:	8d 50 04             	lea    0x4(%eax),%edx
  800385:	89 11                	mov    %edx,(%ecx)
  800387:	8b 00                	mov    (%eax),%eax
  800389:	99                   	cltd   
  80038a:	eb 0a                	jmp    800396 <getint+0x36>
	else
		return va_arg(*ap, int);
  80038c:	8b 01                	mov    (%ecx),%eax
  80038e:	8d 50 04             	lea    0x4(%eax),%edx
  800391:	89 11                	mov    %edx,(%ecx)
  800393:	8b 00                	mov    (%eax),%eax
  800395:	99                   	cltd   
}
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 1c             	sub    $0x1c,%esp
  8003a1:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  8003a4:	0f b6 0b             	movzbl (%ebx),%ecx
  8003a7:	43                   	inc    %ebx
  8003a8:	83 f9 25             	cmp    $0x25,%ecx
  8003ab:	74 1e                	je     8003cb <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ad:	85 c9                	test   %ecx,%ecx
  8003af:	0f 84 dc 02 00 00    	je     800691 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	ff 75 0c             	pushl  0xc(%ebp)
  8003bb:	51                   	push   %ecx
  8003bc:	ff 55 08             	call   *0x8(%ebp)
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	0f b6 0b             	movzbl (%ebx),%ecx
  8003c5:	43                   	inc    %ebx
  8003c6:	83 f9 25             	cmp    $0x25,%ecx
  8003c9:	75 e2                	jne    8003ad <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  8003cb:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  8003cf:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  8003d6:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  8003db:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8003e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	0f b6 0b             	movzbl (%ebx),%ecx
  8003ea:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003ed:	43                   	inc    %ebx
  8003ee:	83 f8 55             	cmp    $0x55,%eax
  8003f1:	0f 87 75 02 00 00    	ja     80066c <vprintfmt+0x2d4>
  8003f7:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fe:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800402:	eb e3                	jmp    8003e7 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800408:	eb dd                	jmp    8003e7 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040a:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80040f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800412:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800416:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800419:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80041c:	83 f8 09             	cmp    $0x9,%eax
  80041f:	77 28                	ja     800449 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800421:	43                   	inc    %ebx
  800422:	eb eb                	jmp    80040f <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800424:	8b 55 14             	mov    0x14(%ebp),%edx
  800427:	8d 42 04             	lea    0x4(%edx),%eax
  80042a:	89 45 14             	mov    %eax,0x14(%ebp)
  80042d:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  80042f:	eb 18                	jmp    800449 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  800431:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800435:	79 b0                	jns    8003e7 <vprintfmt+0x4f>
				width = 0;
  800437:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  80043e:	eb a7                	jmp    8003e7 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800440:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  800447:	eb 9e                	jmp    8003e7 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  800449:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80044d:	79 98                	jns    8003e7 <vprintfmt+0x4f>
				width = precision, precision = -1;
  80044f:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800452:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  800457:	eb 8e                	jmp    8003e7 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800459:	47                   	inc    %edi
			goto reswitch;
  80045a:	eb 8b                	jmp    8003e7 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	ff 75 0c             	pushl  0xc(%ebp)
  800462:	8b 55 14             	mov    0x14(%ebp),%edx
  800465:	8d 42 04             	lea    0x4(%edx),%eax
  800468:	89 45 14             	mov    %eax,0x14(%ebp)
  80046b:	ff 32                	pushl  (%edx)
  80046d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	e9 2c ff ff ff       	jmp    8003a4 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	8b 55 14             	mov    0x14(%ebp),%edx
  80047b:	8d 42 04             	lea    0x4(%edx),%eax
  80047e:	89 45 14             	mov    %eax,0x14(%ebp)
  800481:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800483:	85 c0                	test   %eax,%eax
  800485:	79 02                	jns    800489 <vprintfmt+0xf1>
				err = -err;
  800487:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800489:	83 f8 0f             	cmp    $0xf,%eax
  80048c:	7f 0b                	jg     800499 <vprintfmt+0x101>
  80048e:	8b 3c 85 80 20 80 00 	mov    0x802080(,%eax,4),%edi
  800495:	85 ff                	test   %edi,%edi
  800497:	75 19                	jne    8004b2 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800499:	50                   	push   %eax
  80049a:	68 3e 20 80 00       	push   $0x80203e
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	ff 75 08             	pushl  0x8(%ebp)
  8004a5:	e8 ef 01 00 00       	call   800699 <printfmt>
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	e9 f2 fe ff ff       	jmp    8003a4 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  8004b2:	57                   	push   %edi
  8004b3:	68 27 23 80 00       	push   $0x802327
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	ff 75 08             	pushl  0x8(%ebp)
  8004be:	e8 d6 01 00 00       	call   800699 <printfmt>
  8004c3:	83 c4 10             	add    $0x10,%esp
			break;
  8004c6:	e9 d9 fe ff ff       	jmp    8003a4 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ce:	8d 42 04             	lea    0x4(%edx),%eax
  8004d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d4:	8b 3a                	mov    (%edx),%edi
  8004d6:	85 ff                	test   %edi,%edi
  8004d8:	75 05                	jne    8004df <vprintfmt+0x147>
				p = "(null)";
  8004da:	bf 47 20 80 00       	mov    $0x802047,%edi
			if (width > 0 && padc != '-')
  8004df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004e3:	7e 3b                	jle    800520 <vprintfmt+0x188>
  8004e5:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8004e9:	74 35                	je     800520 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	56                   	push   %esi
  8004ef:	57                   	push   %edi
  8004f0:	e8 58 02 00 00       	call   80074d <strnlen>
  8004f5:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004ff:	7e 1f                	jle    800520 <vprintfmt+0x188>
  800501:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800511:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	ff 4d f0             	decl   -0x10(%ebp)
  80051a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80051e:	7f e8                	jg     800508 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800520:	0f be 0f             	movsbl (%edi),%ecx
  800523:	47                   	inc    %edi
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 44                	je     80056c <vprintfmt+0x1d4>
  800528:	85 f6                	test   %esi,%esi
  80052a:	78 03                	js     80052f <vprintfmt+0x197>
  80052c:	4e                   	dec    %esi
  80052d:	78 3d                	js     80056c <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  80052f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800533:	74 18                	je     80054d <vprintfmt+0x1b5>
  800535:	8d 41 e0             	lea    -0x20(%ecx),%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x1b5>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	51                   	push   %ecx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	ff 4d f0             	decl   -0x10(%ebp)
  80055d:	0f be 0f             	movsbl (%edi),%ecx
  800560:	47                   	inc    %edi
  800561:	85 c9                	test   %ecx,%ecx
  800563:	74 07                	je     80056c <vprintfmt+0x1d4>
  800565:	85 f6                	test   %esi,%esi
  800567:	78 c6                	js     80052f <vprintfmt+0x197>
  800569:	4e                   	dec    %esi
  80056a:	79 c3                	jns    80052f <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800570:	0f 8e 2e fe ff ff    	jle    8003a4 <vprintfmt+0xc>
				putch(' ', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	ff 75 0c             	pushl  0xc(%ebp)
  80057c:	6a 20                	push   $0x20
  80057e:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	ff 4d f0             	decl   -0x10(%ebp)
  800587:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80058b:	7f e9                	jg     800576 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  80058d:	e9 12 fe ff ff       	jmp    8003a4 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800592:	57                   	push   %edi
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	50                   	push   %eax
  800597:	e8 c4 fd ff ff       	call   800360 <getint>
  80059c:	89 c6                	mov    %eax,%esi
  80059e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	85 d2                	test   %edx,%edx
  8005a5:	79 15                	jns    8005bc <vprintfmt+0x224>
				putch('-', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 2d                	push   $0x2d
  8005af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b2:	f7 de                	neg    %esi
  8005b4:	83 d7 00             	adc    $0x0,%edi
  8005b7:	f7 df                	neg    %edi
  8005b9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005bc:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8005c1:	eb 76                	jmp    800639 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c3:	57                   	push   %edi
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	50                   	push   %eax
  8005c8:	e8 53 fd ff ff       	call   800320 <getuint>
  8005cd:	89 c6                	mov    %eax,%esi
  8005cf:	89 d7                	mov    %edx,%edi
			base = 10;
  8005d1:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	eb 5e                	jmp    800639 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005db:	57                   	push   %edi
  8005dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005df:	50                   	push   %eax
  8005e0:	e8 3b fd ff ff       	call   800320 <getuint>
  8005e5:	89 c6                	mov    %eax,%esi
  8005e7:	89 d7                	mov    %edx,%edi
			base = 8;
  8005e9:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8005ee:	83 c4 08             	add    $0x8,%esp
  8005f1:	eb 46                	jmp    800639 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	ff 75 0c             	pushl  0xc(%ebp)
  8005f9:	6a 30                	push   $0x30
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005fe:	83 c4 08             	add    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	6a 78                	push   $0x78
  800606:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800609:	8b 55 14             	mov    0x14(%ebp),%edx
  80060c:	8d 42 04             	lea    0x4(%edx),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
  800612:	8b 32                	mov    (%edx),%esi
  800614:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800619:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800623:	57                   	push   %edi
  800624:	8d 45 14             	lea    0x14(%ebp),%eax
  800627:	50                   	push   %eax
  800628:	e8 f3 fc ff ff       	call   800320 <getuint>
  80062d:	89 c6                	mov    %eax,%esi
  80062f:	89 d7                	mov    %edx,%edi
			base = 16;
  800631:	ba 10 00 00 00       	mov    $0x10,%edx
  800636:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  800639:	83 ec 04             	sub    $0x4,%esp
  80063c:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	ff 75 f0             	pushl  -0x10(%ebp)
  800644:	52                   	push   %edx
  800645:	57                   	push   %edi
  800646:	56                   	push   %esi
  800647:	ff 75 0c             	pushl  0xc(%ebp)
  80064a:	ff 75 08             	pushl  0x8(%ebp)
  80064d:	e8 2e fc ff ff       	call   800280 <printnum>
			break;
  800652:	83 c4 20             	add    $0x20,%esp
  800655:	e9 4a fd ff ff       	jmp    8003a4 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	ff 75 0c             	pushl  0xc(%ebp)
  800660:	51                   	push   %ecx
  800661:	ff 55 08             	call   *0x8(%ebp)
			break;
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	e9 38 fd ff ff       	jmp    8003a4 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	ff 75 0c             	pushl  0xc(%ebp)
  800672:	6a 25                	push   $0x25
  800674:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800677:	4b                   	dec    %ebx
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80067f:	0f 84 1f fd ff ff    	je     8003a4 <vprintfmt+0xc>
  800685:	4b                   	dec    %ebx
  800686:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80068a:	75 f9                	jne    800685 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80068c:	e9 13 fd ff ff       	jmp    8003a4 <vprintfmt+0xc>
		}
	}
}
  800691:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800694:	5b                   	pop    %ebx
  800695:	5e                   	pop    %esi
  800696:	5f                   	pop    %edi
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a2:	50                   	push   %eax
  8006a3:	ff 75 10             	pushl  0x10(%ebp)
  8006a6:	ff 75 0c             	pushl  0xc(%ebp)
  8006a9:	ff 75 08             	pushl  0x8(%ebp)
  8006ac:	e8 e7 fc ff ff       	call   800398 <vprintfmt>
	va_end(ap);
}
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  8006b9:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  8006bc:	8b 0a                	mov    (%edx),%ecx
  8006be:	3b 4a 04             	cmp    0x4(%edx),%ecx
  8006c1:	73 07                	jae    8006ca <sprintputch+0x17>
		*b->buf++ = ch;
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	88 01                	mov    %al,(%ecx)
  8006c8:	ff 02                	incl   (%edx)
}
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 18             	sub    $0x18,%esp
  8006d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006db:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8006df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	74 04                	je     8006f1 <vsnprintf+0x25>
  8006ed:	85 c9                	test   %ecx,%ecx
  8006ef:	7f 07                	jg     8006f8 <vsnprintf+0x2c>
		return -E_INVAL;
  8006f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f6:	eb 1d                	jmp    800715 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f8:	ff 75 14             	pushl  0x14(%ebp)
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	68 b3 06 80 00       	push   $0x8006b3
  800707:	e8 8c fc ff ff       	call   800398 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800720:	50                   	push   %eax
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	ff 75 0c             	pushl  0xc(%ebp)
  800727:	ff 75 08             	pushl  0x8(%ebp)
  80072a:	e8 9d ff ff ff       	call   8006cc <vsnprintf>
	va_end(ap);

	return rc;
}
  80072f:	c9                   	leave  
  800730:	c3                   	ret    
  800731:	00 00                	add    %al,(%eax)
	...

00800734 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	80 3a 00             	cmpb   $0x0,(%edx)
  800742:	74 07                	je     80074b <strlen+0x17>
		n++;
  800744:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800745:	42                   	inc    %edx
  800746:	80 3a 00             	cmpb   $0x0,(%edx)
  800749:	75 f9                	jne    800744 <strlen+0x10>
		n++;
	return n;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    

0080074d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	85 d2                	test   %edx,%edx
  80075d:	74 0f                	je     80076e <strnlen+0x21>
  80075f:	80 39 00             	cmpb   $0x0,(%ecx)
  800762:	74 0a                	je     80076e <strnlen+0x21>
		n++;
  800764:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	41                   	inc    %ecx
  800766:	4a                   	dec    %edx
  800767:	74 05                	je     80076e <strnlen+0x21>
  800769:	80 39 00             	cmpb   $0x0,(%ecx)
  80076c:	75 f6                	jne    800764 <strnlen+0x17>
		n++;
	return n;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80077a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80077c:	8a 02                	mov    (%edx),%al
  80077e:	42                   	inc    %edx
  80077f:	88 01                	mov    %al,(%ecx)
  800781:	41                   	inc    %ecx
  800782:	84 c0                	test   %al,%al
  800784:	75 f6                	jne    80077c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800786:	89 d8                	mov    %ebx,%eax
  800788:	5b                   	pop    %ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	53                   	push   %ebx
  800793:	e8 9c ff ff ff       	call   800734 <strlen>
	strcpy(dst + len, src);
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80079e:	50                   	push   %eax
  80079f:	e8 cc ff ff ff       	call   800770 <strcpy>
	return dst;
}
  8007a4:	89 d8                	mov    %ebx,%eax
  8007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	57                   	push   %edi
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b7:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  8007ba:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  8007bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c1:	39 f3                	cmp    %esi,%ebx
  8007c3:	73 10                	jae    8007d5 <strncpy+0x2a>
		*dst++ = *src;
  8007c5:	8a 02                	mov    (%edx),%al
  8007c7:	88 01                	mov    %al,(%ecx)
  8007c9:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ca:	80 3a 01             	cmpb   $0x1,(%edx)
  8007cd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	43                   	inc    %ebx
  8007d1:	39 f3                	cmp    %esi,%ebx
  8007d3:	72 f0                	jb     8007c5 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d5:	89 f8                	mov    %edi,%eax
  8007d7:	5b                   	pop    %ebx
  8007d8:	5e                   	pop    %esi
  8007d9:	5f                   	pop    %edi
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007ea:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	74 19                	je     800809 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f0:	4a                   	dec    %edx
  8007f1:	74 13                	je     800806 <strlcpy+0x2a>
  8007f3:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f6:	74 0e                	je     800806 <strlcpy+0x2a>
  8007f8:	8a 01                	mov    (%ecx),%al
  8007fa:	41                   	inc    %ecx
  8007fb:	88 03                	mov    %al,(%ebx)
  8007fd:	43                   	inc    %ebx
  8007fe:	4a                   	dec    %edx
  8007ff:	74 05                	je     800806 <strlcpy+0x2a>
  800801:	80 39 00             	cmpb   $0x0,(%ecx)
  800804:	75 f2                	jne    8007f8 <strlcpy+0x1c>
		*dst = '\0';
  800806:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800809:	89 d8                	mov    %ebx,%eax
  80080b:	29 f0                	sub    %esi,%eax
}
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 55 08             	mov    0x8(%ebp),%edx
  800817:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80081a:	80 3a 00             	cmpb   $0x0,(%edx)
  80081d:	74 13                	je     800832 <strcmp+0x21>
  80081f:	8a 02                	mov    (%edx),%al
  800821:	3a 01                	cmp    (%ecx),%al
  800823:	75 0d                	jne    800832 <strcmp+0x21>
  800825:	42                   	inc    %edx
  800826:	41                   	inc    %ecx
  800827:	80 3a 00             	cmpb   $0x0,(%edx)
  80082a:	74 06                	je     800832 <strcmp+0x21>
  80082c:	8a 02                	mov    (%edx),%al
  80082e:	3a 01                	cmp    (%ecx),%al
  800830:	74 f3                	je     800825 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	0f b6 02             	movzbl (%edx),%eax
  800835:	0f b6 11             	movzbl (%ecx),%edx
  800838:	29 d0                	sub    %edx,%eax
}
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
  800843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 1f                	je     80086c <strncmp+0x30>
  80084d:	80 3a 00             	cmpb   $0x0,(%edx)
  800850:	74 16                	je     800868 <strncmp+0x2c>
  800852:	8a 02                	mov    (%edx),%al
  800854:	3a 03                	cmp    (%ebx),%al
  800856:	75 10                	jne    800868 <strncmp+0x2c>
  800858:	42                   	inc    %edx
  800859:	43                   	inc    %ebx
  80085a:	49                   	dec    %ecx
  80085b:	74 0f                	je     80086c <strncmp+0x30>
  80085d:	80 3a 00             	cmpb   $0x0,(%edx)
  800860:	74 06                	je     800868 <strncmp+0x2c>
  800862:	8a 02                	mov    (%edx),%al
  800864:	3a 03                	cmp    (%ebx),%al
  800866:	74 f0                	je     800858 <strncmp+0x1c>
	if (n == 0)
  800868:	85 c9                	test   %ecx,%ecx
  80086a:	75 07                	jne    800873 <strncmp+0x37>
		return 0;
  80086c:	b8 00 00 00 00       	mov    $0x0,%eax
  800871:	eb 0a                	jmp    80087d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 12             	movzbl (%edx),%edx
  800876:	0f b6 03             	movzbl (%ebx),%eax
  800879:	29 c2                	sub    %eax,%edx
  80087b:	89 d0                	mov    %edx,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800889:	80 38 00             	cmpb   $0x0,(%eax)
  80088c:	74 0a                	je     800898 <strchr+0x18>
		if (*s == c)
  80088e:	38 10                	cmp    %dl,(%eax)
  800890:	74 0b                	je     80089d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800892:	40                   	inc    %eax
  800893:	80 38 00             	cmpb   $0x0,(%eax)
  800896:	75 f6                	jne    80088e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  8008a8:	80 38 00             	cmpb   $0x0,(%eax)
  8008ab:	74 0a                	je     8008b7 <strfind+0x18>
		if (*s == c)
  8008ad:	38 10                	cmp    %dl,(%eax)
  8008af:	74 06                	je     8008b7 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b1:	40                   	inc    %eax
  8008b2:	80 38 00             	cmpb   $0x0,(%eax)
  8008b5:	75 f6                	jne    8008ad <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  8008c3:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 40                	je     800909 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cf:	75 30                	jne    800901 <memset+0x48>
  8008d1:	f6 c1 03             	test   $0x3,%cl
  8008d4:	75 2b                	jne    800901 <memset+0x48>
		c &= 0xFF;
  8008d6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e0:	c1 e0 18             	shl    $0x18,%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	c1 e2 10             	shl    $0x10,%edx
  8008e9:	09 d0                	or     %edx,%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	c1 e2 08             	shl    $0x8,%edx
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	fc                   	cld    
  8008fd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ff:	eb 06                	jmp    800907 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800901:	8b 45 0c             	mov    0xc(%ebp),%eax
  800904:	fc                   	cld    
  800905:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800907:	89 f8                	mov    %edi,%eax
}
  800909:	5f                   	pop    %edi
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	57                   	push   %edi
  800910:	56                   	push   %esi
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80091a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80091c:	39 c6                	cmp    %eax,%esi
  80091e:	73 34                	jae    800954 <memmove+0x48>
  800920:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800923:	39 c2                	cmp    %eax,%edx
  800925:	76 2d                	jbe    800954 <memmove+0x48>
		s += n;
  800927:	89 d6                	mov    %edx,%esi
		d += n;
  800929:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	f6 c2 03             	test   $0x3,%dl
  80092f:	75 1b                	jne    80094c <memmove+0x40>
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 13                	jne    80094c <memmove+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0e                	jne    80094c <memmove+0x40>
			asm volatile("std; rep movsl\n"
  80093e:	83 ef 04             	sub    $0x4,%edi
  800941:	83 ee 04             	sub    $0x4,%esi
  800944:	c1 e9 02             	shr    $0x2,%ecx
  800947:	fd                   	std    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 05                	jmp    800951 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094c:	4f                   	dec    %edi
  80094d:	4e                   	dec    %esi
  80094e:	fd                   	std    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800951:	fc                   	cld    
  800952:	eb 20                	jmp    800974 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	75 15                	jne    800971 <memmove+0x65>
  80095c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800962:	75 0d                	jne    800971 <memmove+0x65>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 08                	jne    800971 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800969:	c1 e9 02             	shr    $0x2,%ecx
  80096c:	fc                   	cld    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 03                	jmp    800974 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	fc                   	cld    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097b:	ff 75 10             	pushl  0x10(%ebp)
  80097e:	ff 75 0c             	pushl  0xc(%ebp)
  800981:	ff 75 08             	pushl  0x8(%ebp)
  800984:	e8 83 ff ff ff       	call   80090c <memmove>
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800992:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800995:	8b 55 10             	mov    0x10(%ebp),%edx
  800998:	4a                   	dec    %edx
  800999:	83 fa ff             	cmp    $0xffffffff,%edx
  80099c:	74 1a                	je     8009b8 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80099e:	8a 01                	mov    (%ecx),%al
  8009a0:	3a 03                	cmp    (%ebx),%al
  8009a2:	74 0c                	je     8009b0 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  8009a4:	0f b6 d0             	movzbl %al,%edx
  8009a7:	0f b6 03             	movzbl (%ebx),%eax
  8009aa:	29 c2                	sub    %eax,%edx
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	eb 0d                	jmp    8009bd <memcmp+0x32>
		s1++, s2++;
  8009b0:	41                   	inc    %ecx
  8009b1:	43                   	inc    %ebx
  8009b2:	4a                   	dec    %edx
  8009b3:	83 fa ff             	cmp    $0xffffffff,%edx
  8009b6:	75 e6                	jne    80099e <memcmp+0x13>
	}

	return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	5b                   	pop    %ebx
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c9:	89 c2                	mov    %eax,%edx
  8009cb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ce:	39 d0                	cmp    %edx,%eax
  8009d0:	73 09                	jae    8009db <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	38 08                	cmp    %cl,(%eax)
  8009d4:	74 05                	je     8009db <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	40                   	inc    %eax
  8009d7:	39 d0                	cmp    %edx,%eax
  8009d9:	72 f7                	jb     8009d2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8009f1:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009f6:	80 3a 20             	cmpb   $0x20,(%edx)
  8009f9:	74 05                	je     800a00 <strtol+0x23>
  8009fb:	80 3a 09             	cmpb   $0x9,(%edx)
  8009fe:	75 0b                	jne    800a0b <strtol+0x2e>
  800a00:	42                   	inc    %edx
  800a01:	80 3a 20             	cmpb   $0x20,(%edx)
  800a04:	74 fa                	je     800a00 <strtol+0x23>
  800a06:	80 3a 09             	cmpb   $0x9,(%edx)
  800a09:	74 f5                	je     800a00 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800a0b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800a0e:	75 03                	jne    800a13 <strtol+0x36>
		s++;
  800a10:	42                   	inc    %edx
  800a11:	eb 0b                	jmp    800a1e <strtol+0x41>
	else if (*s == '-')
  800a13:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800a16:	75 06                	jne    800a1e <strtol+0x41>
		s++, neg = 1;
  800a18:	42                   	inc    %edx
  800a19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1e:	85 c9                	test   %ecx,%ecx
  800a20:	74 05                	je     800a27 <strtol+0x4a>
  800a22:	83 f9 10             	cmp    $0x10,%ecx
  800a25:	75 15                	jne    800a3c <strtol+0x5f>
  800a27:	80 3a 30             	cmpb   $0x30,(%edx)
  800a2a:	75 10                	jne    800a3c <strtol+0x5f>
  800a2c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a30:	75 0a                	jne    800a3c <strtol+0x5f>
		s += 2, base = 16;
  800a32:	83 c2 02             	add    $0x2,%edx
  800a35:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a3a:	eb 14                	jmp    800a50 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800a3c:	85 c9                	test   %ecx,%ecx
  800a3e:	75 10                	jne    800a50 <strtol+0x73>
  800a40:	80 3a 30             	cmpb   $0x30,(%edx)
  800a43:	75 05                	jne    800a4a <strtol+0x6d>
		s++, base = 8;
  800a45:	42                   	inc    %edx
  800a46:	b1 08                	mov    $0x8,%cl
  800a48:	eb 06                	jmp    800a50 <strtol+0x73>
	else if (base == 0)
  800a4a:	85 c9                	test   %ecx,%ecx
  800a4c:	75 02                	jne    800a50 <strtol+0x73>
		base = 10;
  800a4e:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a50:	8a 02                	mov    (%edx),%al
  800a52:	83 e8 30             	sub    $0x30,%eax
  800a55:	3c 09                	cmp    $0x9,%al
  800a57:	77 08                	ja     800a61 <strtol+0x84>
			dig = *s - '0';
  800a59:	0f be 02             	movsbl (%edx),%eax
  800a5c:	83 e8 30             	sub    $0x30,%eax
  800a5f:	eb 20                	jmp    800a81 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800a61:	8a 02                	mov    (%edx),%al
  800a63:	83 e8 61             	sub    $0x61,%eax
  800a66:	3c 19                	cmp    $0x19,%al
  800a68:	77 08                	ja     800a72 <strtol+0x95>
			dig = *s - 'a' + 10;
  800a6a:	0f be 02             	movsbl (%edx),%eax
  800a6d:	83 e8 57             	sub    $0x57,%eax
  800a70:	eb 0f                	jmp    800a81 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800a72:	8a 02                	mov    (%edx),%al
  800a74:	83 e8 41             	sub    $0x41,%eax
  800a77:	3c 19                	cmp    $0x19,%al
  800a79:	77 12                	ja     800a8d <strtol+0xb0>
			dig = *s - 'A' + 10;
  800a7b:	0f be 02             	movsbl (%edx),%eax
  800a7e:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a81:	39 c8                	cmp    %ecx,%eax
  800a83:	7d 08                	jge    800a8d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a85:	42                   	inc    %edx
  800a86:	0f af d9             	imul   %ecx,%ebx
  800a89:	01 c3                	add    %eax,%ebx
  800a8b:	eb c3                	jmp    800a50 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8d:	85 f6                	test   %esi,%esi
  800a8f:	74 02                	je     800a93 <strtol+0xb6>
		*endptr = (char *) s;
  800a91:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a93:	89 d8                	mov    %ebx,%eax
  800a95:	85 ff                	test   %edi,%edi
  800a97:	74 02                	je     800a9b <strtol+0xbe>
  800a99:	f7 d8                	neg    %eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 04             	sub    $0x4,%esp
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	89 f8                	mov    %edi,%eax
  800ab6:	89 fb                	mov    %edi,%ebx
  800ab8:	89 fe                	mov    %edi,%esi
  800aba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abc:	83 c4 04             	add    $0x4,%esp
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad4:	89 fa                	mov    %edi,%edx
  800ad6:	89 f9                	mov    %edi,%ecx
  800ad8:	89 fb                	mov    %edi,%ebx
  800ada:	89 fe                	mov    %edi,%esi
  800adc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aef:	b8 03 00 00 00       	mov    $0x3,%eax
  800af4:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	89 f9                	mov    %edi,%ecx
  800afb:	89 fb                	mov    %edi,%ebx
  800afd:	89 fe                	mov    %edi,%esi
  800aff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	7e 17                	jle    800b1c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	50                   	push   %eax
  800b09:	6a 03                	push   $0x3
  800b0b:	68 18 22 80 00       	push   $0x802218
  800b10:	6a 23                	push   $0x23
  800b12:	68 35 22 80 00       	push   $0x802235
  800b17:	e8 74 f6 ff ff       	call   800190 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	89 fa                	mov    %edi,%edx
  800b36:	89 f9                	mov    %edi,%ecx
  800b38:	89 fb                	mov    %edi,%ebx
  800b3a:	89 fe                	mov    %edi,%esi
  800b3c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sys_yield>:

void
sys_yield(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4e:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	89 fa                	mov    %edi,%edx
  800b55:	89 f9                	mov    %edi,%ecx
  800b57:	89 fb                	mov    %edi,%ebx
  800b59:	89 fe                	mov    %edi,%esi
  800b5b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b74:	b8 04 00 00 00       	mov    $0x4,%eax
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	89 fe                	mov    %edi,%esi
  800b80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 04                	push   $0x4
  800b8c:	68 18 22 80 00       	push   $0x802218
  800b91:	6a 23                	push   $0x23
  800b93:	68 35 22 80 00       	push   $0x802235
  800b98:	e8 f3 f5 ff ff       	call   800190 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bba:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bbd:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 05                	push   $0x5
  800bce:	68 18 22 80 00       	push   $0x802218
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 35 22 80 00       	push   $0x802235
  800bda:	e8 b1 f5 ff ff       	call   800190 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bf6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfb:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	89 fb                	mov    %edi,%ebx
  800c02:	89 fe                	mov    %edi,%esi
  800c04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 06                	push   $0x6
  800c10:	68 18 22 80 00       	push   $0x802218
  800c15:	6a 23                	push   $0x23
  800c17:	68 35 22 80 00       	push   $0x802235
  800c1c:	e8 6f f5 ff ff       	call   800190 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c38:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	89 fb                	mov    %edi,%ebx
  800c44:	89 fe                	mov    %edi,%esi
  800c46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 08                	push   $0x8
  800c52:	68 18 22 80 00       	push   $0x802218
  800c57:	6a 23                	push   $0x23
  800c59:	68 35 22 80 00       	push   $0x802235
  800c5e:	e8 2d f5 ff ff       	call   800190 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	89 fb                	mov    %edi,%ebx
  800c86:	89 fe                	mov    %edi,%esi
  800c88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 09                	push   $0x9
  800c94:	68 18 22 80 00       	push   $0x802218
  800c99:	6a 23                	push   $0x23
  800c9b:	68 35 22 80 00       	push   $0x802235
  800ca0:	e8 eb f4 ff ff       	call   800190 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc1:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	89 fb                	mov    %edi,%ebx
  800cc8:	89 fe                	mov    %edi,%esi
  800cca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 0a                	push   $0xa
  800cd6:	68 18 22 80 00       	push   $0x802218
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 35 22 80 00       	push   $0x802235
  800ce2:	e8 a9 f4 ff ff       	call   800190 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d06:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d1e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d23:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	89 f9                	mov    %edi,%ecx
  800d2a:	89 fb                	mov    %edi,%ebx
  800d2c:	89 fe                	mov    %edi,%esi
  800d2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 17                	jle    800d4b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 0d                	push   $0xd
  800d3a:	68 18 22 80 00       	push   $0x802218
  800d3f:	6a 23                	push   $0x23
  800d41:	68 35 22 80 00       	push   $0x802235
  800d46:	e8 45 f4 ff ff       	call   800190 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    
	...

00800d54 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d5f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d62:	c9                   	leave  
  800d63:	c3                   	ret    

00800d64 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d67:	ff 75 08             	pushl  0x8(%ebp)
  800d6a:	e8 e5 ff ff ff       	call   800d54 <fd2num>
  800d6f:	83 c4 04             	add    $0x4,%esp
  800d72:	c1 e0 0c             	shl    $0xc,%eax
  800d75:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  800d8f:	bb 00 00 40 ef       	mov    $0xef400000,%ebx
		fd = INDEX2FD(i);
  800d94:	89 c8                	mov    %ecx,%eax
  800d96:	c1 e0 0c             	shl    $0xc,%eax
  800d99:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9f:	89 d0                	mov    %edx,%eax
  800da1:	c1 e8 16             	shr    $0x16,%eax
  800da4:	8b 04 86             	mov    (%esi,%eax,4),%eax
  800da7:	a8 01                	test   $0x1,%al
  800da9:	74 0c                	je     800db7 <fd_alloc+0x3b>
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	c1 e8 0c             	shr    $0xc,%eax
  800db0:	8b 04 83             	mov    (%ebx,%eax,4),%eax
  800db3:	a8 01                	test   $0x1,%al
  800db5:	75 09                	jne    800dc0 <fd_alloc+0x44>
			*fd_store = fd;
  800db7:	89 17                	mov    %edx,(%edi)
			return 0;
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	eb 11                	jmp    800dd1 <fd_alloc+0x55>
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc0:	41                   	inc    %ecx
  800dc1:	83 f9 1f             	cmp    $0x1f,%ecx
  800dc4:	7e ce                	jle    800d94 <fd_alloc+0x18>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	return -E_MAX_OPEN;
  800dcc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800ddc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de1:	83 f8 1f             	cmp    $0x1f,%eax
  800de4:	77 3a                	ja     800e20 <fd_lookup+0x4a>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de6:	c1 e0 0c             	shl    $0xc,%eax
  800de9:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	///^&^ making sure fd page exists
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800def:	89 d0                	mov    %edx,%eax
  800df1:	c1 e8 16             	shr    $0x16,%eax
  800df4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dfb:	a8 01                	test   $0x1,%al
  800dfd:	74 10                	je     800e0f <fd_lookup+0x39>
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	c1 e8 0c             	shr    $0xc,%eax
  800e04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e0b:	a8 01                	test   $0x1,%al
  800e0d:	75 07                	jne    800e16 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800e0f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e14:	eb 0a                	jmp    800e20 <fd_lookup+0x4a>
	}
	*fd_store = fd;
  800e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e19:	89 10                	mov    %edx,(%eax)
	return 0;
  800e1b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800e20:	89 d0                	mov    %edx,%eax
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 10             	sub    $0x10,%esp
  800e2c:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e32:	50                   	push   %eax
  800e33:	56                   	push   %esi
  800e34:	e8 1b ff ff ff       	call   800d54 <fd2num>
  800e39:	89 04 24             	mov    %eax,(%esp)
  800e3c:	e8 95 ff ff ff       	call   800dd6 <fd_lookup>
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	83 c4 08             	add    $0x8,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 05                	js     800e4f <fd_close+0x2b>
  800e4a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e4d:	74 0f                	je     800e5e <fd_close+0x3a>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800e4f:	89 d8                	mov    %ebx,%eax
  800e51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e55:	75 45                	jne    800e9c <fd_close+0x78>
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	eb 3e                	jmp    800e9c <fd_close+0x78>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e5e:	83 ec 08             	sub    $0x8,%esp
  800e61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e64:	50                   	push   %eax
  800e65:	ff 36                	pushl  (%esi)
  800e67:	e8 37 00 00 00       	call   800ea3 <dev_lookup>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 1a                	js     800e8f <fd_close+0x6b>
		if (dev->dev_close)
  800e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e7d:	83 78 10 00          	cmpl   $0x0,0x10(%eax)
  800e81:	74 0c                	je     800e8f <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	56                   	push   %esi
  800e87:	ff 50 10             	call   *0x10(%eax)
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	56                   	push   %esi
  800e93:	6a 00                	push   $0x0
  800e95:	e8 4d fd ff ff       	call   800be7 <sys_page_unmap>
	return r;
  800e9a:	89 d8                	mov    %ebx,%eax
}
  800e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800eab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	for (i = 0; devtab[i]; i++)
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	83 3d 04 30 80 00 00 	cmpl   $0x0,0x803004
  800eba:	74 1c                	je     800ed8 <dev_lookup+0x35>
  800ebc:	b9 04 30 80 00       	mov    $0x803004,%ecx
		if (devtab[i]->dev_id == dev_id) {
  800ec1:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  800ec4:	39 18                	cmp    %ebx,(%eax)
  800ec6:	75 09                	jne    800ed1 <dev_lookup+0x2e>
			*dev = devtab[i];
  800ec8:	89 06                	mov    %eax,(%esi)
			return 0;
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	eb 29                	jmp    800efa <dev_lookup+0x57>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed1:	42                   	inc    %edx
  800ed2:	83 3c 91 00          	cmpl   $0x0,(%ecx,%edx,4)
  800ed6:	75 e9                	jne    800ec1 <dev_lookup+0x1e>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed8:	83 ec 04             	sub    $0x4,%esp
  800edb:	53                   	push   %ebx
  800edc:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee1:	8b 40 48             	mov    0x48(%eax),%eax
  800ee4:	50                   	push   %eax
  800ee5:	68 44 22 80 00       	push   $0x802244
  800eea:	e8 7d f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800eef:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return -E_INVAL;
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <close>:

int
close(int fdnum)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 08             	sub    $0x8,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f07:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 75 08             	pushl  0x8(%ebp)
  800f0e:	e8 c3 fe ff ff       	call   800dd6 <fd_lookup>
  800f13:	83 c4 08             	add    $0x8,%esp
		return r;
  800f16:	89 c2                	mov    %eax,%edx
close(int fdnum)
{
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 0f                	js     800f2b <close+0x2a>
		return r;
	else
		return fd_close(fd, 1);
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	6a 01                	push   $0x1
  800f21:	ff 75 fc             	pushl  -0x4(%ebp)
  800f24:	e8 fb fe ff ff       	call   800e24 <fd_close>
  800f29:	89 c2                	mov    %eax,%edx
}
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <close_all>:

void
close_all(void)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	53                   	push   %ebx
  800f3f:	e8 bd ff ff ff       	call   800f01 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	43                   	inc    %ebx
  800f48:	83 fb 1f             	cmp    $0x1f,%ebx
  800f4b:	7e ee                	jle    800f3b <close_all+0xc>
		close(i);
}
  800f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	ff 75 08             	pushl  0x8(%ebp)
  800f65:	e8 6c fe ff ff       	call   800dd6 <fd_lookup>
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	83 c4 08             	add    $0x8,%esp
  800f6f:	85 db                	test   %ebx,%ebx
  800f71:	0f 88 b7 00 00 00    	js     80102e <dup+0xdc>
		return r;
	close(newfdnum);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	57                   	push   %edi
  800f7b:	e8 81 ff ff ff       	call   800f01 <close>

	newfd = INDEX2FD(newfdnum);
  800f80:	89 f8                	mov    %edi,%eax
  800f82:	c1 e0 0c             	shl    $0xc,%eax
  800f85:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  800f8b:	ff 75 f0             	pushl  -0x10(%ebp)
  800f8e:	e8 d1 fd ff ff       	call   800d64 <fd2data>
  800f93:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f95:	89 34 24             	mov    %esi,(%esp)
  800f98:	e8 c7 fd ff ff       	call   800d64 <fd2data>
  800f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800fa0:	89 d8                	mov    %ebx,%eax
  800fa2:	c1 e8 16             	shr    $0x16,%eax
  800fa5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fac:	83 c4 14             	add    $0x14,%esp
  800faf:	a8 01                	test   $0x1,%al
  800fb1:	74 33                	je     800fe6 <dup+0x94>
  800fb3:	89 da                	mov    %ebx,%edx
  800fb5:	c1 ea 0c             	shr    $0xc,%edx
  800fb8:	b9 00 00 40 ef       	mov    $0xef400000,%ecx
  800fbd:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  800fc0:	a8 01                	test   $0x1,%al
  800fc2:	74 22                	je     800fe6 <dup+0x94>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  800fca:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcf:	50                   	push   %eax
  800fd0:	ff 75 ec             	pushl  -0x14(%ebp)
  800fd3:	6a 00                	push   $0x0
  800fd5:	53                   	push   %ebx
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 c8 fb ff ff       	call   800ba5 <sys_page_map>
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	83 c4 20             	add    $0x20,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 2e                	js     801014 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fec:	89 d0                	mov    %edx,%eax
  800fee:	c1 e8 0c             	shr    $0xc,%eax
  800ff1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	50                   	push   %eax
  800ffe:	56                   	push   %esi
  800fff:	6a 00                	push   $0x0
  801001:	52                   	push   %edx
  801002:	6a 00                	push   $0x0
  801004:	e8 9c fb ff ff       	call   800ba5 <sys_page_map>
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80100e:	89 f8                	mov    %edi,%eax
	nva = fd2data(newfd);

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801010:	85 db                	test   %ebx,%ebx
  801012:	79 1a                	jns    80102e <dup+0xdc>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 c8 fb ff ff       	call   800be7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80101f:	83 c4 08             	add    $0x8,%esp
  801022:	ff 75 ec             	pushl  -0x14(%ebp)
  801025:	6a 00                	push   $0x0
  801027:	e8 bb fb ff ff       	call   800be7 <sys_page_unmap>
	return r;
  80102c:	89 d8                	mov    %ebx,%eax
}
  80102e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	53                   	push   %ebx
  80103a:	83 ec 14             	sub    $0x14,%esp
  80103d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801040:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801043:	50                   	push   %eax
  801044:	53                   	push   %ebx
  801045:	e8 8c fd ff ff       	call   800dd6 <fd_lookup>
  80104a:	83 c4 08             	add    $0x8,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 18                	js     801069 <read+0x33>
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801057:	50                   	push   %eax
  801058:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80105b:	ff 30                	pushl  (%eax)
  80105d:	e8 41 fe ff ff       	call   800ea3 <dev_lookup>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	79 04                	jns    80106d <read+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  801069:	89 c2                	mov    %eax,%edx
  80106b:	eb 4e                	jmp    8010bb <read+0x85>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80106d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801070:	8b 40 08             	mov    0x8(%eax),%eax
  801073:	83 e0 03             	and    $0x3,%eax
  801076:	83 f8 01             	cmp    $0x1,%eax
  801079:	75 1e                	jne    801099 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80107b:	83 ec 04             	sub    $0x4,%esp
  80107e:	53                   	push   %ebx
  80107f:	a1 04 40 80 00       	mov    0x804004,%eax
  801084:	8b 40 48             	mov    0x48(%eax),%eax
  801087:	50                   	push   %eax
  801088:	68 85 22 80 00       	push   $0x802285
  80108d:	e8 da f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801092:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801097:	eb 22                	jmp    8010bb <read+0x85>
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801099:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80109e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a1:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8010a5:	74 14                	je     8010bb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	ff 75 10             	pushl  0x10(%ebp)
  8010ad:	ff 75 0c             	pushl  0xc(%ebp)
  8010b0:	ff 75 f8             	pushl  -0x8(%ebp)
  8010b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b6:	ff 50 08             	call   *0x8(%eax)
  8010b9:	89 c2                	mov    %eax,%edx
}
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d6:	39 f3                	cmp    %esi,%ebx
  8010d8:	73 25                	jae    8010ff <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	89 f0                	mov    %esi,%eax
  8010df:	29 d8                	sub    %ebx,%eax
  8010e1:	50                   	push   %eax
  8010e2:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
  8010e5:	50                   	push   %eax
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 48 ff ff ff       	call   801036 <read>
		if (m < 0)
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 0c                	js     801101 <readn+0x3f>
			return m;
		if (m == 0)
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	74 06                	je     8010ff <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f9:	01 c3                	add    %eax,%ebx
  8010fb:	39 f3                	cmp    %esi,%ebx
  8010fd:	72 db                	jb     8010da <readn+0x18>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8010ff:	89 d8                	mov    %ebx,%eax
}
  801101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	53                   	push   %ebx
  80110d:	83 ec 14             	sub    $0x14,%esp
  801110:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801113:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	53                   	push   %ebx
  801118:	e8 b9 fc ff ff       	call   800dd6 <fd_lookup>
  80111d:	83 c4 08             	add    $0x8,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 18                	js     80113c <write+0x33>
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80112e:	ff 30                	pushl  (%eax)
  801130:	e8 6e fd ff ff       	call   800ea3 <dev_lookup>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	79 04                	jns    801140 <write+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	eb 49                	jmp    801189 <write+0x80>
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801140:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801143:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801147:	75 1e                	jne    801167 <write+0x5e>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	53                   	push   %ebx
  80114d:	a1 04 40 80 00       	mov    0x804004,%eax
  801152:	8b 40 48             	mov    0x48(%eax),%eax
  801155:	50                   	push   %eax
  801156:	68 a1 22 80 00       	push   $0x8022a1
  80115b:	e8 0c f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801160:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801165:	eb 22                	jmp    801189 <write+0x80>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801167:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80116c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801173:	74 14                	je     801189 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	ff 75 10             	pushl  0x10(%ebp)
  80117b:	ff 75 0c             	pushl  0xc(%ebp)
  80117e:	ff 75 f8             	pushl  -0x8(%ebp)
  801181:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801184:	ff 50 0c             	call   *0xc(%eax)
  801187:	89 c2                	mov    %eax,%edx
}
  801189:	89 d0                	mov    %edx,%eax
  80118b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <seek>:

int
seek(int fdnum, off_t offset)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 04             	sub    $0x4,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801196:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	ff 75 08             	pushl  0x8(%ebp)
  80119d:	e8 34 fc ff ff       	call   800dd6 <fd_lookup>
  8011a2:	83 c4 08             	add    $0x8,%esp
		return r;
  8011a5:	89 c2                	mov    %eax,%edx
seek(int fdnum, off_t offset)
{
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 0e                	js     8011b9 <seek+0x29>
		return r;
	fd->fd_offset = offset;
  8011ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011b9:	89 d0                	mov    %edx,%eax
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	53                   	push   %ebx
  8011c1:	83 ec 14             	sub    $0x14,%esp
  8011c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c7:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011ca:	50                   	push   %eax
  8011cb:	53                   	push   %ebx
  8011cc:	e8 05 fc ff ff       	call   800dd6 <fd_lookup>
  8011d1:	83 c4 08             	add    $0x8,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 18                	js     8011f0 <ftruncate+0x33>
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011e2:	ff 30                	pushl  (%eax)
  8011e4:	e8 ba fc ff ff       	call   800ea3 <dev_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	79 04                	jns    8011f4 <ftruncate+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0) 
		return r;
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	eb 46                	jmp    80123a <ftruncate+0x7d>
	

	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fb:	75 1e                	jne    80121b <ftruncate+0x5e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	53                   	push   %ebx
  801201:	a1 04 40 80 00       	mov    0x804004,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	50                   	push   %eax
  80120a:	68 64 22 80 00       	push   $0x802264
  80120f:	e8 58 f0 ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801214:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801219:	eb 1f                	jmp    80123a <ftruncate+0x7d>
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80121b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801223:	83 78 18 00          	cmpl   $0x0,0x18(%eax)
  801227:	74 11                	je     80123a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	ff 75 0c             	pushl  0xc(%ebp)
  80122f:	ff 75 f8             	pushl  -0x8(%ebp)
  801232:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801235:	ff 50 18             	call   *0x18(%eax)
  801238:	89 c2                	mov    %eax,%edx
}
  80123a:	89 d0                	mov    %edx,%eax
  80123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	53                   	push   %ebx
  801245:	83 ec 14             	sub    $0x14,%esp
  801248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	ff 75 08             	pushl  0x8(%ebp)
  801252:	e8 7f fb ff ff       	call   800dd6 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 18                	js     801276 <fstat+0x35>
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 34 fc ff ff       	call   800ea3 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	79 04                	jns    80127a <fstat+0x39>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  801276:	89 c2                	mov    %eax,%edx
  801278:	eb 3a                	jmp    8012b4 <fstat+0x73>
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80127a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801282:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801286:	74 2c                	je     8012b4 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801288:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80128b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801292:	00 00 00 
	stat->st_isdir = 0;
  801295:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80129c:	00 00 00 
	stat->st_dev = dev;
  80129f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	ff 75 f8             	pushl  -0x8(%ebp)
  8012af:	ff 50 14             	call   *0x14(%eax)
  8012b2:	89 c2                	mov    %eax,%edx
}
  8012b4:	89 d0                	mov    %edx,%eax
  8012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	6a 00                	push   $0x0
  8012c5:	ff 75 08             	pushl  0x8(%ebp)
  8012c8:	e8 72 00 00 00       	call   80133f <open>
  8012cd:	89 c6                	mov    %eax,%esi
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 f6                	test   %esi,%esi
  8012d4:	78 18                	js     8012ee <stat+0x33>
		return fd;
	r = fstat(fd, stat);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 75 0c             	pushl  0xc(%ebp)
  8012dc:	56                   	push   %esi
  8012dd:	e8 5f ff ff ff       	call   801241 <fstat>
  8012e2:	89 c3                	mov    %eax,%ebx
	close(fd);
  8012e4:	89 34 24             	mov    %esi,(%esp)
  8012e7:	e8 15 fc ff ff       	call   800f01 <close>
	return r;
  8012ec:	89 d8                	mov    %ebx,%eax
}
  8012ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	c9                   	leave  
  8012f4:	c3                   	ret    
  8012f5:	00 00                	add    %al,(%eax)
	...

008012f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 08             	sub    $0x8,%esp
	static envid_t fsenv;
	if (fsenv == 0) {
  8012fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801305:	75 12                	jne    801319 <fsipc+0x21>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801307:	83 ec 0c             	sub    $0xc,%esp
  80130a:	6a 02                	push   $0x2
  80130c:	e8 f8 07 00 00       	call   801b09 <ipc_find_env>
  801311:	a3 00 40 80 00       	mov    %eax,0x804000
  801316:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801319:	6a 07                	push   $0x7
  80131b:	68 00 50 80 00       	push   $0x805000
  801320:	ff 75 08             	pushl  0x8(%ebp)
  801323:	ff 35 00 40 80 00    	pushl  0x804000
  801329:	e8 7a 07 00 00       	call   801aa8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80132e:	83 c4 0c             	add    $0xc,%esp
  801331:	6a 00                	push   $0x0
  801333:	ff 75 0c             	pushl  0xc(%ebp)
  801336:	6a 00                	push   $0x0
  801338:	e8 fb 06 00 00       	call   801a38 <ipc_recv>
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 1c             	sub    $0x1c,%esp
  801347:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  80134a:	56                   	push   %esi
  80134b:	e8 e4 f3 ff ff       	call   800734 <strlen>
  801350:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  801353:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  801358:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80135d:	7f 5f                	jg     8013be <open+0x7f>
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	e8 11 fa ff ff       	call   800d7c <fd_alloc>
  80136b:	83 c4 10             	add    $0x10,%esp
		return r;
  80136e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  801370:	85 c0                	test   %eax,%eax
  801372:	78 4a                	js     8013be <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	56                   	push   %esi
  801378:	68 00 50 80 00       	push   $0x805000
  80137d:	e8 ee f3 ff ff       	call   800770 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801382:	8b 45 0c             	mov    0xc(%ebp),%eax
  801385:	a3 00 54 80 00       	mov    %eax,0x805400


	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80138a:	83 c4 08             	add    $0x8,%esp
  80138d:	ff 75 f4             	pushl  -0xc(%ebp)
  801390:	6a 01                	push   $0x1
  801392:	e8 61 ff ff ff       	call   8012f8 <fsipc>
  801397:	89 c3                	mov    %eax,%ebx
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	85 c0                	test   %eax,%eax
  80139e:	79 11                	jns    8013b1 <open+0x72>
		fd_close(fd, 0);
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	6a 00                	push   $0x0
  8013a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a8:	e8 77 fa ff ff       	call   800e24 <fd_close>
		return r;
  8013ad:	89 da                	mov    %ebx,%edx
  8013af:	eb 0d                	jmp    8013be <open+0x7f>
	}
	
	return fd2num(fd);	
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b7:	e8 98 f9 ff ff       	call   800d54 <fd2num>
  8013bc:	89 c2                	mov    %eax,%edx
}
  8013be:	89 d0                	mov    %edx,%eax
  8013c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d8:	6a 00                	push   $0x0
  8013da:	6a 06                	push   $0x6
  8013dc:	e8 17 ff ff ff       	call   8012f8 <fsipc>
}
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 0c             	sub    $0xc,%esp
	// The bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f8:	a3 04 50 80 00       	mov    %eax,0x805004
		

	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013fd:	6a 00                	push   $0x0
  8013ff:	6a 03                	push   $0x3
  801401:	e8 f2 fe ff ff       	call   8012f8 <fsipc>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 db                	test   %ebx,%ebx
  80140d:	78 13                	js     801422 <devfile_read+0x3f>
		return r;

	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	53                   	push   %ebx
  801413:	68 00 50 80 00       	push   $0x805000
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	e8 ec f4 ff ff       	call   80090c <memmove>
	return r;
  801420:	89 d8                	mov    %ebx,%eax
}
  801422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	8b 45 10             	mov    0x10(%ebp),%eax
	// Be careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801430:	8b 55 08             	mov    0x8(%ebp),%edx
  801433:	8b 52 0c             	mov    0xc(%edx),%edx
  801436:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80143c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t))));
  801441:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801446:	76 05                	jbe    80144d <devfile_write+0x26>
  801448:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	50                   	push   %eax
  801451:	ff 75 0c             	pushl  0xc(%ebp)
  801454:	68 08 50 80 00       	push   $0x805008
  801459:	e8 ae f4 ff ff       	call   80090c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80145e:	83 c4 08             	add    $0x8,%esp
  801461:	6a 00                	push   $0x0
  801463:	6a 04                	push   $0x4
  801465:	e8 8e fe ff ff       	call   8012f8 <fsipc>
  80146a:	83 c4 10             	add    $0x10,%esp
		return r;
	return r;
}
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <devfile_stat>:

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	8b 40 0c             	mov    0xc(%eax),%eax
  80147f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801484:	6a 00                	push   $0x0
  801486:	6a 05                	push   $0x5
  801488:	e8 6b fe ff ff       	call   8012f8 <fsipc>
  80148d:	83 c4 10             	add    $0x10,%esp
		return r;
  801490:	89 c2                	mov    %eax,%edx
devfile_stat(struct Fd *fd, struct Stat *st)
{
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801492:	85 c0                	test   %eax,%eax
  801494:	78 29                	js     8014bf <devfile_stat+0x50>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	68 00 50 80 00       	push   $0x805000
  80149e:	53                   	push   %ebx
  80149f:	e8 cc f2 ff ff       	call   800770 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a4:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014af:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014bf:	89 d0                	mov    %edx,%eax
  8014c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <devfile_trunc>:

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014df:	6a 00                	push   $0x0
  8014e1:	6a 02                	push   $0x2
  8014e3:	e8 10 fe ff ff       	call   8012f8 <fsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <remove>:

// Delete a file
int
remove(const char *path)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 10             	sub    $0x10,%esp
  8014f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8014f4:	53                   	push   %ebx
  8014f5:	e8 3a f2 ff ff       	call   800734 <strlen>
  8014fa:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  8014fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
  801502:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801507:	7f 1c                	jg     801525 <remove+0x3b>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	53                   	push   %ebx
  80150d:	68 00 50 80 00       	push   $0x805000
  801512:	e8 59 f2 ff ff       	call   800770 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	6a 00                	push   $0x0
  80151c:	6a 07                	push   $0x7
  80151e:	e8 d5 fd ff ff       	call   8012f8 <fsipc>
  801523:	89 c2                	mov    %eax,%edx
}
  801525:	89 d0                	mov    %edx,%eax
  801527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 10             	sub    $0x10,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801532:	6a 00                	push   $0x0
  801534:	6a 08                	push   $0x8
  801536:	e8 bd fd ff ff       	call   8012f8 <fsipc>
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    
  80153d:	00 00                	add    %al,(%eax)
	...

00801540 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	57                   	push   %edi
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80154c:	6a 00                	push   $0x0
  80154e:	ff 75 08             	pushl  0x8(%ebp)
  801551:	e8 e9 fd ff ff       	call   80133f <open>
  801556:	89 c3                	mov    %eax,%ebx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	85 db                	test   %ebx,%ebx
  80155d:	0f 88 ca 01 00 00    	js     80172d <spawn+0x1ed>
		return r;
	fd = r;
  801563:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	68 00 02 00 00       	push   $0x200
  801571:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	53                   	push   %ebx
  801579:	e8 44 fb ff ff       	call   8010c2 <readn>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	3d 00 02 00 00       	cmp    $0x200,%eax
  801586:	75 0c                	jne    801594 <spawn+0x54>
  801588:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80158f:	45 4c 46 
  801592:	74 30                	je     8015c4 <spawn+0x84>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80159d:	e8 5f f9 ff ff       	call   800f01 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015a2:	83 c4 0c             	add    $0xc,%esp
  8015a5:	68 7f 45 4c 46       	push   $0x464c457f
  8015aa:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015b0:	68 be 22 80 00       	push   $0x8022be
  8015b5:	e8 b2 ec ff ff       	call   80026c <cprintf>
		return -E_NOT_EXEC;
  8015ba:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  8015bf:	e9 69 01 00 00       	jmp    80172d <spawn+0x1ed>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015c4:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  8015c9:	89 d0                	mov    %edx,%eax
  8015cb:	cd 30                	int    $0x30
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 db                	test   %ebx,%ebx
  8015d1:	0f 88 56 01 00 00    	js     80172d <spawn+0x1ed>
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
	child = r;
  8015d7:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8015dd:	89 da                	mov    %ebx,%edx
  8015df:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	c1 e0 05             	shl    $0x5,%eax
  8015ea:	29 d0                	sub    %edx,%eax
  8015ec:	8d 95 98 fd ff ff    	lea    -0x268(%ebp),%edx
  8015f2:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	6a 44                	push   $0x44
  8015fe:	50                   	push   %eax
  8015ff:	52                   	push   %edx
  801600:	e8 73 f3 ff ff       	call   800978 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801605:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80160b:	89 85 c8 fd ff ff    	mov    %eax,-0x238(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801611:	83 c4 0c             	add    $0xc,%esp
  801614:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	ff 75 0c             	pushl  0xc(%ebp)
  80161e:	53                   	push   %ebx
  80161f:	e8 8c 01 00 00       	call   8017b0 <init_stack>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 db                	test   %ebx,%ebx
  80162b:	0f 88 fc 00 00 00    	js     80172d <spawn+0x1ed>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801631:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801637:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80163e:	bf 00 00 00 00       	mov    $0x0,%edi
  801643:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  80164a:	00 
  80164b:	74 4f                	je     80169c <spawn+0x15c>
		if (ph->p_type != ELF_PROG_LOAD)
  80164d:	83 3e 01             	cmpl   $0x1,(%esi)
  801650:	75 3b                	jne    80168d <spawn+0x14d>
			continue;
		perm = PTE_P | PTE_U;
  801652:	b8 05 00 00 00       	mov    $0x5,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801657:	f6 46 18 02          	testb  $0x2,0x18(%esi)
  80165b:	74 02                	je     80165f <spawn+0x11f>
			perm |= PTE_W;
  80165d:	b0 07                	mov    $0x7,%al
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	50                   	push   %eax
  801663:	ff 76 04             	pushl  0x4(%esi)
  801666:	ff 76 10             	pushl  0x10(%esi)
  801669:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80166f:	ff 76 14             	pushl  0x14(%esi)
  801672:	ff 76 08             	pushl  0x8(%esi)
  801675:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80167b:	e8 9c 02 00 00       	call   80191c <map_segment>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	83 c4 20             	add    $0x20,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	0f 88 82 00 00 00    	js     80170f <spawn+0x1cf>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80168d:	47                   	inc    %edi
  80168e:	83 c6 20             	add    $0x20,%esi
  801691:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801698:	39 f8                	cmp    %edi,%eax
  80169a:	7f b1                	jg     80164d <spawn+0x10d>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8016a5:	e8 57 f8 ff ff       	call   800f01 <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	8d 85 98 fd ff ff    	lea    -0x268(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8016ba:	e8 ac f5 ff ff       	call   800c6b <sys_env_set_trapframe>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	79 15                	jns    8016db <spawn+0x19b>
		panic("sys_env_set_trapframe: %e", r);
  8016c6:	50                   	push   %eax
  8016c7:	68 d8 22 80 00       	push   $0x8022d8
  8016cc:	68 80 00 00 00       	push   $0x80
  8016d1:	68 f2 22 80 00       	push   $0x8022f2
  8016d6:	e8 b5 ea ff ff       	call   800190 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	6a 02                	push   $0x2
  8016e0:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8016e6:	e8 3e f5 ff ff       	call   800c29 <sys_env_set_status>
  8016eb:	89 c3                	mov    %eax,%ebx
  8016ed:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return child;
  8016f0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8016f6:	85 db                	test   %ebx,%ebx
  8016f8:	79 33                	jns    80172d <spawn+0x1ed>
		panic("sys_env_set_status: %e", r);
  8016fa:	53                   	push   %ebx
  8016fb:	68 fe 22 80 00       	push   $0x8022fe
  801700:	68 83 00 00 00       	push   $0x83
  801705:	68 f2 22 80 00       	push   $0x8022f2
  80170a:	e8 81 ea ff ff       	call   800190 <_panic>

	return child;

error:
	sys_env_destroy(child);
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801718:	e8 c6 f3 ff ff       	call   800ae3 <sys_env_destroy>
	close(fd);
  80171d:	83 c4 04             	add    $0x4,%esp
  801720:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801726:	e8 d6 f7 ff ff       	call   800f01 <close>
	return r;
  80172b:	89 d8                	mov    %ebx,%eax
}
  80172d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801730:	5b                   	pop    %ebx
  801731:	5e                   	pop    %esi
  801732:	5f                   	pop    %edi
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	57                   	push   %edi
  801739:	56                   	push   %esi
  80173a:	53                   	push   %ebx
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	89 e7                	mov    %esp,%edi
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801740:	be 00 00 00 00       	mov    $0x0,%esi
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801745:	8d 45 10             	lea    0x10(%ebp),%eax
  801748:	8d 50 04             	lea    0x4(%eax),%edx
  80174b:	83 38 00             	cmpl   $0x0,(%eax)
  80174e:	74 0b                	je     80175b <spawnl+0x26>
  801750:	46                   	inc    %esi
  801751:	89 d0                	mov    %edx,%eax
  801753:	8d 52 04             	lea    0x4(%edx),%edx
  801756:	83 38 00             	cmpl   $0x0,(%eax)
  801759:	75 f5                	jne    801750 <spawnl+0x1b>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80175b:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  801762:	83 e0 f0             	and    $0xfffffff0,%eax
  801765:	29 c4                	sub    %eax,%esp
  801767:	8d 44 24 0f          	lea    0xf(%esp),%eax
  80176b:	89 c3                	mov    %eax,%ebx
  80176d:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  801770:	8b 45 0c             	mov    0xc(%ebp),%eax
  801773:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  801775:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  80177c:	00 

	va_start(vl, arg0);
  80177d:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801780:	b9 00 00 00 00       	mov    $0x0,%ecx
  801785:	83 fe 00             	cmp    $0x0,%esi
  801788:	76 10                	jbe    80179a <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  80178a:	89 d0                	mov    %edx,%eax
  80178c:	8d 52 04             	lea    0x4(%edx),%edx
  80178f:	8b 00                	mov    (%eax),%eax
  801791:	89 44 8b 04          	mov    %eax,0x4(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801795:	41                   	inc    %ecx
  801796:	39 ce                	cmp    %ecx,%esi
  801798:	77 f0                	ja     80178a <spawnl+0x55>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	53                   	push   %ebx
  80179e:	ff 75 08             	pushl  0x8(%ebp)
  8017a1:	e8 9a fd ff ff       	call   801540 <spawn>
  8017a6:	89 fc                	mov    %edi,%esp
}
  8017a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5f                   	pop    %edi
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	57                   	push   %edi
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 0c             	sub    $0xc,%esp
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8017b9:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  8017be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8017c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c8:	83 38 00             	cmpl   $0x0,(%eax)
  8017cb:	74 27                	je     8017f4 <init_stack+0x44>
		string_size += strlen(argv[argc]) + 1;
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	ff 34 90             	pushl  (%eax,%edx,4)
  8017d9:	e8 56 ef ff ff       	call   800734 <strlen>
  8017de:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	ff 45 f0             	incl   -0x10(%ebp)
  8017e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ee:	83 3c 90 00          	cmpl   $0x0,(%eax,%edx,4)
  8017f2:	75 d9                	jne    8017cd <init_stack+0x1d>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017f4:	b8 00 10 40 00       	mov    $0x401000,%eax
  8017f9:	89 c7                	mov    %eax,%edi
  8017fb:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8017fd:	89 fa                	mov    %edi,%edx
  8017ff:	83 e2 fc             	and    $0xfffffffc,%edx
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	c1 e0 02             	shl    $0x2,%eax
  801808:	89 d6                	mov    %edx,%esi
  80180a:	29 c6                	sub    %eax,%esi
  80180c:	83 ee 04             	sub    $0x4,%esi

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80180f:	8d 46 f8             	lea    -0x8(%esi),%eax
		return -E_NO_MEM;
  801812:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801817:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80181c:	0f 86 f0 00 00 00    	jbe    801912 <init_stack+0x162>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801822:	83 ec 04             	sub    $0x4,%esp
  801825:	6a 07                	push   $0x7
  801827:	68 00 00 40 00       	push   $0x400000
  80182c:	6a 00                	push   $0x0
  80182e:	e8 2f f3 ff ff       	call   800b62 <sys_page_alloc>
  801833:	83 c4 10             	add    $0x10,%esp
		return r;
  801836:	89 c2                	mov    %eax,%edx
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 88 d2 00 00 00    	js     801912 <init_stack+0x162>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801840:	bb 00 00 00 00       	mov    $0x0,%ebx
  801845:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
  801848:	7d 33                	jge    80187d <init_stack+0xcd>
		argv_store[i] = UTEMP2USTACK(string_store);
  80184a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801850:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
		strcpy(string_store, argv[i]);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	8b 55 0c             	mov    0xc(%ebp),%edx
  801859:	ff 34 9a             	pushl  (%edx,%ebx,4)
  80185c:	57                   	push   %edi
  80185d:	e8 0e ef ff ff       	call   800770 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801862:	83 c4 04             	add    $0x4,%esp
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	ff 34 98             	pushl  (%eax,%ebx,4)
  80186b:	e8 c4 ee ff ff       	call   800734 <strlen>
  801870:	8d 7c 38 01          	lea    0x1(%eax,%edi,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	43                   	inc    %ebx
  801878:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
  80187b:	7c cd                	jl     80184a <init_stack+0x9a>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80187d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801880:	c7 04 96 00 00 00 00 	movl   $0x0,(%esi,%edx,4)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801887:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80188d:	74 19                	je     8018a8 <init_stack+0xf8>
  80188f:	68 48 23 80 00       	push   $0x802348
  801894:	68 15 23 80 00       	push   $0x802315
  801899:	68 ec 00 00 00       	push   $0xec
  80189e:	68 f2 22 80 00       	push   $0x8022f2
  8018a3:	e8 e8 e8 ff ff       	call   800190 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8018a8:	8d 86 00 d0 7f ee    	lea    -0x11803000(%esi),%eax
  8018ae:	89 46 fc             	mov    %eax,-0x4(%esi)
	argv_store[-2] = argc;
  8018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b4:	89 46 f8             	mov    %eax,-0x8(%esi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8018b7:	8d 96 f8 cf 7f ee    	lea    -0x11803008(%esi),%edx
  8018bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c0:	89 10                	mov    %edx,(%eax)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	6a 07                	push   $0x7
  8018c7:	68 00 d0 bf ee       	push   $0xeebfd000
  8018cc:	ff 75 08             	pushl  0x8(%ebp)
  8018cf:	68 00 00 40 00       	push   $0x400000
  8018d4:	6a 00                	push   $0x0
  8018d6:	e8 ca f2 ff ff       	call   800ba5 <sys_page_map>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	83 c4 20             	add    $0x20,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 1d                	js     801901 <init_stack+0x151>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	68 00 00 40 00       	push   $0x400000
  8018ec:	6a 00                	push   $0x0
  8018ee:	e8 f4 f2 ff ff       	call   800be7 <sys_page_unmap>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	83 c4 10             	add    $0x10,%esp
		goto error;

	return 0;
  8018f8:	ba 00 00 00 00       	mov    $0x0,%edx

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	79 11                	jns    801912 <init_stack+0x162>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801901:	83 ec 08             	sub    $0x8,%esp
  801904:	68 00 00 40 00       	push   $0x400000
  801909:	6a 00                	push   $0x0
  80190b:	e8 d7 f2 ff ff       	call   800be7 <sys_page_unmap>
	return r;
  801910:	89 da                	mov    %ebx,%edx
}
  801912:	89 d0                	mov    %edx,%eax
  801914:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5f                   	pop    %edi
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <map_segment>:

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801928:	8b 75 18             	mov    0x18(%ebp),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80192b:	89 fb                	mov    %edi,%ebx
  80192d:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  801933:	74 0a                	je     80193f <map_segment+0x23>
		va -= i;
  801935:	29 df                	sub    %ebx,%edi
		memsz += i;
  801937:	01 5d 10             	add    %ebx,0x10(%ebp)
		filesz += i;
  80193a:	01 de                	add    %ebx,%esi
		fileoffset -= i;
  80193c:	29 5d 1c             	sub    %ebx,0x1c(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80193f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801944:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801947:	0f 83 db 00 00 00    	jae    801a28 <map_segment+0x10c>
		if (i >= filesz) {
  80194d:	39 f3                	cmp    %esi,%ebx
  80194f:	72 22                	jb     801973 <map_segment+0x57>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801951:	83 ec 04             	sub    $0x4,%esp
  801954:	ff 75 20             	pushl  0x20(%ebp)
  801957:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
  80195a:	50                   	push   %eax
  80195b:	ff 75 08             	pushl  0x8(%ebp)
  80195e:	e8 ff f1 ff ff       	call   800b62 <sys_page_alloc>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	0f 89 ab 00 00 00    	jns    801a19 <map_segment+0xfd>
				return r;
  80196e:	e9 ba 00 00 00       	jmp    801a2d <map_segment+0x111>
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	6a 07                	push   $0x7
  801978:	68 00 00 40 00       	push   $0x400000
  80197d:	6a 00                	push   $0x0
  80197f:	e8 de f1 ff ff       	call   800b62 <sys_page_alloc>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 9e 00 00 00    	js     801a2d <map_segment+0x111>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	8b 45 1c             	mov    0x1c(%ebp),%eax
  801995:	01 d8                	add    %ebx,%eax
  801997:	50                   	push   %eax
  801998:	ff 75 14             	pushl  0x14(%ebp)
  80199b:	e8 f0 f7 ff ff       	call   801190 <seek>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	0f 88 82 00 00 00    	js     801a2d <map_segment+0x111>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019ab:	89 f2                	mov    %esi,%edx
  8019ad:	29 da                	sub    %ebx,%edx
  8019af:	b8 00 10 00 00       	mov    $0x1000,%eax
  8019b4:	39 d0                	cmp    %edx,%eax
  8019b6:	76 02                	jbe    8019ba <map_segment+0x9e>
  8019b8:	89 d0                	mov    %edx,%eax
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	50                   	push   %eax
  8019be:	68 00 00 40 00       	push   $0x400000
  8019c3:	ff 75 14             	pushl  0x14(%ebp)
  8019c6:	e8 f7 f6 ff ff       	call   8010c2 <readn>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 5b                	js     801a2d <map_segment+0x111>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	ff 75 20             	pushl  0x20(%ebp)
  8019d8:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
  8019db:	50                   	push   %eax
  8019dc:	ff 75 08             	pushl  0x8(%ebp)
  8019df:	68 00 00 40 00       	push   $0x400000
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 ba f1 ff ff       	call   800ba5 <sys_page_map>
  8019eb:	83 c4 20             	add    $0x20,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	79 15                	jns    801a07 <map_segment+0xeb>
				panic("spawn: sys_page_map data: %e", r);
  8019f2:	50                   	push   %eax
  8019f3:	68 2a 23 80 00       	push   $0x80232a
  8019f8:	68 1f 01 00 00       	push   $0x11f
  8019fd:	68 f2 22 80 00       	push   $0x8022f2
  801a02:	e8 89 e7 ff ff       	call   800190 <_panic>
			sys_page_unmap(0, UTEMP);
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	68 00 00 40 00       	push   $0x400000
  801a0f:	6a 00                	push   $0x0
  801a11:	e8 d1 f1 ff ff       	call   800be7 <sys_page_unmap>
  801a16:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a1f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a22:	0f 82 25 ff ff ff    	jb     80194d <map_segment+0x31>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5f                   	pop    %edi
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    
  801a35:	00 00                	add    %al,(%eax)
	...

00801a38 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a43:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  801a46:	85 c0                	test   %eax,%eax
  801a48:	75 05                	jne    801a4f <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  801a4a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	50                   	push   %eax
  801a53:	e8 ba f2 ff ff       	call   800d12 <sys_ipc_recv>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	79 16                	jns    801a75 <ipc_recv+0x3d>
		if (from_env_store)
  801a5f:	85 db                	test   %ebx,%ebx
  801a61:	74 06                	je     801a69 <ipc_recv+0x31>
			*from_env_store = 0;
  801a63:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  801a69:	85 f6                	test   %esi,%esi
  801a6b:	74 34                	je     801aa1 <ipc_recv+0x69>
			*perm_store = 0;
  801a6d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  801a73:	eb 2c                	jmp    801aa1 <ipc_recv+0x69>
	}

	if (from_env_store)
  801a75:	85 db                	test   %ebx,%ebx
  801a77:	74 0a                	je     801a83 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801a79:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7e:	8b 40 74             	mov    0x74(%eax),%eax
  801a81:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  801a83:	85 f6                	test   %esi,%esi
  801a85:	74 12                	je     801a99 <ipc_recv+0x61>
  801a87:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a8d:	8b 42 78             	mov    0x78(%edx),%eax
  801a90:	85 c0                	test   %eax,%eax
  801a92:	74 05                	je     801a99 <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  801a94:	8b 42 78             	mov    0x78(%edx),%eax
  801a97:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  801a99:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801aa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  801aba:	85 db                	test   %ebx,%ebx
  801abc:	74 10                	je     801ace <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  801abe:	ff 75 14             	pushl  0x14(%ebp)
  801ac1:	53                   	push   %ebx
  801ac2:	56                   	push   %esi
  801ac3:	57                   	push   %edi
  801ac4:	e8 26 f2 ff ff       	call   800cef <sys_ipc_try_send>
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	eb 11                	jmp    801adf <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  801ace:	6a 00                	push   $0x0
  801ad0:	68 00 00 c0 ee       	push   $0xeec00000
  801ad5:	56                   	push   %esi
  801ad6:	57                   	push   %edi
  801ad7:	e8 13 f2 ff ff       	call   800cef <sys_ipc_try_send>
  801adc:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	74 1e                	je     801b01 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  801ae3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae6:	74 12                	je     801afa <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  801ae8:	50                   	push   %eax
  801ae9:	68 70 23 80 00       	push   $0x802370
  801aee:	6a 4a                	push   $0x4a
  801af0:	68 94 23 80 00       	push   $0x802394
  801af5:	e8 96 e6 ff ff       	call   800190 <_panic>
		}
		sys_yield();
  801afa:	e8 44 f0 ff ff       	call   800b43 <sys_yield>
  801aff:	eb b9                	jmp    801aba <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  801b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5f                   	pop    %edi
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	53                   	push   %ebx
  801b0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801b10:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  801b15:	89 d0                	mov    %edx,%eax
  801b17:	c1 e0 05             	shl    $0x5,%eax
  801b1a:	29 d0                	sub    %edx,%eax
  801b1c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b23:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  801b29:	8b 40 50             	mov    0x50(%eax),%eax
  801b2c:	39 d8                	cmp    %ebx,%eax
  801b2e:	75 0b                	jne    801b3b <ipc_find_env+0x32>
			return envs[i].env_id;
  801b30:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  801b36:	8b 40 40             	mov    0x40(%eax),%eax
  801b39:	eb 0e                	jmp    801b49 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b3b:	42                   	inc    %edx
  801b3c:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801b42:	7e d1                	jle    801b15 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b49:	5b                   	pop    %ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	57                   	push   %edi
  801b50:	56                   	push   %esi
  801b51:	83 ec 14             	sub    $0x14,%esp
  801b54:	8b 55 14             	mov    0x14(%ebp),%edx
  801b57:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b5d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b60:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801b62:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801b65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  801b68:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  801b6b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b6d:	75 11                	jne    801b80 <__udivdi3+0x34>
    {
      if (d0 > n1)
  801b6f:	39 f8                	cmp    %edi,%eax
  801b71:	76 4d                	jbe    801bc0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b73:	89 fa                	mov    %edi,%edx
  801b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b78:	f7 75 e4             	divl   -0x1c(%ebp)
  801b7b:	89 c7                	mov    %eax,%edi
  801b7d:	eb 09                	jmp    801b88 <__udivdi3+0x3c>
  801b7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b80:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  801b83:	76 17                	jbe    801b9c <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  801b85:	31 ff                	xor    %edi,%edi
  801b87:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  801b88:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b8f:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b92:	83 c4 14             	add    $0x14,%esp
  801b95:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b96:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b98:	5f                   	pop    %edi
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    
  801b9b:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b9c:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  801ba0:	89 c7                	mov    %eax,%edi
  801ba2:	83 f7 1f             	xor    $0x1f,%edi
  801ba5:	75 4d                	jne    801bf4 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ba7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801baa:	77 0a                	ja     801bb6 <__udivdi3+0x6a>
  801bac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  801baf:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bb1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801bb4:	72 d2                	jb     801b88 <__udivdi3+0x3c>
		{
		  q0 = 1;
  801bb6:	bf 01 00 00 00       	mov    $0x1,%edi
  801bbb:	eb cb                	jmp    801b88 <__udivdi3+0x3c>
  801bbd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	75 0e                	jne    801bd5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcc:	31 c9                	xor    %ecx,%ecx
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bd5:	89 f0                	mov    %esi,%eax
  801bd7:	31 d2                	xor    %edx,%edx
  801bd9:	f7 75 e4             	divl   -0x1c(%ebp)
  801bdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be2:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801be5:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801be8:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801beb:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bed:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bee:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf0:	5f                   	pop    %edi
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    
  801bf3:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801bf4:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf9:	29 f8                	sub    %edi,%eax
  801bfb:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801bfe:	89 f9                	mov    %edi,%ecx
  801c00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c03:	d3 e2                	shl    %cl,%edx
  801c05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c08:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801c0b:	d3 e8                	shr    %cl,%eax
  801c0d:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  801c0f:	89 f9                	mov    %edi,%ecx
  801c11:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c14:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801c17:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801c1a:	89 f2                	mov    %esi,%edx
  801c1c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801c1e:	89 f9                	mov    %edi,%ecx
  801c20:	d3 e6                	shl    %cl,%esi
  801c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c25:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801c28:	d3 e8                	shr    %cl,%eax
  801c2a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  801c2c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c2e:	89 f0                	mov    %esi,%eax
  801c30:	f7 75 f4             	divl   -0xc(%ebp)
  801c33:	89 d6                	mov    %edx,%esi
  801c35:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c37:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801c3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c3f:	39 f2                	cmp    %esi,%edx
  801c41:	77 0f                	ja     801c52 <__udivdi3+0x106>
  801c43:	0f 85 3f ff ff ff    	jne    801b88 <__udivdi3+0x3c>
  801c49:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801c4c:	0f 86 36 ff ff ff    	jbe    801b88 <__udivdi3+0x3c>
		{
		  q0--;
  801c52:	4f                   	dec    %edi
  801c53:	e9 30 ff ff ff       	jmp    801b88 <__udivdi3+0x3c>

00801c58 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	57                   	push   %edi
  801c5c:	56                   	push   %esi
  801c5d:	83 ec 30             	sub    $0x30,%esp
  801c60:	8b 55 14             	mov    0x14(%ebp),%edx
  801c63:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  801c66:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  801c68:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801c6b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  801c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c73:	85 ff                	test   %edi,%edi
  801c75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801c7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  801c83:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c86:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  801c89:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c8c:	75 3e                	jne    801ccc <__umoddi3+0x74>
    {
      if (d0 > n1)
  801c8e:	39 d6                	cmp    %edx,%esi
  801c90:	0f 86 a2 00 00 00    	jbe    801d38 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c96:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801c98:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801c9b:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c9d:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801ca0:	74 1b                	je     801cbd <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  801ca2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ca5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  801ca8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801cb5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801cb8:	89 10                	mov    %edx,(%eax)
  801cba:	89 48 04             	mov    %ecx,0x4(%eax)
  801cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cc3:	83 c4 30             	add    $0x30,%esp
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    
  801cca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ccc:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  801ccf:	76 1f                	jbe    801cf0 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801cd1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  801cd4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801cd7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  801cda:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ce0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801ce6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ce9:	83 c4 30             	add    $0x30,%esp
  801cec:	5e                   	pop    %esi
  801ced:	5f                   	pop    %edi
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cf0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cf3:	83 f0 1f             	xor    $0x1f,%eax
  801cf6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801cf9:	75 61                	jne    801d5c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cfb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  801cfe:	77 05                	ja     801d05 <__umoddi3+0xad>
  801d00:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  801d03:	72 10                	jb     801d15 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d05:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801d08:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d0b:	29 f0                	sub    %esi,%eax
  801d0d:	19 fa                	sbb    %edi,%edx
  801d0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801d12:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  801d15:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801d18:	85 d2                	test   %edx,%edx
  801d1a:	74 a1                	je     801cbd <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801d1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  801d1f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801d22:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  801d25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801d28:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801d2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d31:	89 01                	mov    %eax,(%ecx)
  801d33:	89 51 04             	mov    %edx,0x4(%ecx)
  801d36:	eb 85                	jmp    801cbd <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d38:	85 f6                	test   %esi,%esi
  801d3a:	75 0b                	jne    801d47 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d41:	31 d2                	xor    %edx,%edx
  801d43:	f7 f6                	div    %esi
  801d45:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d47:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d4a:	89 fa                	mov    %edi,%edx
  801d4c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d51:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d54:	f7 f6                	div    %esi
  801d56:	e9 3d ff ff ff       	jmp    801c98 <__umoddi3+0x40>
  801d5b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d5c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d61:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  801d64:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d67:	89 fa                	mov    %edi,%edx
  801d69:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801d6c:	d3 e2                	shl    %cl,%edx
  801d6e:	89 f0                	mov    %esi,%eax
  801d70:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801d73:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  801d75:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801d78:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d7a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d7c:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801d7f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d82:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d84:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801d86:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d89:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801d91:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801d94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	0b 45 cc             	or     -0x34(%ebp),%eax
  801d9c:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  801d9f:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801da2:	f7 f7                	div    %edi
  801da4:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801da7:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801daa:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dac:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801daf:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801db2:	77 0a                	ja     801dbe <__umoddi3+0x166>
  801db4:	75 12                	jne    801dc8 <__umoddi3+0x170>
  801db6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801db9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801dbc:	76 0a                	jbe    801dc8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dbe:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801dc1:	29 f1                	sub    %esi,%ecx
  801dc3:	19 fa                	sbb    %edi,%edx
  801dc5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	0f 84 ea fe ff ff    	je     801cbd <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801dd3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801dd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801dd9:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801ddc:	19 d1                	sbb    %edx,%ecx
  801dde:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801de1:	89 ca                	mov    %ecx,%edx
  801de3:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801de6:	d3 e2                	shl    %cl,%edx
  801de8:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801deb:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dee:	d3 e8                	shr    %cl,%eax
  801df0:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  801df2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801df5:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801df7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801dfd:	e9 ad fe ff ff       	jmp    801caf <__umoddi3+0x57>
