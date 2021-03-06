#include <arch/zxn/esxdos.h>
#include "globals.h"

// initial state

unsigned char cwd[ESX_PATHNAME_MAX];

// file handles

unsigned char fin = 0xff;                       // handle for located program
unsigned char fdir = 0xff;                      // handle for readdir

// details on program being loaded

unsigned char program_name[ESX_PATHNAME_MAX];   // full path to program
unsigned char *command_line;                    // command line to be passed to program

// path loaded from environment

unsigned char PATH[512];

// buffer space

unsigned char buf[64];

// animated cursor

unsigned char cursor[5] = "\|/-";
unsigned char cpos;
