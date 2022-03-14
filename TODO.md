## gfe

1. Instr needs RegisterRefs?
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. consider making flow instr not implicit via call instr
1. more unit tests
1. gfe.sh - run examples
1. gfe.sh - stop the process if a step errors out
1. higher level refs where registers are inferred from called words
1. CondCall is not flowing yet
1. inline is not flowing yet
1. import vs use - one brings in externs other all code from file
1. better newline support when generating asm

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. resX, decX
1. word local dictionaries (or similar to support parsers) - just non globals in files?
1. hide non global words before merging dictionaries when importing
1. structs
1. comment to eol don't parse inside words
1. support fallthrough between word decls (flow from previous latest)

# Targets

### f5

1. see about calling blue object files from Go, start migrating some logic

### f4 (current)

readability improvements from f3

1. thinking less about imports like sys and more about rolling it to suite needs
1. ^ location of fd for read in sys doesn't help composability
1. ^ after more code is written the right abstraction may emerge
1. collapse multiple extern/global/imports to one 
1. ^ global( start read bob joe )

### f3

echo
