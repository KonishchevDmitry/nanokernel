start:
    mov ax, cs
    mov ds, ax

    mov si, kernel_loaded_message
    call print_string

    jmp stop_execution

kernel_loaded_message: db "The kernel is loaded.", 0

%include "lib.asm"