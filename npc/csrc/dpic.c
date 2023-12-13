#include "macro.h"
#include <VTOP.h>
#include <cstdint>
#include <cstdio>
#include <stdio.h>
#include <string.h>
#include <svdpi.h>

#include "top.h"
extern void set_npc_state(int state, vaddr_t pc, int halt_ret);

extern "C" void stopnpc(int state) {
  set_npc_state(NPC_END, top->io_pc, state);
}

// 环形缓冲区
#define IRING_BUF_SIZE 20
int first = 0;

#define PC_LEN 4
#define ONE_BUF_ZISE 128

static char itrace_buf[IRING_BUF_SIZE][ONE_BUF_ZISE] = {};
static unsigned int idx = 0;
static void fmt(char *p, uint32_t pc, uint32_t inst) {
  p += snprintf(p, sizeof(itrace_buf[idx]), FMT_WORD ":", pc);
  int ilen = PC_LEN;
  int i;
  uint8_t *code = (uint8_t *)&inst;
  for (i = ilen - 1; i >= 0; i--) {
    p += snprintf(p, 4, " %02x", code[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0)
    space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;
}

extern "C" void insttrace(uint32_t pc, uint32_t inst) {
  if (first == 0) {
    first = 1;
    return;
  }
  char *p = itrace_buf[idx];
  fmt(p, pc, inst);
  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

  disassemble(p, itrace_buf[idx] + sizeof(itrace_buf[idx]) - p, pc,
              (uint8_t *)&inst, PC_LEN);

  log_write("0x%08x: %s\n", pc, p);
}

#include "trace.h"

extern "C" void ftrace(uint32_t pc, uint32_t inst, uint32_t dst_addr) {
  uint32_t i = inst;
  static int space_num = 0;
  int rd = BITS(i, 11, 7);
  int rs1 = BITS(i, 19, 15);
  elf_func_info cur_func = find_func_by_addr(pc);
  elf_func_info dst_func = find_func_by_addr(dst_addr);
  if (rd == 1) {
    ftrace_log_write("0x%x: ", pc);
    ftrace_log_write("%s\t", cur_func.name);
    for (int i = 0; i < space_num; ++i) {
      ftrace_log_write("  ");
    }
    ftrace_log_write("call--> %s @[0x%x]\n", dst_func.name, dst_addr);
    space_num++;
  } else if (rd == 0 && rs1 == 1) {
    ftrace_log_write("0x%x: ", pc);
    ftrace_log_write("%s\t", cur_func.name);
    space_num--;
    for (int i = 0; i < space_num; ++i) {
      ftrace_log_write("  ");
    }
    ftrace_log_write("ret --> %s @[0x%x]\n", dst_func.name, dst_addr);
  }
}
