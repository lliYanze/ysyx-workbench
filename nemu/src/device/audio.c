/***************************************************************************************
 * Copyright (c) 2014-2022 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan
 *PSL v2. You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
 *KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 *NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include "macro.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_audio.h>
#include <common.h>
#include <device/map.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  nr_reg
};
static uint8_t *sbuf = NULL;
static uint32_t *audio_base = NULL;

void fill_buff(void *userdata, uint8_t *stream, int len) {
  len = CONFIG_SB_SIZE < len ? CONFIG_SB_SIZE : len;
  int nread = len;
  if (audio_base[reg_count] < nread)
    nread = audio_base[reg_count];

  // SDL_memset(stream, 0, nread);
  // for (int i = 0; i < nread; i++) {
  //   stream[i] = sbuf[i] * 50;
  // }

  SDL_MixAudio(stream, sbuf + audio_base[reg_count], nread, SDL_MIX_MAXVOLUME);
  audio_base[reg_count] -= nread;
  if (len > nread)
    SDL_memset(stream + audio_base[reg_count], 0, len - nread);
}

void init_sdlaudio() {
  memset(sbuf, 0, CONFIG_SB_SIZE);
  SDL_AudioSpec spec, have;
  spec.format = AUDIO_S16SYS;
  spec.userdata = NULL;
  spec.callback = fill_buff;
  spec.channels = 1;
  spec.freq = 8000;
  spec.samples = 1024;
  if (SDL_Init(SDL_INIT_AUDIO)) {
    printf("SDL_Init error: %s\n", SDL_GetError());
    return;
  }

  if (SDL_OpenAudio(&spec, &have) < 0) {
    printf("Failed to open audio: %s\n", SDL_GetError());
    return;
  }
  SDL_PauseAudio(0);
}

static void
audio_io_handler(uint32_t offset, int len,
                 bool is_write) { // 会传入 访问的偏移和长度 以及读写标志
  assert(len == 4);
}

void init_audio() {
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
  audio_base[reg_init] = 1;
  audio_base[reg_sbuf_size] = CONFIG_SB_SIZE;
  audio_base[reg_count] = 0;
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size,
              audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size,
               audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
  IFDEF(CONFIG_HAS_AUDIO, init_sdlaudio());
}
