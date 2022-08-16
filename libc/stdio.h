#ifndef __HSTDIO_LIBC__
#define __HSTDIO_LIBC__

#include "../driver/video.h"

#define println(string)                                                        \
    HSCR_PRINT(string);                                                        \
    HSCR_PRINT("\n");

#define puts(string) HSCR_PRINT(string)

#endif
