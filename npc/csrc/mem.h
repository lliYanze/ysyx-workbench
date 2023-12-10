#ifndef MEM_H
#define MEM_H
#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/macro.h"

void test_trap();
uint8_t *guest_to_host(paddr_t paddr);

static inline word_t host_read(void *addr, int len);

word_t pmem_read(paddr_t addr, int len);



#include <getopt.h>
#include <unistd.h>
#include <assert.h>

int parse_args(int argc, char *argv[]);
long load_img();


#endif // MEM_H
