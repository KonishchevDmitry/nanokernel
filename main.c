#include "lib.h"

static volatile unsigned long TIMER_INTERRUPTS;

void interrupt_handler(int irq) {
    switch(irq) {
        case 32:
            TIMER_INTERRUPTS++;
            break;

        default:
            printlnf("Got interrupt: %d.", irq);
            break;
    }
}

void kernel_main() {
    printlnf("Minikernel is running...");

    const int approximate_timer_frequency = 18;
    const int watchdog_period = 5;
    unsigned long last_watchdog_uptime = 0;

    while(1) {
        unsigned long uptime = TIMER_INTERRUPTS / approximate_timer_frequency;

        if(uptime - last_watchdog_uptime >= watchdog_period) {
            printlnf("We're still alive (~%ds uptime).", uptime);
            last_watchdog_uptime = uptime;
        }

        asm("hlt");
    }
}