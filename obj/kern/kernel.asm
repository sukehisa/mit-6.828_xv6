
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];   // defined in kernel.ld

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100047:	b8 04 00 20 f0       	mov    $0xf0200004,%eax
f010004c:	2d 29 d2 1b f0       	sub    $0xf01bd229,%eax
f0100051:	50                   	push   %eax
f0100052:	6a 00                	push   $0x0
f0100054:	68 29 d2 1b f0       	push   $0xf01bd229
f0100059:	e8 33 5c 00 00       	call   f0105c91 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005e:	e8 a3 07 00 00       	call   f0100806 <cons_init>

	cprintf("16 decimal is %o octal!\n", 16);
f0100063:	83 c4 08             	add    $0x8,%esp
f0100066:	6a 10                	push   $0x10
f0100068:	68 00 6a 10 f0       	push   $0xf0106a00
f010006d:	e8 60 39 00 00       	call   f01039d2 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100072:	e8 bc 0b 00 00       	call   f0100c33 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100077:	e8 f7 2f 00 00       	call   f0103073 <env_init>
	trap_init();
f010007c:	e8 9b 39 00 00       	call   f0103a1c <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();         // collect information about the multiprocessor system
f0100081:	e8 d6 60 00 00       	call   f010615c <mp_init>
	lapic_init();      // initialize lapic & enable LAPIC build-in timer for preemptive multitasking
f0100086:	e8 6c 62 00 00       	call   f01062f7 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010008b:	e8 28 38 00 00       	call   f01038b8 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100090:	c7 04 24 c0 95 12 f0 	movl   $0xf01295c0,(%esp)
f0100097:	e8 3c 65 00 00       	call   f01065d8 <spin_lock>
f010009c:	83 c4 10             	add    $0x10,%esp
	// Acquire the big kernel lock before waking up APs
	// Your code here:
	lock_kernel();

	// Starting non-boot CPUs	
	boot_aps();
f010009f:	e8 52 00 00 00       	call   f01000f6 <boot_aps>

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01000a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01000a9:	83 ec 04             	sub    $0x4,%esp
f01000ac:	6a 01                	push   $0x1
f01000ae:	68 d5 38 00 00       	push   $0x38d5
f01000b3:	68 87 79 15 f0       	push   $0xf0157987
f01000b8:	e8 09 34 00 00       	call   f01034c6 <env_create>
f01000bd:	83 c4 10             	add    $0x10,%esp
	// Starting non-boot CPUs	
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01000c0:	43                   	inc    %ebx
f01000c1:	83 fb 07             	cmp    $0x7,%ebx
f01000c4:	7e e3                	jle    f01000a9 <i386_init+0x69>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01000c6:	83 ec 04             	sub    $0x4,%esp
f01000c9:	6a 02                	push   $0x2
f01000cb:	68 25 b4 01 00       	push   $0x1b425
f01000d0:	68 04 1e 1a f0       	push   $0xf01a1e04
f01000d5:	e8 ec 33 00 00       	call   f01034c6 <env_create>
f01000da:	83 c4 0c             	add    $0xc,%esp

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000dd:	6a 00                	push   $0x0
f01000df:	68 c7 4c 00 00       	push   $0x4cc7
f01000e4:	68 3d d1 19 f0       	push   $0xf019d13d
f01000e9:	e8 d8 33 00 00       	call   f01034c6 <env_create>
f01000ee:	83 c4 10             	add    $0x10,%esp
	// ENV_CREATE(user_testfile, ENV_TYPE_USER);
	// ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01000f1:	e8 82 48 00 00       	call   f0104978 <sched_yield>

f01000f6 <boot_aps>:
// Start the non-boot (AP) processors.
/// starts in real mode
/// copies AP entry code(kern/mpentry.S) to memory location addressable in real-mode 
static void
boot_aps(void)
{
f01000f6:	55                   	push   %ebp
f01000f7:	89 e5                	mov    %esp,%ebp
f01000f9:	56                   	push   %esi
f01000fa:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000fb:	83 3d e8 ee 1b f0 07 	cmpl   $0x7,0xf01beee8
f0100102:	77 16                	ja     f010011a <boot_aps+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100104:	68 00 70 00 00       	push   $0x7000
f0100109:	68 58 6a 10 f0       	push   $0xf0106a58
f010010e:	6a 62                	push   $0x62
f0100110:	68 19 6a 10 f0       	push   $0xf0106a19
f0100115:	e8 87 01 00 00       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f010011a:	b8 00 70 00 00       	mov    $0x7000,%eax
f010011f:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 f2 5e 10 f0       	mov    $0xf0105ef2,%eax
f010012d:	2d 78 5e 10 f0       	sub    $0xf0105e78,%eax
f0100132:	50                   	push   %eax
f0100133:	68 78 5e 10 f0       	push   $0xf0105e78
f0100138:	56                   	push   %esi
f0100139:	e8 a6 5b 00 00       	call   f0105ce4 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013e:	bb 20 f0 1b f0       	mov    $0xf01bf020,%ebx
f0100143:	83 c4 10             	add    $0x10,%esp
f0100146:	8b 15 c4 f3 1b f0    	mov    0xf01bf3c4,%edx
f010014c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100153:	29 d0                	sub    %edx,%eax
f0100155:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100158:	8d 04 85 20 f0 1b f0 	lea    -0xfe40fe0(,%eax,4),%eax
f010015f:	39 d8                	cmp    %ebx,%eax
f0100161:	0f 86 aa 00 00 00    	jbe    f0100211 <boot_aps+0x11b>
		if (c == cpus + cpunum())  // We've started already.
f0100167:	e8 a6 62 00 00       	call   f0106412 <cpunum>
f010016c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100173:	29 c2                	sub    %eax,%edx
f0100175:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0100178:	8d 14 95 20 f0 1b f0 	lea    -0xfe40fe0(,%edx,4),%edx
f010017f:	39 da                	cmp    %ebx,%edx
f0100181:	74 6a                	je     f01001ed <boot_aps+0xf7>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100183:	89 d9                	mov    %ebx,%ecx
f0100185:	81 e9 20 f0 1b f0    	sub    $0xf01bf020,%ecx
f010018b:	c1 f9 02             	sar    $0x2,%ecx
f010018e:	89 ca                	mov    %ecx,%edx
f0100190:	c1 e2 07             	shl    $0x7,%edx
f0100193:	29 ca                	sub    %ecx,%edx
f0100195:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
f0100198:	89 d0                	mov    %edx,%eax
f010019a:	c1 e0 0e             	shl    $0xe,%eax
f010019d:	29 d0                	sub    %edx,%eax
f010019f:	c1 e0 04             	shl    $0x4,%eax
f01001a2:	01 c8                	add    %ecx,%eax
f01001a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01001a7:	c1 e0 0f             	shl    $0xf,%eax
f01001aa:	05 00 80 1c f0       	add    $0xf01c8000,%eax
f01001af:	a3 e4 ee 1b f0       	mov    %eax,0xf01beee4
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01001b4:	89 f0                	mov    %esi,%eax
	if ((uint32_t)kva < KERNBASE)
f01001b6:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01001bc:	77 12                	ja     f01001d0 <boot_aps+0xda>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001be:	56                   	push   %esi
f01001bf:	68 7c 6a 10 f0       	push   $0xf0106a7c
f01001c4:	6a 6d                	push   $0x6d
f01001c6:	68 19 6a 10 f0       	push   $0xf0106a19
f01001cb:	e8 d1 00 00 00       	call   f01002a1 <_panic>
f01001d0:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01001d5:	83 ec 08             	sub    $0x8,%esp
f01001d8:	50                   	push   %eax
f01001d9:	0f b6 03             	movzbl (%ebx),%eax
f01001dc:	50                   	push   %eax
f01001dd:	e8 6d 62 00 00       	call   f010644f <lapic_startap>
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001e2:	83 c4 10             	add    $0x10,%esp
f01001e5:	8b 43 04             	mov    0x4(%ebx),%eax
f01001e8:	83 f8 01             	cmp    $0x1,%eax
f01001eb:	75 f8                	jne    f01001e5 <boot_aps+0xef>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ed:	83 c3 74             	add    $0x74,%ebx
f01001f0:	8b 15 c4 f3 1b f0    	mov    0xf01bf3c4,%edx
f01001f6:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01001fd:	29 d0                	sub    %edx,%eax
f01001ff:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100202:	8d 04 85 20 f0 1b f0 	lea    -0xfe40fe0(,%eax,4),%eax
f0100209:	39 d8                	cmp    %ebx,%eax
f010020b:	0f 87 56 ff ff ff    	ja     f0100167 <boot_aps+0x71>
		lapic_startap(c->cpu_id, PADDR(code));
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
			;
	}
}
f0100211:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100214:	5b                   	pop    %ebx
f0100215:	5e                   	pop    %esi
f0100216:	c9                   	leave  
f0100217:	c3                   	ret    

f0100218 <mp_main>:

// Setup code for APs
void
mp_main(void)
{
f0100218:	55                   	push   %ebp
f0100219:	89 e5                	mov    %esp,%ebp
f010021b:	83 ec 08             	sub    $0x8,%esp
f010021e:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
	if ((uint32_t)kva < KERNBASE)
f0100223:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100228:	77 12                	ja     f010023c <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010022a:	50                   	push   %eax
f010022b:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100230:	6a 79                	push   $0x79
f0100232:	68 19 6a 10 f0       	push   $0xf0106a19
f0100237:	e8 65 00 00 00       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f010023c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100241:	0f 22 d8             	mov    %eax,%cr3
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100244:	83 ec 10             	sub    $0x10,%esp
f0100247:	e8 c6 61 00 00       	call   f0106412 <cpunum>
f010024c:	83 c4 08             	add    $0x8,%esp
f010024f:	50                   	push   %eax
f0100250:	68 25 6a 10 f0       	push   $0xf0106a25
f0100255:	e8 78 37 00 00       	call   f01039d2 <cprintf>

	lapic_init();
f010025a:	e8 98 60 00 00       	call   f01062f7 <lapic_init>
	env_init_percpu();
f010025f:	e8 9f 2e 00 00       	call   f0103103 <env_init_percpu>
	trap_init_percpu();
f0100264:	e8 1d 3e 00 00       	call   f0104086 <trap_init_percpu>
        return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0100269:	83 c4 10             	add    $0x10,%esp
f010026c:	e8 a1 61 00 00       	call   f0106412 <cpunum>
f0100271:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100278:	29 c2                	sub    %eax,%edx
f010027a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010027d:	c1 e2 02             	shl    $0x2,%edx
f0100280:	b8 01 00 00 00       	mov    $0x1,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100285:	f0 87 82 24 f0 1b f0 	lock xchg %eax,-0xfe40fdc(%edx)
f010028c:	83 ec 0c             	sub    $0xc,%esp
f010028f:	68 c0 95 12 f0       	push   $0xf01295c0
f0100294:	e8 3f 63 00 00       	call   f01065d8 <spin_lock>
f0100299:	83 c4 10             	add    $0x10,%esp
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010029c:	e8 d7 46 00 00       	call   f0104978 <sched_yield>

f01002a1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01002a1:	55                   	push   %ebp
f01002a2:	89 e5                	mov    %esp,%ebp
f01002a4:	56                   	push   %esi
f01002a5:	53                   	push   %ebx
f01002a6:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01002a9:	83 3d e0 ee 1b f0 00 	cmpl   $0x0,0xf01beee0
f01002b0:	75 40                	jne    f01002f2 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01002b2:	89 35 e0 ee 1b f0    	mov    %esi,0xf01beee0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01002b8:	fa                   	cli    
f01002b9:	fc                   	cld    

	va_start(ap, fmt);
f01002ba:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01002bd:	ff 75 0c             	pushl  0xc(%ebp)
f01002c0:	ff 75 08             	pushl  0x8(%ebp)
f01002c3:	83 ec 08             	sub    $0x8,%esp
f01002c6:	e8 47 61 00 00       	call   f0106412 <cpunum>
f01002cb:	83 c4 08             	add    $0x8,%esp
f01002ce:	50                   	push   %eax
f01002cf:	68 a0 6a 10 f0       	push   $0xf0106aa0
f01002d4:	e8 f9 36 00 00       	call   f01039d2 <cprintf>
	vcprintf(fmt, ap);
f01002d9:	83 c4 08             	add    $0x8,%esp
f01002dc:	53                   	push   %ebx
f01002dd:	56                   	push   %esi
f01002de:	e8 c9 36 00 00       	call   f01039ac <vcprintf>
	cprintf("\n");
f01002e3:	c7 04 24 cc 6a 10 f0 	movl   $0xf0106acc,(%esp)
f01002ea:	e8 e3 36 00 00       	call   f01039d2 <cprintf>
	va_end(ap);
f01002ef:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01002f2:	83 ec 0c             	sub    $0xc,%esp
f01002f5:	6a 00                	push   $0x0
f01002f7:	e8 a2 07 00 00       	call   f0100a9e <monitor>
f01002fc:	83 c4 10             	add    $0x10,%esp
f01002ff:	eb f1                	jmp    f01002f2 <_panic+0x51>

f0100301 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100301:	55                   	push   %ebp
f0100302:	89 e5                	mov    %esp,%ebp
f0100304:	53                   	push   %ebx
f0100305:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100308:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010030b:	ff 75 0c             	pushl  0xc(%ebp)
f010030e:	ff 75 08             	pushl  0x8(%ebp)
f0100311:	68 3b 6a 10 f0       	push   $0xf0106a3b
f0100316:	e8 b7 36 00 00       	call   f01039d2 <cprintf>
	vcprintf(fmt, ap);
f010031b:	83 c4 08             	add    $0x8,%esp
f010031e:	53                   	push   %ebx
f010031f:	ff 75 10             	pushl  0x10(%ebp)
f0100322:	e8 85 36 00 00       	call   f01039ac <vcprintf>
	cprintf("\n");
f0100327:	c7 04 24 cc 6a 10 f0 	movl   $0xf0106acc,(%esp)
f010032e:	e8 9f 36 00 00       	call   f01039d2 <cprintf>
	va_end(ap);
}
f0100333:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100336:	c9                   	leave  
f0100337:	c3                   	ret    

f0100338 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100338:	55                   	push   %ebp
f0100339:	89 e5                	mov    %esp,%ebp
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010033b:	ba 84 00 00 00       	mov    $0x84,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100340:	ec                   	in     (%dx),%al
f0100341:	ec                   	in     (%dx),%al
f0100342:	ec                   	in     (%dx),%al
f0100343:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100344:	c9                   	leave  
f0100345:	c3                   	ret    

f0100346 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100346:	55                   	push   %ebp
f0100347:	89 e5                	mov    %esp,%ebp
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f0100349:	ba fd 03 00 00       	mov    $0x3fd,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010034e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010034f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f0100354:	a8 01                	test   $0x1,%al
f0100356:	74 09                	je     f0100361 <serial_proc_data+0x1b>
f0100358:	ba f8 03 00 00       	mov    $0x3f8,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035d:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010035e:	0f b6 d0             	movzbl %al,%edx
	return inb(COM1+COM_RX);
}
f0100361:	89 d0                	mov    %edx,%eax
f0100363:	c9                   	leave  
f0100364:	c3                   	ret    

f0100365 <serial_intr>:

void
serial_intr(void)
{
f0100365:	55                   	push   %ebp
f0100366:	89 e5                	mov    %esp,%ebp
f0100368:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010036b:	83 3d 04 e0 1b f0 00 	cmpl   $0x0,0xf01be004
f0100372:	74 10                	je     f0100384 <serial_intr+0x1f>
		cons_intr(serial_proc_data);
f0100374:	83 ec 0c             	sub    $0xc,%esp
f0100377:	68 46 03 10 f0       	push   $0xf0100346
f010037c:	e8 dc 03 00 00       	call   f010075d <cons_intr>
f0100381:	83 c4 10             	add    $0x10,%esp
}
f0100384:	c9                   	leave  
f0100385:	c3                   	ret    

f0100386 <serial_putc>:

static void
serial_putc(int c)
{
f0100386:	55                   	push   %ebp
f0100387:	89 e5                	mov    %esp,%ebp
f0100389:	56                   	push   %esi
f010038a:	53                   	push   %ebx
	int i;
	
	for (i = 0;
f010038b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100390:	ba fd 03 00 00       	mov    $0x3fd,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100395:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f0100396:	a8 20                	test   $0x20,%al
f0100398:	75 1a                	jne    f01003b4 <serial_putc+0x2e>
f010039a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010039f:	e8 94 ff ff ff       	call   f0100338 <delay>
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003a4:	43                   	inc    %ebx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a5:	89 f2                	mov    %esi,%edx
f01003a7:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f01003a8:	a8 20                	test   $0x20,%al
f01003aa:	75 08                	jne    f01003b4 <serial_putc+0x2e>
f01003ac:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003b2:	7e eb                	jle    f010039f <serial_putc+0x19>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	8a 45 08             	mov    0x8(%ebp),%al
f01003bc:	ee                   	out    %al,(%dx)
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
}
f01003bd:	5b                   	pop    %ebx
f01003be:	5e                   	pop    %esi
f01003bf:	c9                   	leave  
f01003c0:	c3                   	ret    

f01003c1 <serial_init>:

static void
serial_init(void)
{
f01003c1:	55                   	push   %ebp
f01003c2:	89 e5                	mov    %esp,%ebp
f01003c4:	53                   	push   %ebx
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003c5:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01003ca:	b0 00                	mov    $0x0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cc:	89 da                	mov    %ebx,%edx
f01003ce:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003cf:	b2 fb                	mov    $0xfb,%dl
f01003d1:	b0 80                	mov    $0x80,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003d4:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01003d9:	b0 0c                	mov    $0xc,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003db:	89 ca                	mov    %ecx,%edx
f01003dd:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003de:	b2 f9                	mov    $0xf9,%dl
f01003e0:	b0 00                	mov    $0x0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e2:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003e3:	b2 fb                	mov    $0xfb,%dl
f01003e5:	b0 03                	mov    $0x3,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e7:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003e8:	b2 fc                	mov    $0xfc,%dl
f01003ea:	b0 00                	mov    $0x0,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ec:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01003ed:	b2 f9                	mov    $0xf9,%dl
f01003ef:	b0 01                	mov    $0x1,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f1:	ee                   	out    %al,(%dx)
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f01003f2:	b2 fd                	mov    $0xfd,%dl
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f4:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f01003f5:	3c ff                	cmp    $0xff,%al
f01003f7:	0f 95 c0             	setne  %al
f01003fa:	0f b6 c0             	movzbl %al,%eax
f01003fd:	a3 04 e0 1b f0       	mov    %eax,0xf01be004
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100402:	89 da                	mov    %ebx,%edx
f0100404:	ec                   	in     (%dx),%al
f0100405:	89 ca                	mov    %ecx,%edx
f0100407:	ec                   	in     (%dx),%al
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f0100408:	5b                   	pop    %ebx
f0100409:	c9                   	leave  
f010040a:	c3                   	ret    

f010040b <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f010040b:	55                   	push   %ebp
f010040c:	89 e5                	mov    %esp,%ebp
f010040e:	56                   	push   %esi
f010040f:	53                   	push   %ebx
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100410:	bb 00 00 00 00       	mov    $0x0,%ebx
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f0100415:	ba 79 03 00 00       	mov    $0x379,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041a:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010041b:	84 c0                	test   %al,%al
f010041d:	78 1a                	js     f0100439 <lpt_putc+0x2e>
f010041f:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100424:	e8 0f ff ff ff       	call   f0100338 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100429:	43                   	inc    %ebx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042a:	89 f2                	mov    %esi,%edx
f010042c:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010042d:	84 c0                	test   %al,%al
f010042f:	78 08                	js     f0100439 <lpt_putc+0x2e>
f0100431:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100437:	7e eb                	jle    f0100424 <lpt_putc+0x19>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0100439:	ba 78 03 00 00       	mov    $0x378,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043e:	8a 45 08             	mov    0x8(%ebp),%al
f0100441:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0100442:	b2 7a                	mov    $0x7a,%dl
f0100444:	b0 0d                	mov    $0xd,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0100447:	b0 08                	mov    $0x8,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100449:	ee                   	out    %al,(%dx)
		delay();
	outb(0x378+0, c);
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f010044a:	5b                   	pop    %ebx
f010044b:	5e                   	pop    %esi
f010044c:	c9                   	leave  
f010044d:	c3                   	ret    

f010044e <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f010044e:	55                   	push   %ebp
f010044f:	89 e5                	mov    %esp,%ebp
f0100451:	57                   	push   %edi
f0100452:	56                   	push   %esi
f0100453:	53                   	push   %ebx
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100454:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	was = *cp;
f0100459:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100460:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100467:	5a a5 
	if (*cp != 0xA55A) {
f0100469:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010046f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100473:	74 10                	je     f0100485 <cga_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100475:	66 be 00 00          	mov    $0x0,%si
		addr_6845 = MONO_BASE;
f0100479:	c7 05 08 e0 1b f0 b4 	movl   $0x3b4,0xf01be008
f0100480:	03 00 00 
f0100483:	eb 0d                	jmp    f0100492 <cga_init+0x44>
	} else {
		*cp = was;
f0100485:	66 89 16             	mov    %dx,(%esi)
		addr_6845 = CGA_BASE;
f0100488:	c7 05 08 e0 1b f0 d4 	movl   $0x3d4,0xf01be008
f010048f:	03 00 00 
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0100492:	8b 0d 08 e0 1b f0    	mov    0xf01be008,%ecx
f0100498:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010049a:	89 ca                	mov    %ecx,%edx
f010049c:	ee                   	out    %al,(%dx)
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010049d:	8d 79 01             	lea    0x1(%ecx),%edi
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004a0:	89 fa                	mov    %edi,%edx
f01004a2:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f01004a3:	0f b6 d8             	movzbl %al,%ebx
f01004a6:	c1 e3 08             	shl    $0x8,%ebx
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01004a9:	b0 0f                	mov    $0xf,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004ab:	89 ca                	mov    %ecx,%edx
f01004ad:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004ae:	89 fa                	mov    %edi,%edx
f01004b0:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f01004b1:	0f b6 c0             	movzbl %al,%eax
f01004b4:	09 c3                	or     %eax,%ebx
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01004b6:	89 35 0c e0 1b f0    	mov    %esi,0xf01be00c
	crt_pos = pos;
f01004bc:	66 89 1d 10 e0 1b f0 	mov    %bx,0xf01be010
}
f01004c3:	5b                   	pop    %ebx
f01004c4:	5e                   	pop    %esi
f01004c5:	5f                   	pop    %edi
f01004c6:	c9                   	leave  
f01004c7:	c3                   	ret    

f01004c8 <cga_putc>:



static void
cga_putc(int c)
{
f01004c8:	55                   	push   %ebp
f01004c9:	89 e5                	mov    %esp,%ebp
f01004cb:	56                   	push   %esi
f01004cc:	53                   	push   %ebx
f01004cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004d0:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f01004d6:	75 03                	jne    f01004db <cga_putc+0x13>
		c |= 0x0700;
f01004d8:	80 cd 07             	or     $0x7,%ch

	switch (c & 0xff) {
f01004db:	0f b6 c1             	movzbl %cl,%eax
f01004de:	83 f8 09             	cmp    $0x9,%eax
f01004e1:	74 7b                	je     f010055e <cga_putc+0x96>
f01004e3:	83 f8 09             	cmp    $0x9,%eax
f01004e6:	7f 0a                	jg     f01004f2 <cga_putc+0x2a>
f01004e8:	83 f8 08             	cmp    $0x8,%eax
f01004eb:	74 14                	je     f0100501 <cga_putc+0x39>
f01004ed:	e9 ab 00 00 00       	jmp    f010059d <cga_putc+0xd5>
f01004f2:	83 f8 0a             	cmp    $0xa,%eax
f01004f5:	74 3c                	je     f0100533 <cga_putc+0x6b>
f01004f7:	83 f8 0d             	cmp    $0xd,%eax
f01004fa:	74 3f                	je     f010053b <cga_putc+0x73>
f01004fc:	e9 9c 00 00 00       	jmp    f010059d <cga_putc+0xd5>
	case '\b':
		if (crt_pos > 0) {
f0100501:	66 83 3d 10 e0 1b f0 	cmpw   $0x0,0xf01be010
f0100508:	00 
f0100509:	0f 84 a5 00 00 00    	je     f01005b4 <cga_putc+0xec>
			crt_pos--;
f010050f:	66 ff 0d 10 e0 1b f0 	decw   0xf01be010
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100516:	0f b7 05 10 e0 1b f0 	movzwl 0xf01be010,%eax
f010051d:	89 ca                	mov    %ecx,%edx
f010051f:	b2 00                	mov    $0x0,%dl
f0100521:	83 ca 20             	or     $0x20,%edx
f0100524:	8b 0d 0c e0 1b f0    	mov    0xf01be00c,%ecx
f010052a:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
		}
		break;
f010052e:	e9 81 00 00 00       	jmp    f01005b4 <cga_putc+0xec>
	case '\n':
		crt_pos += CRT_COLS;
f0100533:	66 83 05 10 e0 1b f0 	addw   $0x50,0xf01be010
f010053a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010053b:	66 8b 1d 10 e0 1b f0 	mov    0xf01be010,%bx
f0100542:	b9 50 00 00 00       	mov    $0x50,%ecx
f0100547:	ba 00 00 00 00       	mov    $0x0,%edx
f010054c:	89 d8                	mov    %ebx,%eax
f010054e:	66 f7 f1             	div    %cx
f0100551:	89 d8                	mov    %ebx,%eax
f0100553:	66 29 d0             	sub    %dx,%ax
f0100556:	66 a3 10 e0 1b f0    	mov    %ax,0xf01be010
		break;
f010055c:	eb 56                	jmp    f01005b4 <cga_putc+0xec>
	case '\t':
		cons_putc(' ');
f010055e:	83 ec 0c             	sub    $0xc,%esp
f0100561:	6a 20                	push   $0x20
f0100563:	e8 7a 02 00 00       	call   f01007e2 <cons_putc>
		cons_putc(' ');
f0100568:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010056f:	e8 6e 02 00 00       	call   f01007e2 <cons_putc>
		cons_putc(' ');
f0100574:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010057b:	e8 62 02 00 00       	call   f01007e2 <cons_putc>
		cons_putc(' ');
f0100580:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100587:	e8 56 02 00 00       	call   f01007e2 <cons_putc>
		cons_putc(' ');
f010058c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100593:	e8 4a 02 00 00       	call   f01007e2 <cons_putc>
		break;
f0100598:	83 c4 10             	add    $0x10,%esp
f010059b:	eb 17                	jmp    f01005b4 <cga_putc+0xec>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010059d:	0f b7 15 10 e0 1b f0 	movzwl 0xf01be010,%edx
f01005a4:	a1 0c e0 1b f0       	mov    0xf01be00c,%eax
f01005a9:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01005ad:	66 ff 05 10 e0 1b f0 	incw   0xf01be010
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005b4:	66 81 3d 10 e0 1b f0 	cmpw   $0x7cf,0xf01be010
f01005bb:	cf 07 
f01005bd:	76 3f                	jbe    f01005fe <cga_putc+0x136>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005bf:	83 ec 04             	sub    $0x4,%esp
f01005c2:	68 00 0f 00 00       	push   $0xf00
f01005c7:	8b 15 0c e0 1b f0    	mov    0xf01be00c,%edx
f01005cd:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f01005d3:	50                   	push   %eax
f01005d4:	52                   	push   %edx
f01005d5:	e8 0a 57 00 00       	call   f0105ce4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005da:	ba 80 07 00 00       	mov    $0x780,%edx
f01005df:	83 c4 10             	add    $0x10,%esp
			crt_buf[i] = 0x0700 | ' ';
f01005e2:	a1 0c e0 1b f0       	mov    0xf01be00c,%eax
f01005e7:	66 c7 04 50 20 07    	movw   $0x720,(%eax,%edx,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ed:	42                   	inc    %edx
f01005ee:	81 fa cf 07 00 00    	cmp    $0x7cf,%edx
f01005f4:	7e ec                	jle    f01005e2 <cga_putc+0x11a>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005f6:	66 83 2d 10 e0 1b f0 	subw   $0x50,0xf01be010
f01005fd:	50 
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01005fe:	8b 1d 08 e0 1b f0    	mov    0xf01be008,%ebx
f0100604:	b0 0e                	mov    $0xe,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100606:	89 da                	mov    %ebx,%edx
f0100608:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0100609:	8d 73 01             	lea    0x1(%ebx),%esi
f010060c:	66 8b 0d 10 e0 1b f0 	mov    0xf01be010,%cx
f0100613:	89 c8                	mov    %ecx,%eax
f0100615:	66 c1 e8 08          	shr    $0x8,%ax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	89 f2                	mov    %esi,%edx
f010061b:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f010061c:	b0 0f                	mov    $0xf,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061e:	89 da                	mov    %ebx,%edx
f0100620:	ee                   	out    %al,(%dx)
f0100621:	88 c8                	mov    %cl,%al
f0100623:	89 f2                	mov    %esi,%edx
f0100625:	ee                   	out    %al,(%dx)
	/* move that little blinky thing */
	outb(addr_6845, 14);
	outb(addr_6845 + 1, crt_pos >> 8);
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100626:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100629:	5b                   	pop    %ebx
f010062a:	5e                   	pop    %esi
f010062b:	c9                   	leave  
f010062c:	c3                   	ret    

f010062d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010062d:	55                   	push   %ebp
f010062e:	89 e5                	mov    %esp,%ebp
f0100630:	53                   	push   %ebx
f0100631:	83 ec 04             	sub    $0x4,%esp
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f0100634:	ba 64 00 00 00       	mov    $0x64,%edx
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100639:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010063a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010063f:	a8 01                	test   $0x1,%al
f0100641:	0f 84 db 00 00 00    	je     f0100722 <kbd_proc_data+0xf5>
f0100647:	ba 60 00 00 00       	mov    $0x60,%edx
f010064c:	ec                   	in     (%dx),%al
f010064d:	88 c2                	mov    %al,%dl

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010064f:	3c e0                	cmp    $0xe0,%al
f0100651:	75 11                	jne    f0100664 <kbd_proc_data+0x37>
		// E0 escape character
		shift |= E0ESC;
f0100653:	83 0d 00 e0 1b f0 40 	orl    $0x40,0xf01be000
		return 0;
f010065a:	ba 00 00 00 00       	mov    $0x0,%edx
f010065f:	e9 be 00 00 00       	jmp    f0100722 <kbd_proc_data+0xf5>
	} else if (data & 0x80) {
f0100664:	84 c0                	test   %al,%al
f0100666:	79 2d                	jns    f0100695 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100668:	f6 05 00 e0 1b f0 40 	testb  $0x40,0xf01be000
f010066f:	75 03                	jne    f0100674 <kbd_proc_data+0x47>
f0100671:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100674:	0f b6 c2             	movzbl %dl,%eax
f0100677:	8a 80 00 90 12 f0    	mov    -0xfed7000(%eax),%al
f010067d:	83 c8 40             	or     $0x40,%eax
f0100680:	0f b6 c0             	movzbl %al,%eax
f0100683:	f7 d0                	not    %eax
f0100685:	21 05 00 e0 1b f0    	and    %eax,0xf01be000
		return 0;
f010068b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100690:	e9 8d 00 00 00       	jmp    f0100722 <kbd_proc_data+0xf5>
	} else if (shift & E0ESC) {
f0100695:	a1 00 e0 1b f0       	mov    0xf01be000,%eax
f010069a:	a8 40                	test   $0x40,%al
f010069c:	74 0b                	je     f01006a9 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010069e:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01006a1:	83 e0 bf             	and    $0xffffffbf,%eax
f01006a4:	a3 00 e0 1b f0       	mov    %eax,0xf01be000
	}

	shift |= shiftcode[data];
f01006a9:	0f b6 ca             	movzbl %dl,%ecx
f01006ac:	0f b6 81 00 90 12 f0 	movzbl -0xfed7000(%ecx),%eax
f01006b3:	0b 05 00 e0 1b f0    	or     0xf01be000,%eax
	shift ^= togglecode[data];
f01006b9:	0f b6 91 00 91 12 f0 	movzbl -0xfed6f00(%ecx),%edx
f01006c0:	31 c2                	xor    %eax,%edx
f01006c2:	89 15 00 e0 1b f0    	mov    %edx,0xf01be000

	c = charcode[shift & (CTL | SHIFT)][data];
f01006c8:	89 d0                	mov    %edx,%eax
f01006ca:	83 e0 03             	and    $0x3,%eax
f01006cd:	8b 04 85 00 95 12 f0 	mov    -0xfed6b00(,%eax,4),%eax
f01006d4:	0f b6 1c 08          	movzbl (%eax,%ecx,1),%ebx
	if (shift & CAPSLOCK) {
f01006d8:	f6 c2 08             	test   $0x8,%dl
f01006db:	74 18                	je     f01006f5 <kbd_proc_data+0xc8>
		if ('a' <= c && c <= 'z')
f01006dd:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01006e0:	83 f8 19             	cmp    $0x19,%eax
f01006e3:	77 05                	ja     f01006ea <kbd_proc_data+0xbd>
			c += 'A' - 'a';
f01006e5:	83 eb 20             	sub    $0x20,%ebx
f01006e8:	eb 0b                	jmp    f01006f5 <kbd_proc_data+0xc8>
		else if ('A' <= c && c <= 'Z')
f01006ea:	8d 43 bf             	lea    -0x41(%ebx),%eax
f01006ed:	83 f8 19             	cmp    $0x19,%eax
f01006f0:	77 03                	ja     f01006f5 <kbd_proc_data+0xc8>
			c += 'a' - 'A';
f01006f2:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01006f5:	a1 00 e0 1b f0       	mov    0xf01be000,%eax
f01006fa:	f7 d0                	not    %eax
f01006fc:	a8 06                	test   $0x6,%al
f01006fe:	75 20                	jne    f0100720 <kbd_proc_data+0xf3>
f0100700:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100706:	75 18                	jne    f0100720 <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100708:	83 ec 0c             	sub    $0xc,%esp
f010070b:	68 c2 6a 10 f0       	push   $0xf0106ac2
f0100710:	e8 bd 32 00 00       	call   f01039d2 <cprintf>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0100715:	83 c4 10             	add    $0x10,%esp
f0100718:	ba 92 00 00 00       	mov    $0x92,%edx
f010071d:	b0 03                	mov    $0x3,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010071f:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100720:	89 da                	mov    %ebx,%edx
}
f0100722:	89 d0                	mov    %edx,%eax
f0100724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100727:	c9                   	leave  
f0100728:	c3                   	ret    

f0100729 <kbd_intr>:

void
kbd_intr(void)
{
f0100729:	55                   	push   %ebp
f010072a:	89 e5                	mov    %esp,%ebp
f010072c:	83 ec 14             	sub    $0x14,%esp
	cons_intr(kbd_proc_data);
f010072f:	68 2d 06 10 f0       	push   $0xf010062d
f0100734:	e8 24 00 00 00       	call   f010075d <cons_intr>
}
f0100739:	c9                   	leave  
f010073a:	c3                   	ret    

f010073b <kbd_init>:

static void
kbd_init(void)
{
f010073b:	55                   	push   %ebp
f010073c:	89 e5                	mov    %esp,%ebp
f010073e:	83 ec 08             	sub    $0x8,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100741:	e8 e3 ff ff ff       	call   f0100729 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100746:	83 ec 0c             	sub    $0xc,%esp
f0100749:	0f b7 05 b0 95 12 f0 	movzwl 0xf01295b0,%eax
f0100750:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100755:	50                   	push   %eax
f0100756:	e8 c7 31 00 00       	call   f0103922 <irq_setmask_8259A>
}
f010075b:	c9                   	leave  
f010075c:	c3                   	ret    

f010075d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	53                   	push   %ebx
f0100761:	83 ec 04             	sub    $0x4,%esp
f0100764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100767:	eb 26                	jmp    f010078f <cons_intr+0x32>
		if (c == 0)
f0100769:	85 d2                	test   %edx,%edx
f010076b:	74 22                	je     f010078f <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f010076d:	a1 24 e2 1b f0       	mov    0xf01be224,%eax
f0100772:	88 90 20 e0 1b f0    	mov    %dl,-0xfe41fe0(%eax)
f0100778:	40                   	inc    %eax
f0100779:	a3 24 e2 1b f0       	mov    %eax,0xf01be224
		if (cons.wpos == CONSBUFSIZE)
f010077e:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100783:	75 0a                	jne    f010078f <cons_intr+0x32>
			cons.wpos = 0;
f0100785:	c7 05 24 e2 1b f0 00 	movl   $0x0,0xf01be224
f010078c:	00 00 00 
f010078f:	ff d3                	call   *%ebx
f0100791:	89 c2                	mov    %eax,%edx
f0100793:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100796:	75 d1                	jne    f0100769 <cons_intr+0xc>
	}
}
f0100798:	83 c4 04             	add    $0x4,%esp
f010079b:	5b                   	pop    %ebx
f010079c:	c9                   	leave  
f010079d:	c3                   	ret    

f010079e <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010079e:	55                   	push   %ebp
f010079f:	89 e5                	mov    %esp,%ebp
f01007a1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01007a4:	e8 bc fb ff ff       	call   f0100365 <serial_intr>
	kbd_intr();
f01007a9:	e8 7b ff ff ff       	call   f0100729 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01007ae:	a1 20 e2 1b f0       	mov    0xf01be220,%eax
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01007b3:	ba 00 00 00 00       	mov    $0x0,%edx
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01007b8:	3b 05 24 e2 1b f0    	cmp    0xf01be224,%eax
f01007be:	74 1e                	je     f01007de <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01007c0:	0f b6 90 20 e0 1b f0 	movzbl -0xfe41fe0(%eax),%edx
f01007c7:	40                   	inc    %eax
f01007c8:	a3 20 e2 1b f0       	mov    %eax,0xf01be220
		if (cons.rpos == CONSBUFSIZE)
f01007cd:	3d 00 02 00 00       	cmp    $0x200,%eax
f01007d2:	75 0a                	jne    f01007de <cons_getc+0x40>
			cons.rpos = 0;
f01007d4:	c7 05 20 e2 1b f0 00 	movl   $0x0,0xf01be220
f01007db:	00 00 00 
		return c;
	}
	return 0;
}
f01007de:	89 d0                	mov    %edx,%eax
f01007e0:	c9                   	leave  
f01007e1:	c3                   	ret    

f01007e2 <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
f01007e2:	55                   	push   %ebp
f01007e3:	89 e5                	mov    %esp,%ebp
f01007e5:	53                   	push   %ebx
f01007e6:	83 ec 04             	sub    $0x4,%esp
f01007e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	serial_putc(c);
f01007ec:	53                   	push   %ebx
f01007ed:	e8 94 fb ff ff       	call   f0100386 <serial_putc>
	lpt_putc(c);
f01007f2:	53                   	push   %ebx
f01007f3:	e8 13 fc ff ff       	call   f010040b <lpt_putc>
	cga_putc(c);
f01007f8:	83 ec 04             	sub    $0x4,%esp
f01007fb:	53                   	push   %ebx
f01007fc:	e8 c7 fc ff ff       	call   f01004c8 <cga_putc>
}
f0100801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100804:	c9                   	leave  
f0100805:	c3                   	ret    

f0100806 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100806:	55                   	push   %ebp
f0100807:	89 e5                	mov    %esp,%ebp
f0100809:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f010080c:	e8 3d fc ff ff       	call   f010044e <cga_init>
	kbd_init();
f0100811:	e8 25 ff ff ff       	call   f010073b <kbd_init>
	serial_init();
f0100816:	e8 a6 fb ff ff       	call   f01003c1 <serial_init>

	if (!serial_exists)
f010081b:	83 3d 04 e0 1b f0 00 	cmpl   $0x0,0xf01be004
f0100822:	75 10                	jne    f0100834 <cons_init+0x2e>
		cprintf("Serial port does not exist!\n");
f0100824:	83 ec 0c             	sub    $0xc,%esp
f0100827:	68 ce 6a 10 f0       	push   $0xf0106ace
f010082c:	e8 a1 31 00 00       	call   f01039d2 <cprintf>
f0100831:	83 c4 10             	add    $0x10,%esp
}
f0100834:	c9                   	leave  
f0100835:	c3                   	ret    

f0100836 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100836:	55                   	push   %ebp
f0100837:	89 e5                	mov    %esp,%ebp
f0100839:	83 ec 14             	sub    $0x14,%esp
	cons_putc(c);
f010083c:	ff 75 08             	pushl  0x8(%ebp)
f010083f:	e8 9e ff ff ff       	call   f01007e2 <cons_putc>
}
f0100844:	c9                   	leave  
f0100845:	c3                   	ret    

f0100846 <getchar>:

int
getchar(void)
{
f0100846:	55                   	push   %ebp
f0100847:	89 e5                	mov    %esp,%ebp
f0100849:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010084c:	e8 4d ff ff ff       	call   f010079e <cons_getc>
f0100851:	85 c0                	test   %eax,%eax
f0100853:	74 f7                	je     f010084c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100855:	c9                   	leave  
f0100856:	c3                   	ret    

f0100857 <iscons>:

int
iscons(int fdnum)
{
f0100857:	55                   	push   %ebp
f0100858:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010085a:	b8 01 00 00 00       	mov    $0x1,%eax
f010085f:	c9                   	leave  
f0100860:	c3                   	ret    
f0100861:	00 00                	add    %al,(%eax)
	...

f0100864 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100864:	55                   	push   %ebp
f0100865:	89 e5                	mov    %esp,%ebp
f0100867:	53                   	push   %ebx
f0100868:	83 ec 04             	sub    $0x4,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010086b:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100870:	83 ec 04             	sub    $0x4,%esp
f0100873:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100876:	c1 e0 02             	shl    $0x2,%eax
f0100879:	ff b0 14 95 12 f0    	pushl  -0xfed6aec(%eax)
f010087f:	ff b0 10 95 12 f0    	pushl  -0xfed6af0(%eax)
f0100885:	68 17 6b 10 f0       	push   $0xf0106b17
f010088a:	e8 43 31 00 00       	call   f01039d2 <cprintf>
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010088f:	83 c4 10             	add    $0x10,%esp
f0100892:	43                   	inc    %ebx
f0100893:	83 fb 01             	cmp    $0x1,%ebx
f0100896:	76 d8                	jbe    f0100870 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100898:	b8 00 00 00 00       	mov    $0x0,%eax
f010089d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008a0:	c9                   	leave  
f01008a1:	c3                   	ret    

f01008a2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008a2:	55                   	push   %ebp
f01008a3:	89 e5                	mov    %esp,%ebp
f01008a5:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008a8:	68 20 6b 10 f0       	push   $0xf0106b20
f01008ad:	e8 20 31 00 00       	call   f01039d2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008b2:	83 c4 0c             	add    $0xc,%esp
f01008b5:	68 0c 00 10 00       	push   $0x10000c
f01008ba:	68 0c 00 10 f0       	push   $0xf010000c
f01008bf:	68 b8 6b 10 f0       	push   $0xf0106bb8
f01008c4:	e8 09 31 00 00       	call   f01039d2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008c9:	83 c4 0c             	add    $0xc,%esp
f01008cc:	68 f2 69 10 00       	push   $0x1069f2
f01008d1:	68 f2 69 10 f0       	push   $0xf01069f2
f01008d6:	68 dc 6b 10 f0       	push   $0xf0106bdc
f01008db:	e8 f2 30 00 00       	call   f01039d2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008e0:	83 c4 0c             	add    $0xc,%esp
f01008e3:	68 29 d2 1b 00       	push   $0x1bd229
f01008e8:	68 29 d2 1b f0       	push   $0xf01bd229
f01008ed:	68 00 6c 10 f0       	push   $0xf0106c00
f01008f2:	e8 db 30 00 00       	call   f01039d2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008f7:	83 c4 0c             	add    $0xc,%esp
f01008fa:	68 04 00 20 00       	push   $0x200004
f01008ff:	68 04 00 20 f0       	push   $0xf0200004
f0100904:	68 24 6c 10 f0       	push   $0xf0106c24
f0100909:	e8 c4 30 00 00       	call   f01039d2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010090e:	83 c4 08             	add    $0x8,%esp
f0100911:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100916:	f7 d8                	neg    %eax
f0100918:	05 03 04 20 f0       	add    $0xf0200403,%eax
f010091d:	79 05                	jns    f0100924 <mon_kerninfo+0x82>
f010091f:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100924:	c1 f8 0a             	sar    $0xa,%eax
f0100927:	50                   	push   %eax
f0100928:	68 48 6c 10 f0       	push   $0xf0106c48
f010092d:	e8 a0 30 00 00       	call   f01039d2 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100932:	b8 00 00 00 00       	mov    $0x0,%eax
f0100937:	c9                   	leave  
f0100938:	c3                   	ret    

f0100939 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100939:	55                   	push   %ebp
f010093a:	89 e5                	mov    %esp,%ebp
f010093c:	57                   	push   %edi
f010093d:	56                   	push   %esi
f010093e:	53                   	push   %ebx
f010093f:	83 ec 0c             	sub    $0xc,%esp
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
}

static __inline uint32_t
read_ebp(void)
{
f0100942:	89 ef                	mov    %ebp,%edi

static __inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=r" (esp));
f0100944:	89 e3                	mov    %esp,%ebx

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100946:	89 ee                	mov    %ebp,%esi
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
}

static __inline uint32_t
read_ebp(void)
{
f0100948:	e8 c5 01 00 00       	call   f0100b12 <read_eip>
f010094d:	50                   	push   %eax
f010094e:	53                   	push   %ebx
f010094f:	56                   	push   %esi
f0100950:	68 74 6c 10 f0       	push   $0xf0106c74
f0100955:	e8 78 30 00 00       	call   f01039d2 <cprintf>
	extern char *bootstacktop;

	// Your code here.
	int *p = (int *) read_ebp();  // ebp of current function which means 'mon_backtrace'
	cprintf("read_ebp: %08x\n read_esp: %08x\n read_eip %08x\n", read_ebp(), read_esp(), read_eip());
	cprintf("bootstacktop: %08x\n", bootstacktop);
f010095a:	83 c4 08             	add    $0x8,%esp
f010095d:	ff 35 00 70 12 f0    	pushl  0xf0127000
f0100963:	68 39 6b 10 f0       	push   $0xf0106b39
f0100968:	e8 65 30 00 00       	call   f01039d2 <cprintf>

	while (p < (int *) bootstacktop) {
f010096d:	83 c4 10             	add    $0x10,%esp
		p = (int *)*p;
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", p, p, *(p-4), *(p-3), *(p-2), *(p-1), *p);
f0100970:	3b 3d 00 70 12 f0    	cmp    0xf0127000,%edi
f0100976:	73 27                	jae    f010099f <mon_backtrace+0x66>
	int *p = (int *) read_ebp();  // ebp of current function which means 'mon_backtrace'
	cprintf("read_ebp: %08x\n read_esp: %08x\n read_eip %08x\n", read_ebp(), read_esp(), read_eip());
	cprintf("bootstacktop: %08x\n", bootstacktop);

	while (p < (int *) bootstacktop) {
		p = (int *)*p;
f0100978:	8b 3f                	mov    (%edi),%edi
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", p, p, *(p-4), *(p-3), *(p-2), *(p-1), *p);
f010097a:	ff 37                	pushl  (%edi)
f010097c:	ff 77 fc             	pushl  -0x4(%edi)
f010097f:	ff 77 f8             	pushl  -0x8(%edi)
f0100982:	ff 77 f4             	pushl  -0xc(%edi)
f0100985:	ff 77 f0             	pushl  -0x10(%edi)
f0100988:	57                   	push   %edi
f0100989:	57                   	push   %edi
f010098a:	68 a4 6c 10 f0       	push   $0xf0106ca4
f010098f:	e8 3e 30 00 00       	call   f01039d2 <cprintf>
f0100994:	83 c4 20             	add    $0x20,%esp
f0100997:	3b 3d 00 70 12 f0    	cmp    0xf0127000,%edi
f010099d:	72 d9                	jb     f0100978 <mon_backtrace+0x3f>
	}
	
	return 0;
}
f010099f:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a7:	5b                   	pop    %ebx
f01009a8:	5e                   	pop    %esi
f01009a9:	5f                   	pop    %edi
f01009aa:	c9                   	leave  
f01009ab:	c3                   	ret    

f01009ac <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f01009ac:	55                   	push   %ebp
f01009ad:	89 e5                	mov    %esp,%ebp
f01009af:	57                   	push   %edi
f01009b0:	56                   	push   %esi
f01009b1:	53                   	push   %ebx
f01009b2:	83 ec 4c             	sub    $0x4c,%esp
f01009b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009b8:	be 00 00 00 00       	mov    $0x0,%esi
	argv[argc] = 0;
f01009bd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009c4:	eb 04                	jmp    f01009ca <runcmd+0x1e>
			*buf++ = 0;
f01009c6:	c6 03 00             	movb   $0x0,(%ebx)
f01009c9:	43                   	inc    %ebx
f01009ca:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009cd:	74 49                	je     f0100a18 <runcmd+0x6c>
f01009cf:	83 ec 08             	sub    $0x8,%esp
f01009d2:	0f be 03             	movsbl (%ebx),%eax
f01009d5:	50                   	push   %eax
f01009d6:	68 4d 6b 10 f0       	push   $0xf0106b4d
f01009db:	e8 78 52 00 00       	call   f0105c58 <strchr>
f01009e0:	83 c4 10             	add    $0x10,%esp
f01009e3:	85 c0                	test   %eax,%eax
f01009e5:	75 df                	jne    f01009c6 <runcmd+0x1a>
		if (*buf == 0)
f01009e7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009ea:	74 2c                	je     f0100a18 <runcmd+0x6c>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009ec:	83 fe 0f             	cmp    $0xf,%esi
f01009ef:	74 3a                	je     f0100a2b <runcmd+0x7f>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f01009f1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009f5:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009f6:	eb 01                	jmp    f01009f9 <runcmd+0x4d>
			buf++;
f01009f8:	43                   	inc    %ebx
f01009f9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009fc:	74 1a                	je     f0100a18 <runcmd+0x6c>
f01009fe:	83 ec 08             	sub    $0x8,%esp
f0100a01:	0f be 03             	movsbl (%ebx),%eax
f0100a04:	50                   	push   %eax
f0100a05:	68 4d 6b 10 f0       	push   $0xf0106b4d
f0100a0a:	e8 49 52 00 00       	call   f0105c58 <strchr>
f0100a0f:	83 c4 10             	add    $0x10,%esp
f0100a12:	85 c0                	test   %eax,%eax
f0100a14:	74 e2                	je     f01009f8 <runcmd+0x4c>
f0100a16:	eb b2                	jmp    f01009ca <runcmd+0x1e>
	}
	argv[argc] = 0;
f0100a18:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a1f:	00 

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
f0100a20:	b8 00 00 00 00       	mov    $0x0,%eax
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
f0100a25:	85 f6                	test   %esi,%esi
f0100a27:	74 6d                	je     f0100a96 <runcmd+0xea>
f0100a29:	eb 29                	jmp    f0100a54 <runcmd+0xa8>
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a2b:	83 ec 08             	sub    $0x8,%esp
f0100a2e:	6a 10                	push   $0x10
f0100a30:	68 52 6b 10 f0       	push   $0xf0106b52
f0100a35:	e8 98 2f 00 00       	call   f01039d2 <cprintf>
			return 0;
f0100a3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3f:	eb 55                	jmp    f0100a96 <runcmd+0xea>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100a41:	83 ec 04             	sub    $0x4,%esp
f0100a44:	ff 75 0c             	pushl  0xc(%ebp)
f0100a47:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a4a:	50                   	push   %eax
f0100a4b:	56                   	push   %esi
f0100a4c:	ff 97 18 95 12 f0    	call   *-0xfed6ae8(%edi)
f0100a52:	eb 42                	jmp    f0100a96 <runcmd+0xea>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a54:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a59:	83 ec 08             	sub    $0x8,%esp
f0100a5c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a5f:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
f0100a66:	ff b7 10 95 12 f0    	pushl  -0xfed6af0(%edi)
f0100a6c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6f:	e8 75 51 00 00       	call   f0105be9 <strcmp>
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	74 c6                	je     f0100a41 <runcmd+0x95>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a7b:	43                   	inc    %ebx
f0100a7c:	83 fb 01             	cmp    $0x1,%ebx
f0100a7f:	76 d8                	jbe    f0100a59 <runcmd+0xad>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a81:	83 ec 08             	sub    $0x8,%esp
f0100a84:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a87:	68 6f 6b 10 f0       	push   $0xf0106b6f
f0100a8c:	e8 41 2f 00 00       	call   f01039d2 <cprintf>
	return 0;
f0100a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a96:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a99:	5b                   	pop    %ebx
f0100a9a:	5e                   	pop    %esi
f0100a9b:	5f                   	pop    %edi
f0100a9c:	c9                   	leave  
f0100a9d:	c3                   	ret    

f0100a9e <monitor>:

void
monitor(struct Trapframe *tf)
{
f0100a9e:	55                   	push   %ebp
f0100a9f:	89 e5                	mov    %esp,%ebp
f0100aa1:	56                   	push   %esi
f0100aa2:	53                   	push   %ebx
f0100aa3:	8b 75 08             	mov    0x8(%ebp),%esi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100aa6:	83 ec 0c             	sub    $0xc,%esp
f0100aa9:	68 d8 6c 10 f0       	push   $0xf0106cd8
f0100aae:	e8 1f 2f 00 00       	call   f01039d2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ab3:	c7 04 24 fc 6c 10 f0 	movl   $0xf0106cfc,(%esp)
f0100aba:	e8 13 2f 00 00       	call   f01039d2 <cprintf>

	if (tf != NULL)
f0100abf:	83 c4 10             	add    $0x10,%esp
f0100ac2:	85 f6                	test   %esi,%esi
f0100ac4:	74 0c                	je     f0100ad2 <monitor+0x34>
		print_trapframe(tf);
f0100ac6:	83 ec 0c             	sub    $0xc,%esp
f0100ac9:	56                   	push   %esi
f0100aca:	e8 7b 36 00 00       	call   f010414a <print_trapframe>
f0100acf:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ad2:	83 ec 0c             	sub    $0xc,%esp
f0100ad5:	68 85 6b 10 f0       	push   $0xf0106b85
f0100ada:	e8 61 4f 00 00       	call   f0105a40 <readline>
f0100adf:	89 c3                	mov    %eax,%ebx
		if (!strcmp(buf, "exit"))
f0100ae1:	83 c4 08             	add    $0x8,%esp
f0100ae4:	68 89 6b 10 f0       	push   $0xf0106b89
f0100ae9:	50                   	push   %eax
f0100aea:	e8 fa 50 00 00       	call   f0105be9 <strcmp>
f0100aef:	83 c4 10             	add    $0x10,%esp
f0100af2:	85 c0                	test   %eax,%eax
f0100af4:	74 15                	je     f0100b0b <monitor+0x6d>
			break;
		if (buf != NULL)
f0100af6:	85 db                	test   %ebx,%ebx
f0100af8:	74 d8                	je     f0100ad2 <monitor+0x34>
			if (runcmd(buf, tf) < 0)
f0100afa:	83 ec 08             	sub    $0x8,%esp
f0100afd:	56                   	push   %esi
f0100afe:	53                   	push   %ebx
f0100aff:	e8 a8 fe ff ff       	call   f01009ac <runcmd>
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	85 c0                	test   %eax,%eax
f0100b09:	79 c7                	jns    f0100ad2 <monitor+0x34>
				break;
	}
}
f0100b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b0e:	5b                   	pop    %ebx
f0100b0f:	5e                   	pop    %esi
f0100b10:	c9                   	leave  
f0100b11:	c3                   	ret    

f0100b12 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100b12:	55                   	push   %ebp
f0100b13:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100b15:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100b18:	c9                   	leave  
f0100b19:	c3                   	ret    
	...

f0100b1c <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b1c:	55                   	push   %ebp
f0100b1d:	89 e5                	mov    %esp,%ebp
f0100b1f:	56                   	push   %esi
f0100b20:	53                   	push   %ebx
f0100b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b24:	83 ec 0c             	sub    $0xc,%esp
f0100b27:	53                   	push   %ebx
f0100b28:	e8 63 2d 00 00       	call   f0103890 <mc146818_read>
f0100b2d:	89 c6                	mov    %eax,%esi
f0100b2f:	43                   	inc    %ebx
f0100b30:	89 1c 24             	mov    %ebx,(%esp)
f0100b33:	e8 58 2d 00 00       	call   f0103890 <mc146818_read>
f0100b38:	c1 e0 08             	shl    $0x8,%eax
f0100b3b:	09 c6                	or     %eax,%esi
}
f0100b3d:	89 f0                	mov    %esi,%eax
f0100b3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b42:	5b                   	pop    %ebx
f0100b43:	5e                   	pop    %esi
f0100b44:	c9                   	leave  
f0100b45:	c3                   	ret    

f0100b46 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100b46:	55                   	push   %ebp
f0100b47:	89 e5                	mov    %esp,%ebp
f0100b49:	83 ec 14             	sub    $0x14,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	/// Memory from 0x0 to 640K
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100b4c:	6a 15                	push   $0x15
f0100b4e:	e8 c9 ff ff ff       	call   f0100b1c <nvram_read>
f0100b53:	85 c0                	test   %eax,%eax
f0100b55:	79 03                	jns    f0100b5a <i386_detect_memory+0x14>
f0100b57:	83 c0 03             	add    $0x3,%eax
f0100b5a:	c1 f8 02             	sar    $0x2,%eax
f0100b5d:	a3 2c e2 1b f0       	mov    %eax,0xf01be22c
	/// Memory above 1MB: extended memory
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100b62:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100b69:	e8 ae ff ff ff       	call   f0100b1c <nvram_read>
f0100b6e:	89 c2                	mov    %eax,%edx
f0100b70:	85 d2                	test   %edx,%edx
f0100b72:	79 03                	jns    f0100b77 <i386_detect_memory+0x31>
f0100b74:	8d 42 03             	lea    0x3(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100b77:	83 c4 10             	add    $0x10,%esp
f0100b7a:	89 c2                	mov    %eax,%edx
f0100b7c:	c1 fa 02             	sar    $0x2,%edx
f0100b7f:	74 0d                	je     f0100b8e <i386_detect_memory+0x48>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100b81:	8d 82 00 01 00 00    	lea    0x100(%edx),%eax
f0100b87:	a3 e8 ee 1b f0       	mov    %eax,0xf01beee8
f0100b8c:	eb 0a                	jmp    f0100b98 <i386_detect_memory+0x52>
	else
		npages = npages_basemem;
f0100b8e:	a1 2c e2 1b f0       	mov    0xf01be22c,%eax
f0100b93:	a3 e8 ee 1b f0       	mov    %eax,0xf01beee8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100b98:	89 d0                	mov    %edx,%eax
f0100b9a:	c1 e0 0c             	shl    $0xc,%eax
f0100b9d:	c1 e8 0a             	shr    $0xa,%eax
f0100ba0:	50                   	push   %eax
f0100ba1:	a1 2c e2 1b f0       	mov    0xf01be22c,%eax
f0100ba6:	c1 e0 0c             	shl    $0xc,%eax
f0100ba9:	c1 e8 0a             	shr    $0xa,%eax
f0100bac:	50                   	push   %eax
f0100bad:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0100bb2:	c1 e0 0c             	shl    $0xc,%eax
f0100bb5:	c1 e8 0a             	shr    $0xa,%eax
f0100bb8:	50                   	push   %eax
f0100bb9:	68 24 6d 10 f0       	push   $0xf0106d24
f0100bbe:	e8 0f 2e 00 00       	call   f01039d2 <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0100bc3:	c9                   	leave  
f0100bc4:	c3                   	ret    

f0100bc5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bc5:	55                   	push   %ebp
f0100bc6:	89 e5                	mov    %esp,%ebp
f0100bc8:	83 ec 08             	sub    $0x8,%esp
f0100bcb:	8b 55 08             	mov    0x8(%ebp),%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100bce:	83 3d 28 e2 1b f0 00 	cmpl   $0x0,0xf01be228
f0100bd5:	75 0f                	jne    f0100be6 <boot_alloc+0x21>
		extern char end[];   /// the end of kernel in Virtual Addr
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100bd7:	b8 03 10 20 f0       	mov    $0xf0201003,%eax
f0100bdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100be1:	a3 28 e2 1b f0       	mov    %eax,0xf01be228
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100be6:	8b 0d 28 e2 1b f0    	mov    0xf01be228,%ecx
	if (n > 0) {
f0100bec:	85 d2                	test   %edx,%edx
f0100bee:	74 13                	je     f0100c03 <boot_alloc+0x3e>
		int alloc_pages = n / PGSIZE + 1;
f0100bf0:	89 d0                	mov    %edx,%eax
f0100bf2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		nextfree += alloc_pages * PGSIZE;
f0100bf7:	8d 84 08 00 10 00 00 	lea    0x1000(%eax,%ecx,1),%eax
f0100bfe:	a3 28 e2 1b f0       	mov    %eax,0xf01be228
	} 

	extern char end[];
	if ((nextfree - (char *)KERNBASE) > (npages * PGSIZE)) 
f0100c03:	8b 15 28 e2 1b f0    	mov    0xf01be228,%edx
f0100c09:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100c0f:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0100c14:	c1 e0 0c             	shl    $0xc,%eax
f0100c17:	39 c2                	cmp    %eax,%edx
f0100c19:	76 14                	jbe    f0100c2f <boot_alloc+0x6a>
		panic("boot_alloc: out of memory\n");
f0100c1b:	83 ec 04             	sub    $0x4,%esp
f0100c1e:	68 3d 75 10 f0       	push   $0xf010753d
f0100c23:	6a 74                	push   $0x74
f0100c25:	68 58 75 10 f0       	push   $0xf0107558
f0100c2a:	e8 72 f6 ff ff       	call   f01002a1 <_panic>

	return result;
}
f0100c2f:	89 c8                	mov    %ecx,%eax
f0100c31:	c9                   	leave  
f0100c32:	c3                   	ret    

f0100c33 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100c33:	55                   	push   %ebp
f0100c34:	89 e5                	mov    %esp,%ebp
f0100c36:	53                   	push   %ebx
f0100c37:	83 ec 04             	sub    $0x4,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f0100c3a:	e8 07 ff ff ff       	call   f0100b46 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100c3f:	83 ec 0c             	sub    $0xc,%esp
f0100c42:	68 00 10 00 00       	push   $0x1000
f0100c47:	e8 79 ff ff ff       	call   f0100bc5 <boot_alloc>
f0100c4c:	a3 ec ee 1b f0       	mov    %eax,0xf01beeec
	memset(kern_pgdir, 0, PGSIZE);
f0100c51:	83 c4 0c             	add    $0xc,%esp
f0100c54:	68 00 10 00 00       	push   $0x1000
f0100c59:	6a 00                	push   $0x0
f0100c5b:	50                   	push   %eax
f0100c5c:	e8 30 50 00 00       	call   f0105c91 <memset>
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	/// top 10bits as index to kern_pgdir
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100c61:	8b 15 ec ee 1b f0    	mov    0xf01beeec,%edx
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	89 d0                	mov    %edx,%eax
	if ((uint32_t)kva < KERNBASE)
f0100c6c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c72:	77 15                	ja     f0100c89 <mem_init+0x56>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c74:	52                   	push   %edx
f0100c75:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100c7a:	68 9b 00 00 00       	push   $0x9b
f0100c7f:	68 58 75 10 f0       	push   $0xf0107558
f0100c84:	e8 18 f6 ff ff       	call   f01002a1 <_panic>
f0100c89:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100c8e:	83 c8 05             	or     $0x5,%eax
f0100c91:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	unsigned int size_pages = sizeof(struct Page) * npages;
f0100c97:	8b 1d e8 ee 1b f0    	mov    0xf01beee8,%ebx
f0100c9d:	c1 e3 03             	shl    $0x3,%ebx
	pages = boot_alloc(size_pages);
f0100ca0:	83 ec 0c             	sub    $0xc,%esp
f0100ca3:	53                   	push   %ebx
f0100ca4:	e8 1c ff ff ff       	call   f0100bc5 <boot_alloc>
f0100ca9:	a3 f0 ee 1b f0       	mov    %eax,0xf01beef0
	memset(pages, 0, size_pages);
f0100cae:	83 c4 0c             	add    $0xc,%esp
f0100cb1:	53                   	push   %ebx
f0100cb2:	6a 00                	push   $0x0
f0100cb4:	50                   	push   %eax
f0100cb5:	e8 d7 4f 00 00       	call   f0105c91 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	unsigned int size_envs = sizeof(struct Env) * NENV;
	envs = boot_alloc(size_envs);
f0100cba:	c7 04 24 00 f0 01 00 	movl   $0x1f000,(%esp)
f0100cc1:	e8 ff fe ff ff       	call   f0100bc5 <boot_alloc>
f0100cc6:	a3 38 e2 1b f0       	mov    %eax,0xf01be238
	memset(envs, 0, size_envs);	
f0100ccb:	83 c4 0c             	add    $0xc,%esp
f0100cce:	68 00 f0 01 00       	push   $0x1f000
f0100cd3:	6a 00                	push   $0x0
f0100cd5:	50                   	push   %eax
f0100cd6:	e8 b6 4f 00 00       	call   f0105c91 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100cdb:	e8 72 02 00 00       	call   f0100f52 <page_init>

	check_page_free_list(1);
f0100ce0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100ce7:	e8 fe 08 00 00       	call   f01015ea <check_page_free_list>
	check_page_alloc();
f0100cec:	e8 54 0c 00 00       	call   f0101945 <check_page_alloc>
	check_page();
f0100cf1:	e8 b0 14 00 00       	call   f01021a6 <check_page>
f0100cf6:	83 c4 10             	add    $0x10,%esp
f0100cf9:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
	if ((uint32_t)kva < KERNBASE)
f0100cfe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d03:	77 15                	ja     f0100d1a <mem_init+0xe7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d05:	50                   	push   %eax
f0100d06:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100d0b:	68 c5 00 00 00       	push   $0xc5
f0100d10:	68 58 75 10 f0       	push   $0xf0107558
f0100d15:	e8 87 f5 ff ff       	call   f01002a1 <_panic>
f0100d1a:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100d1f:	83 ec 0c             	sub    $0xc,%esp
f0100d22:	6a 03                	push   $0x3
f0100d24:	50                   	push   %eax
f0100d25:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0100d2a:	c1 e0 03             	shl    $0x3,%eax
f0100d2d:	50                   	push   %eax
f0100d2e:	ff 35 f0 ee 1b f0    	pushl  0xf01beef0
f0100d34:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100d3a:	e8 7d 05 00 00       	call   f01012bc <boot_map_region>
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	// (**) PADDR(pages) is correct, I did page2pa(pages) all the time.... damn
	boot_map_region(kern_pgdir, (uintptr_t)pages, sizeof(struct Page)*npages, PADDR(pages), (PTE_W |  PTE_P));	
//	boot_map_region(kern_pgdir, UPAGES, sizeof(struct Page)*npages, PADDR(pages), (PTE_W | PTE_U | PTE_P));
	boot_map_region(kern_pgdir, UPAGES, sizeof(struct Page)*npages, PADDR(pages), (PTE_U | PTE_P));
f0100d3f:	83 c4 20             	add    $0x20,%esp
f0100d42:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
	if ((uint32_t)kva < KERNBASE)
f0100d47:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d4c:	77 15                	ja     f0100d63 <mem_init+0x130>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d4e:	50                   	push   %eax
f0100d4f:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100d54:	68 c7 00 00 00       	push   $0xc7
f0100d59:	68 58 75 10 f0       	push   $0xf0107558
f0100d5e:	e8 3e f5 ff ff       	call   f01002a1 <_panic>
f0100d63:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100d68:	83 ec 0c             	sub    $0xc,%esp
f0100d6b:	6a 05                	push   $0x5
f0100d6d:	50                   	push   %eax
f0100d6e:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0100d73:	c1 e0 03             	shl    $0x3,%eax
f0100d76:	50                   	push   %eax
f0100d77:	68 00 00 00 ef       	push   $0xef000000
f0100d7c:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100d82:	e8 35 05 00 00       	call   f01012bc <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, (uintptr_t)envs, sizeof(struct Env)*NENV, PADDR(envs), (PTE_W | PTE_P));
f0100d87:	83 c4 20             	add    $0x20,%esp
f0100d8a:	a1 38 e2 1b f0       	mov    0xf01be238,%eax
	if ((uint32_t)kva < KERNBASE)
f0100d8f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d94:	77 15                	ja     f0100dab <mem_init+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d96:	50                   	push   %eax
f0100d97:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100d9c:	68 d0 00 00 00       	push   $0xd0
f0100da1:	68 58 75 10 f0       	push   $0xf0107558
f0100da6:	e8 f6 f4 ff ff       	call   f01002a1 <_panic>
f0100dab:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100db0:	83 ec 0c             	sub    $0xc,%esp
f0100db3:	6a 03                	push   $0x3
f0100db5:	50                   	push   %eax
f0100db6:	68 00 f0 01 00       	push   $0x1f000
f0100dbb:	ff 35 38 e2 1b f0    	pushl  0xf01be238
f0100dc1:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100dc7:	e8 f0 04 00 00       	call   f01012bc <boot_map_region>
	boot_map_region(kern_pgdir, UENVS,  sizeof(struct Env)*NENV, PADDR(envs), (PTE_W | PTE_U | PTE_P));
f0100dcc:	83 c4 20             	add    $0x20,%esp
f0100dcf:	a1 38 e2 1b f0       	mov    0xf01be238,%eax
	if ((uint32_t)kva < KERNBASE)
f0100dd4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100dd9:	77 15                	ja     f0100df0 <mem_init+0x1bd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ddb:	50                   	push   %eax
f0100ddc:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100de1:	68 d1 00 00 00       	push   $0xd1
f0100de6:	68 58 75 10 f0       	push   $0xf0107558
f0100deb:	e8 b1 f4 ff ff       	call   f01002a1 <_panic>
f0100df0:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100df5:	83 ec 0c             	sub    $0xc,%esp
f0100df8:	6a 07                	push   $0x7
f0100dfa:	50                   	push   %eax
f0100dfb:	68 00 f0 01 00       	push   $0x1f000
f0100e00:	68 00 00 c0 ee       	push   $0xeec00000
f0100e05:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100e0b:	e8 ac 04 00 00       	call   f01012bc <boot_map_region>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstacktop), (PTE_W | PTE_P));
f0100e10:	83 c4 20             	add    $0x20,%esp
f0100e13:	b8 00 70 12 f0       	mov    $0xf0127000,%eax
	if ((uint32_t)kva < KERNBASE)
f0100e18:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e1d:	77 15                	ja     f0100e34 <mem_init+0x201>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e1f:	50                   	push   %eax
f0100e20:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100e25:	68 de 00 00 00       	push   $0xde
f0100e2a:	68 58 75 10 f0       	push   $0xf0107558
f0100e2f:	e8 6d f4 ff ff       	call   f01002a1 <_panic>
f0100e34:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100e39:	83 ec 0c             	sub    $0xc,%esp
f0100e3c:	6a 03                	push   $0x3
f0100e3e:	50                   	push   %eax
f0100e3f:	68 00 80 00 00       	push   $0x8000
f0100e44:	68 00 80 bf ef       	push   $0xefbf8000
f0100e49:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100e4f:	e8 68 04 00 00       	call   f01012bc <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0x0, (PTE_W | PTE_P));
f0100e54:	83 c4 14             	add    $0x14,%esp
f0100e57:	6a 03                	push   $0x3
f0100e59:	6a 00                	push   $0x0
f0100e5b:	68 ff ff ff 0f       	push   $0xfffffff
f0100e60:	68 00 00 00 f0       	push   $0xf0000000
f0100e65:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100e6b:	e8 4c 04 00 00       	call   f01012bc <boot_map_region>
	
	// Initialize the SMP-related parts of the memory map
	mem_init_mp();  
f0100e70:	83 c4 20             	add    $0x20,%esp
f0100e73:	e8 53 00 00 00       	call   f0100ecb <mem_init_mp>

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
f0100e78:	e8 6a 0f 00 00       	call   f0101de7 <check_kern_pgdir>
f0100e7d:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
	if ((uint32_t)kva < KERNBASE)
f0100e82:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e87:	77 15                	ja     f0100e9e <mem_init+0x26b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e89:	50                   	push   %eax
f0100e8a:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100e8f:	68 f7 00 00 00       	push   $0xf7
f0100e94:	68 58 75 10 f0       	push   $0xf0107558
f0100e99:	e8 03 f4 ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100e9e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100ea3:	0f 22 d8             	mov    %eax,%cr3
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));

	check_page_free_list(0);
f0100ea6:	83 ec 0c             	sub    $0xc,%esp
f0100ea9:	6a 00                	push   $0x0
f0100eab:	e8 3a 07 00 00       	call   f01015ea <check_page_free_list>
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
}

static __inline uint32_t
rcr0(void)
{
f0100eb0:	83 c4 10             	add    $0x10,%esp
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0100eb3:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0100eb6:	0d 23 00 05 80       	or     $0x80050023,%eax
	__asm __volatile("ltr %0" : : "r" (sel));
}

static __inline void
lcr0(uint32_t val)
{
f0100ebb:	83 e0 f3             	and    $0xfffffff3,%eax
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0100ebe:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0100ec1:	e8 c5 1d 00 00       	call   f0102c8b <check_page_installed_pgdir>
}
f0100ec6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ec9:	c9                   	leave  
f0100eca:	c3                   	ret    

f0100ecb <mem_init_mp>:
//   - Map the per-CPU stacks in the region [KSTACKTOP-PTSIZE, KSTACKTOP)
// See the revised inc/memlayout.h
//
static void
mem_init_mp(void)
{
f0100ecb:	55                   	push   %ebp
f0100ecc:	89 e5                	mov    %esp,%ebp
f0100ece:	53                   	push   %ebx
f0100ecf:	83 ec 10             	sub    $0x10,%esp
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0100ed2:	6a 02                	push   $0x2
f0100ed4:	68 00 00 00 fe       	push   $0xfe000000
f0100ed9:	68 00 00 00 02       	push   $0x2000000
f0100ede:	68 00 00 00 fe       	push   $0xfe000000
f0100ee3:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100ee9:	e8 ce 03 00 00       	call   f01012bc <boot_map_region>
	// LAB 4: Your code here:
	/// percpu_kstacks[i] points to the bottom of stack. I thought this was the top of stack 
	/// it took so much time to notice this
	int i;

	for (i = 0; i < NCPU; i++) {	
f0100eee:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ef3:	83 c4 20             	add    $0x20,%esp
f0100ef6:	89 d8                	mov    %ebx,%eax
f0100ef8:	c1 e0 0f             	shl    $0xf,%eax
f0100efb:	05 00 00 1c f0       	add    $0xf01c0000,%eax
	if ((uint32_t)kva < KERNBASE)
f0100f00:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f05:	77 15                	ja     f0100f1c <mem_init_mp+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f07:	50                   	push   %eax
f0100f08:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0100f0d:	68 28 01 00 00       	push   $0x128
f0100f12:	68 58 75 10 f0       	push   $0xf0107558
f0100f17:	e8 85 f3 ff ff       	call   f01002a1 <_panic>
f0100f1c:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100f21:	83 ec 0c             	sub    $0xc,%esp
f0100f24:	6a 03                	push   $0x3
f0100f26:	50                   	push   %eax
f0100f27:	68 00 80 00 00       	push   $0x8000
f0100f2c:	89 d8                	mov    %ebx,%eax
f0100f2e:	c1 e0 10             	shl    $0x10,%eax
f0100f31:	f7 d8                	neg    %eax
f0100f33:	2d 00 80 40 10       	sub    $0x10408000,%eax
f0100f38:	50                   	push   %eax
f0100f39:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0100f3f:	e8 78 03 00 00       	call   f01012bc <boot_map_region>
f0100f44:	83 c4 20             	add    $0x20,%esp
f0100f47:	43                   	inc    %ebx
f0100f48:	83 fb 07             	cmp    $0x7,%ebx
f0100f4b:	7e a9                	jle    f0100ef6 <mem_init_mp+0x2b>
		boot_map_region(kern_pgdir, KSTACKTOP - (i+1)*(KSTKSIZE+KSTKGAP)+KSTKGAP,
				KSTKSIZE, (physaddr_t)PADDR(percpu_kstacks[i]), (PTE_W | PTE_P));
	}	

}
f0100f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f50:	c9                   	leave  
f0100f51:	c3                   	ret    

f0100f52 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f52:	55                   	push   %ebp
f0100f53:	89 e5                	mov    %esp,%ebp
f0100f55:	56                   	push   %esi
f0100f56:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	char *nextfree_page = boot_alloc(0);
f0100f57:	83 ec 0c             	sub    $0xc,%esp
f0100f5a:	6a 00                	push   $0x0
f0100f5c:	e8 64 fc ff ff       	call   f0100bc5 <boot_alloc>
	unsigned int num_page_used = (nextfree_page - (char *)KERNBASE) / PGSIZE;
f0100f61:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0100f67:	89 da                	mov    %ebx,%edx
f0100f69:	85 db                	test   %ebx,%ebx
f0100f6b:	79 06                	jns    f0100f73 <page_init+0x21>
f0100f6d:	8d 90 ff 0f 00 10    	lea    0x10000fff(%eax),%edx
f0100f73:	89 d3                	mov    %edx,%ebx
f0100f75:	c1 fb 0c             	sar    $0xc,%ebx

	// Lab4 
	unsigned int index_mpentry_paddr = MPENTRY_PADDR / PGSIZE;
f0100f78:	be 07 00 00 00       	mov    $0x7,%esi

	for (i = 0; i < npages; i++) {
f0100f7d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f82:	83 c4 10             	add    $0x10,%esp
f0100f85:	3b 0d e8 ee 1b f0    	cmp    0xf01beee8,%ecx
f0100f8b:	0f 83 e3 00 00 00    	jae    f0101074 <page_init+0x122>
		if (i < num_page_used) {
f0100f91:	39 d9                	cmp    %ebx,%ecx
f0100f93:	73 7b                	jae    f0101010 <page_init+0xbe>
			if (i > 0 && i < npages_basemem && (i != index_mpentry_paddr)) {
f0100f95:	85 c9                	test   %ecx,%ecx
f0100f97:	74 69                	je     f0101002 <page_init+0xb0>
f0100f99:	3b 0d 2c e2 1b f0    	cmp    0xf01be22c,%ecx
f0100f9f:	73 61                	jae    f0101002 <page_init+0xb0>
f0100fa1:	39 f1                	cmp    %esi,%ecx
f0100fa3:	74 5d                	je     f0101002 <page_init+0xb0>
				pages[i].pp_ref = 0;
f0100fa5:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0100faa:	66 c7 44 c8 04 00 00 	movw   $0x0,0x4(%eax,%ecx,8)
				if (page_free_list == NULL) {
f0100fb1:	83 3d 30 e2 1b f0 00 	cmpl   $0x0,0xf01be230
f0100fb8:	75 2d                	jne    f0100fe7 <page_init+0x95>
					pages[i].pp_link = NULL;
f0100fba:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0100fbf:	c7 04 c8 00 00 00 00 	movl   $0x0,(%eax,%ecx,8)
					page_free_list = &pages[i];
f0100fc6:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0100fcb:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
f0100fce:	a3 30 e2 1b f0       	mov    %eax,0xf01be230
f0100fd3:	e9 8f 00 00 00       	jmp    f0101067 <page_init+0x115>
				} else {
					pages[i].pp_link = NULL;
					struct Page *page = page_free_list;
					while (1) {
						if (page->pp_link == NULL) {
							page->pp_link = &pages[i];
f0100fd8:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0100fdd:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
f0100fe0:	89 02                	mov    %eax,(%edx)
							break;
f0100fe2:	e9 80 00 00 00       	jmp    f0101067 <page_init+0x115>
				pages[i].pp_ref = 0;
				if (page_free_list == NULL) {
					pages[i].pp_link = NULL;
					page_free_list = &pages[i];
				} else {
					pages[i].pp_link = NULL;
f0100fe7:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0100fec:	c7 04 c8 00 00 00 00 	movl   $0x0,(%eax,%ecx,8)
					struct Page *page = page_free_list;
f0100ff3:	8b 15 30 e2 1b f0    	mov    0xf01be230,%edx
					while (1) {
						if (page->pp_link == NULL) {
f0100ff9:	83 3a 00             	cmpl   $0x0,(%edx)
f0100ffc:	74 da                	je     f0100fd8 <page_init+0x86>
							page->pp_link = &pages[i];
							break;
						}
						page = page->pp_link;
f0100ffe:	8b 12                	mov    (%edx),%edx
f0101000:	eb f7                	jmp    f0100ff9 <page_init+0xa7>
					}
				}
			} else { 	
				 // paged allocated by boot_alloc does not have valid reference count field
				pages[i].pp_ref = 1;        // used 
f0101002:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0101007:	66 c7 44 c8 04 01 00 	movw   $0x1,0x4(%eax,%ecx,8)
f010100e:	eb 57                	jmp    f0101067 <page_init+0x115>
			}
		} else {
			pages[i].pp_ref = 0;
f0101010:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0101015:	66 c7 44 c8 04 00 00 	movw   $0x0,0x4(%eax,%ecx,8)
			if (page_free_list == NULL) {
f010101c:	83 3d 30 e2 1b f0 00 	cmpl   $0x0,0xf01be230
f0101023:	75 27                	jne    f010104c <page_init+0xfa>
				pages[i].pp_link = NULL;
f0101025:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f010102a:	c7 04 c8 00 00 00 00 	movl   $0x0,(%eax,%ecx,8)
				page_free_list = &pages[i];
f0101031:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0101036:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
f0101039:	a3 30 e2 1b f0       	mov    %eax,0xf01be230
f010103e:	eb 27                	jmp    f0101067 <page_init+0x115>
			} else {
				pages[i].pp_link = NULL;
				struct Page *page = page_free_list;
				while (1) {
					if (page->pp_link == NULL) {
						page->pp_link = &pages[i];
f0101040:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0101045:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
f0101048:	89 02                	mov    %eax,(%edx)
						break;
f010104a:	eb 1b                	jmp    f0101067 <page_init+0x115>
			pages[i].pp_ref = 0;
			if (page_free_list == NULL) {
				pages[i].pp_link = NULL;
				page_free_list = &pages[i];
			} else {
				pages[i].pp_link = NULL;
f010104c:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0101051:	c7 04 c8 00 00 00 00 	movl   $0x0,(%eax,%ecx,8)
				struct Page *page = page_free_list;
f0101058:	8b 15 30 e2 1b f0    	mov    0xf01be230,%edx
				while (1) {
					if (page->pp_link == NULL) {
f010105e:	83 3a 00             	cmpl   $0x0,(%edx)
f0101061:	74 dd                	je     f0101040 <page_init+0xee>
						page->pp_link = &pages[i];
						break;
					}
					page = page->pp_link;
f0101063:	8b 12                	mov    (%edx),%edx
f0101065:	eb f7                	jmp    f010105e <page_init+0x10c>
	unsigned int num_page_used = (nextfree_page - (char *)KERNBASE) / PGSIZE;

	// Lab4 
	unsigned int index_mpentry_paddr = MPENTRY_PADDR / PGSIZE;

	for (i = 0; i < npages; i++) {
f0101067:	41                   	inc    %ecx
f0101068:	3b 0d e8 ee 1b f0    	cmp    0xf01beee8,%ecx
f010106e:	0f 82 1d ff ff ff    	jb     f0100f91 <page_init+0x3f>
					page = page->pp_link;
				}	
			}
		}
	}
}
f0101074:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101077:	5b                   	pop    %ebx
f0101078:	5e                   	pop    %esi
f0101079:	c9                   	leave  
f010107a:	c3                   	ret    

f010107b <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f010107b:	55                   	push   %ebp
f010107c:	89 e5                	mov    %esp,%ebp
f010107e:	53                   	push   %ebx
f010107f:	83 ec 04             	sub    $0x4,%esp
//		}	


		return allocating_page;
	} else {
		return NULL;
f0101082:	b8 00 00 00 00       	mov    $0x0,%eax
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if (page_free_list != NULL) {
f0101087:	83 3d 30 e2 1b f0 00 	cmpl   $0x0,0xf01be230
f010108e:	74 63                	je     f01010f3 <page_alloc+0x78>
		struct Page *allocating_page = page_free_list;
f0101090:	8b 1d 30 e2 1b f0    	mov    0xf01be230,%ebx
		page_free_list = page_free_list->pp_link;
f0101096:	8b 03                	mov    (%ebx),%eax
f0101098:	a3 30 e2 1b f0       	mov    %eax,0xf01be230
		allocating_page->pp_link = NULL;
f010109d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO) 
f01010a3:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010a7:	74 48                	je     f01010f1 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01010a9:	89 d8                	mov    %ebx,%eax
f01010ab:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f01010b1:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01010b4:	89 c2                	mov    %eax,%edx
f01010b6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010b9:	89 d0                	mov    %edx,%eax
f01010bb:	c1 e8 0c             	shr    $0xc,%eax
f01010be:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f01010c4:	72 12                	jb     f01010d8 <page_alloc+0x5d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c6:	52                   	push   %edx
f01010c7:	68 58 6a 10 f0       	push   $0xf0106a58
f01010cc:	6a 56                	push   $0x56
f01010ce:	68 64 75 10 f0       	push   $0xf0107564
f01010d3:	e8 c9 f1 ff ff       	call   f01002a1 <_panic>
f01010d8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f01010de:	83 ec 04             	sub    $0x4,%esp
f01010e1:	68 00 10 00 00       	push   $0x1000
f01010e6:	6a 00                	push   $0x0
f01010e8:	50                   	push   %eax
f01010e9:	e8 a3 4b 00 00       	call   f0105c91 <memset>
f01010ee:	83 c4 10             	add    $0x10,%esp
//		else {                                          
//			memset(page2kva(allocating_page), 0, PGSIZE);   //TODO: irrelevant?
//		}	


		return allocating_page;
f01010f1:	89 d8                	mov    %ebx,%eax
	} else {
		return NULL;
	}
}
f01010f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010f6:	c9                   	leave  
f01010f7:	c3                   	ret    

f01010f8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f01010f8:	55                   	push   %ebp
f01010f9:	89 e5                	mov    %esp,%ebp
f01010fb:	83 ec 08             	sub    $0x8,%esp
f01010fe:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	if (pp->pp_ref <= 1) {
f0101101:	66 83 7a 04 01       	cmpw   $0x1,0x4(%edx)
f0101106:	77 5b                	ja     f0101163 <page_free+0x6b>
		pp->pp_link = page_free_list;
f0101108:	a1 30 e2 1b f0       	mov    0xf01be230,%eax
f010110d:	89 02                	mov    %eax,(%edx)
		page_free_list = pp;
f010110f:	89 15 30 e2 1b f0    	mov    %edx,0xf01be230
		pp->pp_ref = 0;
f0101115:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010111b:	89 d0                	mov    %edx,%eax
f010111d:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101123:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101126:	89 c2                	mov    %eax,%edx
f0101128:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010112b:	89 d0                	mov    %edx,%eax
f010112d:	c1 e8 0c             	shr    $0xc,%eax
f0101130:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0101136:	72 12                	jb     f010114a <page_free+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101138:	52                   	push   %edx
f0101139:	68 58 6a 10 f0       	push   $0xf0106a58
f010113e:	6a 56                	push   $0x56
f0101140:	68 64 75 10 f0       	push   $0xf0107564
f0101145:	e8 57 f1 ff ff       	call   f01002a1 <_panic>
f010114a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101150:	83 ec 04             	sub    $0x4,%esp
f0101153:	68 00 10 00 00       	push   $0x1000
f0101158:	6a 00                	push   $0x0
f010115a:	50                   	push   %eax
f010115b:	e8 31 4b 00 00       	call   f0105c91 <memset>
f0101160:	83 c4 10             	add    $0x10,%esp
		memset(page2kva(pp), 0, PGSIZE);
	}	
}
f0101163:	c9                   	leave  
f0101164:	c3                   	ret    

f0101165 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101165:	55                   	push   %ebp
f0101166:	89 e5                	mov    %esp,%ebp
f0101168:	83 ec 08             	sub    $0x8,%esp
f010116b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010116e:	66 ff 48 04          	decw   0x4(%eax)
f0101172:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101177:	75 0c                	jne    f0101185 <page_decref+0x20>
		page_free(pp);
f0101179:	83 ec 0c             	sub    $0xc,%esp
f010117c:	50                   	push   %eax
f010117d:	e8 76 ff ff ff       	call   f01010f8 <page_free>
f0101182:	83 c4 10             	add    $0x10,%esp
}
f0101185:	c9                   	leave  
f0101186:	c3                   	ret    

f0101187 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101187:	55                   	push   %ebp
f0101188:	89 e5                	mov    %esp,%ebp
f010118a:	57                   	push   %edi
f010118b:	56                   	push   %esi
f010118c:	53                   	push   %ebx
f010118d:	83 ec 0c             	sub    $0xc,%esp
f0101190:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101193:	8b 75 0c             	mov    0xc(%ebp),%esi
//	pgdir[PDX(va)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // ToDo: delete

	// Fill this function in
	pde_t *page_dir_entry = &pgdir[PDX(va)];
f0101196:	89 f0                	mov    %esi,%eax
f0101198:	c1 e8 16             	shr    $0x16,%eax
f010119b:	8d 04 87             	lea    (%edi,%eax,4),%eax
	if (!(*page_dir_entry)) {
f010119e:	83 38 00             	cmpl   $0x0,(%eax)
f01011a1:	0f 85 d2 00 00 00    	jne    f0101279 <pgdir_walk+0xf2>
		if (!create) { 
			return NULL;
f01011a7:	b8 00 00 00 00       	mov    $0x0,%eax
//	pgdir[PDX(va)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // ToDo: delete

	// Fill this function in
	pde_t *page_dir_entry = &pgdir[PDX(va)];
	if (!(*page_dir_entry)) {
		if (!create) { 
f01011ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011b0:	0f 84 fe 00 00 00    	je     f01012b4 <pgdir_walk+0x12d>
			return NULL;
		} else {
			struct Page *newpage_table = page_alloc(0); 
f01011b6:	83 ec 0c             	sub    $0xc,%esp
f01011b9:	6a 00                	push   $0x0
f01011bb:	e8 bb fe ff ff       	call   f010107b <page_alloc>
f01011c0:	89 c3                	mov    %eax,%ebx
			if (newpage_table == NULL)  // page_alloc failed
f01011c2:	83 c4 10             	add    $0x10,%esp
				return NULL;
f01011c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(*page_dir_entry)) {
		if (!create) { 
			return NULL;
		} else {
			struct Page *newpage_table = page_alloc(0); 
			if (newpage_table == NULL)  // page_alloc failed
f01011ca:	85 db                	test   %ebx,%ebx
f01011cc:	0f 84 e2 00 00 00    	je     f01012b4 <pgdir_walk+0x12d>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01011d2:	89 d8                	mov    %ebx,%eax
f01011d4:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f01011da:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01011dd:	89 c2                	mov    %eax,%edx
f01011df:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011e2:	89 d0                	mov    %edx,%eax
f01011e4:	c1 e8 0c             	shr    $0xc,%eax
f01011e7:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f01011ed:	72 12                	jb     f0101201 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ef:	52                   	push   %edx
f01011f0:	68 58 6a 10 f0       	push   $0xf0106a58
f01011f5:	6a 56                	push   $0x56
f01011f7:	68 64 75 10 f0       	push   $0xf0107564
f01011fc:	e8 a0 f0 ff ff       	call   f01002a1 <_panic>
f0101201:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101207:	83 ec 04             	sub    $0x4,%esp
f010120a:	68 00 10 00 00       	push   $0x1000
f010120f:	6a 00                	push   $0x0
f0101211:	50                   	push   %eax
f0101212:	e8 7a 4a 00 00       	call   f0105c91 <memset>
				return NULL;
			memset(page2kva(newpage_table), 0, PGSIZE);
			(newpage_table->pp_ref)++;
f0101217:	66 ff 43 04          	incw   0x4(%ebx)
//			pgdir[PDX(va)] = (pde_t)page2pa(newpage_table) | PTE_P;
//			pgdir[PDX(va)] = (pde_t)page2pa(newpage_table) | PTE_U | PTE_P; 
//			pgdir[PDX(va)] = (pde_t)page2pa(newpage_table) | PTE_W | PTE_P; //kernel RW
			pgdir[PDX(va)] = (pde_t)page2pa(newpage_table) | PTE_W | PTE_U | PTE_P; //kernel/user RW
f010121b:	89 f2                	mov    %esi,%edx
f010121d:	c1 ea 16             	shr    $0x16,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101220:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f0101223:	89 d8                	mov    %ebx,%eax
f0101225:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f010122b:	c1 f8 03             	sar    $0x3,%eax
f010122e:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101231:	83 c8 07             	or     $0x7,%eax
f0101234:	89 04 97             	mov    %eax,(%edi,%edx,4)
	return (pp - pages) << PGSHIFT;
f0101237:	89 d8                	mov    %ebx,%eax
f0101239:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f010123f:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101242:	89 c2                	mov    %eax,%edx
f0101244:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101247:	89 d0                	mov    %edx,%eax
f0101249:	c1 e8 0c             	shr    $0xc,%eax
f010124c:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0101252:	72 12                	jb     f0101266 <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101254:	52                   	push   %edx
f0101255:	68 58 6a 10 f0       	push   $0xf0106a58
f010125a:	6a 56                	push   $0x56
f010125c:	68 64 75 10 f0       	push   $0xf0107564
f0101261:	e8 3b f0 ff ff       	call   f01002a1 <_panic>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101266:	89 f0                	mov    %esi,%eax
f0101268:	c1 e8 0a             	shr    $0xa,%eax
f010126b:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101270:	8d 84 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%eax
f0101277:	eb 3b                	jmp    f01012b4 <pgdir_walk+0x12d>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0101279:	8b 10                	mov    (%eax),%edx
f010127b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101281:	89 d0                	mov    %edx,%eax
f0101283:	c1 e8 0c             	shr    $0xc,%eax
f0101286:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f010128c:	72 15                	jb     f01012a3 <pgdir_walk+0x11c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010128e:	52                   	push   %edx
f010128f:	68 58 6a 10 f0       	push   $0xf0106a58
f0101294:	68 ea 01 00 00       	push   $0x1ea
f0101299:	68 58 75 10 f0       	push   $0xf0107558
f010129e:	e8 fe ef ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01012a3:	89 f0                	mov    %esi,%eax
f01012a5:	c1 e8 0a             	shr    $0xa,%eax
f01012a8:	25 fc 0f 00 00       	and    $0xffc,%eax
f01012ad:	8d 84 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%eax
			return &(((pte_t *)(page2kva(newpage_table)))[PTX(va)]);
		}
	}	

	return &((pte_t *)(KADDR(PTE_ADDR(*page_dir_entry))))[PTX(va)];
}
f01012b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012b7:	5b                   	pop    %ebx
f01012b8:	5e                   	pop    %esi
f01012b9:	5f                   	pop    %edi
f01012ba:	c9                   	leave  
f01012bb:	c3                   	ret    

f01012bc <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012bc:	55                   	push   %ebp
f01012bd:	89 e5                	mov    %esp,%ebp
f01012bf:	57                   	push   %edi
f01012c0:	56                   	push   %esi
f01012c1:	53                   	push   %ebx
f01012c2:	83 ec 0c             	sub    $0xc,%esp
f01012c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	uintptr_t va_base = va;
	physaddr_t pa_base = pa;
f01012c8:	8b 75 14             	mov    0x14(%ebp),%esi
	unsigned int offset = 0;
f01012cb:	bb 00 00 00 00       	mov    $0x0,%ebx
	while (offset < size) {
		pte_t *ptbl_entry = pgdir_walk(pgdir, (void *)(va+offset), 1);
		assert(ptbl_entry != NULL);
		*ptbl_entry = (pa_base+offset) | perm | PTE_P;
		offset += PGSIZE;
f01012d0:	39 fb                	cmp    %edi,%ebx
f01012d2:	73 4a                	jae    f010131e <boot_map_region+0x62>
	// Fill this function in
	uintptr_t va_base = va;
	physaddr_t pa_base = pa;
	unsigned int offset = 0;
	while (offset < size) {
		pte_t *ptbl_entry = pgdir_walk(pgdir, (void *)(va+offset), 1);
f01012d4:	83 ec 04             	sub    $0x4,%esp
f01012d7:	6a 01                	push   $0x1
f01012d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012dc:	01 d8                	add    %ebx,%eax
f01012de:	50                   	push   %eax
f01012df:	ff 75 08             	pushl  0x8(%ebp)
f01012e2:	e8 a0 fe ff ff       	call   f0101187 <pgdir_walk>
f01012e7:	89 c2                	mov    %eax,%edx
		assert(ptbl_entry != NULL);
f01012e9:	83 c4 10             	add    $0x10,%esp
f01012ec:	85 c0                	test   %eax,%eax
f01012ee:	75 19                	jne    f0101309 <boot_map_region+0x4d>
f01012f0:	68 72 75 10 f0       	push   $0xf0107572
f01012f5:	68 85 75 10 f0       	push   $0xf0107585
f01012fa:	68 00 02 00 00       	push   $0x200
f01012ff:	68 58 75 10 f0       	push   $0xf0107558
f0101304:	e8 98 ef ff ff       	call   f01002a1 <_panic>
		*ptbl_entry = (pa_base+offset) | perm | PTE_P;
f0101309:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010130c:	0b 45 18             	or     0x18(%ebp),%eax
f010130f:	83 c8 01             	or     $0x1,%eax
f0101312:	89 02                	mov    %eax,(%edx)
		offset += PGSIZE;
f0101314:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010131a:	39 fb                	cmp    %edi,%ebx
f010131c:	72 b6                	jb     f01012d4 <boot_map_region+0x18>
	}
}
f010131e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101321:	5b                   	pop    %ebx
f0101322:	5e                   	pop    %esi
f0101323:	5f                   	pop    %edi
f0101324:	c9                   	leave  
f0101325:	c3                   	ret    

f0101326 <page_insert>:
/* TODO */
// this is copies from MIT_JOS, this works! but not mine..
// compare this with mine!
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101326:	55                   	push   %ebp
f0101327:	89 e5                	mov    %esp,%ebp
f0101329:	57                   	push   %edi
f010132a:	56                   	push   %esi
f010132b:	53                   	push   %ebx
f010132c:	83 ec 0c             	sub    $0xc,%esp
f010132f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	assert(pgdir);
f0101332:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101336:	75 19                	jne    f0101351 <page_insert+0x2b>
f0101338:	68 9a 75 10 f0       	push   $0xf010759a
f010133d:	68 85 75 10 f0       	push   $0xf0107585
f0101342:	68 46 02 00 00       	push   $0x246
f0101347:	68 58 75 10 f0       	push   $0xf0107558
f010134c:	e8 50 ef ff ff       	call   f01002a1 <_panic>
	assert(pp);
f0101351:	85 ff                	test   %edi,%edi
f0101353:	75 19                	jne    f010136e <page_insert+0x48>
f0101355:	68 44 77 10 f0       	push   $0xf0107744
f010135a:	68 85 75 10 f0       	push   $0xf0107585
f010135f:	68 47 02 00 00       	push   $0x247
f0101364:	68 58 75 10 f0       	push   $0xf0107558
f0101369:	e8 33 ef ff ff       	call   f01002a1 <_panic>

	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f010136e:	83 ec 04             	sub    $0x4,%esp
f0101371:	6a 01                	push   $0x1
f0101373:	ff 75 10             	pushl  0x10(%ebp)
f0101376:	ff 75 08             	pushl  0x8(%ebp)
f0101379:	e8 09 fe ff ff       	call   f0101187 <pgdir_walk>
f010137e:	89 c3                	mov    %eax,%ebx
	if (!pte)
f0101380:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0101383:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	assert(pgdir);
	assert(pp);

	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (!pte)
f0101388:	85 db                	test   %ebx,%ebx
f010138a:	74 54                	je     f01013e0 <page_insert+0xba>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010138c:	89 f8                	mov    %edi,%eax
f010138e:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101394:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101397:	89 c6                	mov    %eax,%esi
f0101399:	c1 e6 0c             	shl    $0xc,%esi
		return -E_NO_MEM;

	physaddr_t pa = page2pa(pp);

	// Already exist, remove it!
	if (*pte & PTE_P) {
f010139c:	8b 03                	mov    (%ebx),%eax
f010139e:	a8 01                	test   $0x1,%al
f01013a0:	74 1a                	je     f01013bc <page_insert+0x96>
		// Same map reinsertion, ONLY permission needs change.
		if (PTE_ADDR(*pte) == pa)
f01013a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013a7:	39 f0                	cmp    %esi,%eax
f01013a9:	74 26                	je     f01013d1 <page_insert+0xab>
			goto SUCCESS;

		// Different map insertion, so remove the old one.
		page_remove(pgdir, va);
f01013ab:	83 ec 08             	sub    $0x8,%esp
f01013ae:	ff 75 10             	pushl  0x10(%ebp)
f01013b1:	ff 75 08             	pushl  0x8(%ebp)
f01013b4:	e8 8d 00 00 00       	call   f0101446 <page_remove>
f01013b9:	83 c4 10             	add    $0x10,%esp
	}

	// Add refcount.
	pp->pp_ref++;
f01013bc:	66 ff 47 04          	incw   0x4(%edi)

	// Cached
	tlb_invalidate(pgdir, va);
f01013c0:	83 ec 08             	sub    $0x8,%esp
f01013c3:	ff 75 10             	pushl  0x10(%ebp)
f01013c6:	ff 75 08             	pushl  0x8(%ebp)
f01013c9:	e8 f2 00 00 00       	call   f01014c0 <tlb_invalidate>
f01013ce:	83 c4 10             	add    $0x10,%esp

SUCCESS:
	// Set PTE with new permissions.
	*pte = pa | perm | PTE_P;
f01013d1:	89 f0                	mov    %esi,%eax
f01013d3:	0b 45 14             	or     0x14(%ebp),%eax
f01013d6:	83 c8 01             	or     $0x1,%eax
f01013d9:	89 03                	mov    %eax,(%ebx)

	return 0;
f01013db:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013e3:	5b                   	pop    %ebx
f01013e4:	5e                   	pop    %esi
f01013e5:	5f                   	pop    %edi
f01013e6:	c9                   	leave  
f01013e7:	c3                   	ret    

f01013e8 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01013e8:	55                   	push   %ebp
f01013e9:	89 e5                	mov    %esp,%ebp
f01013eb:	53                   	push   %ebx
f01013ec:	83 ec 08             	sub    $0x8,%esp
f01013ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *entry = pgdir_walk(pgdir, va, 0);
f01013f2:	6a 00                	push   $0x0
f01013f4:	ff 75 0c             	pushl  0xc(%ebp)
f01013f7:	ff 75 08             	pushl  0x8(%ebp)
f01013fa:	e8 88 fd ff ff       	call   f0101187 <pgdir_walk>
f01013ff:	89 c1                	mov    %eax,%ecx
	if (entry == NULL)
f0101401:	83 c4 10             	add    $0x10,%esp
		return NULL;
f0101404:	b8 00 00 00 00       	mov    $0x0,%eax
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *entry = pgdir_walk(pgdir, va, 0);
	if (entry == NULL)
f0101409:	85 c9                	test   %ecx,%ecx
f010140b:	74 34                	je     f0101441 <page_lookup+0x59>
	return (pp - pages) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
f010140d:	8b 11                	mov    (%ecx),%edx
	if (PGNUM(pa) >= npages)
f010140f:	89 d0                	mov    %edx,%eax
f0101411:	c1 e8 0c             	shr    $0xc,%eax
f0101414:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f010141a:	72 14                	jb     f0101430 <page_lookup+0x48>
		panic("pa2page called with invalid pa");
f010141c:	83 ec 04             	sub    $0x4,%esp
f010141f:	68 60 6d 10 f0       	push   $0xf0106d60
f0101424:	6a 4f                	push   $0x4f
f0101426:	68 64 75 10 f0       	push   $0xf0107564
f010142b:	e8 71 ee ff ff       	call   f01002a1 <_panic>
f0101430:	c1 ea 0c             	shr    $0xc,%edx
	return (pp - pages) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
f0101433:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
f0101438:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	struct Page *page = pa2page((physaddr_t)*entry);
	if (pte_store) 
f010143b:	85 db                	test   %ebx,%ebx
f010143d:	74 02                	je     f0101441 <page_lookup+0x59>
		*pte_store = entry;
f010143f:	89 0b                	mov    %ecx,(%ebx)
	return page;
}
f0101441:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101444:	c9                   	leave  
f0101445:	c3                   	ret    

f0101446 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101446:	55                   	push   %ebp
f0101447:	89 e5                	mov    %esp,%ebp
f0101449:	57                   	push   %edi
f010144a:	56                   	push   %esi
f010144b:	53                   	push   %ebx
f010144c:	83 ec 10             	sub    $0x10,%esp
f010144f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101452:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *entry = pgdir_walk(pgdir, va, 0);
f0101455:	6a 00                	push   $0x0
f0101457:	56                   	push   %esi
f0101458:	57                   	push   %edi
f0101459:	e8 29 fd ff ff       	call   f0101187 <pgdir_walk>
f010145e:	89 c3                	mov    %eax,%ebx
	if (!(*entry))  // there is no such entry
f0101460:	83 c4 10             	add    $0x10,%esp
f0101463:	83 38 00             	cmpl   $0x0,(%eax)
f0101466:	74 50                	je     f01014b8 <page_remove+0x72>
		return;

	tlb_invalidate(pgdir, va);
f0101468:	83 ec 08             	sub    $0x8,%esp
f010146b:	56                   	push   %esi
f010146c:	57                   	push   %edi
f010146d:	e8 4e 00 00 00       	call   f01014c0 <tlb_invalidate>
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	8b 13                	mov    (%ebx),%edx
f0101477:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010147d:	89 d0                	mov    %edx,%eax
f010147f:	c1 e8 0c             	shr    $0xc,%eax
f0101482:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0101488:	72 14                	jb     f010149e <page_remove+0x58>
		panic("pa2page called with invalid pa");
f010148a:	83 ec 04             	sub    $0x4,%esp
f010148d:	68 60 6d 10 f0       	push   $0xf0106d60
f0101492:	6a 4f                	push   $0x4f
f0101494:	68 64 75 10 f0       	push   $0xf0107564
f0101499:	e8 03 ee ff ff       	call   f01002a1 <_panic>
f010149e:	89 d0                	mov    %edx,%eax
f01014a0:	c1 e8 09             	shr    $0x9,%eax
f01014a3:	03 05 f0 ee 1b f0    	add    0xf01beef0,%eax
	struct Page *page = pa2page(PTE_ADDR(*entry));

	page_decref(page);
f01014a9:	83 ec 0c             	sub    $0xc,%esp
f01014ac:	50                   	push   %eax
f01014ad:	e8 b3 fc ff ff       	call   f0101165 <page_decref>
	*entry = 0;
f01014b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
f01014b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014bb:	5b                   	pop    %ebx
f01014bc:	5e                   	pop    %esi
f01014bd:	5f                   	pop    %edi
f01014be:	c9                   	leave  
f01014bf:	c3                   	ret    

f01014c0 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01014c0:	55                   	push   %ebp
f01014c1:	89 e5                	mov    %esp,%ebp
f01014c3:	53                   	push   %ebx
f01014c4:	83 ec 04             	sub    $0x4,%esp
f01014c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01014ca:	e8 43 4f 00 00       	call   f0106412 <cpunum>
f01014cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01014d6:	29 c2                	sub    %eax,%edx
f01014d8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01014db:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f01014e2:	00 
f01014e3:	74 20                	je     f0101505 <tlb_invalidate+0x45>
f01014e5:	e8 28 4f 00 00       	call   f0106412 <cpunum>
f01014ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01014f1:	29 c2                	sub    %eax,%edx
f01014f3:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01014f6:	8b 14 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%edx
f01014fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0101500:	39 42 60             	cmp    %eax,0x60(%edx)
f0101503:	75 03                	jne    f0101508 <tlb_invalidate+0x48>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101505:	0f 01 3b             	invlpg (%ebx)
		invlpg(va);
}
f0101508:	83 c4 04             	add    $0x4,%esp
f010150b:	5b                   	pop    %ebx
f010150c:	c9                   	leave  
f010150d:	c3                   	ret    

f010150e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010150e:	55                   	push   %ebp
f010150f:	89 e5                	mov    %esp,%ebp
f0101511:	57                   	push   %edi
f0101512:	56                   	push   %esi
f0101513:	53                   	push   %ebx
f0101514:	83 ec 0c             	sub    $0xc,%esp
f0101517:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// LAB 3: Your code here.
	uintptr_t va_base = ROUNDDOWN((uint32_t)va, PGSIZE);
f010151a:	89 fb                	mov    %edi,%ebx
f010151c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t va_top = ROUNDUP((uint32_t)va+len, PGSIZE); 
f0101522:	89 f8                	mov    %edi,%eax
f0101524:	03 45 10             	add    0x10(%ebp),%eax
f0101527:	05 ff 0f 00 00       	add    $0xfff,%eax
f010152c:	89 c6                	mov    %eax,%esi
f010152e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		}
		if ((PTE_ADDR(*entry) >= ULIM) || (*entry & perm) != perm) {
			user_mem_check_addr = (uint32_t)va;
			return -E_FAULT;
		}
		va_base += PGSIZE;
f0101534:	39 f3                	cmp    %esi,%ebx
f0101536:	73 5b                	jae    f0101593 <user_mem_check+0x85>
	// LAB 3: Your code here.
	uintptr_t va_base = ROUNDDOWN((uint32_t)va, PGSIZE);
	uintptr_t va_top = ROUNDUP((uint32_t)va+len, PGSIZE); 
	while (va_base < va_top) {
		pte_t *entry;
		if (!page_lookup(env->env_pgdir, (void *)va_base, &entry)) {
f0101538:	83 ec 04             	sub    $0x4,%esp
f010153b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010153e:	50                   	push   %eax
f010153f:	53                   	push   %ebx
f0101540:	8b 45 08             	mov    0x8(%ebp),%eax
f0101543:	ff 70 60             	pushl  0x60(%eax)
f0101546:	e8 9d fe ff ff       	call   f01013e8 <page_lookup>
f010154b:	83 c4 10             	add    $0x10,%esp
f010154e:	85 c0                	test   %eax,%eax
f0101550:	75 0d                	jne    f010155f <user_mem_check+0x51>
			user_mem_check_addr = (uint32_t)va;
f0101552:	89 3d 34 e2 1b f0    	mov    %edi,0xf01be234
			return -E_FAULT;
f0101558:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010155d:	eb 39                	jmp    f0101598 <user_mem_check+0x8a>
		}
		if ((PTE_ADDR(*entry) >= ULIM) || (*entry & perm) != perm) {
f010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101562:	8b 10                	mov    (%eax),%edx
f0101564:	89 d0                	mov    %edx,%eax
f0101566:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010156b:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0101570:	77 0a                	ja     f010157c <user_mem_check+0x6e>
f0101572:	8b 45 14             	mov    0x14(%ebp),%eax
f0101575:	21 d0                	and    %edx,%eax
f0101577:	3b 45 14             	cmp    0x14(%ebp),%eax
f010157a:	74 0d                	je     f0101589 <user_mem_check+0x7b>
			user_mem_check_addr = (uint32_t)va;
f010157c:	89 3d 34 e2 1b f0    	mov    %edi,0xf01be234
			return -E_FAULT;
f0101582:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101587:	eb 0f                	jmp    f0101598 <user_mem_check+0x8a>
		}
		va_base += PGSIZE;
f0101589:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010158f:	39 f3                	cmp    %esi,%ebx
f0101591:	72 a5                	jb     f0101538 <user_mem_check+0x2a>
	}

	return 0;
f0101593:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101598:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010159b:	5b                   	pop    %ebx
f010159c:	5e                   	pop    %esi
f010159d:	5f                   	pop    %edi
f010159e:	c9                   	leave  
f010159f:	c3                   	ret    

f01015a0 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01015a0:	55                   	push   %ebp
f01015a1:	89 e5                	mov    %esp,%ebp
f01015a3:	53                   	push   %ebx
f01015a4:	83 ec 04             	sub    $0x4,%esp
f01015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U | PTE_P) < 0) {
f01015aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01015ad:	83 c8 05             	or     $0x5,%eax
f01015b0:	50                   	push   %eax
f01015b1:	ff 75 10             	pushl  0x10(%ebp)
f01015b4:	ff 75 0c             	pushl  0xc(%ebp)
f01015b7:	53                   	push   %ebx
f01015b8:	e8 51 ff ff ff       	call   f010150e <user_mem_check>
f01015bd:	83 c4 10             	add    $0x10,%esp
f01015c0:	85 c0                	test   %eax,%eax
f01015c2:	79 21                	jns    f01015e5 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01015c4:	83 ec 04             	sub    $0x4,%esp
f01015c7:	ff 35 34 e2 1b f0    	pushl  0xf01be234
f01015cd:	ff 73 48             	pushl  0x48(%ebx)
f01015d0:	68 80 6d 10 f0       	push   $0xf0106d80
f01015d5:	e8 f8 23 00 00       	call   f01039d2 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01015da:	89 1c 24             	mov    %ebx,(%esp)
f01015dd:	e8 24 21 00 00       	call   f0103706 <env_destroy>
f01015e2:	83 c4 10             	add    $0x10,%esp
	}
}
f01015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015e8:	c9                   	leave  
f01015e9:	c3                   	ret    

f01015ea <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01015ea:	55                   	push   %ebp
f01015eb:	89 e5                	mov    %esp,%ebp
f01015ed:	57                   	push   %edi
f01015ee:	56                   	push   %esi
f01015ef:	53                   	push   %ebx
f01015f0:	83 ec 1c             	sub    $0x1c,%esp
f01015f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01015f6:	83 f8 01             	cmp    $0x1,%eax
f01015f9:	19 f6                	sbb    %esi,%esi
f01015fb:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101601:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0101602:	bf 00 00 00 00       	mov    $0x0,%edi
f0101607:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	char *first_free_page;

	if (!page_free_list)
f010160e:	83 3d 30 e2 1b f0 00 	cmpl   $0x0,0xf01be230
f0101615:	75 17                	jne    f010162e <check_page_free_list+0x44>
		panic("'page_free_list' is a null pointer!");
f0101617:	83 ec 04             	sub    $0x4,%esp
f010161a:	68 b8 6d 10 f0       	push   $0xf0106db8
f010161f:	68 f7 02 00 00       	push   $0x2f7
f0101624:	68 58 75 10 f0       	push   $0xf0107558
f0101629:	e8 73 ec ff ff       	call   f01002a1 <_panic>

	if (only_low_memory) {
f010162e:	85 c0                	test   %eax,%eax
f0101630:	74 59                	je     f010168b <check_page_free_list+0xa1>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0101632:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101635:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101638:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010163b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010163e:	8b 1d 30 e2 1b f0    	mov    0xf01be230,%ebx
f0101644:	85 db                	test   %ebx,%ebx
f0101646:	74 2a                	je     f0101672 <check_page_free_list+0x88>
f0101648:	8d 4d e0             	lea    -0x20(%ebp),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010164b:	89 d8                	mov    %ebx,%eax
f010164d:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101653:	c1 e0 09             	shl    $0x9,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101656:	c1 e8 16             	shr    $0x16,%eax
f0101659:	39 f0                	cmp    %esi,%eax
f010165b:	0f 93 c0             	setae  %al
f010165e:	0f b6 c0             	movzbl %al,%eax
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
f0101661:	c1 e0 02             	shl    $0x2,%eax
f0101664:	8b 14 08             	mov    (%eax,%ecx,1),%edx
f0101667:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101669:	89 1c 08             	mov    %ebx,(%eax,%ecx,1)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010166c:	8b 1b                	mov    (%ebx),%ebx
f010166e:	85 db                	test   %ebx,%ebx
f0101670:	75 d9                	jne    f010164b <check_page_free_list+0x61>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101675:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010167b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010167e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101681:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101683:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101686:	a3 30 e2 1b f0       	mov    %eax,0xf01be230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010168b:	8b 1d 30 e2 1b f0    	mov    0xf01be230,%ebx
f0101691:	85 db                	test   %ebx,%ebx
f0101693:	74 5a                	je     f01016ef <check_page_free_list+0x105>
	return (pp - pages) << PGSHIFT;
f0101695:	89 d8                	mov    %ebx,%eax
f0101697:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f010169d:	c1 f8 03             	sar    $0x3,%eax
f01016a0:	89 c2                	mov    %eax,%edx
f01016a2:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01016a5:	89 d0                	mov    %edx,%eax
f01016a7:	c1 e8 16             	shr    $0x16,%eax
f01016aa:	39 f0                	cmp    %esi,%eax
f01016ac:	73 3b                	jae    f01016e9 <check_page_free_list+0xff>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016ae:	89 d0                	mov    %edx,%eax
f01016b0:	c1 e8 0c             	shr    $0xc,%eax
f01016b3:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f01016b9:	72 12                	jb     f01016cd <check_page_free_list+0xe3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016bb:	52                   	push   %edx
f01016bc:	68 58 6a 10 f0       	push   $0xf0106a58
f01016c1:	6a 56                	push   $0x56
f01016c3:	68 64 75 10 f0       	push   $0xf0107564
f01016c8:	e8 d4 eb ff ff       	call   f01002a1 <_panic>
f01016cd:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f01016d3:	83 ec 04             	sub    $0x4,%esp
f01016d6:	68 80 00 00 00       	push   $0x80
f01016db:	68 97 00 00 00       	push   $0x97
f01016e0:	50                   	push   %eax
f01016e1:	e8 ab 45 00 00       	call   f0105c91 <memset>
f01016e6:	83 c4 10             	add    $0x10,%esp
f01016e9:	8b 1b                	mov    (%ebx),%ebx
f01016eb:	85 db                	test   %ebx,%ebx
f01016ed:	75 a6                	jne    f0101695 <check_page_free_list+0xab>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01016ef:	83 ec 0c             	sub    $0xc,%esp
f01016f2:	6a 00                	push   $0x0
f01016f4:	e8 cc f4 ff ff       	call   f0100bc5 <boot_alloc>
f01016f9:	89 c1                	mov    %eax,%ecx
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01016fb:	8b 1d 30 e2 1b f0    	mov    0xf01be230,%ebx
f0101701:	83 c4 10             	add    $0x10,%esp
f0101704:	85 db                	test   %ebx,%ebx
f0101706:	0f 84 d0 01 00 00    	je     f01018dc <check_page_free_list+0x2f2>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010170c:	3b 1d f0 ee 1b f0    	cmp    0xf01beef0,%ebx
f0101712:	73 19                	jae    f010172d <check_page_free_list+0x143>
f0101714:	68 a0 75 10 f0       	push   $0xf01075a0
f0101719:	68 85 75 10 f0       	push   $0xf0107585
f010171e:	68 11 03 00 00       	push   $0x311
f0101723:	68 58 75 10 f0       	push   $0xf0107558
f0101728:	e8 74 eb ff ff       	call   f01002a1 <_panic>
		assert(pp < pages + npages);
f010172d:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101732:	8b 15 f0 ee 1b f0    	mov    0xf01beef0,%edx
f0101738:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010173b:	39 d8                	cmp    %ebx,%eax
f010173d:	77 19                	ja     f0101758 <check_page_free_list+0x16e>
f010173f:	68 ac 75 10 f0       	push   $0xf01075ac
f0101744:	68 85 75 10 f0       	push   $0xf0107585
f0101749:	68 12 03 00 00       	push   $0x312
f010174e:	68 58 75 10 f0       	push   $0xf0107558
f0101753:	e8 49 eb ff ff       	call   f01002a1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101758:	89 d8                	mov    %ebx,%eax
f010175a:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101760:	a8 07                	test   $0x7,%al
f0101762:	74 19                	je     f010177d <check_page_free_list+0x193>
f0101764:	68 dc 6d 10 f0       	push   $0xf0106ddc
f0101769:	68 85 75 10 f0       	push   $0xf0107585
f010176e:	68 13 03 00 00       	push   $0x313
f0101773:	68 58 75 10 f0       	push   $0xf0107558
f0101778:	e8 24 eb ff ff       	call   f01002a1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010177d:	89 d8                	mov    %ebx,%eax
f010177f:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101785:	c1 f8 03             	sar    $0x3,%eax
f0101788:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f010178b:	85 c0                	test   %eax,%eax
f010178d:	75 19                	jne    f01017a8 <check_page_free_list+0x1be>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010178f:	68 c0 75 10 f0       	push   $0xf01075c0
f0101794:	68 85 75 10 f0       	push   $0xf0107585
f0101799:	68 16 03 00 00       	push   $0x316
f010179e:	68 58 75 10 f0       	push   $0xf0107558
f01017a3:	e8 f9 ea ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f01017a8:	89 d8                	mov    %ebx,%eax
f01017aa:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f01017b0:	c1 f8 03             	sar    $0x3,%eax
f01017b3:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01017b6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01017bb:	75 19                	jne    f01017d6 <check_page_free_list+0x1ec>
		assert(page2pa(pp) != IOPHYSMEM);
f01017bd:	68 d1 75 10 f0       	push   $0xf01075d1
f01017c2:	68 85 75 10 f0       	push   $0xf0107585
f01017c7:	68 17 03 00 00       	push   $0x317
f01017cc:	68 58 75 10 f0       	push   $0xf0107558
f01017d1:	e8 cb ea ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f01017d6:	89 d8                	mov    %ebx,%eax
f01017d8:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f01017de:	c1 f8 03             	sar    $0x3,%eax
f01017e1:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01017e4:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01017e9:	75 19                	jne    f0101804 <check_page_free_list+0x21a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01017eb:	68 10 6e 10 f0       	push   $0xf0106e10
f01017f0:	68 85 75 10 f0       	push   $0xf0107585
f01017f5:	68 18 03 00 00       	push   $0x318
f01017fa:	68 58 75 10 f0       	push   $0xf0107558
f01017ff:	e8 9d ea ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f0101804:	89 d8                	mov    %ebx,%eax
f0101806:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f010180c:	c1 f8 03             	sar    $0x3,%eax
f010180f:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101812:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101817:	75 19                	jne    f0101832 <check_page_free_list+0x248>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101819:	68 ea 75 10 f0       	push   $0xf01075ea
f010181e:	68 85 75 10 f0       	push   $0xf0107585
f0101823:	68 19 03 00 00       	push   $0x319
f0101828:	68 58 75 10 f0       	push   $0xf0107558
f010182d:	e8 6f ea ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f0101832:	89 d8                	mov    %ebx,%eax
f0101834:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f010183a:	c1 f8 03             	sar    $0x3,%eax
f010183d:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101840:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101845:	76 42                	jbe    f0101889 <check_page_free_list+0x29f>
f0101847:	89 c2                	mov    %eax,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101849:	c1 e8 0c             	shr    $0xc,%eax
f010184c:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0101852:	72 12                	jb     f0101866 <check_page_free_list+0x27c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101854:	52                   	push   %edx
f0101855:	68 58 6a 10 f0       	push   $0xf0106a58
f010185a:	6a 56                	push   $0x56
f010185c:	68 64 75 10 f0       	push   $0xf0107564
f0101861:	e8 3b ea ff ff       	call   f01002a1 <_panic>
f0101866:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f010186c:	39 c8                	cmp    %ecx,%eax
f010186e:	73 19                	jae    f0101889 <check_page_free_list+0x29f>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101870:	68 34 6e 10 f0       	push   $0xf0106e34
f0101875:	68 85 75 10 f0       	push   $0xf0107585
f010187a:	68 1a 03 00 00       	push   $0x31a
f010187f:	68 58 75 10 f0       	push   $0xf0107558
f0101884:	e8 18 ea ff ff       	call   f01002a1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101889:	89 d8                	mov    %ebx,%eax
f010188b:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101891:	c1 f8 03             	sar    $0x3,%eax
f0101894:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101897:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010189c:	75 19                	jne    f01018b7 <check_page_free_list+0x2cd>

		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010189e:	68 04 76 10 f0       	push   $0xf0107604
f01018a3:	68 85 75 10 f0       	push   $0xf0107585
f01018a8:	68 1d 03 00 00       	push   $0x31d
f01018ad:	68 58 75 10 f0       	push   $0xf0107558
f01018b2:	e8 ea e9 ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f01018b7:	89 d8                	mov    %ebx,%eax
f01018b9:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f01018bf:	c1 f8 03             	sar    $0x3,%eax
f01018c2:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01018c5:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01018ca:	77 03                	ja     f01018cf <check_page_free_list+0x2e5>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01018cc:	47                   	inc    %edi
f01018cd:	eb 03                	jmp    f01018d2 <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f01018cf:	ff 45 d8             	incl   -0x28(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01018d2:	8b 1b                	mov    (%ebx),%ebx
f01018d4:	85 db                	test   %ebx,%ebx
f01018d6:	0f 85 30 fe ff ff    	jne    f010170c <check_page_free_list+0x122>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01018dc:	85 ff                	test   %edi,%edi
f01018de:	7f 19                	jg     f01018f9 <check_page_free_list+0x30f>
f01018e0:	68 21 76 10 f0       	push   $0xf0107621
f01018e5:	68 85 75 10 f0       	push   $0xf0107585
f01018ea:	68 25 03 00 00       	push   $0x325
f01018ef:	68 58 75 10 f0       	push   $0xf0107558
f01018f4:	e8 a8 e9 ff ff       	call   f01002a1 <_panic>
	assert(nfree_extmem > 0);
f01018f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01018fd:	7f 19                	jg     f0101918 <check_page_free_list+0x32e>
f01018ff:	68 33 76 10 f0       	push   $0xf0107633
f0101904:	68 85 75 10 f0       	push   $0xf0107585
f0101909:	68 26 03 00 00       	push   $0x326
f010190e:	68 58 75 10 f0       	push   $0xf0107558
f0101913:	e8 89 e9 ff ff       	call   f01002a1 <_panic>

	cprintf("************************************\n");
f0101918:	83 ec 0c             	sub    $0xc,%esp
f010191b:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0101920:	e8 ad 20 00 00       	call   f01039d2 <cprintf>
	cprintf("**check_page_freelist() succeeded!**\n");
f0101925:	c7 04 24 a4 6e 10 f0 	movl   $0xf0106ea4,(%esp)
f010192c:	e8 a1 20 00 00       	call   f01039d2 <cprintf>
	cprintf("************************************\n\n");
f0101931:	c7 04 24 cc 6e 10 f0 	movl   $0xf0106ecc,(%esp)
f0101938:	e8 95 20 00 00       	call   f01039d2 <cprintf>
}
f010193d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101940:	5b                   	pop    %ebx
f0101941:	5e                   	pop    %esi
f0101942:	5f                   	pop    %edi
f0101943:	c9                   	leave  
f0101944:	c3                   	ret    

f0101945 <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
f0101945:	55                   	push   %ebp
f0101946:	89 e5                	mov    %esp,%ebp
f0101948:	57                   	push   %edi
f0101949:	56                   	push   %esi
f010194a:	53                   	push   %ebx
f010194b:	83 ec 0c             	sub    $0xc,%esp
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f010194e:	83 3d f0 ee 1b f0 00 	cmpl   $0x0,0xf01beef0
f0101955:	75 17                	jne    f010196e <check_page_alloc+0x29>
		panic("'pages' is a null pointer!");
f0101957:	83 ec 04             	sub    $0x4,%esp
f010195a:	68 44 76 10 f0       	push   $0xf0107644
f010195f:	68 3b 03 00 00       	push   $0x33b
f0101964:	68 58 75 10 f0       	push   $0xf0107558
f0101969:	e8 33 e9 ff ff       	call   f01002a1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010196e:	a1 30 e2 1b f0       	mov    0xf01be230,%eax
f0101973:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010197a:	85 c0                	test   %eax,%eax
f010197c:	74 09                	je     f0101987 <check_page_alloc+0x42>
		++nfree;
f010197e:	ff 45 f0             	incl   -0x10(%ebp)

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101981:	8b 00                	mov    (%eax),%eax
f0101983:	85 c0                	test   %eax,%eax
f0101985:	75 f7                	jne    f010197e <check_page_alloc+0x39>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101987:	83 ec 0c             	sub    $0xc,%esp
f010198a:	6a 00                	push   $0x0
f010198c:	e8 ea f6 ff ff       	call   f010107b <page_alloc>
f0101991:	89 c3                	mov    %eax,%ebx
f0101993:	83 c4 10             	add    $0x10,%esp
f0101996:	85 c0                	test   %eax,%eax
f0101998:	75 19                	jne    f01019b3 <check_page_alloc+0x6e>
f010199a:	68 5f 76 10 f0       	push   $0xf010765f
f010199f:	68 85 75 10 f0       	push   $0xf0107585
f01019a4:	68 43 03 00 00       	push   $0x343
f01019a9:	68 58 75 10 f0       	push   $0xf0107558
f01019ae:	e8 ee e8 ff ff       	call   f01002a1 <_panic>
	assert((pp1 = page_alloc(0)));
f01019b3:	83 ec 0c             	sub    $0xc,%esp
f01019b6:	6a 00                	push   $0x0
f01019b8:	e8 be f6 ff ff       	call   f010107b <page_alloc>
f01019bd:	89 c6                	mov    %eax,%esi
f01019bf:	83 c4 10             	add    $0x10,%esp
f01019c2:	85 c0                	test   %eax,%eax
f01019c4:	75 19                	jne    f01019df <check_page_alloc+0x9a>
f01019c6:	68 75 76 10 f0       	push   $0xf0107675
f01019cb:	68 85 75 10 f0       	push   $0xf0107585
f01019d0:	68 44 03 00 00       	push   $0x344
f01019d5:	68 58 75 10 f0       	push   $0xf0107558
f01019da:	e8 c2 e8 ff ff       	call   f01002a1 <_panic>
	assert((pp2 = page_alloc(0)));
f01019df:	83 ec 0c             	sub    $0xc,%esp
f01019e2:	6a 00                	push   $0x0
f01019e4:	e8 92 f6 ff ff       	call   f010107b <page_alloc>
f01019e9:	89 c7                	mov    %eax,%edi
f01019eb:	83 c4 10             	add    $0x10,%esp
f01019ee:	85 c0                	test   %eax,%eax
f01019f0:	75 19                	jne    f0101a0b <check_page_alloc+0xc6>
f01019f2:	68 8b 76 10 f0       	push   $0xf010768b
f01019f7:	68 85 75 10 f0       	push   $0xf0107585
f01019fc:	68 45 03 00 00       	push   $0x345
f0101a01:	68 58 75 10 f0       	push   $0xf0107558
f0101a06:	e8 96 e8 ff ff       	call   f01002a1 <_panic>

	assert(pp0);
f0101a0b:	85 db                	test   %ebx,%ebx
f0101a0d:	75 19                	jne    f0101a28 <check_page_alloc+0xe3>
f0101a0f:	68 af 76 10 f0       	push   $0xf01076af
f0101a14:	68 85 75 10 f0       	push   $0xf0107585
f0101a19:	68 47 03 00 00       	push   $0x347
f0101a1e:	68 58 75 10 f0       	push   $0xf0107558
f0101a23:	e8 79 e8 ff ff       	call   f01002a1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a28:	85 f6                	test   %esi,%esi
f0101a2a:	74 04                	je     f0101a30 <check_page_alloc+0xeb>
f0101a2c:	39 de                	cmp    %ebx,%esi
f0101a2e:	75 19                	jne    f0101a49 <check_page_alloc+0x104>
f0101a30:	68 a1 76 10 f0       	push   $0xf01076a1
f0101a35:	68 85 75 10 f0       	push   $0xf0107585
f0101a3a:	68 48 03 00 00       	push   $0x348
f0101a3f:	68 58 75 10 f0       	push   $0xf0107558
f0101a44:	e8 58 e8 ff ff       	call   f01002a1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a49:	85 c0                	test   %eax,%eax
f0101a4b:	74 08                	je     f0101a55 <check_page_alloc+0x110>
f0101a4d:	39 f0                	cmp    %esi,%eax
f0101a4f:	74 04                	je     f0101a55 <check_page_alloc+0x110>
f0101a51:	39 d8                	cmp    %ebx,%eax
f0101a53:	75 19                	jne    f0101a6e <check_page_alloc+0x129>
f0101a55:	68 f4 6e 10 f0       	push   $0xf0106ef4
f0101a5a:	68 85 75 10 f0       	push   $0xf0107585
f0101a5f:	68 49 03 00 00       	push   $0x349
f0101a64:	68 58 75 10 f0       	push   $0xf0107558
f0101a69:	e8 33 e8 ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f0101a6e:	89 da                	mov    %ebx,%edx
f0101a70:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f0101a76:	c1 fa 03             	sar    $0x3,%edx
f0101a79:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101a7c:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101a81:	c1 e0 0c             	shl    $0xc,%eax
f0101a84:	39 c2                	cmp    %eax,%edx
f0101a86:	72 19                	jb     f0101aa1 <check_page_alloc+0x15c>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a88:	68 b3 76 10 f0       	push   $0xf01076b3
f0101a8d:	68 85 75 10 f0       	push   $0xf0107585
f0101a92:	68 4a 03 00 00       	push   $0x34a
f0101a97:	68 58 75 10 f0       	push   $0xf0107558
f0101a9c:	e8 00 e8 ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f0101aa1:	89 f2                	mov    %esi,%edx
f0101aa3:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f0101aa9:	c1 fa 03             	sar    $0x3,%edx
f0101aac:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101aaf:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101ab4:	c1 e0 0c             	shl    $0xc,%eax
f0101ab7:	39 c2                	cmp    %eax,%edx
f0101ab9:	72 19                	jb     f0101ad4 <check_page_alloc+0x18f>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101abb:	68 d0 76 10 f0       	push   $0xf01076d0
f0101ac0:	68 85 75 10 f0       	push   $0xf0107585
f0101ac5:	68 4b 03 00 00       	push   $0x34b
f0101aca:	68 58 75 10 f0       	push   $0xf0107558
f0101acf:	e8 cd e7 ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f0101ad4:	89 fa                	mov    %edi,%edx
f0101ad6:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f0101adc:	c1 fa 03             	sar    $0x3,%edx
f0101adf:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101ae2:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101ae7:	c1 e0 0c             	shl    $0xc,%eax
f0101aea:	39 c2                	cmp    %eax,%edx
f0101aec:	72 19                	jb     f0101b07 <check_page_alloc+0x1c2>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101aee:	68 ed 76 10 f0       	push   $0xf01076ed
f0101af3:	68 85 75 10 f0       	push   $0xf0107585
f0101af8:	68 4c 03 00 00       	push   $0x34c
f0101afd:	68 58 75 10 f0       	push   $0xf0107558
f0101b02:	e8 9a e7 ff ff       	call   f01002a1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b07:	a1 30 e2 1b f0       	mov    0xf01be230,%eax
f0101b0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	page_free_list = 0;
f0101b0f:	c7 05 30 e2 1b f0 00 	movl   $0x0,0xf01be230
f0101b16:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b19:	83 ec 0c             	sub    $0xc,%esp
f0101b1c:	6a 00                	push   $0x0
f0101b1e:	e8 58 f5 ff ff       	call   f010107b <page_alloc>
f0101b23:	83 c4 10             	add    $0x10,%esp
f0101b26:	85 c0                	test   %eax,%eax
f0101b28:	74 19                	je     f0101b43 <check_page_alloc+0x1fe>
f0101b2a:	68 0a 77 10 f0       	push   $0xf010770a
f0101b2f:	68 85 75 10 f0       	push   $0xf0107585
f0101b34:	68 53 03 00 00       	push   $0x353
f0101b39:	68 58 75 10 f0       	push   $0xf0107558
f0101b3e:	e8 5e e7 ff ff       	call   f01002a1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101b43:	83 ec 0c             	sub    $0xc,%esp
f0101b46:	53                   	push   %ebx
f0101b47:	e8 ac f5 ff ff       	call   f01010f8 <page_free>
	page_free(pp1);
f0101b4c:	89 34 24             	mov    %esi,(%esp)
f0101b4f:	e8 a4 f5 ff ff       	call   f01010f8 <page_free>
	page_free(pp2);	
f0101b54:	89 3c 24             	mov    %edi,(%esp)
f0101b57:	e8 9c f5 ff ff       	call   f01010f8 <page_free>


	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b63:	e8 13 f5 ff ff       	call   f010107b <page_alloc>
f0101b68:	89 c3                	mov    %eax,%ebx
f0101b6a:	83 c4 10             	add    $0x10,%esp
f0101b6d:	85 c0                	test   %eax,%eax
f0101b6f:	75 19                	jne    f0101b8a <check_page_alloc+0x245>
f0101b71:	68 5f 76 10 f0       	push   $0xf010765f
f0101b76:	68 85 75 10 f0       	push   $0xf0107585
f0101b7b:	68 5c 03 00 00       	push   $0x35c
f0101b80:	68 58 75 10 f0       	push   $0xf0107558
f0101b85:	e8 17 e7 ff ff       	call   f01002a1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b8a:	83 ec 0c             	sub    $0xc,%esp
f0101b8d:	6a 00                	push   $0x0
f0101b8f:	e8 e7 f4 ff ff       	call   f010107b <page_alloc>
f0101b94:	89 c6                	mov    %eax,%esi
f0101b96:	83 c4 10             	add    $0x10,%esp
f0101b99:	85 c0                	test   %eax,%eax
f0101b9b:	75 19                	jne    f0101bb6 <check_page_alloc+0x271>
f0101b9d:	68 75 76 10 f0       	push   $0xf0107675
f0101ba2:	68 85 75 10 f0       	push   $0xf0107585
f0101ba7:	68 5d 03 00 00       	push   $0x35d
f0101bac:	68 58 75 10 f0       	push   $0xf0107558
f0101bb1:	e8 eb e6 ff ff       	call   f01002a1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bb6:	83 ec 0c             	sub    $0xc,%esp
f0101bb9:	6a 00                	push   $0x0
f0101bbb:	e8 bb f4 ff ff       	call   f010107b <page_alloc>
f0101bc0:	89 c7                	mov    %eax,%edi
f0101bc2:	83 c4 10             	add    $0x10,%esp
f0101bc5:	85 c0                	test   %eax,%eax
f0101bc7:	75 19                	jne    f0101be2 <check_page_alloc+0x29d>
f0101bc9:	68 8b 76 10 f0       	push   $0xf010768b
f0101bce:	68 85 75 10 f0       	push   $0xf0107585
f0101bd3:	68 5e 03 00 00       	push   $0x35e
f0101bd8:	68 58 75 10 f0       	push   $0xf0107558
f0101bdd:	e8 bf e6 ff ff       	call   f01002a1 <_panic>
	assert(pp0);
f0101be2:	85 db                	test   %ebx,%ebx
f0101be4:	75 19                	jne    f0101bff <check_page_alloc+0x2ba>
f0101be6:	68 af 76 10 f0       	push   $0xf01076af
f0101beb:	68 85 75 10 f0       	push   $0xf0107585
f0101bf0:	68 5f 03 00 00       	push   $0x35f
f0101bf5:	68 58 75 10 f0       	push   $0xf0107558
f0101bfa:	e8 a2 e6 ff ff       	call   f01002a1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101bff:	85 f6                	test   %esi,%esi
f0101c01:	74 04                	je     f0101c07 <check_page_alloc+0x2c2>
f0101c03:	39 de                	cmp    %ebx,%esi
f0101c05:	75 19                	jne    f0101c20 <check_page_alloc+0x2db>
f0101c07:	68 a1 76 10 f0       	push   $0xf01076a1
f0101c0c:	68 85 75 10 f0       	push   $0xf0107585
f0101c11:	68 60 03 00 00       	push   $0x360
f0101c16:	68 58 75 10 f0       	push   $0xf0107558
f0101c1b:	e8 81 e6 ff ff       	call   f01002a1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c20:	85 c0                	test   %eax,%eax
f0101c22:	74 08                	je     f0101c2c <check_page_alloc+0x2e7>
f0101c24:	39 f0                	cmp    %esi,%eax
f0101c26:	74 04                	je     f0101c2c <check_page_alloc+0x2e7>
f0101c28:	39 d8                	cmp    %ebx,%eax
f0101c2a:	75 19                	jne    f0101c45 <check_page_alloc+0x300>
f0101c2c:	68 f4 6e 10 f0       	push   $0xf0106ef4
f0101c31:	68 85 75 10 f0       	push   $0xf0107585
f0101c36:	68 61 03 00 00       	push   $0x361
f0101c3b:	68 58 75 10 f0       	push   $0xf0107558
f0101c40:	e8 5c e6 ff ff       	call   f01002a1 <_panic>
	assert(!page_alloc(0));
f0101c45:	83 ec 0c             	sub    $0xc,%esp
f0101c48:	6a 00                	push   $0x0
f0101c4a:	e8 2c f4 ff ff       	call   f010107b <page_alloc>
f0101c4f:	83 c4 10             	add    $0x10,%esp
f0101c52:	85 c0                	test   %eax,%eax
f0101c54:	74 19                	je     f0101c6f <check_page_alloc+0x32a>
f0101c56:	68 0a 77 10 f0       	push   $0xf010770a
f0101c5b:	68 85 75 10 f0       	push   $0xf0107585
f0101c60:	68 62 03 00 00       	push   $0x362
f0101c65:	68 58 75 10 f0       	push   $0xf0107558
f0101c6a:	e8 32 e6 ff ff       	call   f01002a1 <_panic>
	return (pp - pages) << PGSHIFT;
f0101c6f:	89 d8                	mov    %ebx,%eax
f0101c71:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101c77:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101c7a:	89 c2                	mov    %eax,%edx
f0101c7c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c7f:	89 d0                	mov    %edx,%eax
f0101c81:	c1 e8 0c             	shr    $0xc,%eax
f0101c84:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0101c8a:	72 12                	jb     f0101c9e <check_page_alloc+0x359>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c8c:	52                   	push   %edx
f0101c8d:	68 58 6a 10 f0       	push   $0xf0106a58
f0101c92:	6a 56                	push   $0x56
f0101c94:	68 64 75 10 f0       	push   $0xf0107564
f0101c99:	e8 03 e6 ff ff       	call   f01002a1 <_panic>
f0101c9e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101ca4:	83 ec 04             	sub    $0x4,%esp
f0101ca7:	68 00 10 00 00       	push   $0x1000
f0101cac:	6a 01                	push   $0x1
f0101cae:	50                   	push   %eax
f0101caf:	e8 dd 3f 00 00       	call   f0105c91 <memset>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
f0101cb4:	89 1c 24             	mov    %ebx,(%esp)
f0101cb7:	e8 3c f4 ff ff       	call   f01010f8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101cbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101cc3:	e8 b3 f3 ff ff       	call   f010107b <page_alloc>
f0101cc8:	83 c4 10             	add    $0x10,%esp
f0101ccb:	85 c0                	test   %eax,%eax
f0101ccd:	75 19                	jne    f0101ce8 <check_page_alloc+0x3a3>
f0101ccf:	68 19 77 10 f0       	push   $0xf0107719
f0101cd4:	68 85 75 10 f0       	push   $0xf0107585
f0101cd9:	68 67 03 00 00       	push   $0x367
f0101cde:	68 58 75 10 f0       	push   $0xf0107558
f0101ce3:	e8 b9 e5 ff ff       	call   f01002a1 <_panic>
	assert(pp && pp0 == pp);
f0101ce8:	39 c3                	cmp    %eax,%ebx
f0101cea:	74 19                	je     f0101d05 <check_page_alloc+0x3c0>
f0101cec:	68 37 77 10 f0       	push   $0xf0107737
f0101cf1:	68 85 75 10 f0       	push   $0xf0107585
f0101cf6:	68 68 03 00 00       	push   $0x368
f0101cfb:	68 58 75 10 f0       	push   $0xf0107558
f0101d00:	e8 9c e5 ff ff       	call   f01002a1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d05:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0101d0b:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0101d0e:	89 c2                	mov    %eax,%edx
f0101d10:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d13:	89 d0                	mov    %edx,%eax
f0101d15:	c1 e8 0c             	shr    $0xc,%eax
f0101d18:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0101d1e:	72 12                	jb     f0101d32 <check_page_alloc+0x3ed>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d20:	52                   	push   %edx
f0101d21:	68 58 6a 10 f0       	push   $0xf0106a58
f0101d26:	6a 56                	push   $0x56
f0101d28:	68 64 75 10 f0       	push   $0xf0107564
f0101d2d:	e8 6f e5 ff ff       	call   f01002a1 <_panic>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0101d32:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101d38:	ba 00 00 00 00       	mov    $0x0,%edx
		assert(c[i] == 0);
f0101d3d:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f0101d41:	74 19                	je     f0101d5c <check_page_alloc+0x417>
f0101d43:	68 47 77 10 f0       	push   $0xf0107747
f0101d48:	68 85 75 10 f0       	push   $0xf0107585
f0101d4d:	68 6b 03 00 00       	push   $0x36b
f0101d52:	68 58 75 10 f0       	push   $0xf0107558
f0101d57:	e8 45 e5 ff ff       	call   f01002a1 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101d5c:	42                   	inc    %edx
f0101d5d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0101d63:	7e d8                	jle    f0101d3d <check_page_alloc+0x3f8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101d65:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d68:	a3 30 e2 1b f0       	mov    %eax,0xf01be230

	// free the pages we took
	page_free(pp0);
f0101d6d:	83 ec 0c             	sub    $0xc,%esp
f0101d70:	53                   	push   %ebx
f0101d71:	e8 82 f3 ff ff       	call   f01010f8 <page_free>
	page_free(pp1);
f0101d76:	89 34 24             	mov    %esi,(%esp)
f0101d79:	e8 7a f3 ff ff       	call   f01010f8 <page_free>
	page_free(pp2);
f0101d7e:	89 3c 24             	mov    %edi,(%esp)
f0101d81:	e8 72 f3 ff ff       	call   f01010f8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d86:	a1 30 e2 1b f0       	mov    0xf01be230,%eax
f0101d8b:	83 c4 10             	add    $0x10,%esp
f0101d8e:	85 c0                	test   %eax,%eax
f0101d90:	74 09                	je     f0101d9b <check_page_alloc+0x456>
		--nfree;
f0101d92:	ff 4d f0             	decl   -0x10(%ebp)
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d95:	8b 00                	mov    (%eax),%eax
f0101d97:	85 c0                	test   %eax,%eax
f0101d99:	75 f7                	jne    f0101d92 <check_page_alloc+0x44d>
		--nfree;
	assert(nfree == 0);
f0101d9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101d9f:	74 19                	je     f0101dba <check_page_alloc+0x475>
f0101da1:	68 51 77 10 f0       	push   $0xf0107751
f0101da6:	68 85 75 10 f0       	push   $0xf0107585
f0101dab:	68 78 03 00 00       	push   $0x378
f0101db0:	68 58 75 10 f0       	push   $0xf0107558
f0101db5:	e8 e7 e4 ff ff       	call   f01002a1 <_panic>

	cprintf("*********************************\n");
f0101dba:	83 ec 0c             	sub    $0xc,%esp
f0101dbd:	68 14 6f 10 f0       	push   $0xf0106f14
f0101dc2:	e8 0b 1c 00 00       	call   f01039d2 <cprintf>
	cprintf("**check_page_alloc() succeeded!**\n");
f0101dc7:	c7 04 24 38 6f 10 f0 	movl   $0xf0106f38,(%esp)
f0101dce:	e8 ff 1b 00 00       	call   f01039d2 <cprintf>
	cprintf("*********************************\n\n");
f0101dd3:	c7 04 24 5c 6f 10 f0 	movl   $0xf0106f5c,(%esp)
f0101dda:	e8 f3 1b 00 00       	call   f01039d2 <cprintf>
}
f0101ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101de2:	5b                   	pop    %ebx
f0101de3:	5e                   	pop    %esi
f0101de4:	5f                   	pop    %edi
f0101de5:	c9                   	leave  
f0101de6:	c3                   	ret    

f0101de7 <check_kern_pgdir>:
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
f0101de7:	55                   	push   %ebp
f0101de8:	89 e5                	mov    %esp,%ebp
f0101dea:	57                   	push   %edi
f0101deb:	56                   	push   %esi
f0101dec:	53                   	push   %ebx
f0101ded:	83 ec 0c             	sub    $0xc,%esp
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0101df0:	8b 3d ec ee 1b f0    	mov    0xf01beeec,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0101df6:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101dfb:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101e07:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
f0101e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101e0f:	39 c3                	cmp    %eax,%ebx
f0101e11:	73 65                	jae    f0101e78 <check_kern_pgdir+0x91>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101e13:	83 ec 08             	sub    $0x8,%esp
f0101e16:	8d 83 00 00 00 ef    	lea    -0x11000000(%ebx),%eax
f0101e1c:	50                   	push   %eax
f0101e1d:	57                   	push   %edi
f0101e1e:	e8 05 03 00 00       	call   f0102128 <check_va2pa>
f0101e23:	89 c2                	mov    %eax,%edx
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0101e25:	83 c4 10             	add    $0x10,%esp
f0101e28:	a1 f0 ee 1b f0       	mov    0xf01beef0,%eax
	if ((uint32_t)kva < KERNBASE)
f0101e2d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e32:	77 15                	ja     f0101e49 <check_kern_pgdir+0x62>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101e34:	50                   	push   %eax
f0101e35:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101e3a:	68 92 03 00 00       	push   $0x392
f0101e3f:	68 58 75 10 f0       	push   $0xf0107558
f0101e44:	e8 58 e4 ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0101e49:	8d 84 18 00 00 00 10 	lea    0x10000000(%eax,%ebx,1),%eax
f0101e50:	39 c2                	cmp    %eax,%edx
f0101e52:	74 19                	je     f0101e6d <check_kern_pgdir+0x86>
f0101e54:	68 80 6f 10 f0       	push   $0xf0106f80
f0101e59:	68 85 75 10 f0       	push   $0xf0107585
f0101e5e:	68 92 03 00 00       	push   $0x392
f0101e63:	68 58 75 10 f0       	push   $0xf0107558
f0101e68:	e8 34 e4 ff ff       	call   f01002a1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0101e6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101e73:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101e76:	72 9b                	jb     f0101e13 <check_kern_pgdir+0x2c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
		

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
f0101e78:	c7 45 f0 00 f0 01 00 	movl   $0x1f000,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0101e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101e84:	83 ec 08             	sub    $0x8,%esp
f0101e87:	8d 83 00 00 c0 ee    	lea    -0x11400000(%ebx),%eax
f0101e8d:	50                   	push   %eax
f0101e8e:	57                   	push   %edi
f0101e8f:	e8 94 02 00 00       	call   f0102128 <check_va2pa>
f0101e94:	89 c2                	mov    %eax,%edx
f0101e96:	83 c4 10             	add    $0x10,%esp
f0101e99:	a1 38 e2 1b f0       	mov    0xf01be238,%eax
	if ((uint32_t)kva < KERNBASE)
f0101e9e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101ea3:	77 15                	ja     f0101eba <check_kern_pgdir+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101ea5:	50                   	push   %eax
f0101ea6:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101eab:	68 98 03 00 00       	push   $0x398
f0101eb0:	68 58 75 10 f0       	push   $0xf0107558
f0101eb5:	e8 e7 e3 ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0101eba:	8d 84 18 00 00 00 10 	lea    0x10000000(%eax,%ebx,1),%eax
f0101ec1:	39 c2                	cmp    %eax,%edx
f0101ec3:	74 19                	je     f0101ede <check_kern_pgdir+0xf7>
f0101ec5:	68 b4 6f 10 f0       	push   $0xf0106fb4
f0101eca:	68 85 75 10 f0       	push   $0xf0107585
f0101ecf:	68 98 03 00 00       	push   $0x398
f0101ed4:	68 58 75 10 f0       	push   $0xf0107558
f0101ed9:	e8 c3 e3 ff ff       	call   f01002a1 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
		

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101ede:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101ee4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101ee7:	72 9b                	jb     f0101e84 <check_kern_pgdir+0x9d>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101eee:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101ef3:	c1 e0 0c             	shl    $0xc,%eax
f0101ef6:	83 f8 00             	cmp    $0x0,%eax
f0101ef9:	76 42                	jbe    f0101f3d <check_kern_pgdir+0x156>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101efb:	83 ec 08             	sub    $0x8,%esp
f0101efe:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
f0101f04:	50                   	push   %eax
f0101f05:	57                   	push   %edi
f0101f06:	e8 1d 02 00 00       	call   f0102128 <check_va2pa>
f0101f0b:	83 c4 10             	add    $0x10,%esp
f0101f0e:	39 d8                	cmp    %ebx,%eax
f0101f10:	74 19                	je     f0101f2b <check_kern_pgdir+0x144>
f0101f12:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0101f17:	68 85 75 10 f0       	push   $0xf0107585
f0101f1c:	68 9c 03 00 00       	push   $0x39c
f0101f21:	68 58 75 10 f0       	push   $0xf0107558
f0101f26:	e8 76 e3 ff ff       	call   f01002a1 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101f2b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101f31:	a1 e8 ee 1b f0       	mov    0xf01beee8,%eax
f0101f36:	c1 e0 0c             	shl    $0xc,%eax
f0101f39:	39 d8                	cmp    %ebx,%eax
f0101f3b:	77 be                	ja     f0101efb <check_kern_pgdir+0x114>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0101f3d:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, i) == i);
f0101f42:	83 ec 08             	sub    $0x8,%esp
f0101f45:	53                   	push   %ebx
f0101f46:	57                   	push   %edi
f0101f47:	e8 dc 01 00 00       	call   f0102128 <check_va2pa>
f0101f4c:	83 c4 10             	add    $0x10,%esp
f0101f4f:	39 d8                	cmp    %ebx,%eax
f0101f51:	74 19                	je     f0101f6c <check_kern_pgdir+0x185>
f0101f53:	68 5c 77 10 f0       	push   $0xf010775c
f0101f58:	68 85 75 10 f0       	push   $0xf0107585
f0101f5d:	68 a0 03 00 00       	push   $0x3a0
f0101f62:	68 58 75 10 f0       	push   $0xf0107558
f0101f67:	e8 35 e3 ff ff       	call   f01002a1 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0101f6c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101f72:	81 fb ff ef ff ff    	cmp    $0xffffefff,%ebx
f0101f78:	76 c8                	jbe    f0101f42 <check_kern_pgdir+0x15b>
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0101f7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
f0101f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101f84:	c1 e0 10             	shl    $0x10,%eax
f0101f87:	ba 00 00 bf ef       	mov    $0xefbf0000,%edx
f0101f8c:	29 c2                	sub    %eax,%edx
f0101f8e:	89 55 ec             	mov    %edx,-0x14(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f0101f91:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101f99:	c1 e0 0f             	shl    $0xf,%eax
f0101f9c:	8d b0 00 00 1c f0    	lea    -0xfe40000(%eax),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0101fa2:	83 ec 08             	sub    $0x8,%esp
f0101fa5:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101fa8:	8d 84 1a 00 80 00 00 	lea    0x8000(%edx,%ebx,1),%eax
f0101faf:	50                   	push   %eax
f0101fb0:	57                   	push   %edi
f0101fb1:	e8 72 01 00 00       	call   f0102128 <check_va2pa>
f0101fb6:	89 c2                	mov    %eax,%edx
f0101fb8:	83 c4 10             	add    $0x10,%esp
	if ((uint32_t)kva < KERNBASE)
f0101fbb:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0101fc1:	77 15                	ja     f0101fd8 <check_kern_pgdir+0x1f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101fc3:	56                   	push   %esi
f0101fc4:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101fc9:	68 a8 03 00 00       	push   $0x3a8
f0101fce:	68 58 75 10 f0       	push   $0xf0107558
f0101fd3:	e8 c9 e2 ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0101fd8:	8d 84 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%eax
f0101fdf:	39 c2                	cmp    %eax,%edx
f0101fe1:	74 19                	je     f0101ffc <check_kern_pgdir+0x215>
f0101fe3:	68 10 70 10 f0       	push   $0xf0107010
f0101fe8:	68 85 75 10 f0       	push   $0xf0107585
f0101fed:	68 a8 03 00 00       	push   $0x3a8
f0101ff2:	68 58 75 10 f0       	push   $0xf0107558
f0101ff7:	e8 a5 e2 ff ff       	call   f01002a1 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f0101ffc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102002:	81 fb ff 7f 00 00    	cmp    $0x7fff,%ebx
f0102008:	76 98                	jbe    f0101fa2 <check_kern_pgdir+0x1bb>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		}
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010200a:	bb 00 00 00 00       	mov    $0x0,%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f010200f:	83 ec 08             	sub    $0x8,%esp
f0102012:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102015:	01 d8                	add    %ebx,%eax
f0102017:	50                   	push   %eax
f0102018:	57                   	push   %edi
f0102019:	e8 0a 01 00 00       	call   f0102128 <check_va2pa>
f010201e:	83 c4 10             	add    $0x10,%esp
f0102021:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102024:	74 19                	je     f010203f <check_kern_pgdir+0x258>
f0102026:	68 58 70 10 f0       	push   $0xf0107058
f010202b:	68 85 75 10 f0       	push   $0xf0107585
f0102030:	68 ab 03 00 00       	push   $0x3ab
f0102035:	68 58 75 10 f0       	push   $0xf0107558
f010203a:	e8 62 e2 ff ff       	call   f01002a1 <_panic>
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) {
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		}
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010203f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102045:	81 fb ff 7f 00 00    	cmp    $0x7fff,%ebx
f010204b:	76 c2                	jbe    f010200f <check_kern_pgdir+0x228>
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010204d:	ff 45 f0             	incl   -0x10(%ebp)
f0102050:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
f0102054:	0f 86 27 ff ff ff    	jbe    f0101f81 <check_kern_pgdir+0x19a>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010205a:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (i) {
f010205f:	8d 83 45 fc ff ff    	lea    -0x3bb(%ebx),%eax
f0102065:	83 f8 03             	cmp    $0x3,%eax
f0102068:	77 1f                	ja     f0102089 <check_kern_pgdir+0x2a2>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010206a:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
f010206e:	75 7e                	jne    f01020ee <check_kern_pgdir+0x307>
f0102070:	68 77 77 10 f0       	push   $0xf0107777
f0102075:	68 85 75 10 f0       	push   $0xf0107585
f010207a:	68 b5 03 00 00       	push   $0x3b5
f010207f:	68 58 75 10 f0       	push   $0xf0107558
f0102084:	e8 18 e2 ff ff       	call   f01002a1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102089:	81 fb bf 03 00 00    	cmp    $0x3bf,%ebx
f010208f:	76 3e                	jbe    f01020cf <check_kern_pgdir+0x2e8>
				assert(pgdir[i] & PTE_P);
f0102091:	f6 04 9f 01          	testb  $0x1,(%edi,%ebx,4)
f0102095:	75 19                	jne    f01020b0 <check_kern_pgdir+0x2c9>
f0102097:	68 77 77 10 f0       	push   $0xf0107777
f010209c:	68 85 75 10 f0       	push   $0xf0107585
f01020a1:	68 b9 03 00 00       	push   $0x3b9
f01020a6:	68 58 75 10 f0       	push   $0xf0107558
f01020ab:	e8 f1 e1 ff ff       	call   f01002a1 <_panic>
				assert(pgdir[i] & PTE_W);
f01020b0:	f6 04 9f 02          	testb  $0x2,(%edi,%ebx,4)
f01020b4:	75 38                	jne    f01020ee <check_kern_pgdir+0x307>
f01020b6:	68 88 77 10 f0       	push   $0xf0107788
f01020bb:	68 85 75 10 f0       	push   $0xf0107585
f01020c0:	68 ba 03 00 00       	push   $0x3ba
f01020c5:	68 58 75 10 f0       	push   $0xf0107558
f01020ca:	e8 d2 e1 ff ff       	call   f01002a1 <_panic>
			} else
				assert(pgdir[i] == 0);
f01020cf:	83 3c 9f 00          	cmpl   $0x0,(%edi,%ebx,4)
f01020d3:	74 19                	je     f01020ee <check_kern_pgdir+0x307>
f01020d5:	68 99 77 10 f0       	push   $0xf0107799
f01020da:	68 85 75 10 f0       	push   $0xf0107585
f01020df:	68 bc 03 00 00       	push   $0x3bc
f01020e4:	68 58 75 10 f0       	push   $0xf0107558
f01020e9:	e8 b3 e1 ff ff       	call   f01002a1 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01020ee:	43                   	inc    %ebx
f01020ef:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f01020f5:	0f 86 64 ff ff ff    	jbe    f010205f <check_kern_pgdir+0x278>
				assert(pgdir[i] == 0);
			break;
		}
	}

	cprintf("************************************\n");
f01020fb:	83 ec 0c             	sub    $0xc,%esp
f01020fe:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0102103:	e8 ca 18 00 00       	call   f01039d2 <cprintf>
	cprintf("***check_kern_pgdir() succeeded!****\n");
f0102108:	c7 04 24 7c 70 10 f0 	movl   $0xf010707c,(%esp)
f010210f:	e8 be 18 00 00       	call   f01039d2 <cprintf>
	cprintf("************************************\n\n");
f0102114:	c7 04 24 cc 6e 10 f0 	movl   $0xf0106ecc,(%esp)
f010211b:	e8 b2 18 00 00       	call   f01039d2 <cprintf>
}
f0102120:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102123:	5b                   	pop    %ebx
f0102124:	5e                   	pop    %esi
f0102125:	5f                   	pop    %edi
f0102126:	c9                   	leave  
f0102127:	c3                   	ret    

f0102128 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0102128:	55                   	push   %ebp
f0102129:	89 e5                	mov    %esp,%ebp
f010212b:	53                   	push   %ebx
f010212c:	83 ec 04             	sub    $0x4,%esp
f010212f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0102132:	89 d8                	mov    %ebx,%eax
f0102134:	c1 e8 16             	shr    $0x16,%eax
f0102137:	c1 e0 02             	shl    $0x2,%eax
f010213a:	03 45 08             	add    0x8(%ebp),%eax
	if (!(*pgdir & PTE_P))
		return ~0;
f010213d:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0102142:	f6 00 01             	testb  $0x1,(%eax)
f0102145:	74 58                	je     f010219f <check_va2pa+0x77>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0102147:	8b 10                	mov    (%eax),%edx
f0102149:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010214f:	89 d0                	mov    %edx,%eax
f0102151:	c1 e8 0c             	shr    $0xc,%eax
f0102154:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f010215a:	72 15                	jb     f0102171 <check_va2pa+0x49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010215c:	52                   	push   %edx
f010215d:	68 58 6a 10 f0       	push   $0xf0106a58
f0102162:	68 d3 03 00 00       	push   $0x3d3
f0102167:	68 58 75 10 f0       	push   $0xf0107558
f010216c:	e8 30 e1 ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0102171:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0102177:	89 d8                	mov    %ebx,%eax
f0102179:	c1 e8 0c             	shr    $0xc,%eax
f010217c:	25 ff 03 00 00       	and    $0x3ff,%eax
		return ~0;
f0102181:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0102186:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f010218a:	74 13                	je     f010219f <check_va2pa+0x77>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010218c:	89 d8                	mov    %ebx,%eax
f010218e:	c1 e8 0c             	shr    $0xc,%eax
f0102191:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102196:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f0102199:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
}
f010219f:	89 c8                	mov    %ecx,%eax
f01021a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01021a4:	c9                   	leave  
f01021a5:	c3                   	ret    

f01021a6 <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f01021a6:	55                   	push   %ebp
f01021a7:	89 e5                	mov    %esp,%ebp
f01021a9:	57                   	push   %edi
f01021aa:	56                   	push   %esi
f01021ab:	53                   	push   %ebx
f01021ac:	83 ec 18             	sub    $0x18,%esp
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01021af:	6a 00                	push   $0x0
f01021b1:	e8 c5 ee ff ff       	call   f010107b <page_alloc>
f01021b6:	89 c7                	mov    %eax,%edi
f01021b8:	83 c4 10             	add    $0x10,%esp
f01021bb:	85 c0                	test   %eax,%eax
f01021bd:	75 19                	jne    f01021d8 <check_page+0x32>
f01021bf:	68 5f 76 10 f0       	push   $0xf010765f
f01021c4:	68 85 75 10 f0       	push   $0xf0107585
f01021c9:	68 e7 03 00 00       	push   $0x3e7
f01021ce:	68 58 75 10 f0       	push   $0xf0107558
f01021d3:	e8 c9 e0 ff ff       	call   f01002a1 <_panic>
	assert((pp1 = page_alloc(0)));
f01021d8:	83 ec 0c             	sub    $0xc,%esp
f01021db:	6a 00                	push   $0x0
f01021dd:	e8 99 ee ff ff       	call   f010107b <page_alloc>
f01021e2:	89 c3                	mov    %eax,%ebx
f01021e4:	83 c4 10             	add    $0x10,%esp
f01021e7:	85 c0                	test   %eax,%eax
f01021e9:	75 19                	jne    f0102204 <check_page+0x5e>
f01021eb:	68 75 76 10 f0       	push   $0xf0107675
f01021f0:	68 85 75 10 f0       	push   $0xf0107585
f01021f5:	68 e8 03 00 00       	push   $0x3e8
f01021fa:	68 58 75 10 f0       	push   $0xf0107558
f01021ff:	e8 9d e0 ff ff       	call   f01002a1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102204:	83 ec 0c             	sub    $0xc,%esp
f0102207:	6a 00                	push   $0x0
f0102209:	e8 6d ee ff ff       	call   f010107b <page_alloc>
f010220e:	89 c6                	mov    %eax,%esi
f0102210:	83 c4 10             	add    $0x10,%esp
f0102213:	85 c0                	test   %eax,%eax
f0102215:	75 19                	jne    f0102230 <check_page+0x8a>
f0102217:	68 8b 76 10 f0       	push   $0xf010768b
f010221c:	68 85 75 10 f0       	push   $0xf0107585
f0102221:	68 e9 03 00 00       	push   $0x3e9
f0102226:	68 58 75 10 f0       	push   $0xf0107558
f010222b:	e8 71 e0 ff ff       	call   f01002a1 <_panic>

	assert(pp0);
f0102230:	85 ff                	test   %edi,%edi
f0102232:	75 19                	jne    f010224d <check_page+0xa7>
f0102234:	68 af 76 10 f0       	push   $0xf01076af
f0102239:	68 85 75 10 f0       	push   $0xf0107585
f010223e:	68 eb 03 00 00       	push   $0x3eb
f0102243:	68 58 75 10 f0       	push   $0xf0107558
f0102248:	e8 54 e0 ff ff       	call   f01002a1 <_panic>
	assert(pp1 && pp1 != pp0);
f010224d:	85 db                	test   %ebx,%ebx
f010224f:	74 04                	je     f0102255 <check_page+0xaf>
f0102251:	39 fb                	cmp    %edi,%ebx
f0102253:	75 19                	jne    f010226e <check_page+0xc8>
f0102255:	68 a1 76 10 f0       	push   $0xf01076a1
f010225a:	68 85 75 10 f0       	push   $0xf0107585
f010225f:	68 ec 03 00 00       	push   $0x3ec
f0102264:	68 58 75 10 f0       	push   $0xf0107558
f0102269:	e8 33 e0 ff ff       	call   f01002a1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010226e:	85 c0                	test   %eax,%eax
f0102270:	74 08                	je     f010227a <check_page+0xd4>
f0102272:	39 d8                	cmp    %ebx,%eax
f0102274:	74 04                	je     f010227a <check_page+0xd4>
f0102276:	39 f8                	cmp    %edi,%eax
f0102278:	75 19                	jne    f0102293 <check_page+0xed>
f010227a:	68 f4 6e 10 f0       	push   $0xf0106ef4
f010227f:	68 85 75 10 f0       	push   $0xf0107585
f0102284:	68 ed 03 00 00       	push   $0x3ed
f0102289:	68 58 75 10 f0       	push   $0xf0107558
f010228e:	e8 0e e0 ff ff       	call   f01002a1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102293:	a1 30 e2 1b f0       	mov    0xf01be230,%eax
f0102298:	89 45 ec             	mov    %eax,-0x14(%ebp)
	page_free_list = 0;
f010229b:	c7 05 30 e2 1b f0 00 	movl   $0x0,0xf01be230
f01022a2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01022a5:	83 ec 0c             	sub    $0xc,%esp
f01022a8:	6a 00                	push   $0x0
f01022aa:	e8 cc ed ff ff       	call   f010107b <page_alloc>
f01022af:	83 c4 10             	add    $0x10,%esp
f01022b2:	85 c0                	test   %eax,%eax
f01022b4:	74 19                	je     f01022cf <check_page+0x129>
f01022b6:	68 0a 77 10 f0       	push   $0xf010770a
f01022bb:	68 85 75 10 f0       	push   $0xf0107585
f01022c0:	68 f4 03 00 00       	push   $0x3f4
f01022c5:	68 58 75 10 f0       	push   $0xf0107558
f01022ca:	e8 d2 df ff ff       	call   f01002a1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022cf:	83 ec 04             	sub    $0x4,%esp
f01022d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01022d5:	50                   	push   %eax
f01022d6:	6a 00                	push   $0x0
f01022d8:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01022de:	e8 05 f1 ff ff       	call   f01013e8 <page_lookup>
f01022e3:	83 c4 10             	add    $0x10,%esp
f01022e6:	85 c0                	test   %eax,%eax
f01022e8:	74 19                	je     f0102303 <check_page+0x15d>
f01022ea:	68 a4 70 10 f0       	push   $0xf01070a4
f01022ef:	68 85 75 10 f0       	push   $0xf0107585
f01022f4:	68 f7 03 00 00       	push   $0x3f7
f01022f9:	68 58 75 10 f0       	push   $0xf0107558
f01022fe:	e8 9e df ff ff       	call   f01002a1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102303:	6a 02                	push   $0x2
f0102305:	6a 00                	push   $0x0
f0102307:	53                   	push   %ebx
f0102308:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f010230e:	e8 13 f0 ff ff       	call   f0101326 <page_insert>
f0102313:	83 c4 10             	add    $0x10,%esp
f0102316:	85 c0                	test   %eax,%eax
f0102318:	78 19                	js     f0102333 <check_page+0x18d>
f010231a:	68 dc 70 10 f0       	push   $0xf01070dc
f010231f:	68 85 75 10 f0       	push   $0xf0107585
f0102324:	68 fa 03 00 00       	push   $0x3fa
f0102329:	68 58 75 10 f0       	push   $0xf0107558
f010232e:	e8 6e df ff ff       	call   f01002a1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102333:	83 ec 0c             	sub    $0xc,%esp
f0102336:	57                   	push   %edi
f0102337:	e8 bc ed ff ff       	call   f01010f8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010233c:	6a 02                	push   $0x2
f010233e:	6a 00                	push   $0x0
f0102340:	53                   	push   %ebx
f0102341:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102347:	e8 da ef ff ff       	call   f0101326 <page_insert>
f010234c:	83 c4 20             	add    $0x20,%esp
f010234f:	85 c0                	test   %eax,%eax
f0102351:	74 19                	je     f010236c <check_page+0x1c6>
f0102353:	68 0c 71 10 f0       	push   $0xf010710c
f0102358:	68 85 75 10 f0       	push   $0xf0107585
f010235d:	68 fe 03 00 00       	push   $0x3fe
f0102362:	68 58 75 10 f0       	push   $0xf0107558
f0102367:	e8 35 df ff ff       	call   f01002a1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010236c:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102371:	8b 10                	mov    (%eax),%edx
f0102373:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102379:	89 f8                	mov    %edi,%eax
f010237b:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102381:	c1 f8 03             	sar    $0x3,%eax
f0102384:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102387:	39 c2                	cmp    %eax,%edx
f0102389:	74 19                	je     f01023a4 <check_page+0x1fe>
f010238b:	68 3c 71 10 f0       	push   $0xf010713c
f0102390:	68 85 75 10 f0       	push   $0xf0107585
f0102395:	68 ff 03 00 00       	push   $0x3ff
f010239a:	68 58 75 10 f0       	push   $0xf0107558
f010239f:	e8 fd de ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023a4:	83 ec 08             	sub    $0x8,%esp
f01023a7:	6a 00                	push   $0x0
f01023a9:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01023af:	e8 74 fd ff ff       	call   f0102128 <check_va2pa>
f01023b4:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f01023b7:	89 da                	mov    %ebx,%edx
f01023b9:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f01023bf:	c1 fa 03             	sar    $0x3,%edx
f01023c2:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01023c5:	39 d0                	cmp    %edx,%eax
f01023c7:	74 19                	je     f01023e2 <check_page+0x23c>
f01023c9:	68 64 71 10 f0       	push   $0xf0107164
f01023ce:	68 85 75 10 f0       	push   $0xf0107585
f01023d3:	68 00 04 00 00       	push   $0x400
f01023d8:	68 58 75 10 f0       	push   $0xf0107558
f01023dd:	e8 bf de ff ff       	call   f01002a1 <_panic>
	assert(pp1->pp_ref == 1);
f01023e2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01023e7:	74 19                	je     f0102402 <check_page+0x25c>
f01023e9:	68 a7 77 10 f0       	push   $0xf01077a7
f01023ee:	68 85 75 10 f0       	push   $0xf0107585
f01023f3:	68 01 04 00 00       	push   $0x401
f01023f8:	68 58 75 10 f0       	push   $0xf0107558
f01023fd:	e8 9f de ff ff       	call   f01002a1 <_panic>
	assert(pp0->pp_ref == 1);
f0102402:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102407:	74 19                	je     f0102422 <check_page+0x27c>
f0102409:	68 b8 77 10 f0       	push   $0xf01077b8
f010240e:	68 85 75 10 f0       	push   $0xf0107585
f0102413:	68 02 04 00 00       	push   $0x402
f0102418:	68 58 75 10 f0       	push   $0xf0107558
f010241d:	e8 7f de ff ff       	call   f01002a1 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102422:	6a 02                	push   $0x2
f0102424:	68 00 10 00 00       	push   $0x1000
f0102429:	56                   	push   %esi
f010242a:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102430:	e8 f1 ee ff ff       	call   f0101326 <page_insert>
f0102435:	83 c4 10             	add    $0x10,%esp
f0102438:	85 c0                	test   %eax,%eax
f010243a:	74 19                	je     f0102455 <check_page+0x2af>
f010243c:	68 94 71 10 f0       	push   $0xf0107194
f0102441:	68 85 75 10 f0       	push   $0xf0107585
f0102446:	68 05 04 00 00       	push   $0x405
f010244b:	68 58 75 10 f0       	push   $0xf0107558
f0102450:	e8 4c de ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102455:	83 ec 08             	sub    $0x8,%esp
f0102458:	68 00 10 00 00       	push   $0x1000
f010245d:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102463:	e8 c0 fc ff ff       	call   f0102128 <check_va2pa>
f0102468:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f010246b:	89 f2                	mov    %esi,%edx
f010246d:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f0102473:	c1 fa 03             	sar    $0x3,%edx
f0102476:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102479:	39 d0                	cmp    %edx,%eax
f010247b:	74 19                	je     f0102496 <check_page+0x2f0>
f010247d:	68 d0 71 10 f0       	push   $0xf01071d0
f0102482:	68 85 75 10 f0       	push   $0xf0107585
f0102487:	68 06 04 00 00       	push   $0x406
f010248c:	68 58 75 10 f0       	push   $0xf0107558
f0102491:	e8 0b de ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 1);
f0102496:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010249b:	74 19                	je     f01024b6 <check_page+0x310>
f010249d:	68 c9 77 10 f0       	push   $0xf01077c9
f01024a2:	68 85 75 10 f0       	push   $0xf0107585
f01024a7:	68 07 04 00 00       	push   $0x407
f01024ac:	68 58 75 10 f0       	push   $0xf0107558
f01024b1:	e8 eb dd ff ff       	call   f01002a1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024b6:	83 ec 0c             	sub    $0xc,%esp
f01024b9:	6a 00                	push   $0x0
f01024bb:	e8 bb eb ff ff       	call   f010107b <page_alloc>
f01024c0:	83 c4 10             	add    $0x10,%esp
f01024c3:	85 c0                	test   %eax,%eax
f01024c5:	74 19                	je     f01024e0 <check_page+0x33a>
f01024c7:	68 0a 77 10 f0       	push   $0xf010770a
f01024cc:	68 85 75 10 f0       	push   $0xf0107585
f01024d1:	68 0a 04 00 00       	push   $0x40a
f01024d6:	68 58 75 10 f0       	push   $0xf0107558
f01024db:	e8 c1 dd ff ff       	call   f01002a1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024e0:	6a 02                	push   $0x2
f01024e2:	68 00 10 00 00       	push   $0x1000
f01024e7:	56                   	push   %esi
f01024e8:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01024ee:	e8 33 ee ff ff       	call   f0101326 <page_insert>
f01024f3:	83 c4 10             	add    $0x10,%esp
f01024f6:	85 c0                	test   %eax,%eax
f01024f8:	74 19                	je     f0102513 <check_page+0x36d>
f01024fa:	68 94 71 10 f0       	push   $0xf0107194
f01024ff:	68 85 75 10 f0       	push   $0xf0107585
f0102504:	68 0d 04 00 00       	push   $0x40d
f0102509:	68 58 75 10 f0       	push   $0xf0107558
f010250e:	e8 8e dd ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102513:	83 ec 08             	sub    $0x8,%esp
f0102516:	68 00 10 00 00       	push   $0x1000
f010251b:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102521:	e8 02 fc ff ff       	call   f0102128 <check_va2pa>
f0102526:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f0102529:	89 f2                	mov    %esi,%edx
f010252b:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f0102531:	c1 fa 03             	sar    $0x3,%edx
f0102534:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102537:	39 d0                	cmp    %edx,%eax
f0102539:	74 19                	je     f0102554 <check_page+0x3ae>
f010253b:	68 d0 71 10 f0       	push   $0xf01071d0
f0102540:	68 85 75 10 f0       	push   $0xf0107585
f0102545:	68 0e 04 00 00       	push   $0x40e
f010254a:	68 58 75 10 f0       	push   $0xf0107558
f010254f:	e8 4d dd ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 1);
f0102554:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102559:	74 19                	je     f0102574 <check_page+0x3ce>
f010255b:	68 c9 77 10 f0       	push   $0xf01077c9
f0102560:	68 85 75 10 f0       	push   $0xf0107585
f0102565:	68 0f 04 00 00       	push   $0x40f
f010256a:	68 58 75 10 f0       	push   $0xf0107558
f010256f:	e8 2d dd ff ff       	call   f01002a1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102574:	83 ec 0c             	sub    $0xc,%esp
f0102577:	6a 00                	push   $0x0
f0102579:	e8 fd ea ff ff       	call   f010107b <page_alloc>
f010257e:	83 c4 10             	add    $0x10,%esp
f0102581:	85 c0                	test   %eax,%eax
f0102583:	74 19                	je     f010259e <check_page+0x3f8>
f0102585:	68 0a 77 10 f0       	push   $0xf010770a
f010258a:	68 85 75 10 f0       	push   $0xf0107585
f010258f:	68 13 04 00 00       	push   $0x413
f0102594:	68 58 75 10 f0       	push   $0xf0107558
f0102599:	e8 03 dd ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f010259e:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f01025a3:	8b 10                	mov    (%eax),%edx
f01025a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01025ab:	89 d0                	mov    %edx,%eax
f01025ad:	c1 e8 0c             	shr    $0xc,%eax
f01025b0:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f01025b6:	72 15                	jb     f01025cd <check_page+0x427>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025b8:	52                   	push   %edx
f01025b9:	68 58 6a 10 f0       	push   $0xf0106a58
f01025be:	68 16 04 00 00       	push   $0x416
f01025c3:	68 58 75 10 f0       	push   $0xf0107558
f01025c8:	e8 d4 dc ff ff       	call   f01002a1 <_panic>
f01025cd:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01025d3:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025d6:	83 ec 04             	sub    $0x4,%esp
f01025d9:	6a 00                	push   $0x0
f01025db:	68 00 10 00 00       	push   $0x1000
f01025e0:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01025e6:	e8 9c eb ff ff       	call   f0101187 <pgdir_walk>
f01025eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01025ee:	83 c2 04             	add    $0x4,%edx
f01025f1:	83 c4 10             	add    $0x10,%esp
f01025f4:	39 d0                	cmp    %edx,%eax
f01025f6:	74 19                	je     f0102611 <check_page+0x46b>
f01025f8:	68 00 72 10 f0       	push   $0xf0107200
f01025fd:	68 85 75 10 f0       	push   $0xf0107585
f0102602:	68 17 04 00 00       	push   $0x417
f0102607:	68 58 75 10 f0       	push   $0xf0107558
f010260c:	e8 90 dc ff ff       	call   f01002a1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102611:	6a 06                	push   $0x6
f0102613:	68 00 10 00 00       	push   $0x1000
f0102618:	56                   	push   %esi
f0102619:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f010261f:	e8 02 ed ff ff       	call   f0101326 <page_insert>
f0102624:	83 c4 10             	add    $0x10,%esp
f0102627:	85 c0                	test   %eax,%eax
f0102629:	74 19                	je     f0102644 <check_page+0x49e>
f010262b:	68 40 72 10 f0       	push   $0xf0107240
f0102630:	68 85 75 10 f0       	push   $0xf0107585
f0102635:	68 1a 04 00 00       	push   $0x41a
f010263a:	68 58 75 10 f0       	push   $0xf0107558
f010263f:	e8 5d dc ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102644:	83 ec 08             	sub    $0x8,%esp
f0102647:	68 00 10 00 00       	push   $0x1000
f010264c:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102652:	e8 d1 fa ff ff       	call   f0102128 <check_va2pa>
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102657:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f010265a:	89 f2                	mov    %esi,%edx
f010265c:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f0102662:	c1 fa 03             	sar    $0x3,%edx
f0102665:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102668:	39 d0                	cmp    %edx,%eax
f010266a:	74 19                	je     f0102685 <check_page+0x4df>
f010266c:	68 d0 71 10 f0       	push   $0xf01071d0
f0102671:	68 85 75 10 f0       	push   $0xf0107585
f0102676:	68 1b 04 00 00       	push   $0x41b
f010267b:	68 58 75 10 f0       	push   $0xf0107558
f0102680:	e8 1c dc ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 1);
f0102685:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010268a:	74 19                	je     f01026a5 <check_page+0x4ff>
f010268c:	68 c9 77 10 f0       	push   $0xf01077c9
f0102691:	68 85 75 10 f0       	push   $0xf0107585
f0102696:	68 1c 04 00 00       	push   $0x41c
f010269b:	68 58 75 10 f0       	push   $0xf0107558
f01026a0:	e8 fc db ff ff       	call   f01002a1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01026a5:	83 ec 04             	sub    $0x4,%esp
f01026a8:	6a 00                	push   $0x0
f01026aa:	68 00 10 00 00       	push   $0x1000
f01026af:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01026b5:	e8 cd ea ff ff       	call   f0101187 <pgdir_walk>
f01026ba:	83 c4 10             	add    $0x10,%esp
f01026bd:	f6 00 04             	testb  $0x4,(%eax)
f01026c0:	75 19                	jne    f01026db <check_page+0x535>
f01026c2:	68 80 72 10 f0       	push   $0xf0107280
f01026c7:	68 85 75 10 f0       	push   $0xf0107585
f01026cc:	68 1d 04 00 00       	push   $0x41d
f01026d1:	68 58 75 10 f0       	push   $0xf0107558
f01026d6:	e8 c6 db ff ff       	call   f01002a1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01026db:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f01026e0:	f6 00 04             	testb  $0x4,(%eax)
f01026e3:	75 19                	jne    f01026fe <check_page+0x558>
f01026e5:	68 da 77 10 f0       	push   $0xf01077da
f01026ea:	68 85 75 10 f0       	push   $0xf0107585
f01026ef:	68 1e 04 00 00       	push   $0x41e
f01026f4:	68 58 75 10 f0       	push   $0xf0107558
f01026f9:	e8 a3 db ff ff       	call   f01002a1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026fe:	6a 02                	push   $0x2
f0102700:	68 00 00 40 00       	push   $0x400000
f0102705:	57                   	push   %edi
f0102706:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f010270c:	e8 15 ec ff ff       	call   f0101326 <page_insert>
f0102711:	83 c4 10             	add    $0x10,%esp
f0102714:	85 c0                	test   %eax,%eax
f0102716:	78 19                	js     f0102731 <check_page+0x58b>
f0102718:	68 b4 72 10 f0       	push   $0xf01072b4
f010271d:	68 85 75 10 f0       	push   $0xf0107585
f0102722:	68 21 04 00 00       	push   $0x421
f0102727:	68 58 75 10 f0       	push   $0xf0107558
f010272c:	e8 70 db ff ff       	call   f01002a1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102731:	6a 02                	push   $0x2
f0102733:	68 00 10 00 00       	push   $0x1000
f0102738:	53                   	push   %ebx
f0102739:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f010273f:	e8 e2 eb ff ff       	call   f0101326 <page_insert>
f0102744:	83 c4 10             	add    $0x10,%esp
f0102747:	85 c0                	test   %eax,%eax
f0102749:	74 19                	je     f0102764 <check_page+0x5be>
f010274b:	68 ec 72 10 f0       	push   $0xf01072ec
f0102750:	68 85 75 10 f0       	push   $0xf0107585
f0102755:	68 24 04 00 00       	push   $0x424
f010275a:	68 58 75 10 f0       	push   $0xf0107558
f010275f:	e8 3d db ff ff       	call   f01002a1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102764:	83 ec 04             	sub    $0x4,%esp
f0102767:	6a 00                	push   $0x0
f0102769:	68 00 10 00 00       	push   $0x1000
f010276e:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102774:	e8 0e ea ff ff       	call   f0101187 <pgdir_walk>
f0102779:	83 c4 10             	add    $0x10,%esp
f010277c:	f6 00 04             	testb  $0x4,(%eax)
f010277f:	74 19                	je     f010279a <check_page+0x5f4>
f0102781:	68 28 73 10 f0       	push   $0xf0107328
f0102786:	68 85 75 10 f0       	push   $0xf0107585
f010278b:	68 25 04 00 00       	push   $0x425
f0102790:	68 58 75 10 f0       	push   $0xf0107558
f0102795:	e8 07 db ff ff       	call   f01002a1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010279a:	83 ec 08             	sub    $0x8,%esp
f010279d:	6a 00                	push   $0x0
f010279f:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01027a5:	e8 7e f9 ff ff       	call   f0102128 <check_va2pa>
f01027aa:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f01027ad:	89 da                	mov    %ebx,%edx
f01027af:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f01027b5:	c1 fa 03             	sar    $0x3,%edx
f01027b8:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01027bb:	39 d0                	cmp    %edx,%eax
f01027bd:	74 19                	je     f01027d8 <check_page+0x632>
f01027bf:	68 60 73 10 f0       	push   $0xf0107360
f01027c4:	68 85 75 10 f0       	push   $0xf0107585
f01027c9:	68 28 04 00 00       	push   $0x428
f01027ce:	68 58 75 10 f0       	push   $0xf0107558
f01027d3:	e8 c9 da ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027d8:	83 ec 08             	sub    $0x8,%esp
f01027db:	68 00 10 00 00       	push   $0x1000
f01027e0:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01027e6:	e8 3d f9 ff ff       	call   f0102128 <check_va2pa>
f01027eb:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f01027ee:	89 da                	mov    %ebx,%edx
f01027f0:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f01027f6:	c1 fa 03             	sar    $0x3,%edx
f01027f9:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01027fc:	39 d0                	cmp    %edx,%eax
f01027fe:	74 19                	je     f0102819 <check_page+0x673>
f0102800:	68 8c 73 10 f0       	push   $0xf010738c
f0102805:	68 85 75 10 f0       	push   $0xf0107585
f010280a:	68 29 04 00 00       	push   $0x429
f010280f:	68 58 75 10 f0       	push   $0xf0107558
f0102814:	e8 88 da ff ff       	call   f01002a1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102819:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010281e:	74 19                	je     f0102839 <check_page+0x693>
f0102820:	68 f0 77 10 f0       	push   $0xf01077f0
f0102825:	68 85 75 10 f0       	push   $0xf0107585
f010282a:	68 2b 04 00 00       	push   $0x42b
f010282f:	68 58 75 10 f0       	push   $0xf0107558
f0102834:	e8 68 da ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 0);
f0102839:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010283e:	74 19                	je     f0102859 <check_page+0x6b3>
f0102840:	68 01 78 10 f0       	push   $0xf0107801
f0102845:	68 85 75 10 f0       	push   $0xf0107585
f010284a:	68 2c 04 00 00       	push   $0x42c
f010284f:	68 58 75 10 f0       	push   $0xf0107558
f0102854:	e8 48 da ff ff       	call   f01002a1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102859:	83 ec 0c             	sub    $0xc,%esp
f010285c:	6a 00                	push   $0x0
f010285e:	e8 18 e8 ff ff       	call   f010107b <page_alloc>
f0102863:	83 c4 10             	add    $0x10,%esp
f0102866:	85 c0                	test   %eax,%eax
f0102868:	74 04                	je     f010286e <check_page+0x6c8>
f010286a:	39 f0                	cmp    %esi,%eax
f010286c:	74 19                	je     f0102887 <check_page+0x6e1>
f010286e:	68 bc 73 10 f0       	push   $0xf01073bc
f0102873:	68 85 75 10 f0       	push   $0xf0107585
f0102878:	68 2f 04 00 00       	push   $0x42f
f010287d:	68 58 75 10 f0       	push   $0xf0107558
f0102882:	e8 1a da ff ff       	call   f01002a1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102887:	83 ec 08             	sub    $0x8,%esp
f010288a:	6a 00                	push   $0x0
f010288c:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102892:	e8 af eb ff ff       	call   f0101446 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102897:	83 c4 08             	add    $0x8,%esp
f010289a:	6a 00                	push   $0x0
f010289c:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01028a2:	e8 81 f8 ff ff       	call   f0102128 <check_va2pa>
f01028a7:	83 c4 10             	add    $0x10,%esp
f01028aa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028ad:	74 19                	je     f01028c8 <check_page+0x722>
f01028af:	68 e0 73 10 f0       	push   $0xf01073e0
f01028b4:	68 85 75 10 f0       	push   $0xf0107585
f01028b9:	68 33 04 00 00       	push   $0x433
f01028be:	68 58 75 10 f0       	push   $0xf0107558
f01028c3:	e8 d9 d9 ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028c8:	83 ec 08             	sub    $0x8,%esp
f01028cb:	68 00 10 00 00       	push   $0x1000
f01028d0:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f01028d6:	e8 4d f8 ff ff       	call   f0102128 <check_va2pa>
f01028db:	83 c4 10             	add    $0x10,%esp
	return (pp - pages) << PGSHIFT;
f01028de:	89 da                	mov    %ebx,%edx
f01028e0:	2b 15 f0 ee 1b f0    	sub    0xf01beef0,%edx
f01028e6:	c1 fa 03             	sar    $0x3,%edx
f01028e9:	c1 e2 0c             	shl    $0xc,%edx
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01028ec:	39 d0                	cmp    %edx,%eax
f01028ee:	74 19                	je     f0102909 <check_page+0x763>
f01028f0:	68 8c 73 10 f0       	push   $0xf010738c
f01028f5:	68 85 75 10 f0       	push   $0xf0107585
f01028fa:	68 34 04 00 00       	push   $0x434
f01028ff:	68 58 75 10 f0       	push   $0xf0107558
f0102904:	e8 98 d9 ff ff       	call   f01002a1 <_panic>
	assert(pp1->pp_ref == 1);
f0102909:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010290e:	74 19                	je     f0102929 <check_page+0x783>
f0102910:	68 a7 77 10 f0       	push   $0xf01077a7
f0102915:	68 85 75 10 f0       	push   $0xf0107585
f010291a:	68 35 04 00 00       	push   $0x435
f010291f:	68 58 75 10 f0       	push   $0xf0107558
f0102924:	e8 78 d9 ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 0);
f0102929:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010292e:	74 19                	je     f0102949 <check_page+0x7a3>
f0102930:	68 01 78 10 f0       	push   $0xf0107801
f0102935:	68 85 75 10 f0       	push   $0xf0107585
f010293a:	68 36 04 00 00       	push   $0x436
f010293f:	68 58 75 10 f0       	push   $0xf0107558
f0102944:	e8 58 d9 ff ff       	call   f01002a1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102949:	83 ec 08             	sub    $0x8,%esp
f010294c:	68 00 10 00 00       	push   $0x1000
f0102951:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102957:	e8 ea ea ff ff       	call   f0101446 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010295c:	83 c4 08             	add    $0x8,%esp
f010295f:	6a 00                	push   $0x0
f0102961:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102967:	e8 bc f7 ff ff       	call   f0102128 <check_va2pa>
f010296c:	83 c4 10             	add    $0x10,%esp
f010296f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102972:	74 19                	je     f010298d <check_page+0x7e7>
f0102974:	68 e0 73 10 f0       	push   $0xf01073e0
f0102979:	68 85 75 10 f0       	push   $0xf0107585
f010297e:	68 3a 04 00 00       	push   $0x43a
f0102983:	68 58 75 10 f0       	push   $0xf0107558
f0102988:	e8 14 d9 ff ff       	call   f01002a1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010298d:	83 ec 08             	sub    $0x8,%esp
f0102990:	68 00 10 00 00       	push   $0x1000
f0102995:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f010299b:	e8 88 f7 ff ff       	call   f0102128 <check_va2pa>
f01029a0:	83 c4 10             	add    $0x10,%esp
f01029a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a6:	74 19                	je     f01029c1 <check_page+0x81b>
f01029a8:	68 04 74 10 f0       	push   $0xf0107404
f01029ad:	68 85 75 10 f0       	push   $0xf0107585
f01029b2:	68 3b 04 00 00       	push   $0x43b
f01029b7:	68 58 75 10 f0       	push   $0xf0107558
f01029bc:	e8 e0 d8 ff ff       	call   f01002a1 <_panic>
	assert(pp1->pp_ref == 0);
f01029c1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029c6:	74 19                	je     f01029e1 <check_page+0x83b>
f01029c8:	68 12 78 10 f0       	push   $0xf0107812
f01029cd:	68 85 75 10 f0       	push   $0xf0107585
f01029d2:	68 3c 04 00 00       	push   $0x43c
f01029d7:	68 58 75 10 f0       	push   $0xf0107558
f01029dc:	e8 c0 d8 ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 0);
f01029e1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01029e6:	74 19                	je     f0102a01 <check_page+0x85b>
f01029e8:	68 01 78 10 f0       	push   $0xf0107801
f01029ed:	68 85 75 10 f0       	push   $0xf0107585
f01029f2:	68 3d 04 00 00       	push   $0x43d
f01029f7:	68 58 75 10 f0       	push   $0xf0107558
f01029fc:	e8 a0 d8 ff ff       	call   f01002a1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a01:	83 ec 0c             	sub    $0xc,%esp
f0102a04:	6a 00                	push   $0x0
f0102a06:	e8 70 e6 ff ff       	call   f010107b <page_alloc>
f0102a0b:	83 c4 10             	add    $0x10,%esp
f0102a0e:	85 c0                	test   %eax,%eax
f0102a10:	74 04                	je     f0102a16 <check_page+0x870>
f0102a12:	39 d8                	cmp    %ebx,%eax
f0102a14:	74 19                	je     f0102a2f <check_page+0x889>
f0102a16:	68 2c 74 10 f0       	push   $0xf010742c
f0102a1b:	68 85 75 10 f0       	push   $0xf0107585
f0102a20:	68 40 04 00 00       	push   $0x440
f0102a25:	68 58 75 10 f0       	push   $0xf0107558
f0102a2a:	e8 72 d8 ff ff       	call   f01002a1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102a2f:	83 ec 0c             	sub    $0xc,%esp
f0102a32:	6a 00                	push   $0x0
f0102a34:	e8 42 e6 ff ff       	call   f010107b <page_alloc>
f0102a39:	83 c4 10             	add    $0x10,%esp
f0102a3c:	85 c0                	test   %eax,%eax
f0102a3e:	74 19                	je     f0102a59 <check_page+0x8b3>
f0102a40:	68 0a 77 10 f0       	push   $0xf010770a
f0102a45:	68 85 75 10 f0       	push   $0xf0107585
f0102a4a:	68 43 04 00 00       	push   $0x443
f0102a4f:	68 58 75 10 f0       	push   $0xf0107558
f0102a54:	e8 48 d8 ff ff       	call   f01002a1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a59:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102a5e:	8b 10                	mov    (%eax),%edx
f0102a60:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102a66:	89 f8                	mov    %edi,%eax
f0102a68:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102a6e:	c1 f8 03             	sar    $0x3,%eax
f0102a71:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102a74:	39 c2                	cmp    %eax,%edx
f0102a76:	74 19                	je     f0102a91 <check_page+0x8eb>
f0102a78:	68 3c 71 10 f0       	push   $0xf010713c
f0102a7d:	68 85 75 10 f0       	push   $0xf0107585
f0102a82:	68 46 04 00 00       	push   $0x446
f0102a87:	68 58 75 10 f0       	push   $0xf0107558
f0102a8c:	e8 10 d8 ff ff       	call   f01002a1 <_panic>
	kern_pgdir[0] = 0;
f0102a91:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102a96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102a9c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102aa1:	74 19                	je     f0102abc <check_page+0x916>
f0102aa3:	68 b8 77 10 f0       	push   $0xf01077b8
f0102aa8:	68 85 75 10 f0       	push   $0xf0107585
f0102aad:	68 48 04 00 00       	push   $0x448
f0102ab2:	68 58 75 10 f0       	push   $0xf0107558
f0102ab7:	e8 e5 d7 ff ff       	call   f01002a1 <_panic>
	pp0->pp_ref = 0;
f0102abc:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102ac2:	83 ec 0c             	sub    $0xc,%esp
f0102ac5:	57                   	push   %edi
f0102ac6:	e8 2d e6 ff ff       	call   f01010f8 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102acb:	83 c4 0c             	add    $0xc,%esp
f0102ace:	6a 01                	push   $0x1
f0102ad0:	68 00 10 40 00       	push   $0x401000
f0102ad5:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102adb:	e8 a7 e6 ff ff       	call   f0101187 <pgdir_walk>
f0102ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0102ae3:	83 c4 10             	add    $0x10,%esp
f0102ae6:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102aeb:	8b 50 04             	mov    0x4(%eax),%edx
f0102aee:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102af4:	89 d0                	mov    %edx,%eax
f0102af6:	c1 e8 0c             	shr    $0xc,%eax
f0102af9:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0102aff:	72 15                	jb     f0102b16 <check_page+0x970>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b01:	52                   	push   %edx
f0102b02:	68 58 6a 10 f0       	push   $0xf0106a58
f0102b07:	68 4f 04 00 00       	push   $0x44f
f0102b0c:	68 58 75 10 f0       	push   $0xf0107558
f0102b11:	e8 8b d7 ff ff       	call   f01002a1 <_panic>
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
f0102b16:	b8 00 10 40 00       	mov    $0x401000,%eax
f0102b1b:	c1 e8 0a             	shr    $0xa,%eax
f0102b1e:	83 e0 04             	and    $0x4,%eax
f0102b21:	8d 84 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%eax
f0102b28:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0102b2b:	74 19                	je     f0102b46 <check_page+0x9a0>
f0102b2d:	68 23 78 10 f0       	push   $0xf0107823
f0102b32:	68 85 75 10 f0       	push   $0xf0107585
f0102b37:	68 50 04 00 00       	push   $0x450
f0102b3c:	68 58 75 10 f0       	push   $0xf0107558
f0102b41:	e8 5b d7 ff ff       	call   f01002a1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102b46:	ba 00 10 40 00       	mov    $0x401000,%edx
f0102b4b:	c1 ea 16             	shr    $0x16,%edx
f0102b4e:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102b53:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	pp0->pp_ref = 0;
f0102b5a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b60:	89 f8                	mov    %edi,%eax
f0102b62:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102b68:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102b6b:	89 c2                	mov    %eax,%edx
f0102b6d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b70:	89 d0                	mov    %edx,%eax
f0102b72:	c1 e8 0c             	shr    $0xc,%eax
f0102b75:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0102b7b:	72 12                	jb     f0102b8f <check_page+0x9e9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b7d:	52                   	push   %edx
f0102b7e:	68 58 6a 10 f0       	push   $0xf0106a58
f0102b83:	6a 56                	push   $0x56
f0102b85:	68 64 75 10 f0       	push   $0xf0107564
f0102b8a:	e8 12 d7 ff ff       	call   f01002a1 <_panic>
f0102b8f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0102b95:	83 ec 04             	sub    $0x4,%esp
f0102b98:	68 00 10 00 00       	push   $0x1000
f0102b9d:	68 ff 00 00 00       	push   $0xff
f0102ba2:	50                   	push   %eax
f0102ba3:	e8 e9 30 00 00       	call   f0105c91 <memset>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
f0102ba8:	89 3c 24             	mov    %edi,(%esp)
f0102bab:	e8 48 e5 ff ff       	call   f01010f8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102bb0:	83 c4 0c             	add    $0xc,%esp
f0102bb3:	6a 01                	push   $0x1
f0102bb5:	6a 00                	push   $0x0
f0102bb7:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102bbd:	e8 c5 e5 ff ff       	call   f0101187 <pgdir_walk>
f0102bc2:	83 c4 10             	add    $0x10,%esp
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bc5:	89 f8                	mov    %edi,%eax
f0102bc7:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102bcd:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102bd0:	89 c2                	mov    %eax,%edx
f0102bd2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bd5:	89 d0                	mov    %edx,%eax
f0102bd7:	c1 e8 0c             	shr    $0xc,%eax
f0102bda:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0102be0:	72 12                	jb     f0102bf4 <check_page+0xa4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102be2:	52                   	push   %edx
f0102be3:	68 58 6a 10 f0       	push   $0xf0106a58
f0102be8:	6a 56                	push   $0x56
f0102bea:	68 64 75 10 f0       	push   $0xf0107564
f0102bef:	e8 ad d6 ff ff       	call   f01002a1 <_panic>
f0102bf4:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0102bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102bfd:	ba 00 00 00 00       	mov    $0x0,%edx
		assert((ptep[i] & PTE_P) == 0);
f0102c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c05:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f0102c09:	74 19                	je     f0102c24 <check_page+0xa7e>
f0102c0b:	68 3b 78 10 f0       	push   $0xf010783b
f0102c10:	68 85 75 10 f0       	push   $0xf0107585
f0102c15:	68 5a 04 00 00       	push   $0x45a
f0102c1a:	68 58 75 10 f0       	push   $0xf0107558
f0102c1f:	e8 7d d6 ff ff       	call   f01002a1 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102c24:	42                   	inc    %edx
f0102c25:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0102c2b:	7e d5                	jle    f0102c02 <check_page+0xa5c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102c2d:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102c32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102c38:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c41:	a3 30 e2 1b f0       	mov    %eax,0xf01be230

	// free the pages we took
	page_free(pp0);
f0102c46:	83 ec 0c             	sub    $0xc,%esp
f0102c49:	57                   	push   %edi
f0102c4a:	e8 a9 e4 ff ff       	call   f01010f8 <page_free>
	page_free(pp1);
f0102c4f:	89 1c 24             	mov    %ebx,(%esp)
f0102c52:	e8 a1 e4 ff ff       	call   f01010f8 <page_free>
	page_free(pp2);
f0102c57:	89 34 24             	mov    %esi,(%esp)
f0102c5a:	e8 99 e4 ff ff       	call   f01010f8 <page_free>

	cprintf("*****************************\n");
f0102c5f:	c7 04 24 18 6f 10 f0 	movl   $0xf0106f18,(%esp)
f0102c66:	e8 67 0d 00 00       	call   f01039d2 <cprintf>
	cprintf("***check_page() succeeded!***\n");
f0102c6b:	c7 04 24 50 74 10 f0 	movl   $0xf0107450,(%esp)
f0102c72:	e8 5b 0d 00 00       	call   f01039d2 <cprintf>
	cprintf("*****************************\n\n");
f0102c77:	c7 04 24 60 6f 10 f0 	movl   $0xf0106f60,(%esp)
f0102c7e:	e8 4f 0d 00 00       	call   f01039d2 <cprintf>
}
f0102c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c86:	5b                   	pop    %ebx
f0102c87:	5e                   	pop    %esi
f0102c88:	5f                   	pop    %edi
f0102c89:	c9                   	leave  
f0102c8a:	c3                   	ret    

f0102c8b <check_page_installed_pgdir>:

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0102c8b:	55                   	push   %ebp
f0102c8c:	89 e5                	mov    %esp,%ebp
f0102c8e:	57                   	push   %edi
f0102c8f:	56                   	push   %esi
f0102c90:	53                   	push   %ebx
f0102c91:	83 ec 18             	sub    $0x18,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c94:	6a 00                	push   $0x0
f0102c96:	e8 e0 e3 ff ff       	call   f010107b <page_alloc>
f0102c9b:	89 c7                	mov    %eax,%edi
f0102c9d:	83 c4 10             	add    $0x10,%esp
f0102ca0:	85 c0                	test   %eax,%eax
f0102ca2:	75 19                	jne    f0102cbd <check_page_installed_pgdir+0x32>
f0102ca4:	68 5f 76 10 f0       	push   $0xf010765f
f0102ca9:	68 85 75 10 f0       	push   $0xf0107585
f0102cae:	68 77 04 00 00       	push   $0x477
f0102cb3:	68 58 75 10 f0       	push   $0xf0107558
f0102cb8:	e8 e4 d5 ff ff       	call   f01002a1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102cbd:	83 ec 0c             	sub    $0xc,%esp
f0102cc0:	6a 00                	push   $0x0
f0102cc2:	e8 b4 e3 ff ff       	call   f010107b <page_alloc>
f0102cc7:	89 c3                	mov    %eax,%ebx
f0102cc9:	83 c4 10             	add    $0x10,%esp
f0102ccc:	85 c0                	test   %eax,%eax
f0102cce:	75 19                	jne    f0102ce9 <check_page_installed_pgdir+0x5e>
f0102cd0:	68 75 76 10 f0       	push   $0xf0107675
f0102cd5:	68 85 75 10 f0       	push   $0xf0107585
f0102cda:	68 78 04 00 00       	push   $0x478
f0102cdf:	68 58 75 10 f0       	push   $0xf0107558
f0102ce4:	e8 b8 d5 ff ff       	call   f01002a1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ce9:	83 ec 0c             	sub    $0xc,%esp
f0102cec:	6a 00                	push   $0x0
f0102cee:	e8 88 e3 ff ff       	call   f010107b <page_alloc>
f0102cf3:	89 c6                	mov    %eax,%esi
f0102cf5:	83 c4 10             	add    $0x10,%esp
f0102cf8:	85 c0                	test   %eax,%eax
f0102cfa:	75 19                	jne    f0102d15 <check_page_installed_pgdir+0x8a>
f0102cfc:	68 8b 76 10 f0       	push   $0xf010768b
f0102d01:	68 85 75 10 f0       	push   $0xf0107585
f0102d06:	68 79 04 00 00       	push   $0x479
f0102d0b:	68 58 75 10 f0       	push   $0xf0107558
f0102d10:	e8 8c d5 ff ff       	call   f01002a1 <_panic>
	page_free(pp0);
f0102d15:	83 ec 0c             	sub    $0xc,%esp
f0102d18:	57                   	push   %edi
f0102d19:	e8 da e3 ff ff       	call   f01010f8 <page_free>
f0102d1e:	83 c4 10             	add    $0x10,%esp
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d21:	89 d8                	mov    %ebx,%eax
f0102d23:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102d29:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102d2c:	89 c2                	mov    %eax,%edx
f0102d2e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d31:	89 d0                	mov    %edx,%eax
f0102d33:	c1 e8 0c             	shr    $0xc,%eax
f0102d36:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0102d3c:	72 12                	jb     f0102d50 <check_page_installed_pgdir+0xc5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d3e:	52                   	push   %edx
f0102d3f:	68 58 6a 10 f0       	push   $0xf0106a58
f0102d44:	6a 56                	push   $0x56
f0102d46:	68 64 75 10 f0       	push   $0xf0107564
f0102d4b:	e8 51 d5 ff ff       	call   f01002a1 <_panic>
f0102d50:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0102d56:	83 ec 04             	sub    $0x4,%esp
f0102d59:	68 00 10 00 00       	push   $0x1000
f0102d5e:	6a 01                	push   $0x1
f0102d60:	50                   	push   %eax
f0102d61:	e8 2b 2f 00 00       	call   f0105c91 <memset>
f0102d66:	83 c4 10             	add    $0x10,%esp
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d69:	89 f0                	mov    %esi,%eax
f0102d6b:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102d71:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102d74:	89 c2                	mov    %eax,%edx
f0102d76:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d79:	89 d0                	mov    %edx,%eax
f0102d7b:	c1 e8 0c             	shr    $0xc,%eax
f0102d7e:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0102d84:	72 12                	jb     f0102d98 <check_page_installed_pgdir+0x10d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d86:	52                   	push   %edx
f0102d87:	68 58 6a 10 f0       	push   $0xf0106a58
f0102d8c:	6a 56                	push   $0x56
f0102d8e:	68 64 75 10 f0       	push   $0xf0107564
f0102d93:	e8 09 d5 ff ff       	call   f01002a1 <_panic>
f0102d98:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0102d9e:	83 ec 04             	sub    $0x4,%esp
f0102da1:	68 00 10 00 00       	push   $0x1000
f0102da6:	6a 02                	push   $0x2
f0102da8:	50                   	push   %eax
f0102da9:	e8 e3 2e 00 00       	call   f0105c91 <memset>
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102dae:	6a 02                	push   $0x2
f0102db0:	68 00 10 00 00       	push   $0x1000
f0102db5:	53                   	push   %ebx
f0102db6:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102dbc:	e8 65 e5 ff ff       	call   f0101326 <page_insert>
	assert(pp1->pp_ref == 1);
f0102dc1:	83 c4 20             	add    $0x20,%esp
f0102dc4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102dc9:	74 19                	je     f0102de4 <check_page_installed_pgdir+0x159>
f0102dcb:	68 a7 77 10 f0       	push   $0xf01077a7
f0102dd0:	68 85 75 10 f0       	push   $0xf0107585
f0102dd5:	68 7e 04 00 00       	push   $0x47e
f0102dda:	68 58 75 10 f0       	push   $0xf0107558
f0102ddf:	e8 bd d4 ff ff       	call   f01002a1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102de4:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102deb:	01 01 01 
f0102dee:	74 19                	je     f0102e09 <check_page_installed_pgdir+0x17e>
f0102df0:	68 70 74 10 f0       	push   $0xf0107470
f0102df5:	68 85 75 10 f0       	push   $0xf0107585
f0102dfa:	68 7f 04 00 00       	push   $0x47f
f0102dff:	68 58 75 10 f0       	push   $0xf0107558
f0102e04:	e8 98 d4 ff ff       	call   f01002a1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102e09:	6a 02                	push   $0x2
f0102e0b:	68 00 10 00 00       	push   $0x1000
f0102e10:	56                   	push   %esi
f0102e11:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102e17:	e8 0a e5 ff ff       	call   f0101326 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e1c:	83 c4 10             	add    $0x10,%esp
f0102e1f:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102e26:	02 02 02 
f0102e29:	74 19                	je     f0102e44 <check_page_installed_pgdir+0x1b9>
f0102e2b:	68 94 74 10 f0       	push   $0xf0107494
f0102e30:	68 85 75 10 f0       	push   $0xf0107585
f0102e35:	68 81 04 00 00       	push   $0x481
f0102e3a:	68 58 75 10 f0       	push   $0xf0107558
f0102e3f:	e8 5d d4 ff ff       	call   f01002a1 <_panic>
	assert(pp2->pp_ref == 1);
f0102e44:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e49:	74 19                	je     f0102e64 <check_page_installed_pgdir+0x1d9>
f0102e4b:	68 c9 77 10 f0       	push   $0xf01077c9
f0102e50:	68 85 75 10 f0       	push   $0xf0107585
f0102e55:	68 82 04 00 00       	push   $0x482
f0102e5a:	68 58 75 10 f0       	push   $0xf0107558
f0102e5f:	e8 3d d4 ff ff       	call   f01002a1 <_panic>
	assert(pp1->pp_ref == 0);
f0102e64:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e69:	74 19                	je     f0102e84 <check_page_installed_pgdir+0x1f9>
f0102e6b:	68 12 78 10 f0       	push   $0xf0107812
f0102e70:	68 85 75 10 f0       	push   $0xf0107585
f0102e75:	68 83 04 00 00       	push   $0x483
f0102e7a:	68 58 75 10 f0       	push   $0xf0107558
f0102e7f:	e8 1d d4 ff ff       	call   f01002a1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e84:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e8b:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e8e:	89 f0                	mov    %esi,%eax
f0102e90:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102e96:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102e99:	89 c2                	mov    %eax,%edx
f0102e9b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e9e:	89 d0                	mov    %edx,%eax
f0102ea0:	c1 e8 0c             	shr    $0xc,%eax
f0102ea3:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0102ea9:	72 12                	jb     f0102ebd <check_page_installed_pgdir+0x232>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eab:	52                   	push   %edx
f0102eac:	68 58 6a 10 f0       	push   $0xf0106a58
f0102eb1:	6a 56                	push   $0x56
f0102eb3:	68 64 75 10 f0       	push   $0xf0107564
f0102eb8:	e8 e4 d3 ff ff       	call   f01002a1 <_panic>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0102ebd:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102ec4:	03 03 03 
f0102ec7:	74 19                	je     f0102ee2 <check_page_installed_pgdir+0x257>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ec9:	68 b8 74 10 f0       	push   $0xf01074b8
f0102ece:	68 85 75 10 f0       	push   $0xf0107585
f0102ed3:	68 85 04 00 00       	push   $0x485
f0102ed8:	68 58 75 10 f0       	push   $0xf0107558
f0102edd:	e8 bf d3 ff ff       	call   f01002a1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ee2:	83 ec 08             	sub    $0x8,%esp
f0102ee5:	68 00 10 00 00       	push   $0x1000
f0102eea:	ff 35 ec ee 1b f0    	pushl  0xf01beeec
f0102ef0:	e8 51 e5 ff ff       	call   f0101446 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ef5:	83 c4 10             	add    $0x10,%esp
f0102ef8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102efd:	74 19                	je     f0102f18 <check_page_installed_pgdir+0x28d>
f0102eff:	68 01 78 10 f0       	push   $0xf0107801
f0102f04:	68 85 75 10 f0       	push   $0xf0107585
f0102f09:	68 87 04 00 00       	push   $0x487
f0102f0e:	68 58 75 10 f0       	push   $0xf0107558
f0102f13:	e8 89 d3 ff ff       	call   f01002a1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f18:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102f1d:	8b 10                	mov    (%eax),%edx
f0102f1f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f25:	89 f8                	mov    %edi,%eax
f0102f27:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0102f2d:	c1 f8 03             	sar    $0x3,%eax
f0102f30:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0102f33:	39 c2                	cmp    %eax,%edx
f0102f35:	74 19                	je     f0102f50 <check_page_installed_pgdir+0x2c5>
f0102f37:	68 3c 71 10 f0       	push   $0xf010713c
f0102f3c:	68 85 75 10 f0       	push   $0xf0107585
f0102f41:	68 8a 04 00 00       	push   $0x48a
f0102f46:	68 58 75 10 f0       	push   $0xf0107558
f0102f4b:	e8 51 d3 ff ff       	call   f01002a1 <_panic>
	kern_pgdir[0] = 0;
f0102f50:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0102f55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102f5b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f60:	74 19                	je     f0102f7b <check_page_installed_pgdir+0x2f0>
f0102f62:	68 b8 77 10 f0       	push   $0xf01077b8
f0102f67:	68 85 75 10 f0       	push   $0xf0107585
f0102f6c:	68 8c 04 00 00       	push   $0x48c
f0102f71:	68 58 75 10 f0       	push   $0xf0107558
f0102f76:	e8 26 d3 ff ff       	call   f01002a1 <_panic>
	pp0->pp_ref = 0;
f0102f7b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// free the pages we took
	page_free(pp0);
f0102f81:	83 ec 0c             	sub    $0xc,%esp
f0102f84:	57                   	push   %edi
f0102f85:	e8 6e e1 ff ff       	call   f01010f8 <page_free>
	
	cprintf("*******************************************\n");
f0102f8a:	c7 04 24 e4 74 10 f0 	movl   $0xf01074e4,(%esp)
f0102f91:	e8 3c 0a 00 00       	call   f01039d2 <cprintf>
	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f96:	c7 04 24 14 75 10 f0 	movl   $0xf0107514,(%esp)
f0102f9d:	e8 30 0a 00 00       	call   f01039d2 <cprintf>
	cprintf("*******************************************\n");
f0102fa2:	c7 04 24 e4 74 10 f0 	movl   $0xf01074e4,(%esp)
f0102fa9:	e8 24 0a 00 00       	call   f01039d2 <cprintf>
}
f0102fae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fb1:	5b                   	pop    %ebx
f0102fb2:	5e                   	pop    %esi
f0102fb3:	5f                   	pop    %edi
f0102fb4:	c9                   	leave  
f0102fb5:	c3                   	ret    
	...

f0102fb8 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102fb8:	55                   	push   %ebp
f0102fb9:	89 e5                	mov    %esp,%ebp
f0102fbb:	56                   	push   %esi
f0102fbc:	53                   	push   %ebx
f0102fbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102fc0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102fc3:	85 c9                	test   %ecx,%ecx
f0102fc5:	75 24                	jne    f0102feb <envid2env+0x33>
		*env_store = curenv;
f0102fc7:	e8 46 34 00 00       	call   f0106412 <cpunum>
f0102fcc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102fd3:	29 c2                	sub    %eax,%edx
f0102fd5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102fd8:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0102fdf:	89 06                	mov    %eax,(%esi)
		return 0;
f0102fe1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fe6:	e9 84 00 00 00       	jmp    f010306f <envid2env+0xb7>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102feb:	89 cb                	mov    %ecx,%ebx
f0102fed:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ff3:	89 d8                	mov    %ebx,%eax
f0102ff5:	c1 e0 05             	shl    $0x5,%eax
f0102ff8:	29 d8                	sub    %ebx,%eax
f0102ffa:	8b 15 38 e2 1b f0    	mov    0xf01be238,%edx
f0103000:	8d 1c 82             	lea    (%edx,%eax,4),%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103003:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103007:	74 05                	je     f010300e <envid2env+0x56>
f0103009:	39 4b 48             	cmp    %ecx,0x48(%ebx)
f010300c:	74 0d                	je     f010301b <envid2env+0x63>
		*env_store = 0;
f010300e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103014:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103019:	eb 54                	jmp    f010306f <envid2env+0xb7>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010301b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010301f:	74 47                	je     f0103068 <envid2env+0xb0>
f0103021:	e8 ec 33 00 00       	call   f0106412 <cpunum>
f0103026:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010302d:	29 c2                	sub    %eax,%edx
f010302f:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103032:	39 1c 95 28 f0 1b f0 	cmp    %ebx,-0xfe40fd8(,%edx,4)
f0103039:	74 2d                	je     f0103068 <envid2env+0xb0>
f010303b:	e8 d2 33 00 00       	call   f0106412 <cpunum>
f0103040:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103047:	29 c2                	sub    %eax,%edx
f0103049:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010304c:	8b 14 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%edx
f0103053:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0103056:	3b 42 48             	cmp    0x48(%edx),%eax
f0103059:	74 0d                	je     f0103068 <envid2env+0xb0>
		*env_store = 0;
f010305b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103061:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103066:	eb 07                	jmp    f010306f <envid2env+0xb7>
	}

	*env_store = e;
f0103068:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010306a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010306f:	5b                   	pop    %ebx
f0103070:	5e                   	pop    %esi
f0103071:	c9                   	leave  
f0103072:	c3                   	ret    

f0103073 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103073:	55                   	push   %ebp
f0103074:	89 e5                	mov    %esp,%ebp
f0103076:	53                   	push   %ebx
f0103077:	83 ec 04             	sub    $0x4,%esp
	// Set up envs array
	// LAB 3: Your code here.
	envs = (struct Env *) UENVS;
f010307a:	c7 05 38 e2 1b f0 00 	movl   $0xeec00000,0xf01be238
f0103081:	00 c0 ee 
	int i;
	for (i = 0; i < NENV; i++) {
f0103084:	bb 00 00 00 00       	mov    $0x0,%ebx
		envs[i].env_id = 0;
f0103089:	89 d8                	mov    %ebx,%eax
f010308b:	c1 e0 05             	shl    $0x5,%eax
f010308e:	29 d8                	sub    %ebx,%eax
f0103090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103097:	a1 38 e2 1b f0       	mov    0xf01be238,%eax
f010309c:	c7 44 02 48 00 00 00 	movl   $0x0,0x48(%edx,%eax,1)
f01030a3:	00 
		envs[i].env_link = NULL;
f01030a4:	a1 38 e2 1b f0       	mov    0xf01be238,%eax
f01030a9:	c7 44 02 44 00 00 00 	movl   $0x0,0x44(%edx,%eax,1)
f01030b0:	00 
		if (env_free_list == NULL) {
f01030b1:	83 3d 3c e2 1b f0 00 	cmpl   $0x0,0xf01be23c
f01030b8:	75 24                	jne    f01030de <env_init+0x6b>
			env_free_list = &envs[i];
f01030ba:	89 d0                	mov    %edx,%eax
f01030bc:	03 05 38 e2 1b f0    	add    0xf01be238,%eax
f01030c2:	a3 3c e2 1b f0       	mov    %eax,0xf01be23c
f01030c7:	eb 26                	jmp    f01030ef <env_init+0x7c>
		} else {
			struct Env *env = env_free_list;
			while (1) {
				if (env->env_link == NULL) {
					env->env_link = &envs[i];
f01030c9:	89 d8                	mov    %ebx,%eax
f01030cb:	c1 e0 05             	shl    $0x5,%eax
f01030ce:	29 d8                	sub    %ebx,%eax
f01030d0:	8b 15 38 e2 1b f0    	mov    0xf01be238,%edx
f01030d6:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01030d9:	89 41 44             	mov    %eax,0x44(%ecx)
					break;
f01030dc:	eb 11                	jmp    f01030ef <env_init+0x7c>
		envs[i].env_id = 0;
		envs[i].env_link = NULL;
		if (env_free_list == NULL) {
			env_free_list = &envs[i];
		} else {
			struct Env *env = env_free_list;
f01030de:	8b 0d 3c e2 1b f0    	mov    0xf01be23c,%ecx
			while (1) {
				if (env->env_link == NULL) {
f01030e4:	83 79 44 00          	cmpl   $0x0,0x44(%ecx)
f01030e8:	74 df                	je     f01030c9 <env_init+0x56>
					env->env_link = &envs[i];
					break;
				}
				env = env->env_link;
f01030ea:	8b 49 44             	mov    0x44(%ecx),%ecx
f01030ed:	eb f5                	jmp    f01030e4 <env_init+0x71>
{
	// Set up envs array
	// LAB 3: Your code here.
	envs = (struct Env *) UENVS;
	int i;
	for (i = 0; i < NENV; i++) {
f01030ef:	43                   	inc    %ebx
f01030f0:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f01030f6:	7e 91                	jle    f0103089 <env_init+0x16>
				env = env->env_link;
			}
		}
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01030f8:	e8 06 00 00 00       	call   f0103103 <env_init_percpu>
}
f01030fd:	83 c4 04             	add    $0x4,%esp
f0103100:	5b                   	pop    %ebx
f0103101:	c9                   	leave  
f0103102:	c3                   	ret    

f0103103 <env_init_percpu>:

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103103:	55                   	push   %ebp
f0103104:	89 e5                	mov    %esp,%ebp
	__asm __volatile("lidt (%0)" : : "r" (p));
}

static __inline void
lgdt(void *p)
{
f0103106:	b8 a8 95 12 f0       	mov    $0xf01295a8,%eax
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010310b:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010310e:	b8 23 00 00 00       	mov    $0x23,%eax
f0103113:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103115:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103117:	b0 10                	mov    $0x10,%al
f0103119:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010311b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010311d:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010311f:	ea 26 31 10 f0 08 00 	ljmp   $0x8,$0xf0103126
}

static __inline void
lldt(uint16_t sel)
{
f0103126:	b0 00                	mov    $0x0,%al
	__asm __volatile("lldt %0" : : "r" (sel));
f0103128:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010312b:	c9                   	leave  
f010312c:	c3                   	ret    

f010312d <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f010312d:	55                   	push   %ebp
f010312e:	89 e5                	mov    %esp,%ebp
f0103130:	53                   	push   %ebx
f0103131:	83 ec 10             	sub    $0x10,%esp
f0103134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103137:	6a 01                	push   $0x1
f0103139:	e8 3d df ff ff       	call   f010107b <page_alloc>
f010313e:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0103141:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103146:	85 c0                	test   %eax,%eax
f0103148:	0f 84 91 00 00 00    	je     f01031df <env_setup_vm+0xb2>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	(p->pp_ref)++;
f010314e:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0103152:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0103158:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f010315b:	89 c2                	mov    %eax,%edx
f010315d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103160:	89 d0                	mov    %edx,%eax
f0103162:	c1 e8 0c             	shr    $0xc,%eax
f0103165:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f010316b:	72 12                	jb     f010317f <env_setup_vm+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010316d:	52                   	push   %edx
f010316e:	68 58 6a 10 f0       	push   $0xf0106a58
f0103173:	6a 56                	push   $0x56
f0103175:	68 64 75 10 f0       	push   $0xf0107564
f010317a:	e8 22 d1 ff ff       	call   f01002a1 <_panic>
f010317f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0103185:	89 43 60             	mov    %eax,0x60(%ebx)
	e->env_pgdir = (pde_t *) page2kva(p); 

	// copying the kernel space of kern_pgdir
	memmove(&e->env_pgdir[PDX(UTOP)], &kern_pgdir[PDX(UTOP)], sizeof(pde_t) * (NPDENTRIES - PDX(UTOP)));
f0103188:	83 ec 04             	sub    $0x4,%esp
f010318b:	68 14 01 00 00       	push   $0x114
f0103190:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
f0103195:	05 ec 0e 00 00       	add    $0xeec,%eax
f010319a:	50                   	push   %eax
f010319b:	8d 82 ec 0e 00 f0    	lea    -0xffff114(%edx),%eax
f01031a1:	50                   	push   %eax
f01031a2:	e8 3d 2b 00 00       	call   f0105ce4 <memmove>
//		e->env_pgdir[i] = kern_pgdir[i];
//	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031a7:	8b 53 60             	mov    0x60(%ebx),%edx
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01031aa:	83 c4 10             	add    $0x10,%esp
f01031ad:	89 d0                	mov    %edx,%eax
	if ((uint32_t)kva < KERNBASE)
f01031af:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01031b5:	77 15                	ja     f01031cc <env_setup_vm+0x9f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031b7:	52                   	push   %edx
f01031b8:	68 7c 6a 10 f0       	push   $0xf0106a7c
f01031bd:	68 d5 00 00 00       	push   $0xd5
f01031c2:	68 81 78 10 f0       	push   $0xf0107881
f01031c7:	e8 d5 d0 ff ff       	call   f01002a1 <_panic>
f01031cc:	05 00 00 00 10       	add    $0x10000000,%eax
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01031d1:	83 c8 05             	or     $0x5,%eax
f01031d4:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	return 0;
f01031da:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01031df:	89 d0                	mov    %edx,%eax
f01031e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031e4:	c9                   	leave  
f01031e5:	c3                   	ret    

f01031e6 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01031e6:	55                   	push   %ebp
f01031e7:	89 e5                	mov    %esp,%ebp
f01031e9:	53                   	push   %ebx
f01031ea:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01031ed:	8b 1d 3c e2 1b f0    	mov    0xf01be23c,%ebx
		return -E_NO_FREE_ENV;
f01031f3:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
{
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01031f8:	85 db                	test   %ebx,%ebx
f01031fa:	0f 84 08 01 00 00    	je     f0103308 <env_alloc+0x122>
		return -E_NO_FREE_ENV;

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
f0103200:	83 ec 0c             	sub    $0xc,%esp
f0103203:	53                   	push   %ebx
f0103204:	e8 24 ff ff ff       	call   f010312d <env_setup_vm>
f0103209:	83 c4 10             	add    $0x10,%esp
		return r;
f010320c:	89 c2                	mov    %eax,%edx

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
f010320e:	85 c0                	test   %eax,%eax
f0103210:	0f 88 f2 00 00 00    	js     f0103308 <env_alloc+0x122>
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103216:	8b 53 48             	mov    0x48(%ebx),%edx
f0103219:	81 c2 00 10 00 00    	add    $0x1000,%edx
	if (generation <= 0)	// Don't create a negative env_id.
f010321f:	81 e2 00 fc ff ff    	and    $0xfffffc00,%edx
f0103225:	7f 05                	jg     f010322c <env_alloc+0x46>
		generation = 1 << ENVGENSHIFT;
f0103227:	ba 00 10 00 00       	mov    $0x1000,%edx
	e->env_id = generation | (e - envs);
f010322c:	89 d8                	mov    %ebx,%eax
f010322e:	2b 05 38 e2 1b f0    	sub    0xf01be238,%eax
f0103234:	c1 f8 02             	sar    $0x2,%eax
f0103237:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f010323d:	09 d0                	or     %edx,%eax
f010323f:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103242:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103245:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103248:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010324f:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103256:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010325d:	83 ec 04             	sub    $0x4,%esp
f0103260:	6a 44                	push   $0x44
f0103262:	6a 00                	push   $0x0
f0103264:	53                   	push   %ebx
f0103265:	e8 27 2a 00 00       	call   f0105c91 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010326a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103270:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103276:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010327c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103283:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103289:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103290:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103297:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010329e:	8b 43 44             	mov    0x44(%ebx),%eax
f01032a1:	a3 3c e2 1b f0       	mov    %eax,0xf01be23c
	*newenv_store = e;
f01032a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032a9:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	cprintf(".%08x. new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032ab:	83 c4 0c             	add    $0xc,%esp
f01032ae:	ff 73 48             	pushl  0x48(%ebx)
f01032b1:	83 ec 08             	sub    $0x8,%esp
f01032b4:	e8 59 31 00 00       	call   f0106412 <cpunum>
f01032b9:	83 c4 08             	add    $0x8,%esp
f01032bc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01032c3:	29 c2                	sub    %eax,%edx
f01032c5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01032c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01032cd:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f01032d4:	00 
f01032d5:	74 21                	je     f01032f8 <env_alloc+0x112>
f01032d7:	83 ec 08             	sub    $0x8,%esp
f01032da:	e8 33 31 00 00       	call   f0106412 <cpunum>
f01032df:	83 c4 08             	add    $0x8,%esp
f01032e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01032e9:	29 c2                	sub    %eax,%edx
f01032eb:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01032ee:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01032f5:	8b 40 48             	mov    0x48(%eax),%eax
f01032f8:	50                   	push   %eax
f01032f9:	68 8c 78 10 f0       	push   $0xf010788c
f01032fe:	e8 cf 06 00 00       	call   f01039d2 <cprintf>

	return 0;
f0103303:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103308:	89 d0                	mov    %edx,%eax
f010330a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010330d:	c9                   	leave  
f010330e:	c3                   	ret    

f010330f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010330f:	55                   	push   %ebp
f0103310:	89 e5                	mov    %esp,%ebp
f0103312:	57                   	push   %edi
f0103313:	56                   	push   %esi
f0103314:	53                   	push   %ebx
f0103315:	83 ec 0c             	sub    $0xc,%esp
f0103318:	8b 45 0c             	mov    0xc(%ebp),%eax
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_base = ROUNDDOWN((uintptr_t)va, PGSIZE);
f010331b:	89 c6                	mov    %eax,%esi
f010331d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uintptr_t va_top  = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0103323:	03 45 10             	add    0x10(%ebp),%eax
f0103326:	05 ff 0f 00 00       	add    $0xfff,%eax
f010332b:	89 c7                	mov    %eax,%edi
f010332d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
			struct Page *newpage = page_alloc(0);
			newpage->pp_ref++;
			assert(newpage != NULL);
			*ptbl_entry = page2pa(newpage) | PTE_W | PTE_U | PTE_P;
		}
		va_base += PGSIZE;	
f0103333:	39 fe                	cmp    %edi,%esi
f0103335:	0f 83 85 00 00 00    	jae    f01033c0 <region_alloc+0xb1>
	//   (Watch out for corner-cases!)
	uintptr_t va_base = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_top  = ROUNDUP((uintptr_t)va + len, PGSIZE);

	while (va_base < va_top) {
		pte_t *ptbl_entry = pgdir_walk(e->env_pgdir, (void *)va_base, 1);
f010333b:	83 ec 04             	sub    $0x4,%esp
f010333e:	6a 01                	push   $0x1
f0103340:	56                   	push   %esi
f0103341:	8b 45 08             	mov    0x8(%ebp),%eax
f0103344:	ff 70 60             	pushl  0x60(%eax)
f0103347:	e8 3b de ff ff       	call   f0101187 <pgdir_walk>
f010334c:	89 c3                	mov    %eax,%ebx
		assert(ptbl_entry != NULL);
f010334e:	83 c4 10             	add    $0x10,%esp
f0103351:	85 c0                	test   %eax,%eax
f0103353:	75 19                	jne    f010336e <region_alloc+0x5f>
f0103355:	68 72 75 10 f0       	push   $0xf0107572
f010335a:	68 85 75 10 f0       	push   $0xf0107585
f010335f:	68 3a 01 00 00       	push   $0x13a
f0103364:	68 81 78 10 f0       	push   $0xf0107881
f0103369:	e8 33 cf ff ff       	call   f01002a1 <_panic>
		if (*ptbl_entry == 0) {
f010336e:	83 38 00             	cmpl   $0x0,(%eax)
f0103371:	75 3f                	jne    f01033b2 <region_alloc+0xa3>
			struct Page *newpage = page_alloc(0);
f0103373:	83 ec 0c             	sub    $0xc,%esp
f0103376:	6a 00                	push   $0x0
f0103378:	e8 fe dc ff ff       	call   f010107b <page_alloc>
			newpage->pp_ref++;
f010337d:	66 ff 40 04          	incw   0x4(%eax)
			assert(newpage != NULL);
f0103381:	83 c4 10             	add    $0x10,%esp
f0103384:	85 c0                	test   %eax,%eax
f0103386:	75 19                	jne    f01033a1 <region_alloc+0x92>
f0103388:	68 a1 78 10 f0       	push   $0xf01078a1
f010338d:	68 85 75 10 f0       	push   $0xf0107585
f0103392:	68 3e 01 00 00       	push   $0x13e
f0103397:	68 81 78 10 f0       	push   $0xf0107881
f010339c:	e8 00 cf ff ff       	call   f01002a1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01033a1:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f01033a7:	c1 f8 03             	sar    $0x3,%eax
f01033aa:	c1 e0 0c             	shl    $0xc,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f01033ad:	83 c8 07             	or     $0x7,%eax
f01033b0:	89 03                	mov    %eax,(%ebx)
			*ptbl_entry = page2pa(newpage) | PTE_W | PTE_U | PTE_P;
		}
		va_base += PGSIZE;	
f01033b2:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01033b8:	39 fe                	cmp    %edi,%esi
f01033ba:	0f 82 7b ff ff ff    	jb     f010333b <region_alloc+0x2c>
	}
}
f01033c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033c3:	5b                   	pop    %ebx
f01033c4:	5e                   	pop    %esi
f01033c5:	5f                   	pop    %edi
f01033c6:	c9                   	leave  
f01033c7:	c3                   	ret    

f01033c8 <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
f01033c8:	55                   	push   %ebp
f01033c9:	89 e5                	mov    %esp,%ebp
f01033cb:	57                   	push   %edi
f01033cc:	56                   	push   %esi
f01033cd:	53                   	push   %ebx
f01033ce:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
}

static __inline uint32_t
rcr3(void)
{
f01033d1:	0f 20 d8             	mov    %cr3,%eax
f01033d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	uint32_t old_cr3 = rcr3();
	struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
f01033d7:	8b 7d 0c             	mov    0xc(%ebp),%edi

	assert(((struct Elf *)binary)->e_magic == ELF_MAGIC);
f01033da:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01033e0:	74 19                	je     f01033fb <load_icode+0x33>
f01033e2:	68 54 78 10 f0       	push   $0xf0107854
f01033e7:	68 85 75 10 f0       	push   $0xf0107585
f01033ec:	68 85 01 00 00       	push   $0x185
f01033f1:	68 81 78 10 f0       	push   $0xf0107881
f01033f6:	e8 a6 ce ff ff       	call   f01002a1 <_panic>

	ph = (struct Proghdr *) (binary + elf->e_phoff); // head of program header table
f01033fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033fe:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;   // tail of program header table entry
f0103401:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103405:	89 f0                	mov    %esi,%eax
f0103407:	c1 e0 05             	shl    $0x5,%eax
f010340a:	8d 34 18             	lea    (%eax,%ebx,1),%esi
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f010340d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103410:	8b 42 60             	mov    0x60(%edx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103413:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103418:	77 15                	ja     f010342f <load_icode+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010341a:	50                   	push   %eax
f010341b:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0103420:	68 89 01 00 00       	push   $0x189
f0103425:	68 81 78 10 f0       	push   $0xf0107881
f010342a:	e8 72 ce ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f010342f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103434:	0f 22 d8             	mov    %eax,%cr3
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++) {
f0103437:	39 f3                	cmp    %esi,%ebx
f0103439:	73 54                	jae    f010348f <load_icode+0xc7>
		if (ph->p_type == ELF_PROG_LOAD) {
f010343b:	83 3b 01             	cmpl   $0x1,(%ebx)
f010343e:	75 48                	jne    f0103488 <load_icode+0xc0>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103440:	83 ec 04             	sub    $0x4,%esp
f0103443:	ff 73 14             	pushl  0x14(%ebx)
f0103446:	ff 73 08             	pushl  0x8(%ebx)
f0103449:	ff 75 08             	pushl  0x8(%ebp)
f010344c:	e8 be fe ff ff       	call   f010330f <region_alloc>

	//		cprintf("from va %p, for %08x\n", (void *)ph->p_va, ph->p_memsz);//deb
			// copying section to ph->p_va, for p_memsz
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103451:	83 c4 0c             	add    $0xc,%esp
f0103454:	ff 73 10             	pushl  0x10(%ebx)
f0103457:	8b 45 0c             	mov    0xc(%ebp),%eax
f010345a:	03 43 04             	add    0x4(%ebx),%eax
f010345d:	50                   	push   %eax
f010345e:	ff 73 08             	pushl  0x8(%ebx)
f0103461:	e8 7e 28 00 00       	call   f0105ce4 <memmove>
			// zero-clear bss segment
			if (ph->p_memsz > ph->p_filesz) {
f0103466:	83 c4 10             	add    $0x10,%esp
f0103469:	8b 53 14             	mov    0x14(%ebx),%edx
f010346c:	3b 53 10             	cmp    0x10(%ebx),%edx
f010346f:	76 17                	jbe    f0103488 <load_icode+0xc0>
				memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103471:	83 ec 04             	sub    $0x4,%esp
f0103474:	8b 43 10             	mov    0x10(%ebx),%eax
f0103477:	29 c2                	sub    %eax,%edx
f0103479:	52                   	push   %edx
f010347a:	6a 00                	push   $0x0
f010347c:	03 43 08             	add    0x8(%ebx),%eax
f010347f:	50                   	push   %eax
f0103480:	e8 0c 28 00 00       	call   f0105c91 <memset>
f0103485:	83 c4 10             	add    $0x10,%esp
	assert(((struct Elf *)binary)->e_magic == ELF_MAGIC);

	ph = (struct Proghdr *) (binary + elf->e_phoff); // head of program header table
	eph = ph + elf->e_phnum;   // tail of program header table entry
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++) {
f0103488:	83 c3 20             	add    $0x20,%ebx
f010348b:	39 f3                	cmp    %esi,%ebx
f010348d:	72 ac                	jb     f010343b <load_icode+0x73>
			}
		} 
	}

	// about entry point 
	e->env_tf.tf_eip = elf->e_entry;
f010348f:	8b 47 18             	mov    0x18(%edi),%eax
f0103492:	8b 55 08             	mov    0x8(%ebp),%edx
f0103495:	89 42 30             	mov    %eax,0x30(%edx)
				
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	struct Page *program_stack = page_alloc(0);
f0103498:	83 ec 0c             	sub    $0xc,%esp
f010349b:	6a 00                	push   $0x0
f010349d:	e8 d9 db ff ff       	call   f010107b <page_alloc>
	page_insert(e->env_pgdir, program_stack, (void *)(USTACKTOP-PGSIZE), (PTE_U | PTE_W | PTE_P));	
f01034a2:	6a 07                	push   $0x7
f01034a4:	68 00 d0 bf ee       	push   $0xeebfd000
f01034a9:	50                   	push   %eax
f01034aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ad:	ff 70 60             	pushl  0x60(%eax)
f01034b0:	e8 71 de ff ff       	call   f0101326 <page_insert>
	return val;
}

static __inline void
lcr3(uint32_t val)
{
f01034b5:	83 c4 20             	add    $0x20,%esp
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01034b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01034bb:	0f 22 da             	mov    %edx,%cr3

	lcr3(old_cr3);
}
f01034be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034c1:	5b                   	pop    %ebx
f01034c2:	5e                   	pop    %esi
f01034c3:	5f                   	pop    %edi
f01034c4:	c9                   	leave  
f01034c5:	c3                   	ret    

f01034c6 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{	
f01034c6:	55                   	push   %ebp
f01034c7:	89 e5                	mov    %esp,%ebp
f01034c9:	53                   	push   %ebx
f01034ca:	83 ec 0c             	sub    $0xc,%esp
f01034cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 3: Your code here.
	struct Env *env = NULL;
f01034d0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	env_alloc(&env, 0);
f01034d7:	6a 00                	push   $0x0
f01034d9:	8d 45 f8             	lea    -0x8(%ebp),%eax
f01034dc:	50                   	push   %eax
f01034dd:	e8 04 fd ff ff       	call   f01031e6 <env_alloc>
	assert(env > 0);
f01034e2:	83 c4 10             	add    $0x10,%esp
f01034e5:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f01034e9:	75 19                	jne    f0103504 <env_create+0x3e>
f01034eb:	68 b1 78 10 f0       	push   $0xf01078b1
f01034f0:	68 85 75 10 f0       	push   $0xf0107585
f01034f5:	68 b1 01 00 00       	push   $0x1b1
f01034fa:	68 81 78 10 f0       	push   $0xf0107881
f01034ff:	e8 9d cd ff ff       	call   f01002a1 <_panic>
	load_icode(env, binary, size); 
f0103504:	83 ec 04             	sub    $0x4,%esp
f0103507:	ff 75 0c             	pushl  0xc(%ebp)
f010350a:	ff 75 08             	pushl  0x8(%ebp)
f010350d:	ff 75 f8             	pushl  -0x8(%ebp)
f0103510:	e8 b3 fe ff ff       	call   f01033c8 <load_icode>
	env->env_type = type;
f0103515:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0103518:	89 58 50             	mov    %ebx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS) 
f010351b:	83 c4 10             	add    $0x10,%esp
f010351e:	83 fb 02             	cmp    $0x2,%ebx
f0103521:	75 0a                	jne    f010352d <env_create+0x67>
		env->env_tf.tf_eflags |= FL_IOPL_MASK;	
f0103523:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0103526:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f010352d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103530:	c9                   	leave  
f0103531:	c3                   	ret    

f0103532 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103532:	55                   	push   %ebp
f0103533:	89 e5                	mov    %esp,%ebp
f0103535:	57                   	push   %edi
f0103536:	56                   	push   %esi
f0103537:	53                   	push   %ebx
f0103538:	83 ec 0c             	sub    $0xc,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010353b:	e8 d2 2e 00 00       	call   f0106412 <cpunum>
f0103540:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103547:	29 c2                	sub    %eax,%edx
f0103549:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010354c:	8b 45 08             	mov    0x8(%ebp),%eax
f010354f:	39 04 95 28 f0 1b f0 	cmp    %eax,-0xfe40fd8(,%edx,4)
f0103556:	75 29                	jne    f0103581 <env_free+0x4f>
f0103558:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
	if ((uint32_t)kva < KERNBASE)
f010355d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103562:	77 15                	ja     f0103579 <env_free+0x47>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103564:	50                   	push   %eax
f0103565:	68 7c 6a 10 f0       	push   $0xf0106a7c
f010356a:	68 c9 01 00 00       	push   $0x1c9
f010356f:	68 81 78 10 f0       	push   $0xf0107881
f0103574:	e8 28 cd ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0103579:	05 00 00 00 10       	add    $0x10000000,%eax
f010357e:	0f 22 d8             	mov    %eax,%cr3
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	cprintf(".%08x. free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103581:	83 ec 04             	sub    $0x4,%esp
f0103584:	8b 55 08             	mov    0x8(%ebp),%edx
f0103587:	ff 72 48             	pushl  0x48(%edx)
f010358a:	83 ec 08             	sub    $0x8,%esp
f010358d:	e8 80 2e 00 00       	call   f0106412 <cpunum>
f0103592:	83 c4 08             	add    $0x8,%esp
f0103595:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010359c:	29 c2                	sub    %eax,%edx
f010359e:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01035a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01035a6:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f01035ad:	00 
f01035ae:	74 21                	je     f01035d1 <env_free+0x9f>
f01035b0:	83 ec 08             	sub    $0x8,%esp
f01035b3:	e8 5a 2e 00 00       	call   f0106412 <cpunum>
f01035b8:	83 c4 08             	add    $0x8,%esp
f01035bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01035c2:	29 c2                	sub    %eax,%edx
f01035c4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01035c7:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01035ce:	8b 40 48             	mov    0x48(%eax),%eax
f01035d1:	50                   	push   %eax
f01035d2:	68 b9 78 10 f0       	push   $0xf01078b9
f01035d7:	e8 f6 03 00 00       	call   f01039d2 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
f01035dc:	83 c4 10             	add    $0x10,%esp

	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01035df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01035e6:	8b 55 08             	mov    0x8(%ebp),%edx
f01035e9:	8b 42 60             	mov    0x60(%edx),%eax
f01035ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01035ef:	8b 04 90             	mov    (%eax,%edx,4),%eax
f01035f2:	a8 01                	test   $0x1,%al
f01035f4:	74 73                	je     f0103669 <env_free+0x137>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035f6:	89 c2                	mov    %eax,%edx
f01035f8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035fe:	89 d0                	mov    %edx,%eax
f0103600:	c1 e8 0c             	shr    $0xc,%eax
f0103603:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0103609:	72 15                	jb     f0103620 <env_free+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010360b:	52                   	push   %edx
f010360c:	68 58 6a 10 f0       	push   $0xf0106a58
f0103611:	68 da 01 00 00       	push   $0x1da
f0103616:	68 81 78 10 f0       	push   $0xf0107881
f010361b:	e8 81 cc ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0103620:	8d b2 00 00 00 f0    	lea    -0x10000000(%edx),%esi
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103626:	bb 00 00 00 00       	mov    $0x0,%ebx
f010362b:	8b 7d f0             	mov    -0x10(%ebp),%edi
f010362e:	c1 e7 16             	shl    $0x16,%edi
			if (pt[pteno] & PTE_P) {
f0103631:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f0103635:	74 19                	je     f0103650 <env_free+0x11e>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103637:	83 ec 08             	sub    $0x8,%esp
f010363a:	89 d8                	mov    %ebx,%eax
f010363c:	c1 e0 0c             	shl    $0xc,%eax
f010363f:	09 f8                	or     %edi,%eax
f0103641:	50                   	push   %eax
f0103642:	8b 45 08             	mov    0x8(%ebp),%eax
f0103645:	ff 70 60             	pushl  0x60(%eax)
f0103648:	e8 f9 dd ff ff       	call   f0101446 <page_remove>
f010364d:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103650:	43                   	inc    %ebx
f0103651:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0103657:	76 d8                	jbe    f0103631 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
			}
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103659:	8b 55 08             	mov    0x8(%ebp),%edx
f010365c:	8b 42 60             	mov    0x60(%edx),%eax
f010365f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103662:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	cprintf(".%08x. free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);

	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103669:	ff 45 f0             	incl   -0x10(%ebp)
f010366c:	81 7d f0 ba 03 00 00 	cmpl   $0x3ba,-0x10(%ebp)
f0103673:	0f 86 6d ff ff ff    	jbe    f01035e6 <env_free+0xb4>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0103679:	8b 55 08             	mov    0x8(%ebp),%edx
f010367c:	8b 42 60             	mov    0x60(%edx),%eax
	if ((uint32_t)kva < KERNBASE)
f010367f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103684:	77 15                	ja     f010369b <env_free+0x169>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103686:	50                   	push   %eax
f0103687:	68 7c 6a 10 f0       	push   $0xf0106a7c
f010368c:	68 e9 01 00 00       	push   $0x1e9
f0103691:	68 81 78 10 f0       	push   $0xf0107881
f0103696:	e8 06 cc ff ff       	call   f01002a1 <_panic>
	}


	// free the page directory
	pa = PADDR(e->env_pgdir);
	e->env_pgdir = 0;
f010369b:	8b 55 08             	mov    0x8(%ebp),%edx
f010369e:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (pp - pages) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
f01036a5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
	if (PGNUM(pa) >= npages)
f01036ab:	89 d0                	mov    %edx,%eax
f01036ad:	c1 e8 0c             	shr    $0xc,%eax
f01036b0:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f01036b6:	72 14                	jb     f01036cc <env_free+0x19a>
		panic("pa2page called with invalid pa");
f01036b8:	83 ec 04             	sub    $0x4,%esp
f01036bb:	68 60 6d 10 f0       	push   $0xf0106d60
f01036c0:	6a 4f                	push   $0x4f
f01036c2:	68 64 75 10 f0       	push   $0xf0107564
f01036c7:	e8 d5 cb ff ff       	call   f01002a1 <_panic>
f01036cc:	89 d0                	mov    %edx,%eax
f01036ce:	c1 e8 0c             	shr    $0xc,%eax
f01036d1:	8b 15 f0 ee 1b f0    	mov    0xf01beef0,%edx
f01036d7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return (pp - pages) << PGSHIFT;
}

static inline struct Page*
pa2page(physaddr_t pa)
{
f01036da:	83 ec 0c             	sub    $0xc,%esp
f01036dd:	50                   	push   %eax
f01036de:	e8 82 da ff ff       	call   f0101165 <page_decref>
	page_decref(pa2page(pa));


	// return the environment to the free list
	e->env_status = ENV_FREE;
f01036e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e6:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01036ed:	a1 3c e2 1b f0       	mov    0xf01be23c,%eax
f01036f2:	8b 55 08             	mov    0x8(%ebp),%edx
f01036f5:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f01036f8:	89 15 3c e2 1b f0    	mov    %edx,0xf01be23c
}
f01036fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103701:	5b                   	pop    %ebx
f0103702:	5e                   	pop    %esi
f0103703:	5f                   	pop    %edi
f0103704:	c9                   	leave  
f0103705:	c3                   	ret    

f0103706 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103706:	55                   	push   %ebp
f0103707:	89 e5                	mov    %esp,%ebp
f0103709:	53                   	push   %ebx
f010370a:	83 ec 04             	sub    $0x4,%esp
f010370d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103710:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103714:	75 23                	jne    f0103739 <env_destroy+0x33>
f0103716:	e8 f7 2c 00 00       	call   f0106412 <cpunum>
f010371b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103722:	29 c2                	sub    %eax,%edx
f0103724:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103727:	39 1c 95 28 f0 1b f0 	cmp    %ebx,-0xfe40fd8(,%edx,4)
f010372e:	74 09                	je     f0103739 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103730:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103737:	eb 47                	jmp    f0103780 <env_destroy+0x7a>
	}

	env_free(e);
f0103739:	83 ec 0c             	sub    $0xc,%esp
f010373c:	53                   	push   %ebx
f010373d:	e8 f0 fd ff ff       	call   f0103532 <env_free>

	if (curenv == e) {
f0103742:	e8 cb 2c 00 00       	call   f0106412 <cpunum>
f0103747:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010374e:	29 c2                	sub    %eax,%edx
f0103750:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103753:	83 c4 10             	add    $0x10,%esp
f0103756:	39 1c 95 28 f0 1b f0 	cmp    %ebx,-0xfe40fd8(,%edx,4)
f010375d:	75 21                	jne    f0103780 <env_destroy+0x7a>
		curenv = NULL;
f010375f:	e8 ae 2c 00 00       	call   f0106412 <cpunum>
f0103764:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010376b:	29 c2                	sub    %eax,%edx
f010376d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103770:	c7 04 95 28 f0 1b f0 	movl   $0x0,-0xfe40fd8(,%edx,4)
f0103777:	00 00 00 00 
		sched_yield();
f010377b:	e8 f8 11 00 00       	call   f0104978 <sched_yield>

	// TODO: merge conflict
//	cprintf("Destroyed the only environment - nothing more to do!\n");
//	while (1)
//		monitor(NULL);
}
f0103780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103783:	c9                   	leave  
f0103784:	c3                   	ret    

f0103785 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103785:	55                   	push   %ebp
f0103786:	89 e5                	mov    %esp,%ebp
f0103788:	56                   	push   %esi
f0103789:	53                   	push   %ebx
f010378a:	8b 75 08             	mov    0x8(%ebp),%esi
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010378d:	e8 80 2c 00 00       	call   f0106412 <cpunum>
f0103792:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103799:	29 c2                	sub    %eax,%edx
f010379b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010379e:	8b 1c 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%ebx
f01037a5:	e8 68 2c 00 00       	call   f0106412 <cpunum>
f01037aa:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01037ad:	89 f4                	mov    %esi,%esp
f01037af:	61                   	popa   
f01037b0:	07                   	pop    %es
f01037b1:	1f                   	pop    %ds
f01037b2:	83 c4 08             	add    $0x8,%esp
f01037b5:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01037b6:	83 ec 04             	sub    $0x4,%esp
f01037b9:	68 cf 78 10 f0       	push   $0xf01078cf
f01037be:	68 25 02 00 00       	push   $0x225
f01037c3:	68 81 78 10 f0       	push   $0xf0107881
f01037c8:	e8 d4 ca ff ff       	call   f01002a1 <_panic>

f01037cd <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01037cd:	55                   	push   %ebp
f01037ce:	89 e5                	mov    %esp,%ebp
f01037d0:	53                   	push   %ebx
f01037d1:	83 ec 04             	sub    $0x4,%esp
f01037d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != NULL && (curenv->env_status == ENV_RUNNING)) 
f01037d7:	e8 36 2c 00 00       	call   f0106412 <cpunum>
f01037dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01037e3:	29 c2                	sub    %eax,%edx
f01037e5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01037e8:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f01037ef:	00 
f01037f0:	74 3d                	je     f010382f <env_run+0x62>
f01037f2:	e8 1b 2c 00 00       	call   f0106412 <cpunum>
f01037f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01037fe:	29 c2                	sub    %eax,%edx
f0103800:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103803:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f010380a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010380e:	75 1f                	jne    f010382f <env_run+0x62>
		curenv->env_status = ENV_RUNNABLE;
f0103810:	e8 fd 2b 00 00       	call   f0106412 <cpunum>
f0103815:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010381c:	29 c2                	sub    %eax,%edx
f010381e:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103821:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0103828:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f010382f:	e8 de 2b 00 00       	call   f0106412 <cpunum>
f0103834:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010383b:	29 c2                	sub    %eax,%edx
f010383d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103840:	89 1c 95 28 f0 1b f0 	mov    %ebx,-0xfe40fd8(,%edx,4)
	e->env_status = ENV_RUNNING;
f0103847:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	(e->env_runs)++;	
f010384e:	ff 43 58             	incl   0x58(%ebx)
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0103851:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103854:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103859:	77 15                	ja     f0103870 <env_run+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010385b:	50                   	push   %eax
f010385c:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0103861:	68 48 02 00 00       	push   $0x248
f0103866:	68 81 78 10 f0       	push   $0xf0107881
f010386b:	e8 31 ca ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0103870:	05 00 00 00 10       	add    $0x10000000,%eax
f0103875:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103878:	83 ec 0c             	sub    $0xc,%esp
f010387b:	68 c0 95 12 f0       	push   $0xf01295c0
f0103880:	e8 cc 2d 00 00       	call   f0106651 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103885:	f3 90                	pause  
	lcr3(PADDR(e->env_pgdir)); 
	unlock_kernel();
	// Step2
	env_pop_tf(&(e->env_tf)); 
f0103887:	89 1c 24             	mov    %ebx,(%esp)
f010388a:	e8 f6 fe ff ff       	call   f0103785 <env_pop_tf>
	...

f0103890 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103890:	55                   	push   %ebp
f0103891:	89 e5                	mov    %esp,%ebp
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0103893:	ba 70 00 00 00       	mov    $0x70,%edx
f0103898:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010389b:	ee                   	out    %al,(%dx)
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010389c:	b2 71                	mov    $0x71,%dl
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010389e:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f010389f:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01038a2:	c9                   	leave  
f01038a3:	c3                   	ret    

f01038a4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01038a4:	55                   	push   %ebp
f01038a5:	89 e5                	mov    %esp,%ebp
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038a7:	ba 70 00 00 00       	mov    $0x70,%edx
f01038ac:	8a 45 08             	mov    0x8(%ebp),%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038af:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038b0:	b2 71                	mov    $0x71,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038b2:	8a 45 0c             	mov    0xc(%ebp),%al
f01038b5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01038b6:	c9                   	leave  
f01038b7:	c3                   	ret    

f01038b8 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01038b8:	55                   	push   %ebp
f01038b9:	89 e5                	mov    %esp,%ebp
f01038bb:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f01038be:	c7 05 40 e2 1b f0 01 	movl   $0x1,0xf01be240
f01038c5:	00 00 00 
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038c8:	ba 21 00 00 00       	mov    $0x21,%edx
f01038cd:	b0 ff                	mov    $0xff,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038cf:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038d0:	b2 a1                	mov    $0xa1,%dl
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038d2:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038d3:	b2 20                	mov    $0x20,%dl
f01038d5:	b0 11                	mov    $0x11,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038d7:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038d8:	b2 21                	mov    $0x21,%dl
f01038da:	b0 20                	mov    $0x20,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038dc:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038dd:	b0 04                	mov    $0x4,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038df:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038e0:	b0 03                	mov    $0x3,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038e2:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038e3:	b2 a0                	mov    $0xa0,%dl
f01038e5:	b0 11                	mov    $0x11,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038e7:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038e8:	b2 a1                	mov    $0xa1,%dl
f01038ea:	b0 28                	mov    $0x28,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038ec:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038ed:	b0 02                	mov    $0x2,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038ef:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038f0:	b0 01                	mov    $0x1,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038f2:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038f3:	b2 20                	mov    $0x20,%dl
f01038f5:	b0 68                	mov    $0x68,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038f7:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038f8:	b0 0a                	mov    $0xa,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038fa:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01038fb:	b2 a0                	mov    $0xa0,%dl
f01038fd:	b0 68                	mov    $0x68,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038ff:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0103900:	b0 0a                	mov    $0xa,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103902:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103903:	66 83 3d b0 95 12 f0 	cmpw   $0xffffffff,0xf01295b0
f010390a:	ff 
f010390b:	74 13                	je     f0103920 <pic_init+0x68>
		irq_setmask_8259A(irq_mask_8259A);
f010390d:	83 ec 0c             	sub    $0xc,%esp
f0103910:	0f b7 05 b0 95 12 f0 	movzwl 0xf01295b0,%eax
f0103917:	50                   	push   %eax
f0103918:	e8 05 00 00 00       	call   f0103922 <irq_setmask_8259A>
f010391d:	83 c4 10             	add    $0x10,%esp
}
f0103920:	c9                   	leave  
f0103921:	c3                   	ret    

f0103922 <irq_setmask_8259A>:

void
irq_setmask_8259A(uint16_t mask)
{
f0103922:	55                   	push   %ebp
f0103923:	89 e5                	mov    %esp,%ebp
f0103925:	56                   	push   %esi
f0103926:	53                   	push   %ebx
f0103927:	8b 45 08             	mov    0x8(%ebp),%eax
f010392a:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f010392c:	66 a3 b0 95 12 f0    	mov    %ax,0xf01295b0
	if (!didinit)
f0103932:	83 3d 40 e2 1b f0 00 	cmpl   $0x0,0xf01be240
f0103939:	74 59                	je     f0103994 <irq_setmask_8259A+0x72>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f010393b:	ba 21 00 00 00       	mov    $0x21,%edx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103940:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0103941:	b2 a1                	mov    $0xa1,%dl
f0103943:	89 f0                	mov    %esi,%eax
f0103945:	66 c1 e8 08          	shr    $0x8,%ax
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103949:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010394a:	83 ec 0c             	sub    $0xc,%esp
f010394d:	68 db 78 10 f0       	push   $0xf01078db
f0103952:	e8 7b 00 00 00       	call   f01039d2 <cprintf>
	for (i = 0; i < 16; i++)
f0103957:	bb 00 00 00 00       	mov    $0x0,%ebx
f010395c:	83 c4 10             	add    $0x10,%esp
f010395f:	0f b7 c6             	movzwl %si,%eax
f0103962:	89 c6                	mov    %eax,%esi
f0103964:	f7 d6                	not    %esi
		if (~mask & (1<<i))
f0103966:	89 f0                	mov    %esi,%eax
f0103968:	88 d9                	mov    %bl,%cl
f010396a:	d3 f8                	sar    %cl,%eax
f010396c:	a8 01                	test   $0x1,%al
f010396e:	74 11                	je     f0103981 <irq_setmask_8259A+0x5f>
			cprintf(" %d", i);
f0103970:	83 ec 08             	sub    $0x8,%esp
f0103973:	53                   	push   %ebx
f0103974:	68 82 7f 10 f0       	push   $0xf0107f82
f0103979:	e8 54 00 00 00       	call   f01039d2 <cprintf>
f010397e:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103981:	43                   	inc    %ebx
f0103982:	83 fb 0f             	cmp    $0xf,%ebx
f0103985:	7e df                	jle    f0103966 <irq_setmask_8259A+0x44>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103987:	83 ec 0c             	sub    $0xc,%esp
f010398a:	68 cc 6a 10 f0       	push   $0xf0106acc
f010398f:	e8 3e 00 00 00       	call   f01039d2 <cprintf>
}
f0103994:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103997:	5b                   	pop    %ebx
f0103998:	5e                   	pop    %esi
f0103999:	c9                   	leave  
f010399a:	c3                   	ret    
	...

f010399c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010399c:	55                   	push   %ebp
f010399d:	89 e5                	mov    %esp,%ebp
f010399f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01039a2:	ff 75 08             	pushl  0x8(%ebp)
f01039a5:	e8 8c ce ff ff       	call   f0100836 <cputchar>
	*cnt++;
}
f01039aa:	c9                   	leave  
f01039ab:	c3                   	ret    

f01039ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039ac:	55                   	push   %ebp
f01039ad:	89 e5                	mov    %esp,%ebp
f01039af:	83 ec 08             	sub    $0x8,%esp
	int cnt = 0;
f01039b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039b9:	ff 75 0c             	pushl  0xc(%ebp)
f01039bc:	ff 75 08             	pushl  0x8(%ebp)
f01039bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
f01039c2:	50                   	push   %eax
f01039c3:	68 9c 39 10 f0       	push   $0xf010399c
f01039c8:	e8 d7 1c 00 00       	call   f01056a4 <vprintfmt>
	return cnt;
f01039cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01039d0:	c9                   	leave  
f01039d1:	c3                   	ret    

f01039d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039d2:	55                   	push   %ebp
f01039d3:	89 e5                	mov    %esp,%ebp
f01039d5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039db:	50                   	push   %eax
f01039dc:	ff 75 08             	pushl  0x8(%ebp)
f01039df:	e8 c8 ff ff ff       	call   f01039ac <vcprintf>
	va_end(ap);

	return cnt;
}
f01039e4:	c9                   	leave  
f01039e5:	c3                   	ret    
	...

f01039e8 <trapname>:
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
f01039e8:	55                   	push   %ebp
f01039e9:	89 e5                	mov    %esp,%ebp
f01039eb:	8b 45 08             	mov    0x8(%ebp),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01039ee:	83 f8 13             	cmp    $0x13,%eax
f01039f1:	77 09                	ja     f01039fc <trapname+0x14>
		return excnames[trapno];
f01039f3:	8b 14 85 60 7c 10 f0 	mov    -0xfef83a0(,%eax,4),%edx
f01039fa:	eb 1c                	jmp    f0103a18 <trapname+0x30>
	if (trapno == T_SYSCALL)
		return "System call";
f01039fc:	ba 41 7a 10 f0       	mov    $0xf0107a41,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0103a01:	83 f8 30             	cmp    $0x30,%eax
f0103a04:	74 12                	je     f0103a18 <trapname+0x30>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103a06:	83 e8 20             	sub    $0x20,%eax
		return "Hardware Interrupt";
f0103a09:	ba 4d 7a 10 f0       	mov    $0xf0107a4d,%edx

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103a0e:	83 f8 0f             	cmp    $0xf,%eax
f0103a11:	76 05                	jbe    f0103a18 <trapname+0x30>
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103a13:	ba d9 79 10 f0       	mov    $0xf01079d9,%edx
}
f0103a18:	89 d0                	mov    %edx,%eax
f0103a1a:	c9                   	leave  
f0103a1b:	c3                   	ret    

f0103a1c <trap_init>:


void
trap_init(void)
{
f0103a1c:	55                   	push   %ebp
f0103a1d:	89 e5                	mov    %esp,%ebp
f0103a1f:	83 ec 08             	sub    $0x8,%esp
	extern void irq13_handler();
	extern void irq14_handler();
	extern void irq15_handler();

			
	SETGATE(idt[T_DIVIDE], 0, GD_KT, trap_divide, 0);
f0103a22:	b9 68 48 10 f0       	mov    $0xf0104868,%ecx
f0103a27:	66 89 0d 60 e2 1b f0 	mov    %cx,0xf01be260
f0103a2e:	66 c7 05 62 e2 1b f0 	movw   $0x8,0xf01be262
f0103a35:	08 00 
f0103a37:	a0 64 e2 1b f0       	mov    0xf01be264,%al
f0103a3c:	83 e0 e0             	and    $0xffffffe0,%eax
f0103a3f:	a2 64 e2 1b f0       	mov    %al,0xf01be264
f0103a44:	83 e0 1f             	and    $0x1f,%eax
f0103a47:	a2 64 e2 1b f0       	mov    %al,0xf01be264
f0103a4c:	a0 65 e2 1b f0       	mov    0xf01be265,%al
f0103a51:	83 e0 f0             	and    $0xfffffff0,%eax
f0103a54:	83 c8 0e             	or     $0xe,%eax
f0103a57:	a2 65 e2 1b f0       	mov    %al,0xf01be265
f0103a5c:	88 c2                	mov    %al,%dl
f0103a5e:	83 e2 ef             	and    $0xffffffef,%edx
f0103a61:	88 15 65 e2 1b f0    	mov    %dl,0xf01be265
f0103a67:	83 e0 8f             	and    $0xffffff8f,%eax
f0103a6a:	a2 65 e2 1b f0       	mov    %al,0xf01be265
f0103a6f:	83 c8 80             	or     $0xffffff80,%eax
f0103a72:	a2 65 e2 1b f0       	mov    %al,0xf01be265
f0103a77:	c1 e9 10             	shr    $0x10,%ecx
f0103a7a:	66 89 0d 66 e2 1b f0 	mov    %cx,0xf01be266
	SETGATE(idt[T_DEBUG], 0, GD_KT, trap_debug, 0);
f0103a81:	b9 72 48 10 f0       	mov    $0xf0104872,%ecx
f0103a86:	66 89 0d 68 e2 1b f0 	mov    %cx,0xf01be268
f0103a8d:	66 c7 05 6a e2 1b f0 	movw   $0x8,0xf01be26a
f0103a94:	08 00 
f0103a96:	a0 6c e2 1b f0       	mov    0xf01be26c,%al
f0103a9b:	83 e0 e0             	and    $0xffffffe0,%eax
f0103a9e:	a2 6c e2 1b f0       	mov    %al,0xf01be26c
f0103aa3:	83 e0 1f             	and    $0x1f,%eax
f0103aa6:	a2 6c e2 1b f0       	mov    %al,0xf01be26c
f0103aab:	a0 6d e2 1b f0       	mov    0xf01be26d,%al
f0103ab0:	83 e0 f0             	and    $0xfffffff0,%eax
f0103ab3:	83 c8 0e             	or     $0xe,%eax
f0103ab6:	a2 6d e2 1b f0       	mov    %al,0xf01be26d
f0103abb:	88 c2                	mov    %al,%dl
f0103abd:	83 e2 ef             	and    $0xffffffef,%edx
f0103ac0:	88 15 6d e2 1b f0    	mov    %dl,0xf01be26d
f0103ac6:	83 e0 8f             	and    $0xffffff8f,%eax
f0103ac9:	a2 6d e2 1b f0       	mov    %al,0xf01be26d
f0103ace:	83 c8 80             	or     $0xffffff80,%eax
f0103ad1:	a2 6d e2 1b f0       	mov    %al,0xf01be26d
f0103ad6:	c1 e9 10             	shr    $0x10,%ecx
f0103ad9:	66 89 0d 6e e2 1b f0 	mov    %cx,0xf01be26e
	SETGATE(idt[T_NMI], 0, GD_KT, trap_nmi, 0);
f0103ae0:	b8 7c 48 10 f0       	mov    $0xf010487c,%eax
f0103ae5:	66 a3 70 e2 1b f0    	mov    %ax,0xf01be270
f0103aeb:	66 c7 05 72 e2 1b f0 	movw   $0x8,0xf01be272
f0103af2:	08 00 
f0103af4:	c6 05 74 e2 1b f0 00 	movb   $0x0,0xf01be274
f0103afb:	c6 05 75 e2 1b f0 8e 	movb   $0x8e,0xf01be275
f0103b02:	c1 e8 10             	shr    $0x10,%eax
f0103b05:	66 a3 76 e2 1b f0    	mov    %ax,0xf01be276
	SETGATE(idt[T_BRKPT], 0, GD_KT, trap_brkpt, 3);
f0103b0b:	b8 86 48 10 f0       	mov    $0xf0104886,%eax
f0103b10:	66 a3 78 e2 1b f0    	mov    %ax,0xf01be278
f0103b16:	66 c7 05 7a e2 1b f0 	movw   $0x8,0xf01be27a
f0103b1d:	08 00 
f0103b1f:	c6 05 7c e2 1b f0 00 	movb   $0x0,0xf01be27c
f0103b26:	c6 05 7d e2 1b f0 ee 	movb   $0xee,0xf01be27d
f0103b2d:	c1 e8 10             	shr    $0x10,%eax
f0103b30:	66 a3 7e e2 1b f0    	mov    %ax,0xf01be27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, trap_oflow, 0);
f0103b36:	b8 90 48 10 f0       	mov    $0xf0104890,%eax
f0103b3b:	66 a3 80 e2 1b f0    	mov    %ax,0xf01be280
f0103b41:	66 c7 05 82 e2 1b f0 	movw   $0x8,0xf01be282
f0103b48:	08 00 
f0103b4a:	c6 05 84 e2 1b f0 00 	movb   $0x0,0xf01be284
f0103b51:	c6 05 85 e2 1b f0 8e 	movb   $0x8e,0xf01be285
f0103b58:	c1 e8 10             	shr    $0x10,%eax
f0103b5b:	66 a3 86 e2 1b f0    	mov    %ax,0xf01be286
	SETGATE(idt[T_BOUND], 0, GD_KT, trap_bound, 0);
f0103b61:	b8 9a 48 10 f0       	mov    $0xf010489a,%eax
f0103b66:	66 a3 88 e2 1b f0    	mov    %ax,0xf01be288
f0103b6c:	66 c7 05 8a e2 1b f0 	movw   $0x8,0xf01be28a
f0103b73:	08 00 
f0103b75:	c6 05 8c e2 1b f0 00 	movb   $0x0,0xf01be28c
f0103b7c:	c6 05 8d e2 1b f0 8e 	movb   $0x8e,0xf01be28d
f0103b83:	c1 e8 10             	shr    $0x10,%eax
f0103b86:	66 a3 8e e2 1b f0    	mov    %ax,0xf01be28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, trap_illop, 0);
f0103b8c:	b8 a4 48 10 f0       	mov    $0xf01048a4,%eax
f0103b91:	66 a3 90 e2 1b f0    	mov    %ax,0xf01be290
f0103b97:	66 c7 05 92 e2 1b f0 	movw   $0x8,0xf01be292
f0103b9e:	08 00 
f0103ba0:	c6 05 94 e2 1b f0 00 	movb   $0x0,0xf01be294
f0103ba7:	c6 05 95 e2 1b f0 8e 	movb   $0x8e,0xf01be295
f0103bae:	c1 e8 10             	shr    $0x10,%eax
f0103bb1:	66 a3 96 e2 1b f0    	mov    %ax,0xf01be296
	SETGATE(idt[T_DEVICE], 0, GD_KT, trap_device, 0);
f0103bb7:	b8 ae 48 10 f0       	mov    $0xf01048ae,%eax
f0103bbc:	66 a3 98 e2 1b f0    	mov    %ax,0xf01be298
f0103bc2:	66 c7 05 9a e2 1b f0 	movw   $0x8,0xf01be29a
f0103bc9:	08 00 
f0103bcb:	c6 05 9c e2 1b f0 00 	movb   $0x0,0xf01be29c
f0103bd2:	c6 05 9d e2 1b f0 8e 	movb   $0x8e,0xf01be29d
f0103bd9:	c1 e8 10             	shr    $0x10,%eax
f0103bdc:	66 a3 9e e2 1b f0    	mov    %ax,0xf01be29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, trap_dblflt, 0);
f0103be2:	b8 b8 48 10 f0       	mov    $0xf01048b8,%eax
f0103be7:	66 a3 a0 e2 1b f0    	mov    %ax,0xf01be2a0
f0103bed:	66 c7 05 a2 e2 1b f0 	movw   $0x8,0xf01be2a2
f0103bf4:	08 00 
f0103bf6:	c6 05 a4 e2 1b f0 00 	movb   $0x0,0xf01be2a4
f0103bfd:	c6 05 a5 e2 1b f0 8e 	movb   $0x8e,0xf01be2a5
f0103c04:	c1 e8 10             	shr    $0x10,%eax
f0103c07:	66 a3 a6 e2 1b f0    	mov    %ax,0xf01be2a6
	//SETGATE(idt[T_COPROC], 0, GD_KT, trap_coproc, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, trap_tss, 0);
f0103c0d:	b8 c0 48 10 f0       	mov    $0xf01048c0,%eax
f0103c12:	66 a3 b0 e2 1b f0    	mov    %ax,0xf01be2b0
f0103c18:	66 c7 05 b2 e2 1b f0 	movw   $0x8,0xf01be2b2
f0103c1f:	08 00 
f0103c21:	c6 05 b4 e2 1b f0 00 	movb   $0x0,0xf01be2b4
f0103c28:	c6 05 b5 e2 1b f0 8e 	movb   $0x8e,0xf01be2b5
f0103c2f:	c1 e8 10             	shr    $0x10,%eax
f0103c32:	66 a3 b6 e2 1b f0    	mov    %ax,0xf01be2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, trap_segnp, 0);
f0103c38:	b8 c8 48 10 f0       	mov    $0xf01048c8,%eax
f0103c3d:	66 a3 b8 e2 1b f0    	mov    %ax,0xf01be2b8
f0103c43:	66 c7 05 ba e2 1b f0 	movw   $0x8,0xf01be2ba
f0103c4a:	08 00 
f0103c4c:	c6 05 bc e2 1b f0 00 	movb   $0x0,0xf01be2bc
f0103c53:	c6 05 bd e2 1b f0 8e 	movb   $0x8e,0xf01be2bd
f0103c5a:	c1 e8 10             	shr    $0x10,%eax
f0103c5d:	66 a3 be e2 1b f0    	mov    %ax,0xf01be2be
	SETGATE(idt[T_STACK], 0, GD_KT, trap_stack, 0);
f0103c63:	b8 d0 48 10 f0       	mov    $0xf01048d0,%eax
f0103c68:	66 a3 c0 e2 1b f0    	mov    %ax,0xf01be2c0
f0103c6e:	66 c7 05 c2 e2 1b f0 	movw   $0x8,0xf01be2c2
f0103c75:	08 00 
f0103c77:	c6 05 c4 e2 1b f0 00 	movb   $0x0,0xf01be2c4
f0103c7e:	c6 05 c5 e2 1b f0 8e 	movb   $0x8e,0xf01be2c5
f0103c85:	c1 e8 10             	shr    $0x10,%eax
f0103c88:	66 a3 c6 e2 1b f0    	mov    %ax,0xf01be2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, trap_gpflt, 0);
f0103c8e:	b8 d8 48 10 f0       	mov    $0xf01048d8,%eax
f0103c93:	66 a3 c8 e2 1b f0    	mov    %ax,0xf01be2c8
f0103c99:	66 c7 05 ca e2 1b f0 	movw   $0x8,0xf01be2ca
f0103ca0:	08 00 
f0103ca2:	c6 05 cc e2 1b f0 00 	movb   $0x0,0xf01be2cc
f0103ca9:	c6 05 cd e2 1b f0 8e 	movb   $0x8e,0xf01be2cd
f0103cb0:	c1 e8 10             	shr    $0x10,%eax
f0103cb3:	66 a3 ce e2 1b f0    	mov    %ax,0xf01be2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, trap_pgflt, 0);
f0103cb9:	b8 e0 48 10 f0       	mov    $0xf01048e0,%eax
f0103cbe:	66 a3 d0 e2 1b f0    	mov    %ax,0xf01be2d0
f0103cc4:	66 c7 05 d2 e2 1b f0 	movw   $0x8,0xf01be2d2
f0103ccb:	08 00 
f0103ccd:	c6 05 d4 e2 1b f0 00 	movb   $0x0,0xf01be2d4
f0103cd4:	c6 05 d5 e2 1b f0 8e 	movb   $0x8e,0xf01be2d5
f0103cdb:	c1 e8 10             	shr    $0x10,%eax
f0103cde:	66 a3 d6 e2 1b f0    	mov    %ax,0xf01be2d6
	//SETGATE(idt[T_RES], 0, GD_KT, trap_res, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, trap_fperr, 0);
f0103ce4:	b8 e4 48 10 f0       	mov    $0xf01048e4,%eax
f0103ce9:	66 a3 e0 e2 1b f0    	mov    %ax,0xf01be2e0
f0103cef:	66 c7 05 e2 e2 1b f0 	movw   $0x8,0xf01be2e2
f0103cf6:	08 00 
f0103cf8:	c6 05 e4 e2 1b f0 00 	movb   $0x0,0xf01be2e4
f0103cff:	c6 05 e5 e2 1b f0 8e 	movb   $0x8e,0xf01be2e5
f0103d06:	c1 e8 10             	shr    $0x10,%eax
f0103d09:	66 a3 e6 e2 1b f0    	mov    %ax,0xf01be2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, trap_align, 0);
f0103d0f:	b8 ea 48 10 f0       	mov    $0xf01048ea,%eax
f0103d14:	66 a3 e8 e2 1b f0    	mov    %ax,0xf01be2e8
f0103d1a:	66 c7 05 ea e2 1b f0 	movw   $0x8,0xf01be2ea
f0103d21:	08 00 
f0103d23:	c6 05 ec e2 1b f0 00 	movb   $0x0,0xf01be2ec
f0103d2a:	c6 05 ed e2 1b f0 8e 	movb   $0x8e,0xf01be2ed
f0103d31:	c1 e8 10             	shr    $0x10,%eax
f0103d34:	66 a3 ee e2 1b f0    	mov    %ax,0xf01be2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, trap_mchk, 0);
f0103d3a:	b8 f0 48 10 f0       	mov    $0xf01048f0,%eax
f0103d3f:	66 a3 f0 e2 1b f0    	mov    %ax,0xf01be2f0
f0103d45:	66 c7 05 f2 e2 1b f0 	movw   $0x8,0xf01be2f2
f0103d4c:	08 00 
f0103d4e:	c6 05 f4 e2 1b f0 00 	movb   $0x0,0xf01be2f4
f0103d55:	c6 05 f5 e2 1b f0 8e 	movb   $0x8e,0xf01be2f5
f0103d5c:	c1 e8 10             	shr    $0x10,%eax
f0103d5f:	66 a3 f6 e2 1b f0    	mov    %ax,0xf01be2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, trap_simderr, 0);
f0103d65:	b8 f6 48 10 f0       	mov    $0xf01048f6,%eax
f0103d6a:	66 a3 f8 e2 1b f0    	mov    %ax,0xf01be2f8
f0103d70:	66 c7 05 fa e2 1b f0 	movw   $0x8,0xf01be2fa
f0103d77:	08 00 
f0103d79:	c6 05 fc e2 1b f0 00 	movb   $0x0,0xf01be2fc
f0103d80:	c6 05 fd e2 1b f0 8e 	movb   $0x8e,0xf01be2fd
f0103d87:	c1 e8 10             	shr    $0x10,%eax
f0103d8a:	66 a3 fe e2 1b f0    	mov    %ax,0xf01be2fe

	//Initial system call entry
	SETGATE(idt[T_SYSCALL], 0, GD_KT, trap_syscall, 3);
f0103d90:	b8 fc 48 10 f0       	mov    $0xf01048fc,%eax
f0103d95:	66 a3 e0 e3 1b f0    	mov    %ax,0xf01be3e0
f0103d9b:	66 c7 05 e2 e3 1b f0 	movw   $0x8,0xf01be3e2
f0103da2:	08 00 
f0103da4:	c6 05 e4 e3 1b f0 00 	movb   $0x0,0xf01be3e4
f0103dab:	c6 05 e5 e3 1b f0 ee 	movb   $0xee,0xf01be3e5
f0103db2:	c1 e8 10             	shr    $0x10,%eax
f0103db5:	66 a3 e6 e3 1b f0    	mov    %ax,0xf01be3e6

	//Initial IRQ handlers
	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, irq0_handler, 0);
f0103dbb:	b8 02 49 10 f0       	mov    $0xf0104902,%eax
f0103dc0:	66 a3 60 e3 1b f0    	mov    %ax,0xf01be360
f0103dc6:	66 c7 05 62 e3 1b f0 	movw   $0x8,0xf01be362
f0103dcd:	08 00 
f0103dcf:	c6 05 64 e3 1b f0 00 	movb   $0x0,0xf01be364
f0103dd6:	c6 05 65 e3 1b f0 8e 	movb   $0x8e,0xf01be365
f0103ddd:	c1 e8 10             	shr    $0x10,%eax
f0103de0:	66 a3 66 e3 1b f0    	mov    %ax,0xf01be366
	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, irq1_handler, 0);
f0103de6:	b8 08 49 10 f0       	mov    $0xf0104908,%eax
f0103deb:	66 a3 68 e3 1b f0    	mov    %ax,0xf01be368
f0103df1:	66 c7 05 6a e3 1b f0 	movw   $0x8,0xf01be36a
f0103df8:	08 00 
f0103dfa:	c6 05 6c e3 1b f0 00 	movb   $0x0,0xf01be36c
f0103e01:	c6 05 6d e3 1b f0 8e 	movb   $0x8e,0xf01be36d
f0103e08:	c1 e8 10             	shr    $0x10,%eax
f0103e0b:	66 a3 6e e3 1b f0    	mov    %ax,0xf01be36e
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, irq2_handler, 0);
f0103e11:	b8 0e 49 10 f0       	mov    $0xf010490e,%eax
f0103e16:	66 a3 70 e3 1b f0    	mov    %ax,0xf01be370
f0103e1c:	66 c7 05 72 e3 1b f0 	movw   $0x8,0xf01be372
f0103e23:	08 00 
f0103e25:	c6 05 74 e3 1b f0 00 	movb   $0x0,0xf01be374
f0103e2c:	c6 05 75 e3 1b f0 8e 	movb   $0x8e,0xf01be375
f0103e33:	c1 e8 10             	shr    $0x10,%eax
f0103e36:	66 a3 76 e3 1b f0    	mov    %ax,0xf01be376
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, irq3_handler, 0);
f0103e3c:	b8 14 49 10 f0       	mov    $0xf0104914,%eax
f0103e41:	66 a3 78 e3 1b f0    	mov    %ax,0xf01be378
f0103e47:	66 c7 05 7a e3 1b f0 	movw   $0x8,0xf01be37a
f0103e4e:	08 00 
f0103e50:	c6 05 7c e3 1b f0 00 	movb   $0x0,0xf01be37c
f0103e57:	c6 05 7d e3 1b f0 8e 	movb   $0x8e,0xf01be37d
f0103e5e:	c1 e8 10             	shr    $0x10,%eax
f0103e61:	66 a3 7e e3 1b f0    	mov    %ax,0xf01be37e
	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, irq4_handler, 0);
f0103e67:	b8 20 49 10 f0       	mov    $0xf0104920,%eax
f0103e6c:	66 a3 80 e3 1b f0    	mov    %ax,0xf01be380
f0103e72:	66 c7 05 82 e3 1b f0 	movw   $0x8,0xf01be382
f0103e79:	08 00 
f0103e7b:	c6 05 84 e3 1b f0 00 	movb   $0x0,0xf01be384
f0103e82:	c6 05 85 e3 1b f0 8e 	movb   $0x8e,0xf01be385
f0103e89:	c1 e8 10             	shr    $0x10,%eax
f0103e8c:	66 a3 86 e3 1b f0    	mov    %ax,0xf01be386
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, irq5_handler, 0);
f0103e92:	b8 1a 49 10 f0       	mov    $0xf010491a,%eax
f0103e97:	66 a3 88 e3 1b f0    	mov    %ax,0xf01be388
f0103e9d:	66 c7 05 8a e3 1b f0 	movw   $0x8,0xf01be38a
f0103ea4:	08 00 
f0103ea6:	c6 05 8c e3 1b f0 00 	movb   $0x0,0xf01be38c
f0103ead:	c6 05 8d e3 1b f0 8e 	movb   $0x8e,0xf01be38d
f0103eb4:	c1 e8 10             	shr    $0x10,%eax
f0103eb7:	66 a3 8e e3 1b f0    	mov    %ax,0xf01be38e
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, irq6_handler, 0);
f0103ebd:	b8 26 49 10 f0       	mov    $0xf0104926,%eax
f0103ec2:	66 a3 90 e3 1b f0    	mov    %ax,0xf01be390
f0103ec8:	66 c7 05 92 e3 1b f0 	movw   $0x8,0xf01be392
f0103ecf:	08 00 
f0103ed1:	c6 05 94 e3 1b f0 00 	movb   $0x0,0xf01be394
f0103ed8:	c6 05 95 e3 1b f0 8e 	movb   $0x8e,0xf01be395
f0103edf:	c1 e8 10             	shr    $0x10,%eax
f0103ee2:	66 a3 96 e3 1b f0    	mov    %ax,0xf01be396
	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, irq7_handler, 0);
f0103ee8:	b8 2c 49 10 f0       	mov    $0xf010492c,%eax
f0103eed:	66 a3 98 e3 1b f0    	mov    %ax,0xf01be398
f0103ef3:	66 c7 05 9a e3 1b f0 	movw   $0x8,0xf01be39a
f0103efa:	08 00 
f0103efc:	c6 05 9c e3 1b f0 00 	movb   $0x0,0xf01be39c
f0103f03:	c6 05 9d e3 1b f0 8e 	movb   $0x8e,0xf01be39d
f0103f0a:	c1 e8 10             	shr    $0x10,%eax
f0103f0d:	66 a3 9e e3 1b f0    	mov    %ax,0xf01be39e
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, irq8_handler, 0);
f0103f13:	b8 32 49 10 f0       	mov    $0xf0104932,%eax
f0103f18:	66 a3 a0 e3 1b f0    	mov    %ax,0xf01be3a0
f0103f1e:	66 c7 05 a2 e3 1b f0 	movw   $0x8,0xf01be3a2
f0103f25:	08 00 
f0103f27:	c6 05 a4 e3 1b f0 00 	movb   $0x0,0xf01be3a4
f0103f2e:	c6 05 a5 e3 1b f0 8e 	movb   $0x8e,0xf01be3a5
f0103f35:	c1 e8 10             	shr    $0x10,%eax
f0103f38:	66 a3 a6 e3 1b f0    	mov    %ax,0xf01be3a6
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, irq9_handler, 0);
f0103f3e:	b8 38 49 10 f0       	mov    $0xf0104938,%eax
f0103f43:	66 a3 a8 e3 1b f0    	mov    %ax,0xf01be3a8
f0103f49:	66 c7 05 aa e3 1b f0 	movw   $0x8,0xf01be3aa
f0103f50:	08 00 
f0103f52:	c6 05 ac e3 1b f0 00 	movb   $0x0,0xf01be3ac
f0103f59:	a0 ad e3 1b f0       	mov    0xf01be3ad,%al
f0103f5e:	83 c8 0e             	or     $0xe,%eax
f0103f61:	83 e0 ee             	and    $0xffffffee,%eax
f0103f64:	83 e0 9f             	and    $0xffffff9f,%eax
f0103f67:	83 c8 80             	or     $0xffffff80,%eax
f0103f6a:	a2 ad e3 1b f0       	mov    %al,0xf01be3ad
f0103f6f:	b8 38 49 10 f0       	mov    $0xf0104938,%eax
f0103f74:	c1 e8 10             	shr    $0x10,%eax
f0103f77:	66 a3 ae e3 1b f0    	mov    %ax,0xf01be3ae
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, irq10_handler, 0);
f0103f7d:	b8 3e 49 10 f0       	mov    $0xf010493e,%eax
f0103f82:	66 a3 b0 e3 1b f0    	mov    %ax,0xf01be3b0
f0103f88:	66 c7 05 b2 e3 1b f0 	movw   $0x8,0xf01be3b2
f0103f8f:	08 00 
f0103f91:	c6 05 b4 e3 1b f0 00 	movb   $0x0,0xf01be3b4
f0103f98:	c6 05 b5 e3 1b f0 8e 	movb   $0x8e,0xf01be3b5
f0103f9f:	c1 e8 10             	shr    $0x10,%eax
f0103fa2:	66 a3 b6 e3 1b f0    	mov    %ax,0xf01be3b6
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, irq11_handler, 0);
f0103fa8:	b8 44 49 10 f0       	mov    $0xf0104944,%eax
f0103fad:	66 a3 b8 e3 1b f0    	mov    %ax,0xf01be3b8
f0103fb3:	66 c7 05 ba e3 1b f0 	movw   $0x8,0xf01be3ba
f0103fba:	08 00 
f0103fbc:	c6 05 bc e3 1b f0 00 	movb   $0x0,0xf01be3bc
f0103fc3:	c6 05 bd e3 1b f0 8e 	movb   $0x8e,0xf01be3bd
f0103fca:	c1 e8 10             	shr    $0x10,%eax
f0103fcd:	66 a3 be e3 1b f0    	mov    %ax,0xf01be3be
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, irq12_handler, 0);
f0103fd3:	b8 4a 49 10 f0       	mov    $0xf010494a,%eax
f0103fd8:	66 a3 c0 e3 1b f0    	mov    %ax,0xf01be3c0
f0103fde:	66 c7 05 c2 e3 1b f0 	movw   $0x8,0xf01be3c2
f0103fe5:	08 00 
f0103fe7:	c6 05 c4 e3 1b f0 00 	movb   $0x0,0xf01be3c4
f0103fee:	c6 05 c5 e3 1b f0 8e 	movb   $0x8e,0xf01be3c5
f0103ff5:	c1 e8 10             	shr    $0x10,%eax
f0103ff8:	66 a3 c6 e3 1b f0    	mov    %ax,0xf01be3c6
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, irq13_handler, 0);
f0103ffe:	b8 50 49 10 f0       	mov    $0xf0104950,%eax
f0104003:	66 a3 c8 e3 1b f0    	mov    %ax,0xf01be3c8
f0104009:	66 c7 05 ca e3 1b f0 	movw   $0x8,0xf01be3ca
f0104010:	08 00 
f0104012:	c6 05 cc e3 1b f0 00 	movb   $0x0,0xf01be3cc
f0104019:	c6 05 cd e3 1b f0 8e 	movb   $0x8e,0xf01be3cd
f0104020:	c1 e8 10             	shr    $0x10,%eax
f0104023:	66 a3 ce e3 1b f0    	mov    %ax,0xf01be3ce
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, irq14_handler, 0);
f0104029:	b8 56 49 10 f0       	mov    $0xf0104956,%eax
f010402e:	66 a3 d0 e3 1b f0    	mov    %ax,0xf01be3d0
f0104034:	66 c7 05 d2 e3 1b f0 	movw   $0x8,0xf01be3d2
f010403b:	08 00 
f010403d:	c6 05 d4 e3 1b f0 00 	movb   $0x0,0xf01be3d4
f0104044:	c6 05 d5 e3 1b f0 8e 	movb   $0x8e,0xf01be3d5
f010404b:	c1 e8 10             	shr    $0x10,%eax
f010404e:	66 a3 d6 e3 1b f0    	mov    %ax,0xf01be3d6
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, irq15_handler, 0);
f0104054:	b8 5c 49 10 f0       	mov    $0xf010495c,%eax
f0104059:	66 a3 d8 e3 1b f0    	mov    %ax,0xf01be3d8
f010405f:	66 c7 05 da e3 1b f0 	movw   $0x8,0xf01be3da
f0104066:	08 00 
f0104068:	c6 05 dc e3 1b f0 00 	movb   $0x0,0xf01be3dc
f010406f:	c6 05 dd e3 1b f0 8e 	movb   $0x8e,0xf01be3dd
f0104076:	c1 e8 10             	shr    $0x10,%eax
f0104079:	66 a3 de e3 1b f0    	mov    %ax,0xf01be3de


	// Per-CPU setup 
	trap_init_percpu();
f010407f:	e8 02 00 00 00       	call   f0104086 <trap_init_percpu>
}
f0104084:	c9                   	leave  
f0104085:	c3                   	ret    

f0104086 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104086:	55                   	push   %ebp
f0104087:	89 e5                	mov    %esp,%ebp
f0104089:	57                   	push   %edi
f010408a:	56                   	push   %esi
f010408b:	53                   	push   %ebx
f010408c:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here:
	
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i;
	for (i = 0; i < NCPU; i++) {
f010408f:	be 00 00 00 00       	mov    $0x0,%esi
f0104094:	bf 68 95 12 f0       	mov    $0xf0129568,%edi
		cpus[i].cpu_ts.ts_esp0 = (uintptr_t)percpu_kstacks[cpunum()] + KSTKSIZE;
f0104099:	8d 1c f5 00 00 00 00 	lea    0x0(,%esi,8),%ebx
f01040a0:	29 f3                	sub    %esi,%ebx
f01040a2:	8d 1c 9e             	lea    (%esi,%ebx,4),%ebx
f01040a5:	c1 e3 02             	shl    $0x2,%ebx
f01040a8:	e8 65 23 00 00       	call   f0106412 <cpunum>
f01040ad:	c1 e0 0f             	shl    $0xf,%eax
f01040b0:	05 00 80 1c f0       	add    $0xf01c8000,%eax
f01040b5:	89 83 30 f0 1b f0    	mov    %eax,-0xfe40fd0(%ebx)
		cpus[i].cpu_ts.ts_ss0 = GD_KD;	
f01040bb:	66 c7 83 34 f0 1b f0 	movw   $0x10,-0xfe40fcc(%ebx)
f01040c2:	10 00 
		//	ts.ts_esp0 = KSTACKTOP;
		//	ts.ts_ss0 = GD_KD;

		// Initialize the TSS slot of the gdt.
		gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&cpus[i].cpu_ts),
f01040c4:	66 b8 68 00          	mov    $0x68,%ax
f01040c8:	81 c3 2c f0 1b f0    	add    $0xf01bf02c,%ebx
f01040ce:	89 d9                	mov    %ebx,%ecx
f01040d0:	c1 e1 10             	shl    $0x10,%ecx
f01040d3:	25 ff ff 00 00       	and    $0xffff,%eax
f01040d8:	09 c8                	or     %ecx,%eax
f01040da:	89 d9                	mov    %ebx,%ecx
f01040dc:	c1 e9 10             	shr    $0x10,%ecx
f01040df:	88 ca                	mov    %cl,%dl
f01040e1:	80 e6 f0             	and    $0xf0,%dh
f01040e4:	80 ce 09             	or     $0x9,%dh
f01040e7:	80 ce 10             	or     $0x10,%dh
f01040ea:	80 e6 9f             	and    $0x9f,%dh
f01040ed:	80 ce 80             	or     $0x80,%dh
f01040f0:	81 e2 ff ff f0 ff    	and    $0xfff0ffff,%edx
f01040f6:	81 e2 ff ff ef ff    	and    $0xffefffff,%edx
f01040fc:	81 e2 ff ff df ff    	and    $0xffdfffff,%edx
f0104102:	81 ca 00 00 40 00    	or     $0x400000,%edx
f0104108:	81 e2 ff ff 7f ff    	and    $0xff7fffff,%edx
f010410e:	81 e3 00 00 00 ff    	and    $0xff000000,%ebx
f0104114:	81 e2 ff ff ff 00    	and    $0xffffff,%edx
f010411a:	09 da                	or     %ebx,%edx
f010411c:	89 04 f7             	mov    %eax,(%edi,%esi,8)
f010411f:	89 54 f7 04          	mov    %edx,0x4(%edi,%esi,8)
				sizeof(struct Taskstate), 0);
		gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0104123:	80 64 f7 05 ef       	andb   $0xef,0x5(%edi,%esi,8)
	// LAB 4: Your code here:
	
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i;
	for (i = 0; i < NCPU; i++) {
f0104128:	46                   	inc    %esi
f0104129:	83 fe 07             	cmp    $0x7,%esi
f010412c:	0f 8e 67 ff ff ff    	jle    f0104099 <trap_init_percpu+0x13>
	__asm __volatile("lldt %0" : : "r" (sel));
}

static __inline void
ltr(uint16_t sel)
{
f0104132:	b8 28 00 00 00       	mov    $0x28,%eax
	__asm __volatile("ltr %0" : : "r" (sel));
f0104137:	0f 00 d8             	ltr    %ax
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
}  

static __inline void
lidt(void *p)
{
f010413a:	b8 b4 95 12 f0       	mov    $0xf01295b4,%eax
	__asm __volatile("lidt (%0)" : : "r" (p));
f010413f:	0f 01 18             	lidtl  (%eax)
	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);
	// Load the IDT
	lidt(&idt_pd);
}
f0104142:	83 c4 0c             	add    $0xc,%esp
f0104145:	5b                   	pop    %ebx
f0104146:	5e                   	pop    %esi
f0104147:	5f                   	pop    %edi
f0104148:	c9                   	leave  
f0104149:	c3                   	ret    

f010414a <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f010414a:	55                   	push   %ebp
f010414b:	89 e5                	mov    %esp,%ebp
f010414d:	53                   	push   %ebx
f010414e:	83 ec 14             	sub    $0x14,%esp
f0104151:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104154:	e8 b9 22 00 00       	call   f0106412 <cpunum>
f0104159:	83 c4 0c             	add    $0xc,%esp
f010415c:	50                   	push   %eax
f010415d:	53                   	push   %ebx
f010415e:	68 60 7a 10 f0       	push   $0xf0107a60
f0104163:	e8 6a f8 ff ff       	call   f01039d2 <cprintf>
	print_regs(&tf->tf_regs);
f0104168:	89 1c 24             	mov    %ebx,(%esp)
f010416b:	e8 34 01 00 00       	call   f01042a4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104170:	83 c4 08             	add    $0x8,%esp
f0104173:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104177:	50                   	push   %eax
f0104178:	68 7e 7a 10 f0       	push   $0xf0107a7e
f010417d:	e8 50 f8 ff ff       	call   f01039d2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104182:	83 c4 08             	add    $0x8,%esp
f0104185:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104189:	50                   	push   %eax
f010418a:	68 91 7a 10 f0       	push   $0xf0107a91
f010418f:	e8 3e f8 ff ff       	call   f01039d2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104194:	83 c4 0c             	add    $0xc,%esp
f0104197:	ff 73 28             	pushl  0x28(%ebx)
f010419a:	e8 49 f8 ff ff       	call   f01039e8 <trapname>
f010419f:	89 04 24             	mov    %eax,(%esp)
f01041a2:	ff 73 28             	pushl  0x28(%ebx)
f01041a5:	68 a4 7a 10 f0       	push   $0xf0107aa4
f01041aa:	e8 23 f8 ff ff       	call   f01039d2 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01041af:	83 c4 10             	add    $0x10,%esp
f01041b2:	3b 1d c8 ea 1b f0    	cmp    0xf01beac8,%ebx
f01041b8:	75 1a                	jne    f01041d4 <print_trapframe+0x8a>
f01041ba:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041be:	75 14                	jne    f01041d4 <print_trapframe+0x8a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01041c0:	0f 20 d0             	mov    %cr2,%eax
	return val;
}

static __inline uint32_t
rcr2(void)
{
f01041c3:	83 ec 08             	sub    $0x8,%esp
f01041c6:	50                   	push   %eax
f01041c7:	68 b6 7a 10 f0       	push   $0xf0107ab6
f01041cc:	e8 01 f8 ff ff       	call   f01039d2 <cprintf>
f01041d1:	83 c4 10             	add    $0x10,%esp
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
f01041d4:	83 ec 08             	sub    $0x8,%esp
f01041d7:	ff 73 2c             	pushl  0x2c(%ebx)
f01041da:	68 c5 7a 10 f0       	push   $0xf0107ac5
f01041df:	e8 ee f7 ff ff       	call   f01039d2 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01041e4:	83 c4 10             	add    $0x10,%esp
f01041e7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041eb:	75 42                	jne    f010422f <print_trapframe+0xe5>
		cprintf(" [%s, %s, %s]\n",
f01041ed:	b8 d3 7a 10 f0       	mov    $0xf0107ad3,%eax
f01041f2:	f6 43 2c 01          	testb  $0x1,0x2c(%ebx)
f01041f6:	75 05                	jne    f01041fd <print_trapframe+0xb3>
f01041f8:	b8 de 7a 10 f0       	mov    $0xf0107ade,%eax
f01041fd:	50                   	push   %eax
f01041fe:	b8 ea 7a 10 f0       	mov    $0xf0107aea,%eax
f0104203:	f6 43 2c 02          	testb  $0x2,0x2c(%ebx)
f0104207:	75 05                	jne    f010420e <print_trapframe+0xc4>
f0104209:	b8 f0 7a 10 f0       	mov    $0xf0107af0,%eax
f010420e:	50                   	push   %eax
f010420f:	b8 f5 7a 10 f0       	mov    $0xf0107af5,%eax
f0104214:	f6 43 2c 04          	testb  $0x4,0x2c(%ebx)
f0104218:	75 05                	jne    f010421f <print_trapframe+0xd5>
f010421a:	b8 12 7c 10 f0       	mov    $0xf0107c12,%eax
f010421f:	50                   	push   %eax
f0104220:	68 fa 7a 10 f0       	push   $0xf0107afa
f0104225:	e8 a8 f7 ff ff       	call   f01039d2 <cprintf>
f010422a:	83 c4 10             	add    $0x10,%esp
f010422d:	eb 10                	jmp    f010423f <print_trapframe+0xf5>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010422f:	83 ec 0c             	sub    $0xc,%esp
f0104232:	68 cc 6a 10 f0       	push   $0xf0106acc
f0104237:	e8 96 f7 ff ff       	call   f01039d2 <cprintf>
f010423c:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010423f:	83 ec 08             	sub    $0x8,%esp
f0104242:	ff 73 30             	pushl  0x30(%ebx)
f0104245:	68 09 7b 10 f0       	push   $0xf0107b09
f010424a:	e8 83 f7 ff ff       	call   f01039d2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010424f:	83 c4 08             	add    $0x8,%esp
f0104252:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104256:	50                   	push   %eax
f0104257:	68 18 7b 10 f0       	push   $0xf0107b18
f010425c:	e8 71 f7 ff ff       	call   f01039d2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104261:	83 c4 08             	add    $0x8,%esp
f0104264:	ff 73 38             	pushl  0x38(%ebx)
f0104267:	68 2b 7b 10 f0       	push   $0xf0107b2b
f010426c:	e8 61 f7 ff ff       	call   f01039d2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104271:	83 c4 10             	add    $0x10,%esp
f0104274:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104278:	74 25                	je     f010429f <print_trapframe+0x155>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010427a:	83 ec 08             	sub    $0x8,%esp
f010427d:	ff 73 3c             	pushl  0x3c(%ebx)
f0104280:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0104285:	e8 48 f7 ff ff       	call   f01039d2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010428a:	83 c4 08             	add    $0x8,%esp
f010428d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104291:	50                   	push   %eax
f0104292:	68 49 7b 10 f0       	push   $0xf0107b49
f0104297:	e8 36 f7 ff ff       	call   f01039d2 <cprintf>
f010429c:	83 c4 10             	add    $0x10,%esp
	}
}
f010429f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01042a2:	c9                   	leave  
f01042a3:	c3                   	ret    

f01042a4 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f01042a4:	55                   	push   %ebp
f01042a5:	89 e5                	mov    %esp,%ebp
f01042a7:	53                   	push   %ebx
f01042a8:	83 ec 0c             	sub    $0xc,%esp
f01042ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01042ae:	ff 33                	pushl  (%ebx)
f01042b0:	68 5c 7b 10 f0       	push   $0xf0107b5c
f01042b5:	e8 18 f7 ff ff       	call   f01039d2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01042ba:	83 c4 08             	add    $0x8,%esp
f01042bd:	ff 73 04             	pushl  0x4(%ebx)
f01042c0:	68 6b 7b 10 f0       	push   $0xf0107b6b
f01042c5:	e8 08 f7 ff ff       	call   f01039d2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01042ca:	83 c4 08             	add    $0x8,%esp
f01042cd:	ff 73 08             	pushl  0x8(%ebx)
f01042d0:	68 7a 7b 10 f0       	push   $0xf0107b7a
f01042d5:	e8 f8 f6 ff ff       	call   f01039d2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01042da:	83 c4 08             	add    $0x8,%esp
f01042dd:	ff 73 0c             	pushl  0xc(%ebx)
f01042e0:	68 89 7b 10 f0       	push   $0xf0107b89
f01042e5:	e8 e8 f6 ff ff       	call   f01039d2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01042ea:	83 c4 08             	add    $0x8,%esp
f01042ed:	ff 73 10             	pushl  0x10(%ebx)
f01042f0:	68 98 7b 10 f0       	push   $0xf0107b98
f01042f5:	e8 d8 f6 ff ff       	call   f01039d2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01042fa:	83 c4 08             	add    $0x8,%esp
f01042fd:	ff 73 14             	pushl  0x14(%ebx)
f0104300:	68 a7 7b 10 f0       	push   $0xf0107ba7
f0104305:	e8 c8 f6 ff ff       	call   f01039d2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010430a:	83 c4 08             	add    $0x8,%esp
f010430d:	ff 73 18             	pushl  0x18(%ebx)
f0104310:	68 b6 7b 10 f0       	push   $0xf0107bb6
f0104315:	e8 b8 f6 ff ff       	call   f01039d2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010431a:	83 c4 08             	add    $0x8,%esp
f010431d:	ff 73 1c             	pushl  0x1c(%ebx)
f0104320:	68 c5 7b 10 f0       	push   $0xf0107bc5
f0104325:	e8 a8 f6 ff ff       	call   f01039d2 <cprintf>
}
f010432a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010432d:	c9                   	leave  
f010432e:	c3                   	ret    

f010432f <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f010432f:	55                   	push   %ebp
f0104330:	89 e5                	mov    %esp,%ebp
f0104332:	56                   	push   %esi
f0104333:	53                   	push   %ebx
f0104334:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t eflags;

	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
f0104337:	8b 46 28             	mov    0x28(%esi),%eax
f010433a:	83 e8 03             	sub    $0x3,%eax
f010433d:	83 f8 2d             	cmp    $0x2d,%eax
f0104340:	0f 87 93 00 00 00    	ja     f01043d9 <trap_dispatch+0xaa>
f0104346:	ff 24 85 b0 7c 10 f0 	jmp    *-0xfef8350(,%eax,4)

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010434d:	9c                   	pushf  
f010434e:	5b                   	pop    %ebx
		case T_DEBUG:
		case T_NMI:
			goto unexpected;
		case T_BRKPT:
			eflags = read_eflags();
			cprintf("elfags 0x%08x\n", eflags);
f010434f:	83 ec 08             	sub    $0x8,%esp
f0104352:	53                   	push   %ebx
f0104353:	68 d4 7b 10 f0       	push   $0xf0107bd4
f0104358:	e8 75 f6 ff ff       	call   f01039d2 <cprintf>
			eflags |= FL_RF;
f010435d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
			cprintf("elfags 0x%08x\n", eflags);
f0104363:	83 c4 08             	add    $0x8,%esp
f0104366:	53                   	push   %ebx
f0104367:	68 d4 7b 10 f0       	push   $0xf0107bd4
f010436c:	e8 61 f6 ff ff       	call   f01039d2 <cprintf>
}

static __inline void
write_eflags(uint32_t eflags)
{
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
f0104371:	53                   	push   %ebx
f0104372:	9d                   	popf   
			write_eflags(eflags);
			monitor(tf);
f0104373:	89 34 24             	mov    %esi,(%esp)
f0104376:	e8 23 c7 ff ff       	call   f0100a9e <monitor>
			break;
f010437b:	83 c4 10             	add    $0x10,%esp
f010437e:	e9 a3 00 00 00       	jmp    f0104426 <trap_dispatch+0xf7>
		case T_STACK:
		case T_GPFLT:
			goto unexpected;
		case T_PGFLT:
			//cprintf("trap_dispatch: page fault\n");		
			page_fault_handler(tf);
f0104383:	83 ec 0c             	sub    $0xc,%esp
f0104386:	56                   	push   %esi
f0104387:	e8 3d 02 00 00       	call   f01045c9 <page_fault_handler>
			break;
f010438c:	83 c4 10             	add    $0x10,%esp
f010438f:	e9 92 00 00 00       	jmp    f0104426 <trap_dispatch+0xf7>
		case T_ALIGN:
		case T_MCHK:
		case T_SIMDERR:
			goto unexpected;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0104394:	83 ec 08             	sub    $0x8,%esp
f0104397:	ff 76 04             	pushl  0x4(%esi)
f010439a:	ff 36                	pushl  (%esi)
f010439c:	ff 76 10             	pushl  0x10(%esi)
f010439f:	ff 76 18             	pushl  0x18(%esi)
f01043a2:	ff 76 14             	pushl  0x14(%esi)
f01043a5:	ff 76 1c             	pushl  0x1c(%esi)
f01043a8:	e8 f9 0d 00 00       	call   f01051a6 <syscall>
f01043ad:	89 46 1c             	mov    %eax,0x1c(%esi)
					tf->tf_regs.reg_edx,
					tf->tf_regs.reg_ecx,
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			break;
f01043b0:	83 c4 20             	add    $0x20,%esp
f01043b3:	eb 71                	jmp    f0104426 <trap_dispatch+0xf7>
		// Handle clock interrupts. Don't forget to acknowledge the
		// interrupt using lapic_eoi() before calling the scheduler!
		// LAB 4: Your code here.
		case IRQ_OFFSET + IRQ_TIMER:
//			cprintf("Timer interrupt on irq 0\n");
			lapic_eoi();
f01043b5:	e8 76 20 00 00       	call   f0106430 <lapic_eoi>
			sched_yield();	
f01043ba:	e8 b9 05 00 00       	call   f0104978 <sched_yield>

		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		case IRQ_OFFSET + IRQ_SPURIOUS:
			cprintf("Spurious interrupt on irq 7\n");
f01043bf:	83 ec 0c             	sub    $0xc,%esp
f01043c2:	68 e3 7b 10 f0       	push   $0xf0107be3
f01043c7:	e8 06 f6 ff ff       	call   f01039d2 <cprintf>
			print_trapframe(tf);
f01043cc:	89 34 24             	mov    %esi,(%esp)
f01043cf:	e8 76 fd ff ff       	call   f010414a <print_trapframe>
			break;
f01043d4:	83 c4 10             	add    $0x10,%esp
f01043d7:	eb 4d                	jmp    f0104426 <trap_dispatch+0xf7>

	return;

	// Unexpected trap: The user process or the kernel has a bug.
unexpected:
	print_trapframe(tf);
f01043d9:	83 ec 0c             	sub    $0xc,%esp
f01043dc:	56                   	push   %esi
f01043dd:	e8 68 fd ff ff       	call   f010414a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01043e2:	83 c4 10             	add    $0x10,%esp
f01043e5:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043ea:	75 17                	jne    f0104403 <trap_dispatch+0xd4>
		panic("unhandled trap in kernel");
f01043ec:	83 ec 04             	sub    $0x4,%esp
f01043ef:	68 00 7c 10 f0       	push   $0xf0107c00
f01043f4:	68 59 01 00 00       	push   $0x159
f01043f9:	68 19 7c 10 f0       	push   $0xf0107c19
f01043fe:	e8 9e be ff ff       	call   f01002a1 <_panic>
	else {
		env_destroy(curenv);
f0104403:	83 ec 10             	sub    $0x10,%esp
f0104406:	e8 07 20 00 00       	call   f0106412 <cpunum>
f010440b:	83 c4 04             	add    $0x4,%esp
f010440e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104415:	29 c2                	sub    %eax,%edx
f0104417:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010441a:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104421:	e8 e0 f2 ff ff       	call   f0103706 <env_destroy>
		return;
	}
}
f0104426:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104429:	5b                   	pop    %ebx
f010442a:	5e                   	pop    %esi
f010442b:	c9                   	leave  
f010442c:	c3                   	ret    

f010442d <trap>:

void
trap(struct Trapframe *tf)
{
f010442d:	55                   	push   %ebp
f010442e:	89 e5                	mov    %esp,%ebp
f0104430:	53                   	push   %ebx
f0104431:	83 ec 04             	sub    $0x4,%esp
f0104434:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104437:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104438:	83 3d e0 ee 1b f0 00 	cmpl   $0x0,0xf01beee0
f010443f:	74 01                	je     f0104442 <trap+0x15>
		asm volatile("hlt");
f0104441:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104442:	9c                   	pushf  
f0104443:	58                   	pop    %eax
	__asm __volatile("movl %0,%%cr3" : : "r" (cr3));
}

static __inline uint32_t
read_eflags(void)
{
f0104444:	f6 c4 02             	test   $0x2,%ah
f0104447:	74 19                	je     f0104462 <trap+0x35>

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104449:	68 25 7c 10 f0       	push   $0xf0107c25
f010444e:	68 85 75 10 f0       	push   $0xf0107585
f0104453:	68 6f 01 00 00       	push   $0x16f
f0104458:	68 19 7c 10 f0       	push   $0xf0107c19
f010445d:	e8 3f be ff ff       	call   f01002a1 <_panic>

//	cprintf("Incoming TRAP frame at %p\n", tf);
//	cprintf("errno: %x\n", tf->tf_trapno);

	if ((tf->tf_cs & 3) == 3) {
f0104462:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104466:	83 e0 03             	and    $0x3,%eax
f0104469:	83 f8 03             	cmp    $0x3,%eax
f010446c:	0f 85 e4 00 00 00    	jne    f0104556 <trap+0x129>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104472:	83 ec 0c             	sub    $0xc,%esp
f0104475:	68 c0 95 12 f0       	push   $0xf01295c0
f010447a:	e8 59 21 00 00       	call   f01065d8 <spin_lock>
f010447f:	83 c4 10             	add    $0x10,%esp
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104482:	e8 8b 1f 00 00       	call   f0106412 <cpunum>
f0104487:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010448e:	29 c2                	sub    %eax,%edx
f0104490:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104493:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f010449a:	00 
f010449b:	75 19                	jne    f01044b6 <trap+0x89>
f010449d:	68 3e 7c 10 f0       	push   $0xf0107c3e
f01044a2:	68 85 75 10 f0       	push   $0xf0107585
f01044a7:	68 7a 01 00 00       	push   $0x17a
f01044ac:	68 19 7c 10 f0       	push   $0xf0107c19
f01044b1:	e8 eb bd ff ff       	call   f01002a1 <_panic>
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01044b6:	e8 57 1f 00 00       	call   f0106412 <cpunum>
f01044bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044c2:	29 c2                	sub    %eax,%edx
f01044c4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01044c7:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01044ce:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01044d2:	75 44                	jne    f0104518 <trap+0xeb>
			env_free(curenv);
f01044d4:	83 ec 10             	sub    $0x10,%esp
f01044d7:	e8 36 1f 00 00       	call   f0106412 <cpunum>
f01044dc:	83 c4 04             	add    $0x4,%esp
f01044df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044e6:	29 c2                	sub    %eax,%edx
f01044e8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01044eb:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f01044f2:	e8 3b f0 ff ff       	call   f0103532 <env_free>
			curenv = NULL;
f01044f7:	e8 16 1f 00 00       	call   f0106412 <cpunum>
f01044fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104503:	29 c2                	sub    %eax,%edx
f0104505:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104508:	c7 04 95 28 f0 1b f0 	movl   $0x0,-0xfe40fd8(,%edx,4)
f010450f:	00 00 00 00 
			sched_yield();
f0104513:	e8 60 04 00 00       	call   f0104978 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104518:	e8 f5 1e 00 00       	call   f0106412 <cpunum>
f010451d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104524:	29 c2                	sub    %eax,%edx
f0104526:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104529:	83 ec 04             	sub    $0x4,%esp
f010452c:	6a 44                	push   $0x44
f010452e:	53                   	push   %ebx
f010452f:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104536:	e8 15 18 00 00       	call   f0105d50 <memcpy>
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;	
f010453b:	e8 d2 1e 00 00       	call   f0106412 <cpunum>
f0104540:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104547:	29 c2                	sub    %eax,%edx
f0104549:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010454c:	8b 1c 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%ebx
f0104553:	83 c4 10             	add    $0x10,%esp
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104556:	89 1d c8 ea 1b f0    	mov    %ebx,0xf01beac8

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f010455c:	83 ec 0c             	sub    $0xc,%esp
f010455f:	53                   	push   %ebx
f0104560:	e8 ca fd ff ff       	call   f010432f <trap_dispatch>

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) 
f0104565:	e8 a8 1e 00 00       	call   f0106412 <cpunum>
f010456a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104571:	29 c2                	sub    %eax,%edx
f0104573:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104576:	83 c4 10             	add    $0x10,%esp
f0104579:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f0104580:	00 
f0104581:	74 41                	je     f01045c4 <trap+0x197>
f0104583:	e8 8a 1e 00 00       	call   f0106412 <cpunum>
f0104588:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010458f:	29 c2                	sub    %eax,%edx
f0104591:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104594:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f010459b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010459f:	75 23                	jne    f01045c4 <trap+0x197>
		env_run(curenv);
f01045a1:	83 ec 10             	sub    $0x10,%esp
f01045a4:	e8 69 1e 00 00       	call   f0106412 <cpunum>
f01045a9:	83 c4 04             	add    $0x4,%esp
f01045ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045b3:	29 c2                	sub    %eax,%edx
f01045b5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01045b8:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f01045bf:	e8 09 f2 ff ff       	call   f01037cd <env_run>
	else
		sched_yield();
f01045c4:	e8 af 03 00 00       	call   f0104978 <sched_yield>

f01045c9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045c9:	55                   	push   %ebp
f01045ca:	89 e5                	mov    %esp,%ebp
f01045cc:	57                   	push   %edi
f01045cd:	56                   	push   %esi
f01045ce:	53                   	push   %ebx
f01045cf:	83 ec 0c             	sub    $0xc,%esp
	return val;
}

static __inline uint32_t
rcr2(void)
{
f01045d2:	0f 20 d6             	mov    %cr2,%esi
	//user_mem_assert(curenv, (void *)fault_va, PGSIZE, PTE_P); //What's this??ToDo

	// Handle kernel-mode page faults.
	// determine whether a fault happened in user or kernel mode 
	// check the low 2 bits of cs
	if ((tf->tf_cs & 0x0003) == 0)
f01045d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01045d8:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f01045dc:	75 17                	jne    f01045f5 <page_fault_handler+0x2c>
		panic("page fault happened in kernel mode!");
f01045de:	83 ec 04             	sub    $0x4,%esp
f01045e1:	68 68 7d 10 f0       	push   $0xf0107d68
f01045e6:	68 ab 01 00 00       	push   $0x1ab
f01045eb:	68 19 7c 10 f0       	push   $0xf0107c19
f01045f0:	e8 ac bc ff ff       	call   f01002a1 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {	
f01045f5:	e8 18 1e 00 00       	call   f0106412 <cpunum>
f01045fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104601:	29 c2                	sub    %eax,%edx
f0104603:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104606:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f010460d:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104611:	0f 84 ea 01 00 00    	je     f0104801 <page_fault_handler+0x238>
	//	cprintf("upcall found\n"); //deb
		// some checkings
		user_mem_assert(curenv, (void *)(UXSTACKTOP-PGSIZE), PGSIZE, PTE_W);
f0104617:	6a 02                	push   $0x2
f0104619:	68 00 10 00 00       	push   $0x1000
f010461e:	68 00 f0 bf ee       	push   $0xeebff000
f0104623:	83 ec 04             	sub    $0x4,%esp
f0104626:	e8 e7 1d 00 00       	call   f0106412 <cpunum>
f010462b:	83 c4 04             	add    $0x4,%esp
f010462e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104635:	29 c2                	sub    %eax,%edx
f0104637:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010463a:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104641:	e8 5a cf ff ff       	call   f01015a0 <user_mem_assert>
		if (!page_lookup(curenv->env_pgdir, (void *)(UXSTACKTOP-PGSIZE), NULL))
f0104646:	83 c4 0c             	add    $0xc,%esp
f0104649:	6a 00                	push   $0x0
f010464b:	68 00 f0 bf ee       	push   $0xeebff000
f0104650:	83 ec 04             	sub    $0x4,%esp
f0104653:	e8 ba 1d 00 00       	call   f0106412 <cpunum>
f0104658:	83 c4 04             	add    $0x4,%esp
f010465b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104662:	29 c2                	sub    %eax,%edx
f0104664:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104667:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f010466e:	ff 70 60             	pushl  0x60(%eax)
f0104671:	e8 72 cd ff ff       	call   f01013e8 <page_lookup>
f0104676:	83 c4 10             	add    $0x10,%esp
f0104679:	85 c0                	test   %eax,%eax
f010467b:	75 26                	jne    f01046a3 <page_fault_handler+0xda>
			env_destroy(curenv);
f010467d:	83 ec 10             	sub    $0x10,%esp
f0104680:	e8 8d 1d 00 00       	call   f0106412 <cpunum>
f0104685:	83 c4 04             	add    $0x4,%esp
f0104688:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010468f:	29 c2                	sub    %eax,%edx
f0104691:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104694:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f010469b:	e8 66 f0 ff ff       	call   f0103706 <env_destroy>
f01046a0:	83 c4 10             	add    $0x10,%esp

		void *dststack;
		// if this is recursive call to pgfault_upcall, make some space
		if (tf->tf_esp >= (UXSTACKTOP-PGSIZE) && tf->tf_esp < UXSTACKTOP) 
f01046a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01046a6:	8b 50 3c             	mov    0x3c(%eax),%edx
f01046a9:	8d 82 00 10 40 11    	lea    0x11401000(%edx),%eax
			dststack = (void *)tf->tf_esp - 4;
		else 
			dststack = (void *)UXSTACKTOP;
f01046af:	c7 45 f0 00 00 c0 ee 	movl   $0xeec00000,-0x10(%ebp)
		if (!page_lookup(curenv->env_pgdir, (void *)(UXSTACKTOP-PGSIZE), NULL))
			env_destroy(curenv);

		void *dststack;
		// if this is recursive call to pgfault_upcall, make some space
		if (tf->tf_esp >= (UXSTACKTOP-PGSIZE) && tf->tf_esp < UXSTACKTOP) 
f01046b6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01046bb:	77 06                	ja     f01046c3 <page_fault_handler+0xfa>
			dststack = (void *)tf->tf_esp - 4;
f01046bd:	83 ea 04             	sub    $0x4,%edx
f01046c0:	89 55 f0             	mov    %edx,-0x10(%ebp)
		else 
			dststack = (void *)UXSTACKTOP;
		dststack -= sizeof(struct UTrapframe);
f01046c3:	83 6d f0 34          	subl   $0x34,-0x10(%ebp)

		// stack overflow
		if ((uint32_t)dststack < (UXSTACKTOP-PGSIZE)) {
f01046c7:	81 7d f0 ff ef bf ee 	cmpl   $0xeebfefff,-0x10(%ebp)
f01046ce:	77 4e                	ja     f010471e <page_fault_handler+0x155>
			cprintf("[%08x] user exception stack overflowed\n", curenv->env_id);
f01046d0:	83 ec 10             	sub    $0x10,%esp
f01046d3:	e8 3a 1d 00 00       	call   f0106412 <cpunum>
f01046d8:	83 c4 08             	add    $0x8,%esp
f01046db:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01046e2:	29 c2                	sub    %eax,%edx
f01046e4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01046e7:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01046ee:	ff 70 48             	pushl  0x48(%eax)
f01046f1:	68 8c 7d 10 f0       	push   $0xf0107d8c
f01046f6:	e8 d7 f2 ff ff       	call   f01039d2 <cprintf>
			env_destroy(curenv);
f01046fb:	e8 12 1d 00 00       	call   f0106412 <cpunum>
f0104700:	83 c4 04             	add    $0x4,%esp
f0104703:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010470a:	29 c2                	sub    %eax,%edx
f010470c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010470f:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104716:	e8 eb ef ff ff       	call   f0103706 <env_destroy>
f010471b:	83 c4 10             	add    $0x10,%esp
//		if (page_lookup(curenv->env_pgdir, (void *)(0xeebfdf50), &pte))
//			cprintf("curenv:pte of userstack: %08x\n", *pte);
//		if (page_lookup(kern_pgdir, (void *)(0xeebfdf50), &pte))
//			cprintf("kernel:pte of userstack: %08x\n", *pte);

		struct UTrapframe *udststack = (struct UTrapframe *)dststack;
f010471e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104721:	e8 ec 1c 00 00       	call   f0106412 <cpunum>
f0104726:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010472d:	29 c2                	sub    %eax,%edx
f010472f:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104732:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0104739:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010473c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104741:	77 15                	ja     f0104758 <page_fault_handler+0x18f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104743:	50                   	push   %eax
f0104744:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0104749:	68 fe 01 00 00       	push   $0x1fe
f010474e:	68 19 7c 10 f0       	push   $0xf0107c19
f0104753:	e8 49 bb ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0104758:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010475d:	0f 22 d8             	mov    %eax,%cr3
//		pde = &curenv->env_pgdir[PDX((void *)dststack)];
//		*pde = *pde | PTE_W | PTE_U | PTE_P;
//		pde = &curenv->env_pgdir[PDX((void *)fault_va)];
//		*pde = *pde | PTE_W | PTE_U | PTE_P;
		lcr3(PADDR(curenv->env_pgdir));
		udststack->utf_err = tf->tf_err;
f0104760:	8b 55 08             	mov    0x8(%ebp),%edx
f0104763:	8b 42 2c             	mov    0x2c(%edx),%eax
f0104766:	89 43 04             	mov    %eax,0x4(%ebx)
		udststack->utf_fault_va = fault_va;
f0104769:	89 33                	mov    %esi,(%ebx)
		udststack->utf_regs = tf->tf_regs;
f010476b:	8d 7b 08             	lea    0x8(%ebx),%edi
f010476e:	fc                   	cld    
f010476f:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104774:	8b 75 08             	mov    0x8(%ebp),%esi
f0104777:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		udststack->utf_eip = tf->tf_eip;
f0104779:	8b 42 30             	mov    0x30(%edx),%eax
f010477c:	89 43 28             	mov    %eax,0x28(%ebx)
		udststack->utf_eflags = tf->tf_eflags;
f010477f:	8b 42 38             	mov    0x38(%edx),%eax
f0104782:	89 43 2c             	mov    %eax,0x2c(%ebx)
		udststack->utf_esp = tf->tf_esp;
f0104785:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104788:	89 43 30             	mov    %eax,0x30(%ebx)
f010478b:	a1 ec ee 1b f0       	mov    0xf01beeec,%eax
	if ((uint32_t)kva < KERNBASE)
f0104790:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104795:	77 15                	ja     f01047ac <page_fault_handler+0x1e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104797:	50                   	push   %eax
f0104798:	68 7c 6a 10 f0       	push   $0xf0106a7c
f010479d:	68 05 02 00 00       	push   $0x205
f01047a2:	68 19 7c 10 f0       	push   $0xf0107c19
f01047a7:	e8 f5 ba ff ff       	call   f01002a1 <_panic>
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01047ac:	05 00 00 00 10       	add    $0x10000000,%eax
f01047b1:	0f 22 d8             	mov    %eax,%cr3
		lcr3(PADDR(kern_pgdir));

		tf->tf_esp = (uintptr_t)dststack;
f01047b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01047b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01047ba:	89 50 3c             	mov    %edx,0x3c(%eax)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f01047bd:	e8 50 1c 00 00       	call   f0106412 <cpunum>
f01047c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047c9:	29 c2                	sub    %eax,%edx
f01047cb:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01047ce:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01047d5:	8b 40 64             	mov    0x64(%eax),%eax
f01047d8:	8b 55 08             	mov    0x8(%ebp),%edx
f01047db:	89 42 30             	mov    %eax,0x30(%edx)

		env_run(curenv);
f01047de:	83 ec 10             	sub    $0x10,%esp
f01047e1:	e8 2c 1c 00 00       	call   f0106412 <cpunum>
f01047e6:	83 c4 04             	add    $0x4,%esp
f01047e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047f0:	29 c2                	sub    %eax,%edx
f01047f2:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01047f5:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f01047fc:	e8 cc ef ff ff       	call   f01037cd <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104801:	8b 45 08             	mov    0x8(%ebp),%eax
f0104804:	ff 70 30             	pushl  0x30(%eax)
f0104807:	56                   	push   %esi
f0104808:	83 ec 08             	sub    $0x8,%esp
f010480b:	e8 02 1c 00 00       	call   f0106412 <cpunum>
f0104810:	83 c4 08             	add    $0x8,%esp
f0104813:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010481a:	29 c2                	sub    %eax,%edx
f010481c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010481f:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0104826:	ff 70 48             	pushl  0x48(%eax)
f0104829:	68 b4 7d 10 f0       	push   $0xf0107db4
f010482e:	e8 9f f1 ff ff       	call   f01039d2 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104833:	83 c4 04             	add    $0x4,%esp
f0104836:	ff 75 08             	pushl  0x8(%ebp)
f0104839:	e8 0c f9 ff ff       	call   f010414a <print_trapframe>
	env_destroy(curenv);
f010483e:	e8 cf 1b 00 00       	call   f0106412 <cpunum>
f0104843:	83 c4 04             	add    $0x4,%esp
f0104846:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010484d:	29 c2                	sub    %eax,%edx
f010484f:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104852:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104859:	e8 a8 ee ff ff       	call   f0103706 <env_destroy>
}
f010485e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104861:	5b                   	pop    %ebx
f0104862:	5e                   	pop    %esi
f0104863:	5f                   	pop    %edi
f0104864:	c9                   	leave  
f0104865:	c3                   	ret    
	...

f0104868 <trap_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(trap_divide, T_DIVIDE); 
f0104868:	6a 00                	push   $0x0
f010486a:	6a 00                	push   $0x0
f010486c:	e9 f1 00 00 00       	jmp    f0104962 <_alltraps>
f0104871:	90                   	nop

f0104872 <trap_debug>:
TRAPHANDLER_NOEC(trap_debug, T_DEBUG);
f0104872:	6a 00                	push   $0x0
f0104874:	6a 01                	push   $0x1
f0104876:	e9 e7 00 00 00       	jmp    f0104962 <_alltraps>
f010487b:	90                   	nop

f010487c <trap_nmi>:
TRAPHANDLER_NOEC(trap_nmi, T_NMI);	
f010487c:	6a 00                	push   $0x0
f010487e:	6a 02                	push   $0x2
f0104880:	e9 dd 00 00 00       	jmp    f0104962 <_alltraps>
f0104885:	90                   	nop

f0104886 <trap_brkpt>:
TRAPHANDLER_NOEC(trap_brkpt, T_BRKPT);
f0104886:	6a 00                	push   $0x0
f0104888:	6a 03                	push   $0x3
f010488a:	e9 d3 00 00 00       	jmp    f0104962 <_alltraps>
f010488f:	90                   	nop

f0104890 <trap_oflow>:
TRAPHANDLER_NOEC(trap_oflow, T_OFLOW); 
f0104890:	6a 00                	push   $0x0
f0104892:	6a 04                	push   $0x4
f0104894:	e9 c9 00 00 00       	jmp    f0104962 <_alltraps>
f0104899:	90                   	nop

f010489a <trap_bound>:
TRAPHANDLER_NOEC(trap_bound, T_BOUND);
f010489a:	6a 00                	push   $0x0
f010489c:	6a 05                	push   $0x5
f010489e:	e9 bf 00 00 00       	jmp    f0104962 <_alltraps>
f01048a3:	90                   	nop

f01048a4 <trap_illop>:
TRAPHANDLER_NOEC(trap_illop, T_ILLOP);
f01048a4:	6a 00                	push   $0x0
f01048a6:	6a 06                	push   $0x6
f01048a8:	e9 b5 00 00 00       	jmp    f0104962 <_alltraps>
f01048ad:	90                   	nop

f01048ae <trap_device>:
TRAPHANDLER_NOEC(trap_device, T_DEVICE);
f01048ae:	6a 00                	push   $0x0
f01048b0:	6a 07                	push   $0x7
f01048b2:	e9 ab 00 00 00       	jmp    f0104962 <_alltraps>
f01048b7:	90                   	nop

f01048b8 <trap_dblflt>:
TRAPHANDLER(trap_dblflt, T_DBLFLT);
f01048b8:	6a 08                	push   $0x8
f01048ba:	e9 a3 00 00 00       	jmp    f0104962 <_alltraps>
f01048bf:	90                   	nop

f01048c0 <trap_tss>:
#TRAPHANDLER_NOEC(trap_coproc, T_DBLFLT);	//Reserved in inc/trap.h, so skip it in kern/trap.c
TRAPHANDLER(trap_tss, T_TSS);
f01048c0:	6a 0a                	push   $0xa
f01048c2:	e9 9b 00 00 00       	jmp    f0104962 <_alltraps>
f01048c7:	90                   	nop

f01048c8 <trap_segnp>:
TRAPHANDLER(trap_segnp, T_SEGNP);
f01048c8:	6a 0b                	push   $0xb
f01048ca:	e9 93 00 00 00       	jmp    f0104962 <_alltraps>
f01048cf:	90                   	nop

f01048d0 <trap_stack>:
TRAPHANDLER(trap_stack, T_STACK);
f01048d0:	6a 0c                	push   $0xc
f01048d2:	e9 8b 00 00 00       	jmp    f0104962 <_alltraps>
f01048d7:	90                   	nop

f01048d8 <trap_gpflt>:
TRAPHANDLER(trap_gpflt, T_GPFLT);
f01048d8:	6a 0d                	push   $0xd
f01048da:	e9 83 00 00 00       	jmp    f0104962 <_alltraps>
f01048df:	90                   	nop

f01048e0 <trap_pgflt>:
TRAPHANDLER(trap_pgflt, T_PGFLT);
f01048e0:	6a 0e                	push   $0xe
f01048e2:	eb 7e                	jmp    f0104962 <_alltraps>

f01048e4 <trap_fperr>:
#TRAPHANDLER_NOEC(trap_res, T_PGFLT);   //Reserved in inc/trap.h, so skip it in kern/trap.c
TRAPHANDLER_NOEC(trap_fperr, T_FPERR);
f01048e4:	6a 00                	push   $0x0
f01048e6:	6a 10                	push   $0x10
f01048e8:	eb 78                	jmp    f0104962 <_alltraps>

f01048ea <trap_align>:
TRAPHANDLER_NOEC(trap_align, T_ALIGN);
f01048ea:	6a 00                	push   $0x0
f01048ec:	6a 11                	push   $0x11
f01048ee:	eb 72                	jmp    f0104962 <_alltraps>

f01048f0 <trap_mchk>:
TRAPHANDLER_NOEC(trap_mchk, T_MCHK);
f01048f0:	6a 00                	push   $0x0
f01048f2:	6a 12                	push   $0x12
f01048f4:	eb 6c                	jmp    f0104962 <_alltraps>

f01048f6 <trap_simderr>:
TRAPHANDLER_NOEC(trap_simderr, T_SIMDERR);
f01048f6:	6a 00                	push   $0x0
f01048f8:	6a 13                	push   $0x13
f01048fa:	eb 66                	jmp    f0104962 <_alltraps>

f01048fc <trap_syscall>:

TRAPHANDLER_NOEC(trap_syscall, T_SYSCALL);
f01048fc:	6a 00                	push   $0x0
f01048fe:	6a 30                	push   $0x30
f0104900:	eb 60                	jmp    f0104962 <_alltraps>

f0104902 <irq0_handler>:

#IRQ handlers blow
TRAPHANDLER_NOEC(irq0_handler ,IRQ_OFFSET);
f0104902:	6a 00                	push   $0x0
f0104904:	6a 20                	push   $0x20
f0104906:	eb 5a                	jmp    f0104962 <_alltraps>

f0104908 <irq1_handler>:
TRAPHANDLER_NOEC(irq1_handler ,IRQ_OFFSET+1);
f0104908:	6a 00                	push   $0x0
f010490a:	6a 21                	push   $0x21
f010490c:	eb 54                	jmp    f0104962 <_alltraps>

f010490e <irq2_handler>:
TRAPHANDLER_NOEC(irq2_handler ,IRQ_OFFSET+2);
f010490e:	6a 00                	push   $0x0
f0104910:	6a 22                	push   $0x22
f0104912:	eb 4e                	jmp    f0104962 <_alltraps>

f0104914 <irq3_handler>:
TRAPHANDLER_NOEC(irq3_handler ,IRQ_OFFSET+3);
f0104914:	6a 00                	push   $0x0
f0104916:	6a 23                	push   $0x23
f0104918:	eb 48                	jmp    f0104962 <_alltraps>

f010491a <irq5_handler>:
TRAPHANDLER_NOEC(irq5_handler ,IRQ_OFFSET+4);
f010491a:	6a 00                	push   $0x0
f010491c:	6a 24                	push   $0x24
f010491e:	eb 42                	jmp    f0104962 <_alltraps>

f0104920 <irq4_handler>:
TRAPHANDLER_NOEC(irq4_handler ,IRQ_OFFSET+5);
f0104920:	6a 00                	push   $0x0
f0104922:	6a 25                	push   $0x25
f0104924:	eb 3c                	jmp    f0104962 <_alltraps>

f0104926 <irq6_handler>:
TRAPHANDLER_NOEC(irq6_handler ,IRQ_OFFSET+6);
f0104926:	6a 00                	push   $0x0
f0104928:	6a 26                	push   $0x26
f010492a:	eb 36                	jmp    f0104962 <_alltraps>

f010492c <irq7_handler>:
TRAPHANDLER_NOEC(irq7_handler ,IRQ_OFFSET+7);
f010492c:	6a 00                	push   $0x0
f010492e:	6a 27                	push   $0x27
f0104930:	eb 30                	jmp    f0104962 <_alltraps>

f0104932 <irq8_handler>:
TRAPHANDLER_NOEC(irq8_handler ,IRQ_OFFSET+8);
f0104932:	6a 00                	push   $0x0
f0104934:	6a 28                	push   $0x28
f0104936:	eb 2a                	jmp    f0104962 <_alltraps>

f0104938 <irq9_handler>:
TRAPHANDLER_NOEC(irq9_handler ,IRQ_OFFSET+9);
f0104938:	6a 00                	push   $0x0
f010493a:	6a 29                	push   $0x29
f010493c:	eb 24                	jmp    f0104962 <_alltraps>

f010493e <irq10_handler>:
TRAPHANDLER_NOEC(irq10_handler,IRQ_OFFSET+10);
f010493e:	6a 00                	push   $0x0
f0104940:	6a 2a                	push   $0x2a
f0104942:	eb 1e                	jmp    f0104962 <_alltraps>

f0104944 <irq11_handler>:
TRAPHANDLER_NOEC(irq11_handler,IRQ_OFFSET+11);
f0104944:	6a 00                	push   $0x0
f0104946:	6a 2b                	push   $0x2b
f0104948:	eb 18                	jmp    f0104962 <_alltraps>

f010494a <irq12_handler>:
TRAPHANDLER_NOEC(irq12_handler,IRQ_OFFSET+12);
f010494a:	6a 00                	push   $0x0
f010494c:	6a 2c                	push   $0x2c
f010494e:	eb 12                	jmp    f0104962 <_alltraps>

f0104950 <irq13_handler>:
TRAPHANDLER_NOEC(irq13_handler,IRQ_OFFSET+13);
f0104950:	6a 00                	push   $0x0
f0104952:	6a 2d                	push   $0x2d
f0104954:	eb 0c                	jmp    f0104962 <_alltraps>

f0104956 <irq14_handler>:
TRAPHANDLER_NOEC(irq14_handler,IRQ_OFFSET+14);
f0104956:	6a 00                	push   $0x0
f0104958:	6a 2e                	push   $0x2e
f010495a:	eb 06                	jmp    f0104962 <_alltraps>

f010495c <irq15_handler>:
TRAPHANDLER_NOEC(irq15_handler,IRQ_OFFSET+15);
f010495c:	6a 00                	push   $0x0
f010495e:	6a 2f                	push   $0x2f
f0104960:	eb 00                	jmp    f0104962 <_alltraps>

f0104962 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
#1. push values to make the stack look like a struct Trapframe 
pushl %ds
f0104962:	1e                   	push   %ds
pushl %es
f0104963:	06                   	push   %es
pushal
f0104964:	60                   	pusha  
#2. load GD_KD into %ds and %es
movw $GD_KD, %eax
f0104965:	66 b8 10 00          	mov    $0x10,%ax
movw %ax, %ds
f0104969:	8e d8                	mov    %eax,%ds
movw %ax, %es
f010496b:	8e c0                	mov    %eax,%es
#3. pass pointer to the Trapfreme as an arg of trap() 
pushl %esp
f010496d:	54                   	push   %esp
#4. call trap
call trap
f010496e:	e8 ba fa ff ff       	call   f010442d <trap>

# when it returns, cleaning it up and return
popal
f0104973:	61                   	popa   
popl %es
f0104974:	07                   	pop    %es
popl %ds
f0104975:	1f                   	pop    %ds
iret
f0104976:	cf                   	iret   
	...

f0104978 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104978:	55                   	push   %ebp
f0104979:	89 e5                	mov    %esp,%ebp
f010497b:	57                   	push   %edi
f010497c:	56                   	push   %esi
f010497d:	53                   	push   %ebx
f010497e:	83 ec 0c             	sub    $0xc,%esp
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	// Env, Cpu
	int id;
	struct Env *next = NULL;
f0104981:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int current_index = (curenv == NULL) ? 0 : curenv - envs;
f0104988:	e8 85 1a 00 00       	call   f0106412 <cpunum>
f010498d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104994:	29 c2                	sub    %eax,%edx
f0104996:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104999:	be 00 00 00 00       	mov    $0x0,%esi
f010499e:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f01049a5:	00 
f01049a6:	74 34                	je     f01049dc <sched_yield+0x64>
f01049a8:	e8 65 1a 00 00       	call   f0106412 <cpunum>
f01049ad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01049b4:	29 c2                	sub    %eax,%edx
f01049b6:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01049b9:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01049c0:	89 c6                	mov    %eax,%esi
f01049c2:	2b 35 38 e2 1b f0    	sub    0xf01be238,%esi
f01049c8:	89 f0                	mov    %esi,%eax
f01049ca:	c1 f8 02             	sar    $0x2,%eax
f01049cd:	69 f0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%esi
f01049d3:	eb 07                	jmp    f01049dc <sched_yield+0x64>
	current_index++;
	for (i = 0; i < NENV; i++) {
		id = (current_index + i) % NENV;
		if (envs[id].env_type != ENV_TYPE_IDLE && envs[id].env_status != ENV_RUNNING &&
				envs[id].env_status == ENV_RUNNABLE) {
			next = &envs[id];
f01049d5:	01 c8                	add    %ecx,%eax
f01049d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
			break;
f01049da:	eb 4c                	jmp    f0104a28 <sched_yield+0xb0>
	// LAB 4: Your code here.
	// Env, Cpu
	int id;
	struct Env *next = NULL;
	int current_index = (curenv == NULL) ? 0 : curenv - envs;
	current_index++;
f01049dc:	46                   	inc    %esi
	for (i = 0; i < NENV; i++) {
f01049dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049e2:	8b 3d 38 e2 1b f0    	mov    0xf01be238,%edi
		id = (current_index + i) % NENV;
f01049e8:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01049eb:	89 d0                	mov    %edx,%eax
f01049ed:	85 d2                	test   %edx,%edx
f01049ef:	79 06                	jns    f01049f7 <sched_yield+0x7f>
f01049f1:	8d 82 ff 03 00 00    	lea    0x3ff(%edx),%eax
f01049f7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01049fc:	29 c2                	sub    %eax,%edx
		if (envs[id].env_type != ENV_TYPE_IDLE && envs[id].env_status != ENV_RUNNING &&
f01049fe:	89 f9                	mov    %edi,%ecx
f0104a00:	89 d0                	mov    %edx,%eax
f0104a02:	c1 e0 05             	shl    $0x5,%eax
f0104a05:	29 d0                	sub    %edx,%eax
f0104a07:	c1 e0 02             	shl    $0x2,%eax
f0104a0a:	83 7c 38 50 01       	cmpl   $0x1,0x50(%eax,%edi,1)
f0104a0f:	74 0e                	je     f0104a1f <sched_yield+0xa7>
f0104a11:	83 7c 38 54 03       	cmpl   $0x3,0x54(%eax,%edi,1)
f0104a16:	74 07                	je     f0104a1f <sched_yield+0xa7>
f0104a18:	83 7c 38 54 02       	cmpl   $0x2,0x54(%eax,%edi,1)
f0104a1d:	74 b6                	je     f01049d5 <sched_yield+0x5d>
	// Env, Cpu
	int id;
	struct Env *next = NULL;
	int current_index = (curenv == NULL) ? 0 : curenv - envs;
	current_index++;
	for (i = 0; i < NENV; i++) {
f0104a1f:	43                   	inc    %ebx
f0104a20:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0104a26:	7e c0                	jle    f01049e8 <sched_yield+0x70>
				envs[id].env_status == ENV_RUNNABLE) {
			next = &envs[id];
			break;
		}
	}
	if (curenv != NULL) {
f0104a28:	e8 e5 19 00 00       	call   f0106412 <cpunum>
f0104a2d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a34:	29 c2                	sub    %eax,%edx
f0104a36:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104a39:	83 3c 95 28 f0 1b f0 	cmpl   $0x0,-0xfe40fd8(,%edx,4)
f0104a40:	00 
f0104a41:	74 5d                	je     f0104aa0 <sched_yield+0x128>
		if (next == NULL && curenv->env_status == ENV_RUNNING && 
f0104a43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104a47:	75 5d                	jne    f0104aa6 <sched_yield+0x12e>
f0104a49:	e8 c4 19 00 00       	call   f0106412 <cpunum>
f0104a4e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a55:	29 c2                	sub    %eax,%edx
f0104a57:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104a5a:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0104a61:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a65:	75 39                	jne    f0104aa0 <sched_yield+0x128>
f0104a67:	e8 a6 19 00 00       	call   f0106412 <cpunum>
f0104a6c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a73:	29 c2                	sub    %eax,%edx
f0104a75:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104a78:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0104a7f:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0104a83:	74 1b                	je     f0104aa0 <sched_yield+0x128>
				curenv->env_type != ENV_TYPE_IDLE) {
			next = curenv;
f0104a85:	e8 88 19 00 00       	call   f0106412 <cpunum>
f0104a8a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a91:	29 c2                	sub    %eax,%edx
f0104a93:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104a96:	8b 14 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%edx
f0104a9d:	89 55 f0             	mov    %edx,-0x10(%ebp)
		}
	}
	if (next != NULL) {
f0104aa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104aa4:	74 0b                	je     f0104ab1 <sched_yield+0x139>
		env_run(next);
f0104aa6:	83 ec 0c             	sub    $0xc,%esp
f0104aa9:	ff 75 f0             	pushl  -0x10(%ebp)
f0104aac:	e8 1c ed ff ff       	call   f01037cd <env_run>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	if (next == NULL) {
		cprintf("No more runnable environments!\n");
f0104ab1:	83 ec 0c             	sub    $0xc,%esp
f0104ab4:	68 d8 7d 10 f0       	push   $0xf0107dd8
f0104ab9:	e8 14 ef ff ff       	call   f01039d2 <cprintf>
		while (1)
f0104abe:	83 c4 10             	add    $0x10,%esp
			monitor(NULL);
f0104ac1:	83 ec 0c             	sub    $0xc,%esp
f0104ac4:	6a 00                	push   $0x0
f0104ac6:	e8 d3 bf ff ff       	call   f0100a9e <monitor>
f0104acb:	83 c4 10             	add    $0x10,%esp
f0104ace:	eb f1                	jmp    f0104ac1 <sched_yield+0x149>

f0104ad0 <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
f0104ad0:	55                   	push   %ebp
f0104ad1:	89 e5                	mov    %esp,%ebp
f0104ad3:	56                   	push   %esi
f0104ad4:	53                   	push   %ebx
f0104ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_P);
f0104adb:	6a 01                	push   $0x1
f0104add:	56                   	push   %esi
f0104ade:	53                   	push   %ebx
f0104adf:	83 ec 04             	sub    $0x4,%esp
f0104ae2:	e8 2b 19 00 00       	call   f0106412 <cpunum>
f0104ae7:	83 c4 04             	add    $0x4,%esp
f0104aea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104af1:	29 c2                	sub    %eax,%edx
f0104af3:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104af6:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104afd:	e8 9e ca ff ff       	call   f01015a0 <user_mem_assert>
	
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104b02:	83 c4 0c             	add    $0xc,%esp
f0104b05:	53                   	push   %ebx
f0104b06:	56                   	push   %esi
f0104b07:	68 f8 7d 10 f0       	push   $0xf0107df8
f0104b0c:	e8 c1 ee ff ff       	call   f01039d2 <cprintf>
}
f0104b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104b14:	5b                   	pop    %ebx
f0104b15:	5e                   	pop    %esi
f0104b16:	c9                   	leave  
f0104b17:	c3                   	ret    

f0104b18 <sys_cgetc>:

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
f0104b18:	55                   	push   %ebp
f0104b19:	89 e5                	mov    %esp,%ebp
f0104b1b:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f0104b1e:	e8 7b bc ff ff       	call   f010079e <cons_getc>
}
f0104b23:	c9                   	leave  
f0104b24:	c3                   	ret    

f0104b25 <sys_getenvid>:

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104b25:	55                   	push   %ebp
f0104b26:	89 e5                	mov    %esp,%ebp
f0104b28:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104b2b:	e8 e2 18 00 00       	call   f0106412 <cpunum>
f0104b30:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b37:	29 c2                	sub    %eax,%edx
f0104b39:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104b3c:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0104b43:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104b46:	c9                   	leave  
f0104b47:	c3                   	ret    

f0104b48 <sys_env_destroy>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
f0104b48:	55                   	push   %ebp
f0104b49:	89 e5                	mov    %esp,%ebp
f0104b4b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b4e:	6a 01                	push   $0x1
f0104b50:	8d 45 fc             	lea    -0x4(%ebp),%eax
f0104b53:	50                   	push   %eax
f0104b54:	ff 75 08             	pushl  0x8(%ebp)
f0104b57:	e8 5c e4 ff ff       	call   f0102fb8 <envid2env>
f0104b5c:	83 c4 10             	add    $0x10,%esp
		return r;
f0104b5f:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b61:	85 c0                	test   %eax,%eax
f0104b63:	78 10                	js     f0104b75 <sys_env_destroy+0x2d>
//	if (e == curenv)
//		cprintf(".%08x. exiting gracefully\n", curenv->env_id);
//	else
//		cprintf(".%08x. destroying %08x\n", curenv->env_id, e->env_id);

	env_destroy(e);
f0104b65:	83 ec 0c             	sub    $0xc,%esp
f0104b68:	ff 75 fc             	pushl  -0x4(%ebp)
f0104b6b:	e8 96 eb ff ff       	call   f0103706 <env_destroy>
	return 0;
f0104b70:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104b75:	89 d0                	mov    %edx,%eax
f0104b77:	c9                   	leave  
f0104b78:	c3                   	ret    

f0104b79 <sys_yield>:

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104b79:	55                   	push   %ebp
f0104b7a:	89 e5                	mov    %esp,%ebp
f0104b7c:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104b7f:	e8 f4 fd ff ff       	call   f0104978 <sched_yield>

f0104b84 <sys_exofork>:
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
f0104b84:	55                   	push   %ebp
f0104b85:	89 e5                	mov    %esp,%ebp
f0104b87:	53                   	push   %ebx
f0104b88:	83 ec 14             	sub    $0x14,%esp
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *env = NULL;
f0104b8b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	int err;
	if ((err = env_alloc(&env, curenv->env_id)) < 0) 
f0104b92:	e8 7b 18 00 00       	call   f0106412 <cpunum>
f0104b97:	83 c4 08             	add    $0x8,%esp
f0104b9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ba1:	29 c2                	sub    %eax,%edx
f0104ba3:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104ba6:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0104bad:	ff 70 48             	pushl  0x48(%eax)
f0104bb0:	8d 45 f8             	lea    -0x8(%ebp),%eax
f0104bb3:	50                   	push   %eax
f0104bb4:	e8 2d e6 ff ff       	call   f01031e6 <env_alloc>
f0104bb9:	83 c4 10             	add    $0x10,%esp
		return err;
f0104bbc:	89 c2                	mov    %eax,%edx
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *env = NULL;
	int err;
	if ((err = env_alloc(&env, curenv->env_id)) < 0) 
f0104bbe:	85 c0                	test   %eax,%eax
f0104bc0:	78 40                	js     f0104c02 <sys_exofork+0x7e>
		return err;

	env->env_status = ENV_NOT_RUNNABLE;
f0104bc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104bc5:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	env->env_tf = curenv->env_tf;
f0104bcc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0104bcf:	e8 3e 18 00 00       	call   f0106412 <cpunum>
f0104bd4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bdb:	29 c2                	sub    %eax,%edx
f0104bdd:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104be0:	83 ec 04             	sub    $0x4,%esp
f0104be3:	6a 44                	push   $0x44
f0104be5:	ff 34 95 28 f0 1b f0 	pushl  -0xfe40fd8(,%edx,4)
f0104bec:	53                   	push   %ebx
f0104bed:	e8 5e 11 00 00       	call   f0105d50 <memcpy>
	// new environment return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104bf2:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104bf5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env->env_id;
f0104bfc:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104bff:	8b 50 48             	mov    0x48(%eax),%edx

	panic("sys_exofork not implemented");
}
f0104c02:	89 d0                	mov    %edx,%eax
f0104c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104c07:	c9                   	leave  
f0104c08:	c3                   	ret    

f0104c09 <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0104c09:	55                   	push   %ebp
f0104c0a:	89 e5                	mov    %esp,%ebp
f0104c0c:	53                   	push   %ebx
f0104c0d:	83 ec 08             	sub    $0x8,%esp
f0104c10:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 4: Your code here.
	struct Env *env;
	int err;

	if ((err = envid2env(envid, &env, 1)) < 0)
f0104c13:	6a 01                	push   $0x1
f0104c15:	8d 45 f8             	lea    -0x8(%ebp),%eax
f0104c18:	50                   	push   %eax
f0104c19:	ff 75 08             	pushl  0x8(%ebp)
f0104c1c:	e8 97 e3 ff ff       	call   f0102fb8 <envid2env>
f0104c21:	83 c4 10             	add    $0x10,%esp
		return err;
f0104c24:	89 c2                	mov    %eax,%edx

	// LAB 4: Your code here.
	struct Env *env;
	int err;

	if ((err = envid2env(envid, &env, 1)) < 0)
f0104c26:	85 c0                	test   %eax,%eax
f0104c28:	78 3a                	js     f0104c64 <sys_env_set_status+0x5b>
		return err;

	if (env->env_status == ENV_RUNNABLE && status == ENV_NOT_RUNNABLE) {
f0104c2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104c2d:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104c31:	75 0e                	jne    f0104c41 <sys_env_set_status+0x38>
f0104c33:	83 fb 04             	cmp    $0x4,%ebx
f0104c36:	75 09                	jne    f0104c41 <sys_env_set_status+0x38>
		env->env_status = ENV_NOT_RUNNABLE;
f0104c38:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
f0104c3f:	eb 1e                	jmp    f0104c5f <sys_env_set_status+0x56>
	} else if (env->env_status == ENV_NOT_RUNNABLE && status == ENV_RUNNABLE) {
f0104c41:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104c44:	83 78 54 04          	cmpl   $0x4,0x54(%eax)
f0104c48:	75 0e                	jne    f0104c58 <sys_env_set_status+0x4f>
f0104c4a:	83 fb 02             	cmp    $0x2,%ebx
f0104c4d:	75 09                	jne    f0104c58 <sys_env_set_status+0x4f>
		env->env_status = ENV_RUNNABLE;
f0104c4f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104c56:	eb 07                	jmp    f0104c5f <sys_env_set_status+0x56>
	} else {
		return -E_INVAL;
f0104c58:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104c5d:	eb 05                	jmp    f0104c64 <sys_env_set_status+0x5b>
	}
	return 0;
f0104c5f:	ba 00 00 00 00       	mov    $0x0,%edx

	panic("sys_env_set_status not implemented");
}
f0104c64:	89 d0                	mov    %edx,%eax
f0104c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104c69:	c9                   	leave  
f0104c6a:	c3                   	ret    

f0104c6b <sys_env_set_trapframe>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
f0104c6b:	55                   	push   %ebp
f0104c6c:	89 e5                	mov    %esp,%ebp
f0104c6e:	53                   	push   %ebx
f0104c6f:	83 ec 08             	sub    $0x8,%esp
f0104c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
f0104c75:	6a 01                	push   $0x1
f0104c77:	8d 45 f8             	lea    -0x8(%ebp),%eax
f0104c7a:	50                   	push   %eax
f0104c7b:	ff 75 08             	pushl  0x8(%ebp)
f0104c7e:	e8 35 e3 ff ff       	call   f0102fb8 <envid2env>
f0104c83:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104c86:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
f0104c8b:	85 c0                	test   %eax,%eax
f0104c8d:	78 2b                	js     f0104cba <sys_env_set_trapframe+0x4f>
		return -E_BAD_ENV;

	if (tf->tf_eip >= UTOP)
		return -1;
f0104c8f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;

	if (tf->tf_eip >= UTOP)
f0104c94:	81 7b 30 ff ff bf ee 	cmpl   $0xeebfffff,0x30(%ebx)
f0104c9b:	77 1d                	ja     f0104cba <sys_env_set_trapframe+0x4f>
		return -1;

	env->env_tf = *tf;
f0104c9d:	83 ec 04             	sub    $0x4,%esp
f0104ca0:	6a 44                	push   $0x44
f0104ca2:	53                   	push   %ebx
f0104ca3:	ff 75 f8             	pushl  -0x8(%ebp)
f0104ca6:	e8 a5 10 00 00       	call   f0105d50 <memcpy>
	env->env_tf.tf_eflags |= FL_IF;
f0104cab:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104cae:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)

	return 0;
f0104cb5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104cba:	89 d0                	mov    %edx,%eax
f0104cbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104cbf:	c9                   	leave  
f0104cc0:	c3                   	ret    

f0104cc1 <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f0104cc1:	55                   	push   %ebp
f0104cc2:	89 e5                	mov    %esp,%ebp
f0104cc4:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 1)) < 0) 
f0104cc7:	6a 01                	push   $0x1
f0104cc9:	8d 45 fc             	lea    -0x4(%ebp),%eax
f0104ccc:	50                   	push   %eax
f0104ccd:	ff 75 08             	pushl  0x8(%ebp)
f0104cd0:	e8 e3 e2 ff ff       	call   f0102fb8 <envid2env>
f0104cd5:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104cd8:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 1)) < 0) 
f0104cdd:	85 c0                	test   %eax,%eax
f0104cdf:	78 0e                	js     f0104cef <sys_env_set_pgfault_upcall+0x2e>
		return -E_BAD_ENV;
	env->env_pgfault_upcall = func;
f0104ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ce4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0104ce7:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f0104cea:	ba 00 00 00 00       	mov    $0x0,%edx
	panic("sys_env_set_pgfault_upcall not implemented");
}
f0104cef:	89 d0                	mov    %edx,%eax
f0104cf1:	c9                   	leave  
f0104cf2:	c3                   	ret    

f0104cf3 <sys_page_alloc>:
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
f0104cf3:	55                   	push   %ebp
f0104cf4:	89 e5                	mov    %esp,%ebp
f0104cf6:	57                   	push   %edi
f0104cf7:	56                   	push   %esi
f0104cf8:	53                   	push   %ebx
f0104cf9:	83 ec 10             	sub    $0x10,%esp
f0104cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cff:	8b 7d 10             	mov    0x10(%ebp),%edi
	//   allocated!

	// LAB 4: Your code here.
	struct Env *env;
	struct Page *page;
	if (envid2env(envid, &env, 1) < 0) 
f0104d02:	6a 01                	push   $0x1
f0104d04:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104d07:	50                   	push   %eax
f0104d08:	ff 75 08             	pushl  0x8(%ebp)
f0104d0b:	e8 a8 e2 ff ff       	call   f0102fb8 <envid2env>
f0104d10:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;    // -E_BAD_ENV
f0104d13:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
	//   allocated!

	// LAB 4: Your code here.
	struct Env *env;
	struct Page *page;
	if (envid2env(envid, &env, 1) < 0) 
f0104d18:	85 c0                	test   %eax,%eax
f0104d1a:	0f 88 d8 00 00 00    	js     f0104df8 <sys_page_alloc+0x105>
		return -E_BAD_ENV;    // -E_BAD_ENV
	if (!(page = page_alloc(0)))
f0104d20:	83 ec 0c             	sub    $0xc,%esp
f0104d23:	6a 00                	push   $0x0
f0104d25:	e8 51 c3 ff ff       	call   f010107b <page_alloc>
f0104d2a:	89 c3                	mov    %eax,%ebx
f0104d2c:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104d2f:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	// LAB 4: Your code here.
	struct Env *env;
	struct Page *page;
	if (envid2env(envid, &env, 1) < 0) 
		return -E_BAD_ENV;    // -E_BAD_ENV
	if (!(page = page_alloc(0)))
f0104d34:	85 c0                	test   %eax,%eax
f0104d36:	0f 84 bc 00 00 00    	je     f0104df8 <sys_page_alloc+0x105>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0104d3c:	2b 05 f0 ee 1b f0    	sub    0xf01beef0,%eax
f0104d42:	c1 f8 03             	sar    $0x3,%eax
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
f0104d45:	89 c2                	mov    %eax,%edx
f0104d47:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104d4a:	89 d0                	mov    %edx,%eax
f0104d4c:	c1 e8 0c             	shr    $0xc,%eax
f0104d4f:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0104d55:	72 12                	jb     f0104d69 <sys_page_alloc+0x76>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104d57:	52                   	push   %edx
f0104d58:	68 58 6a 10 f0       	push   $0xf0106a58
f0104d5d:	6a 56                	push   $0x56
f0104d5f:	68 64 75 10 f0       	push   $0xf0107564
f0104d64:	e8 38 b5 ff ff       	call   f01002a1 <_panic>
f0104d69:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0104d6f:	83 ec 04             	sub    $0x4,%esp
f0104d72:	68 00 10 00 00       	push   $0x1000
f0104d77:	6a 00                	push   $0x0
f0104d79:	50                   	push   %eax
f0104d7a:	e8 12 0f 00 00       	call   f0105c91 <memset>
		return -E_NO_MEM;
	memset(page2kva(page), 0, PGSIZE);

	if ((uint32_t)va > UTOP || ((uint32_t)va % PGSIZE) != 0) {
f0104d7f:	83 c4 10             	add    $0x10,%esp
f0104d82:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
f0104d88:	77 08                	ja     f0104d92 <sys_page_alloc+0x9f>
f0104d8a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104d90:	74 10                	je     f0104da2 <sys_page_alloc+0xaf>
		page_free(page);
f0104d92:	83 ec 0c             	sub    $0xc,%esp
f0104d95:	53                   	push   %ebx
f0104d96:	e8 5d c3 ff ff       	call   f01010f8 <page_free>
		return -E_INVAL;
f0104d9b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104da0:	eb 56                	jmp    f0104df8 <sys_page_alloc+0x105>
	}
	if (!((perm & PTE_U) && (perm & PTE_P) && 
f0104da2:	f7 c7 04 00 00 00    	test   $0x4,%edi
f0104da8:	74 16                	je     f0104dc0 <sys_page_alloc+0xcd>
f0104daa:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104db0:	74 0e                	je     f0104dc0 <sys_page_alloc+0xcd>
f0104db2:	89 f8                	mov    %edi,%eax
f0104db4:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104db9:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104dbe:	74 10                	je     f0104dd0 <sys_page_alloc+0xdd>
				((perm | PTE_SYSCALL) == PTE_SYSCALL))) {
		page_free(page);
f0104dc0:	83 ec 0c             	sub    $0xc,%esp
f0104dc3:	53                   	push   %ebx
f0104dc4:	e8 2f c3 ff ff       	call   f01010f8 <page_free>
		return -E_INVAL;
f0104dc9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104dce:	eb 28                	jmp    f0104df8 <sys_page_alloc+0x105>
	}

	if (page_insert(env->env_pgdir, page, va, perm) < 0) {
f0104dd0:	57                   	push   %edi
f0104dd1:	56                   	push   %esi
f0104dd2:	53                   	push   %ebx
f0104dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104dd6:	ff 70 60             	pushl  0x60(%eax)
f0104dd9:	e8 48 c5 ff ff       	call   f0101326 <page_insert>
f0104dde:	83 c4 10             	add    $0x10,%esp
		page_free(page);
		return -E_NO_MEM;
	}

	return 0;
f0104de1:	ba 00 00 00 00       	mov    $0x0,%edx
				((perm | PTE_SYSCALL) == PTE_SYSCALL))) {
		page_free(page);
		return -E_INVAL;
	}

	if (page_insert(env->env_pgdir, page, va, perm) < 0) {
f0104de6:	85 c0                	test   %eax,%eax
f0104de8:	79 0e                	jns    f0104df8 <sys_page_alloc+0x105>
		page_free(page);
f0104dea:	83 ec 0c             	sub    $0xc,%esp
f0104ded:	53                   	push   %ebx
f0104dee:	e8 05 c3 ff ff       	call   f01010f8 <page_free>
		return -E_NO_MEM;
f0104df3:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	}

	return 0;
	
	panic("sys_page_alloc not implemented");
}
f0104df8:	89 d0                	mov    %edx,%eax
f0104dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dfd:	5b                   	pop    %ebx
f0104dfe:	5e                   	pop    %esi
f0104dff:	5f                   	pop    %edi
f0104e00:	c9                   	leave  
f0104e01:	c3                   	ret    

f0104e02 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0104e02:	55                   	push   %ebp
f0104e03:	89 e5                	mov    %esp,%ebp
f0104e05:	57                   	push   %edi
f0104e06:	56                   	push   %esi
f0104e07:	53                   	push   %ebx
f0104e08:	83 ec 10             	sub    $0x10,%esp
f0104e0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e0e:	8b 75 14             	mov    0x14(%ebp),%esi
f0104e11:	8b 7d 18             	mov    0x18(%ebp),%edi
	//   check the current permissions on the page.
	// LAB 4: Your code here.
	struct Env *srcenv, *dstenv;
	struct Page *srcpage;
	pte_t *entry;
	if (envid2env(srcenvid, &srcenv, 1) < 0) {
f0104e14:	6a 01                	push   $0x1
f0104e16:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104e19:	50                   	push   %eax
f0104e1a:	ff 75 08             	pushl  0x8(%ebp)
f0104e1d:	e8 96 e1 ff ff       	call   f0102fb8 <envid2env>
f0104e22:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104e25:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
	//   check the current permissions on the page.
	// LAB 4: Your code here.
	struct Env *srcenv, *dstenv;
	struct Page *srcpage;
	pte_t *entry;
	if (envid2env(srcenvid, &srcenv, 1) < 0) {
f0104e2a:	85 c0                	test   %eax,%eax
f0104e2c:	0f 88 b8 00 00 00    	js     f0104eea <sys_page_map+0xe8>
		return -E_BAD_ENV;
	}
	//^&^ I had problem here... 3rd param should be 0
	if (envid2env(dstenvid, &dstenv, 0) < 0) {
f0104e32:	83 ec 04             	sub    $0x4,%esp
f0104e35:	6a 00                	push   $0x0
f0104e37:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e3a:	50                   	push   %eax
f0104e3b:	ff 75 10             	pushl  0x10(%ebp)
f0104e3e:	e8 75 e1 ff ff       	call   f0102fb8 <envid2env>
f0104e43:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104e46:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
	pte_t *entry;
	if (envid2env(srcenvid, &srcenv, 1) < 0) {
		return -E_BAD_ENV;
	}
	//^&^ I had problem here... 3rd param should be 0
	if (envid2env(dstenvid, &dstenv, 0) < 0) {
f0104e4b:	85 c0                	test   %eax,%eax
f0104e4d:	0f 88 97 00 00 00    	js     f0104eea <sys_page_map+0xe8>
		return -E_BAD_ENV;
	}

	if ((uint32_t)srcva > UTOP || ((uint32_t)srcva % PGSIZE) ||
f0104e53:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
f0104e59:	77 18                	ja     f0104e73 <sys_page_map+0x71>
f0104e5b:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104e61:	75 10                	jne    f0104e73 <sys_page_map+0x71>
f0104e63:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
f0104e69:	77 08                	ja     f0104e73 <sys_page_map+0x71>
f0104e6b:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104e71:	74 07                	je     f0104e7a <sys_page_map+0x78>
			(uint32_t)dstva > UTOP || ((uint32_t)dstva % PGSIZE))
		return -E_INVAL;
f0104e73:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e78:	eb 70                	jmp    f0104eea <sys_page_map+0xe8>
	if (!(srcpage = page_lookup(srcenv->env_pgdir, srcva, &entry)))
f0104e7a:	83 ec 04             	sub    $0x4,%esp
f0104e7d:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104e80:	50                   	push   %eax
f0104e81:	53                   	push   %ebx
f0104e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e85:	ff 70 60             	pushl  0x60(%eax)
f0104e88:	e8 5b c5 ff ff       	call   f01013e8 <page_lookup>
f0104e8d:	89 c1                	mov    %eax,%ecx
f0104e8f:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104e92:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	}

	if ((uint32_t)srcva > UTOP || ((uint32_t)srcva % PGSIZE) ||
			(uint32_t)dstva > UTOP || ((uint32_t)dstva % PGSIZE))
		return -E_INVAL;
	if (!(srcpage = page_lookup(srcenv->env_pgdir, srcva, &entry)))
f0104e97:	85 c0                	test   %eax,%eax
f0104e99:	74 4f                	je     f0104eea <sys_page_map+0xe8>
		return -E_INVAL;
	if (!((perm & PTE_U) && (perm & PTE_P) && 
f0104e9b:	f7 c7 04 00 00 00    	test   $0x4,%edi
f0104ea1:	74 16                	je     f0104eb9 <sys_page_map+0xb7>
f0104ea3:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104ea9:	74 0e                	je     f0104eb9 <sys_page_map+0xb7>
f0104eab:	89 f8                	mov    %edi,%eax
f0104ead:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104eb2:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104eb7:	74 07                	je     f0104ec0 <sys_page_map+0xbe>
				((perm | PTE_SYSCALL) == PTE_SYSCALL))) {
		return -E_INVAL;
f0104eb9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ebe:	eb 2a                	jmp    f0104eea <sys_page_map+0xe8>
	}
	if ((perm & PTE_W) && !((*entry & PTE_W) == PTE_W))
f0104ec0:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104ec6:	74 0d                	je     f0104ed5 <sys_page_map+0xd3>
		return -E_INVAL;
f0104ec8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		return -E_INVAL;
	if (!((perm & PTE_U) && (perm & PTE_P) && 
				((perm | PTE_SYSCALL) == PTE_SYSCALL))) {
		return -E_INVAL;
	}
	if ((perm & PTE_W) && !((*entry & PTE_W) == PTE_W))
f0104ecd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ed0:	f6 00 02             	testb  $0x2,(%eax)
f0104ed3:	74 15                	je     f0104eea <sys_page_map+0xe8>
		return -E_INVAL;
	if (page_insert(dstenv->env_pgdir, srcpage, dstva, perm) < 0)
f0104ed5:	57                   	push   %edi
f0104ed6:	56                   	push   %esi
f0104ed7:	51                   	push   %ecx
f0104ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104edb:	ff 70 60             	pushl  0x60(%eax)
f0104ede:	e8 43 c4 ff ff       	call   f0101326 <page_insert>
f0104ee3:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104ee6:	99                   	cltd   
f0104ee7:	83 e2 fc             	and    $0xfffffffc,%edx

	return 0;

	panic("sys_page_map not implemented");
}
f0104eea:	89 d0                	mov    %edx,%eax
f0104eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104eef:	5b                   	pop    %ebx
f0104ef0:	5e                   	pop    %esi
f0104ef1:	5f                   	pop    %edi
f0104ef2:	c9                   	leave  
f0104ef3:	c3                   	ret    

f0104ef4 <sys_page_unmap>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0104ef4:	55                   	push   %ebp
f0104ef5:	89 e5                	mov    %esp,%ebp
f0104ef7:	53                   	push   %ebx
f0104ef8:	83 ec 08             	sub    $0x8,%esp
f0104efb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 1)) < 0) 
f0104efe:	6a 01                	push   $0x1
f0104f00:	8d 45 f8             	lea    -0x8(%ebp),%eax
f0104f03:	50                   	push   %eax
f0104f04:	ff 75 08             	pushl  0x8(%ebp)
f0104f07:	e8 ac e0 ff ff       	call   f0102fb8 <envid2env>
f0104f0c:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104f0f:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 1)) < 0) 
f0104f14:	85 c0                	test   %eax,%eax
f0104f16:	78 2b                	js     f0104f43 <sys_page_unmap+0x4f>
		return -E_BAD_ENV;

	if ((uint32_t)va > UTOP || (uint32_t)va % PGSIZE != 0)
f0104f18:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
f0104f1e:	77 08                	ja     f0104f28 <sys_page_unmap+0x34>
f0104f20:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104f26:	74 07                	je     f0104f2f <sys_page_unmap+0x3b>
		return E_INVAL;
f0104f28:	ba 03 00 00 00       	mov    $0x3,%edx
f0104f2d:	eb 14                	jmp    f0104f43 <sys_page_unmap+0x4f>

	page_remove(env->env_pgdir, va);
f0104f2f:	83 ec 08             	sub    $0x8,%esp
f0104f32:	53                   	push   %ebx
f0104f33:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104f36:	ff 70 60             	pushl  0x60(%eax)
f0104f39:	e8 08 c5 ff ff       	call   f0101446 <page_remove>

	return 0;
f0104f3e:	ba 00 00 00 00       	mov    $0x0,%edx
	panic("sys_page_unmap not implemented");
}
f0104f43:	89 d0                	mov    %edx,%eax
f0104f45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f48:	c9                   	leave  
f0104f49:	c3                   	ret    

f0104f4a <sys_ipc_try_send>:
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
f0104f4a:	55                   	push   %ebp
f0104f4b:	89 e5                	mov    %esp,%ebp
f0104f4d:	57                   	push   %edi
f0104f4e:	56                   	push   %esi
f0104f4f:	53                   	push   %ebx
f0104f50:	83 ec 10             	sub    $0x10,%esp
f0104f53:	8b 75 10             	mov    0x10(%ebp),%esi
f0104f56:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	struct Env *target;
	pte_t *pte;
	struct Page *page;
	int r;
	if ((r = envid2env(envid, &target, 0)) < 0) {
f0104f59:	6a 00                	push   $0x0
f0104f5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104f5e:	50                   	push   %eax
f0104f5f:	ff 75 08             	pushl  0x8(%ebp)
f0104f62:	e8 51 e0 ff ff       	call   f0102fb8 <envid2env>
f0104f67:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104f6a:	b9 fe ff ff ff       	mov    $0xfffffffe,%ecx
	// LAB 4: Your code here.
	struct Env *target;
	pte_t *pte;
	struct Page *page;
	int r;
	if ((r = envid2env(envid, &target, 0)) < 0) {
f0104f6f:	85 c0                	test   %eax,%eax
f0104f71:	0f 88 75 01 00 00    	js     f01050ec <sys_ipc_try_send+0x1a2>
		return -E_BAD_ENV;
	}
	if (!target->env_ipc_recving)
		return -E_IPC_NOT_RECV;
f0104f77:	b9 f9 ff ff ff       	mov    $0xfffffff9,%ecx
	struct Page *page;
	int r;
	if ((r = envid2env(envid, &target, 0)) < 0) {
		return -E_BAD_ENV;
	}
	if (!target->env_ipc_recving)
f0104f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f7f:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0104f83:	0f 84 63 01 00 00    	je     f01050ec <sys_ipc_try_send+0x1a2>
		return -E_IPC_NOT_RECV;

	if ((uintptr_t)srcva < UTOP && (((uintptr_t)srcva % PGSIZE) != 0))
f0104f89:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104f8f:	0f 87 87 00 00 00    	ja     f010501c <sys_ipc_try_send+0xd2>
		return -E_INVAL;
f0104f95:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
		return -E_BAD_ENV;
	}
	if (!target->env_ipc_recving)
		return -E_IPC_NOT_RECV;

	if ((uintptr_t)srcva < UTOP && (((uintptr_t)srcva % PGSIZE) != 0))
f0104f9a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104fa0:	0f 85 46 01 00 00    	jne    f01050ec <sys_ipc_try_send+0x1a2>
		return -E_INVAL;
	if ((uintptr_t)srcva < UTOP && !((perm & PTE_U) && (perm & PTE_P) &&  
f0104fa6:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104fac:	77 6e                	ja     f010501c <sys_ipc_try_send+0xd2>
f0104fae:	f7 c7 04 00 00 00    	test   $0x4,%edi
f0104fb4:	74 16                	je     f0104fcc <sys_ipc_try_send+0x82>
f0104fb6:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104fbc:	74 0e                	je     f0104fcc <sys_ipc_try_send+0x82>
f0104fbe:	89 f8                	mov    %edi,%eax
f0104fc0:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104fc5:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104fca:	74 0a                	je     f0104fd6 <sys_ipc_try_send+0x8c>
				((perm | PTE_SYSCALL) == PTE_SYSCALL))) 
		return -E_INVAL;
f0104fcc:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
f0104fd1:	e9 16 01 00 00       	jmp    f01050ec <sys_ipc_try_send+0x1a2>
	if ((uintptr_t)srcva < UTOP && 
f0104fd6:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104fdc:	77 3e                	ja     f010501c <sys_ipc_try_send+0xd2>
f0104fde:	83 ec 04             	sub    $0x4,%esp
f0104fe1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104fe4:	50                   	push   %eax
f0104fe5:	56                   	push   %esi
f0104fe6:	83 ec 04             	sub    $0x4,%esp
f0104fe9:	e8 24 14 00 00       	call   f0106412 <cpunum>
f0104fee:	83 c4 04             	add    $0x4,%esp
f0104ff1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ff8:	29 c2                	sub    %eax,%edx
f0104ffa:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104ffd:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0105004:	ff 70 60             	pushl  0x60(%eax)
f0105007:	e8 dc c3 ff ff       	call   f01013e8 <page_lookup>
f010500c:	83 c4 10             	add    $0x10,%esp
			!page_lookup(curenv->env_pgdir, srcva, &pte))
		return -E_INVAL;
f010500f:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
	if ((uintptr_t)srcva < UTOP && (((uintptr_t)srcva % PGSIZE) != 0))
		return -E_INVAL;
	if ((uintptr_t)srcva < UTOP && !((perm & PTE_U) && (perm & PTE_P) &&  
				((perm | PTE_SYSCALL) == PTE_SYSCALL))) 
		return -E_INVAL;
	if ((uintptr_t)srcva < UTOP && 
f0105014:	85 c0                	test   %eax,%eax
f0105016:	0f 84 d0 00 00 00    	je     f01050ec <sys_ipc_try_send+0x1a2>
			!page_lookup(curenv->env_pgdir, srcva, &pte))
		return -E_INVAL;
	if ((perm & PTE_W) && (!(*pte & PTE_W) || !(*pte & PTE_U)))
f010501c:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105022:	74 17                	je     f010503b <sys_ipc_try_send+0xf1>
f0105024:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105027:	8b 00                	mov    (%eax),%eax
f0105029:	a8 02                	test   $0x2,%al
f010502b:	74 04                	je     f0105031 <sys_ipc_try_send+0xe7>
f010502d:	a8 04                	test   $0x4,%al
f010502f:	75 0a                	jne    f010503b <sys_ipc_try_send+0xf1>
		return -E_INVAL;
f0105031:	b9 fd ff ff ff       	mov    $0xfffffffd,%ecx
f0105036:	e9 b1 00 00 00       	jmp    f01050ec <sys_ipc_try_send+0x1a2>

	target->env_ipc_recving = 0;
f010503b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010503e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
	target->env_ipc_from = curenv->env_id;
f0105045:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105048:	e8 c5 13 00 00       	call   f0106412 <cpunum>
f010504d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105054:	29 c2                	sub    %eax,%edx
f0105056:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105059:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0105060:	8b 40 48             	mov    0x48(%eax),%eax
f0105063:	89 43 74             	mov    %eax,0x74(%ebx)
	target->env_ipc_value = value;
f0105066:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105069:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010506c:	89 50 70             	mov    %edx,0x70(%eax)
	if (((uintptr_t)srcva < UTOP) && ((uintptr_t)target->env_ipc_dstva < UTOP)) {
f010506f:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105075:	77 5c                	ja     f01050d3 <sys_ipc_try_send+0x189>
f0105077:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010507a:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0105081:	77 50                	ja     f01050d3 <sys_ipc_try_send+0x189>
		if ((r = sys_page_map(curenv->env_id, srcva, envid, target->env_ipc_dstva, perm)) < 0) {
f0105083:	83 ec 0c             	sub    $0xc,%esp
f0105086:	57                   	push   %edi
f0105087:	ff 70 6c             	pushl  0x6c(%eax)
f010508a:	ff 75 08             	pushl  0x8(%ebp)
f010508d:	56                   	push   %esi
f010508e:	83 ec 04             	sub    $0x4,%esp
f0105091:	e8 7c 13 00 00       	call   f0106412 <cpunum>
f0105096:	83 c4 04             	add    $0x4,%esp
f0105099:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050a0:	29 c2                	sub    %eax,%edx
f01050a2:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01050a5:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f01050ac:	ff 70 48             	pushl  0x48(%eax)
f01050af:	e8 4e fd ff ff       	call   f0104e02 <sys_page_map>
f01050b4:	89 c2                	mov    %eax,%edx
f01050b6:	83 c4 20             	add    $0x20,%esp
f01050b9:	85 c0                	test   %eax,%eax
f01050bb:	79 0e                	jns    f01050cb <sys_ipc_try_send+0x181>
			target->env_ipc_perm = 0;
f01050bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01050c0:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
			return r;
f01050c7:	89 d1                	mov    %edx,%ecx
f01050c9:	eb 21                	jmp    f01050ec <sys_ipc_try_send+0x1a2>
		}
		target->env_ipc_perm = perm;
f01050cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01050ce:	89 78 78             	mov    %edi,0x78(%eax)
f01050d1:	eb 0a                	jmp    f01050dd <sys_ipc_try_send+0x193>
	} else {
		target->env_ipc_perm = 0;
f01050d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01050d6:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}
	target->env_status = ENV_RUNNABLE;
f01050dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01050e0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	
	return 0;
f01050e7:	b9 00 00 00 00       	mov    $0x0,%ecx
}
f01050ec:	89 c8                	mov    %ecx,%eax
f01050ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050f1:	5b                   	pop    %ebx
f01050f2:	5e                   	pop    %esi
f01050f3:	5f                   	pop    %edi
f01050f4:	c9                   	leave  
f01050f5:	c3                   	ret    

f01050f6 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f01050f6:	55                   	push   %ebp
f01050f7:	89 e5                	mov    %esp,%ebp
f01050f9:	53                   	push   %ebx
f01050fa:	83 ec 04             	sub    $0x4,%esp
f01050fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && (((uintptr_t)dstva % PGSIZE) != 0))
f0105100:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105106:	77 11                	ja     f0105119 <sys_ipc_recv+0x23>
		return -E_INVAL;
f0105108:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && (((uintptr_t)dstva % PGSIZE) != 0))
f010510d:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0105113:	0f 85 87 00 00 00    	jne    f01051a0 <sys_ipc_recv+0xaa>
		return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0105119:	e8 f4 12 00 00       	call   f0106412 <cpunum>
f010511e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105125:	29 c2                	sub    %eax,%edx
f0105127:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010512a:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0105131:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	if ((uintptr_t)dstva < UTOP)
f0105138:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010513e:	77 1d                	ja     f010515d <sys_ipc_recv+0x67>
		curenv->env_ipc_dstva = dstva;
f0105140:	e8 cd 12 00 00       	call   f0106412 <cpunum>
f0105145:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010514c:	29 c2                	sub    %eax,%edx
f010514e:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105151:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0105158:	89 58 6c             	mov    %ebx,0x6c(%eax)
f010515b:	eb 1f                	jmp    f010517c <sys_ipc_recv+0x86>
	else 
		curenv->env_ipc_dstva = (void *)UTOP;   // set UTOP as "no page"
f010515d:	e8 b0 12 00 00       	call   f0106412 <cpunum>
f0105162:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105169:	29 c2                	sub    %eax,%edx
f010516b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010516e:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0105175:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010517c:	e8 91 12 00 00       	call   f0106412 <cpunum>
f0105181:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105188:	29 c2                	sub    %eax,%edx
f010518a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010518d:	8b 04 95 28 f0 1b f0 	mov    -0xfe40fd8(,%edx,4),%eax
f0105194:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// shouldn't call sys_yield, because of trap call by timer
//	sys_yield();

//	panic("sys_ipc_recv not implemented");
	return 0;
f010519b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01051a0:	83 c4 04             	add    $0x4,%esp
f01051a3:	5b                   	pop    %ebx
f01051a4:	c9                   	leave  
f01051a5:	c3                   	ret    

f01051a6 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01051a6:	55                   	push   %ebp
f01051a7:	89 e5                	mov    %esp,%ebp
f01051a9:	57                   	push   %edi
f01051aa:	56                   	push   %esi
f01051ab:	53                   	push   %ebx
f01051ac:	83 ec 0c             	sub    $0xc,%esp
f01051af:	8b 55 08             	mov    0x8(%ebp),%edx
f01051b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01051b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01051b8:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01051bb:	8b 75 18             	mov    0x18(%ebp),%esi
//			cprintf("[%08x] sys_ipc_recv\n", curenv->env_id);
			return sys_ipc_recv((void *)a1);
		case NSYSCALLS: // What's this?? TODO	
			return -E_INVAL;
		default:	
			return -E_INVAL;
f01051be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
{
	int r;
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f01051c3:	83 fa 0e             	cmp    $0xe,%edx
f01051c6:	0f 87 c6 00 00 00    	ja     f0105292 <syscall+0xec>
f01051cc:	ff 24 95 14 7e 10 f0 	jmp    *-0xfef81ec(,%edx,4)
		case SYS_cputs:
//			cprintf("sys_cputs\n");
			sys_cputs((char *)a1, a2);
f01051d3:	83 ec 08             	sub    $0x8,%esp
f01051d6:	53                   	push   %ebx
f01051d7:	57                   	push   %edi
f01051d8:	e8 f3 f8 ff ff       	call   f0104ad0 <sys_cputs>
			return 0;
f01051dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01051e2:	e9 ab 00 00 00       	jmp    f0105292 <syscall+0xec>
		case SYS_cgetc:
//			cprintf("sys_cgetc\n");
			return sys_cgetc();
f01051e7:	e8 2c f9 ff ff       	call   f0104b18 <sys_cgetc>
f01051ec:	e9 a1 00 00 00       	jmp    f0105292 <syscall+0xec>
		case SYS_getenvid:
//			cprintf("sys_getenvid:%d\n", sys_getenvid());
			return sys_getenvid();
f01051f1:	e8 2f f9 ff ff       	call   f0104b25 <sys_getenvid>
f01051f6:	e9 97 00 00 00       	jmp    f0105292 <syscall+0xec>
		case SYS_env_destroy:
//			cprintf("sys_env_destroy\n");
			return sys_env_destroy((envid_t) a1);
f01051fb:	83 ec 0c             	sub    $0xc,%esp
f01051fe:	57                   	push   %edi
f01051ff:	e8 44 f9 ff ff       	call   f0104b48 <sys_env_destroy>
f0105204:	e9 89 00 00 00       	jmp    f0105292 <syscall+0xec>
		case SYS_page_alloc:
//			cprintf("sys_page_alloc\n");
			return sys_page_alloc(a1, (void *)a2, a3);
f0105209:	83 ec 04             	sub    $0x4,%esp
f010520c:	51                   	push   %ecx
f010520d:	53                   	push   %ebx
f010520e:	57                   	push   %edi
f010520f:	e8 df fa ff ff       	call   f0104cf3 <sys_page_alloc>
f0105214:	eb 7c                	jmp    f0105292 <syscall+0xec>
		case SYS_page_map:
//			cprintf("sys_page_map\n");
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0105216:	83 ec 0c             	sub    $0xc,%esp
f0105219:	ff 75 1c             	pushl  0x1c(%ebp)
f010521c:	56                   	push   %esi
f010521d:	51                   	push   %ecx
f010521e:	53                   	push   %ebx
f010521f:	57                   	push   %edi
f0105220:	e8 dd fb ff ff       	call   f0104e02 <sys_page_map>
f0105225:	eb 6b                	jmp    f0105292 <syscall+0xec>
		case SYS_page_unmap:
//			cprintf("sys_page_unmap\n");
			return sys_page_unmap(a1, (void *)a2);
f0105227:	83 ec 08             	sub    $0x8,%esp
f010522a:	53                   	push   %ebx
f010522b:	57                   	push   %edi
f010522c:	e8 c3 fc ff ff       	call   f0104ef4 <sys_page_unmap>
f0105231:	eb 5f                	jmp    f0105292 <syscall+0xec>
		case SYS_exofork:
//			cprintf("sys_exofork\n");
			return sys_exofork();
f0105233:	e8 4c f9 ff ff       	call   f0104b84 <sys_exofork>
f0105238:	eb 58                	jmp    f0105292 <syscall+0xec>
		case SYS_env_set_status:
//			cprintf("sys_env_set_status\n");
			return sys_env_set_status(a1, a2);
f010523a:	83 ec 08             	sub    $0x8,%esp
f010523d:	53                   	push   %ebx
f010523e:	57                   	push   %edi
f010523f:	e8 c5 f9 ff ff       	call   f0104c09 <sys_env_set_status>
f0105244:	eb 4c                	jmp    f0105292 <syscall+0xec>
		case SYS_env_set_trapframe:
			cprintf("sys_env_set_trapframe\n");
f0105246:	83 ec 0c             	sub    $0xc,%esp
f0105249:	68 fd 7d 10 f0       	push   $0xf0107dfd
f010524e:	e8 7f e7 ff ff       	call   f01039d2 <cprintf>
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f0105253:	83 c4 08             	add    $0x8,%esp
f0105256:	53                   	push   %ebx
f0105257:	57                   	push   %edi
f0105258:	e8 0e fa ff ff       	call   f0104c6b <sys_env_set_trapframe>
f010525d:	eb 33                	jmp    f0105292 <syscall+0xec>
		case SYS_env_set_pgfault_upcall:			
//			cprintf("sys_env_set_pgfault_upcall\n");
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
f010525f:	83 ec 08             	sub    $0x8,%esp
f0105262:	53                   	push   %ebx
f0105263:	57                   	push   %edi
f0105264:	e8 58 fa ff ff       	call   f0104cc1 <sys_env_set_pgfault_upcall>
f0105269:	eb 27                	jmp    f0105292 <syscall+0xec>
		case SYS_yield:
//			cprintf("sys_yield\n");
			sys_yield();
f010526b:	e8 09 f9 ff ff       	call   f0104b79 <sys_yield>
			return 0;
f0105270:	b8 00 00 00 00       	mov    $0x0,%eax
f0105275:	eb 1b                	jmp    f0105292 <syscall+0xec>
		case SYS_ipc_try_send:
//			cprintf("[%08x] sys_ipc_try_send\n", curenv->env_id);
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0105277:	56                   	push   %esi
f0105278:	51                   	push   %ecx
f0105279:	53                   	push   %ebx
f010527a:	57                   	push   %edi
f010527b:	e8 ca fc ff ff       	call   f0104f4a <sys_ipc_try_send>
f0105280:	eb 10                	jmp    f0105292 <syscall+0xec>
		case SYS_ipc_recv:
//			cprintf("[%08x] sys_ipc_recv\n", curenv->env_id);
			return sys_ipc_recv((void *)a1);
f0105282:	83 ec 0c             	sub    $0xc,%esp
f0105285:	57                   	push   %edi
f0105286:	e8 6b fe ff ff       	call   f01050f6 <sys_ipc_recv>
f010528b:	eb 05                	jmp    f0105292 <syscall+0xec>
		case NSYSCALLS: // What's this?? TODO	
			return -E_INVAL;
f010528d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		default:	
			return -E_INVAL;
	}

	panic("syscall not implemented");
}
f0105292:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105295:	5b                   	pop    %ebx
f0105296:	5e                   	pop    %esi
f0105297:	5f                   	pop    %edi
f0105298:	c9                   	leave  
f0105299:	c3                   	ret    
	...

f010529c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010529c:	55                   	push   %ebp
f010529d:	89 e5                	mov    %esp,%ebp
f010529f:	57                   	push   %edi
f01052a0:	56                   	push   %esi
f01052a1:	53                   	push   %ebx
f01052a2:	83 ec 0c             	sub    $0xc,%esp
f01052a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052ab:	8b 08                	mov    (%eax),%ecx
f01052ad:	8b 55 10             	mov    0x10(%ebp),%edx
f01052b0:	8b 12                	mov    (%edx),%edx
f01052b2:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01052b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
			l = m;
			addr++;
f01052bc:	39 d1                	cmp    %edx,%ecx
f01052be:	0f 8f 88 00 00 00    	jg     f010534c <stab_binsearch+0xb0>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01052c4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01052c7:	8d 04 19             	lea    (%ecx,%ebx,1),%eax
f01052ca:	89 c2                	mov    %eax,%edx
f01052cc:	c1 ea 1f             	shr    $0x1f,%edx
f01052cf:	01 d0                	add    %edx,%eax
f01052d1:	89 c3                	mov    %eax,%ebx
f01052d3:	d1 fb                	sar    %ebx
f01052d5:	89 da                	mov    %ebx,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01052d7:	39 cb                	cmp    %ecx,%ebx
f01052d9:	7c 23                	jl     f01052fe <stab_binsearch+0x62>
f01052db:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01052de:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f01052e3:	3b 45 14             	cmp    0x14(%ebp),%eax
f01052e6:	74 12                	je     f01052fa <stab_binsearch+0x5e>
f01052e8:	4a                   	dec    %edx
f01052e9:	39 ca                	cmp    %ecx,%edx
f01052eb:	7c 11                	jl     f01052fe <stab_binsearch+0x62>
f01052ed:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01052f0:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f01052f5:	3b 45 14             	cmp    0x14(%ebp),%eax
f01052f8:	75 ee                	jne    f01052e8 <stab_binsearch+0x4c>
		if (m < l) {	// no match in [l, m]
f01052fa:	39 ca                	cmp    %ecx,%edx
f01052fc:	7d 05                	jge    f0105303 <stab_binsearch+0x67>
			l = true_m + 1;
f01052fe:	8d 4b 01             	lea    0x1(%ebx),%ecx
			continue;
f0105301:	eb 40                	jmp    f0105343 <stab_binsearch+0xa7>
		}

		// actual binary search
		any_matches = 1;
f0105303:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		if (stabs[m].n_value < addr) {
f010530a:	8d 34 52             	lea    (%edx,%edx,2),%esi
f010530d:	8b 45 18             	mov    0x18(%ebp),%eax
f0105310:	39 44 b7 08          	cmp    %eax,0x8(%edi,%esi,4)
f0105314:	73 0a                	jae    f0105320 <stab_binsearch+0x84>
			*region_left = m;
f0105316:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105319:	89 16                	mov    %edx,(%esi)
			l = true_m + 1;
f010531b:	8d 4b 01             	lea    0x1(%ebx),%ecx
f010531e:	eb 23                	jmp    f0105343 <stab_binsearch+0xa7>
		} else if (stabs[m].n_value > addr) {
f0105320:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105323:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105326:	39 5c 87 08          	cmp    %ebx,0x8(%edi,%eax,4)
f010532a:	76 0d                	jbe    f0105339 <stab_binsearch+0x9d>
			*region_right = m - 1;
f010532c:	8d 42 ff             	lea    -0x1(%edx),%eax
f010532f:	8b 75 10             	mov    0x10(%ebp),%esi
f0105332:	89 06                	mov    %eax,(%esi)
			r = m - 1;
f0105334:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0105337:	eb 0a                	jmp    f0105343 <stab_binsearch+0xa7>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105339:	8b 45 0c             	mov    0xc(%ebp),%eax
f010533c:	89 10                	mov    %edx,(%eax)
			l = m;
f010533e:	89 d1                	mov    %edx,%ecx
			addr++;
f0105340:	ff 45 18             	incl   0x18(%ebp)
f0105343:	3b 4d e8             	cmp    -0x18(%ebp),%ecx
f0105346:	0f 8e 78 ff ff ff    	jle    f01052c4 <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f010534c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0105350:	75 0d                	jne    f010535f <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
f0105352:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105355:	8b 02                	mov    (%edx),%eax
f0105357:	48                   	dec    %eax
f0105358:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010535b:	89 03                	mov    %eax,(%ebx)
f010535d:	eb 33                	jmp    f0105392 <stab_binsearch+0xf6>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010535f:	8b 75 10             	mov    0x10(%ebp),%esi
f0105362:	8b 0e                	mov    (%esi),%ecx
f0105364:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105367:	39 08                	cmp    %ecx,(%eax)
f0105369:	7d 22                	jge    f010538d <stab_binsearch+0xf1>
f010536b:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f010536e:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f0105373:	3b 45 14             	cmp    0x14(%ebp),%eax
f0105376:	74 15                	je     f010538d <stab_binsearch+0xf1>
f0105378:	49                   	dec    %ecx
f0105379:	8b 55 0c             	mov    0xc(%ebp),%edx
f010537c:	39 0a                	cmp    %ecx,(%edx)
f010537e:	7d 0d                	jge    f010538d <stab_binsearch+0xf1>
f0105380:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0105383:	0f b6 44 87 04       	movzbl 0x4(%edi,%eax,4),%eax
f0105388:	3b 45 14             	cmp    0x14(%ebp),%eax
f010538b:	75 eb                	jne    f0105378 <stab_binsearch+0xdc>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f010538d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105390:	89 0b                	mov    %ecx,(%ebx)
	}
}
f0105392:	83 c4 0c             	add    $0xc,%esp
f0105395:	5b                   	pop    %ebx
f0105396:	5e                   	pop    %esi
f0105397:	5f                   	pop    %edi
f0105398:	c9                   	leave  
f0105399:	c3                   	ret    

f010539a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010539a:	55                   	push   %ebp
f010539b:	89 e5                	mov    %esp,%ebp
f010539d:	57                   	push   %edi
f010539e:	56                   	push   %esi
f010539f:	53                   	push   %ebx
f01053a0:	83 ec 1c             	sub    $0x1c,%esp
f01053a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01053a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01053a9:	c7 06 50 7e 10 f0    	movl   $0xf0107e50,(%esi)
	info->eip_line = 0;
f01053af:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01053b6:	c7 46 08 50 7e 10 f0 	movl   $0xf0107e50,0x8(%esi)
	info->eip_fn_namelen = 9;
f01053bd:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01053c4:	89 5e 10             	mov    %ebx,0x10(%esi)
	info->eip_fn_narg = 0;
f01053c7:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01053ce:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01053d4:	76 1a                	jbe    f01053f0 <debuginfo_eip+0x56>
		stabs = __STAB_BEGIN__;
f01053d6:	bf e4 83 10 f0       	mov    $0xf01083e4,%edi
		stab_end = __STAB_END__;
f01053db:	b8 74 6b 11 f0       	mov    $0xf0116b74,%eax
		stabstr = __STABSTR_BEGIN__;
f01053e0:	c7 45 e0 75 6b 11 f0 	movl   $0xf0116b75,-0x20(%ebp)
		stabstr_end = __STABSTR_END__;
f01053e7:	c7 45 dc 9b e0 11 f0 	movl   $0xf011e09b,-0x24(%ebp)
f01053ee:	eb 1d                	jmp    f010540d <debuginfo_eip+0x73>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01053f0:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f01053f6:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01053fb:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105401:	89 55 e0             	mov    %edx,-0x20(%ebp)
		stabstr_end = usd->stabstr_end;
f0105404:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010540a:	89 55 dc             	mov    %edx,-0x24(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010540d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105410:	39 55 dc             	cmp    %edx,-0x24(%ebp)
f0105413:	76 09                	jbe    f010541e <debuginfo_eip+0x84>
f0105415:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105418:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f010541c:	74 0a                	je     f0105428 <debuginfo_eip+0x8e>
		return -1;
f010541e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105423:	e9 59 01 00 00       	jmp    f0105581 <debuginfo_eip+0x1e7>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105428:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	rfile = (stab_end - stabs) - 1;
f010542f:	89 c2                	mov    %eax,%edx
f0105431:	29 fa                	sub    %edi,%edx
f0105433:	c1 fa 02             	sar    $0x2,%edx
f0105436:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0105439:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010543c:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010543f:	89 c2                	mov    %eax,%edx
f0105441:	c1 e2 08             	shl    $0x8,%edx
f0105444:	01 d0                	add    %edx,%eax
f0105446:	89 c2                	mov    %eax,%edx
f0105448:	c1 e2 10             	shl    $0x10,%edx
f010544b:	01 d0                	add    %edx,%eax
f010544d:	f7 d0                	not    %eax
f010544f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105452:	53                   	push   %ebx
f0105453:	6a 64                	push   $0x64
f0105455:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105458:	50                   	push   %eax
f0105459:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010545c:	50                   	push   %eax
f010545d:	57                   	push   %edi
f010545e:	e8 39 fe ff ff       	call   f010529c <stab_binsearch>
	if (lfile == 0)
f0105463:	83 c4 14             	add    $0x14,%esp
		return -1;
f0105466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010546b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010546f:	0f 84 0c 01 00 00    	je     f0105581 <debuginfo_eip+0x1e7>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105475:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105478:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	rfun = rfile;
f010547b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010547e:	89 45 e8             	mov    %eax,-0x18(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105481:	53                   	push   %ebx
f0105482:	6a 24                	push   $0x24
f0105484:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105487:	50                   	push   %eax
f0105488:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010548b:	50                   	push   %eax
f010548c:	57                   	push   %edi
f010548d:	e8 0a fe ff ff       	call   f010529c <stab_binsearch>

	if (lfun <= rfun) {
f0105492:	83 c4 14             	add    $0x14,%esp
f0105495:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105498:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f010549b:	7f 2f                	jg     f01054cc <debuginfo_eip+0x132>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010549d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01054a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01054a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01054aa:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01054ad:	39 04 3a             	cmp    %eax,(%edx,%edi,1)
f01054b0:	73 09                	jae    f01054bb <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01054b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054b5:	03 04 3a             	add    (%edx,%edi,1),%eax
f01054b8:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01054bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054be:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054c1:	8b 54 97 08          	mov    0x8(%edi,%edx,4),%edx
f01054c5:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f01054c8:	89 c3                	mov    %eax,%ebx
		rline = rfun;
f01054ca:	eb 06                	jmp    f01054d2 <debuginfo_eip+0x138>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01054cc:	89 5e 10             	mov    %ebx,0x10(%esi)
		lline = lfile;
f01054cf:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01054d2:	83 ec 08             	sub    $0x8,%esp
f01054d5:	6a 3a                	push   $0x3a
f01054d7:	ff 76 08             	pushl  0x8(%esi)
f01054da:	e8 98 07 00 00       	call   f0105c77 <strfind>
f01054df:	2b 46 08             	sub    0x8(%esi),%eax
f01054e2:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01054e5:	83 c4 10             	add    $0x10,%esp
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01054e8:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f01054eb:	7c 60                	jl     f010554d <debuginfo_eip+0x1b3>
f01054ed:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01054f0:	c1 e0 02             	shl    $0x2,%eax
f01054f3:	80 7c 38 04 84       	cmpb   $0x84,0x4(%eax,%edi,1)
f01054f8:	74 31                	je     f010552b <debuginfo_eip+0x191>
f01054fa:	80 7c 38 04 64       	cmpb   $0x64,0x4(%eax,%edi,1)
f01054ff:	75 07                	jne    f0105508 <debuginfo_eip+0x16e>
f0105501:	83 7c 38 08 00       	cmpl   $0x0,0x8(%eax,%edi,1)
f0105506:	75 23                	jne    f010552b <debuginfo_eip+0x191>
f0105508:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010550b:	4b                   	dec    %ebx
f010550c:	39 d3                	cmp    %edx,%ebx
f010550e:	7c 1b                	jl     f010552b <debuginfo_eip+0x191>
f0105510:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105513:	c1 e0 02             	shl    $0x2,%eax
f0105516:	80 7c 38 04 84       	cmpb   $0x84,0x4(%eax,%edi,1)
f010551b:	74 0e                	je     f010552b <debuginfo_eip+0x191>
f010551d:	80 7c 38 04 64       	cmpb   $0x64,0x4(%eax,%edi,1)
f0105522:	75 e7                	jne    f010550b <debuginfo_eip+0x171>
f0105524:	83 7c 38 08 00       	cmpl   $0x0,0x8(%eax,%edi,1)
f0105529:	74 e0                	je     f010550b <debuginfo_eip+0x171>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010552b:	3b 5d ec             	cmp    -0x14(%ebp),%ebx
f010552e:	7c 1d                	jl     f010554d <debuginfo_eip+0x1b3>
f0105530:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105533:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010553a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010553d:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0105540:	39 04 3a             	cmp    %eax,(%edx,%edi,1)
f0105543:	73 08                	jae    f010554d <debuginfo_eip+0x1b3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105545:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105548:	03 04 3a             	add    (%edx,%edi,1),%eax
f010554b:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010554d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105550:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0105553:	7d 27                	jge    f010557c <debuginfo_eip+0x1e2>
		for (lline = lfun + 1;
f0105555:	8d 58 01             	lea    0x1(%eax),%ebx
f0105558:	3b 5d e8             	cmp    -0x18(%ebp),%ebx
f010555b:	7d 1f                	jge    f010557c <debuginfo_eip+0x1e2>
f010555d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105560:	80 7c 87 04 a0       	cmpb   $0xa0,0x4(%edi,%eax,4)
f0105565:	75 15                	jne    f010557c <debuginfo_eip+0x1e2>
f0105567:	8b 55 e8             	mov    -0x18(%ebp),%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010556a:	ff 46 14             	incl   0x14(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010556d:	43                   	inc    %ebx
f010556e:	39 d3                	cmp    %edx,%ebx
f0105570:	7d 0a                	jge    f010557c <debuginfo_eip+0x1e2>
f0105572:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105575:	80 7c 87 04 a0       	cmpb   $0xa0,0x4(%edi,%eax,4)
f010557a:	74 ee                	je     f010556a <debuginfo_eip+0x1d0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f010557c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105581:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105584:	5b                   	pop    %ebx
f0105585:	5e                   	pop    %esi
f0105586:	5f                   	pop    %edi
f0105587:	c9                   	leave  
f0105588:	c3                   	ret    
f0105589:	00 00                	add    %al,(%eax)
	...

f010558c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010558c:	55                   	push   %ebp
f010558d:	89 e5                	mov    %esp,%ebp
f010558f:	57                   	push   %edi
f0105590:	56                   	push   %esi
f0105591:	53                   	push   %ebx
f0105592:	83 ec 0c             	sub    $0xc,%esp
f0105595:	8b 75 10             	mov    0x10(%ebp),%esi
f0105598:	8b 7d 14             	mov    0x14(%ebp),%edi
f010559b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010559e:	8b 45 18             	mov    0x18(%ebp),%eax
f01055a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01055a6:	39 fa                	cmp    %edi,%edx
f01055a8:	77 39                	ja     f01055e3 <printnum+0x57>
f01055aa:	72 04                	jb     f01055b0 <printnum+0x24>
f01055ac:	39 f0                	cmp    %esi,%eax
f01055ae:	77 33                	ja     f01055e3 <printnum+0x57>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01055b0:	83 ec 04             	sub    $0x4,%esp
f01055b3:	ff 75 20             	pushl  0x20(%ebp)
f01055b6:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01055b9:	50                   	push   %eax
f01055ba:	ff 75 18             	pushl  0x18(%ebp)
f01055bd:	8b 45 18             	mov    0x18(%ebp),%eax
f01055c0:	ba 00 00 00 00       	mov    $0x0,%edx
f01055c5:	52                   	push   %edx
f01055c6:	50                   	push   %eax
f01055c7:	57                   	push   %edi
f01055c8:	56                   	push   %esi
f01055c9:	e8 6e 11 00 00       	call   f010673c <__udivdi3>
f01055ce:	83 c4 10             	add    $0x10,%esp
f01055d1:	52                   	push   %edx
f01055d2:	50                   	push   %eax
f01055d3:	ff 75 0c             	pushl  0xc(%ebp)
f01055d6:	ff 75 08             	pushl  0x8(%ebp)
f01055d9:	e8 ae ff ff ff       	call   f010558c <printnum>
f01055de:	83 c4 20             	add    $0x20,%esp
f01055e1:	eb 19                	jmp    f01055fc <printnum+0x70>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01055e3:	4b                   	dec    %ebx
f01055e4:	85 db                	test   %ebx,%ebx
f01055e6:	7e 14                	jle    f01055fc <printnum+0x70>
f01055e8:	83 ec 08             	sub    $0x8,%esp
f01055eb:	ff 75 0c             	pushl  0xc(%ebp)
f01055ee:	ff 75 20             	pushl  0x20(%ebp)
f01055f1:	ff 55 08             	call   *0x8(%ebp)
f01055f4:	83 c4 10             	add    $0x10,%esp
f01055f7:	4b                   	dec    %ebx
f01055f8:	85 db                	test   %ebx,%ebx
f01055fa:	7f ec                	jg     f01055e8 <printnum+0x5c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01055fc:	83 ec 08             	sub    $0x8,%esp
f01055ff:	ff 75 0c             	pushl  0xc(%ebp)
f0105602:	8b 45 18             	mov    0x18(%ebp),%eax
f0105605:	ba 00 00 00 00       	mov    $0x0,%edx
f010560a:	83 ec 04             	sub    $0x4,%esp
f010560d:	52                   	push   %edx
f010560e:	50                   	push   %eax
f010560f:	57                   	push   %edi
f0105610:	56                   	push   %esi
f0105611:	e8 32 12 00 00       	call   f0106848 <__umoddi3>
f0105616:	83 c4 14             	add    $0x14,%esp
f0105619:	0f be 80 6c 7f 10 f0 	movsbl -0xfef8094(%eax),%eax
f0105620:	50                   	push   %eax
f0105621:	ff 55 08             	call   *0x8(%ebp)
}
f0105624:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105627:	5b                   	pop    %ebx
f0105628:	5e                   	pop    %esi
f0105629:	5f                   	pop    %edi
f010562a:	c9                   	leave  
f010562b:	c3                   	ret    

f010562c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010562c:	55                   	push   %ebp
f010562d:	89 e5                	mov    %esp,%ebp
f010562f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105632:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f0105635:	83 f8 01             	cmp    $0x1,%eax
f0105638:	7e 0e                	jle    f0105648 <getuint+0x1c>
		return va_arg(*ap, unsigned long long);
f010563a:	8b 11                	mov    (%ecx),%edx
f010563c:	8d 42 08             	lea    0x8(%edx),%eax
f010563f:	89 01                	mov    %eax,(%ecx)
f0105641:	8b 02                	mov    (%edx),%eax
f0105643:	8b 52 04             	mov    0x4(%edx),%edx
f0105646:	eb 22                	jmp    f010566a <getuint+0x3e>
	else if (lflag)
f0105648:	85 c0                	test   %eax,%eax
f010564a:	74 10                	je     f010565c <getuint+0x30>
		return va_arg(*ap, unsigned long);
f010564c:	8b 11                	mov    (%ecx),%edx
f010564e:	8d 42 04             	lea    0x4(%edx),%eax
f0105651:	89 01                	mov    %eax,(%ecx)
f0105653:	8b 02                	mov    (%edx),%eax
f0105655:	ba 00 00 00 00       	mov    $0x0,%edx
f010565a:	eb 0e                	jmp    f010566a <getuint+0x3e>
	else
		return va_arg(*ap, unsigned int);
f010565c:	8b 11                	mov    (%ecx),%edx
f010565e:	8d 42 04             	lea    0x4(%edx),%eax
f0105661:	89 01                	mov    %eax,(%ecx)
f0105663:	8b 02                	mov    (%edx),%eax
f0105665:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010566a:	c9                   	leave  
f010566b:	c3                   	ret    

f010566c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f010566c:	55                   	push   %ebp
f010566d:	89 e5                	mov    %esp,%ebp
f010566f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105672:	8b 45 0c             	mov    0xc(%ebp),%eax
	if (lflag >= 2)
f0105675:	83 f8 01             	cmp    $0x1,%eax
f0105678:	7e 0e                	jle    f0105688 <getint+0x1c>
		return va_arg(*ap, long long);
f010567a:	8b 11                	mov    (%ecx),%edx
f010567c:	8d 42 08             	lea    0x8(%edx),%eax
f010567f:	89 01                	mov    %eax,(%ecx)
f0105681:	8b 02                	mov    (%edx),%eax
f0105683:	8b 52 04             	mov    0x4(%edx),%edx
f0105686:	eb 1a                	jmp    f01056a2 <getint+0x36>
	else if (lflag)
f0105688:	85 c0                	test   %eax,%eax
f010568a:	74 0c                	je     f0105698 <getint+0x2c>
		return va_arg(*ap, long);
f010568c:	8b 01                	mov    (%ecx),%eax
f010568e:	8d 50 04             	lea    0x4(%eax),%edx
f0105691:	89 11                	mov    %edx,(%ecx)
f0105693:	8b 00                	mov    (%eax),%eax
f0105695:	99                   	cltd   
f0105696:	eb 0a                	jmp    f01056a2 <getint+0x36>
	else
		return va_arg(*ap, int);
f0105698:	8b 01                	mov    (%ecx),%eax
f010569a:	8d 50 04             	lea    0x4(%eax),%edx
f010569d:	89 11                	mov    %edx,(%ecx)
f010569f:	8b 00                	mov    (%eax),%eax
f01056a1:	99                   	cltd   
}
f01056a2:	c9                   	leave  
f01056a3:	c3                   	ret    

f01056a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01056a4:	55                   	push   %ebp
f01056a5:	89 e5                	mov    %esp,%ebp
f01056a7:	57                   	push   %edi
f01056a8:	56                   	push   %esi
f01056a9:	53                   	push   %ebx
f01056aa:	83 ec 1c             	sub    $0x1c,%esp
f01056ad:	8b 5d 10             	mov    0x10(%ebp),%ebx

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
			putch(ch, putdat);
f01056b0:	0f b6 0b             	movzbl (%ebx),%ecx
f01056b3:	43                   	inc    %ebx
f01056b4:	83 f9 25             	cmp    $0x25,%ecx
f01056b7:	74 1e                	je     f01056d7 <vprintfmt+0x33>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01056b9:	85 c9                	test   %ecx,%ecx
f01056bb:	0f 84 dc 02 00 00    	je     f010599d <vprintfmt+0x2f9>
				return;
			putch(ch, putdat);
f01056c1:	83 ec 08             	sub    $0x8,%esp
f01056c4:	ff 75 0c             	pushl  0xc(%ebp)
f01056c7:	51                   	push   %ecx
f01056c8:	ff 55 08             	call   *0x8(%ebp)
f01056cb:	83 c4 10             	add    $0x10,%esp
f01056ce:	0f b6 0b             	movzbl (%ebx),%ecx
f01056d1:	43                   	inc    %ebx
f01056d2:	83 f9 25             	cmp    $0x25,%ecx
f01056d5:	75 e2                	jne    f01056b9 <vprintfmt+0x15>
		}

		// Process a %-escape sequence
		padc = ' ';
f01056d7:	c6 45 eb 20          	movb   $0x20,-0x15(%ebp)
		width = -1;
f01056db:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
		precision = -1;
f01056e2:	be ff ff ff ff       	mov    $0xffffffff,%esi
		lflag = 0;
f01056e7:	bf 00 00 00 00       	mov    $0x0,%edi
		altflag = 0;
f01056ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056f3:	0f b6 0b             	movzbl (%ebx),%ecx
f01056f6:	8d 41 dd             	lea    -0x23(%ecx),%eax
f01056f9:	43                   	inc    %ebx
f01056fa:	83 f8 55             	cmp    $0x55,%eax
f01056fd:	0f 87 75 02 00 00    	ja     f0105978 <vprintfmt+0x2d4>
f0105703:	ff 24 85 00 80 10 f0 	jmp    *-0xfef8000(,%eax,4)

		// flag to pad on the right
		case '-':
			padc = '-';
f010570a:	c6 45 eb 2d          	movb   $0x2d,-0x15(%ebp)
			goto reswitch;
f010570e:	eb e3                	jmp    f01056f3 <vprintfmt+0x4f>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105710:	c6 45 eb 30          	movb   $0x30,-0x15(%ebp)
			goto reswitch;
f0105714:	eb dd                	jmp    f01056f3 <vprintfmt+0x4f>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105716:	be 00 00 00 00       	mov    $0x0,%esi
				precision = precision * 10 + ch - '0';
f010571b:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f010571e:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
f0105722:	0f be 0b             	movsbl (%ebx),%ecx
				if (ch < '0' || ch > '9')
f0105725:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0105728:	83 f8 09             	cmp    $0x9,%eax
f010572b:	77 28                	ja     f0105755 <vprintfmt+0xb1>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010572d:	43                   	inc    %ebx
f010572e:	eb eb                	jmp    f010571b <vprintfmt+0x77>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105730:	8b 55 14             	mov    0x14(%ebp),%edx
f0105733:	8d 42 04             	lea    0x4(%edx),%eax
f0105736:	89 45 14             	mov    %eax,0x14(%ebp)
f0105739:	8b 32                	mov    (%edx),%esi
			goto process_precision;
f010573b:	eb 18                	jmp    f0105755 <vprintfmt+0xb1>

		case '.':
			if (width < 0)
f010573d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0105741:	79 b0                	jns    f01056f3 <vprintfmt+0x4f>
				width = 0;
f0105743:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
			goto reswitch;
f010574a:	eb a7                	jmp    f01056f3 <vprintfmt+0x4f>

		case '#':
			altflag = 1;
f010574c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			goto reswitch;
f0105753:	eb 9e                	jmp    f01056f3 <vprintfmt+0x4f>

		process_precision:
			if (width < 0)
f0105755:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0105759:	79 98                	jns    f01056f3 <vprintfmt+0x4f>
				width = precision, precision = -1;
f010575b:	89 75 f0             	mov    %esi,-0x10(%ebp)
f010575e:	be ff ff ff ff       	mov    $0xffffffff,%esi
			goto reswitch;
f0105763:	eb 8e                	jmp    f01056f3 <vprintfmt+0x4f>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105765:	47                   	inc    %edi
			goto reswitch;
f0105766:	eb 8b                	jmp    f01056f3 <vprintfmt+0x4f>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105768:	83 ec 08             	sub    $0x8,%esp
f010576b:	ff 75 0c             	pushl  0xc(%ebp)
f010576e:	8b 55 14             	mov    0x14(%ebp),%edx
f0105771:	8d 42 04             	lea    0x4(%edx),%eax
f0105774:	89 45 14             	mov    %eax,0x14(%ebp)
f0105777:	ff 32                	pushl  (%edx)
f0105779:	ff 55 08             	call   *0x8(%ebp)
			break;
f010577c:	83 c4 10             	add    $0x10,%esp
f010577f:	e9 2c ff ff ff       	jmp    f01056b0 <vprintfmt+0xc>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105784:	8b 55 14             	mov    0x14(%ebp),%edx
f0105787:	8d 42 04             	lea    0x4(%edx),%eax
f010578a:	89 45 14             	mov    %eax,0x14(%ebp)
f010578d:	8b 02                	mov    (%edx),%eax
			if (err < 0)
f010578f:	85 c0                	test   %eax,%eax
f0105791:	79 02                	jns    f0105795 <vprintfmt+0xf1>
				err = -err;
f0105793:	f7 d8                	neg    %eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105795:	83 f8 0f             	cmp    $0xf,%eax
f0105798:	7f 0b                	jg     f01057a5 <vprintfmt+0x101>
f010579a:	8b 3c 85 c0 7f 10 f0 	mov    -0xfef8040(,%eax,4),%edi
f01057a1:	85 ff                	test   %edi,%edi
f01057a3:	75 19                	jne    f01057be <vprintfmt+0x11a>
				printfmt(putch, putdat, "error %d", err);
f01057a5:	50                   	push   %eax
f01057a6:	68 7d 7f 10 f0       	push   $0xf0107f7d
f01057ab:	ff 75 0c             	pushl  0xc(%ebp)
f01057ae:	ff 75 08             	pushl  0x8(%ebp)
f01057b1:	e8 ef 01 00 00       	call   f01059a5 <printfmt>
f01057b6:	83 c4 10             	add    $0x10,%esp
f01057b9:	e9 f2 fe ff ff       	jmp    f01056b0 <vprintfmt+0xc>
			else
				printfmt(putch, putdat, "%s", p);
f01057be:	57                   	push   %edi
f01057bf:	68 97 75 10 f0       	push   $0xf0107597
f01057c4:	ff 75 0c             	pushl  0xc(%ebp)
f01057c7:	ff 75 08             	pushl  0x8(%ebp)
f01057ca:	e8 d6 01 00 00       	call   f01059a5 <printfmt>
f01057cf:	83 c4 10             	add    $0x10,%esp
			break;
f01057d2:	e9 d9 fe ff ff       	jmp    f01056b0 <vprintfmt+0xc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01057d7:	8b 55 14             	mov    0x14(%ebp),%edx
f01057da:	8d 42 04             	lea    0x4(%edx),%eax
f01057dd:	89 45 14             	mov    %eax,0x14(%ebp)
f01057e0:	8b 3a                	mov    (%edx),%edi
f01057e2:	85 ff                	test   %edi,%edi
f01057e4:	75 05                	jne    f01057eb <vprintfmt+0x147>
				p = "(null)";
f01057e6:	bf 86 7f 10 f0       	mov    $0xf0107f86,%edi
			if (width > 0 && padc != '-')
f01057eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01057ef:	7e 3b                	jle    f010582c <vprintfmt+0x188>
f01057f1:	80 7d eb 2d          	cmpb   $0x2d,-0x15(%ebp)
f01057f5:	74 35                	je     f010582c <vprintfmt+0x188>
				for (width -= strnlen(p, precision); width > 0; width--)
f01057f7:	83 ec 08             	sub    $0x8,%esp
f01057fa:	56                   	push   %esi
f01057fb:	57                   	push   %edi
f01057fc:	e8 24 03 00 00       	call   f0105b25 <strnlen>
f0105801:	29 45 f0             	sub    %eax,-0x10(%ebp)
f0105804:	83 c4 10             	add    $0x10,%esp
f0105807:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010580b:	7e 1f                	jle    f010582c <vprintfmt+0x188>
f010580d:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
f0105811:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(padc, putdat);
f0105814:	83 ec 08             	sub    $0x8,%esp
f0105817:	ff 75 0c             	pushl  0xc(%ebp)
f010581a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010581d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105820:	83 c4 10             	add    $0x10,%esp
f0105823:	ff 4d f0             	decl   -0x10(%ebp)
f0105826:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010582a:	7f e8                	jg     f0105814 <vprintfmt+0x170>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010582c:	0f be 0f             	movsbl (%edi),%ecx
f010582f:	47                   	inc    %edi
f0105830:	85 c9                	test   %ecx,%ecx
f0105832:	74 44                	je     f0105878 <vprintfmt+0x1d4>
f0105834:	85 f6                	test   %esi,%esi
f0105836:	78 03                	js     f010583b <vprintfmt+0x197>
f0105838:	4e                   	dec    %esi
f0105839:	78 3d                	js     f0105878 <vprintfmt+0x1d4>
				if (altflag && (ch < ' ' || ch > '~'))
f010583b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010583f:	74 18                	je     f0105859 <vprintfmt+0x1b5>
f0105841:	8d 41 e0             	lea    -0x20(%ecx),%eax
f0105844:	83 f8 5e             	cmp    $0x5e,%eax
f0105847:	76 10                	jbe    f0105859 <vprintfmt+0x1b5>
					putch('?', putdat);
f0105849:	83 ec 08             	sub    $0x8,%esp
f010584c:	ff 75 0c             	pushl  0xc(%ebp)
f010584f:	6a 3f                	push   $0x3f
f0105851:	ff 55 08             	call   *0x8(%ebp)
f0105854:	83 c4 10             	add    $0x10,%esp
f0105857:	eb 0d                	jmp    f0105866 <vprintfmt+0x1c2>
				else
					putch(ch, putdat);
f0105859:	83 ec 08             	sub    $0x8,%esp
f010585c:	ff 75 0c             	pushl  0xc(%ebp)
f010585f:	51                   	push   %ecx
f0105860:	ff 55 08             	call   *0x8(%ebp)
f0105863:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105866:	ff 4d f0             	decl   -0x10(%ebp)
f0105869:	0f be 0f             	movsbl (%edi),%ecx
f010586c:	47                   	inc    %edi
f010586d:	85 c9                	test   %ecx,%ecx
f010586f:	74 07                	je     f0105878 <vprintfmt+0x1d4>
f0105871:	85 f6                	test   %esi,%esi
f0105873:	78 c6                	js     f010583b <vprintfmt+0x197>
f0105875:	4e                   	dec    %esi
f0105876:	79 c3                	jns    f010583b <vprintfmt+0x197>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105878:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010587c:	0f 8e 2e fe ff ff    	jle    f01056b0 <vprintfmt+0xc>
				putch(' ', putdat);
f0105882:	83 ec 08             	sub    $0x8,%esp
f0105885:	ff 75 0c             	pushl  0xc(%ebp)
f0105888:	6a 20                	push   $0x20
f010588a:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010588d:	83 c4 10             	add    $0x10,%esp
f0105890:	ff 4d f0             	decl   -0x10(%ebp)
f0105893:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0105897:	7f e9                	jg     f0105882 <vprintfmt+0x1de>
				putch(' ', putdat);
			break;
f0105899:	e9 12 fe ff ff       	jmp    f01056b0 <vprintfmt+0xc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010589e:	57                   	push   %edi
f010589f:	8d 45 14             	lea    0x14(%ebp),%eax
f01058a2:	50                   	push   %eax
f01058a3:	e8 c4 fd ff ff       	call   f010566c <getint>
f01058a8:	89 c6                	mov    %eax,%esi
f01058aa:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f01058ac:	83 c4 08             	add    $0x8,%esp
f01058af:	85 d2                	test   %edx,%edx
f01058b1:	79 15                	jns    f01058c8 <vprintfmt+0x224>
				putch('-', putdat);
f01058b3:	83 ec 08             	sub    $0x8,%esp
f01058b6:	ff 75 0c             	pushl  0xc(%ebp)
f01058b9:	6a 2d                	push   $0x2d
f01058bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01058be:	f7 de                	neg    %esi
f01058c0:	83 d7 00             	adc    $0x0,%edi
f01058c3:	f7 df                	neg    %edi
f01058c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01058c8:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f01058cd:	eb 76                	jmp    f0105945 <vprintfmt+0x2a1>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01058cf:	57                   	push   %edi
f01058d0:	8d 45 14             	lea    0x14(%ebp),%eax
f01058d3:	50                   	push   %eax
f01058d4:	e8 53 fd ff ff       	call   f010562c <getuint>
f01058d9:	89 c6                	mov    %eax,%esi
f01058db:	89 d7                	mov    %edx,%edi
			base = 10;
f01058dd:	ba 0a 00 00 00       	mov    $0xa,%edx
			goto number;
f01058e2:	83 c4 08             	add    $0x8,%esp
f01058e5:	eb 5e                	jmp    f0105945 <vprintfmt+0x2a1>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01058e7:	57                   	push   %edi
f01058e8:	8d 45 14             	lea    0x14(%ebp),%eax
f01058eb:	50                   	push   %eax
f01058ec:	e8 3b fd ff ff       	call   f010562c <getuint>
f01058f1:	89 c6                	mov    %eax,%esi
f01058f3:	89 d7                	mov    %edx,%edi
			base = 8;
f01058f5:	ba 08 00 00 00       	mov    $0x8,%edx
			goto number;
f01058fa:	83 c4 08             	add    $0x8,%esp
f01058fd:	eb 46                	jmp    f0105945 <vprintfmt+0x2a1>

		// pointer
		case 'p':
			putch('0', putdat);
f01058ff:	83 ec 08             	sub    $0x8,%esp
f0105902:	ff 75 0c             	pushl  0xc(%ebp)
f0105905:	6a 30                	push   $0x30
f0105907:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010590a:	83 c4 08             	add    $0x8,%esp
f010590d:	ff 75 0c             	pushl  0xc(%ebp)
f0105910:	6a 78                	push   $0x78
f0105912:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0105915:	8b 55 14             	mov    0x14(%ebp),%edx
f0105918:	8d 42 04             	lea    0x4(%edx),%eax
f010591b:	89 45 14             	mov    %eax,0x14(%ebp)
f010591e:	8b 32                	mov    (%edx),%esi
f0105920:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105925:	ba 10 00 00 00       	mov    $0x10,%edx
			goto number;
f010592a:	83 c4 10             	add    $0x10,%esp
f010592d:	eb 16                	jmp    f0105945 <vprintfmt+0x2a1>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010592f:	57                   	push   %edi
f0105930:	8d 45 14             	lea    0x14(%ebp),%eax
f0105933:	50                   	push   %eax
f0105934:	e8 f3 fc ff ff       	call   f010562c <getuint>
f0105939:	89 c6                	mov    %eax,%esi
f010593b:	89 d7                	mov    %edx,%edi
			base = 16;
f010593d:	ba 10 00 00 00       	mov    $0x10,%edx
f0105942:	83 c4 08             	add    $0x8,%esp
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105945:	83 ec 04             	sub    $0x4,%esp
f0105948:	0f be 45 eb          	movsbl -0x15(%ebp),%eax
f010594c:	50                   	push   %eax
f010594d:	ff 75 f0             	pushl  -0x10(%ebp)
f0105950:	52                   	push   %edx
f0105951:	57                   	push   %edi
f0105952:	56                   	push   %esi
f0105953:	ff 75 0c             	pushl  0xc(%ebp)
f0105956:	ff 75 08             	pushl  0x8(%ebp)
f0105959:	e8 2e fc ff ff       	call   f010558c <printnum>
			break;
f010595e:	83 c4 20             	add    $0x20,%esp
f0105961:	e9 4a fd ff ff       	jmp    f01056b0 <vprintfmt+0xc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105966:	83 ec 08             	sub    $0x8,%esp
f0105969:	ff 75 0c             	pushl  0xc(%ebp)
f010596c:	51                   	push   %ecx
f010596d:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105970:	83 c4 10             	add    $0x10,%esp
f0105973:	e9 38 fd ff ff       	jmp    f01056b0 <vprintfmt+0xc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105978:	83 ec 08             	sub    $0x8,%esp
f010597b:	ff 75 0c             	pushl  0xc(%ebp)
f010597e:	6a 25                	push   $0x25
f0105980:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105983:	4b                   	dec    %ebx
f0105984:	83 c4 10             	add    $0x10,%esp
f0105987:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f010598b:	0f 84 1f fd ff ff    	je     f01056b0 <vprintfmt+0xc>
f0105991:	4b                   	dec    %ebx
f0105992:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105996:	75 f9                	jne    f0105991 <vprintfmt+0x2ed>
				/* do nothing */;
			break;
f0105998:	e9 13 fd ff ff       	jmp    f01056b0 <vprintfmt+0xc>
		}
	}
}
f010599d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059a0:	5b                   	pop    %ebx
f01059a1:	5e                   	pop    %esi
f01059a2:	5f                   	pop    %edi
f01059a3:	c9                   	leave  
f01059a4:	c3                   	ret    

f01059a5 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01059a5:	55                   	push   %ebp
f01059a6:	89 e5                	mov    %esp,%ebp
f01059a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01059ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01059ae:	50                   	push   %eax
f01059af:	ff 75 10             	pushl  0x10(%ebp)
f01059b2:	ff 75 0c             	pushl  0xc(%ebp)
f01059b5:	ff 75 08             	pushl  0x8(%ebp)
f01059b8:	e8 e7 fc ff ff       	call   f01056a4 <vprintfmt>
	va_end(ap);
}
f01059bd:	c9                   	leave  
f01059be:	c3                   	ret    

f01059bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01059bf:	55                   	push   %ebp
f01059c0:	89 e5                	mov    %esp,%ebp
f01059c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f01059c5:	ff 42 08             	incl   0x8(%edx)
	if (b->buf < b->ebuf)
f01059c8:	8b 0a                	mov    (%edx),%ecx
f01059ca:	3b 4a 04             	cmp    0x4(%edx),%ecx
f01059cd:	73 07                	jae    f01059d6 <sprintputch+0x17>
		*b->buf++ = ch;
f01059cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01059d2:	88 01                	mov    %al,(%ecx)
f01059d4:	ff 02                	incl   (%edx)
}
f01059d6:	c9                   	leave  
f01059d7:	c3                   	ret    

f01059d8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01059d8:	55                   	push   %ebp
f01059d9:	89 e5                	mov    %esp,%ebp
f01059db:	83 ec 18             	sub    $0x18,%esp
f01059de:	8b 55 08             	mov    0x8(%ebp),%edx
f01059e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01059e4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01059e7:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
f01059eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01059ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (buf == NULL || n < 1)
f01059f5:	85 d2                	test   %edx,%edx
f01059f7:	74 04                	je     f01059fd <vsnprintf+0x25>
f01059f9:	85 c9                	test   %ecx,%ecx
f01059fb:	7f 07                	jg     f0105a04 <vsnprintf+0x2c>
		return -E_INVAL;
f01059fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105a02:	eb 1d                	jmp    f0105a21 <vsnprintf+0x49>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105a04:	ff 75 14             	pushl  0x14(%ebp)
f0105a07:	ff 75 10             	pushl  0x10(%ebp)
f0105a0a:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105a0d:	50                   	push   %eax
f0105a0e:	68 bf 59 10 f0       	push   $0xf01059bf
f0105a13:	e8 8c fc ff ff       	call   f01056a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a18:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105a1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0105a21:	c9                   	leave  
f0105a22:	c3                   	ret    

f0105a23 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a23:	55                   	push   %ebp
f0105a24:	89 e5                	mov    %esp,%ebp
f0105a26:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a29:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a2c:	50                   	push   %eax
f0105a2d:	ff 75 10             	pushl  0x10(%ebp)
f0105a30:	ff 75 0c             	pushl  0xc(%ebp)
f0105a33:	ff 75 08             	pushl  0x8(%ebp)
f0105a36:	e8 9d ff ff ff       	call   f01059d8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a3b:	c9                   	leave  
f0105a3c:	c3                   	ret    
f0105a3d:	00 00                	add    %al,(%eax)
	...

f0105a40 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105a40:	55                   	push   %ebp
f0105a41:	89 e5                	mov    %esp,%ebp
f0105a43:	57                   	push   %edi
f0105a44:	56                   	push   %esi
f0105a45:	53                   	push   %ebx
f0105a46:	83 ec 0c             	sub    $0xc,%esp
f0105a49:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105a4c:	85 c0                	test   %eax,%eax
f0105a4e:	74 11                	je     f0105a61 <readline+0x21>
		cprintf("%s", prompt);
f0105a50:	83 ec 08             	sub    $0x8,%esp
f0105a53:	50                   	push   %eax
f0105a54:	68 97 75 10 f0       	push   $0xf0107597
f0105a59:	e8 74 df ff ff       	call   f01039d2 <cprintf>
f0105a5e:	83 c4 10             	add    $0x10,%esp

	i = 0;
f0105a61:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
f0105a66:	83 ec 0c             	sub    $0xc,%esp
f0105a69:	6a 00                	push   $0x0
f0105a6b:	e8 e7 ad ff ff       	call   f0100857 <iscons>
f0105a70:	89 c7                	mov    %eax,%edi
	while (1) {
f0105a72:	83 c4 10             	add    $0x10,%esp
		c = getchar();
f0105a75:	e8 cc ad ff ff       	call   f0100846 <getchar>
f0105a7a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105a7c:	85 c0                	test   %eax,%eax
f0105a7e:	79 15                	jns    f0105a95 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105a80:	83 ec 08             	sub    $0x8,%esp
f0105a83:	50                   	push   %eax
f0105a84:	68 58 81 10 f0       	push   $0xf0108158
f0105a89:	e8 44 df ff ff       	call   f01039d2 <cprintf>
			return NULL;
f0105a8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a93:	eb 6f                	jmp    f0105b04 <readline+0xc4>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105a95:	83 f8 08             	cmp    $0x8,%eax
f0105a98:	74 05                	je     f0105a9f <readline+0x5f>
f0105a9a:	83 f8 7f             	cmp    $0x7f,%eax
f0105a9d:	75 18                	jne    f0105ab7 <readline+0x77>
f0105a9f:	85 f6                	test   %esi,%esi
f0105aa1:	7e 14                	jle    f0105ab7 <readline+0x77>
			if (echoing)
f0105aa3:	85 ff                	test   %edi,%edi
f0105aa5:	74 0d                	je     f0105ab4 <readline+0x74>
				cputchar('\b');
f0105aa7:	83 ec 0c             	sub    $0xc,%esp
f0105aaa:	6a 08                	push   $0x8
f0105aac:	e8 85 ad ff ff       	call   f0100836 <cputchar>
f0105ab1:	83 c4 10             	add    $0x10,%esp
			i--;
f0105ab4:	4e                   	dec    %esi
f0105ab5:	eb be                	jmp    f0105a75 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105ab7:	83 fb 1f             	cmp    $0x1f,%ebx
f0105aba:	7e 21                	jle    f0105add <readline+0x9d>
f0105abc:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105ac2:	7f 19                	jg     f0105add <readline+0x9d>
			if (echoing)
f0105ac4:	85 ff                	test   %edi,%edi
f0105ac6:	74 0c                	je     f0105ad4 <readline+0x94>
				cputchar(c);
f0105ac8:	83 ec 0c             	sub    $0xc,%esp
f0105acb:	53                   	push   %ebx
f0105acc:	e8 65 ad ff ff       	call   f0100836 <cputchar>
f0105ad1:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105ad4:	88 9e e0 ea 1b f0    	mov    %bl,-0xfe41520(%esi)
f0105ada:	46                   	inc    %esi
f0105adb:	eb 98                	jmp    f0105a75 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105add:	83 fb 0a             	cmp    $0xa,%ebx
f0105ae0:	74 05                	je     f0105ae7 <readline+0xa7>
f0105ae2:	83 fb 0d             	cmp    $0xd,%ebx
f0105ae5:	75 8e                	jne    f0105a75 <readline+0x35>
			if (echoing)
f0105ae7:	85 ff                	test   %edi,%edi
f0105ae9:	74 0d                	je     f0105af8 <readline+0xb8>
				cputchar('\n');
f0105aeb:	83 ec 0c             	sub    $0xc,%esp
f0105aee:	6a 0a                	push   $0xa
f0105af0:	e8 41 ad ff ff       	call   f0100836 <cputchar>
f0105af5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105af8:	c6 86 e0 ea 1b f0 00 	movb   $0x0,-0xfe41520(%esi)
			return buf;
f0105aff:	b8 e0 ea 1b f0       	mov    $0xf01beae0,%eax
		}
	}
}
f0105b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b07:	5b                   	pop    %ebx
f0105b08:	5e                   	pop    %esi
f0105b09:	5f                   	pop    %edi
f0105b0a:	c9                   	leave  
f0105b0b:	c3                   	ret    

f0105b0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b0c:	55                   	push   %ebp
f0105b0d:	89 e5                	mov    %esp,%ebp
f0105b0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b12:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b17:	80 3a 00             	cmpb   $0x0,(%edx)
f0105b1a:	74 07                	je     f0105b23 <strlen+0x17>
		n++;
f0105b1c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b1d:	42                   	inc    %edx
f0105b1e:	80 3a 00             	cmpb   $0x0,(%edx)
f0105b21:	75 f9                	jne    f0105b1c <strlen+0x10>
		n++;
	return n;
}
f0105b23:	c9                   	leave  
f0105b24:	c3                   	ret    

f0105b25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b25:	55                   	push   %ebp
f0105b26:	89 e5                	mov    %esp,%ebp
f0105b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b33:	85 d2                	test   %edx,%edx
f0105b35:	74 0f                	je     f0105b46 <strnlen+0x21>
f0105b37:	80 39 00             	cmpb   $0x0,(%ecx)
f0105b3a:	74 0a                	je     f0105b46 <strnlen+0x21>
		n++;
f0105b3c:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b3d:	41                   	inc    %ecx
f0105b3e:	4a                   	dec    %edx
f0105b3f:	74 05                	je     f0105b46 <strnlen+0x21>
f0105b41:	80 39 00             	cmpb   $0x0,(%ecx)
f0105b44:	75 f6                	jne    f0105b3c <strnlen+0x17>
		n++;
	return n;
}
f0105b46:	c9                   	leave  
f0105b47:	c3                   	ret    

f0105b48 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105b48:	55                   	push   %ebp
f0105b49:	89 e5                	mov    %esp,%ebp
f0105b4b:	53                   	push   %ebx
f0105b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	char *ret;

	ret = dst;
f0105b52:	89 cb                	mov    %ecx,%ebx
	while ((*dst++ = *src++) != '\0')
f0105b54:	8a 02                	mov    (%edx),%al
f0105b56:	42                   	inc    %edx
f0105b57:	88 01                	mov    %al,(%ecx)
f0105b59:	41                   	inc    %ecx
f0105b5a:	84 c0                	test   %al,%al
f0105b5c:	75 f6                	jne    f0105b54 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105b5e:	89 d8                	mov    %ebx,%eax
f0105b60:	5b                   	pop    %ebx
f0105b61:	c9                   	leave  
f0105b62:	c3                   	ret    

f0105b63 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105b63:	55                   	push   %ebp
f0105b64:	89 e5                	mov    %esp,%ebp
f0105b66:	53                   	push   %ebx
f0105b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105b6a:	53                   	push   %ebx
f0105b6b:	e8 9c ff ff ff       	call   f0105b0c <strlen>
	strcpy(dst + len, src);
f0105b70:	ff 75 0c             	pushl  0xc(%ebp)
f0105b73:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105b76:	50                   	push   %eax
f0105b77:	e8 cc ff ff ff       	call   f0105b48 <strcpy>
	return dst;
}
f0105b7c:	89 d8                	mov    %ebx,%eax
f0105b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105b81:	c9                   	leave  
f0105b82:	c3                   	ret    

f0105b83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105b83:	55                   	push   %ebp
f0105b84:	89 e5                	mov    %esp,%ebp
f0105b86:	57                   	push   %edi
f0105b87:	56                   	push   %esi
f0105b88:	53                   	push   %ebx
f0105b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b8f:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
f0105b92:	89 cf                	mov    %ecx,%edi
	for (i = 0; i < size; i++) {
f0105b94:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105b99:	39 f3                	cmp    %esi,%ebx
f0105b9b:	73 10                	jae    f0105bad <strncpy+0x2a>
		*dst++ = *src;
f0105b9d:	8a 02                	mov    (%edx),%al
f0105b9f:	88 01                	mov    %al,(%ecx)
f0105ba1:	41                   	inc    %ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105ba2:	80 3a 01             	cmpb   $0x1,(%edx)
f0105ba5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ba8:	43                   	inc    %ebx
f0105ba9:	39 f3                	cmp    %esi,%ebx
f0105bab:	72 f0                	jb     f0105b9d <strncpy+0x1a>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105bad:	89 f8                	mov    %edi,%eax
f0105baf:	5b                   	pop    %ebx
f0105bb0:	5e                   	pop    %esi
f0105bb1:	5f                   	pop    %edi
f0105bb2:	c9                   	leave  
f0105bb3:	c3                   	ret    

f0105bb4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105bb4:	55                   	push   %ebp
f0105bb5:	89 e5                	mov    %esp,%ebp
f0105bb7:	56                   	push   %esi
f0105bb8:	53                   	push   %ebx
f0105bb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105bbf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
f0105bc2:	89 de                	mov    %ebx,%esi
	if (size > 0) {
f0105bc4:	85 d2                	test   %edx,%edx
f0105bc6:	74 19                	je     f0105be1 <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105bc8:	4a                   	dec    %edx
f0105bc9:	74 13                	je     f0105bde <strlcpy+0x2a>
f0105bcb:	80 39 00             	cmpb   $0x0,(%ecx)
f0105bce:	74 0e                	je     f0105bde <strlcpy+0x2a>
f0105bd0:	8a 01                	mov    (%ecx),%al
f0105bd2:	41                   	inc    %ecx
f0105bd3:	88 03                	mov    %al,(%ebx)
f0105bd5:	43                   	inc    %ebx
f0105bd6:	4a                   	dec    %edx
f0105bd7:	74 05                	je     f0105bde <strlcpy+0x2a>
f0105bd9:	80 39 00             	cmpb   $0x0,(%ecx)
f0105bdc:	75 f2                	jne    f0105bd0 <strlcpy+0x1c>
		*dst = '\0';
f0105bde:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
f0105be1:	89 d8                	mov    %ebx,%eax
f0105be3:	29 f0                	sub    %esi,%eax
}
f0105be5:	5b                   	pop    %ebx
f0105be6:	5e                   	pop    %esi
f0105be7:	c9                   	leave  
f0105be8:	c3                   	ret    

f0105be9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105be9:	55                   	push   %ebp
f0105bea:	89 e5                	mov    %esp,%ebp
f0105bec:	8b 55 08             	mov    0x8(%ebp),%edx
f0105bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
		p++, q++;
f0105bf2:	80 3a 00             	cmpb   $0x0,(%edx)
f0105bf5:	74 13                	je     f0105c0a <strcmp+0x21>
f0105bf7:	8a 02                	mov    (%edx),%al
f0105bf9:	3a 01                	cmp    (%ecx),%al
f0105bfb:	75 0d                	jne    f0105c0a <strcmp+0x21>
f0105bfd:	42                   	inc    %edx
f0105bfe:	41                   	inc    %ecx
f0105bff:	80 3a 00             	cmpb   $0x0,(%edx)
f0105c02:	74 06                	je     f0105c0a <strcmp+0x21>
f0105c04:	8a 02                	mov    (%edx),%al
f0105c06:	3a 01                	cmp    (%ecx),%al
f0105c08:	74 f3                	je     f0105bfd <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c0a:	0f b6 02             	movzbl (%edx),%eax
f0105c0d:	0f b6 11             	movzbl (%ecx),%edx
f0105c10:	29 d0                	sub    %edx,%eax
}
f0105c12:	c9                   	leave  
f0105c13:	c3                   	ret    

f0105c14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105c14:	55                   	push   %ebp
f0105c15:	89 e5                	mov    %esp,%ebp
f0105c17:	53                   	push   %ebx
f0105c18:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0105c21:	85 c9                	test   %ecx,%ecx
f0105c23:	74 1f                	je     f0105c44 <strncmp+0x30>
f0105c25:	80 3a 00             	cmpb   $0x0,(%edx)
f0105c28:	74 16                	je     f0105c40 <strncmp+0x2c>
f0105c2a:	8a 02                	mov    (%edx),%al
f0105c2c:	3a 03                	cmp    (%ebx),%al
f0105c2e:	75 10                	jne    f0105c40 <strncmp+0x2c>
f0105c30:	42                   	inc    %edx
f0105c31:	43                   	inc    %ebx
f0105c32:	49                   	dec    %ecx
f0105c33:	74 0f                	je     f0105c44 <strncmp+0x30>
f0105c35:	80 3a 00             	cmpb   $0x0,(%edx)
f0105c38:	74 06                	je     f0105c40 <strncmp+0x2c>
f0105c3a:	8a 02                	mov    (%edx),%al
f0105c3c:	3a 03                	cmp    (%ebx),%al
f0105c3e:	74 f0                	je     f0105c30 <strncmp+0x1c>
	if (n == 0)
f0105c40:	85 c9                	test   %ecx,%ecx
f0105c42:	75 07                	jne    f0105c4b <strncmp+0x37>
		return 0;
f0105c44:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c49:	eb 0a                	jmp    f0105c55 <strncmp+0x41>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c4b:	0f b6 12             	movzbl (%edx),%edx
f0105c4e:	0f b6 03             	movzbl (%ebx),%eax
f0105c51:	29 c2                	sub    %eax,%edx
f0105c53:	89 d0                	mov    %edx,%eax
}
f0105c55:	5b                   	pop    %ebx
f0105c56:	c9                   	leave  
f0105c57:	c3                   	ret    

f0105c58 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105c58:	55                   	push   %ebp
f0105c59:	89 e5                	mov    %esp,%ebp
f0105c5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c5e:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
f0105c61:	80 38 00             	cmpb   $0x0,(%eax)
f0105c64:	74 0a                	je     f0105c70 <strchr+0x18>
		if (*s == c)
f0105c66:	38 10                	cmp    %dl,(%eax)
f0105c68:	74 0b                	je     f0105c75 <strchr+0x1d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105c6a:	40                   	inc    %eax
f0105c6b:	80 38 00             	cmpb   $0x0,(%eax)
f0105c6e:	75 f6                	jne    f0105c66 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f0105c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c75:	c9                   	leave  
f0105c76:	c3                   	ret    

f0105c77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105c77:	55                   	push   %ebp
f0105c78:	89 e5                	mov    %esp,%ebp
f0105c7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c7d:	8a 55 0c             	mov    0xc(%ebp),%dl
	for (; *s; s++)
f0105c80:	80 38 00             	cmpb   $0x0,(%eax)
f0105c83:	74 0a                	je     f0105c8f <strfind+0x18>
		if (*s == c)
f0105c85:	38 10                	cmp    %dl,(%eax)
f0105c87:	74 06                	je     f0105c8f <strfind+0x18>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105c89:	40                   	inc    %eax
f0105c8a:	80 38 00             	cmpb   $0x0,(%eax)
f0105c8d:	75 f6                	jne    f0105c85 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
}
f0105c8f:	c9                   	leave  
f0105c90:	c3                   	ret    

f0105c91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105c91:	55                   	push   %ebp
f0105c92:	89 e5                	mov    %esp,%ebp
f0105c94:	57                   	push   %edi
f0105c95:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105c98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
		return v;
f0105c9b:	89 f8                	mov    %edi,%eax
void *
memset(void *v, int c, size_t n)
{
	char *p;

	if (n == 0)
f0105c9d:	85 c9                	test   %ecx,%ecx
f0105c9f:	74 40                	je     f0105ce1 <memset+0x50>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105ca1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105ca7:	75 30                	jne    f0105cd9 <memset+0x48>
f0105ca9:	f6 c1 03             	test   $0x3,%cl
f0105cac:	75 2b                	jne    f0105cd9 <memset+0x48>
		c &= 0xFF;
f0105cae:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105cb8:	c1 e0 18             	shl    $0x18,%eax
f0105cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cbe:	c1 e2 10             	shl    $0x10,%edx
f0105cc1:	09 d0                	or     %edx,%eax
f0105cc3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cc6:	c1 e2 08             	shl    $0x8,%edx
f0105cc9:	09 d0                	or     %edx,%eax
f0105ccb:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
f0105cce:	c1 e9 02             	shr    $0x2,%ecx
f0105cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105cd4:	fc                   	cld    
f0105cd5:	f3 ab                	rep stos %eax,%es:(%edi)
f0105cd7:	eb 06                	jmp    f0105cdf <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105cdc:	fc                   	cld    
f0105cdd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
f0105cdf:	89 f8                	mov    %edi,%eax
}
f0105ce1:	5f                   	pop    %edi
f0105ce2:	c9                   	leave  
f0105ce3:	c3                   	ret    

f0105ce4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105ce4:	55                   	push   %ebp
f0105ce5:	89 e5                	mov    %esp,%ebp
f0105ce7:	57                   	push   %edi
f0105ce8:	56                   	push   %esi
f0105ce9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0105cef:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0105cf2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0105cf4:	39 c6                	cmp    %eax,%esi
f0105cf6:	73 34                	jae    f0105d2c <memmove+0x48>
f0105cf8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105cfb:	39 c2                	cmp    %eax,%edx
f0105cfd:	76 2d                	jbe    f0105d2c <memmove+0x48>
		s += n;
f0105cff:	89 d6                	mov    %edx,%esi
		d += n;
f0105d01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d04:	f6 c2 03             	test   $0x3,%dl
f0105d07:	75 1b                	jne    f0105d24 <memmove+0x40>
f0105d09:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d0f:	75 13                	jne    f0105d24 <memmove+0x40>
f0105d11:	f6 c1 03             	test   $0x3,%cl
f0105d14:	75 0e                	jne    f0105d24 <memmove+0x40>
			asm volatile("std; rep movsl\n"
f0105d16:	83 ef 04             	sub    $0x4,%edi
f0105d19:	83 ee 04             	sub    $0x4,%esi
f0105d1c:	c1 e9 02             	shr    $0x2,%ecx
f0105d1f:	fd                   	std    
f0105d20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d22:	eb 05                	jmp    f0105d29 <memmove+0x45>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105d24:	4f                   	dec    %edi
f0105d25:	4e                   	dec    %esi
f0105d26:	fd                   	std    
f0105d27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105d29:	fc                   	cld    
f0105d2a:	eb 20                	jmp    f0105d4c <memmove+0x68>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d2c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105d32:	75 15                	jne    f0105d49 <memmove+0x65>
f0105d34:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d3a:	75 0d                	jne    f0105d49 <memmove+0x65>
f0105d3c:	f6 c1 03             	test   $0x3,%cl
f0105d3f:	75 08                	jne    f0105d49 <memmove+0x65>
			asm volatile("cld; rep movsl\n"
f0105d41:	c1 e9 02             	shr    $0x2,%ecx
f0105d44:	fc                   	cld    
f0105d45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d47:	eb 03                	jmp    f0105d4c <memmove+0x68>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105d49:	fc                   	cld    
f0105d4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105d4c:	5e                   	pop    %esi
f0105d4d:	5f                   	pop    %edi
f0105d4e:	c9                   	leave  
f0105d4f:	c3                   	ret    

f0105d50 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0105d50:	55                   	push   %ebp
f0105d51:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105d53:	ff 75 10             	pushl  0x10(%ebp)
f0105d56:	ff 75 0c             	pushl  0xc(%ebp)
f0105d59:	ff 75 08             	pushl  0x8(%ebp)
f0105d5c:	e8 83 ff ff ff       	call   f0105ce4 <memmove>
}
f0105d61:	c9                   	leave  
f0105d62:	c3                   	ret    

f0105d63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105d63:	55                   	push   %ebp
f0105d64:	89 e5                	mov    %esp,%ebp
f0105d66:	53                   	push   %ebx
	const uint8_t *s1 = (const uint8_t *) v1;
f0105d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	const uint8_t *s2 = (const uint8_t *) v2;
f0105d6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	while (n-- > 0) {
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105d6d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105d70:	4a                   	dec    %edx
f0105d71:	83 fa ff             	cmp    $0xffffffff,%edx
f0105d74:	74 1a                	je     f0105d90 <memcmp+0x2d>
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
f0105d76:	8a 01                	mov    (%ecx),%al
f0105d78:	3a 03                	cmp    (%ebx),%al
f0105d7a:	74 0c                	je     f0105d88 <memcmp+0x25>
			return (int) *s1 - (int) *s2;
f0105d7c:	0f b6 d0             	movzbl %al,%edx
f0105d7f:	0f b6 03             	movzbl (%ebx),%eax
f0105d82:	29 c2                	sub    %eax,%edx
f0105d84:	89 d0                	mov    %edx,%eax
f0105d86:	eb 0d                	jmp    f0105d95 <memcmp+0x32>
		s1++, s2++;
f0105d88:	41                   	inc    %ecx
f0105d89:	43                   	inc    %ebx
f0105d8a:	4a                   	dec    %edx
f0105d8b:	83 fa ff             	cmp    $0xffffffff,%edx
f0105d8e:	75 e6                	jne    f0105d76 <memcmp+0x13>
	}

	return 0;
f0105d90:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d95:	5b                   	pop    %ebx
f0105d96:	c9                   	leave  
f0105d97:	c3                   	ret    

f0105d98 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105d98:	55                   	push   %ebp
f0105d99:	89 e5                	mov    %esp,%ebp
f0105d9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105da1:	89 c2                	mov    %eax,%edx
f0105da3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105da6:	39 d0                	cmp    %edx,%eax
f0105da8:	73 09                	jae    f0105db3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105daa:	38 08                	cmp    %cl,(%eax)
f0105dac:	74 05                	je     f0105db3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105dae:	40                   	inc    %eax
f0105daf:	39 d0                	cmp    %edx,%eax
f0105db1:	72 f7                	jb     f0105daa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105db3:	c9                   	leave  
f0105db4:	c3                   	ret    

f0105db5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105db5:	55                   	push   %ebp
f0105db6:	89 e5                	mov    %esp,%ebp
f0105db8:	57                   	push   %edi
f0105db9:	56                   	push   %esi
f0105dba:	53                   	push   %ebx
f0105dbb:	8b 55 08             	mov    0x8(%ebp),%edx
f0105dbe:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dc1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	int neg = 0;
f0105dc4:	bf 00 00 00 00       	mov    $0x0,%edi
	long val = 0;
f0105dc9:	bb 00 00 00 00       	mov    $0x0,%ebx

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
f0105dce:	80 3a 20             	cmpb   $0x20,(%edx)
f0105dd1:	74 05                	je     f0105dd8 <strtol+0x23>
f0105dd3:	80 3a 09             	cmpb   $0x9,(%edx)
f0105dd6:	75 0b                	jne    f0105de3 <strtol+0x2e>
f0105dd8:	42                   	inc    %edx
f0105dd9:	80 3a 20             	cmpb   $0x20,(%edx)
f0105ddc:	74 fa                	je     f0105dd8 <strtol+0x23>
f0105dde:	80 3a 09             	cmpb   $0x9,(%edx)
f0105de1:	74 f5                	je     f0105dd8 <strtol+0x23>

	// plus/minus sign
	if (*s == '+')
f0105de3:	80 3a 2b             	cmpb   $0x2b,(%edx)
f0105de6:	75 03                	jne    f0105deb <strtol+0x36>
		s++;
f0105de8:	42                   	inc    %edx
f0105de9:	eb 0b                	jmp    f0105df6 <strtol+0x41>
	else if (*s == '-')
f0105deb:	80 3a 2d             	cmpb   $0x2d,(%edx)
f0105dee:	75 06                	jne    f0105df6 <strtol+0x41>
		s++, neg = 1;
f0105df0:	42                   	inc    %edx
f0105df1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105df6:	85 c9                	test   %ecx,%ecx
f0105df8:	74 05                	je     f0105dff <strtol+0x4a>
f0105dfa:	83 f9 10             	cmp    $0x10,%ecx
f0105dfd:	75 15                	jne    f0105e14 <strtol+0x5f>
f0105dff:	80 3a 30             	cmpb   $0x30,(%edx)
f0105e02:	75 10                	jne    f0105e14 <strtol+0x5f>
f0105e04:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105e08:	75 0a                	jne    f0105e14 <strtol+0x5f>
		s += 2, base = 16;
f0105e0a:	83 c2 02             	add    $0x2,%edx
f0105e0d:	b9 10 00 00 00       	mov    $0x10,%ecx
f0105e12:	eb 14                	jmp    f0105e28 <strtol+0x73>
	else if (base == 0 && s[0] == '0')
f0105e14:	85 c9                	test   %ecx,%ecx
f0105e16:	75 10                	jne    f0105e28 <strtol+0x73>
f0105e18:	80 3a 30             	cmpb   $0x30,(%edx)
f0105e1b:	75 05                	jne    f0105e22 <strtol+0x6d>
		s++, base = 8;
f0105e1d:	42                   	inc    %edx
f0105e1e:	b1 08                	mov    $0x8,%cl
f0105e20:	eb 06                	jmp    f0105e28 <strtol+0x73>
	else if (base == 0)
f0105e22:	85 c9                	test   %ecx,%ecx
f0105e24:	75 02                	jne    f0105e28 <strtol+0x73>
		base = 10;
f0105e26:	b1 0a                	mov    $0xa,%cl

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105e28:	8a 02                	mov    (%edx),%al
f0105e2a:	83 e8 30             	sub    $0x30,%eax
f0105e2d:	3c 09                	cmp    $0x9,%al
f0105e2f:	77 08                	ja     f0105e39 <strtol+0x84>
			dig = *s - '0';
f0105e31:	0f be 02             	movsbl (%edx),%eax
f0105e34:	83 e8 30             	sub    $0x30,%eax
f0105e37:	eb 20                	jmp    f0105e59 <strtol+0xa4>
		else if (*s >= 'a' && *s <= 'z')
f0105e39:	8a 02                	mov    (%edx),%al
f0105e3b:	83 e8 61             	sub    $0x61,%eax
f0105e3e:	3c 19                	cmp    $0x19,%al
f0105e40:	77 08                	ja     f0105e4a <strtol+0x95>
			dig = *s - 'a' + 10;
f0105e42:	0f be 02             	movsbl (%edx),%eax
f0105e45:	83 e8 57             	sub    $0x57,%eax
f0105e48:	eb 0f                	jmp    f0105e59 <strtol+0xa4>
		else if (*s >= 'A' && *s <= 'Z')
f0105e4a:	8a 02                	mov    (%edx),%al
f0105e4c:	83 e8 41             	sub    $0x41,%eax
f0105e4f:	3c 19                	cmp    $0x19,%al
f0105e51:	77 12                	ja     f0105e65 <strtol+0xb0>
			dig = *s - 'A' + 10;
f0105e53:	0f be 02             	movsbl (%edx),%eax
f0105e56:	83 e8 37             	sub    $0x37,%eax
		else
			break;
		if (dig >= base)
f0105e59:	39 c8                	cmp    %ecx,%eax
f0105e5b:	7d 08                	jge    f0105e65 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105e5d:	42                   	inc    %edx
f0105e5e:	0f af d9             	imul   %ecx,%ebx
f0105e61:	01 c3                	add    %eax,%ebx
f0105e63:	eb c3                	jmp    f0105e28 <strtol+0x73>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105e65:	85 f6                	test   %esi,%esi
f0105e67:	74 02                	je     f0105e6b <strtol+0xb6>
		*endptr = (char *) s;
f0105e69:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0105e6b:	89 d8                	mov    %ebx,%eax
f0105e6d:	85 ff                	test   %edi,%edi
f0105e6f:	74 02                	je     f0105e73 <strtol+0xbe>
f0105e71:	f7 d8                	neg    %eax
}
f0105e73:	5b                   	pop    %ebx
f0105e74:	5e                   	pop    %esi
f0105e75:	5f                   	pop    %edi
f0105e76:	c9                   	leave  
f0105e77:	c3                   	ret    

f0105e78 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105e78:	fa                   	cli    

	xorw    %ax, %ax
f0105e79:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105e7b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105e7d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105e7f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105e81:	0f 01 16             	lgdtl  (%esi)
f0105e84:	74 70                	je     f0105ef6 <sum+0x2>
	movl    %cr0, %eax
f0105e86:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105e89:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105e8d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105e90:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105e96:	08 00                	or     %al,(%eax)

f0105e98 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105e98:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105e9c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105e9e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ea0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105ea2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105ea6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105ea8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105eaa:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0105eaf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105eb2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105eb5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105eba:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0105ebd:	8b 25 e4 ee 1b f0    	mov    0xf01beee4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105ec3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105ec8:	b8 18 02 10 f0       	mov    $0xf0100218,%eax
	call    *%eax
f0105ecd:	ff d0                	call   *%eax

f0105ecf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105ecf:	eb fe                	jmp    f0105ecf <spin>
f0105ed1:	8d 76 00             	lea    0x0(%esi),%esi

f0105ed4 <gdt>:
	...
f0105edc:	ff                   	(bad)  
f0105edd:	ff 00                	incl   (%eax)
f0105edf:	00 00                	add    %al,(%eax)
f0105ee1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105ee8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105eec <gdtdesc>:
f0105eec:	17                   	pop    %ss
f0105eed:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105ef2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105ef2:	90                   	nop
	...

f0105ef4 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105ef4:	55                   	push   %ebp
f0105ef5:	89 e5                	mov    %esp,%ebp
f0105ef7:	56                   	push   %esi
f0105ef8:	53                   	push   %ebx
f0105ef9:	8b 75 08             	mov    0x8(%ebp),%esi
f0105efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, sum;

	sum = 0;
f0105eff:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = 0; i < len; i++)
f0105f04:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f09:	39 d9                	cmp    %ebx,%ecx
f0105f0b:	7d 0b                	jge    f0105f18 <sum+0x24>
		sum += ((uint8_t *)addr)[i];
f0105f0d:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0105f11:	01 c1                	add    %eax,%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f13:	42                   	inc    %edx
f0105f14:	39 da                	cmp    %ebx,%edx
f0105f16:	7c f5                	jl     f0105f0d <sum+0x19>
		sum += ((uint8_t *)addr)[i];
	return sum;
f0105f18:	0f b6 c1             	movzbl %cl,%eax
}
f0105f1b:	5b                   	pop    %ebx
f0105f1c:	5e                   	pop    %esi
f0105f1d:	c9                   	leave  
f0105f1e:	c3                   	ret    

f0105f1f <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105f1f:	55                   	push   %ebp
f0105f20:	89 e5                	mov    %esp,%ebp
f0105f22:	56                   	push   %esi
f0105f23:	53                   	push   %ebx
f0105f24:	8b 55 08             	mov    0x8(%ebp),%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f27:	89 d0                	mov    %edx,%eax
f0105f29:	c1 e8 0c             	shr    $0xc,%eax
f0105f2c:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0105f32:	72 12                	jb     f0105f46 <mpsearch1+0x27>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f34:	52                   	push   %edx
f0105f35:	68 58 6a 10 f0       	push   $0xf0106a58
f0105f3a:	6a 58                	push   $0x58
f0105f3c:	68 f5 82 10 f0       	push   $0xf01082f5
f0105f41:	e8 5b a3 ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0105f46:	8d 9a 00 00 00 f0    	lea    -0x10000000(%edx),%ebx
f0105f4c:	03 55 0c             	add    0xc(%ebp),%edx
	if (PGNUM(pa) >= npages)
f0105f4f:	89 d0                	mov    %edx,%eax
f0105f51:	c1 e8 0c             	shr    $0xc,%eax
f0105f54:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f0105f5a:	72 16                	jb     f0105f72 <mpsearch1+0x53>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f5c:	52                   	push   %edx
f0105f5d:	68 58 6a 10 f0       	push   $0xf0106a58
f0105f62:	6a 58                	push   $0x58
f0105f64:	68 f5 82 10 f0       	push   $0xf01082f5
f0105f69:	e8 33 a3 ff ff       	call   f01002a1 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
f0105f6e:	89 d8                	mov    %ebx,%eax
f0105f70:	eb 3c                	jmp    f0105fae <mpsearch1+0x8f>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0105f72:	8d b2 00 00 00 f0    	lea    -0x10000000(%edx),%esi
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105f78:	39 f3                	cmp    %esi,%ebx
f0105f7a:	73 2d                	jae    f0105fa9 <mpsearch1+0x8a>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105f7c:	83 ec 04             	sub    $0x4,%esp
f0105f7f:	6a 04                	push   $0x4
f0105f81:	68 05 83 10 f0       	push   $0xf0108305
f0105f86:	53                   	push   %ebx
f0105f87:	e8 d7 fd ff ff       	call   f0105d63 <memcmp>
f0105f8c:	83 c4 10             	add    $0x10,%esp
f0105f8f:	85 c0                	test   %eax,%eax
f0105f91:	75 0f                	jne    f0105fa2 <mpsearch1+0x83>
f0105f93:	6a 10                	push   $0x10
f0105f95:	53                   	push   %ebx
f0105f96:	e8 59 ff ff ff       	call   f0105ef4 <sum>
f0105f9b:	83 c4 08             	add    $0x8,%esp
f0105f9e:	84 c0                	test   %al,%al
f0105fa0:	74 cc                	je     f0105f6e <mpsearch1+0x4f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105fa2:	83 c3 10             	add    $0x10,%ebx
f0105fa5:	39 f3                	cmp    %esi,%ebx
f0105fa7:	72 d3                	jb     f0105f7c <mpsearch1+0x5d>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105fa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105fae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fb1:	5b                   	pop    %ebx
f0105fb2:	5e                   	pop    %esi
f0105fb3:	c9                   	leave  
f0105fb4:	c3                   	ret    

f0105fb5 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0105fb5:	55                   	push   %ebp
f0105fb6:	89 e5                	mov    %esp,%ebp
f0105fb8:	83 ec 08             	sub    $0x8,%esp
	if (PGNUM(pa) >= npages)
f0105fbb:	83 3d e8 ee 1b f0 00 	cmpl   $0x0,0xf01beee8
f0105fc2:	75 16                	jne    f0105fda <mpsearch+0x25>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fc4:	68 00 04 00 00       	push   $0x400
f0105fc9:	68 58 6a 10 f0       	push   $0xf0106a58
f0105fce:	6a 70                	push   $0x70
f0105fd0:	68 f5 82 10 f0       	push   $0xf01082f5
f0105fd5:	e8 c7 a2 ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0105fda:	b8 00 04 00 00       	mov    $0x400,%eax
f0105fdf:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105fe5:	0f b7 42 0e          	movzwl 0xe(%edx),%eax
f0105fe9:	85 c0                	test   %eax,%eax
f0105feb:	74 1c                	je     f0106009 <mpsearch+0x54>
		p <<= 4;	// Translate from segment to PA
f0105fed:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105ff0:	83 ec 08             	sub    $0x8,%esp
f0105ff3:	68 00 04 00 00       	push   $0x400
f0105ff8:	50                   	push   %eax
f0105ff9:	e8 21 ff ff ff       	call   f0105f1f <mpsearch1>
f0105ffe:	83 c4 10             	add    $0x10,%esp
			return mp;
f0106001:	89 c2                	mov    %eax,%edx

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106003:	85 c0                	test   %eax,%eax
f0106005:	75 39                	jne    f0106040 <mpsearch+0x8b>
f0106007:	eb 23                	jmp    f010602c <mpsearch+0x77>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106009:	0f b7 42 13          	movzwl 0x13(%edx),%eax
f010600d:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106010:	83 ec 08             	sub    $0x8,%esp
f0106013:	68 00 04 00 00       	push   $0x400
f0106018:	2d 00 04 00 00       	sub    $0x400,%eax
f010601d:	50                   	push   %eax
f010601e:	e8 fc fe ff ff       	call   f0105f1f <mpsearch1>
f0106023:	83 c4 10             	add    $0x10,%esp
			return mp;
f0106026:	89 c2                	mov    %eax,%edx
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106028:	85 c0                	test   %eax,%eax
f010602a:	75 14                	jne    f0106040 <mpsearch+0x8b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010602c:	83 ec 08             	sub    $0x8,%esp
f010602f:	68 00 00 01 00       	push   $0x10000
f0106034:	68 00 00 0f 00       	push   $0xf0000
f0106039:	e8 e1 fe ff ff       	call   f0105f1f <mpsearch1>
f010603e:	89 c2                	mov    %eax,%edx
}
f0106040:	89 d0                	mov    %edx,%eax
f0106042:	c9                   	leave  
f0106043:	c3                   	ret    

f0106044 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0106044:	55                   	push   %ebp
f0106045:	89 e5                	mov    %esp,%ebp
f0106047:	56                   	push   %esi
f0106048:	53                   	push   %ebx
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106049:	e8 67 ff ff ff       	call   f0105fb5 <mpsearch>
f010604e:	89 c6                	mov    %eax,%esi
		return NULL;
f0106050:	b8 00 00 00 00       	mov    $0x0,%eax
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106055:	85 f6                	test   %esi,%esi
f0106057:	0f 84 f8 00 00 00    	je     f0106155 <mpconfig+0x111>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010605d:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
f0106061:	74 06                	je     f0106069 <mpconfig+0x25>
f0106063:	80 7e 0b 00          	cmpb   $0x0,0xb(%esi)
f0106067:	74 17                	je     f0106080 <mpconfig+0x3c>
		cprintf("SMP: Default configurations not implemented\n");
f0106069:	83 ec 0c             	sub    $0xc,%esp
f010606c:	68 68 81 10 f0       	push   $0xf0108168
f0106071:	e8 5c d9 ff ff       	call   f01039d2 <cprintf>
		return NULL;
f0106076:	b8 00 00 00 00       	mov    $0x0,%eax
f010607b:	e9 d5 00 00 00       	jmp    f0106155 <mpconfig+0x111>
f0106080:	8b 56 04             	mov    0x4(%esi),%edx
	if (PGNUM(pa) >= npages)
f0106083:	89 d0                	mov    %edx,%eax
f0106085:	c1 e8 0c             	shr    $0xc,%eax
f0106088:	3b 05 e8 ee 1b f0    	cmp    0xf01beee8,%eax
f010608e:	72 15                	jb     f01060a5 <mpconfig+0x61>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106090:	52                   	push   %edx
f0106091:	68 58 6a 10 f0       	push   $0xf0106a58
f0106096:	68 91 00 00 00       	push   $0x91
f010609b:	68 f5 82 10 f0       	push   $0xf01082f5
f01060a0:	e8 fc a1 ff ff       	call   f01002a1 <_panic>
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01060a5:	8d 9a 00 00 00 f0    	lea    -0x10000000(%edx),%ebx
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01060ab:	83 ec 04             	sub    $0x4,%esp
f01060ae:	6a 04                	push   $0x4
f01060b0:	68 0a 83 10 f0       	push   $0xf010830a
f01060b5:	53                   	push   %ebx
f01060b6:	e8 a8 fc ff ff       	call   f0105d63 <memcmp>
f01060bb:	83 c4 10             	add    $0x10,%esp
f01060be:	85 c0                	test   %eax,%eax
f01060c0:	74 14                	je     f01060d6 <mpconfig+0x92>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01060c2:	83 ec 0c             	sub    $0xc,%esp
f01060c5:	68 98 81 10 f0       	push   $0xf0108198
f01060ca:	e8 03 d9 ff ff       	call   f01039d2 <cprintf>
		return NULL;
f01060cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01060d4:	eb 7f                	jmp    f0106155 <mpconfig+0x111>
	}
	if (sum(conf, conf->length) != 0) {
f01060d6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01060da:	50                   	push   %eax
f01060db:	53                   	push   %ebx
f01060dc:	e8 13 fe ff ff       	call   f0105ef4 <sum>
f01060e1:	83 c4 08             	add    $0x8,%esp
f01060e4:	84 c0                	test   %al,%al
f01060e6:	74 14                	je     f01060fc <mpconfig+0xb8>
		cprintf("SMP: Bad MP configuration checksum\n");
f01060e8:	83 ec 0c             	sub    $0xc,%esp
f01060eb:	68 cc 81 10 f0       	push   $0xf01081cc
f01060f0:	e8 dd d8 ff ff       	call   f01039d2 <cprintf>
		return NULL;
f01060f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01060fa:	eb 59                	jmp    f0106155 <mpconfig+0x111>
	}
	if (conf->version != 1 && conf->version != 4) {
f01060fc:	80 7b 06 01          	cmpb   $0x1,0x6(%ebx)
f0106100:	74 1f                	je     f0106121 <mpconfig+0xdd>
f0106102:	80 7b 06 04          	cmpb   $0x4,0x6(%ebx)
f0106106:	74 19                	je     f0106121 <mpconfig+0xdd>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106108:	83 ec 08             	sub    $0x8,%esp
f010610b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010610f:	50                   	push   %eax
f0106110:	68 f0 81 10 f0       	push   $0xf01081f0
f0106115:	e8 b8 d8 ff ff       	call   f01039d2 <cprintf>
		return NULL;
f010611a:	b8 00 00 00 00       	mov    $0x0,%eax
f010611f:	eb 34                	jmp    f0106155 <mpconfig+0x111>
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106121:	0f b7 43 28          	movzwl 0x28(%ebx),%eax
f0106125:	50                   	push   %eax
f0106126:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010612a:	01 d8                	add    %ebx,%eax
f010612c:	50                   	push   %eax
f010612d:	e8 c2 fd ff ff       	call   f0105ef4 <sum>
f0106132:	83 c4 08             	add    $0x8,%esp
f0106135:	3a 43 2a             	cmp    0x2a(%ebx),%al
f0106138:	74 14                	je     f010614e <mpconfig+0x10a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010613a:	83 ec 0c             	sub    $0xc,%esp
f010613d:	68 10 82 10 f0       	push   $0xf0108210
f0106142:	e8 8b d8 ff ff       	call   f01039d2 <cprintf>
		return NULL;
f0106147:	b8 00 00 00 00       	mov    $0x0,%eax
f010614c:	eb 07                	jmp    f0106155 <mpconfig+0x111>
	}
	*pmp = mp;
f010614e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106151:	89 30                	mov    %esi,(%eax)
	return conf;
f0106153:	89 d8                	mov    %ebx,%eax
}
f0106155:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106158:	5b                   	pop    %ebx
f0106159:	5e                   	pop    %esi
f010615a:	c9                   	leave  
f010615b:	c3                   	ret    

f010615c <mp_init>:

void
mp_init(void)
{
f010615c:	55                   	push   %ebp
f010615d:	89 e5                	mov    %esp,%ebp
f010615f:	57                   	push   %edi
f0106160:	56                   	push   %esi
f0106161:	53                   	push   %ebx
f0106162:	83 ec 18             	sub    $0x18,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106165:	c7 05 c0 f3 1b f0 20 	movl   $0xf01bf020,0xf01bf3c0
f010616c:	f0 1b f0 
	if ((conf = mpconfig(&mp)) == 0)
f010616f:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106172:	50                   	push   %eax
f0106173:	e8 cc fe ff ff       	call   f0106044 <mpconfig>
f0106178:	89 c7                	mov    %eax,%edi
f010617a:	83 c4 10             	add    $0x10,%esp
f010617d:	85 c0                	test   %eax,%eax
f010617f:	0f 84 4f 01 00 00    	je     f01062d4 <mp_init+0x178>
		return;
	ismp = 1;
f0106185:	c7 05 00 f0 1b f0 01 	movl   $0x1,0xf01bf000
f010618c:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f010618f:	8b 40 24             	mov    0x24(%eax),%eax
f0106192:	a3 00 00 20 f0       	mov    %eax,0xf0200000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106197:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f010619a:	be 00 00 00 00       	mov    $0x0,%esi
f010619f:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f01061a4:	0f 84 ab 00 00 00    	je     f0106255 <mp_init+0xf9>
		switch (*p) {
f01061aa:	0f b6 03             	movzbl (%ebx),%eax
f01061ad:	85 c0                	test   %eax,%eax
f01061af:	74 07                	je     f01061b8 <mp_init+0x5c>
f01061b1:	83 f8 04             	cmp    $0x4,%eax
f01061b4:	7f 70                	jg     f0106226 <mp_init+0xca>
f01061b6:	eb 69                	jmp    f0106221 <mp_init+0xc5>
		case MPPROC:
			proc = (struct mpproc *)p;
f01061b8:	89 d9                	mov    %ebx,%ecx
			if (proc->flags & MPPROC_BOOT)
f01061ba:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01061be:	74 1e                	je     f01061de <mp_init+0x82>
				bootcpu = &cpus[ncpu];
f01061c0:	8b 15 c4 f3 1b f0    	mov    0xf01bf3c4,%edx
f01061c6:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01061cd:	29 d0                	sub    %edx,%eax
f01061cf:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01061d2:	8d 04 85 20 f0 1b f0 	lea    -0xfe40fe0(,%eax,4),%eax
f01061d9:	a3 c0 f3 1b f0       	mov    %eax,0xf01bf3c0
			if (ncpu < NCPU) {
f01061de:	83 3d c4 f3 1b f0 07 	cmpl   $0x7,0xf01bf3c4
f01061e5:	7f 20                	jg     f0106207 <mp_init+0xab>
				cpus[ncpu].cpu_id = ncpu;
f01061e7:	a1 c4 f3 1b f0       	mov    0xf01bf3c4,%eax
f01061ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01061f3:	29 c2                	sub    %eax,%edx
f01061f5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01061f8:	88 04 95 20 f0 1b f0 	mov    %al,-0xfe40fe0(,%edx,4)
				ncpu++;
f01061ff:	40                   	inc    %eax
f0106200:	a3 c4 f3 1b f0       	mov    %eax,0xf01bf3c4
f0106205:	eb 15                	jmp    f010621c <mp_init+0xc0>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106207:	83 ec 08             	sub    $0x8,%esp
f010620a:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f010620e:	50                   	push   %eax
f010620f:	68 40 82 10 f0       	push   $0xf0108240
f0106214:	e8 b9 d7 ff ff       	call   f01039d2 <cprintf>
f0106219:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010621c:	83 c3 14             	add    $0x14,%ebx
			continue;
f010621f:	eb 27                	jmp    f0106248 <mp_init+0xec>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106221:	83 c3 08             	add    $0x8,%ebx
			continue;
f0106224:	eb 22                	jmp    f0106248 <mp_init+0xec>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106226:	83 ec 08             	sub    $0x8,%esp
f0106229:	0f b6 03             	movzbl (%ebx),%eax
f010622c:	50                   	push   %eax
f010622d:	68 68 82 10 f0       	push   $0xf0108268
f0106232:	e8 9b d7 ff ff       	call   f01039d2 <cprintf>
			ismp = 0;
f0106237:	c7 05 00 f0 1b f0 00 	movl   $0x0,0xf01bf000
f010623e:	00 00 00 
			i = conf->entry;
f0106241:	0f b7 77 22          	movzwl 0x22(%edi),%esi
f0106245:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106248:	46                   	inc    %esi
f0106249:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f010624d:	39 f0                	cmp    %esi,%eax
f010624f:	0f 87 55 ff ff ff    	ja     f01061aa <mp_init+0x4e>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106255:	a1 c0 f3 1b f0       	mov    0xf01bf3c0,%eax
f010625a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106261:	83 3d 00 f0 1b f0 00 	cmpl   $0x0,0xf01bf000
f0106268:	75 23                	jne    f010628d <mp_init+0x131>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010626a:	c7 05 c4 f3 1b f0 01 	movl   $0x1,0xf01bf3c4
f0106271:	00 00 00 
		lapic = NULL;
f0106274:	c7 05 00 00 20 f0 00 	movl   $0x0,0xf0200000
f010627b:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010627e:	83 ec 0c             	sub    $0xc,%esp
f0106281:	68 88 82 10 f0       	push   $0xf0108288
f0106286:	e8 47 d7 ff ff       	call   f01039d2 <cprintf>
		return;
f010628b:	eb 47                	jmp    f01062d4 <mp_init+0x178>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010628d:	83 ec 04             	sub    $0x4,%esp
f0106290:	ff 35 c4 f3 1b f0    	pushl  0xf01bf3c4
f0106296:	a1 c0 f3 1b f0       	mov    0xf01bf3c0,%eax
f010629b:	0f b6 00             	movzbl (%eax),%eax
f010629e:	50                   	push   %eax
f010629f:	68 0f 83 10 f0       	push   $0xf010830f
f01062a4:	e8 29 d7 ff ff       	call   f01039d2 <cprintf>

	if (mp->imcrp) {
f01062a9:	83 c4 10             	add    $0x10,%esp
f01062ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01062af:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01062b3:	74 1f                	je     f01062d4 <mp_init+0x178>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01062b5:	83 ec 0c             	sub    $0xc,%esp
f01062b8:	68 b4 82 10 f0       	push   $0xf01082b4
f01062bd:	e8 10 d7 ff ff       	call   f01039d2 <cprintf>
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01062c2:	83 c4 10             	add    $0x10,%esp
f01062c5:	ba 22 00 00 00       	mov    $0x22,%edx
f01062ca:	b0 70                	mov    $0x70,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062cc:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f01062cd:	b2 23                	mov    $0x23,%dl

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01062cf:	ec                   	in     (%dx),%al
	__asm __volatile("int3");
}

static __inline uint8_t
inb(int port)
{
f01062d0:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062d3:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01062d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062d7:	5b                   	pop    %ebx
f01062d8:	5e                   	pop    %esi
f01062d9:	5f                   	pop    %edi
f01062da:	c9                   	leave  
f01062db:	c3                   	ret    

f01062dc <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f01062dc:	55                   	push   %ebp
f01062dd:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01062df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01062e2:	8b 55 08             	mov    0x8(%ebp),%edx
f01062e5:	a1 00 00 20 f0       	mov    0xf0200000,%eax
f01062ea:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
	lapic[ID];  // wait for write to finish, by reading
f01062ed:	a1 00 00 20 f0       	mov    0xf0200000,%eax
f01062f2:	8b 40 20             	mov    0x20(%eax),%eax
}
f01062f5:	c9                   	leave  
f01062f6:	c3                   	ret    

f01062f7 <lapic_init>:

void
lapic_init(void)
{
f01062f7:	55                   	push   %ebp
f01062f8:	89 e5                	mov    %esp,%ebp
f01062fa:	83 ec 08             	sub    $0x8,%esp
	if (!lapic) 
f01062fd:	83 3d 00 00 20 f0 00 	cmpl   $0x0,0xf0200000
f0106304:	0f 84 06 01 00 00    	je     f0106410 <lapic_init+0x119>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010630a:	68 27 01 00 00       	push   $0x127
f010630f:	6a 3c                	push   $0x3c
f0106311:	e8 c6 ff ff ff       	call   f01062dc <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106316:	6a 0b                	push   $0xb
f0106318:	68 f8 00 00 00       	push   $0xf8
f010631d:	e8 ba ff ff ff       	call   f01062dc <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106322:	68 20 00 02 00       	push   $0x20020
f0106327:	68 c8 00 00 00       	push   $0xc8
f010632c:	e8 ab ff ff ff       	call   f01062dc <lapicw>
	lapicw(TICR, 10000000); 
f0106331:	68 80 96 98 00       	push   $0x989680
f0106336:	68 e0 00 00 00       	push   $0xe0
f010633b:	e8 9c ff ff ff       	call   f01062dc <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106340:	83 c4 20             	add    $0x20,%esp
f0106343:	e8 ca 00 00 00       	call   f0106412 <cpunum>
f0106348:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010634f:	29 c2                	sub    %eax,%edx
f0106351:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106354:	8d 14 95 20 f0 1b f0 	lea    -0xfe40fe0(,%edx,4),%edx
f010635b:	3b 15 c0 f3 1b f0    	cmp    0xf01bf3c0,%edx
f0106361:	74 12                	je     f0106375 <lapic_init+0x7e>
		lapicw(LINT0, MASKED);
f0106363:	68 00 00 01 00       	push   $0x10000
f0106368:	68 d4 00 00 00       	push   $0xd4
f010636d:	e8 6a ff ff ff       	call   f01062dc <lapicw>
f0106372:	83 c4 08             	add    $0x8,%esp

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106375:	68 00 00 01 00       	push   $0x10000
f010637a:	68 d8 00 00 00       	push   $0xd8
f010637f:	e8 58 ff ff ff       	call   f01062dc <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106384:	a1 00 00 20 f0       	mov    0xf0200000,%eax
f0106389:	8b 40 30             	mov    0x30(%eax),%eax
f010638c:	c1 e8 10             	shr    $0x10,%eax
f010638f:	83 c4 08             	add    $0x8,%esp
f0106392:	3c 03                	cmp    $0x3,%al
f0106394:	76 12                	jbe    f01063a8 <lapic_init+0xb1>
		lapicw(PCINT, MASKED);
f0106396:	68 00 00 01 00       	push   $0x10000
f010639b:	68 d0 00 00 00       	push   $0xd0
f01063a0:	e8 37 ff ff ff       	call   f01062dc <lapicw>
f01063a5:	83 c4 08             	add    $0x8,%esp

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01063a8:	6a 33                	push   $0x33
f01063aa:	68 dc 00 00 00       	push   $0xdc
f01063af:	e8 28 ff ff ff       	call   f01062dc <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01063b4:	6a 00                	push   $0x0
f01063b6:	68 a0 00 00 00       	push   $0xa0
f01063bb:	e8 1c ff ff ff       	call   f01062dc <lapicw>
	lapicw(ESR, 0);
f01063c0:	6a 00                	push   $0x0
f01063c2:	68 a0 00 00 00       	push   $0xa0
f01063c7:	e8 10 ff ff ff       	call   f01062dc <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01063cc:	6a 00                	push   $0x0
f01063ce:	6a 2c                	push   $0x2c
f01063d0:	e8 07 ff ff ff       	call   f01062dc <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01063d5:	83 c4 20             	add    $0x20,%esp
f01063d8:	6a 00                	push   $0x0
f01063da:	68 c4 00 00 00       	push   $0xc4
f01063df:	e8 f8 fe ff ff       	call   f01062dc <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01063e4:	68 00 85 08 00       	push   $0x88500
f01063e9:	68 c0 00 00 00       	push   $0xc0
f01063ee:	e8 e9 fe ff ff       	call   f01062dc <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01063f3:	83 c4 10             	add    $0x10,%esp
f01063f6:	8b 15 00 00 20 f0    	mov    0xf0200000,%edx
f01063fc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106402:	f6 c4 10             	test   $0x10,%ah
f0106405:	75 f5                	jne    f01063fc <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106407:	6a 00                	push   $0x0
f0106409:	6a 20                	push   $0x20
f010640b:	e8 cc fe ff ff       	call   f01062dc <lapicw>
}
f0106410:	c9                   	leave  
f0106411:	c3                   	ret    

f0106412 <cpunum>:

int
cpunum(void)
{
f0106412:	55                   	push   %ebp
f0106413:	89 e5                	mov    %esp,%ebp
	if (lapic)
		return lapic[ID] >> 24;
	return 0;
f0106415:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f010641a:	83 3d 00 00 20 f0 00 	cmpl   $0x0,0xf0200000
f0106421:	74 0b                	je     f010642e <cpunum+0x1c>
		return lapic[ID] >> 24;
f0106423:	a1 00 00 20 f0       	mov    0xf0200000,%eax
f0106428:	8b 40 20             	mov    0x20(%eax),%eax
f010642b:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f010642e:	c9                   	leave  
f010642f:	c3                   	ret    

f0106430 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106430:	55                   	push   %ebp
f0106431:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106433:	83 3d 00 00 20 f0 00 	cmpl   $0x0,0xf0200000
f010643a:	74 0c                	je     f0106448 <lapic_eoi+0x18>
		lapicw(EOI, 0);
f010643c:	6a 00                	push   $0x0
f010643e:	6a 2c                	push   $0x2c
f0106440:	e8 97 fe ff ff       	call   f01062dc <lapicw>
f0106445:	83 c4 08             	add    $0x8,%esp
}
f0106448:	c9                   	leave  
f0106449:	c3                   	ret    

f010644a <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f010644a:	55                   	push   %ebp
f010644b:	89 e5                	mov    %esp,%ebp
f010644d:	c9                   	leave  
f010644e:	c3                   	ret    

f010644f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010644f:	55                   	push   %ebp
f0106450:	89 e5                	mov    %esp,%ebp
f0106452:	57                   	push   %edi
f0106453:	56                   	push   %esi
f0106454:	53                   	push   %ebx
f0106455:	83 ec 0c             	sub    $0xc,%esp
f0106458:	0f b6 75 08          	movzbl 0x8(%ebp),%esi
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f010645c:	ba 70 00 00 00       	mov    $0x70,%edx
f0106461:	b0 0f                	mov    $0xf,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106463:	ee                   	out    %al,(%dx)
			 "memory", "cc");
}

static __inline void
outb(int port, uint8_t data)
{
f0106464:	b2 71                	mov    $0x71,%dl
f0106466:	b0 0a                	mov    $0xa,%al
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106468:	ee                   	out    %al,(%dx)
f0106469:	66 ba 67 04          	mov    $0x467,%dx
	if (PGNUM(pa) >= npages)
f010646d:	83 3d e8 ee 1b f0 00 	cmpl   $0x0,0xf01beee8
f0106474:	75 19                	jne    f010648f <lapic_startap+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106476:	68 67 04 00 00       	push   $0x467
f010647b:	68 58 6a 10 f0       	push   $0xf0106a58
f0106480:	68 93 00 00 00       	push   $0x93
f0106485:	68 2c 83 10 f0       	push   $0xf010832c
f010648a:	e8 12 9e ff ff       	call   f01002a1 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010648f:	66 c7 82 00 00 00 f0 	movw   $0x0,-0x10000000(%edx)
f0106496:	00 00 
	wrv[1] = addr >> 4;
f0106498:	8b 45 0c             	mov    0xc(%ebp),%eax
f010649b:	c1 e8 04             	shr    $0x4,%eax
f010649e:	66 89 82 02 00 00 f0 	mov    %ax,-0xffffffe(%edx)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01064a5:	89 f0                	mov    %esi,%eax
f01064a7:	c1 e0 18             	shl    $0x18,%eax
f01064aa:	50                   	push   %eax
f01064ab:	68 c4 00 00 00       	push   $0xc4
f01064b0:	e8 27 fe ff ff       	call   f01062dc <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01064b5:	68 00 c5 00 00       	push   $0xc500
f01064ba:	68 c0 00 00 00       	push   $0xc0
f01064bf:	e8 18 fe ff ff       	call   f01062dc <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01064c4:	68 00 85 00 00       	push   $0x8500
f01064c9:	68 c0 00 00 00       	push   $0xc0
f01064ce:	e8 09 fe ff ff       	call   f01062dc <lapicw>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f01064d3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01064d8:	83 c4 18             	add    $0x18,%esp
f01064db:	89 f7                	mov    %esi,%edi
f01064dd:	c1 e7 18             	shl    $0x18,%edi
f01064e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064e3:	c1 e8 0c             	shr    $0xc,%eax
f01064e6:	89 c6                	mov    %eax,%esi
f01064e8:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f01064ee:	57                   	push   %edi
f01064ef:	68 c4 00 00 00       	push   $0xc4
f01064f4:	e8 e3 fd ff ff       	call   f01062dc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01064f9:	56                   	push   %esi
f01064fa:	68 c0 00 00 00       	push   $0xc0
f01064ff:	e8 d8 fd ff ff       	call   f01062dc <lapicw>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f0106504:	83 c4 10             	add    $0x10,%esp
f0106507:	43                   	inc    %ebx
f0106508:	83 fb 01             	cmp    $0x1,%ebx
f010650b:	7e e1                	jle    f01064ee <lapic_startap+0x9f>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
f010650d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106510:	5b                   	pop    %ebx
f0106511:	5e                   	pop    %esi
f0106512:	5f                   	pop    %edi
f0106513:	c9                   	leave  
f0106514:	c3                   	ret    

f0106515 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106515:	55                   	push   %ebp
f0106516:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106518:	8b 45 08             	mov    0x8(%ebp),%eax
f010651b:	0d 00 00 0c 00       	or     $0xc0000,%eax
f0106520:	50                   	push   %eax
f0106521:	68 c0 00 00 00       	push   $0xc0
f0106526:	e8 b1 fd ff ff       	call   f01062dc <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010652b:	83 c4 08             	add    $0x8,%esp
f010652e:	8b 15 00 00 20 f0    	mov    0xf0200000,%edx
f0106534:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010653a:	f6 c4 10             	test   $0x10,%ah
f010653d:	75 f5                	jne    f0106534 <lapic_ipi+0x1f>
		;
}
f010653f:	c9                   	leave  
f0106540:	c3                   	ret    
f0106541:	00 00                	add    %al,(%eax)
	...

f0106544 <get_caller_pcs>:

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
f0106544:	55                   	push   %ebp
f0106545:	89 e5                	mov    %esp,%ebp
f0106547:	53                   	push   %ebx
f0106548:	8b 5d 08             	mov    0x8(%ebp),%ebx
        __asm __volatile("pushl %0; popfl" : : "r" (eflags));
}

static __inline uint32_t
read_ebp(void)
{
f010654b:	89 ea                	mov    %ebp,%edx
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010654d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106552:	8d 82 00 00 80 10    	lea    0x10800000(%edx),%eax
f0106558:	3d ff ff 7f 0e       	cmp    $0xe7fffff,%eax
f010655d:	77 10                	ja     f010656f <get_caller_pcs+0x2b>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010655f:	8b 42 04             	mov    0x4(%edx),%eax
f0106562:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106565:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106567:	41                   	inc    %ecx
f0106568:	83 f9 09             	cmp    $0x9,%ecx
f010656b:	7e e5                	jle    f0106552 <get_caller_pcs+0xe>
f010656d:	eb 12                	jmp    f0106581 <get_caller_pcs+0x3d>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010656f:	83 f9 09             	cmp    $0x9,%ecx
f0106572:	7f 0d                	jg     f0106581 <get_caller_pcs+0x3d>
		pcs[i] = 0;
f0106574:	c7 04 8b 00 00 00 00 	movl   $0x0,(%ebx,%ecx,4)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010657b:	41                   	inc    %ecx
f010657c:	83 f9 09             	cmp    $0x9,%ecx
f010657f:	7e f3                	jle    f0106574 <get_caller_pcs+0x30>
		pcs[i] = 0;
}
f0106581:	5b                   	pop    %ebx
f0106582:	c9                   	leave  
f0106583:	c3                   	ret    

f0106584 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106584:	55                   	push   %ebp
f0106585:	89 e5                	mov    %esp,%ebp
f0106587:	56                   	push   %esi
f0106588:	53                   	push   %ebx
f0106589:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010658c:	be 00 00 00 00       	mov    $0x0,%esi
f0106591:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106594:	74 21                	je     f01065b7 <holding+0x33>
f0106596:	e8 77 fe ff ff       	call   f0106412 <cpunum>
f010659b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065a2:	29 c2                	sub    %eax,%edx
f01065a4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01065a7:	8d 14 95 20 f0 1b f0 	lea    -0xfe40fe0(,%edx,4),%edx
f01065ae:	39 53 08             	cmp    %edx,0x8(%ebx)
f01065b1:	75 04                	jne    f01065b7 <holding+0x33>
f01065b3:	66 be 01 00          	mov    $0x1,%si
}
f01065b7:	89 f0                	mov    %esi,%eax
f01065b9:	5b                   	pop    %ebx
f01065ba:	5e                   	pop    %esi
f01065bb:	c9                   	leave  
f01065bc:	c3                   	ret    

f01065bd <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065bd:	55                   	push   %ebp
f01065be:	89 e5                	mov    %esp,%ebp
f01065c0:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01065c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065cc:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01065cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01065d6:	c9                   	leave  
f01065d7:	c3                   	ret    

f01065d8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01065d8:	55                   	push   %ebp
f01065d9:	89 e5                	mov    %esp,%ebp
f01065db:	53                   	push   %ebx
f01065dc:	83 ec 10             	sub    $0x10,%esp
f01065df:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01065e2:	53                   	push   %ebx
f01065e3:	e8 9c ff ff ff       	call   f0106584 <holding>
f01065e8:	83 c4 10             	add    $0x10,%esp
f01065eb:	85 c0                	test   %eax,%eax
f01065ed:	74 1d                	je     f010660c <spin_lock+0x34>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01065ef:	83 ec 0c             	sub    $0xc,%esp
f01065f2:	ff 73 04             	pushl  0x4(%ebx)
f01065f5:	e8 18 fe ff ff       	call   f0106412 <cpunum>
f01065fa:	50                   	push   %eax
f01065fb:	68 80 83 10 f0       	push   $0xf0108380
f0106600:	6a 42                	push   $0x42
f0106602:	68 45 83 10 f0       	push   $0xf0108345
f0106607:	e8 95 9c ff ff       	call   f01002a1 <_panic>
        return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f010660c:	b8 01 00 00 00       	mov    $0x1,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106611:	f0 87 03             	lock xchg %eax,(%ebx)
        return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0106614:	85 c0                	test   %eax,%eax
f0106616:	74 10                	je     f0106628 <spin_lock+0x50>
f0106618:	ba 01 00 00 00       	mov    $0x1,%edx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010661d:	f3 90                	pause  
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010661f:	89 d0                	mov    %edx,%eax
f0106621:	f0 87 03             	lock xchg %eax,(%ebx)
        return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0106624:	85 c0                	test   %eax,%eax
f0106626:	75 f5                	jne    f010661d <spin_lock+0x45>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106628:	e8 e5 fd ff ff       	call   f0106412 <cpunum>
f010662d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106634:	29 c2                	sub    %eax,%edx
f0106636:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106639:	8d 14 95 20 f0 1b f0 	lea    -0xfe40fe0(,%edx,4),%edx
f0106640:	89 53 08             	mov    %edx,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106643:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106646:	50                   	push   %eax
f0106647:	e8 f8 fe ff ff       	call   f0106544 <get_caller_pcs>
#endif
}
f010664c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010664f:	c9                   	leave  
f0106650:	c3                   	ret    

f0106651 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106651:	55                   	push   %ebp
f0106652:	89 e5                	mov    %esp,%ebp
f0106654:	53                   	push   %ebx
f0106655:	83 ec 60             	sub    $0x60,%esp
f0106658:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010665b:	53                   	push   %ebx
f010665c:	e8 23 ff ff ff       	call   f0106584 <holding>
f0106661:	83 c4 10             	add    $0x10,%esp
f0106664:	85 c0                	test   %eax,%eax
f0106666:	0f 85 b5 00 00 00    	jne    f0106721 <spin_unlock+0xd0>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010666c:	83 ec 04             	sub    $0x4,%esp
f010666f:	6a 28                	push   $0x28
f0106671:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106674:	50                   	push   %eax
f0106675:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0106678:	50                   	push   %eax
f0106679:	e8 66 f6 ff ff       	call   f0105ce4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010667e:	8b 43 08             	mov    0x8(%ebx),%eax
f0106681:	0f b6 00             	movzbl (%eax),%eax
f0106684:	50                   	push   %eax
f0106685:	ff 73 04             	pushl  0x4(%ebx)
f0106688:	83 ec 08             	sub    $0x8,%esp
f010668b:	e8 82 fd ff ff       	call   f0106412 <cpunum>
f0106690:	83 c4 08             	add    $0x8,%esp
f0106693:	50                   	push   %eax
f0106694:	68 ac 83 10 f0       	push   $0xf01083ac
f0106699:	e8 34 d3 ff ff       	call   f01039d2 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010669e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01066a3:	83 c4 20             	add    $0x20,%esp
f01066a6:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01066aa:	74 61                	je     f010670d <spin_unlock+0xbc>
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066ac:	83 ec 08             	sub    $0x8,%esp
f01066af:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01066b2:	50                   	push   %eax
f01066b3:	ff 74 9d c8          	pushl  -0x38(%ebp,%ebx,4)
f01066b7:	e8 de ec ff ff       	call   f010539a <debuginfo_eip>
f01066bc:	83 c4 10             	add    $0x10,%esp
f01066bf:	85 c0                	test   %eax,%eax
f01066c1:	78 29                	js     f01066ec <spin_unlock+0x9b>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01066c3:	83 ec 04             	sub    $0x4,%esp
f01066c6:	8b 54 9d c8          	mov    -0x38(%ebp,%ebx,4),%edx
f01066ca:	89 d0                	mov    %edx,%eax
f01066cc:	2b 45 b8             	sub    -0x48(%ebp),%eax
f01066cf:	50                   	push   %eax
f01066d0:	ff 75 b0             	pushl  -0x50(%ebp)
f01066d3:	ff 75 b4             	pushl  -0x4c(%ebp)
f01066d6:	ff 75 ac             	pushl  -0x54(%ebp)
f01066d9:	ff 75 a8             	pushl  -0x58(%ebp)
f01066dc:	52                   	push   %edx
f01066dd:	68 55 83 10 f0       	push   $0xf0108355
f01066e2:	e8 eb d2 ff ff       	call   f01039d2 <cprintf>
f01066e7:	83 c4 20             	add    $0x20,%esp
f01066ea:	eb 14                	jmp    f0106700 <spin_unlock+0xaf>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01066ec:	83 ec 08             	sub    $0x8,%esp
f01066ef:	ff 74 9d c8          	pushl  -0x38(%ebp,%ebx,4)
f01066f3:	68 6c 83 10 f0       	push   $0xf010836c
f01066f8:	e8 d5 d2 ff ff       	call   f01039d2 <cprintf>
f01066fd:	83 c4 10             	add    $0x10,%esp
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106700:	43                   	inc    %ebx
f0106701:	83 fb 09             	cmp    $0x9,%ebx
f0106704:	7f 07                	jg     f010670d <spin_unlock+0xbc>
f0106706:	83 7c 9d c8 00       	cmpl   $0x0,-0x38(%ebp,%ebx,4)
f010670b:	75 9f                	jne    f01066ac <spin_unlock+0x5b>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010670d:	83 ec 04             	sub    $0x4,%esp
f0106710:	68 74 83 10 f0       	push   $0xf0108374
f0106715:	6a 68                	push   $0x68
f0106717:	68 45 83 10 f0       	push   $0xf0108345
f010671c:	e8 80 9b ff ff       	call   f01002a1 <_panic>
	}

	lk->pcs[0] = 0;
f0106721:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106728:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f010672f:	b8 00 00 00 00       	mov    $0x0,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106734:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010673a:	c9                   	leave  
f010673b:	c3                   	ret    

f010673c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f010673c:	55                   	push   %ebp
f010673d:	89 e5                	mov    %esp,%ebp
f010673f:	57                   	push   %edi
f0106740:	56                   	push   %esi
f0106741:	83 ec 14             	sub    $0x14,%esp
f0106744:	8b 55 14             	mov    0x14(%ebp),%edx
f0106747:	8b 75 08             	mov    0x8(%ebp),%esi
f010674a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010674d:	8b 45 10             	mov    0x10(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106750:	85 d2                	test   %edx,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106752:	89 75 f0             	mov    %esi,-0x10(%ebp)
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f0106755:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d1 = dd.s.high;
f0106758:	89 55 f4             	mov    %edx,-0xc(%ebp)
  n0 = nn.s.low;
  n1 = nn.s.high;
f010675b:	89 fe                	mov    %edi,%esi

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010675d:	75 11                	jne    f0106770 <__udivdi3+0x34>
    {
      if (d0 > n1)
f010675f:	39 f8                	cmp    %edi,%eax
f0106761:	76 4d                	jbe    f01067b0 <__udivdi3+0x74>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106763:	89 fa                	mov    %edi,%edx
f0106765:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106768:	f7 75 e4             	divl   -0x1c(%ebp)
f010676b:	89 c7                	mov    %eax,%edi
f010676d:	eb 09                	jmp    f0106778 <__udivdi3+0x3c>
f010676f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106770:	39 7d f4             	cmp    %edi,-0xc(%ebp)
f0106773:	76 17                	jbe    f010678c <__udivdi3+0x50>
	{
	  /* 00 = nn / DD */

	  q0 = 0;
f0106775:	31 ff                	xor    %edi,%edi
f0106777:	90                   	nop
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
		}

	      q1 = 0;
f0106778:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010677f:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106782:	83 c4 14             	add    $0x14,%esp
f0106785:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106786:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106788:	5f                   	pop    %edi
f0106789:	c9                   	leave  
f010678a:	c3                   	ret    
f010678b:	90                   	nop
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010678c:	0f bd 45 f4          	bsr    -0xc(%ebp),%eax
	  if (bm == 0)
f0106790:	89 c7                	mov    %eax,%edi
f0106792:	83 f7 1f             	xor    $0x1f,%edi
f0106795:	75 4d                	jne    f01067e4 <__udivdi3+0xa8>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106797:	3b 75 f4             	cmp    -0xc(%ebp),%esi
f010679a:	77 0a                	ja     f01067a6 <__udivdi3+0x6a>
f010679c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
		}
	      else
		q0 = 0;
f010679f:	31 ff                	xor    %edi,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01067a1:	39 55 f0             	cmp    %edx,-0x10(%ebp)
f01067a4:	72 d2                	jb     f0106778 <__udivdi3+0x3c>
		{
		  q0 = 1;
f01067a6:	bf 01 00 00 00       	mov    $0x1,%edi
f01067ab:	eb cb                	jmp    f0106778 <__udivdi3+0x3c>
f01067ad:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01067b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01067b3:	85 c0                	test   %eax,%eax
f01067b5:	75 0e                	jne    f01067c5 <__udivdi3+0x89>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01067b7:	b8 01 00 00 00       	mov    $0x1,%eax
f01067bc:	31 c9                	xor    %ecx,%ecx
f01067be:	31 d2                	xor    %edx,%edx
f01067c0:	f7 f1                	div    %ecx
f01067c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01067c5:	89 f0                	mov    %esi,%eax
f01067c7:	31 d2                	xor    %edx,%edx
f01067c9:	f7 75 e4             	divl   -0x1c(%ebp)
f01067cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01067cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01067d2:	f7 75 e4             	divl   -0x1c(%ebp)
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01067d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01067d8:	83 c4 14             	add    $0x14,%esp

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01067db:	89 c7                	mov    %eax,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01067dd:	5e                   	pop    %esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01067de:	89 f8                	mov    %edi,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01067e0:	5f                   	pop    %edi
f01067e1:	c9                   	leave  
f01067e2:	c3                   	ret    
f01067e3:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01067e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01067e9:	29 f8                	sub    %edi,%eax
f01067eb:	89 45 e8             	mov    %eax,-0x18(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
f01067ee:	89 f9                	mov    %edi,%ecx
f01067f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01067f3:	d3 e2                	shl    %cl,%edx
f01067f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01067f8:	8a 4d e8             	mov    -0x18(%ebp),%cl
f01067fb:	d3 e8                	shr    %cl,%eax
f01067fd:	09 c2                	or     %eax,%edx
	      d0 = d0 << bm;
f01067ff:	89 f9                	mov    %edi,%ecx
f0106801:	d3 65 e4             	shll   %cl,-0x1c(%ebp)
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106804:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106807:	8a 4d e8             	mov    -0x18(%ebp),%cl
f010680a:	89 f2                	mov    %esi,%edx
f010680c:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
f010680e:	89 f9                	mov    %edi,%ecx
f0106810:	d3 e6                	shl    %cl,%esi
f0106812:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106815:	8a 4d e8             	mov    -0x18(%ebp),%cl
f0106818:	d3 e8                	shr    %cl,%eax
f010681a:	09 c6                	or     %eax,%esi
	      n0 = n0 << bm;
f010681c:	89 f9                	mov    %edi,%ecx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010681e:	89 f0                	mov    %esi,%eax
f0106820:	f7 75 f4             	divl   -0xc(%ebp)
f0106823:	89 d6                	mov    %edx,%esi
f0106825:	89 c7                	mov    %eax,%edi

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106827:	d3 65 f0             	shll   %cl,-0x10(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
f010682a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010682d:	f7 e7                	mul    %edi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010682f:	39 f2                	cmp    %esi,%edx
f0106831:	77 0f                	ja     f0106842 <__udivdi3+0x106>
f0106833:	0f 85 3f ff ff ff    	jne    f0106778 <__udivdi3+0x3c>
f0106839:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010683c:	0f 86 36 ff ff ff    	jbe    f0106778 <__udivdi3+0x3c>
		{
		  q0--;
f0106842:	4f                   	dec    %edi
f0106843:	e9 30 ff ff ff       	jmp    f0106778 <__udivdi3+0x3c>

f0106848 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106848:	55                   	push   %ebp
f0106849:	89 e5                	mov    %esp,%ebp
f010684b:	57                   	push   %edi
f010684c:	56                   	push   %esi
f010684d:	83 ec 30             	sub    $0x30,%esp
f0106850:	8b 55 14             	mov    0x14(%ebp),%edx
f0106853:	8b 45 10             	mov    0x10(%ebp),%eax
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
f0106856:	89 d7                	mov    %edx,%edi
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
f0106858:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f010685b:	89 c6                	mov    %eax,%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;
f010685d:	8b 55 0c             	mov    0xc(%ebp),%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106860:	8b 45 08             	mov    0x8(%ebp),%eax
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106863:	85 ff                	test   %edi,%edi
f0106865:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010686c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
     defined (L_umoddi3) || defined (L_moddi3))
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
f0106873:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106876:	89 45 dc             	mov    %eax,-0x24(%ebp)
  n1 = nn.s.high;
f0106879:	89 55 cc             	mov    %edx,-0x34(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010687c:	75 3e                	jne    f01068bc <__umoddi3+0x74>
    {
      if (d0 > n1)
f010687e:	39 d6                	cmp    %edx,%esi
f0106880:	0f 86 a2 00 00 00    	jbe    f0106928 <__umoddi3+0xe0>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106886:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);

	  /* Remainder in n0.  */
	}

      if (rp != 0)
f0106888:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010688b:	85 c9                	test   %ecx,%ecx

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010688d:	89 55 dc             	mov    %edx,-0x24(%ebp)

	  /* Remainder in n0.  */
	}

      if (rp != 0)
f0106890:	74 1b                	je     f01068ad <__umoddi3+0x65>
	{
	  rr.s.low = n0;
f0106892:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106895:	89 45 e0             	mov    %eax,-0x20(%ebp)
	  rr.s.high = 0;
f0106898:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f010689f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01068a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01068a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01068a8:	89 10                	mov    %edx,(%eax)
f01068aa:	89 48 04             	mov    %ecx,0x4(%eax)
f01068ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01068b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01068b3:	83 c4 30             	add    $0x30,%esp
f01068b6:	5e                   	pop    %esi
f01068b7:	5f                   	pop    %edi
f01068b8:	c9                   	leave  
f01068b9:	c3                   	ret    
f01068ba:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01068bc:	3b 7d cc             	cmp    -0x34(%ebp),%edi
f01068bf:	76 1f                	jbe    f01068e0 <__umoddi3+0x98>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
f01068c1:	8b 55 08             	mov    0x8(%ebp),%edx
	      rr.s.high = n1;
f01068c4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
f01068c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	      rr.s.high = n1;
f01068ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	      *rp = rr.ll;
f01068cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01068d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01068d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01068d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01068d9:	83 c4 30             	add    $0x30,%esp
f01068dc:	5e                   	pop    %esi
f01068dd:	5f                   	pop    %edi
f01068de:	c9                   	leave  
f01068df:	c3                   	ret    
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01068e0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f01068e3:	83 f0 1f             	xor    $0x1f,%eax
f01068e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01068e9:	75 61                	jne    f010694c <__umoddi3+0x104>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01068eb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01068ee:	77 05                	ja     f01068f5 <__umoddi3+0xad>
f01068f0:	39 75 dc             	cmp    %esi,-0x24(%ebp)
f01068f3:	72 10                	jb     f0106905 <__umoddi3+0xbd>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01068f5:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01068f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01068fb:	29 f0                	sub    %esi,%eax
f01068fd:	19 fa                	sbb    %edi,%edx
f01068ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106902:	89 55 cc             	mov    %edx,-0x34(%ebp)
	      else
		q0 = 0;

	      q1 = 0;

	      if (rp != 0)
f0106905:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0106908:	85 d2                	test   %edx,%edx
f010690a:	74 a1                	je     f01068ad <__umoddi3+0x65>
		{
		  rr.s.low = n0;
f010690c:	8b 45 dc             	mov    -0x24(%ebp),%eax
		  rr.s.high = n1;
f010690f:	8b 55 cc             	mov    -0x34(%ebp),%edx

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
f0106912:	89 45 e0             	mov    %eax,-0x20(%ebp)
		  rr.s.high = n1;
f0106915:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		  *rp = rr.ll;
f0106918:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010691b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010691e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106921:	89 01                	mov    %eax,(%ecx)
f0106923:	89 51 04             	mov    %edx,0x4(%ecx)
f0106926:	eb 85                	jmp    f01068ad <__umoddi3+0x65>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106928:	85 f6                	test   %esi,%esi
f010692a:	75 0b                	jne    f0106937 <__umoddi3+0xef>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010692c:	b8 01 00 00 00       	mov    $0x1,%eax
f0106931:	31 d2                	xor    %edx,%edx
f0106933:	f7 f6                	div    %esi
f0106935:	89 c6                	mov    %eax,%esi

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106937:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010693a:	89 fa                	mov    %edi,%edx
f010693c:	f7 f6                	div    %esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010693e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106941:	89 55 cc             	mov    %edx,-0x34(%ebp)
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106944:	f7 f6                	div    %esi
f0106946:	e9 3d ff ff ff       	jmp    f0106888 <__umoddi3+0x40>
f010694b:	90                   	nop
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010694c:	b8 20 00 00 00       	mov    $0x20,%eax
f0106951:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0106954:	89 45 d8             	mov    %eax,-0x28(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
f0106957:	89 fa                	mov    %edi,%edx
f0106959:	8a 4d d4             	mov    -0x2c(%ebp),%cl
f010695c:	d3 e2                	shl    %cl,%edx
f010695e:	89 f0                	mov    %esi,%eax
f0106960:	8a 4d d8             	mov    -0x28(%ebp),%cl
f0106963:	d3 e8                	shr    %cl,%eax
	      d0 = d0 << bm;
f0106965:	8a 4d d4             	mov    -0x2c(%ebp),%cl
f0106968:	d3 e6                	shl    %cl,%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010696a:	89 d7                	mov    %edx,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010696c:	8a 4d d8             	mov    -0x28(%ebp),%cl
f010696f:	8b 55 cc             	mov    -0x34(%ebp),%edx
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106972:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106974:	d3 ea                	shr    %cl,%edx
	      n1 = (n1 << bm) | (n0 >> b);
f0106976:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0106979:	8a 4d d4             	mov    -0x2c(%ebp),%cl
f010697c:	d3 e0                	shl    %cl,%eax
f010697e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0106981:	8a 4d d8             	mov    -0x28(%ebp),%cl
f0106984:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106987:	d3 e8                	shr    %cl,%eax
f0106989:	0b 45 cc             	or     -0x34(%ebp),%eax
f010698c:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n0 = n0 << bm;
f010698f:	8a 4d d4             	mov    -0x2c(%ebp),%cl

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106992:	f7 f7                	div    %edi
f0106994:	89 55 cc             	mov    %edx,-0x34(%ebp)

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106997:	d3 65 dc             	shll   %cl,-0x24(%ebp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
f010699a:	f7 e6                	mul    %esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010699c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);
f010699f:	89 45 c8             	mov    %eax,-0x38(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01069a2:	77 0a                	ja     f01069ae <__umoddi3+0x166>
f01069a4:	75 12                	jne    f01069b8 <__umoddi3+0x170>
f01069a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01069a9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01069ac:	76 0a                	jbe    f01069b8 <__umoddi3+0x170>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01069ae:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01069b1:	29 f1                	sub    %esi,%ecx
f01069b3:	19 fa                	sbb    %edi,%edx
f01069b5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		}

	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
f01069b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01069bb:	85 c0                	test   %eax,%eax
f01069bd:	0f 84 ea fe ff ff    	je     f01068ad <__umoddi3+0x65>
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01069c3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01069c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01069c9:	2b 45 c8             	sub    -0x38(%ebp),%eax
f01069cc:	19 d1                	sbb    %edx,%ecx
f01069ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01069d1:	89 ca                	mov    %ecx,%edx
f01069d3:	8a 4d d8             	mov    -0x28(%ebp),%cl
f01069d6:	d3 e2                	shl    %cl,%edx
f01069d8:	8a 4d d4             	mov    -0x2c(%ebp),%cl
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01069db:	89 45 dc             	mov    %eax,-0x24(%ebp)
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01069de:	d3 e8                	shr    %cl,%eax
f01069e0:	09 c2                	or     %eax,%edx
		  rr.s.high = n1 >> bm;
f01069e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01069e5:	d3 e8                	shr    %cl,%eax

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01069e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		  rr.s.high = n1 >> bm;
f01069ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01069ed:	e9 ad fe ff ff       	jmp    f010689f <__umoddi3+0x57>
