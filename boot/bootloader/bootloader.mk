NASM=nasm

build/bootloader.bin: boot/bootloader/entry.asm
	$(NASM) $< -f bin -o $@