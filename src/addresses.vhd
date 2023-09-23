library ieee;
use ieee.std_logic_1164.all;


package addresses is
    -- this should become a CSR at some point
    constant SCREENBUFFER_ADDRESS: std_logic_vector(31 downto 0) := X"03000000";

    constant RAM_SIZE: std_logic_vector(31 downto 0) := X"04000000";
end package;
