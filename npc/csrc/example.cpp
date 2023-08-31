#include <Vtop.h>
#include "verilated.h"
#include <nvboard.h>

void nvboard_bind_all_pins(Vtop* top);

static TOP_NAME dut;

void single_cycle() {
    dut.clk = 0; dut.eval();
    dut.clk = 1; dut.eval();
}

void reset(int times) {
    dut.rst = 0;
    while(times--) single_cycle();
}


int main(int arg, char** argv){
  nvboard_bind_all_pins(&dut);
  nvboard_init();
  reset(10);

  while(1) {
    nvboard_update();
    dut.eval();
  }
}
