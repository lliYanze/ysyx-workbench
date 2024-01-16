#include <VTOP.h>
#include <config.h>
#include <cpu/difftest/difftest.h>
#include <cstdint>
#include <cstdio>
#include <device/device.h>
#include <macro.h>
#include <stdio.h>
#include <string.h>
#include <svdpi.h>

#include <top.h>
extern void set_npc_state(int state, vaddr_t pc, int halt_ret);

extern paddr_t now_pc;

extern "C" void stopnpc(int state) { set_npc_state(NPC_END, now_pc, state); }

#ifdef TRACE
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

#endif

extern "C" void insttrace(uint32_t pc, uint32_t inst) {
#ifdef TRACE
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
#endif
}

#include <utils/trace.h>

extern "C" void ftrace(uint32_t pc, uint32_t inst, uint32_t dst_addr) {
#ifdef FTRACE
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
      ftrace_log_write(" ");
    }
    ftrace_log_write("call--> %s @[0x%x]\n", dst_func.name, dst_addr);
    space_num++;
  } else if (rd == 0 && rs1 == 1) {
    ftrace_log_write("0x%x: ", pc);
    ftrace_log_write("%s\t", cur_func.name);
    space_num--;
    for (int i = 0; i < space_num; ++i) {
      ftrace_log_write(" ");
    }
    ftrace_log_write("ret --> %s @[0x%x]\n", dst_func.name, dst_addr);
  }
#endif
}

#include <mem/pmem.h>

#include <sys/time.h>
uint64_t begin_time = 0;

static uint64_t get_time() {
  struct timeval now;
  gettimeofday(&now, NULL);
  uint64_t us = now.tv_sec * 1000000 + now.tv_usec;
  if (begin_time == 0) {
    begin_time = us;
  }
  uint64_t now_time = us - begin_time;
  return now_time;
}

static uint32_t rtc_time[2];

extern "C" int data_read(paddr_t addr, svBitVecVal *wmask, svBit valid) {
  if (addr == RTC_ADDR) {

    difftest_skip_ref();
    log_write(" --时钟设备(0x%08x) 读取到  0x%08x\n", addr, rtc_time[0]);
    return rtc_time[0];
  }
  if (addr == RTC_ADDR + 4) {
    uint64_t now_time = get_time();
    rtc_time[0] = (uint32_t)now_time;
    rtc_time[1] = (uint32_t)(now_time >> 32);

    difftest_skip_ref();
    log_write(" --时钟设备(0x%08x) 读取到  0x%08x\n", addr, rtc_time[1]);

    return rtc_time[1];
  }

  if (addr == 0x00000000 || valid == 0x0 || addr < 0x80000000 ||
      addr > 0x80000000 + 0xfffffff)
    return 0;
  int buf = 0;
  log_write(" md5从 0x%08x \n ", addr);
  if (*wmask == 0x0) {
    word_t lowbyte = pmem_read(addr, 1);
    buf = SEXT(lowbyte, 8); // 有符号数扩展
  } else if (*wmask == 0x1) {
    word_t lowbyte = pmem_read(addr, 2);
    buf = SEXT(lowbyte, 16);
  } else if (*wmask == 0x2)
    buf = pmem_read(addr, 4);
  else if (*wmask == 0x4)
    buf = pmem_read(addr, 1);
  else if (*wmask == 0x5)
    buf = pmem_read(addr, 2);
  else {
    printf("data_read wmask is 0x%x   wrong\n", *wmask);
    assert(0);
  }
  log_write(" 从 0x%08x 读取到  0x%08x\n", addr, buf);
  return buf;
}

extern "C" void data_write(paddr_t addr, int buf, svBitVecVal *wmask) {

  if (addr == SERIAL_PORT) {
    if (*wmask == 0x2) {
      putchar(buf);
      fflush(stdout);
    }
    difftest_skip_ref();
    log_write("向串口(0x%08x) 写入 0x%08x  mask is %d\n", addr, buf, *wmask);

    return;
  }
  if (*wmask == 0x0)
    pmem_write(addr, buf, 1);
  else if (*wmask == 0x1)
    pmem_write(addr, buf, 2);
  else if (*wmask == 0x2)
    pmem_write(addr, buf, 4);
  else if (*wmask == 0x4)
    pmem_write(addr, buf, 1);
  else if (*wmask == 0x5)
    pmem_write(addr, buf, 2);
  else if (*wmask == 0x7)
    return;
  else {
    printf("wmask is 0x%x   wrong\n", *wmask);
    assert(0);
  }
  log_write("向 0x%08x 写入 0x%08x  mask is %d\n", addr, buf, *wmask);
}
