#include <stdarg.h>

#include "lib.h"

static volatile unsigned char* VIDEO = (unsigned char*) 0xB8000;

static const int WIDTH = 80;
static const int HEIGHT = 25;

static int CUR_POS = 0;

static void printc(char c) {
    int max_pos = WIDTH * HEIGHT;

    if(c == '\n') {
        CUR_POS += WIDTH - CUR_POS % WIDTH;
    }

    if(CUR_POS >= max_pos) {
        const int bytes_per_line = WIDTH * 2;

        volatile unsigned char* dst = VIDEO;
        volatile unsigned char* src = dst + bytes_per_line;
        volatile unsigned char* end = dst + bytes_per_line * HEIGHT;

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

static void prints(const char* s) {
    while(*s) {
        printc(*s++);
    }
}

static void println(const char* s) {
    prints(s);
    printc('\n');
}

static void printi(int value) {
    if(value < 0) {
        printc('-');
    } else {
        value = -value;
    }

    int mul = 1;
    while(value / mul <= -10) {
        mul *= 10;
    }

    while(mul > 0) {
        int digit = -(value / mul);
        printc('0' + digit);
        value += digit * mul;
        mul /= 10;
    }
}

static void print_args(const char* s, va_list args) {
    char c;

	while((c = *s++)) {
        if(c != '%') {
            printc(c);
            continue;
        }

        switch((c = *s++)) {
            case 'c':
                printc(va_arg(args, int));
                break;

            case 'd':
                printi(va_arg(args, int));
                break;

            case 's':
                prints(va_arg(args, const char*));
                break;

            case '%':
                printc('%');
                break;

            case '\0':
                return;
                break;

            default:
                printc('%');
                printc(c);
                break;
        }
	}
}

void printf(const char* s, ...) {
    va_list args;
    va_start(args, s);
    print_args(s, args);
    va_end(args);
}

void printlnf(const char* s, ...) {
    va_list args;
    va_start(args, s);
    print_args(s, args);
    va_end(args);
    printc('\n');
}

void stop_execution() {
    while(1) {
        asm("hlt");
    }
}