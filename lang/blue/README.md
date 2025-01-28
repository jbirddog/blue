# Blue Language

## First Milestone

```
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 3C syscall ;
: bye (( -- noret )) 0 exit ;

bye
```

## After First Miletone

1. bluevm.py needs to contain effects for each op, else same problem as v1 with native ops
1. Consider (( reg edi status -- )) to simplify double_paren
   1. Actually just need (( and )) to set the current dictionary?
   1. (( edi status -- ))
1. Need to track machine code length of words, inline if smaller
1. Flow in for compiling words needs to be implemented vs prototyped
1. Need flow out while compiling word bodies
1. Need flow in while interpreting words
1. Need flow out while interpreting words
1. Remove need for bye to have a stack effact, infer instead
1. No ret needed for noret on ;
1. jmp to noret words
1. Move build stuff into own build.sh, call from main after vm tests

