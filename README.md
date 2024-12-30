# Compiler for the Blue Language

_Please note: the compiler is currently undergoing a complete rewrite. The first version can be found in the [bak](bak) directory._

More details will be added as the new version of the compiler is fleshed out.


## v3

Extremely minimal version of a 64bit forth-like compiler that:

1. Completely stand alone (nostdlib)
1. Supports compile time execution of any word
1. Supports multiple os/architectures/executable formats
1. Works on byte code
1. Quickly can be bootstrapped to a higher level language(s)

### Byte code

vm works on byte code, multi-byte values are assumed to be little-endian

00 q - ( -- n ) read qword from input, push on the data stack
01   - ( -- a ) push addr of code buffer on the data stack

02   - ( a b -- a' ) write byte from TOS to addr, push new addr on the data stack
03   - ( a w -- a' ) write word from TOS to addr, push new addr on the data stack
04   - ( a d -- a' ) write dword from TOS to addr, push new addr on the data stack
05   - ( a q -- a' ) write qword from TOS to addr, push new addr on the data stack

