bits 16

section .fsjump
    jmp short main
    nop

section .fsheaders
    ;BDB
    bdb_oem:                db "gatOS   "
    bdbBytePerSector:       dw 512
    bdbSectorsPerCluster:   db 4
    bdbReserved:            dw 4
    bdbFATCount:            db 2
    bdbEntriesCount:        dw 512
    bdbTotalSector:         dw 49152
    bdbMediaDesc:           db 0xF8
    bdbSectorsPerFAT:       dw 48
    bdbSectorsPerTrack:     dw 32
    bdbHeadsCount:          dw 2
    bdbHiddenSectors:       dq 0
    bdbLargeSectorsCount:   dq 0

    ;EBR
    DriveNumber:            db 0x80
    NTFlag:                 db 0
    EBRSignature:           db 0x29
    EBRVolumeID:            dq 0x20202020
    EBRVolumeLabel:         db "gatOS drive"
    EBRSystemID:            db "FAT16   "

section .entry
    global main
    main:
        mov ax, PART_ENTRY_SEG
        mov es, ax
        mov di, PART_ENTRY_OFF
        mov cx, 16
        rep movsb

        mov ax, 0
        mov ds, ax
        mov ss, ax
        mov bp, 0x7c00
        mov sp, bp

        push es
        push word .after
        retf

    .after:
        mov [DriveNumber], dl

        mov si, msg
        call printnl

        mov ah, 0x41
        mov bx, 0x55AA
        stc
        int 13h
        jc .no_lba_addressing_extension

        mov byte [lba_extension], 1
        jmp .after_check

    .no_lba_addressing_extension:
        mov byte [lba_extension], 0

    .after_check:
        mov si, stage2_location

        mov ax, STAGE2_LOAD_SEG
        mov es, ax

        mov bx, STAGE2_LOAD_OFF

    .load_loop:
        mov eax, [si]
        add si, 4
        mov cl, [si]
        inc si

        cmp eax, 0
        je .read_finish

        call disk_read

        xor ch, ch
        shl cx, 5
        mov di, es
        add di, cx
        mov es, di

        jmp .load_loop

    .read_finish:
        mov dl, [DriveNumber]

        mov si, PART_ENTRY_OFF
        mov di, PART_ENTRY_SEG

        mov ax, STAGE2_LOAD_SEG
        mov ds, ax
        mov es, ax

        jmp STAGE2_LOAD_SEG:STAGE2_LOAD_OFF

        cli
        hlt

section .text
    stage2_notfound:
        mov si, STAGE2_msg
        call printnl

    printnl:
        push si
        push ax

    .loop:
        lodsb
        cmp al, 0
        je .nl

        mov ah, 0Eh
        int 10h

        jmp .loop

    .nl:
        mov ah, 0Eh
        mov al, 0Ah
        int 0x10

        mov al, 0Dh
        int 0x10

        pop ax
        pop si
        ret

    lba_to_chs:

        push ax
        push dx

        xor dx, dx                          ; dx = 0
        div word [bdbSectorsPerTrack]          ; ax = LBA / SectorsPerTrack
                                            ; dx = LBA % SectorsPerTrack

        inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
        mov cx, dx                          ; cx = sector

        xor dx, dx                          ; dx = 0
        div word [bdbHeadsCount]                   ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                            ; dx = (LBA / SectorsPerTrack) % Heads = head
        mov dh, dl                          ; dh = head
        mov ch, al                          ; ch = cylinder (lower 8 bits)
        shl ah, 6
        or cl, ah                           ; put upper 2 bits of cylinder in CL

        pop ax
        mov dl, al                          ; restore DL
        pop ax
        ret
        
    disk_read:
        push eax
        push bx
        push cx
        push dx
        push di
        push si

        cmp byte [lba_extension], 1
        jne .no_extensions

        mov [extensions_dap.lba], eax
        mov [extensions_dap.numSector], cl
        mov [extensions_dap.segment], es
        mov [extensions_dap.offset], bx

        mov ah, 0x42
        mov si, extensions_dap
        
        mov di, 3
        jmp .read

    .no_extensions:
        push cx
        call lba_to_chs
        pop ax

        mov ah, 0x02
        mov di, 3

    .read:
        pusha
        stc

        int 13h
        jnc .done

        popa
        call disk_reset

        dec di
        test di, di
        jnz .read

    .fail:
        jmp disk_error

    .done:
        popa

        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop eax
        ret

    disk_reset:
        pusha
        mov ah, 0
        stc
        int 13h
        jc disk_error
        popa
        ret

    disk_error:
        mov si, DISK_ERROR
        call printnl

section .rodata
    msg:            db 'Booting', 0
    DISK_ERROR:     db 'Disk Error', 0
    STAGE2_msg:     db 'boot.bin not found', 0
    STAGE2_file:    db 'BOOT    BIN'

section .data
    STAGE2_LOAD_SEG equ 0x0
    STAGE2_LOAD_OFF equ 0x500

    PART_ENTRY_SEG  equ 0x2000
    PART_ENTRY_OFF  equ 0x0

    START_OF_FILE   equ 0xFFFF
    END_OF_FILE     equ 0xFFF8
    
    lba_extension: db 0
    extensions_dap:     ;   Disk-Address-Packet Structure
        .size:      db 16
        .reserved:  db 0
        .numSector: dw 0
        .offset:    dw 0
        .segment:   dw 0
        .lba:       dq 0

    global stage2_location
    stage2_location:times 30 db 0

section .bss
    buf:            resb 512