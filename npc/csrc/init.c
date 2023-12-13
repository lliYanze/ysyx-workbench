#include "pmem.h"
#include "reg.h"
#include "top.h"
#include <svdpi.h>

void wave_init(int arg, char **argv) {
  contextp->commandArgs(arg, argv);
  Verilated::mkdir("./build/logs");
  Verilated::traceEverOn(true);
  top->trace(mytrace, 5);
  mytrace->open("./build/logs/top.vcd");
}

#include <getopt.h>
#include <unistd.h>

char *img_file = NULL;
char *log_file = NULL;
char *elf_file = NULL;
char *ftrace_file = NULL;
bool batch_mode = false;
int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
      {"batch", no_argument, NULL, 'b'},
      {"log-file", required_argument, NULL, 'l'},
      {"elf-file", required_argument, NULL, 'e'},
      {"ftrace-file", required_argument, NULL, 'f'},
      {0, 0, NULL, 0},
  };
  int o;
  int time = argc;

  while ((o = getopt_long(argc, argv, "-bl:e:f:", table, NULL)) != -1) {
    switch (o) {
    case 'b':
      batch_mode = true;
      break;
    case 'l':
      log_file = optarg;
      break;
    case 'e':
      elf_file = optarg;
      break;
    case 'f':
      ftrace_file = optarg;
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

#include <assert.h>
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
  printf("Trace Log is written  to %s\n", log_file ? log_file : "stdout");
}

FILE *ftrace_fp = NULL;

void ftrace_init() {
  ftrace_fp = stdout;
  if (ftrace_file != NULL) {
    FILE *fp = fopen(ftrace_file, "w");
    if (fp == NULL) {
      printf("Can not open '%s'\n", ftrace_file);
      assert(0);
    }
    ftrace_fp = fp;
  }
  printf("Ftrace Log is written  to %s\n",
         ftrace_file ? ftrace_file : "stdout");
}

#include "trace.h"

extern "C" void init_disasm(const char *triple);
void engine_init(int arg, char **argv) {
  wave_init(arg, argv);
  parse_args(arg, argv);
  load_img();
  log_init();
  preg_init();
  init_disasm("riscv32"
              "-pc-linux-gnu");
  load_elf();
  ftrace_init();
}
