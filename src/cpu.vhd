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
	signal opcode: std_logic_vector(15 downto 0);
	signal fetch_enable, decode_ready: std_logic;
	signal enable: std_logic;

	signal writeback_indicator: std_logic;
	signal writeback_register: std_logic_vector(3 downto 0);
	signal writeback_value: std_logic_vector(31 downto 0);

	-- signals between fetch and decode
	signal valid_fetch_to_decode: std_logic;

	-- signals between decode and execute
	signal operation_decode_to_exec: std_logic_vector(3 downto 0);
	signal op1_decode_to_exec: std_logic_vector(31 downto 0);
	signal op2_decode_to_exec: std_logic_vector(31 downto 0);
	signal memory_indicator_decode_to_exec: std_logic;
	signal memory_op_decode_to_exec: std_logic;
	signal memory_val_decode_to_exec: std_logic_vector(31 downto 0);
	signal writeback_indicator_decode_to_exec: std_logic;
	signal writeback_register_decode_to_exec: std_logic_vector(3 downto 0);
	signal valid_decode_to_exec: std_logic;

	-- signals between execute and memory
	signal result_exec_to_mem: std_logic_vector(31 downto 0);
	signal mem_indicator_exec_to_mem: std_logic;
	signal mem_op_exec_to_mem: std_logic;
	signal mem_val_exec_to_mem: std_logic_vector(31 downto 0);
	signal wb_indicator_exec_to_mem: std_logic;
	signal wb_reg_exec_to_mem: std_logic_vector(3 downto 0);
	signal valid_exec_to_mem: std_logic;

	component instruction_fetch is
		port(
			clk: in std_logic;
			enable_in: in std_logic;
			valid_out: out std_logic := '0';
			opcode_out: out std_logic_vector(15 downto 0)
		);
	end component;

	component instruction_decode is
		port(
			clk: in std_logic;
			valid_in: in std_logic;
			opcode_in: in std_logic_vector(15 downto 0);
			valid_out: out std_logic;
			operation_out: out std_logic_vector(3 downto 0);
			operand_1_out: out std_logic_vector(31 downto 0);
			operand_2_out: out std_logic_vector(31 downto 0);
			memory_indicator_out: out std_logic := '0';
			memory_operation_out: out std_logic := '0';
			memory_value_out: out std_logic_vector(31 downto 0);
			writeback_indicator_out: out std_logic := '0';
			writeback_register_out: out std_logic_vector(3 downto 0);
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
			writeback_value_in: in std_logic_vector(31 downto 0);
			ready_out: out std_logic
		);
	end component;

	component instruction_execute is
		port(
			clk: in std_logic;
			valid_in: in std_logic;
			operation_in: in std_logic_vector(3 downto 0);
			operand_1_in: in std_logic_vector(31 downto 0);
			operand_2_in: in std_logic_vector(31 downto 0);
			memory_indicator_in: in std_logic;
			memory_operation_in: in std_logic;
			memory_value_in: in std_logic_vector(31 downto 0);
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
			valid_out: out std_logic;
			result_out: out std_logic_vector(31 downto 0);
			memory_indicator_out: out std_logic := '0';
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
			memory_indicator_in: in std_logic;
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
	fetch_enable <= decode_ready;

	instr_fetch: instruction_fetch port map(clk => clk, enable_in => fetch_enable, opcode_out => opcode, valid_out => valid_fetch_to_decode);

	instr_decode: instruction_decode port map(clk => clk, valid_in => valid_fetch_to_decode,
	                                          opcode_in => opcode,
	                                          writeback_indicator_in => writeback_indicator, writeback_register_in => writeback_register, writeback_value_in => writeback_value,
	                                          operation_out => operation_decode_to_exec, operand_1_out => op1_decode_to_exec, operand_2_out => op2_decode_to_exec,
	                                          memory_indicator_out => memory_indicator_decode_to_exec, memory_operation_out => memory_op_decode_to_exec, memory_value_out => memory_val_decode_to_exec,
	                                          writeback_indicator_out => writeback_indicator_decode_to_exec, writeback_register_out => writeback_register_decode_to_exec,
	                                          valid_out => valid_decode_to_exec, ready_out => decode_ready);

	instr_execute: instruction_execute port map(clk => clk, valid_in => valid_decode_to_exec,
	                                            operation_in => operation_decode_to_exec, operand_1_in => op1_decode_to_exec, operand_2_in => op2_decode_to_exec,
	                                            memory_indicator_in => memory_indicator_decode_to_exec, memory_operation_in => memory_op_decode_to_exec, memory_value_in => memory_val_decode_to_exec,
	                                            writeback_indicator_in => writeback_indicator_decode_to_exec, writeback_register_in => writeback_register_decode_to_exec,
	                                            result_out => result_exec_to_mem,
	                                            memory_indicator_out => mem_indicator_exec_to_mem, memory_operation_out => mem_op_exec_to_mem, memory_value_out => mem_val_exec_to_mem,
	                                            writeback_indicator_out => wb_indicator_exec_to_mem, writeback_register_out => wb_reg_exec_to_mem,
	                                            valid_out => valid_exec_to_mem);

	mem: memory port map(clk => clk, valid_in => valid_exec_to_mem,
	                    result_in => result_exec_to_mem,
	                    memory_indicator_in => memory_indicator_decode_to_exec, memory_operation_in => memory_op_decode_to_exec, memory_value_in => mem_val_exec_to_mem,
	                    writeback_indicator_in => wb_indicator_exec_to_mem, writeback_register_in => wb_reg_exec_to_mem,
	                    writeback_indicator_out => writeback_indicator, writeback_register_out => writeback_register, writeback_value_out => writeback_value);
end Behavioral;