library ieee;
use ieee.std_logic_1164.all;

use work.top_level_types.all;
use work.top_level_constants.all;


entity memory_interface is
	port(
		clk: in std_logic;

		mem_p0_clk_in: in std_logic;
		mem_p0_in: in memory_port := DEFAULT_MEMORY_PORT;
		mem_p0_status_out: out memory_port_status := DEFAULT_MEMORY_PORT_STATUS;

		dram_p0_out: out dram_port := DEFAULT_DRAM_PORT;
		dram_p0_status_in: in dram_port_status;

		bram_port_out: out bram_port := DEFAULT_BRAM_PORT;
		bram_data_in: in std_logic_vector(31 downto 0);

		calib_done_in: in std_logic;
		memory_ready_out: out std_logic

		-- for vga signal
		--read_port_clk_in: in std_logic;
		--read_port_in: in read_cmd_signals;
		--read_status_out: out read_status_signals;
		--ram_out: out ram_signals;
		--ram_bus: inout ram_bus_signals;
		--calib_done_out: out std_logic := '0';
		--reset_in: in std_logic
	);
end memory_interface;

architecture Behavioral of memory_interface is
	constant STATE_INITIALIZE: std_logic_vector(2 downto 0)      := "000";
	constant STATE_READY: std_logic_vector(2 downto 0)           := "001";
	constant STATE_READING_DRAM: std_logic_vector(2 downto 0)    := "010";
	constant STATE_WRITING_DRAM: std_logic_vector(2 downto 0)    := "011";
	constant STATE_READING_TEXTBUF: std_logic_vector(2 downto 0) := "100";

	signal p0_state: std_logic_vector(2 downto 0) := STATE_INITIALIZE;
	signal p0: dram_port := DEFAULT_DRAM_PORT;

	--signal c3_p0_cmd_en: std_logic := '0';
	--signal c3_p0_cmd_instr: std_logic_vector(2 downto 0) := "000";
	--signal c3_p0_cmd_byte_addr: std_logic_vector(29 downto 0) := (others => '0');
	--signal c3_p0_cmd_empty: std_logic := '0';
	--signal c3_p0_cmd_full: std_logic := '0';
	--signal c3_p0_wr_en: std_logic := '0';
	--signal c3_p0_wr_mask: std_logic_vector(3 downto 0) := "1111";
	--signal c3_p0_wr_data: std_logic_vector(31 downto 0) := (others => '0');
	--signal c3_p0_wr_full: std_logic := '0';
	--signal c3_p0_wr_empty: std_logic := '0';
	--signal c3_p0_wr_count: std_logic_vector(6 downto 0) := (others => '0');
	--signal c3_p0_rd_data: std_logic_vector(31 downto 0) := (others => '0');
	--signal c3_p0_rd_full: std_logic := '0';
	--signal c3_p0_rd_empty: std_logic := '0';
	--signal c3_p0_rd_count: std_logic_vector(6 downto 0) := (others => '0');

begin

	process(clk)
	begin
		if rising_edge(mem_p0_clk_in) then
			if p0_state = STATE_INITIALIZE then
				if calib_done_in = '1' then
					p0_state <= STATE_READY;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '1';

					bram_port_out <= DEFAULT_BRAM_PORT;

					memory_ready_out <= '1';
				else
					p0_state <= STATE_INITIALIZE;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '1';

					bram_port_out <= DEFAULT_BRAM_PORT;
				end if;
			elsif p0_state = STATE_READY then
				if mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_READ and mem_p0_in.address(26) = '0' then
					-- read to main memory
					p0_state <= STATE_READING_DRAM;

					dram_p0_out.command_enable <= '1';
					dram_p0_out.command <= "001";
					dram_p0_out.address <= "000" & mem_p0_in.address & "00";
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bram_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_WRITE and mem_p0_in.address(26) = '0' then
					-- write to main memory
					p0_state <= STATE_WRITING_DRAM;

					dram_p0_out.command_enable <= '1';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= "000" & mem_p0_in.address & "00";
					dram_p0_out.write_enable <= '1';
					dram_p0_out.write_mask <= not(mem_p0_in.write_mask);
					dram_p0_out.write_data <= mem_p0_in.write_data;

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bram_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_READ then --and read_write_port_in.address(26 downto 13) = "11000000000000" then
					-- read from text buffer
					p0_state <= STATE_READING_TEXTBUF;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bram_port_out.address <= mem_p0_in.address(11 downto 2);  -- TODO: change to 12 downto 2 when 4 BRAMs are used
					bram_port_out.data <= (others => '0');
					bram_port_out.mask <= (others => '0');
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_WRITE then --and read_write_port_in.address(26 downto 13) = "11000000000000" then
					-- write to text buffer
					p0_state <= STATE_READY;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bram_port_out.address <= mem_p0_in.address(11 downto 2);  -- TODO: change to 12 downto 2 when 4 BRAMs are used
					bram_port_out.data <= mem_p0_in.write_data;
					bram_port_out.mask <= mem_p0_in.write_mask;
				else
					-- no-op
					p0_state <= STATE_READY;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '1';
					
					bram_port_out <= DEFAULT_BRAM_PORT;
				end if;
			elsif p0_state = STATE_READING_DRAM then
				if dram_p0_status_in.read_empty = '0' then
					-- read data ready
					p0_state <= STATE_READY;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= dram_p0_status_in.read_data;
					mem_p0_status_out.data_valid <= '1';
					mem_p0_status_out.ready <= '1';

					bram_port_out <= DEFAULT_BRAM_PORT;
				else
					-- read data not ready
					p0_state <= STATE_READING_DRAM;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bram_port_out <= DEFAULT_BRAM_PORT;
				end if;
			elsif p0_state = STATE_WRITING_DRAM then
				if dram_p0_status_in.write_empty = '1' and dram_p0_status_in.command_empty = '1' then
					-- write handled
					p0_state <= STATE_READY;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '1';

					bram_port_out <= DEFAULT_BRAM_PORT;
				else
					-- write still pending
					p0_state <= STATE_WRITING_DRAM;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bram_port_out <= DEFAULT_BRAM_PORT;
				end if;
			elsif p0_state = STATE_READING_TEXTBUF then
				p0_state <= STATE_READY;

				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');

				mem_p0_status_out.read_data <= bram_data_in;
				mem_p0_status_out.data_valid <= '1';
				mem_p0_status_out.ready <= '1';

				bram_port_out <= DEFAULT_BRAM_PORT;
			end if;
		end if;
	end process;
	
end Behavioral;
