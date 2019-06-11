`ifndef PARAM
	`include "../Parametros.v"
`endif

//
// Caminho de dados processador RISC-V Uniciclo
//
//

module Datapath_UNI (
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
    output [31:0] wInstr, 
    input    	 	wCOrigAULA, 
	 input 			wCOrigBULA, 
	 input			wCRegWrite, 
	 input			wCMemWrite, 
	 input			wCMemRead,
	 input  [ 2:0]	wCMem2Reg, 
	 input  [ 2:0]	wCOrigPC,
	 input  [ 4:0] wCALUControl,
	 // csr control	 
	 input 			wCSRegWrite,
	 input  			wUCAUSEWrite,
	 input			wUEPCWrite,
	 input  [ 1:0]	wCSType,
	 input  [31:0] wUCAUSEData,
	 input  [ 2:0] wCSRWSource,
`ifdef RV32IMF
	 input        	wCFRegWrite,    // Controla a escrita no FReg
	 input [ 4:0] 	wCFPALUControl, // Controla a operacao a ser realizda pela FPULA
	 input       	wCOrigAFPALU,   // Controla se a entrada A da FPULA  float ou int
	 input       	wCFPALU2Reg,    // Controla a escrita no registrador de inteiros (origem FPULA ou nao?)
	 input       	wCFWriteData,   // Controla a escrita nos FRegisters (origem FPALU(0) : origem memoria(1)?)
	 input       	wCWrite2Mem,     // Controla a escrita na memoria (origem Register(0) : FRegister(1))
	 input 			wCFPstart,		 // controla a FPULA
`endif

    //  Barramento de Dados
    output wire        DwReadEnable, DwWriteEnable,
    output wire [ 3:0] DwByteEnable,
    output wire [31:0] DwAddress, DwWriteData,
    input  wire [31:0] DwReadData,

    // Barramento de Instrucoes
    output wire        IwReadEnable, IwWriteEnable,
    output wire [ 3:0] IwByteEnable,
    output wire [31:0] IwAddress, IwWriteData,
    input  wire [31:0] IwReadData
);



// Sinais de monitoramento e Debug
wire [31:0] wRegDisp, wFRegDisp, wCSRegDisp, wVGARead, wFVGARead, wCSVGARead;
wire [ 4:0] wRegDispSelect, wVGASelect;


assign mPC					= PC; 
assign mInstr				= wInstr;
assign mRead1				= wRead1;
assign mRead2				= wRead2;
assign mRegWrite			= wRegWrite;
assign mULA					= wALUresult;
assign mDebug				= 32'h000ACE10;	// Ligar onde for preciso	
assign wRegDispSelect 	= mRegDispSelect;
assign wVGASelect 		= mVGASelect;
assign mRegDisp			= wRegDisp;
assign mCSRegDisp			= wCSRegDisp;
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
assign mFRead1          = wFRead1;
assign mFRead2          = wFRead2;
assign mOrigAFPALU      = wOrigAFPALU;
assign mFWriteData      = wFWriteData;
assign mCFRegWrite      = wCFRegWrite;
`endif


// ****************************************************** 
// Instanciação e Inicializacao do PC						  						 

reg  [31:0] PC;

initial
	begin
		PC         <= BEGINNING_TEXT;
	end						 



// ****************************************************** 
// Instanciacao das estruturas 	 		  						 
	  						 
wire [31:0] wPC4       	= PC + 32'h00000004;
wire [31:0] wBranchPC  	= PC + wImmediate;

wire [ 4:0] wRs1			= wInstr[19:15];
wire [ 4:0] wRs2			= wInstr[24:20];
wire [ 4:0] wRd			= wInstr[11: 7];
wire [ 2:0] wFunct3		= wInstr[14:12];
wire [ 6:0] wOPCode		= wInstr[ 6: 0];



// Barramento da Memoria de Instrucoes 
assign    IwReadEnable      = ON;
assign    IwWriteEnable     = OFF;
assign    IwByteEnable      = 4'b1111;
assign    IwAddress         = PC;
assign    IwWriteData       = ZERO;
assign    wInstr            = IwReadData;


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
// Banco de Registradores de ponto flutuante 
	wire [31:0] wFRead1, wFRead2;

