#include "dpic.h"
#include <VTOP.h>
#include <cstdint>
#include <cstdio>
#include <svdpi.h>

extern NPCstate npc_state;

extern VTOP *top;

void setnpcstate(int state) {
  npc_state.state = NPC_STOP;
  npc_state.halt_pc = top->io_pc;
  npc_state.halt_ret = state;
}
extern "C" void stopnpc(int state) { setnpcstate(state); }

// 环形缓冲区
#define IRING_BUF_SIZE 20
int first = 0;
char p[128] = {};
extern "C" void insttrace(uint32_t pc, uint32_t inst) {
  if (first == 0) {
    first = 1;
    return;
  }
  uint8_t *test = (uint8_t *)&inst;
  printf("pc: %x inst: %x\n", pc, inst);

  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, 128, pc, test, 4);
  printf("done\n");

  log_write("0x%08x: 0x%08x\n", pc, inst);
  printf("llvm test %c \n", *p);
}
