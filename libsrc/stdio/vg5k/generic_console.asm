

		SECTION		code_clib

		PUBLIC		generic_console_cls
		PUBLIC		generic_console_vpeek
		PUBLIC		generic_console_scrollup
		PUBLIC		generic_console_printc
		PUBLIC		generic_console_ioctl
                PUBLIC          generic_console_set_ink
                PUBLIC          generic_console_set_paper
                PUBLIC          generic_console_set_inverse

		EXTERN		CONSOLE_COLUMNS
		EXTERN		CONSOLE_ROWS

		defc		DISPLAY = 0x4000

generic_console_ioctl:
	scf
generic_console_set_inverse:
	ret

generic_console_set_paper:
	jp	generic_console_set_ink
	and	7
	rlca
	rlca
	rlca
	rlca
	ld	c,a
	ld	hl,vg5k_attr
	ld	a,(hl)
	and	@10001111
	or	c
	ld	(hl),a
	ret


generic_console_set_ink:
	and	7
	ld	c,a
	ld	hl,vg5k_attr
	ld	a,(hl)
	and	@11111000
	or	c
	ld	(hl),a
	ret

generic_console_cls:
	ld	c,CONSOLE_ROWS
	ld	hl, DISPLAY
	ld	a,(vg5k_attr)
	and	7
cls0:
	ld	b,CONSOLE_COLUMNS 
cls1:	ld	(hl),32
	inc	hl
	ld	(hl),a
	inc	hl
	djnz	cls1
	dec	c
	jr	nz,cls0
	call	refresh_screen
	ret

; c = x
; b = y
; a = character to print
; e = raw
generic_console_printc:
	push	bc	;save coordinates
	push	de
	call	xypos
	ld	d,a			;Save character
	ld	a,(vg5k_attr)
	ld	(hl),d			;place character
	inc	hl
	pop	bc			;get raw mode back into e
	rr	c
	jr	nc,is_gfx
	or	128
is_gfx:
	ld	(hl),a
	pop	hl			;get coordinates back
	ld	e,a			;attribute
	ld	a,h
	and	a
	jr	z,zrow
	add	7
	ld	h,a
zrow:
	call	0x0092			;call the rom to do the hardwork
	ret

xypos:
	ld	hl,DISPLAY - 80
	ld	de,80
	inc	b
generic_console_printc_1:
	add	hl,de
	djnz	generic_console_printc_1
	add	hl,bc		
	add	hl,bc			;hl now points to address in display
	ret

;Entry: c = x,
;       b = y
;       e = rawmode
;Exit:  nc = success
;        a = character,
;        c = failure
generic_console_vpeek:
        call    xypos
	ld	a,(hl)
	and	a
	ret


generic_console_scrollup:
	push	de
	push	bc
	ld	hl, DISPLAY + 80
	ld	de, DISPLAY
	ld	bc, 80 * (CONSOLE_ROWS-1)
	ldir
	ex	de,hl
	ld	a,(vg5k_attr)
	and	7
	ld	b,CONSOLE_COLUMNS
generic_console_scrollup_3:
	ld	(hl),32
	inc	hl
	ld	(hl),a
	inc	hl
	djnz	generic_console_scrollup_3
	call	refresh_screen
	pop	bc
	pop	de
	ret

; Refresh the whole VG5k screen - we can't rely on the interrupt
refresh_screen:
	ld	bc,CONSOLE_ROWS * CONSOLE_COLUMNS
	ld	hl,0		
	ld	de,DISPLAY
refresh_screen1:
	push	bc
	push	hl
	ld	a,(de)
	inc	de
	ex	af,af
	ld	a,(de)		;attribute
	inc	de
	push	de
	ld	e,a		;attribute
	ex	af,af
	ld	d,a		;character
	call	$0092
	push	de
	pop	hl
	inc	l
	ld	a,l
	cp	40
	jr	nz,same_line
	ld	l,0
	ld	a,h
	and	a
	jr	nz,increment_row
	ld	a,7
increment_row:
	inc	h
same_line:
	pop	bc
	dec	bc
	ld	a,b
	or	c
	jr	nz,refresh_screen1
	ret

	

	SECTION		data_clib

vg5k_attr:	defb	7	;White on black
