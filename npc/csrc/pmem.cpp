#include "macro.h"
#include <assert.h>
#include <iostream>
#include <memory>
#include <stdio.h>
static std::unique_ptr<uint8_t[]> pmem;

uint8_t *guest_to_host(paddr_t paddr) {
  return pmem.get() + paddr - CONFIG_MBASE;
}

static inline word_t host_read(void *addr, int len) {
  switch (len) {
  case 1:
    return *(uint8_t *)addr;
  case 2:
    return *(uint16_t *)addr;
  case 4:
    return *(uint32_t *)addr;
  }
  return 0;
}
word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

void show_mem(paddr_t addr, int len) {
  while (len-- > 0) {
    printf("0x%02x ", pmem_read(addr, 4));
    addr++;
    printf("\n");
  }
}

void init_mem() {
#if defined(CONFIG_PMEM_MALLOC)
  pmem = std::make_unique<uint8_t[]>(CONFIG_MSIZE);
  assert(pmem);
#endif
#ifdef CONFIG_MEM_RANDOM
  uint32_t *p = (uint32_t *)pmem;
  int i;
  for (i = 0; i < (int)(CONFIG_MSIZE / sizeof(p[0])); i++) {
    p[i] = rand();
  }
#endif
  log_write("physical memory area [" FMT_PADDR ", " FMT_PADDR "]\n", PMEM_LEFT,
            PMEM_RIGHT);
}
