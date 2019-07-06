NUM_NIVEL1: .word 6
NOTAS_NIVEL1: 								# a2 = 80
	.word 48,150,# pausa de 300 milisegundos
	52,350,55,150,57,150,55,150 					# tocar em looping durante a fase 1

NUM_NIVEL3: .word 3
NOTAS_NIVEL3: 								# a2 = 80
	.word 48,80,48,80,52,80 # Tocar em looping e antes de iniciar um novo looping uma pausa de 100 milisegundos
	
NUM_FASE_START: .word 8
NOTAS_FASE_START: 	
	.word 67,250,69,250,72,300,69,200,67,200,69,200,65,300,53,250 	# a2 = 80
	
NUM_FASE_CLEAR: .word 11
NOTAS_FASE_CLEAR: 							# a2 = 80
	.word 60,300,60,300,60,400,67,150,69,150,71,200,67,300,67,150,69,150,71,200,67,300

NUM_MARIOMORRE: .word 16
NOTAS_MARIOMORRE: 	
	.word 58,50,65,50,62,50,68,50,60,50,67,50,59,100,66,100,58,100,65,100,56,100,63,100, 	# a2 = 74		
	64,200,67,300,55,300,60,300 					# a2 = 80
	
NUM_PASSOS: .word 2
NOTAS_PASSOS: 								# a2 = 120
	.word 62,10,69,10 						# Tocar em looping
	
NUM_MARTELO: .word 18
NOTAS_MARTELO: 	
	.word 60,200,60,200,60,200,60,200,60,200,64,200,60,200,64,200,60,200,		# a2 = 80
	64,200,64,200,64,200,64,200,64,200,67,200,64,200,67,200,64,200,			# Tocar em looping
