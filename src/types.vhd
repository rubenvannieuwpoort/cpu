library ieee;
use ieee.std_logic_1164.all;


package top_level_types is
	type memory_clock_signals is record
		sysclk_2x: std_logic;
		sysclk_2x_180: std_logic;
		pll_ce_0: std_logic;
		pll_ce_90: std_logic;
		pll_lock: std_logic;
		mcb_drp_clk: std_logic;
	end record;

	type vga_signals is record
		hsync: std_logic;
		vsync: std_logic;
		red: std_logic_vector(2 downto 0);
		green: std_logic_vector(2 downto 0);
		blue: std_logic_vector(2 downto 1);
	end record;

	type ram_signals is record
		a: std_logic_vector(12 downto 0);
		ba: std_logic_vector(1 downto 0);
		cke: std_logic;
		ras_n: std_logic;
		cas_n: std_logic;
		we_n: std_logic;
		dm: std_logic;
		udm: std_logic;
		ck: std_logic;
		ck_n: std_logic;
	end record;

	type ram_bus_signals is record
		dq: std_logic_vector(15 downto 0);
		udqs: std_logic;
		rzq: std_logic;
		dqs: std_logic;
	end record;

	-- Ports
	-- =====

	type memory_port is record
		enable: std_logic;
		command: std_logic;
		address: std_logic_vector(26 downto 2);
		write_data: std_logic_vector(31 downto 0);
		write_mask: std_logic_vector(3 downto 0);
	end record;

	type memory_port_status is record
		read_data: std_logic_vector(31 downto 0);
		data_valid: std_logic;
		ready: std_logic;
		read_overflow: std_logic;
		read_error: std_logic;
		write_underrun: std_logic;
		write_error: std_logic;
	end record;

	type dram_port is record
		command_enable: std_logic;
		command: std_logic_vector(2 downto 0);
		burst_length: std_logic_vector(5 downto 0);
		address: std_logic_vector(29 downto 0);
		write_enable: std_logic;
		write_mask: std_logic_vector(3 downto 0);
		write_data: std_logic_vector(31 downto 0);
		read_enable: std_logic;
	end record;
	
	type dram_port_status is record
		command_empty: std_logic;
		command_full: std_logic;
		write_full: std_logic;
		write_empty: std_logic;
		write_count: std_logic_vector(6 downto 0);
		write_underrun: std_logic;
		write_error: std_logic;
		read_data: std_logic_vector(31 downto 0);
		read_full: std_logic;
		read_empty: std_logic;
		read_count: std_logic_vector(6 downto 0);
		read_overflow: std_logic;
		read_error: std_logic;
	end record;

	type bram_port is record
		address: std_logic_vector(11 downto 2);
		data: std_logic_vector(31 downto 0);
		mask: std_logic_vector(0 to 3);
	end record;

end package;
