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
1. ability to compute echo's buf.clamp (RIP, was 1024 -> 2047 for and) at compile time
1. push/pop
1. continue to infer registers from word body
1. ^ if fully specified, validate
1. ^ infer during word fallthrough? whole program infer?
1. validate needs to check for lingering refs/stack items
1. check env.AppendInstr usage to see if compiling check can be moved there

### random notes

mov 0(%rsp), %rdi ; argc
lea 8(%rsp), %rsi ; argv
lea 16(%rsp, %rdi, 8), %rdx ; env?

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

### f6

1. Some tooling
1. ^ build
1. ^ test

### f5 (current)

1. Some code to help the migration of blue to blue
1. ^ main driver for blue

### f4

readability improvements from f3

### f3

echo
