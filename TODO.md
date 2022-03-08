## gfe

1. Instr needs RegisterRefs?
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. consider making flow instr not implicit via call instr
1. more unit tests
1. gfe.sh - run examples
1. higher level refs where registers are inferred from called words
1. compile time dup, tuck, nip, etc when refs calculations get more strict

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. imports
1. db, dw, const, etc (const is just db/dw in .text to start?)
1. resb/w
1. word local dictionaries (or similar to support parsers) - just non globals in files?

## Targets

### f3

f3.blue

read at most `cap` bytes from stdin, write back to stdout. Will be prep for starting 
to parse blue files from blue.

requires

1. resb/variable support
1. const for cap/stdin/stdout? and/or readStdIn writeStdout
1. import sys
