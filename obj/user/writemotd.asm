
obj/user/writemotd.debug:     file format elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 24 02 00 00    	sub    $0x224,%esp
	int rfd, wfd;
	char buf[512];
	int n, r;

	if ((rfd = open("/newmotd", O_RDONLY)) < 0)
  800040:	6a 00                	push   $0x0
  800042:	68 c0 19 80 00       	push   $0x8019c0
  800047:	e8 93 13 00 00       	call   8013df <open>
  80004c:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  800052:	83 c4 10             	add    $0x10,%esp
  800055:	85 c0                	test   %eax,%eax
  800057:	79 12                	jns    80006b <umain+0x37>
		panic("open /newmotd: %e", rfd);
  800059:	50                   	push   %eax
  80005a:	68 c9 19 80 00       	push   $0x8019c9
  80005f:	6a 0b                	push   $0xb
  800061:	68 db 19 80 00       	push   $0x8019db
  800066:	e8 c5 01 00 00       	call   800230 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	6a 02                	push   $0x2
  800070:	68 ec 19 80 00       	push   $0x8019ec
  800075:	e8 65 13 00 00       	call   8013df <open>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 12                	jns    800095 <umain+0x61>
		panic("open /motd: %e", wfd);
  800083:	50                   	push   %eax
  800084:	68 f2 19 80 00       	push   $0x8019f2
  800089:	6a 0d                	push   $0xd
  80008b:	68 db 19 80 00       	push   $0x8019db
  800090:	e8 9b 01 00 00       	call   800230 <_panic>

	if (rfd == wfd)
  800095:	39 85 e4 fd ff ff    	cmp    %eax,-0x21c(%ebp)
  80009b:	75 14                	jne    8000b1 <umain+0x7d>
		panic("open /newmotd and /motd give same file descriptor");
  80009d:	83 ec 04             	sub    $0x4,%esp
  8000a0:	68 54 1a 80 00       	push   $0x801a54
  8000a5:	6a 10                	push   $0x10
  8000a7:	68 db 19 80 00       	push   $0x8019db
  8000ac:	e8 7f 01 00 00       	call   800230 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 01 1a 80 00       	push   $0x801a01
  8000b9:	e8 4e 02 00 00       	call   80030c <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  8000c7:	eb 0d                	jmp    8000d6 <umain+0xa2>
		sys_cputs(buf, n);
  8000c9:	83 ec 08             	sub    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	56                   	push   %esi
  8000ce:	e8 6d 0a 00 00       	call   800b40 <sys_cputs>
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	68 ff 01 00 00       	push   $0x1ff
  8000de:	56                   	push   %esi
  8000df:	57                   	push   %edi
  8000e0:	e8 f1 0f 00 00       	call   8010d6 <read>
  8000e5:	89 c3                	mov    %eax,%ebx
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	7f db                	jg     8000c9 <umain+0x95>
	cprintf("===\n");
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	68 0a 1a 80 00       	push   $0x801a0a
  8000f6:	e8 11 02 00 00       	call   80030c <cprintf>
	seek(wfd, 0);
  8000fb:	83 c4 08             	add    $0x8,%esp
  8000fe:	6a 00                	push   $0x0
  800100:	57                   	push   %edi
  800101:	e8 2a 11 00 00       	call   801230 <seek>

	//DEBUG reaches here.

	if ((r = ftruncate(wfd, 0)) < 0)
  800106:	83 c4 08             	add    $0x8,%esp
  800109:	6a 00                	push   $0x0
  80010b:	57                   	push   %edi
  80010c:	e8 4c 11 00 00       	call   80125d <ftruncate>
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	85 c0                	test   %eax,%eax
  800116:	79 12                	jns    80012a <umain+0xf6>
		panic("truncate /motd: %e", r);
  800118:	50                   	push   %eax
  800119:	68 0f 1a 80 00       	push   $0x801a0f
  80011e:	6a 1b                	push   $0x1b
  800120:	68 db 19 80 00       	push   $0x8019db
  800125:	e8 06 01 00 00       	call   800230 <_panic>

	cprintf("NEW MOTD\n===\n");
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	68 22 1a 80 00       	push   $0x801a22
  800132:	e8 d5 01 00 00       	call   80030c <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  800140:	eb 2e                	jmp    800170 <umain+0x13c>
		sys_cputs(buf, n);
  800142:	83 ec 08             	sub    $0x8,%esp
  800145:	53                   	push   %ebx
  800146:	56                   	push   %esi
  800147:	e8 f4 09 00 00       	call   800b40 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80014c:	83 c4 0c             	add    $0xc,%esp
  80014f:	53                   	push   %ebx
  800150:	56                   	push   %esi
  800151:	57                   	push   %edi
  800152:	e8 52 10 00 00       	call   8011a9 <write>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	39 d8                	cmp    %ebx,%eax
  80015c:	74 12                	je     800170 <umain+0x13c>
			panic("write /motd: %e", r);
  80015e:	50                   	push   %eax
  80015f:	68 30 1a 80 00       	push   $0x801a30
  800164:	6a 21                	push   $0x21
  800166:	68 db 19 80 00       	push   $0x8019db
  80016b:	e8 c0 00 00 00       	call   800230 <_panic>
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	68 ff 01 00 00       	push   $0x1ff
  800178:	56                   	push   %esi
  800179:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  80017f:	e8 52 0f 00 00       	call   8010d6 <read>
  800184:	89 c3                	mov    %eax,%ebx
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	85 c0                	test   %eax,%eax
  80018b:	7f b5                	jg     800142 <umain+0x10e>
	}
	cprintf("===\n");
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	68 0a 1a 80 00       	push   $0x801a0a
  800195:	e8 72 01 00 00       	call   80030c <cprintf>

	if (n < 0)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	85 db                	test   %ebx,%ebx
  80019f:	79 12                	jns    8001b3 <umain+0x17f>
		panic("read /newmotd: %e", n);
  8001a1:	53                   	push   %ebx
  8001a2:	68 40 1a 80 00       	push   $0x801a40
  8001a7:	6a 26                	push   $0x26
  8001a9:	68 db 19 80 00       	push   $0x8019db
  8001ae:	e8 7d 00 00 00       	call   800230 <_panic>

	close(rfd);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  8001bc:	e8 e0 0d 00 00       	call   800fa1 <close>
	close(wfd);
  8001c1:	89 3c 24             	mov    %edi,(%esp)
  8001c4:	e8 d8 0d 00 00       	call   800fa1 <close>
}
  8001c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    
  8001d1:	00 00                	add    %al,(%eax)
	...

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  8001df:	e8 e0 09 00 00       	call   800bc4 <sys_getenvid>
  8001e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e9:	89 c2                	mov    %eax,%edx
  8001eb:	c1 e2 05             	shl    $0x5,%edx
  8001ee:	29 c2                	sub    %eax,%edx
  8001f0:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  8001f7:	89 15 04 30 80 00    	mov    %edx,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 f6                	test   %esi,%esi
  8001ff:	7e 07                	jle    800208 <libmain+0x34>
		binaryname = argv[0];
  800201:	8b 03                	mov    (%ebx),%eax
  800203:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	53                   	push   %ebx
  80020c:	56                   	push   %esi
  80020d:	e8 22 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800212:	e8 09 00 00 00       	call   800220 <exit>
}
  800217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    
	...

