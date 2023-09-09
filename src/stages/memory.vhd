library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity memory is
	port(
		clk: in std_logic;
		memory_ready_in: in std_logic;
		input: in execute_output_type;

		read_write_status_in: in read_write_status_signals;
		read_write_port_out: out read_write_cmd_signals;

		stall_out: out std_logic := '0';
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal read_write_port: read_write_cmd_signals := DEFAULT_READ_WRITE_CMD;

	constant STATE_DEFAULT: std_logic := '0';
	constant STATE_READING: std_logic := '1';
	signal state: std_logic := STATE_DEFAULT;
begin
	read_write_port_out.enable <= read_write_port.enable;
	read_write_port_out.command <= read_write_port.command;
	read_write_port_out.read_enable <= '1';
	read_write_port_out.write_enable <= read_write_port.write_enable;
	read_write_port_out.address <= read_write_port.address;
	read_write_port_out.write_mask <= read_write_port.write_mask;
	read_write_port_out.write_data <= read_write_port.write_data;

	process(clk)
		variable v_extn: std_logic_vector(31 downto 0);
		variable v_temp_halfword: std_logic_vector(15 downto 0);
		variable v_temp_byte: std_logic_vector(7 downto 0);
		variable v_input: execute_output_type;
	begin
		stall_out <= buffered_input.valid;

		if rising_edge(clk) then
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if state = STATE_DEFAULT then
				if v_input.memory_operation = MEMORY_OPERATION_LOAD then
					if memory_ready_in = '1' and read_write_status_in.cmd_empty = '1' and read_write_status_in.write_empty = '1' and read_write_status_in.read_empty = '1' then
						state <= STATE_READING;

						buffered_input <= v_input;

						output <= DEFAULT_MEMORY_OUTPUT;

						read_write_port.enable <= '1';
						read_write_port.command <= CMD_READ;
						read_write_port.write_enable <= '0';
						read_write_port.address <= v_input.memory_address(29 downto 2) & "00";
						read_write_port.write_mask <= "1111";
						read_write_port.write_data <= (others => '0');
					else
						state <= STATE_DEFAULT;
						buffered_input <= v_input;
						output <= DEFAULT_MEMORY_OUTPUT;
						read_write_port <= DEFAULT_READ_WRITE_CMD;
					end if;
				elsif v_input.memory_operation = MEMORY_OPERATION_STORE then
					if memory_ready_in = '1' and unsigned(read_write_status_in.write_count) < 16 and read_write_status_in.cmd_full = '0' then
						state <= STATE_DEFAULT;

						buffered_input <= DEFAULT_EXECUTE_OUTPUT;

						output.act <= v_input.act;
						output.writeback_value <= v_input.writeback_value;
						output.writeback_register <= v_input.writeback_register;
						output.tag <= v_input.tag;

						read_write_port.enable <= '1';
						read_write_port.command <= CMD_WRITE;
						read_write_port.write_enable <= '1';
						read_write_port.address <= v_input.memory_address(29 downto 2) & "00";
						read_write_port.write_mask <= not(v_input.memory_write_mask);
						read_write_port.write_data <= v_input.memory_data;
					else
						state <= STATE_DEFAULT;
						buffered_input <= v_input;
						output <= DEFAULT_MEMORY_OUTPUT;
						read_write_port <= DEFAULT_READ_WRITE_CMD;
					end if;
				else
					state <= STATE_DEFAULT;

					buffered_input <= DEFAULT_EXECUTE_OUTPUT;

					output.act <= v_input.act;
					output.writeback_value <= v_input.writeback_value;
					output.writeback_register <= v_input.writeback_register;
					output.tag <= v_input.tag;

					read_write_port <= DEFAULT_READ_WRITE_CMD;
				end if;
			elsif state = STATE_READING then
				if read_write_status_in.read_empty = '0' then
					state <= STATE_DEFAULT;

					buffered_input <= DEFAULT_EXECUTE_OUTPUT;

					output.act <= v_input.act;

					if (v_input.memory_size = MEMORY_SIZE_BYTE) then
						if (v_input.memory_address(1 downto 0) = "00") then
							v_temp_byte := read_write_status_in.read_data(31 downto 24);
						elsif (v_input.memory_address(1 downto 0) = "01") then
							v_temp_byte := read_write_status_in.read_data(23 downto 16);
						elsif (v_input.memory_address(1 downto 0) = "10") then
							v_temp_byte := read_write_status_in.read_data(15 downto 8);
						else
							v_temp_byte := read_write_status_in.read_data(7 downto 0);
						end if;

						v_extn := (others => (v_input.sign_extend and v_temp_byte(7)));
						output.writeback_value <= v_extn(31 downto 8) & v_temp_byte;
					elsif (v_input.memory_size = MEMORY_SIZE_BYTE) then
						if (v_input.memory_address(1 downto 0) = "00") then
							v_temp_halfword := read_write_status_in.read_data(23 downto 16) & read_write_status_in.read_data(31 downto 24);
						else
							v_temp_halfword := read_write_status_in.read_data(7 downto 0) & read_write_status_in.read_data(15 downto 8);
						end if;

						v_extn := (others => (v_input.sign_extend and v_temp_halfword(15)));
						output.writeback_value <= v_extn(31 downto 16) & v_temp_halfword;
					else
						output.writeback_value <= read_write_status_in.read_data(7 downto 0) & read_write_status_in.read_data(15 downto 8) & read_write_status_in.read_data(23 downto 16) & read_write_status_in.read_data(31 downto 24);
					end if;

					output.writeback_register <= v_input.writeback_register;
					output.tag <= v_input.tag;

					read_write_port <= DEFAULT_READ_WRITE_CMD;
				else
					state <= STATE_READING;
					buffered_input <= v_input;
					output <= DEFAULT_MEMORY_OUTPUT;
					read_write_port <= DEFAULT_READ_WRITE_CMD;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
