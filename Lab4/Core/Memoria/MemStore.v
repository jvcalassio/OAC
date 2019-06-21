`ifndef PARAM
	`include "../Parametros.v"
`endif

/* Controlador da memoria de escrita */
/* define a partir do funct3 qual a forma de acesso a memoria sb, sh, sw e ByteEnable */
/* verifica se ha algum erro no endereco de escrita */

module MemStore(
	//input [1:0] 			iAlignment,
	input [31:0]			iStoreAddr,
	input [ 6:0]			iOPCode,
	input [ 2:0] 			iFunct3,
	input [31:0] 			iData,
	output logic [31:0]  oData,
	output logic [ 3:0]  oByteEnable,
	output 		 [ 1:0]	oException
);

wire wCheckAlignment;
wire [1:0] iAlignment;

assign iAlignment = iStoreAddr[1:0];
assign wCheckAlignment = (iFunct3 == FUNCT3_SW && iAlignment    != 2'b00)
								|| (iFunct3 == FUNCT3_SH && iAlignment[0] != 1'b0);
always @(*) begin
	if(iOPCode == OPC_STORE) begin
		if(wCheckAlignment)
			oException <= 2'b01; // endereco desalinhado
		else begin
			if((iStoreAddr >= BEGINNING_DATA && iStoreAddr <= END_DATA) || iStoreAddr >= BEGINNING_IODEVICES) 
				oException 	<= 2'b00; // endereco dentro do .data e MMIO, valido
			else
				oException	<= 2'b10; // endereco fora dos segmentos
		end
	end else
		oException <= 2'b00;
end

always @(*) begin
	case (iFunct3)
		FUNCT3_SW:   oData <= iData;
		FUNCT3_SH:   oData <= {iData[15:0], iData[15:0]};
		FUNCT3_SB:   oData <= {iData[7:0], iData[7:0], iData[7:0], iData[7:0]};
		default: oData <= iData;
	endcase
end


always @(*) begin
	case (iFunct3)
		FUNCT3_SW: // Word
			begin
				case (iAlignment)
					2'b00:   oByteEnable <= 4'b1111; // 4-aligned
					default: oByteEnable <= 4'b0000; // Not aligned
				endcase
			end
		FUNCT3_SH: // Halfword
			begin
				case (iAlignment)
					2'b00:   oByteEnable <= 4'b0011; // 2-aligned (lower)
					2'b10:   oByteEnable <= 4'b1100; // 2-aligned (upper)
					default: oByteEnable <= 4'b0000; // Not aligned
				endcase
			end
		FUNCT3_SB: // Byte
			begin
				case (iAlignment)
					2'b00: oByteEnable <= 4'b0001;
					2'b01: oByteEnable <= 4'b0010;
					2'b10: oByteEnable <= 4'b0100;
					2'b11: oByteEnable <= 4'b1000;
				endcase
			end
		default:
			oByteEnable = 4'b0000;
	endcase
end

endmodule
