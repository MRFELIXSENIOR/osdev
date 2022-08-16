#include "isr.h"
#include "../driver/keyboard.h"
#include "../driver/ports.h"
#include "../libc/stdio.h"
#include "../libc/string.h"
#include "idt.h"
#include "timer.h"

isr_t interrupt_handlers[256];

void HISR_SETUP() {
    HIDT_SETGATE(0, (unsigned int)isr0);
    HIDT_SETGATE(1, (unsigned int)isr1);
    HIDT_SETGATE(2, (unsigned int)isr2);
    HIDT_SETGATE(3, (unsigned int)isr3);
    HIDT_SETGATE(4, (unsigned int)isr4);
    HIDT_SETGATE(5, (unsigned int)isr5);
    HIDT_SETGATE(6, (unsigned int)isr6);
    HIDT_SETGATE(7, (unsigned int)isr7);
    HIDT_SETGATE(8, (unsigned int)isr8);
    HIDT_SETGATE(9, (unsigned int)isr9);
    HIDT_SETGATE(10, (unsigned int)isr10);
    HIDT_SETGATE(11, (unsigned int)isr11);
    HIDT_SETGATE(12, (unsigned int)isr12);
    HIDT_SETGATE(13, (unsigned int)isr13);
    HIDT_SETGATE(14, (unsigned int)isr14);
    HIDT_SETGATE(15, (unsigned int)isr15);
    HIDT_SETGATE(16, (unsigned int)isr16);
    HIDT_SETGATE(17, (unsigned int)isr17);
    HIDT_SETGATE(18, (unsigned int)isr18);
    HIDT_SETGATE(19, (unsigned int)isr19);
    HIDT_SETGATE(20, (unsigned int)isr20);
    HIDT_SETGATE(21, (unsigned int)isr21);
    HIDT_SETGATE(22, (unsigned int)isr22);
    HIDT_SETGATE(23, (unsigned int)isr23);
    HIDT_SETGATE(24, (unsigned int)isr24);
    HIDT_SETGATE(25, (unsigned int)isr25);
    HIDT_SETGATE(26, (unsigned int)isr26);
    HIDT_SETGATE(27, (unsigned int)isr27);
    HIDT_SETGATE(28, (unsigned int)isr28);
    HIDT_SETGATE(29, (unsigned int)isr29);
    HIDT_SETGATE(30, (unsigned int)isr30);
    HIDT_SETGATE(31, (unsigned int)isr31);

    HPORT_SENDBYTE(0x20, 0x11);
    HPORT_SENDBYTE(0xA0, 0x11);
    HPORT_SENDBYTE(0x21, 0x20);
    HPORT_SENDBYTE(0xA1, 0x28);
    HPORT_SENDBYTE(0x21, 0x04);
    HPORT_SENDBYTE(0xA1, 0x02);
    HPORT_SENDBYTE(0x21, 0x01);
    HPORT_SENDBYTE(0xA1, 0x01);
    HPORT_SENDBYTE(0x21, 0x0);
    HPORT_SENDBYTE(0xA1, 0x0);

    // Install the IRQs
    HIDT_SETGATE(32, (unsigned int)irq0);
    HIDT_SETGATE(33, (unsigned int)irq1);
    HIDT_SETGATE(34, (unsigned int)irq2);
    HIDT_SETGATE(35, (unsigned int)irq3);
    HIDT_SETGATE(36, (unsigned int)irq4);
    HIDT_SETGATE(37, (unsigned int)irq5);
    HIDT_SETGATE(38, (unsigned int)irq6);
    HIDT_SETGATE(39, (unsigned int)irq7);
    HIDT_SETGATE(40, (unsigned int)irq8);
    HIDT_SETGATE(41, (unsigned int)irq9);
    HIDT_SETGATE(42, (unsigned int)irq10);
    HIDT_SETGATE(43, (unsigned int)irq11);
    HIDT_SETGATE(44, (unsigned int)irq12);
    HIDT_SETGATE(45, (unsigned int)irq13);
    HIDT_SETGATE(46, (unsigned int)irq14);
    HIDT_SETGATE(47, (unsigned int)irq15);

    HIDT_SET(); // Load with ASM
}

char *exception_messages[] = {"Division By Zero",
                              "Debug",
                              "Non Maskable Interrupt",
                              "Breakpoint",
                              "Into Detected Overflow",
                              "Out of Bounds",
                              "Invalid Opcode",
                              "No Coprocessor",

                              "Double Fault",
                              "Coprocessor Segment Overrun",
                              "Bad TSS",
                              "Segment Not Present",
                              "Stack Fault",
                              "General Protection Fault",
                              "Page Fault",
                              "Unknown Interrupt",

                              "Coprocessor Fault",
                              "Alignment Check",
                              "Machine Check",
                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved",

                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved",
                              "Reserved"};

void HISR_HANDLER(registers R) {
    // puts("Interupt: ");
    char s[3];
    itoa(R.intN, s);
    // println(s);
    // println(exception_messages[R.intN]);
}

void HREGISTER_INTHANDLER(unsigned char n, isr_t handler) {
    interrupt_handlers[n] = handler;
}

void HIRQ_HANDLER(registers R) {
    if (R.intN >= 40)
        HPORT_SENDBYTE(0xA0, 0x20);

    HPORT_SENDBYTE(0x20, 0x20);

    if (interrupt_handlers[R.intN] != 0) {
        isr_t handler = interrupt_handlers[R.intN];
        handler(R);
    }
}

void HIRQ_INSTALL() {
    asm volatile("sti");
    HTIMER_START(50);
    HKEYBOARD_INIT();
}
