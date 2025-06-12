# Vulture CPU

This is a VHDL implementation of a pipelined [RISC-V](https://en.wikipedia.org/wiki/RISC-V) processor. The design currently targets the [Mimas v2](https://numato.com/product/mimas-v2-spartan-6-fpga-development-board-with-ddr-sdram/).

There is still a lot to do before this will be a somewhat usable CPU (see the last section of this document), so it's maybe more enlightening to focus on what the Vulture CPU (in its current form) *can do*:
- All RISC-V instructions in the RVI32 set are implemented.
- Display video output in a 640x480 resolution with 256 colors. It can do simple animation at about 10 fps.
- Display text mode output. (Switching between video modes or text mode needs to be done in the design, it can't be done from within a program.)
- CSRs are implemented in a minimal, but (as far as I know) spec-compliant way.

The most notable omissions are any form of input, caches, reading instructions from RAM (the executed program is currently read from a hardcoded ROM), and exceptions.

For more documentation, see the docs/vulture folder.


## Synthesis

The design currently uses Xilinx IP for the memory controller, which some custom adjustments to it. I still need to document how this can be generated and modified so the whole design can be synthesized.


## Todo
- Set up some tools to conveniently program and test in C or assembly.
- Implement timers.
- Implement SD card controller.
- Implement the "M" extension (multiplication and division instructions).
- Add a data cache.
- Add an instruction cache.
- Add PS/2 keyboard interface.
- Unify the text mode and screenbuffer mode VGA generators.
- Add some mechanism to switch between text mode and screenbuffer mode.
- Add video modes with lower resolution.
- Add some mechanism to switch video modes.
- Port the design to the miniSpartan 6+.
- Implement DVI/HDMI video output.
- Add 24 bpp video modes.
- Add an indexed color mode with 256 colors, so 1 byte per pixel can be used.
