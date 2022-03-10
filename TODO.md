## gfe

1. Instr needs RegisterRefs?
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. consider making flow instr not implicit via call instr
1. more unit tests
1. gfe.sh - run examples
1. higher level refs where registers are inferred from called words
1. compile time dup, tuck, nip, etc when refs calculations get more strict
1. mangage sections when resp or : ?

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. db, dw, const, etc (const is just db/dw in .text to start?)
1. resw
1. word local dictionaries (or similar to support parsers) - just non globals in files?
1. handle name collisons for asm labels when importing/redeclaring
1. hide non global words before merging dictionaries when importing
1. make names asm friendly (stdin>buf is not a valid label)

# Targets

### f3

echo

1. thinking less about imports like sys and more about rolling it to suite needs
1. ^ location of fd for read in sys doesn't help composability
1. ^ after more code is written the right abstraction may emerge
1. word names being restricted by valid nasm labels hurts readability

### f4

