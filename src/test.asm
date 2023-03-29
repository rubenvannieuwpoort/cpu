; compile with "python sas.py test.asm"
; output is written to stdout and should be copied to fetch.vhd
setbyte0 r0, 0x67
setbyte1 r0, 0x45
setbyte2 r0, 0x23
setbyte3 r0, 0x01
setbyte0 r1, 0xef
setbyte1 r1, 0xcd
setbyte2 r1, 0xab
setbyte3 r1, 0x89
add r0, r1
