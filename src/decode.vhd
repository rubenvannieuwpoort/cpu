library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_decode is
	port(
		clk: in std_logic;

		valid_in: in std_logic;
		hold_in: in std_logic;

		opcode_in: in std_logic_vector(15 downto 0);

		valid_out: out std_logic;

		operation_out: out std_logic_vector(3 downto 0) := "0000";

		read_indicator_1_out: out std_logic;
		reg_1_out: out std_logic_vector(3 downto 0) := "0000";
		read_indicator_2_out: out std_logic;
		reg_2_out: out std_logic_vector(3 downto 0) := "0000";

		memory_operation_out: out std_logic := '0'; -- 0: NOP, 1: not supported for now
		memory_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000"
	);
end instruction_decode;

architecture Behavioral of instruction_decode is
	signal error: std_logic := '0';  -- internal signal to indicate errors
begin
	process(clk)
		variable v_exception: std_logic;
		variable v_valid_out: std_logic;
		variable v_operation_out: std_logic_vector(3 downto 0);
		variable v_read_indicator_1_out: std_logic;
		variable v_reg_1_out: std_logic_vector(3 downto 0);
		variable v_read_indicator_2_out: std_logic;
		variable v_reg_2_out: std_logic_vector(3 downto 0);
		variable v_memory_operation_out: std_logic;
		variable v_memory_value_out: std_logic_vector(31 downto 0);
		variable v_writeback_indicator_out: std_logic;
		variable v_writeback_register_out: std_logic_vector(3 downto 0);
	begin
		if rising_edge(clk) then

			if hold_in = '0' then
				v_exception := '0';

				if valid_in = '1' then
					-- decode
					if opcode_in(15) = '0' then
						-- nop
						v_valid_out := '1';
						v_operation_out := "0000";
						v_read_indicator_1_out := '0';
						v_reg_1_out := "0000";
						v_read_indicator_2_out := '0';
						v_reg_2_out := "0000";
						v_memory_operation_out := '0';
						v_memory_value_out := "00000000000000000000000000000000";
						v_writeback_indicator_out := '0';
						v_writeback_register_out := "0000";

						-- check validity of the opcode
						if opcode_in(15 downto 8) /= "00000000" then
							v_exception := '1';
						end if;
					elsif opcode_in(15) = '1' then
						-- arithmetic operations
						v_valid_out := '1';
						v_operation_out := opcode_in(11 downto 8);
						v_read_indicator_1_out := '1';
						v_reg_1_out := opcode_in(7 downto 4);
						v_read_indicator_2_out := '1';
						v_reg_2_out := opcode_in(3 downto 0);
						v_memory_operation_out := '0';
						v_memory_value_out := "00000000000000000000000000000000";
						v_writeback_indicator_out := '1';
						v_writeback_register_out := opcode_in(7 downto 4);

						-- check validity of the opcode
						if to_integer(unsigned(opcode_in(13 downto 8))) > 6 then
							v_exception := '1';
						end if;
					end if;
				end if;

				-- select output based on if the input was valid and whether there was an exception or not
				if valid_in = '1' and v_exception = '0' then
					valid_out <= v_valid_out;
					operation_out <= v_operation_out;
					read_indicator_1_out <= v_read_indicator_1_out;
					reg_1_out <= v_reg_1_out;
					read_indicator_2_out <= v_read_indicator_2_out;
					reg_2_out <= v_reg_2_out;
					memory_operation_out <= v_memory_operation_out;
					memory_value_out <= v_memory_value_out;
					writeback_indicator_out <= v_writeback_indicator_out;
					writeback_register_out <= v_writeback_register_out;
				else
					if v_exception = '1' then
						error <= '1';
					end if;
					valid_out <= '0';
					operation_out <= "0000";
					read_indicator_1_out <= '0';
					reg_1_out <= "0000";
					read_indicator_2_out <= '0';
					reg_2_out <= "0000";
					memory_operation_out <= '0';
					memory_value_out <= "00000000000000000000000000000000";
					writeback_indicator_out <= '0';
					writeback_register_out <= "0000";
				end if;

			end if;
		end if;
	end process;
end Behavioral;