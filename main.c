#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  long int *a = NULL;
  iniciaAlocador();
  printTopo();
  printLastAddr();

  imprimeMapa();
  printf("\n");

  a=alocaMem(155);
  
  imprimeMapa();
  printf("\n");

  finalizaAlocador();
}

