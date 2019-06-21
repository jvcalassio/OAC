`ifndef PARAM
	`include "../Parametros.v"
`endif

//*
// * Bloco de Controle UNICICLO
// *
 

 module Control_UNI(
    input  [31:0] iInstr, 
    output    	 	oOrigAULA, 
	 output 			oOrigBULA, 
	 output			oRegWrite, 
	 output			oMemWrite, 
	 output			oMemRead,
	 output [ 2:0]	oMem2Reg, 
	 output [ 2:0]	oOrigPC,
	 output [ 4:0] oALUControl,
	 // csregisters
	 output 			oCSRegWrite,
	 output 			oUCAUSEWrite,
	 output			oUEPCWrite,
	 output [ 1:0]	oCSType,
	 output [31:0]	oUCAUSEData,
	 output [ 2:0] oCSRWSource,
	 output			oBreak
`ifdef RV32IMF
	 ,
	 output       oFRegWrite,    // Controla a escrita no FReg
	 output [4:0] oFPALUControl, // Controla a operacao a ser realizda pela FPULA
	 output       oOrigAFPALU,   // Controla se a entrada A da FPULA  float ou int
	 output       oFPALU2Reg,    // Controla a escrita no registrador de inteiros (origem FPULA ou nao?)
	 output       oFWriteData,   // Controla a escrita nos FRegisters (origem FPALU(0) : origem memoria(1)?)
	 output       oWrite2Mem,     // Controla a escrita na memoria (origem Register(0) : FRegister(1))
	 output		  oFPstart			// controla/liga a FPULA
`endif
);


wire [6:0] Opcode = iInstr[ 6: 0];
wire [2:0] Funct3	= iInstr[14:12];
wire [6:0] Funct7	= iInstr[31:25];
//`ifdef RV32IMF
wire [4:0] Rs2    = iInstr[24:20]; // Para os converts de ponto flutuante e CSR
//`endif

always @(*)
	case(Opcode)
		OPC_LOAD:
			begin
				oOrigAULA	 <= 1'b0;
				oOrigBULA 	 <= 1'b1;
				oRegWrite	 <= 1'b1;
				oMemWrite	 <= 1'b0; 
				oMemRead 	 <= 1'b1; 
				oALUControl	 <= OPADD;
				oMem2Reg 	 <= 3'b010;
				oOrigPC		 <= 3'b000;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
		OPC_OPIMM:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b1;
				oRegWrite	<= 1'b1;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oMem2Reg 	<= 3'b000;
				oOrigPC		<= 3'b000;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
				case (Funct3)
					FUNCT3_ADD:			oALUControl <= OPADD;
					FUNCT3_SLL:			oALUControl <= OPSLL;
					FUNCT3_SLT:			oALUControl <= OPSLT;
					FUNCT3_SLTU:		oALUControl	<= OPSLTU;
					FUNCT3_XOR:			oALUControl <= OPXOR;
					FUNCT3_SRL,
					FUNCT3_SRA:
						if(Funct7==FUNCT7_SRA)  oALUControl <= OPSRA;
						else 							oALUControl <= OPSRL;
					FUNCT3_OR:			oALUControl <= OPOR;
					FUNCT3_AND:			oALUControl <= OPAND;	
					default: // instrucao invalida
						begin
							oOrigAULA  	<= 1'b0;
							oOrigBULA 	<= 1'b0;
							oRegWrite	<= 1'b0;
							oMemWrite	<= 1'b0; 
							oMemRead 	<= 1'b0; 
							oALUControl	<= OPNULL;
							oMem2Reg 	<= 3'b000;
							oOrigPC		<= 3'b000;
