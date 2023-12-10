#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/mem.h"
#include "/home/alan/Project/ysyx/ysyx-workbench/npc/csrc/macro.h"

#include <stdio.h>

extern NPCstate npc_state;


static uint8_t pmem[0x8000000] PG_ALIGN = {};

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

word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}


void test_trap() {

  printf("\nnemu: %s at pc = " FMT_WORD "\n",
         (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN)
                                  : ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED)),
         npc_state.halt_pc);
}



//***************************读入img文件

char *img_file = NULL;
int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
      {"batch", no_argument, NULL, 'b'},
      {0, 0, NULL, 0},
  };
  int o;

  while ((o = getopt_long(argc, argv, "-b:", table, NULL)) != -1) {
    switch (o) {
    case 1:
      img_file = optarg;
      return 0;
    default:
      printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
      printf("\n");
      exit(0);
    }
  }
  return 0;
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


