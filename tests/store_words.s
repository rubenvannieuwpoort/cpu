.global	_start

.text
_start:
li x1, 0
li x2, 0
li x3, 25

loop:
sw x1, 0(x2)
addi x1, x1, 1
addi x2, x2, 4

blt x1, x3, loop

done:
jal x0, 0

# expected result:
# 0 to 25 written to the first 25 words in RAM

# machine code and disassembly:
#   0:   00000093                li      ra,0
#   4:   00000113                li      sp,0
#   8:   01900193                li      gp,25
#   c:   00112023                sw      ra,0(sp)
#  10:   00108093                add     ra,ra,1
#  14:   00410113                add     sp,sp,4
#  18:   fe30cae3                blt     ra,gp,c <loop>
#  1c:   0000006f                j       1c <done>
