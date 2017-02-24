/**
* @author hb20007
* @brief yacc source file for miniTeX
*/

/* DECLARATIONS */

%{
	#include <stdio.h>
	#include <stdlib.h> // For free() and exit()
	#include <string.h> // For strdup()
	#include <ctype.h> // For toupper()
	#include <stdbool.h> // For bool
	#include <limits.h> // For INT_MAX
	#include "y.tab.h"
	#include "miniTeX.h" // Header file with my external (public) types, variables, and functions.
	
	void yyerror(const char *);
	int yylex(void);
	
	/* "Connect" with the output file  */
	extern FILE *yyout;
	extern int  yylineno;
	
	int tabSize, linesPerPage, charsPerLine, lineNumberOnPage = 1, pageNumber = 1, sectionCount = 1, currentEnumeratedListItem = 1;
	
	const int MIN_TAB_SIZE = 0, MAX_TAB_SIZE = 7, MIN_LINES_PER_PAGE = 1, MIN_CHARS_PER_LINE = 20; // The min chars per line was set at 20 due to enumeration lists. Max tab size is 7. 7*2 = 14. + 1 for the dot = 15. + 5 for the max no. of digits in the enumeration number assumed = 20. OLD COMMENT: The min chars per line was set as 15 because when printing itemize lists I set a max tab size to 7. There are 2 tabs and a * on each line so that's 15 chars. Increasing max tab size decreases the min no. of chars per line but I think 7 and 15 is a good compromise. // OLD COMMENT: The minimum characters per line was chosen to be 7 because the maximum number of digits in the section number was assumed to be 5. +2 for the dot and space = 7. So printLeftAligned() will not work properly with less than 7 characters per line in the extreme case of very large section numbers
	
	char* title; /* char* title, author, date; is wrong. In C that would have been char *title, *author, *date because typically in C it's int *p while in C++ it's int* p */
	char* author; 
	char* date;
	
	bool enumerateFlag;
	
	int docPropertyCounters[5];
	
	static inline char *stringFromDocPropertyEnum(const document_property indexOfProperty) { // There is no extern prototype for this method in the header because extern and static cannot be used together
		static char *strings[] = { "\\pagesetup{}", "\\tabsize()", "\\title{}", "\\author{}", "\\date{}"};
		return strings[indexOfProperty];
	}
	
	void printTab() {
		for (int i = 0; i < tabSize; i++)
			fprintf(yyout, " ");
	}
	
	void dealWithDocPropertyErrors() {
		for (int i = 0; i < sizeof(docPropertyCounters)/sizeof(docPropertyCounters[0]); i++) {
			if (docPropertyCounters[i] < 1) { 
				/* yyerror() is not used in this function because the line number does not need to be shown */
				fprintf(stderr, "SYNTAX ERROR: Your source file does not contain the required document property %s", stringFromDocPropertyEnum(i)); 
				exit(-1);
			}
			if (docPropertyCounters[i] > 1) {
				fprintf(stderr, "SYNTAX ERROR: Your source file contains more than one instance of the document property %s", stringFromDocPropertyEnum(i));
				exit(-2);
			}
		}
	}
	
	void validateInteger(const int toValidate, const char description[], const int lowerLimit, const int upperLimit) {
		if (toValidate < lowerLimit) {
			// yyerror() is not used in this function because it is for syntax errors
			fprintf(stderr, "SEMANTIC ERROR near line [%d]: The %s specified (%d) is less than the lower limit allowed (%d)", yylineno, description, toValidate, lowerLimit);
			exit(-3);
		}
		if (toValidate > upperLimit) {
			fprintf(stderr, "SEMANTIC ERROR near line [%d]: The %s specified (%d) is more than the upper limit allowed (%d)", yylineno, description, toValidate, lowerLimit);
			exit(-4);
		}
	}
	
	int numberOfDigits(const int num)  {  
    return (num < 10 ? 1 :   
        (num < 100 ? 2 :   
        (num < 1000 ? 3 :   
        (num < 10000 ? 4 :   // This function is used on page numbers, section numbers, and item numbers when enumerating. It is assumed there can be no documents with more than 100,000 pages/sections or enumeration lists with more than 100,000 items (5 is the maximum number returned)
        5))));  
		// This approach may seem naive but is probably the fastest way to do it.
	}
	
	void printPageNumber() {
		// The algorithm below is an alternative to the one I used to print the other things center-aligned
		int spaces = (charsPerLine - numberOfDigits(pageNumber)) / 2;
		for (int i = 0; i < spaces * 2 + 1; i++)
		{
			if (i == spaces) 
				fprintf(yyout, "%d", pageNumber);
			else 
				//printf(".");
				fprintf(yyout, " ");
		}
		// If the two numbers have a different parity we need an extra space
		if (charsPerLine % 2 != numberOfDigits(pageNumber) % 2) 
			fprintf(yyout, " ");
	}
	
	void actionIfReachedEndOfPage() {
			if (lineNumberOnPage > linesPerPage) { // If (lineNumberOnPage == linesPerPage) nothing happens, we just print on the last line allowed. The footer with the line number and the new lines before and after it are not considered part of the page
				fprintf(yyout, "\n");
				printPageNumber();
				fprintf(yyout, "\n");
				fprintf(yyout, "\n");
				pageNumber++;
				lineNumberOnPage = 1;
		}
	}
	
	void removeFirstAndLastChar(char** string) {
		*string += 1; // Removes the first character
		int i = 0;
		for (; (*string)[i] != '\0'; i++);
			(*string)[i - 1] = '\0';
	}
	
	void capitalize(char** string) { // Using this kind of functions is the only way I could find of manipulating the $ pseudo-variabls
		int i = 0;
		for (; (*string)[i] != '\0'; i++)
			(*string)[i] = toupper((*string)[i]);
	}
	
	int charArraySize(const char* str) {
		int i = 0;
		for(; str[i] != '\0'; i++);
		return i;
	}
	
	void newLineActions() {
		fprintf(yyout, "\n");
		lineNumberOnPage++;
		actionIfReachedEndOfPage();
	}
	
	void printCenterAligned(const char* s) {
		// I check if I am exceeding the limit for that line. If I am I call it again in the next line with what's remaining in the string. The code below is best understood with an example (eg. s = "abc" and charsPerLine = 2)
		if (charArraySize(s) > charsPerLine) {
			char* s2 = strdup(s);
			s2[charsPerLine] = '\0';
			printCenterAligned(s2);
			free(s2);
			s += charsPerLine;
			printCenterAligned(s); // To subject s to further checks
			return; // We return at this point because whenever the function is called and the if condition is triggered, we just want to split the string and get more recursive calls to the function with smaller strings. Printing only occurs for the strings which are small enough and don't trigger the if.
		}
		// At this point charArraySize(s) is less than or equal to charsPerLine
		int numberOfSpaces = charsPerLine - charArraySize(s); // This is either 0 or a positive number
		int numberOfSpacesAtStart = numberOfSpaces / 2;
		for (int i = 0; i < numberOfSpacesAtStart; i++)
			fprintf(yyout, " ");
		fprintf(yyout, "%s", s);
		int numberOfSpacesAtEnd = numberOfSpaces - numberOfSpacesAtStart;
		for (int i = 0; i < numberOfSpacesAtEnd; i++)
			fprintf(yyout, " ");
		newLineActions();
		// Word wrap using a '-' was not implemented because it is not appropriate for center aligned text
	}
	
	void printLeftAligned(const char* s, const int charsUsed) {
		if (charArraySize(s) > (charsPerLine - charsUsed)) {
			bool wordWrapFlag = false;
			char* s2 = strdup(s);
			s2[charsPerLine - charsUsed] = '\0';
			if ((s2[charsPerLine - charsUsed - 1] >= 'A' && s2[charsPerLine - charsUsed - 1] <= 'Z') || (s2[charsPerLine - charsUsed - 1] >= 'a' && s2[charsPerLine - charsUsed - 1] <= 'z')) { // If it is a letter
				wordWrapFlag = true;
				s2[charsPerLine - charsUsed - 1] = '\0';
				if ((s2[charsPerLine - charsUsed - 2] >= 'A' && s2[charsPerLine - charsUsed - 2] <= 'Z') || (s2[charsPerLine - charsUsed - 2] >= 'a' && s2[charsPerLine - charsUsed - 2] <= 'z'))
					s2[charsPerLine - charsUsed - 1] = '-';
			} // Explanation of word wrap code: if s2[charsPerLine - charsUsed - 1] is a letter, we delete it. Then we check if the character before it as a letter too. If it is, we put a '-' in the place of the deleted thing. If it is not, it is left deleted and it will appear as a space. The purpose of this is to be able to print the extra hyphen when needed without exceding the number of allowed characters per line 
			printLeftAligned(s2, 0); // s2 for sure is less than charsPerLine but it is printed through a recursive call to the function because the function correctly takes care of newLineActions();
			free(s2);
			if (wordWrapFlag) // If word wrap occured s has an extra character instead of the deleted one
				s += (charsPerLine - charsUsed - 1);	
			else 
				s += (charsPerLine - charsUsed);
			if (*s == ' ') // If the line got cut at a space, it does not not to be displayed at the beginning of the next line
				s += 1;
			printLeftAligned(s, 0); // The charsUsed problem was dealt with so the next time the function is called that is 0.
			return;
		}
		fprintf(yyout, "%s", s);
		newLineActions(); // New line actions needed in the case of recursive calls of this function. The drawback of this necessity is that there will be a newline at the end of the document.
	}
	
	void printDocumentProperties() {
		printCenterAligned(title);
		printCenterAligned("by");
		printCenterAligned(author);
		printCenterAligned(date);
	}
	
	void addLineNumberToLastPage() {
		// The line number for the last page will always be inserted using this function. There can never be a case where the last page already has a line number by the time this is called. 
		while(lineNumberOnPage <= linesPerPage) {
			fprintf(yyout, "\n");
			lineNumberOnPage++;
		}
		fprintf(yyout, "\n");
		printPageNumber();
	}
	
	void freeMemory() {
		// Freeing memory created by strdup()
		free(title);
		free(author);
		free(date);
	}
%}

