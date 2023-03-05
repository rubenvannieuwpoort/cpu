-- TODO
-- instantiate a fetch unit
-- instantiate a decode unit
-- instantiate an execute unit
-- instantiate a memory unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU is
	port(
		clk: in std_logic
	);
end CPU;

architecture Behavioral of CPU is
	-- signals from fetch
	signal fetch_valid: std_logic;
	signal opcode: std_logic_vector(15 downto 0);
	
	-- signals from decode
	signal decode_valid: std_logic;
	signal decode_operation: std_logic_vector(3 downto 0);
	signal r1_indicator, r2_indicator: std_logic;
	signal reg_1, reg_2: std_logic_vector(3 downto 0);
	signal decode_mem_op: std_logic;
	signal decode_mem_val: std_logic_vector(31 downto 0);
	signal decode_wb_ind: std_logic;
	signal decode_wb_reg: std_logic_vector(3 downto 0);

	-- signals from register read
	signal regread_valid: std_logic;
	signal op_1, op_2: std_logic_vector(31 downto 0);
	signal regread_op: std_logic_vector(3 downto 0);
	signal regread_mem_op: std_logic;
	signal regread_mem_val: std_logic_vector(31 downto 0);
	signal regread_wb_ind: std_logic;
	signal regread_wb_reg: std_logic_vector(3 downto 0);

	-- signals from execute
	signal exec_valid: std_logic;
	signal exec_result: std_logic_vector(31 downto 0);
	signal exec_mem_op: std_logic;
	signal exec_mem_val: std_logic_vector(31 downto 0);
	signal exec_wb_ind: std_logic;
	signal exec_wb_reg: std_logic_vector(3 downto 0);

	-- signals from memory
	signal mem_wb_ind: std_logic;
	signal mem_wb_reg: std_logic_vector(3 downto 0);
	signal mem_wb_val: std_logic_vector(31 downto 0);

	component instruction_fetch is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			valid_out: out std_logic;
			opcode_out: out std_logic_vector(15 downto 0)
		);
	end component;

	component instruction_decode is
		port(
			clk: in std_logic;
			valid_in: in std_logic;
			hold_in: in std_logic;
			opcode_in: in std_logic_vector(15 downto 0);
			valid_out: out std_logic;
			operation_out: out std_logic_vector(3 downto 0) := "0000";
			read_indicator_1_out: out std_logic;
			reg_1_out: out std_logic_vector(3 downto 0) := "0000";
			read_indicator_2_out: out std_logic;
			reg_2_out: out std_logic_vector(3 downto 0) := "0000";
			memory_operation_out: out std_logic := '0';
			memory_value_out: out std_logic_vector(31 downto 0);
			writeback_indicator_out: out std_logic := '0';
			writeback_register_out: out std_logic_vector(3 downto 0)
		);
	end component;

	component register_read_write is
		port(
			clk: in std_logic;
			valid_in: in std_logic;
			read_indicator_1_in: in std_logic;
			reg_1_in: in std_logic_vector(3 downto 0);
			read_indicator_2_in: in std_logic;
			reg_2_in: in std_logic_vector(3 downto 0);
			valid_out: out std_logic := '0';
			op_1_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
			op_2_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
			operation_in: std_logic_vector(3 downto 0);
			memory_operation_in: in std_logic;
			memory_value_in: in std_logic_vector(31 downto 0);
			writeback_indicator_passthrough_in: in std_logic;
			writeback_register_passthrough_in: in std_logic_vector(3 downto 0);
			operation_out: out std_logic_vector(3 downto 0) := "0000";
			memory_operation_out: out std_logic := '0';
			memory_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
			writeback_indicator_out: out std_logic;
			writeback_register_out: out std_logic_vector(3 downto 0);
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
			writeback_value_in: in std_logic_vector(31 downto 0)
		);
	end component;

	component instruction_execute is
		port(
			clk: in std_logic;
			valid_in: in std_logic;
			operation_in: in std_logic_vector(3 downto 0);
			operand_1_in: in std_logic_vector(31 downto 0);
			operand_2_in: in std_logic_vector(31 downto 0);
			memory_operation_in: in std_logic;
			memory_value_in: in std_logic_vector(31 downto 0);
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
			valid_out: out std_logic;
			result_out: out std_logic_vector(31 downto 0);
			memory_operation_out: out std_logic := '0';
			memory_value_out: out std_logic_vector(31 downto 0);
			writeback_indicator_out: out std_logic := '0';
			writeback_register_out: out std_logic_vector(3 downto 0)
		);
	end component;

	component memory is
		port(
			clk: in std_logic;
			valid_in: in std_logic;
			result_in: in std_logic_vector(31 downto 0);
			memory_operation_in: in std_logic;
			memory_value_in: in std_logic_vector(31 downto 0);
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
			writeback_indicator_out: out std_logic := '0';
			writeback_register_out: out std_logic_vector(3 downto 0);
			writeback_value_out: out std_logic_vector(31 downto 0)
		);
	end component;

