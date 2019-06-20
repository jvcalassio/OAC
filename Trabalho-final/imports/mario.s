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
	la t1,fase 
	lb t0,0(t1) # carrega numero da fase atual
	li t1,1
	beq t0,t1,INIT_MARIO_F1 # se fase atual for fase 1, printa mario parado na fase 1
	li t1,2
	beq t0,t1,INIT_MARIO_F2 # se fase atual for fase 2, printa mario parado na fase 2
	li t1,3
	beq t0,t1,INIT_MARIO_F3 # se fase atual for fase 3, printa mario parado na fase 3
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
	j FIM_MMPOS
	
	MMPOS_FASE1:
	la a1,fase1_obj
	j MMPOS_CONTINUE
	MMPOS_FASE2:
	la a1,fase2_obj
	j MMPOS_CONTINUE
	MMPOS_FASE3:
	la a1,fase3_obj
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
		
		set_mario_move(2,0,mario_andando_p1) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 1 na tela
		
		la t0,movement_counter
		addi t1,zero,1
		sw t1,0(t0) # salva q fez passo 1
		
		li a0,0
		call MARIO_STEP_SOUND
		
		j FIM_MVMD_ANDANDO
	
	MVMD_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(2,0,mario_andando_p2) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 2 na tela
	
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
		
		set_mario_move(-2,0,mario_andando_p1) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 1 na tela
		
		la t0,movement_counter
		addi t1,zero,1
		sw t1,0(t0) # salva q fez passo 1
		
		li a0,0
		call MARIO_STEP_SOUND
		
		j FIM_MVME_ANDANDO
	
	MVME_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(-2,0,mario_andando_p2) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 2 na tela
		
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
	la t0,mario_state 
	lb t1,0(t0)
	andi t1,t1,0x18 # verifica se pode pular
	bne t1,zero,FIM_PULO_DIR # se nao puder pular, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
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
		save_stack(s0)
		mario_mappos(s0)
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
	
		set_mario_move(4,8,mario_parado) # se move 8px pra baixo, 4px pra direita p/ finalizar pulo
		
	PULO_DIR_ANIM: # pula pra direita em movimento
		call PRINT_OBJ
	
	FIM_PULO_DIR:
		tail MAINLOOP_RET

# realiza mario pulando pra esquerda em movimento
MARIO_PULO_ESQ:
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x18 # verifica se pode pular
	bne t1,zero,FIM_PULO_ESQ # se nao puder, sai
	
	rmv_mario(mario_pulando) # remove mario na posicao atual
	
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
		save_stack(s0)
		mario_mappos(s0) # pega posicao atual do mario
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
	
		set_mario_move(-4,8,mario_parado) # se move 8px pra baixo, 4px pra esquerda p/ finalizar pulo
		#set_mario_move(0,0,mario_parado)
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
		call GET_POSITION
		lb t0,0(a0) # t0 = pixel ao lado
		li t2,128
		beq t0,t2,MVDIR_PXUP # se for piso azul
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
		call GET_POSITION
		lb t0,0(a0)
		li t2,0x00
		bne t0,t2,MARIO_CL_ALLOW # se px abaixo nao for preto, simplesmente permite mov
		call MV_1PXDW # se px abaixo for preto (acabou chao), desce 1 degrau
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
		call GET_POSITION
		lb t0,0(a0)
		li t2,128
		beq t0,t2,MVESQ_PXUP # se for piso azul
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
		call GET_POSITION
		lb t0,0(a0)
		li t2,0x00
		bne t0,t2,MARIO_CL_ALLOW # se px abaixo nao for preto, simplesmente permite mov
		call MV_1PXDW # se px abaixo for preto (acabou chao), desce 1 degra
		j MARIO_CL_ALLOW # se der zero, passa
		
	VERIF_MV_CIMA:
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
		call PRINT_OBJ # printa mario posicao abaixo
		sleep(20) # questionavel, avaliar desempenho
	
	FIM_MARIO_GRAVITY:
		free_stack(s0)
		free_stack(ra)
		ret

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
		tail GAME_OVER
		
		MARIO_DEATH_FASE1:
			tail INIT_FASE1
		MARIO_DEATH_FASE2:
			tail INIT_FASE2
		MARIO_DEATH_FASE3:
			tail INIT_FASE3
	
	
	
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
