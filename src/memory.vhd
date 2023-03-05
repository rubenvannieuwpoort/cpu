library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
	port(
		clk: in std_logic;

		valid_in: in std_logic;

		result_in: in std_logic_vector(31 downto 0);

		memory_operation_in: in std_logic;
		memory_value_in: in std_logic_vector(31 downto 0);

		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);

		writeback_indicator_out: out std_logic := '0';
		writeback_register_out: out std_logic_vector(3 downto 0) := "0000";
		writeback_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000"
	);
end memory;

architecture Behavioral of memory is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if valid_in = '1' then
				writeback_indicator_out <= writeback_indicator_in;
				writeback_register_out <= writeback_register_in;
				writeback_value_out <= result_in;
			else
				writeback_indicator_out <= '0';
				writeback_register_out <= "0000";
				writeback_value_out <= "00000000000000000000000000000000";
			end if;
		end if;
	end process;
end Behavioral;