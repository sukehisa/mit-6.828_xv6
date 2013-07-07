
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cf 00 00 00       	call   800100 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003a:	e8 f2 0d 00 00       	call   800e31 <sfork>
  80003f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	74 4c                	je     800092 <umain+0x5e>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	ff 35 08 20 80 00    	pushl  0x802008
  80004f:	83 ec 08             	sub    $0x8,%esp
  800052:	e8 4d 0a 00 00       	call   800aa4 <sys_getenvid>
  800057:	83 c4 08             	add    $0x8,%esp
  80005a:	50                   	push   %eax
  80005b:	68 60 12 80 00       	push   $0x801260
  800060:	e8 87 01 00 00       	call   8001ec <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800065:	83 c4 0c             	add    $0xc,%esp
  800068:	ff 75 fc             	pushl  -0x4(%ebp)
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	e8 31 0a 00 00       	call   800aa4 <sys_getenvid>
  800073:	83 c4 08             	add    $0x8,%esp
  800076:	50                   	push   %eax
  800077:	68 7a 12 80 00       	push   $0x80127a
  80007c:	e8 6b 01 00 00       	call   8001ec <cprintf>
		ipc_send(who, 0, 0, 0);
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	6a 00                	push   $0x0
  800087:	ff 75 fc             	pushl  -0x4(%ebp)
  80008a:	e8 29 0e 00 00       	call   800eb8 <ipc_send>
  80008f:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	6a 00                	push   $0x0
  800097:	6a 00                	push   $0x0
  800099:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80009c:	50                   	push   %eax
  80009d:	e8 a6 0d 00 00       	call   800e48 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8000ab:	8b 42 48             	mov    0x48(%edx),%eax
  8000ae:	50                   	push   %eax
  8000af:	52                   	push   %edx
  8000b0:	ff 75 fc             	pushl  -0x4(%ebp)
  8000b3:	ff 35 04 20 80 00    	pushl  0x802004
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	e8 e3 09 00 00       	call   800aa4 <sys_getenvid>
  8000c1:	83 c4 08             	add    $0x8,%esp
  8000c4:	50                   	push   %eax
  8000c5:	68 90 12 80 00       	push   $0x801290
  8000ca:	e8 1d 01 00 00       	call   8001ec <cprintf>
		if (val == 10)
  8000cf:	83 c4 20             	add    $0x20,%esp
  8000d2:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000d9:	74 20                	je     8000fb <umain+0xc7>
			return;
		++val;
  8000db:	ff 05 04 20 80 00    	incl   0x802004
		ipc_send(who, 0, 0, 0);
  8000e1:	6a 00                	push   $0x0
  8000e3:	6a 00                	push   $0x0
  8000e5:	6a 00                	push   $0x0
  8000e7:	ff 75 fc             	pushl  -0x4(%ebp)
  8000ea:	e8 c9 0d 00 00       	call   800eb8 <ipc_send>
		if (val == 10)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f9:	75 97                	jne    800092 <umain+0x5e>
			return;
	}

}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	8b 75 08             	mov    0x8(%ebp),%esi
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  80010b:	e8 94 09 00 00       	call   800aa4 <sys_getenvid>
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	89 c2                	mov    %eax,%edx
  800117:	c1 e2 05             	shl    $0x5,%edx
  80011a:	29 c2                	sub    %eax,%edx
  80011c:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800123:	89 15 08 20 80 00    	mov    %edx,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800129:	85 f6                	test   %esi,%esi
  80012b:	7e 07                	jle    800134 <libmain+0x34>
		binaryname = argv[0];
  80012d:	8b 03                	mov    (%ebx),%eax
  80012f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	53                   	push   %ebx
  800138:	56                   	push   %esi
  800139:	e8 f6 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013e:	e8 09 00 00 00       	call   80014c <exit>
}
  800143:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	c9                   	leave  
  800149:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800152:	6a 00                	push   $0x0
  800154:	e8 0a 09 00 00       	call   800a63 <sys_env_destroy>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    
	...

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 04             	sub    $0x4,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 1a                	jne    800193 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	68 ff 00 00 00       	push   $0xff
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	50                   	push   %eax
  800185:	e8 96 08 00 00       	call   800a20 <sys_cputs>
		b->idx = 0;
  80018a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800190:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800193:	ff 43 04             	incl   0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	68 5c 01 80 00       	push   $0x80015c
  8001ca:	e8 49 01 00 00       	call   800318 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cf:	83 c4 08             	add    $0x8,%esp
  8001d2:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  8001d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 3c 08 00 00       	call   800a20 <sys_cputs>

	return b.cnt;
  8001e4:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f5:	50                   	push   %eax
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	e8 9d ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	8b 75 10             	mov    0x10(%ebp),%esi
  80020c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800212:	8b 45 18             	mov    0x18(%ebp),%eax
  800215:	ba 00 00 00 00       	mov    $0x0,%edx
  80021a:	39 fa                	cmp    %edi,%edx
  80021c:	77 39                	ja     800257 <printnum+0x57>
  80021e:	72 04                	jb     800224 <printnum+0x24>
  800220:	39 f0                	cmp    %esi,%eax
  800222:	77 33                	ja     800257 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 20             	pushl  0x20(%ebp)
  80022a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80022d:	50                   	push   %eax
  80022e:	ff 75 18             	pushl  0x18(%ebp)
  800231:	8b 45 18             	mov    0x18(%ebp),%eax
  800234:	ba 00 00 00 00       	mov    $0x0,%edx
  800239:	52                   	push   %edx
  80023a:	50                   	push   %eax
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	e8 66 0d 00 00       	call   800fa8 <__udivdi3>
  800242:	83 c4 10             	add    $0x10,%esp
  800245:	52                   	push   %edx
  800246:	50                   	push   %eax
  800247:	ff 75 0c             	pushl  0xc(%ebp)
  80024a:	ff 75 08             	pushl  0x8(%ebp)
  80024d:	e8 ae ff ff ff       	call   800200 <printnum>
  800252:	83 c4 20             	add    $0x20,%esp
  800255:	eb 19                	jmp    800270 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800257:	4b                   	dec    %ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7e 14                	jle    800270 <printnum+0x70>
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	ff 75 0c             	pushl  0xc(%ebp)
  800262:	ff 75 20             	pushl  0x20(%ebp)
  800265:	ff 55 08             	call   *0x8(%ebp)
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	4b                   	dec    %ebx
  80026c:	85 db                	test   %ebx,%ebx
  80026e:	7f ec                	jg     80025c <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	8b 45 18             	mov    0x18(%ebp),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	52                   	push   %edx
  800282:	50                   	push   %eax
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	e8 2a 0e 00 00       	call   8010b4 <__umoddi3>
  80028a:	83 c4 14             	add    $0x14,%esp
  80028d:	0f be 80 d2 13 80 00 	movsbl 0x8013d2(%eax),%eax
  800294:	50                   	push   %eax
  800295:	ff 55 08             	call   *0x8(%ebp)
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002a9:	83 f8 01             	cmp    $0x1,%eax
  8002ac:	7e 0e                	jle    8002bc <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 11                	mov    (%ecx),%edx
  8002b0:	8d 42 08             	lea    0x8(%edx),%eax
  8002b3:	89 01                	mov    %eax,(%ecx)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x3e>
	else if (lflag)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	74 10                	je     8002d0 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 11                	mov    (%ecx),%edx
  8002c2:	8d 42 04             	lea    0x4(%edx),%eax
  8002c5:	89 01                	mov    %eax,(%ecx)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 11                	mov    (%ecx),%edx
  8002d2:	8d 42 04             	lea    0x4(%edx),%eax
  8002d5:	89 01                	mov    %eax,(%ecx)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002e9:	83 f8 01             	cmp    $0x1,%eax
  8002ec:	7e 0e                	jle    8002fc <getint+0x1c>
		return va_arg(*ap, long long);
  8002ee:	8b 11                	mov    (%ecx),%edx
  8002f0:	8d 42 08             	lea    0x8(%edx),%eax
  8002f3:	89 01                	mov    %eax,(%ecx)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 1a                	jmp    800316 <getint+0x36>
	else if (lflag)
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	74 0c                	je     80030c <getint+0x2c>
		return va_arg(*ap, long);
  800300:	8b 01                	mov    (%ecx),%eax
  800302:	8d 50 04             	lea    0x4(%eax),%edx
  800305:	89 11                	mov    %edx,(%ecx)
  800307:	8b 00                	mov    (%eax),%eax
  800309:	99                   	cltd   
  80030a:	eb 0a                	jmp    800316 <getint+0x36>
	else
		return va_arg(*ap, int);
  80030c:	8b 01                	mov    (%ecx),%eax
  80030e:	8d 50 04             	lea    0x4(%eax),%edx
  800311:	89 11                	mov    %edx,(%ecx)
  800313:	8b 00                	mov    (%eax),%eax
  800315:	99                   	cltd   
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 1c             	sub    $0x1c,%esp
  800321:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800324:	0f b6 0b             	movzbl (%ebx),%ecx
  800327:	43                   	inc    %ebx
  800328:	83 f9 25             	cmp    $0x25,%ecx
  80032b:	74 1e                	je     80034b <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032d:	85 c9                	test   %ecx,%ecx
  80032f:	0f 84 dc 02 00 00    	je     800611 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	51                   	push   %ecx
  80033c:	ff 55 08             	call   *0x8(%ebp)
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	0f b6 0b             	movzbl (%ebx),%ecx
  800345:	43                   	inc    %ebx
  800346:	83 f9 25             	cmp    $0x25,%ecx
  800349:	75 e2                	jne    80032d <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80034b:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  80034f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  800356:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80035b:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  800360:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	0f b6 0b             	movzbl (%ebx),%ecx
  80036a:	8d 41 dd             	lea    -0x23(%ecx),%eax
  80036d:	43                   	inc    %ebx
  80036e:	83 f8 55             	cmp    $0x55,%eax
  800371:	0f 87 75 02 00 00    	ja     8005ec <vprintfmt+0x2d4>
  800377:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  80037e:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  800382:	eb e3                	jmp    800367 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800384:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  800388:	eb dd                	jmp    800367 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038a:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  80038f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  800392:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  800396:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  800399:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80039c:	83 f8 09             	cmp    $0x9,%eax
  80039f:	77 28                	ja     8003c9 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a1:	43                   	inc    %ebx
  8003a2:	eb eb                	jmp    80038f <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a4:	8b 55 14             	mov    0x14(%ebp),%edx
  8003a7:	8d 42 04             	lea    0x4(%edx),%eax
  8003aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ad:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8003af:	eb 18                	jmp    8003c9 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8003b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003b5:	79 b0                	jns    800367 <vprintfmt+0x4f>
				width = 0;
  8003b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  8003be:	eb a7                	jmp    800367 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  8003c0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  8003c7:	eb 9e                	jmp    800367 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  8003c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003cd:	79 98                	jns    800367 <vprintfmt+0x4f>
				width = precision, precision = -1;
  8003cf:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8003d2:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  8003d7:	eb 8e                	jmp    800367 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d9:	47                   	inc    %edi
			goto reswitch;
  8003da:	eb 8b                	jmp    800367 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dc:	83 ec 08             	sub    $0x8,%esp
  8003df:	ff 75 0c             	pushl  0xc(%ebp)
  8003e2:	8b 55 14             	mov    0x14(%ebp),%edx
  8003e5:	8d 42 04             	lea    0x4(%edx),%eax
  8003e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8003eb:	ff 32                	pushl  (%edx)
  8003ed:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	e9 2c ff ff ff       	jmp    800324 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fb:	8d 42 04             	lea    0x4(%edx),%eax
  8003fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800401:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800403:	85 c0                	test   %eax,%eax
  800405:	79 02                	jns    800409 <vprintfmt+0xf1>
				err = -err;
  800407:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800409:	83 f8 0f             	cmp    $0xf,%eax
  80040c:	7f 0b                	jg     800419 <vprintfmt+0x101>
  80040e:	8b 3c 85 20 14 80 00 	mov    0x801420(,%eax,4),%edi
  800415:	85 ff                	test   %edi,%edi
  800417:	75 19                	jne    800432 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  800419:	50                   	push   %eax
  80041a:	68 e3 13 80 00       	push   $0x8013e3
  80041f:	ff 75 0c             	pushl  0xc(%ebp)
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	e8 ef 01 00 00       	call   800619 <printfmt>
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	e9 f2 fe ff ff       	jmp    800324 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800432:	57                   	push   %edi
  800433:	68 ec 13 80 00       	push   $0x8013ec
  800438:	ff 75 0c             	pushl  0xc(%ebp)
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	e8 d6 01 00 00       	call   800619 <printfmt>
  800443:	83 c4 10             	add    $0x10,%esp
			break;
  800446:	e9 d9 fe ff ff       	jmp    800324 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044b:	8b 55 14             	mov    0x14(%ebp),%edx
  80044e:	8d 42 04             	lea    0x4(%edx),%eax
  800451:	89 45 14             	mov    %eax,0x14(%ebp)
  800454:	8b 3a                	mov    (%edx),%edi
  800456:	85 ff                	test   %edi,%edi
  800458:	75 05                	jne    80045f <vprintfmt+0x147>
				p = "(null)";
  80045a:	bf ef 13 80 00       	mov    $0x8013ef,%edi
			if (width > 0 && padc != '-')
  80045f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800463:	7e 3b                	jle    8004a0 <vprintfmt+0x188>
  800465:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  800469:	74 35                	je     8004a0 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	56                   	push   %esi
  80046f:	57                   	push   %edi
  800470:	e8 58 02 00 00       	call   8006cd <strnlen>
  800475:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80047f:	7e 1f                	jle    8004a0 <vprintfmt+0x188>
  800481:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800491:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	ff 4d f0             	decl   -0x10(%ebp)
  80049a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80049e:	7f e8                	jg     800488 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a0:	0f be 0f             	movsbl (%edi),%ecx
  8004a3:	47                   	inc    %edi
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	74 44                	je     8004ec <vprintfmt+0x1d4>
  8004a8:	85 f6                	test   %esi,%esi
  8004aa:	78 03                	js     8004af <vprintfmt+0x197>
  8004ac:	4e                   	dec    %esi
  8004ad:	78 3d                	js     8004ec <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8004af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8004b3:	74 18                	je     8004cd <vprintfmt+0x1b5>
  8004b5:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 10                	jbe    8004cd <vprintfmt+0x1b5>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	51                   	push   %ecx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	ff 4d f0             	decl   -0x10(%ebp)
  8004dd:	0f be 0f             	movsbl (%edi),%ecx
  8004e0:	47                   	inc    %edi
  8004e1:	85 c9                	test   %ecx,%ecx
  8004e3:	74 07                	je     8004ec <vprintfmt+0x1d4>
  8004e5:	85 f6                	test   %esi,%esi
  8004e7:	78 c6                	js     8004af <vprintfmt+0x197>
  8004e9:	4e                   	dec    %esi
  8004ea:	79 c3                	jns    8004af <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004f0:	0f 8e 2e fe ff ff    	jle    800324 <vprintfmt+0xc>
				putch(' ', putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	ff 75 0c             	pushl  0xc(%ebp)
  8004fc:	6a 20                	push   $0x20
  8004fe:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	ff 4d f0             	decl   -0x10(%ebp)
  800507:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80050b:	7f e9                	jg     8004f6 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  80050d:	e9 12 fe ff ff       	jmp    800324 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800512:	57                   	push   %edi
  800513:	8d 45 14             	lea    0x14(%ebp),%eax
  800516:	50                   	push   %eax
  800517:	e8 c4 fd ff ff       	call   8002e0 <getint>
  80051c:	89 c6                	mov    %eax,%esi
  80051e:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800520:	83 c4 08             	add    $0x8,%esp
  800523:	85 d2                	test   %edx,%edx
  800525:	79 15                	jns    80053c <vprintfmt+0x224>
				putch('-', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	6a 2d                	push   $0x2d
  80052f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800532:	f7 de                	neg    %esi
  800534:	83 d7 00             	adc    $0x0,%edi
  800537:	f7 df                	neg    %edi
  800539:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80053c:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800541:	eb 76                	jmp    8005b9 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800543:	57                   	push   %edi
  800544:	8d 45 14             	lea    0x14(%ebp),%eax
  800547:	50                   	push   %eax
  800548:	e8 53 fd ff ff       	call   8002a0 <getuint>
  80054d:	89 c6                	mov    %eax,%esi
  80054f:	89 d7                	mov    %edx,%edi
			base = 10;
  800551:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800556:	83 c4 08             	add    $0x8,%esp
  800559:	eb 5e                	jmp    8005b9 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80055b:	57                   	push   %edi
  80055c:	8d 45 14             	lea    0x14(%ebp),%eax
  80055f:	50                   	push   %eax
  800560:	e8 3b fd ff ff       	call   8002a0 <getuint>
  800565:	89 c6                	mov    %eax,%esi
  800567:	89 d7                	mov    %edx,%edi
			base = 8;
  800569:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  80056e:	83 c4 08             	add    $0x8,%esp
  800571:	eb 46                	jmp    8005b9 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	6a 30                	push   $0x30
  80057b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	6a 78                	push   $0x78
  800586:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800589:	8b 55 14             	mov    0x14(%ebp),%edx
  80058c:	8d 42 04             	lea    0x4(%edx),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
  800592:	8b 32                	mov    (%edx),%esi
  800594:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800599:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005a3:	57                   	push   %edi
  8005a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	e8 f3 fc ff ff       	call   8002a0 <getuint>
  8005ad:	89 c6                	mov    %eax,%esi
  8005af:	89 d7                	mov    %edx,%edi
			base = 16;
  8005b1:	ba 10 00 00 00       	mov    $0x10,%edx
  8005b6:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005b9:	83 ec 04             	sub    $0x4,%esp
  8005bc:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8005c0:	50                   	push   %eax
  8005c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8005c4:	52                   	push   %edx
  8005c5:	57                   	push   %edi
  8005c6:	56                   	push   %esi
  8005c7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ca:	ff 75 08             	pushl  0x8(%ebp)
  8005cd:	e8 2e fc ff ff       	call   800200 <printnum>
			break;
  8005d2:	83 c4 20             	add    $0x20,%esp
  8005d5:	e9 4a fd ff ff       	jmp    800324 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	ff 75 0c             	pushl  0xc(%ebp)
  8005e0:	51                   	push   %ecx
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	e9 38 fd ff ff       	jmp    800324 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	ff 75 0c             	pushl  0xc(%ebp)
  8005f2:	6a 25                	push   $0x25
  8005f4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f7:	4b                   	dec    %ebx
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8005ff:	0f 84 1f fd ff ff    	je     800324 <vprintfmt+0xc>
  800605:	4b                   	dec    %ebx
  800606:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80060a:	75 f9                	jne    800605 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  80060c:	e9 13 fd ff ff       	jmp    800324 <vprintfmt+0xc>
		}
	}
}
  800611:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800614:	5b                   	pop    %ebx
  800615:	5e                   	pop    %esi
  800616:	5f                   	pop    %edi
  800617:	c9                   	leave  
  800618:	c3                   	ret    

