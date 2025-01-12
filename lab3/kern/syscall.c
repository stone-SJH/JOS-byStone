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
void
router(struct Trapframe *tf){
	curenv->env_tf = *tf;
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
}
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
		default:
			break;
	}
	return ret;
	//panic("syscall not implemented");
}


