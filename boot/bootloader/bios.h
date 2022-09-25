#ifndef __NFOS__BIOS__
#define __NFOS__BIOS__

#include "../../libc/stdint.h"

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

#endif