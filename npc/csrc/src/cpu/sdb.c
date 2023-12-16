#include <cpu/cpu.h>
#include <cpu/sdb.h>
#include <macro.h>
#include <mem/pmem.h>
#include <mem/reg.h>

#include <iomanip>
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>

extern paddr_t now_pc;
std::vector<std::string> cl_rd() {
  std::cout << "[NPC 0x" << std::hex << std::setw(8) << std::setfill('0')
            << now_pc << ":>]";
  std::string getcmd;
  std::getline(std::cin, getcmd);
  std::vector<std::string> cmdlist;
  std::string split{};
  for (auto begin = getcmd.begin(), end = getcmd.end(); begin != end; ++begin) {

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
  return cmdlist;
}

extern void cpu_exec(uint64_t n);

extern bool batch_mode;

void sdb_mainloop() {
  reset(1);
  if (batch_mode) {
    cpu_exec(-1);
    return;
  } else {
    // while (NPC_RUNNING == npc_state.state) {
    std::vector<std::string> cmdlist{};
    while (cmdlist = cl_rd(), cmdlist.size() > 0) {
      switch (cmdlist[0][0]) {
      case 'b':
        if (cmdlist.size() == 2) {
          while (1) {
            cpu_exec(1);
            if (now_pc == std::stoul(cmdlist[1], 0, 16)) {
              break;
            }
          }
        } else {
          printf("Usege: \n \
                b [addr]\n");
        }
      case 'c':
        cpu_exec(1);
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
        return;
      case 's':
        cpu_exec(-1);
        return;
      default:
        printf("Usege: \n \
                c: cycle\n \
                m: mem\n \
                s: run\n \
                r: regs\n \
                q: quit\n");

        break;
      }
    }
  }
}
