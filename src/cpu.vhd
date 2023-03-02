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
		clk_100MHz: in std_logic
	);
end CPU;

architecture Behavioral of CPU is
	signal clk: std_logic;

	signal opcode: std_logic_vector(15 downto 0);
	signal fetch_ready, decode_ready, execute_ready, memory_ready: std_logic;
	signal enable: std_logic;

	signal writeback_indicator: std_logic;
	signal writeback_register: std_logic_vector(3 downto 0);
	signal writeback_value: std_logic_vector(31 downto 0);
	signal flag_set_indicator: std_logic;
	signal flags: std_logic_vector(3 downto 0);

	-- signals between decode and execute
	signal operation_decode_to_exec: std_logic_vector(3 downto 0);
	signal op1_decode_to_exec: std_logic_vector(31 downto 0);
	signal op2_decode_to_exec: std_logic_vector(31 downto 0);
	signal memory_indicator_decode_to_exec: std_logic;
	signal memory_op_decode_to_exec: std_logic;
	signal memory_address_decode_to_exec: std_logic_vector(31 downto 0);
	signal writeback_indicator_decode_to_exec: std_logic;
	signal writeback_register_decode_to_exec: std_logic_vector(3 downto 0);
	signal flag_set_indicator_decode_to_exec: std_logic;

	-- signals between execute and memory
	signal result_exec_to_mem: std_logic_vector(31 downto 0);
	signal mem_indicator_exec_to_mem: std_logic;
	signal mem_op_exec_to_mem: std_logic;
	signal mem_addr_exec_to_mem: std_logic_vector(31 downto 0);
	signal wb_indicator_exec_to_mem: std_logic;
	signal wb_reg_exec_to_mem: std_logic_vector(3 downto 0);
	signal flag_set_indicator_exec_to_mem: std_logic;
	signal flags_exec_to_mem: std_logic_vector(3 downto 0);

	component clock_divider
		generic(power: integer := 0); -- set power = 26 for 0.75Hz
		port(clk_in: in std_logic; clk_out: out std_logic);
	end component;

	component instruction_fetch
		port(
			clk: in std_logic;
			enable_in: in std_logic;
			opcode_out: out std_logic_vector(15 downto 0);
			ready_out: out std_logic := '0'
		);
	end component;

	component instruction_decode is
		port(
			clk: in std_logic;
		
			enable_in: in std_logic;
			opcode_in: in std_logic_vector(15 downto 0);
	
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
			writeback_value_in: in std_logic_vector(31 downto 0);

			flag_set_indicator_in: in std_logic;
			flags_in: in std_logic_vector(3 downto 0);

			operation_out: out std_logic_vector(3 downto 0); -- TODO: make this an enum type (0: add, 1: sub, 2: mul, 3: and, 4: or, 5: xor)
			operand_1_out: out std_logic_vector(31 downto 0);
			operand_2_out: out std_logic_vector(31 downto 0);
	
			memory_indicator_out: out std_logic;
			memory_operation_out: out std_logic; -- TODO: make this an enum type
			memory_address_out: out std_logic_vector(31 downto 0);
	
			writeback_indicator_out: out std_logic;
			writeback_register_out: out std_logic_vector(3 downto 0);
	
			flag_set_indicator_out: out std_logic;
	
			ready_out: out std_logic
		);
	end component;

	component instruction_execute is
		port(
			clk: in std_logic;
			enable_in: in std_logic;
	
			operation_in: in std_logic_vector(3 downto 0); -- TODO: make this an enum type (0: add, 1: sub, 2: mul, 3: and, 4: or, 5: xor)
			operand_1_in: in std_logic_vector(31 downto 0);
			operand_2_in: in std_logic_vector(31 downto 0);
	
			memory_indicator_in: in std_logic;
			memory_operation_in: in std_logic; -- TODO: make this an enum type
			memory_address_in: in std_logic_vector(31 downto 0);
	
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
	
			flag_set_indicator_in: in std_logic;
	
	
			result_out: out std_logic_vector(31 downto 0);
	
			memory_indicator_out: out std_logic;
			memory_operation_out: out std_logic; -- TODO: make this an enum type
			memory_address_out: out std_logic_vector(31 downto 0);
	
			writeback_indicator_out: out std_logic;
			writeback_register_out: out std_logic_vector(3 downto 0);
	
			flag_set_indicator_out: out std_logic;
			flags_out: out std_logic_vector(3 downto 0);
	
			ready_out: out std_logic
		);
	end component;

	component memory is
		port(
			clk: in std_logic;
			enable_in: in std_logic;
	
			result_in: in std_logic_vector(31 downto 0);
	
			memory_indicator_in: in std_logic;
			memory_operation_in: in std_logic; -- TODO: make this an enum type
			memory_address_in: in std_logic_vector(31 downto 0);
	
			writeback_indicator_in: in std_logic;
			writeback_register_in: in std_logic_vector(3 downto 0);
	
			flag_set_indicator_in: in std_logic;
			flags_in: in std_logic_vector(3 downto 0);
	
	
			writeback_indicator_out: out std_logic;
			writeback_register_out: out std_logic_vector(3 downto 0);
			writeback_value_out: out std_logic_vector(31 downto 0);
	
			flag_set_indicator_out: out std_logic;
			flags_out: out std_logic_vector(3 downto 0);
	
			ready_out: out std_logic
		);
	end component;

