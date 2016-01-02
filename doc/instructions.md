# Riscade Instructions

## Registers

Riscade contains at most 16 8-bit registers, they are:

    r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, fl, sp, s0, s1, s2, pc

`r0` to `r9` are general registers.

`fl` is flag register.

`sp` is stack pointer.

`s0` is data segment pointer;

`s1` is stack segment pointer;

`s2` is code segment pointer.

`pc` is instruction pointer pointing to the next instruction.

They are encoded into 4-bit binary. So `r0` is `0000` and `pc` is `1111`.

When the system is powered on, all registers except `s2` are set to 0, while `s2` is set to `0xff`.

## Memory

Memory can be at most 64 KiB of linear memory space. Memory is segmented into segments of 256 bytes.

Either ROM or RAM can be mapped into each segment of linear memory.

The boot initialization code must be put into address starting from `ff:00`.

## Flag

Bit 7-4: Interrupt identifier

Bit 3: Shift fill-in

Bit 2: Interrupt enabled

Bit 1: Carry indicator, sometimes error indicator

Bit 0: Condition execution

## Instruction format

Each instruction is 8-bit long, the MSB is always condition execution bit. The instruction will only be executed if it is the same as the LSB of register `fl`.

## Instructions

### `x0000000`. NOP: No operation

    pc = pc + 1;

### `c0000001`. HLT: Halt until interrupt

    pc = pc + 1;
    while(1) {
    }

### `c0000010`. IN: Read I/O port

    pc = pc + 1;
    if(c == fl[0]) {
        if(port_ready[r1]) {
            r0 = port[r1];
            fl[1] = 0;
        } else {
            r0 = undefined;
            fl[1] = 1;
        }
    }

### `c0000011`. OUT: Write I/O port

    pc = pc + 1;
    if(c == fl[0]) {
        port[r1] = r0;
    }

### `c0000100`. SHR: Shift right

    pc = pc + 1;
    if(c == fl[0]) {
        if(r1 > 0 && r1 < 8) {
            fl[1] = r0[r1-1];
            if(fl[3]) {
                r0 = ~(~r0 >> r1);
            } else {
                r0 = r0 >> r1;
            }
        } else if(r1 > -8 && r1 < 0) {
            fl[1] = r0[8-(-r1)];
            if(fl[3]) {
                r0 = ~(~r0 << -r1);
            } else {
                r0 = r0 << -r1;
            }
        } else {
            undefined;
        }
    }

### `c0000101`. SHR1: Shift right 1 bit

    pc = pc + 1;
    if(c == fl[0]) {
        fl[1] = r0[0];
        r0 = r0 >> 1;
    }

### `c0000110`. ROR: Rotate right

    pc = pc + 1;
    if(c == fl[0]) {
        if(r1 > 0 && r1 < 8) {
            r0 = r0 >> r1 | r0 << (8-r1);
        } else {
            undefined;
        }
    }

### `c0000111`. ROR1: Rotate right 1 bit

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = r0 >> 1 | r0 << 7;
    }

### `c0001000`. CLI: Set `fl[7:4]` to 0

    pc = pc + 1;
    if(c == fl[0]) {
        fl[7:4] = 0;
    }

### `c00010ff`. CLF: Clear flag

    assert(ff != 00);
    pc = pc + 1;
    if(c == fl[0]) {
        fl[ff] = 0;
    }

### `c0001100`. TCE: Toggle `fl[0]`

    pc = pc + 1;
    if(c == fl[0]) {
        fl[0] = ~fl[0];
    }

### `c00011ff`. STF: Set flag

    assert(ff != 00);
    pc = pc + 1;
    if(c == fl[0]) {
        fl[ff] = 1;
    }


### `c0010000`. TSP: Test `r0`'s LSB

    pc = pc + 1;
    if(c == fl[0]) {
        fl[0] = r0[0];
    }

### `c001rrrr`. SWP: Swap register between `r0` and `rrrr`

    assert(rrrr != a);
    pc = pc + 1;
    if(c == fl[0]) {
        tmp = a;
        a = rrrr;
        rrrr = tmp;
    }

### `c0100000`. TSZ: Test `r0` is not zero

    pc = pc + 1;
    if(c == fl[0]) {
        fl[0] = r0 != 0;
    }

### `c010rrrr`. CPF: Copy register from `rrrr` to `r0`

    assert(rrrr != a);
    pc = pc + 1;
    if(c == fl[0]) {
        r0 = rrrr;
    }

### `ca11000a`. TSS: Test `r0`'s MSB

    pc = pc + 1;
    if(c == fl[0]) {
        fl[0] = a[7];
    }

### `c011rrrr`. CPT: Copy register from `r0` to `rrrr`

    assert(rrrr != a);
    pc = pc + 1;
    if(c == fl[0]) {
        rrrr = 0;
    }

##E `x1000xxx`: Undefined yet

### `c1001000`. TSI: Test `fl[7:4]` is not 0

    pc = pc + 1;
    if(c == fl[0]) {
        fl[0] = fl[7:4] != 0;
    }

