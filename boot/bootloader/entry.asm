bits 16

global entry
entry:
    mov bx, msg
    call printnl

msg: db 'ur in the bootloader fucker!!11', 0

printnl:
    pusha

.loop:
    mov al, [bx]
    cmp al, 0
    je .nl

    mov ah, 0x0e
    int 0x10

    inc bx
    jmp .loop

.nl:
    pusha

    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    
    mov al, 0x0d
    int 0x10

    popa
    ret