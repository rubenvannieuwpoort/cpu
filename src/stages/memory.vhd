library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity memory is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in execute_output_type;

		busy_out: out std_logic := '0';
		write_status_in: in write_status_signals;
		write_port_out: out write_port_signals;
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	
begin

	process(clk)
		variable v_wait: std_logic;
		variable v_input: execute_output_type;
		variable v_output: memory_output_type;
	begin
		if rising_edge(clk) then
		
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			v_wait := '0';
			if hold_in = '0' then
				-- generate output
				v_output.writeback_indicator := v_input.writeback_indicator;
				v_output.writeback_register := v_input.writeback_register;
				-- v_output.writeback_value := v_input.result;
				v_output.act := v_input.act;
				v_output.tag := v_input.tag;
				v_output.address_bits := v_input.result(1 downto 0);

				if v_input.memory_operation = MEMORY_OPERATION_LOAD then
					v_output.convert_memory_order_indicator := '1';
				else
					v_output.convert_memory_order_indicator := '0';
				end if;
				v_output.memory_size := v_input.memory_size;

				if v_wait = '1' then
					v_output := DEFAULT_MEMORY_OUTPUT;
				else
					buffered_input <= DEFAULT_EXECUTE_OUTPUT;
				end if;

				-- equivalent to output <= v_output; EXCEPT for the writeback value
				output.writeback_indicator <= v_output.writeback_indicator;
				output.writeback_register <= v_output.writeback_register;
				-- output.writeback_value <= v_output.result;
				output.act <= v_output.act;
				output.tag <= v_output.tag;
				output.convert_memory_order_indicator <= v_output.convert_memory_order_indicator;
				output.memory_size <= v_output.memory_size;
				output.address_bits <= v_output.address_bits;
			end if;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				buffered_input <= v_input;
			end if;

			busy_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
