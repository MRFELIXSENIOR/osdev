print16:
    pusha

prt16_srt:
    mov al, [bx]
    cmp al, 0x0
    je done

    mov ah, 0x0
    int 0x10

    add bx, 1
    jmp prt16_srt

done:
    popa
    ret

print16_nl:
    pusha

    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10

    popa
    ret
