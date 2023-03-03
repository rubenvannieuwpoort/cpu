library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_decode is
	port(
		clk: in std_logic;

		-- instruction decode stage
		valid_in: in std_logic;
		opcode_in: in std_logic_vector(15 downto 0);

		valid_out: out std_logic;

		operation_out: out std_logic_vector(3 downto 0) := "0000";
		operand_1_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		operand_2_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		memory_indicator_out: out std_logic := '0';
		memory_operation_out: out std_logic := '0'; -- 0: NOP, 1: not supported for now
		memory_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000";
	
		-- writeback stage
		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);
		writeback_value_in: in std_logic_vector(31 downto 0);

		ready_out: out std_logic
	);
end instruction_decode;

architecture Behavioral of instruction_decode is
	type register_file is array(0 to 15) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000001", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");
	signal ERROR: std_logic := '0';

begin
	ready_out <= '1';

	process(clk)
	begin
		if rising_edge(clk) then
			-- decode
			if valid_in = '1' then
				if opcode_in(15) = '0' then
					-- nop
					operation_out <= "0000";
					operand_1_out <= "00000000000000000000000000000000";
					operand_2_out <= "00000000000000000000000000000000";
					memory_indicator_out <= '0';
					memory_operation_out <= '0';
					memory_value_out <= "00000000000000000000000000000000";
					writeback_indicator_out <= '0';
					writeback_register_out <= "0000";
					if opcode_in(15 downto 8) = "00000000" then
						valid_out <= '1';
					else
						ERROR <= '1';
					end if;
				elsif opcode_in(15) = '1' then
					-- arithmetic operations
					operation_out <= opcode_in(11 downto 8);
					operand_1_out <= reg(to_integer(unsigned(opcode_in(7 downto 4))));
					operand_2_out <= reg(to_integer(unsigned(opcode_in(3 downto 0))));
					memory_indicator_out <= '0';
					memory_operation_out <= '0';
					memory_value_out <= "00000000000000000000000000000000";
					writeback_indicator_out <= '1';
					writeback_register_out <= opcode_in(7 downto 4);
					if to_integer(unsigned(opcode_in(13 downto 8))) < 6 then
						valid_out <= '1';
					else
						ERROR <= '1';
					end if;
				end if;
			else
				operation_out <= "0000";
				operand_1_out <= "00000000000000000000000000000000";
				operand_2_out <= "00000000000000000000000000000000";
				memory_indicator_out <= '0';
				memory_operation_out <= '0';
				memory_value_out <= "00000000000000000000000000000000";
				writeback_indicator_out <= '0';
				writeback_register_out <= "0000";
				valid_out <= '0';
			end if;
			
			-- writeback
			if writeback_indicator_in = '1' then
				reg(to_integer(unsigned(writeback_register_in))) <= writeback_value_in;
			end if;

		end if;
	end process;
end Behavioral;