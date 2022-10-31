# $@ = target file
# $< = first dependency
# $^ = all dependencies

include scripts/def.mk

DISK_SIZE=31457280
all: ${BUILD_DIR}/$(OS_IMAGE)

run: $(BUILD_DIR)/$(OS_IMAGE)
	@$(QEMU) $(QEMU_FLAG)

$(LIB_DIR)/libc.a:
	@$(MAKE) -f libc/buildlibc.mk

$(LIB_DIR)/libsys.a:
	@$(MAKE) -f sys/buildsys.mk

$(BUILD_DIR)/bootloader.bin:
	@$(MAKE) -f boot/bootloader/bootloader.mk

$(BUILD_DIR)/boot.bin:
	@$(MAKE) -f boot/stage1/boot.mk

bootloader: $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/boot.bin
	@$(MAKE) -f boot/bootloader/bootloader.mk

libc: $(LIB_DIR)/libc.a
sys: $(LIB_DIR)/libsys.a

.PHONY=bootloader sys libc all run
$(BUILD_DIR)/$(OS_IMAGE): libc sys bootloader
	@./scripts/create_disk_image.sh $@ ${DISK_SIZE}

clean:
	@echo "${fgGREEN_COL}Cleaning..."
	@rm -rf $(BUILD_DIR)/*