bits 16

start:
    mov ax, 0
    mov ds, ax

    mov si, _bootstrap_running_message
    call println

    mov si, _bootstrap_size_message
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

        ; Configure interrupts
        call remap_pic
        lidt [idtr]

        ; Switch to 32 bit code segment
        mov ax, kernel_code_gdte - gdt
        push ax
        mov ax, start_kernel
        push ax
        retf

    _bootstrap_running_message: db "Minikernel bootstrap is running...", 0
    _bootstrap_size_message: db "Bootstrap code size: ", 0

init_video_mode:
    push si

    mov si, _switch_video_mode_message
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
    ret

    _switch_video_mode_message: db "Switching video mode...", 0

remap_pic:
    mov al, 11h
    out 0x20, al ; master: init cmd
    out 0xa0, al ; slave:  init cmd

    mov al, [master_pic_start]
    out 0x21, al ; master: where to start from

    mov al, [slave_pic_start]
    out 0xa1, al ; slave: where to start from

    mov al, 04h
    out 0x21, al ; master: where slave is connected

    mov al, 02h
    out 0xa1, al ; slave: where master is connected

    mov al, 01h
    out 0x21, al ; master: x86 mode
    out 0xa1, al ; slave:  x86 mode

    mov al, 0h
    out 0x21, al ; master: enable all IRQ
    out 0xa1, al ; slave:  enable all IRQ

    ret

%include "libcore.asm"
%include "libmisc.asm"

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

    sti

    call kernel_main
    extern kernel_main

isr:
    push eax
    push ecx
    push edx

    mov ecx, [esp + 12]
    push ecx

    call interrupt_handler
    pop ecx

    cmp cl, [master_pic_start]
	jnge _isr_finish

	mov al, 0x20
	out 0x20, al ; ACK IRQ on master

    cmp cl, [slave_pic_start]
	jnge _isr_finish

	mov al, 0xa0
	out 0x20, al ; ACK IRQ on slave

    _isr_finish:
        pop edx
        pop ecx
        pop eax
        add esp, 4

        sti
        iret

    extern interrupt_handler

%include "gdt.asm"
%include "idt.asm"

end: