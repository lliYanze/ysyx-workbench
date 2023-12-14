/***************************************************************************************
 * Copyright (c) 2014-2022 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan
 *PSL v2. You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
 *KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 *NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include <cpu/cpu.h>
#include <difftest-def.h>
#include <isa.h>
#include <memory/paddr.h>

void diff_memcpy(paddr_t addr, void *src, size_t n) {
  for (size_t i = 0; i < n; ++i) {
    paddr_write(addr + i * 4, 4, *((word_t *)src + i));
  }
}

void diff_get_regs(void *r) {
  memcpy(r, &cpu, sizeof(cpu));
  // printf("diff_getregs\n");
}

void diff_set_regs(const void *r) {
  memcpy(&cpu, r, sizeof(cpu));
  // printf("diff_setregs\n");
}

__EXPORT void difftest_memcpy(paddr_t addr, void *buf, size_t n,
                              bool direction) {
  if (direction == DIFFTEST_TO_REF) {
    diff_memcpy(addr, buf, n);
  } else {
    Assert(0, "difftest_memcpy 方向错误\n");
  }
  // printf("0x%08x\n", paddr_read(0x80000000, 4));
}

__EXPORT void difftest_regcpy(void *dut, bool direction) {
  printf("regcpy\n");
  if (direction == DIFFTEST_TO_REF) {
    diff_set_regs(dut);
  } else {
    diff_get_regs(dut);
  }
  printf("cpu.pc = 0x%08x\n", cpu.pc);
  printf("cpu.gpr[2] = 0x%08x\n", cpu.gpr[2]);
}

__EXPORT void difftest_exec(uint64_t n) { assert(0); }

__EXPORT void difftest_raise_intr(word_t NO) { assert(0); }

__EXPORT void difftest_init(int port) {
  void init_mem();
  init_mem();
  /* Perform ISA dependent initialization. */
  init_isa();
}
