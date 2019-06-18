.data
# numero de Notas a tocar
NUM_MARIOMORRE: .word 16
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS_MARIOMORRE: 	
	58,0,65,0,62,0,68,0,60,0,67,0,59,0,66,0,58,0,65,0,56,0,63,0, 	# a2 = 74		
	64,300,67,300,55,300,60,300 					# a2 = 80
	
# numero de Notas a tocar	
NUM_NIVEL1: .word 6
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS_NIVEL1: 								# a2 = 80
	48,300, # pausa de 300 milisegundos
	52,300,55,300,57,300,55,300 # tocar em looping durante o jogo

# numero de Notas a tocar
NUM_NIVEL3: .word 3
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS_NIVEL3: 								# a2 = 80
	48,80,48,80,52,80, # Tocar em looping e antes de iniciar um novo looping uma pausa de 100 milisegundos
	
# numero de Notas a tocar
NUM_FASE_START: .word 8
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS_FASE_START: 	
	67,300,69,300,72,300,69,300,67,300,69,300,65,350,53,300 	# a2 = 80
	
# numero de Notas a tocar
NUM_FASE_CLEAR: .word 11
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS_FASE_CLEAR: 							# a2 = 80
	60,350,60,350,60,450,67,300,69,300,71,300,67,450,67,300,69,300,71,300,67,450 
	
# numero de Notas a tocar
NUM_PASSOS: .word 4
# lista de nota,duração,nota,duração,nota,duração,...
NOTAS_PASSOS: 								# a2 = 120
	62,30,65,30,62,30,69,30, # Tocar em looping
