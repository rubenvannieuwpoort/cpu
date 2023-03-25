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

		data_out: out fetch_output_type := DEFAULT_FETCH_OUTPUT
	);
end fetch;

architecture Behavioral of fetch is
	signal count: std_logic_vector(4 downto 0) := "00000";
	type opcodes_list is array(0 to 31) of std_logic_vector(15 downto 0);
	signal opcodes: opcodes_list := (
		"1000001100001111", "1001011111111000", "0000000000000000", "0000000000000000", "0000000000000000", "0000001000110111", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000");

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if hold_in = '0' then
				count <= std_logic_vector(unsigned(count) + 1);
				data_out.valid <= '1';
				data_out.opcode <= opcodes(to_integer(unsigned(count)));
			end if;
		end if;
	end process;
end Behavioral;
