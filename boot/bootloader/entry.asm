bits 16


extern bootmain

section .entry
    global main
    main:
        mov si, msg
        call printnl

        call bootmain
        
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
    msg: db 'boot.bin Loaded!, jmped to the Bootloader', 0