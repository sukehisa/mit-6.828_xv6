
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	83 ec 04             	sub    $0x4,%esp
  80003f:	6a 00                	push   $0x0
  800041:	6a 00                	push   $0x0
  800043:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800046:	50                   	push   %eax
  800047:	e8 40 0e 00 00       	call   800e8c <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	50                   	push   %eax
  800052:	a1 04 20 80 00       	mov    0x802004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	50                   	push   %eax
  80005b:	68 60 12 80 00       	push   $0x801260
  800060:	e8 cb 01 00 00       	call   800230 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 4c 0d 00 00       	call   800db6 <fork>
  80006a:	89 c6                	mov    %eax,%esi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x51>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 0c 16 80 00       	push   $0x80160c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 6c 12 80 00       	push   $0x80126c
  800080:	e8 cf 00 00 00       	call   800154 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b3                	je     80003c <primeproc+0x8>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	83 ec 04             	sub    $0x4,%esp
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800093:	50                   	push   %eax
  800094:	e8 f3 0d 00 00       	call   800e8c <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e4                	je     800089 <primeproc+0x55>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	56                   	push   %esi
  8000ab:	e8 4c 0e 00 00       	call   800efc <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d4                	jmp    800089 <primeproc+0x55>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 f7 0c 00 00       	call   800db6 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 0c 16 80 00       	push   $0x80160c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 6c 12 80 00       	push   $0x80126c
  8000d2:	e8 7d 00 00 00       	call   800154 <_panic>
	if (id == 0)
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	75 05                	jne    8000e0 <umain+0x2b>
		primeproc();
  8000db:	e8 54 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
  8000e0:	bb 02 00 00 00       	mov    $0x2,%ebx
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 0c 0e 00 00       	call   800efc <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	43                   	inc    %ebx
  8000f4:	eb ef                	jmp    8000e5 <umain+0x30>
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];	
  800103:	e8 e0 09 00 00       	call   800ae8 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	89 c2                	mov    %eax,%edx
  80010f:	c1 e2 05             	shl    $0x5,%edx
  800112:	29 c2                	sub    %eax,%edx
  800114:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  80011b:	89 15 04 20 80 00    	mov    %edx,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	53                   	push   %ebx
  800130:	56                   	push   %esi
  800131:	e8 7f ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800136:	e8 09 00 00 00       	call   800144 <exit>
}
  80013b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	c9                   	leave  
  800141:	c3                   	ret    
	...

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 56 09 00 00       	call   800aa7 <sys_env_destroy>
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 10             	sub    $0x10,%esp
	va_list ap;

	va_start(ap, fmt);
  80015b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	ff 35 00 20 80 00    	pushl  0x802000
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	e8 76 09 00 00       	call   800ae8 <sys_getenvid>
  800172:	83 c4 08             	add    $0x8,%esp
  800175:	50                   	push   %eax
  800176:	68 84 12 80 00       	push   $0x801284
  80017b:	e8 b0 00 00 00       	call   800230 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 53 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800193:	e8 98 00 00 00       	call   800230 <cprintf>

	// Cause a breakpoint exception
	while (1)
  800198:	83 c4 10             	add    $0x10,%esp
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x47>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 18 08          	mov    %dl,0x8(%eax,%ebx,1)
  8001b3:	40                   	inc    %eax
  8001b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 96 08 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	ff 43 04             	incl   0x4(%ebx)
}
  8001da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 e8 fe ff ff 00 	movl   $0x0,-0x118(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	ff 75 0c             	pushl  0xc(%ebp)
  8001ff:	ff 75 08             	pushl  0x8(%ebp)
  800202:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	68 a0 01 80 00       	push   $0x8001a0
  80020e:	e8 49 01 00 00       	call   80035c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800213:	83 c4 08             	add    $0x8,%esp
  800216:	ff b5 e8 fe ff ff    	pushl  -0x118(%ebp)
  80021c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800222:	50                   	push   %eax
  800223:	e8 3c 08 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
  800228:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
}
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800236:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800239:	50                   	push   %eax
  80023a:	ff 75 08             	pushl  0x8(%ebp)
  80023d:	e8 9d ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	8b 75 10             	mov    0x10(%ebp),%esi
  800250:	8b 7d 14             	mov    0x14(%ebp),%edi
  800253:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800256:	8b 45 18             	mov    0x18(%ebp),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	39 fa                	cmp    %edi,%edx
  800260:	77 39                	ja     80029b <printnum+0x57>
  800262:	72 04                	jb     800268 <printnum+0x24>
  800264:	39 f0                	cmp    %esi,%eax
  800266:	77 33                	ja     80029b <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 04             	sub    $0x4,%esp
  80026b:	ff 75 20             	pushl  0x20(%ebp)
  80026e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800271:	50                   	push   %eax
  800272:	ff 75 18             	pushl  0x18(%ebp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	ba 00 00 00 00       	mov    $0x0,%edx
  80027d:	52                   	push   %edx
  80027e:	50                   	push   %eax
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	e8 1a 0d 00 00       	call   800fa0 <__udivdi3>
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	ff 75 0c             	pushl  0xc(%ebp)
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 ae ff ff ff       	call   800244 <printnum>
  800296:	83 c4 20             	add    $0x20,%esp
  800299:	eb 19                	jmp    8002b4 <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7e 14                	jle    8002b4 <printnum+0x70>
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	ff 75 0c             	pushl  0xc(%ebp)
  8002a6:	ff 75 20             	pushl  0x20(%ebp)
  8002a9:	ff 55 08             	call   *0x8(%ebp)
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	4b                   	dec    %ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ec                	jg     8002a0 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ba:	8b 45 18             	mov    0x18(%ebp),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c2:	83 ec 04             	sub    $0x4,%esp
  8002c5:	52                   	push   %edx
  8002c6:	50                   	push   %eax
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	e8 de 0d 00 00       	call   8010ac <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 bb 13 80 00 	movsbl 0x8013bb(%eax),%eax
  8002d8:	50                   	push   %eax
  8002d9:	ff 55 08             	call   *0x8(%ebp)
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  8002ed:	83 f8 01             	cmp    $0x1,%eax
  8002f0:	7e 0e                	jle    800300 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 11                	mov    (%ecx),%edx
  8002f4:	8d 42 08             	lea    0x8(%edx),%eax
  8002f7:	89 01                	mov    %eax,(%ecx)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x3e>
	else if (lflag)
  800300:	85 c0                	test   %eax,%eax
  800302:	74 10                	je     800314 <getuint+0x30>
		return va_arg(*ap, unsigned long);
  800304:	8b 11                	mov    (%ecx),%edx
  800306:	8d 42 04             	lea    0x4(%edx),%eax
  800309:	89 01                	mov    %eax,(%ecx)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 11                	mov    (%ecx),%edx
  800316:	8d 42 04             	lea    0x4(%edx),%eax
  800319:	89 01                	mov    %eax,(%ecx)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
  80032d:	83 f8 01             	cmp    $0x1,%eax
  800330:	7e 0e                	jle    800340 <getint+0x1c>
		return va_arg(*ap, long long);
  800332:	8b 11                	mov    (%ecx),%edx
  800334:	8d 42 08             	lea    0x8(%edx),%eax
  800337:	89 01                	mov    %eax,(%ecx)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 1a                	jmp    80035a <getint+0x36>
	else if (lflag)
  800340:	85 c0                	test   %eax,%eax
  800342:	74 0c                	je     800350 <getint+0x2c>
		return va_arg(*ap, long);
  800344:	8b 01                	mov    (%ecx),%eax
  800346:	8d 50 04             	lea    0x4(%eax),%edx
  800349:	89 11                	mov    %edx,(%ecx)
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	99                   	cltd   
  80034e:	eb 0a                	jmp    80035a <getint+0x36>
	else
		return va_arg(*ap, int);
  800350:	8b 01                	mov    (%ecx),%eax
  800352:	8d 50 04             	lea    0x4(%eax),%edx
  800355:	89 11                	mov    %edx,(%ecx)
  800357:	8b 00                	mov    (%eax),%eax
  800359:	99                   	cltd   
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
  800362:	83 ec 1c             	sub    $0x1c,%esp
  800365:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
  800368:	0f b6 0b             	movzbl (%ebx),%ecx
  80036b:	43                   	inc    %ebx
  80036c:	83 f9 25             	cmp    $0x25,%ecx
  80036f:	74 1e                	je     80038f <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c9                	test   %ecx,%ecx
  800373:	0f 84 dc 02 00 00    	je     800655 <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	ff 75 0c             	pushl  0xc(%ebp)
  80037f:	51                   	push   %ecx
  800380:	ff 55 08             	call   *0x8(%ebp)
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	0f b6 0b             	movzbl (%ebx),%ecx
  800389:	43                   	inc    %ebx
  80038a:	83 f9 25             	cmp    $0x25,%ecx
  80038d:	75 e2                	jne    800371 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
  80038f:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
  800393:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
  80039a:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
  80039f:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
  8003a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	0f b6 0b             	movzbl (%ebx),%ecx
  8003ae:	8d 41 dd             	lea    -0x23(%ecx),%eax
  8003b1:	43                   	inc    %ebx
  8003b2:	83 f8 55             	cmp    $0x55,%eax
  8003b5:	0f 87 75 02 00 00    	ja     800630 <vprintfmt+0x2d4>
  8003bb:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c2:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
  8003c6:	eb e3                	jmp    8003ab <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
  8003cc:	eb dd                	jmp    8003ab <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ce:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
  8003d3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
  8003d6:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
  8003da:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
  8003dd:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003e0:	83 f8 09             	cmp    $0x9,%eax
  8003e3:	77 28                	ja     80040d <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e5:	43                   	inc    %ebx
  8003e6:	eb eb                	jmp    8003d3 <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003eb:	8d 42 04             	lea    0x4(%edx),%eax
  8003ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8003f1:	8b 32                	mov    (%edx),%esi
			goto process_precision;
  8003f3:	eb 18                	jmp    80040d <vprintfmt+0xb1>

		case '.':
			if (width < 0)
  8003f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003f9:	79 b0                	jns    8003ab <vprintfmt+0x4f>
				width = 0;
  8003fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
  800402:	eb a7                	jmp    8003ab <vprintfmt+0x4f>

		case '#':
			altflag = 1;
  800404:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
  80040b:	eb 9e                	jmp    8003ab <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
  80040d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800411:	79 98                	jns    8003ab <vprintfmt+0x4f>
				width = precision, precision = -1;
  800413:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800416:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
  80041b:	eb 8e                	jmp    8003ab <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041d:	47                   	inc    %edi
			goto reswitch;
  80041e:	eb 8b                	jmp    8003ab <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	ff 75 0c             	pushl  0xc(%ebp)
  800426:	8b 55 14             	mov    0x14(%ebp),%edx
  800429:	8d 42 04             	lea    0x4(%edx),%eax
  80042c:	89 45 14             	mov    %eax,0x14(%ebp)
  80042f:	ff 32                	pushl  (%edx)
  800431:	ff 55 08             	call   *0x8(%ebp)
			break;
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	e9 2c ff ff ff       	jmp    800368 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043c:	8b 55 14             	mov    0x14(%ebp),%edx
  80043f:	8d 42 04             	lea    0x4(%edx),%eax
  800442:	89 45 14             	mov    %eax,0x14(%ebp)
  800445:	8b 02                	mov    (%edx),%eax
			if (err < 0)
  800447:	85 c0                	test   %eax,%eax
  800449:	79 02                	jns    80044d <vprintfmt+0xf1>
				err = -err;
  80044b:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 0f             	cmp    $0xf,%eax
  800450:	7f 0b                	jg     80045d <vprintfmt+0x101>
  800452:	8b 3c 85 00 14 80 00 	mov    0x801400(,%eax,4),%edi
  800459:	85 ff                	test   %edi,%edi
  80045b:	75 19                	jne    800476 <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
  80045d:	50                   	push   %eax
  80045e:	68 cc 13 80 00       	push   $0x8013cc
  800463:	ff 75 0c             	pushl  0xc(%ebp)
  800466:	ff 75 08             	pushl  0x8(%ebp)
  800469:	e8 ef 01 00 00       	call   80065d <printfmt>
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	e9 f2 fe ff ff       	jmp    800368 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
  800476:	57                   	push   %edi
  800477:	68 d5 13 80 00       	push   $0x8013d5
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	ff 75 08             	pushl  0x8(%ebp)
  800482:	e8 d6 01 00 00       	call   80065d <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
			break;
  80048a:	e9 d9 fe ff ff       	jmp    800368 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048f:	8b 55 14             	mov    0x14(%ebp),%edx
  800492:	8d 42 04             	lea    0x4(%edx),%eax
  800495:	89 45 14             	mov    %eax,0x14(%ebp)
  800498:	8b 3a                	mov    (%edx),%edi
  80049a:	85 ff                	test   %edi,%edi
  80049c:	75 05                	jne    8004a3 <vprintfmt+0x147>
				p = "(null)";
  80049e:	bf d8 13 80 00       	mov    $0x8013d8,%edi
			if (width > 0 && padc != '-')
  8004a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004a7:	7e 3b                	jle    8004e4 <vprintfmt+0x188>
  8004a9:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
  8004ad:	74 35                	je     8004e4 <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	57                   	push   %edi
  8004b4:	e8 58 02 00 00       	call   800711 <strnlen>
  8004b9:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004c3:	7e 1f                	jle    8004e4 <vprintfmt+0x188>
  8004c5:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  8004c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	ff 75 0c             	pushl  0xc(%ebp)
  8004d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	ff 4d f0             	decl   -0x10(%ebp)
  8004de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004e2:	7f e8                	jg     8004cc <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	0f be 0f             	movsbl (%edi),%ecx
  8004e7:	47                   	inc    %edi
  8004e8:	85 c9                	test   %ecx,%ecx
  8004ea:	74 44                	je     800530 <vprintfmt+0x1d4>
  8004ec:	85 f6                	test   %esi,%esi
  8004ee:	78 03                	js     8004f3 <vprintfmt+0x197>
  8004f0:	4e                   	dec    %esi
  8004f1:	78 3d                	js     800530 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8004f7:	74 18                	je     800511 <vprintfmt+0x1b5>
  8004f9:	8d 41 e0             	lea    -0x20(%ecx),%eax
  8004fc:	83 f8 5e             	cmp    $0x5e,%eax
  8004ff:	76 10                	jbe    800511 <vprintfmt+0x1b5>
					putch('?', putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	6a 3f                	push   $0x3f
  800509:	ff 55 08             	call   *0x8(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb 0d                	jmp    80051e <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	51                   	push   %ecx
  800518:	ff 55 08             	call   *0x8(%ebp)
  80051b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051e:	ff 4d f0             	decl   -0x10(%ebp)
  800521:	0f be 0f             	movsbl (%edi),%ecx
  800524:	47                   	inc    %edi
  800525:	85 c9                	test   %ecx,%ecx
  800527:	74 07                	je     800530 <vprintfmt+0x1d4>
  800529:	85 f6                	test   %esi,%esi
  80052b:	78 c6                	js     8004f3 <vprintfmt+0x197>
  80052d:	4e                   	dec    %esi
  80052e:	79 c3                	jns    8004f3 <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800530:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800534:	0f 8e 2e fe ff ff    	jle    800368 <vprintfmt+0xc>
				putch(' ', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 20                	push   $0x20
  800542:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	ff 4d f0             	decl   -0x10(%ebp)
  80054b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80054f:	7f e9                	jg     80053a <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
  800551:	e9 12 fe ff ff       	jmp    800368 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800556:	57                   	push   %edi
  800557:	8d 45 14             	lea    0x14(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	e8 c4 fd ff ff       	call   800324 <getint>
  800560:	89 c6                	mov    %eax,%esi
  800562:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
  800564:	83 c4 08             	add    $0x8,%esp
  800567:	85 d2                	test   %edx,%edx
  800569:	79 15                	jns    800580 <vprintfmt+0x224>
				putch('-', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 2d                	push   $0x2d
  800573:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800576:	f7 de                	neg    %esi
  800578:	83 d7 00             	adc    $0x0,%edi
  80057b:	f7 df                	neg    %edi
  80057d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800580:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  800585:	eb 76                	jmp    8005fd <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800587:	57                   	push   %edi
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	50                   	push   %eax
  80058c:	e8 53 fd ff ff       	call   8002e4 <getuint>
  800591:	89 c6                	mov    %eax,%esi
  800593:	89 d7                	mov    %edx,%edi
			base = 10;
  800595:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
  80059a:	83 c4 08             	add    $0x8,%esp
  80059d:	eb 5e                	jmp    8005fd <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80059f:	57                   	push   %edi
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	e8 3b fd ff ff       	call   8002e4 <getuint>
  8005a9:	89 c6                	mov    %eax,%esi
  8005ab:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ad:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
  8005b2:	83 c4 08             	add    $0x8,%esp
  8005b5:	eb 46                	jmp    8005fd <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	6a 30                	push   $0x30
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c2:	83 c4 08             	add    $0x8,%esp
  8005c5:	ff 75 0c             	pushl  0xc(%ebp)
  8005c8:	6a 78                	push   $0x78
  8005ca:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8005cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8005d0:	8d 42 04             	lea    0x4(%edx),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d6:	8b 32                	mov    (%edx),%esi
  8005d8:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005dd:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	eb 16                	jmp    8005fd <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e7:	57                   	push   %edi
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	50                   	push   %eax
  8005ec:	e8 f3 fc ff ff       	call   8002e4 <getuint>
  8005f1:	89 c6                	mov    %eax,%esi
  8005f3:	89 d7                	mov    %edx,%edi
			base = 16;
  8005f5:	ba 10 00 00 00       	mov    $0x10,%edx
  8005fa:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fd:	83 ec 04             	sub    $0x4,%esp
  800600:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
  800604:	50                   	push   %eax
  800605:	ff 75 f0             	pushl  -0x10(%ebp)
  800608:	52                   	push   %edx
  800609:	57                   	push   %edi
  80060a:	56                   	push   %esi
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	ff 75 08             	pushl  0x8(%ebp)
  800611:	e8 2e fc ff ff       	call   800244 <printnum>
			break;
  800616:	83 c4 20             	add    $0x20,%esp
  800619:	e9 4a fd ff ff       	jmp    800368 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	51                   	push   %ecx
  800625:	ff 55 08             	call   *0x8(%ebp)
			break;
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	e9 38 fd ff ff       	jmp    800368 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	ff 75 0c             	pushl  0xc(%ebp)
  800636:	6a 25                	push   $0x25
  800638:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063b:	4b                   	dec    %ebx
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800643:	0f 84 1f fd ff ff    	je     800368 <vprintfmt+0xc>
  800649:	4b                   	dec    %ebx
  80064a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80064e:	75 f9                	jne    800649 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
  800650:	e9 13 fd ff ff       	jmp    800368 <vprintfmt+0xc>
		}
	}
}
  800655:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800658:	5b                   	pop    %ebx
  800659:	5e                   	pop    %esi
  80065a:	5f                   	pop    %edi
  80065b:	c9                   	leave  
  80065c:	c3                   	ret    

0080065d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800666:	50                   	push   %eax
  800667:	ff 75 10             	pushl  0x10(%ebp)
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	ff 75 08             	pushl  0x8(%ebp)
  800670:	e8 e7 fc ff ff       	call   80035c <vprintfmt>
	va_end(ap);
}
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
  80067d:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
  800680:	8b 0a                	mov    (%edx),%ecx
  800682:	3b 4a 04             	cmp    0x4(%edx),%ecx
  800685:	73 07                	jae    80068e <sprintputch+0x17>
		*b->buf++ = ch;
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	88 01                	mov    %al,(%ecx)
  80068c:	ff 02                	incl   (%edx)
}
  80068e:	c9                   	leave  
  80068f:	c3                   	ret    

00800690 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	83 ec 18             	sub    $0x18,%esp
  800696:	8b 55 08             	mov    0x8(%ebp),%edx
  800699:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80069f:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
  8006a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	74 04                	je     8006b5 <vsnprintf+0x25>
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	7f 07                	jg     8006bc <vsnprintf+0x2c>
		return -E_INVAL;
  8006b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ba:	eb 1d                	jmp    8006d9 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bc:	ff 75 14             	pushl  0x14(%ebp)
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8006c5:	50                   	push   %eax
  8006c6:	68 77 06 80 00       	push   $0x800677
  8006cb:	e8 8c fc ff ff       	call   80035c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e4:	50                   	push   %eax
  8006e5:	ff 75 10             	pushl  0x10(%ebp)
  8006e8:	ff 75 0c             	pushl  0xc(%ebp)
  8006eb:	ff 75 08             	pushl  0x8(%ebp)
  8006ee:	e8 9d ff ff ff       	call   800690 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    
  8006f5:	00 00                	add    %al,(%eax)
	...

008006f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	80 3a 00             	cmpb   $0x0,(%edx)
  800706:	74 07                	je     80070f <strlen+0x17>
		n++;
  800708:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	42                   	inc    %edx
  80070a:	80 3a 00             	cmpb   $0x0,(%edx)
  80070d:	75 f9                	jne    800708 <strlen+0x10>
		n++;
	return n;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	85 d2                	test   %edx,%edx
  800721:	74 0f                	je     800732 <strnlen+0x21>
  800723:	80 39 00             	cmpb   $0x0,(%ecx)
  800726:	74 0a                	je     800732 <strnlen+0x21>
		n++;
  800728:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800729:	41                   	inc    %ecx
  80072a:	4a                   	dec    %edx
  80072b:	74 05                	je     800732 <strnlen+0x21>
  80072d:	80 39 00             	cmpb   $0x0,(%ecx)
  800730:	75 f6                	jne    800728 <strnlen+0x17>
		n++;
	return n;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	53                   	push   %ebx
  800738:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
  80073e:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
  800740:	8a 02                	mov    (%edx),%al
  800742:	42                   	inc    %edx
  800743:	88 01                	mov    %al,(%ecx)
  800745:	41                   	inc    %ecx
  800746:	84 c0                	test   %al,%al
  800748:	75 f6                	jne    800740 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074a:	89 d8                	mov    %ebx,%eax
  80074c:	5b                   	pop    %ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	53                   	push   %ebx
  800757:	e8 9c ff ff ff       	call   8006f8 <strlen>
	strcpy(dst + len, src);
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800762:	50                   	push   %eax
  800763:	e8 cc ff ff ff       	call   800734 <strcpy>
	return dst;
}
  800768:	89 d8                	mov    %ebx,%eax
  80076a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	57                   	push   %edi
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077b:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
  80077e:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
  800780:	bb 00 00 00 00       	mov    $0x0,%ebx
  800785:	39 f3                	cmp    %esi,%ebx
  800787:	73 10                	jae    800799 <strncpy+0x2a>
		*dst++ = *src;
  800789:	8a 02                	mov    (%edx),%al
  80078b:	88 01                	mov    %al,(%ecx)
  80078d:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078e:	80 3a 01             	cmpb   $0x1,(%edx)
  800791:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800794:	43                   	inc    %ebx
  800795:	39 f3                	cmp    %esi,%ebx
  800797:	72 f0                	jb     800789 <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800799:	89 f8                	mov    %edi,%eax
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	56                   	push   %esi
  8007a4:	53                   	push   %ebx
  8007a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
  8007ae:	89 de                	mov    %ebx,%esi
	if (size > 0) {
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	74 19                	je     8007cd <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b4:	4a                   	dec    %edx
  8007b5:	74 13                	je     8007ca <strlcpy+0x2a>
  8007b7:	80 39 00             	cmpb   $0x0,(%ecx)
  8007ba:	74 0e                	je     8007ca <strlcpy+0x2a>
  8007bc:	8a 01                	mov    (%ecx),%al
  8007be:	41                   	inc    %ecx
  8007bf:	88 03                	mov    %al,(%ebx)
  8007c1:	43                   	inc    %ebx
  8007c2:	4a                   	dec    %edx
  8007c3:	74 05                	je     8007ca <strlcpy+0x2a>
  8007c5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007c8:	75 f2                	jne    8007bc <strlcpy+0x1c>
		*dst = '\0';
  8007ca:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
  8007cd:	89 d8                	mov    %ebx,%eax
  8007cf:	29 f0                	sub    %esi,%eax
}
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
  8007de:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e1:	74 13                	je     8007f6 <strcmp+0x21>
  8007e3:	8a 02                	mov    (%edx),%al
  8007e5:	3a 01                	cmp    (%ecx),%al
  8007e7:	75 0d                	jne    8007f6 <strcmp+0x21>
  8007e9:	42                   	inc    %edx
  8007ea:	41                   	inc    %ecx
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 06                	je     8007f6 <strcmp+0x21>
  8007f0:	8a 02                	mov    (%edx),%al
  8007f2:	3a 01                	cmp    (%ecx),%al
  8007f4:	74 f3                	je     8007e9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f6:	0f b6 02             	movzbl (%edx),%eax
  8007f9:	0f b6 11             	movzbl (%ecx),%edx
  8007fc:	29 d0                	sub    %edx,%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80080d:	85 c9                	test   %ecx,%ecx
  80080f:	74 1f                	je     800830 <strncmp+0x30>
  800811:	80 3a 00             	cmpb   $0x0,(%edx)
  800814:	74 16                	je     80082c <strncmp+0x2c>
  800816:	8a 02                	mov    (%edx),%al
  800818:	3a 03                	cmp    (%ebx),%al
  80081a:	75 10                	jne    80082c <strncmp+0x2c>
  80081c:	42                   	inc    %edx
  80081d:	43                   	inc    %ebx
  80081e:	49                   	dec    %ecx
  80081f:	74 0f                	je     800830 <strncmp+0x30>
  800821:	80 3a 00             	cmpb   $0x0,(%edx)
  800824:	74 06                	je     80082c <strncmp+0x2c>
  800826:	8a 02                	mov    (%edx),%al
  800828:	3a 03                	cmp    (%ebx),%al
  80082a:	74 f0                	je     80081c <strncmp+0x1c>
	if (n == 0)
  80082c:	85 c9                	test   %ecx,%ecx
  80082e:	75 07                	jne    800837 <strncmp+0x37>
		return 0;
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
  800835:	eb 0a                	jmp    800841 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800837:	0f b6 12             	movzbl (%edx),%edx
  80083a:	0f b6 03             	movzbl (%ebx),%eax
  80083d:	29 c2                	sub    %eax,%edx
  80083f:	89 d0                	mov    %edx,%eax
}
  800841:	5b                   	pop    %ebx
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80084d:	80 38 00             	cmpb   $0x0,(%eax)
  800850:	74 0a                	je     80085c <strchr+0x18>
		if (*s == c)
  800852:	38 10                	cmp    %dl,(%eax)
  800854:	74 0b                	je     800861 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800856:	40                   	inc    %eax
  800857:	80 38 00             	cmpb   $0x0,(%eax)
  80085a:	75 f6                	jne    800852 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800861:	c9                   	leave  
  800862:	c3                   	ret    

