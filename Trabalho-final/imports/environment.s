.data
.include "../sprites/bin/dk_1.s"
.include "../sprites/bin/dk_2.s"
.include "../sprites/bin/lady_p1.s"
.include "../sprites/bin/lady_p2.s"
var_dk: .word 0,0,0,0
var_lady: .word 0

# strings de jogo
victory_text: .string "PARABENS VC VENCEU"
gameover_text: .string "GAME OVER"
loading_text: .string "CARREGANDO"
level_text: .string "LV"
blank: .string " " # lembrar de apagar
up_text: .string "UP"
highscore_text: .string "HIGHSCORE"
bonus_text: .string "BONUS"

.text

# Faz danca do Donkey Kong fase 1
INIT_DK_DANCA:
	
	la	t4, var_dk
	sw	zero, 0(t4)	#var_i = 0
	li	t0, 50
	sw	t0, 4(t4)	#var0 = 10000
	li	t0, 100
	sw	t0, 8(t4)	#var1 = 20000
	li	t0, 150
	sw	t0, 12(t4)	#var_2 = 30000
	j DK_DANCA_FRAME0 # printa primeiro frame
	ret

DK_DANCA_LOOP:
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	beq	t0, zero, DK_DANCA_FRAME0 #i==0? goto FRAME0
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	lw	t1, 4(t4)	#10000
	beq	t0, t1, DK_DANCA_FRAME1	#i==10000? goto FRAME1
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	lw	t2, 8(t4)	#20000
	beq	t0, t2, DK_DANCA_FRAME2	#i==20000? goto FRAME2
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	lw	t3, 12(t4)	#30000
	bge	t0, t3, DK_DANCA_RESET	#i>=30000? goto RESETi
	
	la	t4, var_dk
	lw	t0, 0(t4)
	addi 	t0, t0, 1	#i++
	sw	t0, 0(t4)
	
	ret

	DK_DANCA_RESET:

		la	t4, var_dk
		sw	zero, 0(t4)	#i=0
		ret

	DK_DANCA_FRAME0:
		
		li	a0, 62
		li	a1, 28
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_1
		save_stack(ra)
		call	CLEAR_OBJPOS
		free_stack(ra)
		
		li	a0, 62
		li	a1, 28
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_1
		save_stack(ra)
		call 	PRINT_OBJ
		free_stack(ra)
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)

		ret

	DK_DANCA_FRAME1:

		li	a0, 62
		li	a1, 28
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_2
		save_stack(ra)
		call	CLEAR_OBJPOS
		free_stack(ra)
		
		li	a0, 62
		li	a1, 28
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_2
		save_stack(ra)
		call 	PRINT_OBJ
		free_stack(ra)
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		ret
		
	DK_DANCA_FRAME2:

		li	a0, 62
		li	a1, 28
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_1
		save_stack(ra)
		call	CLEAR_OBJPOS
		free_stack(ra)
		
		li	a0, 62
		li	a1, 28
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_1
		save_stack(ra)
		call 	PRINT_OBJ_MIRROR
		free_stack(ra)
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		ret

# Faz danca da lady na fase 1
INIT_LADY:
	
	la	t4, var_lady
	sw	zero, 0(t4)
	save_stack(ra)
	j LADY_FRAME0 # printa primeiro frame da lady
	
LADY_LOOP:
	save_stack(ra)
	la	t4, var_lady
	lw	t0, 0(t4)
	beq	t0, zero, LADY_FRAME0
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 10
	beq	t0, t1, LADY_FRAME1

	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 15
	beq	t0, t1, LADY_FRAME0
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 20
	beq	t0, t1, LADY_FRAME1
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 25
	beq	t0, t1, LADY_FRAME0
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 30
	beq	t0, t1, LADY_FRAME1
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 35
	beq	t0, t1, LADY_FRAME0
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 40
	beq	t0, t1, LADY_FRAME1
	
	#la	t4, var_lady
	#lw	t0, 0(t4)
	#li	t1, 120
	#beq	t0, t1, LADY_FRAME0
	
	la	t4, var_lady
	lw	t0, 0(t4)
	li	t1, 100
	bge	t0, t1, LADY_RESET
	
	la	t4, var_lady
	lw	t0, 0(t4)
	addi	t0, t0, 1
	sw	t0, 0(t4)
	
	j FIM_LADY_LOOP
	
	LADY_RESET:
		
		la	t4, var_lady
		sw	zero, 0(t4)
		j FIM_LADY_LOOP
			
	LADY_FRAME0:
		
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw 	a2, 0(a2)
		la	a3, fase_current
		la	a4, lady_p1
		call CLEAR_OBJPOS
		
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw 	a2, 0(a2)
		la	a3, lady_p1
		call PRINT_OBJ
		
		la	t4, var_lady
		lw	t0, 0(t4)
		addi	t0, t0, 1
		sw	t0, 0(t4)
		
		j FIM_LADY_LOOP
		
	LADY_FRAME1:
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw	a2, 0(a2)
		la	a3, fase_current
		la	a4, lady_p2
		call CLEAR_OBJPOS
		
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw	a2, 0(a2)
		la	a3, lady_p2
		call PRINT_OBJ
		
		la	t4, var_lady
		lw	t0, 0(t4)
		addi	t0, t0, 1
		sw	t0, 0(t4)
		
	FIM_LADY_LOOP:
		free_stack(ra)
		ret

