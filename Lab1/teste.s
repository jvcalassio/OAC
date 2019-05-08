.data
teste: .space 40
space: .string " "
.text

la t0,teste # vetor[0]
li t1,0
li t2,10
LER:
	beq t1,t2,PRNT
	li a7,5
	ecall
	sw a0,0(t0)
	addi t0,t0,4
	addi t1,t1,1
	j LER
	
PRNT:
la t0,teste
li t1,0
li t2,10
PRNTL:
	beq t1,t2,FIM
	lw a0,0(t0)
	li a7,1
	ecall
	la a0,space
	li a7,4
	ecall
	addi t0,t0,4
	addi t1,t1,1
	j PRNTL
FIM:
li a7,10
ecall