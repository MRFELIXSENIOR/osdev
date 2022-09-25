# $@ = target file
# $< = first dependency
# $^ = all dependencies

FAT=12

QEMU=qemu-system-x86_64.exe
QEMU_FLAG=-hda

CC=i686-elf-gcc.exe
CFLAGS=-ffreestanding -Wall -Wextra -Wno-unused-parameter

LD=i686-elf-ld.exe

SOURCES=$(wildcard kernel/*.c driver/*.c libc/*.c cpu/*.c)
HEADERS=$(wildcard kernel/*.h driver/*.h libc/*.h cpu/*.h)
OBJ=$(SOURCES:.c=.o cpu/int.o)

#TRUNCATE=truncate
#RECOMMENDED_SIZE=1M

.PHONY=all
all:
	@$(MAKE) -f boot/stage1/boot.mk
	@$(MAKE) -f boot/bootloader/bootloader.mk
	@$(MAKE) build

run: build #extend
	$(QEMU) $(QEMU_FLAG) os.vhd

.PHONY=build
build: os.vhd

os.vhd: build/boot.bin build/bootloader.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F $(FAT) -n "GATO" $@
	dd if=$< of=$@ conv=notrunc
	mcopy -i $@ build/bootloader.bin "::boot.bin"

build/%.o : %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: %.asm
	nasm $< -f elf -o $@

build/%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm build/* *.vhd