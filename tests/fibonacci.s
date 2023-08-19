.global	_start

.text
_start:
addi x5, x0, 17
addi x1, x0, 0
addi x2, x0, 1
beq x4, x5, done

start_loop:
addi x4, x4, 1
addi x3, x2, 0
add x2, x1, x2
addi x1, x3, 0
blt x4, x5, start_loop

done:
jal x0, 0

# expected result
# the 17th (or whatever value was in x5) Fibonacci number in x1

# machine code and disassembly
#   0:   01100293                li      t0,17
#   4:   00000093                li      ra,0
#   8:   00100113                li      sp,1
#   c:   00520c63                beq     tp,t0,24 <done>
# 00000010 <start_loop>:
#  10:   00120213                add     tp,tp,1 # 1 <_start+0x1>
#  14:   00010193                mv      gp,sp
#  18:   00208133                add     sp,ra,sp
#  1c:   00018093                mv      ra,gp
#  20:   fe5248e3                blt     tp,t0,10 <start_loop>
# 00000024 <done>:
#  24:   0000006f                j       24 <done>
