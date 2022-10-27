CC=i686-elf-gcc.exe
CFLAGS=-g -ffreestanding -I.

SOURCES=$(wildcard sys/*.c)
HEADERS=$(wildcard sys/*.h)

OBJS=$(patsubst %.c,build/%.o,$(SOURCES))

.PHONY=all
all: ${OBJS}

build/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@