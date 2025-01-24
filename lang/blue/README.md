# Blue Language

## First Milestone

```
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 3C syscall ;
: bye (( -- noret )) 0 exit ;

bye
```

## After First Miletone

1. Still perl?
1. Consider (( reg edi status -- )) to simplify double_paren
   1. Actually just need (( and )) to set the current dictionary?
   1. (( edi status -- ))
1. Better number/base support
1. Need to track machine code length of words, inline if smaller
1. Flow in for compiling words needs to be implemented vs prototyped
1. Need flow out while compiling word bodies
1. Need flow in while interpreting words
1. Need flow out while interpreting words
1. Remove need for bye to have a stack effact, infer instead
1. No ret needed for noret on ;
1. jmp to noret words
1. Refactor compiling a number (right now always litb)
1. Move build stuff into own build.sh, call from main after vm tests
1. The frontend needs to have a bootstrap bs0 (use blang/refactor ops to .pm file to generate for now)
   1. Can be start of code_buffer array

## BlueVM Integration

1. Blue is having to track the perceived vm here/stack depth/etc - not sure how best to resolve this
   1. BlueVM could be a process the compiler talks to - that is a bit complex
   
