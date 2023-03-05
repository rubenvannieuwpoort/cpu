library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_read_write is
	port(
		clk: in std_logic;

		-- register read stage
		-- ===================
		valid_in: in std_logic;
		read_indicator_1_in: in std_logic;
		reg_1_in: in std_logic_vector(3 downto 0);
		read_indicator_2_in: in std_logic;
		reg_2_in: in std_logic_vector(3 downto 0);

		valid_out: out std_logic := '0';
		op_1_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		op_2_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

		hold_out: out std_logic := '0';

		-- passthrough signals
		operation_in: std_logic_vector(3 downto 0);
		memory_operation_in: in std_logic;
		memory_value_in: in std_logic_vector(31 downto 0);
		writeback_indicator_passthrough_in: in std_logic;
		writeback_register_passthrough_in: in std_logic_vector(3 downto 0);

		operation_out: out std_logic_vector(3 downto 0) := "0000";
		memory_operation_out: out std_logic := '0';
		memory_value_out: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		writeback_indicator_out: out std_logic;
		writeback_register_out: out std_logic_vector(3 downto 0);

		-- writeback stage
		-- ===============
		writeback_indicator_in: in std_logic;
		writeback_register_in: in std_logic_vector(3 downto 0);
		writeback_value_in: in std_logic_vector(31 downto 0)
	);
end register_read_write;

architecture Behavioral of register_read_write is
	type register_file is array(0 to 15) of std_logic_vector(31 downto 0);
	signal reg: register_file := ("00000000000000000000000000000000", "00000000000000000000000000000001", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000");

	type scoreboard is array(0 to 15) of std_logic_vector(1 downto 0);
	signal writes_in_flight: scoreboard := ("00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00");
begin
	process(clk)
		variable v_r1_ready, v_r2_ready: std_logic;
		variable v_reg_1_val, v_reg_2_val: std_logic_vector(31 downto 0);
		variable v_write_incoming, v_write_outgoing: std_logic;
		variable v_valid: std_logic;
	begin
		if rising_edge(clk) then
		
			-- register read
			if valid_in = '1' then
				if read_indicator_1_in = '1' then
					if writes_in_flight(to_integer(unsigned(reg_1_in))) = "00" then
						v_reg_1_val := reg(to_integer(unsigned(reg_1_in)));
						v_r1_ready := '1';
					elsif writes_in_flight(to_integer(unsigned(reg_1_in))) = "01" and writeback_indicator_in = '1' and writeback_register_in = reg_1_in then
						v_reg_1_val := writeback_value_in;
						v_r1_ready := '1';
					else
						v_reg_1_val := "00000000000000000000000000000000";
						v_r1_ready := '0';
					end if;
				end if;

				if read_indicator_2_in = '1' then
					if writes_in_flight(to_integer(unsigned(reg_2_in))) = "00" then
						v_reg_2_val := reg(to_integer(unsigned(reg_2_in)));
						v_r2_ready := '1';
					elsif writes_in_flight(to_integer(unsigned(reg_2_in))) = "01" and writeback_indicator_in = '1' and writeback_register_in = reg_2_in then
						v_reg_2_val := writeback_value_in;
						v_r2_ready := '1';
					else
						v_reg_1_val := "00000000000000000000000000000000";
						v_r2_ready := '0';
					end if;
				end if;
			end if;
			
			v_valid := valid_in and v_r1_ready and v_r2_ready;
			
			if v_valid = '1' then
				valid_out <= '1';
				op_1_out <= v_reg_1_val;
				op_2_out <= v_reg_2_val;
				operation_out <= operation_in;
				memory_operation_out <= memory_operation_in;
				memory_value_out <= memory_value_in;
				writeback_indicator_out <= writeback_indicator_passthrough_in;
				writeback_register_out <= writeback_register_passthrough_in;
			else
				valid_out <= '0';
				op_1_out <= "00000000000000000000000000000000";
				op_2_out <= "00000000000000000000000000000000";
				operation_out <= "0000";
				memory_operation_out <= memory_operation_in;
				memory_value_out <= memory_value_in;
				writeback_indicator_out <= writeback_indicator_passthrough_in;
				writeback_register_out <= writeback_register_passthrough_in;
			end if;
		end if;
		
		-- register writeback
		if writeback_indicator_in = '1' then
			reg(to_integer(unsigned(writeback_register_in))) <= writeback_value_in;
		end if;
		
		-- bookkeeping of in-flight register writes
		v_write_outgoing := v_valid and writeback_indicator_passthrough_in;
		v_write_incoming := writeback_indicator_in;
		if v_write_outgoing = '1' and v_write_incoming = '1' and writeback_register_passthrough_in = writeback_register_in then
		else
			if v_write_incoming = '1' then
				writes_in_flight(to_integer(unsigned(writeback_register_in))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(writeback_register_in)))) + 3);
			end if;

			if v_write_outgoing = '1' then
				writes_in_flight(to_integer(unsigned(writeback_register_passthrough_in))) <= std_logic_vector(unsigned(writes_in_flight(to_integer(unsigned(writeback_register_passthrough_in)))) + 1);
			end if;
		end if;
	end process;
end Behavioral;