# Z88DK - The Development Kit for Z80 Computers

Z88DK is a collection of software development tools that targets z80 machines.  It allows development of programs in C, assembly language or any mixture of the two.  What makes z88dk unique is its ease of use, built-in support for many z80 machines and its extensive set of assembly language library subroutines implementing the C standard and extensions.

## THE TOOLS

* **ZCC** is the toolchain's front end.  zcc can generate an output binary out of any set of input source files.
* **SCCZ80** is z88dk's native c compiler.   sccz80 is derived from small c but has seen much development to the point that it is nearly c90 compliant.
* **ZSDCC** is z88dk's customization of the [sdcc compiler](https://sourceforge.net/projects/sdcc/).  Our patch makes sdcc compatible with the z88dk toolchain, gives it access to z88dk's extensive assembly language libraries and ready-made crts, addresses some of sdcc's code generation bugs and improves on sdcc's generated code.
* **Z80ASM** (not to be confused with another project called [z80asm](http://www.nongnu.org/z80asm/)) is a fully featured assembler / linker / librarian implementing sections.
* **Z80NM** is z80asm's companion archiver.  It can provide a listing of functions or data encoded in an object or library file.
* **APPMAKE** processes the raw binaries generated by the toolkit into a form suitable for specific target machines.  For example, it can generate intel hex files, tapes, etc.
* **TICKS** is a command line z80 emulator that can be used to time execution speed of code fragments.
* **ZX7** is a PC-side optimal lz77 data compression tool with companion decompression functions in the z80 library.
* **DZX7** is a PC-side decompressor counterpart to zx7.

These tools are not normally directly invoked by the user:

* **M4** acts as z88dk's macro preprocessor and can optionally process files ahead of the c preprocessor or assembler.
* **ZCPP** is the c preprocessor invoked for sccz80.
* **ZSDCPP** is the c preprocessor invoked for zsdcc.
* **ZPRAGMA** is used by the toolchain to process pragmas embedded in c source.
* **COPT** is a regular expression engine that is used as peephole optimizer for sccz80 and as a post-processing tool for both sccz80 and zsdcc.

## BENCHMARKS

The assembly language libraries supplied by z88dk give it performance advantages over other z80 compilers.
(COMPARISON RESULTS COMING)

* **Dhrystone 2.1**  Dhrystone was a common synthetic benchmark for measuring the integer performance of compilers in the 1980s until more modern benchmarks replaced it.  It attempts to simulate typical programs by executing a set of statements statistically determined from common programs.
* **Pi**  Mainly measures 32-bit integer performance.
* **Sieve of Eratosthenes**  Popular benchmark for small machine compilers because just about everything is able to compile it.  As a benchmark it doesn't reveal much more than loop overhead.
* **Whetstone 1.2**  Whetstone is a common synthetic floating point benchmark.
* **Program Size**  Program size has great importance for small machines.  A collection of test programs were compiled for the common cp/m target and resulting binary sizes were compared.

## INSTALLATION

There are three ways to install z88dk.

1. Use the [Most Recent Official Release](https://github.com/z88dk/z88dk/tree/github/Readme#most-recent-official-release) currently v1.99B dated 10 Jan 2017.  Follow these [installation instructions](https://www.z88dk.org/wiki/doku.php?id=temp:front#installation).
2. Get the [Nightly Build](http://nightly.z88dk.org/).  Every night we build complete binary packages for windows and osx and generate source packages for everyone else.  The same [installation instructions](https://www.z88dk.org/wiki/doku.php?id=temp:front#installation) apply.  Using a nightly build means you can keep up with bugfixes and new features rather than having to wait an entire year for a release to occur.
3. Use Github.  Using github will keep you up-to-date with the developers and will allow you to contribute to the project.  We do not store the z80 libraries or the binaries in the github repository.  Instead you will either have to build those things yourself or acquire them from the nightly build to have a working install.
   i **Installing the Z88DK Binaries**   
	  * **Mac OSX** Download the nightly build for osx and copy the z88dk/bin directory to the same place in your z88dk tree.  If you would like to try building the binaries yourself, follow the Other instructions below.   
	  * **Windows** Download the nightly build for win32 and copy the z88dk/bin directory to the same place in your z88dk tree.  You can also build the z88dk binaries yourself using the VS2015 solution found in z88dk/win32 however you should copy the nightly build initially so that various required dlls and some non-z88dk binaries are present.   
	  * **Other** Build the binaries yourself by following these [instructions](https://www.z88dk.org/wiki/doku.php?id=temp:front#linux_unix).
	ii **Installing the Classic Lib Z80 Libraries**  If you installed the z88dk binaries following the Other instructions in (I) you should have also built the classic z80 libraries.  You can confirm this by checking that z88dk/lib/clibs contains about 138 .lib files.  Otherwise you can following one of these two methods:   
	  * **Copy the classic lib library files** from any nightly build by copying the z88dk/lib/clibs directory to the same place in your z88dk tree.   
	  * **Build the classic lib library from source**  Building the classic lib from source requires unix-like tools so windows users will need to use msys or cygwin.  Aside from that the process is simple.  After setting the environment variables as detailed below, open a shell, cd to z88dk/libsrc and enter "make -i".
	iii **Installing the New Lib Z80 Libraries**  If you installed the z88dk binaries following the Other instructions in (I) you should have also built the classic z80 libraries.  You can confirm this by checking that z88dk/libsrc/_DEVELOPMENT/lib contains six .lib files in each of the subdirectories.  Otherwise you can following one of these two methods:   
	  * **Copy the new lib library files** from any nightly build by copying the z88dk/libsrc/_DEVELOPMENT/lib tree to the same place in your z88dk tree.   
	  * **Build the new lib library files**  After setting the environment variables as detailed below, open a command prompt, cd to z88dk/libsrc/_DEVELOPMENT and enter "Winmake all" for windows or "make" for other platforms.

We do not maintain the zsdcc or zsdcpp source code in the repository.  Instead zsdcc is built separately from a [patched sdcc](http://z88dk.cvs.sourceforge.net/viewvc/z88dk/z88dk/libsrc/_DEVELOPMENT/sdcc_z88dk_patch.zip).  We supply the zsdcc and zsdcpp binaries for win32 and osx in the nightly build so if you are using win32 or osx and you copied z88dk/bin, you will already have zsdcc and zsdcpp installed.  Other users will have to build the zsdcc binary by following these [instructions](https://www.z88dk.org/wiki/doku.php?id=temp:front#sdcc1).

The last step for installation is to set the ZCCCFG environment variable and your PATH appropriately.  You can find that information [here](https://www.z88dk.org/wiki/doku.php?id=temp:front#installation).

To verify that the install was successful, try some test compiles from the examples directories in z88dk/examples (classic c lib) and z88dk/libsrc/_DEVELOPMENT/EXAMPLES (new c lib).

## USING Z88DK

Unfortunately, like a lot of open source projects, we could use a lot of help with the documentation.

Some things to know:

* There are [two c compilers](https://www.z88dk.org/wiki/doku.php?id=temp:front#z88dk_supports_two_c_compilers) in z88dk.  Projects must be completely compiled with one compiler only.  Due to various [differences](https://www.z88dk.org/wiki/doku.php?id=temp:front#limitations) the object files generated by the two compilers are [not compatible](#15).
* There are [two c libraries](https://www.z88dk.org/wiki/doku.php?id=temp:front#z88dk_contains_two_independent_c_libraries) in z88dk.  These are referred to as the classic c library and the new c library.
* Thankfully there is only one assembler so we only need to deal with 2*2 combinations :)

When you form a compile line you must decide which compiler you will use and which c library you will link against.  You will make that decision based on which targets you want to compile for and what features you need.

The classic c library is z88dk's original c library and it has crts that allow generation of programs for [50 different z80 machines](https://www.z88dk.org/wiki/doku.php?id=targets).  The level of support for each is historically determined by user interest.  [Documentation begins here](https://www.z88dk.org/wiki/doku.php) and example programs can be found in [z88dk/examples](https://github.com/z88dk/z88dk/tree/master/examples) with compile lines most often appearing at the top of .c files.

The new c library is z88dk's rewrite aiming for a large subset of C11 conformance.  It directly supports five targets currently (cpm, embedded, rc2014, sega master system and zx spectrum) but the [embedded target](https://www.z88dk.org/wiki/doku.php?id=libnew:target_embedded) can also be used to compile programs for any z80 machine.  [Documentation begins here](https://www.z88dk.org/wiki/doku.php?id=temp:front) and example programs can be found in [z88dk/libsrc/_DEVELOPMENT/EXAMPLES](https://github.com/z88dk/z88dk/tree/master/libsrc/_DEVELOPMENT/EXAMPLES) with compile lines most often appearing at the top of .c files.  The documentation for the embedded target gives an excellent overview of how the tools work.

## QUICK LINKS

[Z88DK Home Page](https://www.z88dk.org/forum/)   
Includes a link to the nightly builds where you can get an up-to-date package.

[Install Instructions](https://www.z88dk.org/wiki/doku.php?id=temp:front#installation)

[Forum for Questions](https://www.z88dk.org/forum/forums.php)

[Bug Reporting](https://github.com/z88dk/z88dk/issues)   
(old bugs in the forum)

[Introduction to Compiling Using the Classic C Library](https://www.z88dk.org/wiki/doku.php)   
Examples in [z88dk/examples](https://github.com/z88dk/z88dk/tree/master/examples)

[Introduction to Compiling Using the New C Library](https://www.z88dk.org/wiki/doku.php?id=temp:front)   
Examples in [z88dk/libsrc/_DEVELOPMENT/EXAMPLES](https://github.com/z88dk/z88dk/tree/master/libsrc/_DEVELOPMENT/EXAMPLES)

[Compiling for Generic z80 Embedded Systems Using the New C Library](https://www.z88dk.org/wiki/doku.php?id=libnew:target_embedded)   
For standalone z80 computers.

# MOST RECENT OFFICIAL RELEASE

[Z88DK v1.99B 10 Jan 2017](https://sourceforge.net/projects/z88dk/)

Z88dk is a development kit for z80 computers that contains the tools and assembly language libraries necessary to develop code in either C or assembly language for z80-based machines.

Over 50 different z80 machines have CRTs in the toolkit, allowing C programs to be compiled for them out-of-the-box.

There are two C compilers supported (sccz80 and sdcc), two independent C libraries included (the classic and new), an assembler/linker/librarian (z80asm), and a data compression tool (zx7).

This is the second transition release in anticipation of v2.0.


--8<----- list of changes below -----------------------


PACKAGE

* The win32 and osx packages are complete and now include the zsdcc & zsdcpp binaries.  zsdcc is z88dk's customization of the sdcc compiler.  Other users can compile zsdcc from source.
* A VS2015 solution file is now available in z88dk/win32 for building all z88dk binaries except zsdcc & zsdcpp.  Instructions for building zsdcc & zsdcpp can be found in the install instructions link above.

ZCC - Compiler Front End

* M4 has been added as an optional macro pre-processor.  Any filename ending with extension ".m4" will automatically be passed through M4 and its output written to the original source directory with the ".m4" extension stripped prior to further processing.  The intention is to allow source files like "foo.c.m4", "foo.asm.m4", "foo.h.m4" and so on to be processed by M4 and then that result to be processed further according to the remaining file extension.
* In conjunction with the above, a collection of useful M4 macros has been started in "z88dk.m4" that can be included in any ".m4" file processed by zcc.  Currently macros implementing for-loops and foreach-loops are defined.
* List files ending with extension ".lst" can be used to specify a list of source files for the current compile, one filename per line.  The list file is specified on the compile line with prefix @ as in "@foo.lst".  List files can contain any source files of any type understood by zcc and individual lines can be commented out with a leading semicolon.  Paths of files listed in list files can be made relative to the list file itself (default) or relative to the directory where zcc was invoked (--listcwd).  List files can list other list files, identified with leading '@'.
* zcc now processes all files it is given to the final output file type specified.  For example, with "-E" specified, all listed .c files will be run through the C pre-processor individually and all output copied to the output directory.  Previous to this, only the first file listed was processed unless a binary was being built.
* -v gives more information on what steps zcc takes to process each source file.
* -x now builds a library out of the source files listed.
* -c by itself will generate individual object files for each input source file.  However, if -c is coupled with an output filename as in "-o name", a single consolidated object file will now be built instead of individual ones.  The intention is to provide a means to generate identical code in separate compiles by allowing this single object file to be specified on different compile lines.
* Better error reporting for source files with unrecognized types.
* Better parsing for compile line pragmas; pragma integer parameters can now be in decimal, hexadecimal or octal.
* -pragma-include added to allow a list of compile time pragmas to be read from a file as in "-pragma-include:zpragma.inc".  This way projects can consolidate pragmas in one location; this is especially important for the new c library which uses pragmas extensively to customize the crt.
* -pragma-export added, is similar to -pragma-define but the assembly label defined as a constant on the compile line is made public so that its value is visible across all source files.
* --list will generate ".lis" files for each source file in a compile to a binary.  The ".lis" file is an assembly listing of source prior to input to the linker.
* --c-code-in-asm causes C code to be interspersed as comments in any generated assembly listing associated with C source files.
* ".s" files are now understood by zcc to be asz80-syntax assembly language source files.  This allows sdcc project files written in assembly language to be assembled by z88dk.  asz80 mnemonics are non-standard so zcc attempts to translate to standard zilog mnemonics before assembling.  You can see the translation to standard zilog form by using "-a" on a compile line.  This is still a work-in-progress feature.
* --no-crt allows compiles to proceed without using the library's supplied crt for a target.  The first file listed on a compile line will stand in as the crt and will be responsible for initialization and setting up the memory map.
* Temporary files are always created in the temp directory.  The option "-notemp" has been removed.
* Library and include search paths have been fixed to honour the order specified on the compile line.  This allows the user to override library functions when desired.
* Source files are now processed from their original location so that includes can be properly resolved.  Previously this was only done for .c files but this now applies to other file types.
* clang/llvm compilation is in an experimental state.

Known issues:

* Spaces in paths or filenames can be a problem.
* When --c-code-in-asm is active, unicode characters from .c source files appearing as comments in translated asm may cause the tools to crash.

SCCZ80 - Native C Compiler

* Correct floating point constant handling.
* New __SAVEFRAME__ function decorator to allow saving of ix during a function call.
* -standard-escape-chars to make \n and \r output standard character codes

ZSDCC - Customization of SDCC C Compiler

* Updated to SDCC 3.6.5 #9824.
* SDCC's native C pre-processor is now used so that line numbers corresponding to reported errors are accurate.
* Peephole-z80 fixed to accurately report registers affected by instructions, allowing accurate application of peephole rules.
* inSequence('stride' %1 %2 %3 ...) added as peephole rule qualifier to allow testing whether consecutive bytes in memory are being accessed.
* Peephole-z80 made aware of z88dk special functions which represent code inlined by the library.
* Approximately 300 new peephole rules added to the aggressive peephole set (-SO3).
* Peephole rules added to fix some known code generation bugs and to fix SDCC's critical sections for nmos processors.
* --opt-code-size now significantly reduces code size for programs using 32-bit longs, 64-bit longlongs and floats.
* chars have been made unsigned by default.  Use --fsigned-char to change to signed.
* For loops can now declare variables in the initializer statement.
* An rodata section has been properly implemented so that all constant data generated by sdcc is assigned there.

Z80ASM - Assembler, Linker, Librarian

* Handle input files more predictably: link .o files; assemble any other extension; append a .asm or .o option to the file name to allow just the basename.
* Make a consolidated object file with -o and not -b: all the object modules are merged, the module local symbols are renamed <module>_<symbol>
* Link the library modules in the command line sequence (it was depth-first).
* Add directory of assembled file to the end the include path to allow includes relative to source location.
* Remove all generated files at start of assembly to remove files from previous runs.
* Remove deprecated directives: XREF and LIB (replaced by EXTERN), XDEF and XLIB (replaced by PUBLIC), OZ keep CALL_OZ).
* Rename DEFL to DEFQ to reserve DEFL for macro variables; rename DS.L by DS.Q
* Constants for section sizes: prune empty sections, rename ASMHEAD, ASMTAIL and ASMSIZE to __head, __tail and __size respectively, rename ASM<HEAD|TAIL|SIZE>_<section_name> to __<section_name>_<head|tail|size>
* Environment variables no longer used: Z80_OZFILES, Z80_STDLIB
* Command line option -r, --origin: accept origin in decimal or hexadecimal with '0x' or '$' prefix
* Command line options: -i, -x: require a library name
* Command line options: remove -RCMX000, keep only --RCMX000
* Command line options: remove -plus, keep only --ti83plus
* Command line options: remove -IXIY and --swap-ix-iy, keep --IXIY
* Command line options: remove --sdcc, -nm, --no-map, -ng, --no-globaldef, -ns, --no-symtable, -nv, --no-verbose, -nl, --no-list, -nb, --no-make-bin, -nd, --no-date-stamp, -a, --make-updated-bin, -e, --asm-ext, -M, --obj-ext, -t
* Make symbol files, map files and reloc files optional; do not merge symbols in the list file; do not paginate and cross-reference symbols in list file; rename list file to file.lis (@file.lst is used as project list)
* Unify format used in map files, symbol files and global define files, output list of symbols only once.
* Include symbols computed at link time in the global define file.
* Simplify output of --verbose

APPMAKE - Processes Output Binaries to Target Suitable Form

* +rom can now generate binaries for ROM chips mapped into a specific address range.
* +sms now generates bankswitched .sms files as output.
* +zx now has option to generate headerless .tap files.
* Appmake now understands three compile models -- ram (destined for ram, no stored data section), rom (destined for rom, stored data section is a copy) and compressed rom (destined from rom, stored data section is compressed) -- and will form output files accordingly.

CLASSIC C LIBRARY

* SDCC can now be used to compile using the classic library.
* Rewritten and modular printf core, added (v)snprintf.
* Rewritten and modular scanf core.
* Ports are now section aware.
* Support for compressed data section model.
* Support for copied data section model.
* User overridable fputc_cons.
* New target: Microbee.  Support for various GFX modes and 1 bit sound.
* New target: Robotron kc.  Support for various GFX modes and 1 bit sound.
* New target: z1013.  Support for various GFX modes and 1 bit sound.
* New target: z9001.  Support for various GFX modes and 1 bit sound.
* CP/M Plus on Spectrum.
* CP/M extenstions forced to upper case.
* CP/M extensions improved on Aussie Byte, trs-80 and Epson PX.
* GFX Library: improved the vector rendering functions, now bigger pictures can be drawn and higher resolutions are supported.  Various fixes.
* Custom text configuration (font, resolution) can be done at compile time for targets with ansi VT support on graphics display. 

NEW C LIBRARY

* 64-bit integers are now fully supported in the library.
* The fprintf/fscanf cores can now have conversion specifiers individually enabled or disabled at compile time.  This allows the printf/scanf cores to be tailored to the minimum size required.
* fprintf %aefg precision formatting corrected.
* Intrinsics have been introduced as a method to inline assembly code without disturbing optimization.  This provides a means to insert assembly labels (whose addresses will appear in map files), simple assembly instructions such as "di" and "ei", and atomic loads/stores into C code without affecting the compiler's optimizer.  See [intrinsic.h]( https://www.z88dk.org/wiki/doku.php?id=libnew:intrinsic)
* The library has had a preserves_registers attribute attached to every function that informs sdcc which registers will not be affected by a library call and allows sdcc to generate better code around library calls.
* aplib added as another data decompression utility.
* setjmp/longjmp state increased to include the value of IY for sdcc compiles.  This was necessary as sdcc sometimes requires the value of IY to be preserved at points in the program.
* New target: rc2014 (preliminary).  This target is still being developed by rc2014 users.
* New target: Sega Master System.  The target is able to automatically create bankswitched rom cartridges with signatures.
* ZX Spectrum target: interfaces to the bifrost and nirvana multicolour sprite engines added.
* The CRT startup code has been made more flexible, allowing a wide range of features to be selected via pragmas at compile time.  See [embedded crt configuration](https://www.z88dk.org/wiki/doku.php?id=libnew:target_embedded#crt_configuration).