## gfe

1. Instr needs RegisterRefs?
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. consider making flow instr not implicit from call instr
1. more unit tests
1. gfe.sh - run examples
1. higher level refs where registers are inferred from called words
1. remove explict CallGoWord, make user define words have a "runner"
1. overhaul run in instr, may tie in to above

### optimizations

1. inlining

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. imports
1. comment to eol
1. db, dw, const, etc (const is just db/dw in .text to start?)
1. word local dictionaries (or similar to support parsers)
