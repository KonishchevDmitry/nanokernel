volatile unsigned char *video = (unsigned char *) 0xB8000;

void kernel_main() {
    video[0] = 'O';
    video[1] = 15;
    video[2] = 'K';
    video[3] = 15;

	while(1)
        ;
}