begin
	enable <= fetch_ready and decode_ready and execute_ready and memory_ready;

	clock_div: clock_divider port map(clk_in => clk_100MHz, clk_out => clk);

	instr_fetch: instruction_fetch port map(clk => clk, enable_in => enable, opcode_out => opcode, ready_out => fetch_ready);

	instr_decode: instruction_decode port map(clk => clk, enable_in => enable, opcode_in => opcode,
		                                       writeback_indicator_in => writeback_indicator, writeback_register_in => writeback_register, writeback_value_in => writeback_value,
		                                       flag_set_indicator_in => flag_set_indicator, flags_in => flags,
                                             operation_out => operation_decode_to_exec, operand_1_out => op1_decode_to_exec, operand_2_out => op2_decode_to_exec,
															memory_indicator_out => memory_indicator_decode_to_exec, memory_operation_out => memory_op_decode_to_exec, memory_address_out => memory_address_decode_to_exec,
															writeback_indicator_out => writeback_indicator_decode_to_exec, writeback_register_out => writeback_register_decode_to_exec,
															flag_set_indicator_out => flag_set_indicator_decode_to_exec,
															ready_out => decode_ready);

	instr_execute: instruction_execute port map(clk => clk, enable_in => enable,
		                                         operation_in => operation_decode_to_exec, operand_1_in => op1_decode_to_exec, operand_2_in => op2_decode_to_exec,
	                                            memory_indicator_in => memory_indicator_decode_to_exec, memory_operation_in => memory_op_decode_to_exec, memory_address_in => memory_address_decode_to_exec,
	                                            writeback_indicator_in => writeback_indicator_decode_to_exec, writeback_register_in => writeback_register_decode_to_exec,
	                                            flag_set_indicator_in => flag_set_indicator_decode_to_exec,
	                                            result_out => result_exec_to_mem,
	                                            memory_indicator_out => mem_indicator_exec_to_mem, memory_operation_out => mem_op_exec_to_mem, memory_address_out => mem_addr_exec_to_mem,
	                                            writeback_indicator_out => wb_indicator_exec_to_mem, writeback_register_out => wb_reg_exec_to_mem,
	                                            flag_set_indicator_out => flag_set_indicator_exec_to_mem, flags_out => flags_exec_to_mem,
	                                            ready_out => execute_ready);

	mem: memory port map(clk => clk, enable_in => enable,
                        result_in => result_exec_to_mem,
                        memory_indicator_in => memory_indicator_decode_to_exec, memory_operation_in => memory_op_decode_to_exec, memory_address_in => memory_address_decode_to_exec,
                        writeback_indicator_in => wb_indicator_exec_to_mem, writeback_register_in => wb_reg_exec_to_mem,
                        flag_set_indicator_in => flag_set_indicator_exec_to_mem, flags_in => flags_exec_to_mem,
                        writeback_indicator_out => writeback_indicator, writeback_register_out => writeback_register, writeback_value_out => writeback_value,
                        flag_set_indicator_out => flag_set_indicator, flags_out => flags,
                        ready_out => memory_ready);
end Behavioral;