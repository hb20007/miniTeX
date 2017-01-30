# miniTeX by hb20007
#
# This makefile will only end up being executed on Windows. The purpose is to give an icon and version information to miniTeX.exe
#
# In winresources.rc the weird numbers in the BLOCK and VALUE lines are codes for US English
#

winresources.rs: winresources.rc
	windres winresources.rc -O coff -o winresources.rs
	mv winresources.rs ..
# The Common Object File Format (COFF) is a specification of a format for executable, object code
# mv winresources.rs .. copies winresources.rs to the parent directory where it will be required to make on Windows. The Windows equivalent to mv is move.