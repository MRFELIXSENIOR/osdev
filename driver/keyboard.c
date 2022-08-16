#include "keyboard.h"
#include "../cpu/isr.h"
#include "../driver/ports.h"
#include "../driver/video.h"
#include "../libc/stdio.h"
#include "../libc/string.h"

#define released(k) HGET_RELEASED_SCANCODE(k)

static char KEY_BUFFER[1024];
static BOOL BACKSPACE_ENABLED = TRUE;
static BOOL SHIFT_ENABLED = FALSE;
static BOOL CAPSLOCK_ENABLED = FALSE;

#define SCANCODE_MAX 0x58
const char *scancodeNames[] = {
    "ERROR",      "Esc",      "1",        "2",           "3",
    "4",          "5",        "6",        "7",           "8",
    "9",          "0",        "-",        "=",           "Backspace",
    "Tab",        "Q",        "W",        "E",           "R",
    "T",          "Y",        "U",        "I",           "O",
    "P",          "[",        "]",        "Enter",       "Lctrl",
    "A",          "S",        "D",        "F",           "G",
    "H",          "J",        "K",        "L",           ";",
    "'",          "`",        "LShift",   "Backslash",   "Z",
    "X",          "C",        "V",        "B",           "N",
    "M",          ",",        ".",        "Slash",       "RShift",
    "Keypad_*",   "LAlt",     "Spacebar", "Capslock",    "F1",
    "F2",         "F3",       "F4",       "F5",          "F6",
    "F7",         "F8",       "F9",       "F10",         "Numlock",
    "ScrollLock", "Keypad_7", "Keypad_8", "Keypad_9",    "Keypad_Minus",
    "Keypad_4",   "Keypad_5", "Keypad_6", "Keypad_Plus", "Keypad_1",
    "Keypad_2",   "Keypad_3", "Keypad_0", "Keypad_Dot",  "NULL",
    "NULL",       "NULL",     "F11",      "F12"};

static const char scancodeAscii[] = {
    NULL, NULL, '1',  '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9',  '0',
    '-',  '=',  NULL, NULL, 'q',  'w',  'e',  'r',  't',  'y',  'u',  'i',
    'o',  'p',  '[',  ']',  NULL, NULL, 'a',  's',  'd',  'f',  'g',  'h',
    'j',  'k',  'l',  ';',  '\'', '`',  NULL, '\\', 'Z',  'x',  'c',  'v',
    'b',  'n',  'm',  ',',  '.',  '/',  NULL, '*',  NULL, ' ',  NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    '7',  '8',  '9',  '-',  '4',  '5',  '6',  '+',  '1',  '2',  '3',  '0',
    '.',  NULL, NULL, NULL, NULL, NULL};

static const char scancodeAsciiCapital[] = {
    NULL, NULL, '!',  '@',  '#',  '$',  '%',  '^',  '&',  '*',  '(',  ')',
    '_',  '+',  NULL, NULL, 'Q',  'W',  'E',  'R',  'T',  'Y',  'U',  'I',
    'O',  'P',  '{',  '}',  NULL, NULL, 'A',  'S',  'D',  'F',  'G',  'H',
    'J',  'K',  'L',  ':',  '"',  '~',  NULL, NULL, 'Z',  'X',  'C',  'V',
    'B',  'N',  'M',  '<',  '>',  '?',  NULL, NULL, NULL, ' ',  NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL};

static void KEYBOARD_CALLBACK(registers r) {
    byte scancode = HPORT_GETBYTE(0x60);

    if (scancode > SCANCODE_MAX)
        return;

    /*
    if (scancode == HSC_BACKSPACE) {
        backspace(KEY_BUFFER);
        HSCR_PUTBACKSPACE();
    } else if (scancode == HSC_ENTER) {
        puts("\n");
        KEY_BUFFER[0] = '\0';
    } else {
        char c = scancodeAscii[(int)scancode];

        char str[2] = {c, 0};
        strapp(KEY_BUFFER, c);
        puts(str);
    }
    */

    switch (scancode) {
    case HSC_ENTER: {
        // puts("\n");
        KEY_BUFFER[0] = 0;
        break;
    }

    case HSC_BACKSPACE: {
        // if (BACKSPACE_ENABLED != TRUE)
        // break;
        backspace(KEY_BUFFER);
        // HSCR_PUTBACKSPACE();
        break;
    }

    default: {
        char c;
        if ((SHIFT_ENABLED | CAPSLOCK_ENABLED) == TRUE) {
            c = scancodeAsciiCapital[scancode];
        } else {
            c = scancodeAscii[scancode];
        }

        char str[2] = {c, 0};
        strapp(KEY_BUFFER, c);
        // puts(str);
    }
    }
}

void HGET_INPUT(char **buffer) {
    if (!buffer)
        return;
    buffer = &KEY_BUFFER;
}

void SETBACKSPACE_ENABLED(BOOL boolean) { BACKSPACE_ENABLED = boolean; }

byte HGET_RELEASED_SCANCODE(byte pressedKey) { return (pressedKey + 0x80); }

void HKEYBOARD_INIT() { HREGISTER_INTHANDLER(IRQ1, KEYBOARD_CALLBACK); }
