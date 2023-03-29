library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity execute is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in register_read_output_type;

		busy_out: out std_logic := '0';
		output: out execute_output_type := DEFAULT_EXECUTE_OUTPUT
	);
end execute;


architecture Behavioral of execute is
	signal buffered_input: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
	signal zero_flag: std_logic := '0';
	signal sign_flag: std_logic := '0';
	signal overflow_flag: std_logic := '0';
	signal carry_flag: std_logic := '0';
begin

	process(clk)
		variable v_input: register_read_output_type;
		variable v_wait: std_logic;
		variable v_output: execute_output_type;
		variable v_result: std_logic_vector(31 downto 0);
		variable full_product: std_logic_vector(63 downto 0);
		variable v_carry_flag: std_logic;
		variable v_overflow_flag: std_logic;

		variable v_full_result: std_logic_vector(32 downto 0);
	begin
		busy_out <= buffered_input.valid;

		if rising_edge(clk) then
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			v_carry_flag := '0';
			v_overflow_flag := '0';

			v_wait := '0';
			if hold_in = '0' then
				-- compute result
				if v_input.execute_operation = EXECUTE_OPERATION_SECOND then
					v_result := v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_ADD then
					-- v_result := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_2));
					-- TODO: set overflow flag
					v_full_result := std_logic_vector(unsigned('0' & v_input.operand_1) + unsigned('0' & v_input.operand_2));
					v_carry_flag := v_full_result(32);
					v_result := v_full_result(31 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_SUB then
					-- v_result := std_logic_vector(unsigned(v_input.operand_1) - unsigned(v_input.operand_2));
					-- TODO: set overflow flag
					v_full_result := std_logic_vector(unsigned('0' & v_input.operand_1) - unsigned('0' & v_input.operand_2));
					v_carry_flag := v_full_result(32);
					v_result := v_full_result(31 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_MUL then
					full_product := std_logic_vector(unsigned(v_input.operand_1) * unsigned(v_input.operand_2));
					-- TODO: set overflow flag
					if unsigned(full_product(63 downto 32)) = 0 then
						v_carry_flag := '0';
					else
						v_carry_flag := '1';
					end if;
					v_result := full_product(31 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_AND then
					v_result := v_input.operand_1 and v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_OR then
					v_result := v_input.operand_1 or v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_XOR then
					v_result := v_input.operand_1 xor v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_NOT then
					v_result := not(v_input.operand_2);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE0 then
					v_result := v_input.operand_1(31 downto 8) & v_input.operand_2(7 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE1 then
					v_result := v_input.operand_1(31 downto 16) & v_input.operand_2(7 downto 0) & v_input.operand_1(7 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE2 then
					v_result := v_input.operand_1(31 downto 24) & v_input.operand_2(7 downto 0) & v_input.operand_1(15 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE3 then
					v_result := v_input.operand_2(7 downto 0) & v_input.operand_1(23 downto 0);
				end if;

				-- set flags
				if v_input.valid = '1' and v_input.flag_set_indicator = '1' and unsigned(v_input.execute_operation) <= unsigned(EXECUTE_OPERATION_NOT) then
					if unsigned(v_result) = 0 then
						zero_flag <= '1';
					else
						zero_flag <= '0';
					end if;

					if v_result(31) = '1' then
						sign_flag <= '1';
					else
						sign_flag <= '0';
					end if;

					if v_input.execute_operation = EXECUTE_OPERATION_ADD or v_input.execute_operation = EXECUTE_OPERATION_SUB or v_input.execute_operation = EXECUTE_OPERATION_MUL then
						carry_flag <= v_carry_flag;
						overflow_flag <= v_overflow_flag;
					end if;
				end if;

				-- set output
				if v_input.valid = '1' then
					v_output.valid := '1';
					v_output.memory_operation := v_input.memory_operation;
					v_output.result := v_result;
					v_output.value := v_input.value;
					v_output.writeback_indicator := v_input.writeback_indicator;
					v_output.writeback_register := v_input.writeback_register;
				else
					v_output := DEFAULT_EXECUTE_OUTPUT;
				end if;
				
				if v_wait = '1' then
					v_output := DEFAULT_EXECUTE_OUTPUT;
				else
					buffered_input <= DEFAULT_REGISTER_READ_OUTPUT;
				end if;

				output <= v_output;
			end if;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				buffered_input <= v_input;
			end if;

			busy_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
