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