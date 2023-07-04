bits 16

start:
    mov ax, 0
    mov ds, ax

    mov si, bootstrap_running_message
    call println

    mov si, bootstrap_size_message
    call prints
    mov ax, (end - start)
    call printwd
    mov si, end_of_line
    call prints

    jmp stop_execution

bootstrap_running_message: db "Minikernel bootstrap is running...", 0
bootstrap_size_message: db "Bootstrap code size: ", 0

%include "lib.asm"
end: