#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "elf.h"
#include "spinlock.h"

extern char data[];  // defined by kernel.ld
pde_t *kpgdir;  // for use in scheduler()
struct segdesc gdt[NSEGS];

// TASK4
// Semaforo para contagem de compartilhamento
struct spinlock num_of_shareslock;

// Contador para o numero de compartilhamentos por pagina
uchar num_of_shares[PHYSTOP/PGSIZE];

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
  struct cpu *c;

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

//   // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  proc = 0;
  
  initlock(&num_of_shareslock, "sharedLock");
}

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;
  
  //PDX - entry that the 10 first bits points to.
  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    
    
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// There is one page table per process, plus one that's used when
// a CPU is not running any process (kpgdir). The kernel uses the
// current process's page table during system calls and interrupts;
// page protection bits prevent user code from using the kernel's
// mappings.
// 
// setupkvm() and exec() set up every page table like this:
//
//   0..KERNBASE: user memory (text+data+stack+heap), mapped to
//                phys memory allocated by the kernel
//   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
//   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
//                for the kernel's instructions and r/o data
//   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP, 
//                                  rw data + free physical memory
//   0xfe000000..0: mapped direct (devices such as ioapic)
//
// The kernel allocates physical memory for its heap and for user memory
// between V2P(end) and the end of physical memory (PHYSTOP)
// (directly addressable from end..P2V(PHYSTOP)).

// This table defines the kernel's mappings, which are present in
// every process's page table.
static struct kmap {
  void *virt;
  uint phys_start;
  uint phys_end;
  int perm;
} kmap[] = {
  { (void*) KERNBASE, 0,             EXTMEM,    PTE_W},  // I/O space
  { (void*) KERNLINK, V2P(KERNLINK), V2P(data), 0}, // kernel text+rodata
  { (void*) data,     V2P(data),     PHYSTOP,   PTE_W},  // kernel data, memory
  { (void*) DEVSPACE, DEVSPACE,      0,         PTE_W},  // more devices
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
}

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  kpgdir = setupkvm();
  switchkvm();
}

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(v2p(kpgdir));   // switch to the kernel page table
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  pushcli();
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(v2p(p->pgdir));  // switch to new address space
  popcli();
}

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.

//TASK 3
/* A fun��o recebe como par�metro a vari�vel de permiss�o de escrita writeFlag*/

int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz,uint writeFlag)
{
  uint i, pa, n;
  pte_t *pte;
  
  //if((uint) addr % PGSIZE != 0)
    //panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE) {
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");

	// TASK3 
  /*Se for permitida a escrita, � adicionada a FLAG de escrita PTE_W para todas as pagina��es pertencentes
    �quele processo, caso contr�rio, a mesma � removida.*/

    if (writeFlag)
    	*pte |= PTE_W;
    else
    	*pte &= ~PTE_W;

	// TASK3 
  /* Al�m disso, � adicionado um deslocamento para alinhamento da pagina. */

    pa = PTE_ADDR(*pte) + ((uint)(addr)%PGSIZE);

    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
}

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);

    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);

  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
	  pte = walkpgdir(pgdir, (char*)a, 0);
	  if(!pte)
		  a += (NPTENTRIES - 1) * PGSIZE;
	  else if((*pte & PTE_P) != 0) {
		  pa = PTE_ADDR(*pte);
		  if(pa == 0)
			  panic("kfree");
		  acquire(&num_of_shareslock);
		  if (num_of_shares[pa/PGSIZE] == 0) {
			  char *v = p2v(pa);
			  kfree(v);
		  } else
			  num_of_shares[pa/PGSIZE]--;

		  release(&num_of_shareslock);
		  *pte = 0;
    }
  }
  return newsz;
}

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
}

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
  *pte &= ~PTE_U;
}


// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz) {
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
  return 0;

  // TASK2 
  /* Como a primeira p�gina da mem�ria est� desalocada, � necess�rio percorrer as pagina��es 
      do processo pai a partir da segunda pagina, inicializando o contador i com o tamanho de 
      uma p�gina, evitando assim, o acesso ao endere�o 0 */

  for(i = PGSIZE; i < sz; i += PGSIZE){
	  if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
		  panic("copyuvm: pte should exist");
	  if(!(*pte & PTE_P))
		  panic("copyuvm: page not present");
	  pa = PTE_ADDR(*pte);
	  if((mem = kalloc()) == 0)
		  goto bad;

	  // copy data
	  memmove(mem, (char*)p2v(pa), PGSIZE); 

	  // TASK3
    /* Tamb�m � necess�rio modificar para que os processos filhos tamb�m recebessem 
      as flags de escrita e leitura do processo pai */

	  if (*pte & PTE_W) {
		  if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
			  goto bad;
	  } else {
		  if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_U) < 0)
			  goto bad;
	  }
  }
  
  return d;
  