00800619 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800622:	50                   	push   %eax
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	ff 75 0c             	pushl  0xc(%ebp)
  800629:	ff 75 08             	pushl  0x8(%ebp)
  80062c:	e8 e7 fc ff ff       	call   800318 <vprintfmt>
	va_end(ap);
}
  800631:	c9                   	leave  
  800632:	c3                   	ret    

00800633 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  800639:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  80063c:	8b 0a                	mov    (%edx),%ecx
  80063e:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800641:	73 07                	jae    80064a <sprintputch+0x17>
		*b->buf++ = ch;
  800643:	8b 45 08             	mov    0x8(%ebp),%eax
  800646:	88 01                	mov    %al,(%ecx)
  800648:	ff 02                	incl   (%edx)
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
  800652:	8b 55 08             	mov    0x8(%ebp),%edx
  800655:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800658:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80065b:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  80065f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800662:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  800669:	85 d2                	test   %edx,%edx
  80066b:	74 04                	je     800671 <vsnprintf+0x25>
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	7f 07                	jg     800678 <vsnprintf+0x2c>
		return -E_INVAL;
  800671:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800676:	eb 1d                	jmp    800695 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800678:	ff 75 14             	pushl  0x14(%ebp)
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800681:	50                   	push   %eax
  800682:	68 33 06 80 00       	push   $0x800633
  800687:	e8 8c fc ff ff       	call   800318 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80068f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800692:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a0:	50                   	push   %eax
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	ff 75 08             	pushl  0x8(%ebp)
  8006aa:	e8 9d ff ff ff       	call   80064c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    
  8006b1:	00 00                	add    %al,(%eax)
	...

