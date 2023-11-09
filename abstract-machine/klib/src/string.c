#include <klib-macros.h>
#include <klib.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

/*
 * null 返回0
 * 其余返回长度*/
size_t strlen(const char *s) {
  if (s == NULL) {
    return 0;
  }
  size_t len = 0;
  while (s[len] != '\0') {
    len++;
  }
  return len;
}

char *strcpy(char *dst, const char *src) {
  if (src == NULL) {
    return NULL;
  }

  size_t len_src = strlen(src);

  for (int i = 0; i < len_src; ++i) {
    dst[i] = src[i];
  }
  dst[len_src] = '\0';
  return dst;
  /*panic("Not implemented");*/
}
/*
 * 在dst后添加src
 * */
char *strncpy(char *dst, const char *src, size_t n) {
  panic("Not implemented");
}

char *strcat(char *dst, const char *src) {
  if (src == NULL) {
    return NULL;
  }

    size_t len_dst = strlen(dst);
    size_t len_src = strlen(src);

    for (int i = 0; i < len_src; ++i) {
        dst[len_dst + i] = src[i];
    }
    dst[len_dst + len_src] = '\0';
    return dst;

    /*panic("Not implemented"); */
}

/*
 *
 *  • 0, if the s1 and s2 are equal;
 *  • a negative value if s1 is less than s2;
 *  • a positive value if s1 is greater than s2.
 *
 * */
int strcmp(const char *s1, const char *s2) {
  if (s1 == NULL || s2 == NULL) {
    return 0;
  }
  if (strlen(s1) != strlen(s2)) {
    return strlen(s1) - strlen(s2);
  }
  int len = 0;
  while (s1[len] != '\0') {
    if (s1[len] != s2[len]) {
      return s1[len] - s2[len];
    }
    len++;
  }
  return 0;

}

int strncmp(const char *s1, const char *s2, size_t n) {
  panic("Not implemented");
}
/*
 * DESCRIPTION
 *The memset() function fills the first n bytes of the memory area pointed to by s with the constant byte c.
 * ETURN VALUE
 *       The memset() function returns a pointer to the memory area s.
*/
void *memset(void *s, int c, size_t n) { 
    void *ret = s;
    while(n--){
        *(char *)ret = c;
        ret = (char *)ret + 1;
    }
    return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  panic("Not implemented");
}

void *memcpy(void *out, const void *in, size_t n) { panic("Not implemented"); }

/*
 * 
 * DESCRIPTION
 *        The memcmp() function compares the first n bytes (each interpreted as unsigned char) of the memory areas s1 and s2.
 * 
 * RETURN VALUE
 *        The  memcmp()  function returns an integer less than, equal to, or greater than zero if the first n bytes of s1 is found, respectively, to be less than, to
 *        match, or be greater than the first n bytes of s2.
 * 
 *        For a nonzero return value, the sign is determined by the sign of the difference between the first pair of bytes (interpreted as unsigned char) that differ
 *        in s1 and s2.
 * 
 *        If n is zero, the return value is zero.
 * */

int memcmp(const void *s1, const void *s2, size_t n) {
    if(n == 0) {
        return 0;
    }
    while(n--){
        if(*(char *)s1 != *(char *)s2){
            return *(char *)s1 - *(char *)s2;
        }
        s1 = (char *)s1 + 1;
        s2 = (char *)s2 + 1;
    }
    return 0;
  /*panic("Not implemented");*/
}

#endif
