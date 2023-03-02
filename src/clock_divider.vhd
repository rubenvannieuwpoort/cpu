-- Clock divider
-- =============
--
-- Inputs               Outputs
--              _____
--             |     |
-- clk_in ---->|     |----> clk_out
--             |_____|
--              power
--
-- Divides the clock by a power of two. 
--
-- The frequency of the clk_out signal will be the frequency of the clk_in
-- signal divided by 2^power. The clk_in and clk_out signals will have a
-- synchronous rising edge.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
	generic(
		power: integer
	);
	port(
		clk_in:  in  std_logic;
		clk_out: out std_logic
	);
end entity;

architecture Behavioral of clock_divider is
	signal counter: std_logic_vector(power downto 0) := std_logic_vector(to_unsigned(0, power + 1));
begin
	
	clk_out <= counter(power);
	
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			counter <= std_logic_vector(unsigned(counter) + 1);
		end if;
	end process;

end Behavioral;