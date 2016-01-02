# Project Riscade

A RISC CPU instruction set for academy experiment

## Documentations

See documentations in `doc` directory.

## Assembler

You can use an assembler, written in Python 3, placed in `as` directory, to compile a Riscade assembly program into binary code.

For example, run the following command to compile `hello.s` into `hello.rom`

    ./as/as.py <hello.s >hello.rom

## Emulator

There is an emulator, written in C, placed in `emu` directory.

For example, run `hello.rom`

    gcc -o ./emu/emu ./emu/emu.c
    ./emu/emu hello.rom

## Demo

There are some demo programs to play with, in `demo` directory.

## Bug report

There are likely to be bugs, either in documentation, assembler, emulator, or in demo programs. Feel free to submit a [GitHub issue](https://github.com/m13253/riscade/issues) so that I can fix it.

# License

This document is licensed under [MIT License](https://github.com/m13253/riscade/blob/master/COPYING)

