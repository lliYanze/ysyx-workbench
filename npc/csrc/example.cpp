#include "verilated.h"
#include <VTOP.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <svdpi.h>
#include <verilated_vcd_c.h>

VerilatedContext *contextp = new VerilatedContext;
VTOP *top = new VTOP{contextp};
VerilatedVcdC *mytrace = new VerilatedVcdC;

#define NPC_RUNNING 0
#define NPC_STOP 1
#define NPC_END 2
#define NPC_ABORT 3
#define NPC_QUIT 4

static int times = 0;
static int npc_state = NPC_RUNNING;

void single_cycle() {
  top->clock = 0;
  top->eval();
  mytrace->dump(times);
  ++times;

  top->clock = 1;
  top->eval();
  mytrace->dump(times);
  ++times;
}

void reset(int n) {
  top->reset = 1;
  while (n-- > 0)
    single_cycle();
  top->reset = 0;
}

void setnpcstate(int state) { npc_state = state; }
extern "C" void stopnpc() { setnpcstate(NPC_STOP); }

#include <getopt.h>
#include <unistd.h>

static char *img_file = NULL;
static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
      {"batch", no_argument, NULL, 'b'},
      {0, 0, NULL, 0},
  };
  int o;
  printf("argc = %d\n", argc);
  printf("argv[0] = %s\n", argv[0]);
  printf("argv[1] = %s\n", argv[1]);

  while ((o = getopt_long(argc, argv, "-b:", table, NULL)) != -1) {
    printf("optind = %d\n", o);
    switch (o) {
    case 1:
      img_file = optarg;
      printf("img_file = %s\n", img_file);
      return 0;
    default:
      printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
      printf("\n");
      exit(0);
    }
  }
  return 0;
}

typedef __uint8_t uint8_t;
typedef __uint16_t uint16_t;
typedef __uint32_t uint32_t;
typedef __uint64_t uint64_t;
#define PG_ALIGN __attribute((aligned(4096))) // 4kb 对齐

static uint8_t pmem[0x8000000] PG_ALIGN = {};

typedef uint32_t paddr_t;

typedef uint32_t word_t;

uint8_t *guest_to_host(paddr_t paddr) { return pmem + paddr - 0x80000000; }

static inline word_t host_read(void *addr, int len) {
  switch (len) {
  case 1:
    return *(uint8_t *)addr;
  case 2:
    return *(uint16_t *)addr;
  case 4:
    return *(uint32_t *)addr;
  }
  return 0;
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

long load_img() {
  if (img_file == NULL) {
    printf("No image file specified\n");
    exit(1);
  }

  FILE *fp = fopen(img_file, "rb");
  if (fp == NULL) {
    printf("Can not open '%s'\n", img_file);
    return 0;
  }

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  printf("Image '%s' size = %ld\n", img_file, size);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(0x80000000), size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;
}

int main(int arg, char **argv) {
  contextp->commandArgs(arg, argv);
  Verilated::mkdir("./build/logs");
  Verilated::traceEverOn(true);
  top->trace(mytrace, 5);
  mytrace->open("./build/logs/top.vcd");

  reset(1);

  /* while (NPC_RUNNING == npc_state) { */

  parse_args(arg, argv);
  long size = load_img();
  printf("size = %ld\n", size);
  printf("top->pc = 0x%x, \n", top->io_pc);
  top->io_inst = pmem_read(top->io_pc, 4);
  printf("inst = 0x%x\n", top->io_inst);
  single_cycle();

  /* printf("top->pc = 0x%x, \n", top->io_pc); */
  /* printf("top->out = 0x%x, \n", top->io_out); */
  /* printf("state is %d\n", npc_state); */
  /* } */
  mytrace->close();
  delete top;
}
