include scripts/def.mk

SOURCES=$(wildcard cpu/*.c driver/*.c)
HEADERS=$(wildcard cpu/*.h driver/*.h)

OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(SOURCES))

.PHONY=all
all: $(LIB_DIR)/libsys.a

$(LIB_DIR)/libsys.a: ${OBJ}
	@echo "${fgYELLOW_COL}Creating $@${fgDEFAULT_COL}"
	@$(AR) rvs $@ $^

$(BUILD_DIR)/%.o: %.c ${HEADERS}
	@echo "${fgCYAN_COL}Compiling $<${fgDEFAULT_COL}"
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@