library ieee;
use ieee.std_logic_1164.all;

use work.top_level_types.all;


package top_level_constants is
	-- this should become a CSR at some point
	constant SCREENBUFFER_ADDRESS: std_logic_vector(31 downto 0) := X"03000000";

	constant RAM_SIZE: std_logic_vector(31 downto 0) := X"04000000";

	constant MAIN_MEMORY_REGION_START: std_logic_vector(31 downto 0) := X"00000000";
	constant MAIN_MEMORY_REGION_END: std_logic_vector(31 downto 0) := X"04000000";

	constant SCREENBUFFER_REGION_START: std_logic_vector(31 downto 0) := X"03000000";
	constant SCREENBUFFER_REGION_END: std_logic_vector(31 downto 0) := X"04000000";

	constant BOOT_RAM_REGION_START: std_logic_vector(31 downto 0) := X"06000000";
	constant BOOT_RAM_REGION_END: std_logic_vector(31 downto 0) := X"06001000";

	constant FONT_RAM_REGION_START: std_logic_vector(31 downto 0) := X"06001000";
	constant FONT_RAM_REGION_END: std_logic_vector(31 downto 0) := X"06002000";

	constant TEXTBUFFER_RAM_REGION_START: std_logic_vector(31 downto 0) := X"06002000";
	constant TEXTBUFFER_RAM_REGION_END: std_logic_vector(31 downto 0) := X"06004000";

	constant COMMAND_READ: std_logic := '0';
	constant COMMAND_WRITE: std_logic := '1';

	constant DEFAULT_MEMORY_PORT: memory_port := (
		enable => '0',
		command => '0',
		address => (others => '0'),
		write_data => (others => '0'),
		write_mask => (others => '0')
	);

	constant DEFAULT_MEMORY_PORT_STATUS: memory_port_status := (
		read_data => (others => '0'),
		data_valid => '0',
		ready => '1',
		read_overflow => '0',
		read_error => '0',
		write_underrun => '0',
		write_error => '0'
	);

	constant DEFAULT_DRAM_PORT: dram_port := (
		command_enable => '0',
		command => (others => '0'),
		burst_length => (others => '0'),
		address => (others => '0'),
		write_enable => '0',
		write_mask => (others => '0'),
		write_data => (others => '0'),
		read_enable => '0'
	);
	
	constant DEFAULT_BRAM_PORT: bram_port := (
		address => (others => '0'),
		write_data => (others => '0'),
		write_mask => (others => '0')
	);
end package;
