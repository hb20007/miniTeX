#
# Makefile for miniTeX
#
# Compiler: GCC
# Other requirements: Flex, Bison
# (Replace every instance of flex with lex, bison with yacc and del with rm in the makefile if using Bash)
#
 
miniTeX: y.tab.o lex.yy.o
	gcc lex.yy.o y.tab.o -o miniTeX
# We finally link the .o files using the C compiler. This is the whole point. The .o files are updated only when the dependencies change.

y.tab.o: y.tab.c y.tab.h
	gcc -c y.tab.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.c y.tab.h: miniTeX.y
	bison -dl -o y.tab.c miniTeX.y

lex.yy.c: miniTeX.l
	flex miniTeX.l

clean:
	del *.o
	del *.c
	del y.tab.h

#target: dependencies
#	action