#include <assert.h>
#include <iostream>
#include <macro.h>
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

word_t pmem_write(paddr_t addr, word_t data, int len) {
  switch (len) {
  case 1:
    *(uint8_t *)guest_to_host(addr) = data;
    break;
  case 2:
    *(uint16_t *)guest_to_host(addr) = data;
    break;
  case 4:
    *(uint32_t *)guest_to_host(addr) = data;
    break;
  default:
    assert(0);
  }
  return 0;
}

extern "C" void data_read(paddr_t addr, int *buf) { *buf = pmem_read(addr, 4); }

extern "C" void data_write(paddr_t addr, int buf, char wmask) {
  if (wmask == 0x0)
    pmem_write(addr, buf, 1);
  else if (wmask == 0x1)
    pmem_write(addr, buf, 2);
  else if (wmask == 0x2)
    pmem_write(addr, buf, 4);
  else if (wmask == 0x4)
    pmem_write(addr, buf, 1);
  else if (wmask == 0x5)
    pmem_write(addr, buf, 2);
  else {
    printf("wmask is 0x%x   wrong\n", wmask);
    assert(0);
  }
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
