/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>
//<<<<<<< HEAD
#include <kern/time.h>
//=======
#include <kern/spinlock.h>
//>>>>>>> new_lab5
#include <kern/e1000.h>


// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	user_mem_assert(curenv, (void*)s, len, PTE_P | PTE_U);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	//cprintf("get:%08x\n", curenv->env_id);
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
	return r;
}
//<<<<<<< HEAD

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	/*stone's solution for lab4-A*/
	//panic("sys_exofork not implemented");
	struct Env* newenv;
	int r;
	if ((r = env_alloc(&newenv, curenv->env_id)) < 0)
		return r;
	newenv->env_status = ENV_NOT_RUNNABLE;
	newenv->env_tf = curenv->env_tf;
	newenv->env_tf.tf_regs.reg_eax = 0;
	return newenv->env_id;
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	/*stone's solution for lab4-A*/
	//panic("sys_env_set_status not implemented");
	struct Env* e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if ((e->env_status != ENV_RUNNABLE) && (e->env_status != ENV_NOT_RUNNABLE))
		return -E_INVAL;
	e->env_status = status;
	return 0;
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
	/*stone's solution for lab5*/
	int r;
	struct Env* e;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return -E_BAD_ENV;
	e->env_tf = *tf;
	e->env_tf.tf_cs |= 3;
	e->env_tf.tf_eflags |= FL_IF;
	return 0;
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	/*stone's solution for lab4-B*/
	/*stone: well, i thought it was done in partA and just did not show off in the homepage..
		but it does not matter cuz so ez that just can be done with the hint.*/
	//panic("sys_env_set_pgfault_upcall not implemented");
	struct Env* e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	//cprintf("sys_env_set_pgfault_upcall:\n");
	e->env_pgfault_upcall = func;
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	/*stone's solution for lab4-A*/
	//panic("sys_page_alloc not implemented");
	struct Env* e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (va >= (void*)UTOP)
		return -E_INVAL;
	if (((uint32_t)va % PGSIZE) != 0)
		return -E_INVAL;
	if (!(perm & PTE_U) || !(perm & PTE_P))
		return -E_INVAL;
	struct Page* p;
	if ((p = page_alloc(ALLOC_ZERO)) == 0)
		return -E_NO_MEM;
	if ((r = page_insert(e->env_pgdir, p, va, perm)) < 0){
		page_free(p);
		return -E_NO_MEM;
	}
	return 0;
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	/*stone's solution for lab4-A*/
	//panic("sys_page_map not implemented");
	struct Env* se;
	struct Env* de;
	int r;
	if ((r = envid2env(srcenvid, &se, 1)) < 0)
		return r;
	if ((r = envid2env(dstenvid, &de, 1)) < 0)
		return r;
	if (srcva >= (void*)UTOP)
		return -E_INVAL;
	if (((uint32_t)srcva % PGSIZE) != 0)
		return -E_INVAL;
	if (dstva >= (void*)UTOP)
		return -E_INVAL;
	if (((uint32_t)dstva % PGSIZE) != 0)
		return -E_INVAL;
	struct Page* p;
	pte_t* pte;
	if ((p = page_lookup(se->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
	if (!(perm & PTE_U) || !(perm & PTE_P))
		return -E_INVAL;
	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
	if ((r = page_insert(de->env_pgdir, p, dstva, perm)) < 0)
		return -E_NO_MEM;
	return 0;

}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	/*stone's solution for lab4-A*/
	//panic("sys_page_unmap not implemented");
	struct Env* e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (va >= (void*)UTOP)
		return -E_INVAL;
	if (((uint32_t)va % PGSIZE) != 0)
		return -E_INVAL;
	page_remove(e->env_pgdir, va);
	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	/*stone's solution for lab4-C*/
	//panic("sys_ipc_try_send not implemented");
	struct Env* e;
	int r;
	if ((r = envid2env(envid, &e, 0)) < 0)
		return r;
	if (!e->env_ipc_recving || e->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
	e->env_ipc_perm = 0;
	if (srcva < (void*)UTOP){
		if (((uint32_t)srcva % PGSIZE) != 0)
			return -E_INVAL;
		if (!(perm & PTE_U) || !(perm & PTE_P))
			return -E_INVAL;
		struct Page* p;
		pte_t* pte;
		if ((p = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
			return -E_INVAL;
		if ((perm & PTE_W) > 0 && !(*pte & PTE_W))
 			return -E_INVAL;
		if ((r = page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm)) < 0)
			return -E_NO_MEM;
	}
	e->env_ipc_recving = 0;
	e->env_ipc_value = value;
	e->env_ipc_from = curenv->env_id;
	e->env_ipc_perm = perm;
	e->env_tf.tf_regs.reg_eax = 0;
	e->env_status = ENV_RUNNABLE;
	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	/*stone's solution for lab4-C*/
	//panic("sys_ipc_recv not implemented");
	if ((uint32_t)dstva % PGSIZE != 0 && dstva < (void*)UTOP)
		return -E_INVAL;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_ipc_dstva = dstva;
	curenv->env_ipc_from = 0;
	curenv->env_ipc_recving = 1;
	sched_yield();
}

/*stone's solution for lab3-B*/
void
sbrk(struct Env* e, size_t len)
{
	char* start = ROUNDDOWN(e->env_sbrk_pos - len, PGSIZE);
	char* end = ROUNDUP(e->env_sbrk_pos, PGSIZE);
	struct Page* p;
	char* pos = start;
	//cprintf("1\n");
	for (; pos < end; pos += PGSIZE){
		int r;
		if (!(p = page_alloc(0)))
			panic("env_alloc: page alloc failed\n");
		else if ((r = page_insert(e->env_pgdir, p, (void*)pos, PTE_U | PTE_W | PTE_P)) < 0)
			panic("env_alloc: %e\n", r);
		//cprintf("2\n");
	}
	e->env_sbrk_pos = start;	
}
static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	/*stone's solution for lab3-B*/
	sbrk(curenv, inc);
	return (int)curenv->env_sbrk_pos;
}
/*stone's solution for lab3-B*/
/*stone's solution for lab4-A(modify)*/
void
router(struct Trapframe *tf){
	lock_kernel();
	curenv->env_tf = *tf;
	tf = &curenv->env_tf;
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
	env_run(curenv);
}
//<<<<<<< HEAD

// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	//panic("sys_time_msec not implemented");
	/*stone's solution for lab6-A*/
	return time_msec();
}

/*stone's solution for lab6-A*/
static int
sys_transmit(uint8_t *data, uint32_t len){
	if ((uintptr_t) data >= UTOP)
		return -E_INVAL;
	else
  		return e1000_transmit(data, len);
}
/*stone's solution for lab6-B*/
static int
sys_receive(uint8_t *data, uint32_t *len){
 	if ((uintptr_t) data >= UTOP)
		return -E_INVAL;

  	int ret = e1000_receive(data);
	if (ret > 0){
    		*len = ret;
    		ret = 0;
	}
	return ret;
}

//=======
//>>>>>>> new_lab5
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	/*stone's solution for lab3-B*/
	int32_t ret = -E_INVAL;
	switch (syscallno){
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			ret = sys_env_destroy(a1);
			break;
		case SYS_map_kernel_page:
			ret = sys_map_kernel_page((void*)a1, (void*)a2);
			break;
		case SYS_sbrk:
			ret = sys_sbrk(a1);
			break;
		/*stone's solution for lab4-A*/
		case SYS_yield:
			sys_yield();
			ret = 0;
			break;
		case SYS_exofork:
			ret = sys_exofork();
			break;
		case SYS_env_set_status:
			ret = sys_env_set_status(a1, a2);
			break;
		case SYS_env_set_pgfault_upcall:
			ret = sys_env_set_pgfault_upcall((envid_t)a1, (void*)a2);
			break;
		case SYS_page_alloc:
			ret = sys_page_alloc((envid_t)a1, (void*)a2, (int)a3);
			break;
		case SYS_page_map:
			/*stone: see lib/syscall.c for modification details*/
			ret = sys_page_map(*((uint32_t*)a1), (void*)*((uint32_t*)a1 + 1), *((uint32_t*)a1 + 2), (void*)*((uint32_t*)a1 + 3), *((uint32_t*)a1 + 4));
			//ret = sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
			break;
		case SYS_page_unmap:
			ret = sys_page_unmap(a1, (void*)a2);
			break;
		case SYS_ipc_recv:
			ret = sys_ipc_recv((void*)a1);
			break;
		case SYS_ipc_try_send:
			ret = sys_ipc_try_send((envid_t)a1, a2, (void*)a3, (int)a4);
			break;
		/*stone's solution for lab5*/
		case SYS_env_set_trapframe:
			ret = sys_env_set_trapframe((envid_t)a1, (struct Trapframe*)a2);
			break;
		/*stone's solution for lab6-A*/
		case SYS_time_msec:
			ret = sys_time_msec();
			break;
		case SYS_transmit:
			ret = sys_transmit((uint8_t*)a1, (uint32_t)a2);
			break;
		case SYS_receive:
			ret = sys_receive((uint8_t*)a1, (uint32_t*)a2);
			break;
		default:
			break;
	}
	return ret;
	//panic("syscall not implemented");
}


