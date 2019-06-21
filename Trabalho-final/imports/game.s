.include "macros.s"
.include "macros2.s"

.data
# Sons
.include "../sounds/som.s"

.include "fases/fase1_obj.s"
.include "fases/fase2_obj.s"
.include "fases/fase3_obj.s"

.include "../sprites/bin/fase_current.s" # fase atual (inicialmente fase 1)
# Variaveis de jogo
display: .word DISPLAY0,DISPLAY1 # endereco do display utilizado no momento

fase: .byte 1 # primeira fase 
level: .byte 1 # primeiro lvl

vidas: .byte 2 # quantidade de vidas (inicia em 2)
highscore: .word 0 # highscore atual
score: .word 0 # score atual
last_key: .word 0,0 # ultima tecla pressionada (tecla, tempo)
bonus_time: .word 0 # ultimo tempo de modificacao do bonus
bonus: .word 0 # bonus inicial da fase

# contadores
ambient_sound_counter: .byte 0 # contador de qual o ultimo som da fase
ambient_sound_timer: .word 0 # tempo de reproducao
sounds: .byte 0 # sons ligados
given_extra_life: .byte 0 # flag de vida extra concedida ou nao
.text
	M_SetEcall(exceptionHandling)
# Inicia o jogo (iniciando as variaveis) 
INIT_GAME:
	addi t0,zero,2
	la t1,vidas
	sb t0,0(t1) # reinicia a vida
	la t0,score
	sw zero,0(t0) # reinicia score
	la t0,last_key
	sw zero,0(t0)
	sw zero,4(t0) # reinicia last key
	la t0,given_extra_life
	sb zero,0(t0) # reinicia vida extra concedida
	
	li t1,1
	la t0,fase
	sb t1,0(t0) # seta fase1
	la t0,level 
	sb t1,0(t0) # seta lvl1
	
	la t0,ambient_sound_counter
	sb zero,0(t0) # salva counter em 0
	la t0,ambient_sound_timer
	sw zero,0(t0)
	
	# Como o jogo comeca na fase 1, nao precisa passar por "init fase1", e consequentemente, carregar
	jal SET_FASE3
	call F3_ADD_BLOCKS
	jal PRINT_FASE
	call PRINT_TEXT_INITIAL
	call INIT_MARIO
	call INIT_DK_DANCA
	call INIT_LADY
	call INIT_BONUS
	call INIT_ITEMS
	call INIT_SOUND
	j MAINLOOP
		
# Inicia a fase 1
INIT_FASE1:
	jal LOADING_SCR
	jal SET_FASE1
	jal PRINT_FASE
	call PRINT_TEXT_INITIAL
	call INIT_MARIO
	call INIT_DK_DANCA
	call INIT_LADY
	call INIT_BONUS
	call INIT_ITEMS
	call INIT_SOUND
	j MAINLOOP

# Inicia a fase 2
INIT_FASE2:
	jal LOADING_SCR
	jal SET_FASE2
	jal PRINT_FASE
	call PRINT_TEXT_INITIAL
	call INIT_MARIO
	call INIT_DK_DANCA
	call INIT_LADY
	call INIT_BONUS
	call INIT_ITEMS
	call INIT_SOUND
	j MAINLOOP
	
# Inicia a fase 3
INIT_FASE3:
	jal LOADING_SCR
	jal SET_FASE3
	call F3_ADD_BLOCKS
	jal PRINT_FASE
	call PRINT_TEXT_INITIAL
	call INIT_MARIO
	call INIT_DK_DANCA
	call INIT_LADY
	call INIT_BONUS
	call INIT_ITEMS
	call INIT_SOUND
	j MAINLOOP

# Imprime fase 1 no fase current, e salva no indicador de fase atual
SET_FASE1:
	la t0,fase
	lb t1,0(t0) # carrega fase atual
	li t0,1
	beq t0,t1,RET_LOADFASE1 # se ja estava na fase 1, nao precisa carregar denovo
	DE1(LOADFASE1_DE1) # se estiver na DE1, carrega o mapa do USB serial
	# do contrario, carregar do endereco no RARS
	la s1,fase_current # endereco do mapa geral
	li t0,76800
	la t1,fase1
	addi t1,t1,8 # pula as words que indicam o tamanho da imagem
	FOR_LOADFASE1:
		beqz t0,FIM_LOADFASE1
		lb t2,0(t1) # carrega byte do mapa
		sb t2,0(s1) # grava byte no current
		addi t1,t1,1
		addi s1,s1,1
		addi t0,t0,-1
		j FOR_LOADFASE1
		
	LOADFASE1_DE1:
		save_stack(ra)
		li a0,1
		call MAP_RETRIEVER
		free_stack(ra)
		
	FIM_LOADFASE1:
	la t0,fase
	li t1,1
	sb t1,0(t0) # salva fase atual como 1
	la t0,ambient_sound_counter
	sb zero,0(t0) # reseta contador do som
	la t0,ambient_sound_timer
	sw zero,0(t0) # reseta timer do som
	RET_LOADFASE1:
		ret
		
# Imprime fase 2 no fase current, e salva no indicador de fase atual
SET_FASE2:
	la t0,fase
	lb t1,0(t0)
	li t0,2
	beq t0,t1,RET_LOADFASE2 # se ja estava na fase 2, nao precisa carregar denovo
	DE1(LOADFASE2_DE1) # se estiver na DE1, carrega o mapa do USB serial
	# do contrario, carregar do endereco no RARS
	la s1,fase_current # endereco do mapa geral
	li t0,76800
	#la t1,fase2
	addi t1,t1,8 # pula as words que indicam o tamanho da imagem
	FOR_LOADFASE2:
		beqz t0,FIM_LOADFASE2
		lb t2,0(t1) # carrega byte do mapa
		sb t2,0(s1) # grava byte no current
		addi t1,t1,1
		addi s1,s1,1
		addi t0,t0,-1
		j FOR_LOADFASE2
	
	LOADFASE2_DE1:
		save_stack(ra)
		li a0,2
		call MAP_RETRIEVER
		free_stack(ra)
			
	FIM_LOADFASE2:
	la t0,fase 
	li t1,2 
	sb t1,0(t0) # salva fase atual como 2
	la t0,ambient_sound_counter
	sb zero,0(t0) # reseta contador do som
	la t0,ambient_sound_timer
	sw zero,0(t0) # reseta timer do som
	RET_LOADFASE2:
		ret
	
# Imprime fase 3 no fase current, e salva no indicador de fase atual
SET_FASE3:
	la t0,fase
	lb t1,0(t0)
	li t0,3
	beq t0,t1,RET_LOADFASE3 # se ja estava na fase 3, nao precisa carregar denovo, apenas os blocos
	DE1(LOADFASE3_DE1) # se estiver na DE1, carrega o mapa do USB serial
	# do contrario, carregar do endereco no RARS
	la s1,fase_current # endereco do mapa geral
	li t0,76800
	la t1,fase3
	addi t1,t1,8 # pula as words que indicam o tamanho da imagem
	FOR_LOADFASE3:
		beqz t0,FIM_LOADFASE3
		lb t2,0(t1) # carrega byte do mapa
		sb t2,0(s1) # grava byte no current
		addi t1,t1,1
		addi s1,s1,1
		addi t0,t0,-1
		j FOR_LOADFASE3
		
	LOADFASE3_DE1:
		save_stack(ra)
		li a0,3
		call MAP_RETRIEVER
		free_stack(ra)
	
	FIM_LOADFASE3:
		la t0,fase
		li t1,3
		sb t1,0(t0) # salva fase atual como 3
		la t0,ambient_sound_counter
		sb zero,0(t0) # reseta contador do som
		la t0,ambient_sound_timer
		sw zero,0(t0) # reseta timer do som
		#la t0,fase3_given_blocks
		#sb zero,0(t0) # reseta contador de golden blocks na fase 3
	RET_LOADFASE3:
		ret

# Imprime a fase atual na tela
PRINT_FASE:
	la t0,display
	lw s0,0(t0) # primeiro display
	lw s2,4(t0) # segundo display	
	la s1,fase_current # carrega fase atual
	li t0,76800 # 320 * 240 pixels, tamanho total da imagem
	FORFASE_PRINT:
		beqz t0,FIMFORFASE_PRINT
		lb t2,0(s1)
		sb t2,0(s0)
		sb t2,0(s2)
		addi s0,s0,1
		addi s1,s1,1
		addi s2,s2,1
		addi t0,t0,-1
		j FORFASE_PRINT
	FIMFORFASE_PRINT:
		ret
		
