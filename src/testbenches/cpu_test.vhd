library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;


entity cpu_test is
end cpu_test;

architecture behavior of cpu_test is
	component CPU
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			read_write_port_clk_out: out std_logic;
			read_write_port_out: out read_write_port_signals;
			read_status_in: in read_status_signals;
			write_status_in: in write_status_signals
		);
	end component;

	signal clk_count: std_logic_vector(5 downto 0) := "000000";
	signal clk: std_logic := '0';
	constant clk_period: time := 10 ns;

	signal read_status: read_status_signals := DEFAULT_READ_STATUS_SIGNALS;
	signal write_status: write_status_signals := DEFAULT_WRITE_STATUS_SIGNALS;
begin

	uut: CPU port map(
		clk => clk,
		memory_ready_in => '1',
		read_write_port_clk_out => open,
		read_write_port_out => open,
		read_status_in => read_status,
		write_status_in => write_status
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
