#include "v1.h"
#include "utils.h"

int *get_v1(int *G, int n, int k) {

    int *gpu_G, *gpu_P, *gpu_O;
    cudaMalloc((void **)&gpu_G, n * n * sizeof(int));
    cudaMalloc((void **)&gpu_P, (n + 2) * (n + 2) * sizeof(int));
    cudaMalloc((void **)&gpu_O, n * n * sizeof(int));

    cudaMemcpy(gpu_G, G, n * n * sizeof(int), cudaMemcpyHostToDevice);

    int block_size = 32;
    dim3 block_dim = dim3(block_size, block_size);

    int grid_size = (n + block_size - 1) / block_size;
    dim3 grid_dim = dim3(grid_size, grid_size);

    for (int step = 0; step < k; step++) {
        pad_v1<<<grid_dim, block_dim>>>(gpu_P, gpu_G, n);
        update_v1<<<grid_dim, block_dim>>>(gpu_P, gpu_O, n);
        swap(&gpu_G, &gpu_O);
    }

    cudaMemcpy(G, gpu_G, n * n * sizeof(int), cudaMemcpyDeviceToHost);

    return G;
}

__global__ void pad_v1(int *P, int *G, int n) {
    int i = threadIdx.y + blockIdx.y * blockDim.y;
    int j = threadIdx.x + blockIdx.x * blockDim.x;

    if (i < n && j < n) {
        P[(n + 2) * (i + 1) + (j + 1)] = G[n * i + j];
        if (i == 0)
            P[(n + 2) * (n + 1) + (j + 1)] = G[n * i + j];
        if (i == n - 1)
            P[j + 1] = G[n * i + j];
        if (j == 0)
            P[(n + 2) * (i + 1) + (n + 1)] = G[n * i + j];
        if (j == n - 1)
            P[(n + 2) * (i + 1)] = G[n * i + j];
    }
}

__global__ void update_v1(int *P, int *O, int n) {
    int i = threadIdx.y + blockIdx.y * blockDim.y;
    int j = threadIdx.x + blockIdx.x * blockDim.x;

    if (i < n && j < n)
        moment_v1(P, O, i + 1, j + 1, n);
}

__device__ void moment_v1(int *P, int *O, int i, int j, int n) {
    int moment = P[(n + 2) * (i - 1) + j]
               + P[(n + 2) * i + (j - 1)]
               + P[(n + 2) * i + j]
               + P[(n + 2) * (i + 1) + j]
               + P[(n + 2) * i + (j + 1)];

    if (moment > 0)
        O[n * (i - 1) + (j - 1)] = 1;
    else
        O[n * (i - 1) + (j - 1)] = -1;
}