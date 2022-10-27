ENTRY(main)
OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x7C00;
    .fsjump : { *(.fsjump) }
    .fsheaders : { *(.fsheaders) }

    .entry : { __entry_start = .;
                *(.entry)
            }

    .text : { *(.text) }
    .data : { *(.data) }
    .rodata : { *(.rodata) }
    
    .bios_footer 0x7DFE : { SHORT(0xAA55) }

    .bss : { *(.bss) }
}