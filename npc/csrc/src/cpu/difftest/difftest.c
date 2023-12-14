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

extern "C" enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

extern long img_file_size;

extern void show_regs();

static void checkregs(CPU_state *ref, vaddr_t pc) {
  if (!isa_difftest_checkregs(ref, pc)) {
    npc_state.state = NPC_ABORT;
    npc_state.halt_pc = pc;
    show_regs();
  }
}

void init_difftest() {
  log_write("Differential testing: %s\n", ANSI_FMT("ON", ANSI_FG_GREEN));
  difftest_init(1234);

  difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_file_size,
                  DIFFTEST_TO_REF);
  difftest_regcpy(&cpu, DIFFTEST_TO_REF);
}

void difftest_step(vaddr_t pc, vaddr_t npc) {
  CPU_state ref_r;
  difftest_exec(1);
  difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
  checkregs(&ref_r, pc);
}
