library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity execute is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in register_read_output_type;

		busy_out: out std_logic := '0';
		output: out execute_output_type := DEFAULT_EXECUTE_OUTPUT;

		branch_continue_indicator: out std_logic := '0';
		branch_address_indicator: out std_logic := '0';
		branch_address: out std_logic_vector(19 downto 0) := "00000000000000000000"
	);
end execute;


architecture Behavioral of execute is
	signal buffered_input: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
	signal zero_flag: std_logic := '0';
	signal sign_flag: std_logic := '0';
	signal overflow_flag: std_logic := '0';
	signal carry_flag: std_logic := '0';
begin

	process(clk)
		variable v_input: register_read_output_type;
		variable v_act: std_logic;
		variable v_wait: std_logic;
		variable v_output: execute_output_type;
		variable v_result: std_logic_vector(31 downto 0);
		variable v_carry_flag: std_logic;
		variable v_overflow_flag: std_logic;

		variable v_full_unsigned_product: std_logic_vector(63 downto 0);
		variable v_signed_high_bits: std_logic_vector(31 downto 0);
		
		variable v_corr1: std_logic_vector(31 downto 0);
		variable v_corr2: std_logic_vector(31 downto 0);
		variable v_temp: std_logic_vector(31 downto 0);
		variable v_temp2: std_logic_vector(31 downto 0);

		variable v_full_result: std_logic_vector(32 downto 0);
		
		variable v_branch_continue_indicator: std_logic;
		variable v_branch_address_indicator: std_logic;
		variable v_branch_address: std_logic_vector(19 downto 0);
	begin
		busy_out <= buffered_input.valid;

		if rising_edge(clk) then
			v_branch_continue_indicator := '0';
			v_branch_address_indicator := '0';
			v_branch_address := (others => '0');
		
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			v_act := '0';
			v_wait := '0';
			v_carry_flag := '0';
			v_overflow_flag := '0';
			if hold_in = '0' then
				-- compute result
				if v_input.execute_operation = EXECUTE_OPERATION_SECOND then
					v_result := v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_ADD then
					v_full_result := std_logic_vector(unsigned('0' & v_input.operand_1) + unsigned('0' & v_input.operand_2));
					v_result := v_full_result(31 downto 0);
					v_carry_flag := v_full_result(32);
					v_overflow_flag := (v_input.operand_1(31) xnor v_input.operand_2(31)) and (v_input.operand_1(31) xor v_result(31));
				elsif v_input.execute_operation = EXECUTE_OPERATION_SUB then
					v_full_result := std_logic_vector(unsigned('0' & v_input.operand_1) - unsigned('0' & v_input.operand_2));
					v_result := v_full_result(31 downto 0);
					v_carry_flag := v_full_result(32);
					v_overflow_flag := (v_input.operand_1(31) xor v_input.operand_2(31)) and (v_input.operand_1(31) xor v_result(31));
				elsif v_input.execute_operation = EXECUTE_OPERATION_MUL then
					v_full_unsigned_product := std_logic_vector(unsigned(v_input.operand_1) * unsigned(v_input.operand_2));
					v_result := v_full_unsigned_product(31 downto 0);

					-- overflow flag
					if v_input.operand_2(31) = '1' then
						v_corr1 := v_input.operand_1;
					else
						v_corr1 := (others => '0');
					end if;
					if v_input.operand_1(31) = '1' then
						v_corr2 := v_input.operand_2;
					else
						v_corr2 := (others => '0');
					end if;
					v_signed_high_bits := std_logic_vector(unsigned(v_full_unsigned_product(63 downto 32)) - unsigned(v_corr1) - unsigned(v_corr2));
					if (v_signed_high_bits = "00000000000000000000000000000000" or v_signed_high_bits = "11111111111111111111111111111111") and v_signed_high_bits(31) = v_result(31) then
						v_overflow_flag := '0';
					else
						v_overflow_flag := '1';
					end if;

					-- carry flag
					if unsigned(v_full_unsigned_product(63 downto 32)) = 0 then
						v_carry_flag := '0';
					else
						v_carry_flag := '1';
					end if;
				elsif v_input.execute_operation = EXECUTE_OPERATION_AND then
					v_result := v_input.operand_1 and v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_OR then
					v_result := v_input.operand_1 or v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_XOR then
					v_result := v_input.operand_1 xor v_input.operand_2;
				elsif v_input.execute_operation = EXECUTE_OPERATION_NOT then
					v_result := not(v_input.operand_2);
				elsif v_input.execute_operation = EXECUTE_OPERATION_SHL then
					v_temp := v_input.operand_1;
					if unsigned(v_input.operand_2) >= 32 then
						v_result := (others => '0');
					else
						if v_input.operand_2(4) = '1' then
							v_temp := v_temp(15 downto 0) & "0000000000000000";
						end if;
						if v_input.operand_2(3) = '1' then
							v_temp := v_temp(23 downto 0) & "00000000";
						end if;
						if v_input.operand_2(2) = '1' then
							v_temp := v_temp(27 downto 0) & "0000";
						end if;
						if v_input.operand_2(1) = '1' then
							v_temp := v_temp(29 downto 0) & "00";
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := v_temp(30 downto 0) & "0";
						end if;
						v_result := v_temp;
					end if;
				elsif v_input.execute_operation = EXECUTE_OPERATION_SHR then
					v_temp := v_input.operand_1;
					if unsigned(v_input.operand_2) >= 32 then
						v_result := (others => '0');
					else
						if v_input.operand_2(4) = '1' then
							v_temp := "0000000000000000" & v_temp(31 downto 16);
						end if;
						if v_input.operand_2(3) = '1' then
							v_temp := "00000000" & v_temp(31 downto 8);
						end if;
						if v_input.operand_2(2) = '1' then
							v_temp := "0000" & v_temp(31 downto 4);
						end if;
						if v_input.operand_2(1) = '1' then
							v_temp := "00" & v_temp(31 downto 2);
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := "0" & v_temp(31 downto 1);
						end if;
						v_result := v_temp;
					end if;
				elsif v_input.execute_operation = EXECUTE_OPERATION_SAR then
					v_temp := v_input.operand_1;
					v_temp2 := (others => v_input.operand_1(31));
					if unsigned(v_input.operand_2) >= 32 then
						v_result := v_temp2;
					else
						if v_input.operand_2(4) = '1' then
							v_temp := v_temp2(15 downto 0) & v_temp(31 downto 16);
						end if;
						if v_input.operand_2(3) = '1' then
							v_temp := v_temp2(7 downto 0) & v_temp(31 downto 8);
						end if;
						if v_input.operand_2(2) = '1' then
							v_temp := v_temp2(3 downto 0) & v_temp(31 downto 4);
						end if;
						if v_input.operand_2(1) = '1' then
							v_temp := v_temp2(2 downto 0) & v_temp(31 downto 2);
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := v_temp2(1 downto 0) & v_temp(31 downto 1);
						end if;
						v_result := v_temp;
					end if;
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE0 then
					v_result := v_input.operand_1(31 downto 8) & v_input.operand_2(7 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE1 then
					v_result := v_input.operand_1(31 downto 16) & v_input.operand_2(7 downto 0) & v_input.operand_1(7 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE2 then
					v_result := v_input.operand_1(31 downto 24) & v_input.operand_2(7 downto 0) & v_input.operand_1(15 downto 0);
				elsif v_input.execute_operation = EXECUTE_OPERATION_BYTE3 then
					v_result := v_input.operand_2(7 downto 0) & v_input.operand_1(23 downto 0);
				end if;

				-- set flags
				if v_input.valid = '1' and v_input.flag_set_indicator = '1' and unsigned(v_input.execute_operation) <= unsigned(EXECUTE_OPERATION_NOT) then
					if unsigned(v_result) = 0 then
						zero_flag <= '1';
					else
						zero_flag <= '0';
					end if;

					if v_result(31) = '1' then
						sign_flag <= '1';
					else
						sign_flag <= '0';
					end if;

					if v_input.execute_operation = EXECUTE_OPERATION_ADD or v_input.execute_operation = EXECUTE_OPERATION_SUB or v_input.execute_operation = EXECUTE_OPERATION_MUL then
						carry_flag <= v_carry_flag;
						overflow_flag <= v_overflow_flag;
					end if;
				end if;

				-- evaluate condition and set v_act accordingly
				if v_input.condition = COND_ALWAYS then
					v_act := '1';
				elsif v_input.condition = COND_O then
					v_act := overflow_flag;
				elsif v_input.condition = COND_NO then
					v_act := not(overflow_flag);
				elsif v_input.condition = COND_N then
					v_act := sign_flag;
				elsif v_input.condition = COND_NN then
					v_act := not(sign_flag);
				elsif v_input.condition = COND_E then
					v_act := zero_flag;
				elsif v_input.condition = COND_NE then
					v_act := not(zero_flag);
				elsif v_input.condition = COND_B then
					v_act := carry_flag;
				elsif v_input.condition = COND_NB then
					v_act := not(carry_flag);
				elsif v_input.condition = COND_BE then
					v_act := carry_flag or zero_flag;
				elsif v_input.condition = COND_A then
					v_act := not(carry_flag) and not(zero_flag);
				elsif v_input.condition = COND_L then
					v_act := sign_flag xor overflow_flag;
				elsif v_input.condition = COND_GE then
					v_act := sign_flag xnor overflow_flag;
				elsif v_input.condition = COND_LE then
					v_act := zero_flag or (sign_flag xor overflow_flag);
				elsif v_input.condition = COND_G then
					v_act := not(zero_flag) and (sign_flag xnor overflow_flag);
				elsif v_input.condition = COND_P then
					v_act := not(sign_flag) and not(zero_flag);
				elsif v_input.condition = COND_NP then
					v_act := sign_flag or zero_flag;
				end if;

				-- conversion to little endian for stores
				if v_input.valid = '1' then
					v_output.valid := '1';
					v_output.memory_operation := v_input.memory_operation;

					if v_input.memory_operation = MEMORY_OPERATION_STORE then
						if v_input.memory_size = MEMORY_SIZE_WORD then
							if v_result(1 downto 0) = "00" then
								v_output.write_enable := "1111";
								v_output.value := v_input.value(7 downto 0) & v_input.value(15 downto 8) & v_input.value(23 downto 16) & v_input.value(31 downto 24);
							else
								-- error
							end if;
						elsif v_input.memory_size = MEMORY_SIZE_HALFWORD then
							if v_result(1 downto 0) = "00" then
								v_output.write_enable := "1100";
								v_output.value := v_input.value(7 downto 0) & v_input.value(15 downto 8) & "0000000000000000";
							elsif v_result(1 downto 0) = "10" then
								v_output.write_enable := "0011";
								v_output.value := "0000000000000000" & v_input.value(7 downto 0) & v_input.value(15 downto 8);
							else
								-- error
							end if;
						elsif v_input.memory_size = MEMORY_SIZE_BYTE then
							if v_result(1 downto 0) = "00" then
								v_output.write_enable := "1000";
								v_output.value := v_input.value(7 downto 0) & "000000000000000000000000";
							elsif v_result(1 downto 0) = "01" then
								v_output.write_enable := "0100";
								v_output.value := "00000000" & v_input.value(7 downto 0) & "0000000000000000";
							elsif v_result(1 downto 0) = "10" then
								v_output.write_enable := "0010";
								v_output.value := "0000000000000000" & v_input.value(7 downto 0) & "00000000";
							elsif v_result(1 downto 0) = "11" then
								v_output.write_enable := "0001";
								v_output.value := "000000000000000000000000" & v_input.value(7 downto 0);
							end if;
						end if;
					else
						v_output.write_enable := "0000";
						v_output.value := v_input.value;
					end if;

					v_output.result := v_result;
					-- v_output.value := v_input.value;
					v_output.writeback_indicator := v_input.writeback_indicator;
					v_output.writeback_register := v_input.writeback_register;
					v_output.act := v_act;
					v_output.tag := v_input.tag;
				else
					v_output := DEFAULT_EXECUTE_OUTPUT;
				end if;
				
				if v_wait = '1' then
					v_output := DEFAULT_EXECUTE_OUTPUT;
				else
					buffered_input <= DEFAULT_REGISTER_READ_OUTPUT;

					-- branching
					if v_input.is_branch = '1' then
						-- branches are read directly by fetch stage, they are not subject to the normal pipelining logic
						-- so we need to take care to ignore the hold_in signal and ensure the address is only handed to the fetch unit once
						v_input.is_branch := '0';
						if v_act = '1' then
							v_branch_address_indicator := '1';
							v_branch_address := v_result(19 downto 0);
						else
							v_branch_continue_indicator := '1';
						end if;
					end if;
				end if;

				output <= v_output;
			end if;

			branch_continue_indicator <= v_branch_continue_indicator;
			branch_address_indicator <= v_branch_address_indicator;
			branch_address <= v_branch_address;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				v_input.is_branch := '0';
				buffered_input <= v_input;
			end if;

			busy_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
