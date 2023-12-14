#include "./VTOP___024root.h"
#include <mem/reg.h>
#include <top.h>
// 寄存器名字为TOP__DOT__exu__DOT__regfile__DOT__regfile_0
#define R(index) &top->rootp->TOP__DOT__exu__DOT__regfile__DOT__regfile_##index

word_t *preg[32];

void reg_init() {
  preg[0] = R(0);
  preg[1] = R(1);
  preg[2] = R(2);
  preg[3] = R(3);
  preg[4] = R(4);
  preg[5] = R(5);
  preg[6] = R(6);
  preg[7] = R(7);
  preg[8] = R(8);
  preg[9] = R(9);
  preg[10] = R(10);
  preg[11] = R(11);
  preg[12] = R(12);
  preg[13] = R(13);
  preg[14] = R(14);
  preg[15] = R(15);
  preg[16] = R(16);
  preg[17] = R(17);
  preg[18] = R(18);
  preg[19] = R(19);
  preg[20] = R(20);
  preg[21] = R(21);
  preg[22] = R(22);
  preg[23] = R(23);
  preg[24] = R(24);
  preg[25] = R(25);
  preg[26] = R(26);
  preg[27] = R(27);
  preg[28] = R(28);
  preg[29] = R(29);
  preg[30] = R(30);
  preg[31] = R(31);
}

const char *regsname[] = {"$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
                          "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
                          "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
                          "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};
#include <stdio.h>
void show_regs() {
  printf("=====================npc regs=========================\n");
  int i = 0;
  while (i < 32) {
    printf("%s\tis\t0x%08x\n", regsname[i], gpr(i));
    ++i;
  }
  printf("--------------------------------------------------------\n");
}

void copyreg2cpu() {
  for (int i = 0; i < 32; ++i) {
    cpugpr(i) = gpr(i);
  }
}
