; computes the 42th Fibonacci number in r0
; simulate until values in registers are stable, should run in ~4.5us
setunsigned r1, 1
setunsigned r3, 42
setunsigned r4, 1
setunsigned r5, 12
setunsigned r6, 8
setunsigned r7, 13
test r3, r3
branch r5  ; branch test
; begin_loop:
    copy r2, r1
    add r1, r0
    copy r0, r2
    subtract r3, r4

; test:
branch_nz r6  ; branch_nz begin_loop

; end:
branch r7  ; branch end