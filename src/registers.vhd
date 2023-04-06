library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity registers is
	port(
		clk: in std_logic;
		read_hold_in: in std_logic;
		read_input: in decode_output_type;

		read_busy_out: out std_logic := '0';
		read_output: out register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
		
		write_input: in memory_output_type := DEFAULT_MEMORY_OUTPUT
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
		variable v_read_wait: std_logic;
		variable v_read_output: register_read_output_type;
		variable v_register_1_value, v_register_2_value: std_logic_vector(31 downto 0);
		variable v_write_incoming, v_write_outgoing: std_logic;
		variable v_register_1_ready, v_register_2_ready: std_logic;
		variable v_writeback_value: std_logic_vector(31 downto 0);
	begin

		if rising_edge(clk) then

			-- REGISTER READ STAGE
			-- ===================
			
			-- select input
			if buffered_read_input.valid = '1' then
				v_read_input := buffered_read_input;
			else
				v_read_input := read_input;
			end if;

			v_read_wait := '0';
			if read_hold_in = '0' then
				-- compute v_internal_hold and v_data_out based on input
				if v_read_input.valid = '1' then
					if v_read_input.read_indicator_1 = '1' then
						if writes_in_flight(to_integer(unsigned(v_read_input.read_register_1))) = "00" then
							v_register_1_value := reg(to_integer(unsigned(v_read_input.read_register_1)));
							v_register_1_ready := '1';
						elsif writes_in_flight(to_integer(unsigned(v_read_input.read_register_1))) = "01" and write_input.writeback_indicator = '1' and write_input.writeback_register = v_read_input.read_register_1 then
							if write_input.act = '1' then
								v_register_1_value := write_input.writeback_value;
							else
								v_register_1_value := reg(to_integer(unsigned(v_read_input.read_register_1)));
							end if;
							v_register_1_ready := '1';
						else
							v_register_1_value := (others => '0');
							v_register_1_ready := '0';
						end if;
					else
						v_register_1_value := (others => '0');
							v_register_1_ready := '1';
					end if;
					
					if v_read_input.read_indicator_2 = '1' then
						if writes_in_flight(to_integer(unsigned(v_read_input.read_register_2))) = "00" then
							v_register_2_value := reg(to_integer(unsigned(v_read_input.read_register_2)));
							v_register_2_ready := '1';
						elsif writes_in_flight(to_integer(unsigned(v_read_input.read_register_2))) = "01" and write_input.writeback_indicator = '1' and write_input.writeback_register = v_read_input.read_register_2 then
							if write_input.act = '1' then
								v_register_2_value := write_input.writeback_value;
							else
								v_register_2_value := reg(to_integer(unsigned(v_read_input.read_register_2)));
							end if;
							v_register_2_ready := '1';
						else
							v_register_2_value := (others => '0');
							v_register_2_ready := '0';
						end if;
					else
						v_register_2_value := (others => '0');
						v_register_2_ready := '1';
					end if;

					if (v_register_1_ready and v_register_2_ready) = '1' then
						v_read_wait := '0';
						v_read_output.valid := '1';
						v_read_output.flag_set_indicator := v_read_input.flag_set_indicator;
						v_read_output.execute_operation := v_read_input.execute_operation;
						v_read_output.memory_operation := v_read_input.memory_operation;
						v_read_output.memory_size := v_read_input.memory_size;
						v_read_output.operand_1 := v_register_1_value;
						if v_read_input.switch_indicator = '0' then
							v_read_output.operand_2 := v_register_2_value;
							v_read_output.value := v_read_input.immediate;
						else
							v_read_output.operand_2 := v_read_input.immediate;
							v_read_output.value := v_register_2_value;
						end if;
						v_read_output.writeback_indicator := v_read_input.writeback_indicator;
						v_read_output.writeback_register := v_read_input.writeback_register;
						v_read_output.is_branch := v_read_input.is_branch;
						v_read_output.condition := v_read_input.condition;
						v_read_output.tag := v_read_input.tag;
					else
						v_read_wait := '1';
						v_read_output := DEFAULT_REGISTER_READ_OUTPUT;
					end if;
				else
					v_read_output := DEFAULT_REGISTER_READ_OUTPUT;
				end if;
				
				if v_read_wait = '1' then
					v_read_output := DEFAULT_REGISTER_READ_OUTPUT;
				else
					buffered_read_input <= DEFAULT_DECODE_OUTPUT;
				end if;
				
				read_output <= v_read_output;
			end if;

			if v_read_input.valid = '1' and (read_hold_in = '1' or v_read_wait = '1') then
				buffered_read_input <= v_read_input;
			end if;

			read_busy_out <= read_hold_in or v_read_wait;

			
			-- REGISTER WRITE STAGE
			-- ====================

			if write_input.convert_memory_order_indicator = '1' then
				if write_input.memory_size = MEMORY_SIZE_WORD then
					if write_input.address_bits = "00" then
						v_writeback_value := write_input.writeback_value(7 downto 0) & write_input.writeback_value(15 downto 8) &  write_input.writeback_value(23 downto 16) & write_input.writeback_value(31 downto 24);
					else
						-- error
					end if;
				elsif write_input.memory_size = MEMORY_SIZE_HALFWORD then
					if write_input.address_bits = "00" then
						v_writeback_value := "0000000000000000" & write_input.writeback_value(7 downto 0) & write_input.writeback_value(15 downto 8);
					elsif write_input.address_bits = "10" then
						v_writeback_value := "0000000000000000" & write_input.writeback_value(23 downto 16) & write_input.writeback_value(31 downto 24);
					else
						-- error
					end if;
				elsif write_input.memory_size = MEMORY_SIZE_BYTE then
					if write_input.address_bits = "00" then
						v_writeback_value := "000000000000000000000000" & write_input.writeback_value(7 downto 0);
					elsif write_input.address_bits = "01" then
						v_writeback_value := "000000000000000000000000" & write_input.writeback_value(15 downto 8);
					elsif write_input.address_bits = "10" then
						v_writeback_value := "000000000000000000000000" & write_input.writeback_value(23 downto 16);
					elsif write_input.address_bits = "11" then
						v_writeback_value := "000000000000000000000000" & write_input.writeback_value(31 downto 24);
					end if;
				else
					-- error
				end if;
			else
				v_writeback_value := write_input.writeback_value;
			end if;

			if write_input.writeback_indicator = '1' and write_input.act = '1' then
				reg(to_integer(unsigned(write_input.writeback_register))) <= v_writeback_value;
			end if;
			
			-- bookkeeping of in-flight writes
			v_write_incoming := write_input.writeback_indicator;
			v_write_outgoing := v_read_input.valid and not(v_read_wait) and v_read_output.writeback_indicator;
			if v_write_outgoing = '1' and v_write_incoming = '1' and v_read_input.writeback_register = write_input.writeback_register then
				-- both an incoming and an outgoing write to the same register, no change
			else
				if v_write_incoming = '1' then
					writes_in_flight(to_integer(unsigned(write_input.writeback_register))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(write_input.writeback_register)))) - 1);
				end if;

				if v_write_outgoing = '1' then
					writes_in_flight(to_integer(unsigned(v_read_input.writeback_register))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(v_read_input.writeback_register)))) + 1);
				end if;
			end if;
		end if;
	end process;

end Behavioral;
