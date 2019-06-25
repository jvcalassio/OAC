.data
.include "../sprites/bin/dk_1.s"
.include "../sprites/bin/dk_2.s"
.include "../sprites/bin/dk_4.s"
.include "../sprites/bin/dk_5.s"
.include "../sprites/bin/lady_p1.s"
.include "../sprites/bin/lady_p2.s"
.include "../sprites/bin/barril_lateral_p1.s"
.include "../sprites/bin/barril.s"

var_dk: .word 0
var_lady: .word 0
var_barris: .word 0, 0, 0, 0, 0, 0 #posicoes de 6 barris, usar GETXY para converter para coordenadas

# strings de jogo
victory_text: .string "PARABENS VC VENCEU"
gameover_text: .string "GAME OVER"
loading_text: .string "CARREGANDO"
blank: .string " " # lembrar de apagar
up_text: .string "UP"
highscore_text: .string "HIGHSCORE"
bonus_text: .string "BONUS"

.text

######################################################
#Calcula X e Y, dado um endereco do bitmap display
#a0 = endereco
#a1 = endereco base
#retorna X em a0 e Y em a1
######################################################
GET_XY:
	sub	a0, a0, a1
	li	t0, 320
	rem	a0, a0, t0	# x = end%320
	div	a1, a1, t0	# y = end/320
	jr	ra, 0


#inicializa uma nova variável para um barril, dentro de var_barris
#a0 = x
#a1 = y
INIT_NOVO_BARRIL:
	la	a2, display
	lw	a2, 0(a2)
	save_stack(ra)
	call	GET_POSITION
	free_stack(ra)
	
	#encontra primeira posicao zerada na var_barris e armazena lá o novo valor do barril
	la	t0, var_barris
	
	loop_verifica_barris1:
	lw	t1, 0(t0)
	beqz	t1, fim_init_novo_barril
	addi	t0,t0,4
	j	loop_verifica_barris1
	
	fim_init_novo_barril:
	sw	a0, 0(t0)
	ret

#responsável pelo movimento dos barris
MOV_BARRIS:
	save_stack(ra)
	la	t0, var_barris
	li	t1, 0	#t1 = i
	
	loop_mov_barris:
	li	t2, 6
	beq	t2, t1, FIM_MOV_BARRIS
	lw	t2, 0(t0)
	
	save_stack(t0)
	save_stack(t1)
	bnez	t2, MOVER_BARRIL
	
	continue_MOV_BARRIS:
	free_stack(t1)
	free_stack(t0)
	
	addi	t0, t0, 4
	addi	t1, t1, 1
	j	loop_mov_barris
	
	MOVER_BARRIL:
		mv	a0, t2
		la	a1, display
		lw	a1, 0(a1)
		call	GET_XY
		save_stack(a0)
		save_stack(a1)	#salva x e y
		
		la	a2, display
		lw	a2, 0(a2)
		la	a3, fase_current
		la	a4, barril
		call	CLEAR_OBJPOS
		
		free_stack(a1)
		free_stack(a0)
		addi	a0, a0, 1	#movendo o barril 1 pixel para a direita
		la	a2, display
		lw	a2, 0(a2)
		la	a3, barril
		call	PRINT_OBJ
		
		j	continue_MOV_BARRIS
		
			
	FIM_MOV_BARRIS:
		free_stack(ra)
		ret
		
# Faz danca do Donkey Kong fase 1
INIT_DK_DANCA:
	la	t4, var_dk
	sw	zero, 0(t4)	#var_i = 0
	ret

