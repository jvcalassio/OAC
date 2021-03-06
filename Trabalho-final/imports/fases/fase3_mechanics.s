#####################################################
# Responsavel por gerenciar as mecanicas da fase 3: #
# - Piso dourado				    #
# - Animacao de vitoria				    #
#####################################################
.data
.include "../../sprites/bin/fase3_golden_block.s"
.include "../../sprites/bin/fase3_blue_block.s"
.include "../../sprites/bin/coracao.s"
.include "../../sprites/bin/dk_5.s"
.include "../../sprites/bin/dk_6.s"
.include "../../sprites/bin/dk_7.s"
.include "../../sprites/bin/foguinho_f3_p1.s"
.include "../../sprites/bin/foguinho_f3_p2.s"
fase3_given_blocks: .byte 0 # blocos removidos
fase3_black_block: .word 8, 7 # bloco preto
	     .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,199
fase3_passingthru: .byte 0 # flag p/ passagem no bloco

foguinho_spawn_counter: .word 0 # tempo de nascimento do ultimo foguinho
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
	li t2,185
	bgt t1,t2,FIM_F3_CHECK_BLOCK # nivel terro, faz nada
	li t2,150
	bgt t1,t2,F3CB_LVL1 # se y <= 190 && y > 150, esta no primeiro nivel
	li t2,110
	bgt t1,t2,F3CB_LVL2 # se y <= 150 && y > 110, esta no segundo nivel
	li t2,70
	bgt t1,t2,F3CB_LVL3 # se y <= 110 && y > 70, esta no terceiro nivel
	bgtz t1,F3CB_LVL4 # se y <= 70, esta no quarto nivel
	j FIM_F3_CHECK_BLOCK # nenhum deles, apenas sai
	
	# Em cada nivel, verifica X para setar flag ou remover bloco
	# col 1 = right 100, left 92
	F3CB_LVL1:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		# verifica primeira coluna
		slti t0,t1,100 # primeira coluna final
		slti t2,t1,84 # primeira coluna inicio
		add t0,t0,t2 # t0 + t2
		# se t0 == 1, esta no meio. se t0 == 0, esta depois. se t0 == 2, esta antes
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com o resultado
		li t2,3 # se resultado da soma for 3 (esta antes e passinthru = 1), remove bloco
		beq t3,t2,BLOCK7_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		slti t2,t1,121
		add t0,t0,t2 # se x >= 104 && x <= 120, t0 = 1
		add t0,t0,t3 # + passingthru
		li t2,2
		beq t0,t2,BLOCK7_REMOVE
		# verifica segunda coluna
		slti t0,t1,220 # segunda coluna final
		slti t2,t1,204 # segunda coluna inicio
		add t0,t0,t2
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com resultado
		li t2,3 # se result for 3, esta antes e pt = 1, remove o bloco
		beq t3,t2,BLOCK8_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		add t3,t3,t0 # passingthru + t0. se t3 = 1, entao mario esta depois do bloco
		li t2,1
		beq t3,t2,BLOCK8_REMOVE
		j FIM_F3_CHECK_BLOCK
		
	F3CB_LVL2:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		# verifica primeira coluna
		slti t0,t1,100 # primeira coluna final
		slti t2,t1,84 # primeira coluna inicio
		add t0,t0,t2 # t0 + t2
		# se t0 == 1, esta no meio. se t0 == 0, esta depois. se t0 == 2, esta antes
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com o resultado
		li t2,3 # se resultado da soma for 3 (esta antes e passinthru = 1), remove bloco
		beq t3,t2,BLOCK5_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		slti t2,t1,121
		add t0,t0,t2 # se x >= 104 && x <= 120, t0 = 1
		add t0,t0,t3 # + passingthru
		li t2,2
		beq t0,t2,BLOCK5_REMOVE
		# verifica segunda coluna
		slti t0,t1,220 # segunda coluna final
		slti t2,t1,204 # segunda coluna inicio
		add t0,t0,t2
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com resultado
		li t2,3 # se result for 3, esta antes e pt = 1, remove o bloco
		beq t3,t2,BLOCK6_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		add t3,t3,t0 # passingthru + t0. se t3 = 1, entao mario esta depois do bloco
		li t2,1
		beq t3,t2,BLOCK6_REMOVE
		j FIM_F3_CHECK_BLOCK
		
	F3CB_LVL3:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		# verifica primeira coluna
		slti t0,t1,100 # primeira coluna final
		slti t2,t1,84 # primeira coluna inicio
		add t0,t0,t2 # t0 + t2
		# se t0 == 1, esta no meio. se t0 == 0, esta depois. se t0 == 2, esta antes
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com o resultado
		li t2,3 # se resultado da soma for 3 (esta antes e passinthru = 1), remove bloco
		beq t3,t2,BLOCK3_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		slti t2,t1,121
		add t0,t0,t2 # se x >= 104 && x <= 120, t0 = 1
		add t0,t0,t3 # + passingthru
		li t2,2
		beq t0,t2,BLOCK3_REMOVE
		# verifica segunda coluna
		slti t0,t1,220 # segunda coluna final
		slti t2,t1,204 # segunda coluna inicio
		add t0,t0,t2
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com resultado
		li t2,3 # se result for 3, esta antes e pt = 1, remove o bloco
		beq t3,t2,BLOCK4_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		add t3,t3,t0 # passingthru + t0. se t3 = 1, entao mario esta depois do bloco
		li t2,1
		beq t3,t2,BLOCK4_REMOVE
		j FIM_F3_CHECK_BLOCK
		
	F3CB_LVL4:
		la t0,pos_mario
		lh t1,0(t0) # x do mario
		# verifica primeira coluna
		slti t0,t1,100 # primeira coluna final
		slti t2,t1,84 # primeira coluna inicio
		add t0,t0,t2 # t0 + t2
		# se t0 == 1, esta no meio. se t0 == 0, esta depois. se t0 == 2, esta antes
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com o resultado
		li t2,3 # se resultado da soma for 3 (esta antes e passinthru = 1), remove bloco
		beq t3,t2,BLOCK1_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		slti t2,t1,121
		add t0,t0,t2 # se x >= 104 && x <= 120, t0 = 1
		add t0,t0,t3 # + passingthru
		li t2,2
		beq t0,t2,BLOCK1_REMOVE
		# verifica segunda coluna
		slti t0,t1,220 # segunda coluna final
		slti t2,t1,204 # segunda coluna inicio
		add t0,t0,t2
		li t2,1
		beq t0,t2,F3_SET_PS
		la t2,fase3_passingthru
		lb t3,0(t2) # carrega passingthru
		add t3,t3,t0 # soma com resultado
		li t2,3 # se result for 3, esta antes e pt = 1, remove o bloco
		beq t3,t2,BLOCK2_REMOVE
		la t2,fase3_passingthru # verificar se passou p/ direita
		lb t3,0(t2)
		add t3,t3,t0 # passingthru + t0. se t3 = 1, entao mario esta depois do bloco
		li t2,1
		beq t3,t2,BLOCK2_REMOVE
		j FIM_F3_CHECK_BLOCK
			
	BLOCK1_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		mv a0,zero
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK2_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,1
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK3_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,2
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK4_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,3
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK5_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,4
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK6_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,5
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK7_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,6
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	BLOCK8_REMOVE:
		la t0,fase3_passingthru
		sb zero,0(t0)
		li a0,7
		jal VERIF_GIVEN_BLOCK
		jal F3_CLEAR_BLOCK
		j FIM_F3_CHECK_BLOCK
		
	# seta passingthru
	F3_SET_PS:
		la t0,fase3_passingthru
		lb t1,0(t0)
		bnez t1,FIM_F3_CHECK_BLOCK
		li t1,1
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
		#la t0,score
		#lw t1,0(t0)
		#addi t1,t1,100
		#sw t1,0(t0) # adiciona +100 no score
		# pontos movidos p/ clearblock
		ret # retorna pra funcao BLOCKxREMOVE
	
	
	FIM_F3_CHECK_BLOCK:
		free_stack(ra)
		ret
		
