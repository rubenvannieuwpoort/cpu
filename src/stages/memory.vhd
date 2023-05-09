library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity memory is
	port(
		clk: in std_logic;
		memory_ready: in std_logic;
		hold_in: in std_logic;
		input: in execute_output_type;

		hold_out: out std_logic;
		write_status_in: in write_status_signals;
		write_port_out: out write_port_signals;
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal write_cmd_out: write_cmd_signals := DEFAULT_WRITE_CMD;

	function should_stall(input: execute_output_type; write_status: write_status_signals; memory_ready: std_logic) return boolean is
		variable is_write_cmd: boolean;
		variable write_port_ready: boolean;
	begin
		is_write_cmd := input.memory_operation = MEMORY_OPERATION_STORE;
		write_port_ready := memory_ready = '1' and write_status.data_empty = '1' and write_status.cmd_empty = '1';
		return is_write_cmd and not(write_port_ready);
	end function;

	function f(input: execute_output_type) return memory_output_type is
		variable output: memory_output_type;
	begin
		output.writeback_indicator := input.writeback_indicator;
		output.writeback_register := input.writeback_register;
		output.writeback_value := input.result;
		output.act := input.act;
		output.tag := input.tag;
		if input.memory_operation = MEMORY_OPERATION_LOAD then
			output.convert_memory_order_indicator := '1';
		else
			output.convert_memory_order_indicator := '0';
		end if;
		output.memory_size := input.memory_size;
		output.address_bits := input.result(1 downto 0);
		return output;
	end function;

	function g(input: execute_output_type) return write_cmd_signals is
		variable write_cmd: write_cmd_signals;
		variable is_memory_operation: boolean;
	begin
		if input.memory_operation = MEMORY_OPERATION_STORE then
			write_cmd.enable := '1';
			write_cmd.data_enable := '1';
			write_cmd.address := input.result(29 downto 2) & "00";
			write_cmd.write_mask := not(input.write_enable);
			write_cmd.data := input.value;
			return write_cmd;
		end if;

		return DEFAULT_WRITE_CMD;
	end function;
begin
	write_port_out.clk <= clk;
	write_port_out.write_cmd <= write_cmd_out;
	hold_out <= buffered_input.valid;

	process(clk)
		variable v_should_stall: boolean;
		variable v_input: execute_output_type;
	begin
		if rising_edge(clk) then
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if hold_in = '0' then
				v_should_stall := should_stall(v_input, write_status_in, memory_ready);
				if v_should_stall then
					output <= DEFAULT_MEMORY_OUTPUT;
				end if;
			end if;

			if hold_in = '0' and not(v_should_stall) then
				output <= f(v_input);
				write_cmd_out <= g(v_input);
				buffered_input <= DEFAULT_EXECUTE_OUTPUT;
			else
				write_cmd_out <= DEFAULT_WRITE_CMD;
				buffered_input <= v_input;
			end if;
		end if;
	end process;
end Behavioral;