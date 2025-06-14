_This file is generated from README.md.tmpl_

# BlueVM

Minimalistic 64 bit virtual machine inspired by Forth and Factor. The BlueVM aims to:

1. Have a reasonably small, simplistic and hackable codebase
1. Support execution of any previously compiled machine or bytecode
1. Provide a minimal set of opcodes that can be extended by the host
1. Serve as the basis for minimalistic handcrafted applications
1. Allow the host full control
1. Bring some fun back into the world

BlueVM bytecode is stored in block sized (1024 byte) files that, by convention, have a `.bs0` (BlueVM Stage 0)
extension.

## Building

To build the BlueVM, tools and examples run `make`.

## Block Structure

The BlueVM binary consists of six blocks (1024 bytes each) in rwx memory:

0. Core VM machine code (including ELF headers)
0. BlueVM Opcodes 0x00 - 0x3F
0. BlueVM Opcodes 0x40 - 0x7F
0. Extended Opcodes 0x80 - 0xBF
0. Extended Opcodes 0xC0 - 0xFF
0. Input buffer

BlueVM also reserves space for the following blocks in rwx memory:

6. Return and Data stack
6. Code buffer
6. Application block
6. Application block
6. Application block

BlueVM itself performs no allocations once it is loaded into memory.

The block structure makes it very easy to patch or slice a BlueVM binary to create a custom standalone executable.
As a quick example, assuming you have a `obj/hello_world.bs0` file compiled with `blasm` and a `bin/bluevm`:

```
$ dd if=bin/bluevm of=bin/bluevm_noib bs=1024 count=5 status=none && \
	cat bin/bluevm_noib obj/hello_world.bs0 > bin/hello_world && \
	chmod +x bin/hello_world && \
	./bin/hello_world
Hello, World!
```

## Boot

If the first 8 bytes of the input buffer are zero then 1024 bytes will be read from stdin into the input buffer.
The input buffer will serve as the bootstrap for the host and is interpreted until the host stops execution.

## Execution

BlueVM follows a simple byte oriented execution strategy:

1. Read byte from and increment instruction pointer
1. Locate the opcode entry in the opcode table
   1. If interpreting, call the opcode entry's code address
   1. If compiling, copy number of bytes equal to the opcode entry's length to the code buffer and advance `here`
1. Goto 1

Because of this "late binding" approach, the host can change the values that the BlueVM uses to execute. The
interpreter requires that the host termintes execution properly. One way to do this is with the `exit` opcode.

## Opcode Map Structure

Each entry in the opcode map is 16 bytes.

1. Flags (1 byte)
1. Size (1 byte)
1. Code (14 bytes)
   1. Either 8 bytes for addr and 6 empty
   1. Or 14 bytes available for byte or machine code

## Opcodes

Opcodes are subject to change.

### VM Low/High

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x00 | exit | ( b -- ) | Exit with status from top of stack |
| 0x01 | argc | ( -- q ) | Push argc |
| 0x02 | argv | ( -- a ) | Push addr of argv |
| 0x03 | blk | ( b -- a ) | Push addr of block number b |
| 0x04 | true | ( -- t ) | Push true value |
| 0x05 | false | ( -- f ) | Push false value |
| 0x06 | ifelse | ( t/f ta fa -- ? ) | Call ta if t/f is true else call fa |
| 0x07 | mccall | ( a -- ? ) | Call machine code at address |
| 0x08 | call | ( a -- ? ) | Call bytecode located at address |
| 0x09 | tor | ( a -- ) | Move top of data stack to return stack |
| 0x0A | fromr | ( -- a ) | Move top of return stack to data stack |
| 0x0B | ret | ( -- ) | Pops value from return stack and sets the instruction pointer |
| 0x0C | comp | ( -- ) | Begin compiling bytecode |
| 0x0D | endcomp | ( -- a ) | Append ret and end compilation, push addr where compilation started |
| 0x0E | opentry | ( b -- a ) | Push addr of the entry in the op table for the opcode |
| 0x0F | setvarb | ( b b -- ) | Set litb value of var op |
| 0x10 | setvarw | ( w b -- ) | Set litw value of var op |
| 0x11 | setvard | ( d b -- ) | Set litd value of var op |
| 0x12 | setvarq | ( q b -- ) | Set litq value of var op |
| 0x13 | ip | ( -- a ) | Push location of the instruction pointer |
| 0x14 | setip | ( a -- ) | Set the location of the instruction pointer |
| 0x15 | here | ( -- a ) | Push addr of the code buffer's here |
| 0x16 | atincb | ( a -- b a' ) | Push byte value found at addr, increment and push addr |
| 0x17 | atincw | ( a -- w a' ) | Push word value found at addr, increment and push addr |
| 0x18 | atincd | ( a -- d a' ) | Push dword value found at addr, increment and push addr |
| 0x19 | atincq | ( a -- q a' ) | Push qword value found at addr, increment and push addr |
| 0x1A | setincb | ( a b -- 'a ) | Write byte value to, increment and push addr |
| 0x1B | setincw | ( a w -- 'a ) | Write word value to, increment and push addr |
| 0x1C | setincd | ( a d -- 'a ) | Write dword value to, increment and push addr |
| 0x1D | setincq | ( a q -- 'a ) | Write qword value to, increment and push addr |
| 0x1E | cb | ( b -- ) | Write byte value to and increment here |
| 0x1F | cw | ( w -- ) | Write word value to and increment here |
| 0x20 | cd | ( d -- ) | Write dword value to and increment here |
| 0x21 | cq | ( q -- ) | Write qword value to and increment here |
| 0x22 | litb | ( -- b ) | Push next byte from and increment instruction pointer |
| 0x23 | litw | ( -- w ) | Push next word from and increment instruction pointer |
| 0x24 | litd | ( -- d ) | Push next dword from and increment instruction pointer |
| 0x25 | litq | ( -- q ) | Push next qword from and increment instruction pointer |
| 0x26 | depth | ( -- n ) | Push depth of the data stack |
| 0x27 | dup | ( x -- ) | Drops top of the data stack |
| 0x28 | drop | ( a -- a a ) | Duplicate top of stack |
| 0x29 | swap | ( a b -- b a ) | Swap top two values on the data stack |
| 0x2A | not | ( x -- 'x ) | Bitwise not top of the data stack |
| 0x2B | eq | ( a b -- t/f ) | Check top two items for equality and push result |
| 0x2C | add | ( a b -- n ) | Push a + b |
| 0x2D | sub | ( a b -- n ) | Push a - b |
| 0x2E | and | ( a b -- n ) | Push logical and of a and b |
| 0x2F | or | ( a b -- n ) | Push logical inclusive or of a and b |
| 0x30 | shl | ( x n -- 'x ) | Push x shl n |
| 0x31 | shr | ( x n -- 'x ) | Push x shr n |
| 0x32 | scall0 | ( d -- q ) | Make syscall _d_ with no arguments |
| 0x33 | scall1 | ( q0 d -- q ) | Make syscall _d_ with one argument |
| 0x34 | scall2 | ( q1 q0 d -- q ) | Make syscall _d_ with arguments q0...q1 |
| 0x35 | scall3 | ( q2 q1 q0 d -- q ) | Make syscall _d_ with arguments q0...q2 |
| 0x36 | scall4 | ( q3 q2 q1 q0 d -- q ) | Make syscall _d_ with arguments q0...q3 |
| 0x37 | scall5 | ( q4 q3 q2 q1 q0 d -- q ) | Make syscall _d_ with arguments q0...q4 |
| 0x38 | scall6 | ( q5 q4 q3 q2 q1 q0 d -- q ) | Make syscall _d_ with arguments q0...q5 |

### Extended Low/High

Host applications are free to implement their own opcodes which can be spliced into a BlueVM binary. For an example
see `tools/bth`.

## Tools/Examples

Along with the code for BlueVM this repository also contains some tools and examples that can be used as reference:

| Name | Descripton | Location |
|----|----|----|
| blasm | Assembles BlueVM bytecode block files using `fasmg` | lang/blasm |
| bth | Patched version of the BlueVM with extended opcodes to facilitate testing. | tools/bth |

### Ideas for more tools/examples

1. bldis - bs0->bla disassembler
1. Tool to create string file from an ops tbl file, to be used by bldis
1. Tool to patch a BlueVM binary with custom blocks
   1. Would also change binary size in elf headers
   1. Remove the reserved blocks from the binary
1. Tool to check stack effects

## Before Merge

1. Order of scall ops
1. Update bth to use syscall ops

## TODOs

1. Make opcode 0 `halt ( -- )` instead of `exit ( n -- )` 
1. What if data_stack_here was always in, say rbp?
   1. Would remove the double dereference
1. Move boot code to bytecode, or maybe better drop it all together
   1. If dropped, need to change tests that `bluevm < test`
1. Rename code buffer to output buffer
1. Get some writing about BlueVM, blasm, bth
1. Bug: add/remove ops and `make` fails until `make clean`
1. Bring back a simpiler version of the `blue` language
1. See about re-arranging >r order in op_compile_begin to simplify it and op_compile_end
1. Grok more fasmg magic to improve blasm syntax
