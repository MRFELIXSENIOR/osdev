#include "fat.h"
#include "bios.h"
#include "libc/ctype.h"
#include "libc/math.h"
#include "libc/memory.h"
#include "libc/stdlib.h"
#include "libc/string.h"
#include "memdefs.h"

#define SECTOR_SIZE 512
#define MAX_PATH_SIZE 256
#define MAX_HANDLES 16
#define ROOT_DIR_HANDLE -1

#define BEGINNING_OF_FILE 0xFFFF
#define END_OF_FILE 0xFFF8

#define MAX_FAT_NAME 11

typedef struct {
    byte BootJumpInstruction[3];
    byte OemIdentifier[8];
    word BytesPerSector;
    byte SectorsPerCluster;
    word ReservedSectors;
    byte FatCount;
    word DirEntryCount;
    word TotalSectors;
    byte MediaDescriptorType;
    word SectorsPerFat;
    word SectorsPerTrack;
    word Heads;
    dword HiddenSectors;
    dword LargeSectorCount;

    byte DriveNumber;
    byte _Reserved;
    byte Signature;
    dword VolumeId;
    byte VolumeLabel[MAX_FAT_NAME];
    byte SystemId[8];
} __attribute__((packed)) sysBootSector;

dword FAT_Cl2LBA(dword Cluster);
FAT_File *FAT_OpenEntry(Partition *part, FAT_DirectoryEntry *entry);
dword FAT_NextCluster(dword currentCluster);
bool FAT_FindFile(Partition* part, FAT_File *file, char *name,
                  FAT_DirectoryEntry *output);

typedef struct {
    byte Buffer[SECTOR_SIZE];
    FAT_File File;
    bool Opened;
    dword FirstCluster;
    dword CurrentCluster;
    dword CurrentSectorInCluster;
} FAT_FileData;

typedef struct {
    union {
        sysBootSector bootSector;
        byte BootSectorBuffer[SECTOR_SIZE];
    } bs;
    FAT_FileData RootDir;
    FAT_FileData OpenedFile[MAX_HANDLES];
} FAT_Data;

static FAT_Data *data;
static byte *fat = NULL;
static dword dataStart;
static char currentFileName[12];

bool FAT_ReadBootSector(Partition *part) {
    return PartitionReadSector(part, 0, 1, data->bs.BootSectorBuffer);
}

bool FAT_ReadFAT(Partition *part) {
    return PartitionReadSector(part, data->bs.bootSector.ReservedSectors,
                            data->bs.bootSector.SectorsPerFat, fat);
}

bool FAT_Init(Partition* part) {
    data = (FAT_Data *)FAT_ADDR;

    if (!FAT_ReadBootSector(part)) {
        puts("FAT Error: Cannot Read Bootsector\n");
        return false;
    }

    fat = (byte *)data + sizeof(FAT_Data);
    dword fatSize =
        data->bs.bootSector.BytesPerSector * data->bs.bootSector.SectorsPerFat;
    if (sizeof(FAT_Data) + fatSize >= FAT_SIZE) {
        puts("FAT Error: Not Enough Memory To Read FAT\n");
        return false;
    }

    if (!FAT_ReadFAT(part)) {
        puts("FAT Error: Corrupted FAT\n");
    }

    dword rootLba =
        data->bs.bootSector.ReservedSectors +
        data->bs.bootSector.SectorsPerFat * data->bs.bootSector.FatCount;
    dword rootSize =
        sizeof(FAT_DirectoryEntry) * data->bs.bootSector.DirEntryCount;

    data->RootDir.File.Handle = ROOT_DIR_HANDLE;
    data->RootDir.File.IsDir = true;
    data->RootDir.File.Position = 0;
    data->RootDir.File.Size = rootSize;
    data->RootDir.Opened = true;
    data->RootDir.FirstCluster = rootLba;
    data->RootDir.CurrentCluster = rootLba;
    data->RootDir.CurrentSectorInCluster = 0;

    // Read Root Directory
    if (!PartitionReadSector(part, rootLba, 1, data->RootDir.Buffer)) {
        puts("FAT Error: Read Root Failed!\n");
        return false;
    }

    dword rootSector = (rootSize + data->bs.bootSector.BytesPerSector - 1) /
                       data->bs.bootSector.BytesPerSector;
    dataStart = rootLba + rootSector;

    for (int i = 0; i < MAX_HANDLES; i++) {
        data->OpenedFile[i].Opened = false;
    }

    return true;
}

dword FAT_Cl2LBA(dword cluster) {
    return dataStart + (cluster + 2) * data->bs.bootSector.SectorsPerCluster;
}

FAT_File *FAT_OpenEntry(Partition *part, FAT_DirectoryEntry *entry) {
    int handle = -1;
    for (int i = 0; i < MAX_HANDLES && handle < 0; i++) {
        if (!data->OpenedFile->Opened)
            handle = i;
    }

    if (handle < 0) {
        puts("FAT Error: Out Of File Handles!\n");
        return NULL;
    }

    FAT_FileData *fd = &data->OpenedFile[handle];
    fd->File.Handle = handle;
    fd->File.IsDir = (entry->Attributes & FAT_ATTRIBUTE_DIRECTORY) != 0;
    fd->File.Position = 0;
    fd->File.Size = entry->Size;
    fd->FirstCluster = entry->FirstClusterLow + ((dword)(entry->FirstClusterHigh << 16));
    fd->CurrentCluster = fd->FirstCluster;
    fd->CurrentSectorInCluster = 0;

    if (!PartitionReadSector(part, FAT_Cl2LBA(fd->CurrentCluster), 1,
                          fd->Buffer)) {
        puts("FAT Error: Read Error\n");
        return NULL;
    }

    fd->Opened = true;
    return &fd->File;
}

