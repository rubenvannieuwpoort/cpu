library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.stages_interfaces.all;


entity execute is
	port(
		clk: in std_logic;
		stall_in: in std_logic;
		input: in register_read_output_type;

		stall_out: out std_logic := '0';
		output: out execute_output_type := DEFAULT_EXECUTE_OUTPUT;

		branch_out: out branch_signals := DEFAULT_BRANCH_SIGNALS;

		leds_out: out std_logic_vector(7 downto 0) := (others => '0')
	);
end execute;


architecture Behavioral of execute is
	signal buffered_input: register_read_output_type := DEFAULT_REGISTER_READ_OUTPUT;
	signal stamp: std_logic_vector(2 downto 0) := (others => '0');
	signal commit_slot: execute_output_type := DEFAULT_EXECUTE_OUTPUT;

	--constant csr_misa: std_logic_vector(31 downto 0) := X"40000100";
	--constant csr_mimpid: std_logic_vector(31 downto 0) := X"00000001";
	
	--constant CSR_MVENDORID_ADDRESS: std_logic_vector(11 downto 0) := X"F11";
	--constant CSR_MARCHID_ADDRESS: std_logic_vector(11 downto 0) := X"F12";
	--constant CSR_MIMPID_ADDRESS: std_logic_vector(11 downto 0) := X"F13";
	--constant CSR_MHARTID_ADDRESS: std_logic_vector(11 downto 0) := X"F14";
	--constant CSR_MCONFIGPTR_ADDRESS: std_logic_vector(11 downto 0) := X"F15";

	--constant CSR_MSTATUS_ADDRESS: std_logic_vector(11 downto 0) := X"300";
	--constant CSR_MISA_ADDRESS: std_logic_vector(11 downto 0) := X"301";

	--signal m_csr_mstatus_mpie: std_logic := '0';
	--signal m_csr_mstatus_spie: std_logic := '0';
	--signal m_csr_mstatus_mie: std_logic := '0';
	--signal m_csr_mstatus_sie: std_logic := '0';
