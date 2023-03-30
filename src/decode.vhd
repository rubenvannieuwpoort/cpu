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
		variable v_sign: std_logic_vector(23 downto 0);
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
					if v_input.opcode(15 downto 0) = "0000000000000000" then
						-- nop
						v_output := DEFAULT_DECODE_OUTPUT;
					elsif v_input.opcode(15 downto 8) = "00000001" then
						-- TODO: conditional branch
						v_output := DEFAULT_DECODE_OUTPUT;
					elsif v_input.opcode(15 downto 11) = "00001" then
						-- load/store
						if v_input.opcode(10) = '0' then
							-- TODO: load
							v_output := DEFAULT_DECODE_OUTPUT;
						else
							-- TODO: store
							v_output := DEFAULT_DECODE_OUTPUT;
						end if;
					elsif v_input.opcode(15 downto 8) = "00011000" then
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
					elsif v_input.opcode(15 downto 8) = "00011001" then
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
					elsif v_input.opcode(15 downto 12) = "0001" and unsigned(v_input.opcode(11 downto 8)) <= unsigned(EXECUTE_OPERATION_NOT) then
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
