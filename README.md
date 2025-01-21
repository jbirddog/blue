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

The BlueVM requires a single allocation with the following layout in rwx memory:

1. Input buffer (2048 bytes)
1. Return stack (1024 bytes)
1. Data stack (1024 bytes)
1. Opcode Map (4096 bytes)
   1. BlueVM Opcode Map: 0x00 - 0x7F (2048 bytes)
   1. Extended Opcode Map: 0x80 - 0xFF (2048 bytes)
1. Runtime Buffer (4096 bytes)
   1. BlueVM addresses (64 bytes)
   1. Code Buffer (4032 bytes)

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
| XX | exit | ( b -- ) | Exit with status from top of stack |
| XX | true | ( -- t ) | Push true value |
| XX | false | ( -- f ) | Push false value |
| XX | if-else | ( t/f ta fa -- ? ) | Call ta if t/f is true else call fa |
| XX | mccall | ( a -- ? ) | Call machine code at address |
| XX | call | ( a -- ? ) | Call bytecode located at address |
| XX | >r | ( a -- ) | Move top of data stack to return stack |
| XX | r> | ( -- a ) | Move top of return stacl to data stack |
| XX | ret | ( -- ) | Pops value from return stack and sets the instruction pointer |
| XX | [ | ( -- ) | Begin compiling bytecode |
| XX | ] | ( -- a ) | Append ret and end compilation, push addr where compilation started |
| XX | ip | ( -- a ) | Push location of the instruction pointer |
| XX | ip! | ( a -- ) | Sets the location of the instruction pointer |
| XX | entry | ( b -- a ) | Push addr of the entry for opcode |
| XX | start | ( -- a ) | Push the code buffer location |
| XX | here | ( -- a ) | Push location of code buffer's here |
| XX | here! | ( a -- ) | Sets the location of code buffer's here |
| XX | b@ | ( a -- b ) | Push byte value found at addr |
| XX | @ | ( a -- ) | Push qword value found at addr |
| XX | b!+ | ( a b -- 'a ) | Write byte value to, increment and push addr |
| XX | d!+ | ( a d -- 'a ) | Write dword value to, increment and push addr |
| XX | !+ | ( a q -- 'a ) | Write qword value to, increment and push addr |
| XX | b, | ( b -- ) | Write byte value to, and increment, here |
| XX | d, | ( d -- ) | Write dword value to, and increment, here |
| XX | , | ( q -- ) | Write qword value to, and increment, here |
| XX | litb | ( -- b ) | Push next byte from, and increment, instruction pointer |
| XX | lit | ( -- q ) | Push next byte from, and increment, instruction pointer |

### Stack operations

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| XX | depth | ( -- n ) | Push depth of the data stack |
| XX | drop | ( x -- ) | Drops top of the data stack |
| XX | dup | ( a -- a a ) | Duplicate top of stack |
| XX | swap | ( a b -- b a ) | Swap top two values on the data stack |
| XX | not | ( x -- 'x ) | Bitwise not top of the data stack |
| XX | = | ( a b -- t/f ) | Check top two items for equality and push result |
| XX | + | ( a b -- n ) | Push a + b |
| XX | - | ( a b -- n ) | Push a - b |

## Tools/Examples

Along with the code for BlueVM this repository also contains some tools and examples that can be used as reference:

| Name | Descripton | Location |
|----|----|----|
| blang | Quick and dirty compiler for a textual representation of the BlueVM bytecode | examples/blang |

### Idea for more tools/examples

1. Write a bs0->blang (gnalb) decompiler by overwriting opcode map/handler

## TODOs

1. See about re-arranging >r order in op_compile_begin to simplify it and op_compile_end
1. Make stacks.inc call instead of macro based, set stack in rdi/rsi
1. Rename opcode_map to opcode_tbl
1. Add more ops to make defining a custom op less verbose/brittle
   1. opN[ ]op
   1. opNI[ ]op
   1. opB[ ]op
   1. opBI[ ]op
1. Dockerize and get a CI job that runs ./build.sh
1. Add bytecode op if/if-not
1. Add bytecode opcodes for litb, etc
1. Print error messages to disambiguate exit status
