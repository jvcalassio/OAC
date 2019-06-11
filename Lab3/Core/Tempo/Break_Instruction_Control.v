module Break_Instruction_Control(
	input wire iCLK,
	input wire iBreakSignal,
	input wire iReset,
	output wire oBreak
);

always @(negedge iCLK or posedge iReset) begin
	if(iReset)
		oBreak <= 1'b0;
	else
		oBreak <= iBreakSignal;
end

endmodule
