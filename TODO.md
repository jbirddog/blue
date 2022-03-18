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
1. ability to compute echo's buf.clamp at compile time
1. push/pop

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## blue

1. resX, decX
1. structs

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

### f4

readability improvements from f3

### f3

echo