bad:
  freevm(d);
  return 0;
}

void

// TASK2, TASK4
// Tratamento de exce��o, para erros em pagina��o/memoria !!
handle_pgflt(void)
{
  char *mem;
  pte_t *pte;
  uint pa;
  
  uint faultingAddress = read_cr2();

  // Tratamento de exce��o para NULL pointer
  if (faultingAddress==0) {
    cprintf("NULL POINTER EXCEPTION! kill&exit\n");
    proc->killed = 1;
    exit();
  }
  
  if ((pte = walkpgdir(proc->pgdir, (void*)faultingAddress , 0)) == 0)
    panic("handle_pgflt: pte should exist");
  if(!(*pte & PTE_P))
      panic("handle_pgflt: page not present");
  
  pa = PTE_ADDR(*pte);

  acquire(&num_of_shareslock);
  
  // Primeiro caso, um processo que entra e � o ultimo processo que compartilha essa pagina
  if ((num_of_shares[pa/PGSIZE] == 0) && ((*pte)& PTE_WAS_WRITABLE)) {
    *pte &= ~PTE_SH;  // Processo deixou de ser compartilhado
    *pte &= ~PTE_WAS_WRITABLE;  // n�o precisamos dessa flag auxiliar podemos usar a flag PTE_W
    *pte |= PTE_W;	// Atualiza o processo para poder ser escrito 
    goto finish_hadle_pgflt;
  }
  
  // Segundo caso, algum processo n�o compartilha mais a pagina��o
  if ((num_of_shares[pa/PGSIZE] > 0) && ((*pte)&PTE_WAS_WRITABLE) && ((*pte)&PTE_SH)) {
    num_of_shares[pa >> PGSHIFT]--;  // Atualiza��o do contador
    if((mem = kalloc()) == 0)		// Alocamos mem�ria
    	panic("handle_pgflt: failed to kalloc");
    memmove(mem, (char*)p2v(pa), PGSIZE);  // movemos o processo para area alocada
    *pte &= ~PTE_SH;	// Remove a FLAG de pagina��o comapritlhada
    *pte &= ~PTE_WAS_WRITABLE;	// FLAG auxiliar n�o � mais necess�ria podemos remover
    *pte = (*pte & 0XFFF) | v2p(mem) | PTE_W;	// Atualizamos a entry e a FLAG de escrita do processo
    goto finish_hadle_pgflt;
  }
  
  // Terceiro caso um processo tenta escrever em uma are originalmente somente leitura (read-only)
  if (!((*pte)&PTE_WAS_WRITABLE)) {
      cprintf("ACCESS VIOLATION! tried to write to read-only page. kill&exit\n");
      release(&num_of_shareslock);
      proc->killed = 1;
      exit(); 
  }

  
finish_hadle_pgflt:
  release(&num_of_shareslock);
  flush_tlb_all();
}

// TASK 4
// Dado um processo pai, compartilha a area de mem�ria com o filho
// Bem parecido com o copyuvm_cow
pde_t*
copyuvm_cow(pde_t *pgdir, uint sz) {
  pde_t *d;
  pte_t *pte;
  uint i, pa, flags;
  
  if((d = setupkvm()) == 0)
    return 0;

  for(i = PGSIZE; i < sz; i += PGSIZE) {
	  if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
		  panic("copyuvm_cow: pte should exist");
	  if(!(*pte & PTE_P))
		  panic("copyuvm_cow: page not present");
   
	  pa = PTE_ADDR(*pte);
    
	  // Aumentamos o contador de compartilhamento, utilizamos semaforo pois outros processos podem estar
	  // tentando fazer um compartilhameto da pagina��o
	  acquire(&num_of_shareslock);
	  num_of_shares[pa/PGSIZE]++;
	  release(&num_of_shareslock);
    

	  flags =  *pte & 0xfff;
	  if ((flags & PTE_W ) | (flags & PTE_WAS_WRITABLE)) {
		  flags &= ~PTE_W;	      // Removemos a flag de escrita
		  flags |= PTE_SH ;		  // Adicionamos as flags e compartilhamento
		  flags |= PTE_WAS_WRITABLE;	  // Adicionamos a flag auxilar para identificar se o processo podia ser escrito
		  if (mappages(d, (void*)i, PGSIZE, pa, flags) < 0)
			  goto bad;
	  } else {
		  flags |= PTE_SH;		  // Adicionamos as flags e compartilhamento 
		  if (mappages(d, (void*)i, PGSIZE, pa, flags) < 0)
			  goto bad;
	  }
    
	  // update flags
	  *pte = (*pte & ~0xfff) | flags; 
     
  }
  
  flush_tlb_all();
  return d;

bad:
  freevm(d);
  return 0;
}

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)p2v(PTE_ADDR(*pte));
}

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
