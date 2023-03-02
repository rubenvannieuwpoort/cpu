library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_decode is
	port(
		clk: in std_logic;
	
		enable_in: in std_logic;
		opcode_in: in std_logic_vector(15 downto 0);

		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);
		writeback_value_in: in std_logic_vector(31 downto 0);

		flag_set_indicator_in: in std_logic;
		flags_in: in std_logic_vector(3 downto 0);

		operation_out: out std_logic_vector(3 downto 0) := "0000"; -- TODO: make this an enum type (0: add, 1: sub, 2: mul, 3: and, 4: or, 5: xor)
		operand_1_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		operand_2_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		memory_indicator_out: out std_logic := '0';
		memory_operation_out: out std_logic := '0'; -- TODO: make this an enum type
		memory_address_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000";

		flag_set_indicator_out: out std_logic := '0';
		flags_out: out std_logic_vector(3 downto 0) := "0000";

		ready_out: out std_logic := '1'
	);
end instruction_decode;

architecture Behavioral of instruction_decode is
	type register_file is array(0 to 15) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000001", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");
	signal ERROR: std_logic := '0'; -- this should always be zero when input opcodes are valid

begin
	ready_out <= '1';

	process(clk)
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				flags_out <= flags_in;

				if writeback_indicator_in = '1' then
					reg(to_integer(unsigned(writeback_register_in))) <= writeback_value_in;
				end if;

				if opcode_in(15) = '0' then
					-- nop
					operation_out <= "0000";
					operand_1_out <= "00000000000000000000000000000000";
					operand_2_out <= "00000000000000000000000000000000";
					memory_indicator_out <= '0';
					memory_operation_out <= '0';
					memory_address_out <= "00000000000000000000000000000000";
					writeback_indicator_out <= '0';
					writeback_register_out <= "0000";
					flag_set_indicator_out <= '0';
					ERROR <= '0';-- when opcode_in(15 downto 8) = "00000000" else '1';
				elsif opcode_in(15) = '1' then
					-- arithmetic operations
					operation_out <= opcode_in(11 downto 8);
					operand_1_out <= reg(to_integer(unsigned(opcode_in(7 downto 4))));
					operand_2_out <= reg(to_integer(unsigned(opcode_in(3 downto 0))));
					memory_indicator_out <= '0';
					memory_operation_out <= '0';
					memory_address_out <= "00000000000000000000000000000000";
					writeback_indicator_out <= '1';
					writeback_register_out <= opcode_in(7 downto 4);
					flag_set_indicator_out <= opcode_in(14);
					ERROR <= '0';-- when to_integer(unsigned(opcode_in(13 downto 8))) < 6 else '1';
				end if;
			end if;
		end if;
	end process;
end Behavioral;