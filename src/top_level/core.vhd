library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_level_types.all;

use work.core_types.all;
use work.core_constants.all;


entity core is
	port(
		clk: in std_logic;
		memory_ready_in: in std_logic;
		data_port_out: out memory_port;
		data_port_status_in: in memory_port_status;
		leds_out: out std_logic_vector(7 downto 0)
	);
end core;


architecture Behavioral of core is
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


	component fetch_stage is
		port(
			clk: in std_logic;
			stall_in: in std_logic;
			branch_in: in branch_signals;
			output: out fetch_output_type
		);
	end component;

	component decode_stage is
		port(
			clk: in std_logic;
			stall_in: in std_logic;
			input: in fetch_output_type;
			stall_out: out std_logic;
			output: out decode_output_type
		);
	end component;

	component register_stages is
		port(
			clk: in std_logic;
			write_input: in memory_output_type;
			read_stall_in: in std_logic;
			read_input: in decode_output_type;
			read_stall_out: out std_logic;
			read_output: out register_read_output_type
		);
	end component;

	component execute_stage is
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

	component memory_stage is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			input: in execute_output_type;
			data_port_out: out memory_port;
			data_port_status_in: in memory_port_status;
			stall_out: out std_logic;
			output: out memory_output_type
		);
	end component;

begin
	fetch_stage_inst: fetch_stage port map(
		clk => clk,
		stall_in => decode_stall_out,
		branch_in => branch,
		output => fetch_output
	);

	decode_stage_inst: decode_stage port map(
		clk => clk,
		stall_in => register_read_stall_out,
		input => fetch_output,
		stall_out => decode_stall_out,
		output => decode_output
	);

	register_stages_inst: register_stages port map(
		clk => clk,
		write_input => memory_output,
		read_stall_in => execute_stall_out,
		read_input => decode_output,
		read_stall_out => register_read_stall_out,
		read_output => register_read_output
	);

	execute_stage_inst: execute_stage port map(
		clk => clk,
		stall_in => memory_stall_out,
		input => register_read_output,
		stall_out => execute_stall_out,
		output => execute_output,
		branch_out => branch,
		leds_out => leds_out
	);

	memory_stage_inst: memory_stage port map(
		clk => clk,
		memory_ready_in => memory_ready_in,
		input => execute_output,
		data_port_out => data_port_out,
		data_port_status_in => data_port_status_in,
		stall_out => memory_stall_out,
		output => memory_output
	);
end Behavioral;