008006b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c2:	74 07                	je     8006cb <strlen+0x17>
		n++;
  8006c4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	42                   	inc    %edx
  8006c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8006c9:	75 f9                	jne    8006c4 <strlen+0x10>
		n++;
	return n;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 0f                	je     8006ee <strnlen+0x21>
  8006df:	80 39 00             	cmpb   $0x0,(%ecx)
  8006e2:	74 0a                	je     8006ee <strnlen+0x21>
		n++;
  8006e4:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e5:	41                   	inc    %ecx
  8006e6:	4a                   	dec    %edx
  8006e7:	74 05                	je     8006ee <strnlen+0x21>
  8006e9:	80 39 00             	cmpb   $0x0,(%ecx)
  8006ec:	75 f6                	jne    8006e4 <strnlen+0x17>
		n++;
	return n;
}
  8006ee:	c9                   	leave  
  8006ef:	c3                   	ret    

008006f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  8006fa:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  8006fc:	8a 02                	mov    (%edx),%al
  8006fe:	42                   	inc    %edx
  8006ff:	88 01                	mov    %al,(%ecx)
  800701:	41                   	inc    %ecx
  800702:	84 c0                	test   %al,%al
  800704:	75 f6                	jne    8006fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800706:	89 d8                	mov    %ebx,%eax
  800708:	5b                   	pop    %ebx
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800712:	53                   	push   %ebx
  800713:	e8 9c ff ff ff       	call   8006b4 <strlen>
	strcpy(dst + len, src);
  800718:	ff 75 0c             	pushl  0xc(%ebp)
  80071b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80071e:	50                   	push   %eax
  80071f:	e8 cc ff ff ff       	call   8006f0 <strcpy>
	return dst;
}
  800724:	89 d8                	mov    %ebx,%eax
  800726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	57                   	push   %edi
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
  800737:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80073a:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  80073c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800741:	39 f3                	cmp    %esi,%ebx
  800743:	73 10                	jae    800755 <strncpy+0x2a>
		*dst++ = *src;
  800745:	8a 02                	mov    (%edx),%al
  800747:	88 01                	mov    %al,(%ecx)
  800749:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074a:	80 3a 01             	cmpb   $0x1,(%edx)
  80074d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800750:	43                   	inc    %ebx
  800751:	39 f3                	cmp    %esi,%ebx
  800753:	72 f0                	jb     800745 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800755:	89 f8                	mov    %edi,%eax
  800757:	5b                   	pop    %ebx
  800758:	5e                   	pop    %esi
  800759:	5f                   	pop    %edi
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  80076a:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  80076c:	85 d2                	test   %edx,%edx
  80076e:	74 19                	je     800789 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800770:	4a                   	dec    %edx
  800771:	74 13                	je     800786 <strlcpy+0x2a>
  800773:	80 39 00             	cmpb   $0x0,(%ecx)
  800776:	74 0e                	je     800786 <strlcpy+0x2a>
  800778:	8a 01                	mov    (%ecx),%al
  80077a:	41                   	inc    %ecx
  80077b:	88 03                	mov    %al,(%ebx)
  80077d:	43                   	inc    %ebx
  80077e:	4a                   	dec    %edx
  80077f:	74 05                	je     800786 <strlcpy+0x2a>
  800781:	80 39 00             	cmpb   $0x0,(%ecx)
  800784:	75 f2                	jne    800778 <strlcpy+0x1c>
		*dst = '\0';
  800786:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  800789:	89 d8                	mov    %ebx,%eax
  80078b:	29 f0                	sub    %esi,%eax
}
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	8b 55 08             	mov    0x8(%ebp),%edx
  800797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  80079a:	80 3a 00             	cmpb   $0x0,(%edx)
  80079d:	74 13                	je     8007b2 <strcmp+0x21>
  80079f:	8a 02                	mov    (%edx),%al
  8007a1:	3a 01                	cmp    (%ecx),%al
  8007a3:	75 0d                	jne    8007b2 <strcmp+0x21>
  8007a5:	42                   	inc    %edx
  8007a6:	41                   	inc    %ecx
  8007a7:	80 3a 00             	cmpb   $0x0,(%edx)
  8007aa:	74 06                	je     8007b2 <strcmp+0x21>
  8007ac:	8a 02                	mov    (%edx),%al
  8007ae:	3a 01                	cmp    (%ecx),%al
  8007b0:	74 f3                	je     8007a5 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b2:	0f b6 02             	movzbl (%edx),%eax
  8007b5:	0f b6 11             	movzbl (%ecx),%edx
  8007b8:	29 d0                	sub    %edx,%eax
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007c9:	85 c9                	test   %ecx,%ecx
  8007cb:	74 1f                	je     8007ec <strncmp+0x30>
  8007cd:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d0:	74 16                	je     8007e8 <strncmp+0x2c>
  8007d2:	8a 02                	mov    (%edx),%al
  8007d4:	3a 03                	cmp    (%ebx),%al
  8007d6:	75 10                	jne    8007e8 <strncmp+0x2c>
  8007d8:	42                   	inc    %edx
  8007d9:	43                   	inc    %ebx
  8007da:	49                   	dec    %ecx
  8007db:	74 0f                	je     8007ec <strncmp+0x30>
  8007dd:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e0:	74 06                	je     8007e8 <strncmp+0x2c>
  8007e2:	8a 02                	mov    (%edx),%al
  8007e4:	3a 03                	cmp    (%ebx),%al
  8007e6:	74 f0                	je     8007d8 <strncmp+0x1c>
	if (n == 0)
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	75 07                	jne    8007f3 <strncmp+0x37>
		return 0;
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	eb 0a                	jmp    8007fd <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 12             	movzbl (%edx),%edx
  8007f6:	0f b6 03             	movzbl (%ebx),%eax
  8007f9:	29 c2                	sub    %eax,%edx
  8007fb:	89 d0                	mov    %edx,%eax
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800809:	80 38 00             	cmpb   $0x0,(%eax)
  80080c:	74 0a                	je     800818 <strchr+0x18>
		if (*s == c)
  80080e:	38 10                	cmp    %dl,(%eax)
  800810:	74 0b                	je     80081d <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800812:	40                   	inc    %eax
  800813:	80 38 00             	cmpb   $0x0,(%eax)
  800816:	75 f6                	jne    80080e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  800828:	80 38 00             	cmpb   $0x0,(%eax)
  80082b:	74 0a                	je     800837 <strfind+0x18>
		if (*s == c)
  80082d:	38 10                	cmp    %dl,(%eax)
  80082f:	74 06                	je     800837 <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800831:	40                   	inc    %eax
  800832:	80 38 00             	cmpb   $0x0,(%eax)
  800835:	75 f6                	jne    80082d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	57                   	push   %edi
  80083d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800840:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800843:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 40                	je     800889 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800849:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084f:	75 30                	jne    800881 <memset+0x48>
  800851:	f6 c1 03             	test   $0x3,%cl
  800854:	75 2b                	jne    800881 <memset+0x48>
		c &= 0xFF;
  800856:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	c1 e0 18             	shl    $0x18,%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	c1 e2 10             	shl    $0x10,%edx
  800869:	09 d0                	or     %edx,%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	c1 e2 08             	shl    $0x8,%edx
  800871:	09 d0                	or     %edx,%eax
  800873:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  800876:	c1 e9 02             	shr    $0x2,%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	fc                   	cld    
  80087d:	f3 ab                	rep stos %eax,%es:(%edi)
  80087f:	eb 06                	jmp    800887 <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800881:	8b 45 0c             	mov    0xc(%ebp),%eax
  800884:	fc                   	cld    
  800885:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800887:	89 f8                	mov    %edi,%eax
}
  800889:	5f                   	pop    %edi
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800897:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80089a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80089c:	39 c6                	cmp    %eax,%esi
  80089e:	73 34                	jae    8008d4 <memmove+0x48>
  8008a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a3:	39 c2                	cmp    %eax,%edx
  8008a5:	76 2d                	jbe    8008d4 <memmove+0x48>
		s += n;
  8008a7:	89 d6                	mov    %edx,%esi
		d += n;
  8008a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ac:	f6 c2 03             	test   $0x3,%dl
  8008af:	75 1b                	jne    8008cc <memmove+0x40>
  8008b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b7:	75 13                	jne    8008cc <memmove+0x40>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 0e                	jne    8008cc <memmove+0x40>
			asm volatile("std; rep movsl\n"
  8008be:	83 ef 04             	sub    $0x4,%edi
  8008c1:	83 ee 04             	sub    $0x4,%esi
  8008c4:	c1 e9 02             	shr    $0x2,%ecx
  8008c7:	fd                   	std    
  8008c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ca:	eb 05                	jmp    8008d1 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cc:	4f                   	dec    %edi
  8008cd:	4e                   	dec    %esi
  8008ce:	fd                   	std    
  8008cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d1:	fc                   	cld    
  8008d2:	eb 20                	jmp    8008f4 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008da:	75 15                	jne    8008f1 <memmove+0x65>
  8008dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e2:	75 0d                	jne    8008f1 <memmove+0x65>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 08                	jne    8008f1 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  8008e9:	c1 e9 02             	shr    $0x2,%ecx
  8008ec:	fc                   	cld    
  8008ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ef:	eb 03                	jmp    8008f4 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f1:	fc                   	cld    
  8008f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f4:	5e                   	pop    %esi
  8008f5:	5f                   	pop    %edi
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008fb:	ff 75 10             	pushl  0x10(%ebp)
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 83 ff ff ff       	call   80088c <memmove>
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800912:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800915:	8b 55 10             	mov    0x10(%ebp),%edx
  800918:	4a                   	dec    %edx
  800919:	83 fa ff             	cmp    $0xffffffff,%edx
  80091c:	74 1a                	je     800938 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  80091e:	8a 01                	mov    (%ecx),%al
  800920:	3a 03                	cmp    (%ebx),%al
  800922:	74 0c                	je     800930 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800924:	0f b6 d0             	movzbl %al,%edx
  800927:	0f b6 03             	movzbl (%ebx),%eax
  80092a:	29 c2                	sub    %eax,%edx
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	eb 0d                	jmp    80093d <memcmp+0x32>
		s1++, s2++;
  800930:	41                   	inc    %ecx
  800931:	43                   	inc    %ebx
  800932:	4a                   	dec    %edx
  800933:	83 fa ff             	cmp    $0xffffffff,%edx
  800936:	75 e6                	jne    80091e <memcmp+0x13>
	}

	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	5b                   	pop    %ebx
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800949:	89 c2                	mov    %eax,%edx
  80094b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094e:	39 d0                	cmp    %edx,%eax
  800950:	73 09                	jae    80095b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800952:	38 08                	cmp    %cl,(%eax)
  800954:	74 05                	je     80095b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800956:	40                   	inc    %eax
  800957:	39 d0                	cmp    %edx,%eax
  800959:	72 f7                	jb     800952 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
  800966:	8b 75 0c             	mov    0xc(%ebp),%esi
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  80096c:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  800971:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800976:	80 3a 20             	cmpb   $0x20,(%edx)
  800979:	74 05                	je     800980 <strtol+0x23>
  80097b:	80 3a 09             	cmpb   $0x9,(%edx)
  80097e:	75 0b                	jne    80098b <strtol+0x2e>
  800980:	42                   	inc    %edx
  800981:	80 3a 20             	cmpb   $0x20,(%edx)
  800984:	74 fa                	je     800980 <strtol+0x23>
  800986:	80 3a 09             	cmpb   $0x9,(%edx)
  800989:	74 f5                	je     800980 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  80098b:	80 3a 2b             	cmpb   $0x2b,(%edx)
  80098e:	75 03                	jne    800993 <strtol+0x36>
		s++;
  800990:	42                   	inc    %edx
  800991:	eb 0b                	jmp    80099e <strtol+0x41>
	else if (*s == '-')
  800993:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800996:	75 06                	jne    80099e <strtol+0x41>
		s++, neg = 1;
  800998:	42                   	inc    %edx
  800999:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099e:	85 c9                	test   %ecx,%ecx
  8009a0:	74 05                	je     8009a7 <strtol+0x4a>
  8009a2:	83 f9 10             	cmp    $0x10,%ecx
  8009a5:	75 15                	jne    8009bc <strtol+0x5f>
  8009a7:	80 3a 30             	cmpb   $0x30,(%edx)
  8009aa:	75 10                	jne    8009bc <strtol+0x5f>
  8009ac:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b0:	75 0a                	jne    8009bc <strtol+0x5f>
		s += 2, base = 16;
  8009b2:	83 c2 02             	add    $0x2,%edx
  8009b5:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009ba:	eb 14                	jmp    8009d0 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	75 10                	jne    8009d0 <strtol+0x73>
  8009c0:	80 3a 30             	cmpb   $0x30,(%edx)
  8009c3:	75 05                	jne    8009ca <strtol+0x6d>
		s++, base = 8;
  8009c5:	42                   	inc    %edx
  8009c6:	b1 08                	mov    $0x8,%cl
  8009c8:	eb 06                	jmp    8009d0 <strtol+0x73>
	else if (base == 0)
  8009ca:	85 c9                	test   %ecx,%ecx
  8009cc:	75 02                	jne    8009d0 <strtol+0x73>
		base = 10;
  8009ce:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d0:	8a 02                	mov    (%edx),%al
  8009d2:	83 e8 30             	sub    $0x30,%eax
  8009d5:	3c 09                	cmp    $0x9,%al
  8009d7:	77 08                	ja     8009e1 <strtol+0x84>
			dig = *s - '0';
  8009d9:	0f be 02             	movsbl (%edx),%eax
  8009dc:	83 e8 30             	sub    $0x30,%eax
  8009df:	eb 20                	jmp    800a01 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  8009e1:	8a 02                	mov    (%edx),%al
  8009e3:	83 e8 61             	sub    $0x61,%eax
  8009e6:	3c 19                	cmp    $0x19,%al
  8009e8:	77 08                	ja     8009f2 <strtol+0x95>
			dig = *s - 'a' + 10;
  8009ea:	0f be 02             	movsbl (%edx),%eax
  8009ed:	83 e8 57             	sub    $0x57,%eax
  8009f0:	eb 0f                	jmp    800a01 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  8009f2:	8a 02                	mov    (%edx),%al
  8009f4:	83 e8 41             	sub    $0x41,%eax
  8009f7:	3c 19                	cmp    $0x19,%al
  8009f9:	77 12                	ja     800a0d <strtol+0xb0>
			dig = *s - 'A' + 10;
  8009fb:	0f be 02             	movsbl (%edx),%eax
  8009fe:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a01:	39 c8                	cmp    %ecx,%eax
  800a03:	7d 08                	jge    800a0d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a05:	42                   	inc    %edx
  800a06:	0f af d9             	imul   %ecx,%ebx
  800a09:	01 c3                	add    %eax,%ebx
  800a0b:	eb c3                	jmp    8009d0 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a0d:	85 f6                	test   %esi,%esi
  800a0f:	74 02                	je     800a13 <strtol+0xb6>
		*endptr = (char *) s;
  800a11:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a13:	89 d8                	mov    %ebx,%eax
  800a15:	85 ff                	test   %edi,%edi
  800a17:	74 02                	je     800a1b <strtol+0xbe>
  800a19:	f7 d8                	neg    %eax
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5f                   	pop    %edi
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	83 ec 04             	sub    $0x4,%esp
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a34:	89 f8                	mov    %edi,%eax
  800a36:	89 fb                	mov    %edi,%ebx
  800a38:	89 fe                	mov    %edi,%esi
  800a3a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a3c:	83 c4 04             	add    $0x4,%esp
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4f:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a54:	89 fa                	mov    %edi,%edx
  800a56:	89 f9                	mov    %edi,%ecx
  800a58:	89 fb                	mov    %edi,%ebx
  800a5a:	89 fe                	mov    %edi,%esi
  800a5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	83 ec 0c             	sub    $0xc,%esp
  800a6c:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a79:	89 f9                	mov    %edi,%ecx
  800a7b:	89 fb                	mov    %edi,%ebx
  800a7d:	89 fe                	mov    %edi,%esi
  800a7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a81:	85 c0                	test   %eax,%eax
  800a83:	7e 17                	jle    800a9c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a85:	83 ec 0c             	sub    $0xc,%esp
  800a88:	50                   	push   %eax
  800a89:	6a 03                	push   $0x3
  800a8b:	68 b8 15 80 00       	push   $0x8015b8
  800a90:	6a 23                	push   $0x23
  800a92:	68 d5 15 80 00       	push   $0x8015d5
  800a97:	e8 c0 04 00 00       	call   800f5c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	c9                   	leave  
  800aa3:	c3                   	ret    

