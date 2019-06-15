#################################################
#	Testbench para a ISA RV32I
#  Baseado no trabalho:
# 
#
# Marcus Vinicius Lamar
# 2019/1
#################################################


.data
N:	.word 5
N2:	.word 10
N3:	.word 0
NH:	.half 2
NH1:	.half 0
NB:	.byte 2
NB1:	.byte 0
MSG:	.string "Endereco do erro : "
MSG2:	.string "CSR - Nao ha erros :)"

.include "../macros2.s"

.text
	M_SetEcall(exceptionHandling)
	li s11, 0	# contador de Loops
	
MAIN:
PULAERRO32: li t0, 2
	csrrw zero,4,t0			# testa CSRRW
	csrrwi t1,4,2			
	beq t0,t1, PULAERRO33
	jal t0,ERRO
	
PULAERRO33: csrrwi t1,4,2		# testa CSRRWI
	li t0, 2
	beq t0,t1,PULAERRO34
	jal t0,ERRO
	
	
PULAERRO34:
  	csrrwi zero,4,0			# zera UIE
	li t0,2
	csrrc zero,4,t0			# testa CSRRC
	csrrci t1,4,7			
	li t0,0
	beq t0,t1, PULAERRO35
	jal t0,ERRO
	
PULAERRO35: csrrci t1,4,0		# testa CSRRCI
	beq zero,t1,PULAERRO36
	jal t0,ERRO
	
PULAERRO36: li t0, 2
	csrrwi zero,4,0			# zera UIE
	csrrs zero,4,t0			# testa CSRRS
	csrrsi t1,4, 2			
	beq t0,t1, PULAERRO37
	jal t0,ERRO
	
PULAERRO37: csrrwi zero,4,2		# seta UIE = 2
	csrrsi t1,4, 2			# testa CSRRSI
	li t0, 2
	beq t0,t1, SUCESSO
	jal t0,ERRO	

SUCESSO: bgt s11,zero,PULA1
   	li a0, 0x38
   	li a1, 0
	li a7, 148
	ecall
	
	#print string sucesso
	li a3,0x3800
	li a7, 104
	la a0, MSG2
	li a1, 64
	li a2, 0
	li a4, 0
	ecall

PULA1:	mv a0, s11
	li a7, 101
	li a1, 140
	li a2, 120
	li a3, 0x3800
	li a4, 0
	ecall

	addi s11, s11, 1
	j MAIN
	
ERRO:	li a0, 0x07
	li a7, 148
	li a1, 0
	ecall
		
	#Print string erro
	li a7, 104
	la a0, MSG
	li a1, 0
	li a2, 0
	li a3, 0x0700
	li a4, 0
	ecall
	
	#print endereco erro
	addi a0, t0, -12 #Endereco onde ocorreu o erro
	li a7, 134
	li a1, 148
	li a2, 0
	li a3, 0x0700
	li a4, 0
	ecall
	
	#end
END: 	addi a7, zero, 10
	ecall
	
.include "../SYSTEMv14.s"
	
