#####################################################
# Responsavel por gerenciar as mecanicas da fase 2: #
# - Elevadores 					    #
# - Mola					    #
#####################################################
.data
.include "../../sprites/bin/fase2_elevador.s"

# Y iniciais: 200, 160, 120
fase2_elevator1: .half 0,0,0 # Y dos elevadores da coluna 1, fase 2; X sempre 82
# Y iniciais: 80, 120, 160
fase2_elevator2: .half 0,0,0 # Y dos elevadores da coluna 2, fase 2; X sempre 146
.text
	
# obs:
#	o px logo abaixo do pe do mario nos elevadores eh apagado por causa do mapa
#	corrigir isso printando os elevadores diretamente no fase current
# 	quando se mover, printar tanto no display quanto no fase current
# 	ao setar a fase 2 (caso reset), fazer com que todas as posicoes assumam o valor certo

INIT_FASE2_ELEVATORS:
	save_stack(ra)
	# primeira coluna
	# primeiro elevador (mais abaixo)
	la t0,fase2_elevator1
	li a1,200
	sh a1,0(t0)
	li a0,82
	#la a2,display
	#lw a2,0(a2) # display atual
	la a2,fase_current
	la a3,fase2_elevador
	call PRINT_OBJ
	# segundo elevador
	la t0,fase2_elevator1
	li a1,160
	sh a1,2(t0)
	li a0,82
	#la a2,display
	#lw a2,0(a2) # display atual
	la a2,fase_current
	la a3,fase2_elevador
	call PRINT_OBJ
	# terceiro elevador
	la t0,fase2_elevator1
	li a1,120
	sh a1,4(t0)
	li a0,82
	#la a2,display
	#lw a2,0(a2) # display atual
	la a2,fase_current
	la a3,fase2_elevador
	call PRINT_OBJ
	
	# segunda coluna
	# primeiro elevador (mais acima)
	la t0,fase2_elevator2
	li a1,80
	sh a1,0(t0)
	li a0,146
	#la a2,display
	#lw a2,0(a2) # display atual
	la a2,fase_current
	la a3,fase2_elevador
	call PRINT_OBJ
	# segundo elevador 
	la t0,fase2_elevator2
	li a1,120
	sh a1,2(t0)
	li a0,146
	#la a2,display
	#lw a2,0(a2) # display atual
	la a2,fase_current
	la a3,fase2_elevador
	call PRINT_OBJ
	# terceiro elevador 
	la t0,fase2_elevator2
	li a1,160
	sh a1,4(t0)
	li a0,146
	#la a2,display
	#lw a2,0(a2) # display atual
	la a2,fase_current
	la a3,fase2_elevador
	call PRINT_OBJ
	FIM_INIT_FASE2_ELEVATORS:
		free_stack(ra)
		ret
		
# faz o movimento dos elevadores
F2_ELEVATORS_UPDATE:
	save_stack(ra)
	la t0,fase
	lb t1,0(t0)
	li t0,2
	bne t0,t1,FIM_F2_ELEVATORS_UPDATE # se nao for fase 2, nao faz nada
	# elevadores da primeira coluna
	la s0,fase2_elevator1
	li s1,3
	COL1_F2_ELEVATORS_UPDATE:
		beqz s1,FIM_COL1_F2_ELEVATORS_UPDATE # terminada a primeira coluna, faz a segunda
		li a0,82 # x do elevador (constante)
		lh a1,0(s0) # carrega y do elevador
		jal F2_REMOVE_ELEVATOR # remove elevador na posicao atual
		li a0,82
		lh a1,0(s0)
		addi a1,a1,-1  #sobe 1 posicao
		li t0,80
		beq a1,t0,RESET_C1F2EU
		j CONT_C1F2EU
		RESET_C1F2EU:
		li a1,200
		CONT_C1F2EU:
		sh a1,0(s0)
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase2_elevador
		call PRINT_OBJ # printa no display
		li a0,82
		lh a1,0(s0)
		la a2,fase_current
		la a3,fase2_elevador
		call PRINT_OBJ # printa no mapa da fase
		addi s0,s0,2
		addi s1,s1,-1
		j COL1_F2_ELEVATORS_UPDATE
		
	FIM_COL1_F2_ELEVATORS_UPDATE:
	#j FIM_F2_ELEVATORS_UPDATE
	la s0,fase2_elevator2
	li s1,3
	COL2_F2_ELEVATORS_UPDATE:
		beqz s1,FIM_F2_ELEVATORS_UPDATE
		li a0,146 # x do elevador (constante)
		lh a1,0(s0) # carrega y do elevador
		jal F2_REMOVE_ELEVATOR # remove elevador na posicao atual
		li a0,146
		lh a1,0(s0)
		addi a1,a1,1 # desce 1 posicoes
		li t0,200
		beq a1,t0,RESET_C2F2EU
		j CONT_C2F2EU
		RESET_C2F2EU:
		li a1,80
		CONT_C2F2EU:
		sh a1,0(s0)
		la a2,display
		lw a2,0(a2) # display atual
		la a3,fase2_elevador
		call PRINT_OBJ # printa no display
		li a0,146
		lh a1,0(s0)
		la a2,fase_current
		la a3,fase2_elevador
		call PRINT_OBJ # printa no mapa da fase
		addi s0,s0,2
		addi s1,s1,-1
		j COL2_F2_ELEVATORS_UPDATE
		
	FIM_F2_ELEVATORS_UPDATE:
		free_stack(ra)
		ret
	
