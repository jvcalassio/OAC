.include "macros2.s"

.eqv preto 0x00
.eqv branco 0xFF

.text

setEcall(exceptionHandling)

MAIN:
	li	a0, preto
	li	a7, 148
	ecall

	li	t0, branco
	li	s0, 0xFF0096A0
	sw	t0, 0(s0)	#s0 = posicao do pixel

	MAINLOOP:
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
			li	t0, preto
			sw	t0, 0(s0)
			
			li	t0, AdcCH0
			lw	t1, 0(t0)		#t1 = x
			li	t0, 0x7FF		#t0 = meio
			
			div	t0, t0, t1	#t0 = meio/x >= 1
			li	t1, -1
			mul	t0, t0, t1	#t0 = meio/x * -1
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
		
		RIGHT:	
			li	t0, preto
			sw	t0, 0(s0)
			
			li	t0, AdcCH0
			lw	t1, 0(t0)	#t1 = x
			li	t0, 0x7FF		#t0 = meio
			
			div	t0, t1, t0	#t0 = x/meio >= 1
			li	t1, 1
			mul	t0, t0, t1	#t0 = meio/x * 1
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
			
		DOWN:	
			li	t0, preto
			sw	t0, 0(s0)
			li	t0, AdcCH4
			lw	t1, 0(t0)	#t1 = y
			li	t0, 0x7FF	#t0 = meio
			
			div	t0, t0, t1	#t0 = meio/y >= 1
			li	t1, 320
			mul	t0, t0, t1	#t0 = meio/y * 320
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
		
		UP:	
			li	t0, preto
			sw	t0, 0(s0)
			li	t0, AdcCH4
			lw	t1, 0(t0)	#t1 = y
			li	t0, 0x7FF	#t0 = meio
			
			div	t0, t0, t1	#t0 = meio/y >= 1
			li	t1, -320
			mul	t0, t0, t1	#t0 = meio/y * -320
			
			add	s0, s0, t0
			li	t0, branco
			sw	t0, 0(s0)
			ret
			
.include "SYSTEMv14.s"