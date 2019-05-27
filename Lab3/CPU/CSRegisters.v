`ifndef PARAM
	`include "../Parametros.v"
`endif


module CSRegisters (
    input wire 			iCLK, iRST, iRegWrite, // sinal de clock, sinal de reset, ?
    input wire  [4:0] 	iReadRegister1, iWriteRegister, // rs1, rd
    input wire  [31:0] 	iWriteData, // dado a ser escrito no rd
    output wire [31:0] 	oReadData1 // dado lido do rs1

    //input wire  [4:0] 	iVGASelect, iRegDispSelect,
    //output reg  [31:0] 	oVGARead, oRegDisp para mostra no display. a ser avaliado
    );

/* Control and Status Register file */
reg [10:0] registers[31:0];

reg [5:0] i;

initial
	begin // seta todos os 11 registradores em 0, inicialmente
		for (i = 0; i <= 10; i = i + 1'b1)
			registers[i] = 32'b0;
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
