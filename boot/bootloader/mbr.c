#include "mbr.h"
#include "libc/memory.h"

#define HARD_DRV 0x80

typedef struct {
    byte driveAttribute;
    byte chsStart[3];
    byte partitionType;
    byte lastPartitionSector[3];
    dword partitionLBA;
    dword size;
} __attribute__((packed)) MBRPartitionEntry;

void MBRCheckPartition(Partition* part, DISK* disk, void* partitionEntry) {
    part->disk = disk;
    if (disk->id != HARD_DRV) {
        part->partitionOffset = 0;
        part->partitionSize = (dword)(disk->cyls * disk->heads * disk->sectors);
    } else {
        MBRPartitionEntry* entry = (MBRPartitionEntry*)toLinearMemAddr(partitionEntry);
        part->partitionOffset = entry->partitionLBA;
        part->partitionSize = entry->size;
    }
}

bool PartitionReadSector(Partition* part, dword lba, byte sector, void* lowDataBuf) {
    return DISK_ReadSectors(part->disk, lba + part->partitionOffset, sector, lowDataBuf);
}