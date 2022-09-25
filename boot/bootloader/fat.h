#ifndef __BOOT_FAT_DRIVER__
#define __BOOT_FAT_DRIVER__

#include "../../libc/stdint.h"
#include "disk.h"

typedef struct {
    byte Name[11];
    byte Attributes;
    byte _Reserved;
    byte CreatedTimeTenths;
    word CreatedTime;
    word CreatedDate;
    word AccessedDate;
    word FirstClusterHigh;
    word ModifiedTime;
    word ModifiedDate;
    word FirstClusterLow;
    dword Size;
} __attribute__((packed)) FAT_DirectoryEntry;

typedef struct {
    int Handle;
    bool IsDir;
    dword Position;
    dword Size;
} FAT_File;

typedef enum {
    FAT_ATTRIBUTE_READ_ONLY = 0x01,
    FAT_ATTRIBUTE_HIDDEN    = 0x02,
    FAT_ATTRIBUTE_SYSTEM    = 0x04,
    FAT_ATTRIBUTE_VOLUME_ID = 0x08,
    FAT_ATTRIBUTE_DIRECTORY = 0x10,
    FAT_ATTRIBUTE_ARCHIVE   = 0x20,
    FAT_ATTRIBUTE_LFN       = FAT_ATTRIBUTE_READ_ONLY | FAT_ATTRIBUTE_HIDDEN |
                              FAT_ATTRIBUTE_SYSTEM | FAT_ATTRIBUTE_VOLUME_ID
} FAT_Attribute;

bool FAT_Init(DISK* disk);
FAT_File* FAT_Open(DISK* disk, char* path);
void FAT_Close(FAT_File* file);
dword FAT_Read(DISK* disk, FAT_File* file, dword byteCount, void* bufferOut);
bool FAT_ReadEntry(DISK* disk, FAT_File* file, FAT_DirectoryEntry* entry);

#endif