ENTRY(main)
OUTPUT_FORMAT("binary")

SECTIONS
{
    .entry : { __entry_start = .;
                *(.entry)
            }

    .text : { *(.text) }
    .data : { *(.data) }
}