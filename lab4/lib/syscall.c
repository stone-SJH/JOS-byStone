// System call stubs.

#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
		 "pushl %%edx\n\t"
	         "pushl %%ebx\n\t"
		 "pushl %%esp\n\t"
		 "pushl %%ebp\n\t"
		 "pushl %%esi\n\t"
		 "pushl %%edi\n\t"
				 
                 //Lab 3: Your code here
		 /*stone's solution for lab3-b*/
		 //TERRIBLE OFFSET!
		 "movl %%esp,%%ebp\n\t"
                 "leal 1f, %%esi\n\t"
                 "sysenter\n\t"
                 "1:\n\t"
		 
                 "popl %%edi\n\t"
                 "popl %%esi\n\t"
                 "popl %%ebp\n\t"
                 "popl %%esp\n\t"
                 "popl %%ebx\n\t"
                 "popl %%edx\n\t"
                 "popl %%ecx\n\t"
                 
                 : "=a" (ret)
                 : "a" (num),
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	/*stone's solution for lab4-A*/
	/*ATTENTION!*/
	/*stone: i got "PAGE FAULT" using the default parameter-passing function. and i have no idea about why this happened.
		i have no way but find other's help by coping the code below using another method of parameter-passing to sys_page_map() function.
		in my eyes these two method is the same but has different result.
		sorry for no more explaination.*/
	uint32_t pp_helper[5];
	pp_helper[0] = (uint32_t) srcenv;
	pp_helper[1] = (uint32_t) srcva;
	pp_helper[2] = (uint32_t) dstenv;
	pp_helper[3] = (uint32_t) dstva;
	pp_helper[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)pp_helper, 0, 0, 0, 0);
	//return syscall(SYS_page_map, 1, (uint32_t) srcenv, (uint32_t) srcva, (uint32_t) dstenv, (uint32_t) dstva, (uint32_t) perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

