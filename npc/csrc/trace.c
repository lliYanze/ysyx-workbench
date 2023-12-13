#include "trace.h"
#include "macro.h"
#include <assert.h>
#include <elf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// elf文件读取
extern char *elf_file;
static Elf32_Off strtab_offset = 0;

elf_func_info elf_funcs[ELF_FUNC_NUM];

static long read_elf_header(Elf32_Ehdr *elf_header, FILE *fp) {
  fseek(fp, 0, SEEK_SET);
  if (elf_file == NULL) {
    log_write("No elf is given. Use the default build-in elf.");
    return -1;
  }
  size_t size_of_elf = fread(elf_header, sizeof(Elf32_Ehdr), 1, fp);
  // printf("size_of_elf = %ld\n", size_of_elf);

  fseek(fp, 0, SEEK_SET);
  if (elf_header->e_ident[0] != ELFMAG0 || elf_header->e_ident[1] != ELFMAG1 ||
      elf_header->e_ident[2] != ELFMAG2 || elf_header->e_ident[3] != ELFMAG3) {
    return -1;
  }
  return 0;
}

static Elf32_Off get_elf_strtab_offset(Elf32_Ehdr *elf_header, FILE *fp) {
  size_t sec_num = elf_header->e_shnum;
  int sec_begin = elf_header->e_shoff;

  fseek(fp, 0, SEEK_SET);
  // 得到shstrtab的位置
  size_t offset_of_shdr =
      elf_header->e_shoff + elf_header->e_shentsize * elf_header->e_shstrndx;

  Elf32_Shdr strtab_shdr;
  fseek(fp, sec_begin, SEEK_SET);
  for (int i = 0; i < sec_num; ++i) {
    size_t ret = fread(&strtab_shdr, sizeof(Elf32_Shdr), 1, fp);
    if (ret != 1) {
      printf("read strtab_shdr error!\n");
      return -1;
    }
    if (strtab_shdr.sh_type == SHT_STRTAB &&
        strtab_shdr.sh_offset != offset_of_shdr) {
      break;
    }
  }
  return strtab_shdr.sh_offset;
}

static long get_func_name(Elf32_Sym elfsym, FILE *fp, char *name) {
  fseek(fp, strtab_offset + elfsym.st_name, SEEK_SET);
  int ret = fscanf(fp, "%s", name);
  if (ret < 0) {
    printf("read name error!\n");
    return -1;
  }
  return 0;
}

static long get_func_info(Elf32_Ehdr *elf_header, FILE *fp) {
  size_t sec_num = elf_header->e_shnum;
  int sec_begin = elf_header->e_shoff;
  fseek(fp, sec_begin, SEEK_SET);

  Elf32_Shdr elfSec;
  Elf32_Sym elfSym;
  int func_index = 0;
  for (int i = 0; i < sec_num; ++i) {
    size_t result = fread(&elfSec, sizeof(Elf32_Shdr), 1, fp);
    if (result != 1) {
      printf("read elfSec error!\n");
      return -1;
    }
    if (elfSec.sh_type == SHT_SYMTAB) {
      size_t symtab_offset = elfSec.sh_offset;
      size_t entries = elfSec.sh_size / elfSec.sh_entsize;
      for (int j = 0; j < entries; ++j) {
        fseek(fp, symtab_offset + j * sizeof(Elf32_Sym), SEEK_SET);
        result = fread(&elfSym, sizeof(Elf32_Sym), 1, fp);
        if (result != 1) {
          printf("read elfSym error!\n");
          return -1;
        }

        if (ELF32_ST_TYPE(elfSym.st_info) == STT_FUNC) {

          get_func_name(elfSym, fp, elf_funcs[func_index].name);
          elf_funcs[func_index].start = elfSym.st_value;
          elf_funcs[func_index].size = elfSym.st_size;
          func_index++;
          assert(func_index < ELF_FUNC_NUM);
        }
      }
      elf_funcs[func_index].name[0] = '\0';
      break;
    }
  }
  return 0;
}

long load_elf() {
  FILE *fp = fopen(elf_file, "rb");
  Elf32_Ehdr elf_header;
  int ret = read_elf_header(&elf_header, fp);
  if (ret == -1) {
    printf("open elf error!\n");
    return -1;
  }
  strtab_offset = get_elf_strtab_offset(&elf_header, fp);
  get_func_info(&elf_header, fp);
  fclose(fp);
  return 0;
}

void show_func_info() {
  int i = 0;
  while (elf_funcs[i].name[0] != '\0') {
    printf("name = %s\n", elf_funcs[i].name);
    printf("start = %x\n", elf_funcs[i].start);
    printf("size = %u\n", elf_funcs[i].size);
    i++;
  }
}

// ftrace
ftrace_list *ftrace_list_head = NULL;

elf_func_info find_func_by_addr(uint32_t addr) {
  for (int i = 0; i < ELF_FUNC_NUM; ++i) {
    if (elf_funcs[i].start <= addr &&
        addr < elf_funcs[i].start + elf_funcs[i].size) {
      return elf_funcs[i];
    }
  }

  elf_func_info miss_func;
  char miss_name[64] = "?????????";
  strcpy(miss_func.name, miss_name);
  miss_func.start = 0;
  miss_func.size = 0;
  return miss_func;
}