# Adiciona os blocos dourados no comeco da fase 3
F3_ADD_BLOCKS:
	save_stack(ra)
	# primeira coluna
	la t0,fase3_obj
	li t1,3707
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,96
	li a1,184
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	la t0,fase3_obj
	li t1,2907
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,96
	li a1,144
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	la t0,fase3_obj
	li t1,2107
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,96
	li a1,104
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	la t0,fase3_obj
	li t1,1307
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,96
	li a1,64
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	
	# segunda coluna
	la t0,fase3_obj
	li t1,3736
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,216
	li a1,184
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	la t0,fase3_obj
	li t1,2936
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,216
	li a1,144
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	la t0,fase3_obj
	li t1,2136
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,216
	li a1,104
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	la t0,fase3_obj
	li t1,1336
	add t0,t0,t1 # soma posicao do bloco
	li t1,0x01
	sb t1,0(t0) # salva chao no map
	li a0,216
	li a1,64
	la a2,fase_current
	la a3,fase3_golden_block
	call PRINT_OBJ
	
	la t0,fase3_given_blocks
	sb zero,0(t0) # reseta contador de golden blocks
	la t0,fase3_passingthru
	sb zero,0(t0) # reseta ps
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
		la t0,fase3_obj
		li t1,1307
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva chao no map
		# da os pontos
		li a0,100
		li a1,96
		li a2,64
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,1336
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva chao no map
		li a0,100
		li a1,216
		li a2,64
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,2107
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva chao no map
		li a0,100
		li a1,96
		li a2,104
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,2136
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva gravity no map
		li a0,100
		li a1,216
		li a2,104
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,2907
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva chao no map
		li a0,100
		li a1,96
		li a2,144
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,2936
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva gravity no map
		li a0,100
		li a1,216
		li a2,144
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,3707
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva como gravity no map
		li a0,100
		li a1,96
		li a2,184
		call GIVE_POINTS
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
		la t0,fase3_obj
		li t1,3736
		add t0,t0,t1 # soma posicao do bloco
		li t1,0x02
		sb t1,0(t0) # salva gravity no map
		li a0,100
		li a1,216
		li a2,184
		call GIVE_POINTS
	
	FIM_F3_CLEAR_BLOCK:
		free_stack(ra)
		ret

