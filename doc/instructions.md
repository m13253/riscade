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

// TODO

## External Controlling

// TODO

# License

This document is licensed under [MIT License](https://github.com/m13253/riscade/blob/master/COPYING)

