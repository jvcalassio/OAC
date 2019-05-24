#################################################
# Responsavel por gerenciar movimentos do Mario
#################################################
.eqv START_MARIO_X_FASE1 84
.eqv START_MARIO_Y_FASE1 199

.data
.include "../sprites/bin/mario_parado.s"
.include "../sprites/bin/mario_andando_p1.s"
.include "../sprites/bin/mario_andando_p2.s"
.include "../sprites/bin/mario_andando_p3.s"
.include "../sprites/bin/mario_pulando.s"
.include "../sprites/bin/mario_pulando_queda.s" 
mario_state: .byte 0x00 # salva estado atual do mario
pulo_px: .byte 0x00, 0x00 # salva pixels movidos no pulo
pos_mario: .half 84,199 # salva posicao atual do mario (x,y)
.text

# Printa o Mario na posicao inicial
# Sem argumentos
INIT_MARIO:
	save_stack(ra)
	la t0,fase
	lw t0,0(t0) # fase atual
	la t1,fase1
	beq t0,t1,INIT_MARIO_F1 # se fase atual for fase 1, printa mario parado na fase 1
	j FIM_INIT_MARIO
	
	INIT_MARIO_F1:
		la t0,pos_mario
		li a0,START_MARIO_X_FASE1
		li a1,START_MARIO_Y_FASE1 # seta posicao x e y inicial do mario na fase 1
		sh a0,0(t0)
		sh a1,2(t0) # salva na memoria, na variavel de posicao do mario
		la t0,display
		lw a2,0(t0) # printa no display correto
		la a3,mario_parado
		
		la t0,mario_state # seta mario_state como 0
		sh zero,0(t0) # seta 00000 no mario state (parado no chao virado pra direita)
		
		jal PRINT_OBJ # printa o mario no display
	
	FIM_INIT_MARIO:
		free_stack(ra)
		ret

# Faz o movimento do mario para a direita
MOVE_MARIO_DIREITA:
	save_stack(a0)
	la t0,pos_mario
	lh t0,0(t0) # t0 = x do mario
	addi t0,t0,16 # adiciona +16 para saber posicao do pe do mario
	srli t0,t0,2 # t0 / 4
	la t1,map_positions
	add t1,t1,t0 # endereco do byte da posicao atual
	addi t1,t1,1 # endereco do byte na posicao a direita
	lb t0,0(t1) # pega byte desejado
	li t1,0x01
	beq t0,t1,MVMD_P1 # caso prox byte seja normal, faz movimento
	li t1,0x08
	beq t0,t1,FIM_MVMD # caso prox byte seja parede, faz nada
	# caso prox byte seja seja degrau:
	jal MV_1PXUP # move mario 1px acima
	
	MVMD_P1: # faz passo 1
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0) # carrega endereco da fase atual
		la a4,mario_parado
		jal CLEAR_OBJPOS # imprime mapa da fase atual na pos do mario
		
		la t0,pos_mario # pega posicao do mario novamente
		lh a0,0(t0)     # pois a funcao anterior modifica os valores
		lh a1,2(t0)
		
		addi a0,a0,1 # adiciona +1 no X
		sh a0,0(t0)
		la t0,display 
		lw a2,0(t0) 
		la a3,mario_andando_p1
		jal PRINT_OBJ # printa mario passo 1 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVMD_P2: # faz passo 2
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0)
		la a4,mario_andando_p1
		jal CLEAR_OBJPOS # imprime mapa na pos do mario
		
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		addi a0,a0,1 # adiciona +1 no X
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p2
		jal PRINT_OBJ # printa mario passo 2 na tela
		
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVMD_P3: # faz passo 3
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0)
		la a4,mario_andando_p2
		jal CLEAR_OBJPOS # imprime mapa no lugar do mario
		
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		addi a0,a0,1 # adiciona +1 no X
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p3
		jal PRINT_OBJ # printa mario passo 3 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVMD_P0: # faz mario parado novamente
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0)
		la a4,mario_andando_p3
		jal CLEAR_OBJPOS
		
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		addi a0,a0,1 # adiciona +1 no X
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_parado

		jal PRINT_OBJ # printa mario passo final na tela
	
	# com isso, o mario se movimentou um total de 4px
	FIM_MVMD:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		sb t1,0(t0) # salva o estado atual do mario
		
		free_stack(a0) # devolve valor de a0
		j MAINLOOP
	
