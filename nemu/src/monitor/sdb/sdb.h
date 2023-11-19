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

#ifndef __SDB_H__
#define __SDB_H__

#include <common.h>

#define NR_WP 32
#define NOT_HIT -100

typedef struct watchpoint {
    int NO;
    
    struct watchpoint *next;

  /* TODO: Add more members if necessary */
    struct watchpoint *pre;
    char expr[32];
    word_t value;
} WP;

void iringbuf_pop();

word_t expr(char *e, bool *success);

//初始化监视点池
void init_wp_pool();

/*
 * 申请一个监视点
 * @param express 监视点表达式
 * @return 返回监视点指针
 */
WP* new_wp(char *express);

/*
 * 删除一个监视点
 * @param num 监视点编号
 */
void free_wp(int num);

/*
 * 打印监视点信息
 */
void show_points();

/*
 * 检测监视点是否命中
 * @return 返回命中监视点编号，若没有命中则返回100
 */
word_t check_wp();


#endif
