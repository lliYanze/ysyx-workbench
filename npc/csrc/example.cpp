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
    dut.rst = 1;
    while(times--) {
        single_cycle();
    }
    dut.rst = 0;
}


int main(int arg, char** argv){
  nvboard_bind_all_pins(&dut);
  nvboard_init();
  reset(5);

  while(1) {
    nvboard_update();
    single_cycle();
    }
}
