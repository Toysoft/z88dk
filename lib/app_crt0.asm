;
;       Startup Code for Z88 applications
;
;	The entry point is a dummy function in the DOR which then
;	jumps to routine in this file
;
;       1/4/99 djm
;
;       7/4/99 djm Added function to handle commands - this requires
;       the user to do something for it!
;
;       4/5/99 djm Added in functionality to remove check for expanded
;       machine, not to give those people reluctant to ug something to
;       use, but to save memory in very small apps
;
;	1/4/2000 djm Added in conditionals for:
;		- far heap stuff (Ask GWL for details!)
;		- "ANSI" stdio - i.e. flagged and ungetc'able
;
;	6/10/2001 djm Clean up (after Henk)
;
;	$Id: app_crt0.asm,v 1.16 2016-04-03 13:28:36 dom Exp $


;--------
; Call up some header files (probably too many but...)
;--------
	INCLUDE "stdio.def"
	INCLUDE "fileio.def"
	INCLUDE "memory.def"
	INCLUDE "error.def"
	INCLUDE "time.def"
	INCLUDE "syspar.def"
	INCLUDE "director.def"

;--------
; Set some scope variables
;--------
        PUBLIC    app_entrypoint	;Start of execution in this file 
        EXTERN    applname	;Application name (in DOR)
        EXTERN    in_dor		;DOR address

;--------
; Set an origin for the application (-zorg=) default to 49152
;--------
        
        IF      !myzorg
                defc    myzorg  = 49152
        ENDIF
                org     myzorg

;--------
; Calculate the required bad memory. If we're using a near heap then the
; compiler sets it to $20+(HEAPSIZE%256)+1
; If we reqpag == 0 or reqpag <> 0 then we don't want to define it else
; default to $20 (8k)
;--------
        IF      (reqpag=0) | (reqpag)
        ELSE 
                defc    reqpag  = $20
        ENDIF

;--------
; We need a safedata def. So if not defined set to 0
;--------
        IF      !safedata
                defc    safedata = 0
        ENDIF


;--------
; Start of execution. We enter with ix pointing to info table about
; memory allocated to us by OZ. 
;--------
app_entrypoint:
;-------
; If we want to debug, then intuition is set, so call $2000
; This assumes several things...no bad memory required, and we've
; been blown onto an EPROM along with Intuition and our app DOR
; has been set appropriately to page in Intuition in segment 0
; Call intuition if that set (assumes no bad memory and DOR is setup)
;-------
IF (intuition <> 0 ) & (reqpag=0)
        call    $2000
ENDIF
IF (reqpag <> 0)
        ld      a,(ix+2)	;Check allocated bad memory if needed
        cp      $20+reqpag
        ld      hl,nomemory
; Bit of trickery with conditional assembly here, if we don't need an
; expanded machine, jump on success to init_continue or if failure
; flow into init_error.
; If we need expanded, jump on failure to init_error and flow onto
; check for expanded
  IF (NEED_expanded=0)			
        jr      nc,init_continue
  ELSE
        jr      c,init_error
  ENDIF
ENDIF
IF NEED_expanded <> 0
        ld      ix,-1		;Check for an expanded machine
        ld      a,FA_EOF
        call_oz(os_frm)
        jr      z,init_continue
        ld      hl,need_expanded_text
ENDIF

IF (reqpag<>0) | (NEED_expanded<>0)
init_error:			;Code to deal with an initialisation error
        push    hl		;The text that we are printing
        ld      hl,clrscr	;Clear the screen
        call_oz(gn_sop)
        ld      hl,windini	;Define a small window
        call_oz(gn_sop)
        pop     hl
        call_oz(gn_sop)		;Print text
        ld      bc,500
        call_oz(os_dly)		;Pause
        xor     a
        call_oz(os_bye)		;Exit
ENDIF

init_continue:			;We had enough memory
        ld   a,SC_DIS		;Disable escape 
        call_oz(Os_Esc)
        xor     a		;Setup our error handler
        ld      b,a
        ld      hl,errhan
        call_oz(os_erh)
        ld      (l_errlevel),a	;Save previous values
        ld      (l_erraddr),hl
        ld      hl,applname	;Name application
        call_oz(dc_nam)
        ld      hl,clrscr	;Setup a BASIC sized window
        call_oz(gn_sop)
        ld      hl,clrscr2
        call_oz(gn_sop)
