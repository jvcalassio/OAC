.include "macros2.s"

.macro save_stack(%reg)
	addi sp,sp,-4
	sw %reg,0(sp)
.end_macro

.macro free_stack(%reg)
	lw %reg,0(sp)
	addi sp,sp,4
.end_macro


.macro get_pointer(%n,%vet,%y,%x) # nao usar t0 como ponteiro para o vet !
	save_stack(t0)
	mul t0,%n,%y # (n * y)
	add t0,t0,%x # (y * n) + x
	slli t0,t0,2 # * 4 bytes
	add %vet,%vet,t0
	free_stack(t0)
.end_macro

.data
C: .space 160 # alocar 160 espacos na memoria 2 coord(x,y) * max casas (20) * 4 bytes cada coord
N: .word 9 # numero de casas
D: .space 1600 # matriz das distancias entre as casas 20 * 20 * 4 bytes de tamanho max

vet_permut: .space 80 # vetor dos numeros das casas (para permutar)
vet_permut_final: .space 80 # vetor dos numeros das casas na melhor ordem

printvet: .space 160 # vetor a ser impresso (C ordenado)

next_line: .string "\n"
blank_line: .string " "
minus1float: .float -1

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
	la a1,D
	jal PRINT_MATRIZ
	
	la t0,N
	lw a0,0(t0)
	la a1,C
	la a2,D
	jal ORDENA
	
	fmv.s fa0,fs0
	li a7,2
	ecall # printa min_dists
	la a0,next_line
	li a7,4
	ecall
	
	jal PRINTORDENADOS
	
	la t0,N
	lw a0,0(t0)
	la a1,C
	jal MAKE_PRINTVET
	
	la t0,N
	lw a0,0(t0)
	jal PRINT_REDLINE
	
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

# TEMPORARY:
PRINT_MATRIZ:
	mv s0,a0 # s0 = n
	mv s1,a1 # s1 = matriz a ser impressa
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

###################################################
#	Acha menores caminhos entre casas
# a0 = numero de casas
# a1 = ponteiro para casas (x,y)
# a2 = ponteiro para matriz de distancias
###################################################
ORDENA:
	mv s0,a0 # a0 = n
	mv s1,a1 # a1 = C
	mv s2,a2 # a2 = D
	
	PRE_CAIXEIRO:
		li t0,0 # i = 0
		la t1,vet_permut # ponteiro inicial do vetor
		LOOP_SETVET: # seta o vetor inicial de 1 a N (para permutar)
			beq t0,s0,FIM_LOOP_SETVET
			sw t0,0(t1)
			addi t0,t0,1
			addi t1,t1,4
			j LOOP_SETVET
		
	FIM_LOOP_SETVET:
	# global: fs0 = menor custo
	li t0,10000
	fcvt.s.w fs0,t0
	li a0,0
	j PERMUTA
	# faz o calculo de melhor rota, testando todas as possibilidades
	
	# sem argumentos. apenas testa se a permutacao atual tem a menor rota e seta fs0
	TESTA_ROTA:
		fcvt.s.w fs1,zero # soma = 0
		li s4,0 # i = 0, contador
		LOOP_SOMADIST: # loop para somar distancias
			beq s4,s0,FIM_LOOPSOMADIST
			mv t1,s2
			rem t2,s4,s0 # t2 = i%n
			addi t3,s4,1 # t3 = i+1
			rem t3,t3,s0 # t3 = (i+1)%n
			la t4,vet_permut
			slli t2,t2,2 # t2 * 4 bytes
			add t2,t4,t2 # a[i%n]
			slli t3,t3,2 # t3 * 4 bytes
			add t3,t4,t3 # a[(i+1%n]
			lw t2,0(t2)
			lw t3,0(t3)
			
			get_pointer(s0,t1,t2,t3) # ponteiro colocado em t1
			flw ft0,0(t1)
			fadd.s fs1,fs1,ft0 # soma += D[t2][t3]
			
			addi s4,s4,1
			j LOOP_SOMADIST
			
		FIM_LOOPSOMADIST:
			# apos finalizar o loop, testar se soma eh menor q o menor custo atual
			flt.s t0,fs1,fs0 # t0 = (fs0 > fs1)
			beq t0,zero,RET_TESTAROTA # se o salvo for menor, soh retorna
				# do contrario, seta novo menor
				fcvt.s.w ft0,zero
				fadd.s fs0,fs1,ft0 # fs0 = fs1
				# salva melhor ordem no vetor de final
				li t0,0 # i = 0
				la t1,vet_permut
				la t2,vet_permut_final
				LOOP_SAVEBEST:
					beq t0,s0,RET_TESTAROTA
					lw t3,0(t1)
					sw t3,0(t2)
					
					addi t1,t1,4 # incrementa ponteiro
					addi t2,t2,4 # incrementa ponteiro
					addi t0,t0,1 # incrementa i
					j LOOP_SAVEBEST
			
		RET_TESTAROTA:
			ret
	
		
	# permuta o vetor de casas (valores apenas, sem xy)
	# argumentos:
	# a0 = casa atual
	PERMUTA:
		addi t0,s0,-1 # t0 = (N-1)
		beq a0,t0,CALL_TESTAROTA # se casa atual == casa N-1 (ja percorreu todas), testa rota
			mv s4,a0 # i = a0
			LOOP_PERMUTA:
				beq s4,s0,FIM_LOOP_PERMUTA # se i == N, sai
					la t0,vet_permut
					slli t1,a0,2
					add t0,t0,t1 # vet_permut + casa atual
					
					la t1,vet_permut
					slli t2,s4,2
					add t1,t1,t2 # vet_permut + j
					lw t2,0(t0) # carrega valor de vet_permut[casaatual]
					lw t3,0(t1) # carreag valor de vet_permut[j]
					sw t2,0(t1)
					sw t3,0(t0) # troca valores de posicao
					
					save_stack(a0)
					save_stack(s4)
					save_stack(t0)
					save_stack(t1)
					save_stack(ra)
					addi a0,a0,1 # novo argumento: casa atual + 1
					jal PERMUTA
					
					# refaz swap
					free_stack(ra)
					free_stack(t1)
					free_stack(t0)
					free_stack(s4)
					free_stack(a0)
					lw t2,0(t0) # valor de vet_permut[casaatual]
					lw t3,0(t1) # valor de vet_permut[j]
					sw t2,0(t1)
					sw t3,0(t0) # troca valores de posicao
					
					addi s4,s4,1
					j LOOP_PERMUTA
		
		CALL_TESTAROTA:
			save_stack(ra)
			jal TESTA_ROTA
			free_stack(ra)
			
	FIM_LOOP_PERMUTA:
		ret

