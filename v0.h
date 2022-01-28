#ifndef V0_H
#define V0_H

int *get_v0(int *G, int n, int k);
void pad_v0(int *P, int *G, int n);
void update_v0(int *P, int *O, int n);
int moment_v0(int *P, int i, int j, int n);

#endif