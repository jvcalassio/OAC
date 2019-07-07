.data
.include "../sprites/bin/dk_1.s"
.include "../sprites/bin/dk_2.s"
.include "../sprites/bin/dk_3.s"
.include "../sprites/bin/dk_4.s"
.include "../sprites/bin/lady_p1.s"
.include "../sprites/bin/lady_p2.s"
.include "../sprites/bin/bolsa.s"
.include "../sprites/bin/guardachuva.s"
.include "../sprites/bin/martelo_x.s"
.include "../sprites/bin/martelo_y.s"
.include "../sprites/bin/barril_lateral_p1.s"
.include "../sprites/bin/barril.s"
.include "../sprites/bin/barril_y.s"
var_dk:		.word 0
var_lady:	.word 0
var_barris:	.half 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 #posicoes de 6 barris, armazenados em pares x, y
var_barris1:	.byte 0, 0, 0, 0, 0, 0	#armazena a direcao que os barris devem ir  (0 direita, 1 esquerda)
var_barris2: 	.byte 0, 0, 0, 0, 0, 0 #armazena como o barril sera printado (0,1,2,3) 4 formas de printar

# strings de jogo
victory_text: .string "PARABENS VC VENCEU"
gameover_text: .string "GAME OVER"
loading_text: .string "CARREGANDO"
level_text: .string "LV"
up_text: .string "UP"
highscore_text: .string "HIGHSCORE"
bonus_text: .string "BONUS"

# variaveis dos coletaveis
fase1_items: .byte 0 # martelo quarto andar | martelo terceiro andar
fase2_items: .byte 0 # bolsa | guarda chuva
fase3_items: .byte 0 # martelo piso 3 | martelo piso 2 | guarda chuva piso 4 | bolsa | guarda chuva piso 2
# outros
points_timer: .word 0,0 # variaveis do tempo de exibicao do texto de pontos ganhos (max 2 simultaneo)
points_pos: .half 0,0,0,0 # texto 1 (x,y) , texto 2 (x,y)
.text

#inicializa uma nova variavel para um barril, dentro de var_barris
#a0 = x
#a1 = y
INIT_NOVO_BARRIL:
	#encontra primeira posicao zerada na var_barris e armazena la o novo valor do barril
	la	t0, var_barris
	la	t4, var_barris1
	la	t5, var_barris2
	loop_verifica_barris1:
	lh	t1, 0(t0)
	lh	t2, 2(t0)
	add	t1, t1, t2
	beqz	t1, fim_init_novo_barril
	addi	t0, t0, 4
	addi	t4, t4, 1
	addi	t5, t5, 1
	j	loop_verifica_barris1
	
	fim_init_novo_barril:
	sh	a0, 0(t0)
	sh	a1, 2(t0)
	sb	zero, 0(t4)
	sb	zero, 0(t5)
	ret