`ifdef RV32IMF
							oFPALU2Reg    <= 1'b0;
							oFPALUControl <= OPNULL;
							oFRegWrite    <= 1'b0;
							oOrigAFPALU   <= 1'b0;
							oFWriteData   <= 1'b0;
							oWrite2Mem    <= 1'b0;
							oFPstart		  <= 1'b0;
`endif
							// dispara tratamento de excessao
							oCSRegWrite  <= ON;
							oCSRWSource  <= 3'b110; // grava instrucao em uval
							oUCAUSEWrite <= ON;
							oUCAUSEData  <= 32'h00000002; // causa = instr invalida
							oUEPCWrite 	 <= ON;
							oCSType		 <= 2'b01; // tipo cs excessao
							oOrigPC		 <= 3'b100; // pc vem do csreg utvec
						end				
				endcase
			end
			
		OPC_AUIPC:
			begin
				oOrigAULA  	<= 1'b1;
				oOrigBULA 	<= 1'b1;
				oRegWrite	<= 1'b1;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPADD;
				oMem2Reg 	<= 3'b000;
				oOrigPC		<= 3'b000;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
			
		OPC_STORE:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b1;
				oRegWrite	<= 1'b0;
				oMemWrite	<= 1'b1; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPADD;
				oMem2Reg 	<= 3'b000;
				oOrigPC		<= 3'b000;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
		
		OPC_RTYPE:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b0;
				oRegWrite	<= 1'b1;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oMem2Reg 	<= 3'b000;
				oOrigPC		<= 3'b000;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			case (Funct7)
				FUNCT7_ADD,  // ou qualquer outro 7'b0000000
				FUNCT7_SUB:	 // SUB ou SRA			
					case (Funct3)
						FUNCT3_ADD,
						FUNCT3_SUB:
							if(Funct7==FUNCT7_SUB)   oALUControl <= OPSUB;
							else 							 oALUControl <= OPADD;
						FUNCT3_SLL:			oALUControl <= OPSLL;
						FUNCT3_SLT:			oALUControl <= OPSLT;
						FUNCT3_SLTU:		oALUControl	<= OPSLTU;
						FUNCT3_XOR:			oALUControl <= OPXOR;
						FUNCT3_SRL,
						FUNCT3_SRA:
							if(Funct7==FUNCT7_SRA)  oALUControl <= OPSRA;
							else 							oALUControl <= OPSRL;
						FUNCT3_OR:			oALUControl <= OPOR;
						FUNCT3_AND:			oALUControl <= OPAND;
						default: // instrucao invalida
							begin
								oOrigAULA  	<= 1'b0;
								oOrigBULA 	<= 1'b0;
								oRegWrite	<= 1'b0;
								oMemWrite	<= 1'b0; 
								oMemRead 	<= 1'b0; 
								oALUControl	<= OPNULL;
								oMem2Reg 	<= 3'b000;
								oOrigPC		<= 3'b000;
`ifdef RV32IMF
								oFPALU2Reg    <= 1'b0;
								oFPALUControl <= OPNULL;
								oFRegWrite    <= 1'b0;
								oOrigAFPALU   <= 1'b0;
								oFWriteData   <= 1'b0;
								oWrite2Mem    <= 1'b0;
								oFPstart		  <= 1'b0;
`endif
								// dispara tratamento de excessao
								oCSRegWrite  <= ON;
								oCSRWSource  <= 3'b110; // grava instrucao em uval
								oUCAUSEWrite <= ON;
								oUCAUSEData  <= 32'h00000002; // causa = instr invalida
								oUEPCWrite 	 <= ON;
								oCSType		 <= 2'b01; // tipo cs excessao
								oOrigPC		 <= 3'b100; // pc vem do csreg utvec
							end				
					endcase

`ifndef RV32I					
				FUNCT7_MULDIV:	
					case (Funct3)
						FUNCT3_MUL:			oALUControl <= OPMUL;
						FUNCT3_MULH:		oALUControl <= OPMULH;
						FUNCT3_MULHSU:		oALUControl <= OPMULHSU;
						FUNCT3_MULHU:		oALUControl <= OPMULHU;
						FUNCT3_DIV:			oALUControl <= OPDIV;
						FUNCT3_DIVU:		oALUControl <= OPDIVU;
						FUNCT3_REM:			oALUControl <= OPREM;
						FUNCT3_REMU:		oALUControl <= OPREMU;	
						default: // instrucao invalida
							begin
								oOrigAULA  	<= 1'b0;
								oOrigBULA 	<= 1'b0;
								oRegWrite	<= 1'b0;
								oMemWrite	<= 1'b0; 
								oMemRead 	<= 1'b0; 
								oALUControl	<= OPNULL;
								oMem2Reg 	<= 3'b000;
								oOrigPC		<= 3'b000;
`ifdef RV32IMF
								oFPALU2Reg    <= 1'b0;
								oFPALUControl <= OPNULL;
								oFRegWrite    <= 1'b0;
								oOrigAFPALU   <= 1'b0;
								oFWriteData   <= 1'b0;
								oWrite2Mem    <= 1'b0;
								oFPstart		  <= 1'b0;
