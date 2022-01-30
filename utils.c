#include "utils.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void print_model_state(int *matrix, int size) {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) printf("%2d ", matrix[i * size + j]);
    printf("\n");
  }
}

int uniform_random_spin() {
  int random = (rand() % 10) + 1;

  return random <= 5 ? -1 : 1;
}

int *init_ising_model(int size) {
  int *matrix = (int *)malloc(size * size * sizeof(int));

  for (int i = 0; i < size; i++)
    for (int j = 0; j < size; j++) matrix[i * size + j] = uniform_random_spin();

  return matrix;
}

int *add_halo(int *matrix, int size) {
  int *pad_mat = (int *)calloc((size + 2) * (size + 2), sizeof(int));

  for (int i = 0; i < size; i++) {
    // Copy elements to pad_mat
    for (int j = 0; j < size; j++)
      pad_mat[(i + 1) * (size + 2) + (j + 1)] = matrix[i * size + j];

    // Add top padding
    pad_mat[i + 1] = matrix[(size - 1) * size + i];
    // Add right padding
    pad_mat[(i + 1) * (size + 2) + size + 1] = matrix[i * size];
    // Add bottom padding
    pad_mat[(size + 1) * (size + 2) + (i + 1)] = matrix[i];
    // Add left padding
    pad_mat[(i + 1) * (size + 2)] = matrix[i * size + (size - 1)];
  }

  return pad_mat;
}

int calculate_moment(int *matrix, int size, int i, int j) {
  int sign = matrix[(i - 1) * size + j] + matrix[(i + 1) * size + j] +
             matrix[i * size + j] + matrix[i * size + (j - 1)] +
             matrix[i * size + (j + 1)];

  return sign > 0 ? 1 : -1
}

void update_ising_model(int *in_matrix, int *out_matrix, int size) {
  // Add padding to input matrix
  int *padded_in_matrix = add_halo(in_matrix, size);

  // The matrix is padded now (dont calc moments for boundaries)
  for (int i = 0; i < size; i++)
    for (int j = 0; j < size; j++)
      out_matrix[i * size + j] =
          calculate_moment(padded_in_matrix, size + 2, i + 1, j + 1);

  free(padded_in_matrix);
}

void swap_matrices(int **A, int **B) {
  int *tmp = *A;
  *A = *B;
  *B = tmp;
}

void ising_model(int *in_matrix, int *out_matrix, int size,
                 int num_iterations) {
  // Allocate memory for out matrix
  out_matrix = (int *)calloc(size * size, sizeof(int));

  int k = 0;

  while (k < num_iterations) {
    update_ising_model(in_matrix, out_matrix, size);
    swap_matrices(&in_matrix, &out_matrix);
    k++;
  }

  if (num_iterations % 2 == 0) swap_matrices(&in_matrix, &out_matrix);
}

int compare_matrices(int *A, in *B, int size) {
  for (int i = 0; i < size * size; i++)
    if (A[i] != B[i]) return 0;

  return 1;
}
