#include <klib.h>
#include <klib-macros.h>
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
  panic("Not implemented");
}

char *strncpy(char *dst, const char *src, size_t n) {
  panic("Not implemented");
}

char *strcat(char *dst, const char *src) {
  panic("Not implemented");
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
    while(s1[len] != '\0') {
        if (s1[len] != s2[len]) {
            return s1[len] - s2[len];
        }
        len++;
    }
    return 0;

  /*panic("Not implemented");*/
}

int strncmp(const char *s1, const char *s2, size_t n) {
  panic("Not implemented");
}

void *memset(void *s, int c, size_t n) {
  panic("Not implemented");
}

void *memmove(void *dst, const void *src, size_t n) {
  panic("Not implemented");
}

void *memcpy(void *out, const void *in, size_t n) {
  panic("Not implemented");
}

int memcmp(const void *s1, const void *s2, size_t n) {
  panic("Not implemented");
}

#endif
