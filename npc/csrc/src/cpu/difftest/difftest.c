#include <cpu/difftest/difftest.h>
#include <iostream>
#include <top.h>

#include <mem/pmem.h>

extern "C" void difftest_memcpy(paddr_t addr, void *buf, size_t n,
                                bool direction);

extern "C" void difftest_regcpy(void *dut, bool direction);

extern "C" void difftest_exec(uint64_t n);

extern "C" void difftest_raise_intr(word_t NO);

extern "C" void difftest_init(int port);

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

extern long img_file_size;

void init_difftest() {
  log_write("Differential testing: %s\n", ANSI_FMT("ON", ANSI_FG_GREEN));
  difftest_init(1234);
  // printf("img_file_size = %ld\n", img_file_size);

  difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_file_size,
                  DIFFTEST_TO_REF);
  difftest_regcpy(&cpu, DIFFTEST_TO_REF);
}
