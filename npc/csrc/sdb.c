#include "sdb.h"
#include "./VTOP___024root.h"
#include "mem.h"
#include <verilated_vcd_c.h>

#include <VTOP.h>
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>

extern VTOP *top;
extern NPCstate npc_state;
extern VerilatedVcdC *mytrace;

// 寄存器名字为TOP__DOT__exu__DOT__regfile__DOT__regfile_0
//

#define R(index) &top->rootp->TOP__DOT__exu__DOT__regfile__DOT__regfile_##index

unsigned int *preg[32];

void preg_init() {
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

void show_regs() {
  int i = 0;
  while (i < 32) {
    printf("%s\tis\t0x%08x\n", regsname[i], *preg[i]);
    ++i;
  }
}

static int times = 0;
void single_exe() { top->io_inst = pmem_read(top->io_pc, 4); }

void single_cycle() {
  top->clock = 0;
  top->eval();
  mytrace->dump(times);
  ++times;

  single_exe();

  top->clock = 1;
  top->eval();
  mytrace->dump(times);
  ++times;
}

void reset(int n) {
  top->reset = 1;
  while (n-- > 0) {
    top->clock = 0;
    top->eval();
    mytrace->dump(times);
    ++times;

    top->clock = 1;
    top->eval();
    mytrace->dump(times);
    ++times;
  }
  top->reset = 0;
}

extern bool batch_mode;

void sdb_mainloop() {

  if (batch_mode) {
    while (NPC_RUNNING == npc_state.state) {
      single_cycle();
    }
  } else {
    while (NPC_RUNNING == npc_state.state) {
      std::cout << "[NPC :>]";
      std::string getcmd;
      std::getline(std::cin, getcmd);
      std::vector<std::string> cmdlist;
      std::string split{};
      for (auto begin = getcmd.begin(), end = getcmd.end(); begin != end;
           ++begin) {

        if (*begin == ' ') {
          if (split.size() > 0) {
            cmdlist.push_back(split);
            split.clear();
            continue;
          } else {
            continue;
          }
        }
        if (begin == end - 1) {
          split.push_back(*begin);
          cmdlist.push_back(split);
        }
        split.push_back(*begin);
      }

      switch (cmdlist[0][0]) {
      case 'c':
        single_cycle();
        break;
      case 'r':
        show_regs();
        break;
      case 'm': {
        int len = 0;
        if (cmdlist.size() == 2) {
          len = 1;
        } else if (cmdlist.size() == 3) {
          len = std::stoul(cmdlist[2], 0, 10);
        } else {
          printf("Usege: \n \
                                m addr [len]\n");
        }
        paddr_t addr = std::stoul(cmdlist[1], 0, 16);
        show_mem(addr, len);
        break;
      }
      case 'q':
        npc_state.state = NPC_QUIT;
        break;
      case 's':
        while (NPC_RUNNING == npc_state.state) {
          single_cycle();
        }
        npc_state.state = NPC_QUIT;
        break;
      default:
        printf("Usege: \n \
                c: cycle\n \
                r: regs\n \
                q: quit\n");

        break;
      }
    }
  }
}

void ftrace_init() {}
