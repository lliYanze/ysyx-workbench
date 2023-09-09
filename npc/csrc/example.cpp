#include <Vtop.h>
#include <verilated.h>
#include <nvboard.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <verilated_vcd_c.h>

void nvboard_bind_all_pins(Vtop* top);

static TOP_NAME dut;

VerilatedVcdC *m_trace = new VerilatedVcdC;

int sim_time = 0;

static void single_cycle() {
  dut.clk = 0; dut.eval(); m_trace->dump(sim_time); sim_time++;
  dut.clk = 1; dut.eval(); m_trace->dump(sim_time); sim_time++;
}

static void reset(int n) {
  dut.ret = 1;
  while (n -- > 0) single_cycle();
  dut.ret = 0;
}

int main(int arg, char** argv){
    Verilated::mkdir("logs");
    Verilated::traceEverOn(true);
    dut.trace(m_trace, 5);
    m_trace->open("./logs/key.vcd");
    nvboard_bind_all_pins(&dut);
    nvboard_init();

    while(1) {
        nvboard_update();
        single_cycle();
    }
}
