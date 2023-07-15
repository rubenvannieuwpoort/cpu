library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity CPU is
	port(
		clk: in std_logic;
		memory_ready: in std_logic;
		write_status: in write_status_signals;
		write_port: out write_port_signals
	);
end CPU;


architecture Behavioral of CPU is
	signal fetch_output: fetch_output_type := DEFAULT_FETCH_OUTPUT;

	signal decode_hold_out: std_logic := '0';
	signal decode_output: decode_output_type := DEFAULT_DECODE_OUTPUT;

	signal register_read_hold_out: std_logic := '0';
	signal register_read_output: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;

	signal execute_hold_out: std_logic := '0';
	signal execute_output: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal execute_continue_out: std_logic;
	signal execute_pc_indicator_out: std_logic;
	signal execute_pc_out: std_logic_vector(31 downto 0);

	signal memory_hold_out: std_logic := '0';
	signal memory_output: memory_output_type := DEFAULT_MEMORY_OUTPUT;


	component fetch is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			continue_in: in std_logic;
			pc_indicator_in: in std_logic;
			pc_in: in std_logic_vector(19 downto 0);
			output: out fetch_output_type
		);
	end component;

	component decode is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			input: in fetch_output_type;
			hold_out: out std_logic;
			output: out decode_output_type
		);
	end component;

	component registers is
		port(
			clk: in std_logic;
			write_input: in memory_output_type;
			read_hold_in: in std_logic;
			read_input: in decode_output_type;
			read_hold_out: out std_logic;
			read_output: out register_read_output_type
		);
	end component;

	component execute is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			input: in register_read_output_type;
			hold_out: out std_logic;
			output: out execute_output_type;
			continue_out: out std_logic;
			pc_indicator_out: out std_logic;
			pc_out: out std_logic_vector(31 downto 0)
		);
	end component;

	component memory is
		port(
			clk: in std_logic;
			--memory_ready: in std_logic;
			hold_in: in std_logic;
			input: in execute_output_type;
			hold_out: out std_logic;
			--write_status_in: in write_status_signals;
			--write_port_out: out write_port_signals;
			output: out memory_output_type
		);
	end component;

begin
	stage_fetch: fetch port map(
		clk => clk,
		hold_in => decode_hold_out,
		continue_in => execute_continue_out,
		pc_indicator_in => execute_pc_indicator_out,
		pc_in => execute_pc_out,
		output => fetch_output
	);

	stage_decode: decode port map(
		clk => clk,
		hold_in => register_read_hold_out,
		input => fetch_output,
		hold_out => decode_hold_out,
		output => decode_output
	);

	stage_registers: registers port map(
		clk => clk,
		write_input => memory_output,
		read_hold_in => execute_hold_out,
		read_input => decode_output,
		read_hold_out => register_read_hold_out,
		read_output => register_read_output
	);

	stage_execute: execute port map(
		clk => clk,
		hold_in => memory_hold_out,
		input => register_read_output,
		hold_out => execute_hold_out,
		output => execute_output,
		continue_out => execute_continue_out,
		pc_indicator_out => execute_pc_indicator_out,
		pc_out => execute_pc_out
	);

	stage_memory: memory port map(
		clk => clk,
		--memory_ready => memory_ready,
		hold_in => '0',
		input => execute_output,
		hold_out => memory_hold_out,
		--write_status_in => write_status,
		--write_port_out => write_port,
		output => memory_output
	);
end Behavioral;