00800220 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800226:	6a 00                	push   $0x0
  800228:	e8 56 09 00 00       	call   800b83 <sys_env_destroy>
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    
	...

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	53                   	push   %ebx
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	ff 35 00 20 80 00    	pushl  0x802000
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	e8 76 09 00 00       	call   800bc4 <sys_getenvid>
  80024e:	83 c4 08             	add    $0x8,%esp
  800251:	50                   	push   %eax
  800252:	68 90 1a 80 00       	push   $0x801a90
  800257:	e8 b0 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025c:	83 c4 18             	add    $0x18,%esp
  80025f:	53                   	push   %ebx
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	e8 53 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  800268:	c7 04 24 0d 1a 80 00 	movl   $0x801a0d,(%esp)
  80026f:	e8 98 00 00 00       	call   80030c <cprintf>

	// Cause a breakpoint exception
	while (1)
  800274:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800277:	cc                   	int3   
  800278:	eb fd                	jmp    800277 <_panic+0x47>
	...

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 03                	mov    (%ebx),%eax
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  80028f:	40                   	inc    %eax
  800290:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800292:	3d ff 00 00 00       	cmp    $0xff,%eax
  800297:	75 1a                	jne    8002b3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	68 ff 00 00 00       	push   $0xff
  8002a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a4:	50                   	push   %eax
  8002a5:	e8 96 08 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  8002aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b3:	ff 43 04             	incl   0x4(%ebx)
}
  8002b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c4:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8002cb:	00 00 00 
	b.cnt = 0;
  8002ce:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8002d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	68 7c 02 80 00       	push   $0x80027c
  8002ea:	e8 49 01 00 00       	call   800438 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ef:	83 c4 08             	add    $0x8,%esp
  8002f2:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  8002f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fe:	50                   	push   %eax
  8002ff:	e8 3c 08 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
  800304:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800312:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 9d ff ff ff       	call   8002bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	8b 75 10             	mov    0x10(%ebp),%esi
  80032c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800332:	8b 45 18             	mov    0x18(%ebp),%eax
  800335:	ba 00 00 00 00       	mov    $0x0,%edx
  80033a:	39 fa                	cmp    %edi,%edx
  80033c:	77 39                	ja     800377 <printnum+0x57>
  80033e:	72 04                	jb     800344 <printnum+0x24>
  800340:	39 f0                	cmp    %esi,%eax
  800342:	77 33                	ja     800377 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800344:	83 ec 04             	sub    $0x4,%esp
  800347:	ff 75 20             	pushl  0x20(%ebp)
  80034a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80034d:	50                   	push   %eax
  80034e:	ff 75 18             	pushl  0x18(%ebp)
  800351:	8b 45 18             	mov    0x18(%ebp),%eax
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
  800359:	52                   	push   %edx
  80035a:	50                   	push   %eax
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	e8 92 13 00 00       	call   8016f4 <__udivdi3>
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	52                   	push   %edx
  800366:	50                   	push   %eax
  800367:	ff 75 0c             	pushl  0xc(%ebp)
  80036a:	ff 75 08             	pushl  0x8(%ebp)
  80036d:	e8 ae ff ff ff       	call   800320 <printnum>
  800372:	83 c4 20             	add    $0x20,%esp
  800375:	eb 19                	jmp    800390 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800377:	4b                   	dec    %ebx
  800378:	85 db                	test   %ebx,%ebx
  80037a:	7e 14                	jle    800390 <printnum+0x70>
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	ff 75 0c             	pushl  0xc(%ebp)
  800382:	ff 75 20             	pushl  0x20(%ebp)
  800385:	ff 55 08             	call   *0x8(%ebp)
  800388:	83 c4 10             	add    $0x10,%esp
  80038b:	4b                   	dec    %ebx
  80038c:	85 db                	test   %ebx,%ebx
  80038e:	7f ec                	jg     80037c <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	8b 45 18             	mov    0x18(%ebp),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	83 ec 04             	sub    $0x4,%esp
  8003a1:	52                   	push   %edx
  8003a2:	50                   	push   %eax
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	e8 56 14 00 00       	call   801800 <__umoddi3>
  8003aa:	83 c4 14             	add    $0x14,%esp
  8003ad:	0f be 80 c5 1b 80 00 	movsbl 0x801bc5(%eax),%eax
  8003b4:	50                   	push   %eax
  8003b5:	ff 55 08             	call   *0x8(%ebp)
}
  8003b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bb:	5b                   	pop    %ebx
  8003bc:	5e                   	pop    %esi
  8003bd:	5f                   	pop    %edi
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8003c9:	83 f8 01             	cmp    $0x1,%eax
  8003cc:	7e 0e                	jle    8003dc <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 11                	mov    (%ecx),%edx
  8003d0:	8d 42 08             	lea    0x8(%edx),%eax
  8003d3:	89 01                	mov    %eax,(%ecx)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	eb 22                	jmp    8003fe <getuint+0x3e>
	else if (lflag)
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	74 10                	je     8003f0 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8003e0:	8b 11                	mov    (%ecx),%edx
  8003e2:	8d 42 04             	lea    0x4(%edx),%eax
  8003e5:	89 01                	mov    %eax,(%ecx)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 0e                	jmp    8003fe <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  8003f0:	8b 11                	mov    (%ecx),%edx
  8003f2:	8d 42 04             	lea    0x4(%edx),%eax
  8003f5:	89 01                	mov    %eax,(%ecx)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  800409:	83 f8 01             	cmp    $0x1,%eax
  80040c:	7e 0e                	jle    80041c <getint+0x1c>
		return va_arg(*ap, long long);
  80040e:	8b 11                	mov    (%ecx),%edx
  800410:	8d 42 08             	lea    0x8(%edx),%eax
  800413:	89 01                	mov    %eax,(%ecx)
  800415:	8b 02                	mov    (%edx),%eax
  800417:	8b 52 04             	mov    0x4(%edx),%edx
  80041a:	eb 1a                	jmp    800436 <getint+0x36>
	else if (lflag)
  80041c:	85 c0                	test   %eax,%eax
  80041e:	74 0c                	je     80042c <getint+0x2c>
		return va_arg(*ap, long);
  800420:	8b 01                	mov    (%ecx),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 11                	mov    %edx,(%ecx)
  800427:	8b 00                	mov    (%eax),%eax
  800429:	99                   	cltd   
  80042a:	eb 0a                	jmp    800436 <getint+0x36>
	else
		return va_arg(*ap, int);
  80042c:	8b 01                	mov    (%ecx),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 11                	mov    %edx,(%ecx)
  800433:	8b 00                	mov    (%eax),%eax
  800435:	99                   	cltd   
}
  800436:	c9                   	leave  
  800437:	c3                   	ret    

