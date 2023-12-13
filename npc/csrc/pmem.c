#include "macro.h"
#include <stdio.h>
static uint8_t pmem[0x80000] PG_ALIGN = {};

uint8_t *guest_to_host(paddr_t paddr) { return pmem + paddr - 0x80000000; }

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
