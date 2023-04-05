LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ram_block_test IS
END ram_block_test;
 
ARCHITECTURE behavior OF ram_block_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram_block
    PORT(
         clk : IN  std_logic;
         write_enable_in : IN  std_logic_vector(3 downto 0);
         data_in : IN  std_logic_vector(31 downto 0);
         address_in : IN  std_logic_vector(8 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal write_enable_in : std_logic_vector(3 downto 0) := (others => '0');
   signal data_in : std_logic_vector(31 downto 0) := (others => '0');
   signal address_in : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
begin
	uut: ram_block port map (
		clk => clk,
		write_enable_in => write_enable_in,
		data_in => data_in,
		address_in => address_in,
		data_out => data_out
	);

	clk_process: process
	begin
		clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
		wait for clk_period / 2;
	end process;
 
	stim_proc: process
	begin
		wait for 10001 ps;

		write_enable_in <= "1111";
		data_in <= "00000000000000000000000000000001";
		address_in <= "000000001";
		wait for clk_period;

		data_in <= "00000000000000000000000000000010";
		address_in <= "000000010";
		wait for clk_period;



		write_enable_in <= "0000";
		address_in <= "000000000";
		wait for clk_period;

		write_enable_in <= "0000";
		address_in <= "000000001";
		wait for clk_period;

		address_in <= "000000010";
		wait for clk_period;

		address_in <= "000000011";
		wait;
	end process;

end;
