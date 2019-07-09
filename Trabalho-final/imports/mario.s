##################################################
# Responsavel por gerenciar movimentos, colisoes #
# interacoes com cenario e objetos do Mario	 #
##################################################
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
.include "../sprites/bin/mario_andando_p1_martelo_baixo.s"
.include "../sprites/bin/mario_andando_p1_martelo_cima.s"
.include "../sprites/bin/mario_andando_p2_martelo_baixo.s"
.include "../sprites/bin/mario_andando_p2_martelo_cima.s"
.include "../sprites/bin/mario_parado_martelo_baixo.s"
.include "../sprites/bin/mario_parado_martelo_cima.s"

# Variaveis
mario_state: .byte 0 # salva estado atual do mario
pulo_px: .byte 0,0 # salva pixels movidos no pulo
pos_mario: .half 0,0 # salva posicao atual do mario (x,y)

movement_counter: .word 0 # contador de passos dos movimentos
mario_hammer_timer: .word 0 # contador de tempo do martelo
mario_hammer_type: .byte 0 # tipo de animacao do martelo (1 = baixo, 0 = cima)
.text

# Printa o Mario na posicao inicial
# Sem argumentos
INIT_MARIO:
	save_stack(ra)
	la t1,fase 
	lb t0,0(t1) # carrega numero da fase atual
	li t1,1
	beq t0,t1,INIT_MARIO_F1 # se fase atual for fase 1, printa mario parado na fase 1
	li t1,2
	beq t0,t1,INIT_MARIO_F2 # se fase atual for fase 2, printa mario parado na fase 2
	li t1,3
	beq t0,t1,INIT_MARIO_F3 # se fase atual for fase 3, printa mario parado na fase 3
	li t1,4
	beq t0,t1,INIT_MARIO_F4 # se fase atual for fase 3, printa mario parado na fase 4
	j FIM_INIT_MARIO
	
	INIT_MARIO_F1:
		la t0,pos_mario
		sw zero,0(t0) # zera pos mario
		set_mario_move(START_MARIO_X_FASE1,START_MARIO_Y_FASE1,mario_parado)
		call PRINT_OBJ # printa mario na posicao inicial, reseta pos mario
		j FIM_INIT_MARIO
		
	INIT_MARIO_F2:
		la t0,pos_mario
		sw zero,0(t0) # zera pos mario
		set_mario_move(START_MARIO_X_FASE2,START_MARIO_Y_FASE2,mario_parado)
		call PRINT_OBJ # printa mario na posicao inicial, reseta pos mario
		j FIM_INIT_MARIO
		
	INIT_MARIO_F3:
		la t0,pos_mario
		sw zero,0(t0) # zera pos mario
		set_mario_move(START_MARIO_X_FASE3,START_MARIO_Y_FASE3,mario_parado)
		call PRINT_OBJ # printa mario na posicao inicial, reseta pos mario
		j FIM_INIT_MARIO
		
	INIT_MARIO_F4:
		la t0,pos_mario
		sw zero,0(t0) # zera pos mario
		set_mario_move(START_MARIO_X_FASE4,START_MARIO_Y_FASE4,mario_parado)
		call PRINT_OBJ # printa mario na posicao inicial, reseta pos mario
		
	FIM_INIT_MARIO:
		# reseta variaveis
		la t0,mario_state # seta mario_state como 0
		sb zero,0(t0) # seta 00000 no mario state (parado no chao virado pra direita)
		la t0,pulo_px
		sb zero,0(t0) # reseta pulopx
		sb zero,1(t0) 
		la t0,movement_counter
		sw zero,0(t0) # reseta mov counter
		
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
#	lw a2,4(a2) # display anterior (caso mudar displays esteja ligado)
	la a3,fase_current
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

# Pega a posicao do mario no map
MARIO_MAP_POS:
	la t0,pos_mario
	lh s1,0(t0) # x do mario
	lh s0,2(t0) # y do mario
	
	addi s1,s1,16 # +16 para saber posicao do pe direito do mario
	addi s0,s0,20 # +16 --
	srli s1,s1,2 # x / 4 para alinhar com mapeamento
	srli s0,s0,2 # y / 4 para alinhar com mapeamento
	
	la t1,fase
	lb t0,0(t1)
	li t1,1
	beq t0,t1,MMPOS_FASE1
	li t1,2
	beq t0,t1,MMPOS_FASE2
	li t1,3
	beq t0,t1,MMPOS_FASE3
	li t1,4
	beq t0,t1,MMPOS_FASE4
	j FIM_MMPOS
	
	MMPOS_FASE1:
	la a1,fase1_obj
	j MMPOS_CONTINUE
	MMPOS_FASE2:
	la a1,fase2_obj
	j MMPOS_CONTINUE
	MMPOS_FASE3:
	la a1,fase3_obj
	j MMPOS_CONTINUE
	MMPOS_FASE4:
	la a1,fase4_obj
	MMPOS_CONTINUE:
	li a0,80
	mul a0,s0,a0 # (y * 80)
	add a0,a0,s1 # (y * 80) + n
	
	FIM_MMPOS:
	ret

