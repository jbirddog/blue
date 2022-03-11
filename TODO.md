## gfe

1. Instr needs RegisterRefs?
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. consider making flow instr not implicit via call instr
1. more unit tests
1. gfe.sh - run examples
1. gfe.sh - stop the process if a step errors out
1. higher level refs where registers are inferred from called words
1. mangage sections when resp or : ?
1. CondCall is not flowing yet
1. Only 1 CondCall is supported per word (unique labels will fix this)
1. If array is used per word, redeclarations work and map can be used at the top level
1. ^ still needs array declaration order for writes to be stable
1. ^ word decls in instrs should support this
1. ^ think map doesn't need array since word decs in instrs will own previous words
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
1. handle name collisons for asm labels when importing/redeclaring
1. hide non global words before merging dictionaries when importing
1. make names asm friendly (stdin>buf is not a valid label)
1. structs

# Targets

### f5

1. see about calling blue object files from Go, start migrating some logic

### f4 (current)

readability improvements from f3

1. thinking less about imports like sys and more about rolling it to suite needs
1. ^ location of fd for read in sys doesn't help composability
1. ^ after more code is written the right abstraction may emerge
1. infer section, no manual override for now? (unless section has been specified)
1. generate unique asm label per word unless global, then verbatim
1. collapse multiple extern/global/imports to one 
1. ^ global( start read bob joe )
1. const
1. inlined literal int when not compiling (run word issue)

### f3

echo
