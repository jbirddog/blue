## gfe

1. Instr needs RegisterRefs
1. compute Word In/Out Refs, compare to declared
1. validate needs to check for lingering refs/stack items
1. mnemonics need in/out counts?
1. compile fib.blue

### optimizations

1. inlining

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. imports
1. global
1. local word flow
1. comment to eol