00800aa4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aaa:	b8 02 00 00 00       	mov    $0x2,%eax
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	89 fa                	mov    %edi,%edx
  800ab6:	89 f9                	mov    %edi,%ecx
  800ab8:	89 fb                	mov    %edi,%ebx
  800aba:	89 fe                	mov    %edi,%esi
  800abc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <sys_yield>:

void
sys_yield(void)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ace:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad3:	89 fa                	mov    %edi,%edx
  800ad5:	89 f9                	mov    %edi,%ecx
  800ad7:	89 fb                	mov    %edi,%ebx
  800ad9:	89 fe                	mov    %edi,%esi
  800adb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af1:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800af4:	b8 04 00 00 00       	mov    $0x4,%eax
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	89 fe                	mov    %edi,%esi
  800b00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b02:	85 c0                	test   %eax,%eax
  800b04:	7e 17                	jle    800b1d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	50                   	push   %eax
  800b0a:	6a 04                	push   $0x4
  800b0c:	68 b8 15 80 00       	push   $0x8015b8
  800b11:	6a 23                	push   $0x23
  800b13:	68 d5 15 80 00       	push   $0x8015d5
  800b18:	e8 3f 04 00 00       	call   800f5c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b3a:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b3d:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b44:	85 c0                	test   %eax,%eax
  800b46:	7e 17                	jle    800b5f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 05                	push   $0x5
  800b4e:	68 b8 15 80 00       	push   $0x8015b8
  800b53:	6a 23                	push   $0x23
  800b55:	68 d5 15 80 00       	push   $0x8015d5
  800b5a:	e8 fd 03 00 00       	call   800f5c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800b76:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800b88:	7e 17                	jle    800ba1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 06                	push   $0x6
  800b90:	68 b8 15 80 00       	push   $0x8015b8
  800b95:	6a 23                	push   $0x23
  800b97:	68 d5 15 80 00       	push   $0x8015d5
  800b9c:	e8 bb 03 00 00       	call   800f5c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800bb8:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800bca:	7e 17                	jle    800be3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 08                	push   $0x8
  800bd2:	68 b8 15 80 00       	push   $0x8015b8
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 d5 15 80 00       	push   $0x8015d5
  800bde:	e8 79 03 00 00       	call   800f5c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	89 fb                	mov    %edi,%ebx
  800c06:	89 fe                	mov    %edi,%esi
  800c08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7e 17                	jle    800c25 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 09                	push   $0x9
  800c14:	68 b8 15 80 00       	push   $0x8015b8
  800c19:	6a 23                	push   $0x23
  800c1b:	68 d5 15 80 00       	push   $0x8015d5
  800c20:	e8 37 03 00 00       	call   800f5c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c41:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	89 fb                	mov    %edi,%ebx
  800c48:	89 fe                	mov    %edi,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 0a                	push   $0xa
  800c56:	68 b8 15 80 00       	push   $0x8015b8
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 d5 15 80 00       	push   $0x8015d5
  800c62:	e8 f5 02 00 00       	call   800f5c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7e:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c86:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c9e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	89 f9                	mov    %edi,%ecx
  800caa:	89 fb                	mov    %edi,%ebx
  800cac:	89 fe                	mov    %edi,%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 0d                	push   $0xd
  800cba:	68 b8 15 80 00       	push   $0x8015b8
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 d5 15 80 00       	push   $0x8015d5
  800cc6:	e8 91 02 00 00       	call   800f5c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    
	...

