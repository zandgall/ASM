# Miscellaneous Assembly Projects

An assortment of x86-64 Assembly (YASM/NASM(/MASM?)) files.

`lib/` contains files that commit or provide basic functions, whereas `test/` contains mini programs that use these library files.
The library has functions that resemble the C standard library, as it is what I was basing most of it off of, replicating functionality found [here](https://www.gnu.org/software/libc/manual/)

`cmp.sh` can be invoked in the Linux terminal to compile a porgram, (so long as YASM is installed, easily done via `sudo apt install yasm`, or with whichever package manager you choose).
