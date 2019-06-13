.include "macros.s"
.include "macros2.s"

.data
.include "fases/fase1_obj.s"

# Variaveis de jogo
display: .word DISPLAY0,DISPLAY1 # endereco do display utilizado no momento
fase_current: .space 76800 # salva fase atual

fase: .byte 1 # primeira fase
level: .byte 1 # primeiro lvl

vidas: .byte 2 # quantidade de vidas (inicia em 2)
highscore: .word 0 # highscore atual
score: .word 0 # score atual
last_key: .word 0,0 # ultima tecla pressionada (tecla, tempo)
bonus_time: .word 0 # ultimo tempo de modificacao do bonus
bonus: .word 0 # bonus inicial da fase
.text
	M_SetEcall(exceptionHandling)
# Inicia o jogo (iniciando as variaveis)
INIT_GAME:
	addi t0,zero,2
	la t1,vidas
	sb t0,0(t1) # reinicia a vida
	la t0,score
	sw zero,0(t0) # reinicia score
	la t0,highscore
	sw zero,0(t0) # reinicia highscore
	la t0,last_key
	sw zero,0(t0)
	sw zero,4(t0) # reinicia last key
	
	li t1,1
	la t0,fase
	sb t1,0(t0) # seta fase1
	la t0,level 
	sb t1,0(t0) # seta lvl1
	
		
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
	j MAINLOOP
	
INIT_FASE2:
	jal LOADING_SCR
	jal SET_FASE2
	jal PRINT_FASE
	call PRINT_TEXT_INITIAL
	call INIT_MARIO
	call INIT_DK_DANCA
	call INIT_LADY
	call INIT_BONUS
	j MAINLOOP

# Imprime fase 1 na tela, e salva no indicador de fase atual
SET_FASE1:
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
		li a0,1
		call MAP_RETRIEVER
		
	FIM_LOADFASE1:
	la t0,fase
	li t1,1
	sb t1,0(t0) # salva fase atual como 1
	ret
		
# Imprime fase 1 na t ela, e salva no indicador de fase atual
SET_FASE2:
	DE1(LOADFASE2_DE1) # se estiver na DE1, carrega o mapa do USB serial
	# do contrario, carregar do endereco no RARS
	la s1,fase_current # endereco do mapa geral
	li t0,76800
	la t1,fase2
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
		li a0,2
		call MAP_RETRIEVER
			
	FIM_LOADFASE2:
	la t0,fase
	li t1,2
	sb t1,0(t0) # salva fase 1
	ret

# Imprime a fase atual	
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
	
	# Modifica valores de variaveis (highscore, bonus)
	call HIGHSCORE_BONUS_MANAGEMENT
	
	# Imprime variaveis de jogo (score, vidas, highscore, bonus)
	call PRINT_TEXT
	
	la t0,pos_mario
	lh t1,0(t0) # x do mario
	lh t2,2(t0) # y do mario
	
	addi t1,t1,16 # +16 para saber posicao do pe direito do mario
	addi t2,t2,16 # +16 --
	srli t1,t1,2 # x / 4 para alinhar com mapeamento
	srli t2,t2,2 # y / 4 para alinhar com mapeamento
	
	la t0,fase1_obj
	li t3,80 # largura
	mul t3,t2,t3 # (y * 80)
	add t3,t3,t1 # (y * 80) + n
	add t0,t0,t3 # endereco da posicao desejada
	lb t0,0(t0) # carrega byte de t0
	andi t0,t0,0x80
	bnez t0,GAME_VICTORY # verifica se esta na posicao de vitoria
	
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
	
		#call PRINT_ACT_POS
		
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
		
	MAINLOOP_RET:
		call DK_DANCA_LOOP
		call LADY_LOOP
		
		li a0,20
		li a7,32
		ecall
		
		j MAINLOOP
	MPUP: tail MARIO_PULO_UP
	MPDIR: tail MARIO_PULO_DIR
	MPESQ: tail MARIO_PULO_ESQ

# Imprime tela de vitoria (temporaria)
# Passa para proxima fase
GAME_VICTORY:
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
	beq t0,t1,INIT_FASE2
	#li t0,2
	#beq t0,t1,INIT_FASE3
	
	
	# se nenhuma das fases, apenas ganha
	la t0,display
	lw s0,0(t0)
	li s2,DISPLAY1
	li t0,76800 # 320 * 240 pixels, tamanho total da imagem
	FORVICTORY: # tela preta
		beqz t0,FIMFORVICTORY
		sb zero,0(s0)
		sb zero,0(s2)
		addi s0,s0,1
		addi s2,s2,1
		addi t0,t0,-1
		j FORVICTORY
	FIMFORVICTORY:
		la a0,victory_text
		li a1,80
		li a2,50
		li a3,0x00ff
		li a4,0
		li a7,104
		ecall
	j FIM
	
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

.include "common.s"
.include "mario.s"
.include "environment.s"
.include "SYSTEMv14.s"
.include "map_includes.s"
