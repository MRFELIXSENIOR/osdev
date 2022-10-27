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

        ; Root LBA
        mov ax, [bdbSectorsPerFAT]
        mul word [bdbFATCount]          ;   ax = SPF * 2 = 48 * 2 = 96
        add ax, [bdbReserved]           ;   ax = 96 + 4 = 100
        mov [root_start], ax            ;   root_start = 100

        ;Calculate Root Size
        mov ax, [bdbEntriesCount]       ;   ax = 512
        shl ax, 5                       ;   ax = 32 * 512 = 16384
        xor dx, dx                      ;   dx: remainder of the division, dx = 0
        div [bdbBytePerSector]          ;   ax / 512 = 32
        add ax, word [root_start]       ;   ax = root_start + 32 = 132 (data_start)

        ;Data Start = ReservedSectors + (FATCount * SectorsPerFat) + (RootDirEntries * 32 / BytesPerSector)
        
        mov [data_start], ax            ;   data_start = 132
        sub ax, [root_start]            ;   ax = 132 - 100 = 32

        test dx, dx
        jz .next
        inc ax

    .next:
        mov cl, al
        mov ax, [root_start]
        mov dl, [DriveNumber]
        mov bx, buf
        call disk_read

        xor bx, bx
        mov di, buf

    .search:
        mov si, STAGE2_file
        mov cx, 11
        push di
        repe cmpsb
        pop di
        je .load_stage2

        add di, 32
        inc bx
        cmp bx, [bdbEntriesCount]
        jnz .search

        jmp stage2_notfound

    .load_stage2:
        mov ax, [di + 26]
        mov [stage2_cl], ax

        mov ax, [bdbReserved]
        mov bx, buf
        mov cl, [bdbSectorsPerFAT]
        mov dl, [DriveNumber]
        call disk_read

        mov bx, STAGE2_LOAD_SEG
        mov es, bx

        mov bx, STAGE2_LOAD_OFF

    .load_loop: 
        mov ax, [stage2_cl]

        sub ax, 2
        mul byte [bdbSectorsPerCluster]
        add ax, word [data_start]

        mov cl, 1
        mov dl, [DriveNumber]
        call disk_read

        add bx, [bdbSectorsPerCluster]

        mov ax, [stage2_cl]
        shl ax, 1

        mov si, buf
        add si, ax
        mov ax, [ds:si]

        and ax, START_OF_FILE

    .next_cluster:
        cmp ax, END_OF_FILE
        jae .read_finish

        mov [stage2_cl], ax
        jmp .load_loop

    .read_finish:
        mov dl, [DriveNumber]

        mov ax, STAGE2_LOAD_SEG
        mov ds, ax
        mov es, ax

        jmp STAGE2_LOAD_SEG:STAGE2_LOAD_OFF

        cli
        hlt

section .text
    stage2_notfound:
        mov bx, STAGE2_msg
        call printnl

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
        push ax
        push bx
        push cx
        push dx
        push di

        push cx
        call lba_to_chs
        pop ax

        mov ah, 02h
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

        pop di
        pop dx
        pop cx
        pop bx
        pop ax
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
        mov bx, DISK_ERROR
        call printnl

section .rodata
    DISK_ERROR:     db 'Disk Error', 0
    STAGE2_msg:     db 'boot.bin not found', 0
    STAGE2_file:    db 'BOOT    BIN'

section .data
    STAGE2_LOAD_SEG equ 0x500
    STAGE2_LOAD_OFF equ 0x0

    START_OF_FILE   equ 0x0FFFF
    END_OF_FILE     equ 0x0FFF8

    stage2_cl:      dw 0
    data_start:     dw 0
    root_start:     dw 0

section .bss
    buf:            resb 512