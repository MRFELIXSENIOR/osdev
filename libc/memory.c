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

int memcmp(const void* ptr1, const void* ptr2, unsigned short num) {
    const unsigned char* bytePtr1 = (const unsigned char*)ptr1;
    const unsigned char* bytePtr2 = (const unsigned char*)ptr2;

    for (short i = 0; i < num; i++) {
        if (bytePtr1[i] != bytePtr2[i])
            return 1;
    }
}

void* toLinearMemAddr(void* seg_off_addr) {
    unsigned int offset = (unsigned int)(seg_off_addr) & 0xFFFF;
    unsigned int seg = (unsigned int)(seg_off_addr) >> 16;
    return (void*)(seg * 16 + offset);
}