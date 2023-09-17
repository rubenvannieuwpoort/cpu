library ieee;
use ieee.std_logic_1164.all;

use work.types.all;


entity memory_interface is
	port(
		clk: in memory_clock_signals;

		read_write_port_clk_in: in std_logic;
		--read_write_port_in: in read_write_cmd_signals;
		--read_write_status_out: out read_write_status_signals;

		read_write_port_in: in read_write_port := DEFAULT_READ_WRITE_PORT;
		read_write_status_out: out read_write_status := DEFAULT_READ_WRITE_STATUS;

		-- for vga signal
		read_port_clk_in: in std_logic;
		read_port_in: in read_cmd_signals;
		read_status_out: out read_status_signals;
		ram_out: out ram_signals;
		ram_bus: inout ram_bus_signals;
		calib_done_out: out std_logic := '0';
		reset_in: in std_logic
	);
end memory_interface;

architecture Behavioral of memory_interface is
	constant STATE_INITIALIZE: std_logic_vector(1 downto 0) := "00";
	constant STATE_READY: std_logic_vector(1 downto 0) := "01";
	constant STATE_READING: std_logic_vector(1 downto 0) := "10";
	constant STATE_WRITING: std_logic_vector(1 downto 0) := "11";
	signal p0_state: std_logic_vector(1 downto 0) := STATE_INITIALIZE;

	signal calib_done: std_logic := '0';

	signal c3_p0_cmd_en: std_logic := '0';
	signal c3_p0_cmd_instr: std_logic_vector(2 downto 0) := "000";
	signal c3_p0_cmd_byte_addr: std_logic_vector(29 downto 0) := (others => '0');
	signal c3_p0_cmd_empty: std_logic := '0';
	signal c3_p0_cmd_full: std_logic := '0';
	signal c3_p0_wr_en: std_logic := '0';
	signal c3_p0_wr_mask: std_logic_vector(3 downto 0) := "1111";
	signal c3_p0_wr_data: std_logic_vector(31 downto 0) := (others => '0');
	signal c3_p0_wr_full: std_logic := '0';
	signal c3_p0_wr_empty: std_logic := '0';
	signal c3_p0_wr_count: std_logic_vector(6 downto 0) := (others => '0');
	signal c3_p0_rd_data: std_logic_vector(31 downto 0) := (others => '0');
	signal c3_p0_rd_full: std_logic := '0';
	signal c3_p0_rd_empty: std_logic := '0';
	signal c3_p0_rd_count: std_logic_vector(6 downto 0) := (others => '0');

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
	u_mem32 : mem32 port map(
		async_rst => '0',
		sysclk_2x => clk.sysclk_2x,
		sysclk_2x_180 => clk.sysclk_2x_180,
		pll_ce_0 => clk.pll_ce_0,
		pll_ce_90 => clk.pll_ce_90,
		pll_lock => clk.pll_lock,
		c3_mcb_drp_clk => clk.mcb_drp_clk,

		c3_sys_clk => '0',
		c3_sys_rst_i => reset_in,

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

		c3_p0_cmd_clk => read_write_port_clk_in,
		c3_p0_cmd_en => c3_p0_cmd_en,
		c3_p0_cmd_instr => c3_p0_cmd_instr,
		c3_p0_cmd_bl => "000000", -- 1 word
		c3_p0_cmd_byte_addr => c3_p0_cmd_byte_addr,
		c3_p0_cmd_empty => c3_p0_cmd_empty,
		c3_p0_cmd_full => c3_p0_cmd_full,

		c3_p0_wr_clk => read_write_port_clk_in,
		c3_p0_wr_en => c3_p0_wr_en,
		c3_p0_wr_mask => c3_p0_wr_mask,
		c3_p0_wr_data => c3_p0_wr_data,
		c3_p0_wr_full => c3_p0_wr_full,
		c3_p0_wr_empty => c3_p0_wr_empty,
		c3_p0_wr_count => c3_p0_wr_count,
		c3_p0_wr_underrun => read_write_status_out.write_underrun,
		c3_p0_wr_error => read_write_status_out.write_error,

		c3_p0_rd_clk => read_write_port_clk_in,
		c3_p0_rd_en => '1',
		c3_p0_rd_data => c3_p0_rd_data,
		c3_p0_rd_full => c3_p0_rd_full,
		c3_p0_rd_empty => c3_p0_rd_empty,
		c3_p0_rd_count => c3_p0_rd_count,
		c3_p0_rd_overflow => read_write_status_out.read_overflow,
		c3_p0_rd_error => read_write_status_out.read_error,

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

	process(clk)
	begin
		if rising_edge(read_write_port_clk_in) then
			if p0_state = STATE_INITIALIZE then
				if calib_done = '1' then
					p0_state <= STATE_READY;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '1';

					calib_done_out <= '1';
				else
					p0_state <= STATE_INITIALIZE;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '0';
				end if;
			elsif p0_state = STATE_READY then
				if read_write_port_in.enable = '1' and read_write_port_in.command = CMD_READ then
					-- read
					p0_state <= STATE_READING;

					c3_p0_cmd_en <= '1';
					c3_p0_cmd_instr <= "001";
					c3_p0_cmd_byte_addr <= "000" & read_write_port_in.address & "00";
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '0';
				elsif read_write_port_in.enable = '1' and read_write_port_in.command = CMD_WRITE then
					-- write
					p0_state <= STATE_WRITING;

					c3_p0_cmd_en <= '1';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= "000" & read_write_port_in.address & "00";
					c3_p0_wr_en <= '1';
					c3_p0_wr_mask <= not(read_write_port_in.write_mask);
					c3_p0_wr_data <= read_write_port_in.write_data;

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '0';
				else
					-- no-op
					p0_state <= STATE_READY;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '1';
				end if;
			elsif p0_state = STATE_READING then
				if c3_p0_rd_empty = '0' and c3_p0_cmd_empty = '1' then
					-- read data ready
					p0_state <= STATE_READY;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= c3_p0_rd_data;
					read_write_status_out.data_valid <= '1';
					read_write_status_out.ready <= '1';
				else
					-- read data not ready
					p0_state <= STATE_READING;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '0';
				end if;
			elsif p0_state = STATE_WRITING then
				if c3_p0_wr_empty = '1' and c3_p0_cmd_empty = '1' then
					-- write handled
					p0_state <= STATE_READY;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '1';
				else
					-- write still pending
					p0_state <= STATE_WRITING;

					c3_p0_cmd_en <= '0';
					c3_p0_cmd_instr <= "000";
					c3_p0_cmd_byte_addr <= (others => '0');
					c3_p0_wr_en <= '0';
					c3_p0_wr_mask <= "1111";
					c3_p0_wr_data <= (others => '0');

					read_write_status_out.read_data <= (others => '0');
					read_write_status_out.data_valid <= '0';
					read_write_status_out.ready <= '0';
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;
