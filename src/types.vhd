library ieee;
use ieee.std_logic_1164.all;


package types is
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

	constant CMD_READ: std_logic := '0';
	constant CMD_WRITE: std_logic := '1';

	type read_cmd_signals is record
		enable: std_logic;
		data_enable: std_logic;
		address: std_logic_vector(29 downto 0);
	end record;

	type read_status_signals is record
		cmd_full: std_logic;
		cmd_empty: std_logic;
		data: std_logic_vector(31 downto 0);
		data_full: std_logic;
		data_empty: std_logic;
		data_count: std_logic_vector(6 downto 0);
		error: std_logic;
		overflow: std_logic;
	end record;

	type branch_data is record
		indicator: std_logic;
		address: std_logic_vector(31 downto 0);
	end record;

	constant DEFAULT_BRANCH_DATA: branch_data := (
		indicator => '0',
		address => (others => '0')
	);

	type branch_signals is record
		data: branch_data;
		stamp: std_logic_vector(2 downto 0);
	end record;

	constant DEFAULT_BRANCH_SIGNALS: branch_signals := (
		data => DEFAULT_BRANCH_DATA,
		stamp => (others => '0')
	);

	type read_write_port is record
		enable: std_logic;
		command: std_logic;
		address: std_logic_vector(26 downto 2);
		write_data: std_logic_vector(31 downto 0);
		write_mask: std_logic_vector(3 downto 0);
	end record;

	constant DEFAULT_READ_WRITE_PORT: read_write_port := (
		enable => '0',
		command => '0',
		address => (others => '0'),
		write_data => (others => '0'),
		write_mask => (others => '0')
	);

	type read_write_status is record
		read_data: std_logic_vector(31 downto 0);
		data_valid: std_logic;
		ready: std_logic;
		read_overflow: std_logic;
		read_error: std_logic;
		write_underrun: std_logic;
		write_error: std_logic;
	end record;
	
	constant DEFAULT_READ_WRITE_STATUS: read_write_status := (
		read_data => (others => '0'),
		data_valid => '0',
		ready => '1',
		read_overflow => '0',
		read_error => '0',
		write_underrun => '0',
		write_error => '0'
	);

	type read_port is record
		act: std_logic;
		address: std_logic_vector(26 downto 2);
	end record;

	constant DEFAULT_READ_PORT: read_port := (
		act => '0',
		address => (others => '0')
	);

	type read_status is record
		read_data: std_logic_vector(31 downto 0);
		data_valid: std_logic;
		ready: std_logic;
	end record;

	constant DEFAULT_READ_STATUS: read_status := (
		read_data => (others => '0'),
		data_valid => '0',
		ready => '0'
	);

	type bram_port is record
		address: std_logic_vector(11 downto 2);
		data: std_logic_vector(31 downto 0);
		mask: std_logic_vector(0 to 3);
	end record;

	constant DEFAULT_BRAM_PORT: bram_port := (
		address => (others => '0'),
		data => (others => '0'),
		mask => (others => '0')
	);
end package;
