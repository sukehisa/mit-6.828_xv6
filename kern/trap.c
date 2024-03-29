#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>
#include <inc/string.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>
#include <kern/time.h>

static struct Taskstate ts;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}


void
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	/// initialize the idt to point to each of entry point
	// trap handler funtions defined in trapentry.S
	
	// exception handler
	extern void trap_divide();
	extern void trap_debug();
	extern void trap_nmi();
	extern void trap_brkpt();
	extern void trap_oflow();
	extern void trap_bound();
	extern void trap_illop();
	extern void trap_device();
	extern void trap_dblflt();
	//extern void trap_coproc();
	extern void trap_tss();
	extern void trap_segnp();
	extern void trap_stack();
	extern void trap_gpflt();
	extern void trap_pgflt();
	//extern void trap_res();
	extern void trap_fperr();
	extern void trap_align();
	extern void trap_mchk();
	extern void trap_simderr();
	extern void trap_syscall();

	// IRQ handlers
	extern void irq0_handler();
	extern void irq1_handler();
	extern void irq2_handler();
	extern void irq3_handler();
	extern void irq4_handler();
	extern void irq5_handler();
	extern void irq6_handler();
	extern void irq7_handler();
	extern void irq8_handler();
	extern void irq9_handler();
	extern void irq10_handler();
	extern void irq11_handler();
	extern void irq12_handler();
	extern void irq13_handler();
	extern void irq14_handler();
	extern void irq15_handler();

			
	SETGATE(idt[T_DIVIDE], 0, GD_KT, trap_divide, 0);
	SETGATE(idt[T_DEBUG], 0, GD_KT, trap_debug, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, trap_nmi, 0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, trap_brkpt, 3);
	SETGATE(idt[T_OFLOW], 0, GD_KT, trap_oflow, 0);
	SETGATE(idt[T_BOUND], 0, GD_KT, trap_bound, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, trap_illop, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, trap_device, 0);
	SETGATE(idt[T_DBLFLT], 0, GD_KT, trap_dblflt, 0);
	//SETGATE(idt[T_COPROC], 0, GD_KT, trap_coproc, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, trap_tss, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, trap_segnp, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, trap_stack, 0);
	SETGATE(idt[T_GPFLT], 0, GD_KT, trap_gpflt, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, trap_pgflt, 0);
	//SETGATE(idt[T_RES], 0, GD_KT, trap_res, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, trap_fperr, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, trap_align, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, trap_mchk, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, trap_simderr, 0);

	//Initial system call entry
	SETGATE(idt[T_SYSCALL], 0, GD_KT, trap_syscall, 3);

	//Initial IRQ handlers
	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, irq0_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, irq1_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, irq2_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, irq3_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, irq4_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, irq5_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, irq6_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, irq7_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, irq8_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, irq9_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, irq10_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, irq11_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, irq12_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, irq13_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, irq14_handler, 0);
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, irq15_handler, 0);


	// Per-CPU setup 
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	// The example code here sets up the Task State Segment (TSS) and
	// the TSS descriptor for CPU 0. But it is incorrect if we are
	// running on other CPUs because each CPU has its own kernel stack.
	// Fix the code so that it works for all CPUs.
	//
	// Hints:
	//   - The macro "thiscpu" always refers to the current CPU's
	//     struct Cpu;
	//   - The ID of the current CPU is given by cpunum() or
	//     thiscpu->cpu_id;
	//   - Use "thiscpu->cpu_ts" as the TSS for the current CPU,
	//     rather than the global "ts" variable;
	//   - Use gdt[(GD_TSS0 >> 3) + i] for CPU i's TSS descriptor;
	//   - You mapped the per-CPU kernel stacks in mem_init_mp()
	//
	// ltr sets a 'busy' flag in the TSS selector, so if you
	// accidentally load the same TSS on more than one CPU, you'll
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i;
	for (i = 0; i < NCPU; i++) {
		cpus[i].cpu_ts.ts_esp0 = (uintptr_t)percpu_kstacks[cpunum()] + KSTKSIZE;
		cpus[i].cpu_ts.ts_ss0 = GD_KD;	
		//	ts.ts_esp0 = KSTACKTOP;
		//	ts.ts_ss0 = GD_KD;

		// Initialize the TSS slot of the gdt.
		gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&cpus[i].cpu_ts),
				sizeof(struct Taskstate), 0);
		gdt[(GD_TSS0 >> 3) + i].sd_s = 0;

		//	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
		//					sizeof(struct Taskstate), 0);
		//	gdt[GD_TSS0 >> 3].sd_s = 0;
	}

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);
	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
	uint32_t eflags;

	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
		case T_DIVIDE:
		case T_DEBUG:
		case T_NMI:
			goto unexpected;
		case T_BRKPT:
			eflags = read_eflags();
			cprintf("elfags 0x%08x\n", eflags);
			eflags |= FL_RF;
			cprintf("elfags 0x%08x\n", eflags);
			write_eflags(eflags);
			monitor(tf);
			break;
		case T_OFLOW:
		case T_BOUND:
		case T_ILLOP:
		case T_DEVICE:
		case T_DBLFLT:
