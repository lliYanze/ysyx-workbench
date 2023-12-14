#include <VTOP.h>
#include <macro.h>
#include <verilated_vcd_c.h>

#include <cpu/isa-def.h>

extern VerilatedContext *contextp;
extern VTOP *top;
extern VerilatedVcdC *mytrace;

extern CPU_state cpu;

void engine_init(int arg, char **argv);
int engine_close();
