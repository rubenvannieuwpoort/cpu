-- TODO: actually implement an instruction pointer and fetch data from it
-- for now it just outputs a hardcoded list of opcodes
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity fetch is
	port(
		clk: in std_logic;
		hold_in: in std_logic;

		output: out fetch_output_type := DEFAULT_FETCH_OUTPUT
	);
end fetch;

architecture Behavioral of fetch is
	signal address: std_logic_vector(20 downto 0) := (others => '0');
	type opcodes_list is array(0 to 31) of std_logic_vector(15 downto 0);
	signal opcodes: opcodes_list := (
		"0100000000000001", "0101000000000010", "0110000000000011", "0111000000000100", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000");
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if hold_in = '0' then
				address <= std_logic_vector(unsigned(address) + 1);
				output.valid <= '1';
				output.opcode <= opcodes(to_integer(unsigned(address(4 downto 0))));
			end if;
		end if;
	end process;
end Behavioral;
