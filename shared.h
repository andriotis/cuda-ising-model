#ifndef SHARED_H
#define SHARED_H

int *shared_ising(int *G, int n, int b, int k);

__global__ void shared_pad(int *P, int *G, int n, int b);

__global__ void shared_update(int *P, int *O, int n, int b);

__device__ int shared_moment(int *p, int i, int j, int n);

#endif