library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity decode is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in fetch_output_type;

		busy_out: out std_logic := '0';
		output: out decode_output_type := DEFAULT_DECODE_OUTPUT
	);
end decode;


architecture Behavioral of decode is
	signal buffered_input: fetch_output_type := DEFAULT_FETCH_OUTPUT;
	signal hold: std_logic := '0';
begin

	process(clk)
		variable v_wait: std_logic;
		variable v_input: fetch_output_type;
		variable v_output: decode_output_type;
		variable v_sign: std_logic_vector(31 downto 0);
	begin
		if rising_edge(clk) then
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			v_wait := '0';
			if hold_in = '0' then
				-- output generation
				if v_input.valid = '1' then
					v_output.tag := v_input.tag;

					if v_input.opcode(15 downto 0) = "0000000000000000" then
						-- nop
						v_output := DEFAULT_DECODE_OUTPUT;
					elsif v_input.opcode(15 downto 8) = "00000001" then
						-- conditional branch
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_ADD;  -- this works as 'none' by adding 0 to operand 1 (maybe I should just add a none op?)
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '0';
						v_output.writeback_indicator := '0';
						v_output.writeback_register := (others => '0');
						v_output.is_branch := '1';
						v_output.condition := '1' & v_input.opcode(3 downto 0);
					elsif v_input.opcode(15 downto 8) = "00000010" and v_input.opcode(3 downto 1) = "001" then
						-- increment/decrement
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_ADD;  -- this works as 'none' by adding 0 to operand? 1 (maybe I should just add a none op?)
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_sign := (others => v_input.opcode(0));
						v_output.immediate := v_sign(31 downto 1) & "1";
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
					elsif v_input.opcode(15 downto 10) = "000010" and unsigned(v_input.opcode(9 downto 8)) <= unsigned(MEMORY_SIZE_WORD) then
						-- load
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_ADD;  -- this works as 'none' by adding 0 to operand 1 (maybe I should just add a none op?)
						v_output.memory_operation := MEMORY_OPERATION_LOAD;
						v_output.memory_size := v_input.opcode(11 downto 10);
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(3 downto 0);
						v_output.read_indicator_2 := '1';
						v_output.read_register_2 := (others => '0');
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 10) = "000011" and unsigned(v_input.opcode(9 downto 8)) <= unsigned(MEMORY_SIZE_WORD) then
						-- store
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_ADD;  -- this works as 'none' by adding 0 to operand 1 (maybe I should just add a none op?)
						v_output.memory_operation := MEMORY_OPERATION_STORE;
						v_output.memory_size := v_input.opcode(11 downto 10);
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(3 downto 0);
						v_output.read_indicator_2 := '1';
						v_output.read_register_2 := v_input.opcode(7 downto 4);
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '0';
						v_output.writeback_register := (others => '0');
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 12) = "1000" and (v_input.opcode(11 downto 10) = "00" or v_input.opcode(11 downto 10) = "01" or v_input.opcode(11 downto 10) = "10") then
						-- shift with immediate
						v_output.valid := '1';
						v_output.flag_set_indicator := '1';
						if v_input.opcode(11 downto 10) = "00" then
							v_output.execute_operation := EXECUTE_OPERATION_SHL;
						elsif v_input.opcode(11 downto 10) = "01" then
							v_output.execute_operation := EXECUTE_OPERATION_SHR;
						else
							v_output.execute_operation := EXECUTE_OPERATION_SAR;
						end if;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_output.immediate := "000000000000000000000000000" & v_input.opcode(8) & v_input.opcode(3 downto 0);
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 8) = "00011011" then
						-- cmp
						v_output.valid := '1';
						v_output.flag_set_indicator := '1';
						v_output.execute_operation := EXECUTE_OPERATION_SUB;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '1';
						v_output.read_register_2 := v_input.opcode(3 downto 0);
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '0';
						v_output.writeback_indicator := '0';
						v_output.writeback_register := (others => '0');
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 8) = "00011100" then
						-- test
						v_output.valid := '1';
						v_output.flag_set_indicator := '1';
						v_output.execute_operation := EXECUTE_OPERATION_AND;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '1';
						v_output.read_register_2 := v_input.opcode(3 downto 0);
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '0';
						v_output.writeback_indicator := '0';
						v_output.writeback_register := (others => '0');
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 12) = "0001" and unsigned(v_input.opcode(11 downto 8)) < unsigned(EXECUTE_OPERATION_BYTE0) then
						-- binary operation
						v_output.valid := '1';
						v_output.flag_set_indicator := '1';
						v_output.execute_operation := v_input.opcode(11 downto 8);
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '1';
						v_output.read_register_2 := v_input.opcode(3 downto 0);
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '0';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 12) = "0010" then
						-- sign extend immediate
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_SECOND;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '0';
						v_output.read_register_1 := (others => '0');
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_sign := (others => v_input.opcode(11));
						v_output.immediate := v_sign & v_input.opcode(11 downto 8) & v_input.opcode(3 downto 0);
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 12) = "0011" then
						-- set unsigned immediate
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_SECOND;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '0';
						v_output.read_register_1 := (others => '0');
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_output.immediate := "000000000000000000000000" & v_input.opcode(11 downto 8) & v_input.opcode(3 downto 0);
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 14) = "01" then
						-- load immediate into byte N
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := "11" & v_input.opcode(13 downto 12);
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_output.immediate := "000000000000000000000000" & v_input.opcode(11 downto 8) & v_input.opcode(3 downto 0);
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 8) = "00000010" and v_input.opcode(3 downto 0) = "0000" then
						-- branch
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_ADD;  -- this works as 'none' by adding 0 to operand? 1 (maybe I should just add a none op?)
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '1';
						v_output.read_register_1 := v_input.opcode(7 downto 4);
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '0';
						v_output.writeback_indicator := '0';
						v_output.writeback_register := (others => '0');
						v_output.is_branch := '1';
						v_output.condition := COND_ALWAYS;
					elsif v_input.opcode(15 downto 12) = "1001" then
						-- conditional copy
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_SECOND;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '0';
						v_output.read_register_1 := (others => '0');
						v_output.read_indicator_2 := '1';
						v_output.read_register_2 := v_input.opcode(3 downto 0);
						v_output.immediate := (others => '0');
						v_output.switch_indicator := '0';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '1';
						v_output.condition := '1' & v_input.opcode(11 downto 8);
					elsif v_input.opcode(15 downto 12) = "1010" then
						-- conditional copy immediate
						v_output.valid := '1';
						v_output.flag_set_indicator := '0';
						v_output.execute_operation := EXECUTE_OPERATION_SECOND;
						v_output.memory_operation := MEMORY_OPERATION_NONE;
						v_output.read_indicator_1 := '0';
						v_output.read_register_1 := (others => '0');
						v_output.read_indicator_2 := '0';
						v_output.read_register_2 := (others => '0');
						v_sign := (others => v_input.opcode(3));
						v_output.immediate := v_sign(31 downto 4) & v_input.opcode(3 downto 0);
						v_output.switch_indicator := '1';
						v_output.writeback_indicator := '1';
						v_output.writeback_register := v_input.opcode(7 downto 4);
						v_output.is_branch := '0';
						v_output.condition := '1' & v_input.opcode(11 downto 8);
					else
						-- invalid opcode
						-- TODO: set interrupt or something?
						v_output := DEFAULT_DECODE_OUTPUT;
					end if;
				else
					v_output := DEFAULT_DECODE_OUTPUT;
				end if;
				
				if v_wait = '1' then
					v_output := DEFAULT_DECODE_OUTPUT;
				else
					buffered_input <= DEFAULT_FETCH_OUTPUT;
				end if;
				
				output <= v_output;
			end if;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				buffered_input <= v_input;
			end if;

			busy_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
