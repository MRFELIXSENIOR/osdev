# $@ = target file
# $< = first dependency
# $^ = all dependencies

SOURCES=$(wildcard kernel/*.c driver/*.c libc/*.c cpu/*.c)
HEADERS=$(wildcard kernel/*.h driver/*.h libc/*.h cpu/*.h)
OBJ=$(SOURCES:.c=.o cpu/int.o)

CC=i686-elf-gcc
CFLAGS=-ffreestanding -Wall -Wextra -Wno-unused-parameter

LD=i686-elf-ld
GDB=gdb
QEMU=qemu-system-x86_64

#TRUNCATE=truncate
#RECOMMENDED_SIZE=1M

.PHONY=all
all:
	@$(MAKE) -f boot/stage1/boot.mk
	@$(MAKE) -f boot/bootloader/bootloader.mk
	@$(MAKE) build

run: build #extend
	$(QEMU) os.vhd

.PHONY=build
build: os.vhd

os.vhd: build/boot.bin build/bootloader.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "HDRV" $@
	dd if=$< of=$@ conv=notrunc
	copy -i $@ build/bootloader.bin "::hboot.bin"

build/%.o : %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: %.asm
	nasm $< -f elf -o $@

build/%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf build/* *.vhd