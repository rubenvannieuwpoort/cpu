library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

use work.types.all;


entity top_level is
	port(
		clk_sys: in std_logic;
		-- VGA
		vga_hsync: out std_logic;
		vga_vsync: out std_logic;
		vga_red: out std_logic_vector(2 downto 0);
		vga_green: out std_logic_vector(2 downto 0);
		vga_blue: out std_logic_vector(2 downto 1);
		-- LEDs
		led: out std_logic_vector(7 downto 0);
		-- seven segment display
		seven_segment_enable: out std_logic_vector(2 downto 0);
		seven_segment: out std_logic_vector(7 downto 0);
		-- RAM
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

	-- memory
	signal memory_ready: std_logic;

	signal read_write_port_0_clk: std_logic;
	signal read_write_port_0: read_write_port_signals;
	signal read_status_0: read_status_signals;
	signal write_status_0: write_status_signals;

	signal read_port_1_clk: std_logic;
	signal read_port_1: read_port_signals;
	signal read_status_1: read_status_signals;

	-- vga
	signal vga: vga_signals;

	-- ram
	signal ram: ram_signals;
	signal ram_bus: ram_bus_signals;

	component CPU is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			read_write_port_clk_out: out std_logic;
			read_write_port_out: out read_write_port_signals;
			read_status_in: in read_status_signals;
			write_status_in: in write_status_signals
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
			clk: in memory_clock_signals;
			read_write_port_0_clk_in: in std_logic;
			read_write_port_0_in: in read_write_port_signals;
			read_status_0_out: out read_status_signals;
			write_status_0_out: out write_status_signals;
			read_port_1_clk_in: in std_logic;
			read_port_1_in: in read_port_signals;
			read_status_1_out: out read_status_signals;
			ram_out: out ram_signals;
			ram_bus: inout ram_bus_signals;
			calib_done: out std_logic;
			reset_in: in std_logic
		);
	end component;

	--component textmode_vga_generator
	--	port(
	--		clk: in std_logic;
	--		vga_out: out vga_signals
	--	);
	--end component;
	
	component vga_generator is
		port(
			clk: in std_logic;
			memory_ready: in std_logic;
			vga_out: out vga_signals;
			read_port_clk_out: out std_logic;
			read_port_out: out read_port_signals;
			read_status_in: in read_status_signals
		);
	end component;

begin
	seven_segment_enable <= "000";
	seven_segment <= "11111111";

	clock_gen: clock_generator
		port map(
			clk_in => clk_sys,
			clk_main => clk_main,
			clk_mem => clk_mem,
			clk_pixel => clk_pixel
		);

	cpu_inst: CPU port map(
		clk => clk_main,
		memory_ready_in => memory_ready,
		read_write_port_clk_out => read_write_port_0_clk,
		read_status_in => read_status_1,
		write_status_in => write_status_0,
		read_write_port_out => read_write_port_0
	);

	mem_if: memory_interface
		port map(
			clk => clk_mem,
			read_write_port_0_clk_in => read_write_port_0_clk,
			read_write_port_0_in => read_write_port_0,
			read_status_0_out => read_status_0,
			write_status_0_out => write_status_0,
			read_port_1_clk_in => read_port_1_clk,
			read_port_1_in => read_port_1,
			read_status_1_out => read_status_1,
			ram_out => ram, ram_bus => ram_bus,
			calib_done => memory_ready,
			reset_in => '0'
		);

	--vga_gen: textmode_vga_generator
	--	port map(
	--		clk => clk_pixel,
	--		vga_out => vga
	--	);

	vga_gen: vga_generator
		port map(
			clk => clk_pixel,
			memory_ready => memory_ready,
			vga_out => vga,
			read_port_clk_out => read_port_1_clk,
			read_port_out => read_port_1,
			read_status_in => read_status_1
		);

	vga_hsync <= vga.hsync;
	vga_vsync <= vga.vsync;
	vga_red <= vga.red;
	vga_green <= vga.green;
	vga_blue <= vga.blue;

	led <= read_status_1.overflow & read_status_1.error & write_status_0.underrun & write_status_0.error & "0000";

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