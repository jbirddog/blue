# Blue Language

## TODOs

1. bluevm.py needs to contain effects for each op, else same problem as v1 with native ops
1. Consider (( edi status -- )) to simplify double_paren
   1. Actually just need (( and )) to set the current dictionary (and maybe stack)?
1. Need to track machine code length of words, inline if smaller
1. Flow in for compiling words needs to be implemented vs prototyped
1. Need flow out while compiling word bodies
1. Need flow in while interpreting words
1. Need flow out while interpreting words
1. Remove need for bye to have a stack effact, infer instead
1. No ret needed for noret on ;
1. jmp to noret words
1. Move build stuff into own build.sh, call from main after vm tests

## Effect Handling

### Problem summary

1. The Blue language uses stack effect declarations to:
   1. Compile data flow in/out of registers when calling words
   1. TODO: validate the stack at compile time
1. The BlueVM controls the data stack
1. In Blue, even when compiling a word, BlueVM words run at compile time
1. Given `: word (( x eax y edi -- z rsi )) dup FF rot word2 swap word3 drop + - word4 = .... ;
   1. How can the Blue language keep its stack effects in sync?

### ??

1. In the Blue frontend each word has a list of effects - ins/outs
1. Those effects need to map to the stack so the proper mov can be compiled

### Ideas

1. WordDecl and TopLevel have effects
   1. ins/outs are parsed, effects are known/infered
   1. Needed for validation/inference
   1. Inference - maybe BlueVM ops are no different than infering another word?
   1. Custom ops can register their effects
   1. Would require a runtime for parsing stack effects
      1. Useful for docs also
   1. Algo will be tricky with if-else/etc
      1. Maybe force all branches to have the same effect?
1, Flow in/out will pop/push from this compile time shadow stack
1. Stack effect words are only frontend?
   1. Seems like 2 3 + exit would still know to flow in a number
