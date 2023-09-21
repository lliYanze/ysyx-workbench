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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

int buf_index = 0;
int gen_depth = 0;

enum {
    BEGIN = 0,NUM, OP, PAREN_LEFT, PAREN_RIGHT,
};
int gen_pre_status = BEGIN;

static void gen_rand_op();

static void gen_num() {
    if(gen_pre_status == PAREN_RIGHT) { //不可以在括号后直接生成数字
        gen_rand_op();
        return;
    }
    int rand_range = 0;
    // 第一个数字不可以是0
    if(gen_pre_status == NUM) {
        rand_range = 10;
    } else {
        rand_range = 9;
    }
    assert(rand_range == 9 || rand_range == 10);
    switch(rand() % rand_range) {
        case 0: buf[buf_index++] = '1';break;
        case 1: buf[buf_index++] = '2';break;
        case 2: buf[buf_index++] = '3';break;
        case 3: buf[buf_index++] = '4';break;
        case 4: buf[buf_index++] = '5';break;
        case 5: buf[buf_index++] = '6';break;
        case 6: buf[buf_index++] = '7';break;
        case 7: buf[buf_index++] = '8';break;
        case 8: buf[buf_index++] = '9';break;
        case 9: buf[buf_index++] = '0';break;
        default: break;
    }
    gen_pre_status = NUM;
}

static void gen_rand_op() {
    if(gen_pre_status == BEGIN || gen_pre_status == OP || gen_pre_status == PAREN_LEFT) {//最开始不可以生成符号
        return;
    }
    assert(!(gen_pre_status == BEGIN || gen_pre_status == OP || gen_pre_status == PAREN_LEFT));
    switch(rand() % 4) {
        case 0: buf[buf_index++] = '+';break;
        case 1: buf[buf_index++] = '-';break;
        case 2: buf[buf_index++] = '*';break;
        case 3: buf[buf_index++] = '/';break;
        default: break;
    }
    gen_pre_status = OP;
}

static void gen_paren(char parn_flag) {
    switch(parn_flag) {
        case '(' : buf[buf_index++] = '(';  gen_pre_status = PAREN_LEFT;break;
        default: buf[buf_index++] = ')'; gen_pre_status = PAREN_RIGHT; break;
    }
}


static void gen_rand_expr() {
    if(gen_depth >= 30000) {
        return;
    }
    switch(rand() % 3) {
        case 0 : gen_num();break;
        case 1 : gen_paren('('); gen_rand_expr(); gen_paren(')');break;
        default: gen_rand_expr(); gen_rand_op(); gen_rand_expr();break;
    }
    ++gen_depth;
  /*buf[0] = '\0';*/
}


int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    gen_rand_expr();
    assert(buf_index < 65535);
    assert(gen_depth < 65535);
    gen_pre_status = BEGIN;

    buf[buf_index] = '\0';
    buf[65535] = '\0';

    buf_index = 0;
    gen_depth = 0;

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
