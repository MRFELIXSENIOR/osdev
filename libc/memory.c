#include "memory.h"

void memcpy(char *src, char *dest, unsigned int nbytes) {
    for (unsigned int i = 0; i < nbytes; i++) {
        *(dest + i) = *(src + i);
    }
}

void memset(char *dest, char val, unsigned int length) {
    char *temp = dest;
    for (; length != 0; length--)
        *temp++ = val;
}
