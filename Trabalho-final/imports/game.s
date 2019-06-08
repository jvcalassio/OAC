.include "macros.s"
.include "macros2.s"

.data
.include "fases/fase1_obj.s"
.include "../sprites/bin/fase1.s"
display: .word DISPLAY0,DISPLAY1 # endereco do display utilizado no momento
fase: .space 4 # endereco da fase atual

# string do jogo
victory_text: .string "PARABENS VC VENCEU\n"
gameover_text: .string "GAME OVER\n"
blank: .string " "

vidas: .byte 0 # quantidade de vidas (inicia em 2, mudar apos testes)
last_key: .word 0,0 # ultima tecla pressionada (tecla, tempo)
.text
	M_SetEcall(exceptionHandling)
	jal PRINT_FASE1
	call INIT_MARIO
	call INIT_DK_DANCA
	call INIT_LADY
	j MAINLOOP

# Imprime fase 1 na t ela, e salva no indicador de fase atual
PRINT_FASE1:
	la t0,display
	lw s0,0(t0)
	li s2,DISPLAY1
	la s1,fase1
	la t0,fase
	sw s1,0(t0) # salva o endereco do mapa da fase atual
	addi s1,s1,8 # pula as words que indicam o tamanho da imagem
	li t0,76800 # 320 * 240 pixels, tamanho total da imagem
	FORF:
		beqz t0,FIMFORF
		lb t2,0(s1)
		sb t2,0(s0)
		sb t2,0(s2)
		addi s0,s0,1
		addi s1,s1,1
		addi s2,s2,1
		addi t0,t0,-1
		j FORF
	FIMFORF:
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
		la t0,mario_state
		lb t1,0(t0)
		andi t1,t1,0x02
		bnez t1,MAINLOOP_RET # se ja tiver andando, ignora botao pressionado
		
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
# Na definitiva, passa para prox fase
GAME_VICTORY:
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
	
# Imprime a tela de game over e volta para o menu
GAME_OVER:
	li a0,100 # x do bloco
	li a1,100 # y do bloco
	li a3,DISPLAY0
	call GET_POSITION
	mv s0,a0 # endereco p/ comecar a printar
	li s1,130 # largura
	li s2,35 # altura
	FOR_GAMEOVER:
		beqz s1,FIMF1_GAMEOVER
		sb zero,0(s0) # coloca cor preta na posicao
		addi s1,s1,-1
		addi s0,s0,1
		j FOR_GAMEOVER
		FIMF1_GAMEOVER:
			beqz s2,FIMF2_GAMEOVER
			addi s0,s0,190
			li s1,130
			addi s2,s2,-1
			j FOR_GAMEOVER
			
	FIMF2_GAMEOVER:
		# fim do bloco preto
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
		call MOVE_MARIO_ESQUERDA
		j FIM_CONTINUE_MOVEMENT
	CONTINUE_MOVEMENT_DIR:	
		call MOVE_MARIO_DIREITA
	FIM_CONTINUE_MOVEMENT:	
		free_stack(ra)
		ret

.include "common.s"
.include "mario.s"
.include "environment.s"
.include "SYSTEMv13.s"
