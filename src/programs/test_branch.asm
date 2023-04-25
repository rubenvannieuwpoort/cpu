; compile with "python sas.py test.asm"
; output is written to stdout and should be copied to fetch.vhd
setbyte0 r0, 2
setbyte0 r1, 1
-- r0 points to here:
add r2, r1
branch r0
; this program should count up in r2
