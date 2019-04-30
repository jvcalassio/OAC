#include <iostream>
#include <algorithm>

using namespace std;

#define N 6

/*
Resumo:
Entregador de pizza vai da casa 0 ate todas as casas
No fim, volta a casa 0

Fazer modificacao para funcao manual de permutacoes (sem uso da STL)

Distancias dos caminhos:
*/
int caminhos[][N] = { {0,10,20,30,40,20},
						 {10,0,15,19,12,10},
						 {20,15,0,25,14,17},
						 {30,19,25,0,11,9},
						 {40,12,14,11,0,10},
					 	 {20,10,17,9,10,0}};

int fat(int n){
	if(n == 0 || n == 1){
		return 1;
	} else {
		return n*(fat(n-1));
	}
}

int caixeiro(){
	int menor_caminho = 1e9;
	int casas[] = {1,2,3,4,5};
	// permutar casas
	next_permutation(casas, casas+4);

	int qtd_perm = fat(N-1);

	do {
		int custo_atual = 0;
		int k = 0;
		for(int i=0;i<(N-1);i++){
			custo_atual += caminhos[k][casas[i]];
			k = casas[i];
		}
		custo_atual += caminhos[k][0];
		menor_caminho = min(menor_caminho, custo_atual);
		next_permutation(casas, casas+(N-1));
		qtd_perm--;
	} while(qtd_perm > 0);
	return menor_caminho;
}

int main(){
	printf("%d\n", caixeiro());
	return 0;
}