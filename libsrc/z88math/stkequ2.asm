;
;	Z88dk Z88 Maths Library
;
;
;	$Id: stkequ2.asm,v 1.1 2002-01-21 20:36:07 dom Exp $

		XLIB	stkequ2

		XREF	fa

; Store the FP number in FA after executing a routine

.stkequ2
        ld      (fa+3),hl
        ld      a,c
        ld      (fa+5),a
        exx
        ld      (fa+1),hl
;        xor     a
;        ld      (fa),a
        ret

