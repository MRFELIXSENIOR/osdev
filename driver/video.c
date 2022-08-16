#include "video.h"
#include "../libc/stdint.h"
#include "ports.h"

/*
void HSCR_PUTS(char *message, int col, int row, byte color) {
    int position = 0;
    if (col >= 0 && row >= 0) {
        position = HSCR_GETPOSITION(col, row);
    } else {
        position = HSCR_GETCURSOR_POS();
        row = HSCR_GETROW(position);
        col = HSCR_GETCOL(position);
    }

    int i = 0;
    while (i != strlen(message)) {
        position = HSCR_PUTCHAR(message[i], col, row, color);

        row = HSCR_GETROW(position);
        col = HSCR_GETCOL(position);
        i++;
    }
}

void HSCR_PRINT(char *message) { HSCR_PUTS(message, -1, -1, VGA_COLOR_WHITE); }
void HSCR_PRINTWITHCOL(char *message, byte color) {
    HSCR_PUTS(message, -1, -1, color);
}

int HSCR_PUTCHAR(char c, int col, int row, byte color) {
    byte *vidmem = (byte *)VID_ADDR;
    if (col >= MAX_COL || row >= MAX_ROW) {
        vidmem[2 * (MAX_COL) * (MAX_ROW)-2] = 'E';
        vidmem[2 * (MAX_COL) * (MAX_ROW)-1] =
            H_GETCOLOR(VGA_COLOR_RED, VGA_COLOR_WHITE);

        return HSCR_GETPOSITION(col, row);
    }

    int pos = 0;
    if (col >= 0 && row >= 0) {
        pos = HSCR_GETPOSITION(col, row);
    } else {
        pos = HSCR_GETCURSOR_POS();
    }

    if (c == '\n') {
        row = HSCR_GETROW(pos);
        pos = HSCR_GETPOSITION(0, row + 1);
    } else {
        vidmem[pos] = c;
        vidmem[pos + 1] = color;
        pos += 2;
    }

    if (pos >= MAX_ROW * MAX_COL * 2) {
        for (int i = 1; i < MAX_ROW; i++) {
            memcpy((char *)HSCR_GETPOSITION(0, i) + VID_ADDR,
                   (char *)HSCR_GETPOSITION(0, i - 1) + VID_ADDR, MAX_COL * 2);
        }

        char *last = (char *)(HSCR_GETPOSITION(0, MAX_ROW - 1) + VID_ADDR);
        for (int i = 0; i < MAX_COL * 2; i++)
            last[i] = 0;

        pos -= 2 * MAX_COL;
    }

    HSCR_SETCURSOR_POS(pos);
    return pos;
}

void HSCR_PUTBACKSPACE() {
    if (HSCR_GETCURSOR_POS() == 0)
        return;
    int pos = HSCR_GETCURSOR_POS() - 2;
    int col = HSCR_GETCOL(pos);
    int row = HSCR_GETROW(pos);

    HSCR_PUTCHAR(' ', col, row, VGA_COLOR_WHITE);

    HSCR_SETCURSOR_POS(pos);
}

int HSCR_GETCURSOR_POS() {
    HPORT_SENDBYTE(PORT_VIDCTRL, 14);
    word offset = (word)HPORT_GETBYTE(PORT_VIDDATA) << 8;
    HPORT_SENDBYTE(PORT_VIDCTRL, 15);
    offset += HPORT_GETBYTE(PORT_VIDDATA);
    return offset * 2;
}

void HSCR_SETCURSOR_POS(int pos) {
    pos /= 2;
    HPORT_SENDBYTE(PORT_VIDCTRL, 14);
    HPORT_SENDBYTE(PORT_VIDDATA, (byte)(pos >> 8));
    HPORT_SENDBYTE(PORT_VIDCTRL, 15);
    HPORT_SENDBYTE(PORT_VIDDATA, (byte)(pos & 0xff));
}

void HSCREEN_CLEAR() {
    byte *vidmem = (byte *)VID_ADDR;
    int size = MAX_COL * MAX_ROW;

    for (int i = 0; i < size; i++) {
        vidmem[i * 2] = ' ';
        vidmem[i * 2 + 1] = VGA_COLOR_WHITE;
    }
    HSCR_SETCURSOR_POS(HSCR_GETPOSITION(0, 0));
}

int HSCR_GETPOSITION(int col, int row) { return 2 * (row * MAX_COL + col); }
int HSCR_GETROW(int pos) { return pos / (2 * MAX_COL); }
int HSCR_GETCOL(int pos) {
    return (pos - (HSCR_GETROW(pos) * 2 * MAX_COL)) / 2;
}
*/
void HscrPutPixel(int x, int y, byte color) {
    byte *pos = (byte *)VGA_ADDR + 320 * y + x;
    *pos = color;
}

byte HscrGetColorFromRGB(byte r, byte g, byte b) {
    return ((r << 16) + (g << 8) + b);
}
