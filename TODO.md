## compiler

1. Instr needs RegisterRefs?
1. more unit tests
1. CondCall is not flowing yet
1. inline is not flowing yet
1. import vs use - one brings in externs other all code from file
   1. link vs include? - use to determine how to build via dsl?
1. better newline support when generating asm
1. outputs don't flow
1. when importing, can drop the global decls from the imported env?
1. continue to infer registers from word body
   1. if fully specified, validate
   1. infer during word fallthrough? whole program infer?
1. validate needs to check for lingering refs/stack items
1. treat words with only decb more like resb
1. mov edx, rax bug

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. jmp vs call noret word
1. mov rxx, 1 -> xor exx, exx ; inc exx

## language

1. structs - some basic support is in f6

# Targets

### f7 (current)

1. Build process overhaul
   1. tedious to add new files/builds
   1. blue.sh - run examples
   1. blue.sh - stop the process if a step errors out
1. peephole - mov xxx, 0 -> xor xxx, xxx
1. Rosetta Code examples
   1. Strip whitespace from a string/Top and tail
1. Start putting examples on Rosetta Code
1. Drop [] support for now, simplify kernel for @

### f6

language and compiler improvements, v0.0.1

### f5

language ergonomic improvements

### f4

readability improvements from f3

### f3

echo