;--------
; Now, set up some very nice variables - stream ids for std*
;--------
	call	crt0_init_data

        xor     a		;Reset atexit() count
        ld      (exitcount),a
        ld      hl,-64		;Setup atexit() stack
        add     hl,sp
        ld      sp,hl
        ld      (exitsp),sp
IF DEFINED_farheapsz
	call	init_far	;Initialise far memory if required
ENDIF
        call    _main		;Call the users code
        xor     a		;Exit with zero 
cleanup:			;Jump back to here from exit()
IF DEFINED_ANSIstdio
	push	af		;Save exit value
	EXTERN	closeall
	call	closeall	;Close all files
 IF DEFINED_farheapsz
 	call	freeall_far	;Deallocate far memory
 ENDIF
	pop	af		;Get exit value back
ELSE	;!ANSIstdio
  IF DEFINED_farheapsz
	push	af		;Deallocate far memory
	call	freeall_far
	pop	af
  ENDIF
ENDIF	;ANSIstdio

        call_oz(os_bye)		;Exit back to OZ

l_dcal:	jp	(hl)		;Used by various things

;-------
; Process a <> command, we call the users handlecmds APPFUNC
;-------
processcmd:
IF DEFINED_handlecmds
IF !DEFINED_Z88DK_USES_SDCC
        EXTERN    _handlecmds
ENDIF
        ld      l,a
        ld      h,0
        push    hl
        call    _handlecmds
        pop     bc
ENDIF
        ld      hl,0		;dummy return value
        ret


;--------
; Fairly simple error handler
;--------
errhan:	ret	z		;Fatal error - far mem probs?
IF DEFINED_redrawscreen
IF !DEFINED_Z88DK_USES_SDCC
        EXTERN    _redrawscreen
ENDIF
        cp      RC_Draw		;(Rc_susp for BASIC!)
        jr      nz,errhan2
        push    af		;Call users screen redraw fn if defined
        call    _redrawscreen
        pop     af
ENDIF
errhan2:
        cp      RC_Quit		;they don't like us!
        jr      nz,keine_error
IF DEFINED_applicationquit
IF !DEFINED_Z88DK_USES_SDCC
	EXTERN	_applicationquit	;Call users routine if defined
ENDIF
	call	_applicationquit
ENDIF
        xor     a		;Standard cleanup
        jr      cleanup

keine_error:
        xor     a
        ret

;--------
; Far memory setup
;--------
IF DEFINED_farheapsz
	EXTERN	freeall_far
	PUBLIC	farpages
	PUBLIC	malloc_table
	PUBLIC	farmemspec
	PUBLIC	pool_table
; All far memory variables now in init_far.asm
	INCLUDE	"init_far.asm"

ENDIF

;--------
; This bit of code allows us to use OZ ptrs transparently
; We copy any data from up far to a near buffer so that OZ
; is happy about it
; Prototype is extern void __FASTCALL__ *cpfar2near(far void *)
;--------
IF DEFINED_farheapsz
	EXTERN	strcpy_far
_cpfar2near:
	pop	bc	;ret address
	pop	hl
	pop	de	;far ptr
	push	bc	;keep ret address
	ld	a,e
	and	a
	ret	z	;already local
	push	ix	;keep ix safe
	ld	bc,0	;local
	push	bc
	ld	bc,copybuff
	push	bc	;dest
	push	de	;source
	push	hl
	call	strcpy_far
	pop	bc	;dump args
	pop	bc
	pop	bc
	pop	bc
	pop	ix	;get ix back
	ld	hl,copybuff
	ret
ELSE
; We have no far code installed so all we have to do is fix the stack
_cpfar2near:
	pop	bc
	pop	hl
	pop	de
	push	bc
	ret
ENDIF

;--------
; Which printf core routine do we need?
;--------
	PUBLIC	asm_vfprintf
IF DEFINED_floatstdio
	EXTERN	asm_vfprintf_level3
	defc	asm_vfprintf = asm_vfprintf_level3
ELSE
	IF DEFINED_complexstdio
	        EXTERN	asm_vfprintf_level2
		defc	asm_vfprintf = asm_vfprintf_level2
	ELSE
	       	EXTERN	asm_vfprintf_level1
		defc	asm_vfprintf = asm_vfprintf_level1
	ENDIF
ENDIF

;-------
; Text to define the BASIC style window
;-------
clrscr:		defb    1,'7','#','1',32,32,32+94,32+8,128,1,'2','C','1',0
clrscr2:	defb    1,'2','+','S',1,'2','+','C',0
          