#responsavel pelo movimento dos barris
MOV_BARRIS:
	save_stack(ra)
	
	li	t0, 1
	la	t1, fase
	lb	t1, 0(t1)
	bne	t0, t1, FIM_MOV_BARRIS
	
	la	t0, var_barris	#localizacao dos barris
	li	t1, 0	#t1 = i
	la	t4, var_barris1 #direcao dos barris
	la	t5, var_barris2 #print dos barris
	
	#checa quais barris ja foram inicializados (x+y!=0)
	loop_mov_barris:
	li	t2, 6
	beq	t1, t2, FIM_MOV_BARRIS
	
	lh	t2, 0(t0)	#x[i]
	lh	t3, 2(t0)	#y[i]
	add	t2, t2, t3
	save_stack(t0)	#salvando a atual posicao do endereco
	save_stack(t1)	#salvando a atual posicao de i
	save_stack(t4)	#salva end da direcao do barril
	save_stack(t5)	#salva end da forma de printar o barril
	bnez	t2, MOV_BARRIS1
	
	continueMOV_BARRIS:
	free_stack(t5)
	free_stack(t4)
	free_stack(t1)
	free_stack(t0)
	addi	t0, t0, 4
	addi	t1, t1, 1
	addi	t4, t4, 1
	addi	t5, t5, 1
	j	loop_mov_barris
	
	MOV_BARRIS1:
		#limpando o barril da posicao atual
		save_stack(t5)
		lh	a0, 0(t0)
		lh	a1, 2(t0)
		la	a2, display
		lw	a2, 0(a2)
		la	a3, fase_current
		la	a4, barril
		save_stack(t0)
		save_stack(t4)
		call	CLEAR_OBJPOS
		free_stack(t4)
		free_stack(t0)
		
		#seta a direcao que o barril deve ir
		#checando se o barril deve desaparecer
		lh	t1, 0(t0)
		li	t2, 256
		bge	t1, t2, set_esquerda_barris
		li	t2, 50
		ble	t1, t2, set_direita_barris
		
		continueset_barris:
		li	t2, 62
		ble	t1, t2, zerar_barril
		
		continuezerar_barril:
		lb	t4, 0(t4)
		bnez	t4, esquerda_barris
		
		#movimento para a direita
		lh	a0, 0(t0)
		lh	a1, 2(t0)
		addi	a1, a1, 12
		la	a2, display
		lw	a2, 0(a2)
		save_stack(t0)
		call	GET_POSITION
		free_stack(t0)		
		li	t1, 0x46
		lb	a0, 0(a0)
		beq	a0, t1, MOV_BARRIS_DIREITA
		
		continueMOV_BARRISdireita:
		lh	a0, 0(t0)
		lh	a1, 2(t0)
		addi	a1, a1, 12
		la	a2, display
		lw	a2, 0(a2)
		save_stack(t0)
		call	GET_POSITION
		free_stack(t0)
		li	t1, 0x00
		lb	a0, 0(a0)
		beq	a0, t1, MOV_BARRIS_BAIXO
		
		j 	continueMOV_BARRISfim
		
		#movimento para a esquerda
		esquerda_barris:
		lh	a0, 0(t0)
		lh	a1, 2(t0)
		addi	a0, a0, 13
		addi	a1, a1, 12
		la	a2, display
		lw	a2, 0(a2)
		save_stack(t0)
		call	GET_POSITION
		free_stack(t0)		
		li	t1, 0x46
		lb	a0, 0(a0)
		beq	a0, t1, MOV_BARRIS_ESQUERDA
		
		continueMOV_BARRISesquerda:
		lh	a0, 0(t0)
		lh	a1, 2(t0)
		addi	a0, a0, 13
		addi	a1, a1, 12
		la	a2, display
		lw	a2, 0(a2)
		save_stack(t0)
		call	GET_POSITION
		free_stack(t0)
		li	t1, 0x00
		lb	a0, 0(a0)
		beq	a0, t1, MOV_BARRIS_BAIXO
		
		continueMOV_BARRISfim:
		free_stack(t5)
		lh	a0, 0(t0)
		lh	a1, 2(t0)
		la	a2, display
		lw	a2, 0(a2)
		
		#barril cair mais rapido quando esta em bordas
		li	t1, 256
		bge	a0, t1, barril_cair_mais
		li	t1, 50
		ble	a0, t1, barril_cair_mais

		
		back_to_print:
		lb	t2, 0(t5)	#decisao de como o barril sera printado
		li	t1, 0
		beq	t2, t1, print_barril0
		li	t1, 1
		beq	t2, t1, print_barril1
		li	t1, 2
		beq	t2, t1, print_barril2
		li	t1, 3
		beq	t2, t1, print_barril3
		
		sb	zero, 0(t5)
		j	back_to_print
		
		barril_cair_mais:
		addi	a1, a1, 1
		sh	a1, 2(t0)
		j	back_to_print
		
		print_barril0:
		la	a3, barril
		addi	t2, t2, 1
		sb	t2, 0(t5)
		call	PRINT_OBJ
		j	continueMOV_BARRIS
		print_barril1:
		addi	a0, a0, -1	#correcao de posicao no print
		la	a3, barril
		addi	t2, t2, 1
		sb	t2, 0(t5)
		call	PRINT_OBJ_MIRROR
		j	continueMOV_BARRIS
		print_barril2:
		la	a3, barril_y
		addi	t2, t2, 1
		sb	t2, 0(t5)
		call	PRINT_OBJ
		j	continueMOV_BARRIS
		print_barril3:
		addi	a0, a0, -1	#correcao de posicao no print
		la	a3, barril_y
		addi	t2, t2, 1
		sb	t2, 0(t5)
		call	PRINT_OBJ_MIRROR
		j	continueMOV_BARRIS
		
		zerar_barril:
			lh	t1, 2(t0)
			li	t2, 198
			bge	t1, t2, zerar_barril1
			j	continuezerar_barril
		zerar_barril1:
			free_stack(t5)
			sh	zero, 0(t0)
			sh	zero, 2(t0)
			j	continueMOV_BARRIS
		
		MOV_BARRIS_DIREITA:
			lh	t1, 0(t0)	#x
			lh	t2, 2(t0)	#y
			addi	t1, t1, 2	#pulando 1 pixel em x
			sh	t1, 0(t0)
			sh	t2, 2(t0)
			j	continueMOV_BARRISdireita
		
		MOV_BARRIS_ESQUERDA:
			lh	t1, 0(t0)	#x
			lh	t2, 2(t0)	#y
			addi	t1, t1, -2	#pulando 1 pixel em x
			sh	t1, 0(t0)
			sh	t2, 2(t0)
			j	continueMOV_BARRISesquerda
		
		MOV_BARRIS_BAIXO:
			lh	t1, 0(t0)	#x
			lh	t2, 2(t0)	#y
			addi	t2, t2, 1	#pulando 1 pixel em y
			sh	t1, 0(t0)
			sh	t2, 2(t0)
			j	continueMOV_BARRISfim
		
		set_esquerda_barris:
			li	t3, 1
			sb	t3, 0(t4)
			j	continueset_barris
		
		set_direita_barris:
			li	t3, 0
			sb	t3, 0(t4)
			j	continueset_barris
			
		
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
	li	t1, 20		#50
	beq	t0, t1, DK_DANCA_FRAME1	#i==50? goto FRAME1
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 40		#100
	beq	t0, t1, DK_DANCA_FRAME2	#i==100? goto FRAME2
	
	li	t0, 1
	la	t1, fase
	lb	t1, 0(t1)
	bne	t0, t1, NAO_BARRIS	#se a fase não for a primeira, pula-se os frames responsáveis pelo spawn do barril
	
	#checa se 6 barris já foram lancados
	la	t0, var_barris
	li	t1,0	#t1 = i
	loop_verifica_barris:
	li	t2, 6	#parada em 6
	beq	t1, t2, NAO_BARRIS #verificou todos e n ha nenhum zerado
	
	lh	t2, 0(t0)	#x[i]
	lh	t3, 2(t0)	#y[i]
	add	t2, t2, t3	#se a soma de x e y é zero, então um novo barril pode ser lancado
	beqz	t2, exit_verifica_barris
	
	addi	t0, t0, 4	#end++
	addi	t1, t1, 1	#i++
	j	loop_verifica_barris
	
	exit_verifica_barris:
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 60
	beq	t0, t1, DK_DANCA_FRAME3	#i==150? goto FRAME3
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 80
	beq	t0, t1, DK_DANCA_FRAME4	#i==200? goto FRAME4
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 100
	beq	t0, t1, DK_DANCA_FRAME5	#i==200? goto FRAME5
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 120
	bge	t0, t1, DK_DANCA_RESET	#i>=300? goto RESETi
	
	j	i_MAISMAIS
	
	NAO_BARRIS:
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	li	t1, 60		#150
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
		la	a4, dk_3
		call	CLEAR_OBJPOS
		
		jal	SET_POSDK
		#li	a2, DISPLAY0
		la 	a2, display
		lw	a2, 0(a2) # display atual
		la	a3, dk_3
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
	li t0,4
	beq t0,t1,PRINT_TEXT_BONUS3 # imprime bonus amarelo (fase4)
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

# Cria os itens (coletaveis) em cada fase	
INIT_ITEMS:
	save_stack(ra)
	la t0,fase
	lb t1,0(t0)
	li t0,1
	beq t0,t1,INIT_ITEMS_F1
	li t0,2
	beq t0,t1,INIT_ITEMS_F2
	li t0,3
	beq t0,t1,INIT_ITEMS_F3
	j FIM_INIT_ITEMS
	
	INIT_ITEMS_F1:
		# martelo 1
		li a0,65
		li a1,130
		la a2,display
		lw a2,0(a2)
		la a3,martelo_y
		call PRINT_OBJ
		# martelo 2
		li a0,65
		li a1,73
		la a2,display
		lw a2,0(a2)
		la a3,martelo_y
		call PRINT_OBJ
		
		la t0,fase1_items
		sb zero,0(t0)
		la t0,points_timer
		sw zero,0(t0)
		la t0,points_pos
		sh zero,0(t0)
		sh zero,2(t0)
		sh zero,4(t0)
		sh zero,6(t0)
		la t0,mario_hammer_timer
		sw zero,0(t0)
		la t0,mario_hammer_type
		sb zero,0(t0)
		j FIM_INIT_ITEMS
		
	INIT_ITEMS_F2:
		j FIM_INIT_ITEMS
		
	INIT_ITEMS_F3:
		# printa guarda chuvas
		li a0,74
		li a1,47
		la a2,display
		lw a2,0(a2)
		la a3,guardachuva
		call PRINT_OBJ
		li a0,225
		li a1,127
		la a2,display
		lw a2,0(a2)
		la a3,guardachuva
		call PRINT_OBJ
		# printa bolsa
		li a0,106
		li a1,133
		la a2,display
		lw a2,0(a2)
		la a3,bolsa
		call PRINT_OBJ
		# printa martelos
		li a0,50
		li a1,111
		la a2,display
		lw a2,0(a2)
		la a3,martelo_y
		call PRINT_OBJ # martelo segundo andar
		li a0,158
		li a1,72
		la a2,display
		lw a2,0(a2)
		la a3,martelo_y
		call PRINT_OBJ # martelo terceiro andar
		
		la t0,fase3_items
		sb zero,0(t0)
		la t0,points_timer
		sw zero,0(t0)
		la t0,points_pos
		sh zero,0(t0)
		sh zero,2(t0)
		sh zero,4(t0)
		sh zero,6(t0)
		la t0,mario_hammer_timer
		sw zero,0(t0)
		la t0,mario_hammer_type
		sb zero,0(t0)
	
	FIM_INIT_ITEMS:
		free_stack(ra)
		ret

# Verifica se o mario coletou algum item (na posicao atual)	
CHECK_ITEMS:
	save_stack(ra)
	la t0,fase
	lb t1,0(t0)
	li t0,1
	beq t0,t1,CHECK_ITEMS_F1
	li t0,2
	beq t0,t1,CHECK_ITEMS_F2
	li t0,3
	beq t0,t1,CHECK_ITEMS_F3
	j FIM_CHECK_ITEMS
	
	CHECK_ITEMS_F1:
		la t0,pos_mario
		lh t1,2(t0) # y do mario
		li t0,145
		bge t1,t0,FIM_CHECK_ITEMS # nao tem martelo abaixo do 3o andar
		li t0,129
		bge t1,t0,CHECK_ITEMS_F1_MARTELO1 # verifica martelo de baixo
		li t0,85
		bge t1,t0,FIM_CHECK_ITEMS # abaixo do 5o andar (exceto outro martelo), nao tem nada
		li t0,70
		bge t1,t0,CHECK_ITEMS_F1_MARTELO2 # verifica martelo de cima
		j FIM_CHECK_ITEMS
		CHECK_ITEMS_F1_MARTELO1:
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,66 # x < 66 ?
			beqz t0,FIM_CHECK_ITEMS # se x >= 66, nao esta na pos do martelo
			li a0,1 # martelo 1
			li a1,1 # fase 1
			j REMOVE_ITEM
		CHECK_ITEMS_F1_MARTELO2:
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,66 # x < 66 ?
			beqz t0,FIM_CHECK_ITEMS # se x >= 66, nao esta na pos do martelo
			li a0,2 # martelo 2
			li a1,1 # fase 1
			j REMOVE_ITEM
	CHECK_ITEMS_F2:
		j FIM_CHECK_ITEMS
		
	CHECK_ITEMS_F3:
		la t0,pos_mario
		lh t1,2(t0) # y do mario
		li t0,144
		bge t1,t0,FIM_CHECK_ITEMS # abaixo do 2 andar nao tem coletaveis
		li t0,124
		bge t1,t0,CHECK_ITEMS_F3_LV2 # verifica itens do segundo andar
		li t0,112
		bge t1,t0,CHECK_ITEMS_F3_MARTELO1 # verifica martelo do segundo andar
		li t0,85
		bge t1,t0,FIM_CHECK_ITEMS # 3o andar nao tem nada
		li t0,75
		bge t1,t0,CHECK_ITEMS_F3_MARTELO2 # verifica martelo do terceiro andar
		li t0,64
		blt t1,t0,CHECK_ITEMS_F3_LV4 # verifica itens do quarto andar
		j FIM_CHECK_ITEMS
		CHECK_ITEMS_F3_MARTELO1:
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,55 # x < 55?
			beqz t0,FIM_CHECK_ITEMS # se x >= 55, nao esta na posicao do martelo
			li a0,3 # item 3
			li a1,3
			j REMOVE_ITEM # remove martelo
		CHECK_ITEMS_F3_MARTELO2:
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,165 # x < 165 ?
			slti t2,t1,153 # x < 160 ?
			add t0,t0,t2 # t0 + t2
			li t2,1
			li a0,4 # item 4
			li a1,3 # fase 3
			beq t0,t2,REMOVE_ITEM
			addi t1,t1,18 # verificar vindo pela esquerda
			slti t0,t1,165
			slti t2,t1,153
			add t0,t0,t2
			li a0,4 # item 4
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM
			j FIM_CHECK_ITEMS # se nao for, so sai
		CHECK_ITEMS_F3_LV2:
			# verificar bolsa
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,116 # x < 116 ?
			slti t2,t1,105 # x < 106 ?
			add t0,t0,t2 # soma
			li a0,1 # item 1 (bolsa)
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM # se x > 106 && x < 116, pega o item e remove do mapa
			addi t1,t1,18 # verificar vindo pela esquerda
			slti t0,t1,116
			slti t2,t1,105
			add t0,t0,t2
			li a0,1 # item 1 (bolsa)
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM
			# verificar guarda chuva
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,240 # x < 243 ?
			slti t2,t1,225 # x < 225 ?
			add t0,t0,t2 # soma
			li a0,0 # item 0 (guarda chuva)
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM # se x > 225 && x < 243, pega o item e remove do mapa
			addi t1,t1,18 # verificar vindo pela esquerda
			slti t0,t1,240
			slti t2,t1,225
			add t0,t0,t2
			li a0,0 # item 0 (guarda chuva)
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM
			j FIM_CHECK_ITEMS
			
		CHECK_ITEMS_F3_LV4:
			# verificar guarda chuva
			la t0,pos_mario
			lh t1,0(t0) # x do mario
			slti t0,t1,92 # x < 92 ?
			slti t2,t1,74 # x < 74 ?
			add t0,t0,t2 # soma
			li a0,2 # item 2 (guarda chuva 4o andar)
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM # se x > 74 && x < 92, pega o item e remove do mapa
			addi t1,t1,18 # verificar vindo pela esquerda
			slti t0,t1,92
			slti t2,t1,74
			add t0,t0,t2
			li a0,2 # item 0 (guarda chuva 4o andar)
			li a1,3 # fase 3
			li t2,1
			beq t0,t2,REMOVE_ITEM
	FIM_CHECK_ITEMS:
		free_stack(ra)
		ret

# Remove um item coletavel do map e o sprite da tela
# a0 = numero do item
# a1 = fase (p/ nao ter q fazer a verificacao novamente)
REMOVE_ITEM:
	li t0,1
	beq a1,t0,RMV_ITEM_F1
	li t0,3
	beq a1,t0,RMV_ITEM_F3
	j FIM_REMOVE_ITEM
	
	RMV_ITEM_F1: # verifica e remove itens da fase 1
		li t1,1
		sll t0,t1,a0 # procura bit do item desejado
		la t1,fase1_items
		lb t1,0(t1)
		and t1,t1,t0 # pega bit do item desejado
		bnez t1,FIM_REMOVE_ITEM # se nao der 0, o item ja foi pego
		li t0,1
		beq a0,t0,RMV_F1_HAMMER1 # remove martelo 1
		li t0,2
		beq a0,t0,RMV_F1_HAMMER2 # remove martelo 2
		j FIM_REMOVE_ITEM
		
		RMV_F1_HAMMER1:
			li a0,65
			li a1,130
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,martelo_y
			call CLEAR_OBJPOS # remove sprite
			la t0,fase1_items
			lb t1,0(t0)
			ori t1,t1,0x01 # adiciona bit do martelo 1 andar
			sb t1,0(t0)
			call MARIO_SET_HAMMER
			j FIM_REMOVE_ITEM
			
		RMV_F1_HAMMER2:
			li a0,65
			li a1,73
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,martelo_y
			call CLEAR_OBJPOS # remove sprite
			la t0,fase1_items
			lb t1,0(t0)
			ori t1,t1,0x02 # adiciona bit do martelo 1 andar
			sb t1,0(t0)
			call MARIO_SET_HAMMER
			j FIM_REMOVE_ITEM
	
	RMV_ITEM_F3: # verifica e remove itens da fase 3
		# da os pontos
		li t1,1
		sll t0,t1,a0 # procura bit do item desejado
		la t1,fase3_items
		lb t1,0(t1) # carrega byte dos itens da fase
		and t1,t1,t0 # procura bit do item desejado
		bnez t1,FIM_REMOVE_ITEM # se nao der 0, o item ja foi pego
		# verifica se o item eh um martelo ou nao
		li t0,3
		beq a0,t0,RMV_F3_HAMMER1 # se for martelo, nao adiciona pontos
		li t0,4
		beq a0,t0,RMV_F3_HAMMER2 # se for martelo, nao adiciona pontos
		
		#la t0,score
		#lw t1,0(t0)
		#addi t1,t1,800
		#sw t1,0(t0)
		mv s0,a0
		li a0,800
		la t0,pos_mario
		lh a1,0(t0) # x do mario
		lh a2,2(t0) # y do mario
		addi a2,a2,18 # abaixo do y mario (p/ nao sobrepor)
		call GIVE_POINTS
		mv a0,s0
		# remove o item a1
		beqz a0,RMV_F3_ITEM1
		li t0,1
		beq a0,t0,RMV_F3_ITEM2
		li t0,2
		beq a0,t0,RMV_F3_ITEM3
		j FIM_REMOVE_ITEM
		
		RMV_F3_ITEM1:
			# remove bolsa
			li a0,225
			li a1,127
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,guardachuva
			call CLEAR_OBJPOS # remove sprite
			la t0,fase3_items
			lb t1,0(t0)
			ori t1,t1,0x01 # adiciona bit do item 0
			sb t1,0(t0) # seta como coletado
			j FIM_REMOVE_ITEM
			
		RMV_F3_ITEM2:
			# remove bolsa
			li a0,106
			li a1,133
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,bolsa
			call CLEAR_OBJPOS # remove sprite
			la t0,fase3_items
			lb t1,0(t0)
			ori t1,t1,0x02 # adiciona bit do item 1
			sb t1,0(t0) # seta como coletado
			j FIM_REMOVE_ITEM
			
		RMV_F3_ITEM3:
			# remove bolsa
			li a0,74
			li a1,47
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,guardachuva
			call CLEAR_OBJPOS # remove sprite
			la t0,fase3_items
			lb t1,0(t0)
			ori t1,t1,0x04 # adiciona bit do item 1
			sb t1,0(t0) # seta como coletado
			j FIM_REMOVE_ITEM
		RMV_F3_HAMMER1:
			li a0,50
			li a1,111
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,martelo_y
			call CLEAR_OBJPOS # remove sprite
			la t0,fase3_items
			lb t1,0(t0)
			ori t1,t1,0x08 # adiciona bit do martelo 2 andar
			sb t1,0(t0)
			call MARIO_SET_HAMMER
			j FIM_REMOVE_ITEM
		RMV_F3_HAMMER2:
			li a0,158
			li a1,72
			la a2,display
			lw a2,0(a2)
			la a3,fase_current
			la a4,martelo_y
			call CLEAR_OBJPOS # remove sprite
			la t0,fase3_items
			lb t1,0(t0)
			ori t1,t1,0x10 # adiciona bit do martelo 3 andar
			sb t1,0(t0)
			call MARIO_SET_HAMMER
	
	FIM_REMOVE_ITEM:
		j FIM_CHECK_ITEMS

# Verifica se eh necessario remove algum dos textos de pontos ganhos (se passar o tempo)		
CHECK_POINTS_TIMER:
	la t0,points_timer
	lw t1,0(t0)
	bnez t1,CHECK_POINTS_TIMER1
	j CHECK_POINTS_TIMER2
	CHECK_POINTS_TIMER1:
		gettime() # pega tempo atual
		sub t1,a0,t1 # tempo atual - tempo de inicio do texto1
		li t2,POINTS_TEXT_TIME # tempo de exibicao em ms
		li a0,0
		bge t1,t2,CLEAR_POINTS_POS
		# verifica o segundo texto
	CHECK_POINTS_TIMER2:
		lw t1,4(t0)
		beqz t1,FIM_CHECK_POINTS_TIMER # se nao tiver timer, so sai
		# se tiver
		gettime()
		sub t1,a0,t1 # tempo atual - tempo de inicio do texto2
		li t2,POINTS_TEXT_TIME # tempo de exibicao em ms
		li a0,1
		bge t1,t2,CLEAR_POINTS_POS
		j FIM_CHECK_POINTS_TIMER
	# limpa na posicao a0 = qual dos textos (0 ou 1) 24x8 pixels
	CLEAR_POINTS_POS:
		save_stack(ra)
		# se a0 = 0, pegar o points_pos 0 e 2
		# se a0 = 1, pegar o points_pos 4 e 6
		slli a0,a0,2 # 0 << 2 = 0, 1 << 2 = 4
		save_stack(a0)
		la t0,points_pos
		add t0,t0,a0
		lh a0,0(t0) # carrega x do texto
		lh a1,2(t0) # carrega y do texto
		save_stack(a0)
		save_stack(a1) # salva x e y p/ uso na prox chamada
		la t0,display
		lw a2,0(t0) # carrega display
		call GET_POSITION
		mv s0,a0 # salva end no display
		free_stack(a1)
		free_stack(a0) # retorna x e y
		la a2,fase_current
		call GET_POSITION # pega end do mapa
		mv s1,a0 # salva o end no mapa
		li s2,24 # largura do bloco
		li s3,8 # altura do bloco
		FOR_CLEAR_POINTS_POS:
			beqz s2,FOR_CLEAR_POINTS_POS1
			lb t0,0(s1) # carrega do mapa
			sb t0,0(s0) # salva no display
			addi s1,s1,1
			addi s0,s0,1
			addi s2,s2,-1
			j FOR_CLEAR_POINTS_POS
			FOR_CLEAR_POINTS_POS1:
				beqz s3,FIM_CLEAR_POINTS_POS
				li s2,24
				addi s0,s0,296
				addi s1,s1,296
				addi s3,s3,-1
				j FOR_CLEAR_POINTS_POS
		FIM_CLEAR_POINTS_POS:
			free_stack(a0)
			free_stack(ra)
			la t0,points_timer
			add t0,t0,a0 # soma com a chamada correspondente
			sw zero,0(t0) # grava 0 p/ saber q nao esta utilizando
		
	FIM_CHECK_POINTS_TIMER:
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