00800863 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
  80086c:	80 38 00             	cmpb   $0x0,(%eax)
  80086f:	74 0a                	je     80087b <strfind+0x18>
		if (*s == c)
  800871:	38 10                	cmp    %dl,(%eax)
  800873:	74 06                	je     80087b <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800875:	40                   	inc    %eax
  800876:	80 38 00             	cmpb   $0x0,(%eax)
  800879:	75 f6                	jne    800871 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
  800887:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 40                	je     8008cd <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800893:	75 30                	jne    8008c5 <memset+0x48>
  800895:	f6 c1 03             	test   $0x3,%cl
  800898:	75 2b                	jne    8008c5 <memset+0x48>
		c &= 0xFF;
  80089a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	c1 e0 18             	shl    $0x18,%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	c1 e2 10             	shl    $0x10,%edx
  8008ad:	09 d0                	or     %edx,%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	c1 e2 08             	shl    $0x8,%edx
  8008b5:	09 d0                	or     %edx,%eax
  8008b7:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	fc                   	cld    
  8008c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c3:	eb 06                	jmp    8008cb <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	fc                   	cld    
  8008c9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8008cb:	89 f8                	mov    %edi,%eax
}
  8008cd:	5f                   	pop    %edi
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	57                   	push   %edi
  8008d4:	56                   	push   %esi
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8008db:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008de:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008e0:	39 c6                	cmp    %eax,%esi
  8008e2:	73 34                	jae    800918 <memmove+0x48>
  8008e4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	76 2d                	jbe    800918 <memmove+0x48>
		s += n;
  8008eb:	89 d6                	mov    %edx,%esi
		d += n;
  8008ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	f6 c2 03             	test   $0x3,%dl
  8008f3:	75 1b                	jne    800910 <memmove+0x40>
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 13                	jne    800910 <memmove+0x40>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0e                	jne    800910 <memmove+0x40>
			asm volatile("std; rep movsl\n"
  800902:	83 ef 04             	sub    $0x4,%edi
  800905:	83 ee 04             	sub    $0x4,%esi
  800908:	c1 e9 02             	shr    $0x2,%ecx
  80090b:	fd                   	std    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 05                	jmp    800915 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800910:	4f                   	dec    %edi
  800911:	4e                   	dec    %esi
  800912:	fd                   	std    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800915:	fc                   	cld    
  800916:	eb 20                	jmp    800938 <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091e:	75 15                	jne    800935 <memmove+0x65>
  800920:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800926:	75 0d                	jne    800935 <memmove+0x65>
  800928:	f6 c1 03             	test   $0x3,%cl
  80092b:	75 08                	jne    800935 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
  80092d:	c1 e9 02             	shr    $0x2,%ecx
  800930:	fc                   	cld    
  800931:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800933:	eb 03                	jmp    800938 <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800935:	fc                   	cld    
  800936:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800938:	5e                   	pop    %esi
  800939:	5f                   	pop    %edi
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093f:	ff 75 10             	pushl  0x10(%ebp)
  800942:	ff 75 0c             	pushl  0xc(%ebp)
  800945:	ff 75 08             	pushl  0x8(%ebp)
  800948:	e8 83 ff ff ff       	call   8008d0 <memmove>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
  800956:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800959:	8b 55 10             	mov    0x10(%ebp),%edx
  80095c:	4a                   	dec    %edx
  80095d:	83 fa ff             	cmp    $0xffffffff,%edx
  800960:	74 1a                	je     80097c <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
  800962:	8a 01                	mov    (%ecx),%al
  800964:	3a 03                	cmp    (%ebx),%al
  800966:	74 0c                	je     800974 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
  800968:	0f b6 d0             	movzbl %al,%edx
  80096b:	0f b6 03             	movzbl (%ebx),%eax
  80096e:	29 c2                	sub    %eax,%edx
  800970:	89 d0                	mov    %edx,%eax
  800972:	eb 0d                	jmp    800981 <memcmp+0x32>
		s1++, s2++;
  800974:	41                   	inc    %ecx
  800975:	43                   	inc    %ebx
  800976:	4a                   	dec    %edx
  800977:	83 fa ff             	cmp    $0xffffffff,%edx
  80097a:	75 e6                	jne    800962 <memcmp+0x13>
	}

	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5b                   	pop    %ebx
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800992:	39 d0                	cmp    %edx,%eax
  800994:	73 09                	jae    80099f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800996:	38 08                	cmp    %cl,(%eax)
  800998:	74 05                	je     80099f <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099a:	40                   	inc    %eax
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	72 f7                	jb     800996 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
  8009b0:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
  8009b5:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009ba:	80 3a 20             	cmpb   $0x20,(%edx)
  8009bd:	74 05                	je     8009c4 <strtol+0x23>
  8009bf:	80 3a 09             	cmpb   $0x9,(%edx)
  8009c2:	75 0b                	jne    8009cf <strtol+0x2e>
  8009c4:	42                   	inc    %edx
  8009c5:	80 3a 20             	cmpb   $0x20,(%edx)
  8009c8:	74 fa                	je     8009c4 <strtol+0x23>
  8009ca:	80 3a 09             	cmpb   $0x9,(%edx)
  8009cd:	74 f5                	je     8009c4 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
  8009cf:	80 3a 2b             	cmpb   $0x2b,(%edx)
  8009d2:	75 03                	jne    8009d7 <strtol+0x36>
		s++;
  8009d4:	42                   	inc    %edx
  8009d5:	eb 0b                	jmp    8009e2 <strtol+0x41>
	else if (*s == '-')
  8009d7:	80 3a 2d             	cmpb   $0x2d,(%edx)
  8009da:	75 06                	jne    8009e2 <strtol+0x41>
		s++, neg = 1;
  8009dc:	42                   	inc    %edx
  8009dd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e2:	85 c9                	test   %ecx,%ecx
  8009e4:	74 05                	je     8009eb <strtol+0x4a>
  8009e6:	83 f9 10             	cmp    $0x10,%ecx
  8009e9:	75 15                	jne    800a00 <strtol+0x5f>
  8009eb:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ee:	75 10                	jne    800a00 <strtol+0x5f>
  8009f0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f4:	75 0a                	jne    800a00 <strtol+0x5f>
		s += 2, base = 16;
  8009f6:	83 c2 02             	add    $0x2,%edx
  8009f9:	b9 10 00 00 00       	mov    $0x10,%ecx
  8009fe:	eb 14                	jmp    800a14 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	75 10                	jne    800a14 <strtol+0x73>
  800a04:	80 3a 30             	cmpb   $0x30,(%edx)
  800a07:	75 05                	jne    800a0e <strtol+0x6d>
		s++, base = 8;
  800a09:	42                   	inc    %edx
  800a0a:	b1 08                	mov    $0x8,%cl
  800a0c:	eb 06                	jmp    800a14 <strtol+0x73>
	else if (base == 0)
  800a0e:	85 c9                	test   %ecx,%ecx
  800a10:	75 02                	jne    800a14 <strtol+0x73>
		base = 10;
  800a12:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a14:	8a 02                	mov    (%edx),%al
  800a16:	83 e8 30             	sub    $0x30,%eax
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	77 08                	ja     800a25 <strtol+0x84>
			dig = *s - '0';
  800a1d:	0f be 02             	movsbl (%edx),%eax
  800a20:	83 e8 30             	sub    $0x30,%eax
  800a23:	eb 20                	jmp    800a45 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
  800a25:	8a 02                	mov    (%edx),%al
  800a27:	83 e8 61             	sub    $0x61,%eax
  800a2a:	3c 19                	cmp    $0x19,%al
  800a2c:	77 08                	ja     800a36 <strtol+0x95>
			dig = *s - 'a' + 10;
  800a2e:	0f be 02             	movsbl (%edx),%eax
  800a31:	83 e8 57             	sub    $0x57,%eax
  800a34:	eb 0f                	jmp    800a45 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
  800a36:	8a 02                	mov    (%edx),%al
  800a38:	83 e8 41             	sub    $0x41,%eax
  800a3b:	3c 19                	cmp    $0x19,%al
  800a3d:	77 12                	ja     800a51 <strtol+0xb0>
			dig = *s - 'A' + 10;
  800a3f:	0f be 02             	movsbl (%edx),%eax
  800a42:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
  800a45:	39 c8                	cmp    %ecx,%eax
  800a47:	7d 08                	jge    800a51 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a49:	42                   	inc    %edx
  800a4a:	0f af d9             	imul   %ecx,%ebx
  800a4d:	01 c3                	add    %eax,%ebx
  800a4f:	eb c3                	jmp    800a14 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a51:	85 f6                	test   %esi,%esi
  800a53:	74 02                	je     800a57 <strtol+0xb6>
		*endptr = (char *) s;
  800a55:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a57:	89 d8                	mov    %ebx,%eax
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	74 02                	je     800a5f <strtol+0xbe>
  800a5d:	f7 d8                	neg    %eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 04             	sub    $0x4,%esp
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a78:	89 f8                	mov    %edi,%eax
  800a7a:	89 fb                	mov    %edi,%ebx
  800a7c:	89 fe                	mov    %edi,%esi
  800a7e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a80:	83 c4 04             	add    $0x4,%esp
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	89 fa                	mov    %edi,%edx
  800a9a:	89 f9                	mov    %edi,%ecx
  800a9c:	89 fb                	mov    %edi,%ebx
  800a9e:	89 fe                	mov    %edi,%esi
  800aa0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab8:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abd:	89 f9                	mov    %edi,%ecx
  800abf:	89 fb                	mov    %edi,%ebx
  800ac1:	89 fe                	mov    %edi,%esi
  800ac3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac5:	85 c0                	test   %eax,%eax
  800ac7:	7e 17                	jle    800ae0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	50                   	push   %eax
  800acd:	6a 03                	push   $0x3
  800acf:	68 98 15 80 00       	push   $0x801598
  800ad4:	6a 23                	push   $0x23
  800ad6:	68 b5 15 80 00       	push   $0x8015b5
  800adb:	e8 74 f6 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aee:	b8 02 00 00 00       	mov    $0x2,%eax
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	89 fa                	mov    %edi,%edx
  800afa:	89 f9                	mov    %edi,%ecx
  800afc:	89 fb                	mov    %edi,%ebx
  800afe:	89 fe                	mov    %edi,%esi
  800b00:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_yield>:

