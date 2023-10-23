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

#include "debug.h"
#include "sdb.h"


/*#define NR_WP 32

typedef struct watchpoint {
    int NO;
    
    struct watchpoint *next;

  [> TODO: Add more members if necessary <]
    struct watchpoint *pre;
    char expr[32];
} WP;*/

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    if(i == 0){
        wp_pool[i].pre = NULL;
    }
    else{
        wp_pool[i].pre = &wp_pool[i - 1];
    }
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
    wp_pool[i].expr[0] = '\0';
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

WP* new_wp(char *express)
{
    if(free_ == NULL){
        printf("No more watchpoint!\n");
        assert(0);
    }
    WP* temp = free_;
    free_ = free_->next;
    head = temp;
    Assert(head != NULL, "head is NULL!");
    Assert(head->next == free_, "head->next is not free_! \n Maybe your breakpoints is wrong\n");
    if(head->expr[0] != '\0'){
        Log_RED("watch point 插入时 表达式太长\n");
    }
    //TODO: add watchpoint function 
    if(strlen(express) > 31) {
        printf("watchpoint expression is too long!\n");
        assert(0);
    }
    strcpy(temp->expr, express);

    return temp;
}


void free_wp(int num)
{
    if(head == NULL){
        printf("No watchpoint!\n");
        assert(0);
    }
    WP* temp = head;
    while(temp != NULL){
        if(temp->NO == num){
            break;
        }
        temp = temp->pre;
    }
    Assert(temp->NO == num, "watch point not fit\n");
    if(temp == head){
        head = head->pre;
        free_ = temp;
    }
    else{
        // 处理删除中间节点的情况
        if(temp->pre != NULL) {
            temp->pre->next = temp->next;
        }
        temp->next->pre = temp->pre;
        temp->pre = head;
        temp->next = free_;
        head->next = temp;
        free_->pre = temp;
        free_ = temp;
    }
    //清除删除节点的信息
    temp->expr[0] = '\0';
}

void show_points()
{
    for(WP* temp = head; temp != NULL; temp = temp->pre){
        printf("watchpoint %d: %s\n", temp->NO, temp->expr);
    }

}