%union { /* The union keyword in flex includes all the possible C types a token may have. If omitted only the default (int) is allowed. */
    int iValue;      /* integer value */ 
    char* sValue;    /* C-String */ 
}; 

%error-verbose /* sometimes provides better error reporting. Useful sometimes when debugging */

%start file /* defining the start condition. Only required in the cases where the grammar does not begin with the start symbol but I included it anyway. */

%token LBRACE RBRACE LPAREN RPAREN COMMA

%token DOCUMENT ITEMIZE ENUMERATE

%token BEGIN_ END /* BEGIN seems to be a reserved word so BEGIN_ was used instead */

%token PAGESETUP TABSIZE TITLE AUTHOR DATE

%token SECTION PARAGRAPH ITEM NEWLINE

%token <iValue> INTEGER

%token <sValue> DDMMYYYYDATE STRING

%%

/* RULES */

file: beginDocument docProperties textProperties endDocument
			{ 
			    addLineNumberToLastPage();
				freeMemory();
			}
		  | /* An empty document is parsed to an empty document, no errors generated */
		  ;

beginDocument: BEGIN_ LBRACE DOCUMENT RBRACE;
		  
	/* required properties... there should be one instance of each in the input file in the correct order */	
docProperties: 	pageSetupProperty tabSizeProperty titleProperty authorProperty dateProperty
				{
					dealWithDocPropertyErrors();
					printDocumentProperties();
				}
				;
	
			  
