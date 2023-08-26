library ieee;
use ieee.std_logic_1164.all;


package stages_interfaces is

	-- CSRs
	constant CSR_MISA: std_logic_vector(11 downto 0) := X"301";

	-- FETCH STAGE INTERFACE

	type fetch_output_type is record
		valid: std_logic;
		opcode: std_logic_vector(31 downto 0);
		pc: std_logic_vector(31 downto 0);
		pc_next: std_logic_vector(31 downto 0);
		stamp: std_logic_vector(2 downto 0);
		tag: std_logic_vector(4 downto 0);
	end record fetch_output_type;  

	constant DEFAULT_FETCH_OUTPUT: fetch_output_type := (
		valid => '0',
		opcode => (others => '0'),
		pc => (others => '0'),
		pc_next => (others => '0'),
		stamp => (others => '0'),
		tag => (others => '0')
	);


	-- DECODE STAGE

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
		tag: std_logic_vector(4 downto 0);
	end record decode_output_type;

	constant TYPE_REGISTER  : std_logic := '0';
	constant TYPE_IMMEDIATE : std_logic := '1';

	-- ALU_FUNCTION_ADD: writeback_value = op1 + op2
	-- ALU_FUNCTION_SUB: writeback_value = op1 - op2
	-- ALU_FUNCTION_SLT: writeback_value = 1 if s32(op1) < s32(op2) else 0
	-- ALU_FUNCTION_SLTU: writeback_value = 1 if u32(op1) < u32(op2) else 0
	-- ALU_FUNCTION_AND: writeback_value = op1 & op2
	-- ALU_FUNCTION_OR: writeback_value = op1 | op2
	-- ALU_FUNCTION_XOR: writeback_value = op1 ^ op2
	-- ALU_FUNCTION_SHIFT_LEFT: writeback_value = op1 << op2
	-- ALU_FUNCTION_SHIFT_RIGHT: writeback_value = op1 >> op2
	-- ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT: writeback_value = s32(op1) >> op2
	-- ALU_FUNCTION_JAL: writeback_value = op3, branch to op1 + op2
	-- ALU_FUNCTION_BXX: branch to op3 if op1 XX op2
	-- ALU_FUNCTION_CSRRW: writeback_value = <value of CSR>, <CSR> = op1
	-- ALU_FUNCTION_CSRRC: writeback_value = <value of CSR>, <CSR> = <CSR> | op1
	-- ALU_FUNCTION_CSRRS: writeback_value = <value of CSR>, <CSR> = <CSR> & !(op1)
	-- ALU_FUNCTION_STORE_BYTE: <store byte in op2 at op1 + op3>
	-- ALU_FUNCTION_STORE_HALFWORD: <store halfword in op2 at op1 + op3>
	-- ALU_FUNCTION_STORE_WORD: <store word in op2 at op1 + op3>
	-- ALU_FUNCTION_LOAD_BYTE: writeback_value = <byte at op1 + op3> (with sign extension)
	-- ALU_FUNCTION_LOAD_HALFWORD: writeback_value = <halfword at op1 + op3> (with sign extension)
	-- ALU_FUNCTION_LOAD_WORD: writeback_value = <word at op1 + op3> (with sign extension)
	-- ALU_FUNCTION_LOAD_BYTE_UNSIGNED: writeback_value = <byte at op1 + op3> (no sign extension)
	-- ALU_FUNCTION_LOAD_HALFWORD_UNSIGNED: writeback_value = <byte at op1 + op3> (no sign extension)

	
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
	constant ALU_FUNCTION_CSRRW                  : std_logic_vector(4 downto 0) := "10001";
	constant ALU_FUNCTION_CSRRC                  : std_logic_vector(4 downto 0) := "10010";
	constant ALU_FUNCTION_CSRRS                  : std_logic_vector(4 downto 0) := "10011";

	-- memory
	constant ALU_FUNCTION_STORE_BYTE             : std_logic_vector(4 downto 0) := "10100";
	constant ALU_FUNCTION_STORE_HALFWORD         : std_logic_vector(4 downto 0) := "10101";
	constant ALU_FUNCTION_STORE_WORD             : std_logic_vector(4 downto 0) := "10110";
	constant ALU_FUNCTION_LOAD_BYTE              : std_logic_vector(4 downto 0) := "11000";
	constant ALU_FUNCTION_LOAD_HALFWORD          : std_logic_vector(4 downto 0) := "11001";
	constant ALU_FUNCTION_LOAD_WORD              : std_logic_vector(4 downto 0) := "11010";
	constant ALU_FUNCTION_LOAD_BYTE_UNSIGNED     : std_logic_vector(4 downto 0) := "11100";
	constant ALU_FUNCTION_LOAD_HALFWORD_UNSIGNED : std_logic_vector(4 downto 0) := "11101";

	constant DEFAULT_DECODE_OUTPUT: decode_output_type := (
		valid => '0',
		illegal => '0',
		operand_1_type => '0',
		operand_1_register => (others => '0'),
		operand_1_immediate => (others => '0'),

		operand_2_type => '0',
		operand_2_immediate => (others => '0'),
		operand_2_3_register => (others => '0'),
		operand_3_type => '0',
		operand_3_immediate => (others => '0'),

		writeback_register => (others => '0'),
		csr_register => (others => '0'),

		alu_function => (others => '0'),
		pc => (others => '0'),
		stamp => (others => '0'),
		tag => (others => '0')
	);


	-- REGISTER READ STAGE

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
		tag: std_logic_vector(4 downto 0);
	end record register_read_output_type;

	constant DEFAULT_REGISTER_READ_OUTPUT: register_read_output_type := (
		valid => '0',

		operand_1 => (others => '0'),
		operand_2 => (others => '0'),
		operand_3 => (others => '0'),

		operand_1_is_zero_register => '0',

		writeback_register => (others => '0'),
		csr_register => (others => '0'),

		alu_function => (others => '0'),

		pc => (others => '0'),
		stamp => (others => '0'),
		tag => (others => '0')
	);


	-- EXECUTE STAGE

	type execute_output_type is record
		valid: std_logic;
		act: std_logic;

		writeback_value: std_logic_vector(31 downto 0);
		writeback_register: std_logic_vector(4 downto 0);

		memory_operation: std_logic_vector(1 downto 0);
		memory_data: std_logic_vector(31 downto 0);
		memory_write_mask: std_logic_vector(3 downto 0);
		memory_address: std_logic_vector(31 downto 0);

		tag: std_logic_vector(4 downto 0);
	end record execute_output_type;

	constant MEMORY_OPERATION_NOP   : std_logic_vector(1 downto 0) := "00";
	constant MEMORY_OPERATION_LOAD  : std_logic_vector(1 downto 0) := "01";
	constant MEMORY_OPERATION_STORE : std_logic_vector(1 downto 0) := "10";

	constant DEFAULT_EXECUTE_OUTPUT: execute_output_type := (
		valid => '0',
		act => '0',

		writeback_value => (others => '0'),
		writeback_register => (others => '0'),
		
		memory_operation => MEMORY_OPERATION_NOP,
		memory_data => (others => '0'),
		memory_write_mask => (others => '0'),
		memory_address => (others => '0'),

		tag => (others => '0')
	);


	-- MEMORY STAGE

	type memory_output_type is record
		act: std_logic;
		writeback_value: std_logic_vector(31 downto 0);
		writeback_register: std_logic_vector(4 downto 0);

		tag: std_logic_vector(4 downto 0);
	end record memory_output_type;

	constant DEFAULT_MEMORY_OUTPUT: memory_output_type := (
		act => '0',
		writeback_value => (others => '0'),
		writeback_register => (others => '0'),

		tag => (others => '0')
	);

end package stages_interfaces;
