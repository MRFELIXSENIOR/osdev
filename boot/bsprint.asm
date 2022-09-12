print:
    pusha

prt16_srt:
    mov al, [bx]
    cmp al, 0x0
    je .nl

    mov ah, 0x0e
    int 0x10

    inc bx
    jmp prt16_srt

.nl:
    pusha

    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10

    popa
    ret
