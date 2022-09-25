#include "disk.h"
#include "bios.h"

bool DISK_Init(DISK* disk, byte driveNumber) {
    byte driveType;
    word cyls, sectors, heads;

    if (!BIOS_GETDISK_PARAM(disk->id, &driveType, &cyls, &sectors, &heads)) {
        disk->Initialized = false;
        return false;
    }
    
    disk->id = driveNumber;
    disk->cyls = cyls;
    disk->sectors = sectors;
    disk->heads = heads;
    disk->Initialized = true;

    return true;
}

bool DISK_ReadSectors(DISK* disk, dword lba, byte sectors, byte* buffer) {
    if (!disk->Initialized)
        return false;
    word cyl, sector, head;

    DISK_lba2chs(disk, lba, &cyl, &sector, &head);
    for (int i = 0; i < 3; i++) {
        if (BIOS_DISK_READ(disk->id, cyl, sector, head, sectors, buffer)) {
            return true;
        }

        BIOS_DISK_RESET(disk->id);
    }

    return false;
}

void DISK_lba2chs(DISK* disk, dword lba, word* cylOut, word* secOut, word* headOut) {
    *secOut = lba % disk->sectors + 1;
    *cylOut = (lba / disk->sectors) / disk->heads;
    *headOut = (lba / disk->sectors) % disk->heads;
}