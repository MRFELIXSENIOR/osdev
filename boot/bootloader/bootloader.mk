include scripts/def.mk

SOURCES=$(wildcard boot/bootloader/*.c)
ASMSOURCES=$(wildcard boot/bootloader/*.asm)

OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(SOURCES))
ASMOBJ=$(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASMSOURCES))

.PHONY=all
all: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: ${ASMOBJ} ${OBJ} $(LIB_DIR)/libc.a
	@mkdir -p $(@D)
	@echo "${fgGREEN_COL}Creating $@"
	@$(LD) $^ -o $@ -T boot/bootloader/linker.ld

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	@echo "${fgGREEN_COL}Compiling $<${fgDEFAULT_COL}"
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.asm
	@mkdir -p $(@D)
	@echo "${fgGREEN_COL}Compiling $<${fgDEFAULT_COL}"
	@$(ASM) $< -f elf -o $@