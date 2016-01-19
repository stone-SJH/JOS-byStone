#include <inc/lib.h>

int k = 0;
void
umain(int argc, char **argv)
{
	int c = sfork();
	if (c != 0){
		cprintf("parent: %d\n", k);
		k = 255;
	}
	else {
		cprintf("child: %d\n", k);
	} 
}
