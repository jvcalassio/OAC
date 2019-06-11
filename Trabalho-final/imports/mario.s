#################################################
# Responsavel por gerenciar movimentos do Mario
#################################################
.data
# Sprites
.include "../sprites/bin/mario_parado.s"
.include "../sprites/bin/mario_andando_p1.s"
.include "../sprites/bin/mario_andando_p2.s"
.include "../sprites/bin/mario_pulando.s"
.include "../sprites/bin/mario_pulando_queda.s" 
.include "../sprites/bin/mario_escada.s"
.include "../sprites/bin/mario_escada_p1.s"
.include "../sprites/bin/mario_escada_p2.s"
.include "../sprites/bin/mario_costas.s"
.include "../sprites/bin/mario_morrendo_y.s"
.include "../sprites/bin/mario_morrendo_x.s"
.include "../sprites/bin/mario_morto.s"

# Sons
.include "../sounds/mario_sounds.s"

# Variaveis
mario_state: .byte 0 # salva estado atual do mario
pulo_px: .byte 0,0 # salva pixels movidos no pulo
pos_mario: .half 0,0 # salva posicao atual do mario (x,y)

movement_counter: .word 0 # contador de passos dos movimentos
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
		sw zero,0(t0) # zera pos mario
		set_mario_move(START_MARIO_X_FASE1,START_MARIO_Y_FASE1,mario_parado)
		call PRINT_OBJ # printa mario na posicao inicial, reseta pos mario
		
		la t0,mario_state # seta mario_state como 0
		sb zero,0(t0) # seta 00000 no mario state (parado no chao virado pra direita)
		la t0,pulo_px
		sh zero,0(t0) # reseta pulopx
	
	FIM_INIT_MARIO:
		free_stack(ra)
		ret
	
# Remove um sprite do mario na posicao atual
# a4 = sprite a ser removido (por causa do tamanho)	
REMOVE_MARIO:
	save_stack(ra)
	la t0,pos_mario # carrega posicao do mario
	lh a0,0(t0) # carrega x
	lh a1,2(t0) # carrega y
	la a2,display
	lw a2,0(a2) # carrega display atual
	la a3,fase
	lw a3,0(a3) # carrega fase atual
	call CLEAR_OBJPOS # limpa mario na posicao atual
	free_stack(ra)
	ret
	
# Move o mario em +X,+Y pixels
# a0 = + x
# a1 = + y
# a3 = sprite
SET_MARIO_MOVEMENT:
	la t0,pos_mario # pega posicao do mario novamente
	lh t1,0(t0)     # pois a funcao anterior modifica os valores
	lh t2,2(t0)
	add a0,a0,t1 # adiciona +x no X
	add a1,a1,t2 # adiciona +y no Y
	sh a0,0(t0) # grava X
	sh a1,2(t0) # grava y
	la t0,display
	lw a2,0(t0) # carrega qual display usar
	ret