# Imprime textos auxiliares de jogo
PRINT_TEXT_INITIAL:
	la a0,up_text
	li a1,40
	li a2,5
	li a3,0x0007
	li a4,0
	li a7,104
	ecall # imprime "UP" no display 0
	la a0,up_text
	li a4,1
	ecall # imprime "UP" no display 1
	
	la a0,highscore_text
	li a1,190
	li a2,5
	li a3,0x0007
	li a4,0
	li a7,104
	ecall # imprime "HIGHSCORE" no display 0
	la a0,highscore_text
	li a4,1
	ecall # imprime "HIGHSCORE" no display 1
	
	la a0,level_text
	li a1,274
	li a2,5
	li a3,0x00d9
	li a4,0
	li a7,104
	ecall # imprime "LV" no display 0
	la a0,level_text
	li a4,1
	ecall # imprime "LV" no display 1
	
	la t0,level
	lb a0,0(t0)
	li a1,294
	li a2,5
	li a3,0x00d9
	li a4,0
	li a7,101
	ecall # imprime quantidade de vidas atualmente no display 0
	la t0,level
	lb a0,0(t0)
	li a4,1
	ecall # imprime quantidade de vidas no display 1
	ret
	
# Imprime dados de jogo (vidas, score, high score, bonus)
PRINT_TEXT:
	la t0,score
	lw a0,0(t0)
	li a1,30
	li a2,15
	li a3,0x00ff
	la t0,display
	lw a4,0(t0) # carrega display atual
	andi a4,a4,0x20
	srli a4,a4,5
	li a7,101
	ecall # imprime score 
	
	la t0,highscore
	lw a0,0(t0)
	li a1,190
	li a2,15
	li a3,0x00ff
	la t0,display
	lw a4,0(t0) # carrega display atual
	andi a4,a4,0x20
	srli a4,a4,5
	li a7,101
	ecall  # imprime highscore
	
	la t0,bonus
	lw a0,0(t0)
	li a1,274
	li a2,30
	la t0,display
	lw a4,0(t0) # carrega display atual
	andi a4,a4,0x20
	srli a4,a4,5
	li a7,101
	la t0,fase
	lb t1,0(t0) # carrega fase atual
	li t0,3
	beq t0,t1,PRINT_TEXT_BONUS3 # imprime bonus amarelo (fase3)
	li a3,0x00f9
	j FIM_PRINT_TEXT
	PRINT_TEXT_BONUS3:
	li a3,0x006f
	FIM_PRINT_TEXT:
	ecall  # imprime bonus
	
	la t0,vidas
	lb a0,0(t0)
	li a1,30
	li a2,5
	li a3,0x0007
	la t0,display
	lw a4,0(t0)
	andi a4,a4,0x20
	srli a4,a4,5 # carrega display atual
	li a7,101
	ecall # imprime quantidade de vidas atualmente
	ret

