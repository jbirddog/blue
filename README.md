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

To build the BlueVM, tools and examples run `make`. Submodules need to be initialized prior to building.

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
6. Application Code Buffer
6. Application Code Buffer
6. Application Code Buffer
6. Application Code Buffer

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

BlueVM follows a simple byte oriented execution strategy. Using the values from the BlueVM data portion of memory
it begins the outer interpreter:

1. Read byte from and increment instruction pointer
1. Locate the opcode entry in the opcode map
   1. If code address is 0 push the opcode on the data stack and call invalid opcode handler
1. Push the code address and flags on the data stack and call the opcode handler
1. Goto 1

Because of this "late binding" approach, the host can change the values that the BlueVM uses to execute. The outer
interpreter requires that the host termintes execution properly. One way to do this is with the `exit` opcode.

## Opcode Map Structure

Each entry in the opcode map is 16 bytes.

1. Flags (1 byte)
1. Size (1 byte)
1. Code (14 bytes)
   1. Either 8 bytes for addr and 6 empty
   1. Or 14 bytes available for byte or machine code

## Opcode Handler

Once an opcode entry is located in the opcode map the opcode handler is called. The BlueVM has two opcode handlers,
interpret (default) and compile. The interpret handler calls the code address specified in the opcode entry. The
compile handler finds the opcode length in the opcode entry and copies that many bytes, including the opcode, into
the code buffer and advances the code buffer's here.

## Opcodes

Opcodes are subject to change.

### VM Low/High

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x00 | exit | ( b -- ) | Exit with status from top of stack |
| 0x01 | argc | ( -- q ) | Push argc |
| 0x02 | argv | ( -- a ) | Push addr of argv |
| 0x03 | true | ( -- t ) | Push true value |
| 0x04 | false | ( -- f ) | Push false value |
| 0x05 | ifelse | ( t/f ta fa -- ? ) | Call ta if t/f is true else call fa |
| 0x06 | if | ( t/f ta -- ? ) | Call ta if t/f is true |
| 0x07 | ifnot | ( t/f fa -- ? ) | Call fa if t/f is false |
| 0x08 | mccall | ( a -- ? ) | Call machine code at address |
| 0x09 | call | ( a -- ? ) | Call bytecode located at address |
| 0x0A | tor | ( a -- ) | Move top of data stack to return stack |
| 0x0B | fromr | ( -- a ) | Move top of return stacl to data stack |
| 0x0C | ret | ( -- ) | Pops value from return stack and sets the instruction pointer |
| 0x0D | comp | ( -- ) | Begin compiling bytecode |
| 0x0E | endcomp | ( -- a ) | Append ret and end compilation, push addr where compilation started |
| 0x0F | op | ( b -- a ) | Push addr of the offset into the op table for the opcode |
| 0x10 | oph | ( -- a ) | Push addr of the opcode handler |
| 0x11 | setvarb | ( b b -- ) | Set litb value of var op |
| 0x12 | setvarw | ( w b -- ) | Set litw value of var op |
| 0x13 | setvard | ( d b -- ) | Set litd value of var op |
| 0x14 | setvarq | ( q b -- ) | Set litq value of var op |
| 0x15 | ib | ( -- a ) | Push addr of the input buffer |
| 0x16 | ip | ( -- a ) | Push location of the instruction pointer |
| 0x17 | setip | ( a -- ) | Set the location of the instruction pointer |
| 0x18 | start | ( -- a ) | Push addr of the code buffer's start |
| 0x19 | here | ( -- a ) | Push addr of the code buffer's here |
| 0x1A | sethere | ( a -- ) | Set addr of the code buffer's here |
| 0x1B | atincb | ( a -- b a' ) | Push byte value found at addr, increment and push addr |
| 0x1C | atincw | ( a -- w a' ) | Push word value found at addr, increment and push addr |
| 0x1D | atincd | ( a -- d a' ) | Push dword value found at addr, increment and push addr |
| 0x1E | atincq | ( a -- q a' ) | Push qword value found at addr, increment and push addr |
| 0x1F | atb | ( a -- b ) | Push byte value found at addr |
| 0x20 | atw | ( a -- d ) | Push word value found at addr |
| 0x21 | atd | ( a -- w ) | Push dword value found at addr |
| 0x22 | atq | ( a -- q ) | Push qword value found at addr |
| 0x23 | setincb | ( a b -- 'a ) | Write byte value to, increment and push addr |
| 0x24 | setincw | ( a w -- 'a ) | Write word value to, increment and push addr |
| 0x25 | setincd | ( a d -- 'a ) | Write dword value to, increment and push addr |
| 0x26 | setincq | ( a q -- 'a ) | Write qword value to, increment and push addr |
| 0x27 | setb | ( a b -- ) | Write byte value to addr |
| 0x28 | setw | ( a w -- ) | Write word value to addr |
| 0x29 | setd | ( a d -- ) | Write dword value to addr |
| 0x2A | setq | ( a q -- ) | Write qword value to addr |
| 0x2B | cb | ( b -- ) | Write byte value to and increment here |
| 0x2C | cw | ( w -- ) | Write word value to and increment here |
| 0x2D | cd | ( d -- ) | Write dword value to and increment here |
| 0x2E | cq | ( q -- ) | Write qword value to and increment here |
| 0x2F | litb | ( -- b ) | Push next byte from and increment instruction pointer |
| 0x30 | litw | ( -- w ) | Push next word from and increment instruction pointer |
| 0x31 | litd | ( -- d ) | Push next dword from and increment instruction pointer |
| 0x32 | litq | ( -- q ) | Push next qword from and increment instruction pointer |
| 0x33 | depth | ( -- n ) | Push depth of the data stack |
| 0x34 | dup | ( x -- ) | Drops top of the data stack |
| 0x35 | drop | ( a -- a a ) | Duplicate top of stack |
| 0x36 | swap | ( a b -- b a ) | Swap top two values on the data stack |
| 0x37 | not | ( x -- 'x ) | Bitwise not top of the data stack |
| 0x38 | eq | ( a b -- t/f ) | Check top two items for equality and push result |
| 0x39 | add | ( a b -- n ) | Push a + b |
| 0x3A | sub | ( a b -- n ) | Push a - b |
| 0x3B | shl | ( x n -- 'x ) | Push x shl n |
| 0x3C | shr | ( x n -- 'x ) | Push x shr n |

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

1. Write a bs0->blasm (msalb) decompiler by overwriting opcode map/handler
1. Tool to patch a BlueVM binary with custom ext ops and/or input buffer

## TODOs

1. Add an opcode to ops_vm that is kinda high up and `make` fails until `make clean`
1. setq, etc stack effects feel backwards when not in test code
   1. see swap in op_setvarq, etc
1. Better name for `op_oph` since opcode handler has different meaning in the vm
1. Bring back a simpiler version of the `blue` language
1. See about re-arranging >r order in op_compile_begin to simplify it and op_compile_end
1. Grok more fasmg magic to improve blasm syntax
1. Add opcodes for litb, etc
1. Print error messages to disambiguate exit status
