#include "utils.h"
#include "sequential.h"
#include "parallel.h"
#include "shared.h"

int main(int argc, char *argv[]) {

    int n = atoi(argv[1]);
    int k = atoi(argv[2]);
    int b = atoi(argv[3]);

    int *G;
    allocate_model(&G, n);
    initialize_model(G, n);


    int *V0;
    allocate_model(&V0, n);
    V0 = sequential_ising(G, n, k);

    int *V1;
    allocate_model(&V1, n);
    V1 = parallel_ising(G, n, 1, k);

    int *V2;
    allocate_model(&V2, n);
    V2 = parallel_ising(G, n, b, k);

    int *V3;
    allocate_model(&V3, n);
    V3 = shared_ising(G, n, b, k);

    check_equal(V0, V1, n);
    check_equal(V0, V2, n);
    check_equal(V0, V3, n);

    return 0;
}