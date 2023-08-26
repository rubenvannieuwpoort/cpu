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

		read_write_port_clk_out: out std_logic;
		read_write_port_out: out read_write_port_signals := DEFAULT_READ_WRITE_PORT_SIGNALS;
		write_status_in: in write_status_signals;

		stall_out: out std_logic := '0';
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;

begin
	stall_out <= buffered_input.valid;

	read_write_port_clk_out <= clk;

	process(clk)
		variable v_input: execute_output_type;
		variable v_output: memory_output_type;
		variable v_read_write_port: read_write_port_signals := DEFAULT_READ_WRITE_PORT_SIGNALS;
		variable v_should_stall: boolean;
	begin
		if rising_edge(clk) then
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if stall_in = '0' then
				if (input.memory_operation = MEMORY_OPERATION_STORE or input.memory_operation = MEMORY_OPERATION_LOAD) and
					 not(memory_ready_in = '1' and write_status_in.data_empty = '1' and write_status_in.cmd_empty = '1') then
					v_should_stall := true;
				else
					v_should_stall := false;
				end if;

				if v_should_stall then
					v_output := DEFAULT_MEMORY_OUTPUT;
					v_read_write_port := DEFAULT_READ_WRITE_PORT_SIGNALS;
				else
					-- MEMORY STAGE OUTPUT
					if v_input.valid = '0' then
						v_output := DEFAULT_MEMORY_OUTPUT;
					end if;
					v_output.writeback_register := input.writeback_register;
					v_output.writeback_value := input.writeback_value;
					v_output.tag := input.tag;
					v_output.act := input.act;
					--if v_input.memory_operation = MEMORY_OPERATION_LOAD then
					--	v_output.convert_memory_order_indicator := '1';
					--else
					--	v_output.convert_memory_order_indicator := '0';
					--end if;
					--output.memory_size := input.memory_size;
					--output.address_bits := input.result(1 downto 0);
					
					-- MEMORY READ/WRITE PORT OUTPUT
					if input.memory_operation = MEMORY_OPERATION_STORE then
						v_read_write_port.enable := '1';
						v_read_write_port.address := input.memory_address(29 downto 2) & "00";
						v_read_write_port.read_cmd := DEFAULT_READ_CMD_SIGNALS;
						v_read_write_port.write_cmd.enable := '1';
						v_read_write_port.write_cmd.data := input.memory_data;
						v_read_write_port.write_cmd.mask := not(input.memory_write_mask);
					else
						v_read_write_port := DEFAULT_READ_WRITE_PORT_SIGNALS;
					end if;
				end if;
			end if;

			if stall_in = '0' then
				output <= v_output;
			end if;

			if stall_in = '0' and not(v_should_stall) then
				read_write_port_out <= v_read_write_port;
				buffered_input <= DEFAULT_EXECUTE_OUTPUT;
			else
				read_write_port_out <= DEFAULT_READ_WRITE_PORT_SIGNALS;
				buffered_input <= v_input;
			end if;
		end if;
	end process;
end Behavioral;