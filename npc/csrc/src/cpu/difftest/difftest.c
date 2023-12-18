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

static bool is_skip_ref = false;
static int skip_dut_nr_inst = 0;

void difftest_skip_ref() {
  is_skip_ref = true;
  // If such an instruction is one of the instruction packing in QEMU
  // (see below), we end the process of catching up with QEMU's pc to
  // keep the consistent behavior in our best.
  // Note that this is still not perfect: if the packed instructions
  // already write some memory, and the incoming instruction in NEMU
  // will load that memory, we will encounter false negative. But such
  // situation is infrequent.
  skip_dut_nr_inst = 0;
}

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

  if (is_skip_ref) {
    // to skip the checking of an instruction, just copy the reg state to
    // reference design
    difftest_regcpy(&cpu, DIFFTEST_TO_REF);
    is_skip_ref = false;
    return;
  }
  difftest_exec(1);
  difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
  checkregs(&ref_r, pc);
}
