## compiler

1. more unit tests
   1. needs to be easier to test Instr and AsmInstr
1. CondCall is not flowing yet
1. import vs use - one brings in externs other all code from file
   1. link vs include? - use to determine how to build via dsl?
1. better newline support when generating asm
1. when importing, can drop the global decls from the imported env?
1. continue to infer registers from word body
   1. infer during word fallthrough?
   1. need x8664 "words" to have register definitions
1. More peephole optimizations
   1. mov rxx, 0 -> xor exx
   1. mov rxx, 1 -> xor exx, exx ; inc exx
1. x8664 words can have default registers - ( a -- b ) 8 add ; a/b = eax
1. x8664 words can have required registers 4 shl needs ecx
1. Rosetta Code examples
   1. Strip whitespace from a string/Top and tail
   1. Environment variable

### optimizations

1. inlining
1. remove unused words before asm
1. whole word optimizations

#### peephole

1. bring back call/ret -> jmp

## language

1. structs - some basic support is in f6

# Targets

### f8 (Current)

### f7

bake, language and compiler improvements, v0.0.2

### f6

language and compiler improvements, v0.0.1

### f5

language ergonomic improvements

### f4

readability improvements from f3

### f3

echo
