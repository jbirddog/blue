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

1. Input Buffer (2048 bytes)
1. Data Stack (2048 bytes)
1. Opcode Map (4096 bytes)
   1. BlueVM Opcode Map: 0x00 - 0x7F (2048 bytes)
   1. Extended Opcode Map: 0x80 - 0xFF (2048 bytes)
1. Code Buffer (4096 bytes)
   1. BlueVM Data (128 bytes)
   1. Space for Host (3968 bytes)

## Boot

When the BlueVM starts it will perform the allocation mentioned above and set the following 8 byte values in the
BlueVM Data portion of the beginning of the code buffer:

1. BlueVM state
1. Location of the input buffer
1. Location of the input buffer's here
1. Input buffer size in bytes
1. Location of the data stack
1. Location of the data stack's here
1. Data stack size in bytes
1. Location of the opcode map
1. Location of the code buffer
1. Location of the code buffer's here
1. Code buffer size in bytes
1. Location of opcode handler
1. Location of invalid opcode handler

These values act as hooks into the BlueVM and can be changed by the host at any step.

BlueVM will then set entries in the BlueVM opcode map and read 2048 bytes from stdin into the input buffer. This
initial read will serve as the bootstrap for the host and is interpreted. Once the input buffer is exhausted the
BlueVM exists using the stack depth as the status code.

## Execution

BlueVM follows a simple byte oriented execution strategy. Using the values from the BlueVM data portion of the code
buffer it:

1. Checks if a byte is available in the input buffer
   1. If not exit using stack depth as status code
   1. If so read a byte and increment the input buffer's here by one byte
1. Locate the opcode entry in the opcode map
   1. If code address is 0 push the opcode on the data stack and call invalid opcode handler
1. Push the code address and flags on the data stack and call the opcode handler
1. Goto 1

Because of this "late binding" approach, the host can change the values that the BlueVM uses to execute, including
opcodes, granting it full control.

## Opcode Map Structure

Each entry in the opcode map is 16 bytes.

1. Code address (8 bytes)
1. Header (8 bytes)
   1. Flags (1 byte)
   1. Opcode size (1 byte)
   1. Reserved (6 bytes)

## Opcode Handler

Once an opcode entry is located in the opcode map the opcode handler is called. The BlueVM has two opcode handlers,
interpret (default) and compile. The interpret handler calls the code address specified in the opcode entry. The
compile handler finds the opcode length in the opcode entry and copies that many bytes, including the opcode, into
the code buffer and advances the code buffer's here.

## Opcodes

All opcodes are represented in hexdecimal.

| Opcode | Name | Stack Effect | Description |
|----|----|----|
| 00 | halt | ( -- ) | Halt execution of the BlueVM |
| 01 | depth | ( -- n ) | Push depth of the data stack |
| 01 | b> | ( -- n ) | Push next byte from the input buffer |
| 02 | = | ( a b -- t/f ) | Check top two items for equality and push result |

## Tools/Examples

Along with the code for BlueVM this repository also contains some tools and examples that can be used as reference:

| Name | Descripton | Location |
|----|----|----|
| blang | Quick and dirty compiler for a textual representation of the BlueVM bytecode | examples/blang |

## TODOs

1. Consider taking a bvm file that contains the full memory mapping. State can be dumped/restored this way
1. Print error messages to disambiguate exit status
1. Cut data stack size back to 1024, move BlueVM Data to 256 bytes after data stack
1. If the host has not set an opcode handler, can bypass push/popping the opcode entry
1. If the host has not set an invalid opcode handler, can bypass push/popping the opcode
1. See about improving data_stack_push/pop
