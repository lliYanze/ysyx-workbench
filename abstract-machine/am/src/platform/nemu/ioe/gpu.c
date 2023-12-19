#include <am.h>
#include <nemu.h>
#include <stdio.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T){.present = true,
                           .has_accel = false,
                           .width = inl(VGACTL_ADDR) >> 16,
                           .height = inw(VGACTL_ADDR),
                           .vmemsz = 0};
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x;
  int y = ctl->y;
  int h = ctl->h;
  int w = ctl->w;
  int screen_width = inl(VGACTL_ADDR) >> 16;

  uint32_t *pixels = ctl->pixels;
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;

  if (ctl->sync) {
    for (int i = 0; i < h; ++i) { // 行
      for (int j = 0; j < w; ++j) {
        fb[screen_width * (y) + x] = pixels[w * i + j];
      }
    }
    outl(SYNC_ADDR, 1);
  } else {
    for (int i = 0; i < h; ++i) { // 行
      for (int j = 0; j < w; ++j) {
        // printf("x = %d, y = %d\n", screen_width * (i + y), j + x);
        fb[screen_width * (y + i) + x + j] = pixels[w * i + j];
      }
    }
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) { status->ready = true; }