# anotacao temporaria das teclas
# tecla 109 = M (sair)
# tecla 100 = D
# tecla 97 = A
# tecla 119 = W
# tecla 115 = S
# tecla 32 = espaco
# fim anotacao temporaria 
MAINLOOP: # loop de jogo, verificar se tecla esta pressionada
	# mudar display
	#la t0,display
	#lw t1,0(t0) # display atual
	#lw t2,4(t0) # display anterior
	#sw t2,0(t0)
	#sw t1,4(t0) # troca displays na variavel
	#li t0,CDISPLAY
	#lw t1,0(t0) # carrega qual o display mostrado atual
	#xori t1,t1,0x01
	#sw t1,0(t0) # seta display
	# fim mudar display
	
	# verifica e toca o som ambiente
	call AMBIENT_SOUND
	
	# Modifica valores de variaveis (highscore, bonus)
	call HIGHSCORE_BONUS_MANAGEMENT
	
	# Imprime variaveis de jogo (score, vidas, highscore, bonus)
	call PRINT_TEXT
	
	call CHECK_ITEMS 
	
	jal CHECK_VICTORY
	
	jal CONTINUE_MOVEMENT
	
	la t0,mario_state
	lb t1,0(t0)
	andi t2,t1,0x01 # verifica se esta pulando
	beqz t2,MAINLOOP_KEYBIND # se nao estiver pulando, vai pro keybind
	# se estiver pulando, verifica se eh pra cima ou direcionado
	andi t2,t1,0x02 # verifica se eh direcionado
	beqz t2,MPUP # se nao for, faz pulo pra cima
	# se for direcionado, verifica qual direcao
	andi t2,t1,0x04
	beqz t2,MPDIR # se for pra direita, faz pulo pra direita
	li t2,0x07
	beq t2,t1,MPESQ # se for pra esquerda, faz pulo pra esquerda
	
	MAINLOOP_KEYBIND:
	call MARIO_GRAVITY
	call KEYBIND
	beqz a0,MAINLOOP_RET # se nenhuma tecla, faz nada
		# salva ultima tecla pressionada
		la t0,last_key
		sw a0,0(t0) # salva tecla
		li a7,30
		ecall
		sw a0,4(t0) # salva tempo
		lw a0,0(t0) # retorna tecla
		
		li t0,109
		beq a0,t0,FIM # se tecla == M, sair  
		
		li t0,100 # D = direita
		beq a0,t0,BCALL_MV_MARIO_DIREITA

		li t0,97 # A = esquerda
		beq a0,t0,BCALL_MV_MARIO_ESQUERDA
	
		li t0,32 # espaco = pulo
		beq a0,t0,BCALL_MV_MARIO_PULO
		
		li t0,119 # W = cima
		beq a0,t0,BCALL_MV_MARIO_CIMA
		
		li t0,115 # S = baixo
		beq a0,t0,BCALL_MV_MARIO_BAIXO
		
		li t0,101 # E = pulo dir
		beq a0,t0,BCALL_MV_MARIO_PULO_DIR
		
		li t0,113 # Q = pulo esq
		beq a0,t0,BCALL_MV_MARIO_PULO_ESQ
		
		li t0,'n' # N = prox fase (hack)
		beq a0,t0,GAME_VICTORY 
		
	MAINLOOP_RET:
		call DK_DANCA_LOOP
		call LADY_LOOP
		call F3_CHECK_BLOCK
		
		la t0,level
		lb t1,0(t0) # carrega lvl atual
		# escolhe sleep baseado no lvl
		li t0,-5
		mul t1,t1,t0 # lvl x -5
		li t0,-30
		ble t1,t0,MAINLOOP_RET_SLEEP0 # se o coeficiente der menor ou igual a -30, joga sem sleep
		# do contrario, faz sleep de 30 - coeficiente ms
		li a0,30
		sub a0,a0,t1
		li a7,32
		ecall
		MAINLOOP_RET_SLEEP0: # sem sleep
		j MAINLOOP
	MPUP: tail MARIO_PULO_UP
	MPDIR: tail MARIO_PULO_DIR
	MPESQ: tail MARIO_PULO_ESQ

