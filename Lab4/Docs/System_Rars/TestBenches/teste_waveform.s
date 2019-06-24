.include "../macros2.s"

.data

.text
	M_SetEcall(exceptionHandling)
	
	jal zero,TESTE2
	li t0,0x345
	TESTE2:
	li a0,0x123
	li a1,100
	li a2,100
	li a3,0x00ff
	li a4,0
	li a7,134
	ecall
	#ebreak
	
FIM_V: j FIM_V
	
.include "../SYSTEMv14.s"
