#include "utils.h"
#include "v0.h"
#include "v1.h"
#include "v2.h"

int main(int argc, char *argv[]) {

    int n = atoi(argv[1]);
    int k = atoi(argv[2]);

    int *G;
    allocate_model(&G, n);
    initialize_model(G, n);


    int *v0;
    allocate_model(&v0, n);
    v0 = get_v0(G, n, k);

    int *v1;
    allocate_model(&v1, n);
    v1 = get_v1(G, n, k);

    int *v2;
    allocate_model(&v2, n);
    v2 = get_v2(G, n, 3, k);

    check_equal(v0, v1, n);
    check_equal(v0, v2, n);

    return 0;
}