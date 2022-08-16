#include "../cpu/isr.h"
#include "../driver/keyboard.h"
#include "../driver/video.h"
#include "../libc/stdio.h"

void kstart() {
    // HISR_SETUP();
    // HIRQ_INSTALL();
    for (int i = 0; i < 25; i++) {
        for (int j = 0; j < 80; j++) {
            HscrPutPixel(j, i, VGA_COLOR_WHITE);
        }
    }
}
