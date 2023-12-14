#ifndef TRACE_H
#define TRACE_H
#include "macro.h"

// ftrace
#define ELF_FUNC_NUM 2048
#define ELF_FUNC_NAME_LEN 64
typedef struct __Elf_Func_Info {
  char name[ELF_FUNC_NAME_LEN];
  uint32_t start;
  uint32_t size;
} elf_func_info;
elf_func_info find_func_by_addr(uint32_t addr);

typedef struct __Ftrace_List {
  elf_func_info cur_func; // 当前位置函数地址
  elf_func_info dst_func; // 目标位置函数地址
  paddr_t addr;           // 指令所在地址
  int type;               // call 或 return
  struct __Ftrace_List *next;
  struct __Ftrace_List *pre;
} ftrace_list;                                // 用于记录函数调用栈
extern elf_func_info elf_funcs[ELF_FUNC_NUM]; // 这里不用extern就会报错
extern ftrace_list *ftrace_list_head;

long load_elf();

#endif // !TRACE_H
