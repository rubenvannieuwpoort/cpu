library ieee;
use ieee.std_logic_1164.all;

use work.types.all;


entity memory_interface is
	port(
		clk: in memory_clock_signals;
		write_port_clk_in: in std_logic;
		write_port_in: in write_cmd_signals;
		write_status_out: out write_status_signals;
		read_port_clk_in: in std_logic;
		read_port_in: in read_cmd_signals;
		read_status_out: out read_status_signals;
		ram_out: out ram_signals;
		ram_bus: inout ram_bus_signals;
		calib_done: out std_logic;
		reset_in: in std_logic
	);
end memory_interface;

architecture Behavioral of memory_interface is
	signal p0_cmd_instr: std_logic_vector(2 downto 0) := "000";

component mem32
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
		c3_clk0: out std_logic;
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
	p0_cmd_instr <= "00" & read_port_in.enable; -- read when read_cmd.enable is set, otherwise write

	u_mem32 : mem32
		port map(
			async_rst => '0',
			sysclk_2x => clk.sysclk_2x,
			sysclk_2x_180 => clk.sysclk_2x_180,
			pll_ce_0 => clk.pll_ce_0,
			pll_ce_90 => clk.pll_ce_90,
			pll_lock => clk.pll_lock,
			c3_mcb_drp_clk => clk.mcb_drp_clk,

			c3_sys_clk => '0',
			c3_sys_rst_i => reset_in,

			c3_clk0 => open,
			mcb_drp_clk => open,
			c3_rst0 => open,
			c3_calib_done => calib_done,

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

			c3_p0_cmd_clk => write_port_clk_in,
			c3_p0_cmd_en => write_port_in.enable,
			c3_p0_cmd_instr => "000", -- write
			c3_p0_cmd_bl => "000000", -- 1 word
			c3_p0_cmd_byte_addr => write_port_in.address,
			c3_p0_cmd_empty => write_status_out.cmd_empty,
			c3_p0_cmd_full => write_status_out.cmd_full,

			c3_p0_wr_clk => write_port_clk_in,
			c3_p0_wr_en => write_port_in.data_enable,
			c3_p0_wr_mask => write_port_in.write_mask,
			c3_p0_wr_data => write_port_in.data,
			c3_p0_wr_full => write_status_out.data_full,
			c3_p0_wr_empty => write_status_out.data_empty,
			c3_p0_wr_count => write_status_out.data_count,
			c3_p0_wr_underrun => write_status_out.underrun,
			c3_p0_wr_error => write_status_out.error,

			c3_p0_rd_clk => write_port_clk_in,
			c3_p0_rd_en => '0',
			c3_p0_rd_data => open, --read_status_0_out.data,
			c3_p0_rd_full => open, --read_status_0_out.data_full,
			c3_p0_rd_empty => open, --read_status_0_out.data_empty,
			c3_p0_rd_count => open, --read_status_0_out.data_count,
			c3_p0_rd_overflow => open, --read_status_0_out.overflow,
			c3_p0_rd_error => open, --read_status_0_out.error,

			c3_p1_cmd_clk => read_port_clk_in,
			c3_p1_cmd_en => read_port_in.enable,
			c3_p1_cmd_instr => "001",  -- read
			c3_p1_cmd_bl => "001111",  -- 16 words
			c3_p1_cmd_byte_addr => read_port_in.address,
			c3_p1_cmd_empty => read_status_out.cmd_empty,
			c3_p1_cmd_full => read_status_out.cmd_full,

			c3_p1_wr_clk => read_port_clk_in,
			c3_p1_wr_en => '0',
			c3_p1_wr_mask => (others => '0'),
			c3_p1_wr_data => (others => '0'),
			c3_p1_wr_full => open,
			c3_p1_wr_empty => open,
			c3_p1_wr_count => open,
			c3_p1_wr_underrun => open,
			c3_p1_wr_error => open,

			c3_p1_rd_clk => read_port_clk_in,
			c3_p1_rd_en => read_port_in.data_enable,
			c3_p1_rd_data => read_status_out.data,
			c3_p1_rd_full => read_status_out.data_full,
			c3_p1_rd_empty => read_status_out.data_empty,
			c3_p1_rd_count => read_status_out.data_count,
			c3_p1_rd_overflow => read_status_out.overflow,
			c3_p1_rd_error => read_status_out.error
		);

end Behavioral;
