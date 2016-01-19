#include <kern/e1000.h>
// LAB 6: Your driver code here
/*stone's solution for lab6-A*/
#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/error.h>
#include <kern/pmap.h>
static void
e1000_mem_init(void)
{
	int i;
	// Initialize the packet buffers
	memset(tx_queue, 0x00, sizeof(struct e1000_tx_desc) * E1000_NTXDESC);
	memset(tx_pkt_buf, 0x00, sizeof(struct tx_pkt) * E1000_NTXDESC);
	// Give each descriptor an address, and mark them writable
	for (i = 0; i < E1000_NTXDESC; i++)
	{
		tx_queue[i].addr = PADDR(tx_pkt_buf[i].pkt);
		tx_queue[i].status |= E1000_TDESC_STATUS_DD;
	}

	memset(rx_queue, 0x00, sizeof(struct e1000_rx_desc) * E1000_NRXDESC);
	memset(rx_pkt_buf, 0x00, sizeof(struct rx_pkt) * E1000_NRXDESC);
	for (i = 0; i < E1000_NRXDESC; i++)
	{
		rx_queue[i].addr = PADDR(rx_pkt_buf[i].pkt);
	}
}

int
e1000_attach(struct pci_func *pcif){
	/*stone's solution for lab6-A PCI attach*/
	pci_func_enable(pcif);

	e1000_mem_init();

	// Sanity check
	static_assert(sizeof(struct e1000_tx_desc) == 16 && sizeof(struct e1000_rx_desc) == 16);
	/*stone's solution for lab6-A MMIO mapping*/
	boot_map_region(kern_pgdir, E1000_ADDR, pcif->reg_size[0], pcif->reg_base[0], PTE_PCD | PTE_PWT | PTE_W);
	e1000 = (uint32_t*)E1000_ADDR;
	//here output "testing:80080783"
	//cprintf("testing: %08x\n",e1000[E1000_STATUS]);	

	e1000[E1000_TDBAL] = PADDR(tx_queue);
	e1000[E1000_TDBAH] = 0;
	e1000[E1000_TDLEN] = sizeof(struct e1000_tx_desc) * E1000_NTXDESC;
	e1000[E1000_TDH]   = 0;
	e1000[E1000_TDT]   = 0;

	// Ensure proper alignment of values
	assert(e1000[E1000_TDBAL] % 0x10 == 0 && e1000[E1000_TDLEN] % 0x80 == 0);

	// Setup TCTL register
	e1000[E1000_TCTL] |= E1000_TCTL_EN;
	e1000[E1000_TCTL] |= E1000_TCTL_PSP;
	e1000[E1000_TCTL] |= E1000_TCTL_CT;
	e1000[E1000_TCTL] |= E1000_TCTL_COLD;

	// Setup TIPG register
	e1000[E1000_TIPG]  = 0;
	e1000[E1000_TIPG] |= E1000_TIPG_IPGT;
	e1000[E1000_TIPG] |= E1000_TIPG_IPGR1;
	e1000[E1000_TIPG] |= E1000_TIPG_IPGR2;

	e1000[E1000_FILTER_RAL] = 0x12005452;
	e1000[E1000_FILTER_RAH] = 0x00005634;
	e1000[E1000_FILTER_RAH] |= E1000_FILTER_RAH_VALID;

	// Setup RX Registers
	e1000[E1000_RDBAL] = PADDR(rx_queue);
	e1000[E1000_RDBAH] = 0;
	e1000[E1000_RDLEN] = sizeof(struct e1000_rx_desc) * E1000_NRXDESC;
	e1000[E1000_RDH]   = 1;
	e1000[E1000_RDT]   = 0; // Gets reset later

	e1000[E1000_RCTL] = E1000_RCTL_EN;
	e1000[E1000_RCTL] &= ~E1000_RCTL_LPE;
	e1000[E1000_RCTL] &= ~E1000_RCTL_LBM;
	e1000[E1000_RCTL] &= ~E1000_RCTL_RDMTS;
	e1000[E1000_RCTL] &= ~E1000_RCTL_MO;
	e1000[E1000_RCTL] |= E1000_RCTL_BAM;
	e1000[E1000_RCTL] &= ~E1000_RCTL_BSIZE;
	e1000[E1000_RCTL] |= E1000_RCTL_SECRC;

	return 0;
}
/*stone's solution for lab6-A*/
int 
e1000_transmit(uint8_t *data, uint32_t len){
	if (len > E1000_TX_PKT_LEN){
		return -E_LONG_PKT;
	}

	uint32_t tdt = e1000[E1000_TDT];
	if ((tx_queue[tdt].status & E1000_TDESC_STATUS_DD) == 0){
		return -E_FULL_TX;
	}

	memmove(tx_pkt_buf[tdt].pkt, data, len);
	tx_queue[tdt].length = len;
	tx_queue[tdt].status &= ~E1000_TDESC_STATUS_DD;
	tx_queue[tdt].cmd |= E1000_TDESC_CMD_RS;
	tx_queue[tdt].cmd |= E1000_TDESC_CMD_EOP;

	e1000[E1000_TDT] = (tdt+1)%E1000_NTXDESC;
	return 0;
}

/*stone's solution for lab6-B*/
int
e1000_receive(uint8_t *data){
	uint32_t rdt = (e1000[E1000_RDT] + 1) % E1000_NRXDESC;
	if ((rx_queue[rdt].status & E1000_RDESC_STATUS_DD) == 0)
		return -E_EMPTY_RX;
	if ((rx_queue[rdt].status & E1000_RDESC_STATUS_EOP) == 0)
		return -E_TOUGH_EOP;
	uint32_t len = rx_queue[rdt].length;
	memmove(data, rx_pkt_buf[rdt].pkt, len);
	rx_queue[rdt].status &= ~E1000_RDESC_STATUS_DD;
	rx_queue[rdt].status &= ~E1000_RDESC_STATUS_EOP;
	e1000[E1000_RDT] = rdt;
	return len;
}
