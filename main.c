#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  long int *a = NULL, *b = NULL, *c = NULL, *d = NULL, *e = NULL;
  iniciaAlocador();
  printTopo();
  printLastAddr();
  imprimeMapa();
  printf("\n");

  liberaMem(a);

  finalizaAlocador();

}