`endif
								// dispara tratamento de excessao
								oCSRegWrite  <= ON;
								oCSRWSource  <= 3'b110; // grava instrucao em uval
								oUCAUSEWrite <= ON;
								oUCAUSEData  <= 32'h00000002; // causa = instr invalida
								oUEPCWrite 	 <= ON;
								oCSType		 <= 2'b01; // tipo cs excessao
								oOrigPC		 <= 3'b100; // pc vem do csreg utvec
							end				
					endcase
`endif			
				default: // instrucao invalida
					begin
						oOrigAULA  	<= 1'b0;
						oOrigBULA 	<= 1'b0;
						oRegWrite	<= 1'b0;
						oMemWrite	<= 1'b0; 
						oMemRead 	<= 1'b0; 
						oALUControl	<= OPNULL;
						oMem2Reg 	<= 3'b000;
						oOrigPC		<= 3'b000;
`ifdef RV32IMF
						oFPALU2Reg    <= 1'b0;
						oFPALUControl <= OPNULL;
						oFRegWrite    <= 1'b0;
						oOrigAFPALU   <= 1'b0;
						oFWriteData   <= 1'b0;
						oWrite2Mem    <= 1'b0;
						oFPstart		  <= 1'b0;
`endif
						// dispara tratamento de excessao
						oCSRegWrite  <= ON;
						oCSRWSource  <= 3'b110; // grava instrucao em uval
						oUCAUSEWrite <= ON;
						oUCAUSEData  <= 32'h00000002; // causa = instr invalida
						oUEPCWrite 	 <= ON;
						oCSType		 <= 2'b01; // tipo cs excessao
						oOrigPC		 <= 3'b100; // pc vem do csreg utvec
					end				
			endcase			
		end
		
		OPC_LUI:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b1;
				oRegWrite	<= 1'b1;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPLUI;
				oMem2Reg 	<= 3'b000;
				oOrigPC		<= 3'b000;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
			
		OPC_BRANCH:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b0;
				oRegWrite	<= 1'b0;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPADD;
				oMem2Reg 	<= 3'b000;
				oOrigPC		<= 3'b001;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
			
		OPC_JALR:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b0;
				oRegWrite	<= 1'b1;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPADD;
				oMem2Reg 	<= 3'b001;
				oOrigPC		<= 3'b011;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
		
		OPC_JAL:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b0;
				oRegWrite	<= 1'b1;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPADD;
				oMem2Reg 	<= 3'b001;
				oOrigPC		<= 3'b010;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
			end
			