DK_DANCA_LOOP:
	save_stack(ra)
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	beq	t0, zero, DK_DANCA_FRAME0 #i==0? goto FRAME0
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 50		#50
	beq	t0, t1, DK_DANCA_FRAME1	#i==50? goto FRAME1
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 100		#100
	beq	t0, t1, DK_DANCA_FRAME2	#i==100? goto FRAME2
	
	
	li	t0, 1
	la	t1, fase
	lb	t1, 0(t1)
	bne	t0, t1, NAO_BARRIS	#se a fase não for a primeira, pula-se os frames responsáveis pelo spawn do barril
	
	#checa se 6 barris já foram lancados
	la	t0, var_barris
	li	t2,0	#t2 = i
	loop_verifica_barris:
	li	t1, 6	#parada em 6
	beq	t2, t1, NAO_BARRIS #verificou todos e n ha nenhum zerado
	lw	t1, 0(t0)
	beqz	t1, exit_verifica_barris
	addi	t0, t0, 4
	addi	t2, t2, 1
	j	loop_verifica_barris
	
	exit_verifica_barris:
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 150	
	beq	t0, t1, DK_DANCA_FRAME3	#i==150? goto FRAME3
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 200
	beq	t0, t1, DK_DANCA_FRAME4	#i==200? goto FRAME4
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 250
	beq	t0, t1, DK_DANCA_FRAME5	#i==200? goto FRAME5
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 300
	bge	t0, t1, DK_DANCA_RESET	#i>=300? goto RESETi
	
	j	i_MAISMAIS
	
	NAO_BARRIS:
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 150		#150
	bge	t0, t1, DK_DANCA_RESET	#i>=150? goto RESETi
	
	i_MAISMAIS:
	la	t4, var_dk
	lw	t0, 0(t4)
	addi 	t0, t0, 1	#i++
	sw	t0, 0(t4)
	j	FIM_DK_DANCA

	DK_DANCA_RESET:
		la	t4, var_dk
		sw	zero, 0(t4)	#i=0
		ret

	DK_DANCA_FRAME0:
		#setar a posicao de x e y
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_1
		call	CLEAR_OBJPOS
			
		jal	 SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_1
		call 	PRINT_OBJ
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)

		j	FIM_DK_DANCA

	DK_DANCA_FRAME1:
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_2
		call	CLEAR_OBJPOS
		
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_2
		call 	PRINT_OBJ
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		j	FIM_DK_DANCA
		
	DK_DANCA_FRAME2:
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_1
		call	CLEAR_OBJPOS
		
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_1
		call 	PRINT_OBJ_MIRROR
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		j	FIM_DK_DANCA
	
	DK_DANCA_FRAME3:
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_4
		call	CLEAR_OBJPOS
		
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_4
		call 	PRINT_OBJ
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		j	FIM_DK_DANCA
	
	DK_DANCA_FRAME4:
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_5
		call	CLEAR_OBJPOS
		
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_5
		call 	PRINT_OBJ
		
		#printar barril na mao do dk
		li	a0, 78
		li	a1, 52
		la	a2, display
		lw	a2, 0(a2)
		la	a3, barril_lateral_p1
		call	PRINT_OBJ
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		j	FIM_DK_DANCA
	
	DK_DANCA_FRAME5:
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, fase_current
		la	a4, dk_4
		call	CLEAR_OBJPOS
		
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_4
		call 	PRINT_OBJ_MIRROR
		
		#printar barril no chao
		li	a0, 111
		li	a1, 52
		la	a2, display
		lw	a2, 0(a2)
		la	a3, barril
		call	PRINT_OBJ
		
		li	a0, 111
		li	a1, 52
		call	INIT_NOVO_BARRIL
		
		la	t4, var_dk
		lw	t0, 0(t4)
		addi 	t0, t0, 1	#i++
		sw	t0, 0(t4)
		
		j	FIM_DK_DANCA
		
	FIM_DK_DANCA:
		free_stack(ra)
		ret
		
	SET_POSDK:
		la	t0, fase
		lb	t0, 0(t0)
		li	t1, 1
		beq	t0, t1, SET_POSDK0
		li	t1, 2
		beq	t0, t1, SET_POSDK0
		li	t1, 3
		beq	t0, t1, SET_POSDK1
	
	SET_POSDK0:
		li	a0, 62
		li	a1, 28
		ret
	SET_POSDK1:
		li	a0, 138
		li	a1, 28
		ret
# Faz danca da lady na fase 1
INIT_LADY:
	la	t4, var_lady
	sw	zero, 0(t4)
	ret
	
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
	
	j	FIM_LADY
	
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
		
		j	FIM_LADY
		
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
		
		j	FIM_LADY
	
	FIM_LADY:
		free_stack(ra)
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
