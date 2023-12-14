#include <cpu/difftest/difftest.h>
#include <mem/reg.h>
#include <stdio.h>
#include <top.h>

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
  int reg_index;
  int reg_nums = sizeof(ref_r->reg) / sizeof(ref_r->reg[0]);

  if (ref_r->pc != cpu.pc) {
    printf("pc is wrong\t ref:0x%08x\t yours:0x%08x\n", ref_r->pc, cpu.pc);
    return false;
  }
  for (reg_index = 0; reg_index < reg_nums; reg_index++) {
    if (ref_r->reg[check_reg_idx(reg_index)] != cpugpr(reg_index)) {
      printf(
          "reg[%d] (%s) is wrong\n ref_r's %s is 0x%08x \t my %s is 0x%08x\n",
          reg_index, reg_name(reg_index, 2), reg_name(reg_index, 2),
          ref_r->reg[check_reg_idx(reg_index)], reg_name(reg_index, 2),
          gpr(reg_index));
      return false;
    }
  }
  return true;
}
