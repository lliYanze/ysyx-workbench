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

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

bool exit_flag = false;
enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
        TK_NUM,
        TK_HEXADDR,
};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */
    //正则表达式已经实现了 这里是正则表达式选择出来的 
    //比如 " +"是正则表达式中的空格重复至少1次 \\+是 \+ 所以正则不会将+当做正则中的元

    {" +", TK_NOTYPE},          // spaces
    {"\\+", '+'},               // plus
    {"==", TK_EQ},              // equal
    {"\\-", '-'},               // sub
    {"\\*", '*'},               // mul
    {"/", '/'},               // div
    {"[0-9]+", TK_NUM},         // numbers
    {"\\(", '('},               // (
    {"\\)", ')'},               // )
    {"\n", TK_NOTYPE},               // )
    
    {"q", 'q'},           // quit
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

#define Token_Size 4000
#define Token_Str_Size 32

typedef struct token {
  int type ;
  char str[Token_Str_Size];
} Token;

static Token tokens[Token_Size] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;
        Assert(nr_token <= Token_Size, "tokens的个数大于接受的tokens溢出了");
        Assert(substr_len <= Token_Size - 1, "token长度大于31 接受的token长度溢出了");

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
                    case TK_NOTYPE: break;
                    case TK_EQ:     printf("test == \n");        break;
                    case '+':       tokens[nr_token].type = '+';
                                    ++nr_token;
                                    printf("\n");
                                    break;
                    case '-':       tokens[nr_token].type = '-';
                                    ++nr_token;
                                    printf("\n");
                                    break;
                    case '*':       tokens[nr_token].type = '*';
                                    ++nr_token;
                                    printf("\n");
                                    break;
                    case '/':      tokens[nr_token].type = '/';
                                    ++nr_token;
                                    printf("\n");
                                    break;
                    case ')':       tokens[nr_token].type = ')';
                                    ++nr_token;
                                    printf("\n");
                                    break;
                    case '(':       tokens[nr_token].type = '(';
                                    ++nr_token;
                                    printf("\n");
                                    break;
                    case TK_NUM:    strncat(tokens[nr_token].str, substr_start, substr_len) ;        
                                    tokens[nr_token].str[substr_len] = '\0';
                                    tokens[nr_token].type = TK_NUM;
                                    ++nr_token;
                                    printf("\n");
                                    break;

                    case 'q':       exit_flag = true; break;

                    default: TODO();
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

    for(int i = 0; i < nr_token && tokens[i].type != 0; ++i) {
        Log("get tokens type is %d str is %s\n", tokens[i].type, tokens[i].str);


    }

  return true;
}

bool check_parentheses(int p, int q) {
    Assert(p < q, " 识别()时 表达式异常\n");
    if(tokens[p].type != '(' || tokens[q].type != ')') {
        return false;
    }
    int nums = 0;
    bool wrong_flag = false;
    bool wait_wrong_flag = false;
    bool true_flag = false;
    for(int i = p; i <= q; ++i) {
        if(tokens[i].type != ')' && tokens[i].type != '(') {
            continue;;
        }else if(tokens[i].type == '(') {
            if(wait_wrong_flag) wrong_flag = true;
            true_flag = true;
            ++nums;
        }else if(tokens[i].type == ')') {
            --nums;
            if(nums == 0) {
                wait_wrong_flag = true;
                continue;
            }
            if(nums < 0) {
                exit_flag = true;
                printf("false, bad expression\n");
                return false;
            }

        }
    }
    if(!wrong_flag && nums == 0 && true_flag ) {
        return  true;
    }
    if(nums > 0) {
        exit_flag = true;
        printf("()匹配失败");
    }

    return false;
}

int chartoint(char* change_char) {
    Assert(*change_char != '\0', "没有转换成int的char");
    int ret = *change_char - '0';
    ++change_char;
        
    for(;*change_char != '\0'; ++change_char) {
        ret *= 10;
        ret += (*change_char - '0');
    }
    Assert(ret >= 0, "char转换成int失败\n");
    return ret;
}


word_t eval(int p, int q) {
  if (p > q) {
    /* Bad expression */
        assert(0);
  }
  else if (p == q) {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
        int num = chartoint(tokens[p].str);
        if(num == 0) {
            printf("你输入了0么？\n");
        }
        return num;
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */



        return eval(p + 1, q - 1);
  }
  else {
        if(exit_flag) return 0;
        int op = 0;
        int main_token = 10;
        int flag = 0;
        for(int i = p; i <= q; ++i) {
            int token_type = tokens[i].type;
            if(token_type == '+' || token_type == '-') {
                token_type = 1;
            } else if(token_type == '*' || token_type == '/') {
                token_type = 2;
            } else if(token_type == '(') {
                flag++;
                /*Assert(flag >= 0, ")没有匹配\n");*/
            } else if(token_type == ')') {
                flag--;
                /*Assert(flag >= 0, ")没有匹配\n");*/
            } else {
                continue;
            }

            if(flag == 0 && main_token >= token_type) {
                op = i;
                main_token = token_type;
            }
        }
        Assert(op > 0, "主运算符位置不合理\n");
        int val1 = eval(p, op - 1);
        int val2 = eval(op + 1, q);

        switch (tokens[op].type) {
          case '+': 
                Log("====%d + %d = %d====\n",val1, val2, val1 + val2); 
                return val1 + val2;
          case '-': 
                Log("====%d - %d = %d====\n",val1, val2, val1 - val2); 
                return val1 - val2;
          case '*': 
                Log("====%d * %d = %d====\n",val1, val2, val1 * val2); 
                return val1 * val2;
          case '/': 
                Log("====%d / %d = %d====\n",val1, val2, val1 / val2); 
                return val1 / val2;
          default: assert(0);
        }
  }
    assert(0);
    return 0;
}

void clear_tokens() {
    for(int i = 0; i < Token_Size; ++i) {
        tokens[i].type = 0;
        for(int j = 0; j < Token_Str_Size && tokens[i].str[j] != '\0'; ++j){
            tokens[i].str[j] = '\0';
        }
    }
}

word_t expr(char *e, bool *success) {
    clear_tokens();
    
    
  if (!make_token(e)) {
    *success = false;
    printf("无效表达式");
    return 0;
  }
    if(exit_flag) goto exit;

  /* TODO: Insert codes to evaluate the expression. */
  /*TODO();*/
    int p = 0;
    int q = 0;
    for(; q < Token_Size && tokens[q].type != 0; ++q);
    /*Assert((--q)>0, "未识别到有效表达式\n");*/
    if(--q <= 0) {
        Log_RED("未识别到有效的表达式\n");
        goto exit;
    }
    

    int ret = eval(p, q);

  return ret;

exit:
    exit_flag = false;
    printf("退出计算器模式\n");
    return 0;

}
