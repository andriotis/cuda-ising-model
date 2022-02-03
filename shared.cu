#include <stdio.h>
#include <stdlib.h>
#include "shared.h"
#include "utils.h"
#include "math.h"

int *shared_ising(int *G, int n, int b, int k) {
    int *I;
    allocate_model(&I, n);
    copy_model(G, I, n);
    
    int *gpu_I, *gpu_P, *gpu_O;
    cudaMalloc((void **)&gpu_I, n * n * sizeof(int));
    cudaMalloc((void **)&gpu_P, (n + 2) * (n + 2) * sizeof(int));
    cudaMalloc((void **)&gpu_O, n * n * sizeof(int));

    cudaMemcpy(gpu_I, I, n * n * sizeof(int), cudaMemcpyHostToDevice); 

    dim3 block_dim = dim3(1, 1);
    dim3 grid_dim = dim3(ceil(((float)n)/b), ceil(((float)n)/b));

    for (int step = 0; step < k; step++) {
        shared_pad<<<grid_dim, block_dim>>>(gpu_P, gpu_I, n, b);
        shared_update<<<grid_dim, block_dim, (b + 2) * (b + 2) * sizeof(int)>>>(gpu_P, gpu_O, n, b);
        swap(&gpu_I, &gpu_O);
    }

    cudaMemcpy(I, gpu_I, n * n * sizeof(int), cudaMemcpyDeviceToHost);

    return I;
}

__global__ void shared_pad(int *P, int *G, int n, int b) {

    int start_row = blockIdx.y * b;
    int end_row = start_row + b;
    int start_col = blockIdx.x * b;
    int end_col = start_col + b;

    for (int row = start_row; row < end_row; row++) {
        for (int col = start_col; col < end_col; col++) {
            if (row < n && col < n) {
                P[(n + 2) * (row + 1) + (col + 1)] = G[n * row + col];
                if (row == 0)
                    P[(n + 2) * (n + 1) + (col + 1)] = G[n * row + col];
                if (row == n - 1)
                    P[col + 1] = G[n * row + col];
                if (col == 0)
                    P[(n + 2) * (row + 1) + (n + 1)] = G[n * row + col];
                if (col == n - 1)
                    P[(n + 2) * (row + 1)] = G[n * row + col];
            }
        }
    }
}

__global__ void shared_update(int *P, int *O, int n, int b) {

    extern __shared__ int shared[];

    int start_row = blockIdx.y * b;
    int end_row = start_row + b;
    int start_col = blockIdx.x * b;
    int end_col = start_col + b;

    for (int i = 0; i < b + 2; i++) {
        for (int j = 0; j < b + 2; j++) {
            if (start_row + i < n + 2 && start_col + j < n + 2) {
                shared[i * (b + 2) + j] = P[(n + 2) * (start_row + i) + (start_col + j)];
            }
        }
    }

    for (int i = start_row; i < end_row; i++) {
        for (int j = start_col; j < end_col; j++) {
            if (i < n && j < n) {
                O[n * i + j] = shared_moment(shared, i + 1 - start_row, j + 1 - start_col, b + 2);
            }
        }
    }
}

__device__ int shared_moment(int *P, int i, int j, int n) {
    int moment = P[n * (i - 1) + j]
               + P[n * i + (j - 1)]
               + P[n * i + j]
               + P[n * (i + 1) + j]
               + P[n * i + (j + 1)];

    return (moment > 0) ? 1 : -1;
}