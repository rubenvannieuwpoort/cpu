library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_level_types.all;
use work.top_level_constants.all;


entity vga_generator is
	port(
		clk: in std_logic;
		memory_ready_in: in std_logic;
		vga_out: out vga_signals;
		dram_port_out: out dram_port;
		dram_port_status_in: in dram_port_status
	);
end vga_generator;

-- VGA timings for different resolutions

-- HDTV (1280x720@60)
-- pixel clock: 74.2 MHz
-- 1280 72 80 216, 720 3 5 22

-- SDTV (720x480@60)
-- pixel clock: 27.7 MHz
-- 720 24 40 96, 480 10 3 32

-- VGA (640x480@60)
-- pixel clock: 27.17
-- 640 16 96 48, 480 10 2 33

architecture Behavioral of vga_generator is

	-- change this block to change the resolution
	-- you also need to change the frequency of the pixel clock
	--constant width: natural := 640;
	--constant hFrontPorch: natural := 16;
	--constant hSync: natural := 96;
	--constant hBackPorch: natural := 48;

	--constant height: natural := 480;
	--constant vFrontPorch: natural := 10;
	--constant vSync: natural := 2;
	--constant vBackPorch: natural := 33;
	constant width: natural := 1280;
	constant hFrontPorch: natural := 72;
	constant hSync: natural := 80;
	constant hBackPorch: natural := 216;

	constant height: natural := 720;
	constant vFrontPorch: natural := 3;
	constant vSync: natural := 5;
	constant vBackPorch: natural := 22;
	-- don't touch stuff after this line

	constant hSyncStart: natural := width + hFrontPorch;
	constant hSyncEnd: natural := hSyncStart + hSync;
	constant hMax: natural := hSyncEnd + hBackPorch - 1;
	constant hSyncActive: std_logic := '1';
	constant vSyncStart: natural := height + vFrontPorch;
	constant vSyncEnd: natural := vSyncStart + vSync;
	constant vMax: natural := vSyncEnd + vBackPorch - 1;
	constant vSyncActive: std_logic := '1';
	signal hCounter : unsigned(10 downto 0) := (others => '0');
	signal vCounter : unsigned(10 downto 0) := (others => '0');
	signal address  : unsigned(29 downto 0) := unsigned(SCREENBUFFER_ADDRESS(29 downto 0));
	signal read_cmd_enable_local : std_logic := '0';

begin
	dram_port_out.address <= std_logic_vector(address);
	dram_port_out.command_enable  <= read_cmd_enable_local;
	dram_port_out.command <= "001";
	dram_port_out.burst_length <= "001111";
	dram_port_out.write_enable <= '0';
	dram_port_out.write_mask <= "1111";
	dram_port_out.write_data <= (others => '0');

	process(clk)
	begin
		if rising_edge(clk) then
			if read_cmd_enable_local = '1' then
				address <= address + 64;  -- address is byte address, 16 words = 64 bytes are read per burst
			end if;

			read_cmd_enable_local <= '0';  -- indicates a read cmd should be issued
			if hCounter >= width - 64 then
				--read_cmd.refresh <= '1';
			else
				--read_cmd.refresh <= '0';
			end if;

			if hCounter(5 downto 0) = "111100" then -- once out of 64 cycles
				if vCounter < height - 1 then
					if hCounter < width then 
						-- issue a read every 64th cycle of a visible line (except last)
						read_cmd_enable_local <= memory_ready_in and not dram_port_status_in.command_full;
					end if;
				elsif vCounter = height - 1 then
					-- don't issue the last three reads on the last line
					if hCounter < (width - 4 * 64) then 
						read_cmd_enable_local <= memory_ready_in and not dram_port_status_in.command_full;
					end if;
				elsif vCounter = vMax-1 then 
					-- prime the read queue just before the first line with 3 read * 16 words * 4 bytes = 192 bytes
					if hCounter < 4 * 64 then
						read_cmd_enable_local <= memory_ready_in and not dram_port_status_in.command_full;
					end if;
				end if;
			end if;

			dram_port_out.read_enable <= '0';  -- indicates a read should be read from FIFO

			-- flush read port at end of frame
			if vCounter = height then
				-- read_data_enable <= memory_ready_in and not read_data_empty;
				address <= unsigned(SCREENBUFFER_ADDRESS(29 downto 0));
			end if;

			-- display pixels and trigger data FIFO reads
			if hCounter < width and vCounter < height then 
				case hcounter(1 downto 0) is
					when "00" =>
						vga_out.red   <= dram_port_status_in.read_data(31 downto 29);
						vga_out.green <= dram_port_status_in.read_data(28 downto 26);
						vga_out.blue  <= dram_port_status_in.read_data(25 downto 24);
					when "01" =>
						vga_out.red   <= dram_port_status_in.read_data(23 downto 21);
						vga_out.green <= dram_port_status_in.read_data(20 downto 18);
						vga_out.blue  <= dram_port_status_in.read_data(17 downto 16);
					when "10" =>
						vga_out.red   <= dram_port_status_in.read_data(15 downto 13);
						vga_out.green <= dram_port_status_in.read_data(12 downto 10);
						vga_out.blue  <= dram_port_status_in.read_data( 9 downto  8);
						-- read_data_enable will be asserted next cycle so read_data will change the one following that
						dram_port_out.read_enable <= memory_ready_in and not dram_port_status_in.read_empty;
					when others =>
						vga_out.red   <= dram_port_status_in.read_data( 7 downto 5);
						vga_out.green <= dram_port_status_in.read_data( 4 downto 2);
						vga_out.blue  <= dram_port_status_in.read_data( 1 downto 0);
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
