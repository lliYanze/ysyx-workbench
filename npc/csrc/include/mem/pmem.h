#ifndef PMEM_H
#define PMEM_H
#include "macro.h"

uint8_t *guest_to_host(paddr_t paddr);
word_t pmem_read(paddr_t addr, int len);
void show_mem(paddr_t addr, int len);
word_t pmem_write(paddr_t addr, word_t data, int len);

#endif // PMEM_H
