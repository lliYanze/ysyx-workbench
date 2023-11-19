/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/difftest.h>
#include "../local-include/reg.h"


bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
    int reg_index;
    int reg_nums = sizeof(ref_r->gpr) / sizeof(ref_r->gpr[0]);

    if(ref_r->pc != cpu.pc) {
        printf("pc is wrong\t ref:0x%08x\t yours:0x%08x\n", ref_r->pc, cpu.pc);
        return false;
    }
    for(reg_index = 0; reg_index < reg_nums; reg_index++) {
        if(ref_r->gpr[check_reg_idx(reg_index)] != gpr(reg_index)) {
            printf("reg[%d] (%s) is wrong\n ref_r's %s is 0x%08x \t my %s is 0x%08x\n", reg_index, reg_name(reg_index, 2), reg_name(reg_index, 2), ref_r->gpr[check_reg_idx(reg_index)], reg_name(reg_index, 2), gpr(reg_index));
            return false;
        }
    }
    /*printf("checkregs pass\n");*/
    return true;
}

void isa_difftest_attach() {

}
