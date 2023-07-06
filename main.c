#include "lib.h"

static void on_timer_interrupt() {
    const int frequency = 18;
    const int watchdog_period = 5;

    static unsigned long interrupts;
    interrupts++;

    if(interrupts % frequency == 0 && interrupts / frequency % watchdog_period == 0) {
        printlnf("We're still alive.");
    }
}

void interrupt_handler(int irq) {
    switch(irq) {
        case 32:
            on_timer_interrupt();
            break;

        default:
            printlnf("Got interrupt: %d.", irq);
            break;
    }
}

void kernel_main() {
    printlnf("Minikernel is running...");
    stop_execution();
}