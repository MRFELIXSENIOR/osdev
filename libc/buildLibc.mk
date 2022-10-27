AR=i686-elf-ar.exe

CC=i686-elf-gcc.exe
CFLAGS=-g -ffreestanding -I.

SOURCES=$(wildcard libc/*.c)
HEADERS=$(wildcard libc/*.h)

OBJ=$(patsubst %.c,build/%.o,$(SOURCES))

.PHONY=all
all: lib/libgtlibc.a

lib/libgtlibc.a: ${OBJ}
	$(AR) rvs $@ $^

build/%.o: %.c ${HEADERS}
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@