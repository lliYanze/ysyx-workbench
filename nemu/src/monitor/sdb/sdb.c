/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"
#include <memory.h>
#include <memory/paddr.h>


word_t vaddr_read(vaddr_t addr, int len);
word_t paddr_read(vaddr_t addr, int len);

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
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
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args);

static int cmd_info(char *args);

static int cmd_x(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
    { "help", "Display information about all supported commands", cmd_help },
    { "c", "Continue the execution of the program", cmd_c },
    { "q", "Exit NEMU", cmd_q },

  /* TODO: Add more commands */
    { "si", "run program step by step", cmd_si},
    { "info", "show reg info", cmd_info},
    { "x", "show data info ", cmd_x},
};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
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
    char* get_step_num = strtok(args, " ");
    int step_num = 1;
    if(get_step_num != NULL) {
        step_num = strtoimax(get_step_num, NULL, 0);
    }
    cpu_exec(step_num);
    printf("have run %d times\n", step_num);
    return 0;
}

static int cmd_info(char *args) {
    char* regname = strtok(args, " ");
    if(regname == NULL) {
        printf("please add the reg name \n");
        return 0;
    }
    switch (*regname) {
        case 'r' : isa_reg_display();break;
        default: printf("please info the right reg\n");
    }
    return 0;
}

static int cmd_x(char *args) {
    char *str = NULL;
    char *token = NULL;
    char* get_param[2];
    str = args;
    printf("str is %s \n", str);
    for(int i = 0; ;++i, str = NULL) {
        token = strtok(str, " ");
        if(token == NULL) {
            break;
        }
        if(i > 1) {
            printf("too many param ,please give me two\n");
            return 0;
        }
        get_param[i] = token;

    }
    if(get_param[0] == NULL || get_param[1] == NULL) {
        printf("too less param ,please give me two\n");
    }
    int data_size = strtoimax(get_param[0], NULL, 0);
    vaddr_t data_addr = (vaddr_t)strtoul(get_param[1], NULL, 16);
    printf("data_size is %d\n", data_size);

    for(int i = 0; i < data_size; ++i) {
        printf("0x%08x \n", vaddr_read(data_addr, 4));
        data_addr += 4;
    }
    return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

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
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
