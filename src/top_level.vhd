library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

use work.types.all;


entity top_level is
	port(
		clk_sys: in std_logic;
		-- vga
		vga_hsync: out std_logic;
		vga_vsync: out std_logic;
		vga_red: out std_logic_vector(2 downto 0);
		vga_green: out std_logic_vector(2 downto 0);
		vga_blue: out std_logic_vector(2 downto 1);
		-- ram
		ram_dq: inout std_logic_vector(15 downto 0);
		ram_a: out std_logic_vector(12 downto 0);
		ram_ba: out std_logic_vector( 1 downto 0);
		ram_cke: out std_logic;
		ram_ras_n: out std_logic;
		ram_cas_n: out std_logic;
		ram_we_n: out std_logic;
		ram_dm: out std_logic;
		ram_udqs: inout std_logic;
		ram_rzq: inout std_logic;
		ram_udm: out std_logic;
		ram_dqs: inout std_logic;
		ram_ck: out std_logic;
		ram_ck_n: out std_logic
	);
end top_level;


architecture Behavioral of top_level is
	-- clocks
	signal clk_main, clk_pixel: std_logic;
	signal clk_mem: memory_clock_signals;

	signal memory_ready: std_logic;
	signal memory_written: std_logic;

	-- vga
	signal vga: vga_signals;

	-- ram
	signal ram: ram_signals;
	signal ram_bus: ram_bus_signals;

	-- read port
	signal read_cmd: read_cmd_signals;
	signal read_status: read_status_signals;

	-- write port
	signal write_cmd: write_cmd_signals;
	signal write_status: write_status_signals;

	component CPU is
		port(
			clk: in std_logic;
			write_status: in write_status_signals;
			write_cmd: out write_cmd_signals
		);
	end component;

	component clock_generator is
		port(
			clk_in: in std_logic;
			clk_main: out std_logic;
			clk_mem: out memory_clock_signals;
			clk_pixel: out std_logic
		);
	end component;

	component memory_interface
		port(
			clk: memory_clock_signals;
			write_cmd: in write_cmd_signals;
			write_status: out write_status_signals;
			read_cmd: in read_cmd_signals;
			read_status: out read_status_signals;
			ram: out ram_signals;
			ram_bus: inout ram_bus_signals;
			reset: in std_logic;
			calib_done: out std_logic
		);
	end component;

	component test_pattern_writer
		port(
			clk: in std_logic;
			completed: out std_logic;
			memory_ready: in std_logic;
			write_cmd: out write_cmd_signals;
			write_status: in write_status_signals
		);
	end component;

	component vga_generator
		port(
			clk: in std_logic;
			vga_out: out vga_signals;
			memory_ready: in std_logic;
			read_cmd: out read_cmd_signals;
			read_status: in read_status_signals
		);
	end component;

begin
	clock_gen: clock_generator
		port map(
			clk_in => clk_sys,
			clk_main => clk_main,
			clk_mem => clk_mem,
			clk_pixel => clk_pixel
		);

	cpu_inst: CPU port map(clk => clk_main, write_status => write_status, write_cmd => write_cmd);

	mem_if: memory_interface
		port map(
			clk => clk_mem,
			write_cmd => write_cmd, write_status => write_status,
			read_cmd => read_cmd, read_status => read_status,
			ram => ram, ram_bus => ram_bus,
			calib_done => memory_ready,
			reset => '0'
		);

	vga_gen: vga_generator
		port map(
			clk => clk_pixel,
			memory_ready => memory_written,
			read_cmd => read_cmd, read_status => read_status,
			vga_out => vga
		);

	vga_hsync <= vga.hsync;
	vga_vsync <= vga.vsync;
	vga_red <= vga.red;
	vga_green <= vga.green;
	vga_blue <= vga.blue;

	ram_a <= ram.a;
	ram_ba <= ram.ba;
	ram_cke <= ram.cke;
	ram_ras_n <= ram.ras_n;
	ram_cas_n <= ram.cas_n;
	ram_we_n <= ram.we_n;
	ram_dm <= ram.dm;
	ram_udm <= ram.udm;
	ram_ck <= ram.ck;
	ram_ck_n <= ram.ck_n;
	ram_dq <= ram_bus.dq;
	ram_udqs <= ram_bus.udqs;
	ram_dqs <= ram_bus.dqs;
	ram_rzq <= ram_bus.rzq;
end Behavioral;