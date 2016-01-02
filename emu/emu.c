#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

const uint8_t fl = 10;
const uint8_t sp = 11;
const uint8_t s0 = 12;
const uint8_t s1 = 13;
const uint8_t s2 = 14;
const uint8_t pc = 15;

void emulate(uint8_t *memory, uint8_t registers[]) {
    for(;;) {
        uint8_t inst = memory[registers[s2] << 8 | registers[pc]];
        registers[pc]++;
        if(inst >> 7 != registers[fl] & 1) {
            continue;
        }
        if(inst == 0x00) {
        } else if(inst == 0x01) {
            return;
        } else if(inst == 0x02) {
            uint8_t port = registers[1];
            if(port == 0) {
                int c = fgetc(stdin);
                if(c != EOF) {
                    registers[0] = (uint8_t) c;
                    registers[fl] &= 0xfd;
                } else {
                    registers[0] = 0xff;
                    registers[fl] |= 0x2;
                }
            } else {
                registers[0] = 0;
                registers[fl] |= 0x2;
            }
        } else if(inst == 0x03) {
            uint8_t port = registers[1];
            if(port == 1) {
                if(fputc(registers[0], stdout) != EOF) {
                    registers[fl] &= 0xfd; 
                } else {
                    registers[fl] |= 0x2;
                }
            } else if(port == 2) {
                if(fputc(registers[0], stderr) != EOF) {
                    registers[fl] &= 0xfd; 
                } else {
                    registers[fl] |= 0x2;
                }
            } else {
                registers[fl] |= 0x2;
            }
        } else if(inst == 0x04) {
            int8_t shift = (int8_t) registers[1];
            if(shift > 0 && shift < 8) {
                registers[fl] &= 0xfd;
                registers[fl] |= (registers[0] >> (shift-2)) & 0x2;
                if(registers[fl] & 0x8) {
                    registers[0] = ~(~registers[0] >> shift);
                } else {
                    registers[0] >>= shift;
                }
            } else if(shift > -8 && shift < 0) {
                shift = -shift;
                registers[fl] &= 0xfd;
                registers[fl] |= (registers[0] >> (7-shift)) & 0x2;
                if(registers[fl] & 0x8) {
                    registers[0] = ~(~registers[0] << shift);
                } else {
                    registers[0] <<= shift;
                }
            } else {
                abort();
            }
        } else if(inst == 0x05) {
            registers[fl] &= 0xfd;
            registers[fl] |= (registers[0] & 0x1) << 1;
        } else if(inst == 0x06) {
            if(registers[1] > 0 && registers[1] < 8) {
                registers[0] = registers[0] >> registers[1] | registers[0] << (8-registers[1]);
            } else {
                abort();
            }
        } else if(inst == 0x07) {
            registers[0] = registers[0] >> 1 | registers[0] << 7;
        } else if(inst == 0x08) {
            registers[fl] &= 0x0f;
        } else if(inst == 0x09) {
            registers[fl] &= 0xfd;
        } else if(inst == 0x0a) {
            registers[fl] &= 0xfb;
        } else if(inst == 0x0b) {
            registers[fl] &= 0xf7;
        } else if(inst == 0x0c) {
            registers[fl] ^= 0x01;
        } else if(inst == 0x0d) {
            registers[fl] |= 0x2;
        } else if(inst == 0x0e) {
            registers[fl] |= 0x4;
        } else if(inst == 0x0f) {
            registers[fl] |= 0x8;
        } else {
            abort();
        }
    }
}

int main(int argc, char *argv[]) {
    if(argc < 2) {
        fprintf(stderr, "Usage: %s ROM.bin\n\n");
        return 1;
    }
    FILE *file = fopen(argv[1], "rb");
    if(!file) {
        int err = errno;
        perror("Error opening ROM file");
        return err;
    }
    void *memory = calloc(0x10000, 1);
    if(!memory) {
        int err = errno;
        perror("Error allocating memory");
        return err;
    }
    fread(memory, 1, 0x10000, file);
    if(ferror(file)) {
        int err = errno;
        perror("Error reading ROM file");
        return err;
    }
    fclose(file);
    uint8_t registers[16] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0
    };
    emulate(memory, registers);
    free(memory);
    return 0;
}
