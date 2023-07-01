; Book - https://github.com/MaaSTaaR/539kernel
; Interrupt reference - http://www.ctyme.com/intr/int.htm
; Instruction reference - https://www.felixcloutier.com/x86/

start:
    mov ax, 07C0h
    mov ds, ax

    mov si, bootloader_message
    call print_string

    call load_kernel
    jmp 0900h:0000

print_string:
    lodsb
    cmp al, 0
    je finish_printing

    ; Print al
    mov ah, 0Eh
    mov bh, 0
    int 10h

    jmp print_string

finish_printing:
    ; Get current cursor position -> dh:dl
    mov ah, 03h
    mov bh, 0
    int 10h

    ; Move cursor to the new line
    mov ah, 02h
    inc dh
    mov dl, 0
    int 10h

    ret

load_kernel:
    mov si, kernel_loading_message
    call print_string

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
    ret

on_kernel_load_error:
    mov si, kernel_load_error_message
    call print_string
    jmp stop_execution

stop_execution:
    hlt
    jmp stop_execution

bootloader_message: db "Minikernel bootloader is running...", 0
kernel_loading_message: db "Loading the kernel...", 0
kernel_load_error_message: db "Failed to load the kernel from disk.", 0

; Bootloader magic code
times 510-($-$$) db 0
dw 0xAA55