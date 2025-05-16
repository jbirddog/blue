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
| 00 | exit | ( b -- ) | Exit with status from top of stack |
| 01 | true | ( -- t ) | Push true value |
| 02 | false | ( -- f ) | Push false value |
| 03 | ifelse | ( t/f ta fa -- ? ) | Call ta if t/f is true else call fa |
| 04 | mccall | ( a -- ? ) | Call machine code at address |
| 05 | call | ( a -- ? ) | Call bytecode located at address |
| 06 | tor | ( a -- ) | Move top of data stack to return stack |
| 07 | fromr | ( -- a ) | Move top of return stacl to data stack |

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
