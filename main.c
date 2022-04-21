#include "meuAlocador.h" 
#include <stdio.h>
int main() {
  long int *a = NULL, *b = NULL, *c = NULL;
  iniciaAlocador();
  printTopo();

  imprimeMapa();
  printf("\n");
  a=alocaMem(34);
  printf("end a: %ld\n", (long int) a);
  imprimeMapa();
  printf("\n");

  *a = 2;
  printf("conteudo de A: %ld\n", *a);

  b=alocaMem(sizeof(long int) * 2);
  printf("end b: %ld\n", (long int) b);
  imprimeMapa();
  printf("\n");

  b[0] = 4;
  b[1] = 6;
  printf("conteudo de b[0],b[1]: %ld,%ld\n", b[0], b[1]);

  c=alocaMem(104);
  printf("end c: %ld\n", (long int) c);
  imprimeMapa();
  printf("\n");
  *c = 14;
  printf("conteudo de c: %ld\n", *c);

  // liberaMem(a);
  // imprimeMapa();
  // a=alocaMem(50);
  // imprimeMapa();

  finalizaAlocador();

}
