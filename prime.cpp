#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
//#include <cuda.h>
#include <math.h>
//#include <cuda_runtime.h>
#include <iostream>
#include <vector>
#include <cstdlib>

#define ULONGLONG long long unsigned int

using namespace std;

struct cell {
  ULONGLONG nbPrime;
  int exposant;

};

int isIn(vector<cell> liste, ULONGLONG n){
   int i = 0;
   while (i < liste.size()){
      if (liste.at(i).nbPrime == n){
         return i;
      }
      i++;
   }
   return -1;
}

bool isPrimeCPU(const ULONGLONG N, vector<cell> liste){
  if (N <= 2) {
    return true;
  }
  int i = 0;
  while (i<liste.size()) {
     if (N%liste[i].nbPrime == 0) {
        return false;
     }
     i++;
  }
   return true;
}

void searchPrimesCPU(const ULONGLONG N, vector<cell> listPrime){
   cell aux = {2, 0};

   listPrime.push_back(aux);

   // PAS SUR POUR LE i*i < N, peut être qu'il faut tous les prendre et alors i < N
   for (ULONGLONG i=3; i < N; i = i + 2 ){
      if (isPrimeCPU(i, listPrime)) {
         aux = {i, 0};
         listPrime.push_back(aux);
     }
   }
}


void v0_factoCPU(ULONGLONG N, vector<cell> listFinale){
   vector<cell> listeP;
   searchPrimesCPU(N, listeP);

   ULONGLONG tmp = N,
             i   = 0,
             j   = 0;
   int       ind;

   if (isPrimeCPU(N, listFinale)) {
      cell aux = {N, 1};
      listFinale.at(0) = aux;
   }
   while(listeP.at(i).nbPrime != 0){                   //TANT QUE LA DECOMPOSITION EST PAS FINI
      if (tmp%listeP.at(i).nbPrime == 0) {              //SI IL EST DIVISIBLE PAR LE NBP DE LA LISTE
         tmp = tmp/listeP.at(i).nbPrime;                // ON DIVISE TMP
         ind = isIn(listFinale, listeP.at(i).nbPrime);
         if (ind < 0) {
            listFinale.at(j) = listeP.at(i);            //ON AJOUTE LE NBP DIVISEUR A LA LISTE listFinale
            listFinale.at(j).exposant++;
            j++;
         } else{
            listFinale.at(ind).exposant++;
         }
      } else{                                           // SINON ON INCREMENTE I POUR PASSER AU NBP SUIVANT DANS LA LISTE
        i++;
      }
   }
}


int main(int argc, char *argv[]) {
   ULONGLONG n = atoi(argv[1]);
   vector<cell> liste;
   v0_factoCPU(n, liste);

   // AFFICHAGE DE LA DECOMPOSITION
   ULONGLONG i=0;
   while(liste[i].nbPrime != 0) {
     printf("%llu à la puissance %d\n", liste.at(i).nbPrime, liste.at(i).exposant);
     i++;
   }

   // TEST SI IL EST PREMIER
   if (isPrimeCPU(n, liste)) {
     printf("true\n");
   } else {
     printf("false\n");
   }

   return 0;
}