FRegisters REGISTERS1 (
    .iCLK(iCLK),
    .iRST(iRST),
    .iReadRegister1(wRs1),     // Input rs1
    .iReadRegister2(wRs2),     // Input rs2
    .iWriteRegister(wRd),      // Input rd
    .iWriteData(wFWriteData),  // Input dado a ser gravado no registrador (que pode vir da memoria ou do resultado da FPULA)
    .iRegWrite(wCFRegWrite),   // Input do FRegWrite (controle da CPU que ativa a escrita nos registradores de ponto flutuante)
    .oReadData1(wFRead1),      // Output conteudo rs1
    .oReadData2(wFRead2),      // Output conteudo rs2
	 
    .iRegDispSelect(wRegDispSelect),    // seleção para display
    .oRegDisp(wFRegDisp),             // Reg display colocar fregdisp
    .iVGASelect(wVGASelect),             // para mostrar Regs na tela
    .oVGARead(wFVGARead)              // para mostrar Regs na tela colocar wfvgaread
	);
`endif

// Banco de Registradores de control status
	wire [31:0] wCSRead;
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
	.iUEPCData(PC),
	
	.iRegDispSelect(wRegDispSelect),    // seleção para display
   .oRegDisp(wCSRegDisp),                // Reg display
   .iVGASelect(wVGASelect),            // para mostrar Regs na tela
   .oVGARead(wCSVGARead)                 // para mostrar Regs na tela
);

// Unidade geradora do imediato 
wire [31:0] wImmediate;

ImmGen IMMGEN0 (
    .iInstrucao(wInstr),
    .oImm(wImmediate)
);



// ALU - Unidade Lógica-Artimética
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
wire [31:0] wFPALUResult;

FPALU FPALU0 (
    .iclock(iCLK50),                // clock inserir clock_50
    .icontrol(wCFPALUControl),      // 5 bits para saber qual eh a operacao a ser realizada (olhar parametros)
    .idataa(wOrigAFPALU),           // novo multiplexador, ja que a entrada a da ula pode conter inteiro ou float, a principio
    .idatab(wFRead2),               // liga a saida b do banco de registradores float diretamente na ULA
	 .istart(wCFPstart),					// calcula só com instruções tipo-FR
    .oresult(wFPALUResult),         // Saida da ULA
	 .oready()								// não importa se está pronto ou não, a freq. de clock deve ser projetada para o pior caso
	);

`endif


// Unidade de controle de escrita 
wire [31:0] wMemDataWrite;
wire [ 3:0] wMemEnable;
wire [ 1:0] wStoreException;

MemStore MEMSTORE0 (
    //.iAlignment(wALUresult[1:0]),
	 .iStoreAddr(wALUresult),
	 .iOPCode(wOPCode),
    .iFunct3(wFunct3),
    .iData(wWrite2Mem),
    .oData(wMemDataWrite),
    .oByteEnable(wMemEnable),
	 .oException(wStoreException)
	);

	
// Barramento da memoria de dados 

assign DwReadEnable     = wCMemRead;
assign DwWriteEnable    = wCMemWrite;
assign DwByteEnable     = wMemEnable;
assign DwWriteData      = wMemDataWrite;
assign DwAddress        = wALUresult;
wire  [31:0] wReadData  = DwReadData;


// Unidade de controle de leitura 
wire [31:0] wMemLoad;
wire [ 1:0] wLoadException;

MemLoad MEMLOAD0 (
    //.iAlignment(wALUresult[1:0]),
	 .iReadAddr(wALUresult),
	 .iOPCode(wOPCode),
    .iFunct3(wFunct3),
    .iData(wReadData),
    .oData(wMemLoad),
    .oException(wLoadException)
	);


	
// Unidade de controle de Branches 
wire 	wBranch;

BranchControl BC0 (
    .iFunct3(wFunct3),
    .iA(wRead1), 
	 .iB(wRead2),
    .oBranch(wBranch)
);


// ******************************************************
// multiplexadores	