# Faz o movimento do mario para a direita
MOVE_MARIO_DIREITA:
	save_stack(a0)
	save_stack(ra)
	
	li a0,1
	call MARIO_COLLISIONS # verifica permissao do movimento
	beqz a0,FIM_MVMD_PAROU # se nao for permitido, so retorna
	
	la t0,movement_counter
	lw t1,0(t0) # contador de movimento
	
	# cont == 0, passo 1
	beqz t1,MVMD_P1 #
	# cont == 1, passo 2
	addi t2,zero,1
	beq t1,t2,MVMD_P2
	# cont == 2, passo 3
	addi t2,zero,2
	beq t1,t2,MVMD_P3
	# cont == 3, passo 0
	addi t2,zero,3
	beq t1,t2,MVMD_P0
	j FIM_MVMD_RET
	
	MVMD_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		set_mario_move(1,0,mario_andando_p1) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 1 na tela
		
		la t0,movement_counter
		addi t1,zero,1
		sw t1,0(t0) # salva q fez passo 1
		
		# verificacao de degraus
		call MARIO_VERIF_DEGRAU
		beqz a0,FIM_MVMD_ANDANDO # se nao tiver degrau, nao faz nada
		li t0,0x03
		beq a0,t0,DDIR_TIPO_D # se tiver degrau do tipo D
		# se tiver degrau do tipo A, desce
		jal MV_1PXDW
		j FIM_MVMD_ANDANDO
	
		DDIR_TIPO_D: # se tiver degrau do tipo D, desce
		jal MV_1PXUP
		
		j FIM_MVMD_ANDANDO
	
	MVMD_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(2,0,mario_andando_p2) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 2 na tela
	
		la t0,movement_counter
		addi t1,zero,2
		sw t1,0(t0) # salva q fez passo 2
		
		j FIM_MVMD_RET
		
	MVMD_P3: # faz passo 3
		rmv_mario(mario_andando_p2)
		
		set_mario_move(1,0,mario_andando_p1) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 3 na tela
		
		la t0,movement_counter
		addi t1,zero,3
		sw t1,0(t0) # salva q fez passo 3
		
		#j FIM_MVMD_RET
		
		la t0,last_key
		lw t1,0(t0) # carrega ultima tecla
		li t2,100
		bne t1,t2,FIM_MVMD_RET # se nao foi D a ultima tecla, ignora
		# se foi, verifica se foi ha menos de 150ms
		lw t1,4(t0) # carrega tempo
		addi a7,zero,30
		ecall
		sub t1,a0,t1 # t1 = tempo atual - tempo da tecla
		addi t2,zero,150
		bgt t1,t2,FIM_MVMD_RET # se a diferenca de tmepo for maior q 150ms, o mario para
		# se for menor, o mario reseta pro passo 1
		la t0,movement_counter
		add t1,zero,zero
		sw t1,0(t0)
		
		j FIM_MVMD_RET
		
	MVMD_P0: # faz mario parado novamente
		rmv_mario(mario_andando_p1)
		
		set_mario_move(0,0,mario_parado) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo final na tela
		
		la t0,movement_counter
		add t1,zero,zero
		sw t1,0(t0) # salva q fez passo 0
		
		j FIM_MVMD_PAROU
	
	# com isso, o mario se movimentou um total de 4px
	FIM_MVMD_ANDANDO:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # parado pra direita
		ori t1,t1,0x02 # andando
		sb t1,0(t0) # salva estado de andando
		j FIM_MVMD_RET
	FIM_MVMD_PAROU:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		sb t1,0(t0) # salva o estado atual do mario
	FIM_MVMD_RET:
		free_stack(ra)
		free_stack(a0) # devolve valor de a0
		#tail MAINLOOP_RET
		ret
	
MOVE_MARIO_ESQUERDA:
	save_stack(a0)
	save_stack(ra)
	
	li a0,2
	call MARIO_COLLISIONS # verifica permissao do movimento
	beq a0,zero,FIM_MVME_PAROU # se nao for permitido, retorna
	
	la t0,movement_counter
	lw t1,0(t0) # contador de movimento
	
	# cont == 0, passo 1
	beqz t1,MVME_P1 #
	# cont == 1, passo 2
	addi t2,zero,1
	beq t1,t2,MVME_P2
	# cont == 2, passo 3
	addi t2,zero,2
	beq t1,t2,MVME_P3
	# cont == 3, passo 0
	addi t2,zero,3
	beq t1,t2,MVME_P0
	j FIM_MVME_RET
	
	MVME_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		set_mario_move(-1,0,mario_andando_p1) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 1 na tela
		
		la t0,movement_counter
		addi t1,zero,1
		sw t1,0(t0) # salva q fez passo 1
	
		# verificacao de degraus
		call MARIO_VERIF_DEGRAU
		beqz a0,FIM_MVME_ANDANDO # se nao tiver degrau, nao faz nada
		li t0,0x03
		beq a0,t0,DESQ_TIPO_D # se tiver degrau do tipo D
		# se tiver degrau do tipo A, sobe
		jal MV_1PXUP
		j FIM_MVME_ANDANDO
	
		DESQ_TIPO_D: # se tiver degrau do tipo D, desce
		jal MV_1PXDW
		j FIM_MVME_ANDANDO
	
	MVME_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(-2,0,mario_andando_p2) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 2 na tela
		
		la t0,movement_counter
		addi t1,zero,2
		sw t1,0(t0) # salva q fez passo 2
		
		j FIM_MVME_RET
	
	MVME_P3: # faz passo 3
		rmv_mario(mario_andando_p2)
		
		set_mario_move(-1,0,mario_andando_p1) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 3 na tela
	
		la t0,movement_counter
		addi t1,zero,3
		sw t1,0(t0) # salva q fez passo 3
		
		#j FIM_MVMD_RET
		
		# LEMBRAR DE AVALIAR O TEMPO DA ULTIMA TECLA NA PLACA
		la t0,last_key
		lw t1,0(t0) # carrega ultima tecla
		li t2,97
		bne t1,t2,FIM_MVME_RET # se nao foi A a ultima tecla, ignora
		# se foi, verifica se foi ha menos de 150ms
		lw t1,4(t0) # carrega tempo
		addi a7,zero,30
		ecall
		sub t1,a0,t1 # t1 = tempo atual - tempo da tecla
		addi t2,zero,150
		bgt t1,t2,FIM_MVMD_RET # se a diferenca de tempo for maior q 150ms, o mario para
		# se for menor, o mario reseta pro passo 1
		la t0,movement_counter
		add t1,zero,zero
		sw t1,0(t0)
		j FIM_MVME_RET
	
	MVME_P0: # faz mario parado novamente
		rmv_mario(mario_andando_p1)
		
		set_mario_move(0,0,mario_parado) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo final na tela
		
		la t0,movement_counter
		add t1,zero,zero
		sw t1,0(t0) # salva q fez passo 0
		
		j FIM_MVME_PAROU
	
	# com isso, o mario se movimentou um total de -4px
	FIM_MVME_ANDANDO:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x14
		ori t1,t1,0x06
		sb t1,0(t0) # salva o estado atual do mario (andando virado pra esquerda)
		j FIM_MVME_RET
	FIM_MVME_PAROU:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x14
		ori t1,t1,0x04
		sb t1,0(t0) # salva o estado atual do mario (parado virado pra esquerda)
	FIM_MVME_RET:
		free_stack(ra)
		free_stack(a0) # devolve valor de a0
		ret

