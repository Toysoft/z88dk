/*
Z88DK Z80 Macro Assembler

Assembly preprocessor

Copyright (C) Paulo Custodio, 2011-2018
License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
Repository: https://github.com/z88dk/z88dk
*/

/*!max:re2c*/
/*!maxnmatch:re2c*/

#include "errors.h"
#include "parse.h"
#include "preproc.h"

#include <stdbool.h>
#include <ctype.h>

/*!re2c
	re2c:define:YYCURSOR = pp->p;
	re2c:define:YYCTYPE = char;
	re2c:yyfill:enable = 0;

	end 	= "\x00";
	ws 		= [\t\v\f ];
	endl 	= "\r\n" | "\r" | "\n";
	pp		= [#*%];
	name    = [a-zA-Z_][a-zA-Z_0-9]*;
	incfile = '<' [^>\x00\r\n;]* '>'
	        | "'" [^'\x00\r\n;]* "'"
			| '"' [^"\x00\r\n;]* '"'
			| [^\t\v\f '"<>\x00\r\n;]*
			;
*/

static bool check_eol(preproc_t* pp)
{
	while (isspace(*pp->p)) 		// eat spaces and newlines
		pp->p++;

	switch (*pp->p) {
		case '\0':
		case ';':
			pp->p += strlen(pp->p);
			return true;

		default:
			err_eol_expected(pp);
			pp->p += strlen(pp->p);
			return false;
	}
}

static str_t* get_filename(char *fs, char *fe)
{
	if (fs && fe) {
		while (isspace(*fs))
			fs++;

		if (*fs == '<' || *fs == '\'' || *fs == '"') {
			fs++;
			fe--;
		}

		if (fs != fe) {
			str_t *filename = str_new();
			str_set_n(filename, fs, fe - fs);
			return filename;
		}
	}

	return NULL;
}

static void do_include(preproc_t* pp, char *fs, char *fe)
{
	if (!check_eol(pp))
		return;

	str_t* filename = get_filename(fs, fe);
	if (filename) {
		str_set(pp->include_pending, str_data(filename));
		str_free(filename);
	}
	else {
		err_file_expected(pp);
	}
}

// split labels from following opcode to allow column-1 undecorated labels, e.g. "lbl nop"
static void split_label(preproc_t* pp, char* ls, char* le, char *ks, char* ke)
{
	str_t* label = str_new();
	str_set_n(label, ls, le - ls);

	str_t* keyword = str_new();
	str_set_n(keyword, ks, ke - ks);

	keyword_e id = keyword_id(str_data(keyword));
	if (id) {
		str_append(label, ":\n");
		preproc_push_line(pp, str_data(label));
		pp->p = ks;		// continue at keyword
	}
	else {
		pp->p = ls;		// restart scanning at start of line
	}

	str_free(label);
	str_free(keyword);
}

static void preproc_scan_label(preproc_t* pp)
{
	char *YYMARKER=NULL, *p1=NULL, *p2=NULL, *p3=NULL, *p4=NULL, *yyt1=NULL, *yyt2=NULL, *yyt3=NULL;

	char* p0 = pp->p;

/*!re2c
	@p1 name @p2  ws+  @p3 name @p4 {
		split_label(pp, p1, p2, p3, p4);
		return;
	}

	ws*  '.' @p1 name @p2  ws+  @p3 name @p4 {
		split_label(pp, p1, p2, p3, p4);
		return;
	}

	ws*  @p1 name @p2 ':'  ws*  @p3 name @p4 {
		split_label(pp, p1, p2, p3, p4);
		return;
	}

	* {
		pp->p = p0;
		return;
	}
*/
}

void preproc_scan_line(preproc_t* pp)
{
	char *YYMARKER=NULL, *p1=NULL, *p2=NULL, *yyt1=NULL;

	// reserve buffer needed by re2c and init scan pointer
	str_reserve(pp->text, YYMAXFILL);
	pp->p = str_data(pp->text);

	// process any label, if present
	preproc_scan_label(pp);

	char* p0 = pp->p;

/*!re2c
	pp? ws* 'INCLUDE' ws* {
		do_include(pp, NULL, NULL);
		return;
	}

	pp? ws* 'INCLUDE' ws* @p1 incfile @p2 {
		do_include(pp, p1, p2);
		return;
	}

	* {
		preproc_push_line(pp, p0);
		return;
	}
*/
}
