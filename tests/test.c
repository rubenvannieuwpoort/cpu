void _start(void) {
	while (1) {
		unsigned int *p = 36000;
		for (unsigned int y = 0; y < 240; y++) {
			for (unsigned int x = 0; x < 320; x++) {
				*p++ = x << 5;
			}
		}
	}
}

// disassembly:
//
//00000000 <_start>:
//   0:   000036b7                lui     a3,0x3
//   4:   000545b7                lui     a1,0x54
//   8:   80068693                add     a3,a3,-2048 # 2800 <.L3+0x27e0>
//   c:   ca058593                add     a1,a1,-864 # 53ca0 <.L3+0x53c80>
//
//00000010 <.L4>:
//  10:   00009637                lui     a2,0x9
//  14:   ca060613                add     a2,a2,-864 # 8ca0 <.L3+0x8c80>
//
//00000018 <.L2>:
//  18:   00060713                mv      a4,a2
//  1c:   00000793                li      a5,0
//
//00000020 <.L3>:
//  20:   00f72023                sw      a5,0(a4)
//  24:   02078793                add     a5,a5,32
//  28:   00470713                add     a4,a4,4
//  2c:   fed79ae3                bne     a5,a3,20 <.L3>
//  30:   50060613                add     a2,a2,1280
//  34:   feb612e3                bne     a2,a1,18 <.L2>
//  38:   fd9ff06f                j       10 <.L4>
