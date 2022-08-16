#ifndef __HVIDEO__
#define __HVIDEO__

#include "../libc/memory.h"
#include "../libc/stdint.h"
#include "../libc/string.h"
#include "colors.h"

//#define VID_ADDR 0xb8000
#define VGA_ADDR 0xA0000

#define VGA_WIDTH 640
#define VGA_HEIGHT 480

/*
#define PORT_VIDCTRL 0x3d4
#define PORT_VIDDATA 0x3d5

void HSCREEN_CLEAR();
void HSCR_PUTS(char *message, int col, int row, byte color);
void HSCR_PRINT(char *message);
void HSCR_PRINTWITHCOL(char *message, byte color);

int HSCR_GETCURSOR_POS();
void HSCR_SETCURSOR_POS(int pos);

int HSCR_PUTCHAR(char c, int col, int row, byte color);

int HSCR_GETPOSITION(int col, int row);
int HSCR_GETROW(int pos);
int HSCR_GETCOL(int pos);
void HSCR_PUTBACKSPACE();
*/

void HscrPutPixel(int x, int y, byte color);
byte HscrGetColorFromRGB(byte r, byte g, byte b);

#endif
