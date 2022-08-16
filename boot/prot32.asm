[bits 16]
switch_prot32:
    cli
    push ds

    lgdt [gdt_desc]

    mov eax, cr0
    or al, 0x1
    mov cr0, eax

    mov bx, 0x08
    mov ds, bx

    and al, 0xFE
    mov cr0, eax

    pop ds
    sti

    jmp CODE_SEG:init_prot32

[bits 32]
init_prot32:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN32