MOVE_MARIO_ESQUERDA:
	save_stack(a0)
	# colisao com as paredes
	la t0,pos_mario
	lh t0,0(t0) # t0 = x do mario
	addi t0,t0,12
	srli t0,t0,2 # t0 / 4
	la t1,map_positions
	add t1,t1,t0 # endereco do byte da posicao atual, no mapa
	addi t1,t1,1 # endereco do byte na posicao a direita
	lb t0,0(t1) # pega byte desejado
	li t1,0x01
	beq t0,t1,MVME_P1 # caso prox byte seja normal, faz movimento
	li t1,0x08
	beq t0,t1,FIM_MVME # caso prox byte seja parede, faz nada
	# caso prox byte seja degrau:
	save_stack(ra)
	jal MV_1PXDW
	free_stack(ra)
	
	MVME_P1: # faz passo 1
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2) # carrega endereco do display atual
		la t0,fase
		lw a3,0(t0) # carrega endereco da imagem do mapa atual
		la a4,mario_parado
		jal CLEAR_OBJPOS # imprime mapa na pos do mario
		
		la t0,pos_mario # pega posicao do mario novamente
		lh a0,0(t0)     # pois a funcao anterior modifica os valores
		lh a1,2(t0)
		
		addi a0,a0,-1 # adiciona -1 no X
		sh a0,0(t0)
		la t0,display 
		lw a2,0(t0) 
		la a3,mario_andando_p1
		jal PRINT_OBJ_MIRROR # printa mario passo 1 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVME_P2: # faz passo 2
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0)
		la a4,mario_andando_p1
		jal CLEAR_OBJPOS # imprime mapa na pos do mario
		
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		addi a0,a0,-1 # adiciona -1 no X
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p2
		jal PRINT_OBJ_MIRROR # printa mario passo 2 na tela
		
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVME_P3: # faz passo 3
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0)
		la a4,mario_andando_p2
		jal CLEAR_OBJPOS # imprime mapa no lugar do mario
		
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		addi a0,a0,-1 # adiciona -1 no X
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p3
		jal PRINT_OBJ_MIRROR # printa mario passo 3 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVME_P0: # faz mario parado novamente
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la t0,fase
		lw a3,0(t0)
		la a4,mario_andando_p3
		jal CLEAR_OBJPOS
		
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		addi a0,a0,-1 # adiciona -1 no X
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_parado

		jal PRINT_OBJ_MIRROR # printa mario passo final na tela
	
	# com isso, o mario se movimentou um total de -4px
	FIM_MVME:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x14
		ori t1,t1,0x04
		sb t1,0(t0) # salva o estado atual do mario (parado virado pra esquerda)
		
		free_stack(a0) # devolve valor de a0
		j MAINLOOP

# move o mario 1px acima, caso encontre um degrau
MV_1PXUP:
	la t0,pos_mario
	lh t1,2(t0)
	addi t1,t1,-1
	sh t1,2(t0) # faz mario subir 1px
	ret
		
MV_1PXDW:
	la t0,pos_mario
	lh t1,2(t0)
	addi t1,t1,1
	sh t1,2(t0) # faz mario descer 1px
	ret

# faz movimento do mario pra cima, na escada
# a ser editado
# temporario, apenas para debug do mapeamento
# reescrever tudo!
MOVE_MARIO_CIMA:
	save_stack(ra)
	# verifica escadas
	la t0,pos_mario
	lh t0,0(t0) # t0 = x do mario
	srli t0,t0,2 # t0 = x / 4, para alinhar com mapa
	la t1,map_ladder
	add t1,t1,t0 # posicao x atual do mario
	lb t0,0(t1) # pega byte da posicao pra ver se tem escada
	li t1,0x02
	bne t0,t1,FIM_MOVE_MARIO_CIMA # se nao for escada, nao faz nada
	# fim verif escada
	
	MARIO_SOBE_ESCADA: # se for escada, sobe
		mv a0,t0
		li a7,34
		ecall
		
		la t0,pos_mario
		lh a0,0(t0) # carrega X
		lh a1,2(t0) # carrega y
		li a2,DISPLAY0
		la a3,fase1
		la a4,mario_parado
		jal CLEAR_OBJPOS # limpa mario na posicao atual
		
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a1,a1,-4
		sh a1,2(t0)
		li a2,DISPLAY0
		la a3,mario_parado
		jal PRINT_OBJ # printa mario na posicao acima
		
	
	FIM_MOVE_MARIO_CIMA:
		free_stack(ra)
		j MAINLOOP

