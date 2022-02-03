#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "utils.h"

void print_model(int *G, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("%2d ", G[n * i + j]);
        }
        printf("\n");
    }
}

void allocate_model(int **G, int n) {
    *G = (int *)calloc(n * n, sizeof(int));
}

void initialize_model(int *G, int n) {
    srand(time(NULL));
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (rand() % 2 == 0) {
                G[n * i + j] = 1;
            }
            else {
                G[n * i + j] = -1;
            }
        }
    }
}

void copy_model(int *G1, int *G2, int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            G2[n * i + j] = G1[n * i + j];
}

void swap(int **G1, int **G2) {
    int *tmp = *G1;
    *G1 = *G2;
    *G2 = tmp;
}

void check_equal(int *G1, int *G2, int N) {
    int count = 0;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            if (G1[N * i + j] != G2[N * i + j])
                count++;
    if (count)
        printf("DIFFERENT!\n");
    else
        printf("EQUAL!\n");
}