library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_level_types.all;
use work.top_level_constants.all;


entity memory_interface is
	port(
		clk: in std_logic;

		mem_p0_in: in memory_port := DEFAULT_MEMORY_PORT;
		mem_p0_status_out: out memory_port_status := DEFAULT_MEMORY_PORT_STATUS;

		dram_p0_out: out dram_port := DEFAULT_DRAM_PORT;
		dram_p0_status_in: in dram_port_status;

		bootram_port_out: out bram_port := DEFAULT_BRAM_PORT;
		bootram_data_in: in std_logic_vector(31 downto 0);

		fontram_port_out: out bram_port := DEFAULT_BRAM_PORT;
		fontram_data_in: in std_logic_vector(31 downto 0);

		textbuffer_port_out: out bram_port := DEFAULT_BRAM_PORT;
		textbuffer_data_in: in std_logic_vector(31 downto 0);

		calib_done_in: in std_logic;
		memory_ready_out: out std_logic
	);
end memory_interface;

architecture Behavioral of memory_interface is
	constant STATE_INITIALIZE: std_logic_vector(3 downto 0)        := "0000";
	constant STATE_READY: std_logic_vector(3 downto 0)             := "0001";

	constant STATE_READING_DRAM: std_logic_vector(3 downto 0)      := "0010";
	constant STATE_WRITING_DRAM: std_logic_vector(3 downto 0)      := "0011";

	constant STATE_READING_BOOTRAM_1: std_logic_vector(3 downto 0) := "0100";
	constant STATE_READING_BOOTRAM_2: std_logic_vector(3 downto 0) := "0101";

	constant STATE_READING_FONTRAM_1: std_logic_vector(3 downto 0) := "0110";
	constant STATE_READING_FONTRAM_2: std_logic_vector(3 downto 0) := "0111";

	constant STATE_READING_TEXTBUF_1: std_logic_vector(3 downto 0) := "1000";
	constant STATE_READING_TEXTBUF_2: std_logic_vector(3 downto 0) := "1001";

	signal p0_state: std_logic_vector(3 downto 0) := STATE_INITIALIZE;
	signal p0: dram_port := DEFAULT_DRAM_PORT;

