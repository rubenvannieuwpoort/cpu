li x6, 320
li x7, 240

li x8, 1
slli x8, x8, 1
srli x8, x8, 2



start:
li x2, 0
mv x3, x8

y_loop:
li x1, 0

x_loop:
add x4, x1, x5
xor x4, x4, x2
sb x4, 0(x3)
addi x3, x3, 1
addi x1, x1, 1
blt x1, x6, x_loop
addi x2, x2, 1
addi x3, x3, 1280
sub x3, x3, x6
blt x2, x7, y_loop
addi x5, x5, 1
j start

# disassembly:
li x6, 320
li x7, 240

li x8, 1
slli x8, x8, 1
srli x8, x8, 2



start:
li x2, 0
mv x3, x8

y_loop:
li x1, 0

x_loop:
add x4, x1, x5
xor x4, x4, x2
sb x4, 0(x3)
addi x3, x3, 1
addi x1, x1, 1
blt x1, x6, x_loop
addi x2, x2, 1
addi x3, x3, 1280
sub x3, x3, x6
blt x2, x7, y_loop
addi x5, x5, 1
j start

# disassembly:
#00000000 <start-0x14>:
#   0:   14000313                li      t1,320
#   4:   0f000393                li      t2,240
#   8:   00100413                li      s0,1
#   c:   00141413                sll     s0,s0,0x1
#  10:   00245413                srl     s0,s0,0x2
#
#00000014 <start>:
#  14:   00000113                li      sp,0
#  18:   00040193                mv      gp,s0
#
#0000001c <y_loop>:
#  1c:   00000093                li      ra,0
#
#00000020 <x_loop>:
#  20:   00508233                add     tp,ra,t0
#  24:   00224233                xor     tp,tp,sp
#  28:   00418023                sb      tp,0(gp)
#  2c:   00118193                add     gp,gp,1
#  30:   00108093                add     ra,ra,1
#  34:   fe60c6e3                blt     ra,t1,20 <x_loop>
#  38:   00110113                add     sp,sp,1
#  3c:   50018193                add     gp,gp,1280
#  40:   406181b3                sub     gp,gp,t1
#  44:   fc714ce3                blt     sp,t2,1c <y_loop>
#  48:   00128293                add     t0,t0,1
#  4c:   fc9ff06f                j       14 <start>
