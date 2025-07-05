# TODOs

1. Move to just having one number type, 8 bytes
1. BC_EXEC_NUM
1. Put data stack in block 0
1. Top of stack always in rax?
1. Dict entry 0x00 can have not found handler
1. Maybe also link to another dictionary
1. Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc
1. Remove BC_FIN
1. Likely go back to fasm for build time speed
1. Once `entry` can be set for the output, move include files above entry

## Keep in Mind

1. There is no ip - just compiling byte code top to bottom
1. Control flow happens via compiled machine code
1. Return stack is rsp

## Elf Bytecode

1. Need to set binary size in elf header
1. Need to set entry in elf header
1. Can likely mutate the values in block 0

## Next

1. Remove bc include from onex.asm
1. Remove linux.inc
