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
	call MARIO_MAP_POS
	add %result,a1,a0
.end_macro

# recebe tempo atual
.macro gettime()
	addi a7,zero,30
	ecall
.end_macro

.macro sleep(%tempo)
	li a0,%tempo
	li a7,32
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
.eqv START_MARIO_X_FASE1 84
.eqv START_MARIO_Y_FASE1 199
.eqv START_MARIO_X_FASE2 52#235
.eqv START_MARIO_Y_FASE2 183#71
.eqv START_MARIO_X_FASE3 92
.eqv START_MARIO_Y_FASE3 199
.eqv START_MARIO_X_FASE4 38
.eqv START_MARIO_Y_FASE4 200

.eqv STARTING_BONUS 5000 # bonus inicial
.eqv POINTS_TEXT_TIME 200 # tempo de exibicao do texto de pontos adquiridos
.eqv HAMMER_TIME 16000 # tempo que o mario fica com o martelo (16s)

# Controlador USB
.eqv USB_CTRL_ADDR 0xff200122
.eqv USB_RECV_ADDR 0xff200120
.eqv USB_SEND_ADDR 0xff200121
