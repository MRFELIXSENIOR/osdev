#ifndef __HSTRING_LIBC__
#define __HSTRING_LIBC__

int strlen(const char *string);
void strrev(char *data);
int strcmp(char *first, char *second);
void backspace(char *s);
void strapp(char *s, char c);

void itoa(int n, char *str);

#endif
