bits 16

[extern bootStart]

section .entry
    global bootloaderStart
    bootloaderStart:
        cli
        mov ax, ds
        mov ss, ax
        mov sp, 0
        mov bp, sp
        sti

        mov si, msg
        call printnl

        xor dh, dh
        push dx
        call bootStart

        cli
        hlt

section .text
    printnl:
        pusha

    .loop:
        lodsb               ; loads next character in al
        cmp al, 0           ; verify if next character is null?
        je .done

        mov ah, 0x0E        ; call bios interrupt
        int 10h

        jmp .loop

    .done:
        mov ah, 0x0e
        mov al, 0x0a
        int 10h

        mov al, 0x0d
        int 10h

        popa
        ret

section .data
    msg: db '[INFO] boot.bin Loaded', 0