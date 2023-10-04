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

	signal textbuffer_port: bram_port;
	signal textbuffer_read_data: std_logic_vector(31 downto 0);

	-- vga
	signal vga: vga_signals;

	-- ram	
	signal dram_p0: dram_port;
	signal dram_p0_status: dram_port_status := DEFAULT_DRAM_PORT_STATUS;
	
	signal dram_p1: dram_port;
	signal dram_p1_status: dram_port_status := DEFAULT_DRAM_PORT_STATUS;
	
	signal calib_done: std_logic := '1';

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
			mem_p0_clk_in: in std_logic;
			mem_p0_in: in memory_port := DEFAULT_MEMORY_PORT;
			mem_p0_status_out: out memory_port_status := DEFAULT_MEMORY_PORT_STATUS;
			dram_p0_out: out dram_port := DEFAULT_DRAM_PORT;
			dram_p0_status_in: in dram_port_status;
			bram_port_out: out bram_port := DEFAULT_BRAM_PORT;
			bram_data_in: in std_logic_vector(31 downto 0);
			calib_done_in: in std_logic;
			memory_ready_out: out std_logic
		);
	end component;

	component text_buffer_ram is
		port(
			write_clk: in std_logic;
			write_address: in std_logic_vector(11 downto 2);
			write_mask: in std_logic_vector(0 to 3);
			write_data: in std_logic_vector(31 downto 0);
			read_data: out std_logic_vector(31 downto 0)
		);
	end component;
	
	component vga_generator is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			vga_out: out vga_signals;
			dram_port_out: out dram_port;
			dram_port_status_in: in dram_port_status
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

	mem_if: memory_interface port map(
		clk => clk_main,
		mem_p0_clk_in => clk_main,
		mem_p0_in => read_write_port_s,
		mem_p0_status_out => read_write_status_s,
		dram_p0_out => dram_p0,
		dram_p0_status_in => dram_p0_status,
		bram_port_out => textbuffer_port,
		bram_data_in => textbuffer_read_data,
		calib_done_in => calib_done,
		memory_ready_out => memory_ready
	);

	text_buffer_ram_inst: text_buffer_ram port map(
		write_clk => clk_main,
		write_address => textbuffer_port.address,
		write_data => textbuffer_port.data,
		write_mask => textbuffer_port.mask,
		read_data => textbuffer_read_data
	);

	vga_generator_inst: vga_generator port map(
		clk => clk_pixel,
		memory_ready_in => memory_ready,
		vga_out => vga,
		dram_port_out => dram_p1,
		dram_port_status_in => dram_p1_status
	);

	--leds_out <= read_status.overflow & read_status.error & read_write_status_s.read_overflow & read_write_status_s.read_error & read_write_status_s.write_underrun & read_write_status_s.write_error & "00";
end Behavioral;
