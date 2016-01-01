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

Bit 0: Condition execution

Bit 1: Carry

Bit 2: Interrupt enabled

Bit 3: Interrupt activated

## Instruction format

Each instruction is 8-bit long, the LSB is always condition execution bit. The instruction will only be executed if it is the same as the LSB of register `fl`.

## Instructions

### x0000000. NOP: No operation

### c0000001. SAR

### c0000010. SHL

### c0000011. SHR

### c0000100. EXT: External control

### c0000101. SAR1

### c0000110. SHL1

### c0000111. SHR1

### c0010000. TSP: Test parity

### c001rrrr. SWP: Swap register between `r0`

### c0100000. TSZ: Test zero

### c010rrrr. CPT: Copy register to `r0`

### c0110000. TSS: Test MSB

### c011rrrr. CPF: Copy register from `r0`

### c1010000. CLR

### c1010001. NOT

### c1010010. AND

### c1010011. OR

### c1010100. XOR

### c1010101. DBG

### c1010110. ADD

### c1010111. SUB

### c1011000. MUL

### c1011001. DIV

### c1011010. INC

### c1011011. DEC

### c1011100. LD

### c1011101. ST

### c110nnnn. IML

### c111nnnn. IMH

## External Controlling

// TODO

# License

This document is licensed under [MIT License](https://github.com/m13253/riscade/blob/master/COPYING)

