#include <iostream>
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

Utiliza bitmask para simular as casas ja visitadas na dfs
Sendo S[6] = { S[0], S[1], S[2], S[3], S[4], S[5], S[6] }, com S[i] = 0 ou 1, indicando se foi visitado ou nao

Distancias dos caminhos:
*/
int distancias[][N] = {  {0,10,20,30,40,20},
						 {10,0,15,19,12,10},
						 {20,15,0,25,14,17},
						 {30,19,25,0,11,9},
						 {40,12,14,11,0,10},
					 	 {20,10,17,9,10,0}};

// visitados com N x 2 ^ N posicoes
int visitados[N][1 << N];
// matriz auxiliar para salvar o caminho percorrido. N x 2^N posicoes tbm
int savePath[N][1 << N];

// i = casa a verificar se ja foi visitada
// S = bitmask do vetor de casas
bool visitada(int i, int S){
	return (S & (1 << i));
}

// incluir casa i (bit i = 1) no bitmask
// retorna novo S
int add_visitadas(int i, int S){
	return (S | (1 << i));
}

// se todas as casas em S foram visitadas
bool completou(int S){
	return S == (1 << N)-1;
}

void binprintf(int v)
{
    unsigned int mask=1<<((1<<3)-1);
    while(mask) {
        printf("%d", (v&mask ? 1 : 0));
        mask >>= 1;
    }
}

// v = vertice atual
// S = bitmask de casas visitadas
int caixeiro(int v, int S){
	if(completou(S))
		return distancias[v][0];

	if(visitados[v][S] != -1)
		return visitados[v][S];

	int menor_caminho = 1e9;
	int chosen_i = 0;
	for(int i=0;i<N;i++){
		if(!visitada(i, S)){
			int q = caixeiro(i, add_visitadas(i, S)) + distancias[v][i];
			if(menor_caminho > q){
				menor_caminho = q;
				savePath[v][S] = i;
			}
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
	printf("Distancia: %d\n", caixeiro(0, 1));
	
	int casa_atual = 0;
	int bitmask = 1;
	int qtd = 0;
	printf("Caminho: 0 ");
	do {
		casa_atual = savePath[casa_atual][bitmask];
		printf("%d ", casa_atual);
		bitmask = add_visitadas(casa_atual, bitmask);
		qtd++;
	} while(qtd < 6);
	printf("\n");
	return 0;
}