# Reproduz som ambiente da fase
AMBIENT_SOUND:
	la t0,sounds
	lb t1,0(t0)
	beqz t1,FIM_AMBIENT_SOUND # sons desligados
	
	la t0,fase
	lb t1,0(t0)
	li t0,2
	beq t0,t1,FIM_AMBIENT_SOUND # fase 2 nao tem som ambiente
	
	la t0,ambient_sound_timer
	lw t1,0(t0)
	gettime()
	sub s0,a0,t1 # tempo atual - tempo do ultimo som
	
	la t0,fase
	lb t1,0(t0)
	addi t0,zero,1
	beq t0,t1,AMBIENT_SOUND_F1
	addi t0,zero,3
	beq t0,t1,AMBIENT_SOUND_F3
	j FIM_AMBIENT_SOUND # fase 2 nao tem som ambiente
	
	AMBIENT_SOUND_F1:
		la t0,ambient_sound_counter
		lb t1,0(t0) # carrega contador
		slli t1,t1,3 # multiplica por 8 (pra pegar o valor correto)
		la t0,NOTAS_NIVEL1
		add t0,t0,t1 # chega na posicao da nota atual
		lw t1,4(t0) # carrega duracao
		ble s0,t1,FIM_AMBIENT_SOUND # se nota atual nao tiver acabado, apenas retorna
		# se ja tiver acabado, atualiza o timer, contador e reproduz nova nota
		# verifica se ja chegou no fim das notas
		la t0,ambient_sound_counter
		lb t1,0(t0)
		li t2,5
		bge t1,t2,RESET_ASCOUNTERF1
		CONT_ASCOUNTERF1:
		addi t1,t1,1
		sb t1,0(t0) # salva novo valor do contador
		slli t1,t1,3 # mul 8
		la t0,NOTAS_NIVEL1
		add t0,t0,t1 # pula pro end correto
		lw a0,0(t0) # carrega nota
		lw a1,4(t0) # carrega duracao
		li a2,80
		li a3,50 # volume
		li a7,31
		ecall
		la t0,ambient_sound_counter
		lb t1,0(t0)
		beqz t1,DELAY_SOUNDF1 # se tiver na primeira nota, faz a pausa
		la t0,ambient_sound_timer
		gettime()
		sw a0,0(t0)
		j FIM_AMBIENT_SOUND
		
	AMBIENT_SOUND_F3:
		la t0,ambient_sound_counter
		lb t1,0(t0) # carrega contador
		slli t1,t1,3 # multiplica por 8 (pra pegar o valor correto)
		la t0,NOTAS_NIVEL3
		add t0,t0,t1 # chega na posicao da nota atual
		lw t1,4(t0) # carrega duracao
		ble s0,t1,FIM_AMBIENT_SOUND # se nota atual nao tiver acabado, apenas retorna
		# se ja tiver acabado, atualiza o timer, contador e reproduz nova nota
		# verifica se ja chegou no fim das notas
		la t0,ambient_sound_counter
		lb t1,0(t0)
		li t2,2
		bge t1,t2,RESET_ASCOUNTERF3
		CONT_ASCOUNTERF3:
		addi t1,t1,1
		sb t1,0(t0) # salva novo valor do contador
		slli t1,t1,3 # mul 8
		la t0,NOTAS_NIVEL3
		add t0,t0,t1 # pula pro end correto
		lw a0,0(t0) # carrega nota
		lw a1,4(t0) # carrega duracao
		li a2,80
		li a3,50 # volume
		li a7,31
		ecall
		la t0,ambient_sound_counter
		lb t1,0(t0)
		beqz t1,DELAY_SOUNDF3 # se tiver na ultima nota, faz a pausa
		la t0,ambient_sound_timer
		gettime()
		sw a0,0(t0)
		j FIM_AMBIENT_SOUND
	
	DELAY_SOUNDF1: # faz o atraso de 300ms da primeira nota do som da fase1
		la t0,ambient_sound_timer
		gettime()
		addi a0,a0,300
		sw a0,0(t0)
		j FIM_AMBIENT_SOUND
		
	DELAY_SOUNDF3: # faz o atraso de 300ms da primeira nota do som da fase1
		la t0,ambient_sound_timer
		gettime()
		addi a0,a0,200
		sw a0,0(t0)
		j FIM_AMBIENT_SOUND
		
	RESET_ASCOUNTERF1:
		addi t1,zero,-1
		j CONT_ASCOUNTERF3
		
	RESET_ASCOUNTERF3:
		addi t1,zero,-1
		j CONT_ASCOUNTERF3
		
	FIM_AMBIENT_SOUND:
		ret

