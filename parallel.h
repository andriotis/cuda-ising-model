#ifndef PARALLEL_H
#define PARALLEL_H

int *parallel_ising(int *G, int n, int b, int k);

__global__ void parallel_pad(int *P, int *G, int n, int b);

__global__ void parallel_update(int *P, int *O, int n, int b);

__device__ int parallel_moment(int *P, int i, int j, int n);

#endif