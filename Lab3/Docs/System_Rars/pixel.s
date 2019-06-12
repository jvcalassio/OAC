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
	li	s0, 0xFF0096A0
	sb	t0, 0(s0)	#s0 = posicao do pixel

	MAINLOOP:
		li	t0, 0xFF200000
		
		lw	t1, 0(t0)
		bnez	t1, MOV
		j MAINLOOP
		
		MOV:
			li	t0, 0xFF200004
			lw	t1, 0(t0)
			
			li	t2, 119
			beq	t1, t2, gotoUP
			
			continue0:
			li	t2, 115
			beq	t1, t2, gotoDOWN
			
			continue1:
			li	t2, 97
			beq	t1, t2, gotoLEFT
			
			continue2:
			li	t2, 100
			beq	t1, t2, gotoRIGHT
			
			continue3:
			j	MAINLOOP
			
			
			gotoUP:	
				jal	UP
				j	continue0
			
			gotoDOWN:
				jal	DOWN
				j	continue1
			
			gotoLEFT:
				jal	LEFT
				j	continue2
			
			gotoRIGHT:
				jal	 RIGHT
				j	continue3 
			
			
			UP:
				li	t0, preto
				sb	t0, 0(s0)
				
				addi	s0, s0, -1280
				li	t0, branco
				sb	t0, 0(s0)
				ret
				
			DOWN:
				li	t0, preto
				sb	t0, 0(s0)
				
				addi	s0, s0, 1280
				li	t0, branco
				sb	t0, 0(s0)
				ret
				
			LEFT:	
				li	t0, preto
				sb	t0, 0(s0)
				
				addi	s0, s0, -4
				li	t0, branco
				sb	t0, 0(s0)
				ret
								
			RIGHT:	
				li	t0, preto
				sb	t0, 0(s0)
				
				addi	s0, s0, 4
				li	t0, branco
				sb	t0, 0(s0)
				ret
				
				
EXIT:	li	a7, 10
	ecall


.include "SYSTEMv14.s"
