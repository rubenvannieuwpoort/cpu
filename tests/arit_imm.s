.global	_start

.text
_start:
li x1, 0x1337c0de
li x2, 0xdeadbeef

addi x3, x1, 0x123

slti x4, x1, 1
slti x5, x1, -1
slti x6, x2, 1
slti x7, x2, -1

sltiu x8, x1, 1
sltiu x9, x1, -1
sltiu x10, x2, 1
sltiu x11, x2, -1

xori x12, x1, 0x234

ori  x13, x1, 0x345

andi x14, x1, 0x456

slli x15, x1, 16

srli x16, x1, 12

srai x17, x1, 12

srai x18, x2, 12

# expected result:
#  x0	0
#  x1	0x1337c0de
#  x2	0xdeadbeef
#  x3	0x1337c201
#  x4	0
#  x5	0
#  x6	1
#  x7	1
#  x8	0
#  x9	1
# x10	0
# x11	1
# x12	0x1337c2ea
# x13	0x1337c3df
# x14	0x00000056
# x15	0xc0de0000
# x16	0x0001337c
# x17	0x0001337c
# x18	0xfffdeadb

# machine code and disassembly
#   0:   1337c0b7                lui     ra,0x1337c
#   4:   0de08093                add     ra,ra,222 # 1337c0de <_start+0x1337c0de>
#   8:   deadc137                lui     sp,0xdeadc
#   c:   eef10113                add     sp,sp,-273 # deadbeef <_start+0xdeadbeef>
#  10:   12308193                add     gp,ra,291
#  14:   0010a213                slti    tp,ra,1
#  18:   fff0a293                slti    t0,ra,-1
#  1c:   00112313                slti    t1,sp,1
#  20:   fff12393                slti    t2,sp,-1
#  24:   0010b413                seqz    s0,ra
#  28:   fff0b493                sltiu   s1,ra,-1
#  2c:   00113513                seqz    a0,sp
#  30:   fff13593                sltiu   a1,sp,-1
#  34:   2340c613                xor     a2,ra,564
#  38:   3450e693                or      a3,ra,837
#  3c:   4560f713                and     a4,ra,1110
#  40:   01009793                sll     a5,ra,0x10
#  44:   00c0d813                srl     a6,ra,0xc
#  48:   40c0d893                sra     a7,ra,0xc
#  4c:   40c15913                sra     s2,sp,0xc
