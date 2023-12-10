#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/macro.h"
#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/mem.h"
#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/dpic.h"
#include "verilated.h"
#include <VTOP.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <verilated_vcd_c.h>

VerilatedContext *contextp = new VerilatedContext;
VTOP *top = new VTOP{contextp};
VerilatedVcdC *mytrace = new VerilatedVcdC;

static int times = 0;
NPCstate npc_state = {NPC_RUNNING, 0, 0};





void single_exe() {
  printf("pc = 0x%x\n", top->io_pc);
  printf("npc_state = %d\n", npc_state.state);
  top->io_inst = pmem_read(top->io_pc, 4);
}

void single_cycle() {
  top->clock = 0;
  top->eval();
  mytrace->dump(times);
  ++times;

  single_exe();

  top->clock = 1;
  top->eval();
  mytrace->dump(times);
  ++times;
}

void reset(int n) {
  top->reset = 1;
  while (n-- > 0) {
    top->clock = 0;
    top->eval();
    mytrace->dump(times);
    ++times;

    top->clock = 1;
    top->eval();
    mytrace->dump(times);
    ++times;
  }
  top->reset = 0;
}




int main(int arg, char **argv) {
  contextp->commandArgs(arg, argv);
  Verilated::mkdir("./build/logs");
  Verilated::traceEverOn(true);
  top->trace(mytrace, 5);
  mytrace->open("./build/logs/top.vcd");

  parse_args(arg, argv);
  long size = load_img();
  npc_state.state = NPC_RUNNING;

  reset(1);
  printf("npc_state = %d\n", npc_state.state);

  while (NPC_RUNNING == npc_state.state) {
    single_cycle();
  }
  test_trap();
  mytrace->close();
  delete top;
}
