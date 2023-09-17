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
		leds_out: out std_logic_vector(0 to 7);
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

	signal read_write_port_s: read_write_port;
	signal read_write_status_s: read_write_status;

	signal read_port: read_cmd_signals;
	signal read_status: read_status_signals;

	-- vga
	signal vga: vga_signals;

	-- ram
	signal ram: ram_signals;
	signal ram_bus: ram_bus_signals;

	component CPU is
		port(
			clk: in std_logic;
			read_write_status_in: in read_write_status;
			read_write_port_out: out read_write_port;
			leds_out: out std_logic_vector(0 to 7)
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

	component memory_interface is
		port(
			clk: in memory_clock_signals;
			read_write_port_clk_in: in std_logic;
			read_write_port_in: in read_write_port;
			read_write_status_out: out read_write_status;
			read_port_clk_in: in std_logic;
			read_port_in: in read_cmd_signals;
			read_status_out: out read_status_signals;
			ram_out: out ram_signals;
			ram_bus: inout ram_bus_signals;
			calib_done_out: out std_logic;
			reset_in: in std_logic
		);
	end component;

	--component test_pattern_writer
	--	port(
	--		clk: in std_logic;
	--		completed: out std_logic;
	--		memory_ready: in std_logic;
	--		write_port_clk: out std_logic;
	--		write_port: out write_cmd_signals;
	--		write_status: in write_status_signals
	--	);
	--end component;

	--component textmode_vga_generator
	--	port(
	--		clk: in std_logic;
	--		vga_out: out vga_signals
	--	);
	--end component;
	
	component vga_generator is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			vga_out: out vga_signals;
			read_port_out: out read_cmd_signals;
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
		read_write_status_in => read_write_status_s,
		read_write_port_out => read_write_port_s,
		leds_out => open
		--leds_out => open
	);

	mem_if: memory_interface
		port map(
			clk => clk_mem,
			read_write_port_clk_in => clk_main,
			read_write_port_in => read_write_port_s,
			read_write_status_out => read_write_status_s,
			read_port_clk_in => clk_pixel,
			read_port_in => read_port,
			read_status_out => read_status,
			ram_out => ram,
			ram_bus => ram_bus,
			calib_done_out => memory_ready,
			reset_in => '0'
		);

	--test_pattern_writer_inst: test_pattern_writer
	--port map(
	--	clk => clk_main,
	--	memory_ready => memory_ready,
	--	completed => open,
	--	write_port => write_port,
	--	write_status => write_status
	--);

	--vga_gen: textmode_vga_generator
	--	port map(
	--		clk => clk_pixel,
	--		vga_out => vga
	--	);

	vga_gen: vga_generator port map(
		clk => clk_pixel,
		memory_ready_in => memory_ready,
		vga_out => vga,
		read_port_out => read_port,
		read_status_in => read_status
	);

	vga_hsync <= vga.hsync;
	vga_vsync <= vga.vsync;
	vga_red <= vga.red;
	vga_green <= vga.green;
	vga_blue <= vga.blue;

	leds_out <= read_status.overflow & read_status.error & read_write_status_s.read_overflow & read_write_status_s.read_error & read_write_status_s.write_underrun & read_write_status_s.write_error & "00";

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