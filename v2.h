#ifndef V2_H
#define V2_H

int *get_v2(int *G, int n, int b, int k);

__global__ void pad_v2(int *P, int *G, int n, int b);

__global__ void update_v2(int *P, int *O, int n, int b);

__device__ void moment_v2(int *P, int *O, int i, int j, int n);

#endif