#ifndef SEQUENTIAL_H
#define SEQUENTIAL_H

int *sequential_ising(int *G, int n, int k);

void sequential_pad(int *P, int *G, int n);

void sequential_update(int *P, int *O, int n);

int sequential_moment(int *P, int i, int j, int n);

#endif