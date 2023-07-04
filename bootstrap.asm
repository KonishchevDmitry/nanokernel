bits 16

start:
    mov ax, 0
    mov ds, ax

    mov si, bootstrap_running_message
    call println

    mov si, bootstrap_size_message
    call prints
    mov ax, end - start
    call printwd
    mov si, end_of_line
    call prints

    ; BIOS is not available in protected mode, so we initialize VGA to be able to print something
    call init_video_mode

    cli
        ; Configure GDT (actually will take effect only after segment registers update)
        lgdt [gdtr]

        ; Switch to protected mode
        mov eax, cr0
        or eax, 1
        mov cr0, eax

        ; Switch to 32 bit code segment
        mov ax, kernel_code_gdte - gdt
        push ax
        mov ax, start_kernel
        push ax
        retf

bootstrap_running_message: db "Minikernel bootstrap is running...", 0
bootstrap_size_message: db "Bootstrap code size: ", 0

init_video_mode:
    push ax
    push cx
    push si

    mov si, switch_video_mode_message
    call println

    mov cx, 1
    call sleep

    ; Video mode = text mode, 80 x 25, 16 colors
    mov ah, 0h
    mov al, 03h
    int 10h

    ; Disable text cursor (we have no input)
    mov ah, 01h
    mov cx, 2000h
    int 10h

    pop si
    pop cx
    pop ax
    ret

switch_video_mode_message: db "Switching video mode...", 0

%include "lib.asm"

bits 32

start_kernel:
        ; Configure data segments
        mov eax, kernel_data_gdte - gdt
        mov ds, eax
        mov ss, eax

        ; Unused segments
        mov eax, 0
        mov es, eax
        mov fs, eax
        mov gs, eax

    ; FIXME(konishchev)
    ;sti

    call kernel_main

extern kernel_main

%include "gdt.asm"
end: