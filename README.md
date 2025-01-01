# Compiler for the Blue Language

_Please note: the compiler is currently undergoing a complete rewrite. Earlier versions can be found in the bak* directories._

More details will be added as the new version of the compiler is fleshed out.


## v3

Extremely minimal version of a 64bit forth-like compiler that aims to:

1. Be completely stand alone (nostdlib)
1. Supports compile time execution of any previously defined word
1. Supports multiple os/architectures/executable formats
1. Works on byte code (no textual parsing)
1. Quickly be bootstrapped to a higher level language(s)

### Requirements

version numbers are not exact requirements, just what i am using at time of writing

1. linux 6.12.7_1 x86_64
1. fasm 1.73.30
1. xxd 2024-09-15

### Byte code

vm works on byte code, multi-byte values are assumed to be little-endian. op codes are subject to change.

| Op Code | Reads | Stack Effect | Description |
|----|----|----|----|
| 00 | byte | ( -- b ) | read byte from input, push on the data stack |
| 01 | word | ( -- w ) | read word from input, push on the data stack |
| 02 | dword | ( -- d ) | read dword from input, push on the data stack |
| 03 | qword | ( -- q ) | read qword from input, push on the data stack |
| 04 | | ( -- a ) | push addr of code buffer's here on the data stack |
| 05 | | ( a -- ) | set addr of code buffer's here |
| 06 | | ( a b -- a' ) | write byte to addr, push new addr on the data stack |
| 07 | | ( a w -- a' ) | write word to addr, push new addr on the data stack |
| 08 | | ( a d -- a' ) | write dword to addr, push new addr on the data stack |
| 09 | | ( a q -- a' ) | write qword to addr, push new addr on the data stack |
| 0A | | ( -- a ) | push addr of code buffer start on the data stack |
| 0B | | ( n1 n2 -- n ) | n1 - n2, push result on the data stack
| 0C | | ( n1 n2 -- n ) | n1 + n2, push result on the data stack
| 0D | | ( x -- ) | drop top of the data stack

### Stages

_Stage 0_

A binary file ending in `bs0` is a stage 0 file that contains a run of bytes that are executed by the blue
compiler.

_Stage 1_

A textual file ending in `bs1` that allows minimal formatting/commenting. Line comments start with `#`. A stage 1
file is lowered to a stage 0 file by stripping comments and running it through `xxd`.

### TODOs:

1. add example that prints hello world and exits cleanly
1. elf bs1 file could contain compile time helper functions for setting file size and entry
1. replace usage of grep/xxd with own program that lowers bs1 files to bs0 files
1. add tuck op
1. add swap op
1. fix elf post TODO with tuck/swap
1. pull linux specific code out of blue.asm, have x86_64/linux/blue.inc
