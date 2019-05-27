`ifndef PARAM
	`include "../Parametros.v"
`endif


module CSRegisters (
    input wire 			iCLK, iRST, iRegWrite, // sinal de clock, sinal de reset, se escreve no csreg ou nao
	 input wire	[3:0]		iReadRegister, // registrador CS a ser lido
	 input wire [3:0]		iWriteRegister, // registrador CS a ser escrito
	 input wire [31:0]	iWriteData, // dado a ser escrito no CSR
	
	 output wire[31:0]	oReadData // dado lido de CSR
	 
    //input wire  [4:0] 	iVGASelect, iRegDispSelect,
    //output reg  [31:0] 	oVGARead, oRegDisp // para mostrar no display. a ser avaliado
    );

/* Control and Status Register file */
reg [69:0] registers[31:0];

reg [7:0] i;

initial
	begin // seta todos os 11 registradores em 0, inicialmente
		for (i = 0; i <= 5; i = i + 1'b1)
			registers[i] = 32'b1; // seta tudo em 1 pra testes apenas
			// registers[i] = 32'b0;
		for (i = 64; i <= 68; i = i + 1'b1)
			registers[i] = 32'b1;
	end


assign oReadData1 =	registers[iReadRegister1];

//assign oRegDisp 	=	registers[iRegDispSelect];
//assign oVGARead 	=	registers[iVGASelect];

`ifdef PIPELINE
    always @(negedge iCLK or posedge iRST)
`else
    always @(posedge iCLK or posedge iRST)
`endif
begin
    if (iRST) // se receber sinal de reset
    begin // reseta o banco de registradores
        for (i = 0; i <= 10; i = i + 1'b1)
            registers[i] <= 32'b0;
    end
    else
	 begin // do contrario, apenas escreve dado desejado no registrador rd
		i<=6'bx; // para não dar warning
		if(iRegWrite && iWriteRegister != 5'b0)
				registers[iWriteRegister] <= iWriteData;
	 end
end

endmodule
