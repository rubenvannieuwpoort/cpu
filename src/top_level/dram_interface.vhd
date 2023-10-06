library ieee;
use ieee.std_logic_1164.all;

use work.top_level_types.all;


entity dram_interface is
	port(
		clks_in: in memory_clock_signals;

		p0_cmd_clk_in: in std_logic;
		p0_read_clk_in: in std_logic;
		p0_write_clk_in: in std_logic;
		p0_in: in dram_port;
		p0_status_out: out dram_port_status;
	
		p1_cmd_clk_in: in std_logic;
		p1_read_clk_in: in std_logic;
		p1_write_clk_in: in std_logic;
		p1_in: in dram_port;
		p1_status_out: out dram_port_status;

		ram_out: out ram_signals;
		ram_bus: inout ram_bus_signals;
		calib_done_out: out std_logic;
		reset_in: in std_logic
	);
end dram_interface;

architecture Behavioral of dram_interface is
	component dram
		generic(
			C3_P0_MASK_SIZE: integer := 4;
			C3_P0_DATA_PORT_SIZE: integer := 32;
			C3_P1_MASK_SIZE: integer := 4;
			C3_P1_DATA_PORT_SIZE: integer := 32;
			C3_MEMCLK_PERIOD: integer := 20000;
			C3_RST_ACT_LOW: integer := 0;
			C3_INPUT_CLK_TYPE: string := "SINGLE_ENDED";
			C3_CALIB_SOFT_IP: string := "TRUE";
			C3_SIMULATION: string := "FALSE";
			DEBUG_EN: integer := 1;
			C3_MEM_ADDR_ORDER: string := "ROW_BANK_COLUMN";
			C3_NUM_DQ_PINS: integer := 16;
			C3_MEM_ADDR_WIDTH: integer := 13;
			C3_MEM_BANKADDR_WIDTH: integer := 2
		);
		port (
			async_rst: in std_logic;
			sysclk_2x: in std_logic;
			sysclk_2x_180: in std_logic;
			pll_ce_0: in std_logic;
			pll_ce_90: in std_logic;
			pll_lock: in std_logic;
			c3_mcb_drp_clk: in std_logic;
			mcb3_dram_dq: inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
			mcb3_dram_a: out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
			mcb3_dram_ba: out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
			mcb3_dram_cke: out std_logic;
			mcb3_dram_ras_n: out std_logic;
			mcb3_dram_cas_n: out std_logic;
			mcb3_dram_we_n: out std_logic;
			mcb3_dram_dm: out std_logic;
			mcb3_dram_udqs: inout std_logic;
			mcb3_rzq: inout std_logic;
			mcb3_dram_udm: out std_logic;
			c3_sys_clk: in std_logic;
			c3_sys_rst_i: in std_logic;
			c3_calib_done: out std_logic;
			c3_rst0: out std_logic;
			mcb_drp_clk: out std_logic;
			mcb3_dram_dqs: inout std_logic;
			mcb3_dram_ck: out std_logic;
			mcb3_dram_ck_n: out std_logic;
			c3_p0_cmd_clk: in std_logic;
			c3_p0_cmd_en: in std_logic;
			c3_p0_cmd_instr: in std_logic_vector(2 downto 0);
			c3_p0_cmd_bl: in std_logic_vector(5 downto 0);
			c3_p0_cmd_byte_addr: in std_logic_vector(29 downto 0);
			c3_p0_cmd_empty: out std_logic;
			c3_p0_cmd_full: out std_logic;
			c3_p0_wr_clk: in std_logic;
			c3_p0_wr_en: in std_logic;
			c3_p0_wr_mask: in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
			c3_p0_wr_data: in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
			c3_p0_wr_full: out std_logic;
			c3_p0_wr_empty: out std_logic;
			c3_p0_wr_count: out std_logic_vector(6 downto 0);
			c3_p0_wr_underrun: out std_logic;
			c3_p0_wr_error: out std_logic;
			c3_p0_rd_clk: in std_logic;
			c3_p0_rd_en: in std_logic;
			c3_p0_rd_data: out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
			c3_p0_rd_full: out std_logic;
			c3_p0_rd_empty: out std_logic;
			c3_p0_rd_count: out std_logic_vector(6 downto 0);
			c3_p0_rd_overflow: out std_logic;
			c3_p0_rd_error: out std_logic;
			c3_p1_cmd_clk: in std_logic;
			c3_p1_cmd_en: in std_logic;
			c3_p1_cmd_instr: in std_logic_vector(2 downto 0);
			c3_p1_cmd_bl: in std_logic_vector(5 downto 0);
			c3_p1_cmd_byte_addr: in std_logic_vector(29 downto 0);
			c3_p1_cmd_empty: out std_logic;
			c3_p1_cmd_full: out std_logic;
			c3_p1_wr_clk: in std_logic;
			c3_p1_wr_en: in std_logic;
			c3_p1_wr_mask: in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
			c3_p1_wr_data: in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
			c3_p1_wr_full: out std_logic;
			c3_p1_wr_empty: out std_logic;
			c3_p1_wr_count: out std_logic_vector(6 downto 0);
			c3_p1_wr_underrun: out std_logic;
			c3_p1_wr_error: out std_logic;
			c3_p1_rd_clk: in std_logic;
			c3_p1_rd_en: in std_logic;
			c3_p1_rd_data: out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
			c3_p1_rd_full: out std_logic;
			c3_p1_rd_empty: out std_logic;
			c3_p1_rd_count: out std_logic_vector(6 downto 0);
			c3_p1_rd_overflow: out std_logic;
			c3_p1_rd_error: out std_logic
		);
	end component;
