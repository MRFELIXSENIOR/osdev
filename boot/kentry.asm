[bits 32]
global _start;

_start:
    [extern kstart]
    call kstart
    jmp $