00800cd4 <duppage>:


/// dstenv: child's envid
void
duppage(envid_t dstenv, void *addr)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800cdc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800cdf:	83 ec 04             	sub    $0x4,%esp
  800ce2:	6a 07                	push   $0x7
  800ce4:	53                   	push   %ebx
  800ce5:	56                   	push   %esi
  800ce6:	e8 f7 fd ff ff       	call   800ae2 <sys_page_alloc>
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	79 12                	jns    800d04 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800cf2:	50                   	push   %eax
  800cf3:	68 e3 15 80 00       	push   $0x8015e3
  800cf8:	6a 18                	push   $0x18
  800cfa:	68 f6 15 80 00       	push   $0x8015f6
  800cff:	e8 58 02 00 00       	call   800f5c <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	6a 07                	push   $0x7
  800d09:	68 00 00 40 00       	push   $0x400000
  800d0e:	6a 00                	push   $0x0
  800d10:	53                   	push   %ebx
  800d11:	56                   	push   %esi
  800d12:	e8 0e fe ff ff       	call   800b25 <sys_page_map>
  800d17:	83 c4 20             	add    $0x20,%esp
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	79 12                	jns    800d30 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  800d1e:	50                   	push   %eax
  800d1f:	68 01 16 80 00       	push   $0x801601
  800d24:	6a 1a                	push   $0x1a
  800d26:	68 f6 15 80 00       	push   $0x8015f6
  800d2b:	e8 2c 02 00 00       	call   800f5c <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	68 00 10 00 00       	push   $0x1000
  800d38:	53                   	push   %ebx
  800d39:	68 00 00 40 00       	push   $0x400000
  800d3e:	e8 49 fb ff ff       	call   80088c <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800d43:	83 c4 08             	add    $0x8,%esp
  800d46:	68 00 00 40 00       	push   $0x400000
  800d4b:	6a 00                	push   $0x0
  800d4d:	e8 15 fe ff ff       	call   800b67 <sys_page_unmap>
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	85 c0                	test   %eax,%eax
  800d57:	79 12                	jns    800d6b <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  800d59:	50                   	push   %eax
  800d5a:	68 12 16 80 00       	push   $0x801612
  800d5f:	6a 1d                	push   $0x1d
  800d61:	68 f6 15 80 00       	push   $0x8015f6
  800d66:	e8 f1 01 00 00       	call   800f5c <_panic>
}
  800d6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    

