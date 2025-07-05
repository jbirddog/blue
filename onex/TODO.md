# TODOs

* Move to just having one number type, 8 bytes
* BC_EXEC_NUM
* Put data stack in block 0
* Top of stack always in rax?
* Dict entry 0x00 can have not found handler
* Maybe also link to another dictionary
* Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc

## Keep in Mind

* There is no ip - just compiling byte code top to bottom
* Control flow happens via compiled machine code
* Return stack is rsp

## Milestone

* Need to set binary size in elf header
* Need to set entry in elf header
* Can likely mutate the values in block 0

