#include "main.h"
#include "libc/stdio.h"

void* data = (void*)0x00500200;

typedef void (*kernelMain)();

void __cdecl bootStart(word bootDrive, void* partitionEntry) {
    puts("[INFO] bootStart called!\n");
    DISK disk;
    if (!DISK_Init(&disk, bootDrive)) {
        puts("DISK: Failed To Initialize, Potential Disk Corruption\n");
        goto loop;
    }

    Partition part;
    MBRCheckPartition(&part, &disk, partitionEntry);

    if (!FAT_Init(&part)) {
        puts("Partition: Failed To Initialize FAT\n");
        goto loop;
    }

    FAT_File* fileData = FAT_Open(&disk, "/");
    FAT_DirectoryEntry entry;
    int i = 0;
    while(FAT_ReadEntry(&disk, fileData, &entry) && i++ < 5) {
        puts("  ");
        for (int i = 0; i < 11; i++) {
            putc(entry.Name[i]);
        }
        puts("\n");
    }
    FAT_Close(fileData);

    char buffer[144];
    dword read;
    fileData = FAT_Open(&disk, "/file.txt");
    while((read = FAT_Read(&disk, fileData, 144, buffer))) {
        for (dword i = 0; i < read; i++) {
            if (buffer[i] == '\n')
                putc('\r');
            putc(buffer[i]);
        }
    }
    FAT_Close(fileData);

loop:
    for (;;);
}