pageSetupProperty: PAGESETUP LBRACE INTEGER COMMA INTEGER RBRACE
				   {
					   validateInteger($3, "lines per page", MIN_LINES_PER_PAGE, INT_MAX); // We know that it is not more than INT_MAX because it is stored as an integer but we pass INT_MAX in because there is no upper limit
					   linesPerPage = $3;
					   validateInteger($5, "characters per line", MIN_CHARS_PER_LINE, INT_MAX);
					   charsPerLine = $5;
					   docPropertyCounters[PAGE_SETUP]++;
				   }
				   ;
				   
tabSizeProperty: TABSIZE LPAREN INTEGER RPAREN
				 {
					validateInteger($3, "tab size", MIN_TAB_SIZE, MAX_TAB_SIZE);
						
					tabSize = $3;
					docPropertyCounters[TAB_SIZE]++; 
				 }
				 ;
				
titleProperty: TITLE LBRACE STRING RBRACE
			   {
				   /* $4 is copied into title excluding the quotation marks at the beginning and end of the string */
				   char *temp = $3; /* Temporary pointer needed to avoid undefined behavior for attempting to modify a string literal when calling removeFirstAndLastChar() */
				   title = temp;
				   removeFirstAndLastChar(&title);
				   docPropertyCounters[DOC_TITLE]++;
			   }
			   ;
			   
