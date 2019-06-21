.include "../macros2.s"
.data
data_addr: .word 0
.text
	M_SetEcall(exceptionHandling)
	
	text_addr: la t0,data_addr
		jalr zero,t0,0 # t0 = fora do segmento text
		
	li t0,0x12345678
	
FIM: j FIM

.include "../SYSTEMv14.s"