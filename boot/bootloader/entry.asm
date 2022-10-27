bits 16

section .entry 
    extern __bss_start
    extern __end

    extern bootStart

    global main
    main:
        cli

        mov [bootDrive], dl
        mov [bootPartOff], si
        mov [bootPartSeg], di

        mov ax, ds
        mov ss, ax
        mov sp, 0
        mov bp, sp
        sti

        mov si, msg
        call printnl

        cli
        call enableA20
        call loadGDT

        mov eax, cr0
        or al, 1
        mov cr0, eax

        jmp dword CODE_SEG32:.pmode

    .pmode:
        bits 32

        mov ax, 10h
        mov ds, ax
        mov ss, ax

        mov edi, __bss_start
        mov ecx, __end
        sub ecx, edi
        mov al, 0
        cld
        rep stosb

        mov eax, cr0
        and al, ~1
        mov cr0, eax

        jmp word 00h:.rmode

    .rmode:
        bits 16

        mov si, realmodemsg
        call printnl

        cli
        hlt

    ;text
    printnl:
        push si
        push ax

    .loop:
        lodsb               ; loads next character in al
        cmp al, 0           ; verify if next character is null?
        je .done

        mov ah, 0x0e        ; call bios interrupt
        int 10h

        jmp .loop

    .done:
        mov ah, 0x0e
        mov al, 0x0a
        int 10h

        mov al, 0x0d
        int 10h

        pop ax
        pop si
        ret

    loadGDT:
        bits 16
        lgdt [GDTDesc]
        ret

    enableA20:
        bits 16
        call a20WaitInput
        mov al, kbDisable
        out kbCommand, al

        call a20WaitInput
        mov al, kbReadCtrlOut
        out kbCommand, al

        call a20WaitOutput
        in al, kbData
        push eax

        call a20WaitInput
        mov al, kbWriteCtrlOut
        out kbCommand, al

        call a20WaitInput
        pop eax
        or al, 2
        out kbData, al

        call a20WaitInput
        mov al, kbEnable
        out kbCommand, al

        call a20WaitInput
        ret

    a20WaitInput:
        in al, kbCommand
        test al, 2
        jnz a20WaitInput
        ret

    a20WaitOutput:
        in al, kbCommand
        test al, 1
        jz a20WaitOutput
        ret

    _GDT: ; don't remove the labels, they're needed to compute sizes and jumps
        dq 0
    
    ;32bit code seg
    .code_seg32:
        dw 0FFFFh    ; segment length, bits 0-15
        dw 0         ; segment base, bits 0-15
        db 0         ; segment base, bits 16-23
        db 10011010b ; flags (8 bits)
        db 11001111b ; flags (4 bits) + segment length, bits 16-19
        db 0         ; segment base, bits 24-31

    ;32bit data seg
    .data_seg32:
        dw 0FFFFh
        dw 0
        db 0
        db 10010010b
        db 11001111b
        db 0

    ;16bit code seg
    .code_seg16:
        dw 0FFFFh
        dw 0
        db 0
        db 10011010b
        db 00001111b
        db 0

    ;16bit data seg
    .data_seg16:
        dw 0FFFFh
        dw 0
        db 0
        db 10010010b
        db 00001111b
        db 0

    GDTDesc:
        dw GDTDesc - _GDT - 1
        dd _GDT

    CODE_SEG32      equ _GDT.code_seg32 - _GDT
    DATA_SEG32      equ _GDT.data_seg32 - _GDT

    CODE_SEG16      equ _GDT.code_seg16 - _GDT
    DATA_SEG16      equ _GDT.data_seg16 - _GDT

    ;rodata
    kbData          equ 0x60
    kbCommand       equ 0x64
    kbDisable       equ 0xAD
    kbEnable        equ 0xAE
    kbReadCtrlOut   equ 0xD0
    kbWriteCtrlOut  equ 0xD1

    ;data
    msg:            db '[INFO] Jumped to Bootloader!', 0
    realmodemsg:    db '[BOOTLOADER] Jumped To 16bit Real Mode!', 0
    
    bootDrive:      db 0
    bootPartSeg:    db 0
    bootPartOff:    db 0