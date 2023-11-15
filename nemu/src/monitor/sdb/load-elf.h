#ifndef LOAD_ELF
#define LOAD_ELF 1
#include <isa.h>
#include <elf.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

//ftrace

/* read elf header 
 * return 0 success
 * return -1 failed*/
long read_elf_header(Elf32_Ehdr *elf_header, FILE *fp);

Elf32_Off get_elf_strtab_offset(Elf32_Ehdr *elf_header, FILE *fp);

long get_func_info(Elf32_Ehdr *elf_header, FILE *fp);

long get_func_name(Elf32_Sym , FILE *, char*);

void show_func_info();

long load_elf();


/**/

#endif /* ifndef LOAD_ELF */
