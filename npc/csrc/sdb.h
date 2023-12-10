#ifndef SDB_H
#define SDB_H
#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/macro.h"
#include <VTOP.h>
#include <stdio.h>
//

void show_regs();
void preg_init();

void single_cycle();
void reset(int sig);

void sdb_mainloop();

#endif // SDB_H
