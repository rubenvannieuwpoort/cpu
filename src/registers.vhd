library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity registers is
	port(
		clk: in std_logic;
		read_hold_in: in std_logic;
		read_data_in: in decode_output_type;

		read_busy_out: out std_logic := '0';
		read_data_out: out register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
		
		write_data_in: in memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end registers;


architecture Behavioral of registers is
	signal buffered_read_input: decode_output_type := DEFAULT_DECODE_OUTPUT;

	type register_file is array(0 to 15) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");

	type scoreboard is array(0 to 15) of std_logic_vector(1 downto 0);
	signal writes_in_flight: scoreboard := ("00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00");
begin

	process(clk)
		variable v_read_input: decode_output_type;
		variable v_read_internal_hold: std_logic;
		variable v_read_data_out: register_read_output_type;
		variable v_register_1_value, v_register_2_value: std_logic_vector(31 downto 0);
		variable v_write_incoming, v_write_outgoing: std_logic;
	begin
		read_busy_out <= buffered_read_input.valid;

		if rising_edge(clk) then

			-- register read stage
			if read_hold_in = '0' then

				-- select input
				if buffered_read_input.valid = '1' then
					v_read_input := buffered_read_input;
				else
					v_read_input := read_data_in;
				end if;

				-- TODO: compute v_internal_hold and v_data_out based on input
				v_read_internal_hold := '0';
				if v_read_input.valid = '1' then
					if v_read_input.read_indicator_1 = '1' then
						if writes_in_flight(to_integer(unsigned(v_read_input.read_register_1))) = "00" then
							v_register_1_value := reg(to_integer(unsigned(v_read_input.read_register_1)));
						elsif writes_in_flight(to_integer(unsigned(v_read_input.read_register_1))) = "01" and write_data_in.writeback_indicator = '1' and write_data_in.writeback_register = v_read_input.read_register_1 then
							v_register_1_value := write_data_in.writeback_value;
						else
							v_register_1_value := (others => '0');
						end if;
					else
						v_register_1_value := (others => '0');
					end if;
					
					if v_read_input.read_indicator_2 = '1' then
						if writes_in_flight(to_integer(unsigned(v_read_input.read_register_2))) = "00" then
							v_register_2_value := reg(to_integer(unsigned(v_read_input.read_register_2)));
						elsif writes_in_flight(to_integer(unsigned(v_read_input.read_register_2))) = "01" and write_data_in.writeback_indicator = '1' and write_data_in.writeback_register = v_read_input.read_register_2 then
							v_register_1_value := write_data_in.writeback_value;
						else
							v_register_2_value := (others => '0');
						end if;
					else
						v_register_2_value := (others => '0');
					end if;

					v_read_data_out.valid := '1';
					v_read_data_out.execute_operation := v_read_input.execute_operation;
					v_read_data_out.memory_operation := v_read_input.memory_operation;
					v_read_data_out.operand_1 := v_register_1_value;
					if v_read_input.switch_indicator = '0' then
						v_read_data_out.operand_2 := v_register_2_value;
						v_read_data_out.value := v_read_input.immediate;
					else
						v_read_data_out.operand_2 := v_read_input.immediate;
						v_read_data_out.value := v_register_2_value;
					end if;
					v_read_data_out.writeback_indicator := v_read_input.writeback_indicator;
					v_read_data_out.writeback_register := v_read_input.writeback_register;
				else
					v_read_data_out := DEFAULT_REGISTER_READ_OUTPUT;
				end if;
			else
				v_read_internal_hold := '1';
			end if;

			if v_read_internal_hold = '0' then
				read_data_out <= v_read_data_out;
				buffered_read_input <= DEFAULT_DECODE_OUTPUT;
			else
				read_data_out <= DEFAULT_REGISTER_READ_OUTPUT;

				if buffered_read_input.valid = '0' and read_data_in.valid = '1' then
					buffered_read_input <= read_data_in;
				end if;
			end if;
			
			
			-- register write stage
			if write_data_in.writeback_indicator = '1' then
				reg(to_integer(unsigned(write_data_in.writeback_register))) <= write_data_in.writeback_value;
			end if;
			
			-- bookkeeping of in-flight writes
			v_write_incoming := write_data_in.writeback_indicator;
			v_write_outgoing := v_read_input.valid and not(v_read_internal_hold) and v_read_data_out.writeback_indicator;
			if v_write_outgoing = '1' and v_write_incoming = '1' and v_read_input.writeback_register = write_data_in.writeback_register then
				-- both an incoming and an outgoing write to the same register, no change
			else
				if v_write_incoming = '1' then
					writes_in_flight(to_integer(unsigned(write_data_in.writeback_register))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(write_data_in.writeback_register)))) - 1);
				end if;

				if v_write_outgoing = '1' then
					writes_in_flight(to_integer(unsigned(v_read_input.writeback_register))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(v_read_input.writeback_register)))) + 1);
				end if;
			end if;
		end if;
	end process;

end Behavioral;
