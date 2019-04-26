.include "macros2.s"

.data
C: .space 160 # alocar 160 espacos na memoria 2 coord(x,y) * max casas (20) * 4 bytes cada coord
N: .word 6 # numero de casas. pode ser mudado
D: .space 1600 # matriz das distancias entre as casas

next_line: .string "\n"
blank_line: .string "x"

.text
	M_SetEcall(exceptionHandling)
	
	la t0,N
	lw a0,0(t0)
	la a1,C
	jal SORTEIO
	
	jal LIMPA_TELA
	
	la t0,N
	lw a0,0(t0)
	la a1,C
	jal ROTAS
	
	la t0,N
	lw a0,0(t0)
	la a1,C
	jal DESENHA
	
	j FIMPROG

######################################
#	Gerar casas aleatoriamente
# a0 = numero de casas
# a1 = ponteiro para as casas
######################################
SORTEIO:
	mv s0,a0 # copia a0 para s0. s0 = n
	mv s1,a1 # copia a1 para s1. s1 = C
	li s2,0 # contador i. i = 0
	LOOP_SORTEIO:
		beq s2,s0,FIM_LOOP_SORTEIO # se i == n, sair do loop
		li a7,41 # gera numero aleatorio para X, em a0
		ecall		
		li t0,310
		remu a0,a0,t0 # faz numero%310 para obter a coordenada X
		sw a0,0(s1) # armazena coord X em C
		
		li a7,41 # gera numero aleatorio para Y, em a0
		ecall
		li t0,230
		remu a0,a0,t0 # faz numero%230 para obter a coordenada Y
		sw a0,4(s1) # armazena coord Y em C
		
		addi s1,s1,8 # incrementa endereco para proxima gravacao em 2 words (2*4 bytes)
		addi s2,s2,1 # incrementa o i
		j LOOP_SORTEIO
	FIM_LOOP_SORTEIO: # numeros sorteados, retornar
		li s2,1 # reseta contador, i = 0
		la s1,C # reseta ponteiro para o comeco
		LOOP2: # loop de teste para printar vetor
			beq s2,s0,FIMLOOP2
			lw a0,0(s1) # printa x
			li a7,1
			ecall
			
			la a0,blank_line
			li a7,4
			ecall
			
			lw a0,4(s1) # printa y
			li a7,1
			ecall
			
			la t0,next_line # printa \n
			lw a0,0(t0)
			li a7,11
			ecall
			
			addi s1,s1,8
			addi,s2,s2,1
			j LOOP2
		FIMLOOP2:
			ret
			
#######################################################
#	Desenha as casas e as rotas no bitmap display
# a0 = numero de casas
# a1 = ponteiro para as casas
#######################################################
DESENHA:
	mv s0,a0 # copia a0 para s0. s0 = n
	mv s1,a1 # copia a1 para s1. s1 = C
	li s2,0 # contador para loop. i = 0
	
	LOOP_DESENHA:
		beq s2,s0,FIM_LOOP_DESENHA # se i == n, sai do loop
		addi a0,s2,65 # nome da casa (caractere ascii correspondente)
		lw a1,0(s1) # carrega a posicao X da casa i
		lw a2,4(s1) # carrega a posicao Y da casa i
		li a3,0x3100 # escolhe a cor (fundo verde, letra pret)
		li a4,0
		li a7,111
		ecall # mostra casa na tela
		
		addi s1,s1,8 # incrementa o endereco para proxima leitura em 2 words (2*4 bytes)
		addi s2,s2,1 # incrementa o i
		j LOOP_DESENHA
		
	FIM_LOOP_DESENHA: # todas as casas desenhadas
		ret

###################################################
#	Calcular distancias e desenhar rotas
# a0 = numero de casas
# a1 = ponteiro para as casas
#######################################################
ROTAS:
	# modelo: traçar rota entre A e todas as casas, calcular todas as distancias e gravar na matriz
	mv s0,a0 # copia a0 para s0. s0 = n
	mv s1,a1 # copia a1 para s1. s1 = C
	li s2,0 # contador para loop. i = 0
	
	LOOP_CASAS:
		beq s2,s0,FIM_LOOP_CASAS # se i == n, sai do loop
		lw s4,0(s1) # coord X da casa i
		lw s5,4(s1) # coord Y da casa i
		
		sub s3,s0,s2 # contador para loop. j = n - i, e o loop decresce (mais rapido, nao precisa de mais instrucoes)
		
		addi s6,s1,8 # ponteiro para casas que i se liga (ligacao i para j. se i > 0, ligacao j para i ja foi feita)
		
		LOOP2_CASAS: # estando na casa i, percorrer todas as casas n-i restantes
			li t0,1
			beq s3,t0,FIM_LOOP2_CASAS
			mv a0,s4 # posicao X da casa i
			mv a1,s5 # posicao Y da casa i
			lw a2,0(s6) # carrega a posicao X da casa j
			lw a3,4(s6) # carrega a posicao Y da casa j
			li a4,0x00
			li a5,0
			li a7,147
			ecall # desenha a linha entre as casas i e j
			
			# todo: gravar distancias entre as casas i e j na matriz
			
			addi s3,s3,-1 # decrementa o j
			addi s6,s6,8 # incrementa o proximo endereco para rota
			j LOOP2_CASAS
		
		FIM_LOOP2_CASAS:
			addi s1,s1,8 # incrementa o endereco para proxima leitura em 2 words (2*4 bytes)
			addi s2,s2,1 # incrementa o i
			j LOOP_CASAS
		
	FIM_LOOP_CASAS:
		ret	

LIMPA_TELA: # fundo de tela branco, para melhor visualizacao/nao esquecer de dar clean
	li a0,0xff
	li a1,0
	li a7,148
	ecall
	ret
	
FIMPROG:
	li a7,10
	ecall

.include "SYSTEMv13.s"
