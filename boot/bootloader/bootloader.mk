NASM=nasm.exe
LD=i686-elf-ld.exe

CC=i686-elf-gcc.exe
CFLAGS=-ffreestanding -Wall -Wextra

SOURCES=$(wildcard boot/bootloader/*.c)
HEADERS=$(wildcard boot/bootloader/*.h)

OBJ=${SOURCES:.c=.o}

.PHONY=all
all: build/bootloader.bin

build/bootEntry.o: boot/bootloader/entry.asm ${OBJ}
	$(NASM) $< -f elf -o $@

build/bootloader.bin: ${OBJ} build/bootEntry.o
	$(LD) -o $@ $^ -T boot/bootloader/linker.ld

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@