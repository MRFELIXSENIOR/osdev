#ifndef __HVIDEO__
#define __HVIDEO__

#include "libc/memory.h"
#include "libc/stdint.h"
#include "libc/string.h"
#include "colors.h"

void ClearScreen();
void HSCR_PUTS(char *message, int col, int row, byte color);
void HSCR_PRINT(char *message);
void HSCR_PRINTWITHCOL(char *message, byte color);

int HSCR_GETCURSOR_POS();
void HSCR_SETCURSOR_POS(int pos);

int HSCR_GETPOSITION(int col, int row);
int HSCR_GETROW(int pos);
int HSCR_GETCOL(int pos);
void HSCR_PUTBACKSPACE();

/*
void HscrPutPixel(int x, int y, byte color);
byte HscrGetColorFromRGB(byte r, byte g, byte b);
*/

#endif
