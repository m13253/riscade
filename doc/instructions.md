# Riscade Instructions

## Registers

Riscade contains at most 16 8-bit registers, they are:

    r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, fl, sp, s0, s1, sc, pc

`r0` to `r9` are general registers.

`fl` is flag register.

`sp` is stack pointer.

`s0` and `s1` are data segment pointer.

`sc` is code segment pointer.

`pc` is instruction pointer pointing to the next instruction.

They are encoded into 

## Memory

Memory can be at most 64 KiB of RAM. Memory is segmented into segments of 256 bytes.

## Flag

## Instruction format

Each instruction is 8-bit long, the MSB is always condition execution bit. The instruction will only be executed if it is the same as the MSB of register `fl`.

## Instructions

### 0000000. test

    7 6 5 4 3 2 1 0
    C 0 0 0 0 0 0 0

    pc = pc+1;
    if(C == fl[7]) {
        if(r0 == 0) {
            fl = 0;
        } else {
            fl = 255;
        }
    }

### 000. mov

    7 6 5 4 3 2 1 0
    C 0 0 0 [ reg ]

    pc = pc+1;
    if(C == fl[7]) {
        reg = r0;
    }

Note that `reg` can not be `r0`, because `r0` is defined as `test`.

### 001. swp

    7 6 5 4 3 2 1 0
    C 0 0 1 [ reg ]

    pc = pc+1;
    if(C == fl[7]) {
        temp = r0;
        r0 = reg;
        reg = r0;
    }

### 010. shl

    7 6 5 4 3 2 1 0
    C 0 1 0 [ reg ]

    pc = pc+1;
    if(C == fl[7]) {
        if(reg >= 0) {
            r0 = r0 << reg;
        } else {
            r0 = r0 >> -reg;
        }
    }

### 011. imm

    7 6 5 4 3 2 1 0
    C 0 1 1 [ imm ]

    if(C == fl[7]) {
        if(C == 0) {
            r0[3:0] = (*pc)[3:0];
        } else {
            r0[7:4] = (*pc)[3:0];
        }
    }
    pc = pc+1;

### 100. nand

    7 6 5 4 3 2 1 0
    C 1 0 0 [ reg ]

    pc = pc+1;
    if(C == fl[7]) {
        r0 = ~(r0 & reg);
    }

### 10101. ext

    7 6 5 4 3 2 1 0
    C 1 0 1 0 1 [f]

See the section `External controlling`.

### 10110. dec

    7 6 5 4 3 2 1 0
    C 1 0 1 1 0 [r]

    pc = pc+1;
    if(C == fl[7]) {
        r = r-1;
    }

Since `r` is only 2-bit long, only `r0`, `r1`, `r2`, `r3` could be used.

### 10111. inc

    7 6 5 4 3 2 1 0
    C 1 0 1 1 1 [r]

    pc = pc+1;
    if(C == fl[7]) {
        r = r+1;
    }

Since `r` is only 2-bit long, only `r0`, `r1`, `r2`, `r3` could be used.

### 110. st

    7 6 5 4 3 2 1 0
    C 1 1 0[s][reg]

    pc = pc+1;
    if(C == fl[7]) {
        if(s == 0) {
            r0 = *(s0<<8 | reg);
        } else {
            r0 = *(s1<<8 | reg);
        }
    }

### 111. ld

    7 6 5 4 3 2 1 0
    C 1 1 0[s][reg]

    pc = pc+1;
    if(C == fl[7]) {
        if(s == 0) {
            *(s0<<8 | reg) = r0;
        } else {
            *(s1<<8 | reg) = r0;
        }
    }

## External Controlling

// TODO

# License

This document is licensed under [MIT License](https://github.com/m13253/riscade/blob/master/COPYING)

