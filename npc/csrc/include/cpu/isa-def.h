#ifndef ISA_DEF_H
#define ISA_DEF_H
#include <macro.h>

/* typedef struct { */
/*   word_t reg[32]; */
/*   vaddr_t pc; */
/* } riscv32_CPU_state; */

typedef struct {
  word_t reg[32];
  vaddr_t pc;
  /* riscv32_csr csr; */
  word_t csr[4];
} riscv32_CPU_state;

#define CPU_state riscv32_CPU_state

#endif // !ISA_DEF_H
