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

#include <common.h>

extern uint64_t g_nr_guest_inst;
FILE *log_fp = NULL;
FILE *ftrace_fp = NULL;
FILE *etrace_fp = NULL;

void init_log(const char *log_file) {
  log_fp = stdout;
  if (log_file != NULL) {
    FILE *fp = fopen(log_file, "w");
    Assert(fp, "Can not open '%s'", log_file);
    log_fp = fp;
  }
  Log("Log is written to %s", log_file ? log_file : "stdout");
}

void init_ftrace_log(const char *ftrace_file) {
  ftrace_fp = stdout;
  if (ftrace_file != NULL) {
    FILE *fp = fopen(ftrace_file, "w");
    Assert(fp, "Can not open '%s'", ftrace_file);
    ftrace_fp = fp;
  }
  Log("Ftrace Log is written to %s", ftrace_file ? ftrace_file : "stdout");
}

void init_etrace_log(const char *etrace_file) {
  etrace_fp = stdout;
  if (etrace_file != NULL) {
    FILE *fp = fopen(etrace_file, "w");
    Assert(fp, "Can not open '%s'", etrace_file);
    etrace_fp = fp;
  }
  Log("Etrace Log is written to %s", etrace_file ? etrace_file : "stdout");
}

bool log_enable() {
  return MUXDEF(CONFIG_TRACE,
                (g_nr_guest_inst >= CONFIG_TRACE_START) &&
                    (g_nr_guest_inst <= CONFIG_TRACE_END),
                false);
}
