#!/usr/bin/env python3

from abc import ABC


class Operand(ABC):
    def bit_letter(self):
        return self._bit_letter


class Instruction:
    def __init__(self, operands: list[Operand], instruction_encoding):
        self._operands = operands
        self._instruction_encoding = instruction_encoding

        if len(instruction_encoding) != 16:
            raise ValueError(f'Expected instruction encoding of length 16, got "{instruction_encoding}"')

        bit_letters = set()
        for operand in self._operands:
            bit_letter = operand.bit_letter()
            if not bit_letter:
                continue

            if bit_letter in bit_letters:
                raise ValueError(f'Multiple operands with same bit letter {operand.bit_letter()}')

            bit_letters.add(operand.bit_letter())

    def match(self, input: list[str]) -> dict[str, int]:
        if len(input) != len(self._operands):
            return None

        result = {}
        for i, operand in enumerate(self._operands):
            match_result = operand.match(input[i])
            if match_result is None:
                return None

            bit_letter = operand.bit_letter()
            if bit_letter:
                assert bit_letter not in result
                result[bit_letter] = match_result

        return result

    def assemble(self, operand_map: dict[str, int]):
        result = 0

        counters = {}
        for bit_letter in operand_map:
            counters[bit_letter] = 0

        for i, bit_letter in enumerate(reversed(self._instruction_encoding)):
            if bit_letter == '0':
                bit = 0
            elif bit_letter == '1':
                bit = 1
            elif bit_letter in [ chr(c) for c in range(ord('a'), ord('z')) ]:
                bit_position = counters[bit_letter]
                bit_mask = 1 << bit_position
                bit = (operand_map[bit_letter] & bit_mask) >> bit_position
                counters[bit_letter] += 1
            else:
                assert False

            result = result | (bit << i)
        
        return result


class Mnemonic(Operand):
    def __init__(self, mnemonic: list[str]):
        self._mnemonic = mnemonic
        self._bit_letter = None

    def match(self, input: str):
        if input in self._mnemonic:
            return []
        return None


class Mnemonics(Operand):
    def __init__(self, mnemonics: list[list[str]], bit_letter: str):
        self._mnemonics = mnemonics
        if len(bit_letter) != 1:
            raise ValueError(f'Expected bit letter of length 1, got "{bit_letter}"')

        self._bit_letter = bit_letter

    def match(self, input: str):
        for index, aliases in enumerate(self._mnemonics):
            if input in aliases:
                return index
        return None


class RegisterOperand(Operand):
    def __init__(self, bit_letter: str):
        if len(bit_letter) != 1:
            raise ValueError(f'Expected bit letter of length 1, got "{bit_letter}"')

        self._bit_letter = bit_letter

    def match(self, input: str):
        if len(input) < 2:
            return None

        if input[0] != 'r':
            return None

        try:
            reg_number = [ f'r{i}' for i in range(0, 16) ].index(input)
        except ValueError:
            return None

        return reg_number


def parse_decimal(input: str):
    try:
        return int(input)
    except ValueError:
        return None


def parse_hexadecimal(input: str):
    try:
        return int(input, 16)
    except ValueError:
        return None


class UImm8(Operand):
    def __init__(self, bit_letter: str):
        if len(bit_letter) != 1:
            raise ValueError(f'Expected bit letter of length 1, got "{bit_letter}"')

        self._bit_letter = bit_letter

    def match(self, input: str):
        n = parse_decimal(input) or parse_hexadecimal(input)
        if n is None:
            return None

        if 0 <= n and n <= 255:
            return n

        return None


class UImm5(Operand):
    def __init__(self, bit_letter: str):
        if len(bit_letter) != 1:
            raise ValueError(f'Expected bit letter of length 1, got "{bit_letter}"')

        self._bit_letter = bit_letter

    def match(self, input: str):
        n = parse_decimal(input) or parse_hexadecimal(input)
        if n is None:
            return None

        if 0 <= n and n <= 31:
            return n

        return None


class SImm8(Operand):
    def __init__(self, bit_letter: str):
        if len(bit_letter) != 1:
            raise ValueError(f'Expected bit letter of length 1, got "{bit_letter}"')

        self._bit_letter = bit_letter

    def match(self, input: str):
        n = parse_decimal(input) or parse_hexadecimal(input)
        if n is None:
            return None

        if -128 <= n and n <= 127:
            return n

        return None


class SImm4(Operand):
    def __init__(self, bit_letter: str):
        if len(bit_letter) != 1:
            raise ValueError(f'Expected bit letter of length 1, got "{bit_letter}"')

        self._bit_letter = bit_letter

    def match(self, input: str):
        n = parse_decimal(input) or parse_hexadecimal(input)
        if n is None:
            return None

        if -8 <= n and n <= 7:
            return n

        return None


class Assembler:
    def __init__(self, instructions: list[Instruction]):
        self._instructions = instructions

    def _match(self, input: list[str]) -> tuple[Operand, ]:
        for instruction in self._instructions:
            match = instruction.match(input)
            if match is not None:
                return instruction, match
        
        return None

    def _parse(self, input: str) -> list[str]:
        if ';' in input:
            input = input.split(';', 1)[0]
        if ' ' in input:
            operand, rest = input.split(' ', 1)
            return [operand.strip()] + [x.strip() for x in rest.split(',')]
        else:
            return [input.strip()]

    def assemble(self, input: str) -> int:
        arguments = self._parse(input)
        match = self._match(arguments)
        if match is None:
            raise ValueError(f'No matching instruction found for "{input}"')

        instruction, operand_map = match
        encoding = instruction.assemble(operand_map)
        return encoding


def generate_conditions(base: str):
    b = base
    return [
        [f'{b}o'],                      # overflow
        [f'{b}no'],                     # no overflow
        [f'{b}n'],                      # negative
        [f'{b}nn'],                     # not negative
        [f'{b}e', f'{b}z'],             # equal/zero
        [f'{b}ne', f'{b}nz'],           # not equal/zero
        [f'{b}b', f'{b}nae', f'{b}c'],  # below, not above or equal (for unsigned numbers), carry
        [f'{b}nb', f'{b}ae', f'{b}nc'], # not below, above or equal (for unsigned numbers), no carry
        [f'{b}be', f'{b}na'],           # below or equal, not above (for unsigned numbers)
        [f'{b}a', f'{b}nbe'],           # above, not below or equal (for unsigned numbers)
        [f'{b}l', f'{b}nge'],           # less, not greater or equal (for signed numbers)
        [f'{b}ge', f'{b}nl'],           # greater or equal, not less (for signed numbers)
        [f'{b}le', f'{b}ng'],           # less or equal, not greater (for signed numbers)
        [f'{b}g', f'{b}nle'],           # greater, not less or equal (for signed numbers)
        [f'{b}p'],                      # positive
        [f'{b}np']                      # not positive
    ]


def printVHDL(input):
    while len(input) < 32:
        input.append(0)

    print('"' + '", "'.join(map(lambda x: bin(x)[2:].rjust(16, '0'), input)) + '"')


assembler = Assembler([
    Instruction([Mnemonic(['nop'])], '0000000000000000'),
    Instruction([Mnemonic(['branch']), RegisterOperand('a')], '00000010aaaa0000'),
    Instruction([Mnemonics(generate_conditions('branch_'), 'c'), RegisterOperand('a')], '00000001aaaacccc'),
    Instruction([Mnemonics([['setbyte0'], ['setbyte1'], ['setbyte2'], ['setbyte3']], 'n'), RegisterOperand('a'), UImm8('i')], '01nniiiiaaaaiiii'),
    Instruction([Mnemonics([['copy'], ['add'], ['subtract'], ['multiply'], ['and'], ['or'], ['xor'], ['not'], ['shl'], ['shr'], ['sar'], ['cmp'], ['test']], 'n'), RegisterOperand('a'), RegisterOperand('b')], '0001nnnnaaaabbbb'),
    Instruction([Mnemonics([['loadbyte'], ['loadhalfword'], ['loadword']], 's'), RegisterOperand('a'), RegisterOperand('b')], '000010ssaaaabbbb'),
    Instruction([Mnemonics(['storebyte', 'storehalfword', 'storeword'], 's'), RegisterOperand('a'), RegisterOperand('b')], '000011ssaaaabbbb'),
    Instruction([Mnemonic(['setsigned']), RegisterOperand('a'), SImm8('i')], '0010iiiiaaaaiiii'),
    Instruction([Mnemonic(['setunsigned']), RegisterOperand('a'), UImm8('i')], '0011iiiiaaaaiiii'),
    Instruction([Mnemonics([['shl'], ['shr'], ['sar']], 'n'), RegisterOperand('a'), UImm5('i')], '1000nn0iaaaaiiii'),
    Instruction([Mnemonic(['prefetch']), RegisterOperand('a')], '10001100aaaa0000'),
    Instruction([Mnemonic(['flush']), RegisterOperand('a')], '10001100aaaa0001'),
    Instruction([Mnemonics(generate_conditions('set_'), 'c'), RegisterOperand('a'), RegisterOperand('b')], '1001ccccaaaabbbb'),
    Instruction([Mnemonics(generate_conditions('set_'), 'c'), RegisterOperand('a'), SImm4('i')], '1010ccccaaaaiiii'),
])

if __name__ == '__main__':
    import sys

    if len(sys.argv) != 2:
        print('expected a single input file as argument')
        exit(1)


    result = []

    for line in open(sys.argv[1], 'r'):
        stripped_line = line.strip()
        if stripped_line == '' or stripped_line[0] == ';':
            continue

        result.append(assembler.assemble(stripped_line))

    printVHDL(result)
