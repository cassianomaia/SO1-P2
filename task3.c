#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   char* p = (char*)main;

  // Cria um filho
   if(fork() == 0) {

     printf(1, "Endereco %p do processo pai.  Valor: %c\n", p, *p);
     printf(1, "Processo Filho tentando escrever no endereco pertencente ao processo pai com permissão somente para leitura\n");
     *p = 'n';
     printf(1, "Endereco %p referente ao processo pai.  Valor: %c\n", p, *p);
  
   } else
     wait();

   exit();
}
