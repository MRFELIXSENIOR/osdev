#include "fat.h"
#include "../../libc/math.h"
#include "../../libc/memory.h"
#include "../../libc/stdlib.h"
#include "../../libc/string.h"
#include "../../libc/ctype.h"
#include "memdefs.h"

#define SECTOR_SIZE     512
#define MAX_PATH_SIZE   256
#define MAX_HANDLES     16
#define ROOT_DIR_HANDLE -1

#define START_OF_FILE   0x0FFF
#define END_OF_FILE     0x0FF8

#define MAX_FILE_NAME   11

dword FAT_Cl2LBA(dword Cluster);
FAT_File *FAT_OpenEntry(DISK *disk, FAT_DirectoryEntry *entry);
dword FAT_NextCluster(dword currentCluster);
bool FAT_FindFile(DISK *disk, FAT_File *file, char *name,
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
        FAT_BootSector bootSector;
        byte BootSectorBuffer[SECTOR_SIZE];
    } bs;
    FAT_FileData RootDir;
    FAT_FileData OpenedFile[MAX_HANDLES];
} FAT_Data;

static FAT_Data *data;
static byte *fat = NULL;
static dword dataStart;

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

    // extended boot record
    byte DriveNumber;
    byte _Reserved;
    byte Signature;
    dword VolumeId;       // serial number, value doesn't matter
    byte VolumeLabel[MAX_FILE_NAME]; // MAX_FILE_NAME bytes, padded with spaces
    byte SystemId[8];

    // ... we don't care about code ...

} __attribute__((packed)) FAT_BootSector;


bool FAT_ReadBootSector(DISK *disk) {
    return DISK_ReadSectors(disk, 0, 1, data->bs.BootSectorBuffer);
}

bool FAT_ReadFAT(DISK *disk) {
    return DISK_ReadSectors(disk, data->bs.bootSector.ReservedSectors,
                            data->bs.bootSector.SectorsPerFat, fat);
}

bool FAT_Init(DISK *disk) {
    data = (FAT_Data *)FAT_ADDR;

    if (!FAT_ReadBootSector(disk)) {
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

    if (!FAT_ReadFAT(disk)) {
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

    //Read Root Directory
    if (!DISK_ReadSectors(disk, rootLba, 1, data->RootDir.Buffer)) {
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

FAT_File *FAT_OpenEntry(DISK *disk, FAT_DirectoryEntry *entry) {
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
    fd->FirstCluster =
        entry->FirstClusterLow + ((dword)(entry->FirstClusterHigh << 16));
    fd->CurrentCluster = fd->FirstCluster;
    fd->CurrentSectorInCluster = 0;

    if (!DISK_ReadSectors(disk, FAT_Cl2LBA(fd->CurrentCluster), 1,
                          fd->Buffer)) {
        puts("FAT Error: Read Error\n");
        return NULL;
    }

    fd->Opened = true;
    return &fd->File;
}

dword FAT_NextCluster(dword currentCluster) {
    dword index = currentCluster * 3 / 2;
    if (currentCluster % 2 == 0) {
        return (*(word *)(fat + index)) & START_OF_FILE;
    } else {
        return (*(word *)(fat + index)) >> 4;
    }
}

char* FAT_ToFATName(char* name) {
    char fatName[12];
    int nameSize = 0;

    memset(fatName, ' ', sizeof(fatName)); //Fill it with spaces
    fatName[MAX_FILE_NAME] = 0;

    char* exten = strchr(name, '.');
    nameSize = (exten == NULL)? MAX_FILE_NAME : MAX_FILE_NAME - sizeof(exten);

    if (nameSize <= 0) {
        puts("Invalid name, Exceeded MAX_FILE_NAME characters");
        return NULL;
    }

    for (int i = 0; i < nameSize; i++)
        fatName[i] = toupper(name[i]); //file.txt -> FILE_______

    char* writeExt;
    int lengthToSkip = (nameSize - strcut(fatName, ' ')) - sizeof(exten);
    writeExt = fatName + lengthToSkip;

    for (int i = 0; i < sizeof(exten); i++)
        writeExt[i] = exten[i];

    return fatName;
}

bool FAT_FindFile(DISK *disk, FAT_File *file, char *name, FAT_DirectoryEntry *output) {
    FAT_DirectoryEntry entry;

    char* fatName = FAT_ToFATName(name);

    while(FAT_ReadEntry(disk, file, &entry)) {
        if (memcmp(fatName, entry.Name, MAX_FILE_NAME)) {
            *output = entry;
            return true;
        }
    }

    return false;
}

FAT_File *FAT_Open(DISK *disk, char *path) {

    char name[MAX_PATH_SIZE+1];
    if (*path == '/')
        path++;

    FAT_File* parent = NULL;
    FAT_File* current = &data->RootDir.File;

    while (*path) {
        bool last = false;
        char* dirDelim = strchr(path, '/');
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
        if (FAT_FindFile(disk, current, name, &entry)) {
            FAT_Close(current);

            if (!last && entry.Attributes & FAT_ATTRIBUTE_DIRECTORY == 0) {
                puts(name); puts("Is not a Directory!\n");
                return NULL;
            }

            if (!last)
                current = FAT_OpenEntry(disk, &entry);
        } else {
            FAT_Close(current);
            
            puts(name); puts("Not found!\n");
            return NULL;
        }
    }

    return current;
}

void FAT_Close(FAT_File* file) {
    if (file->Handle == ROOT_DIR_HANDLE) {
        file->Position = 0;
        data->RootDir.CurrentCluster = data->RootDir.FirstCluster;
    } else {
        if (data->OpenedFile[file->Handle].Opened)
            data->OpenedFile[file->Handle].Opened = false;
    }
}

dword FAT_Read(DISK *disk, FAT_File *file, dword count, void *output) {
    FAT_FileData *fileData = (file->Handle == ROOT_DIR_HANDLE)
                           ? &data->RootDir
                           : &data->OpenedFile[file->Handle];
}