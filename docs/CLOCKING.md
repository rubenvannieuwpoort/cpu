The top module implements the clock generator component and uses the output clocks for the CPU, the memory interface, and the VGA signal generation.

The clock settings are hardcoded in the clock generator (e.g. not configurable). If you make changes to the memory or VGA signal generation that require a different clock, you will need to dive in clock_generator.vhd. Luckily it's quite simple.

For the clock signal generation, the `PLL_ADV` primitive is used. It derives up to 6 clock signals from 1 input clock signal, using a phase-locked loop.

The frequency of the PLL will be `PLL_FREQ = (INPUT_FREQUENCY * CLKFBOUT_MULT) / DIVCLK_DIVIDE`. The frequency of the clock signal N will then be `PLL_FREQ / CLKOUT<N>_DIVIDE`.

For the Mimas v2, the built-in crystal has a frequency of 100 MHz, so `INPUT_FREQUENCY = 100 MHz`. With the current settings `CLKFBOUT_MULT = 12` and `DIVCLK_DIVIDE = 2` the formula for the frequency of clock signal N becomes `CLOCK<N>_FREQ = 600 / CLKOUT<N>_DIVIDE`.

Currently clock signals 0, 1, and 3 are used for the memory clock (150 MHz). Clock signal 2 is used for the main clock (600 / 4 = 150 MHz), and clock signal 4 is used for the pixel clock (600 / 8 = 75 MHz).
