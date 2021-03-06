`ifndef PARAM
	`include "../Parametros.v"
`endif

//
// Caminho de dados processador RISC-V Multiciclo
//
// 2018-2 Marcus Vinicius Lamar
//
 
module Datapath_MULTI (
    // Inputs e clocks
    input  wire        iCLK, iCLK50, iRST,
    input  wire [31:0] iInitialPC,

    // Para monitoramento
    output wire [31:0] mPC,
    output wire [31:0] mInstr,
	 output wire [31:0] mDebug,
    input  wire [ 4:0] mRegDispSelect,
    output wire [31:0] mRegDisp,
	 output wire [31:0] mFRegDisp,
	 output wire [31:0] mCSRegDisp, //	 
    input  wire [ 4:0] mVGASelect,
    output wire [31:0] mVGARead,
    output wire [31:0] mFVGARead,
	 output wire [31:0] mCSVGARead, //
	 output wire [31:0] mRead1,
	 output wire [31:0] mRead2,
	 output wire [31:0] mRegWrite,
	 output wire [31:0] mULA,
`ifdef RV32IMF
	 output wire [31:0] mFPALU,       // Fio de monitoramento da FPALU
	 output wire [31:0] mFRead1,      // Monitoramento Rs1 FRegister
	 output wire [31:0] mFRead2,      // Monitoramento Rs2 FRegister
	 output wire [31:0] mOrigAFPALU,  // Monitoramento entrada A da FPULA
	 output wire [31:0] mFWriteData,  // Para verificar o que esta entrando no FRegister
	 output wire        mCFRegWrite,  // Monitoramento do Enable do FRegister
`endif	 
	 
	// Sinais do Controle
	output wire	[31:0] wInstr,
	input  wire			 wCEscreveIR,
	input  wire			 wCEscrevePC,
	input  wire			 wCEscrevePCCond,
	input  wire			 wCEscrevePCBack,
   input  wire	[ 1:0] wCOrigAULA,
   input  wire	[ 1:0] wCOrigBULA,	 
   input  wire	[ 2:0] wCMem2Reg,
	input  wire	[ 1:0] wCOrigPC,
	input  wire			 wCIouD,
   input  wire			 wCRegWrite,
   input  wire			 wCMemWrite,
	input  wire			 wCMemRead,
	input  wire	[ 4:0] wCALUControl,
	// csr control	 
	input  wire			 wCSRegWrite,
	input  wire			 wUCAUSEWrite,
	input	 wire			 wUEPCWrite,
	input  wire [ 1:0] wCSType,
	input  wire	[31:0] wUCAUSEData,
	input  wire [ 2:0] wCSRWSource,
`ifdef RV32IMF
	output wire			 wFPALUReady,
	input  wire        wCFRegWrite,
	input  wire [ 4:0] wCFPALUControl,
	input  wire        wCOrigAFPALU,
	input  wire        wCFPALUStart,
	input  wire        wCFWriteData,
	input  wire        wCWrite2Mem,
`endif

    //  Barramento
   output wire        DwReadEnable, DwWriteEnable,
   output wire [ 3:0] DwByteEnable,
   output wire [31:0] DwAddress, DwWriteData,
   input  wire [31:0] DwReadData
);



// Sinais de monitoramento e Debug
wire [31:0] wRegDisp, wFRegDisp, wVGARead, wFVGARead, wCSVGARead;
wire [ 4:0] wRegDispSelect, wVGASelect;

assign mPC					= PC; 
assign mInstr				= IR;
assign mRead1				= A;
assign mRead2				= B;
assign mRegWrite			= wRegWrite;
assign mULA					= ALUOut;
assign mDebug				= 32'h000ACE10;	// Ligar onde for preciso	
assign wRegDispSelect 	= mRegDispSelect;
assign wVGASelect 		= mVGASelect;
assign mRegDisp			= wRegDisp;
assign mVGARead			= wVGARead;
assign mCSVGARead			= wCSVGARead;

`ifdef RV32IMF
assign mFRegDisp			= wFRegDisp;
assign mFVGARead			= wFVGARead;
`else
assign mFRegDisp			= ZERO;
assign mFVGARead			= ZERO;
`endif


