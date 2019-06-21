.include "../macros2.s"
.data
data_addr: .word 0
.text
	M_SetEcall(exceptionHandling)
	
	li t1,0x123
	text_addr: la t0,data_addr
		sw t1,3(t0) # t0 + 3 = store desalinhado p/ word
		
	li t0,0x12345678
	
FIM: j FIM

.include "../SYSTEMv14.s"