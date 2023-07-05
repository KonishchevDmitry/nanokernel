; Book - https://github.com/MaaSTaaR/539kernel
; Interrupt reference - http://www.ctyme.com/intr/int.htm
; Instruction reference - https://www.felixcloutier.com/x86/
; C calling convention - https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl

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
    push si

    _prints_loop:
        lodsb
        cmp al, 0
        je _prints_ret

        call printc
        jmp _prints_loop

    _prints_ret:
        pop si
        ret

; Prints character in AL
printc:
    push bx

    mov ah, 0Eh
    mov bh, 0
    int 10h

    pop bx
    ret

; Prints AX
printw:
    push bx
    mov bl, al

    mov al, ah
    call printb

    mov al, bl
    call printb

    pop bx
    ret

; Prints AL
printb:
    push bx
    mov bl, al

    shr al, 4
    call _print_half_of_byte

    mov al, bl
    and al, 0xF
    call _print_half_of_byte

    pop bx
    ret

_print_half_of_byte:
    cmp al, 10
    jb _format_half_of_byte
    add al, 7

    _format_half_of_byte:
        add al, '0'
        call printc
        ret

; Prints AX in decimal
printwd:
    push bx

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
        pop bx
        ret

; Loads kernel from disk:
; * CL - start sector (starts from 1 which is bootloader)
; * AL - number of sectors. If 128 is specified, reads all available sectors, but at least one.
; * ES - destination
load_kernel:
    push bx
    push si

    mov ah, 0
    mov si, ax

    mov ah, 02h ; read sectors to es:bx
    mov dl, 80h ; hard disk
    mov ch, 0   ; track number
    mov dh, 0   ; head number
    mov bx, 0
    int 13h
    jc _load_kernel_read_error

    _load_kernel_success:
        pop si
        pop bx
        ret

    _load_kernel_read_error:
        mov bx, ax

        cmp si, 128 ; our magic number to read all available sectors
        jne _load_kernel_error

        cmp bh, 0x0C ; invalid sector
        jne _load_kernel_error

        cmp bl, 0 ; zero sectors have been read
        je _load_kernel_error

        mov ah, 0
        mov al, bl
        call printwd
        mov si, _kernel_sectors_read_message
        call println

        jmp _load_kernel_success

    _load_kernel_error:
        mov si, _kernel_load_error_message
        call prints

        mov al, bh
        call printb

        mov si, end_of_line
        call prints

        jmp stop_execution

_kernel_load_error_message: db "Failed to load the kernel from disk: ", 0
_kernel_sectors_read_message: db " sectors have been read.", 0

stop_execution:
    mov si, _stop_execution_message
    call println

    _stop_execution_loop:
        hlt
        jmp _stop_execution_loop

_stop_execution_message: db "Stopping the execution.", 0

end_of_line: db `\r\n`, 0