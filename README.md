# miniTeX

***
								
## 1. About

miniTeX is a simple text formatting language intended to illustrate the basics of languages such as TeX. This repository contains the code for the compiler of the language. The grammar can be found in `Notes.txt`

## 2. Language

My code is written in **C11**. I have made use of the _Flex_ and _Bison_ tools for lexical analysis and parser generation.


## 3. Operating System

miniTeX compiles and works correctly on Windows 10 with Flex 2.5.4a using the GCC 6.3 C compiler. It should also work on other platforms and with other versions of Flex even though I haven't confirmed that by testing.

## 4. List of files

The following files should be in the miniTeX folder:
>      1. miniTeX.l
>      2. miniTeX.y
>      3. miniTeX.h
>      4. ExampleSourceFile.txt


## 5. Compilation instructions

The instructions below are for the GCC C compiler on Windows.
	  
The input file is `ExampleSourceFile.txt` and the output file is `output1.txt`.

It is assumed that the environment variables for Flex, Bison and GCC are configured correctly and that the programs can be called from within the command prompt.

Open cmd and navigate to the directory with the miniTeX files. Then execute the following commands:

```
      nmake # generate miniTeX.exe
	  nmake clean # delete auto-generated files
  	  miniTeX ExampleSourceFile.txt output.txt
```

The commands above are for the Windows command-line interpreter.

If using Bash instead, in `makefile` replace every instance of `flex` with `lex`, `bison` with `yacc` and `del` with `rm`. Then use `make` as opposed to `nmake` in the command line.