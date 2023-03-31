; computes the 42th Fibonacci number in r0
; simulate until values in registers are stable, should run in ~7us
setbyte0 r1, 1
setbyte0 r3, 42
setunsigned r4, 1
setunsigned r5, 5
setunsigned r6, 12
test r3, r3
branch_z r6
copy r2, r1
add r1, r0
copy r0, r2
subtract r3, r4
branch r5
branch r6
