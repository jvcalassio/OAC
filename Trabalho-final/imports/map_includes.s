# Includes das fases (para ficar no final)
.data
# mapas (no RARS)
#.include "../sprites/bin/fase1.s"
.include "../sprites/bin/fase2.s"
.include "../sprites/bin/fase3.s"

.text
# Recebe mapa atraves do USB na DE1
# a0 = mapa a ser recebido (1, 2, 3; 0 = nenhum mapa)
MAP_RETRIEVER:
	save_stack(ra)
	li s0,USB_CTRL_ADDR
	li s1,USB_SEND_ADDR
	li s2,USB_RECV_ADDR
	la s3,fase_current # endereco da fase atual
	li t0,1 # sinal 1 (para facilitar)
	SEND_MAP_SIGNAL: # envia sinal de leitura do mapa a0
		sb a0,0(s1)
		sb t0,0(s0) # start = 1
		sb zero,0(s0) # start = 0
		jal LOOP_MAP_BUSY # espera ate terminar de enviar o sinal
		
	# Terminado de enviar o sinal do mapa desejado, recebe os bytes do mapa um por um
	li s4,76800 # quantidade de bytes
	RECV_MAP_BYTES: beqz s4,FIM_RECV_MAP_BYTES # se recebidos todos os bytes, termina
		jal LOOP_MAP_READY # espera sinal ready acionar
		lb t1,0(s2) # le o byte recebido
		sb t1,0(s3) # salva o byte recebido no endereco correspondente do mapa
		jal LOOP_MAP_BUSY # espera sinal ready voltar para 0
		addi s3,s3,1 # pula pro prox endereco no mapa
		addi s4,s4,-1
		j RECV_MAP_BYTES
		
	FIM_RECV_MAP_BYTES:
		j FIM_MAP_RETRIEVER
		
	LOOP_MAP_BUSY: # espera enquanto o sinal de busy esta ativo
		lb t1,0(s0)
		bnez t1,LOOP_MAP_BUSY # enquanto controlador estiver ocupado 
		ret
		
	LOOP_MAP_READY: # espera enquanto o sinal de ready eh 0
		lb t1,0(s0)
		beqz t1,LOOP_MAP_READY
		ret
		
	FIM_MAP_RETRIEVER: # recebeu todo o mapa desejado, retorna
		free_stack(ra)
		ret