begin
	process(clk)
	begin

		-- data port
		if rising_edge(clk) then
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;

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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				end if;
			elsif p0_state = STATE_READY then
				if mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_READ and unsigned(MAIN_MEMORY_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(MAIN_MEMORY_REGION_END) then
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_WRITE and unsigned(MAIN_MEMORY_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(MAIN_MEMORY_REGION_END) then
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_READ and unsigned(BOOT_RAM_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(BOOT_RAM_REGION_END) then
					-- read from boot ram
					p0_state <= STATE_READING_BOOTRAM_1;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bootram_port_out.address <= "0" & mem_p0_in.address(11 downto 2);
					bootram_port_out.write_data <= (others => '0');
					bootram_port_out.write_mask <= (others => '0');

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_WRITE and unsigned(BOOT_RAM_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(BOOT_RAM_REGION_END) then
					-- write to boot ram
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

					bootram_port_out.address <= "0" & mem_p0_in.address(11 downto 2);
					bootram_port_out.write_data <= mem_p0_in.write_data;
					bootram_port_out.write_mask <= mem_p0_in.write_mask;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_READ and unsigned(FONT_RAM_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(FONT_RAM_REGION_END) then
					-- read from font ram
					p0_state <= STATE_READING_FONTRAM_1;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out.address <= "0" & mem_p0_in.address(11 downto 2);
					fontram_port_out.write_data <= (others => '0');
					fontram_port_out.write_mask <= (others => '0');

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_WRITE and unsigned(FONT_RAM_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(FONT_RAM_REGION_END) then
					-- write to font ram
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out.address <= "0" & mem_p0_in.address(11 downto 2);
					fontram_port_out.write_data <= mem_p0_in.write_data;
					fontram_port_out.write_mask <= mem_p0_in.write_mask;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_READ and unsigned(TEXTBUFFER_RAM_REGION_START) <= unsigned(mem_p0_in.address) and unsigned(mem_p0_in.address) < unsigned(TEXTBUFFER_RAM_REGION_END) then
					-- read from text buffer
					p0_state <= STATE_READING_TEXTBUF_1;

					dram_p0_out.command_enable <= '0';
					dram_p0_out.command <= "000";
					dram_p0_out.address <= (others => '0');
					dram_p0_out.write_enable <= '0';
					dram_p0_out.write_mask <= "1111";
					dram_p0_out.write_data <= (others => '0');

					mem_p0_status_out.read_data <= (others => '0');
					mem_p0_status_out.data_valid <= '0';
					mem_p0_status_out.ready <= '0';

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out.address <= mem_p0_in.address(12 downto 2);
					textbuffer_port_out.write_data <= (others => '0');
					textbuffer_port_out.write_mask <= (others => '0');
				elsif mem_p0_in.enable = '1' and mem_p0_in.command = COMMAND_WRITE and mem_p0_in.address(26 downto 12) = "110000000000000" then
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out.address <= mem_p0_in.address(12 downto 2);
					textbuffer_port_out.write_data <= mem_p0_in.write_data;
					textbuffer_port_out.write_mask <= mem_p0_in.write_mask;
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
					
					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
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

					bootram_port_out <= DEFAULT_BRAM_PORT;

					fontram_port_out <= DEFAULT_BRAM_PORT;

					textbuffer_port_out <= DEFAULT_BRAM_PORT;
				end if;
			elsif p0_state = STATE_READING_BOOTRAM_1 then
				p0_state <= STATE_READING_BOOTRAM_2;
				
				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');
				
				mem_p0_status_out.read_data <= (others => '0');
				mem_p0_status_out.data_valid <= '0';
				mem_p0_status_out.ready <= '0';

				bootram_port_out <= DEFAULT_BRAM_PORT;

				fontram_port_out <= DEFAULT_BRAM_PORT;

				textbuffer_port_out <= DEFAULT_BRAM_PORT;
			elsif p0_state = STATE_READING_BOOTRAM_2 then
				p0_state <= STATE_READY;

				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');

				mem_p0_status_out.read_data <= bootram_data_in;
				mem_p0_status_out.data_valid <= '1';
				mem_p0_status_out.ready <= '1';

				bootram_port_out <= DEFAULT_BRAM_PORT;

				fontram_port_out <= DEFAULT_BRAM_PORT;

				textbuffer_port_out <= DEFAULT_BRAM_PORT;
			elsif p0_state = STATE_READING_FONTRAM_1 then
				p0_state <= STATE_READING_FONTRAM_2;
				
				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');
				
				mem_p0_status_out.read_data <= (others => '0');
				mem_p0_status_out.data_valid <= '0';
				mem_p0_status_out.ready <= '0';

				bootram_port_out <= DEFAULT_BRAM_PORT;

				fontram_port_out <= DEFAULT_BRAM_PORT;

				textbuffer_port_out <= DEFAULT_BRAM_PORT;
			elsif p0_state = STATE_READING_FONTRAM_2 then
				p0_state <= STATE_READY;

				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');

				mem_p0_status_out.read_data <= fontram_data_in;
				mem_p0_status_out.data_valid <= '1';
				mem_p0_status_out.ready <= '1';

				bootram_port_out <= DEFAULT_BRAM_PORT;

				fontram_port_out <= DEFAULT_BRAM_PORT;

				textbuffer_port_out <= DEFAULT_BRAM_PORT;
			elsif p0_state = STATE_READING_TEXTBUF_1 then
				p0_state <= STATE_READING_TEXTBUF_2;
				
				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');
				
				mem_p0_status_out.read_data <= (others => '0');
				mem_p0_status_out.data_valid <= '0';
				mem_p0_status_out.ready <= '0';

				bootram_port_out <= DEFAULT_BRAM_PORT;

				fontram_port_out <= DEFAULT_BRAM_PORT;

				textbuffer_port_out <= DEFAULT_BRAM_PORT;
			elsif p0_state = STATE_READING_TEXTBUF_2 then
				p0_state <= STATE_READY;

				dram_p0_out.command_enable <= '0';
				dram_p0_out.command <= "000";
				dram_p0_out.address <= (others => '0');
				dram_p0_out.write_enable <= '0';
				dram_p0_out.write_mask <= "1111";
				dram_p0_out.write_data <= (others => '0');

				mem_p0_status_out.read_data <= textbuffer_data_in;
				mem_p0_status_out.data_valid <= '1';
				mem_p0_status_out.ready <= '1';

				bootram_port_out <= DEFAULT_BRAM_PORT;

				fontram_port_out <= DEFAULT_BRAM_PORT;

				textbuffer_port_out <= DEFAULT_BRAM_PORT;
			end if;
		end if;
	end process;
	
end Behavioral;
