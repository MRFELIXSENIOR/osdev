#include "idt.h"

static idt_gate_t idt[IDT_ENTRIES];
static idt_reg_t idt_register;

void HIDT_SETGATE(int n, unsigned int Handler) {
    idt[n].low_offset = low16(Handler);
    idt[n].ksegment_sel = KCS;
    idt[n].intByte = 0;
    idt[n].flags = 0x8E;
    idt[n].high_offset = high16(Handler);
}

void HIDT_SET() {
    idt_register.base = (unsigned int)&idt;
    idt_register.limit = IDT_ENTRIES * sizeof(idt_gate_t) - 1;
    __asm__ __volatile__("lidtl (%0)" : : "r"(&idt_register));
}
