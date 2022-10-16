#ifndef __NFOS__BIOS_DISK__
#define __NFOS__BIOS_DISK__

#include "../../libc/stdint.h"

typedef struct {
    byte id;
    word cyls;
    word sectors;
    word heads;
    bool Initialized;
} DISK;

bool DISK_Init(DISK* disk, byte driveNumber);
bool DISK_ReadSectors(DISK* disk, dword lba, byte sectors, byte* dataOut);

void DISK_lba2chs(DISK* disk, dword lba, word* cylOut, word* secOut, word* headOut);

#endif