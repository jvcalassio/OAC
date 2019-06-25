.include "macros2.s"
.data
# Numero de Notas a tocar
NUM: .word 4
# lista de nota,dura��o,nota,dura��o,nota,dura��o,...
NOTAS: 64,200,67,300,55,300,60,400,

.text
	li a7,30
	ecall
	mv t1,a0		# salva o tempo inicial
	la s0,NUM		# define o endere�o do n�mero de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,NOTAS		# define o endere�o das notas
	li t0,0			# zera o contador de notas
	li a2,81		# define o instrumento
	li a3,127		# define o volume

LOOP:	beq t0,s1, FIM		# contador chegou no final? ent�o v� para FIM
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	add t3,t1,a1		# soma duracao total da nota com o tempo
	
LOOP2:	li a7,30
	ecall
	mv t2,a0		# salva o tempo atual
	blt t2,t3,LOOP2
	lw a0,0(s0)		# le o valor da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	addi t0,t0,1		# incrementa o contador de notas
	addi s0,s0,8		# incrementa para o endere�o da pr�xima nota
	mv t1,t3		# novo tempo inicial = soma da duracao da nota com tempo inicial
	j LOOP			# volta ao loop

FIM: 	li a7,10		# saida do programa
	ecall

.include "SYSTEMv14.s"