00800438 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 1c             	sub    $0x1c,%esp
  800441:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800444:	0f b6 0b             	movzbl (%ebx),%ecx
  800447:	43                   	inc    %ebx
  800448:	83 f9 25             	cmp    $0x25,%ecx
  80044b:	74 1e                	je     80046b <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80044d:	85 c9                	test   %ecx,%ecx
  80044f:	0f 84 dc 02 00 00    	je     800731 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 0c             	pushl  0xc(%ebp)
  80045b:	51                   	push   %ecx
  80045c:	ff 55 08             	call   *0x8(%ebp)
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	0f b6 0b             	movzbl (%ebx),%ecx
  800465:	43                   	inc    %ebx
  800466:	83 f9 25             	cmp    $0x25,%ecx
  800469:	75 e2                	jne    80044d <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80046b:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80046f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800476:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80047b:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800480:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	0f b6 0b             	movzbl (%ebx),%ecx
  80048a:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80048d:	43                   	inc    %ebx
  80048e:	83 f8 55             	cmp    $0x55,%eax
  800491:	0f 87 75 02 00 00    	ja     80070c <vprintfmt+0x2d4>
  800497:	ff 24 85 60 1c 80 00 	jmp    *0x801c60(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80049e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8004a2:	eb e3                	jmp    800487 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a4:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8004a8:	eb dd                	jmp    800487 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004aa:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8004af:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8004b2:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8004b6:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8004b9:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8004bc:	83 f8 09             	cmp    $0x9,%eax
  8004bf:	77 28                	ja     8004e9 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c1:	43                   	inc    %ebx
  8004c2:	eb eb                	jmp    8004af <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c4:	8b 55 14             	mov    0x14(%ebp),%edx
  8004c7:	8d 42 04             	lea    0x4(%edx),%eax
  8004ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cd:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8004cf:	eb 18                	jmp    8004e9 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8004d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004d5:	79 b0                	jns    800487 <vprintfmt+0x4f>
				width = 0;
  8004d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8004de:	eb a7                	jmp    800487 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8004e0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  8004e7:	eb 9e                	jmp    800487 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  8004e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004ed:	79 98                	jns    800487 <vprintfmt+0x4f>
				width = precision, precision = -1;
  8004ef:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8004f2:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8004f7:	eb 8e                	jmp    800487 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f9:	47                   	inc    %edi
			goto reswitch;
  8004fa:	eb 8b                	jmp    800487 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	8b 55 14             	mov    0x14(%ebp),%edx
  800505:	8d 42 04             	lea    0x4(%edx),%eax
  800508:	89 45 14             	mov    %eax,0x14(%ebp)
  80050b:	ff 32                	pushl  (%edx)
  80050d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	e9 2c ff ff ff       	jmp    800444 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800518:	8b 55 14             	mov    0x14(%ebp),%edx
  80051b:	8d 42 04             	lea    0x4(%edx),%eax
  80051e:	89 45 14             	mov    %eax,0x14(%ebp)
  800521:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800523:	85 c0                	test   %eax,%eax
  800525:	79 02                	jns    800529 <vprintfmt+0xf1>
				err = -err;
  800527:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800529:	83 f8 0f             	cmp    $0xf,%eax
  80052c:	7f 0b                	jg     800539 <vprintfmt+0x101>
  80052e:	8b 3c 85 20 1c 80 00 	mov    0x801c20(,%eax,4),%edi
  800535:	85 ff                	test   %edi,%edi
  800537:	75 19                	jne    800552 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800539:	50                   	push   %eax
  80053a:	68 d6 1b 80 00       	push   $0x801bd6
  80053f:	ff 75 0c             	pushl  0xc(%ebp)
  800542:	ff 75 08             	pushl  0x8(%ebp)
  800545:	e8 ef 01 00 00       	call   800739 <printfmt>
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	e9 f2 fe ff ff       	jmp    800444 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800552:	57                   	push   %edi
  800553:	68 df 1b 80 00       	push   $0x801bdf
  800558:	ff 75 0c             	pushl  0xc(%ebp)
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 d6 01 00 00       	call   800739 <printfmt>
  800563:	83 c4 10             	add    $0x10,%esp
			break;
  800566:	e9 d9 fe ff ff       	jmp    800444 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 55 14             	mov    0x14(%ebp),%edx
  80056e:	8d 42 04             	lea    0x4(%edx),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
  800574:	8b 3a                	mov    (%edx),%edi
  800576:	85 ff                	test   %edi,%edi
  800578:	75 05                	jne    80057f <vprintfmt+0x147>
				p = "(null)";
  80057a:	bf e2 1b 80 00       	mov    $0x801be2,%edi
			if (width > 0 && padc != '-')
  80057f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800583:	7e 3b                	jle    8005c0 <vprintfmt+0x188>
  800585:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800589:	74 35                	je     8005c0 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	56                   	push   %esi
  80058f:	57                   	push   %edi
  800590:	e8 58 02 00 00       	call   8007ed <strnlen>
  800595:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80059f:	7e 1f                	jle    8005c0 <vprintfmt+0x188>
  8005a1:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	ff 4d f0             	decl   -0x10(%ebp)
  8005ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005be:	7f e8                	jg     8005a8 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c0:	0f be 0f             	movsbl (%edi),%ecx
  8005c3:	47                   	inc    %edi
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	74 44                	je     80060c <vprintfmt+0x1d4>
  8005c8:	85 f6                	test   %esi,%esi
  8005ca:	78 03                	js     8005cf <vprintfmt+0x197>
  8005cc:	4e                   	dec    %esi
  8005cd:	78 3d                	js     80060c <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8005d3:	74 18                	je     8005ed <vprintfmt+0x1b5>
  8005d5:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8005d8:	83 f8 5e             	cmp    $0x5e,%eax
  8005db:	76 10                	jbe    8005ed <vprintfmt+0x1b5>
					putch('?', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	ff 75 0c             	pushl  0xc(%ebp)
  8005e3:	6a 3f                	push   $0x3f
  8005e5:	ff 55 08             	call   *0x8(%ebp)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb 0d                	jmp    8005fa <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	ff 75 0c             	pushl  0xc(%ebp)
  8005f3:	51                   	push   %ecx
  8005f4:	ff 55 08             	call   *0x8(%ebp)
  8005f7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fa:	ff 4d f0             	decl   -0x10(%ebp)
  8005fd:	0f be 0f             	movsbl (%edi),%ecx
  800600:	47                   	inc    %edi
  800601:	85 c9                	test   %ecx,%ecx
  800603:	74 07                	je     80060c <vprintfmt+0x1d4>
  800605:	85 f6                	test   %esi,%esi
  800607:	78 c6                	js     8005cf <vprintfmt+0x197>
  800609:	4e                   	dec    %esi
  80060a:	79 c3                	jns    8005cf <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800610:	0f 8e 2e fe ff ff    	jle    800444 <vprintfmt+0xc>
				putch(' ', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	ff 75 0c             	pushl  0xc(%ebp)
  80061c:	6a 20                	push   $0x20
  80061e:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	ff 4d f0             	decl   -0x10(%ebp)
  800627:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80062b:	7f e9                	jg     800616 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  80062d:	e9 12 fe ff ff       	jmp    800444 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800632:	57                   	push   %edi
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	50                   	push   %eax
  800637:	e8 c4 fd ff ff       	call   800400 <getint>
  80063c:	89 c6                	mov    %eax,%esi
  80063e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800640:	83 c4 08             	add    $0x8,%esp
  800643:	85 d2                	test   %edx,%edx
  800645:	79 15                	jns    80065c <vprintfmt+0x224>
				putch('-', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	ff 75 0c             	pushl  0xc(%ebp)
  80064d:	6a 2d                	push   $0x2d
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	f7 de                	neg    %esi
  800654:	83 d7 00             	adc    $0x0,%edi
  800657:	f7 df                	neg    %edi
  800659:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065c:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800661:	eb 76                	jmp    8006d9 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800663:	57                   	push   %edi
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	e8 53 fd ff ff       	call   8003c0 <getuint>
  80066d:	89 c6                	mov    %eax,%esi
  80066f:	89 d7                	mov    %edx,%edi
			base = 10;
  800671:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	eb 5e                	jmp    8006d9 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067b:	57                   	push   %edi
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	50                   	push   %eax
  800680:	e8 3b fd ff ff       	call   8003c0 <getuint>
  800685:	89 c6                	mov    %eax,%esi
  800687:	89 d7                	mov    %edx,%edi
			base = 8;
  800689:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	eb 46                	jmp    8006d9 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	6a 30                	push   $0x30
  80069b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80069e:	83 c4 08             	add    $0x8,%esp
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	6a 78                	push   $0x78
  8006a6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ac:	8d 42 04             	lea    0x4(%edx),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b2:	8b 32                	mov    (%edx),%esi
  8006b4:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b9:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 16                	jmp    8006d9 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c3:	57                   	push   %edi
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	50                   	push   %eax
  8006c8:	e8 f3 fc ff ff       	call   8003c0 <getuint>
  8006cd:	89 c6                	mov    %eax,%esi
  8006cf:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d1:	ba 10 00 00 00       	mov    $0x10,%edx
  8006d6:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d9:	83 ec 04             	sub    $0x4,%esp
  8006dc:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8006e4:	52                   	push   %edx
  8006e5:	57                   	push   %edi
  8006e6:	56                   	push   %esi
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 2e fc ff ff       	call   800320 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
  8006f5:	e9 4a fd ff ff       	jmp    800444 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	ff 75 0c             	pushl  0xc(%ebp)
  800700:	51                   	push   %ecx
  800701:	ff 55 08             	call   *0x8(%ebp)
			break;
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	e9 38 fd ff ff       	jmp    800444 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	6a 25                	push   $0x25
  800714:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800717:	4b                   	dec    %ebx
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80071f:	0f 84 1f fd ff ff    	je     800444 <vprintfmt+0xc>
  800725:	4b                   	dec    %ebx
  800726:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80072a:	75 f9                	jne    800725 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80072c:	e9 13 fd ff ff       	jmp    800444 <vprintfmt+0xc>
		}
	}
}
  800731:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800734:	5b                   	pop    %ebx
  800735:	5e                   	pop    %esi
  800736:	5f                   	pop    %edi
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800742:	50                   	push   %eax
  800743:	ff 75 10             	pushl  0x10(%ebp)
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	ff 75 08             	pushl  0x8(%ebp)
  80074c:	e8 e7 fc ff ff       	call   800438 <vprintfmt>
	va_end(ap);
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800759:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80075c:	8b 0a                	mov    (%edx),%ecx
  80075e:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800761:	73 07                	jae    80076a <sprintputch+0x17>
		*b->buf++ = ch;
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	88 01                	mov    %al,(%ecx)
  800768:	ff 02                	incl   (%edx)
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	83 ec 18             	sub    $0x18,%esp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
  800775:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800778:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80077b:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80077f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800782:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 04                	je     800791 <vsnprintf+0x25>
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	7f 07                	jg     800798 <vsnprintf+0x2c>
		return -E_INVAL;
  800791:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800796:	eb 1d                	jmp    8007b5 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800798:	ff 75 14             	pushl  0x14(%ebp)
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	68 53 07 80 00       	push   $0x800753
  8007a7:	e8 8c fc ff ff       	call   800438 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c0:	50                   	push   %eax
  8007c1:	ff 75 10             	pushl  0x10(%ebp)
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	ff 75 08             	pushl  0x8(%ebp)
  8007ca:	e8 9d ff ff ff       	call   80076c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    
  8007d1:	00 00                	add    %al,(%eax)
	...

008007d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e2:	74 07                	je     8007eb <strlen+0x17>
		n++;
  8007e4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e5:	42                   	inc    %edx
  8007e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e9:	75 f9                	jne    8007e4 <strlen+0x10>
		n++;
	return n;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	74 0f                	je     80080e <strnlen+0x21>
  8007ff:	80 39 00             	cmpb   $0x0,(%ecx)
  800802:	74 0a                	je     80080e <strnlen+0x21>
		n++;
  800804:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	41                   	inc    %ecx
  800806:	4a                   	dec    %edx
  800807:	74 05                	je     80080e <strnlen+0x21>
  800809:	80 39 00             	cmpb   $0x0,(%ecx)
  80080c:	75 f6                	jne    800804 <strnlen+0x17>
		n++;
	return n;
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80081a:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  80081c:	8a 02                	mov    (%edx),%al
  80081e:	42                   	inc    %edx
  80081f:	88 01                	mov    %al,(%ecx)
  800821:	41                   	inc    %ecx
  800822:	84 c0                	test   %al,%al
  800824:	75 f6                	jne    80081c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800826:	89 d8                	mov    %ebx,%eax
  800828:	5b                   	pop    %ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	53                   	push   %ebx
  800833:	e8 9c ff ff ff       	call   8007d4 <strlen>
	strcpy(dst + len, src);
  800838:	ff 75 0c             	pushl  0xc(%ebp)
  80083b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80083e:	50                   	push   %eax
  80083f:	e8 cc ff ff ff       	call   800810 <strcpy>
	return dst;
}
  800844:	89 d8                	mov    %ebx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	57                   	push   %edi
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
  800857:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80085a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80085c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800861:	39 f3                	cmp    %esi,%ebx
  800863:	73 10                	jae    800875 <strncpy+0x2a>
		*dst++ = *src;
  800865:	8a 02                	mov    (%edx),%al
  800867:	88 01                	mov    %al,(%ecx)
  800869:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086a:	80 3a 01             	cmpb   $0x1,(%edx)
  80086d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800870:	43                   	inc    %ebx
  800871:	39 f3                	cmp    %esi,%ebx
  800873:	72 f0                	jb     800865 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800875:	89 f8                	mov    %edi,%eax
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80088a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80088c:	85 d2                	test   %edx,%edx
  80088e:	74 19                	je     8008a9 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	4a                   	dec    %edx
  800891:	74 13                	je     8008a6 <strlcpy+0x2a>
  800893:	80 39 00             	cmpb   $0x0,(%ecx)
  800896:	74 0e                	je     8008a6 <strlcpy+0x2a>
  800898:	8a 01                	mov    (%ecx),%al
  80089a:	41                   	inc    %ecx
  80089b:	88 03                	mov    %al,(%ebx)
  80089d:	43                   	inc    %ebx
  80089e:	4a                   	dec    %edx
  80089f:	74 05                	je     8008a6 <strlcpy+0x2a>
  8008a1:	80 39 00             	cmpb   $0x0,(%ecx)
  8008a4:	75 f2                	jne    800898 <strlcpy+0x1c>
		*dst = '\0';
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8008a9:	89 d8                	mov    %ebx,%eax
  8008ab:	29 f0                	sub    %esi,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8008ba:	80 3a 00             	cmpb   $0x0,(%edx)
  8008bd:	74 13                	je     8008d2 <strcmp+0x21>
  8008bf:	8a 02                	mov    (%edx),%al
  8008c1:	3a 01                	cmp    (%ecx),%al
  8008c3:	75 0d                	jne    8008d2 <strcmp+0x21>
  8008c5:	42                   	inc    %edx
  8008c6:	41                   	inc    %ecx
  8008c7:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ca:	74 06                	je     8008d2 <strcmp+0x21>
  8008cc:	8a 02                	mov    (%edx),%al
  8008ce:	3a 01                	cmp    (%ecx),%al
  8008d0:	74 f3                	je     8008c5 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 02             	movzbl (%edx),%eax
  8008d5:	0f b6 11             	movzbl (%ecx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 1f                	je     80090c <strncmp+0x30>
  8008ed:	80 3a 00             	cmpb   $0x0,(%edx)
  8008f0:	74 16                	je     800908 <strncmp+0x2c>
  8008f2:	8a 02                	mov    (%edx),%al
  8008f4:	3a 03                	cmp    (%ebx),%al
  8008f6:	75 10                	jne    800908 <strncmp+0x2c>
  8008f8:	42                   	inc    %edx
  8008f9:	43                   	inc    %ebx
  8008fa:	49                   	dec    %ecx
  8008fb:	74 0f                	je     80090c <strncmp+0x30>
  8008fd:	80 3a 00             	cmpb   $0x0,(%edx)
  800900:	74 06                	je     800908 <strncmp+0x2c>
  800902:	8a 02                	mov    (%edx),%al
  800904:	3a 03                	cmp    (%ebx),%al
  800906:	74 f0                	je     8008f8 <strncmp+0x1c>
	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	75 07                	jne    800913 <strncmp+0x37>
		return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb 0a                	jmp    80091d <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 12             	movzbl (%edx),%edx
  800916:	0f b6 03             	movzbl (%ebx),%eax
  800919:	29 c2                	sub    %eax,%edx
  80091b:	89 d0                	mov    %edx,%eax
}
  80091d:	5b                   	pop    %ebx
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800929:	80 38 00             	cmpb   $0x0,(%eax)
  80092c:	74 0a                	je     800938 <strchr+0x18>
		if (*s == c)
  80092e:	38 10                	cmp    %dl,(%eax)
  800930:	74 0b                	je     80093d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800932:	40                   	inc    %eax
  800933:	80 38 00             	cmpb   $0x0,(%eax)
  800936:	75 f6                	jne    80092e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800948:	80 38 00             	cmpb   $0x0,(%eax)
  80094b:	74 0a                	je     800957 <strfind+0x18>
		if (*s == c)
  80094d:	38 10                	cmp    %dl,(%eax)
  80094f:	74 06                	je     800957 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800951:	40                   	inc    %eax
  800952:	80 38 00             	cmpb   $0x0,(%eax)
  800955:	75 f6                	jne    80094d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800963:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 40                	je     8009a9 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 30                	jne    8009a1 <memset+0x48>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 2b                	jne    8009a1 <memset+0x48>
		c &= 0xFF;
  800976:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	c1 e0 18             	shl    $0x18,%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	c1 e2 10             	shl    $0x10,%edx
  800989:	09 d0                	or     %edx,%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	c1 e2 08             	shl    $0x8,%edx
  800991:	09 d0                	or     %edx,%eax
  800993:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800996:	c1 e9 02             	shr    $0x2,%ecx
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	fc                   	cld    
  80099d:	f3 ab                	rep stos %eax,%es:(%edi)
  80099f:	eb 06                	jmp    8009a7 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	fc                   	cld    
  8009a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8009a7:	89 f8                	mov    %edi,%eax
}
  8009a9:	5f                   	pop    %edi
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009ba:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009bc:	39 c6                	cmp    %eax,%esi
  8009be:	73 34                	jae    8009f4 <memmove+0x48>
  8009c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c3:	39 c2                	cmp    %eax,%edx
  8009c5:	76 2d                	jbe    8009f4 <memmove+0x48>
		s += n;
  8009c7:	89 d6                	mov    %edx,%esi
		d += n;
  8009c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	f6 c2 03             	test   $0x3,%dl
  8009cf:	75 1b                	jne    8009ec <memmove+0x40>
  8009d1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d7:	75 13                	jne    8009ec <memmove+0x40>
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 0e                	jne    8009ec <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8009de:	83 ef 04             	sub    $0x4,%edi
  8009e1:	83 ee 04             	sub    $0x4,%esi
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
  8009e7:	fd                   	std    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb 05                	jmp    8009f1 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ec:	4f                   	dec    %edi
  8009ed:	4e                   	dec    %esi
  8009ee:	fd                   	std    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f1:	fc                   	cld    
  8009f2:	eb 20                	jmp    800a14 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fa:	75 15                	jne    800a11 <memmove+0x65>
  8009fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a02:	75 0d                	jne    800a11 <memmove+0x65>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 08                	jne    800a11 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  800a09:	c1 e9 02             	shr    $0x2,%ecx
  800a0c:	fc                   	cld    
  800a0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0f:	eb 03                	jmp    800a14 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a11:	fc                   	cld    
  800a12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a14:	5e                   	pop    %esi
  800a15:	5f                   	pop    %edi
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1b:	ff 75 10             	pushl  0x10(%ebp)
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	ff 75 08             	pushl  0x8(%ebp)
  800a24:	e8 83 ff ff ff       	call   8009ac <memmove>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a35:	8b 55 10             	mov    0x10(%ebp),%edx
  800a38:	4a                   	dec    %edx
  800a39:	83 fa ff             	cmp    $0xffffffff,%edx
  800a3c:	74 1a                	je     800a58 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800a3e:	8a 01                	mov    (%ecx),%al
  800a40:	3a 03                	cmp    (%ebx),%al
  800a42:	74 0c                	je     800a50 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800a44:	0f b6 d0             	movzbl %al,%edx
  800a47:	0f b6 03             	movzbl (%ebx),%eax
  800a4a:	29 c2                	sub    %eax,%edx
  800a4c:	89 d0                	mov    %edx,%eax
  800a4e:	eb 0d                	jmp    800a5d <memcmp+0x32>
		s1++, s2++;
  800a50:	41                   	inc    %ecx
  800a51:	43                   	inc    %ebx
  800a52:	4a                   	dec    %edx
  800a53:	83 fa ff             	cmp    $0xffffffff,%edx
  800a56:	75 e6                	jne    800a3e <memcmp+0x13>
	}

	return 0;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	73 09                	jae    800a7b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a72:	38 08                	cmp    %cl,(%eax)
  800a74:	74 05                	je     800a7b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a76:	40                   	inc    %eax
  800a77:	39 d0                	cmp    %edx,%eax
  800a79:	72 f7                	jb     800a72 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800a91:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800a96:	80 3a 20             	cmpb   $0x20,(%edx)
  800a99:	74 05                	je     800aa0 <strtol+0x23>
  800a9b:	80 3a 09             	cmpb   $0x9,(%edx)
  800a9e:	75 0b                	jne    800aab <strtol+0x2e>
  800aa0:	42                   	inc    %edx
  800aa1:	80 3a 20             	cmpb   $0x20,(%edx)
  800aa4:	74 fa                	je     800aa0 <strtol+0x23>
  800aa6:	80 3a 09             	cmpb   $0x9,(%edx)
  800aa9:	74 f5                	je     800aa0 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  800aab:	80 3a 2b             	cmpb   $0x2b,(%edx)
  800aae:	75 03                	jne    800ab3 <strtol+0x36>
		s++;
  800ab0:	42                   	inc    %edx
  800ab1:	eb 0b                	jmp    800abe <strtol+0x41>
	else if (*s == '-')
  800ab3:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800ab6:	75 06                	jne    800abe <strtol+0x41>
		s++, neg = 1;
  800ab8:	42                   	inc    %edx
  800ab9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abe:	85 c9                	test   %ecx,%ecx
  800ac0:	74 05                	je     800ac7 <strtol+0x4a>
  800ac2:	83 f9 10             	cmp    $0x10,%ecx
  800ac5:	75 15                	jne    800adc <strtol+0x5f>
  800ac7:	80 3a 30             	cmpb   $0x30,(%edx)
  800aca:	75 10                	jne    800adc <strtol+0x5f>
  800acc:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad0:	75 0a                	jne    800adc <strtol+0x5f>
		s += 2, base = 16;
  800ad2:	83 c2 02             	add    $0x2,%edx
  800ad5:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ada:	eb 14                	jmp    800af0 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	75 10                	jne    800af0 <strtol+0x73>
  800ae0:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae3:	75 05                	jne    800aea <strtol+0x6d>
		s++, base = 8;
  800ae5:	42                   	inc    %edx
  800ae6:	b1 08                	mov    $0x8,%cl
  800ae8:	eb 06                	jmp    800af0 <strtol+0x73>
	else if (base == 0)
  800aea:	85 c9                	test   %ecx,%ecx
  800aec:	75 02                	jne    800af0 <strtol+0x73>
		base = 10;
  800aee:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	8a 02                	mov    (%edx),%al
  800af2:	83 e8 30             	sub    $0x30,%eax
  800af5:	3c 09                	cmp    $0x9,%al
  800af7:	77 08                	ja     800b01 <strtol+0x84>
			dig = *s - '0';
  800af9:	0f be 02             	movsbl (%edx),%eax
  800afc:	83 e8 30             	sub    $0x30,%eax
  800aff:	eb 20                	jmp    800b21 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800b01:	8a 02                	mov    (%edx),%al
  800b03:	83 e8 61             	sub    $0x61,%eax
  800b06:	3c 19                	cmp    $0x19,%al
  800b08:	77 08                	ja     800b12 <strtol+0x95>
			dig = *s - 'a' + 10;
  800b0a:	0f be 02             	movsbl (%edx),%eax
  800b0d:	83 e8 57             	sub    $0x57,%eax
  800b10:	eb 0f                	jmp    800b21 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800b12:	8a 02                	mov    (%edx),%al
  800b14:	83 e8 41             	sub    $0x41,%eax
  800b17:	3c 19                	cmp    $0x19,%al
  800b19:	77 12                	ja     800b2d <strtol+0xb0>
			dig = *s - 'A' + 10;
  800b1b:	0f be 02             	movsbl (%edx),%eax
  800b1e:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800b21:	39 c8                	cmp    %ecx,%eax
  800b23:	7d 08                	jge    800b2d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b25:	42                   	inc    %edx
  800b26:	0f af d9             	imul   %ecx,%ebx
  800b29:	01 c3                	add    %eax,%ebx
  800b2b:	eb c3                	jmp    800af0 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2d:	85 f6                	test   %esi,%esi
  800b2f:	74 02                	je     800b33 <strtol+0xb6>
		*endptr = (char *) s;
  800b31:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b33:	89 d8                	mov    %ebx,%eax
  800b35:	85 ff                	test   %edi,%edi
  800b37:	74 02                	je     800b3b <strtol+0xbe>
  800b39:	f7 d8                	neg    %eax
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 04             	sub    $0x4,%esp
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b4f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	89 f8                	mov    %edi,%eax
  800b56:	89 fb                	mov    %edi,%ebx
  800b58:	89 fe                	mov    %edi,%esi
  800b5a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5c:	83 c4 04             	add    $0x4,%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	89 fa                	mov    %edi,%edx
  800b76:	89 f9                	mov    %edi,%ecx
  800b78:	89 fb                	mov    %edi,%ebx
  800b7a:	89 fe                	mov    %edi,%esi
  800b7c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b94:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	89 f9                	mov    %edi,%ecx
  800b9b:	89 fb                	mov    %edi,%ebx
  800b9d:	89 fe                	mov    %edi,%esi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 03                	push   $0x3
  800bab:	68 b8 1d 80 00       	push   $0x801db8
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 d5 1d 80 00       	push   $0x801dd5
  800bb7:	e8 74 f6 ff ff       	call   800230 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	89 fa                	mov    %edi,%edx
  800bd6:	89 f9                	mov    %edi,%ecx
  800bd8:	89 fb                	mov    %edi,%ebx
  800bda:	89 fe                	mov    %edi,%esi
  800bdc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_yield>:

void
sys_yield(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800be9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	89 fa                	mov    %edi,%edx
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	89 fb                	mov    %edi,%ebx
  800bf9:	89 fe                	mov    %edi,%esi
  800bfb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c14:	b8 04 00 00 00       	mov    $0x4,%eax
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	89 fe                	mov    %edi,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 04                	push   $0x4
  800c2c:	68 b8 1d 80 00       	push   $0x801db8
  800c31:	6a 23                	push   $0x23
  800c33:	68 d5 1d 80 00       	push   $0x801dd5
  800c38:	e8 f3 f5 ff ff       	call   800230 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c5d:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 05                	push   $0x5
  800c6e:	68 b8 1d 80 00       	push   $0x801db8
  800c73:	6a 23                	push   $0x23
  800c75:	68 d5 1d 80 00       	push   $0x801dd5
  800c7a:	e8 b1 f5 ff ff       	call   800230 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	89 fb                	mov    %edi,%ebx
  800ca2:	89 fe                	mov    %edi,%esi
  800ca4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 06                	push   $0x6
  800cb0:	68 b8 1d 80 00       	push   $0x801db8
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 d5 1d 80 00       	push   $0x801dd5
  800cbc:	e8 6f f5 ff ff       	call   800230 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdd:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	89 fb                	mov    %edi,%ebx
  800ce4:	89 fe                	mov    %edi,%esi
  800ce6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 17                	jle    800d03 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 08                	push   $0x8
  800cf2:	68 b8 1d 80 00       	push   $0x801db8
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 d5 1d 80 00       	push   $0x801dd5
  800cfe:	e8 2d f5 ff ff       	call   800230 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	89 fb                	mov    %edi,%ebx
  800d26:	89 fe                	mov    %edi,%esi
  800d28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 09                	push   $0x9
  800d34:	68 b8 1d 80 00       	push   $0x801db8
  800d39:	6a 23                	push   $0x23
  800d3b:	68 d5 1d 80 00       	push   $0x801dd5
  800d40:	e8 eb f4 ff ff       	call   800230 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d61:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	89 fb                	mov    %edi,%ebx
  800d68:	89 fe                	mov    %edi,%esi
  800d6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 0a                	push   $0xa
  800d76:	68 b8 1d 80 00       	push   $0x801db8
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 d5 1d 80 00       	push   $0x801dd5
  800d82:	e8 a9 f4 ff ff       	call   800230 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dbe:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	89 f9                	mov    %edi,%ecx
  800dca:	89 fb                	mov    %edi,%ebx
  800dcc:	89 fe                	mov    %edi,%esi
  800dce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 17                	jle    800deb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 0d                	push   $0xd
  800dda:	68 b8 1d 80 00       	push   $0x801db8
  800ddf:	6a 23                	push   $0x23
  800de1:	68 d5 1d 80 00       	push   $0x801dd5
  800de6:	e8 45 f4 ff ff       	call   800230 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
	...

00800df4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	05 00 00 00 30       	add    $0x30000000,%eax
  800dff:	c1 e8 0c             	shr    $0xc,%eax
}
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e07:	ff 75 08             	pushl  0x8(%ebp)
  800e0a:	e8 e5 ff ff ff       	call   800df4 <fd2num>
  800e0f:	83 c4 04             	add    $0x4,%esp
  800e12:	c1 e0 0c             	shl    $0xc,%eax
  800e15:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    