`ifdef RV32IMF
assign mFPALU				= wFPALUResult;
assign mFRead1          = FA;
assign mFRead2          = FB;
assign mOrigAFPALU      = wOrigAFPALU;
assign mFWriteData      = wFWriteData;
assign mCFRegWrite      = wCFRegWrite;
`endif


// ****************************************************** 
// Instanciação e Inicializacao dos registradores		  						 

reg 	[31:0] PC, PCBack, IR, MDR, A, B, ALUOut, CSRDA, CSRDB;
`ifdef RV32IMF
reg   [31:0] FA, FB, FPALUOut;
`endif

assign wInstr = IR;


initial
begin
	PC			<= BEGINNING_TEXT;
	PCBack 	<= BEGINNING_TEXT;
	IR			<= ZERO;
	ALUOut	<= ZERO;
	MDR 		<= ZERO;
	A 			<= ZERO;
	B 			<= ZERO;
	CSRDA		<= ZERO;
	CSRDB		<= ZERO;
`ifdef RV32IMF
	FA       <= ZERO;
	FB       <= ZERO;
	FPALUOut	<= ZERO;
`endif
end


// ****************************************************** 
// Instanciacao das estruturas 	 		  						 
 						 

wire [ 4:0] wRs1			= IR[19:15];
wire [ 4:0] wRs2			= IR[24:20];
wire [ 4:0] wRd			= IR[11:7];
wire [ 2:0] wFunct3		= IR[14:12];
wire [ 6:0]	wOPCode		= IR[ 6: 0];


// Unidade de controle de escrita 
wire [31:0] wMemDataWrite;
wire [ 3:0] wMemEnable;
wire [ 1:0] wStoreException;

