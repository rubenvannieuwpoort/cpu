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

		read_write_status_in: in read_write_status_signals;
		read_write_port_out: out read_write_cmd_signals;

		stall_out: out std_logic := '0';
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal read_write_cmd: read_write_cmd_signals := DEFAULT_READ_WRITE_CMD;
	signal reading: std_logic := '0';

begin
	read_write_port_out <= read_write_cmd;
	stall_out <= buffered_input.valid;

	process(clk)
		variable v_should_stall: boolean;
		variable v_input: execute_output_type;

		variable v_read_write_cmd: read_write_cmd_signals := DEFAULT_READ_WRITE_CMD;
		variable v_output: memory_output_type := DEFAULT_MEMORY_OUTPUT;
	begin
		if rising_edge(clk) then
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if stall_in = '0' then
				if reading = '1' then
					-- TODO
				else
					v_should_stall := v_input.memory_operation = MEMORY_OPERATION_STORE and (memory_ready_in = '0' or unsigned(read_write_status_in.write_count) >= 16 or read_write_status_in.write_full = '1');
					               --or v_input.memory_operation = MEMORY_OPERATION_LOAD and (memory_ready_in = '0' or write_status_in.cmd_full = '1');
				end if;

				if v_should_stall then
					output <= DEFAULT_MEMORY_OUTPUT;
				end if;
			end if;

			if stall_in = '0' and not(v_should_stall) then
				if reading = '1' then
					-- TODO
				else
					if input.memory_operation = MEMORY_OPERATION_STORE then
						v_read_write_cmd.enable := '1';
						v_read_write_cmd.read_enable := '0';
						v_read_write_cmd.write_enable := '1';
						v_read_write_cmd.address := input.memory_address(29 downto 2) & "00";
						v_read_write_cmd.write_mask := not(input.memory_write_mask);
						v_read_write_cmd.write_data := input.memory_data;

						v_output.act := input.act;
						v_output.writeback_value := input.writeback_value;
						v_output.writeback_register := input.writeback_register;
						v_output.tag := input.tag;
					elsif input.memory_operation = MEMORY_OPERATION_LOAD then
						reading <= '1';

						v_read_write_cmd.enable := '1';
						v_read_write_cmd.read_enable := '1';
						v_read_write_cmd.write_enable := '0';
						v_read_write_cmd.address := input.memory_address(29 downto 2) & "00";
						v_read_write_cmd.write_mask := "1111";
						v_read_write_cmd.write_data := (others => '0');

						v_output := DEFAULT_MEMORY_OUTPUT;
					else
						v_read_write_cmd := DEFAULT_READ_WRITE_CMD;

						v_output.act := input.act;
						v_output.writeback_value := input.writeback_value;
						v_output.writeback_register := input.writeback_register;
						v_output.tag := input.tag;
					end if;
				end if;

				output <= v_output;
				read_write_cmd <= v_read_write_cmd;
				buffered_input <= DEFAULT_EXECUTE_OUTPUT;
			else
				read_write_cmd <= DEFAULT_READ_WRITE_CMD;
				buffered_input <= v_input;
			end if;
		end if;
	end process;
end Behavioral;