begin
	-- todo: fix hold_in
	instr_fetch: instruction_fetch port map(clk => clk, hold_in => '0', opcode_out => opcode, valid_out => fetch_valid);

	instr_decode: instruction_decode port map(clk => clk, valid_in => fetch_valid, hold_in => '0', -- todo: fix hold_in
	                                          opcode_in => opcode,
															valid_out => decode_valid,
															operation_out => decode_operation,
															read_indicator_1_out => r1_indicator, reg_1_out => reg_1,
															read_indicator_2_out => r2_indicator, reg_2_out => reg_2,
	                                          memory_operation_out => decode_mem_op, memory_value_out => decode_mem_val,
	                                          writeback_indicator_out => decode_wb_ind, writeback_register_out => decode_wb_reg);

	reg_rw: register_read_write port map(clk => clk, valid_in => decode_valid,
	                                     read_indicator_1_in => r1_indicator, reg_1_in => reg_1,
	                                     read_indicator_2_in => r2_indicator, reg_2_in => reg_2,
													 valid_out => regread_valid, op_1_out => op_1, op_2_out => op_2,
													 operation_in => decode_operation,
													 memory_operation_in => decode_mem_op, memory_value_in => decode_mem_val,
													 writeback_indicator_passthrough_in => '0', writeback_register_passthrough_in => "0000",
													 operation_out => regread_op, memory_operation_out => regread_mem_op, memory_value_out => regread_mem_val,
													 writeback_indicator_out => regread_wb_ind, writeback_register_out => regread_wb_reg,
													 writeback_indicator_in => '0', writeback_register_in => "0000", writeback_value_in => "00000000000000000000000000000000");
													 

	instr_execute: instruction_execute port map(clk => clk, valid_in => regread_valid,
	                                            operation_in => regread_op, operand_1_in => op_1, operand_2_in => op_2,
	                                            memory_operation_in => regread_mem_op, memory_value_in => regread_mem_val,
	                                            writeback_indicator_in => regread_wb_ind, writeback_register_in => regread_wb_reg,
	                                            result_out => exec_result,
	                                            memory_operation_out => exec_mem_op, memory_value_out => exec_mem_val,
	                                            writeback_indicator_out => exec_wb_ind, writeback_register_out => exec_wb_reg,
	                                            valid_out => exec_valid);

	mem: memory port map(clk => clk, valid_in => exec_valid,
	                    result_in => exec_result,
	                    memory_operation_in => exec_mem_op, memory_value_in => exec_mem_val,
	                    writeback_indicator_in => exec_wb_ind, writeback_register_in => exec_wb_reg,
	                    writeback_indicator_out => mem_wb_ind, writeback_register_out => mem_wb_reg, writeback_value_out => mem_wb_val);
end Behavioral;