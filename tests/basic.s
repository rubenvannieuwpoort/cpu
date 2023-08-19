.global	_start

.text
_start:
lui x1, 0x76543

addi x0, x1, -1
addi x1, x1, 0x210

auipc x2, 0x987

# expected result:
# x0	0x00000000
# x1	0x76543210
# x2	0x0098700c

# machine code and disassembly
#   0:   765430b7                lui     ra,0x76543
#   4:   fff08013                add     zero,ra,-1 # 76542fff <_start+0x76542fff>
#   8:   21008093                add     ra,ra,528
#   c:   00987117                auipc   sp,0x987
