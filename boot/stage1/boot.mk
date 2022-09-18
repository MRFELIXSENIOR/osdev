LD=i686-elf-ld.exe
NASM=nasm.exe

.PHONY=all
all: build/boot.bin

build/bootrecord.o: boot/stage1/boot.asm
	$(NASM) $< -f elf -o $@

build/boot.bin: build/bootrecord.o
	$(LD) -o $@ -T boot/stage1/linker.ld $^