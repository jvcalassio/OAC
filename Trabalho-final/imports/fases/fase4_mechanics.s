#####################################################
# Responsavel por gerenciar as mecanicas da fase 4: #
# - Teleportes				    	    #
#####################################################
.data

.text

# Verifica posicoes e faz teleporte na posicao correta
F4_TELEPORT:
	save_stack(ra)
	la t0,fase
	lb t1,0(t0)
	li t0,4
	bne t0,t1,FIM_F4_TELEPORT # se nao estiver na fase 4, nao faz nada

	la t0,pos_mario
	lh t1,2(t0) # y do mario
	li t0,199
	bge t1,t0,F4TP_VERIF_LV1 # se x >= 199, verifica lvl 2 p/ tp
	li t0,182
	#bge t1,t0,F4TP_VERIF_LV2 # se x >= 182, verifica lvl 2 p/ tp
	li t0,70
	bge t1,t0,F4TP_VERIF_LV8 # se x >= 70, verifica lv 8
	j FIM_F4_TELEPORT
	
	F4TP_VERIF_LV1:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,51 # x < 51 ? tem q dar 0
		slti t1,t1,70 # x < 70 ? tem q dar 1
		add t0,t0,t1 # soma as duas
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X do primeiro tp, nao faz nada
		li a0,1
		j F4_MARIO_TP
		
	F4TP_VERIF_LV8:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,81 # x < 81 ? tem q dar 0
		slti t1,t1,100 # x < 100 ? tem q dar 1
		add t0,t0,t1 # soma as condicoes
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X do tp1lv8, nao faz nada
		li a0,0
		j F4_MARIO_TP
	
		
	
	FIM_F4_TELEPORT:
		free_stack(ra)
		ret
		

# faz o teleporte do mario para uma base especifica
# a0 = base destino
F4_MARIO_TP:
	beqz a0,SET_F4MTP_B0
	li t0,1
	beq t0,a0,SET_F4MTP_B1
	j FIM_F4_TELEPORT
	
	SET_F4MTP_B0: # teleport base 0
		rmv_mario(mario_parado)
		li a0,54
		li a1,200
		j PRINT_F4MTP
		
	SET_F4MTP_B1: # teleport base 1
		rmv_mario(mario_parado)
		li a0,83 # x
		li a1,71 # y
		j PRINT_F4MTP
		
	PRINT_F4MTP:
		la t0,pos_mario
		sh a0,0(t0)
		sh a1,2(t0)
		la a2,display
		lw a2,0(a2) # display
		la a3,mario_parado
		call PRINT_OBJ
		j FIM_F4_TELEPORT
		
	
	

