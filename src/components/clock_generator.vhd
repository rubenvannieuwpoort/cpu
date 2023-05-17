library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use work.types.all;


entity clock_generator is
	port(
		clk_in: in std_logic;
		clk_main: out std_logic;
		clk_mem: out memory_clock_signals;
		clk_pixel: out std_logic
	);
end entity;


architecture Behavioral of clock_generator is
	signal clk_2x_0: std_logic;
	signal clk_2x_180: std_logic;

	signal clk0_bufg_in, clk1_bufg_in: std_logic;
	signal mcb_drp_clk_bufg_in: std_logic;
	signal clkfbout_clkfbin: std_logic;
	signal clk_in_ibufg: std_logic;
	signal locked: std_logic;
	signal bufpll_mcb_locked: std_logic;
	signal mcb_drp_clk_sig: std_logic;
begin 
	clk_mem.pll_lock <= bufpll_mcb_locked;
	clk_mem.mcb_drp_clk <= mcb_drp_clk_sig;

	u_ibufg_clk_in: IBUFG
		port map(
			I => clk_in,
			O => clk_in_ibufg
		);

	u_pll_adv: PLL_ADV 
		generic map(
			BANDWIDTH => "OPTIMIZED",
			CLKIN1_PERIOD => 10.0,
			CLKIN2_PERIOD => 10.0,
			CLKOUT0_DIVIDE => 4,
			CLKOUT1_DIVIDE => 4,
			CLKOUT2_DIVIDE => 4,
			CLKOUT3_DIVIDE => 24,
			CLKOUT4_DIVIDE => 8,
			CLKOUT5_DIVIDE => 1,
			CLKOUT0_PHASE => 0.000,
			CLKOUT1_PHASE => 180.000,
			CLKOUT2_PHASE => 0.000,
			CLKOUT3_PHASE => 0.000,
			CLKOUT4_PHASE => 0.000,
			CLKOUT5_PHASE => 0.000,
			CLKOUT0_DUTY_CYCLE => 0.500,
			CLKOUT1_DUTY_CYCLE => 0.500,
			CLKOUT2_DUTY_CYCLE => 0.500,
			CLKOUT3_DUTY_CYCLE => 0.500,
			CLKOUT4_DUTY_CYCLE => 0.500,
			CLKOUT5_DUTY_CYCLE => 0.500,
			SIM_DEVICE => "SPARTAN6",
			COMPENSATION => "INTERNAL",
			DIVCLK_DIVIDE => 2,
			CLKFBOUT_MULT => 12,
			CLKFBOUT_PHASE => 0.0,
			REF_JITTER => 0.005000
		)
		port map(
			CLKFBIN => clkfbout_clkfbin,
			CLKINSEL => '1',
			CLKIN1 => clk_in_ibufg,
			CLKIN2 => '0',
			DADDR => (others => '0'),
			DCLK => '0',
			DEN => '0',
			DI => (others => '0'),
			DWE => '0',
			REL => '0',
			RST => '0',
			CLKFBDCM => open,
			CLKFBOUT => clkfbout_clkfbin,
			CLKOUTDCM0 => open,
			CLKOUTDCM1 => open,
			CLKOUTDCM2 => open,
			CLKOUTDCM3 => open,
			CLKOUTDCM4 => open,
			CLKOUTDCM5 => open,
			CLKOUT0 => clk_2x_0,
			CLKOUT1 => clk_2x_180,
			CLKOUT2 => clk0_bufg_in,
			CLKOUT3 => mcb_drp_clk_bufg_in,
			CLKOUT4 => clk1_bufg_in,
			CLKOUT5 => open,
			DO => open,
			DRDY => open,
			LOCKED => locked
		);

	U_BUFG_CLK0: BUFG
		port map(
			O => clk_main,
			I => clk0_bufg_in
		);

	U_BUFG_CLK1: BUFGCE
		port map(
			O => mcb_drp_clk_sig,
			I => mcb_drp_clk_bufg_in,
			CE => locked
		);

	U_BUFG_CLK2: BUFG
		port map(
			O => clk_pixel,
			I => clk1_bufg_in
		);

	BUFPLL_MCB_INST: BUFPLL_MCB
		port map(
			IOCLK0 => clk_mem.sysclk_2x,
			IOCLK1 => clk_mem.sysclk_2x_180,
			LOCKED => locked,
			GCLK => mcb_drp_clk_sig,
			SERDESSTROBE0 => clk_mem.pll_ce_0,
			SERDESSTROBE1 => clk_mem.pll_ce_90,
			PLLIN0 => clk_2x_0,
			PLLIN1 => clk_2x_180,
			LOCK => bufpll_mcb_locked
		);
end architecture;
