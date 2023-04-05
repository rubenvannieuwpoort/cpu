library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity memory is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in execute_output_type;

		busy_out: out std_logic := '0';
		output: out memory_output_type := DEFAULT_MEMORY_OUTPUT
	);
end memory;


architecture Behavioral of memory is
	signal buffered_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal last_input: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal ram_data_out: std_logic_vector(31 downto 0) := (others => '0');
	
	component ram_block is
		port(
			clk: in std_logic;

			write_enable_in: in std_logic_vector(3 downto 0);
			data_in: in std_logic_vector(31 downto 0);
			address_in: in std_logic_vector(8 downto 0);

			data_out: out  std_logic_vector(31 downto 0)
		);
	end component;
	
begin
	output.writeback_value <= last_input.result when last_input.memory_operation = MEMORY_OPERATION_NONE else ram_data_out;
	-- output.writeback_value <= (others => '0') when input.memory_operation = MEMORY_OPERATION_NONE else (others => '0');

	internal_ram: ram_block port map (
		clk => clk,
		write_enable_in => input.write_enable,
		data_in => input.value,
		address_in => input.result(8 downto 0),
		data_out => ram_data_out
	);

	process(clk)
		variable v_wait: std_logic;
		variable v_input: execute_output_type;
		variable v_output: memory_output_type;
	begin
		if rising_edge(clk) then
			last_input <= input;
		
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			v_wait := '0';
			if hold_in = '0' then
				-- generate output
				v_output.writeback_indicator := v_input.writeback_indicator;
				v_output.writeback_register := v_input.writeback_register;
				-- v_output.writeback_value := v_input.result;
				v_output.act := v_input.act;
				v_output.tag := v_input.tag;

				if v_wait = '1' then
					v_output := DEFAULT_MEMORY_OUTPUT;
				else
					buffered_input <= DEFAULT_EXECUTE_OUTPUT;
				end if;

				-- equivalent to output <= v_output; EXCEPT for the writeback value
				output.writeback_indicator <= v_output.writeback_indicator;
				output.writeback_register <= v_output.writeback_register;
				-- output.writeback_value <= v_output.result;
				output.act <= v_output.act;
				output.tag <= v_output.tag;
			end if;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				buffered_input <= v_input;
			end if;

			busy_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
