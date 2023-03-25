library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity decode is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		data_in: in fetch_output_type;

		busy_out: out std_logic := '0';
		data_out: out decode_output_type := DEFAULT_DECODE_OUTPUT
	);
end decode;


architecture Behavioral of decode is
	signal buffered_input: fetch_output_type := DEFAULT_FETCH_OUTPUT;
begin

	process(clk)
		variable v_input: fetch_output_type;
		variable v_internal_hold: std_logic;
		variable v_data_out: decode_output_type;
		variable v_sign: std_logic_vector(23 downto 0);
	begin
		busy_out <= buffered_input.valid;

		if rising_edge(clk) then

			if hold_in = '0' then

				-- select input
				if buffered_input.valid = '1' then
					v_input := buffered_input;
				else
					v_input := data_in;
				end if;

				-- output generation
				v_internal_hold := '0';
				
				if v_input.valid = '1' then
					if v_input.opcode(15 downto 0) = "0000000000000000" then
						-- nop
						v_data_out := DEFAULT_DECODE_OUTPUT;
					elsif v_input.opcode(15 downto 8) = "00000001" then
						-- TODO: conditional branch
						v_data_out := DEFAULT_DECODE_OUTPUT;
					elsif v_input.opcode(15 downto 11) = "00001" then
						-- load/store
						if v_input.opcode(10) = '0' then
							-- TODO: load
							v_data_out := DEFAULT_DECODE_OUTPUT;
						else
							-- TODO: store
							v_data_out := DEFAULT_DECODE_OUTPUT;
						end if;
					elsif v_input.opcode(15 downto 12) = "0001" and unsigned(v_input.opcode(11 downto 8)) < unsigned(EXECUTE_OPERATION_NONE) then
						-- binary operation
						v_data_out.valid := '1';
						v_data_out.execute_operation := v_input.opcode(11 downto 8);
						v_data_out.memory_operation := MEMORY_OPERATION_NONE;
						v_data_out.read_indicator_1 := '1';
						v_data_out.read_register_1 := v_input.opcode(7 downto 4);
						v_data_out.read_indicator_2 := '1';
						v_data_out.read_register_2 := v_input.opcode(3 downto 0);
						v_data_out.immediate := (others => '0');
						v_data_out.switch_indicator := '0';
						v_data_out.writeback_indicator := '1';
						v_data_out.writeback_register := v_input.opcode(7 downto 4);
					elsif v_input.opcode(15 downto 12) = "0010" then
						-- sign extend immediate
						v_data_out.valid := '1';
						v_data_out.execute_operation := EXECUTE_OPERATION_SECOND;
						v_data_out.memory_operation := MEMORY_OPERATION_NONE;
						v_data_out.read_indicator_1 := '0';
						v_data_out.read_register_1 := (others => '0');
						v_data_out.read_indicator_2 := '0';
						v_data_out.read_register_2 := (others => '0');
						v_sign := (others => v_input.opcode(11));
						v_data_out.immediate := v_sign & v_input.opcode(11 downto 8) & v_input.opcode(3 downto 0);
						v_data_out.switch_indicator := '1';
						v_data_out.writeback_indicator := '1';
						v_data_out.writeback_register := v_input.opcode(7 downto 4);
					elsif v_input.opcode(15 downto 14) = "01" then
						-- load immediate into byte N
						v_data_out.valid := '1';
						v_data_out.execute_operation := "11" & v_input.opcode(13 downto 12);
						v_data_out.memory_operation := MEMORY_OPERATION_NONE;
						v_data_out.read_indicator_1 := '1';
						v_data_out.read_register_1 := v_input.opcode(7 downto 4);
						v_data_out.read_indicator_2 := '0';
						v_data_out.read_register_2 := (others => '0');
						v_data_out.immediate := "000000000000000000000000" & v_input.opcode(11 downto 8) & v_input.opcode(3 downto 0);
						v_data_out.switch_indicator := '1';
						v_data_out.writeback_indicator := '1';
						v_data_out.writeback_register := v_input.opcode(7 downto 4);
					else
						-- invalid opcode
						-- TODO: set interrupt or something?
						v_data_out := DEFAULT_DECODE_OUTPUT;
					end if;

				else
					v_data_out := DEFAULT_DECODE_OUTPUT;
				end if;
				
			else
				v_internal_hold := '1';
			end if;

			if v_internal_hold = '0' then
				data_out <= v_data_out;
				buffered_input <= DEFAULT_FETCH_OUTPUT;
			else
				data_out <= DEFAULT_DECODE_OUTPUT;

				if buffered_input.valid = '0' and data_in.valid = '1' then
					buffered_input <= data_in;
				end if;
			end if;

		end if;
	end process;

end Behavioral;
