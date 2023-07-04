#include "lib.h"

static volatile unsigned char* VIDEO = (unsigned char*) 0xB8000;

static const int WIDTH = 80;
static const int HEIGHT = 25;

static int CUR_POS = 0;

void println(char* s) {
    prints(s);
    printc('\n');
}

void prints(char* s) {
    while(*s) {
        printc(*s++);
    }
}

void printc(char c) {
    int max_pos = WIDTH * HEIGHT;

    if(c == '\n') {
        CUR_POS += WIDTH - CUR_POS % WIDTH;
    }

    if(CUR_POS >= max_pos) {
        const int bytes_per_line = WIDTH * 2;

        unsigned char* dst = VIDEO;
        unsigned char* src = dst + bytes_per_line;
        unsigned char* end = dst + bytes_per_line * HEIGHT;

        while(src != end) {
            *dst++ = *src++;
        }

        while(dst != end) {
            *dst++ = 0;
        }

        CUR_POS -= WIDTH;
    }

    if(c != '\n') {
        int char_pos = CUR_POS++ * 2;
        int color_pos = char_pos + 1;

        VIDEO[char_pos] = c;
        VIDEO[color_pos] = 0;
    }
}

void stop_execution() {
    while(1) {
        asm("hlt");
    }
}