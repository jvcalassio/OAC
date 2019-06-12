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
	li	s0, 160		#s0 = x do pixel branco
	li	s1, 120		#s1 = y do pixel branco
	jal	GET_POSITION	
	sb	t0, 0(a0)	#a0 = posicao do pixel

	MAINLOOP:
		li	a0, 100
		li	a7, 32
		ecall		#sleep de 125ms

		li	t0, AdcCH0
		lw	s2, 0(t0)	#s2 = x, x entre 0x000 e 0xFFF
		
		li	t0, 100
		bleu	s2, t0, LEFT3	#x < 100 ? goto LEFT3
		
		li	t0, 1000
		bleu	s2, t0, LEFT2	#x<1000 ? goto LEFT2
		
		li	t0, 2400
		bleu	s2, t0, LEFT1	#x<2400 ? goto LEFT1
		
		li	t0, 3300
		bleu	s2, t0, RIGHT1	#x<3300 ? goto RIGHT1
		
		li	t0, 4000
		bleu	s2, t0, RIGHT2	#x < 4000 ? goto RIGHT2
		
		li	t0, 5000
		bleu	s2, t0, RIGHT3	#x < 5000? goto RIGHT3
		
		
		li	t0, AdcCH4
		lw	s2, 0(t0)	#s2 = y, y entre 0x000 e 0xFFF
		
		li	t0, 100
		bleu	s2, t0, DOWN3	#y < 100 ? goto DOWN3
		
		li	t0, 1000
		bleu	s2, t0, DOWN2	#y<1000 ? goto DOWN2
		
		li	t0, 2400
		bleu	s2, t0, DOWN1	#y<2400 ? goto DOWN1
		
		li	t0, 3300
		bleu	s2, t0, UP1	#x<3300 ? goto UP1
		
		li	t0, 4000
		bleu	s2, t0, UP2	#x < 4000 ? goto UP2
		
		li	t0, 5000
		bleu	s2, t0, UP3	#x < 5000? goto UP3
		
		j MAINLOOP
		
		LEFT3:
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posição atual com preto
			
			addi	s0, s0, -9	#move o pixel tres posicoes para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j	 MAINLOOP
			
		LEFT2:
			li	t0, 100
			bgeu	s2, t0, LEFT2continue	#x > 100 ? continue
			j	 MAINLOOP
			
		LEFT2continue:
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posição atual com preto
			
			addi	s0, s0, -3	#move o pixel dois posicoes para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j 	MAINLOOP
			
		LEFT1:
			li	t0, 1000
			bgeu	s2, t0, LEFT1continue	#x > 1000 ? continue
			j	 MAINLOOP
		
		LEFT1continue:
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posição atual com preto
			
			addi	s0, s0, -1	#move o pixel tres posicoes para a esquerda
			
			li	t1, 1
			ble	s0, t1, LIMIT_LEFT
			
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j 	MAINLOOP
		
		LIMIT_LEFT:
			li	s0, 1
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j 	MAINLOOP			
		
		RIGHT1:
			li	t0, 2500
			bgeu	s2, t0, RIGHT1continue	#x > 2500 ? continue
			j	MAINLOOP
		
		RIGHT1continue:
			mv	a0, s0
			mv	a1, s1
			jal	 GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a pos atual com preto
			
			addi	s0, s0, 1
			
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)
			j	MAINLOOP
		
		RIGHT2:
			li	t0, 3300
			bgeu	s2, t0, RIGHT2continue	#x > 3000? continue
			j	MAINLOOP
		
		RIGHT2continue:
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)
			
			addi	s0,s0, 3
			
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0,0(a0)
			j	MAINLOOP
		
		RIGHT3:
			li	t0, 4000
			bgeu	s2, t0, RIGHT3continue
			j	MAINLOOP
		
		RIGHT3continue:
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, preto
			sb	t0,0(a0)
			
			addi	s0,s0,9
			li	t1, 319
			bge	s0, t1, LIMIT_RIGHT
			
			mv	a0,s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)
			j	MAINLOOP
			
		LIMIT_RIGHT:
			li	s0, 319
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)
			j	MAINLOOP
		
		
		
		DOWN3:
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posição atual com preto
			
			addi	s1, s1, 9	#move o pixel tres posicoes para baixo
			
			li	t1, 239
			bge	s1, t1, LIMIT_DOWN
			
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j	 MAINLOOP
			
		DOWN2:
			li	t0, 100
			bgeu	s2, t0, DOWN2continue	#x > 100 ? continue
			j	 MAINLOOP
			
		DOWN2continue:
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posição atual com preto
			
			addi	s1, s1, 3	#move o pixel dois posicoes para a esquerda
			
			li	t1, 239
			bge	s1, t1, LIMIT_DOWN
			
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j 	MAINLOOP
			
		DOWN1:
			li	t0, 1000
			bgeu	s2, t0, DOWN1continue	#x > 1000 ? continue
			j	 MAINLOOP
		
		DOWN1continue:
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a posição atual com preto
			
			addi	s1, s1, 1	#move o pixel tres posicoes para a esquerda
			
			li	t1, 239
			bge	s1, t1, LIMIT_DOWN
			
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j 	MAINLOOP
		
		LIMIT_DOWN:
			li	s1, 239
			mv	a0, s0
			mv	a1, s1
			jal 	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)	#preenche a nova posicao com branco
			j 	MAINLOOP			
		
		UP1:
			li	t0, 2500
			bgeu	s2, t0, UP1continue	#x > 2500 ? continue
			j	MAINLOOP
		
		UP1continue:
			mv	a0, s0
			mv	a1, s1
			jal	 GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)	#preenche a pos atual com preto
			
			addi	s1, s1, -1
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)
			j	MAINLOOP
		
		UP2:
			li	t0, 3300
			bgeu	s2, t0, UP2continue	#x > 3000? continue
			j	MAINLOOP
		
		UP2continue:
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, preto
			sb	t0, 0(a0)
			
			addi	s1,s1, -3
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0,0(a0)
			j	MAINLOOP
		
		UP3:
			li	t0, 4000
			bgeu	s2, t0, UP3continue
			j	MAINLOOP
		
		UP3continue:
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, preto
			sb	t0,0(a0)
			
			addi	s1,s1,-9
			
			li	t1, 1
			ble	s1, t1, LIMIT_UP
			
			mv	a0,s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)
			j	MAINLOOP
	
		LIMIT_UP:
			li	s1, 1
			mv	a0, s0
			mv	a1, s1
			jal	GET_POSITION
			li	t0, branco
			sb	t0, 0(a0)
			j	MAINLOOP

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
