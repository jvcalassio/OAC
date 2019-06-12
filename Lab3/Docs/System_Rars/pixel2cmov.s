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

.macro sleep(%miliseg)
	mv a0, %miliseg
	li a7, 10
	ecall
.end_macro


.include "macros2.s"


.eqv preto 0x00
.eqv branco 0xFF


.text

M_SetEcall(exceptionHandling)

MAIN:
	li	a0, preto
	li	a7, 148
	ecall			#preencher de preto o display

	li	t0, branco
	li	s0, 160		#s0 = coordenada x do pixel branco
	li	s1, 120		#s1 = coordenada y do pixel branco
	jal	GET_POSITION	
	sb	t0, 0(a0)	#a0 = posicao do pixel
	
	mv	s4, zero	#botao n�o foi pressionado
	
	MAINLOOP:
	
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
		lw	t1, 0(t0)
		bnez	t1, L0		#botao pressionado? fazer switch da flag do botao(s4)
		not	s4, s4		#switch botao pressionado
		L0:
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
		
		
		LEFT3:
			li	t0, 3
			sleep(t0)		#sleep de 3 ms
			
			save_stack(ra)
			jal	MOV_LEFT
			free_stack(ra)
			ret
			
		LEFT2:
			li	t0, 100
			bgeu	s2, t0, LEFT2continue	#x > 100 ? continue
			ret
			
		LEFT2continue:
			li	t0, 15
			sleep(t0)		#sleep de 15 ms
			
			save_stack(ra)
			jal	MOV_LEFT
			free_stack(ra)
			ret
			
		LEFT1:
			li	t0, 1000
			bgeu	s2, t0, LEFT1continue	#x > 1000 ? continue
			ret
		
		LEFT1continue:
			li	t0, 75
			sleep(t0)		#sleep de 75 ms
			
			save_stack(ra)
			jal	MOV_LEFT
			free_stack(ra)
			ret
		
		#impede que o pixel ultrapasse o limite a esquerda da tela
		LIMIT_LEFT:
			li	s0, 1
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret			
		
		MOV_LEFT:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posicao atual com preto
		
			addi	s0, s0, -1	#move o pixel nove posicoes para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
			
			
		RIGHT1:
			li	t0, 2500
			bgeu	s2, t0, RIGHT1continue	#x > 2500 ? continue
			ret
		
		RIGHT1continue:
			li	t0, 75
			sleep(t0)		#sleep de 75ms
			
			save_stack(ra)
			jal	MOV_RIGHT
			free_stack(ra)
			ret
		
		RIGHT2:
			li	t0, 3300
			bgeu	s2, t0, RIGHT2continue	#x > 3300? continue
			ret
		
		RIGHT2continue:
			li	t0, 15
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_RIGHT
			free_stack(ra)
			ret
		
		RIGHT3:
			li	t0, 4000
			bgeu	s2, t0, RIGHT3continue	#x>4000? continue
			ret
		
		RIGHT3continue:
			li	t0, 3
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_RIGHT
			free_stack(ra)
			ret
		
		#impede que o pixel ultrapasse o limite a direita da tela
		LIMIT_RIGHT:
			li	s0, 319
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)
			ret
		
		MOV_RIGHT:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	 GET_POSITION
			free_stack(ra)
			
			li	t0, preto
			sb	t0, 0(a0)	#preenche a pos atual com preto
			
			addi	s0, s0, 1	#move o pixel uma pos para a direita
			
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)
			ret
		
		
		UP3:	
			li	t0, 3
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_UP
			free_stack(ra)
			ret
			
		UP2:
			li	t0, 100
			bgeu	s3, t0, UP2continue	#t > 100 ? continue
			ret
			
		UP2continue:
			li	t0, 15
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_UP
			free_stack(ra)
			ret
			
		UP1:
			li	t0, 1000
			bgeu	s3, t0, UP1continue	#y > 1000 ? continue
			ret
		
		UP1continue:
			li	t0, 75
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_UP
			free_stack(ra)
			ret
		
		#impede que o pixel ultrapasse o limite superior da tela
		LIMIT_UP:
			li	s1, 1
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret			
		
		MOV_UP:
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posicao atual com preto
			
			addi	s1, s1, -1	#move o pixel nove posicoes para cima
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal 	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			ret
			
			
		DOWN1:
			li	t0, 2600
			bgeu	s3, t0, DOWN1continue	#y > 2600 ? continue
			ret
		
		DOWN1continue:
			li	t0, 75
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_DOWN
			free_stack(ra)
			ret
		
		DOWN2:
			li	t0, 3300
			bgeu	s3, t0, DOWN2continue	#y > 3300? continue
			ret
		
		DOWN2continue:
			li	t0, 15
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_DOWN
			free_stack(ra)
			ret
		
		DOWN3:
			li	t0, 4000
			bgeu	s3, t0, DOWN3continue	#y > 4000? continue
			ret
		
		DOWN3continue:
			li	t0, 3
			sleep(t0)
			
			save_stack(ra)
			jal	MOV_DOWN
			free_stack(ra)
			ret
		
		#impede que pixel ultrapasse o limite inferior da tela
		LIMIT_DOWN:
			li	s1, 239
			mv	a0, s0
			mv	a1, s1
			save_stack(ra)
			jal	GET_POSITION
			free_stack(ra)
			li	t0, branco
			sb	t0, 0(a0)
			ret
			
		MOV_DOWN:
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
			li	t0, branco
			sb	t0, 0(a0)
			ret

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
