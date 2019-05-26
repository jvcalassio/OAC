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
	call CLEAR_OBJPOS # limpa mario na posicao atual
.end_macro

# pega a posicao do mario no map
.macro mario_mappos(%result)
	la t0,pos_mario
	lh t1,0(t0) # x do mario
	lh t2,2(t0) # y do mario
	
	addi t1,t1,16 # +16 para saber posicao do pe direito do mario
	addi t2,t2,20 # +16 --
	srli t1,t1,2 # x / 4 para alinhar com mapeamento
	srli t2,t2,2 # y / 4 para alinhar com mapeamento
	
	la t0,fase1_obj
	li t3,80
	mul t3,t2,t3 # (y * 80)
	add t3,t3,t1 # (y * 80) + n
	add %result,t0,t3 # endereco da posicao desejada
.end_macro

.data
.include "../sprites/bin/mario_parado.s"
.include "../sprites/bin/mario_andando_p1.s"
.include "../sprites/bin/mario_andando_p2.s"
.include "../sprites/bin/mario_andando_p3.s"
.include "../sprites/bin/mario_pulando.s"
.include "../sprites/bin/mario_pulando_queda.s" 
.include "../sprites/bin/mario_escada.s"
.include "../sprites/bin/mario_escada_p1.s"
.include "../sprites/bin/mario_escada_p2.s"
.include "../sprites/bin/mario_costas.s"
.include "../sprites/bin/mario_morrendo_y.s"

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
		call PRINT_OBJ # printa mario na posicao inicial
		
		la t0,mario_state # seta mario_state como 0
		sh zero,0(t0) # seta 00000 no mario state (parado no chao virado pra direita)
	
	FIM_INIT_MARIO:
		free_stack(ra)
		ret

# Faz o movimento do mario para a direita
MOVE_MARIO_DIREITA:
	save_stack(a0)
	
	li a0,1
	call MARIO_COLLISIONS # verifica permissao do movimento
	beqz a0,FIM_MVMD_RET # se nao for permitido, so retorna
	
	# verificacao de degraus
	call MARIO_VERIF_DEGRAU
	beqz a0,MVMD_P1 # se nao tiver degrau, nao faz nada
	li t0,0x03
	beq a0,t0,DDIR_TIPO_D # se tiver degrau do tipo D
	# se tiver degrau do tipo A, desce
	jal MV_1PXDW
	j MVMD_P1
	
	DDIR_TIPO_D: # se tiver degrau do tipo D, desce
	jal MV_1PXUP
	
	#jal MV_1PXUP # move mario 1px acima
	
	MVMD_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		set_mario_move(1,0,mario_andando_p1) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 1 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVMD_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(1,0,mario_andando_p2) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 2 na tela
		
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVMD_P3: # faz passo 3
		rmv_mario(mario_andando_p2)
		
		set_mario_move(1,0,mario_andando_p3) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo 3 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVMD_P0: # faz mario parado novamente
		rmv_mario(mario_andando_p3)
		
		set_mario_move(1,0,mario_parado) # se move 1px pra direita
		call PRINT_OBJ # printa mario passo final na tela
	
	# com isso, o mario se movimentou um total de 4px
	FIM_MVMD:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x10
		sb t1,0(t0) # salva o estado atual do mario
	FIM_MVMD_RET:
		free_stack(a0) # devolve valor de a0
		tail MAINLOOP_RET
	
MOVE_MARIO_ESQUERDA:
	save_stack(a0)
	
	li a0,2
	call MARIO_COLLISIONS # verifica permissao do movimento
	beq a0,zero,FIM_MVME_RET # se nao for permitido, retorna
	
	# verificacao de degraus
	call MARIO_VERIF_DEGRAU
	beqz a0,MVME_P1 # se nao tiver degrau, nao faz nada
	li t0,0x03
	beq a0,t0,DESQ_TIPO_D # se tiver degrau do tipo D
	# se tiver degrau do tipo A, sobe
	jal MV_1PXUP
	j MVME_P1
	
	DESQ_TIPO_D: # se tiver degrau do tipo D, desce
	jal MV_1PXDW
	
	# colisao com as paredes (missing)
	
	MVME_P1: # faz passo 1
		rmv_mario(mario_parado)
		
		set_mario_move(-1,0,mario_andando_p1) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 1 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVME_P2: # faz passo 2
		rmv_mario(mario_andando_p1)
		
		set_mario_move(-1,0,mario_andando_p2) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 2 na tela
		
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVME_P3: # faz passo 3
		rmv_mario(mario_andando_p2)
		
		set_mario_move(-1,0,mario_andando_p3) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo 3 na tela
	
		# sleep entre os passos (20ms)
		li a0,20
		li a7,32
		ecall
	
	MVME_P0: # faz mario parado novamente
		rmv_mario(mario_andando_p3)
		
		set_mario_move(-1,0,mario_parado) # se move 1px pra esquerda
		call PRINT_OBJ_MIRROR # printa mario passo final na tela
	
	# com isso, o mario se movimentou um total de -4px
	FIM_MVME:
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x14
		ori t1,t1,0x04
		sb t1,0(t0) # salva o estado atual do mario (parado virado pra esquerda)
	FIM_MVME_RET:
		free_stack(a0) # devolve valor de a0
		tail MAINLOOP_RET

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
	la t0,mario_state
	lb t1,0(t0)
	andi t1,t1,0x1A # verifica se pode pular
	bne t1,zero,FIM_PULO_UP # se nao puder pular, sai

	li a0,20
	li a7,32
	ecall # sleep de 20ms, entre cada movimento para cima, para ficar mais fluido
	
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
		call PRINT_OBJ_MIRROR
		j FIM_PULO_UP
	PULO_UP_PDIR: # pula pra cima parado, virado pra direita
		call PRINT_OBJ
	
	FIM_PULO_UP:
		tail MAINLOOP_RET

# realiza mario pulando pra direita em movimento
MARIO_PULO_DIR:
	la t0,mario_state 
	lb t1,0(t0)
	andi t1,t1,0x18 # verifica se pode pular
	bne t1,zero,FIM_PULO_DIR # se nao puder pular, sai

	li a0,20
	li a7,32
	ecall # sleep de 20ms, entre cada movimento para cima, para ficar mais fluido
	
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

	li a0,20
	li a7,32
	ecall # sleep de 20ms, entre cada movimento para cima, para ficar mais fluido
	
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
#	7 = subir andar		8 = descer andar
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
		ecall
		
		la a0,blank
		li a7,4
		ecall
		
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
	
	FIM_MARIO_GRAVITY:
		free_stack(s0)
		free_stack(ra)
		ret

# faz a morte do mario (0 vidas por enquanto)	
MARIO_DEATH:
	li a0,500
	li a7,32
	ecall # sleep 500ms

	la t0,display
	lw s0,0(t0)
	li s2,DISPLAY1
	li t0,76800 # 320 * 240 pixels, tamanho total da imagem
	FORDEATH: # tela preta
		beqz t0,FIMFORDEATH
		sb zero,0(s0)
		sb zero,0(s2)
		addi s0,s0,1
		addi s2,s2,1
		addi t0,t0,-1
		j FORDEATH
	FIMFORDEATH:
		la a0,death_text
		li a1,80
		li a2,50
		li a3,0x00ff
		li a4,0
		li a7,104
		ecall
	
	tail FIM
	
# temporario
PRINT_ACT_POS:
	mario_mappos(t0)
	
	mv t1,a0
	lb a0,0(t0)
	li a7,34
	ecall
	mv a0,t1
	ret
