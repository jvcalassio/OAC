#include <iostream>
#include <algorithm>
#include <cstring>

using namespace std;

#define N 6

/*
Resumo:
Entregador de pizza vai da casa 0 ate todas as casas
Sub caminhos entre casas ja visitadas armazenado na matriz de visitados
Assim, reduz tempo de sub execucoes
No fim, volta a casa 0

* Fazer modificacao para funcao manual de permutacoes (sem uso da STL) 
* Desnecessario. Funcao com dp mais rapida e mais facil de implementar

Distancias dos caminhos:
*/
int distancias[][N] = { 	 {0,10,20,30,40,20},
						 {10,0,15,19,12,10},
						 {20,15,0,25,14,17},
						 {30,19,25,0,11,9},
						 {40,12,14,11,0,10},
					 	 {20,10,17,9,10,0}};

int visitados[N][1 << N];

// i = casa a verificar pertencimento
// S = bitmask do vetor de casas
bool pertence(int i, int S){
	return (S & (1 << i));
}

// incluir casa i (bit i) no bitmask
// retorna novo S
int incluir(int i, int S){
	return (S | (1 << i));
}

// se todas as casas em S foram visitadas
bool completou(int S){
	return S == (1 << N)-1;
}

// v = vertice atual
// S = bitmask de casas visitadas
int caixeiro(int v, int S){
	if(completou(S))
		return distancias[v][0];

	if(visitados[v][S] != -1)
		return visitados[v][S];

	int menor_caminho = 1e9;
	for(int i=0;i<N;i++){
		if(!pertence(i, S)){
			menor_caminho = min(
					menor_caminho,
					caixeiro(i, incluir(i, S)) + distancias[v][i]
				);
		}
	}

	visitados[v][S] = menor_caminho;
	return menor_caminho;
}


/*
int caixeiro(){
	int menor_caminho = 1e9;
	int casas[] = {1,2,3,4,5};
	// permutar casas
	next_permutation(casas, casas+(N-1));

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
*/

int main(){
	memset(visitados, -1, sizeof(visitados));
	printf("%d\n", caixeiro(0, 1));
	return 0;
}