# TODOs

1. BC_EXEC_NUM
1. Top of stack always in rax?
1. Allocate data via sub rsp, 128
1. Dict entry 0x00 can have not found handler
1. Maybe also link to another dictionary
1. Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc
1. Likely go back to fasm for build time speed

## Keep in Mind

1. There is no ip - just compiling byte code top to bottom
1. Control flow happens via compiled machine code
1. Return stack is rsp
1. Data stack wraps

## Words

1. Call word at compile time
1. Compile runtime call to word
1. Push compile time addr of word
1. Push run time addr of word

## Next

1. Core word `dstsz` to push size of dst
1. New opcode to get compile time address of word
1. Core word `!`
1. Set `elfbsz` and `elfmsz` at compile time in `exit.1xo.asm`
1. Make `elfbsz` and `elfmsz` have 0x00 values in `elf.1xo.asm`

1. Do the same for `entry`

1. ed.pl needs better parsing of values for bytecodes
1. ed.pl needs colors for compile time word address
