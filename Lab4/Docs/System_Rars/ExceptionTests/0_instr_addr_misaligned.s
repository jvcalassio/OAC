.include "../macros2.s"
.data
data_addr: .word 0
.text
	M_SetEcall(exceptionHandling)
	
	text_addr: la t0,text_addr
		jalr zero,t0,3 # + 3 = desalinhado
		
	li t0,0x12345678
	
FIM: j FIM

.include "../SYSTEMv14.s"