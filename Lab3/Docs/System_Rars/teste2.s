.include "macros2.s"

.data
teste: .word 123456
.text
	la t0,exceptionHandling
	csrrw zero,5,t0
	csrrwi zero,0,1
	
	la t0,teste
	lw t0,0(t0)
	TESTE2: j FIM
	
FIM: j FIM

.include "SYSTEMv14.s"
