#include <stdio.h>

#include "v0.h"
#include "utils.h"

int *get_v0(int *G, int n, int k) {
    int *I, *P, *O;
    allocate_model(&I, n);
    allocate_model(&P, n + 2);
    allocate_model(&O, n);

    copy_model(G, I, n);

    for (int step = 0; step < k; step++) {
        pad_v0(P, I, n);
        update_v0(P, O, n);
        swap(&I, &O);
    }
    return I;
}

void pad_v0(int *P, int *G, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            P[(n + 2) * (i + 1) + (j + 1)] = G[n * i + j];
        }
        P[i + 1] = G[n * (n - 1) + i];
        P[(n + 2) * (n + 1) + (i + 1)] = G[i];
        P[(n + 2) * (i + 1)] = G[n * i + (n - 1)];
        P[(n + 2) * (i + 1) + (n + 1)] = G[n * i];
    }
}

void update_v0(int *P, int *O, int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            O[n * i + j] = moment_v0(P, i + 1, j + 1, n + 2);
}

int moment_v0(int *P, int i, int j, int n) {
    int moment = P[n * (i - 1) + j]
                + P[n * i + (j - 1)]
                + P[n * i + j]
                + P[n * (i + 1) + j]
                + P[n * i + (j + 1)];

    if (moment > 0)
        return 1;
    else
        return -1;
}