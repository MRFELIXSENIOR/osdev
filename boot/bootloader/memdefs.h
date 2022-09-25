#ifndef __BIOS_MEMDEFS__
#define __BIOS_MEMDEFS__

#define MEM_MIN 0x00000500
#define MEM_MAX 0x00080000

#define FAT_ADDR ((void*) 0x00500000)
#define FAT_SIZE 0x00010000

#define KERNEL_LOAD_ADDR (void*)0x10000000

#endif