### `c10010ff`. TSF: Test flag

    assert(ff != 0);
    pc = pc + 1;
    if(c == fl[0]) {
        fl[0] = fl[ff];
    }

### `c10s1100`. LD: Read a byte from RAM

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = *(s0 << 8 | r1);
    }

Note: `s` can only be `s0` or `s1`.

### `c10s1101`. ST: Write a byte to RAM

    pc = pc + 1;
    if(c == fl[0]) {
        *(s0 << 8 | r1) = r0;
    }

Note: `s` can only be `s0` or `s1`.

### `c1010000`. CLR: Set `r0` to zero

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = 0;
    }

### `c1010001`. NOT: Bit-wise negative

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = ~r0;
    }

### `c1010010`. AND: Bit-wise and

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = r0 & r1;
    }

### `c1010011`. OR: Bit-wise or

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = r0 | r1;
    }

### `c1010100`. XOR: Bit-wise xor

    pc = pc + 1;
    if(c == fl[0]) {
        r0 = r0 ^ r1;
    }

### `c1010101`. DBG: Debugging trap

    pc = pc + 1;
    if(c == fl[0]) {
    #ifdef NDEBUG
        reboot();
    #else
        trigger_breakpoint();
    #endif
    }

### `c1010110`. ADD: Arithmetic add

    pc = pc + 1;
    if(c == fl[0]) {
        fl[1] = (r0 + r1) >> 8;
        r0 = (r0 + r1) & 0xff;
    }

### `c1010111`. SUB: Arithmetic subtract

    pc = pc + 1;
    if(c == fl[0]) {
        fl[1] = (r0 - r1) >> 8;
        r0 = (r0 - r1) & 0xff;
    }

### `c1011000`. MUL: Arithmetic unsigned multiply

    pc = pc + 1;
    if(c == fl[0]) {
        r0_bak = r0;
        r1_bak = r1;
        r0 = (r0_bak * r1_bak) & 0xff;
        r1 = (r0_bak * r1_bak) >> 8;
    }

### `c1011001`. DIV: Arithmetic unsigned divide

    pc = pc + 1;
    if(c == fl[0]) {
        if(r0 == 0 && r1 == 0) {
            fl[1] = 1;
            r0 = 0;
            r1 = 0;
        } else if(r0 != 0 && r1 == 0) {
            fl[1] = 1;
            r0 = 0xff;
            r1 = 0;
        } else {
            r0_bak = r0;
            r1_bak = r1;
            fl[1] = 0;
            r0 = r0 / r1;
            r1 = r0 % r1;
        }
    }

### `c1011010`. INC: Arithmetic add 1

    pc = pc + 1;
    if(c == fl[0]) {
        fl[1] = r0 == 0xff;
        r0 = r0 + 1;
    }

### `c1011011`. DEC: Arithmetic subtract 1

    pc = pc + 1;
    if(c == fl[0]) {
        fl[1] = r0 == 0x00;
        r0 = r0 - 1;
    }

### `c1011100`: POP: Arithmetic add 1 on `sp`

    pc = pc + 1;
    if(c == fl[0]) {
        sp = sp + 1;
    }

### `c1011101`: PUSH: Arithmetic add 1 on `sp`

    pc = pc + 1;
    if(c == fl[0]) {
        sp = sp - 1;
    }

### `c1011110`: LJMP: Long jump

    pc = pc + 1;
    if(c == fl[0]) {
        tmp = r0;
        r0 = pc;
        pc = tmp;
        tmp = s0;
        s0 = s2;
        s2 = tmp;
    }

### `c1011111`: IRET: Return from interrupt handler

    pc = *(s1 << 8 | sp);
    sp = sp + 1;
    s0 = *(s1 << 8 | sp);
    sp = sp + 1;

### `c110nnnn`. IML: Load a immediate number

    pc = pc + 1;
    if(c == fl[0]) {
        r0[3:0] = nnnn;
    }

### `c111nnnn`. IMH: Load a immediate number

    pc = pc + 1;
    if(c == fl[0]) {
        r0[7:4] = nnnn;
    }

## I/O port

Up to 256 ports are available. Byte stream could be read or written through these ports. They can be connected to UART controllers, USB controllers, GPIO ports, or other external devices.

On simulation, port 0, 1, 2, 3 are assigned to `stdin`, `stdout`, `stderr`, and system call controller.

## Interrupt

When interrupt happens and `fl[2]` is 1, an interrupt will fire.

The hardware will automatically:

    sp = sp - 1;
    *(s1 << 8 | sp) = s2;
    sp = sp - 1;
    *(s1 << 8 | sp) = pc;
    fl[7:4] = interrupt_no;
    s2 = 0;
    pc = 0;

The interrupt handler code at address `00:00` should detect the type of the interrupt by checking `fl[7:4]`.

Note that since `fl[0]` may be either 0 or 1, the interrupt handler should detect, save, and later restore it.

# License

This document is licensed under [MIT License](https://github.com/m13253/riscade/blob/master/COPYING)