MemStore MEMSTORE0 (
    //.iAlignment(wMemAddress[1:0]),
	 .iStoreAddr(wMemAddress),
	 .iOPCode(wOPCode),
    .iFunct3(wFunct3),
`ifndef RV32IMF
    .iData(B),                       // Dado de escrita
`else
	 .iData(wWrite2Mem),
`endif
    .oData(wMemDataWrite),
    .oByteEnable(wMemEnable),
    .oException(wStoreException)
	);
	

// Barramento da memoria 
assign DwReadEnable     = wCMemRead;
assign DwWriteEnable    = wCMemWrite;
assign DwByteEnable     = wMemEnable;
assign DwAddress        = wMemAddress;
assign DwWriteData      = wMemDataWrite;
wire 	 [31:0] wReadData = DwReadData;

// Unidade de controle de leitura 
wire [31:0] wMemLoad;
wire [ 1:0] wLoadException;

MemLoad MEMLOAD0 (
    //.iAlignment(wMemAddress[1:0]),
	 .iReadAddr(wMemAddress),
	 .iOPCode(wOPCode),
    .iFunct3(wFunct3),
    .iData(wReadData),
    .oData(wMemLoad),
    .oException(wLoadException)
	);
	
	

// Banco de Registradores 
wire [31:0] wRead1, wRead2;

Registers REGISTERS0 (
    .iCLK(iCLK),
    .iRST(iRST),
    .iReadRegister1(wRs1),
    .iReadRegister2(wRs2),
    .iWriteRegister(wRd),
    .iWriteData(wRegWrite),
    .iRegWrite(wCRegWrite),
    .oReadData1(wRead1),
    .oReadData2(wRead2),
	 
    .iRegDispSelect(wRegDispSelect),    // seleção para display
    .oRegDisp(wRegDisp),                // Reg display
    .iVGASelect(wVGASelect),            // para mostrar Regs na tela
    .oVGARead(wVGARead)                 // para mostrar Regs na tela
	);
	
	
`ifdef RV32IMF
wire [31:0] wFRead1;
wire [31:0] wFRead2;

FRegisters REGISTERS1 (
    .iCLK(iCLK),
    .iRST(iRST),
    .iReadRegister1(wRs1),
    .iReadRegister2(wRs2),     
    .iWriteRegister(wRd),      
    .iWriteData(wFWriteData),  
    .iRegWrite(wCFRegWrite),   
    .oReadData1(wFRead1),      
    .oReadData2(wFRead2),     
	 
    .iRegDispSelect(wRegDispSelect),    // seleÃ§Ã£o para display
    .oRegDisp(wFRegDisp),                // Reg display colocar fregdisp
    .iVGASelect(wVGASelect),            // para mostrar Regs na tela
    .oVGARead(wFVGARead)                 // para mostrar Regs na tela colocar wfvgaread
	);

`endif

// Banco de registradores de controle e status
wire [31:0] wCSRead; // dado lido do registrador csr
CSRegisters REGISTERS2 (
	.iCLK(iCLK),
	.iRST(iRST),
	.iCSReadRegister(wCSReadRegister),
	.oCSReadData(wCSRead),
	.iCSWriteRegister(wCSWriteRegister),
	.iCSWriteData(wCSWriteData),
	.iCSRegWrite(wSCSRegWrite),
	.iUCAUSEWrite(wSUCAUSEWrite),
	.iUEPCWrite(wSUEPCWrite),
	.iUCAUSEData(wSUCAUSEData),
	.iUEPCData(PCBack),
	
	.iRegDispSelect(wRegDispSelect),    // seleção para display
   .oRegDisp(wCSRegDisp),                // Reg display
   .iVGASelect(wVGASelect),            // para mostrar Regs na tela
   .oVGARead(wCSVGARead)                 // para mostrar Regs na tela
);

	
// Unidade de controle de Branches 
wire 	wBranch;

BranchControl BC0 (
    .iFunct3(wFunct3),
    .iA(A), 
	 .iB(B),
    .oBranch(wBranch)
);


// Unidade geradora do imediato 
wire [31:0] wImmediate;

ImmGen IMMGEN0 (
    .iInstrucao(IR),
    .oImm(wImmediate)
);


// ALU - Unidade Lógica Aritmética
wire [31:0] wALUresult;

ALU ALU0 (
    .iControl(wCALUControl),
    .iA(wOrigAULA),
    .iB(wOrigBULA),
    .oResult(wALUresult),
    .oZero()
	);


`ifdef RV32IMF
//FPALU
//wire        wFPALUReady;
wire [31:0] wFPALUResult;

FPALU FPALU0 (
    .iclock(iCLK),
    .icontrol(wCFPALUControl),
    .idataa(wOrigAFPALU),
    .idatab(FB),                    // Registrador B entra direto na FPULA
	 .istart(wCFPALUStart),            // Sinal de reset (start) que sera enviado pela controladora
	 .oready(wFPALUReady),           // Output que sinaliza a controladora que a FPULA terminou a operacao
    .oresult(wFPALUResult)
	);

`endif



// ****************************************************** 
// multiplexadores							  						 

// fios de selecao dos dados CSR
wire [2:0]  wSCSRWSource, wSCOrigPC;
wire [1:0]  wSCSType;
wire 		   wSCSRegWrite, wSUCAUSEWrite, wSUEPCWrite, wSCEscrevePC;
wire [31:0] wSUCAUSEData;

// selecao dos dados CSR
always @(*) begin
	if(wCEscrevePCBack && wCEscreveIR && wCEscrevePC) begin // excessao do pc
		if(PC[1:0] != 2'b00) begin // endereco de instrucao desalinhado
			wSCSRWSource	<= 3'b111;
			wSCSType			<= 2'b01;
			wSCSRegWrite	<= 1'b1;
			wSUCAUSEWrite	<= 1'b1;
			wSUCAUSEData	<= 32'h00000000; // causa = 0;
			wSUEPCWrite		<= 1'b1;
			wSCOrigPC		<= 2'b11;
			wSCEscrevePC	<= 1'b1;
		end else if (PC < BEGINNING_TEXT || PC > END_TEXT) begin // endereco fora do segmento .text
			wSCSRWSource	<= 3'b111;
			wSCSType			<= 2'b01;
			wSCSRegWrite	<= 1'b1;
			wSUCAUSEWrite	<= 1'b1;
			wSUCAUSEData	<= 32'h00000001; // causa = 1;
			wSUEPCWrite		<= 1'b1;
			wSCOrigPC		<= 2'b11;
			wSCEscrevePC	<= 1'b1;
		end
	end
	else if(wCMemRead && wCIouD) begin // excessao de leitura
		if(wLoadException == 2'b01) begin // endereco de load desalinhado
			wSCSRWSource	<= 3'b111;
			wSCSType			<= 2'b01;
			wSCSRegWrite	<= 1'b1;
			wSUCAUSEWrite	<= 1'b1;
			wSUCAUSEData	<= 32'h00000004; // causa = 4;
			wSUEPCWrite		<= 1'b1;
			wSCOrigPC		<= 2'b11;
			wSCEscrevePC	<= 1'b1;
		end
		else if(wLoadException == 2'b10) begin // endereco de load fora dos segmentos
			wSCSRWSource	<= 3'b111;
			wSCSType			<= 2'b01;
			wSCSRegWrite	<= 1'b1;
			wSUCAUSEWrite	<= 1'b1;
			wSUCAUSEData	<= 32'h00000005; // causa = 5;
			wSUEPCWrite		<= 1'b1;
			wSCOrigPC		<= 2'b11;
			wSCEscrevePC	<= 1'b1;
		end
	end else if(wCMemWrite && wCIouD) begin // excessao de escrita
		if(wStoreException == 2'b01) begin // endereco de store desalinhado
			wSCSRWSource	<= 3'b111;
			wSCSType			<= 2'b01;
			wSCSRegWrite	<= 1'b1;
			wSUCAUSEWrite	<= 1'b1;
			wSUCAUSEData	<= 32'h00000006; // causa = 6;
			wSUEPCWrite		<= 1'b1;
			wSCOrigPC		<= 2'b11;
			wSCEscrevePC	<= 1'b1;
		end
		else if(wStoreException == 2'b10) begin // endereco de store fora dos segmentos
			wSCSRWSource	<= 3'b111;
			wSCSType			<= 2'b01;
			wSCSRegWrite	<= 1'b1;
			wSUCAUSEWrite	<= 1'b1;
			wSUCAUSEData	<= 32'h00000007; // causa = 7;
			wSUEPCWrite		<= 1'b1;
			wSCOrigPC		<= 2'b11;
			wSCEscrevePC	<= 1'b1;
		end
	end
	else begin // sem exception
		wSCSRWSource 	<= wCSRWSource;
		wSCSType			<= wCSType;
		wSCSRegWrite 	<= wCSRegWrite;
		wSUCAUSEWrite	<= wUCAUSEWrite;
		wSUCAUSEData	<= wUCAUSEData;
		wSUEPCWrite		<= wUEPCWrite;
		wSCOrigPC		<= wCOrigPC;
		wSCEscrevePC	<= wCEscrevePC;
	end
end

// fonte do dado a ser escrito no CSR
wire [31:0] wCSWriteData;
assign wCSWriteData = wALUresult; // resultado da saida da ula
/* Modificar:
	No multiciclo, a ula pode fazer todas as operacoes
	Fazer operacoes dos csr na ula e retornar resultado
	ler csr e register > orig a ula, orig b ula.
	escrever dado do csr no registrador
	escrever resultado da ula no csr
	no fim, o cs write data vai receber
		1. resultado da ula
		2. instrucao
		3. pc
always @(*)
	begin
		case(wSCSRWSource)
			3'b000: 	wCSWriteData <= wRead1; // valor lido do Rs1
			3'b001: 	wCSWriteData <= wCSRead | wRead1; // valor lido do CSR bitwise-or valor lido do Rs1
			3'b010: 	wCSWriteData <= wCSRead & ~(wRead1); // valor lido do CSR bitwise-and valor lido do Rs1 negado
			3'b011: 	wCSWriteData <= wRs1; // Imediato
			3'b100: 	wCSWriteData <= wCSRead | wRs1; // valor lido do CSR bitwise-or Imediato
			3'b101: 	wCSWriteData <= wCSRead & ~(wRs1); // valor lido do CSR bitwise-and Imediato negado
			3'b110: 	wCSWriteData <= wInstr; // Instrucao atual
			3'b111: 	wCSWriteData <= PC; // PC atual
			default: wCSWriteData <= wRead1;
		endcase
	end
	*/
	
// numero do csr a ser lido, numero do csr a ser escrito
wire [6:0] wCSReadRegister, wCSWriteRegister;
always @(*)
	begin
		case(wSCSType)
			2'b00: begin // nenhum tipo (fica o espaco se necessario)
					wCSReadRegister	<= 7'b0000000;
					wCSWriteRegister	<= 7'b0000000;
			end
			2'b01: begin // se for ecall ou qlqr outra excessao com ucause, le UTVEC, escreve UTVAL
					wCSReadRegister	<= 7'd05;
					wCSWriteRegister	<= 7'd67;
			end
			2'b10: begin // se for uret, le CSR UEPC = 7'd65
					wCSReadRegister	<= 7'd65;
					wCSWriteRegister	<= 7'b0000000;
				end
			2'b11: begin // se for instrucao, le e escreve o CSR vindo do imediato
					wCSReadRegister	<= wImmediate; 
					wCSWriteRegister	<= wImmediate;
			end
			default: begin
					wCSReadRegister	<= 7'b0000000;
					wCSWriteRegister	<= 7'b0000000;
			end
		endcase
	end

wire [31:0] wOrigAULA;
always @(*)
    case(wCOrigAULA)
        2'b00:    wOrigAULA <= A;
		  2'b01:		wOrigAULA <= PC;
		  2'b10:		wOrigAULA <= PCBack;
		  2'b11: 	wOrigAULA <= CSRDA; // numero escolhido (de acordo com a instrucao) p/ operar na ula com o csr
		  default:	wOrigAULA <= ZERO;
    endcase

	 
wire [31:0] wOrigBULA;	 
always @(*)
    case(wCOrigBULA)
        2'b00:    wOrigBULA <= B;
        2'b01:    wOrigBULA <= 32'h4;
		  2'b10:		wOrigBULA <= wImmediate;
		  2'b11: 	wOrigBULA <= CSRDB; // numero escolhido (de acordo com a instrucao) p/ operar na ula com o csr
		  default:	wOrigBULA <= ZERO;
    endcase	 
	 
	 
wire [31:0] wRegWrite;	 
always @(*)
    case(wCMem2Reg)
        3'b000:    wRegWrite <= ALUOut;
        3'b001:    wRegWrite <= PC;
        3'b010:    wRegWrite <= MDR;
		  3'b100:	 wRegWrite <= wCSRead; // dado lido do registrador csr
`ifdef RV32IMF                                        //RV32IMF
		  3'b011:    wRegWrite <= FPALUOut; // Uma entrada a mais no multiplexador de escrita no registrador de inteiros
`endif
        default:  wRegWrite <= ZERO;
    endcase

	 
wire [31:0] wiPC;	 
always @(*)
	case(wSCOrigPC)
		2'b00:     wiPC <= wALUresult;				// PC+4
      2'b01:     wiPC <= ALUOut;						// Branches e jal
		2'b10:	  wiPC <= wALUresult & ~(32'h1);	// jalr
		2'b11:	  wiPC <= wCSRead;					// UTVEC ou UEPC - registrador lido csr
		default:	  wiPC <= ZERO;
	endcase
	
	
wire [31:0] wMemAddress;	
always @(*)
	case(wCIouD)
		1'b0:		wMemAddress <= PC;
		1'b1:		wMemAddress <= ALUOut;
		default:	wMemAddress <= ZERO;
	endcase
	
`ifdef RV32IMF
wire [31:0] wOrigAFPALU;
always @(*)
    case(wCOrigAFPALU) // Multiplexador que controla a origem A da FPULA
        1'b0:      wOrigAFPALU <= A;
        1'b1:      wOrigAFPALU <= FA;
		  default:	 wOrigAFPALU <= ZERO;
    endcase

	 
wire [31:0] wFWriteData;
always @(*)
    case(wCFWriteData) // Multiplexador que controla o que vai ser escrito em um registrador de ponto flutuante (origem memoria ou FPALU?)
        1'b0:      wFWriteData <= MDR;      // Registrador de dado de memoria (para o flw)
        1'b1:      wFWriteData <= FPALUOut; // Registrador da saida da FPULA
		  default:	 wFWriteData <= ZERO;
    endcase

	 
wire [31:0] wWrite2Mem;	 
always @(*)
    case(wCWrite2Mem) // Multiplexador que controla o que vai ser escrito na memoria (vem do Register(0) ou do FRegister(1)?)
        1'b0:      wWrite2Mem <= B;
        1'b1:      wWrite2Mem <= FB;
		  default:	 wWrite2Mem <= ZERO;
    endcase
`endif
		

		


// ****************************************************** 
// A cada ciclo de clock					  						 

always @(posedge iCLK or posedge iRST)
	if (iRST)
	  begin
		PC			<= BEGINNING_TEXT;
		PCBack 	<= BEGINNING_TEXT;
		IR			<= ZERO;
		ALUOut	<= ZERO;
		MDR 		<= ZERO;
		A 			<= ZERO;
		B 			<= ZERO;
		CSRDA		<= ZERO;
		CSRDB		<= ZERO;
`ifdef RV32IMF
	   FA       <= ZERO;
	   FB       <= ZERO;
		FPALUOut <= ZERO;
`endif
	  end
	else
	  begin
		// Unconditional 
		ALUOut	<= wALUresult;
		A			<= wRead1;
		B			<= wRead2;
		MDR		<= wMemLoad;
`ifdef RV32IMF
		FPALUOut <= wFPALUResult;
		FA       <= wFRead1;
		FB       <= wFRead2;
`endif

		// csr
		case(wSCSRWSource)
			3'b000: begin // CSRRW
				CSRDA <= wRead1;
				CSRDB <= ZERO;
			end
			3'b001: begin // CSRRS
				CSRDA <= wCSRead;
				CSRDB <= wRead1;
			end
			3'b010: begin // CSRRC
				CSRDA <= wCSRead;
				CSRDB <= ~(wRead1);
			end
			3'b011: begin // CSRRWI
				CSRDA <= wRs1;
				CSRDB <= ZERO;
			end
			3'b100: begin // CSRRSI
				CSRDA <= wCSRead;
				CSRDB <= wRs1;
			end
			3'b101: begin // CSRRCI
				CSRDA <= wCSRead;
				CSRDB <= ~(wRs1);
			end
			3'b110: begin // escreve instrucao
				CSRDA <= wInstr;
				CSRDB <= ZERO;
			end
			3'b111: begin // escreve PC
				CSRDA <= PCBack;
				CSRDB <= ZERO;
			end
			default: begin
				CSRDA <= ZERO;
				CSRDB <= ZERO;
			end
		endcase
		
		// Conditional 
		if (wCEscreveIR)
			IR	<= wReadData;
			
		if (wCEscrevePCBack)
			PCBack <= PC;
			
		if (wSCEscrevePC || wBranch & wCEscrevePCCond)
			PC	<= wiPC;	

	  end



endmodule 
