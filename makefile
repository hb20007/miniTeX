#
# Makefile for miniTeX
#
# Compiler: GCC
# Other requirements: Flex, Bison
#
# NB: On Windows, MSYS make must be used. MinGW make and Microsoft's nmake do not support ifeq and the makefile leads to errors. Also rm was used instead of del etc.
#
# To download MSYS make on Windows see: http://www.mingw.org/wiki/MSYS 
#

#uname_S is set to the user's OS
ifeq ($(OS),Windows_NT)
	uname_S := Windows
else
	uname_S := $(shell uname -s)
endif

#if the OS is Windows, we will integrate Resources/winresources.cs in the compilation. This creates a file called winresources.rs in the project directory.
ifeq ($(uname_S), Windows)
miniTeX: y.tab.o lex.yy.o Resources
	cd Resources && $(MAKE)
	gcc lex.yy.o y.tab.o winresources.rs -o miniTeX
# For Windows, we execute the make file in the Resources directory. winresources.rc was placed in that directory because it is only for Windows and shouldn't be in the parent directory
# The 2 commands above are executed in separate shells so no need for cd ..	
else
miniTeX: y.tab.o lex.yy.o
	gcc lex.yy.o y.tab.o -o miniTeX
endif

y.tab.o: y.tab.c y.tab.h
	gcc -c y.tab.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.c y.tab.h: miniTeX.y
	bison -dl -o y.tab.c miniTeX.y

lex.yy.c: miniTeX.l
	flex miniTeX.l

ifeq ($(uname_S), Windows)
clean:
	rm *.o
	rm *.c
	rm y.tab.h
	rm winresources.rs
#The Windows equivalent to rm is del
else
clean:
	rm *.o
	rm *.c
	rm y.tab.h
endif
		
#target: dependencies
#	action