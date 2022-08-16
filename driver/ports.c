#include "ports.h"

unsigned char HPORT_GETBYTE(unsigned short port) {
    unsigned char result;

    __asm__("in %%dx, %%al" : "=a"(result) : "d"(port));
    return result;
}

void HPORT_SENDBYTE(unsigned short port, unsigned char data) {
    __asm__("out %%al, %%dx" : : "a"(data), "d"(port));
}

unsigned short HPORT_GETWORD(unsigned short port) {
    unsigned short result;
    __asm__("in %%dx, %%ax" : "=a"(result) : "d"(port));
    return result;
}

void HPORT_SENDWORD(unsigned short port, unsigned short data) {
    __asm__("out %%ax, %%dx" : : "a"(data), "d"(port));
}
