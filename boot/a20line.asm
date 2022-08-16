usea20:
    mov ax, 0x2403
    int 0x15
    jb a20ns
    cmp ah, 0
    jnz a20ns

    mov ax, 0x2402
    int 0x15
    jb a20_stf
    cmp ah, 0
    jnz a20_stf

    cmp al, 1
    jz a20_act

    mov ax, 0x2401
    int 0x15
    jb a20_stf
    cmp ah, 0
    jnz a20_stf

a20_act:
    mov bx, a20actMsg
    call print16
    call print16_nl

a20ns:
    mov bx, a20nsMsg
    call print16
    call print16_nl

a20_stf:
    mov bx, a20stfMsg
    call print16
    call print16_nl

a20stfMsg: db "A20 FAILED", 0
a20nsMsg: db "NO A20", 0
a20actMsg: db "A20 ENABLED", 0
