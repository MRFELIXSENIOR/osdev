[org 0x7c00]
[bits 16]
KOFFSET equ 0x1000

jmp short start
nop

;BDB
_oem: db 'MSWIN4.1'
_bytes_per_sect: dw 512
_sect_per_clust: db 2
_reserved_sect_count: dw 1
_FAT_count: db 2
_dir_entry_count: dw 0x0E0
_total_sect: dw 2880
_media_desctor_type: db 0x0F0
_sect_per_track: dw 18
_heads: dw 2
_hidden_sect: dd 0
_large_sect_count dd 0

;EBR
_sect_per_fat: dw 9
_flags: dw 0
_FAT_ver: dw 0
_root_clust_num: dd 2
_fsinfo_sect_num: dw 3
_backup_boot_sect: dw 0

_reserved_bytes: dd 0, 0, 0

_drive_num: db 0
_WINNT_FLAG: db 0

_signature: db 0x29
_vol_id: db 0x04, 0x51, 0x83, 0x40
_vol_label: db 'HOBBYOS DRV'
_sys_id: db 'FAT32   '

start:
    jmp main

main:
    xor ax, ax
    mov ds, ax
    mov ss, ax

    mov bp, 0x9c00
    mov sp, bp

    mov [_drive_num], dl

    mov bx, MSG16_RM
    call print16
    call print16_nl

    mov ah, 0x00
    mov al, 0x13
    int 0x10

    call KLOAD
    call switch_prot32

    jmp $

%include "boot/disk.asm"
%include "boot/bsprint.asm"
%include "boot/bsprint_hex.asm"
%include "boot/gdt32.asm"
%include "boot/prot32.asm"
;%include "boot/a20line.asm"

[bits 16]
KLOAD:
    mov bx, MSG_KLOAD
    call print16
    call print16_nl

    mov bx, KOFFSET
    mov dh, 15
    mov dl, [_drive_num]
    call disk_load
    ret

[bits 32]
BEGIN32:
    call KOFFSET
    jmp $

MSG16_RM: db "BOOTING", 0
MSG_KLOAD: db "LOADING KERNEL", 0
PRESSKEY: db "Press Any Key To Reboot..", 0

key_reboot:
    mov ah, 0
    int 0x16

    mov bx, PRESSKEY
    call print16
    call print16_nl

    jmp 0FFFFh:0


times 510 - ($-$$) db 0
dw 0xaa55

;fsinfo FAT32
_lead_signature: dd 0x41615252
;_reserved_bytes:
times 480 - 1 db 0
_second_signature: dd 0x61417272
_free_cluster: dd 0
_findcl_indicator: dd 1
_reserved: dd 0, 0, 0
dd 0xAA550000
