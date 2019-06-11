.include "macros2.s"

.eqv preto 0x00
.eqv branco 0xFF

.text

M_SetEcall(exceptionHandling)

MAIN:
	li	a0, preto
	li	a7, 148
	ecall

	li	t0, branco
	li	a0, 160
	li	a1, 120
	li	a2, VGAADDRESSINI0
	jal	GET_POSITION	#a0 = end pixel
	mv	s0, a0
	
	sw	t0, 0(s0)	#s0 = posicao do pixel

	MAINLOOP:
		li	a0, 125
		li	a7, 32
		ecall

		li	t0, AdcCH0
		lw	t1, 0(t0)	#t1 = x, x entre 0x000 e 0xFFF
		
		li	t0, 0x60B	#t0 = meio - 500
		ble	t1, t0, gotoLEFT
		
		continue0:
		li	t0, 0x9F3	#t0 = meio + 500 
		bge	t1, t0, gotoRIGHT
		
		continue1:
		li	t0, AdcCH4
		lw	t1, 0(t0)	#t1 = y, y entre 0x000 e 0xFFF
		
		li	t0, 0x60B	#t0 = meio - 500
		ble	t1, t0, gotoDOWN
		
		continue2:
		li	t0, 0x9F3	#t0 = meio + 500
		bge	t1, t0, gotoUP
		
		continue3:
		j	MAINLOOP
		
		gotoLEFT:
			jal 	LEFT
			j	continue0
		
		gotoRIGHT:
			jal	RIGHT
			j	continue1
		
		gotoDOWN:
			jal	DOWN
			j 	continue2
			
		gotoUP:
			jal	UP
			j 	continue3
			
			
		LEFT:
			mv	a0, s0
			li	a1, VGAADDRESSINI0
			addi	sp, sp, -4
			sw	ra, 0(sp)
			jal	GET_XY
			lw	ra, 0(sp)
			addi	sp, sp, 4
			beq	a0, zero, MAINLOOP	#x == 0? goto main loop
			
			li	t0, preto
			sw	t0, 0(s0)
			
			li	t0, AdcCH0
			lw	t1, 0(t0)	#t1 = x
			li	t0, 0x7FF	#t0 = meio
			
			div	t0, t0, t1	#t0 = meio/x >= 1
			li	t1, -4
			mul	t0, t0, t1	#t0 = meio/x * -4
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
		
		RIGHT:	
			mv	a0, s0
			li	a1, VGAADDRESSINI0
			addi	sp, sp, -4
			sw	ra, 0(sp)
			jal	GET_XY
			lw	ra, 0(sp)
			addi	sp, sp, 4
			li	t0, 320
			beq	a0, t0, MAINLOOP	#x == 320? goto main loop
			
			li	t0, 0xFF000000
			ble	s0, t0, MAINLOOP
			li	t0, 0xFF012C00
			bge	s0, t0, MAINLOOP
			li	t0, preto
			sw	t0, 0(s0)
			
			li	t0, AdcCH0
			lw	t1, 0(t0)		#t1 = x
			li	t0, 0x7FF		#t0 = meio
			
			div	t0, t1, t0	#t0 = x/meio >= 1
			li	t1, 4
			mul	t0, t0, t1	#t0 = meio/x * 1
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
			
		DOWN:	
			mv	a0, s0
			li	a1, VGAADDRESSINI0
			addi	sp, sp, -4
			sw	ra, 0(sp)
			jal	GET_XY
			lw	ra, 0(sp)
			addi	sp, sp, 4
			li	t0, 320
			beq	a1, t0, MAINLOOP	#y == 320? goto main loop
			
			li	t0, 0xFF000000
			ble	s0, t0, MAINLOOP
			li	t0, 0xFF012C00
			bge	s0, t0, MAINLOOP
			li	t0, preto
			sw	t0, 0(s0)
			li	t0, AdcCH4
			lw	t1, 0(t0)	#t1 = y
			li	t0, 0x7FF	#t0 = meio
			
			div	t0, t0, t1	#t0 = meio/y >= 1
			li	t1, 1280
			mul	t0, t0, t1	#t0 = meio/y * 320
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
		
		UP:	
			mv	a0, s0
			li	a1, VGAADDRESSINI0
			addi	sp, sp, -4
			sw	ra, 0(sp)
			jal	GET_XY
			lw	ra, 0(sp)
			addi	sp, sp, 4
			beq	a1, zero, MAINLOOP	#y == 0? goto main loop
			
			li	t0, 0xFF000000
			ble	s0, t0, MAINLOOP
			li	t0, 0xFF012C00
			bge	s0, t0, MAINLOOP
			li	t0, preto
			sw	t0, 0(s0)
			li	t0, AdcCH4
			lw	t1, 0(t0)	#t1 = y
			li	t0, 0x7FF	#t0 = meio
			
			div	t0, t0, t1	#t0 = meio/y >= 1
			li	t1, -1280
			mul	t0, t0, t1	#t0 = meio/y * -320
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret

#a0 = x
#a1 = y
#a2 = endbase		
#a0 (retorno)
GET_POSITION:
	li t0,320
	mul t0,t0,a1 # (y * 320)
	add t0,t0,a0 # (y * 320) + x
	add a0,a2,t0 # end base + calculo acima
	jr ra,0 # retorna
	
#a0 = end
#a1 = endbase
#a0 = x (retorno)
#a1 = y (retorno)
GET_XY:
	sub a0, a0, a1
	li t0, 320
	rem a0, a0, t0
	div a1, a1, t0
	jr ra, 0 #retorna
	
			
.include "SYSTEMv14.s"
