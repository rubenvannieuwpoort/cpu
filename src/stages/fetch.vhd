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

		continue_in: in std_logic;
		address_indicator_in: in std_logic;
		address_in: in std_logic_vector(19 downto 0);

		output: out fetch_output_type := DEFAULT_FETCH_OUTPUT
	);
end fetch;

architecture Behavioral of fetch is
	signal address: std_logic_vector(19 downto 0) := (others => '0');
	type opcodes_list is array(0 to 31) of std_logic_vector(15 downto 0);
	signal opcodes: opcodes_list := (
		"0011001000000011", "0011000100010010", "0001101100000001", "1010000000101111", "1010000100111111", "1010001001001111", "1010001101011111", "1010010001101111", "1010010101111111", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000"
	);
	signal wait_indicator: std_logic := '0';
begin
	process(clk)
		variable v_opcode: std_logic_vector(15 downto 0);
		variable v_is_branch: std_logic;
	begin
		if rising_edge(clk) then
			if wait_indicator = '0' then
				if hold_in = '0' then
					v_opcode := opcodes(to_integer(unsigned(address(4 downto 0))));

					address <= std_logic_vector(unsigned(address) + 1);
					output.valid <= '1';
					output.opcode <= v_opcode;
					output.tag <= address(4 downto 0);

					if (v_opcode(15 downto 8) = "00000010" and v_opcode(3 downto 0) = "0000") or v_opcode(15 downto 8) = "00000001" then
						v_is_branch := '1';
					else
						v_is_branch := '0';
					end if;
					
					if v_is_branch = '1' then
						wait_indicator <= '1';
					end if;
				end if;
			else
				if hold_in = '0' then
				output <= DEFAULT_FETCH_OUTPUT;
				end if;
				if continue_in = '1' then
					wait_indicator <= '0';
				elsif address_indicator_in = '1' then
					wait_indicator <= '0';
					address <= address_in;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
