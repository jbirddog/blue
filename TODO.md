## compiler

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
1. when importing, can drop the global decls from the imported env?
1. ability to compute echo's buf.clamp (was 1024 -> 2047 for and) at compile time
1. push/pop
1. continue to infer registers from word body
   1. if fully specified, validate
   1. infer during word fallthrough? whole program infer?
1. validate needs to check for lingering refs/stack items
1. check env.AppendInstr usage to see if compiling check can be moved there
1. treat words with only decb more like resb
1. lea

### optimizations

1. inlining
1. remove unused words before asm

#### peephole

1. jmp vs call ret at tail of word
1. mov xxx, 0 -> xor xxx, xxx

## language

1. structs

# Targets

### f6 (current)

1. Clobber detection/handling, blue.blue is example of issue
   1. push/pops based on called words indirect register usage (syscall steps on rcx)
1. Rosettacode task `Command-line arguments`
   1. blocked on clobber detection/handling
1. Rosettacode task `Read entire file`
   1. open system call
   1. stat system call
   1. mmap system call
   1. close system call
   1. struct for stat
1. Rosettacode task `Create a file`
1. mov edx, rax bug
1. README

### f5

language ergonomic improvements

### f4

readability improvements from f3

### f3

echo
