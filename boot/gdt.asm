_gdt: ; don't remove the labels, they're needed to compute sizes and jumps
    dq 0

gdt_code: 
    dw 0FFFFh    ; segment length, bits 0-15
    dw 0         ; segment base, bits 0-15
    db 0         ; segment base, bits 16-23
    db 10011010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0         ; segment base, bits 24-31

gdt_data:
    dw 0FFFFh
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

gdt_code16:
    dw 0FFFFh
    dw 0
    db 0
    db 10011010b
    db 00001111b
    db 0

gdt_data16:
    dw 0FFFFh
    dw 0
    db 0
    db 10010010b
    db 00001111b
    db 0

gdt_desc:
    dw gdt_desc - _gdt - 1
    dd _gdt


CODE_SEG    equ gdt_code    - _gdt
DATA_SEG    equ gdt_data    - _gdt

CODE_SEG16  equ gdt_code16  - _gdt
DATA_SEG16  equ gdt_data16  - _gdt