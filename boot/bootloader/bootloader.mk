NASM=nasm.exe
LD=i686-elf-ld.exe
AR=i686-elf-ar.exe

CC=i686-elf-gcc.exe
CFLAGS=-g -ffreestanding -I.

SOURCES=$(wildcard boot/bootloader/*.c)
ASMSOURCES=$(wildcard boot/bootloader/*.asm)
HEADERS=$(wildcard boot/bootloader/*.h)

OBJ=$(patsubst %.c,build/%.o,$(SOURCES))
ASMOBJ=$(patsubst %.asm,build/%.o,$(ASMSOURCES))

.PHONY=all
all: build/bootloader.bin

build/bootloader.bin: ${ASMOBJ} ${OBJ}
	$(LD) $^ lib/libgtlibc.a build/sys/mbr.o -o $@ -T boot/bootloader/linker.ld

build/%.o: %.c $(HEADERS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: %.asm
	@mkdir -p $(@D)
	nasm $< -f elf -o $@