# Muda valores do highscore e bonus
HIGHSCORE_BONUS_MANAGEMENT:
	la t0,score
	lw t1,0(t0)
	la t0,highscore
	lw t2,0(t0)
	bgt t1,t2,ADD_HIGHSCORE # highscore
	
	HBONUS_MANAG_CONT1:
	gettime()
	la t0,bonus_time
	lw t1,0(t0)
	sub t2,a0,t1 # tempo atual - ultimo tempo de sub do highscore
	li t1,2000 # 2 segundos
	bge t2,t1,SUB_BONUS # se a dif de tempo >= 2s, subtrai o valor do bonus
	
	HBONUS_MANAG_CONT2:
	la t0,given_extra_life
	lb t1,0(t0)
	beqz t1,CHECK_EXTRA_LIFE # se ainda nao deu vida extra, verifica se pode
	j FIM_HBONUS_MANAGEMENT
	
	ADD_HIGHSCORE: # muda highscore caso score seja maior
		la t0,score
		lw t1,0(t0)
		la t0,highscore
		sw t1,0(t0)
		j HBONUS_MANAG_CONT1
		
	SUB_BONUS: # muda bonus caso tenha decorrido o tempo
		la t0,bonus_time
		gettime()
		sw a0,0(t0) # grava ultimo tempo de subtracao
		la t0,bonus
		lw t1,0(t0)
		addi t1,t1,-100 # subtrai 100 do bonus
		sw t1,0(t0) # grava novo bonus
		bgez t1,HBONUS_MANAG_CONT2 # se bonus > 0, continua
		# se bonus <= 0, mario morre
		tail MARIO_DEATH
		
	CHECK_EXTRA_LIFE: # da a vida extra caso o score ultrapasse 20.000
		la t0,score
		lw t1,0(t0) # carrega score atual
		li t0,20000
		bge t1,t0,GIVE_EXTRA_LIFE # se score >= 20k, da a vida
		j FIM_HBONUS_MANAGEMENT	  # do contrario, nao faz nada
		GIVE_EXTRA_LIFE:
			la t0,vidas
			lb t1,0(t0)
			addi t1,t1,1
			sb t1,0(t0) # vida extra concedida
			la t0,given_extra_life
			addi t1,zero,1
			sb t1,0(t0) # marca flag como concedida
		
	FIM_HBONUS_MANAGEMENT:
		ret

# Inicia bonus da fase
INIT_BONUS:
	gettime()
	# recebe tempo em a0
	la t0,bonus_time
	sw a0,0(t0)
	
	# grava bonus inicial
	# pega lvl para saber qual adicional
	la t0,level
	lb t1,0(t0)
	li t0,4
	bge t1,t0,STARTING_BONUS_8K # se lvl >= 4, recebe sempre 8000 de bonus inicial
	addi t2,t1,-1 # -1 pra ajustar o bonus recebido por lvl
	li t0,1000
	mul t2,t2,t0 # x 1000
	j CONT_STARTING_BONUS
	STARTING_BONUS_8K:
		li t2,3000
	CONT_STARTING_BONUS:
		la t0,bonus
		li t1,STARTING_BONUS
		add t1,t1,t2 # adiciona bonus por lvl
		sw t1,0(t0)
		ret

# sons iniciais das fases
INIT_SOUND:
	la t0,sounds
	lb t1,0(t0)
	beqz t1,FIM_INIT_SOUND # sons desligados
	# toca som de fase start
	la t0,NOTAS_FASE_START
	la t1,NUM_FASE_START
	lw t1,0(t1) # numero de notas
	li a2,80
	li a3,127
	LOOP_INIT_SOUND:
		beqz t1,FIM_LOOP_INIT_SOUND
		lw a0,0(t0)
		lw a1,4(t0)
		li a7,31
		ecall
		mv a0,a1
		li a7,32
		ecall
		addi t1,t1,-1
		addi t0,t0,8
		j LOOP_INIT_SOUND
		
	FIM_LOOP_INIT_SOUND:
	li a3,0
	li a7,31
	ecall
	li a0,100
	li a7,32
	ecall
	FIM_INIT_SOUND:
		ret

# Toca o som de fase completa		
SOUND_CLEARSTAGE:
	la t0,sounds
	lb t1,0(t0)
	beqz t1,FIM_SOUND_CLEARSTAGE # sons desligados
	
	la t0,NOTAS_FASE_CLEAR
	la t1,NUM_FASE_CLEAR
	lw t1,0(t1) # numero de notas
	li a2,80
	li a3,127
	FOR_SOUND_CLEARSTAGE:
		beqz t1,FIM_SOUND_CLEARSTAGE
		lw a0,0(t0)
		lw a1,4(t0)
		li a7,31
		ecall
		mv a0,a1
		li a7,32
		ecall
		addi t0,t0,8
		addi t1,t1,-1
		j FOR_SOUND_CLEARSTAGE
	FIM_SOUND_CLEARSTAGE:
	ret

