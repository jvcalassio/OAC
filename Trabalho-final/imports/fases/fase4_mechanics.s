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
		
# Faz movimento dos foguinhos
MOVE_FOGUINHO1:
	save_stack(ra)
	la t0,fogo1
	lh t1,0(t0) # x fogo 1
	lh t2,2(t0) # y fogo 1
	add t3,t1,t2
	beqz t3,FIM_MOVE_FOGUINHOS # se nao foi inicializado nessa fase, nao faz nada
	
	lh t3,4(t0) # contador horizontal
	lh t4,6(t0) # contador vertical
	
	# esquema do movimento:
	# o foguinho sempre tenta aproximar seu x,y em 0
	# para movimentar 15px pra direita: seta contador horizontal em -15, assim ele vai aproximar a 0, andando 1px
	# o mesmo pra esquerda (seta +15)
	# e o mesmo na vertical
	beqz t3,VERIF_FIRE_FASE_TO_STEP # so verifica vertical se movimento horizontal terminado
	
	VERIF_FIRE_HORIZONTAL:
		slt t5,t3,zero # contador < 0 ? 1 : 0
		# se for maior que 0, precisa decrementar
		beqz t5,VERIF_FIRE_HORIZONTAL_DECREMENT
			# do contrario, incrementa
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo1
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a0,a0,1 # incrementa posicao
			sh a0,0(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,4(t0) # carrega contador horizontal
			addi t2,t2,1 # incrementa contador
			sh t2,4(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_NORMAL
			j PRINT_FIRE_P1_NORMAL
			
		VERIF_FIRE_HORIZONTAL_DECREMENT:
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo1
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a0,a0,-1 # decrementa posicao
			sh a0,0(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,4(t0) # carrega contador horizontal
			addi t2,t2,-1 # decrementa contador
			sh t2,4(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_MIRROR
			j PRINT_FIRE_P1_MIRROR
	
	VERIF_FIRE_VERTICAL:
		la t0,fogo1
		lh t1,0(t0)
		lh t2,2(t0)
		lh t3,4(t0)
		lh t4,6(t0)
		slt t5,t4,zero # contador < 0 ? 1 : 0
		# se for maior que 0, precisa decrementar
		beqz t5,VERIF_FIRE_VERTICAL_DECREMENT
			# do contrario, incrementa
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo1
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a1,a1,1 # incrementa posicao
			sh a1,2(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,6(t0) # carrega contador vertical
			addi t2,t2,1 # incrementa contador
			sh t2,6(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_NORMAL
			j PRINT_FIRE_P1_NORMAL
			
		VERIF_FIRE_VERTICAL_DECREMENT:
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo1
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a1,a1,-1 # decrementa posicao
			sh a1,2(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,6(t0) # carrega contador vertical
			addi t2,t2,-1 # decrementa contador
			sh t2,6(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_MIRROR
			j PRINT_FIRE_P1_MIRROR
	
	VERIF_FIRE_FASE_TO_STEP:
		bnez t4,VERIF_FIRE_VERTICAL
	
		la t0,fase
		lb t1,0(t0)
		li t0,2
		beq t1,t0,VERIF_FIRE_STEP_F2
		li t0,4
		beq t1,t0,VERIF_FIRE_STEP_F4
		j FIM_MOVE_FOGUINHOS
		
	VERIF_FIRE_STEP_F2:
		la t0,fogo1
		lh t1,10(t0)
		beqz t1,VERIF_FIRE_STEP_F2_S1
		li t0,1
		beq t1,t0,VERIF_FIRE_STEP_F2_S2
		li t0,2
		beq t1,t0,VERIF_FIRE_STEP_F2_S3
		li t0,3
		beq t1,t0,VERIF_FIRE_STEP_F2_S4
		j FIM_MOVE_FOGUINHOS
		
		VERIF_FIRE_STEP_F2_S1:
			la t0,fogo1
			li t1,-16
			sh t1,4(t0) # 16 pixels horizontal
			li t1,0
			sh t1,6(t0) # -64 vertical
			li t1,1
			sh t1,10(t0)
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F2_S2:
			la t0,fogo1
			li t1,20
			sh t1,4(t0) # 16 pixels horizontal
			li t1,0
			sh t1,6(t0) # -64 vertical
			li t1,2
			sh t1,10(t0)
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F2_S3:
			la t0,fogo1
			li t1,-20
			sh t1,4(t0) # 16 pixels horizontal
			li t1,-64
			sh t1,6(t0) # -64 vertical
			li t1,3
			sh t1,10(t0)
			j FIM_MOVE_FOGUINHOS
		
		VERIF_FIRE_STEP_F2_S4:
			la t0,fogo1
			li t1,16
			sh t1,4(t0) # 16 pixels horizontal
			li t1,64
			sh t1,6(t0) # -64 vertical
			li t1,0
			sh t1,10(t0)
			j FIM_MOVE_FOGUINHOS
		
	VERIF_FIRE_STEP_F4:
		la t0,fogo1
		lh t1,10(t0) # carrega passo atual do fogo 1
		beqz t1,VERIF_FIRE_STEP_F4_S1
		li t0,1
		beq t1,t0,VERIF_FIRE_STEP_F4_S2
		li t0,2
		beq t1,t0,VERIF_FIRE_STEP_F4_S3
		li t0,3
		beq t1,t0,VERIF_FIRE_STEP_F4_S4
		li t0,4
		beq t1,t0,VERIF_FIRE_STEP_F4_S5
		li t0,5
		beq t1,t0,VERIF_FIRE_STEP_F4_S6
		j FIM_MOVE_FOGUINHOS
		
		VERIF_FIRE_STEP_F4_S1:
			la t0,fogo1
			li t1,20
			sh t1,4(t0) # 20 pixels horizontal
			li t1,42
			sh t1,6(t0) # 42 pixels vertical
			li t1,1
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F4_S2:
			la t0,fogo1
			li t1,-16
			sh t1,4(t0) # -16 pixels horizontal
			sh zero,6(t0) # 0 pixels vertical
			li t1,2
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F4_S3:
			la t0,fogo1
			li t1,16
			sh t1,4(t0) # 16 pixels horizontal
			li t1,-42
			sh t1,6(t0) # -42 pixels vertical
			li t1,3
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F4_S4:
			la t0,fogo1
			li t1,-20
			sh t1,4(t0) # -20 pixels horizontal
			li t1,-42
			sh t1,6(t0) # -42 pixels vertical
			li t1,4
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F4_S5: # seta o step 1
			la t0,fogo1
			li t1,35
			sh t1,4(t0) # 35 pixels horizontal
			sh zero,6(t0) # 0 pixels vertical
			li t1,5
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE_STEP_F4_S6: # seta o step 1
			la t0,fogo1
			li t1,-35
			sh t1,4(t0) # -35 pixels horizontal
			li t1,42
			sh t1,6(t0) # 42 pixels vertical
			li t1,0
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS

# Faz movimento do segundo foguinho
MOVE_FOGUINHO2:
	save_stack(ra)
	la t0,fogo2
	lh t1,0(t0) # x fogo 1
	lh t2,2(t0) # y fogo 1
	add t3,t1,t2
	beqz t3,FIM_MOVE_FOGUINHOS # se nao foi inicializado nessa fase, nao faz nada
	
	lh t3,4(t0) # contador horizontal
	lh t4,6(t0) # contador vertical
	
	# esquema do movimento:
	# o foguinho sempre tenta aproximar seu x,y em 0
	# para movimentar 15px pra direita: seta contador horizontal em -15, assim ele vai aproximar a 0, andando 1px
	# o mesmo pra esquerda (seta +15)
	# e o mesmo na vertical
	beqz t3,VERIF_FIRE2_FASE_TO_STEP # so verifica vertical se movimento horizontal terminado
	
	VERIF_FIRE2_HORIZONTAL:
		slt t5,t3,zero # contador < 0 ? 1 : 0
		# se for maior que 0, precisa decrementar
		beqz t5,VERIF_FIRE2_HORIZONTAL_DECREMENT
			# do contrario, incrementa
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo2
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a0,a0,1 # incrementa posicao
			sh a0,0(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,4(t0) # carrega contador horizontal
			addi t2,t2,1 # incrementa contador
			sh t2,4(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_NORMAL
			j PRINT_FIRE_P1_NORMAL
			
		VERIF_FIRE2_HORIZONTAL_DECREMENT:
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo2
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a0,a0,-1 # decrementa posicao
			sh a0,0(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,4(t0) # carrega contador horizontal
			addi t2,t2,-1 # decrementa contador
			sh t2,4(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_MIRROR
			j PRINT_FIRE_P1_MIRROR
	
	VERIF_FIRE2_VERTICAL:
		la t0,fogo2
		lh t1,0(t0)
		lh t2,2(t0)
		lh t3,4(t0)
		lh t4,6(t0)
		slt t5,t4,zero # contador < 0 ? 1 : 0
		# se for maior que 0, precisa decrementar
		beqz t5,VERIF_FIRE2_VERTICAL_DECREMENT
			# do contrario, incrementa
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo2
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a1,a1,1 # incrementa posicao
			sh a1,2(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,6(t0) # carrega contador vertical
			addi t2,t2,1 # incrementa contador
			sh t2,6(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_NORMAL
			j PRINT_FIRE_P1_NORMAL
			
		VERIF_FIRE2_VERTICAL_DECREMENT:
			mv a0,t1 # y antigo do fogo
			mv a1,t2 # x antigo do fogo
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase_current
			la a4,foguinho_p1
			call CLEAR_OBJPOS # limpa fogo antigo
			
			la t0,fogo2
			lh a0,0(t0) # x do fogo
			lh a1,2(t0) # y do fogo
			addi a1,a1,-1 # decrementa posicao
			sh a1,2(t0)
			la a2,display
			lw a2,0(a2) # display atual
			lh t1,8(t0) # carrega ultimo utilizado
			not t2,t1
			sh t2,8(t0) # salva novo utilizado
			lh t2,6(t0) # carrega contador vertical
			addi t2,t2,-1 # decrementa contador
			sh t2,6(t0) # salva contador
			beqz t1,PRINT_FIRE_P2_MIRROR
			j PRINT_FIRE_P1_MIRROR
	
	VERIF_FIRE2_FASE_TO_STEP:
		bnez t4,VERIF_FIRE2_VERTICAL
	
		la t0,fase
		lb t1,0(t0)
		li t0,2
		beq t1,t0,VERIF_FIRE2_STEP_F2
		li t0,4
		beq t1,t0,VERIF_FIRE2_STEP_F4
		j FIM_MOVE_FOGUINHOS
		
	VERIF_FIRE2_STEP_F2:
		la t0,fogo2
		lh t1,10(t0) # carrega passo atual do fogo 1
		beqz t1,VERIF_FIRE2_STEP_F2_S1
		li t0,1
		beq t1,t0,VERIF_FIRE2_STEP_F2_S2
		li t0,2
		beq t1,t0,VERIF_FIRE2_STEP_F2_S3
		li t0,3
		beq t1,t0,VERIF_FIRE2_STEP_F2_S4
		li t0,4
		beq t1,t0,VERIF_FIRE2_STEP_F2_S5
		li t0,5
		beq t1,t0,VERIF_FIRE2_STEP_F2_S6
		j FIM_MOVE_FOGUINHOS
		
		VERIF_FIRE2_STEP_F2_S1:
			la t0,fogo2
			li t1,-8
			sh t1,4(t0) # -8 pixels horizontal
			sh zero,6(t0) # 0 pixels vertical
			li t1,1
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F2_S2:
			la t0,fogo2
			li t1,8
			sh t1,4(t0) # 8 pixels horizontal
			li t1,-40
			sh t1,6(t0) # -40 pixels vertical
			li t1,2
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F2_S3:
			la t0,fogo2
			li t1,22
			sh t1,4(t0) # 22 pixels horizontal
			li t1,-32
			sh t1,6(t0) # -32 pixels vertical
			li t1,3
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F2_S4:
			la t0,fogo2
			li t1,-4
			sh t1,4(t0) # -4 pixels horizontal
			sh zero,6(t0) # 0 pixels vertical
			li t1,4
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F2_S5:
			la t0,fogo2
			li t1,4
			sh t1,4(t0) # 4 pixels horizontal
			li t1,32
			sh t1,6(t0) # 32 pixels vertical
			li t1,5
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F2_S6:
			la t0,fogo2
			li t1,-22
			sh t1,4(t0) # -22 pixels horizontal
			li t1,40
			sh t1,6(t0) # 40 pixels vertical
			li t1,0
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
		
	VERIF_FIRE2_STEP_F4:
		la t0,fogo2
		lh t1,10(t0) # carrega passo atual do fogo 1
		beqz t1,VERIF_FIRE2_STEP_F4_S1
		li t0,1
		beq t1,t0,VERIF_FIRE2_STEP_F4_S2
		li t0,2
		beq t1,t0,VERIF_FIRE2_STEP_F4_S3
		j FIM_MOVE_FOGUINHOS
		
		VERIF_FIRE2_STEP_F4_S1:
			la t0,fogo2
			li t1,113
			sh t1,4(t0) # 113 pixels horizontal
			sh zero,6(t0) # 0 pixels vertical
			li t1,1
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F4_S2:
			la t0,fogo2
			li t1,-166
			sh t1,4(t0) # -166 pixels horizontal
			li t1,26
			sh t1,6(t0) # 26 pixels vertical
			li t1,2
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
			
		VERIF_FIRE2_STEP_F4_S3:
			la t0,fogo2
			li t1,55
			sh t1,4(t0) # 55 pixels horizontal
			li t1,-26
			sh t1,6(t0) # -26 pixels vertical
			li t1,0
			sh t1,10(t0) # salva passo atual
			j FIM_MOVE_FOGUINHOS
		
PRINT_FIRE_P1_NORMAL:
	la a3,foguinho_p1
	call PRINT_OBJ
	j FIM_MOVE_FOGUINHOS
PRINT_FIRE_P2_NORMAL:
	la a3,foguinho_p2
	call PRINT_OBJ
	j FIM_MOVE_FOGUINHOS
PRINT_FIRE_P1_MIRROR:
	la a3,foguinho_p1
	call PRINT_OBJ_MIRROR
	j FIM_MOVE_FOGUINHOS
PRINT_FIRE_P2_MIRROR:
	la a3,foguinho_p2
	call PRINT_OBJ_MIRROR
	j FIM_MOVE_FOGUINHOS		
FIM_MOVE_FOGUINHOS:
	free_stack(ra)
	ret