# Faz a animacao de vitoria na fase 3.
F3_WIN_ANIM:
	save_stack(ra)
	call PRINT_FASE
	li a0,269
	li a1,22
	la t0,display
	lw a2,0(t0)
	call GET_POSITION # pega pos do label do bonus
	li s0,42 # largura
	li s1,19 # altura
	FFWABB_0: # limpa o label de bonus p/ cutscene
		beqz s0,FIM_FFWABB0
		sb zero,0(a0)
		addi a0,a0,1
		addi s0,s0,-1
		j FFWABB_0
		FIM_FFWABB0:
			beqz s1,FIM_FFWABB1
			addi a0,a0,278
			li s0,42
			addi s1,s1,-1
			j FFWABB_0
	FIM_FFWABB1:
	# fazer bloco preto iniciando em (96,25) de 128 de largura e 185 de altura
	li a0,96
	li a1,25
	la t0,display
	lw a2,0(t0) # carrega display atual
	call GET_POSITION
	li s0,128 # largura
	li s1,185 # altura
	FOR_F3_WINANIM_BLACK_BLOCK:
		beqz s0,FIMF1_F3_WINANIM_BLACK_BLOCK
		sb zero,0(a0) # pixel preto na posicao
		addi s0,s0,-1
		addi a0,a0,1
		j FOR_F3_WINANIM_BLACK_BLOCK
		FIMF1_F3_WINANIM_BLACK_BLOCK:
			beqz s1,FIMF2_F3_WINANIM_BLACK_BLOCK
			addi a0,a0,192
			li s0,128
			addi s1,s1,-1
			j FOR_F3_WINANIM_BLACK_BLOCK
			
	FIMF2_F3_WINANIM_BLACK_BLOCK:
		# imprime o chao azul onde o dk cai
		li s0,14 # 14 blocos
		li s1,104 # x inicial = 104
		li s2,208 # y inicial = 209
		li s3,2 # (qtd-1) de fileiras de blue blocks
		FOR_PRINT_BLUE_BLOCK1:
			beqz s0,FOR_PRINT_BLUE_BLOCK2
			mv a0,s1
			mv a1,s2
			la a2,display
			lw a2,0(a2) # display atual
			la a3,fase3_blue_block
			call PRINT_OBJ
			addi s1,s1,8 # posicao pro prox bloco
			addi s0,s0,-1
			j FOR_PRINT_BLUE_BLOCK1
			FOR_PRINT_BLUE_BLOCK2: # printou a fileira? print a proxima
				beqz s3,DK_FALLING_ANIM
				li s0,14
				li s1,104
				addi s2,s2,-8
				addi s3,s3,-1
				j FOR_PRINT_BLUE_BLOCK1
	
	# Apos fundo preto e printar chaos, fazer animacao do DK
	DK_FALLING_ANIM:
		# fazer o dk brabo
		li s0,8 # qtd de transicoes
		li s1,138 # x do dk
		li s2,26 # y do dk
		LOOP_DK_BRABO_ANIM: # faz o dk balancando os bracos
			beqz s0,FIM_LOOP_DK_BRABO_ANIM
			mv a0,s1
			mv a1,s2
			la a2,display
			lw a2,0(a2) # display atual
			la a3,dk_1
			li t0,2
			remu t0,s0,t0 # t0 = s0 mod 2
			beqz t0,DKBRABO_2 # se i par, printa normal. se i impar, printa espelhado
			DKBRABO_1:
			call PRINT_OBJ_MIRROR
			j CONT_DK_BRABO
			DKBRABO_2:
			call PRINT_OBJ
			CONT_DK_BRABO:
			sleep(200)
			mv a0,s1
			mv a1,s2
			la t0,display
			lw a2,0(t0) # display atual
			#lw a3,0(t0) # printar preto
			la a3,fase_current
			la a4,dk_1
			call CLEAR_OBJPOS # remove dk anterior
			addi s0,s0,-1
			j LOOP_DK_BRABO_ANIM
		
		FIM_LOOP_DK_BRABO_ANIM:
			sleep(200)
		# fazer o dk caindo
		li s0,138 # x do dk
		li s1,74 # y do dk (inicialmente)
		FOR_DK_CAINDO:
			li t0,156
			bge s1,t0,FIM_FALLING_ANIM # se chegar na pos final
			# printa dk uma posicao abaixo
			mv a0,s0
			addi a1,s1,0
			la t0,display
			lw a2,0(t0) # display atual
			la a3,dk_7
			call PRINT_OBJ
			# limpa pxs acima dele (na linha superior)
			addi s2,zero,188
			FOR_DK_CAINDO_CLEAR:
				beq s2,s0,FIM_DK_CAINDO_CLEAR
				mv a0,s2
				mv a1,s1
				la t0,display
				lw a2,0(t0)
				call GET_POSITION
				addi s2,s2,-1
				j FOR_DK_CAINDO_CLEAR
				
			FIM_DK_CAINDO_CLEAR:
				#sleep(5)
				addi s1,s1,4
				j FOR_DK_CAINDO
				
	FIM_FALLING_ANIM:
	#sleep(10)
	# Imprimir piso do lv4 completo
	li s0,16 # 16 blocos
	li s1,96 # x inicial
	li s2,64 # y inicial
	FOR_PRINT_BLUE_BLOCK3:
		beqz s0,FIM_FOR_PRINT_BLUE_BLOCK3
		mv a0,s1
		mv a1,s2
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase3_blue_block
		call PRINT_OBJ
		addi s1,s1,8 # posicao pro prox bloco
		addi s0,s0,-1
		j FOR_PRINT_BLUE_BLOCK3
		
	# Apos piso impresso, imprimir mario e lady com coracao
	FIM_FOR_PRINT_BLUE_BLOCK3:
		# imprime lady
		li a0,112 # x
		li a1,41 # y
		la a2,display
		lw a2,0(a2) # display atual
		la a3,lady_p2
		call PRINT_OBJ
		# imprime mario
		li a0,192
		li a1,47
		la a2,display
		lw a2,0(a2) # display atual
		la a3,mario_parado
		call PRINT_OBJ_MIRROR
		# imprime coracao
		li a0,153
		li a1,39
		la a2,display
		lw a2,0(a2) # display atual
		la a3,coracao
		call PRINT_OBJ
		
	# Tocar som de vitoria aqui tananannananan anananana nanananan
	# Fazer animacao dos pes do dk mexendo aqui
	# fazer o dk brabo
	li s0,13 # qtd de transicoes
	li s1,138 # x do dk
	li s2,156 # y do dk
	LOOP_DK_BRABO2_ANIM: # faz o dk balancando as pernas
		beqz s0,FIM_LOOP_DK_BRABO2_ANIM
		mv a0,s1
		mv a1,s2
		la a2,display
		lw a2,0(a2) # display atual
		li t0,2
		remu t0,s0,t0 # t0 = s0 mod 2
		beqz t0,DKBRABO2_2 # se i par, printa dk6. se i impar, printa dk5
		DKBRABO2_1:
		la a3,dk_5
		j CONT_DK_BRABO2
		DKBRABO2_2:
		la a3,dk_6 
		CONT_DK_BRABO2: 
		call PRINT_OBJ
		sleep(200)
		addi s0,s0,-1
		j LOOP_DK_BRABO2_ANIM
	
	FIM_LOOP_DK_BRABO2_ANIM:
		sleep(200)
	
	FIM_F3_WIN_ANIM: # animacao finalizada, sleep (temporario) e retorna
		free_stack(ra)
		ret

