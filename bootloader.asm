start:
    mov ax, 07C0h
    mov ds, ax

    mov si, _bootloader_message
    call println

    mov si, _bootloader_size_message
    call prints
    mov ax, end - start
    call printwd
    mov si, end_of_line
    call prints

    call get_kernel_start

    mov si, _kernel_loading_message
    call println

    mov cl, 2 ; start sector
    mov al, 1 ; count
    call load_kernel

    mov si, _kernel_loaded_message
    call println

    push es
    mov ax, 0
    push ax
    retf

    _bootloader_message: db "Minikernel bootloader is running...", 0
    _bootloader_size_message: db "Bootloader size: ", 0

    _kernel_loading_message: db "Loading nanokernel from disk...", 0
    _kernel_loaded_message: db "Nanokernel is loaded.", 0

; Calculates kernel load address and stores it in ES
get_kernel_start:
    mov ax, end
    shr ax, 4

    mov cx, end
    and cx, 0Fh
    cmp cx, 0
    je _get_kernel_start_aligned

    inc ax

    _get_kernel_start_aligned:
        mov cx, ds
        add ax, cx
        mov es, ax
        ret

%include "libcore.asm"
end:

; Bootloader magic code + to get a compile error if we suddenly exceed the 512 bytes in size
times 510-($-$$) db 0
dw 0xAA55