# TEMPORARY:
# printa casas na melhor ordem		
PRINTORDENADOS:
	la s0,N
	lw s0,0(s0) # s0 = n
	la s1,vet_permut_final # s1 = vetor ordenado na melhor ordem
	
	li s2,0 # i = 0
	LOOPPO:
		beq s2,s0,VOLTAPO
		lw a0,0(s1)
		li a7,1
		ecall # printa num
		la a0,blank_line
		li a7,4
		ecall # printa espaco
		
		addi s1,s1,4
		addi s2,s2,1
		j LOOPPO
	
	VOLTAPO:
		la a0,next_line
		li a7,4
		ecall
		ret
		
####################################################
#  Faz vetor para utilizar na impressao das linhas
# a0 = numero de casas
# a1 = vetor C de casas
####################################################
MAKE_PRINTVET:
	mv s0,a0 # s0 = n
	mv s1,a1 # s1 = C
	la s2,vet_permut_final
	la s3,printvet
	
	li s4,0 # i = 0
	LOOP_MAKEPV:
		beq s4,s0,FIM_MAKEPV
		lw t0,0(s2) # carrega qual a i-esima casa
		slli t0,t0,3 # t0 * 8 bytes (pelo x,y) para procurar a i-esima casa em C
		add t0,s1,t0 # t0 = endereco da i-esima casa em C
		
		lw t1,0(t0) # Xi
		lw t2,4(t0) # Yi
		sw t1,0(s3)
		sw t2,4(s3) # grava Xi e Yi no printvet
		
		addi s3,s3,8
		addi s4,s4,1
		addi s2,s2,4
		j LOOP_MAKEPV

	FIM_MAKEPV:
		ret

################################################
# Desenha as linhas vermelhas no bitmap
# a0 = N
################################################
PRINT_REDLINE:
	mv s0,a0 # s0 = n
	addi s0,s0,-1 # so faz ate o penultimo. o ultimo se liga no primeiro
	
	la s1,printvet
	li s2,0 # i = 0
	
	LOOP_REDLINE:
		beq s2,s0,FIMLOOP_REDLINE
		lw a0,0(s1) # x1
		lw a1,4(s1) # y1
		lw a2,8(s1) # x2
		lw a3,12(s1) # y2 
		li a4,0x07
		li a5,0
		li a7,147
		ecall
		
		addi s2,s2,1 # incerementa i
		addi s1,s1,8 # incrementa ponteiro
		j LOOP_REDLINE
	
	FIMLOOP_REDLINE:
		lw a0,0(s1)
		lw a1,4(s1)
		la s1,printvet
		lw a2,0(s1)
		lw a3,4(s1)
		li a4,0x07
		li a5,0
		li a7,147
		ecall
		
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
