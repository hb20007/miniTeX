/**
* @file miniTeX.l
* @author hb20007
* @brief lex source file for miniTeX
*/

/* DEFINITIONS */

%{
	#include <string.h> // For strdup()
	#include "y.tab.h"
	
	void yyerror(const char *);
	int yylex(void);
	
	extern FILE *yyout; /* "Connection" with the output file */
	extern int  yyparse();
%}

/* %option noyywrap;	 Tells flex not to declare the function yywrap() which is only useful in the case of more than 1 input file */
	/* Allows printing the line number (of an error) */
%option yylineno
	/* Catches some errors */
%option nodefault
	/* Tells flex not to generate code for the input() and unput() functions which I will not be using */
%option nounput
%option noinput
	/* Prints the tokens flex recognizes to the console. Useful when debugging and avoids having to write printf() statements for that */
%option debug

%%

\{	return LBRACE;
\}	return RBRACE;
\(	return LPAREN;
\)	return RPAREN;
,	return COMMA;

document  return DOCUMENT;
itemize   return ITEMIZE;
enumerate return ENUMERATE;

\\begin    return BEGIN_; /* It is not assumed that properties have to be at the very beginning of a line so ^\\ is not used. */
\\end      return END;

\\pagesetup return PAGESETUP;
\\tabsize   return TABSIZE;
\\title	    return TITLE;
\\author 	return AUTHOR;
\\date      return DATE;

\\section    return SECTION;
\\paragraph  return PARAGRAPH;
\\item  	 return ITEM;
\\newline    return NEWLINE;

(((0[1-9]|[12][0-9]|30)[-\/ ]?(0[13-9]|1[012])|31[-\/ ]?(0[13578]|1[02])|(0[1-9]|1[0-9]|2[0-8])[-\/ ]?02)[-\/ ]?[0-9]{4}|29[-\/ ]?02[-\/ ]?([0-9]{2}(([2468][048]|[02468][48])|[13579][26])|([13579][26]|[02468][048]|0[0-9]|1[0-6])00))	{ yylval.sValue = strdup(yytext); return DDMMYYYYDATE; } /* strdup() is string duplicate. yytext must be copied because of its temporary nature */ 
-?[0-9]*[0-9][0-9]*	{ yylval.iValue = atoi(strdup(yytext)); return INTEGER; } /* This also accepts negative integers and 0. */
\".*\"				{ yylval.sValue = strdup(yytext); return STRING; } 

	/* This regex recognizes a C-style comment. There is no action associated since the comment is not passed to the parser. */
\/\*.*\*\/	;

	/* Skip whitespace which is not part of a string. [ \t\r\n]+ is better than [ \t\r\n] performance-wise. */
[ \t\r\n]+ ;

	/* Anything else is an error. */
. yyerror("Invalid character");

%%

/* C CODE SECTION */

/**
* @brief Main function
* @param argc Count of the command line arguments
* @param argv An argument array of the command line arguments
* @return An integer 0 upon exit success
*/
int main(int argc, char *argv[]) {
	if ( argc != 3)
		printf("ERROR: You need 2 args, input file name and output file name."); // yyerror() is not used because no line number needs to be displayed.
	else {
		yyin = fopen(argv[1], "r");
		yyout = fopen(argv[2], "w");
		yyparse();
		fclose(yyin);
		fclose(yyout);
	}
	return 0;
}