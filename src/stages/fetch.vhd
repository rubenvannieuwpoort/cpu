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

		--continue_in: in std_logic;
		--pc_indicator_in: in std_logic;
		--pc_in: in std_logic_vector(19 downto 0);

		output: out fetch_output_type := DEFAULT_FETCH_OUTPUT
	);
end fetch;

architecture Behavioral of fetch is
	signal pc: std_logic_vector(31 downto 0) := (others => '0');
	signal pc_next: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4, 32));
	signal wait_indicator: std_logic := '0';

	type opcodes_list is array(0 to 31) of std_logic_vector(31 downto 0);
	signal opcodes: opcodes_list := (
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
		"00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000"
	);

	function is_branch(opcode: std_logic_vector(31 downto 0)) return boolean is
	begin
		return false;
	end function;
begin
	process(clk)
		variable v_opcode: std_logic_vector(31 downto 0);
	begin
		if rising_edge(clk) then
			if wait_indicator = '0' then
				if hold_in = '0' then
					v_opcode := opcodes(to_integer(unsigned(pc(6 downto 2))));

					pc <= pc_next;
					pc_next <= std_logic_vector(unsigned(pc_next) + 4);

					output.valid <= '1';
					output.pc <= pc;
					output.pc_next <= pc_next;
					output.opcode <= v_opcode;
					output.tag <= pc(6 downto 2);
					
					if is_branch(v_opcode) then
						wait_indicator <= '1';
					end if;
				end if;
			else
				if hold_in = '0' then
					output <= DEFAULT_FETCH_OUTPUT;
				end if;
			--	if continue_in = '1' then
			--		wait_indicator <= '0';
			--	elsif pc_in_indicator = '1' then
			--		wait_indicator <= '0';
			--		pc <= pc_in;
			--	end if;
			end if;
		end if;
	end process;
end Behavioral;
