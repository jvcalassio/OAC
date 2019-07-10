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
	bge t1,t0,F4TP_VERIF_LV1 # se x >= 199, verifica lv1 p/ tp
	li t0,150
	bge t1,t0,F4TP_VERIF_LV2 # se x >= 150, verifica lv2 p/ tp
	li t0,130
	bge t1,t0,F4TP_VERIF_LV3 # se x >= 130, verifica lv3 p/ tp
	li t0,110
	bge t1,t0,F4TP_VERIF_LV4 # se x >= 110, verifica lv4 p/ tp
	li t0,70
	bge t1,t0,F4TP_VERIF_LV5 # se x >= 70, verifica lv5
	j FIM_F4_TELEPORT
	
	F4TP_VERIF_LV1:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,51 # x < 51 ? tem q dar 0
		slti t1,t1,66 # x < 66 ? tem q dar 1
		add t0,t0,t1 # soma as duas
		li t1,1
		bne t0,t1,NEXT_F4TP_VERIF_LV1 # se nao estiver no X do tp1lv1, verifica o tp2lv1
		li a0,1 # vai p/ base 1
		j F4_MARIO_TP
		NEXT_F4TP_VERIF_LV1:	la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,120 # x < 122 ? tem q dar 0
		slti t1,t1,137 # x < 137 ? tem q dar 1
		add t0,t0,t1 # soma as duas
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X do tp2lv1, apenas retorna
		li a0,2 # vai p/ base 2
		j F4_MARIO_TP
		
	F4TP_VERIF_LV2:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,30 # x < 32 ? tem q dar 0
		slti t1,t1,47 # x < 44 ? tem q dar 1
		add t0,t0,t1 # soma as duas
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X, apenas retorna
		li a0,5
		j F4_MARIO_TP
		
	F4TP_VERIF_LV3:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,266 # x < 266 ? tem q dar 0
		slti t1,t1,282 # x < 282 ? tem q dar 1
		add t0,t0,t1 # soma as duas
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X, apenas retorna
		li a0,4
		j F4_MARIO_TP
		
	F4TP_VERIF_LV4:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,30 # x < 32 ? tem q dar 0
		slti t1,t1,47 # x < 44 ? tem q dar 1
		add t0,t0,t1 # soma as duas
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X, apenas retorna
		li a0,3
		j F4_MARIO_TP
		
	F4TP_VERIF_LV5:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		slti t0,t1,60 # x < 60 ? tem q dar 0
		slti t1,t1,75 # x < 80 ? tem q dar 1
		add t0,t0,t1 # soma as condicoes
		li t1,1
		bne t0,t1,FIM_F4_TELEPORT # se nao estiver no X do tp1lv8, nao faz nada
		li a0,0 # vai p/ base 0
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
	li t0,2
	beq t0,a0,SET_F4MTP_B2
	li t0,3
	beq t0,a0,SET_F4MTP_B3
	li t0,4
	beq t0,a0,SET_F4MTP_B4
	li t0,5
	beq t0,a0,SET_F4MTP_B5
	j FIM_F4_TELEPORT
	
	SET_F4MTP_B0: # teleport base 0
		rmv_mario(mario_parado)
		li a0,54
		li a1,200
		j PRINT_F4MTP
		
	SET_F4MTP_B1: # teleport base 1
		rmv_mario(mario_parado)
		li a0,64 # x
		li a1,71 # y
		j PRINT_F4MTP
		
	SET_F4MTP_B2: # teleport base 2
		rmv_mario(mario_parado)
		li a0,31 # x
		li a1,113 # y
		j PRINT_F4MTP
		
	SET_F4MTP_B3: # teleport base 3
		rmv_mario(mario_parado)
		li a0,123 # x
		li a1,200 # y
		j PRINT_F4MTP
		
	SET_F4MTP_B4: # teleport base 4
		rmv_mario(mario_parado)
		li a0,31 # x
		li a1,155 # y
		j PRINT_F4MTP
	
	SET_F4MTP_B5: # teleport base 5		
		rmv_mario(mario_parado)
		li a0,271 # x
		li a1,131 # y
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
		

# Manuseia os foguinhos da fase extra
FASE4_START_FOGUINHOS:
	save_stack(ra)
	la t0,fogo1
	li a0,32 # x fogo 1
	li a1,156 # y fogo 1
	sh a0,0(t0)
	sh a1,2(t0) # salva variavel
	la a2,display
	lw a2,0(a2) # display atual
	la a3,foguinho_p1
	call PRINT_OBJ
	la t0,fogo1
	li t1,-35
	sh t1,4(t0) # salva contador horizontal inicial
	li t1,42
	sh t1,6(t0) # salva contador vertical inicial
	
	la t0,fogo2
	li a0,236 # x fogo 1
	li a1,175 # y fogo 1
	sh a0,0(t0)
	sh a1,2(t0) # salva variavel
	la a2,display
	lw a2,0(a2) # display atual
	la a3,foguinho_p1
	call PRINT_OBJ
	la t0,fogo2
	li t1,-26
	sh t1,6(t0) # salva contador vertical inicial
	
	
	FIM_FASE4_FOGUINHOS:
		free_stack(ra)
		ret
