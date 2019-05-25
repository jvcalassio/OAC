.include "./imports/macros.s"

.data
.include "./sprites/bin/fase1.s"
.include "./sprites/bin/dk_1.s"
.include "./sprites/bin/dk_2.s"
.include "./sprites/bin/dk_3.s"

.text
	li	a0, 0
	li	a1, 0
	li	a2, DISPLAY0
	la	a3, fase1
	jal	PRINT_OBJ

	mv	s0, zero
	li	s1, 100000
	li	s2, 200000
	li	s3, 300000

LOOP:
	beq	s0, zero, FRAME0
	beq	s0, s1, FRAME1
	beq	s0, s2, FRAME2
	bge	s0, s3, RESETI
	addi 	s0, s0, 1
	j 	LOOP

RESETI:
	mv	s0, zero
	j	LOOP

FRAME0:
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, fase1
	la	a4, dk_1
	jal	CLEAR_OBJPOS
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, dk_1
	jal 	PRINT_OBJ
	
	addi	s0, s0, 1

	j	LOOP

FRAME1:

	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, fase1
	la	a4, dk_2
	jal	CLEAR_OBJPOS
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, dk_2
	jal 	PRINT_OBJ
	
	addi	s0, s0, 1
	
	j	LOOP
	
FRAME2:
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, fase1
	la	a4, dk_3
	jal	CLEAR_OBJPOS
	
	li	a0, 50
	li	a1, 28
	li	a2, DISPLAY0
	la	a3, dk_3
	jal 	PRINT_OBJ
	
	addi	s0, s0, 1
	
	j	LOOP
	
li a7, 10
ecall

.include "./imports/common.s"
