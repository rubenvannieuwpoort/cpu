setunsigned r4, 5
shl r4, 8
setunsigned r5, 45
shl r5, 4
setunsigned r6, 10
setunsigned r7, 9
setunsigned r8, 8
xor r2, r2
xor r1, r1
xor r0, r0
copy r3, r0
xor r3, r1
storebyte r3, r2
increment r0
increment r2
cmp r0, r4
branch_b r6
increment r1
cmp r1, r5
branch_b r7
branch r8
