#include "ctype.h"

bool islower(dword chr) {
    return chr >= 'a' && chr <= 'z';
}

dword toupper(dword chr) {
    return islower(chr) ? (chr - 'a' + 'A') : chr;
}