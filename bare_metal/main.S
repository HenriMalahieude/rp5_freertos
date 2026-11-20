#define GPIO_BASE 16

#define IO_BANK0   0x1F000D0000
#define SYS_RIO0   0x1F000E0000
#define PADS_BANK0 0x1F000F0000

#define XOR_OFFSET 0x1000
#define SET_OFFSET 0x2000
#define CLR_OFFSET 0x3000

#define RIO_OUT 0x00
#define RIO_OE  0x04

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

    //4a. Wake up all the other cores
    cmp w1, #GPIO_BASE
    b.ne 1f
    bl core_poke
1:

    //5. loop forever
    ldr x0, =(SYS_RIO0 + XOR_OFFSET + RIO_OUT)

loop:
    str w2, [x0]
    ldr x3, =0x800000
2:  subs x3, x3, #1
    b.ne 2b
    b loop

.size _start, .-_start

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
    lsl x1, x19, #8
    adr x2, _start
    mov x3, #0
    smc #0          //poke the core
    add w19, w19, #1
    cmp w19, #4
    b.lt 1b

    mov x1, x20
    mov x2, x21
    mov x3, x22
    ret
.size core_poke, .-core_poke
