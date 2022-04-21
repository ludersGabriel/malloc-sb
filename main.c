#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  long int *a = NULL, *b = NULL, *c = NULL, *d = NULL, *e = NULL;
  iniciaAlocador();
  printTopo();
  printLastAddr();
  imprimeMapa();
  printf("\n");

  a=alocaMem(10);


  b=alocaMem(30);


  c=alocaMem(8);

  d=alocaMem(12);

  e=alocaMem(12);

  imprimeMapa();
  printf("\n");


  liberaMem(a);
  liberaMem(c);
  liberaMem(e);
  imprimeMapa();
  printf("\n");

  a = alocaMem(11);
  imprimeMapa();
  printf("\n");
  liberaMem(b);
  liberaMem(d);

  // liberaMem(c);
  // imprimeMapa();
  // printLastAddr();
  // printf("\n");

  // liberaMem(b);
  // imprimeMapa();
  // printLastAddr();
  // printf("\n");

  // liberaMem(a);
  // imprimeMapa();
  // a=alocaMem(50);
  // imprimeMapa();

  finalizaAlocador();

}
