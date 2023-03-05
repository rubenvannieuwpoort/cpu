library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_execute is
	port(
		clk: in std_logic;

		valid_in: in std_logic;

		operation_in: in std_logic_vector(3 downto 0);
		operand_1_in: in std_logic_vector(31 downto 0);
		operand_2_in: in std_logic_vector(31 downto 0);

		memory_operation_in: in std_logic;
		memory_value_in: in std_logic_vector(31 downto 0);

		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);


		valid_out: out std_logic;

		result_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		memory_operation_out: out std_logic := '0';
		memory_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000"
	);
end instruction_execute;

architecture Behavioral of instruction_execute is
	type register_file is array(0 to 15) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");
	signal ERROR: std_logic := '0'; -- this should always be zero when input opcodes are valid

begin
	process(clk)
		variable full_sum: std_logic_vector(63 downto 0);
	begin
		if rising_edge(clk) then
			if valid_in = '1' then
				memory_operation_out <= memory_operation_in;
				memory_value_out <= memory_value_in;
					
				writeback_indicator_out <= writeback_indicator_in;
				writeback_register_out <= writeback_register_in;

				if operation_in = "0000" then
					-- mov
					result_out <= operand_2_in;
					valid_out <= '1';
				elsif operation_in = "0001" then
					-- add
					result_out <= std_logic_vector(unsigned(operand_1_in) + unsigned(operand_2_in));
					valid_out <= '1';
				elsif operation_in = "0010" then
					-- sub
					result_out <= std_logic_vector(unsigned(operand_1_in) - unsigned(operand_2_in));
					valid_out <= '1';
				elsif operation_in = "0011" then
					-- mul
					full_sum := std_logic_vector(unsigned(operand_1_in) * unsigned(operand_2_in));
					result_out <= full_sum(31 downto 0);
					valid_out <= '1';
				elsif operation_in = "0100" then
					-- and
					result_out <= std_logic_vector(unsigned(operand_1_in) and unsigned(operand_2_in));
					valid_out <= '1';
				elsif operation_in = "0101" then
					-- or
					result_out <= std_logic_vector(unsigned(operand_1_in) or unsigned(operand_2_in));
					valid_out <= '1';
				elsif operation_in = "0110" then
					-- xor
					result_out <= std_logic_vector(unsigned(operand_1_in) xor unsigned(operand_2_in));
					valid_out <= '1';
				else
					ERROR <= '1';
					valid_out <= '0';
				end if;
			else
				memory_operation_out <= '0';
				memory_value_out <= "00000000000000000000000000000000";

				writeback_indicator_out <= '0';
				writeback_register_out <= "0000";

				result_out <= "00000000000000000000000000000000";
				valid_out <= '0';
			end if;
		end if;
	end process;
end Behavioral;