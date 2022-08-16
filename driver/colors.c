#include "colors.h"

unsigned char H_GETCOLOR(unsigned char fg, unsigned char bg) {
    return (fg | bg << 4);
}
