#include "prime.cpp"

int main(int argc, char *argv[]) {
   ULONGLONG n = atoi(argv[1]);
   ULONGLONG * liste = (ULONGLONG*) calloc(sqrt(n), sizeof(ULONGLONG));
   //searchPrimesCPU(n, liste);
   v0_factoCPU(n, liste);

   // AFFICHAGE DE LA DECOMPOSITION
   ULONGLONG i=0;
   while(liste[i] != 0) {
     printf("%llu\n", liste[i]);
     i++;
   }
   
   // TEST SI IL EST PREMIER
   if (isPrimeCPU(n)) {
     printf("true\n");
   } else {
     printf("false\n");
   }

   return 0;
}
