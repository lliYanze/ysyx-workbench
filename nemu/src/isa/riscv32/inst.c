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

#include "common.h"
#include "debug.h"
#include "local-include/reg.h"
#include "macro.h"
#include <cpu/cpu.h>
#include <cpu/ifetch.h>
#include <cpu/decode.h>


#define R(i) gpr(i)
#define Mr vaddr_read
#define Mw vaddr_write

#ifdef CONFIG_FTRACE_COND
static void ftrace(Decode *s , paddr_t dst_addr);
#endif

enum {
    TYPE_I, //短立即数和访存指令
    TYPE_U, //长立即数指令
    TYPE_S, //访存store指令
    TYPE_N, //无效指令 
    TYPE_J, //无条件跳转指令 
    TYPE_B, //条件跳转指令
    TYPE_R, //寄存器-寄存器操作
};

#define src1R() do { *src1 = R(rs1); } while (0)
#define src2R() do { *src2 = R(rs2); } while (0)
#define immI() do { *imm = SEXT(BITS(i, 31, 20), 12); } while(0)
#define immU() do { *imm = SEXT(BITS(i, 31, 12), 20) << 12; } while(0)
#define immS() do { *imm = (SEXT(BITS(i, 31, 25), 7) << 5) | BITS(i, 11, 7); } while(0)
#define immJ() do { *imm = (SEXT(BITS(i, 19, 12), 8) << 12) | (BITS(i, 30, 21) << 1) | (BITS(i, 20, 20) << 11)| (BITS(i, 31, 31) << 20) ;} while(0)
#define immB() do { *imm = (SEXT(BITS(i, 31, 31), 1) << 12) | (BITS(i, 7, 7) << 11) | (BITS(i, 30, 25) << 5) | (BITS(i, 11, 8) << 1); } while(0)


static void decode_operand(Decode *s, int *rd, word_t *src1, word_t *src2, word_t *imm, int type) {
    uint32_t i = s->isa.inst.val;
    int rs1 = BITS(i, 19, 15);
    int rs2 = BITS(i, 24, 20);
    *rd     = BITS(i, 11, 7);
    switch (type) {
        case TYPE_I: src1R();          immI(); break;
        case TYPE_U:                   immU(); break;
        case TYPE_S: src1R(); src2R(); immS(); break;
        case TYPE_J:                   immJ(); break;
        case TYPE_R: src1R(); src2R();         break;
        case TYPE_N: Assert(0, "无效的指令，可能需要添加该指令\n"); break;
        case TYPE_B: src1R(); src2R(); immB(); break;
    }
}

