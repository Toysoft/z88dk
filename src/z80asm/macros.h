/*
Z88DK Z80 Macro Assembler

Copyright (C) Paulo Custodio, 2011-2018
License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
Repository: https://github.com/z88dk/z88dk

Assembly macros.
*/
#pragma once

#include "strutil.h"

typedef char* (*getline_t)();

typedef struct macros_state_t {
    str_t* in_line;         // input text
    str_t* out_line;        // output text

    const char* p;          // scan pointer in in_line

    getline_t getline_f;    // function to get a new line from input
} macros_state_t;


void init_macros();
void clear_macros();
void free_macros();
char* macros_getline(getline_t getline_func);

// in macros_re.re
char* preproc_line(macros_state_t* st, char* in_line);
