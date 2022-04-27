#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  long int *a = NULL, *b = NULL;
  iniciaAlocador();

  imprimeMapa();
  printf("\n");

  a=alocaMem(240);  
  imprimeMapa();
  printf("\n");

  b=alocaMem(24000);
  imprimeMapa();
  printf("\n");

  finalizaAlocador();

}
