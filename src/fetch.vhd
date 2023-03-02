-- TODO: actually implement an instruction pointer and fetch data from it
-- for now it just outputs a hardcoded list of opcodes
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_fetch is
	port(
		clk: in std_logic;
		enable_in: in std_logic;

		opcode_out: out std_logic_vector(15 downto 0) := "0000000000000000";
		ready_out: out std_logic := '1'
	);
end instruction_fetch;

architecture Behavioral of instruction_fetch is
	signal count: std_logic_vector(4 downto 0) := "00000";
	type opcodes_list is array(0 to 31) of std_logic_vector(15 downto 0);
	signal opcodes: opcodes_list := (
		"1000000100000001", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "1000000100000001", "0000000000000000", "0000000000000000",
		"0000000000000000", "0000000000000000", "1000000100000001", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "1000000100000001",
		"0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "1000000100000001", "0000000000000000", "0000000000000000", "0000000000000000",
		"0000000000000000", "1000000100000001", "0000000000000000", "0000000000000000", "1000000100000001", "0000000000000000", "0000000000000000", "0000000000000000");

begin
	ready_out <= '1';

	process(clk)
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				count <= std_logic_vector(unsigned(count) + 1);
				opcode_out <= opcodes(to_integer(unsigned(count)));
			end if;
		end if;
	end process;
end Behavioral;