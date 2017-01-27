miniTeX by H. Z. Sababa (hb20007)       
                                
                                        
1. ABOUT

      miniTeX is a simple text formatting language intended to illustrate the basics of
languages such as TeX. This repository contains the code for the compiler of the language.
The grammar can be found in Notes.txt


2. PROGRAMMING LANGUAGE

      My code is written in C11. I have made use of the Flex and Bison tools for lexical 
analysis and parser generation.


3. OPERATING SYSTEM

      miniTeX compiles and works correctly on Windows 10 with Flex 2.5.4a using the 
GCC 6.3 C compiler. It should theoretically also work on other platforms and with other v-
ersions of Flex even though I haven't confirmed that by testing.



                                            1                                             

4. LIST OF FILES

      The following files should be in the miniTeX folder:
      1.     miniTeX.l
      2.     miniTeX.y
      3.     miniTeX.h
      4.     ExampleSourceFile.txt


5. COMPILATION INSTRUCTIONS

      The instructions below are for the GCC C compiler on Windows.
	  
      The input file is "ExampleSourceFile.txt.txt" and the output 
file is "output1.txt".

      It is assumed that the environment variables for Flex, Bison and GCC are configured 
correctly and that the programs can be called from within the command prompt.

      Open cmd and navigate to the directory with the miniTeX files. Then execute th-
e following commands:

      1.     flex miniTeX.l
      2.     bison -dl -o y.tab.c miniTeX.y
      3.     gcc lex.yy.c y.tab.c -o miniTeX
      4.     miniTeX.exe ExampleSourceFile.txt output.txt




                                            2                                             