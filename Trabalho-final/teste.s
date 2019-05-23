.eqv botao 0xff200004
.eqv ready 0xff200000

.data
espaco: .string " "
barran: .string "\n"
.text

main:
	li t0,ready
	lw a0,0(t0)
	beqz a0,SEMBOTAO
		# tem botao
		li t0,botao
		lw a0,0(t0)
	SEMBOTAO:
		li a7,1
		ecall # printa atual, 0 = nenhuma
		
		mv t0,a0
		
		la a0,espaco
		li a7,4
		ecall # printa espaco
		
		mv a0,s11
		li a7,1
		ecall # printa ultima, 0 = nenhuma
		
		la a0,barran
		li a7,4
		ecall # printa \n
		
		mv a0,t0
		mv s11,a0 # s11 = ultimo botao
		
		j main
