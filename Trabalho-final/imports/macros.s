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

# move o mario +x px, +y px, usando o sprite desejado
.macro set_mario_move(%x,%y,%sprite)
	li a0,%x
	li a1,%y
	la a3,%sprite
	call SET_MARIO_MOVEMENT
.end_macro

# remove um sprite do mario nas posicoes atuais
.macro rmv_mario(%sprite)
	la a4,%sprite
	call REMOVE_MARIO
.end_macro

# pega a posicao do mario no map
.macro mario_mappos(%result)
	la t0,pos_mario
	lh t1,0(t0) # x do mario
	lh t2,2(t0) # y do mario
	
	addi t1,t1,16 # +16 para saber posicao do pe direito do mario
	addi t2,t2,20 # +16 --
	srli t1,t1,2 # x / 4 para alinhar com mapeamento
	srli t2,t2,2 # y / 4 para alinhar com mapeamento
	
	la t0,fase1_obj
	li t3,80
	mul t3,t2,t3 # (y * 80)
	add t3,t3,t1 # (y * 80) + n
	add %result,t0,t3 # endereco da posicao desejada
.end_macro

# recebe tempo atual
.macro gettime()
	addi a7,zero,30
	ecall
.end_macro

# Enderecos
.eqv DISPLAY0 0xff000000
.eqv DISPLAY1 0xff100000
.eqv CDISPLAY 0xff200604
.eqv CTRL_X_ADDR 0xFF200200
.eqv CTRL_Y_ADDR 0xFF200210
.eqv CTRL_BTN_ADDR 0xFF20021C

# Constantes de jogo
#.eqv START_MARIO_X_FASE1 84
#.eqv START_MARIO_Y_FASE1 199
.eqv START_MARIO_X_FASE1 222
.eqv START_MARIO_Y_FASE1 46
.eqv START_MARIO_X_FASE2 52
.eqv START_MARIO_Y_FASE2 185

.eqv STARTING_BONUS 5000

# Controlador USB
.eqv USB_CTRL_ADDR 0xff200122
.eqv USB_RECV_ADDR 0xff200120
.eqv USB_SEND_ADDR 0xff200121