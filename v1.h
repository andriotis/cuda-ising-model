#ifndef V1_H
#define V1_H

int *get_v1(int *G, int n, int k);
__global__ void pad_v1(int *P, int *G, int n);
__global__ void update_v1(int *P, int *O, int n);
__device__ void moment_v1(int *P, int *O, int i, int j, int n);

#endif