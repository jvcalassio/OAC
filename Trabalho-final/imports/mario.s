#################################################
# Responsavel por gerenciar movimentos do Mario
#################################################
.eqv START_MARIO_X_FASE1 84
.eqv START_MARIO_Y_FASE1 199

# move o mario +x px, +y px, usando o sprite desejado
.macro set_mario_move(%x,%y,%sprite)
	la t0,pos_mario # pega posicao do mario novamente
	lh a0,0(t0)     # pois a funcao anterior modifica os valores
	lh a1,2(t0)
	addi a0,a0,%x # adiciona +x no X
	addi a1,a1,%y # adiciona +y no Y
	sh a0,0(t0) # grava X
	sh a1,2(t0) # grava y
	la t0,display
	lw a2,0(t0) # carrega qual display usar 
	la a3,%sprite # label do sprite a ser utilizado
.end_macro

# remove um sprite do mario nas posicoes atuais
.macro rmv_mario(%sprite)
	la t0,pos_mario # carrega posicao do mario
	lh a0,0(t0) # carrega x
	lh a1,2(t0) # carrega y
	la a2,display
	lw a2,0(a2) # carrega display atual
	la a3,fase
	lw a3,0(a3) # carrega fase atual
	la a4,%sprite # carrega sprite
	jal CLEAR_OBJPOS # limpa mario na posicao atual
.end_macro

