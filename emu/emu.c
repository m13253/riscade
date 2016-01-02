#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static const uint8_t fl = 10;
static const uint8_t sp = 11;
static const uint8_t s0 = 12;
static const uint8_t s1 = 13;
static const uint8_t s2 = 14;
static const uint8_t pc = 15;

static void print_debug(const uint8_t memory[0x10000], const uint8_t registers[16]) {
    fprintf(stderr, "\nr0:%02x r1:%02x r2:%02x r3:%02x r4:%02x r5:%02x r6:%02x r7:%02x\nr8:%02x r9:%02x fl:%02x sp:%02x s0:%02x s1:%02x s2:%02x pc:%02x\n\n", registers[0], registers[1], registers[2], registers[3], registers[4], registers[5], registers[6], registers[7], registers[8], registers[9], registers[fl], registers[sp], registers[s0], registers[s1], registers[s2], registers[pc]);
}

static void emulate(uint8_t memory[0x10000], uint8_t registers[16]) {
    for(;;) {
        uint8_t inst = memory[registers[s2] << 8 | registers[pc]];
        registers[pc]++;
        if(inst >> 7 != registers[fl] & 1) {
            continue;
        }
        inst &= 0x7f;
        // NOP
        if(inst == 0x00) {
        // HLT
        } else if(inst == 0x01) {
            return;
        // IN
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
        // OUT
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
        // SHR
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
                print_debug();
                abort();
            }
        // SHR1
        } else if(inst == 0x05) {
            registers[fl] &= 0xfd;
            registers[fl] |= (registers[0] & 0x1) << 1;
        // ROR
        } else if(inst == 0x06) {
            if(registers[1] > 0 && registers[1] < 8) {
                registers[0] = registers[0] >> registers[1] | registers[0] << (8-registers[1]);
            } else {
                print_debug();
                abort();
            }
        // ROR1
        } else if(inst == 0x07) {
            registers[0] = registers[0] >> 1 | registers[0] << 7;
        // CLI
        } else if(inst == 0x08) {
            registers[fl] &= 0x0f;
        // CLF 1
        } else if(inst == 0x09) {
            registers[fl] &= 0xfd;
        // CLF 2
        } else if(inst == 0x0a) {
            registers[fl] &= 0xfb;
        // CLF 3
        } else if(inst == 0x0b) {
            registers[fl] &= 0xf7;
        // TCE
        } else if(inst == 0x0c) {
            registers[fl] ^= 0x1;
        // STF 1
        } else if(inst == 0x0d) {
            registers[fl] |= 0x2;
        // STF 2
        } else if(inst == 0x0e) {
            registers[fl] |= 0x4;
        // STF 3
        } else if(inst == 0x0f) {
            registers[fl] |= 0x8;
        // TSP
        } else if(inst == 0x10) {
            registers[fl] &= 0xfe;
            registers[fl] |= registers[0] & 1;
        // SWP
        } else if(inst >= 0x10 && inst <= 0x1f) {
            uint8_t tmp = registers[0];
            registers[0] = registers[inst & 0xf];
            registers[inst & 0xf] = tmp;
        // TSZ
        } else if(inst == 0x20) {
            if(registers[0]) {
                registers[fl] |= 0x1;
            } else {
                registers[fl] &= 0xfe;
            }
        // CPF
        } else if(inst >= 0x20 && inst <= 0x2f) {
            registers[0] = registers[inst & 0xf];
        // TSS
        } else if(inst == 0x30) {
            registers[fl] &= 0xfe;
            registers[fl] |= registers[0] >> 7;
        // CPT
        } else if(inst >= 0x30 && inst <= 0x3f) {
            registers[inst & 0xf] = registers[0];
        // TSI
        } else if(inst == 0x48) {
            if(fl & 0xf0) {
                registers[fl] |= 0x1;
            } else {
                registers[fl] &= 0xfe;
            }
        // TSF 1
        } else if(inst == 0x49) {
            if(registers[fl] & 0x2) {
                registers[fl] |= 0x1;
            } else {
                registers[fl] &= 0xfe;
            }
        // TSF 2
        } else if(inst == 0x4a) {
            if(registers[fl] & 0x4) {
                registers[fl] |= 0x1;
            } else {
                registers[fl] &= 0xfe;
            }
        // TSF 3
        } else if(inst == 0x4b) {
            if(registers[fl] & 0x8) {
                registers[fl] |= 0x1;
            } else {
                registers[fl] &= 0xfe;
            }
        // LD s0
        } else if(inst == 0x4c) {
            registers[0] = memory[registers[s0] << 8 | registers[1]];
        // LD s1
        } else if(inst == 0x5c) {
            registers[0] = memory[registers[s1] << 8 | registers[1]];
        // ST  s0
        } else if(inst == 0x4d) {
            memory[registers[s0] << 8 | registers[1]] = registers[0];
        // ST  s1
        } else if(inst == 0x4d) {
            memory[registers[s1] << 8 | registers[1]] = registers[0];
        // CLR
        } else if(inst == 0x50) {
            registers[0] = 0;
        // NOT
        } else if(inst == 0x51) {
            registers[0] = ~registers[0];
        // AND
        } else if(inst == 0x52) {
            registers[0] &= registers[1];
        // OR
        } else if(inst == 0x53) {
            registers[0] |= registers[1];
        // XOR
        } else if(inst == 0x54) {
            registers[0] ^= registers[1];
        // DBG
        } else if(inst == 0x55) {
            print_debug(memory, registers);
        // ADD
        } else if(inst == 0x56) {
            if(registers[0] + registers[1] >= 0xff) {
                registers[fl] |= 0x2;
            } else {
                registers[fl] &= 0xfd;
            }
            registers[0] += registers[1];
        // SUB
        } else if(inst == 0x57) {
            if(registers[0] + (uint8_t) -registers[1] >= 0xff) {
                registers[fl] |= 0x2;
            } else {
                registers[fl] &= 0xfd;
            }
        // MUL
        } else if(inst == 0x58) {
            uint16_t prod = registers[0] * registers[1];
            registers[0] = (uint8_t) prod;
            registers[1] = (uint8_t) (prod >> 8);
        // DIV
        } else if(inst == 0x59) {
            if(registers[0] == 0 && registers[1] == 0) {
                registers[fl] |= 0x2;
                registers[0] = 0;
                registers[1] = 0;
            } else if(registers[1] == 0) {
                registers[fl] |= 0x2;
                registers[0] = 0xff;
                registers[1] = 0;
            } else {
                uint8_t r0 = registers[0];
                uint8_t r1 = registers[1];
                registers[fl] &= 0xfd;
                registers[0] = r0 / r1;
                registers[1] = r0 % r1;
            }
        // INC
        } else if(inst == 0x5a) {
            if(registers[0] == 0xff) {
                registers[fl] |= 0x2;
            } else {
                registers[fl] &= 0xfd;
            }
            registers[0]++;
        // DEC
        } else if(inst == 0x5b) {
            if(registers[0] == 0x0) {
                registers[fl] |= 0x2;
            } else {
                registers[fl] &= 0xfd;
            }
            registers[0]--;
        // PUSH
        } else if(inst == 0x5c) {
            registers[sp]--;
        // POP
        } else if(inst == 0x5d) {
            registers[sp]++;
        // LJMP
        } else if(inst == 0x5e) {
            uint8_t tmp0 = registers[0];
            registers[0] = registers[pc];
            registers[pc] = tmp0;
            uint8_t tmp1 = registers[s0];
            registers[s0] = registers[s2];
            registers[s2] = tmp1;
        // IRET
        } else if(inst == 0x5f) {
            registers[pc] = memory[registers[s1] << 8 | registers[sp]++];
            registers[s0] = memory[registers[s1] << 8 | registers[sp]++];
        // IML
        } else if(inst >= 0x60 && inst <= 0x6f) {
            registers[0] = (registers[0] & 0xf0) | (inst & 0x0f);
        // IMH
        } else if(inst >= 0x70 && inst <= 0x7f) {
            registers[0] = (registers[0] & 0xf0) | (inst & 0x0f) << 4;
        } else {
            print_debug();
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
    uint8_t *memory = calloc(0x10000, 1);
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
