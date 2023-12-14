#include <cpu/sdb.h>
#include <top.h>

extern void init_difftest();
int main(int arg, char **argv) {
  engine_init(arg, argv);
  npc_state.state = NPC_RUNNING;
  sdb_mainloop();

  return engine_close();
}