# move o mario 1px acima, caso encontre um degrau
MV_1PXUP:
	la t0,pos_mario
	lh t1,2(t0)
	addi t1,t1,-1
	sh t1,2(t0) # faz mario subir 1px
	save_stack(a0)
	li a0,1
	li a7,1
	ecall
	free_stack(a0)
	ret
		
MV_1PXDW:
	la t0,pos_mario
	lh t1,2(t0)
	addi t1,t1,1
	sh t1,2(t0) # faz mario descer 1px
	save_stack(a0)
	li a0,2
	li a7,1
	ecall
	free_stack(a0)
	ret
	
# Faz movimento do Mario pra cima, nas escadas
MOVE_MARIO_CIMA:
	li a0,5
	call MARIO_COLLISIONS # verifica se pode subir
	beqz a0,FIM_MOVE_MARIO_CIMA # se for 0 (nao pode subir), soh sai
	li t0,0x05
	beq a0,t0,MARIO_SOBE_NV # se o byte acima for um fim de escada, sobe nivel
	# se for apenas uma escada, sobe normal

	MARIO_SOBE_ESCADA: # enquanto o mario esta subindo a escada
		rmv_mario(mario_parado) # retira o mario na posicao atual
		set_mario_move(0,-4,mario_escada) # seta impressao do mario
		
		# muda mario state para escada
		la t0,mario_state
		lb t1,0(t0)
		ori t1,t1,0x08 # seta escada = 1
		sb t1,0(t0)
		
		# pega emprestado pulo_px pra fazer os passos do mario na escada
		# se 0, faz passo normal, se 1, faz passo espelhado
		la t0,pulo_px
		lb t0,0(t0)
		beqz t0,MSE_P1
		j MSE_P2
		
		MSE_P1:
			call PRINT_OBJ
			li t0,1
			la t1,pulo_px
			sb t0,0(t1) # salva como fez p1
			j FIM_MOVE_MARIO_CIMA
		MSE_P2:
			call PRINT_OBJ_MIRROR
			la t0,pulo_px
			sb zero,0(t0) # salva como fez p2
			j FIM_MOVE_MARIO_CIMA
	MARIO_SOBE_NV: # quando ele chega no final e precisa subir pro degrau
		rmv_mario(mario_escada)
		set_mario_move(0,-2,mario_escada_p1)
		call PRINT_OBJ # printa sprite de subindo
		
		li a0,30
		li a7,32
		ecall # sleep de 40ms
		
		rmv_mario(mario_escada_p1)
		set_mario_move(0,-2,mario_escada_p2)
		call PRINT_OBJ
		
		li a0,30
		li a7,32
		ecall # sleep de mais 40ms
		
		rmv_mario(mario_escada_p2)
		set_mario_move(0,-4,mario_costas)
		call PRINT_OBJ
		
		# devolve pulo_px emprestado
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0)
		
		# reseta mario state
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x04 # mantem lado q ele tava virado, muda todo o resto pra 0
		sb t1,0(t0)
	
	FIM_MOVE_MARIO_CIMA:
		tail MAINLOOP_RET

