library ieee;
use ieee.std_logic_1164.all;


package stages_interfaces is

	-- CSRs
	constant CSR_MISA: std_logic_vector(11 downto 0) := X"301";

	-- FETCH STAGE INTERFACE

	type fetch_output_type is record
		valid: std_logic;
		pc: std_logic_vector(31 downto 0);
		pc_next: std_logic_vector(31 downto 0);
		opcode: std_logic_vector(31 downto 0);
		tag: std_logic_vector(4 downto 0);
	end record fetch_output_type;  

	constant DEFAULT_FETCH_OUTPUT: fetch_output_type := (
		valid => '0',
		pc => (others => '0'),
		pc_next => (others => '0'),
		opcode => (others => '0'),
		tag => (others => '0')
	);


	-- DECODE STAGE

	type decode_output_type is record
		valid: std_logic;

		operand_1_type: std_logic;
		operand_1_immediate: std_logic_vector(31 downto 0);
		operand_1_register: std_logic_vector(4 downto 0);

		operand_2_type: std_logic;
		operand_2_immediate: std_logic_vector(31 downto 0);
		operand_2_3_register: std_logic_vector(4 downto 0);
		operand_3_type: std_logic;
		operand_3_immediate: std_logic_vector(31 downto 0);

		branch_to_be_handled: std_logic;
		writeback_register: std_logic_vector(4 downto 0);
		csr_register: std_logic_vector(11 downto 0);

		alu_function: std_logic_vector(4 downto 0);
		-- mem_function: std_logic_vector(4 downto 0);
		-- memory_operation: std_logic_vector(1 downto 0);
		-- memory_size: std_logic_vector(1 downto 0);

		tag: std_logic_vector(4 downto 0);
	end record decode_output_type;

	constant TYPE_REGISTER  : std_logic := '0';
	constant TYPE_IMMEDIATE : std_logic := '1';

	--constant MEMORY_OPERATION_LOAD_BYTE     : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_OPERATION_LOAD_BYTE     : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_OPERATION_LOAD_HALFWORD : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_OPERATION_LOAD_HALFWORD : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_OPERATION_LOAD_WORD     : std_logic_vector(1 downto 0) := "00";
	
	--constant MEMORY_OPERATION_STORE_BYTE     : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_OPERATION_STORE_HALFWORD : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_OPERATION_STORE_WORD     : std_logic_vector(1 downto 0) := "00";

	--constant MEMORY_OPERATION_LOAD : std_logic_vector(1 downto 0) := "01";
	--constant MEMORY_OPERATION_STORE: std_logic_vector(1 downto 0) := "10";

	--constant MEMORY_SIZE_BYTE     : std_logic_vector(1 downto 0) := "00";
	--constant MEMORY_SIZE_HALFWORD : std_logic_vector(1 downto 0) := "01";
	--constant MEMORY_SIZE_WORD     : std_logic_vector(1 downto 0) := "10";

	
	-- arithmetic
	constant ALU_FUNCTION_ADD                    : std_logic_vector(4 downto 0) := "00000";
	constant ALU_FUNCTION_SUB                    : std_logic_vector(4 downto 0) := "00001";
	constant ALU_FUNCTION_SLT                    : std_logic_vector(4 downto 0) := "00010";
	constant ALU_FUNCTION_SLTU                   : std_logic_vector(4 downto 0) := "00011";
	-- bitwise
	constant ALU_FUNCTION_AND                    : std_logic_vector(4 downto 0) := "00100";
	constant ALU_FUNCTION_OR                     : std_logic_vector(4 downto 0) := "00101";
	constant ALU_FUNCTION_XOR                    : std_logic_vector(4 downto 0) := "00110";
	constant ALU_FUNCTION_SHIFT_LEFT             : std_logic_vector(4 downto 0) := "00111";
	constant ALU_FUNCTION_SHIFT_RIGHT            : std_logic_vector(4 downto 0) := "01000";
	constant ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT : std_logic_vector(4 downto 0) := "01001";

	-- branches
	constant ALU_FUNCTION_JAL                    : std_logic_vector(4 downto 0) := "01010";
	constant ALU_FUNCTION_BEQ                    : std_logic_vector(4 downto 0) := "01011";
	constant ALU_FUNCTION_BNE                    : std_logic_vector(4 downto 0) := "01100";
	constant ALU_FUNCTION_BLT                    : std_logic_vector(4 downto 0) := "01101";
	constant ALU_FUNCTION_BLTU                   : std_logic_vector(4 downto 0) := "01110";
	constant ALU_FUNCTION_BGE                    : std_logic_vector(4 downto 0) := "01111";
	constant ALU_FUNCTION_BGEU                   : std_logic_vector(4 downto 0) := "10000";

	-- CSRs
	constant ALU_FUNCTION_CSRRW                    : std_logic_vector(4 downto 0) := "10001";
	constant ALU_FUNCTION_CSRRC                    : std_logic_vector(4 downto 0) := "10010";
	constant ALU_FUNCTION_CSRRS                    : std_logic_vector(4 downto 0) := "10011";

	constant DEFAULT_DECODE_OUTPUT: decode_output_type := (
		valid => '0',
		operand_1_type => '0',
		operand_1_register => (others => '0'),
		operand_1_immediate => (others => '0'),

		operand_2_type => '0',
		operand_2_immediate => (others => '0'),
		operand_2_3_register => (others => '0'),
		operand_3_type => '0',
		operand_3_immediate => (others => '0'),

		branch_to_be_handled => '0',
		writeback_register => (others => '0'),
		csr_register => (others => '0'),

		alu_function => (others => '0'),
		tag => (others => '0')
	);


	-- REGISTER READ STAGE

	type register_read_output_type is record
		valid: std_logic;

		operand_1: std_logic_vector(31 downto 0);
		operand_2: std_logic_vector(31 downto 0);
		operand_3: std_logic_vector(31 downto 0);

		branch_to_be_handled: std_logic;
		writeback_register: std_logic_vector(4 downto 0);
		csr_register: std_logic_vector(11 downto 0);

		alu_function: std_logic_vector(4 downto 0);
		-- mem_function: std_logic_vector(4 downto 0);
		-- memory_operation: std_logic_vector(1 downto 0);
		-- memory_size: std_logic_vector(1 downto 0);

		tag: std_logic_vector(4 downto 0);
	end record register_read_output_type;

	constant DEFAULT_REGISTER_READ_OUTPUT: register_read_output_type := (
		valid => '0',

		operand_1 => (others => '0'),
		operand_2 => (others => '0'),
		operand_3 => (others => '0'),

		branch_to_be_handled => '0',
		writeback_register => (others => '0'),
		csr_register => (others => '0'),

		alu_function => (others => '0'),

		tag => (others => '0')
	);


	-- EXECUTE STAGE

	type execute_output_type is record
		valid: std_logic;

		writeback_value: std_logic_vector(31 downto 0);
		writeback_register: std_logic_vector(4 downto 0);

		tag: std_logic_vector(4 downto 0);
	end record execute_output_type;

	constant DEFAULT_EXECUTE_OUTPUT: execute_output_type := (
		valid => '0',

		writeback_value => (others => '0'),
		writeback_register => (others => '0'),

		tag => (others => '0')
	);


	-- MEMORY STAGE

	type memory_output_type is record
		writeback_value: std_logic_vector(31 downto 0);
		writeback_register: std_logic_vector(4 downto 0);

		tag: std_logic_vector(4 downto 0);
	end record memory_output_type;

	constant DEFAULT_MEMORY_OUTPUT: memory_output_type := (
		writeback_value => (others => '0'),
		writeback_register => (others => '0'),

		tag => (others => '0')
	);

end package stages_interfaces;
