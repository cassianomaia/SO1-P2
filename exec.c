#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  char *s, *last;
  int i, off;

  //TASK 3
  /* � declarada uma vari�vel writeFlag para ser utilizada posteriormente 
      para guardar se o programa est� em modo leitura ou escrita*/

  uint argc, sz, sp, ustack[3+MAXARG+1], writeFlag;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
    return -1;
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.

  // TASK2 
  /* Setando a vari�vel sz com o tamanho de uma p�gina (PGSIZE) para que o programa seja
      inicializado na segunda p�gina, n�o na primeira. 
      PGSIZE � definido como 4096 bytes em mmu.h inclu�do no in�cio do programa */

  sz = PGSIZE;
  
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;

    //TASK 3
    /* � feita uma verifica��o do cabe�alho do arquivo ELF.h para analisar se a flag de permiss�o de escrita � existente.
        Se for, a vari�vel writeFlag definida anteriormente recebe o valor 1. Se n�o for, se aprentar apenas permiss�o de leitura, recebe 0
        e essa vari�vel � passada por par�metro para a fun��o loaduvm() */

    if (ph.flags & ELF_PROG_FLAG_WRITE)
    	writeFlag = 1;
    else
    	writeFlag = 0;

    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz, writeFlag) < 0)
    {
      goto bad;
    }
  }

  iunlockput(ip);
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  proc->pgdir = pgdir;
  proc->sz = sz;
  proc->tf->eip = elf.entry;  // main
  proc->tf->esp = sp;
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip)
    iunlockput(ip);
  return -1;
}