# faz movimento do mario pra baixo, na escada
MOVE_MARIO_BAIXO:
	j MAINLOOP

# faz o pulo do mario pra cima (parado)
# precisa printar o mario na posicao atual, ou seja, se tiver virado pra esquerda, printar pra esquerda
# o mesmo virado pra direita
# sprite de pulo sempre o mesmo do ponto de subida ate o topo, ate voltar ao ponto inicial de subida e muda pro fim_pulo
MARIO_PULO_UP:
	# mover mario 8px acima
	li a0,26
	li a7,32
	ecall # sleep de 26ms, entre cada movimento para cima, para ficar mais fluido
	
	la t0,pos_mario
	lh a0,0(t0)
	lh a1,2(t0)
	la a2,display
	lw a2,0(a2)
	la a3,fase
	lw a3,0(a3)
	la a4,mario_pulando
	jal CLEAR_OBJPOS # limpa mario na posicao atual
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,12
	beq t2,t3,MARIO_PULO_UP_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	beq t1,t3,MARIO_PULO_UP_RESET # se ambos tiverem em 12, termina pulo
	bgt t1,zero,MARIO_PULO_UP_DESCE # se descida tiver > 0 e < 12, faz movimento de descer
	bgt t2,zero,MARIO_PULO_UP_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_UP_INIT_SUBIDA:
		la t0,pos_mario
		lh a0,0(t0) # carrega X atual do mario
		lh a1,2(t0) # carrega Y atual do mario
		addi a1,a1,-8 # move 8px acima
		sh a1,2(t0) # salva nova posicao do mario
		la a2,display
		lw a2,0(a2) # carrega end do display atual
		la a3,mario_pulando # carrega end do mario pulando
	
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x05
		ori t1,t1,0x01 # seta mario status como pulando pra esquerda ou direita
		andi t2,t1,0x04
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		beqz t2,PULO_UP_PDIR
		beq zero,zero,PULO_UP_PESQ
		
	MARIO_PULO_UP_SOBE:
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a1,a1,-1
		sh a1,2(t0)
		la a2,display
		lw a2,0(a2)
		la a3,mario_pulando
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x05
		ori t1,t1,0x01 # seta mario status como pulando pra esquerda ou direita
		andi t2,t1,0x04
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1 # sobe 1px
		sb t1,1(t0)
		beqz t2,PULO_UP_PDIR
		beq zero,zero,PULO_UP_PESQ
		
	MARIO_PULO_UP_INIT_DESCIDA:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1
		sb t1,1(t0) # faz o subida = 13, assim nao conflita nos beqs la em cima
		lb t1,0(t0)
		addi t1,t1,8
		sb t1,0(t0) # adiciona 1 na descida
		
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0) # ele nao se move nessa iteracao
		la a2,display
		lw a2,0(a2)
		la a3,mario_pulando
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x05
		ori t1,t1,0x01 # seta mario status como pulando pra esquerda ou direita
		andi t2,t1,0x04
		beqz t2,PULO_UP_PDIR
		beq zero,zero,PULO_UP_PESQ
	
	MARIO_PULO_UP_DESCE:
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a1,a1,1
		sh a1,2(t0)
		la a2,display
		lw a2,0(a2)
		la a3,mario_pulando
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x05
		ori t1,t1,0x01 # seta mario status como pulando pra esquerda ou direita
		andi t2,t1,0x04
		
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px
		sb t1,0(t0)
		beqz t2,PULO_UP_PDIR
		beq zero,zero,PULO_UP_PESQ
	
	MARIO_PULO_UP_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a1,a1,8
		sh a1,2(t0)
		la a2,display
		lw a2,0(a2)
		la a3,mario_parado
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x05
		ori t1,t1,0x01 # seta mario status como pulando pra esquerda ou direita
		andi t2,t1,0x04
		
		beqz t2,PULO_UP_PDIR
		
	PULO_UP_PESQ: # pula pra cima parado, virado pra esquerda
		jal PRINT_OBJ_MIRROR
		j FIM_PULO_UP
	PULO_UP_PDIR: # pula pra cima parado, virado pra direita
		jal PRINT_OBJ
	
	FIM_PULO_UP:
		j MAINLOOP
