.data
.include "../../sprites/bin/fase3_golden_block.s"
fase3_given_blocks: .byte 0 # blocos removidos
fase3_black_block: .word 8, 7 # bloco preto
	     .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,199
fase3_passingthru: .byte 0 # flag p/ passagem no bloco
.text

# Verifica se o jogador esta na posicao de um bloco dourado da fase 3
F3_CHECK_BLOCK:
	save_stack(ra)
	la t0,fase
	lb t1,0(t0)
	li t0,3
	bne t0,t1,FIM_F3_CHECK_BLOCK # se nao for fase 3, nao faz nada
	la t0,pos_mario
	lh t1,2(t0) # Y do mario
	li t2,190
	bgt t1,t2,FIM_F3_CHECK_BLOCK # nivel terro, faz nada
	li t2,150
	bgt t1,t2,F3CB_LVL1 # se y <= 190 && y > 150, esta no primeiro nivel
	#li t2,110
	#bgt t1,t2,F3CB_LVL2 # se y <= 150 && y > 110, esta no segundo nivel
	#li t2,70
	#bgt t1,t2,F3CB_LVL3 # se y <= 110 && y > 70, esta no terceiro nivel
	#bgtz t1,F3CB_LV4 # se y <= 70, esta no quarto nivel
	j FIM_F3_CHECK_BLOCK # nenhum deles, apenas sai
	
	# Em cada nivel, verifica X para setar flag ou remover bloco
	# col 1 = right 100, left 92
	F3CB_LVL1:
		la t0,fase3_passingthru
		lb t1,0(t0) # verifica se esta passando por um degrau
		beqz t1,F3_CHECK_HOTPOS_L1 # se nao estiver passando, procura setar um passando caso tenha
		# se estiver passando, e for rtl ou ltr, procura onde fechar p/ finalizar e tirar bloco
		li t0,1
		beq t0,t1,F3_CHECKL1_RTL
		li t0,2
		beq t0,t1,F3_CHECKL1_LTR
		j FIM_F3_CHECK_BLOCK
		F3_CHECK_HOTPOS_L1:
			la t0,pos_mario
			lh t1,0(t0) # X do mario
			slti t0,t1,100
			slti t2,t1,110
			add t0,t0,t2
			li t2,1
			beq t0,t2,F3_SET_RTL # 100 ao 110
			slti t0,t1,86
			slti t2,t1,92
			add t0,t0,t2
			li t2,1
			beq t0,t2,F3_SET_LTR # 86 ao 92
			slti t0,t1,220
			slti t2,t1,230
			add t0,t0,t2
			li t2,1
			beq t0,t2,F3_SET_RTL # 220 ao 230
			slti t0,t1,206
			slti t2,t1,212
			add t0,t0,t2
			li t2,1
			beq t0,t2,F3_SET_LTR # 206 ao 212
			# se nenhum, so sai
			j FIM_F3_CHECK_BLOCK
		# verifica posicao da direita p/ esquerda
		F3_CHECKL1_RTL:
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			li t0,80
			beq t0,t1,BLOCK7_REMOVE
			#blt t1,t0,F3_RESET_PS
			li t0,202
			beq t0,t1,BLOCK8_REMOVE
			slti t2,t1,111
			slti t0,t1,202
			add t0,t0,t2
			li t2,1
			beq t0,t2,F3_RESET_PS
			j FIM_F3_CHECK_BLOCK
		F3_CHECKL1_LTR:
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			li t0,100
			beq t0,t1,BLOCK7_REMOVE
			slti t0,t1,111
			slti t2,t1,211
			add t0,t0,t2
			li t2,1
			#bgt t1,t0,F3_RESET_PS
			beq t2,t0,F3_RESET_PS
			li t0,220
			beq t0,t1,BLOCK8_REMOVE
			j FIM_F3_CHECK_BLOCK
			
		
	BLOCK7_REMOVE:
		li a0,6
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		la t0,fase3_passingthru
		sb zero,0(t0)
		j FIM_F3_CHECK_BLOCK
		
	BLOCK8_REMOVE:
		li a0,7
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		la t0,fase3_passingthru
		sb zero,0(t0)
		j FIM_F3_CHECK_BLOCK
		
	# seta right to left
	F3_SET_RTL:
		la t0,fase3_passingthru
		li t1,1
		sb t1,0(t0)
		j FIM_F3_CHECK_BLOCK
	# seta left to right
	F3_SET_LTR:
		la t0,fase3_passingthru
		li t1,2
		sb t1,0(t0)
		j FIM_F3_CHECK_BLOCK
	# reseta passingthru
	F3_RESET_PS:
		la t0,fase3_passingthru
		lb t1,0(t0)
		beqz t1,FIM_F3_CHECK_BLOCK
		sb zero,0(t0)
		j FIM_F3_CHECK_BLOCK
		
	# a0 = bloco desejado (0, 1, 2, 3, 4, 5, 6, 7)
	VERIF_GIVEN_BLOCK:
		li t0,0x01
		sll a0,t0,a0 # escolhe qual o bloco
		la t1,fase3_given_blocks
		lb t2,0(t1) # carrega blocos
		and t0,t2,a0 # verifica se o bloco ja foi
		beqz t0,GIVE_POINTS_CLEAR_BLOCK # se nao foi, da os pontos e seta bit 1
		# se ja foi, nao faz nada
		j FIM_F3_CHECK_BLOCK
	
	# da os 100 pontos e limpa dado bloco da tela (vindo de a0, ja shiftado)
	# seta o bit do bloco em 1
	GIVE_POINTS_CLEAR_BLOCK:
		la t0,fase3_given_blocks
		lb t1,0(t0)
		or t1,t1,a0 # adiciona bit
		sb t1,0(t0)
		la t0,score
		lw t1,0(t0)
		addi t1,t1,100
		sw t1,0(t0) # adiciona +100 no score
		ret # retorna pra funcao COLxLVLy
	
	
	FIM_F3_CHECK_BLOCK:
		free_stack(ra)
		ret
		
