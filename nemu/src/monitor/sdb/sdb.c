/***************************************************************************************
 * Copyright (c) 2014-2022 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan
 *PSL v2. You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
 *KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 *NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include "sdb.h"
#include "common.h"
#include <cpu/cpu.h>
#include <isa.h>
#include <memory.h>
#include <memory/paddr.h>
#include <readline/history.h>
#include <readline/readline.h>
#include <utils.h>

word_t vaddr_read(vaddr_t addr, int len);
word_t paddr_read(vaddr_t addr, int len);
extern NEMUState nemu_state;

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin.
 */
static char *rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) { 
    nemu_state.state = NEMU_QUIT;
    return -1; 
}

static int cmd_help(char *args);

static int cmd_si(char *args);

static int cmd_info(char *args);

static int cmd_x(char *args);

static int cmd_cal(char *args);

static int cmd_cal_test(char *args);

static int cmd_b(char *args);

static int cmd_d(char *args);

static int cmd_w(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler)(char *);
} cmd_table[] = {
    {"help", "Display information about all supported commands", cmd_help},
    {"c", "Continue the execution of the program", cmd_c},
    {"q", "Exit NEMU", cmd_q},

    /* TODO: Add more commands */
    {"si", "run program step by step", cmd_si},
    {"info", "show reg info", cmd_info},
    {"x", "show data info ", cmd_x},
    {"cal", "calculate", cmd_cal},
    {"cal_test", "calculate", cmd_cal_test},
    {"b", "add break points", cmd_b},
    {"d", "delect break points", cmd_d},
    {"w", "set break point", cmd_w},
};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  } else {
    for (i = 0; i < NR_CMD; i++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

//单步调试
static int cmd_si(char *args) {
  /*printf("this test si\n");*/
  /*printf("get line : %s\n", args);*/
  char *get_step_num = strtok(args, " ");
  int step_num = 1;
  if (get_step_num != NULL) {
    step_num = strtoimax(get_step_num, NULL, 0);
  }
  cpu_exec(step_num);
  printf("have run %d times\n", step_num);
  return 0;
}

static int cmd_info(char *args) {
  char *regname = strtok(args, " ");
  if (regname == NULL) {
    printf("please add the reg name \n");
    return 0;
  }
  switch (*regname) {
  case 'r':
    isa_reg_display();
    break;
  case 'b':
    show_points();
    break;
  default:
    printf("please info the right reg\n");
  }
  return 0;
}

static int cmd_x(char *args) {
  char *str = NULL;
  char *token = NULL;
  char *get_param[2] = {NULL, NULL};
  str = args;
  printf("str is %s \n", str);
  for (int i = 0;; ++i, str = NULL) {
    token = strtok(str, " ");
    if (token == NULL) {
      break;
    }
    if (i > 1) {
      printf("too many param ,please give me two\n");
      return 0;
    }
    get_param[i] = token;
  }
  if (get_param[0] == NULL || get_param[1] == NULL) {
    printf("too less param ,please give me two\n");
    return 0;
  }
  int data_size = strtoimax(get_param[0], NULL, 0);
  vaddr_t data_addr = (vaddr_t)strtoumax(get_param[1], NULL, 16);
  printf("data_size is %d\n", data_size);
  printf("data_addr is 0x%x\n", data_addr);

  for (int i = 0; i < data_size*4; i = i +4) {
    printf("0x%08x \n", vaddr_read(data_addr, 4));
    data_addr += 4;
  }
  return 0;
}

static int cmd_cal(char *args) {
  printf("now you can calculate\n");
  char *calculate_str = NULL;
  if (calculate_str) {
    free(calculate_str);
    calculate_str = NULL;
  }
  word_t result = 0;

  do {
    calculate_str = readline("calculate # ");
    bool is_success = true;
    Assert(calculate_str != NULL, "calculate is NULL\n");
    if (*calculate_str) {
      add_history(calculate_str);
    }
    result = expr(calculate_str, &is_success);
    if (!is_success) {
      printf("get wrong token\n");
    }
    printf("%s = 0x%x\n", calculate_str, result);
  } while (strcmp(calculate_str, "q") != 0);

  return 0;
}

static int cmd_b(char *args) {
  char *get_express = args;
  if (get_express == NULL) {
    printf("please add the express\n");
    return 0;
  }
  new_wp(get_express);
  printf("add watchpoint success\n");

  return 0;
}

static int cmd_d(char *args) {
  int delect_nums[NR_WP];
  int counts = 0;
  char *str = args;
  for (int i = 0;; ++i, str = NULL) {
    char *delect_num = strtok(str, " ");
    if (delect_num == NULL) {
      break;
    }
    int num = strtoimax(delect_num, NULL, 0);
    if (num > NR_WP || num < 0) {
      printf("delect num is wrong. 0<= num <= 31\n");
      return -1;
    }
    delect_nums[i] = num;
    counts++;
  }
  for (; counts > 0; --counts) {
    free_wp(delect_nums[counts - 1]);
  }
  return 0;
}

static int cmd_w(char *args) {
  char *get_express = args;
  if (get_express == NULL) {
    printf("please add the express\n");
    return 0;
  }
  new_wp(get_express);
  printf("add watchpoint success\n");

  return 0;
}

void sdb_set_batch_mode() { is_batch_mode = true; }

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL;) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) {
      continue;
    }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) {
          return;
        }
        break;
      }
    }

    if (i == NR_CMD) {
      printf("Unknown command '%s'\n", cmd);
    }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}

