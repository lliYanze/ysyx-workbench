#include <am.h>
#include <nemu.h>
#include <stdio.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T){.present = true,
                           .has_accel = false,
                           .width = inw(VGACTL_ADDR),
                           .height = inl(VGACTL_ADDR) >> 16,
                           .vmemsz = inl(FB_ADDR)};
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x;
  int y = ctl->y;
  int h = ctl->h;
  int w = ctl->w;
  int screen_width = inl(VGACTL_ADDR) >> 16;
  uint32_t *pixels = ctl->pixels;
  if (!ctl->sync) {
    uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
    for (int i = 0; i < h; ++i) { // 行
      for (int j = 0; j < w; ++j) {
        fb[screen_width * (i + x) + j + y] = pixels[w * i + h + j];
      }
    }
  } else {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) { status->ready = true; }
