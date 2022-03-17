## gfe

1. Instr needs RegisterRefs?
1. consider making flow instr not implicit via call instr
1. more unit tests
1. gfe.sh - run examples
1. gfe.sh - stop the process if a step errors out
1. CondCall is not flowing yet
1. inline is not flowing yet
1. import vs use - one brings in externs other all code from file
1. better newline support when generating asm
1. better placement of comments in asm
1. outputs don't flow
1. collapse multiple extern/imports to one (const/resb/etc?) 
1. when importing, can drop the global decls from the imported env?
1. move to go 1.18

### things

want a quick movement from low to high level 
infer registers is good first step
general solutions overwritten by optimal specific versions
some clamp operation that uses branching vs sse override
sys read/write vs echo's read/write
import linux
import sse

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. resX, decX
1. word local dictionaries (or similar to support parsers) - just non globals in files?
1. structs
1. pmaxud, pminud for clamp in echo's write

# Targets

### f5 (current)

1. some bit of code that would help push the gfe conversion to blue along
1. ^ f4 looked at read/write support
1. ^ mmap for file reads/writes?
1. continue to infer registers from word body
1. ^ echo's 2nd write failed again after clamp
1. ^ if fully specified, validate
1. ^ infer during word fallthrough? whole program infer?
1. validate needs to check for lingering refs/stack items
1. push/pop

### f4

readability improvements from f3

### f3

echo
