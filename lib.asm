; Book - https://github.com/MaaSTaaR/539kernel
; Interrupt reference - http://www.ctyme.com/intr/int.htm
; Instruction reference - https://www.felixcloutier.com/x86/

; Prints string in SI with line ending
println:
    call prints

    push si
        mov si, end_of_line
        call prints
    pop si

    ret

; Prints string in SI
prints:
    push ax

    _prints_loop:
        lodsb
        cmp al, 0
        je _prints_ret

        call printc
        jmp _prints_loop

    _prints_ret:
        pop ax
        ret

; Prints character in AL
printc:
    push ax
    push bx

    mov ah, 0Eh
    mov bh, 0
    int 10h

    pop bx
    pop ax
    ret

; Prints AX
printw:
    push ax
        mov al, ah
        call printb
    pop ax

    call printb
    ret

; Prints AL
printb:
    push ax
        shr al, 4
        call _print_half_of_byte
    pop ax

    push ax
        and al, 0Fh
        call _print_half_of_byte
    pop ax

    ret

_print_half_of_byte:
    push ax

    cmp al, 10
    jb _format_half_of_byte
    add al, 7

    _format_half_of_byte:
        add al, '0'
        call printc

        pop ax
        ret

; Prints AX in decimal
printwd:
    push ax
    push bx
    push cx
    push dx

    mov cx, 0

    cmp ax, 0
    je _printwd_zero

    _printwd_backward_loop:
        cmp ax, 0
        je _printwd_forward_loop

        mov dx, 0
        mov bx, 10
        div bx

        push dx
        inc cx
        jmp _printwd_backward_loop

    _printwd_zero:
        push ax
        inc cx

    _printwd_forward_loop:
        cmp cx, 0
        je _printwd_ret

        dec cx
        pop ax
        add ax, '0'

        call printc
        jmp _printwd_forward_loop

    _printwd_ret:
        pop dx
        pop cx
        pop bx
        pop ax
        ret

; Loads kernel from disk:
; * CL - start sector (starts from 1 which is bootloader)
; * AL - number of sectors
; * ES - destination
load_kernel:
    push ax
    push bx
    push cx
    push dx

    mov ah, 02h ; read sectors to es:bx
    mov dl, 80h ; hard disk
    mov ch, 0   ; track number
    mov dh, 0   ; head number
    mov bx, 0
    int 13h
    jc _load_kernel_error

    pop dx
    pop cx
    pop bx
    pop ax
    ret

    _load_kernel_error:
        mov si, kernel_load_error_message
        call println
        jmp stop_execution

kernel_load_error_message: db "Failed to load the kernel from disk.", 0

; Sleeps for the specified number of seconds (CX)
; A very naive implementation which relies on the fact that we receive ~18.2 timer iterrupts per second
sleep:
    push ax
    push cx
    push dx

    mov ax, 18
    mul cx

    _sleep_iteration:
        cmp ax, 0
        je _sleep_zero_ax

        dec ax

    _sleep:
        hlt
        jmp _sleep_iteration

    _sleep_zero_ax:
        cmp dx, 0
        je _sleep_finish

        dec dx
        mov ax, 0xff
        jmp _sleep

    _sleep_finish:
        pop dx
        pop cx
        pop ax
        ret

stop_execution:
    mov si, stop_execution_message
    call println

    _stop_execution_loop:
        hlt
        jmp _stop_execution_loop

stop_execution_message: db "Stopping the execution.", 0

end_of_line: db `\r\n`, 0