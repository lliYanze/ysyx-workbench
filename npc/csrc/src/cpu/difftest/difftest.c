#include <iostream>
#include <macro.h>

extern "C" void difftest_memcpy(paddr_t addr, void *buf, size_t n,
                                bool direction);

extern "C" void difftest_regcpy(void *dut, bool direction);

extern "C" void difftest_exec(uint64_t n);

extern "C" void difftest_raise_intr(word_t NO);

extern "C" void difftest_init(int port);

void init_difftest() {
  difftest_init(1234);
  std::cout << "init difftest" << std::endl;
}
