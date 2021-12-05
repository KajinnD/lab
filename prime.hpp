#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <cuda.h>
#include <math.h>
#include <cuda_runtime.h>
#include <iostream>
#include <vector>
#include <cstdlib>

#define ULONGLONG long long unsigned int

using namespace std;

struct cell {
  ULONGLONG nbPrime;
  int exposant;

};

#ifndef __REFERENCE_HPP
#define __REFERENCE_HPP

int isIn(vector<cell> liste, ULONGLONG n);
bool isPrimeCPU(const ULONGLONG N, vector<cell> liste);
void searchPrimesCPU(const ULONGLONG N, vector<cell> listPrime);
void v0_factoCPU(ULONGLONG N, vector<cell> listFinale);

#endif
