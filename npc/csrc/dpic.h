#ifndef DPIC_H
#define DPIC_H

#include "macro.h"

void setnpcstate(int state);
extern "C" void stopnpc(int state);

extern "C" void insttrace(uint32_t pc, uint32_t inst);

#endif // DPIC_H
