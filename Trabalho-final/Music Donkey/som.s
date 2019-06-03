.macro tocar(%NUM,%NOTAS)
	.data
		NUM: %NUM
		NOTAS: %NOTAS
	.text
		la s0,NUM		# define o endere�o do n�mero de notas
		lw s1,0(s0)		# le o numero de notas
		la s0,NOTAS		# define o endere�o das notas
		li t0,0			# zera o contador de notas
		li a2,80		# define o instrumento
		li a3,50		# define o volume

	LOOP:	beq t0,s1, FIM		# contador chegou no final? ent�o v� para FIM
		lw a0,0(s0)		# le o valor da nota
		bnez a0,LOOP2		# nota � diferente de 0? ent�o v� para LOOP2
		li a3,0			# zera o volume da nota
		
	LOOP2:	lw a1,4(s0)		# le a duracao da nota
		li a7,31		# define a chamada de syscall
		ecall			# toca a nota
		li a3,50		# volta ao volume original
		
		addi s0,s0,8		# incrementa para o endere�o da pr�xima nota
		addi t0,t0,1		# incrementa o contador de notas
		j LOOP			# volta ao loop
		
	FIM:	
.end_macro

.data
	NUM_LEVEL_1: .word 11
	NOTAS_LEVEL_1: .word 48,300,0,100,0,300,52,300,0,100,55,300,0,100,57,300,0,100,55,300,0,100,
.text
	tocar(NUM_LEVEL_1,NOTAS_LEVEL_1)
	li a7,10
	ecall
	

