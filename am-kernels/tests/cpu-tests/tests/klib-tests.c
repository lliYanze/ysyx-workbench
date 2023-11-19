#include "trap.h"

char data[128];
char data_cpy[128];

void check_seq(int l, int r, int val) {
  int i;
  for (i = l; i < r; i++) {
    assert(data[i] == val + i - l);
  }
}

// 检查[l,r)区间中的值是否均为val
void check_eq(int l, int r, char val) {
  int i;
  for (i = l; i < r; i ++) {
    assert(data[i] == val);
  }
}
void check_cpyeq(int l, int r, int val) {
  int i;
  for (i = l; i < r; i ++) {
    assert(data_cpy[i] == val);
  }
}

void test_memset() {
    int l, r;
    for (l = 0; l < 128; ++l) {
      for (r = l+1; r < 128; ++r) {
        memset(data+l, l, (r-l));
        check_eq(l, r, l);
      }
    }
}

void test_memcpy() {
    int l, r;
    for (l = 0; l < 128; l ++) {
      for (r = l+1; r < 128; r ++) {
        memset(data+l, l, r-l);
        memcpy(data_cpy+l, data+l, r-l);

        check_cpyeq(l, r, l);
      }
    }
}




int main() {
    /*test_memset();*/
    test_memcpy();
    return 0;
}

