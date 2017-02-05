NOTES
=====

- - - - 

## 1. General Notes ##

* `\tabsize()` is the only property that uses `()` instead of `{}`

* It is not assumed that properties should be at the beginning of a line or that two
properties cannot be on the same line.

* It is also not assumed that `\begin{document}` should be on the first line of the file
or that `\end{document}` should be at the end of file even though `\begin{document}`
and `\end{document}` should be the first and last token respectively. This provides
for more flexibility.

* Whitespace is totally ignored between tokens. Also integers are allowed to be
preceded by 0. So `\pagesetup{2,5}` and `\pagesetup { 2, 05 }` are the same. However,
there cannot be a space between the backslash and the property name.

* When the page number is printed, an empty line is printed before and after it as
well. For a document of 30 lines per page, lines 1-30 will contain the text of page 1.
Lines 31 and 33 are empty lines and line 32 contains the page number. Page 2 text
will span lines 34-63 etc.

* I have implemented a word wrap feature where text wraps to the next line and a
hyphen is inserted if the text is cut in the middle of a word.

* The date regex I used is a standard regex for verifying all dates taking into
consideration leap years. Therefore it covers checking the date for both syntax
and semantic errors.

* Most of the other lexical and syntax errors were dealt with using
Flex/Bison functionality exclusively. Lexical errors are caught by Flex when
matching the regex expressions. Syntax errors are caught by Bison when applying
the tokens to the BNF grammar. The line `%option debug` in my `.l` file means Flex
will print to the console in detail the tokens it has parsed as well as any
unexpected input along with the line number and what it was expecting. Semantic
errors were dealt with using C functions to validate the user input

* C-style `/* ... */` comments can be included in the source files and will be ignored 
by the compiler. This is roughly equivelent to using % to write comments in LaTeX.

* The whole text of a paragraph must be on the same line in the source file.

* miniTeX commands are case-sensitive, just like LaTeX commands.


## 2. BNF Grammar ##

The BNF grammar is provided below in Yacc format for ease of reference with my Bison
file.

Names written in ALL-CAPS are non-terminals defined in terms of a regex expression while
those written in camelCase are non-terminals defined in terms of other non-terminals.
For the non-terminals written in ALL-CAPS, it was not possible to define them the
conventional way (ie. using a | b | c | ... | y | z notation etc.) because some of them are
very complex (eg. DDMMYYDATE). Therefore I will define them in terms of terminals
with the help of regex.

My grammar does not lead to any shift/reduce or reduce/reduce conflicts.

```C
file: beginDocument docProperties textProperties endDocument;
beginDocument: BEGIN_ LBRACE DOCUMENT RBRACE;
docProperties: pageSetupProperty tabSizeProperty titleProperty authorProperty dateProperty;
pageSetupProperty: PAGESETUP LBRACE INTEGER COMMA INTEGER RBRACE;
tabSizeProperty: TABSIZE LPAREN INTEGER RPAREN;
titleProperty: TITLE LBRACE STRING RBRACE;
authorProperty: AUTHOR LBRACE STRING RBRACE;
dateProperty: DATE LBRACE DDMMYYYYDATE RBRACE;
textProperties: textProperties textProperty;
textProperty: sectionProperty | paragraphProperty | itemizeProperty | enumerateProperty | newlineProperty;
sectionProperty: SECTION LBRACE STRING RBRACE;
paragraphProperty: PARAGRAPH LBRACE STRING RBRACE;
itemizeProperty: beginItemize itemProperties endItemize;
enumerateProperty: beginEnumerate itemProperties endEnumerate;
beginItemize: BEGIN_ LBRACE ITEMIZE RBRACE;
endItemize: END LBRACE ITEMIZE RBRACE;
beginEnumerate: BEGIN_ LBRACE ENUMERATE RBRACE;
endEnumerate: END LBRACE ENUMERATE RBRACE;
itemProperties: itemProperties itemProperty;
itemProperty: ITEM LBRACE STRING RBRACE;
newlineProperty: NEWLINE;
endDocument: END LBRACE DOCUMENT RBRACE;

LBRACE: \{ /* (The slash is the escape character. From this point onward I use regex) */
RBRACE: \}
LPAREN: \(
RPAREN: \)
COMMA: ,
DOCUMENT: document
ITEMIZE: itemize
ENUMERATE: enumerate
BEGIN_: \\begin
END: \\end
PAGESETUP: \\pagesetup
TABSIZE: \\tabsize
TITLE: \\title
AUTHOR: \\author
DATE: \\date
SECTION: \\section
PARAGRAPH: \\paragraph
ITEM: \\item
NEWLINE: \\newline
DDMMYYYDATE: (((0[1-9]|[12][0-9]|30)[-\/ ]?(0[13-9]|1[012])|31[-\/
]?(0[13578]|1[02])|(0[1-9]|1[0-9]|2[0-8])[-\/ ]?02)[-\/ ]?[0-9]{4}|29[-\/ ]?02[-\/
]?([0-9]{2}(([2468][048]|[02468][48])|[13579][26])|([13579][26]|[02468][048]|0[0-9]|1[0-6
])00))
INTEGER: -?[0-9]*[0-9][0-9]*
STRING: \".*\"
```

## 3. Implementation Notes ##

* In the initial stages of my program I had a separate token for `\`.
However in some cases this leads to the parser requiring a two-token lookahead to
determine where properties end. I dealt with this problem by removing the
backslash token altogether and including the backslash as part of the property
tokens instead.

* In earlier stages of my program I allowed the user to insert the document
properties in any order as long as they are provided before the text properties. I
then coded checks to see if a property was left out or if one was entered twice.
However, this later proved to be infeasible. The checks I mentioned had to take
place after the whole file was parsed because of the recursive nature of the
definition of the document properties that had to be implemented. The
consequence of that is that I was not able to output the title, author and date
strings as soon as the token is received by Bison. The only solution would have
been creating a 2D array and storing all the output there and then printing it to
the output file in one go. However, that is inelegant and I made changes in my
code to require that the document properties are given in a certain order. The
extensive checks for document properties in my code are a remnant of the earlier
stages where I allowed them to be inserted in an arbitrary order.

* Due to my flexible description of a string (`.*` in regex), a token like `\tabsize(5)`
would be parsed entirely as a string as opposed to being broken down to `\tabsize`, `(`
and `)` because of the rule that the longest pattern matched is chosen. I dealt with
this problem without resorting to a more restrictive definition for a string by
requiring that all strings are enclosed by `“ ”`.