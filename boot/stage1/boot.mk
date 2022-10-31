include scripts/def.mk

.PHONY=all
all: $(BUILD_DIR)/boot.bin

boot.o:
	@echo "${fgCYAN_COL}Compiling boot.asm${fgDEFAULT_COL}"
	@$(ASM) boot/stage1/boot.asm -f elf -o boot.o

$(BUILD_DIR)/boot.bin: boot.o
	@echo "${fgYELLOW_COL}Creating $@${fgDEFAULT_COL}"
	@$(LD) -o $@ -T boot/stage1/linker.ld $^