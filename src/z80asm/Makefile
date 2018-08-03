#------------------------------------------------------------------------------
# Z88DK Z80 Module Assembler
# Copyright (C) Paulo Custodio, 2011-2018
# License: http://www.perlfoundation.org/artistic_license_2_0
# Repository: https://github.com/z88dk/z88dk
#------------------------------------------------------------------------------
PROJ		:= z80asm

include ../Make.common

CC 		?= gcc
INSTALL 	?= install
CROSS		?= 0

#------------------------------------------------------------------------------
# Object files
#------------------------------------------------------------------------------
SRCS		:= $(filter-out test.c,$(wildcard *.c lib/*.c ../common/*.c ../../ext/regex/reg*.c))
OBJS 		:= $(SRCS:.c=.o) \
		   $(UNIXem_OBJS)
DEPENDS		:= $(SRCS:.c=.d)
TEST_SRC_MAIN	:= $(wildcard t/test_*.c)
TEST_SRC_LIB	:= t/testlib.c

#------------------------------------------------------------------------------
# variables
#------------------------------------------------------------------------------
OPT 		=  -O3
STD 		=  -std=gnu11
LOCAL_LIB 	:= lib
LOCAL_CFLAGS 	+= -MMD -I. -I$(LOCAL_LIB) -It -g -Wall -ftabstop=4 $(STD) $(OPT) \
		-I../common \
		-I../../ext/optparse \
		-I../../ext/regex \
		-I../../ext/uthash/src \
		$(UNIXem_CFLAGS)

#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------
.PHONY: all

all: $(PROJ)$(EXE)

$(PROJ)$(EXE): ../config.h $(OBJS)
	$(CC) $(LOCAL_CFLAGS) $(CFLAGS) -o $(PROJ)$(EXE) $(OBJS) $(LDFLAGS)

../config.h:
	@echo \#define PREFIX \"/usr/local/share/z88dk\"		 > $@
	@echo \#define UNIX 1						>> $@
	@echo \#define EXEC_PREFIX \"\"					>> $@
	@echo \#define Z88DK_VERSION \"build-$(shell date +%Y%m%d)\"	>> $@

%.o: %.c
	$(CC) $(LOCAL_CFLAGS) $(CFLAGS) -c -o $@ $<

# parser is too big to optimize with -O3
parse.o: parse.c
	$(CC) $(LOCAL_CFLAGS) $(CFLAGS) -O0 -c -o $@ $<

#------------------------------------------------------------------------------
# re2c
#------------------------------------------------------------------------------
RE2C		:= re2c
RE2C_ROOT	:= ../../ext/re2c/re2c
RE2C_FLAGS	:= -i --no-generation-date -W -T

#------------------------------------------------------------------------------
CXX		?= g++
CXXFLAGS	+= -g -Wall -Wextra -std=gnu++11 -MMD -I$(RE2C_ROOT)

#------------------------------------------------------------------------------
RE2C_SRCS	:= \
$(wildcard $(RE2C_ROOT)/bootstrap/src/ast/*.cc) \
$(wildcard $(RE2C_ROOT)/bootstrap/src/conf/*.cc) \
$(wildcard $(RE2C_ROOT)/src/*.cc) \
$(wildcard $(RE2C_ROOT)/src/adfa/*.cc) \
$(wildcard $(RE2C_ROOT)/src/ast/*.cc) \
$(wildcard $(RE2C_ROOT)/src/code/*.cc) \
$(wildcard $(RE2C_ROOT)/src/conf/*.cc) \
$(wildcard $(RE2C_ROOT)/src/dfa/*.cc) \
$(wildcard $(RE2C_ROOT)/src/dfa/cfg/*.cc) \
$(wildcard $(RE2C_ROOT)/src/nfa/*.cc) \
$(wildcard $(RE2C_ROOT)/src/re/*.cc) \
$(wildcard $(RE2C_ROOT)/src/re/encoding/*.cc) \
$(wildcard $(RE2C_ROOT)/src/re/encoding/utf16/*.cc) \
$(wildcard $(RE2C_ROOT)/src/re/encoding/utf8/*.cc) \
$(wildcard $(RE2C_ROOT)/src/skeleton/*.cc) \
$(wildcard $(RE2C_ROOT)/src/util/*.cc)

RE2C_OBJS	:= $(RE2C_SRCS:.cc=.o)

DEPENDS		+= $(RE2C_SRCS:.cc=.d)

#------------------------------------------------------------------------------
all:   $(RE2C_ROOT)/config.h
test:: $(RE2C_ROOT)/config.h

$(RE2C_ROOT)/config.h:
	echo '#define HAVE_STDINT_H 1'          > $(RE2C_ROOT)/config.h
	echo '#define PACKAGE_VERSION "1.0.3"' >> $(RE2C_ROOT)/config.h

#------------------------------------------------------------------------------
define MAKE_RE2C
$(PROJ)$(EXE): $(1).o

$(1).c: $(1).re $(RE2C)$(EXE)
	./$(RE2C)$(EXE) $(RE2C_FLAGS) -o $(1).c1 $(1).re
	sed -e "s/\r//" < $(1).c1 > $(1).c
	$(RM) $(1).c1
endef

#------------------------------------------------------------------------------

$(eval $(call MAKE_CXX_EXE,$(RE2C),$(RE2C_OBJS),0))

$(eval $(call MAKE_RE2C,macros_re))
$(eval $(call MAKE_RE2C,preproc_re))

#------------------------------------------------------------------------------
# libraries
#------------------------------------------------------------------------------
.PHONY: z80asm_lib
all: z80asm_lib

z80asm_lib:
ifeq ($(CROSS),0)
	make -C dev/z80asm_lib
	cp dev/z80asm_lib/$(PROJ)-*.lib .
endif

clean::
	make -C dev/z80asm_lib clean
	$(RM) $(PROJ)-*.lib

#------------------------------------------------------------------------------
# developer generated source files, and test libs
#------------------------------------------------------------------------------
.PHONY: dev
dev:
	$(MAKE) -C tt
	$(MAKE) -C lib
	$(MAKE) -f dev/Makefile
	$(MAKE) all

clean::
	$(MAKE) -C lib clean

#------------------------------------------------------------------------------
# astyle
#------------------------------------------------------------------------------
.PHONY: astyle
astyle:
	$(ASTYLE) $(wildcard *.c *.h lib/*.c lib/*.h t/*.c t/*.h)
	$(ASTYLE) $(wildcard ../common/*.c ../common/*.h ../common/t/*.c ../common/t/*.h)

#------------------------------------------------------------------------------
# install
#------------------------------------------------------------------------------
install:
	$(INSTALL) $(PROJ)$(EXE)     $(PREFIX)/bin/$(EXEC_PREFIX)$(PROJ)$(EXE)
	$(INSTALL) asmpp.pl      $(PREFIX)/bin/asmpp.pl
	make -C dev/z80asm_lib install PREFIX=$(PREFIX_SHARE)

#------------------------------------------------------------------------------
# clean
#------------------------------------------------------------------------------
clean::
	$(RM) *.core $(LOCAL_LIB)/*.core $(LOCAL_LIB)/t/*.core $(LOCAL_LIB)/t/uthash/*.core
	$(RM) *.o    $(LOCAL_LIB)/*.o    $(LOCAL_LIB)/t/*.o    $(LOCAL_LIB)/t/uthash/*.o 
	$(RM) *.out  $(LOCAL_LIB)/*.out  $(LOCAL_LIB)/t/*.out  $(LOCAL_LIB)/t/uthash/*.out
	$(RM) *.orig $(LOCAL_LIB)/*.orig $(LOCAL_LIB)/t/*.orig $(LOCAL_LIB)/t/uthash/*.orig
	$(RM) *.exe  $(LOCAL_LIB)/*.exe  $(LOCAL_LIB)/t/*.exe  $(LOCAL_LIB)/t/uthash/*.exe
	$(RM) *.tmp  $(LOCAL_LIB)/*.tmp  $(LOCAL_LIB)/t/*.tmp  $(LOCAL_LIB)/t/uthash/*.tmp
	$(RM) *.bak  $(LOCAL_LIB)/*.bak  $(LOCAL_LIB)/t/*.bak  $(LOCAL_LIB)/t/uthash/*.bak
	$(RM) *.log  $(LOCAL_LIB)/*.log  $(LOCAL_LIB)/t/*.log  $(LOCAL_LIB)/t/uthash/*.log
	$(RM) *~     $(LOCAL_LIB)/*~     $(LOCAL_LIB)/t/*~     $(LOCAL_LIB)/t/uthash/*~
	$(RM) -rf Debug Release x1 x2 x3

#------------------------------------------------------------------------------
# test
#------------------------------------------------------------------------------
all: t/libtestlib.a

t/libtestlib.a : $(OBJS) $(TEST_SRC_LIB:.c=.o)
	ar rcs t/libtestlib.a $(OBJS:$(PROJ).o=) $(TEST_SRC_LIB:.c=.o)

$(TEST_SRC_MAIN:.c=.o) : t/libtestlib.a

.o.out :
	$(CC) -static $(CFLAGS) $< -o $(<:.o=$(EXE)) $(LDFLAGS) -Lt -ltestlib
	$(<:.o=$(EXE)) 2> $@~
	diff -w $(<:.o=.bmk) $@~
	mv -f $@~ $@

clean::
	$(RM) t/libtestlib.a t/*.o t/*.out lib/t/*.o lib/t/*.out $(TEST_SRC_MAIN:.c=$(EXE))

test:: $(PROJ)$(EXE) z80asm_lib
	$(MAKE) dev
	$(MAKE) z80asm_lib
	#$(MAKE) -C dev\z80asm_lib test
	$(MAKE) prove_c
	$(MAKE) prove_perl
	$(MAKE) test_enigma

testlib:
	$(MAKE) -C lib test

prove_c: t/libtestlib.a $(TEST_SRC_MAIN:.c=.o) $(TEST_SRC_MAIN:.c=.out)

prove_perl: $(PROJ)$(EXE)
	perl -S prove t/*.t

test_enigma: $(PROJ)$(EXE)
	zcc +cpm -oenigma.bin t/data/enigma.c
	echo HELLO. > enigma.in
	cpm enigma.bin < enigma.in > enigma.out
	echo 'Enter text to be (de)coded, finish with a .' > enigma.bmk
	echo 'HREXLSLEOC .' >> enigma.bmk
	diff -w enigma.bmk enigma.out
	$(RM) enigma.bin enigma.in enigma.out enigma.bmk
	
clean::
	$(RM) zcc_opt.def zcc_proj.lst enigma.bin enigma.in enigma.out enigma.bmk

testzcc : $(PROJ)$(EXE)
	zcc +zx -lndos       -create-app -omicroman.bin ../../examples/microman.c
	zcc +zx -lndos -lmzx -create-app -omandel.bin   ../../examples/graphics/mandel.c
	eightyone microman.tap
	eightyone mandel.tap

clean::
	$(RM) zcc_opt.def microman.bin microman.tap
	$(RM) zcc_opt.def mandel.bin   mandel.tap

clean::
	$(RM) $(PROJ)$(EXE) $(LOCAL_LIB)/$(PROJ)$(EXE) test* $(LOCAL_LIB)/test*
	$(RM) t/*.tmp $(LOCAL_LIB)/t/*.tmp t/dev/*.tmp 

#------------------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------------------
clean::
	rm -f $(DEPENDS)
	
-include $(DEPENDS)
