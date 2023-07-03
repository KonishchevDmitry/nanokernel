; Book - https://github.com/MaaSTaaR/539kernel
; Interrupt reference - http://www.ctyme.com/intr/int.htm
; Instruction reference - https://www.felixcloutier.com/x86/

start:
    mov ax, 07C0h
    mov ds, ax

    mov si, bootloader_message
    call println

    call load_kernel
    jmp 0900h:0000

load_kernel:
    mov si, kernel_loading_message
    call println

    mov ax, 0900h
    mov es, ax
    mov bx, 0

    mov ah, 02h ; read sectors to es:bx
    mov al, 1   ; count
    mov ch, 0   ; track number
    mov cl, 2   ; sector number (starts from 1 which is bootloader)
    mov dh, 0   ; head number
    mov dl, 80h ; hard disk
    int 13h
    jc on_kernel_load_error

    mov si, kernel_loaded_message
    call println

    ret

on_kernel_load_error:
    mov si, kernel_load_error_message
    call println
    jmp stop_execution

bootloader_message: db "Minikernel bootloader is running...", 0
kernel_loading_message: db "Loading the kernel from disk...", 0
kernel_load_error_message: db "Failed to load the kernel from disk.", 0
kernel_loaded_message: db "The .", 0

%include "lib.asm"

; Bootloader magic code
times 510-($-$$) db 0
dw 0xAA55