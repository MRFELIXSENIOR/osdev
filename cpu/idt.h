#ifndef __HIDT__
#define __HIDT__

#define KCS 0x08
#define low16(addr) (unsigned short)((addr)&0xffff)

#define high16(addr) (unsigned short)(((addr) >> 16) & 0xffff)

typedef struct {
    unsigned short low_offset; /* Lower 16 bits of handler function address */
    unsigned short ksegment_sel;
    unsigned char intByte;
    /* First byte
     * Bit 7: "Interrupt is present"
     * Bits 6-5: Privilege level of caller (0=kernel..3=user)
     * Bit 4: Set to 0 for interrupt gates
     * Bits 3-0: bits 1110 = decimal 14 = "32 bit interrupt gate" */
    unsigned char flags;
    unsigned short high_offset; /* Higher 16 bits of handler function address */
} __attribute__((packed)) idt_gate_t;

typedef struct {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed)) idt_reg_t;

#define IDT_ENTRIES 256

void HIDT_SETGATE(int n, unsigned int Handler);
void HIDT_SET();

#endif
