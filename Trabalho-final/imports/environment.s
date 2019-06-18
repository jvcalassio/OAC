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
	ret
	
LADY_LOOP:
	
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
	
	ret
	
	LADY_RESET:
		
		la	t4, var_lady
		sw	zero, 0(t4)
		ret
			
	LADY_FRAME0:
		
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw 	a2, 0(a2)
		la	a3, fase_current
		la	a4, lady_p1
		save_stack(ra)
		call CLEAR_OBJPOS
		free_stack(ra)
		
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw 	a2, 0(a2)
		la	a3, lady_p1
		save_stack(ra)
		call PRINT_OBJ
		free_stack(ra)
		
		la	t4, var_lady
		lw	t0, 0(t4)
		addi	t0, t0, 1
		sw	t0, 0(t4)
		
		ret
		
	LADY_FRAME1:

		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw	a2, 0(a2)
		la	a3, fase_current
		la	a4, lady_p2
		save_stack(ra)
		call CLEAR_OBJPOS
		free_stack(ra)
		
		li	a0, 113
		li	a1, 25
		#li	a2, DISPLAY0
		la	a2, display
		lw	a2, 0(a2)
		la	a3, lady_p2
		save_stack(ra)
		call PRINT_OBJ
		free_stack(ra)
		
		la	t4, var_lady
		lw	t0, 0(t4)
		addi	t0, t0, 1
		sw	t0, 0(t4)
		
		ret

# Imprime textos auxiliares de jogo
PRINT_TEXT_INITIAL:
	la a0,up_text
	li a1,40
	li a2,5
	li a3,0x00ff
	li a4,0
	li a7,104
	ecall # imprime "UP" no display 0
	la a0,up_text
	li a4,1
	ecall # imprime "UP" no display 1
	
	la a0,highscore_text
	li a1,190
	li a2,5
	li a3,0x00ff
	li a4,0
	li a7,104
	ecall # imprime "HIGHSCORE" no display 0
	la a0,highscore_text
	li a4,1
	ecall # imprime "HIGHSCORE" no display 1
	
	la t0,vidas
	lb a0,0(t0)
	li a1,30
	li a2,5
	li a3,0x00ff
	li a4,0
	li a7,101
	ecall # imprime quantidade de vidas atualmente no display 0
	la t0,vidas
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
	li a1,265
	li a2,30
	li a3,0x00ff
	la t0,display
	lw a4,0(t0) # carrega display atual
	andi a4,a4,0x20
	srli a4,a4,5
	li a7,101
	ecall  # imprime bonus
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
	li t1,3000 # 3 segundos
	bge t2,t1,SUB_BONUS # se a dif de tempo >= 3s, subtrai o valor do bonus
	
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
		bgez t1,FIM_HBONUS_MANAGEMENT # se bonus > 0, continua
		# se bonus <= 0, mario morre
		tail MARIO_DEATH
		
	FIM_HBONUS_MANAGEMENT:
		ret

# Inicia bonus da fase
INIT_BONUS:
	gettime()
	# recebe tempo em a0
	la t0,bonus_time
	sw a0,0(t0)
	
	# grava bonus inicial
	la t0,bonus
	li t1,STARTING_BONUS
	sw t1,0(t0)
	ret
