.include "../imports/macros2.s"

.data
# Numero de Notas a tocar
NUM: .word 7
# lista de nota,dura��o,nota,dura��o,nota,dura��o,...
NOTAS: 64,400,0,100,67,400,0,100,55,400,0,100,60,600

.text
	la t0,exceptionHandling
	csrrw zero,5,t0
	csrrwi zero,0,1

	la s0,NUM		# define o endere�o do n�mero de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,NOTAS		# define o endere�o das notas
	li t0,0			# zera o contador de notas
	li t1,0			# contador teste
	li t2,0			# numero de vezes que ira tocar
	li a2,80		# define o instrumento
	li a3,127		# define o volume

LOOP:	beq t0,s1, FIM		# contador chegou no final? ent�o v� para FIM
	lw a0,0(s0)		# le o valor da nota
	bnez a0,LOOP2
	li a3,0			# zera o volume da nota
	

	
LOOP2:	lw a1,4(s0)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	addi s0,s0,8		# incrementa para o endere�o da pr�xima nota
	addi t0,t0,1		# incrementa o contador de notas
	li a3,127		# volta o volume original
	j LOOP			# volta ao loop
		
FIM:	beq t1,t2,FIM1		# contador chegou no final? ent�o v� para FIM1
	li t0,0			# zera o contador de notas
	la s0,NOTAS		# carrega novamente o endere�o das notas
	addi t1,t1,1		# incrementa o contador de notas
	j LOOP			# volta ao loop

FIM1: 	li a0,10		# saida do programa
	ecall

.include "../imports/SYSTEMv14.s"
