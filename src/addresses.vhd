library ieee;
use ieee.std_logic_1164.all;


package addresses is
    constant UNCACHED_REGION_START: std_logic_vector(31 downto 0) := X"03C00000";

    -- this should become a CSR at some point
    constant SCREENBUFFER_ADDRESS: std_logic_vector(31 downto 0) := X"03C00000";

    constant RAM_SIZE: std_logic_vector(31 downto 0) := X"04000000";
end package;
