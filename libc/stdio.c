#include "stdio.h"
#include "../driver/video.h"
#include "../boot/bootloader/bios.h"

void putc(char c) {
    #ifdef __GTOS_BIOS_MODE__
        BIOS_PUTC(c);
    #elif __GTOS_PROT_MODE__
        GPUTC(c);
    #endif
}

void puts(char* str) {
    while (*str) {
        putc(*str);
        str++;
    }
}