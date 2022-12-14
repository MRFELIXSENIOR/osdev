export OS_IMAGE		= os_image.vhd

export FATType 		= 16
export QEMU			= qemu-system-x86_64.exe
export QEMU_FLAG	= -drive file=$(OS_IMAGE),format=raw

export CFLAGS 		= -std=c99 -g -ffreestanding -I$(SOURCE_DIR) -L$(LIB_DIR)
export ASM			= nasm.exe
export CC			= i686-elf-gcc.exe
export CXX			= i686-elf-g++.exe
export LD			= i686-elf-ld.exe
export AR			= i686-elf-ar.exe

export SOURCE_DIR 	= .
export LIB_DIR		= lib
export LIBC_DIR		= libc
export BOOT_DIR		= boot
export DRIVER_DIR	= driver
export BUILD_DIR 	= build

export fgBLACK_COL	= "$$(tput setaf 0)"
export fgRED_COL	= "$$(tput setaf 1)"
export fgGREEN_COL	= "$$(tput setaf 2)"
export fgYELLOW_COL	= "$$(tput setaf 3)"
export fgBLUE_COL	= "$$(tput setaf 4)"
export fgMAGENTA_COL= "$$(tput setaf 5)"
export fgCYAN_COL	= "$$(tput setaf 6)"
export fgWHITE_COL	= "$$(tput setaf 7)"
export fgDEFAULT_COL= "$$(tput setaf 9)"