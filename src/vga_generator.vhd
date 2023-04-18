library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;


entity vga_generator is
	port(
		clk: in std_logic;
		memory_ready: in std_logic;
		vga_out: out vga_signals;
		read_cmd: out read_cmd_signals;
		read_status: in read_status_signals
	);
end vga_generator;

architecture Behavioral of vga_generator is
	-- Timings for 1280x720@60Hz, 75Mhz pixel clock
	constant hVisible: natural := 1280;
	constant hSyncStart: natural := 1352;
	constant hSyncEnd: natural := 1432;
	constant hMax: natural := 1647;
	constant hSyncActive: std_logic := '1';

	constant vVisible: natural := 720;
	constant vSyncStart: natural := 723;
	constant vSyncEnd: natural := 728;
	constant vMax: natural := 750;
	constant vSyncActive: std_logic := '1';

	signal hCounter : unsigned(10 downto 0) := (others => '0');
	signal vCounter : unsigned(10 downto 0) := (others => '0');
	signal address  : unsigned(29 downto 0) := (others => '0');
	signal read_cmd_enable_local : std_logic := '0';

begin
	read_cmd.address <= std_logic_vector(address);
	read_cmd.enable  <= read_cmd_enable_local;
	read_cmd.clk <= clk;

	process(clk)
	begin
		if rising_edge(clk) then
			if read_cmd_enable_local = '1' then
				address <= address + 64;  -- address is byte address, 16 words = 64 bytes are read per burst
			end if;

			read_cmd_enable_local <= '0';  -- indicates a read cmd should be issued
			if hCounter >= hVisible-64 then
				--read_cmd.refresh <= '1';
			else
				--read_cmd.refresh <= '0';
			end if;

			if hCounter(5 downto 0) = "111100" then -- once out of 64 cycles
				if vCounter < vVisible-1 then
					if hCounter < hVisible then 
						-- issue a read every 64th cycle of a visible line (except last)
						read_cmd_enable_local <= memory_ready and not read_status.cmd_full;
					end if;
				elsif vCounter = vVisible-1 then
					-- don't issue the last three reads on the last line
					if hCounter < (hVisible - 4 * 64) then 
						read_cmd_enable_local <= memory_ready and not read_status.cmd_full;
					end if;
				elsif vCounter = vMax-1 then 
					-- prime the read queue just before the first line with 3 read * 16 words * 4 bytes = 192 bytes
					if hCounter < 4 * 64 then
						read_cmd_enable_local <= memory_ready and not read_status.cmd_full;
					end if;
				end if;
			end if;

			read_cmd.data_enable <= '0';  -- indicates a read should be read from FIFO

			-- flush read port at end of frame
			if vCounter = vVisible then
				-- read_data_enable <= memory_ready and not read_data_empty;
				address <= (others => '0');
			end if;

			-- display pixels and trigger data FIFO reads
			if hCounter < hVisible and vCounter < vVisible then 
				case hcounter(1 downto 0) is
					when "00" =>
						vga_out.red   <= read_status.data( 7 downto 5);
						vga_out.green <= read_status.data( 4 downto 2);
						vga_out.blue  <= read_status.data( 1 downto 0);
					when "01" =>
						vga_out.red   <= read_status.data(15 downto 13);
						vga_out.green <= read_status.data(12 downto 10);
						vga_out.blue  <= read_status.data( 9 downto  8);
					when "10" =>
						vga_out.red   <= read_status.data(23 downto 21);
						vga_out.green <= read_status.data(20 downto 18);
						vga_out.blue  <= read_status.data(17 downto 16);
						-- read_data_enable will be asserted next cycle so read_data will change the one following that
						read_cmd.data_enable <= memory_ready and not read_status.data_empty;
					when others =>
						vga_out.red   <= read_status.data(31 downto 29);
						vga_out.green <= read_status.data(28 downto 26);
						vga_out.blue  <= read_status.data(25 downto 24);
				end case; 
			else
				vga_out.red   <= (others => '0');
				vga_out.green <= (others => '0');
				vga_out.blue  <= (others => '0');
			end if;

			-- track horizontal and vertical position and generate sync pulses
			if hCounter = hMax then
				hCounter <= (others => '0');
				if vCounter = vMax then 
					vCounter <= (others => '0');
				else
					vCounter <= vCounter +1;
				end if;

				if vCounter = vSyncStart then
					vga_out.vsync <= vSyncActive;
				end if;

				if vCounter = vSyncEnd then
					vga_out.vsync <= not vSyncActive;
				end if;
			else
				hCounter <= hCounter+1;
			end if;

			if hCounter = hSyncStart then
				vga_out.hsync <= hSyncActive;
			end if;

			if hCounter = hSyncEnd then
				vga_out.hsync <= not hSyncActive;
			end if;
		end if;
	end process;
end Behavioral;
