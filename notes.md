# Notes

## 1. General Notes

- `\tabsize()` is the only property that uses `()` instead of `{}`.
- Each line can contain multiple properties that can appear anywhere in the text.
- `\begin{document}` and `\end{document}` should be the first and last tokens, but
  they do not need to appear on the first and last lines of the file.
- Whitespace is totally ignored between tokens, and integers are allowed to be
  preceded by 0. So `\pagesetup{2,5}` and `\pagesetup { 2, 05 }` are the same. However,
  there cannot be a space between the backslash and the property name.
- When the page number is printed, an empty line is printed before and after it as
  well. For a document of 30 lines per page, lines 1–30 will contain the text of page 1.
  Lines 31 and 33 are empty lines, and line 32 contains the page number. Page 2 text
  will span lines 34–63, and so on.
- I have implemented a word wrap feature that allows text to flow to the next line,
  and a hyphen is inserted if the text is split in the middle of a word.
- The date regex I used is a standard expression that verifies all possible dates and
  accounts for leap years. Therefore, it covers checking the date for both syntax
  and semantic errors.
- Most of the other lexical and syntax errors were addressed using
  Flex/Bison exclusively. Lexical errors are caught by Flex when
  matching the regular expressions. Syntax errors are caught by Bison when applying
  the tokens to the BNF grammar. The line `%option debug` in my `.l` file instructs Flex
  to print all the tokens it has parsed, as well as any unexpected input, along with
  the line number and what it was expecting.
  Semantic errors were addressed by utilizing C functions to validate user input.
- C-style `/* ... */` comments can be included in the source files and will be ignored
  by the compiler. This is roughly equivalent to using % to write comments in LaTeX.
- The whole text of a paragraph must be on the same line in the source file.
- Like LaTeX commands, miniTeX commands are case-sensitive.

## 2. BNF Grammar

The BNF grammar is provided below in Yacc format for ease of reference with my Bison
file.

Names written in ALL-CAPS are non-terminals defined in terms of a regular expression, while
those written in camelCase are non-terminals defined in terms of other non-terminals.
For the non-terminals written in ALL-CAPS, it was not possible to define them the
conventional way (i.e., using a | b | c | ... | y | z notation, etc.) because some of them are
very complex (e.g., DDMMYYYYDATE). Therefore, I defined them in terms of terminals using regex.

My grammar is free of shift/reduce and reduce/reduce conflicts.

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

LBRACE: \{ /* (The slash represents the escape character. From this point, I use regex.) */
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
DDMMYYYYDATE: (((0[1-9]|[12][0-9]|30)[-\/ ]?(0[13-9]|1[012])|31[-\/
]?(0[13578]|1[02])|(0[1-9]|1[0-9]|2[0-8])[-\/ ]?02)[-\/ ]?[0-9]{4}|29[-\/ ]?02[-\/
]?([0-9]{2}(([2468][048]|[02468][48])|[13579][26])|([13579][26]|[02468][048]|0[0-9]|1[0-6
])00))
INTEGER: -?[0-9]*[0-9][0-9]*
STRING: \".*\"
```

## 3. Implementation Notes

- In the initial stages of my program, I had a separate token for `\`.
  However, in some cases, this results in the parser needing a two-token lookahead to
  determine where properties end. I addressed this issue by removing the
  backslash token entirely and incorporating the backslash into
  the property tokens instead.
- In earlier stages of my program, I allowed the user to insert the document
  properties in any order as long as they were provided before the text properties. I
  then implemented checks to verify whether a property was omitted or entered more than once.
  However, this later proved to be infeasible. The checks needed to occur after
  parsing the entire file due to the recursive nature of the document properties that
  had to be implemented. I was unable to output the title, author, and date strings immediately
  upon receiving the tokens from Bison. The only solution would have been to create
  a 2D array and store all the output there before printing it to the output file in one go.
  However, that is inelegant, and I made changes to require that the document properties be
  given in a certain order. The extensive checks for document properties in my code are
  a remnant of the earlier stages, where I allowed them to be inserted in an arbitrary order.
- My flexible definition of a string (`.*` in regex) indicates that a token like `\tabsize(5)`
  would be parsed entirely as a string, as opposed to being broken down to `\tabsize`, `(`,
  and `)`. This is because of the rule that the longest pattern matched is chosen. I dealt with
  this problem without resorting to a more restrictive definition for a string by
  requiring that all strings be enclosed by `""`.
