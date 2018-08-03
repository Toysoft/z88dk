/*
Z88DK Z80 Macro Assembler

Assembly preprocessor

Copyright (C) Paulo Custodio, 2011-2018
License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
Repository: https://github.com/z88dk/z88dk
*/
#pragma once

#include "strutil.h"
#include <stdio.h>
#include <stdbool.h>

// keywords
typedef enum keyword {
    K_NULL,         // reserve 0 entry for false return
    K_INCLUDE,
} keyword_e;

// get keyword id, K_NULL=0 if not a keyword
keyword_e keyword_id(const char* keyword);

// init preprocessor tables
void preproc_init();


// one input line from file or to parser
typedef struct line_t {
    char* text;                 // input line text
    struct line_t* next, *prev; // queue of lines
} line_t;

line_t* line_new(const char* text);
void line_free(line_t* line);


// preprocessor context
typedef struct preproc_t {
    line_t* lineq;              // queue of lines to be returned
    FILE* fp;                   // currrent open file
    str_t* text;                // current input line text
    const char* filename;       // current input file
    int line_nr;                // current input line number
	int line_inc;

    str_t* include_pending;     // file name of include pending

    char* p;                    // used by re2c

    struct preproc_t* next;     // stack of open files
} preproc_t;

preproc_t* preproc_new();
void preproc_free(preproc_t* pp);

// open a file, return new prepoc state; parent is NULL on top file
preproc_t* preproc_open_file(const char* filename, preproc_t* parent);

// open a scope to preprocess a string
preproc_t* preproc_open_text(const char* text, preproc_t* parent);

// pop a file from the preproc stack, return new TOS
preproc_t* preproc_pop_file(preproc_t* pp);

// return the next line from input after preprocessing, user must free returned pointer
char* preproc_getline(preproc_t* pp);

// push line to queue, pop line from queue
void preproc_push_line(preproc_t* pp, const char* text);
char* preproc_pop_line(preproc_t* pp);  // user must free

// preprocess line in pp.text, push result to lineq
void preproc_scan_line(preproc_t* pp);