`ifdef RV32IMF
		OPC_FRTYPE: // OPCODE de todas as intruções tipo R ponto flutuante
			begin
				oOrigAULA   <= 1'b0;   // Importam as entradas da ULA?
				oOrigBULA   <= 1'b0;	  // Importam as entradas da ULA?
				oMemWrite	<= 1'b0;   // Nao escreve na memoria
				oMemRead 	<= 1'b0;   // Nao le da memoria
				oALUControl	<= OPNULL; // Nao realiza operacoes na ULA
				oMem2Reg 	<= 3'b000;  // Nao importa o que sera escrito do mux mem2reg?
				oOrigPC		<= 3'b000;  // PC+4
				oFWriteData <= 1'b0;   // Instrucoes do tipo R sempre escrevem no banco de registradores a partir do resultado da FPALU
				oWrite2Mem  <= 1'b0;   // Instrucoes do tipo R nao escrevem na memoria
				oFPstart		<= 1'b1;		// habilita a FPULA
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
				
				case(Funct7)
					FUNCT7_FADD_S:
						begin
							oRegWrite     <= 1'b0;   // Nao habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b0;   // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPADD; // Realiza um fadd
							oFRegWrite    <= 1'b1;   // Habilita escrita no registrador de float
							oOrigAFPALU   <= 1'b1;   // Rs1 eh um float 
						end

					FUNCT7_FSUB_S:
						begin
							oRegWrite     <= 1'b0;   // Nao habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b0;   // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPSUB; // Realiza um fsub
							oFRegWrite    <= 1'b1;   // Habilita escrita no registrador de float
							oOrigAFPALU   <= 1'b1;   // Rs1 eh um float 
						end
						
					FUNCT7_FMUL_S:
						begin
							oRegWrite     <= 1'b0;   // Nao habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b0;   // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPMUL; // Realiza um fmul
							oFRegWrite    <= 1'b1;   // Habilita escrita no registrador de float
							oOrigAFPALU   <= 1'b1;   // Rs1 eh um float 
						end
					
					FUNCT7_FDIV_S:
						begin
							oRegWrite     <= 1'b0;   // Nao habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b0;   // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPDIV; // Realiza um fdiv
							oFRegWrite    <= 1'b1;   // Habilita escrita no registrador de float
							oOrigAFPALU   <= 1'b1;   // Rs1 eh um float 
						end
						
					FUNCT7_FSQRT_S: // OBS.: Rs2 nao importa?
						begin
							oRegWrite     <= 1'b0;   // Nao habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b0;   // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPSQRT; // Realiza um fsqrt
							oFRegWrite    <= 1'b1;   // Habilita escrita no registrador de float
							oOrigAFPALU   <= 1'b1;   // Rs1 eh um float 
						end
						
					FUNCT7_FMV_S_X:
						begin
							oRegWrite     <= 1'b0;      // Nao habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b0;      // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPMV;     // Realiza um fmv.s.x
							oFRegWrite    <= 1'b1;      // Habilita escrita no registrador de float
							oOrigAFPALU   <= 1'b0;      // Rs1 eh um int 
						end
						
					FUNCT7_FMV_X_S:
						begin
							oRegWrite     <= 1'b1;      // Habilita escrita em registrador de inteiros 
							oFPALU2Reg    <= 1'b1;      // Nao importa o que escreve em registrador de inteiros
							oFPALUControl <= FOPMV;     // Realiza um fmv.x.s
							oFRegWrite    <= 1'b0;      // Desabilita escrita no registrador de float
							oOrigAFPALU   <= 1'b1;      // Rs1 eh um float 
						end
						
					FUNCT7_FSIGN_INJECT:
						begin
							oRegWrite     <= 1'b0;
							oFPALU2Reg    <= 1'b0;
							oFRegWrite    <= 1'b1;
							oOrigAFPALU   <= 1'b1;
							case (Funct3)
								FUNCT3_FSGNJ_S:  oFPALUControl <= FOPSGNJ;
								FUNCT3_FSGNJN_S: oFPALUControl <= FOPSGNJN;
								FUNCT3_FSGNJX_S: oFPALUControl <= FOPSGNJX;
								default: // instrucao invalida
									begin
										oOrigAULA  	  <= 1'b0;
										oOrigBULA 	  <= 1'b0;
										oRegWrite	  <= 1'b0;
										oMemWrite	  <= 1'b0; 
										oMemRead 	  <= 1'b0; 
										oALUControl	  <= OPNULL;
										oMem2Reg 	  <= 3'b000;
										oOrigPC		  <= 3'b000;
										oFPALU2Reg    <= 1'b0;
										oFPALUControl <= OPNULL;
										oFRegWrite    <= 1'b0;
										oOrigAFPALU   <= 1'b0;
										oFWriteData   <= 1'b0;
										oWrite2Mem    <= 1'b0;
										// dispara tratamento de excessao
										oCSRegWrite  <= ON;
										oCSRWSource  <= 3'b110; // grava instrucao em uval
										oUCAUSEWrite <= ON;
										oUCAUSEData  <= 32'h00000002; // causa = instr invalida
										oUEPCWrite 	 <= ON;
										oCSType		 <= 2'b01; // tipo cs excessao
										oOrigPC		 <= 3'b100; // pc vem do csreg utvec
									end
							endcase
						end
						
					FUNCT7_MAX_MIN_S:
						begin
							oRegWrite     <= 1'b0;
							oFPALU2Reg    <= 1'b0;
							oFRegWrite    <= 1'b1;
							oOrigAFPALU   <= 1'b1;
							case (Funct3)
								FUNCT3_FMAX_S: oFPALUControl <= FOPMAX;
								FUNCT3_FMIN_S: oFPALUControl <= FOPMIN;
								default: // instrucao invalida
									begin
										oOrigAULA  	  <= 1'b0;
										oOrigBULA 	  <= 1'b0;
										oRegWrite	  <= 1'b0;
										oMemWrite	  <= 1'b0; 
										oMemRead 	  <= 1'b0; 
										oALUControl	  <= OPNULL;
										oMem2Reg 	  <= 3'b000;
										oOrigPC		  <= 3'b000;
										oFPALU2Reg    <= 1'b0;
										oFPALUControl <= OPNULL;
										oFRegWrite    <= 1'b0;
										oOrigAFPALU   <= 1'b0;
										oFWriteData   <= 1'b0;
										oWrite2Mem    <= 1'b0;
										// dispara tratamento de excessao
										oCSRegWrite  <= ON;
										oCSRWSource  <= 3'b110; // grava instrucao em uval
										oUCAUSEWrite <= ON;
										oUCAUSEData  <= 32'h00000002; // causa = instr invalida
										oUEPCWrite 	 <= ON;
										oCSType		 <= 2'b01; // tipo cs excessao
										oOrigPC		 <= 3'b100; // pc vem do csreg utvec
									end
							endcase
						end
						
					FUNCT7_FCOMPARE:
						begin
							oRegWrite     <= 1'b1;
							oFPALU2Reg    <= 1'b1;
							oFRegWrite    <= 1'b0;
							oOrigAFPALU   <= 1'b1;
							case (Funct3)
								FUNCT3_FEQ_S: oFPALUControl <= FOPCEQ;
								FUNCT3_FLE_S: oFPALUControl <= FOPCLE;
								FUNCT3_FLT_S: oFPALUControl <= FOPCLT;
								default: // instrucao invalida
									begin
										oOrigAULA  	  <= 1'b0;
										oOrigBULA 	  <= 1'b0;
										oRegWrite	  <= 1'b0;
										oMemWrite	  <= 1'b0; 
										oMemRead 	  <= 1'b0; 
										oALUControl	  <= OPNULL;
										oMem2Reg 	  <= 3'b000;
										oOrigPC		  <= 3'b000;
										oFPALU2Reg    <= 1'b0;
										oFPALUControl <= OPNULL;
										oFRegWrite    <= 1'b0;
										oOrigAFPALU   <= 1'b0;
										oFWriteData   <= 1'b0;
										oWrite2Mem    <= 1'b0;
										// dispara tratamento de excessao
										oCSRegWrite  <= ON;
										oCSRWSource  <= 3'b110; // grava instrucao em uval
										oUCAUSEWrite <= ON;
										oUCAUSEData  <= 32'h00000002; // causa = instr invalida
										oUEPCWrite 	 <= ON;
										oCSType		 <= 2'b01; // tipo cs excessao
										oOrigPC		 <= 3'b100; // pc vem do csreg utvec
									end
							endcase
						end
						
					FUNCT7_FCVT_S_W_WU:
						begin
							oRegWrite     <= 1'b0;
							oFPALU2Reg    <= 1'b0;
							oFRegWrite    <= 1'b1;
							oOrigAFPALU   <= 1'b0;
							case (Rs2)
								RS2_FCVT_S_W:  oFPALUControl <= FOPCVTSW;
								RS2_FCVT_S_WU: oFPALUControl <= FOPCVTSWU;
								default: // instrucao invalida
									begin
										oOrigAULA  	  <= 1'b0;
										oOrigBULA 	  <= 1'b0;
										oRegWrite	  <= 1'b0;
										oMemWrite	  <= 1'b0; 
										oMemRead 	  <= 1'b0; 
										oALUControl	  <= OPNULL;
										oMem2Reg 	  <= 3'b000;
										oOrigPC		  <= 3'b000;
										oFPALU2Reg    <= 1'b0;
										oFPALUControl <= OPNULL;
										oFRegWrite    <= 1'b0;
										oOrigAFPALU   <= 1'b0;
										oFWriteData   <= 1'b0;
										oWrite2Mem    <= 1'b0;
										// dispara tratamento de excessao
										oCSRegWrite  <= ON;
										oCSRWSource  <= 3'b110; // grava instrucao em uval
										oUCAUSEWrite <= ON;
										oUCAUSEData  <= 32'h00000002; // causa = instr invalida
										oUEPCWrite 	 <= ON;
										oCSType		 <= 2'b01; // tipo cs excessao
										oOrigPC		 <= 3'b100; // pc vem do csreg utvec
									end
							endcase
						end
						
					FUNCT7_FCVT_W_WU_S:
						begin
							oRegWrite     <= 1'b1;
							oFPALU2Reg    <= 1'b1;
							oFRegWrite    <= 1'b0;
							oOrigAFPALU   <= 1'b1;
							case (Rs2)
								RS2_FCVT_W_S:  oFPALUControl <= FOPCVTWS;
								RS2_FCVT_WU_S: oFPALUControl <= FOPCVTWUS;
								default: // instrucao invalida
									begin
										oOrigAULA  	  <= 1'b0;
										oOrigBULA 	  <= 1'b0;
										oRegWrite	  <= 1'b0;
										oMemWrite	  <= 1'b0; 
										oMemRead 	  <= 1'b0; 
										oALUControl	  <= OPNULL;
										oMem2Reg 	  <= 3'b000;
										oOrigPC		  <= 3'b000;
										oFPALU2Reg    <= 1'b0;
										oFPALUControl <= OPNULL;
										oFRegWrite    <= 1'b0;
										oOrigAFPALU   <= 1'b0;
										oFWriteData   <= 1'b0;
										oWrite2Mem    <= 1'b0;
										// dispara tratamento de excessao
										oCSRegWrite  <= ON;
										oCSRWSource  <= 3'b110; // grava instrucao em uval
										oUCAUSEWrite <= ON;
										oUCAUSEData  <= 32'h00000002; // causa = instr invalida
										oUEPCWrite 	 <= ON;
										oCSType		 <= 2'b01; // tipo cs excessao
										oOrigPC		 <= 3'b100; // pc vem do csreg utvec
									end
							endcase
						end
						
					default: // instrucao invalida
					  begin
							oOrigAULA  	  <= 1'b0;
							oOrigBULA 	  <= 1'b0;
							oRegWrite	  <= 1'b0;
							oMemWrite	  <= 1'b0; 
							oMemRead 	  <= 1'b0; 
							oALUControl	  <= OPNULL;
							oMem2Reg 	  <= 3'b000;
							oOrigPC		  <= 3'b000;
							oFPALU2Reg    <= 1'b0;
							oFPALUControl <= OPNULL;
							oFRegWrite    <= 1'b0;
							oOrigAFPALU   <= 1'b0;
							oFWriteData   <= 1'b0;
							oWrite2Mem    <= 1'b0;
							oFPstart		  <= 1'b0;
							// dispara tratamento de excessao
							oCSRegWrite  <= ON;
							oCSRWSource  <= 3'b110; // grava instrucao em uval
							oUCAUSEWrite <= ON;
							oUCAUSEData  <= 32'h00000002; // causa = instr invalida
							oUEPCWrite 	 <= ON;
							oCSType		 <= 2'b01; // tipo cs excessao
							oOrigPC		 <= 3'b100; // pc vem do csreg utvec
					  end
						
				endcase				
			end
			
		OPC_FLOAD: //OPCODE do FLW
			begin
				// Sinais int
				oOrigAULA	  <= 1'b0;
				oOrigBULA 	  <= 1'b1;
				oRegWrite	  <= 1'b0;
				oMemWrite	  <= 1'b0; 
				oMemRead 	  <= 1'b1; 
				oALUControl	  <= OPADD;
				oMem2Reg 	  <= 3'b010;
				oOrigPC		  <= 3'b000;
				// Sinais float
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b1;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b1;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
			end
			
		OPC_FSTORE:
			begin
				// Sinais int
				oOrigAULA  	  <= 1'b0;
				oOrigBULA 	  <= 1'b1;
				oRegWrite	  <= 1'b0;
				oMemWrite	  <= 1'b1; 
				oMemRead 	  <= 1'b0; 
				oALUControl	  <= OPADD;
				oMem2Reg 	  <= 3'b000;
				oOrigPC		  <= 3'b000;
				// Sinais float
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b1;
				oFPstart		  <= 1'b0; 
				// Sinais CSR
				oCSRegWrite  <= OFF;
				oCSRWSource  <= 3'b000;
				oUCAUSEWrite <= OFF;
				oUEPCWrite 	 <= OFF;
				oCSType		 <= 2'b00;
				oUCAUSEData  <= ZERO;
				oBreak		 <= 1'b0;
			end
		
`endif
	  OPC_URET:
			begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b0;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPNULL;
				oBreak		<= 1'b0;
				
			`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
			`endif
				case(Funct3)
					FUNCT3_ECALL:
						begin
							case(Rs2)
								RS2_ECALL: // ecall
									begin
										oCSRegWrite		<= OFF; // nao escreve em CSR alem de UEPC e UCAUSE
										oCSRWSource  	<= 3'b000;
										oUCAUSEWrite 	<= ON; // escreve em ucause
										oUCAUSEData 	<= 32'h00000008; // causa = ecall
										oUEPCWrite 		<= ON; // escreve em uepc
										oMem2Reg 		<= 3'b000; // nao escreve em registradores int
										oRegWrite		<= 1'b0;
										oOrigPC 			<= 3'b100; // pc vem do csreg
										oCSType 			<= 2'b01; // tipo excessao
									end
								RS2_URET: // uret
									begin
										oCSRegWrite 	<= OFF; // nao escreve nos CSR
										oCSRWSource  	<= 3'b000;
										oUCAUSEWrite 	<= OFF; // nao escreve ucause
										oUCAUSEData 	<= ZERO;
										oUEPCWrite 		<= OFF; // nao escreve uepc
										oMem2Reg 		<= 3'b000; // nao escreve em registradores int
										oRegWrite		<= 1'b0;
										oOrigPC 			<= 3'b100; // pc vem do csreg
										oCSType 			<= 2'b10; // tipo uret
									end
								RS2_EBREAK:	 // ebreak
									begin
										oCSRegWrite		<= OFF;
										oCSRWSource		<= 3'b000;
										oUCAUSEWrite	<= OFF;
										oUCAUSEData		<= ZERO;
										oUEPCWrite		<= OFF;
										oMem2Reg			<= 3'b000;
										oRegWrite		<= 1'b0;
										oOrigPC			<= 3'b000;
										oCSType			<= 2'b00;
										if({iInstr[31:25],iInstr[19:7]} == 20'h00000)
											oBreak		 	<= 1'b1;
									end
								default:
									begin
										oRegWrite	<= 1'b0;  
										oMem2Reg 	<= 3'b000;
										// dispara tratamento de excessao (mas pelo rs2 invalido!)
										oCSRegWrite  <= ON;
										oCSRWSource  <= 3'b110; // grava instrucao em uval
										oUCAUSEWrite <= ON;
										oUCAUSEData  <= 32'h00000002; // causa = instr invalida
										oUEPCWrite 	 <= ON;
										oOrigPC		 <= 3'b100; // pc vem do csreg utvec
										oCSType		 <= 2'b01; // tipo cs excessao
									end
							endcase
						end
					FUNCT3_CSRRW:
						begin
							oUCAUSEWrite	<= OFF; // nao escreve ucause
							oUCAUSEData 	<= ZERO;
							oUEPCWrite 		<= OFF; // nao escreve uepc
							oOrigPC 			<= 3'b000; // PC vem de PC + 4
							oMem2Reg 		<= 3'b100; // dado do rd vem do csr
							oRegWrite 		<= ON;
							oCSRegWrite		<= ON; // escreve em csr
							oCSRWSource  	<= 3'b000; // instrucao do tipo CSR = REG
							oCSType 			<= 2'b11; // tipo cs instrucao
						end
						
					FUNCT3_CSRRS:
						begin
							oUCAUSEWrite	<= OFF; // nao escreve ucause
							oUCAUSEData 	<= ZERO;
							oUEPCWrite 		<= OFF; // nao escreve UEPC
							oOrigPC 			<= 3'b000; // PC vem de PC+4
							oMem2Reg 		<= 3'b100; // dado do rd vem do csr
							oRegWrite 		<= ON;
							oCSRegWrite 	<= ON; // escreve em csr
							oCSRWSource 	<= 3'b001; // instrucao do tipo CSR = CSR | REG
							oCSType 			<= 2'b11; // tipo cs instrucao
						end
		
					FUNCT3_CSRRC:
						begin
							oUCAUSEWrite	<= OFF; // nao escreve ucause
							oUCAUSEData 	<= ZERO;
							oUEPCWrite 		<= OFF; // nao escreve UEPC
							oOrigPC 			<= 3'b000; // PC vem de PC+4
							oMem2Reg 		<= 3'b100; // dado do rd vem do csr
							oRegWrite 		<= ON;
							oCSRegWrite 	<= ON; // escreve em csr
							oCSRWSource 	<= 3'b010; // instrucao do tipo CSR = CSR & !REG
							oCSType 			<= 2'b11; // tipo cs instrucao
						end
					FUNCT3_CSRRWI:
						begin
							oUCAUSEWrite	<= OFF; // nao escreve ucause
							oUCAUSEData 	<= ZERO;
							oUEPCWrite 		<= OFF; // nao escreve UEPC
							oOrigPC 			<= 3'b000; // PC vem de PC+4
							oMem2Reg 		<= 3'b100; // dado do rd vem do csr
							oRegWrite 		<= ON;
							oCSRegWrite 	<= ON; // escreve em csr
							oCSRWSource  	<= 3'b011; // instrucao do tipo CSR = IMM
							oCSType 			<= 2'b11; // tipo cs instrucao
						end
					FUNCT3_CSRRSI:
						begin
							oUCAUSEWrite	<= OFF; // nao escreve ucause
							oUCAUSEData 	<= ZERO;
							oUEPCWrite 		<= OFF; // nao escreve UEPC
							oOrigPC 			<= 3'b000; // PC vem de PC+4
							oMem2Reg 		<= 3'b100; // dado do rd vem do csr
							oRegWrite 		<= ON;
							oCSRegWrite 	<= ON; // escreve em csr
							oCSRWSource 	<= 3'b100; // instrucao do tipo CSR = CSR | IMM
							oCSType 			<= 2'b11; // tipo cs instrucao
						end
					FUNCT3_CSRRCI:
						begin
							oUCAUSEWrite	<= OFF; // nao escreve ucause
							oUCAUSEData 	<= ZERO;
							oUEPCWrite 		<= OFF; // nao escreve UEPC
							oOrigPC 			<= 3'b000; // PC vem de PC+4
							oMem2Reg 		<= 3'b101; // dado do rd vem do csr
							oRegWrite 		<= ON;
							oCSRegWrite 	<= ON; // escreve em csr
							oCSRWSource 	<= 3'b101; // instrucao do tipo CSR = CSR & !IMM
							oCSType 			<= 2'b11; // tipo cs instrucao
						end
					default:
						begin
							oRegWrite	<= 1'b0;  
							oMem2Reg 	<= 3'b000;
							// dispara tratamento de excessao
							oCSRegWrite  <= ON;
							oCSRWSource  <= 3'b110; // grava instrucao em uval
							oUCAUSEWrite <= ON;
							oUCAUSEData  <= 32'h00000002; // causa = instr invalida
							oUEPCWrite 	 <= ON;
							oCSType		 <= 2'b01; // tipo cs excessao
							oOrigPC		 <= 3'b100; // pc vem do csreg utvec
						end
				endcase
			end
      
		default: // instrucao invalida : opcode invalido
        begin
				oOrigAULA  	<= 1'b0;
				oOrigBULA 	<= 1'b0;
				oRegWrite	<= 1'b0;
				oMemWrite	<= 1'b0; 
				oMemRead 	<= 1'b0; 
				oALUControl	<= OPNULL;
				oMem2Reg 	<= 3'b000;
`ifdef RV32IMF
				oFPALU2Reg    <= 1'b0;
				oFPALUControl <= OPNULL;
				oFRegWrite    <= 1'b0;
				oOrigAFPALU   <= 1'b0;
				oFWriteData   <= 1'b0;
				oWrite2Mem    <= 1'b0;
				oFPstart		  <= 1'b0;
`endif
				// dispara tratamento de excessao
				oCSRegWrite  <= ON;
				oCSRWSource  <= 3'b110; // grava instrucao em uval
				oUCAUSEWrite <= ON;
				oUCAUSEData  <= 32'h00000002; // causa = instr invalida
				oUEPCWrite 	 <= ON;
				oCSType		 <= 2'b01; // tipo cs excessao
				oOrigPC		 <= 3'b100; // pc vem do csreg utvec
				oBreak		 <= 1'b0;
        end
		  
	endcase

endmodule
