library ieee;
use ieee.std_logic_1164.all;


package stages_interfaces is

	-- FETCH STAGE INTERFACE

	type fetch_output_type is record
		valid: std_logic;
		opcode : std_logic_vector(15 downto 0);
	end record fetch_output_type;  

	constant DEFAULT_FETCH_OUTPUT : fetch_output_type := (
		valid => '0',
		opcode => (others => '0')
	);


	-- DECODE STAGE

	type decode_output_type is record
		valid: std_logic;

		flag_set_indicator: std_logic;
		execute_operation: std_logic_vector(3 downto 0);
		memory_operation: std_logic_vector(1 downto 0);

		read_indicator_1: std_logic;
		read_register_1: std_logic_vector(3 downto 0);

		read_indicator_2: std_logic;
		read_register_2: std_logic_vector(3 downto 0);

		immediate: std_logic_vector(31 downto 0);
		switch_indicator: std_logic;

		writeback_indicator: std_logic;
		writeback_register: std_logic_vector(3 downto 0);
		is_branch: std_logic;
	end record decode_output_type;

	constant MEMORY_OPERATION_NONE     : std_logic_vector(1 downto 0) := "00";
	constant MEMORY_OPERATION_LOAD     : std_logic_vector(1 downto 0) := "01";
	constant MEMORY_OPERATION_STORE    : std_logic_vector(1 downto 0) := "10";

	constant EXECUTE_OPERATION_SECOND : std_logic_vector(3 downto 0) := "0000";
	constant EXECUTE_OPERATION_ADD    : std_logic_vector(3 downto 0) := "0001";
	constant EXECUTE_OPERATION_SUB    : std_logic_vector(3 downto 0) := "0010";
	constant EXECUTE_OPERATION_MUL    : std_logic_vector(3 downto 0) := "0011";
	constant EXECUTE_OPERATION_AND    : std_logic_vector(3 downto 0) := "0100";
	constant EXECUTE_OPERATION_OR     : std_logic_vector(3 downto 0) := "0101";
	constant EXECUTE_OPERATION_XOR    : std_logic_vector(3 downto 0) := "0110";
	constant EXECUTE_OPERATION_NOT    : std_logic_vector(3 downto 0) := "0111";
	constant EXECUTE_OPERATION_BYTE0  : std_logic_vector(3 downto 0) := "1100";
	constant EXECUTE_OPERATION_BYTE1  : std_logic_vector(3 downto 0) := "1101";
	constant EXECUTE_OPERATION_BYTE2  : std_logic_vector(3 downto 0) := "1110";
	constant EXECUTE_OPERATION_BYTE3  : std_logic_vector(3 downto 0) := "1111";

	constant DEFAULT_DECODE_OUTPUT : decode_output_type := (
		valid => '0',
		flag_set_indicator => '0',
		execute_operation => EXECUTE_OPERATION_SECOND,
		memory_operation => MEMORY_OPERATION_NONE,
		read_indicator_1 => '0',
		read_register_1 => (others => '0'),
		read_indicator_2 => '0',
		read_register_2 => (others => '0'),
		immediate => (others => '0'),
		switch_indicator => '0',
		writeback_indicator => '0',
		writeback_register => (others => '0'),
		is_branch => '0'
	);


	-- REGISTER READ STAGE

	type register_read_output_type is record
		valid: std_logic;

		flag_set_indicator: std_logic;
		execute_operation: std_logic_vector(3 downto 0);
		memory_operation: std_logic_vector(1 downto 0);
	
		operand_1: std_logic_vector(31 downto 0);
		operand_2: std_logic_vector(31 downto 0);
		value: std_logic_vector(31 downto 0);

		writeback_indicator: std_logic;
		writeback_register: std_logic_vector(3 downto 0);
		is_branch: std_logic;
	end record register_read_output_type;

	constant DEFAULT_REGISTER_READ_OUTPUT : register_read_output_type := (
		valid => '0',
		flag_set_indicator => '0',
		execute_operation => EXECUTE_OPERATION_SECOND,
		memory_operation => MEMORY_OPERATION_NONE,
		operand_1 => (others => '0'),
		operand_2 => (others => '0'),
		value => (others => '0'),
		writeback_indicator => '0',
		writeback_register => (others => '0'),
		is_branch => '0'
	);


	-- EXECUTE STAGE

	type execute_output_type is record
		valid: std_logic;

		memory_operation: std_logic_vector(1 downto 0);
	
		result: std_logic_vector(31 downto 0);
		value: std_logic_vector(31 downto 0);

		writeback_indicator: std_logic;
		writeback_register: std_logic_vector(3 downto 0);
	end record execute_output_type;

	constant DEFAULT_EXECUTE_OUTPUT : execute_output_type := (
		valid => '0',
		memory_operation => MEMORY_OPERATION_NONE,
		result => (others => '0'),
		value => (others => '0'),
		writeback_indicator => '0',
		writeback_register => (others => '0')
	);


	-- MEMORY STAGE

	type memory_output_type is record
		writeback_indicator: std_logic;
		writeback_register: std_logic_vector(3 downto 0);
		writeback_value: std_logic_vector(31 downto 0);
	end record memory_output_type;

	constant DEFAULT_MEMORY_OUTPUT : memory_output_type := (
		writeback_indicator => '0',
		writeback_register => (others => '0'),
		writeback_value => (others => '0')
	);

end package stages_interfaces;