# Remove um elevador na posicao
# a0 = x
# a1 = y	
F2_REMOVE_ELEVATOR:
	save_stack(ra)
	save_stack(s0)
	save_stack(a0)
	save_stack(a1)
	la a2,display
	lw a2,0(a2)
	call GET_POSITION # pega posicao do bloco no display
	# a0 = posicao do bloco no display 
	mv s0,a0 # posicao do bloco no display
	free_stack(a1)
	free_stack(a0)
	la a2,fase_current
	call GET_POSITION
	# a0 = posicao do bloco no mapa
	mv a1,s0
	li t0,16 # altura do bloco
	li t1,7 # largura do bloco
	FOR_F2_REMOVE_ELEVATOR:
		beqz t0,FOR_F2_REMOVE_ELEVATOR0
		li t2,8
		beq t0,t2,PAINT_F2RE_RED
		sb zero,0(a0)
		sb zero,0(a1)
		j PAINT_F2RE_CONT
		PAINT_F2RE_RED:
		li t2,5
		sb t2,-1(a0)
		sb t2,-1(a1)
		sb t2,0(a0)
		sb t2,0(a1)
		PAINT_F2RE_CONT:
		addi a0,a0,1 # passa p/ proximo endereco no display
		addi a1,a1,1 # passa p/ proximo endereco no mapa
		addi t0,t0,-1 # decrementa contador
		j FOR_F2_REMOVE_ELEVATOR
		FOR_F2_REMOVE_ELEVATOR0:
			beqz t1,FIM_F2_REMOVE_ELEVATOR
			li t0,16 # devolve valor do contador j
			addi a0,a0,304 # vai p/ posicao correta do display
			addi a1,a1,304 # vai p/ posicao correta do mapa
			addi t1,t1,-1 # decrementa contador
			j FOR_F2_REMOVE_ELEVATOR
	FIM_F2_REMOVE_ELEVATOR:
		free_stack(s0)
		free_stack(ra)
		ret
		
# Manuseia os foguinhos da fase 2
FASE2_START_FOGUINHOS:
	save_stack(ra)
	la t0,fogo1
	li a0,110 # x fogo 1
	li a1,160 # y fogo 1
	sh a0,0(t0)
	sh a1,2(t0) # salva variavel
	la a2,display
	lw a2,0(a2) # display atual
	la a3,foguinho_p1
	call PRINT_OBJ
	la t0,fogo1
	li t1,64 # sobe 64
	sh t1,6(t0) # salva contador vertical inicial
	
	la t0,fogo2
	li a0,245 # x fogo 1
	li a1,104 # y fogo 1
	sh a0,0(t0)
	sh a1,2(t0) # salva variavel
	la a2,display
	lw a2,0(a2) # display atual
	la a3,foguinho_p1
	call PRINT_OBJ
	la t0,fogo2
	li t1,-8 # anda 8 pra direita
	sh t1,4(t0)
	li t1,40 # sobe 40
	sh t1,6(t0) # salva contador vertical inicial
	
	FIM_FASE2_FOGUINHOS:
		free_stack(ra)
		ret
