include scripts/def.mk

SOURCES=$(wildcard cpu/*.c driver/*.c)
OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(SOURCES))

.PHONY=all
all: $(LIB_DIR)/libsys.a

$(LIB_DIR)/libsys.a: ${OBJ}
	@echo "${fgGREEN_COL}Creating $@${fgDEFAULT_COL}"
	@mkdir -p $(@D)
	@$(AR) rvs $@ $^

$(BUILD_DIR)/%.o: %.c
	@echo "${fgGREEN_COL}Compiling $<${fgDEFAULT_COL}"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@