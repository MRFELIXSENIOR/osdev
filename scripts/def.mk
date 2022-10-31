export OS_IMAGE	= os.hdd

export FATType 	= 16
export QEMU		= qemu-system-x86_64.exe
export QEMU_FLAG= -drive file=$(OS_IMAGE),format=raw

export CFLAGS 	= -std=c99 -g -ffreestanding -I$(SOURCE) -L
export ASM		= nasm.exe
export CC		= i686-elf-gcc.exe
export CXX		= i686-elf-g++.exe
export LD		= i686-elf-ld.exe
export AR		= i686-elf-ar.exe

export SOURCE_DIR 	= $(abspath .)
export LIB_DIR		= $(abspath lib)
export LIBC_DIR		= $(abspath libc)
export BOOT_DIR		= $(abspath boot)
export DRIVER_DIR	= $(abspath driver)
export BUILD_DIR 	= $(abspath build)

export fgBLACK_COL	= "$$(tput setaf 0)"
export fgRED_COL	= "$$(tput setaf 1)"
export fgGREEN_COL	= "$$(tput setaf 2)"
export fgYELLOW_COL	= "$$(tput setaf 3)"
export fgBLUE_COL	= "$$(tput setaf 4)"
export fgMAGENTA_COL= "$$(tput setaf 5)"
export fgCYAN_COL	= "$$(tput setaf 6)"
export fgWHITE_COL	= "$$(tput setaf 7)"
export fgDEFAULT_COL= "$$(tput setaf 9)"

export bgBLACK_COL	= "$$(tput setab 0)"
export bgRED_COL	= "$$(tput setab 1)"
export bgGREEN_COL	= "$$(tput setab 2)"
export bgYELLOW_COL	= "$$(tput setab 3)"
export bgBLUE_COL	= "$$(tput setab 4)"
export bgMAGENTA_COL= "$$(tput setab 5)"
export bgCYAN_COL	= "$$(tput setab 6)"
export bgWHITE_COL	= "$$(tput setab 7)"
export bgDEFAULT_COL= "$$(tput setab 9)"