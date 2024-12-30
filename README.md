# Compiler for the Blue Language

_Please note: the compiler is currently undergoing a complete rewrite. The first version can be found in the [bak](bak) directory._

More details will be added as the new version of the compiler is fleshed out.


## v3

Extremely minimal version of a 64bit forth-like compiler that:

1. Completely stand alone (nostdlib)
1. Supports compile time execution of any word
1. Supports multiple os/architectures/executable formats
1. Works on byte code (no textual parsing)
1. Quickly can be bootstrapped to a higher level language(s)

### Requirements

version numbers are not exact requirements, just what i am using at time of writing

linux 6.12.7_1 x86_64
fasm 1.73.30
xxd 2024-09-15

### Byte code

vm works on byte code, multi-byte values are assumed to be little-endian

00 b - ( -- b ) read byte from input, push on the data stack
01 w - ( -- w ) read word from input, push on the data stack
02 d - ( -- d ) read dword from input, push on the data stack
03 q - ( -- q ) read qword from input, push on the data stack

04   - ( -- a ) push addr of code buffer's here on the data stack
05   - ( a -- ) set addr of code buffer's here

06   - ( a b -- a' ) write byte to addr, push new addr on the data stack
07   - ( a w -- a' ) write word to addr, push new addr on the data stack
08   - ( a d -- a' ) write dword to addr, push new addr on the data stack
09   - ( a q -- a' ) write qword to addr, push new addr on the data stack

