#include "macro.h"
#include <VTOP.h>
#include <verilated_vcd_c.h>

extern VerilatedContext *contextp;
extern VTOP *top;
extern VerilatedVcdC *mytrace;

void engine_init(int arg, char **argv);
