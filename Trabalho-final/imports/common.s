##########################################################
#  Arquivo com funcoes e comuns a todo o jogo  
#########################################################
.text

######################################################
# Calcula o endereco, dado X e Y, no bitmap display
# a0 = X
# a1 = Y
# a2 = end base (dependendo do display atual)
# retorna posicao em a0
######################################################
GET_POSITION:
	li t0,320
	mul t0,t0,a1 # (y * 320)
	add t0,t0,a0 # (y * 320) + x
	add a0,a2,t0 # end base + calculo acima
	jr ra,0 # retorna
	
####################################################
# Imprime um objeto 18x18 no bitmap display
# a0 = X desejado
# a1 = Y desejado
# a2 = end base (dependendo do display atual)
# a3 = endereco do objeto
###################################################
PRINT_OBJ:
	save_stack(s0)
	save_stack(s1)
	save_stack(ra)
	li s0,18
	li s1,18
	jal GET_POSITION # a0 = posicao desejada para imprimir
	addi a3,a3,8
	POBJ_LOOP0: # imprime nas colunas
		beq s0,zero,POBJ_LOOP1 # se chegar no 18o pixel, pula para linha de baixo
		lb t0,0(a3) # carrega em t0 byte correspondente da imagem
		sb t0,0(a0) # imprime imagem no bitmap display
		addi s0,s0,-1 # decrementa j
		addi a3,a3,1 # passa para prox endereco
		addi a0,a0,1 # passa para prox endereco
		j POBJ_LOOP0
		
		POBJ_LOOP1: 
			beq s1,zero,FIM_POBJ # se chegar no fim das linhas, termina execucao do procedimento
			addi s1,s1,-1 # decrementa i
			addi a0,a0,302 # pula 302 pixels no target
			li s0,18 # reseta j
			j POBJ_LOOP0
			
	FIM_POBJ:
		free_stack(ra)
		free_stack(s1)
		free_stack(s0)
		ret

######################################
# Faz leitura das teclas do teclado
# returna a0 = 0 (nenhuma tecla), ou a0 = tecla
######################################		
KEYBIND:
	# verificar se alguma tecla esta sendo pressionada
	li t0,0xff200000
	lw t1,0(t0)
	beqz t1,KEYB_RET_0
		lw a0,4(t0) # retorna tecla pressionada, caso alguma esteja sendo pressionada
		ret
	
	KEYB_RET_0: # se nenhuma tecla esta sendo pressionada, retorna 0
		li a0,0
		ret
