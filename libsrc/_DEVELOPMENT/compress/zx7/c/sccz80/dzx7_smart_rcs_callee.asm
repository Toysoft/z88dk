
; void dzx7_smart_rcs_callee(void *src, void *dst)

PUBLIC dzx7_smart_rcs_callee

dzx7_smart_rcs_callee:

   pop hl
   pop de
   ex (sp),hl
   
   INCLUDE "compress/zx7/z80/asm_dzx7_smart_rcs.asm"
