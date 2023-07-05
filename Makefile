.PHONY: all clean

all: disk.img
	qemu-system-x86_64 -s -drive file=disk.img,format=raw -display curses

disk.img: bootloader.bin nanokernel.bin minikernel.bin
	dd seek=0 count=1 if=bootloader.bin of=disk.img
	dd seek=1 count=1 if=nanokernel.bin of=disk.img
	dd seek=2         if=minikernel.bin of=disk.img

bootloader.bin: bootloader.asm libcore.asm
	nasm -f bin $< -o $@

nanokernel.bin: nanokernel.asm libcore.asm
	nasm -f bin $< -o $@

minikernel.bin: minikernel.elf
	objcopy -O binary $< $@

minikernel.elf: linker.ld bootstrap.o main.o lib.o
	ld -m elf_i386 -T linker.ld bootstrap.o main.o lib.o -o $@

bootstrap.o: bootstrap.asm gdt.asm idt.asm libcore.asm libmisc.asm
	nasm -f elf32 $< -o $@

%.o: %.c lib.h
	gcc -Wall -m32 -c -ffreestanding -fno-asynchronous-unwind-tables -fno-pie $< -o $@

gdt.asm: generate-gdt
	./generate-gdt

idt.asm: generate-idt
	./generate-idt

clean:
	rm -f *.bin *.o *.elf *.img