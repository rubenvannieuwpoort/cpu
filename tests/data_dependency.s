.global	_start

.text
_start:
addi x1, x1, 1
addi x1, x1, 1
addi x1, x1, 1
addi x1, x1, 1
addi x1, x1, 1
addi x1, x1, 1
addi x1, x1, 1
addi x1, x1, 1
jal x0, 0

# expected result
# x1	8

# machine code and disassembly
#   0:   00108093                add     ra,ra,1
#   4:   00108093                add     ra,ra,1
#   8:   00108093                add     ra,ra,1
#   c:   00108093                add     ra,ra,1
#  10:   00108093                add     ra,ra,1
#  14:   00108093                add     ra,ra,1
#  18:   00108093                add     ra,ra,1
#  1c:   00108093                add     ra,ra,1
#  20:   0000006f                j       20 <_start+0x20>
