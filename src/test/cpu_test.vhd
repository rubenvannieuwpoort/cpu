LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY cpu_test IS
END cpu_test;
 
ARCHITECTURE behavior OF cpu_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPU
    PORT(
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_100MHz : std_logic := '0';

   -- Clock period definitions
   constant clk_100MHz_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CPU PORT MAP (
          clk => clk_100MHz
        );

   -- Clock process definitions
   clk_100MHz_process :process
   begin
		clk_100MHz <= '0';
		wait for clk_100MHz_period/2;
		clk_100MHz <= '1';
		wait for clk_100MHz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_100MHz_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
