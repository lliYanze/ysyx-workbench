#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/dpic.h"

extern NPCstate npc_state;

extern VTOP *top;
void setnpcstate(int state) {
  npc_state.state = NPC_STOP;
  npc_state.halt_pc = top->io_pc;
  npc_state.halt_ret = state;
}
extern "C" void stopnpc(int state) { setnpcstate(state); }
