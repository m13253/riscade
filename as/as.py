#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This program is a part of Riscade project.
# Licensed under MIT License.
# See https://github.com/m13253/riscade/blob/master/COPYING for licensing information.

import enum
import logging
import sys


def log_error(line: int, col: int, message: str):
    logging.error(message, extra={'line': line+1, 'col': col+1})
    sys.exit(1)


def log_warn(line: int, col: int, message: str):
    logging.warn(message, extra={'line': line+1, 'col': col+1})


class Token:
    Type = enum.Enum('Token.Type', 'none error ident sign zero zerob zeroo zerox bin oct hex number punct')

    def __init__(self, token: str, ttype: Type, col: int):
        self.token, self.ttype, self.col = token, ttype, col

    def __repr__(self):
        return 'Token(%r, %s, %r)' % (self.token, self.ttype, self.col)


def parse_token(line: str, lineno: int) -> [Token]:

    def next_token(line: str, col: int) -> Token:
        token = ''
        last = Token.Type.none
        while col < len(line):
            if last == Token.Type.none:
                if line[col] in ('\t', ' '):
                    pass
                elif line[col] in (',', '.', ':'):
                    token += line[col]
                    last = Token.Type.punct
                elif 'A' <= line[col] <= 'Z' or 'a' <= line[col] <= 'z' or line[col] == '_':
                    token += line[col]
                    last = Token.Type.ident
                elif line[col] in ('-', '+'):
                    token += line[col]
                    last = Token.Type.sign
                elif line[col] == '0':
                    token += line[col]
                    last = Token.Type.zero
                elif '1' <= line[col] <= '9':
                    token += line[col]
                    last = Token.Type.number
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.ident:
                if line[col] in ('\t', ' ', ',', '.', ':'):
                    break
                elif '0' <= line[col] <= '9' or 'A' <= line[col] <= 'Z' or 'a' <= line[col] <= 'z' or line[col] == '_':
                    token += line[col]
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.sign:
                if line[col] == '0':
                    token += line[col]
                    last = Token.Type.zero
                elif '1' <= line[col] <= '9':
                    token += line[col]
                    last = Token.Type.number
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.zero:
                if line[col] in ('\t', ' ', ',', '.', ':'):
                    break
                elif '0' <= line[col] <= '9':
                    token += line[col]
                    last = Token.Type.number
                elif line[col] in ('b', 'B'):
                    token += line[col]
                    last = Token.Type.zerob
                elif line[col] in ('o',):
                    token += line[col]
                    last = Token.Type.zeroo
                elif line[col] in ('x', 'X'):
                    token += line[col]
                    last = Token.Type.zerox
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.zerob:
                if '0' <= line[col] <= '1':
                    token += line[col]
                    last = Token.Type.bin
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.zeroo:
                if '0' <= line[col] <= '7':
                    token += line[col]
                    last = Token.Type.oct
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.zerox:
                if '0' <= line[col] <= '9' or 'A' <= line[col] <= 'F' or 'a' <= line[col] <= 'f':
                    token += line[col]
                    last = Token.Type.hex
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.bin:
                if line[col] in ('\t', ' ', ',', '.', ':'):
                    break
                elif '0' <= line[col] <= '1':
                    token += line[col]
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.oct:
                if line[col] in ('\t', ' ', ',', '.', ':'):
                    break
                elif '0' <= line[col] <= '7':
                    token += line[col]
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.hex:
                if line[col] in ('\t', ' ', ',', '.', ':'):
                    break
                elif '0' <= line[col] <= '9' or 'A' <= line[col] <= 'F' or 'a' <= line[col] <= 'f':
                    token += line[col]
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.number:
                if line[col] in ('\t', ' ', ',', '.', ':'):
                    break
                elif '0' <= line[col] <= '9':
                    token += line[col]
                else:
                    return Token(token, Token.Type.error, col)
            elif last == Token.Type.punct:
                break
            col += 1
        if last in (Token.Type.sign, Token.Type.zerob, Token.Type.zeroo, Token.Type.zerox):
            last = Token.Type.error
        elif last in (Token.Type.zero, Token.Type.bin, Token.Type.oct, Token.Type.hex):
            last = Token.Type.number
        return Token(token, last, col)

    col = 0
    while True:
        token = next_token(line, col)
        col = token.col
        if(token.ttype == Token.Type.error):
            log_error(lineno, col, "Syntax error after '%s'" % token.token)
        if not token.token:
            return
        yield token


class AsmStatus:
    def __init__(self):
        self.memory = bytearray(0x10000)
        self.symtable = {}
        self.reloc = []  # [(line: int, col: int, addr: int, ident: str, shift: int)]
        self.pointer = 0xff00
        self.lineno = 0


def try_label(tokens: [Token], status: AsmStatus) -> bool:
    if len(tokens) >= 2 and (tokens[0].ttype, tokens[1].token) == (Token.Type.ident, ':'):
        symbol = tokens[0].token
        if symbol not in status.symtable:
            status.symtable[symbol] = status.pointer
        del tokens[0:2]
        return True
    return False


def try_directive(tokens: [Token], status: AsmStatus) -> bool:
    if len(tokens) >= 2 and (tokens[0].token, tokens[1].ttype) == ('.', Token.Type.ident):
        directive = tokens[1].token.lower()
        if directive == 'org':
            if len(tokens) == 3:
                try:
                    status.pointer = int(tokens[2].token, 0)
                    if not (0 <= status.pointer <= 0xffff):
                        raise ValueError()
                except ValueError:
                    log_error(status.lineno, tokens[2].col, "Invalid value '%s' in directive '.org'" % tokens[2].token)
            else:
                log_error(status.lineno, tokens[0].col, "Directive '.org' requires 1 argument")
        elif directive == 'byte':
            for idx, byte in enumerate(tokens[2:]):
                if status.pointer & 0xff == 0xff:
                    log_warn(status.lineno, tokens[0].col, "Instruction goes across segment boundry but no '.org' was seen")
                if status.memory[status.pointer] & 0x7f != 0:
                    log_warn(status.lineno, tokens[0].col, "Memory at 0x%04x was already programmed to 0x02x" % (status.pointer, status.memory[status.pointer]))
                try:
                    byte_val = int(byte.token, 0)
                    if not (0 <= byte_val <= 0xff):
                        raise ValueError()
                except ValueError:
                    log_error(status.lineno, byte.col, "Invalid value '%s' in directive '.byte'" % byte.token)
                status.memory[status.pointer] = byte_val
                status.pointer += 1
        else:
            log_error(status.lineno, tokens[0].col, "Invalid directive '%s'" % directive)
        return True
    return False


def try_instruction(tokens: [Token], status: AsmStatus) -> bool:

    def check_argc(inst, argc):
        if argc == 0:
            if len(tokens) != argc + 1:
                log_error(status.lineno, tokens[0].col, "Instruction '%s' requires no arguments" % inst)
        elif argc == 1:
            if len(tokens) != argc + 1:
                log_error(status.lineno, tokens[0].col, "Instruction '%s' requires 1 argument" % inst)
        else:
            if len(tokens) != argc + 1:
                log_error(status.lineno, tokens[0].col, "Instruction '%s' requires %d arguments" % (inst, argc))

    def parse_reg1(inst, token):
        try:
            return {'s0': 0, 's1': 1}[token.token]
        except KeyError:
            log_error(status.lineno, token.col, "The argument of '%s' can only be 's0' or 's1'" % inst)

    def parse_reg4(inst, token):
        try:
            return {'r0': 0, 'r1': 1, 'r2': 2, 'r3': 3, 'r4': 4, 'r5': 5, 'r6': 6, 'r7': 7, 'r8': 8, 'r9': 9, 'fl': 10, 'sp': 11, 's0': 12, 's1': 13, 's2': 14, 'pc': 15}[token.token]
        except KeyError:
            log_error(status.lineno, token.col, "The argument of '%s' must be a valid register" % inst)

    def parse_flag(inst, token):
        try:
            f = int(tokens[1].token, 0)
            if f not in (1, 2, 3):
                raise ValueError()
            return f
        except ValueError:
            log_error(status.lineno, tokens.col, "The first argument of '%s' can only be '1', '2', '3'" % inst)

    if status.pointer & 0xff == 0xff:
        log_warn(status.lineno, tokens[0].col, "Instruction goes across segment boundry but no '.org' was seen")
    if status.memory[status.pointer] & 0x7f != 0:
        log_warn(status.lineno, tokens[0].col, "Memory at 0x%04x was already programmed to 0x02x" % (status.pointer, status.memory[status.pointer]))
    inst = tokens[0].token.lower()
    cond = 0
    if inst == 'cond':
        if len(tokens) >= 1:
            cond = 0x80
            inst = tokens[1].token.lower()
            del tokens[0]
        else:
            log_error(status.lineno, tokens[0].col, "Instruction 'cond' requires at least 1 argument")
    if inst == 'nop':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000000
    elif inst == 'hlt':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000001
    elif inst == 'in':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000010
    elif inst == 'out':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000011
    elif inst == 'shr':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000100
    elif inst == 'shr1':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000101
    elif inst == 'ror':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000110
    elif inst == 'ror1':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0000111
    elif inst == 'cli':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0001000
    elif inst == 'clf':
        check_argc(inst, 1)
        f = parse_flag(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b0001000 | f
    elif inst == 'tce':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b0001100
    elif inst == 'stf':
        check_argc(inst, 1)
        f = parse_flag(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b0001100 | f
    elif inst == 'tsp':
        check_argc(inst, 1)
        status.memory[status.pointer] = cond | 0b0010000
    elif inst == 'swp':
        check_argc(inst, 1)
        r = parse_reg4(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b0010000 | r
    elif inst == 'tsz':
        status.memory[status.pointer] = cond | 0b0100000
    elif inst == 'cpf':
        check_argc(inst, 1)
        r = parse_reg4(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b0100000 | r
    elif inst == 'tss':
        status.memory[status.pointer] = cond | 0b0110000
    elif inst == 'cpt':
        check_argc(inst, 1)
        r = parse_reg4(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b0110000 | r
    elif inst == 'tsi':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1001000
    elif inst == 'tsf':
        check_argc(inst, 1)
        f = parse_flag(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b1001000 | f
    elif inst == 'ld':
        check_argc(inst, 1)
        s = parse_reg1(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b1001100 | s << 4
    elif inst == 'st':
        check_argc(inst, 1)
        s = parse_reg1(inst, tokens[1])
        status.memory[status.pointer] = cond | 0b1001101 | s << 4
    elif inst == 'clr':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010000
    elif inst == 'not':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010001
    elif inst == 'and':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010010
    elif inst == 'or':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010011
    elif inst == 'xor':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010100
    elif inst == 'dbg':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010101
    elif inst == 'add':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010110
    elif inst == 'sub':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1010111
    elif inst == 'mul':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011000
    elif inst == 'div':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011001
    elif inst == 'inc':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011010
    elif inst == 'dec':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011011
    elif inst == 'pop':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011100
    elif inst == 'push':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011101
    elif inst == 'ljmp':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011110
    elif inst == 'iret':
        check_argc(inst, 0)
        status.memory[status.pointer] = cond | 0b1011111
    elif inst == 'iml':
        m = 0
        if len(tokens) <= 1:
            log_error(status.lineno, tokens[0].col, "Instruction '%s' requires 1 arguments" % inst)
        elif len(tokens) == 2 and tokens[1].ttype == Token.Type.number:
            try:
                m = int(tokens[1].token, 0)
                if not (0 <= m <= 15):
                    raise ValueError()
            except ValueError:
                log_error(status.lineno, tokens[1].col, "The argument of '%s' must be a number between 0 and 15" % tokens[1].token)
        elif len(tokens) == 2 and tokens[1].ttype == Token.Type.ident:
            status.reloc.append((status.lineno, tokens[1].col, status.pointer, tokens[1].token, 0))
        elif len(tokens) == 4 and (tokens[1].ttype, tokens[2].token, tokens[3].ttype) == (Token.Type.ident, '.', Token.Type.ident):
            try:
                shift = {'low': 0, 'high': 4, 'seg': 8, 'seglow': 8, 'seghigh': 12}[tokens[3].token]
            except KeyError:
                log_error(status.lineno, tokens[1].col, "The suffix of '%s' can only be 'low', 'high', 'seg', 'seglow', 'seghigh'" % tokens[1].token)
            status.reloc.append((status.lineno, tokens[1].col, status.pointer, tokens[1].token, shift))
        else:
            log_error(status.lineno, tokens[1].col, "The argument of '%s' must be a number, or a valid identifier, either with or without a suffix" % inst)
        status.memory[status.pointer] = cond | 0b1100000 | m
    elif inst == 'imh':
        m = 0
        if len(tokens) <= 1:
            log_error(status.lineno, tokens[0].col, "Instruction '%s' requires 1 arguments" % inst)
        elif len(tokens) == 2 and tokens[1].ttype == Token.Type.number:
            try:
                m = int(tokens[1].token, 0)
                if not (0 <= m <= 15):
                    raise ValueError()
            except ValueError:
                log_error(status.lineno, tokens[1].col, "The argument of '%s' must be a number between 0 and 15" % tokens[1].token)
        elif len(tokens) == 2 and tokens[1].ttype == Token.Type.ident:
            status.reloc.append((status.lineno, tokens[1].col, status.pointer, tokens[1].token, 4))
        elif len(tokens) == 4 and (tokens[1].ttype, tokens[2].token, tokens[3].ttype) == (Token.Type.ident, '.', Token.Type.ident):
            try:
                shift = {'low': 0, 'high': 4, 'seg': 12, 'seglow': 8, 'seghigh': 12}[tokens[3].token]
            except KeyError:
                log_error(status.lineno, tokens[1].col, "The suffix of '%s' can only be 'low', 'high', 'seg', 'seglow', 'seghigh'" % tokens[1].token)
            status.reloc.append((status.lineno, tokens[1].col, status.pointer, tokens[1].token, shift))
        else:
            log_error(status.lineno, tokens[1].col, "The argument of '%s' must be a number, or a valid identifier, either with or without a suffix" % inst)
        status.memory[status.pointer] = cond | 0b1110000 | m
    else:
        return False
    status.pointer += 1
    return True


def relocate(status: AsmStatus):
    for line, col, addr, ident, shift in status.reloc:
        if ident not in status.symtable:
            log_error(line, col, "Undefined identifier '%s'" % ident)
        status.memory[addr] |= (status.symtable[ident] >> shift) & 0xf


def main():
    logging.basicConfig(format='%(line)s:%(col)s: %(levelname)s: %(message)s')
    status = AsmStatus()
    for status.lineno, line in enumerate(sys.stdin):
        line = line.split(';', 1)[0].rstrip()
        tokens = list(parse_token(line, status.lineno))
        while try_label(tokens, status):
            pass
        if tokens:
            if try_directive(tokens, status):
                continue
            if try_instruction(tokens, status):
                continue
            log_error(status.lineno, tokens[0].col, "Syntax error near '%s'" % tokens[0].token)
    relocate(status)
    sys.stdout.buffer.write(status.memory)

if __name__ == '__main__':
    main()