void
sys_yield(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b12:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	89 fa                	mov    %edi,%edx
  800b19:	89 f9                	mov    %edi,%ecx
  800b1b:	89 fb                	mov    %edi,%ebx
  800b1d:	89 fe                	mov    %edi,%esi
  800b1f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 0c             	sub    $0xc,%esp
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b38:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3d:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	89 fe                	mov    %edi,%esi
  800b44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b46:	85 c0                	test   %eax,%eax
  800b48:	7e 17                	jle    800b61 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	50                   	push   %eax
  800b4e:	6a 04                	push   $0x4
  800b50:	68 98 15 80 00       	push   $0x801598
  800b55:	6a 23                	push   $0x23
  800b57:	68 b5 15 80 00       	push   $0x8015b5
  800b5c:	e8 f3 f5 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7e:	8b 75 18             	mov    0x18(%ebp),%esi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b81:	b8 05 00 00 00       	mov    $0x5,%eax
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	7e 17                	jle    800ba3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	50                   	push   %eax
  800b90:	6a 05                	push   $0x5
  800b92:	68 98 15 80 00       	push   $0x801598
  800b97:	6a 23                	push   $0x23
  800b99:	68 b5 15 80 00       	push   $0x8015b5
  800b9e:	e8 b1 f5 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bba:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbf:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	89 fb                	mov    %edi,%ebx
  800bc6:	89 fe                	mov    %edi,%esi
  800bc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	7e 17                	jle    800be5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 06                	push   $0x6
  800bd4:	68 98 15 80 00       	push   $0x801598
  800bd9:	6a 23                	push   $0x23
  800bdb:	68 b5 15 80 00       	push   $0x8015b5
  800be0:	e8 6f f5 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bfc:	b8 08 00 00 00       	mov    $0x8,%eax
  800c01:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	89 fb                	mov    %edi,%ebx
  800c08:	89 fe                	mov    %edi,%esi
  800c0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 17                	jle    800c27 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 08                	push   $0x8
  800c16:	68 98 15 80 00       	push   $0x801598
  800c1b:	6a 23                	push   $0x23
  800c1d:	68 b5 15 80 00       	push   $0x8015b5
  800c22:	e8 2d f5 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c43:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	89 fb                	mov    %edi,%ebx
  800c4a:	89 fe                	mov    %edi,%esi
  800c4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7e 17                	jle    800c69 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	50                   	push   %eax
  800c56:	6a 09                	push   $0x9
  800c58:	68 98 15 80 00       	push   $0x801598
  800c5d:	6a 23                	push   $0x23
  800c5f:	68 b5 15 80 00       	push   $0x8015b5
  800c64:	e8 eb f4 ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c85:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	89 fb                	mov    %edi,%ebx
  800c8c:	89 fe                	mov    %edi,%esi
  800c8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7e 17                	jle    800cab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 0a                	push   $0xa
  800c9a:	68 98 15 80 00       	push   $0x801598
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 b5 15 80 00       	push   $0x8015b5
  800ca6:	e8 a9 f4 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ce2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce7:	bf 00 00 00 00       	mov    $0x0,%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	89 f9                	mov    %edi,%ecx
  800cee:	89 fb                	mov    %edi,%ebx
  800cf0:	89 fe                	mov    %edi,%esi
  800cf2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 17                	jle    800d0f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 0d                	push   $0xd
  800cfe:	68 98 15 80 00       	push   $0x801598
  800d03:	6a 23                	push   $0x23
  800d05:	68 b5 15 80 00       	push   $0x8015b5
  800d0a:	e8 45 f4 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    
	...

00800d18 <duppage>:


/// dstenv: child's envid
void
duppage(envid_t dstenv, void *addr)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800d23:	83 ec 04             	sub    $0x4,%esp
  800d26:	6a 07                	push   $0x7
  800d28:	53                   	push   %ebx
  800d29:	56                   	push   %esi
  800d2a:	e8 f7 fd ff ff       	call   800b26 <sys_page_alloc>
  800d2f:	83 c4 10             	add    $0x10,%esp
  800d32:	85 c0                	test   %eax,%eax
  800d34:	79 12                	jns    800d48 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800d36:	50                   	push   %eax
  800d37:	68 c3 15 80 00       	push   $0x8015c3
  800d3c:	6a 18                	push   $0x18
  800d3e:	68 d6 15 80 00       	push   $0x8015d6
  800d43:	e8 0c f4 ff ff       	call   800154 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	6a 07                	push   $0x7
  800d4d:	68 00 00 40 00       	push   $0x400000
  800d52:	6a 00                	push   $0x0
  800d54:	53                   	push   %ebx
  800d55:	56                   	push   %esi
  800d56:	e8 0e fe ff ff       	call   800b69 <sys_page_map>
  800d5b:	83 c4 20             	add    $0x20,%esp
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	79 12                	jns    800d74 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  800d62:	50                   	push   %eax
  800d63:	68 e1 15 80 00       	push   $0x8015e1
  800d68:	6a 1a                	push   $0x1a
  800d6a:	68 d6 15 80 00       	push   $0x8015d6
  800d6f:	e8 e0 f3 ff ff       	call   800154 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	68 00 10 00 00       	push   $0x1000
  800d7c:	53                   	push   %ebx
  800d7d:	68 00 00 40 00       	push   $0x400000
  800d82:	e8 49 fb ff ff       	call   8008d0 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800d87:	83 c4 08             	add    $0x8,%esp
  800d8a:	68 00 00 40 00       	push   $0x400000
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 15 fe ff ff       	call   800bab <sys_page_unmap>
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	79 12                	jns    800daf <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  800d9d:	50                   	push   %eax
  800d9e:	68 f2 15 80 00       	push   $0x8015f2
  800da3:	6a 1d                	push   $0x1d
  800da5:	68 d6 15 80 00       	push   $0x8015d6
  800daa:	e8 a5 f3 ff ff       	call   800154 <_panic>
}
  800daf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	c9                   	leave  
  800db5:	c3                   	ret    

