include scripts/def.mk

SOURCES=$(wildcard libc/*.c)
HEADERS=$(wildcard libc/*.h)

OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(SOURCES))

.PHONY=all
all: $(LIB_DIR)/libc.a

$(LIB_DIR)/libc.a: ${OBJ}
	$(AR) rvs $@ $^

$(BUILD_DIR)/%.o: %.c ${HEADERS}
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@