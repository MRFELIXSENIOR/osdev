include scripts/def.mk

SOURCES=$(wildcard boot/bootloader/*.c)
ASMSOURCES=$(wildcard boot/bootloader/*.asm)
HEADERS=$(wildcard boot/bootloader/*.h)

OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(SOURCES))
ASMOBJ=$(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASMSOURCES))

.PHONY=all
all: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: ${ASMOBJ} ${OBJ} $(LIB_DIR)/libc.a
	$(LD) $^ -o $@ -T boot/bootloader/linker.ld

$(BUILD_DIR)/%.o: %.c $(HEADERS)
	@echo "${fgCYAN_COL}Compiling $<${fgDEFAULT_COL}"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.asm
	@echo "${fgCYAN_COL}Compiling $<${fgDEFAULT_COL}"
	@$(ASM) $< -f elf -o $@