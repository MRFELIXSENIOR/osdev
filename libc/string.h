#ifndef __HSTRING_LIBC__
#define __HSTRING_LIBC__

int strlen(const char *string);
void strrev(char *data);
int strcmp(char *first, char *second);
int chridx(char* string, char chr);
void strapp(char *s, char c);
const char* strchr(char* str, char c);
char* strcpy(char* src, char* dest);

void backspace(char *s);
void itoa(int n, char *str);

#endif
