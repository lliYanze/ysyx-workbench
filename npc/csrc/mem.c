#include "mem.h"
#include "macro.h"

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

void show_mem(paddr_t addr, int len) {
  while (len-- > 0) {
    printf("0x%02x ", pmem_read(addr, 4));
    addr++;
    printf("\n");
  }
}

void test_trap() {

  printf("\nnemu: %s at pc = " FMT_WORD "\n",
         (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN)
                                  : ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED)),
         npc_state.halt_pc);
}

//***************************读入img文件

char *img_file = NULL;
char *log_file = NULL;
extern bool batch_mode;
int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
      {"batch", no_argument, NULL, 'b'},
      {"l", required_argument, NULL, 'f'},
      {0, 0, NULL, 0},
  };
  int o;
  int time = argc;
  while (time--) {
    printf("%s\n", argv[time]);
  }

  while ((o = getopt_long(argc, argv, "-bl:", table, NULL)) != -1) {
    switch (o) {
    case 'b':
      batch_mode = true;
      break;
    case 'l':
      log_file = optarg;
      break;
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

FILE *log_fp = NULL;

void log_init() {
  log_fp = stdout;
  if (log_file != NULL) {
    FILE *fp = fopen(log_file, "w");
    if (fp == NULL) {
      printf("Can not open '%s'\n", log_file);
      assert(0);
    }
    log_fp = fp;
  }
  printf("Log is written to %s\n", log_file ? log_file : "stdout");
}
