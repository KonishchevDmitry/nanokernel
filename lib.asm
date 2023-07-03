println:
    call prints

    mov si, end_of_line
    call prints

prints:
    lodsb
    cmp al, 0
    je return

    ; Print al
    mov ah, 0Eh
    mov bh, 0
    int 10h

    jmp prints

return:
    ret

stop_execution:
    hlt
    jmp stop_execution

end_of_line: db `\r\n`, 0