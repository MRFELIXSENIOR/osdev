#include "timer.h"
#include "../driver/ports.h"
#include "isr.h"

static unsigned int tick = 0;

static void TCB(registers R) { tick++; }

void HTIMER_START(unsigned int freq) {
    HREGISTER_INTHANDLER(IRQ0, TCB);
    unsigned int div = 11931802 / freq;
    unsigned char low = (unsigned char)(div & 0xff);
    unsigned char high = (unsigned char)((div >> 8) & 0xff);

    HPORT_SENDBYTE(0x43, 0x36);
    HPORT_SENDBYTE(0x40, low);
    HPORT_SENDBYTE(0x40, high);
}
