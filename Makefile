# $@ = target file
# $< = first dependency
# $^ = all dependencies

SOURCES=$(wildcard kernel/*.c driver/*.c libc/*.c cpu/*.c)
HEADERS=$(wildcard kernel/*.h driver/*.h libc/*.h cpu/*.h)
OBJ=$(SOURCES:.c=.o cpu/int.o)

CC=i386-elf-gcc
CFLAGS=-g -ffreestanding -Wall -Wextra -Wno-unused-parameter -zl

LD=i386-elf-ld
GDB=gdb
QEMU=qemu-system-i386

#TRUNCATE=truncate
#RECOMMENDED_SIZE=1M

.PHONY=all
all: build

run: build #extend
	$(QEMU) os.img

build: os.img

#extend: os.img
#	$(TRUNCATE) --size=$(RECOMMENDED_SIZE) $<

debug: os.img kernel.elf
	$(QEMU) -s -S $< &
	$(GDB) -ix gdb_init_rm.txt -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

os.img: boot/boot.bin kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 32 -n "HOSD" $@
	dd if=$< of=$@ conv=notrunc
	mcopy -i $@ kernel.bin "::kernel.bin"

#os.img: cat $^ > $@

kernel.bin: boot/kentry.o ${OBJ}
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

kernel.elf: boot/kentry.o ${OBJ}
	$(LD) -o $@ -Ttext 0x1000 $^

%.o : %.c ${HEADERS}
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf *.bin *.elf kernel/*.o boot/*.bin boot/*.o driver/*.o libc/*.o *.img cpu/*.o 
