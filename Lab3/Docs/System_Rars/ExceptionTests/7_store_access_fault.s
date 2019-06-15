.include "../macros2.s"
.data
data_addr: .word 0
.text
	M_SetEcall(exceptionHandling)
	
	li t1,0x123
	text_addr: la t0,text_addr
		sw t1,0(t0) # t0 = endereco fora do segmento data e mmio
		
	li t0,0x12345678
	
FIM: j FIM

.include "../SYSTEMv14.s"