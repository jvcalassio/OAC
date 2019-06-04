.data
# Numero de Notas a tocar
NUM: .word 6

# lista de nota,duração,nota,duração,nota,duração,...
NOTAS: 48,80,0,80,48,80,0,80,52,80,0,100,

.text
	la s0,NUM		# define o endereço do número de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,NOTAS		# define o endereço das notas
	li t0,0			# zera o contador de notas
	li t1,0			# contador teste
	li t2,8			# numero de vezes que ira tocar
	li a2,80		# define o instrumento
	li a3,25		# define o volume

LOOP:	beq t0,s1, FIM		# contador chegou no final? então vá para FIM
	lw a0,0(s0)		# le o valor da nota
	bnez a0,LOOP2
	li a3,0			# zera o volume da nota
	
LOOP2:	lw a1,4(s0)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	addi s0,s0,8		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	li a3,25		# volta o volume original
	j LOOP			# volta ao loop
		
FIM:	beq t1,t2,FIM1		# contador chegou no final? então vá para FIM1
	li t0,0			# zera o contador de notas
	la s0,NOTAS		# carrega novamente o endereço das notas
	addi t1,t1,1		# incrementa o contador de notas
	j LOOP			# volta ao loop

FIM1: 	li a0,10		# saida do programa
	ecall

