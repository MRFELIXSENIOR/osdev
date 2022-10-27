#include "string.h"

#define NULL (void*)0

int strlen(const char *string) {
    int len = 0;
    while (string[len] != 0) {
        len++;
    }
    return len;
}

void itoa(int n, char *str) {
    int i = 0, sign = 0;
    if ((sign = n) < 0)
        n = -n;
    while ((n /= 10) > 0) {
        str[i++] = n % 10 + '0';
    }

    if (sign < 0)
        str[i++] = '-';

    str[i] = '\0';
}

void strrev(char *s) {
    int c, i, j;
    for (i = 0, j = strlen(s) - 1; i < j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

int strcmp(char *s1, char *s2) {
    int i;
    for (i = 0; s1[i] == s2[i]; i++) {
        if (s1[i] == '\0')
            return 0;
    }
    return s1[i] - s2[i];
}

const char* strchr(char* str, char c) {
    while (*str) {
        if (*str == c) 
            return str;

        str++;
    }

    return NULL;
}

char* strcpy(char* src, char* dest) {
    char* orgD = dest;
    if (dest == NULL)
        return NULL;

    if (src == NULL) {
        *dest = 0;
        return dest;
    }

    while (*src) {
        *dest = *src;
        src++;
        dest++;
    }

    *dest = 0;
    return orgD;
}

void backspace(char *s) { s[strlen(s) - 1] = 0; }
void strapp(char *s, char c) {
    unsigned int len = strlen(s);
    s[len] = c;
    s[len + 1] = 0;
}

int chridx(char* string, char chr) {
    int i = 0;
    while (string[i] != chr) {
        i++;
    }

    return i;
}