#include "verilated.h"
#include <VTOP.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <verilated_vcd_c.h>

VerilatedContext *contextp = new VerilatedContext;
VTOP *top = new VTOP{contextp};

void single_cycle() {
  top->clock = 0;
  top->eval();
  top->clock = 1;
  top->eval();
}

void reset(int n) {
  top->reset = 1;
  while (n-- > 0)
    single_cycle();
  top->reset = 0;
}

int main(int arg, char **argv) {
  contextp->commandArgs(arg, argv);
  int times = 0;
  Verilated::mkdir("./build/logs");
  Verilated::traceEverOn(true);
  VerilatedVcdC *mytrace = new VerilatedVcdC;
  top->trace(mytrace, 5);
  mytrace->open("./build/logs/top.vcd");

  reset(10);

  for (times = 0; times < 100; ++times) {
    int a = rand() & 1;
    int b = rand() & 1;
    top->io_in_a = a;
    top->io_in_b = b;
    top->eval();
    mytrace->dump(times);

    /* printf("C++:a = %d, b = %d, f = %d\n", a, b, top->io_out); */

    assert(top->io_out == (a ^ b));
  }
  mytrace->close();
  delete top;
}
