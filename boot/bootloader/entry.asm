bits 16

global main
main:
    sti
    mov ah, 0x0e
    mov al, 0x75
    int 0x10 

msg: db "booting", 0

printnl:
    push ax
    push bx

.loop:
    mov al, [bx]
    cmp al, 0           ; verify if next character is null?
    je .nl

    mov ah, 0x0e        ; call bios interrupt
    int 0x10

    inc bx
    jmp .loop

.nl:
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10

    mov al, 0x0d
    int 0x10

    pop bx
    pop ax
    ret