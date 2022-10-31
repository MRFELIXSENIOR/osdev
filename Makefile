# $@ = target file
# $< = first dependency
# $^ = all dependencies

include scripts/def.mk

DISK_SIZE=31457280

.PHONY=all
all: ${BUILD_DIR}/$(OS_IMAGE)

run: $(BUILD_DIR)/$(OS_IMAGE)
	@$(QEMU) $(QEMU_FLAG)

.PHONY=$(BUILD_DIR)

$(BUILD_DIR)/$(OS_IMAGE): bootloader sys
	@./scripts/create_disk_image.sh $@ ${DISK_SIZE}

bootloader: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/bootloader.bin

$(LIB_DIR)/libc.a: always
	@echo ${fgBLUE_COL}"Compiling"$@"..."
	@$(MAKE) -C libc

sys: $(LIB_DIR)/libsys.a

$(LIB_DIR)/libsys.a: always
	@echo ${fgBLUE_COL}"Compiling"$@"..."
	@$(MAKE) -C sys/buildsys.mk

$(BUILD_DIR)/boot.bin: always
	@echo ${fgBLUE_COL}"Compiling"$@"..."
	@$(MAKE) -f boot/stage1/boot.mk

$(BUILD_DIR)/bootloader.bin: always
	@echo ${fgBLUE_COL}"Compiling"$@"..."
	@$(MAKE) -f boot/bootloader/bootloader.mk

always:
	@mkdir -p $(BUILD_DIR)

clean:
	@echo "${fgBLUE_COL}Cleaning..."
	@rm -rf $(BUILD_DIR)/*