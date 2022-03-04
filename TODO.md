## gfe

1. Instr needs RegisterRefs?
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. consider making flow instr not implicit from call instr
1. more unit tests
1. gfe.sh - run examples
1. move to code buf instead of lowering from the dictionary - needed for sections

### optimizations

1. inlining

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. imports
1. comment to eol
1. sections
1. db, dw, const, etc
1. word local dictionaries (or similar to support parsers)
