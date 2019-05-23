#include <bits/stdc++.h>

using namespace std;

int main(){
	printf(".data\n");
	printf("map_positions: .byte ");
	char mapa[81] = "PPPPPPPPPPPPPPPPPPPPP.........EE........................EE.........PPPPPPPPPPPPP";
	int i = 0;
	while(mapa[i]!='\0'){
		if(mapa[i] == 'P'){
			//printf(",00001000");
			printf("0x08,");
		}
		if(mapa[i] == 'C'){
			//printf(",00000001");
			printf("0x01,");
		}
		if(mapa[i] == 'D'){
			//printf(",00010001");
			printf("0x11,");
		}
		if(mapa[i] == 'E'){
			//printf(",00000010");
			printf("0x02,");
		}
		if(mapa[i] == '.'){
			//printf(",00000000");
			printf("0x00,");
		}
		i++;
	}
	return 0;
}

/*

martelo escada     esquerda andando pulando = 1
normal  nao-escada direita  parado  chao    = 0

or
00001

and
00100
00100
00000

parado direita:
	00000

parado esquerda:
	00100

andando direita:
	00010

andando esquerda:
	00110

pulando direita:
	00011

pulando esquerda:
	00111

pulando cima esquerda:
	00101

pulando cima direita:
	00001

escada:
	01XXX

parado martelo direita:
	10000

parado martelo esquerda:
	10100

andando martelo direita:
	10010

andando martelo esquerda:
	10110












*/