# Faz movimento do Mario pra baixo, na escada
MOVE_MARIO_BAIXO:
	li a0,6
	call MARIO_COLLISIONS # verifica se pode descer
	beqz a0,FIM_MOVE_MARIO_BAIXO # se for 0 (nao pode descer), soh sai
	li t0,0x05
	beq a0,t0,MARIO_DESCE_NV # se o byte abaixo for um fim de escada, desce p/ escada
	li t0,0x01
	beq a0,t0,MARIO_DESCE_SETCHAO # se for o chao, chegou ao fim da escada
	# se for apenas uma escada, desce normal
	
	MARIO_DESCE_ESCADA: # enquanto o mario esta subindo a escada
		rmv_mario(mario_parado) # retira o mario na posicao atual
		set_mario_move(0,4,mario_escada) # seta impressao do mario
		
		# pega emprestado pulo_px pra fazer os passos do mario na escada
		# se 0, faz passo normal, se 1, faz passo espelhado
		la t0,pulo_px
		lb t0,0(t0)
		beqz t0,MDE_P1
		j MDE_P2
		
		MDE_P1:
			call PRINT_OBJ
			li t0,1
			la t1,pulo_px
			sb t0,0(t1) # salva como fez p1
			j FIM_MOVE_MARIO_BAIXO
		MDE_P2:
			call PRINT_OBJ_MIRROR
			la t0,pulo_px
			sb zero,0(t0) # salva como fez p2
			j FIM_MOVE_MARIO_BAIXO
	MARIO_DESCE_NV: # quando ele chega no final e precisa subir pro degrau
		rmv_mario(mario_escada)
		set_mario_move(0,2,mario_escada_p1)
		call PRINT_OBJ # printa sprite de subindo
		
		li a0,30
		li a7,32
		ecall # sleep de 30ms
		
		rmv_mario(mario_escada_p1)
		set_mario_move(0,2,mario_escada_p2)
		call PRINT_OBJ
		
		li a0,30
		li a7,32
		ecall # sleep de mais 30ms
		
		rmv_mario(mario_escada_p2)
		set_mario_move(0,4,mario_escada)
		call PRINT_OBJ_MIRROR
		
		# muda mario state pra escada
		la t0,mario_state
		lb t1,0(t0)
		ori t1,t1,0x08 # seta escada = 1
		sb t1,0(t0)
		
		j FIM_MOVE_MARIO_BAIXO
		
	MARIO_DESCE_SETCHAO:
		rmv_mario(mario_escada)
		set_mario_move(0,4,mario_escada)
		call PRINT_OBJ_MIRROR
		# devolve pulo_px emprestado
		la t0,pulo_px
		sh zero,0(t0)
		
		# reseta mario state
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x04 # mantem lado q ele tava virado, muda todo o resto pra 0
		sb t1,0(t0)
	
	FIM_MOVE_MARIO_BAIXO:
		tail MAINLOOP_RET