# Inicializa contador dos foguinhos da fase 3
FASE3_START_FOGUINHOS:
	save_stack(ra)
	la t0,foguinho_spawn_counter
	lw t0,0(t0)
	gettime()
	sub t1,a0,t0 # tempo atual - tempo do ultimo fogo
	li t2,FASE3_FOGO_TIME # se maior q o tempo definido, spawna novo
	ble t1,t2,FIM_F3_START_FOGUINHOS
	
	# se for maior, verifica qual fogo esta disponivel
	la t0,fogo1
	lh t1,0(t0)
	lh t2,2(t0)
	add t1,t1,t2 # soma x + y
	beqz t1,SPAWN_F3_FOGO1
	la t0,fogo2
	lh t1,0(t0)
	lh t2,2(t0)
	add t1,t1,t2 # soma x + y fogo 2
	beqz t1,SPAWN_F3_FOGO2
	j FIM_F3_START_FOGUINHOS # se nenhum disponivel, nao faz nada
	
	SPAWN_F3_FOGO1:
		la t0,foguinho_spawn_counter
		gettime()
		sw a0,0(t0) # salva contador atual
	
		# faz spawn do primeiro foguinho
		# 239,95
		la t0,fogo1
		li a0,159
		li a1,89
		sh a0,0(t0) # grava x inicial
		sh a1,2(t0) # grava y inicial
		la a2,display
		lw a2,0(a2) # carrega display
		la a3,foguinho_f3_p1
		call PRINT_OBJ
		j FIM_F3_START_FOGUINHOS
		
	SPAWN_F3_FOGO2:
		la t0,foguinho_spawn_counter
		gettime()
		sw a0,0(t0) # salva contador atual
	
		# faz spawn do segundo foguinho
		# 239,95
		la t0,fogo2
		li a0,239
		li a1,89	
		sh a0,0(t0) # grava x inicial
		sh a1,2(t0) # grava y inicial
		la a2,display
		lw a2,0(a2) # carrega display
		la a3,foguinho_f3_p1
		call PRINT_OBJ
	
	
	FIM_F3_START_FOGUINHOS:
		free_stack(ra)
		ret
	
	
