; Sleeps for the specified number of seconds (CX)
; A very naive implementation which relies on the fact that we receive ~18.2 timer iterrupts per second
sleep:
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
        ret