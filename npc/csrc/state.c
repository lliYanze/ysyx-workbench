#include "macro.h"

NPCstate npc_state = {NPC_RUNNING, 0, 0};

void set_npc_state(int state, vaddr_t pc, int halt_ret) {
  npc_state.state = state;
  npc_state.halt_pc = pc;
  npc_state.halt_ret = halt_ret;
}
