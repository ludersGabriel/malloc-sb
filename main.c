#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  long int *a = NULL, *b = NULL, *c = NULL, *d = NULL, *e = NULL;
  iniciaAlocador();
  printTopo();
  printLastAddr();
  imprimeMapa();
  printf("\n");

  a = alocaMem(100);
  imprimeMapa();
  printf("\n");
  liberaMem(a);

  b = alocaMem(100);
  imprimeMapa();
  printf("\n");

  liberaMem(a);

  imprimeMapa();
  printf("\n");

  finalizaAlocador();

}
