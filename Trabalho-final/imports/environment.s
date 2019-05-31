.data
.include "../sprites/bin/dk_1.s"
.include "../sprites/bin/dk_2.s"
var_dk: .word 0,0,0,0


.text
INIT_DK_DANCA:
	
	la	t4, var_dk
	sw	zero, 0(t4)	#var_i = 0
	li	t0, 10000
	sw	t0, 4(t4)	#var0 = 10000
	li	t0, 20000
	sw	t0, 8(t4)	#var1 = 20000
	li	t0, 30000
	sw	t0, 12(t4)	#var_2 = 30000
	ret

DK_DANCA_LOOP:
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	beq	t0, zero, DK_DANCA_FRAME0 #i==0? goto FRAME0
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	lw	t1, 4(t4)	#10000
	beq	t0, t1, DK_DANCA_FRAME1	#i==10000? goto FRAME1
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	lw	t2, 8(t4)	#20000
	beq	t0, t2, DK_DANCA_FRAME2	#i==20000? goto FRAME2
	
	la	t4, var_dk
	lw	t0, 0(t4)	#i
	lw	t3, 12(t4)	#30000
	bge	t0, t3, DK_DANCA_RESET	#i>=30000? goto RESETi
	
	la	t4, var_dk
	lw	t0, 0(t4)
	addi 	t0, t0, 1	#i++
	sw	t0, 0(t4)
	
	tail 	MAINLOOP

DK_DANCA_RESET:
	la	t4, var_dk
	sw	zero, 0(t4)	#i=0
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
	
	la	t4, var_dk
	lw	t0, 0(t4)
	addi 	t0, t0, 1	#i++
	sw	t0, 0(t4)

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
	
	la	t4, var_dk
	lw	t0, 0(t4)
	addi 	t0, t0, 1	#i++
	sw	t0, 0(t4)
	
	tail	MAINLOOP
	
DK_DANCA_FRAME2:
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
	call 	PRINT_OBJ_MIRROR
	
	la	t4, var_dk
	lw	t0, 0(t4)
	addi 	t0, t0, 1	#i++
	sw	t0, 0(t4)
	
	tail	MAINLOOP
