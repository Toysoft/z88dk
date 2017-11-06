; 2017 dom / feilipu
; 2017 aralbrec - slightly faster

SECTION code_clib
SECTION code_math

PUBLIC l_small_mul_16_16x16

l_small_mul_16_16x16:

   ; multiplication of two 16-bit numbers into a 16-bit product
   ;
   ; enter : de = 16-bit multiplicand
   ;         hl = 16-bit multiplicand
   ;
   ; exit  : hl = 16-bit product
   ;         carry reset
   ;
   ; uses  : af, bc, de, hl

   ld a,d                      ; a = xh
   ld d,h                      ; d = yh
   ld h,a                      ; h = xh
   ld c,e                      ; c = xl
   ld b,l                      ; b = yl
   mul d,e                     ; yh * yl
   ex de,hl
   mul d,e                     ; xh * yl
   add hl,de                   ; add cross products
   ld e,c
   ld d,b
   mul d,e                     ; yl * xl
   ld a,l                      ; cross products lsb
   add a,d                     ; add to msb final
   ld h,a
   ld l,e                      ; hl = final

   ; 83 cycles, 19 bytes

   or a
   ret
