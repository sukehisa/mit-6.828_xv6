// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	cprintf("In pgfault: fault @%08x\n", addr);
	cprintf("pte: %08x\n", vpt[PGNUM(addr)]);
	if (!(err & FEC_WR))
		panic("pgfault: FEC_WR check err"); 
	if (!(vpt[PGNUM(addr)] & PTE_COW))
		panic("pgfault: PTE_COW check err");

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)) < 0)
		panic("pgfault: page alloc %e", r);
	memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
	if ((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE),
					PTE_P|PTE_W|PTE_U)) < 0)
		panic("pgfault: page map %e", r);
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
		panic("pgfault: page unmap %e", r);

//	panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  
// If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	pte = vpt[pn];
	addr = (void *) (pn << PGSHIFT);
	
//	cprintf("pn: %08x pte: %08x\n", pn, pte); //deb
	if ((pte & PTE_W) || (pte & PTE_COW)) {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P|PTE_COW)) < 0)
			panic("sys_page_map->newenv");
		if ((r = sys_page_map(0, addr, 0, addr, PTE_U|PTE_P|PTE_COW)) < 0)
			panic("sys_page_map->curenv");	
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, pte & 0xfff)) < 0)
//		if ((r = sys_page_map(0, addr, envid, addr, PTE_U | PTE_P)) < 0)
			return r;
	}

	return 0;
}




//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	envid_t envid;
	uint8_t *addr;
	uint32_t pdex, ptex, pn;
	int r;
	extern unsigned char end[];
	extern void _pgfault_upcall(void);

	/* 1. installing page fault handler */
	set_pgfault_handler(pgfault);

//	// TODO experimental
//	if ((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE),
//					PTE_P|PTE_W|PTE_U)) < 0) 
//		panic("sys_page_alloc err %e\n", r);

	/* 2. */
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	// child
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	/* 3. */
	// parent	
	for (pdex = PDX(0); pdex < PDX(UTOP); pdex++) {
		if (vpd[pdex] & (PTE_P)) {
			for (ptex = 0; ptex < NPTENTRIES; ptex++) {
				pn = (pdex<<10) + ptex;
				if ((pn<PGNUM(UXSTACKTOP-PGSIZE)) && (vpt[pn]&PTE_P)) {
					duppage(envid, pn);
				}
			}
		}
	}
	cprintf("done duppage\n");
	// exception stack allocation
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE),
					PTE_P|PTE_W|PTE_U)) < 0) 
		panic("sys_page_alloc err %e\n", r);
//	if ((r = sys_page_map(envid, (void *)(UXSTACKTOP-PGSIZE),
//					      0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
//		return r;
//	memmove(UTEMP, (void *)(UXSTACKTOP-PGSIZE), PGSIZE);
//	if ((r = sys_page_unmap(0, UTEMP)) < 0)
//		return r;
//	cprintf("done exception stack alloc\n");

	/* 4. */
	if ((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
		panic("sys_env_set_pgfault_upcall: err %e\n", r);
	cprintf("done set pgfault upcall\n");
	
	/* 5. */
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: err %e\n", r);
	cprintf("sys_env_set status\n");

	return envid;
	
//	panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
