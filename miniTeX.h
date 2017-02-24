/**
* @file miniTeX.h
* @author hb20007
* @brief Header file for miniTeX
*/

// (Below is a member group in doxygen syntax)

//@{
/** @name Integers related to user-defined document properties and keeping track of sections and enumerated list items */ 
extern int tabSize;
extern int linesPerPage;
extern int charsPerLine;
extern int lineNumberOnPage;
extern int pageNumber;
extern int sectionCount;
extern int currentEnumeratedListItem;
//@}	

//@{
/** @name Integers used in validation */
extern const int MIN_TAB_SIZE; 
extern const int MAX_TAB_SIZE;
extern const int MIN_LINES_PER_PAGE;
extern const int MIN_CHARS_PER_LINE;
//@}

//@{
/** @name The title, author and date of the document are stored in these variables */
extern char* title;
extern char* author; 
extern char* date;
//@}
	
/** 
* @brief Flag for enumeration/bullet points mode
* When this is true, we are in enumeration mode and any list items will be considered as an enumerate list instead of bullet points
*/
extern bool enumerateFlag;
	
// extern const int cannot be used because in C const means 'read-only' as opposed to constant.	
#define NUMBER_OF_DOC_PROPERTIES 5
	
/** 
* @brief An array of the document property counters
* An array with counters of how many times each of the document properties appears in the input file. The order of the properties is defined in the enum below
*/
extern int docPropertyCounters[NUMBER_OF_DOC_PROPERTIES];
	
/** 
* @brief An enumerated list with the 5 document properties. A problem with Doxygen causes the elements to be duplicated in the documentation.
*/
typedef enum {PAGE_SETUP,	/**< "\pagesetup{}" */
			  TAB_SIZE,		/**< "\tabsize()" */
			  DOC_TITLE,	/**< "\title{}" */
			  DOC_AUTHOR,	/**< "\author{}" */
			  DOC_DATE		/**< "\date{}" */
			  } document_property; // This is fully defined here that's why there is no extern keyword (it can't be used with this)

/** 
* @brief Prints spaces depending on the tab size
*/
extern void printTab();

/**
* @brief Checks for all possible errors in document properties
*/
extern void dealWithDocPropertyErrors();

/**
* @brief Validates the integer passed in as one the arguments
* Validates the integer passed in as an argument against the limits provided. Uses the description argument to print an error.
*
* @param toValidate The integer to be validated
* @param description Used to print an error in the case there is one
* @param lowerLimit The lower bound of the valid range
* @param upperLimit The upper bound of the valid range
*/
extern void validateInteger(const int toValidate, const char description[], const int lowerLimit, const int upperLimit);

/**
* @brief Returns the number of digits of the integer passed in
* @param num The integer
* @return The number of digits
*/
extern int numberOfDigits(const int num);

/**
* @brief Prints the page number center-aligned
* @note Also prints spaces after the page number on the same line. They are not really required but it looks nicer.
*/
extern void printPageNumber();

/**
* @brief Called when we reach the end of a page
* Prints the page number, increments it and resets the line number
*/
extern void actionIfReachedEndOfPage();

/**
* @brief Removes first and last character of the string passed "by reference"
* @param string The string
*/
extern void removeFirstAndLastChar(char** string);

/**
* @brief Capitalizes the string passed "by reference"
* @param string The string
*/
extern void capitalize(char** string);
	
/**
* @brief Returns the size of the character array argument
* @param str The string
* @note Does not count the null character
*/
extern int charArraySize(const char* str);
	
/**
* @brief Called on a new line
* Prints a new line, increments the number of lines on current page, performs appropriate action if the end of page has been reached
*/
extern void newLineActions();
	
/**
* @brief Prints the string inserted as an argument in the output file center-aligned
* @param s The string
* @note Also prints spaces after the string on the same line. They are not really required but it looks nicer.
*/
extern void printCenterAligned(const char* s);
	
/**
* @brief Prints the string argument left-aligned
* @param s The string
* @param charsUsed Allows the function to take into account any characters on the current line already used
* @note Also prints spaces after the string on the same line. They are not really required but it looks nicer.
*/
extern void printLeftAligned(const char* s, const int charsUsed);
	
/**
* @brief Prints the title, author and date in the center by calling @code printCenterAligned() @endcode
*/
extern void printDocumentProperties();
	
/**
* @brief Prints new lines until we are at the end of the page and then prints the line number in the center
*/
extern void addLineNumberToLastPage();
	
/**
* @brief Frees memory created by @code strdup() @endcode in the .l file
*/
extern void freeMemory();