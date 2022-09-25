#include "stdio.h"
#include "../driver/video.h"
#include "../boot/bootloader/bios.h"

void puts(byte* str) {
    #ifdef __GTOS_KERNEL_BIOS_MODE__
        while (*str) {
            BIOS_PUTC(*str);
            str++;
        }
        BIOS_PUTC('\r');
    #elif __GTOS_KERNEL_PROTECTED_MODE__
        while (*str) {
            GPUTC(*str);
            str++;
        }
    #endif
}