//		case T_COPROC:
		case T_TSS:
		case T_SEGNP:
		case T_STACK:
		case T_GPFLT:
			goto unexpected;
		case T_PGFLT:
			//cprintf("trap_dispatch: page fault\n");		
			page_fault_handler(tf);
			break;
//		case T_RES:
		case T_FPERR:
		case T_ALIGN:
		case T_MCHK:
		case T_SIMDERR:
			goto unexpected;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
					tf->tf_regs.reg_edx,
					tf->tf_regs.reg_ecx,
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			break;

		// Handle clock interrupts. Don't forget to acknowledge the
		// interrupt using lapic_eoi() before calling the scheduler!
		// LAB 4: Your code here.
		case IRQ_OFFSET + IRQ_TIMER:
//			cprintf("Timer interrupt on irq 0\n");
			lapic_eoi();
			sched_yield();	
			cprintf("Shouldn't happen..\n");
			break;

		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		case IRQ_OFFSET + IRQ_SPURIOUS:
			cprintf("Spurious interrupt on irq 7\n");
			print_trapframe(tf);
			break;
		default:
			goto unexpected;
			break;
	}

	return;

	// Add time tick increment to clock interrupts.
	// Be careful! In multiprocessors, clock interrupts are
	// triggered on every CPU.
	// LAB 6: Your code here.


	// Unexpected trap: The user process or the kernel has a bug.
unexpected:
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
		asm volatile("hlt");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

//	cprintf("Incoming TRAP frame at %p\n", tf);
//	cprintf("errno: %x\n", tf->tf_trapno);

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;	
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) 
		env_run(curenv);
	else
		sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// LAB 3: Your code here.
//	cprintf("\n[%08x]In page_fault_handler! fault_va:%08x\n", curenv->env_id, fault_va);
	//user_mem_assert(curenv, (void *)fault_va, PGSIZE, PTE_P); //What's this??ToDo

	// Handle kernel-mode page faults.
	// determine whether a fault happened in user or kernel mode 
	// check the low 2 bits of cs
	if ((tf->tf_cs & 0x0003) == 0)
		panic("page fault happened in kernel mode!");

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.


	// Call the environment's page fault upcall, if one exists.  
	// Set up a page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, 
	// the environment didn't allocate a page for its exception stack 
	// or can't write to it,
	// or the exception stack overflows, 
	// then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {	
	//	cprintf("upcall found\n"); //deb
		// some checkings
		user_mem_assert(curenv, (void *)(UXSTACKTOP-PGSIZE), PGSIZE, PTE_W);
		if (!page_lookup(curenv->env_pgdir, (void *)(UXSTACKTOP-PGSIZE), NULL))
			env_destroy(curenv);

		void *dststack;
		// if this is recursive call to pgfault_upcall, make some space
		if (tf->tf_esp >= (UXSTACKTOP-PGSIZE) && tf->tf_esp < UXSTACKTOP) 
			dststack = (void *)tf->tf_esp - 4;
		else 
			dststack = (void *)UXSTACKTOP;
		dststack -= sizeof(struct UTrapframe);

		// stack overflow
		if ((uint32_t)dststack < (UXSTACKTOP-PGSIZE)) {
			cprintf("[%08x] user exception stack overflowed\n", curenv->env_id);
			env_destroy(curenv);
		}

//		cprintf("[%08x] dststack:%08x\n", curenv->env_id, dststack); //deb
//		pte_t *pte;
//		pde_t *pde;
//
//		if (page_lookup(curenv->env_pgdir, (void *)dststack, &pte))
//			cprintf("curenv:pte of dststack: %08x\n", *pte);
//		if (page_lookup(kern_pgdir, (void *)dststack, &pte))
//			cprintf("kernel:pte of dststack: %08x\n", *pte);
//		pde = &curenv->env_pgdir[PDX((void *)dststack)];
//		cprintf("curenv:pde of dststack: %08x\n", *pde);
//		*pde = *pde | PTE_W
//		pde = &kern_pgdir[PDX((void *)dststack)];
//		cprintf("kernel:pde of dststack: %08x\n", *pde);
//		cprintf("\n");
//		if (page_lookup(curenv->env_pgdir, (void *)(0xeebfdf50), &pte))
//			cprintf("curenv:pte of userstack: %08x\n", *pte);
//		if (page_lookup(kern_pgdir, (void *)(0xeebfdf50), &pte))
//			cprintf("kernel:pte of userstack: %08x\n", *pte);

		struct UTrapframe *udststack = (struct UTrapframe *)dststack;
//		pde_t *pde;
//		pde = &curenv->env_pgdir[PDX((void *)dststack)];
//		*pde = *pde | PTE_W | PTE_U | PTE_P;
//		pde = &curenv->env_pgdir[PDX((void *)fault_va)];
//		*pde = *pde | PTE_W | PTE_U | PTE_P;
		lcr3(PADDR(curenv->env_pgdir));
		udststack->utf_err = tf->tf_err;
		udststack->utf_fault_va = fault_va;
		udststack->utf_regs = tf->tf_regs;
		udststack->utf_eip = tf->tf_eip;
		udststack->utf_eflags = tf->tf_eflags;
		udststack->utf_esp = tf->tf_esp;
		lcr3(PADDR(kern_pgdir));

		tf->tf_esp = (uintptr_t)dststack;
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;

		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
			curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