authorProperty: AUTHOR LBRACE STRING RBRACE
				{
					char *temp = $3;
					author = temp;
					removeFirstAndLastChar(&author);
					docPropertyCounters[DOC_AUTHOR]++;
				}
				;
				
dateProperty: DATE LBRACE DDMMYYYYDATE RBRACE
			  {
				  date = $3;
				  docPropertyCounters[DOC_DATE]++;
			  }
			  ;

textProperties: textProperties textProperty
				| /* empty */
				;

textProperty: sectionProperty
		      | paragraphProperty
			  | itemizeProperty
			  | enumerateProperty
			  | newlineProperty
			  ;
			  
sectionProperty: SECTION LBRACE STRING RBRACE
                 {
					newLineActions();
					
					char* sectionName = $3;
					removeFirstAndLastChar(&sectionName);
					capitalize(&sectionName);
					
					fprintf(yyout, "%d. ", sectionCount);
					int usedCharsOnLine = numberOfDigits(sectionCount++) + 2; // The extra 2 digits are for the dot and the space. Section count is post-incremented in preparation for the next section
					printLeftAligned(sectionName, usedCharsOnLine);
					
					newLineActions();
                 }
				 ;

paragraphProperty: PARAGRAPH LBRACE STRING RBRACE
                   {
						char* paragraphName = $3;
						removeFirstAndLastChar(&paragraphName);
						
						printTab();
						printLeftAligned(paragraphName, tabSize);
                   }
				   ;
   
itemizeProperty: beginItemize itemProperties endItemize;

enumerateProperty: beginEnumerate itemProperties endEnumerate;

beginItemize: BEGIN_ LBRACE ITEMIZE RBRACE
			  {
				  enumerateFlag = false;
			  }
			  ; 				
			  
endItemize: END LBRACE ITEMIZE RBRACE;			  

beginEnumerate: BEGIN_ LBRACE ENUMERATE RBRACE
				{
					enumerateFlag = true;
					currentEnumeratedListItem = 1; // Resets the enumerated list item counter
				}
				;
				
endEnumerate: END LBRACE ENUMERATE RBRACE;				

itemProperties: itemProperties itemProperty;
				| /* empty */
				;

itemProperty: ITEM LBRACE STRING RBRACE
			  {
				char* itemName = $3;
				removeFirstAndLastChar(&itemName);
				
				printTab();

				if (enumerateFlag) 
					fprintf(yyout, "%d.", currentEnumeratedListItem);
				else
					fprintf(yyout, "* "); // The space is added to align the * lists with enumerated lists

				// Instead of printTab() the following code is used. This ensures that when the currentEnumeratedListItem reaches 10 or more, it will still be aligned with the rest of the items. However this is only possible if tabSize > 5 because 5 was earlier on assumed to be the maximum number of digits an item number can reach and we need to deduct this from tabSize. if tabSize is 5, in the worst case scenario 5-5 = 0 so no spaces. I consider that less neat than having spaces but ones which are not perfectly aligned so I need tabSize to be > 5. I don't want to decrease the number "5" which I assume to be the list item even though it is extremely pessimistic simply because the program will be ruined if a user tries to have a list with items of more than 9,999 items.
				if (tabSize > 5)
					for(int i = 0; i < tabSize - numberOfDigits(currentEnumeratedListItem); i++)
						fprintf(yyout, " ");
				else
					printTab();
				
				if (enumerateFlag) 
					printLeftAligned(itemName, 2 * tabSize + numberOfDigits(currentEnumeratedListItem++) + 1); // + 1 for the .
				else
					printLeftAligned(itemName, 2 * tabSize + 2); // + 1 for the * and space
			  }
			  ;
			  
newlineProperty: NEWLINE
                 {
					newLineActions();
                 }
				 ;
			  
endDocument: END LBRACE DOCUMENT RBRACE;

%%

/* ROUTINES */

int yywrap(void) {
	return 1;
}

void yyerror(const char* str) 
{
    fprintf(stderr,"SYNTAX ERROR near line [%d]: %s\n", yylineno, str);
}