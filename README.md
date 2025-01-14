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
initial read will serve as the bootstrap for the host and is interpreted until the host halts execution.

## Execution

BlueVM follows a simple byte oriented execution strategy. Using the values from the BlueVM data portion of memory
it begins the outer interpreter:

1. Read byte from and increment instruction pointer
1. Locate the opcode entry in the opcode map
   1. If code address is 0 push the opcode on the data stack and call invalid opcode handler
1. Push the code address and flags on the data stack and call the opcode handler
1. Goto 1

Because of this "late binding" approach, the host can change the values that the BlueVM uses to execute. The outer
interpreter requires that the host termintes execution properly. One way to do this is with the `halt` opcode.

## Opcode Map Structure

Each entry in the opcode map is 16 bytes.

1. Header (8 bytes)
   1. Flags (1 byte)
   1. Size (1 byte)
   1. Reserved (6 bytes)
1. Code (inline or address) (8 bytes)

## Opcode Handler

Once an opcode entry is located in the opcode map the opcode handler is called. The BlueVM has two opcode handlers,
interpret (default) and compile. The interpret handler calls the code address specified in the opcode entry. The
compile handler finds the opcode length in the opcode entry and copies that many bytes, including the opcode, into
the code buffer and advances the code buffer's here.

## Opcodes

All opcodes are represented in hexdecimal and subject to change.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 00 | halt | ( -- ) | Halt execution of the BlueVM |
| 01 | depth | ( -- n ) | Push depth of the data stack |
| 02 | litb | ( -- n ) | Push next byte from the input buffer |
| 03 | = | ( a b -- t/f ) | Check top two items for equality and push result |
| 04 | assert | ( t/f -- ) | Exits with 255 status code if top of stack is false (tmp) |
| 05 | drop | ( x -- ) | Drops top of the data stack |
| 06 | not | ( x -- 'x ) | Bitwise not top of the data stack |
| 07 | swap | ( a b -- b a ) | Swap top two values on the data stack |
| 08 | [ | ( -- ) | Set the opcode handler to interpret |
| 09 | ] | ( -- ) | Set the opcode handler to compile |
| 0A | start | ( -- a ) | Push the code buffer location |
| 0B | - | ( a b -- n ) | Push a - b |
| 0C | + | ( a b -- n ) | Push a + b |
| 0D | b@ | ( a -- b ) | Push byte value found at addr |
| 0E | here | ( -- a ) | Push location of code buffer's here |
| 0F | execute | ( a -- ? ) | Execute bytecode located at address |
| 10 | ret | ( -- ) | Pops value from return stack and sets the instruction pointer |
| 11 | call | ( a -- ? ) | Call machine code at address |
| 12 | b!+ | ( a b -- a' ) | Write byte value to, increment and push addr |
| 13 | here! | ( a -- ) | Sets the location of code buffer's here |
| 14 | b, | ( b -- ) | Write byte value to, and increment, here |

## Tools/Examples

Along with the code for BlueVM this repository also contains some tools and examples that can be used as reference:

| Name | Descripton | Location |
|----|----|----|
| blang | Quick and dirty compiler for a textual representation of the BlueVM bytecode | examples/blang |

## TODOs

1. Print error messages to disambiguate exit status
1. Move compile/interpret etc logic to interpreter.inc
1. Dockerize and get a CI job that runs ./build.sh
1. In opcode map entry move addr/code field right after flags/size for more inline bytes
1. Opcodes can't have inline machine code with call/jmp since offsets are wrong after copy to mem
1. Machine code needs to be able to call bytecode
   1. Need opcodes to supply addrs to call (data/return stack push/pop, handle op code, etc)
   1. Put addres at start of code buffer so no literal addrs in bs0 files
   1. Add test for calling + from machine code
1. Write a bs0->blang (gnalb) decompiler by overwriting opcode map and opcode handler
1. Bring back stack push/pop2
1. Bring back stack bounds checking
1. Add dup
1. Extend blang op array to include more info of each opcode, use for tooling
1. Add build script that uses ops from blang to generate files (consts, macros, md table, etc)
1. After tooling, start to re-arrange opcodes
