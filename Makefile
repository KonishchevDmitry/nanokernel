.PHONY: all clean

all: disk.img
	qemu-system-x86_64 -s -drive file=disk.img,format=raw -display curses

disk.img: bootloader.o kernel.o
	cat bootloader.o kernel.o > disk.img

%.o: %.asm lib.asm
	nasm -f bin $< -o $@

kernel.o: gdt.asm

gdt.asm:
	./generate-gdt

clean:
	rm -f *.o disk.img