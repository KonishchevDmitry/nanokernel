start:
    mov ax, cs
    mov ds, ax

    mov si, kernel_running_message
    call println

    mov si, kernel_size_message
    call prints
    mov ax, end
    call printwd
    mov si, end_of_line
    call prints

    jmp stop_execution

kernel_running_message: db "Minikernel is running...", 0
kernel_size_message: db "Kernel size: ", 0

%include "lib.asm"
end: