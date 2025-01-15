# BlueVM

Minimalistic 64 bit Forth-like virtual machine for hackers. The BlueVM aims to:

1. Have a simplistic and hackable codebase
1. Support execution of any previously compiled bytecode
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
   1. Immediate
   1. Inlined code
   1. Bytecode
   1. 5 bits reserved
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
| XX | call | ( a -- ? ) | Call machine code at address |
| XX | execute | ( a -- ? ) | Execute bytecode located at address |
| XX | >r | ( a -- ) | Move top of data stack to return stack |
| XX | r> | ( -- a ) | Move top of return stacl to data stack |
| XX | ret | ( -- ) | Pops value from return stack and sets the instruction pointer |
| XX | [ | ( -- ) | Begin compiling bytecode |
| XX | ] | ( -- a ) | Append ret and end compilation, push addr where compilation started |
| XX | start | ( -- a ) | Push the code buffer location |
| XX | here | ( -- a ) | Push location of code buffer's here |
| XX | here! | ( a -- ) | Sets the location of code buffer's here |
| XX | b@ | ( a -- b ) | Push byte value found at addr |
| XX | @ | ( a -- ) | Push qword value found at addr |
| XX | b!+ | ( a b -- a' ) | Write byte value to, increment and push addr |
| XX | d!+ | ( a d -- a' ) | Write dword value to, increment and push addr |
| XX | !+ | ( a q -- a' ) | Write qword value to, increment and push addr |
| XX | , | ( q -- ) | Write qword value to, and increment, here |

### Stack operations

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| XX | depth | ( -- n ) | Push depth of the data stack |
| XX | litb | ( -- n ) | Push next byte from the input buffer |
| XX | = | ( a b -- t/f ) | Check top two items for equality and push result |
| XX | assert | ( t/f -- ) | Exits with 255 status code if top of stack is false (tmp) |
| XX | drop | ( x -- ) | Drops top of the data stack |
| XX | not | ( x -- 'x ) | Bitwise not top of the data stack |
| XX | swap | ( a b -- b a ) | Swap top two values on the data stack |
| XX | - | ( a b -- n ) | Push a - b |
| XX | + | ( a b -- n ) | Push a + b |
| XX | b, | ( b -- ) | Write byte value to, and increment, here |
| XX | d, | ( d -- ) | Write dword value to, and increment, here |
| XX | dup | ( a -- a a ) | Duplicate top of stack |

## Tools/Examples

Along with the code for BlueVM this repository also contains some tools and examples that can be used as reference:

| Name | Descripton | Location |
|----|----|----|
| blang | Quick and dirty compiler for a textual representation of the BlueVM bytecode | examples/blang |

## TODOs

1. Print error messages to disambiguate exit status
1. Move compile/interpret etc logic to interpreter.inc
1. Dockerize and get a CI job that runs ./build.sh
1. Write a bs0->blang (gnalb) decompiler by overwriting opcode map and opcode handler
1. Migrate ops to stack push/pop2
1. Bring back stack bounds checking
1. Add ip, ip! opcodes
1. Add if-else opcode ( t/f ta fa -- ? )
1. Add bytecode opcodes for litb, etc
1. Finish re-ordering opcodes
1. Make assert a host (tests) defined bytecode op
1. To allow nesting have [ ] return stack push/pop the opcode handler
1. Consider dropping the vm opcodes from the opcode map, only used for extended ops
   1. Or make non leaf opcodes bytecode only ( [ ] )