# Faz o movimento do mario para a direita
MOVE_MARIO_DIREITA:
	save_stack(a0)
	save_stack(ra)
	
	li a0,1
	call MARIO_COLLISIONS # verifica permissao do movimento
	beqz a0,FIM_MVMD_RET # se nao for permitido, so retorna

	la t0,movement_counter
	lw t1,0(t0) # contador de movimento
	
	# cont == 0, passo 1
	beqz t1,MVMD_P1 #
	# cont == 1, passo 2
	addi t2,zero,1
	beq t1,t2,MVMD_P2
	# cont == 2, passo 3
	addi t2,zero,2
	beq t1,t2,MVMD_P1
	j FIM_MVMD_RET
	
	MVMD_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # verifica se esta com martelo
		beqz t1,MVMD_P1_NORM
		# se estiver com martelo, faz animacao
		la t0,mario_hammer_type
		lb t1,0(t0) # carrega tipo do martelo
		beqz t1,MVMD_P1_HAMMER_T0
			sb zero,0(t0) # salva tipo 0 p/ prox
			set_mario_move(2,0,mario_andando_p1_martelo_baixo) # se == 1, faz tipo 1
			j CONT_MVMD_P1
		MVMD_P1_HAMMER_T0:
			li t1,1
			sb t1,0(t0) # salva tipo 1 p/ prox
			set_mario_move(2,0,mario_andando_p1_martelo_cima) # se == 0, faz tipo 0
			j CONT_MVMD_P1
		MVMD_P1_NORM:
			set_mario_move(2,0,mario_andando_p1) # se move 1px pra direita
		CONT_MVMD_P1:
		call PRINT_OBJ # printa mario passo 1 na tela
		
		li a0,1
		call MARIO_HAMMER_SPRITE
		
		la t0,movement_counter
		addi t1,zero,1
		sw t1,0(t0) # salva q fez passo 1
		
		li a0,0
		call MARIO_STEP_SOUND
		
		j FIM_MVMD_ANDANDO
	
	MVMD_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # verifica se esta com martelo
		beqz t1,MVMD_P2_NORM
		# se estiver com martelo, faz animacao
		la t0,mario_hammer_type
		lb t1,0(t0) # carrega tipo do martelo
		beqz t1,MVMD_P2_HAMMER_T0
			sb zero,0(t0) # salva tipo 0 p/ prox
			set_mario_move(2,0,mario_andando_p2_martelo_baixo) # se == 1, faz tipo 1
			j CONT_MVMD_P2
		MVMD_P2_HAMMER_T0: 
			li t1,1
			sb t1,0(t0) # salva tipo 1 p/ prox
			set_mario_move(2,0,mario_andando_p2_martelo_cima) # se == 0, faz tipo 0
			j CONT_MVMD_P2
		MVMD_P2_NORM: 
			set_mario_move(2,0,mario_andando_p2) # se move 1px pra direita
		CONT_MVMD_P2: call PRINT_OBJ # printa mario passo 2 na tela
	
		li a0,1
		call MARIO_HAMMER_SPRITE
		
		la t0,movement_counter
		addi t1,zero,2
		sw t1,0(t0) # salva q fez passo 2
		
		li a0,1
		call MARIO_STEP_SOUND
		
		j FIM_MVMD_RET
		
	#MVMD_P3: # faz passo 3
	#	rmv_mario(mario_andando_p2)
		
	#	set_mario_move(2,0,mario_andando_p1) # se move 1px pra direita
	#	call PRINT_OBJ # printa mario passo 3 na tela
		
	#	la t0,movement_counter
	#	addi t1,zero,1
	#	sw t1,0(t0) # salva q fez passo 1 (sem precisar dar write no bit andando)
		
	#	j FIM_MVMD_RET
		
	MVMD_P0: # faz mario parado novamente
		save_stack(a0)
		save_stack(ra)
		la t0,last_key
		lw t1,0(t0) # carrega ultima tecla
		li t2,100
		bne t1,t2,FIM_MVMD_RET # se nao foi D a ultima tecla, ignora
		# se foi, verifica se foi ha menos de 150ms
		lw t1,4(t0) # carrega tempo
		gettime()
		sub t1,a0,t1 # t1 = tempo atual - tempo da tecla
		addi t2,zero,300
		blt t1,t2,FIM_MVMD_RET # se a diferenca de tmepo for maior q 150ms, o mario para
		
		rmv_mario(mario_andando_p1)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # verifica se esta com martelo
		beqz t1,MVMD_P0_NORM
		# se estiver com martelo, faz animacao
		la t0,mario_hammer_type
		lb t1,0(t0) # carrega tipo do martelo
		beqz t1,MVMD_P0_HAMMER_T0
			sb zero,0(t0) # salva tipo 0 p/ prox
			set_mario_move(0,0,mario_parado_martelo_baixo) # se == 1, faz tipo 1
			j CONT_MVMD_P0
		MVMD_P0_HAMMER_T0: 
			li t1,1
			sb t1,0(t0) # salva tipo 1 p/ prox
			set_mario_move(0,0,mario_parado_martelo_cima) # se == 0, faz tipo 0
			j CONT_MVMD_P0
		MVMD_P0_NORM: set_mario_move(0,0,mario_parado) # printa o mario parado
		CONT_MVMD_P0: call PRINT_OBJ # printa mario passo final na tela
		
		li a0,1
		call MARIO_HAMMER_SPRITE
		
		la t0,movement_counter
		add t1,zero,zero
		sw t1,0(t0) # salva q fez passo 0
		
		j FIM_MVMD_PAROU
	
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
	beq a0,zero,FIM_MVME_RET # se nao for permitido, retorna

	la t0,movement_counter
	lw t1,0(t0) # contador de movimento
	
	# cont == 0, passo 1
	beqz t1,MVME_P1 #
	# cont == 1, passo 2
	addi t2,zero,1
	beq t1,t2,MVME_P2
	# cont == 2, passo 1
	addi t2,zero,2
	beq t1,t2,MVME_P1
	j FIM_MVME_RET
	
	MVME_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # verifica se esta com martelo
		beqz t1,MVME_P1_NORM
		# se estiver com martelo, faz animacao
		la t0,mario_hammer_type
		lb t1,0(t0) # carrega tipo do martelo
		beqz t1,MVME_P1_HAMMER_T0
			sb zero,0(t0) # salva tipo 0 p/ prox
			set_mario_move(-2,0,mario_andando_p1_martelo_baixo) # se == 1, faz tipo 1
			j CONT_MVME_P1
		MVME_P1_HAMMER_T0:
			li t1,1
			sb t1,0(t0) # salva tipo 1 p/ prox
			set_mario_move(-2,0,mario_andando_p1_martelo_cima) # se == 0, faz tipo 0
			j CONT_MVME_P1
		MVME_P1_NORM:
			set_mario_move(-2,0,mario_andando_p1) # se move 1px pra esquerda
		CONT_MVME_P1: call PRINT_OBJ_MIRROR # printa mario passo 1 na tela
		
		li a0,2
		call MARIO_HAMMER_SPRITE
		
		la t0,movement_counter
		addi t1,zero,1
		sw t1,0(t0) # salva q fez passo 1
		
		li a0,0
		call MARIO_STEP_SOUND
		
		j FIM_MVME_ANDANDO
	
	MVME_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # verifica se esta com martelo
		beqz t1,MVME_P2_NORM
		# se estiver com martelo, faz animacao
		la t0,mario_hammer_type
		lb t1,0(t0) # carrega tipo do martelo
		beqz t1,MVME_P2_HAMMER_T0
			sb zero,0(t0) # salva tipo 0 p/ prox
			set_mario_move(-2,0,mario_andando_p2_martelo_baixo) # se == 1, faz tipo 1
			j CONT_MVME_P2
		MVME_P2_HAMMER_T0:
			li t1,1
			sb t1,0(t0) # salva tipo 1 p/ prox
			set_mario_move(-2,0,mario_andando_p2_martelo_cima) # se == 0, faz tipo 0
			j CONT_MVME_P2
		MVME_P2_NORM:
			set_mario_move(-2,0,mario_andando_p2) # se move 1px pra esquerda
		CONT_MVME_P2: call PRINT_OBJ_MIRROR # printa mario passo 2 na tela
		
		li a0,2
		call MARIO_HAMMER_SPRITE
		
		la t0,movement_counter
		addi t1,zero,2
		sw t1,0(t0) # salva q fez passo 2
		
		li a0,1
		call MARIO_STEP_SOUND
		
		j FIM_MVME_RET
	
	#MVME_P3: # faz passo 3
	#	rmv_mario(mario_andando_p2)
		
	#	set_mario_move(-2,0,mario_andando_p1) # se move 1px pra esquerda
	#	call PRINT_OBJ_MIRROR # printa mario passo 3 na tela
		
	#	la t0,movement_counter
	#	addi t1,zero,1
	#	sw t1,0(t0) # salva q fez passo 1 (sem precisar do write no bit de andando)
		
	#	j FIM_MVME_ANDANDO
	
	MVME_P0:
		save_stack(a0)
		save_stack(ra) # faz mario parado novamente
		la t0,last_key
		lw t1,0(t0) # carrega ultima tecla
		li t2,97
		bne t1,t2,FIM_MVME_RET # se nao foi A a ultima tecla, ignora
		# se foi, verifica se foi ha menos de 150ms
		lw t1,4(t0) # carrega tempo
		gettime()
		sub t1,a0,t1 # t1 = tempo atual - tempo da tecla
		addi t2,zero,300
		blt t1,t2,FIM_MVME_RET # se a diferenca de tempo for maior q 150ms, o mario para
		
		rmv_mario(mario_andando_p1)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10 # verifica se esta com martelo
		beqz t1,MVME_P0_NORM
		# se estiver com martelo, faz animacao
		la t0,mario_hammer_type
		lb t1,0(t0) # carrega tipo do martelo
		beqz t1,MVME_P0_HAMMER_T0
			sb zero,0(t0) # salva tipo 0 p/ prox
			set_mario_move(0,0,mario_parado_martelo_baixo) # se == 1, faz tipo 1
			j CONT_MVME_P0
		MVME_P0_HAMMER_T0:
			li t1,1
			sb t1,0(t0) # salva tipo 1 p/ prox
			set_mario_move(0,0,mario_parado_martelo_cima) # se == 0, faz tipo 0
			j CONT_MVME_P0
		MVME_P0_NORM: set_mario_move(0,0,mario_parado) # printa o mario parado
		CONT_MVME_P0: call PRINT_OBJ_MIRROR # printa mario passo final na tela
		
		li a0,2
		call MARIO_HAMMER_SPRITE
		
		la t0,movement_counter
		add t1,zero,zero
		sw t1,0(t0) # salva q fez passo 0
		
		j FIM_MVME_PAROU
	
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
	ret
		