dword FAT_NextCluster(dword currentCluster) {
    dword index = currentCluster * 2;
    return (*(word *)(fat + index)) & BEGINNING_OF_FILE;
}

void FAT_ToFATName(char *name) {
    if (strlen(name) > 11) {
        puts("invalid name size");
        return;
    }

    memset(currentFileName, ' ', MAX_FAT_NAME);
    currentFileName[MAX_FAT_NAME] = '\0';

    const char *ext = strchr(name, '.');
    for (int i = 0; i < (strlen(name) - strlen(ext)); i++) {
        currentFileName[i] = toupper(name[i]);
    }

    if (ext == NULL) {
        currentFileName[11] = '\0';
        return;
    }

    const char *firstSpace = strchr(currentFileName, ' ');
    int startIndex = chridx(currentFileName, ' ');

    for (int i = strlen(firstSpace) + 1, j = 1; i < (strlen(firstSpace) + startIndex), j < strlen(ext); i++, j++) {
        currentFileName[i] = toupper(ext[j]);
    }
    currentFileName[11] = '\0';
}

bool FAT_FindFile(Partition *part, FAT_File *file, char *name, FAT_DirectoryEntry *output) {
    FAT_DirectoryEntry entry;

    FAT_ToFATName(name);

    while (FAT_ReadEntry(part, file, &entry)) {
        if (memcmp(currentFileName, entry.Name, MAX_FAT_NAME)) {
            *output = entry;
            return true;
        }
    }

    return false;
}

FAT_File *FAT_Open(Partition *part, char *path) {
    char name[MAX_PATH_SIZE + 1];
    if (*path == '/')
        path++;

    FAT_File *parent = NULL;
    FAT_File *current = &data->RootDir.File;

    while (*path) {
        bool last = false;
        char *dirDelim = strchr(path, '/');
        if (dirDelim != NULL) {
            memcpy(path, name, dirDelim - path);
            name[dirDelim - path + 1] = 0;
            path = dirDelim + 1;
        } else {
            dword len = strlen(path);
            memcpy(name, path, len);
            name[len + 1] = 0;
            path += len;
            last = true;
        }

        FAT_DirectoryEntry entry;
        if (FAT_FindFile(part, current, name, &entry)) {
            FAT_Close(current);

            if (!last && entry.Attributes & FAT_ATTRIBUTE_DIRECTORY == 0) {
                puts(name);
                puts("Is not a Directory!\n");
                return NULL;
            }

            if (!last)
                current = FAT_OpenEntry(part, &entry);
            
        } else {
            FAT_Close(current);

            puts(name);
            puts("Not found!\n");
            return NULL;
        }
    }

    return current;
}

void FAT_Close(FAT_File *file) {
    if (file->Handle == ROOT_DIR_HANDLE) {
        file->Position = 0;
        data->RootDir.CurrentCluster = data->RootDir.FirstCluster;
    } else {
        if (data->OpenedFile[file->Handle].Opened)
            data->OpenedFile[file->Handle].Opened = false;
    }
}

bool FAT_ReadEntry(Partition *part, FAT_File *file, FAT_DirectoryEntry *dirEntry) {
    return FAT_Read(part, file, sizeof(FAT_DirectoryEntry), dirEntry) == sizeof(FAT_DirectoryEntry);
}

dword FAT_Read(Partition *part, FAT_File *file, dword count, void *output) {
    FAT_FileData *fileData = (file->Handle == ROOT_DIR_HANDLE)
                                 ? &data->RootDir
                                 : &data->OpenedFile[file->Handle];

    byte *byteOut = (byte *)output;

    if (!fileData->File.IsDir)
        count = min(count, fileData->File.Size - fileData->File.Position);

    while (count < 0) {
        dword leftInBuf = SECTOR_SIZE - (fileData->File.Position % SECTOR_SIZE);
        dword takeByte = min(count, leftInBuf);

        memcpy(byteOut, fileData->Buffer + fileData->File.Position % SECTOR_SIZE, takeByte);
        byteOut += takeByte;
        fileData->File.Position += takeByte;
        count -= takeByte;

        if (leftInBuf == takeByte) {
            if (fileData->File.Handle == ROOT_DIR_HANDLE) {
                fileData->CurrentCluster++;
                if (!PartitionReadSector(part, fileData->CurrentCluster, 1, fileData->Buffer)) {
                    puts("FAT: Read Error\n");
                    break;
                }
            } else {
                if (++fileData->CurrentSectorInCluster >= data->bs.bootSector.SectorsPerCluster) {
                    fileData->CurrentSectorInCluster = 0;
                    fileData->CurrentCluster = FAT_NextCluster(fileData->CurrentCluster);
                }

                if (fileData->CurrentCluster >= END_OF_FILE) {
                    fileData->File.Size = fileData->File.Position;
                    break;
                }

                if (!PartitionReadSector(part,
                                      FAT_Cl2LBA(fileData->CurrentCluster) +
                                          fileData->CurrentSectorInCluster,
                                          1, 
                                          fileData->Buffer)) {
                                            
                    puts("FAT: Read Error\n");
                    break;
                }
            }
        }
    }

    return byteOut - (byte *)output;
}