#ifndef __HSTDIO_LIBC__
#define __HSTDIO_LIBC__

#include "sys/driver/video.h"

#define puts(s) HSCR_PRINT(s)
#define putc(c) HSCR_PRINT(c)

#endif