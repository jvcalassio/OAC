#include <bits/stdc++.h>

using namespace std;

/*

Esquemas do mapa:
1 byte = 0000_0000

4 lsb = relativos as propriedades do cenario

0000 = ar					= .
0001 = chao					= C
0010 = degrau p esquerda	= A 
0011 = degrau p direita		= D
0100 = escada 				= E
0101 = fim escada 			= T
1000 = parede				= P

0000_0100
1111_1011

4 msb = relativos a alguns coletaveis

0000 = nada
0001 = chao quebradico (fase 3)
0010 = item bonus (500 pts)
0100 = martelo
1000 = vitoria


*/
int main(){
	printf(".data\n");
	printf("map_positions: .byte ");
	//char mapa[81] = "PPPPPPPPPPPPPPPPPPPPP.........EE........................EE.........PPPPPPPPPPPPP";
	char mapa[81] = "PPPPPPPPPPPPPPPPCCCCCCCCCCCCCCCCCCCCCCCCCDCCCCCDCCCCCDCCCCCDCCCCCDCCCCPPPPPPPPPP";
	int i = 0;
	while(mapa[i]!='\0'){
		if(mapa[i] == 'P'){
			printf("0x08,");
		}
		if(mapa[i] == 'C'){
			printf("0x01,");
		}
		if(mapa[i] == 'D'){
			printf("0x02,");
		}
		if(mapa[i] == 'E'){
			printf("0x04,");
		}
		if(mapa[i] == '.'){
			printf("0x00,");
		}
		i++;
	}
	return 0;
}

/*

Status do mario (cada coluna é um bit no byte)
martelo escada     esquerda andando pulando = 1
normal  nao-escada direita  parado  chao    = 0

00000 = andou pra direita
00100 = andou pra esquerda

----------------------------------

00X01 = pulo up
00010

00011 = pulo dir
00111 = pulo esq

----------------------------------

unicos estados possiveis para iniciar pulo
and 00100 > 00000 (direita) ou 00100 (esquerda)
fazer or com
00001 pra setar pulo = 1

sempre:
00001 = pulando direita
ou
00101 = pulando esquerda

andi 00100 > 00000 ou 00100

no reset:

00001 > 00000
00101 > 00100

andi 00100 > 00000
andi 00100 > 00100

*/