00800e1c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2a:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  800e2f:	bb 00 00 40 ef       	mov    $0xef400000,%ebx
		fd = INDEX2FD(i);
  800e34:	89 c8                	mov    %ecx,%eax
  800e36:	c1 e0 0c             	shl    $0xc,%eax
  800e39:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	c1 e8 16             	shr    $0x16,%eax
  800e44:	8b 04 86             	mov    (%esi,%eax,4),%eax
  800e47:	a8 01                	test   $0x1,%al
  800e49:	74 0c                	je     800e57 <fd_alloc+0x3b>
  800e4b:	89 d0                	mov    %edx,%eax
  800e4d:	c1 e8 0c             	shr    $0xc,%eax
  800e50:	8b 04 83             	mov    (%ebx,%eax,4),%eax
  800e53:	a8 01                	test   $0x1,%al
  800e55:	75 09                	jne    800e60 <fd_alloc+0x44>
			*fd_store = fd;
  800e57:	89 17                	mov    %edx,(%edi)
			return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	eb 11                	jmp    800e71 <fd_alloc+0x55>
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e60:	41                   	inc    %ecx
  800e61:	83 f9 1f             	cmp    $0x1f,%ecx
  800e64:	7e ce                	jle    800e34 <fd_alloc+0x18>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e66:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	return -E_MAX_OPEN;
  800e6c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	c9                   	leave  
  800e75:	c3                   	ret    

