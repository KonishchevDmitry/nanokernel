start:
    mov ax, cs
    mov ds, ax

    mov si, kernel_running_message
    call println

    jmp stop_execution

kernel_running_message: db "Minikernel is running...", 0

%include "lib.asm"