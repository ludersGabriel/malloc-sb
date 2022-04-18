#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  void *a = NULL, *b = NULL;
  iniciaAlocador();
  printTopo();

  imprimeMapa();
  printf("\n");
  a=alocaMem(8);
  printf("end a: %ld\n", (long int) a);
  imprimeMapa();
  printf("\n");
  b=alocaMem(50);
  printf("end b: %ld\n", (long int) b);
  imprimeMapa();
  printf("\n");
  // liberaMem(a);
  // imprimeMapa();
  // a=alocaMem(50);
  // imprimeMapa();

  finalizaAlocador();

}
