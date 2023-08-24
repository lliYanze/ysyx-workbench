#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <Vour.h>
#include "verilated.h"
#include <verilated_vcd_c.h>

int main(int arg, char** argv){
    VerilatedContext* contextp= new VerilatedContext;
    contextp->commandArgs(arg, argv);
    Vour* top = new Vour{contextp};
    int times = 0;
    Verilated::mkdir("logs");
    Verilated::traceEverOn(true);
    VerilatedVcdC *mytrace = new VerilatedVcdC;
    top->trace(mytrace, 5);
    mytrace->open("./logs/add.vcd");
    



    for(times = 0; times < 100; ++times) {
        int a = rand() & 1;
        int b = rand() & 1;
        top->a = a;
        top->b = b;
        top->eval();
        mytrace->dump(times);

        printf("a = %d, b = %d, f = %d\n", a, b, top->f);
        assert(top->f == (a^b));
    }
    mytrace->close();
    delete top;

}
