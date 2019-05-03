.include "macros2.s"

.macro save_stack(%reg)
	addi sp,sp,-4
	sw %reg,0(sp)
.end_macro

.macro save_stackf(%reg)
	addi sp,sp,-4
	fsw %reg,0(sp)
.end_macro

.macro free_stack(%reg)
	lw %reg,0(sp)
	addi sp,sp,4
.end_macro

.macro free_stackf(%reg)
	flw %reg,0(sp)
	addi sp,sp,4
.end_macro

.data
C: .space 160 # alocar 160 espacos na memoria 2 coord(x,y) * max casas (20) * 4 bytes cada coord
N: .word 6 # numero de casas
D: .space 1600 # matriz das distancias entre as casas 20 * 20 * 4 bytes de tamanho max

dp: .space 0xa000 # caminhos visitados 20 casas max * 2^10 bits (bitmask, 1 bit = 1 casa) * 4 bytes
savepath: .space 0x2800 # matriz auxiliar para salvar caminho utilizado 20 casas max * 2^20 bits (bitmask)
			   # nao precisa ser word, salva valores de 0 a 20 apenas
			   # talvez mude pela comodidade de usar mesmo contador da dp
printvet: .space 160 

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
	
	jal PRINTORDENADOS
	
	la t0,N
	lw a0,0(t0)
	jal PRINT_REDLINE
	
	jal PRINT_C_VET
	
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
	
	# seta a matriz de dp para -1, em todos os valores
	RESETA_VISITADOS:
		li t0,0 # i = 0
		la t1,dp # ponteiro para matriz
		li t3,1
		#sll t3,t3,s0 # 1 << n (shifta 1 para esquerda n vezes)
		slli t3,t3,6
		mul t3,t3,s0 # t = n * (1 << n) = numero de posicoes na matriz com as distancias totais
		
		LOOP_RESET:
			beq t0,t3,PRE_CAIXEIRO # se i == t, toda a matriz tem valores -1
			#li t2,-1
			la t2,minus1float
			lw t2,0(t2)
			sw t2,0(t1) # armazena -1 na posicao especificada
			
			addi t1,t1,4 # incrementa endereco
			addi t0,t0,1 # incrementa i 
			j LOOP_RESET
			
	# aqui comeca a magica
	# a casa inicial eh sempre a casa 0
	# casa atual = a0, comecando em 0
	# bitmask das casas visitadas = a1, inicialmente 0000001
	# se caminho ja foi feito, pegar posicao na matriz (dp)
	# se casa nao foi feito, calcular entre todas as possibilidades, qual o menor caminho
	# apos finalizar, pegar pontos na matriz de path e desenhar no bitmap
	PRE_CAIXEIRO:
		li a0,0
		li a1,1
	
	CAIXEIRO:
		li t0,1
		sll t0,t0,s0 # (1 << N)
		addi t0,t0,-1 # (1 << N)-1
		
#		save_stack(a0)
		mv t1,a0 # move o v atual para t1
		slli t1,t1,2 # * 4bytes
		add t2,s2,t1 # endereco de D[v]
#		lw a0,0(t2) # carrega o valor de D[v] em a0, para retornar
		flw fa0,0(t2)
		beq a1,t0,RETURN_RA # if(S == (1<<N)-1) return D[v];
		
		# caso nao retorne no primeiro if, recupera o valor de a0 mandado para a funcao
#		free_stack(a0)
		
		mul t0,a0,s0 # a0 * n
		add t0,t0,a1 # (a0 * n) + a1
		slli t0,t0,2 # * 4 bytes
		la t1,dp
		add t1,t1,t0 # t1 = endereco de dp[a0][a1]
#		li t0,-1
#		save_stack(a0)
#		lw a0,0(t1) # carrega o valor, para possivel retorno
		flw fa0,0(t1)
#		bne a0,t0,RETURN_RA # se dp[a0][a1] != -1, retorna esse valor
		la t0,minus1float
		flw ft0,0(t0)
		feq.s t0,ft0,fa0
		beq t0,zero,RETURN_RA
		
		# caso nao entre em nenhum dos ifs da dp, calcular menor caminho
#		free_stack(a0)
		#li s3,10000 # numero muito grande, para ser base de menor_caminho
		li t0,10000
		fcvt.s.w fs0,t0# base menor caminho float
		li t1,0 # i = 0
		LOOP_CALC_MD: # iterar da casa 0 ate casa N 
			beq t1,s0,FIM_LOOP_CALCMD
			# verificar se a casa i ja foi visitada:
			li t2,1
			sll t2,t2,t1 # 1 << i
			and t2,a1,t2 # a1 & (1 << i)
			bne t2,zero,CONT_LOOP_CALCMD # se t2 != 0, ou seja, a casa i ja foi visitada nesse loop
				# do contrario, chama a funcao recursivamente
				save_stackf(fa0)
				save_stack(a0)
				save_stack(a1)
				save_stack(ra)
#				save_stack(s3)
				save_stackf(fs0)
				save_stack(t1) # salva v, S, ra, menor_caminho e i na stackpile
				
				mv a0,t1 # a0 = i
				li t0,1
				sll t0,t0,t1 # (1 << i)
				or a1,a1,t0 # a1 = (S | 1<<i)
				jal CAIXEIRO
				# retorna a0 como menor caminho
				free_stack(t1)