# Manuseio dos foguinhos da fase 3
# Esquema dos foguinhos modificado (para reutilizar a variavel) na fase 3
# Cada half word agora significa:
# x, y, contador horizontal, contador vertical, sprite (0 ou 1), status (normal 0, vulneravel 1)
MOVE_FOGUINHO_F3:
	save_stack(ra)
	la t0,fase
	lb t1,0(t0)
	li t0,3
	bne t0,t1,FIM_MOVE_FOGUINHO_F3 # se nao estiver na fase 3, nao faz nada
	# nasce novo foguinho apos os 10s
	call FASE3_START_FOGUINHOS
	
	# movimento do fogo 1
	la t0,fogo1
	lh s0,0(t0) # carrega x
	lh s1,2(t0) # carrega y
	add t1,s0,s1 # soma x + y
	beqz t1,MOV_FOGO2_F3 # se estiver morto, verifica o fogo 2 direto
		# verifica se movimento ja foi terminado
		lh t1,4(t0) # verifica mov horizontal
		bnez t1,FOGUINHO1_F3_REALIZE_MOVEMENT
		lh t1,6(t0) # verifica mov vertical
		bnez t1,FOGUINHO1_F3_REALIZE_MOVEMENT
		# se sim, seta novo valor
		
		addi t0,s0,16 # +16 p/ alinhar com mapeamento
		addi t1,s1,16 # +16 p/ alinhar com mapeamento
		srli t0,t0,2 # x / 4 para manter proporcao
		srli t1,t1,2 # y / 4 para manter proporcao
		
		la t2,fase3_obj # carrega obj
		li t3,80
		mul t3,t3,t1 # y * 80
		add t3,t3,t0 # (y * 80) + x
		add t2,t2,t3 # end inicial somado
		
		lb t1,0(t2) # carrega byte
		lb t3,-80(t2) # carrega byte acima
		
		# precisa agora verificar pra qual direcao vai andar
		# se piso acima = ar (0x00):
			# se piso atual = g (0x02) vai sempre na direcao contraria do G
			# se piso atual = c (0x01) vai pra direcao aleatoria
		# se piso acima = escada (0x04):
			# se piso atual = g (0x02) vai sempre pra cima
			# se piso atual = c (0x01) decide se vai pra cima ou direcao aleatoria
		# verifica piso abaixo depois
		
		beqz t3,FOGO1_F3_AIR # se piso acima for ar
		li t0,0x04
		beq t0,t3,FOGO1_F3_ESCADA # se piso acima for escada
		#j MOV_FOGO2_F3 # se nenhum, considera q eh ar
		
		FOGO1_F3_AIR: # no caso do piso ser ar
			# verifica qual o piso do chao
			li t0,0x01
			beq t0,t1,FOGO1_F3_AIR_CHAO
			li t0,0x02
			beq t0,t1,FOGO1_F3_AIR_GRAV
			#j MOV_FOGO2_F3 # se nenhum, considera grav
			j FOGO1_F3_AIR_GRAV
			
			FOGO1_F3_AIR_CHAO:
				li a7,41
				ecall # gera numero aletorio (pra decidir direcao)
				li t0,2
				remu a0,a0,t0 # numero mod 2
				beqz a0,FOGO1_MOVE_ESQ # vai pra esquerda
				j FOGO1_MOVE_DIR # vai pra direita
				
			FOGO1_F3_AIR_GRAV:
				# verifica se a frente tbm eh gravity
				lb t1,-1(t2) # byte atras
				lb t3,1(t2) # byte a frente
				li t0,0x02
				beq t1,t3,FOGO1_MOVE_DIR # se atras (esq) for gravity, vai pra direita
				j FOGO1_MOVE_ESQ # se a frente (dir) for gravity, vai pra esquerda
				
		FOGO1_F3_ESCADA: # no caso do piso ser escada
			li t0,0x01
			li t0,0x01
			beq t0,t1,FOGO1_F3_ESC_CHAO
			li t0,0x02
			beq t0,t1,FOGO1_F3_AIR_GRAV
			#j MOV_FOGO2_F3 # se nenhum, trava
			j FOGO1_F3_AIR_GRAV # se nenhum, considera grav
			
			FOGO1_F3_ESC_CHAO:
				li a7,41
				ecall # gera numero rand
				li t0,3
				remu a0,a0,t0 # numero mod 3
				beqz a0,FOGO1_MOVE_ESQ # vai pra esquerda
				li t0,1
				beq a0,t0,FOGO1_MOVE_DIR # vai pra direita
				j FOGO1_MOVE_UP
			
		FOGO1_MOVE_ESQ:
			# seta os mov horizontal
			la t0,fogo1
			li t1,-15 # move 5px pra esquerda
			sh t1,4(t0)
			j MOV_FOGO2_F3
			
		FOGO1_MOVE_DIR:
			# seta os mov horizontal
			la t0,fogo1
			li t1,15 # move 5px pra direita
			sh t1,4(t0)
			j MOV_FOGO2_F3
			
		FOGO1_MOVE_UP:
			la t0,fogo1
			li t1,41 # move 5px pra cima
			sh t1,6(t0)
			j MOV_FOGO2_F3
	
	MOV_FOGO2_F3:
	
	FIM_MOVE_FOGUINHO_F3:
		free_stack(ra)
		ret
		
