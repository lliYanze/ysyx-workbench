#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  /*kbd->keydown = 1;*/
  kbd->keycode = (int)inl(KBD_ADDR);
    if(kbd->keycode & KEYDOWN_MASK){
        kbd->keydown = 1;
        kbd->keycode = kbd->keycode ^ KEYDOWN_MASK;
    }
    else{
        kbd->keydown = 0;
    }
}
