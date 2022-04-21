#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  void *a = NULL, *b = NULL, *c = NULL;
  iniciaAlocador();
  printTopo();

  imprimeMapa();
  printf("\n");
  a=alocaMem(4);
  printf("end a: %ld\n", (long int) a);
  imprimeMapa();
  printf("\n");

  b=alocaMem(14);
  printf("end b: %ld\n", (long int) b);
  imprimeMapa();
  printf("\n");

  c=alocaMem(44);
  printf("end c: %ld\n", (long int) c);
  imprimeMapa();
  printf("\n");

  // liberaMem(a);
  // imprimeMapa();
  // a=alocaMem(50);
  // imprimeMapa();

  finalizaAlocador();

}
