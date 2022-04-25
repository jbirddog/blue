## compiler

1. Instr needs RegisterRefs?
1. more unit tests
   1. needs to be easier to test Instr and AsmInstr
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
   1. global strings also fall into this bucket
1. More peephole optimizations
   1. mov rxx, 0 -> xor exx
   1. mov rxx, 1 -> xor exx, exx ; inc exx
1. clobber support for indirect register usage
1. x8664 words can have default registers - ( a -- b ) 8 add ; a/b = eax
1. x8664 words can have required registers 4 shl needs ecx
1. can't c" bob" var ! - operation size not specified

### optimizations

1. inlining
1. remove unused words before asm
1. whole word optimizations

#### peephole


## language

1. structs - some basic support is in f6

# Targets

### f7 (current)

1. Build process overhaul
   1. tedious to add new files/builds
   1. blue.sh - run examples
   1. blue.sh - stop the process if a step errors out
1. Rosetta Code examples
   1. Strip whitespace from a string/Top and tail
   1. Environment variable
1. Update README/tutorial with new assembly

### f6

language and compiler improvements, v0.0.1

### f5

language ergonomic improvements

### f4

readability improvements from f3

### f3

echo
