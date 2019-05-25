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

.eqv DISPLAY0 0xff000000
.eqv DISPLAY1 0xff100000
.eqv CDISPLAY 0xff200604