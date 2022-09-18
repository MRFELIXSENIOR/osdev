# $@ = target file
# $< = first dependency
# $^ = all dependencies

SOURCES=$(wildcard kernel/*.c driver/*.c libc/*.c cpu/*.c)
HEADERS=$(wildcard kernel/*.h driver/*.h libc/*.h cpu/*.h)
OBJ=$(SOURCES:.c=.o cpu/int.o)

CC=i686-elf-gcc.exe
CFLAGS=-ffreestanding -Wall -Wextra -Wno-unused-parameter

LD=i686-elf-ld.exe
QEMU=qemu-system-x86_64.exe

#TRUNCATE=truncate
#RECOMMENDED_SIZE=1M

.PHONY=all
all:
	@$(MAKE) -f boot/stage1/boot.mk
	@$(MAKE) -f boot/bootloader/bootloader.mk
	@$(MAKE) build

run: build #extend
	$(QEMU) -fda os.img

.PHONY=build
build: os.img

.PHONY=debug
debug:
	bochs.exe -f bochs-config

os.img: build/boot.bin build/bootloader.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "OS  " $@
	dd if=$< of=$@ conv=notrunc
	mcopy -i $@ build/bootloader.bin "::boot.bin"

build/%.o : %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: %.asm
	nasm $< -f elf -o $@

build/%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm build/*