00800e76 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800e7c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e81:	83 f8 1f             	cmp    $0x1f,%eax
  800e84:	77 3a                	ja     800ec0 <fd_lookup+0x4a>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e86:	c1 e0 0c             	shl    $0xc,%eax
  800e89:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	///^&^ making sure fd page exists
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800e8f:	89 d0                	mov    %edx,%eax
  800e91:	c1 e8 16             	shr    $0x16,%eax
  800e94:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e9b:	a8 01                	test   $0x1,%al
  800e9d:	74 10                	je     800eaf <fd_lookup+0x39>
  800e9f:	89 d0                	mov    %edx,%eax
  800ea1:	c1 e8 0c             	shr    $0xc,%eax
  800ea4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eab:	a8 01                	test   $0x1,%al
  800ead:	75 07                	jne    800eb6 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  800eaf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800eb4:	eb 0a                	jmp    800ec0 <fd_lookup+0x4a>
	}
	*fd_store = fd;
  800eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb9:	89 10                	mov    %edx,(%eax)
	return 0;
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800ec0:	89 d0                	mov    %edx,%eax
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 10             	sub    $0x10,%esp
  800ecc:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ecf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed2:	50                   	push   %eax
  800ed3:	56                   	push   %esi
  800ed4:	e8 1b ff ff ff       	call   800df4 <fd2num>
  800ed9:	89 04 24             	mov    %eax,(%esp)
  800edc:	e8 95 ff ff ff       	call   800e76 <fd_lookup>
  800ee1:	89 c3                	mov    %eax,%ebx
  800ee3:	83 c4 08             	add    $0x8,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 05                	js     800eef <fd_close+0x2b>
  800eea:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eed:	74 0f                	je     800efe <fd_close+0x3a>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800eef:	89 d8                	mov    %ebx,%eax
  800ef1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef5:	75 45                	jne    800f3c <fd_close+0x78>
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	eb 3e                	jmp    800f3c <fd_close+0x78>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f04:	50                   	push   %eax
  800f05:	ff 36                	pushl  (%esi)
  800f07:	e8 37 00 00 00       	call   800f43 <dev_lookup>
  800f0c:	89 c3                	mov    %eax,%ebx
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	78 1a                	js     800f2f <fd_close+0x6b>
		if (dev->dev_close)
  800f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f1d:	83 78 10 00          	cmpl   $0x0,0x10(%eax)
  800f21:	74 0c                	je     800f2f <fd_close+0x6b>
			r = (*dev->dev_close)(fd);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	56                   	push   %esi
  800f27:	ff 50 10             	call   *0x10(%eax)
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	56                   	push   %esi
  800f33:	6a 00                	push   $0x0
  800f35:	e8 4d fd ff ff       	call   800c87 <sys_page_unmap>
	return r;
  800f3a:	89 d8                	mov    %ebx,%eax
}
  800f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f4b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	for (i = 0; devtab[i]; i++)
  800f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f53:	83 3d 04 20 80 00 00 	cmpl   $0x0,0x802004
  800f5a:	74 1c                	je     800f78 <dev_lookup+0x35>
  800f5c:	b9 04 20 80 00       	mov    $0x802004,%ecx
		if (devtab[i]->dev_id == dev_id) {
  800f61:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  800f64:	39 18                	cmp    %ebx,(%eax)
  800f66:	75 09                	jne    800f71 <dev_lookup+0x2e>
			*dev = devtab[i];
  800f68:	89 06                	mov    %eax,(%esi)
			return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	eb 29                	jmp    800f9a <dev_lookup+0x57>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f71:	42                   	inc    %edx
  800f72:	83 3c 91 00          	cmpl   $0x0,(%ecx,%edx,4)
  800f76:	75 e9                	jne    800f61 <dev_lookup+0x1e>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	53                   	push   %ebx
  800f7c:	a1 04 30 80 00       	mov    0x803004,%eax
  800f81:	8b 40 48             	mov    0x48(%eax),%eax
  800f84:	50                   	push   %eax
  800f85:	68 e4 1d 80 00       	push   $0x801de4
  800f8a:	e8 7d f3 ff ff       	call   80030c <cprintf>
	*dev = 0;
  800f8f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	return -E_INVAL;
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <close>:

int
close(int fdnum)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800faa:	50                   	push   %eax
  800fab:	ff 75 08             	pushl  0x8(%ebp)
  800fae:	e8 c3 fe ff ff       	call   800e76 <fd_lookup>
  800fb3:	83 c4 08             	add    $0x8,%esp
		return r;
  800fb6:	89 c2                	mov    %eax,%edx
close(int fdnum)
{
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 0f                	js     800fcb <close+0x2a>
		return r;
	else
		return fd_close(fd, 1);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	6a 01                	push   $0x1
  800fc1:	ff 75 fc             	pushl  -0x4(%ebp)
  800fc4:	e8 fb fe ff ff       	call   800ec4 <fd_close>
  800fc9:	89 c2                	mov    %eax,%edx
}
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <close_all>:

void
close_all(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	53                   	push   %ebx
  800fdf:	e8 bd ff ff ff       	call   800fa1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	43                   	inc    %ebx
  800fe8:	83 fb 1f             	cmp    $0x1f,%ebx
  800feb:	7e ee                	jle    800fdb <close_all+0xc>
		close(i);
}
  800fed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ffe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	ff 75 08             	pushl  0x8(%ebp)
  801005:	e8 6c fe ff ff       	call   800e76 <fd_lookup>
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	85 db                	test   %ebx,%ebx
  801011:	0f 88 b7 00 00 00    	js     8010ce <dup+0xdc>
		return r;
	close(newfdnum);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	57                   	push   %edi
  80101b:	e8 81 ff ff ff       	call   800fa1 <close>

	newfd = INDEX2FD(newfdnum);
  801020:	89 f8                	mov    %edi,%eax
  801022:	c1 e0 0c             	shl    $0xc,%eax
  801025:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80102b:	ff 75 f0             	pushl  -0x10(%ebp)
  80102e:	e8 d1 fd ff ff       	call   800e04 <fd2data>
  801033:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801035:	89 34 24             	mov    %esi,(%esp)
  801038:	e8 c7 fd ff ff       	call   800e04 <fd2data>
  80103d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801040:	89 d8                	mov    %ebx,%eax
  801042:	c1 e8 16             	shr    $0x16,%eax
  801045:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104c:	83 c4 14             	add    $0x14,%esp
  80104f:	a8 01                	test   $0x1,%al
  801051:	74 33                	je     801086 <dup+0x94>
  801053:	89 da                	mov    %ebx,%edx
  801055:	c1 ea 0c             	shr    $0xc,%edx
  801058:	b9 00 00 40 ef       	mov    $0xef400000,%ecx
  80105d:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  801060:	a8 01                	test   $0x1,%al
  801062:	74 22                	je     801086 <dup+0x94>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	8b 04 91             	mov    (%ecx,%edx,4),%eax
  80106a:	25 07 0e 00 00       	and    $0xe07,%eax
  80106f:	50                   	push   %eax
  801070:	ff 75 ec             	pushl  -0x14(%ebp)
  801073:	6a 00                	push   $0x0
  801075:	53                   	push   %ebx
  801076:	6a 00                	push   $0x0
  801078:	e8 c8 fb ff ff       	call   800c45 <sys_page_map>
  80107d:	89 c3                	mov    %eax,%ebx
  80107f:	83 c4 20             	add    $0x20,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 2e                	js     8010b4 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108c:	89 d0                	mov    %edx,%eax
  80108e:	c1 e8 0c             	shr    $0xc,%eax
  801091:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801098:	25 07 0e 00 00       	and    $0xe07,%eax
  80109d:	50                   	push   %eax
  80109e:	56                   	push   %esi
  80109f:	6a 00                	push   $0x0
  8010a1:	52                   	push   %edx
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 9c fb ff ff       	call   800c45 <sys_page_map>
  8010a9:	89 c3                	mov    %eax,%ebx
  8010ab:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ae:	89 f8                	mov    %edi,%eax
	nva = fd2data(newfd);

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b0:	85 db                	test   %ebx,%ebx
  8010b2:	79 1a                	jns    8010ce <dup+0xdc>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 c8 fb ff ff       	call   800c87 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	ff 75 ec             	pushl  -0x14(%ebp)
  8010c5:	6a 00                	push   $0x0
  8010c7:	e8 bb fb ff ff       	call   800c87 <sys_page_unmap>
	return r;
  8010cc:	89 d8                	mov    %ebx,%eax
}
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 14             	sub    $0x14,%esp
  8010dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e0:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	53                   	push   %ebx
  8010e5:	e8 8c fd ff ff       	call   800e76 <fd_lookup>
  8010ea:	83 c4 08             	add    $0x8,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 18                	js     801109 <read+0x33>
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8010fb:	ff 30                	pushl  (%eax)
  8010fd:	e8 41 fe ff ff       	call   800f43 <dev_lookup>
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	79 04                	jns    80110d <read+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  801109:	89 c2                	mov    %eax,%edx
  80110b:	eb 4e                	jmp    80115b <read+0x85>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801110:	8b 40 08             	mov    0x8(%eax),%eax
  801113:	83 e0 03             	and    $0x3,%eax
  801116:	83 f8 01             	cmp    $0x1,%eax
  801119:	75 1e                	jne    801139 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111b:	83 ec 04             	sub    $0x4,%esp
  80111e:	53                   	push   %ebx
  80111f:	a1 04 30 80 00       	mov    0x803004,%eax
  801124:	8b 40 48             	mov    0x48(%eax),%eax
  801127:	50                   	push   %eax
  801128:	68 25 1e 80 00       	push   $0x801e25
  80112d:	e8 da f1 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  801132:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801137:	eb 22                	jmp    80115b <read+0x85>
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801139:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80113e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801141:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  801145:	74 14                	je     80115b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	ff 75 10             	pushl  0x10(%ebp)
  80114d:	ff 75 0c             	pushl  0xc(%ebp)
  801150:	ff 75 f8             	pushl  -0x8(%ebp)
  801153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801156:	ff 50 08             	call   *0x8(%eax)
  801159:	89 c2                	mov    %eax,%edx
}
  80115b:	89 d0                	mov    %edx,%eax
  80115d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	53                   	push   %ebx
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80116e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801171:	bb 00 00 00 00       	mov    $0x0,%ebx
  801176:	39 f3                	cmp    %esi,%ebx
  801178:	73 25                	jae    80119f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	89 f0                	mov    %esi,%eax
  80117f:	29 d8                	sub    %ebx,%eax
  801181:	50                   	push   %eax
  801182:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
  801185:	50                   	push   %eax
  801186:	ff 75 08             	pushl  0x8(%ebp)
  801189:	e8 48 ff ff ff       	call   8010d6 <read>
		if (m < 0)
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 0c                	js     8011a1 <readn+0x3f>
			return m;
		if (m == 0)
  801195:	85 c0                	test   %eax,%eax
  801197:	74 06                	je     80119f <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801199:	01 c3                	add    %eax,%ebx
  80119b:	39 f3                	cmp    %esi,%ebx
  80119d:	72 db                	jb     80117a <readn+0x18>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80119f:	89 d8                	mov    %ebx,%eax
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 14             	sub    $0x14,%esp
  8011b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	53                   	push   %ebx
  8011b8:	e8 b9 fc ff ff       	call   800e76 <fd_lookup>
  8011bd:	83 c4 08             	add    $0x8,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 18                	js     8011dc <write+0x33>
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ca:	50                   	push   %eax
  8011cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011ce:	ff 30                	pushl  (%eax)
  8011d0:	e8 6e fd ff ff       	call   800f43 <dev_lookup>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	79 04                	jns    8011e0 <write+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	eb 49                	jmp    801229 <write+0x80>
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e7:	75 1e                	jne    801207 <write+0x5e>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	53                   	push   %ebx
  8011ed:	a1 04 30 80 00       	mov    0x803004,%eax
  8011f2:	8b 40 48             	mov    0x48(%eax),%eax
  8011f5:	50                   	push   %eax
  8011f6:	68 41 1e 80 00       	push   $0x801e41
  8011fb:	e8 0c f1 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  801200:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801205:	eb 22                	jmp    801229 <write+0x80>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801207:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801213:	74 14                	je     801229 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	ff 75 10             	pushl  0x10(%ebp)
  80121b:	ff 75 0c             	pushl  0xc(%ebp)
  80121e:	ff 75 f8             	pushl  -0x8(%ebp)
  801221:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801224:	ff 50 0c             	call   *0xc(%eax)
  801227:	89 c2                	mov    %eax,%edx
}
  801229:	89 d0                	mov    %edx,%eax
  80122b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122e:	c9                   	leave  
  80122f:	c3                   	ret    

00801230 <seek>:

int
seek(int fdnum, off_t offset)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 04             	sub    $0x4,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801236:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 34 fc ff ff       	call   800e76 <fd_lookup>
  801242:	83 c4 08             	add    $0x8,%esp
		return r;
  801245:	89 c2                	mov    %eax,%edx
seek(int fdnum, off_t offset)
{
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801247:	85 c0                	test   %eax,%eax
  801249:	78 0e                	js     801259 <seek+0x29>
		return r;
	fd->fd_offset = offset;
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801251:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801254:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801259:	89 d0                	mov    %edx,%eax
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	53                   	push   %ebx
  801261:	83 ec 14             	sub    $0x14,%esp
  801264:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801267:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	53                   	push   %ebx
  80126c:	e8 05 fc ff ff       	call   800e76 <fd_lookup>
  801271:	83 c4 08             	add    $0x8,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 18                	js     801290 <ftruncate+0x33>
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801282:	ff 30                	pushl  (%eax)
  801284:	e8 ba fc ff ff       	call   800f43 <dev_lookup>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	79 04                	jns    801294 <ftruncate+0x37>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0) 
		return r;
  801290:	89 c2                	mov    %eax,%edx
  801292:	eb 46                	jmp    8012da <ftruncate+0x7d>
	

	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801294:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801297:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129b:	75 1e                	jne    8012bb <ftruncate+0x5e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80129d:	83 ec 04             	sub    $0x4,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	a1 04 30 80 00       	mov    0x803004,%eax
  8012a6:	8b 40 48             	mov    0x48(%eax),%eax
  8012a9:	50                   	push   %eax
  8012aa:	68 04 1e 80 00       	push   $0x801e04
  8012af:	e8 58 f0 ff ff       	call   80030c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b9:	eb 1f                	jmp    8012da <ftruncate+0x7d>
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c3:	83 78 18 00          	cmpl   $0x0,0x18(%eax)
  8012c7:	74 11                	je     8012da <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	ff 75 0c             	pushl  0xc(%ebp)
  8012cf:	ff 75 f8             	pushl  -0x8(%ebp)
  8012d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d5:	ff 50 18             	call   *0x18(%eax)
  8012d8:	89 c2                	mov    %eax,%edx
}
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 14             	sub    $0x14,%esp
  8012e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012eb:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	ff 75 08             	pushl  0x8(%ebp)
  8012f2:	e8 7f fb ff ff       	call   800e76 <fd_lookup>
  8012f7:	83 c4 08             	add    $0x8,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 18                	js     801316 <fstat+0x35>
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801308:	ff 30                	pushl  (%eax)
  80130a:	e8 34 fc ff ff       	call   800f43 <dev_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	79 04                	jns    80131a <fstat+0x39>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
  801316:	89 c2                	mov    %eax,%edx
  801318:	eb 3a                	jmp    801354 <fstat+0x73>
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80131a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80131f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801322:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801326:	74 2c                	je     801354 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801328:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80132b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801332:	00 00 00 
	stat->st_isdir = 0;
  801335:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80133c:	00 00 00 
	stat->st_dev = dev;
  80133f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801342:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	53                   	push   %ebx
  80134c:	ff 75 f8             	pushl  -0x8(%ebp)
  80134f:	ff 50 14             	call   *0x14(%eax)
  801352:	89 c2                	mov    %eax,%edx
}
  801354:	89 d0                	mov    %edx,%eax
  801356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	6a 00                	push   $0x0
  801365:	ff 75 08             	pushl  0x8(%ebp)
  801368:	e8 72 00 00 00       	call   8013df <open>
  80136d:	89 c6                	mov    %eax,%esi
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	85 f6                	test   %esi,%esi
  801374:	78 18                	js     80138e <stat+0x33>
		return fd;
	r = fstat(fd, stat);
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	ff 75 0c             	pushl  0xc(%ebp)
  80137c:	56                   	push   %esi
  80137d:	e8 5f ff ff ff       	call   8012e1 <fstat>
  801382:	89 c3                	mov    %eax,%ebx
	close(fd);
  801384:	89 34 24             	mov    %esi,(%esp)
  801387:	e8 15 fc ff ff       	call   800fa1 <close>
	return r;
  80138c:	89 d8                	mov    %ebx,%eax
}
  80138e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	c9                   	leave  
  801394:	c3                   	ret    
  801395:	00 00                	add    %al,(%eax)
	...

