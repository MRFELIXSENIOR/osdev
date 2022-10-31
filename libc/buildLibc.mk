include scripts/def.mk

SOURCES=$(wildcard libc/*.c)
OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(SOURCES))

.PHONY=all
all: $(LIB_DIR)/libc.a

$(LIB_DIR)/libc.a: ${OBJ}
	@echo "${fgGREEN_COL}Creating $(notdir $@)"
	@mkdir -p $(@D)
	@$(AR) rvs $@ $^

$(BUILD_DIR)/%.o: %.c
	@echo "${fgGREEN_COL}Compiling $(notdir $<)"
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@