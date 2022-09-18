NASM=nasm.exe
LD=i686-elf-ld.exe

.PHONY=all
all: build/bootloader.bin

build/bootloader.o: boot/bootloader/entry.asm
	$(NASM) $< -f elf -o $@

build/bootloader.bin: build/bootloader.o
	$(LD) -o $@ -T boot/bootloader/linker.ld $^