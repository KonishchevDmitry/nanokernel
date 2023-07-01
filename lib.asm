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

stop_execution:
    hlt
    jmp stop_execution