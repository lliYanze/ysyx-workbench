#include "../riscv.h"
#include <am.h>

unsigned long begin_time = 0;
void __am_timer_init() { begin_time = inl(0xa0000048 + 4); }

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uptime->us = 0;
  uptime->us = inl(0xa0000048 + 4);
  uptime->us = (uptime->us << 32) | inl(0xa0000048);
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour = 0;
  rtc->day = 0;
  rtc->month = 0;
  rtc->year = 1900;
}
