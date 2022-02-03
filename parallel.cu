#include <stdio.h>
#include "parallel.h"
#include "utils.h"
#include "math.h"

int *parallel_ising(int *G, int n, int b, int k) {
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
        parallel_pad<<<grid_dim, block_dim>>>(gpu_P, gpu_I, n, b);
        parallel_update<<<grid_dim, block_dim>>>(gpu_P, gpu_O, n, b);
        swap(&gpu_I, &gpu_O);
    }

    cudaMemcpy(I, gpu_I, n * n * sizeof(int), cudaMemcpyDeviceToHost);

    return I;
}

__global__ void parallel_pad(int *P, int *G, int n, int b) {

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

__global__ void parallel_update(int *P, int *O, int n, int b) {

    int start_row = blockIdx.y * b;
    int end_row = start_row + b;
    int start_col = blockIdx.x * b;
    int end_col = start_col + b;

    for (int row = start_row; row < end_row; row++) {
        for (int col = start_col; col < end_col; col++) {
            if (row < n && col < n) {
                O[n * row + col] = parallel_moment(P, row + 1, col + 1, n + 2);
            }
        }
    }
}

__device__ int parallel_moment(int *P, int i, int j, int n) {
    int moment = P[n * (i - 1) + j]
               + P[n * i + (j - 1)]
               + P[n * i + j]
               + P[n * (i + 1) + j]
               + P[n * i + (j + 1)];

    return (moment > 0) ? 1 : -1;
}
