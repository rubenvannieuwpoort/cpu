library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity execute is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in register_read_output_type;

		hold_out: out std_logic := '0';
		output: out execute_output_type := DEFAULT_EXECUTE_OUTPUT;

		continue_out: out std_logic := '0';
		pc_indicator_out: out std_logic := '0';
		pc_out: out std_logic_vector(31 downto 0) := (others => '0')
	);
end execute;


architecture Behavioral of execute is
	signal buffered_input: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
begin

	process(clk)
		variable v_input: register_read_output_type;
		variable v_wait: std_logic;
		variable v_output: execute_output_type;
		variable v_temp: std_logic_vector(31 downto 0);
		variable v_temp2: std_logic_vector(31 downto 0);
		
		variable v_branch_continue_indicator: std_logic;
		variable v_branch_address_indicator: std_logic;
		variable v_branch_address: std_logic_vector(19 downto 0);
	begin
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

			v_wait := '0';
			if hold_in = '0' then
				if v_input.alu_function = ALU_FUNCTION_ADD then
					v_output.valid := '1';
					v_output.writeback_value := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_2));
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SUB then
					v_output.valid := '1';
					v_output.writeback_value := std_logic_vector(unsigned(v_input.operand_1) - unsigned(v_input.operand_2));
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SLT then
					v_output.valid := '1';
					if signed(v_input.operand_1) < signed(v_input.operand_2) then
						v_output.writeback_value := std_logic_vector(to_unsigned(1, 32));
					else
						v_output.writeback_value := (others => '0');
					end if;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SLTU then
					v_output.valid := '1';
					if unsigned(v_input.operand_1) < unsigned(v_input.operand_2) then
						v_output.writeback_value := std_logic_vector(to_unsigned(1, 32));
					else
						v_output.writeback_value := (others => '0');
					end if;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_AND then
					v_output.valid := '1';
					v_output.writeback_value := v_input.operand_1 and v_input.operand_2;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_OR then
					v_output.valid := '1';
					v_output.writeback_value := v_input.operand_1 or v_input.operand_2;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_XOR then
					v_output.valid := '1';
					v_output.writeback_value := v_input.operand_1 xor v_input.operand_2;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SHIFT_LEFT then
					v_temp := v_input.operand_1;
					if unsigned(v_input.operand_2) >= 32 then
						v_temp := (others => '0');
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
					end if;

					v_output.valid := '1';
					v_output.writeback_value := v_temp;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SHIFT_RIGHT then
					v_temp := v_input.operand_1;
					if unsigned(v_input.operand_2) >= 32 then
						v_temp := (others => '0');
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
					end if;

					v_output.valid := '1';
					v_output.writeback_value := v_temp;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT then
					v_temp := v_input.operand_1;
					v_temp2 := (others => v_input.operand_1(31));
					if unsigned(v_input.operand_2) >= 32 then
						v_temp := v_temp2;
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
							v_temp := v_temp2(2 downto 0) & v_temp(31 downto 3);
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := v_temp2(1 downto 0) & v_temp(31 downto 2);
						end if;
					end if;

					v_output.valid := '1';
					v_output.writeback_value := v_temp;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_JAL then
					v_output.valid := '1';
					v_output.writeback_value := v_input.operand_3;
					v_output.writeback_register := v_input.writeback_register;
					v_output.tag := v_input.tag;
					
					v_branch_continue_indicator := '0';
					v_branch_address_indicator := '1';
					v_branch_address := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_2));
				elsif v_input.alu_function = ALU_FUNCTION_BEQ then
					v_output.valid := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.tag := v_input.tag;

					if v_input.operand_1 = v_input.operand_2 then
						v_branch_continue_indicator := '0';
						v_branch_address_indicator := '1';
						v_branch_address := v_input.operand_3;
					else
						v_branch_continue_indicator := '1';
						v_branch_address_indicator := '0';
						v_branch_address := (others => '0');
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BNE then
					v_output.valid := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.tag := v_input.tag;

					if v_input.operand_1 /= v_input.operand_2 then
						v_branch_continue_indicator := '0';
						v_branch_address_indicator := '1';
						v_branch_address := v_input.operand_3;
					else
						v_branch_continue_indicator := '1';
						v_branch_address_indicator := '0';
						v_branch_address := (others => '0');
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BLT then
					v_output.valid := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.tag := v_input.tag;

					if signed(v_input.operand_1) < signed(v_input.operand_2) then
						v_branch_continue_indicator := '0';
						v_branch_address_indicator := '1';
						v_branch_address := v_input.operand_3;
					else
						v_branch_continue_indicator := '1';
						v_branch_address_indicator := '0';
						v_branch_address := (others => '0');
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BLTU then
					v_output.valid := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.tag := v_input.tag;

					if unsigned(v_input.operand_1) < unsigned(v_input.operand_2) then
						v_branch_continue_indicator := '0';
						v_branch_address_indicator := '1';
						v_branch_address := v_input.operand_3;
					else
						v_branch_continue_indicator := '1';
						v_branch_address_indicator := '0';
						v_branch_address := (others => '0');
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BGE then
					v_output.valid := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.tag := v_input.tag;

					if signed(v_input.operand_1) >= signed(v_input.operand_2) then
						v_branch_continue_indicator := '0';
						v_branch_address_indicator := '1';
						v_branch_address := v_input.operand_3;
					else
						v_branch_continue_indicator := '1';
						v_branch_address_indicator := '0';
						v_branch_address := (others => '0');
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BGEU then
					v_output.valid := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.tag := v_input.tag;

					if unsigned(v_input.operand_1) >= unsigned(v_input.operand_2) then
						v_branch_continue_indicator := '0';
						v_branch_address_indicator := '1';
						v_branch_address := v_input.operand_3;
					else
						v_branch_continue_indicator := '1';
						v_branch_address_indicator := '0';
						v_branch_address := (others => '0');
					end if;
				else
					-- TODO: this should never happen. Interrupt?
				end if;
				
				if v_wait = '1' then
					v_output := DEFAULT_EXECUTE_OUTPUT;
				else
					buffered_input <= DEFAULT_REGISTER_READ_OUTPUT;
				end if;

				output <= v_output;
			end if;

			if v_input.branch_to_be_handled = '1' then
				continue_out <= v_branch_continue_indicator;
				pc_indicator_out <= v_branch_address_indicator;
				pc_out <= v_branch_address;
				-- so we don't take the branch again
				v_input.branch_to_be_handled := '0';
			end if;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				buffered_input <= v_input;
			end if;

			hold_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
