#ifndef SDB_H
#define SDB_H
#include "macro.h"

//

void begin(int arg, char **argv);
void end();

void show_regs();
void preg_init();

void single_cycle();
void reset(int sig);

void sdb_mainloop();
void ftrace_init();

#endif // SDB_H
