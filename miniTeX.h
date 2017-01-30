/**
* miniTeX.h
* Header file for miniTeX
*
* @author hb20007
*/


	/* Integers related to user-defined document properties and keeping track of sections and enumerated list items */
	extern int tabSize, linesPerPage, charsPerLine, lineNumberOnPage, pageNumber, sectionCount, currentEnumeratedListItem;
	
	/* Integers used in validation */
	extern const int MIN_TAB_SIZE, MAX_TAB_SIZE, MIN_LINES_PER_PAGE, MIN_CHARS_PER_LINE; 
	
	/* Stores the title, author and date of the document */
	extern char* title;
	extern char* author; 
	extern char* date;
	
	/* When this is true, we are in enumeration mode and any list items will be considered as an enumerate list instead of bullet points */
	extern bool enumerateFlag;
	
	/* An array with counters of how many times each of the 5 document properties appears in the input file. The order of the properties is defined in the enum below */
	extern int docPropertyCounters[5];
	
	/* An enumerated list with the 5 document properties */
	typedef enum {PAGE_SETUP, TAB_SIZE, DOC_TITLE, DOC_AUTHOR, DOC_DATE} document_property; // This is fully defined here that's why there is no extern keyword (it can't be used with this)
	
	/* Prints spaces depending on the tab size */
	void printTab();
	
	/* Checks for all possible errors in document properties */
	void dealWithDocPropertyErrors();
	
	/* Validates the integer passed in as an argument against the lower limit provided. Uses the description argument to print an error */
	void validateInteger(const int toValidate, const char description[], const int lowerLimit, const int upperLimit);
	
	/* Returns the number of digits of the integer passed in */	
	int numberOfDigits(const int num);
	
	/* Prints the page number center-aligned. The spaces after printing the page number are not really required but it looks nicer. */
	void printPageNumber();
	
	/* If we have reached the end of the page we print the page number, increment it and reset the line number */
	void actionIfReachedEndOfPage();
	
	/* Removes first and last character of the string passed "by reference" */
	void removeFirstAndLastChar(char** string);
	
	/* Capitalized the string passed "by reference" */
	void capitalize(char** string);
	
	/* Returns the size of the character array argument. Does not count the null character */
	int charArraySize(const char* str);
	
	/* Prints a new line, increments the number of lines on current page, performs appropriate action if the end of page has been reached */
	void newLineActions();
	
	/* Prints the string inserted as an argument in the output file center-aligned. The spaces after the string are not really required but it looks nicer. */
	void printCenterAligned(const char* s);
	
	/* Prints the string argument left-aligned. Takes into account any characters on the current line already used  */
	void printLeftAligned(const char* s, const int charsUsed);
	
	/* Prints the document title, author and date in the center by calling printCenterAligned() */
	void printDocumentProperties();
	
	/* When printing to the output file is done spaces are printed until the end of the page and then the line number is printed in the center if we are not exactly at the end of a page*/
	void addLineNumberToLastPage();
	
	/* Frees memory created by strdup() in the .l file */
	void freeMemory();