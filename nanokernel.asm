; An intermediate tiny kernel which allows to experiment with real mode.
; All labels have relative addresses.

start:
    mov ax, cs
    mov ds, ax

    mov si, kernel_running_message
    call println

    mov si, kernel_size_message
    call prints
    mov ax, end - start
    call printwd
    mov si, end_of_line
    call prints

    mov si, kernel_loading_message
    call println

    ; Load address
    mov ax, 800h ; 0x7c00 + 512 + 512 = 0x8000
    mov es, ax

    mov cl, 3   ; start sector
    mov al, 128 ; read all available
    call load_kernel

    mov si, kernel_loaded_message
    call println

    push es
    mov ax, 0
    push ax
    retf

kernel_running_message: db "Nanokernel is running...", 0
kernel_size_message: db "Kernel size: ", 0

kernel_loading_message: db "Loading minikernel from disk...", 0
kernel_loaded_message: db "Minikernel is loaded.", 0

%include "libcore.asm"
end:

; To get a compile error if we suddenly exceed the 512 bytes in size
times 512-($-$$) db 0