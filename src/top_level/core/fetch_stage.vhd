-- TODO: actually implement an instruction pointer and fetch data from it
-- for now it just outputs a hardcoded list of opcodes
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_types.all;
use work.core_constants.all;


entity fetch_stage is
	port(
		clk: in std_logic;
		stall_in: in std_logic;

		branch_in: branch_signals;
		output: out fetch_output_type := DEFAULT_FETCH_OUTPUT
	);
end fetch_stage;

architecture Behavioral of fetch_stage is
	signal pc: std_logic_vector(31 downto 0) := (others => '0');
	signal pc_next: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4, 32));
	-- signal wait_indicator: std_logic := '0';
	signal stamp: std_logic_vector(2 downto 0) := (others => '0');

	type opcodes_list is array(0 to 63) of std_logic_vector(31 downto 0);
	signal opcodes: opcodes_list := (
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"ffffffff", X"0000006f", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013",
		X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013", X"00000013"
	);

	function is_branch(opcode: std_logic_vector(31 downto 0)) return boolean is
	begin
		if opcode(6 downto 0) = "1100011" and (opcode(14 downto 12) /= "010" or opcode(14 downto 12) /= "011") then
			return true;
		end if;
		return false;
	end function;
begin
	process(clk)
		variable v_opcode: std_logic_vector(31 downto 0);
	begin
		if rising_edge(clk) then
			if stall_in = '1' then
				if branch_in.data.indicator = '1' then	
					pc <= branch_in.data.address;
					pc_next <= std_logic_vector(unsigned(branch_in.data.address) + 4);
					stamp <= branch_in.stamp;
				end if;
			elsif branch_in.data.indicator = '1' then
				output.valid <= '1';

				pc <= std_logic_vector(unsigned(branch_in.data.address) + 4);
				pc_next <= std_logic_vector(unsigned(branch_in.data.address) + 8);
				stamp <= branch_in.stamp;

				output.pc <= branch_in.data.address;
				output.pc_next <= std_logic_vector(unsigned(branch_in.data.address) + 4);
				output.opcode <= opcodes(to_integer(unsigned(branch_in.data.address(7 downto 2))));
				output.stamp <= branch_in.stamp;
				output.tag <= branch_in.data.address(7 downto 2);
			else
				pc <= pc_next;
				pc_next <= std_logic_vector(unsigned(pc_next) + 4);

				output.valid <= '1';
				output.pc <= pc;
				output.pc_next <= pc_next;
				output.opcode <= opcodes(to_integer(unsigned(pc(7 downto 2))));
				output.stamp <= stamp;
				output.tag <= pc(7 downto 2);
			end if;
		end if;
	end process;
end Behavioral;
