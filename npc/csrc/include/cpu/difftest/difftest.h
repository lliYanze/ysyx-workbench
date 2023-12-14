#ifndef DIFFTEST_H
#define DIFFTEST_H

#include <top.h>
void init_difftest();

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc);
void difftest_step(vaddr_t pc, vaddr_t npc);
#endif // !DIFFTEST_H
