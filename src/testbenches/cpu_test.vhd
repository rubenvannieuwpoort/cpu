library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;


entity cpu_test is
end cpu_test;

architecture behavior of cpu_test is
	component CPU is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			write_status_in: in write_status_signals;
			write_port_out: out write_port_signals;
			leds_out: out std_logic_vector(7 downto 0)
		);
	end component;

	signal clk_count: std_logic_vector(5 downto 0) := "000000";
	signal clk: std_logic := '0';
	constant clk_period: time := 10 ns;

	signal write_port: write_port_signals;
begin

	uut: CPU port map(
		clk => clk,
		memory_ready_in => '1',
		write_status_in => DEFAULT_WRITE_STATUS,
		write_port_out => write_port,
		leds_out => open
	);

	clk_process :process
	begin
		wait for clk_period / 2;
		clk <= '1';
		clk_count <= std_logic_vector(unsigned(clk_count) + 1);
		wait for clk_period / 2;
		clk <= '0';
	end process;
 
	stim_proc: process
	begin
		wait for 50001 ps;
		wait;
	end process;

end;
