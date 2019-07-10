.include "imports/macros2.s"  

.data
str_start: .string "INICIAR"
str_sounds: .string "SONS:"
str_sound_on: .string "ON "
str_sound_off: .string "OFF"
menu_selector: .byte 0
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

.include "imports/game.s"