00800d72 <fork>:

envid_t
fork(void)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	83 ec 04             	sub    $0x4,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800d79:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  800d7e:	89 d0                	mov    %edx,%eax
  800d80:	cd 30                	int    $0x30
  800d82:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	79 12                	jns    800d9a <fork+0x28>
		panic("sys_exofork: %e", envid);
  800d88:	50                   	push   %eax
  800d89:	68 25 16 80 00       	push   $0x801625
  800d8e:	6a 2f                	push   $0x2f
  800d90:	68 f6 15 80 00       	push   $0x8015f6
  800d95:	e8 c2 01 00 00       	call   800f5c <_panic>
	if (envid == 0) {
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	75 25                	jne    800dc3 <fork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800d9e:	e8 01 fd ff ff       	call   800aa4 <sys_getenvid>
  800da3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	c1 e2 05             	shl    $0x5,%edx
  800dad:	29 c2                	sub    %eax,%edx
  800daf:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800db6:	89 15 08 20 80 00    	mov    %edx,0x802008
		return 0;
  800dbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc1:	eb 67                	jmp    800e2a <fork+0xb8>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800dc3:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800dca:	81 7d f8 0c 20 80 00 	cmpl   $0x80200c,-0x8(%ebp)
  800dd1:	73 1f                	jae    800df2 <fork+0x80>
		duppage(envid, addr);
  800dd3:	83 ec 08             	sub    $0x8,%esp
  800dd6:	ff 75 f8             	pushl  -0x8(%ebp)
  800dd9:	53                   	push   %ebx
  800dda:	e8 f5 fe ff ff       	call   800cd4 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  800de9:	81 7d f8 0c 20 80 00 	cmpl   $0x80200c,-0x8(%ebp)
  800df0:	72 e1                	jb     800dd3 <fork+0x61>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800df2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800df5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dfa:	83 ec 08             	sub    $0x8,%esp
  800dfd:	50                   	push   %eax
  800dfe:	53                   	push   %ebx
  800dff:	e8 d0 fe ff ff       	call   800cd4 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800e04:	83 c4 08             	add    $0x8,%esp
  800e07:	6a 02                	push   $0x2
  800e09:	53                   	push   %ebx
  800e0a:	e8 9a fd ff ff       	call   800ba9 <sys_env_set_status>
  800e0f:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  800e12:	89 da                	mov    %ebx,%edx

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	79 12                	jns    800e2a <fork+0xb8>
		panic("sys_env_set_status: %e", r);
  800e18:	50                   	push   %eax
  800e19:	68 35 16 80 00       	push   $0x801635
  800e1e:	6a 44                	push   $0x44
  800e20:	68 f6 15 80 00       	push   $0x8015f6
  800e25:	e8 32 01 00 00       	call   800f5c <_panic>

	return envid;
}
  800e2a:	89 d0                	mov    %edx,%eax
  800e2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <sfork>:

