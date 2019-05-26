.data
.include "../sprites/bin/dk_1.s"
.include "../sprites/bin/dk_2.s"
.include "../sprites/bin/dk_3.s"

.text
INIT_DK_DANCA:
	mv	s8, zero
	li	s9, 10000
	li	s10, 20000
	li	s11, 30000
	ret

DK_DANCA_LOOP:
	beq	s8, zero, DK_DANCA_FRAME0
	beq	s8, s9, DK_DANCA_FRAME1
	beq	s8, s10, DK_DANCA_FRAME2
	bge	s8, s11, DK_DANCA_RESET
	addi 	s8, s8, 1
	tail 	MAINLOOP

DK_DANCA_RESET:
	mv	s8, zero
	tail	MAINLOOP

DK_DANCA_FRAME0:
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, fase1
	la	a4, dk_1
	call	CLEAR_OBJPOS
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, dk_1
	call 	PRINT_OBJ
	
	addi	s8, s8, 1

	tail	MAINLOOP

DK_DANCA_FRAME1:

	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, fase1
	la	a4, dk_2
	call	CLEAR_OBJPOS
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, dk_2
	call 	PRINT_OBJ
	
	addi	s8, s8, 1
	
	tail	MAINLOOP
	
DK_DANCA_FRAME2:
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, fase1
	la	a4, dk_3
	call	CLEAR_OBJPOS
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, dk_3
	call 	PRINT_OBJ
	
	addi	s8, s8, 1
	
	tail	MAINLOOP
