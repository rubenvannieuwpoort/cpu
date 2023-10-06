library ieee;
use ieee.std_logic_1164.all;


package core_types is
	type fetch_output_type is record
		valid: std_logic;
		opcode: std_logic_vector(31 downto 0);
		pc: std_logic_vector(31 downto 0);
		pc_next: std_logic_vector(31 downto 0);
		stamp: std_logic_vector(2 downto 0);
		tag: std_logic_vector(5 downto 0);
	end record fetch_output_type;  

	type decode_output_type is record
		valid: std_logic;
		illegal: std_logic;

		operand_1_type: std_logic;
		operand_1_immediate: std_logic_vector(31 downto 0);
		operand_1_register: std_logic_vector(4 downto 0);

		operand_2_type: std_logic;
		operand_2_immediate: std_logic_vector(31 downto 0);
		operand_2_3_register: std_logic_vector(4 downto 0);
		operand_3_type: std_logic;
		operand_3_immediate: std_logic_vector(31 downto 0);

		writeback_register: std_logic_vector(4 downto 0);
		csr_register: std_logic_vector(11 downto 0);

		alu_function: std_logic_vector(4 downto 0);

		pc: std_logic_vector(31 downto 0);
		stamp: std_logic_vector(2 downto 0);
		tag: std_logic_vector(5 downto 0);
	end record decode_output_type;

	type register_read_output_type is record
		valid: std_logic;

		operand_1: std_logic_vector(31 downto 0);
		operand_2: std_logic_vector(31 downto 0);
		operand_3: std_logic_vector(31 downto 0);
		
		operand_1_is_zero_register: std_logic;

		writeback_register: std_logic_vector(4 downto 0);
		csr_register: std_logic_vector(11 downto 0);

		alu_function: std_logic_vector(4 downto 0);

		pc: std_logic_vector(31 downto 0);
		stamp: std_logic_vector(2 downto 0);
		tag: std_logic_vector(5 downto 0);
	end record register_read_output_type;

	type execute_output_type is record
		valid: std_logic;
		act: std_logic;

		writeback_value: std_logic_vector(31 downto 0);
		writeback_register: std_logic_vector(4 downto 0);

		memory_operation: std_logic_vector(1 downto 0);
		memory_data: std_logic_vector(31 downto 0);
		memory_write_mask: std_logic_vector(3 downto 0);
		memory_address: std_logic_vector(31 downto 0);
		memory_size: std_logic_vector(1 downto 0);

		sign_extend: std_logic;

		tag: std_logic_vector(5 downto 0);
	end record execute_output_type;

	type memory_output_type is record
		act: std_logic;
		writeback_value: std_logic_vector(31 downto 0);
		writeback_register: std_logic_vector(4 downto 0);

		tag: std_logic_vector(5 downto 0);
	end record memory_output_type;
	
	type branch_data is record
		indicator: std_logic;
		address: std_logic_vector(31 downto 0);
	end record;

	type branch_signals is record
		data: branch_data;
		stamp: std_logic_vector(2 downto 0);
	end record;
end package core_types;
