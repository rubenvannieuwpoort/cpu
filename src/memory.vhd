library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
	port(
		clk: in std_logic;
		enable_in: in std_logic;

		result_in: in std_logic_vector(31 downto 0);

		memory_indicator_in: in std_logic;
		memory_operation_in: in std_logic; -- TODO: make this an enum type
		memory_address_in: in std_logic_vector(31 downto 0);

		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);

		flag_set_indicator_in: in std_logic;
		flags_in: in std_logic_vector(3 downto 0);


		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000";
		writeback_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		flag_set_indicator_out: out std_logic := '0';
		flags_out: out std_logic_vector(3 downto 0) := "0000";

		ready_out: out std_logic := '1'
	);
end memory;

architecture Behavioral of memory is
begin
	ready_out <= '1';

	process(clk)
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				writeback_indicator_out <= writeback_indicator_in;
				writeback_register_out <= writeback_register_in;
				writeback_value_out <= result_in;

				flag_set_indicator_out <= flag_set_indicator_in;
				flags_out <= flags_in;
			end if;
		end if;
	end process;
end Behavioral;