#ifndef __HMEMORY_LIBC__
#define __HMEMORY_LIBC__

void memcpy(char *src, char *dest, unsigned int nbytes);
void memset(char *dest, char val, unsigned int length);
int memcmp(const void* ptr1, const void* ptr2, unsigned short num);
void* toLinearMemAddr(void* seg_off_addr);

#endif
