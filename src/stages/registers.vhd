library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity registers is
	port(
		clk: in std_logic;
		read_hold_in: in std_logic;
		read_input: in decode_output_type;

		read_hold_out: out std_logic := '0';
		read_output: out register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
		
		write_input: in memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end registers;


architecture Behavioral of registers is
	signal buffered_read_input: decode_output_type := DEFAULT_DECODE_OUTPUT;

	type register_file is array(0 to 31) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");

	type scoreboard is array(0 to 31) of std_logic_vector(1 downto 0);
	signal writes_in_flight: scoreboard := ("00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00");
begin

	process(clk)
		variable v_read_input: decode_output_type;
		variable v_read_wait: std_logic;
		variable v_read_output: register_read_output_type;
		variable v_register_1_value, v_register_2_3_value: std_logic_vector(31 downto 0);
		variable v_write_incoming, v_write_outgoing: boolean;
		variable v_register_1_ready, v_register_2_3_ready: std_logic;
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
					if v_read_input.operand_1_type = TYPE_REGISTER then
						if writes_in_flight(to_integer(unsigned(v_read_input.operand_1_register))) = "00" then
							v_register_1_value := reg(to_integer(unsigned(v_read_input.operand_1_register)));
							v_register_1_ready := '1';
						elsif writes_in_flight(to_integer(unsigned(v_read_input.operand_1_register))) = "01" and write_input.writeback_register /= "00000" and write_input.writeback_register = v_read_input.operand_1_register then
							v_register_1_value := write_input.writeback_value;
							v_register_1_ready := '1';
						else
							v_register_1_value := (others => '0');
							v_register_1_ready := '0';
						end if;
					else
						v_register_1_value := (others => '0');
						v_register_1_ready := '1';
					end if;
					
					if v_read_input.operand_2_type = TYPE_REGISTER or v_read_input.operand_3_type = TYPE_REGISTER then
						if writes_in_flight(to_integer(unsigned(v_read_input.operand_2_3_register))) = "00" then
							v_register_2_3_value := reg(to_integer(unsigned(v_read_input.operand_2_3_register)));
							v_register_2_3_ready := '1';
						elsif writes_in_flight(to_integer(unsigned(v_read_input.operand_2_3_register))) = "01" and write_input.writeback_register /= "00000" and write_input.writeback_register = v_read_input.operand_2_3_register then
							v_register_2_3_value := write_input.writeback_value;
							v_register_2_3_ready := '1';
						else
							v_register_2_3_value := (others => '0');
							v_register_2_3_ready := '0';
						end if;
					else
						v_register_2_3_value := (others => '0');
						v_register_2_3_ready := '1';
					end if;

					if (v_register_1_ready and v_register_2_3_ready) = '1' then
						v_read_wait := '0';

						v_read_output.valid := '1';

						if v_read_input.operand_1_type = TYPE_REGISTER then
							v_read_output.operand_1 := v_register_1_value;
						else
							v_read_output.operand_1 := v_read_input.operand_1_immediate;
						end if;

						if v_read_input.operand_2_type = TYPE_REGISTER then
							v_read_output.operand_2 := v_register_2_3_value;
						else
							v_read_output.operand_2 := v_read_input.operand_2_immediate;
						end if;

						if v_read_input.operand_3_type = TYPE_REGISTER then
							v_read_output.operand_3 := v_register_2_3_value;
						else
							v_read_output.operand_3 := v_read_input.operand_3_immediate;
						end if;

						if v_read_input.operand_1_type = TYPE_REGISTER and v_read_input.operand_1_register = "00000" then
							v_read_output.operand_1_is_zero_register := '1';
						else
							v_read_output.operand_1_is_zero_register := '0';
						end if;

						v_read_output.branch_to_be_handled := v_read_input.branch_to_be_handled;
						v_read_output.writeback_register := v_read_input.writeback_register;
						v_read_output.csr_register := v_read_input.csr_register;
						v_read_output.alu_function := v_read_input.alu_function;
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

			read_hold_out <= read_hold_in or v_read_wait;

			
			-- REGISTER WRITE STAGE
			-- ====================

			--if write_input.convert_memory_order_indicator = '1' then
			--	if write_input.memory_size = MEMORY_SIZE_WORD then
			--		if write_input.address_bits = "00" then
			--			v_writeback_value := write_input.writeback_value(7 downto 0) & write_input.writeback_value(15 downto 8) &  write_input.writeback_value(23 downto 16) & write_input.writeback_value(31 downto 24);
			--		else
			--			-- TODO: error?
			--		end if;
			--	elsif write_input.memory_size = MEMORY_SIZE_HALFWORD then
			--		if write_input.address_bits = "00" then
			--			v_writeback_value := "0000000000000000" & write_input.writeback_value(7 downto 0) & write_input.writeback_value(15 downto 8);
			--		elsif write_input.address_bits = "10" then
			--			v_writeback_value := "0000000000000000" & write_input.writeback_value(23 downto 16) & write_input.writeback_value(31 downto 24);
			--		else
			--			-- TODO: error?
			--		end if;
			--	elsif write_input.memory_size = MEMORY_SIZE_BYTE then
			--		if write_input.address_bits = "00" then
			--			v_writeback_value := "000000000000000000000000" & write_input.writeback_value(7 downto 0);
			--		elsif write_input.address_bits = "01" then
			--			v_writeback_value := "000000000000000000000000" & write_input.writeback_value(15 downto 8);
			--		elsif write_input.address_bits = "10" then
			--			v_writeback_value := "000000000000000000000000" & write_input.writeback_value(23 downto 16);
			--		elsif write_input.address_bits = "11" then
			--			v_writeback_value := "000000000000000000000000" & write_input.writeback_value(31 downto 24);
			--		end if;
			--	else
			--		-- TODO: error?
			--	end if;
			--else
				v_writeback_value := write_input.writeback_value;
			--end if;

			if write_input.writeback_register /= "00000" then
				reg(to_integer(unsigned(write_input.writeback_register))) <= v_writeback_value;
			end if;
			
			-- bookkeeping of in-flight writes
			v_write_incoming := write_input.writeback_register /= "00000";
			v_write_outgoing := v_read_input.valid = '1' and v_read_wait = '0' and v_read_output.writeback_register /= "00000";
			if v_write_outgoing and v_write_incoming and v_read_input.writeback_register = write_input.writeback_register then
				-- both an incoming and an outgoing write to the same register, no change
			else
				if v_write_incoming then
					writes_in_flight(to_integer(unsigned(write_input.writeback_register))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(write_input.writeback_register)))) - 1);
				end if;

				if v_write_outgoing then
					writes_in_flight(to_integer(unsigned(v_read_input.writeback_register))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(v_read_input.writeback_register)))) + 1);
				end if;
			end if;
		end if;
	end process;

end Behavioral;
