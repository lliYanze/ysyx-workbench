#include "mem.h"
#include "macro.h"

#include <stdio.h>

extern NPCstate npc_state;

uint8_t *guest_to_host(paddr_t paddr);

word_t pmem_read(paddr_t addr, int len);
