NUM_NIVEL1: .word 6
NOTAS_NIVEL1: 								# a2 = 80
	.word 48,300, # pausa de 300 milisegundos
	52,300,55,300,57,300,55,300 # tocar em looping durante o jogo

NUM_NIVEL3: .word 3
NOTAS_NIVEL3: 								# a2 = 80
	.word 48,80,48,80,52,80 # Tocar em looping e antes de iniciar um novo looping uma pausa de 100 milisegundos
	
NUM_FASE_START: .word 8
NOTAS_FASE_START: 	
	.word 67,300,69,300,72,300,69,300,67,300,69,300,65,350,53,300 	# a2 = 80
	
NUM_FASE_CLEAR: .word 11
NOTAS_FASE_CLEAR: 							# a2 = 80
	.word 60,350,60,350,60,450,67,300,69,300,71,300,67,450,67,300,69,300,71,300,67,450

NUM_MARIOMORRE: .word 16
NOTAS_MARIOMORRE: 	
	.word 58,100,65,100,62,100,68,100,60,100,67,100,59,100,66,100,58,100,65,100,56,100,63,100, 	# a2 = 74		
	64,300,67,300,55,300,60,300 					# a2 = 80
	
NUM_PASSOS: .word 4
NOTAS_PASSOS: 								# a2 = 120
	.word 62,30,65,30,62,30,69,30 # Tocar em looping
