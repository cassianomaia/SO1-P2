#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   int x = 0;
   int i , j;
   int sum = 0;
   int *num = (int*)malloc(sizeof(int));
   *num = 5;
   procdump();
   //child
   printf(1,"Criando filho, valor de x =  %d \n\n\n", x);
   if (cowfork() == 0)
   {
     procdump();
     x=2;
     
     printf(1,"Filho valor da variavel x = %d \n\n\n", x);
     
     for (i=0; i< 10; i++)
       for(j=0; j<5; j++)
	sum++;
     *num = 6;
     procdump();
	 printf(1, "Valor do numero para o filho:\n");
     printf(1, "%d\n", *num);
     
    }
    else{
       wait();
       printf(1,"Valor do numero para o pai:\n");
       printf(1, "%d\n", *num);
    }
   exit();
}
