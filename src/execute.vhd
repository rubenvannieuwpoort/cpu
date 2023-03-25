library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity execute is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		data_in: in register_read_output_type;

		busy_out: out std_logic := '0';
		data_out: out execute_output_type := DEFAULT_EXECUTE_OUTPUT
	);
end execute;


architecture Behavioral of execute is
	signal buffered_input: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
begin

	process(clk)
		variable v_input: register_read_output_type;
		variable v_internal_hold: std_logic;
		variable v_data_out: execute_output_type;
		variable v_result: std_logic_vector(31 downto 0);
		variable full_product: std_logic_vector(63 downto 0);
	begin
		busy_out <= buffered_input.valid;

		if rising_edge(clk) then

			if hold_in = '0' then

				-- select input
				if buffered_input.valid = '1' then
					v_input := buffered_input;
				else
					v_input := data_in;
				end if;

				-- TODO: compute v_internal_hold and v_data_out based on input
				v_internal_hold := '0';

				-- compute result
				if v_input.execute_operation = EXECUTE_OPERATION_SECOND then
					v_result := v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_ADD then
					v_result := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_2));
				elsif v_input.execute_operation = EXECUTE_OPERATION_SUB then
					v_result := std_logic_vector(unsigned(v_input.operand_1) - unsigned(v_input.operand_2));
				elsif v_input.execute_operation = EXECUTE_OPERATION_MUL then
					full_product := std_logic_vector(unsigned(v_input.operand_1) * unsigned(v_input.operand_2));
					v_result := full_product(31 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_AND then
					v_result := v_input.operand_1 and v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_OR then
					v_result := v_input.operand_1 or v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_XOR then
					v_result := v_input.operand_1 xor v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_NOT then
					v_result := not(v_input.operand_2);
				--elsif v_input.execute_operation = EXECUTE_OPERATION_CMP then
				--	v_result := v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE0 then
					v_result := v_input.operand_1(31 downto 8) & v_input.operand_2(7 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE1 then
					v_result := v_input.operand_1(31 downto 16) & v_input.operand_2(7 downto 0) & v_input.operand_1(7 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE2 then
					v_result := v_input.operand_1(31 downto 24) & v_input.operand_2(7 downto 0) & v_input.operand_1(15 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE3 then
					v_result := v_input.operand_2(7 downto 0) & v_input.operand_1(23 downto 0);
				end if;

				if v_input.valid = '1' then
					v_data_out.valid := '1';
					v_data_out.memory_operation := v_input.memory_operation;
					v_data_out.result := v_result;
					v_data_out.value := v_input.value;
					v_data_out.writeback_indicator := v_input.writeback_indicator;
					v_data_out.writeback_register := v_input.writeback_register;
				else
					v_data_out := DEFAULT_EXECUTE_OUTPUT;
				end if;
			else
				v_internal_hold := '1';
			end if;

			if v_internal_hold = '0' then
				data_out <= v_data_out;
				buffered_input <= DEFAULT_REGISTER_READ_OUTPUT;
			else
				data_out <= DEFAULT_EXECUTE_OUTPUT;

				if buffered_input.valid = '0' and data_in.valid = '1' then
					buffered_input <= data_in;
				end if;
			end if;

		end if;
	end process;

end Behavioral;
