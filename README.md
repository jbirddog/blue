# BlueVM

Minimalistic 64 bit virtual machine inspired by Forth and Factor. The BlueVM aims to:

1. Have a reasonably small, simplistic and hackable codebase
1. Support execution of any previously compiled machine or bytecode
1. Provide a minimal set of opcodes that can be extended by the host
1. Serve as the basis for minimalistic handcrafted applications
1. Allow the host full control
1. Bring some fun back into the world

By convention BlueVM bytecode files have a `bs0` (BlueVM Stage 0) extension.

## Building

To build the BlueVM, tools and examples run ./build.sh

## Memory Layout

The BlueVM has the following layout in rwx memory:

1. Opcode Map (4096 bytes)
   1. BlueVM Opcode Map: 0x00 - 0x7F (2048 bytes)
   1. Extended Opcode Map: 0x80 - 0xFF (2048 bytes)
1. Input buffer (2048 bytes)
1. Return stack (512 bytes)
1. Data stack (512 bytes)
1. Runtime Data (1024 bytes)
   1. User data (960 bytes)
   1. BlueVM addresses (64 bytes)
1. Code Buffer (4096 bytes)

## Boot

BlueVM will set entries in the BlueVM opcode map and read 2048 bytes from stdin into the input buffer. This
initial read will serve as the bootstrap for the host and is interpreted until the host stops execution.

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

Opcodes start at 00 and subject to change.

### Core

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x00 | exit | ( b -- ) | Exit with status from top of stack |
| 0x01 | true | ( -- t ) | Push true value |
| 0x02 | false | ( -- f ) | Push false value |
| 0x03 | ifelse | ( t/f ta fa -- ? ) | Call ta if t/f is true else call fa |
| 0x04 | mccall | ( a -- ? ) | Call machine code at address |
| 0x05 | call | ( a -- ? ) | Call bytecode located at address |
| 0x06 | tor | ( a -- ) | Move top of data stack to return stack |
| 0x07 | fromr | ( -- a ) | Move top of return stacl to data stack |
| 0x08 | ret | ( -- ) | Pops value from return stack and sets the instruction pointer |
| 0x09 | comp | ( -- ) | Begin compiling bytecode |
| 0x0A | endcomp | ( -- a ) | Append ret and end compilation, push addr where compilation started |
| 0x0B | ip | ( -- a ) | Push location of the instruction pointer |
| 0x0C | setip | ( a -- ) | Sets the location of the instruction pointer |
| 0x0D | op | ( b -- a ) | Push addr of the code for opcode |
| 0x0E | start | ( -- a ) | Push addr of the code buffer's start |
| 0x0F | here | ( -- a ) | Push addr of the code buffer's here |
| 0x10 | sethere | ( a -- ) | Set addr of the code buffer's here |
| 0x11 | atincb | ( a -- b a' ) | Push byte value found at addr, increment and push addr |
| 0x12 | atincw | ( a -- w a' ) | Push word value found at addr, increment and push addr |
| 0x13 | atincd | ( a -- d a' ) | Push dword value found at addr, increment and push addr |
| 0x14 | atincq | ( a -- q a' ) | Push qword value found at addr, increment and push addr |
| 0x15 | atb | ( a -- b ) | Push byte value found at addr |
| 0x16 | atw | ( a -- d ) | Push word value found at addr |
| 0x17 | atd | ( a -- w ) | Push dword value found at addr |
| 0x18 | atq | ( a -- q ) | Push qword value found at addr |
| 0x19 | setincb | ( a b -- 'a ) | Write byte value to, increment and push addr |
| 0x1A | setincw | ( a w -- 'a ) | Write word value to, increment and push addr |
| 0x1B | setincd | ( a d -- 'a ) | Write dword value to, increment and push addr |
| 0x1C | setincq | ( a q -- 'a ) | Write qword value to, increment and push addr |
| 0x1D | cb | ( b -- ) | Write byte value to and increment here |
| 0x1E | cw | ( w -- ) | Write word value to and increment here |
| 0x1F | cd | ( d -- ) | Write dword value to and increment here |
| 0x20 | cq | ( q -- ) | Write qword value to and increment here |
| 0x21 | litb | ( -- b ) | Push next byte from and increment instruction pointer |
| 0x22 | litw | ( -- w ) | Push next word from and increment instruction pointer |
| 0x23 | litd | ( -- d ) | Push next dword from and increment instruction pointer |
| 0x24 | litq | ( -- q ) | Push next qword from and increment instruction pointer |
| 0x25 | depth | ( -- n ) | Push depth of the data stack |
| 0x26 | dup | ( x -- ) | Drops top of the data stack |
| 0x27 | drop | ( a -- a a ) | Duplicate top of stack |
| 0x28 | swap | ( a b -- b a ) | Swap top two values on the data stack |
| 0x29 | not | ( x -- 'x ) | Bitwise not top of the data stack |
| 0x2A | eq | ( a b -- t/f ) | Check top two items for equality and push result |
| 0x2B | add | ( a b -- n ) | Push a + b |
| 0x2C | sub | ( a b -- n ) | Push a - b |
| 0x2D | shl | ( x n -- 'x ) | Push x shl n |
| 0x2E | shr | ( x n -- 'x ) | Push x shr n |

## Tools/Examples

Along with the code for BlueVM this repository also contains some tools and examples that can be used as reference:

| Name | Descripton | Location |
|----|----|----|
| blasm | Assembles BlueVM bytecode using `fasmg` | lang/blasm |

### Idea for more tools/examples

1. Write a bs0->blasm (msalb) decompiler by overwriting opcode map/handler

## TODOs

1. Bring back a simpiler version of the `blue` language
1. Add ! flavors
   1. Use in Blue opcodes
1. See about re-arranging >r order in op_compile_begin to simplify it and op_compile_end
1. Add more ops to make defining a custom op less verbose/brittle
   1. opN[ ]op
   1. opNI[ ]op
   1. opB[ ]op
   1. opBI[ ]op
1. Makefile needs to invalidate bs0 files when asm or inc files change
1. Grok more fasmg magic to improve blasm syntax
1. Add bytecode op if/if-not
1. Add opcodes for litb, etc
1. Print error messages to disambiguate exit status
