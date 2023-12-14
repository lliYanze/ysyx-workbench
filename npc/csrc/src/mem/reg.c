#include "./VTOP___024root.h"
#include <mem/reg.h>
#include <top.h>
// 寄存器名字为TOP__DOT__exu__DOT__regfile__DOT__regfile_0
#define R(index) &top->rootp->TOP__DOT__exu__DOT__regfile__DOT__regfile_##index

// word_t *preg[32];

void reg_init() {
  cpu.reg[0] = R(0);
  cpu.reg[1] = R(1);
  cpu.reg[2] = R(2);
  cpu.reg[3] = R(3);
  cpu.reg[4] = R(4);
  cpu.reg[5] = R(5);
  cpu.reg[6] = R(6);
  cpu.reg[7] = R(7);
  cpu.reg[8] = R(8);
  cpu.reg[9] = R(9);
  cpu.reg[10] = R(10);
  cpu.reg[11] = R(11);
  cpu.reg[12] = R(12);
  cpu.reg[13] = R(13);
  cpu.reg[14] = R(14);
  cpu.reg[15] = R(15);
  cpu.reg[16] = R(16);
  cpu.reg[17] = R(17);
  cpu.reg[18] = R(18);
  cpu.reg[19] = R(19);
  cpu.reg[20] = R(20);
  cpu.reg[21] = R(21);
  cpu.reg[22] = R(22);
  cpu.reg[23] = R(23);
  cpu.reg[24] = R(24);
  cpu.reg[25] = R(25);
  cpu.reg[26] = R(26);
  cpu.reg[27] = R(27);
  cpu.reg[28] = R(28);
  cpu.reg[29] = R(29);
  cpu.reg[30] = R(30);
  cpu.reg[31] = R(31);
}

const char *regsname[] = {"$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
                          "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
                          "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
                          "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};
#include <stdio.h>
void show_regs() {
  int i = 0;
  while (i < 32) {
    printf("%s\tis\t0x%08x\n", regsname[i], gpr(i));
    ++i;
  }
}
