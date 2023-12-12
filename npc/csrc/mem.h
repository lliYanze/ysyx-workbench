#ifndef MEM_H
#define MEM_H
#include "macro.h"

void test_trap();
uint8_t *guest_to_host(paddr_t paddr);

static inline word_t host_read(void *addr, int len);

word_t pmem_read(paddr_t addr, int len);

#include <assert.h>
#include <getopt.h>
#include <unistd.h>

int parse_args(int argc, char *argv[]);
long load_img();
void log_init();

void show_mem(paddr_t addr, int len);

#endif // MEM_H