// fios de selecao dos dados CSR
wire [2:0]  wSCSRWSource, wSCOrigPC;
wire [1:0]  wSCSType;
wire 		   wSCSRegWrite, wSUCAUSEWrite, wSUEPCWrite;
wire [31:0] wSUCAUSEData;

// selecao dos dados CSR
always @(*) begin
	if(PC[1:0] != 2'b00) begin // endereco de instrucao desalinhado
		wSUCAUSEWrite	<= ON; // escreve ucause
		wSUCAUSEData 	<= 32'h00000000;
		wSUEPCWrite 	<= ON; // escreve UEPC
		wSCOrigPC 		<= 3'b100; // PC vem do CSR
		wSCSRegWrite 	<= ON; // escreve em csr
		wSCSRWSource	<= 3'b111; 
		wSCSType			<= 2'b01; // excessao com ucause
	end else if (PC < BEGINNING_TEXT || PC > END_TEXT) begin // endereco fora do segmento .text
		wSUCAUSEWrite	<= ON; // escreve ucause
		wSUCAUSEData 	<= 32'h00000001;
		wSUEPCWrite 	<= ON; // escreve UEPC
		wSCOrigPC 		<= 3'b100; // PC vem do CSR
		wSCSRegWrite 	<= ON; // escreve em csr
		wSCSRWSource	<= 3'b111; 
		wSCSType			<= 2'b01; // excessao com ucause
	end
	else if(wLoadException == 2'b01) begin // endereco de load desalinhado
		wSCSType 		<= 2'b01;
		wSCSRWSource  	<= 3'b111;
		wSUCAUSEData  	<= 32'h00000004; // causa = 4;
		wSUCAUSEWrite 	<= ON;
		wSUEPCWrite 	<= ON;
		wSCOrigPC		<= 3'b100;
		wSCSRegWrite   <= ON;
	end
	else if(wLoadException == 2'b10) begin // endereco de load fora dos segmentos
		wSCSType 		<= 2'b01;
		wSCSRWSource  	<= 3'b111;
		wSUCAUSEData  	<= 32'h00000005; // causa = 5;
		wSUCAUSEWrite 	<= ON;
		wSUEPCWrite 	<= ON;
		wSCOrigPC		<= 3'b100;
		wSCSRegWrite  	<= ON;
	end
	else if(wStoreException == 2'b01) begin // endereco de store desalinhado
		wSCSType 		<= 2'b01;
		wSCSRWSource  	<= 3'b111;
		wSUCAUSEData  	<= 32'h00000006; // causa = 6;
		wSUCAUSEWrite 	<= ON;
		wSUEPCWrite 	<= ON;
		wSCOrigPC		<= 3'b100;
		wSCSRegWrite   <= ON;
	end
	else if(wStoreException == 2'b10) begin // endereco de store fora dos segmentos
		wSCSType 		<= 2'b01;
		wSCSRWSource  	<= 3'b111;
		wSUCAUSEData  	<= 32'h00000007; // causa = 7;
		wSUCAUSEWrite 	<= ON;
		wSUEPCWrite 	<= ON;
		wSCOrigPC		<= 3'b100;
		wSCSRegWrite  	<= ON;
	end
	else begin // sem exception
		wSCSRWSource 	<= wCSRWSource;
		wSCSType			<= wCSType;
		wSCSRegWrite 	<= wCSRegWrite;
		wSUCAUSEWrite	<= wUCAUSEWrite;
		wSUCAUSEData	<= wUCAUSEData;
		wSUEPCWrite		<= wUEPCWrite;
		wSCOrigPC		<= wCOrigPC;
	end
end
 
// fonte do dado a ser escrito no CSR
wire [31:0] wCSWriteData;
always @(*)
	begin
		case(wSCSRWSource)
			3'b000: 	wCSWriteData <= wRead1;
			3'b001: 	wCSWriteData <= wCSRead | wRead1;
			3'b010: 	wCSWriteData <= wCSRead & ~(wRead1);
			3'b011: 	wCSWriteData <= wRs1;
			3'b100: 	wCSWriteData <= wCSRead | wRs1;
			3'b101: 	wCSWriteData <= wCSRead & ~(wRs1);
			3'b110: 	wCSWriteData <= wInstr;
			3'b111: 	wCSWriteData <= PC;
			default: wCSWriteData <= wRead1;
		endcase
	end

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
        1'b0:      wOrigAULA <= wRead1;
        1'b1:      wOrigAULA <= PC;
		  default:	 wOrigAULA <= ZERO;
    endcase

	 
wire [31:0] wOrigBULA;
always @(*)
    case(wCOrigBULA)
        1'b0:      wOrigBULA <= wRead2;
        1'b1:      wOrigBULA <= wImmediate;
		  default:	 wOrigBULA <= ZERO;
    endcase	 
	 

`ifndef RV32IMF
wire [31:0] wRegWrite;	 
always @(*)
    case(wCMem2Reg)
        2'b000:     wRegWrite <= wALUresult;		// Tipo-R e Tipo-I
        2'b001:     wRegWrite <= wPC4;				// jalr e jal
        3'b010:     wRegWrite <= wMemLoad;		// Loads
		  3'b100:	  wRegWrite <= wCSRead;			// csr instruction
        default:    wRegWrite <= ZERO;
    endcase 
`else
wire [31:0] wMem2Reg;
always @(*) // Novo fio de saida para fazer os multiplexadores em cascata
    case(wCMem2Reg)
        3'b000:     wMem2Reg <= wALUresult;		// Tipo-R e Tipo-I
        3'b001:     wMem2Reg <= wPC4;				// jalr e jal
        3'b010:     wMem2Reg <= wMemLoad;			// Loads
		  3'b100:	  wMem2Reg <= wCSRead;			// csr instruction
        default:    wMem2Reg <= ZERO;
    endcase	 
`endif

	 
wire [31:0] wiPC;	 
always @(*)
	case(wSCOrigPC)
		3'b000:     wiPC <= wPC4;												// PC+4
      3'b001:     wiPC <= wBranch ? wBranchPC: wPC4;					// Branches
      3'b010:     wiPC <= wBranchPC;										// jal
      3'b011:     wiPC <= (wRead1+wImmediate) & ~(32'h000000001);	// jalr
		3'b100:		wiPC <= wCSRead; 											// UTVEC ou UEPC (exception)
		default:	   wiPC <= ZERO;
	endcase

	
`ifdef RV32IMF
wire [31:0] wOrigAFPALU;
always @(*)
    case(wCOrigAFPALU) //
        1'b0:      wOrigAFPALU <= wRead1;
        1'b1:      wOrigAFPALU <= wFRead1;
		  default:	 wOrigAFPALU <= ZERO;
    endcase

	 
wire [31:0] wRegWrite;	 
always @(*)
    case(wCFPALU2Reg) // Multiplexador intermediario para definir se o que entra no RegWrite do banco de registradores vem da FPULA ou do mux original implementado na ISA RV32I
        1'b0:      wRegWrite <= wMem2Reg;
        1'b1:      wRegWrite <= wFPALUResult;
		  default:	 wRegWrite <= ZERO;
    endcase

	 
wire [31:0] wFWriteData;	 
always @(*)
    case(wCFWriteData) // Multiplexador que controla o que vai ser escrito em um registrador de ponto flutuante (origem memoria ou FPALU?)
        1'b0:      wFWriteData <= wFPALUResult;
        1'b1:      wFWriteData <= wMemLoad;
		  default:	 wFWriteData <= ZERO;
    endcase

	 
wire [31:0] wWrite2Mem;	 
always @(*)
    case(wCWrite2Mem) // Multiplexador que controla o que vai ser escrito na memoria (vem do Register(0) ou do FRegister(1)?)
        1'b0:      wWrite2Mem <= wRead2;
        1'b1:      wWrite2Mem <= wFRead2;
		  default:	 wWrite2Mem <= ZERO;
    endcase
`else
wire [31:0] wWrite2Mem = wRead2;
`endif



// ****************************************************** 
// A cada ciclo de clock					  						 


always @(posedge iCLK or posedge iRST)
begin
    if(iRST)
			PC	<= iInitialPC;
    else
			PC	<= wiPC;
end


endmodule