00800db6 <fork>:

envid_t
fork(void)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	83 ec 04             	sub    $0x4,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800dbd:	ba 07 00 00 00       	mov    $0x7,%edx
int	sys_ipc_recv(void *rcv_pg);

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  800dc2:	89 d0                	mov    %edx,%eax
  800dc4:	cd 30                	int    $0x30
  800dc6:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	79 12                	jns    800dde <fork+0x28>
		panic("sys_exofork: %e", envid);
  800dcc:	50                   	push   %eax
  800dcd:	68 05 16 80 00       	push   $0x801605
  800dd2:	6a 2f                	push   $0x2f
  800dd4:	68 d6 15 80 00       	push   $0x8015d6
  800dd9:	e8 76 f3 ff ff       	call   800154 <_panic>
	if (envid == 0) {
  800dde:	85 c0                	test   %eax,%eax
  800de0:	75 25                	jne    800e07 <fork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800de2:	e8 01 fd ff ff       	call   800ae8 <sys_getenvid>
  800de7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800dec:	89 c2                	mov    %eax,%edx
  800dee:	c1 e2 05             	shl    $0x5,%edx
  800df1:	29 c2                	sub    %eax,%edx
  800df3:	8d 14 95 00 00 c0 ee 	lea    -0x11400000(,%edx,4),%edx
  800dfa:	89 15 04 20 80 00    	mov    %edx,0x802004
		return 0;
  800e00:	ba 00 00 00 00       	mov    $0x0,%edx
  800e05:	eb 67                	jmp    800e6e <fork+0xb8>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800e07:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800e0e:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800e15:	73 1f                	jae    800e36 <fork+0x80>
		duppage(envid, addr);
  800e17:	83 ec 08             	sub    $0x8,%esp
  800e1a:	ff 75 f8             	pushl  -0x8(%ebp)
  800e1d:	53                   	push   %ebx
  800e1e:	e8 f5 fe ff ff       	call   800d18 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  800e2d:	81 7d f8 08 20 80 00 	cmpl   $0x802008,-0x8(%ebp)
  800e34:	72 e1                	jb     800e17 <fork+0x61>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800e36:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800e39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	50                   	push   %eax
  800e42:	53                   	push   %ebx
  800e43:	e8 d0 fe ff ff       	call   800d18 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800e48:	83 c4 08             	add    $0x8,%esp
  800e4b:	6a 02                	push   $0x2
  800e4d:	53                   	push   %ebx
  800e4e:	e8 9a fd ff ff       	call   800bed <sys_env_set_status>
  800e53:	83 c4 10             	add    $0x10,%esp
		panic("sys_env_set_status: %e", r);

	return envid;
  800e56:	89 da                	mov    %ebx,%edx

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 12                	jns    800e6e <fork+0xb8>
		panic("sys_env_set_status: %e", r);
  800e5c:	50                   	push   %eax
  800e5d:	68 15 16 80 00       	push   $0x801615
  800e62:	6a 44                	push   $0x44
  800e64:	68 d6 15 80 00       	push   $0x8015d6
  800e69:	e8 e6 f2 ff ff       	call   800154 <_panic>

	return envid;
}
  800e6e:	89 d0                	mov    %edx,%eax
  800e70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <sfork>:

