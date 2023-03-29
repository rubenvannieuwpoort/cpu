; compile with "python sas.py test.asm"
; output is written to stdout and should be copied to fetch.vhd
setbyte0 r0, 0x67
setbyte0 r1, 0xef
setbyte0 r2, 0xea
setbyte1 r0, 0x45
setbyte1 r1, 0xcd
setbyte1 r2, 0x0c
setbyte2 r0, 0x23
setbyte2 r1, 0xab
setbyte2 r2, 0x7c
setbyte3 r0, 0x01
setbyte3 r1, 0x89
setbyte3 r2, 0x55
add r0, r1
xor r0, r2
