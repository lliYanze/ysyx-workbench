#ifndef REG_H
#define REG_H
#include <assert.h>
#include <macro.h>

extern word_t *preg[32];

#define CONFIG_RT_CHECK

static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 32));
  return idx;
}

#define gpr(idx) *preg[check_reg_idx(idx)]
#define cpugpr(idx) cpu.reg[check_reg_idx(idx)]

void reg_init();
void show_regs();
void copyreg2cpu();

#endif // !REG_H
