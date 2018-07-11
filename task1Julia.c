
/*  Essa é a função responsável por exibir as informações dos processos
    já alocados na memória, e será modificada para a task 1 */
void
procdump(void)                
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i, j;
  struct proc *p;
  char *state;
  uint pc[10];
  
  /*  Laço for que percorre a tabela de processos (ptable) e localiza os processos
      delimitados pela constante NPROC (número de processos). Ele não foi alterado
      pelo grupo */

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    
    /*  Identificação do endereço de início do Page Directory */
    pde_t * pageDir = p -> pageDir;     

    cprintf("Localizacao do Page Directory na memoria: %p\n", pageDir);

    /*  Laço para a busca do endereço que referencia o processo em questão
        NPDENTRIES é a quantidade máxima de registros por página (1024) */
    for (i = 0; i < NPDENTRIES; i++){
      /* Verificação se a Page Table Entry (PTE) está presente, é uma página do usuário e é acessível */
      if ((pageDir[i] & PTE_U) && (pageDir[i] & PTE_A) && (pageDir[i] & PTE_P)) {
        /* Shift right para desconsiderar os primeiros 12 bits, que são flags */
        cprintf(" Page Directory: %d, PPN: %d\n", i, pageDir[i] >> 12);

        /* Conversão do endereço físico para o virtual através da função P2V() */
        pde_t * pageTable = P2V(PTE_ADDR(pageDir[i])); 
        cprintf("Localizacao do Page Table na memoria: %p\n", pageTable);

        /*  Laço para a localização do PTE das tables, ou seja, são percorridas 
            todas as páginas */
        for (j = 0, j < NPTENTRIES, j++) {
          if ((pageTable[j] & PTE_U) && (pageTable[j] & PTE_A) && (pageTable[j] & PTE_P))
            cprintf("Page Table: %d, PPN: %d, Endereco Virtual: %p\n", j, pageTable[j] >> 12, P2V(PTE_ADDR(pageTable[j])));
        }
      }
    }

    cprintf("Mapeamento de Paginas:\n");
    for (i = 0; i < NPDENTRIES; i++){
      /* Mesma verificação de PTE anterior */
      if ((pageDir[i] & PTE_U) && (pageDir[i] & PTE_A) && (pageDir[i] & PTE_P)){
        pde_t * pageTable = P2V(PTE_ADDR(pageDir[i]));

        /* Informações do PPN (Physical Page Number) da página correspondente */
        for (j = 0; j < NPTENTRIES; j++) {
          if ((pageTable[j] & PTE_U) && (pageTable[j] & PTE_A) && (pageTable[j] & PTE_P))
            cprintf( "%d ->  %d\n", (i << 10) | j, pageTable[j] >> 12);
        }
      }
    }
  }
}

