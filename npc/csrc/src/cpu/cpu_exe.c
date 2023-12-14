#include <cpu/cpu.h>
#include <macro.h>
#include <mem/pmem.h>
#include <top.h>

VerilatedContext *contextp = new VerilatedContext;
VTOP *top = new VTOP{contextp};
VerilatedVcdC *mytrace = new VerilatedVcdC;

CPU_state cpu = {};

void single_exe() { top->io_inst = pmem_read(top->io_pc, 4); }

static paddr_t now_pc = 0;
static paddr_t next_pc = 0;

static int times = 0;
void single_cycle() {
  top->clock = 0;
  top->eval();
  mytrace->dump(times);
  ++times;
  now_pc = top->io_pc;

  single_exe();

  top->clock = 1;
  top->eval();
  mytrace->dump(times);
  ++times;
  next_pc = top->io_pc;
}

void reset(int n) {
  top->reset = 1;
  while (n-- > 0) {
    top->clock = 0;
    top->eval();
    mytrace->dump(times);
    ++times;

    top->clock = 1;
    top->eval();
    mytrace->dump(times);
    ++times;
  }
  top->reset = 0;
}

#include <mem/reg.h>
void update_cpu() {
  cpu.pc = now_pc;
  copyreg2cpu();
}

static void exec_once() { single_cycle(); }

static void execute(uint64_t n) {
  for (; n > 0; n--) {
    exec_once();
    update_cpu();

    if (npc_state.state != NPC_RUNNING)
      break;
  }
}

void statistic() { printf("结束\n"); }

void cpu_exec(uint64_t n) {
  switch (npc_state.state) {
  case NPC_END:
  case NPC_ABORT:
    printf("Program execution has ended. To restart the program, exit npc and "
           "run again.\n");
    return;
  default:
    npc_state.state = NPC_RUNNING;
  }
  execute(n);
  switch (npc_state.state) {
  case NPC_RUNNING:
    npc_state.state = NPC_STOP;
    break;

  case NPC_END:
  case NPC_ABORT:
    printf("\nnemu: %s at pc = " FMT_WORD "\n",
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN)
                                    : ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED)),
           npc_state.halt_pc);
    // fall through
  case NPC_QUIT:
    statistic();
  }
}