.data
.include "../sprites/bin/mario_parado.s"
.include "../sprites/bin/mario_andando_p1.s"
.include "../sprites/bin/mario_andando_p2.s"
.include "../sprites/bin/mario_andando_p3.s"
.include "../sprites/bin/mario_pulando.s"
.include "../sprites/bin/mario_pulando_queda.s" 
mario_state: .byte 0 # salva estado atual do mario
pulo_px: .byte 0,0 # salva pixels movidos no pulo
pos_mario: .half 0,0 # salva posicao atual do mario (x,y)
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
		set_mario_move(START_MARIO_X_FASE1,START_MARIO_Y_FASE1,mario_parado)
		jal PRINT_OBJ # printa mario na posicao inicial
		
		la t0,mario_state # seta mario_state como 0
		sh zero,0(t0) # seta 00000 no mario state (parado no chao virado pra direita)
	
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
		rmv_mario(mario_parado)
		
		set_mario_move(1,0,mario_andando_p1) # se move 1px pra direita
		jal PRINT_OBJ # printa mario passo 1 na tela
	
		# sleep entre os passos (20ms)
		li a0,30
		li a7,32
		ecall
	
	MVMD_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(1,0,mario_andando_p2) # se move 1px pra direita
		jal PRINT_OBJ # printa mario passo 2 na tela
		
		# sleep entre os passos (20ms)
		li a0,30
		li a7,32
		ecall
	
	MVMD_P3: # faz passo 3
		rmv_mario(mario_andando_p2)
		
		set_mario_move(1,0,mario_andando_p3) # se move 1px pra direita
		jal PRINT_OBJ # printa mario passo 3 na tela
	
		# sleep entre os passos (20ms)
		li a0,30
		li a7,32
		ecall
	
	MVMD_P0: # faz mario parado novamente
		rmv_mario(mario_andando_p3)
		
		set_mario_move(1,0,mario_parado) # se move 1px pra direita
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
	addi t0,t0,12 # add +12 pra saber a posicao do pe do mario na descida de degrau
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
	jal MV_1PXDW
	
	MVME_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		set_mario_move(-1,0,mario_andando_p1) # se move 1px pra esquerda
		jal PRINT_OBJ_MIRROR # printa mario passo 1 na tela
	
		# sleep entre os passos (20ms)
		li a0,30
		li a7,32
		ecall
	
	MVME_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(-1,0,mario_andando_p2) # se move 1px pra esquerda
		jal PRINT_OBJ_MIRROR # printa mario passo 2 na tela
		
		# sleep entre os passos (20ms)
		li a0,30
		li a7,32
		ecall
	
	MVME_P3: # faz passo 3
		rmv_mario(mario_andando_p2)
		
		set_mario_move(-1,0,mario_andando_p3) # se move 1px pra esquerda
		jal PRINT_OBJ_MIRROR # printa mario passo 3 na tela
	
		# sleep entre os passos (20ms)
		li a0,30
		li a7,32
		ecall
	
	MVME_P0: # faz mario parado novamente
		rmv_mario(mario_andando_p3)
		
		set_mario_move(-1,0,mario_parado) # se move 1px pra esquerda
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
	li t1,0x04
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
	li a0,26
	li a7,32
	ecall # sleep de 26ms, entre cada movimento para cima, para ficar mais fluido
	
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
		andi t2,t1,0x04 # verificador de qual lado o mario esta
		
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,8
		sb t1,1(t0) # salva que ele subiu 8px no byte de pulo
		
		set_mario_move(0,-8,mario_pulando) # se move 8px pra cima
		
		beqz t2,PULO_UP_PDIR
		j PULO_UP_PESQ
		
	MARIO_PULO_UP_SOBE:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1 # sobe 1px no pulopx
		sb t1,1(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t2,t1,0x04 # verificador de qual o lado do mario
		
		set_mario_move(0,-1,mario_pulando) # se move 1px pra cima
		
		beqz t2,PULO_UP_PDIR
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
		andi t2,t1,0x04 # verificador de qual o lado do mario
		
		set_mario_move(0,0,mario_pulando) # nao se move nesse frame
		
		beqz t2,PULO_UP_PDIR
		j PULO_UP_PESQ
	
	MARIO_PULO_UP_DESCE:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		la t0,mario_state
		lb t1,0(t0)
		andi t2,t1,0x04 # pega para qual lado o mario esta virado
		
		set_mario_move(0,1,mario_pulando) # se move 1px pra baixo
		
		beqz t2,PULO_UP_PDIR
		j PULO_UP_PESQ
	
	MARIO_PULO_UP_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x04
		sb t1,0(t0) # salva estado do mario no chao, virado pro lado onde ja estava
		
		set_mario_move(0,8,mario_parado) # se move 8px pra baixo
		
		beqz t1,PULO_UP_PDIR
		
	PULO_UP_PESQ: # pula pra cima parado, virado pra esquerda
		jal PRINT_OBJ_MIRROR
		j FIM_PULO_UP
	PULO_UP_PDIR: # pula pra cima parado, virado pra direita
		jal PRINT_OBJ
	
	FIM_PULO_UP:
		j MAINLOOP

# realiza mario pulando pra direita em movimento
MARIO_PULO_DIR:
	li a0,26
	li a7,32
	ecall # sleep de 26ms, entre cada movimento para cima, para ficar mais fluido
	
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
		
		set_mario_move(1,-1,mario_pulando) # se move 1px pra cima, 1px pra direita
		
		j PULO_DIR_ANIM
		
	MARIO_PULO_DIR_INIT_DESCIDA:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1
		sb t1,1(t0) # faz o subida = 13, assim nao conflita nos beqs la em cima
		lb t1,0(t0)
		addi t1,t1,8
		sb t1,0(t0) # adiciona 8 pra descida
		
		set_mario_move(1,0,mario_pulando) # se move apenas 1px pra direita, sem subir nem descer
		
		j PULO_DIR_ANIM
	
	MARIO_PULO_DIR_DESCE:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		set_mario_move(1,1,mario_pulando) # se move 1px pra baixo, 1px pra direita
		
		j PULO_DIR_ANIM
	
	MARIO_PULO_DIR_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		sb zero,0(t0) # salva estado do mario no chao, virado pra direita
		
		set_mario_move(4,8,mario_parado) # se move 8px pra baixo, 4px pra direita p/ finalizar pulo
		
	PULO_DIR_ANIM: # pula pra direita em movimento
		jal PRINT_OBJ
	
	FIM_PULO_DIR:
		j MAINLOOP

# realiza mario pulando pra esquerda em movimento
MARIO_PULO_ESQ:
	li a0,26
	li a7,32
	ecall # sleep de 26ms, entre cada movimento para cima, para ficar mais fluido
	
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
		
		set_mario_move(-1,-1,mario_pulando) # se move 1px pra cima, 1px pra esquerda
		
		j PULO_ESQ_ANIM
		
	MARIO_PULO_ESQ_INIT_DESCIDA:
		la t0,pulo_px
		lb t1,1(t0)
		addi t1,t1,1
		sb t1,1(t0) # faz o subida = 13, assim nao conflita nos beqs la em cima
		lb t1,0(t0)
		addi t1,t1,8
		sb t1,0(t0) # adiciona 8 pra descida
		
		set_mario_move(-1,0,mario_pulando) # se move apenas 1px pra esquerda, sem subir nem descer
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_DESCE:
		la t0,pulo_px
		lb t1,0(t0)
		addi t1,t1,1 # desce 1px no pulopx
		sb t1,0(t0)
		
		set_mario_move(-1,1,mario_pulando) # se move 1px pra baixo, 1px pra esquerda
		
		j PULO_ESQ_ANIM
	
	MARIO_PULO_ESQ_RESET:
		la t0,pulo_px
		sb zero,0(t0)
		sb zero,1(t0) # reseta pulopx
		
		la t0,mario_state
		li t1,0x04
		sb t1,0(t0) # salva estado do mario no chao, virado pra esquerda
		
		set_mario_move(-4,8,mario_parado) # se move 8px pra baixo, 4px pra esquerda p/ finalizar pulo
		
	PULO_ESQ_ANIM: # pula pra esquerda em movimento
		jal PRINT_OBJ_MIRROR
	
	FIM_PULO_ESQ:
		j MAINLOOP
