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
pos_mario: .half 83,199 # (x,y)
.text
	jal PRINT_BG
	j INITGM
	
PRINT_BG:
	# printa fundo
	la t0,display
	lw s0,0(t0)
	li s2,DISPLAY1
	li t0,76800
	la s1,fase1
	addi s1,s1,8
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
	
		
# fundo printado
INITGM:

la t0,pos_mario
lh a0,0(t0)
lh a1,2(t0)
la t0,display
lw a2,0(t0)
la a3,mario_parado
jal PRINT_OBJ

# tecla 109 = M (sair)
# tecla 100 = D
# tecla 97 = A
# tecla 32 = espaco

MAINLOOP: # loop de jogo, verificar se tecla esta pressionada
	# mudar display
	li t0,DISPLAY0
	la t1,display
	lw t2,0(t1) # carrega conteudo de display
	beq t0,t2,SETDISPLAY1 # se tiver no display 0, muda pra 1
		li t2,DISPLAY0
		sw t2,0(t1)
		li t0,CDISPLAY
		sw zero,0(t0) # muda para frame 0
	SETDISPLAY1:
		li t2,DISPLAY1 # se tiver no display 1, muda pro 0
		sw t2,0(t1)
		li t0,CDISPLAY
		li t1,1
		sw t1,0(t0)
	# fim mudar display

	la t0,mario_state
	lb t0,0(t0)
	bne t0,zero,MARIO_MOVIMENTANDO # se o mario estiver no meio de um movimento, nao deve fazer um novo
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
		
		j MAINLOOP
	
	MARIO_MOVIMENTANDO:
		li t0,100
		beq a0,t0,MOVE_MARIO_DIREITA
	
		li t0,97
		beq a0,t0,MOVE_MARIO_ESQUERDA
	
		li t0,32
		beq a0,t0,MARIO_PULO_UP
	SEMKEY:
		j MAINLOOP

# Faz o movimento do mario para a direita, baseado no mario_state
MOVE_MARIO_DIREITA:
	save_stack(a0)
	#jal PRINT_BG
	la t0,mario_state
	lb t0,0(t0)
	li t1,1
	beq t0,zero,MVMD_P1
	beq t0,t1,MVMD_P2
	li t1,2
	beq t0,t1,MVMD_P3
	li t1,3
	beq t0,t1,MVMD_P0
	
	MVMD_P1: # faz passo 1
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a0,a0,1
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p1
		jal PRINT_OBJ
		
		# modifica mario state
		la t0,mario_state
		li t1,1
		sb t1,0(t0)
		j FIM_MVMD
	
	MVMD_P2: # faz passo 2
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a0,a0,1
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p2
		jal PRINT_OBJ
		
		# modifica mario state
		la t0,mario_state
		li t1,2
		sb t1,0(t0)
		j FIM_MVMD
	
	MVMD_P3: # faz passo 3
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a0,a0,1
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_andando_p3
		jal PRINT_OBJ
		
		# modifica mario state
		la t0,mario_state
		li t1,3
		sb t1,0(t0)
		j FIM_MVMD
	
	MVMD_P0: # faz mario parado
		la t0,pos_mario
		lh a0,0(t0)
		lh a1,2(t0)
		addi a0,a0,1
		sh a0,0(t0)
		la t0,display
		lw a2,0(t0)
		la a3,mario_parado
		
		# modifica mario state
		la t0,mario_state
		li t1,0
		sb t1,0(t0)
		jal PRINT_OBJ
	
	FIM_MVMD:
		free_stack(a0)
		j MAINLOOP
	
MOVE_MARIO_ESQUERDA:

MARIO_PULO_UP:

####################
# apenas para testes, excluir daqui pra baixo depois

FIM:
	li a7,10
	ecall
	
.include "common.s"
