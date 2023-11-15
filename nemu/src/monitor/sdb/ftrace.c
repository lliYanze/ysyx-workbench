#include <isa.h>


/*typedef struct __Ftrace_List{
    elf_func_info *cur_func; // 当前位置函数地址 
    elf_func_info *dst_func; // 目标位置函数地址
    paddr_t addr;       // 指令所在地址
    int type;           // call 或 return
    struct __Ftrace_List *next;
}ftrace_list;            // 用于记录函数调用栈*/

ftrace_list *ftrace_list_head = NULL;


elf_func_info find_func_by_addr(uint32_t addr) {
    for(int i = 0; i < 100; ++i) {
        if(elf_funcs[i].start <= addr && addr < elf_funcs[i].start + elf_funcs[i].size) {
            return elf_funcs[i];
        }
    }
    printf("can not find func by addr!\n");

    elf_func_info miss_func;
    char miss_name[64] = "?????????";
    strcpy(miss_func.name, miss_name);
    miss_func.start = 0;
    miss_func.size = 0;
    return miss_func;
}
