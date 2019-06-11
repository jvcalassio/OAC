`ifndef PARAM
	`include "../Parametros.v"
`endif


module CSRegisters (
    input wire 			iCLK, iRST, iCSRegWrite, // sinal de clock, sinal de reset, se escreve no csreg ou nao
	 input wire	[6:0]		iCSReadRegister, // registrador CS a ser lido
	 input wire [6:0]		iCSWriteRegister, // registrador CS a ser escrito
	 input wire [31:0]	iCSWriteData, // dado a ser escrito no CSR
		// registradores ucause e uepc vao ser escritos quase sempre
	 input wire				iUCAUSEWrite, iUEPCWrite,
	 input wire	[31:0]	iUCAUSEData, iUEPCData,
	 output wire[31:0]	oCSReadData, // dado lido de CSR
	 
    input wire  [4:0] 	iVGASelect, iRegDispSelect,
    output reg  [31:0] 	oVGARead, oRegDisp // para mostrar no display. a ser avaliado
    );

/* Control and Status Register file */
reg [31:0] registers[69:0];

reg [6:0] i;

initial
	begin 
		for (i = 0; i <= 68; i = i + 1'b1) // seta os registradores em 0
			registers[i] = 32'b0;
	end


assign oCSReadData =	registers[iCSReadRegister];

assign oRegDisp 	=	registers[iRegDispSelect];
assign oVGARead 	=	registers[iVGASelect];

`ifdef PIPELINE
    always @(negedge iCLK or posedge iRST)
`else
    always @(posedge iCLK or posedge iRST)
`endif
begin
    if (iRST) // se receber sinal de reset
    begin // reseta o banco de registradores
        for (i = 0; i <= 68; i = i + 1'b1)
            registers[i] <= 32'b0;
    end
    else
	 begin // do contrario, apenas escreve dado desejado no registrador desejado
		i<=6'bx; // para não dar warning
		if(iCSRegWrite)
				registers[iCSWriteRegister] <= iCSWriteData;
				
		if(iUCAUSEWrite)
				registers[7'd66] <= iUCAUSEData;
				
		if(iUEPCWrite)
				registers[7'd65] <= iUEPCData;
		
		end
end

endmodule
