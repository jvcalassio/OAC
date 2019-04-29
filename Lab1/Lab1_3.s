.include "macros2.s"

.data
C: .space 160 # alocar 160 espacos na memoria 2 coord(x,y) * max casas (20) * 4 bytes cada coord
N: .word 6 # numero de casas. pode ser mudado
D: .space 1600 # matriz das distancias entre as casas

next_line: .string "\n"
blank_line: .string " "

pi: .float 3.141592

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
	
	la t0,N
	lw a0,0(t0)
	jal PRINT_MATRIZ
	
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

#######################################################
#	Calcular distancias e desenhar rotas
# a0 = numero de casas
# a1 = ponteiro para as casas
#######################################################
ROTAS:
	# modelo: traçar rota entre A e todas as casas, calcular todas as distancias e gravar na matriz
	mv s0,a0 # copia a0 para s0. s0 = n
	mv s1,a1 # copia a1 para s1. s1 = C
	li s2,0 # contador para loop. i = 0
	la s9,D # matriz de posicoes
	
	LOOP_CASAS:
		beq s2,s0,FIM_LOOP_CASAS # se i == n, sai do loop
		lw s4,0(s1) # coord X da casa i
		lw s5,4(s1) # coord Y da casa i
		
		slli t0,s2,2 # t0 = 4*i
		add s9,s9,t0 # pula o end da matriz para o end i x i
		#sw zero,0(s9) # adiciona 0 de distancia em i x i
		addi s9,s9,4 # pula o end da matriz para a proxima posicao (para ja gravar i x j)
		
		addi s3,s2,1 # contador para loop. j = i + 1
		
		addi s6,s1,8 # ponteiro para casas que i se liga (ligacao i para j. se i > 0, ligacao j para i ja foi feita no display)
		
		LOOP2_CASAS: # estando na casa i, percorrer todas as n-i casas restantes
			beq s3,s0,FIM_LOOP2_CASAS # s3 == n ? fim do loop : continua loop
			mv a0,s4 # posicao X da casa i
			mv a1,s5 # posicao Y da casa i
			lw a2,0(s6) # carrega a posicao X da casa j
			lw a3,4(s6) # carrega a posicao Y da casa j
			li a4,0x00
			li a5,0
			li a7,147
			ecall # desenha a linha entre as casas i e j
			
			# gravar distancias entre as casas i e j na matriz
			sub t0,a0,a2 # (x1-x2)
			sub t1,a1,a3 # (y1-y2)
			mul t0,t0,t0 # (x1-x2)*(x1-x2)
			mul t1,t1,t1 # (y1-y2)*(y1-y2)
			fcvt.s.w ft0,t0 # converte o quadrado das diferencas dos x para float
			fcvt.s.w ft1,t1 # converte o quadrado das diferencas dos y para float
			fadd.s ft0,ft0,ft1 # faz a soma dos quadrados
			fsqrt.s ft0,ft0 # faz a raiz quadrada
			fsw ft0,0(s9) # salva o resultado na matriz
			
			# gravar distancias entre as casas j e i na matriz
			# distancia ja salva previamente em ft0, basta calcular posicao do j x i correspondente
			mv t0,s2 # t0 = i
			mv t1,s3 # t1 = j
			mul t1,t1,s0 # j = j * n
			add t1,t1,t0 # j = (j * n) + i
			slli t1,t1,2 # j * 4 bytes
			la t2,D
			add t2,t2,t1 # calcula qual o endereco de j x i na matriz a partir do end base
			fsw ft0,0(t2) # grava o resultado em j x i
			
			addi s9,s9,4 # passa o ponteiro de s9 (D) para o proximo byte
			addi s3,s3,1 # incrementa o j
			addi s6,s6,8 # incrementa o proximo endereco para rota
			j LOOP2_CASAS
		
		FIM_LOOP2_CASAS:
			addi s1,s1,8 # incrementa o endereco para proxima leitura em 2 words (2*4 bytes)
			addi s2,s2,1 # incrementa o i
			j LOOP_CASAS
		
	FIM_LOOP_CASAS:
		ret

PRINT_MATRIZ:
	mv s0,a0 # s0 = n
	la s1,D
	li s2,0 # i = 0
	la a0,next_line
	li a7,4
	ecall
			
	FOR1:
		beq s2,s0,FIMFOR1
		li s3,0 # j = 0
		
		FOR2:
			beq s3,s0,FIMFOR2
			flw fa0,0(s1)
			li a7,2
			ecall
			
			la a0,blank_line
			li a7,4
			ecall
			
			addi s1,s1,4
			addi s3,s3,1
			j FOR2
			
		FIMFOR2:
			la a0,next_line
			li a7,4
			ecall
			
			addi s2,s2,1
			j FOR1
		
	FIMFOR1:
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
