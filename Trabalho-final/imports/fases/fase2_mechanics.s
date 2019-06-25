#####################################################
# Responsavel por gerenciar as mecanicas da fase 2: #
# - Elevadores 					    #
# - Mola					    #
#####################################################
.data
.include "../../sprites/bin/fase2_elevador.s"

fase2_elevator1: .half 0,0,0 # Y dos elevadores da coluna 1, fase 2, X sempre 82 
fase2_elevator2: .half 0,0,0 # Y dos elevadores da coluna 2, fase 2, X sempre 146
.text
	
INIT_FASE2_ELEVATOR1:
	save_stack(ra)
	la t0,fase2_elevator1
	li a1,200
	sh a1,0(t0)
	
	li a0,82
	la a2,display
	lw a2,0(a2) # display atual
	la a3,fase2_elevador
	call PRINT_OBJ
	
	FIM_INIT_FASE2_ELEVATOR1:
		free_stack(ra)
		ret	
	
INIT_FASE2_ELEVATOR2:
	save_stack(ra)
	la t0,fase2_elevator2
	li a1,80
	sh a1,0(t0)
	
	li a0,146
	la a2,display
	lw a2,0(a2) # display atual
	la a3,fase2_elevador
	call PRINT_OBJ
	FIM_INIT_FASE2_ELEVATOR2:
		free_stack(ra)
		ret