.data
	.include "Sobradinho.s"

.text
	la a0, Sobradinho #carrega endereço da bandeira
	li a1, 0xFF000000 #carrega endereço inicial da memoria VGA, frame 0
	
	lw t0, 0(a0) #carrega numero colunas em t0
	lw t1, 4(a0) #carrega numero linhas em t1
	
	li s0, 0 #contador, i=0
	addi a0, a0, 8 #move ponteiro imagem (8 bytes = depois do num. linhas e num. colunas) 
	
	
	
FOR1:
	beq s0, t0, FRAME1 #i == num colunas? carrega imagem no frame 1 : continua printando img frame 0
	addi s0, s0, 1	# i++
	li s2, 0 #contador j = 0
		
	FOR1_INTERNO:	
		beq s2, t1, FOR1 #j == num colunas? continua : volta loop anterior
		lw t5, 0(a0) #carrega do endereço da imagem
		sw t5, 0(a1) #salva no endereço da memoria VGA
		addi a0, a0, 4 #anda ponteiro imagem
		addi a1, a1, 4 #anda ponteiro video
		addi s2, s2, 1 #j++
		j FOR1_INTERNO	#volta para inicio do loop
		
		
FRAME1:
	la a0, Sobradinho
	li a1, 0xFF100000 #carrega endereço memoria VGA, frame 1
	
	lw t0, 0(a0)
	lw t1, 4(a0)
	
	addi a0, a0, 8
	li s0, 0
	
	#Funcionamento abaixo é análogo ao FOR1 e FOR1_interno
			
FOR2:
	beq s0, t0, FIM #i == num colunas? fim programa : continua loop
	addi s0, s0, 1	
	li s2, 0
		
	FOR2_INTERNO:	
		beq s2, t1, FOR2
		lw t5, 0(a0)
		sw t5, 0(a1)
		addi a0, a0, 4
		addi a1, a1, 4
		addi s2, s2, 1
		j FOR2_INTERNO
				
FIM: 
	li a7, 10
	ecall
