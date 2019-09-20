#
# Makefile for miniTeX
#
# Compiler: GCC
# Other requirements: Flex, Bison
#
# NB: On Windows, MSYS make must be used. MinGW make and Microsoft's nmake do not support ifeq and the makefile leads to errors. Also rm was used instead of del etc.
#
# To download MSYS make on Windows, see http://www.mingw.org/wiki/MSYS
#

PROGRAM_NAME = miniTeX
CC = gcc
LEX = flex
YACC = bison -dl

# .PHONY: clean

# uname_S is set to the user's OS
ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

# If the OS is Windows, we will integrate resources/winresources.cs in the compilation. This creates a file called winresources.rs in the project directory.
ifeq ($(uname_S), Windows)
$(PROGRAM_NAME): y.tab.o lex.yy.o resources
	cd resources && $(MAKE)
	$(CC) lex.yy.o y.tab.o winresources.rs -o $(PROGRAM_NAME)
# For Windows, we execute the make file in the resources directory. winresources.rc was placed in that directory because it is only for Windows and shouldn't be in the parent directory.
# The 2 commands above are executed in separate shells so no need for "cd ..".
else
$(PROGRAM_NAME): y.tab.o lex.yy.o
	$(CC) lex.yy.o y.tab.o -o $(PROGRAM_NAME)
endif

y.tab.o: y.tab.c y.tab.h
	$(CC) -c y.tab.c

lex.yy.o: lex.yy.c
	$(CC) -c lex.yy.c

y.tab.c y.tab.h: $(PROGRAM_NAME).y
	$(YACC) -o y.tab.c $(PROGRAM_NAME).y

lex.yy.c: $(PROGRAM_NAME).l
	$(LEX) $(PROGRAM_NAME).l

ifeq ($(uname_S), Windows)
clean:
	rm -f *.o
	rm -f *.c
	rm -f y.tab.h
	rm -f winresources.rs
else
clean:
	rm -f *.o
	rm -f *.c
	rm -f y.tab.h
endif