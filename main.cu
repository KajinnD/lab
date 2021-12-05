#include "prime.cpp"

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
