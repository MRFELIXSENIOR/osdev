#ifndef __GTOS_BIOS_DEF_H
#define __GTOS_BIOS_DEF_H

#include "libc/stdint.h"
#define __cdecl __attribute__((cdecl))

bool __cdecl BIOS_GETDISK_PARAM(byte driveNumber, 
                                byte* driveTypeOut, 
                                word* cylinderOut, 
                                word* sectorsOut, 
                                word* headsOut);

bool __cdecl BIOS_DISK_RESET(byte driveNumber);

bool __cdecl BIOS_DISK_READ(byte driveNumber,
                            word cylinder,
                            word sectors,
                            word head,
                            byte count,
                            void* buffer);

void __cdecl BIOS_PUTC(byte c);
void __cdecl BIOS_PUTS(byte* str);

#define puts(s) BIOS_PUTS(s)
#define putc(c) BIOS_PUTC(c)

#endif