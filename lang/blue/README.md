# Blue Language

## First Milestone

```
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 60 syscall ;
: bye (( -- noret )) 0 exit ;

bye
```

## Initial Braindump

1. Frontend that compiles down to BlueVM bs0 file
1. The BlueVM itself may never enter compilation mode unless host code does
1. Each Blue word should be header + machine code
1. Top level calls are vm `mccall`s
1. Calls within compiled words are handled by asm `call`s
1. The frontend needs to have a bootstrap bs0 (use blang/refactor ops to .pm file to generate for now)
1. Can the dictionary live soley in the frontend? How would code buffer addrs be resolved?
   1. Frontend will always know how many bytes are in the code buffer at any given time?
   1. Frontend bootstrap bs0 can have custom opcode to mccall an offset + start
   1. Frontend could buffer its code buffer output if needed

## After First Miletone

1. Remove need for bye to have a stack effact, infer instead
1. No ret needed for noret on ;
1. jmp to noret words
1. Refactor compiling a number (right now always litb)
1. Move build stuff into own build.sh, call from main after vm tests

