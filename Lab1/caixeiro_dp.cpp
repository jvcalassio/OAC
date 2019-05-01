// Código relacionado a este post no meu blog:
// http://crbonilha.com/pt/um-pouco-sobre-o-salesman-problem/

#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;
const int INF = 1000000000, maxn = 16;

int n;
int adj[maxn+1][maxn+1];
int sp[maxn+1][1 << maxn];

int dfs(int v, int S) {
	// caso base
	if(completo(S)) return adj[v][1];
	
	// sub-problema ja resolvido
	if(sp[v][S] != -1) return sp[v][S];
	
	int resposta = INF;
	for(int u=1; u<=n; u++) {
		if(!pertence(u, S)) {
			resposta = min(
				resposta, 
				dfs(u, inclua(u, S)) + adj[v][u]
			);
		}
	}
	
	sp[v][S] = resposta;
	return sp[v][S];
}

bool pertence(int u, int S) {
	return (S & (1 << (u-1)));
}
int inclua(int u, int S) {
	return (S | (1 << (u-1)));
}
bool completo(int S) {
	return S == (1 << n)-1;
}

int main() {
	scanf("%d", &n);
	for(int i=1; i<=n; i++) {
		for(int j=1; j<=n; j++) {
			scanf("%d", &adj[i][j]);
		}
	}
	
	memset(sp, -1, sizeof(sp));
	printf("%d\n", dfs(1, 1));
}