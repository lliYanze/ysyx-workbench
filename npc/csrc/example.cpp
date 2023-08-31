//#include <stdio.h>
//#include <stdlib.h>
//#include <assert.h>
#include <Vtop.h>
#include "verilated.h"
//#include <verilated_vcd_c.h>
#include <nvboard.h>

void nvboard_bind_all_pins(Vtop* top);

static TOP_NAME dut;
int main(int arg, char** argv){

    

  nvboard_bind_all_pins(&dut);
  nvboard_init();

  //reset(10);

  while(1) {
    nvboard_update();
    //int a = rand() & 1;
    //int b = rand() & 1;
    //dut.a = a;
    //dut.b = b;
    dut.eval();
  }
}
