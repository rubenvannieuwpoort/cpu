library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_level_types.all;
use work.top_level_constants.all;

use work.core_types.all;
use work.core_constants.all;


entity memory_stage is
	port(
		clk: in std_logic;
		memory_ready_in: std_logic;
		input: in execute_output_type;

		data_port_status_in: in memory_port_status;
		data_port_out: out memory_port := DEFAULT_MEMORY_PORT;

		stall_out: out std_logic := '0';
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory_stage;


architecture Behavioral of memory_stage is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;

	constant STATE_INIT: std_logic_vector(1 downto 0) := "00";
	constant STATE_DEFAULT: std_logic_vector(1 downto 0) := "01";
	constant STATE_READING: std_logic_vector(1 downto 0) := "10";
	signal state: std_logic_vector(1 downto 0) := STATE_INIT;
	signal initializing: std_logic := '1';
begin
	stall_out <= buffered_input.valid or initializing;

	process(clk)
		variable v_extn: std_logic_vector(31 downto 0);
		variable v_temp_halfword: std_logic_vector(15 downto 0);
		variable v_temp_byte: std_logic_vector(7 downto 0);
		variable v_input: execute_output_type;
	begin

		if rising_edge(clk) then
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if state = STATE_INIT then
				if memory_ready_in = '1' then
					initializing <= '0';
					state <= STATE_DEFAULT;
				end if;
			elsif state = STATE_DEFAULT then
				if v_input.memory_operation = MEMORY_OPERATION_LOAD then
					if data_port_status_in.ready = '1' then
						state <= STATE_READING;

						buffered_input <= v_input;

						output <= DEFAULT_MEMORY_OUTPUT;

						data_port_out.enable <= '1';
						data_port_out.command <= COMMAND_READ;
						data_port_out.address <= v_input.memory_address(26 downto 0);
						data_port_out.write_data <= (others => '0');
						data_port_out.write_mask <= "0000";
					else
						state <= STATE_DEFAULT;
						buffered_input <= v_input;
						output <= DEFAULT_MEMORY_OUTPUT;
						data_port_out <= DEFAULT_MEMORY_PORT;
					end if;
				elsif v_input.memory_operation = MEMORY_OPERATION_STORE then
					if data_port_status_in.ready = '1' then
						state <= STATE_DEFAULT;

						buffered_input <= DEFAULT_EXECUTE_OUTPUT;

						output.act <= v_input.act;
						output.writeback_value <= v_input.writeback_value;
						output.writeback_register <= v_input.writeback_register;
						output.tag <= v_input.tag;

						data_port_out.enable <= '1';
						data_port_out.command <= COMMAND_WRITE;
						data_port_out.address <= v_input.memory_address(26 downto 0);
						data_port_out.write_data <= v_input.memory_data;
						data_port_out.write_mask <= v_input.memory_write_mask;
					else
						state <= STATE_DEFAULT;
						buffered_input <= v_input;
						output <= DEFAULT_MEMORY_OUTPUT;
						data_port_out <= DEFAULT_MEMORY_PORT;
					end if;
				else
					state <= STATE_DEFAULT;

					buffered_input <= DEFAULT_EXECUTE_OUTPUT;

					output.act <= v_input.act;
					output.writeback_value <= v_input.writeback_value;
					output.writeback_register <= v_input.writeback_register;
					output.tag <= v_input.tag;

					data_port_out <= DEFAULT_MEMORY_PORT;
				end if;
			elsif state = STATE_READING then
				if data_port_status_in.data_valid = '1' then
					state <= STATE_DEFAULT;

					buffered_input <= DEFAULT_EXECUTE_OUTPUT;

					output.act <= v_input.act;

					if (v_input.memory_size = MEMORY_SIZE_BYTE) then
						if (v_input.memory_address(1 downto 0) = "00") then
							v_temp_byte := data_port_status_in.read_data(31 downto 24);
						elsif (v_input.memory_address(1 downto 0) = "01") then
							v_temp_byte := data_port_status_in.read_data(23 downto 16);
						elsif (v_input.memory_address(1 downto 0) = "10") then
							v_temp_byte := data_port_status_in.read_data(15 downto 8);
						else
							v_temp_byte := data_port_status_in.read_data(7 downto 0);
						end if;

						v_extn := (others => (v_input.sign_extend and v_temp_byte(7)));
						output.writeback_value <= v_extn(31 downto 8) & v_temp_byte;
					elsif (v_input.memory_size = MEMORY_SIZE_BYTE) then
						if (v_input.memory_address(1 downto 0) = "00") then
							v_temp_halfword := data_port_status_in.read_data(23 downto 16) & data_port_status_in.read_data(31 downto 24);
						else
							v_temp_halfword := data_port_status_in.read_data(7 downto 0) & data_port_status_in.read_data(15 downto 8);
						end if;

						v_extn := (others => (v_input.sign_extend and v_temp_halfword(15)));
						output.writeback_value <= v_extn(31 downto 16) & v_temp_halfword;
					else
						output.writeback_value <= data_port_status_in.read_data(7 downto 0) & data_port_status_in.read_data(15 downto 8) & data_port_status_in.read_data(23 downto 16) & data_port_status_in.read_data(31 downto 24);
					end if;

					output.writeback_register <= v_input.writeback_register;
					output.tag <= v_input.tag;

					data_port_out <= DEFAULT_MEMORY_PORT;
				else
					state <= STATE_READING;
					buffered_input <= v_input;
					output <= DEFAULT_MEMORY_OUTPUT;
					data_port_out <= DEFAULT_MEMORY_PORT;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
