//Global defines

/// For the start blinking code
#define GPIO_BASE 16

#define IO_BANK0   0x1F000D0000
#define SYS_RIO0   0x1F000E0000
#define PADS_BANK0 0x1F000F0000

#define XOR_OFFSET 0x1000
#define SET_OFFSET 0x2000
#define CLR_OFFSET 0x3000

#define RIO_OUT 0x00
#define RIO_OE  0x04

/// For the status led
#define GIO_AON    0x107D517C00
#define GIO_ODEN   0x00
#define GIO_DATA   0x04
#define GIO_IODIR  0x08
#define ACT        9

//The normal code that all cores will run
.section .text
.type _start, %function
.global _start
_start:
    //0. Cores 0-3 each get their own gpio pin 0-3
    mrs x1, mpidr_el1
    ubfx w1, w1, #8, #8 //Extract CPU_ID

    add w1, w1, #GPIO_BASE //GPIO_PINS 16, 17, 18, 19, per core
    mov w0, #1
    lsl w2, w0, w1 //(1 << GPIO_PIN)

//We have powered on
    cmp w1, #GPIO_BASE
    b.ne 1f
    mov w9, #2
    bl blink_status
1:

    //1. Pad control: DRIVE=4mA, IE=0, OD=0, no pulls
    ldr x0, =(PADS_BANK0 + 0x04)
    mov x4, #4
    mul x3, x1, x4 //GPIO_PIN * 4
    add x0, x0, x3

    mov w4, #0x10
    str w4, [x0]

    //2. Function select: FUNCSEL=5 (sys_rio), all overrides cleared
    ldr x0, =(IO_BANK0 + 0x04)
    mov x4, #8
    mul x3, x1, x4 //GPIO_PIN * 8
    add x0, x0, x3

    mov w4, #5
    str w4, [x0]

    //3. Enable output driver (pin now drives low)
    ldr x0, =(SYS_RIO0 + SET_OFFSET + RIO_OE)
    str w2, [x0]

    //4. Drive high, signal boot
    ldr x0, =(SYS_RIO0 + SET_OFFSET + RIO_OUT)
    str w2, [x0]

//We are about to wake the other cores up
    cmp w1, #GPIO_BASE
    b.ne 1f
    mov w9, #4
    bl blink_status
1:

    //4a. Wake up all the other cores
    cmp w1, #GPIO_BASE
    b.ne 1f
    bl core_poke
1:

    //5. loop forever
    ldr x0, =(SYS_RIO0 + XOR_OFFSET + RIO_OUT)

loop:
    str w2, [x0]
    ldr x3, =0x100000
2:  subs x3, x3, #1
    b.ne 2b
    b loop

.size _start, .-_start

//Code for core 0 to wake up core 1-3
.type core_poke, %function
core_poke:
    //Init
    mov x19, #1
    mov x20, x1
    mov x21, x2
    mov x22, x3

    //Send poke
1:  mov w0, #0x0003
    movk w0, #0xC400, lsl #16
    lsl x1, x19, #8 //which core to wake
    adr x2, _start  //send them to _start
    mov x3, #0      //their context (sent to x0) is 0
    smc #0          //poke the core
    add w19, w19, #1
    cmp w19, #4
    b.lt 1b

    mov x1, x20
    mov x2, x21
    mov x3, x22
    ret
.size core_poke, .-core_poke

// blinks the 'stat' led (otherwise known as ACT by the system)
//        the 'stat' led doesn't require RP1/PCIe to be initialized
// in      = {w9: blink count}
// out     = {}
// clobber = {x9-x13}
.type blink_status, %function
blink_status:
    //Init
    ldr x10, =GIO_AON
    mov w11, #(1 << ACT)

    ldr w12, [x10, #GIO_ODEN]
    bic w12, w12, w11           //open-drain disable
    str w12, [x10, #GIO_ODEN]

    ldr w12, [x10, #GIO_IODIR]
    bic w12, w12, w11           //0 = output direction
    str w12, [x10, #GIO_IODIR]

1:  ldr w12, [x10, #GIO_DATA]
    orr w12, w12, w11           //disable LED
    str w12, [x10, #GIO_DATA]

    ldr x13, =0x200000
2:  subs x13, x13, #1
    b.ne 2b                     //off-duration delay

    ldr w12, [x10, #GIO_DATA]
    bic w12, w12, w11           //active-low LED (enable)
    str w12, [x10, #GIO_DATA]

    ldr x13, =0x200000
3:  subs x13, x13, #1
    b.ne 3b                     //on-duration delay

    //Have we completed the count?
    subs w9, w9, #1
    b.ne 1b

    ldr x13, =0x800000
4:  subs x13, x13, #1
    b.ne 4b                     //longer pause for if this is called again
    ret

.size blink_status, .-blink_status