static int decode_exec(Decode *s) {
  int rd = 0;
  word_t src1 = 0, src2 = 0, imm = 0;
  s->dnpc = s->snpc;

#define INSTPAT_INST(s) ((s)->isa.inst.val)
#define INSTPAT_MATCH(s, name, type, ... /* execute body */ ) { \
  decode_operand(s, &rd, &src1, &src2, &imm, concat(TYPE_, type)); \
  __VA_ARGS__ ; \
}
    /*printf("-------flag-----\n");*/

    INSTPAT_START();
    /***********************************************/
    /******************** R ************************/
    /***********************************************/
    INSTPAT("0000000 ????? ????? 000 ????? 01100 11", add    , R, R(rd) = src1 + src2);
    INSTPAT("0100000 ????? ????? 000 ????? 01100 11", sub    , R, R(rd) = src1 - src2);
    INSTPAT("0000000 ????? ????? 100 ????? 01100 11", xor    , R, R(rd) = src1 ^ src2);
    INSTPAT("0000000 ????? ????? 110 ????? 01100 11", or     , R, R(rd) = src1 | src2);
    INSTPAT("0000000 ????? ????? 111 ????? 01100 11", and    , R, R(rd) = src1 & src2);
    INSTPAT("0000000 ????? ????? 001 ????? 01100 11", sll    , R, R(rd) = src1 << src2);

    INSTPAT("0000000 ????? ????? 011 ????? 01100 11", sltu   , R, R(rd) = (src1 < src2));
    /*-------------------*/

    INSTPAT("0000001 ????? ????? 100 ????? 01100 11", div    , R, R(rd) = src1 / src2);

    INSTPAT("0000001 ????? ????? 110 ????? 01100 11", rem    , R, R(rd) = src1 % src2);

    /***********************************************/
    /******************** I ************************/
    /***********************************************/
    INSTPAT("??????? ????? ????? 000 ????? 00100 11", addi   , I, R(rd) = src1 + imm);
    INSTPAT("??????? ????? ????? 100 ????? 00100 11", xori   , I, R(rd) = src1 ^ imm);
    INSTPAT("??????? ????? ????? 110 ????? 00100 11", ori    , I, R(rd) = src1 | imm);
    INSTPAT("??????? ????? ????? 111 ????? 00100 11", andi   , I, R(rd) = src1 & imm);

    INSTPAT("0000000 ????? ????? 001 ????? 00100 11", slli   , I, R(rd) = (src1 << imm));//逻辑左移
    INSTPAT("0000000 ????? ????? 101 ????? 00100 11", srli   , I, R(rd) = (src1 >> imm));//逻辑右移
    INSTPAT("0100000 ????? ????? 101 ????? 00100 11", srai   , I, R(rd) = ((int)src1 >> imm));//算数右移

    INSTPAT("??????? ????? ????? 011 ????? 00100 11", sltiu  , I, R(rd) = (src1 < imm));

    /*-------------------*/
    INSTPAT("??????? ????? ????? 010 ????? 00000 11", lw     , I, R(rd) = Mr(src1 + imm, 4));
    INSTPAT("??????? ????? ????? 100 ????? 00000 11", lbu    , I, R(rd) = Mr(src1 + imm, 1));

    /*-------------------*/
    INSTPAT("??????? ????? ????? ??? ????? 11001 11", jalr   , I, IFDEF(CONFIG_FTRACE, ftrace(s, s->pc+imm)); R(rd) = s->pc + 4; s->dnpc = src1 + imm;);

    INSTPAT("0000000 00001 00000 000 00000 11100 11", ebreak , I, NEMUTRAP(s->pc, R(10))); // R(10) is $a0

    /***********************************************/
    /******************** S ************************/
    /***********************************************/
    INSTPAT("??????? ????? ????? 000 ????? 01000 11", sb     , S, Mw(src1 + imm, 1, src2));
    INSTPAT("??????? ????? ????? 001 ????? 01000 11", sb     , S, Mw(src1 + imm, 2, src2));
    INSTPAT("??????? ????? ????? 010 ????? 01000 11", sw     , S, Mw(src1 + imm, 4, src2));


    /***********************************************/
    /******************** B ************************/
    /***********************************************/
    INSTPAT("??????? ????? ????? 000 ????? 11000 11", beq    , B, if(src1 == src2) s->dnpc = s->dnpc - 4 + imm);
    INSTPAT("??????? ????? ????? 001 ????? 11000 11", bne    , B, if(src1 != src2) s->dnpc = s->dnpc - 4 + imm);
    INSTPAT("??????? ????? ????? 100 ????? 11000 11", bne    , B, if(src1 < src2) s->dnpc = s->dnpc - 4 + imm);
    INSTPAT("??????? ????? ????? 101 ????? 11000 11", bge    , B, if((int)src1 >= (int)src2) s->dnpc = s->dnpc - 4 + imm);
    INSTPAT("??????? ????? ????? 110 ????? 11000 11", bltu   , B, if(src1 < src2) s->dnpc = s->dnpc - 4 + imm);
    INSTPAT("??????? ????? ????? 111 ????? 11000 11", bgeu    , B, if(src1 >= src2) s->dnpc = s->dnpc - 4 + imm);

    /***********************************************/
    /******************** J ************************/
    /***********************************************/
    INSTPAT("??????? ????? ????? ??? ????? 1011 11",  jal    , J, IFDEF(CONFIG_FTRACE, ftrace(s, s->pc+imm)); R(rd) = s->snpc ; s->dnpc = s->dnpc - 4 + imm);

    /***********************************************/
    /******************** U ************************/
    /***********************************************/
    INSTPAT("??????? ????? ????? ??? ????? 01101 11", lui    , U, R(rd) = imm;);
    INSTPAT("??????? ????? ????? ??? ????? 00101 11", auipc  , U, R(rd) = s->pc + imm);



    INSTPAT("??????? ????? ????? ??? ????? ????? ??", inv    , N, INV(s->pc));


    INSTPAT_END();

  R(0) = 0; // reset $zero to 0

  return 0;
}

int isa_exec_once(Decode *s) {
  s->isa.inst.val = inst_fetch(&s->snpc, 4);
  return decode_exec(s);
}


#ifdef CONFIG_FTRACE_COND
static void ftrace(Decode *s , paddr_t dst_addr) {
    uint32_t i = s->isa.inst.val;
    static int space_num = 0;
    int rd = BITS(i, 11, 7);
    int rs1 = BITS(i, 19, 15);
    elf_func_info cur_func = find_func_by_addr(s->pc);
    elf_func_info dst_func = find_func_by_addr(dst_addr);
    if(rd == 1) {
        ftrace_log_write("0x%x: ", s->pc);
        ftrace_log_write("%s\t", cur_func.name);
        for(int i = 0; i < space_num; ++i) {
            ftrace_log_write("  ");
        }
        ftrace_log_write("call--> %s @[0x%x]\n", dst_func.name, dst_addr);
        space_num++;
    } else if(rd == 0 && rs1 == 1) {
        ftrace_log_write("0x%x: ", s->pc);
        ftrace_log_write("%s\t", cur_func.name);
        space_num--;
        for(int i = 0; i < space_num; ++i) {
            ftrace_log_write("  ");
        }
        ftrace_log_write("ret --> %s @[0x%x]\n", dst_func.name, dst_addr);
    }
}
#endif
