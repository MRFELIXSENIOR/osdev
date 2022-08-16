#include "memory.h"

void memcpy(char *src, char *dest, unsigned int nbytes) {
    for (unsigned int i = 0; i < nbytes; i++) {
        *(dest + i) = *(src + i);
    }
}

void memset(unsigned char *dest, unsigned char val, unsigned int length) {
    unsigned char *temp = dest;
    for (; length != 0; length--)
        *temp++ = val;
}
