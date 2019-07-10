.include "imports/macros2.s"  
.include "imports/macros.s"

.data
str_start: .string "INICIAR"
str_sounds: .string "SONS:"
str_sound_on: .string "ON "
str_sound_off: .string "OFF"
menu_selector: .byte 0

donkey_title_map: .word 0x1cf4a5e9, 0x1296a909, 0x1295b1cf, 0x1294a906, 0x1cf4a5e6 # primeira palavra
kong_title_map: .word 0x4bd2f, 0x525a8, 0x6256b, 0x52529, 0x4bd2f # segunda palavra
.text
	M_SetEcall(exceptionHandling)
START_MENU:
	la t0,menu_selector
	sb zero,0(t0)
	
	# tela preta
	li a0,0x00
	li a1,0
	li a7,148
	ecall
	
	jal DRAW_DK_TITLE
	
	# texto de start
	la a0,str_start
	li a1,70
	li a2,190
	li a3,0x00ff
	li a4,0
	li a7,104
	ecall
	
	# texto de som
	la a0,str_sounds
	li a1,170
	li a2,190
	li a3,0x00ff
	li a4,0
	li a7,104
	ecall
	
	# seletor
	li a0,'*'
	li a1,60
	li a2,190
	li a3,0x00fa
	li a4,0
	li a7,111
	ecall

# Loop do menu
MAINMENU_LOOP:
	jal CHECK_SOUND_TXT
	call KEYBIND
	beqz a0,MAINMENU_LOOP_RET
		li t0,100 # D
		beq a0,t0,MOVE_CURSOR_NEXT
		li t0,97 # A
		beq a0,t0,MOVE_CURSOR_NEXT
		li t0,119 # D
		beq a0,t0,MOVE_CURSOR_NEXT
		li t0,115 # A
		beq a0,t0,MOVE_CURSOR_NEXT
		li t0,32 # espaco
		beq a0,t0,CURSOR_SELECTION
	
	MAINMENU_LOOP_RET:
		j MAINMENU_LOOP
		

# Move o seletor do menu		
MOVE_CURSOR_NEXT:
	la t0,menu_selector
	lb t1,0(t0)
	beqz t1,PRINT_SELECTION2
		li a0,'*'
		li a1,60
		li a2,190
		li a3,0x00fa
		li a4,0
		li a7,111
		ecall # printa cursor na nova posicao
		li a0,'*'
		li a1,160
		li a2,190
		li a3,0x0000
		li a4,0
		li a7,111
		ecall # limpa cursor
		la t0,menu_selector
		sb zero,0(t0) # salva nova posicao
		j FIM_MOVE_CURSOR_NEXT
	PRINT_SELECTION2:
		li a0,'*'
		li a1,60
		li a2,190
		li a3,0x0000
		li a4,0
		li a7,111
		ecall # limpa cursor
		li a0,'*'
		li a1,160
		li a2,190
		li a3,0x00fa
		li a4,0
		li a7,111
		ecall # printa cursor na nova posicao
		la t0,menu_selector
		li t1,1
		sb t1,0(t0) # salva nova posicao
	
	FIM_MOVE_CURSOR_NEXT:
		j MAINMENU_LOOP_RET
	
# Realiza o click do botao do menu	
CURSOR_SELECTION:
	la t0,menu_selector
	lb t1,0(t0)
	beqz t1,CURSOR_SELECT_STARTGM
		# se selecionado som
		la t0,sounds
		lb t1,0(t0)
		beqz t1,CURSOR_SELECT_SOUNDON
			# desliga o som
			sb zero,0(t0)
			j FIM_CURSOR_SELECTION
		CURSOR_SELECT_SOUNDON: # liga o som
			li t1,1
			sb t1,0(t0)
			j FIM_CURSOR_SELECTION

	CURSOR_SELECT_STARTGM: # se selecionado start
		tail INIT_GAME
		
	FIM_CURSOR_SELECTION:
		j MAINMENU_LOOP_RET

# Printa o texto correto dos sons
CHECK_SOUND_TXT:
	la t0,sounds
	lb t1,0(t0)
	beqz t1,CHECK_SOUND_TXT_OFF
		la a0,str_sound_on
		j FIM_CHECK_SOUND_TXT
	CHECK_SOUND_TXT_OFF:
		la a0,str_sound_off
	FIM_CHECK_SOUND_TXT:
		li a1,220
		li a2,190
		li a3,0x00ff
		li a4,0
		li a7,104
		ecall
		ret
		
# Desenha o titulo "Donkey Kong"
DRAW_DK_TITLE:
	save_stack(ra)
	# desenha donkey
	la s1,donkey_title_map # linha inicial
	li s2,5 # contador de linhas
	li s5,30 # y a ser impresso
	LOOP_DRAW_DONKEY_LINE:
		beqz s2,DRAW_KONG
		li s3,29 # 29 colunas no total
		li s4,0 # contador de colunas
		li s6,40 # x a ser impresso
		LOOP_DRAW_DONKEY_COL:
			li s0,0x10000000 # starting
			beq s4,s3,FIM_LOOP_DRAW_DONKEY_COL
			lw t0,0(s1) # carrega word da linha
			srl s0,s0,s4 # shifta j vezes
			and t1,t0,s0 # verifica se precisa pintar ou nao
			beqz t1,CONT_LDRAW_DONKEY_COL
				mv a0,s6
				mv a1,s5
				li a2,DISPLAY0
				la a3,fase3_blue_block
				call PRINT_OBJ
		CONT_LDRAW_DONKEY_COL:
			addi s6,s6,8 # pula o tamanho do bloco
			addi s4,s4,1
			j LOOP_DRAW_DONKEY_COL
				
		FIM_LOOP_DRAW_DONKEY_COL:
			addi s5,s5,8 # pula linha
			addi s2,s2,-1 # decrementa i
			addi s1,s1,4 # pula pra prox word
			j LOOP_DRAW_DONKEY_LINE
			
	# desenha kong
	DRAW_KONG:
		la s1,kong_title_map # linha inicial
		li s2,5 # contador de linhas
		li s5,78 # y a ser impresso
		LOOP_DRAW_KONG_LINE:
			beqz s2,FIM_DRAW_DK_TITLE
			li s3,19 # 19 colunas no total
			li s4,0 # contador de colunas
			li s6,80 # x a ser impresso
			LOOP_DRAW_KONG_COL:
				li s0,0x40000 # starting
				beq s4,s3,FIM_LOOP_DRAW_KONG_COL
				lw t0,0(s1) # carrega word da linha
				srl s0,s0,s4 # shifta j vezes
				and t1,t0,s0 # verifica se precisa pintar ou nao
				beqz t1,CONT_LDRAW_KONG_COL
					mv a0,s6
					mv a1,s5
					li a2,DISPLAY0
					la a3,fase3_blue_block
					call PRINT_OBJ
			CONT_LDRAW_KONG_COL:
				addi s6,s6,8 # pula o tamanho do bloco
				addi s4,s4,1
				j LOOP_DRAW_KONG_COL
				
			FIM_LOOP_DRAW_KONG_COL:
				addi s5,s5,8 # pula linha
				addi s2,s2,-1 # decrementa i
				addi s1,s1,4 # pula pra prox word
				j LOOP_DRAW_KONG_LINE
		
	
	
	FIM_DRAW_DK_TITLE:
		# desenha sprite do dk no centro
		li a0,125
		li a1,130
		li a2,DISPLAY0
		la a3,dk_1
		call PRINT_OBJ
	
		free_stack(ra)
		ret

.include "imports/game.s"
