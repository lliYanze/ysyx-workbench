#include "pmem.h"
#include "reg.h"
#include "top.h"

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
bool batch_mode = false;
int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
      {"batch", no_argument, NULL, 'b'},
      {"l", required_argument, NULL, 'f'},
      {0, 0, NULL, 0},
  };
  int o;
  int time = argc;

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
  printf("Log is written to %s\n", log_file ? log_file : "stdout");
}

void engine_init(int arg, char **argv) {
  wave_init(arg, argv);
  parse_args(arg, argv);
  load_img();
  log_init();
  preg_init();
}
