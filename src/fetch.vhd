-- TODO: actually implement an instruction pointer and fetch data from it
-- for now it just outputs a hardcoded list of opcodes
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_fetch is
	port(
		clk: in std_logic;
		hold_in: in std_logic;

		valid_out: out std_logic := '0';
		opcode_out: out std_logic_vector(15 downto 0) := "0000000000000000"
	);
end instruction_fetch;

architecture Behavioral of instruction_fetch is
	signal count: std_logic_vector(3 downto 0) := "0000";
	type opcodes_list is array(0 to 3) of std_logic_vector(15 downto 0);
	signal opcodes: opcodes_list := ("1000000100000001", "0000000000000000", "0000000000000000", "0000000000000000");

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if hold_in = '0' then
				opcode_out <= opcodes(to_integer(unsigned(count)));

				if count = "0000" then
					valid_out <= '1';
				else
					valid_out <= '0';
				end if;

				if to_integer(unsigned(count)) = 2 then
					count <= (others => '0');
				else
					count <= std_logic_vector(unsigned(count) + 1);
				end if;
			else
				opcode_out <= (others => '0');
				valid_out <= '0';
			end if;
		end if;
	end process;
end Behavioral;