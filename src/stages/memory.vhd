library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity memory is
	port(
		clk: in std_logic;
		memory_ready_in: in std_logic;
		stall_in: in std_logic;
		input: in execute_output_type;

		write_status_in: in write_status_signals;
		write_port_out: out write_cmd_signals;

		stall_out: out std_logic := '0';
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal write_cmd: write_cmd_signals := DEFAULT_WRITE_CMD;

	function should_stall(input: execute_output_type; write_status: write_status_signals; memory_ready: std_logic) return boolean is
		variable is_write_cmd: boolean;
		variable write_port_ready: boolean;
	begin
		is_write_cmd := input.memory_operation = MEMORY_OPERATION_STORE;
		write_port_ready := memory_ready = '1' and unsigned(write_status.data_count) < 16 and write_status.cmd_full = '0';
		return is_write_cmd and not(write_port_ready);
	end function;

	function f(input: execute_output_type) return memory_output_type is
		variable output: memory_output_type;
	begin
		output.act := input.act;
		output.writeback_value := input.writeback_value;
		output.writeback_register := input.writeback_register;
		output.tag := input.tag;
		return output;
	end function;

	function g(input: execute_output_type) return write_cmd_signals is
		variable write_cmd: write_cmd_signals;
		variable is_memory_operation: boolean;
	begin
		if input.memory_operation = MEMORY_OPERATION_STORE then
			write_cmd.enable := '1';
			write_cmd.data_enable := '1';
			write_cmd.address := input.memory_address(29 downto 2) & "00";
			write_cmd.write_mask := not(input.memory_write_mask);
			write_cmd.data := input.memory_data;
			return write_cmd;
		end if;

		return DEFAULT_WRITE_CMD;
	end function;

begin
	write_port_out <= write_cmd;
	stall_out <= buffered_input.valid;

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

			if stall_in = '0' then
				v_should_stall := should_stall(v_input, write_status_in, memory_ready_in);
				if v_should_stall then
					output <= DEFAULT_MEMORY_OUTPUT;
				end if;
			end if;

			if stall_in = '0' and not(v_should_stall) then
				output <= f(v_input);
				write_cmd <= g(v_input);
				buffered_input <= DEFAULT_EXECUTE_OUTPUT;
			else
				write_cmd <= DEFAULT_WRITE_CMD;
				buffered_input <= v_input;
			end if;
		end if;
	end process;
end Behavioral;