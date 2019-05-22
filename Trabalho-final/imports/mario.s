#################################################
# Responsavel por gerenciar movimentos do Mario
#################################################
.include "macros.s"

.data
.include "../sprites/bin/fase1.s"
.include "../sprites/bin/mario_parado.s"
.include "../sprites/bin/mario_andando_p1.s"
.include "../sprites/bin/mario_andando_p2.s"
.include "../sprites/bin/mario_andando_p3.s"
.include "../sprites/bin/mario_pulando.s"
.include "../sprites/bin/mario_pulando_queda.s" 
display: .word 0xff000000
# Estados do mario
# 0 = parado
# 1 = p1-direita
# 2 = p2-direita
# 3 = p3-direita
# 4 = pulo incompleto subida
# 5 = pulo completo
# 6 = pulo incompleto descida
mario_state: .byte 0
pos_mario: .half 84,200 # (x,y)
.text
	jal PRINT_BG
	j INITGM
	
PRINT_BG:
	# printa fundo
	la t0,display
	lw s0,0(t0)
	li t0,76800
	la s1,fase1
	addi s1,s1,8
	FORF:
		beqz t0,FIMFORF
		lb t2,0(s1)
		sb t2,0(s0)
		addi s0,s0,1
		addi s1,s1,1
		addi t0,t0,-1
		j FORF
	FIMFORF:
		ret
	
		
# Apos printar o fundo, inicia o jogo
# Printa o mario na posicao inicial
# Continua para game loop
INITGM:
	la t0,pos_mario
	lh a0,0(t0)
	lh a1,2(t0)
	la t0,display
	lw a2,0(t0)
	la a3,mario_parado
	jal PRINT_OBJ

# anotacao temporaria das teclas
# tecla 109 = M (sair)
# tecla 100 = D
# tecla 97 = A
# tecla 32 = espaco
# fim anotacao temporaria

MAINLOOP: # loop de jogo, verificar se tecla esta pressionada
	jal KEYBIND
	beqz a0,SEMKEY # se nenhuma tecla, faz nada
		li t0,109
		beq a0,t0,FIM # se tecla == M, sair
	
		li t0,100
		beq a0,t0,MOVE_MARIO_DIREITA
	
		li t0,97
		beq a0,t0,MOVE_MARIO_ESQUERDA
	
		li t0,32
		beq a0,t0,MARIO_PULO_UP
	SEMKEY:
		j MAINLOOP

# Faz o movimento do mario para a direita
MOVE_MARIO_DIREITA:
	save_stack(a0)
	la t0,mario_state
	lb t0,0(t0)
	
	MVMD_P1: # faz passo 1
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la a3,fase1
		la a4,mario_parado
		jal CLEAR_OBJPOS # imprime mapa na pos do mario
		
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
		la a3,fase1
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
		la a3,fase1
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
		la a3,fase1
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
		free_stack(a0) # devolve valor de a0
		j MAINLOOP
	
MOVE_MARIO_ESQUERDA:
	save_stack(a0)
	la t0,mario_state
	lb t0,0(t0)
	
	MVME_P1: # faz passo 1
		la t0,pos_mario # pega posicao do mario
		lh a0,0(t0)
		lh a1,2(t0)
		
		la a2,display
		lw a2,0(a2)
		la a3,fase1
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
		la a3,fase1
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
		la a3,fase1
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
		la a3,fase1
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
	
	# com isso, o mario se movimentou um total de 4px
	FIM_MVME:
		free_stack(a0) # devolve valor de a0
		j MAINLOOP

MARIO_PULO_UP:

####################
# apenas para testes, excluir daqui pra baixo depois

FIM:
	li a7,10
	ecall
	
.include "common.s"
