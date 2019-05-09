#include <iostream>

using namespace std;

#define N 6

int a[] = {0, 1, 2, 3, 4, 5};
int best[N];
int cost = 1e9;
int distancias[][N] = {{0, 192, 116, 26, 84, 184},
                       {192, 0, 122, 101, 9, 40},
                       {116, 122, 0, 21, 171, 110},
                       {26, 101, 21, 0, 135, 270},
                       {84, 9, 171, 135, 0, 191},
                       {184, 40, 110, 270, 191, 0}};

void swap(int *x, int *y) {
    int temp;
    temp = *x;
    *x = *y;
    *y = temp;
}
void copy_array() {
    int i, sum = 0;
    for (i = 0; i < N; i++) {
        sum += distancias[a[i % N]][a[(i + 1) % N]];
    }
    if (cost > sum) {
        cost = sum;
        for (int i = 0; i < N; i++) {
            best[i] = a[i];
        }
    }
}
void permute(int i) {
    int j, k;
    if (i == (N - 1)) {
        copy_array();
    }
    else {
        for (j = i; j < N; j++) {
            swap((a + i), (a + j));
            permute(i + 1);
            swap((a + i), (a + j));
        }
    }
}
int main() {
    int i, j;
    permute(0   ); // arg0 = casa inicial
    printf("Custo: %d\n", cost);
    printf("Melhor rota: \n");
    for (int i = 0; i < N; i++) {
        printf("%d ", best[i]);
    }
    printf("\n");
}
