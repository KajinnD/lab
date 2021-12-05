#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <cuda.h>
#include <math.h>
#include <cuda_runtime.h>
#include <iostream>
#include <cstdlib>

#define ULONGLONG long long unsigned int

struct cell {
  ULONGLONG nbPrime;
  ULONGLONG exposant;
};

void completeInData(ULONGLONG n, ULONGLONG * inData) {
  ULONGLONG j = 1;
  inData[0] = 2;

  for (ULONGLONG i = 3; i < sqrt(n); i = i + 2) {
    inData[j] = i;
    j++;
  }
}

bool isPrimeCPU(const ULONGLONG N){
  if (N == 2) {
    return true;
  } else if (N%2 == 0) {
    return false;
  }

   for(int i=3 ; i*i < N ; i = i + 2){
      if (N % i == 0) {
         return false;
      }
   }
   return true;
}

void searchPrimesCPU(const ULONGLONG N, ULONGLONG * listPrime){
   ULONGLONG j = 0;
   listPrime[j] = 2;
   j++;

   // PAS SUR POUR LE i*i < N, peut être qu'il faut tous les prendre et alors i < N
   for (ULONGLONG i=3; i < N; i = i + 2 ){
     if (isPrimeCPU(i)) {
       listPrime[j] = i;
       j++;
     }
   }
}

void v0_factoCPU(ULONGLONG N, ULONGLONG * listFinale){
    ULONGLONG * listeP = (ULONGLONG*) calloc(N/2, sizeof(ULONGLONG));
    searchPrimesCPU(N, listeP);


    ULONGLONG tmp = N;
    ULONGLONG i = 0;
    ULONGLONG j = 0;

    if (isPrimeCPU(N)) {
      listFinale[0] = N;
    }
    while(listeP[i] != 0) {         //TANT QUE LA DECOMPOSITION EST PAS FINI
      if (tmp%listeP[i] == 0) {     //SI IL EST DIVISIBLE PAR LE NBP DE LA LISTE
        tmp = tmp/listeP[i];        // ON DIVISE TMP
        listFinale[j] = listeP[i];  //ON AJOUTE LE NBP DIVISEUR A LA LISTE listFinale
        j++;
      } else {                      // SINON ON INCREMENTE I POUR PASSER AU NBP SUIVANT DANS LA LISTE
        i++;
      }
    }
}

__global__ void v0_isPrimeGPU(ULONGLONG * inData, ULONGLONG * N, bool * isPrime) {

  //SANS REDUCTION
  ULONGLONG tid = blockIdx.x * blockDim.x + threadIdx.x;

  while (tid < *N) {
    if (*N % inData[tid] == 0) {
      *isPrime = false;
    }
    tid += blockDim.x * gridDim.x;
  }
}

__global__ void searchPrimesGPU(ULONGLONG * inData, bool * listePrime, ULONGLONG * N, ULONGLONG * outData) {

  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  //pb avec le j
  ULONGLONG j = 0;

  while (tid < *N) {
    //SI LE CHIFFRE COURANT EST UN PRIME
      if (listePrime[tid]) {
         //cell prime;
         //prime.nbPrime = inData[tid];
         outData[j] = inData[tid];
         j++;
       }
    tid += blockDim.x * gridDim.x;
  }
}

__global__ void factoGPU(bool * listePrime, ULONGLONG * N, ULONGLONG * outData){
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  ULONGLONG i = 0;
  ULONGLONG j = 0;

//SYNCH_THREAD ???
  while(tid < *N){
    if(*N % listePrime[i] == 0) {     //SI IL EST DIVISIBLE PAR LE NBP DE LA LISTE
      *N = *N/listPrime[i];          // ON DIVISE TMP
      outData[j] = listePrime[i];    //ON AJOUTE LE NBP DIVISEUR A LA LISTE listFinale
      j++;
    } else {                         // SINON ON INCREMENTE I POUR PASSER AU NBP SUIVANT DANS LA LISTE
      i++;
    }

    tid += blockDim.x * gridDim.x;
  }
}

int main(int argc, char *argv[]) {
   ULONGLONG n = atoi(argv[1]);

   ULONGLONG * inData = (ULONGLONG*) calloc(sqrt(n), sizeof(ULONGLONG));
   bool isPrime = true;
   bool *listPrime = (bool*) calloc(sqrt(n), sizeof(bool));
   ULONGLONG * outData = (ULONGLONG*) calloc(sqrt(n), sizeof(ULONGLONG));


   ULONGLONG j = 1;
   //inData[0] = 2;
   //for (ULONGLONG i = 3; i < sqrt(n); i = i + 2) {
  //   inData[j] = i;
  //   j++;
   //}

   // Liste on Device
   ULONGLONG *dev_inData;
   ULONGLONG *dev_n;
   bool *dev_isPrime;
   ULONGLONG * dev_outData;


   // Allocate memory on Device
   cudaMalloc(&dev_inData, sqrt(n) * sizeof(ULONGLONG));
   cudaMalloc(&dev_n, sizeof(ULONGLONG));
   cudaMalloc(&dev_outData, sqrt(n) * sizeof(ULONGLONG));
   cudaMalloc(&dev_isPrime, sizeof(bool));

   // Copy from Host to Device
		cudaMemcpy(dev_n, &n, sizeof(ULONGLONG), cudaMemcpyHostToDevice);
    //cudaMemcpy(dev_inData, inData, sqrt(n) * sizeof(ULONGLONG), cudaMemcpyHostToDevice);
    //cudaMemcpy(dev_isPrime, &isPrime, sizeof(bool), cudaMemcpyHostToDevice);


    inData[0] = 2;
    for (ULONGLONG i = 3; i < sqrt(n); i = i + 2) {
      inData[j] = i;
      cudaMemcpy(dev_inData, inData, sqrt(n) * sizeof(ULONGLONG), cudaMemcpyHostToDevice);
      cudaMemcpy(dev_isPrime, &isPrime, sizeof(bool), cudaMemcpyHostToDevice);
      v0_isPrimeGPU<<<5, 16>>>(dev_inData, dev_n, dev_isPrime);
      cudaMemcpy(&isPrime, dev_isPrime, sizeof(bool), cudaMemcpyDeviceToHost);
      listPrime[j] = isPrime;
      j++;
      cudaFree(dev_inData);
      cudaFree(dev_isPrime);
      if (isPrime) {
        printf("true\n");
      } else {
        printf("false\n");
      }
    }

    cudaMemcpy(dev_isPrime, listPrime, sizeof(ULONGLONG), cudaMemcpyHostToDevice);
    searchPrimesGPU<<<10,32>>>(dev_inData, dev_isPrime, dev_n, dev_outData);
    cudaMemcpy(&outData, dev_outData, sqrt(n) * sizeof(ULONGLONG), cudaMemcpyDeviceToHost);

    // Launch kernel
    //v0_isPrimeGPU<<<10, 32>>>(dev_inData, dev_n, dev_isPrime);

		// Copy from Device to Host
    //cudaMemcpy(&isPrime, dev_isPrime, sizeof(bool), cudaMemcpyDeviceToHost);

    if (isPrime) {
      printf("true\n");
    } else {
      printf("false\n");
    }

    ULONGLONG i=0;
    while(outData[i] != 0) {
      printf("%llu\n", outData[i]);
      i++;
    }

		// Free memory on Device
		cudaFree(dev_inData);
		cudaFree(dev_n);
    cudaFree(dev_isPrime);

   return 0;
}
