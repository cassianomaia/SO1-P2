#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[]){

  /* Código para realizar o teste da task 2, tentando acessar a primeira página da memória */

  char* p1;

  p1 = (char*) 4096;
  printf(1, "Escrevendo endereco %p\n", p1);
  
  p1[0] = 'teste1';

  printf(1, "Endereco %p, valor: %c\n", p1, *p1);

  exit();
}