00801398 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 08             	sub    $0x8,%esp
	static envid_t fsenv;
	if (fsenv == 0) {
  80139e:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  8013a5:	75 12                	jne    8013b9 <fsipc+0x21>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	6a 02                	push   $0x2
  8013ac:	e8 00 03 00 00       	call   8016b1 <ipc_find_env>
  8013b1:	a3 00 30 80 00       	mov    %eax,0x803000
  8013b6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b9:	6a 07                	push   $0x7
  8013bb:	68 00 40 80 00       	push   $0x804000
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	ff 35 00 30 80 00    	pushl  0x803000
  8013c9:	e8 82 02 00 00       	call   801650 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ce:	83 c4 0c             	add    $0xc,%esp
  8013d1:	6a 00                	push   $0x0
  8013d3:	ff 75 0c             	pushl  0xc(%ebp)
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 03 02 00 00       	call   8015e0 <ipc_recv>
}
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 1c             	sub    $0x1c,%esp
  8013e7:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  8013ea:	56                   	push   %esi
  8013eb:	e8 e4 f3 ff ff       	call   8007d4 <strlen>
  8013f0:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  8013f3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
  8013f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8013fd:	7f 5f                	jg     80145e <open+0x7f>
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	e8 11 fa ff ff       	call   800e1c <fd_alloc>
  80140b:	83 c4 10             	add    $0x10,%esp
		return r;
  80140e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;
	int r;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
	if ((r = fd_alloc(&fd)) < 0)
  801410:	85 c0                	test   %eax,%eax
  801412:	78 4a                	js     80145e <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	56                   	push   %esi
  801418:	68 00 40 80 00       	push   $0x804000
  80141d:	e8 ee f3 ff ff       	call   800810 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801422:	8b 45 0c             	mov    0xc(%ebp),%eax
  801425:	a3 00 44 80 00       	mov    %eax,0x804400


	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80142a:	83 c4 08             	add    $0x8,%esp
  80142d:	ff 75 f4             	pushl  -0xc(%ebp)
  801430:	6a 01                	push   $0x1
  801432:	e8 61 ff ff ff       	call   801398 <fsipc>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	79 11                	jns    801451 <open+0x72>
		fd_close(fd, 0);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	6a 00                	push   $0x0
  801445:	ff 75 f4             	pushl  -0xc(%ebp)
  801448:	e8 77 fa ff ff       	call   800ec4 <fd_close>
		return r;
  80144d:	89 da                	mov    %ebx,%edx
  80144f:	eb 0d                	jmp    80145e <open+0x7f>
	}
	
	return fd2num(fd);	
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	ff 75 f4             	pushl  -0xc(%ebp)
  801457:	e8 98 f9 ff ff       	call   800df4 <fd2num>
  80145c:	89 c2                	mov    %eax,%edx
}
  80145e:	89 d0                	mov    %edx,%eax
  801460:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80146d:	8b 45 08             	mov    0x8(%ebp),%eax
  801470:	8b 40 0c             	mov    0xc(%eax),%eax
  801473:	a3 00 40 80 00       	mov    %eax,0x804000
	return fsipc(FSREQ_FLUSH, NULL);
  801478:	6a 00                	push   $0x0
  80147a:	6a 06                	push   $0x6
  80147c:	e8 17 ff ff ff       	call   801398 <fsipc>
}
  801481:	c9                   	leave  
  801482:	c3                   	ret    

00801483 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 0c             	sub    $0xc,%esp
	// The bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	8b 40 0c             	mov    0xc(%eax),%eax
  801490:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.read.req_n = n;
  801495:	8b 45 10             	mov    0x10(%ebp),%eax
  801498:	a3 04 40 80 00       	mov    %eax,0x804004
		

	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80149d:	6a 00                	push   $0x0
  80149f:	6a 03                	push   $0x3
  8014a1:	e8 f2 fe ff ff       	call   801398 <fsipc>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	85 db                	test   %ebx,%ebx
  8014ad:	78 13                	js     8014c2 <devfile_read+0x3f>
		return r;

	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	68 00 40 80 00       	push   $0x804000
  8014b8:	ff 75 0c             	pushl  0xc(%ebp)
  8014bb:	e8 ec f4 ff ff       	call   8009ac <memmove>
	return r;
  8014c0:	89 d8                	mov    %ebx,%eax
}
  8014c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	8b 45 10             	mov    0x10(%ebp),%eax
	// Be careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d6:	89 15 00 40 80 00    	mov    %edx,0x804000
	fsipcbuf.write.req_n = n;
  8014dc:	a3 04 40 80 00       	mov    %eax,0x804004
	memmove(fsipcbuf.write.req_buf, buf, MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t))));
  8014e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014e6:	76 05                	jbe    8014ed <devfile_write+0x26>
  8014e8:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014ed:	83 ec 04             	sub    $0x4,%esp
  8014f0:	50                   	push   %eax
  8014f1:	ff 75 0c             	pushl  0xc(%ebp)
  8014f4:	68 08 40 80 00       	push   $0x804008
  8014f9:	e8 ae f4 ff ff       	call   8009ac <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014fe:	83 c4 08             	add    $0x8,%esp
  801501:	6a 00                	push   $0x0
  801503:	6a 04                	push   $0x4
  801505:	e8 8e fe ff ff       	call   801398 <fsipc>
  80150a:	83 c4 10             	add    $0x10,%esp
		return r;
	return r;
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <devfile_stat>:

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
  80151c:	8b 40 0c             	mov    0xc(%eax),%eax
  80151f:	a3 00 40 80 00       	mov    %eax,0x804000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801524:	6a 00                	push   $0x0
  801526:	6a 05                	push   $0x5
  801528:	e8 6b fe ff ff       	call   801398 <fsipc>
  80152d:	83 c4 10             	add    $0x10,%esp
		return r;
  801530:	89 c2                	mov    %eax,%edx
devfile_stat(struct Fd *fd, struct Stat *st)
{
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801532:	85 c0                	test   %eax,%eax
  801534:	78 29                	js     80155f <devfile_stat+0x50>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	68 00 40 80 00       	push   $0x804000
  80153e:	53                   	push   %ebx
  80153f:	e8 cc f2 ff ff       	call   800810 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801544:	a1 80 40 80 00       	mov    0x804080,%eax
  801549:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154f:	a1 84 40 80 00       	mov    0x804084,%eax
  801554:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80155f:	89 d0                	mov    %edx,%eax
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <devfile_trunc>:

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 10             	sub    $0x10,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	8b 40 0c             	mov    0xc(%eax),%eax
  801572:	a3 00 40 80 00       	mov    %eax,0x804000
	fsipcbuf.set_size.req_size = newsize;
  801577:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157a:	a3 04 40 80 00       	mov    %eax,0x804004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80157f:	6a 00                	push   $0x0
  801581:	6a 02                	push   $0x2
  801583:	e8 10 fe ff ff       	call   801398 <fsipc>
}
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <remove>:

// Delete a file
int
remove(const char *path)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	53                   	push   %ebx
  80158e:	83 ec 10             	sub    $0x10,%esp
  801591:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801594:	53                   	push   %ebx
  801595:	e8 3a f2 ff ff       	call   8007d4 <strlen>
  80159a:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_PATH;
  80159d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx

// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
  8015a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a7:	7f 1c                	jg     8015c5 <remove+0x3b>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	68 00 40 80 00       	push   $0x804000
  8015b2:	e8 59 f2 ff ff       	call   800810 <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	6a 00                	push   $0x0
  8015bc:	6a 07                	push   $0x7
  8015be:	e8 d5 fd ff ff       	call   801398 <fsipc>
  8015c3:	89 c2                	mov    %eax,%edx
}
  8015c5:	89 d0                	mov    %edx,%eax
  8015c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 10             	sub    $0x10,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d2:	6a 00                	push   $0x0
  8015d4:	6a 08                	push   $0x8
  8015d6:	e8 bd fd ff ff       	call   801398 <fsipc>
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    
  8015dd:	00 00                	add    %al,(%eax)
	...

