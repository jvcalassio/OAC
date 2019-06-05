.include "macros2.s"

.data
texto: .string "Isso eh apenas um teste"
.text
	la t0,exceptionHandling
	csrrw zero,5,t0
	csrrwi zero,0,1
	
	lw t0,0(zero)
	
	li a0,0x0099
	li a7,48
	ecall # limpa tela
	
	la a0,texto
	li a1,10
	li a2,10
	li a3,0x99ff
	li a7,4
	ecall
	
	li a0,5000
	li a7,32
	ecall
	
	li a0,12345678
	li a1,10
	li a2,20
	li a3,0x99ff
	li a7,1
	ecall
	
	li a7,10
	ecall
	
FIM: j FIM

.include "SYSTEMv14.s"