// Challenge!
int
sfork(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e7b:	68 2c 16 80 00       	push   $0x80162c
  800e80:	6a 4d                	push   $0x4d
  800e82:	68 d6 15 80 00       	push   $0x8015d6
  800e87:	e8 c8 f2 ff ff       	call   800154 <_panic>

00800e8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg == NULL)
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	75 05                	jne    800ea3 <ipc_recv+0x17>
		pg = (void *) UTOP; // UTOP as "no page"
  800e9e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	if ((r = sys_ipc_recv(pg)) < 0) {
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	50                   	push   %eax
  800ea7:	e8 2a fe ff ff       	call   800cd6 <sys_ipc_recv>
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	79 16                	jns    800ec9 <ipc_recv+0x3d>
		if (from_env_store)
  800eb3:	85 db                	test   %ebx,%ebx
  800eb5:	74 06                	je     800ebd <ipc_recv+0x31>
			*from_env_store = 0;
  800eb7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store)
  800ebd:	85 f6                	test   %esi,%esi
  800ebf:	74 34                	je     800ef5 <ipc_recv+0x69>
			*perm_store = 0;
  800ec1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
  800ec7:	eb 2c                	jmp    800ef5 <ipc_recv+0x69>
	}

	if (from_env_store)
  800ec9:	85 db                	test   %ebx,%ebx
  800ecb:	74 0a                	je     800ed7 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  800ecd:	a1 04 20 80 00       	mov    0x802004,%eax
  800ed2:	8b 40 74             	mov    0x74(%eax),%eax
  800ed5:	89 03                	mov    %eax,(%ebx)
	if (perm_store && thisenv->env_ipc_perm != 0) {
  800ed7:	85 f6                	test   %esi,%esi
  800ed9:	74 12                	je     800eed <ipc_recv+0x61>
  800edb:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800ee1:	8b 42 78             	mov    0x78(%edx),%eax
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	74 05                	je     800eed <ipc_recv+0x61>
		*perm_store = thisenv->env_ipc_perm;
  800ee8:	8b 42 78             	mov    0x78(%edx),%eax
  800eeb:	89 06                	mov    %eax,(%esi)
//		sys_page_map(thisenv->env_id, pg, thisenv->env_id, pg, *perm_store);
	}	

	return thisenv->env_ipc_value;
  800eed:	a1 04 20 80 00       	mov    0x802004,%eax
  800ef2:	8b 40 70             	mov    0x70(%eax),%eax
}
  800ef5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
