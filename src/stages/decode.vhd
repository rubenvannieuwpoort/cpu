library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity decode is
	port(
		clk: in std_logic;
		stall_in: in std_logic;
		input: in fetch_output_type;

		stall_out: out std_logic := '0';
		output: out decode_output_type := DEFAULT_DECODE_OUTPUT
	);
end decode;


architecture Behavioral of decode is
	signal buffered_input: fetch_output_type := DEFAULT_FETCH_OUTPUT;
begin
	stall_out <= buffered_input.valid;

	process(clk)
		variable v_input: fetch_output_type;
		variable v_output: decode_output_type;
	begin
		if rising_edge(clk) then
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if stall_in = '0' then
				-- output generation
				if v_input.valid = '1' then
					--variable v_imm: std_logic_vector(31 downto 0);
					--variable v_rs1: std_logic_vector(4 downto 0);
					--variable v_rs2: std_logic_vector(4 downto 0);
					--variable v_rsd: std_logic_vector(4 downto 0);
					--variable v_funct7: std_logic_vector(6 downto 0);
					--variable v_funct3: std_logic_vector(2 downto 0);
					--variable v_opcode: std_logic_vector(6 downto 0);

					--v_opcode := v_input.opcode(6 downto 0);

					---- R-type
					--v_funct7 := v_input.opcode(31 downto 25);
					--v_rs2 := v_input.opcode(24 downto 20);
					--v_rs1 := v_input.opcode(19 downto 15);
					--v_funct3 := v_input.opcode(14 downto 12);
					--v_rd := v_input.opcode(11 downto 7);

					---- I-type
					--v_imm = std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));  -- TODO: how to extend?
					--v_rs1 := v_input.opcode(19 downto 15);
					--v_funct3 := v_input.opcode(14 downto 12);
					--v_rd := v_input.opcode(11 downto 7);

					---- S-type
					--v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32)); -- TODO: extend
					--v_rs2 := v_input.opcode(24 downto 20);
					--v_rs1 := v_input.opcode(19 downto 15);
					--v_funct3 := v_input.opcode(14 downto 12);

					---- B-type
					--v_imm := std_logic_vector(resize(signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"), 32)); -- TODO: extend
					--v_rs2 := v_input.opcode(24 downto 20);
					--v_rs1 := v_input.opcode(19 downto 15);
					--v_funct3 := v_input.opcode(14 downto 12);

					---- U-type
					--v_imm := v_input.opcode(31 downto 12) & "000000000000";
					--v_rd := v_input.opcode(11 downto 7);

					---- J-type
					--v_imm := std_logic_vector(resize(signed(v_input.opcode(31) & v_input.opcode(19 downto 12) & v_input.opcode(20) & v_input.opcode(20) & v_input.opcode(30 downto 25) & v_input.opcode(24 downto 12) & "0"), 32))
					--v_rd := v_input.opcode(11 downto 7);


					if v_input.opcode(6 downto 0) = "0110111" then
						-- LUI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_immediate := v_input.opcode(31 downto 12) & "000000000000";
						v_output.operand_1_register := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010111" then
						-- AUIPC (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := v_input.pc;
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := v_input.opcode(31 downto 12) & "000000000000";
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1101111" then
						-- JAL (done)
						-- puts pc in op1, offset in op2, and pc_next in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := v_input.pc;
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31) & v_input.opcode(19 downto 12) & v_input.opcode(20) & v_input.opcode(20) & v_input.opcode(30 downto 25) & v_input.opcode(24 downto 12) & "0"), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := v_input.pc_next;
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_JAL;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100111" and v_input.opcode(14 downto 12) = "000" then
						-- JALR (done)
						-- puts rs1 in op1, offset in op2, and pc_next in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := v_input.pc_next;
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_JAL;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "000" then
						-- BEQ (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BEQ;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "001" then
						-- BNE (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BNE;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "100" then
						-- BLT (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BLT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "101" then
						-- BGE (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BGE;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "110" then
						-- BLTU (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BLTU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "111" then
						-- BGEU (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BGEU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					-- TODO (MEMORY STUFF)
					--elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "000" then
					--	-- LB (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));  -- TODO: how to extend?
					--	v_rs1 := v_input.opcode(19 downto 15);
					--	v_rd := v_input.opcode(11 downto 7);
					--elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "001" then
					--	-- LH (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));  -- TODO: how to extend?
					--	v_rs1 := v_input.opcode(19 downto 15);
					--	v_rd := v_input.opcode(11 downto 7);
					--elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "010" then
					--	-- LW (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));  -- TODO: how to extend?
					--	v_rs1 := v_input.opcode(19 downto 15);
					--	v_rd := v_input.opcode(11 downto 7);
					--elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "100" then
					--	-- LBU (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));  -- TODO: how to extend?
					--	v_rs1 := v_input.opcode(19 downto 15);
					--	v_rd := v_input.opcode(11 downto 7);
					--elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "101" then
					--	-- LHU (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));  -- TODO: how to extend?
					--	v_rs1 := v_input.opcode(19 downto 15);
					--	v_rd := v_input.opcode(11 downto 7);
					--elsif v_input.opcode(6 downto 0) = "0100011" and v_input.opcode(14 downto 12) = "000" then
					--	-- SB (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32)); -- TODO: extend
					--	v_rs2 := v_input.opcode(24 downto 20);
					--	v_rs1 := v_input.opcode(19 downto 15);
					--elsif v_input.opcode(6 downto 0) = "0100011" and v_input.opcode(14 downto 12) = "001" then
					--	-- SH (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32)); -- TODO: extend
					--	v_rs2 := v_input.opcode(24 downto 20);
					--	v_rs1 := v_input.opcode(19 downto 15);
					--elsif v_input.opcode(6 downto 0) = "0100011" and v_input.opcode(14 downto 12) = "010" then
					--	-- SW (TODO)
					--	v_imm := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32)); -- TODO: extend
					--	v_rs2 := v_input.opcode(24 downto 20);
					--	v_rs1 := v_input.opcode(19 downto 15);
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "000" then
						-- ADDI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "010" then
						-- SLTI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "011" then
						-- SLTIU (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLTU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "100" then
						-- XORI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_XOR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "110" then
						-- ORI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_OR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "111" then
						-- ANDI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_AND;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "001" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLLI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_LEFT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0000000" then
						-- SRLI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0100000" then
						-- SRAI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "000" and v_input.opcode(31 downto 25) = "0000000" then
						-- ADD (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "000" and v_input.opcode(31 downto 25) = "0100000" then
						-- SUB (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SUB;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "001" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLL (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_LEFT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "010" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLT (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "011" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLTU (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLTU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "100" and v_input.opcode(31 downto 25) = "0000000" then
						-- XOR (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_XOR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0000000" then
						-- SRL (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0100000" then
						-- SRA (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "110" and v_input.opcode(31 downto 25) = "0000000" then
						-- OR (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_OR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "111" and v_input.opcode(31 downto 25) = "0000000" then
						-- AND (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_AND;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0001111" and v_input.opcode(14 downto 12) = "000" then
						-- FENCE (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "00000000000000000000000001110011" then
						-- ECALL (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(31 downto 0) = "00000000000100000000000001110011" then
						-- EBREAK (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "001" then
						-- CSRRW
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRW;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "101" then
						-- CSRRWI
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := "000000000000000000000000000" & v_input.opcode(19 downto 15);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRW;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "010" then
						-- CSRRS
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRS;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "110" then
						-- CSRRSI
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := "000000000000000000000000000" & v_input.opcode(19 downto 15);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRS;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "011" then
						-- CSRRC
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRC;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "111" then
						-- CSRRCI
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := "000000000000000000000000000" & v_input.opcode(19 downto 15);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRC;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(31 downto 0) = "00110000001000000000000001110011" then
						-- TODO: MRET
					elsif v_input.opcode(31 downto 0) = "00010000010100000000000001110011" then
						-- TODO: WFI
					else
						v_output := DEFAULT_DECODE_OUTPUT;
						v_output.illegal := '1';
						v_output.tag := v_input.tag;
					end if;
				else
					v_output := DEFAULT_DECODE_OUTPUT;
				end if;
				
				output <= v_output;
			end if;

			if v_input.valid = '1' and stall_in = '1' then
				buffered_input <= v_input;
			else
				buffered_input <= DEFAULT_FETCH_OUTPUT;
			end if;
		end if;
	end process;

end Behavioral;