# faz o pulo do mario pra cima (parado)
# precisa printar o mario na posicao atual, ou seja, se tiver virado pra esquerda, printar pra esquerda
# o mesmo virado pra direita
# sprite de pulo sempre o mesmo do ponto de subida ate o topo, ate voltar ao ponto inicial de subida e muda pro fim_pulo
MARIO_PULO_UP:
	save_stack(s0)
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x1A # verifica se pode pular
	bne t1,zero,FIM_PULO_UP # se nao puder pular, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,12
	beq t2,t3,MARIO_PULO_UP_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	beq t1,t3,MARIO_PULO_UP_RESET # se ambos tiverem em 12, termina pulo
	bgt t1,zero,MARIO_PULO_UP_DESCE # se descida tiver > 0 e < 12, faz movimento de descer
	bgt t2,zero,MARIO_PULO_UP_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_UP_INIT_SUBIDA:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x04 # verifica se esta pulando pra esquerda ou direita
		ori t1,t1,0x01 # seta mario status como pulando
		sb t1,0(t0) # grava mario state
		andi s0,t1,0x04 # verificador de qual lado o mario esta
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		set_mario_move(0,-8,mario_pulando) # se move 8px pra cima
		
		beqz s0,PULO_UP_PDIR
		j PULO_UP_PESQ
		
	MARIO_PULO_UP_SOBE:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1 # sobe 1px no pulopx
		sb t1,1(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi s0,t1,0x04 # verificador de qual o lado do mario
		
		set_mario_move(0,-1,mario_pulando) # se move 1px pra cima
		
		beqz s0,PULO_UP_PDIR
		j PULO_UP_PESQ
		
	MARIO_PULO_UP_INIT_DESCIDA:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1
		sb t1,1(t0) # faz o subida = 13, assim nao conflita nos beqs la em cima
		lb t1,0(t0)
		addi t1,t1,8
		sb t1,0(t0) # adiciona 8 na descida
		
		la t0,mario_state
		lb t1,0(t0)
		andi s0,t1,0x04 # verificador de qual o lado do mario
		
		set_mario_move(0,0,mario_pulando) # nao se move nesse frame
		
		beqz s0,PULO_UP_PDIR
		j PULO_UP_PESQ
	
	MARIO_PULO_UP_DESCE:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi s0,t1,0x04 # pega para qual lado o mario esta virado
		
		set_mario_move(0,1,mario_pulando) # se move 1px pra baixo
		
		beqz s0,PULO_UP_PDIR
		j PULO_UP_PESQ
	
	MARIO_PULO_UP_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb s0,0(t0)
		andi s0,s0,0x04
		sb s0,0(t0) # salva estado do mario no chao, virado pro lado onde ja estava
		
		set_mario_move(0,8,mario_parado) # se move 8px pra baixo
		
		beqz s0,PULO_UP_PDIR
		
	PULO_UP_PESQ: # pula pra cima parado, virado pra esquerda
		call PRINT_OBJ_MIRROR
		j FIM_PULO_UP
	PULO_UP_PDIR: # pula pra cima parado, virado pra direita
		call PRINT_OBJ
	
	FIM_PULO_UP:
		free_stack(s0)
		tail MAINLOOP_RET

# realiza mario pulando pra direita em movimento
MARIO_PULO_DIR:
	save_stack(s0)
	la t0,mario_state 
	lb t1,0(t0)
	andi t1,t1,0x18 # verifica se pode pular
	bne t1,zero,FIM_PULO_DIR # se nao puder pular, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
	# posicao do mario no map
	mario_mappos(s0)
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,12
	beq t2,t3,MARIO_PULO_DIR_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	beq t1,t3,MARIO_PULO_DIR_RESET # se ambos tiverem em 12, termina pulo
	bgt t1,zero,MARIO_PULO_DIR_DESCE # se descida tiver > 0 e < 12, faz movimento de descer
	bgt t2,zero,MARIO_PULO_DIR_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_DIR_INIT_SUBIDA:
		# verifica se em algum ponto da trajetoria tem uma parede
		# se tiver, nao realiza pulo
		mv t0,s0
		li t1,6
		MPDIS_CHECKWALL:
			beqz t1,MPDIS_CHECKWALL_PASS
			lb t2,0(t0)
			li t3,0x08
			beq t2,t3,MPDIS_CHECKWALL_FAIL # se tiver, nao pula
			addi t0,t0,1 # passa p/ prox endereco do map
			addi t1,t1,-1 # decrementa i
			j MPDIS_CHECKWALL
		MPDIS_CHECKWALL_FAIL:
			set_mario_move(0,0,mario_parado)
			j PULO_DIR_ANIM
		MPDIS_CHECKWALL_PASS: # se nao tiver nenhuma parede, faz pulo
	
		la t0,mario_state
		li t1,0x03
		sb t1,0(t0) # grava mario state de pulando pra direita
		
		# verificar se tem degrau
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		set_mario_move(4,-8,mario_pulando) # se move 8px pra cima, 4px pra direita p/ iniciar pulo
		
		j PULO_DIR_ANIM
		
	MARIO_PULO_DIR_SOBE:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1 # sobe 1px no pulopx
		sb t1,1(t0)
		
		set_mario_move(2,-1,mario_pulando) # se move 1px pra cima, 1px pra direita
		
		j PULO_DIR_ANIM
		
	MARIO_PULO_DIR_INIT_DESCIDA:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1
		sb t1,1(t0) # faz o subida = 13, assim nao conflita nos beqs la em cima
		lb t1,0(t0)
		addi t1,t1,8
		sb t1,0(t0) # adiciona 8 pra descida
		
		set_mario_move(0,0,mario_pulando) # se move apenas 1px pra direita, sem subir nem descer
		
		j PULO_DIR_ANIM
	
	MARIO_PULO_DIR_DESCE:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		set_mario_move(2,1,mario_pulando) # se move 1px pra baixo, 1px pra direita
		
		j PULO_DIR_ANIM
	
	MARIO_PULO_DIR_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		sb zero,0(t0) # salva estado do mario no chao, virado pra direita
		
		# verifica se em algum dos 24px horizontais anteriores (referentes a dist do pulo) tinha degrau
		# a cada degrau, adiciona 1 no Y do mario pos
		save_stack(s1)
		#mario_mappos(s0) # pega posicao atual do mario
		addi s0,s0,1 # posicao a frente no x, onde o mario cai apos a prox animacao (no x)
		addi s0,s0,160 # posicao alinhada no y, onde o mario cai apos a prox animacao
		li s1,6 # iteracoes
		VERIFD_PULOD:
			beqz s1,FIM_VERIFD_PULOD # se t1 == 0, sai do loop
			lb t2,0(s0) # carrega posicao atual do map
			li t3,0x03
			beq t2,t3,ADD_VERIFD_PULOD # verifica se precisa subir
			li t3,0x02
			beq t2,t3,RMV_VERIFD_PULOD # verifica se precisa descer
			j CONT_VERIFD_PULOD
			ADD_VERIFD_PULOD:
				call MV_1PXUP
				j CONT_VERIFD_PULOD
			RMV_VERIFD_PULOD:
				call MV_1PXDW
			CONT_VERIFD_PULOD:
				addi s1,s1,-1 # decrementa i
				addi s0,s0,-1 # verifica posicao anterior a atual
			j VERIFD_PULOD
		
		FIM_VERIFD_PULOD:
		free_stack(s1)
		set_mario_move(4,8,mario_parado) # se move 8px pra baixo, 4px pra direita p/ finalizar pulo
		
	PULO_DIR_ANIM: # pula pra direita em movimento
		call PRINT_OBJ
	
	FIM_PULO_DIR:
		free_stack(s0)
		tail MAINLOOP_RET

# realiza mario pulando pra esquerda em movimento
MARIO_PULO_ESQ:
	save_stack(s0)
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x18 # verifica se pode pular
	bne t1,zero,FIM_PULO_ESQ # se nao puder, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
	mario_mappos(s0) # pega posicao atual do mario
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,12
	beq t2,t3,MARIO_PULO_ESQ_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	beq t1,t3,MARIO_PULO_ESQ_RESET # se ambos tiverem em 12, termina pulo
	bgt t1,zero,MARIO_PULO_ESQ_DESCE # se descida tiver > 0 e < 12, faz movimento de descer
	bgt t2,zero,MARIO_PULO_ESQ_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_ESQ_INIT_SUBIDA:
		# verifica se em algum ponto da trajetoria tem uma parede
		# se tiver, nao realiza pulo
		mv t0,s0
		li t1,6
		MPEIS_CHECKWALL:
			beqz t1,MPEIS_CHECKWALL_PASS
			lb t2,0(t0)
			li t3,0x08
			beq t2,t3,MPEIS_CHECKWALL_FAIL # se tiver, nao pula
			addi t0,t0,-1 # passa p/ prox endereco do map
			addi t1,t1,-1 # decrementa i
			j MPEIS_CHECKWALL
		MPEIS_CHECKWALL_FAIL:
			set_mario_move(0,0,mario_parado)
			j PULO_ESQ_ANIM
		MPEIS_CHECKWALL_PASS: # se nao tiver nenhuma parede, faz pulo
		
		la t0,mario_state
		li t1,0x07
		sb t1,0(t0) # grava mario state de pulando pra direita
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		set_mario_move(-4,-8,mario_pulando) # se move 8px pra cima, 4px pra esquerda p/ iniciar pulo
		
		j PULO_ESQ_ANIM
		
	MARIO_PULO_ESQ_SOBE:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1 # sobe 1px no pulopx
		sb t1,1(t0)
		
		set_mario_move(-2,-1,mario_pulando) # se move 1px pra cima, 1px pra esquerda
		
		j PULO_ESQ_ANIM
		
	MARIO_PULO_ESQ_INIT_DESCIDA:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1
		sb t1,1(t0) # faz o subida = 13, assim nao conflita nos beqs la em cima
		lb t1,0(t0)
		addi t1,t1,8
		sb t1,0(t0) # adiciona 8 pra descida
		
		set_mario_move(0,0,mario_pulando) # se move apenas 1px pra esquerda, sem subir nem descer
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_DESCE:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		set_mario_move(-2,1,mario_pulando) # se move 1px pra baixo, 1px pra esquerda
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		li t1,0x04
		sb t1,0(t0) # salva estado do mario no chao, virado pra esquerda
	
		#mario_mappos(s0) # pega posicao atual do mario
		# verifica se em algum dos 24px horizontais anteriores (referentes a dist do pulo) tinha degrau
		# a cada degrau, adiciona (ou remove) 1 no Y do mario pos
		save_stack(s1)
		addi s0,s0,-1
		addi s0,s0,160
		li s1,6 # iteracoes
		VERIFD_PULOE:
			beqz s1,FIM_VERIFD_PULOE # se t1 == 0, sai do loop
			lb t2,0(s0) # carrega posicao atual do map
			li t3,0x02
			beq t2,t3,ADD_VERIFD_PULOE # verifica se precisa subir
			li t3,0x03
			beq t2,t3,RMV_VERIFD_PULOE # verifica se precisa descer
			j CONT_VERIFD_PULOE
			ADD_VERIFD_PULOE:
				call MV_1PXUP
				j CONT_VERIFD_PULOE
			RMV_VERIFD_PULOE:
				call MV_1PXDW
			CONT_VERIFD_PULOE:
				addi s1,s1,-1 # decrementa i
				addi s0,s0,1 # verifica posicao q veio antes da atual
			j VERIFD_PULOE
		
		FIM_VERIFD_PULOE:
		free_stack(s1)
		set_mario_move(-4,8,mario_parado) # se move 8px pra baixo, 4px pra esquerda p/ finalizar pulo
		#set_mario_move(0,0,mario_parado)
	PULO_ESQ_ANIM: # pula pra esquerda em movimento
		call PRINT_OBJ_MIRROR
	
	FIM_PULO_ESQ:
		free_stack(s0)
		tail MAINLOOP_RET

#####################################################
# Verifica colisao do mario
# a0 = movimento desejado
#	0 = pular
# 	1 = andar direita	2 = andar esquerda
#	3 = pular direita	4 = pular esquerda
#	5 = subir escada	6 = descer escada
# retorna a0 = 0 (nao permitido), 1 (permitido) pras colisoes
# retorna a0 = bloco, caso seja escadas
#####################################################
MARIO_COLLISIONS:
	save_stack(s0)
	# considereando a mario position e state atual, verificar se o movimento desejado eh permitido
	mario_mappos(s0)
	
	li t0,1
	beq a0,t0,VERIF_MV_DIR
	li t0,2
	beq a0,t0,VERIF_MV_ESQ
	li t0,5
	beq a0,t0,VERIF_MV_CIMA
	li t0,6
	beq a0,t0,VERIF_MV_BAIXO
	j MARIO_COLLISIONS_FIM
	
	VERIF_MV_DIR: # verifica se movimento de andar pra direita eh permitido
		addi s0,s0,1 # posicao a frente
		la t0,mario_state
		lb t1,0(t0) # carrega byte de status
		andi t1,t1,0x08 # verifica bit de escada no status
		lb t0,0(s0)
		andi t0,t0,0x08 # verifica bit de parede no mapa
		or t0,t1,t0 # junta os dois bytes
		bne t0,zero,MARIO_CL_DENY # se qlqr um deles der 1 no bit desejado, nao permite
		j MARIO_CL_ALLOW # se der zero, permite
		
	VERIF_MV_ESQ:
		addi s0,s0,-1 # posicao atras
		la t0,mario_state
		lb t1,0(t0) # carrega byte de status
		andi t1,t1,0x08 # verifica bit de escada no status
		lb t0,0(s0)
		andi t0,t0,0x08 # verifica bit de parede no mapa
		or t0,t1,t0 # junta os dois bytes
		bne t0,zero,MARIO_CL_DENY # se qlqr um deler de 1 no bit, nao permite
		j MARIO_CL_ALLOW # se der zero, passa
		
	VERIF_MV_CIMA:
		addi s0,s0,-80 # linha acima
		
		lb a0,0(s0)
		li a7,1
		#ecall
		
		la a0,blank
		li a7,4
		#ecall
		
		lb a0,0(s0)
		li t0,0x04
		beq a0,t0,MARIO_COLLISIONS_FIM # se for escada
		li t0,0x05
		beq a0,t0,MARIO_COLLISIONS_FIM # se for fim de escada
		j MARIO_CL_DENY # retorna 0
	
	VERIF_MV_BAIXO:
		addi s0,s0,80 # linha abaixo
		lb a0,0(s0)
		li t0,0x04
		beq a0,t0,MARIO_COLLISIONS_FIM # se for escada, retorna
		li t0,0x05
		beq a0,t0,MARIO_COLLISIONS_FIM # se for fim de escada, retorna
		# se nao for nenhuma das escadas, pode ser chao (valido)
		# verificar mario state pra ver se ainda ta na escada, se tiver, permitir
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x08
		beqz t1,MARIO_CL_DENY # se nao tiver bit de escada ligado, nao permite
		# se tiver bit de escada, verifica se esta quase no chao
		li t0,0x01 # se tiver, verifica se eh chao no byte ATUAL
		beq a0,t0,MARIO_COLLISIONS_FIM # se for chao, retorna
		j MARIO_CL_DENY # retorna 0
	
	MARIO_CL_ALLOW:
		li a0,1
		j MARIO_COLLISIONS_FIM
	MARIO_CL_DENY:
		li a0,0
	MARIO_COLLISIONS_FIM:
		free_stack(s0)
		ret
	
##################################################
# Verifica se ha degrau na pos atual. Retorna:
# a0 = degrau tipo A, degrau tipo D, 0 (sem degrau)
##################################################
MARIO_VERIF_DEGRAU:
	mario_mappos(t0)
	
	lb t1,0(t0) # carrega byte da posicao
	li t0,0x03
	beq t0,t1,MV_DEGRAU_D # se byte == D, retorna D
	li t0,0x02
	beq t0,t1,MV_DEGRAU_A # se byte == A, retorna A
	li a0,0x00
	j FIM_MVDDEGRAU # se nao tiver nenhum, retorna 0
	
	MV_DEGRAU_D:
		li a0,0x03
		ret
	MV_DEGRAU_A:
		li a0,0x02
	FIM_MVDDEGRAU:
		ret

# faz gravidade do mario
MARIO_GRAVITY:
	save_stack(ra)
	save_stack(s0)
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x01 # verifica se esta pulando
	bnez t1,FIM_MARIO_GRAVITY # se estiver pulando, sai
	
	mario_mappos(s0)
	lb t1,0(s0) # carrega posicao do mario atual no map
	bnez t1,FIM_MARIO_GRAVITY # se for qualquer coisa exceto 0, sai pois tem chao
	# se for 0, eh ar e tem q cair
	rmv_mario(mario_parado)
	
	addi s0,s0,80 # verificar linha abaixo
	lb t1,0(s0)
	beqz t1,PRINT_FALL_MARIO_GRAVITY # se for ar, cai normal
	# se for chao, morre
	set_mario_move(0,4,mario_morrendo_y)
	call PRINT_OBJ
	free_stack(s0)
	free_stack(ra)
	j MARIO_DEATH
	
	PRINT_FALL_MARIO_GRAVITY:
		set_mario_move(0,4,mario_parado)
		call PRINT_OBJ # printa mario posicao abaixo
		li a0,20
		li a7,32
		ecall # sleep 20ms queda
	
	FIM_MARIO_GRAVITY:
		free_stack(s0)
		free_stack(ra)
		ret

# faz a morte do mario (0 vidas por enquanto)	
MARIO_DEATH:
	# animacao e som de morte do mario
	# recebe mario morrendo y inicialmente
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ # faz mario virado pra um lado
	
	la a0,mario_morrendo_y
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRRORY # faz mario de cabeca pra baixo
	
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRROR # faz mario virado pro outro lado
	
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ # faz mario virado pra um lado
	
	la a0,mario_morrendo_y
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRRORY # faz mario de cabeca pra baixo
	
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRROR # faz mario virado pro outro lado
	
	addi a0,zero,0
	jal MARIO_DEATH_SOUND
	la a0,mario_morto
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ # printa mario no chao
	# fim da animacao
	addi a0,zero,1
	jal MARIO_DEATH_SOUND
	li a0,300
	li a7,32
	ecall
	addi a0,zero,2
	jal MARIO_DEATH_SOUND
	li a0,300
	li a7,32
	ecall
	addi a0,zero,3
	jal MARIO_DEATH_SOUND
	li a0,400
	li a7,32
	ecall
	addi a0,zero,4
	jal MARIO_DEATH_SOUND
	li a0,40
	li a7,32
	ecall

	# verifica se ainda tem vidas
	la t0,vidas
	lb t1,0(t0)	
	addi t1,t1,-1 # decrementa 1 vida
	sb t1,0(t0) # salva vida decrementada
	#bltz t1,GAME_OVER # se vidas < 0, game over
	bgez t1,FASE_RESET # se vidas >= 0, so reseta
	tail GAME_OVER
	
	# se ainda tiver vidas, decrementa e volta para o comeco
	FASE_RESET:
		la t0,fase
		lw t1,0(t0) # carrega qual a fase atual
		la t0,fase1
		beq t0,t1,MARIO_DEATH_FASE1 # se tiver na fase 1, reseta na fase1
		tail GAME_OVER
		
		MARIO_DEATH_FASE1:
			call PRINT_FASE1
			call INIT_MARIO
			call INIT_DK_DANCA
			tail MAINLOOP
	
	
	
# prepara animacao do mario morrendo
# a0 = sprite a ser mostrado (para facilitar)
MARIO_DEATH_ANIM:
	save_stack(ra)
	mv s0,a0
	li a0,300 # sleep de 300ms
	li a7,32
	ecall
	
	rmv_mario(mario_morrendo_y)
	la t0,pos_mario
	lh a0,0(t0) # carrega x
	lh a1,2(t0) # carrega y
	la t0,display
	lw a2,0(t0) # display atual
	mv a3,s0 # prepara a3
	
	FIM_MARIO_DEATH_ANIM:
		free_stack(ra)
		ret
		
# toca som do mario morrendo
# a0 = numero do som atual
MARIO_DEATH_SOUND:
	la t0,mario_death
	slli a0,a0,3 # multiplica por 8
	add t0,t0,a0 # pula pra posicao do audio desejado
	lw a0,0(t0) # carrega nota
	lw a1,4(t0) # carrega duracao
	li a2,80 # instrumento
	li a3,127 # volume
	li a7,31 # ecall som async
	ecall
	ret
	
# temporario
PRINT_ACT_POS:
	mario_mappos(t0)
	
	mv t1,a0
	lb a0,0(t0)
	li a7,34
	ecall
	mv a0,t1
	ret
