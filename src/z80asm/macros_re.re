/*
Z88DK Z80 Macro Assembler

Copyright (C) Paulo Custodio, 2011-2018
License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
Repository: https://github.com/z88dk/z88dk

Assembly macros.
*/

#include "directives.h"
#include "errors.h"
#include "macros.h"
#include "strutil.h"

#include <ctype.h>

/*!max:re2c*/
/*!maxnmatch:re2c*/

static void setup_scan(macros_state_t *st, char *in_line)
{
	size_t len = strlen(in_line);
	str_clear(st->in_line);
	str_reserve(st->in_line, len + YYMAXFILL);		// reserve space for scan look-ahead
	str_set(st->in_line, in_line);

	st->p = str_data(st->in_line);					// scan pointer

	str_set(st->out_line, str_data(st->in_line));	// by default output = input
}

static void scan_preproc(macros_state_t *st)
{
// to add later
//	pp			{ clear_out(st); return; }
//	ws* ';'		{ clear_out(st); return; }
}

char * preproc_line(macros_state_t *st, char *in_line)
{
	setup_scan(st, in_line);

	scan_preproc(st);

	return str_data(st->out_line);
}