//   -> UTOP as "no page"
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1) {
		if (pg)
  800f0e:	85 db                	test   %ebx,%ebx
  800f10:	74 10                	je     800f22 <ipc_send+0x26>
			r = sys_ipc_try_send(to_env, val, pg, perm);
  800f12:	ff 75 14             	pushl  0x14(%ebp)
  800f15:	53                   	push   %ebx
  800f16:	56                   	push   %esi
  800f17:	57                   	push   %edi
  800f18:	e8 96 fd ff ff       	call   800cb3 <sys_ipc_try_send>
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	eb 11                	jmp    800f33 <ipc_send+0x37>
		else 
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  800f22:	6a 00                	push   $0x0
  800f24:	68 00 00 c0 ee       	push   $0xeec00000
  800f29:	56                   	push   %esi
  800f2a:	57                   	push   %edi
  800f2b:	e8 83 fd ff ff       	call   800cb3 <sys_ipc_try_send>
  800f30:	83 c4 10             	add    $0x10,%esp

		if (r == 0) 
  800f33:	85 c0                	test   %eax,%eax
  800f35:	74 1e                	je     800f55 <ipc_send+0x59>
			break;
		
		if (r != -E_IPC_NOT_RECV) {
  800f37:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800f3a:	74 12                	je     800f4e <ipc_send+0x52>
			panic("sys_ipc_try_send:unexpected err, %e", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 44 16 80 00       	push   $0x801644
  800f42:	6a 4a                	push   $0x4a
  800f44:	68 68 16 80 00       	push   $0x801668
  800f49:	e8 06 f2 ff ff       	call   800154 <_panic>
		}
		sys_yield();
  800f4e:	e8 b4 fb ff ff       	call   800b07 <sys_yield>
  800f53:	eb b9                	jmp    800f0e <ipc_send+0x12>
	}
//	panic("ipc_send not implemented");
}
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	53                   	push   %ebx
  800f61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800f64:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
  800f69:	89 d0                	mov    %edx,%eax
  800f6b:	c1 e0 05             	shl    $0x5,%eax
  800f6e:	29 d0                	sub    %edx,%eax
  800f70:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800f77:	8d 81 00 00 c0 ee    	lea    -0x11400000(%ecx),%eax
  800f7d:	8b 40 50             	mov    0x50(%eax),%eax
  800f80:	39 d8                	cmp    %ebx,%eax
  800f82:	75 0b                	jne    800f8f <ipc_find_env+0x32>
			return envs[i].env_id;
  800f84:	8d 81 08 00 c0 ee    	lea    -0x113ffff8(%ecx),%eax
  800f8a:	8b 40 40             	mov    0x40(%eax),%eax
  800f8d:	eb 0e                	jmp    800f9d <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f8f:	42                   	inc    %edx
  800f90:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800f96:	7e d1                	jle    800f69 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    

