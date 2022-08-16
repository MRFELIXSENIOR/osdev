lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [_sect_per_track]

    add dx, 1
    mov cx, dx

    xor dx, dx
    div word [_heads]

    mov dh, al
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov al, ax
    pop ax
    ret
    
disk_read:

