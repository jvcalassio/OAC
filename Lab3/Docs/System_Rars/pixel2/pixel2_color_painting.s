# salva conteudo de REG na pilha
.macro save_stack(%reg)
	addi sp,sp,-4
	sw %reg,0(sp)
.end_macro

# libera algo da pilha e salva em REG
.macro free_stack(%reg)
	lw %reg,0(sp)
	addi sp,sp,4
.end_macro


.include "macros2.s"


.eqv preto 0x00
.eqv branco 0xFF

.data
.text

M_SetEcall(exceptionHandling)

MAIN:
	li	a0, preto
	li	a7, 148
	ecall			#preencher de preto o display

	mv	t0, s11
	li	s0, 160		#s0 = x do pixel branco
	li	s1, 120		#s1 = y do pixel branco
	jal	GET_POSITION	
	sb	t0, 0(a0)	#a0 = posicao do pixel
	
	li 	s6, 0 		# seletor de desenho (0 = false, 1 = true)
	li	s11, 0xff	# cor = branco

	MAINLOOP:
		li	a0, 50
		li	a7, 32
		ecall		#sleep de 50
		
		# gera cor
		li 	a7, 41
		ecall
		li 	t0, 256
		remu 	s11, a0, t0 # a0 = numero aleatorio mod 256 = cor
		addi	s11, s11, 1
			
		# salva posicoes anteriores, antes de setar as novas
		mv 	s4, s0 # x anterior
		mv 	s5, s1 # y anterior

		li	t0, AdcCH0
		lw	s2, 0(t0)	#s2 = x do analogico, x entre 0x000 e 0xFFF
		
		li	t0, 100
		bleu	s2, t0, gotoLEFT3	#x < 100 ? goto LEFT3
		continue0:
		li	t0, 1000
		bleu	s2, t0, gotoLEFT2	#x<1000 ? goto LEFT2
		continue1:
		li	t0, 2400
		bleu	s2, t0, gotoLEFT1	#x<2400 ? goto LEFT1
		continue2:
		li	t0, 3300
		bleu	s2, t0, gotoRIGHT1	#x<3300 ? goto RIGHT1
		continue3:
		li	t0, 4000
		bleu	s2, t0, gotoRIGHT2	#x < 4000 ? goto RIGHT2
		continue4:
		li	t0, 5000
		bleu	s2, t0, gotoRIGHT3	#x < 5000? goto RIGHT3
		
		continue5:
		li	t0, AdcCH4
		lw	s3, 0(t0)	#s3 = y do analogico, y entre 0x000 e 0xFFF
		
		li	t0, 100
		bleu	s3, t0, gotoUP3	#y < 100 ? goto UP3
		continue6:
		li	t0, 1000	
		bleu	s3, t0, gotoUP2	#y<1000 ? goto UP2
		continue7:
		li	t0, 2400
		bleu	s3, t0, gotoUP1	#y<2400 ? goto UP1
		continue8:
		li	t0, 3300
		bleu	s3, t0, gotoDOWN1	#y<3300 ? gotoDOWN1
		continue9:
		li	t0, 4000
		bleu	s3, t0, gotoDOWN2	#y < 4000 ? goto DOWN2
		continue10:
		li	t0, 5000
		bleu	s3, t0, gotoDOWN3	#y < 5000? goto DOWN3
		continue11:
		li	t0, AdcCH7
		lw 	t1, 0(t0) # carrega byte do botao
		beqz	t1, gotoTogglePainting
		continue12:
		bnez	s6, DRAW_MOVEMENT # se pintar == true, desenha movimento
		continue13:
		j MAINLOOP
		
		gotoLEFT3:
			jal	LEFT3
			j	continue0
		
		gotoLEFT2:
			jal	LEFT2
			j	continue1
		
		gotoLEFT1:
			jal	LEFT1
			j	continue2
		
		gotoRIGHT1:
			jal	RIGHT1
			j	continue3
		
		gotoRIGHT2:
			jal 	RIGHT2
			j	continue4
		
		gotoRIGHT3:
			jal	RIGHT3
			j	continue5
		
		gotoUP3:
			jal	UP3
			j	continue6
		
		gotoUP2:
			jal	UP2
			j	continue7
		
		gotoUP1:
			jal	UP1
			j	continue8
		
		gotoDOWN1:
			jal	DOWN1
			j	continue9
		
		gotoDOWN2:
			jal 	DOWN2
			j	continue10
		
		gotoDOWN3:
			jal	DOWN3
			j	continue11
			
		gotoTogglePainting:
			jal	TogglePainting
			j	continue12
		
		LEFT3:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			
			bnez	s6, LEFT3continue1 # se pintar == true, nao pinta px atual de preto
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posi��o atual com preto
			
			LEFT3continue1:
			addi	s0, s0, -9	#move o pixel nove posicoes para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
			
		LEFT2:
			li	t0, 100
			bgeu	s2, t0, LEFT2continue	#x > 100 ? continue
			ret
			
		LEFT2continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			
			bnez	s6, LEFT2continue1 # se pintar == true, nao pinta px atual de preto
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posi��o atual com preto
			
			LEFT2continue1:
			addi	s0, s0, -3	#move o pixel tres posicoes para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
			
		LEFT1:
			li	t0, 1000
			bgeu	s2, t0, LEFT1continue	#x > 1000 ? continue
			ret
		
		LEFT1continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			
			bnez	s6, LEFT1continue1 # se pintar == true, nao pinta px atual de preto
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posi��o atual com preto
			
			LEFT1continue1:
			addi	s0, s0, -1	#move o pixel uma posicao para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
		
		LIMIT_LEFT:
			li	s0, 1
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret			
		
		RIGHT1:
			li	t0, 2500
			bgeu	s2, t0, RIGHT1continue	#x > 2500 ? continue
			ret
		
		RIGHT1continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	 GET_POSITION
			free_stack(ra)
			
			bnez	s6, RIGHT1continue1 # se pintar == true, nao pinta px atual de preto
			li	t0, preto
			sb	t0, 0(a0)	#preenche a pos atual com preto
			
			RIGHT1continue1:
			addi	s0, s0, 1	#move o pixel uma pos para a direita
			
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)
			ret
		
		RIGHT2:
			li	t0, 3300
			bgeu	s2, t0, RIGHT2continue	#x > 3300? continue
			ret
		
		RIGHT2continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			
			bnez	s6, RIGHT2continue1 # se pintar == true, nao pinta px atual de preto
			li	t0, preto	
			sb	t0, 0(a0)	#preenche a pos atual com preto
			
			RIGHT2continue1:
			addi	s0,s0, 3	#move o pixel 3 pos para a direita
			
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0,0(a0)
			ret
		
		RIGHT3:
			li	t0, 4000
			bgeu	s2, t0, RIGHT3continue	#x>4000? continue
			ret
		
		RIGHT3continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			
			bnez	s6, RIGHT3continue1 # se pintar == true, nao pinta px atual de preto
			li	t0, preto	#preenche a pos atual com preto
			sb	t0,0(a0)
			
			RIGHT3continue1:
			addi	s0,s0,9		#move o pixel nove pos para a direita
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0,s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)
			ret
			
		LIMIT_RIGHT:
			li	s0, 319
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)
			ret
		
		
		
		UP3:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posi��o atual com preto
			
			addi	s1, s1, -9	#move o pixel nove posicoes para cima
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
			
		UP2:
			li	t0, 100
			bgeu	s3, t0, UP2continue	#t > 100 ? continue
			ret
			
		UP2continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posi��o atual com preto
			
			addi	s1, s1, -3	#move o pixel tres posicoes para cima
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
			
		UP1:
			li	t0, 1000
			bgeu	s3, t0, UP1continue	#y > 1000 ? continue
			ret
		
		UP1continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posi��o atual com preto
			
			addi	s1, s1, -1	#move o pixel uma pos para cima
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
		
		LIMIT_UP:
			li	s1, 1
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret			
		
		DOWN1:
			li	t0, 2600
			bgeu	s3, t0, DOWN1continue	#y > 2600 ? continue
			ret
		
		DOWN1continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)	#preenche a pos atual com preto
			
			addi	s1, s1, 1	#move o pixel uma pos para baixo
			
			li	t1, 239
			bge	s1, t1, LIMIT_DOWN
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)
			ret
		
		DOWN2:
			li	t0, 3300
			bgeu	s3, t0, DOWN2continue	#y > 3300? continue
			ret
		
		DOWN2continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)
			
			addi	s1,s1, 3	#move o pixel tres pos para baixo
			
			li	t1, 239
			bge	s1, t1, LIMIT_DOWN
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0,0(a0)
			ret
		
		DOWN3:
			li	t0, 4000
			bgeu	s3, t0, DOWN3continue	#y > 4000? continue
			ret
		
		DOWN3continue:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0,0(a0)
			
			addi	s1,s1,9		#move nove pos para baixo
			
			li	t1, 239
			bge	s1, t1, LIMIT_DOWN
			
			mv	a0,s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)
			ret
		
		#impede que pixel ultrapasee o limite inferior da tela
		LIMIT_DOWN:
			li	s1, 239
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			mv	t0, s11
			sb	t0, 0(a0)
			ret
	
		TogglePainting:
			not	s6,s6 # inverte bit de habilitacao do painting
			ret
			
		DRAW_MOVEMENT:
			bne s0,s4,DO_DRAW
			beq s1,s5,END_DRAW_MOV
			# x atual = s0
			# y atual = s1
			# x anterior = s4
			# y anterior = s5
			DO_DRAW:
			mv	a0, s0
			mv	a1, s1
			mv	a2, s4
			mv	a3, s5
			mv	a4, s11
			li	a5, 0
			li 	a7, 147
			ecall
			END_DRAW_MOV:
			j continue13
#a0 = x	
#a1 = y
#a0 (retorno)
GET_POSITION:
	li t0,320
	mul t0,t0,a1 # (y * 320)
	add t0,t0,a0 # (y * 320) + x
	li t1, VGAADDRESSINI0
	add a0,t1,t0 # end base + calculo acima
	jr ra,0 # retorna
	
#a0 = end
#a0 = x (retorno)
#a1 = y (retorno)
GET_XY:
	li t0, VGAADDRESSINI0
	sub a0, a0, t0
	li t0, 320
	rem a0, a0, t0
	div a1, a1, t0
	jr ra, 0 #retorna
	
			
.include "SYSTEMv14.s"
