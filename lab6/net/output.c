#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	/*stone's solution for lab6-A*/
	while (1){
		if (sys_ipc_recv(&nsipcbuf) < 0)
			break;
		if ((thisenv->env_ipc_from != ns_envid) || (thisenv->env_ipc_value != NSREQ_OUTPUT))
			continue;
		while (sys_transmit((uint8_t *)nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len));
	}
}
