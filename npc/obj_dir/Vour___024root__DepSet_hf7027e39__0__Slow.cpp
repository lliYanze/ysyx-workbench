// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vour.h for the primary calling header

#include "verilated.h"

#include "Vour__Syms.h"
#include "Vour___024root.h"

VL_ATTR_COLD void Vour___024root___eval_initial__TOP(Vour___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vour__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vour___024root___eval_initial__TOP\n"); );
    // Init
    VlWide<4>/*127:0*/ __Vtemp_h60887cd1__0;
    // Body
    if (VL_UNLIKELY((0U != VL_TESTPLUSARGS_I(std::string{"trace"})))) {
        __Vtemp_h60887cd1__0[0U] = 0x2e766364U;
        __Vtemp_h60887cd1__0[1U] = 0x2f616464U;
        __Vtemp_h60887cd1__0[2U] = 0x6c6f6773U;
        __Vtemp_h60887cd1__0[3U] = 0x2e2fU;
        vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(4, __Vtemp_h60887cd1__0));
        vlSymsp->_traceDumpOpen();
        VL_WRITEF("[%0t] Tracing to logs/add.vcd...\n\n",
                  64,VL_TIME_UNITED_Q(1),-12);
    }
    VL_WRITEF("[%0t] Model running...\n\n",64,VL_TIME_UNITED_Q(1),
              -12);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vour___024root___dump_triggers__stl(Vour___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vour___024root___eval_triggers__stl(Vour___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vour__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vour___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.at(0U) = (0U == vlSelf->__VstlIterCount);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vour___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
