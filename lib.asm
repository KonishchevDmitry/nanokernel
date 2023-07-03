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
        call print_half_of_byte
    pop ax

    push ax
        and al, 0Fh
        call print_half_of_byte
    pop ax

    ret

print_half_of_byte:
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

stop_execution:
    mov si, stop_execution_message
    call println

    _stop_execution_loop:
        hlt
        jmp _stop_execution_loop

stop_execution_message: db "Stopping the execution.", 0

end_of_line: db `\r\n`, 0