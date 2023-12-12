#include "mem.h"
#include "sdb.h"
#include <VTOP.h>
#include <verilated_vcd_c.h>

VerilatedContext *contextp = new VerilatedContext;
VTOP *top = new VTOP{contextp};
VerilatedVcdC *mytrace = new VerilatedVcdC;

NPCstate npc_state = {NPC_RUNNING, 0, 0};

bool batch_mode = false;

int main(int arg, char **argv) {
  contextp->commandArgs(arg, argv);
  Verilated::mkdir("./build/logs");
  Verilated::traceEverOn(true);
  top->trace(mytrace, 5);
  mytrace->open("./build/logs/top.vcd");

  parse_args(arg, argv);
  long size = load_img();
  log_init();
  npc_state.state = NPC_RUNNING;

  reset(1);
  preg_init();

  sdb_mainloop();

  show_regs();
  test_trap();
  mytrace->close();
  delete top;
  return 0;
}
