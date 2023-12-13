#include "sdb.h"
#include "top.h"

/* #include "/home/alan/Project/ysyx/ysyx-workbench/nemu/include/cpu/difftest.h"
 */

extern "C" void difftest_init(int port);
int main(int arg, char **argv) {
  engine_init(arg, argv);
  npc_state.state = NPC_RUNNING;
  difftest_init(1234);
  sdb_mainloop();

  return engine_close();
}