#				free_stack(s3)
				free_stackf(fs0)
				free_stack(ra)
				free_stack(a1)
				mul t0,a0,s0 # t0 = (a0 * n)
				add t0,t0,t1 # t0 += t1
				slli t0,t0,2 # t0 * 4 bytes
				add t0,s2,t0 # t0 = endereco de D[a0][s3]
#				lw t0,0(t0) # valor de D[a0][s3]
				flw ft0,0(t0)
#				add t0,a0,t0 # q = ret + D[a0][s3]
				fadd.s ft0,fa0,ft0
				free_stack(a0)
				free_stackf(fa0)
#				bgt t0,s3,CONT_LOOP_CALCMD
				flt.s t0,ft0,fs0
#				bgt ft0,fs0,CONT_LOOP_CALCMD
				beqz t0,CONT_LOOP_CALCMD
#					mv s3,t0 # menor_distancia = ret + D[a0][s3]
					fcvt.s.w ft1,zero
					fadd.s fs0,ft0,ft1
					
					# salva no savepath
					mul t0,a0,s0 # t0 = (a0 * n)
					add t0,t0,a1 # t0 + a1
					slli t0,t0,2 # t0 * 4 bytes
					save_stack(t1)
					la t1,savepath
					add t0,t1,t0
					free_stack(t1)
					sw t1,0(t0) # salva o i em savepath[a0][a1]
				
			
			CONT_LOOP_CALCMD:
				addi t1,t1,1
				j LOOP_CALC_MD
		
		FIM_LOOP_CALCMD:
			mul t0,a0,s0 # a0 * n
			add t0,t0,a1 # (a0 * n) + a1
			slli t0,t0,2 # * 4 bytes
			la t1,dp
			add t1,t1,t0 # t1 = endereco de dp[a0][a1]
#			sw s3,0(t1)
			fsw fs0,0(t1)
#			mv a0,s3
			fcvt.s.w ft0,zero
			fadd.s fa0,fs0,ft0
			j RETURN_RA
			ebreak
	
	RETURN_RA:
		# retorna fa0 = menor distancia
		ret
PRINTORDENADOS:
	la t0,N
	lw s0,0(t0) # s0 = n
	la s1,savepath # s1 = savepath
	
	li s2,0 # casa atual
	li s3,1 # bitmask = 000001
	li s4,0 # i = 0
	
	la s5,C
	la s6,printvet
	
	lw t0,0(s5) # x0
	lw t1,4(s5) # y0
	sw t0,0(s6)
	sw t1,4(s6)
	addi s6,s6,8 # inicia em printvet[1]
	
	LOOPPO:
		mul t0,s0,s2 # t0 = casa atual * n
		add t0,t0,s3 # t0 = (casa atual*n) + bitmask
		slli t0,t0,2
		add t0,s1,t0 # t0 = savepath[casa_atual][bitmask]
		lw s2,0(t0)
		lw a0,0(t0)
		li a7,1
		ecall 
		
		# pegar (s2)esima casa de C, e salvar no printvet
		slli t1,s2,3
		add t0,s5,t1 # c + (s2 * 4 bytes)
		lw t1,0(t0)
		sw t1,0(s6) # salva x em printvet
		lw t1,4(t0)
		sw t1,4(s6) # salva y em printvet
		
		la a0,blank_line
		li a7,4
		ecall
		
		li t1,1
		sll t1,t1,s2
		or s3,s3,t1 # incrementa bitmask
		addi s6,s6,8 # incrementa printvet
		
		addi s4,s4,1 # incrementa contador
		bne s4,s0,LOOPPO
		
	VOLTAPO:
		ret

PRINT_C_VET:
	li s0,6
	la s1,C
	li s2,0
	la s3,printvet
	
	LOOPCVET:
		beq s2,s0,FIMLOOPCVET
		lw a0,0(s1)
		li a7,1
		ecall
		
		la a0,blank_line
		li a7,4
		ecall
		
		lw a0,4(s1)
		li a7,1
		ecall
		
		la a0,next_line
		li a7,4
		ecall
		
		addi s2,s2,1
		addi s1,s1,8
		j LOOPCVET
		
	FIMLOOPCVET:
		la a0,next_line
		li a7,4
		ecall
		li s2,0
		
	LOOP2CVET:
		beq s2,s0,FIM2LOOPCVET
		lw a0,0(s3)
		li a7,1
		ecall
		
		la a0,blank_line
		li a7,4
		ecall
		
		lw a0,4(s3)
		li a7,1
		ecall
		
		la a0,next_line
		li a7,4
		ecall
		
		addi s2,s2,1
		addi s3,s3,8
		j LOOP2CVET
		
	FIM2LOOPCVET:
		ret

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
		li a4,0x0F
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
		li a4,0x0F
		li a5,0
		li a7,147
		ecall
		
		ret

PRINT_MATRIZ_INT:
	mv s0,a0 # s0 = n
	mv s1,a1 # s1 = matriz a ser impressa
	li s2,0 # i = 0
	
	la a0,next_line
	li a7,4
	ecall
			
	FOR1INT:
		beq s2,s0,FIMFOR1INT
		li s3,0 # j = 0
		
		FOR2INT:
			beq s3,s0,FIMFOR2INT
			lw a0,0(s1)
			li a7,1
			ecall
			
			la a0,blank_line
			li a7,4
			ecall
			
			addi s1,s1,4
			addi s3,s3,1
			j FOR2INT
			
		FIMFOR2INT:
			la a0,next_line
			li a7,4
			ecall
			
			addi s2,s2,1
			j FOR1INT
		
	FIMFOR1INT:
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
