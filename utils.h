#ifndef UTILS_H
#define UTILS_H

void print_model(int *G, int n);
void allocate_model(int **G, int n);
void initialize_model(int *G, int n);
void swap(int **G1, int **G2);
void check_equal(int *G1, int *G2, int N);

#endif