IF (NEED_expanded <> 0 )  | (reqpag <>0)
windini:
          defb   1,'7','#','3',32+7,32+1,32+34,32+7,131     ;dialogue box
          defb   1,'2','C','3',1,'4','+','T','U','R',1,'2','J','C'
          defb   1,'3','@',32,32  ;reset to (0,0)
          defm   "Small C+ Application"
          defb   1,'3','@',32,32 ,1,'2','A',32+34  ;keep settings for 10
          defb   1,'7','#','3',32+8,32+3,32+32,32+5,128     ;dialogue box
          defb   1,'2','C','3'
          defb   1,'3','@',32,32,1,'2','+','B'
          defb   0
ENDIF

IF reqpag <> 0
nomemory:
        defb    1,'3','@',32,32,1,'2','J','C'
        defm    "Not enough memory allocated to run application"
        defb    13,10,13,10
        defm    "Sorry, please try again later!"
        defb    0
ENDIF

IF (NEED_expanded <> 0 )
need_expanded_text:
        defb    1,'3','@',32,32,1,'2','J','C'
        defm    "Sorry, application needs an expanded machine"
        defb    13,10,13,10
        defm    "Try again when you have expanded your machine"
        defb    0
ENDIF

;--------
; Include the stdio handle defaults if we need them
;--------
IF DEFINED_ANSIstdio
sgoprotos:
	INCLUDE	"stdio_fp.asm"
ENDIF



;--------
; Now, include the math routines if needed..
;--------
IF NEED_floatpack
        INCLUDE "float.asm"
ENDIF



; Memory map
SECTION code_crt_init
	; Setup std* streams
crt0_init_data:
        ld      hl,$8080	;Initialise floating point seed
        ld      (fp_seed),hl
IF DEFINED_ANSIstdio
        ld      hl,sgoprotos
        ld      de,__sgoioblk
        ld      bc,4*10         ;4*10 FILES
        ldir
ELSE
        ld      hl,-10
        ld      (__sgoioblk+4),hl
        dec     hl
        ld      (__sgoioblk),hl
        dec     hl
        ld      (__sgoioblk+2),hl
ENDIF
SECTION code_crt_exit

	ret
SECTION code_compiler
SECTION code_clib
SECTION code_crt0_sccz80
SECTION code_l_sdcc
SECTION code_math
SECTION code_error
SECTION data_compiler
SECTION rodata_compiler
SECTION rodata_clib

; Now the magic for z88 apps, BSS goes into low memory
SECTION bss_crt
; Variables need by crt0 code and some lib routines are kept in safe workspace
IF !DEFINED_sysdefvarsaddr
	defc sysdefvarsaddr = $1ffD-100-safedata
ENDIF
	org	sysdefvarsaddr

__sgoioblk:      defs    40      ;stdio control block
l_erraddr:       defw    0       ;Not sure if these are used...
l_errlevel:      defb    0
coords:          defw    0       ;Graphics xy coordinates
base_graphics:   defw    0       ;Address of graphics map
gfx_bank:        defb    0       ;Bank that this is in
exitsp:          defw    0       ;atexit() stack
exitcount:       defb    0       ;Number of atexit() routines
fp_seed:         defs    6       ;Floating point seed (not used ATM)
extra:           defs    6       ;Floating point spare register
fa:              defs    6       ;Floating point accumulator
fasign:          defb    0       ;Floating point variable
packintrout:     defw    0       ;User interrupt handler
snd_asave:       defb    0       ;Sound
snd_tick:        defb    0       ;Sound
bit_irqstatus:   defw    0       ;current irq status when DI is necessary
; If the user doesn't care where the heap variables go, dump them in safe space
IF !userheapvar
        defc userheapvar = 0
ENDIF
IF userheapvar = 1
heapblocks:	defw	0	;Number of free blocks
heaplast:	defw	0 	;Pointer to linked blocks
ENDIF

SECTION bss_fardata
; If we use safedata then we can't have far memory
IF !safedata
        IF !DEFINED_defvarsaddr
                DEFINE DEFINED_defvarsaddr
                defc defvarsaddr = 8192
        ENDIF
	org	defvarsaddr
	IF DEFINED_farheapsz
	pool_table:     defs    224
	malloc_table:	defw	0
	farpages:	defww	1
	farmemspec:	defb	1
	copybuff:	defs	258
	actual_malloc_table: defs ((farheapsz/256)+1)*2
	ENDIF
ENDIF
SECTION bss_compiler




SECTION bss_clib
SECTION bss_error
