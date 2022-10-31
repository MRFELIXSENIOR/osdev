include scripts/def.mk

always:
	@mkdir -p $(@D)

.PHONY=all always
all: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.o: always
	@echo "${fgCYAN_COL}Compiling boot.asm${fgDEFAULT_COL}"
	@mkdir -p $(@D)
	@$(ASM) boot/stage1/boot.asm -f elf -o boot.o

$(BUILD_DIR)/boot.bin: always $(BUILD_DIR)/boot.o
	@echo "${fgYELLOW_COL}Creating $@${fgDEFAULT_COL}"
	@mkdir -p $(@D)
	@$(LD) -o $@ -T boot/stage1/linker.ld $^