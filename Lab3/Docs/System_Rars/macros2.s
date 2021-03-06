######### Verifica se eh a DE1-SoC ###############
.macro DE1(%salto)
	li tp, 0x10008000			# carrega tp = 0x10008000
	bne gp,tp,%salto			# Na DE1 gp = 0 ! Nao tem segmento .extern
.end_macro

######### Seta o endereco UTVEC ###############
.macro M_SetEcall(%label)
 	la t6,%label		# carrega em t6 o endereco base das rotinas do sistema ECALL
 	csrrw zero,5,t6 	# seta utvec (reg 5) para o endereco t6
 	csrrsi zero,0,1 	# seta o bit de habilitacao de interrupcao em ustatus (reg 0)
.end_macro
 
#definicao do mapa de enderecamento de MMIO
.eqv VGAADDRESSINI0     0xFF000000
.eqv VGAADDRESSFIM0     0xFF012C00
.eqv VGAADDRESSINI1     0xFF100000
.eqv VGAADDRESSFIM1     0xFF112C00 
.eqv NUMLINHAS          240
.eqv NUMCOLUNAS         320
.eqv VGAFRAMESELECT	0xFF200604

.eqv KDMMIO_Ctrl	0xFF200000
.eqv KDMMIO_Data	0xFF200004

.eqv Buffer0Teclado     0xFF200100
.eqv Buffer1Teclado     0xFF200104

.eqv TecladoxMouse      0xFF200110
.eqv BufferMouse        0xFF200114

.eqv AudioBase		0xFF200160
.eqv AudioINL           0xFF200160
.eqv AudioINR           0xFF200164
.eqv AudioOUTL          0xFF200168
.eqv AudioOUTR          0xFF20016C
.eqv AudioCTRL1         0xFF200170
.eqv AudioCTRL2         0xFF200174

# Sintetizador - 2015/1
.eqv NoteData           0xFF200178
.eqv NoteClock          0xFF20017C
.eqv NoteMelody         0xFF200180
.eqv MusicTempo         0xFF200184
.eqv MusicAddress       0xFF200188


.eqv IrDA_CTRL 		0xFF20 0500	
.eqv IrDA_RX 		0xFF20 0504
.eqv IrDA_TX		0xFF20 0508

.eqv STOPWATCH		0xFF200510

.eqv LFSR		0xFF200514

.eqv KeyMap0		0xFF200520
.eqv KeyMap1		0xFF200524
.eqv KeyMap2		0xFF200528
.eqv KeyMap3		0xFF20052C 

# ADC Controller
.eqv AdcCH0 		0xFF200200
.eqv AdcCH1		0xFF200204
.eqv AdcCH2 		0xFF200208
.eqv AdcCH3 		0xFF20020C
.eqv AdcCH4 		0xFF200210
.eqv AdcCH5 		0xFF200214
.eqv AdcCH6		0xFF200218
.eqv AdcCH7 		0xFF20021C
