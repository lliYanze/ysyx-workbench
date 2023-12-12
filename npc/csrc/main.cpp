#include "mem.h"
#include "sdb.h"
#include "top.h"

int main(int arg, char **argv) {
  /* contextp->commandArgs(arg, argv); */
  /* Verilated::mkdir("./build/logs"); */
  /* Verilated::traceEverOn(true); */
  /* top->trace(mytrace, 5); */
  /* mytrace->open("./build/logs/top.vcd"); */
  engine_init(arg, argv);

  /* parse_args(arg, argv); */
  /* long size = load_img(); */
  /* log_init(); */
  npc_state.state = NPC_RUNNING;

  sdb_mainloop();

  /* show_regs(); */
  /* test_trap(); */
  mytrace->close();
  delete top;
  return 0;
}