# Adiciona os blocos dourados no comeco da fase 3
F3_ADD_BLOCKS:
	save_stack(ra)
	# primeira coluna
	li a0,96
	li a1,184
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	li a0,96
	li a1,144
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	li a0,96
	li a1,104
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	li a0,96
	li a1,64
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	
	# segunda coluna
	li a0,216
	li a1,184
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	li a0,216
	li a1,144
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	li a0,216
	li a1,104
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	li a0,216
	li a1,64
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	
	la t0,fase3_given_blocks
	sb zero,0(t0) # reseta contador de golden blocks
	free_stack(ra)
	ret
# Remove um bloco dourado da fase 3
# a0 = bloco
F3_CLEAR_BLOCK:
	save_stack(ra)
	li t0,1
	beq a0,t0,F3_CLEAR_BLOCK_1
	li t0,2
	beq a0,t0,F3_CLEAR_BLOCK_2
	li t0,4
	beq a0,t0,F3_CLEAR_BLOCK_3
	li t0,8
	beq a0,t0,F3_CLEAR_BLOCK_4
	li t0,16
	beq a0,t0,F3_CLEAR_BLOCK_5
	li t0,32
	beq a0,t0,F3_CLEAR_BLOCK_6
	li t0,64
	beq a0,t0,F3_CLEAR_BLOCK_7
	li t0,0x80
	beq a0,t0,F3_CLEAR_BLOCK_8
	j FIM_F3_CLEAR_BLOCK
	
	F3_CLEAR_BLOCK_1:
		li a0,96
		li a1,64
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,96
		li a1,64
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
	
	F3_CLEAR_BLOCK_2:
		li a0,216
		li a1,64
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,216
		li a1,64
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
		
	F3_CLEAR_BLOCK_3:
		li a0,96
		li a1,104
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,96
		li a1,104
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
		
	F3_CLEAR_BLOCK_4:
		li a0,216
		li a1,104
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,216
		li a1,104
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
		
	F3_CLEAR_BLOCK_5:
		li a0,96
		li a1,144
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,96
		li a1,144
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
		
	F3_CLEAR_BLOCK_6:
		li a0,216
		li a1,144
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,216
		li a1,144
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
		
	F3_CLEAR_BLOCK_7:
		li a0,96
		li a1,184
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,96
		li a1,184
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
		j FIM_F3_CLEAR_BLOCK
		
	F3_CLEAR_BLOCK_8:
		li a0,216
		li a1,184
		la a2,display
		lw a2,0(a2)
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no display
		li a0,216
		li a1,184
		la a2,fase_current
		la a3,fase3_black_block
		call PRINT_OBJ # limpa no sprite da fase, caso o mario passe por cima
	
	FIM_F3_CLEAR_BLOCK:
		free_stack(ra)
		ret
