#include <am.h>
#include <klib-macros.h>
#include <klib.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static int int_to_str(int num, char *str, int base) {
  int i = 0;
  int len = 0; //记录长度
  if (num == 0) {
    str[i++] = '0';
    str[i] = '\0';
    return 1;
  }
  if (num < 0)
    num = -num;
  while (num) {
    int rem = num % base;
    str[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
    num = num / base;
    ++len;
  }
  if (num < 0) {
    str[i++] = '-';
    ++len;
  }
  //翻转字符串 (int)521 -1-> char(125) -2-> char(521) 这里是第2步
  char tmp;
  char *end = str + len - 1;
  char *begin = str;
  while (begin < end) {
    tmp = *begin;
    *begin++ = *end;
    *end-- = tmp;
  }
  str[len] = '\0';
  return len;
}

int printf(const char *fmt, ...) { 
    va_list ap;
    va_start(ap, fmt);
    char buf[1024] = {0};
    int ret = vsprintf(buf, fmt, ap);
    va_end(ap);
    for(int i = 0; i < ret; i++) {
        putch(buf[i]);
    }

    return ret;

}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
   int ret = vsprintf(out, fmt, ap);
  va_end(ap);
    return ret;

}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char *begin = out;
  int d;
  char *s;
    char c;

  while (*fmt != '\0') {
    if (*fmt != '%') {
      *begin++ = *fmt++;
      continue;
    } else {
      switch (*(++fmt)) {
      case '%':
        *begin = *fmt;
        ++begin;
        break;
      case 's': /* string */
        s = va_arg(ap, char *);
        strcpy(begin, s);
        begin += strlen(s);
        ++fmt;
        break;
      case 'd': /* int */
        d = va_arg(ap, int);
        begin += int_to_str(d, begin, 10);
        ++fmt;
        break;
      case 'c': /* char */
        c = va_arg(ap, int);
        *begin = c;
        begin += 1;
        ++fmt;
        break;
      default:
        break;
      }
    }
  }
  *begin = '\0';
    return begin - out;
}

/*int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);

  char *begin = out;
  int d;
  char *s;

  while (*fmt != '\0') {
    if (*fmt != '%') {
      *begin++ = *fmt++;
      continue;
    } else {
      switch (*(++fmt)) {
      case '%':
        *begin = *fmt;
        ++begin;
        break;
      case 's': [> string <]
        s = va_arg(ap, char *);
        strcpy(begin, s);
        begin += strlen(s);
        ++fmt;
        break;
      case 'd': [> int <]
        d = va_arg(ap, int);
        begin += int_to_str(d, begin, 10);
        ++fmt;
        break;
      case 'c': [> char <]
        [> need a cast here since va_arg only
           takes fully promoted types <]
        [>c = (char)va_arg(ap, int);<]
        break;
      default:
        break;
      }
    }
  }
  *begin = '\0';
  va_end(ap);
  return begin - out;
}*/

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
