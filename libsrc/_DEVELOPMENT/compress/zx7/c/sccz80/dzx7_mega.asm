
; void dzx7_mega(void *src, void *dst)

PUBLIC dzx7_mega

EXTERN asm_dzx7_mega

dzx7_mega:

   pop af
   pop de
   pop hl
   
   push hl
   push de
   push af
   
   jp asm_dzx7_mega
