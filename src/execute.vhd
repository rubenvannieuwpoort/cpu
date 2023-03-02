library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_execute is
	port(
		clk: in std_logic;
	
		enable_in: in std_logic;

		operation_in: in std_logic_vector(3 downto 0); -- TODO: make this an enum type (0: add, 1: sub, 2: mul, 3: and, 4: or, 5: xor)
		operand_1_in: in std_logic_vector(31 downto 0);
		operand_2_in: in std_logic_vector(31 downto 0);

		memory_indicator_in: in std_logic;
		memory_operation_in: in std_logic; -- TODO: make this an enum type
		memory_address_in: in std_logic_vector(31 downto 0);

		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);

		flag_set_indicator_in: in std_logic;


		result_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		memory_indicator_out: out std_logic := '0';
		memory_operation_out: out std_logic := '0'; -- TODO: make this an enum type
		memory_address_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000";

		flag_set_indicator_out: out std_logic := '1';
		flags_out: out std_logic_vector(3 downto 0) := "0000";

		ready_out: out std_logic := '1'
	);
end instruction_execute;

architecture Behavioral of instruction_execute is
	type register_file is array(0 to 15) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");
	signal ERROR: std_logic := '0'; -- this should always be zero when input opcodes are valid

begin
	flags_out <= "0000";  -- TODO: actually set this
	ready_out <= '1';

	process(clk)
		variable full_sum: std_logic_vector(63 downto 0);
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				memory_indicator_out <= memory_indicator_in;
				memory_operation_out <= memory_operation_in;
				memory_address_out <= memory_address_in;
				
				writeback_indicator_out <= writeback_indicator_in;
				writeback_register_out <= writeback_register_in;

				flag_set_indicator_out <= flag_set_indicator_in;

				if operation_in = "0000" then
					-- mov
					result_out <= operand_2_in;
				elsif operation_in = "0001" then
					-- add
					result_out <= std_logic_vector(unsigned(operand_1_in) + unsigned(operand_2_in));
				elsif operation_in = "0010" then
					-- sub
					result_out <= std_logic_vector(unsigned(operand_1_in) - unsigned(operand_2_in));
				elsif operation_in = "0011" then
					-- mul
					full_sum := std_logic_vector(unsigned(operand_1_in) * unsigned(operand_2_in));
					result_out <= full_sum(31 downto 0);
				elsif operation_in = "0100" then
					-- and
					result_out <= std_logic_vector(unsigned(operand_1_in) and unsigned(operand_2_in));
				elsif operation_in = "0101" then
					-- or
					result_out <= std_logic_vector(unsigned(operand_1_in) or unsigned(operand_2_in));
				elsif operation_in = "0110" then
					-- xor
					result_out <= std_logic_vector(unsigned(operand_1_in) xor unsigned(operand_2_in));
				else
					ERROR <= '1';
				end if;
			end if;
		end if;
	end process;
end Behavioral;