MV_1PXDW:
	la t0,pos_mario
	lh t1,2(t0)
	addi t1,t1,1
	sh t1,2(t0) # faz mario descer 1px
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
		set_mario_move(0,-2,mario_escada) # seta impressao do mario
		
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
		
		sleep(30)
		
		rmv_mario(mario_escada_p1)
		set_mario_move(0,-2,mario_escada_p2)
		call PRINT_OBJ
		
		sleep(30)
		
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
		set_mario_move(0,2,mario_escada) # seta impressao do mario
		
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
		
		sleep(30)
		
		rmv_mario(mario_escada_p1)
		set_mario_move(0,2,mario_escada_p2)
		call PRINT_OBJ
		
		sleep(30)
		
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
		sb zero,0(t0)
		sb zero,1(t0)
		
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
	andi t1,t1,0x0A # verifica se pode pular
	bne t1,zero,FIM_PULO_UP # se nao puder pular, sai
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,13
	beq t2,t3,MARIO_PULO_UP_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	beq t1,t3,MARIO_PULO_UP_RESET # se ambos tiverem em 12, termina pulo
	bgt t1,zero,MARIO_PULO_UP_DESCE # se descida tiver > 0 e < 12, faz movimento de descer
	bgt t2,zero,MARIO_PULO_UP_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_UP_INIT_SUBIDA:
		la t0,mario_state
		lb t1,0(t0)
		andi t2,t1,0x10 # verificar se o mario esta com martelo
		bnez t2,FIM_PULO_UP # se estiver de martelo, nao inicia subida
		# do contrario, continua
		rmv_mario(mario_pulando) # remove mario na posicao atual
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
		rmv_mario(mario_pulando) # remove mario na posicao atual
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1 # sobe 1px no pulopx
		sb t1,1(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi s0,t1,0x04 # verificador de qual o lado do mario
		
		set_mario_move(0,-2,mario_pulando) # se move 1px pra cima
		
		beqz s0,PULO_UP_PDIR
		j PULO_UP_PESQ
		
	MARIO_PULO_UP_INIT_DESCIDA:
		rmv_mario(mario_pulando) # remove mario na posicao atual
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
		rmv_mario(mario_pulando) # remove mario na posicao atual
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi s0,t1,0x04 # pega para qual lado o mario esta virado
		
		set_mario_move(0,2,mario_pulando) # se move 1px pra baixo
		
		beqz s0,PULO_UP_PDIR
		j PULO_UP_PESQ
	
	MARIO_PULO_UP_RESET:	
		rmv_mario(mario_pulando) # remove mario na posicao atual
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb s0,0(t0)
		andi s0,s0,0x14
		sb s0,0(t0) # salva estado do mario no chao, virado pro lado onde ja estava com ou sem martelo
		
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
	la t0,mario_state 
	lb t1,0(t0)
	andi t1,t1,0x28 # verifica se pode pular
	bne t1,zero,FIM_PULO_DIR # se nao puder pular, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,14
	beq t2,t3,MARIO_PULO_DIR_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	bge t1,t3,MARIO_PULO_DIR_DESCE_RETO # se ambos >= 12, verifica se precisa parar, ou morrer
	bgt t1,zero,MARIO_PULO_DIR_DESCE_DIAG # se descida tiver > 0 e < 12, faz movimento de descer
	bgt t2,zero,MARIO_PULO_DIR_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_DIR_INIT_SUBIDA:
		# verifica se em algum ponto da trajetoria tem uma parede
		# se tiver, nao realiza pulo
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x11 # verifica se esta com martelo ou se ja estava pulando
		bnez t1,FIM_PULO_DIR # se estiver com martelo, ou pulando, nao inicia subida
		
		save_stack(s0)
		mario_mappos(s0)
		mv t0,s0
		li t1,7
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
			free_stack(s0)
			j PULO_DIR_ANIM
		MPDIS_CHECKWALL_PASS: # se nao tiver nenhuma parede, faz pulo
	
		la t0,mario_state
		li t1,0x03
		sb t1,0(t0) # grava mario state de pulando pra direita
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		set_mario_move(4,-8,mario_pulando) # se move 8px pra cima, 4px pra direita p/ iniciar pulo
		free_stack(s0)
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
		
		la t0,pos_mario
		lh s0,0(t0) # x do mario
		lh s1,2(t0) # y do mario
		addi s1,s1,16
		# y_mario + 18 < y_barril && y_mario + 18 > y_barril - 15(altura do pulo do mario)
		la s2,var_barris
		li s3,6
		MBC_VERIF_Y_PDIR: # verifica se o mario esta na altura passiva de ganhar pontos
			beqz s3,CONT_MARIO_PULO_DIR_INIT_DESCIDA # verificados todos os barris, encerra
			lh a0,0(s2) # x do barril
			lh a1,2(s2) # y do barril
			slt t0,s1,a1 # y_mario + 16 < y_barril ? 1 : 0 tem q dar 1
			addi a1,a1,-15 # y_barril - 15
			slt t1,s1,t1 # y_mario + 16 < y_barril - 15 ? 1 : 0 tem q dar 0
			add t0,t0,t1
			li t1,1
			beq t0,t1,MBC_VERIF_X_PDIR # se estiver acima do barril, verifica eixo x 
			CONTINUE_MBC_VERIF_Y_PDIR:
			addi s2,s2,4 # passa p/ proximo barril
			addi s3,s3,-1 # decrementa contador
			j MBC_VERIF_Y_PDIR
			
		MBC_VERIF_X_PDIR:
			slt t0,a0,s0 # x_barril < x_mario ? 1 : 0  tem q dar 1
			addi t1,a0,10
			slt t1,t1,s0 # x_barril + 10 < x_mario tem q dar 0
			add t0,t0,t1 # soma as duas condicoes
			li t1,1
			beq t0,t1,MBC_VERIF_X_PDIR_GPOINTS # se estiver na posicao, da pontos
			j CONTINUE_MBC_VERIF_Y_PDIR
			MBC_VERIF_X_PDIR_GPOINTS:
				li a0,100
				la t0,pos_mario
				lh a1,0(t0)
				lh a2,2(t0)
				addi a2,a2,-10
				call GIVE_POINTS
			j CONTINUE_MBC_VERIF_Y_PDIR # do contrario, verifica os outros barris
		
		CONT_MARIO_PULO_DIR_INIT_DESCIDA:
		set_mario_move(0,0,mario_pulando) # nao se move
		
		j PULO_DIR_ANIM
	
	MARIO_PULO_DIR_DESCE_DIAG:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		la t0,pos_mario
		lh s0,0(t0) # x do mario
		lh s1,2(t0) # y do mario
		addi s1,s1,18
		li s2,18
		MPDIR_VERIF_GROUND:
			beqz s2,CONT_MPDIR_VERIF_GROUND
			addi a0,s0,1 # x crescente p/ procurar px de chao
			addi a1,s1,0 # y do pe
			la a2,display
			lw a2,0(a2)
			call GET_POSITION
			lb t0,0(a0)
			li t1,128
			beq t0,t1,MARIO_PULO_DIR_RESET # para ao achar chao azul
			li t1,0x46
			beq t0,t1,MARIO_PULO_DIR_RESET # para ao achar chao rosa
			addi s0,s0,1 # incrementa x
			addi s2,s2,-1 # decrementa contador
			j MPDIR_VERIF_GROUND
		
		CONT_MPDIR_VERIF_GROUND: # se nao tiver chao, move o mario
			set_mario_move(2,2,mario_pulando) # se move 1px pra baixo, 1px pra direita
		
		j PULO_DIR_ANIM
		
	MARIO_PULO_DIR_DESCE_RETO:
		la t0,fase
		lb t1,0(t0)
		li t0,3
		beq t0,t1,MARIO_PULO_DIR_RESET_F3 # se for fase 3, ele sempre cai na mesma altura
		li t0,4
		beq t0,t1,MARIO_PULO_DIR_RESET_F3 # o mesmo pra fase 4
		
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		li t0,22
		bge t1,t0,MARIO_PULO_DIR_RESET_DEATH # se cair mais q 1,5 x altura do mario, morre
		
		la t0,pos_mario
		lh s0,0(t0) # x do mario
		lh s1,2(t0) # y do mario
		addi s1,s1,18
		li s2,18
		MPDIR_VERIF_GROUND_R:
			beqz s2,CONT_MPDIR_VERIF_GROUND_R
			addi a0,s0,1 # x crescente p/ procurar px de chao
			addi a1,s1,0 # y do pe
			la a2,display
			lw a2,0(a2)
			call GET_POSITION
			lb t0,0(a0)
			li t1,0x46
			beq t0,t1,MARIO_PULO_DIR_RESET # para ao achar chao rosa
			addi s0,s0,1 # incrementa x
			addi s2,s2,-1 # decrementa contador
			j MPDIR_VERIF_GROUND_R
		
		CONT_MPDIR_VERIF_GROUND_R: # se nao tiver chao, move o mario
			set_mario_move(1,2,mario_pulando) # se move 1px pra baixo, 1px pra direita
		
		j PULO_DIR_ANIM
	
	MARIO_PULO_DIR_RESET_DEATH:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		sb t1,0(t0) # salva estado do mario no chao, virado pra direita, com ou sem martelo
	
		set_mario_move(0,0,mario_pulando)
		j PULO_DIR_ANIM
		
	MARIO_PULO_DIR_RESET_F3:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		sb t1,0(t0) # salva estado do mario no chao, virado pra direita, com ou sem martelo
	
		set_mario_move(4,2,mario_parado) # se move 2px pra baixo, 4px pra direita p/ finalizar pulo
		
		j PULO_DIR_ANIM
		
	MARIO_PULO_DIR_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		sb t1,0(t0) # salva estado do mario no chao, virado pra direita, com ou sem martelo
	
		set_mario_move(0,0,mario_parado) # muda pro sprite do mario parado
		
	PULO_DIR_ANIM: # pula pra direita em movimento
		call PRINT_OBJ
	
	FIM_PULO_DIR:
		tail MAINLOOP_RET

# realiza mario pulando pra esquerda em movimento
MARIO_PULO_ESQ:
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x28 # verifica se pode pular
	bne t1,zero,FIM_PULO_ESQ # se nao puder, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
	la t0,pulo_px
	lb t1,0(t0) # carrega estado de descida do pulo do mario
	lb t2,1(t0) # carrega estado de subida do pulo do mario
	li t3,14
	beq t2,t3,MARIO_PULO_ESQ_INIT_DESCIDA # se ja tiver chegado no ponto maximo, inicia descida
	#beq t1,t3,MARIO_PULO_ESQ_RESET # se ambos tiverem em 12, termina pulo
	bge t1,t3,MARIO_PULO_ESQ_DESCE_RETO # se ambos >= 12, verifica se precisa parar (ou morrer)
	bgt t1,zero,MARIO_PULO_ESQ_DESCE_DIAG # se descida tiver > 0 e < 12, faz movimento de descer diagonal ate o chao
	bgt t2,zero,MARIO_PULO_ESQ_SOBE # se subida tiver > 0 e < 12, sobe 1px
	
	MARIO_PULO_ESQ_INIT_SUBIDA:
		# verifica se esta com martelo
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x11 # verifica se esta com martelo, ou pulando
		bnez t1,FIM_PULO_ESQ # se estiver com martelo, ou pulando, nao inicia subida
		
		# verifica se em algum ponto da trajetoria tem uma parede
		# se tiver, nao realiza pulo	
		save_stack(s0)
		mario_mappos(s0) # pega posicao atual do mario
		mv t0,s0
		li t1,7
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
			free_stack(s0)
			j PULO_ESQ_ANIM
		MPEIS_CHECKWALL_PASS: # se nao tiver nenhuma parede, faz pulo
		
		la t0,mario_state
		li t1,0x07
		sb t1,0(t0) # grava mario state de pulando pra esquerda
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		set_mario_move(-4,-8,mario_pulando) # se move 8px pra cima, 4px pra esquerda p/ iniciar pulo
		
		free_stack(s0)
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
		
		la t0,pos_mario
		lh s0,0(t0) # x do mario
		lh s1,2(t0) # y do mario
		addi s1,s1,16
		# y_mario + 18 < y_barril && y_mario + 18 > y_barril - 15(altura do pulo do mario)
		la s2,var_barris
		li s3,6
		MBC_VERIF_Y_PESQ: # verifica se o mario esta na altura passiva de ganhar pontos
			beqz s3,CONT_MARIO_PULO_ESQ_INIT_DESCIDA # verificados todos os barris, encerra
			lh a0,0(s2) # x do barril
			lh a1,2(s2) # y do barril
			slt t0,s1,a1 # y_mario + 16 < y_barril ? 1 : 0 tem q dar 1
			addi a1,a1,-15 # y_barril - 15
			slt t1,s1,t1 # y_mario + 16 < y_barril - 15 ? 1 : 0 tem q dar 0
			add t0,t0,t1
			li t1,1
			beq t0,t1,MBC_VERIF_X_PESQ # se estiver acima do barril, verifica eixo x 
			CONTINUE_MBC_VERIF_Y_PESQ:
			addi s2,s2,4 # passa p/ proximo barril
			addi s3,s3,-1 # decrementa contador
			j MBC_VERIF_Y_PESQ
			
		MBC_VERIF_X_PESQ:
			slt t0,a0,s0 # x_barril < x_mario ? 1 : 0  tem q dar 1
			addi t1,a0,-10
			slt t1,t1,s0 # x_barril + 10 < x_mario tem q dar 0
			add t0,t0,t1 # soma as duas condicoes
			li t1,1
			beq t0,t1,MBC_VERIF_X_PESQ_GPOINTS # se estiver na posicao, da pontos
			j CONTINUE_MBC_VERIF_Y_PESQ
			MBC_VERIF_X_PESQ_GPOINTS:
				li a0,100
				la t0,pos_mario
				lh a1,0(t0)
				lh a2,2(t0)
				addi a2,a2,-10
				call GIVE_POINTS
			j CONTINUE_MBC_VERIF_Y_PESQ # do contrario, verifica os outros barris
		
		CONT_MARIO_PULO_ESQ_INIT_DESCIDA:
		set_mario_move(0,0,mario_pulando) # se move apenas 1px pra esquerda, sem subir nem descer
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_DESCE_DIAG:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		la t0,pos_mario
		lh s0,0(t0) # x do mario
		lh s1,2(t0) # y do mario
		addi s1,s1,18
		li s2,18
		MPESQ_VERIF_GROUND:
			beqz s2,CONT_MPESQ_VERIF_GROUND
			addi a0,s0,1 # x crescente p/ procurar px de chao
			addi a1,s1,0 # y do pe
			la a2,display
			lw a2,0(a2)
			call GET_POSITION
			lb t0,0(a0)
			li t1,0x46
			beq t0,t1,MARIO_PULO_ESQ_RESET # para ao achar chao rosa
			addi s0,s0,1 # incrementa x
			addi s2,s2,-1 # decrementa contador
			j MPESQ_VERIF_GROUND
		
		CONT_MPESQ_VERIF_GROUND: # se nao tiver chao, move o mario
			set_mario_move(-2,2,mario_pulando) # se move 1px pra baixo, 1px pra esquerda
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_DESCE_RETO:
		la t0,fase
		lb t1,0(t0)
		li t0,3
		beq t0,t1,MARIO_PULO_ESQ_RESET_F3 # se for fase 3, termina o pulo (pois eh tudo no msm nivel)
		li t0,4
		beq t0,t1,MARIO_PULO_ESQ_RESET_F3 # o mesmo pra fase 4
		
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		li t0,22
		bge t1,t0,MARIO_PULO_ESQ_RESET_DEATH # se cair mais q 1,5 x altura do mario, morre
		
		la t0,pos_mario
		lh s0,0(t0) # x do mario
		lh s1,2(t0) # y do mario
		addi s1,s1,18
		li s2,18
		MPESQ_VERIF_GROUND_R:
			beqz s2,CONT_MPESQ_VERIF_GROUND_R
			addi a0,s0,1 # x crescente p/ procurar px de chao
			addi a1,s1,0 # y do pe
			la a2,display
			lw a2,0(a2)
			call GET_POSITION
			lb t0,0(a0)
			li t1,0x46
			beq t0,t1,MARIO_PULO_ESQ_RESET # para ao achar chao rosa
			addi s0,s0,1 # incrementa x
			addi s2,s2,-1 # decrementa contador
			j MPESQ_VERIF_GROUND_R
		
		CONT_MPESQ_VERIF_GROUND_R: # se nao tiver chao, move o mario
			set_mario_move(-1,2,mario_pulando) # se move 1px pra baixo, 1px pra esquerda
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_RESET_DEATH:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		ori t1,t1,0x04
		sb t1,0(t0) # salva estado do mario no chao, virado pra esquerda, com ou sem martelo
	
		set_mario_move(0,0,mario_pulando)
			
		j PULO_ESQ_ANIM
		
	MARIO_PULO_ESQ_RESET_F3:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		ori t1,t1,0x04
		sb t1,0(t0) # salva estado do mario no chao, virado pra esquerda, com ou sem martelo
	
		set_mario_move(-4,2,mario_parado) # se move 2px pra baixo, 4px pra esquerda p/ finalizar pulo
		j PULO_ESQ_ANIM
		
	MARIO_PULO_ESQ_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		ori t1,t1,0x04
		sb t1,0(t0) # salva estado do mario no chao, virado pra esquerda, com ou sem martelo
	
		set_mario_move(0,0,mario_parado) # muda sprite pro mario parado
		
	PULO_ESQ_ANIM: # pula pra esquerda em movimento
		call PRINT_OBJ_MIRROR
	
	FIM_PULO_ESQ:
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
	save_stack(ra)
	save_stack(a0)
	# considereando a mario position e state atual, verificar se o movimento desejado eh permitido
	mario_mappos(s0)
	free_stack(a0)
	
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
		andi t1,t1,0x28 # verifica bit de escada e caindo no status
		lb t0,0(s0)
		andi t0,t0,0x08 # verifica bit de parede no mapa
		or t0,t1,t0 # junta os dois bytes
		bne t0,zero,MARIO_CL_DENY # se qlqr um deles der 1 no bit desejado, nao permite
		lb t0,0(s0) # carrega byte do mapa
		# verifica se tem degrau subindo
		la t0,pos_mario
		lh a0,0(t0) # carrega x
		addi a0,a0,20
		lh a1,2(t0) # carrega y
		addi a1,a1,16
		la a2,fase_current # carrega endereco da fase atual
		#la a2,display
		#lw a2,0(a2) # carrega endereco do display (por causa dos degraus)
		call GET_POSITION
		lb t0,0(a0) # t0 = pixel ao lado
		li t2,0x46
		bne t0,t2,VERIF_MV_DIR_DOWNDEG # se px ao lado nao for chao, verifica se tem descida
		MVDIR_PXUP: call MV_1PXUP # se px ao lado for chao, sobe 1px
		j MARIO_CL_ALLOW
		# verifica se tem degrau descendo
		VERIF_MV_DIR_DOWNDEG: 
		la t0,pos_mario
		lh a0,0(t0) # carrega x
		addi a0,a0,10
		lh a1,2(t0) # carrega y
		addi a1,a1,17
		la a2,fase_current # carrega endereco da fase atual
		#la a2,display
		#lw a2,0(a2) # carrega endereco do display (por causa dos degraus)
		call GET_POSITION
		lb t0,0(a0)
		#li t2,0xffffffc7
		#beq t0,t2,MVDIR_PXDW
		#beqz t0,MVDIR_PXDW
		#j MARIO_CL_ALLOW
		li t2,0x00
		bne t0,t2,MARIO_CL_ALLOW # se px abaixo nao for preto, simplesmente permite mov
		MVDIR_PXDW: call MV_1PXDW # se px abaixo for preto (acabou chao), desce 1 degrau
		j MARIO_CL_ALLOW # se der zero, permite
		
	VERIF_MV_ESQ:
		addi s0,s0,-1 # posicao atras
		la t0,mario_state
		lb t1,0(t0) # carrega byte de status
		andi t1,t1,0x08 # verifica bit de escada no status
		lb t2,0(t0)
		andi t2,t2,0x20 # verifica bit de caindo
		lb t0,0(s0)
		andi t0,t0,0x08 # verifica bit de parede no mapa
		or t0,t1,t0 # junta os dois bytes
		or t0,t0,t2 # junta o byte de caindo
		bne t0,zero,MARIO_CL_DENY # se qlqr um deles der 1 no bit, nao permite
		# verifica se tem degrau subindo
		la t0,pos_mario
		lh a0,0(t0) # carrega x
		addi a0,a0,0
		lh a1,2(t0) # carrega y
		addi a1,a1,16
		la a2,fase_current # carrega endereco da fase atual
		#la a2,display
		#lw a2,0(a2) # carrega endereco do display (por causa dos degraus)
		call GET_POSITION
		lb t0,0(a0)
		li t2,0x46
		bne t0,t2,VERIF_MV_ESQ_DOWNDEG # se px ao lado nao for chao, verifica se tem descida
		MVESQ_PXUP: call MV_1PXUP # se px ao lado for chao, sobe 1px
		j MARIO_CL_ALLOW
		# verifica se tem degrau descendo
		VERIF_MV_ESQ_DOWNDEG:
		la t0,pos_mario
		lh a0,0(t0) # carrega x
		addi a0,a0,12
		lh a1,2(t0) # carrega y
		addi a1,a1,17
		la a2,fase_current # carrega endereco da fase atual
		#la a2,display
		#lw a2,0(a2) # carrega endereco do display (por causa dos degraus)
		call GET_POSITION
		lb t0,0(a0)
		li t2,0x00
		bne t0,t2,MARIO_CL_ALLOW # se px abaixo nao for preto, simplesmente permite mov
		call MV_1PXDW # se px abaixo for preto (acabou chao), desce 1 degra
		j MARIO_CL_ALLOW # se der zero, passa
		
	VERIF_MV_CIMA:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		bnez t1,MARIO_CL_DENY # se estiver com martelo, nao permite subir escada
		addi s0,s0,-80 # linha acima
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
		andi t2,t1,0x10
		bnez t2,MARIO_CL_DENY # se estiver com martelo, nao permite descer escada
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
		free_stack(ra)
		free_stack(s0)
		ret
	
##################################################
# Verifica se ha degrau na pos atual. Retorna:
# a0 = degrau tipo A, degrau tipo D, 0 (sem degrau)
##################################################
MARIO_VERIF_DEGRAU:
	save_stack(ra)
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
		free_stack(ra)
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
	li t2,0x10
	beq t1,t2,MARIO_GRAVITY_ELEVATOR # se estiver no elevador, sobe junto
	li t2,0x02
	bne t1,t2,FIM_MARIO_GRAVITY # se for qualquer coisa exceto gravity, sai
	# se for 0010 eh ponto de queda e tem q cair
	# seta bit de caindo = 1
	la t0,mario_state
	lb t1,0(t0)
	ori t1,t1,0x20
	sb t1,0(t0) # salva status de caindo
	
	rmv_mario(mario_parado)
	
	addi s0,s0,80 # verificar linha abaixo
	lb t1,0(s0)
	li t2,0x02
	beq t1,t2,PRINT_FALL_MARIO_GRAVITY # se for gravity, cai normal
	# se for chao, morre
	set_mario_move(0,6,mario_morrendo_y)
	call PRINT_OBJ
	free_stack(s0)
	free_stack(ra)
	j MARIO_DEATH
	
	PRINT_FALL_MARIO_GRAVITY:
		set_mario_move(0,4,mario_andando_p2)
		j MARIO_GRAVITY_PRINT
		
	MARIO_GRAVITY_ELEVATOR:
		la t0,pos_mario
		lh s0,0(t0)
		lh a1,2(t0)
		addi a1,a1,18
		li t2,16
		addi s0,s0,1
		LOOP_SEARCH_GROUND_MGE:
			beqz t2,MARIO_GRAVITY_ELEVATOR_FALL
			mv a0,s0
			la a2,display
			lw a2,0(a2)
			call GET_POSITION # pega posicao de baixo do pe do mario
			lb t0,0(a0) # carrega byte do mapa nessa posicao
			li t1,0x46
			beq t0,t1,MARIO_GRAVITY_ELEVATOR_RISE
			#beqz t0,MARIO_GRAVITY_ELEVATOR_FALL
			addi t2,t2,-1
			addi s0,s0,1
			j LOOP_SEARCH_GROUND_MGE
		
		MARIO_GRAVITY_ELEVATOR_RISE:
			rmv_mario(mario_parado)
			set_mario_move(0,-1,mario_parado)
			j MARIO_GRAVITY_PRINT
		
		MARIO_GRAVITY_ELEVATOR_FALL:
			rmv_mario(mario_parado)
			set_mario_move(0,2,mario_parado)
			j MARIO_GRAVITY_PRINT
			
	MARIO_GRAVITY_PRINT:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x04 # verifica direcao
		beqz t1,MARIO_GRAVITY_PRINT_RIGHT
		call PRINT_OBJ_MIRROR
		j FIM_MARIO_GRAVITY
		MARIO_GRAVITY_PRINT_RIGHT:
		call PRINT_OBJ
		
	FIM_MARIO_GRAVITY:
		free_stack(s0)
		free_stack(ra)
		ret

# Da o martelo para o mario
MARIO_SET_HAMMER:
	la t0,mario_state
	lb t1,0(t0)
	ori t1,t1,0x10 # adiciona bit do martelo
	sb t1,0(t0)
	gettime()
	la t0,mario_hammer_timer
	sw a0,0(t0) # salva tempo de aquisicao do martelo
	FIM_MARIO_SET_HAMMER:
		ret
		
# Verifica se o martelo deve ser removido ou nao
MARIO_CHECK_HAMMER:
	save_stack(ra)
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x10 # bit de martelo
	beqz t1,FIM_MARIO_CHECK_HAMMER # se nao esta com martelo, nao faz nada disso
	la t0,mario_hammer_timer
	lw t1,0(t0) # carrega tempo de aquisicao do martelo
	gettime()
	sub t1,a0,t1 # tempo atual - tempo de aquisicao
	li t2,HAMMER_TIME
	blt t1,t2,MARIO_CHECK_HAMMER_TOGGLE # se nao atingido o tempo, verifica se esta parado p/ mover o martelo
	# se atingido o tempo, reseta mario state e tempo
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x0f # 01111, mantendo todos os bits exceto o martelo
	sb t1,0(t0)
	la t0,mario_hammer_timer
	sw zero,0(t0) # reseta timer
	la t0,mario_hammer_type
	sb zero,0(t0) # reseta tipo
	
	# muda sprite do mario de martelo p/ parado normal, se estiver parado
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x02
	bnez t1,CONT_MCHT_PRINT_NORMAL0 # se estiver andando, nao muda o sprite, apenas remove martelo
	# se estiver parado, muda o sprite p/ parado
	rmv_mario(mario_parado)
	set_mario_move(0,0,mario_parado)
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x04 # pega direcao
	beqz t1,MCHT_PRINT_NORMAL0
	call PRINT_OBJ_MIRROR
	j CONT_MCHT_PRINT_NORMAL0
	MCHT_PRINT_NORMAL0: call PRINT_OBJ
	CONT_MCHT_PRINT_NORMAL0:
	li a0,0
	call MARIO_HAMMER_SPRITE
	j FIM_MARIO_CHECK_HAMMER
	
	MARIO_CHECK_HAMMER_TOGGLE:
		la t0,mario_state
		lb t1,0(t0)
		andi t2,t1,0x02 # verifica se esta andando ou parado
		bnez t2,FIM_MARIO_CHECK_HAMMER # se estiver andando, nao faz nada
		andi t2,t1,0x01 # verifica se esta pulando
		bnez t2,FIM_MARIO_CHECK_HAMMER # se estiver pulando, nao faz nada
		# se estiver parado, muda o sprite do mario de acordo com o mario hammer type
		la t0,mario_hammer_type
		lb t1,0(t0)
		beqz t1,MCHT_TYPE0 # se for tipo 0, muda pro tipo 1
			sb zero,0(t0)
			rmv_mario(mario_parado)
			set_mario_move(0,0,mario_parado_martelo_baixo)
			la t0,mario_state
			lb t1,0(t0)
			andi t1,t1,0x04 # verifica bit de direcao
			beqz t1,MCHT_PRINT_NORMAL
			j MCHT_PRINT_MIRROR
		MCHT_TYPE0:
		 	li t1,1
		 	sb t1,0(t0) # salva prox tipo como 1
		 	rmv_mario(mario_parado)
		 	set_mario_move(0,0,mario_parado_martelo_cima)
		 	la t0,mario_state
			lb t1,0(t0)
			andi t1,t1,0x04 # verifica bit de direcao
			beqz t1,MCHT_PRINT_NORMAL
			j MCHT_PRINT_MIRROR
		 MCHT_PRINT_NORMAL:
		 	call PRINT_OBJ
		 	li a0,1
			call MARIO_HAMMER_SPRITE
			j FIM_MARIO_CHECK_HAMMER
		 MCHT_PRINT_MIRROR:
		 	call PRINT_OBJ_MIRROR
		 	li a0,2
			call MARIO_HAMMER_SPRITE
	FIM_MARIO_CHECK_HAMMER:
		free_stack(ra)
		ret
		
# Gerencia o sprite do martelo do mario
# a0 = qual direcao utilizar (0 = remover, 1 = direita, 2 = esquerda)
# tipo (cima ou baixo) pegado da variavel
MARIO_HAMMER_SPRITE:
	save_stack(ra)
	beqz a0,RMV_MARIO_HAMMER_SPRITE
	
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x10
	beqz t1,FIM_MARIO_HAMMER_SPRITE # se nao tiver martelo, nao faz nada
	
	la t0,mario_hammer_type
	lb t1,0(t0) # carrega o tipo do martelo (cima ou baixo) p/ as duas funcoes
	li t0,1
	beq a0,t0,MARIO_HAMMER_SPRITE_DIR
	li t0,2
	beq a0,t0,MARIO_HAMMER_SPRITE_ESQ
	j FIM_MARIO_HAMMER_SPRITE
	
	RMV_MARIO_HAMMER_SPRITE:
		# limpa direita
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,17 # x + 16 p/ posicao correta do martelo
		addi a1,t2,5 # y + 5
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_x
		call CLEAR_OBJPOS
		# limpa esquerda
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,-13 # x - 13 p/ posicao correta do martelo
		addi a1,t2,5 # y + 5
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_x
		call CLEAR_OBJPOS
		# limpa em cima
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,4 # x + 4 p/ posicao correta do martelo
		addi a1,t2,-15 # y -14
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_y
		call CLEAR_OBJPOS
		j FIM_MARIO_HAMMER_SPRITE
	MARIO_HAMMER_SPRITE_DIR: # faz o martelo caso o mario esteja virado p/ direita
		beqz t1,MARIO_HAMMER_SPRITE_DIR_BAIXO # se for 0, faz martelo p/ direita baixo
		# do contrario, faz martelo p/ direita cima
		# limpa direita
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,17 # x + 16 p/ posicao correta do martelo
		addi a1,t2,5 # y + 5
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_x
		call CLEAR_OBJPOS
		# limpa esquerda
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,-13 # x - 13 p/ posicao correta do martelo
		addi a1,t2,5 # y + 5
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_x
		call CLEAR_OBJPOS
		# limpa em cima
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,4 # x + 4 p/ posicao correta do martelo
		addi a1,t2,-15 # y -14
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_y
		call CLEAR_OBJPOS
		# printa em cima
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,4 # x + 4 p/ posicao correta do martelo
		addi a1,t2,-14 # y -14
		la a2,display
		lw a2,0(a2) # display atual
		la a3,martelo_y
		call PRINT_OBJ
		j FIM_MARIO_HAMMER_SPRITE
		MARIO_HAMMER_SPRITE_DIR_BAIXO:
			# limpa direita
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,17 # x + 16 p/ posicao correta do martelo
			addi a1,t2,5 # y + 5
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,martelo_x
			call CLEAR_OBJPOS
			# limpa esquerda
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,-13 # x - 13 p/ posicao correta do martelo
			addi a1,t2,5 # y + 5
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,martelo_x
			call CLEAR_OBJPOS
			# limpa em cima
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,4 # x + 4 p/ posicao correta do martelo
			addi a1,t2,-15 # y -14
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,martelo_y
			call CLEAR_OBJPOS
			# printa direita
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,16 # x + 16 p/ posicao correta do martelo
			addi a1,t2,5 # y + 5
			la a2,display
			lw a2,0(a2) # display atual
			la a3,martelo_x
			call PRINT_OBJ
			j FIM_MARIO_HAMMER_SPRITE
		
	MARIO_HAMMER_SPRITE_ESQ:
		beqz t1,MARIO_HAMMER_SPRITE_ESQ_BAIXO # se for 0, faz martelo p/ esquerda baixo
		# limpa direita
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,17 # x + 16 p/ posicao correta do martelo
		addi a1,t2,5 # y + 5
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_x
		call CLEAR_OBJPOS
		# limpa esquerda
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,-13 # x - 13 p/ posicao correta do martelo
		addi a1,t2,5 # y + 5
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_x
		call CLEAR_OBJPOS
		# limpa em cima
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,4 # x + 4 p/ posicao correta do martelo
		addi a1,t2,-15 # y -14
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase_current
		la a4,martelo_y
		call CLEAR_OBJPOS
		# printa martelo pra cima
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		lh t2,2(t0) # y do mario
		addi a0,t1,4 # x + 4 p/ posicao correta do martelo
		addi a1,t2,-14 # y -14
		la a2,display
		lw a2,0(a2) # display atual
		la a3,martelo_y
		call PRINT_OBJ_MIRROR
		j FIM_MARIO_HAMMER_SPRITE
		MARIO_HAMMER_SPRITE_ESQ_BAIXO:
			# limpa direita
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,17 # x + 16 p/ posicao correta do martelo
			addi a1,t2,5 # y + 5
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,martelo_x
			call CLEAR_OBJPOS
			# limpa esquerda
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,-13 # x - 13 p/ posicao correta do martelo
			addi a1,t2,5 # y + 5
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,martelo_x
			call CLEAR_OBJPOS
			# limpa em cima
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,5 # x + 4 p/ posicao correta do martelo
			addi a1,t2,-15 # y -14
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,martelo_y
			call CLEAR_OBJPOS
			# printa martelo pra baixo
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			lh t2,2(t0) # y do mario
			addi a0,t1,-13 # x - 13 p/ posicao correta do martelo
			addi a1,t2,5 # y + 5
			la a2,display
			lw a2,0(a2) # display atual
			la a3,martelo_x
			call PRINT_OBJ_MIRROR
		
	FIM_MARIO_HAMMER_SPRITE:
		free_stack(ra)
		ret

# Verifica a colisao do Mario com os barris da fase 1	
MARIO_BARREL_COLLISION:
	la t0,fase
	lb t1,0(t0)
	li t0,1
	bne t0,t1,FIM_MARIO_BARREL_COLLISION # se nao estiver na fase 1, nao faz nada
	
	la t0,pos_mario
	lh s0,0(t0) # x do mario
	lh s1,2(t0) # y do mario
	la t0,mario_state
	lb t1,0(t0)
	andi t0,t1,0x10 # verifica martelo
	bnez t0,MBC_HAMMER
	andi t1,t1,0x08 # verifica escada
	srli t1,t1,1
	addi s1,s1,13
	sub s1,s1,t1 # se tiver na escada, considera menos pixels
	# se y_mario + 18 (tamanho) >= y do barril && y_mario + 18 <= y_barril + 14
	la s2,var_barris
	li s3,6
	MBC_VERIF_Y: # verifica se o mario esta na altura passiva de colisao com barril
		beqz s3,FIM_MARIO_BARREL_COLLISION # verificados todos os barris, encerra
		lh a0,0(s2) # x do barril
		lh a1,2(s2) # y do barril
		addi t0,a1,14
		slt t0,s1,t0 # y_mario + 18 < y_barril + 14 ? 1 : 0 tem q dar 1
		slt t1,s1,a1 # y_mario + 18 < y_barril ? 1 : 0 tem q dar 0
		add t0,t0,t1 # soma as duas condicoes
		li t1,1
		beq t0,t1,MBC_VERIF_X # se estiver no range do barril, verifica eixo x 
		CONTINUE_MBC_VERIF_Y:
		addi s2,s2,4 # passa p/ proximo barril
		addi s3,s3,-1 # decrementa contador
		j MBC_VERIF_Y
		
	MBC_VERIF_X:
		slt t0,a0,s0 # x_barril < x_mario ? 1 : 0  tem q dar 1
		addi t1,a0,10
		slt t1,t1,s0 # x_barril + 14 < x_mario tem q dar 0
		add t0,t0,t1 # soma as duas condicoes
		li t1,1
		beq t0,t1,MARIO_DEATH # se colidir, morre
		addi t2,s0,12
		slt t0,a0,t2 # x_barril < x_mario + 16 tem q dar 1
		addi t1,a0,10
		slt t1,t1,t2 # x_barril + 14 < x_mario + 16 tem q dar 0
		add t0,t0,t1 # soma as duas condicoes
		li t1,1
		beq t0,t1,MARIO_DEATH # se colidir, morre
		j CONTINUE_MBC_VERIF_Y # do contrario, verifica os outros barris
	
	# Caso o mario esteja com o martelo
	MBC_HAMMER:
		# se y_mario + 18 (tamanho) >= y do barril && y_mario + 18 <= y_barril + 14
		addi s1,s1,15
		la s2,var_barris
		li s3,6
		MBC_VERIF_Y_HAMMER: # verifica se o mario esta na altura passiva de colisao com barril
			beqz s3,FIM_MARIO_BARREL_COLLISION # verificados todos os barris, encerra
			lh a0,0(s2) # x do barril
			lh a1,2(s2) # y do barril
			addi t0,a1,14
			slt t0,s1,t0 # y_mario + 18 < y_barril + 14 ? 1 : 0 tem q dar 1
			slt t1,s1,a1 # y_mario + 18 < y_barril ? 1 : 0 tem q dar 0
			add t0,t0,t1 # soma as duas condicoes
			li t1,1
			beq t0,t1,MBC_VERIF_X_HAMMER # se estiver no range do barril, verifica eixo x 
			CONTINUE_MBC_VERIF_Y_HAMMER:
			addi s2,s2,4 # passa p/ proximo barril
			addi s3,s3,-1 # decrementa contador
			j MBC_VERIF_Y_HAMMER
		
		MBC_VERIF_X_HAMMER:
			addi t2,s0,16 # -16 na posicao, por causa do martelo esquerda
			slt t0,a0,t2 # x_barril < x_mario - 16 ? 1 : 0  tem q dar 1
			addi t1,a0,12
			slt t1,t1,t2 # x_barril + 14 < x_mario - 16 tem q dar 0
			add t0,t0,t1 # soma as duas condicoes
			li t1,1
			mv a0,s3 # numero do barril (decrescente)
			mv a1,s2 # endereco do barril
			beq t0,t1,MARIO_BARREL_DESTROY # se colidir, destroi barril
			addi t2,s0,-16 # +16 na posicao, por causa do martelo direita
			slt t0,a0,t2 # x_barril < x_mario - 16 ? 1 : 0  tem q dar 1
			addi t1,a0,12
			slt t1,t1,t2 # x_barril + 14 < x_mario + 16 tem q dar 0
			add t0,t0,t1 # soma as duas condicoes
			li t1,1
			mv a0,s3 # numero do barril (decrescente)
			mv a1,s2 # endereco do barril
			beq t0,t1,MARIO_BARREL_DESTROY # se colidir, destroi barril
			j CONTINUE_MBC_VERIF_Y_HAMMER # do contrario, verifica os outros barris
			
	FIM_MARIO_BARREL_COLLISION:
		ret

# a0 = numero do barril a ser destruido
# a1 = endereco do var_barris (para facilitar)
MARIO_BARREL_DESTROY:
	save_stack(ra)
	save_stack(a0)
	save_stack(a1)
	lh t0,0(a1) # carrega x do barril
	lh t1,2(a1) # carrega y do barril
	mv a0,t0
	mv a1,t1
	la a2,display
	lw a2,0(a2)
	la a3,fase_current
	la a4,barril
	call CLEAR_OBJPOS # limpa no display

	li a0,500
	la t0,pos_mario
	lh a1,0(t0)
	lh a2,2(t0)
	addi a1,a1,20
	call GIVE_POINTS # da os pontos por destruir barril
	
	free_stack(a1)
	free_stack(a0)
	sh zero,0(a1) # zera contador do barril x
	sh zero,2(a1) # zera contador do barril y
	
	li t0,6
	sub t1,a0,t0 # 6 - numero do barril atual (decrescente)
	la t0,var_barris1
	add t0,t0,t1
	sb zero,0(t0) # zera contador
	la t0,var_barris2
	add t0,t0,t1
	sb zero,0(t0) # zera contador
	free_stack(ra)
	j FIM_MARIO_BARREL_COLLISION

# faz a morte do mario
MARIO_DEATH:
	# animacao e som de morte do mario
	# recebe mario morrendo y inicialmente
	mv a0,zero
	jal MARIO_DEATH_SOUND
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ # faz mario virado pra um lado
	
	addi a0,zero,1
	jal MARIO_DEATH_SOUND
	la a0,mario_morrendo_y
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRRORY # faz mario de cabeca pra baixo
	
	addi a0,zero,2
	jal MARIO_DEATH_SOUND
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRROR # faz mario virado pro outro lado
	
	addi a0,zero,3
	jal MARIO_DEATH_SOUND
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ # faz mario virado pra um lado
	
	addi a0,zero,4
	jal MARIO_DEATH_SOUND
	la a0,mario_morrendo_y
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRRORY # faz mario de cabeca pra baixo
	
	addi a0,zero,5
	jal MARIO_DEATH_SOUND
	la a0,mario_morrendo_x
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ_MIRROR # faz mario virado pro outro lado
	
	addi a0,zero,12
	jal MARIO_DEATH_SOUND
	la a0,mario_morto
	jal MARIO_DEATH_ANIM
	call PRINT_OBJ # printa mario no chao
	sleep(200)
	# fim da animacao
	addi a0,zero,13
	jal MARIO_DEATH_SOUND
	mv a0,a1
	li a7,32
	ecall # sleep do tempo de duracao
	
	addi a0,zero,14
	jal MARIO_DEATH_SOUND
	mv a0,a1
	li a7,32
	ecall # sleep do tempo de duracao
	
	addi a0,zero,15
	jal MARIO_DEATH_SOUND
	mv a0,a1
	li a7,32
	ecall # sleep do tempo de duracao
	
	addi a0,zero,16
	jal MARIO_DEATH_SOUND
	mv a0,a1
	li a7,32
	ecall # sleep do tempo de duracao
	# verifica se ainda tem vidas
	la t0,vidas
	lb t1,0(t0)	
	addi t1,t1,-1 # decrementa 1 vida
	sb t1,0(t0) # salva vida decrementada
	#bltz t1,GAME_OVER # se vidas < 0, game over
	bgez t1,FASE_RESET # se vidas >= 0, so reseta
	tail GAME_OVER # do contrario, game over
	
	# se ainda tiver vidas, decrementa e volta para o comeco
	FASE_RESET:
		la t0,fase
		lb t1,0(t0) # carrega numero da fase atual
		li t0,1
		beq t0,t1,MARIO_DEATH_FASE1 # se tiver na fase 1, reseta na fase1
		li t0,2
		beq t0,t1,MARIO_DEATH_FASE2 # se tiver na fase 2, reseta na fase2
		li t0,3
		beq t0,t1,MARIO_DEATH_FASE3 # se tiver na fase 3, reseta na fase3
		li t0,4
		beq t0,t1,MARIO_DEATH_FASE4 # se tiver na fase 4, reseta na fase4
		tail GAME_OVER
		
		MARIO_DEATH_FASE1:
			tail INIT_FASE1
		MARIO_DEATH_FASE2:
			tail INIT_FASE2
		MARIO_DEATH_FASE3:
			tail INIT_FASE3
		MARIO_DEATH_FASE4:
			tail INIT_FASE4
	
	
	
# prepara animacao do mario morrendo
# a0 = sprite a ser mostrado (para facilitar)
MARIO_DEATH_ANIM:
	save_stack(ra)
	mv s0,a0
	sleep(300)
	
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
	la t0,sounds
	lb t1,0(t0)
	beqz t1,FIM_MARIO_DEATH_SOUND # sons desligados
	
	la t0,NOTAS_MARIOMORRE
	addi t1,zero,12
	mv t2,a0
	slli a0,a0,3 # multiplica por 8
	add t0,t0,a0 # pula pra posicao do audio desejado
	lw a0,0(t0) # carrega nota
	lw a1,4(t0) # carrega duracao
	bge t2,t1,MARIO_DEATH_SOUND_PT2 # se passou primeira parte, toca instrumento 80
	li a2,74 # instrumento primeira parte
	j CONT_MARIO_DEATH_SOUND
	MARIO_DEATH_SOUND_PT2:
	li a2,80 # instrumento segunda parte
	CONT_MARIO_DEATH_SOUND:
	li a3,127 # volume
	li a7,31 # ecall som async
	ecall
	FIM_MARIO_DEATH_SOUND:
		ret

# Toca som de passo do mario
# a0 = passo (0 ou 1)
MARIO_STEP_SOUND:
	la t0,sounds
	lb t1,0(t0)
	beqz t1,FIM_MARIO_STEP_SOUND # sons desligados
	
	slli a0,a0,3
	# toca som do passo a0
	la t0,NOTAS_PASSOS
	add t0,t0,a0
	lw a0,0(t0)
	lw a1,4(t0) # carrega duracao
	li a2,80
	li a3,127
	li a7,31
	ecall
	FIM_MARIO_STEP_SOUND:
		ret
