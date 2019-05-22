#################################################
# Responsavel por gerenciar movimentos do Mario
#################################################
.data
.include "../sprites/bin/mario_parado.s"
.include "../sprites/bin/mario_andando_p1.s"
.include "../sprites/bin/mario_andando_p2.s"
.include "../sprites/bin/mario_andando_p3.s"
.include "../sprites/bin/mario_pulando.s"
.include "../sprites/bin/mario_pulando_queda.s" 
# Estados do mario
# 0 = parado
# 1 = p1-direita
# 2 = p2-direita
# 3 = p3-direita
# 4 = pulo incompleto subida
# 5 = pulo completo
# 6 = pulo incompleto descida
mario_state: .byte 0
pos_mario: .half 84,199 # (x,y)
.text

# Printa o Mario na posicao inicial
# Sem argumentos
INIT_MARIO:
	la t0,pos_mario
	lh a0,0(t0)
	lh a1,2(t0)
	la t0,display
	lw a2,0(t0)
	la a3,mario_parado
	save_stack(ra)
	jal PRINT_OBJ
	free_stack(ra)
	ret

# Faz o movimento do mario para a direita
MOVE_MARIO_DIREITA:
	save_stack(a0)
	# colisao com as paredes
	la t0,pos_mario
	lh t0,0(t0) # t0 = x do mario
	addi t0,t0,20
	srli t0,t0,2 # t0 / 4
	la t1,map_positions
	add t1,t1,t0 # endereco do byte da posicao atual
	addi t1,t1,1 # endereco do byte na posicao a direita
	lb t0,0(t1) # pega byte desejado
	li t1,0x01
	beq t0,t1,MVMD_P1 # caso prox byte seja normal, faz movimento
	li t1,0x08
	beq t0,t1,FIM_MVMD # caso prox byte seja parede, faz nada
	# caso seja degrau:
	
	save_stack(ra)
	jal MV_1PXUP
	free_stack(ra)
	
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
	# colisao com as paredes
	la t0,pos_mario
	lh t0,0(t0) # t0 = x do mario
	#addi t0,t0,-20
	srli t0,t0,2 # t0 / 4
	la t1,map_positions
	add t1,t1,t0 # endereco do byte da posicao atual
	addi t1,t1,1 # endereco do byte na posicao a direita
	lb t0,0(t1) # pega byte desejado
	li t1,0x01
	beq t0,t1,MVME_P1 # caso prox byte seja normal, faz movimento
	li t1,0x08
	beq t0,t1,FIM_MVME # caso prox byte seja parede, faz nada
	# caso seja degrau:
	
	save_stack(ra)
	jal MV_1PXDW
	free_stack(ra)
	
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
MOVE_MARIO_CIMA:
	save_stack(ra)
	# verifica escadas
	la t0,pos_mario
	lh t0,0(t0)
	srli t0,t0,2
	la t1,map_ladder
	add t1,t1,t0 # posicao atual do mario
	lb t0,0(t1) # pega byte da posicao pra ver se tem escada
	li t1,0x02
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

MARIO_PULO_UP:
	j MAINLOOP
