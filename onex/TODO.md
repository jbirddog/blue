# TODOs

1. Changes to `bc.inc` require `make clean` for 1x files
1. Drop `k_` prefix, define -> def_word
1. Add `dup`
1. Add `dstout`
1. Add `bye`, remove BC_FIN
1. Top of stack always in rax?
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

1. ed.pl needs better parsing of values for bytecodes
1. ed.pl needs colors for compile time word address
