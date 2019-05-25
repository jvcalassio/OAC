.include "macros.s"
.include "fases/fase1_obj.s"

.data

.include "../sprites/bin/fase1.s"
display: .word DISPLAY0,DISPLAY1 # endereco do display utilizado no momento
fase: .space 4 # endereco da fase atual

espaco: .string " "
barran: .string "\n"

.text
	jal PRINT_FASE1
	call INIT_MARIO
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
	call KEYBIND
	beqz a0,SEMKEY # se nenhuma tecla, faz nada
		call PRINT_ACT_POS
		li t0,109
		beq a0,t0,FIM # se tecla == M, sair
		
		li t0,100 # D = direita
		beq a0,t0,MOVE_MARIO_DIREITA
	
		li t0,97 # A = esquerda
		beq a0,t0,MOVE_MARIO_ESQUERDA
	
		li t0,32 # espaco = pulo
		beq a0,t0,MARIO_PULO_UP
		
		li t0,119 # W = cima
		beq a0,t0,MOVE_MARIO_CIMA
		
		li t0,115 # S = baixo
		beq a0,t0,MOVE_MARIO_BAIXO
		
		li t0,101 # E = pulo dir
		beq a0,t0,MARIO_PULO_DIR
		
		li t0,113 # Q = pulo esq
		beq a0,t0,MARIO_PULO_ESQ
		
	SEMKEY: j MAINLOOP
	MPUP: tail MARIO_PULO_UP
	MPDIR: tail MARIO_PULO_DIR
	MPESQ: tail MARIO_PULO_ESQ

FIM:
	li a7,10
	ecall
	
.include "common.s"
.include "mario.s"
