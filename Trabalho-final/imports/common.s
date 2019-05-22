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
# Imprime um objeto no bitmap display
# a0 = X desejado
# a1 = Y desejado
# a2 = end base (dependendo do display atual)
# a3 = endereco do objeto
###################################################
PRINT_OBJ:
	save_stack(s0)
	save_stack(s1)
	save_stack(s2)
	save_stack(ra)
	lw s0,0(a3) # carrega X do objeto
	lw s1,4(a3) # carrega Y do objeto
	mv s2,a3 # salva endereco inicial do objeto
	jal GET_POSITION # a0 = posicao inicial desejada para imprimir
	addi a3,a3,8 # pula enderecos do tamanho do objeto
	POBJ_LOOP0: # imprime nas colunas
		beq s0,zero,POBJ_LOOP1 # se chegar no (max X)esimo pixel, pula para linha de baixo
		lb t0,0(a3) # carrega em t0 byte correspondente da imagem
		sb t0,0(a0) # imprime imagem no bitmap display
		addi s0,s0,-1 # decrementa j
		addi a3,a3,1 # passa para prox endereco
		addi a0,a0,1 # passa para prox endereco
		j POBJ_LOOP0
		
		POBJ_LOOP1: 
			beq s1,zero,FIM_POBJ # se chegar no fim das linhas, termina execucao do procedimento
			addi s1,s1,-1 # decrementa i
			lw t0,0(s2)
			li t1,320
			sub t1,t1,t0
			add a0,a0,t1 # pula (320 - x) pixels no endereco do bitmap, para prox impressao
			mv s0,t0 # reseta j
			j POBJ_LOOP0
			
	FIM_POBJ:
		free_stack(ra)
		free_stack(s2)
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

##############################################
# Limpa 18 x 18px na posicao desejada
# Utilizado para desenhar objetos/mario,
# sem apagar o cenario
# Basicamenta, a funcao coloca o que estava
# no cenario, na posicao especificada
# a0 = x
# a1 = y
# a2 = end base (dependendo do display)
# a3 = end mapa atual
##############################################
CLEAR_OBJPOS:
	save_stack(s0)
	save_stack(s1)
	save_stack(ra) # salva ra e salvos na pilha
	
	mv s0,a0 # salva a0
	jal GET_POSITION # retorna endereco para imprimir no display
	mv s1,a0 # salva endereco no display em s1
	
	mv a0,s0 # retorna valor de a0 original
	mv a2,a3 # seta novo endereco para calcular
	addi a2,a2,8 # pula as duas words que especificam o tamanho
	jal GET_POSITION # retorna endereco no mapa, para imprimir
	mv a3,a0 # salva endereco no mapa em s2
	mv a0,s1
	
	li s0,18 # i, para iterar no Y
	li s1,18
	
	PCOP_LOOP0: # imprime nas colunas
		beq s0,zero,PCOP_LOOP1 # se chegar no 18o pixel, pula para linha de baixo
		lb t0,0(a3) # carrega em t0 byte correspondente da imagem
		sb t0,0(a0) # imprime imagem no bitmap display
		addi s0,s0,-1 # decrementa j
		addi a3,a3,1 # passa para prox endereco
		addi a0,a0,1 # passa para prox endereco
		j PCOP_LOOP0
		
		PCOP_LOOP1: 
			beq s1,zero,FIM_PCOP # se chegar no fim das linhas, termina execucao do procedimento
			addi s1,s1,-1 # decrementa i
			addi a0,a0,302 # pula 302 pixels no target
			addi a3,a3,302
			li s0,18 # reseta j
			j PCOP_LOOP0
			
	FIM_PCOP:
		free_stack(ra)
		free_stack(s1)
		free_stack(s0)
		ret
