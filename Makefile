# $@ = target file
# $< = first dependency
# $^ = all dependencies

FAT=16
OS_IMAGE=os.hdd

QEMU=qemu-system-x86_64.exe
QEMU_FLAG=-drive file=$(OS_IMAGE),format=raw

CC=i686-elf-gcc.exe
CFLAGS=-g -ffreestanding -I.

LD=i686-elf-ld.exe

SOURCES=$(wildcard kernel/*.c driver/*.c cpu/*.c)
HEADERS=$(wildcard kernel/*.h driver/*.h cpu/*.h)
ASMSOURCES=$(wildcard cpu/*.asm)
#OBJ=$(SOURCES:.c=build/.o cpu/int.o)

OBJ=$(patsubst %.c,build/kessential/%.o,$(SOURCES))
ASMOBJ=$(patsubst %.asm,build/kessential/%.o,$(ASMSOURCES))

.PHONY=all
all: buildkessential
	@$(MAKE) -f libc/buildlibc.mk
	@$(MAKE) -f sys/buildsys.mk
	@$(MAKE) -f boot/stage1/boot.mk
	@$(MAKE) -f boot/bootloader/bootloader.mk
	@$(MAKE) putfile
	@$(MAKE) run

run: os #extend
	$(QEMU) $(QEMU_FLAG)

.PHONY=putfile
putfile: os
	mcopy -i $(OS_IMAGE) test/file.txt ::

.PHONY=build
os: $(OS_IMAGE)

$(OS_IMAGE): build/boot.bin build/bootloader.bin
	dd if=/dev/zero of=$@ bs=512 count=49152
	mkfs.fat -F $(FAT) -n "GATO" $@
	dd if=$< of=$@ conv=notrunc
	mcopy -i $@ build/bootloader.bin ::

buildkessential: ${OBJ} ${ASMOBJ}

build/kessential/%.o : %.c ${HEADERS}
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

build/kessential/%.o: %.asm
	@mkdir -p $(@D)
	nasm $< -f elf -o $@

build/%.bin: %.asm
	@mkdir -p $(@D)
	nasm $< -f bin -o $@

clean:
	rm -rf build/*