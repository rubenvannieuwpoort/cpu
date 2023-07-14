library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.stages_interfaces.all;


entity decode is
	port(
		clk: in std_logic;
		hold_in: in std_logic;
		input: in fetch_output_type;

		hold_out: out std_logic := '0';
		output: out decode_output_type := DEFAULT_DECODE_OUTPUT
	);
end decode;


architecture Behavioral of decode is
	signal buffered_input: fetch_output_type := DEFAULT_FETCH_OUTPUT;
	signal hold: std_logic := '0';
begin

	process(clk)
		variable v_wait: std_logic;
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

			v_wait := '0';
			if hold_in = '0' then
				-- output generation
				if v_input.valid = '1' then
					v_output.tag := v_input.tag;

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
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_IMMEDIATE;
						v_output.operand_1_immediate <= v_input.opcode(31 downto 12) & "000000000000";
						v_output.operand_1_register <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register: v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010111" then
						-- AUIPC (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_IMMEDIATE;
						v_output.operand_1_register <= (others => '0');
						v_output.operand_1_immediate <= pc;
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= v_input.opcode(31 downto 12) & "000000000000";
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1101111" then
						-- JAL (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_IMMEDIATE;
						v_output.operand_1_register <= (others => '0');
						v_output.operand_1_immediate <= pc;
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31) & v_input.opcode(19 downto 12) & v_input.opcode(20) & v_input.opcode(20) & v_input.opcode(30 downto 25) & v_input.opcode(24 downto 12) & "0"), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= pc_next;
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_JAL;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100111" and v_input(14 downto 12) = "000" then
						-- JALR (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= pc_next;
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_JAL;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input(14 downto 12) = "000" then
						-- BEQ (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= std_logic_vector(unsigned(pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_BEQ;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input(14 downto 12) = "001" then
						-- BNE (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= std_logic_vector(unsigned(pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_BNE;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input(14 downto 12) = "100" then
						-- BLT (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= std_logic_vector(unsigned(pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_BLT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input(14 downto 12) = "101" then
						-- BGE (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= std_logic_vector(unsigned(pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_BGE;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input(14 downto 12) = "110" then
						-- BLTU (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= std_logic_vector(unsigned(pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_BLTU;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input(14 downto 12) = "111" then
						-- BGEU (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= std_logic_vector(unsigned(pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_BGEU;
						v_output.tag <= v_input.tag;
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
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "010" then
						-- SLTI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SLT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "011" then
						-- SLTIU (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SLTU;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "100" then
						-- XORI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_XOR;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "110" then
						-- ORI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_OR;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "111" then
						-- ANDI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_AND;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "001" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLLI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SHIFT_LEFT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0000000" then
						-- SRLI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SHIFT_RIGHT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0100000" then
						-- SRAI (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "000" and v_input.opcode(31 downto 25) = "0000000" then
						-- ADD (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "000" and v_input.opcode(31 downto 25) = "0100000" then
						-- SUB (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SUB;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "001" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLL (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SHIFT_LEFT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "010" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLT (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SLT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "011" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLTU (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SLTU;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "100" and v_input.opcode(31 downto 25) = "0000000" then
						-- XOR (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_XOR;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0000000" then
						-- SRL (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_SHIFT_RIGHT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0100000" then
						-- SRA (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "110" and v_input.opcode(31 downto 25) = "0000000" then
						-- OR (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_OR;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "111" and v_input.opcode(31 downto 25) = "0000000" then
						-- AND (done)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_REGISTER;
						v_output.operand_1_register <= v_input.opcode(19 downto 15);
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_REGISTER;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= v_input.opcode(24 downto 20);
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= v_input.opcode(11 downto 7);
						v_output.alu_function <= ALU_FUNCTION_AND;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "0001111" and v_input.opcode(14 downto 12) = "000" then
						-- FENCE (implemented as NOP)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_IMMEDIATE;
						v_output.operand_1_register <= (others => '0');
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= (others => '0');
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(6 downto 0) = "00000000000000000000000001110011" and v_input.opcode(14 downto 12) = "" then
						-- ECALL (implemented as NOP)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_IMMEDIATE;
						v_output.operand_1_register <= (others => '0');
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= (others => '0');
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					elsif v_input.opcode(31 downto 0) = "00000000000100000000000001110011" and v_input.opcode(14 downto 12) = "" then
						-- EBREAK (implemented as NOP)
						v_output.valid <= '1';
						v_output.operand_1_type <= TYPE_IMMEDIATE;
						v_output.operand_1_register <= (others => '0');
						v_output.operand_1_immediate <= (others => '0');
						v_output.operand_2_type <= TYPE_IMMEDIATE;
						v_output.operand_2_immediate <= (others => '0');
						v_output.operand_2_3_register <= (others => '0');
						v_output.operand_3_type <= TYPE_IMMEDIATE;
						v_output.operand_3_immediate <= (others => '0');
						v_output.writeback_register <= (others => '0');
						v_output.alu_function <= ALU_FUNCTION_ADD;
						v_output.tag <= v_input.tag;
					else
						-- invalid instruction
						-- TODO: figure this out (interrupt?)
						v_output := DEFAULT_DECODE_OUTPUT;
					end if;
				
				if v_wait = '1' then
					v_output := DEFAULT_DECODE_OUTPUT;
				else
					buffered_input <= DEFAULT_FETCH_OUTPUT;
				end if;
				
				output <= v_output;
			end if;

			if v_input.valid = '1' and (hold_in = '1' or v_wait = '1') then
				buffered_input <= v_input;
			end if;

			hold_out <= hold_in or v_wait;
		end if;
	end process;

end Behavioral;
