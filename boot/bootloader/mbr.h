#ifndef __GT_MBR__
#define __GT_MBR__

#include "boot/bootloader/disk.h"

typedef struct {
    DISK* disk;
    dword partitionOffset;
    dword partitionSize;
} Partition;

void MBRCheckPartition(Partition* part, DISK* disk, void* partitionEntry);
bool PartitionReadSector(Partition* part, dword lba, byte sectors, void* lowDataBuf);

#endif