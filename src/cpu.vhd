library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity CPU is
	port(
		clk: in std_logic;
		memory_ready_in: in std_logic;
		read_write_status_in: in read_write_status_signals;
		read_write_port_out: out read_write_cmd_signals;
		leds_out: out std_logic_vector(7 downto 0)
	);
end CPU;


architecture Behavioral of CPU is
	signal fetch_output: fetch_output_type := DEFAULT_FETCH_OUTPUT;

	signal decode_stall_out: std_logic := '0';
	signal decode_output: decode_output_type := DEFAULT_DECODE_OUTPUT;

	signal register_read_stall_out: std_logic := '0';
	signal register_read_output: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;

	signal execute_stall_out: std_logic := '0';
	signal execute_output: execute_output_type := DEFAULT_EXECUTE_OUTPUT;
	signal branch: branch_signals := DEFAULT_BRANCH_SIGNALS;

	signal memory_stall_out: std_logic := '0';
	signal memory_output: memory_output_type := DEFAULT_MEMORY_OUTPUT;


	component fetch is
		port(
			clk: in std_logic;
			stall_in: in std_logic;
			branch_in: in branch_signals;
			output: out fetch_output_type
		);
	end component;

	component decode is
		port(
			clk: in std_logic;
			stall_in: in std_logic;
			input: in fetch_output_type;
			stall_out: out std_logic;
			output: out decode_output_type
		);
	end component;

	component registers is
		port(
			clk: in std_logic;
			write_input: in memory_output_type;
			read_stall_in: in std_logic;
			read_input: in decode_output_type;
			read_stall_out: out std_logic;
			read_output: out register_read_output_type
		);
	end component;

	component execute is
		port(
			clk: in std_logic;
			stall_in: in std_logic;
			input: in register_read_output_type;
			stall_out: out std_logic;
			output: out execute_output_type;
			branch_out: out branch_signals;
			leds_out: out std_logic_vector(7 downto 0)
		);
	end component;

	component memory is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			stall_in: in std_logic;
			input: in execute_output_type;
			read_write_status_in: in read_write_status_signals;
			read_write_port_out: out read_write_cmd_signals;
			stall_out: out std_logic;
			output: out memory_output_type
		);
	end component;

begin
	stage_fetch: fetch port map(
		clk => clk,
		stall_in => decode_stall_out,
		branch_in => branch,
		output => fetch_output
	);

	stage_decode: decode port map(
		clk => clk,
		stall_in => register_read_stall_out,
		input => fetch_output,
		stall_out => decode_stall_out,
		output => decode_output
	);

	stage_registers: registers port map(
		clk => clk,
		write_input => memory_output,
		read_stall_in => execute_stall_out,
		read_input => decode_output,
		read_stall_out => register_read_stall_out,
		read_output => register_read_output
	);

	stage_execute: execute port map(
		clk => clk,
		stall_in => memory_stall_out,
		input => register_read_output,
		stall_out => execute_stall_out,
		output => execute_output,
		branch_out => branch,
		leds_out => leds_out
	);

	stage_memory: memory port map(
		clk => clk,
		memory_ready_in => memory_ready_in,
		stall_in => '0',
		input => execute_output,
		read_write_status_in => read_write_status_in,
		read_write_port_out => read_write_port_out,
		stall_out => memory_stall_out,
		output => memory_output
	);
end Behavioral;