# Realiza os movimentos (como os outros foguinhos)
FOGUINHO1_F3_REALIZE_MOVEMENT:
	la t0,fogo1
	lh t1,4(t0)
	beqz t1,F1F3RM_VERT # terminado movimento horizontal, faz vertical
		# realiza movimento horizontal
		bgtz t1,F1F3RM_DECREASE
			# increase
			la t0,fogo1
			lh a0,0(t0)
			lh a1,2(t0)
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,foguinho_f3_p1
			call CLEAR_OBJPOS # limpa foguinho
		
			la t0,fogo1
			lh a0,0(t0) # carrega x
			lh a1,2(t0) # carrega y
			addi a0,a0,1
			sh a0,0(t0) # salva x
			la a2,display
			lw a2,0(a2) # carrega display
			# decide sprite
			lb t1,8(t0)
			beqz t1,F1F3RM_I_SP1
			la a3,foguinho_f3_p1
			j F1F3RM_I_CONT
			F1F3RM_I_SP1:
			la a3,foguinho_f3_p2
			li t1,1
			sb t1,8(t0) # salva novo sprite utilizado
			F1F3RM_I_CONT:
			lh t1,4(t0) # carrega mov horizontal
			addi t1,t1,1
			sh t1,4(t0) # salva mov horizontal
			call PRINT_OBJ
			j FIM_FOGUINHO1_F3_REALIZE_MOVEMENT
			
		F1F3RM_DECREASE:
			# decrease
			la t0,fogo1
			lh a0,0(t0)
			lh a1,2(t0)
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,foguinho_f3_p1
			call CLEAR_OBJPOS # limpa foguinho
		
			la t0,fogo1
			lh a0,0(t0) # carrega x
			lh a1,2(t0) # carrega y
			addi a0,a0,-1
			sh a0,0(t0) # salva x
			la a2,display
			lw a2,0(a2) # carrega display
			# decide sprite
			lb t1,8(t0)
			beqz t1,F1F3RM_D_SP1
			la a3,foguinho_f3_p1
			j F1F3RM_D_CONT
			F1F3RM_D_SP1:
			la a3,foguinho_f3_p2
			li t1,1
			sb t1,8(t0) # salva novo sprite utilizado
			F1F3RM_D_CONT:
			lh t1,4(t0) # carrega mov horizontal
			addi t1,t1,-1
			sh t1,4(t0) # salva mov horizontal
			call PRINT_OBJ_MIRROR
			j FIM_FOGUINHO1_F3_REALIZE_MOVEMENT
		
	F1F3RM_VERT:
		lh t1,6(t0) # carrega contador vertical
		beqz t1,FIM_FOGUINHO1_F3_REALIZE_MOVEMENT
		bgtz t1,F1F3RM_VERT_DECREASE
			# decrease
			la t0,fogo1
			lh a0,0(t0)
			lh a1,2(t0)
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,foguinho_f3_p1
			call CLEAR_OBJPOS # limpa foguinho
		
			la t0,fogo1
			lh a0,0(t0) # carrega x
			lh a1,2(t0) # carrega y
			addi a1,a1,1
			sh a1,2(t0) # salva x
			la a2,display
			lw a2,0(a2) # carrega display
			# decide sprite
			lb t1,8(t0)
			beqz t1,F1F3RM_VERT_I_SP1
			la a3,foguinho_f3_p1
			j F1F3RM_VERT_I_CONT
			F1F3RM_VERT_I_SP1:
			la a3,foguinho_f3_p2
			li t1,1
			sb t1,8(t0) # salva novo sprite utilizado
			F1F3RM_VERT_I_CONT:
			lh t1,6(t0) # carrega mov horizontal
			addi t1,t1,1
			sh t1,6(t0) # salva mov horizontal
			call PRINT_OBJ_MIRROR
			j FIM_FOGUINHO1_F3_REALIZE_MOVEMENT
		F1F3RM_VERT_DECREASE:
			# decrease
			la t0,fogo1
			lh a0,0(t0)
			lh a1,2(t0)
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,foguinho_f3_p1
			call CLEAR_OBJPOS # limpa foguinho
		
			la t0,fogo1
			lh a0,0(t0) # carrega x
			lh a1,2(t0) # carrega y
			addi a1,a1,-1
			sh a1,2(t0) # salva x
			la a2,display
			lw a2,0(a2) # carrega display
			# decide sprite
			lb t1,8(t0)
			beqz t1,F1F3RM_VERT_D_SP1
			la a3,foguinho_f3_p1
			j F1F3RM_VERT_D_CONT
			F1F3RM_VERT_D_SP1:
			la a3,foguinho_f3_p2
			li t1,1
			sb t1,8(t0) # salva novo sprite utilizado
			F1F3RM_VERT_D_CONT:
			lh t1,6(t0) # carrega mov horizontal
			addi t1,t1,-1
			sh t1,6(t0) # salva mov horizontal
			call PRINT_OBJ_MIRROR
	
	FIM_FOGUINHO1_F3_REALIZE_MOVEMENT:
		j MOV_FOGO2_F3