bits 16

section .fsjump
    jmp short vbrmain
    nop

section .fsheaders
    ;BDB
    _oem: db 'MSWIN4.1'
    _bytes_per_sect:    dw 512
    _sect_per_clust:    db 2
    _reserved_sect:     dw 1
    _FAT_count:         db 2
    _entry_count:       dw 0x0E0
    _total_sect:        dw 2880
    _media:             db 0x0F0
    _sect_per_FAT:      dw 9
    _sect_per_track:    dw 18
    _heads:             dw 2
    _hidden_sect:       dd 0
    _large_sect_count:  dd 0

    ;EBR
    _drive_num: db 0
    _ntflags: dw 0
    _signature: db 0x29
    _vol_id: db 11h, 11h, 11h, 11h
    _volume_label: db 'LOCAL DISK '
    _sys_id: db 'FAT12   '

section .entry
    global vbrmain

    vbrmain:
        xor ax, ax
        mov ds, ax
        mov ss, ax

        mov bp, 0x9c00
        mov sp, bp

        push es
        push word .after
        retf

    .after:
        mov [_drive_num], dl

        ;   Read Disk
        push es
        mov ah, 08h
        int 13h
        jc disk_error
        pop es

        and cl, 0x3f
        xor ch, ch
        mov [_sect_per_track], cx

        inc dh
        mov [_heads], dh

        ; Root LBA
        mov ax, [_sect_per_FAT]
        mov bl, [_FAT_count]
        xor bh, bh
        mul bx                          ;   ax = 9 * 2
        add ax, [_reserved_sect]        ;   ax = ax + 1

        mov bx, ax                      ;   bx = 19
        push ax                         ;   ax = 19

        mov ax, [_entry_count]          ;   ax = 32
        shl ax, 5                       ;   ax = 32 * 224 = 7168  

        xor dx, dx                      ;   dx: remainder of the division, dx = 0
        div word [_bytes_per_sect]      ;   ax = ax / 512 = 14      
        add ax, bx                      ;   ax = ax + bx = 33
        mov [data_start], ax            ;   data_start = 33

        ;calculate Root size
        sub ax, bx                      ;   ax = 33 - 19

        test dx, dx                     ;   check remainer
        jz .next                        ;   jump if 0
        inc ax                          ;   add 1 to ax

    .next:
        mov cl, al
        pop ax
        mov dl, [_drive_num]
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
        cmp bx, [_entry_count]
        jl .search

        jmp stage2_notfound

    .load_stage2:
        mov ax, [di + 26]
        mov [stage2_cl], ax

        mov ax, [_reserved_sect]
        mov bx, buf
        mov cl, [_sect_per_FAT]
        mov dl, [_drive_num]
        call disk_read

        mov bx, STAGE2_LOAD_SEG
        mov es, bx

        mov bx, STAGE2_LOAD_OFF

    .load_loop: 
        mov ax, [stage2_cl]
        
        sub ax, 2
        mul byte [_sect_per_clust]
        add ax, [data_start]

        mov cl, 1
        mov dl, [_drive_num]
        call disk_read

        add bx, [_bytes_per_sect]

        mov ax, [stage2_cl]
        mov cx, 3
        mul cx

        mov cx, 2
        div cx

        mov si, buf
        add si, ax
        mov ax, [ds:si]

        or dx, dx
        jz .even

    .odd:
        shr ax, 4
        jmp .next_cluster

    .even:
        and ax, 0x0fff

    .next_cluster:
        cmp ax, 0x0ff8
        jae .read_finish

        mov [stage2_cl], ax
        jmp .load_loop

    .read_finish:
        mov dl, [_drive_num]

        mov ax, STAGE2_LOAD_SEG
        mov ds, ax
        mov es, ax

        jmp STAGE2_LOAD_SEG:STAGE2_LOAD_OFF

        cli
        hlt

section .text
    reboot:
        jmp 0FFFFh:0

    .halt:
        cli
        hlt

    stage2_notfound:
        mov bx, STAGE2_msg
        call printnl

        jmp reboot

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
        div word [_sect_per_track]          ; ax = LBA / SectorsPerTrack
                                            ; dx = LBA % SectorsPerTrack

        inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
        mov cx, dx                          ; cx = sector

        xor dx, dx                          ; dx = 0
        div word [_heads]                   ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
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

        push cx
        call lba_to_chs
        pop ax

        mov ah, 02h

    .read:
        pusha
        stc

        int 13h
        jnc .done

        popa
        call disk_reset

    .fail:
        jmp disk_error

    .done:
        popa

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
        mov bx, DISK_ERROR
        call printnl

        jmp reboot

section .rodata
    DISK_ERROR: db 'Disk Error', 0
    STAGE2_msg: db 'boot.bin not found', 0
    STAGE2_file: db 'BOOT    BIN'

section .data
    STAGE2_LOAD_OFF equ 0x2000
    STAGE2_LOAD_SEG equ 0x0

    stage2_cl:      dw 0
    data_start:     dw 0

    root_lba:       dw 0
    root_size:      dw 0

;section .bios_footer
;    times 510-($-$$) db 0
;    dw 0xaa55

section .bss
    buf: resb 512