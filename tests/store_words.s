.global	_start

.text
_start:
li x3, 25
xor x1, x1, x1

loop:
sw x0, 0(x1)
addi x0, x0, 1
addi x1, x1, 4

blt x1, x3, loop

done:
jal x0, 0

# expected result:
# 0 to 25 written to the first 25 words in RAM

# machine code and disassembly:
#   0:   01900193                li      gp,25
#   4:   0010c0b3                xor     ra,ra,ra
#   8:   0000a023                sw      zero,0(ra)
#   c:   00100013                li      zero,1
#  10:   00408093                add     ra,ra,4
#  14:   fe30cae3                blt     ra,gp,8 <loop>
#  18:   0000006f                j       18 <done>
