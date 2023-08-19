.global	_start

.text
_start:
li x1, 0x1337c0de
li x2, 0xdeadbeef
li x3, 16

add x4, x1, x2

sub x5, x1, x2

sll x6, x1, x3

slt x7, x1, x2
slt x8, x2, x1
slt x9, x1, x1
slt x10, x2, x2

sltu x11, x1, x2
sltu x12, x2, x1
sltu x13, x1, x1
sltu x14, x2, x2

xor x15, x1, x2

srl x16, x1, x3

sra x17, x1, x3
sra x18, x2, x3

or  x19, x1, x2

and x20, x1, x2

# expected result:
#  x0	0
#  x1	0x1337c0de
#  x2	0xdeadbeef
#  x3	0x00000010
#  x4	0xf1e57fcd
#  x5	0x348a01ef
#  x6	0xc0de0000
#  x7	0
#  x8	1
#  x9	0
# x10	0
# x11	1
# x12	0
# x13	0
# x14	0
# x15	0xcd9a7e31
# x16	0x00001337
# x17	0x00001337
# x18	0xffffdead
# x19	0xdfbffeff
# x20	0x122580ce

# machine code and disassembly
#   0:   1337c0b7                lui     ra,0x1337c
#   4:   0de08093                add     ra,ra,222 # 1337c0de <_start+0x1337c0de>
#   8:   deadc137                lui     sp,0xdeadc
#   c:   eef10113                add     sp,sp,-273 # deadbeef <_start+0xdeadbeef>
#  10:   01000193                li      gp,16
#  14:   00208233                add     tp,ra,sp
#  18:   402082b3                sub     t0,ra,sp
#  1c:   00309333                sll     t1,ra,gp
#  20:   0020a3b3                slt     t2,ra,sp
#  24:   00112433                slt     s0,sp,ra
#  28:   0010a4b3                slt     s1,ra,ra
#  2c:   00212533                slt     a0,sp,sp
#  30:   0020b5b3                sltu    a1,ra,sp
#  34:   00113633                sltu    a2,sp,ra
#  38:   0010b6b3                sltu    a3,ra,ra
#  3c:   00213733                sltu    a4,sp,sp
#  40:   0020c7b3                xor     a5,ra,sp
#  44:   0030d833                srl     a6,ra,gp
#  48:   4030d8b3                sra     a7,ra,gp
#  4c:   40315933                sra     s2,sp,gp
#  50:   0020e9b3                or      s3,ra,sp
#  54:   0020fa33                and     s4,ra,sp
