#include "verilated.h"
#include <VTOP.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <verilated_vcd_c.h>

VerilatedContext *contextp = new VerilatedContext;
VTOP *top = new VTOP{contextp};
VerilatedVcdC *mytrace = new VerilatedVcdC;

#define NPC_RUNNING 0
#define NPC_STOP 1
#define NPC_END 2
#define NPC_ABORT 3
#define NPC_QUIT 4

static int times = 0;
static npc_state = NPC_RUNNING;

void single_cycle() {
  top->clock = 0;
  top->eval();
  mytrace->dump(times);
  ++times;

  top->clock = 1;
  top->eval();
  mytrace->dump(times);
  ++times;
}

void reset(int n) {
  top->reset = 1;
  while (n-- > 0)
    single_cycle();
  top->reset = 0;
}

void setnpcstate(int state) { npc_state = state; }
void stopnpc() { setnpcstate(NPC_STOP); }

int main(int arg, char **argv) {
  contextp->commandArgs(arg, argv);
  Verilated::mkdir("./build/logs");
  Verilated::traceEverOn(true);
  top->trace(mytrace, 5);
  mytrace->open("./build/logs/top.vcd");

  reset(1);
  /* assert(top->io_out == 0x80000000); */
  top->io_inst = 0xb0030413;
  top->io_inst = 0x00100073;

  printf("top->pc = 0x%x, \n", top->io_pc);
  printf("top->end = 0x%x, \n", top->io_end);
  single_cycle();
  printf("top->pc = 0x%x, \n", top->io_pc);
  printf("top->end = 0x%x, \n", top->io_end);
  single_cycle();
  printf("top->pc = 0x%x, \n", top->io_pc);
  printf("top->end = 0x%x, \n", top->io_end);
  mytrace->close();
  delete top;
}