// Challenge!
int
sfork(void)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e37:	68 4c 16 80 00       	push   $0x80164c
  800e3c:	6a 4d                	push   $0x4d
  800e3e:	68 f6 15 80 00       	push   $0x8015f6
  800e43:	e8 14 01 00 00       	call   800f5c <_panic>

00800e48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  800e56:	85 c0                	test   %eax,%eax
  800e58:	75 05                	jne    800e5f <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  800e5a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	e8 2a fe ff ff       	call   800c92 <sys_ipc_recv>
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	79 16                	jns    800e85 <ipc_recv+0x3d>
		if (from_env_store)
  800e6f:	85 db                	test   %ebx,%ebx
  800e71:	74 06                	je     800e79 <ipc_recv+0x31>
			*from_env_store = 0;
  800e73:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  800e79:	85 f6                	test   %esi,%esi
  800e7b:	74 34                	je     800eb1 <ipc_recv+0x69>
			*perm_store = 0;
  800e7d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  800e83:	eb 2c                	jmp    800eb1 <ipc_recv+0x69>
	}

	if (from_env_store)
  800e85:	85 db                	test   %ebx,%ebx
  800e87:	74 0a                	je     800e93 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  800e89:	a1 08 20 80 00       	mov    0x802008,%eax
  800e8e:	8b 40 74             	mov    0x74(%eax),%eax
  800e91:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  800e93:	85 f6                	test   %esi,%esi
  800e95:	74 12                	je     800ea9 <ipc_recv+0x61>
  800e97:	8b 15 08 20 80 00    	mov    0x802008,%edx
  800e9d:	8b 42 78             	mov    0x78(%edx),%eax
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	74 05                	je     800ea9 <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  800ea4:	8b 42 78             	mov    0x78(%edx),%eax
  800ea7:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  800ea9:	a1 08 20 80 00       	mov    0x802008,%eax
  800eae:	8b 40 70             	mov    0x70(%eax),%eax
}
  800eb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  800eca:	85 db                	test   %ebx,%ebx
  800ecc:	74 10                	je     800ede <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  800ece:	ff 75 14             	pushl  0x14(%ebp)
  800ed1:	53                   	push   %ebx
  800ed2:	56                   	push   %esi
  800ed3:	57                   	push   %edi
  800ed4:	e8 96 fd ff ff       	call   800c6f <sys_ipc_try_send>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	eb 11                	jmp    800eef <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  800ede:	6a 00                	push   $0x0
  800ee0:	68 00 00 c0 ee       	push   $0xeec00000
  800ee5:	56                   	push   %esi
  800ee6:	57                   	push   %edi
  800ee7:	e8 83 fd ff ff       	call   800c6f <sys_ipc_try_send>
  800eec:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	74 1e                	je     800f11 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  800ef3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800ef6:	74 12                	je     800f0a <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  800ef8:	50                   	push   %eax
  800ef9:	68 64 16 80 00       	push   $0x801664
  800efe:	6a 4a                	push   $0x4a
  800f00:	68 88 16 80 00       	push   $0x801688
  800f05:	e8 52 00 00 00       	call   800f5c <_panic>
		}
		sys_yield();
  800f0a:	e8 b4 fb ff ff       	call   800ac3 <sys_yield>
  800f0f:	eb b9                	jmp    800eca <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  800f11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	53                   	push   %ebx
  800f1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800f20:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	c1 e0 05             	shl    $0x5,%eax
  800f2a:	29 d0                	sub    %edx,%eax
  800f2c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800f33:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  800f39:	8b 40 50             	mov    0x50(%eax),%eax
  800f3c:	39 d8                	cmp    %ebx,%eax
  800f3e:	75 0b                	jne    800f4b <ipc_find_env+0x32>
			return envs[i].env_id;
  800f40:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  800f46:	8b 40 40             	mov    0x40(%eax),%eax
  800f49:	eb 0e                	jmp    800f59 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f4b:	42                   	inc    %edx
  800f4c:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800f52:	7e d1                	jle    800f25 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f59:	5b                   	pop    %ebx
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  800f63:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f66:	ff 75 0c             	pushl  0xc(%ebp)
  800f69:	ff 75 08             	pushl  0x8(%ebp)
  800f6c:	ff 35 00 20 80 00    	pushl  0x802000
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	e8 2a fb ff ff       	call   800aa4 <sys_getenvid>
  800f7a:	83 c4 08             	add    $0x8,%esp
  800f7d:	50                   	push   %eax
  800f7e:	68 94 16 80 00       	push   $0x801694
  800f83:	e8 64 f2 ff ff       	call   8001ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f88:	83 c4 18             	add    $0x18,%esp
  800f8b:	53                   	push   %ebx
  800f8c:	ff 75 10             	pushl  0x10(%ebp)
  800f8f:	e8 07 f2 ff ff       	call   80019b <vcprintf>
	cprintf("\n");
  800f94:	c7 04 24 78 12 80 00 	movl   $0x801278,(%esp)
  800f9b:	e8 4c f2 ff ff       	call   8001ec <cprintf>

	// Cause a breakpoint exception
	while (1)
  800fa0:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  800fa3:	cc                   	int3   
  800fa4:	eb fd                	jmp    800fa3 <_panic+0x47>
	...

