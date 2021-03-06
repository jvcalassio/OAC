#include <iostream>
#include <string>
#include <fstream>

using namespace std;

/*

Esquemas do mapa:
1 byte = 0000_0000

4 lsb = relativos as propriedades do cenario

0000 = ar					= .
0001 = chao					= C
//0010 = degrau p esquerda		= A 
//0011 = degrau p direita		= D
0010 = gravidade			= G
0011 = morte certa			= M
0100 = escada 				= E
0101 = fim escada 			= T
1000 = parede				= P

0000_0100
1111_1011

4 msb = relativos a alguns coletaveis (removido)

0000 = nada	
0001 = area de elevador			= L
0010 = item bonus (800 pts)		= B (removido)
0100 = martelo					= H (removido)
1000 = vitoria					= V (ar)


*/
int main(){
	int k;
	scanf("%d",&k);
	char stringname[40];
	sprintf(stringname, "fase%d_map.txt", k);
	printf("fase%d_obj: .byte ",k);
	string mapa;
	ifstream map_in;
	map_in.open(stringname);
	for(int j=0;j<60;j++){
		map_in >> mapa;
		for(int i=0;i<80;i++){
			int t = 0;
			if(mapa[i] == '.'){
				t = 1;
				printf("0x00");
			}
			if(mapa[i] == 'C'){
				t = 1;
				printf("0x01");
			}
			if(mapa[i] == 'L'){
				t = 1;
				printf("0x10");
			}
			if(mapa[i] == 'G'){
				t = 1;
				printf("0x02");
			}
			if(mapa[i] == 'M'){
				t = 1;
				printf("0x03");
			}
			if(mapa[i] == 'E'){
				t = 1;
				printf("0x04");
			}
			if(mapa[i] == 'T'){
				t = 1;
				printf("0x05");
			}
			if(mapa[i] == 'P'){
				t = 1;
				printf("0x08");
			}
			if(mapa[i] == 'V'){
				t = 1;
				printf("0x80");
			}
			if(mapa[i] == 'B'){
				t = 1;
				printf("0x21");
			}
			if(j == 59 && t == 1){
				if(i != 79){
					printf(",");
				}
			} else if(t == 1){
				printf(",");
			}
		}
		printf("\n");
	}

	map_in.close();
	/*  old version:
		mantida para fazer debug de linhas especificas
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
	}*/
	return 0;
}
