start:
    mov ax, 07C0h
    mov ds, ax

    mov si, bootloader_message
    call println

    mov si, bootloader_size_message
    call prints
    mov ax, end
    call printwd
    mov si, end_of_line
    call prints

    call get_kernel_start
    call load_kernel

    push es
    mov ax, 0
    push ax
    retf

bootloader_message: db "Minikernel bootloader is running...", 0
bootloader_size_message: db "Bootloader size: ", 0

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

; Loads kernel from disk to ES
load_kernel:
    push bx
    push si

    mov si, kernel_loading_message
    call println

    mov ah, 02h ; read sectors to es:bx
    mov dl, 80h ; hard disk
    mov ch, 0   ; track number
    mov cl, 2   ; sector number (starts from 1 which is bootloader)
    mov dh, 0   ; head number
    mov al, 1   ; count
    mov bx, 0
    int 13h
    jc _load_kernel_error

    mov si, kernel_loaded_message
    call println

    pop si
    pop bx
    ret

    _load_kernel_error:
        mov si, kernel_load_error_message
        call println
        jmp stop_execution

kernel_loading_message: db "Loading the kernel from disk...", 0
kernel_loaded_message: db "The kernel is loaded from disk.", 0
kernel_load_error_message: db "Failed to load the kernel from disk.", 0

%include "lib.asm"
end:

; Bootloader magic code
times 510-($-$$) db 0
dw 0xAA55