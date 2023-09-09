#include <Vtop.h>
#include "verilated.h"
#include <nvboard.h>

void nvboard_bind_all_pins(Vtop* top);

static TOP_NAME dut;

int main(int arg, char** argv){
  nvboard_bind_all_pins(&dut);
  nvboard_init();

  while(1) {
    nvboard_update();
    dut.eval();
    }
}
