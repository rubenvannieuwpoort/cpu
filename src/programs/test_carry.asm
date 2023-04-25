; compile with "python sas.py test.asm"
; output is written to stdout and should be copied to fetch.vhd
setsigned r7, 34
setsigned r15, -23
add r7, r15
; carry flag should be set
