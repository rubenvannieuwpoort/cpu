library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity memory is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		data_in: in execute_output_type;

		busy_out: out std_logic := '0';
		data_out: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
begin

	process(clk)
		variable v_input: execute_output_type;
		variable v_internal_hold: std_logic;
		variable v_data_out: memory_output_type;
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
				v_data_out.writeback_indicator := v_input.writeback_indicator;
				v_data_out.writeback_register := v_input.writeback_register;
				v_data_out.writeback_value := v_input.result;
			else
				v_internal_hold := '1';
			end if;

			if v_internal_hold = '0' then
				data_out <= v_data_out;
				buffered_input <= DEFAULT_EXECUTE_OUTPUT;
			else
				data_out <= DEFAULT_MEMORY_OUTPUT;

				if buffered_input.valid = '0' and data_in.valid = '1' then
					buffered_input <= data_in;
				end if;
			end if;

		end if;
	end process;

end Behavioral;
