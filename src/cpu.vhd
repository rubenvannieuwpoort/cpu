library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity CPU is
	port(
		clk: in std_logic
	);
end CPU;


architecture Behavioral of CPU is
	signal fetch_output: fetch_output_type := DEFAULT_FETCH_OUTPUT;

	signal decode_busy_out: std_logic := '0';
	signal decode_output: decode_output_type := DEFAULT_DECODE_OUTPUT;

	signal register_read_busy_out: std_logic := '0';
	signal register_read_output: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;

	signal execute_busy_out: std_logic := '0';
	signal execute_output: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal execute_branch_indicator_out: std_logic;
	signal execute_branch_address_out: std_logic_vector(19 downto 0);

	signal memory_busy_out: std_logic := '0';
	signal memory_output: memory_output_type := DEFAULT_MEMORY_OUTPUT;


	component fetch is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			continue_in: in std_logic;
			address_indicator_in: in std_logic;
			address_in: in std_logic_vector(19 downto 0);
			output: out fetch_output_type
		);
	end component;

	component decode is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			input: in fetch_output_type;
			busy_out: out std_logic;
			output: out decode_output_type
		);
	end component;

	component registers is
		port(
			clk: in std_logic;
			write_input: in memory_output_type;
			read_hold_in: in std_logic;
			read_input: in decode_output_type;
			read_busy_out: out std_logic;
			read_output: out register_read_output_type
		);
	end component;

	component execute is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			input: in register_read_output_type;
			busy_out: out std_logic;
			output: out execute_output_type;
			branch_indicator: out std_logic := '0';
			branch_address: out std_logic_vector(19 downto 0) := "00000000000000000000"
		);
	end component;

	component memory is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			input: in execute_output_type;
			busy_out: out std_logic;
			output: out memory_output_type
		);
	end component;

begin
	stage_fetch: fetch port map(clk => clk, hold_in => decode_busy_out, continue_in => '0', address_indicator_in => execute_branch_indicator_out, address_in => execute_branch_address_out, output => fetch_output);
	stage_decode: decode port map(clk => clk, hold_in => register_read_busy_out, input => fetch_output, busy_out => decode_busy_out, output => decode_output);
	stage_registers: registers port map(clk => clk, write_input => memory_output, read_hold_in => execute_busy_out, read_input => decode_output, read_busy_out => register_read_busy_out, read_output => register_read_output);
	stage_execute: execute port map(clk => clk, hold_in => memory_busy_out, input => register_read_output, busy_out => execute_busy_out, output => execute_output, branch_indicator => execute_branch_indicator_out, branch_address => execute_branch_address_out);
	stage_memory: memory port map(clk => clk, hold_in => '0', input => execute_output, busy_out => memory_busy_out, output => memory_output);
end Behavioral;