# Vulture CPU

This is a VHDL implementation of a pipelined [RISC-V](https://en.wikipedia.org/wiki/RISC-V) processor. The design currently targets the [Mimas v2](https://numato.com/product/mimas-v2-spartan-6-fpga-development-board-with-ddr-sdram/).


## Synthesis

The design currently uses Xilinx IP for the memory controller, which some custom adjustments to it. I still need to document how this can be generated and modified so the whole design can be synthesized.


## Todo
- Add a block RAM for the boot memory.
- Add a write-only block RAM for the text buffer.
- Add a write-only block RAM for the font RAM (optional).
- Set up a testbench with a DRAM module.
- Set up some tools to conveniently program and test in C or assembly.
- Implement CSRs.
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
- Remove the custom instructions to control the LEDs (added for debugging).
- Write a loader for ELF files.
- Write boot RAM.
- Write an OS/shell.
- Write some demo's. (rotozoomer, fire, water, swirl, 2d water, bumpmap, plasma, 3d?, tunnel, lens, flag, infinite sprites, teapot, explosion, mode 7, heightmapped terrain, point cloud, noise cloud, 3d translucency, raycaster, parallax, Mandelbrot zoomer, Julia animation)