# Faz as verificacoes de vitoria nas fases
CHECK_VICTORY:
	la t0,fase
	lb t1,0(t0)
	li t0,3
	beq t0,t1,CHECK_VICTORY_F1
	# Verifica posicao de vitoria nas fases 1 e 2
	CHECK_VICTORY_F0:
		save_stack(ra)
		mario_mappos(a0)
		free_stack(ra)
		lb t0,0(a0) # carrega byte de t0
		andi t0,t0,0x80
		bnez t0,GAME_VICTORY # verifica se esta na posicao de vitoria
		lb t0,0(a0)
		li t1,0x03
		beq t0,t1,GOTO_MARIO_DEATH # se mario estiver em posicao de morte, morre
		j FIM_CHECK_VICTORY
	# Verifica posicao de vitoria na fase 3
	CHECK_VICTORY_F1:
		la t0,fase3_given_blocks
		lb t1,0(t0)
		li t0,0xffffffff
		beq t0,t1,GAME_VICTORY # se completou todos os pedacos, vitoria
		
	FIM_CHECK_VICTORY:
		ret
# Imprime tela de vitoria (temporaria)
# Passa para proxima fase
GAME_VICTORY:
	la t0,fase
	lb t1,0(t0)
	li t0,3
	beq t0,t1,GAME_VICTORY_SKIPSOUND
	# toca som de vitoria
	call SOUND_CLEARSTAGE
	GAME_VICTORY_SKIPSOUND:
	# Adiciona bonus ao score
	la t0,bonus
	lw t1,0(t0) # carrega bonus atual
	la t0,score
	lw t2,0(t0) # carrega score atual
	add t1,t1,t2 # soma scora atual + bonus
	sw t1,0(t0) # adiciona ao score

	la t0,fase
	lb t1,0(t0) # carrega fase atual
	li t0,1
	beq t0,t1,INIT_FASE3
	li t0,2
	beq t0,t1,INIT_FASE3
	li t0,3
	beq t0,t1,NEXT_LVL # se estava na fase 3, passa para o prox lvl e volta p/ fase 1
	
	# se nenhum dos casos, apenas finaliza
	j FIM
	
# Passa para o proximo lvl
NEXT_LVL:
	# Como so passa de lvl apos a animacao da fase 3, chama ela aqui
	call F3_WIN_ANIM
	la t0,level
	lb t1,0(t0)
	addi t1,t1,1
	sb t1,0(t0) # salva prox lvl
	j INIT_FASE1 # volta p/ fase 1
	
# Imprime tela de carregando
LOADING_SCR:
	save_stack(ra)
	call BLACK_BLOCK_SCR
	la a0,loading_text
	li a1,130
	li a2,115
	li a3,0x00ff
	li a4,0
	li a7,104
	ecall
	free_stack(ra)
	ret
	
# Imprime a tela de game over e volta para o menu
# falta adaptar para display frames (!)
GAME_OVER:
	call BLACK_BLOCK_SCR
	# Imprime texto de game over
	la a0,gameover_text
	li a1,130
	li a2,115
	li a3,0x00ff
	li a4,0
	li a7,104
	ecall
	j FIM
	
FIM:
	li a7,10
	ecall
	
# calls pra outras funcoes por causa dos 12bit
BCALL_MV_MARIO_DIREITA:
	call MOVE_MARIO_DIREITA
	j MAINLOOP_RET
BCALL_MV_MARIO_ESQUERDA:
	call MOVE_MARIO_ESQUERDA
	j MAINLOOP_RET
BCALL_MV_MARIO_CIMA:
	tail MOVE_MARIO_CIMA
BCALL_MV_MARIO_BAIXO:
	tail MOVE_MARIO_BAIXO
BCALL_MV_MARIO_PULO:	
	tail MARIO_PULO_UP
BCALL_MV_MARIO_PULO_DIR:
	tail MARIO_PULO_DIR
BCALL_MV_MARIO_PULO_ESQ:
	tail MARIO_PULO_ESQ

# continua movimentos do contador	
CONTINUE_MOVEMENT:
	save_stack(ra)
	la t0,mario_state
	lb t1,0(t0)
	andi t2,t1,0x02
	beqz t2,FIM_CONTINUE_MOVEMENT # se nao ta andando, sai
	andi t2,t1,0x01
	bnez t2,FIM_CONTINUE_MOVEMENT # se ta pulando, sai
	
	andi t1,t1,0x04
	beqz t1,CONTINUE_MOVEMENT_DIR
	CONTINUE_MOVEMENT_ESQ:
		call MVME_P0
		j FIM_CONTINUE_MOVEMENT
	CONTINUE_MOVEMENT_DIR:
		call MVMD_P0
	FIM_CONTINUE_MOVEMENT:	
		free_stack(ra)
		ret
 
GOTO_MARIO_DEATH:
	tail MARIO_DEATH

.include "common.s"
.include "mario.s"
.include "environment.s"
.include "fases/fase3_mechanics.s"
.include "map_includes.s"
.include "SYSTEMv14.s"