008015e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	75 05                	jne    8015f7 <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  8015f2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	50                   	push   %eax
  8015fb:	e8 b2 f7 ff ff       	call   800db2 <sys_ipc_recv>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	79 16                	jns    80161d <ipc_recv+0x3d>
		if (from_env_store)
  801607:	85 db                	test   %ebx,%ebx
  801609:	74 06                	je     801611 <ipc_recv+0x31>
			*from_env_store = 0;
  80160b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  801611:	85 f6                	test   %esi,%esi
  801613:	74 34                	je     801649 <ipc_recv+0x69>
			*perm_store = 0;
  801615:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  80161b:	eb 2c                	jmp    801649 <ipc_recv+0x69>
	}

	if (from_env_store)
  80161d:	85 db                	test   %ebx,%ebx
  80161f:	74 0a                	je     80162b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801621:	a1 04 30 80 00       	mov    0x803004,%eax
  801626:	8b 40 74             	mov    0x74(%eax),%eax
  801629:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  80162b:	85 f6                	test   %esi,%esi
  80162d:	74 12                	je     801641 <ipc_recv+0x61>
  80162f:	8b 15 04 30 80 00    	mov    0x803004,%edx
  801635:	8b 42 78             	mov    0x78(%edx),%eax
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 05                	je     801641 <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  80163c:	8b 42 78             	mov    0x78(%edx),%eax
  80163f:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  801641:	a1 04 30 80 00       	mov    0x803004,%eax
  801646:	8b 40 70             	mov    0x70(%eax),%eax
}
  801649:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	57                   	push   %edi
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	8b 7d 08             	mov    0x8(%ebp),%edi
  80165c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80165f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  801662:	85 db                	test   %ebx,%ebx
  801664:	74 10                	je     801676 <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  801666:	ff 75 14             	pushl  0x14(%ebp)
  801669:	53                   	push   %ebx
  80166a:	56                   	push   %esi
  80166b:	57                   	push   %edi
  80166c:	e8 1e f7 ff ff       	call   800d8f <sys_ipc_try_send>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb 11                	jmp    801687 <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  801676:	6a 00                	push   $0x0
  801678:	68 00 00 c0 ee       	push   $0xeec00000
  80167d:	56                   	push   %esi
  80167e:	57                   	push   %edi
  80167f:	e8 0b f7 ff ff       	call   800d8f <sys_ipc_try_send>
  801684:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  801687:	85 c0                	test   %eax,%eax
  801689:	74 1e                	je     8016a9 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  80168b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80168e:	74 12                	je     8016a2 <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  801690:	50                   	push   %eax
  801691:	68 60 1e 80 00       	push   $0x801e60
  801696:	6a 4a                	push   $0x4a
  801698:	68 84 1e 80 00       	push   $0x801e84
  80169d:	e8 8e eb ff ff       	call   800230 <_panic>
		}
		sys_yield();
  8016a2:	e8 3c f5 ff ff       	call   800be3 <sys_yield>
  8016a7:	eb b9                	jmp    801662 <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  8016a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5e                   	pop    %esi
  8016ae:	5f                   	pop    %edi
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8016b8:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  8016bd:	89 d0                	mov    %edx,%eax
  8016bf:	c1 e0 05             	shl    $0x5,%eax
  8016c2:	29 d0                	sub    %edx,%eax
  8016c4:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8016cb:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  8016d1:	8b 40 50             	mov    0x50(%eax),%eax
  8016d4:	39 d8                	cmp    %ebx,%eax
  8016d6:	75 0b                	jne    8016e3 <ipc_find_env+0x32>
			return envs[i].env_id;
  8016d8:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  8016de:	8b 40 40             	mov    0x40(%eax),%eax
  8016e1:	eb 0e                	jmp    8016f1 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8016e3:	42                   	inc    %edx
  8016e4:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8016ea:	7e d1                	jle    8016bd <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f1:	5b                   	pop    %ebx
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	57                   	push   %edi
  8016f8:	56                   	push   %esi
  8016f9:	83 ec 14             	sub    $0x14,%esp
  8016fc:	8b 55 14             	mov    0x14(%ebp),%edx
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801705:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801708:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80170a:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80170d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  801710:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  801713:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801715:	75 11                	jne    801728 <__udivdi3+0x34>
    {
      if (d0 > n1)
  801717:	39 f8                	cmp    %edi,%eax
  801719:	76 4d                	jbe    801768 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80171b:	89 fa                	mov    %edi,%edx
  80171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801720:	f7 75 e4             	divl   -0x1c(%ebp)
  801723:	89 c7                	mov    %eax,%edi
  801725:	eb 09                	jmp    801730 <__udivdi3+0x3c>
  801727:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801728:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  80172b:	76 17                	jbe    801744 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  80172d:	31 ff                	xor    %edi,%edi
  80172f:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  801730:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801737:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80173a:	83 c4 14             	add    $0x14,%esp
  80173d:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80173e:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801740:	5f                   	pop    %edi
  801741:	c9                   	leave  
  801742:	c3                   	ret    
  801743:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801744:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  801748:	89 c7                	mov    %eax,%edi
  80174a:	83 f7 1f             	xor    $0x1f,%edi
  80174d:	75 4d                	jne    80179c <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80174f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801752:	77 0a                	ja     80175e <__udivdi3+0x6a>
  801754:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  801757:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801759:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80175c:	72 d2                	jb     801730 <__udivdi3+0x3c>
		{
		  q0 = 1;
  80175e:	bf 01 00 00 00       	mov    $0x1,%edi
  801763:	eb cb                	jmp    801730 <__udivdi3+0x3c>
  801765:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176b:	85 c0                	test   %eax,%eax
  80176d:	75 0e                	jne    80177d <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80176f:	b8 01 00 00 00       	mov    $0x1,%eax
  801774:	31 c9                	xor    %ecx,%ecx
  801776:	31 d2                	xor    %edx,%edx
  801778:	f7 f1                	div    %ecx
  80177a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80177d:	89 f0                	mov    %esi,%eax
  80177f:	31 d2                	xor    %edx,%edx
  801781:	f7 75 e4             	divl   -0x1c(%ebp)
  801784:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80178d:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801790:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801793:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801795:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801796:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801798:	5f                   	pop    %edi
  801799:	c9                   	leave  
  80179a:	c3                   	ret    
  80179b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80179c:	b8 20 00 00 00       	mov    $0x20,%eax
  8017a1:	29 f8                	sub    %edi,%eax
  8017a3:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  8017a6:	89 f9                	mov    %edi,%ecx
  8017a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ab:	d3 e2                	shl    %cl,%edx
  8017ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b0:	8a 4d e8             	mov    -0x18(%ebp),%cl
  8017b3:	d3 e8                	shr    %cl,%eax
  8017b5:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  8017b7:	89 f9                	mov    %edi,%ecx
  8017b9:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8017bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8017bf:	8a 4d e8             	mov    -0x18(%ebp),%cl
  8017c2:	89 f2                	mov    %esi,%edx
  8017c4:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8017c6:	89 f9                	mov    %edi,%ecx
  8017c8:	d3 e6                	shl    %cl,%esi
  8017ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cd:	8a 4d e8             	mov    -0x18(%ebp),%cl
  8017d0:	d3 e8                	shr    %cl,%eax
  8017d2:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  8017d4:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8017d6:	89 f0                	mov    %esi,%eax
  8017d8:	f7 75 f4             	divl   -0xc(%ebp)
  8017db:	89 d6                	mov    %edx,%esi
  8017dd:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8017df:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8017e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e5:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8017e7:	39 f2                	cmp    %esi,%edx
  8017e9:	77 0f                	ja     8017fa <__udivdi3+0x106>
  8017eb:	0f 85 3f ff ff ff    	jne    801730 <__udivdi3+0x3c>
  8017f1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8017f4:	0f 86 36 ff ff ff    	jbe    801730 <__udivdi3+0x3c>
		{
		  q0--;
  8017fa:	4f                   	dec    %edi
  8017fb:	e9 30 ff ff ff       	jmp    801730 <__udivdi3+0x3c>

00801800 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	57                   	push   %edi
  801804:	56                   	push   %esi
  801805:	83 ec 30             	sub    $0x30,%esp
  801808:	8b 55 14             	mov    0x14(%ebp),%edx
  80180b:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  80180e:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  801810:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801813:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  801815:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80181b:	85 ff                	test   %edi,%edi
  80181d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801824:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  80182b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80182e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  801831:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801834:	75 3e                	jne    801874 <__umoddi3+0x74>
    {
      if (d0 > n1)
  801836:	39 d6                	cmp    %edx,%esi
  801838:	0f 86 a2 00 00 00    	jbe    8018e0 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80183e:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801840:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801843:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801845:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  801848:	74 1b                	je     801865 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  80184a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80184d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  801850:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801857:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80185a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80185d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801860:	89 10                	mov    %edx,(%eax)
  801862:	89 48 04             	mov    %ecx,0x4(%eax)
  801865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801868:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80186b:	83 c4 30             	add    $0x30,%esp
  80186e:	5e                   	pop    %esi
  80186f:	5f                   	pop    %edi
  801870:	c9                   	leave  
  801871:	c3                   	ret    
  801872:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801874:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  801877:	76 1f                	jbe    801898 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801879:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  80187c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  80187f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  801882:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801885:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801888:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80188b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80188e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801891:	83 c4 30             	add    $0x30,%esp
  801894:	5e                   	pop    %esi
  801895:	5f                   	pop    %edi
  801896:	c9                   	leave  
  801897:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801898:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80189b:	83 f0 1f             	xor    $0x1f,%eax
  80189e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8018a1:	75 61                	jne    801904 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8018a3:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  8018a6:	77 05                	ja     8018ad <__umoddi3+0xad>
  8018a8:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  8018ab:	72 10                	jb     8018bd <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8018ad:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8018b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018b3:	29 f0                	sub    %esi,%eax
  8018b5:	19 fa                	sbb    %edi,%edx
  8018b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8018ba:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  8018bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8018c0:	85 d2                	test   %edx,%edx
  8018c2:	74 a1                	je     801865 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  8018c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  8018c7:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8018ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  8018cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  8018d0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8018d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018d9:	89 01                	mov    %eax,(%ecx)
  8018db:	89 51 04             	mov    %edx,0x4(%ecx)
  8018de:	eb 85                	jmp    801865 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8018e0:	85 f6                	test   %esi,%esi
  8018e2:	75 0b                	jne    8018ef <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8018e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e9:	31 d2                	xor    %edx,%edx
  8018eb:	f7 f6                	div    %esi
  8018ed:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8018ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8018f2:	89 fa                	mov    %edi,%edx
  8018f4:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8018f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8018f9:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8018fc:	f7 f6                	div    %esi
  8018fe:	e9 3d ff ff ff       	jmp    801840 <__umoddi3+0x40>
  801903:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801904:	b8 20 00 00 00       	mov    $0x20,%eax
  801909:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  80190c:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  80190f:	89 fa                	mov    %edi,%edx
  801911:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801914:	d3 e2                	shl    %cl,%edx
  801916:	89 f0                	mov    %esi,%eax
  801918:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80191b:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  80191d:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801920:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801922:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801924:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801927:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80192a:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80192c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  80192e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801931:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  801934:	d3 e0                	shl    %cl,%eax
  801936:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801939:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80193c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80193f:	d3 e8                	shr    %cl,%eax
  801941:	0b 45 cc             	or     -0x34(%ebp),%eax
  801944:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  801947:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80194a:	f7 f7                	div    %edi
  80194c:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80194f:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801952:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801954:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801957:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80195a:	77 0a                	ja     801966 <__umoddi3+0x166>
  80195c:	75 12                	jne    801970 <__umoddi3+0x170>
  80195e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801961:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801964:	76 0a                	jbe    801970 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801966:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801969:	29 f1                	sub    %esi,%ecx
  80196b:	19 fa                	sbb    %edi,%edx
  80196d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801970:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801973:	85 c0                	test   %eax,%eax
  801975:	0f 84 ea fe ff ff    	je     801865 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80197b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80197e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801981:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801984:	19 d1                	sbb    %edx,%ecx
  801986:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801989:	89 ca                	mov    %ecx,%edx
  80198b:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80198e:	d3 e2                	shl    %cl,%edx
  801990:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801993:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801996:	d3 e8                	shr    %cl,%eax
  801998:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80199a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80199d:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80199f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  8019a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019a5:	e9 ad fe ff ff       	jmp    801857 <__umoddi3+0x57>
