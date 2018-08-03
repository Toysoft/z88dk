/*
Z88DK Z80 Macro Assembler

Assembly preprocessor

Copyright (C) Paulo Custodio, 2011-2018
License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
Repository: https://github.com/z88dk/z88dk
*/
#include "preproc.h"
#include "die.h"
#include "utlist.h"
#include "options.h"
#include "errors.h"
#include "strutil.h"
#include "listfile.h"
#include "codearea.h"
#include "parse.h"

// table of keywords
static struct {
    const char* keyword;
    keyword_e   id;
}
keyword_table[] = {
    { "INCLUDE",    K_INCLUDE },
    { NULL,         K_NULL }
};

// global keyword map
static map_t* keyword_map = NULL;

static void preproc_deinit(void)
{
    map_free(keyword_map);
}

void preproc_init()
{
    if (keyword_map)
        return;

    keyword_map = map_new_icase();

    for (size_t i = 0; keyword_table[i].keyword != NULL; i++)
        map_set_num(keyword_map, keyword_table[i].keyword, keyword_table[i].id);

    atexit(preproc_deinit);
}

keyword_e keyword_id(const char* keyword)
{
    if (!keyword_map)
        preproc_init();

    return (keyword_e)map_get_num(keyword_map, keyword);
}


// line input
line_t* line_new(const char* text)
{
    line_t* line = xnew(line_t);
    line->text = xstrdup(text);
    return line;
}

void line_free(line_t* line)
{
    xfree(line->text);
    xfree(line);
}


// preprocessor
preproc_t* preproc_new()
{
    preproc_t* pp = xnew(preproc_t);
    pp->text = str_new();
    pp->filename = "";
	pp->line_nr = 0;
	pp->line_inc = 1;
    pp->include_pending = str_new();
    return pp;
}

void preproc_free(preproc_t* pp)
{
    line_t* elt, *tmp;
    DL_FOREACH_SAFE(pp->lineq, elt, tmp) {
        DL_DELETE(pp->lineq, elt);
        line_free(elt);
    }
    str_free(pp->text);
    str_free(pp->include_pending);

    if (pp->fp)
        fclose(pp->fp);
}

preproc_t* preproc_open_file(const char* filename, preproc_t* parent)
{
    // search file
    const char* filename_path = path_search(filename, opts.inc_path);

    // check for include recursion
    preproc_t* pp = parent;

    while (pp) {
        if (strcmp(pp->filename, filename_path) == 0) {
            err_include_recursion(parent, filename_path);
            return NULL;
        }

        pp = pp->next;
    }

    // open new file in binary mode, for cross-platform newline processing
    FILE* fp = fopen(filename_path, "rb");

    if (!fp) {
        err_read_file(parent, filename_path);
        return NULL;
    }

    // create new scan structure
    pp = preproc_new();
    pp->next = parent;
    pp->filename = spool_add(filename_path);
    pp->line_nr = 0;
    pp->fp = fp;

    if (opts.verbose)
        printf("Reading %s\n", filename_path);

    return pp;
}

preproc_t* preproc_open_text(const char* text, preproc_t* parent)
{
    // create new scan structure
    preproc_t* pp = preproc_new();
    pp->next = parent;

    if (parent) {
        pp->filename = parent->filename;
        pp->line_nr = parent->line_nr;
    }

    // push lines from text
    const char* p0 = text;
    const char* p1;

    while ((p1 = strchr(p0, '\n')) != NULL) {
        str_set_n(pp->text, p0, p1 - p0 + 1);
        preproc_push_line(pp, str_data(pp->text));
        p0 = p1 + 1;
    }

	if (*p0 != '\0') {
		str_set(pp->text, p0);
		str_append(pp->text, "\n");
        preproc_push_line(pp, str_data(pp->text));
	}

    str_clear(pp->text);

    return pp;
}

preproc_t* preproc_pop_file(preproc_t* pp)
{
    if (!pp)
        return NULL;

    preproc_t* ret = pp->next;
    preproc_free(pp);

    return ret;
}

// read next line from input file into pp.text, update pp.line_nr
static bool preproc_read_line(preproc_t* pp)
{
    str_clear(pp->text);

    if (pp->fp == NULL)
        return false;

    bool ok = str_getline(pp->text, pp->fp) != NULL;

    if (ok) {
		pp->line_nr += pp->line_inc;

        // interface with error
        set_error_file(pp->filename);
        set_error_line(pp->line_nr);

        // interface with list
        if (opts.cur_list) {
            list_start_line(get_phased_PC() >= 0 ? get_phased_PC() : get_PC(),
                            pp->filename, pp->line_nr, str_data(pp->text));
        }
    }
    else {
        fclose(pp->fp);
        pp->fp = NULL;
    }

    return ok;
}

char* preproc_getline(preproc_t* pp)
{
    while (true) {
        char* text = preproc_pop_line(pp);

        if (text)
            return text;                // user must free text

        // special handling for INCLUDE - only process INCLUDE after queue is empty
        // so that any label before INCLUDE is parsed before the file is included
        if (str_len(pp->include_pending)) {
            parse_file(str_data(pp->include_pending));
            str_clear(pp->include_pending);
            continue;
        }

        if (!preproc_read_line(pp))
            return NULL;                // no more input

        preproc_scan_line(pp);          // preprocess, fill lineq
    }
}

void preproc_push_line(preproc_t* pp, const char* text)
{
    line_t* elt = line_new(text);
    DL_APPEND(pp->lineq, elt);
}

char* preproc_pop_line(preproc_t* pp)
{
    line_t* elt = pp->lineq;

    if (!elt)
        return NULL;                // queue empty

    char* text = elt->text;         // take ownership of pointer
    DL_DELETE(pp->lineq, elt);
    xfree(elt);

    return text;                    // user must free text
}