begin
	stall_out <= buffered_input.valid;
	output <= commit_slot;

	process(clk)
		variable v_branch: branch_data;
		variable v_trap: std_logic;
		variable v_input: register_read_output_type;
		variable v_stall: std_logic;
		variable v_output: execute_output_type;
		variable v_temp, v_temp2: std_logic_vector(31 downto 0);

		variable v_new_stamp: std_logic_vector(2 downto 0);
		
		--variable v_m_csr_mstatus_mpie: std_logic;
		--variable v_m_csr_mstatus_spie: std_logic;
		--variable v_m_csr_mstatus_mie: std_logic;
		--variable v_m_csr_mstatus_sie: std_logic;
	begin
		if rising_edge(clk) then

			-- SELECT INPUT
			-- ============
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			elsif input.valid = '1' then
				v_input := input;
			else
				v_input := DEFAULT_REGISTER_READ_OUTPUT;
			end if;


			-- SET DEFAULTS
			-- ============
			v_stall := '0';
			v_branch := DEFAULT_BRANCH_DATA;
			--v_m_csr_mstatus_mpie := v_m_csr_mstatus_mpie;
			--v_m_csr_mstatus_spie := v_m_csr_mstatus_spie;
			--v_m_csr_mstatus_mie := v_m_csr_mstatus_mie;
			--v_m_csr_mstatus_sie := v_m_csr_mstatus_sie;


			-- SELECT OUTPUT
			-- =============
			if stall_in = '0' then
				if v_input.valid = '0' then
					v_output := DEFAULT_EXECUTE_OUTPUT;
				elsif v_input.stamp /= stamp then
					-- pass on some data to keep the read/write administration in order
					v_output := DEFAULT_EXECUTE_OUTPUT;
					v_output.valid := '1';
					v_output.act := '0';
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
				--elsif v_input.illegal = '1' then
				--	v_trap := true;
				elsif v_input.alu_function = ALU_FUNCTION_LEDS then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
					leds_out <= v_input.operand_1(7 downto 0);
				elsif v_input.alu_function = ALU_FUNCTION_ADD then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_2));
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SUB then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := std_logic_vector(unsigned(v_input.operand_1) - unsigned(v_input.operand_2));
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SLT then
					v_output.valid := '1';
					v_output.act := '1';
					if signed(v_input.operand_1) < signed(v_input.operand_2) then
						v_output.writeback_value := std_logic_vector(to_unsigned(1, 32));
					else
						v_output.writeback_value := (others => '0');
					end if;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SLTU then
					v_output.valid := '1';
					v_output.act := '1';
					if unsigned(v_input.operand_1) < unsigned(v_input.operand_2) then
						v_output.writeback_value := std_logic_vector(to_unsigned(1, 32));
					else
						v_output.writeback_value := (others => '0');
					end if;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_AND then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_input.operand_1 and v_input.operand_2;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_OR then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_input.operand_1 or v_input.operand_2;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_XOR then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_input.operand_1 xor v_input.operand_2;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SHIFT_LEFT then
					v_temp := v_input.operand_1;
					if unsigned(v_input.operand_2) >= 32 then
						v_temp := (others => '0');
					else
						if v_input.operand_2(4) = '1' then
							v_temp := v_temp(15 downto 0) & "0000000000000000";
						end if;
						if v_input.operand_2(3) = '1' then
							v_temp := v_temp(23 downto 0) & "00000000";
						end if;
						if v_input.operand_2(2) = '1' then
							v_temp := v_temp(27 downto 0) & "0000";
						end if;
						if v_input.operand_2(1) = '1' then
							v_temp := v_temp(29 downto 0) & "00";
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := v_temp(30 downto 0) & "0";
						end if;
					end if;

					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_temp;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_SHIFT_RIGHT then
					v_temp := v_input.operand_1;
					if unsigned(v_input.operand_2) >= 32 then
						v_temp := (others => '0');
					else
						if v_input.operand_2(4) = '1' then
							v_temp := "0000000000000000" & v_temp(31 downto 16);
						end if;
						if v_input.operand_2(3) = '1' then
							v_temp := "00000000" & v_temp(31 downto 8);
						end if;
						if v_input.operand_2(2) = '1' then
							v_temp := "0000" & v_temp(31 downto 4);
						end if;
						if v_input.operand_2(1) = '1' then
							v_temp := "00" & v_temp(31 downto 2);
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := "0" & v_temp(31 downto 1);
						end if;
					end if;

					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_temp;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT then
					v_temp := v_input.operand_1;
					v_temp2 := (others => v_input.operand_1(31));
					if unsigned(v_input.operand_2) >= 32 then
						v_temp := v_temp2;
					else
						if v_input.operand_2(4) = '1' then
							v_temp := v_temp2(15 downto 0) & v_temp(31 downto 16);
						end if;
						if v_input.operand_2(3) = '1' then
							v_temp := v_temp2(7 downto 0) & v_temp(31 downto 8);
						end if;
						if v_input.operand_2(2) = '1' then
							v_temp := v_temp2(3 downto 0) & v_temp(31 downto 4);
						end if;
						if v_input.operand_2(1) = '1' then
							v_temp := v_temp2(2 downto 0) & v_temp(31 downto 3);
						end if;
						if v_input.operand_2(0) = '1' then
							v_temp := v_temp2(1 downto 0) & v_temp(31 downto 2);
						end if;
					end if;

					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_temp;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
				elsif v_input.alu_function = ALU_FUNCTION_JAL then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := v_input.operand_3;
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					v_branch.indicator := '1';
					v_branch.address := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_2));
				elsif v_input.alu_function = ALU_FUNCTION_BEQ then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					if v_input.operand_1 = v_input.operand_2 then
						v_branch.indicator := '1';
						v_branch.address := v_input.operand_3;
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BNE then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					if v_input.operand_1 /= v_input.operand_2 then
						v_branch.indicator := '1';
						v_branch.address := v_input.operand_3;
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BLT then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					if signed(v_input.operand_1) < signed(v_input.operand_2) then
						v_branch.indicator := '1';
						v_branch.address := v_input.operand_3;
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BLTU then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					if unsigned(v_input.operand_1) < unsigned(v_input.operand_2) then
						v_branch.indicator := '1';
						v_branch.address := v_input.operand_3;
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BGE then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					if signed(v_input.operand_1) >= signed(v_input.operand_2) then
						v_branch.indicator := '1';
						v_branch.address := v_input.operand_3;
					end if;
				elsif v_input.alu_function = ALU_FUNCTION_BGEU then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_NOP;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := (others => '0');
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;

					if unsigned(v_input.operand_1) >= unsigned(v_input.operand_2) then
						v_branch.indicator := '1';
						v_branch.address := v_input.operand_3;
					end if;
				--elsif v_input.alu_function = ALU_FUNCTION_CSRRW then
				--	v_output.writeback_register := v_input.writeback_register;
				--	v_output.tag := v_input.tag;

				--	if v_input.csr_register = CSR_MVENDORID_ADDRESS and v_input.operand_1_is_zero_register = '1'then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MARCHID_ADDRESS and v_input.operand_1_is_zero_register = '1'then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MIMPID_ADDRESS and v_input.operand_1_is_zero_register = '1'then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := csr_mimpid;
				--	elsif v_input.csr_register = CSR_MHARTID_ADDRESS and v_input.operand_1_is_zero_register = '1'then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MCONFIGPTR_ADDRESS and v_input.operand_1_is_zero_register = '1'then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MSTATUS_ADDRESS then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_m_csr_mstatus_mpie := v_input.operand_1(7);
				--		v_m_csr_mstatus_spie := v_input.operand_1(5);
				--		v_m_csr_mstatus_mie := v_input.operand_1(3);
				--		v_m_csr_mstatus_sie := v_input.operand_1(1);
				--		v_output.writeback_value := "000000000000000011000000" & m_csr_mstatus_mpie & "0" & m_csr_mstatus_spie & "0" & m_csr_mstatus_mie & "0" & m_csr_mstatus_sie & "0";
				--	elsif v_input.csr_register = CSR_MISA_ADDRESS then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := csr_misa;
				--	--elsif v_input.csr_register = CSR_MIE then
				--	--elsif v_input.csr_register = CSR_MTVEC then
				--	--elsif v_input.csr_register = CSR_MSTATUSH then
				--	--elsif v_input.csr_register = CSR_MSCRATCH then
				--	--elsif v_input.csr_register = CSR_MEPC then
				--	--elsif v_input.csr_register = CSR_MCAUSE then
				--	--elsif v_input.csr_register = CSR_MTVAL then
				--	--elsif v_input.csr_register = CSR_MIP then
				--	--elsif v_input.csr_register = CSR_MTINST then
				--	--elsif v_input.csr_register = CSR_MTVAL2 then
				--	--else
				--		-- TODO: handle this? fire interrupt?
				--	end if;
				--elsif v_input.alu_function = ALU_FUNCTION_CSRRS then
				--	v_output.writeback_register := v_input.writeback_register;
				--	v_output.tag := v_input.tag;

				--	-- TODO: v_csr_mtargetreg := csr_mtargetreg or v_input.operand_1;

				--	if v_input.csr_register = CSR_MVENDORID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MARCHID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MIMPID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := csr_mimpid;
				--	elsif v_input.csr_register = CSR_MHARTID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MCONFIGPTR_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MSTATUS_ADDRESS then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_m_csr_mstatus_mpie := v_m_csr_mstatus_mpie or v_input.operand_1(7);
				--		v_m_csr_mstatus_spie := v_m_csr_mstatus_spie or v_input.operand_1(5);
				--		v_m_csr_mstatus_mie := v_m_csr_mstatus_mie or v_input.operand_1(3);
				--		v_m_csr_mstatus_sie := v_m_csr_mstatus_sie or v_input.operand_1(1);
				--		v_output.writeback_value := "000000000000000011000000" & m_csr_mstatus_mpie & "0" & m_csr_mstatus_spie & "0" & m_csr_mstatus_mie & "0" & m_csr_mstatus_sie & "0";
				--	elsif v_input.csr_register = CSR_MISA_ADDRESS then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := csr_misa;  -- 32-bit RVI
				--	--elsif v_input.csr_register = CSR_MIE then
				--	--elsif v_input.csr_register = CSR_MTVEC then
				--	--elsif v_input.csr_register = CSR_MCOUNTEREN then
				--	--elsif v_input.csr_register = CSR_MSTATUSH then
				--	--elsif v_input.csr_register = CSR_MSCRATCH then
				--	--elsif v_input.csr_register = CSR_MEPC then
				--	--elsif v_input.csr_register = CSR_MCAUSE then
				--	--elsif v_input.csr_register = CSR_MTVAL then
				--	--elsif v_input.csr_register = CSR_MIP then
				--	--elsif v_input.csr_register = CSR_MTINST then
				--	--elsif v_input.csr_register = CSR_MTVAL2 then
				--	--else
				--		-- TODO: handle this? fire interrupt?
				--	end if;
				--elsif v_input.alu_function = ALU_FUNCTION_CSRRC then
				--	v_output.writeback_register := v_input.writeback_register;
				--	v_output.tag := v_input.tag;

				--	-- TODO: v_csr_mtargetreg := csr_mtargetreg and not(v_input.operand_1);

				--	if v_input.csr_register = CSR_MVENDORID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MARCHID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MIMPID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := csr_mimpid;
				--	elsif v_input.csr_register = CSR_MHARTID_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MCONFIGPTR_ADDRESS and v_input.operand_1 = "00000" then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := (others => '0');
				--	elsif v_input.csr_register = CSR_MSTATUS_ADDRESS then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_m_csr_mstatus_mpie := v_m_csr_mstatus_mpie and not(v_input.operand_1(7));
				--		v_m_csr_mstatus_spie := v_m_csr_mstatus_spie and not(v_input.operand_1(5));
				--		v_m_csr_mstatus_mie := v_m_csr_mstatus_mie and not(v_input.operand_1(3));
				--		v_m_csr_mstatus_sie := v_m_csr_mstatus_sie and not(v_input.operand_1(1));
				--		v_output.writeback_value := "000000000000000011000000" & m_csr_mstatus_mpie & "0" & m_csr_mstatus_spie & "0" & m_csr_mstatus_mie & "0" & m_csr_mstatus_sie & "0";
				--	elsif v_input.csr_register = CSR_MISA_ADDRESS then
				--		v_output.valid := '1';
				--		v_output.act := '1';
				--		v_output.writeback_value := csr_misa;  -- 32-bit RVI
				--	--elsif v_input.csr_register = CSR_MIE then
				--	--elsif v_input.csr_register = CSR_MTVEC then
				--	--elsif v_input.csr_register = CSR_MCOUNTEREN then
				--	--elsif v_input.csr_register = CSR_MSTATUSH then
				--	--elsif v_input.csr_register = CSR_MSCRATCH then
				--	--elsif v_input.csr_register = CSR_MEPC then
				--	--elsif v_input.csr_register = CSR_MCAUSE then
				--	--elsif v_input.csr_register = CSR_MTVAL then
				--	--elsif v_input.csr_register = CSR_MIP then
				--	--elsif v_input.csr_register = CSR_MTINST then
				--	--elsif v_input.csr_register = CSR_MTVAL2 then
				--	--else
				--		-- TODO: handle this? fire interrupt?
				--	end if;
				elsif v_input.alu_function = ALU_FUNCTION_STORE_BYTE then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_STORE;

					v_output.memory_address := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_3));
	
					if v_output.memory_address(1 downto 0) = "00" then
						v_output.memory_data := v_input.operand_2(7 downto 0) & "000000000000000000000000";
						v_output.memory_write_mask := "1000";
					elsif v_output.memory_address(1 downto 0) = "01" then
						v_output.memory_data := "00000000" & v_input.operand_2(7 downto 0) & "0000000000000000";
						v_output.memory_write_mask := "0100";
					elsif v_output.memory_address(1 downto 0) = "10" then
						v_output.memory_data := "0000000000000000" & v_input.operand_2(7 downto 0) & "00000000";
						v_output.memory_write_mask := "0010";
					else
						v_output.memory_data := "000000000000000000000000" & v_input.operand_2(7 downto 0);
						v_output.memory_write_mask := "0001";
					end if;

					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';

					v_output.tag := v_input.tag;
					v_branch.indicator := '0';
					v_branch.address := (others => '0');
				elsif v_input.alu_function = ALU_FUNCTION_STORE_HALFWORD then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_STORE;

					v_output.memory_address := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_3));
	
					if v_output.memory_address(1) = '0' then
						v_output.memory_data := v_input.operand_2(7 downto 0) & v_input.operand_2(15 downto 8) & "0000000000000000";
						v_output.memory_write_mask := "1100";
					else
						v_output.memory_data := "0000000000000000" & v_input.operand_2(7 downto 0) & v_input.operand_2(15 downto 8);
						v_output.memory_write_mask := "0011";
					end if;

					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';

					v_output.tag := v_input.tag;
					v_branch.indicator := '0';
					v_branch.address := (others => '0');
				elsif v_input.alu_function = ALU_FUNCTION_STORE_WORD then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := (others => '0');
					v_output.memory_operation := MEMORY_OPERATION_STORE;
					v_output.memory_data := v_input.operand_2(7 downto 0) & v_input.operand_2(15 downto 8) & v_input.operand_2(23 downto 16) & v_input.operand_2(31 downto 24);
					v_output.memory_write_mask := "1111";
					v_output.memory_address := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_3));
					v_output.memory_size := (others => '0');
					v_output.sign_extend := '0';
					v_output.tag := v_input.tag;
					v_branch.indicator := '0';
					v_branch.address := (others => '0');
				elsif v_input.alu_function = ALU_FUNCTION_LOAD_BYTE or v_input.alu_function = ALU_FUNCTION_LOAD_BYTE_UNSIGNED or
				      v_input.alu_function = ALU_FUNCTION_LOAD_HALFWORD or v_input.alu_function = ALU_FUNCTION_LOAD_HALFWORD_UNSIGNED or
					  v_input.alu_function = ALU_FUNCTION_LOAD_WORD then
					v_output.valid := '1';
					v_output.act := '1';
					v_output.writeback_value := (others => '0');
					v_output.writeback_register := v_input.writeback_register;
					v_output.memory_operation := MEMORY_OPERATION_LOAD;
					v_output.memory_data := (others => '0');
					v_output.memory_write_mask := (others => '0');
					v_output.memory_address := std_logic_vector(unsigned(v_input.operand_1) + unsigned(v_input.operand_3));
					
					if v_input.alu_function = ALU_FUNCTION_LOAD_BYTE or v_input.alu_function = ALU_FUNCTION_LOAD_BYTE_UNSIGNED then
						v_output.memory_size := MEMORY_SIZE_BYTE;
					elsif v_input.alu_function = ALU_FUNCTION_LOAD_HALFWORD or v_input.alu_function = ALU_FUNCTION_LOAD_HALFWORD_UNSIGNED then
						v_output.memory_size := MEMORY_SIZE_HALFWORD;
					else
						v_output.memory_size := MEMORY_SIZE_WORD;
					end if;

					if v_input.alu_function = ALU_FUNCTION_LOAD_BYTE or v_input.alu_function = ALU_FUNCTION_LOAD_HALFWORD then
						v_output.sign_extend := '1';
					else
						v_output.sign_extend := '0';
					end if;

					v_output.tag := v_input.tag;
					v_branch.indicator := '0';
					v_branch.address := (others => '0');
				else
					-- TODO: this should never happen. Interrupt?
				end if;
			end if;


			-- TODO: DETECT TRAPS
			-- ==================
			v_trap := '0';


			-- COMMIT
			-- ======
			if v_trap = '1' then
				-- TODO
			elsif stall_in = '0' then
				-- commit output by placing it in the commit slot
				commit_slot <= v_output;

				-- commit branch
				branch_out.data <= v_branch;
				if v_branch.indicator = '1' then
					-- update stamp
					v_new_stamp := std_logic_vector(unsigned(stamp) + 1);
					stamp <= v_new_stamp;
					branch_out.stamp <= v_new_stamp;
				else
					branch_out.stamp <= (others => '0');
				end if;

				-- TODO: commit CSRs
			else
				branch_out <= DEFAULT_BRANCH_SIGNALS;
			end if;


			-- BUFFER INPUT
			-- ============
			if v_trap = '0' and (stall_in = '1' or v_stall = '1') then
				buffered_input <= v_input;
			else 
				buffered_input <= DEFAULT_REGISTER_READ_OUTPUT;
			end if;
		end if;
	end process;

end Behavioral;