00800fa8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	83 ec 14             	sub    $0x14,%esp
  800fb0:	8b 55 14             	mov    0x14(%ebp),%edx
  800fb3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fb9:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fbc:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800fbe:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800fc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800fc4:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800fc7:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fc9:	75 11                	jne    800fdc <__udivdi3+0x34>
    {
      if (d0 > n1)
  800fcb:	39 f8                	cmp    %edi,%eax
  800fcd:	76 4d                	jbe    80101c <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fcf:	89 fa                	mov    %edi,%edx
  800fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd4:	f7 75 e4             	divl   -0x1c(%ebp)
  800fd7:	89 c7                	mov    %eax,%edi
  800fd9:	eb 09                	jmp    800fe4 <__udivdi3+0x3c>
  800fdb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fdc:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800fdf:	76 17                	jbe    800ff8 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800fe1:	31 ff                	xor    %edi,%edi
  800fe3:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800fe4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800feb:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fee:	83 c4 14             	add    $0x14,%esp
  800ff1:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ff2:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ff4:	5f                   	pop    %edi
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    
  800ff7:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ff8:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	83 f7 1f             	xor    $0x1f,%edi
  801001:	75 4d                	jne    801050 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801003:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801006:	77 0a                	ja     801012 <__udivdi3+0x6a>
  801008:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  80100b:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80100d:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801010:	72 d2                	jb     800fe4 <__udivdi3+0x3c>
		{
		  q0 = 1;
  801012:	bf 01 00 00 00       	mov    $0x1,%edi
  801017:	eb cb                	jmp    800fe4 <__udivdi3+0x3c>
  801019:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80101c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101f:	85 c0                	test   %eax,%eax
  801021:	75 0e                	jne    801031 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801023:	b8 01 00 00 00       	mov    $0x1,%eax
  801028:	31 c9                	xor    %ecx,%ecx
  80102a:	31 d2                	xor    %edx,%edx
  80102c:	f7 f1                	div    %ecx
  80102e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 75 e4             	divl   -0x1c(%ebp)
  801038:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80103b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103e:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801041:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801044:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801047:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801049:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80104a:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80104c:	5f                   	pop    %edi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    
  80104f:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801050:	b8 20 00 00 00       	mov    $0x20,%eax
  801055:	29 f8                	sub    %edi,%eax
  801057:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  80105a:	89 f9                	mov    %edi,%ecx
  80105c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80105f:	d3 e2                	shl    %cl,%edx
  801061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801064:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801067:	d3 e8                	shr    %cl,%eax
  801069:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  80106b:	89 f9                	mov    %edi,%ecx
  80106d:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801070:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801073:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801076:	89 f2                	mov    %esi,%edx
  801078:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  80107a:	89 f9                	mov    %edi,%ecx
  80107c:	d3 e6                	shl    %cl,%esi
  80107e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801081:	8a 4d e8             	mov    -0x18(%ebp),%cl
  801084:	d3 e8                	shr    %cl,%eax
  801086:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  801088:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80108a:	89 f0                	mov    %esi,%eax
  80108c:	f7 75 f4             	divl   -0xc(%ebp)
  80108f:	89 d6                	mov    %edx,%esi
  801091:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801093:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801096:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801099:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80109b:	39 f2                	cmp    %esi,%edx
  80109d:	77 0f                	ja     8010ae <__udivdi3+0x106>
  80109f:	0f 85 3f ff ff ff    	jne    800fe4 <__udivdi3+0x3c>
  8010a5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8010a8:	0f 86 36 ff ff ff    	jbe    800fe4 <__udivdi3+0x3c>
		{
		  q0--;
  8010ae:	4f                   	dec    %edi
  8010af:	e9 30 ff ff ff       	jmp    800fe4 <__udivdi3+0x3c>

008010b4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	83 ec 30             	sub    $0x30,%esp
  8010bc:	8b 55 14             	mov    0x14(%ebp),%edx
  8010bf:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  8010c2:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8010c4:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8010c7:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  8010c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010cf:	85 ff                	test   %edi,%edi
  8010d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8010d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8010df:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  8010e5:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010e8:	75 3e                	jne    801128 <__umoddi3+0x74>
    {
      if (d0 > n1)
  8010ea:	39 d6                	cmp    %edx,%esi
  8010ec:	0f 86 a2 00 00 00    	jbe    801194 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010f2:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8010f4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8010f7:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010f9:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8010fc:	74 1b                	je     801119 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  8010fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801101:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  801104:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80110b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80110e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801111:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801114:	89 10                	mov    %edx,(%eax)
  801116:	89 48 04             	mov    %ecx,0x4(%eax)
  801119:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80111f:	83 c4 30             	add    $0x30,%esp
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	c9                   	leave  
  801125:	c3                   	ret    
  801126:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801128:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  80112b:	76 1f                	jbe    80114c <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  801130:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801133:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  801136:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801139:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80113c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80113f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801142:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801145:	83 c4 30             	add    $0x30,%esp
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80114c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80114f:	83 f0 1f             	xor    $0x1f,%eax
  801152:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801155:	75 61                	jne    8011b8 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801157:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  80115a:	77 05                	ja     801161 <__umoddi3+0xad>
  80115c:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  80115f:	72 10                	jb     801171 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801161:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801164:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801167:	29 f0                	sub    %esi,%eax
  801169:	19 fa                	sbb    %edi,%edx
  80116b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80116e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  801171:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801174:	85 d2                	test   %edx,%edx
  801176:	74 a1                	je     801119 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801178:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  80117b:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80117e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  801181:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  801184:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801187:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80118a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80118d:	89 01                	mov    %eax,(%ecx)
  80118f:	89 51 04             	mov    %edx,0x4(%ecx)
  801192:	eb 85                	jmp    801119 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801194:	85 f6                	test   %esi,%esi
  801196:	75 0b                	jne    8011a3 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801198:	b8 01 00 00 00       	mov    $0x1,%eax
  80119d:	31 d2                	xor    %edx,%edx
  80119f:	f7 f6                	div    %esi
  8011a1:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8011a6:	89 fa                	mov    %edi,%edx
  8011a8:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011ad:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011b0:	f7 f6                	div    %esi
  8011b2:	e9 3d ff ff ff       	jmp    8010f4 <__umoddi3+0x40>
  8011b7:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8011b8:	b8 20 00 00 00       	mov    $0x20,%eax
  8011bd:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  8011c0:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  8011c3:	89 fa                	mov    %edi,%edx
  8011c5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011c8:	d3 e2                	shl    %cl,%edx
  8011ca:	89 f0                	mov    %esi,%eax
  8011cc:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011cf:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  8011d1:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011d4:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011d6:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8011d8:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011db:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011de:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8011e0:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8011e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8011e5:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011e8:	d3 e0                	shl    %cl,%eax
  8011ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8011ed:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f3:	d3 e8                	shr    %cl,%eax
  8011f5:	0b 45 cc             	or     -0x34(%ebp),%eax
  8011f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  8011fb:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011fe:	f7 f7                	div    %edi
  801200:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801203:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801206:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801208:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  80120b:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80120e:	77 0a                	ja     80121a <__umoddi3+0x166>
  801210:	75 12                	jne    801224 <__umoddi3+0x170>
  801212:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801215:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801218:	76 0a                	jbe    801224 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80121a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80121d:	29 f1                	sub    %esi,%ecx
  80121f:	19 fa                	sbb    %edi,%edx
  801221:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  801224:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801227:	85 c0                	test   %eax,%eax
  801229:	0f 84 ea fe ff ff    	je     801119 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80122f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801232:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801235:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801238:	19 d1                	sbb    %edx,%ecx
  80123a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80123d:	89 ca                	mov    %ecx,%edx
  80123f:	8a 4d d8             	mov    -0x28(%ebp),%cl
  801242:	d3 e2                	shl    %cl,%edx
  801244:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801247:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80124a:	d3 e8                	shr    %cl,%eax
  80124c:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  80124e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801251:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801253:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  801256:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801259:	e9 ad fe ff ff       	jmp    80110b <__umoddi3+0x57>