00800fa0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	83 ec 14             	sub    $0x14,%esp
  800fa8:	8b 55 14             	mov    0x14(%ebp),%edx
  800fab:	8b 75 08             	mov    0x8(%ebp),%esi
  800fae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fb1:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fb4:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800fb6:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800fb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
  800fbc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
  800fbf:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fc1:	75 11                	jne    800fd4 <__udivdi3+0x34>
    {
      if (d0 > n1)
  800fc3:	39 f8                	cmp    %edi,%eax
  800fc5:	76 4d                	jbe    801014 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fc7:	89 fa                	mov    %edi,%edx
  800fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcc:	f7 75 e4             	divl   -0x1c(%ebp)
  800fcf:	89 c7                	mov    %eax,%edi
  800fd1:	eb 09                	jmp    800fdc <__udivdi3+0x3c>
  800fd3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fd4:	39 7d f4             	cmp    %edi,-0xc(%ebp)
  800fd7:	76 17                	jbe    800ff0 <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
  800fd9:	31 ff                	xor    %edi,%edi
  800fdb:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
  800fdc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fe3:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fe6:	83 c4 14             	add    $0x14,%esp
  800fe9:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fea:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fec:	5f                   	pop    %edi
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    
  800fef:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ff0:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
  800ff4:	89 c7                	mov    %eax,%edi
  800ff6:	83 f7 1f             	xor    $0x1f,%edi
  800ff9:	75 4d                	jne    801048 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ffb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ffe:	77 0a                	ja     80100a <__udivdi3+0x6a>
  801000:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
  801003:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801005:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801008:	72 d2                	jb     800fdc <__udivdi3+0x3c>
		{
		  q0 = 1;
  80100a:	bf 01 00 00 00       	mov    $0x1,%edi
  80100f:	eb cb                	jmp    800fdc <__udivdi3+0x3c>
  801011:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801014:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801017:	85 c0                	test   %eax,%eax
  801019:	75 0e                	jne    801029 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80101b:	b8 01 00 00 00       	mov    $0x1,%eax
  801020:	31 c9                	xor    %ecx,%ecx
  801022:	31 d2                	xor    %edx,%edx
  801024:	f7 f1                	div    %ecx
  801026:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801029:	89 f0                	mov    %esi,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 75 e4             	divl   -0x1c(%ebp)
  801030:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801036:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801039:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80103c:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80103f:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801041:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801042:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801044:	5f                   	pop    %edi
  801045:	c9                   	leave  
  801046:	c3                   	ret    
  801047:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801048:	b8 20 00 00 00       	mov    $0x20,%eax
  80104d:	29 f8                	sub    %edi,%eax
  80104f:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  801052:	89 f9                	mov    %edi,%ecx
  801054:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801057:	d3 e2                	shl    %cl,%edx
  801059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105c:	8a 4d e8             	mov    -0x18(%ebp),%cl
  80105f:	d3 e8                	shr    %cl,%eax
  801061:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
  801063:	89 f9                	mov    %edi,%ecx
  801065:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801068:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80106b:	8a 4d e8             	mov    -0x18(%ebp),%cl
  80106e:	89 f2                	mov    %esi,%edx
  801070:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  801072:	89 f9                	mov    %edi,%ecx
  801074:	d3 e6                	shl    %cl,%esi
  801076:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801079:	8a 4d e8             	mov    -0x18(%ebp),%cl
  80107c:	d3 e8                	shr    %cl,%eax
  80107e:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
  801080:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801082:	89 f0                	mov    %esi,%eax
  801084:	f7 75 f4             	divl   -0xc(%ebp)
  801087:	89 d6                	mov    %edx,%esi
  801089:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80108b:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  80108e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801091:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801093:	39 f2                	cmp    %esi,%edx
  801095:	77 0f                	ja     8010a6 <__udivdi3+0x106>
  801097:	0f 85 3f ff ff ff    	jne    800fdc <__udivdi3+0x3c>
  80109d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8010a0:	0f 86 36 ff ff ff    	jbe    800fdc <__udivdi3+0x3c>
		{
		  q0--;
  8010a6:	4f                   	dec    %edi
  8010a7:	e9 30 ff ff ff       	jmp    800fdc <__udivdi3+0x3c>

008010ac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	83 ec 30             	sub    $0x30,%esp
  8010b4:	8b 55 14             	mov    0x14(%ebp),%edx
  8010b7:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  8010ba:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8010bc:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8010bf:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
  8010c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010c7:	85 ff                	test   %edi,%edi
  8010c9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8010d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  8010d7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010da:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
  8010dd:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010e0:	75 3e                	jne    801120 <__umoddi3+0x74>
    {
      if (d0 > n1)
  8010e2:	39 d6                	cmp    %edx,%esi
  8010e4:	0f 86 a2 00 00 00    	jbe    80118c <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010ea:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8010ec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8010ef:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010f1:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
  8010f4:	74 1b                	je     801111 <__umoddi3+0x65>
	{
	  rr.s.low = n0;
  8010f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
  8010fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801103:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801106:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801109:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80110c:	89 10                	mov    %edx,(%eax)
  80110e:	89 48 04             	mov    %ecx,0x4(%eax)
  801111:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801114:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801117:	83 c4 30             	add    $0x30,%esp
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    
  80111e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801120:	3b 7d cc             	cmp    -0x34(%ebp),%edi
  801123:	76 1f                	jbe    801144 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801125:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
  801128:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  80112b:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
  80112e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
  801131:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801134:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801137:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80113a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80113d:	83 c4 30             	add    $0x30,%esp
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	c9                   	leave  
  801143:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801144:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801147:	83 f0 1f             	xor    $0x1f,%eax
  80114a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80114d:	75 61                	jne    8011b0 <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80114f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
  801152:	77 05                	ja     801159 <__umoddi3+0xad>
  801154:	39 75 dc             	cmp    %esi,-0x24(%ebp)
  801157:	72 10                	jb     801169 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801159:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80115c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80115f:	29 f0                	sub    %esi,%eax
  801161:	19 fa                	sbb    %edi,%edx
  801163:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801166:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
  801169:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80116c:	85 d2                	test   %edx,%edx
  80116e:	74 a1                	je     801111 <__umoddi3+0x65>
		{
		  rr.s.low = n0;
  801170:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
  801173:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801176:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
  801179:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
  80117c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80117f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801182:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801185:	89 01                	mov    %eax,(%ecx)
  801187:	89 51 04             	mov    %edx,0x4(%ecx)
  80118a:	eb 85                	jmp    801111 <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80118c:	85 f6                	test   %esi,%esi
  80118e:	75 0b                	jne    80119b <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801190:	b8 01 00 00 00       	mov    $0x1,%eax
  801195:	31 d2                	xor    %edx,%edx
  801197:	f7 f6                	div    %esi
  801199:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80119b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80119e:	89 fa                	mov    %edi,%edx
  8011a0:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011a5:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011a8:	f7 f6                	div    %esi
  8011aa:	e9 3d ff ff ff       	jmp    8010ec <__umoddi3+0x40>
  8011af:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8011b0:	b8 20 00 00 00       	mov    $0x20,%eax
  8011b5:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  8011b8:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
  8011bb:	89 fa                	mov    %edi,%edx
  8011bd:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011c0:	d3 e2                	shl    %cl,%edx
  8011c2:	89 f0                	mov    %esi,%eax
  8011c4:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011c7:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
  8011c9:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011cc:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011ce:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8011d0:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011d6:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8011d8:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
  8011da:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8011dd:	8a 4d d4             	mov    -0x2c(%ebp),%cl
  8011e0:	d3 e0                	shl    %cl,%eax
  8011e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8011e5:	8a 4d d8             	mov    -0x28(%ebp),%cl
  8011e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011eb:	d3 e8                	shr    %cl,%eax
  8011ed:	0b 45 cc             	or     -0x34(%ebp),%eax
  8011f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
  8011f3:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011f6:	f7 f7                	div    %edi
  8011f8:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011fb:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  8011fe:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801200:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
  801203:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801206:	77 0a                	ja     801212 <__umoddi3+0x166>
  801208:	75 12                	jne    80121c <__umoddi3+0x170>
  80120a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120d:	39 45 c8             	cmp    %eax,-0x38(%ebp)
  801210:	76 0a                	jbe    80121c <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801212:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801215:	29 f1                	sub    %esi,%ecx
  801217:	19 fa                	sbb    %edi,%edx
  801219:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
  80121c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80121f:	85 c0                	test   %eax,%eax
  801221:	0f 84 ea fe ff ff    	je     801111 <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801227:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80122a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80122d:	2b 45 c8             	sub    -0x38(%ebp),%eax
  801230:	19 d1                	sbb    %edx,%ecx
  801232:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801235:	89 ca                	mov    %ecx,%edx
  801237:	8a 4d d8             	mov    -0x28(%ebp),%cl
  80123a:	d3 e2                	shl    %cl,%edx
  80123c:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80123f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801242:	d3 e8                	shr    %cl,%eax
  801244:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
  801246:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801249:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80124b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
  80124e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801251:	e9 ad fe ff ff       	jmp    801103 <__umoddi3+0x57>