begin
	dram_inst : dram port map(
		async_rst => '0',
		sysclk_2x => clks_in.sysclk_2x,
		sysclk_2x_180 => clks_in.sysclk_2x_180,
		pll_ce_0 => clks_in.pll_ce_0,
		pll_ce_90 => clks_in.pll_ce_90,
		pll_lock => clks_in.pll_lock,
		c3_mcb_drp_clk => clks_in.mcb_drp_clk,

		c3_sys_clk => '0',
		c3_sys_rst_i => reset_in,

		mcb_drp_clk => open,
		c3_rst0 => open,
		c3_calib_done => calib_done_out,

		mcb3_dram_dq => ram_bus.dq,
		mcb3_dram_a => ram_out.a,
		mcb3_dram_ba => ram_out.ba,
		mcb3_dram_ras_n => ram_out.ras_n,
		mcb3_dram_cas_n => ram_out.cas_n,
		mcb3_dram_we_n => ram_out.we_n,
		mcb3_dram_cke => ram_out.cke,
		mcb3_dram_ck => ram_out.ck,
		mcb3_dram_ck_n => ram_out.ck_n,
		mcb3_dram_dqs => ram_bus.dqs,
		mcb3_dram_udqs => ram_bus.udqs,
		mcb3_dram_udm => ram_out.udm,
		mcb3_dram_dm => ram_out.dm,
		mcb3_rzq => ram_bus.rzq,

		c3_p0_cmd_clk => p0_cmd_clk_in,
		c3_p0_cmd_en => p0_in.command_enable,
		c3_p0_cmd_instr => p0_in.command,
		c3_p0_cmd_bl => p0_in.burst_length,
		c3_p0_cmd_byte_addr => p0_in.address,
		c3_p0_cmd_empty => p0_status_out.command_empty,
		c3_p0_cmd_full => p0_status_out.command_full,

		c3_p0_wr_clk => p0_write_clk_in,
		c3_p0_wr_en => p0_in.write_enable,
		c3_p0_wr_mask => p0_in.write_mask,
		c3_p0_wr_data => p0_in.write_data,
		c3_p0_wr_full => p0_status_out.write_full,
		c3_p0_wr_empty => p0_status_out.write_empty,
		c3_p0_wr_count => p0_status_out.write_count,
		c3_p0_wr_underrun => p0_status_out.write_underrun,
		c3_p0_wr_error => p0_status_out.write_error,

		c3_p0_rd_clk => p0_read_clk_in,
		c3_p0_rd_en => p0_in.read_enable,
		c3_p0_rd_data => p0_status_out.read_data,
		c3_p0_rd_full => p0_status_out.read_full,
		c3_p0_rd_empty => p0_status_out.read_empty,
		c3_p0_rd_count => p0_status_out.read_count,
		c3_p0_rd_overflow => p0_status_out.read_overflow,
		c3_p0_rd_error => p0_status_out.read_error,

		c3_p1_cmd_clk => p1_cmd_clk_in,
		c3_p1_cmd_en => p1_in.command_enable,
		c3_p1_cmd_instr => p1_in.command,
		c3_p1_cmd_bl => p1_in.burst_length,
		c3_p1_cmd_byte_addr => p1_in.address,
		c3_p1_cmd_empty => p1_status_out.command_empty,
		c3_p1_cmd_full => p1_status_out.command_full,

		c3_p1_wr_clk => p1_write_clk_in,
		c3_p1_wr_en => p1_in.write_enable,
		c3_p1_wr_mask => p1_in.write_mask,
		c3_p1_wr_data => p1_in.write_data,
		c3_p1_wr_full => p1_status_out.write_full,
		c3_p1_wr_empty => p1_status_out.write_empty,
		c3_p1_wr_count => p1_status_out.write_count,
		c3_p1_wr_underrun => p1_status_out.write_underrun,
		c3_p1_wr_error => p1_status_out.write_error,

		c3_p1_rd_clk => p1_read_clk_in,
		c3_p1_rd_en => p1_in.read_enable,
		c3_p1_rd_data => p1_status_out.read_data,
		c3_p1_rd_full => p1_status_out.read_full,
		c3_p1_rd_empty => p1_status_out.read_empty,
		c3_p1_rd_count => p1_status_out.read_count,
		c3_p1_rd_overflow => p1_status_out.read_overflow,
		c3_p1_rd_error => p1_status_out.read_error
	);
end Behavioral;
