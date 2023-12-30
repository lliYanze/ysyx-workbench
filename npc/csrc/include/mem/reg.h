#ifndef REG_H
#define REG_H
#include <assert.h>
#include <macro.h>

extern word_t *preg[32];
extern word_t *pcsr[4];

#define CONFIG_RT_CHECK

static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 32));
  return idx;
}

static inline int check_csr_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 4));
  return idx;
}
static inline const char *reg_name(int idx, int width) {
  extern const char *regsname[32];
  return regsname[check_reg_idx(idx)];
}

#define gpr(idx) *preg[check_reg_idx(idx)]
#define cpugpr(idx) cpu.reg[check_reg_idx(idx)]

#define csr(idx) *pcsr[check_csr_idx(idx)]
#define cpucsr(idx) cpu.csr[check_csr_idx(idx)]

void reg_init();
void show_regs();
void copyreg2cpu();

void copycsr2cpu();

#endif // !REG_H
