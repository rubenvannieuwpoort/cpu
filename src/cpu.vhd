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

	signal memory_busy_out: std_logic := '0';
	signal memory_output: memory_output_type := DEFAULT_MEMORY_OUTPUT;


	component fetch is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			data_out: out fetch_output_type
		);
	end component;

	component decode is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			data_in: in fetch_output_type;
			busy_out: out std_logic;
			data_out: out decode_output_type
		);
	end component;

	component registers is
		port(
			clk: in std_logic;
			write_data_in: in memory_output_type;
			read_hold_in: in std_logic;
			read_data_in: in decode_output_type;
			read_busy_out: out std_logic;
			read_data_out: out register_read_output_type
		);
	end component;

	component execute is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			data_in: in register_read_output_type;
			busy_out: out std_logic;
			data_out: out execute_output_type
		);
	end component;

	component memory is
		port(
			clk: in std_logic;
			hold_in: in std_logic;
			data_in: in execute_output_type;
			busy_out: out std_logic;
			data_out: out memory_output_type
		);
	end component;

begin
	stage_fetch: fetch port map(clk => clk, hold_in => decode_busy_out, data_out => fetch_output);
	stage_decode: decode port map(clk => clk, hold_in => register_read_busy_out, data_in => fetch_output, busy_out => decode_busy_out, data_out => decode_output);
	stage_registers: registers port map(clk => clk, write_data_in => memory_output, read_hold_in => execute_busy_out, read_data_in => decode_output, read_busy_out => register_read_busy_out, read_data_out => register_read_output);
	stage_execute: execute port map(clk => clk, hold_in => memory_busy_out, data_in => register_read_output, busy_out => execute_busy_out, data_out => execute_output);
	stage_memory: memory port map(clk => clk, hold_in => '0', data_in => execute_output, busy_out => memory_busy_out, data_out => memory_output);
end Behavioral;