library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_level_types.all;
use work.top_level_constants.all;


entity testbench is
end testbench;


architecture Behavioral of testbench is
	signal clk_sys: std_logic := '0';
	constant clk_period: time := 10 ns;

	-- LEDs
	signal leds_out: std_logic_vector(7 downto 0);

	-- clocks
	signal clk_main, clk_pixel: std_logic;
	signal clk_mem: memory_clock_signals;

	-- memory
	signal memory_ready: std_logic;

	signal read_write_port_s: memory_port;
	signal read_write_status_s: memory_port_status;

	signal boot_ram_port: bram_port;
	signal boot_ram_read_data: std_logic_vector(31 downto 0);

	signal font_ram_port: bram_port;
	signal font_ram_read_data: std_logic_vector(31 downto 0);

	signal textbuffer_ram_port: bram_port;
	signal textbuffer_ram_read_data: std_logic_vector(31 downto 0);

	component clock_generator is
		port(
			clk_in: in std_logic;
			clk_main: out std_logic;
			clk_mem: out memory_clock_signals;
			clk_pixel: out std_logic
		);
	end component;

	component core is
		port(
			clk: in std_logic;
			data_port_out: out memory_port;
			data_port_status_in: in memory_port_status;
			leds_out: out std_logic_vector(0 to 7)
		);
	end component;

	component memory_interface is
		port(
			clk: in std_logic;
			mem_p0_in: in memory_port := DEFAULT_MEMORY_PORT;
			mem_p0_status_out: out memory_port_status := DEFAULT_MEMORY_PORT_STATUS;
			dram_p0_out: out dram_port := DEFAULT_DRAM_PORT;
			dram_p0_status_in: in dram_port_status;
			bootram_port_out: out bram_port := DEFAULT_BRAM_PORT;
			bootram_data_in: in std_logic_vector(31 downto 0);
			fontram_port_out: out bram_port := DEFAULT_BRAM_PORT;
			fontram_data_in: in std_logic_vector(31 downto 0);
			textbuffer_port_out: out bram_port := DEFAULT_BRAM_PORT;
			textbuffer_data_in: in std_logic_vector(31 downto 0);
			calib_done_in: in std_logic;
			memory_ready_out: out std_logic
		);
	end component;

	component boot_ram is
		port(
			clk_0: in std_logic;
			port_0: in bram_port;
			p0_read_data: out std_logic_vector(31 downto 0);
			clk_1: in std_logic;
			port_1: in bram_port;
			p1_read_data: out std_logic_vector(31 downto 0)
		);
	end component;

	component font_ram is
		port(
			clk_0: in std_logic;
			port_0: in bram_port;
			p0_read_data: out std_logic_vector(31 downto 0);
			clk_1: in std_logic;
			port_1: in bram_port;
			p1_read_data: out std_logic_vector(31 downto 0)
		);
	end component;

	component textbuffer_ram is
		port(
			clk_0: in std_logic;
			port_0: in bram_port;
			p0_read_data: out std_logic_vector(31 downto 0);
			clk_1: in std_logic;
			port_1: in bram_port;
			p1_read_data: out std_logic_vector(31 downto 0)
		);
	end component;
begin
	clk_process :process
	begin
		wait for clk_period / 2;
		clk_sys <= '1';
		wait for clk_period / 2;
		clk_sys <= '0';
	end process;

	clock_generator_inst: clock_generator port map(
		clk_in => clk_sys,
		clk_main => clk_main,
		clk_mem => clk_mem,
		clk_pixel => clk_pixel
	);

	core_inst: core port map(
		clk => clk_main,
		data_port_out => read_write_port_s,
		data_port_status_in => read_write_status_s,
		leds_out => leds_out
	);

	memory_interface_inst: memory_interface port map(
		clk => clk_main,
		mem_p0_in => read_write_port_s,
		mem_p0_status_out => read_write_status_s,
		dram_p0_out => open,
		dram_p0_status_in => DEFAULT_DRAM_PORT_STATUS,
		bootram_port_out => boot_ram_port,
		bootram_data_in => boot_ram_read_data,
		fontram_port_out => font_ram_port,
		fontram_data_in => font_ram_read_data,
		textbuffer_port_out => textbuffer_ram_port,
		textbuffer_data_in => textbuffer_ram_read_data,
		calib_done_in => '1',
		memory_ready_out => memory_ready
	);

	boot_ram_inst: boot_ram port map(
		clk_0 => clk_main,
		port_0 => boot_ram_port,
		p0_read_data => boot_ram_read_data,
		clk_1 => '0',
		port_1 => DEFAULT_BRAM_PORT,
		p1_read_data => open
	);

	font_ram_inst: font_ram port map(
		clk_0 => clk_main,
		port_0 => font_ram_port,
		p0_read_data => font_ram_read_data,
		clk_1 => '0',
		port_1 => DEFAULT_BRAM_PORT,
		p1_read_data => open
	);

	textbuffer_ram_inst: textbuffer_ram port map(
		clk_0 => clk_main,
		port_0 => textbuffer_ram_port,
		p0_read_data => textbuffer_ram_read_data,
		clk_1 => '0',
		port_1 => DEFAULT_BRAM_PORT,
		p1_read_data => open
	);
end Behavioral;
