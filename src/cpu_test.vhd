library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_test is
end cpu_test;


architecture behavior of cpu_test is
	component CPU
		port(
			clk : in std_logic
		);
	end component;

	signal clk_count: std_logic_vector(5 downto 0) := "000000";
	signal clk: std_logic := '0';
	constant clk_period: time := 10 ns;

begin

	uut: CPU port map(clk => clk);

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
