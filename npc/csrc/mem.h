#ifndef MEM_H
#define MEM_H
#include "macro.h"

void test_trap();

int parse_args(int argc, char *argv[]);
long load_img();
void log_init();

void show_mem(paddr_t addr, int len);

#endif // MEM_H
