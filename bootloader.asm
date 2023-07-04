start:
    mov ax, 07C0h
    mov ds, ax

    mov si, bootloader_message
    call println

    mov si, bootloader_size_message
    call prints
    mov ax, end - start
    call printwd
    mov si, end_of_line
    call prints

    call get_kernel_start

    mov si, kernel_loading_message
    call println

    mov cl, 2 ; start sector
    mov al, 1 ; count
    call load_kernel

    mov si, kernel_loaded_message
    call println

    push es
    mov ax, 0
    push ax
    retf

bootloader_message: db "Minikernel bootloader is running...", 0
bootloader_size_message: db "Bootloader size: ", 0

kernel_loading_message: db "Loading nanokernel from disk...", 0
kernel_loaded_message: db "Nanokernel is loaded from disk.", 0

; Calculates kernel load address and stores it in ES
get_kernel_start:
    push ax
    push bx

    mov ax, end
    shr ax, 4

    mov bx, end
    and bx, 0Fh
    cmp bx, 0
    je _get_kernel_start_aligned

    inc ax

    _get_kernel_start_aligned:
        mov bx, ds
        add ax, bx
        mov es, ax

        pop bx
        pop ax
        ret

%include "lib.asm"
end:

; Bootloader magic code
times 510-($-$$) db 0
dw 0xAA55