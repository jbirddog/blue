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

## Words

1. Call word at compile time
1. Compile runtime call to word
1. Push compile time addr of word
1. Push run time addr of word

## Next

1. Don't build a bin/elf
1. bin/exit needs cat obj/elf.1x obj/exit.1x
1. ed.pl needs better parsing of values for bytecodes
1. Need variables
   1. Just define a word
   1. New opcode to get compile time address of word
1. Need word to get start of dst