static int cmd_cal_test(char *args) {
  FILE *fp = fopen(
      "/home/alan/Project/ysyx/ysyx-workbench/nemu/tools/gen-expr/express.log",
      "r");
  assert(fp != NULL);
    //清空log
  FILE *fpwrite = fopen(
      "/home/alan/Project/ysyx/ysyx-workbench/nemu/log/cal_log/write.log", "w");
  FILE *fpwrong = fopen(
          "/home/alan/Project/ysyx/ysyx-workbench/nemu/log/cal_log/wrong.log", "w");
  assert(fp != NULL && fpwrong != NULL && fpwrite != NULL);
  fputs("=========\n", fpwrite);
  fputs("=========\n", fpwrong);
  fclose(fpwrong);
  fclose(fpwrite);

  char get_one_line[65536] = {};
  unsigned result = 0;
  int cal_result = 0;
  char express[65535];
  while (fgets(get_one_line, 65535, fp) != NULL) {
    printf("get line %s\n", get_one_line);
    bool express_flag = false;
    int express_begin = 0;

      FILE *fpwrite = fopen(
          "/home/alan/Project/ysyx/ysyx-workbench/nemu/log/cal_log/write.log", "a");
      FILE *fpwrong = fopen(
          "/home/alan/Project/ysyx/ysyx-workbench/nemu/log/cal_log/wrong.log", "a");
      assert(fp != NULL && fpwrong != NULL && fpwrite != NULL);
    for (int i = 0; get_one_line[i] != '\n'; ++i) {
      if (!express_flag) {
        result *= 10;
        result += get_one_line[i] - '0';
        if (get_one_line[i + 1] == ' ') {
          express_flag = true;
          express_begin = ++i;
        }
      } else {
        Assert(i - express_begin - 1 >= 0, "表达式识别错误\n");
        express[i - express_begin - 1] = get_one_line[i];
        express[i - express_begin] = '\0';
      }
    }
    printf("result is %u, express is %s\n", result, express);
    bool *is_success = false;
    assert(express != NULL);
    cal_result = expr(express, is_success);
    if (cal_result == result) {
      fprintf(fpwrite, "express is %s\n cal_result = %d, result is %d\n",
              express, cal_result, result);
      fputs("=========\n", fpwrite);
    } else {
      fprintf(fpwrong, "express is %s\n cal_result = %d, result is %d\n",
              express, cal_result, result);
      fputs("=========\n", fpwrong);

      /*printf("wrong, result is %d, cal_result is %d\n express is %s", result,
       * cal_result, express);*/
    }
      fclose(fpwrong);
      fclose(fpwrite);

    result = 0;
  }
  fclose(fp);
  return 0;
}
