# TODOs

1. BC_EXEC_NUM
1. Put data stack in block 0
1. Top of stack always in rax?
1. Dict entry 0x00 can have not found handler
1. Maybe also link to another dictionary
1. Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc
1. Likely go back to fasm for build time speed

## Keep in Mind

1. There is no ip - just compiling byte code top to bottom
1. Control flow happens via compiled machine code
1. Return stack is rsp

## Next

1. Move elf header logic into its own bytecode file
1. Mutate the values in block 0
   1. Need to set binary size in elf header
   1. Need to set reserved size in elf header
   1. Need to set entry in elf header

